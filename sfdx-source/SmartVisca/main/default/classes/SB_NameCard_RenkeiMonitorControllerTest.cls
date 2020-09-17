/**
 *
 * SB_NameCard_RenkeiMonitorControllerTest
 *
 *
 *
 * Copyright (C) 2017-2020 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2017.08.xx
 *  @Version 2.5.1  2020.05.22 SV_DEV-2599 コードスキャン対応 2コードスキャンで Query: URL Redirection Attack になってしまうので、修正
 *  @Version 2.5.3  2020.07.20 コードスキャン対応で、戻り先ページ指定しない。 リストビューの識別しない。retUrlパラメータを使わない。PRODUCT-480 SmartVisca コードスキャン対応の v2.5.3 の修正の v2.6 へ向けての反映
 *
 **/
@isTest
private class SB_NameCard_RenkeiMonitorControllerTest
{

  public class TestDb extends SB_NC_TestDB {


  }


  @isTest
  static void test_Init_Command() {
    TestDb db = new TestDb();
    db.initialize();

    List<NameCard__c> cards = [SELECT Id, Name FROM NameCard__c limit 10];
    PageReference pageRef = Page.SB_NameCard_RenkeiMonitor;
    Test.setCurrentPage(pageRef);
    SB_NameCard_RenkeiMonitorController ctrl = new SB_NameCard_RenkeiMonitorController();
    Map<String, String> params = pageRef.getParameters();
    params.put('id', cards[0].Id);
    ctrl.init();
    System.assertEquals(false, ctrl.cardIds.isEmpty());
    ctrl.runAll();
  }

  @isTest
  static void test_Init_Command_StandardSetController() {
    TestDb db = new TestDb();
    db.initialize();

    List<NameCard__c> cards = [SELECT Id, Name FROM NameCard__c limit 10];
    PageReference pageRef = Page.SB_NameCard_RenkeiMonitor;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardSetController controller = new ApexPages.StandardSetController(cards);
    controller.setSelected(cards);
    SB_NameCard_RenkeiMonitorController ctrl = new SB_NameCard_RenkeiMonitorController(controller);
    Map<String, String> params = pageRef.getParameters();
    params.put('retUrl', 'fcf=listview000');
    ctrl.init();
    System.assertEquals(false, ctrl.cardIds.isEmpty());
    // v2.5.3 2020.07.20 コードスキャン対応で、戻り先ページ指定しない。 retUrlパラメータを使わない。 PRODUCT-480 SmartVisca コードスキャン対応の v2.5.3 の修正の v2.6 へ向けての反映
    // System.assertEquals(true, ctrl.retUrl.contains('listview000'));
  }

  @isTest
  static void test_Init_Command_StandardSetController_LexBulk() {
    TestDb db = new TestDb();
    db.initialize();

    List<NameCard__c> cards = [SELECT Id, Name FROM NameCard__c limit 10];
    PageReference pageRef = Page.SB_NameCard_RenkeiMonitor;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardSetController controller = new ApexPages.StandardSetController(cards);
    controller.setSelected(cards);
    SB_NameCard_RenkeiMonitorController ctrl = new SB_NameCard_RenkeiMonitorController(controller);
    Map<String, String> params = pageRef.getParameters();
    params.put('vfRetURLInSFX', System.URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/o/NameCard__c/list?filterName=listview000');
    ctrl.init();
    System.assertEquals(false, ctrl.cardIds.isEmpty());
    // v2.5.3 2020.07.20 コードスキャン対応で、戻り先ページ指定しない。 retUrlパラメータを使わない。 PRODUCT-480 SmartVisca コードスキャン対応の v2.5.3 の修正の v2.6 へ向けての反映
    // System.assertEquals(null, ctrl.retUrl);
  }

  @isTest
  static void test_getCreateParameters() {
    TestDb db = new TestDb();
    db.initialize();

    List<NameCard__c> cards = [SELECT Id, Name FROM NameCard__c limit 10];

    String param = SB_NameCard_RenkeiMonitorController.getCreateParameters(cards[0].Id);
    System.assert(String.isNotBlank(param));
  }

  @isTest
  static void test_getCreateParametersBadId() {
    TestDb db = new TestDb();
    db.initialize();

    Boolean success = true;
    try {
      String param = SB_NameCard_RenkeiMonitorController.getCreateParameters('123456789012345678');
    }
    catch(Exception e) {
      success = false;
    }
    System.assertEquals(false, success);
  }

  @isTest
  static void test_getEscapedJSONString() {
    Map<String, Object> values = new Map<String, Object>();
    values.put('Boolean', true);
    values.put('Number', 1000);
    values.put('Text', 'ABCDEFG');
    values.put('MultiLine', '111\r222');
    String serialized = SB_NameCard_RenkeiMonitorController.getEscapedJSONString(values);
    System.assert(serialized.contains('true'));
    System.assert(serialized.contains('1000'));
  }

  //  v2.4 SV_DEV-1676 【例外】「自動連携の検証」で コレクションサイズ XXXX は、1,000 の最大サイズを超えています。エラーがでる。 用
  @isTest
  static void test_over1000Accounts() {
    TestDb db = new TestDb();
    db.initialize();

    // 取引先
    List<Account> acnts = new List<Account>();
    for (Integer n = 1; n <= 1002; n++) {
      acnts.add(new Account(Name='株式会社 千一件', Site='本社', NumberOfEmployees=1000+n));
    }
    insert acnts;
    // 名刺
    List<NameCard__c> cards = new List<NameCard__c>();
    cards.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社 千一件', division__c='本社',
                    // zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    // tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='一郎', email__c='ichiro@1001.com', delivery_type__c='2'));
    insert cards;
    NameCard__c card = [SELECT Id, Name FROM NameCard__c WHERE Name='テスト 一郎' limit 1];

    Test.startTest();
    PageReference pageRef = Page.SB_NameCard_RenkeiMonitor;
    Test.setCurrentPage(pageRef);
    SB_NameCard_RenkeiMonitorController ctrl = new SB_NameCard_RenkeiMonitorController();
    Map<String, String> params = pageRef.getParameters();
    params.put('id', card.Id);
    ctrl.init();
    System.assertEquals(card.Id, ctrl.nameCard.Id);
    System.assertEquals(1000, ctrl.candidates.size());
    System.assert(String.isNotBlank(ctrl.over1000Caption));
    System.assertEquals(false, ctrl.disableRun);
    Test.stopTest();
  }


  // SV_DEV-1677 【例外】「自動連携の検証」で SmartViscaf:Too many query rows: 50001エラーがでる。用
  @isTest
  static void test_TooManyQueryRows50001() {
    TestDb db = new TestDb();
    db.initialize();

    // 取引先
    List<Account> acnts = new List<Account>();
    for (Integer n = 1; n <= 12; n++) {
      acnts.add(new Account(Name='株式会社 沢山', Site='本社', NumberOfEmployees=1000+n));
    }
    insert acnts;
    // 名刺
    List<NameCard__c> cards = new List<NameCard__c>();
    cards.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社 沢山', division__c='本社',
                    // zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    // tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='一郎', email__c='ichiro@1001.com', delivery_type__c='2'));
    insert cards;
    NameCard__c card = [SELECT Id, Name FROM NameCard__c WHERE Name='テスト 一郎' limit 1];

    Test.startTest();
    SB_NameCard_RenkeiMonitorController.MAX_RECORDS = 10;
    PageReference pageRef = Page.SB_NameCard_RenkeiMonitor;
    Test.setCurrentPage(pageRef);
    SB_NameCard_RenkeiMonitorController ctrl = new SB_NameCard_RenkeiMonitorController();
    Map<String, String> params = pageRef.getParameters();
    params.put('id', card.Id);
    Boolean success = true;
    try {
      ctrl.init();
    }
    catch(Exception e) {
      success = false;
    }
    System.assertEquals(true, success);  // v2.4 例外スローしないようにした。
    System.assertEquals(true, ctrl.disableRun);
    Test.stopTest();
  }

  @isTest
  static void test_getViewidFromUrl() {
    System.assertEquals('listview001', SB_NameCard_RenkeiMonitorController.getViewidFromUrl('XXXX&fcf=listview001', false));
  }

  @isTest
  static void test_getRetunrUrl() {
    System.assertEquals(true, SB_NameCard_RenkeiMonitorController.getRetunrUrl('listview001', false).contains('?fcf=listview001'));
  }

}