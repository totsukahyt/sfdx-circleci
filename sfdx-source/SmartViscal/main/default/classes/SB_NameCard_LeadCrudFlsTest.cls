/*
 * SB_NameCard_LeadCrudFlsTest
 * (c) 2015 Sunbridge Inc.
 *
 * リードに登録
 * リードを更新
 * テスト
*/

@isTest private class SB_NameCard_LeadCrudFlsTest {
  @isTest private static void test1() {
    Test.startTest();
    Database.DMLOptions dml = new Database.DMLOptions();
    dml.OptAllOrNone = false;
    List<Database.SaveResult> srs =  SB_NameCard_LeadCrudFls.supdate(new List<SObject>{new Account()},dml);
    System.assertEquals(null, srs);
    // System.assertNotEquals(0,sr.getErrors().size(), 'NameCard error');
    Test.stopTest();
  }

  private static testMethod void test2() {
    Profile prof;
    try{
      prof = [SELECT Id, UserType, Name FROM Profile WHERE Name = 'Read Only'];
    }
    catch(Exception e){
      prof = [SELECT Id, UserType, Name FROM Profile WHERE Name = '参照のみ'];
    }
    User u = new User();
    // u.Name = 'mydtest@mydexample.com';
    User u2 = new User(Alias = 'test', Email='newusertest@testorgtest.com',
    EmailEncodingKey='UTF-8', LastName='Testingtest', LanguageLocaleKey='en_US',
    LocaleSidKey='en_US', ProfileId = prof.Id,
    TimeZoneSidKey='America/Los_Angeles', UserName='newusertesttest@testorgtest.com');
    insert u2;
    
    list<PermissionSet> psList = [SELECT Id FROM PermissionSet WHERE Name IN ('SmartViscaAdminUser','SmartViscaAdvancedUser','SmartViscaRenkeiUser','SmartViscaUser','SmartViscaLeadAdminUser')];
    PermissionSetAssignment psa1 = new PermissionSetAssignment(AssigneeId = u2.id, PermissionSetId = psList[0].Id);
    PermissionSetAssignment psa2 = new PermissionSetAssignment(AssigneeId = u2.id, PermissionSetId = psList[1].Id);
    PermissionSetAssignment psa3 = new PermissionSetAssignment(AssigneeId = u2.id, PermissionSetId = psList[2].Id);
    PermissionSetAssignment psa4 = new PermissionSetAssignment(AssigneeId = u2.id, PermissionSetId = psList[3].Id);
    PermissionSetAssignment psa5 = new PermissionSetAssignment(AssigneeId = u2.id, PermissionSetId = psList[4].Id);
    insert new PermissionSetAssignment[]{psa1,psa2,psa3,psa4,psa5};

    System.runAs(u2) {
      try{
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.OptAllOrNone = false;
        List<Database.SaveResult> srs = SB_NameCard_LeadCrudFls.screate(new List<SObject>{new SmartViscaf__NameCard__c()},dml);
        System.assertEquals(null, srs);
        // System.assertEquals(null, sr.getErrors().size(), 'NameCard error');
      }catch(Exception e) {
      }
    }
  }


    // private static testMethod void test3()
    // {
    //     Profile prof;
    //     try{

    //         prof = [SELECT Id, UserType, Name FROM Profile WHERE Name = 'Read Only'];

    //     }catch(Exception e){

    //         prof = [SELECT Id, UserType, Name FROM Profile WHERE Name = '参照のみ'];

    //     }

    //     User u = new User();
    //     // u.Name = 'mydtest@mydexample.com';
    //     User u2 = new User(Alias = 'test', Email='newusertest@testorgtest.com',

    //     EmailEncodingKey='UTF-8', LastName='Testingtest', LanguageLocaleKey='en_US',

    //     LocaleSidKey='en_US', ProfileId = prof.Id,


    //     TimeZoneSidKey='America/Los_Angeles', UserName='newusertest@testorgtest.com');

    //     insertNameCard();

    //     SmartViscaf__NameCard__c nc = getNameCard('TestCompany');

    //     System.runAs(u2) {

    //         try{
    //             Database.DMLOptions dml = new Database.DMLOptions();

    //             dml.OptAllOrNone = false;

    //             Database.SaveResult sr = SB_NameCard_LeadCrudFls.supdate(new List<SObject>{nc},dml)[0];

    //             System.assertEquals(0, sr.getErrors().size(), 'NameCard error');
    //         }
    //         catch(Exception e)
    //         {  }
    //     }

    // }
}