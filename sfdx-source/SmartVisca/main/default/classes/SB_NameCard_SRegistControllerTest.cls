/**
 *
 * SB_NameCard_SRegistControllerTest
 * Salesforce1対応 SmartVisca 取引先・取引先責任者へ登録 画面の コンロローラ のテストクラス
 *
 * Copyright (C) 2016 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2016.04.xx
 *  @Version 2      2017.10.xx  v1.21 for code scan
 *  @Version 3      2018.01.xx v1.22 SV_DEV-435 S1の取引先･取引先責任者に登録のマッピングとLEX・Classicのマッピングを同じにします。
 *  @Version 2.1    2018.11.xx SV_DEV-1346 S1 取引先登録で、遷移元を識別し戻る
 *  @Version 2.5    2020.03.xx SV_DEV-2146 LEX 取引先登録 個別：取引先の日付（カスタム項目）をマッピングに設定した際に登録先候補で表示されるポップアップが日付で表示されない
 *
 **/
@isTest
private class SB_NameCard_SRegistControllerTest {

  public class TestDb extends SB_NC_TestDB {
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
      // 名刺基本設定
      initializeBasicSetting();
      if (!listBasicSetting.isEmpty()) {
        insert listBasicSetting;
      }
      // 名刺連携項目マッピング
      initializeMapping();
      if (!listMapping.isEmpty()) {
        insert listMapping;
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
  } // public class TestDb extends SB_NC_TestDB

  public class TestDb_NoAccount_NoContact extends SB_NC_TestDB {
    public override void initialize() {
      // Smarta設定
      initializeSmartViscaConfig();
      if (svConfig !=null) {
        upsert svConfig;
      }
       // ユーザ
      initializeUser();
      if (listUser.isEmpty() == false) {
        insert listUser;
      }
      // 名刺基本設定
      initializeBasicSetting();
      if (!listBasicSetting.isEmpty()) {
        insert listBasicSetting;
      }
      // 名刺連携項目マッピング
      initializeMapping();
      if (!listMapping.isEmpty()) {
        insert listMapping;
      }
      // 名刺関係
      initializeKaisha();     // 会社を揃えておく
      initializeEmployee();   // 会社ごとに名刺の人を揃えておく
      // 名刺
      initializeNameCard();
      if (listCard.isEmpty() == false) {
        insert listCard;
      }
    }
  } // public class TestDb_NoAccount_NoContact extends SB_NC_TestDB



  // 画面コントローラとしてのテスト
  @isTest
  static void testLaunchPage() {
    TestDb_NoAccount_NoContact db = new TestDb_NoAccount_NoContact();
    db.initialize();

    List<NameCard__c> cards = [SELECT Id FROM NameCard__c LIMIT 10];
    Test.startTest();
    PageReference pageRef = Page.SB_NameCard_SRegistIndex;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(cards[0]);
    SB_NameCard_SRegistController ctrl = new SB_NameCard_SRegistController(sc);
    ctrl.init();
    System.assertEquals(cards[0].Id, ctrl.card.Id);
    System.debug(ctrl.getNameSpace());
    System.debug(ctrl.getDevMode());
    System.debug(SB_NameCard_SRegistController.getConfig());
    Test.stopTest();
  }

  // 画面コントローラとしてのテスト クエリパラメータが不正
  @isTest
  static void testLaunchPageInvalidParameter() {
    TestDb_NoAccount_NoContact db = new TestDb_NoAccount_NoContact();
    db.initialize();

    Test.startTest();
    PageReference pageRef = Page.SB_NameCard_SRegistIndex;
    Test.setCurrentPage(pageRef);
    SB_NameCard_SRegistController ctrl = new SB_NameCard_SRegistController();
    Boolean ng = false;
    try {
      ctrl.init();
    }
    catch(Exception e) {
      ng = true;
    }
    System.assertEquals(true, ng);
    Test.stopTest();
  }

  @isTest
  static void testEtc() {
    // 2017.10.xx  v1.21 for code scan Test Methods With No Assert
    SB_NameCard_S1Config config = SB_NameCard_SRegistController.getConfig();
    System.assertEquals(UserInfo.getUserId(), config.userId);
  }

  // getRecordTypeInfo
  @isTest
  static void testGetRecordTypeInfo() {
    List<SB_NameCard_SRegistController.RecordTypeInfo> accountRecTypeInfos = SB_NameCard_SRegistController.getRecordTypeInfo('Account');
    Map<String, Schema.RecordTypeInfo> mapRecordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
    Integer cnt = 0;
    for (Schema.RecordTypeInfo info : mapRecordTypes.values()) {
      if (info.isAvailable() == false) continue;   // ユーザが使用可能なものだけ
      if (info.isMaster() == true) continue;   // マスターは除外
      cnt++;
    }
    System.assertEquals(cnt, accountRecTypeInfos.size());
  }

  // ID指定で名刺情報を取得
  @isTest
  static void testGetNameCard() {
    TestDb_NoAccount_NoContact db = new TestDb_NoAccount_NoContact();
    db.initialize();

    Test.startTest();
    List<NameCard__c> cards = [SELECT Id, Name FROM NameCard__c LIMIT 10];
    SB_NameCard_SController.NameCardDTO cardDto = SB_NameCard_SRegistController.getNameCard(cards[0].Id);
    System.assertEquals(cards[0].Name, cardDto.name);
    Test.stopTest();
  }

  // ID指定で名刺情報を取得
  @isTest
  static void testGetNameCardInvalidId() {
    TestDb_NoAccount_NoContact db = new TestDb_NoAccount_NoContact();
    db.initialize();

    Test.startTest();
    Boolean ng = false;
    try {
      SB_NameCard_SController.NameCardDTO cardDto = SB_NameCard_SRegistController.getNameCard('123456789012345678');
    }
    catch(Exception e) {
      ng = true;
    }
    System.assertEquals(true, ng);
    Test.stopTest();
  }

  @isTest
  static void testGetSimpleNameCardInvalidId() {
    TestDb_NoAccount_NoContact db = new TestDb_NoAccount_NoContact();
    db.initialize();

    Test.startTest();
    Boolean ng = false;
    try {
      NameCard__c obj = SB_NameCard_SRegistController.getSimpleNameCard('123456789012345678');
    }
    catch(Exception e) {
      ng = true;
    }
    System.assertEquals(true, ng);
    Test.stopTest();
  }

  @isTest
  static void testGetContactNameSet() {
    NameCard__c card = new NameCard__c(person_name_last__c='姓');
    Set<String> names = SB_NameCard_SRegistController.getContactNameSet(card);
    System.assert(names.isEmpty() == false);
  }

  // 取引先の登録オプションを取得する
  @isTest
  static void testGetAccountOptions() {
    TestDb_NoAccount_NoContact db = new TestDb_NoAccount_NoContact();
    db.initialize();

    SB_NameCard_SRegistController.QueryOption queryOpt = new SB_NameCard_SRegistController.QueryOption();
    List<NameCard__c> cards = [SELECT Id, Name FROM NameCard__c LIMIT 10];
    List<SB_NameCard_SRegistController.RegistOption> res = SB_NameCard_SRegistController.getAccountOptions(cards[0].Id, queryOpt);
    System.assertEquals(2, res.size());
  }

  // 取引先の登録オプションを取得する 既存取引先あり
  @isTest
  static void testGetAccountOptions2() {
    TestDb db = new TestDb();
    db.initialize();

    SB_NameCard_SRegistController.QueryOption queryOpt = new SB_NameCard_SRegistController.QueryOption();
    List<NameCard__c> cards = [SELECT Id, Name FROM NameCard__c LIMIT 10];
    List<SB_NameCard_SRegistController.RegistOption> res = SB_NameCard_SRegistController.getAccountOptions(cards[0].Id, queryOpt);
    System.assertEquals(3, res.size());
  }

  // 取引先の登録オプションを取得する レコードタイプを指定してみる
  @isTest
  static void testGetAccountOptions3() {
    TestDb_NoAccount_NoContact db = new TestDb_NoAccount_NoContact();
    db.initialize();

    SB_NameCard_SRegistController.QueryOption queryOpt = new SB_NameCard_SRegistController.QueryOption();
    queryOpt.querySite = true;
    queryOpt.queryState = true;
    queryOpt.queryCity = true;
    queryOpt.queryZip = true;
    queryOpt.acntRecTypeIds = new List<String>();
    queryOpt.acntRecTypeIds.add('123456789012345678');
    queryOpt.contRecTypeIds = new List<String>();
    queryOpt.contRecTypeIds.add('123456789012345678');
    List<NameCard__c> cards = [SELECT Id, Name FROM NameCard__c LIMIT 10];
    List<SB_NameCard_SRegistController.RegistOption> res = SB_NameCard_SRegistController.getAccountOptions(cards[0].Id, queryOpt);
    System.assert(res.size() >= 2); // 値が一致するものはなくて、その他指定と新規の2つ
  }

  // 取引先責任者の登録オプションを取得する
  @isTest
  static void testGetContactOptions() {
    TestDb db = new TestDb();
    db.initialize();

    List<Contact> conts = [SELECT Id, Name, Email, AccountId FROM Contact LIMIT 10];
    List<NameCard__c> cards = [SELECT Id FROM NameCard__c WHERE email__c = :conts[0].Email];

    SB_NameCard_SRegistController.QueryOption queryOpt = new SB_NameCard_SRegistController.QueryOption();
    List<SB_NameCard_SRegistController.RegistOption> res = SB_NameCard_SRegistController.getContactOptions(cards[0].Id, conts[0].AccountId, queryOpt);
    System.assertEquals(3, res.size());
  }


  // 取引先責任者の登録オプションを取得する レコードタイプを指定してみる
  @isTest
  static void testGetContactOptions2() {
    TestDb db = new TestDb();
    db.initialize();

    List<Contact> conts = [SELECT Id, Name, Email, AccountId FROM Contact LIMIT 10];
    List<NameCard__c> cards = [SELECT Id FROM NameCard__c WHERE email__c = :conts[0].Email];

    SB_NameCard_SRegistController.QueryOption queryOpt = new SB_NameCard_SRegistController.QueryOption();
    queryOpt.contRecTypeIds = new List<String>();
    queryOpt.contRecTypeIds.add('123456789012345678');
    List<SB_NameCard_SRegistController.RegistOption> res = SB_NameCard_SRegistController.getContactOptions(cards[0].Id, conts[0].AccountId, queryOpt);
    System.assert(res.size() >= 2);
  }

  // getRecentlyViewed
  @isTest
  static void testGetRecentlyViewed() {
    TestDb db = new TestDb();
    db.initialize();
    List<Account> acnts = [SELECT Name FROM Account limit 100];
    for (Account acnt : acnts) {
      System.debug(acnt.Name);
    }
    List<String> namesA = SB_NameCard_SRegistController.getRecentlyViewed('Account', null);
    List<String> recTypes = new List<String> {'1234567890', '1234567890'};
    namesA = SB_NameCard_SRegistController.getRecentlyViewed('Account', recTypes);

    System.runAs(db.listUser[0]) {
      List<String> namesC = SB_NameCard_SRegistController.getRecentlyViewed('Contact', recTypes);
      System.assertEquals(0, namesC.size());
    }
  }


  // getAccountContacts
  @isTest
  static void testGetAccountContacts() {
    TestDb db = new TestDb();
    db.initialize();
    List<Account> acnts = [SELECT Name FROM Account limit 2];
    List<Contact> conts = [SELECT Name FROM Contact WHERE AccountId = :acnts[0].Id];
    for (Contact cont : conts) {
      System.debug(cont.Name);
    }
    List<String> names = SB_NameCard_SRegistController.getAccountContacts(acnts[0].Id, null);
    System.assertEquals(conts.size(), names.size());

    // レコードタイプが辺で例外
    Boolean bFalt = false;
    List<String> recTypes = new List<String> {'1234567890', '1234567890'};
    try {
      names = SB_NameCard_SRegistController.getAccountContacts(acnts[0].Id, recTypes);
    }
    catch(Exception ex) {
      bFalt = true;
    }
    System.assertEquals(0, names.size());
  }

  // 取引先のSearch
  @isTest
  static void testSearchAccount() {
    TestDb db = new TestDb();
    db.initialize();

    List<Account> acnts = [SELECT Id, Name FROM Account];
    Id[] ids = new Id[1];
    ids[0] = acnts[0].Id;
    Test.setFixedSearchResults(ids);
    List<SB_NameCard_SRegistController.RegistOption> res = SB_NameCard_SRegistController.searchAccount(acnts[0].Name, null);
    System.assertEquals(1, res.size());

    // レコードタイプが辺で例外
    Boolean bFalt = false;
    List<String> recTypes = new List<String> {'1234567890', '1234567890'};
    try {
      res = SB_NameCard_SRegistController.searchAccount(acnts[0].Name, recTypes);
    }
    catch(Exception ex) {
      bFalt = true;
    }
    System.assertEquals(0, res.size());
  }

  // 取引責任者のSearch
  @isTest
  static void testSearchContact() {
    TestDb db = new TestDb();
    db.initialize();

    List<Contact> conts = [SELECT Id, Email, AccountId FROM Contact];
    Id[] ids = new Id[1];
    ids[0] = conts[0].Id;
    Test.setFixedSearchResults(ids);
    List<SB_NameCard_SRegistController.RegistOption> res = SB_NameCard_SRegistController.searchContact(conts[0].Email, conts[0].AccountId, null);
    System.assertEquals(1, res.size());

    // レコードタイプが辺で例外
    Boolean bFalt = false;
    List<String> recTypes = new List<String> {'1234567890', '1234567890'};
    try {
      res = SB_NameCard_SRegistController.searchContact(conts[0].Email, conts[0].AccountId, recTypes);
    }
    catch(Exception ex) {
      bFalt = true;
    }
    System.assertEquals(0, res.size());
  }


  //@isTest
  //static void testGetDMLErrorMsg() {
  //  Account obj = new Account();
  //  Database.SaveResult result = Database.insert(obj, false);
  //  String msg = SB_NameCard_SRegistController.getDMLErrorMsg(result.getErrors());
  //  System.assert(msg.length() != 0);
  //}


  // 取引先登録(registAccountContact)のテスト
  // 新規アカウント、新規コンタクト
  @isTest
  static void testRegistAccountContactInsert() {
    TestDb_NoAccount_NoContact db = new TestDb_NoAccount_NoContact();
    db.initialize();

    List<NameCard__c> cards = [SELECT Id, Name FROM NameCard__c];
    //SB_NameCard_SRegistController.RegistTarget target = new SB_NameCard_SRegistController.RegistTarget(cards[0].Id, null, null, null, false, null);
    SB_NameCard_SRegistController.RegistRequest req = new SB_NameCard_SRegistController.RegistRequest(
      // new SB_NameCard_SRegistController.RegistTarget(Id cardId, Id acntId, Id contId, Id someId, Boolean createTodo, Date todoDate)
      new List<SB_NameCard_SRegistController.RegistTarget> { new SB_NameCard_SRegistController.RegistTarget(cards[0].Id, null, null, null, false, null) },
      // RegistParam(String objName, Boolean overwrite, Id recTypeId, Id ownerId, Boolean allowSave)
      new SB_NameCard_SRegistController.RegistParam('Account', true, null, null, false),
      new SB_NameCard_SRegistController.RegistParam('Contact', true, null, null, false),
      null,
      null
    );
    SB_NC_RegistExecutor.RegistResponse result = SB_NameCard_SRegistController.registAccountContact(req);
    System.assertEquals(true, result.success);
    System.assert(result.registeds.values()[0].acnt != null);
    System.assert(result.registeds.values()[0].cont != null);
    NameCard__c card = [SELECT Id, Name, account__c, contact__c FROM NameCard__c WHERE Id = :cards[0].Id];
    System.assertEquals(result.registeds.values()[0].acnt.Id, card.account__c);
    System.assertEquals(result.registeds.values()[0].cont.Id, card.contact__c);
  }

  // 取引先登録(registAccountContact)のテスト
  // 既存アカウント、既存コンタクト
  @isTest
  static void testRegistAccountContactUpdate() {
    TestDb db = new TestDb();
    db.initialize();
    List<NameCard__c> cards = [SELECT Id, Name FROM NameCard__c];
    List<Account> acnts = [SELECT Id, Name FROM Account];
    List<Contact> conts = [SELECT Id, Name FROM Contact];
    //SB_NameCard_SRegistController.RegistRequest req = new SB_NameCard_SRegistController.RegistRequest(
    //  cards[0].Id,
    //  new SB_NameCard_SRegistController.RegistParam(acnts[0].Id, true, null),
    //  new SB_NameCard_SRegistController.RegistParam(conts[0].Id, true, null)
    //);
    SB_NameCard_SRegistController.RegistRequest req = new SB_NameCard_SRegistController.RegistRequest(
      // new SB_NameCard_SRegistController.RegistTarget(Id cardId, Id acntId, Id contId, Id someId, Boolean createTodo, Date todoDate)
      new List<SB_NameCard_SRegistController.RegistTarget> {
        new SB_NameCard_SRegistController.RegistTarget(
          cards[0].Id,
          acnts[0].Id,
          conts[0].Id,
          null, false, null)
      },
      // RegistParam(String objName, Boolean overwrite, Id recTypeId, Id ownerId, Boolean allowSave)
      new SB_NameCard_SRegistController.RegistParam('Account', true, null, null, false),
      new SB_NameCard_SRegistController.RegistParam('Contact', true, null, null, false),
      null,
      null
    );

    SB_NC_RegistExecutor.RegistResponse result = SB_NameCard_SRegistController.registAccountContact(req);
    System.assertEquals(true, result.success);
    System.assert(result.registeds.values()[0].acnt != null);
    System.assert(result.registeds.values()[0].cont != null);
    NameCard__c card = [SELECT Id, Name, account__c, contact__c FROM NameCard__c WHERE Id = :cards[0].Id];
    System.assertEquals(result.registeds.values()[0].acnt.Id, card.account__c);
    System.assertEquals(result.registeds.values()[0].cont.Id, card.contact__c);
  }

  // 取引先登録(registAccountContact)のNGテスト
  // 既存アカウント、既存コンタクト
  @isTest
  static void testRegistAccountContactUpdateNG() {
    TestDb db = new TestDb();
    db.initialize();
    List<NameCard__c> cards = [SELECT Id, Name FROM NameCard__c];
    List<Account> acnts = [SELECT Id, Name FROM Account];
    List<Contact> conts = [SELECT Id, Name FROM Contact];
    //SB_NameCard_SRegistController.RegistRequest req = new SB_NameCard_SRegistController.RegistRequest(
    //  cards[0].Id,
    //  new SB_NameCard_SRegistController.RegistParam(conts[0].Id, false, null),     // アカウントでなくコンタクト
    //  new SB_NameCard_SRegistController.RegistParam(acnts[0].Id, false, null)      // コンタクトでなくアカウント
    //);

    SB_NameCard_SRegistController.RegistRequest req = new SB_NameCard_SRegistController.RegistRequest(
      // new SB_NameCard_SRegistController.RegistTarget(Id cardId, Id acntId, Id contId, Id someId, Boolean createTodo, Date todoDate)
      new List<SB_NameCard_SRegistController.RegistTarget> {
        new SB_NameCard_SRegistController.RegistTarget(
          cards[0].Id,
          conts[0].Id, // アカウントでなくコンタクト
          acnts[0].Id, // コンタクトでなくアカウント
          null, false, null)
      },
      // RegistParam(String objName, Boolean overwrite, Id recTypeId, Id ownerId, Boolean allowSave)
      new SB_NameCard_SRegistController.RegistParam('Account', false, null, null, false),
      new SB_NameCard_SRegistController.RegistParam('Contact', false, null, null, false),
      null,
      null
    );


    SB_NC_RegistExecutor.RegistResponse result = SB_NameCard_SRegistController.registAccountContact(req);
    System.assertEquals(false, result.success);
  }

  @isTest
  static void testGetEnableAccess() {
    Boolean b = SB_NameCard_S1Config.getEnableAccess(Account.getSObjectType());
    System.assertEquals(true, b);
  }

  @isTest
  static void testUiTypeNullHandling() {
    TestDb db = new TestDb();
    db.initialize();
    List<NameCard__c> cards = [SELECT Id FROM NameCard__c LIMIT 10];
    System.assert(!cards.isEmpty());

    Test.startTest();
    PageReference pageRef = Page.SB_NameCard_SRegistIndex;
    Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('uitype', null);
    ApexPages.StandardController sc = new ApexPages.StandardController(cards[0]);
    SB_NameCard_SRegistController ctrl = new SB_NameCard_SRegistController(sc);
    ctrl.init();
    String retUrl = ctrl.buildReturnUrl();
    System.assertEquals(true, retUrl.contains('SB_NameCard_S1Index'));
  }

  @isTest
  static void testUiType2Handling() {
    TestDb db = new TestDb();
    db.initialize();
    List<NameCard__c> cards = [SELECT Id FROM NameCard__c LIMIT 10];
    System.assert(!cards.isEmpty());

    Test.startTest();
    PageReference pageRef = Page.SB_NameCard_SRegistIndex;
    Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('uitype', '2');
    ApexPages.StandardController sc = new ApexPages.StandardController(cards[0]);
    SB_NameCard_SRegistController ctrl = new SB_NameCard_SRegistController(sc);
    ctrl.init();
    String retUrl = ctrl.buildReturnUrl();
    System.assertEquals(true, retUrl.contains('SB_NameCard_SIndex'));
  }

  // v2.5 2020.03.xx SV_DEV-2301 S1 取引先登録：S取引先登録時表示する取引先の項目1,2 に 複合住所項目 を指定した場合、JSON形式のまま表示される。
  @isTest
  static void test_AddressValues() {
    TestDb db = new TestDb();
    db.initialize();
    SB_NameCard_Util.smartViscaConfig.SRegistQueryAccountFields1__c += ', ShippingAddress:2, BillingAddress:2';

    SB_NameCard_SRegistController.QueryOption queryOpt = new SB_NameCard_SRegistController.QueryOption();
    List<NameCard__c> cards = [SELECT Id, Name FROM NameCard__c LIMIT 10];
    List<SB_NameCard_SRegistController.RegistOption> res = SB_NameCard_SRegistController.getAccountOptions(cards[0].Id, queryOpt);
    Id aId = res[0].id;
    Address a = (Address)[SELECT Id, ShippingAddress FROM Account WHERE Id = :aId LIMIT 1].ShippingAddress;
    String address = String.format(System.Label.SB_NC_AddressFormat,
              new String[] { String.isNotBlank(a.getCountry())? a.getCountry() : '',
                              String.isNotBlank(a.getCountryCode())? a.getCountryCode() : '',
                              String.isNotBlank(a.getPostalCode())? a.getPostalCode() : '',
                              String.isNotBlank(a.getState())? a.getState() : '',
                              String.isNotBlank(a.getStateCode())? a.getStateCode() : '',
                              String.isNotBlank(a.getCity())? a.getCity() : '',
                              String.isNotBlank(a.getStreet())? a.getStreet() : '' });
    String label = Account.ShippingAddress.getDescribe().getLabel();
    System.assertEquals(address, res[0].label2val.get(label));

  }

  // SV_DEV-2146 LEX 取引先登録 個別：取引先の日付（カスタム項目）をマッピングに設定した際に登録先候補で表示されるポップアップが日付で表示されない
  @isTest
  static void test_DateTimeValue() {
    TestDb db = new TestDb();
    db.initialize();
    SB_NameCard_Util.smartViscaConfig.SRegistQueryAccountFields1__c += ', CreatedDate:2';

    DateTime dt = Datetime.now().addDays(-5);
    for (Account rec :[SELECT Id FROM Account]) {
      Test.setCreatedDate(rec.Id, dt);
    }

    SB_NameCard_SRegistController.QueryOption queryOpt = new SB_NameCard_SRegistController.QueryOption();
    List<NameCard__c> cards = [SELECT Id, Name FROM NameCard__c LIMIT 10];
    List<SB_NameCard_SRegistController.RegistOption> res = SB_NameCard_SRegistController.getAccountOptions(cards[0].Id, queryOpt);
    String label = Account.CreatedDate.getDescribe().getLabel();
    System.assertEquals(Datetime.now().addDays(-5).format(), res[0].label2val.get(label));
  }

  // SV_DEV-2146 LEX 取引先登録 個別：取引先の日付（カスタム項目）をマッピングに設定した際に登録先候補で表示されるポップアップが日付で表示されない
  @isTest
  static void test_DateValue() {
    TestDb db = new TestDb();
    db.initialize();
    SB_NameCard_Util.smartViscaConfig.SRegistQueryContactFields1__c += ', Birthdate:2';
    List<Contact> conts = [SELECT Id, Name, Birthdate, AccountId  FROM Contact];
    for (Contact cont : conts) {
      cont.Birthdate = Date.today().addDays(-1); // 昨日
    }
    update conts;

    SB_NameCard_SRegistController.QueryOption queryOpt = new SB_NameCard_SRegistController.QueryOption();
    List<NameCard__c> cards = [SELECT Id, Name, company_name__c FROM NameCard__c WHERE company_name__c != null LIMIT 10 ];
    String cName = cards[0].company_name__c;
    Contact cont = [SELECT Id, Name, AccountId FROM Contact WHERE Account.Name = :cName LIMIT 1];
    List<SB_NameCard_SRegistController.RegistOption> res = SB_NameCard_SRegistController.getContactOptions(cards[0].Id, cont.AccountId, queryOpt);
    String label = Contact.Birthdate.getDescribe().getLabel();
    System.assertEquals(Date.today().addDays(-1).format(), res[0].label2val.get(label));
  }

}