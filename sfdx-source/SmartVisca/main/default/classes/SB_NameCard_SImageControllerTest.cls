/**
 *
 * SB_NameCard_SImageControllerTest
 * SB_NameCard_SImageController  のテストクラス SB_NameCard_SControllerTest からシュリンク
 *
 * Copyright (C) 2014 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2014.5.xx
 *  @Version 2      2016.9.xx
 *  @Version 3      2018.03.xx v1.22
 *
 **/
@isTest
private class SB_NameCard_SImageControllerTest {

  static final String STR_LISTNAME = '名刺のリスト名';   //

  @testSetup
  static void setupNameCards() {
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(
      Name='名刺 太郎'
      , person_name_last__c= '名刺'
      , person_name_first__c='太郎'
      , email__c='taro@test.com'
      , company_name__c= 'テスト株式会社'
      , division__c = '本社'
      , title_name__c = '役職'
      , tel1__c= '03-3333-3333'
      , zip_code__c = '115-0022'
      , address_pref__c = '東京都'
      , address__c = '渋谷区'
      , address_bld__c = '恵比寿1−5−5'
      , list_name__c = STR_LISTNAME
      , memo__c = 'メモ'
      , freehandmemo__c = '自由記述'
      , delivery_type__c='1'
    ));
    listCard.add(new NameCard__c(
      Name='名刺 二郎'
      , person_name_last__c= '名刺'
      , person_name_first__c='二郎'
      , email__c='jiro@test.com'
      , company_name__c= 'テスト株式会社'
      , division__c = '本社'
      , title_name__c = '役職'
      , tel1__c= '03-3333-3333'
      , zip_code__c = '115-0022'
      , address_pref__c = '東京都'
      , address__c = '渋谷区'
      , address_bld__c = '恵比寿1−5−5'
      , list_name__c = STR_LISTNAME
      , memo__c = 'メモ'
      , freehandmemo__c = '自由記述'
      , delivery_type__c='1'
    ));
    insert listCard;
  }

  @isTest
  static void test_constructor() {
    SB_NameCard_SImageController ctrl = new SB_NameCard_SImageController();
    System.assertEquals(false, ctrl.debug);
    System.assertEquals(true, ctrl.isIOS8('iPhone OS/8.1 (iPad) Salesforce1/6.0.4(3000747) XBranding/1.0 SalesforceTouchContainer/2.0 Mozilla/5.0 (iPad; CPU OS 8_1 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Mobile/12B410 (413432672)'));
    System.assertEquals(false, ctrl.isIOS8('any os'));
  }

  // getSVConfig のテスト
  @isTest
  static void test_getSVConfig() {
    Test.startTest();
    SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    Map<String, Object> config = SB_NameCard_SImageController.getSVConfig();
    System.assert(svConfig.Id == null || svConfig.SEnableNameCardEdit__c == (Boolean)config.get('sEnableNameCardEdit'));
    Test.stopTest();
  }

  private with sharing class SObjectCreater {
    private Schema.SObjectType oType;
    public SObjectCreater(String objName) {
      this.oType = Schema.getGlobalDescribe().get(objName);
    }
    public SObject create(Map<String, Object> values) {
      SObject result = this.oType.newSObject();
      for(String key : values.keySet()) {
        result.put(key, values.get(key));
      }
      return result;
    }
  }

  // タグ or 名刺リスト に 名刺を追加するテスト タグ一覧でのメソッド
  @isTest
  static void test_getTagsOrListnames() {
    List<NameCard__c> cards = [SELECT Id, Name FROM NameCard__c];
    Integer cntTag = 2;
    if (SB_NameCard_SImageController.isEnableNameCardTagPersonal() == true) {
      // 動的APEXでつくらないと、インストールでエラーになる?
      SObjectCreater tagCreater = new SObjectCreater(SB_NameCard_Util.getNamespacePrefix_x() + 'NameCard__tag');
      List<SObject> tags = new List<SObject>();
      for (NameCard__c card : cards) {
        tags.add(tagCreater.create(new Map<String, Object> { 'Name'=>'タグ その１', 'Type'=>'Personal', 'ItemId'=>card.Id }));
        tags.add(tagCreater.create(new Map<String, Object> { 'Name'=>'タグ その２', 'Type'=>'Personal', 'ItemId'=>card.Id }));
      }
      insert tags;
    }

    Test.startTest();
    // 全タグを取得
    SB_NameCard_SImageController.GetTagsRequest getTagReq = new SB_NameCard_SImageController.GetTagsRequest(1, 0, null);
    List<SB_NameCard_TagAndListCollector.NameCardTagOrList> tags = SB_NameCard_SImageController.getTagsOrListnames(getTagReq);
    // パッケージ作成環境とかで、タグがつかえないところでテストするから対策
    if (SB_NameCard_SImageController.isEnableNameCardTagPersonal() == true) {
      // テストで TagDefinition のクエリが0件でもどるので、
      List<SObject> tagds = Database.query('SELECT Id, Name, Type FROM TagDefinition WHERE Name LIKE \'タグ%\' AND Type=\'Personal\'');
      System.assertEquals(tagds.size(), tags.size());
    }
    else {
      System.assertEquals(0, tags.size());
    }

    // 指定した名刺データで使ってないタグを取得
    tags.clear();
    SB_NameCard_SImageController.GetTagsRequest getTagReqExclude = new SB_NameCard_SImageController.GetTagsRequest(1, 0, cards[0].Id);
    tags = SB_NameCard_SImageController.getTagsOrListnames(getTagReqExclude);
    // 全部使ってるし 0
    System.assertEquals(0, tags.size());

    // 名刺リスト
    tags.clear();
    SB_NameCard_SImageController.GetTagsRequest getListReq = new SB_NameCard_SImageController.GetTagsRequest(2, -1, null);
    tags = SB_NameCard_SImageController.getTagsOrListnames(getListReq);
    System.assertEquals(1, tags.size());

    // タグと名刺リストの両方
    SB_NameCard_SImageController.GetTagsRequest getAllReq = new SB_NameCard_SImageController.GetTagsRequest(-1, -1, null);
    tags = SB_NameCard_SImageController.getTagsOrListnames(getAllReq);
    // パッケージ作成環境とかで、タグがつかえないところでテストするから対策
    if (SB_NameCard_SImageController.isEnableNameCardTagPersonal() == true) {
      // テストで TagDefinition のクエリが0件でもどるので、
      List<SObject> tagds = Database.query('SELECT Id, Name, Type FROM TagDefinition WHERE Name LIKE \'タグ%\' AND Type=\'Personal\'');
      System.assertEquals(tagds.size()+1, tags.size());
    }
    else {
      System.assertEquals(1, tags.size());
    }

    Test.stopTest();
  }

  // 名刺利用可能ユーザの 部署−ユーザs 取得
  // getDepartmentUsers
  @isTest
  static void test_getDepartmentUsers() {
    Test.startTest();
    SB_NameCard_UserList.DepartmentUsers deptUsers1 = SB_NameCard_UserList.getDepartmentUsers(null, null);
    SB_NameCard_UserList.DepartmentUsers deptUsers2 = SB_NameCard_SImageController.getDepartmentUsers(null, null);
    System.assertEquals(deptUsers1.departments.size(), deptUsers2.departments.size());
    Test.stopTest();
  }

  // ユーザの設定を保存する のをテスト
  @isTest
  static void test_saveUserSetting() {
    // 更新用データ
    Map<String, Object> values = new Map<String, Object>();
    values.put('svcRepeatMemo', true); //  SmartViscaカメラ:メモを引き継ぐ SvcRepeatMemo__c	チェックボックス
    values.put('svcShadeFilter', true); //  SmartViscaカメラ:陰影を除去する SvcShadeFilter__c	チェックボックス
    values.put('svcNoiseFilter', true); //  SmartViscaカメラ:陰影除去後のゴミを取る SvcNoiseFilter__c	チェックボックス
    values.put('svcGabageFilter', true); //  SmartViscaカメラ:陰影除去後、さらにゴミを取る SvcGabageFilter__c	チェックボックス
    // values.put('svcImageSize', 10000); //  SmartViscaカメラ:画像サイズ SvcImageSize__c	数値(18、0)
    values.put('svcImageTransform', true); //  SmartViscaカメラ:画像補正する SvcImageTransform__c	チェックボックス
    // values.put('svcInputImageSize', 40000); //  SmartViscaカメラ:画像補正に使う長辺のサイズ SvcInputImageSize__c	数値(18、0)
    values.put('svcConfirmTransform', true); //  SmartViscaカメラ:画像補正の結果を確認する SvcConfirmTransform__c	チェックボックス
    values.put('svcShowTranslateFailure', true); //  SmartViscaカメラ:画像補正の失敗を表示する SvcShowTranslateFailure__c	チェックボックス
    values.put('svcFreehandMemo', true); //  SmartViscaカメラ:手書きメモをデジタル化する（表面のみ） SvcFreehandMemo__c	チェックボックス
    values.put('svcLastListName', '前回のリスト名1'); //  SmartViscaカメラ:前回のリスト名 SvcLastListName__c	テキスト(255)
    values.put('svcFrontOnly', true); //  SmartViscaカメラ:表面のみをデジタル化する SvcFrontOnly__c	チェックボックス
    values.put('svcKeepListName', true); //  SmartViscaカメラ:名刺リスト名を覚えておく SvcKeepListName__c	チェックボックス
    values.put('svcRepeatExchangeDate', true); //  SmartViscaカメラ:名刺交換日を引き継ぐ SvcRepeatExchangeDate__c	チェックボックス
    values.put('svcDoubleSide', true); //  SmartViscaカメラ:裏面も撮る SvcDoubleSide__c	チェックボックス
    values.put('AAAAA', true); // ない項目
    values.put('ZZZZZ', true); // ない項目
    SB_NameCard_SImageController.saveUserSetting(values);

    Id userId = UserInfo.getUserId();
    List<NameCardUserSetting__c> settings = [SELECT Id, SvcRepeatMemo__c, SvcLastListName__c FROM NameCardUserSetting__c WHERE User__c = :userId];
    System.assertEquals(1, settings.size());
    System.assertEquals(values.get('svcRepeatMemo'), settings[0].SvcRepeatMemo__c);
    // System.assertEquals(values.get('svcImageSize'), settings[0].SvcImageSize__c);
    System.assertEquals(values.get('svcLastListName'), settings[0].SvcLastListName__c);
  }

  @isTest
  static void test_saveUserSetting_Exception() {
    // 更新用データ
    Map<String, Object> values = new Map<String, Object>();
    values.put('svcRepeatMemo', Datetime.now()); // SmartViscaカメラ:メモを引き継ぐ SvcRepeatMemo__c	チェックボックス
    // values.put('svcImageSize', 'ABC'); //  SmartViscaカメラ:画像サイズ SvcImageSize__c	数値(18、0)
    SB_NameCard_SImageController.Response res = SB_NameCard_SImageController.saveUserSetting(values);
    System.assertEquals(false, res.success);
  }

  @isTest
  static void test_namespace_normal() {
    System.assertEquals(SB_NameCard_Util.getNamespacePrefix(), SB_NameCard_SImageController.namespace);
  }

  @isTest
  static void test_namespace_ex() {
    SmartViscaConfig__c config = new SmartViscaConfig__c();
    config.SSmartViscaServerOptions__c = 'AAA:111\r\nBBB:222';
    config.SExtraNamespace__c = 'カスタム設定で名前空間名を指定';
    insert config;

    System.assertEquals(config.SExtraNamespace__c, SB_NameCard_SImageController.namespace);
  }

}