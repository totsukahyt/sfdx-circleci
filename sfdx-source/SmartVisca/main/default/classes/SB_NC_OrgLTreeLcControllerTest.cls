/**
 *
 *  SB_NC_OrgLTreeLcControllerTest
 *
 *  SB_NC_OrgLTreeLcController  Lightning Component による 組織ツリー Lightning Component の Controller のテストクラス
 *
 * Copyright (C) 2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1     2018.01.xx v1.22  SV_DEV-412 LEXの組織情報
 *
 *
 **/
@isTest
private class SB_NC_OrgLTreeLcControllerTest
{

  public class TestDb extends SB_NC_TestDB {

    //  存在するユーザごとに所有者を変えて同一の名刺を追加
    public override void initializeNameCard() {
      for (Employee emp :listEmp) {
        // 所有者の異なる名刺を作成
        //for (User u : listUser) {
          listCard.add(
            new NameCard__c(
              name= emp.name
              , person_name_last__c= emp.sei
              , person_name_first__c= emp.mei
              , last_name__c= emp.sei.replace('苗字', 'Myoji')
              , first_name__c= emp.mei.replace('名', 'Na')
              , email__c= emp.mail
              , company_name__c= emp.kaisha.name
              , division__c = '本社'
              , title_name__c = '役職'+emp.num.format()
              , tel1__c= emp.kaisha.phone
              , tel2__c= emp.kaisha.phone
              , fax1__c= '0344444444'
              , mobile__c = '09099999999'
              , web_url1__c = 'http://www.'+emp.kaisha.domain
              , web_url2__c = 'http://www.'+emp.kaisha.domain
              , zip_code__c = emp.kaisha.zip
              , address_pref__c = emp.kaisha.pref
              , address__c = emp.kaisha.address
              , address_bld__c = emp.kaisha.bld
              //                    , list_name__c ='名刺'
              , memo__c = 'メモ : ' + emp.kaisha.name +' '+ emp.num.format()
              , freehandmemo__c = '自由記述 : ' + emp.kaisha.name +' '+ emp.num.format()
              , delivery_type__c='1'
              //, OwnerId = u.Id
          ));
        //}
      }
    }
    public override void initialize() {
      //　ユーザ
      //initializeUser();
      if (listUser.isEmpty() == false)
        insert listUser;
      // 名刺レコード作成
      initializeKaisha();     // 会社を揃えておく
      initializeEmployee();   // 会社ごとに名刺の人を揃えておく
      initializeNameCard();
      if (listCard.isEmpty() == false)
        insert listCard;
    }
  } // public class TestDb extends SB_NC_TestDB

  //  StandardController でのテスト
  @isTest
  static void test_StandardController() {
    TestDb db = new TestDb();
    db.initialize();

    Test.startTest();
    List<NameCard__c> cards = [SELECT Id, Name, company_name__c FROM NameCard__c LIMIT 10];
    ApexPages.StandardController sc = new ApexPages.StandardController(cards[0]);
    SB_NC_OrgLTreeLcController ctrl = new SB_NC_OrgLTreeLcController(sc);
    System.assert(ctrl.getRecordName().contains(cards[0].Name));
    Test.stopTest();
  }

  // @AuraEnabled の getOrgTreeItems のテスト
  @isTest
  static void test_getOrgTreeItems() {
    TestDb db = new TestDb();
    db.initialize();
    List<NameCard__c> cards = [SELECT Id, Name, company_name__c FROM NameCard__c LIMIT 10];
    
    Test.startTest();
    SB_NC_OrgLTreeLcController.GetOrgTreeItemsRequest req =
        new SB_NC_OrgLTreeLcController.GetOrgTreeItemsRequest(cards[0].Id, true, 1000);
    String reqText = JSON.serialize(req);
    //String itemsJson = SB_NC_OrgLTreeLcController.getOrgTreeItems(db.listCard[0].Id);
    SB_NC_OrgLTreeLcController.GetOrgTreeItemsResponse response = SB_NC_OrgLTreeLcController.getOrgTreeItems(reqText);
    System.assertEquals(true, response.success);
    System.assertEquals(cards[0].company_name__c, response.items[0].label);
    Test.stopTest();
  }

  // 未サポートのオブジェクトで例外発生
  @isTest
  static void test_getOrgTreeItemsException() {

    Test.startTest();
    List<User> users = [SELECT Id, Name FROM User];
    if (!users.isEmpty()) {
      SB_NC_OrgLTreeLcController.GetOrgTreeItemsRequest req =
          new SB_NC_OrgLTreeLcController.GetOrgTreeItemsRequest(users[0].Id, true, 1000);
      String reqText = JSON.serialize(req);
      SB_NC_OrgLTreeLcController.GetOrgTreeItemsResponse response = SB_NC_OrgLTreeLcController.getOrgTreeItems(reqText);
      System.assertEquals(false, response.success);
    }
    Test.stopTest();
  }


}