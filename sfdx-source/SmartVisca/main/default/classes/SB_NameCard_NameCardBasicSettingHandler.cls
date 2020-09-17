/**
 *
 *  SB_NameCard_NameCardBasicSettingHandler 基本設定トリガHandler
 *
 *
 *  Copyright (C) 2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author gao
 *  @Version 2.1      2018.04.xx SV_DEV-865 名刺基本設定オブジェクトのトリガを作って不正な値で保存されたらエラーにする。
 *  @Version 2.4.1    2019.10.xx SV_DEV-2194 インストール/アップデート操作時はNameCardBasicSettingのトリガで実行している入力チェックをスキップする
 *  @Version 2.5      2020.01.xx SV_DEV-2178 ポストインストールスクリプトで発生した例外をキャッチして通知する。
 *  @Version 2.5.4 sawano 2020.08.xx PRODUCT-594 新規Salesforce組織にSVインストール後、リード拡張パッケージをインストールすると、インストールがエラー終了してインストールできないので、対応する。
 *
 **/

public with sharing class SB_NameCard_NameCardBasicSettingHandler {


  // 項目APIを保存する項目
  // RenkeiSpecificItems__c 自動連携:指定項目
  private final Set<String> fieldCheckSet = new Set<String> {'RenkeiSpecificItems__c'};

  // RenkeiCampaignStatus__c 自動連携:キャンペーンの状況
  private final Set<String> campaignCheckSet = new Set<String> {'RenkeiCampaignStatus__c'};

  // レコードタイプ保存する項目(取引先)
  // RenkeiAccountRecordTypes__c 自動連携:取引先レコードタイプ
  // RenkeiAccountQueryRecordTypeIds__c 自動連携:自動連携で検索対象の取引先レコードタイプ
  private final Set<String> recordTypeCheckSetAccount = new Set<String> {'RenkeiAccountRecordTypes__c', 'RenkeiAccountQueryRecordTypeIds__c'};

  // レコードタイプ保存する項目(取引先責任者)
  // RenkeiContactRecordTypes__c 自動連携:取引先責任者レコードタイプ
  // RenkeiContactQueryRecordTypeIds__c 自動連携:自動連携で検索対象の取引先責任者レコードタイプ
  private final Set<String> recordTypeCheckSetContact = new Set<String> {'RenkeiContactRecordTypes__c' , 'RenkeiContactQueryRecordTypeIds__c'};

  // レコードタイプ保存する項目(リード)
  // RenkeiLeadRecordTypes__c    自動連携:リードレコードタイプ
  // RenkeiLeadQueryRecordTypeIds__c    自動連携:自動連携で検索対象のリードレコードタイプ
  private final Set<String> recordTypeCheckSetLead = new Set<String> {'RenkeiLeadRecordTypes__c' , 'RenkeiLeadQueryRecordTypeIds__c'};

  public SB_NameCard_NameCardBasicSettingHandler() {

  }

  /**
   * @description beforeInsert実行メソッド
   * @param newList Trigger.new
   * @return
  */
  public void beforeInsert(List<NameCardBasicSetting__c> newList) {
    // 念の為ここも判断
    if (Trigger.isBefore && Trigger.isInsert) {
      beforeCheck(newList);
    }
  }

  /**
   * @description beforeUpdate実行メソッド
   * @param newList　Trigger.new
   * @param oldMap  Trigger.oldMap  v2.5.4
   * @return
  */
  public void beforeUpdate(List<NameCardBasicSetting__c> newList, Map<Id, NameCardBasicSetting__c> oldMap) {
    // 念の為ここも判断
    if (Trigger.isBefore && Trigger.isUpdate) {
      // 項目チェック
      fieldCheck(newList);
      // レコードタイプチェック
      recordTypesCheck(newList);

      // ポストインストールスクリプト実行中はキャンペーンに関する入力チェックをスキップする
      if ( SB_NC_PostInstallScript.isInstall ){
        return;
      }
      // キャンペーン に関するチェック
      for (NameCardBasicSetting__c cur : newList) {
        NameCardBasicSetting__c prv = oldMap.get(cur.Id);
        if (cur.RenkeiCampaignStatus__c !=null && cur.RenkeiCampaignStatus__c != prv.RenkeiCampaignStatus__c) {
          // NULLでなく、変わったときだけ  リード拡張のインストール時に呼ばないように！
          campaignCheck(newList);
          break;
        }
      }
    }
  }
  /**
   * @description 値が正しいがどうかチェックメソッド
   * @param newList Trigger.new
   * @return
  */
  private void beforeCheck(List<NameCardBasicSetting__c> newList) {
    // 項目チェック
    fieldCheck(newList);
    // レコードタイプチェック
    recordTypesCheck(newList);

    // ポストインストールスクリプト実行中はキャンペーンに関する入力チェックをスキップする
    if ( SB_NC_PostInstallScript.isInstall ){
      return;
    }
    // キャンペーン に関するチェック
    campaignCheck(newList);
  }

  /**
   * @description 項目APIに関するチェックメソッド
   * @param newList Trigger.new
   * @return
  */
  private void fieldCheck(List<NameCardBasicSetting__c> newList) {
    Map<String, Schema.SObjectField> accountFieldsMap = Account.getSObjectType().getDescribe().fields.getMap();
    for (NameCardBasicSetting__c basicSetting : newList) {
      for (String field : fieldCheckSet) {
        if (String.isNotBlank((String)basicSetting.get(field))) {
          String fieldAPI = (String)basicSetting.get(field);
          if (!accountFieldsMap.containsKey(fieldAPI)) {
            basicSetting.addError(String.format(System.Label.SB_NC_SETTING_ERROR_Wrong_RenkeiSpecificItems, new String[]{fieldAPI}));
          }
        }
      }
    }
  }

  // キャンペンメンバーのステータスの選択肢
  // 実際にチェックが必要なときだけインスタンス化するように Singletone
  private static Set<String> campaignStatusSet {
    get {
      if (campaignStatusSet == null) {
        campaignStatusSet = new Set<String>();
        Map<String,Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.DescribeFieldResult fieldResult;
        if (schemaMap.containsKey('CampaignMember')) {
          fieldResult = schemaMap.get('CampaignMember').getDescribe().fields.getMap().get('status').getDescribe();
        }
        if (fieldResult != null) {
          List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
          for (Schema.PicklistEntry f: ple) {
            if (!f.isActive()) {
              continue;
            }
            campaignStatusSet.add(f.getValue());
          }
        }
      }
      return campaignStatusSet;
    }
    set;
  }

  /**
   * @description 項目APIに関するチェックメソッド
   * @param newList Trigger.new
   * @return
  */
  private void campaignCheck(List<NameCardBasicSetting__c> newList) {
    for (NameCardBasicSetting__c basicSetting : newList) {
      for (String field : campaignCheckSet) {
        if (String.isNotBlank((String)basicSetting.get(field))) {
          String campaignStatus = (String)basicSetting.get(field);
          if (!campaignStatusSet.contains(campaignStatus)) {
            basicSetting.addError(String.format(System.Label.SB_NC_MAPPING_Trigger_campaignStatus_ErrorMessage,
                                                new String[]{CampaignMember.getSObjectType().getDescribe().getLabel(),
                                                             CampaignMember.Status.getDescribe().getLabel(),
                                                             campaignStatus}));
          }
        }
      }
    }
  }

  /**
   * @description レコードタイプにチェック
   * @param newList Trigger.new
   * @return
  */
  private void recordTypesCheck(List<NameCardBasicSetting__c> newList) {
    //取引先レコードタイプチェック
    recordTypeCheck(newList, Account.sObjectType, recordTypeCheckSetAccount);
    //取引先責任者レコードタイプチェック
    recordTypeCheck(newList, Contact.sObjectType, recordTypeCheckSetContact);
    //リードレコードタイプチェック
    recordTypeCheck(newList, Lead.sObjectType, recordTypeCheckSetLead);
  }

  /**
   * @description レコードタイプにチェックロジック
   * @param newList Trigger.new
   * @param sObjType チェックのオブジェクト
   * @param recordTypeCheckSet チェックの項目
   * @return
  */
  private void recordTypeCheck(List<NameCardBasicSetting__c> newList, sObjectType sObjType, Set<String> recordTypeCheckSet) {
    Map<String, Schema.RecordTypeInfo> recordTypeIdMap = new Map<String, Schema.RecordTypeInfo>();
    for (Schema.RecordTypeInfo recordTypeInfo : sObjType.getDescribe().getRecordTypeInfos()) {
      if (!recordTypeInfo.isMaster()) {
        recordTypeIdMap.put(recordTypeInfo.getRecordTypeId(), recordTypeInfo);
      }
    }
    for (NameCardBasicSetting__c basicSetting : newList) {
      for (String field : recordTypeCheckSet) {
        if (String.isNotBlank((String)basicSetting.get(field))) {
          String[] recordTypes = ((String)basicSetting.get(field)).split(';');
          for (String recordType : recordTypes) {
            if (!recordTypeIdMap.containsKey(recordType)) {
              basicSetting.addError(String.format(System.Label.SB_NC_MAPPING_NoObject_ErrorMessage, new String[]{sObjType.getDescribe().getLabel(), recordType}));
            }
            else if (!recordTypeIdMap.get(recordType).isAvailable()) {
              basicSetting.addError(String.format(System.Label.SB_NC_MAPPING_NoAvailableR_ErrorMessage, new String[]{sObjType.getDescribe().getLabel(), recordTypeIdMap.get(recordType).Name}));
            }
          }
        }
      }
    }
  }
}