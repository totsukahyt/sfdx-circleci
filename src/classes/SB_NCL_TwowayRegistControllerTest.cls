/**
 *
 * SB_NCL_TwowayRegistControllerTest
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
private class SB_NCL_TwowayRegistControllerTest
{

  public class TestDb extends SB_NCL_TestDB {

    public void updaeDeliveryStatus() {
      List<SmartViscaf__NameCard__c> cards = [SELECT Id, Name, SmartViscaf__Parent__c, SmartViscaf__Saishin__c, SmartViscaf__delivery_type__c FROM SmartViscaf__NameCard__c];
      for (SmartViscaf__NameCard__c c : cards) {
        c.SmartViscaf__delivery_type__c = '2';
        c.SmartViscaf__Saishin__c = true;
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
    TestDb db = new TestDb();
    db.initialize();
    db.updaeDeliveryStatus();
  }

  private static SelectOption getSomeViewOption() {
    List<SmartViscaf__NameCard__c> objs = [SELECT Id, Name FROM SmartViscaf__NameCard__c];
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
      List<SObject> objs = Database.query('SELECT Id, Name FROM SmartViscaf__NameCard__c LIMIT 10');
      System.assert(objs.isEmpty()==false);
      PageReference pageRef1 = Page.SB_NCL_PageDispacher;
      Test.setCurrentPage(pageRef1);
      String urlpath = URL.getCurrentRequestUrl().getProtocol() + '://' + URL.getCurrentRequestUrl().getHost();
      System.debug('URL' + urlpath);
      ApexPages.currentPage().getHeaders().put('Referer', urlpath);      // Referer
      //ApexPages.currentPage().getHeaders().put('USER-AGENT', 'edge');
      SelectOption viewOpt = getSomeViewOption();
      ApexPages.currentPage().getParameters().put('retUrl', 'fcf='+(viewOpt!=null ? viewOpt.getValue() : '111111111111111'));
      ApexPages.StandardSetController stdSetCtrl = new ApexPages.StandardSetController(objs);
      stdSetCtrl.setSelected(objs);
      SB_NCL_PageDispacherController ctrl1 = new SB_NCL_PageDispacherController(stdSetCtrl);
      SB_NCL_TwowayRegistController ctrlNoUse = new SB_NCL_TwowayRegistController(stdSetCtrl);    // 使ってないけど テストを通す
      PageReference pageRef2 = ctrl1.init();    // Cookie セットして振り分け先PageRefの取得
      System.assertEquals('SB_NCL_TwowayBulkRegist', ctrl1.toPage);
      Test.setCurrentPage(pageRef2);
      SB_NCL_TwowayRegistController ctrl2 = new SB_NCL_TwowayRegistController();
      System.assertEquals(objs.size(), ctrl2.targetIds.size());
    }
  }

  // LEX で リストビューから 取引先一括登録画面を開く Edge
  @isTest
  static void test_SB_NC_AccountBulkRegist_LEX_Edge() {
    List<User> users = [SELECT Id, Name FROM User WHERE IsActive = true limit 10];
    System.assertNotEquals(0, users.size());
    System.runAs(users[0]) {
      List<SObject> objs = Database.query('SELECT Id, Name FROM SmartViscaf__NameCard__c LIMIT 10');
      System.assert(objs.isEmpty()==false);
      PageReference pageRef1 = Page.SB_NCL_PageDispacher;
      Test.setCurrentPage(pageRef1);
      String urlpath = URL.getCurrentRequestUrl().getProtocol() + '://' + URL.getCurrentRequestUrl().getHost();
      ApexPages.currentPage().getHeaders().put('Referer', urlpath);      // Referer
      ApexPages.currentPage().getHeaders().put('USER-AGENT', 'Windows edge');
      SelectOption viewOpt = getSomeViewOption();
      //ApexPages.currentPage().getParameters().put('viewId', viewOpt!=null ? viewOpt.getValue() : '111111111111111');
      ApexPages.currentPage().getParameters().put('vfRetURLInSFX', 'filterName='+(viewOpt!=null ? viewOpt.getValue() : '111111111111111'));
      ApexPages.StandardSetController stdSetCtrl = new ApexPages.StandardSetController(objs);
      stdSetCtrl.setSelected(objs);
      SB_NCL_PageDispacherController ctrl1 = new SB_NCL_PageDispacherController(stdSetCtrl);
      SB_NCL_TwowayRegistController ctrlNoUse = new SB_NCL_TwowayRegistController(stdSetCtrl);
      PageReference pageRef2 = ctrl1.init();    // Cookie セットして振り分け先PageRefの取得
      System.assertEquals('SB_NCL_TwowayBulkRegistEdge', ctrl1.toPage);
      Test.setCurrentPage(pageRef2);
      SB_NCL_TwowayRegistController ctrl2 = new SB_NCL_TwowayRegistController();
      System.assertEquals(objs.size(), ctrl2.targetIds.size());
    }
  }

  // LEX で リストビューから 取引先一括登録画面を開く Edge
  @isTest
  static void test_SB_NC_AccountBulkRegist_LimitOver() {
    List<User> users = [SELECT Id, Name FROM User WHERE IsActive = true limit 10];
    System.assertNotEquals(0, users.size());
    System.runAs(users[0]) {
      List<SObject> objs = Database.query('SELECT Id, Name FROM SmartViscaf__NameCard__c LIMIT 20');
      System.assert(objs.isEmpty()==false);
      PageReference pageRef1 = Page.SB_NCL_PageDispacher;
      Test.setCurrentPage(pageRef1);
      String urlpath = URL.getCurrentRequestUrl().getProtocol() + '://' + URL.getCurrentRequestUrl().getHost();
      ApexPages.currentPage().getHeaders().put('Referer', urlpath);      // Referer
      ApexPages.currentPage().getHeaders().put('USER-AGENT', 'Windows edge');
      SelectOption viewOpt = getSomeViewOption();
      //ApexPages.currentPage().getParameters().put('viewId', viewOpt!=null ? viewOpt.getValue() : '111111111111111');
      ApexPages.currentPage().getParameters().put('vfRetURLInSFX', 'filterName='+(viewOpt!=null ? viewOpt.getValue() : '111111111111111'));
      ApexPages.StandardSetController stdSetCtrl = new ApexPages.StandardSetController(objs);
      stdSetCtrl.setSelected(objs);
      SB_NCL_PageDispacherController ctrl1 = new SB_NCL_PageDispacherController(stdSetCtrl);
      SB_NCL_TwowayRegistController ctrlNoUse = new SB_NCL_TwowayRegistController(stdSetCtrl);
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
      List<SObject> objs = Database.query('SELECT Id, Name FROM SmartViscaf__NameCard__c LIMIT 10');
      System.assert(objs.isEmpty()==false);
      PageReference pageRef1 = Page.SB_NCL_PageDispacher;
      Test.setCurrentPage(pageRef1);
      String urlpath = URL.getCurrentRequestUrl().getProtocol() + '://' + URL.getCurrentRequestUrl().getHost();
      ApexPages.currentPage().getHeaders().put('Referer', urlpath);      // Referer
      ApexPages.currentPage().getHeaders().put('USER-AGENT', 'Windows Trident/7.0');
      SelectOption viewOpt = getSomeViewOption();
      //ApexPages.currentPage().getParameters().put('viewId', viewOpt!=null ? viewOpt.getValue() : '111111111111111');
      ApexPages.currentPage().getParameters().put('vfRetURLInSFX', 'filterName='+(viewOpt!=null ? viewOpt.getValue() : '111111111111111'));
      ApexPages.StandardSetController stdSetCtrl = new ApexPages.StandardSetController(objs);
      stdSetCtrl.setSelected(objs);
      SB_NCL_PageDispacherController ctrl1 = new SB_NCL_PageDispacherController(stdSetCtrl);
      SB_NCL_TwowayRegistController ctrlNoUse = new SB_NCL_TwowayRegistController(stdSetCtrl);
      PageReference pageRef2 = ctrl1.init();    // Cookie セットして振り分け先PageRefの取得
      System.assertEquals('SB_NCL_TwowayBulkRegistEdge', ctrl1.toPage);
      Test.setCurrentPage(pageRef2);
      SB_NCL_TwowayRegistController ctrl2 = new SB_NCL_TwowayRegistController();
      System.assertEquals(objs.size(), ctrl2.targetIds.size());
    }
  }

  // LEX で 詳細画面から 取引先登録画面を開く
  @isTest
  static void test_SB_NC_AccountRegist_LEX() {
    List<User> users = [SELECT Id, Name FROM User WHERE IsActive = true limit 10];
    System.assertNotEquals(0, users.size());
    System.runAs(users[0]) {
      List<SObject> objs = Database.query('SELECT Id, Name FROM SmartViscaf__NameCard__c LIMIT 10');
      System.assert(objs.isEmpty()==false);
      PageReference pageRef = Page.SB_NCL_PageDispacher;
      Test.setCurrentPage(pageRef);
      String urlpath = URL.getCurrentRequestUrl().getProtocol() + '://' + URL.getCurrentRequestUrl().getHost();
      ApexPages.currentPage().getHeaders().put('Referer', urlpath);      // Referer
      ApexPages.currentPage().getParameters().put('id', objs[0].Id);
      ApexPages.currentPage().getParameters().put('page', 'SB_NCL_TwowayRegist');
      ApexPages.currentPage().getParameters().put('vfRetURLInSFX', urlpath);
      SB_NCL_PageDispacherController ctrl1 = new SB_NCL_PageDispacherController();
      PageReference pageRef2 = ctrl1.init();
      System.assertEquals('SB_NCL_TwowayRegist', ctrl1.toPage);
      Test.setCurrentPage(pageRef2);
      SB_NCL_TwowayRegistController ctrl2 = new SB_NCL_TwowayRegistController();
      System.assertEquals(objs[0].Id, ctrl2.targetId);
    }
  }

  // LEX で 詳細画面から 取引先登録画面を開く Edge
  @isTest
  static void test_SB_NC_AccountRegist_LEX_Edge() {
    List<User> users = [SELECT Id, Name FROM User WHERE IsActive = true limit 10];
    System.assertNotEquals(0, users.size());
    System.runAs(users[0]) {
      List<SObject> objs = Database.query('SELECT Id, Name FROM SmartViscaf__NameCard__c LIMIT 10');
      System.assert(objs.isEmpty()==false);
      PageReference pageRef = Page.SB_NCL_PageDispacher;
      Test.setCurrentPage(pageRef);
      String urlpath = URL.getCurrentRequestUrl().getProtocol() + '://' + URL.getCurrentRequestUrl().getHost();
      ApexPages.currentPage().getHeaders().put('Referer', urlpath);      // Referer
      ApexPages.currentPage().getHeaders().put('USER-AGENT', 'Windows edge');
      ApexPages.currentPage().getParameters().put('id', objs[0].Id);
      ApexPages.currentPage().getParameters().put('page', 'SB_NCL_TwowayRegist');
      ApexPages.currentPage().getParameters().put('vfRetURLInSFX', urlpath);
      SB_NCL_PageDispacherController ctrl1 = new SB_NCL_PageDispacherController();
      PageReference pageRef2 = ctrl1.init();
      System.assertEquals('SB_NCL_TwowayRegistEdge', ctrl1.toPage);
      Test.setCurrentPage(pageRef2);
      SB_NCL_TwowayRegistController ctrl2 = new SB_NCL_TwowayRegistController();
      System.assertEquals(objs[0].Id, ctrl2.targetId);
    }
  }

  // LEX で 詳細画面から 取引先登録画面を開く IE11
  @isTest
  static void test_SB_NC_AccountRegist_LEX_IE11() {
    List<User> users = [SELECT Id, Name FROM User WHERE IsActive = true limit 10];
    System.assertNotEquals(0, users.size());
    System.runAs(users[0]) {
      List<SObject> objs = Database.query('SELECT Id, Name FROM SmartViscaf__NameCard__c LIMIT 10');
      System.assert(objs.isEmpty()==false);
      PageReference pageRef = Page.SB_NCL_PageDispacher;
      Test.setCurrentPage(pageRef);
      String urlpath = URL.getCurrentRequestUrl().getProtocol() + '://' + URL.getCurrentRequestUrl().getHost();
      ApexPages.currentPage().getHeaders().put('Referer', urlpath);      // Referer
      ApexPages.currentPage().getHeaders().put('USER-AGENT', 'Windows Trident/7.0');
      ApexPages.currentPage().getParameters().put('id', objs[0].Id);
      ApexPages.currentPage().getParameters().put('page', 'SB_NCL_TwowayRegist');
      ApexPages.currentPage().getParameters().put('vfRetURLInSFX', urlpath);
      SB_NCL_PageDispacherController ctrl1 = new SB_NCL_PageDispacherController();
      PageReference pageRef2 = ctrl1.init();
      // Classic の 取引先登録画面
      System.assertEquals('SB_NameCard_TwowayRegist', ctrl1.toPage);
      Test.setCurrentPage(pageRef2);
      SB_NCL_TwowayRegistController ctrl2 = new SB_NCL_TwowayRegistController();
      System.assertEquals(objs[0].Id, ctrl2.targetId);
    }
  }

  @isTest
  static void test_SB_NC_AccountRegist_NoTarget() {
    List<User> users = [SELECT Id, Name FROM User WHERE IsActive = true limit 10];
    System.assertNotEquals(0, users.size());
    System.runAs(users[0]) {
      List<SObject> objs = Database.query('SELECT Id, Name FROM SmartViscaf__NameCard__c LIMIT 10');
      System.assert(objs.isEmpty()==false);
      PageReference pageRef = Page.SB_NCL_PageDispacher;
      Test.setCurrentPage(pageRef);
      String urlpath = URL.getCurrentRequestUrl().getProtocol() + '://' + URL.getCurrentRequestUrl().getHost();
      ApexPages.currentPage().getHeaders().put('Referer', urlpath);      // Referer
      ApexPages.currentPage().getHeaders().put('USER-AGENT', 'Windows edge');
      //ApexPages.currentPage().getParameters().put('id', objs[0].Id);
      ApexPages.currentPage().getParameters().put('page', 'SB_NCL_TwowayRegist');
      ApexPages.currentPage().getParameters().put('vfRetURLInSFX', urlpath);
      SB_NCL_PageDispacherController ctrl1 = new SB_NCL_PageDispacherController();
      PageReference pageRef2 = ctrl1.init();
      System.assertEquals('SB_NCL_TwowayRegistEdge', ctrl1.toPage);
      Test.setCurrentPage(pageRef2);
      SB_NCL_TwowayRegistController ctrl2 = new SB_NCL_TwowayRegistController();
      System.assert(String.isBlank(ctrl2.targetId));
    }
  }

  // getNamespacePrefix getUrlRoot
  @isTest
  static void test_Etc() {
    SB_NCL_TwowayRegistController ctrl = new SB_NCL_TwowayRegistController();
    System.debug(ctrl.getNameSpace());
    System.assertEquals(SB_NameCardL_Util.getNamespacePrefix(), ctrl.getNameSpace());
    String url1 = ctrl.getUrlRoot('https://sunbridge.com/smartvisca/about');
    System.assertEquals('https://sunbridge.com', url1);
    String url2 = ctrl.getUrlRoot('https://');
    System.assertEquals('https://', url2);
  }

  // getSVConfig
  @isTest
  static void test_getSVConfig() {
    System.assert(SB_NCL_TwowayRegistController.getSVConfig() != null);
  }

  // getListViewOptions
  @isTest
  static void test_getListViewOptions() {
    List<SB_NCL_ListViewConfig.ListViewInfo> views = SB_NCL_TwowayRegistController.getListViewOptions('SmartViscaf__NameCard__c', 'Id, Name');
    List<SmartViscaf__NameCard__c> objs = [SELECT Id, Name FROM SmartViscaf__NameCard__c];
    ApexPages.StandardSetController scon = new ApexPages.StandardSetController(objs);
    System.assertEquals(scon.getListViewOptions().size(), views.size());
  }

  // getListViewConfig
  @isTest
  static void test_getListViewConfig() {
    SB_NCL_ListViewConfig viewConfig = SB_NCL_TwowayRegistController.getListViewConfig();
    System.assertEquals('SmartViscaf__NameCard__c', viewConfig.objectName);
  }

  // getFilteredRecords
  @isTest
  static void test_getFilteredRecords() {
    Account acnt = [SELECT Id FROM Account limit 1];
    SB_NCL_TwowayRegistController.FilteredQueryRequest req = new SB_NCL_TwowayRegistController.FilteredQueryRequest();
    req.setDummy();
    SB_NCL_TwowayRegistController.FilteredQueryResponse res = SB_NCL_TwowayRegistController.getFilteredRecords(req);
    System.assertEquals(req.obj_name, res.req.obj_name);
  }

  // getRecordTypeInfo
  @isTest
  static void test_getRecordTypeInfos() {
    List<String> objnames = new List<String> {'Account'};
    Map<String, SB_NCL_TwowayRegistController.RecordTypeInfos> recTypeInfos = SB_NCL_TwowayRegistController.getRecordTypeInfos(objnames);
    Map<String, Schema.RecordTypeInfo> mapRecordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
    Integer cnt = 0;
    for (Schema.RecordTypeInfo info : mapRecordTypes.values()) {
      if (info.isAvailable() == false) continue;   // ユーザが使用可能なものだけ
      if (info.isMaster() == true) continue;   // マスターは除外
      cnt++;
    }
    System.assertEquals(cnt, recTypeInfos.get('Account').infos.size());
  }

  // GetRegistOptions のテスト
  @isTest
  static void test_getRegistOptions() {
    SB_NCL_TwowayRegistController.QueryOption opt = new SB_NCL_TwowayRegistController.QueryOption();
    opt.querySite = true;
    opt.queryState = true;
    opt.queryCity = true;
    opt.queryZip = true;
    //opt.acntRecTypeIds = new List<String> {};
    //opt.contRecTypeIds = null;
    List<SmartViscaf__NameCard__c> cards = [SELECT Id, Name FROM SmartViscaf__NameCard__c LIMIT 100];
    List<Id> ncIds = new List<Id>();
    for (SmartViscaf__NameCard__c card : cards) {
      ncIds.add(card.Id);
    }
    // リクエストの引数
    SB_NCL_TwowayRegistController.RegistOptionRequest req = new SB_NCL_TwowayRegistController.RegistOptionRequest(ncIds, opt);
    List<SB_NCL_RegistOptionCreater.Card_RegistOption> reg_opts = SB_NCL_TwowayRegistController.getRegistOptions(req);
    System.assertEquals(cards.size(), reg_opts.size());
    for (SB_NCL_RegistOptionCreater.Card_RegistOption reg_opt : reg_opts) {
      System.assertEquals(3, reg_opt.options.size());
    }
  }


  @isTest
  static void test_getNameCard() {
    List<SmartViscaf__NameCard__c> objs = [SELECT Id, Name FROM SmartViscaf__NameCard__c LIMIT 10];
    SB_NCL_NameCardDTO record = SB_NCL_TwowayRegistController.getNameCard(objs[0].Id);
    System.assertEquals(objs[0].Name, record.name);
    Boolean bFalt = false;
    try {
      SB_NCL_TwowayRegistController.getNameCard('111111111111111');
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
    List<SmartViscaf__NameCard__c> cards = [SELECT Id, Name FROM SmartViscaf__NameCard__c WHERE SmartViscaf__company_name__c IN :company_names];
    System.assert(cards.isEmpty() == false);
    SB_NCL_TwowayRegistController.QueryOption query_opt = new SB_NCL_TwowayRegistController.QueryOption();
    query_opt.bulkRegist = true;      // TURE:一括登録 FALSE:個別登録
    query_opt.querySite = true;      // 所属名を条件にして検索 0: 取引先名と所属名で検索 1,その他: 取引先名のみで検索
    query_opt.queryState = true;     // 都道府県を条件にして検索
    query_opt.queryCity = true;      // 市区郡を条件にして検索
    query_opt.queryZip = true;       // 郵便番号を条件にして検索
    List<SB_NCL_RegistOptionCreater.RegistOption> options = SB_NCL_TwowayRegistController.getAccountOptions(cards[0].Id, query_opt);
    System.assert(options.isEmpty() == false);
    for (SB_NCL_RegistOptionCreater.RegistOption opt : options) {
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
    List<SmartViscaf__NameCard__c> cards = [SELECT Id, Name, SmartViscaf__company_name__c, SmartViscaf__account__c FROM SmartViscaf__NameCard__c WHERE SmartViscaf__company_name__c IN :company_names];
    System.assert(cards.isEmpty() == false);
    SB_NCL_TwowayRegistController.QueryOption query_opt = new SB_NCL_TwowayRegistController.QueryOption();
    query_opt.bulkRegist = true;      // TURE:一括登録 FALSE:個別登録
    query_opt.querySite = true;      // 所属名を条件にして検索 0: 取引先名と所属名で検索 1,その他: 取引先名のみで検索
    query_opt.queryState = true;     // 都道府県を条件にして検索
    query_opt.queryCity = true;      // 市区郡を条件にして検索
    query_opt.queryZip = true;       // 郵便番号を条件にして検索
    Account acnt = [SELECT Id, Name FROM Account WHERE Name = :cards[0].SmartViscaf__company_name__c LIMIT 1];
    List<SB_NCL_RegistOptionCreater.RegistOption> options = SB_NCL_TwowayRegistController.getContactOptions(cards[0].Id, acnt.Id, query_opt);
    System.assert(options.isEmpty() == false);
    for (SB_NCL_RegistOptionCreater.RegistOption opt : options) {
      System.assertEquals(false, opt.selected);
    }
  }

  // registAccountContact 登録実行メソッドのテスト
  @isTest
  static void test_registAccountContact() {
    List<Account> acnts =[SELECT Id, Name FROM Account LIMIT 10];
    Set<String> company_names = new Set<String>();
    for (Account acnt : acnts) {
      company_names.add(acnt.Name);
    }
    List<SmartViscaf__NameCard__c> cards = [SELECT Id, Name, OwnerId, SmartViscaf__company_name__c, SmartViscaf__account__c FROM SmartViscaf__NameCard__c WHERE SmartViscaf__company_name__c IN :company_names];
    System.assert(cards.isEmpty() == false);
    Account acnt = [SELECT Id, Name FROM Account WHERE Name = :cards[0].SmartViscaf__company_name__c LIMIT 1];
    Contact cont = [SELECT Id, Name FROM Contact WHERE AccountId = :acnt.Id LIMIT 1];
    SB_NCL_TwowayRegistController.RegistRequest req = new SB_NCL_TwowayRegistController.RegistRequest();
    req.targets = new List<SB_NCL_TwowayRegistController.RegistTarget>();
    SB_NCL_TwowayRegistController.RegistTarget target = new SB_NCL_TwowayRegistController.RegistTarget();
    target.cardId = cards[0].Id;
    target.acntId = acnt.Id;
    target.contId = cont.Id;
    target.leadId = null;
    target.createTodo = true;
    target.todoDate = Date.today();
    req.targets.add(target);
    req.acntParam = new SB_NCL_TwowayRegistController.RegistParam();
    req.acntParam.overwrite = true;
    req.contParam = new SB_NCL_TwowayRegistController.RegistParam();
    req.contParam.overwrite = true;
    //req.someParam = new SB_NCL_TwowayRegistController.RegistParam();
    //req.someParam.overwrite = true;
    req.todoParam = new SB_NCL_TwowayRegistController.TodoParam();
    req.todoParam.subject = '名刺交換';
    req.todoParam.activityDate = Date.today();
    req.todoParam.comment = '名刺交換したので、';
    req.todoParam.ownerId = cards[0].OwnerId;
    SB_NameCardL_RegistHelper.RegistResponse res = SB_NCL_TwowayRegistController.registAccountContact(req);
    System.assertEquals(true, res.success);
  }

  // searchAccount 取引先責任者のSearch
  @isTest
  static void test_searchAccount() {
    List<Account> acnts = [SELECT Id, Name FROM Account];
    Id[] ids = new Id[1];
    ids[0] = acnts[0].Id;
    Test.setFixedSearchResults(ids);
    List<SB_NCL_RegistOptionCreater.RegistOption> options = SB_NCL_TwowayRegistController.searchAccount(acnts[0].Name, null);
    System.assertEquals(1, options.size());

    // レコードタイプが辺で例外
    Boolean bFalt = false;
    List<String> recTypes = new List<String> {'1234567890', '1234567890'};
    options.clear();
    try {
      options = SB_NCL_TwowayRegistController.searchAccount(acnts[0].Name, recTypes);
    }
    catch(Exception ex) {
      bFalt = true;
    }
    System.assertEquals(0, options.size());
  }

  // searchContact 取引先責任者のSearch
  @isTest
  static void test_searchContact() {
    List<Contact> conts = [SELECT Id, Email, AccountId FROM Contact];
    Id[] ids = new Id[1];
    ids[0] = conts[0].Id;
    Test.setFixedSearchResults(ids);
    List<SB_NCL_RegistOptionCreater.RegistOption> options = SB_NCL_TwowayRegistController.searchContact(conts[0].Email, conts[0].AccountId, null);
    System.assertEquals(1, options.size());

    // レコードタイプが辺で例外
    Boolean bFalt = false;
    List<String> recTypes = new List<String> {'1234567890', '1234567890'};
    options.clear();
    try {
      options = SB_NCL_TwowayRegistController.searchContact(conts[0].Email, conts[0].AccountId, recTypes);
    }
    catch(Exception ex) {
      bFalt = true;
    }
    System.assertEquals(0, options.size());
  }


  // searchRegistOptions 取引先責任者のSearch
  @isTest
  static void test_searchRegistOptions() {
    List<Contact> conts = [SELECT Id, Email, AccountId FROM Contact];
    Id[] ids = new Id[1];
    ids[0] = conts[0].Id;
    Test.setFixedSearchResults(ids);
    List<SB_NCL_RegistOptionCreater.RegistOption> options = SB_NCL_TwowayRegistController.searchRegistOptions(conts[0].Email, 'Contact', conts[0].AccountId, null);
    System.assertEquals(1, options.size());

    // レコードタイプが辺で例外
    Boolean bFalt = false;
    List<String> recTypes = new List<String> {'1234567890', '1234567890'};
    options.clear();
    try {
      options = SB_NCL_TwowayRegistController.searchRegistOptions(conts[0].Email, 'Contact', conts[0].AccountId, recTypes);
    }
    catch(Exception ex) {
      bFalt = true;
    }
    System.assertEquals(0, options.size());
  }

  // searchSObject 取引先責任者のSearch
  @isTest
  static void test_searchSObject() {
    List<Contact> conts = [SELECT Id, Email, AccountId FROM Contact];
    Id[] ids = new Id[1];
    ids[0] = conts[0].Id;
    Test.setFixedSearchResults(ids);
    List<SB_NCL_RegistOptionCreater.RegistOption> options = SB_NCL_TwowayRegistController.searchSObject(conts[0].Email, 'Contact', conts[0].AccountId, null);
    System.assertEquals(1, options.size());

    // レコードタイプが辺で例外
    Boolean bFalt = false;
    List<String> recTypes = new List<String> {'1234567890', '1234567890'};
    options.clear();
    try {
      options = SB_NCL_TwowayRegistController.searchSObject(conts[0].Email, 'Contact', conts[0].AccountId, recTypes);
    }
    catch(Exception ex) {
      bFalt = true;
    }
    System.assertEquals(0, options.size());
  }

  //// getNamesWithRecordTypes
  //@isTest
  //static void test_getNamesWithRecordTypes() {
  //  List<SmartViscaf__NameCard__c> objs = [SELECT Id, Name FROM SmartViscaf__NameCard__c limit 10];
  //  System.assert(objs.isEmpty() == false);
  //  Id[] ids = new Id[objs.size()];
  //  for (SmartViscaf__NameCard__c obj : objs) {
  //    ids.add(obj.Id);
  //  }
  //  //Test.setFixedSearchResults(ids);
  //  //List<String> recTypes = new List<String>{'マスタ', null};
  //  List<String> names = SB_NCL_TwowayRegistController.getNamesWithRecordTypes(new Set<Id>(ids), 'SmartViscaf__NameCard__c', null);
  //  System.assert(names.isEmpty() == false);
  //}

  // getRecentlyViewed
  @isTest
  static void test_getRecentlyViewed() {
    List<SmartViscaf__NameCard__c> objs = [SELECT Id, Name FROM SmartViscaf__NameCard__c limit 10];
    List<String> names = SB_NCL_TwowayRegistController.getRecentlyViewed('SmartViscaf__NameCard__c', null);
    System.assert(names != null);
  }

  // searchSObjects
  @isTest
  static void test_searchSObjects() {
    List<SmartViscaf__NameCard__c> objs = [SELECT Id, Name FROM SmartViscaf__NameCard__c limit 10];
    Id[] ids = new Id[1];
    ids[0] = objs[0].Id;
    Test.setFixedSearchResults(ids);
    List<SOBject> res = SB_NCL_TwowayRegistController.searchSObjects(objs[0].Name, 'SmartViscaf__NameCard__c', null);
    System.assert(!res.isEmpty());
  }

  // getRecordById
  @isTest
  static void test_getRecordById1() {
    List<SmartViscaf__NameCard__c> objs = [SELECT Id, Name FROM SmartViscaf__NameCard__c limit 10];
    SOBject obj = SB_NCL_TwowayRegistController.getRecordById('SmartViscaf__NameCard__c', objs[0].Id);
    System.assertEquals(objs[0].Id, obj.Id);
  }

  @isTest
  static void test_getRecordById2() {
    Account acnt = [SELECT Id FROM Account limit 1];
    SObject acntRec = SB_NCL_TwowayRegistController.getRecordById(acnt.Id);
    System.assertEquals(acnt.Id, acntRec.Id);

    Contact cont = [SELECT Id FROM Contact limit 1];
    SObject contRec = SB_NCL_TwowayRegistController.getRecordById(cont.Id);
    System.assertEquals(cont.Id, contRec.Id);
  }


}