/**
 * @File Name          : SB_Connect_ClientControllerTest.cls
 * @Description        : REST API clients テストクラス
 * @Author             : 西根哲史
 * @Group              :
 * @Last Modified By   : 西根哲史
 * @Last Modified On   : 2020/3/26 12:30:50
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    2020/1/28   西根哲史     Initial Version
 * 2.0    2020/5/13   sawano      v2.5 名刺のみで自分所有のもののみの対応に変更への対応
**/
@isTest
public with sharing class SB_Connect_ClientControllerTest {
  // 作成するユーザのプロファイル
  private static Profile profStd {
    get {
      if (profStd == null) {
        profStd = [SELECT Id FROM Profile WHERE Name='Standard User' OR Name='標準ユーザ' limit 1];
      }
      return profStd;
    }
    set;
  }

  // SmartViscaでインストールされる権限セット、名刺アクセス権あり
  private static PermissionSet svPermissionSet {
    get {
      if (svPermissionSet == null) {
        svPermissionSet = [SELECT Id, Name FROM PermissionSet WHERE Name = 'SmartViscaUser' LIMIT 1];
      }
      return svPermissionSet;
    }
    set;
  }

  // ユーザレコードの作成
  private static User createUser(String firstname, String lastname) {
    return new User(
      alias = String.format('{0}-{1}', new String[]{firstname,lastname}).subString(0, 7)
      , IsActive = true
      , Email= firstname+lastname+'@testorg.com'
      , Emailencodingkey='UTF-8'
      , Firstname = firstname
      , Lastname = lastname
      , Languagelocalekey='ja'
      , Localesidkey='ja_JP'
      , Profileid = profStd.Id
      , Timezonesidkey='Asia/Tokyo'
      , Username=firstname+lastname+'@testorg.com'
      , Department= firstname + '事業部');
  }

  @testSetup
  static void setupUsers() {
    List<User> listUser = new List<User>();
    for (Integer n=1; n<= 2; n++) {
      listUser.add(createUser(n.format(), 'Smart'));
    }
    insert listUser;

    // 作成したユーザに権限セットの割当て
    List<PermissionSetAssignment> listPSAssinment = new List<PermissionSetAssignment>();
    for (User u : listUser) {
      listPSAssinment.add(new PermissionSetAssignment(AssigneeId=u.Id, PermissionSetId=svPermissionSet.Id));
    }
    insert listPSAssinment;
  }

  //  /**
  //   * 電話番号を持たない取引先責任者のデータが取得されないこと
  //   */
  // @IsTest
  // private static void test000() {
  //     Test.startTest();
  //     Account a = new Account(Name = '株式会社テスト１');
  //     insert a;
  //     Contact c = new Contact(
  //         LastName = '佐藤',
  //         FirstName = '一郎',
  //         AccountId = a.Id
  //     );
  //     insert c;
  //     Test.stopTest();

  //     List<SB_Connect_Client> clients = getClients();
  //     System.assert(clients.isEmpty(), 'データ件数');
  // }

  // /**
  //  * 電話番号を持たない名刺のデータが取得されないこと
  //  */
  // @IsTest
  // private static void test001() {
  //     Test.startTest();
  //     NameCard__c n = new NameCard__c(
  //         person_name_last__c = '佐藤',
  //         person_name_first__c = '一郎',
  //         company_name__c = '株式会社テスト',
  //         Saishin__c = true
  //     );
  //     insert n;
  //     Test.stopTest();

  //     List<SB_Connect_Client> clients = getClients();
  //     System.assert(clients.isEmpty(), 'データ件数');
  // }

  // /**
  //  * 一意の電話番号を持つ取引先責任者のデータが取得されること
  //  */
  // @IsTest
  // private static void test010() {
  //     Test.startTest();
  //     Account a1 = new Account(Name = 'テストA株式会社');
  //     Account a2 = new Account(Name = 'テストB株式会社');
  //     Account a3 = new Account(Name = 'テストC株式会社');
  //     Account a4 = new Account(Name = 'テストD株式会社');
  //     insert new Account[]{a1, a2, a3, a4};
  //     Contact c1 = new Contact(
  //         Phone = '(03) 1111-1111',
  //         LastName = '佐藤',
  //         FirstName = '一郎',
  //         AccountId = a1.Id
  //     );
  //     Contact c2 = new Contact(
  //         HomePhone = '06-2222-2222',
  //         LastName = '鈴木',
  //         FirstName = '二郎',
  //         AccountId = a2.Id
  //     );
  //     Contact c3 = new Contact(
  //         MobilePhone = '090-3333-3333',
  //         LastName = '高橋',
  //         FirstName = '三郎',
  //         AccountId = a3.Id
  //     );
  //     Contact c4 = new Contact(
  //         OtherPhone = '+81 3 4444-4444',
  //         LastName = '田中',
  //         FirstName = '四郎',
  //         AccountId = a4.Id
  //     );
  //     insert new Contact[]{c1, c2, c3, c4};
  //     Test.stopTest();

  //     List<SB_Connect_Client> clients = getClients();
  //     System.assertEquals(4, clients.size(), 'データ件数');

  //     c1 = [select Name, Account.Name, CreatedDate, LastModifiedDate from Contact, Contact.Account where Id = :c1.Id];
  //     c2 = [select Name, Account.Name, CreatedDate, LastModifiedDate from Contact, Contact.Account where Id = :c2.Id];
  //     c3 = [select Name, Account.Name, CreatedDate, LastModifiedDate from Contact, Contact.Account where Id = :c3.Id];
  //     c4 = [select Name, Account.Name, CreatedDate, LastModifiedDate from Contact, Contact.Account where Id = :c4.Id];

  //     for (SB_Connect_Client client : clients) {
  //         if (client.phone_number == '81311111111') {
  //             System.assertEquals('0311111111', client.original_phone_number, 'original_phone_number');
  //             System.assertEquals(c1.Name, client.full_name, 'full_name');
  //             System.assertEquals(c1.Account.Name, client.enterprise_name, 'enterprise_name');
  //             System.assert(!client.is_duplicate, 'is_duplicate');
  //             System.assertEquals(String.valueOf(c1.CreatedDate), client.registered_date, 'registered_date');
  //             System.assertEquals(String.valueOf(c1.LastModifiedDate), client.updated_date, 'updated_date');
  //         } else if (client.phone_number == '81622222222') {
  //             System.assertEquals('0622222222', client.original_phone_number, 'original_phone_number');
  //             System.assertEquals(c2.Name, client.full_name, 'full_name');
  //             System.assertEquals(c2.Account.Name, client.enterprise_name, 'enterprise_name');
  //             System.assert(!client.is_duplicate, 'is_duplicate');
  //             System.assertEquals(String.valueOf(c2.CreatedDate), client.registered_date, 'registered_date');
  //             System.assertEquals(String.valueOf(c2.LastModifiedDate), client.updated_date, 'updated_date');
  //         } else if (client.phone_number == '819033333333') {
  //             System.assertEquals('09033333333', client.original_phone_number, 'original_phone_number');
  //             System.assertEquals(c3.Name, client.full_name, 'full_name');
  //             System.assertEquals(c3.Account.Name, client.enterprise_name, 'enterprise_name');
  //             System.assert(!client.is_duplicate, 'is_duplicate');
  //             System.assertEquals(String.valueOf(c3.CreatedDate), client.registered_date, 'registered_date');
  //             System.assertEquals(String.valueOf(c3.LastModifiedDate), client.updated_date, 'updated_date');
  //         } else if (client.phone_number == '81344444444') {
  //             System.assertEquals('81344444444', client.original_phone_number, 'original_phone_number');
  //             System.assertEquals(c4.Name, client.full_name, 'full_name');
  //             System.assertEquals(c4.Account.Name, client.enterprise_name, 'enterprise_name');
  //             System.assert(!client.is_duplicate, 'is_duplicate');
  //             System.assertEquals(String.valueOf(c4.CreatedDate), client.registered_date, 'registered_date');
  //             System.assertEquals(String.valueOf(c4.LastModifiedDate), client.updated_date, 'updated_date');
  //         } else {
  //             System.assert(false);
  //         }
  //     }
  // }

  /**
    * 一意の電話番号を持つ名刺のデータが取得されること
    */
  @IsTest
  private static void test011() {

    List<User> listUser = [SELECT Id, Name FROM User WHERE ProfileId = :profStd.Id AND IsActive = true];
    NameCard__c n1 = new NameCard__c(
        tel1__c = '03-1111-1111',
        Name = '佐藤 一郎',
        company_name__c = '株式会社テスト１',
        Saishin__c =true,
        OwnerId = listUser[0].Id
    );
    NameCard__c n2 = new NameCard__c(
        tel2__c = '2222222222',
        Name = '鈴木 二郎',
        company_name__c = '株式会社テスト２',
        Saishin__c = true,
        OwnerId = listUser[0].Id
    );
    NameCard__c n3 = new NameCard__c(
        mobile__c = '333-3333-3333',
        Name = '高橋 三郎',
        company_name__c = '株式会社テスト３',
        Saishin__c = true,
        OwnerId = listUser[0].Id
    );
    NameCard__c n4 = new NameCard__c(
        tel1__c = '03-4444-4444',
        Name = '田中 四郎',
        company_name__c = '株式会社テスト４',
        Saishin__c = false,
        OwnerId = listUser[1].Id
    );
    insert new NameCard__c[]{n1, n2, n3, n4};

    System.runAs(listUser[0]) {
      List<SB_Connect_Client> clients = getClients();
      System.assertEquals(3, clients.size(), 'データ件数');

      n1 = [select Name, company_name__c, CreatedDate, LastModifiedDate from NameCard__c where Id = :n1.Id];
      n2 = [select Name, company_name__c, CreatedDate, LastModifiedDate from NameCard__c where Id = :n2.Id];
      n3 = [select Name, company_name__c, CreatedDate, LastModifiedDate from NameCard__c where Id = :n3.Id];

      for (SB_Connect_Client client : clients) {
        if (client.phone_number == '81311111111') {
            System.assertEquals('0311111111', client.original_phone_number, 'original_phone_number');
            System.assertEquals(n1.Name, client.full_name, 'full_name');
            System.assertEquals(n1.company_name__c, client.enterprise_name, 'enterprise_name');
            System.assert(!client.is_duplicate, 'is_duplicate');
            // System.assertEquals(String.valueOf(n1.CreatedDate), client.registered_date, 'registered_date');
            // System.assertEquals(String.valueOf(n1.LastModifiedDate), client.updated_date, 'updated_date');
        } else if (client.phone_number == '2222222222') {
            System.assertEquals('2222222222', client.original_phone_number, 'original_phone_number');
            System.assertEquals(n2.Name, client.full_name, 'full_name');
            System.assertEquals(n2.company_name__c, client.enterprise_name, 'enterprise_name');
            System.assert(!client.is_duplicate, 'is_duplicate');
            // System.assertEquals(String.valueOf(n2.CreatedDate), client.registered_date, 'registered_date');
            // System.assertEquals(String.valueOf(n2.LastModifiedDate), client.updated_date, 'updated_date');
        } else if (client.phone_number == '33333333333') {
            System.assertEquals('33333333333', client.original_phone_number, 'original_phone_number');
            System.assertEquals(n3.Name, client.full_name, 'full_name');
            System.assertEquals(n3.company_name__c, client.enterprise_name, 'enterprise_name');
            System.assert(!client.is_duplicate, 'is_duplicate');
            // System.assertEquals(String.valueOf(n3.CreatedDate), client.registered_date, 'registered_date');
            // System.assertEquals(String.valueOf(n3.LastModifiedDate), client.updated_date, 'updated_date');
        } else {
            System.assert(false);
        }
      }
    }
  }

  // /**
  //  * 一意の電話番号を複数持つ取引先責任者の場合、電話番号の件数分だけデータが取得されること
  //  */
  // @IsTest
  // private static void test020() {
  //     Test.startTest();
  //     Account a = new Account(Name = 'テスト株式会社');
  //     insert a;
  //     Contact c = new Contact(
  //         Phone = '11-1111-1111',
  //         HomePhone = '(03) 2222-2222',
  //         MobilePhone = '080-3333-3333',
  //         OtherPhone = '+81 4 4444-4444',
  //         LastName = '佐藤',
  //         FirstName = '一郎',
  //         AccountId = a.Id
  //     );
  //     insert c;
  //     Test.stopTest();

  //     List<SB_Connect_Client> clients = getClients();
  //     System.assertEquals(4, clients.size(), 'データ件数');

  //     c = [select Name, Account.Name, CreatedDate, LastModifiedDate from Contact, Contact.Account where Id = :c.Id];

  //     for (SB_Connect_Client client : clients) {
  //         if (client.phone_number == '1111111111') {
  //             System.assertEquals('1111111111', client.original_phone_number, 'original_phone_number');
  //         } else if (client.phone_number == '81322222222') {
  //             System.assertEquals('0322222222', client.original_phone_number, 'original_phone_number');
  //         } else if (client.phone_number == '818033333333') {
  //             System.assertEquals('08033333333', client.original_phone_number, 'original_phone_number');
  //         } else if (client.phone_number == '81444444444') {
  //             System.assertEquals('81444444444', client.original_phone_number, 'original_phone_number');
  //         } else {
  //             System.assert(false);
  //         }
  //         System.assertEquals(c.Name, client.full_name, 'full_name');
  //         System.assertEquals(c.Account.Name, client.enterprise_name, 'enterprise_name');
  //         System.assert(!client.is_duplicate, 'is_duplicate');
  //         System.assertEquals(String.valueOf(c.CreatedDate), client.registered_date, 'registered_date');
  //         System.assertEquals(String.valueOf(c.LastModifiedDate), client.updated_date, 'updated_date');
  //     }
  // }

  /**
    * 一意の電話番号を複数持つ名刺の場合、電話番号の件数分だけデータが取得されること
    */
  @IsTest
  private static void test021() {
    Test.startTest();

    List<User> listUser = [SELECT Id, Name FROM User WHERE ProfileId = :profStd.Id AND IsActive = true];
    NameCard__c n = new NameCard__c(
        tel1__c = '(03) 1111 1111',
        tel2__c = '0322222222',
        mobile__c = '090-3333-3333',
        Name = '佐藤 一郎',
        company_name__c = 'テスト株式会社',
        Saishin__c = true,
        OwnerId = listUser[0].Id
    );
    insert n;
    Test.stopTest();

    System.runAs(listUser[0]) {
      List<SB_Connect_Client> clients = getClients();
      System.assertEquals(3, clients.size(), 'データ件数');

      n = [select Name, company_name__c, CreatedDate, LastModifiedDate from NameCard__c where Id = :n.Id];

      for (SB_Connect_Client client : clients) {
          if (client.phone_number == '81311111111') {
              System.assertEquals('0311111111', client.original_phone_number, 'original_phone_number');
          } else if (client.phone_number == '81322222222') {
              System.assertEquals('0322222222', client.original_phone_number, 'original_phone_number');
          } else if (client.phone_number == '819033333333') {
              System.assertEquals('09033333333', client.original_phone_number, 'original_phone_number');
          } else {
              System.assert(false);
          }
          System.assertEquals(n.Name, client.full_name, 'full_name');
          System.assertEquals(n.company_name__c, client.enterprise_name, 'enterprise_name');
          System.assert(!client.is_duplicate, 'is_duplicate');
          // System.assertEquals(String.valueOf(n.CreatedDate), client.registered_date, 'registered_date');
          // System.assertEquals(String.valueOf(n.LastModifiedDate), client.updated_date, 'updated_date');
      }
    }
  }

  // /**
  //  * デフォルトの国番号と異なる国情報を持つ取引先責任者の場合、入力された国名の国番号始まりの電話番号が取得されること
  //  * また、Mailing CountryとOther Countryの両方に入力があった場合、Mailing Countryの方が優先されること
  //  */
  // @IsTest
  // private static void test030() {
  //     Test.startTest();
  //     Account a = new Account(Name = 'テスト株式会社');
  //     insert a;
  //     Contact c1 = new Contact(
  //         Phone = '01-1111-1111',
  //         LastName = '佐藤',
  //         FirstName = '一郎',
  //         MailingCountry = 'United States',
  //         OtherCountry = 'United Kingdom',
  //         AccountId = a.Id
  //     );
  //     Contact c2 = new Contact(
  //         Phone = '(02) 2222-2222',
  //         LastName = '鈴木',
  //         FirstName = '二郎',
  //         OtherCountry = 'United Kingdom',
  //         AccountId = a.Id
  //     );
  //     Contact c3 = new Contact(
  //         Phone = '03-3333-3333',
  //         LastName = '高橋',
  //         FirstName = '三郎',
  //         MailingCountry = '日本',
  //         AccountId = a.Id
  //     );
  //     Contact c4 = new Contact(
  //         Phone = '04-4444-4444',
  //         LastName = '田中',
  //         FirstName = '四郎',
  //         MailingCountry = 'サンブリッジ　テスト',
  //         AccountId = a.Id
  //     );
  //     insert new Contact[]{c1, c2, c3, c4};
  //     Test.stopTest();

  //     List<SB_Connect_Client> clients = getClients();
  //     System.assertEquals(4, clients.size(), 'データ件数');

  //     c1 = [select Name, Account.Name, CreatedDate, LastModifiedDate from Contact, Contact.Account where Id = :c1.Id];
  //     c2 = [select Name, Account.Name, CreatedDate, LastModifiedDate from Contact, Contact.Account where Id = :c2.Id];
  //     c3 = [select Name, Account.Name, CreatedDate, LastModifiedDate from Contact, Contact.Account where Id = :c3.Id];
  //     c4 = [select Name, Account.Name, CreatedDate, LastModifiedDate from Contact, Contact.Account where Id = :c4.Id];

  //     for (SB_Connect_Client client : clients) {
  //         if (client.phone_number == '1111111111') {
  //             System.assertEquals('0111111111', client.original_phone_number, 'original_phone_number');
  //             System.assertEquals(c1.Name, client.full_name, 'full_name');
  //             System.assertEquals(c1.Account.Name, client.enterprise_name, 'enterprise_name');
  //             System.assert(!client.is_duplicate, 'is_duplicate');
  //             System.assertEquals(String.valueOf(c1.CreatedDate), client.registered_date, 'registered_date');
  //             System.assertEquals(String.valueOf(c1.LastModifiedDate), client.updated_date, 'updated_date');
  //         } else if (client.phone_number == '44222222222') {
  //             System.assertEquals('0222222222', client.original_phone_number, 'original_phone_number');
  //             System.assertEquals(c2.Name, client.full_name, 'full_name');
  //             System.assertEquals(c2.Account.Name, client.enterprise_name, 'enterprise_name');
  //             System.assert(!client.is_duplicate, 'is_duplicate');
  //             System.assertEquals(String.valueOf(c2.CreatedDate), client.registered_date, 'registered_date');
  //             System.assertEquals(String.valueOf(c2.LastModifiedDate), client.updated_date, 'updated_date');
  //         } else if (client.phone_number == '81333333333') {
  //             System.assertEquals('0333333333', client.original_phone_number, 'original_phone_number');
  //             System.assertEquals(c3.Name, client.full_name, 'full_name');
  //             System.assertEquals(c3.Account.Name, client.enterprise_name, 'enterprise_name');
  //             System.assert(!client.is_duplicate, 'is_duplicate');
  //             System.assertEquals(String.valueOf(c3.CreatedDate), client.registered_date, 'registered_date');
  //             System.assertEquals(String.valueOf(c3.LastModifiedDate), client.updated_date, 'updated_date');
  //         } else if (client.phone_number == '81444444444') {
  //             System.assertEquals('0444444444', client.original_phone_number, 'original_phone_number');
  //             System.assertEquals(c4.Name, client.full_name, 'full_name');
  //             System.assertEquals(c4.Account.Name, client.enterprise_name, 'enterprise_name');
  //             System.assert(!client.is_duplicate, 'is_duplicate');
  //             System.assertEquals(String.valueOf(c4.CreatedDate), client.registered_date, 'registered_date');
  //             System.assertEquals(String.valueOf(c4.LastModifiedDate), client.updated_date, 'updated_date');
  //         } else {
  //             System.debug(client.phone_number);
  //             System.assert(false);
  //         }
  //     }
  // }

  // /**
  //  * 取引先責任者Aの電話番号 == 取引先責任者Bの電話番号 && 取引先責任者Aの最終更新日時 > 取引先責任者Bの最終更新日時の場合、
  //  * 取引先責任者Aのデータのみ取得できること
  //  */
  // @IsTest
  // private static void test040() {
  //     Test.startTest();
  //     Account a = new Account(Name = 'テスト株式会社');
  //     insert a;
  //     Contact c1 = new Contact(
  //         Phone = '03-1111-1111',
  //         LastName = '佐藤',
  //         FirstName = '一郎',
  //         AccountId = a.Id
  //     );
  //     insert c1;
  //     sleep(1000);
  //     Contact c2 = new Contact(
  //         OtherPhone = '(03) 1111-1111',
  //         LastName = '鈴木',
  //         FirstName = '二郎',
  //         AccountId = a.Id
  //     );
  //     insert c2;
  //     Test.stopTest();

  //     List<SB_Connect_Client> clients = getClients();
  //     System.assertEquals(1, clients.size(), 'データ件数');

  //     c2 = [select Name, Account.Name, CreatedDate, LastModifiedDate from Contact, Contact.Account where Id = :c2.Id];

  //     SB_Connect_Client client = clients.get(0);
  //     System.assertEquals('81311111111', client.phone_number, 'phone_number');
  //     System.assertEquals('0311111111', client.original_phone_number, 'original_phone_number');
  //     System.assertEquals(c2.Name, client.full_name, 'full_name');
  //     System.assertEquals(c2.Account.Name, client.enterprise_name, 'enterprise_name');
  //     System.assert(client.is_duplicate, 'is_duplicate');
  //     System.assertEquals(String.valueOf(c2.CreatedDate), client.registered_date, 'registered_date');
  //     System.assertEquals(String.valueOf(c2.LastModifiedDate), client.updated_date, 'updated_date');
  // }

  /**
    * 取引先責任者Aの電話番号 == 名刺Bの電話番号 && 取引先責任者Aの最終更新日時 >= 名刺Bの名刺交換日の場合
    * 取引先責任者Aの電話番号が取得されること
    */
  @IsTest
  private static void test041() {
    List<User> listUser = [SELECT Id, Name FROM User WHERE ProfileId = :profStd.Id AND IsActive = true];

    Test.startTest();
    NameCard__c n = new NameCard__c(
        tel1__c = '03-1111-1111',
        Name = '鈴木 二郎',
        company_name__c = '株式会社テスト',
        Saishin__c = true,
        OwnerId = listUser[0].Id
    );
    insert n;
    Account a = new Account(Name = 'テスト株式会社');
    insert a;
        Contact c = new Contact(
        Phone = '0311111111',
        LastName = '佐藤',
        FirstName = '一郎',
        AccountId = a.Id
    );
    insert c;
    Test.stopTest();

    SYstem.runAs(listUser[0]) {
      List<SB_Connect_Client> clients = getClients();
      System.assertEquals(1, clients.size(), 'データ件数');

      // c = [select Name, Account.Name, CreatedDate, LastModifiedDate from Contact, Contact.Account where Id = :c.Id];

      // SB_Connect_Client client = clients.get(0);
      // System.assertEquals('81311111111', client.phone_number, 'phone_number');
      // System.assertEquals('0311111111', client.original_phone_number, 'original_phone_number');
      // System.assertEquals(c.Name, client.full_name, 'full_name');
      // System.assertEquals(c.Account.Name, client.enterprise_name, 'enterprise_name');
      // System.assert(client.is_duplicate, 'is_duplicate');
      // System.assertEquals(String.valueOf(c.CreatedDate), client.registered_date, 'registered_date');
      // System.assertEquals(String.valueOf(c.LastModifiedDate), client.updated_date, 'updated_date');
    }
  }

  // /**
  //  * 取引先責任者Aの電話番号 == 名刺Bの電話番号 && 取引先責任者Aの最終更新日時 < 名刺Bの名刺交換日の場合
  //  * 名刺Bのデータが取得されること
  //  */
  // @IsTest
  // private static void test042() {
  //     Test.startTest();
  //     Account a = new Account(Name = 'テスト株式会社');
  //     insert a;
  //     Contact c = new Contact(
  //         Phone = '0311111111',
  //         LastName = '佐藤',
  //         FirstName = '一郎',
  //         AccountId = a.Id
  //     );
  //     insert c;
  //     sleep(1000);
  //     NameCard__c n = new NameCard__c(
  //         tel1__c = '03-1111-1111',
  //         Name = '鈴木 二郎',
  //         company_name__c = '株式会社テスト',
  //         Saishin__c = true
  //     );
  //     insert n;
  //     Test.stopTest();

  //     List<SB_Connect_Client> clients = getClients();
  //     System.assertEquals(1, clients.size(), 'データ件数');

  //     n = [select Name, company_name__c, CreatedDate, LastModifiedDate from NameCard__c where Id = :n.Id];

  //     SB_Connect_Client client = clients.get(0);
  //     System.assertEquals('81311111111', client.phone_number, 'phone_number');
  //     System.assertEquals('0311111111', client.original_phone_number, 'original_phone_number');
  //     System.assertEquals(n.Name, client.full_name, 'full_name');
  //     System.assertEquals(n.company_name__c, client.enterprise_name, 'enterprise_name');
  //     System.assert(client.is_duplicate, 'is_duplicate');
  //     System.assertEquals(String.valueOf(n.CreatedDate), client.registered_date, 'registered_date');
  //     System.assertEquals(String.valueOf(n.LastModifiedDate), client.updated_date, 'updated_date');
  // }

  /**
    * 名刺Aの電話番号 == 名刺Bの電話番号 && 名刺Aの名刺交換日 > 名刺Bの名刺交換日の場合
    * 名刺Aのデータが取得されること
    */
  @IsTest
  private static void test043() {
    List<User> listUser = [SELECT Id, Name FROM User WHERE ProfileId = :profStd.Id AND IsActive = true];
    Test.startTest();
    NameCard__c n1 = new NameCard__c(
        tel1__c = '03-1111-1111',
        Name = '佐藤 一郎',
        company_name__c = '株式会社テスト１',
        Saishin__c = true,
        OwnerId = listUser[0].Id
    );
    insert n1;
    sleep(1000);
    NameCard__c n2 = new NameCard__c(
        tel2__c = '03-1111-1111',
        Name = '鈴木 二郎',
        company_name__c = '株式会社テスト２',
        Saishin__c = true,
        OwnerId = listUser[0].Id
    );
    insert n2;
    Test.stopTest();

    System.runAs(listUser[0]) {
      List<SB_Connect_Client> clients = getClients();
      System.assertEquals(1, clients.size(), 'データ件数');

      n2 = [select Name, company_name__c, CreatedDate, LastModifiedDate from NameCard__c where Id = :n2.Id];

      SB_Connect_Client client = clients.get(0);
      System.assertEquals('81311111111', client.phone_number, 'phone_number');
      System.assertEquals('0311111111', client.original_phone_number, 'original_phone_number');
      // System.assertEquals(n2.Name, client.full_name, 'full_name');
      // System.assertEquals(n2.company_name__c, client.enterprise_name, 'enterprise_name');
      // System.assert(client.is_duplicate, 'is_duplicate');
      // System.assertEquals(String.valueOf(n2.CreatedDate), client.registered_date, 'registered_date');
      // System.assertEquals(String.valueOf(n2.LastModifiedDate), client.updated_date, 'updated_date');
    }
  }

  // /**
  //  * 取引先責任者Aの電話番号 != 取引先責任者Bの電話番号
  //  *   && 国番号始まりの取引先責任者Aの電話番号 == 国番号始まりの取引先責任者Bの電話番号
  //  *   && 取引先責任者Aの最終更新日時 > 取引先責任者Bの最終更新日時の場合、
  //  * 取引先責任者Aのデータが取得されること
  //  */
  // @IsTest
  // private static void test050() {
  //     Test.startTest();
  //     Account a = new Account(Name = 'テスト株式会社');
  //     insert a;
  //     Contact c1a = new Contact(
  //         Phone = '13-1111-1111',
  //         LastName = '佐藤',
  //         FirstName = '一郎',
  //         AccountId = a.Id
  //     );
  //     Contact c2a = new Contact(
  //         Phone = '(03) 2222-2222',
  //         LastName = '鈴木',
  //         FirstName = '二郎',
  //         AccountId = a.Id
  //     );
  //     Contact c3a = new Contact(
  //         MobilePhone = '090-3333-3333',
  //         LastName = '高橋',
  //         FirstName = '三郎',
  //         AccountId = a.Id
  //     );
  //     insert new Contact[]{c1a, c2a, c3a};
  //     sleep(1000);
  //     Contact c1b = new Contact(
  //         Phone = '03-1111-1111',
  //         LastName = '田中',
  //         FirstName = '四郎',
  //         MailingCountry = 'United States',
  //         AccountId = a.Id
  //     );
  //     Contact c2b = new Contact(
  //         HomePhone = '+81 3-2222-2222',
  //         LastName = '伊藤',
  //         FirstName = '五郎',
  //         OtherCountry = 'United States',
  //         AccountId = a.Id
  //     );
  //     Contact c3b = new Contact(
  //         MobilePhone = '(090) 3333-3333',
  //         LastName = '渡辺',
  //         FirstName = '六郎',
  //         MailingCountry = '日本',
  //         AccountId = a.Id
  //     );
  //     insert new Contact[]{c1b, c2b, c3b};
  //     Test.stopTest();

  //     List<SB_Connect_Client> clients = getClients();
  //     System.assertEquals(3, clients.size(), 'データ件数');

  //     c1b = [select Name, Account.Name, CreatedDate, LastModifiedDate from Contact, Contact.Account where Id = :c1b.Id];
  //     c2b = [select Name, Account.Name, CreatedDate, LastModifiedDate from Contact, Contact.Account where Id = :c2b.Id];
  //     c3b = [select Name, Account.Name, CreatedDate, LastModifiedDate from Contact, Contact.Account where Id = :c3b.Id];

  //     for (SB_Connect_Client client : clients) {
  //         if (client.phone_number == '1311111111') {
  //             System.assertEquals('0311111111', client.original_phone_number, 'original_phone_number');
  //             System.assertEquals(c1b.Name, client.full_name, 'full_name');
  //             System.assertEquals(c1b.Account.Name, client.enterprise_name, 'enterprise_name');
  //             System.assert(client.is_duplicate, 'is_duplicate');
  //             System.assertEquals(String.valueOf(c1b.CreatedDate), client.registered_date, 'registered_date');
  //             System.assertEquals(String.valueOf(c1b.LastModifiedDate), client.updated_date, 'updated_date');
  //         } else if (client.phone_number == '81322222222') {
  //             System.assertEquals('81322222222', client.original_phone_number, 'original_phone_number');
  //             System.assertEquals(c2b.Name, client.full_name, 'full_name');
  //             System.assertEquals(c2b.Account.Name, client.enterprise_name, 'enterprise_name');
  //             System.assert(client.is_duplicate, 'is_duplicate');
  //             System.assertEquals(String.valueOf(c2b.CreatedDate), client.registered_date, 'registered_date');
  //             System.assertEquals(String.valueOf(c2b.LastModifiedDate), client.updated_date, 'updated_date');
  //         } else if (client.phone_number == '819033333333') {
  //             System.assertEquals('09033333333', client.original_phone_number, 'original_phone_number');
  //             System.assertEquals(c3b.Name, client.full_name, 'full_name');
  //             System.assertEquals(c3b.Account.Name, client.enterprise_name, 'enterprise_name');
  //             System.assert(client.is_duplicate, 'is_duplicate');
  //             System.assertEquals(String.valueOf(c3b.CreatedDate), client.registered_date, 'registered_date');
  //             System.assertEquals(String.valueOf(c3b.LastModifiedDate), client.updated_date, 'updated_date');
  //         } else {
  //             System.assert(false);
  //         }
  //     }
  // }

  // /**
  //   * 取引先責任者Aの電話番号 != 名刺Bの電話番号
  //   *   && 国番号始まりの取引先責任者Aの電話番号 == 国番号始まりの名刺Bの電話番号
  //   *   && 取引先責任者Aの最終更新日時 >= 名刺Bの名刺交換日の場合、
  //   * 取引先責任者Aのデータが取得されること
  //   */
  // @IsTest
  // private static void test051() {
  //     Test.startTest();
  //     NameCard__c n1 = new NameCard__c(
  //         tel1__c = '+81 3 1111-1111',
  //         Name = '佐藤 一郎',
  //         company_name__c = 'テストA株式会社',
  //         Saishin__c = true
  //     );
  //     NameCard__c n2 = new NameCard__c(
  //         tel1__c = '442-2222-2222',
  //         Name = '鈴木 二郎',
  //         company_name__c = 'テストB株式会社',
  //         Saishin__c = true
  //     );
  //     NameCard__c n3 = new NameCard__c(
  //         tel1__c = '(03) 3333-3333',
  //         Name = '高橋 三郎',
  //         company_name__c = 'テストC株式会社',
  //         Saishin__c = true
  //     );
  //     insert new NameCard__c[]{n1, n2, n3};
  //     sleep(1000);
  //     Account a = new Account(Name = 'テスト株式会社');
  //     insert a;
  //     Contact c1 = new Contact(
  //         Phone = '(03) 1111-1111',
  //         LastName = '田中',
  //         FirstName = '四郎',
  //         AccountId = a.Id
  //     );
  //     Contact c2 = new Contact(
  //         Phone = '(02) 2222-2222',
  //         LastName = '伊藤',
  //         FirstName = '五郎',
  //         MailingCountry = 'United Kingdom',
  //         AccountId = a.Id
  //     );
  //     Contact c3 = new Contact(
  //         Phone = '+81 3-3333-3333',
  //         LastName = '渡辺',
  //         FirstName = '六郎',
  //         MailingCountry = 'United States',
  //         AccountId = a.Id
  //     );
  //     insert new Contact[]{c1, c2, c3};
  //     Test.stopTest();

  //     List<SB_Connect_Client> clients = getClients();
  //     System.assertEquals(3, clients.size(), 'データ件数');

  //     c1 = [select Name, Account.Name, CreatedDate, LastModifiedDate from Contact, Contact.Account where Id = :c1.Id];
  //     c2 = [select Name, Account.Name, CreatedDate, LastModifiedDate from Contact, Contact.Account where Id = :c2.Id];
  //     c3 = [select Name, Account.Name, CreatedDate, LastModifiedDate from Contact, Contact.Account where Id = :c3.Id];

  //     for (SB_Connect_Client client : clients) {
  //         if (client.phone_number == '81311111111') {
  //             System.assertEquals('0311111111', client.original_phone_number, 'original_phone_number');
  //             System.assertEquals(c1.Name, client.full_name, 'full_name');
  //             System.assertEquals(c1.Account.Name, client.enterprise_name, 'enterprise_name');
  //             System.assert(client.is_duplicate, 'is_duplicate');
  //             System.assertEquals(String.valueOf(c1.CreatedDate), client.registered_date, 'registered_date');
  //             System.assertEquals(String.valueOf(c1.LastModifiedDate), client.updated_date, 'updated_date');
  //         } else if (client.phone_number == '44222222222') {
  //             System.assertEquals('0222222222', client.original_phone_number, 'original_phone_number');
  //             System.assertEquals(c2.Name, client.full_name, 'full_name');
  //             System.assertEquals(c2.Account.Name, client.enterprise_name, 'enterprise_name');
  //             System.assert(client.is_duplicate, 'is_duplicate');
  //             System.assertEquals(String.valueOf(c2.CreatedDate), client.registered_date, 'registered_date');
  //             System.assertEquals(String.valueOf(c2.LastModifiedDate), client.updated_date, 'updated_date');
  //         } else if (client.phone_number == '81333333333') {
  //             System.assertEquals('81333333333', client.original_phone_number, 'original_phone_number');
  //             System.assertEquals(c3.Name, client.full_name, 'full_name');
  //             System.assertEquals(c3.Account.Name, client.enterprise_name, 'enterprise_name');
  //             System.assert(client.is_duplicate, 'is_duplicate');
  //             System.assertEquals(String.valueOf(c3.CreatedDate), client.registered_date, 'registered_date');
  //             System.assertEquals(String.valueOf(c3.LastModifiedDate), client.updated_date, 'updated_date');
  //         } else {
  //             System.assert(false);
  //         }
  //     }
  // }

  // /**
  //  * 取引先責任者Aの電話番号 != 名刺Bの電話番号
  //  *   && 国番号始まりの取引先責任者Aの電話番号 == 国番号始まりの名刺Bの電話番号
  //  *   && 取引先責任者Aの最終更新日時 < 名刺Bの名刺交換日の場合、
  //  * 名刺Bのデータが取得されること
  //  */
  // @IsTest
  // private static void test052() {
  //     Test.startTest();
  //     Account a = new Account(Name = 'テスト株式会社');
  //     insert a;
  //     Contact c1 = new Contact(
  //         Phone = '01-1111-1111',
  //         LastName = '佐藤',
  //         FirstName = '一郎',
  //         MailingCountry = 'United States',
  //         AccountId = a.Id
  //     );
  //     Contact c2 = new Contact(
  //         Phone = '(22) 2222-2222',
  //         LastName = '鈴木',
  //         FirstName = '二郎',
  //         AccountId = a.Id
  //     );
  //     Contact c3 = new Contact(
  //         Phone = '03-3333-3333',
  //         LastName = '高橋',
  //         FirstName = '三郎',
  //         AccountId = a.Id
  //     );
  //     insert new Contact[]{c1, c2, c3};
  //     sleep(1000);
  //     NameCard__c n1 = new NameCard__c(
  //         tel1__c = '+1 1 1111-1111',
  //         Name = '田中 四郎',
  //         company_name__c = 'テスト株式会社',
  //         Saishin__c = true
  //     );
  //     NameCard__c n2 = new NameCard__c(
  //         tel1__c = '22-2222-2222',
  //         Name = '伊藤 五郎',
  //         company_name__c = 'テスト株式会社',
  //         Saishin__c = true
  //     );
  //     NameCard__c n3 = new NameCard__c(
  //         tel1__c = '+81 3 3333-3333',
  //         Name = '渡辺 六郎',
  //         company_name__c = 'テスト株式会社',
  //         Saishin__c = true
  //     );
  //     insert new NameCard__c[]{n1, n2, n3};
  //     Test.stopTest();

  //     List<SB_Connect_Client> clients = getClients();
  //     System.assertEquals(3, clients.size(), 'データ件数');

  //     n1 = [select Name, company_name__c, CreatedDate, LastModifiedDate from NameCard__c where Id = :n1.Id];
  //     n2 = [select Name, company_name__c, CreatedDate, LastModifiedDate from NameCard__c where Id = :n2.Id];
  //     n3 = [select Name, company_name__c, CreatedDate, LastModifiedDate from NameCard__c where Id = :n3.Id];

  //     for (SB_Connect_Client client : clients) {
  //         if (client.phone_number == '1111111111') {
  //             System.assertEquals('1111111111', client.original_phone_number, 'original_phone_number');
  //             System.assertEquals(n1.Name, client.full_name, 'full_name');
  //             System.assertEquals(n1.company_name__c, client.enterprise_name, 'enterprise_name');
  //             System.assert(client.is_duplicate, 'is_duplicate');
  //             System.assertEquals(String.valueOf(n1.CreatedDate), client.registered_date, 'registered_date');
  //             System.assertEquals(String.valueOf(n1.LastModifiedDate), client.updated_date, 'updated_date');
  //         } else if (client.phone_number == '2222222222') {
  //             System.assertEquals('2222222222', client.original_phone_number, 'original_phone_number');
  //             System.assertEquals(n2.Name, client.full_name, 'full_name');
  //             System.assertEquals(n2.company_name__c, client.enterprise_name, 'enterprise_name');
  //             System.assert(client.is_duplicate, 'is_duplicate');
  //             System.assertEquals(String.valueOf(n2.CreatedDate), client.registered_date, 'registered_date');
  //             System.assertEquals(String.valueOf(n2.LastModifiedDate), client.updated_date, 'updated_date');
  //         } else if (client.phone_number == '81333333333') {
  //             System.assertEquals('81333333333', client.original_phone_number, 'original_phone_number');
  //             System.assertEquals(n3.Name, client.full_name, 'full_name');
  //             System.assertEquals(n3.company_name__c, client.enterprise_name, 'enterprise_name');
  //             System.assert(client.is_duplicate, 'is_duplicate');
  //             System.assertEquals(String.valueOf(n3.CreatedDate), client.registered_date, 'registered_date');
  //             System.assertEquals(String.valueOf(n3.LastModifiedDate), client.updated_date, 'updated_date');
  //         } else {
  //             System.assert(false);
  //         }
  //     }
  // }

  /**
    * 名刺Aの電話番号 != 名刺Bの電話番号
    *   && 国番号始まりの名刺Aの電話番号 == 国番号始まりの名刺Bの電話番号
    *   && 名刺Aの名刺交換日 > 名刺Bの名刺交換日の場合、
    * 名刺Aのデータが取得されること
    */
  @IsTest
  private static void test053() {
    List<User> listUser = [SELECT Id, Name FROM User WHERE ProfileId = :profStd.Id AND IsActive = true];
    Test.startTest();
    NameCard__c n1 = new NameCard__c(
      tel1__c = '(03) 1111-1111',
      Name = '佐藤 一郎',
      company_name__c = 'テスト株式会社',
      Saishin__c = true,
      OwnerId = listUser[0].Id
    );
    insert n1;
    sleep(1000);
    NameCard__c n2 = new NameCard__c(
      tel2__c = '+81 3 1111-1111',
      Name = '鈴木 二郎',
      company_name__c = 'テスト株式会社',
      Saishin__c = true,
      OwnerId = listUser[0].Id
    );
    insert n2;
    Test.stopTest();

    System.runAs(listUser[0]) {
      List<SB_Connect_Client> clients = getClients();
      System.assertEquals(1, clients.size(), 'データ件数');

      n2 = [select Name, company_name__c, CreatedDate, LastModifiedDate from NameCard__c where Id = :n2.Id];

      SB_Connect_Client client = clients.get(0);
      System.assertEquals('81311111111', client.phone_number, 'phone_number');
      // System.assertEquals('81311111111', client.original_phone_number, 'original_phone_number');
      // System.assertEquals(n2.Name, client.full_name, 'full_name');
      // System.assertEquals(n2.company_name__c, client.enterprise_name, 'enterprise_name');
      // System.assert(client.is_duplicate, 'is_duplicate');
      // System.assertEquals(String.valueOf(n2.CreatedDate), client.registered_date, 'registered_date');
      // System.assertEquals(String.valueOf(n2.LastModifiedDate), client.updated_date, 'updated_date');
    }
  }

  // /**
  //  * 取引先責任者Aの電話番号 == 取引先責任者Bの電話番号
  //  *   && 国番号始まりの取引先責任者Aの電話番号 != 国番号始まりの取引先責任者Bの電話番号の場合、
  //  * 取引先責任者A、Bの両方のデータが取得されること
  //  */
  // @IsTest
  // private static void test060() {
  //     Test.startTest();
  //     Account a = new Account(Name = 'テスト株式会社');
  //     insert a;
  //     Contact c1 = new Contact(
  //         Phone = '03-1111-1111',
  //         LastName = '佐藤',
  //         FirstName = '一郎',
  //         MailingCountry = '日本',
  //         AccountId = a.Id
  //     );
  //     Contact c2 = new Contact(
  //         Phone = '03-1111-1111',
  //         LastName = '鈴木',
  //         FirstName = '二郎',
  //         OtherCountry = 'United States',
  //         AccountId = a.Id
  //     );
  //     insert new Contact[]{c1, c2};
  //     Test.stopTest();

  //     List<SB_Connect_Client> clients = getClients();
  //     System.assertEquals(2, clients.size(), 'データ件数');

  //     c1 = [select Name, Account.Name, CreatedDate, LastModifiedDate from Contact, Contact.Account where Id = :c1.Id];
  //     c2 = [select Name, Account.Name, CreatedDate, LastModifiedDate from Contact, Contact.Account where Id = :c2.Id];

  //     for (SB_Connect_Client client : clients) {
  //         if (client.phone_number == '81311111111') {
  //             System.assertEquals('0311111111', client.original_phone_number, 'original_phone_number');
  //             System.assertEquals(c1.Name, client.full_name, 'full_name');
  //             System.assertEquals(c1.Account.Name, client.enterprise_name, 'enterprise_name');
  //             System.assert(!client.is_duplicate, 'is_duplicate');
  //             System.assertEquals(String.valueOf(c1.CreatedDate), client.registered_date, 'registered_date');
  //             System.assertEquals(String.valueOf(c1.LastModifiedDate), client.updated_date, 'updated_date');
  //         } else if (client.phone_number == '1311111111') {
  //             System.assertEquals('0311111111', client.original_phone_number, 'original_phone_number');
  //             System.assertEquals(c2.Name, client.full_name, 'full_name');
  //             System.assertEquals(c2.Account.Name, client.enterprise_name, 'enterprise_name');
  //             System.assert(!client.is_duplicate, 'is_duplicate');
  //             System.assertEquals(String.valueOf(c2.CreatedDate), client.registered_date, 'registered_date');
  //             System.assertEquals(String.valueOf(c2.LastModifiedDate), client.updated_date, 'updated_date');
  //         } else {
  //             System.assert(false);
  //         }
  //     }
  // }

  // /**
  //  * 取引先責任者Aの電話番号 == 名刺Bの電話番号
  //  *   && 国番号始まりの取引先責任者Aの電話番号 != 国番号始まりの名刺Bの電話番号の場合、
  //  * 取引先責任者A、名刺Bの両方のデータが取得されること
  //  */
  // @IsTest
  // private static void test061() {
  //     Test.startTest();
  //     Account a = new Account(Name = 'テスト株式会社');
  //     insert a;
  //     Contact c = new Contact(
  //         Phone = '03-1111-1111',
  //         LastName = '佐藤',
  //         FirstName = '一郎',
  //         OtherCountry = 'United Kingdom',
  //         AccountId = a.Id
  //     );
  //     insert c;
  //     NameCard__c n = new NameCard__c(
  //         tel2__c = '03-1111-1111',
  //         Name = '鈴木 二郎',
  //         company_name__c = 'テスト株式会社',
  //         Saishin__c = true
  //     );
  //     insert n;
  //     Test.stopTest();

  //     List<SB_Connect_Client> clients = getClients();
  //     System.assertEquals(2, clients.size(), 'データ件数');

  //     c = [select Name, Account.Name, CreatedDate, LastModifiedDate from Contact, Contact.Account where Id = :c.Id];
  //     n = [select Name, company_name__c, CreatedDate, LastModifiedDate from NameCard__c where Id = :n.Id];

  //     for (SB_Connect_Client client : clients) {
  //         if (client.phone_number == '44311111111') {
  //             System.assertEquals('0311111111', client.original_phone_number, 'original_phone_number');
  //             System.assertEquals(c.Name, client.full_name, 'full_name');
  //             System.assertEquals(c.Account.Name, client.enterprise_name, 'enterprise_name');
  //             System.assert(!client.is_duplicate, 'is_duplicate');
  //             System.assertEquals(String.valueOf(c.CreatedDate), client.registered_date, 'registered_date');
  //             System.assertEquals(String.valueOf(c.LastModifiedDate), client.updated_date, 'updated_date');
  //         } else if (client.phone_number == '81311111111') {
  //             System.assertEquals('0311111111', client.original_phone_number, 'original_phone_number');
  //             System.assertEquals(n.Name, client.full_name, 'full_name');
  //             System.assertEquals(n.company_name__c, client.enterprise_name, 'enterprise_name');
  //             System.assert(!client.is_duplicate, 'is_duplicate');
  //             System.assertEquals(String.valueOf(n.CreatedDate), client.registered_date, 'registered_date');
  //             System.assertEquals(String.valueOf(n.LastModifiedDate), client.updated_date, 'updated_date');
  //         } else {
  //             System.assert(false);
  //         }
  //     }
  // }

  /**
    * 会社名が設定されていない名刺の場合、会社名がブランク(空文字)となること
    */
  @IsTest
  private static void test070() {
    List<User> listUser = [SELECT Id, Name FROM User WHERE ProfileId = :profStd.Id AND IsActive = true];
    Test.startTest();
    NameCard__c n = new NameCard__c(
        tel1__c = '03-1111-1111',
        Name = '佐藤 一郎',
        Saishin__c = true,
        OwnerId = listUser[0].Id
    );
    insert n;
    Test.stopTest();

    System.runAs(listUser[0]) {
      List<SB_Connect_Client> clients = getClients();
      System.assertEquals(1, clients.size(), 'データ件数');

      n = [select Name, company_name__c, CreatedDate, LastModifiedDate from NameCard__c where Id = :n.Id];

      SB_Connect_Client client = clients.get(0);
      System.assertEquals('81311111111', client.phone_number, 'phone_number');
      System.assertEquals('0311111111', client.original_phone_number, 'original_phone_number');
      System.assertEquals(n.Name, client.full_name, 'full_name');
      System.assertEquals('', client.enterprise_name, 'enterprise_name');
      System.assert(!client.is_duplicate, 'is_duplicate');
      // System.assertEquals(String.valueOf(n.CreatedDate), client.registered_date, 'registered_date');
      // System.assertEquals(String.valueOf(n.LastModifiedDate), client.updated_date, 'updated_date');
    }
  }

  /**
    * APIでレスポンスするデータを取得します。
    */
  private static List<SB_Connect_Client> getClients() {
      RestRequest req = new RestRequest();
      RestContext.request = req;
      Map<String, List<SB_Connect_Client>> clientMap =  SB_Connect_ClientController.getClients();
      System.debug(JSON.serialize(clientMap));
      return clientMap.get('clients');
  }

  /**
    * テスト観点一覧
    *
    * 表示 / 非表示観点
    *   1. 電話番号を一つだけ持ち、重複もないため表示されるユーザ
    *   2. 複数の電話番号を持ち、その番号の分だけ表示されるユーザ
    *   3. 電話番号を持たないため表示されないユーザ
    *
    * 重複フラグ観点
    *   4. 電話番号が重複していないユーザ ※1と同じ
    *   5. 電話番号が重複しているため表示されないユーザ
    *   6. 電話番号が重複していても最終更新日時がもっとも新しいため表示されるユーザ
    *   7. 電話番号が重複しているが国情報が異なるため表示されるユーザ
    *   8. 電話番号が重複しており、国情報も同じため表示されないユーザ
    *
    * 国番号始まり観点
    *   9. 国情報を持たないユーザ (デフォルトの国番号81始まり)
    *  10. メタデータに設定されている国情報を持つユーザ
    *  11. メタデータに設定されている複数の国情報を持つユーザ ※優先順位の確認
    *  12. メタデータに設定されている国情報とは異なる国情報を持つユーザ
    *
    * 電話番号のフォーマット観点
    *  13. 電話番号のフォーマットが (03) 0000-0000 または (090) 0000-0000
    *  14. 電話番号のフォーマットが 03-0000-0000 または 090-0000-0000
    *  15. 電話番号のフォーマットが 1-0000-0000 ※国番号始まり デフォルトの日本の国番号以外の場合
    *  16. 電話番号のフォーマットが 100000000 かつ 国情報がアメリカの場合
    *  17. 電話番号のフォーマットが 100000000 かつ 国情報がアメリカ以外の場合
    *  18. 電話番号のフォーマットが +81 0 0000-0000 かつ 国情報がない場合
    */

  // /**
  //  * 観点1, 4, 9, 10, 13, 14
  //  */
  //  @isTest
  // private static void test1() {
  //     Test.startTest();
  //     Account a1 = new Account(Name = '株式会社テスト１');
  //     insert a1;
  //     Contact c1 = new Contact(
  //         Phone = '(03) 1111-1111',
  //         LastName = '佐藤',
  //         FirstName = '一郎',
  //         MailingCountry = 'アメリカ',
  //         AccountId = a1.Id
  //     );
  //     insert c1;
  //     NameCard__c n1 = new NameCard__c(
  //         tel1__c = '06-2222-2222',
  //         person_name_last__c = '鈴木',
  //         person_name_first__c = '二郎',
  //         company_name__c = '株式会社テスト２'
  //     );
  //     insert n1;
  //     Test.stopTest();

  //     RestRequest req = new RestRequest();
  //     RestContext.request = req;
  //     Map<String, List<SB_Connect_Client>> clientMap =  SB_Connect_ClientController.getClients();
  //     System.debug(JSON.serialize(clientMap));

  //     List<SB_Connect_Client> clients = clientMap.get(KEY);
  //     System.assertEquals(2, clients.size());
  //     for (SB_Connect_Client client : clientMap.get(KEY)) {
  //         if (client.phone_number == '1311111111') {
  //             System.assertEquals('0311111111', client.original_phone_number, 'original_phone_number');
  //             System.assertEquals('佐藤 一郎', client.full_name, 'full_name');
  //             System.assertEquals('株式会社テスト１', client.enterprise_name, 'enterprise_name');
  //             System.assert(!client.is_duplicate, 'is_duplicate');
  //             System.assert(client.registered_date != null, 'registered_date');
  //             System.assert(client.updated_date != null, 'updated_date');
  //         } else if (client.phone_number == '81622222222') {
  //             System.assertEquals('0622222222', client.original_phone_number, 'original_phone_number');
  //             System.assertEquals('鈴木 二郎', client.full_name, 'full_name');
  //             System.assertEquals('株式会社テスト２', client.enterprise_name, 'enterprise_name');
  //             System.assert(!client.is_duplicate, 'is_duplicate');
  //             System.assert(client.registered_date != null, 'registerd_date');
  //             System.assert(client.updated_date != null, 'updated_date');
  //         } else {
  //             System.assert(false); // 上記以外の電話番号が存在した場合、エラー
  //         }
  //     }
  // }

  // /**
  //  * 観点2, 3, 4, 15
  //  */
  //  @isTest
  // private static void test2() {
  //     Test.startTest();
  //     Account a1 = new Account(Name = '株式会社テスト１');
  //     Account a2 = new Account(Name = '株式会社テスト２');
  //     insert new Account[]{a1, a2};
  //     Contact c1 = new Contact( // レスポンス4つ
  //         Phone = '81311111111',
  //         HomePhone = '0311111112',
  //         MobilePhone = '090-1111-1111',
  //         OtherPhone = '(03)11111113',
  //         LastName = '佐藤',
  //         FirstName = '一郎',
  //         AccountId = a1.Id
  //     );
  //     Contact c2 = new Contact( // レスポンスされない
  //         LastName = '鈴木',
  //         FirstName = '二郎',
  //         AccountId = a2.Id
  //     );
  //     insert new Contact[]{c1, c2};
  //     NameCard__c n1 = new NameCard__c( // レスポンス２つ
  //         tel1__c = '1-3-3333-3333',
  //         tel2__c = '1-80-3333-3333',
  //         person_name_last__c = '高橋',
  //         person_name_first__c = '三郎',
  //         company_name__c = '株式会社テスト３'
  //     );
  //     NameCard__c n2 = new NameCard__c( // レスポンスされない
  //         person_name_last__c = '田中',
  //         person_name_first__c = '四郎',
  //         company_name__c = '株式会社テスト４'
  //     );
  //     insert new NameCard__c[]{n1, n2};
  //     Test.stopTest();

  //     RestRequest req = new RestRequest();
  //     RestContext.request = req;
  //     Map<String, List<SB_Connect_Client>> clientMap =  SB_Connect_ClientController.getClients();
  //     System.debug(JSON.serialize(clientMap));

  //     List<SB_Connect_Client> clients = clientMap.get(KEY);
  //     System.assertEquals(6, clients.size());
  //     for (SB_Connect_Client client : clients) {
  //         if (client.phone_number == '81311111111') {
  //             System.assertEquals('81311111111', client.original_phone_number, 'original_phone_number');
  //             System.assertEquals('佐藤 一郎', client.full_name, 'full_name');
  //             System.assertEquals('株式会社テスト１', client.enterprise_name, 'enterprise_name');
  //             System.assert(!client.is_duplicate, 'is_duplicate');
  //             System.assert(client.registered_date != null, 'registered_date');
  //             System.assert(client.updated_date != null, 'updated_date');
  //         } else if (client.phone_number == '81311111112') {
  //             System.assertEquals('0311111112', client.original_phone_number, 'original_phone_number');
  //             System.assertEquals('佐藤 一郎', client.full_name, 'full_name');
  //             System.assertEquals('株式会社テスト１', client.enterprise_name, 'enterprise_name');
  //             System.assert(!client.is_duplicate, 'is_duplicate');
  //             System.assert(client.registered_date != null, 'registered_date');
  //             System.assert(client.updated_date != null, 'updated_date');
  //         } else if (client.phone_number == '819011111111') {
  //             System.assertEquals('09011111111', client.original_phone_number, 'original_phone_number');
  //             System.assertEquals('佐藤 一郎', client.full_name, 'full_name');
  //             System.assertEquals('株式会社テスト１', client.enterprise_name, 'enterprise_name');
  //             System.assert(!client.is_duplicate, 'is_duplicate');
  //             System.assert(client.registered_date != null, 'registered_date');
  //             System.assert(client.updated_date != null, 'updated_date');
  //         } else if (client.phone_number == '81311111113') {
  //             System.assertEquals('0311111113', client.original_phone_number, 'original_phone_number');
  //             System.assertEquals('佐藤 一郎', client.full_name, 'full_name');
  //             System.assertEquals('株式会社テスト１', client.enterprise_name, 'enterprise_name');
  //             System.assert(!client.is_duplicate, 'is_duplicate');
  //             System.assert(client.registered_date != null, 'registered_date');
  //             System.assert(client.updated_date != null, 'updated_date');
  //         } else if (client.phone_number == '1333333333') {
  //             System.assertEquals('1333333333', client.original_phone_number, 'original_phone_number');
  //             System.assertEquals('高橋 三郎', client.full_name, 'full_name');
  //             System.assertEquals('株式会社テスト３', client.enterprise_name, 'enterprise_name');
  //             System.assert(!client.is_duplicate, 'is_duplicate');
  //             System.assert(client.registered_date != null, 'registered_date');
  //             System.assert(client.updated_date != null, 'updated_date');
  //         } else if (client.phone_number == '18033333333') {
  //             System.assertEquals('18033333333', client.original_phone_number, 'original_phone_number');
  //             System.assertEquals('高橋 三郎', client.full_name, 'full_name');
  //             System.assertEquals('株式会社テスト３', client.enterprise_name, 'enterprise_name');
  //             System.assert(!client.is_duplicate, 'is_duplicate');
  //             System.assert(client.registered_date != null, 'registered_date');
  //             System.assert(client.updated_date != null, 'updated_date');
  //         } else {
  //             System.assert(false); // 上記以外の電話番号が存在した場合、エラー
  //         }
  //     }
  // }

  // /**
  //  * 観点5, 6, 12, 18
  //  */
  // @isTest
  // private static void test3() {
  //     Test.startTest();
  //     Account a1 = new Account(Name = '株式会社テスト１');
  //     Account a2 = new Account(Name = '株式会社テスト２');
  //     insert new Account[]{a1, a2};
  //     Contact c1 = new Contact( // 表示されない
  //         Phone = '0311111111',
  //         LastName = '佐藤',
  //         FirstName = '一郎',
  //         AccountId = a1.Id
  //     );
  //     insert c1;
  //     sleep(1000);
  //     Contact c2 = new Contact( // 表示されない
  //         Phone = '(03) 1111-1111',
  //         LastName = '鈴木',
  //         FirstName = '二郎',
  //         AccountId = a2.Id
  //     );
  //     insert c2;
  //     sleep(1000);
  //     Contact c3 = new Contact( // 表示される
  //         HomePhone = '03-1111-1111',
  //         LastName = '高橋',
  //         FirstName = '三郎',
  //         OtherCountry = 'テスト',
  //         AccountId = a1.Id
  //     );
  //     insert c3;
  //     NameCard__c n1 = new NameCard__c( // 表示されない
  //         tel1__c = '0644444444',
  //         person_name_last__c = '田中',
  //         person_name_first__c = '四郎',
  //         company_name__c = '株式会社テスト' // 会社名も表示されない
  //     );
  //     insert n1;
  //     sleep(1000);
  //     NameCard__c n2 = new NameCard__c( // 表示される
  //         tel2__c = '(816) 4444-4444',
  //         person_name_last__c = '伊藤',
  //         person_name_first__c = '五郎'
  //     );
  //     insert n2;
  //     Test.stopTest();

  //     RestRequest req = new RestRequest();
  //     RestContext.request = req;
  //     Map<String, List<SB_Connect_Client>> clientMap =  SB_Connect_ClientController.getClients();
  //     System.debug(JSON.serialize(clientMap));
  //     List<SB_Connect_Client> clients = clientMap.get(KEY);
  //     System.assertEquals(2, clients.size());
  //     for (SB_Connect_Client client : clients) {
  //         if (client.phone_number == '81311111111') {
  //             System.assertEquals('0311111111', client.original_phone_number, 'original_phone_number');
  //             System.assertEquals('高橋 三郎', client.full_name, 'full_name');
  //             System.assertEquals('株式会社テスト１', client.enterprise_name, 'enterprise_name');
  //             System.assert(client.is_duplicate, 'is_duplicate');
  //             System.assert(client.registered_date != null, 'registered_date');
  //             System.assert(client.updated_date != null, 'updated_date');
  //         } else if (client.phone_number == '81644444444') {
  //             System.assertEquals('81644444444', client.original_phone_number, 'original_phone_number');
  //             System.assertEquals('伊藤 五郎', client.full_name, 'full_name');
  //             System.assert(client.enterprise_name == null, 'enterprise_name');
  //             System.assert(client.is_duplicate, 'is_duplicate');
  //             System.assert(client.registered_date != null, 'registered_date');
  //             System.assert(client.updated_date != null, 'updated_date');
  //         } else {
  //             System.assert(false); // 上記以外の電話番号が存在した場合、エラー
  //         }
  //     }
  // }

  // /**
  //  * 観点7, 8
  //  */
  // @isTest
  // private static void test4() {
  //     Test.startTest();
  //     Account a1 = new Account(Name = '株式会社テスト１');
  //     Account a2 = new Account(Name = '株式会社テスト２');
  //     Account a3 = new Account(Name = '株式会社テスト３');
  //     insert new Account[]{a1, a2, a3};
  //     Contact c1 = new Contact( // 表示されない
  //         Phone = '0311111111',
  //         LastName = '佐藤',
  //         FirstName = '一郎',
  //         MailingCountry = 'アメリカ',
  //         AccountId = a1.Id
  //     );
  //     insert c1;
  //     sleep(1000);
  //     Contact c2 = new Contact( // 表示される
  //         HomePhone = '+813 1111-1111',
  //         LastName = '鈴木',
  //         FirstName = '二郎',
  //         OtherCountry = '日本',
  //         AccountId = a2.Id
  //     );
  //     Contact c3 = new Contact( // 表示される
  //         OtherPhone = '03-1111-1111',
  //         LastName = '高橋',
  //         FirstName = '三郎',
  //         OtherCountry = 'United States',
  //         AccountId = a3.Id
  //     );
  //     insert new Contact[] {c2, c3};
  //     Test.stopTest();

  //     RestRequest req = new RestRequest();
  //     RestContext.request = req;
  //     Map<String, List<SB_Connect_Client>> clientMap =  SB_Connect_ClientController.getClients();
  //     System.debug(JSON.serialize(clientMap));
  //     List<SB_Connect_Client> clients = clientMap.get(KEY);
  //     System.assertEquals(2, clients.size());
  //     for (SB_Connect_Client client : clients) {
  //         if (client.phone_number == '81311111111') {
  //             System.assertEquals('81311111111', client.original_phone_number, 'original_phone_number');
  //             System.assertEquals('鈴木 二郎', client.full_name, 'full_name');
  //             System.assertEquals('株式会社テスト２', client.enterprise_name, 'enterprise_name');
  //             System.assert(!client.is_duplicate, 'is_duplicate');
  //             System.assert(client.registered_date != null, 'registered_date');
  //             System.assert(client.updated_date != null, 'updated_date');
  //         } else if (client.phone_number == '1311111111') {
  //             System.assertEquals('0311111111', client.original_phone_number, 'original_phone_number');
  //             System.assertEquals('高橋 三郎', client.full_name, 'full_name');
  //             System.assertEquals('株式会社テスト３', client.enterprise_name, 'enterprise_name');
  //             System.assert(client.is_duplicate, 'is_duplicate');
  //             System.assert(client.registered_date != null, 'registered_date');
  //             System.assert(client.updated_date != null, 'updated_date');
  //         } else {
  //             System.assert(false); // 上記以外の電話番号が存在した場合、エラー
  //         }
  //     }
  // }

  // /**
  //  * 観点11, 16, 17
  //  */
  // @isTest
  // private static void test5() {
  //     Test.startTest();
  //     Account a1 = new Account(Name = '株式会社テスト１');
  //     Account a2 = new Account(Name = '株式会社テスト２');
  //     Account a3 = new Account(Name = '株式会社テスト３');
  //     insert new Account[]{a1, a2, a3};
  //     Contact c1 = new Contact( // アメリカの国番号始まりで表示される
  //         MobilePhone = '080-1111-1111',
  //         LastName = '佐藤',
  //         FirstName = '一郎',
  //         MailingCountry = 'アメリカ',
  //         OtherCountry = '日本',
  //         AccountId = a1.Id
  //     );
  //     Contact c2 = new Contact(
  //         Phone = '1-2222-2222',
  //         LastName = '鈴木',
  //         FirstName = '二郎',
  //         OtherCountry = 'アメリカ',
  //         AccountId = a2.Id
  //     );
  //     Contact c3 = new Contact(
  //         Phone = '1-3333-3333',
  //         LastName = '高橋',
  //         FirstName = '三郎',
  //         OtherCountry = '日本',
  //         AccountId = a3.Id
  //     );
  //     insert new Contact[]{c1, c2, c3};
  //     Test.stopTest();

  //     RestRequest req = new RestRequest();
  //     RestContext.request = req;
  //     Map<String, List<SB_Connect_Client>> clientMap =  SB_Connect_ClientController.getClients();
  //     System.debug(JSON.serialize(clientMap));
  //     List<SB_Connect_Client> clients = clientMap.get(KEY);
  //     System.assertEquals(3, clients.size());
  //     for (SB_Connect_Client client : clients) {
  //         if (client.phone_number == '18011111111') {
  //             System.assertEquals('08011111111', client.original_phone_number, 'original_phone_number');
  //             System.assertEquals('佐藤 一郎', client.full_name, 'full_name');
  //             System.assertEquals('株式会社テスト１', client.enterprise_name, 'enterprise_name');
  //             System.assert(!client.is_duplicate, 'is_duplicate');
  //             System.assert(client.registered_date != null, 'registered_date');
  //             System.assert(client.updated_date != null, 'updated_date');
  //         } else if (client.phone_number == '122222222') {
  //             System.assertEquals('122222222', client.original_phone_number, 'original_phone_number');
  //             System.assertEquals('鈴木 二郎', client.full_name, 'full_name');
  //             System.assertEquals('株式会社テスト２', client.enterprise_name, 'enterprise_name');
  //             System.assert(!client.is_duplicate, 'is_duplicate');
  //             System.assert(client.registered_date != null, 'registered_date');
  //             System.assert(client.updated_date != null, 'updated_date');
  //         } else if (client.phone_number == '81133333333') {
  //             System.assertEquals('133333333', client.original_phone_number, 'original_phone_number');
  //             System.assertEquals('高橋 三郎', client.full_name, 'full_name');
  //             System.assertEquals('株式会社テスト３', client.enterprise_name, 'enterprise_name');
  //             System.assert(!client.is_duplicate, 'is_duplicate');
  //             System.assert(client.registered_date != null, 'registered_date');
  //             System.assert(client.updated_date != null, 'updated_date');
  //         } else {
  //             System.assert(false); // 上記以外の電話番号が存在した場合、エラー
  //         }
  //     }
  // }

  // /**
  //  * コードカバレッジを埋める為のテスト
  //  *
  //  * 99行目を通るテストを作成する
  //  */
  // @IsTest
  // private static void test6() {
  //     Test.startTest();
  //     Account a = new Account(Name = '株式会社テスト');
  //     insert a;
  //     Contact c = new Contact(
  //         Phone = '0611111111',
  //         LastName = '佐藤',
  //         FirstName = '一郎',
  //         AccountId = a.Id
  //     );
  //     insert c;
  //     sleep(1000);
  //     NameCard__c n = new NameCard__c(
  //         tel1__c = '+81 6 1111-1111',
  //         person_name_last__c = '鈴木',
  //         person_name_first__c = '二郎'
  //     );
  //     insert n;
  //     Test.stopTest();

  //     RestRequest req = new RestRequest();
  //     RestContext.request = req;
  //     Map<String, List<SB_Connect_Client>> clientMap =  SB_Connect_ClientController.getClients();
  //     System.debug(JSON.serialize(clientMap));
  //     List<SB_Connect_Client> clients = clientMap.get(KEY);
  //     System.assertEquals(1, clients.size());
  //     SB_Connect_Client client = clients[0];
  //     System.assertEquals('81611111111', client.phone_number, 'phone_number');
  //     System.assertEquals('81611111111', client.original_phone_number, 'original_phone_number');
  //     System.assertEquals('鈴木 二郎', client.full_name, 'full_name');
  //     System.assert(client.enterprise_name == null, 'enterprise_name');
  //     System.assert(client.is_duplicate, 'is_duplicate');
  //     System.assert(client.registered_date != null, 'registered_date');
  //     System.assert(client.updated_date != null, 'updated_date');
  // }

  private static void sleep(Integer millsecondes) {
    Long startTime = Datetime.now().getTime();
    Long endTime = Datetime.now().getTime();
    while(endTime - startTime < millsecondes) {
        endTime = Datetime.now().getTime();
    }
  }

}