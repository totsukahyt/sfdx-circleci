/**
 *
 * SB_NCL_TwowayRegistControllerTest2
 *   LEX版  取引先登録（個別）、取引先登録（一括）のテストクラス
 *   SB_NC_SVCameraLauncherController と SB_NCL_TwowayRegistController のテストクラス
 *
 * Copyright (C) 2016 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2016.11.xx
 *
 **/
@isTest
private class SB_NCL_TwowayRegistControllerTest2
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
      svConfig.LeadRegist_CampaignList__c = '10;true ;In Progress, Planned,進行中; Email, Other'; // リードに登録 キャンペーンリスト
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

    //　キャンペーン
    public override void initializeCampaign() {
      listCampaign.add(new Campaign(Name='キャンペーン01', IsActive=true, Status='進行中', Type = 'Email'));
      listCampaign.add(new Campaign(Name='キャンペーン02', IsActive=true, Status='進行中', Type = 'Other'));
      listCampaign.add(new Campaign(Name='完了ようキャンペーン', IsActive=true, Status='完了', Type = 'Email'));
      listCampaign.add(new Campaign(Name='無効キャンペーン01', IsActive=false, Status='完了', Type = 'Email'));
      listCampaign.add(new Campaign(Name='無効キャンペーン02', IsActive=false, Status='完了', Type = 'Email'));
      listCampaign.add(new Campaign(Name='無効キャンペーン03', IsActive=false, Status='完了', Type = 'Email'));
      listCampaign.add(new Campaign(Name='無効キャンペーン04', IsActive=false, Status='完了', Type = 'Email'));
      listCampaign.add(new Campaign(Name='無効キャンペーン05', IsActive=false, Status='完了', Type = 'Email'));
      listCampaign.add(new Campaign(Name='無効キャンペーン06', IsActive=false, Status='完了', Type = 'Email'));
      listCampaign.add(new Campaign(Name='無効キャンペーン07', IsActive=false, Status='完了', Type = 'Email'));
      listCampaign.add(new Campaign(Name='無効キャンペーン08', IsActive=false, Status='完了', Type = 'Email'));
      listCampaign.add(new Campaign(Name='無効キャンペーン09', IsActive=false, Status='完了', Type = 'Email'));
      listCampaign.add(new Campaign(Name='無効キャンペーン10', IsActive=false, Status='完了', Type = 'Email'));
      listCampaign.add(new Campaign(Name='無効キャンペーン11', IsActive=false, Status='完了', Type = 'Email'));
    }

    //　キャンペーンメンバーステータス
    public void initializeCampaignMemberStatus() {
      listCampaignMemberStatus.add(new CampaignMemberStatus(CampaignId=listCampaign[0].Id, IsDefault=true, Label='進行中'));
      listCampaignMemberStatus.add(new CampaignMemberStatus(CampaignId=listCampaign[0].Id, IsDefault=false, Label='計画中'));
    }


    public override void initializeLead() {
      listLead.add(new Lead(Company='サンブリッジ株式会社', FirstName='太郎', LastName='恵比寿', Title='課長', Email='user01@sunbridge.com', OwnerId=UserInfo.getUserId()));
      listLead.add(new Lead(Company='目黒商事株式会社', FirstName='次郎', LastName='不動前', Title='部長', Email='user01@meguro.co.jp', OwnerId=UserInfo.getUserId()));
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
      // キャンペーン
      initializeCampaign();
      if (listCampaign.isEmpty() == false) {
          insert listCampaign;
      }
      initializeCampaignMemberStatus();
      if (listCampaignMemberStatus.isEmpty() == false) {
          insert listCampaignMemberStatus;
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

  @testSetup
  static void setupDB() {
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
  }

  // getCampaigns のテスト
  @isTest
  static void test_getCampaigns() {
    // 有効なものだけでは、上限にたっしないので、有効なものすべて
    System.assertEquals(4, SB_NCL_TwowayRegistController.getCampaignOptions().size());
    // 無効なのを有効にする
    List<Campaign> cams = [SELECT Id, Name, Status, IsActive FROM Campaign WHERE IsActive=false];
    for (Campaign cam : cams) {
      cam.IsActive = true;
    }
    update cams;
    // 有効なものだけで、上限をこえるのて、StatusとTypeで絞られる+ 2
    System.assertEquals(4, SB_NCL_TwowayRegistController.getCampaignOptions().size());
  }

  @isTest
  static void test_getCampaignStatusList() {
    List<SB_NCL_TwowayRegistController.CampaignStatus> camsts = SB_NCL_TwowayRegistController.getCampaignStatusList();
    Integer count = 0;
    for (Schema.PicklistEntry entry : CampaignMember.Status.getDescribe().getPicklistValues()) {
      if (entry.isActive()) {
        count++;
      }
    }
    System.assertEquals(count, camsts.size());
  }

  @isTest
  static void test_getCampaignStatusList2() {
    List<Campaign> cams = [SELECT Id, Name FROM Campaign WHERE Name= 'キャンペーン01'];
    List<CampaignMemberStatus> cammemsts = SB_NCL_TwowayRegistController.getCampaignMemberStatusList(cams[0].Id);
    System.assertEquals(2, cammemsts.size());
  }

  //  searchLead のテスト
  @isTest
  static void test_searchLead() {
    List<Lead> leads = [SELECT Id, Name, Owner.Id, Owner.Name FROM Lead];
    Id[] ids = new Id[1];
    ids[0] = leads[0].Id;
    Test.setFixedSearchResults(ids);
    List<SB_NCL_RegistOptionCreater.RegistOption> options = SB_NCL_TwowayRegistController.searchLead(leads[0].Name, null);
    System.assertEquals(1, options.size());

    // レコードタイプが辺で例外
    Boolean bFalt = false;
    List<String> recTypes = new List<String> {'1234567890', '1234567890'};
    options.clear();
    try {
      options = SB_NCL_TwowayRegistController.searchLead(leads[0].Name, recTypes);
    }
    catch(Exception ex) {
      bFalt = true;
    }
    System.assertEquals(0, options.size());
  }

  //　searchCampaign のテスト
  @isTest
  static void test_searchCampaign() {
    List<Campaign> cams = [SELECT Id, Name FROM Campaign];
    Id[] ids = new Id[1];
    ids[0] = cams[0].Id;
    Test.setFixedSearchResults(ids);
    List<Campaign> options = SB_NCL_TwowayRegistController.searchCampaign(cams[0].Name);
    System.assertEquals(1, options.size());
  }

  @isTest
  static void test_getRecordById() {
    // lx 2.0
    Lead l = [SELECT Id FROM Lead limit 1];
    SObject leadRec = SB_NCL_TwowayRegistController.getRecordById(l.Id);
    System.assertEquals(l.Id, leadRec.Id);

  }

  // searchSObjects Queue
  @isTest
  static void test_searchSObjectsInQueue() {
    List<QueueSobject> qss = [SELECT Id, QueueId, QUeue.Name, SobjectType FROM QueueSobject WHERE SobjectType = 'Lead'];
    String word;
    if (!qss.isEmpty()) {
      word = qss[0].QUeue.Name;
    }
    else {
      word = 'ABCXYZ';
    }
    List<SOBject> res = SB_NCL_TwowayRegistController.searchSObjects(word, 'Queue', null);
    System.assert((qss.isEmpty() && res.isEmpty()) || !res.isEmpty());
  }

}