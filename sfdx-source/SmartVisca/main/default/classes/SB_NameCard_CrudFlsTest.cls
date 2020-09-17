/**
 *
 * SB_NameCard_CrudFlsTest
 *  SB_NameCard_CrudFls のテストクラス
 *
 * Copyright (C) 2016 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2016.9.xx
 *
 **/
@isTest
private class  SB_NameCard_CrudFlsTest
{
  @isTest
  static void testsCreate() {
    List<SObject> objs = new List<SObject>();
    SB_NameCard_CrudFls.screate(objs, true);
    Database.DMLOptions dmlOption = new Database.DMLOptions();
    System.assertEquals(NULL, SB_NameCard_CrudFls.screate(objs, dmlOption));
  }

  @isTest
  static void testsUpdate() {
    List<SObject> objs = new List<SObject>();
    SB_NameCard_CrudFls.supdate(objs, true);
    Database.DMLOptions dmlOption = new Database.DMLOptions();
    System.assertEquals(NULL, SB_NameCard_CrudFls.supdate(objs, dmlOption));
  }

  @isTest
  static void testGetCheckFields() {
    List<NameCard__c> cards = new List<NameCard__c>();
    cards.add(new NameCard__c(Name='テスト 太郎', person_name_last__c='テスト', person_name_first__c='太郎',
                     first_name__c='Taro', last_name__c='Test', company_name__c='テスト株式会社'));
    Set<String> values = SB_NameCard_CrudFls.getCheckFields(cards);
    System.assertEquals(6, values.size());
  }

  @isTest
  static void testCompatibilityCode() {
     System.assertEquals(null, SB_NameCard_CrudFls.screateDuplicate(null, null));
     System.assertEquals(null, SB_NameCard_CrudFls.supdateDuplicate(null, null));
  }

  // screate で例外のテスト
  @isTest
  static void test_screate_Exception() {
    List<Account> objs = new List<Account>();
    objs.add(new Account(Site='BBB'));
    Boolean success = false;
    try {
      SB_NameCard_CrudFls.screate(objs, true);
      success = true;
    }
    catch(Exception e) {
      System.debug(e.getMessage());
    }
    System.assertEquals(false, success);
  }

  // supdate で例外のテスト
  @isTest
  static void test_supdate_Exception() {
    List<Account> objs = new List<Account>();
    objs.add(new Account(Name='AAA', Site='BBB'));
    Boolean success = false;
    try {
      SB_NameCard_CrudFls.supdate(objs, true);
      success = true;
    }
    catch(Exception e) {
      System.debug(e.getMessage());
    }
    System.assertEquals(false, success);
  }

}