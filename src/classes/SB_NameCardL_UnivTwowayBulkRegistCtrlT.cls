/*
 * (c) 2018 Sunbridge Inc.
 *
 * 統合版一括登録Lex&Classic コントローラ テストクラス
 * 
 * classicのページを表示、Lex環境の方はlexのページを表示　方針にして、一つボタンに統一すること
 * @author mao
 * @Version 1 2018/08/XX  SV_DEV-1109 リード拡張パッケージ[統合版]Classic環境でLexのボタンタップすると、エラー発生するため、 LexとClassicを一つボタンから表示させる
 *
 */

@isTest
public class SB_NameCardL_UnivTwowayBulkRegistCtrlT {
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
  static testMethod void testSB_NCL_TwowayBulkRegistLauncherCtrl() {
    List<User> us = insertUser();
    System.runAs(us[0]) {
      setData(true, false, false, false, false);
      List<SmartViscaf__NameCard__c> cards = [SELECT Id,
                                                     SmartViscaf__company_name__c,
                                                     SmartViscaf__person_name_last__c
                                                FROM SmartViscaf__NameCard__c];
      System.assertEquals(1, cards.size());
      PageReference pageRef = Page.SB_NameCardL_UnivTwowayBulkRegist;
      Test.setCurrentPage(pageRef);
      
      ApexPages.currentPage().getParameters().put('runTestLex', 'true');
      ApexPages.StandardSetController sc = new ApexPages.StandardSetController(cards);
      sc.setSelected(cards);
      SB_NameCardL_UnivTwowayBulkRegistCtrl ctrl = new SB_NameCardL_UnivTwowayBulkRegistCtrl(sc);
      String lccmp = 'SB_NCL_TwowayBulkRegist';
      System.assertEquals(lccmp, ctrl.component);
      System.assertEquals(cards[0].Id, ctrl.targetIds);
      ctrl.campaignOption = new SmartViscaf__NameCard__c();
      ctrl.changeCampaign();
      ctrl.getUrlRoot('https://Test.com');
      ctrl.getLabel('Test', 'TestE');
      SB_NameCardL_UnivTwowayBulkRegistCtrl.getColName('Account', '');
      SB_NameCardL_UnivTwowayBulkRegistCtrl.createStandardSetController('SmartViscaf__NameCard__c', 'Id, Name', 'Id', true);
    }
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

  static testMethod void testContact() {
    List<User> us = insertUser();
    System.runAs(us[0]) {
      setMappingDate();
      setData(true, true, true, true, false);
      List<SmartViscaf__NameCard__c> ncs = [SELECT Id
                                              FROM SmartViscaf__NameCard__c];
      System.assertEquals(1, ncs.size());

      List<Account> acs = [SELECT Id
                             FROM Account];
      System.assertEquals(1, acs.size());

      List<Contact> cos = [SELECT Id
                             FROM Contact];
      System.assertEquals(1, cos.size());

      List<Lead> leas = [SELECT Id
                             FROM Lead];
      System.assertEquals(1, leas.size());

      PageReference pageRef = Page.SB_NameCardL_TwowayBulkRegist;
      pageRef.getParameters().put('retUrl', '/home/home.jsp');
      Test.setCurrentPage(pageRef);
      ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(ncs);
      ssc.setSelected(ncs);
      SB_NameCardL_UnivTwowayBulkRegistCtrl.getRenkeiTypeList();
      SB_NameCardL_UnivTwowayBulkRegistCtrl.getSearchTypeList();
      SB_NameCardL_UnivTwowayBulkRegistCtrl ctrl = new SB_NameCardL_UnivTwowayBulkRegistCtrl(ssc);
      ctrl.renkeiType = 'Both';
      ctrl.getleadrecordtypeOptions();
      ctrl.getAccountRecordtypeOptions();
      ctrl.getContactRecordtypeOptions();
      ctrl.getSearchTypeSelectOpts();
      ctrl.useNameCardContactOwner = true;
      ctrl.useNameCardOwner = true;
      for (SB_NameCardL_BulkRegistDTO.CustomObject dto : ctrl.nameCardRecordListDTO) {
        System.assertNotEquals(1, dto.index);
      }
      ctrl.saveLead();
      System.assertEquals(null, ctrl.testError);
      System.assertEquals(true, ctrl.saveOK);
    }
  }

  static testMethod void testLead() {
    List<User> us = insertUser();
    System.runAs(us[0]) {
      setMappingDate();
      setData(true, false, false, true, false);
      List<SmartViscaf__NameCard__c> ncs = [SELECT Id
                                              FROM SmartViscaf__NameCard__c];
      System.assertEquals(1, ncs.size());

      List<Account> acs = [SELECT Id
                             FROM Account];
      System.assertEquals(0, acs.size());

      List<Contact> cos = [SELECT Id
                             FROM Contact];
      System.assertEquals(0, cos.size());

      List<Lead> leas = [SELECT Id
                             FROM Lead];
      System.assertEquals(1, leas.size());

      PageReference pageRef = Page.SB_NameCardL_TwowayBulkRegist;
      pageRef.getParameters().put('retUrl', '/home/home.jsp');
      Test.setCurrentPage(pageRef);
      ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(ncs);
      ssc.setSelected(ncs);
      SB_NameCardL_UnivTwowayBulkRegistCtrl.getRenkeiTypeList();
      SB_NameCardL_UnivTwowayBulkRegistCtrl.getSearchTypeList();
      SB_NameCardL_UnivTwowayBulkRegistCtrl ctrl = new SB_NameCardL_UnivTwowayBulkRegistCtrl(ssc);
      ctrl.renkeiType = 'Both';
      ctrl.getleadrecordtypeOptions();
      ctrl.getAccountRecordtypeOptions();
      ctrl.getContactRecordtypeOptions();
      ctrl.getSearchTypeSelectOpts();
      ctrl.useNameCardContactOwner = true;
      ctrl.useNameCardOwner = true;
      ctrl.saveLead();
      System.assertEquals(true, ctrl.saveOK);
    }
  }
}