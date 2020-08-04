/**
 *
 *  SB_NameCardL_RegistHelperTest
 *  SB_NC_RegistExecutorTest の改造
 *    SB_NameCardL_RegistHelper のテストクラス2
 *
 * Copyright (C) 2020 SunBridge Inc. All Rights Reserved.
 *
 *  @author T.OU
 *  @Version 1      2020.07.xx  PRODUCT-31 リードまたは取引先責任者に登録の際、名刺の活動履歴を取引先責任者に引き継ぐ
 *  SB_NameCardL_RegistHelper
 **/
@isTest
private class SB_NameCardL_RegistHelperTest2
{
  public class TestDb extends SB_NCL_TestDB {

    public override void initialize() {
       // ユーザ
      initializeUser();
      if (listUser.isEmpty() == false) {
        insert listUser;
      }

      // 名刺
      SmartViscaf__NameCard__c card = new SmartViscaf__NameCard__c();
      card.Name='追加姓１ 名１';
      card.SmartViscaf__last_name__c='追加姓１';
      card.SmartViscaf__first_name__c='名１';
      card.SmartViscaf__email__c='test1@add1.com';
      card.SmartViscaf__company_name__c='追加会社１';
      insert card;

      // 名刺連携項目マッピング
      initializeMapping();
      if (!listMapping.isEmpty()) {
        insert listMapping;
      }
    }
  }

  // 名刺からアカウント、コンタクト作成
  @isTest
  static void test_doRegist_Account_Create1() {
    TestDb db = new TestDb();
    db.initialize();

    Test.startTest();
    User u = db.listUser[0];
    List<SmartViscaf__NameCard__c> cards = [SELECT Id, Name, OwnerId FROM SmartViscaf__NameCard__c WHERE SmartViscaf__company_name__c LIKE '追加%'];

    // 活動をつける
    Task task = new Task();
    task.Subject=cards[0].Name + 'task'; 
    task.OwnerId=cards[0].OwnerId;
    task.whatId=cards[0].Id;
    insert task;

    // 行動をつける
    Event event = new Event();
    event.Subject=cards[0].Name + 'event';
    event.OwnerId=cards[0].OwnerId;
    event.IsAllDayEvent=true;
    event.ActivityDate=date.today();
    event.whatId=cards[0].Id;
    insert event;

    // リクエストパラメータの作成
    List<SB_NameCardL_RegistHelper.RegistTarget> targets = new List<SB_NameCardL_RegistHelper.RegistTarget>();
    SB_NameCardL_RegistHelper.RegistTarget t1 = new SB_NameCardL_RegistHelper.RegistTarget(SB_NameCardL_RegistHelper.ProcType.ACCOUNT, cards[0].Id, null, null, null, true, null);
    targets.add(t1);
    SB_NameCardL_RegistHelper.RegistParam acntParam = new SB_NameCardL_RegistHelper.RegistParam('Account', true, null, u.Id, false);
    SB_NameCardL_RegistHelper.RegistParam contParam = new SB_NameCardL_RegistHelper.RegistParam('Contact', true, null, u.Id, false);
    SB_NameCardL_RegistHelper.TodoParam todoParam = new SB_NameCardL_RegistHelper.TodoParam('件名:名刺交換', Date.today(), 'ToDoのコメント', u.Id);
    SB_NameCardL_RegistHelper.RegistRequest req = new SB_NameCardL_RegistHelper.RegistRequest(targets, acntParam, contParam, null, todoParam);
    //　実行
    SB_NameCardL_RegistHelper.RegistResponse res = SB_NameCardL_RegistHelper.doRegistEx(req);
    //　結果確認
    List<Account> acnts = [SELECT Id FROM Account WHERE Name Like '追加%'];
    List<Contact> conts = [SELECT Id FROM Contact WHERE AccountId =: acnts[0].Id];
    List<Task> tasks = [SELECT Id, whoId FROM Task WHERE whatId =: cards[0].Id];
    List<Event> events = [SELECT Id, whoId FROM Event WHERE whatId =: cards[0].Id];
    System.assertEquals(conts[0].Id, tasks[0].whoId);
    System.assertEquals(conts[0].Id, events[0].whoId);
    Test.stopTest();
  }

  // 名刺からアカウント作成
  @isTest
  static void test_doRegist_Account_Create2() {
    TestDb db = new TestDb();
    db.initialize();

    Test.startTest();
    User u = db.listUser[0];
    List<SmartViscaf__NameCard__c> cards = [SELECT Id, Name, OwnerId FROM SmartViscaf__NameCard__c WHERE SmartViscaf__company_name__c LIKE '追加%'];

    // 活動をつける
    Task task = new Task();
    task.Subject=cards[0].Name + 'task'; 
    task.OwnerId=cards[0].OwnerId;
    task.whatId=cards[0].Id;
    insert task;

    // 行動をつける
    Event event = new Event();
    event.Subject=cards[0].Name + 'event';
    event.OwnerId=cards[0].OwnerId;
    event.IsAllDayEvent=true;
    event.ActivityDate=date.today();
    event.whatId=cards[0].Id;
    insert event;

    // リクエストパラメータの作成
    List<SB_NameCardL_RegistHelper.RegistTarget> targets = new List<SB_NameCardL_RegistHelper.RegistTarget>();
    SB_NameCardL_RegistHelper.RegistTarget t1 = new SB_NameCardL_RegistHelper.RegistTarget(SB_NameCardL_RegistHelper.ProcType.ACCOUNT, cards[0].Id, null, null, null, true, null);
    targets.add(t1);
    SB_NameCardL_RegistHelper.RegistParam acntParam = new SB_NameCardL_RegistHelper.RegistParam('Account', true, null, u.Id, false);
    SB_NameCardL_RegistHelper.TodoParam todoParam = new SB_NameCardL_RegistHelper.TodoParam('件名:名刺交換', Date.today(), 'ToDoのコメント', u.Id);
    SB_NameCardL_RegistHelper.RegistRequest req = new SB_NameCardL_RegistHelper.RegistRequest(targets, acntParam, null, null, todoParam);
    //　実行
    SB_NameCardL_RegistHelper.RegistResponse res = SB_NameCardL_RegistHelper.doRegistEx(req);
    //　結果確認
    List<Account> acnts = [SELECT Id FROM Account WHERE Name Like '追加%'];
    List<Task> tasks = [SELECT Id, whoId FROM Task WHERE whatId =: cards[0].Id];
    List<Event> events = [SELECT Id, whoId FROM Event WHERE whatId =: cards[0].Id];
    System.assertEquals(null, tasks[0].whoId);
    System.assertEquals(null, events[0].whoId);
    Test.stopTest();
  }
}