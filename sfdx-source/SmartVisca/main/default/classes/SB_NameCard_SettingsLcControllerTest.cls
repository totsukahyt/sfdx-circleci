/**
 *
 * SB_NameCard_RenkeiSettingLcTest    (SB_NameCard_RenkeiSettingLcController)
 *
 *  Copyright (C) 2016 SunBridge Inc. All Rights Reserved.
 *
 *  @author mao
 *  @Version 1.20      2017.02.XX
 *  @Version 2.4       2019.06.XX SV_DEV-1634 SmartVisca設定タブの自動連携に関する設定の表示/非表示を切り替えるカスタム設定を作る
 *
 **/
@isTest
public with sharing class SB_NameCard_SettingsLcControllerTest {
	@isTest
  //権限がありません
  static void test_canNotAccess() {
    List<Profile> profiles = [Select Id From Profile Where Name IN ('Read Only','参照のみ')];
    Profile p = profiles[0];
    User testUser = new User(
      alias = 'hogehoge',
      email = 'smith@salesforce.com',
      emailencodingkey = 'UTF-8',
      lastname = 'smith',
      languagelocalekey = 'en_US',
      localesidkey = 'en_US',
      profileid = p.Id,
      timezonesidkey = 'America/Los_Angeles',
      username = 'smith@salesforce.com.forsample'
    );
    System.runAs(testUser) {
      String c1 =  SB_NameCard_SettingsLcController.check();
      SB_NameCard_SettingsLcController.CheckAccesable ca1 = (SB_NameCard_SettingsLcController.CheckAccesable)System.JSON.deserializeStrict(c1,SB_NameCard_SettingsLcController.CheckAccesable.Class);
      System.assertEquals(String.isBlank(ca1.message),false);
    }
	}
  @isTest
  //権限があっで問題なく登録
  static void test_canAccess() {
    String c =  SB_NameCard_SettingsLcController.check();
    SB_NameCard_SettingsLcController.CheckAccesable ca = (SB_NameCard_SettingsLcController.CheckAccesable)System.JSON.deserializeStrict(c,SB_NameCard_SettingsLcController.CheckAccesable.Class);
    System.assertEquals(String.isBlank(ca.message),true);
  }
}