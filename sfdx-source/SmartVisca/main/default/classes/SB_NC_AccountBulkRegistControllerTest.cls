/*
 * SB_NC_AccountBulkRegistController
 * LEX 取引先・取引先責任者一括登録画面 コントローラのテストクラス
 *
 * (c) 2019 Sunbridge Inc.
 *
 *  @author K.Yoshida
 *  @Version 2.2  2019.02.XX SV_DEV-1558 LEX 取引先登録 一括画面をLXパッケージ同様のLC化で追加
 */
@isTest
public class SB_NC_AccountBulkRegistControllerTest {
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

    list<PermissionSet> psList = [SELECT Id FROM PermissionSet WHERE Name IN ('SmartViscaAdminUser','SmartViscaAdvancedUser','SmartViscaRenkeiUser','SmartViscaUser')];
    PermissionSetAssignment psa1 = new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = psList[0].Id);
    PermissionSetAssignment psa2 = new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = psList[1].Id);
    PermissionSetAssignment psa3 = new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = psList[2].Id);
    PermissionSetAssignment psa4 = new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = psList[3].Id);
    insert new PermissionSetAssignment[]{psa1,psa2,psa3,psa4};

    us.add(u);
    us.add(u1);
    return us;
  }


  private static void setData(Boolean needNameCard, Boolean needAccount, Boolean needContact) {
    NameCard__c nc = new NameCard__c();
    nc.zip_code__c = '150-0022';
    nc.address_pref__c = '東京都';
    nc.address__c = '渋谷区恵比寿南';
    nc.company_name__c = 'TestCompany';
    nc.tel1__c = '03-1111-1111';
    nc.fax1__c = '03-1111-1112';
    nc.title_name__c = 'TestTitle';
    nc.person_name_last__c = 'TestLast';
    nc.person_name_first__c = 'TestFirst';

    //nc.email__c = 'test@sbnc.example.com';
    nc.mobile__c = '090-1111-1111';
    nc.card_exchange_date__c = Date.today();

    Database.DMLOptions dml = new Database.DMLOptions();

    dml.OptAllOrNone = false;
    Database.SaveResult sr1 = SB_NameCard_CrudFls.screate(new List<NameCard__c>{nc},dml)[0];
    System.assertEquals(0, sr1.getErrors().size(), 'savenamecard error');

    Account a ;
    if (needAccount) {
      a = new Account(Name = 'TestCompany');
      a.NameCard__c = nc.Id;
      insert a;
      nc.account__c = a.Id;
    }

    if (needContact) {
      Contact cont = new Contact();
      if (a != null) {
        cont.AccountId = a.Id;
      }
      cont.LastName = 'TestLast';
      cont.FirstName = 'TestFirst';
      cont.NameCard__c = nc.Id;
      insert cont;
      nc.contact__c = cont.Id;
    }
    update nc;
  }
  // LEX で リストビューから 取引先一括登録画面を開く
  @isTest
  static void test_SB_NC_AccountBulkRegistController_LEX() {
    List<User> us = insertUser();
    System.runAs(us[0]) {
      setData(true, true, true);
      List<SObject> objs = Database.query('SELECT Id, Name FROM NameCard__c LIMIT 10');
      System.assert(objs.isEmpty()==false);
      ApexPages.StandardSetController stdSetCtrl = new ApexPages.StandardSetController(objs);
      stdSetCtrl.setSelected(objs);
      SB_NC_AccountBulkRegistController ctrl1 = new SB_NC_AccountBulkRegistController(stdSetCtrl);
      System.assertNotEquals(null, ctrl1.targetIds);
    }
  }
}