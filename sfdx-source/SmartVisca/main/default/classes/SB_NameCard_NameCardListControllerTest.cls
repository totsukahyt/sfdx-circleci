/*  $Id: SB_NameCard_NameCardListControllerTest.cls 1 2011-10-16 11:51:01Z ume $    */

/*
 * Copyright (c) 2011-2015 SunBridge
 *
 * 名刺リスト
 */
 @isTest
 private class SB_NameCard_NameCardListControllerTest
 {
    public SB_NameCard_NameCardListControllerTest()
    {
        PageReference p = Page.SB_NameCard_NameCardList;
        Test.setCurrentPage(p);
    }

    public static void testPage(String aid, String cid)
    {
        ApexPages.currentPage().getParameters().put('aid', aid);
        ApexPages.currentPage().getParameters().put('cid', cid);
        SB_NameCard_NameCardListController c = new SB_NameCard_NameCardListController();
        c.cancel();
    }

    public static testMethod void testAll()
    {
        Account a = new Account();
        Contact c = new Contact();
        NameCard__c n = new NameCard__c();

        a.Name = 'SB_TEST';
        a.Site = 'SB_TEST';
        insert(a);

        c.LastName = 'SB_TEST';
        c.FirstName = 'SB_TEST';
        c.Email = 'meishi@namecard.com';
        insert(c);

        List<NameCard__c> ncList = new List<NameCard__c>();

                   // acount -> match, contact -> match
        NameCard__c n1 = new NameCard__c();
        n1.company_name__c = 'SB_TEST';
        n1.person_name_last__c = 'SB_TEST';
        n1.person_name_first__c = 'SB_TEST';
        n1.email__c = 'meishi@namecard.com';
        ncList.add(n1);

        // acount -> not match, contact -> not match
        NameCard__c n2 = new NameCard__c();
        n2.company_name__c = 'TEST1';
        n2.person_name_last__c = 'TEST1';
        n2.person_name_first__c = 'TEST1';
        n2.email__c = 'meishi@namecard.com1';
        ncList.add(n2);

        // acount -> not match, contact -> not match
        NameCard__c n3 = new NameCard__c();
        n3.company_name__c = '';
        n3.person_name_last__c = 'SB_TEST';
        n3.person_name_first__c = '';
        n3.email__c = '';
        ncList.add(n3);

        // acount -> match, contact -> not match
        NameCard__c n4 = new NameCard__c();
        n4.company_name__c = 'SB_TEST';
        n4.person_name_last__c = '';
        n4.person_name_first__c = 'SB_TEST';
        n4.email__c = 'meishi@namecard.com';
        ncList.add(n4);

        // acount -> match, contact -> not match
        NameCard__c n5 = new NameCard__c();
        n5.company_name__c = 'SB_TEST';
        n5.person_name_last__c = 'SB_TEST';
        n5.person_name_first__c = 'SB_TEST';
        n5.email__c = '';
        ncList.add(n5);

        // acount -> not match, contact -> not match
        NameCard__c n6 = new NameCard__c();
        n6.company_name__c = 'TEST1';
        n6.person_name_last__c = 'SB_TEST';
        n6.person_name_first__c = 'SB_TEST';
        n6.email__c = 'meishi@xxx.com';
        ncList.add(n6);

        insert(ncList);

        Test.startTest();

        SB_NameCard_NameCardListControllerTest.testPage(null, null);
        //SB_NameCard_NameCardListControllerTest.testPage(a.Id, null);
        //SB_NameCard_NameCardListControllerTest.testPage(a.Id, c.Id);

        ApexPages.currentPage().getParameters().put('aid', a.Id);
        SB_NameCard_NameCardListController ctr = new SB_NameCard_NameCardListController();
        System.assertEquals(3, ctr.nameCards.size());

        ApexPages.currentPage().getParameters().put('cid', c.Id);
        ctr = new SB_NameCard_NameCardListController();
        System.assertEquals(1, ctr.nameCards.size());

        Test.stopTest();
    }

    public static testMethod void test2()
    {
        Test.startTest();        

        Date dt = Date.newInstance(2016, 5, 1);

        Account a = new Account();
        List<Contact> cList = new List<Contact>();
        List<NameCard__c> ncList = new List<NameCard__c>();

        a.Name = 'SB_TEST';
        insert(a);

        for(Integer i = 1; i <= 1001; i++ ){

            Contact c = new Contact();
            c.FirstName = 'SB_TEST' + i;
            c.LastName = 'SB_TEST';
            c.Email = 'meishi@namecard.com';
            cList.add(c);

            namecard__c nc = new namecard__c();
            nc.name = 'SB_TEST SB_TEST';
            nc.person_name_first__c = 'SB_TEST' + i;
            nc.person_name_last__c = 'SB_TEST';
            nc.email__c = 'meishi@namecard.com';
            nc.company_name__c = 'SB_TEST';
            nc.delivery_type__c = '2';
            nc.card_exchange_date__c = dt;
            
            ncList.add(nc);
        }
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;
        List<Database.SaveResult> sr = Database.insert(cList, dml);
        List<Database.SaveResult> sr1 = Database.insert(ncList, dml);

        SB_NameCard_NameCardListControllerTest.testPage(null, null);

        try {
            ApexPages.currentPage().getParameters().put('aid', a.Id);
            SB_NameCard_NameCardListController ctr = new SB_NameCard_NameCardListController();
        } catch(Exception e) {
            System.assertEquals('検索件数が制限値（1000件）を超えました', e.getMessage());
        }

        Test.stopTest();
    }

}