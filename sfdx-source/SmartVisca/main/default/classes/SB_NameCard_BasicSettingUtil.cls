/*
 *
 * SV_DEV-596 連携条件レコードの取得方法を統一
 *
 * Copyright (c) 2017 SunBridge Inc.
 *
 *  @author mao
 *  @Version 1.22      2017.09.XX
 */
public class SB_NameCard_BasicSettingUtil {
  /*
      @param recordType 連携マッピングのレコードタイプ
      @param keySet  検索される項目のSet .... 削除済みの項目は画面に表示しないため、保存の時削除されます
  */
  public static List<NameCardRenkeiMapping__c> getNameCardMapping(String recordType, Set<String> keySet) {
    NameCardBasicSetting__c bb = SB_NameCard_BasicSetting.getNameCardBasicSetting();
    if (keySet == null || keySet.isEMpty()) {
        return [select Id,Name,RecordTypeId,TargetName__c,NameCardName__c,IsActive__c,LastModifiedDate,LastModifiedById,LastModifiedBy.Name,Recordtype.Developername
                                                            from NameCardRenkeiMapping__c Where RecordTypeId = :recordType AND BasicSetting__c =:bb.Id AND BasicSetting__c!= null
                                                            ORDER BY LastModifiedDate Desc limit 10000 ];
    } else {
        return [select Id,Name,RecordTypeId,TargetName__c,NameCardName__c,IsActive__c,LastModifiedDate,LastModifiedById,LastModifiedBy.Name,Recordtype.Developername
                                                            from NameCardRenkeiMapping__c Where RecordTypeId = :recordType AND BasicSetting__c =:bb.Id AND BasicSetting__c!= null
                                                                And TargetName__c IN :keySet
                                                            ORDER BY LastModifiedDate Desc limit 10000 ];
    }
  }
  /*
      連携マッピングメタデータ取得
      @param reid 連携マッピングメタデータのレコードタイプ
  */
  public static List<DefaultRenkeiMapping__mdt> getMappingMetadata(String reid) {
    return [Select ID,TargetName__c,NameCardName__c,IsActive__c,recordtype__c
              From DefaultRenkeiMapping__mdt
              Where recordtype__c = :reid];
  }
  /*
      名刺設定値をセユトク
      @param settingType 名刺設定値タイプ(現在は名刺から引き継ぐ項目とOhter)
  */
  public static List<NameCardSettingValues__c> getSettingValues(String settingType) {
    return [Select Id,Name,TextValue01__c,Type__c From NameCardSettingValues__c Where Type__c = :settingType ORDER BY CreatedDate ASC, index__c];
  }
  /*
      連携条件取得
  */
  public static List<NameCardRenkeiJyoken__c> getNameCardRenkeiJyoken(String rid) {
    if (String.isBlank(rid)) {
      NameCardBasicSetting__c bb = SB_NameCard_BasicSetting.getNameCardBasicSetting();
      return [select Id,Name, NameCardName__c,Operator__c,Value__c,NameCardDataType__c,LastModifiedById,LastModifiedBy.Name,LastModifiedDate
                                                from NameCardRenkeiJyoken__c Where BasicSetting__c=:bb.Id AND BasicSetting__c != null Order By LastModifiedDate Desc
                                                limit 10000 ];
    } else {
      return [select Id,Name, NameCardName__c,Operator__c,Value__c,NameCardDataType__c,LastModifiedById,LastModifiedBy.Name,LastModifiedDate
                                            from NameCardRenkeiJyoken__c Where BasicSetting__c=:rid AND BasicSetting__c != null Order By LastModifiedDate Desc
                                            limit 10000 ];
    }
  }
}