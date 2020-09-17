/**
 *
 *  SB_NC_LookupModalLcControllerTest
 *  SmartVisca LEX対応
 *   Lightning Component 用 APEXコントローラ   SB_NC_LookupModalLcController のテストクラス
 *
 * Copyright (C) 2016 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2016.11.xx
 *
 **/
@isTest
private class SB_NC_LookupModalLcControllerTest {

  public class TestDb extends SB_NC_TestDB {

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
    }
  }

  @isTest
  static void t_getLookupModalLabels() {

    SB_NC_LookupModalLcController.LookupModalLabels res = null;
    String result;
    result = SB_NC_LookupModalLcController.getLookupModalLabels('NameCard__c');
    res = (SB_NC_LookupModalLcController.LookupModalLabels)JSON.deserializeStrict(result, SB_NC_LookupModalLcController.LookupModalLabels.class);
    System.assertEquals(true, res.success);
    System.assert(String.isBlank(res.error));

    // エラー
    result = SB_NC_LookupModalLcController.getLookupModalLabels('NameCard');
    res = (SB_NC_LookupModalLcController.LookupModalLabels)JSON.deserializeStrict(result, SB_NC_LookupModalLcController.LookupModalLabels.class);
    System.assertEquals(false, res.success);
    System.assert(String.isNotBlank(res.error));
  }

  @isTest
  static void t_searchSObject() {
    TestDb db = new TestDb();
    db.initialize();

    List<NameCard__c> cards = [SELECT Id, Name, company_name__c, division__c, title_name__c, address_pref__c,
          person_name_last__c, person_name_first__c,
          card_exchange_date__c, email__c, list_name__c FROM NameCard__c LIMIT 10];

    SB_NC_LookupModalLcController.SearchRequest req = new SB_NC_LookupModalLcController.SearchRequest();
    //req.searchString = cards[0].company_name__c.right(cards[0].company_name__c.length()-2);
    req.searchString = cards[0].person_name_last__c;
    req.sobjName = 'NameCard__c';
    req.fields = new List<String> {'Id', 'Name', 'Owner.Name'};
    req.orderby = 'card_exchange_date__c';
    req.ascend = false;

    List<List<SObject>> searchList = Search.query('FIND {' + req.searchString + '} IN ALL FIELDS RETURNING NameCard__c (Id, Name) LIMIT 50');

    String request = (String)JSON.serialize(req);
    SB_NC_LookupModalLcController.SearchResponse res = null;
    String result;
    result = SB_NC_LookupModalLcController.searchSObject(request);
    res = (SB_NC_LookupModalLcController.SearchResponse)JSON.deserializeStrict(result, SB_NC_LookupModalLcController.SearchResponse.class);
    System.assertEquals(true, res.success);
    System.assert(String.isBlank(res.error));
    System.debug('searchSObject count : '  + res.objs.size());
    System.assertEquals(searchList[0].size(), res.objs.size());

  }
}