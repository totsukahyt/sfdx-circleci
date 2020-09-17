/*
 *
 * SV_DEV-596 連携条件レコードの取得方法を統一
 * SB_NameCard_BasicSettingUtilTest   SB_NameCard_BasicSettingUtilのテストクラス
 * Copyright (c) 2011-2015 SunBridge Inc.
 *
 *  @author mao
 *  @Version 1.22      2017.09.XX
 *  @Version 2.4       2019.05.XX  SV_DEV-1630と合わせてリファクタリングを実施
 */
@isTest
private class SB_NameCard_BasicSettingUtilTest {
  public static String A_RECORD_TYPE_ID = '';
  public static String C_RECORD_TYPE_ID = '';
  static void setupTestData() {
    //名刺基本設定を設定
    NameCardBasicSetting__c s = SB_NameCard_BasicSetting.getNameCardBasicSetting();
    if(String.isBlank(s.Id)){
        insert s;
    }
    String objname = SB_NameCard_RenkeiMapperUtil.getManagedObjectName('NameCardRenkeiMapping__c');
    List<RecordType> res = [SELECT Id,Name,Developername FROM RecordType WHERE SobjectType = :objname AND (Developername ='Account' OR Developername = 'Contact')];
    System.debug('resresres' + res);
    A_RECORD_TYPE_ID = res[0].Developername == 'Account' ? res[0].Id : res[1].Id;
    C_RECORD_TYPE_ID = res[0].Developername == 'Contact' ? res[0].Id : res[1].Id;

    String ar = SB_NameCard_RenkeiMappingLcController.changerecord('Account',A_RECORD_TYPE_ID);
    String cr = SB_NameCard_RenkeiMappingLcController.changerecord('Contact',C_RECORD_TYPE_ID);
    SB_NameCard_RenkeiMappingLcController.RecordTypedata lstFilters = new SB_NameCard_RenkeiMappingLcController.RecordTypedata();
    lstFilters = (SB_NameCard_RenkeiMappingLcController.RecordTypedata )System.JSON.deserializeStrict(ar,SB_NameCard_RenkeiMappingLcController.RecordTypedata .Class);
    String def1 = SB_NameCard_RenkeiMappingLcController.changetodefault('Account',lstFilters.obj2LabelNameMap,A_RECORD_TYPE_ID);
    SB_NameCard_RenkeiMappingLcController.Metadata def = new SB_NameCard_RenkeiMappingLcController.Metadata();
    def = (SB_NameCard_RenkeiMappingLcController.Metadata )System.JSON.deserializeStrict(def1,SB_NameCard_RenkeiMappingLcController.Metadata .Class);

    String savemsg = SB_NameCard_RenkeiMappingLcController.savemaps(JSON.serialize(def.mappingList),A_RECORD_TYPE_ID,'Account');

    SB_NameCard_RenkeiMappingLcController.RecordTypedata lstFilters1 = new SB_NameCard_RenkeiMappingLcController.RecordTypedata();
    lstFilters1 = (SB_NameCard_RenkeiMappingLcController.RecordTypedata )System.JSON.deserializeStrict(cr,SB_NameCard_RenkeiMappingLcController.RecordTypedata .Class);
    String def11 = SB_NameCard_RenkeiMappingLcController.changetodefault('Contact',lstFilters1.obj2LabelNameMap,C_RECORD_TYPE_ID);
    SB_NameCard_RenkeiMappingLcController.Metadata def22 = new SB_NameCard_RenkeiMappingLcController.Metadata();
    def22 = (SB_NameCard_RenkeiMappingLcController.Metadata )System.JSON.deserializeStrict(def11,SB_NameCard_RenkeiMappingLcController.Metadata .Class);
    String savemsg1 = SB_NameCard_RenkeiMappingLcController.savemaps(JSON.serialize(def22.mappingList),C_RECORD_TYPE_ID,'Contact');

    List<NameCardRenkeiJyoken__c> jyuos = new List<NameCardRenkeiJyoken__c>();


    NameCardRenkeiJyoken__c jyouken1 = new NameCardRenkeiJyoken__c();
    jyouken1.NameCardName__c = 'Name';
    jyouken1.Operator__c = 'Matches_next_character_string';
    jyouken1.NameCardDataType__c = 'STRING';
    jyouken1.Value__c = 'test';
    jyouken1.BasicSetting__c = s.Id;
    jyuos.add(jyouken1);

    NameCardRenkeiJyoken__c jyouken2 = new NameCardRenkeiJyoken__c();
    jyouken2.NameCardName__c = 'Name';
    jyouken2.Operator__c = 'Does_not_match_next_character_string';
    jyouken2.NameCardDataType__c = 'DATE';
    jyouken2.Value__c = '2017-02-21';
    jyouken2.BasicSetting__c = s.Id;
    jyuos.add(jyouken2);

    NameCardRenkeiJyoken__c jyouken3 = new NameCardRenkeiJyoken__c();
    jyouken3.NameCardName__c = 'Name';
    jyouken3.Operator__c = 'Start_with_the_following_string';
    jyouken3.Value__c = '2017-02-21';
    jyouken3.NameCardDataType__c = 'DATETIME';
    jyouken3.BasicSetting__c = s.Id;
    jyuos.add(jyouken3);

    NameCardRenkeiJyoken__c jyouken4 = new NameCardRenkeiJyoken__c();
    jyouken4.NameCardName__c = 'Name';
    jyouken4.Operator__c = 'Contains_the_following_character_string';
    jyouken4.Value__c = 'test';
    jyouken4.NameCardDataType__c = 'STRING';
    jyouken4.BasicSetting__c = s.Id;
    jyuos.add(jyouken4);

    insert jyuos;

    NameCardSettingValues__c sv = new NameCardSettingValues__c();
    sv.TextValue01__c  = 'Name';
    sv.Type__c = 'SaishinInherit';
    insert sv;
  }

  //getNameCardMapping 連携マッピングデータを取得テスト 取引先
  static testMethod void getNameCardMappingACTest() {
    setupTestData();
    List<NameCardRenkeiMapping__c> ncms = SB_NameCard_BasicSettingUtil.getNameCardMapping(A_RECORD_TYPE_ID, null);
    Integer count = [Select COUNT() From NameCardRenkeiMapping__c Where RecordTypeId = :A_RECORD_TYPE_ID];
    System.assertEquals(ncms.size() > 0, true);
    System.assertEquals(ncms.size(), count);
  }

  //getNameCardMapping 連携マッピングデータを取得テスト項目付き 取引先
  static testMethod void getNameCardMappingFSetACTest() {
    setupTestData();
    List<NameCardRenkeiMapping__c> ncms = SB_NameCard_BasicSettingUtil.getNameCardMapping(A_RECORD_TYPE_ID, new Set<String>{'Name'});
    System.assertEquals(ncms.size(), 1);
  }

  //getNameCardMapping 連携マッピングデータを取得テスト 取引先責任者
  static testMethod void getNameCardMappingCOTest() {
    setupTestData();
    List<NameCardRenkeiMapping__c> ncms = SB_NameCard_BasicSettingUtil.getNameCardMapping(C_RECORD_TYPE_ID, null);
    Integer count = [Select COUNT() From NameCardRenkeiMapping__c Where RecordTypeId = :C_RECORD_TYPE_ID];
    System.assertEquals(ncms.size() > 0, true);
    System.assertEquals(ncms.size(), count);
  }

  //getNameCardMapping 連携マッピングデータを取得テスト項目付き 取引先責任者
  static testMethod void getNameCardMappingFSetCOTest() {
    setupTestData();
    List<NameCardRenkeiMapping__c> ncms = SB_NameCard_BasicSettingUtil.getNameCardMapping(C_RECORD_TYPE_ID, new Set<String>{'LastName'});
    System.assertEquals(ncms.size(), 1);
  }

  //getMappingMetadata メタデータを取得テスト 取引先責任者
  static testMethod void getMappingMetadataACTest() {
    setupTestData();
    Integer count = [Select COUNT() From DefaultRenkeiMapping__mdt Where recordtype__c = 'Account'];
    List<DefaultRenkeiMapping__mdt> drmm = SB_NameCard_BasicSettingUtil.getMappingMetadata('Account');
    System.assertEquals(drmm.size() > 0, true);
    System.assertEquals(drmm.size(), count);
  }

  //getMappingMetadata メタデータを取得テスト 取引先責任者
  static testMethod void getMappingMetadataCOTest() {
    setupTestData();
    Integer count = [Select COUNT() From DefaultRenkeiMapping__mdt Where recordtype__c = 'Contact'];
    List<DefaultRenkeiMapping__mdt> drmm = SB_NameCard_BasicSettingUtil.getMappingMetadata('Contact');
    System.assertEquals(drmm.size() > 0, true);
    System.assertEquals(drmm.size(), count);
  }

  //getSettingValues 名刺設定値を取得テスト タイプ付き
  static testMethod void getSettingValuesACTest() {
    setupTestData();
    List<NameCardSettingValues__c> nsvs = SB_NameCard_BasicSettingUtil.getSettingValues('SaishinInherit');
    Integer count = [Select COUNT() from NameCardSettingValues__c Where Type__c = 'SaishinInherit'];
    System.assertEquals(nsvs.size() > 0, true);
    System.assertEquals(nsvs.size(), count);
  }

  //getNameCardRenkeiJyoken 名刺条件を取得テスト 基本設定付き
  static testMethod void getNameCardRenkeiJyokenTest() {
    setupTestData();
    NameCardBasicSetting__c bb = SB_NameCard_BasicSetting.getNameCardBasicSetting();
    Integer count = [select COUNT() from NameCardRenkeiJyoken__c Where BasicSetting__c=:bb.Id AND BasicSetting__c != null
                                                limit 10000 ];
    List<NameCardRenkeiJyoken__c> nrjs = SB_NameCard_BasicSettingUtil.getNameCardRenkeiJyoken(bb.Id);
    System.assertEquals(nrjs.size() > 0, true);
    System.assertEquals(nrjs.size(), count);
  }

  //getNameCardRenkeiJyoken 名刺条件を取得テスト 基本設定なし
  static testMethod void getNameCardRenkeiJyokenNoTest() {
    setupTestData();
    NameCardBasicSetting__c bb = SB_NameCard_BasicSetting.getNameCardBasicSetting();
    Integer count = [select COUNT() from NameCardRenkeiJyoken__c Where BasicSetting__c=:bb.Id AND BasicSetting__c != null
                                                limit 10000 ];
    List<NameCardRenkeiJyoken__c> nrjs = SB_NameCard_BasicSettingUtil.getNameCardRenkeiJyoken(null);
    System.assertEquals(nrjs.size() > 0, true);
    System.assertEquals(nrjs.size(), count);
  }

}