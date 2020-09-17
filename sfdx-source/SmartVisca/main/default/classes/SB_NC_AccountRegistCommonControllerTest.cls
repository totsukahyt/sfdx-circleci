/**
 *
 * SB_NC_AccountRegistCommonControllerTest
 *   LEX版  取引先登録（個別）、取引先登録（一括）のテストクラス
 *   SB_NC_SVCameraLauncherController と SB_NC_AccountRegistCommonController のテストクラス
 *
 * Copyright (C) 2016 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2016.11.xx
 *  @Version 2      2019.06.xx v2.4 v2.3 までの SOQLで候補を収集する。
 *  @Version 2.6 全 2020.09.03 PRODUCT-697 [取引先登録]でマスターレコードタイプしか割り当てられていないユーザが操作をすると割り当てられていないカスタムレコードタイプでレコードを作成しようとしエラーになる。
 *  @Version 2.7    2020.09.08 ohno   PRODUCT-696 取引先登録 個別・一括 メールアドレスが空白値で一致して登録先候補が表示されてしまう。（姓・名が異なるレコードが表示される）
 *
 **/
@isTest
private class SB_NC_AccountRegistCommonControllerTest
{

  public class TestDb extends SB_NC_TestDB {

    public void updaeDeliveryStatus() {
      List<NameCard__c> cards = [SELECT Id, Name, Parent__c, Saishin__c, delivery_type__c FROM NameCard__c];
      for (NameCard__c c : cards) {
        c.delivery_type__c = '2';
        c.Saishin__c = true;
      }
      update cards;
    }

    public override void initialize() {
       // ユーザ
      initializeUser();
      if (listUser.isEmpty() == false) {
        insert listUser;
      }
      // 名刺関係
      initializeKaisha();     // 会社を揃えておく
      initializeEmployee();   // 会社ごとに名刺の人を揃えておく
      // 名刺
      initializeNameCard();
      if (listCard.isEmpty() == false) {
        insert listCard;
      }
      // 名刺にToDoをつける
      initializeTask();
      if (!listTask.isEmpty()) {
        insert listTask;
      }
      // 名刺に行動をつける
      initializeEvent();
      if (!listEvent.isEmpty()) {
        insert listEvent;
      }
      // 取引先
      initializeAccount();  // 揃えた会社について、取引先を作る。
      if (mapAccount.isEmpty() == false) {
        insert mapAccount.values();
      }
      // 取引先責任者
      initializeContact();
      if (!listContact.isEmpty()) {
        insert listContact;
      }
      // 名刺連携項目マッピング
      initializeMapping();
      if (!listMapping.isEmpty()) {
        insert listMapping;
      }
    }
  }

  // 当クラスのメソッド共通のデータベースの準備
  @TestSetup
  static void setupDB() {
    // v2.3 までの SOQLでやる
    SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    svConfig.AccountRegistSearchMethod__c = 0; // v2.4 取引先・取引先任者に登録(個別) 登録先候補の検索方法 SOQL
    svConfig.AccountBulkRegistSearchMethod__c = 0; // v2.4 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL　に
    upsert svConfig;

    TestDb db = new TestDb();
    db.initialize();
    db.updaeDeliveryStatus();
  }

  private static SelectOption getSomeViewOption() {
    List<NameCard__c> objs = [SELECT Id, Name FROM NameCard__c];
    ApexPages.StandardSetController scon = new ApexPages.StandardSetController(objs);
    if (scon.getListViewOptions().isEmpty()) {
      return null;
    }
    return scon.getListViewOptions().get(0);
  }


  // Classic で リストビューから 取引先一括登録画面を開く
  @isTest
  static void test_SB_NC_AccountBulkRegist_Classic() {
    List<User> users = [SELECT Id, Name FROM User WHERE IsActive = true limit 10];
    System.assertNotEquals(0, users.size());
    System.runAs(users[0]) {
      List<SObject> objs = Database.query('SELECT Id, Name FROM NameCard__c LIMIT 10');
      System.assert(objs.isEmpty()==false);
      PageReference pageRef1 = Page.SB_NC_PageDispacher;
      Test.setCurrentPage(pageRef1);
      String urlpath = URL.getCurrentRequestUrl().getProtocol() + '://' + URL.getCurrentRequestUrl().getHost();
      System.debug('URL' + urlpath);
      ApexPages.currentPage().getHeaders().put('Referer', urlpath);      // Referer
      //ApexPages.currentPage().getHeaders().put('USER-AGENT', 'edge');
      SelectOption viewOpt = getSomeViewOption();
      ApexPages.currentPage().getParameters().put('retUrl', 'fcf='+(viewOpt!=null ? viewOpt.getValue() : '111111111111111'));
      ApexPages.StandardSetController stdSetCtrl = new ApexPages.StandardSetController(objs);
      stdSetCtrl.setSelected(objs);
      SB_NC_PageDispacherController ctrl1 = new SB_NC_PageDispacherController(stdSetCtrl);
      SB_NC_AccountRegistCommonController ctrlNoUse = new SB_NC_AccountRegistCommonController(stdSetCtrl);    // 使ってないけど テストを通す
      PageReference pageRef2 = ctrl1.init();    // Cookie セットして振り分け先PageRefの取得
      System.assertEquals('SB_NC_AccountBulkRegist', ctrl1.toPage);
      Test.setCurrentPage(pageRef2);
      SB_NC_AccountRegistCommonController ctrl2 = new SB_NC_AccountRegistCommonController();
      System.assertEquals(objs.size(), ctrl2.targetIds.size());
    }
  }

  // LEX で リストビューから 取引先一括登録画面を開く Edge
  @isTest
  static void test_SB_NC_AccountBulkRegist_LEX_Edge() {
    List<User> users = [SELECT Id, Name FROM User WHERE IsActive = true limit 10];
    System.assertNotEquals(0, users.size());
    System.runAs(users[0]) {
      List<SObject> objs = Database.query('SELECT Id, Name FROM NameCard__c LIMIT 10');
      System.assert(objs.isEmpty()==false);
      PageReference pageRef1 = Page.SB_NC_PageDispacher;
      Test.setCurrentPage(pageRef1);
      String urlpath = URL.getCurrentRequestUrl().getProtocol() + '://' + URL.getCurrentRequestUrl().getHost();
      ApexPages.currentPage().getHeaders().put('Referer', urlpath);      // Referer
      ApexPages.currentPage().getHeaders().put('USER-AGENT', 'Windows edge');
      SelectOption viewOpt = getSomeViewOption();
      //ApexPages.currentPage().getParameters().put('viewId', viewOpt!=null ? viewOpt.getValue() : '111111111111111');
      ApexPages.currentPage().getParameters().put('vfRetURLInSFX', 'filterName='+(viewOpt!=null ? viewOpt.getValue() : '111111111111111'));
      ApexPages.StandardSetController stdSetCtrl = new ApexPages.StandardSetController(objs);
      stdSetCtrl.setSelected(objs);
      SB_NC_PageDispacherController ctrl1 = new SB_NC_PageDispacherController(stdSetCtrl);
      SB_NC_AccountRegistCommonController ctrlNoUse = new SB_NC_AccountRegistCommonController(stdSetCtrl);
      PageReference pageRef2 = ctrl1.init();    // Cookie セットして振り分け先PageRefの取得
      System.assertEquals('SB_NC_AccountBulkRegistEdge', ctrl1.toPage);
      Test.setCurrentPage(pageRef2);
      SB_NC_AccountRegistCommonController ctrl2 = new SB_NC_AccountRegistCommonController();
      System.assertEquals(objs.size(), ctrl2.targetIds.size());
    }
  }

  // LEX で リストビューから 取引先一括登録画面を開く Edge
  @isTest
  static void test_SB_NC_AccountBulkRegist_LimitOver() {
    List<User> users = [SELECT Id, Name FROM User WHERE IsActive = true limit 10];
    System.assertNotEquals(0, users.size());
    System.runAs(users[0]) {
      List<SObject> objs = Database.query('SELECT Id, Name FROM NameCard__c LIMIT 20');
      System.assert(objs.isEmpty()==false);
      PageReference pageRef1 = Page.SB_NC_PageDispacher;
      Test.setCurrentPage(pageRef1);
      String urlpath = URL.getCurrentRequestUrl().getProtocol() + '://' + URL.getCurrentRequestUrl().getHost();
      ApexPages.currentPage().getHeaders().put('Referer', urlpath);      // Referer
      ApexPages.currentPage().getHeaders().put('USER-AGENT', 'Windows edge');
      SelectOption viewOpt = getSomeViewOption();
      //ApexPages.currentPage().getParameters().put('viewId', viewOpt!=null ? viewOpt.getValue() : '111111111111111');
      ApexPages.currentPage().getParameters().put('vfRetURLInSFX', 'filterName='+(viewOpt!=null ? viewOpt.getValue() : '111111111111111'));
      ApexPages.StandardSetController stdSetCtrl = new ApexPages.StandardSetController(objs);
      stdSetCtrl.setSelected(objs);
      SB_NC_PageDispacherController ctrl1 = new SB_NC_PageDispacherController(stdSetCtrl);
      SB_NC_AccountRegistCommonController ctrlNoUse = new SB_NC_AccountRegistCommonController(stdSetCtrl);
      Boolean bFalt = false;
      PageReference pageRef2 = ctrl1.init();    // Cookie セットして振り分け先PageRefの取得
      System.assert(String.isNotBlank(ctrl1.message));
    }
  }

  // LEX で リストビューから 取引先一括登録画面を開く IE11
  @isTest
  static void test_SB_NC_AccountBulkRegist_LEX_IE11() {
    List<User> users = [SELECT Id, Name FROM User WHERE IsActive = true limit 10];
    System.assertNotEquals(0, users.size());
    System.runAs(users[0]) {
      List<SObject> objs = Database.query('SELECT Id, Name FROM NameCard__c LIMIT 10');
      System.assert(objs.isEmpty()==false);
      PageReference pageRef1 = Page.SB_NC_PageDispacher;
      Test.setCurrentPage(pageRef1);
      String urlpath = URL.getCurrentRequestUrl().getProtocol() + '://' + URL.getCurrentRequestUrl().getHost();
      ApexPages.currentPage().getHeaders().put('Referer', urlpath);      // Referer
      ApexPages.currentPage().getHeaders().put('USER-AGENT', 'Windows Trident/7.0');
      SelectOption viewOpt = getSomeViewOption();
      //ApexPages.currentPage().getParameters().put('viewId', viewOpt!=null ? viewOpt.getValue() : '111111111111111');
      ApexPages.currentPage().getParameters().put('vfRetURLInSFX', 'filterName='+(viewOpt!=null ? viewOpt.getValue() : '111111111111111'));
      ApexPages.StandardSetController stdSetCtrl = new ApexPages.StandardSetController(objs);
      stdSetCtrl.setSelected(objs);
      SB_NC_PageDispacherController ctrl1 = new SB_NC_PageDispacherController(stdSetCtrl);
      SB_NC_AccountRegistCommonController ctrlNoUse = new SB_NC_AccountRegistCommonController(stdSetCtrl);
      PageReference pageRef2 = ctrl1.init();    // Cookie セットして振り分け先PageRefの取得
      System.assertEquals('SB_NC_AccountBulkRegistEdge', ctrl1.toPage);
      Test.setCurrentPage(pageRef2);
      SB_NC_AccountRegistCommonController ctrl2 = new SB_NC_AccountRegistCommonController();
      System.assertEquals(objs.size(), ctrl2.targetIds.size());
    }
  }

  // LEX で 詳細画面から 取引先登録画面を開く
  @isTest
  static void test_SB_NC_AccountRegist_LEX() {
    List<User> users = [SELECT Id, Name FROM User WHERE IsActive = true limit 10];
    System.assertNotEquals(0, users.size());
    System.runAs(users[0]) {
      List<SObject> objs = Database.query('SELECT Id, Name FROM NameCard__c LIMIT 10');
      System.assert(objs.isEmpty()==false);
      PageReference pageRef = Page.SB_NC_PageDispacher;
      Test.setCurrentPage(pageRef);
      String urlpath = URL.getCurrentRequestUrl().getProtocol() + '://' + URL.getCurrentRequestUrl().getHost();
      ApexPages.currentPage().getHeaders().put('Referer', urlpath);      // Referer
      ApexPages.currentPage().getParameters().put('id', objs[0].Id);
      ApexPages.currentPage().getParameters().put('page', 'SB_NC_AccountRegist');
      ApexPages.currentPage().getParameters().put('vfRetURLInSFX', urlpath);
      SB_NC_PageDispacherController ctrl1 = new SB_NC_PageDispacherController();
      PageReference pageRef2 = ctrl1.init();
      System.assertEquals('SB_NC_AccountRegist', ctrl1.toPage);
      Test.setCurrentPage(pageRef2);
      SB_NC_AccountRegistCommonController ctrl2 = new SB_NC_AccountRegistCommonController();
      System.assertEquals(objs[0].Id, ctrl2.targetId);
    }
  }

  // LEX で 詳細画面から 取引先登録画面を開く Edge
  @isTest
  static void test_SB_NC_AccountRegist_LEX_Edge() {
    List<User> users = [SELECT Id, Name FROM User WHERE IsActive = true limit 10];
    System.assertNotEquals(0, users.size());
    System.runAs(users[0]) {
      List<SObject> objs = Database.query('SELECT Id, Name FROM NameCard__c LIMIT 10');
      System.assert(objs.isEmpty()==false);
      PageReference pageRef = Page.SB_NC_PageDispacher;
      Test.setCurrentPage(pageRef);
      String urlpath = URL.getCurrentRequestUrl().getProtocol() + '://' + URL.getCurrentRequestUrl().getHost();
      ApexPages.currentPage().getHeaders().put('Referer', urlpath);      // Referer
      ApexPages.currentPage().getHeaders().put('USER-AGENT', 'Windows edge');
      ApexPages.currentPage().getParameters().put('id', objs[0].Id);
      ApexPages.currentPage().getParameters().put('page', 'SB_NC_AccountRegist');
      ApexPages.currentPage().getParameters().put('vfRetURLInSFX', urlpath);
      SB_NC_PageDispacherController ctrl1 = new SB_NC_PageDispacherController();
      PageReference pageRef2 = ctrl1.init();
      System.assertEquals('SB_NC_AccountRegistEdge', ctrl1.toPage);
      Test.setCurrentPage(pageRef2);
      SB_NC_AccountRegistCommonController ctrl2 = new SB_NC_AccountRegistCommonController();
      System.assertEquals(objs[0].Id, ctrl2.targetId);
    }
  }

  // LEX で 詳細画面から 取引先登録画面を開く IE11
  @isTest
  static void test_SB_NC_AccountRegist_LEX_IE11() {
    List<User> users = [SELECT Id, Name FROM User WHERE IsActive = true limit 10];
    System.assertNotEquals(0, users.size());
    System.runAs(users[0]) {
      List<SObject> objs = Database.query('SELECT Id, Name FROM NameCard__c LIMIT 10');
      System.assert(objs.isEmpty()==false);
      PageReference pageRef = Page.SB_NC_PageDispacher;
      Test.setCurrentPage(pageRef);
      String urlpath = URL.getCurrentRequestUrl().getProtocol() + '://' + URL.getCurrentRequestUrl().getHost();
      ApexPages.currentPage().getHeaders().put('Referer', urlpath);      // Referer
      ApexPages.currentPage().getHeaders().put('USER-AGENT', 'Windows Trident/7.0');
      ApexPages.currentPage().getParameters().put('id', objs[0].Id);
      ApexPages.currentPage().getParameters().put('page', 'SB_NC_AccountRegist');
      ApexPages.currentPage().getParameters().put('vfRetURLInSFX', urlpath);
      SB_NC_PageDispacherController ctrl1 = new SB_NC_PageDispacherController();
      PageReference pageRef2 = ctrl1.init();
      // Classic の 取引先登録画面
      System.assertEquals('SB_NameCard_AccountRegist', ctrl1.toPage);
      Test.setCurrentPage(pageRef2);
      SB_NC_AccountRegistCommonController ctrl2 = new SB_NC_AccountRegistCommonController();
      System.assertEquals(objs[0].Id, ctrl2.targetId);
    }
  }

  @isTest
  static void test_SB_NC_AccountRegist_NoTarget() {
    List<User> users = [SELECT Id, Name FROM User WHERE IsActive = true limit 10];
    System.assertNotEquals(0, users.size());
    System.runAs(users[0]) {
      List<SObject> objs = Database.query('SELECT Id, Name FROM NameCard__c LIMIT 10');
      System.assert(objs.isEmpty()==false);
      PageReference pageRef = Page.SB_NC_PageDispacher;
      Test.setCurrentPage(pageRef);
      String urlpath = URL.getCurrentRequestUrl().getProtocol() + '://' + URL.getCurrentRequestUrl().getHost();
      ApexPages.currentPage().getHeaders().put('Referer', urlpath);      // Referer
      ApexPages.currentPage().getHeaders().put('USER-AGENT', 'Windows edge');
      //ApexPages.currentPage().getParameters().put('id', objs[0].Id);
      ApexPages.currentPage().getParameters().put('page', 'SB_NC_AccountRegist');
      ApexPages.currentPage().getParameters().put('vfRetURLInSFX', urlpath);
      SB_NC_PageDispacherController ctrl1 = new SB_NC_PageDispacherController();
      PageReference pageRef2 = ctrl1.init();
      System.assertEquals('SB_NC_AccountRegistEdge', ctrl1.toPage);
      Test.setCurrentPage(pageRef2);
      SB_NC_AccountRegistCommonController ctrl2 = new SB_NC_AccountRegistCommonController();
      System.assert(String.isBlank(ctrl2.targetId));
    }
  }

  // getNamespacePrefix getUrlRoot
  @isTest
  static void test_Etc() {
    SB_NC_AccountRegistCommonController ctrl = new SB_NC_AccountRegistCommonController();
    System.debug(ctrl.getNameSpace());
    System.assertEquals(SB_NameCard_Util.getNamespacePrefix(), ctrl.getNameSpace());
    String url1 = ctrl.getUrlRoot('https://sunbridge.com/smartvisca/about');
    System.assertEquals('https://sunbridge.com', url1);
    String url2 = ctrl.getUrlRoot('https://');
    System.assertEquals('https://', url2);
  }

  // getSVConfig
  @isTest
  static void test_getSVConfig() {
    // ↓ まとめてテスト実行で __MISSING LABEL__ PropertyFile - val CatalogException$InternalException not found in section Exception
    // System.assert(SB_NC_AccountRegistCommonController.getSVConfig() != null);
    // ↓ SB_NameCard_SRegistControllerTest と同じにしてみたけど解決しない Why ?!
    SB_NameCard_S1Config config = SB_NC_AccountRegistCommonController.getSVConfig();
    System.assertEquals(UserInfo.getUserId(), config.userId);
  }

  // getListViewOptions
  @isTest
  static void test_getListViewOptions() {
    List<SB_NC_ListViewConfig.ListViewInfo> views = SB_NC_AccountRegistCommonController.getListViewOptions('NameCard__c', 'Id, Name');
    List<NameCard__c> objs = [SELECT Id, Name FROM NameCard__c];
    ApexPages.StandardSetController scon = new ApexPages.StandardSetController(objs);
    System.assertEquals(scon.getListViewOptions().size(), views.size());
  }

  // getListViewConfig
  @isTest
  static void test_getListViewConfig() {
    SB_NC_ListViewConfig viewConfig = SB_NC_AccountRegistCommonController.getListViewConfig();
    System.assertEquals('NameCard__c', viewConfig.objectName);
  }

  // getFilteredRecords
  @isTest
  static void test_getFilteredRecords() {
    Account acnt = [SELECT Id FROM Account limit 1];
    SB_NC_AccountRegistCommonController.FilteredQueryRequest req = new SB_NC_AccountRegistCommonController.FilteredQueryRequest();
    req.setDummy();
    SB_NC_AccountRegistCommonController.FilteredQueryResponse res = SB_NC_AccountRegistCommonController.getFilteredRecords(req);
    System.assertEquals(req.obj_name, res.req.obj_name);
  }

  // getRecordTypeInfo
  @isTest
  static void test_getRecordTypeInfos() {
    List<String> objnames = new List<String> {'Account'};
    Map<String, SB_NameCard_RecordTypeUtil.RecordTypeInfos> recTypeInfos = SB_NC_AccountRegistCommonController.getRecordTypeInfos(objnames);
    Map<String, Schema.RecordTypeInfo> mapRecordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
    Integer cnt = 0;
    for (Schema.RecordTypeInfo info : mapRecordTypes.values()) {
      if (info.isAvailable() == false) continue;   // PRODUCT-697 ユーザが使用可能なレコードタイプだけ
      if (info.isMaster() == true) continue;   // マスターは除外
      cnt++;
    }
    System.assertEquals(cnt, recTypeInfos.get('Account').infos.size());
  }

  // v 2.4 SV_DEV-590 取引先・取引先検索の対象を、レコードタイプ単位で絞る
  @isTest
  static void test_getRecordTypeInfos_Selected() {
    SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder builder = new SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder();
    builder.run();

    NameCardBasicSetting__c setting = [SELECT Id, Name, RegistAccountQueryRecordTypeIds__c, RegistContactQueryRecordTypeIds__c, RegistLeadQueryRecordTypeIds__c FROM NameCardBasicSetting__c LIMIT 1];
    setting.RegistAccountQueryRecordTypeIds__c = String.join(new List<Id>(Account.sObjectType.getDescribe().getRecordTypeInfosById().keySet()), ';'); // 全部またはマスターのみ
    setting.RegistContactQueryRecordTypeIds__c = String.join(new List<Id>(Contact.sObjectType.getDescribe().getRecordTypeInfosById().keySet()), ';'); // 全部またはマスターのみ
    setting.RegistLeadQueryRecordTypeIds__c = String.join(new List<Id>(Lead.sObjectType.getDescribe().getRecordTypeInfosById().keySet()), ';'); // 全部またはマスターのみ
    update setting;

    List<String> objnames = new List<String> {'Account','Contact','Lead'};
    Map<String, SB_NameCard_RecordTypeUtil.RecordTypeInfos> recTypeInfos = SB_NC_AccountRegistCommonController.getRecordTypeInfos(objnames);
    Map<String, Schema.RecordTypeInfo> mapRecordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
    Integer cnt = 0;
    for (Schema.RecordTypeInfo info : mapRecordTypes.values()) {
      if (info.isAvailable() == false) continue;   // PRODUCT-697 ユーザが使用可能なレコードタイプだけ
      if (info.isMaster() == true) continue;   // マスターは除外
      cnt++;
    }
    System.assertEquals(cnt, recTypeInfos.get('Account').infos.size());
  }


  // GetRegistOptions のテスト
  @isTest
  static void test_getRegistOptions() {
    SB_NC_RegistQueryOption opt = new SB_NC_RegistQueryOption();
    opt.bulkRegist = true;
    opt.queryDept = true;
    opt.queryState = true;
    opt.queryCity = true;
    opt.queryZip = true;
    //opt.acntRecTypeIds = new List<String> {};
    //opt.contRecTypeIds = null;
    List<NameCard__c> cards = [SELECT Id, Name FROM NameCard__c LIMIT 100];
    List<Id> ncIds = new List<Id>();
    for (NameCard__c card : cards) {
      ncIds.add(card.Id);
    }
    // // SOSL検索結果をセット
    // Map<Id, Account> acnts = new Map<Id, Account>([SELECT Id, Name FROM Account]);
    // Test.setFixedSearchResults(new List<Id>(acnts.keySet()));

    // リクエストの引数
    SB_NC_AccountRegistCommonController.RegistOptionRequest req = new SB_NC_AccountRegistCommonController.RegistOptionRequest(ncIds, opt);
    List<SB_NC_RegistOptionCreater.Card_RegistOption> reg_opts = SB_NC_AccountRegistCommonController.getRegistOptions(req);
    System.assertEquals(cards.size(), reg_opts.size());
    for (SB_NC_RegistOptionCreater.Card_RegistOption reg_opt : reg_opts) {
      System.assertEquals(3, reg_opt.options.size());
    }
  }


  @isTest
  static void test_getNameCard() {
    List<NameCard__c> objs = [SELECT Id, Name FROM NameCard__c LIMIT 10];
    SB_NC_NameCardDTO record = SB_NC_AccountRegistCommonController.getNameCard(objs[0].Id);
    System.assertEquals(objs[0].Name, record.name);
    Boolean bFalt = false;
    try {
      SB_NC_AccountRegistCommonController.getNameCard('111111111111111');
    }
    catch(Exception e) {
      bFalt = true;
    }
    System.assertEquals(true, bFalt);
  }

  // getAccountOptions
  @isTest
  static void test_getAccountOptions() {
    List<Account> acnts =[SELECT Id, Name FROM Account LIMIT 10];
    Set<String> company_names = new Set<String>();
    for (Account acnt : acnts) {
      company_names.add(acnt.Name);
    }
    List<NameCard__c> cards = [SELECT Id, Name FROM NameCard__c WHERE company_name__c IN :company_names];
    System.assert(cards.isEmpty() == false);
    SB_NC_RegistQueryOption query_opt = new SB_NC_RegistQueryOption(Account.getSObjectType());
    query_opt.bulkRegist = false;      // TURE:一括登録 FALSE:個別登録
    query_opt.querySite = true;      // 所属名を条件にして検索 0: 取引先名と所属名で検索 1,その他: 取引先名のみで検索
    query_opt.queryState = true;     // 都道府県を条件にして検索
    query_opt.queryCity = true;      // 市区郡を条件にして検索
    query_opt.queryZip = true;       // 郵便番号を条件にして検索
    List<SB_NC_RegistOptionCreater.RegistOption> options = SB_NC_AccountRegistCommonController.getAccountOptions(cards[0].Id, query_opt);
    System.assert(options.isEmpty() == false);
    for (SB_NC_RegistOptionCreater.RegistOption opt : options) {
      System.assertEquals(false, opt.selected);
    }
  }

  // getContactOptions
  @isTest
  static void test_getContactOptions() {
    List<Account> acnts =[SELECT Id, Name FROM Account LIMIT 10];
    Set<String> company_names = new Set<String>();
    for (Account acnt : acnts) {
      company_names.add(acnt.Name);
    }
    List<NameCard__c> cards = [SELECT Id, Name, company_name__c, account__c FROM NameCard__c WHERE company_name__c IN :company_names];
    System.assert(cards.isEmpty() == false);
    SB_NC_RegistQueryOption query_opt = new SB_NC_RegistQueryOption(Contact.getSObjectType());
    query_opt.bulkRegist = false;      // TURE:一括登録 FALSE:個別登録
    query_opt.querySite = true;      // 所属名を条件にして検索 0: 取引先名と所属名で検索 1,その他: 取引先名のみで検索
    query_opt.queryState = true;     // 都道府県を条件にして検索
    query_opt.queryCity = true;      // 市区郡を条件にして検索
    query_opt.queryZip = true;       // 郵便番号を条件にして検索
    Account acnt = [SELECT Id, Name FROM Account WHERE Name = :cards[0].company_name__c LIMIT 1];
    query_opt.parentIds = new List<Id>{ acnt.Id };
    List<SB_NC_RegistOptionCreater.RegistOption> options = SB_NC_AccountRegistCommonController.getContactOptions(cards[0].Id, query_opt);
    System.assert(options.isEmpty() == false);
    for (SB_NC_RegistOptionCreater.RegistOption opt : options) {
      System.assertEquals(false, opt.selected);
    }
  }

  // PRODUCT-696 取引先登録 個別・一括 メールアドレスが空白値で一致して登録先候補が表示されてしまう。（姓・名が異なるレコードが表示される）
  // getContactOptionsEmptyEmail
  @isTest
  static void test_getContactOptionsEmptyEmail() {
    List<Account> acnts =[SELECT Id, Name FROM Account LIMIT 1];
    Set<String> company_names = new Set<String>();
    for (Account acnt : acnts) {
      company_names.add(acnt.Name);
    }
    List<NameCard__c> cards = [SELECT Id, Name, company_name__c, account__c FROM NameCard__c WHERE company_name__c IN :company_names];
    // メールアドレスを未設定に変更
    for (Integer i = 0; i < cards.size(); i++) {
      cards[i].Email__c = null;
    }
    update cards;

    // メールアドレスを未設定に変更
    List<Contact> listContact= [SELECT Id, Name, Email FROM Contact WHERE AccountId = :acnts[0].Id];
    for (Integer i = 0; i < listContact.size(); i++) {
      listContact[i].Email = null;
    }
    update listContact;

    System.assert(cards.isEmpty() == false);
    SB_NC_RegistQueryOption query_opt = new SB_NC_RegistQueryOption(Contact.getSObjectType());
    query_opt.bulkRegist = false;      // TURE:一括登録 FALSE:個別登録
    query_opt.queryOrgType = 1; // 0:CorpMatch 1:PartialMatch 2:ExactMatch
    query_opt.queryState = false;
    query_opt.queryCity = false;
    query_opt.queryZip = false;
    Account acnt = [SELECT Id, Name FROM Account WHERE Name = :cards[0].company_name__c LIMIT 1];
    query_opt.parentIds = new List<Id>{ acnt.Id };
    List<SB_NC_RegistOptionCreater.RegistOption> options = SB_NC_AccountRegistCommonController.getContactOptions(cards[0].Id, query_opt);
    System.assert(options.isEmpty() == false);
    for (SB_NC_RegistOptionCreater.RegistOption opt : options) {
      System.debug(opt);
      if (opt.otype == 'Contact' && opt.type == 1) { // 1:既存で名刺と一致してるアカウント or コンタクトレコードが対象
        System.assertEquals(cards[0].Name, opt.title);
      }
      System.assertEquals(false, opt.selected);
    }
    System.assertEquals(3, options.size(), 'リストの取得件数が3件(新規取引先責任者の追加1件,取引先責任者を検索1件,既存取引先責任者１件)ではありません');
  }

  // registAccountContact 登録実行メソッドのテスト
  @isTest
  static void test_registAccountContact() {
    List<Account> acnts =[SELECT Id, Name FROM Account LIMIT 10];
    Set<String> company_names = new Set<String>();
    for (Account acnt : acnts) {
      company_names.add(acnt.Name);
    }
    List<NameCard__c> cards = [SELECT Id, Name, OwnerId, company_name__c, account__c FROM NameCard__c WHERE company_name__c IN :company_names];
    System.assert(cards.isEmpty() == false);
    Account acnt = [SELECT Id, Name FROM Account WHERE Name = :cards[0].company_name__c LIMIT 1];
    Contact cont = [SELECT Id, Name FROM Contact WHERE AccountId = :acnt.Id LIMIT 1];
    SB_NC_AccountRegistCommonController.RegistRequest req = new SB_NC_AccountRegistCommonController.RegistRequest();
    req.targets = new List<SB_NC_AccountRegistCommonController.RegistTarget>();
    SB_NC_AccountRegistCommonController.RegistTarget target = new SB_NC_AccountRegistCommonController.RegistTarget();
    target.cardId = cards[0].Id;
    target.acntId = acnt.Id;
    target.contId = cont.Id;
    target.someId = null;
    target.createTodo = true;
    target.todoDate = Date.today();
    target.createChildAccount = false;
    req.targets.add(target);
    req.acntParam = new SB_NC_AccountRegistCommonController.RegistParam();
    req.acntParam.overwrite = true;
    req.contParam = new SB_NC_AccountRegistCommonController.RegistParam();
    req.contParam.overwrite = true;
    //req.someParam = new SB_NC_AccountRegistCommonController.RegistParam();
    //req.someParam.overwrite = true;
    req.todoParam = new SB_NC_AccountRegistCommonController.TodoParam();
    req.todoParam.subject = '名刺交換';
    req.todoParam.activityDate = Date.today();
    req.todoParam.comment = '名刺交換したので、';
    req.todoParam.ownerId = cards[0].OwnerId;
    SB_NC_RegistExecutor.RegistResponse res = SB_NC_AccountRegistCommonController.registAccountContact(req);
    System.assertEquals(true, res.success);
  }

  // searchAccount 取引先責任者のSearch
  @isTest
  static void test_searchAccount() {
    Map<Id, Account> acnts = new Map<Id, Account>([SELECT Id, Name FROM Account LIMIT 1]);
    Test.setFixedSearchResults(new List<Id>(acnts.keySet()));

    List<SB_NC_RegistOptionCreater.RegistOption> options = SB_NC_AccountRegistCommonController.searchAccount(acnts.values()[0].Name, null);
    System.assertEquals(1, options.size());
  }

  @isTest
  static void test_searchAccount_withRectypeIds_Ng() {
    Map<Id, Account> acnts = new Map<Id, Account>([SELECT Id, Name FROM Account LIMIT 1]);
    Test.setFixedSearchResults(new List<Id>(acnts.keySet()));

    // レコードタイプが辺で例外
    List<String> recTypes = new List<String> {'1234567890', '1234567890'};
    List<SB_NC_RegistOptionCreater.RegistOption> options;
    Boolean bFalt = false;
    try {
      options = SB_NC_AccountRegistCommonController.searchAccount(acnts.values()[0].Name, recTypes);
    }
    catch(Exception ex) {
      bFalt = true;
    }
    System.assertEquals(true, bFalt);
  }

  // searchContact 取引先責任者のSearch
  @isTest
  static void test_searchContact() {
    Map<Id, Contact> conts = new Map<Id, Contact>([SELECT Id, Email, AccountId FROM Contact LIMIT 1]);
    Test.setFixedSearchResults(new List<Id>(conts.keySet()));

    List<SB_NC_RegistOptionCreater.RegistOption> options = SB_NC_AccountRegistCommonController.searchContact(conts.values()[0].Email, conts.values()[0].AccountId, null);
    System.assertEquals(1, options.size());
  }

  @isTest
  static void test_searchContact_withRectypeIds_Ng() {
    Map<Id, Contact> conts = new Map<Id, Contact>([SELECT Id, Email, AccountId FROM Contact LIMIT 1]);
    Test.setFixedSearchResults(new List<Id>(conts.keySet()));

    // レコードタイプが辺で例外
    List<String> recTypes = new List<String> {'1234567890', '1234567890'};
    List<SB_NC_RegistOptionCreater.RegistOption> options;
    Boolean bFalt = false;
    try {
      options = SB_NC_AccountRegistCommonController.searchContact(conts.values()[0].Email, conts.values()[0].AccountId, recTypes);
    }
    catch(Exception ex) {
      bFalt = true;
    }
    System.assertEquals(true, bFalt);
  }


  // searchRegistOptions 取引先責任者のSearch
  @isTest
  static void test_searchRegistOptions() {
    Map<Id, Contact> conts = new Map<Id, Contact>([SELECT Id, Email, AccountId FROM Contact LIMIT 1]);
    Test.setFixedSearchResults(new List<Id>(conts.keySet()));

    List<SB_NC_RegistOptionCreater.RegistOption> options = SB_NC_AccountRegistCommonController.searchRegistOptions(conts.values()[0].Email, 'Contact', conts.values()[0].AccountId, null);
    System.assertEquals(1, options.size());
  }
  
  @isTest
  static void test_searchRegistOptions_withRectypeIds_Ng() {
    Map<Id, Contact> conts = new Map<Id, Contact>([SELECT Id, Email, AccountId FROM Contact LIMIT 1]);
    Test.setFixedSearchResults(new List<Id>(conts.keySet()));

    // レコードタイプが辺で例外
    List<String> recTypes = new List<String> {'1234567890', '1234567890'};
    List<SB_NC_RegistOptionCreater.RegistOption> options;
    Boolean bFalt = false;
    try {
      options = SB_NC_AccountRegistCommonController.searchRegistOptions(conts.values()[0].Email, 'Contact', conts.values()[0].AccountId, recTypes);
    }
    catch(Exception ex) {
      bFalt = true;
    }
    System.assertEquals(true, bFalt);
  }

  // searchSObject 取引先責任者のSearch
  @isTest
  static void test_searchSObject() {
    Map<Id, Contact> conts = new Map<Id, Contact>([SELECT Id, Email, AccountId FROM Contact LIMIT 1]);
    Test.setFixedSearchResults(new List<Id>(conts.keySet()));
    List<SB_NC_RegistOptionCreater.RegistOption> options = SB_NC_AccountRegistCommonController.searchSObject(conts.values()[0].Email, 'Contact', conts.values()[0].AccountId, null);
    System.assertEquals(1, options.size());
  }

  @isTest
  static void test_searchSObject_withRectypeIds_Ng() {
    Map<Id, Contact> conts = new Map<Id, Contact>([SELECT Id, Email, AccountId FROM Contact LIMIT 1]);
    Test.setFixedSearchResults(new List<Id>(conts.keySet()));

    // レコードタイプが辺で例外
    List<String> recTypes = new List<String> {'1234567890', '1234567890'};
    List<SB_NC_RegistOptionCreater.RegistOption> options;
    Boolean bFalt = false;
    try {
      options = SB_NC_AccountRegistCommonController.searchSObject(conts.values()[0].Email, 'Contact', conts.values()[0].AccountId, recTypes);
    }
    catch(Exception ex) {
      bFalt = true;
    }
    System.assertEquals(true, bFalt);
  }

  //// getNamesWithRecordTypes
  //@isTest
  //static void test_getNamesWithRecordTypes() {
  //  List<NameCard__c> objs = [SELECT Id, Name FROM NameCard__c limit 10];
  //  System.assert(objs.isEmpty() == false);
  //  Id[] ids = new Id[objs.size()];
  //  for (NameCard__c obj : objs) {
  //    ids.add(obj.Id);
  //  }
  //  //Test.setFixedSearchResults(ids);
  //  //List<String> recTypes = new List<String>{'マスタ', null};
  //  List<String> names = SB_NC_AccountRegistCommonController.getNamesWithRecordTypes(new Set<Id>(ids), 'NameCard__c', null);
  //  System.assert(names.isEmpty() == false);
  //}

  // getRecentlyViewed
  @isTest
  static void test_getRecentlyViewed() {
    List<NameCard__c> objs = [SELECT Id, Name FROM NameCard__c limit 10];
    List<String> names = SB_NC_AccountRegistCommonController.getRecentlyViewed('NameCard__c', null);
    System.assert(names != null);
  }

  // searchSObjects
  @isTest
  static void test_searchSObjects() {
    List<NameCard__c> objs = [SELECT Id, Name FROM NameCard__c limit 10];
    Id[] ids = new Id[1];
    ids[0] = objs[0].Id;
    Test.setFixedSearchResults(ids);
    List<SOBject> res = SB_NC_AccountRegistCommonController.searchSObjects(objs[0].Name, 'NameCard__c', null);
    System.assert(!res.isEmpty());
  }

  // getRecordById
  @isTest
  static void test_getRecordById1() {
    List<NameCard__c> objs = [SELECT Id, Name FROM NameCard__c limit 10];
    SOBject obj = SB_NC_AccountRegistCommonController.getRecordById(objs[0].Id);
    System.assertEquals(objs[0].Id, obj.Id);
  }

  @isTest
  static void test_getRecordById2() {
    Account acnt = [SELECT Id FROM Account limit 1];
    SObject acntRec = SB_NC_AccountRegistCommonController.getRecordById(acnt.Id);
    System.assertEquals(acnt.Id, acntRec.Id);

    Contact cont = [SELECT Id FROM Contact limit 1];
    SObject contRec = SB_NC_AccountRegistCommonController.getRecordById(cont.Id);
    System.assertEquals(cont.Id, contRec.Id);
  }


}