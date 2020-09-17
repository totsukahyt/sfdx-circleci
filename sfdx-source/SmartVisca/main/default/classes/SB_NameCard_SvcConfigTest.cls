/**
 *
 * SB_NameCard_SvcConfigTest
 * SB_NameCard_SvcConfig  のテストクラス 
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2019.05.xx
 *
 **/
@isTest
private class SB_NameCard_SvcConfigTest {

  @isTest
  static void test_constructor() {
    SmartViscaConfig__c config = new SmartViscaConfig__c();
    config.SSmartViscaServerOptions__c = 'AAA:111\r\nBBB:222';
    insert config;
    NameCardUserSetting__c setting = new NameCardUserSetting__c();
    setting.User__c = UserInfo.getUserId();
    setting.SvcLastListName__c = '前回のリスト名';
    insert setting;
    SB_NameCard_SvcConfig svcConfig = SB_NameCard_SvcConfig.getInstance();
    System.assert(!svcConfig.getValues().isEmpty());
    Map<String, String> opts = (Map<String, String>)svcConfig.getValues().get('sSmartViscaServerOptions');
    System.assertEquals('111', opts.get('AAA'));
    System.assertEquals(setting.SvcLastListName__c, svcConfig.getValues().get('svcLastListName'));
  }

  @isTest
  static void test_getValeus_sExtraNamespace() {
    SmartViscaConfig__c config = new SmartViscaConfig__c();
    config.SSmartViscaServerOptions__c = 'AAA:111\r\nBBB:222';
    config.SExtraNamespace__c = 'カスタム設定で名前空間名を指定';
    insert config;
    NameCardUserSetting__c setting = new NameCardUserSetting__c();
    setting.User__c = UserInfo.getUserId();
    setting.SvcLastListName__c = '前回のリスト名';
    insert setting;
    System.assertEquals(config.SExtraNamespace__c, SB_NameCard_SImageController.namespace);
  }

  // SV_DEV-1938 SmartViscaカメラから固定で proxy_flag及びservice_id を名刺サーバに送る
  @isTest
  static void test_FixedSeverOptions() {
    SmartViscaConfig__c config = new SmartViscaConfig__c();
    insert config;
    SB_NameCard_SvcConfig svcConfig = SB_NameCard_SvcConfig.getInstance();
    System.assert(!svcConfig.getValues().isEmpty());
    Map<String, String> opts = (Map<String, String>)svcConfig.getValues().get('sSmartViscaServerOptions');
    System.assertEquals('1', opts.get('proxy_flag'));
    System.assertEquals('SFDCAPEX', opts.get('service_id'));
  }


}