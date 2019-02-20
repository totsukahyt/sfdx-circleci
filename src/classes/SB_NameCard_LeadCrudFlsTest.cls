/*
 * (c) 2015 Sunbridge Inc.
 *
 * リードに登録
 * リードを更新
 * テスト
 */

@isTest private class SB_NameCard_LeadCrudFlsTest
{
    @isTest private static void test1()
    {
        insertNameCard();
        SmartViscaf__NameCard__c nc = getNameCard('TestCompany');
        System.debug('SB_NameCard_LeadRegistTest nc.Id: '+nc.Id);

        Test.startTest();
        Account acc = new Account();
        List<SObject> objets = new List<SObject>();
        objets.add(acc);
        SB_NameCard_LeadCrudFls.screate(objets);
        Test.stopTest();
    }

    @isTest private static void test2()
    {
  
        Test.startTest();

        SB_NameCard_LeadCrudFls.supdate(new List<SObject>{new Account()});

        Test.stopTest();
    }
    

    @isTest private static void test3()
    {


        Test.startTest();
    SB_NameCard_LeadCrudFls.isCreateable('Account');
    SB_NameCard_LeadCrudFls.isCreateableError('Account');
    SB_NameCard_LeadCrudFls.isUpdateable('Account');
    SB_NameCard_LeadCrudFls.isUpdateableError('Account');


        Test.stopTest();
    }
    
          private static testMethod void test6()
    {
     Profile prof;
        try{
       prof = [SELECT Id, UserType, Name FROM Profile WHERE Name = 'Read Only'];
        }catch(Exception e){
         prof = [SELECT Id, UserType, Name FROM Profile WHERE Name = '参照のみ'];
     }
   User u = new User(); 
   // u.Name = 'mydtest@mydexample.com';
  User u2 = new User(Alias = 'test', Email='newusertest@testorgtest.com',

         EmailEncodingKey='UTF-8', LastName='Testingtest', LanguageLocaleKey='en_US',

         LocaleSidKey='en_US', ProfileId = prof.Id,

         TimeZoneSidKey='America/Los_Angeles', UserName='newusertesttest@testorgtest.com');
        	insertNameCard();
		SmartViscaf__NameCard__c nc = getNameCard('TestCompany');
    System.runAs(u2) {
        try{
           SB_NameCard_LeadCrudFls.screate(new List<SObject>{nc});
        }catch(Exception e)
        {}
         }
        
    }


      private static testMethod void test4()
    {
     Profile prof;
        try{
       prof = [SELECT Id, UserType, Name FROM Profile WHERE Name = 'Read Only'];
        }catch(Exception e){
         prof = [SELECT Id, UserType, Name FROM Profile WHERE Name = '参照のみ'];
     }
   User u = new User(); 
   // u.Name = 'mydtest@mydexample.com';
  User u2 = new User(Alias = 'test', Email='newusertest@testorgtest.com',

         EmailEncodingKey='UTF-8', LastName='Testingtest', LanguageLocaleKey='en_US',

         LocaleSidKey='en_US', ProfileId = prof.Id,

         TimeZoneSidKey='America/Los_Angeles', UserName='newusertest@testorgtest.com');
        	insertNameCard();
		SmartViscaf__NameCard__c nc = getNameCard('TestCompany');
    System.runAs(u2) {
        try{
           SB_NameCard_LeadCrudFls.supdate(new List<SObject>{nc});
        }catch(Exception e)
        {}
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
        Database.insert(nc);
        System.debug('SB_NameCard_LeadRegistTest nc.Id: '+nc.Id);
    }

    private static void insertLead(SmartViscaf__NameCard__c nc)
    {
        Lead lead = SB_NameCard_LeadRegist.getLead(null, nc, null);
        Database.insert(lead);
        System.debug('SB_NameCard_LeadRegistTest lead.Id: '+lead.Id);
    }

    private static SmartViscaf__NameCard__c getNameCard(String company)
    {
        return [SELECT Id, SmartViscaf__zip_code__c, SmartViscaf__address_pref__c, SmartViscaf__address__c,
            SmartViscaf__address_bld__c, SmartViscaf__address_eng__c, SmartViscaf__company_name__c, SmartViscaf__web_url1__c,
            SmartViscaf__tel1__c, SmartViscaf__fax1__c, SmartViscaf__title_name__c, SmartViscaf__person_name_last__c,
            SmartViscaf__person_name_first__c, SmartViscaf__last_name__c, SmartViscaf__first_name__c, SmartViscaf__email__c,
            SmartViscaf__mobile__c, SmartViscaf__list_name__c, SmartViscaf__memo__c, SmartViscaf__freehandmemo__c, OwnerId
            FROM SmartViscaf__NameCard__c WHERE SmartViscaf__company_name__c = :company];
    }

    private static SmartViscaf__NameCard__c getNameCard(Id ncId)
    {
        return [SELECT Id, SmartViscaf__lead__c FROM SmartViscaf__NameCard__c WHERE Id = :ncId];
    }

    private static Lead getLead(Id ncId)
    {
        return [SELECT Id FROM Lead WHERE NameCard__c = :ncId];
    }
}