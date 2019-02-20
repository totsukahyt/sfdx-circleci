/*
 * (c) 2015 Sunbridge Inc.
 *
 * リードに登録
 * リードを更新
 * テスト
 */

@isTest private class SB_NameCard_LeadRegistTest
{
    /**
      * @description 連携マッピング用データー作成するメソッド
    **/
    private static void setMappingDate() {
      SmartViscaf__NameCardBasicSetting__c setting = SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting();
      upsert setting;
      System.assertEquals(true, String.isNotBlank(setting.Id));
      String objname = 'SmartViscaf__NameCardRenkeiMapping__c';
      List<RecordType> res = [SELECT Id,Name,Developername FROM RecordType WHERE SobjectType = :objname ORDER BY Developername];
      System.assertEquals('Lead2', res[2].Developername);
      System.assertEquals('Contact', res[1].Developername);
      System.assertEquals('Account', res[0].Developername);
      System.debug('resresres' + res);
      List<SmartViscaf__NameCardRenkeiMapping__c> testmapplist = new List<SmartViscaf__NameCardRenkeiMapping__c>();
      SmartViscaf__NameCardRenkeiMapping__c lmap = new SmartViscaf__NameCardRenkeiMapping__c();
      lmap.SmartViscaf__IsActive__c = true;
      lmap.SmartViscaf__TargetName__c = 'Company';
      lmap.SmartViscaf__NameCardName__c = 'SmartViscaf__company_name__c';
      lmap.SmartViscaf__BasicSetting__c = setting.Id;
      lmap.RecordTypeId = res[2].Id; // Lead
      testmapplist.add(lmap);

      lmap = new SmartViscaf__NameCardRenkeiMapping__c();
      lmap.SmartViscaf__IsActive__c = true;
      lmap.SmartViscaf__TargetName__c = 'LastName';
      lmap.SmartViscaf__NameCardName__c = 'SmartViscaf__person_name_last__c';
      lmap.SmartViscaf__BasicSetting__c = setting.Id;
      lmap.RecordTypeId = res[2].Id; // Lead
      testmapplist.add(lmap);

      lmap = new SmartViscaf__NameCardRenkeiMapping__c();
      lmap.SmartViscaf__IsActive__c = true;
      lmap.SmartViscaf__TargetName__c = SB_NameCardL_Util.getNamespacePrefix_x() + 'NameCard__c';
      lmap.SmartViscaf__NameCardName__c = 'Id';
      lmap.SmartViscaf__BasicSetting__c = setting.Id;
      lmap.RecordTypeId = res[2].Id; // Lead
      testmapplist.add(lmap);

      SmartViscaf__NameCardRenkeiMapping__c cmap = new SmartViscaf__NameCardRenkeiMapping__c();
      cmap.SmartViscaf__IsActive__c = true;
      cmap.SmartViscaf__TargetName__c = 'LastName';
      cmap.SmartViscaf__NameCardName__c = 'SmartViscaf__person_name_last__c';
      cmap.RecordTypeId = res[1].Id; // Contact
      cmap.SmartViscaf__BasicSetting__c = setting.Id;
      testmapplist.add(cmap);

      SmartViscaf__NameCardRenkeiMapping__c amap = new SmartViscaf__NameCardRenkeiMapping__c();
      amap.SmartViscaf__IsActive__c = true;
      amap.SmartViscaf__TargetName__c = 'Name';
      amap.SmartViscaf__NameCardName__c = 'SmartViscaf__company_name__c';
      amap.RecordTypeId = res[0].Id; // Account
      amap.SmartViscaf__BasicSetting__c = setting.Id;
      testmapplist.add(amap);

      insert testmapplist;
    }

    @isTest private static void test1() {
      List<User> u = insertUser();
      System.runAs(u[1]){
        setMappingDate();
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
        PageReference savePageRef = ctrl.saveLead();
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
        setMappingDate();
        insertNameCard(true);
        SmartViscaf__NameCard__c nc = getNameCard('TestCompany');
        System.debug('SB_NameCard_LeadRegistTest nc.Id: '+nc.Id);

        insertLead(nc, null);
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
        PageReference savePageRef = ctrl.saveLead();
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
        setMappingDate();
        insertNameCard(true);
        SmartViscaf__NameCard__c nc = getNameCard('TestCompany');
        System.debug('SB_NameCard_LeadRegistTest nc.Id: '+nc.Id);

        insertLead(nc, null);
        Lead lead = getLead(nc.Id);
        System.debug('SB_NameCard_LeadRegistTest lead.Id: '+lead.Id);

        Test.startTest();

        PageReference pageRef = Page.SB_NameCard_LeadNameCardList;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(lead);
        SB_NameCard_LeadNameCardListController ctrl = new SB_NameCard_LeadNameCardListController(sc);

        ctrl.nameCardRecordListIndex = 0;

        PageReference savePageRef = ctrl.saveLead();
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
        setMappingDate();
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

 
        ctrl.saveLead();
        System.assertEquals(null, ctrl.testError);
        System.assertEquals(true, ctrl.saveOK);
        List<Lead> ls = [SELECT Id
                           FROM Lead];
        System.assertEquals(1, ls.size());
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
          setMappingDate();
          insertNameCard(true);
          SmartViscaf__NameCard__c nc = getNameCard('TestCompany');
          List<SmartViscaf__NameCard__c> ncList = new List<SmartViscaf__NameCard__c> { nc };
          System.debug('SB_NameCard_LeadRegistTest nc.Id: '+ncList[0].Id);

          insertLead(nc, null);
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

          ctrl.saveLead();
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
        setMappingDate();
        insertNameCard(false);

        SmartViscaf__NameCard__c nc = getNameCard('TestCompany');
        System.debug('SB_NameCard_LeadRegistTest nc.Id: '+nc.Id);

        insertLead(nc, null);
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

        PageReference savePageRef = ctrl.saveLead();
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
            setMappingDate();
            insertNameCard(true);
            SmartViscaf__NameCard__c nc = getNameCard('TestCompany');
            PageReference pageRef = Page.SB_NameCard_LeadRegist;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(nc);
            SB_NameCard_LeadRegistController ctrl = new SB_NameCard_LeadRegistController(sc);
            System.assertEquals(nc.OwnerId,ctrl.pageLead.ownerId);
            // System.assertNotEquals(SB_NameCard_LeadRegistController.smartViscaConfig, null);
            ctrl.pageLead.ownerId = u[0].Id;
            ctrl.leadRecordListIndex = ctrl.leadRecordList.size()-1;
            PageReference savePageRef = ctrl.saveLead();
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
            setMappingDate();
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
            ctrl.saveLead();
            List<Lead> ls = [Select Id From Lead];
            System.assertEquals(ls.size(),1);
            Lead le = getLead(nc.Id);
            System.assertEquals(le.OwnerId,u[0].Id);
            SB_NameCard_LeadBulkRegistController ctrl1 = new SB_NameCard_LeadBulkRegistController(ssc);
            for (SB_NameCard_LeadBulkRegistController.NameCardRecord r : ctrl1.nameCardRecordList) {
                r.leadId = 'new';
            }
            ctrl.saveLead();
        }
    }

    //カスタム設定によるデフォルトtrue
    @isTest private static void test_cusSettingDefTest() {
        List<User> u = insertUser();
        System.runAs(u[1]){
            //名刺に関するデータを作成
            setMappingDate();
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
            setMappingDate();
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
            setMappingDate();
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
            setMappingDate();
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
            ctrl.pageLead.ownerId = qs.size() > 0 ? qs[0].QueueId : Userinfo.getUserid();
            ctrl.changeOwner();
            //System.assertEquals(!ctrl.canEditTodo, qs.size() > 0);
            if (qs.size() > 0) {
                ctrl.pageLead.ownerId = Userinfo.getUserid();
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
            setMappingDate();
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
                PageReference p = ctrl.saveLead();
                System.assertEquals(p, null);
            }
        }
    }

        //エラーケース
    @isTest private static void test_errorCase2Test() {
        List<User> u = insertUser();
        System.runAs(u[1]){
            setMappingDate();
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
            PageReference p = ctrl.saveLead();
            System.assertNotEquals(p, null);
            SB_NameCard_LeadRegistController ctrl1 = new SB_NameCard_LeadRegistController(sc);
            //新規リード
            ctrl1.leadRecordListIndex = ctrl1.leadRecordList.size()-1;
            ctrl1.registTodo = true;
            //保存
            PageReference p1 = ctrl1.saveLead();
            //System.assertEquals(p1, null);
        }
    }

    //カスタム設定によるデフォルト false
    @isTest private static void test_SettingDefFTestBulk() {
        List<User> u = insertUser();
        System.runAs(u[1]){
            setMappingDate();
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
            // SmartViscaf__SmartViscaConfig__c sms = SB_NameCard_LeadBulkRegistController.smartViscaConfig;
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
            setMappingDate();
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
            ctrl.saveLead();
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
            setMappingDate();
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
            ctrl.saveLead();
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
            setMappingDate();
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
                ctrl.saveLead();
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
            setMappingDate();
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
                ctrl.saveLead();
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
            setMappingDate();
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
                ctrl.saveLead();
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
            setMappingDate();
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
            ctrl.saveLead();
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
            setMappingDate();
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
            ctrl.saveLead();
            System.assertEquals(null, ctrl.testError);
            List<CampaignMember> cmbs = [Select Id,Name,Status From CampaignMember];
            //キャンペーンメンバーをAssert
            System.assertEquals(cmbs.size(),1);
            //キャンペーンメンバーStatusをAssert
            System.assertEquals(cmbs[0].Status,'New1');
        }
    }

    // 詳細
    // リード新規
    // キュー リード使える
    // ToDo あり
    // 結果:エラー ToDoの所有者はキューに設定する事ができません
    @isTest static void testQueueCanUseLeadNewTask() {
      List<User> u = insertUser();
        System.runAs(u[1]) {
        Group g1 = new Group(Name='group name', type='Queue');
        insert g1;
        List<QueuesObject> qss = new List<QueuesObject>();
        QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Lead');
        qss.add(q1);
        QueuesObject q2 = new QueueSObject(QueueID = g1.id, SobjectType = 'SmartViscaf__NameCard__c');
        qss.add(q2);
        insert qss;
        setMappingDate();
        insertNameCard(true);
        insCusSetting(false);
        List<SmartViscaf__NameCard__c> namecards = [Select Id FROM SmartViscaf__NameCard__c];
        System.assertEquals(namecards.size(), 1);
        namecards[0].ownerId = g1.Id;
        update namecards;
        SmartViscaf__NameCard__c nc = namecards[0];

        Test.startTest();
        PageReference pageRef = Page.SB_NameCard_LeadRegist;
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(nc);
        SB_NameCard_LeadRegistController ctrl = new SB_NameCard_LeadRegistController(sc);

        SB_NameCard_LeadRegistController.getSearchTypeList();

        ctrl.leadRecordListIndex = ctrl.leadRecordList.size()-1;
        ctrl.registTodo = true;
        PageReference savePageRef = ctrl.saveLead();
        String todoE = Task.getSobjectType().getDescribe().getLabel();
        todoE += System.Label.SB_NCLD_MSG_Regist_Error;
        System.assertEquals(ctrl.testError, todoE + ': ' + String.format(System.Label.SB_NCLD_MSG_QUEUES_ERROR, new List<String> {'group name'}));

        System.assertEquals(null, savePageRef, 'Save error');

        nc = getNameCard(nc.Id);
        System.debug('SB_NameCard_LeadRegistTest nc.lead__c: '+nc.SmartViscaf__lead__c);
        System.assertEquals(null, nc.SmartViscaf__lead__c, 'nc.lead__c error');
        ctrl.cancel();
        Test.stopTest();
      }
    }

    // 詳細
    // リード新規
    // キュー リード使える
    // ToDo なし
    // 結果:問題なく保存
    @isTest static void testQueueCanUseLeadNewNoTask() {
      List<User> u = insertUser();
        System.runAs(u[1]) {
        Group g1 = new Group(Name='group name', type='Queue');
        insert g1;
        List<QueuesObject> qss = new List<QueuesObject>();
        QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Lead');
        qss.add(q1);
        QueuesObject q2 = new QueueSObject(QueueID = g1.id, SobjectType = 'SmartViscaf__NameCard__c');
        qss.add(q2);
        insert qss;
        setMappingDate();
        insertNameCard(true);
        insCusSetting(false);
        List<SmartViscaf__NameCard__c> namecards = [Select Id FROM SmartViscaf__NameCard__c];
        System.assertEquals(namecards.size(), 1);
        namecards[0].ownerId = g1.Id;
        update namecards;
        SmartViscaf__NameCard__c nc = namecards[0];

        Test.startTest();
        PageReference pageRef = Page.SB_NameCard_LeadRegist;
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(nc);
        SB_NameCard_LeadRegistController ctrl = new SB_NameCard_LeadRegistController(sc);

        SB_NameCard_LeadRegistController.getSearchTypeList();

        ctrl.leadRecordListIndex = ctrl.leadRecordList.size()-1;
        // ctrl.registTodo = true;
        PageReference savePageRef = ctrl.saveLead();
        System.assertEquals(null, ctrl.testError);
        System.assertNotEquals(null, savePageRef, 'Save error');

        nc = getNameCard(nc.Id);
        System.debug('SB_NameCard_LeadRegistTest nc.lead__c: '+nc.SmartViscaf__lead__c);
        System.assertNotEquals(null, nc.SmartViscaf__lead__c, 'nc.lead__c error');
        ctrl.cancel();
        Test.stopTest();
      }
    }

    // 詳細
    // リード新規
    // キュー リード使えない
    // ToDo なし
    // 結果:エラー 選択されたキュー(group name)ではリードにサポートされていません
    // @isTest static void testQueueCantUseLeadNewNoTask() {
    //   List<User> u = insertUser();
    //     System.runAs(u[1]) {
    //     Group g1 = new Group(Name='group name', type='Queue');
    //     insert g1;
    //     List<QueuesObject> qss = new List<QueuesObject>();
    //     // QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Lead');
    //     // qss.add(q1);
    //     QueuesObject q2 = new QueueSObject(QueueID = g1.id, SobjectType = 'SmartViscaf__NameCard__c');
    //     qss.add(q2);
    //     insert qss;
    //     setMappingDate();
    //     insertNameCard(true);
    //     insCusSetting(false);
    //     List<SmartViscaf__NameCard__c> namecards = [Select Id FROM SmartViscaf__NameCard__c];
    //     System.assertEquals(namecards.size(), 1);
    //     namecards[0].ownerId = g1.Id;
    //     update namecards;
    //     SmartViscaf__NameCard__c nc = namecards[0];

    //     Test.startTest();
    //     PageReference pageRef = Page.SB_NameCard_LeadRegist;
    //     Test.setCurrentPage(pageRef);

    //     ApexPages.StandardController sc = new ApexPages.StandardController(nc);
    //     SB_NameCard_LeadRegistController ctrl = new SB_NameCard_LeadRegistController(sc);

    //     SB_NameCard_LeadRegistController.getSearchTypeList();

    //     ctrl.leadRecordListIndex = ctrl.leadRecordList.size()-1;
    //     ctrl.pageLead = new Lead(OwnerId = g1.Id);
    //     // ctrl.registTodo = true;
    //     PageReference savePageRef = ctrl.saveLead();
    //     System.assertEquals(null, savePageRef, 'Save error');
    //     // エラー Assert
    //     System.assertEquals(ctrl.testError, String.format(System.Label.SB_NCLD_MSG_QUEUES_LEAD_ERROR,new String[]{'group name'}));

    //     nc = getNameCard(nc.Id);
    //     System.debug('SB_NameCard_LeadRegistTest nc.lead__c: '+nc.SmartViscaf__lead__c);
    //     System.assertEquals(null, nc.SmartViscaf__lead__c, 'nc.lead__c error');
    //     ctrl.cancel();
    //     Test.stopTest();
    //   }
    // }

    // 詳細
    // リード新規
    // キュー リード使えない
    // ToDo あり
    // 結果:エラー 選択されたキュー(group name)ではリードにサポートされていません
    // @isTest static void testQueueCantUseLeadNewTask() {
    //   List<User> u = insertUser();
    //     System.runAs(u[1]) {
    //     Group g1 = new Group(Name='group name', type='Queue');
    //     insert g1;
    //     List<QueuesObject> qss = new List<QueuesObject>();
    //     // QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Lead');
    //     // qss.add(q1);
    //     QueuesObject q2 = new QueueSObject(QueueID = g1.id, SobjectType = 'SmartViscaf__NameCard__c');
    //     qss.add(q2);
    //     insert qss;
    //     setMappingDate();
    //     insertNameCard(true);
    //     insCusSetting(false);
    //     List<SmartViscaf__NameCard__c> namecards = [Select Id FROM SmartViscaf__NameCard__c];
    //     System.assertEquals(namecards.size(), 1);
    //     namecards[0].ownerId = g1.Id;
    //     update namecards;
    //     SmartViscaf__NameCard__c nc = namecards[0];

    //     Test.startTest();
    //     PageReference pageRef = Page.SB_NameCard_LeadRegist;
    //     Test.setCurrentPage(pageRef);

    //     ApexPages.StandardController sc = new ApexPages.StandardController(nc);
    //     SB_NameCard_LeadRegistController ctrl = new SB_NameCard_LeadRegistController(sc);

    //     SB_NameCard_LeadRegistController.getSearchTypeList();

    //     ctrl.leadRecordListIndex = ctrl.leadRecordList.size()-1;
    //     ctrl.registTodo = true;
    //     PageReference savePageRef = ctrl.saveLead();
    //     System.assertEquals(null, savePageRef, 'Save error');
    //     // エラー Assert
    //     System.assertEquals(ctrl.testError, String.format(System.Label.SB_NCLD_MSG_QUEUES_LEAD_ERROR,new String[]{'group name'}));

    //     nc = getNameCard(nc.Id);
    //     System.debug('SB_NameCard_LeadRegistTest nc.lead__c: '+nc.SmartViscaf__lead__c);
    //     System.assertEquals(null, nc.SmartViscaf__lead__c, 'nc.lead__c error');
    //     ctrl.cancel();
    //     Test.stopTest();
    //   }
    // }

    // 詳細
    // リード更新
    // リード所有者はキュー
    // ToDo あり
    // 結果:エラー ToDoの所有者はキューに設定する事ができません
    @isTest static void testQueueCanUseLeadUpdateTask() {
      List<User> u = insertUser();
        System.runAs(u[1]) {
        Group g1 = new Group(Name='group name', type='Queue');
        insert g1;
        List<QueuesObject> qss = new List<QueuesObject>();
        QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Lead');
        qss.add(q1);
        QueuesObject q2 = new QueueSObject(QueueID = g1.id, SobjectType = 'SmartViscaf__NameCard__c');
        qss.add(q2);
        insert qss;
        setMappingDate();
        insertNameCard(true);
        insCusSetting(false);
        SmartViscaf__NameCard__c nc = getNameCard('TestCompany');
        nc.ownerId = g1.Id;
        update nc;
        insertLead(nc, g1.Id);

        Test.startTest();
        PageReference pageRef = Page.SB_NameCard_LeadRegist;
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(nc);
        SB_NameCard_LeadRegistController ctrl = new SB_NameCard_LeadRegistController(sc);

        SB_NameCard_LeadRegistController.getSearchTypeList();
        System.assertEquals(ctrl.leadRecordList.size(), 3);

        ctrl.leadRecordListIndex = 0;
        ctrl.registTodo = true;
        PageReference savePageRef = ctrl.saveLead();
        System.assertEquals(null, savePageRef, 'Save error');
        // エラー Assert
        String todoE = Task.getSobjectType().getDescribe().getLabel();
        todoE += System.Label.SB_NCLD_MSG_Regist_Error;
        System.assertEquals(ctrl.testError, todoE + ': ' + String.format(System.Label.SB_NCLD_MSG_QUEUES_ERROR, new List<String> {'group name'}));

        nc = getNameCard(nc.Id);
        System.debug('SB_NameCard_LeadRegistTest nc.lead__c: '+nc.SmartViscaf__lead__c);
        System.assertEquals(null, nc.SmartViscaf__lead__c, 'nc.lead__c error');
        ctrl.cancel();
        Test.stopTest();
      }
    }

    // 詳細
    // リード更新
    // リード所有者はキュー
    // ToDo なし
    // 結果:問題なく保存
    @isTest static void testQueueCanUseLeadUpdateNoTask() {
      List<User> u = insertUser();
        System.runAs(u[1]) {
        Group g1 = new Group(Name='group name', type='Queue');
        insert g1;
        List<QueuesObject> qss = new List<QueuesObject>();
        QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Lead');
        qss.add(q1);
        QueuesObject q2 = new QueueSObject(QueueID = g1.id, SobjectType = 'SmartViscaf__NameCard__c');
        qss.add(q2);
        insert qss;
        setMappingDate();
        insertNameCard(true);
        insCusSetting(false);
        SmartViscaf__NameCard__c nc = getNameCard('TestCompany');
        nc.ownerId = g1.Id;
        update nc;
        insertLead(nc, g1.Id);

        Test.startTest();
        PageReference pageRef = Page.SB_NameCard_LeadRegist;
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(nc);
        SB_NameCard_LeadRegistController ctrl = new SB_NameCard_LeadRegistController(sc);

        SB_NameCard_LeadRegistController.getSearchTypeList();
        System.assertEquals(ctrl.leadRecordList.size(), 3);

        ctrl.leadRecordListIndex = 0;
        // ctrl.registTodo = true;
        PageReference savePageRef = ctrl.saveLead();
        System.assertNotEquals(null, savePageRef, 'Save error');

        nc = getNameCard(nc.Id);
        System.debug('SB_NameCard_LeadRegistTest nc.lead__c: '+nc.SmartViscaf__lead__c);
        System.assertNotEquals(null, nc.SmartViscaf__lead__c, 'nc.lead__c error');
        ctrl.cancel();
        Test.stopTest();
      }
    }

    // 詳細
    // リード更新
    // リード所有者は普通ユーザ
    // ToDo なし
    // 結果:問題なく保存
    @isTest static void testQueueCantUseLeadUpdateNoTask() {
      List<User> u = insertUser();
        System.runAs(u[1]) {
        Group g1 = new Group(Name='group name', type='Queue');
        insert g1;
        List<QueuesObject> qss = new List<QueuesObject>();
        // QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Lead');
        // qss.add(q1);
        QueuesObject q2 = new QueueSObject(QueueID = g1.id, SobjectType = 'SmartViscaf__NameCard__c');
        qss.add(q2);
        insert qss;
        setMappingDate();
        insertNameCard(true);
        insCusSetting(false);
        SmartViscaf__NameCard__c nc = getNameCard('TestCompany');
        nc.ownerId = g1.Id;
        update nc;
        insertLead(nc, u[1].Id);

        Test.startTest();
        PageReference pageRef = Page.SB_NameCard_LeadRegist;
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(nc);
        SB_NameCard_LeadRegistController ctrl = new SB_NameCard_LeadRegistController(sc);

        SB_NameCard_LeadRegistController.getSearchTypeList();
        System.assertEquals(ctrl.leadRecordList.size(), 3);

        ctrl.leadRecordListIndex = 0;
        // ctrl.registTodo = true;
        PageReference savePageRef = ctrl.saveLead();
        System.assertNotEquals(null, savePageRef, 'Save error');

        nc = getNameCard(nc.Id);
        System.debug('SB_NameCard_LeadRegistTest nc.lead__c: '+nc.SmartViscaf__lead__c);
        System.assertNotEquals(null, nc.SmartViscaf__lead__c, 'nc.lead__c error');
        ctrl.cancel();
        Test.stopTest();
      }
    }

    // 詳細
    // リード更新
    // リード所有者は普通ユーザ
    // ToDo あり
    // 結果:問題なく保存
    @isTest static void testQueueCantUseLeadUpdateTask() {
      List<User> u = insertUser();
        System.runAs(u[1]) {
        Group g1 = new Group(Name='group name', type='Queue');
        insert g1;
        List<QueuesObject> qss = new List<QueuesObject>();
        // QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Lead');
        // qss.add(q1);
        QueuesObject q2 = new QueueSObject(QueueID = g1.id, SobjectType = 'SmartViscaf__NameCard__c');
        qss.add(q2);
        insert qss;
        setMappingDate();
        insertNameCard(true);
        insCusSetting(false);
        SmartViscaf__NameCard__c nc = getNameCard('TestCompany');
        nc.ownerId = g1.Id;
        update nc;
        insertLead(nc, u[1].Id);

        Test.startTest();
        PageReference pageRef = Page.SB_NameCard_LeadRegist;
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(nc);
        SB_NameCard_LeadRegistController ctrl = new SB_NameCard_LeadRegistController(sc);

        SB_NameCard_LeadRegistController.getSearchTypeList();
        System.assertEquals(ctrl.leadRecordList.size(), 3);

        ctrl.leadRecordListIndex = 0;
        ctrl.registTodo = true;
        PageReference savePageRef = ctrl.saveLead();
        System.assertEquals(null, ctrl.testError);
        System.assertNotEquals(null, savePageRef, 'Save error');

        nc = getNameCard(nc.Id);
        System.debug('SB_NameCard_LeadRegistTest nc.lead__c: '+nc.SmartViscaf__lead__c);
        System.assertNotEquals(null, nc.SmartViscaf__lead__c, 'nc.lead__c error');
        ctrl.cancel();
        Test.stopTest();
      }
    }


    // 一括
    // リード新規
    // キュー リード使える
    // ToDo あり
    // 結果:エラー 1行目:登録エラー:ToDoの所有者はキューに設定する事ができません
    @isTest static void testQueueCanUseLeadNewTaskBulk() {
      List<User> u = insertUser();
        System.runAs(u[1]) {
        Group g1 = new Group(Name='group name', type='Queue');
        insert g1;
        List<QueuesObject> qss = new List<QueuesObject>();
        QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Lead');
        qss.add(q1);
        QueuesObject q2 = new QueueSObject(QueueID = g1.id, SobjectType = 'SmartViscaf__NameCard__c');
        qss.add(q2);
        insert qss;
        setMappingDate();
        insertNameCard(true);
        insCusSetting(false);
        List<SmartViscaf__NameCard__c> namecards = [Select Id FROM SmartViscaf__NameCard__c];
        System.assertEquals(namecards.size(), 1);
        namecards[0].ownerId = g1.Id;
        update namecards;
        SmartViscaf__NameCard__c nc = namecards[0];

        Test.startTest();
        PageReference pageRef = Page.SB_NameCard_LeadBulkRegist;
        Test.setCurrentPage(pageRef);

        List<SmartViscaf__NameCard__c> ncList = new List<SmartViscaf__NameCard__c> { nc };

        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(ncList);
        ssc.setSelected(ncList);
        SB_NameCard_LeadBulkRegistController ctrl = new SB_NameCard_LeadBulkRegistController(ssc);

        ctrl.nameCardRecordList[0].leadId = 'new';
        ctrl.nameCardRecordList[0].registTodo = true;
        ctrl.useNameCardOwner = true;
        ctrl.saveLead();
        //System.assertNotEquals(null, savePageRef, 'Save error');
        String todoE = Task.getSobjectType().getDescribe().getLabel();
        todoE += System.Label.SB_NCLD_MSG_Regist_Error;
        String msg = 1 + System.Label.SB_NC_Line + ': ' + todoE + ': ' + String.format(System.Label.SB_NCLD_MSG_QUEUES_ERROR, new List<String> {'group name'});
        System.assertEquals(null, nc.SmartViscaf__lead__c, 'nc.lead__c error');
        System.assertEquals(ctrl.testError, msg);
        Test.stopTest();
      }
    }

    // 一括
    // リード新規
    // キュー リード使える
    // ToDo なし
    // 結果:問題なく保存
    @isTest static void testQueueCanUseLeadNewNoTaskBulk() {
      List<User> u = insertUser();
        System.runAs(u[1]) {
        Group g1 = new Group(Name='group name', type='Queue');
        insert g1;
        List<QueuesObject> qss = new List<QueuesObject>();
        QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Lead');
        qss.add(q1);
        QueuesObject q2 = new QueueSObject(QueueID = g1.id, SobjectType = 'SmartViscaf__NameCard__c');
        qss.add(q2);
        insert qss;
        setMappingDate();
        insertNameCard(true);
        insCusSetting(false);
        List<SmartViscaf__NameCard__c> namecards = [Select Id FROM SmartViscaf__NameCard__c];
        System.assertEquals(namecards.size(), 1);
        namecards[0].ownerId = g1.Id;
        update namecards;
        SmartViscaf__NameCard__c nc = namecards[0];

        Test.startTest();
        PageReference pageRef = Page.SB_NameCard_LeadBulkRegist;
        Test.setCurrentPage(pageRef);

        List<SmartViscaf__NameCard__c> ncList = new List<SmartViscaf__NameCard__c> { nc };

        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(ncList);
        ssc.setSelected(ncList);
        SB_NameCard_LeadBulkRegistController ctrl = new SB_NameCard_LeadBulkRegistController(ssc);

        ctrl.nameCardRecordList[0].leadId = 'new';
        ctrl.nameCardRecordList[0].registTodo = false;
        ctrl.useNameCardOwner = true;
        ctrl.saveLead();
        //System.assertNotEquals(null, savePageRef, 'Save error');
        System.assertEquals(null, nc.SmartViscaf__lead__c, 'nc.lead__c error');
        System.assertEquals(ctrl.testError, null);
        Test.stopTest();
      }
    }

    // 一括
    // リード新規
    // キュー リード使えない
    // ToDo なし
    // 結果:エラー 1行目:登録エラー:選択されたキュー(group name)ではリードにサポートされていません
    @isTest static void testQueueCantUseLeadNewNoTaskBulk() {
      List<User> u = insertUser();
        System.runAs(u[1]) {
        Group g1 = new Group(Name='group name', type='Queue');
        insert g1;
        List<QueuesObject> qss = new List<QueuesObject>();
        // QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Lead');
        // qss.add(q1);
        QueuesObject q2 = new QueueSObject(QueueID = g1.id, SobjectType = 'SmartViscaf__NameCard__c');
        qss.add(q2);
        insert qss;
        setMappingDate();
        insertNameCard(true);
        insCusSetting(false);
        List<SmartViscaf__NameCard__c> namecards = [Select Id FROM SmartViscaf__NameCard__c];
        System.assertEquals(namecards.size(), 1);
        namecards[0].ownerId = g1.Id;
        update namecards;
        SmartViscaf__NameCard__c nc = namecards[0];

        Test.startTest();
        PageReference pageRef = Page.SB_NameCard_LeadBulkRegist;
        Test.setCurrentPage(pageRef);

        List<SmartViscaf__NameCard__c> ncList = new List<SmartViscaf__NameCard__c> { nc };

        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(ncList);
        ssc.setSelected(ncList);
        SB_NameCard_LeadBulkRegistController ctrl = new SB_NameCard_LeadBulkRegistController(ssc);

        ctrl.nameCardRecordList[0].leadId = 'new';
        ctrl.nameCardRecordList[0].registTodo = false;
        ctrl.useNameCardOwner = true;
        ctrl.saveLead();
        //System.assertNotEquals(null, savePageRef, 'Save error');
        System.assertEquals(null, nc.SmartViscaf__lead__c, 'nc.lead__c error');
        String msg = 1 + System.Label.SB_NC_Line + ': ' + Lead.getSobjectType().getDescribe().getLabel()
                                 + System.Label.SB_NCLD_MSG_Regist_Error + ': ' + String.format(System.Label.SB_NCLD_MSG_QUEUES_LEAD_ERROR,new String[]{'group name'});
        System.assertEquals(null, nc.SmartViscaf__lead__c, 'nc.lead__c error');
        System.assertEquals(ctrl.testError, msg);
        Test.stopTest();
      }
    }

    // 一括
    // リード新規
    // キュー リード使えない
    // ToDo あり
    // 結果:エラー 1行目:登録エラー:選択されたキュー(group name)ではリードにサポートされていません
    @isTest static void testQueueCantUseLeadNewTaskBulk() {
      List<User> u = insertUser();
        System.runAs(u[1]) {
        Group g1 = new Group(Name='group name', type='Queue');
        insert g1;
        List<QueuesObject> qss = new List<QueuesObject>();
        // QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Lead');
        // qss.add(q1);
        QueuesObject q2 = new QueueSObject(QueueID = g1.id, SobjectType = 'SmartViscaf__NameCard__c');
        qss.add(q2);
        insert qss;
        setMappingDate();
        insertNameCard(true);
        insCusSetting(false);
        List<SmartViscaf__NameCard__c> namecards = [Select Id FROM SmartViscaf__NameCard__c];
        System.assertEquals(namecards.size(), 1);
        namecards[0].ownerId = g1.Id;
        update namecards;
        SmartViscaf__NameCard__c nc = namecards[0];

        Test.startTest();
        PageReference pageRef = Page.SB_NameCard_LeadBulkRegist;
        Test.setCurrentPage(pageRef);

        List<SmartViscaf__NameCard__c> ncList = new List<SmartViscaf__NameCard__c> { nc };

        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(ncList);
        ssc.setSelected(ncList);
        SB_NameCard_LeadBulkRegistController ctrl = new SB_NameCard_LeadBulkRegistController(ssc);

        ctrl.nameCardRecordList[0].leadId = 'new';
        ctrl.nameCardRecordList[0].registTodo = true;
        ctrl.useNameCardOwner = true;
        ctrl.saveLead();
        //System.assertNotEquals(null, savePageRef, 'Save error');
        System.assertEquals(null, nc.SmartViscaf__lead__c, 'nc.lead__c error');
        String msg = 1 + System.Label.SB_NC_Line + ': ' + Lead.getSobjectType().getDescribe().getLabel()
                                 + System.Label.SB_NCLD_MSG_Regist_Error + ': ' + String.format(System.Label.SB_NCLD_MSG_QUEUES_LEAD_ERROR,new String[]{'group name'}) + '<br>';
        System.assertEquals(null, nc.SmartViscaf__lead__c, 'nc.lead__c error');
                String todoE = Task.getSobjectType().getDescribe().getLabel();
        todoE += System.Label.SB_NCLD_MSG_Regist_Error;
        msg = 1 + System.Label.SB_NC_Line + ': ' + todoE + ': ' + String.format(System.Label.SB_NCLD_MSG_QUEUES_ERROR, new List<String> {'group name'});
        System.assertEquals(ctrl.testError, msg);
        Test.stopTest();
      }
    }

    // 一括
    // リード更新
    // リード所有者はキュー
    // ToDo あり
    // 結果:エラー 1行目:登録エラー:ToDoの所有者はキューに設定する事ができません
    @isTest static void testQueueCanUseLeadUpdateTaskBulk() {
      List<User> u = insertUser();
        System.runAs(u[1]) {
        Group g1 = new Group(Name='group name', type='Queue');
        insert g1;
        List<QueuesObject> qss = new List<QueuesObject>();
        QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Lead');
        qss.add(q1);
        QueuesObject q2 = new QueueSObject(QueueID = g1.id, SobjectType = 'SmartViscaf__NameCard__c');
        qss.add(q2);
        insert qss;
        setMappingDate();
        insertNameCard(true);
        insCusSetting(false);
        SmartViscaf__NameCard__c nc = getNameCard('TestCompany');
        nc.ownerId = g1.Id;
        update nc;
        insertLead(nc, g1.Id);

        Test.startTest();
        PageReference pageRef = Page.SB_NameCard_LeadBulkRegist;
        Test.setCurrentPage(pageRef);

        List<SmartViscaf__NameCard__c> ncList = new List<SmartViscaf__NameCard__c> { nc };

        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(ncList);
        ssc.setSelected(ncList);
        SB_NameCard_LeadBulkRegistController ctrl = new SB_NameCard_LeadBulkRegistController(ssc);

        List<Lead> lea = [select Id From Lead];
        System.assertEquals(lea.size(), 1);

        ctrl.nameCardRecordList[0].leadId = lea[0].Id;
        ctrl.nameCardRecordList[0].registTodo = true;
        ctrl.useNameCardOwner = true;
        ctrl.saveLead();
        //System.assertNotEquals(null, savePageRef, 'Save error');
        String todoE = Task.getSobjectType().getDescribe().getLabel();
        todoE += System.Label.SB_NCLD_MSG_Regist_Error;
        String msg = 1 + System.Label.SB_NC_Line + ': ' + todoE + ': ' + String.format(System.Label.SB_NCLD_MSG_QUEUES_ERROR, new List<String> {'group name'});
        System.assertEquals(null, nc.SmartViscaf__lead__c, 'nc.lead__c error');
        System.assertEquals(ctrl.testError, msg);
        Test.stopTest();
      }
    }

    // 一括
    // リード更新
    // リード所有者はキュー
    // ToDo なし
    // 結果:問題なく保存
    @isTest static void testQueueCanUseLeadUpdateNoTaskBulk() {
      List<User> u = insertUser();
        System.runAs(u[1]) {
        Group g1 = new Group(Name='group name', type='Queue');
        insert g1;
        List<QueuesObject> qss = new List<QueuesObject>();
        QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Lead');
        qss.add(q1);
        QueuesObject q2 = new QueueSObject(QueueID = g1.id, SobjectType = 'SmartViscaf__NameCard__c');
        qss.add(q2);
        insert qss;
        setMappingDate();
        insertNameCard(true);
        insCusSetting(false);
        SmartViscaf__NameCard__c nc = getNameCard('TestCompany');
        nc.ownerId = g1.Id;
        update nc;
        insertLead(nc, g1.Id);

        Test.startTest();
        PageReference pageRef = Page.SB_NameCard_LeadBulkRegist;
        Test.setCurrentPage(pageRef);

        List<SmartViscaf__NameCard__c> ncList = new List<SmartViscaf__NameCard__c> { nc };

        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(ncList);
        ssc.setSelected(ncList);
        SB_NameCard_LeadBulkRegistController ctrl = new SB_NameCard_LeadBulkRegistController(ssc);

        List<Lead> lea = [select Id From Lead];
        System.assertEquals(lea.size(), 1);

        ctrl.nameCardRecordList[0].leadId = lea[0].Id;
        ctrl.nameCardRecordList[0].registTodo = false;
        ctrl.useNameCardOwner = true;
        ctrl.saveLead();
        //System.assertNotEquals(null, savePageRef, 'Save error');
        System.assertEquals(ctrl.testError, null);
        Test.stopTest();
      }
    }

    // 一括
    // リード更新
    // リード所有者は普通ユーザ
    // ToDo なし
    // 結果:問題なく保存
    @isTest static void testQueueCantUseLeadUpdateNoTaskBulk() {
      List<User> u = insertUser();
        System.runAs(u[1]) {
        Group g1 = new Group(Name='group name', type='Queue');
        insert g1;
        List<QueuesObject> qss = new List<QueuesObject>();
        // QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Lead');
        // qss.add(q1);
        QueuesObject q2 = new QueueSObject(QueueID = g1.id, SobjectType = 'SmartViscaf__NameCard__c');
        qss.add(q2);
        insert qss;
        setMappingDate();
        insertNameCard(true);
        insCusSetting(false);
        SmartViscaf__NameCard__c nc = getNameCard('TestCompany');
        nc.ownerId = g1.Id;
        update nc;
        insertLead(nc, u[1].Id);

        Test.startTest();
        PageReference pageRef = Page.SB_NameCard_LeadBulkRegist;
        Test.setCurrentPage(pageRef);

        List<SmartViscaf__NameCard__c> ncList = new List<SmartViscaf__NameCard__c> { nc };

        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(ncList);
        ssc.setSelected(ncList);
        SB_NameCard_LeadBulkRegistController ctrl = new SB_NameCard_LeadBulkRegistController(ssc);

        List<Lead> lea = [select Id From Lead];
        System.assertEquals(lea.size(), 1);

        ctrl.nameCardRecordList[0].leadId = lea[0].Id;
        ctrl.nameCardRecordList[0].registTodo = false;
        ctrl.useNameCardOwner = true;
        ctrl.saveLead();
        //System.assertNotEquals(null, savePageRef, 'Save error');
        System.assertEquals(ctrl.testError, null);
        Test.stopTest();
      }
    }

    // 一括
    // リード更新
    // リード所有者は普通ユーザ
    // ToDo あり
    // 結果:問題なく保存
    @isTest static void testQueueCantUseLeadUpdateTaskBulk() {
      List<User> u = insertUser();
        System.runAs(u[1]) {
        Group g1 = new Group(Name='group name', type='Queue');
        insert g1;
        List<QueuesObject> qss = new List<QueuesObject>();
        // QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Lead');
        // qss.add(q1);
        QueuesObject q2 = new QueueSObject(QueueID = g1.id, SobjectType = 'SmartViscaf__NameCard__c');
        qss.add(q2);
        insert qss;
        setMappingDate();
        insertNameCard(true);
        insCusSetting(false);
        SmartViscaf__NameCard__c nc = getNameCard('TestCompany');
        nc.ownerId = g1.Id;
        update nc;
        insertLead(nc, u[1].Id);

        Test.startTest();
        PageReference pageRef = Page.SB_NameCard_LeadBulkRegist;
        Test.setCurrentPage(pageRef);

        List<SmartViscaf__NameCard__c> ncList = new List<SmartViscaf__NameCard__c> { nc };

        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(ncList);
        ssc.setSelected(ncList);
        SB_NameCard_LeadBulkRegistController ctrl = new SB_NameCard_LeadBulkRegistController(ssc);

        List<Lead> lea = [select Id From Lead];
        System.assertEquals(lea.size(), 1);

        ctrl.nameCardRecordList[0].leadId = lea[0].Id;
        ctrl.nameCardRecordList[0].registTodo = true;
        ctrl.useNameCardOwner = true;
        ctrl.saveLead();
        //System.assertNotEquals(null, savePageRef, 'Save error');
        System.assertEquals(ctrl.testError, null);
        Test.stopTest();
      }
    }

    private static void insertNameCard(Boolean haveMail) {
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
            Database.SaveResult sr1 = SmartViscaf.SB_NameCard_CrudFls.screate(new List<Campaign>{cc},dml)[0];
            System.assertEquals(0, sr1.getErrors().size(), 'NameCard error');
            nc.campaign__c = cc.Id;
        }
        Database.SaveResult sr = SmartViscaf.SB_NameCard_CrudFls.screate(new List<SmartViscaf__NameCard__c>{nc},dml)[0];
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

    private static void insertLead(SmartViscaf__NameCard__c nc, Id owner)
    {
        Lead lead = SB_NameCard_LeadRegist.getLead(null, nc, owner,null);
        Database.DMLOptions dml = new Database.DMLOptions();

        dml.OptAllOrNone = false;

        Database.SaveResult sr = SmartViscaf.SB_NameCard_CrudFls.screate(new List<Lead>{lead},dml)[0];
        System.debug(sr);
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
        SmartViscaf__NameCardBasicSetting__c setting = SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting();
        setting.SmartViscaf__RegistToDoSubject__c = flage ? '交換true' : '交換false';
        setting.SmartViscaf__RegistNoToDo__c = !flage;
        upsert setting;
        SmartViscaf__SmartViscaConfig__c conf = SmartViscaf__SmartViscaConfig__c.getInstance(UserInfo.getUserId());
        if (conf.Id == null) conf = SmartViscaf__SmartViscaConfig__c.getInstance(UserInfo.getProfileId());
        if (conf.Id == null) conf = SmartViscaf__SmartViscaConfig__c.getOrgDefaults();
        conf.LeadRegist_RegistTodo__c = flage;
        conf.LeadRegist_TodoSubject__c = flage ? '交換true' : '交換false';
        upsert conf;
    }
}