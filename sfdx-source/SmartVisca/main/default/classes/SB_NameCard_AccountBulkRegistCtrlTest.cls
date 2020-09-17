/**
 *
 * 名刺情報から取引先・取引先責任者への登録、一括登録 SB_NameCard_AccountBulkRegistController のテストクラス
 *
 * Copyright (C) 2011-2014 SunBridge Inc. All Rights Reserved.
 *
 *  @author gao
 *  History :
 *    SB_NameCard_AccountBulkRegistCtrlTest を更新
 *  @Version 2    2014.4.2x
 *  @Version 1.20.4    2017.11.xx  SV_DEV-673 会社名に全角バックスラッシュが含まれる名刺を自動連携すると、ORA-01424エラーが発生
 *  @Version 1.22      2017.11.XX SV_DEV-684  部署名に全角バックスラッシュが含まれる名刺を自動連携すると、ORA-01424エラーが発生する
 *  @Version 2.1       2018.04.XX  SV_DEV-876   連携設定条件に名刺項目に参照項目が選択できないことを変更
 *  @Version 2.1       2018.04.XX  SV_DEV-885 基本設定、連携条件設定、連携マッピングタブ切り替えの見直し
 *  @Version 2.1       2018.04.XX  SV_DEV-1106 SmartVisca基本設定レコードの一部項目の値が反転して表示される。
 *  @Version 2.4       2019.05.XX  SV_DEV-1630と合わせてリファクタリングを実施
 **/
@isTest
private class SB_NameCard_AccountBulkRegistCtrlTest {
  public class AccountBulkRegistCtrlTestDB extends SB_NameCard_TestDB {
    // 取引先を既存にするために名刺にある取引先を事前に追加
    public override virtual void initializeAccount() {
      Integer i = 1;
      for (String actName :listKaisha) {
        mapAccount.put(actName, new Account(Name= actName + i
                                        , Site='第' + i + '部 第' + i + '課'));
        i++;
      }
    }


  // 取引先責任者を既存にするために名刺にする取引先責任者を事前に追加
  //  存在するユーザごとに所有者を変えて同一の取引先責任者を追加
  public override virtual void initializeContact() {
    Integer i = 1;
    for(Employee emp :listEmp) {
      Account acnt = mapAccount.get(emp.kaisha);
      listContact.add(new Contact(AccountId=acnt.Id
                      , LastName=emp.sei + i
                      , FirstName=emp.mei
                      , Email=emp.mail
                      ));
      i++;
    }
  }

  public override void initialize() {
    // ユーザ
    initializeUser();
    if (listUser.isEmpty() == false) {
      insert listUser;
    }
    // 名刺
    initializeKaisha();   // 会社を揃えておく
    initializeEmployee(); // 会社ごとに名刺の人を揃えておく
    initializeAccount();  // 揃えた会社について、取引先を作る。
    if (mapAccount.isEmpty() == false) {
      insert mapAccount.values();
    }
    initializeContact();  // 揃えた会社ごとに名刺の人で、取引先責任者を作る。
    if (listContact.isEmpty() == false) {
      insert listContact;
    }
    System.debug('alistCardis' + listCard.size());
    initializeNameCard();
    if (listCard.isEmpty() == false) {
      insert listCard;
    }
    System.debug('blistCardis' + listCard.size());
    // ToDo
    initializeEvent();
    if (listEvent.isEmpty() == false) {
      insert listEvent;
    }
    // 行動
    initializeTask();
    if (listTask.isEmpty() == false){
      insert listTask;
    }
  }
}

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
    setting.RenkeiAccountAddressPref__c = false;
    setting.RenkeiAccountCity__c = false;
    setting.RenkeiAccountOverwrite__c = true;
    setting.RenkeiAccountNOExistCreateNew__c = true;
    setting.RegistDispAccountRectype__c = true; // 取引先・取引先任者に登録 取引先レコードタイプ選択を表示する
    setting.RegistAccountNotOverWrite__c = false; // 取引先・取引先任者に登録 取引先を名刺情報で上書きしない
    setting.RegistDispContactRectype__c = true; // 取引先・取引先任者に登録 取引先責任者レコードタイプ選択を表示する
    setting.RegistContactNotOverWrite__c = false; // 取引先・取引先任者に登録 取引先責任者を名刺情報で上書きしない
    setting.RenkeiAccountNOExistCreateNew__c = true;  //既存の取引先がなければ新規作成する
    setting.RenkeiContactNOExistCreateNew__c = true;  // 既存の取引先責任者がなければ新規作成する
    insert setting;

    String objname = SB_NameCard_RenkeiMapperUtil.getManagedObjectName('NameCardRenkeiMapping__c');
    List<RecordType> res = [SELECT Id,Name,Developername FROM RecordType WHERE SobjectType = :objname AND (Developername ='Account' OR Developername = 'Contact')];
    System.debug('resresres' + res);
    List<NameCardRenkeiMapping__c> testmapplist = new List<NameCardRenkeiMapping__c>();
    NameCardRenkeiMapping__c amap = new NameCardRenkeiMapping__c();
    amap.IsActive__c = true;
    amap.TargetName__c = 'Name';
    amap.NameCardName__c = SB_NameCard_RenkeiMapperUtil.getManagedfileName('NameCard__c','company_name__c');
    amap.BasicSetting__c = setting.Id;
    if(res.size()>0){
        amap.RecordTypeId = res[0].Id;
    }
    testmapplist.add(amap);

    NameCardRenkeiMapping__c cmap = new NameCardRenkeiMapping__c();
    cmap.IsActive__c = true;
    cmap.TargetName__c = 'LastName';
    cmap.NameCardName__c = SB_NameCard_RenkeiMapperUtil.getManagedfileName('NameCard__c','person_name_last__c');
    if(res.size()>1){
        cmap.RecordTypeId = res[1].Id;
    }
    testmapplist.add(cmap);
    cmap.BasicSetting__c = setting.Id;


    insert testmapplist;
  }


  // 取引先、取引先責任者が既存で、名刺が追加されて、取引先、取引先責任者を新たに作るテスト
  private static testMethod void testCreateNew() {

    setMappingDate();
    Test.startTest();
    AccountBulkRegistCtrlTestDB db = new AccountBulkRegistCtrlTestDB();
    db.initialize();
    List<Account> acnts1 = [SELECT Id, Name from Account];
    System.debug('acnts1' + acnts1.size());
    ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(db.listCard);
    ssc.setSelected(db.listCard);
    SB_NameCard_AccountBulkRegistController ctrl = new SB_NameCard_AccountBulkRegistController(ssc);
    for (SB_NameCard_AccountBulkRegistController.NameCardRecord ncr : ctrl.nameCardTable) {
        ncr.accAndCon = ncr.accAndConSelectOpts.size()-1;
        ncr.registTask = true;
    }
    ctrl.owner.OwnerId = UserInfo.getUserId();
    System.debug('startsave');
    ctrl.saveNC();
    System.debug('endsave');
    Test.stopTest();
    //ctrl.cancel();
    List<Account> acnts = [SELECT Id, Name from Account];
    System.assertEquals(db.mapAccount.size() + db.listEmp.size(), acnts.size()); // 名刺の数だけ取引先が増えてる。
    List<Contact> conts = [SELECT Id, Name from Contact];
    System.assertEquals(db.listContact.size() + db.listEmp.size(), conts.size());  // 名刺の数だけ取引先責任者が増えてる。
    List<Task> tasks = [SELECT whoId, whatId from Task];
    for (Task t :tasks) {
        System.assertNotEquals(null, t.whoId);// 名刺の活動を取引先責任者に紐づいてる
    }
    List<Event> evens = [SELECT whoId, whatId from Event];
    for (Event e :evens) {
        System.assertNotEquals(null, e.WhoId);
    }
  }

  // 取引先、取引先責任者が既存で、名刺が追加されて、取引先、取引先責任者を新たに作らず、更新するテスト
  private static testMethod void testUpdateExist() {
    Test.startTest();
    AccountBulkRegistCtrlTestDB db = new AccountBulkRegistCtrlTestDB();
    db.initialize();

    ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(db.listCard);
    ssc.setSelected(db.listCard);

    SB_NameCard_AccountBulkRegistController ctrl = new SB_NameCard_AccountBulkRegistController(ssc);
    for (SB_NameCard_AccountBulkRegistController.NameCardRecord ncr : ctrl.nameCardTable) {
      ncr.accAndCon = 0;
      ncr.registTask = true;
    }
    ctrl.saveNC();
    //ctrl.cancel();
    List<Account> acnts = [SELECT Id, Name from Account];
    System.assertEquals(db.mapAccount.size(), acnts.size());  // 取引先が増えてない。
    List<Contact> conts = [SELECT Id, Name from Contact];
    System.assertEquals(db.listContact.size(), conts.size()); // 取引先責任者が増えてない。

    ctrl.getSearchTypeSelectOpts();
    ctrl.getAccRecTypeSelectOpts();
    ctrl.getContRecTypeSelectOpts();
    Test.stopTest();
  }

  //既存の取引先を名刺情報で上書きする」を表示する
  //既存の取引先責任者を名刺情報で上書きする」を表示するのチェック
  private static testMethod void testOverWriteTrue() {
    Test.startTest();
    AccountBulkRegistCtrlTestDB db = new AccountBulkRegistCtrlTestDB();
    db.initialize();

    NameCardBasicSetting__c s = SB_NameCard_BasicSetting.getNameCardBasicSetting();
    //既存の取引先を名刺情報で上書きする」を表示する
    s.RegistDispAccountOverWriteCheckbox__c = true;
    //既存の取引先責任者を名刺情報で上書きする」を表示する
    s.RegistDispContactOverWriteCheckbox__c = true;
    insert s;

    ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(db.listCard);
    ssc.setSelected(db.listCard);

    SB_NameCard_AccountBulkRegistController ctrl = new SB_NameCard_AccountBulkRegistController(ssc);
    System.assertEquals(ctrl.showupdateAccount,true);
    System.assertEquals(ctrl.showupdateContact,true);

  }

  //既存の取引先を名刺情報で上書きする」を表示する
  //既存の取引先責任者を名刺情報で上書きする」を表示するのチェック
  private static testMethod void testOverWriteFalse() {
    Test.startTest();
    AccountBulkRegistCtrlTestDB db = new AccountBulkRegistCtrlTestDB();
    db.initialize();

    NameCardBasicSetting__c s = SB_NameCard_BasicSetting.getNameCardBasicSetting();
    //既存の取引先を名刺情報で上書きする」を表示する
    s.RegistDispAccountOverWriteCheckbox__c = false;
    //既存の取引先責任者を名刺情報で上書きする」を表示する
    s.RegistDispContactOverWriteCheckbox__c = false;
    insert s;

    ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(db.listCard);
    ssc.setSelected(db.listCard);

    SB_NameCard_AccountBulkRegistController ctrl = new SB_NameCard_AccountBulkRegistController(ssc);
    System.assertEquals(ctrl.showupdateAccount,false);
    System.assertEquals(ctrl.showupdateContact,false);

  }

  //既存の取引先を名刺情報で上書きする」を表示する
  //既存の取引先責任者を名刺情報で上書きする」を表示するのチェック
  private static testMethod void testOverWriteFalseTrue() {
    Test.startTest();
    AccountBulkRegistCtrlTestDB db = new AccountBulkRegistCtrlTestDB();
    db.initialize();

    NameCardBasicSetting__c s = SB_NameCard_BasicSetting.getNameCardBasicSetting();
    //既存の取引先を名刺情報で上書きする」を表示する
    s.RegistDispAccountOverWriteCheckbox__c = false;
    //既存の取引先責任者を名刺情報で上書きする」を表示する
    s.RegistDispContactOverWriteCheckbox__c = true;
    insert s;

    ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(db.listCard);
    ssc.setSelected(db.listCard);

    SB_NameCard_AccountBulkRegistController ctrl = new SB_NameCard_AccountBulkRegistController(ssc);
    System.assertEquals(ctrl.showupdateAccount,false);
    System.assertEquals(ctrl.showupdateContact,true);

  }

  //既存の取引先を名刺情報で上書きする」を表示する
  //既存の取引先責任者を名刺情報で上書きする」を表示するのチェック
  private static testMethod void testOverWriteTrueFalse() {
    Test.startTest();
    AccountBulkRegistCtrlTestDB db = new AccountBulkRegistCtrlTestDB();
    db.initialize();

    NameCardBasicSetting__c s = SB_NameCard_BasicSetting.getNameCardBasicSetting();
    //既存の取引先を名刺情報で上書きする」を表示する
    s.RegistDispAccountOverWriteCheckbox__c = true;
    //既存の取引先責任者を名刺情報で上書きする」を表示する
    s.RegistDispContactOverWriteCheckbox__c = false;
    insert s;

    ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(db.listCard);
    ssc.setSelected(db.listCard);

    SB_NameCard_AccountBulkRegistController ctrl = new SB_NameCard_AccountBulkRegistController(ssc);
    System.assertEquals(ctrl.showupdateAccount,true);
    System.assertEquals(ctrl.showupdateContact,false);

  }

  /*
   *  複数名刺一括登録のケース
   *  名刺が姓名が存在、責任者は姓名が一致
   *  希望結果：検索されます
  */
  private static testMethod void testMultipleNameCard() {
    Test.startTest();
    NameCard__c n1 = new NameCard__c(Name = 'Test1',
                                     company_name__c = 'TestC1',
                                     person_name_last__c = 'TestL1',
                                     person_name_first__c = 'TestF1');
    NameCard__c n2 = new NameCard__c(Name = 'Test2',
                                     company_name__c = 'TestC2',
                                     person_name_last__c = 'TestL2',
                                     person_name_first__c = 'TestF2');
    insert new NameCard__c[]{n1, n2};

    Account a1 = new Account(Name = 'TestC1');
    Account a2 = new Account(Name = 'TestC2');
    insert new Account[]{a1, a2};

    Contact c1 = new Contact(LastName = 'TestL1', FirstName = 'TestF1', AccountId = a1.Id);
    Contact c2 = new Contact(LastName = 'TestL2', FirstName = 'TestF2', AccountId = a2.Id);
    Contact[] cs = new Contact[]{c1, c2};
    insert cs;
    Test.stopTest();
    ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(new NameCard__c[]{n1, n2});
    ssc.setSelected(new NameCard__c[]{n1, n2});
    SB_NameCard_AccountBulkRegistController ctrl = new SB_NameCard_AccountBulkRegistController(ssc);
    Integer i = 0;
    for (SB_NameCard_AccountBulkRegistController.NameCardRecord ncr : ctrl.nameCardTable) {
      System.debug(ncr.accAndConList[1].contactId);
      System.debug(cs[i].Id);
      System.assertEquals(ncr.accAndConList[1].contactId, cs[i].Id);
      i++;
    }
  }

  /*
   *  複数名刺一括登録のケース
   *  名刺が姓のみが存在、責任者は姓だけ一致
   *  希望結果：検索されます
  */
  private static testMethod void testMultipleNameCardJustLast() {
    Test.startTest();
    NameCard__c n1 = new NameCard__c(Name = 'Test1',
                                     company_name__c = 'TestC1',
                                     person_name_last__c = 'TestL1'
                                     );
    NameCard__c n2 = new NameCard__c(Name = 'Test2',
                                     company_name__c = 'TestC2',
                                     person_name_last__c = 'TestL2'
                                     );
    insert new NameCard__c[]{n1, n2};

    Account a1 = new Account(Name = 'TestC1');
    Account a2 = new Account(Name = 'TestC2');
    insert new Account[]{a1, a2};

    Contact c1 = new Contact(LastName = 'TestL1', FirstName = 'TestFXX1', AccountId = a1.Id);
    Contact c2 = new Contact(LastName = 'TestL2', FirstName = 'TestFXX2', AccountId = a2.Id);
    Contact[] cs = new Contact[]{c1, c2};
    insert cs;
    Test.stopTest();
    ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(new NameCard__c[]{n1, n2});
    ssc.setSelected(new NameCard__c[]{n1, n2});
    SB_NameCard_AccountBulkRegistController ctrl = new SB_NameCard_AccountBulkRegistController(ssc);
    Integer i = 0;
    for (SB_NameCard_AccountBulkRegistController.NameCardRecord ncr : ctrl.nameCardTable) {
      System.debug(ncr.accAndConList[1].contactId);
      System.debug(cs[i].Id);
      System.assertEquals(ncr.accAndConList[1].contactId, cs[i].Id);
      i++;
    }
  }

  /*
   *  複数名刺一括登録のケース
   *  名刺が姓名が存在、責任者は姓だけ一致
   *  希望結果：検索されません
  */
  private static testMethod void testMultipleNameCardNotSearch() {
    Test.startTest();
    NameCard__c n1 = new NameCard__c(Name = 'Test1',
                                     company_name__c = 'TestC1',
                                     person_name_last__c = 'TestL1',
                                     person_name_first__c = 'TestF1');
    NameCard__c n2 = new NameCard__c(Name = 'Test2',
                                     company_name__c = 'TestC2',
                                     person_name_last__c = 'TestL2',
                                     person_name_first__c = 'TestF2');
    insert new NameCard__c[]{n1, n2};

    Account a1 = new Account(Name = 'TestC1');
    Account a2 = new Account(Name = 'TestC2');
    insert new Account[]{a1, a2};

    Contact c1 = new Contact(LastName = 'TestL1', FirstName = 'TestFXX1', AccountId = a1.Id);
    Contact c2 = new Contact(LastName = 'TestL2', FirstName = 'TestFXX2', AccountId = a2.Id);
    Contact[] cs = new Contact[]{c1, c2};
    insert cs;
    Test.stopTest();
    ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(new NameCard__c[]{n1, n2});
    ssc.setSelected(new NameCard__c[]{n1, n2});
    SB_NameCard_AccountBulkRegistController ctrl = new SB_NameCard_AccountBulkRegistController(ssc);
    Integer i = 0;
    for (SB_NameCard_AccountBulkRegistController.NameCardRecord ncr : ctrl.nameCardTable) {
      System.debug(ncr.accAndConList[1].contactId);
      System.debug(cs[i].Id);
      System.assertEquals(ncr.accAndConList[1].contactId, null);
      i++;
    }
  }

  /*
  * SV_DEV-591
  * 取引先・取引先責任者一括登録時の所有者について
  */
  private static testMethod void testUseNameCardOwner() {
    List<Profile> profiles = [Select Id From Profile Where Name IN ('System Administrator','システム管理者')];
    Profile p = profiles[0];
    Test.startTest();
    User testUser = new User(
                         alias = 'hogehoge',
                         email = 'smith@salesforce.com',
                         emailencodingkey = 'UTF-8',
                         lastname = 'smith',
                         languagelocalekey = 'en_US',
                         localesidkey = 'en_US',
                         profileid = p.Id,
                         timezonesidkey = 'America/Los_Angeles',
                         username = 'smith@salesforce.com.forsample'
                         );

    User testUser2 = new User(
                         alias = 'hogehoge',
                         email = 'smith@salesforce1.com',
                         emailencodingkey = 'UTF-8',
                         lastname = 'smith',
                         languagelocalekey = 'en_US',
                         localesidkey = 'en_US',
                         profileid = p.Id,
                         timezonesidkey = 'America/Los_Angeles',
                         username = 'smith1@salesforce.com.forsample'
                         );
    insert new User[]{testUser, testUser2};

    list<PermissionSet> psList = [SELECT Id FROM PermissionSet WHERE Name IN ('SmartViscaAdminUser','SmartViscaAdvancedUser','SmartViscaRenkeiUser','SmartViscaUser')];
    PermissionSetAssignment psa1 = new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = psList[0].Id);
    PermissionSetAssignment psa2 = new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = psList[1].Id);
    PermissionSetAssignment psa3 = new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = psList[2].Id);
    PermissionSetAssignment psa4 = new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = psList[3].Id);
    insert new PermissionSetAssignment[]{psa1,psa2,psa3,psa4};

    System.runAs(testUser) {
      setMappingDate1();
      NameCard__c n1 = new NameCard__c(Name = 'Test1',
                                   company_name__c = 'TestC1',
                                   person_name_last__c = 'TestL1',
                                   person_name_first__c = 'TestF1');

      insert new NameCard__c[]{n1};
      ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(new NameCard__c[]{n1});
      ssc.setSelected(new NameCard__c[]{n1});
      SB_NameCard_AccountBulkRegistController ctrl = new SB_NameCard_AccountBulkRegistController(ssc);
      ctrl.useNameCardOwner = true;
      System.assertEquals(ctrl.nameCardTable.size(), 1);
      for (SB_NameCard_AccountBulkRegistController.NameCardRecord ncr : ctrl.nameCardTable) {
        ncr.accAndCon = ncr.accAndConSelectOpts.size()-1;
        ncr.registTask = true;
      }
      ctrl.saveNC();
      Test.stopTest();
      List<Contact> cs = [Select Id, OwnerId From Contact];
      System.assertEquals(cs.size(), 1);
      System.assertEquals(cs[0].OwnerId, testUser.Id);
    }
  }

  /*
  * SV_DEV-591
  * 取引先・取引先責任者一括登録時の所有者について
  */
  private static testMethod void testUseNameCardOwner2() {
    List<Profile> profiles = [Select Id From Profile Where Name IN ('System Administrator','システム管理者')];
    Profile p = profiles[0];
    Test.startTest();
    User testUser = new User(
                         alias = 'hogehoge',
                         email = 'smith@salesforce.com',
                         emailencodingkey = 'UTF-8',
                         lastname = 'smith',
                         languagelocalekey = 'en_US',
                         localesidkey = 'en_US',
                         profileid = p.Id,
                         timezonesidkey = 'America/Los_Angeles',
                         username = 'smith@salesforce.com.forsample'
                         );

    User testUser2 = new User(
                         alias = 'hogehoge',
                         email = 'smith@salesforce1.com',
                         emailencodingkey = 'UTF-8',
                         lastname = 'smith',
                         languagelocalekey = 'en_US',
                         localesidkey = 'en_US',
                         profileid = p.Id,
                         timezonesidkey = 'America/Los_Angeles',
                         username = 'smith1@salesforce.com.forsample'
                         );
    insert new User[]{testUser, testUser2};

    list<PermissionSet> psList = [SELECT Id FROM PermissionSet WHERE Name IN ('SmartViscaAdminUser','SmartViscaAdvancedUser','SmartViscaRenkeiUser','SmartViscaUser')];
    PermissionSetAssignment psa1 = new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = psList[0].Id);
    PermissionSetAssignment psa2 = new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = psList[1].Id);
    PermissionSetAssignment psa3 = new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = psList[2].Id);
    PermissionSetAssignment psa4 = new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = psList[3].Id);
    insert new PermissionSetAssignment[]{psa1,psa2,psa3,psa4};

    System.runAs(testUser) {
      setMappingDate1();
      NameCard__c n1 = new NameCard__c(Name = 'Test1',
                                       company_name__c = 'TestC1',
                                       person_name_last__c = 'TestL1',
                                       person_name_first__c = 'TestF1');

      insert new NameCard__c[]{n1};
      ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(new NameCard__c[]{n1});
      ssc.setSelected(new NameCard__c[]{n1});
      SB_NameCard_AccountBulkRegistController ctrl = new SB_NameCard_AccountBulkRegistController(ssc);
      ctrl.owner.ownerId = testUser2.Id;
      ctrl.useNameCardOwner = true;
      System.assertEquals(ctrl.nameCardTable.size(), 1);
      for (SB_NameCard_AccountBulkRegistController.NameCardRecord ncr : ctrl.nameCardTable) {
        ncr.accAndCon = ncr.accAndConSelectOpts.size()-1;
        ncr.registTask = true;
      }
      ctrl.saveNC();
      Test.stopTest();
      List<Contact> cs = [Select Id, OwnerId From Contact];
      System.assertEquals(cs.size(), 1);
      System.assertEquals(cs[0].OwnerId, testUser.Id);
    }

  }

  /*
  * SV_DEV-591
  * 取引先・取引先責任者一括登録時の所有者について
  */
  private static testMethod void testNotUseNameCardOwner() {
    List<Profile> profiles = [Select Id From Profile Where Name IN ('System Administrator','システム管理者')];
    Profile p = profiles[0];
    Test.startTest();
    User testUser = new User(
                         alias = 'hogehoge',
                         email = 'smith@salesforce.com',
                         emailencodingkey = 'UTF-8',
                         lastname = 'smith',
                         languagelocalekey = 'en_US',
                         localesidkey = 'en_US',
                         profileid = p.Id,
                         timezonesidkey = 'America/Los_Angeles',
                         username = 'smith@salesforce.com.forsample'
                         );

    User testUser2 = new User(
                         alias = 'hogehoge',
                         email = 'smith@salesforce1.com',
                         emailencodingkey = 'UTF-8',
                         lastname = 'smith',
                         languagelocalekey = 'en_US',
                         localesidkey = 'en_US',
                         profileid = p.Id,
                         timezonesidkey = 'America/Los_Angeles',
                         username = 'smith1@salesforce.com.forsample'
                         );
    insert new User[]{testUser, testUser2};

    list<PermissionSet> psList = [SELECT Id FROM PermissionSet WHERE Name IN ('SmartViscaAdminUser','SmartViscaAdvancedUser','SmartViscaRenkeiUser','SmartViscaUser')];
    PermissionSetAssignment psa1 = new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = psList[0].Id);
    PermissionSetAssignment psa2 = new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = psList[1].Id);
    PermissionSetAssignment psa3 = new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = psList[2].Id);
    PermissionSetAssignment psa4 = new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = psList[3].Id);
    insert new PermissionSetAssignment[]{psa1,psa2,psa3,psa4};

    System.runAs(testUser) {
      setMappingDate1();
      NameCard__c n1 = new NameCard__c(Name = 'Test1',
                                       company_name__c = 'TestC1',
                                       person_name_last__c = 'TestL1',
                                       person_name_first__c = 'TestF1');

      insert new NameCard__c[]{n1};
      ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(new NameCard__c[]{n1});
      ssc.setSelected(new NameCard__c[]{n1});
      SB_NameCard_AccountBulkRegistController ctrl = new SB_NameCard_AccountBulkRegistController(ssc);
      ctrl.useNameCardOwner = false;
      System.assertEquals(ctrl.nameCardTable.size(), 1);
      for (SB_NameCard_AccountBulkRegistController.NameCardRecord ncr : ctrl.nameCardTable) {
        ncr.accAndCon = ncr.accAndConSelectOpts.size()-1;
        ncr.registTask = true;
      }
      ctrl.saveNC();
      Test.stopTest();
      List<Contact> cs = [Select Id, OwnerId From Contact];
      System.assertEquals(cs.size(), 0);
    }

  }

  /*
  * SV_DEV-591
  * 取引先・取引先責任者一括登録時の所有者について
  */
  private static testMethod void testNotUseNameCardOwner2() {
    List<Profile> profiles = [Select Id From Profile Where Name IN ('System Administrator','システム管理者')];
    Profile p = profiles[0];
    Test.startTest();
    User testUser = new User(
                         alias = 'hogehoge',
                         email = 'smith@salesforce.com',
                         emailencodingkey = 'UTF-8',
                         lastname = 'smith',
                         languagelocalekey = 'en_US',
                         localesidkey = 'en_US',
                         profileid = p.Id,
                         timezonesidkey = 'America/Los_Angeles',
                         username = 'smith@salesforce.com.forsample'
                         );

    User testUser2 = new User(
                         alias = 'hogehoge',
                         email = 'smith@salesforce1.com',
                         emailencodingkey = 'UTF-8',
                         lastname = 'smith',
                         languagelocalekey = 'en_US',
                         localesidkey = 'en_US',
                         profileid = p.Id,
                         timezonesidkey = 'America/Los_Angeles',
                         username = 'smith1@salesforce.com.forsample'
                         );
    insert new User[]{testUser, testUser2};

    list<PermissionSet> psList = [SELECT Id FROM PermissionSet WHERE Name IN ('SmartViscaAdminUser','SmartViscaAdvancedUser','SmartViscaRenkeiUser','SmartViscaUser')];
    PermissionSetAssignment psa1 = new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = psList[0].Id);
    PermissionSetAssignment psa2 = new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = psList[1].Id);
    PermissionSetAssignment psa3 = new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = psList[2].Id);
    PermissionSetAssignment psa4 = new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = psList[3].Id);
    insert new PermissionSetAssignment[]{psa1,psa2,psa3,psa4};

    System.runAs(testUser) {
      setMappingDate1();
      NameCard__c n1 = new NameCard__c(Name = 'Test1',
                                       company_name__c = 'TestC1',
                                       person_name_last__c = 'TestL1',
                                       person_name_first__c = 'TestF1');

      insert new NameCard__c[]{n1};
      ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(new NameCard__c[]{n1});
      ssc.setSelected(new NameCard__c[]{n1});
      SB_NameCard_AccountBulkRegistController ctrl = new SB_NameCard_AccountBulkRegistController(ssc);
      ctrl.owner.ownerId = testUser2.Id;
      ctrl.useNameCardOwner = false;
      System.assertEquals(ctrl.nameCardTable.size(), 1);
      for (SB_NameCard_AccountBulkRegistController.NameCardRecord ncr : ctrl.nameCardTable) {
        ncr.accAndCon = ncr.accAndConSelectOpts.size()-1;
        ncr.registTask = true;
      }
      ctrl.saveNC();
      Test.stopTest();
      List<Contact> cs = [Select Id, OwnerId From Contact];
      System.assertEquals(cs.size(), 1);
      System.assertEquals(cs[0].OwnerId, testUser2.Id);
    }

  }


  /**********************************************************************************/

  // SV_DEV-673 会社名に全角バックスラッシュが含まれる名刺を自動連携すると、ORA-01424エラーが発生
  // SV_DEV-684 部署名に全角バックスラッシュが含まれる名刺を自動連携すると、ORA-01424エラーが発生する
  // Start

  public static String ARECORDTYPEID = '';
  public static String CRECORDTYPEID = '';

  private static void setMappingDate1() {
    NameCardBasicSetting__c s = SB_NameCard_BasicSetting.getNameCardBasicSetting();
    if(String.isBlank(s.Id)){
        insert s;
    }
    String objname = SB_NameCard_RenkeiMapperUtil.getManagedObjectName('NameCardRenkeiMapping__c');
    List<RecordType> res = [SELECT Id,Name,Developername FROM RecordType WHERE SobjectType = :objname AND (Developername ='Account' OR Developername = 'Contact')];
    System.debug('resresres' + res);
    ARECORDTYPEID = res[0].Developername == 'Account' ? res[0].Id : res[1].Id;
    CRECORDTYPEID = res[0].Developername == 'Contact' ? res[0].Id : res[1].Id;

    String ar = SB_NameCard_RenkeiMappingLcController.changerecord('Account',ARECORDTYPEID);
    String cr = SB_NameCard_RenkeiMappingLcController.changerecord('Contact',CRECORDTYPEID);
    SB_NameCard_RenkeiMappingLcController.RecordTypedata lstFilters = new SB_NameCard_RenkeiMappingLcController.RecordTypedata();
    lstFilters = (SB_NameCard_RenkeiMappingLcController.RecordTypedata )System.JSON.deserializeStrict(ar,SB_NameCard_RenkeiMappingLcController.RecordTypedata .Class);
    String def1 = SB_NameCard_RenkeiMappingLcController.changetodefault('Account',lstFilters.obj2LabelNameMap,ARECORDTYPEID);
    SB_NameCard_RenkeiMappingLcController.Metadata def = new SB_NameCard_RenkeiMappingLcController.Metadata();
    def = (SB_NameCard_RenkeiMappingLcController.Metadata )System.JSON.deserializeStrict(def1,SB_NameCard_RenkeiMappingLcController.Metadata .Class);

    String savemsg = SB_NameCard_RenkeiMappingLcController.savemaps(JSON.serialize(def.mappingList),ARECORDTYPEID,'Account');

    SB_NameCard_RenkeiMappingLcController.RecordTypedata lstFilters1 = new SB_NameCard_RenkeiMappingLcController.RecordTypedata();
    lstFilters1 = (SB_NameCard_RenkeiMappingLcController.RecordTypedata )System.JSON.deserializeStrict(cr,SB_NameCard_RenkeiMappingLcController.RecordTypedata .Class);
    String def11 = SB_NameCard_RenkeiMappingLcController.changetodefault('Contact',lstFilters1.obj2LabelNameMap,CRECORDTYPEID);
    SB_NameCard_RenkeiMappingLcController.Metadata def22 = new SB_NameCard_RenkeiMappingLcController.Metadata();
    def22 = (SB_NameCard_RenkeiMappingLcController.Metadata )System.JSON.deserializeStrict(def11,SB_NameCard_RenkeiMappingLcController.Metadata .Class);
    String savemsg1 = SB_NameCard_RenkeiMappingLcController.savemaps(JSON.serialize(def22.mappingList),CRECORDTYPEID,'Contact');

  }

  public static void setBasic(){
    NameCardBasicSetting__c result = new NameCardBasicSetting__c(
      RenkeiActive__c = false,      // 自動連携機能有効
      RenkeiAccountAddressPref__c = false,   // アカウント 都道府県
      RenkeiAccount_Street__c = false,   // アカウント 町名・番地
      RenkeiAccountZipCode__c = false,   // アカウント 郵便番号
      RenkeiAccountCity__c = false,      // アカウント 市区郡
      RenkeiAccountURL__c = false,       // アカウント URL
      RenkeiAccountCompany__c = true,   // アカウント 会社名
      RenkeiAccountPhone__c = false,     // アカウント 電話番号
      RenkeiSpecificItems__c = null,        // アカウント 特定項目
      RenkeiAccountSite__c = false,        // アカウント 部署名
      RenkeiExcludeHojinkakuPartial__c = true,      // 自動連携:会社名は法人格を除いて部分一致
      RenkeiExcludeHojinkaku__c = false,      // 自動連携:会社名は法人格を除いて完全一致
      RenkeiAccountSitePartialMatch__c = true,      // 自動連携:部署は中間一致検索
      RenkeiContactMail__c = true,      // コンタクト メールアドレス
      RenkeiContactLastName__c = true,  // コンタクト ラストネーム
      RenkeiContactFirstName__c = true, // コンタクト ファーストネーム
      RenkeiAccountQueryRecordTypeIds__c = null,    // 検索対象のレコードタイプタイプID カンマ区切り で羅列
      RenkeiContactQueryRecordTypeIds__c = null,  // 自動連携で検索対象の取引先責任者レコードタイプ
      RenkeiAccountOverwrite__c = false,   // 既存の取引先を上書き  上書きしない!
      RenkeiContactOverwrite__c = false,   // 既存の取引先責任者を上書き  上書きしない!
      RenkeiAccountNOExistCreateNew__c = true,  //既存の取引先がなければ新規作成する
      RenkeiContactNOExistCreateNew__c = true,  // 既存の取引先責任者がなければ新規作成する
      RenkeiAccountRecordTypes__c = null,     // 作成するアカウント の レコードタイプID １つ
      RenkeiContactRecordTypes__c = null,      // 作成するコンタクト の レコードタイプID １つ
      SaishinInheritValues__c = false,          //最新名刺は値を引継ぐ
      RegistToDoSubject__c = Label.SB_NC_ExchangeCard, // 取引先・取引先任者に登録 ToDo件名
      RegistNoToDo__c = false, // 取引先・取引先任者に登録 ToDo登録しない
      RegistDispOverWriteCheckbox__c = true, // 取引先・取引先任者に登録 「上書きする」チェックボックスを表示する
      RegistDispAccountRectype__c = true, // 取引先・取引先任者に登録 取引先レコードタイプ選択を表示する
      RegistAccountNotOverWrite__c = false, // 取引先・取引先任者に登録 取引先を名刺情報で上書きしない
      RegistDispContactRectype__c = true, // 取引先・取引先任者に登録 取引先責任者レコードタイプ選択を表示する
      RegistContactNotOverWrite__c = false // 取引先・取引先任者に登録 取引先責任者を名刺情報で上書きしない
    );
    insert result;
  }

  private static NameCard__c setNameCard(String name,String div , String Last, String First) {
    NameCard__c nc = new NameCard__c();
    nc.Name = 'Test';
    nc.person_name_last__c = Last;
    nc.person_name_first__c = First;
    nc.company_name__c = name;
    nc.company_name_kana__c = 'カブシキガイシャサンブリッジ';
    nc.division__c = div;
    nc.card_exchange_date__c = Date.today();
    insert(nc);

    Account ac = new Account();
    ac.Name = 'aa' + name + 'cc';
    ac.Site = 'aa' + div + 'cc';
    insert ac;

    Contact c = new Contact();
    c.LastName = Last;
    c.FirstName = First;
    c.AccountId = ac.Id;
    c.Department = 'aa' + div + 'cc';
    insert c;
    return nc;
  }

  private static User setRunUser() {
    List<Profile> profiles = [Select Id From Profile Where Name IN ('System Administrator','システム管理者')];
    Profile p = profiles[0];
    User testUser = new User(
                         alias = 'hogehoge',
                         email = 'smith@salesforce.com',
                         emailencodingkey = 'UTF-8',
                         lastname = 'smith',
                         languagelocalekey = 'en_US',
                         localesidkey = 'en_US',
                         profileid = p.Id,
                         timezonesidkey = 'America/Los_Angeles',
                         username = 'smith@salesforce.com.forsample'
                         );
    insert new User[]{testUser};

    list<PermissionSet> psList = [SELECT Id FROM PermissionSet WHERE Name IN ('SmartViscaAdminUser','SmartViscaAdvancedUser','SmartViscaRenkeiUser','SmartViscaUser')];
    PermissionSetAssignment psa1 = new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = psList[0].Id);
    PermissionSetAssignment psa2 = new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = psList[1].Id);
    PermissionSetAssignment psa3 = new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = psList[2].Id);
    PermissionSetAssignment psa4 = new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = psList[3].Id);
    insert new PermissionSetAssignment[]{psa1,psa2,psa3,psa4};

    return testUser;
  }

  // 全角バックスラッシュ
  private static testMethod void testBackSlash() {
    User testUser = setRunUser();
    System.runAs(testUser) {
      setBasic();
      setMappingDate1();
      NameCard__c nc = setNameCard('HOGEHOGE＼FUGAFUGA', 'div＼ision', 'La＼st', 'Fi＼rst');
      ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(new NameCard__c[]{nc});
      ssc.setSelected(new NameCard__c[]{nc});
      SB_NameCard_AccountBulkRegistController ctrl = new SB_NameCard_AccountBulkRegistController(ssc);
      for (SB_NameCard_AccountBulkRegistController.NameCardRecord ncr : ctrl.nameCardTable) {
        System.assertEquals(ncr.accAndConSelectOpts.size(), 4);
      }
    }
  }

  // 半角バックスラッシュ 1個
  private static testMethod void testBackSlashH1() {
    User testUser = setRunUser();
    System.runAs(testUser) {
      setBasic();
      setMappingDate1();
      NameCard__c nc = setNameCard('HOGEHOGE\\FUGAFUGA', 'div\\ision', 'La\\st', 'Fi\\rst');

      ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(new NameCard__c[]{nc});
      ssc.setSelected(new NameCard__c[]{nc});
      SB_NameCard_AccountBulkRegistController ctrl = new SB_NameCard_AccountBulkRegistController(ssc);
      for (SB_NameCard_AccountBulkRegistController.NameCardRecord ncr : ctrl.nameCardTable) {
          System.assertEquals(ncr.accAndConSelectOpts.size(), 4);
      }
    }
  }

  // 半角バックスラッシュ 2個
  private static testMethod void testBackSlashH2() {
    User testUser = setRunUser();
    System.runAs(testUser) {
      setBasic();
      setMappingDate1();
      NameCard__c nc = setNameCard('HOGEHOGE\\\\FUGAFUGA', 'div\\\\ision', 'La\\\\st', 'Fi\\\\rst');

      ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(new NameCard__c[]{nc});
      ssc.setSelected(new NameCard__c[]{nc});
      SB_NameCard_AccountBulkRegistController ctrl = new SB_NameCard_AccountBulkRegistController(ssc);
      for (SB_NameCard_AccountBulkRegistController.NameCardRecord ncr : ctrl.nameCardTable) {
        System.assertEquals(ncr.accAndConSelectOpts.size(), 4);
      }
    }
  }

  // シングルクオート
  private static testMethod void testSingleQuote() {
    User testUser = setRunUser();
    System.runAs(testUser) {
      setBasic();
      setMappingDate1();
      NameCard__c nc = setNameCard('HOGEHOGE\'FUGAFUGA', 'div\'ision', 'La\'st', 'Fi\'rst');

      ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(new NameCard__c[]{nc});
      ssc.setSelected(new NameCard__c[]{nc});
      SB_NameCard_AccountBulkRegistController ctrl = new SB_NameCard_AccountBulkRegistController(ssc);
      for (SB_NameCard_AccountBulkRegistController.NameCardRecord ncr : ctrl.nameCardTable) {
        System.assertEquals(ncr.accAndConSelectOpts.size(), 4);
      }
    }
  }


  // SV_DEV-673 会社名に全角バックスラッシュが含まれる名刺を自動連携すると、ORA-01424エラーが発生
  // End
  /**********************************************************************************/
}