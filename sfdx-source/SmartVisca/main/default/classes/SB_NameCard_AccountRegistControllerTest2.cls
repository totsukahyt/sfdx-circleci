/*
 * ツールパッケージ用拡張バージョン
 *  SB_NameCard_AccountRegistControllerTest2
 *    LDV対応取引先登録拡張パッケージでの SB_SmartViscaRgq_AccountRegistCTest
 * 
 * @Version 1      2018.01.xx
 * @Version 2.7 　 2020.09.08 ohno   PRODUCT-696 取引先登録 個別・一括 メールアドレスが空白値で一致して登録先候補が表示されてしまう。（姓・名が異なるレコードが表示される）
 * @author  kou
 *
 * 名刺情報から取引先・取引先責任者の登録テストクラス
 *
 */
@isTest
private with sharing class SB_NameCard_AccountRegistControllerTest2
{

  private static void setMappingData() {
    NameCardBasicSetting__c s = SB_NameCard_BasicSetting.getNameCardBasicSetting();
    if(String.isBlank(s.Id)){
        insert s;
    }
    String objname = SB_NameCard_RenkeiMapperUtil.getManagedObjectName('NameCardRenkeiMapping__c');
    List<RecordType> res = [SELECT Id,Name,Developername FROM RecordType WHERE SobjectType = :objname AND (Developername ='Account' OR Developername = 'Contact')];
    System.debug('resresres' + res);
    String ARECORDTYPEID = res[0].Developername == 'Account' ? res[0].Id : res[1].Id;
    String CRECORDTYPEID = res[0].Developername == 'Contact' ? res[0].Id : res[1].Id;

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

  private static testMethod void testAll()
  {
    setMappingData();
    NameCard__c nc = new NameCard__c  ();
    nc.company_name__c  = '株式会社サンブリッジ';
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

    nc = [SELECT Id, account__c, contact__c, company_name__c   , division__c,
        person_name_last__c, person_name_first__c, email__c
        FROM NameCard__c    WHERE Id = :nc.Id];

    System.assertNotEquals(null, nc.contact__c);
    System.assertEquals('/' + nc.contact__c, nextPage);

    Contact c = [SELECT Id, AccountId FROM Contact WHERE Id = :nc.contact__c];
    Account acc = [SELECT Id FROM Account WHERE Id = :nc.account__c];

    System.assertNotEquals(null, c);
    System.assertNotEquals(null, acc);

    List<Task> tList1 = [SELECT ActivityDate, Status, Subject FROM Task WHERE WhoId = :c.Id AND Subject = :'test Subject'];
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
    ctrl = new SB_NameCard_AccountRegistController();
    ctrl.accountTableIndex = ctrl.accountTable.size() - 1;

    ctrl.todo.Subject = 'test Subject';
    ctrl.todo.ActivityDate = Date.today().addDays(1);

    // 保存
    //nextPage = ctrl.save().getUrl();
    // System.assertEquals(null, ctrl.save());

    // キャンセル
    nextPage = ctrl.cancel().getUrl();
    System.assertEquals('/' + nc.Id, nextPage);

    ctrl = new SB_NameCard_AccountRegistController();
    ctrl.accountTableIndex = 0;

    // 保存
    nextPage = ctrl.save().getUrl();
    System.assertEquals('/' + nc.contact__c, nextPage);
  }

  private static User setRunUser() {
    List<Profile> profiles = [Select Id From Profile Where Name IN ('System Administrator','システム管理者')];
    Profile p = profiles[0];
    User testUser = new User(
                         alias = 'hogehoge',
                         email = 'test_u@sunbridge.com',
                         emailencodingkey = 'UTF-8',
                         lastname = 'smith',
                         languagelocalekey = 'en_US',
                         localesidkey = 'en_US',
                         profileid = p.Id,
                         timezonesidkey = 'America/Los_Angeles',
                         username = 'test_u@sunbridge.com.forsample'
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
      NameCard__c nc = setNameCard('HOGEHOGE＼FUGAFUGA', 'div＼ision', 'La＼st', 'Fi＼rst');

      PageReference pageRef = Page.SB_NameCard_AccountRegist;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put('id', nc.Id);
      ApexPages.currentPage().getParameters().put('searchMethod', '0');
      List<Account> ac = [Select Id From Account];
      System.assertEquals(ac.size(), 1);
      Id [] fixedSearchResults= new Id[1];
      fixedSearchResults[0] = ac[0].Id;
      Test.setFixedSearchResults(fixedSearchResults);
      SB_NameCard_AccountRegistController ctrl = new SB_NameCard_AccountRegistController();
      System.assertEquals(ctrl.accountTable.size(), 5);
    }
  }

  // 半角バックスラッシュ 1個
  private static testMethod void testBackSlashH1() {
    User testUser = setRunUser();
    System.runAs(testUser) {
      NameCard__c nc = setNameCard('HOGEHOGE\\FUGAFUGA', 'div\\ision', 'La\\st', 'Fi\\rst');

      PageReference pageRef = Page.SB_NameCard_AccountRegist;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put('id', nc.Id);
      ApexPages.currentPage().getParameters().put('searchMethod', '0');
      List<Account> ac = [Select Id From Account];
      System.assertEquals(ac.size(), 1);
      Id [] fixedSearchResults= new Id[1];
      fixedSearchResults[0] = ac[0].Id;
      Test.setFixedSearchResults(fixedSearchResults);
      SB_NameCard_AccountRegistController ctrl = new SB_NameCard_AccountRegistController();
      System.assertEquals(ctrl.accountTable.size(), 5);
    }
  }

  // 半角バックスラッシュ 2個
  private static testMethod void testBackSlashH2() {
    User testUser = setRunUser();
    System.runAs(testUser) {
      NameCard__c nc = setNameCard('HOGEHOGE\\\\FUGAFUGA', 'div\\\\ision', 'La\\\\st', 'Fi\\\\rst');

      PageReference pageRef = Page.SB_NameCard_AccountRegist;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put('id', nc.Id);
      ApexPages.currentPage().getParameters().put('searchMethod', '0');
      List<Account> ac = [Select Id From Account];
      System.assertEquals(ac.size(), 1);
      Id [] fixedSearchResults= new Id[1];
      fixedSearchResults[0] = ac[0].Id;
      Test.setFixedSearchResults(fixedSearchResults);
      SB_NameCard_AccountRegistController ctrl = new SB_NameCard_AccountRegistController();
      System.assertEquals(ctrl.accountTable.size(), 5);
    }
  }

  // シングルクオート
  private static testMethod void testSingleQuote() {
    User testUser = setRunUser();
    System.runAs(testUser) {
      NameCard__c nc = setNameCard('HOGEHOGE\'FUGAFUGA', 'div\'ision', 'La\'st', 'Fi\'rst');

      PageReference pageRef = Page.SB_NameCard_AccountRegist;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put('id', nc.Id);
      ApexPages.currentPage().getParameters().put('searchMethod', '0');
      List<Account> ac = [Select Id From Account];
      System.assertEquals(ac.size(), 1);
      Id [] fixedSearchResults= new Id[1];
      fixedSearchResults[0] = ac[0].Id;
      Test.setFixedSearchResults(fixedSearchResults);
      SB_NameCard_AccountRegistController ctrl = new SB_NameCard_AccountRegistController();
      System.assertEquals(ctrl.accountTable.size(), 5);
    }
  }

  // 全角バックスラッシュ
  private static testMethod void testBackSlash1() {
    User testUser = setRunUser();
    System.runAs(testUser) {
      NameCard__c nc = setNameCard('HOGEHOGE＼FUGAFUGA', 'div＼ision', 'La＼st', 'Fi＼rst');

      PageReference pageRef = Page.SB_NameCard_AccountRegist;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put('id', nc.Id);
      ApexPages.currentPage().getParameters().put('searchMethod', '1');
      List<Account> ac = [Select Id From Account];
      System.assertEquals(ac.size(), 1);
      Id [] fixedSearchResults= new Id[1];
      fixedSearchResults[0] = ac[0].Id;
      Test.setFixedSearchResults(fixedSearchResults);
      SB_NameCard_AccountRegistController ctrl = new SB_NameCard_AccountRegistController();
      System.assertEquals(ctrl.accountTable.size(), 5);
    }
  }

  // 半角バックスラッシュ 1個
  private static testMethod void testBackSlashH11() {
    User testUser = setRunUser();
    System.runAs(testUser) {
      NameCard__c nc = setNameCard('HOGEHOGE\\FUGAFUGA', 'div\\ision', 'La\\st', 'Fi\\rst');

      PageReference pageRef = Page.SB_NameCard_AccountRegist;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put('id', nc.Id);
      ApexPages.currentPage().getParameters().put('searchMethod', '1');
      List<Account> ac = [Select Id From Account];
      System.assertEquals(ac.size(), 1);
      Id [] fixedSearchResults= new Id[1];
      fixedSearchResults[0] = ac[0].Id;
      Test.setFixedSearchResults(fixedSearchResults);
      SB_NameCard_AccountRegistController ctrl = new SB_NameCard_AccountRegistController();
      System.assertEquals(ctrl.accountTable.size(), 5);
    }
  }

  // 半角バックスラッシュ 2個
  private static testMethod void testBackSlashH21() {
    User testUser = setRunUser();
    System.runAs(testUser) {
      NameCard__c nc = setNameCard('HOGEHOGE\\\\FUGAFUGA', 'div\\\\ision', 'La\\\\st', 'Fi\\\\rst');

      PageReference pageRef = Page.SB_NameCard_AccountRegist;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put('id', nc.Id);
      ApexPages.currentPage().getParameters().put('searchMethod', '1');
      List<Account> ac = [Select Id From Account];
      System.assertEquals(ac.size(), 1);
      Id [] fixedSearchResults= new Id[1];
      fixedSearchResults[0] = ac[0].Id;
      Test.setFixedSearchResults(fixedSearchResults);
      SB_NameCard_AccountRegistController ctrl = new SB_NameCard_AccountRegistController();
      System.assertEquals(ctrl.accountTable.size(), 5);
    }
  }

  // シングルクオート
  private static testMethod void testSingleQuote1() {
    User testUser = setRunUser();
    System.runAs(testUser) {
      NameCard__c nc = setNameCard('HOGEHOGE\'FUGAFUGA', 'div\'ision', 'La\'st', 'Fi\'rst');

      PageReference pageRef = Page.SB_NameCard_AccountRegist;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put('id', nc.Id);
      ApexPages.currentPage().getParameters().put('searchMethod', '1');
      List<Account> ac = [Select Id From Account];
      System.assertEquals(ac.size(), 1);
      Id [] fixedSearchResults= new Id[1];
      fixedSearchResults[0] = ac[0].Id;
      Test.setFixedSearchResults(fixedSearchResults);
      SB_NameCard_AccountRegistController ctrl = new SB_NameCard_AccountRegistController();
      System.assertEquals(ctrl.accountTable.size(), 5);
    }
  }

  // 全角バックスラッシュ
  private static testMethod void testBackSlash2() {
    User testUser = setRunUser();
    System.runAs(testUser) {
      NameCard__c nc = setNameCard('HOGEHOGE＼FUGAFUGA', 'div＼ision', 'La＼st', 'Fi＼rst');

      PageReference pageRef = Page.SB_NameCard_AccountRegist;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put('id', nc.Id);
      ApexPages.currentPage().getParameters().put('searchMethod', '2');
      List<Account> ac = [Select Id From Account];
      System.assertEquals(ac.size(), 1);
      Id [] fixedSearchResults= new Id[1];
      fixedSearchResults[0] = ac[0].Id;
      Test.setFixedSearchResults(fixedSearchResults);
      SB_NameCard_AccountRegistController ctrl = new SB_NameCard_AccountRegistController();
      System.assertEquals(ctrl.accountTable.size(), 5);
    }
  }

  // 半角バックスラッシュ 1個
  private static testMethod void testBackSlashH12() {
    User testUser = setRunUser();
    System.runAs(testUser) {
      NameCard__c nc = setNameCard('HOGEHOGE\\FUGAFUGA', 'div\\ision', 'La\\st', 'Fi\\rst');

      PageReference pageRef = Page.SB_NameCard_AccountRegist;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put('id', nc.Id);
      ApexPages.currentPage().getParameters().put('searchMethod', '2');
      List<Account> ac = [Select Id From Account];
      System.assertEquals(ac.size(), 1);
      Id [] fixedSearchResults= new Id[1];
      fixedSearchResults[0] = ac[0].Id;
      Test.setFixedSearchResults(fixedSearchResults);
      SB_NameCard_AccountRegistController ctrl = new SB_NameCard_AccountRegistController();
      System.assertEquals(ctrl.accountTable.size(), 5);
    }
  }

  // 半角バックスラッシュ 2個
  private static testMethod void testBackSlashH22() {
    User testUser = setRunUser();
    System.runAs(testUser) {
      NameCard__c nc = setNameCard('HOGEHOGE\\\\FUGAFUGA', 'div\\\\ision', 'La\\\\st', 'Fi\\\\rst');

      PageReference pageRef = Page.SB_NameCard_AccountRegist;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put('id', nc.Id);
      ApexPages.currentPage().getParameters().put('searchMethod', '2');
      List<Account> ac = [Select Id From Account];
      System.assertEquals(ac.size(), 1);
      Id [] fixedSearchResults= new Id[1];
      fixedSearchResults[0] = ac[0].Id;
      Test.setFixedSearchResults(fixedSearchResults);
      SB_NameCard_AccountRegistController ctrl = new SB_NameCard_AccountRegistController();
      System.assertEquals(ctrl.accountTable.size(), 5);
    }
  }

  // シングルクオート
  private static testMethod void testSingleQuote2() {
    User testUser = setRunUser();
    System.runAs(testUser) {
      NameCard__c nc = setNameCard('HOGEHOGE\'FUGAFUGA', 'div\'ision', 'La\'st', 'Fi\'rst');

      PageReference pageRef = Page.SB_NameCard_AccountRegist;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put('id', nc.Id);
      ApexPages.currentPage().getParameters().put('searchMethod', '2');
      List<Account> ac = [Select Id From Account];
      System.assertEquals(ac.size(), 1);
      Id [] fixedSearchResults= new Id[1];
      fixedSearchResults[0] = ac[0].Id;
      Test.setFixedSearchResults(fixedSearchResults);
      SB_NameCard_AccountRegistController ctrl = new SB_NameCard_AccountRegistController();
      System.assertEquals(ctrl.accountTable.size(), 5);
    }
  }

  // 全角バックスラッシュ
  private static testMethod void testBackSlash3() {
    User testUser = setRunUser();
    System.runAs(testUser) {
      NameCard__c nc = setNameCard('HOGEHOGE＼FUGAFUGA', 'div＼ision', 'La＼st', 'Fi＼rst');

      PageReference pageRef = Page.SB_NameCard_AccountRegist;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put('id', nc.Id);
      ApexPages.currentPage().getParameters().put('searchMethod', '3');
      List<Account> ac = [Select Id From Account];
      System.assertEquals(ac.size(), 1);
      Id [] fixedSearchResults= new Id[1];
      fixedSearchResults[0] = ac[0].Id;
      Test.setFixedSearchResults(fixedSearchResults);
      SB_NameCard_AccountRegistController ctrl = new SB_NameCard_AccountRegistController();
      System.assertEquals(ctrl.accountTable.size(), 5);
    }
  }

  // 半角バックスラッシュ 1個
  private static testMethod void testBackSlashH13() {
    User testUser = setRunUser();
    System.runAs(testUser) {
      NameCard__c nc = setNameCard('HOGEHOGE\\FUGAFUGA', 'div\\ision', 'La\\st', 'Fi\\rst');

      PageReference pageRef = Page.SB_NameCard_AccountRegist;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put('id', nc.Id);
      ApexPages.currentPage().getParameters().put('searchMethod', '3');
      List<Account> ac = [Select Id From Account];
      System.assertEquals(ac.size(), 1);
      Id [] fixedSearchResults= new Id[1];
      fixedSearchResults[0] = ac[0].Id;
      Test.setFixedSearchResults(fixedSearchResults);
      SB_NameCard_AccountRegistController ctrl = new SB_NameCard_AccountRegistController();
      System.assertEquals(ctrl.accountTable.size(), 5);
    }
  }

  // 半角バックスラッシュ 2個
  private static testMethod void testBackSlashH23() {
    User testUser = setRunUser();
    System.runAs(testUser) {
      NameCard__c nc = setNameCard('HOGEHOGE\\\\FUGAFUGA', 'div\\\\ision', 'La\\\\st', 'Fi\\\\rst');

      PageReference pageRef = Page.SB_NameCard_AccountRegist;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put('id', nc.Id);
      ApexPages.currentPage().getParameters().put('searchMethod', '3');
      List<Account> ac = [Select Id From Account];
      System.assertEquals(ac.size(), 1);
      Id [] fixedSearchResults= new Id[1];
      fixedSearchResults[0] = ac[0].Id;
      Test.setFixedSearchResults(fixedSearchResults);
      SB_NameCard_AccountRegistController ctrl = new SB_NameCard_AccountRegistController();
      System.assertEquals(ctrl.accountTable.size(), 5);
    }
  }

  // シングルクオート
  private static testMethod void testSingleQuote3() {
    User testUser = setRunUser();
    System.runAs(testUser) {
      NameCard__c nc = setNameCard('HOGEHOGE\'FUGAFUGA', 'div\'ision', 'La\'st', 'Fi\'rst');

      PageReference pageRef = Page.SB_NameCard_AccountRegist;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put('id', nc.Id);
      ApexPages.currentPage().getParameters().put('searchMethod', '3');
      List<Account> ac = [Select Id From Account];
      System.assertEquals(ac.size(), 1);
      Id [] fixedSearchResults= new Id[1];
      fixedSearchResults[0] = ac[0].Id;
      Test.setFixedSearchResults(fixedSearchResults);
      SB_NameCard_AccountRegistController ctrl = new SB_NameCard_AccountRegistController();
      System.assertEquals(ctrl.accountTable.size(), 5);
    }
  }


  // @TestSetup
  static void setupDB() {
    //
    List<Account> listAccount = new List<Account>();
    listAccount.add(new Account(Name='株式会社 テスト商事', Site='本社'));
    listAccount.add(new Account(Name='株式会社 テスト電気', Site='本社'));
    listAccount.add(new Account(Name='株式会社 テスト工業', Site='本社'));
    listAccount.add(new Account(Name='株式会社 テスト重工', Site='本社'));
    listAccount.add(new Account(Name='株式会社 テスト運送', Site='本社'));
    listAccount.add(new Account(Name='株式会社 テスト運輸', Site='営業'));
    listAccount.add(new Account(Name='株式会社 テスト不動産', Site='営業'));
    listAccount.add(new Account(Name='株式会社 サンプル物産', Site='本社'));
    insert listAccount;
    //
    List<Contact> listContact = new List<Contact>();
    listContact.add(new Contact(LastName='テスト', FirstName='一郎', Email='ichiro@test.com', AccountId=listAccount[0].Id));
    listContact.add(new Contact(LastName='テスト', FirstName='二郎', Email='jiro@test.com', AccountId=listAccount[0].Id));
    listContact.add(new Contact(LastName='サンプル', FirstName='一郎', Email='ichiro@sample.com', AccountId=listAccount[1].Id));
    listContact.add(new Contact(LastName='サンプル', FirstName='二郎', Email='jiro@sample.com', AccountId=listAccount[1].Id));
    insert listContact;

    //List<NameCard__c> listCard = new List<NameCard__c>();
    //listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社 テスト商事', last_name__c='テスト', first_name__c='一郎', email__c='ichiro@test.com'));
    //listCard.add(new NameCard__c(Name='テスト 二郎', company_name__c='株式会社 テスト商事', last_name__c='テスト', first_name__c='二郎', email__c='jiro@test.com'));
    //listCard.add(new NameCard__c(Name='サンプル 一郎', company_name__c='株式会社 サンプル物産', last_name__c='サンプル', first_name__c='一郎', email__c='ichiro@sample.com'));
    //listCard.add(new NameCard__c(Name='サンプル 二郎', company_name__c='株式会社 サンプル物産', last_name__c='サンプル', first_name__c='二郎', email__c='jiro@sample.com'));
    //insert listCard;

  }

  // アカウント 名刺の 株式会社テスト商事 が一致 1つ
  // コンタクト が一致 1つ
  @isTest
  static void test_Account1_Contact1_Default3_PerfectMatch() {
    setupDB();
    // 名刺の追加
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社テスト商事', division__c='本社',
              last_name__c='テスト', first_name__c='一郎', email__c='ichiro@test.com'));
    insert listCard;

    Test.startTest();
    // SOSL で 所定のアカウント が取得出来るように
    Id [] fixedSearchResults= new Id[1];
    List<Account> acnts = [SELECT Id, Name FROM Account WHERE Name='株式会社 テスト商事'];
    System.assert(!acnts.isEmpty());
    fixedSearchResults[0] = acnts[0].Id;
    Test.setFixedSearchResults(fixedSearchResults);

    // SB_NameCard_AccountRegist ページを開いて、オプションを選択
    PageReference pageRef = Page.SB_NameCard_AccountRegist;
    pageRef.getParameters().put('id', listCard[0].Id);
    Test.setCurrentPage(pageRef);
    // ApexPages.StandardController sc = new ApexPages.StandardController(listCard[0]);
    SB_NameCard_AccountRegistController ctrl = new SB_NameCard_AccountRegistController();
    ctrl.searchType = SB_NameCard_Util.SEARCHTYPE_NAME_SITE;
    // ctrl.queryMatch = SB_NameCard_AccountRegistController.QUERY_PERFECT;
    ctrl.searchMethod = SB_NameCard_AccountRegistController.SEARCHMETHOD_OLD;  // '従来仕様 (取引先責任者SOQL+取引先部分一致SOQL)☓2'
    // ctrl.init();
    System.assertEquals(2+3, ctrl.accountTable.size());
    ctrl.searchMethod = 1;  // 'SOSL or SOQL完全一致'
    ctrl.search();
    System.assertEquals(2+3, ctrl.accountTable.size());
    ctrl.searchMethod = 2;  // 'SOQLでカウントしてから続ける'
    ctrl.search();
    System.assertEquals(2+3, ctrl.accountTable.size());
    ctrl.searchMethod = 3;  // '取引先責任者へのリレーションクエリを含む取引先クエリのみ' Lex版 一括取引先登録の検索方式
    ctrl.search();
    System.assertEquals(2+3, ctrl.accountTable.size());
    ctrl.searchMethod = 0;  // '従来仕様 (取引先責任者SOQL+取引先部分一致SOQL)☓2'
    ctrl.search();
    System.assertEquals(2+3, ctrl.accountTable.size());
    Test.stopTest();
  }


  // アカウント 名刺の 株式会社テスト で 取引先名の部分一致 が一致 7つ
  // コンタクト が一致 1つ
  @isTest
  static void test_Account7_Contact1_Default3_PartialMatch() {
    setupDB();
    // 名刺の追加
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社テスト', division__c='本社',
              last_name__c='テスト', first_name__c='一郎', email__c='ichiro@test.com'));
    insert listCard;

    Test.startTest();
    // SOSL で 所定のアカウント が取得出来るように
    List<Account> acnts = [SELECT Id, Name FROM Account WHERE Name LIKE '%テスト%' AND Site = '本社'];
    Id [] fixedSearchResults= new Id[acnts.size()];
    System.assert(!acnts.isEmpty());
    System.debug(acnts.size());
    for (Integer n = 0; n < acnts.size(); n++) {
      fixedSearchResults[n] = acnts[n].Id;
    }
    Test.setFixedSearchResults(fixedSearchResults);

    // SB_NameCard_AccountRegist ページを開いて、オプションを選択
    PageReference pageRef = Page.SB_NameCard_AccountRegist;
    pageRef.getParameters().put('id', listCard[0].Id);
    Test.setCurrentPage(pageRef);
    // ApexPages.StandardController sc = new ApexPages.StandardController(listCard[0]);
    SB_NameCard_AccountRegistController ctrl = new SB_NameCard_AccountRegistController();
    ctrl.searchType = SB_NameCard_Util.SEARCHTYPE_NAME_SITE;
    // ctrl.queryMatch = SB_NameCard_AccountRegistController.QUERY_PERFECT;
    ctrl.searchMethod = 0;  // '従来仕様 (取引先責任者SOQL+取引先部分一致SOQL)☓2'
    // ctrl.init();
    System.assertEquals(acnts.size() + 1 + 3, ctrl.accountTable.size());
    ctrl.searchMethod = 1;  // 'SOSL or SOQL完全一致'
    ctrl.search();
    System.assertEquals(acnts.size() + 1 + 3, ctrl.accountTable.size());
    ctrl.searchMethod = 2;  // 'SOQLでカウントしてから続ける'
    ctrl.search();
    System.assertEquals(acnts.size() + 1 + 3, ctrl.accountTable.size());
    ctrl.searchMethod = 3;  // '取引先責任者へのリレーションクエリを含む取引先クエリのみ' Lex版 一括取引先登録の検索方式
    ctrl.search();
    System.assertEquals(acnts.size() + 1 + 3, ctrl.accountTable.size());
    ctrl.searchMethod = 0;  // '従来仕様 (取引先責任者SOQL+取引先部分一致SOQL)☓2'
    ctrl.search();
    System.assertEquals(acnts.size() + 1 + 3, ctrl.accountTable.size());
    Test.stopTest();
  }


  // アカウント 名刺の 株式会社テスト で 取引先名の部分一致 が一致 たくさん
  // コンタクト が一致 1つ
  @isTest
  static void test_Account998_Contact1_Default3_PartialMatch() {
    setupDB();
    // アカウント1,000件追加
    List<Account> listAccount = new List<Account>();
    for (Integer n =0; n < 1000; n++) {
      listAccount.add(new Account(Name='株式会社 テスト〇〇', Site='本社'));
    }
    listAccount.add(new Account(Name='株式会社テスト', Site='本社'));
    insert listAccount;

    // 名刺の追加
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社テスト', division__c='本社',
              last_name__c='テスト', first_name__c='一郎', email__c='ichiro@test.com'));
    insert listCard;

    Test.startTest();
    // SOSL で 所定のアカウント が取得出来るように
    List<Account> acnts = [SELECT Id, Name FROM Account WHERE Name LIKE '%テスト%' AND Site LIKE '%本社%'];
    Id [] fixedSearchResults= new Id[acnts.size()];
    System.assert(!acnts.isEmpty());
    System.debug(acnts.size());
    for (Integer n = 0; n < acnts.size(); n++) {
      fixedSearchResults[n] = acnts[n].Id;
    }
    Test.setFixedSearchResults(fixedSearchResults);

    // SB_NameCard_AccountRegist ページを開いて、オプションを選択
    PageReference pageRef = Page.SB_NameCard_AccountRegist;
    pageRef.getParameters().put('id', listCard[0].Id);
    Test.setCurrentPage(pageRef);
    // ApexPages.StandardController sc = new ApexPages.StandardController(listCard[0]);
    SB_NameCard_AccountRegistController ctrl = new SB_NameCard_AccountRegistController();
    ctrl.searchType = SB_NameCard_Util.SEARCHTYPE_NAME_SITE;
    // ctrl.queryMatch = SB_NameCard_AccountRegistController.QUERY_PERFECT;
    // // ctrl.searchMethod = 0;  // '従来仕様 (取引先責任者SOQL+取引先部分一致SOQL)☓2'
    // // ctrl.init();
    // System.assertEquals(1 + 1 + 3, ctrl.accountTable.size());
    // ctrl.searchMethod = 1;  // 'SOSL or SOQL完全一致'
    ctrl.search();
    System.assertEquals(1 + 1 + 3, ctrl.accountTable.size());
    ctrl.searchMethod = 2;  // 'SOQLでカウントしてから続ける'
    ctrl.search();
    System.assertEquals(1 + 1 + 3, ctrl.accountTable.size());
    // ctrl.searchMethod = 3;  // '取引先責任者へのリレーションクエリを含む取引先クエリのみ' Lex版 一括取引先登録の検索方式
    // ctrl.search();
    // // System.assertEquals(1 + 3, ctrl.accountTable.size()); // メアドが一致するだけのコンタクとは含まれないので、
    // System.assertEquals(1 + 3, ctrl.accountTable.size()); // メアドが一致するだけのコンタクとは含まれないので、
    ctrl.searchMethod = 0;  // '従来仕様 (取引先責任者SOQL+取引先部分一致SOQL)☓2'
    ctrl.search();
    System.assertEquals(1 + 1 + 3, ctrl.accountTable.size());
    Test.stopTest();
  }

  // アカウント 名刺の 株式会社テスト で 取引先名の部分一致 が一致 たくさん で 完全一致1つ 名刺のアカウント参照が違うのが１つ
  // コンタクト が一致 1つ
  @isTest
  static void test_Account998_Contact1_Default3_PerfectMatch_ReferenceOther() {
    setupDB();
    // アカウント1,000件追加
    List<Account> listAccount = new List<Account>();
    for (Integer n =0; n < 1000; n++) {
      listAccount.add(new Account(Name='株式会社 テスト〇〇', Site='本社'));
    }
    listAccount.add(new Account(Name='株式会社テスト', Site='本社'));
    insert listAccount;

    // 名刺の追加
    Account acnt = [SELECT Id, Name FROM Account WHERE Name = '株式会社 テスト〇〇' AND Site = '本社' LIMIT 1];
    Contact cont = [SELECT Id, Name FROM Contact WHERE Email = 'ichiro@test.com' LIMIT 1];
    // 名刺の追加 アカウントID とコンタクトID がある
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社テスト', division__c='本社',
              last_name__c='テスト', first_name__c='一郎', email__c='ichiro@test.com',
              account__c=acnt.Id, contact__c=cont.Id));
    insert listCard;

    Test.startTest();
    // SOSL で 所定のアカウント が取得出来るように
    Map<Id, Account> acnts = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Name LIKE '%テスト%' AND Site LIKE '%本社%' AND Id != :acnt.Id ]);
    List<Id> fixedSearchResults = new List<Id>(acnts.keySet());
    Test.setFixedSearchResults(fixedSearchResults);

    // SB_NameCard_AccountRegist ページを開いて、オプションを選択
    PageReference pageRef = Page.SB_NameCard_AccountRegist;
    pageRef.getParameters().put('id', listCard[0].Id);
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(listCard[0]);
    SB_NameCard_AccountRegistController ctrl = new SB_NameCard_AccountRegistController();
    ctrl.searchType = SB_NameCard_Util.SEARCHTYPE_NAME_SITE;
    // ctrl.queryMatch = SB_NameCard_AccountRegistController.QUERY_PERFECT;
    // ctrl.searchMethod = 0;  // '従来仕様 (取引先責任者SOQL+取引先部分一致SOQL)☓2'
    // // ctrl.init();
    // System.assertEquals(2 + 1 + 3, ctrl.accountTable.size());
    // ctrl.searchMethod = 1;  // 'SOSL or SOQL完全一致'
    ctrl.search();
    System.assertEquals(3 + 1 + 3, ctrl.accountTable.size());
    ctrl.searchMethod = 2;  // 'SOQLでカウントしてから続ける'
    ctrl.search();
    System.assertEquals(3 + 1 + 3, ctrl.accountTable.size());
    // ctrl.searchMethod = 3;  // '取引先責任者へのリレーションクエリを含む取引先クエリのみ' Lex版 一括取引先登録の検索方式
    // ctrl.search();
    // System.assertEquals(1 + 1 + 3, ctrl.accountTable.size());
    // ctrl.searchMethod = 0;  // '従来仕様 (取引先責任者SOQL+取引先部分一致SOQL)☓2'
    // ctrl.search();
    // System.assertEquals(2 + 1 + 3, ctrl.accountTable.size());
    Test.stopTest();
  }


  // アカウント 名刺の 株式会社テスト で 取引先名の部分一致 が一致 7つ
  // コンタクト が一致 1つ
  // 名刺にアカウントID とコンタクトID がある。
  @isTest
  static void test_Account1_Contact1_Default3_PartialMatch_AccountId_ContactId() {
    setupDB();
    Account acnt = [SELECT Id, Name FROM Account WHERE Name = '株式会社 テスト商事' AND Site = '本社'];
    Contact cont = [SELECT Id, Name FROM Contact WHERE Email = 'ichiro@test.com'];
    // 名刺の追加 アカウントID とコンタクトID がある
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社テスト商事', division__c='本社',
              last_name__c='テスト', first_name__c='一郎', email__c='ichiro@test.com',
              account__c=acnt.Id, contact__c=cont.Id));
    insert listCard;

    Test.startTest();
    // SOSL で 所定のアカウント が取得出来るように
    List<Account> acnts = [SELECT Id, Name FROM Account WHERE Name LIKE '%テスト商事%' AND Site LIKE '%本社%'];
    Id [] fixedSearchResults= new Id[acnts.size()];
    System.assert(!acnts.isEmpty());
    System.debug(acnts.size());
    for (Integer n = 0; n < acnts.size(); n++) {
      fixedSearchResults[n] = acnts[n].Id;
    }
    Test.setFixedSearchResults(fixedSearchResults);

    // SB_NameCard_AccountRegist ページを開いて、オプションを選択
    PageReference pageRef = Page.SB_NameCard_AccountRegist;
    pageRef.getParameters().put('id', listCard[0].Id);
    Test.setCurrentPage(pageRef);
    // ApexPages.StandardController sc = new ApexPages.StandardController(listCard[0]);
    SB_NameCard_AccountRegistController ctrl = new SB_NameCard_AccountRegistController();
    ctrl.searchType = SB_NameCard_Util.SEARCHTYPE_NAME_SITE;
    // ctrl.queryMatch = SB_NameCard_AccountRegistController.QUERY_PERFECT;
    // ctrl.searchMethod = 0;  // '従来仕様 (取引先責任者SOQL+取引先部分一致SOQL)☓2'
    // // ctrl.init();
    // System.assertEquals(acnts.size() + 1 + 3, ctrl.accountTable.size());
    // ctrl.searchMethod = 1;  // 'SOSL or SOQL完全一致'
    ctrl.search();
    System.assertEquals(acnts.size() + 1 + 3, ctrl.accountTable.size());
    ctrl.searchMethod = 2;  // 'SOQLでカウントしてから続ける'
    ctrl.search();
    System.assertEquals(acnts.size() + 1 + 3, ctrl.accountTable.size());
    // ctrl.searchMethod = 3;  // '取引先責任者へのリレーションクエリを含む取引先クエリのみ' Lex版 一括取引先登録の検索方式
    // ctrl.search();
    // System.assertEquals(acnts.size() + 1 + 3, ctrl.accountTable.size());
    // ctrl.searchMethod = 0;  // '従来仕様 (取引先責任者SOQL+取引先部分一致SOQL)☓2'
    // ctrl.search();
    // System.assertEquals(acnts.size() + 1 + 3, ctrl.accountTable.size());
    Test.stopTest();
  }

  // PRODUCT-696 取引先登録 個別・一括 メールアドレスが空白値で一致して登録先候補が表示されてしまう。（姓・名が異なるレコードが表示される）  // アカウント 名刺の 株式会社テスト で 取引先名の部分一致 が一致 7つ
  // コンタクト が一致 1つ
  // 名刺にアカウントID とコンタクトID がある。
  @isTest
  static void test_Account1_Contact2_EmailBlank() {
    setupDB();
    // 名刺の追加 メールアドレスは未設定
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社テスト商事', division__c='本社',
              last_name__c='テスト', first_name__c='一郎', email__c=''));
    insert listCard;

    Test.startTest();
    // SOSL で 所定のアカウント が取得出来るように
    List<Account> acnts = [SELECT Id, Name FROM Account WHERE Name LIKE '%テスト商事%' AND Site LIKE '%本社%'];
    Id [] fixedSearchResults= new Id[acnts.size()];
    System.assert(!acnts.isEmpty());
    System.debug(acnts.size());
    for (Integer n = 0; n < acnts.size(); n++) {
      fixedSearchResults[n] = acnts[n].Id;
    }
    Test.setFixedSearchResults(fixedSearchResults);

    // メールアドレスを未設定に変更
    List<Contact> listContact= [SELECT Id, Name, Email FROM Contact];
    for (Integer i = 0; i < listContact.size(); i++) {
      listContact[i].Email = '';
    }
    update listContact;

    // SB_NameCard_AccountRegist ページを開いて、オプションを選択
    PageReference pageRef = Page.SB_NameCard_AccountRegist;
    pageRef.getParameters().put('id', listCard[0].Id);
    Test.setCurrentPage(pageRef);
    // ApexPages.StandardController sc = new ApexPages.StandardController(listCard[0]);
    SB_NameCard_AccountRegistController ctrl = new SB_NameCard_AccountRegistController();
    ctrl.searchType = SB_NameCard_Util.SEARCHTYPE_NAME;
    // ctrl.queryMatch = SB_NameCard_AccountRegistController.QUERY_PERFECT;
    // ctrl.searchMethod = 0;  // '従来仕様 (取引先責任者SOQL+取引先部分一致SOQL)☓2'
    // // ctrl.init();
    // System.assertEquals(acnts.size() + 1 + 3, ctrl.accountTable.size());
    // ctrl.searchMethod = 1;  // 'SOSL or SOQL完全一致'
    ctrl.search();
    for (SB_NameCard_AccountRegistController.AccountRecord ar : ctrl.accountTable) {
      System.debug('ar1:' + ar);
    }
    // ctrl.accountTable[0].contactName;
    System.assertEquals(acnts.size() + 1 + 3, ctrl.accountTable.size(), 'リストの取得件数が5件(新規/新規 + none/新規 + none/none + 既存/新規 + 既存/既存)ではありません');
    ctrl.searchMethod = 2;  // 'SOQLでカウントしてから続ける'
    ctrl.search();
    for (SB_NameCard_AccountRegistController.AccountRecord ar : ctrl.accountTable) {
      System.debug('ar2:' + ar);
    }
    System.assertEquals(acnts.size() + 1 + 3, ctrl.accountTable.size(), 'リストの取得件数が5件(新規/新規 + none/新規 + none/none + 既存/新規 + 既存/既存)ではありません');
    // ctrl.searchMethod = 3;  // '取引先責任者へのリレーションクエリを含む取引先クエリのみ' Lex版 一括取引先登録の検索方式
    // ctrl.search();
    // System.assertEquals(acnts.size() + 1 + 3, ctrl.accountTable.size());
    // ctrl.searchMethod = 0;  // '従来仕様 (取引先責任者SOQL+取引先部分一致SOQL)☓2'
    // ctrl.search();
    // System.assertEquals(acnts.size() + 1 + 3, ctrl.accountTable.size());
    Test.stopTest();
  }


  // アカウント 名刺の 株式会社テスト で 取引先名と所属 の部分一致 が一致 5つ
  // コンタクト が一致 1つ
  @isTest
  static void test_Account5_Contact1_Default3_PartialMatch() {
    setupDB();
    // 名刺の追加
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社テスト', division__c='本社',
              last_name__c='テスト', first_name__c='一郎', email__c='ichiro@test.com'));
    insert listCard;

    Test.startTest();
    // SOSL で 所定のアカウント が取得出来るように
    List<Account> acnts = [SELECT Id, Name FROM Account WHERE Name LIKE '%テスト%' AND Site LIKE '%本社%'];
    Id [] fixedSearchResults= new Id[acnts.size()];
    System.assert(!acnts.isEmpty());
    System.debug(acnts.size());
    for (Integer n = 0; n < acnts.size(); n++) {
      fixedSearchResults[n] = acnts[n].Id;
    }
    Test.setFixedSearchResults(fixedSearchResults);

    // SB_NameCard_AccountRegist ページを開いて、オプションを選択
    PageReference pageRef = Page.SB_NameCard_AccountRegist;
    pageRef.getParameters().put('id', listCard[0].Id);
    Test.setCurrentPage(pageRef);
    // ApexPages.StandardController sc = new ApexPages.StandardController(listCard[0]);
    SB_NameCard_AccountRegistController ctrl = new SB_NameCard_AccountRegistController();
    ctrl.searchType = SB_NameCard_Util.SEARCHTYPE_NAME_SITE;
    // ctrl.queryMatch = SB_NameCard_AccountRegistController.QUERY_PERFECT;
    // ctrl.searchMethod = 0;  // '従来仕様 (取引先責任者SOQL+取引先部分一致SOQL)☓2'
    // // ctrl.init();
    // System.assertEquals(acnts.size() + 1 + 3, ctrl.accountTable.size());
    // ctrl.searchMethod = 1;  // 'SOSL or SOQL完全一致'
    ctrl.search();
    System.assertEquals(acnts.size() + 1 + 3, ctrl.accountTable.size());
    ctrl.searchMethod = 2;  // 'SOQLでカウントしてから続ける'
    ctrl.search();
    System.assertEquals(acnts.size() + 1 + 3, ctrl.accountTable.size());
    // ctrl.searchMethod = 3;  // '取引先責任者へのリレーションクエリを含む取引先クエリのみ' Lex版 一括取引先登録の検索方式
    // ctrl.search();
    // System.assertEquals(acnts.size() + 1 + 3, ctrl.accountTable.size());
    // ctrl.searchMethod = 0;  // '従来仕様 (取引先責任者SOQL+取引先部分一致SOQL)☓2'
    // ctrl.search();
    // System.assertEquals(acnts.size() + 1 + 3, ctrl.accountTable.size());
    Test.stopTest();
  }

  @isTest
  static void test_createInstance_QueryPrameter() {
    setupDB();
    // 名刺の追加
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社テスト', division__c='本社',
              last_name__c='テスト', first_name__c='一郎', email__c='ichiro@test.com'));
    insert listCard;

    Test.startTest();
    // SOSL で 所定のアカウント が取得出来るように
    List<Account> acnts = [SELECT Id, Name FROM Account WHERE Name LIKE '%テスト%' AND Site LIKE '%本社%'];
    Id [] fixedSearchResults= new Id[acnts.size()];
    System.assert(!acnts.isEmpty());
    System.debug(acnts.size());
    for (Integer n = 0; n < acnts.size(); n++) {
      fixedSearchResults[n] = acnts[n].Id;
    }
    Test.setFixedSearchResults(fixedSearchResults);

    //
    List<Contact> conts = [SELECT Id, Name FROM Contact];

    // SB_NameCard_AccountRegist ページを開いて、オプションを選択
    PageReference pageRef = Page.SB_NameCard_AccountRegist;
    //pageRef.getParameters().put('id', listCard[0].Id);
    Test.setCurrentPage(pageRef);
    pageRef.getParameters().put('id', listCard[0].Id);
    // pageRef.getParameters().put('serchMethod', String.valueOf(SB_NameCard_AccountRegistController.SEARCHTYPE_DEFAULT));
    // pageRef.getParameters().put('searchField', String.valueOf(SB_NameCard_Util.SEARCHTYPE_NAME_SITE));
    // pageRef.getParameters().put('queryMatch', String.valueOf(SB_NameCard_AccountRegistController.QUERY_PERFECT_NO));
    SB_NameCard_AccountRegistController ctrl = new SB_NameCard_AccountRegistController();
    //ctrl.searchType = SB_NameCard_Util.SEARCHTYPE_NAME_SITE;
    //ctrl.queryMatch = SB_NameCard_AccountRegistController.QUERY_PERFECT;
    //ctrl.searchMethod = 0;
    // ctrl.init();
    System.assertEquals(acnts.size() + 1 + 3, ctrl.accountTable.size());

    // ctrl.postLookupContact();
    ctrl.save();
    ctrl.cancel();

    // for (SB_NameCard_AccountRegistController.AccountRecord can : ctrl.accountTable) {
    //   // System.debug(can.getLookupContact());
    //   if (can instanceof SB_NameCard_AccountRegistController.AccountLookupCandidate) {
    //     can.card4Lookup.account__c = acnts[0].Id;
    //     can.postLookup();
    //   }
    //   else if (can instanceof SB_NameCard_AccountRegistController.ContactLookupCandidate) {
    //     can.card4Lookup.contact__c = conts[0].Id;
    //     can.postLookup();
    //   }
    //   can.adopt(listCard[0]);
    // }

  }

  // @isTest
  // static void test_ControllerEtc() {
  //   SB_NameCard_AccountRegistController ctrl = new SB_NameCard_AccountRegistController();
  //   System.assertEquals(SB_NameCard_AccountRegistController.searchMethods.size(), ctrl.getSearchMethodSelectOpts().size());
  //   System.assertEquals(2, ctrl.getSearchFieldSelectOpts().size());

  // }


}