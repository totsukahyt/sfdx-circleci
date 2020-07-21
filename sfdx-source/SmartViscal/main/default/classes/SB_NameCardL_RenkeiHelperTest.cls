/**
 *
 *  SB_NameCardL_RenkeiHelperTest
 *    SB_NameCard_RenkeiHelperTest の改造
 *  自動連携機能で、絞り込まれた名刺を入力として、対象のアカウント、コンタクト、リードなどを作成、更新する Helperクラス SB_NameCardL_RenkeiHelper のテストクラス
 *
 * Copyright (C) 2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2017.02.xx
 *  SB_NameCardL_RenkeiHelperTest
 *  lx 2.0    2018.06.xx
 *
 **/
@isTest
private class SB_NameCardL_RenkeiHelperTest
{

  // アカウント、コンタクトの絞込はシンプルな条件でテストするよう
  public virtual class TestDb extends SB_NCL_TestDB {

    public virtual override void initializeBasicSetting() {
      SmartViscaf__NameCardBasicSetting__c bs = SmartViscaf.SB_NC_PostInstallScript.createDefaultBasicSetting();
      //bs.SmartViscaf__RenkeiActive__c = true;      // 自動連携機能有効
      //bs.SmartViscaf__RenkeiLeadActive__c = false;
      //bs.SmartViscaf__RenkeiAccountNOExistCreateNew__c = true;
      bs.SmartViscaf__RenkeiAccountOverwrite__c = true;   // 既存の取引先を上書き
      //bs.SmartViscaf__RenkeiContactNOExistCreateNew__c = true;
      bs.SmartViscaf__RenkeiContactOverwrite__c = true;   // 既存の取引先責任者を上書き
      bs.SmartViscaf__RenkeiLeadOverwrite__c = true;   // 既存のリードを上書き
    //  SmartViscaf__NameCardBasicSetting__c bs = new SmartViscaf__NameCardBasicSetting__c(
    //    SmartViscaf__RenkeiActive__c = false,      // 自動連携機能有効
    //    SmartViscaf__RenkeiAccountAddressPref__c = false,   // アカウント 都道府県
    //    SmartViscaf__RenkeiAccount_Street__c = false,   // アカウント 町名・番地
    //    SmartViscaf__RenkeiAccountZipCode__c = false,   // アカウント 郵便番号
    //    SmartViscaf__RenkeiAccountCity__c = false,      // アカウント 市区郡
    //    SmartViscaf__RenkeiAccountURL__c = false,       // アカウント URL
    //    SmartViscaf__RenkeiAccountCompany__c = true,   // アカウント 会社名
    //    SmartViscaf__RenkeiAccountPhone__c = false,     // アカウント 電話番号
    //    SmartViscaf__RenkeiSpecificItems__c = null,        // アカウント 特定項目
    //    SmartViscaf__RenkeiAccountSite__c = false,        // アカウント 部署名
    //    SmartViscaf__RenkeiExcludeHojinkakuPartial__c = true,      // 自動連携:会社名は法人格を除いて部分一致
    //    SmartViscaf__RenkeiExcludeHojinkaku__c = false,      // 自動連携:会社名は法人格を除いて完全一致
    //    SmartViscaf__RenkeiAccountSitePartialMatch__c = true,      // 自動連携:部署は中間一致検索
    //    SmartViscaf__RenkeiContactMail__c = true,      // コンタクト メールアドレス
    //    SmartViscaf__RenkeiContactLastName__c = true,  // コンタクト ラストネーム
    //    SmartViscaf__RenkeiContactFirstName__c = false, // コンタクト ファーストネーム
    //    SmartViscaf__RenkeiAccountQueryRecordTypeIds__c = null,    // 検索対象のレコードタイプタイプID カンマ区切り で羅列
    //    SmartViscaf__RenkeiContactQueryRecordTypeIds__c = null,  // 自動連携で検索対象の取引先責任者レコードタイプ
    //    SmartViscaf__RenkeiAccountOverwrite__c = true,   // 既存の取引先を上書き
    //    SmartViscaf__RenkeiContactOverwrite__c = true,   // 既存の取引先責任者を上書き
    //    SmartViscaf__RenkeiAccountNOExistCreateNew__c = true,  //既存の取引先がなければ新規作成する
    //    SmartViscaf__RenkeiContactNOExistCreateNew__c = true,  // 既存の取引先責任者がなければ新規作成する
    //    SmartViscaf__RenkeiAccountRecordTypes__c = null,     // 作成するアカウント の レコードタイプID １つ
    //    SmartViscaf__RenkeiContactRecordTypes__c = null,      // 作成するコンタクト の レコードタイプID １つ
    //    SmartViscaf__SaishinInheritValues__c = false,          //最新名刺は値を引継ぐ
    //    SmartViscaf__RegistToDoSubject__c = Label.SB_NC_ExchangeCard, // 取引先・取引先任者に登録 ToDo件名
    //    SmartViscaf__RegistNoToDo__c =  false, // 取引先・取引先任者に登録 ToDo登録しない
    //    SmartViscaf__RegistDispOverWriteCheckbox__c = true, // 取引先・取引先任者に登録 「上書きする」チェックボックスを表示する
    //    SmartViscaf__RegistDispAccountRectype__c = true, // 取引先・取引先任者に登録 取引先レコードタイプ選択を表示する
    //    SmartViscaf__RegistAccountNotOverWrite__c = false, // 取引先・取引先任者に登録 取引先を名刺情報で上書きしない
    //    SmartViscaf__RegistDispContactRectype__c = true, // 取引先・取引先任者に登録 取引先責任者レコードタイプ選択を表示する
    //    SmartViscaf__RegistContactNotOverWrite__c = false // 取引先・取引先任者に登録 取引先責任者を名刺情報で上書きしない
    //  );
      listBasicSetting.add(bs);
    }

    public virtual override void initialize() {
      // SmartVisca設定
      initializeSmartViscaConfig();
      if (svConfig !=null) {
        upsert svConfig;
      }
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
      SmartViscaf__NameCardBasicSetting__c bs = SmartViscaf.SB_NC_PostInstallScript.createDefaultBasicSetting();
      //bs.SmartViscaf__RenkeiAccountOverwrite__c = false;   // 既存の取引先を上書き
      //bs.SmartViscaf__RenkeiContactOverwrite__c = false;   // 既存の取引先責任者を上書き

      //SmartViscaf__NameCardBasicSetting__c bs = new SmartViscaf__NameCardBasicSetting__c(
      //  SmartViscaf__RenkeiActive__c = false,      // 自動連携機能有効
      //  SmartViscaf__RenkeiAccountAddressPref__c = false,   // アカウント 都道府県
      //  SmartViscaf__RenkeiAccount_Street__c = false,   // アカウント 町名・番地
      //  SmartViscaf__RenkeiAccountZipCode__c = false,   // アカウント 郵便番号
      //  SmartViscaf__RenkeiAccountCity__c = false,      // アカウント 市区郡
      //  SmartViscaf__RenkeiAccountURL__c = false,       // アカウント URL
      //  SmartViscaf__RenkeiAccountCompany__c = true,   // アカウント 会社名
      //  SmartViscaf__RenkeiAccountPhone__c = false,     // アカウント 電話番号
      //  SmartViscaf__RenkeiSpecificItems__c = null,        // アカウント 特定項目
      //  SmartViscaf__RenkeiAccountSite__c = false,        // アカウント 部署名
      //  SmartViscaf__RenkeiExcludeHojinkakuPartial__c = true,      // 自動連携:会社名は法人格を除いて部分一致
      //  SmartViscaf__RenkeiExcludeHojinkaku__c = false,      // 自動連携:会社名は法人格を除いて完全一致
      //  SmartViscaf__RenkeiAccountSitePartialMatch__c = true,      // 自動連携:部署は中間一致検索
      //  SmartViscaf__RenkeiContactMail__c = true,      // コンタクト メールアドレス
      //  SmartViscaf__RenkeiContactLastName__c = true,  // コンタクト ラストネーム
      //  SmartViscaf__RenkeiContactFirstName__c = false, // コンタクト ファーストネーム
      //  SmartViscaf__RenkeiAccountQueryRecordTypeIds__c = null,    // 検索対象のレコードタイプタイプID カンマ区切り で羅列
      //  SmartViscaf__RenkeiContactQueryRecordTypeIds__c = null,  // 自動連携で検索対象の取引先責任者レコードタイプ
      //  SmartViscaf__RenkeiAccountOverwrite__c = false,   // 既存の取引先を上書き
      //  SmartViscaf__RenkeiContactOverwrite__c = false,   // 既存の取引先責任者を上書き
      //  SmartViscaf__RenkeiAccountNOExistCreateNew__c = true,  //既存の取引先がなければ新規作成する
      //  SmartViscaf__RenkeiContactNOExistCreateNew__c = true,  // 既存の取引先責任者がなければ新規作成する
      //  SmartViscaf__RenkeiAccountRecordTypes__c = null,     // 作成するアカウント の レコードタイプID １つ
      //  SmartViscaf__RenkeiContactRecordTypes__c = null,      // 作成するコンタクト の レコードタイプID １つ
      //  SmartViscaf__SaishinInheritValues__c = false,          //最新名刺は値を引継ぐ
      //  SmartViscaf__RegistToDoSubject__c = Label.SB_NC_ExchangeCard, // 取引先・取引先任者に登録 ToDo件名
      //  SmartViscaf__RegistNoToDo__c =  false, // 取引先・取引先任者に登録 ToDo登録しない
      //  SmartViscaf__RegistDispOverWriteCheckbox__c = true, // 取引先・取引先任者に登録 「上書きする」チェックボックスを表示する
      //  SmartViscaf__RegistDispAccountRectype__c = true, // 取引先・取引先任者に登録 取引先レコードタイプ選択を表示する
      //  SmartViscaf__RegistAccountNotOverWrite__c = false, // 取引先・取引先任者に登録 取引先を名刺情報で上書きしない
      //  SmartViscaf__RegistDispContactRectype__c = true, // 取引先・取引先任者に登録 取引先責任者レコードタイプ選択を表示する
      //  SmartViscaf__RegistContactNotOverWrite__c = false // 取引先・取引先任者に登録 取引先責任者を名刺情報で上書きしない
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

  ////////////////

  // 既存アカウントがない状態で、新規アカウント、コンタクトを作らない条件のテスト用
  public class TestDbNoAccountNotCreate extends TestDbNoAccount {

    public override void initializeBasicSetting() {
      SmartViscaf__NameCardBasicSetting__c bs = SmartViscaf.SB_NC_PostInstallScript.createDefaultBasicSetting();
      bs.SmartViscaf__RenkeiAccountOverwrite__c = true;  // 既存の取引先を上書き
      bs.SmartViscaf__RenkeiContactOverwrite__c = true;   // 既存の取引先責任者を上書き
      bs.SmartViscaf__RenkeiLeadOverwrite__c = true;   // 既存のリードを上書き
      bs.SmartViscaf__RenkeiAccountNOExistCreateNew__c = false;  //既存の取引先がなければ新規作成する
      bs.SmartViscaf__RenkeiContactNOExistCreateNew__c = false;  // 既存の取引先責任者がなければ新規作成する
      bs.SmartViscaf__RenkeiLeadNOExistCreateNew__c = false;  // 既存のリードがなければ新規作成する
      //SmartViscaf__NameCardBasicSetting__c bs = new SmartViscaf__NameCardBasicSetting__c(
      //  SmartViscaf__RenkeiActive__c = false,      // 自動連携機能有効
      //  SmartViscaf__RenkeiAccountAddressPref__c = false,   // アカウント 都道府県
      //  SmartViscaf__RenkeiAccount_Street__c = false,   // アカウント 町名・番地
      //  SmartViscaf__RenkeiAccountZipCode__c = false,   // アカウント 郵便番号
      //  SmartViscaf__RenkeiAccountCity__c = false,      // アカウント 市区郡
      //  SmartViscaf__RenkeiAccountURL__c = false,       // アカウント URL
      //  SmartViscaf__RenkeiAccountCompany__c = true,   // アカウント 会社名
      //  SmartViscaf__RenkeiAccountPhone__c = false,     // アカウント 電話番号
      //  SmartViscaf__RenkeiSpecificItems__c = null,        // アカウント 特定項目
      //  SmartViscaf__RenkeiAccountSite__c = false,        // アカウント 部署名
      //  SmartViscaf__RenkeiExcludeHojinkakuPartial__c = true,      // 自動連携:会社名は法人格を除いて部分一致
      //  SmartViscaf__RenkeiExcludeHojinkaku__c = false,      // 自動連携:会社名は法人格を除いて完全一致
      //  SmartViscaf__RenkeiAccountSitePartialMatch__c = true,      // 自動連携:部署は中間一致検索
      //  SmartViscaf__RenkeiContactMail__c = true,      // コンタクト メールアドレス
      //  SmartViscaf__RenkeiContactLastName__c = true,  // コンタクト ラストネーム
      //  SmartViscaf__RenkeiContactFirstName__c = false, // コンタクト ファーストネーム
      //  SmartViscaf__RenkeiAccountQueryRecordTypeIds__c = null,    // 検索対象のレコードタイプタイプID カンマ区切り で羅列
      //  SmartViscaf__RenkeiContactQueryRecordTypeIds__c = null,  // 自動連携で検索対象の取引先責任者レコードタイプ
      //  SmartViscaf__RenkeiAccountOverwrite__c = true,   // 既存の取引先を上書き
      //  SmartViscaf__RenkeiContactOverwrite__c = true,   // 既存の取引先責任者を上書き
      //  SmartViscaf__RenkeiAccountNOExistCreateNew__c = false,  //既存の取引先がなければ新規作成する
      //  SmartViscaf__RenkeiContactNOExistCreateNew__c = false,  // 既存の取引先責任者がなければ新規作成する
      //  SmartViscaf__RenkeiAccountRecordTypes__c = null,     // 作成するアカウント の レコードタイプID １つ
      //  SmartViscaf__RenkeiContactRecordTypes__c = null,      // 作成するコンタクト の レコードタイプID １つ
      //  SmartViscaf__SaishinInheritValues__c = false,          //最新名刺は値を引継ぐ
      //  SmartViscaf__RegistToDoSubject__c = Label.SB_NC_ExchangeCard, // 取引先・取引先任者に登録 ToDo件名
      //  SmartViscaf__RegistNoToDo__c =  false, // 取引先・取引先任者に登録 ToDo登録しない
      //  SmartViscaf__RegistDispOverWriteCheckbox__c = true, // 取引先・取引先任者に登録 「上書きする」チェックボックスを表示する
      //  SmartViscaf__RegistDispAccountRectype__c = true, // 取引先・取引先任者に登録 取引先レコードタイプ選択を表示する
      //  SmartViscaf__RegistAccountNotOverWrite__c = false, // 取引先・取引先任者に登録 取引先を名刺情報で上書きしない
      //  SmartViscaf__RegistDispContactRectype__c = true, // 取引先・取引先任者に登録 取引先責任者レコードタイプ選択を表示する
      //  SmartViscaf__RegistContactNotOverWrite__c = false // 取引先・取引先任者に登録 取引先責任者を名刺情報で上書きしない
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

  private static final String NMAECARD_FIELDS = 'Id, Name, SmartViscaf__name_kana__c, SmartViscaf__person_name_last__c, SmartViscaf__person_name_first__c, SmartViscaf__last_name__c, SmartViscaf__first_name__c' +
    ', SmartViscaf__company_name__c, SmartViscaf__company_name_kana__c, SmartViscaf__division__c, SmartViscaf__division_name__c, SmartViscaf__title_name__c' +
    ', SmartViscaf__zip_code__c, SmartViscaf__address_pref__c, SmartViscaf__address__c, SmartViscaf__address_bld__c, SmartViscaf__address_eng__c' +
    ', SmartViscaf__card_exchange_date__c, SmartViscaf__list_name__c, OwnerId, Owner.Name, SmartViscaf__Parent__c, SmartViscaf__tenshokugonomeishi__c, SmartViscaf__account__c, SmartViscaf__contact__c' +
    ', SmartViscaf__lead__c, campaign__c' +
    ', SmartViscaf__freehandmemo__c, SmartViscaf__memo__c, SmartViscaf__web_url1__c, SmartViscaf__web_url2__c, SmartViscaf__email__c, SmartViscaf__tel1__c, SmartViscaf__tel2__c, SmartViscaf__mobile__c, SmartViscaf__fax1__c' +
    ', SmartViscaf__image_id__c, SmartViscaf__bk_image_id__c, SmartViscaf__width__c, SmartViscaf__height__c, SmartViscaf__bk_width__c, SmartViscaf__bk_height__c' +
    ', SmartViscaf__RenkeiMessage__c' +    // 2017.04.xx
    ', SmartViscaf__isNotOverwrite__c, SmartViscaf__isNotOverContactwrite__c';

  // 既存のアカウント、コンタクトを更新するテスト
  @isTest
  static void test_AccountRenkeiProcessUpdateExist()
  {
    TestDb db = new TestDb();
    db.initialize();

    Test.startTest();
    Map<Id, Account> acnts = new Map<Id, Account> ([SELECT Id, Name FROM Account]);
    Map<Id, Contact> conts = new Map<Id, Contact> ([SELECT Id, Name, AccountId, Account.Name FROM Contact]);
    List<SmartViscaf__NameCard__c> cards = Database.query('SELECT ' + NMAECARD_FIELDS + ' FROM SmartViscaf__NameCard__c LIMIT 1');
    for (SmartViscaf__NameCard__c card :cards) {
      System.assertEquals(null, card.SmartViscaf__account__c);
      System.assertEquals(null, card.SmartViscaf__contact__c);
    }
    SB_NameCardL_RenkeiHelper.doRenkei(cards, SB_NameCardL_RenkeiHelper.ProcType.ACCOUNT);
    for (SmartViscaf__NameCard__c card :cards) {
      System.assertNotEquals(null, card.SmartViscaf__account__c);
      System.assertNotEquals(null, card.SmartViscaf__contact__c);
      Contact cont = conts.get(card.SmartViscaf__contact__c);
      System.assertEquals(cont.AccountId, card.SmartViscaf__account__c);
      System.assertEquals(cont.Account.Name, card.SmartViscaf__company_name__c);
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
    List<SmartViscaf__NameCard__c> cards = Database.query('SELECT ' + NMAECARD_FIELDS + ' FROM SmartViscaf__NameCard__c');
    for (SmartViscaf__NameCard__c card :cards) {
      System.assertEquals(null, card.SmartViscaf__account__c);
      System.assertEquals(null, card.SmartViscaf__contact__c);
    }
    SB_NameCardL_RenkeiHelper.doRenkei(cards, SB_NameCardL_RenkeiHelper.ProcType.ACCOUNT);
    for (SmartViscaf__NameCard__c card :cards) {
      System.assertNotEquals(null, card.SmartViscaf__account__c);
      System.assertNotEquals(null, card.SmartViscaf__contact__c);
      Contact cont = conts.get(card.SmartViscaf__contact__c);
      System.assertEquals(cont.AccountId, card.SmartViscaf__account__c);
      System.assertEquals(cont.Account.Name, card.SmartViscaf__company_name__c);
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
    List<SmartViscaf__NameCard__c> cards = Database.query('SELECT ' + NMAECARD_FIELDS + ' FROM SmartViscaf__NameCard__c LIMIT 1');
    for (SmartViscaf__NameCard__c card :cards) {
      System.assertEquals(null, card.SmartViscaf__account__c);
      System.assertEquals(null, card.SmartViscaf__contact__c);
    }
    SB_NameCardL_RenkeiHelper.doRenkei(cards, SB_NameCardL_RenkeiHelper.ProcType.ACCOUNT);
    for (SmartViscaf__NameCard__c card :cards) {
      System.assertNotEquals(null, card.SmartViscaf__account__c);
      System.assertNotEquals(null, card.SmartViscaf__contact__c);
      Contact cont = conts.get(card.SmartViscaf__contact__c);
      System.assertEquals(cont.AccountId, card.SmartViscaf__account__c);
      System.assertEquals(cont.Account.Name, card.SmartViscaf__company_name__c);
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
    List<SmartViscaf__NameCard__c> cards = Database.query('SELECT ' + NMAECARD_FIELDS + ' FROM SmartViscaf__NameCard__c LIMIT 1');
    for (SmartViscaf__NameCard__c card :cards) {
      System.assertEquals(null, card.SmartViscaf__account__c);
      System.assertEquals(null, card.SmartViscaf__contact__c);
    }
    SB_NameCardL_RenkeiHelper.doRenkei(cards, SB_NameCardL_RenkeiHelper.ProcType.ACCOUNT);
    for (SmartViscaf__NameCard__c card :cards) {
      System.assertNotEquals(null, card.SmartViscaf__account__c);
      System.assertNotEquals(null, card.SmartViscaf__contact__c);
      System.assert(acnts.containsKey(card.SmartViscaf__account__c) == false);
      System.assert(conts.containsKey(card.SmartViscaf__contact__c) == false);
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
    List<SmartViscaf__NameCard__c> cards = Database.query('SELECT ' + NMAECARD_FIELDS + ' FROM SmartViscaf__NameCard__c');
    for (SmartViscaf__NameCard__c card :cards) {
      System.assertEquals(null, card.SmartViscaf__account__c);
      System.assertEquals(null, card.SmartViscaf__contact__c);
    }
    SB_NameCardL_RenkeiHelper.doRenkei(cards, SB_NameCardL_RenkeiHelper.ProcType.ACCOUNT);
    for (SmartViscaf__NameCard__c card :cards) {
      System.assertNotEquals(null, card.SmartViscaf__account__c);
      System.assertNotEquals(null, card.SmartViscaf__contact__c);
      System.assert(acnts.containsKey(card.SmartViscaf__account__c) == false);
      System.assert(conts.containsKey(card.SmartViscaf__contact__c) == false);
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
    List<SmartViscaf__NameCard__c> cards = Database.query('SELECT ' + NMAECARD_FIELDS + ' FROM SmartViscaf__NameCard__c LIMIT 1');
    for (SmartViscaf__NameCard__c card :cards) {
      System.assertEquals(null, card.SmartViscaf__account__c);
      System.assertEquals(null, card.SmartViscaf__contact__c);
    }
    SB_NameCardL_RenkeiHelper.doRenkei(cards, SB_NameCardL_RenkeiHelper.ProcType.ACCOUNT);
    for (SmartViscaf__NameCard__c card :cards) {
      System.assertEquals(null, card.SmartViscaf__account__c);
      System.assertEquals(null, card.SmartViscaf__contact__c);
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
    List<SmartViscaf__NameCard__c> cards = Database.query('SELECT ' + NMAECARD_FIELDS + ' FROM SmartViscaf__NameCard__c LIMIT 1');
    for (SmartViscaf__NameCard__c card :cards) {
      System.assertEquals(null, card.SmartViscaf__account__c);
      System.assertEquals(null, card.SmartViscaf__contact__c);
    }
    SB_NameCardL_RenkeiHelper.doRenkei(cards, SB_NameCardL_RenkeiHelper.ProcType.ACCOUNT);
    for (SmartViscaf__NameCard__c card :cards) {
      System.assertNotEquals(null, card.SmartViscaf__account__c);
      System.assertNotEquals(null, card.SmartViscaf__contact__c);
      System.assert(acnts.containsKey(card.SmartViscaf__account__c));
      System.assert(conts.containsKey(card.SmartViscaf__contact__c) == false);
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
    List<SmartViscaf__NameCard__c> cards = Database.query('SELECT ' + NMAECARD_FIELDS + ' FROM SmartViscaf__NameCard__c LIMIT 1');
    for (SmartViscaf__NameCard__c card :cards) {
      System.assertEquals(null, card.SmartViscaf__account__c);
      System.assertEquals(null, card.SmartViscaf__contact__c);
    }
    SB_NameCardL_RenkeiHelper.doRenkei(cards, SB_NameCardL_RenkeiHelper.ProcType.ACCOUNT);
    for (SmartViscaf__NameCard__c card :cards) {
      System.assertEquals(null, card.SmartViscaf__account__c);
      System.assertEquals(null, card.SmartViscaf__contact__c);
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
    List<SmartViscaf__NameCard__c> cards = Database.query('SELECT ' + NMAECARD_FIELDS + ' FROM SmartViscaf__NameCard__c LIMIT 1');
    for (SmartViscaf__NameCard__c card :cards) {
      System.assertEquals(null, card.SmartViscaf__account__c);
      System.assertEquals(null, card.SmartViscaf__contact__c);
    }
    SB_NameCardL_RenkeiHelper.doRenkei(cards, SB_NameCardL_RenkeiHelper.ProcType.ACCOUNT);
    for (SmartViscaf__NameCard__c card :cards) {
      System.assertNotEquals(null, card.SmartViscaf__account__c);
      System.assertEquals(null, card.SmartViscaf__contact__c);
    }
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
    List<SmartViscaf__NameCard__c> cards = Database.query('SELECT ' + NMAECARD_FIELDS + ' FROM SmartViscaf__NameCard__c LIMIT 1');
    for (SmartViscaf__NameCard__c card :cards) {
      //System.assertEquals(null, card.SmartViscaf__account__c);
      //System.assertEquals(null, card.SmartViscaf__contact__c);
      card.SmartViscaf__company_name__c = null;    // 会社名なしにしとく
    }
    SB_NameCardL_RenkeiHelper.doRenkei(cards, SB_NameCardL_RenkeiHelper.ProcType.ACCOUNT);
    for (SmartViscaf__NameCard__c card :cards) {
      System.assert(String.isNotBlank(card.SmartViscaf__RenkeiMessage__c));  // メッセージがせっとされてる
    }
    Test.stopTest();
  }



}