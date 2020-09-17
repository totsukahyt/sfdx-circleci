/**
 *  SB_NC_RegistOptionCreaterTest
 *    SB_NC_RegistOptionCreater のテストクラス
 *
 * Copyright (C) 2016 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2016.10.xx
 *  @Version 2.5    2020.03.xx SV_DEV-2146 LEX 取引先登録 個別：取引先の日付（カスタム項目）をマッピングに設定した際に登録先候補で表示されるポップアップが日付で表示されない
 *
 **/
@isTest
public class SB_NC_RegistOptionCreaterTest
{
  public class TestDb extends SB_NC_TestDB {

    public override void initialize() {
      // // SmartVisca設定
      // initializeSmartViscaConfig();
      // if (svConfig != null) {
      //   upsert svConfig;
      // }
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


  @isTest
  static void test_GetRegistOptions_soql() {
    // カスタム設定は 名刺トリガが動く前にセット
    SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    svConfig.SRegistQueryAccountFields1__c = 'BillingPostalCode:3,BillingState:2,BillingCity:3, BillingStreet:3, Site:2, ShippingAddress:2'; // ShippingAddress を追加
    // svConfig.AccountRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(個別) 登録先候補の検索方法 SOQL　に
    svConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL　に
    upsert svConfig;

    TestDb db = new TestDb();
    db.initialize();

    Test.startTest();
    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.getSObjectType());
    qo_a.bulkRegist = true;
    qo_a.queryDept = true;
    qo_a.queryState = true;
    qo_a.queryCity = true;
    qo_a.queryZip = true;
    SB_NC_RegistQueryOption qo_c = new SB_NC_RegistQueryOption(Contact.getSObjectType());
    qo_c.bulkRegist = true;
    qo_c.queryDept = true;
    qo_c.queryState = true;
    qo_c.queryCity = true;
    qo_c.queryZip = true;
    List<NameCard__c> cards = [SELECT Id, Name FROM NameCard__c LIMIT 100];
    List<Id> ncIds = new List<Id>();
    for (NameCard__c card : cards) {
      ncIds.add(card.Id);
    }
    // SB_NC_RegistOptionCreater.RegistOptionRequest req = new SB_NC_RegistOptionCreater.RegistOptionRequest(ncIds, opt);
    // SB_NC_RegistOptionCreater creater = new SB_NC_RegistOptionCreater();
    List<SB_NC_RegistOptionCreater.Card_RegistOption> reg_opts = SB_NC_RegistOptionCreater.getRegistOptions(ncIds, new List<SB_NC_RegistQueryOption> { qo_a, qo_c });
    System.assertEquals(cards.size(), reg_opts.size());
    for (SB_NC_RegistOptionCreater.Card_RegistOption reg_opt : reg_opts) {
      System.assertEquals(3, reg_opt.options.size());
    }
    Test.stopTest();
  }

  @isTest
  static void testGetRegistOptionsRecType_sosl() {
    // カスタム設定は 名刺トリガが動く前にセット
    SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    svConfig.SRegistQueryAccountFields1__c = 'BillingPostalCode:3,BillingState:2,BillingCity:3, BillingStreet:3, Site:2, ShippingAddress:2'; // ShippingAddress を追加
    // svConfig.AccountRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(個別) 登録先候補の検索方法 SOQL　に
    svConfig.AccountBulkRegistSearchMethod__c = 1; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL　に
    upsert svConfig;

    TestDb db = new TestDb();
    db.initialize();


    Test.startTest();
    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.getSObjectType());
    qo_a.bulkRegist = true;
    qo_a.queryDept = true;
    qo_a.queryState = true;
    qo_a.queryCity = true;
    qo_a.queryZip = true;
    qo_a.acntRecTypeIds = new List<Id>(Account.sObjectType.getDescribe().getRecordTypeInfosById().keySet());
    qo_a.contRecTypeIds = new List<Id>(Contact.sObjectType.getDescribe().getRecordTypeInfosById().keySet());
    SB_NC_RegistQueryOption qo_c = new SB_NC_RegistQueryOption(Contact.getSObjectType());
    qo_c.bulkRegist = true;
    qo_c.queryDept = true;
    qo_c.queryState = true;
    qo_c.queryCity = true;
    qo_c.queryZip = true;
    qo_c.acntRecTypeIds = new List<Id>(Account.sObjectType.getDescribe().getRecordTypeInfosById().keySet());
    qo_c.contRecTypeIds = new List<Id>(Contact.sObjectType.getDescribe().getRecordTypeInfosById().keySet());
    List<NameCard__c> cards = [SELECT Id, Name FROM NameCard__c LIMIT 100];
    List<Id> ncIds = new List<Id>();
    for (NameCard__c card : cards) {
      ncIds.add(card.Id);
    }
    // SB_NC_RegistOptionCreater.RegistOptionRequest req = new SB_NC_RegistOptionCreater.RegistOptionRequest(ncIds, opt);
    // SB_NC_RegistOptionCreater creater = new SB_NC_RegistOptionCreater();
    List<SB_NC_RegistOptionCreater.Card_RegistOption> reg_opts = SB_NC_RegistOptionCreater.getRegistOptions(ncIds, new List<SB_NC_RegistQueryOption> { qo_a, qo_c });
    System.assertEquals(cards.size(), reg_opts.size());
    Test.stopTest();
  }

  @isTest
  static void test_getAccountOptions_sosl() {
    // カスタム設定は 名刺トリガが動く前にセット
    SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    svConfig.SRegistQueryAccountFields1__c = 'BillingPostalCode:3,BillingState:2,BillingCity:3, BillingStreet:3, Site:2, ShippingAddress:2'; // ShippingAddress を追加
    svConfig.AccountRegistSearchMethod__c = 1; // 取引先・取引先任者に登録(個別) 登録先候補の検索方法 SOSL　に
    // svConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL　に
    upsert svConfig;

    TestDb db = new TestDb();
    db.initialize();

    Test.startTest();
    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.getSObjectType());

    List<NameCard__c> cards = [SELECT Id, Name, company_name__c, division__c FROM NameCard__c LIMIT 10];

    // SB_NC_RegistOptionCreater.RegistOptionRequest req = new SB_NC_RegistOptionCreater.RegistOptionRequest(ncIds, opt);
    // SB_NC_RegistOptionCreater creater = new SB_NC_RegistOptionCreater();
    List<SB_NC_RegistOptionCreater.RegistOption> reg_opts = SB_NC_RegistOptionCreater.getAccountOptions(cards[0].Id, qo_a);

    String corp = SB_NameCard_Util.getCompanyName(cards[0].company_name__c);
    System.debug('corp: ' + corp);
    for (SB_NC_RegistOptionCreater.RegistOption reg_opt : reg_opts) {
      System.debug(reg_opt.title);
      System.assert(reg_opt.type != SB_NC_RegistOptionCreater.OPT_MATH || reg_opt.title.contains(corp));
    }
    Test.stopTest();
  }

  @isTest
  static void test_getAccountOptions_soql() {
    // カスタム設定は 名刺トリガが動く前にセット
    SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    svConfig.SRegistQueryAccountFields1__c = 'BillingPostalCode:3,BillingState:2,BillingCity:3, BillingStreet:3, Site:2, ShippingAddress:2'; // ShippingAddress を追加
    svConfig.AccountRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(個別) 登録先候補の検索方法 SOQL　に
    // svConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL　に
    upsert svConfig;

    TestDb db = new TestDb();
    db.initialize();

    Test.startTest();
    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.getSObjectType());

    List<NameCard__c> cards = [SELECT Id, Name, company_name__c, division__c FROM NameCard__c LIMIT 10];

    // SB_NC_RegistOptionCreater.RegistOptionRequest req = new SB_NC_RegistOptionCreater.RegistOptionRequest(ncIds, opt);
    // SB_NC_RegistOptionCreater creater = new SB_NC_RegistOptionCreater();
    List<SB_NC_RegistOptionCreater.RegistOption> reg_opts = SB_NC_RegistOptionCreater.getAccountOptions(cards[0].Id, qo_a);

    String corp = SB_NameCard_Util.getCompanyName(cards[0].company_name__c);
    System.debug('corp: ' + corp);
    for (SB_NC_RegistOptionCreater.RegistOption reg_opt : reg_opts) {
      System.debug(reg_opt.title);
      System.assert(reg_opt.type != SB_NC_RegistOptionCreater.OPT_MATH || reg_opt.title.contains(corp));
    }
    Test.stopTest();
  }

  @isTest
  static void test_getContactOptions() {
    TestDb db = new TestDb();
    db.initialize();

    Test.startTest();
    SB_NC_RegistQueryOption qo_c = new SB_NC_RegistQueryOption(Contact.getSObjectType());

    List<NameCard__c> cards = [SELECT Id, Name, company_name__c, division__c, title_name__c, email__c FROM NameCard__c LIMIT 10];

    // SB_NC_RegistOptionCreater.RegistOptionRequest req = new SB_NC_RegistOptionCreater.RegistOptionRequest(ncIds, opt);
    // SB_NC_RegistOptionCreater creater = new SB_NC_RegistOptionCreater();
    List<SB_NC_RegistOptionCreater.RegistOption> reg_opts = SB_NC_RegistOptionCreater.getContactOptions(cards[0].Id, qo_c);

    System.debug('email__c: ' + cards[0].email__c);
    for (SB_NC_RegistOptionCreater.RegistOption reg_opt : reg_opts) {
      System.debug(reg_opt.label2val !=null ? reg_opt.label2val.get('Email') : 'no email');
      System.assert(reg_opt.type != SB_NC_RegistOptionCreater.OPT_MATH || reg_opt.label2val.get('Email') == cards[0].email__c);
    }
    Test.stopTest();
  }


  // v2.5 2020.03.xx SV_DEV-2301 S1 取引先登録：S取引先登録時表示する取引先の項目1,2 に 複合住所項目 を指定した場合、JSON形式のまま表示される。
  @isTest
  static void test_AddressValues() {
    TestDb db = new TestDb();
    db.initialize();
    SB_NameCard_Util.smartViscaConfig.SRegistQueryAccountFields1__c = 'Site:2, ShippingAddress:2, BillingAddress:2';

    Account acnt = [SELECT Id, Name, OwnerId, Owner.Name, Site, ShippingAddress, BillingAddress FROM Account LIMIT 1];
    SB_NC_RegistOptionCreater.RegistOption opt = new SB_NC_RegistOptionCreater.RegistOption(acnt, 0, SB_NC_RegistOptionCreater.OPT_MATH);

    Address a = (Address)acnt.ShippingAddress;
    String address = String.format(System.Label.SB_NC_AddressFormat,
              new String[] { String.isNotBlank(a.getCountry())? a.getCountry() : '',
                              String.isNotBlank(a.getCountryCode())? a.getCountryCode() : '',
                              String.isNotBlank(a.getPostalCode())? a.getPostalCode() : '',
                              String.isNotBlank(a.getState())? a.getState() : '',
                              String.isNotBlank(a.getStateCode())? a.getStateCode() : '',
                              String.isNotBlank(a.getCity())? a.getCity() : '',
                              String.isNotBlank(a.getStreet())? a.getStreet() : '' });
    String label = Account.ShippingAddress.getDescribe().getLabel();
    System.assertEquals(address, opt.label2val.get(label));
  }

  // SV_DEV-2146 LEX 取引先登録 個別：取引先の日付（カスタム項目）をマッピングに設定した際に登録先候補で表示されるポップアップが日付で表示されない
  @isTest
  static void test_DateTimeValue() {
    TestDb db = new TestDb();
    db.initialize();
    SB_NameCard_Util.smartViscaConfig.SRegistQueryAccountFields1__c = 'Site:2, CreatedDate:2';

    DateTime dt = Datetime.now().addDays(-5);
    for (Account rec :[SELECT Id FROM Account]) {
      Test.setCreatedDate(rec.Id, dt);
    }

    Account acnt = [SELECT Id, Name, OwnerId, Owner.Name, Site, CreatedDate FROM Account LIMIT 1];
    SB_NC_RegistOptionCreater.RegistOption opt = new SB_NC_RegistOptionCreater.RegistOption(acnt, 0, SB_NC_RegistOptionCreater.OPT_MATH);
    String label = Account.CreatedDate.getDescribe().getLabel();
    System.assertEquals(Datetime.now().addDays(-5).format(), opt.label2val.get(label));
  }

  // SV_DEV-2146 LEX 取引先登録 個別：取引先の日付（カスタム項目）をマッピングに設定した際に登録先候補で表示されるポップアップが日付で表示されない
  @isTest
  static void test_DateValue() {
    TestDb db = new TestDb();
    db.initialize();
    SB_NameCard_Util.smartViscaConfig.SRegistQueryContactFields1__c = 'Birthdate:2';
    List<Contact> conts = [SELECT Id, Name, Birthdate, AccountId  FROM Contact];
    for (Contact cont : conts) {
      cont.Birthdate = Date.today().addDays(-1); // 昨日
    }
    update conts;

    Contact cont = [SELECT Id, Name, OwnerId, Owner.Name, AccountId, Department, Title, EMail, FirstName, LastName, Birthdate FROM Contact LIMIT 1];
    SB_NC_RegistOptionCreater.RegistOption opt = new SB_NC_RegistOptionCreater.RegistOption(cont, 0, SB_NC_RegistOptionCreater.OPT_MATH);
    String label = Contact.Birthdate.getDescribe().getLabel();
    System.assertEquals(Date.today().addDays(-1).format(), opt.label2val.get(label));
  }

}