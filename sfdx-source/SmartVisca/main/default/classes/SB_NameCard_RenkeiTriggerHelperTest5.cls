/**
 *
 * SB_NameCard_RenkeiTriggerHelperTest5
 *
 * v2.4 での 自動連携の改良のテスト 1
 *
 * SV_DEV-1638 自動連携の取引先検索で取引先名完全一致の取引先があればあいまい検索一致の取引先があっても重複にしないようにする
 *
 * SV_DEV-1647 法人格の正式名称と略称をマッチさせる（登録・自動連携）
 *
 * SV_DEV-893 【自動連携】1次納品段階で登録した活動履歴を取引先・取引先責任者に引き継ぎたい
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2019.05.xx v2.4
 *
 **/
@isTest
private class SB_NameCard_RenkeiTriggerHelperTest5 {

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
  @isTest
  static void test_Renkei_KabusikiKaisha_Variants() {
    // 会社名完全一致にする。
    NameCardBasicSetting__c bs = [SELECT Id, RenkeiExcludeHojinkakuPartial__c, RenkeiExcludeHojinkaku__c FROM NameCardBasicSetting__c LIMIT 1];
    bs.RenkeiExcludeHojinkakuPartial__c = false;      // 自動連携:会社名は法人格を除いて部分一致
    bs.RenkeiExcludeHojinkaku__c = false;      // 自動連携:会社名は法人格を除いて完全一致
    bs.HojinkakuEquationLongAndAbbr__c = true; // 	法人格の略称を正称の表記とみなして会社名を比較する
    update bs;

    List<Account> acnts = new List<Account>();
    acnts.add(new Account(Name='㈱テスト商事'));
    acnts.add(new Account(Name='株式会社 サンプル物産'));
    acnts.add(new Account(Name='有限会社テスト商事'));
    insert acnts;

    System.assertEquals(null, [SELECT Id, Name, Site, Phone, BillingState, ShippingState FROM Account WHERE Name = '㈱テスト商事' LIMIT 1].Site);
    System.assertEquals(null, [SELECT Id, Name, Site, Phone, BillingState, ShippingState FROM Account WHERE Name = '株式会社 サンプル物産' LIMIT 1].Site);
    System.assertEquals(null, [SELECT Id, Name, Site, Phone, BillingState, ShippingState FROM Account WHERE Name = '有限会社テスト商事' LIMIT 1].Site);

    Test.startTest();
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社テスト商事', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='一郎', email__c='ichiro@test.com', delivery_type__c='2'));
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='（株）　サンプル物産', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-5555-5555', tel2__c = '03-6666-6666', // 電話番号
                    last_name__c='テスト', first_name__c='一郎', email__c='ichiro@sample.com', delivery_type__c='2'));

    insert listCard;
    Test.stopTest();

    System.assertEquals('本社', [SELECT Id, Name, Site, Phone, BillingState, ShippingState FROM Account WHERE Name = '㈱テスト商事' LIMIT 1].Site);
    System.assertEquals('本社', [SELECT Id, Name, Site, Phone, BillingState, ShippingState FROM Account WHERE Name = '株式会社 サンプル物産' LIMIT 1].Site);
    System.assertEquals(null, [SELECT Id, Name, Site, Phone, BillingState, ShippingState FROM Account WHERE Name = '有限会社テスト商事' LIMIT 1].Site);
  }

  // SV_DEV-1647 法人格の正式名称と略称をマッチさせる（登録・自動連携）
  //  正式名称と略称の２つある
  @isTest
  static void test_Renkei_KabusikiKaisha_Variants_duplicate() {
    // 会社名完全一致にする。
    NameCardBasicSetting__c bs = [SELECT Id, RenkeiExcludeHojinkakuPartial__c, RenkeiExcludeHojinkaku__c FROM NameCardBasicSetting__c LIMIT 1];
    bs.RenkeiExcludeHojinkakuPartial__c = false;      // 自動連携:会社名は法人格を除いて部分一致
    bs.RenkeiExcludeHojinkaku__c = false;      // 自動連携:会社名は法人格を除いて完全一致
    bs.HojinkakuEquationLongAndAbbr__c = true; // 	法人格の略称を正称の表記とみなして会社名を比較する
    update bs;

    List<Account> acnts = new List<Account>();
    acnts.add(new Account(Name='㈱テスト商事'));
    acnts.add(new Account(Name='株式会社テスト商事'));
    acnts.add(new Account(Name='株式会社 サンプル物産'));
    acnts.add(new Account(Name='有限会社テスト商事'));
    insert acnts;

    System.assertEquals(null, [SELECT Id, Name, Site, Phone, BillingState, ShippingState FROM Account WHERE Name = '㈱テスト商事' LIMIT 1].Site);
    System.assertEquals(null, [SELECT Id, Name, Site, Phone, BillingState, ShippingState FROM Account WHERE Name = '株式会社テスト商事' LIMIT 1].Site);
    System.assertEquals(null, [SELECT Id, Name, Site, Phone, BillingState, ShippingState FROM Account WHERE Name = '株式会社 サンプル物産' LIMIT 1].Site);
    System.assertEquals(null, [SELECT Id, Name, Site, Phone, BillingState, ShippingState FROM Account WHERE Name = '有限会社テスト商事' LIMIT 1].Site);

    Test.startTest();
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社テスト商事', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='一郎', email__c='ichiro@test.com', delivery_type__c='2'));
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='（株）　サンプル物産', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-5555-5555', tel2__c = '03-6666-6666', // 電話番号
                    last_name__c='テスト', first_name__c='一郎', email__c='ichiro@sample.com', delivery_type__c='2'));

    insert listCard;
    Test.stopTest();

    System.assertEquals(null, [SELECT Id, Name, Site, Phone, BillingState, ShippingState FROM Account WHERE Name = '㈱テスト商事' LIMIT 1].Site);
    System.assertEquals(null, [SELECT Id, Name, Site, Phone, BillingState, ShippingState FROM Account WHERE Name = '株式会社テスト商事' LIMIT 1].Site);
    System.assertEquals('本社', [SELECT Id, Name, Site, Phone, BillingState, ShippingState FROM Account WHERE Name = '株式会社 サンプル物産' LIMIT 1].Site);
    System.assertEquals(null, [SELECT Id, Name, Site, Phone, BillingState, ShippingState FROM Account WHERE Name = '有限会社テスト商事' LIMIT 1].Site);
  }

  // SV_DEV-1638 自動連携の取引先検索で取引先名完全一致の取引先があればあいまい検索一致の取引先があっても重複にしないようにする
  // 中間一致で複数該当するが、完全一致が１つ
  @isTest
  static void test_Renkei_ManyAccounts_FullMatchOne() {
    // 会社名は法人格を除いて部分一致
    NameCardBasicSetting__c bs = [SELECT Id, RenkeiExcludeHojinkakuPartial__c, RenkeiExcludeHojinkaku__c FROM NameCardBasicSetting__c LIMIT 1];
    bs.RenkeiExcludeHojinkakuPartial__c = true;      // 自動連携:会社名は法人格を除いて部分一致
    bs.RenkeiExcludeHojinkaku__c = false;      // 自動連携:会社名は法人格を除いて完全一致
    update bs;

    List<Account> acnts = new List<Account>();
    acnts.add(new Account(Name='㈱テスト商事'));
    acnts.add(new Account(Name='株式会社 テスト商事運輸'));
    acnts.add(new Account(Name='有限会社 テスト商事'));
    insert acnts;
    System.assertEquals(null, [SELECT Id, Name, Site, Phone, BillingState, ShippingState FROM Account WHERE Name = '㈱テスト商事' LIMIT 1].Site);
    System.assertEquals(null, [SELECT Id, Name, Site, Phone, BillingState, ShippingState FROM Account WHERE Name = '株式会社 テスト商事運輸' LIMIT 1].Site);
    System.assertEquals(null, [SELECT Id, Name, Site, Phone, BillingState, ShippingState FROM Account WHERE Name = '有限会社 テスト商事' LIMIT 1].Site);

    Test.startTest();
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社テスト商事', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='一郎', email__c='ichiro@test.com', delivery_type__c='2'));

    insert listCard;
    Test.stopTest();

    System.assertEquals('本社', [SELECT Id, Name, Site, Phone, BillingState, ShippingState FROM Account WHERE Name = '㈱テスト商事' LIMIT 1].Site);
    System.assertEquals(null, [SELECT Id, Name, Site, Phone, BillingState, ShippingState FROM Account WHERE Name = '株式会社 テスト商事運輸' LIMIT 1].Site);
    System.assertEquals(null, [SELECT Id, Name, Site, Phone, BillingState, ShippingState FROM Account WHERE Name = '有限会社 テスト商事' LIMIT 1].Site);

  }

  // SV_DEV-1638 自動連携の取引先検索で取引先名完全一致の取引先があればあいまい検索一致の取引先があっても重複にしないようにする
  // 中間一致で複数該当するが、完全一致が２つ
  @isTest
  static void test_Renkei_ManyAccounts_FullMatchTwo() {
    // 会社名は法人格を除いて部分一致
    NameCardBasicSetting__c bs = [SELECT Id, RenkeiExcludeHojinkakuPartial__c, RenkeiExcludeHojinkaku__c FROM NameCardBasicSetting__c LIMIT 1];
    bs.RenkeiExcludeHojinkakuPartial__c = true;      // 自動連携:会社名は法人格を除いて部分一致
    bs.RenkeiExcludeHojinkaku__c = false;      // 自動連携:会社名は法人格を除いて完全一致
    update bs;

    List<Account> acnts = new List<Account>();
    acnts.add(new Account(Name='㈱テスト商事'));
    acnts.add(new Account(Name='株式会社テスト商事'));
    acnts.add(new Account(Name='株式会社 テスト商事運輸'));
    acnts.add(new Account(Name='有限会社 テスト商事'));
    insert acnts;
    System.assertEquals(null, [SELECT Id, Name, Site, Phone, BillingState, ShippingState FROM Account WHERE Name = '㈱テスト商事' LIMIT 1].Site);
    System.assertEquals(null, [SELECT Id, Name, Site, Phone, BillingState, ShippingState FROM Account WHERE Name = '株式会社テスト商事' LIMIT 1].Site);
    System.assertEquals(null, [SELECT Id, Name, Site, Phone, BillingState, ShippingState FROM Account WHERE Name = '株式会社 テスト商事運輸' LIMIT 1].Site);
    System.assertEquals(null, [SELECT Id, Name, Site, Phone, BillingState, ShippingState FROM Account WHERE Name = '有限会社 テスト商事' LIMIT 1].Site);

    Test.startTest();
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社テスト商事', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='一郎', email__c='ichiro@test.com', delivery_type__c='2'));

    insert listCard;
    Test.stopTest();

    System.assertEquals(null, [SELECT Id, Name, Site, Phone, BillingState, ShippingState FROM Account WHERE Name = '㈱テスト商事' LIMIT 1].Site);
    System.assertEquals(null, [SELECT Id, Name, Site, Phone, BillingState, ShippingState FROM Account WHERE Name = '株式会社テスト商事' LIMIT 1].Site);
    System.assertEquals(null, [SELECT Id, Name, Site, Phone, BillingState, ShippingState FROM Account WHERE Name = '株式会社 テスト商事運輸' LIMIT 1].Site);
    System.assertEquals(null, [SELECT Id, Name, Site, Phone, BillingState, ShippingState FROM Account WHERE Name = '有限会社 テスト商事' LIMIT 1].Site);

  }

  // SV_DEV-1638 自動連携の取引先検索で取引先名完全一致の取引先があればあいまい検索一致の取引先があっても重複にしないようにする
  // 中間一致で複数該当するが、完全一致がなし
  @isTest
  static void test_Renkei_ManyAccounts_FullMatchNo() {
    // 会社名は法人格を除いて部分一致
    NameCardBasicSetting__c bs = [SELECT Id, RenkeiExcludeHojinkakuPartial__c, RenkeiExcludeHojinkaku__c FROM NameCardBasicSetting__c LIMIT 1];
    bs.RenkeiExcludeHojinkakuPartial__c = true;      // 自動連携:会社名は法人格を除いて部分一致
    bs.RenkeiExcludeHojinkaku__c = false;      // 自動連携:会社名は法人格を除いて完全一致
    update bs;

    List<Account> acnts = new List<Account>();
    acnts.add(new Account(Name='テスト商事株式会社'));
    acnts.add(new Account(Name='株式会社 テスト商事運輸'));
    acnts.add(new Account(Name='有限会社 テスト商事'));
    insert acnts;
    System.assertEquals(null, [SELECT Id, Name, Site, Phone, BillingState, ShippingState FROM Account WHERE Name = 'テスト商事株式会社' LIMIT 1].Site);
    System.assertEquals(null, [SELECT Id, Name, Site, Phone, BillingState, ShippingState FROM Account WHERE Name = '株式会社 テスト商事運輸' LIMIT 1].Site);
    System.assertEquals(null, [SELECT Id, Name, Site, Phone, BillingState, ShippingState FROM Account WHERE Name = '有限会社 テスト商事' LIMIT 1].Site);

    Test.startTest();
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社テスト商事', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='一郎', email__c='ichiro@test.com', delivery_type__c='2'));

    insert listCard;
    Test.stopTest();

    System.assertEquals(null, [SELECT Id, Name, Site, Phone, BillingState, ShippingState FROM Account WHERE Name = 'テスト商事株式会社' LIMIT 1].Site);
    System.assertEquals(null, [SELECT Id, Name, Site, Phone, BillingState, ShippingState FROM Account WHERE Name = '株式会社 テスト商事運輸' LIMIT 1].Site);
    System.assertEquals(null, [SELECT Id, Name, Site, Phone, BillingState, ShippingState FROM Account WHERE Name = '有限会社 テスト商事' LIMIT 1].Site);

  }

  // SV_DEV-893 【自動連携】1次納品段階で登録した活動履歴を取引先・取引先責任者に引き継ぎたい
  // 引き継ぐ設定
  @isTest
  static void test_Renkei_Acitivity_TakeOver_On() {
    // 会社名は法人格を除いて部分一致
    NameCardBasicSetting__c bs = [SELECT Id, RenkeiInheritEvent__c FROM NameCardBasicSetting__c LIMIT 1];
    bs.RenkeiInheritEvent__c = true;      // 自動連携:名刺の活動履歴を引き継ぐ
    update bs;

    List<Account> acnts = new List<Account>();
    acnts.add(new Account(Name='株式会社テスト商事'));
    insert acnts;

    Test.startTest();
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社テスト商事', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='一郎', email__c='ichiro@test.com', delivery_type__c='1'));
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='（株）サンプル物産', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-5555-5555', tel2__c = '03-6666-6666', // 電話番号
                    last_name__c='テスト', first_name__c='一郎', email__c='ichiro@sample.com', delivery_type__c='1'));

    insert listCard;
    listCard = [SELECT Id, Name, OwnerId FROM NameCard__c WHERE delivery_type__c='1'];
    // 名刺にToDoをつける
    List<Task> listTask = new List<Task>();
    for (NameCard__c card : listCard) {
      listTask.add(new Task(Subject=card.Name + 'task', OwnerId=card.OwnerId, whatId=card.Id));
    }
    insert listTask;

    // 名刺に行動をつける
    List<Event> listEvent = new List<Event>();
    for (NameCard__c card : listCard) {
      listEvent.add(new Event(Subject=card.Name + 'event', OwnerId=card.OwnerId
        , IsAllDayEvent=true, ActivityDate=date.today(), whatId=card.Id));
    }
    insert listEvent;

    listCard = [SELECT Id, delivery_type__c FROM NameCard__c WHERE delivery_type__c='1'];
    for (NameCard__c card : listCard) {
      card.delivery_type__c = '2';
    }
    update listCard;

    Test.stopTest();

    System.assertEquals(1, [SELECT Id FROM Task WHERE WhoId IN (SELECT Id FROM Contact WHERE Account.Name='株式会社テスト商事')].size());
    System.assertEquals(1, [SELECT Id FROM Event WHERE WhoId IN (SELECT Id FROM Contact WHERE Account.Name='株式会社テスト商事')].size());
    System.assertEquals(1, [SELECT Id FROM Task WHERE WhoId IN (SELECT Id FROM Contact WHERE Account.Name='（株）サンプル物産')].size());
    System.assertEquals(1, [SELECT Id FROM Event WHERE WhoId IN (SELECT Id FROM Contact WHERE Account.Name='（株）サンプル物産')].size());

  }

  // SV_DEV-893 【自動連携】1次納品段階で登録した活動履歴を取引先・取引先責任者に引き継ぎたい
  // 引き継がない設定
  @isTest
  static void test_Renkei_Acitivity_TakeOver_Off() {
    // 会社名は法人格を除いて部分一致
    NameCardBasicSetting__c bs = [SELECT Id, RenkeiInheritEvent__c FROM NameCardBasicSetting__c LIMIT 1];
    bs.RenkeiInheritEvent__c = false;      // 自動連携:名刺の活動履歴を引き継ぐ
    update bs;

    List<Account> acnts = new List<Account>();
    acnts.add(new Account(Name='株式会社テスト商事'));
    insert acnts;

    Test.startTest();
    // 名刺 挿入
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社テスト商事', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='一郎', email__c='ichiro@test.com', delivery_type__c='1'));
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='（株）サンプル物産', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-5555-5555', tel2__c = '03-6666-6666', // 電話番号
                    last_name__c='テスト', first_name__c='一郎', email__c='ichiro@sample.com', delivery_type__c='1'));

    insert listCard;
    listCard = [SELECT Id, Name, OwnerId FROM NameCard__c WHERE delivery_type__c='1'];
    // 名刺にToDoをつける
    List<Task> listTask = new List<Task>();
    for (NameCard__c card : listCard) {
      listTask.add(new Task(Subject=card.Name + 'task', OwnerId=card.OwnerId, whatId=card.Id));
    }
    insert listTask;

    // 名刺に行動をつける
    List<Event> listEvent = new List<Event>();
    for (NameCard__c card : listCard) {
      listEvent.add(new Event(Subject=card.Name + 'event', OwnerId=card.OwnerId
        , IsAllDayEvent=true, ActivityDate=date.today(), whatId=card.Id));
    }
    insert listEvent;

    listCard = [SELECT Id, delivery_type__c FROM NameCard__c WHERE delivery_type__c='1'];
    for (NameCard__c card : listCard) {
      card.delivery_type__c = '2';
    }
    update listCard;

    Test.stopTest();

    System.assertEquals(0, [SELECT Id FROM Task WHERE WhoId IN (SELECT Id FROM Contact WHERE Account.Name='株式会社テスト商事')].size());
    System.assertEquals(0, [SELECT Id FROM Event WHERE WhoId IN (SELECT Id FROM Contact WHERE Account.Name='株式会社テスト商事')].size());
    System.assertEquals(0, [SELECT Id FROM Task WHERE WhoId IN (SELECT Id FROM Contact WHERE Account.Name='（株）サンプル物産')].size());
    System.assertEquals(0, [SELECT Id FROM Event WHERE WhoId IN (SELECT Id FROM Contact WHERE Account.Name='（株）サンプル物産')].size());

  }

}