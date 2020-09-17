/*  $Id: SB_NameCard_AccountRegistControllerTest.cls 13 2013-10-22 10:56:25Z ume $  */
/*
 * SB_NameCard_AccountRegistControllerTest
 * 名刺情報から取引先・取引先責任者の登録
 *
 * Copyright (c) 2011-2019 SunBridge
 * @author gao
 * @Version 1.20.4      2017.11.xx  SV_DEV-673 会社名に全角バックスラッシュが含まれる名刺を自動連携すると、ORA-01424エラーが発生
 * @Version 1.22        2017.11.XX SV_DEV-684  部署名に全角バックスラッシュが含まれる名刺を自動連携すると、ORA-01424エラーが発生する
 * @Version 2.2    sawano   2019.03.XX 2.1.1 パッチで で2019.02 コードスキャンをパス → セキュリティレビュー更新 2.2へ反映
 * @Version 2.4       2019.05.XX  SV_DEV-1630と合わせてリファクタリングを実施
 */
@isTest
private with sharing class SB_NameCard_AccountRegistControllerTest {
  public static String ARECORDTYPEID = '';
  public static String CRECORDTYPEID = '';

  private static void setMappingDate() {
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


  //     insert testmapplist;
  // }
  private static testMethod void testAll() {
    setMappingDate();
    NameCard__c nc = new NameCard__c();
    nc.company_name__c = '株式会社サンブリッジ';
    nc.company_name_kana__c = 'カブシキガイシャサンブリッジ';
    nc.division__c = 'テスト部署';
    nc.person_name_last__c = 'テスト姓';
    nc.person_name_first__c = 'テスト名';
    nc.email__c = 'test@sb.example.com';
    nc.card_exchange_date__c = Date.today();
    insert(nc);

    Task t1 = new Task();
    t1.OwnerId = UserInfo.getUserId();
    t1.Subject = 'todo1';
    t1.WhatId = nc.Id;
    insert(t1);

    Event e1 = new Event();
    e1.OwnerId = UserInfo.getUserId();
    e1.Subject = 'event1';
    e1.WhatId = nc.Id;
    e1.StartDateTime = Datetime.now().addHours(3);
    e1.EndDateTime = Datetime.now().addHours(5);
    insert(e1);

    PageReference pageRef = Page.SB_NameCard_AccountRegist;
    Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('id', nc.Id);
    SB_NameCard_AccountRegistController ctrl = new SB_NameCard_AccountRegistController();
    //ctrl.getAcntRecTypeSelectOpts();
    //ctrl.getContRecTypeSelectOpts();
    ctrl.accountTableIndex = ctrl.accountTable.size() - 1;

    ctrl.todo.Subject = 'test Subject';
    ctrl.todo.ActivityDate = Date.today().addDays(1);
    ctrl.registTodo = true;

    // 保存
    String nextPage = ctrl.save().getUrl();

    nc = [SELECT Id, account__c, contact__c, company_name__c, division__c,
        person_name_last__c, person_name_first__c, email__c
        FROM NameCard__c WHERE Id = :nc.Id];

    System.assertNotEquals(null, nc.contact__c);
    System.assertEquals('/' + nc.contact__c, nextPage);

    Contact c = [SELECT Id, AccountId FROM Contact WHERE Id = :nc.contact__c];
    Account acc = [SELECT Id FROM Account WHERE Id = :nc.account__c];

    System.assertNotEquals(null, c);
    System.assertNotEquals(null, acc);

    List<Task> tList1 = [SELECT ActivityDate, Status, Subject FROM Task WHERE WhoId = :c.Id AND Subject = :'test Subject'];
    System.debug('sizeis' + tList1.size());
    System.assertEquals(1, tList1.size());
    System.assertEquals(Date.today().addDays(1), tList1[0].ActivityDate);

    List<Task> tList2 = [SELECT WhoId FROM Task WHERE WhatId = :nc.Id ];
    System.assertNotEquals(0, tList2.size());
    System.assertEquals(c.Id, tList2[0].WhoId);

    List<Event> eList = [SELECT WhoId FROM Event WHERE WhatId = :nc.Id ];
    System.assertNotEquals(0, eList.size());
    System.assertEquals(c.Id, eList[0].WhoId);

    //重複管理
    pageRef = Page.SB_NameCard_AccountRegist;
    Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('id', nc.Id);
    ApexPages.currentPage().getParameters().put('debug', 'true');  // v2.1.1 2019.02.19 これがないと System.assertEquals(null, ctrl.save()); にならないよね ?
    ctrl = new SB_NameCard_AccountRegistController();
    ctrl.accountTableIndex = ctrl.accountTable.size() - 1;

    ctrl.todo.Subject = 'test Subject';
    ctrl.todo.ActivityDate = Date.today().addDays(1);

    // 保存
    //nextPage = ctrl.save().getUrl();
    System.assertEquals(null, ctrl.save());

    // キャンセル
    nextPage = ctrl.cancel().getUrl();
    System.assertEquals('/' + nc.Id, nextPage);

    ApexPages.currentPage().getParameters().put('debug', 'false');  // v2.1.1 2019.02.19 これがないと System.assertEquals('/' + nc.contact__c, nextPage); にならないよね ?
    ctrl = new SB_NameCard_AccountRegistController();
    ctrl.accountTableIndex = 0;

    // 保存
    nextPage = ctrl.save().getUrl();
    System.assertEquals('/' + nc.contact__c, nextPage);
    ctrl.getContRecTypeSelectOpts();
    ctrl.getAccRecTypeSelectOpts();
  }

  /******************************************************************************** **/

  // SV_DEV-673 会社名に全角バックスラッシュが含まれる名刺を自動連携すると、ORA-01424エラーが発生
  // SV_DEV-684 部署名に全角バックスラッシュが含まれる名刺を自動連携すると、ORA-01424エラーが発生する
  // Start

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
    return testUser;
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
    ac.Name = 'aa' + name + 'bb';
    ac.Site = 'ss' + div + 'bb';
    insert ac;

    // v2.4 SOSL 検索になったので、固定された検索結果のリストを、テストメソッドで後続のすべての SOSL ステートメントに返されるよう定義します。
    Test.setFixedSearchResults(new Id[] { ac.Id });

    Contact c = new Contact();
    c.LastName = Last;
    c.FirstName = First;
    c.AccountId = ac.Id;
    c.Department = 'ss' + div + 'bb';
    insert c;
    return nc;
  }


  // 全角バックスラッシュ
  private static testMethod void testBackSlash() {
    User testUser = setRunUser();
    System.runAs(testUser) {
      setBasic();
      setMappingDate();
      NameCard__c nc = setNameCard('HOGEHOGE＼FUGAFUGA', 'div＼ision', 'La＼st', 'Fi＼rst');

      PageReference pageRef = Page.SB_NameCard_AccountRegist;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put('id', nc.Id);
      SB_NameCard_AccountRegistController ctrl = new SB_NameCard_AccountRegistController();
      System.assertEquals(ctrl.accountTable.size(), 5);
    }
  }

  // 半角バックスラッシュ 1個
  private static testMethod void testBackSlashH1() {
    User testUser = setRunUser();
    System.runAs(testUser) {
      setBasic();
      setMappingDate();
      NameCard__c nc = setNameCard('HOGEHOGE\\FUGAFUGA', 'div\\ision', 'La\\st', 'Fi\\rst');

      PageReference pageRef = Page.SB_NameCard_AccountRegist;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put('id', nc.Id);
      SB_NameCard_AccountRegistController ctrl = new SB_NameCard_AccountRegistController();
      System.assertEquals(ctrl.accountTable.size(), 5);
    }
  }

  // 半角バックスラッシュ 2個
  private static testMethod void testBackSlashH2() {
    User testUser = setRunUser();
    System.runAs(testUser) {
      setBasic();
      setMappingDate();
      NameCard__c nc = setNameCard('HOGEHOGE\\\\FUGAFUGA', 'div\\\\ision', 'La\\\\st', 'Fi\\\\rst');

      PageReference pageRef = Page.SB_NameCard_AccountRegist;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put('id', nc.Id);
      SB_NameCard_AccountRegistController ctrl = new SB_NameCard_AccountRegistController();
      System.assertEquals(ctrl.accountTable.size(), 5);
    }
  }

  // シングルクオート
  private static testMethod void testSingleQuote() {
    User testUser = setRunUser();
    System.runAs(testUser) {
      setBasic();
      setMappingDate();
      NameCard__c nc = setNameCard('HOGEHOGE\'FUGAFUGA', 'div\'ision', 'La\'st', 'Fi\'rst');

      PageReference pageRef = Page.SB_NameCard_AccountRegist;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put('id', nc.Id);
      SB_NameCard_AccountRegistController ctrl = new SB_NameCard_AccountRegistController();
      System.assertEquals(ctrl.accountTable.size(), 5);
    }
  }

  // SV_DEV-673 会社名に全角バックスラッシュが含まれる名刺を自動連携すると、ORA-01424エラーが発生
  // End
  /**********************************************************************************/
}