/**
 *
 * SB_NameCard_RenkeiTriggerHelperTest
 *  自動連携機能で、絞り込まれた名刺を入力として、対象のアカウント、コンタクト、リードなどを作成、更新する Helperクラス SB_NameCard_RenkeiTriggerHelper のテストクラス
 *
 * Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2017.02.xx
 *
 **/
@isTest
private class SB_NameCard_RenkeiTriggerHelperTest
{

  // アカウント、コンタクトの絞込はシンプルな条件でテストするよう
  public virtual class TestDb extends SB_NC_TestDB {

    public virtual override void initializeBasicSetting() {
      NameCardBasicSetting__c bs = SB_NC_PostInstallScript.createDefaultBasicSetting();
      bs.RenkeiAccountOverwrite__c = true;   // 既存の取引先を上書き
      bs.RenkeiContactOverwrite__c = true;   // 既存の取引先責任者を上書き
    //  NameCardBasicSetting__c bs = new NameCardBasicSetting__c(
    //    RenkeiActive__c = false,      // 自動連携機能有効
    //    RenkeiAccountAddressPref__c = false,   // アカウント 都道府県
    //    RenkeiAccount_Street__c = false,   // アカウント 町名・番地
    //    RenkeiAccountZipCode__c = false,   // アカウント 郵便番号
    //    RenkeiAccountCity__c = false,      // アカウント 市区郡
    //    RenkeiAccountURL__c = false,       // アカウント URL
    //    RenkeiAccountCompany__c = true,   // アカウント 会社名
    //    RenkeiAccountPhone__c = false,     // アカウント 電話番号
    //    RenkeiSpecificItems__c = null,        // アカウント 特定項目
    //    RenkeiAccountSite__c = false,        // アカウント 部署名
    //    RenkeiExcludeHojinkakuPartial__c = true,      // 自動連携:会社名は法人格を除いて部分一致
    //    RenkeiExcludeHojinkaku__c = false,      // 自動連携:会社名は法人格を除いて完全一致
    //    RenkeiAccountSitePartialMatch__c = true,      // 自動連携:部署は中間一致検索
    //    RenkeiContactMail__c = true,      // コンタクト メールアドレス
    //    RenkeiContactLastName__c = true,  // コンタクト ラストネーム
    //    RenkeiContactFirstName__c = false, // コンタクト ファーストネーム
    //    RenkeiAccountQueryRecordTypeIds__c = null,    // 検索対象のレコードタイプタイプID カンマ区切り で羅列
    //    RenkeiContactQueryRecordTypeIds__c = null,  // 自動連携で検索対象の取引先責任者レコードタイプ
    //    RenkeiAccountOverwrite__c = true,   // 既存の取引先を上書き
    //    RenkeiContactOverwrite__c = true,   // 既存の取引先責任者を上書き
    //    RenkeiAccountNOExistCreateNew__c = true,  //既存の取引先がなければ新規作成する
    //    RenkeiContactNOExistCreateNew__c = true,  // 既存の取引先責任者がなければ新規作成する
    //    RenkeiAccountRecordTypes__c = null,     // 作成するアカウント の レコードタイプID １つ
    //    RenkeiContactRecordTypes__c = null,      // 作成するコンタクト の レコードタイプID １つ
    //    SaishinInheritValues__c = false,          //最新名刺は値を引継ぐ
    //    RegistToDoSubject__c = Label.SB_NC_ExchangeCard, // 取引先・取引先任者に登録 ToDo件名
    //    RegistNoToDo__c =  false, // 取引先・取引先任者に登録 ToDo登録しない
    //    RegistDispOverWriteCheckbox__c = true, // 取引先・取引先任者に登録 「上書きする」チェックボックスを表示する
    //    RegistDispAccountRectype__c = true, // 取引先・取引先任者に登録 取引先レコードタイプ選択を表示する
    //    RegistAccountNotOverWrite__c = false, // 取引先・取引先任者に登録 取引先を名刺情報で上書きしない
    //    RegistDispContactRectype__c = true, // 取引先・取引先任者に登録 取引先責任者レコードタイプ選択を表示する
    //    RegistContactNotOverWrite__c = false // 取引先・取引先任者に登録 取引先責任者を名刺情報で上書きしない
    //  );
      listBasicSetting.add(bs);
    }

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
    }
  } // TestDb

  // 既存のアカウント、コンタクトがあって、更新しないで、名刺の参照項目をセットするだけのテスト用
  public class TestDbNoOverwrite extends TestDb {

    public override void initializeBasicSetting() {
      NameCardBasicSetting__c bs = SB_NC_PostInstallScript.createDefaultBasicSetting();
      //bs.RenkeiAccountOverwrite__c = false;   // 既存の取引先を上書き
      //bs.RenkeiContactOverwrite__c = false;   // 既存の取引先責任者を上書き

      //NameCardBasicSetting__c bs = new NameCardBasicSetting__c(
      //  RenkeiActive__c = false,      // 自動連携機能有効
      //  RenkeiAccountAddressPref__c = false,   // アカウント 都道府県
      //  RenkeiAccount_Street__c = false,   // アカウント 町名・番地
      //  RenkeiAccountZipCode__c = false,   // アカウント 郵便番号
      //  RenkeiAccountCity__c = false,      // アカウント 市区郡
      //  RenkeiAccountURL__c = false,       // アカウント URL
      //  RenkeiAccountCompany__c = true,   // アカウント 会社名
      //  RenkeiAccountPhone__c = false,     // アカウント 電話番号
      //  RenkeiSpecificItems__c = null,        // アカウント 特定項目
      //  RenkeiAccountSite__c = false,        // アカウント 部署名
      //  RenkeiExcludeHojinkakuPartial__c = true,      // 自動連携:会社名は法人格を除いて部分一致
      //  RenkeiExcludeHojinkaku__c = false,      // 自動連携:会社名は法人格を除いて完全一致
      //  RenkeiAccountSitePartialMatch__c = true,      // 自動連携:部署は中間一致検索
      //  RenkeiContactMail__c = true,      // コンタクト メールアドレス
      //  RenkeiContactLastName__c = true,  // コンタクト ラストネーム
      //  RenkeiContactFirstName__c = false, // コンタクト ファーストネーム
      //  RenkeiAccountQueryRecordTypeIds__c = null,    // 検索対象のレコードタイプタイプID カンマ区切り で羅列
      //  RenkeiContactQueryRecordTypeIds__c = null,  // 自動連携で検索対象の取引先責任者レコードタイプ
      //  RenkeiAccountOverwrite__c = false,   // 既存の取引先を上書き
      //  RenkeiContactOverwrite__c = false,   // 既存の取引先責任者を上書き
      //  RenkeiAccountNOExistCreateNew__c = true,  //既存の取引先がなければ新規作成する
      //  RenkeiContactNOExistCreateNew__c = true,  // 既存の取引先責任者がなければ新規作成する
      //  RenkeiAccountRecordTypes__c = null,     // 作成するアカウント の レコードタイプID １つ
      //  RenkeiContactRecordTypes__c = null,      // 作成するコンタクト の レコードタイプID １つ
      //  SaishinInheritValues__c = false,          //最新名刺は値を引継ぐ
      //  RegistToDoSubject__c = Label.SB_NC_ExchangeCard, // 取引先・取引先任者に登録 ToDo件名
      //  RegistNoToDo__c =  false, // 取引先・取引先任者に登録 ToDo登録しない
      //  RegistDispOverWriteCheckbox__c = true, // 取引先・取引先任者に登録 「上書きする」チェックボックスを表示する
      //  RegistDispAccountRectype__c = true, // 取引先・取引先任者に登録 取引先レコードタイプ選択を表示する
      //  RegistAccountNotOverWrite__c = false, // 取引先・取引先任者に登録 取引先を名刺情報で上書きしない
      //  RegistDispContactRectype__c = true, // 取引先・取引先任者に登録 取引先責任者レコードタイプ選択を表示する
      //  RegistContactNotOverWrite__c = false // 取引先・取引先任者に登録 取引先責任者を名刺情報で上書きしない
      //);
      listBasicSetting.add(bs);
    }
  } // TestDbNoOverwrite


  // 既存アカウントがない状態で、新規アカウント、コンタクトを作るテスト用
  public virtual class TestDbNoAccount extends TestDb {

    public override void initialize() {
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
      // 名刺関係
      initializeKaisha();     // 会社を揃えておく
      initializeEmployee();   // 会社ごとに名刺の人を揃えておく
      // 名刺
      initializeNameCard();
      if (listCard.isEmpty() == false) {
        insert listCard;
      }
    }

  } // class TestDbNoAccount

  // 既存アカウントがない状態で、新規アカウント、コンタクトを作らない条件のテスト用
  public class TestDbNoAccountNotCreate extends TestDbNoAccount {

    public override void initializeBasicSetting() {
      NameCardBasicSetting__c bs = SB_NC_PostInstallScript.createDefaultBasicSetting();
      bs.RenkeiAccountOverwrite__c = true;  // 既存の取引先を上書き
      bs.RenkeiContactOverwrite__c = true;   // 既存の取引先責任者を上書き
      bs.RenkeiAccountNOExistCreateNew__c = false;  //既存の取引先がなければ新規作成する
      bs.RenkeiContactNOExistCreateNew__c = false;  // 既存の取引先責任者がなければ新規作成する

      //NameCardBasicSetting__c bs = new NameCardBasicSetting__c(
      //  RenkeiActive__c = false,      // 自動連携機能有効
      //  RenkeiAccountAddressPref__c = false,   // アカウント 都道府県
      //  RenkeiAccount_Street__c = false,   // アカウント 町名・番地
      //  RenkeiAccountZipCode__c = false,   // アカウント 郵便番号
      //  RenkeiAccountCity__c = false,      // アカウント 市区郡
      //  RenkeiAccountURL__c = false,       // アカウント URL
      //  RenkeiAccountCompany__c = true,   // アカウント 会社名
      //  RenkeiAccountPhone__c = false,     // アカウント 電話番号
      //  RenkeiSpecificItems__c = null,        // アカウント 特定項目
      //  RenkeiAccountSite__c = false,        // アカウント 部署名
      //  RenkeiExcludeHojinkakuPartial__c = true,      // 自動連携:会社名は法人格を除いて部分一致
      //  RenkeiExcludeHojinkaku__c = false,      // 自動連携:会社名は法人格を除いて完全一致
      //  RenkeiAccountSitePartialMatch__c = true,      // 自動連携:部署は中間一致検索
      //  RenkeiContactMail__c = true,      // コンタクト メールアドレス
      //  RenkeiContactLastName__c = true,  // コンタクト ラストネーム
      //  RenkeiContactFirstName__c = false, // コンタクト ファーストネーム
      //  RenkeiAccountQueryRecordTypeIds__c = null,    // 検索対象のレコードタイプタイプID カンマ区切り で羅列
      //  RenkeiContactQueryRecordTypeIds__c = null,  // 自動連携で検索対象の取引先責任者レコードタイプ
      //  RenkeiAccountOverwrite__c = true,   // 既存の取引先を上書き
      //  RenkeiContactOverwrite__c = true,   // 既存の取引先責任者を上書き
      //  RenkeiAccountNOExistCreateNew__c = false,  //既存の取引先がなければ新規作成する
      //  RenkeiContactNOExistCreateNew__c = false,  // 既存の取引先責任者がなければ新規作成する
      //  RenkeiAccountRecordTypes__c = null,     // 作成するアカウント の レコードタイプID １つ
      //  RenkeiContactRecordTypes__c = null,      // 作成するコンタクト の レコードタイプID １つ
      //  SaishinInheritValues__c = false,          //最新名刺は値を引継ぐ
      //  RegistToDoSubject__c = Label.SB_NC_ExchangeCard, // 取引先・取引先任者に登録 ToDo件名
      //  RegistNoToDo__c =  false, // 取引先・取引先任者に登録 ToDo登録しない
      //  RegistDispOverWriteCheckbox__c = true, // 取引先・取引先任者に登録 「上書きする」チェックボックスを表示する
      //  RegistDispAccountRectype__c = true, // 取引先・取引先任者に登録 取引先レコードタイプ選択を表示する
      //  RegistAccountNotOverWrite__c = false, // 取引先・取引先任者に登録 取引先を名刺情報で上書きしない
      //  RegistDispContactRectype__c = true, // 取引先・取引先任者に登録 取引先責任者レコードタイプ選択を表示する
      //  RegistContactNotOverWrite__c = false // 取引先・取引先任者に登録 取引先責任者を名刺情報で上書きしない
      //);
      listBasicSetting.add(bs);
    }

  } // class TestDbNoAccount


  // 既存コンタクトがない状態で、既存アカウントの更新、新規コンタクトを作るテスト用
  public class TestDbNoContact extends TestDb {
    public override void initialize() {
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
    }

  } // class TestDbNoContact


  // 複数の同名アカウントがいる場合に、アカウント更新をスルーするテスト用
  public class TestDbMultiAccount extends TestDb {
    public override void initialize() {
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
      // 登録済のアカウントをクエリして、同じ会社名のアカウントを Insert する。
      List<Account> acnts = [SELECT Id, Name FROM Account];
      List<Account> duplicateAcnts = new List<Account>();
      for (Account acnt : acnts) {
        duplicateAcnts.add(new Account(Name=acnt.Name));
      }
      if (duplicateAcnts.isEmpty() == false) {
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;
        Database.insert(duplicateAcnts, dml);
      }
    }

  } // class TestDbMultiAccount


  // 複数の同名コンタクトがいる場合に、コンタクト更新をスルーするテスト用
  public class TestDbMultiContact extends TestDb {
    public override void initialize() {
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
      // 　同じコンタクデータをIDをクリアして、もう一度 Insert する。
      for (Contact cont : listContact) {
        cont.Id = null;
      }
      if (!listContact.isEmpty()) {
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;
        Database.insert(listContact, dml);
      }
    }

  } // class TestDbMultiContact

  private static final String NMAECARD_FIELDS = 'Id, Name, name_kana__c, person_name_last__c, person_name_first__c, last_name__c, first_name__c' +
    ', company_name__c, company_name_kana__c, division__c, division_name__c, title_name__c' +
    ', zip_code__c, address_pref__c, address__c, address_bld__c, address_eng__c, Saishin__c' +
    ', card_exchange_date__c, list_name__c, OwnerId, Owner.Name, Parent__c, tenshokugonomeishi__c, account__c, contact__c' +
    ', freehandmemo__c, memo__c, web_url1__c, email__c, tel1__c, mobile__c, fax1__c' +
    ', image_id__c, bk_image_id__c, width__c, height__c, bk_width__c, bk_height__c' +
    ', RenkeiMessage__c' +    // 2017.04.xx
    ', isNotOverwrite__c, isNotOverContactwrite__c';

  // 既存のアカウント、コンタクトを更新するテスト
  @isTest
  static void test_AccountRenkeiProcessUpdateExist()
  {
    TestDb db = new TestDb();
    db.initialize();

    Test.startTest();
    Map<Id, Account> acnts = new Map<Id, Account> ([SELECT Id, Name FROM Account]);
    Map<Id, Contact> conts = new Map<Id, Contact> ([SELECT Id, Name, AccountId, Account.Name FROM Contact]);
    List<NameCard__c> cards = Database.query('SELECT ' + NMAECARD_FIELDS + ' FROM NameCard__c LIMIT 1');
    for (NameCard__c card :cards) {
      System.assertEquals(null, card.account__c);
      System.assertEquals(null, card.contact__c);
    }
    SB_NameCard_RenkeiTriggerHelper.doRenkei(cards, SB_NameCard_RenkeiTriggerHelper.ProcType.ACCOUNT);
    for (NameCard__c card :cards) {
      System.assertNotEquals(null, card.account__c);
      System.assertNotEquals(null, card.contact__c);
      Contact cont = conts.get(card.contact__c);
      System.assertEquals(cont.AccountId, card.account__c);
      System.assertEquals(cont.Account.Name, card.company_name__c);
    }
    Test.stopTest();
  }

  // 既存のアカウント、コンタクトを更新するテスト
  @isTest
  static void test_AccountRenkeiProcessUpdateExistMulti()
  {
    TestDb db = new TestDb();
    db.initialize();

    Test.startTest();
    Map<Id, Account> acnts = new Map<Id, Account> ([SELECT Id, Name FROM Account]);
    Map<Id, Contact> conts = new Map<Id, Contact> ([SELECT Id, Name, AccountId, Account.Name FROM Contact]);
    List<NameCard__c> cards = Database.query('SELECT ' + NMAECARD_FIELDS + ' FROM NameCard__c');
    for (NameCard__c card :cards) {
      System.assertEquals(null, card.account__c);
      System.assertEquals(null, card.contact__c);
    }
    SB_NameCard_RenkeiTriggerHelper.doRenkei(cards, SB_NameCard_RenkeiTriggerHelper.ProcType.ACCOUNT);
    for (NameCard__c card :cards) {
      System.assertNotEquals(null, card.account__c);
      System.assertNotEquals(null, card.contact__c);
      Contact cont = conts.get(card.contact__c);
      System.assertEquals(cont.AccountId, card.account__c);
      System.assertEquals(cont.Account.Name, card.company_name__c);
    }
    Test.stopTest();
  }

  // 既存のアカウント、コンタクトを更新するテスト
  @isTest
  static void test_AccountRenkeiProcessNoOverwrite()
  {
    TestDbNoOverwrite db = new TestDbNoOverwrite();
    db.initialize();

    Test.startTest();
    Map<Id, Account> acnts = new Map<Id, Account> ([SELECT Id, Name FROM Account]);
    Map<Id, Contact> conts = new Map<Id, Contact> ([SELECT Id, Name, AccountId, Account.Name FROM Contact]);
    List<NameCard__c> cards = Database.query('SELECT ' + NMAECARD_FIELDS + ' FROM NameCard__c LIMIT 1');
    for (NameCard__c card :cards) {
      System.assertEquals(null, card.account__c);
      System.assertEquals(null, card.contact__c);
    }
    SB_NameCard_RenkeiTriggerHelper.doRenkei(cards, SB_NameCard_RenkeiTriggerHelper.ProcType.ACCOUNT);
    for (NameCard__c card :cards) {
      System.assertNotEquals(null, card.account__c);
      System.assertNotEquals(null, card.contact__c);
      Contact cont = conts.get(card.contact__c);
      System.assertEquals(cont.AccountId, card.account__c);
      System.assertEquals(cont.Account.Name, card.company_name__c);
    }
    Test.stopTest();
  }

  // 既存のアカウント、コンタクトがいなくて新規作成するテスト
  @isTest
  static void test_AccountRenkeiProcessCreateNewAccountContact()
  {
    TestDbNoAccount db = new TestDbNoAccount();
    db.initialize();

    Test.startTest();
    Map<Id, Account> acnts = new Map<Id, Account> ([SELECT Id, Name FROM Account]);
    Map<Id, Contact> conts = new Map<Id, Contact> ([SELECT Id, Name, AccountId FROM Contact]);
    List<NameCard__c> cards = Database.query('SELECT ' + NMAECARD_FIELDS + ' FROM NameCard__c LIMIT 1');
    for (NameCard__c card :cards) {
      System.assertEquals(null, card.account__c);
      System.assertEquals(null, card.contact__c);
    }
    SB_NameCard_RenkeiTriggerHelper.doRenkei(cards, SB_NameCard_RenkeiTriggerHelper.ProcType.ACCOUNT);
    for (NameCard__c card :cards) {
      System.assertNotEquals(null, card.account__c);
      System.assertNotEquals(null, card.contact__c);
      System.assert(acnts.containsKey(card.account__c) == false);
      System.assert(conts.containsKey(card.contact__c) == false);
    }
    Test.stopTest();
  }

  // 既存のアカウント、コンタクトがいなくて新規作成するテスト
  @isTest
  static void test_AccountRenkeiProcessCreateNewAccountContactMulti()
  {
    TestDbNoAccount db = new TestDbNoAccount();
    db.initialize();

    Test.startTest();
    Map<Id, Account> acnts = new Map<Id, Account> ([SELECT Id, Name FROM Account]);
    Map<Id, Contact> conts = new Map<Id, Contact> ([SELECT Id, Name, AccountId FROM Contact]);
    List<NameCard__c> cards = Database.query('SELECT ' + NMAECARD_FIELDS + ' FROM NameCard__c');
    for (NameCard__c card :cards) {
      System.assertEquals(null, card.account__c);
      System.assertEquals(null, card.contact__c);
    }
    SB_NameCard_RenkeiTriggerHelper.doRenkei(cards, SB_NameCard_RenkeiTriggerHelper.ProcType.ACCOUNT);
    for (NameCard__c card :cards) {
      System.assertNotEquals(null, card.account__c);
      System.assertNotEquals(null, card.contact__c);
      System.assert(acnts.containsKey(card.account__c) == false);
      System.assert(conts.containsKey(card.contact__c) == false);
    }
    Test.stopTest();
  }

  // 既存のアカウント、コンタクトがいなくて新規作成するテスト
  @isTest
  static void test_AccountRenkeiProcessDontCreateNewAccountContact()
  {
    TestDbNoAccountNotCreate db = new TestDbNoAccountNotCreate();
    db.initialize();

    Test.startTest();
    Map<Id, Account> acnts = new Map<Id, Account> ([SELECT Id, Name FROM Account]);
    Map<Id, Contact> conts = new Map<Id, Contact> ([SELECT Id, Name, AccountId FROM Contact]);
    List<NameCard__c> cards = Database.query('SELECT ' + NMAECARD_FIELDS + ' FROM NameCard__c LIMIT 1');
    for (NameCard__c card :cards) {
      System.assertEquals(null, card.account__c);
      System.assertEquals(null, card.contact__c);
    }
    SB_NameCard_RenkeiTriggerHelper.doRenkei(cards, SB_NameCard_RenkeiTriggerHelper.ProcType.ACCOUNT);
    for (NameCard__c card :cards) {
      System.assertEquals(null, card.account__c);
      System.assertEquals(null, card.contact__c);
    }
    Test.stopTest();
  }



  // 既存のアカウントがいて、コンタクトがいなくてコンタクトだけ新規作成するテスト
  @isTest
  static void test_AccountRenkeiProcessCreateNewContact()
  {
    TestDbNoContact db = new TestDbNoContact();
    db.initialize();

    Test.startTest();
    Map<Id, Account> acnts = new Map<Id, Account> ([SELECT Id, Name FROM Account]);
    Map<Id, Contact> conts = new Map<Id, Contact> ([SELECT Id, Name, AccountId FROM Contact]);
    List<NameCard__c> cards = Database.query('SELECT ' + NMAECARD_FIELDS + ' FROM NameCard__c LIMIT 1');
    for (NameCard__c card :cards) {
      System.assertEquals(null, card.account__c);
      System.assertEquals(null, card.contact__c);
    }
    SB_NameCard_RenkeiTriggerHelper.doRenkei(cards, SB_NameCard_RenkeiTriggerHelper.ProcType.ACCOUNT);
    for (NameCard__c card :cards) {
      System.assertNotEquals(null, card.account__c);
      System.assertNotEquals(null, card.contact__c);
      System.assert(acnts.containsKey(card.account__c));
      System.assert(conts.containsKey(card.contact__c) == false);
    }
    Test.stopTest();
  }

  // 既存のアカウントが複数存在するので、スルーするテスト
  @isTest
  static void test_AccountRenkeiProcessMultiAccount()
  {
    TestDbMultiAccount db = new TestDbMultiAccount();
    db.initialize();

    Test.startTest();
    Map<Id, Account> acnts = new Map<Id, Account> ([SELECT Id, Name FROM Account]);
    Map<Id, Contact> conts = new Map<Id, Contact> ([SELECT Id, Name, AccountId FROM Contact]);
    List<NameCard__c> cards = Database.query('SELECT ' + NMAECARD_FIELDS + ' FROM NameCard__c LIMIT 1');
    for (NameCard__c card :cards) {
      System.assertEquals(null, card.account__c);
      System.assertEquals(null, card.contact__c);
    }
    SB_NameCard_RenkeiTriggerHelper.doRenkei(cards, SB_NameCard_RenkeiTriggerHelper.ProcType.ACCOUNT);
    for (NameCard__c card :cards) {
      System.assertEquals(null, card.account__c);
      System.assertEquals(null, card.contact__c);
    }
    Test.stopTest();
  }

  // 既存のコンタクトが複数存在するので、スルーするテスト
  @isTest
  static void test_AccountRenkeiProcessMultiContact()
  {
    TestDbMultiContact db = new TestDbMultiContact();
    db.initialize();

    Test.startTest();
    Map<Id, Account> acnts = new Map<Id, Account> ([SELECT Id, Name FROM Account]);
    Map<Id, Contact> conts = new Map<Id, Contact> ([SELECT Id, Name, AccountId FROM Contact]);
    List<NameCard__c> cards = Database.query('SELECT ' + NMAECARD_FIELDS + ' FROM NameCard__c LIMIT 1');
    for (NameCard__c card :cards) {
      System.assertEquals(null, card.account__c);
      System.assertEquals(null, card.contact__c);
    }
    SB_NameCard_RenkeiTriggerHelper.doRenkei(cards, SB_NameCard_RenkeiTriggerHelper.ProcType.ACCOUNT);
    for (NameCard__c card :cards) {
      System.assertNotEquals(null, card.account__c);
      System.assertEquals(null, card.contact__c);
    }
    Test.stopTest();
  }

  // リードも対応用
  @isTest
  static void test_ComboRenkeiProcessCreateNew()
  {
    TestDb db = new TestDb();
    db.initialize();

    Test.startTest();
    List<NameCard__c> cards = Database.query('SELECT ' + NMAECARD_FIELDS + ' FROM NameCard__c');
    SB_NameCard_RenkeiTriggerHelper.doRenkei(cards, SB_NameCard_RenkeiTriggerHelper.ProcType.LEAD);
    //for (NameCard__c card :cards) {
    //  System.assertEquals(null, card.lead__c);
    //}
    Test.stopTest();
  }

  @isTest
  static void test_AccountRenkeiProcessCreateNewAccountContactError()
  {
    TestDbNoAccount db = new TestDbNoAccount();
    db.initialize();

    Test.startTest();
    Map<Id, Account> acnts = new Map<Id, Account> ([SELECT Id, Name FROM Account]);
    Map<Id, Contact> conts = new Map<Id, Contact> ([SELECT Id, Name, AccountId FROM Contact]);
    List<NameCard__c> cards = Database.query('SELECT ' + NMAECARD_FIELDS + ' FROM NameCard__c LIMIT 1');
    for (NameCard__c card :cards) {
      //System.assertEquals(null, card.account__c);
      //System.assertEquals(null, card.contact__c);
      card.company_name__c = null;    // 会社名なしにしとく
    }
    SB_NameCard_RenkeiTriggerHelper.doRenkei(cards, SB_NameCard_RenkeiTriggerHelper.ProcType.ACCOUNT);
    for (NameCard__c card :cards) {
      System.assert(String.isNotBlank(card.RenkeiMessage__c));  // メッセージがせっとされてる
    }
    Test.stopTest();
  }



}