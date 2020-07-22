/**
 *
 *  SB_NameCardL_RegistHelperTest
 *  SB_NC_RegistExecutorTest の改造
 *    SB_NameCardL_RegistHelper のテストクラス
 *
 * Copyright (C) 2016 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2016.11.xx
 *  @Version 2      2017.04.xx   クラッシク版取引先登録もこちらを使うので 調整
 *  SB_NameCardL_RegistHelper
 *  lx 2.0    2018.06.xx
 **/
@isTest
private class SB_NameCardL_RegistHelperTest
{
  public class TestDb extends SB_NCL_TestDB {

    public void appendNameCard() {
      List<SmartViscaf__NameCard__c> objs = new List<SmartViscaf__NameCard__c>();
      objs.add(new SmartViscaf__NameCard__c(Name='追加姓１ 名１', SmartViscaf__last_name__c='追加姓１', SmartViscaf__first_name__c='名１', SmartViscaf__email__c='test1@add1.com', SmartViscaf__company_name__c='追加会社１'));
      objs.add(new SmartViscaf__NameCard__c(Name='追加姓２ 名２', SmartViscaf__last_name__c='追加姓２', SmartViscaf__first_name__c='名２', SmartViscaf__email__c='test2@add2.com', SmartViscaf__company_name__c='追加会社２'));
      insert objs;
    }

    public void appendLead() {

    }

    //public List<Campaign> listCampaign = new List<Campaign>();
    //public void initializeCampaign() {
    //  listCampaign.add(new Campaign(Name='テストキャンペーン01', IsActive=true));
    //}

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
      // 名刺にToDoをつける
      initializeTask();
      if (!listTask.isEmpty()) {
        insert listTask;
      }
      // 名刺に行動をつける
      initializeEvent();
      if (!listEvent.isEmpty()) {
        insert listEvent;
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
      // 名刺連携項目マッピング
      initializeMapping();
      if (!listMapping.isEmpty()) {
        insert listMapping;
      }
      initializeCampaign();
      if (!listCampaign.isEmpty()) {
        insert listCampaign;
      }
    }
  }

  // 名刺からリードを作って、キャンペーンメンバーも作る
  @isTest
  static void test_doRegistEx_Lead_Create() {
    TestDb db = new TestDb();
    db.initialize();
    db.appendNameCard();

    Test.startTest();
    User u = db.listUser[0];
    List<SmartViscaf__NameCard__c> cards = [SELECT Id, Name, SmartViscaf__company_name__c FROM SmartViscaf__NameCard__c WHERE SmartViscaf__company_name__c LIKE '追加%'];
    System.assertEquals(2, cards.size());

    // リクエストパラメータの作成
    List<SB_NameCardL_RegistHelper.RegistTarget> targets = new List<SB_NameCardL_RegistHelper.RegistTarget>();
    SB_NameCardL_RegistHelper.RegistTarget t1 = new SB_NameCardL_RegistHelper.RegistTarget(SB_NameCardL_RegistHelper.ProcType.LEAD, cards[0].Id, null, null, null, true, null);
    t1.setLeadCampaign(db.listCampaign[0].Id, SB_NameCardL_Util.getDefaultCampaignStatus());
    targets.add(t1);    // 既存 2017.04.xx
    SB_NameCardL_RegistHelper.RegistTarget t2 = new SB_NameCardL_RegistHelper.RegistTarget(SB_NameCardL_RegistHelper.ProcType.LEAD, cards[1].Id, null, null, null, true, null);
    t2.setLeadCampaign(db.listCampaign[0].Id, SB_NameCardL_Util.getDefaultCampaignStatus());
    targets.add(t2);    // 既存 2017.04.xx
    SB_NameCardL_RegistHelper.RegistParam acntParam = new SB_NameCardL_RegistHelper.RegistParam('Account', true, null, u.Id, false);
    SB_NameCardL_RegistHelper.RegistParam contParam = new SB_NameCardL_RegistHelper.RegistParam('Contact', true, null, u.Id, false);
    SB_NameCardL_RegistHelper.RegistParam leadParam = new SB_NameCardL_RegistHelper.RegistParam('Lead', true, null, u.Id, false);
    SB_NameCardL_RegistHelper.TodoParam todoParam = new SB_NameCardL_RegistHelper.TodoParam('件名:名刺交換', Date.today(), 'ToDoのコメント', u.Id);
    SB_NameCardL_RegistHelper.RegistRequest req = new SB_NameCardL_RegistHelper.RegistRequest(targets, acntParam, contParam, leadParam, todoParam);
    //　実行
    SB_NameCardL_RegistHelper.RegistResponse res = SB_NameCardL_RegistHelper.doRegistEx(req);
    //　結果確認
    System.assert(res.success);
    System.assertEquals(2, res.registeds.size());
    for (Id cardId : res.registeds.keySet()) {
      SB_NameCardL_RegistHelper.RegistedSummary rs = res.registeds.get(cardId);
      System.debug(rs.acnt != null ? rs.acnt.id + ': ' + rs.acnt.name : 'Account not Created');
      System.debug(rs.cont != null ? rs.cont.id + ': ' + rs.cont.name : 'Contact not Created');
      System.debug(rs.lead != null ? rs.lead.id + ': ' + rs.lead.name : 'Lead not Created');
      System.debug(rs.todo != null ? rs.todo.id + ': ' + rs.todo.name : 'ToDo not Created');
    }
    //// 1. 更新分の確認
    //// existing Account
    //System.assertEquals(acnt.Id, res.registeds.get(card.Id).acnt.Id);
    //// existing Contact
    //System.assertEquals(cont.Id, res.registeds.get(card.Id).cont.Id);

    // 2. 追加分の確認 New Account new Contact
    List<Lead> leads = [SELECT Id, Name, Company, Email FROM Lead WHERE Company Like '追加%'];
    System.assertEquals(2, leads.size());
    // キャンペーンメンバーになってる
    System.assertEquals(leads.size(), [SELECT Id, CampaignId, LeadId, ContactId FROM CampaignMember WHERE LeadId IN :leads].size());
    Map<Id, SmartViscaf__NameCard__c> id2card = new Map<Id, SmartViscaf__NameCard__c>([SELECT Id, Name, SmartViscaf__account__c, SmartViscaf__contact__c, SmartViscaf__lead__c FROM SmartViscaf__NameCard__c WHERE SmartViscaf__company_name__c LIKE '追加%']);
    for(Id cardId : id2card.keySet()) {
      SmartViscaf__NameCard__c nc = id2card.get(cardId);
      //System.assertEquals(nc.SmartViscaf__account__c, res.registeds.get(cardId).acnt.Id);     // refernce to account eq. res
      //System.assertEquals(nc.SmartViscaf__contact__c, res.registeds.get(cardId).cont.Id);     // refernce to contact eq. res
      System.assertEquals(nc.SmartViscaf__lead__c, res.registeds.get(cardId).lead.Id);     // refernce to contact eq. res
    }
    Test.stopTest();


  }


  // 名刺から既存アカウント、コンタクトを更新と、アカウント、コンタクト作成、と、コンタクトをキャンペーンメンバーにする。
  @isTest
  static void test_doRegist_Account() {
    TestDb db = new TestDb();
    db.initialize();
    db.appendNameCard();

    Test.startTest();
    User u = db.listUser[0];
    Contact cont = [SELECT Id, Name, LastName, FirstName, AccountId FROM Contact  LIMIT 1];
    Account acnt = [SELECT Id, Name FROM Account WHERE Id=:cont.AccountId LIMIT 1];
    SmartViscaf__NameCard__c card = [SELECT Id, Name, SmartViscaf__company_name__c FROM SmartViscaf__NameCard__c WHERE SmartViscaf__company_name__c=:acnt.Name
           AND SmartViscaf__person_name_first__c=:cont.FirstName AND SmartViscaf__person_name_last__c=:cont.LastName LIMIT 1];

    List<SmartViscaf__NameCard__c> cards = [SELECT Id, Name FROM SmartViscaf__NameCard__c WHERE SmartViscaf__company_name__c LIKE '追加%'];
    System.assert(cards.size() == 2);
    // リクエストパラメータの作成
    List<SB_NameCardL_RegistHelper.RegistTarget> targets = new List<SB_NameCardL_RegistHelper.RegistTarget>();
    SB_NameCardL_RegistHelper.RegistTarget t1 = new SB_NameCardL_RegistHelper.RegistTarget(SB_NameCardL_RegistHelper.ProcType.ACCOUNT, card.Id, acnt.Id, cont.Id, null, true, null);
    t1.setContactCampaign(db.listCampaign[0].Id, SB_NameCardL_Util.getDefaultCampaignStatus());
    targets.add(t1);    // 既存 2017.04.xx
    SB_NameCardL_RegistHelper.RegistTarget t2 = new SB_NameCardL_RegistHelper.RegistTarget(SB_NameCardL_RegistHelper.ProcType.ACCOUNT, cards[0].Id, null, null, null, true, null);
    t2.setContactCampaign(db.listCampaign[0].Id, SB_NameCardL_Util.getDefaultCampaignStatus());
    targets.add(t2);  //　新規 2017.04.xx
    SB_NameCardL_RegistHelper.RegistTarget t3 = new SB_NameCardL_RegistHelper.RegistTarget(SB_NameCardL_RegistHelper.ProcType.ACCOUNT, cards[1].Id, null, null, null, true, null);
    t3.setContactCampaign(db.listCampaign[0].Id, SB_NameCardL_Util.getDefaultCampaignStatus());
    targets.add(t3);  //　新規 2017.04.xx
    SB_NameCardL_RegistHelper.RegistParam acntParam = new SB_NameCardL_RegistHelper.RegistParam('Account', true, null, u.Id, false);
    SB_NameCardL_RegistHelper.RegistParam contParam = new SB_NameCardL_RegistHelper.RegistParam('Contact', true, null, u.Id, false);
    SB_NameCardL_RegistHelper.TodoParam todoParam = new SB_NameCardL_RegistHelper.TodoParam('件名:名刺交換', Date.today(), 'ToDoのコメント', u.Id);
    SB_NameCardL_RegistHelper.RegistRequest req = new SB_NameCardL_RegistHelper.RegistRequest(targets, acntParam, contParam, null, todoParam);
    //　実行
    SB_NameCardL_RegistHelper.RegistResponse res = SB_NameCardL_RegistHelper.doRegist(req);
    //　結果確認
    System.assert(res.success);
    System.assertEquals(3, res.registeds.size());
    for (Id cardId : res.registeds.keySet()) {
      SB_NameCardL_RegistHelper.RegistedSummary rs = res.registeds.get(cardId);
      System.debug(rs.acnt.id + ': ' + rs.acnt.name);
      System.debug(rs.cont.id + ': ' + rs.cont.name);
      System.debug(rs.todo.id + ': ' + rs.todo.name);
    }
    // 1. 更新分の確認
    // existing Account
    System.assertEquals(acnt.Id, res.registeds.get(card.Id).acnt.Id);
    // existing Contact
    System.assertEquals(cont.Id, res.registeds.get(card.Id).cont.Id);

    // 2. 追加分と既存の確認
    List<Contact> conts = [SELECT Id, Name, AccountId FROM Contact WHERE Account.Name Like '追加%' OR Id = :cont.Id];
    System.assertEquals(3, conts.size());
    // キャンペーンメンバーになってる
    System.assertEquals(conts.size(), [SELECT Id, CampaignId, LeadId, ContactId FROM CampaignMember WHERE ContactId IN :conts].size());

    Map<Id, SmartViscaf__NameCard__c> id2card = new Map<Id, SmartViscaf__NameCard__c>([SELECT Id, Name, SmartViscaf__account__c, SmartViscaf__contact__c FROM SmartViscaf__NameCard__c WHERE SmartViscaf__company_name__c LIKE '追加%']);
    for(Id cardId : id2card.keySet()) {
      SmartViscaf__NameCard__c nc = id2card.get(cardId);
      System.assertEquals(nc.SmartViscaf__account__c, res.registeds.get(cardId).acnt.Id);     // refernce to account eq. res
      System.assertEquals(nc.SmartViscaf__contact__c, res.registeds.get(cardId).cont.Id);     // refernce to contact eq. res
    }
    Test.stopTest();
  }

  @isTest
  static void test_doRegist_new_account_error() {
    TestDb db = new TestDb();
    db.initialize();

    User u = db.listUser[0];
    List<SmartViscaf__NameCard__c> cards = new List<SmartViscaf__NameCard__c>();
    // 会社名のない名刺
    cards.add(new SmartViscaf__NameCard__c(Name='追加姓１ 名１', SmartViscaf__last_name__c='追加姓１', SmartViscaf__first_name__c='名１', SmartViscaf__email__c='test1@add1.com', SmartViscaf__company_name__c=null));
    insert cards;
    // リクエストパラメータの作成
    List<SB_NameCardL_RegistHelper.RegistTarget> targets = new List<SB_NameCardL_RegistHelper.RegistTarget>();
    targets.add(new SB_NameCardL_RegistHelper.RegistTarget(SB_NameCardL_RegistHelper.ProcType.ACCOUNT, cards[0].Id, null, null, null, true, null));  //　新規  2017.04.xx
    SB_NameCardL_RegistHelper.RegistParam acntParam = new SB_NameCardL_RegistHelper.RegistParam('Account', true, null, u.Id, false);
    SB_NameCardL_RegistHelper.RegistParam contParam = new SB_NameCardL_RegistHelper.RegistParam('Contact', true, null, u.Id, false);
    SB_NameCardL_RegistHelper.TodoParam todoParam = new SB_NameCardL_RegistHelper.TodoParam('件名:名刺交換', Date.today(), 'ToDoのコメント', u.Id);
    SB_NameCardL_RegistHelper.RegistRequest req = new SB_NameCardL_RegistHelper.RegistRequest(targets, acntParam, contParam, null, todoParam);
    //　実行
    SB_NameCardL_RegistHelper.RegistResponse res = SB_NameCardL_RegistHelper.doRegist(req);
    //　結果確認
    System.assertEquals(false, res.success);

  }

  @isTest
  static void test_doRegist_new_contact_error() {
    TestDb db = new TestDb();
    db.initialize();

    User u = db.listUser[0];
    List<SmartViscaf__NameCard__c> cards = new List<SmartViscaf__NameCard__c>();
    // 姓のない名刺
    cards.add(new SmartViscaf__NameCard__c(Name='追加姓１ 名１', SmartViscaf__last_name__c=null, SmartViscaf__first_name__c='名１', SmartViscaf__email__c='test1@add1.com', SmartViscaf__company_name__c='追加会社１'));
    insert cards;
    // リクエストパラメータの作成
    List<SB_NameCardL_RegistHelper.RegistTarget> targets = new List<SB_NameCardL_RegistHelper.RegistTarget>();
    targets.add(new SB_NameCardL_RegistHelper.RegistTarget(SB_NameCardL_RegistHelper.ProcType.ACCOUNT, cards[0].Id, null, null, null, true, null));  //　新規 2017.04.xx
    SB_NameCardL_RegistHelper.RegistParam acntParam = new SB_NameCardL_RegistHelper.RegistParam('Account', true, null, u.Id, false);
    SB_NameCardL_RegistHelper.RegistParam contParam = new SB_NameCardL_RegistHelper.RegistParam('Contact', true, null, u.Id, false);
    SB_NameCardL_RegistHelper.TodoParam todoParam = new SB_NameCardL_RegistHelper.TodoParam('件名:名刺交換', Date.today(), 'ToDoのコメント', u.Id);
    SB_NameCardL_RegistHelper.RegistRequest req = new SB_NameCardL_RegistHelper.RegistRequest(targets, acntParam, contParam, null, todoParam);
    //　実行
    SB_NameCardL_RegistHelper.RegistResponse res = SB_NameCardL_RegistHelper.doRegist(req);
    //　結果確認
    System.assertEquals(false, res.success);
  }


  //// createSobjects
  //@isTest
  //static void test_createSobjects() {
  //  TestDb db = new TestDb();
  //  db.initialize();

  //  Map<Id, SmartViscaf__NameCard__c> objs = new Map<Id, SmartViscaf__NameCard__c>([SELECT Id, Name FROM SmartViscaf__NameCard__c LIMIT 10]);
  //  SB_NameCardL_RegistHelper exec = new SB_NameCardL_RegistHelper();
  //  Map<Id, SObject> res = exec.createSobjects(SmartViscaf__NameCard__c.getSObjectType(), objs.keySet());
  //  for (SObject o : res.values()) {
  //    System.assertEquals(objs.get(o.Id).Name, (String)o.get('Name'));
  //  }
  //}


  @isTest
  static void test_etc() {
    SB_NameCardL_RegistHelper helper = new SB_NameCardL_RegistHelper();
    System.assertEquals(false, helper.success);
    System.assertEquals(null, helper.req);
    System.assertNotEquals(null, helper.result);
  }


}