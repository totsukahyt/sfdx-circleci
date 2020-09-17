/**
 *
 * SB_NC_RegistOptionCreaterTest2
 *  SB_NC_RegistOptionCreater のテストクラス SOSL検索編 個別 アカウント 
 * 
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1  2019.06.xx v2.4
 *
 **/
@isTest
private class SB_NC_RegistOptionCreaterTest2 {

  private class TestDb extends SB_NC_TestDB {
    // 名刺基本設定 デフォルト
    public override void initializeBasicSetting() {
      NameCardBasicSetting__c bs = SB_NC_PostInstallScript.createDefaultBasicSetting();
      listBasicSetting.add(bs);
    }
    // SmartVisca設定　デフォルト
    public virtual override void initializeSmartViscaConfig() {
      svConfig = SmartViscaConfig__c.getOrgDefaults();
    }

    public override void initialize() {
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
    acnts.add(new Account(Name='株式会社サンブリッジ', Site='静岡支社', AccountNumber='0')); // 社名一致、部分一致、完全一致略称同一視、完全一致略称区別
    acnts.add(new Account(Name='株式会社 サンブリッジ', Site='静岡支社', AccountNumber='1')); // 社名一致、部分一致、完全一致略称同一視
    acnts.add(new Account(Name='(株) サンブリッジ', Site='静岡支社', AccountNumber='2'));     // 社名一致、部分一致、完全一致略称同一視
    acnts.add(new Account(Name='サンブリッジ (株)', Site='静岡支社', AccountNumber='3'));     // 社名一致、部分一致
    acnts.add(new Account(Name='有限会社 サンブリッジ', Site='静岡支社', AccountNumber='4'));     // 社名一致、部分一致
    acnts.add(new Account(Name='(株) サンブリッジ商事', Site='静岡支社', AccountNumber='5')); // 部分一致
    acnts.add(new Account(Name='サンブリッジ海運 (株)', Site='静岡支社', AccountNumber='6')); // 部分一致
    insert acnts;

    List<Contact> conts = new List<Contact>();
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@0.com', AccountId=acnts[0].Id));
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@test.com', AccountId=acnts[0].Id));    // メアドが名刺と一緒
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@1.com', AccountId=acnts[1].Id));
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@test.com', AccountId=acnts[1].Id));    // メアドが名刺と一緒
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@2.com', AccountId=acnts[2].Id));
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@test.com', AccountId=acnts[2].Id));    // メアドが名刺と一緒
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@3.com', AccountId=acnts[3].Id));
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@test.com', AccountId=acnts[3].Id));    // メアドが名刺と一緒
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@4.com', AccountId=acnts[4].Id));
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@test.com', AccountId=acnts[4].Id));    // メアドが名刺と一緒
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@5.com', AccountId=acnts[5].Id));
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@test.com', AccountId=acnts[5].Id));    // メアドが名刺と一緒
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@6.com', AccountId=acnts[6].Id));
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@test.com', AccountId=acnts[6].Id));    // メアドが名刺と一緒
    insert conts;

  }

  /** SOSL 編 **/
  // SOSL検索
  // 会社名一致
  @isTest
  static void test_getAccountOptions_Sosl_CorpMatch_deptOff_emailoff() {
    // カスタム設定は 名刺トリガが動く前にセット    
    SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    svConfig.AccountRegistSearchMethod__c = 1; // 取引先・取引先任者に登録(個別) 登録先候補の検索方法 SOSL　に
    // svConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL　に
    upsert svConfig;
    SB_NameCard_BasicSetting.getNameCardBasicSetting().HojinkakuEquationLongAndAbbr__c = true; // // v2.4 会社名の法人格は略称・正称を同一視


    Test.startTest();
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社サンブリッジ', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    insert listCard;

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.getSObjectType());
    qo_a.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.CorpMatch;  // 社名一致
    qo_a.queryDept = false;  // 部署照合 オフ
    qo_a.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_a.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ

    List<NameCard__c> cards = [SELECT Id, Name, company_name__c, division__c FROM NameCard__c LIMIT 10];

    System.assertEquals(SB_NameCard_Util.smartViscaConfig.AccountRegistSearchMethod__c, svConfig.AccountRegistSearchMethod__c);
    // SOSL 検索結果 を セット
    Map<Id, Account> acnts = new Map<Id, Account>([SELECT Id, Name FROM Account]);
    Test.setFixedSearchResults(new List<Id>(acnts.keySet()));
    List<SB_NC_RegistOptionCreater.RegistOption> reg_opts = SB_NC_RegistOptionCreater.getAccountOptions(cards[0].Id, qo_a);
    Test.stopTest();

    System.assertEquals(5+2, reg_opts.size());
    for (SB_NC_RegistOptionCreater.RegistOption reg_opt : reg_opts) {
      System.debug(reg_opt.title);
    }
  }

  // SOSL検索
  // 会社名一致
  @isTest
  static void test_getAccountOptions_Sosl_CorpMatch_depton_emailoff() {
    // カスタム設定は 名刺トリガが動く前にセット    
    SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    svConfig.AccountRegistSearchMethod__c = 1; // 取引先・取引先任者に登録(個別) 登録先候補の検索方法 SOSL　に
    // svConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL　に
    upsert svConfig;
    SB_NameCard_BasicSetting.getNameCardBasicSetting().HojinkakuEquationLongAndAbbr__c = true; // // v2.4 会社名の法人格は略称・正称を同一視

    Test.startTest();
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社サンブリッジ', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    insert listCard;

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.getSObjectType());
    qo_a.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.CorpMatch;  // 社名一致
    qo_a.queryDept = true;  // 部署照合 オン
    qo_a.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_a.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ

    List<NameCard__c> cards = [SELECT Id, Name, company_name__c, division__c FROM NameCard__c LIMIT 10];

    System.assertEquals(SB_NameCard_Util.smartViscaConfig.AccountRegistSearchMethod__c, svConfig.AccountRegistSearchMethod__c);
    // SOSL 検索結果 を セット
    Map<Id, Account> acnts = new Map<Id, Account>([SELECT Id, Name FROM Account]);
    Test.setFixedSearchResults(new List<Id>(acnts.keySet()));
    List<SB_NC_RegistOptionCreater.RegistOption> reg_opts = SB_NC_RegistOptionCreater.getAccountOptions(cards[0].Id, qo_a);
    Test.stopTest();

    System.assertEquals(2, reg_opts.size());  // 部署名が違うので該当アカウントはなしになる。
    for (SB_NC_RegistOptionCreater.RegistOption reg_opt : reg_opts) {
      System.debug(reg_opt.title);
    }
  }

  // SOSL検索
  // 会社名一致
  @isTest
  static void test_getAccountOptions_Sosl_CorpMatch_depton_emailon() {
    // カスタム設定は 名刺トリガが動く前にセット    
    SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    svConfig.AccountRegistSearchMethod__c = 1; // 取引先・取引先任者に登録(個別) 登録先候補の検索方法 SOSL　に
    // svConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL　に
    upsert svConfig;
    SB_NameCard_BasicSetting.getNameCardBasicSetting().HojinkakuEquationLongAndAbbr__c = true; // // v2.4 会社名の法人格は略称・正称を同一視

    Test.startTest();
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社サンブリッジ', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    insert listCard;

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.getSObjectType());
    qo_a.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.CorpMatch;  // 社名一致
    qo_a.queryDept = true;  // 部署照合 オン
    qo_a.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_a.queryOnlyEMail = true;  // コンタクトはメアドのみ一致で該当 オン

    List<NameCard__c> cards = [SELECT Id, Name, company_name__c, division__c FROM NameCard__c LIMIT 10];

    System.assertEquals(SB_NameCard_Util.smartViscaConfig.AccountRegistSearchMethod__c, svConfig.AccountRegistSearchMethod__c);
    // SOSL 検索結果 を セット
    Map<Id, Account> acnts = new Map<Id, Account>([SELECT Id, Name FROM Account]);
    Test.setFixedSearchResults(new List<Id>(acnts.keySet()));
    List<SB_NC_RegistOptionCreater.RegistOption> reg_opts = SB_NC_RegistOptionCreater.getAccountOptions(cards[0].Id, qo_a);
    Test.stopTest();

    System.assertEquals(7+2, reg_opts.size());  // 部署名が違うけど、メアド一致のコンタクト7個の親アカウント7個全部
    for (SB_NC_RegistOptionCreater.RegistOption reg_opt : reg_opts) {
      System.debug(reg_opt.title);
    }
  }

  // SOSL検索
  // 部分一致
  @isTest
  static void test_getAccountOptions_Sosl_PartialMatch_deptOff_emailoff() {
    // カスタム設定は 名刺トリガが動く前にセット    
    SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    svConfig.AccountRegistSearchMethod__c = 1; // 取引先・取引先任者に登録(個別) 登録先候補の検索方法 SOSL　に
    // svConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL　に
    upsert svConfig;
    SB_NameCard_BasicSetting.getNameCardBasicSetting().HojinkakuEquationLongAndAbbr__c = true; // // v2.4 会社名の法人格は略称・正称を同一視

    Test.startTest();
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社サンブリッジ', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    insert listCard;

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.getSObjectType());
    qo_a.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.PartialMatch;  // 部分一致
    qo_a.queryDept = false;  // 部署照合 オフ
    qo_a.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_a.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ

    List<NameCard__c> cards = [SELECT Id, Name, company_name__c, division__c FROM NameCard__c LIMIT 10];

    System.assertEquals(SB_NameCard_Util.smartViscaConfig.AccountRegistSearchMethod__c, svConfig.AccountRegistSearchMethod__c);
    // SOSL 検索結果 を セット
    Map<Id, Account> acnts = new Map<Id, Account>([SELECT Id, Name FROM Account]);
    Test.setFixedSearchResults(new List<Id>(acnts.keySet()));
    List<SB_NC_RegistOptionCreater.RegistOption> reg_opts = SB_NC_RegistOptionCreater.getAccountOptions(cards[0].Id, qo_a);
    Test.stopTest();

    System.assertEquals(7+2, reg_opts.size()); // 部分一致だと7個全部
    for (SB_NC_RegistOptionCreater.RegistOption reg_opt : reg_opts) {
      System.debug(reg_opt.title);
    }
  }

  // SOSL検索
  // 部分一致 
  @isTest
  static void test_getAccountOptions_Sosl_PartialMatch_deptOn_emailoff() {
    // カスタム設定は 名刺トリガが動く前にセット    
    SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    svConfig.AccountRegistSearchMethod__c = 1; // 取引先・取引先任者に登録(個別) 登録先候補の検索方法 SOSL　に
    // svConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL　に
    upsert svConfig;
    SB_NameCard_BasicSetting.getNameCardBasicSetting().HojinkakuEquationLongAndAbbr__c = true; // // v2.4 会社名の法人格は略称・正称を同一視

    Test.startTest();
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社サンブリッジ', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    insert listCard;

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.getSObjectType());
    qo_a.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.PartialMatch;  // 部分一致
    qo_a.queryDept = true;  // 部署照合 オン
    qo_a.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_a.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ

    List<NameCard__c> cards = [SELECT Id, Name, company_name__c, division__c FROM NameCard__c LIMIT 10];

    System.assertEquals(SB_NameCard_Util.smartViscaConfig.AccountRegistSearchMethod__c, svConfig.AccountRegistSearchMethod__c);
    // SOSL 検索結果 を セット
    Map<Id, Account> acnts = new Map<Id, Account>([SELECT Id, Name FROM Account]);
    Test.setFixedSearchResults(new List<Id>(acnts.keySet()));
    List<SB_NC_RegistOptionCreater.RegistOption> reg_opts = SB_NC_RegistOptionCreater.getAccountOptions(cards[0].Id, qo_a);
    Test.stopTest();

    System.assertEquals(2, reg_opts.size()); // 社名は部分一致するけど、部署がちがうので、該当レコードはなし
    for (SB_NC_RegistOptionCreater.RegistOption reg_opt : reg_opts) {
      System.debug(reg_opt.title);
    }
  }

  // SOSL検索
  // 部分一致 
  @isTest
  static void test_getAccountOptions_Sosl_PartialMatch_deptOn_emailon() {
    // カスタム設定は 名刺トリガが動く前にセット    
    SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    svConfig.AccountRegistSearchMethod__c = 1; // 取引先・取引先任者に登録(個別) 登録先候補の検索方法 SOSL　に
    // svConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL　に
    upsert svConfig;
    SB_NameCard_BasicSetting.getNameCardBasicSetting().HojinkakuEquationLongAndAbbr__c = true; // // v2.4 会社名の法人格は略称・正称を同一視

    Test.startTest();
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社サンブリッジ', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    insert listCard;

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.getSObjectType());
    qo_a.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.PartialMatch;  // 部分一致
    qo_a.queryDept = true;  // 部署照合 オン
    qo_a.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_a.queryOnlyEMail = true;  // コンタクトはメアドのみ一致で該当 オン

    List<NameCard__c> cards = [SELECT Id, Name, company_name__c, division__c FROM NameCard__c LIMIT 10];

    System.assertEquals(SB_NameCard_Util.smartViscaConfig.AccountRegistSearchMethod__c, svConfig.AccountRegistSearchMethod__c);
    // SOSL 検索結果 を セット
    Map<Id, Account> acnts = new Map<Id, Account>([SELECT Id, Name FROM Account]);
    Test.setFixedSearchResults(new List<Id>(acnts.keySet()));
    List<SB_NC_RegistOptionCreater.RegistOption> reg_opts = SB_NC_RegistOptionCreater.getAccountOptions(cards[0].Id, qo_a);
    Test.stopTest();

    System.assertEquals(7+2, reg_opts.size()); // 社名は部分一致するけど、部署がちがうので、該当レコードはなしになど、メアド一致のコンタクト7個の親アカウント7個全部
    for (SB_NC_RegistOptionCreater.RegistOption reg_opt : reg_opts) {
      System.debug(reg_opt.title);
    }
  }

  // SOSL検索
  // 完全一致 
  // 法人格 正称・略称 同一視
  @isTest
  static void test_getAccountOptions_Sosl_ExactMatch_nostrict_deptOff_emailoff() {
    // カスタム設定は 名刺トリガが動く前にセット    
    SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    svConfig.AccountRegistSearchMethod__c = 1; // 取引先・取引先任者に登録(個別) 登録先候補の検索方法 SOSL　に
    // svConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL　に
    upsert svConfig;
    SB_NameCard_BasicSetting.getNameCardBasicSetting().HojinkakuEquationLongAndAbbr__c = true; // // v2.4 会社名の法人格は略称・正称を同一視

    Test.startTest();
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社サンブリッジ', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    insert listCard;

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.getSObjectType());
    qo_a.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.ExactMatch;  // 完全一致 
    qo_a.queryDept = false;  // 部署照合 オフ
    qo_a.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_a.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ

    List<NameCard__c> cards = [SELECT Id, Name, company_name__c, division__c FROM NameCard__c LIMIT 10];

    System.assertEquals(SB_NameCard_Util.smartViscaConfig.AccountRegistSearchMethod__c, svConfig.AccountRegistSearchMethod__c);
    // SOSL 検索結果 を セット
    Map<Id, Account> acnts = new Map<Id, Account>([SELECT Id, Name FROM Account]);
    Test.setFixedSearchResults(new List<Id>(acnts.keySet()));
    List<SB_NC_RegistOptionCreater.RegistOption> reg_opts = SB_NC_RegistOptionCreater.getAccountOptions(cards[0].Id, qo_a);
    Test.stopTest();

    System.assertEquals(3+2, reg_opts.size()); // 法人格（法人格 正称・略称 同一視）＋社名が一致は3件
    for (SB_NC_RegistOptionCreater.RegistOption reg_opt : reg_opts) {
      System.debug(reg_opt.title);
    }
  }

  // SOSL検索
  // 完全一致 
  // 法人格 正称・略称 同一視
  @isTest
  static void test_getAccountOptions_Sosl_ExactMatch_nostrict_depton_emailoff() {
    // カスタム設定は 名刺トリガが動く前にセット    
    SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    svConfig.AccountRegistSearchMethod__c = 1; // 取引先・取引先任者に登録(個別) 登録先候補の検索方法 SOSL　に
    // svConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL　に
    upsert svConfig;
    SB_NameCard_BasicSetting.getNameCardBasicSetting().HojinkakuEquationLongAndAbbr__c = true; // // v2.4 会社名の法人格は略称・正称を同一視

    Test.startTest();
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社サンブリッジ', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    insert listCard;

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.getSObjectType());
    qo_a.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.ExactMatch;  // 完全一致 
    qo_a.queryDept = true;  // 部署照合 オン
    qo_a.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_a.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ

    List<NameCard__c> cards = [SELECT Id, Name, company_name__c, division__c FROM NameCard__c LIMIT 10];

    System.assertEquals(SB_NameCard_Util.smartViscaConfig.AccountRegistSearchMethod__c, svConfig.AccountRegistSearchMethod__c);
    // SOSL 検索結果 を セット
    Map<Id, Account> acnts = new Map<Id, Account>([SELECT Id, Name FROM Account]);
    Test.setFixedSearchResults(new List<Id>(acnts.keySet()));
    List<SB_NC_RegistOptionCreater.RegistOption> reg_opts = SB_NC_RegistOptionCreater.getAccountOptions(cards[0].Id, qo_a);
    Test.stopTest();

    System.assertEquals(2, reg_opts.size()); // 法人格（法人格 正称・略称 同一視）＋社名が一致は3件だけど、部署名が違うので 0
    for (SB_NC_RegistOptionCreater.RegistOption reg_opt : reg_opts) {
      System.debug(reg_opt.title);
    }
  }

  // SOSL検索
  // 完全一致 
  // 法人格 正称・略称 同一視
  @isTest
  static void test_getAccountOptions_Sosl_ExactMatch_nostrict_deptonMatch_emailoff() {
    // カスタム設定は 名刺トリガが動く前にセット    
    SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    svConfig.AccountRegistSearchMethod__c = 1; // 取引先・取引先任者に登録(個別) 登録先候補の検索方法 SOSL　に
    // svConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL　に
    upsert svConfig;
    SB_NameCard_BasicSetting.getNameCardBasicSetting().HojinkakuEquationLongAndAbbr__c = true; // // v2.4 会社名の法人格は略称・正称を同一視

    Test.startTest();
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社サンブリッジ', division__c='静岡支社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    insert listCard;

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.getSObjectType());
    qo_a.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.ExactMatch;  // 完全一致 
    qo_a.queryDept = true;  // 部署照合 オン
    qo_a.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_a.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ

    List<NameCard__c> cards = [SELECT Id, Name, company_name__c, division__c FROM NameCard__c LIMIT 10];

    System.assertEquals(SB_NameCard_Util.smartViscaConfig.AccountRegistSearchMethod__c, svConfig.AccountRegistSearchMethod__c);
    // SOSL 検索結果 を セット
    Map<Id, Account> acnts = new Map<Id, Account>([SELECT Id, Name FROM Account]);
    Test.setFixedSearchResults(new List<Id>(acnts.keySet()));
    List<SB_NC_RegistOptionCreater.RegistOption> reg_opts = SB_NC_RegistOptionCreater.getAccountOptions(cards[0].Id, qo_a);
    Test.stopTest();

    System.assertEquals(3+2, reg_opts.size()); // 法人格（法人格 正称・略称 同一視）＋社名が一致は3件で、部署名も一致
    for (SB_NC_RegistOptionCreater.RegistOption reg_opt : reg_opts) {
      System.debug(reg_opt.title);
    }
  }

  // SOSL検索
  // 完全一致 
  // 法人格 正称・略称 区別
  @isTest
  static void test_getAccountOptions_Sosl_ExactMatch_strict_deptOff_emailoff() {
    // // カスタム設定は 名刺トリガが動く前にセット    
    // SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    // svConfig.AccountRegistSearchMethod__c = 1; // 取引先・取引先任者に登録(個別) 登録先候補の検索方法 SOSL　に
    // // svConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL　に
    // upsert svConfig;

    Test.startTest();
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社サンブリッジ', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    insert listCard;

    SB_NameCard_Util.smartViscaConfig.AccountRegistSearchMethod__c = 1;
    SB_NameCard_BasicSetting.getNameCardBasicSetting().HojinkakuEquationLongAndAbbr__c = false; // // v2.4 会社名の法人格は略称・正称を同一視 しない

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.getSObjectType());
    qo_a.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.ExactMatch;  // 完全一致 
    qo_a.queryDept = false;  // 部署照合 オフ
    qo_a.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_a.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ

    List<NameCard__c> cards = [SELECT Id, Name, company_name__c, division__c FROM NameCard__c LIMIT 10];

    // System.assertEquals(SB_NameCard_Util.smartViscaConfig.AccountRegistSearchMethod__c, svConfig.AccountRegistSearchMethod__c);
    // SOSL 検索結果 を セット
    Map<Id, Account> acnts = new Map<Id, Account>([SELECT Id, Name FROM Account]);
    Test.setFixedSearchResults(new List<Id>(acnts.keySet()));
    List<SB_NC_RegistOptionCreater.RegistOption> reg_opts = SB_NC_RegistOptionCreater.getAccountOptions(cards[0].Id, qo_a);
    Test.stopTest();

    System.assertEquals(1+2, reg_opts.size()); // 法人格（法人格 正称・略称 区別）＋社名が一致は1件
    for (SB_NC_RegistOptionCreater.RegistOption reg_opt : reg_opts) {
      System.debug(reg_opt.title);
    }
  }

  // SOSL検索
  // 完全一致 
  // 法人格 正称・略称 区別
  @isTest
  static void test_getAccountOptions_Sosl_ExactMatch_strict_deptOff_emailon() {
    // カスタム設定は 名刺トリガが動く前にセット    
    SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    svConfig.AccountRegistSearchMethod__c = 1; // 取引先・取引先任者に登録(個別) 登録先候補の検索方法 SOSL　に
    // svConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL　に
    upsert svConfig;
    SB_NameCard_BasicSetting.getNameCardBasicSetting().HojinkakuEquationLongAndAbbr__c = false; // // v2.4 会社名の法人格は略称・正称を同一視

    Test.startTest();
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社サンブリッジ', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    insert listCard;

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.getSObjectType());
    qo_a.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.ExactMatch;  // 完全一致 
    qo_a.queryDept = false;  // 部署照合 オフ
    qo_a.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_a.queryOnlyEMail = true;  // コンタクトはメアドのみ一致で該当 オフ

    List<NameCard__c> cards = [SELECT Id, Name, company_name__c, division__c FROM NameCard__c LIMIT 10];

    System.assertEquals(SB_NameCard_Util.smartViscaConfig.AccountRegistSearchMethod__c, svConfig.AccountRegistSearchMethod__c);
    // SOSL 検索結果 を セット
    Map<Id, Account> acnts = new Map<Id, Account>([SELECT Id, Name FROM Account]);
    Test.setFixedSearchResults(new List<Id>(acnts.keySet()));
    List<SB_NC_RegistOptionCreater.RegistOption> reg_opts = SB_NC_RegistOptionCreater.getAccountOptions(cards[0].Id, qo_a);
    Test.stopTest();

    System.assertEquals(7+2, reg_opts.size()); // 法人格（法人格 正称・略称 区別）＋社名が一致は1件 だけど、メアドの一致したコンタクトの親アカウントが 7
    for (SB_NC_RegistOptionCreater.RegistOption reg_opt : reg_opts) {
      System.debug(reg_opt.title);
    }
  }  

}