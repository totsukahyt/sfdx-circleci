/**
 *
 * SB_NameCard_SvConfigTest
 * SB_NameCard_SvConfig  のテストクラス 
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2019.08.xx
 *
 **/
@isTest
private class SB_NameCard_SvConfigTest {

  // ユーザ設定レコードががないときのデフォルト
  @isTest
  static void test_default() {
    SmartViscaConfig__c config = new SmartViscaConfig__c();
    insert config;
    SmartViscaUserConfig__c userConfig = new SmartViscaUserConfig__c();
    insert userConfig;
    SB_NameCard_SvConfig svConfig= new SB_NameCard_SvConfig();
    System.assert(!svConfig.userSetting.isEmpty());
    System.assertEquals(SmartViscaUserConfig__c.getOrgDefaults().SvInitialListView__c, svConfig.userSetting.get('svInitialListView'));
    System.assertEquals(SmartViscaUserConfig__c.getOrgDefaults().SvLatestListView__c, svConfig.userSetting.get('svLatestListView'));
  }

  // ユーザ設定レコードがあって、それを反映してる
  @isTest
  static void test_record() {
    SmartViscaConfig__c config = new SmartViscaConfig__c();
    insert config;
    SmartViscaUserConfig__c userConfig = new SmartViscaUserConfig__c();
    insert userConfig;
    NameCardUserSetting__c setting = new NameCardUserSetting__c();
    setting.User__c = UserInfo.getUserId();
    setting.SvInitialListView__c = 0;
    setting.SvLatestListView__c = 0;
    insert setting;
    SB_NameCard_SvConfig svConfig= new SB_NameCard_SvConfig();
    System.assert(!svConfig.userSetting.isEmpty());
    System.assertEquals(setting.SvInitialListView__c, svConfig.userSetting.get('svInitialListView'));
    System.assertEquals(setting.SvLatestListView__c, svConfig.userSetting.get('svLatestListView'));
  }

  @isTest
  static void test_save_SB_NameCard_SvConfig() {
    SmartViscaConfig__c config = new SmartViscaConfig__c();
    insert config;
    SmartViscaUserConfig__c userConfig = new SmartViscaUserConfig__c();
    insert userConfig;
    SB_NameCard_SvConfig svConfig= new SB_NameCard_SvConfig();
    Map<String, Object> container = new Map<String, Object>();
    svConfig.userSetting.put('svInitialListView', 100);
    svConfig.userSetting.put('svLatestListView', 1000);
    container.put('aaa', true);
    container.put('sss', 'test');
    container.put('userSetting', svConfig.userSetting);
    SB_NameCard_SvConfig.saveSetting(container); // 保存

    Id userId = UserInfo.getUserId();
    NameCardUserSetting__c userSetting = [SELECT SvInitialListView__c, SvLatestListView__c FROM NameCardUserSetting__c WHERE User__c = :userId LIMIT 1];
    System.assertEquals(100, userSetting.SvInitialListView__c);
    System.assertEquals(1000, userSetting.SvLatestListView__c);
  }

  @isTest
  static void test_save_Fields() {
    SmartViscaConfig__c config = new SmartViscaConfig__c();
    insert config;
    SmartViscaUserConfig__c userConfig = new SmartViscaUserConfig__c();
    insert userConfig;
    SB_NameCard_SvConfig svConfig= new SB_NameCard_SvConfig();
    Map<String, Object> values = new Map<String, Object>();
    values.put('svInitialListView', 100);
    values.put('svLatestListView', 1000);
    values.put('aaa', true);
    values.put('sss', 'test');
    SB_NameCard_SvConfig.saveSetting(values); // 保存

    Id userId = UserInfo.getUserId();
    NameCardUserSetting__c userSetting = [SELECT SvInitialListView__c, SvLatestListView__c FROM NameCardUserSetting__c WHERE User__c = :userId LIMIT 1];
    System.assertEquals(100, userSetting.SvInitialListView__c);
    System.assertEquals(1000, userSetting.SvLatestListView__c);
  }

  // 文字列を行で分けて、次に : でわけて キーと値のマップを作る メソッドのテスト 2015.08.1x
  // 2019.098.xx v2.4  SB_NameCard_S2ControllerTest から移動
  @isTest
  static void testGetKey2Value() {
    String text = 'key1:val1\r\nkey2:val2';
    Map<String, String> options = SB_NameCard_SvConfig.getKey2Value(text);
    System.assertEquals(2, options.size());
  }



}