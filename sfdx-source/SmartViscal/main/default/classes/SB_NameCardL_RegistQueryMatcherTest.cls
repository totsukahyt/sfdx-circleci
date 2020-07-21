/**
 *
 *  SB_NameCardL_RegistQueryMatcherTest
 *
 * Copyright (C) 2020 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  lx 2.0.3    2020.02.xx
 *
 **/
@isTest
private class SB_NameCardL_RegistQueryMatcherTest {

  @isTest
  static void test_ContactMatcher_FirstName() {
    Contact cont = new Contact( LastName='テスト０１', FirstName='００１', EMail='001@test.com');
    insert cont;
    SmartViscaf__NameCard__c card = new SmartViscaf__NameCard__c(Name='',
      SmartViscaf__person_name_last__c='テスト０１',
      SmartViscaf__person_name_first__c= '００１' + '別人',
      SmartViscaf__email__c= '001@test.com',
      SmartViscaf__company_name__c= '',
      SmartViscaf__division__c='',
      SmartViscaf__contact__c=null);
    SB_NameCardL_RegistQueryMatcher.ContactMatcher m = new SB_NameCardL_RegistQueryMatcher.ContactMatcher();
    m.queryOnlyEMail = false;
    m.queryEmail = false;
    m.queryFirstName = true;
    m.queryLastName = false;
    m.queryCompany = false;
    m.queryDept = false;
    m.queryNameOrEMail = false;
    System.assertEquals(false, m.isMatch(card, cont));
  }

  @isTest
  static void test_ContactMatcher_LastName() {
    Contact cont = new Contact( LastName='テスト０１', FirstName='００１', EMail='001@test.com');
    insert cont;
    SmartViscaf__NameCard__c card = new SmartViscaf__NameCard__c(Name='',
      SmartViscaf__person_name_last__c='テスト０１' + '別人',
      SmartViscaf__person_name_first__c= '００１',
      SmartViscaf__email__c= '001@test.com',
      SmartViscaf__company_name__c= '',
      SmartViscaf__division__c='',
      SmartViscaf__contact__c=null);
    SB_NameCardL_RegistQueryMatcher.ContactMatcher m = new SB_NameCardL_RegistQueryMatcher.ContactMatcher();
    m.queryOnlyEMail = false;
    m.queryEmail = false;
    m.queryFirstName = false;
    m.queryLastName = true;
    m.queryCompany = false;
    m.queryDept = false;
    m.queryNameOrEMail = false;
    System.assertEquals(false, m.isMatch(card, cont));
  }

  @isTest
  static void test_ContactMatcher_EMail() {
    Contact cont = new Contact( LastName='テスト０１', FirstName='００１', EMail='001@test.com');
    insert cont;
    SmartViscaf__NameCard__c card = new SmartViscaf__NameCard__c(Name='',
      SmartViscaf__person_name_last__c='テスト０１',
      SmartViscaf__person_name_first__c= '００１',
      SmartViscaf__email__c= '001@test.com'.replace('com', 'co.jp'),
      SmartViscaf__company_name__c= '',
      SmartViscaf__division__c='',
      SmartViscaf__contact__c=null);
    SB_NameCardL_RegistQueryMatcher.ContactMatcher m = new SB_NameCardL_RegistQueryMatcher.ContactMatcher();
    m.queryOnlyEMail = false;
    m.queryEmail = true;
    m.queryFirstName = false;
    m.queryLastName = false;
    m.queryCompany = false;
    m.queryDept = false;
    m.queryNameOrEMail = false;
    System.assertEquals(false, m.isMatch(card, cont));
  }

  @isTest
  static void test_ContactMatcher_OnlyEMail() {
    Contact cont = new Contact( LastName='テスト０１', FirstName='００１', EMail='001@test.com');
    insert cont;
    SmartViscaf__NameCard__c card = new SmartViscaf__NameCard__c(Name='',
      SmartViscaf__person_name_last__c='テスト０１' + '別人',
      SmartViscaf__person_name_first__c= '００１' + '別人',
      SmartViscaf__email__c= '001@test.com',
      SmartViscaf__company_name__c= '',
      SmartViscaf__division__c='',
      SmartViscaf__contact__c=null);
    SB_NameCardL_RegistQueryMatcher.ContactMatcher m = new SB_NameCardL_RegistQueryMatcher.ContactMatcher();
    m.queryOnlyEMail = true;
    m.queryEmail = true;
    m.queryFirstName = true;
    m.queryLastName = true;
    m.queryCompany = false;
    m.queryDept = false;
    m.queryNameOrEMail = false;
    System.assertEquals(true, m.isMatch(card, cont));
  }

}