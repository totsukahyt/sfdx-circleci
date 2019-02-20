@isTest
private class SB_NCL_UpdateByCardLcControllerTest {
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

  // 名刺検索テスト
  static testMethod void testSearchNameCard() {
    List<User> us = insertUser();
    System.runAs(us[0]) {
      SB_NCL_UpdateByCardLcController.getFieldList();
      SB_NCL_UpdateByCardLcController.getInputValue();
      SB_NCL_UpdateByCardLcController.getFieldList();
      setData(true, false, false, true, false);
      List<SmartViscaf__NameCard__c> cards = [SELECT Id
                          FROM SmartViscaf__NameCard__c];
      System.assertEquals(1, cards.size());
      List<Lead> lea = [SELECT Id
                          FROM Lead];
      System.assertEquals(1, lea.size());
      String data = SB_NCL_UpdateByCardLcController.getUpdateByCard(lea[0].Id);
      SB_NCL_UpdateByCardDTO dto = (SB_NCL_UpdateByCardDTO)System.JSON.deserializeStrict(data, SB_NCL_UpdateByCardDTO .Class);
      System.assertEquals(1, dto.dataList.size());

    }
  }

  // 更新テスト
  static testMethod void testUpdate() {
    List<User> us = insertUser();
    System.runAs(us[0]) {
      SB_NCL_UpdateByCardLcController.getFieldList();
      SB_NCL_UpdateByCardLcController.getInputValue();
      SB_NCL_UpdateByCardLcController.getFieldList();
      setData(true, false, false, true, false);
      List<SmartViscaf__NameCard__c> cards = [SELECT Id,
                                                     SmartViscaf__company_name__c,
                                                     SmartViscaf__person_name_last__c
                                                FROM SmartViscaf__NameCard__c];
      System.assertEquals(1, cards.size());
      List<Lead> lea = [SELECT Id
                          FROM Lead];
      System.assertEquals(1, lea.size());
      String data = SB_NCL_UpdateByCardLcController.updateLead(lea[0].Id, cards[0].Id, true);
      SB_NCL_UpdateByCardLcController.SaveResult sr = (SB_NCL_UpdateByCardLcController.SaveResult)System.JSON.deserializeStrict(data, SB_NCL_UpdateByCardLcController.SaveResult .Class);
      System.assertEquals(true, sr.isOk);
      System.assertEquals(true, String.isBlank(sr.message));
      lea = [SELECT Id,
                    LastName,
                    Company
               FROM Lead];
      System.assertEquals(1, lea.size());
      System.assertEquals(cards[0].SmartViscaf__person_name_last__c, lea[0].LastName);
      System.assertEquals(cards[0].SmartViscaf__company_name__c, lea[0].Company);
    }
  }
}