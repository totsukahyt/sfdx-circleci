/**
 *
 * Salesforce1対応 SB_NameCard_S2Controller  のテストクラス
 *  SB_NameCard_SControllerTest の流用
 * Copyright (C) 2014 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2014.5.xx
 *  @Version 2      2016.9.xx
 *  @Version 3      2018.03.xx v1.22
 *  @Version 2.1    2018.11.xx
 *  @Version 2.2    2019.03.xx
 *  @Version 2.4    2019.06.xx SV_DEV-1830 要望 SmartViscaアプリでタグの登録エラーの場合、メッセージを表示してほしい の関係で修正
 *  @Version 2.5 2020.03.xx SV_DEV-2528 「リスト名」が全角数字を含む場合に名刺詳細で2つ表示される
 *
 **/
@isTest
private class SB_NameCard_S2ControllerTest {

  private static final String STR_LISTNAME = '名刺のリスト名';   //

  public class SControllerTestDb extends SB_NameCard_TestDB {

    public void updateNameCardGeolocation(Integer num) {
      List<NameCard__c> cards = [select Id, Name, GeoLocation__Longitude__s, GeoLocation__Latitude__s from NameCard__c limit :num];
      for (NameCard__c card : cards) {
        card.GeoLocation__Longitude__s = 139.765092;
        card.GeoLocation__Latitude__s = 35.679841;
      }
      update cards;
    }

    public void updateNameCardAddress() {
      List<NameCard__c> cards = [select Id, Name, address__c from NameCard__c where address__c = null];
      for (NameCard__c card : cards) {
        card.address__c = '渋谷区恵比寿南1-5-5';
      }
      update cards;
    }

    // 名刺のオーナを全部 実行ユーザにする。
    public void updateNameCardOwner() {
      List<NameCard__c> cards = [select Id, Name, OwnerId from NameCard__c];
      for (NameCard__c card : cards) {
        card.OwnerId = UserInfo.getUserId();
      }
      update cards;
    }

    // リスト名をつける。
    public void updateNameCardListName(Integer cntCard) {
      List<NameCard__c> cards = [select Id, Name, list_name__c from NameCard__c limit :cntCard];
      for (NameCard__c card : cards) {
        card.list_name__c = STR_LISTNAME;
      }
      update cards;
    }

    // 2次納品にする。
    public void updateNameCardDeliveryType() {
      List<NameCard__c> cards = [select Id, Name, delivery_type__c from NameCard__c];
      for (NameCard__c card : cards) {
        card.delivery_type__c = '2';
      }
      update cards;
    }

    // 名刺にタグを付ける
/*      public void insertNameCardTag() {
      initializeNameCardTag();
      if (listCardTag.isEmpty() == false)
        insert listCardTag;
    }*/

    //public override void initializeEvent() {
    //  for (NameCard__c card : listCard) {
    //    listEvent.add(new Event(Subject=card.Name + 'event', OwnerId=UserInfo.getUserId()
    //      , IsAllDayEvent=false, ActivityDateTime=Datetime.now().addHours(-1), EndDateTime=Datetime.now()
    //      , whatId=card.Id));
    //  }
    //}

    //public override virtual void initializeTask() {
    //  for (NameCard__c card : listCard) {
    //    listTask.add(new Task(Subject=card.Name + 'task', OwnerId=UserInfo.getUserId()
    //      ,ActivityDate=Date.today(), whatId=card.Id));
    //  }
    //}

    public override void initialize() {
      // SmartVisca設定
      super.initializeSmartViscaConfig();
      if (svConfig !=null) {
        upsert svConfig;
      }
       // ユーザ
      initializeUser();
      if (listUser.isEmpty() == false)
        insert listUser;
      // 名刺関係
      initializeKaisha();     // 会社を揃えておく
      initializeEmployee();   // 会社ごとに名刺の人を揃えておく
      // 名刺
      initializeNameCard();
      if (listCard.isEmpty() == false)
        insert listCard;
      // ToDo
      initializeEvent();
      if (listEvent.isEmpty() == false)
        insert listEvent;
      // 行動
      initializeTask();
      if (listTask.isEmpty() == false)
        insert listTask;
    }
  }

  // getSVConfig のテスト
  @isTest
  static void testGetSVConfig() {
    Test.startTest();
    SControllerTestDb db = new SControllerTestDb();
    db.initialize();

    SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    SB_NameCard_SvConfig config = SB_NameCard_S2Controller.getSVConfig();
    System.assertEquals(svConfig.SEnableNameCardEdit__c, config.sEnableNameCardEdit);
    Test.stopTest();

  }

  // getUserInfo のテスト
  @isTest
  static void testGetUserInfo() {
    Test.startTest();
    SControllerTestDb db = new SControllerTestDb();
    db.initialize();

    User result = SB_NameCard_S2Controller.getUserInfo(db.listUser[0].Id);
    System.assertEquals(db.listUser[0].username.toLowerCase(), result.username.toLowerCase());
    result = SB_NameCard_S2Controller.getUserInfo(UserInfo.getUserId());
    System.assertEquals(UserInfo.getUserId(), result.Id);
    Test.stopTest();
  }

  // getNameCardList のテスト
  @isTest
  static void testGetNameCardList() {
    Test.startTest();
    SControllerTestDb db = new SControllerTestDb();
    db.initialize();
    // 自分の名刺
    List<NameCard__c> cards = [select Id, Name from NameCard__c where OwnerId = :UserInfo.getUserId()];
    List<NameCard__c> results = SB_NameCard_S2Controller.getNameCardList(true);
    System.assertEquals(cards.size(), results.size());
    // みんなの名刺
    cards.clear();
    results.clear();
    cards = [select Id, Name from NameCard__c where OwnerId = :UserInfo.getUserId()];
    results = SB_NameCard_S2Controller.getNameCardList(true);
    System.assertEquals(cards.size(), results.size());
    Test.stopTest();
  }

  // List<NameCard__c> searchNameCards のテスト
  @isTest
  static void testSearchNameCards() {
    Test.startTest();
    SControllerTestDb db = new SControllerTestDb();
    db.initialize();
    SB_NameCard_S2Controller.SearchRequest req = new SB_NameCard_S2Controller.SearchRequest();
    req.setTarget('MineOnly');
    req.setWord('');
    // 自分の名刺
    List<NameCard__c> cards = [select Id, Name from NameCard__c where OwnerId = :UserInfo.getUserId()];
    List<NameCard__c> results = SB_NameCard_S2Controller.searchNameCards(req);
    System.assertEquals(cards.size(), results.size());
    // みんなの名刺
    cards.clear();
    results.clear();
    req.setTarget('All');
    cards = [select Id, Name from NameCard__c];
    results = SB_NameCard_S2Controller.searchNameCards(req);
    System.assertEquals(cards.size(), results.size());
    // SOQL
    results.clear();
    req.setTarget('All');
    req.setWord('Company');
    List<List<NameCard__c>> finds = search.query('FIND {Company} IN ALL FIELDS RETURNING NameCard__c(Id)');
    results = SB_NameCard_S2Controller.searchNameCards(req);
    System.assertEquals(finds[0].size(), results.size());
    // 最近の
/*      2014.05.22 コメント化
    results.clear();
    req.target = 'Recent';
    req.word = '';
    List<RecentlyViewed> vieweds = [SELECT Id from RecentlyViewed where Type='NameCard__c'];   // 変更セットでリリースとするとここでエラー
    results = SB_NameCard_S2Controller.searchNameCards(req);
    System.assertEquals(vieweds.size(), results.size());*/
    Test.stopTest();
  }

  // SearchResponse searchNameCardsEx のテスト
  @isTest
  static void testSearchNameCardsEx() {
    Test.startTest();
    SControllerTestDb db = new SControllerTestDb();
    db.initialize();
    SB_NameCard_S2Controller.SearchRequest req = new SB_NameCard_S2Controller.SearchRequest();
    req.setTarget('MineOnly');
    req.setWord('');
    req.setPage(1);
    // 自分の名刺
    List<NameCard__c> cards = [select Id, Name from NameCard__c where OwnerId = :UserInfo.getUserId()];
    SB_NameCard_S2Controller.SearchResponse result = SB_NameCard_S2Controller.searchNameCardsEx(req);
    System.assertEquals(cards.size(), result.cards.size());
    // みんなの名刺
    //      みんなの名刺 の場合、2次納品だけなので
    db.updateNameCardDeliveryType();
    cards.clear();
    req.setTarget('All');
    cards = [select Id, Name from NameCard__c];
    result = SB_NameCard_S2Controller.searchNameCardsEx(req);
    System.assertEquals(cards.size(), result.cards.size());
    // SOQL
    req.setTarget('All');
    req.setWord('Company');
    List<List<NameCard__c>> finds = search.query('FIND {Company} IN ALL FIELDS RETURNING NameCard__c(Id)');
    result = SB_NameCard_S2Controller.searchNameCardsEx(req);
    System.assertEquals(finds[0].size(), result.cards.size());
    Test.stopTest();
  }

  // String getNameCard のテスト
  @isTest
  static void testGetNameCard() {
    Test.startTest();
    SControllerTestDb db = new SControllerTestDb();
    db.initialize();
    List<NameCard__c> cards = [SELECT Id, Name FROM NameCard__c limit 2];

    SB_NC_NameCardDTO result = SB_NameCard_S2Controller.getNameCard(cards[0].id);
    System.assertEquals(cards[0].Id, result.Id);
    Test.stopTest();
  }

  // deleteNameCards のテスト
  @isTest
  static void testDeleteNameCards() {
    Test.startTest();
    SControllerTestDb db = new SControllerTestDb();
    db.initialize();

    List<NameCard__c> cards = [SELECT Id, Name FROM NameCard__c limit 2];
    List<Id> ids = new List<Id>();
    for (NameCard__c c : cards) {
      ids.add(c.Id);
    }
    SB_NameCard_S2Controller.Response res = SB_NameCard_S2Controller.deleteNameCards(ids);
    System.assertEquals(true, res.status);
    cards.clear();
    cards = [SELECT Id FROM NameCard__c WHERE Id IN :ids];
    System.assertEquals(0, cards.size());
    Test.stopTest();
  }

  // saveNameCard のテスト
  @isTest
  static void testSaveNameCard() {
    Test.startTest();
    SControllerTestDb db = new SControllerTestDb();
    db.initialize();

    List<NameCard__c> cards = [SELECT Id, Name FROM NameCard__c limit 2];
    SB_NC_NameCardDTO dto = SB_NameCard_S2Controller.getNameCard(cards[0].id);
    // List<NameCard__c>  results = SB_NameCard_S2Controller.getNameCardList(false);
    dto.division = '変更後の部署';
    List<SB_NC_NameCardDTO> dtos = new List<SB_NC_NameCardDTO>();
    dtos.add(dto);
    SB_NameCard_S2Controller.saveNameCards(dtos);
    cards = [select Id, Name, division__c from NameCard__c where Id = :dto.Id];
    System.assertEquals('変更後の部署', cards[0].division__c);
    Test.stopTest();
  }

  // 詳細画面でタグをつけるテスト
  @isTest
  static void testTaggingInWindow() {
    Test.startTest();
    SControllerTestDb db = new SControllerTestDb();
    db.initialize();
    db.updateNameCardOwner();

    Integer cntCard = 2;
    // リスト名をつける
    db.updateNameCardListName(cntCard);
    // 画面コントローラで名刺にタグをつける
    List<NameCard__c> cards = [select Id, Name from NameCard__c limit :cntCard];    // cntCard分取得
    Integer cntTag = 3;
    for (NameCard__c card : cards) {
      List<String> tags = new List<String>();
      for (Integer i =0; i < cntTag; i++) {
        tags.add('tag' + i.format());
      }
      // v2.4 2019.06.xx SV_DEV-1830 要望 SmartViscaアプリでタグの登録エラーの場合、メッセージを表示してほしい
      // 例外はそのまま、クライアントに送ります。にしたので、 try catch するように。
      try {
        SB_NameCard_S2Controller.saveNameCardTag(card.Id, tags);
      }
      catch(Exception e) {
        System.debug(e);
      }
    }
    // 名刺詳細画面 で 名刺詳細＋タグ情報 を取得する メソッドのテスト
    for (NameCard__c card : cards) {
      SB_NameCard_S2Controller.NameCardDetail tagdCard= SB_NameCard_S2Controller.getNameCardDetail(card.Id);
      // パッケージ作成環境とかで、タグがつかえないところでテストするから対策
      // 2020.02.xx v2.4.6 SV_DEV-2495 @RemoteAction getNameCardDetail の tagsでリスト名も返す。タグかリスト名か判別可能にする
      if (SB_NameCard_S2Controller.isEnableNameCardTagPersonal() == true) {
        // タグ有効
        System.assertEquals(cntTag+1, tagdCard.tags.size());
        // テストで TagDefinition のクエリで正しい結果をえられないので、その検証はしません。
      }
      else {
        // タグ無効
        System.assertEquals(1, tagdCard.tags.size());
      }
      System.assertEquals(card.Id, tagdCard.card.get('id'));
      List<SB_NameCard_S2Controller.Activity> acts = SB_NameCard_S2Controller.getMyActivities(card.Id);
    }
    // タグ一覧 のタグごと名刺クラスのリスト取得のメソッドのテスト
    List<SB_NameCard_TagAndListCollector.TagdNameCards> tags = SB_NameCard_S2Controller.getTagdNameCards();
    for (SB_NameCard_TagAndListCollector.TagdNameCards tagdCards :tags) {
      System.debug(tagdCards.tagLabel);
      for (Map<String, Object> card : tagdCards.cards) {
        System.debug(card.get('name'));
      }
      System.assertEquals(cntCard, tagdCards.cards.size());
    }
    // パッケージ作成環境とかで、タグがつかえないところでテストするから対策
    if (SB_NameCard_S2Controller.isEnableNameCardTagPersonal() == true)
      System.assertEquals(cntTag+1, tags.size());
    else
      System.assertEquals(1, tags.size());
    Test.stopTest();
  }

  // saveNameCard のテスト
  //   文字不正で例外　v2.4 2019.06.xx SV_DEV-1830 要望 SmartViscaアプリでタグの登録エラーの場合、メッセージを表示してほしい
  //  エラー: タグには、文字、数字、スペース、ダッシュ、およびアンダースコアのみが使用でき、文字または数字が 1 つ以上必要です。
  @isTest
  static void test_saveNameCardTag_Exception() {
    SControllerTestDb db = new SControllerTestDb();
    db.initialize();
    db.updateNameCardOwner();

    Test.startTest();
    List<NameCard__c> cards = [select Id, Name from NameCard__c LIMIT 2];
    List<String> tags = new List<String> {'○○○○2019.6'};
    Boolean success = true;
    try {
      SB_NameCard_S2Controller.saveNameCardTag(cards[0].Id, tags);
    }
    catch(Exception e) {
      success =false;
    }
    Test.stopTest();
    System.assertEquals(false, success);
  }

  // タグ or 名刺リスト に 名刺を追加するテスト タグ一覧でのメソッド
  @isTest
  static void testTaggingInRemoteFunction() {
    Test.startTest();
    SControllerTestDb db = new SControllerTestDb();
    db.initialize();
    db.updateNameCardOwner();   // 全部の名刺の所有者を自分にする。

    // 指定のタグのない名刺  タグに名刺を追加するときの選択可能な名刺を抽出するメソッドのテスト
    List<NameCard__c> cards = SB_NameCard_S2Controller.getNameCardsWithoutLabel('ABC', true);
    System.assertEquals(db.listCard.size(), cards.size());
    cards.clear();
    cards = SB_NameCard_S2Controller.getNameCardsWithoutLabel('ABC', false);
    System.assertEquals(db.listCard.size(), cards.size());

    // タグ、名刺リストを 付与する。
    SB_NameCard_S2Controller.TaggingRequest saveReq = new SB_NameCard_S2Controller.TaggingRequest();
    // タグ
    Integer cntTag = 2;
    for (Integer n=0;  n < cntTag; n++) {
      saveReq.labels.add('タグ' + n.format());
    }
    for (NameCard__c card : cards) {
      saveReq.nameCardIds.add(card.Id);
    }
    saveReq.tagIsTag = true;        // タグとして
    SB_NameCard_S2Controller.bindNameCardsToLabel(saveReq);

//      db.insertNameCardTag();
//      db.updateNameCardListName(2);

    // 全タグを取得
    SB_NameCard_S2Controller.GetTagsRequest getTagReq = new SB_NameCard_S2Controller.GetTagsRequest(1, 0, null);
    List<SB_NameCard_TagAndListCollector.NameCardTagOrList> tags = SB_NameCard_S2Controller.getTagsOrListnames(getTagReq);
    // パッケージ作成環境とかで、タグがつかえないところでテストするから対策
    if (SB_NameCard_S2Controller.isEnableNameCardTagPersonal() == true) {
      // テストで TagDefinition のクエリが0件でもどるので、
      List<SObject> tagds = Database.query('SELECT Id, Name, Type FROM TagDefinition WHERE Name LIKE \'タグ%\' AND Type=\'Personal\'');
      System.assertEquals(tagds.size(), tags.size());
    }
    else {
      System.assertEquals(0, tags.size());
    }

    // 指定した名刺データで使ってないタグを取得
    tags.clear();
    SB_NameCard_S2Controller.GetTagsRequest getTagReqExclude = new SB_NameCard_S2Controller.GetTagsRequest(1, 0, cards[0].Id);
    tags = SB_NameCard_S2Controller.getTagsOrListnames(getTagReqExclude);
    // 全部使ってるし 0
    System.assertEquals(0, tags.size());

    // 名刺リスト
    saveReq.labels.clear();
    saveReq.labels.add('名刺リスト');
    saveReq.tagIsTag = false;       //名刺リストとして
    tags.clear();
    SB_NameCard_S2Controller.bindNameCardsToLabel(saveReq);
    SB_NameCard_S2Controller.GetTagsRequest getListReq = new SB_NameCard_S2Controller.GetTagsRequest(2, -1, null);
    tags = SB_NameCard_S2Controller.getTagsOrListnames(getListReq);
    System.assertEquals(1, tags.size());

    // タグと名刺リストの両方
    SB_NameCard_S2Controller.GetTagsRequest getAllReq = new SB_NameCard_S2Controller.GetTagsRequest(-1, -1, null);
    tags = SB_NameCard_S2Controller.getTagsOrListnames(getAllReq);
    // パッケージ作成環境とかで、タグがつかえないところでテストするから対策
    if (SB_NameCard_S2Controller.isEnableNameCardTagPersonal() == true) {
      // テストで TagDefinition のクエリが0件でもどるので、
      List<SObject> tagds = Database.query('SELECT Id, Name, Type FROM TagDefinition WHERE Name LIKE \'タグ%\' AND Type=\'Personal\'');
      System.assertEquals(tagds.size()+1, tags.size());
    }
    else {
      System.assertEquals(1, tags.size());
    }

    Test.stopTest();
  }

  // タグ or 名刺リスト に 名刺を追加して削除するテスト タグ一覧でのメソッド
  @isTest
  static void testRemoveTag() {
    Test.startTest();
    SControllerTestDb db = new SControllerTestDb();
    db.initialize();
    db.updateNameCardOwner();   // 全部の名刺の所有者を自分にする。

    // 指定のタグのない名刺  タグに名刺を追加するときの選択可能な名刺を抽出するメソッドのテスト
    List<NameCard__c> cards = [Select Id, Name From NameCard__c limit 10];

    SB_NameCard_S2Controller.TaggingRequest saveReq = new SB_NameCard_S2Controller.TaggingRequest();

    // タグ
    Integer cntTag = 2;
    for (Integer n=0;  n < cntTag; n++) {
      saveReq.labels.add('タグ' + n.format());
    }
    for (NameCard__c card : cards) {
      saveReq.nameCardIds.add(card.Id);
    }
    saveReq.tagIsTag = true;        // タグとして
    SB_NameCard_S2Controller.bindNameCardsToLabel(saveReq);

    SB_NameCard_S2Controller.GetTagsRequest getTagReq = new SB_NameCard_S2Controller.GetTagsRequest(1, 0, null);
    List<SB_NameCard_TagAndListCollector.NameCardTagOrList> tags = SB_NameCard_S2Controller.getTagsOrListnames(getTagReq);
    // パッケージ作成環境とかで、タグがつかえないところでテストするから対策
    if (SB_NameCard_S2Controller.isEnableNameCardTagPersonal() == true) {
      // テストで TagDefinition のクエリが0件でもどるので、
      List<SObject> tagds = Database.query('SELECT Id, Name, Type FROM TagDefinition WHERE Name LIKE \'タグ%\' AND Type=\'Personal\'');
      System.assertEquals(tagds.size(), tags.size());
    }
    else {
      System.assertEquals(0, tags.size());
    }
    for (String label: saveReq.labels) {
      SB_NameCard_S2Controller.removeNameCardTag(saveReq.nameCardIds, label, saveReq.tagIsTag);
    }
    tags.clear();
    tags = SB_NameCard_S2Controller.getTagsOrListnames(getTagReq);
    System.assertEquals(0, tags.size());

    // 名刺リスト
    saveReq.labels.clear();
    saveReq.labels.add('名刺リスト');
    saveReq.tagIsTag = false;       //名刺リストとして
    tags.clear();
    SB_NameCard_S2Controller.bindNameCardsToLabel(saveReq);
    SB_NameCard_S2Controller.GetTagsRequest getListReq = new SB_NameCard_S2Controller.GetTagsRequest(2, -1, null);
    tags = SB_NameCard_S2Controller.getTagsOrListnames(getListReq);
    System.assertEquals(1, tags.size());
    for (String label: saveReq.labels) {
      SB_NameCard_S2Controller.removeNameCardTag(saveReq.nameCardIds, label, saveReq.tagIsTag);
    }
    tags.clear();
    tags = SB_NameCard_S2Controller.getTagsOrListnames(getListReq);
    System.assertEquals(0, tags.size());

    Test.stopTest();
  }

  // getFindNearby のテスト
  @isTest
  static void testGetFindNearby() {
    Test.startTest();
    SControllerTestDb db = new SControllerTestDb();
    db.initialize();
    db.updateNameCardGeolocation(2);

    SB_NameCard_S2Controller.FindNearbyRequest req = new SB_NameCard_S2Controller.FindNearbyRequest();
    req.mineOnly = false;
    req.latitude = '35.679841';
    req.longitude = '139.765092';
    req.target='All';           // 探す対象について
    List<NameCard__c> cards = SB_NameCard_S2Controller.getFindNearby(req);
    System.assertEquals(2, cards.size());

    List<SB_NameCard_S2Controller.NameCardLocation> locations = SB_NameCard_S2Controller.getFindNearbyEx(req);
    System.assertEquals(1, locations.size());

    Test.stopTest();
  }

  // getNameCardsWithoutGeoLocation のテスト
  @isTest
  static void testGetNameCardsWithoutGeoLocation() {
    Test.startTest();
    SControllerTestDb db = new SControllerTestDb();
    db.initialize();
    db.updateNameCardAddress();

    List<NameCard__c> results = SB_NameCard_S2Controller.getNameCardsWithoutGeoLocation(null);
    System.assertEquals(db.listCard.size(), results.size());
    results = SB_NameCard_S2Controller.getNameCardsWithoutGeoLocation(UserInfo.getUserId());
    System.assertEquals(db.listCard.size(), results.size());
    Test.stopTest();
  }


  // getUsersHavingCard のテスト
  // 同じ名刺を持っているユーザ
  @isTest
  static void testGetUsersHavingCard() {
    Test.startTest();
    SControllerTestDb db = new SControllerTestDb();
    db.initialize();
    // Chatterの有効無効
    System.debug(SB_NameCard_S2Controller.isEnableFeedItem());
    List<User> results = SB_NameCard_S2Controller.getUsersHavingCard(db.listCard[0].Id, true);
    System.assertEquals(SB_NameCard_TestDB.CNT_USER, results.size());
    Test.stopTest();
  }

  @isTest
  static void testGetCompnayTree() {
    Test.startTest();
    SControllerTestDb db = new SControllerTestDb();
    db.initialize();

    // SB_NameCard_S2Controller.Nodeは 中身をからにしたので、 2018.01.xx
    SB_NameCard_S2Controller.Node n = new SB_NameCard_S2Controller.Node();
    System.assertNotEquals(null, n);

    List<SB_NameCard_S2Controller.Node> rootNodes = SB_NameCard_S2Controller.getCompnayTree(db.listCard[0].Id, false);

    System.assertEquals(null, rootNodes);
  }

  // Node getCompnayTree のテスト
  // 同じ名刺を持っているユーザ
  //  2017.11.xx v1.22 SV_DEV-689 組織情報に役職を加味する
  @isTest
  static void testGetCompnayTree2() {
    Test.startTest();
    SControllerTestDb db = new SControllerTestDb();
    db.initialize();

    //List<SB_NameCard_S2Controller.Node> rootNodes = SB_NameCard_S2Controller.getCompnayTree(db.listCard[0].Id, false);
    //System.assertEquals(SB_NameCard_TestDB.CNT_EMPLOYEE, rootNodes[0].children.size());
    //System.assertEquals(1, rootNodes[0].children[0].children.size());
    List<SB_NameCard_OrgTreeBuilder.Item> items = SB_NameCard_S2Controller.getCompnayTree2(db.listCard[0].Id, false);
    System.assertEquals(SB_NameCard_TestDB.CNT_EMPLOYEE, items[0].items.size());
    System.assertEquals(1, items[0].items[0].items.size());
    Test.stopTest();
  }

  // 活動を作るテスト 行動編
  @isTest
  static void testSaveActivityEvent() {
    Test.startTest();
    SControllerTestDb db = new SControllerTestDb();
    db.initialize();
    db.updateNameCardOwner();

    List<SB_NameCard_S2Controller.ActivityDTO> reqs = new List<SB_NameCard_S2Controller.ActivityDTO>();
    Set<Id> cardIds = new Set<Id>();
    // 行動の追加
    for (NameCard__c card : db.listCard) {
      SB_NameCard_S2Controller.ActivityDTO req = new SB_NameCard_S2Controller.ActivityDTO();
      req.subject = '行動';
      req.description = '説明\n説明\n説明\n説明\n説明\n説明\n説明\n説明';
      req.startDatetimeL = Datetime.now().addDays(1).getTime();
      if (Math.mod(cardIds.size(), 2) == 0)    // デフォルトの行動の長さを使わせるため 交互に 終了時刻指定、
        req.startDatetimeL = Datetime.now().addDays(1).addHours(1).getTime();
      req.location = '行動の場所';
      req.cardId = card.Id;
      cardIds.add(card.Id);
      reqs.add(req);
    }
    SB_NameCard_S2Controller.saveActivities(reqs);
    List<Event> events = [SELECT Id, WhoId, WhatId, OwnerId FROM Event WHERE WhatId IN :cardIds AND subject = '行動'];
    System.assertEquals(db.listCard.size(), events.size());
    reqs.clear();
    // 更新して全部 終日 行動にする。
    for (Event e : events) {
      SB_NameCard_S2Controller.ActivityDTO req = new SB_NameCard_S2Controller.ActivityDTO();
      req.subject = '行動2';
      req.description = '説明\n説明\n説明\n説明\n説明\n説明\n説明\n説明';
      req.allDay = true;
      req.activityDateL = Datetime.now().addDays(1).getTime();
      req.endDatetimeL = Datetime.now().addDays(2).getTime();
      req.location = '行動の場所2';
      req.cardId = e.WhatId;
      req.eventID = e.Id;
      reqs.add(req);
    }
    SB_NameCard_S2Controller.saveActivities(reqs);
    // 更新して全部 終日 行動になっている
    events = [SELECT Id, subject, WhoId, WhatId, OwnerId FROM Event WHERE IsAllDayEvent = true AND subject = '行動2'];
    System.assertEquals(db.listCard.size(), events.size());

    SB_NameCard_S2Controller.ActivityDTO act = SB_NameCard_S2Controller.getActivity(events[0].Id);
    System.assertEquals(events[0].subject, act.subject);
    Test.stopTest();
  }

  // 活動を作るテスト ToDo編
  @isTest
  static void testSaveActivityTask() {
    Test.startTest();
    SControllerTestDb db = new SControllerTestDb();
    db.initialize();
    db.updateNameCardOwner();

    // 選択可能なステータスのリストを取得して数の確認
    List<String> statuss = SB_NameCard_Util.getPickListEntry(Task.status);
    List<SB_NameCard_S2Controller.SelectOption> opts = SB_NameCard_S2Controller.getTaskStatusOptions();
    System.assertEquals(statuss.size(), opts.size());

    List<SB_NameCard_S2Controller.ActivityDTO> reqs = new List<SB_NameCard_S2Controller.ActivityDTO>();
    Set<Id> cardIds = new Set<Id>();
    // ToDo の追加
    for (NameCard__c card : db.listCard) {
      SB_NameCard_S2Controller.ActivityDTO req = new SB_NameCard_S2Controller.ActivityDTO();
      req.subject = 'ToDo';
      req.description = '説明\n説明\n説明\n説明\n説明\n説明\n説明\n説明';
      req.activityDateL = Datetime.now().addDays(1).getTime();
      req.status = statuss[0];
      req.cardId = card.Id;
      cardIds.add(card.Id);
      reqs.add(req);
    }
    SB_NameCard_S2Controller.saveActivities(reqs);
    List<Task> tasks = [SELECT Id, subject, WhoId, WhatId, OwnerId FROM Task WHERE WhatId IN :cardIds and subject = 'ToDo'];
    System.assertEquals(db.listCard.size(), tasks.size());
    reqs.clear();
    for (Task t : tasks) {
      SB_NameCard_S2Controller.ActivityDTO req = new SB_NameCard_S2Controller.ActivityDTO();
      req.subject = 'ToDo2';
      req.description = '説明\n説明\n説明\n説明\n説明\n説明\n説明\n説明';
      req.activityDateL = Datetime.now().addDays(2).getTime();
      req.status = statuss[0];
      req.cardId = t.WhatId;
      req.taskID = t.Id;
      reqs.add(req);
    }
    SB_NameCard_S2Controller.saveActivities(reqs);
    // 更新して全部 ToDo2 になっている
    tasks = [SELECT Id, subject, WhoId, WhatId, OwnerId FROM Task WHERE subject = 'ToDo2'];
    System.assertEquals(db.listCard.size(), tasks.size());

    SB_NameCard_S2Controller.ActivityDTO act = SB_NameCard_S2Controller.getActivity(tasks[0].Id);
    System.assertEquals(tasks[0].subject, act.subject);

    Test.stopTest();
  }

  // 活動を作るテスト ToDo編
  @isTest
  static void testDeleteSObjects() {
    Test.startTest();
    SControllerTestDb db = new SControllerTestDb();
    db.initialize();

    List<String> objectIds = new List<String>();
    for (NameCard__c card : db.listCard) {
      objectIds.add(card.Id);
    }
    SB_NameCard_S2Controller.deleteSObjects(objectIds);
    List<NameCard__c> cards = [select Id from NameCard__c];
    System.assertEquals(0, cards.size());

    Test.stopTest();
  }

  // 古い名刺 を取得するテスト
  @isTest
  static void testGetReferenced() {
    Test.startTest();
    SControllerTestDb db = new SControllerTestDb();
    db.initialize();
    SB_NameCard_MergeBuisnessCardsAfter.firstRun = true;       // １回起動を初期化
    // SB_NameCard_FirstRunKeeper.SB_AftInsUpdOnNameCard = true;    // 旧パッケージ用
    db.updateNameCardDeliveryType();

    List<NameCard__c> cards = [Select Id,Name From NameCard__c Where Parent__c=null];

    for (NameCard__c card :cards) {
      List<SB_NC_NameCardDTO> refereds = SB_NameCard_S2Controller.getReferenced(card.Id);
      System.assertEquals(SB_NameCard_TestDB.CNT_USER-1, refereds.size());
    }

    Test.stopTest();
  }

  // 同じ人の名刺 を取得するテスト
  @isTest
  static void testGetSameCards() {
    Test.startTest();
    SControllerTestDb db = new SControllerTestDb();
    db.initialize();
    SB_NameCard_MergeBuisnessCardsAfter.firstRun = true;       // １回起動を初期化
    // SB_NameCard_FirstRunKeeper.SB_AftInsUpdOnNameCard = true;    // 旧パッケージ用
    db.updateNameCardDeliveryType();

    List<NameCard__c> cards = [Select Id,Name From NameCard__c Where Parent__c=null];

    for (NameCard__c card :cards) {
      List<SB_NC_NameCardDTO> samecards = SB_NameCard_S2Controller.getSameCards(card.Id);
      System.assertEquals(SB_NameCard_TestDB.CNT_USER, samecards.size());
    }

    Test.stopTest();
  }

  // レコードタイプ取得のテスト
   @isTest
   static void testGetRecordTypes() {
    Test.startTest();
    SControllerTestDb db = new SControllerTestDb();
    db.initialize();

    // Event 行動
    List<RecordType> recInfos = [select Id from RecordType Where SobjectType='Event'];
    List<SB_NameCard_S2Controller.RecordTypeDTO> rcInfoEvent = SB_NameCard_S2Controller.getRecordTypes('Event');
    if (rcInfoEvent !=null)
      System.assertEquals(recInfos.size(), rcInfoEvent.size());
    else
      System.assertEquals(recInfos.size(), 0);
    // Task ToDo
    recInfos.clear();
    recInfos = [select Id from RecordType Where SobjectType='Task'];
    List<SB_NameCard_S2Controller.RecordTypeDTO> rcInfoTask = SB_NameCard_S2Controller.getRecordTypes('Task');
    if (rcInfoTask !=null)
      System.assertEquals(recInfos.size(), rcInfoTask.size());
    else
      System.assertEquals(recInfos.size(), 0);

    Test.stopTest();
  }

  // ユーザProfile取得のテスト
   @isTest
   static void testGetUserProfile() {
    Test.startTest();
    SControllerTestDb db = new SControllerTestDb();
    db.initialize();

    // 取得
    User userProf = SB_NameCard_S2Controller.getUserProfile(db.listUser[0].Id);
    System.assert(db.listUser[0].email==userProf.EMail);

    Test.stopTest();
  }

   // 画面のコントローラとしてのテスト
  @isTest
  static void testSController() {
    Test.startTest();
    SControllerTestDb db = new SControllerTestDb();
    db.initialize();
    db.updateNameCardAddress();

    PageReference pageRef = Page.SB_NameCard_SSetGeoLocations;
    pageRef.getHeaders().put('USER-AGENT', 'iPhone OS/8.1 (iPhone) Salesforce1');
    Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('userid', UserInfo.getUserId());
    ApexPages.currentPage().getHeaders().put('USER-AGENT', 'iPhone OS/8.1 (iPhone) Salesforce1');
    SB_NameCard_S2Controller ctrl = new SB_NameCard_S2Controller();
    System.assertEquals(SB_NameCard_Util.smartViscaConfig.SGeolocationQueryLimit__c.intValue(), ctrl.getSGeolocationQueryLimit());
    System.assertEquals(SB_NameCard_Util.smartViscaConfig.SGeolocationQueryInterval__c.intValue(), ctrl.getSGeolocationQueryInterval());
    System.assertEquals(UserInfo.getUserId(), ctrl.userId);
    System.assertEquals(false, ctrl.debug);
    Test.stopTest();
  }

  // 2016.06.xx
  // コントローラのメンバ変数のチェック
  @isTest
  static void testCheckControllerValues() {
    SB_NameCard_S2Controller ctrl = new SB_NameCard_S2Controller();

    System.assertEquals(true, ctrl.isIOS8('iPhone OS/8.1 (iPad) Salesforce1/6.0.4(3000747) XBranding/1.0 SalesforceTouchContainer/2.0 Mozilla/5.0 (iPad; CPU OS 8_1 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Mobile/12B410 (413432672)'));
    System.assertEquals(false, ctrl.isIOS8('any os'));
    System.assertEquals(SB_NameCard_Util.smartViscaConfig.SEnableNameCardEdit__c, ctrl.getSEnableNameCardEdit());
    System.assertEquals(SB_NameCard_Util.smartViscaConfig.SUseGIS__c, ctrl.getSUseGIS());
    System.assertEquals(SB_NameCard_Util.smartViscaConfig.SUseStandardActivityUI__c, ctrl.getSUseStandardActivityUI());
 }

  // 2016.06.xx
  // 最近みた名刺の一覧取得
  @isTest
  static void testGetRecentNameCardIds() {
    List<Id> ids = SB_NameCard_S2Controller.getRecentNameCardIds();
    System.assert(0 <= ids.size());     // 通常のテスト実行と パッケージ アップロードのテストで結果が違うのでやむなく
  }

  // 2016.06.xx
  // 最近みた名刺の一覧取得
  @isTest
  static void testGetRecentViewedCards() {
    List<NameCard__c> cards = SB_NameCard_S2Controller.getRecentViewedCards();
    System.assert(0 <=  cards.size());  // 通常のテスト実行と パッケージ アップロードのテストで結果が違うのでやむなく
  }

  // 2016.06.xx
  // 既存名刺の更新
  // saveNameCardsRaw
  @isTest
  static void testSaveNameCardsRawInsert() {
    Test.startTest();
    List<NameCard__c> cards = new List<NameCard__c>();
    cards.add(new NameCard__c(Name='姓 名', person_name_last__c='姓'));
    List<NameCard__c> res = SB_NameCard_S2Controller.saveNameCardsRaw(cards);
    System.assertEquals(cards.size(), res.size());
    Test.stopTest();
  }

  // 2016.06.xx
  // 既存名刺の更新
  // saveNameCardsRaw
  @isTest
  static void testSaveNameCardsRawUpdate() {
    SControllerTestDb db = new SControllerTestDb();
    db.initialize();
    Test.startTest();
    List<NameCard__c> cards = [SELECT ID, Name FROM NameCard__c];
    List<NameCard__c> res = SB_NameCard_S2Controller.saveNameCardsRaw(cards);
    System.assertEquals(cards.size(), res.size());
    Test.stopTest();
  }

  // 2016.06.xx
  // 既存名刺の更新
  // getUsersHavingCardEx
  @isTest
  static void testGetUsersHavingCardEx() {
    Test.startTest();
    SControllerTestDb db = new SControllerTestDb();
    db.initialize();
    List<NameCard__c> cards = [SELECT ID, Name FROM NameCard__c];
    SB_NameCard_S2Controller.SameCardUsers res = SB_NameCard_S2Controller.getUsersHavingCardEx(cards[0].Id, false);
    System.assertEquals(SB_NameCard_TestDB.CNT_USER, res.users.size());
    Test.stopTest();
  }

  // タグ付き名刺の情報を取得
  // TagdNameCards
  @isTest
  static void testInnerClasses() {
    SB_NameCard_TagAndListCollector.TagdNameCards holder = new SB_NameCard_TagAndListCollector.TagdNameCards('タグ名');
    holder.setTagIsTag(true);
    System.assertEquals('タグ名', holder.tagLabel);

    Exception ex = new SB_NameCard_S2Controller.SB_NameCard_S2ControllerException('TEST Error');
    SB_NameCard_S2Controller.Response res = new SB_NameCard_S2Controller.Response();
    res.setResponse(ex);
    System.assertEquals(false, res.status);

  }

  // 2016.06.xx
  // 名刺のToDOの取得
  // getActivitySubject
  @isTest
  static void testGetActivitySubjectTask() {
    Test.startTest();
    SControllerTestDb db = new SControllerTestDb();
    db.initialize();

    List<String> subjects =  SB_NameCard_S2Controller.getActivitySubject(1);
    Boolean ok = false;
    for (String s : subjects) {
      if (s.containsIgnoreCase('task')) {
        ok = true;
        break;
      }
    }
    System.assert(ok);
    Test.stopTest();
  }

  // 2016.06.xx
  // 名刺のEventの取得
  // getActivitySubject
  @isTest
  static void testGetActivitySubjectEvent() {
    Test.startTest();
    SControllerTestDb db = new SControllerTestDb();
    db.initialize();

    List<String> subjects =  SB_NameCard_S2Controller.getActivitySubject(2);
    Boolean ok = false;
    for (String s : subjects) {
      if (s.containsIgnoreCase('event')) {
        ok = true;
        break;
      }
    }
    System.assert(ok);
    Test.stopTest();
  }

  // 2018.01.xx
  // 名刺利用可能ユーザの 部署−ユーザs 取得
  // getDepartmentUsers
  @isTest
  static void test_getDepartmentUsers() {
    Test.startTest();
    SB_NameCard_UserList.DepartmentUsers depts = SB_NameCard_S2Controller.getDepartmentUsers(null, null);
    // 別のメソッドでも調べる
    Map<String, Integer> dept2num = SB_NameCard_UserList.getDept2Number();
    // 結果を突き合わせる
    // depts.departments には「全て」があるので マイナス1する。あるいは、部署が1つ（あるいはなし）ならば、全てはないので 1
    System.assert(dept2num.size() == depts.departments.size()-1 | dept2num.size()==1);
    for (String dept : dept2num.keySet()) {
      System.assert(depts.dept2Users.containsKey(dept));
      System.assertEquals(dept2num.get(dept), depts.dept2Users.get(dept).size());
    }
    Test.stopTest();
  }

  // 2019.03.xx v2.2
  // SV_DEV-1526 モバイル 新UI 検索ページのキャプションに「Search by Company Name / Name / Email / Phone」とあるが、実際には、項目は絞っていない
  @isTest
  static void test_getSearchResultFilter() {
    String filter = SB_NameCard_S2Controller.getSearchResultFilter('渋谷');
    System.assert(filter.startsWith('('));
    System.assert(filter.contains('%渋谷%'));
    System.assert(filter.endsWith(')'));
  }

  // 詳細画面でタグをつけるテスト リスト名も要求するタグの配列にはいいてる。
  // v2.5 2020.03.xx SV_DEV-2528 「リスト名」が全角数字を含む場合に名刺詳細で2つ表示される
  @isTest
  static void test_saveNameCardTag_without_listname() {
    Test.startTest();
    SControllerTestDb db = new SControllerTestDb();
    db.initialize();
    db.updateNameCardOwner();

    List<NameCard__c> cards = [select Id, Name FROM NameCard__c LIMIT 2];    //
    Integer cntTag = 3;
    List<String> tagLabels = new List<String>();
    // tagLabels.add(STR_LISTNAME);
    for (Integer i =0; i < cntTag; i++) {
      tagLabels.add('tag' + i.format());
    }
    Boolean success = true;
    try {
      SB_NameCard_S2Controller.saveNameCardTag(cards[0].Id, tagLabels);
    }
    catch(Exception e) {
      success = false;
      System.debug(e);
    }
    if (SB_NameCard_S2Controller.isEnableNameCardTagPersonal() == true) {
      Id cId = cards[0].Id;
      List<SObject> tags = Database.query('SELECT ItemId, Name FROM NameCard__Tag WHERE ItemId = :cId');
      System.assertEquals(tagLabels.size(), tags.size());
    }
    else {
      System.assertEquals(false, success);
    }

  }

  @isTest
  static void test_saveNameCardTag_with_listname() {
    Test.startTest();
    SControllerTestDb db = new SControllerTestDb();
    db.initialize();
    db.updateNameCardOwner();

    Integer cntCard = 2;
    // リスト名をつける
    db.updateNameCardListName(cntCard);
    // 画面コントローラで名刺にタグをつける
    List<NameCard__c> cards = [select Id, Name from NameCard__c WHERE list_name__c = :STR_LISTNAME];    //
    Integer cntTag = 3;
    List<String> tagLabels = new List<String>();
    tagLabels.add(STR_LISTNAME);    // リスト名
    for (Integer i =0; i < cntTag; i++) {
      tagLabels.add('tag' + i.format());
    }
    Boolean success = true;
    try {
      SB_NameCard_S2Controller.saveNameCardTag(cards[0].Id, tagLabels);
    }
    catch(Exception e) {
      success = false;
      System.debug(e);
    }
    if (SB_NameCard_S2Controller.isEnableNameCardTagPersonal() == true) {
      Id cId = cards[0].Id;
      List<SObject> tags = Database.query('SELECT ItemId, Name FROM NameCard__Tag WHERE ItemId = :cId AND Name=:STR_LISTNAME');
      System.assert(tags.isEmpty());
    }
    else {
      System.assertEquals(false, success);
    }
  }

  @isTest
  static void test_saveNameCardTag_with_listname2() {
    Test.startTest();
    SControllerTestDb db = new SControllerTestDb();
    db.initialize();
    db.updateNameCardOwner();

    Integer cntCard = 2;
    // リスト名をつける
    db.updateNameCardListName(cntCard);
    // 画面コントローラで名刺にタグをつける
    List<NameCard__c> cards = [select Id, Name from NameCard__c WHERE list_name__c = :STR_LISTNAME];    //
    Integer cntTag = 3;
    List<String> tagLabels = new List<String>();
    tagLabels.add(STR_LISTNAME);    // リスト名
    for (Integer i =0; i < cntTag; i++) {
      tagLabels.add('tag' + i.format());
    }
    tagLabels.add(STR_LISTNAME);    // リスト名
    Boolean success = true;
    try {
      SB_NameCard_S2Controller.saveNameCardTag(cards[0].Id, tagLabels);
    }
    catch(Exception e) {
      System.debug(e);
      success = false;
    }
    if (SB_NameCard_S2Controller.isEnableNameCardTagPersonal() == true) {
      Id cId = cards[0].Id;
      List<SObject> tags = Database.query('SELECT ItemId, Name FROM NameCard__Tag WHERE ItemId = :cId AND Name=:STR_LISTNAME');
      System.assertEquals(1, tags.size());  // リスト名と同じタグがある。
    }
    else {
      System.assertEquals(false, success);
    }
  }

}