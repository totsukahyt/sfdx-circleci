/**
 *
 * 名刺のトリガで呼んでる SB_SmartVisca_CreateFeedOnNameCard のテストクラス
 *      従来 SB_NameCard_FeedTriggerTest.cls でやってたテストの移植
 *
 * Copyright (C) 2012-2015 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  History :
 *      SB_NameCard_FeedTriggerTest.cls の移植というか置換
 *  @Version 2      2014.4.2x
 **/
@isTest
private class SB_NameCard_CreateFeedOnNameCardTest {

  public class CreateFeedOnNameCardTestDb extends SB_NameCard_TestDB {

    // 同一トランザクションで、一回しかマージ処理しないので、最初から２次納品でInsertする。
    public override void initializeNameCard() {
      for (Employee emp :listEmp) {
        // 所有者の異なる名刺を作成
        for (User u : listUser) {
          NameCard__c c = createNameCard(emp, u);
          c.delivery_type__c = '2';           // ２次納品で
          listCard.add(c);
        }
      }
    }

    // SmartVisca設定 OFFにする。
    public override void initializeSmartViscaConfig() {
      svConfig = SmartViscaConfig__c.getOrgDefaults();
      svConfig.TriggerRegDateTime__c = false;
      svConfig.TriggerCreateFeedOnName__c = false;
      svConfig.TriggerMergeNameCards__c = false;
    }

    public Set<String> getCardIds() {
      Set<String> ids = new Set<String>();
      for(NameCard__c c : listCard) {
        ids.add(c.Id);
      }
      return ids;
    }

    public override void initialize() {
      // SmartVisca設定
      super.initializeSmartViscaConfig();
      if (svConfig !=null) {
        upsert svConfig;
      }
      // ユーザ
      initializeUser();
      if (listUser.isEmpty() == false) {
        insert listUser;
      }
      // 名刺
      initializeKaisha();     // 会社を揃えておく
      initializeEmployee();   // 会社ごとに名刺の人を揃えておく
      initializeNameCard();
      if (listCard.isEmpty() == false) {
        insert listCard;
      }
    }

    public void initializeConfigOff() {
      // SmartVisca設定
      initializeSmartViscaConfig();
      if (svConfig !=null) {
        upsert svConfig;
      }
      // ユーザ
      initializeUser();
      if (listUser.isEmpty() == false) {
        insert listUser;
      }
      // 名刺
      initializeKaisha();     // 会社を揃えておく
      initializeEmployee();   // 会社ごとに名刺の人を揃えておく
      initializeNameCard();
      if (listCard.isEmpty() == false) {
        insert listCard;
      }
    }

    public void cardExchange(String s) {
      //if (listEmp.size() > 0 && listUser.size() > 0) {
      //  NameCard__c c = createNameCard(listEmp[0], listUser[0]);
      //  c.division__c = 'testChange';
      //  c.delivery_type__c = '2';     // ２次納品で
      //  insert c;
      //}
      List<NameCard__c> ls = new List<NameCard__c>();
      for (Employee emp :listEmp) {
        // 所有者の異なる名刺を作成
        for (User u : listUser) {
          NameCard__c c = createNameCard(emp, u);
          c.division__c = s;
          c.delivery_type__c = '2';     // ２次納品で
          ls.add(c);
        }
      }
      insert ls;
    }

  }

  // フィードが発行されることをテスト
  private static testMethod void testCreateFeedOnNameCard() {
    Test.startTest();
    CreateFeedOnNameCardTestDb db = new CreateFeedOnNameCardTestDb();
    db.initialize();

    Set<String> cardIds = db.getCardIds();
    system.debug('_cardIds.size:' + cardIds.size());
    system.debug('_cardIds:' + cardIds);
    String query = 'SELECT Id, ParentId from FeedItem where ParentId IN :cardIds';
    system.debug('_feeds:' + Database.query(query));
    list<sObject> feeds = SB_NameCard_CreateFeedOnNameCard.enableFeedItem ? Database.query(query) : new list<sObject>();
    if (SB_NameCard_CreateFeedOnNameCard.enableFeedItem == true) {
      system.assertEquals(db.listCard.size()-SB_NameCard_TestDB.CNT_COMPANY*SB_NameCard_TestDB.CNT_EMPLOYEE, feeds.size()); // 同じ名刺で、１つ以外にフィードを発行してる。
      db.cardExchange('test1');
      db.cardExchange('test2');
      db.cardExchange('test3');
      feeds = SB_NameCard_CreateFeedOnNameCard.enableFeedItem ? Database.query(query) : new list<sObject>();
      system.assertEquals(db.listCard.size()-SB_NameCard_TestDB.CNT_COMPANY*SB_NameCard_TestDB.CNT_EMPLOYEE, feeds.size()); // 同じ名刺で、１つ以外にフィードを発行してる。
    }
    else {
      system.assertEquals(0, feeds.size());   // フィードを発行してない。
    }
    Test.stopTest();
  }

  // 設定をオフにして、フィードが発行されないことをテスト
  private static testMethod void testCreateFeedOnNameCardOff() {
    Test.startTest();
    CreateFeedOnNameCardTestDb db = new CreateFeedOnNameCardTestDb();
    db.initializeConfigOff();

    //      list<FeedItem> feeds = [SELECT Id, ParentId from FeedItem where ParentId IN :db.listCard];
    Set<String> cardIds = db.getCardIds();
    String query = 'SELECT Id, ParentId from FeedItem where ParentId IN :cardIds';
    list<sObject> feeds = SB_NameCard_CreateFeedOnNameCard.enableFeedItem ? Database.query(query) : new list<sObject>();
    system.assertEquals(0, feeds.size());   // フィードを発行してない。

    Test.stopTest();
  }

  // フィードが発行されることをテスト Feedオフなら、トリガで終わってるので、直接ハンドラを読んでコードカバー率をあげるけ
  private static testMethod void testCreateFeedOnNameCardHandler() {
    Test.startTest();
    CreateFeedOnNameCardTestDb db = new CreateFeedOnNameCardTestDb();
    db.initializeConfigOff();

    map<Id, NameCard__c> mapCard = new map<Id, NameCard__c>([SELECT Id, Name, parent__c FROM NameCard__c]);
    list<NameCard__c> cards = [SELECT Id, Name, parent__c FROM NameCard__c];
    cards[0].parent__c= cards[cards.size()-1].parent__c;
    for (NameCard__c c : cards) {
      c.delivery_type__c = '2';
    }

    SB_NameCard_CreateFeedOnNameCard handler = new SB_NameCard_CreateFeedOnNameCard();
    handler.run(cards, mapCard);
    Set<String> cardIds = db.getCardIds();
    String query = 'SELECT Id, ParentId from FeedItem where ParentId IN :cardIds';
    list<sObject> feeds = SB_NameCard_CreateFeedOnNameCard.enableFeedItem ? Database.query(query) : new list<sObject>();
    system.assertEquals(0, feeds.size());   // フィードを発行してない。
    Test.stopTest();
  }


/*
    従来のコード
  static testMethod void myUnitTest() {

    Integer FeedSizeBf;
    Integer FeedSizeAf;

    // 取引先作成
    Account a = new Account(Name='TestAccount1');
    insert a;

    // 取引先責任者作成
    Contact c = new Contact(LastName='TestContact1', FirstName='foo', AccountId=a.Id);
    insert c;

    // リード作成
    Lead l = new Lead(LastName='TestLead1', firstName='foo', Company='Test');
    insert l;

    // 名刺作成
    NameCard__c nc = new NameCard__c(Name='Test Test', company_name__c='Test', person_name_last__c='Test', person_name_first__c='Test', delivery_type__c='1');
    insert nc;

    // リード、取引先、取引先責任者に登録
    nc.account__c = a.Id;
    nc.contact__c = c.Id;
    nc.accountRegDateTime__c = Datetime.now();
    Test.startTest();
    update nc;
    nc.delivery_type__c = '2';
    update nc;
    nc.leadRegDateTime__c = Datetime.now();
    nc.lead__c = l.Id;
    update nc;
    nc.delivery_type__c = '1';
    update nc;
    nc.delivery_type__c = '2';
    update nc;
    Test.stopTest();
  }
*/
}