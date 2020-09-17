/**
 * Copyright (c) 2011-2015 SunBridge
 *
 * SB_NameCard_NameCardBasicSettingHandler TestClass
 *
 *  @author gao
 *  @Version 2.1      2018.04.xx SV_DEV-865 名刺基本設定オブジェクトのトリガを作って不正な値で保存されたらエラーにする。
 *  @Version 2.5.4 sawano 2020.08.xx PRODUCT-594 新規Salesforce組織にSVインストール後、リード拡張パッケージをインストールすると、インストールがエラー終了してインストールできないので、対応する。
 *
 **/
 @isTest
public with sharing class SB_NameCard_NameCardBasicSettingHTest {

/******************************************* 基本設定 指定項目 Start *******************************************/

  /**
   * @description 基本設定新規 -> 指定項目:標準項目test
  */
  public static testMethod void createBasicSettingSpecificItemsStandField(){
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c(RenkeiSpecificItems__c = 'Name');
    Database.SaveResult lsr = Database.insert(setting, false);
    System.assertEquals(true, lsr.isSuccess());
    System.assertEquals(0, lsr.getErrors().size());
  }
  /**
   * @description 基本設定新規 -> 指定項目:カスタム項目test
  */
  public static testMethod void createBasicSettingSpecificItemsCustomField(){
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c(RenkeiSpecificItems__c = SB_NameCard_RenkeiMapperUtil.getManagedfileName('namecard__c', 'NameCardMemo__c'));
    Database.SaveResult lsr = Database.insert(setting, false);
    System.assertEquals(true, lsr.isSuccess());
    System.assertEquals(0, lsr.getErrors().size());
  }

  /**
   * @description 基本設定新規 -> 指定項目:存在しない項目test
  */
  public static testMethod void createBasicSettingSpecificItemsNoField(){
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c(RenkeiSpecificItems__c = 'xx');
    Database.SaveResult lsr = Database.insert(setting, false);
    System.assertEquals(false, lsr.isSuccess());
    System.assertEquals(1, lsr.getErrors().size());
    System.assertEquals(String.format(System.Label.SB_NC_SETTING_ERROR_Wrong_RenkeiSpecificItems, new String[]{'xx'}), lsr.getErrors()[0].getMessage());
  }

  /**
   * @description 基本設定更新 -> 指定項目:標準項目test
  */
  public static testMethod void updateBasicSettingSpecificItemsStandField(){
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c(RenkeiSpecificItems__c = 'Name');
    insert setting;
    setting.RenkeiSpecificItems__c = 'Fax';
    Database.SaveResult lsr = Database.update(setting, false);
    System.assertEquals(true, lsr.isSuccess());
    System.assertEquals(0, lsr.getErrors().size());
  }

  /**
   * @description 基本設定更新 -> 指定項目:カスタム項目test
  */
  public static testMethod void updateBasicSettingSpecificItemsCustomField(){
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c(RenkeiSpecificItems__c = 'Name');
    insert setting;
    setting.RenkeiSpecificItems__c = SB_NameCard_RenkeiMapperUtil.getManagedfileName('namecard__c', 'NameCardMemo__c');
    Database.SaveResult lsr = Database.update(setting, false);
    System.assertEquals(true, lsr.isSuccess());
    System.assertEquals(0, lsr.getErrors().size());
  }

  /**
   * @description 基本設定更新 -> 指定項目:存在しない項目test
  */
  public static testMethod void updateBasicSettingSpecificItemsNoField(){
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c(RenkeiSpecificItems__c = 'Name');
    insert setting;
    setting.RenkeiSpecificItems__c = 'xx';
    Database.SaveResult lsr = Database.update(setting, false);
    System.assertEquals(false, lsr.isSuccess());
    System.assertEquals(1, lsr.getErrors().size());
    System.assertEquals(String.format(System.Label.SB_NC_SETTING_ERROR_Wrong_RenkeiSpecificItems, new String[]{'xx'}), lsr.getErrors()[0].getMessage());
  }

/******************************************* 基本設定 指定項目 End *******************************************/

/******************************************* 基本設定 キャンペーンメンバーの状況 Start *******************************************/

  /**
   * @description 基本設定新規 -> キャンペーンメンバーの状況:有効
  */
  public static testMethod void createBasicSettingCampaignStatusAC(){
    Map<String,Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    Schema.DescribeFieldResult fieldResult;
    if (schemaMap.containsKey('CampaignMember')) {
      fieldResult = schemaMap.get('CampaignMember').getDescribe().fields.getMap().get('status').getDescribe();
    } else {
      return;
    }
    String campaignStatus;
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    for (Schema.PicklistEntry f: ple) {
      if (!f.isActive()) {
        continue;
      }
      campaignStatus = f.getValue();
      break;
    }
    if (String.isBlank(campaignStatus)) {
      return;
    }
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c(RenkeiCampaignStatus__c = campaignStatus);
    Database.SaveResult lsr = Database.insert(setting, false);
    System.assertEquals(true, lsr.isSuccess());
    System.assertEquals(0, lsr.getErrors().size());
  }

  /**
   * @description 基本設定新規 -> キャンペーンメンバーの状況:無効
  */
  public static testMethod void createBasicSettingCampaignStatusUNAC(){
    Map<String,Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    Schema.DescribeFieldResult fieldResult;
    if (schemaMap.containsKey('CampaignMember')) {
      fieldResult = schemaMap.get('CampaignMember').getDescribe().fields.getMap().get('status').getDescribe();
    } else {
      return;
    }
    String campaignStatus;
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    for (Schema.PicklistEntry f: ple) {
      if (!f.isActive()) {
        campaignStatus = f.getValue();
        break;
      }
    }
    if (String.isBlank(campaignStatus)) {
      return;
    }
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c(RenkeiCampaignStatus__c = campaignStatus);
    Database.SaveResult lsr = Database.insert(setting, false);
    System.assertEquals(false, lsr.isSuccess());
    System.assertEquals(1, lsr.getErrors().size());
    System.assertEquals(String.format(System.Label.SB_NC_MAPPING_Trigger_campaignStatus_ErrorMessage,
                                              new String[]{CampaignMember.getSObjectType().getDescribe().getLabel(),
                                                           CampaignMember.Status.getDescribe().getLabel(),
                                                           campaignStatus}),
                        lsr.getErrors()[0].getMessage());
  }

  /**
   * @description 基本設定新規 -> キャンペーンメンバーの状況:無し
  */
  public static testMethod void createBasicSettingCampaignStatusNot(){
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c(RenkeiCampaignStatus__c = '');
    Database.SaveResult lsr = Database.insert(setting, false);
    System.assertEquals(true, lsr.isSuccess());
    System.assertEquals(0, lsr.getErrors().size());
  }

  /**
   * @description 基本設定新規 -> キャンペーンメンバーの状況:存在しない
  */
  public static testMethod void createBasicSettingCampaignStatusWrong(){
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c(RenkeiCampaignStatus__c = '123;321');
    Database.SaveResult lsr = Database.insert(setting, false);
    System.assertEquals(false, lsr.isSuccess());
    System.assertEquals(1, lsr.getErrors().size());
    System.assertEquals(String.format(System.Label.SB_NC_MAPPING_Trigger_campaignStatus_ErrorMessage,
                                              new String[]{CampaignMember.getSObjectType().getDescribe().getLabel(),
                                                           CampaignMember.Status.getDescribe().getLabel(),
                                                           '123;321'}),
                        lsr.getErrors()[0].getMessage());
  }

  /**
   * @description 基本設定更新 -> キャンペーンメンバーの状況:有効
  */
  public static testMethod void updateBasicSettingCampaignStatusAC(){
    Map<String,Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    Schema.DescribeFieldResult fieldResult;
    if (schemaMap.containsKey('CampaignMember')) {
      fieldResult = schemaMap.get('CampaignMember').getDescribe().fields.getMap().get('status').getDescribe();
    } else {
      return;
    }
    String campaignStatus;
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    for (Schema.PicklistEntry f: ple) {
      if (!f.isActive()) {
        continue;
      }
      campaignStatus = f.getValue();
      break;
    }
    if (String.isBlank(campaignStatus)) {
      return;
    }
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    insert setting;
    setting.RenkeiCampaignStatus__c = campaignStatus;
    Database.SaveResult lsr = Database.update(setting, false);
    System.assertEquals(true, lsr.isSuccess());
    System.assertEquals(0, lsr.getErrors().size());
  }

  /**
   * @description 基本設定更新 -> キャンペーンメンバーの状況:無効
  */
  public static testMethod void updateBasicSettingCampaignStatusUNAC(){
    Map<String,Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    Schema.DescribeFieldResult fieldResult;
    if (schemaMap.containsKey('CampaignMember')) {
      fieldResult = schemaMap.get('CampaignMember').getDescribe().fields.getMap().get('status').getDescribe();
    } else {
      return;
    }
    String campaignStatus;
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    for (Schema.PicklistEntry f: ple) {
      if (!f.isActive()) {
        campaignStatus = f.getValue();
        break;
      }
    }
    if (String.isBlank(campaignStatus)) {
      return;
    }
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    insert setting;
    setting.RenkeiCampaignStatus__c = campaignStatus;
    Database.SaveResult lsr = Database.update(setting, false);
    System.assertEquals(false, lsr.isSuccess());
    System.assertEquals(1, lsr.getErrors().size());
    System.assertEquals(String.format(System.Label.SB_NC_MAPPING_Trigger_campaignStatus_ErrorMessage,
                                              new String[]{CampaignMember.getSObjectType().getDescribe().getLabel(),
                                                           CampaignMember.Status.getDescribe().getLabel(),
                                                           campaignStatus}),
                        lsr.getErrors()[0].getMessage());
  }

  /**
   * @description 基本設定更新 -> キャンペーンメンバーの状況:無し
  */
  public static testMethod void updateBasicSettingCampaignStatusNot(){
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    insert setting;
    setting.RenkeiCampaignStatus__c = '';
    Database.SaveResult lsr = Database.update(setting, false);
    System.assertEquals(true, lsr.isSuccess());
    System.assertEquals(0, lsr.getErrors().size());
  }

  /**
   * @description 基本設定更新 -> キャンペーンメンバーの状況:存在しない
  */
  public static testMethod void updateBasicSettingCampaignStatusWrong(){
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    insert setting;
    setting.RenkeiCampaignStatus__c = '123;321';
    Database.SaveResult lsr = Database.update(setting, false);
    System.assertEquals(false, lsr.isSuccess());
    System.assertEquals(1, lsr.getErrors().size());
    System.assertEquals(String.format(System.Label.SB_NC_MAPPING_Trigger_campaignStatus_ErrorMessage,
                                              new String[]{CampaignMember.getSObjectType().getDescribe().getLabel(),
                                                           CampaignMember.Status.getDescribe().getLabel(),
                                                           '123;321'}),
                        lsr.getErrors()[0].getMessage());
  }

/******************************************* 基本設定 キャンペーンメンバーの状況 End *******************************************/

/******************************************* 基本設定 レコードタイプ Start *******************************************/

  /*------------------------------------ 基本設定 レコードタイプ(単数) Start ------------------------------------*/

  /**
   * @description 基本設定新規 -> 自動連携:取引先レコードタイプ(単数) あり(有効)
  */
  public static testMethod void createBasicSettingAccountSRCTHaveAC(){
    String recordTypeId = '';
    for (Schema.RecordTypeInfo recordTypeInfo : Account.sObjectType.getDescribe().getRecordTypeInfos()) {
      if (recordTypeInfo.isAvailable() && !recordTypeInfo.isMaster()) {
        recordTypeId = recordTypeInfo.getRecordTypeId();
        break;
      }
    }
    // 環境にはレコードタイプがないため,テストはここでやめます
    if (String.isBlank(recordTypeId)) {
      return;
    }
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c(RenkeiAccountRecordTypes__c = recordTypeId);
    Database.SaveResult lsr = Database.insert(setting, false);
    System.assertEquals(true, lsr.isSuccess());
    System.assertEquals(0, lsr.getErrors().size());
  }

  /**
   * @description 基本設定新規 -> 自動連携:取引先レコードタイプ(単数) あり(無効)
  */
  public static testMethod void createBasicSettingAccountSRCTHaveUNAC(){
    String recordTypeId = '';
    String recordTypeName = '';
    for (Schema.RecordTypeInfo recordTypeInfo : Account.sObjectType.getDescribe().getRecordTypeInfos()) {
      if (!recordTypeInfo.isAvailable() && !recordTypeInfo.isMaster()) {
        recordTypeId = recordTypeInfo.getRecordTypeId();
        recordTypeName = recordTypeInfo.Name;
        break;
      }
    }
    // 環境にはレコードタイプがないため,テストはここでやめます
    if (String.isBlank(recordTypeId)) {
      return;
    }
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c(RenkeiAccountRecordTypes__c = recordTypeId);
    Database.SaveResult lsr = Database.insert(setting, false);
    System.assertEquals(false, lsr.isSuccess());
    System.assertEquals(1, lsr.getErrors().size());
    System.assertEquals(String.format(System.Label.SB_NC_MAPPING_NoAvailableR_ErrorMessage, new String[]{Account.getSObjectType().getDescribe().getLabel(), recordTypeName}), lsr.getErrors()[0].getMessage());
  }

  /**
   * @description 基本設定新規 -> 自動連携:取引先レコードタイプ(単数) なし
  */
  public static testMethod void createBasicSettingAccountSRCTNotHave(){
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c(RenkeiAccountRecordTypes__c = '');
    Database.SaveResult lsr = Database.insert(setting, false);
    System.assertEquals(true, lsr.isSuccess());
    System.assertEquals(0, lsr.getErrors().size());
  }

  /**
   * @description 基本設定新規 -> 自動連携:取引先レコードタイプ(単数) 存在しない
  */
  public static testMethod void createBasicSettingAccountSWrongRCT(){
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c(RenkeiAccountRecordTypes__c = 'Test');
    Database.SaveResult lsr = Database.insert(setting, false);
    System.assertEquals(false, lsr.isSuccess());
    System.assertEquals(1, lsr.getErrors().size());
    System.assertEquals(String.format(System.Label.SB_NC_MAPPING_NoObject_ErrorMessage, new String[]{Account.getSObjectType().getDescribe().getLabel(), 'Test'}), lsr.getErrors()[0].getMessage());
  }

  /**
   * @description 基本設定新規 -> 自動連携:取引先責任者レコードタイプ(単数) あり(有効)
  */
  public static testMethod void createBasicSettingContactSRCTHaveAC(){
    String recordTypeId = '';
    for (Schema.RecordTypeInfo recordTypeInfo : Contact.sObjectType.getDescribe().getRecordTypeInfos()) {
      if (recordTypeInfo.isAvailable() && !recordTypeInfo.isMaster()) {
        recordTypeId = recordTypeInfo.getRecordTypeId();
        break;
      }
    }
    // 環境にはレコードタイプがないため,テストはここでやめます
    if (String.isBlank(recordTypeId)) {
      return;
    }
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c(RenkeiContactRecordTypes__c = recordTypeId);
    Database.SaveResult lsr = Database.insert(setting, false);
    System.assertEquals(true, lsr.isSuccess());
    System.assertEquals(0, lsr.getErrors().size());
  }

  /**
   * @description 基本設定新規 -> 自動連携:取引先責任者レコードタイプ(単数) あり(無効)
  */
  public static testMethod void createBasicSettingContactSRCTHaveUNAC(){
    String recordTypeId = '';
    String recordTypeName = '';
    for (Schema.RecordTypeInfo recordTypeInfo : Contact.sObjectType.getDescribe().getRecordTypeInfos()) {
      if (!recordTypeInfo.isAvailable() && !recordTypeInfo.isMaster()) {
        recordTypeId = recordTypeInfo.getRecordTypeId();
        recordTypeName = recordTypeInfo.Name;
        break;
      }
    }
    // 環境にはレコードタイプがないため,テストはここでやめます
    if (String.isBlank(recordTypeId)) {
      return;
    }
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c(RenkeiContactRecordTypes__c = recordTypeId);
    Database.SaveResult lsr = Database.insert(setting, false);
    System.assertEquals(false, lsr.isSuccess());
    System.assertEquals(1, lsr.getErrors().size());
    System.assertEquals(String.format(System.Label.SB_NC_MAPPING_NoAvailableR_ErrorMessage, new String[]{Contact.getSObjectType().getDescribe().getLabel(), recordTypeName}), lsr.getErrors()[0].getMessage());
  }

  /**
   * @description 基本設定新規 -> 自動連携:取引先責任者レコードタイプ(単数) なし
  */
  public static testMethod void createBasicSettingContactSRCTNotHave(){
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c(RenkeiContactRecordTypes__c = '');
    Database.SaveResult lsr = Database.insert(setting, false);
    System.assertEquals(true, lsr.isSuccess());
    System.assertEquals(0, lsr.getErrors().size());
  }

  /**
   * @description 基本設定新規 -> 自動連携:取引先責任者レコードタイプ(単数) 存在しない
  */
  public static testMethod void createBasicSettingContactSWrongRCT(){
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c(RenkeiContactRecordTypes__c = 'Test');
    Database.SaveResult lsr = Database.insert(setting, false);
    System.assertEquals(false, lsr.isSuccess());
    System.assertEquals(1, lsr.getErrors().size());
    System.assertEquals(String.format(System.Label.SB_NC_MAPPING_NoObject_ErrorMessage, new String[]{Contact.getSObjectType().getDescribe().getLabel(), 'Test'}), lsr.getErrors()[0].getMessage());
  }

  /**
   * @description 基本設定新規 -> 自動連携:リードレコードタイプ(単数) あり(有効)
  */
  public static testMethod void createBasicSettingLeadSRCTHaveAC(){
    String recordTypeId = '';
    for (Schema.RecordTypeInfo recordTypeInfo : Lead.sObjectType.getDescribe().getRecordTypeInfos()) {
      if (recordTypeInfo.isAvailable() && !recordTypeInfo.isMaster()) {
        recordTypeId = recordTypeInfo.getRecordTypeId();
        break;
      }
    }
    // 環境にはレコードタイプがないため,テストはここでやめます
    if (String.isBlank(recordTypeId)) {
      return;
    }
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c(RenkeiLeadRecordTypes__c = recordTypeId);
    Database.SaveResult lsr = Database.insert(setting, false);
    System.assertEquals(true, lsr.isSuccess());
    System.assertEquals(0, lsr.getErrors().size());
  }

  /**
   * @description 基本設定新規 -> 自動連携:リードレコードタイプ(単数) あり(無効)
  */
  public static testMethod void createBasicSettingLeadSRCTHaveUNAC(){
    String recordTypeId = '';
    for (Schema.RecordTypeInfo recordTypeInfo : Lead.sObjectType.getDescribe().getRecordTypeInfos()) {
      if (!recordTypeInfo.isAvailable() && !recordTypeInfo.isMaster()) {
        recordTypeId = recordTypeInfo.getRecordTypeId();
        break;
      }
    }
    // 環境にはレコードタイプがないため,テストはここでやめます
    if (String.isBlank(recordTypeId)) {
      return;
    }
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c(RenkeiLeadRecordTypes__c = recordTypeId);
    Database.SaveResult lsr = Database.insert(setting, false);
    System.assertEquals(false, lsr.isSuccess());
    System.assertEquals(1, lsr.getErrors().size());
    System.assertEquals(String.format(System.Label.SB_NC_MAPPING_NoAvailableR_ErrorMessage, new String[]{Lead.getSObjectType().getDescribe().getLabel(), recordTypeId}), lsr.getErrors()[0].getMessage());
  }

  /**
   * @description 基本設定新規 -> 自動連携:リードレコードタイプ(単数) なし
  */
  public static testMethod void createBasicSettingLeadSRCTNotHave(){
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c(RenkeiLeadRecordTypes__c = '');
    Database.SaveResult lsr = Database.insert(setting, false);
    System.assertEquals(true, lsr.isSuccess());
    System.assertEquals(0, lsr.getErrors().size());
  }

  /**
   * @description 基本設定新規 -> 自動連携:リードレコードタイプ(単数) 存在しない
  */
  public static testMethod void createBasicSettingLeadSWrongRCT(){
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c(RenkeiLeadRecordTypes__c = 'Test');
    Database.SaveResult lsr = Database.insert(setting, false);
    System.assertEquals(false, lsr.isSuccess());
    System.assertEquals(1, lsr.getErrors().size());
    System.assertEquals(String.format(System.Label.SB_NC_MAPPING_NoObject_ErrorMessage, new String[]{Lead.getSObjectType().getDescribe().getLabel(), 'Test'}), lsr.getErrors()[0].getMessage());
  }


  /**
   * @description 基本設定更新 -> 自動連携:取引先レコードタイプ(単数) あり(有効)
  */
  public static testMethod void updateBasicSettingAccountSRCTHaveAC(){
    String recordTypeId = '';
    for (Schema.RecordTypeInfo recordTypeInfo : Account.sObjectType.getDescribe().getRecordTypeInfos()) {
      if (recordTypeInfo.isAvailable() && !recordTypeInfo.isMaster()) {
        recordTypeId = recordTypeInfo.getRecordTypeId();
        break;
      }
    }
    // 環境にはレコードタイプがないため,テストはここでやめます
    if (String.isBlank(recordTypeId)) {
      return;
    }
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    insert setting;
    setting.RenkeiAccountRecordTypes__c = recordTypeId;
    Database.SaveResult lsr = Database.update(setting, false);
    System.assertEquals(true, lsr.isSuccess());
    System.assertEquals(0, lsr.getErrors().size());
  }

  /**
   * @description 基本設定更新 -> 自動連携:取引先レコードタイプ(単数) あり(無効)
  */
  public static testMethod void updateBasicSettingAccountSRCTHaveUNAC(){
    String recordTypeId = '';
    String recordTypeName = '';
    for (Schema.RecordTypeInfo recordTypeInfo : Account.sObjectType.getDescribe().getRecordTypeInfos()) {
      if (!recordTypeInfo.isAvailable() && !recordTypeInfo.isMaster()) {
        recordTypeId = recordTypeInfo.getRecordTypeId();
        recordTypeName = recordTypeInfo.Name;
        break;
      }
    }
    // 環境にはレコードタイプがないため,テストはここでやめます
    if (String.isBlank(recordTypeId)) {
      return;
    }
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    insert setting;
    setting.RenkeiAccountRecordTypes__c = recordTypeId;
    Database.SaveResult lsr = Database.update(setting, false);
    System.assertEquals(false, lsr.isSuccess());
    System.assertEquals(1, lsr.getErrors().size());
    System.assertEquals(String.format(System.Label.SB_NC_MAPPING_NoAvailableR_ErrorMessage, new String[]{Account.getSObjectType().getDescribe().getLabel(), recordTypeName}), lsr.getErrors()[0].getMessage());
  }

  /**
   * @description 基本設定更新 -> 自動連携:取引先レコードタイプ(単数) なし
  */
  public static testMethod void updateBasicSettingAccountSRCTNotHave(){
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    insert setting;
    setting.RenkeiAccountRecordTypes__c = '';
    Database.SaveResult lsr = Database.update(setting, false);
    System.assertEquals(true, lsr.isSuccess());
    System.assertEquals(0, lsr.getErrors().size());
  }

  /**
   * @description 基本設定更新 -> 自動連携:取引先レコードタイプ(単数) 存在しない
  */
  public static testMethod void updateBasicSettingAccountSWrongRCT(){
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    insert setting;
    setting.RenkeiAccountRecordTypes__c = 'Test';
    Database.SaveResult lsr = Database.update(setting, false);
    System.assertEquals(false, lsr.isSuccess());
    System.assertEquals(1, lsr.getErrors().size());
    System.assertEquals(String.format(System.Label.SB_NC_MAPPING_NoObject_ErrorMessage, new String[]{Account.getSObjectType().getDescribe().getLabel(), 'Test'}), lsr.getErrors()[0].getMessage());
  }

  /**
   * @description 基本設定更新 -> 自動連携:取引先責任者レコードタイプ(単数) あり(有効)
  */
  public static testMethod void updateBasicSettingContactSRCTHaveAC(){
    String recordTypeId = '';
    for (Schema.RecordTypeInfo recordTypeInfo : Contact.sObjectType.getDescribe().getRecordTypeInfos()) {
      if (recordTypeInfo.isAvailable() && !recordTypeInfo.isMaster()) {
        recordTypeId = recordTypeInfo.getRecordTypeId();
        break;
      }
    }
    // 環境にはレコードタイプがないため,テストはここでやめます
    if (String.isBlank(recordTypeId)) {
      return;
    }
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    insert setting;
    setting.RenkeiContactRecordTypes__c = recordTypeId;
    Database.SaveResult lsr = Database.update(setting, false);
    System.assertEquals(true, lsr.isSuccess());
    System.assertEquals(0, lsr.getErrors().size());
  }

  /**
   * @description 基本設定更新 -> 自動連携:取引先責任者レコードタイプ(単数) あり(無効)
  */
  public static testMethod void updateBasicSettingContactSRCTHaveUNAC(){
    String recordTypeId = '';
    String recordTypeName = '';
    for (Schema.RecordTypeInfo recordTypeInfo : Contact.sObjectType.getDescribe().getRecordTypeInfos()) {
      if (!recordTypeInfo.isAvailable() && !recordTypeInfo.isMaster()) {
        recordTypeId = recordTypeInfo.getRecordTypeId();
        recordTypeName = recordTypeInfo.Name;
        break;
      }
    }
    // 環境にはレコードタイプがないため,テストはここでやめます
    if (String.isBlank(recordTypeId)) {
      return;
    }
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    insert setting;
    setting.RenkeiContactRecordTypes__c = recordTypeId;
    Database.SaveResult lsr = Database.update(setting, false);
    System.assertEquals(false, lsr.isSuccess());
    System.assertEquals(1, lsr.getErrors().size());
    System.assertEquals(String.format(System.Label.SB_NC_MAPPING_NoAvailableR_ErrorMessage, new String[]{Contact.getSObjectType().getDescribe().getLabel(), recordTypeName}), lsr.getErrors()[0].getMessage());
  }

  /**
   * @description 基本設定更新 -> 自動連携:取引先責任者レコードタイプ(単数) なし
  */
  public static testMethod void updateBasicSettingContactSRCTNotHave(){
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    insert setting;
    setting.RenkeiContactRecordTypes__c = '';
    Database.SaveResult lsr = Database.update(setting, false);
    System.assertEquals(true, lsr.isSuccess());
    System.assertEquals(0, lsr.getErrors().size());
  }

  /**
   * @description 基本設定更新 -> 自動連携:取引先責任者レコードタイプ(単数) 存在しない
  */
  public static testMethod void updateBasicSettingContactSWrongRCT(){
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    insert setting;
    setting.RenkeiContactRecordTypes__c = 'Test';
    Database.SaveResult lsr = Database.update(setting, false);
    System.assertEquals(false, lsr.isSuccess());
    System.assertEquals(1, lsr.getErrors().size());
    System.assertEquals(String.format(System.Label.SB_NC_MAPPING_NoObject_ErrorMessage, new String[]{Contact.getSObjectType().getDescribe().getLabel(), 'Test'}), lsr.getErrors()[0].getMessage());
  }

  /**
   * @description 基本設定更新 -> 自動連携:取引先責任者レコードタイプ(単数) あり(有効)
  */
  public static testMethod void updateBasicSettingLeadSRCTHaveAC(){
    String recordTypeId = '';
    for (Schema.RecordTypeInfo recordTypeInfo : Lead.sObjectType.getDescribe().getRecordTypeInfos()) {
      if (recordTypeInfo.isAvailable() && !recordTypeInfo.isMaster()) {
        recordTypeId = recordTypeInfo.getRecordTypeId();
        break;
      }
    }
    // 環境にはレコードタイプがないため,テストはここでやめます
    if (String.isBlank(recordTypeId)) {
      return;
    }
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    insert setting;
    setting.RenkeiLeadRecordTypes__c = recordTypeId;
    Database.SaveResult lsr = Database.update(setting, false);
    System.assertEquals(true, lsr.isSuccess());
    System.assertEquals(0, lsr.getErrors().size());
  }

  /**
   * @description 基本設定更新 -> 自動連携:取引先責任者レコードタイプ(単数) あり(無効)
  */
  public static testMethod void updateBasicSettingLeadSRCTHaveUNAC(){
    String recordTypeId = '';
    for (Schema.RecordTypeInfo recordTypeInfo : Lead.sObjectType.getDescribe().getRecordTypeInfos()) {
      if (!recordTypeInfo.isAvailable() && !recordTypeInfo.isMaster()) {
        recordTypeId = recordTypeInfo.getRecordTypeId();
        break;
      }
    }
    // 環境にはレコードタイプがないため,テストはここでやめます
    if (String.isBlank(recordTypeId)) {
      return;
    }
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    insert setting;
    setting.RenkeiLeadRecordTypes__c = recordTypeId;
    Database.SaveResult lsr = Database.update(setting, false);
    System.assertEquals(false, lsr.isSuccess());
    System.assertEquals(1, lsr.getErrors().size());
    System.assertEquals(String.format(System.Label.SB_NC_MAPPING_NoAvailableR_ErrorMessage, new String[]{Lead.getSObjectType().getDescribe().getLabel(), recordTypeId}), lsr.getErrors()[0].getMessage());
  }

  /**
   * @description 基本設定更新 -> 自動連携:取引先責任者レコードタイプ(単数) なし
  */
  public static testMethod void updateBasicSettingLeadSRCTNotHave(){
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    insert setting;
    setting.RenkeiLeadRecordTypes__c = '';
    Database.SaveResult lsr = Database.update(setting, false);
    System.assertEquals(true, lsr.isSuccess());
    System.assertEquals(0, lsr.getErrors().size());
  }

  /**
   * @description 基本設定更新 -> 自動連携:取引先責任者レコードタイプ(単数) 存在しない
  */
  public static testMethod void updateBasicSettingLeadSWrongRCT(){
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    insert setting;
    setting.RenkeiLeadRecordTypes__c = 'Test';
    Database.SaveResult lsr = Database.update(setting, false);
    System.assertEquals(false, lsr.isSuccess());
    System.assertEquals(1, lsr.getErrors().size());
    System.assertEquals(String.format(System.Label.SB_NC_MAPPING_NoObject_ErrorMessage, new String[]{Lead.getSObjectType().getDescribe().getLabel(), 'Test'}), lsr.getErrors()[0].getMessage());
  }

  /*------------------------------------ 基本設定 レコードタイプ(単数) End ------------------------------------*/

  /*------------------------------------ 基本設定 レコードタイプ(複数) Start ------------------------------------*/

  /**
   * @description 基本設定新規 -> 自動連携:取引先レコードタイプ(複数) あり(有効)
  */
  public static testMethod void createBasicSettingAccountPRCTHaveAC(){
    String recordTypeId = '';
    for (Schema.RecordTypeInfo recordTypeInfo : Account.sObjectType.getDescribe().getRecordTypeInfos()) {
      if (recordTypeInfo.isAvailable() && !recordTypeInfo.isMaster()) {
        if (String.isBlank(recordTypeId)) {
          recordTypeId = recordTypeInfo.getRecordTypeId();
        } else {
          recordTypeId += ';' + recordTypeInfo.getRecordTypeId();
        }
      }
    }
    // 環境にはレコードタイプがないため,テストはここでやめます
    if (String.isBlank(recordTypeId)) {
      return;
    }
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c(RenkeiAccountQueryRecordTypeIds__c = recordTypeId);
    Database.SaveResult lsr = Database.insert(setting, false);
    System.assertEquals(true, lsr.isSuccess());
    System.assertEquals(0, lsr.getErrors().size());
  }

  /**
   * @description 基本設定新規 -> 自動連携:取引先レコードタイプ(複数) あり(無効)
  */
  public static testMethod void createBasicSettingAccountPRCTHaveUNAC(){
    String recordTypeIds = '';
    String recordTypeName = '';
    for (Schema.RecordTypeInfo recordTypeInfo : Account.sObjectType.getDescribe().getRecordTypeInfos()) {
      if (!recordTypeInfo.isAvailable() && !recordTypeInfo.isMaster()) {
        if (String.isBlank(recordTypeIds)) {
          recordTypeIds = recordTypeInfo.getRecordTypeId();
        } else {
          recordTypeIds += ';' + recordTypeInfo.getRecordTypeId();
        }
        recordTypeName = recordTypeInfo.Name;
      }
    }
    // 環境にはレコードタイプがないため,テストはここでやめます
    if (String.isBlank(recordTypeIds)) {
      return;
    }
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c(RenkeiAccountQueryRecordTypeIds__c = recordTypeIds);
    Database.SaveResult lsr = Database.insert(setting, false);
    System.assertEquals(false, lsr.isSuccess());
    System.assertEquals(1, lsr.getErrors().size());
    System.assertEquals(String.format(System.Label.SB_NC_MAPPING_NoAvailableR_ErrorMessage, new String[]{Account.getSObjectType().getDescribe().getLabel(), recordTypeName}), lsr.getErrors()[0].getMessage());
  }

  /**
   * @description 基本設定新規 -> 自動連携:取引先レコードタイプ(複数) 無し
  */
  public static testMethod void createBasicSettingAccountPRCTNotHave(){
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c(RenkeiAccountQueryRecordTypeIds__c = '');
    Database.SaveResult lsr = Database.insert(setting, false);
    System.assertEquals(true, lsr.isSuccess());
    System.assertEquals(0, lsr.getErrors().size());
  }

  /**
   * @description 基本設定新規 -> 自動連携:取引先レコードタイプ(複数) 存在しない
  */
  public static testMethod void createBasicSettingAccountPRCTWrongHave(){
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c(RenkeiAccountQueryRecordTypeIds__c = 'Test1;Test2');
    Database.SaveResult lsr = Database.insert(setting, false);
    System.assertEquals(false, lsr.isSuccess());
    System.assertEquals(1, lsr.getErrors().size());
    System.assertEquals(String.format(System.Label.SB_NC_MAPPING_NoObject_ErrorMessage, new String[]{Account.getSObjectType().getDescribe().getLabel(), 'Test2'}), lsr.getErrors()[0].getMessage());
  }

  /**
   * @description 基本設定新規 -> 自動連携:取引先責任者レコードタイプ(複数) あり(有効)
  */
  public static testMethod void createBasicSettingContactPRCTHaveAC(){
    String recordTypeIds = '';
    for (Schema.RecordTypeInfo recordTypeInfo : Contact.sObjectType.getDescribe().getRecordTypeInfos()) {
      if (recordTypeInfo.isAvailable() && !recordTypeInfo.isMaster()) {
        if (String.isBlank(recordTypeIds)) {
          recordTypeIds = recordTypeInfo.getRecordTypeId();
        } else {
          recordTypeIds += ';' + recordTypeInfo.getRecordTypeId();
        }
      }
    }
    // 環境にはレコードタイプがないため,テストはここでやめます
    if (String.isBlank(recordTypeIds)) {
      return;
    }
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c(RenkeiContactQueryRecordTypeIds__c = recordTypeIds);
    Database.SaveResult lsr = Database.insert(setting, false);
    System.assertEquals(true, lsr.isSuccess());
    System.assertEquals(0, lsr.getErrors().size());
  }

  /**
   * @description 基本設定新規 -> 自動連携:取引先責任者レコードタイプ(複数) あり(無効)
  */
  public static testMethod void createBasicSettingContactPRCTHaveUNAC(){
    String recordTypeIds = '';
    String recordTypeName = '';
    for (Schema.RecordTypeInfo recordTypeInfo : Contact.sObjectType.getDescribe().getRecordTypeInfos()) {
      if (!recordTypeInfo.isAvailable() && !recordTypeInfo.isMaster()) {
        if (String.isBlank(recordTypeIds)) {
          recordTypeIds = recordTypeInfo.getRecordTypeId();
        } else {
          recordTypeIds += ';' + recordTypeInfo.getRecordTypeId();
        }
        recordTypeName = recordTypeInfo.Name;
      }
    }
    // 環境にはレコードタイプがないため,テストはここでやめます
    if (String.isBlank(recordTypeIds)) {
      return;
    }
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c(RenkeiContactQueryRecordTypeIds__c = recordTypeIds);
    Database.SaveResult lsr = Database.insert(setting, false);
    System.assertEquals(false, lsr.isSuccess());
    System.assertEquals(1, lsr.getErrors().size());
    System.assertEquals(String.format(System.Label.SB_NC_MAPPING_NoAvailableR_ErrorMessage, new String[]{Contact.getSObjectType().getDescribe().getLabel(), recordTypeName}), lsr.getErrors()[0].getMessage());
  }

  /**
   * @description 基本設定新規 -> 自動連携:取引先責任者レコードタイプ(複数) 無し
  */
  public static testMethod void createBasicSettingContactPRCTNotHave(){
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c(RenkeiContactQueryRecordTypeIds__c = '');
    Database.SaveResult lsr = Database.insert(setting, false);
    System.assertEquals(true, lsr.isSuccess());
    System.assertEquals(0, lsr.getErrors().size());
  }

  /**
   * @description 基本設定新規 -> 自動連携:取引先責任者レコードタイプ(複数) 存在しない
  */
  public static testMethod void createBasicSettingContactPRCTWrongHave(){
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c(RenkeiContactQueryRecordTypeIds__c = 'Test1;Test2');
    Database.SaveResult lsr = Database.insert(setting, false);
    System.assertEquals(false, lsr.isSuccess());
    System.assertEquals(1, lsr.getErrors().size());
    System.assertEquals(String.format(System.Label.SB_NC_MAPPING_NoObject_ErrorMessage, new String[]{Contact.getSObjectType().getDescribe().getLabel(), 'Test2'}), lsr.getErrors()[0].getMessage());
  }

  /**
   * @description 基本設定新規 -> 自動連携:リードレコードタイプ(複数) あり(有効)
  */
  public static testMethod void createBasicSettingLeadPRCTHaveAC(){
    String recordTypeId = '';
    for (Schema.RecordTypeInfo recordTypeInfo : Lead.sObjectType.getDescribe().getRecordTypeInfos()) {
      if (recordTypeInfo.isAvailable() && !recordTypeInfo.isMaster()) {
        if (String.isBlank(recordTypeId)) {
          recordTypeId = recordTypeInfo.getRecordTypeId();
        } else {
          recordTypeId += ';' + recordTypeInfo.getRecordTypeId();
        }
      }
    }
    // 環境にはレコードタイプがないため,テストはここでやめます
    if (String.isBlank(recordTypeId)) {
      return;
    }
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c(RenkeiLeadQueryRecordTypeIds__c = recordTypeId);
    Database.SaveResult lsr = Database.insert(setting, false);
    System.assertEquals(true, lsr.isSuccess());
    System.assertEquals(0, lsr.getErrors().size());
  }

  /**
   * @description 基本設定新規 -> 自動連携:リードレコードタイプ(複数) あり(無効)
  */
  public static testMethod void createBasicSettingLeadPRCTHaveUNAC(){
    String recordTypeIds = '';
    for (Schema.RecordTypeInfo recordTypeInfo : Lead.sObjectType.getDescribe().getRecordTypeInfos()) {
      if (!recordTypeInfo.isAvailable() && !recordTypeInfo.isMaster()) {
        if (String.isBlank(recordTypeIds)) {
          recordTypeIds = recordTypeInfo.getRecordTypeId();
        } else {
          recordTypeIds += ';' + recordTypeInfo.getRecordTypeId();
        }
      }
    }
    // 環境にはレコードタイプがないため,テストはここでやめます
    if (String.isBlank(recordTypeIds)) {
      return;
    }
    String [] recordTypeIdList = recordTypeIds.split(';');
    String recordTypeId = recordTypeIdList[recordTypeIdList.size()-1];
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c(RenkeiLeadQueryRecordTypeIds__c = recordTypeIds);
    Database.SaveResult lsr = Database.insert(setting, false);
    System.assertEquals(false, lsr.isSuccess());
    System.assertEquals(1, lsr.getErrors().size());
    System.assertEquals(String.format(System.Label.SB_NC_MAPPING_NoAvailableR_ErrorMessage, new String[]{Lead.getSObjectType().getDescribe().getLabel(), recordTypeId}), lsr.getErrors()[0].getMessage());
  }

  /**
   * @description 基本設定新規 -> 自動連携:リードレコードタイプ(複数) 無し
  */
  public static testMethod void createBasicSettingLeadPRCTNotHave(){
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c(RenkeiLeadQueryRecordTypeIds__c = '');
    Database.SaveResult lsr = Database.insert(setting, false);
    System.assertEquals(true, lsr.isSuccess());
    System.assertEquals(0, lsr.getErrors().size());
  }

  /**
   * @description 基本設定新規 -> 自動連携:リードレコードタイプ(複数) 存在しない
  */
  public static testMethod void createBasicSettingLeadPRCTWrongHave(){
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c(RenkeiLeadQueryRecordTypeIds__c = 'Test1;Test2');
    Database.SaveResult lsr = Database.insert(setting, false);
    System.assertEquals(false, lsr.isSuccess());
    System.assertEquals(1, lsr.getErrors().size());
    System.assertEquals(String.format(System.Label.SB_NC_MAPPING_NoObject_ErrorMessage, new String[]{Lead.getSObjectType().getDescribe().getLabel(), 'Test2'}), lsr.getErrors()[0].getMessage());
  }

  /**
   * @description 基本設定新規 -> 自動連携:取引先レコードタイプ(複数) あり(有効)
  */
  public static testMethod void updateBasicSettingAccountPRCTHaveAC(){
    String recordTypeId = '';
    for (Schema.RecordTypeInfo recordTypeInfo : Account.sObjectType.getDescribe().getRecordTypeInfos()) {
      if (recordTypeInfo.isAvailable() && !recordTypeInfo.isMaster()) {
        if (String.isBlank(recordTypeId)) {
          recordTypeId = recordTypeInfo.getRecordTypeId();
        } else {
          recordTypeId += ';' + recordTypeInfo.getRecordTypeId();
        }
      }
    }
    // 環境にはレコードタイプがないため,テストはここでやめます
    if (String.isBlank(recordTypeId)) {
      return;
    }
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    insert setting;
    setting.RenkeiAccountQueryRecordTypeIds__c = recordTypeId;
    Database.SaveResult lsr = Database.update(setting, false);
    System.assertEquals(true, lsr.isSuccess());
    System.assertEquals(0, lsr.getErrors().size());
  }

  /**
   * @description 基本設定更新 -> 自動連携:取引先レコードタイプ(複数) あり(無効)
  */
  public static testMethod void updateBasicSettingAccountPRCTHaveUNAC(){
    String recordTypeIds = '';
    String recordTypeName = '';
    for (Schema.RecordTypeInfo recordTypeInfo : Account.sObjectType.getDescribe().getRecordTypeInfos()) {
      if (!recordTypeInfo.isAvailable() && !recordTypeInfo.isMaster()) {
        if (String.isBlank(recordTypeIds)) {
          recordTypeIds = recordTypeInfo.getRecordTypeId();
        } else {
          recordTypeIds += ';' + recordTypeInfo.getRecordTypeId();
        }
        recordTypeName = recordTypeInfo.Name;
      }
    }
    // 環境にはレコードタイプがないため,テストはここでやめます
    if (String.isBlank(recordTypeIds)) {
      return;
    }
    String [] recordTypeIdList = recordTypeIds.split(';');
    String recordTypeId = recordTypeIdList[recordTypeIdList.size()-1];
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    insert setting;
    setting.RenkeiAccountQueryRecordTypeIds__c = recordTypeIds;
    Database.SaveResult lsr = Database.update(setting, false);
    System.assertEquals(false, lsr.isSuccess());
    System.assertEquals(1, lsr.getErrors().size());
    System.assertEquals(String.format(System.Label.SB_NC_MAPPING_NoAvailableR_ErrorMessage, new String[]{Account.getSObjectType().getDescribe().getLabel(), recordTypeName}), lsr.getErrors()[0].getMessage());
  }

  /**
   * @description 基本設定更新 -> 自動連携:取引先レコードタイプ(複数) 無し
  */
  public static testMethod void updateBasicSettingAccountPRCTNotHave(){
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    insert setting;
    setting.RenkeiAccountQueryRecordTypeIds__c = '';
    Database.SaveResult lsr = Database.update(setting, false);
    System.assertEquals(true, lsr.isSuccess());
    System.assertEquals(0, lsr.getErrors().size());
  }

  /**
   * @description 基本設定更新 -> 自動連携:取引先レコードタイプ(複数) 存在しない
  */
  public static testMethod void updateBasicSettingAccountPRCTWrongHave(){
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    insert setting;
    setting.RenkeiAccountQueryRecordTypeIds__c = 'Test1;Test2';
    Database.SaveResult lsr = Database.update(setting, false);
    System.assertEquals(false, lsr.isSuccess());
    System.assertEquals(1, lsr.getErrors().size());
    System.assertEquals(String.format(System.Label.SB_NC_MAPPING_NoObject_ErrorMessage, new String[]{Account.getSObjectType().getDescribe().getLabel(), 'Test2'}), lsr.getErrors()[0].getMessage());
  }

  /**
   * @description 基本設定更新 -> 自動連携:取引先責任者レコードタイプ(複数) あり(有効)
  */
  public static testMethod void updateBasicSettingContactPRCTHaveAC(){
    String recordTypeIds = '';
    for (Schema.RecordTypeInfo recordTypeInfo : Contact.sObjectType.getDescribe().getRecordTypeInfos()) {
      if (recordTypeInfo.isAvailable() && !recordTypeInfo.isMaster()) {
        if (String.isBlank(recordTypeIds)) {
          recordTypeIds = recordTypeInfo.getRecordTypeId();
        } else {
          recordTypeIds += ';' + recordTypeInfo.getRecordTypeId();
        }
      }
    }
    // 環境にはレコードタイプがないため,テストはここでやめます
    if (String.isBlank(recordTypeIds)) {
      return;
    }
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    insert setting;
    setting.RenkeiContactQueryRecordTypeIds__c = recordTypeIds;
    Database.SaveResult lsr = Database.update(setting, false);
    System.assertEquals(true, lsr.isSuccess());
    System.assertEquals(0, lsr.getErrors().size());
  }

  /**
   * @description 基本設定更新 -> 自動連携:取引先責任者レコードタイプ(複数) あり(無効)
  */
  public static testMethod void updateBasicSettingContactPRCTHaveUNAC(){
    String recordTypeIds = '';
    String recordTypeName = '';
    for (Schema.RecordTypeInfo recordTypeInfo : Contact.sObjectType.getDescribe().getRecordTypeInfos()) {
      if (!recordTypeInfo.isAvailable() && !recordTypeInfo.isMaster()) {
        if (String.isBlank(recordTypeIds)) {
          recordTypeIds = recordTypeInfo.getRecordTypeId();
        } else {
          recordTypeIds += ';' + recordTypeInfo.getRecordTypeId();
        }
        recordTypeName = recordTypeInfo.Name;
      }
    }
    // 環境にはレコードタイプがないため,テストはここでやめます
    if (String.isBlank(recordTypeIds)) {
      return;
    }
    String [] recordTypeIdList = recordTypeIds.split(';');
    String recordTypeId = recordTypeIdList[recordTypeIdList.size()-1];
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    insert setting;
    setting.RenkeiContactQueryRecordTypeIds__c = recordTypeIds;
    Database.SaveResult lsr = Database.update(setting, false);
    System.assertEquals(false, lsr.isSuccess());
    System.assertEquals(1, lsr.getErrors().size());
    System.assertEquals(String.format(System.Label.SB_NC_MAPPING_NoAvailableR_ErrorMessage, new String[]{Contact.getSObjectType().getDescribe().getLabel(), recordTypeName}), lsr.getErrors()[0].getMessage());
  }

  /**
   * @description 基本設定更新 -> 自動連携:取引先責任者レコードタイプ(複数) 無し
  */
  public static testMethod void updateBasicSettingContactPRCTNotHave(){
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    insert setting;
    setting.RenkeiContactQueryRecordTypeIds__c = '';
    Database.SaveResult lsr = Database.update(setting, false);
    System.assertEquals(true, lsr.isSuccess());
    System.assertEquals(0, lsr.getErrors().size());
  }

  /**
   * @description 基本設定更新 -> 自動連携:取引先責任者レコードタイプ(複数) 存在しない
  */
  public static testMethod void updateBasicSettingContactPRCTWrongHave(){
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    insert setting;
    setting.RenkeiContactQueryRecordTypeIds__c = 'Test1;Test2';
    Database.SaveResult lsr = Database.update(setting, false);
    System.assertEquals(false, lsr.isSuccess());
    System.assertEquals(1, lsr.getErrors().size());
    System.assertEquals(String.format(System.Label.SB_NC_MAPPING_NoObject_ErrorMessage, new String[]{Contact.getSObjectType().getDescribe().getLabel(), 'Test2'}), lsr.getErrors()[0].getMessage());
  }

  /**
   * @description 基本設定更新 -> 自動連携:リードレコードタイプ(複数) あり(有効)
  */
  public static testMethod void updateBasicSettingLeadPRCTHaveAC(){
    String recordTypeId = '';
    for (Schema.RecordTypeInfo recordTypeInfo : Lead.sObjectType.getDescribe().getRecordTypeInfos()) {
      if (recordTypeInfo.isAvailable() && !recordTypeInfo.isMaster()) {
        if (String.isBlank(recordTypeId)) {
          recordTypeId = recordTypeInfo.getRecordTypeId();
        } else {
          recordTypeId += ';' + recordTypeInfo.getRecordTypeId();
        }
      }
    }
    // 環境にはレコードタイプがないため,テストはここでやめます
    if (String.isBlank(recordTypeId)) {
      return;
    }
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    insert setting;
    setting.RenkeiLeadQueryRecordTypeIds__c = recordTypeId;
    Database.SaveResult lsr = Database.update(setting, false);
    System.assertEquals(true, lsr.isSuccess());
    System.assertEquals(0, lsr.getErrors().size());
  }

  /**
   * @description 基本設定更新 -> 自動連携:リードレコードタイプ(複数) あり(無効)
  */
  public static testMethod void updateBasicSettingLeadPRCTHaveUNAC(){
    String recordTypeIds = '';
    for (Schema.RecordTypeInfo recordTypeInfo : Lead.sObjectType.getDescribe().getRecordTypeInfos()) {
      if (!recordTypeInfo.isAvailable() && !recordTypeInfo.isMaster()) {
        if (String.isBlank(recordTypeIds)) {
          recordTypeIds = recordTypeInfo.getRecordTypeId();
        } else {
          recordTypeIds += ';' + recordTypeInfo.getRecordTypeId();
        }
      }
    }
    // 環境にはレコードタイプがないため,テストはここでやめます
    if (String.isBlank(recordTypeIds)) {
      return;
    }
    String [] recordTypeIdList = recordTypeIds.split(';');
    String recordTypeId = recordTypeIdList[recordTypeIdList.size()-1];
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    insert setting;
    setting.RenkeiLeadQueryRecordTypeIds__c = recordTypeIds;
    Database.SaveResult lsr = Database.update(setting, false);
    System.assertEquals(false, lsr.isSuccess());
    System.assertEquals(1, lsr.getErrors().size());
    System.assertEquals(String.format(System.Label.SB_NC_MAPPING_NoAvailableR_ErrorMessage, new String[]{Lead.getSObjectType().getDescribe().getLabel(), recordTypeId}), lsr.getErrors()[0].getMessage());
  }

  /**
   * @description 基本設定更新 -> 自動連携:リードレコードタイプ(複数) 無し
  */
  public static testMethod void updateBasicSettingLeadPRCTNotHave(){
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    insert setting;
    setting.RenkeiLeadQueryRecordTypeIds__c = '';
    Database.SaveResult lsr = Database.update(setting, false);
    System.assertEquals(true, lsr.isSuccess());
    System.assertEquals(0, lsr.getErrors().size());
  }

  /**
   * @description 基本設定更新 -> 自動連携:リードレコードタイプ(複数) 存在しない
  */
  public static testMethod void updateBasicSettingLeadPRCTWrongHave(){
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    insert setting;
    setting.RenkeiLeadQueryRecordTypeIds__c = 'Test1;Test2';
    Database.SaveResult lsr = Database.update(setting, false);
    System.assertEquals(false, lsr.isSuccess());
    System.assertEquals(1, lsr.getErrors().size());
    System.assertEquals(String.format(System.Label.SB_NC_MAPPING_NoObject_ErrorMessage, new String[]{Lead.getSObjectType().getDescribe().getLabel(), 'Test2'}), lsr.getErrors()[0].getMessage());
  }

  /*------------------------------------ 基本設定 レコードタイプ(複数) END ------------------------------------*/

  /*------------------------------------ 基本設定 キャンペンメンバーステータスチェック Start ------------------------------------*/

  private static List<String> campaignStatusList {
    get {
      if (campaignStatusList == null) {
        campaignStatusList = new List<String>();
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
            campaignStatusList.add(f.getValue());
          }
        }
      }
      return campaignStatusList;
    }
    set;
  }

  /**
   * @description キャンペンメンバーステータスチェックあり（正当）基本設定追加
  */
  public static testMethod void test_campaignCheck_insert_ok(){
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    if (!campaignStatusList.isEmpty()) {
      setting.RenkeiCampaignStatus__c=campaignStatusList.get(0);
    }
    Boolean success = true;
    try {
      insert setting;
    }
    catch(Exception e) {
      success = false;
    }
    System.assertEquals(false, [SELECT Id FROM NameCardBasicSetting__c].isEmpty());
    System.assertEquals(true, success);
  }

  /**
   * @description キャンペンメンバーステータスチェックあり（不正）基本設定追加
  */
  public static testMethod void test_campaignCheck_insert_ng(){
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    setting.RenkeiCampaignStatus__c='BAD CAMPAIGN MEMBER STATUS';
    Boolean success = true;
    try {
      insert setting;
    }
    catch(Exception e) {
      success = false;
    }
    System.assertEquals(true, [SELECT Id FROM NameCardBasicSetting__c].isEmpty());
    System.assertEquals(false, success);
  }

  /**
   * @description キャンペンメンバーステータスチェックあり（正当）基本設定更新
  */
  public static testMethod void test_campaignCheck_update_ok(){
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    insert setting;
    if (!campaignStatusList.isEmpty()) {
      setting.RenkeiCampaignStatus__c=campaignStatusList.get(0);
    }
    Boolean success = true;
    try {
      update setting;
    }
    catch(Exception e) {
      success = false;
    }
    System.assertEquals(false, [SELECT Id FROM NameCardBasicSetting__c ].isEmpty());
    System.assertEquals(true, success);
  }

  /**
   * @description キャンペンメンバーステータスチェックあり（不正）基本設定更新
  */
  public static testMethod void test_campaignCheck_update_ng(){
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    insert setting;
    setting.RenkeiCampaignStatus__c='BAD CAMPAIGN MEMBER STATUS';
    Boolean success = true;
    try {
      update setting;
    }
    catch(Exception e) {
      success = false;
    }
    System.assertEquals(false, [SELECT Id FROM NameCardBasicSetting__c ].isEmpty());
    System.assertEquals(false, success);
  }

  /*------------------------------------ 基本設定 キャンペンメンバーステータスチェック End ------------------------------------*/

/******************************************* 基本設定 レコードタイプ End *******************************************/
}