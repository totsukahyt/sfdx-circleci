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

       Test.startTest();

       Database.DMLOptions dml = new Database.DMLOptions();

       dml.OptAllOrNone = false;

       Database.SaveResult sr =  SB_NameCard_LeadCrudFls.supdate(new List<SObject>{new Account()},dml)[0];

       System.assertNotEquals(0,sr.getErrors().size(), 'NameCard error');

       Test.stopTest();
   }

    private static testMethod void test2()
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
                Database.DMLOptions dml = new Database.DMLOptions();

                dml.OptAllOrNone = false;

                Database.SaveResult sr = SB_NameCard_LeadCrudFls.screate(new List<SObject>{nc},dml)[0];

                System.assertEquals(null, sr.getErrors().size(), 'NameCard error');
            }catch(Exception e)
            {  }
        }

    }


    private static testMethod void test3()
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
                Database.DMLOptions dml = new Database.DMLOptions();

                dml.OptAllOrNone = false;

                Database.SaveResult sr = SB_NameCard_LeadCrudFls.supdate(new List<SObject>{nc},dml)[0];

                System.assertEquals(0, sr.getErrors().size(), 'NameCard error');
            }
            catch(Exception e)
            {  }
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

    private static void insertLead(SmartViscaf__NameCard__c nc)
    {
        Lead lead = SB_NameCard_LeadRegist.getLead(null, nc, null);

        Database.DMLOptions dml = new Database.DMLOptions();

        dml.OptAllOrNone = false;

        List<Lead> leads = new List<Lead>();

        leads.add(lead);

        Database.SaveResult sr = SB_NameCard_LeadCrudFls.screate(leads,dml)[0];

        System.assertEquals(0, sr.getErrors().size(), 'NameCard error');

        System.debug('SB_NameCard_LeadRegistTest lead.Id: '+lead.Id);
    }

    private static SmartViscaf__NameCard__c getNameCard(String company)
    {
        System.assertNotEquals(null, company, 'company error');
        SmartViscaf__NameCard__c card = [SELECT Id, SmartViscaf__zip_code__c, SmartViscaf__address_pref__c, SmartViscaf__address__c,

        SmartViscaf__address_bld__c, SmartViscaf__address_eng__c, SmartViscaf__company_name__c, SmartViscaf__web_url1__c,
        SmartViscaf__tel1__c, SmartViscaf__fax1__c, SmartViscaf__title_name__c, SmartViscaf__person_name_last__c,
        SmartViscaf__person_name_first__c, SmartViscaf__last_name__c, SmartViscaf__first_name__c, SmartViscaf__email__c,
        SmartViscaf__mobile__c, SmartViscaf__list_name__c, SmartViscaf__memo__c, SmartViscaf__freehandmemo__c, OwnerId
        FROM SmartViscaf__NameCard__c WHERE SmartViscaf__company_name__c = :company];
        System.assertNotEquals(null, card, 'getNameCard error');
        return card;
    }

    private static SmartViscaf__NameCard__c getNameCard(Id ncId)
    {
        System.assertNotEquals(null, ncId, 'ncId error');
        SmartViscaf__NameCard__c card = [SELECT Id, SmartViscaf__lead__c FROM SmartViscaf__NameCard__c WHERE Id = :ncId];
        System.assertNotEquals(null, card, 'getNameCard error');
        return card;
    }

    private static Lead getLead(Id ncId)
    {
        System.assertNotEquals(null, ncId, 'ncId error');
        Lead lead = [SELECT Id FROM Lead WHERE NameCard__c = :ncId];
        System.assertNotEquals(null, lead, 'getLead error');
        return lead;
    }
}