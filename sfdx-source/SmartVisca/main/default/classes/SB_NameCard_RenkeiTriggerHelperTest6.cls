/**
 *
 * SB_NameCard_RenkeiTriggerHelperTest6
 *
 * v2.4 での 自動連携の改良のテスト 2
 *
 * SV_DEV-1684 【自動連携】設定により取引先を作成せず「未登録」となった場合の自動連携処理情報に記載される文言を変えて欲しい
 *  同時に納品した別の名刺で更新した場合: [Account update: another][Contact update: another]
 *  既存あったけど、上書きしない設定のとき:[Account link] [Contact link]
 *  ないけど、新規作成しない設定のとき: [Account not create] [Contact not create]
 *  新規作成したとき:[Account create] [Contact create]
 *  更新したとき:[Account update] [Contact update]
 * 
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2019.05.xx v2.4 
 *
 **/
@isTest
private class SB_NameCard_RenkeiTriggerHelperTest6 {

  // 自動連携で電話番号2を使用するカスタム設定
  private class TestDb extends SB_NC_TestDB {

    // 会社名は(法人格含め)完全一致で自動連携の設定
    public override void initializeBasicSetting() {
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
      bs.RenkeiAccountPhone__c = false;     // アカウント 電話番号 ※
      //bs.RenkeiSpecificItems__c = null;        // アカウント 特定項目
      bs.RenkeiExcludeHojinkakuPartial__c = false;      // 自動連携:会社名は法人格を除いて部分一致
      bs.RenkeiExcludeHojinkaku__c = false;      // 自動連携:会社名は法人格を除いて完全一致
      bs.RenkeiAccountSitePartialMatch__c = true;      // 自動連携:部署は中間一致検索
      bs.RenkeiContactMail__c = true;      // コンタクト メールアドレス
      bs.RenkeiContactLastName__c = true;  // コンタクト ラストネーム
      bs.RenkeiContactFirstName__c = false; // コンタクト ファーストネーム

      listBasicSetting.add(bs);
    }
    // SmartVisca設定　
    // トリガを有効・無効
    // 自動連携: 電話番号2 は取引先候補の条件に使わない FALSE
    public virtual override void initializeSmartViscaConfig() {
      svConfig = SmartViscaConfig__c.getOrgDefaults();
      svConfig.TriggerRegDateTime__c = true;
      svConfig.TriggerCreateFeedOnName__c = false;
      svConfig.TriggerMergeNameCards__c = false;
      svConfig.TriggerHistoryIsActive__c = false;
      svConfig.TriggerRenkeiTriggerHandler__c = true; // v2.1 トリガで自動連携を行う
      svConfig.TriggerLeadExRenkeiTriggerHandler__c = false; // v2.1 トリガでリード拡張パッケージの自動連携を使う
      svConfig.SFilterSearchResult__c = false; // v2.2 S検索結果を特定の項目値で絞り込む
      svConfig.AutoConvAccountSearchNotUsePhone2__c = false;   // v2.2 自動連携: 電話番号2 は取引先候補の条件に使わない
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
      // 名刺連携項目マッピング
      initializeMapping();
      if (!listMapping.isEmpty()) {
        insert listMapping;
      }
    }
  } // TestDb


  @testSetup
  static void setupDB() {
    TestDb db = new TestDb();
    db.initialize();  
  }

  // SV_DEV-1647 法人格の正式名称と略称をマッチさせる（登録・自動連携）
  // 上書きする、新規作成する設定
  @isTest
  static void test_Renkei_Update_Create() {
    NameCardBasicSetting__c bs = [SELECT Id, RenkeiAccountOverwrite__c, RenkeiContactOverwrite__c, RenkeiAccountNOExistCreateNew__c, RenkeiContactNOExistCreateNew__c FROM NameCardBasicSetting__c LIMIT 1];
    bs.RenkeiAccountOverwrite__c = true;  // 既存の取引先を上書き
    bs.RenkeiContactOverwrite__c = true;   // 既存の取引先責任者を上書き
    bs.RenkeiAccountNOExistCreateNew__c = true;  //既存の取引先がなければ新規作成する
    bs.RenkeiContactNOExistCreateNew__c = true;  // 既存の取引先責任者がなければ新規作成する
    update bs;

    List<Account> acnts = new List<Account>();
    acnts.add(new Account(Name='株式会社 既存取責あり商事'));
    acnts.add(new Account(Name='株式会社 既存取責なし商事'));
    insert acnts;

    List<Contact> conts = new List<Contact>();
    conts.add(new Contact(LastName='テスト', FirstName='一郎', EMail='ichiro@kizon1.com', AccountId=acnts[0].Id));
    insert conts;

    Test.startTest();
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社 既存取責あり商事', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='一郎', email__c='ichiro@kizon1.com', delivery_type__c='2'));
    listCard.add(new NameCard__c(Name='テスト 二郎', company_name__c='株式会社 既存取責なし商事', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-5555-5555', tel2__c = '03-6666-6666', // 電話番号
                    last_name__c='テスト', first_name__c='二郎', email__c='jiro@kizon2.com', delivery_type__c='2'));
    listCard.add(new NameCard__c(Name='テスト 三郎', company_name__c='株式会社 新規物産', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-7777-7777', tel2__c = '03-8888-8888', // 電話番号
                    last_name__c='テスト', first_name__c='三郎', email__c='saburo@sinki.com', delivery_type__c='2'));

    insert listCard;
    Test.stopTest();

    // 名刺の 自動連携処理情報の確認
    System.assertEquals(1, [SELECT Id FROM NameCard__c WHERE company_name__c = '株式会社 既存取責あり商事' AND RenkeiMessage__c LIKE '[Account update] [Contact update]'].size());
    System.assertEquals(1, [SELECT Id FROM NameCard__c WHERE company_name__c = '株式会社 既存取責なし商事' AND RenkeiMessage__c LIKE '[Account update] [Contact create]'].size());
    System.assertEquals(1, [SELECT Id FROM NameCard__c WHERE company_name__c = '株式会社 新規物産' AND RenkeiMessage__c LIKE '[Account create] [Contact create]'].size());
    // アカウントの確認
    System.assertEquals('本社', [SELECT Id, Name, Site, Phone, BillingState, ShippingState FROM Account WHERE Name = '株式会社 既存取責あり商事' LIMIT 1].Site);
    System.assertEquals('本社', [SELECT Id, Name, Site, Phone, BillingState, ShippingState FROM Account WHERE Name = '株式会社 既存取責なし商事' LIMIT 1].Site);
    System.assertEquals('本社', [SELECT Id, Name, Site, Phone, BillingState, ShippingState FROM Account WHERE Name = '株式会社 新規物産' LIMIT 1].Site);
    // コンタクトの確認
    System.assertEquals('03-3333-3333', [SELECT Id, Name, Department, Title, Phone, EMail FROM Contact WHERE Account.Name = '株式会社 既存取責あり商事' LIMIT 1].Phone);
    System.assertEquals('03-5555-5555', [SELECT Id, Name, Department, Title, Phone, EMail FROM Contact WHERE Account.Name = '株式会社 既存取責なし商事' LIMIT 1].Phone);
    System.assertEquals('03-7777-7777', [SELECT Id, Name, Department, Title, Phone, EMail FROM Contact WHERE Account.Name = '株式会社 新規物産' LIMIT 1].Phone);
  }

  // SV_DEV-1647 法人格の正式名称と略称をマッチさせる（登録・自動連携）
  // 上書きしない、新規作成する設定
  @isTest
  static void test_Renkei_NoUpdate_Create() {
    NameCardBasicSetting__c bs = [SELECT Id, RenkeiAccountOverwrite__c, RenkeiContactOverwrite__c, RenkeiAccountNOExistCreateNew__c, RenkeiContactNOExistCreateNew__c FROM NameCardBasicSetting__c LIMIT 1];
    bs.RenkeiAccountOverwrite__c = false;  // 既存の取引先を上書き
    bs.RenkeiContactOverwrite__c = false;   // 既存の取引先責任者を上書き
    bs.RenkeiAccountNOExistCreateNew__c = true;  //既存の取引先がなければ新規作成する
    bs.RenkeiContactNOExistCreateNew__c = true;  // 既存の取引先責任者がなければ新規作成する
    update bs;

    List<Account> acnts = new List<Account>();
    acnts.add(new Account(Name='株式会社 既存取責あり商事'));
    acnts.add(new Account(Name='株式会社 既存取責なし商事'));
    insert acnts;

    List<Contact> conts = new List<Contact>();
    conts.add(new Contact(LastName='テスト', FirstName='一郎', EMail='ichiro@kizon1.com', AccountId=acnts[0].Id));
    insert conts;

    Test.startTest();
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社 既存取責あり商事', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='一郎', email__c='ichiro@kizon1.com', delivery_type__c='2'));
    listCard.add(new NameCard__c(Name='テスト 二郎', company_name__c='株式会社 既存取責なし商事', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-5555-5555', tel2__c = '03-6666-6666', // 電話番号
                    last_name__c='テスト', first_name__c='二郎', email__c='jiro@kizon2.com', delivery_type__c='2'));
    listCard.add(new NameCard__c(Name='テスト 三郎', company_name__c='株式会社 新規物産', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-7777-7777', tel2__c = '03-8888-8888', // 電話番号
                    last_name__c='テスト', first_name__c='三郎', email__c='saburo@sinki.com', delivery_type__c='2'));

    insert listCard;
    Test.stopTest();

    // 名刺の 自動連携処理情報の確認
    System.assertEquals(1, [SELECT Id FROM NameCard__c WHERE company_name__c = '株式会社 既存取責あり商事' AND RenkeiMessage__c LIKE '[Account link] [Contact link]'].size());
    System.assertEquals(1, [SELECT Id FROM NameCard__c WHERE company_name__c = '株式会社 既存取責なし商事' AND RenkeiMessage__c LIKE '[Account link] [Contact create]'].size());
    System.assertEquals(1, [SELECT Id FROM NameCard__c WHERE company_name__c = '株式会社 新規物産' AND RenkeiMessage__c = '[Account create] [Contact create]'].size());
    // アカウントの確認
    System.assertEquals(null, [SELECT Id, Name, Site, Phone, BillingState, ShippingState FROM Account WHERE Name = '株式会社 既存取責あり商事' LIMIT 1].Site);
    System.assertEquals(null, [SELECT Id, Name, Site, Phone, BillingState, ShippingState FROM Account WHERE Name = '株式会社 既存取責なし商事' LIMIT 1].Site);
    System.assertEquals('本社', [SELECT Id, Name, Site, Phone, BillingState, ShippingState FROM Account WHERE Name = '株式会社 新規物産' LIMIT 1].Site);
    // コンタクトの確認
    System.assertEquals(null, [SELECT Id, Name, Department, Title, Phone, EMail FROM Contact WHERE Account.Name = '株式会社 既存取責あり商事' LIMIT 1].Phone);
    System.assertEquals('03-5555-5555', [SELECT Id, Name, Department, Title, Phone, EMail FROM Contact WHERE Account.Name = '株式会社 既存取責なし商事' LIMIT 1].Phone);
    System.assertEquals('03-7777-7777', [SELECT Id, Name, Department, Title, Phone, EMail FROM Contact WHERE Account.Name = '株式会社 新規物産' LIMIT 1].Phone);

  }

  // SV_DEV-1647 法人格の正式名称と略称をマッチさせる（登録・自動連携）
  // 上書きしない、新規作成しない設定
  @isTest
  static void test_Renkei_NoUpdate_NoCreate() {
    NameCardBasicSetting__c bs = [SELECT Id, RenkeiAccountOverwrite__c, RenkeiContactOverwrite__c, RenkeiAccountNOExistCreateNew__c, RenkeiContactNOExistCreateNew__c FROM NameCardBasicSetting__c LIMIT 1];
    bs.RenkeiAccountOverwrite__c = false;  // 既存の取引先を上書き
    bs.RenkeiContactOverwrite__c = false;   // 既存の取引先責任者を上書き
    bs.RenkeiAccountNOExistCreateNew__c = false;  //既存の取引先がなければ新規作成する
    bs.RenkeiContactNOExistCreateNew__c = false;  // 既存の取引先責任者がなければ新規作成する
    update bs;

    List<Account> acnts = new List<Account>();
    acnts.add(new Account(Name='株式会社 既存取責あり商事'));
    acnts.add(new Account(Name='株式会社 既存取責なし商事'));
    insert acnts;

    List<Contact> conts = new List<Contact>();
    conts.add(new Contact(LastName='テスト', FirstName='一郎', EMail='ichiro@kizon1.com', AccountId=acnts[0].Id));
    insert conts;

    Test.startTest();
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社 既存取責あり商事', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='一郎', email__c='ichiro@kizon1.com', delivery_type__c='2'));
    listCard.add(new NameCard__c(Name='テスト 二郎', company_name__c='株式会社 既存取責なし商事', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-5555-5555', tel2__c = '03-6666-6666', // 電話番号
                    last_name__c='テスト', first_name__c='二郎', email__c='jiro@kizon2.com', delivery_type__c='2'));
    listCard.add(new NameCard__c(Name='テスト 三郎', company_name__c='株式会社 新規物産', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-7777-7777', tel2__c = '03-8888-8888', // 電話番号
                    last_name__c='テスト', first_name__c='三郎', email__c='saburo@sinki.com', delivery_type__c='2'));

    insert listCard;
    Test.stopTest();

    // 名刺の 自動連携処理情報の確認
    System.assertEquals(1, [SELECT Id FROM NameCard__c WHERE company_name__c = '株式会社 既存取責あり商事' AND RenkeiMessage__c LIKE '[Account link] [Contact link]'].size());
    System.assertEquals(1, [SELECT Id FROM NameCard__c WHERE company_name__c = '株式会社 既存取責なし商事' AND RenkeiMessage__c LIKE '[Account link] [Contact not create]'].size());
    System.assertEquals(1, [SELECT Id FROM NameCard__c WHERE company_name__c = '株式会社 新規物産' AND RenkeiMessage__c = '[Account not create] [Contact not create]'].size());
    // アカウントの確認
    System.assertEquals(null, [SELECT Id, Name, Site, Phone, BillingState, ShippingState FROM Account WHERE Name = '株式会社 既存取責あり商事' LIMIT 1].Site);
    System.assertEquals(null, [SELECT Id, Name, Site, Phone, BillingState, ShippingState FROM Account WHERE Name = '株式会社 既存取責なし商事' LIMIT 1].Site);
    System.assertEquals(0, [SELECT Id, Name, Site, Phone, BillingState, ShippingState FROM Account WHERE Name = '株式会社 新規物産' LIMIT 1].size());
    // コンタクトの確認
    System.assertEquals(null, [SELECT Id, Name, Department, Title, Phone, EMail FROM Contact WHERE Account.Name = '株式会社 既存取責あり商事' LIMIT 1].Phone);
    System.assertEquals(0, [SELECT Id, Name, Department, Title, Phone, EMail FROM Contact WHERE Account.Name = '株式会社 既存取責なし商事' LIMIT 1].size());
    System.assertEquals(0, [SELECT Id, Name, Department, Title, Phone, EMail FROM Contact WHERE Account.Name = '株式会社 新規物産' LIMIT 1].size());
  }

  // SV_DEV-1647 法人格の正式名称と略称をマッチさせる（登録・自動連携）
  // 上書きする、新規作成しない設定
  @isTest
  static void test_Renkei_Update_NoCreate() {
    NameCardBasicSetting__c bs = [SELECT Id, RenkeiAccountOverwrite__c, RenkeiContactOverwrite__c, RenkeiAccountNOExistCreateNew__c, RenkeiContactNOExistCreateNew__c FROM NameCardBasicSetting__c LIMIT 1];
    bs.RenkeiAccountOverwrite__c = true;  // 既存の取引先を上書き
    bs.RenkeiContactOverwrite__c = true;   // 既存の取引先責任者を上書き
    bs.RenkeiAccountNOExistCreateNew__c = false;  //既存の取引先がなければ新規作成する
    bs.RenkeiContactNOExistCreateNew__c = false;  // 既存の取引先責任者がなければ新規作成する
    update bs;

    List<Account> acnts = new List<Account>();
    acnts.add(new Account(Name='株式会社 既存取責あり商事'));
    acnts.add(new Account(Name='株式会社 既存取責なし商事'));
    insert acnts;

    List<Contact> conts = new List<Contact>();
    conts.add(new Contact(LastName='テスト', FirstName='一郎', EMail='ichiro@kizon1.com', AccountId=acnts[0].Id));
    insert conts;

    Test.startTest();
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社 既存取責あり商事', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='一郎', email__c='ichiro@kizon1.com', delivery_type__c='2'));
    listCard.add(new NameCard__c(Name='テスト 二郎', company_name__c='株式会社 既存取責なし商事', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-5555-5555', tel2__c = '03-6666-6666', // 電話番号
                    last_name__c='テスト', first_name__c='二郎', email__c='jiro@kizon2.com', delivery_type__c='2'));
    listCard.add(new NameCard__c(Name='テスト 三郎', company_name__c='株式会社 新規物産', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-7777-7777', tel2__c = '03-8888-8888', // 電話番号
                    last_name__c='テスト', first_name__c='三郎', email__c='saburo@sinki.com', delivery_type__c='2'));

    insert listCard;
    Test.stopTest();

    // 名刺の 自動連携処理情報の確認
    System.assertEquals(1, [SELECT Id FROM NameCard__c WHERE company_name__c = '株式会社 既存取責あり商事' AND RenkeiMessage__c ='[Account update] [Contact update]'].size());
    System.assertEquals(1, [SELECT Id FROM NameCard__c WHERE company_name__c = '株式会社 既存取責なし商事' AND RenkeiMessage__c = '[Account update] [Contact not create]'].size());
    System.assertEquals(1, [SELECT Id FROM NameCard__c WHERE company_name__c = '株式会社 新規物産' AND RenkeiMessage__c = '[Account not create] [Contact not create]'].size());
    // アカウントの確認
    System.assertEquals('本社', [SELECT Id, Name, Site, Phone, BillingState, ShippingState FROM Account WHERE Name = '株式会社 既存取責あり商事' LIMIT 1].Site);
    System.assertEquals('本社', [SELECT Id, Name, Site, Phone, BillingState, ShippingState FROM Account WHERE Name = '株式会社 既存取責なし商事' LIMIT 1].Site);
    System.assertEquals(0, [SELECT Id, Name, Site, Phone, BillingState, ShippingState FROM Account WHERE Name = '株式会社 新規物産' LIMIT 1].size());
    // コンタクトの確認
    System.assertEquals('03-3333-3333', [SELECT Id, Name, Department, Title, Phone, EMail FROM Contact WHERE Account.Name = '株式会社 既存取責あり商事' LIMIT 1].Phone);
    System.assertEquals(0, [SELECT Id, Name, Department, Title, Phone, EMail FROM Contact WHERE Account.Name = '株式会社 既存取責なし商事' LIMIT 1].size());
    System.assertEquals(0, [SELECT Id, Name, Department, Title, Phone, EMail FROM Contact WHERE Account.Name = '株式会社 新規物産' LIMIT 1].size());
  }

}