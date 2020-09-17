/**
 *
 * SB_NC_RegistOptionCreaterTest5
 *  SB_NC_RegistOptionCreater のテストクラス SOQL検索編 個別 コンタクト 
 * 
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1  2019.06.xx v2.4
 *
 **/
@isTest
private class SB_NC_RegistOptionCreaterTest5 {

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
    // 株式会社サンブリッジ 
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@0.com', Department='営業部', AccountId=acnts[0].Id));       // 姓名が名刺と一緒
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@test.com', Department='営業部', AccountId=acnts[0].Id));    // 姓名メアドが名刺と一緒
    conts.add(new Contact(LastName='検証', FirstName='太郎', EMail='taro@test.com', Department='営業部', AccountId=acnts[0].Id));    // メアドが名刺と一緒
    conts.add(new Contact(LastName='テスト', FirstName='一郎', EMail='ichiro@0.com', Department='営業部', AccountId=acnts[0].Id));  // 姓名メアド 一致しない
    conts.add(new Contact(LastName='テスト', FirstName='一郎', EMail='ichiro@test.com', Department='営業部', AccountId=acnts[0].Id));   // 姓名メアド 一致しない

    // (株) サンブリッジ海運
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@0.com', Department='営業部', AccountId=acnts[6].Id));       // 姓名が名刺と一緒
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@test.com', Department='営業部', AccountId=acnts[6].Id));    // 姓名メアドが名刺と一緒
    conts.add(new Contact(LastName='検証', FirstName='太郎', EMail='taro@test.com', Department='営業部', AccountId=acnts[6].Id));    // メアドが名刺と一緒
    conts.add(new Contact(LastName='テスト', FirstName='一郎', EMail='ichiro@0.com', Department='営業部', AccountId=acnts[6].Id));  // 姓名メアド 一致しない
    conts.add(new Contact(LastName='テスト', FirstName='一郎', EMail='ichiro@test.com', Department='営業部', AccountId=acnts[6].Id));   // 姓名メアド 一致しない
    insert conts;

  }

  // SOQL検索
  // 部署条件オフ、メアド条件オフ、メアドのみ条件オン
  @isTest
  static void test_getContactOptions_Soql_deptOff_emailoff_emailonlyon() {
    // カスタム設定は 名刺トリガが動く前にセット    
    SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    svConfig.AccountRegistSearchMethod__c = 1; // 取引先・取引先任者に登録(個別) 登録先候補の検索方法 SOQL　に
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

    Account acnt = [SELECT Id, Name FROM Account WHERE Name='株式会社サンブリッジ' LIMIT 1];
    SB_NC_RegistQueryOption qo_c = new SB_NC_RegistQueryOption(Contact.getSObjectType());
    // qo_c.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.CorpMatch;  // 社名一致
    qo_c.addParentId(acnt.Id); // アカウントの指定
    qo_c.queryDept = false;  // 部署照合 オフ
    qo_c.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_c.queryEMail = false;  // メアドは条件 オン
    qo_c.queryOnlyEMail = true;  // コンタクトはメアドのみ一致で該当 オフ

    List<NameCard__c> cards = [SELECT Id, Name, company_name__c, division__c FROM NameCard__c LIMIT 10];

    System.assertEquals(SB_NameCard_Util.smartViscaConfig.AccountRegistSearchMethod__c, svConfig.AccountRegistSearchMethod__c);
    // 登録先候補取得
    List<SB_NC_RegistOptionCreater.RegistOption> reg_opts = SB_NC_RegistOptionCreater.getContactOptions(cards[0].Id, qo_c);
    Test.stopTest();

    System.assertEquals(3+2, reg_opts.size());  // 姓名一致は2件+メアド一致は１件
    for (SB_NC_RegistOptionCreater.RegistOption reg_opt : reg_opts) {
      System.debug(reg_opt.title);
    }
  }

  // SOQL検索
  // 部署条件オフ、メアド条件オン、メアドのみ条件オン
  @isTest
  static void test_getContactOptions_Soql_deptOff_emailon_emailonlyon() {
    // カスタム設定は 名刺トリガが動く前にセット    
    SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    svConfig.AccountRegistSearchMethod__c = 1; // 取引先・取引先任者に登録(個別) 登録先候補の検索方法 SOQL　に
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

    Account acnt = [SELECT Id, Name FROM Account WHERE Name='株式会社サンブリッジ' LIMIT 1];
    SB_NC_RegistQueryOption qo_c = new SB_NC_RegistQueryOption(Contact.getSObjectType());
    // qo_c.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.CorpMatch;  // 社名一致
    qo_c.addParentId(acnt.Id); // アカウントの指定
    qo_c.queryDept = false;  // 部署照合 オフ
    qo_c.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_c.queryEMail = true;  // メアドは条件 オン
    qo_c.queryOnlyEMail = true;  // コンタクトはメアドのみ一致で該当 オフ
    qo_c.queryNameOrEMail = false; // 

    List<NameCard__c> cards = [SELECT Id, Name, company_name__c, division__c FROM NameCard__c LIMIT 10];

    System.assertEquals(SB_NameCard_Util.smartViscaConfig.AccountRegistSearchMethod__c, svConfig.AccountRegistSearchMethod__c);
    // 登録先候補取得
    List<SB_NC_RegistOptionCreater.RegistOption> reg_opts = SB_NC_RegistOptionCreater.getContactOptions(cards[0].Id, qo_c);
    Test.stopTest();

    System.assertEquals(2+2, reg_opts.size());  // 姓名一致は2件+メアド一致は１件
    for (SB_NC_RegistOptionCreater.RegistOption reg_opt : reg_opts) {
      System.debug(reg_opt.title);
    }
  }

  /** SOQL 編 **/
  // SOQL検索
  // 部署条件オフ、メアド条件オン、メアドのみ条件オフ
  @isTest
  static void test_getContactOptions_Soql_deptOff_emailon_emailonlyoff() {
    // カスタム設定は 名刺トリガが動く前にセット    
    SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    svConfig.AccountRegistSearchMethod__c = 1; // 取引先・取引先任者に登録(個別) 登録先候補の検索方法 SOQL　に
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

    Account acnt = [SELECT Id, Name FROM Account WHERE Name='株式会社サンブリッジ' LIMIT 1];
    SB_NC_RegistQueryOption qo_c = new SB_NC_RegistQueryOption(Contact.getSObjectType());
    // qo_c.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.CorpMatch;  // 社名一致
    qo_c.addParentId(acnt.Id); // アカウントの指定
    qo_c.queryDept = false;  // 部署照合 オフ
    qo_c.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_c.queryEMail = true;  // メアドは条件 オン
    qo_c.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ
    qo_c.queryNameOrEMail = false; // 

    List<NameCard__c> cards = [SELECT Id, Name, company_name__c, division__c FROM NameCard__c LIMIT 10];

    System.assertEquals(SB_NameCard_Util.smartViscaConfig.AccountRegistSearchMethod__c, svConfig.AccountRegistSearchMethod__c);
    // 登録先候補取得
    List<SB_NC_RegistOptionCreater.RegistOption> reg_opts = SB_NC_RegistOptionCreater.getContactOptions(cards[0].Id, qo_c);
    Test.stopTest();

    System.assertEquals(1+2, reg_opts.size());  // 姓名一致は2件
    for (SB_NC_RegistOptionCreater.RegistOption reg_opt : reg_opts) {
      System.debug(reg_opt.title);
    }

  }

  // SOQL検索
  // 部署条件オン、メアド条件オフ、メアドのみ条件オフ
  @isTest
  static void test_getContactOptions_Soql_deptOn_0_emailoff_emailonlyoff() {
    // カスタム設定は 名刺トリガが動く前にセット    
    SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    svConfig.AccountRegistSearchMethod__c = 1; // 取引先・取引先任者に登録(個別) 登録先候補の検索方法 SOQL　に
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

    Account acnt = [SELECT Id, Name FROM Account WHERE Name='株式会社サンブリッジ' LIMIT 1];
    SB_NC_RegistQueryOption qo_c = new SB_NC_RegistQueryOption(Contact.getSObjectType());
    // qo_c.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.CorpMatch;  // 社名一致
    qo_c.addParentId(acnt.Id); // アカウントの指定
    qo_c.queryDept = true;  // 部署照合 オン
    qo_c.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_c.queryEMail = false;  // メアドは条件 オフ
    qo_c.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ

    List<NameCard__c> cards = [SELECT Id, Name, company_name__c, division__c FROM NameCard__c LIMIT 10];

    System.assertEquals(SB_NameCard_Util.smartViscaConfig.AccountRegistSearchMethod__c, svConfig.AccountRegistSearchMethod__c);
    // 登録先候補取得
    List<SB_NC_RegistOptionCreater.RegistOption> reg_opts = SB_NC_RegistOptionCreater.getContactOptions(cards[0].Id, qo_c);
    Test.stopTest();

    System.assertEquals(2, reg_opts.size());  // 部署が一致しないので、 0
    for (SB_NC_RegistOptionCreater.RegistOption reg_opt : reg_opts) {
      System.debug(reg_opt.title);
    }
  }

  // SOQL検索
  // 部署条件オン、メアド条件オフ、メアドのみ条件オン
  @isTest
  static void test_getContactOptions_Soql_deptOn_0_emailoff_emailonlyon() {
    // カスタム設定は 名刺トリガが動く前にセット    
    SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    svConfig.AccountRegistSearchMethod__c = 1; // 取引先・取引先任者に登録(個別) 登録先候補の検索方法 SOQL　に
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

    Account acnt = [SELECT Id, Name FROM Account WHERE Name='株式会社サンブリッジ' LIMIT 1];
    SB_NC_RegistQueryOption qo_c = new SB_NC_RegistQueryOption(Contact.getSObjectType());
    // qo_c.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.CorpMatch;  // 社名一致
    qo_c.addParentId(acnt.Id); // アカウントの指定
    qo_c.queryDept = true;  // 部署照合 オン
    qo_c.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_c.queryEMail = false;  // メアドは条件 オフ
    qo_c.queryOnlyEMail = true;  // コンタクトはメアドのみ一致で該当 オン

    List<NameCard__c> cards = [SELECT Id, Name, company_name__c, division__c FROM NameCard__c LIMIT 10];

    System.assertEquals(SB_NameCard_Util.smartViscaConfig.AccountRegistSearchMethod__c, svConfig.AccountRegistSearchMethod__c);
    // 登録先候補取得
    List<SB_NC_RegistOptionCreater.RegistOption> reg_opts = SB_NC_RegistOptionCreater.getContactOptions(cards[0].Id, qo_c);
    Test.stopTest();

    System.assertEquals(2+2, reg_opts.size());  // 部署が一致しないので、 0 だけど、Emailのみ条件で 2つ
    for (SB_NC_RegistOptionCreater.RegistOption reg_opt : reg_opts) {
      System.debug(reg_opt.title);
    }
  }

  // SOQL検索
  // 部署条件オン、メアド条件オフ、メアドのみ条件オフ
  @isTest
  static void test_getContactOptions_Soql_deptOn_emailoff_emailonlyoff() {
    // カスタム設定は 名刺トリガが動く前にセット    
    SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    svConfig.AccountRegistSearchMethod__c = 1; // 取引先・取引先任者に登録(個別) 登録先候補の検索方法 SOQL　に
    // svConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL　に
    upsert svConfig;
    SB_NameCard_BasicSetting.getNameCardBasicSetting().HojinkakuEquationLongAndAbbr__c = true; // // v2.4 会社名の法人格は略称・正称を同一視

    Test.startTest();
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社サンブリッジ', division__c='営業',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    insert listCard;

    Account acnt = [SELECT Id, Name FROM Account WHERE Name='株式会社サンブリッジ' LIMIT 1];
    SB_NC_RegistQueryOption qo_c = new SB_NC_RegistQueryOption(Contact.getSObjectType());
    // qo_c.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.CorpMatch;  // 社名一致
    qo_c.addParentId(acnt.Id); // アカウントの指定
    qo_c.queryDept = true;  // 部署照合 オン
    qo_c.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_c.queryEMail = false;  // メアドは条件 オフ
    qo_c.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ

    List<NameCard__c> cards = [SELECT Id, Name, company_name__c, division__c FROM NameCard__c LIMIT 10];

    System.assertEquals(SB_NameCard_Util.smartViscaConfig.AccountRegistSearchMethod__c, svConfig.AccountRegistSearchMethod__c);
    // 登録先候補取得
    List<SB_NC_RegistOptionCreater.RegistOption> reg_opts = SB_NC_RegistOptionCreater.getContactOptions(cards[0].Id, qo_c);
    Test.stopTest();

    System.assertEquals(2+2, reg_opts.size());  // 姓名部署一致が２つ
    for (SB_NC_RegistOptionCreater.RegistOption reg_opt : reg_opts) {
      System.debug(reg_opt.title);
    }
  }

  // SOQL検索
  // 部署条件オン、メアド条件オン、メアドのみ条件オフ
  @isTest
  static void test_getContactOptions_Soql_deptOn_emailon_emailonlyoff() {
    // カスタム設定は 名刺トリガが動く前にセット    
    SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    svConfig.AccountRegistSearchMethod__c = 1; // 取引先・取引先任者に登録(個別) 登録先候補の検索方法 SOQL　に
    // svConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL　に
    upsert svConfig;
    SB_NameCard_BasicSetting.getNameCardBasicSetting().HojinkakuEquationLongAndAbbr__c = true; // // v2.4 会社名の法人格は略称・正称を同一視

    Test.startTest();
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社サンブリッジ', division__c='営業',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    insert listCard;

    Account acnt = [SELECT Id, Name FROM Account WHERE Name='株式会社サンブリッジ' LIMIT 1];
    SB_NC_RegistQueryOption qo_c = new SB_NC_RegistQueryOption(Contact.getSObjectType());
    // qo_c.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.CorpMatch;  // 社名一致
    qo_c.addParentId(acnt.Id); // アカウントの指定
    qo_c.queryDept = true;  // 部署照合 オン
    qo_c.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_c.queryEMail = true;  // メアドは条件 オン
    qo_c.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ
    qo_c.queryNameOrEMail = false; // 

    List<NameCard__c> cards = [SELECT Id, Name, company_name__c, division__c FROM NameCard__c LIMIT 10];

    System.assertEquals(SB_NameCard_Util.smartViscaConfig.AccountRegistSearchMethod__c, svConfig.AccountRegistSearchMethod__c);
    // 登録先候補取得
    List<SB_NC_RegistOptionCreater.RegistOption> reg_opts = SB_NC_RegistOptionCreater.getContactOptions(cards[0].Id, qo_c);
    Test.stopTest();

    System.assertEquals(1+2, reg_opts.size());  // 姓名部署Email一致が1つ
    for (SB_NC_RegistOptionCreater.RegistOption reg_opt : reg_opts) {
      System.debug(reg_opt.title);
    }
  }

  // SOQL検索
  // 部署条件オン、メアド条件オン、メアドのみ条件オフ
  @isTest
  static void test_getContactOptions_Soql_deptOn_AccountSite_emailon_emailonlyoff() {
    // カスタム設定は 名刺トリガが動く前にセット    
    SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    svConfig.AccountRegistSearchMethod__c = 1; // 取引先・取引先任者に登録(個別) 登録先候補の検索方法 SOQL　に
    // svConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL　に
    upsert svConfig;
    SB_NameCard_BasicSetting.getNameCardBasicSetting().HojinkakuEquationLongAndAbbr__c = true; // // v2.4 会社名の法人格は略称・正称を同一視

    Test.startTest();
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社サンブリッジ', division__c='静岡',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    insert listCard;

    Account acnt = [SELECT Id, Name FROM Account WHERE Name='株式会社サンブリッジ' LIMIT 1];
    SB_NC_RegistQueryOption qo_c = new SB_NC_RegistQueryOption(Contact.getSObjectType());
    // qo_c.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.CorpMatch;  // 社名一致
    qo_c.addParentId(acnt.Id); // アカウントの指定
    qo_c.queryDept = true;  // 部署照合 オン
    qo_c.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_c.queryEMail = true;  // メアドは条件 オン
    qo_c.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ
    qo_c.queryNameOrEMail = false; // 

    List<NameCard__c> cards = [SELECT Id, Name, company_name__c, division__c FROM NameCard__c LIMIT 10];

    System.assertEquals(SB_NameCard_Util.smartViscaConfig.AccountRegistSearchMethod__c, svConfig.AccountRegistSearchMethod__c);
    // 登録先候補取得
    List<SB_NC_RegistOptionCreater.RegistOption> reg_opts = SB_NC_RegistOptionCreater.getContactOptions(cards[0].Id, qo_c);
    Test.stopTest();

    System.assertEquals(1+2, reg_opts.size());  // 姓名部署Email一致が1つ
    for (SB_NC_RegistOptionCreater.RegistOption reg_opt : reg_opts) {
      System.debug(reg_opt.title);
    }
  }

}