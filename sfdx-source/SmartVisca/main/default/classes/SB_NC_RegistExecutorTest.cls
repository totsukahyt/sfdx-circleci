/**
 *
 *  SB_NC_RegistExecutorTest
 *    SB_NC_RegistExecutor のテストクラス
 *
 * Copyright (C) 2016-2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2016.11.xx
 *  @Version 2      2017.04.xx   クラッシク版取引先登録もこちらを使うので 調整
 *  @Version 3      2019.07.xx v2.4 SV_DEV-437 名刺から子取引先の作成
 *                                  SV_DEV-1644 取引先・取引先責任者に登録(更新時)のToDo任命先を名刺の所有者にする
 *  @Version 4      2019.07.xx sawano   v2.4 SV_DEV-437 名刺から子取引先の作成
 *                          複数名刺項目から 連携先項目合成対応 SV_DEV-395 医療法人のデータ納品について
 *
 **/
@isTest
private class SB_NC_RegistExecutorTest
{
  public class TestDb extends SB_NC_TestDB {

    public void appendNameCard() {
      List<NameCard__c> objs = new List<NameCard__c>();
      objs.add(new NameCard__c(Name='追加姓１ 名１', last_name__c='追加姓１', first_name__c='名１', email__c='test1@add1.com', company_name__c='追加会社１', division__c='追加所属１'));
      objs.add(new NameCard__c(Name='追加姓２ 名２', last_name__c='追加姓２', first_name__c='名２', email__c='test2@add2.com', company_name__c='追加会社２', division__c='追加所属２'));
      insert objs;
    }

    private void appendInactiveUser() {
      User u = createUser(CNT_USER.format(), 'Inactive');
      u.IsActive = false;
      insert u;
    }

    public override void initialize() {
       // ユーザ
      initializeUser();
      if (listUser.isEmpty() == false) {
        insert listUser;
      }
      // 無効ユーザを追加
      appendInactiveUser();
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
    }
  }

  @isTest
  static void test_SB_NC_RegistExecutor() {
    TestDb db = new TestDb();
    db.initialize();
    db.appendNameCard();

    Test.startTest();
    User u = db.listUser[0];
    Contact cont = [SELECT Id, Name, LastName, FirstName, AccountId FROM Contact  LIMIT 1];
    Account acnt = [SELECT Id, Name FROM Account WHERE Id=:cont.AccountId LIMIT 1];
    NameCard__c card = [SELECT Id, Name, company_name__c FROM NameCard__c WHERE company_name__c=:acnt.Name
           AND person_name_first__c=:cont.FirstName AND person_name_last__c=:cont.LastName LIMIT 1];

    List<NameCard__c> cards = [SELECT Id, Name FROM NameCard__c WHERE company_name__c LIKE '追加%'];
    System.assert(cards.size() == 2);
    // リクエストパラメータの作成
    List<SB_NC_RegistExecutor.RegistTarget> targets = new List<SB_NC_RegistExecutor.RegistTarget>();
    targets.add(new SB_NC_RegistExecutor.RegistTarget(card.Id, acnt.Id, cont.Id, null, true, null));    // 既存 2017.04.xx
    targets.add(new SB_NC_RegistExecutor.RegistTarget(cards[0].Id, null, null, null, true, null));  //　新規 2017.04.xx
    targets.add(new SB_NC_RegistExecutor.RegistTarget(cards[1].Id, null, null, null, true, null));  //　新規 2017.04.xx
    SB_NC_RegistExecutor.RegistParam acntParam = new SB_NC_RegistExecutor.RegistParam('Account', true, null, u.Id, false);
    SB_NC_RegistExecutor.RegistParam contParam = new SB_NC_RegistExecutor.RegistParam('Contact', true, null, u.Id, false);
    SB_NC_RegistExecutor.TodoParam todoParam = new SB_NC_RegistExecutor.TodoParam('件名:名刺交換', Date.today(), 'ToDoのコメント', u.Id);
    SB_NC_RegistExecutor.RegistRequest req = new SB_NC_RegistExecutor.RegistRequest(targets, acntParam, contParam, null, todoParam);
    //　実行
    SB_NC_RegistExecutor.RegistResponse res = SB_NC_RegistExecutor.doRegist(req);
    //　結果確認
    System.assert(res.success);
    System.assertEquals(3, res.registeds.size());
    for (Id cardId : res.registeds.keySet()) {
      SB_NC_RegistExecutor.RegistedSummary rs = res.registeds.get(cardId);
      System.debug(rs.acnt.id + ': ' + rs.acnt.name);
      System.debug(rs.cont.id + ': ' + rs.cont.name);
      System.debug(rs.todo.id + ': ' + rs.todo.name);
    }
    // 1. 更新分の確認
    // existing Account
    System.assertEquals(acnt.Id, res.registeds.get(card.Id).acnt.Id);
    // existing Contact
    System.assertEquals(cont.Id, res.registeds.get(card.Id).cont.Id);

    // 2. 追加分の確認 New Account new Contact
    List<Contact> conts = [SELECT Id, Name, AccountId FROM Contact WHERE Account.Name Like '追加%'];
    System.assertEquals(2, conts.size());
    Map<Id, NameCard__c> id2card = new Map<Id, NameCard__c>([SELECT Id, Name, account__c, contact__c FROM NameCard__c WHERE company_name__c LIKE '追加%']);
    for(Id cardId : id2card.keySet()) {
      NameCard__c nc = id2card.get(cardId);
      System.assertEquals(nc.account__c, res.registeds.get(cardId).acnt.Id);     // refernce to account eq. res
      System.assertEquals(nc.contact__c, res.registeds.get(cardId).cont.Id);     // refernce to contact eq. res
    }
    Test.stopTest();
  }

  @isTest
  static void test_SB_NC_RegistExecutor_new_account_error() {
    TestDb db = new TestDb();
    db.initialize();

    User u = db.listUser[0];
    List<NameCard__c> cards = new List<NameCard__c>();
    // 会社名のない名刺
    cards.add(new NameCard__c(Name='追加姓１ 名１', last_name__c='追加姓１', first_name__c='名１', email__c='test1@add1.com', company_name__c=null));
    insert cards;
    // リクエストパラメータの作成
    List<SB_NC_RegistExecutor.RegistTarget> targets = new List<SB_NC_RegistExecutor.RegistTarget>();
    targets.add(new SB_NC_RegistExecutor.RegistTarget(cards[0].Id, null, null, null, true, null));  //　新規  2017.04.xx
    SB_NC_RegistExecutor.RegistParam acntParam = new SB_NC_RegistExecutor.RegistParam('Account', true, null, u.Id, false);
    SB_NC_RegistExecutor.RegistParam contParam = new SB_NC_RegistExecutor.RegistParam('Contact', true, null, u.Id, false);
    SB_NC_RegistExecutor.TodoParam todoParam = new SB_NC_RegistExecutor.TodoParam('件名:名刺交換', Date.today(), 'ToDoのコメント', u.Id);
    SB_NC_RegistExecutor.RegistRequest req = new SB_NC_RegistExecutor.RegistRequest(targets, acntParam, contParam, null, todoParam);
    //　実行
    SB_NC_RegistExecutor.RegistResponse res = SB_NC_RegistExecutor.doRegist(req);
    //　結果確認
    System.assertEquals(false, res.success);

  }

  @isTest
  static void test_SB_NC_RegistExecutor_new_contact_error() {
    TestDb db = new TestDb();
    db.initialize();

    User u = db.listUser[0];
    List<NameCard__c> cards = new List<NameCard__c>();
    // 姓のない名刺
    cards.add(new NameCard__c(Name='追加姓１ 名１', last_name__c=null, first_name__c='名１', email__c='test1@add1.com', company_name__c='追加会社１'));
    insert cards;
    // リクエストパラメータの作成
    List<SB_NC_RegistExecutor.RegistTarget> targets = new List<SB_NC_RegistExecutor.RegistTarget>();
    targets.add(new SB_NC_RegistExecutor.RegistTarget(cards[0].Id, null, null, null, true, null));  //　新規 2017.04.xx
    SB_NC_RegistExecutor.RegistParam acntParam = new SB_NC_RegistExecutor.RegistParam('Account', true, null, u.Id, false);
    SB_NC_RegistExecutor.RegistParam contParam = new SB_NC_RegistExecutor.RegistParam('Contact', true, null, u.Id, false);
    SB_NC_RegistExecutor.TodoParam todoParam = new SB_NC_RegistExecutor.TodoParam('件名:名刺交換', Date.today(), 'ToDoのコメント', u.Id);
    SB_NC_RegistExecutor.RegistRequest req = new SB_NC_RegistExecutor.RegistRequest(targets, acntParam, contParam, null, todoParam);
    //　実行
    SB_NC_RegistExecutor.RegistResponse res = SB_NC_RegistExecutor.doRegist(req);
    //　結果確認
    System.assertEquals(false, res.success);
  }

  // 2019.07.xx v2.4 SV_DEV-437 名刺から子取引先の作成
  @isTest
  static void test_create_new_childAccount_new_contact() {
    TestDb db = new TestDb();
    db.initialize();
    db.appendNameCard();

    Test.startTest();
    User u = db.listUser[0];
    // Contact cont = [SELECT Id, Name, LastName, FirstName, AccountId FROM Contact  LIMIT 1];
    Account acnt = [SELECT Id, Name FROM Account LIMIT 1];

    List<NameCard__c> cards = [SELECT Id, Name FROM NameCard__c WHERE company_name__c LIKE '追加%'];
    System.assert(cards.size() == 2);
    // リクエストパラメータの作成
    List<SB_NC_RegistExecutor.RegistTarget> targets = new List<SB_NC_RegistExecutor.RegistTarget>();
    targets.add(new SB_NC_RegistExecutor.RegistTarget(cards[0].Id, acnt.Id, null, null, true, null, true));    // 既存 
    targets.add(new SB_NC_RegistExecutor.RegistTarget(cards[1].Id, acnt.Id, null, null, true, null, true));    // 既存 
    SB_NC_RegistExecutor.RegistParam acntParam = new SB_NC_RegistExecutor.RegistParam('Account', true, null, u.Id, false);
    SB_NC_RegistExecutor.RegistParam contParam = new SB_NC_RegistExecutor.RegistParam('Contact', true, null, u.Id, false);
    SB_NC_RegistExecutor.TodoParam todoParam = new SB_NC_RegistExecutor.TodoParam('件名:名刺交換', Date.today(), 'ToDoのコメント', u.Id);
    SB_NC_RegistExecutor.RegistRequest req = new SB_NC_RegistExecutor.RegistRequest(targets, acntParam, contParam, null, todoParam);
    //　実行
    SB_NC_RegistExecutor.RegistResponse res = SB_NC_RegistExecutor.doRegist(req);
    //　結果確認
    System.assert(res.success);
    System.assertEquals(2, res.registeds.size());
    for (Id cardId : res.registeds.keySet()) {
      SB_NC_RegistExecutor.RegistedSummary rs = res.registeds.get(cardId);
      System.debug(rs.acnt.id + ': ' + rs.acnt.name);
      System.debug(rs.cont.id + ': ' + rs.cont.name);
      System.debug(rs.todo.id + ': ' + rs.todo.name);
    }
    // 追加の確認 New Account new Contact
    //  親アカウントIDも条件で検索
    List<Contact> conts = [SELECT Id, Name, AccountId, Account.ParentId FROM Contact WHERE Account.Name Like '追加%' AND Account.ParentId=:acnt.Id];
    System.assertEquals(2, conts.size());   // 2つある
    Map<Id, NameCard__c> id2card = new Map<Id, NameCard__c>([SELECT Id, Name, account__c, contact__c FROM NameCard__c WHERE company_name__c LIKE '追加%']);
    for(Id cardId : id2card.keySet()) {
      NameCard__c nc = id2card.get(cardId);
      System.assertEquals(nc.account__c, res.registeds.get(cardId).acnt.Id);     // refernce to account eq. res
      System.assertEquals(nc.contact__c, res.registeds.get(cardId).cont.Id);     // refernce to contact eq. res
    }
    Test.stopTest();
  }

  // SV_DEV-1644 取引先・取引先責任者に登録(更新時)のToDo任命先を名刺の所有者にする
  @isTest
  static void test_complex_todo_owner_contact_owner_default() {
    TestDb db = new TestDb();
    db.initialize();
    db.appendNameCard();

    Test.startTest();
    User u = db.listUser[0];
    Contact cont = [SELECT Id, Name, LastName, FirstName, AccountId FROM Contact  LIMIT 1];
    Account acnt = [SELECT Id, Name FROM Account WHERE Id=:cont.AccountId LIMIT 1];
    NameCard__c card = [SELECT Id, Name, company_name__c FROM NameCard__c WHERE company_name__c=:acnt.Name
           AND person_name_first__c=:cont.FirstName AND person_name_last__c=:cont.LastName LIMIT 1];

    List<NameCard__c> cards = [SELECT Id, Name FROM NameCard__c WHERE company_name__c LIKE '追加%'];
    System.assert(cards.size() == 2);
    // リクエストパラメータの作成
    List<SB_NC_RegistExecutor.RegistTarget> targets = new List<SB_NC_RegistExecutor.RegistTarget>();
    targets.add(new SB_NC_RegistExecutor.RegistTarget(card.Id, acnt.Id, cont.Id, null, true, null));    // 既存
    targets.add(new SB_NC_RegistExecutor.RegistTarget(cards[0].Id, null, null, null, true, null));  //　新規
    targets.add(new SB_NC_RegistExecutor.RegistTarget(cards[1].Id, null, null, null, true, null));  //　新規
    SB_NC_RegistExecutor.RegistParam acntParam = new SB_NC_RegistExecutor.RegistParam('Account', true, null, u.Id, false);
    SB_NC_RegistExecutor.RegistParam contParam = new SB_NC_RegistExecutor.RegistParam('Contact', true, null, u.Id, false);
    SB_NC_RegistExecutor.TodoParam todoParam = new SB_NC_RegistExecutor.TodoParam('件名:名刺交換', Date.today(), 'ToDoのコメント', null);
    SB_NC_RegistExecutor.RegistRequest req = new SB_NC_RegistExecutor.RegistRequest(targets, acntParam, contParam, null, todoParam);
    //　実行
    SB_NC_RegistExecutor.RegistResponse res = SB_NC_RegistExecutor.doRegist(req);
    //　結果確認
    List<Task> tasks = [SELECT Id, Subject, WhatId, WhoId, OwnerId FROM Task WHERE Subject='件名:名刺交換'];
    System.assertEquals(3, tasks.size());
    for (Task t : tasks) {
      System.assertEquals([SELECT Id, OwnerId FROM Contact WHERE Id = :t.WhoId LIMIT 1].OwnerId, t.OwnerId);
    }
    Test.stopTest();
  }

  // SV_DEV-1644 取引先・取引先責任者に登録(更新時)のToDo任命先を名刺の所有者にする
  @isTest
  static void test_complex_todo_owner_contact_owner_setting() {
    TestDb db = new TestDb();
    db.initialize();
    db.appendNameCard();
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    setting.RegistToDoOwner__c = 'ContactOwner';
    insert setting;

    Test.startTest();
    User u = db.listUser[0];
    Contact cont = [SELECT Id, Name, LastName, FirstName, AccountId FROM Contact  LIMIT 1];
    Account acnt = [SELECT Id, Name FROM Account WHERE Id=:cont.AccountId LIMIT 1];
    NameCard__c card = [SELECT Id, Name, company_name__c FROM NameCard__c WHERE company_name__c=:acnt.Name
           AND person_name_first__c=:cont.FirstName AND person_name_last__c=:cont.LastName LIMIT 1];

    List<NameCard__c> cards = [SELECT Id, Name FROM NameCard__c WHERE company_name__c LIKE '追加%'];
    System.assert(cards.size() == 2);
    // リクエストパラメータの作成
    List<SB_NC_RegistExecutor.RegistTarget> targets = new List<SB_NC_RegistExecutor.RegistTarget>();
    targets.add(new SB_NC_RegistExecutor.RegistTarget(card.Id, acnt.Id, cont.Id, null, true, null));    // 既存
    targets.add(new SB_NC_RegistExecutor.RegistTarget(cards[0].Id, null, null, null, true, null));  //　新規
    targets.add(new SB_NC_RegistExecutor.RegistTarget(cards[1].Id, null, null, null, true, null));  //　新規
    SB_NC_RegistExecutor.RegistParam acntParam = new SB_NC_RegistExecutor.RegistParam('Account', true, null, u.Id, false);
    SB_NC_RegistExecutor.RegistParam contParam = new SB_NC_RegistExecutor.RegistParam('Contact', true, null, u.Id, false);
    SB_NC_RegistExecutor.TodoParam todoParam = new SB_NC_RegistExecutor.TodoParam('件名:名刺交換', Date.today(), 'ToDoのコメント', null);
    SB_NC_RegistExecutor.RegistRequest req = new SB_NC_RegistExecutor.RegistRequest(targets, acntParam, contParam, null, todoParam);
    //　実行
    SB_NC_RegistExecutor.RegistResponse res = SB_NC_RegistExecutor.doRegist(req);
    //　結果確認
    List<Task> tasks = [SELECT Id, Subject, WhatId, WhoId, OwnerId FROM Task WHERE Subject='件名:名刺交換'];
    System.assertEquals(3, tasks.size());
    for (Task t : tasks) {
      System.assertEquals([SELECT Id, OwnerId FROM Contact WHERE Id = :t.WhoId LIMIT 1].OwnerId, t.OwnerId);
    }
    Test.stopTest();
  }

  // SV_DEV-1644 取引先・取引先責任者に登録(更新時)のToDo任命先を名刺の所有者にする
  @isTest
  static void test_complex_todo_owner_card_owner() {
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    setting.RegistToDoOwner__c = 'NameCardOwner';
    insert setting;

    TestDb db = new TestDb();
    db.initialize();
    db.appendNameCard();

    Test.startTest();
    User u = db.listUser[0];
    Contact cont = [SELECT Id, Name, LastName, FirstName, AccountId FROM Contact  LIMIT 1];
    Account acnt = [SELECT Id, Name FROM Account WHERE Id=:cont.AccountId LIMIT 1];
    NameCard__c card = [SELECT Id, Name, company_name__c FROM NameCard__c WHERE company_name__c=:acnt.Name
           AND person_name_first__c=:cont.FirstName AND person_name_last__c=:cont.LastName LIMIT 1];

    List<NameCard__c> cards = [SELECT Id, Name FROM NameCard__c WHERE company_name__c LIKE '追加%'];
    System.assert(cards.size() == 2);
    // リクエストパラメータの作成
    List<SB_NC_RegistExecutor.RegistTarget> targets = new List<SB_NC_RegistExecutor.RegistTarget>();
    targets.add(new SB_NC_RegistExecutor.RegistTarget(card.Id, acnt.Id, cont.Id, null, true, null));    // 既存
    targets.add(new SB_NC_RegistExecutor.RegistTarget(cards[0].Id, null, null, null, true, null));  //　新規
    targets.add(new SB_NC_RegistExecutor.RegistTarget(cards[1].Id, null, null, null, true, null));  //　新規
    SB_NC_RegistExecutor.RegistParam acntParam = new SB_NC_RegistExecutor.RegistParam('Account', true, null, u.Id, false);
    SB_NC_RegistExecutor.RegistParam contParam = new SB_NC_RegistExecutor.RegistParam('Contact', true, null, u.Id, false);
    SB_NC_RegistExecutor.TodoParam todoParam = new SB_NC_RegistExecutor.TodoParam('件名:名刺交換', Date.today(), 'ToDoのコメント', null);
    SB_NC_RegistExecutor.RegistRequest req = new SB_NC_RegistExecutor.RegistRequest(targets, acntParam, contParam, null, todoParam);
    //　実行
    SB_NC_RegistExecutor.RegistResponse res = SB_NC_RegistExecutor.doRegist(req);
    //　結果確認
    List<Task> tasks = [SELECT Id, Subject, WhatId, WhoId, OwnerId FROM Task WHERE Subject='件名:名刺交換'];
    System.assertEquals(3, tasks.size());
    for (Task t : tasks) {
      System.assertEquals([SELECT Id, OwnerId FROM NameCard__c WHERE account__c = :t.WhatId LIMIT 1].OwnerId, t.OwnerId);
    }
    Test.stopTest();
  }

  // 2019.07.xx v2.4 複数名刺項目から 連携先項目合成対応 SV_DEV-395 医療法人のデータ納品について
  @isTest
  static void test_create_new_Account_orgNameWithDept() {
    TestDb db = new TestDb();
    db.initialize();
    db.appendNameCard();

    Test.startTest();
    User u = db.listUser[0];
    // Contact cont = [SELECT Id, Name, LastName, FirstName, AccountId FROM Contact  LIMIT 1];
    Account acnt = [SELECT Id, Name FROM Account LIMIT 1];

    List<NameCard__c> cards = [SELECT Id, Name, company_name__c, division__c FROM NameCard__c WHERE company_name__c LIKE '追加%'];
    System.assert(cards.size() == 2);
    // リクエストパラメータの作成
    List<SB_NC_RegistExecutor.RegistTarget> targets = new List<SB_NC_RegistExecutor.RegistTarget>();
    targets.add(new SB_NC_RegistExecutor.RegistTarget(cards[0].Id, null, null, null, true, null, false));    // 新規
    targets.add(new SB_NC_RegistExecutor.RegistTarget(cards[1].Id, null, null, null, true, null, false));    // 新規
    SB_NC_RegistExecutor.RegistParam acntParam = new SB_NC_RegistExecutor.RegistParam('Account', true, null, u.Id, false, true);
    SB_NC_RegistExecutor.RegistParam contParam = new SB_NC_RegistExecutor.RegistParam('Contact', true, null, u.Id, false, true);
    SB_NC_RegistExecutor.TodoParam todoParam = new SB_NC_RegistExecutor.TodoParam('件名:名刺交換', Date.today(), 'ToDoのコメント', u.Id);
    SB_NC_RegistExecutor.RegistRequest req = new SB_NC_RegistExecutor.RegistRequest(targets, acntParam, contParam, null, todoParam);
    //　実行
    SB_NC_RegistExecutor.RegistResponse res = SB_NC_RegistExecutor.doRegist(req);
    //　結果確認
    System.assert(res.success);
    System.assertEquals(2, res.registeds.size());
    for (Id cardId : res.registeds.keySet()) {
      SB_NC_RegistExecutor.RegistedSummary rs = res.registeds.get(cardId);
      System.debug(rs.acnt.id + ': ' + rs.acnt.name);
      System.debug(rs.cont.id + ': ' + rs.cont.name);
      System.debug(rs.todo.id + ': ' + rs.todo.name);
    }
    // アカウント Name は結合してる
    System.assertEquals(cards[0].company_name__c + ' ' + cards[0].division__c,  [SELECT Id, Name, Site, NameCard__c FROM Account WHERE NameCard__c = :cards[0].Id].Name);
    System.assertEquals(cards[1].company_name__c + ' ' + cards[1].division__c,  [SELECT Id, Name, Site, NameCard__c FROM Account WHERE NameCard__c = :cards[1].Id].Name);
    // アカウント 部門  は NULL
    System.assertEquals(null,  [SELECT Id, Name, Site, NameCard__c FROM Account WHERE NameCard__c = :cards[0].Id].Site);
    System.assertEquals(null,  [SELECT Id, Name, Site, NameCard__c FROM Account WHERE NameCard__c = :cards[1].Id].Site);
    // コンタクト 部署はNULL
    System.assertEquals(null,  [SELECT Id, Name, Department, NameCard__c FROM Contact WHERE NameCard__c = :cards[0].Id].Department);
    System.assertEquals(null,  [SELECT Id, Name, Department, NameCard__c FROM Contact WHERE NameCard__c = :cards[1].Id].Department);

    Test.stopTest();
  }

  // 2019.07.xx v2.4 複数名刺項目から 連携先項目合成対応 SV_DEV-395 医療法人のデータ納品について
  @isTest
  static void test_create_new_Account_No_orgNameWithDept() {
    TestDb db = new TestDb();
    db.initialize();
    db.appendNameCard();

    Test.startTest();
    User u = db.listUser[0];
    // Contact cont = [SELECT Id, Name, LastName, FirstName, AccountId FROM Contact  LIMIT 1];
    Account acnt = [SELECT Id, Name FROM Account LIMIT 1];

    List<NameCard__c> cards = [SELECT Id, Name, company_name__c, division__c FROM NameCard__c WHERE company_name__c LIKE '追加%'];
    System.assert(cards.size() == 2);
    // リクエストパラメータの作成
    List<SB_NC_RegistExecutor.RegistTarget> targets = new List<SB_NC_RegistExecutor.RegistTarget>();
    targets.add(new SB_NC_RegistExecutor.RegistTarget(cards[0].Id, null, null, null, true, null, false));    // 新規
    targets.add(new SB_NC_RegistExecutor.RegistTarget(cards[1].Id, null, null, null, true, null, false));    // 新規
    SB_NC_RegistExecutor.RegistParam acntParam = new SB_NC_RegistExecutor.RegistParam('Account', true, null, u.Id, false, false);
    SB_NC_RegistExecutor.RegistParam contParam = new SB_NC_RegistExecutor.RegistParam('Contact', true, null, u.Id, false, false);
    SB_NC_RegistExecutor.TodoParam todoParam = new SB_NC_RegistExecutor.TodoParam('件名:名刺交換', Date.today(), 'ToDoのコメント', u.Id);
    SB_NC_RegistExecutor.RegistRequest req = new SB_NC_RegistExecutor.RegistRequest(targets, acntParam, contParam, null, todoParam);
    //　実行
    SB_NC_RegistExecutor.RegistResponse res = SB_NC_RegistExecutor.doRegist(req);
    //　結果確認
    System.assert(res.success);
    System.assertEquals(2, res.registeds.size());
    for (Id cardId : res.registeds.keySet()) {
      SB_NC_RegistExecutor.RegistedSummary rs = res.registeds.get(cardId);
      System.debug(rs.acnt.id + ': ' + rs.acnt.name);
      System.debug(rs.cont.id + ': ' + rs.cont.name);
      System.debug(rs.todo.id + ': ' + rs.todo.name);
    }
    // アカウント Name は結合してない
    System.assertEquals(cards[0].company_name__c,  [SELECT Id, Name, Site, NameCard__c FROM Account WHERE NameCard__c = :cards[0].Id].Name);
    System.assertEquals(cards[1].company_name__c,  [SELECT Id, Name, Site, NameCard__c FROM Account WHERE NameCard__c = :cards[1].Id].Name);
    // アカウント 部門  は 名刺の所属
    System.assertEquals(cards[0].division__c,  [SELECT Id, Name, Site, NameCard__c FROM Account WHERE NameCard__c = :cards[0].Id].Site);
    System.assertEquals(cards[1].division__c,  [SELECT Id, Name, Site, NameCard__c FROM Account WHERE NameCard__c = :cards[1].Id].Site);
    // コンタクト 部署は 名刺の所属
    System.assertEquals(cards[0].division__c,  [SELECT Id, Name, Department, NameCard__c FROM Contact WHERE NameCard__c = :cards[0].Id].Department);
    System.assertEquals(cards[1].division__c,  [SELECT Id, Name, Department, NameCard__c FROM Contact WHERE NameCard__c = :cards[1].Id].Department);

    Test.stopTest();
  }  

  // SV_DEV-1742 取引先・取引先責任者に登録の上書きで取責の所有者が無効なユーザである場合、Todo登録をエラーにしないでほしい 個別登録改修
  @isTest
  static void test_regist_cerate_todo_inactive_user() {
    Profile prof = [SELECT Id, UserType, Name FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
    User u1 = new User(Alias = 'test', Email='newusertest@testorgtest.com',
    EmailEncodingKey='UTF-8', LastName='Testingtest', LanguageLocaleKey='en_US',
    LocaleSidKey='en_US', ProfileId = prof.Id,UserPermissionsMarketingUser = true,
    TimeZoneSidKey='America/Los_Angeles', UserName='newusertesttest@testorgtestA.com');
    insert u1;

    list<PermissionSet> psList = [SELECT Id FROM PermissionSet WHERE Name IN ('SmartViscaAdminUser','SmartViscaAdvancedUser','SmartViscaRenkeiUser','SmartViscaUser')];
    PermissionSetAssignment psa1 = new PermissionSetAssignment(AssigneeId = u1.id, PermissionSetId = psList[0].Id);
    PermissionSetAssignment psa2 = new PermissionSetAssignment(AssigneeId = u1.id, PermissionSetId = psList[1].Id);
    PermissionSetAssignment psa3 = new PermissionSetAssignment(AssigneeId = u1.id, PermissionSetId = psList[2].Id);
    PermissionSetAssignment psa4 = new PermissionSetAssignment(AssigneeId = u1.id, PermissionSetId = psList[3].Id);
    insert new PermissionSetAssignment[]{psa1,psa2,psa3,psa4};

    System.runAs(u1) {
      TestDb db = new TestDb();
      db.initialize();
      db.appendNameCard();

      Test.startTest();
      // 無効ユーザ
      User u = [SELECT Id, Name, UserName, IsActive FROM User WHERE IsActive = false LIMIT 1];
      // Contact cont = [SELECT Id, Name, LastName, FirstName, AccountId FROM Contact  LIMIT 1];
      Account acnt = [SELECT Id, Name FROM Account LIMIT 1];

      List<NameCard__c> cards = [SELECT Id, Name, company_name__c, division__c FROM NameCard__c WHERE company_name__c LIKE '追加%'];
      System.assert(cards.size() == 2);
      // リクエストパラメータの作成
      List<SB_NC_RegistExecutor.RegistTarget> targets = new List<SB_NC_RegistExecutor.RegistTarget>();
      targets.add(new SB_NC_RegistExecutor.RegistTarget(cards[0].Id, null, null, null, true, null, false));    // 新規
      targets.add(new SB_NC_RegistExecutor.RegistTarget(cards[1].Id, null, null, null, true, null, false));    // 新規
      SB_NC_RegistExecutor.RegistParam acntParam = new SB_NC_RegistExecutor.RegistParam('Account', true, null, null, false, false);
      SB_NC_RegistExecutor.RegistParam contParam = new SB_NC_RegistExecutor.RegistParam('Contact', true, null, null, false, false);
      // ToDoの任命先を無効なユーザを指定
      SB_NC_RegistExecutor.TodoParam todoParam = new SB_NC_RegistExecutor.TodoParam('件名:名刺交換', Date.today(), 'ToDoのコメント', u.Id);
      SB_NC_RegistExecutor.RegistRequest req = new SB_NC_RegistExecutor.RegistRequest(targets, acntParam, contParam, null, todoParam);
      //　実行
      SB_NC_RegistExecutor.RegistResponse res = SB_NC_RegistExecutor.doRegist(req);
      //　結果確認
      //  ToDo 任命先ユーザが無効ユーザなので、失敗
      System.assertEquals(false, res.success);
      System.assertEquals(String.format(System.Label.SB_NC_MSG_CanNotSetInActiveUserToOwnerToDo, new String[] { u.Name }), res.message);
      Test.stopTest();
    }
  }    
}