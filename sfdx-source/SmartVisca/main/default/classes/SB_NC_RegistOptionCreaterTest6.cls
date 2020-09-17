/**
 *
 * SB_NC_RegistOptionCreaterTest6
 *  SB_NC_RegistOptionCreater のテストクラス SOQL検索編 一括
 * 
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1  2019.06.xx v2.4
 *
 **/
@isTest
private class SB_NC_RegistOptionCreaterTest6 {

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

    // 恵比寿システム
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@0.com', Department='営業部', AccountId=acnts[7].Id));       // 姓名が名刺と一緒
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@test.com', Department='営業部', AccountId=acnts[7].Id));    // 姓名メアドが名刺と一緒
    conts.add(new Contact(LastName='検証', FirstName='太郎', EMail='taro@test.com', Department='営業部', AccountId=acnts[7].Id));    // メアドが名刺と一緒
    conts.add(new Contact(LastName='テスト', FirstName='一郎', EMail='ichiro@0.com', Department='営業部', AccountId=acnts[7].Id));    // 姓名メアド 一致しない
    conts.add(new Contact(LastName='テスト', FirstName='一郎', EMail='ichiro@test.com', Department='営業部', AccountId=acnts[7].Id));  // 姓名メアド 一致しない

    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@1.com', AccountId=acnts[8].Id));
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@test.com', AccountId=acnts[8].Id));    // メアドが名刺と一緒
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@2.com', AccountId=acnts[9].Id));
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@test.com', AccountId=acnts[9].Id));    // メアドが名刺と一緒
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@3.com', AccountId=acnts[10].Id));
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@test.com', AccountId=acnts[10].Id));    // メアドが名刺と一緒
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@4.com', AccountId=acnts[11].Id));
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@test.com', AccountId=acnts[11].Id));    // メアドが名刺と一緒
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@5.com', AccountId=acnts[12].Id));
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@test.com', AccountId=acnts[12].Id));    // メアドが名刺と一緒
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@6.com', AccountId=acnts[13].Id));
    conts.add(new Contact(LastName='テスト', FirstName='太郎', EMail='taro@test.com', AccountId=acnts[13].Id));    // メアドが名刺と一緒

    insert conts;

  }

  // SOQL検索
  // 会社名一致
  // 部署照合 オフ
  // 姓名 一致、メアドのみ一致オフ
  @isTest
  static void test_getAccountOptions_Soql_CorpMatch_deptOff_emailoff_emailonlyoff() {
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
    SB_NameCard_Util.smartViscaConfig.AccountBulkRegistSearchMethod__c = 1; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOSL　に
    SB_NameCard_BasicSetting.getNameCardBasicSetting().HojinkakuEquationLongAndAbbr__c = true; // // v2.4 会社名の法人格は略称・正称を同一視

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.getSObjectType());
    qo_a.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.CorpMatch;  // 社名一致
    qo_a.bulkRegist = true;
    qo_a.queryDept = false;  // 部署照合 オフ
    qo_a.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_a.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ
    SB_NC_RegistQueryOption qo_c = new SB_NC_RegistQueryOption(Contact.getSObjectType());
    qo_c.bulkRegist = true;
    qo_c.queryCompany = false;
    qo_c.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.PartialMatch;  // 社名一致
    qo_c.queryDept = false;  // 部署照合 オフ
    qo_c.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;  // 部署中間一致
    qo_c.queryEMail = false;  // メアドは条件 オフ
    qo_c.queryOnlyEMail = false;  // コンタクトはメアドのみ一致で該当 オフ

    Map<Id, NameCard__c> cards = new Map<Id, NameCard__c> ([SELECT Id, Name, company_name__c, division__c FROM NameCard__c LIMIT 10]);
    // List<Id> ids = (List<Id>)cards.values();

    // SOSL 検索結果 を セット
    Map<Id, Account> acnts = new Map<Id, Account>([SELECT Id, Name FROM Account]);
    Test.setFixedSearchResults(new List<Id>(acnts.keySet()));
    // 名刺-登録先候補s 取得
    List<SB_NC_RegistOptionCreater.Card_RegistOption> card_opts_list = SB_NC_RegistOptionCreater.getRegistOptions(new List<Id>(cards.keySet()), new List<SB_NC_RegistQueryOption> { qo_a, qo_c });
    Test.stopTest();

    System.assertEquals(2, card_opts_list.size());
    for (SB_NC_RegistOptionCreater.Card_RegistOption card_opts : card_opts_list) {
      System.assertEquals(5+2, card_opts.options.size());
      for (SB_NC_RegistOptionCreater.RegistOption reg_opt : card_opts.options) {
        System.debug(reg_opt.title);
      }
    }
  }

}