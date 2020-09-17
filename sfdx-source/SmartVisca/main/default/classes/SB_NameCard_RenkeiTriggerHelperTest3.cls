/**
 *
 * SB_NameCard_RenkeiTriggerHelperTest3
 *  自動連携機能の、おもに 複数既存アカウントあても、特定して更新する仕様のテスト用
 *   SV_DEV-585 自動連携で既存取引先責任者が一意に特定できるなら取引先があいまいでも重複エラーにしない
 *
 * Copyright (C) 2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2018.02.xx v1.22
 *
 **/
@isTest
private class SB_NameCard_RenkeiTriggerHelperTest3
{

  // 既存アカウントがない状態で、新規アカウント、コンタクトを作らない条件のテスト用
  public virtual class TestDb extends SB_NC_TestDB {

    public virtual override void initializeBasicSetting() {
      NameCardBasicSetting__c bs = SB_NC_PostInstallScript.createDefaultBasicSetting();
      bs.RenkeiActive__c = true;      // 自動連携機能有効
      bs.RenkeiAccountOverwrite__c = true;  // 既存の取引先を上書き
      bs.RenkeiContactOverwrite__c = true;   // 既存の取引先責任者を上書き
      bs.RenkeiAccountNOExistCreateNew__c = true;  //既存の取引先がなければ新規作成する
      bs.RenkeiContactNOExistCreateNew__c = true;  // 既存の取引先責任者がなければ新規作成する
      bs.RenkeiAccountCompany__c = true;   // アカウント 会社名
      bs.RenkeiAccountSite__c = false;        // アカウント 部署名
      bs.RenkeiAccountAddressPref__c = false;   // アカウント 都道府県
      bs.RenkeiAccount_Street__c = false;   // アカウント 町名・番地
      bs.RenkeiAccountZipCode__c = false;   // アカウント 郵便番号
      bs.RenkeiAccountCity__c = false;      // アカウント 市区郡
      bs.RenkeiAccountURL__c = false;       // アカウント URL
      bs.RenkeiAccountPhone__c = false;     // アカウント 電話番号
      //bs.RenkeiSpecificItems__c = null;        // アカウント 特定項目
      bs.RenkeiExcludeHojinkakuPartial__c = false;      // 自動連携:会社名は法人格を除いて部分一致
      bs.RenkeiExcludeHojinkaku__c = true;      // 自動連携:会社名は法人格を除いて完全一致
      bs.RenkeiAccountSitePartialMatch__c = true;      // 自動連携:部署は中間一致検索
      //bs.RenkeiContactMail__c = true;      // コンタクト メールアドレス
      //bs.RenkeiContactLastName__c = true;  // コンタクト ラストネーム
      //bs.RenkeiContactFirstName__c = false; // コンタクト ファーストネーム

      listBasicSetting.add(bs);
    }

    //public virtual override void initializeNameCard() {
    //  listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社テスト商事', division__c='本社',
    //                  zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
    //                  last_name__c='テスト', first_name__c='一郎', email__c='ichiro@test.com', delivery_type__c='2'));
    //}

    public virtual override void initialize() {
      initializeUser();
      if (listUser.isEmpty() == false)
        insert listUser;
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
      //// 名刺
      //initializeNameCard();
      //if (!listCard.isEmpty()) {
      //  insert listCard;
      //}
      //// 取引先
      //initializeAccount();  // 揃えた会社について、取引先を作る。
      //if (mapAccount.isEmpty() == false) {
      //  insert mapAccount.values();
      //}
      //// 取引先責任者
      //initializeContact();
      //if (!listContact.isEmpty()) {
      //  insert listContact;
      //}
    }
  } // TestDb

  // 既存アカウントがない状態で、新規アカウント、コンタクトを作らない条件のテスト用
  public virtual class TestDbLinkOnly extends TestDb {

    public virtual override void initializeBasicSetting() {
      NameCardBasicSetting__c bs = SB_NC_PostInstallScript.createDefaultBasicSetting();
      bs.RenkeiActive__c = true;      // 自動連携機能有効
      bs.RenkeiAccountOverwrite__c = false;  // 既存の取引先を上書き
      bs.RenkeiContactOverwrite__c = false;   // 既存の取引先責任者を上書き
      bs.RenkeiAccountNOExistCreateNew__c = false;  //既存の取引先がなければ新規作成する
      bs.RenkeiContactNOExistCreateNew__c = false;  // 既存の取引先責任者がなければ新規作成する
      bs.RenkeiAccountCompany__c = true;   // アカウント 会社名
      bs.RenkeiAccountSite__c = false;        // アカウント 部署名
      bs.RenkeiAccountAddressPref__c = false;   // アカウント 都道府県
      bs.RenkeiAccount_Street__c = false;   // アカウント 町名・番地
      bs.RenkeiAccountZipCode__c = false;   // アカウント 郵便番号
      bs.RenkeiAccountCity__c = false;      // アカウント 市区郡
      bs.RenkeiAccountURL__c = false;       // アカウント URL
      bs.RenkeiAccountPhone__c = false;     // アカウント 電話番号
      //bs.RenkeiSpecificItems__c = null;        // アカウント 特定項目
      bs.RenkeiExcludeHojinkakuPartial__c = false;      // 自動連携:会社名は法人格を除いて部分一致
      bs.RenkeiExcludeHojinkaku__c = true;      // 自動連携:会社名は法人格を除いて完全一致
      bs.RenkeiAccountSitePartialMatch__c = true;      // 自動連携:部署は中間一致検索
      //bs.RenkeiContactMail__c = true;      // コンタクト メールアドレス
      //bs.RenkeiContactLastName__c = true;  // コンタクト ラストネーム
      //bs.RenkeiContactFirstName__c = false; // コンタクト ファーストネーム

      listBasicSetting.add(bs);
    }
  }

  // 名刺挿入で自動連携して アカウント追加、コンタクト追加
  @isTest
  static void test01_Renkei_NewAccount_NewContact() {
    TestDb db = new TestDb();
    db.initialize();

    //List<Account> listAccount = new List<Account>();
    //listAccount.add(new Account(Name='株式会社 テスト商事'));
    //insert listAccount;

    Test.startTest();
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社テスト商事', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    last_name__c='テスト', first_name__c='一郎', email__c='ichiro@test.com', delivery_type__c='2'));
    insert listCard;
    Test.stopTest();

    List<Account> acnts2 = [SELECT Id, Name FROM Account WHERE Name LIKE '%テスト商事%'];
    System.assertEquals(listCard.size(), acnts2.size());
    List<Contact> conts2 = [SELECT Id, Name FROM Contact WHERE AccountId = :acnts2[0].Id];
    System.assertEquals(listCard.size(), conts2.size());
    List<NameCard__c> cards2 =[SELECT Id, Name, account__c, contact__c FROM NameCard__c];
    System.assertEquals(acnts2[0].Id, cards2[0].account__c);
    System.assertEquals(conts2[0].Id, cards2[0].contact__c);
  }

  // 名刺挿入で自動連携して アカウント更新、コンタクト追加
  @isTest
  static void test02_Renkei_UpdateAccount_NewContact() {
    TestDb db = new TestDb();
    db.initialize();

    Test.startTest();
    // アカウント挿入
    List<Account> listAccount = new List<Account>();
    listAccount.add(new Account(Name='株式会社 テスト商事'));
    listAccount.add(new Account(Name='株式会社 対象外'));
    insert listAccount;

    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社テスト商事', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    last_name__c='テスト', first_name__c='一郎', email__c='ichiro@test.com', delivery_type__c='2'));

    insert listCard;
    Test.stopTest();

    List<Account> acnts2 = [SELECT Id, Name FROM Account WHERE Name LIKE '%テスト商事%'];
    System.assertEquals(listCard.size(), acnts2.size());
    List<Contact> conts2 = [SELECT Id, Name FROM Contact WHERE AccountId = :acnts2[0].Id];
    System.assertEquals(listCard.size(), conts2.size());
    List<NameCard__c> cards2 =[SELECT Id, Name, account__c, contact__c FROM NameCard__c];
    System.assertEquals(acnts2[0].Id, cards2[0].account__c);
    System.assertEquals(conts2[0].Id, cards2[0].contact__c);
  }

  // 名刺挿入で自動連携して アカウント更新、コンタクト更新
  @isTest
  static void test03_Renkei_UpdateAccount_UpdateContact() {
    TestDb db = new TestDb();
    db.initialize();

    Test.startTest();
    // アカウント挿入
    List<Account> listAccount = new List<Account>();
    listAccount.add(new Account(Name='株式会社 テスト商事'));
    listAccount.add(new Account(Name='株式会社 対象外'));

    insert listAccount;

    // コンタクト挿入
    List<Contact> listContact = new List<Contact>();
    listContact.add(new Contact(LastName='テスト', FirstName='一郎', Email='ichiro@test.com', AccountId=listAccount[0].Id));
    insert listContact;

    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社テスト商事', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    last_name__c='テスト', first_name__c='一郎', email__c='ichiro@test.com', delivery_type__c='2'));

    insert listCard;
    Test.stopTest();

    List<Account> acnts2 = [SELECT Id, Name FROM Account WHERE Name LIKE '%テスト商事%'];
    System.assertEquals(listCard.size(), acnts2.size());
    List<Contact> conts2 = [SELECT Id, Name FROM Contact WHERE AccountId = :acnts2[0].Id];
    System.assertEquals(listCard.size(), conts2.size());
    List<NameCard__c> cards2 =[SELECT Id, Name, account__c, contact__c FROM NameCard__c];
    System.assertEquals(acnts2[0].Id, cards2[0].account__c);
    System.assertEquals(conts2[0].Id, cards2[0].contact__c);
  }

  // 名刺挿入で自動連携して 複数アカウントで アカウント更新なし、コンタクト追加なし
  @isTest
  static void test04_Renkei_UpdateNoAccounts_NoNewContact() {
    TestDb db = new TestDb();
    db.initialize();

    Test.startTest();
    // アカウント挿入
    List<Account> listAccount = new List<Account>();
    listAccount.add(new Account(Name='株式会社 テスト商事'));
    listAccount.add(new Account(Name='株式会社 テスト商事'));
    listAccount.add(new Account(Name='株式会社 対象外'));
    insert listAccount;

    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社テスト商事', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    last_name__c='テスト', first_name__c='一郎', email__c='ichiro@test.com', delivery_type__c='2'));

    insert listCard;
    Test.stopTest();

    List<Account> acnts2 = [SELECT Id, Name, Site FROM Account WHERE Name LIKE '%テスト商事%' AND Site='本社' AND BillingPostalCode='150-0022'];
    System.assertEquals(0, acnts2.size());
    List<Contact> conts2 = [SELECT Id, Name FROM Contact WHERE AccountId IN (SELECT Id FROM Account WHERE Name LIKE '%テスト商事%')];
    System.assertEquals(0, conts2.size());
    List<NameCard__c> cards2 =[SELECT Id, Name, account__c, contact__c FROM NameCard__c];
    System.assertEquals(null, cards2[0].account__c);
    System.assertEquals(null, cards2[0].contact__c);
  }

  // 名刺挿入で自動連携して 複数アカウントだけど 特定のアカウント更新、コンタクト更新
  @isTest
  static void test05_Renkei_Update1Account_Update1Contact() {
    TestDb db = new TestDb();
    db.initialize();

    Test.startTest();
    // アカウント挿入
    List<Account> listAccount = new List<Account>();
    listAccount.add(new Account(Name='株式会社 テスト商事'));
    listAccount.add(new Account(Name='株式会社 テスト商事'));
    listAccount.add(new Account(Name='株式会社 対象外'));
    insert listAccount;

    // コンタクト挿入
    List<Contact> listContact = new List<Contact>();
    listContact.add(new Contact(LastName='テスト', FirstName='一郎', Email='ichiro@test.com', AccountId=listAccount[0].Id));
    listContact.add(new Contact(LastName='サンプル', FirstName='二郎', Email='jiro@test.com', AccountId=listAccount[0].Id));
    insert listContact;

    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社テスト商事', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    last_name__c='テスト', first_name__c='一郎', email__c='ichiro@test.com', delivery_type__c='2'));

    insert listCard;
    Test.stopTest();

    List<Account> acnts2 = [SELECT Id, Name, Site FROM Account WHERE Name LIKE '%テスト商事%' AND Site='本社' AND BillingPostalCode='150-0022'];
    System.assertEquals(listCard.size(), acnts2.size());
    List<Contact> conts2 = [SELECT Id, Name FROM Contact WHERE AccountId IN (SELECT Id FROM Account WHERE Name LIKE '%テスト商事%') AND MailingPostalCode='150-0022'];
    System.assertEquals(listCard.size(), conts2.size());
    List<NameCard__c> cards2 =[SELECT Id, Name, account__c, contact__c FROM NameCard__c];
    System.assertEquals(acnts2[0].Id, cards2[0].account__c);
    System.assertEquals(conts2[0].Id, cards2[0].contact__c);
  }


  // 名刺挿入で自動連携して  特定のアカウント更新だけど、コンタクト更新なし
  @isTest
  static void test06_Renkei_UpdateAccount_UpdateNoContact() {
    TestDb db = new TestDb();
    db.initialize();

    Test.startTest();
    // アカウント挿入
    List<Account> listAccount = new List<Account>();
    listAccount.add(new Account(Name='株式会社 テスト商事'));
    listAccount.add(new Account(Name='株式会社 対象外'));
    insert listAccount;

    // コンタクト挿入
    List<Contact> listContact = new List<Contact>();
    listContact.add(new Contact(LastName='テスト', FirstName='一郎', Email='ichiro@test.com', AccountId=listAccount[0].Id));
    listContact.add(new Contact(LastName='テスト', FirstName='一郎', Email='ichiro@test.com', AccountId=listAccount[0].Id));
    insert listContact;

    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社テスト商事', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    last_name__c='テスト', first_name__c='一郎', email__c='ichiro@test.com', delivery_type__c='2'));

    insert listCard;
    Test.stopTest();

    List<Account> acnts2 = [SELECT Id, Name, Site FROM Account WHERE Name LIKE '%テスト商事%' AND Site='本社' AND BillingPostalCode='150-0022'];
    System.assertEquals(listCard.size(), acnts2.size());
    List<Contact> conts2 = [SELECT Id, Name FROM Contact WHERE AccountId IN (SELECT Id FROM Account WHERE Name LIKE '%テスト商事%') AND MailingPostalCode='150-0022'];
    System.assertEquals(0, conts2.size());
    List<NameCard__c> cards2 =[SELECT Id, Name, account__c, contact__c FROM NameCard__c];
    System.assertEquals(acnts2[0].Id, cards2[0].account__c);
    System.assertEquals(null, cards2[0].contact__c);
  }


  // 名刺挿入で自動連携して 複数アカウント、複数コンタクトで  アカウント更新、コンタクト更新なし
  @isTest
  static void test07_Renkei_Update1Account_UpdateNoContact() {
    TestDb db = new TestDb();
    db.initialize();

    Test.startTest();
    // アカウント挿入
    List<Account> listAccount = new List<Account>();
    listAccount.add(new Account(Name='株式会社 テスト商事'));
    listAccount.add(new Account(Name='株式会社 テスト商事'));
    listAccount.add(new Account(Name='株式会社 対象外'));
    insert listAccount;

    // コンタクト挿入
    List<Contact> listContact = new List<Contact>();
    listContact.add(new Contact(LastName='テスト', FirstName='一郎', Email='ichiro@test.com', AccountId=listAccount[0].Id));
    listContact.add(new Contact(LastName='テスト', FirstName='一郎', Email='ichiro@test.com', AccountId=listAccount[0].Id));
    insert listContact;

    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社テスト商事', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    last_name__c='テスト', first_name__c='一郎', email__c='ichiro@test.com', delivery_type__c='2'));

    insert listCard;
    Test.stopTest();

    List<Account> acnts2 = [SELECT Id, Name, Site FROM Account WHERE Name LIKE '%テスト商事%' AND Site='本社' AND BillingPostalCode='150-0022'];
    System.assertEquals(listCard.size(), acnts2.size());
    List<Contact> conts2 = [SELECT Id, Name FROM Contact WHERE AccountId IN (SELECT Id FROM Account WHERE Name LIKE '%テスト商事%') AND MailingPostalCode='150-0022'];
    System.assertEquals(0, conts2.size());
    List<NameCard__c> cards2 =[SELECT Id, Name, account__c, contact__c FROM NameCard__c];
    System.assertEquals(acnts2[0].Id, cards2[0].account__c);
    System.assertEquals(null, cards2[0].contact__c);
  }

  // 名刺挿入で自動連携して 複数アカウントに、コンタクトありで  アカウント更新なし、コンタクト更新なし
  @isTest
  static void test08_Renkei_UpdateNoAccounts_1Contact() {
    TestDb db = new TestDb();
    db.initialize();

    Test.startTest();
    // アカウント挿入
    List<Account> listAccount = new List<Account>();
    listAccount.add(new Account(Name='株式会社 テスト商事'));
    listAccount.add(new Account(Name='株式会社 テスト商事'));
    listAccount.add(new Account(Name='株式会社 対象外'));
    insert listAccount;

    // コンタクト挿入
    List<Contact> listContact = new List<Contact>();
    // 1つ目のアカウントに追加
    listContact.add(new Contact(LastName='テスト', FirstName='一郎', Email='ichiro@test.com', AccountId=listAccount[0].Id));
    // 2つ目のアカウントに追加
    listContact.add(new Contact(LastName='テスト', FirstName='一郎', Email='ichiro@test.com', AccountId=listAccount[1].Id));
    insert listContact;

    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社テスト商事', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    last_name__c='テスト', first_name__c='一郎', email__c='ichiro@test.com', delivery_type__c='2'));

    insert listCard;
    Test.stopTest();

    List<Account> acnts2 = [SELECT Id, Name, Site FROM Account WHERE Name LIKE '%テスト商事%' AND Site='本社' AND BillingPostalCode='150-0022'];
    System.assertEquals(0, acnts2.size());
    List<Contact> conts2 = [SELECT Id, Name FROM Contact WHERE AccountId IN (SELECT Id FROM Account WHERE Name LIKE '%テスト商事%') AND MailingPostalCode='150-0022'];
    System.assertEquals(0, conts2.size());
    List<NameCard__c> cards2 =[SELECT Id, Name, account__c, contact__c FROM NameCard__c];
    System.assertEquals(null, cards2[0].account__c);
    System.assertEquals(null, cards2[0].contact__c);
  }

  // 名刺挿入で自動連携して 複数アカウントに、複数コンタクトありで  アカウント更新なし、コンタクト更新なし
  @isTest
  static void test09_Renkei_UpdateNoAccounts_SomeContacts() {
    TestDb db = new TestDb();
    db.initialize();

    Test.startTest();
    // アカウント挿入
    List<Account> listAccount = new List<Account>();
    listAccount.add(new Account(Name='株式会社 テスト商事'));
    listAccount.add(new Account(Name='株式会社 テスト商事'));
    listAccount.add(new Account(Name='株式会社 対象外'));
    insert listAccount;

    // コンタクト挿入
    List<Contact> listContact = new List<Contact>();
    // 1つ目のアカウントに追加
    listContact.add(new Contact(LastName='テスト', FirstName='一郎', Email='ichiro@test.com', AccountId=listAccount[0].Id));
    listContact.add(new Contact(LastName='テスト', FirstName='一郎', Email='ichiro@test.com', AccountId=listAccount[0].Id));
    // 2つ目のアカウントに追加
    listContact.add(new Contact(LastName='テスト', FirstName='一郎', Email='ichiro@test.com', AccountId=listAccount[1].Id));
    listContact.add(new Contact(LastName='テスト', FirstName='一郎', Email='ichiro@test.com', AccountId=listAccount[1].Id));
    insert listContact;

    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社テスト商事', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    last_name__c='テスト', first_name__c='一郎', email__c='ichiro@test.com', delivery_type__c='2'));

    insert listCard;
    Test.stopTest();

    List<Account> acnts2 = [SELECT Id, Name, Site FROM Account WHERE Name LIKE '%テスト商事%' AND Site='本社' AND BillingPostalCode='150-0022'];
    System.assertEquals(0, acnts2.size());
    List<Contact> conts2 = [SELECT Id, Name FROM Contact WHERE AccountId IN (SELECT Id FROM Account WHERE Name LIKE '%テスト商事%') AND MailingPostalCode='150-0022'];
    System.assertEquals(0, conts2.size());
    List<NameCard__c> cards2 =[SELECT Id, Name, account__c, contact__c FROM NameCard__c];
    System.assertEquals(null, cards2[0].account__c);
    System.assertEquals(null, cards2[0].contact__c);
  }

  // 名刺挿入で自動連携して 複数アカウント、複数コンタクトで  アカウント更新、コンタクト更新なし
  @isTest
  static void test10_Renkei_LinkOnly() {
    TestDbLinkOnly db = new TestDbLinkOnly();
    db.initialize();

    Test.startTest();
    // アカウント挿入
    List<Account> listAccount = new List<Account>();
    listAccount.add(new Account(Name='株式会社 テスト商事'));
    listAccount.add(new Account(Name='株式会社 テスト商事'));
    listAccount.add(new Account(Name='株式会社 対象外'));
    insert listAccount;

    // コンタクト挿入
    List<Contact> listContact = new List<Contact>();
    listContact.add(new Contact(LastName='テスト', FirstName='一郎', Email='ichiro@test.com', AccountId=listAccount[0].Id));
    listContact.add(new Contact(LastName='サンプル', FirstName='二郎', Email='jiro@test.com', AccountId=listAccount[0].Id));
    insert listContact;

    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社テスト商事', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    last_name__c='テスト', first_name__c='一郎', email__c='ichiro@test.com', delivery_type__c='2'));

    insert listCard;
    Test.stopTest();

    List<Account> acnts2 = [SELECT Id, Name, Site FROM Account WHERE Name LIKE '%テスト商事%' AND Site='本社' AND BillingPostalCode='150-0022'];
    System.assertEquals(0, acnts2.size());
    List<Contact> conts2 = [SELECT Id, Name FROM Contact WHERE AccountId IN (SELECT Id FROM Account WHERE Name LIKE '%テスト商事%') AND MailingPostalCode='150-0022'];
    System.assertEquals(0, conts2.size());
    List<NameCard__c> cards2 =[SELECT Id, Name, account__c, contact__c FROM NameCard__c];
    System.assertEquals(listAccount[0].Id, cards2[0].account__c);
    System.assertEquals(listContact[0].Id, cards2[0].contact__c);
  }


}