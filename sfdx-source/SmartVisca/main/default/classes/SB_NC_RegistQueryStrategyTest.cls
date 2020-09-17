/**
 *
 * SB_NC_RegistQueryStrategyTest
 *  SB_NC_RegistQueryStrategy のテストクラス
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2019.06.xx v2.4
 *
 **/
@isTest
private class SB_NC_RegistQueryStrategyTest {

  @isTest
  static void test_getConvertedAccountQuery() {
    List<Account> acnts = new List<Account>();
    acnts.add(new Account(Name='株式会社 テスト商事', WebSite='test.com', Description='テスト'));
    acnts.add(new Account(Name='株式会社 サンプル物産', WebSite='sample.com', Description='サンプル'));
    insert acnts;

    List<Contact> conts = new List<Contact>();
    for (Account a : acnts) {
      conts.add(new Contact(AccountId=a.Id, LastName=a.Description, FirstName='一郎', EMail='one@'+a.Website));
      conts.add(new Contact(AccountId=a.Id, LastName=a.Description, FirstName='二郎', EMail='one@'+a.Website));
      conts.add(new Contact(AccountId=a.Id, LastName=a.Description, FirstName='三郎', EMail='one@'+a.Website));
    }
    insert conts;
    List<String> aIds = new List<String>();
    for (Account a : acnts) {
      aIds.add(a.Id);
    }
    List<String> cIds = new List<String>();
    for (Contact c : conts) {
      cIds.add(c.Id);
    }
    String query = SB_NC_RegistQueryStrategy.getConvertedAccountQuery(String.join(aIds, ','), String.join(cIds, ','));
    System.assert(query.startsWithIgnoreCase('select'));
  }

}