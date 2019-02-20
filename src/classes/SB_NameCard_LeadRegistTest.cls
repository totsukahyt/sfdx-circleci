/*
 * (c) 2015 Sunbridge Inc.
 *
 * リードに登録
 * リードを更新
 * テスト
 */

@isTest private class SB_NameCard_LeadRegistTest
{
    @isTest private static void test1()
    {
        insertNameCard();
        SmartViscaf__NameCard__c nc = getNameCard('TestCompany');
        System.debug('SB_NameCard_LeadRegistTest nc.Id: '+nc.Id);

        Test.startTest();

        PageReference pageRef = Page.SB_NameCard_LeadRegist;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(nc);
        SB_NameCard_LeadRegistController ctrl = new SB_NameCard_LeadRegistController(sc);

        SB_NameCard_LeadRegistController.getSearchTypeList();

        ctrl.leadRecordListIndex = ctrl.leadRecordList.size()-1;
        ctrl.registTodo = true;

        PageReference savePageRef = ctrl.save();
        System.assertNotEquals(null, savePageRef, 'Save error');

        nc = getNameCard(nc.Id);
        System.debug('SB_NameCard_LeadRegistTest nc.lead__c: '+nc.SmartViscaf__lead__c);
        System.assertNotEquals(null, nc.SmartViscaf__lead__c, 'nc.lead__c error');

        ctrl.cancel();

        Test.stopTest();
    }

    @isTest private static void test2()
    {
        insertNameCard();
        SmartViscaf__NameCard__c nc = getNameCard('TestCompany');
        System.debug('SB_NameCard_LeadRegistTest nc.Id: '+nc.Id);

        insertLead(nc);
        Lead lead = getLead(nc.Id);
        System.debug('SB_NameCard_LeadRegistTest lead.Id: '+lead.Id);

        Test.startTest();

        PageReference pageRef = Page.SB_NameCard_LeadRegist;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(nc);
        SB_NameCard_LeadRegistController ctrl = new SB_NameCard_LeadRegistController(sc);

        ctrl.searchType = SB_NameCard_LeadRegist.SEARCHTYPE_EMAIL;
        ctrl.search();
        ctrl.searchType = SB_NameCard_LeadRegist.SEARCHTYPE_NAME;
        ctrl.search();

        ctrl.lookUpIndex = ctrl.leadRecordList.size()-2;
        SB_NameCard_LeadRegistController.LeadRecord leadRec = ctrl.leadRecordList.get(ctrl.lookUpIndex);
        leadRec.lookUpNameCard.SmartViscaf__lead__c = lead.Id;
        ctrl.setLookUp();

        ctrl.leadRecordListIndex = 0;

        PageReference savePageRef = ctrl.save();
        System.assertNotEquals(null, savePageRef, 'Save error');

        nc = getNameCard(nc.Id);
        System.debug('SB_NameCard_LeadRegistTest nc.lead__c: '+nc.SmartViscaf__lead__c);
        System.assertEquals(lead.Id, nc.SmartViscaf__lead__c, 'LeadId error');

        Test.stopTest();
    }

    @isTest private static void test3()
    {
        insertNameCard();
        SmartViscaf__NameCard__c nc = getNameCard('TestCompany');
        System.debug('SB_NameCard_LeadRegistTest nc.Id: '+nc.Id);

        insertLead(nc);
        Lead lead = getLead(nc.Id);
        System.debug('SB_NameCard_LeadRegistTest lead.Id: '+lead.Id);

        Test.startTest();

        PageReference pageRef = Page.SB_NameCard_LeadNameCardList;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(lead);
        SB_NameCard_LeadNameCardListController ctrl = new SB_NameCard_LeadNameCardListController(sc);

        ctrl.nameCardRecordListIndex = 0;

        PageReference savePageRef = ctrl.save();
        System.assertNotEquals(null, savePageRef, 'Save error');

        nc = getNameCard(nc.Id);
        System.debug('SB_NameCard_LeadRegistTest nc.lead__c: '+nc.SmartViscaf__lead__c);
        System.assertEquals(lead.Id, nc.SmartViscaf__lead__c, 'LeadId error');

        ctrl.cancel();

        Test.stopTest();
    }

    @isTest private static void test4()
    {
        insertNameCard();
        SmartViscaf__NameCard__c nc = getNameCard('TestCompany');
        List<SmartViscaf__NameCard__c> ncList = new List<SmartViscaf__NameCard__c> { nc };
        System.debug('SB_NameCard_LeadRegistTest nc.Id: '+ncList[0].Id);

        Test.startTest();

        PageReference pageRef = Page.SB_NameCard_LeadBulkRegist;
        pageRef.getParameters().put('retUrl', '/home/home.jsp');
        Test.setCurrentPage(pageRef);
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(ncList);
        ssc.setSelected(ncList);
        SB_NameCard_LeadBulkRegistController ctrl = new SB_NameCard_LeadBulkRegistController(ssc);

        SB_NameCard_LeadRegistController.getSearchTypeList();

        ctrl.nameCardRecordList[0].leadId = 'new';
        ctrl.nameCardRecordList[0].registTodo = true;
        ctrl.ownerlead.OwnerId = Userinfo.getUserid();

        ctrl.save();
        //System.assertNotEquals(null, savePageRef, 'Save error');
        nc = getNameCard(nc.Id);
        System.debug('SB_NameCard_LeadRegistTest nc.lead__c: '+nc.SmartViscaf__lead__c);
        System.assertNotEquals(null, nc.SmartViscaf__lead__c, 'nc.lead__c error');

        //ctrl.cancel();

        Test.stopTest();
    }

    @isTest private static void test5()
    {
        insertNameCard();
        SmartViscaf__NameCard__c nc = getNameCard('TestCompany');
        List<SmartViscaf__NameCard__c> ncList = new List<SmartViscaf__NameCard__c> { nc };
        System.debug('SB_NameCard_LeadRegistTest nc.Id: '+ncList[0].Id);

        insertLead(nc);
        Lead lead = getLead(nc.Id);
        System.debug('SB_NameCard_LeadRegistTest lead.Id: '+lead.Id);

        Test.startTest();

        PageReference pageRef = Page.SB_NameCard_LeadBulkRegist;
        pageRef.getParameters().put('retUrl', '/home/home.jsp');
        Test.setCurrentPage(pageRef);
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(ncList);
        ssc.setSelected(ncList);
        SB_NameCard_LeadBulkRegistController ctrl = new SB_NameCard_LeadBulkRegistController(ssc);

        ctrl.searchType = SB_NameCard_LeadRegist.SEARCHTYPE_EMAIL;
        ctrl.search();
        ctrl.searchType = SB_NameCard_LeadRegist.SEARCHTYPE_NAME;
        ctrl.search();

        ctrl.nameCardRecordList[0].leadId = lead.Id;
        ctrl.nameCardRecordList[0].registTodo = true;

        ctrl.save();
        //System.assertNotEquals(null, savePageRef, 'Save error');

        nc = getNameCard(nc.Id);
        System.debug('SB_NameCard_LeadRegistTest nc.lead__c: '+nc.SmartViscaf__lead__c);
        System.assertNotEquals(null, nc.SmartViscaf__lead__c, 'nc.lead__c error');

        //ctrl.cancel();

        Test.stopTest();
    }

        @isTest private static void test6()
    {
        insertNameCardnomail();
        SmartViscaf__NameCard__c nc = getNameCard('TestCompany');
        System.debug('SB_NameCard_LeadRegistTest nc.Id: '+nc.Id);

        insertLead(nc);
        Lead lead = getLead(nc.Id);
        System.debug('SB_NameCard_LeadRegistTest lead.Id: '+lead.Id);

        Test.startTest();

        PageReference pageRef = Page.SB_NameCard_LeadRegist;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(nc);
        SB_NameCard_LeadRegistController ctrl = new SB_NameCard_LeadRegistController(sc);

        ctrl.searchType = SB_NameCard_LeadRegist.SEARCHTYPE_EMAIL;
        ctrl.search();
        ctrl.searchType = SB_NameCard_LeadRegist.SEARCHTYPE_NAME;
        ctrl.search();

        ctrl.lookUpIndex = ctrl.leadRecordList.size()-2;
        SB_NameCard_LeadRegistController.LeadRecord leadRec = ctrl.leadRecordList.get(ctrl.lookUpIndex);
        leadRec.lookUpNameCard.SmartViscaf__lead__c = lead.Id;
        ctrl.setLookUp();
        //ctrl.leadRecordList.get(0).isNew = true;
        ctrl.leadRecordListIndex = ctrl.leadRecordList.size()-2;

        PageReference savePageRef = ctrl.save();
        System.assertNotEquals(null, savePageRef, 'Save error');

        nc = getNameCard(nc.Id);
        System.debug('SB_NameCard_LeadRegistTest nc.lead__c: '+nc.SmartViscaf__lead__c);
        System.assertNotEquals(null, nc.SmartViscaf__lead__c, 'nc.lead__c error');

        Test.stopTest();
    }

    //所有者のデフォルト値のテスト
    @isTest private static void ownerIdDefTest() {
        insertNameCard();
        SmartViscaf__NameCard__c nc = getNameCard('TestCompany');
        PageReference pageRef = Page.SB_NameCard_LeadRegist;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(nc);
        SB_NameCard_LeadRegistController ctrl = new SB_NameCard_LeadRegistController(sc);
        System.assertEquals(nc.OwnerId,ctrl.lead.ownerId);
        Id uid = Userinfo.getUserid();
        List<User> us = [Select Id From User Where Id != :uid];
        User u = us[0];
        ctrl.lead.ownerId = u.Id;
        ctrl.leadRecordListIndex = ctrl.leadRecordList.size()-1;
        PageReference savePageRef = ctrl.save();
        List<Lead> ls = [Select Id From Lead];
        System.assertEquals(ls.size(),1);
        Lead le = getLead(nc.Id);
        System.assertEquals(le.OwnerId,u.Id);
    }

    //所有者のデフォルト値のテスト
    @isTest private static void ownerIdDefTestBulk() {
        insertNameCard();
        SmartViscaf__NameCard__c nc = getNameCard('TestCompany');
        List<SmartViscaf__NameCard__c> ncList = new List<SmartViscaf__NameCard__c>();
        PageReference pageRef = Page.SB_NameCard_LeadBulkRegist;
        Test.setCurrentPage(pageRef);
        ncList.add(nc);
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(ncList);
        ssc.setSelected(ncList);
        SB_NameCard_LeadBulkRegistController ctrl = new SB_NameCard_LeadBulkRegistController(ssc);


        System.assertEquals(null,ctrl.ownerlead.ownerId);
        Id uid = Userinfo.getUserid();
        List<User> us = [Select Id From User Where Id != :uid];
        User u = us[0];
        ctrl.ownerlead.ownerId = u.Id;
        for (SB_NameCard_LeadBulkRegistController.NameCardRecord r : ctrl.nameCardRecordList) {
            r.leadId = 'new';
        }
         ctrl.save();
        List<Lead> ls = [Select Id From Lead];
        System.assertEquals(ls.size(),1);
        Lead le = getLead(nc.Id);
        System.assertEquals(le.OwnerId,u.Id);
    }

    //カスタム設定によるデフォルトtrue
    @isTest private static void cusSettingDefTest() {
        insertNameCard();
        insCusSetting(true);
        SmartViscaf__NameCard__c nc = getNameCard('TestCompany');
        PageReference pageRef = Page.SB_NameCard_LeadRegist;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(nc);
        SB_NameCard_LeadRegistController ctrl = new SB_NameCard_LeadRegistController(sc);
        System.assertEquals(ctrl.registTodo,true);
        System.assertEquals(ctrl.todo.Subject,'交換true');
    }


    //カスタム設定によるデフォルトtrue
    @isTest private static void cusSettingDefTestBulk() {
        insertNameCard();
        SmartViscaf__NameCard__c nc = getNameCard('TestCompany');
        List<SmartViscaf__NameCard__c> ncList = new List<SmartViscaf__NameCard__c>();
        PageReference pageRef = Page.SB_NameCard_LeadBulkRegist;
        Test.setCurrentPage(pageRef);
        ncList.add(nc);
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(ncList);
        ssc.setSelected(ncList);
        SB_NameCard_LeadBulkRegistController ctrl = new SB_NameCard_LeadBulkRegistController(ssc);
        for (SB_NameCard_LeadBulkRegistController.NameCardRecord r : ctrl.nameCardRecordList) {
            System.assertEquals(r.registTodo,true);
        }
    }

     //カスタム設定によるデフォルト false
    @isTest private static void cusSettingDefFTest() {
        insertNameCard();
        insCusSetting(false);
        SmartViscaf__NameCard__c nc = getNameCard('TestCompany');
        PageReference pageRef = Page.SB_NameCard_LeadRegist;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(nc);
        SB_NameCard_LeadRegistController ctrl = new SB_NameCard_LeadRegistController(sc);
        System.assertEquals(ctrl.registTodo,false);
        System.assertEquals(ctrl.todo.Subject,'交換false');
    }


    //カスタム設定によるデフォルト false
    @isTest private static void cusSettingDefFTestBulk() {
        insertNameCard();
        insCusSetting(false);
        SmartViscaf__NameCard__c nc = getNameCard('TestCompany');
        List<SmartViscaf__NameCard__c> ncList = new List<SmartViscaf__NameCard__c>();
        PageReference pageRef = Page.SB_NameCard_LeadBulkRegist;
        Test.setCurrentPage(pageRef);
        ncList.add(nc);
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(ncList);
        ssc.setSelected(ncList);
        SB_NameCard_LeadBulkRegistController ctrl = new SB_NameCard_LeadBulkRegistController(ssc);
        for (SB_NameCard_LeadBulkRegistController.NameCardRecord r : ctrl.nameCardRecordList) {
            System.assertEquals(r.registTodo,false);
        }
    }

    private static void insertNameCard()
    {
        SmartViscaf__NameCard__c nc = new SmartViscaf__NameCard__c();
        nc.SmartViscaf__zip_code__c = '150-0022';
        nc.SmartViscaf__address_pref__c = '東京都';
        nc.SmartViscaf__address__c = '渋谷区恵比寿南';
        nc.SmartViscaf__company_name__c = 'TestCompany';
        nc.SmartViscaf__tel1__c = '03-1111-1111';
        nc.SmartViscaf__fax1__c = '03-1111-1112';
        nc.SmartViscaf__title_name__c = 'TestTitle';
        nc.SmartViscaf__person_name_last__c = 'TestLast';
        nc.SmartViscaf__person_name_first__c = 'TestFirst';
        nc.SmartViscaf__email__c = 'test@sbnc.example.com';
        nc.SmartViscaf__mobile__c = '090-1111-1111';
        nc.SmartViscaf__card_exchange_date__c = Date.today();

        Database.DMLOptions dml = new Database.DMLOptions();

        dml.OptAllOrNone = false;

        Database.SaveResult sr = SB_NameCard_LeadCrudFls.screate(new List<SmartViscaf__NameCard__c>{nc},dml)[0];
        System.assertEquals(0, sr.getErrors().size(), 'NameCard error');

        System.debug('SB_NameCard_LeadRegistTest nc.Id: '+nc.Id);
    }

    private static void insertNameCardnomail()
    {
        SmartViscaf__NameCard__c nc = new SmartViscaf__NameCard__c();
        nc.SmartViscaf__zip_code__c = '150-0022';
        nc.SmartViscaf__address_pref__c = '東京都';
        nc.SmartViscaf__address__c = '渋谷区恵比寿南';
        nc.SmartViscaf__company_name__c = 'TestCompany';
        nc.SmartViscaf__tel1__c = '03-1111-1111';
        nc.SmartViscaf__fax1__c = '03-1111-1112';
        nc.SmartViscaf__title_name__c = 'TestTitle';
        nc.SmartViscaf__person_name_last__c = 'TestLast';
        nc.SmartViscaf__person_name_first__c = 'TestFirst';

        //nc.SmartViscaf__email__c = 'test@sbnc.example.com';
        nc.SmartViscaf__mobile__c = '090-1111-1111';
        nc.SmartViscaf__card_exchange_date__c = Date.today();

        Database.DMLOptions dml = new Database.DMLOptions();

        dml.OptAllOrNone = false;

        Campaign cc = new Campaign();
        cc.Name = 'test';
        Database.SaveResult sr = SB_NameCard_LeadCrudFls.screate(new List<Campaign>{cc},dml)[0];

        nc.campaign__c = cc.Id;

        Database.SaveResult sr1 = SB_NameCard_LeadCrudFls.screate(new List<SmartViscaf__NameCard__c>{nc},dml)[0];
        System.assertEquals(0, sr.getErrors().size(), 'saveCampaign error');
        System.assertEquals(0, sr1.getErrors().size(), 'savenamecard error');

        System.debug('SB_NameCard_LeadRegistTest nc.Id: '+nc.Id);
    }

    private static void insertLead(SmartViscaf__NameCard__c nc)
    {
        Lead lead = SB_NameCard_LeadRegist.getLead(null, nc, null,null);
        Database.DMLOptions dml = new Database.DMLOptions();

        dml.OptAllOrNone = false;

        Database.SaveResult sr = SB_NameCard_LeadCrudFls.screate(new List<Lead>{lead},dml)[0];
        System.assertEquals(0, sr.getErrors().size(), 'savelead error');

        System.debug('SB_NameCard_LeadRegistTest lead.Id: '+lead.Id);
    }

    private static SmartViscaf__NameCard__c getNameCard(String company)
    {
        System.assertNotEquals(null,company, 'company error');
        SmartViscaf__NameCard__c card = [SELECT Id, SmartViscaf__zip_code__c, SmartViscaf__address_pref__c, SmartViscaf__address__c,
            SmartViscaf__address_bld__c, SmartViscaf__address_eng__c, SmartViscaf__company_name__c, SmartViscaf__web_url1__c,
            SmartViscaf__tel1__c, SmartViscaf__fax1__c, SmartViscaf__title_name__c, SmartViscaf__person_name_last__c,
            SmartViscaf__person_name_first__c, SmartViscaf__last_name__c, SmartViscaf__first_name__c, SmartViscaf__email__c,
            SmartViscaf__mobile__c, SmartViscaf__list_name__c, SmartViscaf__memo__c, SmartViscaf__freehandmemo__c, OwnerId
            FROM SmartViscaf__NameCard__c WHERE SmartViscaf__company_name__c = :company];
        System.assertNotEquals(null,card, 'company error');
        return card;

    }

    private static SmartViscaf__NameCard__c getNameCard(Id ncId)
    {
        System.assertNotEquals(null,ncId, 'ncId error');
        SmartViscaf__NameCard__c card = [SELECT Id, SmartViscaf__lead__c FROM SmartViscaf__NameCard__c WHERE Id = :ncId];
        System.assertNotEquals(null,card, 'company error');
        return card;
    }

    private static Lead getLead(Id ncId)
    {
        System.assertNotEquals(null,ncId, 'ncId error');
        Lead lead = [SELECT Id,OwnerId FROM Lead WHERE NameCard__c = :ncId];
        System.assertNotEquals(null,lead, 'company error');
        return lead;
    }

    private static void insCusSetting(Boolean flage)
    {
        SmartViscaf__SmartViscaConfig__c smartViscaConfig = new SmartViscaf__SmartViscaConfig__c();
        smartViscaConfig.LeadRegist_DispEmail__c = flage;
        smartViscaConfig.LeadRegist_DispLastModifiedDate__c = flage;
        smartViscaConfig.LeadRegist_DispOwner__c = flage;
        smartViscaConfig.LeadRegist_DispState__c = flage;
        smartViscaConfig.LeadRegist_Overwrite__c = flage;
        smartViscaConfig.LeadRegist_DispTitle__c = flage;
        smartViscaConfig.LeadRegist_DispLeadRectype__c = flage;
        smartViscaConfig.LeadRegist_TodoSubject__c = flage ? '交換true' : '交換false';
        smartViscaConfig.LeadRegist_DispCompany__c = flage;
        smartViscaConfig.LeadRegist_RegistTodo__c = flage;
        upsert smartViscaConfig;
    }
}