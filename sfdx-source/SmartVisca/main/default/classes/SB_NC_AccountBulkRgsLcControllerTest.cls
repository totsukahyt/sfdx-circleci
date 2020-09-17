/*
 * SB_NC_AccountBulkRgsLcControllerTest
 * LEX 取引先・取引先責任者一括登録画面 コントローラ SB_NC_AccountBulkRgsLcControllerのテストクラス
 *
 * (c) 2019 Sunbridge Inc.
 *
 *  @author K.Yoshida
 *  @Version 2.2  2019.02.XX SV_DEV-1558 LEX 取引先登録 一括画面をLXパッケージ同様のLC化で追加
 *  @Version 2.7  2020.09.08 ohno   PRODUCT-696 取引先登録 個別・一括 メールアドレスが空白値で一致して登録先候補が表示されてしまう。（姓・名が異なるレコードが表示される）
 */

@isTest
private class SB_NC_AccountBulkRgsLcControllerTest {
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
  /**
    * @description データー作成用のメソッド
  **/
  private static void setData(Boolean needNameCard, Boolean needAccount, Boolean needContact) {
    NameCard__c nc = new NameCard__c();
    nc.zip_code__c = '150-0022';
    // nc.address_pref__c = '東京都';
    // nc.address__c = '渋谷区恵比寿南';
    nc.company_name__c = 'TestCompany';
    // nc.tel1__c = '03-1111-1111';
    // nc.fax1__c = '03-1111-1112';
    // nc.title_name__c = 'TestTitle';
    nc.person_name_last__c = 'TestLast';
    nc.person_name_first__c = 'TestFirst';
    nc.email__c = 'Test@test.com';

    //nc.email__c = 'test@sbnc.example.com';
    // nc.mobile__c = '090-1111-1111';
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
      // a.Site = 'TestTitle';
      // a.BillingState = 'TestBillingState';
      insert a;
      nc.account__c = a.Id;
    }
    // 名刺と一致する名称の取引先責任者（名刺と参照関係あり）
    if (needContact) {
      Contact cont = new Contact();
      if (a != null) {
        cont.AccountId = a.Id;
      }
      cont.LastName = 'TestLast';
      cont.FirstName = 'TestFirst';
      cont.NameCard__c = nc.Id;
      cont.MailingState = 'TestMailingState';
      cont.Title = 'TestTitle';
      cont.MobilePhone = '1234321';
      cont.Email = 'Test@test.com';
      cont.Department = 'TestDepartment';
      insert cont;
      nc.contact__c = cont.Id;
    }

    update nc;
  }

  /**
    * @description 連携マッピング用データー作成するメソッド
  **/
  private static void setMappingDate() {
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    setting.Name = 'BasicSetting';
    setting.RenkeiContactFirstName__c = false;
    setting.RenkeiContactLastName__c = false;
    setting.RenkeiAccountCompany__c = false;
    setting.RenkeiContactMail__c = false;
    setting.RenkeiAccountSite__c = false;
    setting.RenkeiAccountZipCode__c = false;
    setting.RenkeiSpecificItems__c = 'Name';
    setting.RenkeiAccountRecordTypes__c  = '123;321';
    setting.RenkeiAccountAddressPref__c = false;
    setting.RenkeiAccountQueryRecordTypeIds__c = '123;01228000000vWgqAAE';
    setting.RenkeiContactQueryRecordTypeIds__c = '01228000000w0mBAAQ;01228000000vWgqAAE';
    setting.RenkeiAccountCity__c = false;
    setting.RenkeiAccountOverwrite__c = true;
    setting.RenkeiAccountNOExistCreateNew__c = true;
    setting.RenkeiAccountRecordTypes__c = '01228000000vWgqAAE';
    setting.RegistDispAccountRectype__c = true; // 取引先・取引先任者に登録 取引先レコードタイプ選択を表示する
    setting.RegistAccountNotOverWrite__c = false; // 取引先・取引先任者に登録 取引先を名刺情報で上書きしない
    setting.RegistDispContactRectype__c = true; // 取引先・取引先任者に登録 取引先責任者レコードタイプ選択を表示する
    setting.RegistContactNotOverWrite__c = false; // 取引先・取引先任者に登録 取引先責任者を名刺情報で上書きしない
    setting.RenkeiAccountNOExistCreateNew__c = true;  //既存の取引先がなければ新規作成する
    setting.RenkeiContactNOExistCreateNew__c = true;  // 既存の取引先責任者がなければ新規作成する
    setting = SB_NameCard_BasicSetting.getNameCardBasicSetting();
    insert setting;
    System.assertEquals(true, String.isNotBlank(setting.Id));
    String objname = SB_NameCard_RenkeiMapperUtil.getManagedObjectName('NameCardRenkeiMapping__c');
    List<RecordType> res = [SELECT Id,Name,Developername FROM RecordType WHERE SobjectType = :objname ORDER BY Developername];
    //System.assertEquals('Lead2', res[2].Developername);
    System.assertEquals('Contact', res[1].Developername);
    System.assertEquals('Account', res[0].Developername);
    System.debug('resresres' + res);
    List<NameCardRenkeiMapping__c> testmapplist = new List<NameCardRenkeiMapping__c>();
    // NameCardRenkeiMapping__c lmap = new NameCardRenkeiMapping__c();
    // lmap.IsActive__c = true;
    // lmap.TargetName__c = 'Company';
    // lmap.NameCardName__c = 'company_name__c';
    // lmap.BasicSetting__c = setting.Id;
    // lmap.RecordTypeId = res[2].Id; // Lead
    // testmapplist.add(lmap);

    // lmap = new NameCardRenkeiMapping__c();
    // lmap.IsActive__c = true;
    // lmap.TargetName__c = 'LastName';
    // lmap.NameCardName__c = 'person_name_last__c';
    // lmap.BasicSetting__c = setting.Id;
    // lmap.RecordTypeId = res[2].Id; // Lead
    // testmapplist.add(lmap);

    NameCardRenkeiMapping__c cmap = new NameCardRenkeiMapping__c();
    cmap.IsActive__c = true;
    cmap.TargetName__c = 'LastName';
    cmap.NameCardName__c = 'person_name_last__c';
    cmap.RecordTypeId = res[1].Id; // Contact
    cmap.BasicSetting__c = setting.Id;
    testmapplist.add(cmap);

    NameCardRenkeiMapping__c amap = new NameCardRenkeiMapping__c();
    amap.IsActive__c = true;
    amap.TargetName__c = 'Name';
    amap.NameCardName__c = 'company_name__c';
    amap.RecordTypeId = res[0].Id; // Account
    amap.BasicSetting__c = setting.Id;
    testmapplist.add(amap);


    insert testmapplist;
  }

  /**
    * @description Searchメソッドのテストメソッド
  **/
  /*
  static testMethod void testSearchBoth() {
    List<User> us = insertUser();
    System.runAs(us[0]) {
      setData(true, true, true);
      List<NameCard__c> cards = [SELECT Id,
                                                     company_name__c,
                                                     person_name_last__c
                                                FROM NameCard__c];
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
      SB_NC_AccountBulkRgsLcController.getTitleValue();
      SB_NC_AccountBulkRgsLcController.getFieldList();
      SB_NC_AccountBulkRgsLcController.getInputValue();

      String data = SB_NC_AccountBulkRgsLcController.searchAllLead(cards[0].Id, '2', '3', null);
      Map<String, Object> dto = (Map<String, Object>)System.JSON.deserializeUntyped(data);
      System.assertEquals('', dto.get('message'));
      System.assertEquals(true, dto.get('success'));
      System.assertEquals('', dto.get('message'));
      Map<Id, Map<String, SB_NC_AccountBulkRegistDTO.InputPickListValue>> inputPickListVMap = (Map<Id, Map<String, SB_NC_AccountBulkRegistDTO.InputPickListValue>>)System.JSON.deserializeStrict(JSON.serialize(dto.get('data')), Map<Id, Map<String, SB_NC_AccountBulkRegistDTO.InputPickListValue>> .Class);
      System.assertEquals(1, inputPickListVMap.keySet().size());
      System.assertEquals(true, inputPickListVMap.containskey(cards[0].Id));
      Map<String, SB_NC_AccountBulkRegistDTO.InputPickListValue> inputPickListMap = inputPickListVMap.get(cards[0].Id);
      System.assertEquals(true, inputPickListMap.containskey('Lead'));
      System.assertEquals(true, inputPickListMap.containskey('Contact'));
      SB_NC_AccountBulkRegistDTO.InputPickListValue plickListLead = inputPickListMap.get('Lead');
      SB_NC_AccountBulkRegistDTO.InputPickListValue plickListContact = inputPickListMap.get('Contact');
      System.debug(plickListContact.plickListOptions);
      String message = plickListContact.plickListOptions[0].Label;
      message += plickListContact.plickListOptions[1].Label;
      message += plickListContact.plickListOptions[2].Label;
      System.assertEquals(4, plickListContact.plickListOptions.size());
      System.assertEquals(3, plickListLead.plickListOptions.size());
    }
  }
  */

  /**
    * @description キャンペーンメンバー状況クエリするメソッドのテストメソッド
  **/
  /*
  static testMethod void testSearchCampaignMemberStatus() {
    List<User> us = insertUser();
    System.runAs(us[0]) {
      setData(true, true, true);
      List<NameCard__c> cards = [SELECT Id,
                                                     company_name__c,
                                                     person_name_last__c
                                                FROM NameCard__c];
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
      SB_NC_AccountBulkRegistDTO.InputPickListValue campaignStatus = (SB_NC_AccountBulkRegistDTO.InputPickListValue)System.JSON.deserializeStrict(data, SB_NC_AccountBulkRegistDTO.InputPickListValue .Class);
      System.assertEquals(3, campaignStatus.plickListOptions.size());
    }
  }
  */

  /**
    * @description 検索関するするのテストメソッド
  **/
  static testMethod void testSearch() {
    List<User> us = insertUser();
    System.runAs(us[0]) {
      setData(true, true, true);
      List<NameCard__c> cards = [SELECT Id,
                                                     company_name__c,
                                                     person_name_last__c
                                                FROM NameCard__c];
      System.assertEquals(1, cards.size());
      List<Account> acc = [SELECT Id
                             FROM Account];
      System.assertEquals(1, acc.size());
      List<Contact> con = [SELECT Id
                          FROM Contact];
      System.assertEquals(1, con.size());
      String data = SB_NC_AccountBulkRgsLcController.getAllData(cards[0].Id, null, null, null, null, null);
      Map<String, Object> dtoMap = (Map<String, Object>)System.JSON.deserializeUntyped(data);
      System.assertEquals(true, dtoMap.get('success'));
      System.assertEquals('', dtoMap.get('message'));
      List<SB_NC_AccountBulkRegistDTO.CustomObject> dto = (List<SB_NC_AccountBulkRegistDTO.CustomObject>)System.JSON.deserializeStrict(JSON.serialize(dtoMap.get('data')), List<SB_NC_AccountBulkRegistDTO.CustomObject> .Class);
      System.assertEquals(1, dto.size());
      System.assertEquals(cards[0].Id, dto[0].id);
    }
  }

  /**
    * @description データー作成用のメソッド
    * Emailが空白＆名刺と名前の異なる取引先責任者を用意し、名前が一致したもののみ取得できること。
  **/
  private static void setDataEmailBlank(Boolean needNameCard, Boolean needAccount, Boolean needContact) {
    NameCard__c nc = new NameCard__c();
    nc.zip_code__c = '150-0022';
    // nc.address_pref__c = '東京都';
    // nc.address__c = '渋谷区恵比寿南';
    nc.company_name__c = 'TestCompany';
    // nc.tel1__c = '03-1111-1111';
    // nc.fax1__c = '03-1111-1112';
    // nc.title_name__c = 'TestTitle';
    nc.person_name_last__c = 'TestLast';
    nc.person_name_first__c = 'TestFirst';
    nc.email__c = null;

    //nc.email__c = 'test@sbnc.example.com';
    // nc.mobile__c = '090-1111-1111';
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
      // a.Site = 'TestTitle';
      // a.BillingState = 'TestBillingState';
      insert a;
      nc.account__c = a.Id;
    }
    // 名刺と一致する名称の取引先責任者（名刺と参照関係なし）
    if (needContact) {
      Contact cont = new Contact();
      if (a != null) {
        cont.AccountId = a.Id;
      }
      cont.LastName = 'TestLast';
      cont.FirstName = 'TestFirst';
      cont.MailingState = 'TestMailingState';
      cont.Title = 'TestTitle';
      cont.MobilePhone = '1234321';
      cont.Email = null;
      cont.Department = 'TestDepartment';
      insert cont;
    }
    // 名刺と一致しない名称の取引先責任者（名刺と参照関係なし）
    if (needContact) {
      Contact cont = new Contact();
      if (a != null) {
        cont.AccountId = a.Id;
      }
      cont.LastName = '名称不一致';
      cont.FirstName = '名称不一致';
      cont.MailingState = 'TestMailingState';
      cont.Title = 'TestTitle';
      cont.MobilePhone = '1234321';
      cont.Email = null;
      cont.Department = 'TestDepartment';
      insert cont;
    }

    update nc;
  }

  /**
    * @description 検索関するするのテストメソッド。メールアドレスが空白の場合
    * Emailが空白＆名刺と名前の異なる取引先責任者を用意し、名前が一致したもののみ取得できること。
    * PRODUCT-696 取引先登録 個別・一括 メールアドレスが空白値で一致して登録先候補が表示されてしまう。（姓・名が異なるレコードが表示される）
  **/
  static testMethod void testSearchEmptyEmail() {
    List<User> us = insertUser();
    System.runAs(us[0]) {
      setDataEmailBlank(true, true, true);
      List<NameCard__c> cards = [SELECT Id,
                                                     company_name__c,
                                                     person_name_last__c
                                                FROM NameCard__c];
      System.assertEquals(1, cards.size());
      List<Account> acc = [SELECT Id
                             FROM Account];
      System.assertEquals(1, acc.size());
      List<Contact> con = [SELECT Id
                          FROM Contact];
      System.assertEquals(2, con.size());

      Test.startTest();
      String data = SB_NC_AccountBulkRgsLcController.getAllData(cards[0].Id, null, null, null, null, null);
      Test.stopTest();

      Map<String, Object> dtoMap = (Map<String, Object>)System.JSON.deserializeUntyped(data);
      System.assertEquals(true, dtoMap.get('success'));
      System.assertEquals('', dtoMap.get('message'));
      List<SB_NC_AccountBulkRegistDTO.CustomObject> dto = (List<SB_NC_AccountBulkRegistDTO.CustomObject>)System.JSON.deserializeStrict(JSON.serialize(dtoMap.get('data')), List<SB_NC_AccountBulkRegistDTO.CustomObject> .Class);
      System.assertEquals(1, dto.size());
      System.assertEquals(cards[0].Id, dto[0].id);
      SB_NC_AccountBulkRegistDTO.InputPickListValue pick = dto[0].combobox.values()[0];
      for (SB_NC_AccountBulkRegistDTO.LabelValue labelV: pick.pickListOptions) {
        System.debug(labelV);
        System.assert(!labelV.label.contains('名称不一致'), '名称が一致しない取引先責任者が取得されています');
      }
      System.assertEquals(3 + 1, pick.pickListOptions.size(), 'リストの取得件数が4件(none1件 + 新規取引先1件 + 既存取引先/新規取責１件 + 既存取引先責任者１件)ではありません');
    }
  }


  /**
    * @description 取引先新規保存のテストメソッド
  **/
  static testMethod void testSaveAccount() {
    List<User> us = insertUser();
    System.runAs(us[0]) {
      setData(true, true, true);
      setMappingDate();
      List<NameCardBasicSetting__c> settings = [SELECT Id
                                                               FROM NameCardBasicSetting__c];
      System.assertEquals(1, settings.size());
      System.assertEquals(SB_NameCard_BasicSetting.getNameCardBasicSetting().Id, settings[0].Id);
      

      List<NameCardRenkeiMapping__c> mappings = [SELECT Id
                                                                FROM NameCardRenkeiMapping__c];
      // System.assertEquals(4, mappings.size());
      System.assertEquals(2, mappings.size());
      List<NameCard__c> cards = [SELECT Id,
                                                     company_name__c,
                                                     person_name_last__c
                                                FROM NameCard__c];
      System.assertEquals(1, cards.size());
      System.assertEquals('TestCompany', cards[0].company_name__c);
      List<Account> acc = [SELECT Id
                             FROM Account];
      System.assertEquals(1, acc.size());
      List<Contact> con = [SELECT Id
                          FROM Contact];
      System.assertEquals(1, con.size());
      String data = SB_NC_AccountBulkRgsLcController.getAllData(cards[0].Id, null, null, null, null, null);
      Map<String, Object> dtoMap = (Map<String, Object>)System.JSON.deserializeUntyped(data);
      System.assertEquals(true, dtoMap.get('success'));
      System.assertEquals('', dtoMap.get('message'));
      List<SB_NC_AccountBulkRegistDTO.CustomObject> dto = (List<SB_NC_AccountBulkRegistDTO.CustomObject>)System.JSON.deserializeStrict(JSON.serialize(dtoMap.get('data')), List<SB_NC_AccountBulkRegistDTO.CustomObject> .Class);
      System.assertEquals(1, dto.size());
      //dto[0].cObjectMap.get('Lead').value = 'none';
      dto[0].cObjectMap.get('Contact').value = 'new';
      System.assertEquals(cards[0].Id, dto[0].id);
      SB_NC_AccountBulkRegistDTO.InputValue inputValue = (SB_NC_AccountBulkRegistDTO.InputValue)System.JSON.deserializeStrict(SB_NC_AccountBulkRgsLcController.getInputValue(), SB_NC_AccountBulkRegistDTO.InputValue  .Class);
      inputValue.useNameCardOwner = true;
      inputValue.useNameCardAccountOwner = true;
      
    }
  }

  /**
    * @description 取引先保存のテストメソッド
  **/
  static testMethod void testSaveContact() {
    List<User> us = insertUser();
    System.runAs(us[0]) {
      setData(true, true, true);
      setMappingDate();
      List<NameCardBasicSetting__c> settings = [SELECT Id
                                                               FROM NameCardBasicSetting__c];
      System.assertEquals(1, settings.size());
      System.assertEquals(SB_NameCard_BasicSetting.getNameCardBasicSetting().Id, settings[0].Id);
      

      List<NameCardRenkeiMapping__c> mappings = [SELECT Id
                                                                FROM NameCardRenkeiMapping__c];
      // System.assertEquals(4, mappings.size());
      System.assertEquals(2, mappings.size());
      List<NameCard__c> cards = [SELECT Id,
                                                     company_name__c,
                                                     person_name_last__c
                                                FROM NameCard__c];
      System.assertEquals(1, cards.size());
      System.assertEquals('TestCompany', cards[0].company_name__c);
      List<Account> acc = [SELECT Id
                             FROM Account];
      System.assertEquals(1, acc.size());
      List<Contact> con = [SELECT Id
                          FROM Contact];
      System.assertEquals(1, con.size());
      String data = SB_NC_AccountBulkRgsLcController.getAllData(cards[0].Id, null, null, null, null, null);
      Map<String, Object> dtoMap = (Map<String, Object>)System.JSON.deserializeUntyped(data);
      System.assertEquals(true, dtoMap.get('success'));
      System.assertEquals('', dtoMap.get('message'));
      List<SB_NC_AccountBulkRegistDTO.CustomObject> dto = (List<SB_NC_AccountBulkRegistDTO.CustomObject>)System.JSON.deserializeStrict(JSON.serialize(dtoMap.get('data')), List<SB_NC_AccountBulkRegistDTO.CustomObject> .Class);
      System.assertEquals(1, dto.size());
      //dto[0].cObjectMap.get('Lead').value = 'new';
      dto[0].cObjectMap.get('Contact').value = 'none';
      System.assertEquals(cards[0].Id, dto[0].id);
      SB_NC_AccountBulkRegistDTO.InputValue inputValue = (SB_NC_AccountBulkRegistDTO.InputValue)System.JSON.deserializeStrict(SB_NC_AccountBulkRgsLcController.getInputValue(), SB_NC_AccountBulkRegistDTO.InputValue  .Class);
      inputValue.useNameCardOwner = true;
      inputValue.useNameCardAccountOwner = true;
    }
  }
}