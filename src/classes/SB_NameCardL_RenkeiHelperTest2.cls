/**
 *
 *  SB_NameCardL_RenkeiHelperTest2
 *    SB_NameCardL_RenkeiHelperTest に加えて キャンペンメンバー化のあるテスト
 *    トリガハンドラ SB_NameCardL_RenkeiTriggerHandler のテストでもある。
 *
 * Copyright (C) 2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  lx 2.0    2018.06.xx
 *
 **/
@isTest
private class SB_NameCardL_RenkeiHelperTest2
{

  public virtual class TestDb extends SB_NCL_TestDB {

    // アカウント
    public override void initializeAccount() {
      listAccount.add(new Account(Name='サンブリッジ株式会社', Site='開発部'));
      listAccount.add(new Account(Name='目黒商事株式会社', Site='営業部'));
    }

    //　コンタクト
    public override void initializeContact() {
      listContact.add(new Contact(AccountId=listAccount[0].Id, FirstName='太郎', LastName='恵比寿', Title='課長', Email='user01@sunbridge.com'));
      listContact.add(new Contact(AccountId=listAccount[1].Id, FirstName='次郎', LastName='不動前', Title='部長', Email='user01@meguro.co.jp'));
    }

    public override void initializeLead() {
      listLead.add(new Lead(Company='サンブリッジ株式会社', FirstName='太郎', LastName='恵比寿', Title='課長', Email='user01@sunbridge.com'));
      listLead.add(new Lead(Company='目黒商事株式会社', FirstName='次郎', LastName='不動前', Title='部長', Email='user01@meguro.co.jp'));
    }

    public void initializeCampaignMember() {
      listCampaignMember.add(new CampaignMember(CampaignId=listCampaign[0].Id, LeadId=listLead[0].Id, Status = SB_NameCardL_Util.getDefaultCampaignStatus()));
      listCampaignMember.add(new CampaignMember(CampaignId=listCampaign[0].Id, LeadId=listLead[1].Id, Status = SB_NameCardL_Util.getDefaultCampaignStatus()));
    }

    //  名刺を追加
    public void initializeNameCard(String delivery_type) {
      listCard.add(new SmartViscaf__NameCard__c(
              Name = '恵比寿 太郎'
              , SmartViscaf__person_name_last__c = '恵比寿'
              , SmartViscaf__person_name_first__c = '太郎'
              , SmartViscaf__last_name__c = null
              , SmartViscaf__first_name__c = null
              , SmartViscaf__email__c = 'user01@sunbridge.com'
              , SmartViscaf__company_name__c= 'サンブリッジ株式会社'
              , SmartViscaf__division__c = '開発部'
              , SmartViscaf__title_name__c = '課長'
              , campaign__c = listCampaign[0].Id
              , SmartViscaf__delivery_type__c = delivery_type));
      listCard.add(new SmartViscaf__NameCard__c(
              Name = '不動前 次郎'
              , SmartViscaf__person_name_last__c = '不動前'
              , SmartViscaf__person_name_first__c = '次郎'
              , SmartViscaf__last_name__c = null
              , SmartViscaf__first_name__c = null
              , SmartViscaf__email__c = 'user01@meguro.co.jp'
              , SmartViscaf__company_name__c= '目黒商事株式会社'
              , SmartViscaf__division__c = '営業部'
              , SmartViscaf__title_name__c = '部長'
              , campaign__c = listCampaign[0].Id
              , SmartViscaf__delivery_type__c = delivery_type));
    }

    // 初期データ作成  他に影響のないものだけ
    public override void initialize() {
      // ユーザ
      initializeUser();
      if (listUser.isEmpty() == false)
        insert listUser;

      // キャンペーン
      initializeCampaign();
      if (listCampaign.isEmpty() == false) {
          insert listCampaign;
      }
    }
    //　カスタム設定
    public void createSmartViscaConfig() {
      initializeSmartViscaConfig();
      if (svConfig !=null) {
        upsert svConfig;
      }
    }

    // 名刺連携項目マッピング (基本設定のあとに作る)
    public void createMapping() {
      initializeMapping();
      if (!listMapping.isEmpty()) {
        insert listMapping;
      }
    }
    //　アカウント
    public void createAccount() {
      initializeAccount();
      if (listAccount.isEmpty() == false) {
        insert listAccount;
      }
    }
    //　コンタクト
    public void createContact() {
      initializeContact();
      if (listContact.isEmpty() == false) {
        insert listContact;
      }
    }
    // リード
    public void createLead() {
      initializeLead();
      if (listLead.isEmpty() == false) {
        insert listLead;
      }
    }
    // キャンペーンメンバー
    public void createCampaignMember() {
      initializeCampaignMember();
      if (listCampaignMember.isEmpty() == false) {
        insert listCampaignMember;
      }
    }
    // 名刺
    public void createNameCard(String delivery_type) {
      initializeNameCard(delivery_type);
      if (listCard.isEmpty() == false) {
        insert listCard;
      }
    }

  } // class TestDb


  //private static final String NMAECARD_FIELDS = 'Id, Name, SmartViscaf__name_kana__c, SmartViscaf__person_name_last__c, SmartViscaf__person_name_first__c, SmartViscaf__last_name__c, SmartViscaf__first_name__c' +
  //  ', SmartViscaf__company_name__c, SmartViscaf__company_name_kana__c, SmartViscaf__division__c, SmartViscaf__division_name__c, SmartViscaf__title_name__c' +
  //  ', SmartViscaf__zip_code__c, SmartViscaf__address_pref__c, SmartViscaf__address__c, SmartViscaf__address_bld__c, SmartViscaf__address_eng__c' +
  //  ', SmartViscaf__card_exchange_date__c, SmartViscaf__list_name__c, OwnerId, Owner.Name, SmartViscaf__Parent__c, SmartViscaf__tenshokugonomeishi__c, SmartViscaf__account__c, SmartViscaf__contact__c' +
  //  ', SmartViscaf__lead__c, campaign__c' +
  //  ', SmartViscaf__freehandmemo__c, SmartViscaf__memo__c, SmartViscaf__web_url1__c, SmartViscaf__email__c, SmartViscaf__tel1__c, SmartViscaf__tel2__c, SmartViscaf__mobile__c, SmartViscaf__fax1__c' +
  //  ', SmartViscaf__image_id__c, SmartViscaf__bk_image_id__c, SmartViscaf__width__c, SmartViscaf__height__c, SmartViscaf__bk_width__c, SmartViscaf__bk_height__c' +
  //  ', SmartViscaf__RenkeiMessage__c' +    // 2017.04.xx
  //  ', SmartViscaf__isNotOverwrite__c, SmartViscaf__isNotOverContactwrite__c';

  ///////////////////////////////
  // 　リード連携は有効で、 リードが出来てキャンペーンメンバーになる。
  @isTest
  static void test_createLead_Campaign() {
    // SmartVisca設定
    SmartViscaf__SmartViscaConfig__c svConfig = SmartViscaf__SmartViscaConfig__c.getOrgDefaults();
    svConfig.SmartViscaf__TriggerLeadExRenkeiTriggerHandler__c = true; // 2018.03.xx v1.22  Lead連携拡張パッケージの中にある 自動連携のトリガハンドラを呼ぶ
    // Lead 拡張パッケージ v2.0 からの項目
    svConfig.RenkeiCreateContactOnAcountWithoutLead__c = false; // デフォルト false 統合版自動連携:リードなく、取引先既存で取引先責任者を作成する
    svConfig.RenkeiCreateContactOnAcountWithLead__c = false;  // デフォルト false 統合版自動連携:リード、取引先既存で取引先責任者を作成する
    svConfig.RenkeiCreateLeadOnTooManyAccounts__c = false;  // デフォルト false 統合版自動連携: 既存取引先が複数あり特定できないとき、リードを作る。
    svConfig.RenkeiContactToCampaignMember__c = false;  // デフォルト false 統合版自動連携: 取引先責任者もキャンペーンメンバーにする。
    svConfig.RenkeiUpdateToCampaignMember__c = false; // デフォルト false 統合版自動連携: 更新でもキャンペーンメンバーにする。
    svConfig.RenkeiUpdateAllLeadsOnCondition__c = true; // デフォルト true 統合版自動連携:条件に合致する既存リードは全て更新する。
    upsert svConfig;

    // 名刺基本設定
    SmartViscaf__NameCardBasicSetting__c bs = SmartViscaf.SB_NC_PostInstallScript.createDefaultBasicSetting();
    bs.SmartViscaf__RenkeiActive__c = true;      // 自動連携機能有効
    bs.SmartViscaf__RenkeiLeadActive__c = true; // リード連携を有効化
    bs.SmartViscaf__RenkeiActiveCampaignMember__c = true; // キャンペンメンバー
    bs.SmartViscaf__RenkeiCampaignStatus__c = SB_NameCardL_Util.getDefaultCampaignStatus(); // キャンペーンメンバーの状況
    bs.SmartViscaf__RenkeiAccountOverwrite__c = true;   // 既存の取引先を上書き
    bs.SmartViscaf__RenkeiContactOverwrite__c = true;   // 既存の取引先責任者を上書き
    bs.SmartViscaf__RenkeiLeadOverwrite__c = true;   // 既存のリードを上書き
    insert bs;
    TestDb db = new TestDb();
    db.initialize();
    db.createMapping();
    db.createAccount();
    db.createNameCard('1');

    List<SmartViscaf__NameCard__c> cards = Database.query('SELECT Id, Name, SmartViscaf__email__c, SmartViscaf__delivery_type__c FROM SmartViscaf__NameCard__c');
    Set<String> emails = new Set<String>();
    for (SmartViscaf__NameCard__c c : cards) {
      emails.add(c.SmartViscaf__email__c);
      c.SmartViscaf__delivery_type__c = '2';
    }
    Test.startTest();
    // 納品 2 に、更新
    update cards;
    Test.stopTest();

    System.assertEquals(2, emails.size());
    //SB_NameCardL_RenkeiHelper.doRenkei(cards, SB_NameCardL_RenkeiHelper.ProcType.LEAD);
    // リードができてる
    List<Lead> leads = [SELECT Id, Name, Email, Company, FirstName, LastName FROM Lead WHERE Email IN :emails];
    System.assertEquals(2, leads.size());
    //　コンタクトはできてない。
    List<Contact> conts = [SELECT Id, Name, Email, Account.Name, FirstName, LastName FROM Contact WHERE Email IN :emails];
    System.assertEquals(0, conts.size());
    //　リードはキャンペンメンバーになってる。
    List<CampaignMember> cms = [SELECT Id, CampaignId, LeadId, ContactId, FirstName, LastName, Status FROM CampaignMember WHERE LeadId != null];
    System.assertEquals(leads.size(), cms.size());
    //for (SmartViscaf__NameCard__c card :cards) {
    //  System.assertEquals(null, card.SmartViscaf__lead__c);
    //}
  }


  // 　リード連携は有効で、 リードが出来てキャンペーンメンバーになる。 最初から納品 2
  @isTest
  static void test_createLead_Campaign_delivery2() {
    // SmartVisca設定
    SmartViscaf__SmartViscaConfig__c svConfig = SmartViscaf__SmartViscaConfig__c.getOrgDefaults();
    svConfig.SmartViscaf__TriggerLeadExRenkeiTriggerHandler__c = true; // 2018.03.xx v1.22  Lead連携拡張パッケージの中にある 自動連携のトリガハンドラを呼ぶ
    // Lead 拡張パッケージ v2.0 からの項目
    svConfig.RenkeiCreateContactOnAcountWithoutLead__c = false; // デフォルト false 統合版自動連携:リードなく、取引先既存で取引先責任者を作成する
    svConfig.RenkeiCreateContactOnAcountWithLead__c = false;  // デフォルト false 統合版自動連携:リード、取引先既存で取引先責任者を作成する
    svConfig.RenkeiCreateLeadOnTooManyAccounts__c = false;  // デフォルト false 統合版自動連携: 既存取引先が複数あり特定できないとき、リードを作る。
    svConfig.RenkeiContactToCampaignMember__c = false;  // デフォルト false 統合版自動連携: 取引先責任者もキャンペーンメンバーにする。
    svConfig.RenkeiUpdateToCampaignMember__c = false; // デフォルト false 統合版自動連携: 更新でもキャンペーンメンバーにする。
    svConfig.RenkeiUpdateAllLeadsOnCondition__c = true; // デフォルト true 統合版自動連携:条件に合致する既存リードは全て更新する。
    upsert svConfig;

    // 名刺基本設定
    SmartViscaf__NameCardBasicSetting__c bs = SmartViscaf.SB_NC_PostInstallScript.createDefaultBasicSetting();
    bs.SmartViscaf__RenkeiActive__c = true;      // 自動連携機能有効
    bs.SmartViscaf__RenkeiLeadActive__c = true; // リード連携を有効化
    bs.SmartViscaf__RenkeiActiveCampaignMember__c = true; // キャンペンメンバー
    bs.SmartViscaf__RenkeiCampaignStatus__c = SB_NameCardL_Util.getDefaultCampaignStatus(); // キャンペーンメンバーの状況
    bs.SmartViscaf__RenkeiAccountOverwrite__c = true;   // 既存の取引先を上書き
    bs.SmartViscaf__RenkeiContactOverwrite__c = true;   // 既存の取引先責任者を上書き
    bs.SmartViscaf__RenkeiLeadOverwrite__c = true;   // 既存のリードを上書き
    insert bs;
    TestDb db = new TestDb();
    db.initialize();
    db.createMapping();
    db.createAccount();
    Test.startTest();
    db.createNameCard('2');
    Test.stopTest();

    List<SmartViscaf__NameCard__c> cards = Database.query('SELECT Id, Name, SmartViscaf__email__c, SmartViscaf__delivery_type__c FROM SmartViscaf__NameCard__c');
    Set<String> emails = new Set<String>();
    for (SmartViscaf__NameCard__c c : cards) {
      emails.add(c.SmartViscaf__email__c);
    }
    System.assertEquals(2, emails.size());
    //SB_NameCardL_RenkeiHelper.doRenkei(cards, SB_NameCardL_RenkeiHelper.ProcType.LEAD);
    // リードができてる
    List<Lead> leads = [SELECT Id, Name, Email, Company, FirstName, LastName FROM Lead WHERE Email IN :emails];
    System.assertEquals(2, leads.size());
    //　コンタクトはできてない。
    List<Contact> conts = [SELECT Id, Name, Email, Account.Name, FirstName, LastName FROM Contact WHERE Email IN :emails];
    System.assertEquals(0, conts.size());
    //　リードはキャンペンメンバーになってる。
    List<CampaignMember> cms = [SELECT Id, CampaignId, LeadId, ContactId, FirstName, LastName, Status FROM CampaignMember WHERE LeadId != null];
    System.assertEquals(leads.size(), cms.size());
    //for (SmartViscaf__NameCard__c card :cards) {
    //  System.assertEquals(null, card.SmartViscaf__lead__c);
    //}
  }

  // 　リード連携は有効で、 リードでなくコンタクトが出来てキャンペーンメンバーになる。 最初から納品 2
  @isTest
  static void test_createContact_Campaign() {
    SmartViscaf__SmartViscaConfig__c svConfig = SmartViscaf__SmartViscaConfig__c.getOrgDefaults();
    svConfig.SmartViscaf__TriggerLeadExRenkeiTriggerHandler__c = true; // 2018.03.xx v1.22  Lead連携拡張パッケージの中にある 自動連携のトリガハンドラを呼ぶ
    // Lead 拡張パッケージ v2.0 からの項目
    svConfig.RenkeiCreateContactOnAcountWithoutLead__c = true; // デフォルト false 統合版自動連携:リードなく、取引先既存で取引先責任者を作成する
    svConfig.RenkeiCreateContactOnAcountWithLead__c = false;  // デフォルト false 統合版自動連携:リード、取引先既存で取引先責任者を作成する
    svConfig.RenkeiCreateLeadOnTooManyAccounts__c = false;  // デフォルト false 統合版自動連携: 既存取引先が複数あり特定できないとき、リードを作る。
    svConfig.RenkeiContactToCampaignMember__c = true;  // デフォルト false 統合版自動連携: 取引先責任者もキャンペーンメンバーにする。
    svConfig.RenkeiUpdateToCampaignMember__c = false; // デフォルト false 統合版自動連携: 更新でもキャンペーンメンバーにする。
    svConfig.RenkeiUpdateAllLeadsOnCondition__c = true; // デフォルト true 統合版自動連携:条件に合致する既存リードは全て更新する。
    upsert svConfig;
    // 名刺基本設定
    SmartViscaf__NameCardBasicSetting__c bs = SmartViscaf.SB_NC_PostInstallScript.createDefaultBasicSetting();
    bs.SmartViscaf__RenkeiActive__c = true;      // 自動連携機能有効
    bs.SmartViscaf__RenkeiLeadActive__c = true; // リード連携を有効化
    bs.SmartViscaf__RenkeiActiveCampaignMember__c = true; // キャンペンメンバー
    bs.SmartViscaf__RenkeiCampaignStatus__c = SB_NameCardL_Util.getDefaultCampaignStatus(); // キャンペーンメンバーの状況
    bs.SmartViscaf__RenkeiAccountOverwrite__c = true;   // 既存の取引先を上書き
    bs.SmartViscaf__RenkeiContactOverwrite__c = true;   // 既存の取引先責任者を上書き
    bs.SmartViscaf__RenkeiLeadOverwrite__c = true;   // 既存のリードを上書き
    insert bs;
    TestDb db = new TestDb();
    db.initialize();
    db.createMapping();
    db.createAccount();

    Test.startTest();
    db.createNameCard('2');
    Test.stopTest();

    List<SmartViscaf__NameCard__c> cards = Database.query('SELECT Id, Name, SmartViscaf__email__c, SmartViscaf__delivery_type__c FROM SmartViscaf__NameCard__c');
    Set<String> emails = new Set<String>();
    for (SmartViscaf__NameCard__c c : cards) {
      emails.add(c.SmartViscaf__email__c);
    }
    System.assertEquals(2, emails.size());
    //SB_NameCardL_RenkeiHelper.doRenkei(cards, SB_NameCardL_RenkeiHelper.ProcType.LEAD);
    // リードができてる
    List<Lead> leads = [SELECT Id, Name, Email, Company, FirstName, LastName FROM Lead WHERE Email IN :emails];
    //System.assertEquals(emails.size(), leads.size());
    System.assertEquals(0, leads.size());
    //　コンタクトはできてない。
    List<Contact> conts = [SELECT Id, Name, Email, Account.Name, FirstName, LastName FROM Contact WHERE Email IN :emails];
    System.assertEquals(2, conts.size());
    //　リードはキャンペンメンバーになってる。
    List<CampaignMember> cms = [SELECT Id, CampaignId, LeadId, ContactId, FirstName, LastName, Status FROM CampaignMember WHERE LeadId != null OR ContactId != null];
    System.assertEquals(conts.size(), cms.size());
  }

  // 　リード連携は有効で、 リードが既存で更新して、すでにキャンペーンメンバーなので、キャンペーンメンバーの追加はなし
  @isTest
  static void test_updateLead_NoCampaignMember() {
    // SmartVisca設定
    SmartViscaf__SmartViscaConfig__c svConfig = SmartViscaf__SmartViscaConfig__c.getOrgDefaults();
    svConfig.SmartViscaf__TriggerLeadExRenkeiTriggerHandler__c = true; // 2018.03.xx v1.22  Lead連携拡張パッケージの中にある 自動連携のトリガハンドラを呼ぶ
    // Lead 拡張パッケージ v2.0 からの項目
    svConfig.RenkeiCreateContactOnAcountWithoutLead__c = false; // デフォルト false 統合版自動連携:リードなく、取引先既存で取引先責任者を作成する
    svConfig.RenkeiCreateContactOnAcountWithLead__c = false;  // デフォルト false 統合版自動連携:リード、取引先既存で取引先責任者を作成する
    svConfig.RenkeiCreateLeadOnTooManyAccounts__c = false;  // デフォルト false 統合版自動連携: 既存取引先が複数あり特定できないとき、リードを作る。
    svConfig.RenkeiContactToCampaignMember__c = false;  // デフォルト false 統合版自動連携: 取引先責任者もキャンペーンメンバーにする。
    svConfig.RenkeiUpdateToCampaignMember__c = false; // デフォルト false 統合版自動連携: 更新でもキャンペーンメンバーにする。
    svConfig.RenkeiUpdateAllLeadsOnCondition__c = true; // デフォルト true 統合版自動連携:条件に合致する既存リードは全て更新する。
    upsert svConfig;

    // 名刺基本設定
    SmartViscaf__NameCardBasicSetting__c bs = SmartViscaf.SB_NC_PostInstallScript.createDefaultBasicSetting();
    bs.SmartViscaf__RenkeiActive__c = true;      // 自動連携機能有効
    bs.SmartViscaf__RenkeiLeadActive__c = true; // リード連携を有効化
    bs.SmartViscaf__RenkeiActiveCampaignMember__c = true; // キャンペンメンバー
    bs.SmartViscaf__RenkeiCampaignStatus__c = SB_NameCardL_Util.getDefaultCampaignStatus(); // キャンペーンメンバーの状況
    bs.SmartViscaf__RenkeiAccountOverwrite__c = true;   // 既存の取引先を上書き
    bs.SmartViscaf__RenkeiContactOverwrite__c = true;   // 既存の取引先責任者を上書き
    bs.SmartViscaf__RenkeiLeadOverwrite__c = true;   // 既存のリードを上書き
    insert bs;
    TestDb db = new TestDb();
    db.initialize();
    db.createMapping();
    db.createLead();
    db.createCampaignMember();
    Test.startTest();
    db.createNameCard('2');
    Test.stopTest();

    List<SmartViscaf__NameCard__c> cards = Database.query('SELECT Id, Name, SmartViscaf__email__c, SmartViscaf__delivery_type__c FROM SmartViscaf__NameCard__c');
    Set<String> emails = new Set<String>();
    for (SmartViscaf__NameCard__c c : cards) {
      emails.add(c.SmartViscaf__email__c);
    }
    System.assertEquals(2, emails.size());
    //SB_NameCardL_RenkeiHelper.doRenkei(cards, SB_NameCardL_RenkeiHelper.ProcType.LEAD);
    // リードができてる
    List<Lead> leads = [SELECT Id, Name, Email, Company, FirstName, LastName FROM Lead WHERE Email IN :emails];
    System.assertEquals(2, leads.size());
    //　コンタクトはできてない。
    List<Contact> conts = [SELECT Id, Name, Email, Account.Name, FirstName, LastName FROM Contact WHERE Email IN :emails];
    System.assertEquals(0, conts.size());
    //　リードはキャンペンメンバーになってる。
    List<CampaignMember> cms = [SELECT Id, CampaignId, LeadId, ContactId, FirstName, LastName, Status FROM CampaignMember WHERE LeadId != null];
    System.assertEquals(leads.size(), cms.size());
    //for (SmartViscaf__NameCard__c card :cards) {
    //  System.assertEquals(null, card.SmartViscaf__lead__c);
    //}
  }

  //　リード連携は有効で、 アカウントが既存でコンタクトを作成、かつ リードが既存で紐づけて、それぞれキャンペンメンバーにする。
  @isTest
  static void test_updateLead_Campaign() {
    SmartViscaf__SmartViscaConfig__c svConfig = SmartViscaf__SmartViscaConfig__c.getOrgDefaults();
    svConfig.SmartViscaf__TriggerLeadExRenkeiTriggerHandler__c = true; // 2018.03.xx v1.22  Lead連携拡張パッケージの中にある 自動連携のトリガハンドラを呼ぶ
    // Lead 拡張パッケージ v2.0 からの項目
    svConfig.RenkeiCreateContactOnAcountWithoutLead__c = true; // デフォルト false 統合版自動連携:リードなく、取引先既存で取引先責任者を作成する
    svConfig.RenkeiCreateContactOnAcountWithLead__c = true;  // デフォルト false 統合版自動連携:リード、取引先既存で取引先責任者を作成する
    svConfig.RenkeiCreateLeadOnTooManyAccounts__c = false;  // デフォルト false 統合版自動連携: 既存取引先が複数あり特定できないとき、リードを作る。
    svConfig.RenkeiContactToCampaignMember__c = true;  // デフォルト false 統合版自動連携: 取引先責任者もキャンペーンメンバーにする。
    svConfig.RenkeiUpdateToCampaignMember__c = true; // デフォルト false 統合版自動連携: 更新でもキャンペーンメンバーにする。
    svConfig.RenkeiUpdateAllLeadsOnCondition__c = true; // デフォルト true 統合版自動連携:条件に合致する既存リードは全て更新する。
    upsert svConfig;
    // 名刺基本設定
    SmartViscaf__NameCardBasicSetting__c bs = SmartViscaf.SB_NC_PostInstallScript.createDefaultBasicSetting();
    bs.SmartViscaf__RenkeiActive__c = true;      // 自動連携機能有効
    bs.SmartViscaf__RenkeiLeadActive__c = true; // リード連携を有効化
    bs.SmartViscaf__RenkeiActiveCampaignMember__c = true; // キャンペンメンバー
    bs.SmartViscaf__RenkeiCampaignStatus__c = SB_NameCardL_Util.getDefaultCampaignStatus(); // キャンペーンメンバーの状況
    bs.SmartViscaf__RenkeiAccountOverwrite__c = true;   // 既存の取引先を上書き
    bs.SmartViscaf__RenkeiContactOverwrite__c = true;   // 既存の取引先責任者を上書き
    bs.SmartViscaf__RenkeiLeadOverwrite__c = true;   // 既存のリードを上書き
    insert bs;
    TestDb db = new TestDb();
    db.initialize();
    db.createMapping();
    db.createAccount();
    db.createLead();

    Test.startTest();
    db.createNameCard('2');
    Test.stopTest();

    List<SmartViscaf__NameCard__c> cards = Database.query('SELECT Id, Name, SmartViscaf__email__c, SmartViscaf__delivery_type__c FROM SmartViscaf__NameCard__c');
    Set<String> emails = new Set<String>();
    for (SmartViscaf__NameCard__c c : cards) {
      emails.add(c.SmartViscaf__email__c);
    }
    System.assertEquals(2, emails.size());
    //SB_NameCardL_RenkeiHelper.doRenkei(cards, SB_NameCardL_RenkeiHelper.ProcType.LEAD);
    // リードを更新してる。
    List<Lead> leads = [SELECT Id, Name, Email, Company, FirstName, LastName FROM Lead WHERE Email IN :emails];
    System.assertEquals(2, leads.size());
    //　コンタクトを作ってる。
    List<Contact> conts = [SELECT Id, Name, Email, Account.Name, FirstName, LastName FROM Contact WHERE Email IN :emails];
    //System.assertEquals(emails.size(), conts.size());
    System.assertEquals(2, conts.size());
    //　リード、コンタクトはキャンペンメンバーになってる。
    List<CampaignMember> cms = [SELECT Id, CampaignId, LeadId, ContactId, FirstName, LastName, Status FROM CampaignMember WHERE LeadId != null OR ContactId != null];
    System.assertEquals(cms.size(), leads.size() + conts.size());
  }


  //　リード連携は有効で、 アカウントが既存でコンタクトを作成せず、リードが既存だが複数なので紐付けない、コンタクトをキャンペンメンバーにする。
  @isTest
  static void test_ignoreLead_Duplicate() {
    SmartViscaf__SmartViscaConfig__c svConfig = SmartViscaf__SmartViscaConfig__c.getOrgDefaults();
    svConfig.SmartViscaf__TriggerLeadExRenkeiTriggerHandler__c = true; // 2018.03.xx v1.22  Lead連携拡張パッケージの中にある 自動連携のトリガハンドラを呼ぶ
    // Lead 拡張パッケージ v2.0 からの項目
    svConfig.RenkeiCreateContactOnAcountWithoutLead__c = false; // デフォルト false 統合版自動連携:リードなく、取引先既存で取引先責任者を作成する
    svConfig.RenkeiCreateContactOnAcountWithLead__c = false;  // デフォルト false 統合版自動連携:リード、取引先既存で取引先責任者を作成する
    svConfig.RenkeiCreateLeadOnTooManyAccounts__c = false;  // デフォルト false 統合版自動連携: 既存取引先が複数あり特定できないとき、リードを作る。
    svConfig.RenkeiContactToCampaignMember__c = false;  // デフォルト false 統合版自動連携: 取引先責任者もキャンペーンメンバーにする。
    svConfig.RenkeiUpdateToCampaignMember__c = false; // デフォルト false 統合版自動連携: 更新でもキャンペーンメンバーにする。
    svConfig.RenkeiUpdateAllLeadsOnCondition__c = true; // デフォルト true 統合版自動連携:条件に合致する既存リードは全て更新する。
    upsert svConfig;
    // 名刺基本設定
    SmartViscaf__NameCardBasicSetting__c bs = SmartViscaf.SB_NC_PostInstallScript.createDefaultBasicSetting();
    bs.SmartViscaf__RenkeiActive__c = true;      // 自動連携機能有効
    bs.SmartViscaf__RenkeiLeadActive__c = true; // リード連携を有効化
    bs.SmartViscaf__RenkeiActiveCampaignMember__c = true; // キャンペンメンバー
    bs.SmartViscaf__RenkeiCampaignStatus__c = SB_NameCardL_Util.getDefaultCampaignStatus(); // キャンペーンメンバーの状況
    bs.SmartViscaf__RenkeiAccountOverwrite__c = true;   // 既存の取引先を上書き
    bs.SmartViscaf__RenkeiContactOverwrite__c = true;   // 既存の取引先責任者を上書き
    bs.SmartViscaf__RenkeiLeadOverwrite__c = true;   // 既存のリードを上書き
    insert bs;
    TestDb db = new TestDb();
    db.initialize();
    db.createMapping();
    db.createAccount();
    db.createLead();
    // リードを複製する
    List<Lead> newLeads = new List<Lead>();
    for (Lead l : [SELECT Id, Name, Email, Company, FirstName, LastName FROM Lead]) {
      newLeads.add(l.clone());
    }
    // 重複を強行
    Database.DMLOptions dml = new Database.DMLOptions();
    dml.DuplicateRuleHeader.AllowSave = true;
    List<Database.SaveResult> srs = Database.insert(newLeads, dml);

    Test.startTest();
    db.createNameCard('2');
    Test.stopTest();

    List<SmartViscaf__NameCard__c> cards = Database.query('SELECT Id, Name, SmartViscaf__email__c, SmartViscaf__delivery_type__c FROM SmartViscaf__NameCard__c');
    Set<String> emails = new Set<String>();
    for (SmartViscaf__NameCard__c c : cards) {
      emails.add(c.SmartViscaf__email__c);
    }
    System.assertEquals(2, emails.size());
    //SB_NameCardL_RenkeiHelper.doRenkei(cards, SB_NameCardL_RenkeiHelper.ProcType.LEAD);
    // リードを更新してる。
    List<Lead> leads = [SELECT Id, Name, Email, Company, FirstName, LastName FROM Lead WHERE Email IN :emails];
    System.assertEquals(4, leads.size());
    //　コンタクトを作ってる。
    List<Contact> conts = [SELECT Id, Name, Email, Account.Name, FirstName, LastName FROM Contact WHERE Email IN :emails];
    //System.assertEquals(emails.size(), conts.size());
    System.assertEquals(0, conts.size());
    cards = [SELECT Id, Name, SmartViscaf__account__c, SmartViscaf__contact__c, SmartViscaf__lead__c FROM SmartViscaf__NameCard__c
              WHERE SmartViscaf__account__c != null AND SmartViscaf__contact__c != null];
    System.assertEquals(0, cards.size());
    //　リード、コンタクトはキャンペンメンバーになってる。
    List<CampaignMember> cms = [SELECT Id, CampaignId, LeadId, ContactId, FirstName, LastName, Status FROM CampaignMember WHERE LeadId != null OR ContactId != null];
    System.assertEquals(cms.size(), 0);
  }

  // リード連携は無効　で、コンタクトが既存で更新、それをキャンペンメンバーにする。
  @isTest
  static void test_updateContact_Campaign() {
    SmartViscaf__SmartViscaConfig__c svConfig = SmartViscaf__SmartViscaConfig__c.getOrgDefaults();
    svConfig.SmartViscaf__TriggerLeadExRenkeiTriggerHandler__c = true; // 2018.03.xx v1.22  Lead連携拡張パッケージの中にある 自動連携のトリガハンドラを呼ぶ
    // Lead 拡張パッケージ v2.0 からの項目
    svConfig.RenkeiCreateContactOnAcountWithoutLead__c = false; // デフォルト false 統合版自動連携:リードなく、取引先既存で取引先責任者を作成する
    svConfig.RenkeiCreateContactOnAcountWithLead__c = false;  // デフォルト false 統合版自動連携:リード、取引先既存で取引先責任者を作成する
    svConfig.RenkeiCreateLeadOnTooManyAccounts__c = false;  // デフォルト false 統合版自動連携: 既存取引先が複数あり特定できないとき、リードを作る。
    svConfig.RenkeiContactToCampaignMember__c = true;  // デフォルト false 統合版自動連携: 取引先責任者もキャンペーンメンバーにする。
    svConfig.RenkeiUpdateToCampaignMember__c = true; // デフォルト false 統合版自動連携: 更新でもキャンペーンメンバーにする。
    svConfig.RenkeiUpdateAllLeadsOnCondition__c = true; // デフォルト true 統合版自動連携:条件に合致する既存リードは全て更新する。
    upsert svConfig;
    // 名刺基本設定  リード連携は無効　で、 キャンペンメンバー化は有効
    SmartViscaf__NameCardBasicSetting__c bs = SmartViscaf.SB_NC_PostInstallScript.createDefaultBasicSetting();
    bs.SmartViscaf__RenkeiActive__c = true;      // 自動連携機能有効
    bs.SmartViscaf__RenkeiLeadActive__c = false; // リード連携を有効化
    bs.SmartViscaf__RenkeiActiveCampaignMember__c = true; // キャンペンメンバー
    bs.SmartViscaf__RenkeiCampaignStatus__c = SB_NameCardL_Util.getDefaultCampaignStatus(); // キャンペーンメンバーの状況
    bs.SmartViscaf__RenkeiAccountOverwrite__c = true;   // 既存の取引先を上書き
    bs.SmartViscaf__RenkeiContactOverwrite__c = true;   // 既存の取引先責任者を上書き
    bs.SmartViscaf__RenkeiLeadOverwrite__c = true;   // 既存のリードを上書き
    insert bs;
    TestDb db = new TestDb();
    db.initialize();
    db.createMapping();
    db.createAccount();
    db.createContact();

    Test.startTest();
    db.createNameCard('2');
    Test.stopTest();

    List<SmartViscaf__NameCard__c> cards = Database.query('SELECT Id, Name, SmartViscaf__email__c, SmartViscaf__delivery_type__c FROM SmartViscaf__NameCard__c');
    Set<String> emails = new Set<String>();
    for (SmartViscaf__NameCard__c c : cards) {
      emails.add(c.SmartViscaf__email__c);
    }
    System.assertEquals(2, emails.size());
    //SB_NameCardL_RenkeiHelper.doRenkei(cards, SB_NameCardL_RenkeiHelper.ProcType.LEAD);
    // リードを更新してる。
    List<Lead> leads = [SELECT Id, Name, Email, Company, FirstName, LastName FROM Lead WHERE Email IN :emails];
    System.assertEquals(0, leads.size());
    //　コンタクトを作ってる。
    List<Contact> conts = [SELECT Id, Name, Email, Account.Name, FirstName, LastName FROM Contact WHERE Email IN :emails];
    //System.assertEquals(emails.size(), conts.size());
    System.assertEquals(2, conts.size());
    //　リード、コンタクトはキャンペンメンバーになってる。
    List<CampaignMember> cms = [SELECT Id, CampaignId, LeadId, ContactId, FirstName, LastName, Status FROM CampaignMember WHERE LeadId != null OR ContactId != null];
    System.assertEquals(conts.size(), cms.size());
  }


  // リード連携は無効　で、 キャンペンメンバー化は有効 で コンタクトが作成されて、キャンペンメンバーになる。
  @isTest
  static void test_createContact_Campaign_NoLeadRenkei() {
    SmartViscaf__SmartViscaConfig__c svConfig = SmartViscaf__SmartViscaConfig__c.getOrgDefaults();
    svConfig.SmartViscaf__TriggerLeadExRenkeiTriggerHandler__c = true; // 2018.03.xx v1.22  Lead連携拡張パッケージの中にある 自動連携のトリガハンドラを呼ぶ
    // Lead 拡張パッケージ v2.0 からの項目
    svConfig.RenkeiCreateContactOnAcountWithoutLead__c = false; // デフォルト false 統合版自動連携:リードなく、取引先既存で取引先責任者を作成する
    svConfig.RenkeiCreateContactOnAcountWithLead__c = false;  // デフォルト false 統合版自動連携:リード、取引先既存で取引先責任者を作成する
    svConfig.RenkeiCreateLeadOnTooManyAccounts__c = false;  // デフォルト false 統合版自動連携: 既存取引先が複数あり特定できないとき、リードを作る。
    svConfig.RenkeiContactToCampaignMember__c = true;  // デフォルト false 統合版自動連携: 取引先責任者もキャンペーンメンバーにする。
    svConfig.RenkeiUpdateToCampaignMember__c = true; // デフォルト false 統合版自動連携: 更新でもキャンペーンメンバーにする。
    svConfig.RenkeiUpdateAllLeadsOnCondition__c = true; // デフォルト true 統合版自動連携:条件に合致する既存リードは全て更新する。
    upsert svConfig;
    // 名刺基本設定 リード連携は無効　で、 キャンペンメンバー化は有効
    SmartViscaf__NameCardBasicSetting__c bs = SmartViscaf.SB_NC_PostInstallScript.createDefaultBasicSetting();
    bs.SmartViscaf__RenkeiActive__c = true;      // 自動連携機能有効
    bs.SmartViscaf__RenkeiLeadActive__c = false; // リード連携を有効化
    bs.SmartViscaf__RenkeiActiveCampaignMember__c = true; // キャンペンメンバー
    bs.SmartViscaf__RenkeiCampaignStatus__c = SB_NameCardL_Util.getDefaultCampaignStatus(); // キャンペーンメンバーの状況
    bs.SmartViscaf__RenkeiAccountOverwrite__c = true;   // 既存の取引先を上書き
    bs.SmartViscaf__RenkeiContactOverwrite__c = true;   // 既存の取引先責任者を上書き
    bs.SmartViscaf__RenkeiLeadOverwrite__c = true;   // 既存のリードを上書き
    insert bs;
    TestDb db = new TestDb();
    db.initialize();
    db.createMapping();
    db.createAccount();

    Test.startTest();
    db.createNameCard('2');
    Test.stopTest();

    List<SmartViscaf__NameCard__c> cards = Database.query('SELECT Id, Name, SmartViscaf__email__c, SmartViscaf__delivery_type__c FROM SmartViscaf__NameCard__c');
    Set<String> emails = new Set<String>();
    for (SmartViscaf__NameCard__c c : cards) {
      emails.add(c.SmartViscaf__email__c);
    }
    System.assertEquals(2, emails.size());
    //SB_NameCardL_RenkeiHelper.doRenkei(cards, SB_NameCardL_RenkeiHelper.ProcType.LEAD);
    // リードができてる
    List<Lead> leads = [SELECT Id, Name, Email, Company, FirstName, LastName FROM Lead WHERE Email IN :emails];
    //System.assertEquals(emails.size(), leads.size());
    System.assertEquals(0, leads.size());
    //　コンタクトはできてない。
    List<Contact> conts = [SELECT Id, Name, Email, Account.Name, FirstName, LastName FROM Contact WHERE Email IN :emails];
    System.assertEquals(2, conts.size());
    //　リードはキャンペンメンバーになってる。
    List<CampaignMember> cms = [SELECT Id, CampaignId, LeadId, ContactId, FirstName, LastName, Status FROM CampaignMember WHERE LeadId != null OR ContactId != null];
    System.assertEquals(conts.size(), cms.size());
  }



  // リード連携は無効　で、 キャンペンメンバー化は無効 で アカウント、コンタクトが作成されて、キャンペンメンバーにならない
  @isTest
  static void test_createAccountContact_AccountRenkei() {
    // SmartVisca設定
    SmartViscaf__SmartViscaConfig__c svConfig = SmartViscaf__SmartViscaConfig__c.getOrgDefaults();
    svConfig.SmartViscaf__TriggerLeadExRenkeiTriggerHandler__c = true; // 2018.03.xx v1.22  Lead連携拡張パッケージの中にある 自動連携のトリガハンドラを呼ぶ
    // Lead 拡張パッケージ v2.0 からの項目
    svConfig.RenkeiCreateContactOnAcountWithoutLead__c = true; // デフォルト false 統合版自動連携:リードなく、取引先既存で取引先責任者を作成する
    svConfig.RenkeiCreateContactOnAcountWithLead__c = false;  // デフォルト false 統合版自動連携:リード、取引先既存で取引先責任者を作成する
    svConfig.RenkeiCreateLeadOnTooManyAccounts__c = false;  // デフォルト false 統合版自動連携: 既存取引先が複数あり特定できないとき、リードを作る。
    svConfig.RenkeiContactToCampaignMember__c = true;  // デフォルト false 統合版自動連携: 取引先責任者もキャンペーンメンバーにする。
    svConfig.RenkeiUpdateToCampaignMember__c = true; // デフォルト false 統合版自動連携: 更新でもキャンペーンメンバーにする。
    svConfig.RenkeiUpdateAllLeadsOnCondition__c = true; // デフォルト true 統合版自動連携:条件に合致する既存リードは全て更新する。
    upsert svConfig;
    // 名刺基本設定 リード連携は無効　で、 キャンペンメンバー化も無効
    SmartViscaf__NameCardBasicSetting__c bs = SmartViscaf.SB_NC_PostInstallScript.createDefaultBasicSetting();
    bs.SmartViscaf__RenkeiActive__c = true;      // 自動連携機能有効
    bs.SmartViscaf__RenkeiLeadActive__c = false; // リード連携を有効化
    bs.SmartViscaf__RenkeiActiveCampaignMember__c = false; // キャンペンメンバー
    bs.SmartViscaf__RenkeiCampaignStatus__c = SB_NameCardL_Util.getDefaultCampaignStatus(); // キャンペーンメンバーの状況
    bs.SmartViscaf__RenkeiAccountOverwrite__c = true;   // 既存の取引先を上書き
    bs.SmartViscaf__RenkeiContactOverwrite__c = true;   // 既存の取引先責任者を上書き
    bs.SmartViscaf__RenkeiLeadOverwrite__c = true;   // 既存のリードを上書き
    insert bs;
    TestDb db = new TestDb();
    db.initialize();
    db.createMapping();

    Test.startTest();
    db.createNameCard('2');
    Test.stopTest();

    List<SmartViscaf__NameCard__c> cards = Database.query('SELECT Id, Name, SmartViscaf__email__c, SmartViscaf__delivery_type__c FROM SmartViscaf__NameCard__c');
    Set<String> emails = new Set<String>();
    for (SmartViscaf__NameCard__c c : cards) {
      emails.add(c.SmartViscaf__email__c);
    }
    System.assertEquals(2, emails.size());
    //SB_NameCardL_RenkeiHelper.doRenkei(cards, SB_NameCardL_RenkeiHelper.ProcType.LEAD);
    // リードができてる
    List<Lead> leads = [SELECT Id, Name, Email, Company, FirstName, LastName FROM Lead WHERE Email IN :emails];
    //System.assertEquals(emails.size(), leads.size());
    System.assertEquals(0, leads.size());
    //　アカウント
    List<Account> acnts = [SELECT Id, Name, Site FROM Account];
    System.assertEquals(2, acnts.size());
    //　コンタクト
    List<Contact> conts = [SELECT Id, Name, Email, Account.Name, FirstName, LastName FROM Contact WHERE Email IN :emails];
    System.assertEquals(2, conts.size());
    //　リードはキャンペンメンバーになってる。
    List<CampaignMember> cms = [SELECT Id, CampaignId, LeadId, ContactId, FirstName, LastName, Status FROM CampaignMember WHERE LeadId != null OR ContactId != null];
    System.assertEquals(0, cms.size());
  }

  // リード連携は無効　で、 キャンペンメンバー化は無効 で コンタクトが作成されて、キャンペンメンバーにならない
  @isTest
  static void test_createContact_AccountRenkei() {
    // SmartVisca設定
    SmartViscaf__SmartViscaConfig__c svConfig = SmartViscaf__SmartViscaConfig__c.getOrgDefaults();
    svConfig.SmartViscaf__TriggerLeadExRenkeiTriggerHandler__c = true; // 2018.03.xx v1.22  Lead連携拡張パッケージの中にある 自動連携のトリガハンドラを呼ぶ
    // Lead 拡張パッケージ v2.0 からの項目
    svConfig.RenkeiCreateContactOnAcountWithoutLead__c = true; // デフォルト false 統合版自動連携:リードなく、取引先既存で取引先責任者を作成する
    svConfig.RenkeiCreateContactOnAcountWithLead__c = false;  // デフォルト false 統合版自動連携:リード、取引先既存で取引先責任者を作成する
    svConfig.RenkeiCreateLeadOnTooManyAccounts__c = false;  // デフォルト false 統合版自動連携: 既存取引先が複数あり特定できないとき、リードを作る。
    svConfig.RenkeiContactToCampaignMember__c = true;  // デフォルト false 統合版自動連携: 取引先責任者もキャンペーンメンバーにする。
    svConfig.RenkeiUpdateToCampaignMember__c = true; // デフォルト false 統合版自動連携: 更新でもキャンペーンメンバーにする。
    svConfig.RenkeiUpdateAllLeadsOnCondition__c = true; // デフォルト true 統合版自動連携:条件に合致する既存リードは全て更新する。
    upsert svConfig;
    // 名刺基本設定 リード連携は無効　で、 キャンペンメンバー化も無効
    SmartViscaf__NameCardBasicSetting__c bs = SmartViscaf.SB_NC_PostInstallScript.createDefaultBasicSetting();
    bs.SmartViscaf__RenkeiActive__c = true;      // 自動連携機能有効
    bs.SmartViscaf__RenkeiLeadActive__c = false; // リード連携を有効化
    bs.SmartViscaf__RenkeiActiveCampaignMember__c = false; // キャンペンメンバー
    bs.SmartViscaf__RenkeiCampaignStatus__c = SB_NameCardL_Util.getDefaultCampaignStatus(); // キャンペーンメンバーの状況
    bs.SmartViscaf__RenkeiAccountOverwrite__c = true;   // 既存の取引先を上書き
    bs.SmartViscaf__RenkeiContactOverwrite__c = true;   // 既存の取引先責任者を上書き
    bs.SmartViscaf__RenkeiLeadOverwrite__c = true;   // 既存のリードを上書き
    insert bs;
    TestDb db = new TestDb();
    db.initialize();
    db.createMapping();
    db.createAccount();

    Test.startTest();
    db.createNameCard('2');
    Test.stopTest();

    List<SmartViscaf__NameCard__c> cards = Database.query('SELECT Id, Name, SmartViscaf__email__c, SmartViscaf__delivery_type__c FROM SmartViscaf__NameCard__c');
    Set<String> emails = new Set<String>();
    for (SmartViscaf__NameCard__c c : cards) {
      emails.add(c.SmartViscaf__email__c);
    }
    System.assertEquals(2, emails.size());
    //SB_NameCardL_RenkeiHelper.doRenkei(cards, SB_NameCardL_RenkeiHelper.ProcType.LEAD);
    // リードができてる
    List<Lead> leads = [SELECT Id, Name, Email, Company, FirstName, LastName FROM Lead WHERE Email IN :emails];
    //System.assertEquals(emails.size(), leads.size());
    System.assertEquals(0, leads.size());
    //　コンタクトはできてない。
    List<Contact> conts = [SELECT Id, Name, Email, Account.Name, FirstName, LastName FROM Contact WHERE Email IN :emails];
    System.assertEquals(2, conts.size());
    //　リードはキャンペンメンバーになってる。
    List<CampaignMember> cms = [SELECT Id, CampaignId, LeadId, ContactId, FirstName, LastName, Status FROM CampaignMember WHERE LeadId != null OR ContactId != null];
    System.assertEquals(0, cms.size());
  }


  // リード連携は無効　で、 キャンペンメンバー化は無効 で コンタクトが既存で更新されて、キャンペンメンバーにならない
  @isTest
  static void test_updateAccountContact_AccountRenkei() {
    // SmartVisca設定
    SmartViscaf__SmartViscaConfig__c svConfig = SmartViscaf__SmartViscaConfig__c.getOrgDefaults();
    svConfig.SmartViscaf__TriggerLeadExRenkeiTriggerHandler__c = true; // 2018.03.xx v1.22  Lead連携拡張パッケージの中にある 自動連携のトリガハンドラを呼ぶ
    // Lead 拡張パッケージ v2.0 からの項目
    svConfig.RenkeiCreateContactOnAcountWithoutLead__c = true; // デフォルト false 統合版自動連携:リードなく、取引先既存で取引先責任者を作成する
    svConfig.RenkeiCreateContactOnAcountWithLead__c = false;  // デフォルト false 統合版自動連携:リード、取引先既存で取引先責任者を作成する
    svConfig.RenkeiCreateLeadOnTooManyAccounts__c = false;  // デフォルト false 統合版自動連携: 既存取引先が複数あり特定できないとき、リードを作る。
    svConfig.RenkeiContactToCampaignMember__c = true;  // デフォルト false 統合版自動連携: 取引先責任者もキャンペーンメンバーにする。
    svConfig.RenkeiUpdateToCampaignMember__c = true; // デフォルト false 統合版自動連携: 更新でもキャンペーンメンバーにする。
    svConfig.RenkeiUpdateAllLeadsOnCondition__c = true; // デフォルト true 統合版自動連携:条件に合致する既存リードは全て更新する。
    upsert svConfig;
    // 名刺基本設定 リード連携は無効　で、 キャンペンメンバー化も無効
    SmartViscaf__NameCardBasicSetting__c bs = SmartViscaf.SB_NC_PostInstallScript.createDefaultBasicSetting();
    bs.SmartViscaf__RenkeiActive__c = true;      // 自動連携機能有効
    bs.SmartViscaf__RenkeiLeadActive__c = false; // リード連携を有効化
    bs.SmartViscaf__RenkeiActiveCampaignMember__c = false; // キャンペンメンバー
    bs.SmartViscaf__RenkeiCampaignStatus__c = SB_NameCardL_Util.getDefaultCampaignStatus(); // キャンペーンメンバーの状況
    bs.SmartViscaf__RenkeiAccountOverwrite__c = true;   // 既存の取引先を上書き
    bs.SmartViscaf__RenkeiContactOverwrite__c = true;   // 既存の取引先責任者を上書き
    bs.SmartViscaf__RenkeiLeadOverwrite__c = true;   // 既存のリードを上書き
    insert bs;
    TestDb db = new TestDb();
    db.initialize();
    db.createMapping();
    db.createAccount();
    db.createContact();

    Test.startTest();
    db.createNameCard('2');
    Test.stopTest();

    List<SmartViscaf__NameCard__c> cards = Database.query('SELECT Id, Name, SmartViscaf__email__c, SmartViscaf__delivery_type__c FROM SmartViscaf__NameCard__c');
    Set<String> emails = new Set<String>();
    for (SmartViscaf__NameCard__c c : cards) {
      emails.add(c.SmartViscaf__email__c);
    }
    System.assertEquals(2, emails.size());
    //SB_NameCardL_RenkeiHelper.doRenkei(cards, SB_NameCardL_RenkeiHelper.ProcType.LEAD);
    // リードができてる
    List<Lead> leads = [SELECT Id, Name, Email, Company, FirstName, LastName FROM Lead WHERE Email IN :emails];
    //System.assertEquals(emails.size(), leads.size());
    System.assertEquals(0, leads.size());
    //　アカウント
    List<Account> acnts = [SELECT Id, Name, Site FROM Account];
    System.assertEquals(2, acnts.size());
    //　コンタクト
    List<Contact> conts = [SELECT Id, Name, Email, Account.Name, FirstName, LastName FROM Contact WHERE Email IN :emails];
    System.assertEquals(2, conts.size());
    cards = [SELECT Id, Name, SmartViscaf__account__c, SmartViscaf__contact__c, SmartViscaf__lead__c FROM SmartViscaf__NameCard__c
              WHERE SmartViscaf__account__c != null AND SmartViscaf__contact__c != null];
    System.assertEquals(2, cards.size());
    // キャンペンメンバ
    List<CampaignMember> cms = [SELECT Id, CampaignId, LeadId, ContactId, FirstName, LastName, Status FROM CampaignMember WHERE LeadId != null OR ContactId != null];
    System.assertEquals(0, cms.size());
  }

  // リード連携は無効　で、 キャンペンメンバー化は無効 で 名刺が重複していて、新規でアカウント、コンタクトを作成する。
  @isTest
  static void test_createAccountContact_AccountRenkei_DuplicateCard() {
    // SmartVisca設定
    SmartViscaf__SmartViscaConfig__c svConfig = SmartViscaf__SmartViscaConfig__c.getOrgDefaults();
    svConfig.SmartViscaf__TriggerLeadExRenkeiTriggerHandler__c = true; // 2018.03.xx v1.22  Lead連携拡張パッケージの中にある 自動連携のトリガハンドラを呼ぶ
    // Lead 拡張パッケージ v2.0 からの項目
    svConfig.RenkeiCreateContactOnAcountWithoutLead__c = true; // デフォルト false 統合版自動連携:リードなく、取引先既存で取引先責任者を作成する
    svConfig.RenkeiCreateContactOnAcountWithLead__c = false;  // デフォルト false 統合版自動連携:リード、取引先既存で取引先責任者を作成する
    svConfig.RenkeiCreateLeadOnTooManyAccounts__c = false;  // デフォルト false 統合版自動連携: 既存取引先が複数あり特定できないとき、リードを作る。
    svConfig.RenkeiContactToCampaignMember__c = true;  // デフォルト false 統合版自動連携: 取引先責任者もキャンペーンメンバーにする。
    svConfig.RenkeiUpdateToCampaignMember__c = true; // デフォルト false 統合版自動連携: 更新でもキャンペーンメンバーにする。
    svConfig.RenkeiUpdateAllLeadsOnCondition__c = true; // デフォルト true 統合版自動連携:条件に合致する既存リードは全て更新する。
    upsert svConfig;
    // 名刺基本設定 リード連携は無効　で、 キャンペンメンバー化も無効
    SmartViscaf__NameCardBasicSetting__c bs = SmartViscaf.SB_NC_PostInstallScript.createDefaultBasicSetting();
    bs.SmartViscaf__RenkeiActive__c = true;      // 自動連携機能有効
    bs.SmartViscaf__RenkeiLeadActive__c = false; // リード連携を有効化
    bs.SmartViscaf__RenkeiActiveCampaignMember__c = false; // キャンペンメンバー
    bs.SmartViscaf__RenkeiCampaignStatus__c = SB_NameCardL_Util.getDefaultCampaignStatus(); // キャンペーンメンバーの状況
    bs.SmartViscaf__RenkeiAccountOverwrite__c = true;   // 既存の取引先を上書き
    bs.SmartViscaf__RenkeiContactOverwrite__c = true;   // 既存の取引先責任者を上書き
    bs.SmartViscaf__RenkeiLeadOverwrite__c = true;   // 既存のリードを上書き
    insert bs;
    TestDb db = new TestDb();
    db.initialize();
    db.createMapping();
    db.initializeNameCard('2');
    List<SmartViscaf__NameCard__c> newList = new List<SmartViscaf__NameCard__c>();
    for (SmartViscaf__NameCard__c c : db.listCard) {
      newList.add(c);
      newList.add(c.clone());
    }

    //　アカウント
    System.assert([SELECT Id, Name, Site FROM Account].isEmpty());

    Test.startTest();
    insert newList;
    Test.stopTest();

    List<SmartViscaf__NameCard__c> cards = Database.query('SELECT Id, Name, SmartViscaf__email__c, SmartViscaf__delivery_type__c FROM SmartViscaf__NameCard__c');
    Set<String> emails = new Set<String>();
    for (SmartViscaf__NameCard__c c : cards) {
      emails.add(c.SmartViscaf__email__c);
    }
    System.assertEquals(2, emails.size());
    //SB_NameCardL_RenkeiHelper.doRenkei(cards, SB_NameCardL_RenkeiHelper.ProcType.LEAD);
    // リードができてる
    List<Lead> leads = [SELECT Id, Name, Email, Company, FirstName, LastName FROM Lead WHERE Email IN :emails];
    //System.assertEquals(emails.size(), leads.size());
    System.assertEquals(0, leads.size());
    //　アカウント
    List<Account> acnts = [SELECT Id, Name, Site FROM Account WHERE SmartViscaf__NameCard__c != null];
    System.assertEquals(2, acnts.size());
    //　コンタクト
    List<Contact> conts = [SELECT Id, Name, Email, Account.Name, FirstName, LastName FROM Contact WHERE Email IN :emails AND SmartViscaf__NameCard__c != null];
    System.assertEquals(2, conts.size());
    cards = [SELECT Id, Name, SmartViscaf__account__c, SmartViscaf__contact__c, SmartViscaf__lead__c FROM SmartViscaf__NameCard__c
              WHERE SmartViscaf__account__c != null AND SmartViscaf__contact__c != null];
    System.assertEquals(4, cards.size());
    // キャンペンメンバ
    List<CampaignMember> cms = [SELECT Id, CampaignId, LeadId, ContactId, FirstName, LastName, Status FROM CampaignMember WHERE LeadId != null OR ContactId != null];
    System.assertEquals(0, cms.size());
  }

  // リード連携は無効　で、 キャンペンメンバー化は無効 で 名刺が重複していて、コンタクトが既存で更新されて、キャンペンメンバーにならない
  @isTest
  static void test_updateAccountContact_AccountRenkei_DuplicateCard() {
    // SmartVisca設定
    SmartViscaf__SmartViscaConfig__c svConfig = SmartViscaf__SmartViscaConfig__c.getOrgDefaults();
    svConfig.SmartViscaf__TriggerLeadExRenkeiTriggerHandler__c = true; // 2018.03.xx v1.22  Lead連携拡張パッケージの中にある 自動連携のトリガハンドラを呼ぶ
    // Lead 拡張パッケージ v2.0 からの項目
    svConfig.RenkeiCreateContactOnAcountWithoutLead__c = true; // デフォルト false 統合版自動連携:リードなく、取引先既存で取引先責任者を作成する
    svConfig.RenkeiCreateContactOnAcountWithLead__c = false;  // デフォルト false 統合版自動連携:リード、取引先既存で取引先責任者を作成する
    svConfig.RenkeiCreateLeadOnTooManyAccounts__c = false;  // デフォルト false 統合版自動連携: 既存取引先が複数あり特定できないとき、リードを作る。
    svConfig.RenkeiContactToCampaignMember__c = true;  // デフォルト false 統合版自動連携: 取引先責任者もキャンペーンメンバーにする。
    svConfig.RenkeiUpdateToCampaignMember__c = true; // デフォルト false 統合版自動連携: 更新でもキャンペーンメンバーにする。
    svConfig.RenkeiUpdateAllLeadsOnCondition__c = true; // デフォルト true 統合版自動連携:条件に合致する既存リードは全て更新する。
    upsert svConfig;
    // 名刺基本設定 リード連携は無効　で、 キャンペンメンバー化も無効
    SmartViscaf__NameCardBasicSetting__c bs = SmartViscaf.SB_NC_PostInstallScript.createDefaultBasicSetting();
    bs.SmartViscaf__RenkeiActive__c = true;      // 自動連携機能有効
    bs.SmartViscaf__RenkeiLeadActive__c = false; // リード連携を有効化
    bs.SmartViscaf__RenkeiActiveCampaignMember__c = false; // キャンペンメンバー
    bs.SmartViscaf__RenkeiCampaignStatus__c = SB_NameCardL_Util.getDefaultCampaignStatus(); // キャンペーンメンバーの状況
    bs.SmartViscaf__RenkeiAccountOverwrite__c = true;   // 既存の取引先を上書き
    bs.SmartViscaf__RenkeiContactOverwrite__c = true;   // 既存の取引先責任者を上書き
    bs.SmartViscaf__RenkeiLeadOverwrite__c = true;   // 既存のリードを上書き
    insert bs;
    TestDb db = new TestDb();
    db.initialize();
    db.createMapping();
    db.createAccount();
    db.createContact();
    db.initializeNameCard('2');
    List<SmartViscaf__NameCard__c> newList = new List<SmartViscaf__NameCard__c>();
    for (SmartViscaf__NameCard__c c : db.listCard) {
      newList.add(c);
      newList.add(c.clone());
    }
    Test.startTest();
    insert newList;
    Test.stopTest();

    List<SmartViscaf__NameCard__c> cards = Database.query('SELECT Id, Name, SmartViscaf__email__c, SmartViscaf__delivery_type__c FROM SmartViscaf__NameCard__c');
    Set<String> emails = new Set<String>();
    for (SmartViscaf__NameCard__c c : cards) {
      emails.add(c.SmartViscaf__email__c);
    }
    System.assertEquals(2, emails.size());
    //SB_NameCardL_RenkeiHelper.doRenkei(cards, SB_NameCardL_RenkeiHelper.ProcType.LEAD);
    // リードができてる
    List<Lead> leads = [SELECT Id, Name, Email, Company, FirstName, LastName FROM Lead WHERE Email IN :emails];
    //System.assertEquals(emails.size(), leads.size());
    System.assertEquals(0, leads.size());
    //　アカウント
    List<Account> acnts = [SELECT Id, Name, Site FROM Account];
    System.assertEquals(2, acnts.size());
    //　コンタクト
    List<Contact> conts = [SELECT Id, Name, Email, Account.Name, FirstName, LastName FROM Contact WHERE Email IN :emails];
    System.assertEquals(2, conts.size());
    cards = [SELECT Id, Name, SmartViscaf__account__c, SmartViscaf__contact__c, SmartViscaf__lead__c FROM SmartViscaf__NameCard__c
              WHERE SmartViscaf__account__c != null AND SmartViscaf__contact__c != null];
    System.assertEquals(4, cards.size());
    // キャンペンメンバ
    List<CampaignMember> cms = [SELECT Id, CampaignId, LeadId, ContactId, FirstName, LastName, Status FROM CampaignMember WHERE LeadId != null OR ContactId != null];
    System.assertEquals(0, cms.size());
  }

}