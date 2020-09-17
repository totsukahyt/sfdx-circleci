/**
 *
 *  SB_NameCard_RenkeiMapperTest
 *   SB_NameCard_RenkeiMapperのテストクラス
 *
 *
 *  Copyright (C) 2016 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2016.xx.xx
 *
 **/
@isTest
private class SB_NameCard_RenkeiMapperTest {


  public class TestDb extends SB_NC_TestDB {

  }

  @testSetup
  static void setupDB() {
    TestDb db = new TestDb();
    db.initialize();
  }

  private static String getQueryFields(Map<String, Set<String>> mappings) {
    String result = '';
    Set<String> fields = new Set<String>(mappings.keySet());
    fields.add('Id');
    fields.add('Name');
    // 会社名
    fields.add('company_name__c');
    // 住所用の項目
    fields.add('address_pref__c');
    fields.add('address__c');
    fields.add('address_eng__c');
    fields.add('address_bld__c');
    // 姓名用の項目
    fields.add('person_name_last__c');
    fields.add('person_name_first__c');
    fields.add('last_name__c');
    fields.add('first_name__c');
    //removeAddressLabel(fields);
    fields.remove('city');
    fields.remove('street');
    fields.remove('pref_address_bld');
    fields.remove('address_bld');
    fields.remove('street_nobld');
    fields.remove('last_name');
    fields.remove('first_name');
    for (String f : fields) {
      result += f + ', ';
    }
    return result.removeEnd(', ');
  }

  // 新規アカウントのテスト
  @isTest
  static void testCreateRecordAccount() {
    String fields = getQueryFields(SB_NC_TestDB.SV_TO_ACCOUNT);
    String query = 'SELECT ' + fields + ' FROM NameCard__c LIMIT 10';
    List<NameCard__c> cards = Database.query(query);

    SB_NameCard_RenkeiMapper mapper = SB_NameCard_RenkeiMapper.getInstance('Account', true);
    mapper = SB_NameCard_RenkeiMapper.getInstance('Account', true);     // 既存のインスタンス取得のコードを動かすため
    Id recorTypeId = null;
    SObject obj;
    if (mapper.haveNameSource(cards[0])) {
      obj = mapper.createRecord(cards[0], recorTypeId);
    }

    List<NameCardRenkeiMapping__c> mappings = [SELECT Id, Name, NameCardName__c, TargetName__c FROM NameCardRenkeiMapping__c WHERE RecordType.Name = 'Account' AND IsActive__c = true];
    for (NameCardRenkeiMapping__c mapping : mappings) {
      if (mapping.NameCardName__c.endsWithIgnoreCase('__c')) {    // city とかは除外
        System.assertEquals(cards[0].get(mapping.NameCardName__c), obj.get(mapping.TargetName__c));
      }
    }
    Database.DMLOptions dml = new Database.DMLOptions();
    dml.DuplicateRuleHeader.allowSave = true;
    dml.DuplicateRuleHeader.runAsCurrentUser = true;
    Database.SaveResult sr = Database.insert(obj, dml);
    if (sr.isSuccess()) {
      System.debug(obj.Id);
      Account acnt = [SELECT Id, Name FROM Account WHERE Id = :obj.Id LIMIT 1];
      System.assertNotEquals(NULL, acnt);
    }
  }

  // アカウント更新のテスト
  @isTest
  static void testUpdateRecordAccount() {
    String fields = getQueryFields(SB_NC_TestDB.SV_TO_ACCOUNT);
    String query = 'SELECT ' + fields + ' FROM NameCard__c LIMIT 10';
    List<NameCard__c> cards = Database.query(query);

    SB_NameCard_RenkeiMapper mapper = SB_NameCard_RenkeiMapper.getInstance('Account', true);
    mapper = SB_NameCard_RenkeiMapper.getInstance('Account', true);     // 既存のインスタンス取得のコードを動かすため
    List<Account> acnts = [SELECT Id, Name FROM Account LIMIT 10];
    SObject obj = mapper.updateRecord(cards[0], acnts[0].Id);

    List<NameCardRenkeiMapping__c> mappings = [SELECT Id, Name, NameCardName__c, TargetName__c FROM NameCardRenkeiMapping__c WHERE RecordType.Name = 'Account' AND IsActive__c = true];
    for (NameCardRenkeiMapping__c mapping : mappings) {
      if (mapping.NameCardName__c.endsWithIgnoreCase('__c') && mapping.TargetName__c != 'Name') {    // city とかは除外
        System.assertEquals(cards[0].get(mapping.NameCardName__c), obj.get(mapping.TargetName__c));
      }
    }
    Database.DMLOptions dml = new Database.DMLOptions();
    dml.DuplicateRuleHeader.allowSave = true;
    dml.DuplicateRuleHeader.runAsCurrentUser = true;
    Database.SaveResult sr = Database.update(obj, dml);
    if (sr.isSuccess()) {
      System.debug(obj.Id);
      Account acnt = [SELECT Id, Name FROM Account WHERE Id = :obj.Id LIMIT 1];
      System.assertNotEquals(NULL, acnt);
    }
  }

  // 新規コンタクトのテスト
  @isTest
  static void testCreateRecordContact() {
    String fields = getQueryFields(SB_NC_TestDB.SV_TO_CONTACT);
    String query = 'SELECT ' + fields + ' FROM NameCard__c LIMIT 10';
    List<NameCard__c> cards = Database.query(query);

    SB_NameCard_RenkeiMapper mapper = SB_NameCard_RenkeiMapper.getInstance('Account', true);    // Account 用もあって
    mapper = SB_NameCard_RenkeiMapper.getInstance('Contact', true);      // Contact 用も作る
    Id recorTypeId = null;
    SObject obj;
    if (mapper.haveNameSource(cards[0])) {
      obj = mapper.createRecord(cards[0], recorTypeId);
    }

    List<NameCardRenkeiMapping__c> mappings = [SELECT Id, Name, NameCardName__c, TargetName__c FROM NameCardRenkeiMapping__c WHERE RecordType.Name = 'Contact' AND IsActive__c = true];
    for (NameCardRenkeiMapping__c mapping : mappings) {
      if (mapping.NameCardName__c.endsWithIgnoreCase('__c')) {    // city とかは除外
        System.assertEquals(cards[0].get(mapping.NameCardName__c), obj.get(mapping.TargetName__c));
      }
    }

    //  親のアカウント
    List<Account> acnts = [SELECT Id, Name FROM Account LIMIT 10];
    obj.put('AccountId', acnts[0].Id);
    Database.DMLOptions dml = new Database.DMLOptions();
    dml.DuplicateRuleHeader.allowSave = true;
    dml.DuplicateRuleHeader.runAsCurrentUser = true;
    Database.SaveResult sr = Database.insert(obj, dml);
    if (sr.isSuccess()) {
      System.debug(obj.Id);
      Contact acnt = [SELECT Id, Name FROM Contact WHERE Id = :obj.Id LIMIT 1];
      System.assertNotEquals(NULL, acnt);
    }
  }

  @isTest
  static void testAddressBuilder() {
    String fields = getQueryFields(SB_NC_TestDB.SV_TO_ACCOUNT);
    String query = 'SELECT ' + fields + ' FROM NameCard__c LIMIT 10';
    List<NameCard__c> cards = Database.query(query);
    Map<String, String> addressMap = SB_NameCard_Util.getAddress(cards[0]);
    SB_NameCard_RenkeiMapper.AddressBuilder builder;
    builder = new SB_NameCard_RenkeiMapper.StreetNoBldBuilder();
    String street_nobld = builder.create(cards[0], addressMap);
    System.assert(String.isNotBlank(street_nobld));
    builder = new SB_NameCard_RenkeiMapper.PrefAddressBldBuilder();
    String fullAddress = builder.create(cards[0], addressMap);
    System.assert(String.isNotBlank(fullAddress));
    builder = new SB_NameCard_RenkeiMapper.AddressBldBuilder();
    String addressBld = builder.create(cards[0], addressMap);
    System.assert(String.isNotBlank(addressBld));
  }

  // FieldBuilderFromPickList のテスト
  // 名刺標準では選択リストはないので、Account を使って
  // 2018.03.xx V1.22  SV_DEV-809 名刺の選択リスト（カスタム項目）のマッピングが選択リストに設定した値のAPI名でマッピングされる。
  @isTest
  static void test_FieldBuilderFromPickList() {
    Account source = new Account(Name='テスト株式会社', Ownership='Public', Industry='Agriculture', AccountSource='Web');
    DescribeFieldResult dfrOwnership = Account.sObjectType.getDescribe().fields.getMap().get('Ownership').getDescribe();
    DescribeFieldResult dfrIndustry = Account.sObjectType.getDescribe().fields.getMap().get('Industry').getDescribe();
    DescribeFieldResult dfrAccountSource = Account.sObjectType.getDescribe().fields.getMap().get('AccountSource').getDescribe();
    SB_NameCard_RenkeiMapper.FieldBuilderFromPickList builderOwnership = new SB_NameCard_RenkeiMapper.FieldBuilderFromPickList('Ownership', dfrOwnership, dfrOwnership.getPicklistValues());
    SB_NameCard_RenkeiMapper.FieldBuilderFromPickList builderIndustry = new SB_NameCard_RenkeiMapper.FieldBuilderFromPickList('Industry', dfrIndustry, dfrIndustry.getPicklistValues());
    SB_NameCard_RenkeiMapper.FieldBuilderFromPickList builderAccountSource = new SB_NameCard_RenkeiMapper.FieldBuilderFromPickList('AccountSource', dfrAccountSource, dfrAccountSource.getPicklistValues());
    Account dest = new Account(Name='テスト株式会社2');
    builderOwnership.create(source, dest);
    builderIndustry.create(source, dest);
    builderAccountSource.create(source, dest);
    System.assertEquals(source.Ownership, dest.Ownership);
    System.assertEquals(source.Industry, dest.Industry);
    System.assertEquals(source.AccountSource, dest.AccountSource);
  }


}