/**
 *
 *  SB_NameCardL_RegistQueryStrategyTest
 *  SB_NameCardL_RegistQueryStrategyテストクラス
 *
 * Copyright (C) 2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2018.4.xx
 *  @Version 2.1    2020.07.xx SV_DEV-1970 カスタム設定からSmartVisca基本設定に移行対応
 *
 **/
@isTest
private class SB_NameCardL_RegistQueryStrategyTest
{

  public virtual class TestDb extends SB_NCL_TestDB {

    public override void initializeSmartViscaConfig() {
      svConfig = SmartViscaf__SmartViscaConfig__c.getOrgDefaults();
      svConfig.SmartViscaf__TriggerLeadExRenkeiTriggerHandler__c = true; // 2018.03.xx v1.22  Lead連携拡張パッケージの中にある 自動連携のトリガハンドラを呼ぶ
      // Lead 拡張パッケージ v2.0 からの項目
      svConfig.RenkeiCreateContactOnAcountWithoutLead__c = true; // デフォルト false 統合版自動連携:リードなく、取引先既存で取引先責任者を作成する
      svConfig.RenkeiCreateContactOnAcountWithLead__c = true;  // デフォルト false 統合版自動連携:リード、取引先既存で取引先責任者を作成する
      svConfig.RenkeiCreateLeadOnTooManyAccounts__c = false;  // デフォルト false 統合版自動連携: 既存取引先が複数あり特定できないとき、リードを作る。
      svConfig.RenkeiContactToCampaignMember__c = false;  // デフォルト false 統合版自動連携: 取引先責任者もキャンペーンメンバーにする。
      svConfig.RenkeiUpdateToCampaignMember__c = false; // デフォルト false 統合版自動連携: 更新でもキャンペーンメンバーにする。
      svConfig.RenkeiUpdateAllLeadsOnCondition__c = true; // デフォルト true 統合版自動連携:条件に合致する既存リードは全て更新する。
    }

    // 名刺基本設定
    public override void initializeBasicSetting() {
      SmartViscaf__NameCardBasicSetting__c bs = SmartViscaf.SB_NC_PostInstallScript.createDefaultBasicSetting();
      bs.SmartViscaf__RenkeiActive__c = true;      // 自動連携機能有効
      bs.SmartViscaf__RenkeiLeadActive__c = true; // リード連携を有効化
      bs.SmartViscaf__RenkeiActiveCampaignMember__c = false; // キャンペンメンバー
      //bs.SmartViscaf__RenkeiCampaignStatus__c = SB_NameCardL_Util.getDefaultCampaignStatus(); // キャンペーンメンバーの状況
      bs.SmartViscaf__RenkeiAccountOverwrite__c = true;   // 既存の取引先を上書き
      bs.SmartViscaf__RenkeiContactOverwrite__c = true;   // 既存の取引先責任者を上書き
      bs.SmartViscaf__RenkeiLeadOverwrite__c = true;   // 既存のリードを上書き
      // SV_DEV-1970 カスタム設定からSmartVisca基本設定に移行
      bs.SmartViscaf__RenkeiCreateContactOnAcountWithoutLead__c = true; // デフォルト false 統合版自動連携:リードなく、取引先既存で取引先責任者を作成する
      bs.SmartViscaf__RenkeiCreateContactOnAcountWithLead__c = true;  // デフォルト false 統合版自動連携:リード、取引先既存で取引先責任者を作成する
      bs.SmartViscaf__RenkeiCreateLeadOnTooManyAccounts__c = false;  // デフォルト false 統合版自動連携: 既存取引先が複数あり特定できないとき、リードを作る。
      bs.SmartViscaf__RenkeiUpdateAllLeadsOnCondition__c = true; // デフォルト true 統合版自動連携:条件に合致する既存リードは全て更新する。
      listBasicSetting.add(bs);
    }

    // アカウント
    public override void initializeAccount() {
      listAccount.add(new Account(Name='サンブリッジ株式会社', Site='開発部'));
      listAccount.add(new Account(Name='目黒商事株式会社', Site='営業部'));
    }

    ////　コンタクト
    //public override void initializeContact() {
    //  listContact.add(new Contact(AccountId=listAccount[0].Id, FirstName='太郎', LastName='恵比寿', Title='課長', Email='user01@sunbridge.com'));
    //  listContact.add(new Contact(AccountId=listAccount[1].Id, FirstName='次郎', LastName='不動前', Title='部長', Email='user01@meguro.co.jp'));
    //}

    public override void initializeLead() {
      listLead.add(new Lead(Company='サンブリッジ株式会社', FirstName='太郎', LastName='恵比寿', Title='課長', Email='user01@sunbridge.com'));
      listLead.add(new Lead(Company='目黒商事株式会社', FirstName='次郎', LastName='不動前', Title='部長', Email='user01@meguro.co.jp'));
    }

    //public void initializeCampaignMember() {
    //  listCampaignMember.add(new CampaignMember(CampaignId=listCampaign[0].Id, LeadId=listLead[0].Id, Status = SB_NameCardL_Util.getDefaultCampaignStatus()));
    //  listCampaignMember.add(new CampaignMember(CampaignId=listCampaign[0].Id, LeadId=listLead[1].Id, Status = SB_NameCardL_Util.getDefaultCampaignStatus()));
    //}

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
              //, SmartViscaf__account__c = listAccount[0].Id
              //, SmartViscaf__contact__c = listContact[0].Id
              //, SmartViscaf__lead__c = listLead[0].Id
              //, campaign__c = listCampaign[0].Id
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
              //, SmartViscaf__account__c = listAccount[1].Id
              //, SmartViscaf__contact__c = listContact[1].Id
              //, SmartViscaf__lead__c = listLead[1].Id
              //, campaign__c = listCampaign[0].Id
              , SmartViscaf__delivery_type__c = delivery_type));
    }

    // 初期データ作成  他に影響のないものだけ
    public override void initialize() {
      // SmartVisca設定
      initializeSmartViscaConfig();
      if (svConfig !=null) {
        upsert svConfig;
      }
      //　ユーザ
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
      // アカウント
      initializeAccount();
      if (listAccount.isEmpty() == false) {
        insert listAccount;
      }
      // リード
      initializeLead();
      if (listLead.isEmpty() == false) {
        insert listLead;
      }

      // 名刺
      initializeNameCard('1');
      if (listCard.isEmpty() == false) {
        insert listCard;
      }
    }
  } // class TestDb

  @isTest
  static void test_query() {
    TestDb db = new TestDb();
    db.initialize();
    List<SmartViscaf__NameCard__c> cards = Database.query('SELECT Id, Name, SmartViscaf__email__c, SmartViscaf__delivery_type__c FROM SmartViscaf__NameCard__c');
    for (SmartViscaf__NameCard__c c : cards) {
      c.SmartViscaf__delivery_type__c = '2';
    }
    update cards;



    System.assertEquals(2, [SELECT Id, Name, SmartViscaf__account__c, SmartViscaf__contact__c, SmartViscaf__lead__c FROM SmartViscaf__NameCard__c
              WHERE SmartViscaf__account__c != null AND SmartViscaf__contact__c != null AND SmartViscaf__lead__c != null].size());

    System.assertEquals(2, [SELECT Id, Name FROM Account WHERE SmartViscaf__NameCard__c != null].size());
    System.assertEquals(2, [SELECT Id, Name FROM Contact WHERE SmartViscaf__NameCard__c != null].size());
    System.assertEquals(2, [SELECT Id, Name FROM Lead WHERE NameCard__c != null].size());

    Test.startTest();
    SB_NameCardL_RegistQueryStrategy.AccountQueryStrategy qs_a = new SB_NameCardL_RegistQueryStrategy.AccountQueryStrategy();


    SB_NameCardL_RegistQueryOption qo = new SB_NameCardL_RegistQueryOption();
    qo.queryState = true;
    qo.queryCity = true;
    qo.queryStreet = true;
    qo.queryZip = true;
    qo.queryPhone = true;
    qo.queryCompany = true;
    qo.queryDept = true;
    qo.queryUrl = true;
    qo.queryLastName = true;
    qo.queryFirstName = true;
    qo.queryEMail = true;
    qo.queryTitle = true;
    qo.queryMobile = true;

    Test.stopTest();
  }

  @isTest
  static void testLeadHojinkakuParse() {
    
    TestDb db = new TestDb();
    db.initialize();
    List<SmartViscaf__NameCard__c> cards = Database.query('SELECT Id, SmartViscaf__company_name__c FROM SmartViscaf__NameCard__c');
    for (SmartViscaf__NameCard__c c : cards) {
      c.SmartViscaf__company_name__c = '㈱' + c.SmartViscaf__company_name__c.remove('株式会社');
      c.SmartViscaf__delivery_type__c = '2';
    }

    Test.startTest();
    update cards;
    Test.stopTest();

    System.assertEquals(2, [SELECT Id, Name, SmartViscaf__account__c, SmartViscaf__contact__c, SmartViscaf__lead__c FROM SmartViscaf__NameCard__c
              WHERE SmartViscaf__account__c != null AND SmartViscaf__contact__c != null AND SmartViscaf__lead__c != null].size());
    System.assertEquals(2, [SELECT Id, Name FROM Account WHERE SmartViscaf__NameCard__c != null].size());
    System.assertEquals(2, [SELECT Id, Name FROM Contact WHERE SmartViscaf__NameCard__c != null].size());
    System.assertEquals(2, [SELECT Id, Name FROM Lead WHERE NameCard__c != null].size());

  }
}