/*  $Id: SB_NameCard_UtilTest.cls 14 2014-02-26 14:06:46Z ume $ */

/*
 * Copyright (c) 2011-2018 SunBridge Inc.
 *
 * ユーティリティテスト
 */

@isTest
private class SB_NameCard_UtilTest
{
  public static testMethod void testAll()
  {
    System.assertEquals('', SB_NameCard_Util.getStr(null));

    System.assertEquals('a\\\\\\\'b', SB_NameCard_Util.addslashes('a\\\'b'));

    ApexPages.currentPage().getParameters().put('pref-hoge', 'page');
    Map<String, String> params = SB_NameCard_Util.getPageParameters('pref-');
    System.assertEquals(1, params.size());

    NameCard__c sobj = new NameCard__c();
    sobj.company_name__c = '株式会社サンブリッジ';
    String companyName = SB_NameCard_Util.getCompanyName(sobj.company_name__c);
    System.assertEquals('サンブリッジ', companyName);

    sobj.company_name__c = 'サンブリッジ株式会社';
    companyName = SB_NameCard_Util.getCompanyName(sobj.company_name__c);
    System.assertEquals('サンブリッジ', companyName);

    sobj.person_name_last__c = '姓';
    sobj.person_name_first__c = '名';
    Map<String, String> personName = SB_NameCard_Util.getPersonName(sobj);
    System.assertEquals('姓', personName.get('last_name'));
    System.assertEquals('名', personName.get('first_name'));

    sobj.person_name_last__c = null;
    sobj.person_name_first__c = null;
    sobj.last_name__c = 'ラストネーム';
    sobj.first_name__c = 'ファーストネーム';
    personName = SB_NameCard_Util.getPersonName(sobj);
    System.assertEquals('ラストネーム', personName.get('last_name'));
    System.assertEquals('ファーストネーム', personName.get('first_name'));

    sobj.address__c = '渋谷区恵比寿';
    sobj.address_bld__c = '渋谷マークシティ';
    Map<String, String> address = SB_NameCard_Util.getAddress(sobj);
    System.assertEquals('渋谷区', address.get('city'));
    System.assertEquals('恵比寿渋谷マークシティ', address.get('street'));

    sobj.address__c = '町田市野津田町';
    sobj.address_bld__c = null;
    address = SB_NameCard_Util.getAddress(sobj);
    System.assertEquals('町田市', address.get('city'));
    System.assertEquals('野津田町', address.get('street'));

    sobj.address__c = '安達郡大玉村';
    sobj.address_bld__c = null;
    address = SB_NameCard_Util.getAddress(sobj);
    System.assertEquals('安達郡', address.get('city'));
    System.assertEquals('大玉村', address.get('street'));

    sobj.address__c = '等々力';
    sobj.address_bld__c = null;
    address = SB_NameCard_Util.getAddress(sobj);
    System.assertEquals('', address.get('city'));
    System.assertEquals('等々力', address.get('street'));

    sobj.address__c = null;
    sobj.address_bld__c = null;
    sobj.address_eng__c = 'kaminoge';
    address = SB_NameCard_Util.getAddress(sobj);
    System.assertEquals('', address.get('city'));
    System.assertEquals('kaminoge', address.get('street'));

    sobj.address__c = 'aaaaaaaaaa';
    sobj.address_bld__c = null;
    sobj.address_eng__c = null;
    for (Integer i = 0; i < 100; i++)
      sobj.address__c += 'aaaaaaaaaa';
    address = SB_NameCard_Util.getAddress(sobj);
    System.assertEquals(255, address.get('street').length());

    // 2016.05.xx
    sobj.address__c = '四日市市諏訪町1番5号';
    sobj.address_bld__c = '四日市市役所';
    address = SB_NameCard_Util.getAddress(sobj);
    System.assertEquals('四日市市', address.get('city'));
    System.assertEquals('諏訪町1番5号四日市市役所', address.get('street'));

    // 2016.05.xx
    sobj.address__c = '余市郡余市町';
    sobj.address_bld__c = 'N蒸留所';
    address = SB_NameCard_Util.getAddress(sobj);
    System.assertEquals('余市郡', address.get('city'));
    System.assertEquals('余市町N蒸留所', address.get('street'));

  }

  // v1.20.3 2017.11.xx getCompanyName のテスト
  public static testMethod void test_getCompanyName() {
    System.assertEquals('法人格', SB_NameCard_Util.getCompanyName('株式会社法人格'));
    System.assertEquals('会社法人', SB_NameCard_Util.getCompanyName('(株)会社法人'));
    System.assertEquals('会社法人', SB_NameCard_Util.getCompanyName('（株）会社法人'));
    System.assertEquals('会社法人', SB_NameCard_Util.getCompanyName('(株）会社法人'));
    System.assertEquals('会社法人', SB_NameCard_Util.getCompanyName('（株)会社法人'));
    System.assertEquals('会社法人', SB_NameCard_Util.getCompanyName('(有)会社法人'));
    System.assertEquals('会社法人', SB_NameCard_Util.getCompanyName('㈱会社法人'));
    System.assertEquals('会社法人', SB_NameCard_Util.getCompanyName('㈲会社法人'));
    System.assertEquals('会社法人', SB_NameCard_Util.getCompanyName('会社法人(株)'));
    System.assertEquals('会社法人', SB_NameCard_Util.getCompanyName('会社法人(有)'));
    System.assertEquals('会社法人', SB_NameCard_Util.getCompanyName('会社法人㈱'));
    System.assertEquals('会社法人', SB_NameCard_Util.getCompanyName('会社法人㈲'));
    System.assertEquals('会社㈱法人', SB_NameCard_Util.getCompanyName('会社㈱法人'));
    System.assertEquals('会社㈲法人', SB_NameCard_Util.getCompanyName('会社㈲法人'));
    System.assertEquals('株式会社', SB_NameCard_Util.getCompanyName('医療法人株式会社'));
    System.assertEquals('法人会社', SB_NameCard_Util.getCompanyName('株式会社法人会社'));
    System.assertEquals('あとかぶ', SB_NameCard_Util.getCompanyName('あとかぶ株式会社'));
    System.assertEquals('', SB_NameCard_Util.getCompanyName('株式会社'));
    System.assertEquals('かくなし', SB_NameCard_Util.getCompanyName('かくなし'));
    // 追加
    // https://www.city.tsuchiura.lg.jp/data/doc/1395993381_doc_38_3.pdf
    System.assertEquals('ほうじんめい', SB_NameCard_Util.getCompanyName('医療法人社団ほうじんめい'));
    System.assertEquals('ほうじんめい', SB_NameCard_Util.getCompanyName('医療法人財団ほうじんめい'));
    System.assertEquals('ほうじんめい', SB_NameCard_Util.getCompanyName('宗教法人ほうじんめい'));
    System.assertEquals('ほうじんめい', SB_NameCard_Util.getCompanyName('社会福祉法人ほうじんめい'));
    System.assertEquals('ほうじんめい', SB_NameCard_Util.getCompanyName('更生保護法人ほうじんめい'));
    System.assertEquals('ほうじんめい', SB_NameCard_Util.getCompanyName('独立行政法人ほうじんめい'));
    System.assertEquals('ほうじんめい', SB_NameCard_Util.getCompanyName('地方独立行政法人ほうじんめい'));
    System.assertEquals('ほうじんめい', SB_NameCard_Util.getCompanyName('一般社団法人ほうじんめい'));
    System.assertEquals('ほうじんめい', SB_NameCard_Util.getCompanyName('(一社)ほうじんめい'));
    System.assertEquals('ほうじんめい', SB_NameCard_Util.getCompanyName('(公社)ほうじんめい'));
    System.assertEquals('ほうじんめい', SB_NameCard_Util.getCompanyName('(特非)ほうじんめい'));
    System.assertEquals('ほうじんめい', SB_NameCard_Util.getCompanyName('(地独)ほうじんめい'));
    System.assertEquals('ほうじんめい', SB_NameCard_Util.getCompanyName('ほうじんめい(地独)'));
    // 2017.11.xx v1.20.4 SV_DEV-677 法人格と法人名の間の 半角・全角スペースを除外して照合する
    // 1
    System.assertEquals('法人格', SB_NameCard_Util.getCompanyName('株式会社 　法人格'));
    System.assertEquals('法 　人格', SB_NameCard_Util.getCompanyName('株式会社 　法 　人格'));
    System.assertEquals('法人格', SB_NameCard_Util.getCompanyName('法人格 　株式会社'));
    System.assertEquals('法 　人格', SB_NameCard_Util.getCompanyName('法 　人格 　株式会社'));
    System.assertEquals('法人格 　', SB_NameCard_Util.getCompanyName('株式会社 　法人格 　'));
    System.assertEquals(' 　法人格', SB_NameCard_Util.getCompanyName(' 　法人格 　株式会社'));
    // 2
    System.assertEquals('法人格', SB_NameCard_Util.getCompanyName('(株) 　法人格'));
    System.assertEquals('法 　人格', SB_NameCard_Util.getCompanyName('(株) 　法 　人格'));
    System.assertEquals('法人格', SB_NameCard_Util.getCompanyName('法人格 　(株)'));
    System.assertEquals('法 　人格', SB_NameCard_Util.getCompanyName('法 　人格 　(株)'));
    System.assertEquals('法人格 　', SB_NameCard_Util.getCompanyName('(株) 　法人格 　'));
    System.assertEquals(' 　法人格', SB_NameCard_Util.getCompanyName(' 　法人格 　(株)'));
    // 3
    System.assertEquals('法人格', SB_NameCard_Util.getCompanyName('㈱ 　法人格'));
    System.assertEquals('法 　人格', SB_NameCard_Util.getCompanyName('㈱ 　法 　人格'));
    System.assertEquals('法人格', SB_NameCard_Util.getCompanyName('法人格 　㈱'));
    System.assertEquals('法 　人格', SB_NameCard_Util.getCompanyName('法 　人格 　㈱'));
    System.assertEquals('法人格 　', SB_NameCard_Util.getCompanyName('㈱ 　法人格 　'));
    System.assertEquals(' 　法人格', SB_NameCard_Util.getCompanyName(' 　法人格 　㈱'));

  }

  // v2.4でカスタム表示ラベルに追加した法人格の分
  public static testMethod void test_getCompanyName_v2_4() {
    // 2019.09.xx v2.4 SV_DEV-1647 法人格の正式名称と略称をマッチさせる（登録・自動連携）
    System.assertEquals('サンブリッジ', SB_NameCard_Util.getCompanyName('サンブリッジ公益社団法人'));
    System.assertEquals('サンブリッジ', SB_NameCard_Util.getCompanyName('公益社団法人 サンブリッジ'));
    System.assertEquals('サンブリッジ', SB_NameCard_Util.getCompanyName('サンブリッジ国立大学法人'));
    System.assertEquals('サンブリッジ', SB_NameCard_Util.getCompanyName('サンブリッジ (大）'));
    System.assertEquals('サンブリッジ', SB_NameCard_Util.getCompanyName('公立大学法人サンブリッジ'));
    System.assertEquals('サンブリッジ', SB_NameCard_Util.getCompanyName('サンブリッジ 無限責任中間法人'));
    System.assertEquals('サンブリッジ', SB_NameCard_Util.getCompanyName('サンブリッジ （中）'));
    System.assertEquals('財団 石心会 川崎幸病院', SB_NameCard_Util.getCompanyName('社会医療法人財団 石心会 川崎幸病院'));
    System.assertEquals('財団 石心会 川崎幸病院', SB_NameCard_Util.getCompanyName('(医)財団 石心会 川崎幸病院'));
    System.assertEquals('sss19', SB_NameCard_Util.getCompanyName('株式会社sss19'));
    System.assertEquals('sss19', SB_NameCard_Util.getCompanyName('（株) sss19'));
  }

  // SmartVisca設定 取得のテスト 初期状態
  public static testMethod void testSmartViscaConfigWithoutSetting() {
    Test.startTest();
    // 未設定のときは履歴とり以外はTRUE
    system.assertEquals(true, SB_NameCard_Util.isTriggerRegDateTime());
    system.assertEquals(true, SB_NameCard_Util.isTriggerCreateFeedOnName());
    system.assertEquals(true, SB_NameCard_Util.isTriggerMergeNameCards());
    system.assertEquals(false, SB_NameCard_Util.isTriggerHistoryIsActive());
    Test.stopTest();
  }
  // SmartVisca設定 取得のテスト 設定後
  public static testMethod void testSmartViscaConfigWithSetting() {
    Test.startTest();
    SB_NameCard_TestDB db = new SB_NameCard_TestDB();
    db.initialize();
    system.assertEquals(db.svConfig.TriggerRegDateTime__c, SB_NameCard_Util.isTriggerRegDateTime());
    system.assertEquals(db.svConfig.TriggerCreateFeedOnName__c, SB_NameCard_Util.isTriggerCreateFeedOnName());
    system.assertEquals(db.svConfig.TriggerMergeNameCards__c, SB_NameCard_Util.isTriggerMergeNameCards());
    system.assertEquals(db.svConfig.TriggerHistoryIsActive__c, SB_NameCard_Util.isTriggerHistoryIsActive());
    Test.stopTest();
  }

  // 名前空間名取得メソッドのテスト
  public static testMethod void testGetNamespacePrefix() {
    String namespace = null;
    list<ApexClass> classes = [select Name, NamespacePrefix from ApexClass where Name='SB_NameCard_Util' limit 1];
    if (classes.isEmpty() == false)
      namespace = classes[0].NamespacePrefix != null ? classes[0].NamespacePrefix : '';
    system.assertEquals(SB_NameCard_Util.getNamespacePrefix(), namespace);
    system.assertEquals(SB_NameCard_Util.getNamespacePrefix_x(), String.isBlank(namespace) ? '' : namespace+'__');
  }

  // 項目の選択リスト値のリストを取得 のテスト
  static testMethod void testGetPickListEntry() {
    list<String> opts = SB_NameCard_Util.getPickListEntry(Task.status);
    system.assertEquals(true, opts.size() >= 0);
    for (String opt :opts) {
      system.debug(opt);
    }
  }

  /**
   *  getObjectNameのテスト
  */
  static testMethod void testGetObjectName() {
    Test.startTest();
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    system.runAs (thisUser) {
      NameCard__c card = new NameCard__c(Name='姓 太郎', person_name_last__c='姓');
      insert card;
      system.assert(SB_NameCard_Util.getObjectName(card.Id).contains('NameCard__c'));
    }
    Test.stopTest();
  }

  // escapeSOSLYoyakugo のテスト 2016.10.xx
  @isTest
  static void testEscapeSOSLYoyakugo() {
    String nomal = SB_NameCard_Util.escapeSOSLYoyakugo('ABC');
    String yoyakugo = '?&|!{}[]()^~*:"\'+-\\';
    String esc = SB_NameCard_Util.escapeSOSLYoyakugo(yoyakugo);
    System.assertNotEquals(yoyakugo.length(), esc.length());
  }

  // 2017.01.xx
  @isTest
  static void test_updateFromTrigger() {
    System.assertEquals(false, SB_NameCard_Util.isUpdateFromTrigger());
    SB_NameCard_Util.setUpdateFromTrigger();
    System.assertEquals(true, SB_NameCard_Util.isUpdateFromTrigger());
  }

  // getNameCardMap  2017.01.xx
  @isTest
  static void test_getNameCardMap() {
    SB_NC_TestDB db = new SB_NC_TestDB();
    db.initialize();
    List<NameCard__c> objs = [SELECT Id, Name, delivery_type__c, person_name_last__c, person_name_first__c, email__c FROM NameCard__c LIMIT 10];
    // 2次納品にしておく
    for (Integer n = 0; n < objs.size(); n++) {
      NameCard__c obj = objs.get(n);
      obj.delivery_type__c = '2';
      obj.email__c = (Math.mod(n, 3)== 0 ? null : (Math.mod(n, 3)==1 ? 'test_' + obj.email__c : obj.email__c));
    }
    update objs;
    objs = [SELECT Id, Name, delivery_type__c, person_name_last__c, person_name_first__c, email__c FROM NameCard__c];
    Map<String, List<NameCard__c>> key2Cards = SB_NameCard_Util.getNameCardMap(objs);
    System.assert(!key2Cards.isEmpty());
  }


  // getManagedObjectName  2017.01.xx
  @isTest
  static void test_getManagedObjectName() {
    System.assertEquals('Account',  SB_NameCard_Util.getManagedObjectName('Account'));
    String ns = SB_NameCard_Util.getNamespacePrefix_x();
    String nc = 'NameCard__c';
    System.assertEquals(ns+nc,  SB_NameCard_Util.getManagedObjectName(nc));
  }

  // v1.22 getZenkakuBackslashToWildcard のテスト
  @isTest
  static void test_getZenkakuBackslashToWildcard() {
    System.assertEquals('カイシャ_カイシャ', SB_NameCard_Util.getZenkakuBackslashToWildcard('カイシャ＼カイシャ'));
    System.assertEquals('カイシャ\'カイシャ', SB_NameCard_Util.getZenkakuBackslashToWildcard('カイシャ\'カイシャ'));
    System.assertEquals('カイシャ\\カイシャ', SB_NameCard_Util.getZenkakuBackslashToWildcard('カイシャ\\カイシャ'));
    System.assertEquals('カイシャ\\\\カイシャ', SB_NameCard_Util.getZenkakuBackslashToWildcard('カイシャ\\\\カイシャ'));

  }

  // v1.22 getStringForPartialMatch のテスト
  @isTest
  static void test_getStringForPartialMatch() {
    System.assertEquals('カイシャ_カイシャ', SB_NameCard_Util.getStringForPartialMatch('カイシャ＼カイシャ'));
    System.assertEquals('カイシャ\'カイシャ', SB_NameCard_Util.getStringForPartialMatch('カイシャ\'カイシャ'));
    System.assertEquals('カイシャ\\\\カイシャ', SB_NameCard_Util.getStringForPartialMatch('カイシャ\\カイシャ'));
  }

  // v1.22 getValidFields(SObjectType otype) のテスト
  @isTest
  static void test_getValidFields() {
    Set<String> ff;
    String nsx = SB_NameCard_Util.getNamespacePrefix_x();
    ff = SB_NameCard_Util.getValidFields(Account.sObjectType);
    System.assert(ff.contains('Site'));
    ff = SB_NameCard_Util.getValidFields(NameCard__c.sObjectType);
    System.assert(ff.contains(nsx + 'first_name__c'));
  }

  // v1.22 getQueryText(SObjectType otype) のテスト
  @isTest
  static void test_getQueryText1() {
    String query = SB_NameCard_Util.getQueryText(Account.sObjectType);
    System.assert(query.contains('Name'));
    System.assert(query.contains('Account'));
  }

  // v1.22 getQueryText(SObjectType otype, String condition) のテスト
  @isTest
  static void test_getQueryText2() {
    String query = SB_NameCard_Util.getQueryText(Account.sObjectType, 'Id != null');
    System.assert(query.contains('Name'));
    System.assert(query.contains('Account'));
  }

  // v1.22 getQueryText(SObjectType otype, String condition, String orderby) のテスト
  @isTest
  static void test_getQueryText3() {
    String query = SB_NameCard_Util.getQueryText(Account.sObjectType, 'Id != null', 'CreatedDate DESC');
    System.assert(query.contains('Name'));
    System.assert(query.contains('Account'));
  }

  // v1.22 test_isEnableLeadExtention Lead  拡張パッケージが入ってるかどうか のテスト
  @isTest
  static void test_isEnableLeadExtention() {
    List<ApexClass> classes = [SELECT Name, NamespacePrefix FROM ApexClass WHERE Name IN ('SB_NameCard_LeadBulkRegistController', 'SB_NameCard_LeadNameCardListController', 'SB_NameCard_LeadRegistController') OR NamespacePrefix='SmartViscal'];
    System.assertEquals(!classes.isEmpty(), SB_NameCard_Util.isEnableLeadExtention());
  }

  // v1.22 リード拡張パッケージの名前空間名を返します。
  @isTest
  static void test_getLeadExNamespacePrefix() {
    String ns = '';
    if (SB_NameCard_Util.isEnableLeadExtention()) {
      ns = 'SmartViscal';
    }
    System.assertEquals(ns, SB_NameCard_Util.getLeadExNamespacePrefix());
    if (SB_NameCard_Util.isEnableLeadExtention()) {
      System.assertEquals(ns + '__', SB_NameCard_Util.getLeadExNamespacePrefix_x());
    }
    else {
      System.assertEquals('', SB_NameCard_Util.getLeadExNamespacePrefix_x());
    }
  }

  // v2.2 オブジェクトデフォルトのレコードタイプIDを取得
  @isTest
  static void test_getDefaultRecordType() {
    SObjectType otype = Account.getSObjectType();
    Boolean hasDefaultRecordType = false;
    List<Schema.RecordTypeInfo> rs = otype.getDescribe().getRecordTypeInfos();
    for (RecordTypeInfo r : rs) {
        if (r.isDefaultRecordTypeMapping() && r.isAvailable() && !r.isMaster()) {
             hasDefaultRecordType = true;
        }
    }
    if (hasDefaultRecordType) {
      System.assertNotEquals(null, SB_NameCard_Util.getDefaultRecordType(otype));
    } else {
      System.assertEquals(null, SB_NameCard_Util.getDefaultRecordType(otype));      
    }
  }
  
  // v2.2 Account.Phone 等から望ましいラベルを取得
  @isTest
  static void test_getDesirableLabel() {
    System.assertNotEquals('', SB_NameCard_Util.getDesirableLabel('Account','Phone'));
    System.assertEquals('', SB_NameCard_Util.getDesirableLabel('hoge','hoge'));
  }
}