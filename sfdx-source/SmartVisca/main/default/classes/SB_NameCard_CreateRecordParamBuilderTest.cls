/**
 *
 *  SB_NameCard_CreateRecordParamBuilderTest
 *   SB_NameCard_CreateRecordParameterBuilderのテストクラス
 *
 *
 *  Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2017.08.xx
 *
 **/
@isTest
private class SB_NameCard_CreateRecordParamBuilderTest {

  @testSetup
  static void setupDB() {
    List<Account> acnts = new List<Account>();
    acnts.add(new Account(Name='Test Inc.',
      Site = 'Test Dev.',
      Website = 'www.test.com',
      BillingPostalCode = '115-0022',
      BillingState = 'Tokyo',
      BillingCity = 'Shibuya-Ku',
      BillingStreet = 'Ebisu',
      ShippingPostalCode = '115-0022',
      ShippingState = 'Tokyo',
      ShippingCity = 'Shibuya-Ku',
      ShippingStreet = 'Ebisu',
      Phone = '03-3333-3333',
      Fax = '03-3333-3333',
      Description = '説明'));
    insert acnts;
  }

  @isTest
  static void test_ComboRenkeiProcessCreateNew()
  {
    Account acnt = new Account(Name='Test Inc.',
      Site = 'Test Dev.',
      Website = 'www.test.com',
      BillingPostalCode = '115-0022',
      BillingState = 'Tokyo',
      BillingCity = 'Shibuya-Ku',
      BillingStreet = 'Ebisu',
      ShippingPostalCode = '115-0022',
      ShippingState = 'Tokyo',
      ShippingCity = 'Shibuya-Ku',
      ShippingStreet = 'Ebisu',
      Phone = '03-3333-3333',
      Fax = '03-3333-3333',
      Description = '説明');
    String param = SB_NameCard_CreateRecordParameterBuilder.buildLex(acnt);
    System.assert(String.isNotBlank(param));
  }

}