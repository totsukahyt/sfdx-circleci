/**
 *
 * SB_NC_UpdateByCardLcControllerTest
 *  SmartVisca LEX対応
 *  名刺で更新 Lightningコンポーネント 用 コントローラ SB_NC_UpdateByCardLcController のテストクラス
 *
 *
 * Copyright (C) 2016 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2016.10.xx
 *
 **/
 @isTest
 private class SB_NC_UpdateByCardLcControllerTest
 {

  public class TestDb extends SB_NC_TestDB {

    //public override void initialize() {
    //   // ユーザ
    //   initializeUser();
    //   if (listUser.isEmpty() == false) {
    //    insert listUser;
    //  }
    //  // 名刺関係
    //  initializeKaisha();     // 会社を揃えておく
    //  initializeEmployee();   // 会社ごとに名刺の人を揃えておく
    //  // 名刺
    //  initializeNameCard();
    //  if (listCard.isEmpty() == false) {
    //    insert listCard;
    //  }
    //  // 取引先
    //  initializeAccount();  // 揃えた会社について、取引先を作る。
    //  if (mapAccount.isEmpty() == false) {
    //    insert mapAccount.values();
    //  }
    //  // 取引先責任者
    //  initializeContact();
    //  if (!listContact.isEmpty()) {
    //    insert listContact;
    //  }
    //  // 名刺連携項目マッピング
    //  initializeMapping();
    //  if (!listMapping.isEmpty()) {
    //    insert listMapping;
    //  }
    //}

    public void insertNameCardOver1000() {
      List<NameCard__c> objs = new List<NameCard__c>();
      for (Integer n=0; n < 1001; n++) {
        objs.add(
          new NameCard__c(
            Name = '名刺 太郎'
            , person_name_last__c= '名刺'
            , person_name_first__c= '太郎'
            , email__c= 'taro@test.com'
            , company_name__c= 'テスト本舗 株式会社'
            , division__c = '本社'
            , title_name__c = '役なし'
            , tel1__c= '0333333333'
            , fax1__c= '0344444444'
            , mobile__c = '09099999999'
            , web_url1__c = 'http://www.test.com'
            , zip_code__c = '1550022'
            , address_pref__c = '東京都'
            , address__c = '渋谷区恵比寿南1−5−5'
            , address_bld__c = '恵比寿ビル'
            , list_name__c ='名刺リスト'
            , memo__c = '名刺メモ'
            , freehandmemo__c = '自由記述'
            , delivery_type__c='1'
            , OwnerId = listUser[0].Id
        ));
      }
      for (Integer n=0; n < 20; n++) {
        objs.add(
          new NameCard__c(
            Name= '名刺 太郎'
            , person_name_last__c= '名刺'
            , person_name_first__c= '太郎'
            , email__c= 'taro@test.com'
            , company_name__c= 'テスト本舗 株式会社'
            , division__c = '本社'
            , title_name__c = '役なし'
            , tel1__c= '0333333333'
            , fax1__c= '0344444444'
            , mobile__c = '09099999999'
            , web_url1__c = 'http://www.test.com'
            , zip_code__c = '1550022'
            , address_pref__c = '東京都'
            , address__c = '渋谷区恵比寿南1−5−5'
            , address_bld__c = '恵比寿ビル'
            , list_name__c ='名刺リスト'
            , memo__c = '名刺メモ'
            , freehandmemo__c = '自由記述'
            , delivery_type__c='2'
            , OwnerId = listUser[0].Id
        ));
      }
      insert objs;
    }

    public void insertAccountContact() {
      List<Account> acnts = new List<Account>();
      acnts.add(new Account(Name='テスト本舗 株式会社'));
      insert acnts;
      List<Contact> conts = new List<Contact>();
      conts.add(new Contact(LastName='名刺', FirstName='太郎', Email='taro@test.com', AccountId=acnts[0].Id));
      insert conts;
    }
  } // TestDb

  //@testSetup
  //static void setupDB() {
  //  TestDb db = new TestDb();
  //  db.initialize();
  //  db.insertNameCardOver1000();
  //  db.insertAccountContact();
  //}

  @isTest
  static void test_isEnabileObject() {
    TestDb db = new TestDb();
    db.initialize();
    Test.startTest();
    Boolean res = SB_NC_UpdateByCardLcController.isEnabileObject(Opportunity.sObjectType);
    System.assertEquals(false, res);
    Test.stopTest();
  }

  // 候補の名刺リストを取得 getNamecards のテスト
  @isTest
  static void test_getNamecards() {
    TestDb db = new TestDb();
    db.initialize();
    Test.startTest();

    SB_NC_UpdateByCardLcController.GetNamecardsResponse res = null;
    String result;

    // アカウントでテスト
    List<Account> acnts = [SELECT Id FROM Account LIMIT 10];
    result = SB_NC_UpdateByCardLcController.getNamecards(acnts[0].Id);
    Map<String, Object> resM = (Map<String, Object>)JSON.deserializeUntyped(result);
    List<Object> cardsList = (List<Object>)resM.get('cards');
    System.debug('Candidate Card count : '  + cardsList.size());
    System.assertEquals(true, (Boolean)resM.get('success'));
    System.assert(String.isBlank((String)resM.get('error')));

    // コンタクトでテスト
    List<Contact> conts = [SELECT Id FROM Contact LIMIT 10];
    result = SB_NC_UpdateByCardLcController.getNamecards(conts[0].Id);
    resM = (Map<String, Object>)JSON.deserializeUntyped(result);
    cardsList = (List<Object>)resM.get('cards');
    System.debug('Candidate Card count : '  + cardsList.size());
    System.assertEquals(true, (Boolean)resM.get('success'));
    System.assert(String.isBlank((String)resM.get('error')));

    //　名刺でテスト 失敗
    List<NameCard__c> cards = [SELECT Id FROM NameCard__c LIMIT 10];
    result = SB_NC_UpdateByCardLcController.getNamecards(cards[0].Id);
    resM = (Map<String, Object>)JSON.deserializeUntyped(result);
    cardsList = (List<Object>)resM.get('cards');
    // System.debug('Candidate Card count : '  + cardsList.size());
    System.assertEquals(false, (Boolean)resM.get('success'));
    System.assert(String.isNotBlank((String)resM.get('error')));

    Test.stopTest();
  }

  // 名刺で更新実行メソッド updateByCard のテスト
  @isTest
  static void test_updateByCard() {
    TestDb db = new TestDb();
    db.initialize();
    Test.startTest();

    List<NameCard__c> cards = [SELECT Id FROM NameCard__c LIMIT 10];
    SB_NC_UpdateByCardLcController.UpdateByCardResponse res = null;
    String result;

    // アカウントを名刺で更新するテスト
    List<Account> acnts = [SELECT Id FROM Account LIMIT 10];
    result = SB_NC_UpdateByCardLcController.updateByCard(acnts[0].Id, cards[0].Id);
    res = (SB_NC_UpdateByCardLcController.UpdateByCardResponse)JSON.deserializeStrict(result, SB_NC_UpdateByCardLcController.UpdateByCardResponse.class);
    System.assertEquals(true, res.success);
    System.assert(String.isBlank(res.error));


    // コンタクトを名刺で更新するテスト
    List<Contact> conts = [SELECT Id FROM Contact LIMIT 10];
    result = SB_NC_UpdateByCardLcController.updateByCard(conts[0].Id, cards[0].Id);
    res = (SB_NC_UpdateByCardLcController.UpdateByCardResponse)JSON.deserializeStrict(result, SB_NC_UpdateByCardLcController.UpdateByCardResponse.class);
    System.assertEquals(true, res.success);
    System.assert(String.isBlank(res.error));

    // 名刺を名刺で更新するテスト 失敗
    result = SB_NC_UpdateByCardLcController.updateByCard(cards[0].Id, cards[0].Id);
    res = (SB_NC_UpdateByCardLcController.UpdateByCardResponse)JSON.deserializeStrict(result, SB_NC_UpdateByCardLcController.UpdateByCardResponse.class);
    System.assertEquals(false, res.success);
    System.assert(String.isNotBlank(res.error));

    Test.stopTest();
  }

  // getUserInfo
  @isTest
  static void test_getUserInfo() {
    TestDb db = new TestDb();
    db.initialize();
    Test.startTest();

    SB_NC_UpdateByCardLcController.GetUserInfoResponse res;
    String result;
    // ユーザIDを指定して ユーザの情報を得る。
    List<User> users = [SELECT Id, Name FROM User LIMIT 10];
    result = SB_NC_UpdateByCardLcController.getUserInfo(users[0].Id);
    res = (SB_NC_UpdateByCardLcController.GetUserInfoResponse)JSON.deserializeStrict(result, SB_NC_UpdateByCardLcController.GetUserInfoResponse.class);
    System.assertEquals(true, res.success);

    // ユーザのIDではないので、エラー
    List<NameCard__c> objs = [SELECT Id, Name FROM NameCard__c LIMIT 10];
    result = SB_NC_UpdateByCardLcController.getUserInfo(objs[0].Id);
    res = (SB_NC_UpdateByCardLcController.GetUserInfoResponse)JSON.deserializeStrict(result, SB_NC_UpdateByCardLcController.GetUserInfoResponse.class);
    System.assertEquals(false, res.success);

    Test.stopTest();
  }

  @isTest
  static void test_Over1000() {
    TestDb db = new TestDb();
    db.initialize();
    db.insertNameCardOver1000();
    db.insertAccountContact();

    Test.startTest();
    List<NameCard__c> cards = [SELECT Id, Name FROM NameCard__c WHERE person_name_last__c='名刺' AND person_name_first__c='太郎' AND email__c='taro@test.com' AND company_name__c='テスト本舗 株式会社'];
    System.assert(cards.size() > 1000);

    SB_NC_UpdateByCardLcController.GetNamecardsResponse res;
    String result;

    // アカウントから更新用の名刺取得
    List<Account> acnts = [SELECT Id FROM Account WHERE Name ='テスト本舗 株式会社'];
    result = SB_NC_UpdateByCardLcController.getNamecards(acnts[0].Id);
    Map<String, Object> resM = (Map<String, Object>)JSON.deserializeUntyped(result);
    System.assertEquals(true, (Boolean)resM.get('success'));
    List<Object> cardsList = (List<Object>)resM.get('cards');
    System.assertEquals(20, cardsList.size());

    // コンタクトから更新用の名刺取得
    List<Contact> conts = [SELECT Id FROM Contact WHERE EMail ='taro@test.com' AND AccountId = :acnts[0].Id];
    result = SB_NC_UpdateByCardLcController.getNamecards(conts[0].Id);
    resM = (Map<String, Object>)JSON.deserializeUntyped(result);
    System.assertEquals(true, (Boolean)resM.get('success'));
    cardsList = (List<Object>)resM.get('cards');
    System.assert(cardsList.size() > 0);
    Test.stopTest();
  }

  // 取引先責任者クエリテスト
  @isTest
  static void test_ContactSearchNameCard() {
    //姓名一致,メールnull
    NameCard__c nc1 = new NameCard__c(Name = 'TestName',
                                      person_name_last__c = 'last',
                                      person_name_first__c = 'first');
    //姓名一致しない,メール一致
    NameCard__c nc2 = new NameCard__c(Name = 'TestName',
                                      person_name_last__c = 'testLast',
                                      person_name_first__c = 'testFirst',
                                      email__c = 'Test@Test.com');
    //姓名一致,メール一致
    NameCard__c nc3 = new NameCard__c(Name = 'TestName',
                                      person_name_last__c = 'last',
                                      person_name_first__c = 'first',
                                      email__c = 'Test@Test.com');
    //姓名一致しない,メール一致しない
    NameCard__c nc4 = new NameCard__c(Name = 'TestName',
                                      person_name_last__c = 'Testlast',
                                      person_name_first__c = 'Testfirst');
    //姓名なし,メールなし
    NameCard__c nc5 = new NameCard__c(Name = 'TestName');
    insert new NameCard__c[]{nc1, nc2, nc3, nc4, nc5};
    //姓名だけ
    Contact co = new Contact(LastName = 'last',
                             FirstName = 'first');
    //メールだけ
    Contact co1 = new Contact(LastName = 'Testl',
                              Email = 'Test@Test.com');
    //一致名刺がない
    Contact co2 = new Contact(LastName = 'last',
                              FirstName = 'first',
                              Email = 'Test@Test.com');
    insert new Contact[]{co, co1, co2};
    Test.startTest();
    SB_NC_UpdateByCardLcController.GetNamecardsResponse res = null;
    String result;

    // コンタクトでテスト
    result = SB_NC_UpdateByCardLcController.getNamecards(co.Id);
    res = (SB_NC_UpdateByCardLcController.GetNamecardsResponse)JSON.deserializeStrict(result, SB_NC_UpdateByCardLcController.GetNamecardsResponse.class);
    System.assert(String.isBlank(res.error));
    System.assertEquals(res.cards.size(), 0);
    // メールアドレスで検索
    contactSearchAssert(co.Id, '1', 0);
    // 姓名で検索
    contactSearchAssert(co.Id, '2', 2);

    result = SB_NC_UpdateByCardLcController.getNamecards(co1.Id);
    res = (SB_NC_UpdateByCardLcController.GetNamecardsResponse)JSON.deserializeStrict(result, SB_NC_UpdateByCardLcController.GetNamecardsResponse.class);
    System.assert(String.isBlank(res.error));
    System.assertEquals(res.cards.size(), 0);
    // メールアドレスで検索
    contactSearchAssert(co1.Id, '1', 2);
    // 姓名で検索
    contactSearchAssert(co1.Id, '2', 0);

    result = SB_NC_UpdateByCardLcController.getNamecards(co2.Id);
    Map<String, Object> resM = (Map<String, Object>)JSON.deserializeUntyped(result);
    System.assert(String.isBlank((String)resM.get('error')));
    List<Object> cards = (List<Object>)resM.get('cards');
    System.assertEquals(cards.size(), 1);
    // メールアドレスで検索
    contactSearchAssert(co2.Id, '1', 2);
    // 姓名で検索
    contactSearchAssert(co2.Id, '2', 2);

    Test.stopTest();
  }

  private static void contactSearchAssert(Id coId, String searchType, Integer size) {
    String result = SB_NC_UpdateByCardLcController.searchData(coId, searchType);
    Map<String, Object> res = (Map<String, Object>)JSON.deserializeUntyped(result);
    System.assert(String.isBlank((String)res.get('error')));
    List<Object> cards = (List<Object>)res.get('cards');
    System.assertEquals(cards.size(), size);
  }


}