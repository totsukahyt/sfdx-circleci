/**
 *
 * SB_NameCard_RegistSoqlCountCanPickerTest
 *  SB_NameCard_RegistSoqlCountCanPicker SOQL検索 のテストクラス 
 * 
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1  2019.06.xx v2.4
 *
 **/
@isTest
private class SB_NameCard_RegistSoqlCountCanPickerTest {

  private class TestDb extends SB_NC_TestDB {

    // 会社名は(法人格含め)完全一致で自動連携の設定
    public override void initializeBasicSetting() {
      NameCardBasicSetting__c bs = SB_NC_PostInstallScript.createDefaultBasicSetting();
      listBasicSetting.add(bs);
    }
    // SmartVisca設定　
    // トリガを有効・無効
    // 自動連携: 電話番号2 は取引先候補の条件に使わない FALSE
    public virtual override void initializeSmartViscaConfig() {
      svConfig = SmartViscaConfig__c.getOrgDefaults();
      // svConfig.TriggerRegDateTime__c = true;
    }

    public override void initialize() {
      // initializeUser();
      // if (listUser.isEmpty() == false) {
      //   insert listUser;
      // }
      // SmartVisca設定
      initializeSmartViscaConfig();
      if (svConfig !=null) {
        upsert svConfig;
      }
      // 名刺基本設定
      initializeBasicSetting();
      if (!listBasicSetting.isEmpty()) {
        insert listBasicSetting;
      }
    }
  } // TestDb

  @testSetup
  static void setupDB() {
    TestDb db = new TestDb();
    db.initialize();  

    List<Account> acnts = new List<Account>();
    // サンブリッジ系
    acnts.add(new Account(Name='株式会社サンブリッジ', Site='静岡支社', AccountNumber='0')); // 社名一致、部分一致、完全一致略称同一視、完全一致略称区別
    acnts.add(new Account(Name='株式会社 サンブリッジ', Site='静岡支社', AccountNumber='1')); // 社名一致、部分一致、完全一致略称同一視
    acnts.add(new Account(Name='(株) サンブリッジ', Site='静岡支社', AccountNumber='2'));     // 社名一致、部分一致、完全一致略称同一視
    acnts.add(new Account(Name='サンブリッジ (株)', Site='静岡支社', AccountNumber='3'));     // 社名一致、部分一致
    acnts.add(new Account(Name='有限会社 サンブリッジ', Site='静岡支社', AccountNumber='4'));     // 社名一致、部分一致
    acnts.add(new Account(Name='(株) サンブリッジ商事', Site='静岡支社', AccountNumber='5')); // 部分一致
    acnts.add(new Account(Name='サンブリッジ海運 (株)', Site='静岡支社', AccountNumber='6')); // 部分一致
    // 恵比寿システム
    acnts.add(new Account(Name='株式会社 恵比寿システム', Site='静岡支社', AccountNumber='7')); // 社名一致、部分一致、完全一致略称同一視、完全一致略称区別
    acnts.add(new Account(Name='株式会社恵比寿システム', Site='静岡支社', AccountNumber='8')); // 社名一致、部分一致、完全一致略称同一視
    acnts.add(new Account(Name='(株) 恵比寿システム', Site='静岡支社', AccountNumber='9'));     // 社名一致、部分一致、完全一致略称同一視
    acnts.add(new Account(Name='恵比寿システム (株)', Site='静岡支社', AccountNumber='10'));     // 社名一致、部分一致
    acnts.add(new Account(Name='有限会社 恵比寿システム', Site='静岡支社', AccountNumber='11'));     // 社名一致、部分一致
    acnts.add(new Account(Name='(株) 恵比寿システム商事', Site='静岡支社', AccountNumber='12')); // 部分一致
    acnts.add(new Account(Name='恵比寿システム海運 (株)', Site='静岡支社', AccountNumber='13')); // 部分一致

    insert acnts;

    List<Contact> conts = new List<Contact>();
    // サンブリッジ系
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@0.com', Department='営業部', AccountId=acnts[0].Id));       // 姓名が名刺と一緒
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@test.com', Department='営業部', AccountId=acnts[0].Id));    // 姓名メアドが名刺と一緒
    conts.add(new Contact(LastName='検証', FirstName='太郎', EMail='taro@test.com', Department='営業部', AccountId=acnts[0].Id));    // メアドが名刺と一緒
    conts.add(new Contact(LastName='テスト', FirstName='一郎', EMail='ichiro@0.com', Department='営業部', AccountId=acnts[0].Id));    // 姓名メアド 一致しない
    conts.add(new Contact(LastName='テスト', FirstName='一郎', EMail='ichiro@test.com', Department='営業部', AccountId=acnts[0].Id)); // 姓名メアド 一致しない

    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@1.com', AccountId=acnts[1].Id));
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@test.com', AccountId=acnts[1].Id));    // 姓名メアドが名刺と一緒
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@2.com', AccountId=acnts[2].Id));
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@test.com', AccountId=acnts[2].Id));    // 姓名メアドが名刺と一緒
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@3.com', AccountId=acnts[3].Id));
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@test.com', AccountId=acnts[3].Id));    // 姓名メアドが名刺と一緒
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@4.com', AccountId=acnts[4].Id));
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@test.com', AccountId=acnts[4].Id));    // 姓名メアドが名刺と一緒
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@5.com', AccountId=acnts[5].Id));
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@test.com', AccountId=acnts[5].Id));    // 姓名メアドが名刺と一緒
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@6.com', AccountId=acnts[6].Id));
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@test.com', AccountId=acnts[6].Id));    // 姓名メアドが名刺と一緒

    // 恵比寿システム
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@0.com', Department='営業部', AccountId=acnts[7].Id));       // 姓名が名刺と一緒
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@test.com', Department='営業部', AccountId=acnts[7].Id));    // 姓名メアドが名刺と一緒
    conts.add(new Contact(LastName='検証', FirstName='太郎', EMail='taro@test.com', Department='営業部', AccountId=acnts[7].Id));    // メアドが名刺と一緒
    conts.add(new Contact(LastName='テスト', FirstName='一郎', EMail='ichiro@0.com', Department='営業部', AccountId=acnts[7].Id));    // 姓名メアド 一致しない
    conts.add(new Contact(LastName='テスト', FirstName='一郎', EMail='ichiro@test.com', Department='営業部', AccountId=acnts[7].Id));  // 姓名メアド 一致しない

    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@1.com', AccountId=acnts[8].Id));
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@test.com', AccountId=acnts[8].Id));    // 姓名メアドが名刺と一緒
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@2.com', AccountId=acnts[9].Id));
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@test.com', AccountId=acnts[9].Id));    // 姓名メアドが名刺と一緒
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@3.com', AccountId=acnts[10].Id));
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@test.com', AccountId=acnts[10].Id));    // 姓名メアドが名刺と一緒
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@4.com', AccountId=acnts[11].Id));
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@test.com', AccountId=acnts[11].Id));    // 姓名メアドが名刺と一緒
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@5.com', AccountId=acnts[12].Id));
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@test.com', AccountId=acnts[12].Id));    // 姓名メアドが名刺と一緒
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@6.com', AccountId=acnts[13].Id));
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@test.com', AccountId=acnts[13].Id));    // 姓名メアドが名刺と一緒

    insert conts;

  }

  /* 会社名一致 編 */
  // SOQL検索
  // CorpMatch-1
  // 会社名一致
  // 部署照合 オフ
  // 姓名 一致、メアドのみ一致オフ
  @isTest
  static void test_createAccountContact_Soql_CorpMatch_deptOff_emailoff_emailonlyoff() {
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    // 株式会社サンブリッジ テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社サンブリッジ', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    // 株式会社 恵比寿システム テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社 恵比寿システム', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    insert listCard;

    Test.startTest();
    SB_NameCard_Util.smartViscaConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL　に
    SB_NameCard_BasicSetting.getNameCardBasicSetting().HojinkakuEquationLongAndAbbr__c = true; // // v2.4 会社名の法人格は略称・正称を同一視

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.getSObjectType());
    qo_a.bulkRegist = true;
    qo_a.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.CorpMatch;  // 社名一致
    qo_a.queryDept = false;  // 部署照合 オフ
    qo_a.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_a.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ ← 一括では常にオフ コンタクトのクエリで出すから
    SB_NC_RegistQueryOption qo_c = new SB_NC_RegistQueryOption(Contact.getSObjectType());
    qo_c.bulkRegist = true;
    qo_c.queryCompany = false;  // コンタクトの会社名照合 オフ
    qo_c.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.CorpMatch;  // 社名一致
    qo_c.queryDept = false;  // 部署照合 オフ
    qo_c.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_c.queryEMail = false;  // メアドは条件 オフ
    qo_c.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ
    qo_c.queryNameOrEMail = false; // 姓名 or メールアドレス いずれか一致でOK オフ

    Map<Id, NameCard__c> cards = new Map<Id, NameCard__c> ([SELECT Id, Name, company_name__c, division__c, email__c FROM NameCard__c LIMIT 10]);

    // SOSL 検索結果 を セット
    // Map<Id, Account> acnts = new Map<Id, Account>([SELECT Id, Name FROM Account]);
    // Test.setFixedSearchResults(new List<Id>(acnts.keySet()));

    // 名刺-登録先候補s 取得
    SB_NameCard_RegistCanPickerAbstract picker = SB_NameCard_RegistCanPickerAbstract.createCandidatePicker(new List<SB_NC_RegistQueryOption> { qo_a, qo_c }, cards.keySet());
    System.assert(picker instanceOf SB_NameCard_RegistSoqlCountCanPicker);
    Map<Id, Map<SObjectType, List<SObject>>> cardId2RecMap = picker.create();
    Test.stopTest();
    
    System.assertEquals(2, cardId2RecMap.size());
    for (Id cardId : cardId2RecMap.keySet()) {
      NameCard__c card = cards.get(cardId);
      System.debug(String.format('NameCard__c: {0}, {1}, {2}', new String[] {card.Name, card.company_name__c, card.division__c }));
      Map<SObjectType, List<SObject>> otype2records = cardId2RecMap.get(cardId);
      // アカウント調査
      System.assertEquals(5, otype2records.get(Account.getSObjectType()).size());  // アカウント数
      for (Account rec : (List<Account>)otype2records.get(Account.getSObjectType())) {
        System.debug(String.format('Account: {0}, {1}', new String[] { rec.Name, rec.Site }));
        System.assert(rec.Name.contains(card.company_name__c.replace('株式会社', '').trim())); // アカウント名
      } 
      // コンタクト調査
      System.assertEquals(28, otype2records.get(Contact.getSObjectType()).size()); // コンタクト数
      for (Contact rec : (List<Contact>)otype2records.get(Contact.getSObjectType())) {
        System.debug(String.format('Contact: {0}, {1}, {2}', new String[] { rec.Name, rec.Email, rec.Department }));
        System.assert(rec.Name == card.Name || rec.Email == card.email__c);  // コンタクト名 か メアド は一致
      } 
    }
  }

  
  // SOQL検索
  // CorpMatch-2
  // 会社名一致
  // 部署照合 オフ
  // 姓名メアド 一致、メアドのみ一致オフ
  @isTest
  static void test_createAccountContact_Soql_CorpMatch_deptOff_emailon_emailonlyoff() {
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    // 株式会社サンブリッジ テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社サンブリッジ', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    // 株式会社 恵比寿システム テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社 恵比寿システム', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    insert listCard;

    Test.startTest();
    SB_NameCard_Util.smartViscaConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL　に
    SB_NameCard_BasicSetting.getNameCardBasicSetting().HojinkakuEquationLongAndAbbr__c = true; // // v2.4 会社名の法人格は略称・正称を同一視

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.getSObjectType());
    qo_a.bulkRegist = true;
    qo_a.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.CorpMatch;  // 社名一致
    qo_a.queryDept = false;  // 部署照合 オフ
    qo_a.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_a.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ ← 一括では常にオフ コンタクトのクエリで出すから
    SB_NC_RegistQueryOption qo_c = new SB_NC_RegistQueryOption(Contact.getSObjectType());
    qo_c.bulkRegist = true;
    qo_c.queryCompany = false;  // コンタクトの会社名照合 オフ
    qo_c.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.CorpMatch;  // 社名一致
    qo_c.queryDept = false;  // 部署照合 オフ
    qo_c.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_c.queryEMail = true;  // メアドは条件 オン
    qo_c.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ
    qo_c.queryNameOrEMail = false; // 姓名 or メールアドレス いずれか一致でOK オフ

    Map<Id, NameCard__c> cards = new Map<Id, NameCard__c> ([SELECT Id, Name, company_name__c, division__c, email__c FROM NameCard__c LIMIT 10]);

    // SOSL 検索結果 を セット
    // Map<Id, Account> acnts = new Map<Id, Account>([SELECT Id, Name FROM Account]);
    // Test.setFixedSearchResults(new List<Id>(acnts.keySet()));

    // 名刺-登録先候補s 取得
    SB_NameCard_RegistCanPickerAbstract picker = SB_NameCard_RegistCanPickerAbstract.createCandidatePicker(new List<SB_NC_RegistQueryOption> { qo_a, qo_c }, cards.keySet());
    System.assert(picker instanceOf SB_NameCard_RegistSoqlCountCanPicker);
    Map<Id, Map<SObjectType, List<SObject>>> cardId2RecMap = picker.create();
    Test.stopTest();
    
    System.assertEquals(2, cardId2RecMap.size());
    for (Id cardId : cardId2RecMap.keySet()) {
      NameCard__c card = cards.get(cardId);
      System.debug(String.format('NameCard__c: {0}, {1}, {2}', new String[] {card.Name, card.company_name__c, card.division__c }));
      Map<SObjectType, List<SObject>> otype2records = cardId2RecMap.get(cardId);
      // アカウント調査
      System.assertEquals(5, otype2records.get(Account.getSObjectType()).size());  // アカウント数
      for (Account rec : (List<Account>)otype2records.get(Account.getSObjectType())) {
        System.debug(String.format('Account: {0}, {1}', new String[] { rec.Name, rec.Site }));
        System.assert(rec.Name.contains(card.company_name__c.replace('株式会社', '').trim())); // アカウント名
      } 
      // コンタクト調査
      System.assertEquals(14, otype2records.get(Contact.getSObjectType()).size()); // コンタクト数
      for (Contact rec : (List<Contact>)otype2records.get(Contact.getSObjectType())) {
        System.debug(String.format('Contact: {0}, {1}, {2}', new String[] { rec.Name, rec.Email, rec.Department }));
        System.assert(rec.Name == card.Name || rec.Email == card.email__c);  // コンタクト名 か メアド は一致
      } 
    }
  }

  // SOQL検索
  // CorpMatch-3
  // 会社名一致
  // 部署照合 オフ
  // 姓名メアド 一致、メアドのみ一致オン
  @isTest
  static void test_createAccountContact_Soql_CorpMatch_deptOff_emailon_emailonlyon() {
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    // 株式会社サンブリッジ テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社サンブリッジ', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    // 株式会社 恵比寿システム テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社 恵比寿システム', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    insert listCard;

    Test.startTest();
    SB_NameCard_Util.smartViscaConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL　に
    SB_NameCard_BasicSetting.getNameCardBasicSetting().HojinkakuEquationLongAndAbbr__c = true; // // v2.4 会社名の法人格は略称・正称を同一視

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.getSObjectType());
    qo_a.bulkRegist = true;
    qo_a.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.CorpMatch;  // 社名一致
    qo_a.queryDept = false;  // 部署照合 オフ
    qo_a.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_a.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ ← 一括では常にオフ コンタクトのクエリで出すから
    SB_NC_RegistQueryOption qo_c = new SB_NC_RegistQueryOption(Contact.getSObjectType());
    qo_c.bulkRegist = true;
    qo_c.queryCompany = false;  // コンタクトの会社名照合 オフ
    qo_c.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.CorpMatch;  // 社名一致
    qo_c.queryDept = false;  // 部署照合 オフ
    qo_c.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_c.queryEMail = true;  // メアドは条件 オン
    qo_c.queryOnlyEMail = true;  // コンタクトはメアドのみ一致で該当 オン
    qo_c.queryNameOrEMail = false; // 姓名 or メールアドレス いずれか一致でOK オフ

    Map<Id, NameCard__c> cards = new Map<Id, NameCard__c> ([SELECT Id, Name, company_name__c, division__c, email__c FROM NameCard__c LIMIT 10]);

    // SOSL 検索結果 を セット
    // Map<Id, Account> acnts = new Map<Id, Account>([SELECT Id, Name FROM Account]);
    // Test.setFixedSearchResults(new List<Id>(acnts.keySet()));

    // 名刺-登録先候補s 取得
    SB_NameCard_RegistCanPickerAbstract picker = SB_NameCard_RegistCanPickerAbstract.createCandidatePicker(new List<SB_NC_RegistQueryOption> { qo_a, qo_c }, cards.keySet());
    System.assert(picker instanceOf SB_NameCard_RegistSoqlCountCanPicker);
    Map<Id, Map<SObjectType, List<SObject>>> cardId2RecMap = picker.create();
    Test.stopTest();
    
    System.assertEquals(2, cardId2RecMap.size());
    for (Id cardId : cardId2RecMap.keySet()) {
      NameCard__c card = cards.get(cardId);
      System.debug(String.format('NameCard__c: {0}, {1}, {2}', new String[] {card.Name, card.company_name__c, card.division__c }));
      Map<SObjectType, List<SObject>> otype2records = cardId2RecMap.get(cardId);
      // アカウント調査
      System.assertEquals(5, otype2records.get(Account.getSObjectType()).size());  // アカウント数
      for (Account rec : (List<Account>)otype2records.get(Account.getSObjectType())) {
        System.debug(String.format('Account: {0}, {1}', new String[] { rec.Name, rec.Site }));
        System.assert(rec.Name.contains(card.company_name__c.replace('株式会社', '').trim())); // アカウント名
      } 
      // コンタクト調査
      System.assertEquals(16, otype2records.get(Contact.getSObjectType()).size()); // コンタクト数  メアドのみ一致各 1
      for (Contact rec : (List<Contact>)otype2records.get(Contact.getSObjectType())) {
        System.debug(String.format('Contact: {0}, {1}, {2}', new String[] { rec.Name, rec.Email, rec.Department }));
        System.assert(rec.Name == card.Name || rec.Email == card.email__c);  // コンタクト名 か メアド は一致
      } 
    }
  }

  // SOQL検索
  // CorpMatch-4
  // 会社名一致
  // 部署照合 オン
  // 姓名メアド 一致、メアドのみ一致オン
  @isTest
  static void test_createAccountContact_Soql_CorpMatch_depton_emailon_emailonlyon() {
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    // 株式会社サンブリッジ テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社サンブリッジ', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    // 株式会社 恵比寿システム テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社 恵比寿システム', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    insert listCard;

    Test.startTest();
    SB_NameCard_Util.smartViscaConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL　に
    SB_NameCard_BasicSetting.getNameCardBasicSetting().HojinkakuEquationLongAndAbbr__c = true; // // v2.4 会社名の法人格は略称・正称を同一視

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.getSObjectType());
    qo_a.bulkRegist = true;
    qo_a.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.CorpMatch;  // 社名一致
    qo_a.queryDept = true;  // 部署照合 オン
    qo_a.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_a.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ ← 一括では常にオフ コンタクトのクエリで出すから
    SB_NC_RegistQueryOption qo_c = new SB_NC_RegistQueryOption(Contact.getSObjectType());
    qo_c.bulkRegist = true;
    qo_c.queryCompany = false;  // コンタクトの会社名照合 オフ
    qo_c.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.CorpMatch;  // 社名一致
    qo_c.queryDept = false;  // 部署照合 オフ
    qo_c.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_c.queryEMail = true;  // メアドは条件 オン
    qo_c.queryOnlyEMail = true;  // コンタクトはメアドのみ一致で該当 オン
    qo_c.queryNameOrEMail = false; // 姓名 or メールアドレス いずれか一致でOK オフ

    Map<Id, NameCard__c> cards = new Map<Id, NameCard__c> ([SELECT Id, Name, company_name__c, division__c, email__c FROM NameCard__c LIMIT 10]);

    // SOSL 検索結果 を セット
    // Map<Id, Account> acnts = new Map<Id, Account>([SELECT Id, Name FROM Account]);
    // Test.setFixedSearchResults(new List<Id>(acnts.keySet()));

    // 名刺-登録先候補s 取得
    SB_NameCard_RegistCanPickerAbstract picker = SB_NameCard_RegistCanPickerAbstract.createCandidatePicker(new List<SB_NC_RegistQueryOption> { qo_a, qo_c }, cards.keySet());
    System.assert(picker instanceOf SB_NameCard_RegistSoqlCountCanPicker);
    Map<Id, Map<SObjectType, List<SObject>>> cardId2RecMap = picker.create();
    Test.stopTest();
    
    System.assertEquals(2, cardId2RecMap.size());
    for (Id cardId : cardId2RecMap.keySet()) {
      NameCard__c card = cards.get(cardId);
      System.debug(String.format('NameCard__c: {0}, {1}, {2}', new String[] {card.Name, card.company_name__c, card.division__c }));
      Map<SObjectType, List<SObject>> otype2records = cardId2RecMap.get(cardId);
      // アカウント調査
      System.assertEquals(0, otype2records.get(Account.getSObjectType()).size());  // アカウント数 0
      for (Account rec : (List<Account>)otype2records.get(Account.getSObjectType())) {
        System.debug(String.format('Account: {0}, {1}', new String[] { rec.Name, rec.Site }));
        System.assert(rec.Name.contains(card.company_name__c.replace('株式会社', '').trim())); // アカウント名
      } 
      // コンタクト調査
      System.assertEquals(16, otype2records.get(Contact.getSObjectType()).size()); // コンタクト数  メアドのみ一致各 1
      for (Contact rec : (List<Contact>)otype2records.get(Contact.getSObjectType())) {
        System.debug(String.format('Contact: {0}, {1}, {2}', new String[] { rec.Name, rec.Email, rec.Department }));
        System.assert(rec.Name == card.Name || rec.Email == card.email__c);  // コンタクト名 か メアド は一致
      } 
    }
  }

  // SOQL検索
  // CorpMatch-5
  // 会社名一致
  // 部署照合 オン
  // 姓名メアド 一致、メアドのみ一致オン
  @isTest
  static void test_createAccountContact_Soql_CorpMatch_deptonMatch_emailon_emailonlyon() {
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    // 株式会社サンブリッジ テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社サンブリッジ', division__c='静岡',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    // 株式会社 恵比寿システム テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社 恵比寿システム', division__c='静岡',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    insert listCard;

    Test.startTest();
    SB_NameCard_Util.smartViscaConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL　に
    SB_NameCard_BasicSetting.getNameCardBasicSetting().HojinkakuEquationLongAndAbbr__c = true; // // v2.4 会社名の法人格は略称・正称を同一視

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.getSObjectType());
    qo_a.bulkRegist = true;
    qo_a.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.CorpMatch;  // 社名一致
    qo_a.queryDept = true;  // 部署照合 オン
    qo_a.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_a.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ ← 一括では常にオフ コンタクトのクエリで出すから
    SB_NC_RegistQueryOption qo_c = new SB_NC_RegistQueryOption(Contact.getSObjectType());
    qo_c.bulkRegist = true;
    qo_c.queryCompany = false;  // コンタクトの会社名照合 オフ
    qo_c.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.CorpMatch;  // 社名一致
    qo_c.queryDept = false;  // 部署照合 オフ
    qo_c.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_c.queryEMail = true;  // メアドは条件 オン
    qo_c.queryOnlyEMail = true;  // コンタクトはメアドのみ一致で該当 オン
    qo_c.queryNameOrEMail = false; // 姓名 or メールアドレス いずれか一致でOK オフ

    Map<Id, NameCard__c> cards = new Map<Id, NameCard__c> ([SELECT Id, Name, company_name__c, division__c, email__c FROM NameCard__c LIMIT 10]);

    // SOSL 検索結果 を セット
    // Map<Id, Account> acnts = new Map<Id, Account>([SELECT Id, Name FROM Account]);
    // Test.setFixedSearchResults(new List<Id>(acnts.keySet()));

    // 名刺-登録先候補s 取得
    SB_NameCard_RegistCanPickerAbstract picker = SB_NameCard_RegistCanPickerAbstract.createCandidatePicker(new List<SB_NC_RegistQueryOption> { qo_a, qo_c }, cards.keySet());
    System.assert(picker instanceOf SB_NameCard_RegistSoqlCountCanPicker);
    Map<Id, Map<SObjectType, List<SObject>>> cardId2RecMap = picker.create();
    Test.stopTest();
    
    System.assertEquals(2, cardId2RecMap.size());
    for (Id cardId : cardId2RecMap.keySet()) {
      NameCard__c card = cards.get(cardId);
      System.debug(String.format('NameCard__c: {0}, {1}, {2}', new String[] {card.Name, card.company_name__c, card.division__c }));
      Map<SObjectType, List<SObject>> otype2records = cardId2RecMap.get(cardId);
      // アカウント調査
      System.assertEquals(5, otype2records.get(Account.getSObjectType()).size());  // アカウント数 0
      for (Account rec : (List<Account>)otype2records.get(Account.getSObjectType())) {
        System.debug(String.format('Account: {0}, {1}', new String[] { rec.Name, rec.Site }));
        System.assert(rec.Name.contains(card.company_name__c.replace('株式会社', '').trim())); // アカウント名
      } 
      // コンタクト調査
      System.assertEquals(16, otype2records.get(Contact.getSObjectType()).size()); // コンタクト数  メアドのみ一致各 1
      for (Contact rec : (List<Contact>)otype2records.get(Contact.getSObjectType())) {
        System.debug(String.format('Contact: {0}, {1}, {2}', new String[] { rec.Name, rec.Email, rec.Department }));
        System.assert(rec.Name == card.Name || rec.Email == card.email__c);  // コンタクト名 か メアド は一致
      } 
    }
  }

  // SOQL検索
  // CorpMatch-6
  // 会社名一致
  // 部署照合 オフ
  // 姓名メアド 一致、メアドのみ一致オフ
  // コンタクトの会社名照合 オン
  @isTest
  static void test_createAccountContact_Soql_CorpMatch_deptOff_emailon_emailonlyoff_contactCompanyOn() {
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    // 株式会社サンブリッジ テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社サンブリッジ', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    // 株式会社 恵比寿システム テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社 恵比寿システム', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    insert listCard;

    Test.startTest();
    SB_NameCard_Util.smartViscaConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL　に
    SB_NameCard_BasicSetting.getNameCardBasicSetting().HojinkakuEquationLongAndAbbr__c = true; // // v2.4 会社名の法人格は略称・正称を同一視

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.getSObjectType());
    qo_a.bulkRegist = true;
    qo_a.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.CorpMatch;  // 社名一致
    qo_a.queryDept = false;  // 部署照合 オフ
    qo_a.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_a.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ ← 一括では常にオフ コンタクトのクエリで出すから
    SB_NC_RegistQueryOption qo_c = new SB_NC_RegistQueryOption(Contact.getSObjectType());
    qo_c.bulkRegist = true;
    qo_c.queryCompany = true;  // コンタクトの会社名照合 オン
    qo_c.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.CorpMatch;  // 社名一致
    qo_c.queryDept = false;  // 部署照合 オフ
    qo_c.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_c.queryEMail = true;  // メアドは条件 オン
    qo_c.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ
    qo_c.queryNameOrEMail = false; // 姓名 or メールアドレス いずれか一致でOK オフ

    Map<Id, NameCard__c> cards = new Map<Id, NameCard__c> ([SELECT Id, Name, company_name__c, division__c, email__c FROM NameCard__c LIMIT 10]);

    // SOSL 検索結果 を セット
    // Map<Id, Account> acnts = new Map<Id, Account>([SELECT Id, Name FROM Account]);
    // Test.setFixedSearchResults(new List<Id>(acnts.keySet()));

    // 名刺-登録先候補s 取得
    SB_NameCard_RegistCanPickerAbstract picker = SB_NameCard_RegistCanPickerAbstract.createCandidatePicker(new List<SB_NC_RegistQueryOption> { qo_a, qo_c }, cards.keySet());
    System.assert(picker instanceOf SB_NameCard_RegistSoqlCountCanPicker);
    Map<Id, Map<SObjectType, List<SObject>>> cardId2RecMap = picker.create();
    Test.stopTest();
    
    System.assertEquals(2, cardId2RecMap.size());
    for (Id cardId : cardId2RecMap.keySet()) {
      NameCard__c card = cards.get(cardId);
      System.debug(String.format('NameCard__c: {0}, {1}, {2}', new String[] {card.Name, card.company_name__c, card.division__c }));
      Map<SObjectType, List<SObject>> otype2records = cardId2RecMap.get(cardId);
      // アカウント調査
      System.assertEquals(5, otype2records.get(Account.getSObjectType()).size());  // アカウント数
      for (Account rec : (List<Account>)otype2records.get(Account.getSObjectType())) {
        System.debug(String.format('Account: {0}, {1}', new String[] { rec.Name, rec.Site }));
        System.assert(rec.Name.contains(card.company_name__c.replace('株式会社', '').trim())); // アカウント名
      } 
      // コンタクト調査
      System.assertEquals(5, otype2records.get(Contact.getSObjectType()).size()); // コンタクト数  5アカウントに 1コンタクトづつ
      for (Contact rec : (List<Contact>)otype2records.get(Contact.getSObjectType())) {
        System.debug(String.format('Contact: {0}, {1}, {2}', new String[] { rec.Name, rec.Email, rec.Department }));
        System.assert(rec.Name == card.Name || rec.Email == card.email__c);  // コンタクト名 か メアド は一致
      } 
    }
  }

  /* 部分一致 編 */
  // SOQL検索
  // PartialMatch-1
  // 部分一致
  // 部署照合 オフ
  // 姓名 一致、メアドのみ一致オフ
  @isTest
  static void test_createAccountContact_Soql_PartialMatch_deptOff_emailoff_emailonlyoff() {
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    // 株式会社サンブリッジ テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社サンブリッジ', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    // 株式会社 恵比寿システム テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社 恵比寿システム', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    insert listCard;

    Test.startTest();
    SB_NameCard_Util.smartViscaConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL　に
    SB_NameCard_BasicSetting.getNameCardBasicSetting().HojinkakuEquationLongAndAbbr__c = true; // // v2.4 会社名の法人格は略称・正称を同一視

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.getSObjectType());
    qo_a.bulkRegist = true;
    qo_a.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.PartialMatch;  // 部分一致
    qo_a.queryDept = false;  // 部署照合 オフ
    qo_a.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_a.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ ← 一括では常にオフ コンタクトのクエリで出すから
    SB_NC_RegistQueryOption qo_c = new SB_NC_RegistQueryOption(Contact.getSObjectType());
    qo_c.bulkRegist = true;
    qo_c.queryCompany = false;  // コンタクトの会社名照合 オフ
    qo_c.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.PartialMatch;  // 部分一致
    qo_c.queryDept = false;  // 部署照合 オフ
    qo_c.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_c.queryEMail = false;  // メアドは条件 オフ
    qo_c.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ
    qo_c.queryNameOrEMail = false; // 姓名 or メールアドレス いずれか一致でOK オフ

    Map<Id, NameCard__c> cards = new Map<Id, NameCard__c> ([SELECT Id, Name, company_name__c, division__c, email__c FROM NameCard__c LIMIT 10]);

    // SOSL 検索結果 を セット
    // Map<Id, Account> acnts = new Map<Id, Account>([SELECT Id, Name FROM Account]);
    // Test.setFixedSearchResults(new List<Id>(acnts.keySet()));

    // 名刺-登録先候補s 取得
    SB_NameCard_RegistCanPickerAbstract picker = SB_NameCard_RegistCanPickerAbstract.createCandidatePicker(new List<SB_NC_RegistQueryOption> { qo_a, qo_c }, cards.keySet());
    System.assert(picker instanceOf SB_NameCard_RegistSoqlCountCanPicker);
    Map<Id, Map<SObjectType, List<SObject>>> cardId2RecMap = picker.create();
    Test.stopTest();
    
    System.assertEquals(2, cardId2RecMap.size());
    for (Id cardId : cardId2RecMap.keySet()) {
      NameCard__c card = cards.get(cardId);
      System.debug(String.format('NameCard__c: {0}, {1}, {2}', new String[] {card.Name, card.company_name__c, card.division__c }));
      Map<SObjectType, List<SObject>> otype2records = cardId2RecMap.get(cardId);
      // アカウント調査
      System.assertEquals(7, otype2records.get(Account.getSObjectType()).size());  // アカウント数
      for (Account rec : (List<Account>)otype2records.get(Account.getSObjectType())) {
        System.debug(String.format('Account: {0}, {1}', new String[] { rec.Name, rec.Site }));
        System.assert(rec.Name.contains(card.company_name__c.replace('株式会社', '').trim())); // アカウント名
      } 
      // コンタクト調査
      System.assertEquals(28, otype2records.get(Contact.getSObjectType()).size()); // コンタクト数
      for (Contact rec : (List<Contact>)otype2records.get(Contact.getSObjectType())) {
        System.debug(String.format('Contact: {0}, {1}, {2}', new String[] { rec.Name, rec.Email, rec.Department }));
        System.assert(rec.Name == card.Name || rec.Email == card.email__c);  // コンタクト名 か メアド は一致
      } 
    }
  }

  // SOQL検索
  // PartialMatch-2
  // 部分一致
  // 部署照合 オフ
  // 姓名メアド 一致、メアドのみ一致オフ
  @isTest
  static void test_createAccountContact_Soql_PartialMatch_deptOff_emailon_emailonlyoff() {
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    // 株式会社サンブリッジ テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社サンブリッジ', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    // 株式会社 恵比寿システム テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社 恵比寿システム', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    insert listCard;

    Test.startTest();
    SB_NameCard_Util.smartViscaConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL　に
    SB_NameCard_BasicSetting.getNameCardBasicSetting().HojinkakuEquationLongAndAbbr__c = true; // // v2.4 会社名の法人格は略称・正称を同一視

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.getSObjectType());
    qo_a.bulkRegist = true;
    qo_a.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.PartialMatch;  // 部分一致
    qo_a.queryDept = false;  // 部署照合 オフ
    qo_a.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_a.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ ← 一括では常にオフ コンタクトのクエリで出すから
    SB_NC_RegistQueryOption qo_c = new SB_NC_RegistQueryOption(Contact.getSObjectType());
    qo_c.bulkRegist = true;
    qo_c.queryCompany = false;  // コンタクトの会社名照合 オフ
    qo_c.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.PartialMatch;  // 部分一致
    qo_c.queryDept = false;  // 部署照合 オフ
    qo_c.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_c.queryEMail = true;  // メアドは条件 オン
    qo_c.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ
    qo_c.queryNameOrEMail = false; // 姓名 or メールアドレス いずれか一致でOK オフ

    Map<Id, NameCard__c> cards = new Map<Id, NameCard__c> ([SELECT Id, Name, company_name__c, division__c, email__c FROM NameCard__c LIMIT 10]);

    // SOSL 検索結果 を セット
    // Map<Id, Account> acnts = new Map<Id, Account>([SELECT Id, Name FROM Account]);
    // Test.setFixedSearchResults(new List<Id>(acnts.keySet()));

    // 名刺-登録先候補s 取得
    SB_NameCard_RegistCanPickerAbstract picker = SB_NameCard_RegistCanPickerAbstract.createCandidatePicker(new List<SB_NC_RegistQueryOption> { qo_a, qo_c }, cards.keySet());
    System.assert(picker instanceOf SB_NameCard_RegistSoqlCountCanPicker);
    Map<Id, Map<SObjectType, List<SObject>>> cardId2RecMap = picker.create();
    Test.stopTest();
    
    System.assertEquals(2, cardId2RecMap.size());
    for (Id cardId : cardId2RecMap.keySet()) {
      NameCard__c card = cards.get(cardId);
      System.debug(String.format('NameCard__c: {0}, {1}, {2}', new String[] {card.Name, card.company_name__c, card.division__c }));
      Map<SObjectType, List<SObject>> otype2records = cardId2RecMap.get(cardId);
      // アカウント調査
      System.assertEquals(7, otype2records.get(Account.getSObjectType()).size());  // アカウント数
      for (Account rec : (List<Account>)otype2records.get(Account.getSObjectType())) {
        System.debug(String.format('Account: {0}, {1}', new String[] { rec.Name, rec.Site }));
        System.assert(rec.Name.contains(card.company_name__c.replace('株式会社', '').trim())); // アカウント名
      } 
      // コンタクト調査
      System.assertEquals(14, otype2records.get(Contact.getSObjectType()).size()); // コンタクト数
      for (Contact rec : (List<Contact>)otype2records.get(Contact.getSObjectType())) {
        System.debug(String.format('Contact: {0}, {1}, {2}', new String[] { rec.Name, rec.Email, rec.Department }));
        System.assert(rec.Name == card.Name || rec.Email == card.email__c);  // コンタクト名 か メアド は一致
      } 
    }
  }

  // SOQL検索
  // PartialMatch-3
  // 部分一致
  // 部署照合 オフ
  // 姓名メアド 一致、メアドのみ一致オン
  @isTest
  static void test_createAccountContact_Soql_PartialMatch_deptOff_emailon_emailonlyon() {
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    // 株式会社サンブリッジ テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社サンブリッジ', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    // 株式会社 恵比寿システム テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社 恵比寿システム', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    insert listCard;

    Test.startTest();
    SB_NameCard_Util.smartViscaConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL　に
    SB_NameCard_BasicSetting.getNameCardBasicSetting().HojinkakuEquationLongAndAbbr__c = true; // // v2.4 会社名の法人格は略称・正称を同一視

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.getSObjectType());
    qo_a.bulkRegist = true;
    qo_a.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.PartialMatch;  // 部分一致
    qo_a.queryDept = false;  // 部署照合 オフ
    qo_a.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_a.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ ← 一括では常にオフ コンタクトのクエリで出すから
    SB_NC_RegistQueryOption qo_c = new SB_NC_RegistQueryOption(Contact.getSObjectType());
    qo_c.bulkRegist = true;
    qo_c.queryCompany = false;  // コンタクトの会社名照合 オフ
    qo_c.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.PartialMatch;  // 部分一致
    qo_c.queryDept = false;  // 部署照合 オフ
    qo_c.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_c.queryEMail = true;  // メアドは条件 オン
    qo_c.queryOnlyEMail = true;  // コンタクトはメアドのみ一致で該当 オン
    qo_c.queryNameOrEMail = false; // 姓名 or メールアドレス いずれか一致でOK オフ

    Map<Id, NameCard__c> cards = new Map<Id, NameCard__c> ([SELECT Id, Name, company_name__c, division__c, email__c FROM NameCard__c LIMIT 10]);

    // SOSL 検索結果 を セット
    // Map<Id, Account> acnts = new Map<Id, Account>([SELECT Id, Name FROM Account]);
    // Test.setFixedSearchResults(new List<Id>(acnts.keySet()));

    // 名刺-登録先候補s 取得
    SB_NameCard_RegistCanPickerAbstract picker = SB_NameCard_RegistCanPickerAbstract.createCandidatePicker(new List<SB_NC_RegistQueryOption> { qo_a, qo_c }, cards.keySet());
    System.assert(picker instanceOf SB_NameCard_RegistSoqlCountCanPicker);
    Map<Id, Map<SObjectType, List<SObject>>> cardId2RecMap = picker.create();
    Test.stopTest();
    
    System.assertEquals(2, cardId2RecMap.size());
    for (Id cardId : cardId2RecMap.keySet()) {
      NameCard__c card = cards.get(cardId);
      System.debug(String.format('NameCard__c: {0}, {1}, {2}', new String[] {card.Name, card.company_name__c, card.division__c }));
      Map<SObjectType, List<SObject>> otype2records = cardId2RecMap.get(cardId);
      // アカウント調査
      System.assertEquals(7, otype2records.get(Account.getSObjectType()).size());  // アカウント数
      for (Account rec : (List<Account>)otype2records.get(Account.getSObjectType())) {
        System.debug(String.format('Account: {0}, {1}', new String[] { rec.Name, rec.Site }));
        System.assert(rec.Name.contains(card.company_name__c.replace('株式会社', '').trim())); // アカウント名
      } 
      // コンタクト調査
      System.assertEquals(16, otype2records.get(Contact.getSObjectType()).size()); // コンタクト数  メアドのみ一致各 1
      for (Contact rec : (List<Contact>)otype2records.get(Contact.getSObjectType())) {
        System.debug(String.format('Contact: {0}, {1}, {2}', new String[] { rec.Name, rec.Email, rec.Department }));
        System.assert(rec.Name == card.Name || rec.Email == card.email__c);  // コンタクト名 か メアド は一致
      } 
    }
  }

  // SOQL検索
  // PartialMatch-4
  // 部分一致
  // 部署照合 オン
  // 姓名メアド 一致、メアドのみ一致オン
  @isTest
  static void test_createAccountContact_Soql_PartialMatch_depton_emailon_emailonlyon() {
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    // 株式会社サンブリッジ テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社サンブリッジ', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    // 株式会社 恵比寿システム テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社 恵比寿システム', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    insert listCard;

    Test.startTest();
    SB_NameCard_Util.smartViscaConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL　に
    SB_NameCard_BasicSetting.getNameCardBasicSetting().HojinkakuEquationLongAndAbbr__c = true; // // v2.4 会社名の法人格は略称・正称を同一視

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.getSObjectType());
    qo_a.bulkRegist = true;
    qo_a.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.PartialMatch;  // 部分一致
    qo_a.queryDept = true;  // 部署照合 オン
    qo_a.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_a.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ ← 一括では常にオフ コンタクトのクエリで出すから
    SB_NC_RegistQueryOption qo_c = new SB_NC_RegistQueryOption(Contact.getSObjectType());
    qo_c.bulkRegist = true;
    qo_c.queryCompany = false;  // コンタクトの会社名照合 オフ
    qo_c.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.PartialMatch;  // 部分一致
    qo_c.queryDept = false;  // 部署照合 オフ
    qo_c.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_c.queryEMail = true;  // メアドは条件 オン
    qo_c.queryOnlyEMail = true;  // コンタクトはメアドのみ一致で該当 オン
    qo_c.queryNameOrEMail = false; // 姓名 or メールアドレス いずれか一致でOK オフ

    Map<Id, NameCard__c> cards = new Map<Id, NameCard__c> ([SELECT Id, Name, company_name__c, division__c, email__c FROM NameCard__c LIMIT 10]);

    // SOSL 検索結果 を セット
    // Map<Id, Account> acnts = new Map<Id, Account>([SELECT Id, Name FROM Account]);
    // Test.setFixedSearchResults(new List<Id>(acnts.keySet()));

    // 名刺-登録先候補s 取得
    SB_NameCard_RegistCanPickerAbstract picker = SB_NameCard_RegistCanPickerAbstract.createCandidatePicker(new List<SB_NC_RegistQueryOption> { qo_a, qo_c }, cards.keySet());
    System.assert(picker instanceOf SB_NameCard_RegistSoqlCountCanPicker);
    Map<Id, Map<SObjectType, List<SObject>>> cardId2RecMap = picker.create();
    Test.stopTest();
    
    System.assertEquals(2, cardId2RecMap.size());
    for (Id cardId : cardId2RecMap.keySet()) {
      NameCard__c card = cards.get(cardId);
      System.debug(String.format('NameCard__c: {0}, {1}, {2}', new String[] {card.Name, card.company_name__c, card.division__c }));
      Map<SObjectType, List<SObject>> otype2records = cardId2RecMap.get(cardId);
      // アカウント調査
      System.assertEquals(0, otype2records.get(Account.getSObjectType()).size());  // アカウント数 0
      for (Account rec : (List<Account>)otype2records.get(Account.getSObjectType())) {
        System.debug(String.format('Account: {0}, {1}', new String[] { rec.Name, rec.Site }));
        System.assert(rec.Name.contains(card.company_name__c.replace('株式会社', '').trim())); // アカウント名
      } 
      // コンタクト調査
      System.assertEquals(16, otype2records.get(Contact.getSObjectType()).size()); // コンタクト数  メアドのみ一致各 1
      for (Contact rec : (List<Contact>)otype2records.get(Contact.getSObjectType())) {
        System.debug(String.format('Contact: {0}, {1}, {2}', new String[] { rec.Name, rec.Email, rec.Department }));
        System.assert(rec.Name == card.Name || rec.Email == card.email__c);  // コンタクト名 か メアド は一致
      } 
    }
  }

  // SOQL検索
  // PartialMatch-5  
  // 部分一致
  // 部署照合 オン
  // 姓名メアド 一致、メアドのみ一致オン
  @isTest
  static void test_createAccountContact_Soql_PartialMatch_deptonMatch_emailon_emailonlyon() {
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    // 株式会社サンブリッジ テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社サンブリッジ', division__c='静岡',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    // 株式会社 恵比寿システム テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社 恵比寿システム', division__c='静岡',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    insert listCard;

    Test.startTest();
    SB_NameCard_Util.smartViscaConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL　に
    SB_NameCard_BasicSetting.getNameCardBasicSetting().HojinkakuEquationLongAndAbbr__c = true; // // v2.4 会社名の法人格は略称・正称を同一視

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.getSObjectType());
    qo_a.bulkRegist = true;
    qo_a.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.PartialMatch;  // 部分一致
    qo_a.queryDept = true;  // 部署照合 オン
    qo_a.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_a.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ ← 一括では常にオフ コンタクトのクエリで出すから
    SB_NC_RegistQueryOption qo_c = new SB_NC_RegistQueryOption(Contact.getSObjectType());
    qo_c.bulkRegist = true;
    qo_c.queryCompany = false;  // コンタクトの会社名照合 オフ
    qo_c.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.PartialMatch;  // 部分一致
    qo_c.queryDept = false;  // 部署照合 オフ
    qo_c.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_c.queryEMail = true;  // メアドは条件 オン
    qo_c.queryOnlyEMail = true;  // コンタクトはメアドのみ一致で該当 オン
    qo_c.queryNameOrEMail = false; // 姓名 or メールアドレス いずれか一致でOK オフ

    Map<Id, NameCard__c> cards = new Map<Id, NameCard__c> ([SELECT Id, Name, company_name__c, division__c, email__c FROM NameCard__c LIMIT 10]);

    // SOSL 検索結果 を セット
    // Map<Id, Account> acnts = new Map<Id, Account>([SELECT Id, Name FROM Account]);
    // Test.setFixedSearchResults(new List<Id>(acnts.keySet()));

    // 名刺-登録先候補s 取得
    SB_NameCard_RegistCanPickerAbstract picker = SB_NameCard_RegistCanPickerAbstract.createCandidatePicker(new List<SB_NC_RegistQueryOption> { qo_a, qo_c }, cards.keySet());
    System.assert(picker instanceOf SB_NameCard_RegistSoqlCountCanPicker);
    Map<Id, Map<SObjectType, List<SObject>>> cardId2RecMap = picker.create();
    Test.stopTest();
    
    System.assertEquals(2, cardId2RecMap.size());
    for (Id cardId : cardId2RecMap.keySet()) {
      NameCard__c card = cards.get(cardId);
      System.debug(String.format('NameCard__c: {0}, {1}, {2}', new String[] {card.Name, card.company_name__c, card.division__c }));
      Map<SObjectType, List<SObject>> otype2records = cardId2RecMap.get(cardId);
      // アカウント調査
      System.assertEquals(7, otype2records.get(Account.getSObjectType()).size());  // アカウント数 0
      for (Account rec : (List<Account>)otype2records.get(Account.getSObjectType())) {
        System.debug(String.format('Account: {0}, {1}', new String[] { rec.Name, rec.Site }));
        System.assert(rec.Name.contains(card.company_name__c.replace('株式会社', '').trim())); // アカウント名
      } 
      // コンタクト調査
      System.assertEquals(16, otype2records.get(Contact.getSObjectType()).size()); // コンタクト数  メアドのみ一致各 1
      for (Contact rec : (List<Contact>)otype2records.get(Contact.getSObjectType())) {
        System.debug(String.format('Contact: {0}, {1}, {2}', new String[] { rec.Name, rec.Email, rec.Department }));
        System.assert(rec.Name == card.Name || rec.Email == card.email__c);  // コンタクト名 か メアド は一致
      } 
    }
  }

  // SOQL検索
  // PartialMatch-6
  // 部分一致
  // 部署照合 オフ
  // 姓名メアド 一致、メアドのみ一致オフ
  // コンタクトの会社名照合 オン
  @isTest
  static void test_createAccountContact_Soql_PartialMatch_deptOff_emailon_emailonlyoff_contactCompanyOn() {
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    // 株式会社サンブリッジ テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社サンブリッジ', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    // 株式会社 恵比寿システム テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社 恵比寿システム', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    insert listCard;

    Test.startTest();
    SB_NameCard_Util.smartViscaConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL　に
    SB_NameCard_BasicSetting.getNameCardBasicSetting().HojinkakuEquationLongAndAbbr__c = true; // // v2.4 会社名の法人格は略称・正称を同一視

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.getSObjectType());
    qo_a.bulkRegist = true;
    qo_a.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.PartialMatch;  // 部分一致
    qo_a.queryDept = false;  // 部署照合 オフ
    qo_a.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_a.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ ← 一括では常にオフ コンタクトのクエリで出すから
    SB_NC_RegistQueryOption qo_c = new SB_NC_RegistQueryOption(Contact.getSObjectType());
    qo_c.bulkRegist = true;
    qo_c.queryCompany = true;  // コンタクトの会社名照合 オン
    qo_c.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.PartialMatch;  // 部分一致
    qo_c.queryDept = false;  // 部署照合 オフ
    qo_c.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_c.queryEMail = true;  // メアドは条件 オン
    qo_c.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ
    qo_c.queryNameOrEMail = false; // 姓名 or メールアドレス いずれか一致でOK オフ

    Map<Id, NameCard__c> cards = new Map<Id, NameCard__c> ([SELECT Id, Name, company_name__c, division__c, email__c FROM NameCard__c LIMIT 10]);

    // SOSL 検索結果 を セット
    // Map<Id, Account> acnts = new Map<Id, Account>([SELECT Id, Name FROM Account]);
    // Test.setFixedSearchResults(new List<Id>(acnts.keySet()));

    // 名刺-登録先候補s 取得
    SB_NameCard_RegistCanPickerAbstract picker = SB_NameCard_RegistCanPickerAbstract.createCandidatePicker(new List<SB_NC_RegistQueryOption> { qo_a, qo_c }, cards.keySet());
    System.assert(picker instanceOf SB_NameCard_RegistSoqlCountCanPicker);
    Map<Id, Map<SObjectType, List<SObject>>> cardId2RecMap = picker.create();
    Test.stopTest();
    
    System.assertEquals(2, cardId2RecMap.size());
    for (Id cardId : cardId2RecMap.keySet()) {
      NameCard__c card = cards.get(cardId);
      System.debug(String.format('NameCard__c: {0}, {1}, {2}', new String[] {card.Name, card.company_name__c, card.division__c }));
      Map<SObjectType, List<SObject>> otype2records = cardId2RecMap.get(cardId);
      // アカウント調査
      System.assertEquals(7, otype2records.get(Account.getSObjectType()).size());  // アカウント数
      for (Account rec : (List<Account>)otype2records.get(Account.getSObjectType())) {
        System.debug(String.format('Account: {0}, {1}', new String[] { rec.Name, rec.Site }));
        System.assert(rec.Name.contains(card.company_name__c.replace('株式会社', '').trim())); // アカウント名
      } 
      // コンタクト調査
       System.assertEquals(7, otype2records.get(Contact.getSObjectType()).size()); // コンタクト数  7アカウントに 1コンタクトづつ
      for (Contact rec : (List<Contact>)otype2records.get(Contact.getSObjectType())) {
        System.debug(String.format('Contact: {0}, {1}, {2}', new String[] { rec.Name, rec.Email, rec.Department }));
        System.assert(rec.Name == card.Name || rec.Email == card.email__c);  // コンタクト名 か メアド は一致
      } 
    }
  }

  /* 完全一致 正略一致 編 */
  // SOQL検索
  // ExactMatch_NoStrict-1
  // 部分一致
  // 部署照合 オフ
  // 姓名 一致、メアドのみ一致オフ
  @isTest
  static void test_createAccountContact_Soql_ExactMatch_nostrict_deptOff_emailoff_emailonlyoff() {
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    // 株式会社サンブリッジ テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社サンブリッジ', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    // 株式会社 恵比寿システム テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社 恵比寿システム', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    insert listCard;

    Test.startTest();
    SB_NameCard_Util.smartViscaConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL　に
    SB_NameCard_BasicSetting.getNameCardBasicSetting().HojinkakuEquationLongAndAbbr__c = true; // // v2.4 会社名の法人格は略称・正称を同一視

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.getSObjectType());
    qo_a.bulkRegist = true;
    qo_a.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.ExactMatch;  // 完全一致
    qo_a.queryDept = false;  // 部署照合 オフ
    qo_a.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_a.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ ← 一括では常にオフ コンタクトのクエリで出すから
    SB_NC_RegistQueryOption qo_c = new SB_NC_RegistQueryOption(Contact.getSObjectType());
    qo_c.bulkRegist = true;
    qo_c.queryCompany = false;  // コンタクトの会社名照合 オフ
    qo_c.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.ExactMatch;  // 完全一致
    qo_c.queryDept = false;  // 部署照合 オフ
    qo_c.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_c.queryEMail = false;  // メアドは条件 オフ
    qo_c.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ
    qo_c.queryNameOrEMail = false; // 姓名 or メールアドレス いずれか一致でOK オフ

    Map<Id, NameCard__c> cards = new Map<Id, NameCard__c> ([SELECT Id, Name, company_name__c, division__c, email__c FROM NameCard__c LIMIT 10]);

    // SOSL 検索結果 を セット
    // Map<Id, Account> acnts = new Map<Id, Account>([SELECT Id, Name FROM Account]);
    // Test.setFixedSearchResults(new List<Id>(acnts.keySet()));

    // 名刺-登録先候補s 取得
    SB_NameCard_RegistCanPickerAbstract picker = SB_NameCard_RegistCanPickerAbstract.createCandidatePicker(new List<SB_NC_RegistQueryOption> { qo_a, qo_c }, cards.keySet());
    System.assert(picker instanceOf SB_NameCard_RegistSoqlCountCanPicker);
    Map<Id, Map<SObjectType, List<SObject>>> cardId2RecMap = picker.create();
    Test.stopTest();
    
    System.assertEquals(2, cardId2RecMap.size());
    for (Id cardId : cardId2RecMap.keySet()) {
      NameCard__c card = cards.get(cardId);
      System.debug(String.format('NameCard__c: {0}, {1}, {2}', new String[] {card.Name, card.company_name__c, card.division__c }));
      Map<SObjectType, List<SObject>> otype2records = cardId2RecMap.get(cardId);
      // アカウント調査
      System.assertEquals(3, otype2records.get(Account.getSObjectType()).size());  // アカウント数
      for (Account rec : (List<Account>)otype2records.get(Account.getSObjectType())) {
        System.debug(String.format('Account: {0}, {1}', new String[] { rec.Name, rec.Site }));
        System.assert(rec.Name.contains(card.company_name__c.replace('株式会社', '').trim())); // アカウント名
      } 
      // コンタクト調査
      System.assertEquals(28, otype2records.get(Contact.getSObjectType()).size()); // コンタクト数
      for (Contact rec : (List<Contact>)otype2records.get(Contact.getSObjectType())) {
        System.debug(String.format('Contact: {0}, {1}, {2}', new String[] { rec.Name, rec.Email, rec.Department }));
        System.assert(rec.Name == card.Name || rec.Email == card.email__c);  // コンタクト名 か メアド は一致
      } 
    }
  }

  // SOQL検索
  // ExactMatch_NoStrict-2
  // 部分一致
  // 部署照合 オフ
  // 姓名メアド 一致、メアドのみ一致オフ
  @isTest
  static void test_createAccountContact_Soql_ExactMatch_nostrict_deptOff_emailon_emailonlyoff() {
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    // 株式会社サンブリッジ テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社サンブリッジ', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    // 株式会社 恵比寿システム テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社 恵比寿システム', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    insert listCard;

    Test.startTest();
    SB_NameCard_Util.smartViscaConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL　に
    SB_NameCard_BasicSetting.getNameCardBasicSetting().HojinkakuEquationLongAndAbbr__c = true; // // v2.4 会社名の法人格は略称・正称を同一視

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.getSObjectType());
    qo_a.bulkRegist = true;
    qo_a.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.ExactMatch;  // 完全一致
    qo_a.queryDept = false;  // 部署照合 オフ
    qo_a.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_a.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ ← 一括では常にオフ コンタクトのクエリで出すから
    SB_NC_RegistQueryOption qo_c = new SB_NC_RegistQueryOption(Contact.getSObjectType());
    qo_c.bulkRegist = true;
    qo_c.queryCompany = false;  // コンタクトの会社名照合 オフ
    qo_c.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.ExactMatch;  // 完全一致
    qo_c.queryDept = false;  // 部署照合 オフ
    qo_c.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_c.queryEMail = true;  // メアドは条件 オン
    qo_c.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ
    qo_c.queryNameOrEMail = false; // 姓名 or メールアドレス いずれか一致でOK オフ

    Map<Id, NameCard__c> cards = new Map<Id, NameCard__c> ([SELECT Id, Name, company_name__c, division__c, email__c FROM NameCard__c LIMIT 10]);

    // SOSL 検索結果 を セット
    // Map<Id, Account> acnts = new Map<Id, Account>([SELECT Id, Name FROM Account]);
    // Test.setFixedSearchResults(new List<Id>(acnts.keySet()));

    // 名刺-登録先候補s 取得
    SB_NameCard_RegistCanPickerAbstract picker = SB_NameCard_RegistCanPickerAbstract.createCandidatePicker(new List<SB_NC_RegistQueryOption> { qo_a, qo_c }, cards.keySet());
    System.assert(picker instanceOf SB_NameCard_RegistSoqlCountCanPicker);
    Map<Id, Map<SObjectType, List<SObject>>> cardId2RecMap = picker.create();
    Test.stopTest();
    
    System.assertEquals(2, cardId2RecMap.size());
    for (Id cardId : cardId2RecMap.keySet()) {
      NameCard__c card = cards.get(cardId);
      System.debug(String.format('NameCard__c: {0}, {1}, {2}', new String[] {card.Name, card.company_name__c, card.division__c }));
      Map<SObjectType, List<SObject>> otype2records = cardId2RecMap.get(cardId);
      // アカウント調査
      System.assertEquals(3, otype2records.get(Account.getSObjectType()).size());  // アカウント数
      for (Account rec : (List<Account>)otype2records.get(Account.getSObjectType())) {
        System.debug(String.format('Account: {0}, {1}', new String[] { rec.Name, rec.Site }));
        System.assert(rec.Name.contains(card.company_name__c.replace('株式会社', '').trim())); // アカウント名
      } 
      // コンタクト調査
      System.assertEquals(14, otype2records.get(Contact.getSObjectType()).size()); // コンタクト数
      for (Contact rec : (List<Contact>)otype2records.get(Contact.getSObjectType())) {
        System.debug(String.format('Contact: {0}, {1}, {2}', new String[] { rec.Name, rec.Email, rec.Department }));
        System.assert(rec.Name == card.Name || rec.Email == card.email__c);  // コンタクト名 か メアド は一致
      } 
    }
  }

  // SOQL検索
  // ExactMatch_NoStrict-3
  // 部分一致
  // 部署照合 オフ
  // 姓名メアド 一致、メアドのみ一致オン
  @isTest
  static void test_createAccountContact_Soql_ExactMatch_nostrict_deptOff_emailon_emailonlyon() {
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    // 株式会社サンブリッジ テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社サンブリッジ', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    // 株式会社 恵比寿システム テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社 恵比寿システム', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    insert listCard;

    Test.startTest();
    SB_NameCard_Util.smartViscaConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL　に
    SB_NameCard_BasicSetting.getNameCardBasicSetting().HojinkakuEquationLongAndAbbr__c = true; // // v2.4 会社名の法人格は略称・正称を同一視

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.getSObjectType());
    qo_a.bulkRegist = true;
    qo_a.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.ExactMatch;  // 完全一致
    qo_a.queryDept = false;  // 部署照合 オフ
    qo_a.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_a.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ ← 一括では常にオフ コンタクトのクエリで出すから
    SB_NC_RegistQueryOption qo_c = new SB_NC_RegistQueryOption(Contact.getSObjectType());
    qo_c.bulkRegist = true;
    qo_c.queryCompany = false;  // コンタクトの会社名照合 オフ
    qo_c.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.ExactMatch;  // 完全一致
    qo_c.queryDept = false;  // 部署照合 オフ
    qo_c.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_c.queryEMail = true;  // メアドは条件 オン
    qo_c.queryOnlyEMail = true;  // コンタクトはメアドのみ一致で該当 オン
    qo_c.queryNameOrEMail = false; // 姓名 or メールアドレス いずれか一致でOK オフ

    Map<Id, NameCard__c> cards = new Map<Id, NameCard__c> ([SELECT Id, Name, company_name__c, division__c, email__c FROM NameCard__c LIMIT 10]);

    // SOSL 検索結果 を セット
    // Map<Id, Account> acnts = new Map<Id, Account>([SELECT Id, Name FROM Account]);
    // Test.setFixedSearchResults(new List<Id>(acnts.keySet()));

    // 名刺-登録先候補s 取得
    SB_NameCard_RegistCanPickerAbstract picker = SB_NameCard_RegistCanPickerAbstract.createCandidatePicker(new List<SB_NC_RegistQueryOption> { qo_a, qo_c }, cards.keySet());
    System.assert(picker instanceOf SB_NameCard_RegistSoqlCountCanPicker);
    Map<Id, Map<SObjectType, List<SObject>>> cardId2RecMap = picker.create();
    Test.stopTest();
    
    System.assertEquals(2, cardId2RecMap.size());
    for (Id cardId : cardId2RecMap.keySet()) {
      NameCard__c card = cards.get(cardId);
      System.debug(String.format('NameCard__c: {0}, {1}, {2}', new String[] {card.Name, card.company_name__c, card.division__c }));
      Map<SObjectType, List<SObject>> otype2records = cardId2RecMap.get(cardId);
      // アカウント調査
      System.assertEquals(3, otype2records.get(Account.getSObjectType()).size());  // アカウント数
      for (Account rec : (List<Account>)otype2records.get(Account.getSObjectType())) {
        System.debug(String.format('Account: {0}, {1}', new String[] { rec.Name, rec.Site }));
        System.assert(rec.Name.contains(card.company_name__c.replace('株式会社', '').trim())); // アカウント名
      } 
      // コンタクト調査
      System.assertEquals(16, otype2records.get(Contact.getSObjectType()).size()); // コンタクト数  メアドのみ一致各 1
      for (Contact rec : (List<Contact>)otype2records.get(Contact.getSObjectType())) {
        System.debug(String.format('Contact: {0}, {1}, {2}', new String[] { rec.Name, rec.Email, rec.Department }));
        System.assert(rec.Name == card.Name || rec.Email == card.email__c);  // コンタクト名 か メアド は一致
      } 
    }
  }

  // SOQL検索
  // ExactMatch_NoStrict-4
  // 部分一致
  // 部署照合 オン
  // 姓名メアド 一致、メアドのみ一致オン
  @isTest
  static void test_createAccountContact_Soql_ExactMatch_nostrict_depton_emailon_emailonlyon() {
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    // 株式会社サンブリッジ テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社サンブリッジ', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    // 株式会社 恵比寿システム テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社 恵比寿システム', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    insert listCard;

    Test.startTest();
    SB_NameCard_Util.smartViscaConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL　に
    SB_NameCard_BasicSetting.getNameCardBasicSetting().HojinkakuEquationLongAndAbbr__c = true; // // v2.4 会社名の法人格は略称・正称を同一視

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.getSObjectType());
    qo_a.bulkRegist = true;
    qo_a.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.ExactMatch;  // 完全一致
    qo_a.queryDept = true;  // 部署照合 オン
    qo_a.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_a.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ ← 一括では常にオフ コンタクトのクエリで出すから
    SB_NC_RegistQueryOption qo_c = new SB_NC_RegistQueryOption(Contact.getSObjectType());
    qo_c.bulkRegist = true;
    qo_c.queryCompany = false;  // コンタクトの会社名照合 オフ
    qo_c.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.ExactMatch;  // 完全一致
    qo_c.queryDept = false;  // 部署照合 オフ
    qo_c.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_c.queryEMail = true;  // メアドは条件 オン
    qo_c.queryOnlyEMail = true;  // コンタクトはメアドのみ一致で該当 オン
    qo_c.queryNameOrEMail = false; // 姓名 or メールアドレス いずれか一致でOK オフ

    Map<Id, NameCard__c> cards = new Map<Id, NameCard__c> ([SELECT Id, Name, company_name__c, division__c, email__c FROM NameCard__c LIMIT 10]);

    // SOSL 検索結果 を セット
    // Map<Id, Account> acnts = new Map<Id, Account>([SELECT Id, Name FROM Account]);
    // Test.setFixedSearchResults(new List<Id>(acnts.keySet()));

    // 名刺-登録先候補s 取得
    SB_NameCard_RegistCanPickerAbstract picker = SB_NameCard_RegistCanPickerAbstract.createCandidatePicker(new List<SB_NC_RegistQueryOption> { qo_a, qo_c }, cards.keySet());
    System.assert(picker instanceOf SB_NameCard_RegistSoqlCountCanPicker);
    Map<Id, Map<SObjectType, List<SObject>>> cardId2RecMap = picker.create();
    Test.stopTest();
    
    System.assertEquals(2, cardId2RecMap.size());
    for (Id cardId : cardId2RecMap.keySet()) {
      NameCard__c card = cards.get(cardId);
      System.debug(String.format('NameCard__c: {0}, {1}, {2}', new String[] {card.Name, card.company_name__c, card.division__c }));
      Map<SObjectType, List<SObject>> otype2records = cardId2RecMap.get(cardId);
      // アカウント調査
      System.assertEquals(0, otype2records.get(Account.getSObjectType()).size());  // アカウント数 0
      for (Account rec : (List<Account>)otype2records.get(Account.getSObjectType())) {
        System.debug(String.format('Account: {0}, {1}', new String[] { rec.Name, rec.Site }));
        System.assert(rec.Name.contains(card.company_name__c.replace('株式会社', '').trim())); // アカウント名
      } 
      // コンタクト調査
      System.assertEquals(16, otype2records.get(Contact.getSObjectType()).size()); // コンタクト数  メアドのみ一致各 1
      for (Contact rec : (List<Contact>)otype2records.get(Contact.getSObjectType())) {
        System.debug(String.format('Contact: {0}, {1}, {2}', new String[] { rec.Name, rec.Email, rec.Department }));
        System.assert(rec.Name == card.Name || rec.Email == card.email__c);  // コンタクト名 か メアド は一致
      } 
    }
  }

  // SOQL検索
  // ExactMatch_NoStrict-5  
  // 部分一致
  // 部署照合 オン
  // 姓名メアド 一致、メアドのみ一致オン
  @isTest
  static void test_createAccountContact_Soql_ExactMatch_nostrict_deptonMatch_emailon_emailonlyon() {
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    // 株式会社サンブリッジ テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社サンブリッジ', division__c='静岡',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    // 株式会社 恵比寿システム テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社 恵比寿システム', division__c='静岡',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    insert listCard;

    Test.startTest();
    SB_NameCard_Util.smartViscaConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL　に
    SB_NameCard_BasicSetting.getNameCardBasicSetting().HojinkakuEquationLongAndAbbr__c = true; // // v2.4 会社名の法人格は略称・正称を同一視

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.getSObjectType());
    qo_a.bulkRegist = true;
    qo_a.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.ExactMatch;  // 完全一致
    qo_a.queryDept = true;  // 部署照合 オン
    qo_a.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_a.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ ← 一括では常にオフ コンタクトのクエリで出すから
    SB_NC_RegistQueryOption qo_c = new SB_NC_RegistQueryOption(Contact.getSObjectType());
    qo_c.bulkRegist = true;
    qo_c.queryCompany = false;  // コンタクトの会社名照合 オフ
    qo_c.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.ExactMatch;  // 完全一致
    qo_c.queryDept = false;  // 部署照合 オフ
    qo_c.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_c.queryEMail = true;  // メアドは条件 オン
    qo_c.queryOnlyEMail = true;  // コンタクトはメアドのみ一致で該当 オン
    qo_c.queryNameOrEMail = false; // 姓名 or メールアドレス いずれか一致でOK オフ

    Map<Id, NameCard__c> cards = new Map<Id, NameCard__c> ([SELECT Id, Name, company_name__c, division__c, email__c FROM NameCard__c LIMIT 10]);

    // SOSL 検索結果 を セット
    // Map<Id, Account> acnts = new Map<Id, Account>([SELECT Id, Name FROM Account]);
    // Test.setFixedSearchResults(new List<Id>(acnts.keySet()));

    // 名刺-登録先候補s 取得
    SB_NameCard_RegistCanPickerAbstract picker = SB_NameCard_RegistCanPickerAbstract.createCandidatePicker(new List<SB_NC_RegistQueryOption> { qo_a, qo_c }, cards.keySet());
    System.assert(picker instanceOf SB_NameCard_RegistSoqlCountCanPicker);
    Map<Id, Map<SObjectType, List<SObject>>> cardId2RecMap = picker.create();
    Test.stopTest();
    
    System.assertEquals(2, cardId2RecMap.size());
    for (Id cardId : cardId2RecMap.keySet()) {
      NameCard__c card = cards.get(cardId);
      System.debug(String.format('NameCard__c: {0}, {1}, {2}', new String[] {card.Name, card.company_name__c, card.division__c }));
      Map<SObjectType, List<SObject>> otype2records = cardId2RecMap.get(cardId);
      // アカウント調査
      System.assertEquals(3, otype2records.get(Account.getSObjectType()).size());  // アカウント数 0
      for (Account rec : (List<Account>)otype2records.get(Account.getSObjectType())) {
        System.debug(String.format('Account: {0}, {1}', new String[] { rec.Name, rec.Site }));
        System.assert(rec.Name.contains(card.company_name__c.replace('株式会社', '').trim())); // アカウント名
      } 
      // コンタクト調査
      System.assertEquals(16, otype2records.get(Contact.getSObjectType()).size()); // コンタクト数  メアドのみ一致各 1
      for (Contact rec : (List<Contact>)otype2records.get(Contact.getSObjectType())) {
        System.debug(String.format('Contact: {0}, {1}, {2}', new String[] { rec.Name, rec.Email, rec.Department }));
        System.assert(rec.Name == card.Name || rec.Email == card.email__c);  // コンタクト名 か メアド は一致
      } 
    }
  }

  // SOQL検索
  // ExactMatch_NoStrict-6
  // 部分一致
  // 部署照合 オフ
  // 姓名メアド 一致、メアドのみ一致オフ
  // コンタクトの会社名照合 オン
  @isTest
  static void test_createAccountContact_Soql_ExactMatch_nostrict_deptOff_emailon_emailonlyoff_contactCompanyOn() {
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    // 株式会社サンブリッジ テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社サンブリッジ', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    // 株式会社 恵比寿システム テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社 恵比寿システム', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    insert listCard;

    Test.startTest();
    SB_NameCard_Util.smartViscaConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL　に
    SB_NameCard_BasicSetting.getNameCardBasicSetting().HojinkakuEquationLongAndAbbr__c = true; // // v2.4 会社名の法人格は略称・正称を同一視

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.getSObjectType());
    qo_a.bulkRegist = true;
    qo_a.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.ExactMatch;  // 完全一致
    qo_a.queryDept = false;  // 部署照合 オフ
    qo_a.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_a.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ ← 一括では常にオフ コンタクトのクエリで出すから
    SB_NC_RegistQueryOption qo_c = new SB_NC_RegistQueryOption(Contact.getSObjectType());
    qo_c.bulkRegist = true;
    qo_c.queryCompany = true;  // コンタクトの会社名照合 オン
    qo_c.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.ExactMatch;  // 完全一致
    qo_c.queryDept = false;  // 部署照合 オフ
    qo_c.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_c.queryEMail = true;  // メアドは条件 オン
    qo_c.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ
    qo_c.queryNameOrEMail = false; // 姓名 or メールアドレス いずれか一致でOK オフ

    Map<Id, NameCard__c> cards = new Map<Id, NameCard__c> ([SELECT Id, Name, company_name__c, division__c, email__c FROM NameCard__c LIMIT 10]);

    // SOSL 検索結果 を セット
    // Map<Id, Account> acnts = new Map<Id, Account>([SELECT Id, Name FROM Account]);
    // Test.setFixedSearchResults(new List<Id>(acnts.keySet()));

    // 名刺-登録先候補s 取得
    SB_NameCard_RegistCanPickerAbstract picker = SB_NameCard_RegistCanPickerAbstract.createCandidatePicker(new List<SB_NC_RegistQueryOption> { qo_a, qo_c }, cards.keySet());
    System.assert(picker instanceOf SB_NameCard_RegistSoqlCountCanPicker);
    Map<Id, Map<SObjectType, List<SObject>>> cardId2RecMap = picker.create();
    Test.stopTest();
    
    System.assertEquals(2, cardId2RecMap.size());
    for (Id cardId : cardId2RecMap.keySet()) {
      NameCard__c card = cards.get(cardId);
      System.debug(String.format('NameCard__c: {0}, {1}, {2}', new String[] {card.Name, card.company_name__c, card.division__c }));
      Map<SObjectType, List<SObject>> otype2records = cardId2RecMap.get(cardId);
      // アカウント調査
      System.assertEquals(3, otype2records.get(Account.getSObjectType()).size());  // アカウント数
      for (Account rec : (List<Account>)otype2records.get(Account.getSObjectType())) {
        System.debug(String.format('Account: {0}, {1}', new String[] { rec.Name, rec.Site }));
        System.assert(rec.Name.contains(card.company_name__c.replace('株式会社', '').trim())); // アカウント名
      } 
      // コンタクト調査
       System.assertEquals(3, otype2records.get(Contact.getSObjectType()).size()); // コンタクト数  7アカウントに 1コンタクトづつ
      for (Contact rec : (List<Contact>)otype2records.get(Contact.getSObjectType())) {
        System.debug(String.format('Contact: {0}, {1}, {2}', new String[] { rec.Name, rec.Email, rec.Department }));
        System.assert(rec.Name == card.Name || rec.Email == card.email__c);  // コンタクト名 か メアド は一致
      } 
    }
  }

  /* 完全一致 正略区別 編 */
  // SOQL検索
  // ExactMatch_Strict-1
  // 部分一致
  // 部署照合 オフ
  // 姓名 一致、メアドのみ一致オフ
  @isTest
  static void test_createAccountContact_Soql_ExactMatch_strict_deptOff_emailoff_emailonlyoff() {
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    // 株式会社サンブリッジ テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社サンブリッジ', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    // 株式会社 恵比寿システム テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社 恵比寿システム', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    insert listCard;

    Test.startTest();
    SB_NameCard_Util.smartViscaConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL　に
    SB_NameCard_BasicSetting.getNameCardBasicSetting().HojinkakuEquationLongAndAbbr__c = false; // // v2.4 会社名の法人格は略称・正称を同一視 しない

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.getSObjectType());
    qo_a.bulkRegist = true;
    qo_a.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.ExactMatch;  // 完全一致
    qo_a.queryDept = false;  // 部署照合 オフ
    qo_a.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_a.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ ← 一括では常にオフ コンタクトのクエリで出すから
    SB_NC_RegistQueryOption qo_c = new SB_NC_RegistQueryOption(Contact.getSObjectType());
    qo_c.bulkRegist = true;
    qo_c.queryCompany = false;  // コンタクトの会社名照合 オフ
    qo_c.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.ExactMatch;  // 完全一致
    qo_c.queryDept = false;  // 部署照合 オフ
    qo_c.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_c.queryEMail = false;  // メアドは条件 オフ
    qo_c.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ
    qo_c.queryNameOrEMail = false; // 姓名 or メールアドレス いずれか一致でOK オフ

    Map<Id, NameCard__c> cards = new Map<Id, NameCard__c> ([SELECT Id, Name, company_name__c, division__c, email__c FROM NameCard__c LIMIT 10]);

    // SOSL 検索結果 を セット
    // Map<Id, Account> acnts = new Map<Id, Account>([SELECT Id, Name FROM Account]);
    // Test.setFixedSearchResults(new List<Id>(acnts.keySet()));

    // 名刺-登録先候補s 取得
    SB_NameCard_RegistCanPickerAbstract picker = SB_NameCard_RegistCanPickerAbstract.createCandidatePicker(new List<SB_NC_RegistQueryOption> { qo_a, qo_c }, cards.keySet());
    System.assert(picker instanceOf SB_NameCard_RegistSoqlCountCanPicker);
    Map<Id, Map<SObjectType, List<SObject>>> cardId2RecMap = picker.create();
    Test.stopTest();
    
    System.assertEquals(2, cardId2RecMap.size());
    for (Id cardId : cardId2RecMap.keySet()) {
      NameCard__c card = cards.get(cardId);
      System.debug(String.format('NameCard__c: {0}, {1}, {2}', new String[] {card.Name, card.company_name__c, card.division__c }));
      Map<SObjectType, List<SObject>> otype2records = cardId2RecMap.get(cardId);
      // アカウント調査
      System.assertEquals(1, otype2records.get(Account.getSObjectType()).size());  // アカウント数
      for (Account rec : (List<Account>)otype2records.get(Account.getSObjectType())) {
        System.debug(String.format('Account: {0}, {1}', new String[] { rec.Name, rec.Site }));
        System.assert(rec.Name.contains(card.company_name__c.replace('株式会社', '').trim())); // アカウント名
      } 
      // コンタクト調査
      System.assertEquals(28, otype2records.get(Contact.getSObjectType()).size()); // コンタクト数
      for (Contact rec : (List<Contact>)otype2records.get(Contact.getSObjectType())) {
        System.debug(String.format('Contact: {0}, {1}, {2}', new String[] { rec.Name, rec.Email, rec.Department }));
        System.assert(rec.Name == card.Name || rec.Email == card.email__c);  // コンタクト名 か メアド は一致
      } 
    }
  }

  // SOQL検索
  // ExactMatch_Strict-2
  // 部分一致
  // 部署照合 オフ
  // 姓名メアド 一致、メアドのみ一致オフ
  @isTest
  static void test_createAccountContact_Soql_ExactMatch_strict_deptOff_emailon_emailonlyoff() {
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    // 株式会社サンブリッジ テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社サンブリッジ', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    // 株式会社 恵比寿システム テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社 恵比寿システム', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    insert listCard;

    Test.startTest();
    SB_NameCard_Util.smartViscaConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL　に
    SB_NameCard_BasicSetting.getNameCardBasicSetting().HojinkakuEquationLongAndAbbr__c = false; // // v2.4 会社名の法人格は略称・正称を同一視 しない

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.getSObjectType());
    qo_a.bulkRegist = true;
    qo_a.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.ExactMatch;  // 完全一致
    qo_a.queryDept = false;  // 部署照合 オフ
    qo_a.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_a.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ ← 一括では常にオフ コンタクトのクエリで出すから
    SB_NC_RegistQueryOption qo_c = new SB_NC_RegistQueryOption(Contact.getSObjectType());
    qo_c.bulkRegist = true;
    qo_c.queryCompany = false;  // コンタクトの会社名照合 オフ
    qo_c.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.ExactMatch;  // 完全一致
    qo_c.queryDept = false;  // 部署照合 オフ
    qo_c.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_c.queryEMail = true;  // メアドは条件 オン
    qo_c.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ
    qo_c.queryNameOrEMail = false; // 姓名 or メールアドレス いずれか一致でOK オフ

    Map<Id, NameCard__c> cards = new Map<Id, NameCard__c> ([SELECT Id, Name, company_name__c, division__c, email__c FROM NameCard__c LIMIT 10]);

    // SOSL 検索結果 を セット
    // Map<Id, Account> acnts = new Map<Id, Account>([SELECT Id, Name FROM Account]);
    // Test.setFixedSearchResults(new List<Id>(acnts.keySet()));

    // 名刺-登録先候補s 取得
    SB_NameCard_RegistCanPickerAbstract picker = SB_NameCard_RegistCanPickerAbstract.createCandidatePicker(new List<SB_NC_RegistQueryOption> { qo_a, qo_c }, cards.keySet());
    System.assert(picker instanceOf SB_NameCard_RegistSoqlCountCanPicker);
    Map<Id, Map<SObjectType, List<SObject>>> cardId2RecMap = picker.create();
    Test.stopTest();
    
    System.assertEquals(2, cardId2RecMap.size());
    for (Id cardId : cardId2RecMap.keySet()) {
      NameCard__c card = cards.get(cardId);
      System.debug(String.format('NameCard__c: {0}, {1}, {2}', new String[] {card.Name, card.company_name__c, card.division__c }));
      Map<SObjectType, List<SObject>> otype2records = cardId2RecMap.get(cardId);
      // アカウント調査
      System.assertEquals(1, otype2records.get(Account.getSObjectType()).size());  // アカウント数
      for (Account rec : (List<Account>)otype2records.get(Account.getSObjectType())) {
        System.debug(String.format('Account: {0}, {1}', new String[] { rec.Name, rec.Site }));
        System.assert(rec.Name.contains(card.company_name__c.replace('株式会社', '').trim())); // アカウント名
      } 
      // コンタクト調査
      System.assertEquals(14, otype2records.get(Contact.getSObjectType()).size()); // コンタクト数
      for (Contact rec : (List<Contact>)otype2records.get(Contact.getSObjectType())) {
        System.debug(String.format('Contact: {0}, {1}, {2}', new String[] { rec.Name, rec.Email, rec.Department }));
        System.assert(rec.Name == card.Name || rec.Email == card.email__c);  // コンタクト名 か メアド は一致
      } 
    }
  }

  // SOQL検索
  // ExactMatch_Strict-3
  // 部分一致
  // 部署照合 オフ
  // 姓名メアド 一致、メアドのみ一致オン
  @isTest
  static void test_createAccountContact_Soql_ExactMatch_strict_deptOff_emailon_emailonlyon() {
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    // 株式会社サンブリッジ テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社サンブリッジ', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    // 株式会社 恵比寿システム テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社 恵比寿システム', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    insert listCard;

    Test.startTest();
    SB_NameCard_Util.smartViscaConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL　に
    SB_NameCard_BasicSetting.getNameCardBasicSetting().HojinkakuEquationLongAndAbbr__c = false; // // v2.4 会社名の法人格は略称・正称を同一視 しない

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.getSObjectType());
    qo_a.bulkRegist = true;
    qo_a.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.ExactMatch;  // 完全一致
    qo_a.queryDept = false;  // 部署照合 オフ
    qo_a.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_a.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ ← 一括では常にオフ コンタクトのクエリで出すから
    SB_NC_RegistQueryOption qo_c = new SB_NC_RegistQueryOption(Contact.getSObjectType());
    qo_c.bulkRegist = true;
    qo_c.queryCompany = false;  // コンタクトの会社名照合 オフ
    qo_c.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.ExactMatch;  // 完全一致
    qo_c.queryDept = false;  // 部署照合 オフ
    qo_c.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_c.queryEMail = true;  // メアドは条件 オン
    qo_c.queryOnlyEMail = true;  // コンタクトはメアドのみ一致で該当 オン
    qo_c.queryNameOrEMail = false; // 姓名 or メールアドレス いずれか一致でOK オフ

    Map<Id, NameCard__c> cards = new Map<Id, NameCard__c> ([SELECT Id, Name, company_name__c, division__c, email__c FROM NameCard__c LIMIT 10]);

    // SOSL 検索結果 を セット
    // Map<Id, Account> acnts = new Map<Id, Account>([SELECT Id, Name FROM Account]);
    // Test.setFixedSearchResults(new List<Id>(acnts.keySet()));

    // 名刺-登録先候補s 取得
    SB_NameCard_RegistCanPickerAbstract picker = SB_NameCard_RegistCanPickerAbstract.createCandidatePicker(new List<SB_NC_RegistQueryOption> { qo_a, qo_c }, cards.keySet());
    System.assert(picker instanceOf SB_NameCard_RegistSoqlCountCanPicker);
    Map<Id, Map<SObjectType, List<SObject>>> cardId2RecMap = picker.create();
    Test.stopTest();
    
    System.assertEquals(2, cardId2RecMap.size());
    for (Id cardId : cardId2RecMap.keySet()) {
      NameCard__c card = cards.get(cardId);
      System.debug(String.format('NameCard__c: {0}, {1}, {2}', new String[] {card.Name, card.company_name__c, card.division__c }));
      Map<SObjectType, List<SObject>> otype2records = cardId2RecMap.get(cardId);
      // アカウント調査
      System.assertEquals(1, otype2records.get(Account.getSObjectType()).size());  // アカウント数
      for (Account rec : (List<Account>)otype2records.get(Account.getSObjectType())) {
        System.debug(String.format('Account: {0}, {1}', new String[] { rec.Name, rec.Site }));
        System.assert(rec.Name.contains(card.company_name__c.replace('株式会社', '').trim())); // アカウント名
      } 
      // コンタクト調査
      System.assertEquals(16, otype2records.get(Contact.getSObjectType()).size()); // コンタクト数  メアドのみ一致各 1
      for (Contact rec : (List<Contact>)otype2records.get(Contact.getSObjectType())) {
        System.debug(String.format('Contact: {0}, {1}, {2}', new String[] { rec.Name, rec.Email, rec.Department }));
        System.assert(rec.Name == card.Name || rec.Email == card.email__c);  // コンタクト名 か メアド は一致
      } 
    }
  }

  // SOQL検索
  // ExactMatch_Strict-4
  // 部分一致
  // 部署照合 オン
  // 姓名メアド 一致、メアドのみ一致オン
  @isTest
  static void test_createAccountContact_Soql_ExactMatch_strict_depton_emailon_emailonlyon() {
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    // 株式会社サンブリッジ テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社サンブリッジ', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    // 株式会社 恵比寿システム テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社 恵比寿システム', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    insert listCard;

    Test.startTest();
    SB_NameCard_Util.smartViscaConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL　に
    SB_NameCard_BasicSetting.getNameCardBasicSetting().HojinkakuEquationLongAndAbbr__c = false; // // v2.4 会社名の法人格は略称・正称を同一視 しない

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.getSObjectType());
    qo_a.bulkRegist = true;
    qo_a.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.ExactMatch;  // 完全一致
    qo_a.queryDept = true;  // 部署照合 オン
    qo_a.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_a.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ ← 一括では常にオフ コンタクトのクエリで出すから
    SB_NC_RegistQueryOption qo_c = new SB_NC_RegistQueryOption(Contact.getSObjectType());
    qo_c.bulkRegist = true;
    qo_c.queryCompany = false;  // コンタクトの会社名照合 オフ
    qo_c.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.ExactMatch;  // 完全一致
    qo_c.queryDept = false;  // 部署照合 オフ
    qo_c.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_c.queryEMail = true;  // メアドは条件 オン
    qo_c.queryOnlyEMail = true;  // コンタクトはメアドのみ一致で該当 オン
    qo_c.queryNameOrEMail = false; // 姓名 or メールアドレス いずれか一致でOK オフ

    Map<Id, NameCard__c> cards = new Map<Id, NameCard__c> ([SELECT Id, Name, company_name__c, division__c, email__c FROM NameCard__c LIMIT 10]);

    // SOSL 検索結果 を セット
    // Map<Id, Account> acnts = new Map<Id, Account>([SELECT Id, Name FROM Account]);
    // Test.setFixedSearchResults(new List<Id>(acnts.keySet()));

    // 名刺-登録先候補s 取得
    SB_NameCard_RegistCanPickerAbstract picker = SB_NameCard_RegistCanPickerAbstract.createCandidatePicker(new List<SB_NC_RegistQueryOption> { qo_a, qo_c }, cards.keySet());
    System.assert(picker instanceOf SB_NameCard_RegistSoqlCountCanPicker);
    Map<Id, Map<SObjectType, List<SObject>>> cardId2RecMap = picker.create();
    Test.stopTest();
    
    System.assertEquals(2, cardId2RecMap.size());
    for (Id cardId : cardId2RecMap.keySet()) {
      NameCard__c card = cards.get(cardId);
      System.debug(String.format('NameCard__c: {0}, {1}, {2}', new String[] {card.Name, card.company_name__c, card.division__c }));
      Map<SObjectType, List<SObject>> otype2records = cardId2RecMap.get(cardId);
      // アカウント調査
      System.assertEquals(0, otype2records.get(Account.getSObjectType()).size());  // アカウント数 0
      for (Account rec : (List<Account>)otype2records.get(Account.getSObjectType())) {
        System.debug(String.format('Account: {0}, {1}', new String[] { rec.Name, rec.Site }));
        System.assert(rec.Name.contains(card.company_name__c.replace('株式会社', '').trim())); // アカウント名
      } 
      // コンタクト調査
      System.assertEquals(16, otype2records.get(Contact.getSObjectType()).size()); // コンタクト数  メアドのみ一致各 1
      for (Contact rec : (List<Contact>)otype2records.get(Contact.getSObjectType())) {
        System.debug(String.format('Contact: {0}, {1}, {2}', new String[] { rec.Name, rec.Email, rec.Department }));
        System.assert(rec.Name == card.Name || rec.Email == card.email__c);  // コンタクト名 か メアド は一致
      } 
    }
  }

  // SOQL検索
  // ExactMatch_Strict-5  
  // 部分一致
  // 部署照合 オン
  // 姓名メアド 一致、メアドのみ一致オン
  @isTest
  static void test_createAccountContact_Soql_ExactMatch_strict_deptonMatch_emailon_emailonlyon() {
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    // 株式会社サンブリッジ テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社サンブリッジ', division__c='静岡',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    // 株式会社 恵比寿システム テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社 恵比寿システム', division__c='静岡',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    insert listCard;

    Test.startTest();
    SB_NameCard_Util.smartViscaConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL　に
    SB_NameCard_BasicSetting.getNameCardBasicSetting().HojinkakuEquationLongAndAbbr__c = false; // // v2.4 会社名の法人格は略称・正称を同一視 しない

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.getSObjectType());
    qo_a.bulkRegist = true;
    qo_a.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.ExactMatch;  // 完全一致
    qo_a.queryDept = true;  // 部署照合 オン
    qo_a.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_a.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ ← 一括では常にオフ コンタクトのクエリで出すから
    SB_NC_RegistQueryOption qo_c = new SB_NC_RegistQueryOption(Contact.getSObjectType());
    qo_c.bulkRegist = true;
    qo_c.queryCompany = false;  // コンタクトの会社名照合 オフ
    qo_c.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.ExactMatch;  // 完全一致
    qo_c.queryDept = false;  // 部署照合 オフ
    qo_c.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_c.queryEMail = true;  // メアドは条件 オン
    qo_c.queryOnlyEMail = true;  // コンタクトはメアドのみ一致で該当 オン
    qo_c.queryNameOrEMail = false; // 姓名 or メールアドレス いずれか一致でOK オフ

    Map<Id, NameCard__c> cards = new Map<Id, NameCard__c> ([SELECT Id, Name, company_name__c, division__c, email__c FROM NameCard__c LIMIT 10]);

    // SOSL 検索結果 を セット
    // Map<Id, Account> acnts = new Map<Id, Account>([SELECT Id, Name FROM Account]);
    // Test.setFixedSearchResults(new List<Id>(acnts.keySet()));

    // 名刺-登録先候補s 取得
    SB_NameCard_RegistCanPickerAbstract picker = SB_NameCard_RegistCanPickerAbstract.createCandidatePicker(new List<SB_NC_RegistQueryOption> { qo_a, qo_c }, cards.keySet());
    System.assert(picker instanceOf SB_NameCard_RegistSoqlCountCanPicker);
    Map<Id, Map<SObjectType, List<SObject>>> cardId2RecMap = picker.create();
    Test.stopTest();
    
    System.assertEquals(2, cardId2RecMap.size());
    for (Id cardId : cardId2RecMap.keySet()) {
      NameCard__c card = cards.get(cardId);
      System.debug(String.format('NameCard__c: {0}, {1}, {2}', new String[] {card.Name, card.company_name__c, card.division__c }));
      Map<SObjectType, List<SObject>> otype2records = cardId2RecMap.get(cardId);
      // アカウント調査
      System.assertEquals(0, otype2records.get(Account.getSObjectType()).size());  // アカウント数 0 コンタクトが独立して一致するのはないなので
      for (Account rec : (List<Account>)otype2records.get(Account.getSObjectType())) {
        System.debug(String.format('Account: {0}, {1}', new String[] { rec.Name, rec.Site }));
        System.assert(rec.Name.contains(card.company_name__c.replace('株式会社', '').trim())); // アカウント名
      } 
      // コンタクト調査
      System.assertEquals(16, otype2records.get(Contact.getSObjectType()).size()); // コンタクト数  メアドのみ一致各 1
      for (Contact rec : (List<Contact>)otype2records.get(Contact.getSObjectType())) {
        System.debug(String.format('Contact: {0}, {1}, {2}', new String[] { rec.Name, rec.Email, rec.Department }));
        System.assert(rec.Name == card.Name || rec.Email == card.email__c);  // コンタクト名 か メアド は一致
      } 
    }
  }

  // SOQL検索
  // ExactMatch_Strict-6
  // 部分一致
  // 部署照合 オフ
  // 姓名メアド 一致、メアドのみ一致オフ
  // コンタクトの会社名照合 オン
  @isTest
  static void test_createAccountContact_Soql_ExactMatch_strict_deptOff_emailon_emailonlyoff_contactCompanyOn() {
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    // 株式会社サンブリッジ テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社サンブリッジ', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    // 株式会社 恵比寿システム テスト 太郎 taro@test.com
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社 恵比寿システム', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    insert listCard;

    Test.startTest();
    SB_NameCard_Util.smartViscaConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL　に
    SB_NameCard_BasicSetting.getNameCardBasicSetting().HojinkakuEquationLongAndAbbr__c = false; // // v2.4 会社名の法人格は略称・正称を同一視 しない

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.getSObjectType());
    qo_a.bulkRegist = true;
    qo_a.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.ExactMatch;  // 完全一致
    qo_a.queryDept = false;  // 部署照合 オフ
    qo_a.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_a.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ ← 一括では常にオフ コンタクトのクエリで出すから
    SB_NC_RegistQueryOption qo_c = new SB_NC_RegistQueryOption(Contact.getSObjectType());
    qo_c.bulkRegist = true;
    qo_c.queryCompany = true;  // コンタクトの会社名照合 オン
    qo_c.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.ExactMatch;  // 完全一致
    qo_c.queryDept = false;  // 部署照合 オフ
    qo_c.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_c.queryEMail = true;  // メアドは条件 オン
    qo_c.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ
    qo_c.queryNameOrEMail = false; // 姓名 or メールアドレス いずれか一致でOK オフ

    Map<Id, NameCard__c> cards = new Map<Id, NameCard__c> ([SELECT Id, Name, company_name__c, division__c, email__c FROM NameCard__c LIMIT 10]);

    // SOSL 検索結果 を セット
    // Map<Id, Account> acnts = new Map<Id, Account>([SELECT Id, Name FROM Account]);
    // Test.setFixedSearchResults(new List<Id>(acnts.keySet()));

    // 名刺-登録先候補s 取得
    SB_NameCard_RegistCanPickerAbstract picker = SB_NameCard_RegistCanPickerAbstract.createCandidatePicker(new List<SB_NC_RegistQueryOption> { qo_a, qo_c }, cards.keySet());
    System.assert(picker instanceOf SB_NameCard_RegistSoqlCountCanPicker);
    Map<Id, Map<SObjectType, List<SObject>>> cardId2RecMap = picker.create();
    Test.stopTest();
    
    System.assertEquals(2, cardId2RecMap.size());
    for (Id cardId : cardId2RecMap.keySet()) {
      NameCard__c card = cards.get(cardId);
      System.debug(String.format('NameCard__c: {0}, {1}, {2}', new String[] {card.Name, card.company_name__c, card.division__c }));
      Map<SObjectType, List<SObject>> otype2records = cardId2RecMap.get(cardId);
      // アカウント調査
      System.assertEquals(1, otype2records.get(Account.getSObjectType()).size());  // アカウント数
      for (Account rec : (List<Account>)otype2records.get(Account.getSObjectType())) {
        System.debug(String.format('Account: {0}, {1}', new String[] { rec.Name, rec.Site }));
        System.assert(rec.Name.contains(card.company_name__c.replace('株式会社', '').trim())); // アカウント名
      } 
      // コンタクト調査
       System.assertEquals(1, otype2records.get(Contact.getSObjectType()).size()); // コンタクト数  7アカウントに 1コンタクトづつ
      for (Contact rec : (List<Contact>)otype2records.get(Contact.getSObjectType())) {
        System.debug(String.format('Contact: {0}, {1}, {2}', new String[] { rec.Name, rec.Email, rec.Department }));
        System.assert(rec.Name == card.Name || rec.Email == card.email__c);  // コンタクト名 か メアド は一致
      } 
    }
  }

}