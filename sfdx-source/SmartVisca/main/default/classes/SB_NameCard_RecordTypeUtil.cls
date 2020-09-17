/**
 *
 * SB_NameCard_RecordTypeUtil
 *   JavaScriptで処理する用の レコードタイプの情報を渡すためのヘルパーメソッド
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2019.08.xx v2.4 
 *  @Version 2.6 全 2020.09.03 PRODUCT-697 [取引先登録]でマスターレコードタイプしか割り当てられていないユーザが操作をすると割り当てられていないカスタムレコードタイプでレコードを作成しようとしエラーになる。
 *
 **/
public with sharing class SB_NameCard_RecordTypeUtil {

  // 個々のレコードタイプに関する情報
  public class RecordTypeInfo {
    public String  label;
    //public String  apiname;
    public String  id { get; private set; }
    public Boolean isActive { get; private set; }     // 有効になってる
    public Boolean isAvailable { get; private set; }  // ユーザが作成に使える
    public Boolean isDefault { get; private set; }    // ユーザのデフォルト
    public Boolean isQuery { get; private set; }      // 検索対象にできる 
    RecordTypeInfo(Schema.RecordTypeInfo info) {
      this.label = info.getName();
      this.id = info.getRecordTypeId();
      this.isActive = info.isActive();
      this.isAvailable = info.isAvailable();
      this.isDefault = info.isDefaultRecordTypeMapping();
      this.isQuery = false;
    }
    RecordTypeInfo(Schema.RecordTypeInfo info, Boolean isQuery) {
      this.label = info.getName();
      this.id = info.getRecordTypeId();
      this.isActive = info.isActive();
      this.isAvailable = info.isAvailable();
      this.isDefault = info.isDefaultRecordTypeMapping();
      this.isQuery = isQuery;
    }
  }

  // オブジェクトごとのレコードタイプに関する情報
  public class RecordTypeInfos {
    public String objName { get; private set; }  // オブジェクトAPI名
    public String objLabel { get; private set; }  // オブジェクト ラベル
    public Boolean restricted { get; private set; }   // SmartVisca設定で検索対象のレコードタイプが 制限されてる → 検索時はかならずID指定する。
    public List<RecordTypeInfo> infos { get; private set; }
    // constructor
    public RecordTypeInfos(String objName) {
      this.restricted = false;    // v2.4
      this.infos = new List<RecordTypeInfo>();
      this.objName = objName;
      Schema.DescribeSObjectResult dsr = Schema.getGlobalDescribe().get(objName).getDescribe();
      this.objLabel = dsr.getLabel();
      Set<String> selectedRectypeIds = getSelectedRegistRecTypeIds(objName);
      this.restricted = !selectedRectypeIds.isEmpty();
      Map<String, Schema.RecordTypeInfo> mapRecordTypes = dsr.getRecordTypeInfosByName();
      for (String key : mapRecordTypes.keySet()) {
        Schema.RecordTypeInfo info = mapRecordTypes.get(key);
        if (info.isAvailable() == false) continue;   // PRODUCT-697 ユーザが使用可能なレコードタイプだけ
        if (info.isMaster() == true) continue;   // マスターは除外
        Boolean isQuery = !this.restricted || selectedRectypeIds.contains(info.getRecordTypeId());
        if (info.isDefaultRecordTypeMapping() && !this.infos.isEmpty()) {
          // デフォルトは一番目に
          this.infos.add(0, new RecordTypeInfo(info, isQuery));
        }
        else {
          this.infos.add(new RecordTypeInfo(info, isQuery));
        }
      }
    }

    // 基本設定にある検索に使うレコードタイプID設定　無効なのもあるかも
    private Set<String> getSelectedRegistRecTypeIds(String objName) {
      Set<String> result = new Set<String>();
      String validIds = SB_NameCard_BasicSetting.getRegistQuerySelectedRecordTypeIds(objName);
      if (String.isNotBlank(validIds)) {
        result.addAll(validIds.split(';\\s*'));
      }
      return result;
    }
  } // public class RecordTypeInfos 

  // オブジェクトAPI名と オブジェクトごとのレコードタイプに関する情報 のマップ
  public static Map<String, RecordTypeInfos> create(List<String> objNames) {
    Map<String, RecordTypeInfos> result = new Map<String, RecordTypeInfos> ();
    for (String objName : objNames) {
      result.put(objName, new RecordTypeInfos(objName));
    }
    return result;
  }

  // オブジェクトごとのレコードタイプに関する情報
  public static RecordTypeInfos create(String objName) {
    return new RecordTypeInfos(objName);
  }

}