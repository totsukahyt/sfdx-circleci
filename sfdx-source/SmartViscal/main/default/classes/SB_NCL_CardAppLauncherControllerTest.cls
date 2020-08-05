/*
 * (c) 2018 Sunbridge Inc.
 *
 * LEX名刺で更新Launcherコントローラ テストクラス
 * @author mao
 * @Version 拡張パッケージ：Lead Ex. 1.12 2018/08/XX
 *
 */
@isTest
private class SB_NCL_CardAppLauncherControllerTest {
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

    list<PermissionSet> psList = [SELECT Id FROM PermissionSet WHERE Name IN ('SmartViscaAdminUser','SmartViscaAdvancedUser','SmartViscaRenkeiUser','SmartViscaUser','SmartViscaLeadAdminUser')];
    PermissionSetAssignment psa1 = new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = psList[0].Id);
    PermissionSetAssignment psa2 = new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = psList[1].Id);
    PermissionSetAssignment psa3 = new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = psList[2].Id);
    PermissionSetAssignment psa4 = new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = psList[3].Id);
    PermissionSetAssignment psa5 = new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = psList[4].Id);
    insert new PermissionSetAssignment[]{psa1,psa2,psa3,psa4,psa5};

    us.add(u);
    us.add(u1);
    return us;
  }

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
      insert lea;
      nc.SmartViscaf__lead__c = lea.Id;
    }
    update nc;
  }

  @isTest
  static void test_SB_NCL_CardAppLauncher_ComponentName() {
    List<User> us = insertUser();
    System.runAs(us[0]) {
      setData(true, false, false, false, false);
      List<SmartViscaf__NameCard__c> cards = [SELECT Id,
                                                     SmartViscaf__company_name__c,
                                                     SmartViscaf__person_name_last__c
                                                FROM SmartViscaf__NameCard__c];
      System.assertEquals(1, cards.size());
      PageReference pageRef = Page.SB_NCL_CardAppLauncher;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put('id', cards[0].Id);
      ApexPages.currentPage().getParameters().put('app', 'updbycard');
      SB_NCL_CardAppLauncherController ctrl = new SB_NCL_CardAppLauncherController();
      String lccmp = SB_NCL_CardAppLauncherController.APPCD_COMPONENT.get('updbycard');
      System.assertEquals(lccmp, ctrl.component);
    }
  }
}