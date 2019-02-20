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
        List<User> u = insertUser();
        System.runAs(u[1]){
            insertNameCard(true);
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
    }

    @isTest private static void test2() {
        List<User> u = insertUser();
        System.runAs(u[1]){
            insertNameCard(true);
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
            ctrl.checkRadio();
            System.assertEquals(ctrl.leadRecTypeEdit, false);
            PageReference savePageRef = ctrl.save();
            System.assertNotEquals(null, savePageRef, 'Save error');

            nc = getNameCard(nc.Id);
            System.debug('SB_NameCard_LeadRegistTest nc.lead__c: '+nc.SmartViscaf__lead__c);
            System.assertEquals(lead.Id, nc.SmartViscaf__lead__c, 'LeadId error');

            Test.stopTest();
        }
    }

    @isTest private static void test3() {
        List<User> u = insertUser();
        System.runAs(u[1]){
            insertNameCard(true);
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
    }

    @isTest private static void test4() {
        List<User> u = insertUser();
        System.runAs(u[1]){
            insertNameCard(true);
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
    }

    @isTest private static void test5() {
        List<User> u = insertUser();
        System.runAs(u[1]){
            insertNameCard(true);
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
    }

    @isTest private static void test6() {
        List<User> u = insertUser();
        System.runAs(u[1]){
            insertNameCard(false);

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
    }

    //所有者のデフォルト値のテスト
    @isTest private static void test_OwnerIdDefTest() {
        List<User> u = insertUser();
        System.runAs(u[1]){
            insertNameCard(true);
            SmartViscaf__NameCard__c nc = getNameCard('TestCompany');
            PageReference pageRef = Page.SB_NameCard_LeadRegist;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(nc);
            SB_NameCard_LeadRegistController ctrl = new SB_NameCard_LeadRegistController(sc);
            System.assertEquals(nc.OwnerId,ctrl.lead.ownerId);
            System.assertNotEquals(SB_NameCard_LeadRegistController.smartViscaConfig, null);
            ctrl.lead.ownerId = u[0].Id;
            ctrl.leadRecordListIndex = ctrl.leadRecordList.size()-1;
            PageReference savePageRef = ctrl.save();

            List<Lead> ls = [Select Id From Lead];
            System.assertEquals(ls.size(),1);
            Lead le = getLead(nc.Id);
            System.assertEquals(le.OwnerId,u[0].Id);
        }
    }

    //所有者のデフォルト値のテスト
    @isTest private static void test_OwnerIdDefTestBulk() {
        List<User> u = insertUser();
        System.runAs(u[1]){
            insertNameCard(true);
            SmartViscaf__NameCard__c nc = getNameCard('TestCompany');
            PageReference pageRef = Page.SB_NameCard_LeadBulkRegist;
            pageRef.getParameters().put('vfRetURLInSFX', '/home/home.jsp');
            Test.setCurrentPage(pageRef);
            List<SmartViscaf__NameCard__c> ncList = new List<SmartViscaf__NameCard__c>();
            ncList.add(nc);
            ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(ncList);
            ssc.setSelected(ncList);
            SB_NameCard_LeadBulkRegistController ctrl = new SB_NameCard_LeadBulkRegistController(ssc);

            System.assertEquals(null,ctrl.ownerlead.ownerId);
            ctrl.ownerlead.ownerId = u[0].Id;
            System.assertEquals(ctrl.nameCardRecordList.size(),1);
            for (SB_NameCard_LeadBulkRegistController.NameCardRecord r : ctrl.nameCardRecordList) {
                r.leadId = 'new';
            }
            ctrl.leadOverwrite = false;
            ctrl.save();
            List<Lead> ls = [Select Id From Lead];
            System.assertEquals(ls.size(),1);
            Lead le = getLead(nc.Id);
            System.assertEquals(le.OwnerId,u[0].Id);
            SB_NameCard_LeadBulkRegistController ctrl1 = new SB_NameCard_LeadBulkRegistController(ssc);
            for (SB_NameCard_LeadBulkRegistController.NameCardRecord r : ctrl1.nameCardRecordList) {
                r.leadId = 'new';
            }
            ctrl.save();
        }
    }

    //カスタム設定によるデフォルトtrue
    @isTest private static void test_cusSettingDefTest() {
        List<User> u = insertUser();
        System.runAs(u[1]){
            //名刺に関するデータを作成
            insertNameCard(true);
            //基本設定に関するデータを作成
            insCusSetting(true);
            SmartViscaf__NameCard__c nc = getNameCard('TestCompany');
            PageReference pageRef = Page.SB_NameCard_LeadRegist;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(nc);
            SB_NameCard_LeadRegistController ctrl = new SB_NameCard_LeadRegistController(sc);
            System.assertEquals(ctrl.registTodo,true);
            System.assertEquals(ctrl.todo.Subject,'交換true');
        }
    }


    //カスタム設定によるデフォルトtrue
    @isTest private static void test_cusSettingDefTestBulk() {
        List<User> u = insertUser();
        System.runAs(u[1]){
            insertNameCard(true);
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
    }

     //カスタム設定によるデフォルト false
    @isTest private static void test_cusSettingDefFTest() {
        List<User> u = insertUser();
        System.runAs(u[1]){
            insertNameCard(true);
            insCusSetting(false);
            SmartViscaf__NameCard__c nc = getNameCard('TestCompany');
            PageReference pageRef = Page.SB_NameCard_LeadRegist;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(nc);
            SB_NameCard_LeadRegistController ctrl = new SB_NameCard_LeadRegistController(sc);
            List<Schema.RecordTypeInfo> rs =  Lead.sObjectType.getDescribe().getRecordTypeInfos();
            List<RecordTypeInfo> recordtypes = new List<RecordTypeInfo>();
            for (RecordTypeInfo r : rs) {
                if (r.isAvailable() && !r.isMaster()) {
                    recordtypes.add(r);
                }
            }
            List<SelectOption> so = ctrl.getleadRecordTypeOptions();
            System.assertEquals(so.size(), recordtypes.size());
            System.assertEquals(ctrl.registTodo,false);
            System.assertEquals(ctrl.todo.Subject,'交換false');
        }
    }

    //所有者変更などのテスト
    @isTest private static void test_changeOwnerTest() {
        List<User> u = insertUser();
        System.runAs(u[1]){
            insertNameCard(true);
            insCusSetting(false);
            SmartViscaf__NameCard__c nc = getNameCard('TestCompany');
            PageReference pageRef = Page.SB_NameCard_LeadRegist;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(nc);
            SB_NameCard_LeadRegistController ctrl = new SB_NameCard_LeadRegistController(sc);
            List<Schema.RecordTypeInfo> rs =  Lead.sObjectType.getDescribe().getRecordTypeInfos();
            List<RecordTypeInfo> recordtypes = new List<RecordTypeInfo>();
            List<QueueSobject> qs = [SELECT Id, QueueId, SobjectType FROM QueueSobject Where SobjectType = 'Lead'];
            ctrl.lead.ownerId = qs.size() > 0 ? qs[0].QueueId : Userinfo.getUserid();
            ctrl.changeOwner();
            //System.assertEquals(!ctrl.canEditTodo, qs.size() > 0);
            if (qs.size() > 0) {
                ctrl.lead.ownerId = Userinfo.getUserid();
                ctrl.changeOwner();
                //System.assertEquals(ctrl.canEditTodo, true);
            }
            System.assertEquals(ctrl.registTodo,false);
            System.assertEquals(ctrl.todo.Subject,'交換false');
        }
    }

    //エラーケース
    @isTest private static void test_errorCaseTest() {
        List<User> u = insertUser();
        System.runAs(u[1]){
            insertNameCard(true);
            insCusSetting(false);
            Profile prof;
            try{
                prof = [SELECT Id, UserType, Name FROM Profile WHERE Name = 'Read Only' OR Name = '参照のみ'];
            }catch(Exception e){
                prof = [SELECT Id, UserType, Name FROM Profile WHERE Name = 'Read Only' OR Name = '参照のみ'];
            }
            User u1 = new User(Alias = 'test', Email='newusertest@testorgtest.com',
            EmailEncodingKey='UTF-8', LastName='Testingtest', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = prof.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='newusertesttest@testorgtest.com');

            SmartViscaf__NameCard__c nc = getNameCard('TestCompany');
            PageReference pageRef = Page.SB_NameCard_LeadRegist;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(nc);
            SB_NameCard_LeadRegistController ctrl = new SB_NameCard_LeadRegistController(sc);
            System.runAs(u1){
                //新規リード
                ctrl.leadRecordListIndex = ctrl.leadRecordList.size()-1;
                ctrl.registTodo = true;
                //保存
                PageReference p = ctrl.save();
                System.assertEquals(p, null);
            }
        }
    }

        //エラーケース
    @isTest private static void test_errorCase2Test() {
        List<User> u = insertUser();
        System.runAs(u[1]){
            insertNameCard(true);
            insCusSetting(false);
            SmartViscaf__NameCard__c nc = getNameCard('TestCompany');
            PageReference pageRef = Page.SB_NameCard_LeadRegist;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(nc);
            SB_NameCard_LeadRegistController ctrl = new SB_NameCard_LeadRegistController(sc);
            //新規リード
            ctrl.leadRecordListIndex = ctrl.leadRecordList.size()-1;
            ctrl.registTodo = true;
            //保存
            PageReference p = ctrl.save();
            System.assertNotEquals(p, null);
            SB_NameCard_LeadRegistController ctrl1 = new SB_NameCard_LeadRegistController(sc);
            //新規リード
            ctrl1.leadRecordListIndex = ctrl1.leadRecordList.size()-1;
            ctrl1.registTodo = true;
            //保存
            PageReference p1 = ctrl1.save();
            //System.assertEquals(p1, null);
        }
    }

    //カスタム設定によるデフォルト false
    @isTest private static void test_SettingDefFTestBulk() {
        List<User> u = insertUser();
        System.runAs(u[1]){
            insertNameCard(true);
            insCusSetting(false);
            SmartViscaf__NameCard__c nc = getNameCard('TestCompany');
            List<SmartViscaf__NameCard__c> ncList = new List<SmartViscaf__NameCard__c>();
            PageReference pageRef = Page.SB_NameCard_LeadBulkRegist;
            Test.setCurrentPage(pageRef);
            ncList.add(nc);
            ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(ncList);
            ssc.setSelected(ncList);
            SB_NameCard_LeadBulkRegistController ctrl = new SB_NameCard_LeadBulkRegistController(ssc);
            SmartViscaf__SmartViscaConfig__c sms = SB_NameCard_LeadBulkRegistController.smartViscaConfig;
            for (SB_NameCard_LeadBulkRegistController.NameCardRecord r : ctrl.nameCardRecordList) {
                System.assertEquals(r.registTodo,false);
            }
        }
    }

    //名刺所有者使用テストtrue 所有者設定なし
    @isTest private static void test_NameCardOwnerIdBulk() {
        //ユーザ作成
        List<User> u = insertUser();
        System.runAs(u[1]){
            //基本設定に関するデータを作成
            insCusSetting(false);
            //名刺に関するデータを作成
            insertNameCard(false);
            SmartViscaf__NameCard__c nc = getNameCard('TestCompany');
            SmartViscaf__NameCard__c[] ncList = new SmartViscaf__NameCard__c[]{nc};
            PageReference pageRef = Page.SB_NameCard_LeadBulkRegist;
            Test.setCurrentPage(pageRef);

            ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(ncList);
            ssc.setSelected(ncList);
            SB_NameCard_LeadBulkRegistController ctrl = new SB_NameCard_LeadBulkRegistController(ssc);
            //リード新規作成
            for (SB_NameCard_LeadBulkRegistController.NameCardRecord r : ctrl.nameCardRecordList) {
                r.leadId = 'new';
                System.assertEquals(r.registTodo,false);
            }
            ctrl.ownerlead.OwnerId = u[0].Id;
            //名刺所有者を設定
            ctrl.useNameCardOwner = true;
            //保存
            ctrl.save();
            List<Lead> ls = [Select Id,Name,OwnerId From Lead];
            //新規リードassert
            System.assertEquals(ls.size(),1);
            //新規リードOwnerIdassert
            System.assertEquals(ls[0].OwnerId,Userinfo.getUserid());
        }
    }

    //名刺所有者使用テストfalse 所有者設定なし
    @isTest private static void test_NameCardOwnerIdFBulk() {
        List<User> u = insertUser();
        System.runAs(u[1]){
            //基本設定に関するデータを作成
            insCusSetting(false);
            //名刺に関するデータを作成
            insertNameCard(false);
            SmartViscaf__NameCard__c nc = getNameCard('TestCompany');
            SmartViscaf__NameCard__c[] ncList = new SmartViscaf__NameCard__c[]{nc};
            PageReference pageRef = Page.SB_NameCard_LeadBulkRegist;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(ncList);
            ssc.setSelected(ncList);
            SB_NameCard_LeadBulkRegistController ctrl = new SB_NameCard_LeadBulkRegistController(ssc);
            //リード新規作成
            for (SB_NameCard_LeadBulkRegistController.NameCardRecord r : ctrl.nameCardRecordList) {
                r.leadId = 'new';
                System.assertEquals(r.registTodo,false);
            }
            //名刺所有者を設定
            ctrl.useNameCardOwner = false;
            //保存
            ctrl.save();
            List<Lead> ls = [Select Id,Name From Lead];
            //新規リードassert
            System.assertEquals(ls.size(),0);
        }
    }

    //名刺所有者使用テストtrue 所有者設定あり
    @isTest private static void test_NameCardHaveOwnerIdBulk() {
        //ユーザ作成
        List<User> u = insertUser();
        System.runAs(u[1]){
            //基本設定に関するデータを作成
            insCusSetting(false);
            //名刺に関するデータを作成
            insertNameCard(false);

            SmartViscaf__NameCard__c nc = getNameCard('TestCompany');
            SmartViscaf__NameCard__c[] ncList = new SmartViscaf__NameCard__c[]{nc};
            PageReference pageRef = Page.SB_NameCard_LeadBulkRegist;
            Test.setCurrentPage(pageRef);

            ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(ncList);
            ssc.setSelected(ncList);
            SB_NameCard_LeadBulkRegistController ctrl = new SB_NameCard_LeadBulkRegistController(ssc);
            //リード新規作成
            for (SB_NameCard_LeadBulkRegistController.NameCardRecord r : ctrl.nameCardRecordList) {
                r.leadId = 'new';
                System.assertEquals(r.registTodo,false);
            }
            ctrl.ownerlead.OwnerId = u[0].Id;
            //名刺所有者を設定
            ctrl.useNameCardOwner = true;
            System.runAs(u[1]) {
                //保存
                ctrl.save();
            }
            List<Lead> ls = [Select Id,Name,OwnerId From Lead];
            //新規リードassert
            System.assertEquals(ls.size(),1);
            //新規リードOwnerIdassert
            System.assertEquals(ls[0].OwnerId,Userinfo.getUserid());
        }
    }

    //名刺所有者使用テストfalse 所有者設定あり
    @isTest private static void test_NameCardHaveOwnerIdFBulk() {
        //ユーザ作成
        List<User> u = insertUser();
        System.runAs(u[1]){
            //基本設定に関するデータを作成
            insCusSetting(false);
            //名刺に関するデータを作成
            insertNameCard(false);


            SmartViscaf__NameCard__c nc = getNameCard('TestCompany');
            SmartViscaf__NameCard__c[] ncList = new SmartViscaf__NameCard__c[]{nc};
            PageReference pageRef = Page.SB_NameCard_LeadBulkRegist;
            Test.setCurrentPage(pageRef);

            ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(ncList);
            ssc.setSelected(ncList);
            SB_NameCard_LeadBulkRegistController ctrl = new SB_NameCard_LeadBulkRegistController(ssc);
            //リード新規作成
            for (SB_NameCard_LeadBulkRegistController.NameCardRecord r : ctrl.nameCardRecordList) {
                r.leadId = 'new';
                System.assertEquals(r.registTodo,false);
            }
            ctrl.ownerlead.OwnerId = u[0].Id;
            //名刺所有者を設定
            ctrl.useNameCardOwner = false;
            System.runAs(u[1]) {
                //保存
                ctrl.save();
            }
            List<Lead> ls = [Select Id,Name,OwnerId From Lead];
            //新規リードassert
            System.assertEquals(ls.size(),1);
            //新規リードOwnerIdassert
            System.assertEquals(ls[0].OwnerId, u[0].Id);
        }
    }

    //キャンペーン状況に関するテスト -> 一括
    @isTest private static void test_CampaignMemberStatusBulk() {
        //ユーザ作成
        List<User> u = insertUser();
        System.runAs(u[1]){
            //基本設定に関するデータを作成
            insCusSetting(false);
            //名刺に関するデータを作成
            insertNameCard(false);


            List<Campaign> cm = [Select Id,Name From Campaign];
            System.assertNotEquals(cm.size(),0);
            //キャンペーンメンバー状況レコードを作成
            List<CampaignMemberStatus> cpmsa = [SELECT id, CampaignID, HasResponded, IsDefault, Label, SortOrder
                                            FROM CampaignMemberStatus Where CampaignId = :cm];

            CampaignMemberStatus newStatus = new CampaignMemberStatus(CampaignID=cm[0].id, Label='New', IsDefault=true, HasResponded=false, SortOrder=3);
            CampaignMemberStatus newStatus1 = new CampaignMemberStatus(CampaignID=cm[0].id, Label='New1', IsDefault=false, HasResponded=false, SortOrder=4);
            CampaignMemberStatus newStatus2 = new CampaignMemberStatus(CampaignID=cm[0].id, Label='New2', IsDefault=false, HasResponded=false, SortOrder=5);
            insert new CampaignMemberStatus[]{newStatus, newStatus1, newStatus2};

            SmartViscaf__NameCard__c nc = getNameCard('TestCompany');
            SmartViscaf__NameCard__c[] ncList = new SmartViscaf__NameCard__c[]{nc};
            PageReference pageRef = Page.SB_NameCard_LeadBulkRegist;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(ncList);
            ssc.setSelected(ncList);
            SB_NameCard_LeadBulkRegistController ctrl = new SB_NameCard_LeadBulkRegistController(ssc);
            ctrl.insertOption.campaign__c = cm[0].Id;
            //キャンペーンメンバーの選択リストをAssert
            List<SelectOption> cselectOption = ctrl.getCampaignS();
            System.assertEquals(cselectOption.size(),3);
            System.assertEquals(cselectOption[0].getvalue(),'New');
            System.assertEquals(cselectOption[1].getvalue(),'New1');
            System.assertEquals(cselectOption[2].getvalue(),'New2');
            //リード新規作成
            for (SB_NameCard_LeadBulkRegistController.NameCardRecord r : ctrl.nameCardRecordList) {
                r.leadId = 'new';
                System.assertEquals(r.registTodo,false);
            }
            //画面上のキャンペーンを設定
            ctrl.insertOption.campaign__c = cm[0].id;
            //名刺所有者を設定
            ctrl.useNameCardOwner = true;
            //キャンペーンメンバー状況を設定
            ctrl.campStatus = 'New1';
            System.runAs(u[1]) {
                //保存
                ctrl.save();
            }
            List<CampaignMember> cmbs = [Select Id,Name,Status From CampaignMember];
            //キャンペーンメンバーをAssert
            System.assertEquals(cmbs.size(),1);
            //キャンペーンメンバーStatusをAssert
            System.assertEquals(cmbs[0].Status,'New1');
        }
    }

    //キャンペーンなし -> 一括
    @isTest private static void test_NOCampaignMemberBulk() {
        //ユーザ作成
        List<User> u = insertUser();
        System.runAs(u[1]){
            //基本設定に関するデータを作成
            insCusSetting(false);
            //名刺に関するデータを作成
            insertNameCard(false);
            List<Campaign> cm = [Select Id,Name From Campaign];
            System.assertNotEquals(cm.size(),0);
            //キャンペーンメンバー状況レコードを作成
            List<CampaignMemberStatus> cpmsa = [SELECT id, CampaignID, HasResponded, IsDefault, Label, SortOrder
                                            FROM CampaignMemberStatus Where CampaignId = :cm];

            CampaignMemberStatus newStatus = new CampaignMemberStatus(CampaignID=cm[0].id, Label='New', IsDefault=false, HasResponded=false, SortOrder=3);
            CampaignMemberStatus newStatus1 = new CampaignMemberStatus(CampaignID=cm[0].id, Label='New1', IsDefault=false, HasResponded=false, SortOrder=4);
            CampaignMemberStatus newStatus2 = new CampaignMemberStatus(CampaignID=cm[0].id, Label='New2', IsDefault=false, HasResponded=false, SortOrder=5);
            insert new CampaignMemberStatus[]{newStatus, newStatus1, newStatus2};

            SmartViscaf__NameCard__c nc = getNameCard('TestCompany');
            SmartViscaf__NameCard__c[] ncList = new SmartViscaf__NameCard__c[]{nc};
            PageReference pageRef = Page.SB_NameCard_LeadBulkRegist;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(ncList);
            ssc.setSelected(ncList);
            SB_NameCard_LeadBulkRegistController ctrl = new SB_NameCard_LeadBulkRegistController(ssc);
            ctrl.insertOption.campaign__c = cm[0].Id;
            //キャンペーンメンバーの選択リストをAssert
            List<SelectOption> cselectOption = ctrl.getCampaignS();
            System.assertEquals(cselectOption.size(),3);
            System.assertEquals(cselectOption[0].getvalue(),'New');
            System.assertEquals(cselectOption[1].getvalue(),'New1');
            System.assertEquals(cselectOption[2].getvalue(),'New2');
            //リード新規作成
            for (SB_NameCard_LeadBulkRegistController.NameCardRecord r : ctrl.nameCardRecordList) {
                r.leadId = 'new';
                r.message = 'test';
                System.assertEquals(r.registTodo,false);
            }
            //名刺所有者を設定
            //ctrl.useNameCardOwner = true;
            ctrl.search();
            //キャンペーンメンバー状況を設定
            ctrl.campStatus = 'New1';
            List<Schema.RecordTypeInfo> rs =  Lead.sObjectType.getDescribe().getRecordTypeInfos();
            List<RecordTypeInfo> recordtypes = new List<RecordTypeInfo>();
            for (RecordTypeInfo r : rs) {
                if (r.isAvailable() && !r.isMaster()) {
                    recordtypes.add(r);
                }
            }
            List<SelectOption> so = ctrl.getleadrecordtypeOptions();
            System.assertEquals(so.size(), recordtypes.size());
            List<SelectOption> so1 = SB_NameCard_LeadBulkRegistController.getSearchTypeList();
            System.assertEquals(so1.size(), 2);
            //保存
            ctrl.save();
            List<CampaignMember> cmbs = [Select Id,Name,Status From CampaignMember];
            //キャンペーンメンバーをAssert
            System.assertEquals(cmbs.size(),0);
        }
    }

    //キャンペーン状況に関するテスト
    @isTest private static void test_CampaignMemberStatus() {
        List<User> u = insertUser();
        System.runAs(u[1]) {
            //基本設定に関するデータを作成
            insCusSetting(false);
            //名刺に関するデータを作成
            insertNameCard(false);
            List<Campaign> cm = [Select Id,Name From Campaign];
            System.assertNotEquals(cm.size(),0);
            //キャンペーンメンバー状況レコードを作成
            List<CampaignMemberStatus> cpmsa = [SELECT id, CampaignID, HasResponded, IsDefault, Label, SortOrder
                                            FROM CampaignMemberStatus Where CampaignId = :cm];

            CampaignMemberStatus newStatus = new CampaignMemberStatus(CampaignID=cm[0].id, Label='New', IsDefault=false, HasResponded=false, SortOrder=3);
            CampaignMemberStatus newStatus1 = new CampaignMemberStatus(CampaignID=cm[0].id, Label='New1', IsDefault=false, HasResponded=false, SortOrder=4);
            CampaignMemberStatus newStatus2 = new CampaignMemberStatus(CampaignID=cm[0].id, Label='New2', IsDefault=false, HasResponded=false, SortOrder=5);
            insert new CampaignMemberStatus[]{newStatus, newStatus1, newStatus2};

            SmartViscaf__NameCard__c nc = getNameCard('TestCompany');
            SmartViscaf__NameCard__c[] ncList = new SmartViscaf__NameCard__c[]{nc};
            PageReference pageRef = Page.SB_NameCard_LeadBulkRegist;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(nc);
            SB_NameCard_LeadRegistController ctrl = new SB_NameCard_LeadRegistController(sc);
            //キャンペーンメンバーの選択リストをAssert
            List<SelectOption> cselectOption = ctrl.getCampaign();
            System.assertEquals(cselectOption.size(),3);
            System.assertEquals(cselectOption[0].getvalue(),'New');
            System.assertEquals(cselectOption[1].getvalue(),'New1');
            System.assertEquals(cselectOption[2].getvalue(),'New2');

            //新規リード
            ctrl.leadRecordListIndex = ctrl.leadRecordList.size()-1;
            ctrl.registTodo = true;
            //画面上のキャンペーンを設定
            ctrl.namecard.campaign__c = cm[0].id;
            //キャンペーンメンバー状況を設定
            ctrl.campStatus = 'New1';
            //保存
            ctrl.save();
            List<CampaignMember> cmbs = [Select Id,Name,Status From CampaignMember];
            //キャンペーンメンバーをAssert
            System.assertEquals(cmbs.size(),1);
            //キャンペーンメンバーStatusをAssert
            System.assertEquals(cmbs[0].Status,'New1');
        }
    }

    private static void insertNameCard(Boolean haveMail)
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
        if (haveMail == true) {
            nc.SmartViscaf__email__c = 'test@sbnc.example.com';
        }
        nc.SmartViscaf__mobile__c = '090-1111-1111';
        nc.SmartViscaf__card_exchange_date__c = Date.today();

        Database.DMLOptions dml = new Database.DMLOptions();

        dml.OptAllOrNone = false;

        if (haveMail == false) {
            Campaign cc = new Campaign();
            cc.Name = 'test';
            Database.SaveResult sr1 = SB_NameCard_LeadCrudFls.screate(new List<Campaign>{cc},dml)[0];
            System.assertEquals(0, sr1.getErrors().size(), 'NameCard error');
            nc.campaign__c = cc.Id;
        }
        Database.SaveResult sr = SB_NameCard_LeadCrudFls.screate(new List<SmartViscaf__NameCard__c>{nc},dml)[0];
        System.assertEquals(0, sr.getErrors().size(), 'NameCard error');
    }


    private static List<User> insertUser() {
        List<User> us = new List<User>();
        Profile prof = [SELECT Id, UserType, Name FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
        User u = new User(Alias = 'test', Email='newusertest@testorgtest.com',
        EmailEncodingKey='UTF-8', LastName='Testingtest', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = prof.Id,UserPermissionsMarketingUser = true,
        TimeZoneSidKey='America/Los_Angeles', UserName='newusertesttest@testorgtestA.com');

        User u1 = new User(Alias = 'test1', Email='newusertest1@testorgtest.com',
        EmailEncodingKey='UTF-8', LastName='Testingtest1', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = prof.Id,UserPermissionsMarketingUser = true,
        TimeZoneSidKey='America/Los_Angeles', UserName='newusertesttest1@testorgtestB.com');
        insert new User[]{u, u1};

        us.add(u);
        us.add(u1);
        return us;
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