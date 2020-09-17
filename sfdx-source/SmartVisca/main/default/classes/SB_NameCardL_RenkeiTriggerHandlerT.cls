/**
 *
 *  SB_NameCardL_RenkeiTriggerHandlerT
 *   LEAD拡張パッケージの 連携用トリガハンドラを呼ぶテストクラス
 *
 *  Copyright (C) 2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1.22      2018.03.xx
 *
 **/
@isTest
private class SB_NameCardL_RenkeiTriggerHandlerT
{

  public class TestDb extends SB_NC_TestDB {

    public override void initializeSmartViscaConfig() {
      svConfig = SmartViscaConfig__c.getOrgDefaults();
      svConfig.TriggerLeadExRenkeiTriggerHandler__c = true; // 2018.03.xx v1.22  Lead連携拡張パッケージの中にある 自動連携のトリガハンドラを呼ぶ
    }

    public override void initializeBasicSetting() {
      NameCardBasicSetting__c bs = SB_NC_PostInstallScript.createDefaultBasicSetting();
      bs.ScanSelectCampaign__c = false; // 名刺スキャン時のキャンペーン選択を有効化
      bs.RenkeiActive__c = true;        // 自動連携機能を有効化
      bs.RenkeiLeadActive__c = true;    // リード登録機能を有効化
      listBasicSetting.add(bs);
    }

    public override void initialize() {

      // SmartVisca設定
      initializeSmartViscaConfig();
      if (svConfig !=null) {
        upsert svConfig;
      }
      //
      initializeUser();
      if (listUser.isEmpty() == false) {
        insert listUser;
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

  }   // public class TestDb extends SB_NC_TestDB

  @isTest
  static void test_LeadexRenkeiTrigerHandler_Insert() {
    TestDb db = new TestDb();
    db.initialize();

    Test.startTest();
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社テスト商事', division__c='本社',
                  zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                  last_name__c='テスト', first_name__c='一郎', email__c='ichiro@test.com', delivery_type__c='2'));
    insert listCard;

    String nsLx = SB_NameCard_Util.getLeadExNamespacePrefix();
    SB_NameCard_TriggerHandlerAbstract handler = SB_NameCard_TriggerHandlerFactory.getInstance(nsLx, 'SB_NameCardL_RenkeiTriggerHandler');
    System.assertEquals(true, handler.didInsert());

    Test.stopTest();
  }

  @isTest
  static void test_LeadexRenkeiTrigerHandler_Update() {
    TestDb db = new TestDb();
    db.initialize();

    Test.startTest();
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社テスト商事', division__c='本社',
                  zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                  last_name__c='テスト', first_name__c='一郎', email__c='ichiro@test.com', delivery_type__c='2'));
    insert listCard;

    listCard = [SELECT Id, Name FROM NameCard__c];
    update listCard;

    String nsLx = SB_NameCard_Util.getLeadExNamespacePrefix();
    SB_NameCard_TriggerHandlerAbstract handler = SB_NameCard_TriggerHandlerFactory.getInstance(nsLx, 'SB_NameCardL_RenkeiTriggerHandler');
    System.assertEquals(true, handler.didInsert());
    System.assertEquals(true, handler.didUpdate());

    Test.stopTest();
  }


}