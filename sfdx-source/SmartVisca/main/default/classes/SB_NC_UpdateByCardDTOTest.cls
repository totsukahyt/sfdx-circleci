/**
 *
 * SB_NC_UpdateByCardDTOTest 名刺で更新コンポネート使用するためのBeanクラス のテストクラス
 *
 * Copyright (C) 2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author gao
 *  @Version 基本パッケージ： 2.1(1.23)       2018.11.XX 初版
 *
 **/

@isTest
private class SB_NC_UpdateByCardDTOTest {

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

    System.debug('SB_NameCard_LeadRegistTest nc.Id: '+nc.Id);
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
  }
  static testMethod void testMethod1() {
    List<User> us = insertUser();
    System.runAs(us[0]) {
      List<SB_NC_UpdateByCardDTO.DataTableColumnField> fieldList = new List<SB_NC_UpdateByCardDTO.DataTableColumnField>();
      fieldList.add(new SB_NC_UpdateByCardDTO.DataTableColumnField('名刺ID',
                                                                        'Id',
                                                                        'Text'));
      fieldList.add(new SB_NC_UpdateByCardDTO.DataTableColumnField('名刺名',
                                                                        'Name',
                                                                        'Text'));
      SB_NC_UpdateByCardDTO.DataTableColumnField field = new SB_NC_UpdateByCardDTO.DataTableColumnField('会社名',
                                                                        'company_name__c',
                                                                        'Text');

      SB_NC_UpdateByCardDTO.Action ac = new SB_NC_UpdateByCardDTO.Action();
      SB_NC_UpdateByCardDTO.Action ac1 = new SB_NC_UpdateByCardDTO.Action('TestLabel', 'TestValue');
      field.setActon(new List<SB_NC_UpdateByCardDTO.Action>{ac});
      field.setURLLabel('TestUrl');
      field.settypeAttributes(new Map<String, Map<String, String>>{
                                                                    'label' => new Map<String, String>{
                                                                                                      'fieldName' => 'company_name__c'}});
      fieldList.add(field);

      SB_NC_UpdateByCardDTO.Button btn = new SB_NC_UpdateByCardDTO.Button();
      SB_NC_UpdateByCardDTO.Button btn1 = new SB_NC_UpdateByCardDTO.Button('TestLabel', 'TestValue', 'TestTitle', 'nameValue', 'iconNameValue', 'iconPositionValue', 'variantValue', false);

      SB_NC_UpdateByCardDTO.LabelValue lv = new SB_NC_UpdateByCardDTO.LabelValue();
      SB_NC_UpdateByCardDTO.LabelValue lv1 = new SB_NC_UpdateByCardDTO.LabelValue('TestLabel', 'TestValue');

      SB_NC_UpdateByCardDTO.InputValue inputV = new SB_NC_UpdateByCardDTO.InputValue();

      SB_NC_UpdateByCardDTO dto = new SB_NC_UpdateByCardDTO();
      dto.fieldList = fieldList;
      setData(true, true, true);
      List<NameCard__c> cards = [SELECT Id,
                                                       Name,
                                                       OwnerId,
                                                       company_name__c,
                                                       person_name_last__c
                                                  FROM NameCard__c];
      System.assertEquals(1, cards.size());
      List<Account> acs = [SELECT Id
                               FROM Account];
      System.assertEquals(1, acs.size());

      List<Contact> cos = [SELECT Id
                             FROM Contact];
      System.assertEquals(1, cos.size());
    }
  }
}