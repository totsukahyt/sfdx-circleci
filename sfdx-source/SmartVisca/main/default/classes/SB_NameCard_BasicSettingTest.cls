/**
 *
 * SB_NameCard_BasicSettingTest
 *  名刺基本設定を 保持するクラス SB_NameCard_BasicSetting のテストクラス
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2019.06.xx v2.4 SV_DEV-940 取引先・取引先責任者登録時の会社名の比較対象をカスタム項目としたい
 *                                    SV_DEV-590 取引先・取引先検索の対象を、レコードタイプ単位で絞る
 *
 **/
@isTest
private class SB_NameCard_BasicSettingTest {

  @isTest
  static void test_RegistAccountCompareField_default() {
    SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder builder = new SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder();
    builder.run();

    // NameCardBasicSetting__c setting = [SELECT Id, Name, RegistAccountCompareCustomize__c, RegistAccountCompareField__c FROM NameCardBasicSetting__c LIMIT 1];

    NameCardBasicSetting__c setting = SB_NameCard_BasicSetting.getNameCardBasicSetting();
    System.assertEquals(false, setting.RegistAccountCompareCustomize__c);
    System.assertEquals(null, setting.RegistAccountCompareField__c);
  }

  @isTest
  static void test_RegistAccountCompareField_custom() {
    SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder builder = new SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder();
    builder.run();

    NameCardBasicSetting__c setting = [SELECT Id, Name, RegistAccountCompareCustomize__c, RegistAccountCompareField__c FROM NameCardBasicSetting__c LIMIT 1];
    setting.RegistAccountCompareCustomize__c = true;
    setting.RegistAccountCompareField__c = 'Site';
    update setting;

    System.assertEquals('Site', SB_NameCard_BasicSetting.accountOrgField);
  }

  @isTest
  static void test_RegistLeadCompareField_default() {
    SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder builder = new SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder();
    builder.run();

    // NameCardBasicSetting__c setting = [SELECT Id, Name, RegistLeadCompareCustomize__c, RegistLeadCompareField__c FROM NameCardBasicSetting__c LIMIT 1];
    NameCardBasicSetting__c setting = SB_NameCard_BasicSetting.getNameCardBasicSetting();
    System.assertEquals(false, setting.RegistLeadCompareCustomize__c);
    System.assertEquals(null, setting.RegistLeadCompareField__c);
  }

  @isTest
  static void test_RegistLeadCompareField_custom() {
    SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder builder = new SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder();
    builder.run();

    NameCardBasicSetting__c setting = [SELECT Id, Name, RegistLeadCompareCustomize__c, RegistLeadCompareField__c FROM NameCardBasicSetting__c LIMIT 1];
    setting.RegistLeadCompareCustomize__c = true;
    setting.RegistLeadCompareField__c = 'Description';
    update setting;

    System.assertEquals('Description', SB_NameCard_BasicSetting.leadOrgField);
  }


  @isTest
  static void test_getRegistQuerySelectedRecordTypeIds() {
    SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder builder = new SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder();
    builder.run();

    NameCardBasicSetting__c setting = [SELECT Id, Name, RegistAccountQueryRecordTypeIds__c, RegistContactQueryRecordTypeIds__c, RegistLeadQueryRecordTypeIds__c FROM NameCardBasicSetting__c LIMIT 1];
    setting.RegistAccountQueryRecordTypeIds__c = String.join(new List<Id>(Account.sObjectType.getDescribe().getRecordTypeInfosById().keySet()), ';'); // 全部またはマスターのみ
    setting.RegistContactQueryRecordTypeIds__c = String.join(new List<Id>(Contact.sObjectType.getDescribe().getRecordTypeInfosById().keySet()), ';'); // 全部またはマスターのみ
    setting.RegistLeadQueryRecordTypeIds__c = String.join(new List<Id>(Lead.sObjectType.getDescribe().getRecordTypeInfosById().keySet()), ';'); // 全部またはマスターのみ
    update setting;

    System.assert(String.isNotBlank(SB_NameCard_BasicSetting.getRegistQuerySelectedRecordTypeIds('account')));
    System.assert(String.isNotBlank(SB_NameCard_BasicSetting.getRegistQuerySelectedRecordTypeIds('contact')));
    System.assert(String.isNotBlank(SB_NameCard_BasicSetting.getRegistQuerySelectedRecordTypeIds('lead')));
  }

  @isTest
  static void test_RegistXXXXXXQueryRecordTypeIds() {
    SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder builder = new SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder();
    builder.run();

    NameCardBasicSetting__c setting = [SELECT Id, Name, RegistAccountQueryRecordTypeIds__c, RegistContactQueryRecordTypeIds__c, RegistLeadQueryRecordTypeIds__c FROM NameCardBasicSetting__c LIMIT 1];
    setting.RegistAccountQueryRecordTypeIds__c = setting.Id + '; ' + setting.Id; // 無効なID
    setting.RegistContactQueryRecordTypeIds__c = setting.Id + '; ' + setting.Id; // 無効なID
    setting.RegistLeadQueryRecordTypeIds__c = setting.Id + '; ' + setting.Id; // 無効なID
    update setting;

    System.assert(SB_NameCard_BasicSetting.registAccountQueryRecordTypeIds.isEmpty());
    System.assert(SB_NameCard_BasicSetting.registContactQueryRecordTypeIds.isEmpty());
    System.assert(SB_NameCard_BasicSetting.registLeadQueryRecordTypeIds.isEmpty());
  }

  @isTest
  static void test_getRegistCandidateQueryRecordTypeIds() {
    SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder builder = new SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder();
    builder.run();

    // NameCardBasicSetting__c setting = [SELECT Id, Name, RegistAccountQueryRecordTypeIds__c, RegistContactQueryRecordTypeIds__c, RegistLeadQueryRecordTypeIds__c FROM NameCardBasicSetting__c LIMIT 1];
    // setting.RegistAccountQueryRecordTypeIds__c = setting.Id + '; ' + setting.Id; // 無効なID
    // setting.RegistContactQueryRecordTypeIds__c = setting.Id + '; ' + setting.Id; // 無効なID
    // setting.RegistLeadQueryRecordTypeIds__c = setting.Id + '; ' + setting.Id; // 無効なID
    // update setting;
    
    System.assert(SB_NameCard_BasicSetting.getRegistQueryRecordTypeIds('Account') != null);
    System.assert(SB_NameCard_BasicSetting.getRegistQueryRecordTypeIds('Contact') != null);
    System.assert(SB_NameCard_BasicSetting.getRegistQueryRecordTypeIds('Lead') != null);
    Boolean success = true;
    try {
      List<Id> recTypeIds = SB_NameCard_BasicSetting.getRegistQueryRecordTypeIds('Noname');
    }
    catch(Exception e) {
      success = false;
    }
    System.assertEquals(false, success);
  }





}