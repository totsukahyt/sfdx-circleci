/**
 *
 *  SB_NC_SetNewCareerLcControllerTest
 *  SmartVisca LEX対応
 *   Lightning Component 用 コントローラ   SB_NC_SetNewCareerLcController のテストクラス
 *
 * Copyright (C) 2016 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2016.11.xx
 *
 **/
@isTest
private class SB_NC_SetNewCareerLcControllerTest {

  // 最新の名刺とその子達の組み合わせ
  public class Family {
    public NameCard__c parent;
    public Set<NameCard__c> children;
    public Family(NameCard__c parent, NameCard__c elder, NameCard__c younger) {
      parent.Saishin__c = true;
      parent.Parent__c = null;
      setParent(parent, elder);
      setParent(parent, younger);
      this.parent = parent;
      children = new Set<NameCard__c>();
      children.add(elder);
      children.add(younger);
    }
    private void setParent(NameCard__c p, NameCard__c c) {
      c.Saishin__c = false;
      c.Parent__c = p.Id;
    }
  }

  public class TestDb extends SB_NC_TestDB {

    public Family oldFamily;
    public Family newFamily;

    public void setupSaishinMeishi() {
      List<NameCard__c> cards = [SELECT Id, Name, Parent__c, Saishin__c FROM NameCard__c limit 6];
      oldFamily = new Family(cards[0], cards[1], cards[2]);
      newFamily = new Family(cards[3], cards[4], cards[5]);
      update cards;
    }

    public void updaeDeliveryStatus() {
      List<NameCard__c> cards = [SELECT Id, Name, Parent__c, Saishin__c, delivery_type__c FROM NameCard__c];
      for (NameCard__c c : cards) {
        c.delivery_type__c = '2';
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

  //
  @isTest
  static void t_checkSaishinCard() {
    TestDb db = new TestDb();
    db.initialize();
    db.updaeDeliveryStatus();
    db.setupSaishinMeishi();

    List<NameCard__c> saishins = [SELECT Id FROM NameCard__c WHERE Saishin__c = true];
    if (!saishins.isEmpty()) {
      String result = SB_NC_SetNewCareerLcController.checkSaishinCard(saishins[0].Id);
      SB_NC_SetNewCareerLcController.CheckSaishinCardResponse res = (SB_NC_SetNewCareerLcController.CheckSaishinCardResponse)JSON.deserializeStrict(result, SB_NC_SetNewCareerLcController.CheckSaishinCardResponse.class);
      System.assertEquals(true, res.saishin);
    }
    List<NameCard__c> not_saishins = [SELECT Id FROM NameCard__c WHERE Saishin__c = false];
    if (!not_saishins.isEmpty()) {
      String result = SB_NC_SetNewCareerLcController.checkSaishinCard(not_saishins[0].Id);
      SB_NC_SetNewCareerLcController.CheckSaishinCardResponse res = (SB_NC_SetNewCareerLcController.CheckSaishinCardResponse)JSON.deserializeStrict(result, SB_NC_SetNewCareerLcController.CheckSaishinCardResponse.class);
      System.assertEquals(false, res.saishin);
    }

  }

  // 更新OK
  @isTest
  static void t_setNewCareer() {
    TestDb db = new TestDb();
    db.initialize();
    db.updaeDeliveryStatus();
    db.setupSaishinMeishi();


    Test.startTest();

    SB_NC_SetNewCareerLcController.SetNewCareerResponse res;

    String result = SB_NC_SetNewCareerLcController.setNewCareer(db.oldFamily.parent.Id, db.newFamily.parent.Id);
    res = (SB_NC_SetNewCareerLcController.SetNewCareerResponse)JSON.deserializeStrict(result, SB_NC_SetNewCareerLcController.SetNewCareerResponse.class);

    // 正常に更新できる
    System.assertEquals(true, res.success);
    System.assert(String.isBlank(res.error));
    Test.stopTest();
  }


  // エラー
  @isTest
  static void t_setNewCareerError1() {
    TestDb db = new TestDb();
    db.initialize();
    db.updaeDeliveryStatus();
    db.setupSaishinMeishi();

    Test.startTest();

    SB_NC_SetNewCareerLcController.SetNewCareerResponse res;

    String result = SB_NC_SetNewCareerLcController.setNewCareer(db.oldFamily.parent.Id, db.oldFamily.parent.Id);
    res = (SB_NC_SetNewCareerLcController.SetNewCareerResponse)JSON.deserializeStrict(result, SB_NC_SetNewCareerLcController.SetNewCareerResponse.class);

    // 同じ名刺だったので、エラー
    System.assertEquals(false, res.success);
    System.assert(String.isNotBlank(res.error));
    Test.stopTest();

  }

  // エラー
  @isTest
  static void t_setNewCareerError2() {
    TestDb db = new TestDb();
    db.initialize();
    db.setupSaishinMeishi();

    Test.startTest();

    SB_NC_SetNewCareerLcController.SetNewCareerResponse res;

    String result = SB_NC_SetNewCareerLcController.setNewCareer(db.oldFamily.parent.Id, db.newFamily.parent.Id);
    res = (SB_NC_SetNewCareerLcController.SetNewCareerResponse)JSON.deserializeStrict(result, SB_NC_SetNewCareerLcController.SetNewCareerResponse.class);

    // 二次納品でなかったので、エラー
    System.assertEquals(false, res.success);
    System.assert(String.isNotBlank(res.error));
    Test.stopTest();

  }

}