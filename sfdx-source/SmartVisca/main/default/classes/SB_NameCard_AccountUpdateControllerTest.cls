/*  $Id: SB_NameCard_AccountUpdateControllerTest.cls 9 2012-10-18 08:18:09Z ume $   */

/*
 * Copyright (c) 2011-2015 Sunbridge Inc.
 *
 * 取引先・取引先責任者の名刺情報を使った更新
* @author gao
 */
@isTest
private class SB_NameCard_AccountUpdateControllerTest {
  public class TestDb extends SB_NC_TestDB {

  public override void initialize() {
   initializeBasicSetting();
    if (!listBasicSetting.isEmpty()) {
      insert listBasicSetting;
    }
    // 名刺連携項目マッピング
    initializeMapping();
    if (!listMapping.isEmpty()) {
      insert listMapping;
    }
    String objname = SB_NameCard_RenkeiMapperUtil.getManagedObjectName('NameCardRenkeiMapping__c');
    List<RecordType> res = [SELECT Id,Name,Developername FROM RecordType WHERE SobjectType = :objname AND Developername = 'Contact'];
    NameCardBasicSetting__c s = SB_NameCard_BasicSetting.getNameCardBasicSetting();
    NameCardRenkeiMapping__c amap = new NameCardRenkeiMapping__c();
    amap.IsActive__c = true;
    amap.TargetName__c = 'AccountId';
    amap.NameCardName__c = SB_NameCard_Util.getNamespacePrefix_x() + 'account__c';
    amap.BasicSetting__c = s.Id;
    amap.RecordTypeId = res[0].Id;
    insert amap;
  }
}
  public SB_NameCard_AccountUpdateControllerTest() {
    PageReference p = Page.SB_NameCard_AccountUpdate;
    Test.setCurrentPage(p);
  }

  public static void testPage(String nid, String aid, String cid) {
    ApexPages.currentPage().getParameters().put('nid', nid);
    ApexPages.currentPage().getParameters().put('aid', aid);
    ApexPages.currentPage().getParameters().put('cid', cid);
    SB_NameCard_AccountUpdateController c = new SB_NameCard_AccountUpdateController();
    c.save();
  }

  public static testMethod void testAll() {
    TestDb td = new TestDb();
    td.initialize();
    Account a = new Account();
    Contact c = new Contact();
    NameCard__c n = new NameCard__c();
    Task t = new Task();
    Event e = new Event();

    a.Name = 'TESTAccount';
    a.Site = 'TESTAccount';
    a.BillingPostalCode = '123';
    a.BillingState = 'TESTAccountBS';
    a.BillingCity = 'TESTAccountBC';
    a.BillingStreet = 'TESTAccountBS';
    a.Phone = '111-222-3333';
    a.Fax = '222-333-4444';
    a.Website = 'http://www.account.com';
    insert(a);

    c.LastName = 'TESTContactLN';
    c.FirstName = 'TESTContactFN';
    c.Title = 'TESTContactTitle';
    c.MailingPostalCode = '456';
    c.MailingState = 'TestContactS';
    c.MailingCity = 'TestContactCity';
    c.MailingStreet = 'TestContactST';
    c.Phone = '333-444-5555';
    c.Fax = '444-555-6666';
    c.MobilePhone = '555-666-7777';
    c.Email = 'mail@contact.com';
    insert(c);

    n.company_name__c = 'TESTNameCardCN';
    n.division__c = 'TESTNameCardDiv';
    n.person_name_last__c = 'TESTNameCardLN';
    n.person_name_first__c = 'TESTNameCardFN';
    n.title_name__c = '部長';
    n.zip_code__c = '987';
    n.address_pref__c = '東京都';
    n.address__c = '渋谷区恵比寿';
    n.tel1__c = '999-888-7777';
    n.fax1__c = '888-777-6666';
    n.mobile__c = '777-666-5555';
    n.web_url1__c = 'http://www.namecard.com';
    n.email__c = 'meishi@namecard.com';
    insert(n);

    t.OwnerId = UserInfo.getUserId();
    t.Subject = 'todo';
    t.WhatId = n.Id;
    insert(t);

    e.OwnerId = UserInfo.getUserId();
    e.Subject = 'event';
    e.WhatId = n.Id;
    e.StartDateTime = Datetime.now().addHours(3);
    e.EndDateTime = Datetime.now().addHours(5);
    insert(e);

    SB_NameCard_AccountUpdateControllerTest.testPage(null, null, null);
    SB_NameCard_AccountUpdateControllerTest.testPage(n.Id, a.Id, null);
    Account a2 = [SELECT Name, Site, BillingPostalCode, BillingState, BillingCity, BillingStreet, Phone, Fax, Website FROM Account WHERE Id=:a.Id];
    System.assertEquals(n.company_name__c, a2.Name);
    System.assertEquals(n.division__c, a2.Site);
    System.assertEquals(n.zip_code__c, a2.BillingPostalCode);
    System.assertEquals(n.address_pref__c, a2.BillingState);
    Map<String, String> address = SB_NameCard_Util.getAddress(n);
    System.assertEquals(address.get('city'), a2.BillingCity);
    System.assertEquals(address.get('street'), a2.BillingStreet);
    System.assertEquals(n.tel1__c, a2.Phone);
    System.assertEquals(n.fax1__c, a2.Fax);
    System.assertEquals(n.web_url1__c, a2.Website);

    NameCard__c na = [SELECT account__c FROM NameCard__c WHERE Id=:n.Id];
    System.assertEquals(a2.Id, na.account__c);

    SB_NameCard_AccountUpdateControllerTest.testPage(n.Id, null, c.Id);
    Contact c2 = [SELECT LastName, FirstName, AccountId, Title, MailingPostalCode, MailingState, MailingCity, MailingStreet, Phone, Fax, MobilePhone, Email FROM Contact WHERE Id=:c.Id];
    System.assertEquals(na.account__c, c2.AccountId);

    List<Task> taskList = [SELECT WhoId FROM Task WHERE WhatId = :n.Id];
    System.assertEquals(1, taskList.size());
    System.assertEquals(c2.Id, taskList[0].WhoId);

    List<Event> eventList = [SELECT WhoId FROM Event WHERE WhatId = :n.Id];
    System.assertEquals(1, eventList.size());
    System.assertEquals(c2.Id, eventList[0].WhoId);

    Map<String, String> tmp = SB_NameCard_Util.getPersonName(n);
    System.assertEquals(tmp.get('last_name'), c2.LastName);
    System.assertEquals(tmp.get('first_name'), c2.FirstName);

    System.assertEquals(n.title_name__c, c2.Title);
    System.assertEquals(n.zip_code__c, c2.MailingPostalCode);
    System.assertEquals(n.address_pref__c, c2.MailingState);

    tmp = SB_NameCard_Util.getAddress(n);
    System.assertEquals(tmp.get('city'), c2.MailingCity);
    System.assertEquals(tmp.get('street'), c2.MailingStreet);

    System.assertEquals(n.tel1__c, c2.Phone);
    System.assertEquals(n.fax1__c, c2.Fax);
    System.assertEquals(n.mobile__c, c2.MobilePhone);
    System.assertEquals(n.email__c, c2.Email);

    NameCard__c nc = [SELECT contact__c FROM NameCard__c WHERE Id=:n.Id];
    System.assertEquals(c2.Id, nc.contact__c);
  }
}