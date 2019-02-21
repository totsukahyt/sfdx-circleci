@isTest
private class SB_NCL_LeadBulkRegistLcControllerTest {
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
    setting = SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting();
    insert setting;
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

  /**
    * @description Searchメソッドのテストメソッド
  **/
  static testMethod void testSearch0() {
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
      SB_NCL_LeadBulkRegistLcController.getTitleValue();
      SB_NCL_LeadBulkRegistLcController.getFieldList();
      SB_NCL_LeadBulkRegistLcController.getInputValue();

      String data = SB_NCL_LeadBulkRegistLcController.searchAllLead(cards[0].Id, '2', null);
      Map<String, Object> dto = (Map<String, Object>)System.JSON.deserializeUntyped(data);
      System.assertEquals(true, dto.get('success'));
      System.assertEquals('', dto.get('message'));
      Map<Id, Map<String, SB_NameCardL_BulkRegistDTO.InputPlickListValue>> inputPlickListVMap = (Map<Id, Map<String, SB_NameCardL_BulkRegistDTO.InputPlickListValue>>)System.JSON.deserializeStrict(JSON.serialize(dto.get('data')), Map<Id, Map<String, SB_NameCardL_BulkRegistDTO.InputPlickListValue>> .Class);
      System.assertEquals(1, inputPlickListVMap.keySet().size());
      System.assertEquals(true, inputPlickListVMap.containskey(cards[0].Id));
      Map<String, SB_NameCardL_BulkRegistDTO.InputPlickListValue> inputPlickListMap = inputPlickListVMap.get(cards[0].Id);
      System.assertEquals(true, inputPlickListMap.containskey('Lead'));
      SB_NameCardL_BulkRegistDTO.InputPlickListValue plickListLead = inputPlickListMap.get('Lead');
      System.assertEquals(3, plickListLead.plickListOptions.size());
    }
  }

  /**
    * @description キャンペーンメンバー状況クエリするメソッドのテストメソッド
  **/
  static testMethod void testSearchCampaignMemberStatus() {
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

      //名刺に関するデータを作成

      List<Campaign> cm = [Select Id,Name From Campaign];
      System.assertNotEquals(cm.size(),0);
      //キャンペーンメンバー状況レコードを作成
      List<CampaignMemberStatus> cpmsa = [SELECT id, CampaignID, HasResponded, IsDefault, Label, SortOrder
                                      FROM CampaignMemberStatus Where CampaignId = :cm];
      CampaignMemberStatus newStatus = new CampaignMemberStatus(CampaignID=cm[0].id, Label='New', IsDefault=true, HasResponded=false, SortOrder=3);
      CampaignMemberStatus newStatus1 = new CampaignMemberStatus(CampaignID=cm[0].id, Label='New1', IsDefault=false, HasResponded=false, SortOrder=4);
      CampaignMemberStatus newStatus2 = new CampaignMemberStatus(CampaignID=cm[0].id, Label='New2', IsDefault=false, HasResponded=false, SortOrder=5);
      insert new CampaignMemberStatus[]{newStatus, newStatus1, newStatus2};
      String data = SB_NCL_LeadBulkRegistLcController.getCampaignStatus(cm[0].Id);
      SB_NameCardL_BulkRegistDTO.InputPlickListValue campaignStatus = (SB_NameCardL_BulkRegistDTO.InputPlickListValue)System.JSON.deserializeStrict(data, SB_NameCardL_BulkRegistDTO.InputPlickListValue .Class);
      System.assertEquals(3, campaignStatus.plickListOptions.size());
    }
  }

  /**
    * @description 検索関するするのテストメソッド
  **/
  static testMethod void testSearch() {
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
      String data = SB_NCL_LeadBulkRegistLcController.getAllData(cards[0].Id, null, null, null);
      Map<String, Object> dtoMap = (Map<String, Object>)System.JSON.deserializeUntyped(data);
      System.assertEquals(true, dtoMap.get('success'));
      System.assertEquals('', dtoMap.get('message'));
      List<SB_NameCardL_BulkRegistDTO.CustomObject> dto = (List<SB_NameCardL_BulkRegistDTO.CustomObject>)System.JSON.deserializeStrict(JSON.serialize(dtoMap.get('data')), List<SB_NameCardL_BulkRegistDTO.CustomObject> .Class);
      System.assertEquals(1, dto.size());
      System.assertEquals(cards[0].Id, dto[0].id);
    }
  }

  /**
    * @description 検索関するするのテストメソッド
  **/
  static testMethod void testSave() {
    List<User> us = insertUser();
    System.runAs(us[0]) {
      setMappingDate();
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
      String data = SB_NCL_LeadBulkRegistLcController.getAllData(cards[0].Id, null, null, null);
      Map<String, Object> dtoMap = (Map<String, Object>)System.JSON.deserializeUntyped(data);
      System.assertEquals(true, dtoMap.get('success'));
      System.assertEquals('', dtoMap.get('message'));
      List<SB_NameCardL_BulkRegistDTO.CustomObject> dto = (List<SB_NameCardL_BulkRegistDTO.CustomObject>)System.JSON.deserializeStrict(JSON.serialize(dtoMap.get('data')), List<SB_NameCardL_BulkRegistDTO.CustomObject> .Class);
      System.assertEquals(1, dto.size());
      dto[0].cObjectMap.get('Lead').value = 'new';
      System.assertEquals(cards[0].Id, dto[0].id);
      SB_NameCardL_BulkRegistDTO.InputValue inputValue = (SB_NameCardL_BulkRegistDTO.InputValue)System.JSON.deserializeStrict(SB_NCL_TwowayBulkRgsLcController.getInputValue(), SB_NameCardL_BulkRegistDTO.InputValue  .Class);
      inputValue.useNameCardOwner = true;
      String saveDate = SB_NCL_LeadBulkRegistLcController.saveLead(Json.serialize(dto), null, true, null, null, true, null);
      Map<String, Object> saver = (Map<String, Object>)System.JSON.deserializeUntyped(saveDate);
      System.assertEquals('', saver.get('errorMessage'));
      System.assertEquals(true, saver.get('success'));
      
    }
  }
}