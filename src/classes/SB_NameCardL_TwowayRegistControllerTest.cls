@isTest
private class SB_NameCardL_TwowayRegistControllerTest {

  /**
    * @description 実行ユーザを作成するメソッド
  **/
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

  /**
    * @description データー作成用のメソッド
  **/
  private static void setData(Boolean needNameCard, Boolean needAccount, Boolean needContact, Boolean needLead, Boolean needCampaign) {
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
    nc.SmartViscaf__email__c = 'Test@test.com';

    //nc.SmartViscaf__email__c = 'test@sbnc.example.com';
    nc.SmartViscaf__mobile__c = '090-1111-1111';
    nc.SmartViscaf__card_exchange_date__c = Date.today();

    Database.DMLOptions dml = new Database.DMLOptions();

    dml.OptAllOrNone = false;

    if (needCampaign) {
      Campaign cc = new Campaign();
      cc.Name = 'test';
      if (needNameCard) {
        Database.SaveResult sr = SmartViscaf.SB_NameCard_CrudFls.screate(new List<Campaign>{cc},dml)[0];
        System.assertEquals(0, sr.getErrors().size(), 'saveCampaign error');
      }
      nc.campaign__c = cc.Id;
    }

    Database.SaveResult sr1 = SmartViscaf.SB_NameCard_CrudFls.screate(new List<SmartViscaf__NameCard__c>{nc},dml)[0];
    System.assertEquals(0, sr1.getErrors().size(), 'savenamecard error');

    System.debug('SB_NameCard_LeadRegistTest nc.Id: '+nc.Id);
    Account a ;
    if (needAccount) {
      a = new Account(Name = 'TestCompany');
      a.SmartViscaf__NameCard__c = nc.Id;
      a.Site = 'TestSite';
      a.BillingState = 'TestBillingState';
      insert a;
      nc.SmartViscaf__account__c = a.Id;
    }

    if (needContact) {
      Contact cont = new Contact();
      if (a != null) {
        cont.AccountId = a.Id;
      }
      cont.LastName = 'TestLast';
      cont.FirstName = 'TestFirst';
      cont.SmartViscaf__NameCard__c = nc.Id;
      cont.MailingState = 'TestMailingState';
      cont.Title = 'TestTitle';
      cont.MobilePhone = '1234321';
      cont.Email = 'Test@test.com';
      cont.Department = 'TestDepartment';
      insert cont;
      nc.SmartViscaf__contact__c = cont.Id;
    }

    if (needLead) {
      Lead lea = new Lead();
      lea.LastName = 'TestLast';
      lea.FirstName = 'TestFirst';
      lea.Company = 'TestCompany';
      lea.NameCard__c = nc.Id;
      lea.Email = 'Test@test.com';
      lea.MobilePhone = '123321';
      lea.Title = 'TestTitle';
      lea.State = 'TestState';
      insert lea;
      nc.SmartViscaf__lead__c = lea.Id;
    }
    update nc;
  }

  /**
    * @description 連携マッピング用データー作成するメソッド
  **/
  private static void setMappingDate() {
    SmartViscaf__NameCardBasicSetting__c setting = new SmartViscaf__NameCardBasicSetting__c();
    setting.Name = 'BasicSetting';
    setting.SmartViscaf__RenkeiContactFirstName__c = false;
    setting.SmartViscaf__RenkeiContactLastName__c = false;
    setting.SmartViscaf__RenkeiAccountCompany__c = false;
    setting.SmartViscaf__RenkeiContactMail__c = false;
    setting.SmartViscaf__RenkeiAccountSite__c = false;
    setting.SmartViscaf__RenkeiAccountZipCode__c = false;
    setting.SmartViscaf__RenkeiSpecificItems__c = 'Name';
    setting.SmartViscaf__RenkeiAccountRecordTypes__c  = '123;321';
    setting.SmartViscaf__RenkeiAccountAddressPref__c = false;
    setting.SmartViscaf__RenkeiAccountQueryRecordTypeIds__c = '123;01228000000vWgqAAE';
    setting.SmartViscaf__RenkeiContactQueryRecordTypeIds__c = '01228000000w0mBAAQ;01228000000vWgqAAE';
    setting.SmartViscaf__RenkeiAccountCity__c = false;
    setting.SmartViscaf__RenkeiAccountOverwrite__c = true;
    setting.SmartViscaf__RenkeiAccountNOExistCreateNew__c = true;
    setting.SmartViscaf__RenkeiAccountRecordTypes__c = '01228000000vWgqAAE';
    setting.SmartViscaf__RegistDispAccountRectype__c = true; // 取引先・取引先任者に登録 取引先レコードタイプ選択を表示する
    setting.SmartViscaf__RegistAccountNotOverWrite__c = false; // 取引先・取引先任者に登録 取引先を名刺情報で上書きしない
    setting.SmartViscaf__RegistDispContactRectype__c = true; // 取引先・取引先任者に登録 取引先責任者レコードタイプ選択を表示する
    setting.SmartViscaf__RegistContactNotOverWrite__c = false; // 取引先・取引先任者に登録 取引先責任者を名刺情報で上書きしない
    setting.SmartViscaf__RenkeiAccountNOExistCreateNew__c = true;  //既存の取引先がなければ新規作成する
    setting.SmartViscaf__RenkeiContactNOExistCreateNew__c = true;  // 既存の取引先責任者がなければ新規作成する
    insert setting;

    String objname = 'SmartViscaf__NameCardRenkeiMapping__c';
    List<RecordType> res = [SELECT Id,Name,Developername FROM RecordType WHERE SobjectType = :objname AND Developername ='Lead'];
    System.debug('resresres' + res);
    List<SmartViscaf__NameCardRenkeiMapping__c> testmapplist = new List<SmartViscaf__NameCardRenkeiMapping__c>();
    SmartViscaf__NameCardRenkeiMapping__c amap = new SmartViscaf__NameCardRenkeiMapping__c();
    amap.SmartViscaf__IsActive__c = true;
    amap.SmartViscaf__TargetName__c = 'Company';
    amap.SmartViscaf__NameCardName__c = 'SmartViscaf__company_name__c';
    amap.SmartViscaf__BasicSetting__c = setting.Id;
    if(res.size()>0){
        amap.RecordTypeId = res[0].Id;
    }
    testmapplist.add(amap);

    SmartViscaf__NameCardRenkeiMapping__c cmap = new SmartViscaf__NameCardRenkeiMapping__c();
    cmap.SmartViscaf__IsActive__c = true;
    cmap.SmartViscaf__TargetName__c = 'LastName';
    cmap.SmartViscaf__NameCardName__c = 'SmartViscaf__person_name_last__c';
    if(res.size()>1){
        cmap.RecordTypeId = res[0].Id;
    }
    testmapplist.add(cmap);
    cmap.SmartViscaf__BasicSetting__c = setting.Id;


    insert testmapplist;
  }

  /**
    * @description ChangeOwnerメソッドのテストメソッド
  **/
  static testMethod void testChangeOwner() {
    List<User> us = insertUser();
    System.runAs(us[0]) {
      setData(true, true, true, true, true);
      List<SmartViscaf__NameCard__c> cards = [SELECT Id,
                                                     SmartViscaf__company_name__c,
                                                     SmartViscaf__person_name_last__c
                                                FROM SmartViscaf__NameCard__c];
      System.assertEquals(1, cards.size());
      List<Account> acc = [SELECT Id
                             FROM Account];
      System.assertEquals(1, acc.size());
      List<Contact> con = [SELECT Id
                          FROM Contact];
      System.assertEquals(1, con.size());
      List<Lead> lea = [SELECT Id
                          FROM Lead];
      System.assertEquals(1, lea.size());
      PageReference pageRef = Page.SB_NameCardL_TwowayRegist;
      pageRef.getParameters().put('lookUpContactIndex', '2');
      Test.setCurrentPage(pageRef);
      ApexPages.StandardController sc = new ApexPages.StandardController(cards[0]);
      SB_NameCardL_TwowayRegistController ctrl = new SB_NameCardL_TwowayRegistController(sc);
      ctrl.registTodo = true;
      ctrl.canEditTodo = false;
      ctrl.changeOwner();
      System.assertEquals(false, ctrl.registTodo);
      ctrl.registTodo = true;
      ctrl.canEditTodo = true;
      ctrl.changeOwner();
      System.assertEquals(true, ctrl.registTodo);
    }
  }

  /**
    * @description cancelメソッドのテストメソッド
  **/
  static testMethod void testCnacel() {
    List<User> us = insertUser();
    System.runAs(us[0]) {
      setData(true, true, true, true, true);
      List<SmartViscaf__NameCard__c> cards = [SELECT Id,
                                                     SmartViscaf__company_name__c,
                                                     SmartViscaf__person_name_last__c
                                                FROM SmartViscaf__NameCard__c];
      System.assertEquals(1, cards.size());
      List<Account> acc = [SELECT Id
                             FROM Account];
      System.assertEquals(1, acc.size());
      List<Contact> con = [SELECT Id
                          FROM Contact];
      System.assertEquals(1, con.size());
      List<Lead> lea = [SELECT Id
                          FROM Lead];
      System.assertEquals(1, lea.size());
      PageReference pageRef = Page.SB_NameCardL_TwowayRegist;
      Test.setCurrentPage(pageRef);
      ApexPages.StandardController sc = new ApexPages.StandardController(cards[0]);
      SB_NameCardL_TwowayRegistController ctrl = new SB_NameCardL_TwowayRegistController(sc);
      System.assertEquals((new ApexPages.StandardController(cards[0])).view().getUrl(), ctrl.cancel().getUrl());
    }
  }

  /**
    * @description LeadCandidate innerclassに関するテストメソッド
  **/
  static testMethod void testLeadCandidate() {
    List<User> us = insertUser();
    System.runAs(us[0]) {
      setData(true, true, true, true, true);
      List<SmartViscaf__NameCard__c> cards = [SELECT Id,
                                                     SmartViscaf__company_name__c,
                                                     SmartViscaf__person_name_last__c
                                                FROM SmartViscaf__NameCard__c];
      System.assertEquals(1, cards.size());
      List<Account> acc = [SELECT Id
                             FROM Account];
      System.assertEquals(1, acc.size());
      List<Contact> con = [SELECT Id
                          FROM Contact];
      System.assertEquals(1, con.size());
      List<Lead> lea = [SELECT Id, Name
                          FROM Lead];
      System.assertEquals(1, lea.size());
      PageReference pageRef = Page.SB_NameCardL_TwowayRegist;
      Test.setCurrentPage(pageRef);
      ApexPages.StandardController sc = new ApexPages.StandardController(cards[0]);
      SB_NameCardL_TwowayRegistController ctrl = new SB_NameCardL_TwowayRegistController(sc);
      System.assertEquals(3, ctrl.leadRecordList.size());
      ctrl.lookUpIndex = 0;
      SB_NameCardL_TwowayRegistController.LeadCandidate leadRec = (SB_NameCardL_TwowayRegistController.LeadCandidate)ctrl.leadRecordList.get(ctrl.lookUpIndex);
      System.assertEquals(lea[0].Name, leadRec.getLeadName());
      System.assertEquals(lea[0].Id, leadRec.getLeadId());
      System.assertEquals('Testingtest', leadRec.getLeadOwnerName());
      System.assertEquals('TestTitle', leadRec.getTitle());
      System.assertEquals('123321', leadRec.getMobile());
      System.assertEquals('test@test.com', leadRec.getEmail());
      System.assertNotEquals(null, leadRec.getLastModifiedDate());
      System.assertEquals('TestCompany', leadRec.getLeadCompany());
      System.assertEquals(us[0].Id, leadRec.getLeadOwnerId());
      System.assertEquals('TestState', leadRec.getState());
      leadRec.adopt(cards[0]);
    }
  }

  /**
    * @description LeadLookupCandidate innerclassに関するテストメソッド
  **/
  static testMethod void testLeadLookupCandidate() {
    List<User> us = insertUser();
    System.runAs(us[0]) {
      setData(true, true, true, true, true);
      List<SmartViscaf__NameCard__c> cards = [SELECT Id,
                                                     SmartViscaf__company_name__c,
                                                     SmartViscaf__person_name_last__c
                                                FROM SmartViscaf__NameCard__c];
      System.assertEquals(1, cards.size());
      List<Account> acc = [SELECT Id
                             FROM Account];
      System.assertEquals(1, acc.size());
      List<Contact> con = [SELECT Id
                          FROM Contact];
      System.assertEquals(1, con.size());
      List<Lead> lea = [SELECT Id, Name
                          FROM Lead];
      System.assertEquals(1, lea.size());
      PageReference pageRef = Page.SB_NameCardL_TwowayRegist;
      Test.setCurrentPage(pageRef);
      ApexPages.StandardController sc = new ApexPages.StandardController(cards[0]);
      SB_NameCardL_TwowayRegistController ctrl = new SB_NameCardL_TwowayRegistController(sc);
      System.assertEquals(3, ctrl.leadRecordList.size());
      ctrl.lookUpIndex = 1;
      SB_NameCardL_TwowayRegistController.LeadLookupCandidate leadRec = (SB_NameCardL_TwowayRegistController.LeadLookupCandidate)ctrl.leadRecordList.get(ctrl.lookUpIndex);
      leadRec.card4Lookup.SmartViscaf__lead__c = lea[0].Id;
      System.assertEquals(null, leadRec.getLeadCompany());
      System.assertEquals(null, leadRec.getLeadOwnerId());
      System.assertEquals(null, leadRec.getLastModifiedDate());
      System.assertEquals(null, leadRec.getEmail());
      System.assertEquals(null, leadRec.getMobile());
      System.assertEquals(null, leadRec.getTitle());
      System.assertEquals(null, leadRec.getLeadOwnerName());
      System.assertEquals(null, leadRec.getLeadId());
      System.assertEquals(null, leadRec.getLeadName());
      ctrl.setLookUp();
      System.assertEquals('TestCompany', leadRec.getLeadCompany());
      System.assertEquals(us[0].Id, leadRec.getLeadOwnerId());
      System.assertNotEquals(null, leadRec.getLastModifiedDate());
      System.assertEquals('test@test.com', leadRec.getEmail());
      System.assertEquals('123321', leadRec.getMobile());
      System.assertEquals('TestTitle', leadRec.getTitle());
      System.assertEquals('Testingtest', leadRec.getLeadOwnerName());
      System.assertEquals(lea[0].Id, leadRec.getLeadId());
      System.assertEquals(lea[0].Name, leadRec.getLeadName());
      leadRec.adopt(cards[0]);
      leadRec.postLookup();
    }
  }

  /**
    * @description NewLeadCandidate innerclassに関するテストメソッド
  **/
  static testMethod void testNewLeadCandidate() {
    List<User> us = insertUser();
    System.runAs(us[0]) {
      setData(true, true, true, true, true);
      List<SmartViscaf__NameCard__c> cards = [SELECT Id,
                                                     SmartViscaf__company_name__c,
                                                     SmartViscaf__person_name_last__c,
                                                     SmartViscaf__person_name_first__c
                                                FROM SmartViscaf__NameCard__c];
      System.assertEquals(1, cards.size());
      List<Account> acc = [SELECT Id
                             FROM Account];
      System.assertEquals(1, acc.size());
      List<Contact> con = [SELECT Id
                          FROM Contact];
      System.assertEquals(1, con.size());
      List<Lead> lea = [SELECT Id, Name
                          FROM Lead];
      System.assertEquals(1, lea.size());
      PageReference pageRef = Page.SB_NameCardL_TwowayRegist;
      Test.setCurrentPage(pageRef);
      ApexPages.StandardController sc = new ApexPages.StandardController(cards[0]);
      SB_NameCardL_TwowayRegistController ctrl = new SB_NameCardL_TwowayRegistController(sc);
      System.assertEquals(3, ctrl.leadRecordList.size());
      ctrl.lookUpIndex = 2;
      SB_NameCardL_TwowayRegistController.NewLeadCandidate leadRec = (SB_NameCardL_TwowayRegistController.NewLeadCandidate)ctrl.leadRecordList.get(ctrl.lookUpIndex);
      System.assertEquals(String.format(System.Label.SB_NCLD_Label_CreateNewLeadDEV, new String[]{ Account.sObjectType.getDescribe().getLabel() }), leadRec.getAccountName());
      System.assertEquals(String.format(System.Label.SB_NCLD_Label_CreateNewLeadDEV, new String[]{ Contact.sObjectType.getDescribe().getLabel() }), leadRec.getContactName());
      System.assertEquals(String.format(System.Label.SB_NCLD_Label_CreateNewLeadDEV, new String[]{ Lead.sObjectType.getDescribe().getLabel() }), leadRec.getLeadName());
      leadRec.adopt(cards[0]);
    }
  }

  /**
    * @description ContactCandidate innerclassに関するテストメソッド
  **/
  static testMethod void testContactCandidate() {
    List<User> us = insertUser();
    System.runAs(us[0]) {
      setData(true, true, true, true, true);
      List<SmartViscaf__NameCard__c> cards = [SELECT Id,
                                                     SmartViscaf__division__c,
                                                     SmartViscaf__company_name__c,
                                                     SmartViscaf__person_name_last__c,
                                                     SmartViscaf__person_name_first__c
                                                FROM SmartViscaf__NameCard__c];
      System.assertEquals(1, cards.size());
      List<Account> acc = [SELECT Id
                             FROM Account];
      System.assertEquals(1, acc.size());
      List<Contact> con = [SELECT Id,
                                  Name
                          FROM Contact];
      System.assertEquals(1, con.size());
      List<Lead> lea = [SELECT Id, Name
                          FROM Lead];
      System.assertEquals(1, lea.size());
      PageReference pageRef = Page.SB_NameCardL_TwowayRegist;
      Test.setCurrentPage(pageRef);
      ApexPages.StandardController sc = new ApexPages.StandardController(cards[0]);
      SB_NameCardL_TwowayRegistController ctrl = new SB_NameCardL_TwowayRegistController(sc);
      System.assertEquals(5, ctrl.candidateTable.size());
      SB_NameCardL_TwowayRegistController.ContactCandidate contachRec = (SB_NameCardL_TwowayRegistController.ContactCandidate)ctrl.candidateTable.get(0);

      System.assertEquals('TestCompany', contachRec.getAccountName());
      System.assertEquals(acc[0].Id, contachRec.getAccountId());
      System.assertEquals(con[0].Name, contachRec.getContactName());
      System.assertEquals(con[0].Id, contachRec.getContactId());
      System.assertEquals('Testingtest', contachRec.getAccountOwnerName());
      System.assertEquals('Testingtest', contachRec.getContactOwnerName());
      System.assertEquals(us[0].Id, contachRec.getAccountOwnerId());
      System.assertEquals(us[0].Id, contachRec.getContactOwnerId());
      System.assertEquals('TestDepartment', contachRec.getDivision());
      System.assertEquals('TestMailingState', contachRec.getState());
      System.assertEquals('TestTitle', contachRec.getTitle());
      System.assertEquals('1234321', contachRec.getMobile());
      System.assertEquals('test@test.com', contachRec.getEmail());
      System.assertNotEquals(null, contachRec.getLastModifiedDate());
      contachRec.adopt(cards[0]);
    }
  }

  /**
    * @description AccountCandidate innerclassに関するテストメソッド
  **/
  static testMethod void testAccountCandidate() {
    List<User> us = insertUser();
    System.runAs(us[0]) {
      setData(true, true, true, true, true);
      List<SmartViscaf__NameCard__c> cards = [SELECT Id,
                                                     SmartViscaf__division__c,
                                                     SmartViscaf__company_name__c,
                                                     SmartViscaf__person_name_last__c,
                                                     SmartViscaf__person_name_first__c
                                                FROM SmartViscaf__NameCard__c];
      System.assertEquals(1, cards.size());
      List<Account> acc = [SELECT Id
                             FROM Account];
      System.assertEquals(1, acc.size());
      List<Contact> con = [SELECT Id
                          FROM Contact];
      System.assertEquals(1, con.size());
      List<Lead> lea = [SELECT Id, Name
                          FROM Lead];
      System.assertEquals(1, lea.size());
      PageReference pageRef = Page.SB_NameCardL_TwowayRegist;
      Test.setCurrentPage(pageRef);
      ApexPages.StandardController sc = new ApexPages.StandardController(cards[0]);
      SB_NameCardL_TwowayRegistController ctrl = new SB_NameCardL_TwowayRegistController(sc);
      System.assertEquals(5, ctrl.candidateTable.size());
      SB_NameCardL_TwowayRegistController.AccountCandidate contachRec = (SB_NameCardL_TwowayRegistController.AccountCandidate)ctrl.candidateTable.get(1);

      System.assertEquals('TestCompany', contachRec.getAccountName());
      System.assertEquals(acc[0].Id, contachRec.getAccountId());
      System.assertEquals(String.format(System.Label.SB_NCLD_Label_CreateNewLeadDEV, new String[]{ Contact.sObjectType.getDescribe().getLabel() }), contachRec.getContactName());
      System.assertEquals('Testingtest', contachRec.getAccountOwnerName());
      System.assertEquals('TestSite', contachRec.getDivision());
      System.assertEquals('TestBillingState', contachRec.getState());
      System.assertNotEquals(null, contachRec.getLastModifiedDate());
      System.assertEquals(us[0].Id, contachRec.getAccountOwnerId());
      contachRec.adopt(cards[0]);
    }
  }

  /**
    * @description 取引先責任者参照テスト
  **/
  static testMethod void testContactSetLookup() {
    List<User> us = insertUser();
    System.runAs(us[0]) {
      setData(true, true, true, true, true);
      List<SmartViscaf__NameCard__c> cards = [SELECT Id,
                                                     SmartViscaf__company_name__c,
                                                     SmartViscaf__person_name_last__c
                                                FROM SmartViscaf__NameCard__c];
      System.assertEquals(1, cards.size());
      List<Account> acc = [SELECT Id
                             FROM Account];
      System.assertEquals(1, acc.size());
      List<Contact> con = [SELECT Id
                          FROM Contact];
      System.assertEquals(1, con.size());
      List<Lead> lea = [SELECT Id, Name
                          FROM Lead];
      System.assertEquals(1, lea.size());
      PageReference pageRef = Page.SB_NameCardL_TwowayRegist;
      Test.setCurrentPage(pageRef);
      ApexPages.StandardController sc = new ApexPages.StandardController(cards[0]);
      SB_NameCardL_TwowayRegistController ctrl = new SB_NameCardL_TwowayRegistController(sc);
      System.assertEquals(3, ctrl.leadRecordList.size());
      pageRef.getParameters().put('lookUpContactIndex', '2');
      SB_NameCardL_TwowayRegistController.ContactLookupCandidate contachRec = (SB_NameCardL_TwowayRegistController.ContactLookupCandidate)ctrl.candidateTable.get(2);
      contachRec.card4Lookup.SmartViscaf__contact__c = con[0].Id;
      System.assertEquals(null, contachRec.getAccountName());
      System.assertEquals(null, contachRec.getAccountOwnerName());
      System.assertEquals(null, contachRec.getLastModifiedDate());
      System.assertEquals(null, contachRec.getAccountOwnerId());
      System.assertEquals(null, contachRec.getContactOwnerId());
      ctrl.postLookupContact();
      System.assertEquals('TestCompany', contachRec.getAccountName());
      System.assertEquals('Testingtest', contachRec.getAccountOwnerName());
      System.assertNotEquals(null, contachRec.getLastModifiedDate());
      System.assertEquals(us[0].Id, contachRec.getAccountOwnerId());
      System.assertEquals(us[0].Id, contachRec.getContactOwnerId());
      contachRec.adopt(cards[0]);
    }
  }

  /**
    * @description AccountLookupCandidate innerclassに関するテストメソッド
  **/
  static testMethod void testAccountLookupCandidate() {
    List<User> us = insertUser();
    System.runAs(us[0]) {
      setData(true, true, true, true, true);
      List<SmartViscaf__NameCard__c> cards = [SELECT Id,
                                                     SmartViscaf__division__c,
                                                     SmartViscaf__company_name__c,
                                                     SmartViscaf__person_name_last__c,
                                                     SmartViscaf__person_name_first__c
                                                FROM SmartViscaf__NameCard__c];
      System.assertEquals(1, cards.size());
      List<Account> acc = [SELECT Id
                             FROM Account];
      System.assertEquals(1, acc.size());
      List<Contact> con = [SELECT Id
                          FROM Contact];
      System.assertEquals(1, con.size());
      List<Lead> lea = [SELECT Id, Name
                          FROM Lead];
      System.assertEquals(1, lea.size());
      PageReference pageRef = Page.SB_NameCardL_TwowayRegist;
      Test.setCurrentPage(pageRef);
      ApexPages.StandardController sc = new ApexPages.StandardController(cards[0]);
      SB_NameCardL_TwowayRegistController ctrl = new SB_NameCardL_TwowayRegistController(sc);
      System.assertEquals(5, ctrl.candidateTable.size());
      SB_NameCardL_TwowayRegistController.AccountLookupCandidate contachRec = (SB_NameCardL_TwowayRegistController.AccountLookupCandidate)ctrl.candidateTable.get(3);
      contachRec.card4Lookup.SmartViscaf__account__c = acc[0].Id;

      System.assertEquals(null, contachRec.getDivision());
      System.assertEquals(null, contachRec.getState());
      System.assertEquals(String.format(System.Label.SB_NCLD_Label_CreateNewLeadDEV, new String[]{ Contact.sObjectType.getDescribe().getLabel() }), contachRec.getContactName());
      System.assertEquals(null, contachRec.getAccountOwnerId());
      contachRec.postLookup();

      System.assertEquals('TestSite', contachRec.getDivision());
      System.assertEquals('TestBillingState', contachRec.getState());
      System.assertEquals(String.format(System.Label.SB_NCLD_Label_CreateNewLeadDEV, new String[]{ Contact.sObjectType.getDescribe().getLabel() }), contachRec.getContactName());
      System.assertEquals(us[0].Id, contachRec.getAccountOwnerId());
      contachRec.adopt(cards[0]);
    }
  }

  /**
    * @description NewAccountCandidate innerclassに関するテストメソッド
  **/
  static testMethod void testNewAccountCandidate() {
    List<User> us = insertUser();
    System.runAs(us[0]) {
      setData(true, true, true, true, true);
      List<SmartViscaf__NameCard__c> cards = [SELECT Id,
                                                     SmartViscaf__division__c,
                                                     SmartViscaf__company_name__c,
                                                     SmartViscaf__person_name_last__c,
                                                     SmartViscaf__person_name_first__c
                                                FROM SmartViscaf__NameCard__c];
      System.assertEquals(1, cards.size());
      List<Account> acc = [SELECT Id
                             FROM Account];
      System.assertEquals(1, acc.size());
      List<Contact> con = [SELECT Id
                          FROM Contact];
      System.assertEquals(1, con.size());
      List<Lead> lea = [SELECT Id, Name
                          FROM Lead];
      System.assertEquals(1, lea.size());
      PageReference pageRef = Page.SB_NameCardL_TwowayRegist;
      Test.setCurrentPage(pageRef);
      ApexPages.StandardController sc = new ApexPages.StandardController(cards[0]);
      SB_NameCardL_TwowayRegistController ctrl = new SB_NameCardL_TwowayRegistController(sc);
      System.assertEquals(5, ctrl.candidateTable.size());
      SB_NameCardL_TwowayRegistController.NewAccountCandidate contachRec = (SB_NameCardL_TwowayRegistController.NewAccountCandidate)ctrl.candidateTable.get(4);
      System.assertEquals(String.format(System.Label.SB_NCLD_Label_CreateNewLeadDEV, new String[]{ Account.sObjectType.getDescribe().getLabel() }), contachRec.getAccountName());
      System.assertEquals(String.format(System.Label.SB_NCLD_Label_CreateNewLeadDEV, new String[]{ Contact.sObjectType.getDescribe().getLabel() }), contachRec.getContactName());
      contachRec.adopt(cards[0]);
    }
  }

  /**
    * @description 
  **/
  static testMethod void testCheckRadio() {
    List<User> us = insertUser();
    System.runAs(us[0]) {
      setData(true, true, true, true, true);
      List<SmartViscaf__NameCard__c> cards = [SELECT Id,
                                                     SmartViscaf__company_name__c,
                                                     SmartViscaf__person_name_last__c
                                                FROM SmartViscaf__NameCard__c];
      System.assertEquals(1, cards.size());
      List<Account> acc = [SELECT Id
                             FROM Account];
      System.assertEquals(1, acc.size());
      List<Contact> con = [SELECT Id
                          FROM Contact];
      System.assertEquals(1, con.size());
      List<Lead> lea = [SELECT Id
                          FROM Lead];
      System.assertEquals(1, lea.size());
      PageReference pageRef = Page.SB_NameCardL_TwowayRegist;
      Test.setCurrentPage(pageRef);
      ApexPages.StandardController sc = new ApexPages.StandardController(cards[0]);
      SB_NameCardL_TwowayRegistController ctrl = new SB_NameCardL_TwowayRegistController(sc);
      List<RecordTypeInfo> LEADRECORDTYPES = SB_NameCardL_TwowayRegistController.getRecordType(Lead.sObjectType);
      ctrl.leadRecordListIndex = 0;
      ctrl.checkRadio();
      System.assertEquals(false, ctrl.leadRecTypeEdit);
      ctrl.leadRecordListIndex = ctrl.leadRecordList.size() - 1;
      ctrl.checkRadio();
      System.assertEquals(true, ctrl.leadRecTypeEdit);
    }
  }

  static testMethod void testMethod1() {
    List<User> us = insertUser();
    System.runAs(us[0]) {
      setData(true, true, true, true, true);
      List<SmartViscaf__NameCard__c> cards = [SELECT Id,
                                                     SmartViscaf__company_name__c,
                                                     SmartViscaf__person_name_last__c
                                                FROM SmartViscaf__NameCard__c];
      System.assertEquals(1, cards.size());
      List<Account> acc = [SELECT Id
                             FROM Account];
      System.assertEquals(1, acc.size());
      List<Contact> con = [SELECT Id
                          FROM Contact];
      System.assertEquals(1, con.size());
      List<Lead> lea = [SELECT Id
                          FROM Lead];
      System.assertEquals(1, lea.size());
      PageReference pageRef = Page.SB_NameCardL_TwowayRegist;
      Test.setCurrentPage(pageRef);
      ApexPages.StandardController sc = new ApexPages.StandardController(cards[0]);
      SB_NameCardL_TwowayRegistController ctrl = new SB_NameCardL_TwowayRegistController(sc);
      SB_NameCardL_TwowayRegistController.getRenkeiTypeList();
      SB_NameCardL_TwowayRegistController.getSearchTypeList();
      System.assertEquals(3, ctrl.leadRecordList.size());
      System.assertEquals(5, ctrl.candidateTable.size());
      ctrl.leadRecordListIndex = 0;
      ctrl.accountTableIndex = 0;
      ctrl.candidateTable[2].card4Lookup.SmartViscaf__contact__c = con[0].Id;
      ctrl.getSearchTypeSelectOpts();
      ctrl.getleadRecordTypeOptions();
      ctrl.getContRecTypeSelectOpts();
      ctrl.getAccRecTypeSelectOpts();
      ctrl.changeCampaign();
      ctrl.saveRenkei();
      for (SB_NameCardL_TwowayRegistController.CandidateRecord record : ctrl.candidateTable) {

      }
      System.assertEquals(null, ctrl.testError);
    }
  }

  static testMethod void testMethod2() {
    List<User> us = insertUser();
    System.runAs(us[0]) {
      setData(true, true, true, true, true);
      List<SmartViscaf__NameCard__c> cards = [SELECT Id,
                                                     SmartViscaf__company_name__c,
                                                     SmartViscaf__person_name_last__c
                                                FROM SmartViscaf__NameCard__c];
      System.assertEquals(1, cards.size());
      List<Account> acc = [SELECT Id
                             FROM Account];
      System.assertEquals(1, acc.size());
      List<Contact> con = [SELECT Id
                          FROM Contact];
      System.assertEquals(1, con.size());
      List<Lead> lea = [SELECT Id
                          FROM Lead];
      System.assertEquals(1, lea.size());
      PageReference pageRef = Page.SB_NameCardL_TwowayRegist;
      Test.setCurrentPage(pageRef);
      ApexPages.StandardController sc = new ApexPages.StandardController(cards[0]);
      SB_NameCardL_TwowayRegistController ctrl = new SB_NameCardL_TwowayRegistController(sc);
      SB_NameCardL_TwowayRegistController.getRenkeiTypeList();
      SB_NameCardL_TwowayRegistController.getSearchTypeList();
      System.assertEquals(3, ctrl.leadRecordList.size());
      System.assertEquals(5, ctrl.candidateTable.size());
      ctrl.leadRecordListIndex = 0;
      ctrl.accountTableIndex = 0;
      ctrl.candidateTable[2].card4Lookup.SmartViscaf__contact__c = con[0].Id;
      ctrl.getSearchTypeSelectOpts();
      ctrl.getleadRecordTypeOptions();
      ctrl.getContRecTypeSelectOpts();
      ctrl.getAccRecTypeSelectOpts();
      ctrl.changeCampaign();
      ctrl.renkeiType = 'Lead';
      ctrl.saveRenkei();
      for (SB_NameCardL_TwowayRegistController.CandidateRecord record : ctrl.candidateTable) {

      }
      System.assertEquals(null, ctrl.testError);
    }
  }
}