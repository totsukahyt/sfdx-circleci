/*
 * ツールパッケージ用拡張バージョン
 *  SB_NameCard_AccountRegistControllerTest3
 *    LDV対応取引先登録拡張パッケージでの SB_NameCard_AccountRegistCTest2
 * 
 * @Version 1      2018.01.xx
 * @author  kou
 *
 * 名刺情報から取引先・取引先責任者の登録テストクラス
 *
 */ 
@isTest
private with sharing class SB_NameCard_AccountRegistControllerTest3 {

  @isTest
  static void test_Account997_Contact1_Default3_PerfectMatchAbandon() {
    List<Account> listAccount = new List<Account>();
    for (Integer n=0; n<1000; n++) {
      listAccount.add(new Account(Name='株式会社 テスト〇〇', Site='本社'));
    }
    for (Integer n=0; n<997; n++) {
      listAccount.add(new Account(Name='株式会社 テスト物産', Site='本社'));
    }
    for(Integer n=0; n<997; n++) {
      listAccount.add(new Account(Name='株式会社 サンプル物産', Site='本社'));
    }
    insert listAccount;
    //
    List<Contact> listContact = new List<Contact>();
    listContact.add(new Contact(LastName='テスト', FirstName='一郎', Email='ichiro@test.com', AccountId=listAccount[0].Id));
    //listContact.add(new Contact(LastName='サンプル', FirstName='一郎', Email='ichiro@sample.com', AccountId=listAccount[1].Id));
    //listContact.add(new Contact(LastName='サンプル', FirstName='二郎', Email='jiro@sample.com', AccountId=listAccount[1].Id));
    insert listContact;

    // 名刺の追加
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社 テスト物産', division__c='本社',
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
    //ctrl.searchMethod = 0;  // '従来仕様 (取引先責任者SOQL+取引先部分一致SOQL)☓2'
    //// ctrl.init();
    //System.assertEquals(acnts.size() + 1 + 3, ctrl.accountTable.size());
    // ctrl.searchMethod = 1;  // 'SOSL or SOQL完全一致'
    ctrl.search();
    System.assertEquals(SB_NameCard_RegistCanPickerAbstract.QueryProcess.ABANDON, ctrl.accoutQueryProcess);
    System.assertEquals(1 + 3, ctrl.accountTable.size());
    ctrl.searchMethod = 2;  // 'SOQLでカウントしてから続ける'
    ctrl.search();
    System.assertEquals(SB_NameCard_RegistCanPickerAbstract.QueryProcess.ABANDON, ctrl.accoutQueryProcess);
    System.assertEquals(1 + 3, ctrl.accountTable.size());

    //ctrl.searchMethod = 3;  // '取引先責任者へのリレーションクエリを含む取引先クエリのみ' Lex版 一括取引先登録の検索方式
    //ctrl.search();
    //System.assertEquals(acnts.size() + 1 + 3, ctrl.accountTable.size());
    //ctrl.searchMethod = 0;  // '従来仕様 (取引先責任者SOQL+取引先部分一致SOQL)☓2'
    //ctrl.search();
    //System.assertEquals(acnts.size() + 1 + 3, ctrl.accountTable.size());
    Test.stopTest();
  }

  @isTest
  static void test_Account996_Contact1_Default3_PerfectMatch() {
    List<Account> listAccount = new List<Account>();
    for (Integer n=0; n<1000; n++) {
      listAccount.add(new Account(Name='株式会社 テスト〇〇', Site='本社'));
    }
    for (Integer n=0; n<996; n++) {
      listAccount.add(new Account(Name='株式会社 テスト物産', Site='本社'));
    }
    for(Integer n=0; n<997; n++) {
      listAccount.add(new Account(Name='テスト物産 株式会社', Site='本社'));
    }
    insert listAccount;
    //
    List<Contact> listContact = new List<Contact>();
    listContact.add(new Contact(LastName='テスト', FirstName='一郎', Email='ichiro@test.com', AccountId=listAccount[0].Id));
    //listContact.add(new Contact(LastName='サンプル', FirstName='一郎', Email='ichiro@sample.com', AccountId=listAccount[1].Id));
    //listContact.add(new Contact(LastName='サンプル', FirstName='二郎', Email='jiro@sample.com', AccountId=listAccount[1].Id));
    insert listContact;

    // 名刺の追加
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社 テスト物産', division__c='本社',
              last_name__c='テスト', first_name__c='一郎', email__c='ichiro@test.com'));
    insert listCard;

    Test.startTest();
    // SOSL で 所定のアカウント が取得出来るように
    Map<Id, Account> acnts = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Name LIKE '%テスト物産%' AND Site LIKE '%本社%']);
    List<Id> fixedSearchResults = new List<Id>(acnts.keySet());
    Test.setFixedSearchResults(fixedSearchResults);

    // SB_NameCard_AccountRegist ページを開いて、オプションを選択
    PageReference pageRef = Page.SB_NameCard_AccountRegist;
    pageRef.getParameters().put('id', listCard[0].Id);
    Test.setCurrentPage(pageRef);
    // ApexPages.StandardController sc = new ApexPages.StandardController(listCard[0]);
    SB_NameCard_AccountRegistController ctrl = new SB_NameCard_AccountRegistController();
    // ctrl.searchType = SB_NameCard_Util.SEARCHTYPE_NAME_SITE;
    // ctrl.queryMatch = SB_NameCard_AccountRegistController.QUERY_PERFECT;
    //ctrl.searchMethod = 0;  // '従来仕様 (取引先責任者SOQL+取引先部分一致SOQL)☓2'
    //// ctrl.init();
    //System.assertEquals(acnts.size() + 1 + 3, ctrl.accountTable.size());
    // ctrl.searchMethod = 1;  // 'SOSL or SOQL完全一致'
    ctrl.search();
    System.assertEquals(SB_NameCard_RegistCanPickerAbstract.QueryProcess.PERFECT, ctrl.accoutQueryProcess);
    System.assertEquals(996 + 1 + 3, ctrl.accountTable.size());
    ctrl.searchMethod = 2;  // 'SOQLでカウントしてから続ける'
    ctrl.search();
    System.assertEquals(SB_NameCard_RegistCanPickerAbstract.QueryProcess.PERFECT, ctrl.accoutQueryProcess);
    System.assertEquals(996 + 1 + 3, ctrl.accountTable.size());
    //ctrl.searchMethod = 3;  // '取引先責任者へのリレーションクエリを含む取引先クエリのみ' Lex版 一括取引先登録の検索方式
    //ctrl.search();
    //System.assertEquals(acnts.size() + 1 + 3, ctrl.accountTable.size());
    //ctrl.searchMethod = 0;  // '従来仕様 (取引先責任者SOQL+取引先部分一致SOQL)☓2'
    //ctrl.search();
    //System.assertEquals(acnts.size() + 1 + 3, ctrl.accountTable.size());
    Test.stopTest();
  }

  @isTest
  static void test_Account0_Contact0_Default3_PartialMatch() {
    List<Account> listAccount = new List<Account>();
    for(Integer n=0; n<997; n++) {
      listAccount.add(new Account(Name='株式会社 サンプル物産', Site='本社'));
    }
    insert listAccount;
    //
    List<Contact> listContact = new List<Contact>();
    //listContact.add(new Contact(LastName='テスト', FirstName='一郎', Email='ichiro@test.com', AccountId=listAccount[0].Id));
    listContact.add(new Contact(LastName='サンプル', FirstName='一郎', Email='ichiro@sample.com', AccountId=listAccount[1].Id));
    //listContact.add(new Contact(LastName='サンプル', FirstName='二郎', Email='jiro@sample.com', AccountId=listAccount[1].Id));
    insert listContact;

    // 名刺の追加
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社 テスト物産', division__c='本社',
              last_name__c='テスト', first_name__c='一郎', email__c='ichiro@test.com'));
    insert listCard;

    Test.startTest();
    //// SOSL で 所定のアカウント が取得出来るように
    //List<Account> acnts = [SELECT Id, Name FROM Account WHERE Name LIKE '%テスト%' AND Site LIKE '%本社%'];
    //Id [] fixedSearchResults= new Id[acnts.size()];
    //System.assert(!acnts.isEmpty());
    //System.debug(acnts.size());
    //for (Integer n = 0; n < acnts.size(); n++) {
    //  fixedSearchResults[n] = acnts[n].Id;
    //}
    //Test.setFixedSearchResults(fixedSearchResults);

    // SB_NameCard_AccountRegist ページを開いて、オプションを選択
    PageReference pageRef = Page.SB_NameCard_AccountRegist;
    pageRef.getParameters().put('id', listCard[0].Id);
    Test.setCurrentPage(pageRef);
    // ApexPages.StandardController sc = new ApexPages.StandardController(listCard[0]);
    SB_NameCard_AccountRegistController ctrl = new SB_NameCard_AccountRegistController();
    ctrl.searchType = SB_NameCard_Util.SEARCHTYPE_NAME_SITE;
    // ctrl.queryMatch = SB_NameCard_AccountRegistController.QUERY_PERFECT;
    //ctrl.searchMethod = 0;  // '従来仕様 (取引先責任者SOQL+取引先部分一致SOQL)☓2'
    //// ctrl.init();
    //System.assertEquals(acnts.size() + 1 + 3, ctrl.accountTable.size());
    // ctrl.searchMethod = 1;  // 'SOSL or SOQL完全一致'
    ctrl.search();
    System.assertEquals(SB_NameCard_RegistCanPickerAbstract.QueryProcess.PARTIAL, ctrl.accoutQueryProcess);
    System.assertEquals(3, ctrl.accountTable.size());
    ctrl.searchMethod = 2;  // 'SOQLでカウントしてから続ける'
    ctrl.search();
    System.assertEquals(SB_NameCard_RegistCanPickerAbstract.QueryProcess.PARTIAL, ctrl.accoutQueryProcess);
    System.assertEquals(3, ctrl.accountTable.size());
    //ctrl.searchMethod = 3;  // '取引先責任者へのリレーションクエリを含む取引先クエリのみ' Lex版 一括取引先登録の検索方式
    //ctrl.search();
    //System.assertEquals(acnts.size() + 1 + 3, ctrl.accountTable.size());
    //ctrl.searchMethod = 0;  // '従来仕様 (取引先責任者SOQL+取引先部分一致SOQL)☓2'
    //ctrl.search();
    //System.assertEquals(acnts.size() + 1 + 3, ctrl.accountTable.size());
    Test.stopTest();
  }

  // 会社名で検索される996 + 検索されないけどリンクしてるのがあってオーバーするので リンクだけ表示
  @isTest
  static void test_Account997_Contact0_ALink1_Default3_PerfectMatchAbandon() {
    List<Account> listAccount = new List<Account>();
    for (Integer n=0; n<1000; n++) {
      listAccount.add(new Account(Name='株式会社 テスト〇〇', Site='本社'));
    }
    for (Integer n=0; n<997; n++) {
      listAccount.add(new Account(Name='株式会社 テスト物産', Site='本社'));
    }
    for(Integer n=0; n<997; n++) {
      listAccount.add(new Account(Name='株式会社 サンプル物産', Site='本社'));
    }
    insert listAccount;
    //
    //List<Contact> listContact = new List<Contact>();
    //listContact.add(new Contact(LastName='テスト', FirstName='一郎', Email='ichiro@test.com', AccountId=listAccount[0].Id));
    ////listContact.add(new Contact(LastName='サンプル', FirstName='一郎', Email='ichiro@sample.com', AccountId=listAccount[1].Id));
    ////listContact.add(new Contact(LastName='サンプル', FirstName='二郎', Email='jiro@sample.com', AccountId=listAccount[1].Id));
    //insert listContact;

    // 名刺の追加
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社 テスト物産', division__c='本社',
              last_name__c='テスト', first_name__c='一郎', email__c='ichiro@test.com',
              account__c=listAccount[0].Id));  // 名前で検索されないのがリンクしている
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
    //ctrl.searchMethod = 0;  // '従来仕様 (取引先責任者SOQL+取引先部分一致SOQL)☓2'
    //// ctrl.init();
    //System.assertEquals(acnts.size() + 1 + 3, ctrl.accountTable.size());
    // ctrl.searchMethod = 1;  // 'SOSL or SOQL完全一致'
    ctrl.search();
    System.assertEquals(SB_NameCard_RegistCanPickerAbstract.QueryProcess.ABANDON, ctrl.accoutQueryProcess);
    System.assertEquals(3+1, ctrl.accountTable.size());  // リンクされてるのがある
    ctrl.searchMethod = 2;  // 'SOQLでカウントしてから続ける'
    ctrl.search();
    System.assertEquals(SB_NameCard_RegistCanPickerAbstract.QueryProcess.ABANDON, ctrl.accoutQueryProcess);
    System.assertEquals(3+1, ctrl.accountTable.size());  // リンクされてるのがある
    //ctrl.searchMethod = 3;  // '取引先責任者へのリレーションクエリを含む取引先クエリのみ' Lex版 一括取引先登録の検索方式
    //ctrl.search();
    //System.assertEquals(acnts.size() + 1 + 3, ctrl.accountTable.size());
    //ctrl.searchMethod = 0;  // '従来仕様 (取引先責任者SOQL+取引先部分一致SOQL)☓2'
    //ctrl.search();
    //System.assertEquals(acnts.size() + 1 + 3, ctrl.accountTable.size());
    Test.stopTest();
  }

  // 会社名で検索される996 + 検索されないけどリンクしてるのがあってオーバーするので コンタクトだけ表示
  @isTest
  static void test_Account996_Contact1_ALink1_Default3_PerfectMatchAbandon() {
    List<Account> listAccount = new List<Account>();
    for (Integer n=0; n<1000; n++) {
      listAccount.add(new Account(Name='株式会社 テスト〇〇', Site='本社'));
    }
    for (Integer n=0; n<996; n++) {
      listAccount.add(new Account(Name='株式会社 テスト物産', Site='本社'));
    }
    for(Integer n=0; n<997; n++) {
      listAccount.add(new Account(Name='株式会社 サンプル物産', Site='本社'));
    }
    insert listAccount;
    //
    List<Contact> listContact = new List<Contact>();
    listContact.add(new Contact(LastName='テスト', FirstName='一郎', Email='ichiro@test.com', AccountId=listAccount[0].Id));
    //listContact.add(new Contact(LastName='サンプル', FirstName='一郎', Email='ichiro@sample.com', AccountId=listAccount[1].Id));
    //listContact.add(new Contact(LastName='サンプル', FirstName='二郎', Email='jiro@sample.com', AccountId=listAccount[1].Id));
    insert listContact;

    // 名刺の追加
    List<NameCard__c> listCard = new List<NameCard__c>();
    Id referenceAccountId = listAccount[2000].Id;
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社 テスト物産', division__c='本社',
              last_name__c='テスト', first_name__c='一郎', email__c='ichiro@test.com',
              account__c=referenceAccountId));  // 名前で検索されないのがリンクしている
    insert listCard;

    Test.startTest();
    // SOSL で 所定のアカウント が取得出来るように
    List<Account> acnts = [SELECT Id, Name FROM Account WHERE Name LIKE '%テスト%' AND Site LIKE '%本社%' AND Id != :referenceAccountId ];
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
    //ctrl.searchMethod = 0;  // '従来仕様 (取引先責任者SOQL+取引先部分一致SOQL)☓2'
    //// ctrl.init();
    //System.assertEquals(acnts.size() + 1 + 3, ctrl.accountTable.size());
    // ctrl.searchMethod = 1;  // 'SOSL or SOQL完全一致'
    ctrl.search();
    System.assertEquals(SB_NameCard_RegistCanPickerAbstract.QueryProcess.ABANDON, ctrl.accoutQueryProcess);
    System.assertEquals(1+1+3, ctrl.accountTable.size());  // リンクとコンタクト
    ctrl.searchMethod = 2;  // 'SOQLでカウントしてから続ける'
    ctrl.search();
    System.assertEquals(SB_NameCard_RegistCanPickerAbstract.QueryProcess.ABANDON, ctrl.accoutQueryProcess);
    System.assertEquals(1+1+3, ctrl.accountTable.size());// リンクとコンタクト
    //ctrl.searchMethod = 3;  // '取引先責任者へのリレーションクエリを含む取引先クエリのみ' Lex版 一括取引先登録の検索方式
    //ctrl.search();
    //System.assertEquals(acnts.size() + 1 + 3, ctrl.accountTable.size());
    //ctrl.searchMethod = 0;  // '従来仕様 (取引先責任者SOQL+取引先部分一致SOQL)☓2'
    //ctrl.search();
    //System.assertEquals(acnts.size() + 1 + 3, ctrl.accountTable.size());
    Test.stopTest();
  }

  // 会社名で検索される996 + 検索されないけどリンクしてるのがあってオーバーするので リンクとコンタクトだけ表示
  @isTest
  static void test_Account996_Contact1_CLink1_Default3_PerfectMatchAbandon() {
    List<Account> listAccount = new List<Account>();
    for (Integer n=0; n<1000; n++) {
      listAccount.add(new Account(Name='株式会社 テスト〇〇', Site='本社'));
    }
    for (Integer n=0; n<996; n++) {
      listAccount.add(new Account(Name='株式会社 テスト物産', Site='本社'));
    }
    for(Integer n=0; n<997; n++) {
      listAccount.add(new Account(Name='株式会社 サンプル物産', Site='本社'));
    }
    insert listAccount;
    //
    List<Contact> listContact = new List<Contact>();
    listContact.add(new Contact(LastName='テスト', FirstName='一郎', Email='ichiro@test.com', AccountId=listAccount[0].Id));
    listContact.add(new Contact(LastName='サンプル', FirstName='一郎', Email='ichiro@sample.com', AccountId=listAccount[1].Id));
    //listContact.add(new Contact(LastName='サンプル', FirstName='二郎', Email='jiro@sample.com', AccountId=listAccount[1].Id));
    insert listContact;

    // 名刺の追加
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社 テスト物産', division__c='本社',
              last_name__c='テスト', first_name__c='一郎', email__c='ichiro@test.com',
              account__c=null, contact__c=listContact[1].Id));  // 名前で検索されないのがリンクしている
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
    //ctrl.searchMethod = 0;  // '従来仕様 (取引先責任者SOQL+取引先部分一致SOQL)☓2'
    //// ctrl.init();
    //System.assertEquals(acnts.size() + 1 + 3, ctrl.accountTable.size());
    // ctrl.searchMethod = 1;  // 'SOSL or SOQL完全一致'
    ctrl.search();
    System.assertEquals(SB_NameCard_RegistCanPickerAbstract.QueryProcess.ABANDON, ctrl.accoutQueryProcess);
    System.assertEquals(1+2+3, ctrl.accountTable.size());
    ctrl.searchMethod = 2;  // 'SOQLでカウントしてから続ける'
    ctrl.search();
    //System.assertEquals(acnts.size() + 1 + 3, ctrl.accountTable.size());
    System.assertEquals(SB_NameCard_RegistCanPickerAbstract.QueryProcess.ABANDON, ctrl.accoutQueryProcess);
    System.assertEquals(1+2+3, ctrl.accountTable.size());
    //ctrl.searchMethod = 3;  // '取引先責任者へのリレーションクエリを含む取引先クエリのみ' Lex版 一括取引先登録の検索方式
    //ctrl.search();
    //System.assertEquals(acnts.size() + 1 + 3, ctrl.accountTable.size());
    //ctrl.searchMethod = 0;  // '従来仕様 (取引先責任者SOQL+取引先部分一致SOQL)☓2'
    //ctrl.search();
    //System.assertEquals(acnts.size() + 1 + 3, ctrl.accountTable.size());
    Test.stopTest();
  }

  // SOSL で NAME に名刺の会社名を指定すると Siteが一致するものも該当する
  @isTest
  static void test_SOSOLAccountSite_Contact1_Default3_PerfectMatchAbandon() {
    List<Account> listAccount = new List<Account>();
    listAccount.add(new Account(Name='株式会社 営業部', Site='本社'));
    for (Integer n=0; n<1000; n++) {
      listAccount.add(new Account(Name='株式会社 テスト商事', Site='本社'));
    }
    listAccount.add(new Account(Name='株式会社 テスト商事', Site='営業部'));
    listAccount.add(new Account(Name='株式会社 テスト物産', Site='営業部'));
    listAccount.add(new Account(Name='株式会社 サンプル物産', Site='営業部'));

    insert listAccount;
    //
    List<Contact> listContact = new List<Contact>();
    listContact.add(new Contact(LastName='テスト', FirstName='一郎', Email='ichiro@eigyo.com', AccountId=listAccount[0].Id));
    //listContact.add(new Contact(LastName='サンプル', FirstName='一郎', Email='ichiro@sample.com', AccountId=listAccount[1].Id));
    ////listContact.add(new Contact(LastName='サンプル', FirstName='二郎', Email='jiro@sample.com', AccountId=listAccount[1].Id));
    insert listContact;

    // 名刺の追加
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社 営業部', division__c='本社',
              last_name__c='テスト', first_name__c='一郎', email__c='ichiro@eigyo.com',
              account__c=null, contact__c=null));
    insert listCard;

    Test.startTest();
    // SOSL で 所定のアカウント が取得出来るように
    List<Account> acnts = [SELECT Id, Name FROM Account WHERE Name LIKE '%営業部%' OR Site LIKE '%営業部%'];
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
    // ctrl.queryMatch = SB_NameCard_AccountRegistController.QUERY_PERFECT;

    // 取引先名 で検索
    ctrl.searchType = SB_NameCard_Util.SEARCHTYPE_NAME;
    // ctrl.searchMethod = 1;
    ctrl.search();
    System.assertEquals(SB_NameCard_RegistCanPickerAbstract.QueryProcess.PARTIAL, ctrl.accoutQueryProcess);
    System.assertEquals(1+1+3, ctrl.accountTable.size());  // 部門 の 営業部も該当する、 RETURNING 中の WHERE句で絞られる。
    ctrl.searchMethod = 2;  // 'SOQLでカウントしてから続ける'
    ctrl.search();
    //System.assertEquals(acnts.size() + 1 + 3, ctrl.accountTable.size());
    System.assertEquals(SB_NameCard_RegistCanPickerAbstract.QueryProcess.PARTIAL, ctrl.accoutQueryProcess);
    System.assertEquals(1+1+3, ctrl.accountTable.size());

    // 取引先名と部門名 で検索
    ctrl.searchType = SB_NameCard_Util.SEARCHTYPE_NAME_SITE;
    // 'SOSL or SOQL完全一致'
    // ctrl.searchMethod = 1;
    ctrl.search();
    System.assertEquals(SB_NameCard_RegistCanPickerAbstract.QueryProcess.PARTIAL, ctrl.accoutQueryProcess);
    System.assertEquals(1+1+3, ctrl.accountTable.size());   // 部門 の 営業部も該当するけど、 RETURNING 中の WHERE句で絞られる。
    ctrl.searchMethod = 2;  // 'SOQLでカウントしてから続ける'
    ctrl.search();
    //System.assertEquals(acnts.size() + 1 + 3, ctrl.accountTable.size());
    System.assertEquals(SB_NameCard_RegistCanPickerAbstract.QueryProcess.PARTIAL, ctrl.accoutQueryProcess);
    System.assertEquals(1+1+3, ctrl.accountTable.size());

    Test.stopTest();
  }

}