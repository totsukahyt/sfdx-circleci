/**
 *
 * SB_NameCard_RenkeiTriggerHelperTest4
 *
 * SV_DEV-1497 自動連携で電話番号2を使用しないようにする のテスト用
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2019.03.xx v2.2
 *
 **/
@isTest
private class SB_NameCard_RenkeiTriggerHelperTest4 {

  // 自動連携で電話番号2を使用するカスタム設定
  private virtual class TestDb extends SB_NC_TestDB {

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
      bs.RenkeiAccountPhone__c = true;     // アカウント 電話番号 ※
      //bs.RenkeiSpecificItems__c = null;        // アカウント 特定項目
      bs.RenkeiExcludeHojinkakuPartial__c = false;      // 自動連携:会社名は法人格を除いて部分一致
      bs.RenkeiExcludeHojinkaku__c = true;      // 自動連携:会社名は法人格を除いて完全一致
      bs.RenkeiAccountSitePartialMatch__c = true;      // 自動連携:部署は中間一致検索
      //bs.RenkeiContactMail__c = true;      // コンタクト メールアドレス
      //bs.RenkeiContactLastName__c = true;  // コンタクト ラストネーム
      //bs.RenkeiContactFirstName__c = false; // コンタクト ファーストネーム

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
      initializeUser();
      if (listUser.isEmpty() == false) {
        insert listUser;
      }
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

  // 自動連携で電話番号2を使用しない カスタム設定
  private virtual class TestDb_IgnorePhone2 extends TestDb {

    // SmartVisca設定　
    // トリガを有効・無効
    // 自動連携: 電話番号2 は取引先候補の条件に使わない TRUE
    public virtual override void initializeSmartViscaConfig() {
      svConfig = SmartViscaConfig__c.getOrgDefaults();
      svConfig.TriggerRegDateTime__c = true;
      svConfig.TriggerCreateFeedOnName__c = false;
      svConfig.TriggerMergeNameCards__c = false;
      svConfig.TriggerHistoryIsActive__c = false;
      svConfig.TriggerRenkeiTriggerHandler__c = true; // v2.1 トリガで自動連携を行う
      svConfig.TriggerLeadExRenkeiTriggerHandler__c = false; // v2.1 トリガでリード拡張パッケージの自動連携を使う
      svConfig.SFilterSearchResult__c = false; // v2.2 S検索結果を特定の項目値で絞り込む
      svConfig.AutoConvAccountSearchNotUsePhone2__c = true;   // v2.2 自動連携: 電話番号2 は取引先候補の条件に使わない
    }

  }
  // 名刺挿入で自動連携して アカウント更新、コンタクト更新
  @isTest
  static void test_Renkei_SameCompanyCards_usePhone2() {
    TestDb db = new TestDb();
    db.initialize();

    Test.startTest();

    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社テスト商事', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='一郎', email__c='ichiro@test.com', delivery_type__c='2'));
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社テスト商事', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-5555-5555', // 電話番号
                    last_name__c='テスト', first_name__c='一郎', email__c='ichiro@test.com', delivery_type__c='2'));

    insert listCard;
    Test.stopTest();

    System.assertEquals(2, [SELECT Id, Name FROM Account WHERE Name = '株式会社テスト商事'].size());
    System.assertEquals(2, [SELECT Id, Name FROM Contact WHERE Account.Name = '株式会社テスト商事'].size());
    System.assertEquals(2, [SELECT Id, Name, account__c, contact__c FROM NameCard__c WHERE account__c != null AND contact__c!=null].size());
  }

  @isTest
  static void test_Renkei_SameCompanyCards_ignorePhone2() {
    TestDb_IgnorePhone2 db = new TestDb_IgnorePhone2();
    db.initialize();

    Test.startTest();

    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社テスト商事', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='一郎', email__c='ichiro@test.com', delivery_type__c='2'));
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社テスト商事', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-5555-5555', // 電話番号
                    last_name__c='テスト', first_name__c='一郎', email__c='ichiro@test.com', delivery_type__c='2'));

    insert listCard;
    Test.stopTest();

    System.assertEquals(1, [SELECT Id, Name FROM Account WHERE Name = '株式会社テスト商事'].size());
    System.assertEquals(1, [SELECT Id, Name FROM Contact WHERE Account.Name = '株式会社テスト商事'].size());
    System.assertEquals(2, [SELECT Id, Name, account__c, contact__c FROM NameCard__c WHERE account__c != null AND contact__c!=null].size());
  }

}