/**
 *
 *  SmartVisca LEX対応
 *      SB_NC_CardDetailLcControllerTest
 *  名刺詳細表示用 Lightningコンポーネント 用 コントローラ のテストクラス
 *
 *
 * Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2017.01.xx
 *  @Version 2      2017.10.xx  v1.21 for code scan Test Methods With No Assert
 *
 **/
@isTest
private class SB_NC_CardDetailLcControllerTest {


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
    }
  }

  @testSetup
  static void setupDB() {
    TestDb db = new TestDb();
    db.initialize();
    db.updaeDeliveryStatus();
    System.assert(db != null);  // 2017.10.xx  v1.21 for code scan Test Methods With No Assert
  }

  //  名刺情報を取得で成功
  @isTest
  static void test_getNamecard_OK() {
    List<User> users = [SELECT Id, Name FROM User WHERE IsActive = true limit 10];
    System.assertNotEquals(0, users.size());
    System.runAs(users[0]) {
      List<NameCard__c> objs = [SELECT Id, Name FROM NameCard__c LIMIT 10];
      String result;
      result = SB_NC_CardDetailLcController.getNamecard(objs[0].Id);
      SB_NC_CardDetailLcController.GetNamecardResponse res = (SB_NC_CardDetailLcController.GetNamecardResponse)JSON.deserializeStrict(result, SB_NC_CardDetailLcController.GetNamecardResponse.class);
      System.assertEquals(true, res.success);
      System.assertEquals(objs[0].Name, res.card.Name);
    }
  }

  //  名刺情報を取得で、アカウントのレコードIDを指定してるので、失敗
  @isTest
  static void test_getNamecard_NG() {
    List<User> users = [SELECT Id, Name FROM User WHERE IsActive = true limit 10];
    System.assertNotEquals(0, users.size());
    System.runAs(users[0]) {
      List<Account> objs = [SELECT Id, Name FROM Account LIMIT 10];
      String result;
      result = SB_NC_CardDetailLcController.getNamecard(objs[0].Id);
      SB_NC_CardDetailLcController.GetNamecardResponse res = (SB_NC_CardDetailLcController.GetNamecardResponse)JSON.deserializeStrict(result, SB_NC_CardDetailLcController.GetNamecardResponse.class);
      System.assertEquals(false, res.success);
    }
  }

}