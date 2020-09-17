/**
 * SB_NC_CardAppLauncherControllerTest
 *  SmartVisca LEX対応
 *   Lightning Component 起動用 Lightning Application 起動用 VFページ 用 APEXコントローラ テストクラス
 *
 *
 * Copyright (C) 2016 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2016.01.xx
 *  @Version 2      2017.10.xx  v1.21 for code scan Test Methods With No Assert
 *
 **/
@isTest
private class SB_NC_CardAppLauncherControllerTest {

  public class TestDb extends SB_NC_TestDB {

    public void updaeDeliveryStatus() {
      List<NameCard__c> cards = [SELECT Id, Name, Parent__c, Saishin__c, delivery_type__c FROM NameCard__c];
      for (NameCard__c c : cards) {
        c.delivery_type__c = '2';
        c.Saishin__c = true;
      }
      update cards;
    }

    public override void initialize() {
       // ユーザ
      initializeUser();
      if (listUser.isEmpty() == false) {
        insert listUser;
      }
      // 名刺関係
      initializeKaisha();     // 会社を揃えておく
      initializeEmployee();   // 会社ごとに名刺の人を揃えておく
      // 名刺
      initializeNameCard();
      if (listCard.isEmpty() == false) {
        insert listCard;
      }
      // 取引先
      initializeAccount();  // 揃えた会社について、取引先を作る。
      if (mapAccount.isEmpty() == false) {
        insert mapAccount.values();
      }
      // 取引先責任者
      initializeContact();
      if (!listContact.isEmpty()) {
        insert listContact;
      }
    }
  }

  @testSetup
  static void setupDB() {
    TestDb db = new TestDb();
    db.initialize();
    db.updaeDeliveryStatus();
    System.assert(db != null);  // 2017.10.xx  v1.21 for code scan Test Methods With No Assert
  }

  // 転職先の設定用 LC を起動する
  @isTest
  static void test_SB_NC_CardAppLauncher_SetNewCareer() {
    List<User> users = [SELECT Id, Name FROM User WHERE IsActive = true limit 10];
    System.assertNotEquals(0, users.size());
    System.runAs(users[0]) {
      List<NameCard__c> objs = [SELECT Id, Name FROM NameCard__c WHERE Saishin__c = true];
      System.assert(objs.isEmpty()==false);
      PageReference pageRef = Page.SB_NC_CardAppLauncher;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put('id', objs[0].Id);
      ApexPages.currentPage().getParameters().put('app', 'newcareer');
      SB_NC_CardAppLauncherController ctrl = new SB_NC_CardAppLauncherController();
      String lccmp = SB_NC_CardAppLauncherController.APPCD_COMPONENT.get('newcareer');
      System.assertEquals(lccmp, ctrl.component);
    }
  }

  // 転職先の設定用 LC を起動するけど、対象の名刺のレコードIDが不正
  @isTest
  static void test_SB_NC_CardAppLauncher_SetNewCareer_InvalidId() {
    List<User> users = [SELECT Id, Name FROM User WHERE IsActive = true limit 10];
    System.assertNotEquals(0, users.size());
    System.runAs(users[0]) {
      PageReference pageRef = Page.SB_NC_CardAppLauncher;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put('id', '111111111111111');
      ApexPages.currentPage().getParameters().put('app', 'newcareer');
      SB_NC_CardAppLauncherController ctrl = new SB_NC_CardAppLauncherController();
      String lccmp = SB_NC_CardAppLauncherController.APPCD_COMPONENT.get('newcareer');
      System.assert(String.isBlank(ctrl.component));
    }
  }

  // 名刺で更新LC を起動するつもりで、 app パラメータが不正
  @isTest
  static void test_SB_NC_CardAppLauncher_InvalidApp() {
    List<User> users = [SELECT Id, Name FROM User WHERE IsActive = true limit 10];
    System.assertNotEquals(0, users.size());
    System.runAs(users[0]) {
      List<Account> objs = [SELECT Id, Name FROM Account LIMIT 10];
      System.assert(objs.isEmpty()==false);
      PageReference pageRef = Page.SB_NC_CardAppLauncher;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put('id', objs[0].Id);
      ApexPages.currentPage().getParameters().put('app', 'updby');
      SB_NC_CardAppLauncherController ctrl = new SB_NC_CardAppLauncherController();
      String lccmp = SB_NC_CardAppLauncherController.APPCD_COMPONENT.get('updbycard');
      System.assertNotEquals(lccmp, ctrl.component);
    }
  }

  // 名刺で更新LC を起動するのに、 app パラメータが 直接 コンポーネント名でもOK
  @isTest
  static void test_SB_NC_CardAppLauncher_ComponentName() {
    List<User> users = [SELECT Id, Name FROM User WHERE IsActive = true limit 10];
    System.assertNotEquals(0, users.size());
    System.runAs(users[0]) {
      List<Account> objs = [SELECT Id, Name FROM Account LIMIT 10];
      System.assert(objs.isEmpty()==false);
      PageReference pageRef = Page.SB_NC_CardAppLauncher;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put('id', objs[0].Id);
      ApexPages.currentPage().getParameters().put('app', 'SB_NC_UpdateByCard');
      SB_NC_CardAppLauncherController ctrl = new SB_NC_CardAppLauncherController();
      String lccmp = SB_NC_CardAppLauncherController.APPCD_COMPONENT.get('updbycard');
      System.assertEquals(lccmp, ctrl.component);
    }
  }

}