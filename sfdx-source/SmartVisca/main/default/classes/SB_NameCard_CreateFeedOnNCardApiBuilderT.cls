/**
 *
 * SB_NameCard_CreateFeedOnNCardApiBuilderT
 *    SB_NameCard_CreateFeedOnNCardApiBuilder のテストクラス
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  History :
 *  @Version 1 v 2.4    2019.07.xx  初版
 *
 **/
@isTest
private class SB_NameCard_CreateFeedOnNCardApiBuilderT {
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

    public override void initializeSmartViscaConfig() {
      svConfig = SmartViscaConfig__c.getOrgDefaults();
      svConfig.TriggerRegDateTime__c = true;
      svConfig.TriggerCreateFeedOnName__c = true;
      svConfig.TriggerMergeNameCards__c = true;
      // svConfig.TriggerHistoryIsActive__c = true;
      svConfig.FeedOnNameCardMentionToOwners__c = true;  // 同じ人と名刺交換したフィードを名刺所有者にメンションする
      svConfig.FeedOnNameCardMentionToGroups__c = '名刺交換共有グループ\nその他のグループ'; // 同じ人と名刺交換したフィードをメンションするグループ
      svConfig.FeedOnNameCardTopic__c = '最新の名刺ですよ {0}{1}{2}';
    }

    // SmartVisca設定 OFFにする。
    public void initializeSmartViscaConfig_Off() {
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

    // public void initializeConfigOff() {
    //   // SmartVisca設定
    //   initializeSmartViscaConfig();
    //   if (svConfig !=null) {
    //     upsert svConfig;
    //   }
    //   // ユーザ
    //   initializeUser();
    //   if (listUser.isEmpty() == false) {
    //     insert listUser;
    //   }
    //   // 名刺
    //   initializeKaisha();     // 会社を揃えておく
    //   initializeEmployee();   // 会社ごとに名刺の人を揃えておく
    //   initializeNameCard();
    //   if (listCard.isEmpty() == false) {
    //     insert listCard;
    //   }
    // }

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
  // 旧版とほぼ同じ内容
  @IsTest(SeeAllData=true)
  private static void testCreateFeedOnNameCard() {
    Test.startTest();
    CreateFeedOnNameCardTestDb db = new CreateFeedOnNameCardTestDb();
    db.initialize();

    List<SObject> listGroup = new List<SObject>();
    SObject chatterGroup = Schema.getGlobalDescribe().get('CollaborationGroup').newSObject();
    chatterGroup.put('Name', '名刺交換共有グループ');
    chatterGroup.put('CollaborationType', 'Public');
    listGroup.add(chatterGroup);
    insert listGroup;

    Set<String> cardIds = db.getCardIds();
    system.debug('_cardIds.size:' + cardIds.size());
    system.debug('_cardIds:' + cardIds);
    String query = 'SELECT Id, ParentId from FeedItem where ParentId IN :cardIds';
    system.debug('_feeds:' + Database.query(query));
    list<sObject> feeds = SB_NameCard_CreateFeedOnNameCardFactory.enableFeedItem ? Database.query(query) : new list<sObject>();
    if (SB_NameCard_CreateFeedOnNameCardFactory.enableFeedItem == true) {
      system.assertEquals(db.listCard.size()-SB_NameCard_TestDB.CNT_COMPANY*SB_NameCard_TestDB.CNT_EMPLOYEE, feeds.size()); // 同じ名刺で、１つ以外にフィードを発行してる。
      db.cardExchange('test1');
      db.cardExchange('test2');
      db.cardExchange('test3');
      feeds = SB_NameCard_CreateFeedOnNameCardFactory.enableFeedItem ? Database.query(query) : new list<sObject>();
      system.assertEquals(db.listCard.size()-SB_NameCard_TestDB.CNT_COMPANY*SB_NameCard_TestDB.CNT_EMPLOYEE, feeds.size()); // 同じ名刺で、１つ以外にフィードを発行してる。
    }
    else {
      system.assertEquals(0, feeds.size());   // フィードを発行してない。
    }
    Test.stopTest();
  }

  @IsTest
  private static void test_getPositionChangeFormat() {
    SB_NameCard_CreateFeedOnNCardApiBuilder builder = new SB_NameCard_CreateFeedOnNCardApiBuilder();
    String out_in = builder.getPositionChangeFormat(null, '新部署新役職');
    System.assert(out_in.contains(System.Label.SB_NC_ExchangedToo4));
    String in_out = builder.getPositionChangeFormat('旧部署旧役職', null);
    System.assert(in_out.contains(System.Label.SB_NC_SETTING_LABEL_NONE));
    String in_in = builder.getPositionChangeFormat('旧部署旧役職', '新部署新役職');
    System.assert(in_in.contains(System.Label.SB_NC_ExchangedToo3));
  }

  // // フィードが発行されることをテスト Feedオフなら、トリガで終わってるので、直接ハンドラを読んでコードカバー率をあげるけ
  // private static testMethod void testCreateFeedOnNameCardHandler() {
  //   Test.startTest();
  //   CreateFeedOnNameCardTestDb db = new CreateFeedOnNameCardTestDb();
  //   db.initializeConfigOff();

  //   map<Id, NameCard__c> mapCard = new map<Id, NameCard__c>([SELECT Id, Name, parent__c FROM NameCard__c]);
  //   list<NameCard__c> cards = [SELECT Id, Name, parent__c FROM NameCard__c];
  //   cards[0].parent__c= cards[cards.size()-1].parent__c;
  //   for (NameCard__c c : cards) {
  //     c.delivery_type__c = '2';
  //   }

  //   SB_NameCard_CreateFeedOnNameCard handler = new SB_NameCard_CreateFeedOnNameCard();
  //   handler.run(cards, mapCard);
  //   Set<String> cardIds = db.getCardIds();
  //   String query = 'SELECT Id, ParentId from FeedItem where ParentId IN :cardIds';
  //   list<sObject> feeds = SB_NameCard_CreateFeedOnNameCard.enableFeedItem ? Database.query(query) : new list<sObject>();
  //   system.assertEquals(0, feeds.size());   // フィードを発行してない。
  //   Test.stopTest();
  // }



  // private class TestDB extends SB_NC_TestDB {

  //   public override void initializeSmartViscaConfig() {
  //     svConfig = SmartViscaConfig__c.getOrgDefaults();
  //     svConfig.TriggerRegDateTime__c = true;
  //     svConfig.TriggerCreateFeedOnName__c = true;
  //     svConfig.TriggerMergeNameCards__c = true;
  //     // svConfig.TriggerHistoryIsActive__c = true;
  //     svConfig.FeedOnNameCardMentionToOwners__c = true;  // 同じ人と名刺交換したフィードを名刺所有者にメンションする
  //     svConfig.FeedOnNameCardMentionToGroups__c = '名刺交換共有グループ\nその他のグループ'; // 同じ人と名刺交換したフィードをメンションするグループ
  //     svConfig.FeedOnNameCardTopic__c = '最新の名刺ですよ {0}{1}{2}';
  //   }


  //   // 名刺データ作成
  //   public override void initializeNameCard() {
  //     listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社サンブリッジ', division__c='本社',
  //                   title_name__c='課長',
  //                   zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
  //                   tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
  //                   last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2',
  //                   card_exchange_date__c=Date.today().addDays(-10), OwnerId=getUserId(1)));
  //   }

  //   public Id getUserId(Integer index) {
  //     return listUser.get(index).Id;
  //   }

  //   public Set<Id> getCardIds() {
  //     Map<Id, NameCard__c> id2card = new Map<Id, NameCard__c>(listCard);
  //     return id2card.keySet();
  //   }

  //   public override void initialize() {
  //     // SmartVisca設定
  //     initializeSmartViscaConfig();
  //     if (svConfig !=null) {
  //      upsert svConfig;
  //     }
  //     //　ユーザ作成
  //     initializeUser();
  //     if (!listUser.isEmpty()) {
  //       insert listUser;
  //     }
  //     // 名刺作成
  //     initializeNameCard();
  //     if (!listCard.isEmpty()) {
  //       insert listCard;
  //     }
  //   }
  // }

  // @isTest(SeeAllData=true)
  // static void test_run() {
  //   Test.startTest();
  //   TestDB db = new TestDB();
  //   db.initialize();

  //   List<NameCard__c> listCard = new List<NameCard__c>();
  //   listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社サンブリッジ', division__c='本社',
  //                   title_name__c='部長',
  //                   zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
  //                   tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
  //                   last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2',
  //                   card_exchange_date__c=Date.today(), OwnerId=db.getUserId(1)));
  //   insert listCard;


  //   Set<Id> cardIds = db.getCardIds();
  //   System.debug([SELECT Id, Name, Parent__c FROM NameCard__c WHERE Parent__c != null AND Name='テスト 太郎']);
  //   System.debug(cardIds);
  //   System.debug(listCard[0].Id);
  //   // System.assertEquals(1, [SELECT Id, Name, Parent__c FROM NameCard__c WHERE Parent__c != null].size());
  //   // System.assert([SELECT Id, Name, Parent__c FROM NameCard__c WHERE Id IN :cardIds][0].Parent__c != null);
  //   // Map<Id, NameCard__c> cards = new Map<Id, NameCard__c>([SELECT Id, Name FROM NameCard__c WHERE Parent__c != null]);
  //   // Set<Id> cardIds = new Set<Id>();
  //   // cardIds.addAll(db.getCardIds());

  //   String query = 'SELECT Id, ParentId from FeedItem where ParentId IN :cardIds';
  //   list<sObject> feeds = SB_NameCard_CreateFeedOnNameCardFactory.enableFeedItem ? Database.query(query) : new list<sObject>();
  //   if (SB_NameCard_CreateFeedOnNameCardFactory.enableFeedItem == true) {
  //     system.assertEquals(cardIds.size(), feeds.size()); // 古い名刺にフィードを発行してる。
  //   }
  //   else {
  //     system.assertEquals(0, feeds.size());   // フィードを発行してない。
  //   }
  //   Test.stopTest();
  // }

}