@isTest
private class SB_NCL_UpdateByCardDTOTest {

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
  static testMethod void testMethod1() {
    List<User> us = insertUser();
    System.runAs(us[0]) {
      List<SB_NCL_UpdateByCardDTO.DataTableColumnField> fieldList = new List<SB_NCL_UpdateByCardDTO.DataTableColumnField>();
      fieldList.add(new SB_NCL_UpdateByCardDTO.DataTableColumnField('名刺ID',
                                                                        'Id',
                                                                        'Text'));
      fieldList.add(new SB_NCL_UpdateByCardDTO.DataTableColumnField('名刺名',
                                                                        'Name',
                                                                        'Text'));
      SB_NCL_UpdateByCardDTO.DataTableColumnField field = new SB_NCL_UpdateByCardDTO.DataTableColumnField('会社名',
                                                                        'SmartViscaf__company_name__c',
                                                                        'Text');

      SB_NCL_UpdateByCardDTO.Action ac = new SB_NCL_UpdateByCardDTO.Action();
      SB_NCL_UpdateByCardDTO.Action ac1 = new SB_NCL_UpdateByCardDTO.Action('TestLabel', 'TestValue');
      field.setActon(new List<SB_NCL_UpdateByCardDTO.Action>{ac});
      field.setURLLabel('TestUrl');
      field.settypeAttributes(new Map<String, Map<String, String>>{
                                                                    'label' => new Map<String, String>{
                                                                                                      'fieldName' => 'SmartViscaf__company_name__c'}});
      fieldList.add(field);

      SB_NCL_UpdateByCardDTO.Button btn = new SB_NCL_UpdateByCardDTO.Button();
      SB_NCL_UpdateByCardDTO.Button btn1 = new SB_NCL_UpdateByCardDTO.Button('TestLabel', 'TestValue', 'TestTitle', 'nameValue', 'iconNameValue', 'iconPositionValue', 'variantValue', false);

      SB_NCL_UpdateByCardDTO.LabelValue lv = new SB_NCL_UpdateByCardDTO.LabelValue();
      SB_NCL_UpdateByCardDTO.LabelValue lv1 = new SB_NCL_UpdateByCardDTO.LabelValue('TestLabel', 'TestValue');

      SB_NCL_UpdateByCardDTO.InputValue inputV = new SB_NCL_UpdateByCardDTO.InputValue();

      SB_NCL_UpdateByCardDTO dto = new SB_NCL_UpdateByCardDTO();
      dto.fieldList = fieldList;
      setData(true, true, true, true, true);
      List<SmartViscaf__NameCard__c> cards = [SELECT Id,
                                                       Name,
                                                       OwnerId,
                                                       SmartViscaf__company_name__c,
                                                       SmartViscaf__person_name_last__c
                                                  FROM SmartViscaf__NameCard__c];
      System.assertEquals(1, cards.size());
      List<Account> acs = [SELECT Id
                               FROM Account];
      System.assertEquals(1, acs.size());

      List<Contact> cos = [SELECT Id
                             FROM Contact];
      System.assertEquals(1, cos.size());

      List<Lead> leas = [SELECT Id
                             FROM Lead];
      System.assertEquals(1, leas.size());
    }
  }
}