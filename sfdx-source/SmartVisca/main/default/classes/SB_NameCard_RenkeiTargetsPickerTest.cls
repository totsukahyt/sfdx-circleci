/**
 *
 * SB_NameCard_RenkeiTargetsPickerTest
 *  自動連携機能で、対象のアカウント、コンタクト、リードなどを抽出する Helperクラス SB_NameCard_RenkeiTargetsPicker のテストクラス
 *
 * Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2017.02.xx
 *
 **/
 @isTest
 private class SB_NameCard_RenkeiTargetsPickerTest
 {

  // アカウント、コンタクトの絞込はシンプルな条件でテストするよう
  public virtual class TestDb extends SB_NC_TestDB {

    public virtual override void initializeBasicSetting() {
      NameCardBasicSetting__c bs = SB_NC_PostInstallScript.createDefaultBasicSetting();
      //bs.RenkeiContactFirstName__c = false; // コンタクト 名
      bs.RenkeiAccountOverwrite__c = true;  // 既存の取引先を上書き
      bs.RenkeiContactOverwrite__c = true;   // 既存の取引先責任者を上書き
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
      //  RenkeiContactLastName__c = true,  // コンタクト 姓
      //  RenkeiContactFirstName__c = false, // コンタクト 名
      //  RenkeiContactMail__c = true,      // コンタクト メールアドレス
      //  RenkeiAccountQueryRecordTypeIds__c = null,    // 検索対象のレコードタイプタイプID カンマ区切り で羅列
      //  RenkeiContactQueryRecordTypeIds__c = null,  // 自動連携で検索対象の取引先責任者レコードタイプ
      //  RenkeiAccountOverwrite__c = true,   // 既存の取引先を上書き
      //  RenkeiContactOverwrite__c = true,   // 既存の取引先責任者を上書き
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

    public override void initialize() {
      initializeUser();
      if (listUser.isEmpty() == false)
        insert listUser;
      // 名刺基本設定
      initializeBasicSetting();
      if (!listBasicSetting.isEmpty()) {
        insert listBasicSetting;
      }
      //// 名刺連携項目マッピング
      //initializeMapping();
      //if (!listMapping.isEmpty()) {
      //  insert listMapping;
      //}
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
  } // TestDb

  // アカウント、コンタクトの絞込は精細な条件でテストするよう
  public class TestDbQueryStrict extends TestDb {

    public override void initializeBasicSetting() {
      //NameCardBasicSetting__c bs = SB_NC_PostInstallScript.createDefaultBasicSetting();
      NameCardBasicSetting__c bs = SB_NC_PostInstallScript.createDefaultBasicSetting();
      bs.RenkeiAccountAddressPref__c = true;   // アカウント 都道府県
      bs.RenkeiAccount_Street__c = true;   // アカウント 町名・番地
      bs.RenkeiAccountZipCode__c = true;   // アカウント 郵便番号
      bs.RenkeiAccountCity__c = true;      // アカウント 市区郡
      bs.RenkeiAccountURL__c = true;       // アカウント URL
      bs.RenkeiAccountCompany__c = true;   // アカウント 会社名
      bs.RenkeiAccountPhone__c = true;     // アカウント 電話番号
      bs.RenkeiAccountSite__c = true;        // アカウント 部署名
      //bs.RenkeiContactFirstName__c = false; // コンタクト 名
      bs.RenkeiAccountOverwrite__c = true;   // 既存の取引先を上書き
      bs.RenkeiContactOverwrite__c = true;   // 既存の取引先責任者を上書き

      //NameCardBasicSetting__c bs = new NameCardBasicSetting__c(
      //  RenkeiActive__c = false,      // 自動連携機能有効
      //  RenkeiAccountAddressPref__c = true,   // アカウント 都道府県
      //  RenkeiAccount_Street__c = true,   // アカウント 町名・番地
      //  RenkeiAccountZipCode__c = true,   // アカウント 郵便番号
      //  RenkeiAccountCity__c = true,      // アカウント 市区郡
      //  RenkeiAccountURL__c = true,       // アカウント URL
      //  RenkeiAccountCompany__c = true,   // アカウント 会社名
      //  RenkeiAccountPhone__c = true,     // アカウント 電話番号
      //  RenkeiSpecificItems__c = null,        // アカウント 特定項目
      //  RenkeiAccountSite__c = true,        // アカウント 部署名
      //  RenkeiExcludeHojinkakuPartial__c = true,      // 自動連携:会社名は法人格を除いて部分一致
      //  RenkeiExcludeHojinkaku__c = false,      // 自動連携:会社名は法人格を除いて完全一致
      //  RenkeiAccountSitePartialMatch__c = false,      // 自動連携:部署は中間一致検索
      //  RenkeiContactLastName__c = true,  // コンタクト 姓
      //  RenkeiContactFirstName__c = false, // コンタクト 名
      //  RenkeiContactMail__c = true,      // コンタクト メールアドレス
      //  RenkeiAccountQueryRecordTypeIds__c = null,    // 検索対象のレコードタイプタイプID カンマ区切り で羅列
      //  RenkeiContactQueryRecordTypeIds__c = null,  // 自動連携で検索対象の取引先責任者レコードタイプ
      //  RenkeiAccountOverwrite__c = true,   // 既存の取引先を上書き
      //  RenkeiContactOverwrite__c = true,   // 既存の取引先責任者を上書き
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
  } // class TestDbQueryStrict


  // アカウント、コンタクトの絞込は名刺メモとの対比がある条件でテストするよう
  public class TestDbQueryExtension extends TestDb {

    public override void initializeNameCard() {
      for (Employee emp :listEmp) {
        // 所有者の異なる名刺を作成
        for (User u : listUser) {
          listCard.add(
            new NameCard__c(
              name= emp.name
              , person_name_last__c= emp.sei
              , person_name_first__c= emp.mei
              , last_name__c= emp.sei.replace('苗字', 'Myoji')
              , first_name__c= emp.mei.replace('名', 'Na')
              , email__c= emp.mail
              , company_name__c= emp.kaisha.name
              , division__c = '本社'
              , title_name__c = '役職'+emp.num.format()
              , tel1__c= emp.kaisha.phone
              , tel2__c= emp.kaisha.phone
              , fax1__c= '0344444444'
              , mobile__c = '09099999999'
              , web_url1__c = 'http://www.'+emp.kaisha.domain
              , web_url2__c = 'http://www.'+emp.kaisha.domain
              , zip_code__c = emp.kaisha.zip
              , address_pref__c = emp.kaisha.pref
              , address__c = emp.kaisha.address
              , address_bld__c = emp.kaisha.bld
              , memo__c = emp.kaisha.name // 会社名に変更
              , freehandmemo__c = '自由記述 : ' + emp.kaisha.name +' '+ emp.num.format()
              , delivery_type__c='1'
              , OwnerId = u.Id
          ));
        }
      }
    }

    public override void initializeBasicSetting() {
      NameCardBasicSetting__c bs = SB_NC_PostInstallScript.createDefaultBasicSetting();
      bs.RenkeiSpecificItems__c = 'Name';        // アカウント 特定項目
      //bs.RenkeiContactFirstName__c = false; // コンタクト 名
      bs.RenkeiAccountOverwrite__c = true;   // 既存の取引先を上書き
      bs.RenkeiContactOverwrite__c = true;   // 既存の取引先責任者を上書き

      //NameCardBasicSetting__c bs = new NameCardBasicSetting__c(
      //  RenkeiActive__c = false,      // 自動連携機能有効
      //  RenkeiAccountAddressPref__c = false,   // アカウント 都道府県
      //  RenkeiAccount_Street__c = false,   // アカウント 町名・番地
      //  RenkeiAccountZipCode__c = false,   // アカウント 郵便番号
      //  RenkeiAccountCity__c = false,      // アカウント 市区郡
      //  RenkeiAccountURL__c = false,       // アカウント URL
      //  RenkeiAccountCompany__c = true,   // アカウント 会社名
      //  RenkeiAccountPhone__c = false,     // アカウント 電話番号
      //  RenkeiSpecificItems__c = 'Name',        // アカウント 特定項目
      //  RenkeiAccountSite__c = false,        // アカウント 部署名
      //  RenkeiExcludeHojinkakuPartial__c = true,      // 自動連携:会社名は法人格を除いて部分一致
      //  RenkeiExcludeHojinkaku__c = false,      // 自動連携:会社名は法人格を除いて完全一致
      //  RenkeiAccountSitePartialMatch__c = true,      // 自動連携:部署は中間一致検索
      //  RenkeiContactLastName__c = true,  // コンタクト 姓
      //  RenkeiContactFirstName__c = false, // コンタクト 名
      //  RenkeiContactMail__c = true,      // コンタクト メールアドレス
      //  RenkeiAccountQueryRecordTypeIds__c = null,    // 検索対象のレコードタイプタイプID カンマ区切り で羅列
      //  RenkeiContactQueryRecordTypeIds__c = null,  // 自動連携で検索対象の取引先責任者レコードタイプ
      //  RenkeiAccountOverwrite__c = true,   // 既存の取引先を上書き
      //  RenkeiContactOverwrite__c = true,   // 既存の取引先責任者を上書き
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

  } // class TestDbQueryExtension

  // アカウント、コンタクトの絞込はレコードタイプも条件にしてテストするよう ただし失敗する。
  public class TestDbQueryRecordType extends TestDb {
    public override void initializeBasicSetting() {
      Map<Id, Schema.RecordTypeInfo> accountRectypes = Account.sObjectType.getDescribe().getRecordTypeInfosById();
      String accountRectypeId = null;
      for (Id id : accountRectypes.keySet()) {
        if (accountRectypes.get(id).isAvailable() && !accountRectypes.get(id).isMaster()) { // 2019.05.xx 利用可能なレコードタイプなら
          accountRectypeId = id;
          break;
        }
      }
      Map<Id, Schema.RecordTypeInfo> contactRectypes = Contact.sObjectType.getDescribe().getRecordTypeInfosById();
      String contactRectypeId = null;
      for (Id id : contactRectypes.keySet()) {
        if (contactRectypes.get(id).isAvailable() && !contactRectypes.get(id).isMaster()) { // 2019.05.xx 利用可能なレコードタイプなら
          contactRectypeId = id;
          break;
        }
      }

      NameCardBasicSetting__c bs = SB_NC_PostInstallScript.createDefaultBasicSetting();
      //bs.RenkeiContactFirstName__c = false; // コンタクト 名
      bs.RenkeiAccountQueryRecordTypeIds__c = accountRectypeId;    // 検索対象のレコードタイプタイプID カンマ区切り で羅列
      bs.RenkeiContactQueryRecordTypeIds__c = contactRectypeId;  // 自動連携で検索対象の取引先責任者レコードタイプ
      bs.RenkeiAccountOverwrite__c = true;   // 既存の取引先を上書き
      bs.RenkeiContactOverwrite__c = true;   // 既存の取引先責任者を上書き

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
      //  RenkeiContactLastName__c = true,  // コンタクト 姓
      //  RenkeiContactFirstName__c = false, // コンタクト 名
      //  RenkeiContactMail__c = true,      // コンタクト メールアドレス
      //  RenkeiAccountQueryRecordTypeIds__c = accountRectypeId,    // 検索対象のレコードタイプタイプID カンマ区切り で羅列
      //  RenkeiContactQueryRecordTypeIds__c = contactRectypeId,  // 自動連携で検索対象の取引先責任者レコードタイプ
      //  RenkeiAccountOverwrite__c = true,   // 既存の取引先を上書き
      //  RenkeiContactOverwrite__c = true,   // 既存の取引先責任者を上書き
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

  } // class TestDbQueryRecordType


  private static final String NMAECARD_FIELDS = 'Id, Name, name_kana__c, person_name_last__c, person_name_first__c, last_name__c, first_name__c' +
  ', company_name__c, company_name_kana__c, division__c, division_name__c, title_name__c' +
  ', zip_code__c, address_pref__c, address__c, address_bld__c, address_eng__c, Saishin__c' +
  ', card_exchange_date__c, list_name__c, OwnerId, Owner.Name, Parent__c, tenshokugonomeishi__c, account__c, contact__c' +
  ', freehandmemo__c, memo__c, web_url1__c, web_url2__c, email__c, tel1__c, tel2__c, mobile__c, fax1__c, fax2__c' +
  ', image_id__c, bk_image_id__c, width__c, height__c, bk_width__c, bk_height__c' +
  ', isNotOverwrite__c, isNotOverContactwrite__c';

  //@isTest
  //static void test_getCradId2Targets()
  //{
  //  TestDb db = new TestDb();
  //  db.initialize();

  //  Test.startTest();
  //  Map<Id, Account> acnts = new Map<Id, Account> ([SELECT Id, Name FROM Account]);
  //  Map<Id, Contact> conts = new Map<Id, Contact> ([SELECT Id, Name, AccountId FROM Contact]);
  //  List<NameCard__c> cards = Database.query('SELECT ' + NMAECARD_FIELDS + ' FROM NameCard__c LIMIT 1');

  //  Map<Id, List<SB_NameCard_RenkeiTargetsPicker.Target>> cardId2Accounts = SB_NameCard_RenkeiTargetsPicker.getCradId2Targets(cards, Account.sObjectType);

  //  for (Id id : cardId2Accounts.keySet()) {
  //    List<SB_NameCard_RegistCardHolder.AccountTarget> ts = (List<SB_NameCard_RegistCardHolder.AccountTarget>)cardId2Accounts.get(id);
  //    System.assert(ts != null && !ts.isEmpty());
  //    for (SB_NameCard_RegistCardHolder.AccountTarget t : ts) {
  //      System.debug(t.targetId + ': ' + t.childIds.size());
  //    }
  //    System.assertEquals(1, ts.size());
  //    System.assertEquals(1, ts[0].childIds.size());
  //  }
  //  Test.stopTest();
  //}

  //@isTest
  //static void test_getCradId2TargetsQueryStrict()
  //{
  //  TestDbQueryStrict db = new TestDbQueryStrict();
  //  db.initialize();

  //  Test.startTest();
  //  Map<Id, Account> acnts = new Map<Id, Account> ([SELECT Id, Name FROM Account]);
  //  Map<Id, Contact> conts = new Map<Id, Contact> ([SELECT Id, Name, AccountId FROM Contact]);
  //  List<NameCard__c> cards = Database.query('SELECT ' + NMAECARD_FIELDS + ' FROM NameCard__c LIMIT 1');

  //  Map<Id, List<SB_NameCard_RenkeiTargetsPicker.Target>> cardId2Accounts = SB_NameCard_RenkeiTargetsPicker.getCradId2Targets(cards, Account.sObjectType);

  //  for (Id id : cardId2Accounts.keySet()) {
  //    List<SB_NameCard_RegistCardHolder.AccountTarget> ts = (List<SB_NameCard_RegistCardHolder.AccountTarget>)cardId2Accounts.get(id);
  //    System.assert(ts != null && !ts.isEmpty());
  //    for (SB_NameCard_RegistCardHolder.AccountTarget t : ts) {
  //      System.debug(t.targetId + ': ' + t.childIds.size());
  //    }
  //    System.assertEquals(1, ts.size());
  //    System.assertEquals(1, ts[0].childIds.size());
  //  }
  //  Test.stopTest();
  //}


  //@isTest
  //static void test_getCradId2TargetsQueryExtension()
  //{
  //  TestDbQueryExtension db = new TestDbQueryExtension();
  //  db.initialize();

  //  Test.startTest();
  //  Map<Id, Account> acnts = new Map<Id, Account> ([SELECT Id, Name FROM Account]);
  //  Map<Id, Contact> conts = new Map<Id, Contact> ([SELECT Id, Name, AccountId FROM Contact]);
  //  List<NameCard__c> cards = Database.query('SELECT ' + NMAECARD_FIELDS + ' FROM NameCard__c LIMIT 1');

  //  Map<Id, List<SB_NameCard_RenkeiTargetsPicker.Target>> cardId2Accounts = SB_NameCard_RenkeiTargetsPicker.getCradId2Targets(cards, Account.sObjectType);

  //  for (Id id : cardId2Accounts.keySet()) {
  //    List<SB_NameCard_RegistCardHolder.AccountTarget> ts = (List<SB_NameCard_RegistCardHolder.AccountTarget>)cardId2Accounts.get(id);
  //    System.assert(ts != null && !ts.isEmpty());
  //    for (SB_NameCard_RegistCardHolder.AccountTarget t : ts) {
  //      System.debug(t.targetId + ': ' + t.childIds.size());
  //    }
  //    System.assertEquals(1, ts.size());
  //    System.assertEquals(1, ts[0].childIds.size());
  //  }
  //  Test.stopTest();
  //}


  //@isTest
  //static void test_getCradId2TargetsCreateQueryRecordType()
  //{
  //  TestDbQueryRecordType db = new TestDbQueryRecordType();
  //  db.initialize();

  //  Test.startTest();
  //  SB_NameCard_RenkeiTargetsPicker.AccountsCardHolderBuilder builder = new SB_NameCard_RenkeiTargetsPicker.AccountsCardHolderBuilder();
  //  String soql = builder.createQuery();
  //  System.assert(String.isNotBlank(soql));
  //  //Map<Id, Account> acnts = new Map<Id, Account> ([SELECT Id, Name FROM Account]);
  //  //Map<Id, Contact> conts = new Map<Id, Contact> ([SELECT Id, Name, AccountId FROM Contact]);
  //  //List<NameCard__c> cards = Database.query('SELECT ' + NMAECARD_FIELDS + ' FROM NameCard__c LIMIT 1');

  //  //Map<Id, List<SB_NameCard_RenkeiTargetsPicker.Target>> cardId2Accounts = SB_NameCard_RenkeiTargetsPicker.getCradId2Targets(cards, Account.sObjectType);

  //  //System.assert(true, cardId2Accounts.isEmpty());
  //  Test.stopTest();
  //}

  @isTest
  static void test_getCradId2Targets()
  {
    TestDb db = new TestDb();
    db.initialize();

    Test.startTest();
    Map<Id, Account> acnts = new Map<Id, Account> ([SELECT Id, Name FROM Account]);
    Map<Id, Contact> conts = new Map<Id, Contact> ([SELECT Id, Name, AccountId FROM Contact]);
    List<NameCard__c> cards = Database.query('SELECT ' + NMAECARD_FIELDS + ' FROM NameCard__c LIMIT 1');

    List<SB_NameCard_RegistCardHolder.AccountCardHolder> accountCardHolder
          = (List<SB_NameCard_RegistCardHolder.AccountCardHolder>)SB_NameCard_RenkeiTargetsPicker.createCardHolders(cards, Account.sObjectType);

    for (SB_NameCard_RegistCardHolder.AccountCardHolder holder : accountCardHolder) {
      System.assert(holder.targets != null && !holder.targets.isEmpty());
      for (SB_NameCard_RegistCardHolder.AccountTarget t : holder.targets) {
        System.debug(t.targetId + ': ' + t.childIds.size());
      }
      System.assertEquals(1, holder.targets.size());
      System.assertEquals(1, holder.targets[0].childIds.size());
    }
    Test.stopTest();
  }

  @isTest
  static void test_getCradId2CardHolderQueryStrict()
  {
    TestDbQueryStrict db = new TestDbQueryStrict();
    db.initialize();

    Test.startTest();
    Map<Id, Account> acnts = new Map<Id, Account> ([SELECT Id, Name FROM Account]);
    Map<Id, Contact> conts = new Map<Id, Contact> ([SELECT Id, Name, AccountId FROM Contact]);
    List<NameCard__c> cards = Database.query('SELECT ' + NMAECARD_FIELDS + ' FROM NameCard__c');    // LIMIT 1 でなくてととおる

    List<SB_NameCard_RegistCardHolder.AccountCardHolder> accountCardHolder
          = (List<SB_NameCard_RegistCardHolder.AccountCardHolder>)SB_NameCard_RenkeiTargetsPicker.createCardHolders(cards, Account.sObjectType);

    for (SB_NameCard_RegistCardHolder.AccountCardHolder holder : accountCardHolder) {
      System.assert(holder.targets != null && !holder.targets.isEmpty());
      for (SB_NameCard_RegistCardHolder.AccountTarget t : holder.targets) {
        System.debug(t.targetId + ': ' + t.childIds.size());
      }
      System.assertEquals(1, holder.targets.size());
      System.assertEquals(1, holder.targets[0].childIds.size());
    }
    Test.stopTest();
  }

  @isTest
  static void test_getCradId2CardHolderQueryExtension()
  {
    TestDbQueryExtension db = new TestDbQueryExtension();
    db.initialize();

    Test.startTest();
    Map<Id, Account> acnts = new Map<Id, Account> ([SELECT Id, Name FROM Account]);
    Map<Id, Contact> conts = new Map<Id, Contact> ([SELECT Id, Name, AccountId FROM Contact]);
    List<NameCard__c> cards = Database.query('SELECT ' + NMAECARD_FIELDS + ' FROM NameCard__c LIMIT 1');

    List<SB_NameCard_RegistCardHolder.AccountCardHolder> accountCardHolder
          = (List<SB_NameCard_RegistCardHolder.AccountCardHolder>)SB_NameCard_RenkeiTargetsPicker.createCardHolders(cards, Account.sObjectType);

    for (SB_NameCard_RegistCardHolder.AccountCardHolder holder : accountCardHolder) {
      System.assert(holder.targets != null && !holder.targets.isEmpty());
      for (SB_NameCard_RegistCardHolder.AccountTarget t : holder.targets) {
        System.debug(t.targetId + ': ' + t.childIds.size());
      }
      System.assertEquals(1, holder.targets.size());
      System.assertEquals(1, holder.targets[0].childIds.size());
    }
    Test.stopTest();
  }


  @isTest
  static void test_getCradId2CardHolderCreateQueryRecordType()
  {
    TestDbQueryRecordType db = new TestDbQueryRecordType();
    db.initialize();

    Test.startTest();
    SB_NameCard_RenkeiTargetsPicker.AccountsCardHolderBuilder builder = new SB_NameCard_RenkeiTargetsPicker.AccountsCardHolderBuilder();
    String soql = builder.createQuery();
    System.assert(String.isNotBlank(soql));
    //Map<Id, Account> acnts = new Map<Id, Account> ([SELECT Id, Name FROM Account]);
    //Map<Id, Contact> conts = new Map<Id, Contact> ([SELECT Id, Name, AccountId FROM Contact]);
    //List<NameCard__c> cards = Database.query('SELECT ' + NMAECARD_FIELDS + ' FROM NameCard__c LIMIT 1');

    //Map<Id, SB_NameCard_RenkeiTargetsPicker.CardHolder> cardId2Accounts = SB_NameCard_RenkeiTargetsPicker.createCardHolders(cards, Account.sObjectType);

    //System.assert(true, cardId2Accounts.isEmpty());
    Test.stopTest();
  }

}