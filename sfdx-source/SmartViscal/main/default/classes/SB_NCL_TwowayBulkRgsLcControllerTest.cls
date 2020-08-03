/*
 * SB_NCL_TwowayBulkRgsLcControllerTest
 *
 * (c) 2018 Sunbridge Inc.
 *
 * 統合版一括登録Lex コントローラ SB_NCL_TwowayBulkRgsLcControllerのテストクラス
 * @Version リード拡張：Lead Ex. 1.12 2018/08/XX
 * @Version リード拡張：Lead Ex. 2.2  2020.08.03   PRODUCT-379 LEX 統合版登録 一括：会社名の検索方法での検索対応
 * @Version リード拡張：Lead Ex. 2.2  2020.08.03   PRODUCT-387 LEX 統合版登録 一括：登録先候補が多すぎるため処理を中断しましたエラー対策
 *
 */

@isTest
private class SB_NCL_TwowayBulkRgsLcControllerTest {
  private enum CompanyMatcing { FullMatch, CorpMatch, PartialMatch } // 法人格含み完全一致、法人格を除いて一致、法人格を除いて部分一致
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

    us.add(u);
    us.add(u1);
    return us;
  }
  /**
    * @description データー作成用のメソッド
  **/
  private static void setData(Boolean needNameCard, Boolean needAccount, Boolean needContact, Boolean needLead, Boolean needCampaign) {
    setData(needNameCard, needAccount, needContact, needLead, needCampaign, CompanyMatcing.FullMatch);
  }

  /**
    * @description データー作成用のメソッド
  **/
  private static void setData(Boolean needNameCard, Boolean needAccount, Boolean needContact, Boolean needLead, Boolean needCampaign, CompanyMatcing match) {
    SmartViscaf__NameCard__c nc = new SmartViscaf__NameCard__c();
    nc.SmartViscaf__zip_code__c = '150-0022';
    // nc.SmartViscaf__address_pref__c = '東京都';
    // nc.SmartViscaf__address__c = '渋谷区恵比寿南';
    nc.SmartViscaf__company_name__c = '株式会社TestCompany';
    // nc.SmartViscaf__tel1__c = '03-1111-1111';
    // nc.SmartViscaf__fax1__c = '03-1111-1112';
    // nc.SmartViscaf__title_name__c = 'TestTitle';
    nc.SmartViscaf__person_name_last__c = 'TestLast';
    nc.SmartViscaf__person_name_first__c = 'TestFirst';
    nc.SmartViscaf__email__c = 'Test@test.com';

    //nc.SmartViscaf__email__c = 'test@sbnc.example.com';
    // nc.SmartViscaf__mobile__c = '090-1111-1111';
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
    // 取引先/取引先責任者　マッチング対象
    Account a ;
    if (needAccount) {
      switch on match {
        when FullMatch {
          // 法人格含み完全一致
          a = new Account(Name = '株式会社TestCompany');
        }
        when CorpMatch {
          // 法人格を除いて一致
          a = new Account(Name = 'TestCompany');
        }
        when PartialMatch {
          // 法人格を除いて部分一致
          a = new Account(Name = '1TestCompany1');
        }
      }
      a.SmartViscaf__NameCard__c = nc.Id;
      // a.Site = 'TestTitle';
      // a.BillingState = 'TestBillingState';
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
      cont.MailingState = 'TestMailingState';
      cont.Title = 'TestTitle';
      cont.MobilePhone = '1234321';
      cont.Email = 'Test@test.com';
      cont.Department = 'TestDepartment';
      insert cont;
      nc.SmartViscaf__contact__c = cont.Id;
    }
    // 取引先/取引先責任者　マッチング非対象
    if (needAccount) {
      switch on match {
        when FullMatch {
          // 法人格含み完全一致
          a = new Account(Name = '有限会社TestCompany');
        }
        when CorpMatch {
          // 法人格を除いて一致
          a = new Account(Name = 'TestCompanyNo');
        }
        when PartialMatch {
          // 法人格を除いて部分一致
          a = new Account(Name = 'TestCompan');
        }
      }
      a.SmartViscaf__NameCard__c = nc.Id;
      // a.Site = 'TestTitle';
      // a.BillingState = 'TestBillingState';
      insert a;
      // nc.SmartViscaf__account__c = a.Id;
    }

    if (needContact) {
      Contact cont = new Contact();
      if (a != null) {
        cont.AccountId = a.Id;
      }
      cont.LastName = 'TestLastNo';
      cont.FirstName = 'TestFirstNo';
      // cont.SmartViscaf__NameCard__c = nc.Id;
      cont.MailingState = 'TestMailingStateNo';
      cont.Title = 'TestTitleNo';
      cont.MobilePhone = '123432100';
      cont.Email = 'TestNo@test.com';
      cont.Department = 'TestDepartmentNo';
      insert cont;
      // nc.SmartViscaf__contact__c = cont.Id;
    }

    // リード　マッチング対象
    if (needLead) {
      Lead lea = new Lead();
      lea.LastName = 'TestLast';
      lea.FirstName = 'TestFirst';
      switch on match {
        when FullMatch {
          // 法人格含み完全一致
          lea.Company = '株式会社TestCompany';
        }
        when CorpMatch {
          // 法人格を除いて一致
          lea.Company = 'TestCompany';
        }
        when PartialMatch {
          // 法人格を除いて部分一致
          lea.Company = '1TestCompany1';
        }
      }
      
      lea.NameCard__c = nc.Id;
      lea.Email = 'Test@test.com';
      lea.MobilePhone = '123321';
      lea.Title = 'TestTitle';
      lea.State = 'TestState';
      insert lea;
      nc.SmartViscaf__lead__c = lea.Id;
    }
    // リード　マッチング非対象
    if (needLead) {
      Lead lea = new Lead();
      lea.LastName = 'TestLastNo';
      lea.FirstName = 'TestFirstNo';
      switch on match {
        when FullMatch {
          // 法人格含み完全一致
          lea.Company = '有限会社TestCompany';
        }
        when CorpMatch {
          // 法人格を除いて一致
          lea.Company = 'TestCompanyNo';
        }
        when PartialMatch {
          // 法人格を除いて部分一致
          lea.Company = '1TestCompan';
        }
      }
      
      // lea.NameCard__c = nc.Id;
      lea.Email = 'TestNo@test.com';
      lea.MobilePhone = '12332100';
      lea.Title = 'TestTitleNo';
      lea.State = 'TestStateNo';
      insert lea;
      // nc.SmartViscaf__lead__c = lea.Id;
    }


    update nc;
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

  /**
    * @description Searchメソッドのテストメソッド
  **/
  static testMethod void testSearchBoth() {
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
      System.assertEquals(2, acc.size());
      List<Contact> con = [SELECT Id
                          FROM Contact];
      System.assertEquals(2, con.size());
      List<Lead> lea = [SELECT Id
                          FROM Lead];
      System.assertEquals(2, lea.size());
      SB_NCL_TwowayBulkRgsLcController.getTitleValue();
      SB_NCL_TwowayBulkRgsLcController.getFieldList();
      SB_NCL_TwowayBulkRgsLcController.getInputValue();

      // HeadSize用50%超 PRODUCT-387 LEX 統合版登録 一括：登録先候補が多すぎるため処理を中断しましたエラー対策
      String tooBig = '*'.repeat(Integer.valueOf(Limits.getLimitHeapSize() * 0.5));
      // searchType                           検索条件（1:メールアドレス / 2:氏名）
      // searchContactType                    取引先責任者検索条件（3:取引先名 / 4:取引先名と部門 / 5:取引先名、部門と都道府県 / 6:取引先名、部門と市区群まで / 7:取引先名、部門と郵便番号）
      String data = SB_NCL_TwowayBulkRgsLcController.searchAllLead(cards[0].Id, '2', '3', null, 'ExactMatchAccount', 'ExactMatchLead');
      Map<String, Object> dto = (Map<String, Object>)System.JSON.deserializeUntyped(data);
      System.assertEquals('', dto.get('message'));
      System.assertEquals(true, dto.get('success'));
      System.assertEquals('', dto.get('message'));
      Map<Id, Map<String, SB_NameCardL_BulkRegistDTO.InputPlickListValue>> inputPlickListVMap = (Map<Id, Map<String, SB_NameCardL_BulkRegistDTO.InputPlickListValue>>)System.JSON.deserializeStrict(JSON.serialize(dto.get('data')), Map<Id, Map<String, SB_NameCardL_BulkRegistDTO.InputPlickListValue>> .Class);
      System.assertEquals(1, inputPlickListVMap.keySet().size());
      System.assertEquals(true, inputPlickListVMap.containskey(cards[0].Id));
      Map<String, SB_NameCardL_BulkRegistDTO.InputPlickListValue> inputPlickListMap = inputPlickListVMap.get(cards[0].Id);
      System.assertEquals(true, inputPlickListMap.containskey('Lead'));
      System.assertEquals(true, inputPlickListMap.containskey('Contact'));
      SB_NameCardL_BulkRegistDTO.InputPlickListValue plickListLead = inputPlickListMap.get('Lead');
      SB_NameCardL_BulkRegistDTO.InputPlickListValue plickListContact = inputPlickListMap.get('Contact');
      System.debug(plickListContact.plickListOptions);
      String message = plickListContact.plickListOptions[0].Label;
      message += plickListContact.plickListOptions[1].Label;
      message += plickListContact.plickListOptions[2].Label;
      System.assertEquals(4, plickListContact.plickListOptions.size());
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
      System.assertEquals(2, acc.size());
      List<Contact> con = [SELECT Id
                          FROM Contact];
      System.assertEquals(2, con.size());
      List<Lead> lea = [SELECT Id
                          FROM Lead];
      System.assertEquals(2, lea.size());

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
      String data = SB_NCL_TwowayBulkRgsLcController.getCampaignStatus(cm[0].Id);
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
      setData(true, true, true, true, true, CompanyMatcing.FullMatch);
      List<SmartViscaf__NameCard__c> cards = [SELECT Id,
                                                     SmartViscaf__company_name__c,
                                                     SmartViscaf__person_name_last__c
                                                FROM SmartViscaf__NameCard__c];
      System.assertEquals(1, cards.size());
      List<Account> acc = [SELECT Id
                             FROM Account];
      System.assertEquals(2, acc.size());
      List<Contact> con = [SELECT Id
                          FROM Contact];
      System.assertEquals(2, con.size());
      List<Lead> lea = [SELECT Id
                          FROM Lead];
      System.assertEquals(2, lea.size());
      String data = SB_NCL_TwowayBulkRgsLcController.getAllData(cards[0].Id, null, null, null, null, 'PartialMatchAccount', 'PartialMatchLead');
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
    * FullMatch 法人格含み完全一致
  **/
  static testMethod void testSearchFullMatch() {
    List<User> us = insertUser();
    System.runAs(us[0]) {
      setData(true, true, true, true, true, CompanyMatcing.FullMatch);
      List<SmartViscaf__NameCard__c> cards = [SELECT Id,
                                                     SmartViscaf__company_name__c,
                                                     SmartViscaf__person_name_last__c
                                                FROM SmartViscaf__NameCard__c];
      System.assertEquals(1, cards.size());
      List<Account> acc = [SELECT Id
                             FROM Account];
      System.assertEquals(2, acc.size());
      List<Contact> con = [SELECT Id
                          FROM Contact];
      System.assertEquals(2, con.size());
      List<Lead> lea = [SELECT Id
                          FROM Lead];
      System.assertEquals(2, lea.size());

      // HeadSize用50%超 PRODUCT-387 LEX 統合版登録 一括：登録先候補が多すぎるため処理を中断しましたエラー対策
      String tooBig = '*'.repeat(Integer.valueOf(Limits.getLimitHeapSize() * 0.5));
      // searchType                           検索条件（1:メールアドレス / 2:氏名）
      // searchContactType                    取引先責任者検索条件（3:取引先名 / 4:取引先名と部門 / 5:取引先名、部門と都道府県 / 6:取引先名、部門と市区群まで / 7:取引先名、部門と郵便番号）
      String data = SB_NCL_TwowayBulkRgsLcController.getAllData(cards[0].Id, null, '2', '3', null, 'ExactMatchAccount', 'ExactMatchLead');
      Map<String, Object> dtoMap = (Map<String, Object>)System.JSON.deserializeUntyped(data);
      System.assertEquals(true, dtoMap.get('success'));
      System.assertEquals('', dtoMap.get('message'));
      List<SB_NameCardL_BulkRegistDTO.CustomObject> dtos = (List<SB_NameCardL_BulkRegistDTO.CustomObject>)System.JSON.deserializeStrict(JSON.serialize(dtoMap.get('data')), List<SB_NameCardL_BulkRegistDTO.CustomObject> .Class);
      System.assertEquals(1, dtos.size());
      System.assertEquals(cards[0].Id, dtos[0].id);

      // 選択リストの取得内容確認
      // 取引先責任者
      List<SB_NameCardL_BulkRegistDTO.LabelValue> plickListOptions = dtos[0].combobox.get('Contact').plickListOptions;
      System.assertEquals(4, plickListOptions.size());
      System.assert(plickListOptions[0].label.contains('株式会社TestCompany'));
      System.assert(plickListOptions[1].label.contains('株式会社TestCompany'));
      // リード
      plickListOptions = dtos[0].combobox.get('Lead').plickListOptions;
      System.assertEquals(3, plickListOptions.size());
      System.assert(plickListOptions[0].label.contains('TestFirst TestLast'));

    }
  }

  /**
    * @description 検索関するするのテストメソッド
    * CorpMatch 法人格を除いて一致
  **/
  static testMethod void testSearchCorpMatch() {
    List<User> us = insertUser();
    System.runAs(us[0]) {
      setData(true, true, true, true, true, CompanyMatcing.CorpMatch);
      List<SmartViscaf__NameCard__c> cards = [SELECT Id,
                                                     SmartViscaf__company_name__c,
                                                     SmartViscaf__person_name_last__c
                                                FROM SmartViscaf__NameCard__c];
      System.assertEquals(1, cards.size());
      List<Account> acc = [SELECT Id
                             FROM Account];
      System.assertEquals(2, acc.size());
      List<Contact> con = [SELECT Id
                          FROM Contact];
      System.assertEquals(2, con.size());
      List<Lead> lea = [SELECT Id
                          FROM Lead];
      System.assertEquals(2, lea.size());
      String data = SB_NCL_TwowayBulkRgsLcController.getAllData(cards[0].Id, null, '2', '3', null, 'CorpMatchAccount', 'CorpMatchLead');
      Map<String, Object> dtoMap = (Map<String, Object>)System.JSON.deserializeUntyped(data);
      System.assertEquals(true, dtoMap.get('success'));
      System.assertEquals('', dtoMap.get('message'));
      List<SB_NameCardL_BulkRegistDTO.CustomObject> dtos = (List<SB_NameCardL_BulkRegistDTO.CustomObject>)System.JSON.deserializeStrict(JSON.serialize(dtoMap.get('data')), List<SB_NameCardL_BulkRegistDTO.CustomObject> .Class);
      System.assertEquals(1, dtos.size());
      System.assertEquals(cards[0].Id, dtos[0].id);

      // 選択リストの取得内容確認
      // 取引先責任者
      List<SB_NameCardL_BulkRegistDTO.LabelValue> plickListOptions = dtos[0].combobox.get('Contact').plickListOptions;
      System.assertEquals(4, plickListOptions.size());
      System.assert(plickListOptions[0].label.contains('TestCompany'));
      System.assert(plickListOptions[1].label.contains('TestCompany'));
      // リード
      plickListOptions = dtos[0].combobox.get('Lead').plickListOptions;
      System.assertEquals(3, plickListOptions.size());
      System.assert(plickListOptions[0].label.contains('TestFirst TestLast'));
    }
  }

  /**
    * @description 検索関するするのテストメソッド
    * PartialMatch 法人格を除いて部分一致
  **/
  static testMethod void testSearchPartialMatch() {
    List<User> us = insertUser();
    System.runAs(us[0]) {
      setData(true, true, true, true, true, CompanyMatcing.PartialMatch);
      List<SmartViscaf__NameCard__c> cards = [SELECT Id,
                                                     SmartViscaf__company_name__c,
                                                     SmartViscaf__person_name_last__c
                                                FROM SmartViscaf__NameCard__c];
      System.assertEquals(1, cards.size());
      List<Account> acc = [SELECT Id
                             FROM Account];
      System.assertEquals(2, acc.size());
      List<Contact> con = [SELECT Id
                          FROM Contact];
      System.assertEquals(2, con.size());
      List<Lead> lea = [SELECT Id
                          FROM Lead];
      System.assertEquals(2, lea.size());
      String data = SB_NCL_TwowayBulkRgsLcController.getAllData(cards[0].Id, null, '2', '3', null, 'PartialMatchAccount', 'PartialMatchLead');
      Map<String, Object> dtoMap = (Map<String, Object>)System.JSON.deserializeUntyped(data);
      System.assertEquals(true, dtoMap.get('success'));
      System.assertEquals('', dtoMap.get('message'));
      List<SB_NameCardL_BulkRegistDTO.CustomObject> dtos = (List<SB_NameCardL_BulkRegistDTO.CustomObject>)System.JSON.deserializeStrict(JSON.serialize(dtoMap.get('data')), List<SB_NameCardL_BulkRegistDTO.CustomObject> .Class);
      System.assertEquals(1, dtos.size());
      System.assertEquals(cards[0].Id, dtos[0].id);

      // 選択リストの取得内容確認
      // 取引先責任者
      List<SB_NameCardL_BulkRegistDTO.LabelValue> plickListOptions = dtos[0].combobox.get('Contact').plickListOptions;
      for (SB_NameCardL_BulkRegistDTO.LabelValue lv : plickListOptions) {
        System.debug('testSearchPartialMatch lv:' + lv);
      }
      System.assertEquals(4, plickListOptions.size());
      System.assert(plickListOptions[0].label.contains('1TestCompany1'));
      System.assert(plickListOptions[1].label.contains('1TestCompany1'));
      // リード
      plickListOptions = dtos[0].combobox.get('Lead').plickListOptions;
      System.assertEquals(3, plickListOptions.size());
      System.assert(plickListOptions[0].label.contains('TestFirst TestLast'));
    }
  }



  /**
    * @description 取引先新規保存のテストメソッド
  **/
  static testMethod void testSaveAccount() {
    List<User> us = insertUser();
    System.runAs(us[0]) {
      setData(true, true, true, true, true);
      setMappingDate();
      List<SmartViscaf__NameCardBasicSetting__c> settings = [SELECT Id
                                                               FROM SmartViscaf__NameCardBasicSetting__c];
      System.assertEquals(1, settings.size());
      System.assertEquals(SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().Id, settings[0].Id);
      

      List<SmartViscaf__NameCardRenkeiMapping__c> mappings = [SELECT Id
                                                                FROM SmartViscaf__NameCardRenkeiMapping__c];
      System.assertEquals(4, mappings.size());
      List<SmartViscaf__NameCard__c> cards = [SELECT Id,
                                                     SmartViscaf__company_name__c,
                                                     SmartViscaf__person_name_last__c
                                                FROM SmartViscaf__NameCard__c];
      System.assertEquals(1, cards.size());
      System.assertEquals('株式会社TestCompany', cards[0].SmartViscaf__company_name__c);
      List<Account> acc = [SELECT Id
                             FROM Account];
      System.assertEquals(2, acc.size());
      List<Contact> con = [SELECT Id
                          FROM Contact];
      System.assertEquals(2, con.size());
      List<Lead> lea = [SELECT Id
                          FROM Lead];
      System.assertEquals(2, lea.size());
      String data = SB_NCL_TwowayBulkRgsLcController.getAllData(cards[0].Id, null, null, null, null, 'PartialMatchAccount', 'PartialMatchLead');
      Map<String, Object> dtoMap = (Map<String, Object>)System.JSON.deserializeUntyped(data);
      System.assertEquals(true, dtoMap.get('success'));
      System.assertEquals('', dtoMap.get('message'));
      List<SB_NameCardL_BulkRegistDTO.CustomObject> dto = (List<SB_NameCardL_BulkRegistDTO.CustomObject>)System.JSON.deserializeStrict(JSON.serialize(dtoMap.get('data')), List<SB_NameCardL_BulkRegistDTO.CustomObject> .Class);
      System.assertEquals(1, dto.size());
      dto[0].cObjectMap.get('Lead').value = 'none';
      dto[0].cObjectMap.get('Contact').value = 'new';
      System.assertEquals(cards[0].Id, dto[0].id);
      SB_NameCardL_BulkRegistDTO.InputValue inputValue = (SB_NameCardL_BulkRegistDTO.InputValue)System.JSON.deserializeStrict(SB_NCL_TwowayBulkRgsLcController.getInputValue(), SB_NameCardL_BulkRegistDTO.InputValue  .Class);
      inputValue.useNameCardOwner = true;
      inputValue.useNameCardAccountOwner = true;
      String saveDate = SB_NCL_TwowayBulkRgsLcController.saveLead(Json.serialize(dto), Json.serialize(inputValue), 'Account');
      Map<String, Object> saver = (Map<String, Object>)System.JSON.deserializeUntyped(saveDate);
      System.assertEquals('', saver.get('testClassMessage'));
      System.assertEquals(true, saver.get('success'));
      
    }
  }

  /**
    * @description 取引先保存のテストメソッド
  **/
  static testMethod void testSaveContact() {
    List<User> us = insertUser();
    System.runAs(us[0]) {
      setData(true, true, true, true, true);
      setMappingDate();
      List<SmartViscaf__NameCardBasicSetting__c> settings = [SELECT Id
                                                               FROM SmartViscaf__NameCardBasicSetting__c];
      System.assertEquals(1, settings.size());
      System.assertEquals(SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().Id, settings[0].Id);
      

      List<SmartViscaf__NameCardRenkeiMapping__c> mappings = [SELECT Id
                                                                FROM SmartViscaf__NameCardRenkeiMapping__c];
      System.assertEquals(4, mappings.size());
      List<SmartViscaf__NameCard__c> cards = [SELECT Id,
                                                     SmartViscaf__company_name__c,
                                                     SmartViscaf__person_name_last__c
                                                FROM SmartViscaf__NameCard__c];
      System.assertEquals(1, cards.size());
      System.assertEquals('株式会社TestCompany', cards[0].SmartViscaf__company_name__c);
      List<Account> acc = [SELECT Id
                             FROM Account];
      System.assertEquals(2, acc.size());
      List<Contact> con = [SELECT Id
                          FROM Contact];
      System.assertEquals(2, con.size());
      List<Lead> lea = [SELECT Id
                          FROM Lead];
      System.assertEquals(2, lea.size());
      String data = SB_NCL_TwowayBulkRgsLcController.getAllData(cards[0].Id, null, null, null, null, 'PartialMatchAccount', 'PartialMatchLead');
      Map<String, Object> dtoMap = (Map<String, Object>)System.JSON.deserializeUntyped(data);
      System.assertEquals(true, dtoMap.get('success'));
      System.assertEquals('', dtoMap.get('message'));
      List<SB_NameCardL_BulkRegistDTO.CustomObject> dto = (List<SB_NameCardL_BulkRegistDTO.CustomObject>)System.JSON.deserializeStrict(JSON.serialize(dtoMap.get('data')), List<SB_NameCardL_BulkRegistDTO.CustomObject> .Class);
      System.assertEquals(1, dto.size());
      dto[0].cObjectMap.get('Lead').value = 'new';
      dto[0].cObjectMap.get('Contact').value = 'none';
      System.assertEquals(cards[0].Id, dto[0].id);
      SB_NameCardL_BulkRegistDTO.InputValue inputValue = (SB_NameCardL_BulkRegistDTO.InputValue)System.JSON.deserializeStrict(SB_NCL_TwowayBulkRgsLcController.getInputValue(), SB_NameCardL_BulkRegistDTO.InputValue  .Class);
      inputValue.useNameCardOwner = true;
      inputValue.useNameCardAccountOwner = true;
      String saveDate = SB_NCL_TwowayBulkRgsLcController.saveLead(Json.serialize(dto), Json.serialize(inputValue), 'Lead');
      Map<String, Object> saver = (Map<String, Object>)System.JSON.deserializeUntyped(saveDate);
      System.assertEquals('', saver.get('testClassMessage'));
      System.assertEquals(true, saver.get('success'));
      
    }
  }
}