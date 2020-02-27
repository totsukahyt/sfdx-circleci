/**
 *
 *  SB_NameCardL_RenkeiTriggerContactCUTest
 *    リード拡張の自動連携で、取引先があって、取引先責任者を作成、更新するテスト
 *      ↓ の検証がメイン
 *    SV_DEV-2527 リード拡張の自動連携で取引先責任者について、不適切なレコードを更新する。または、作成されるべき新規取引先責任者レコードが作成されない。
 *
 * Copyright (C) 2020 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  lx 2.0.3    2020.02.xx
 *
 **/
@isTest
private class SB_NameCardL_RenkeiTriggerContactCUTest {

  private class Person {
    public String name;
    public String firstName;
    public String lastName;
    public String email;
    public String company;
    public String dept;
    public Person(String firstName, String lastName, String email, String company, String dept) {
      this.name = lastName + ' ' + firstName;
      this.firstName = firstName;
      this.lastName = lastName;
      this.email = email;
      this.company = company;
      this.dept = dept;
    }
  }

  private class TestDb extends SB_NCL_TestDB {

    private List<Person> persons;

    public void setPersons(List<Person> persons) {
      this.persons = new List<Person>(persons);
    }
    public override void initializeSmartViscaConfig() {
      svConfig = SmartViscaf__SmartViscaConfig__c.getOrgDefaults();
      // 自動連携のトリガハンドラを呼ぶ
      svConfig.SmartViscaf__TriggerRenkeiTriggerHandler__c = false;
      // Lead連携拡張パッケージの中にある 自動連携のトリガハンドラを呼ぶ
      svConfig.SmartViscaf__TriggerLeadExRenkeiTriggerHandler__c = true;
      // Lead 拡張パッケージ v2.0 からの項目
      // 統合版自動連携:リードなく、取引先既存で取引先責任者を作成する
      svConfig.RenkeiCreateContactOnAcountWithoutLead__c = true; // デフォルト false   リードを作らないようにする指定
      // 統合版自動連携:リード、取引先既存で取引先責任者を作成する
      svConfig.RenkeiCreateContactOnAcountWithLead__c = false;  // デフォルト false
      // 統合版自動連携: 既存取引先が複数あり特定できないとき、リードを作る。
      svConfig.RenkeiCreateLeadOnTooManyAccounts__c = false;  // デフォルト false
      // 統合版自動連携: 取引先責任者もキャンペーンメンバーにする。
      svConfig.RenkeiContactToCampaignMember__c = false;  // デフォルト false
      // 統合版自動連携: 更新でもキャンペーンメンバーにする。
      svConfig.RenkeiUpdateToCampaignMember__c = false; // デフォルト false
      // 統合版自動連携:条件に合致する既存リードは全て更新する。
      svConfig.RenkeiUpdateAllLeadsOnCondition__c = true; // デフォルト true
    }

    public override void initializeBasicSetting() {
      SmartViscaf__NameCardBasicSetting__c bs = SmartViscaf.SB_NC_PostInstallScript.createDefaultBasicSetting();
      bs.SmartViscaf__RenkeiActive__c = true;      // 自動連携機能有効
      bs.SmartViscaf__RenkeiLeadActive__c = true; // 自動連携:リード登録機能を有効化
      bs.SmartViscaf__RenkeiAccountNOExistCreateNew__c = true; // 自動連携:既存の取引先がなければ新規作成する
      bs.SmartViscaf__RenkeiContactNOExistCreateNew__c = true; // 自動連携:既存の取引先責任者がなければ新規作成する
      bs.SmartViscaf__RenkeiAccountOverwrite__c = true;  // 自動連携:既存の取引先を上書きする
      bs.SmartViscaf__RenkeiContactOverwrite__c = true;  // 自動連携:既存の取引先責任者を上書きする
      bs.SmartViscaf__RenkeiExcludeHojinkakuPartial__c = false;     // 自動連携:会社名は法人格を除いて部分一致
      bs.SmartViscaf__RenkeiExcludeHojinkaku__c = false;      // 自動連携:会社名は法人格を除いて完全一致
      bs.SmartViscaf__RenkeiContactMail__c = true;      // コンタクト メールアドレス
      bs.SmartViscaf__RenkeiContactLastName__c = true;  // コンタクト ラストネーム
      bs.SmartViscaf__RenkeiContactFirstName__c = true; // コンタクト ファーストネーム
      listBasicSetting.add(bs);
    }
      //
    public override void initializeAccount() {
      Set<String> company_dept = new Set<String>();
      for (Person p : this.persons) {
        if (company_dept.contains(p.company+p.dept)) {
          continue;
        }
        listAccount.add(new Account(Name=p.company, Site=p.dept));
        company_dept.add(p.company+p.dept);
      }
    }

    public override void initializeContact() {
      List<Account> acnts = [SELECT Id, Name, Site, AccountNumber FROM Account];
      Map<String, Account> acntMap = new Map<String, Account>();
      for (Account a : acnts) {
        acntMap.put(a.Name, a);
      }
      for (Person p : this.persons) {
        listContact.add(new Contact(LastName=p.lastName, FirstName=p.firstName, EMail=p.email, Department=p.dept, AccountId=acntMap.get(p.company).Id));       // 姓名が名刺と一緒
      }
    }

    public override void initializeNameCard() {
      for (Person p : this.persons) {
        listCard.add(
          new SmartViscaf__NameCard__c(Name=p.name,
              SmartViscaf__person_name_last__c= p.lastName,
              SmartViscaf__person_name_first__c= p.firstName,
              SmartViscaf__email__c= p.email,
              SmartViscaf__company_name__c=p.company,
              SmartViscaf__division__c=p.dept,
              SmartViscaf__delivery_type__c='1' ));
      }
    }

    // // コードスキャンで FLS Update、FLS Create がでるので、
    // protected Boolean canUpsert(SObjectType otype) {
    //   return otype.getDescribe().isCreateable() && otype.getDescribe().isUpdateable();
    // }

    // // コードスキャンで FLS Update、FLS Create がでるので、
    // protected Boolean canInsert(SObjectType otype) {
    //   return otype.getDescribe().isCreateable();
    // }

    public override void initialize() {

      // SmartVisca設定
      initializeSmartViscaConfig();
      if (svConfig !=null) {
        List<SmartViscaf__SmartViscaConfig__c> l = new List<SmartViscaf__SmartViscaConfig__c>();
        l.add(svConfig);
        if(svConfig.Id == null) {
          SmartViscaf.SB_NameCard_CrudFls.screate(l, true);
        }
        else {
          SmartViscaf.SB_NameCard_CrudFls.supdate(l, true);
        }
      }

      // 名刺基本設定
      initializeBasicSetting();
      if (!listBasicSetting.isEmpty()) {
        SmartViscaf.SB_NameCard_CrudFls.screate(listBasicSetting, true);
      }

      // 名刺連携項目マッピング
      initializeMapping();
      if (!listMapping.isEmpty()) {
        SmartViscaf.SB_NameCard_CrudFls.screate(listMapping, true);
      }

      // アカウント
      initializeAccount();
      if (!listAccount.isEmpty()) {
        SmartViscaf.SB_NameCard_CrudFls.screate(listAccount, true);
      }
      // コンタクト
      initializeContact();
      if (!listContact.isEmpty()) {
        SmartViscaf.SB_NameCard_CrudFls.screate(listContact, true);
      }
      // 名刺レコード作成
      initializeNameCard();
      if (!listCard.isEmpty()) {
        SmartViscaf.SB_NameCard_CrudFls.screate(listCard, true);
      }
    }
  }

  private static final List<Person> PERSONS = new List<Person> {
    new Person('００１', 'テスト０１', '001@test.com', 'てすと株式会社', '営業部'),
    new Person('００２', 'テスト０２', '002@test.com', 'てすと株式会社', '営業部'),
    new Person('００３', 'テスト０３', '003@test.com', 'てすと株式会社', '営業部'),
    new Person('００４', 'テスト０４', '004@test.com', 'てすと株式会社', '営業部'),
    new Person('００５', 'テスト０５', '005@test.com', 'てすと株式会社', '営業部'),
    new Person('００６', 'テスト０６', '006@test.com', 'てすと株式会社', '営業部'),
    new Person('００７', 'テスト０７', '007@test.com', 'てすと株式会社', '営業部'),
    new Person('００８', 'テスト０８', '008@test.com', 'てすと株式会社', '営業部'),
    new Person('００９', 'テスト０９', '009@test.com', 'てすと株式会社', '営業部'),
    new Person('０１０', 'テスト１０', '010@test.com', 'てすと株式会社', '営業部')
  };


  // https://sunbridge.my.salesforce.com/5001000000vDMqK で 問題が発覚した事象
  @isTest
  static void test_createContact_E() {
    TestDb db = new TestDb();
    db.setPersons(new List<Person> {
      new Person('００１', 'テスト０１', '001@test.com', 'てすと株式会社', '営業部')
    });
    db.initialize();

    SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RenkeiContactMail__c = true;      // コンタクト メールアドレス
    SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RenkeiContactLastName__c = false;  // コンタクト ラストネーム
    SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RenkeiContactFirstName__c = false; // コンタクト ファーストネーム

    System.assertEquals(1, [SELECT Id FROM Account].size());
    System.assertEquals(1, [SELECT Id FROM Contact WHERE SmartViscaf__NameCard__c=null].size());
    System.assertEquals(1, [SELECT Id FROM SmartViscaf__NameCard__c WHERE SmartViscaf__contact__c=null AND SmartViscaf__account__c=null].size());

    Test.startTest();
    List<SmartViscaf__NameCard__c> cards = [SELECT Id, Name, SmartViscaf__person_name_last__c, SmartViscaf__person_name_first__c, SmartViscaf__email__c, SmartViscaf__delivery_type__c FROM SmartViscaf__NameCard__c];
    for (SmartViscaf__NameCard__c c : cards) {
      c.SmartViscaf__email__c = c.SmartViscaf__email__c.replace('.com', '.co.jp');
      // c.SmartViscaf__person_name_last__c = c.SmartViscaf__person_name_last__c + '別人';
      // c.SmartViscaf__person_name_first__c = c.SmartViscaf__person_name_first__c + '別人';
      // c.Name = c.SmartViscaf__person_name_last__c + ' ' + c.SmartViscaf__person_name_first__c;
      c.SmartViscaf__delivery_type__c='2';
    }
    update cards;
    Test.stopTest();
    System.assertEquals(0, [SELECT Id FROM Lead].size());
    System.assertEquals(1, [SELECT Id FROM SmartViscaf__NameCard__c WHERE SmartViscaf__contact__c!=null AND SmartViscaf__account__c!=null AND SmartViscaf__RenkeiMessage__c!=null].size());
    System.assertEquals(1, [SELECT Id FROM Contact WHERE SmartViscaf__NameCard__c!=null].size());
    System.assertEquals(2, [SELECT Id FROM Contact].size());
  }

  @isTest
  static void test_createContacts_E() {
    TestDb db = new TestDb();
    db.setPersons(new List<Person> {
      new Person('００１', 'テスト０１', '001@test.com', 'てすと株式会社', '営業部'),
      new Person('００２', 'テスト０２', '002@test.com', 'てすと株式会社', '営業部')
    });
    db.initialize();

    SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RenkeiContactMail__c = true;      // コンタクト メールアドレス
    SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RenkeiContactLastName__c = false;  // コンタクト ラストネーム
    SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RenkeiContactFirstName__c = false; // コンタクト ファーストネーム

    System.assertEquals(1, [SELECT Id FROM Account].size());
    System.assertEquals(2, [SELECT Id FROM Contact WHERE SmartViscaf__NameCard__c=null].size());
    System.assertEquals(2, [SELECT Id FROM SmartViscaf__NameCard__c WHERE SmartViscaf__contact__c=null AND SmartViscaf__account__c=null].size());

    Test.startTest();
    List<SmartViscaf__NameCard__c> cards = [SELECT Id, Name, SmartViscaf__person_name_last__c, SmartViscaf__person_name_first__c, SmartViscaf__email__c, SmartViscaf__delivery_type__c FROM SmartViscaf__NameCard__c];
    for (SmartViscaf__NameCard__c c : cards) {
      c.SmartViscaf__email__c = c.SmartViscaf__email__c.replace('.com', '.co.jp');
      // c.SmartViscaf__person_name_last__c = c.SmartViscaf__person_name_last__c + '別人';
      // c.SmartViscaf__person_name_first__c = c.SmartViscaf__person_name_first__c + '別人';
      // c.Name = c.SmartViscaf__person_name_last__c + ' ' + c.SmartViscaf__person_name_first__c;
      c.SmartViscaf__delivery_type__c='2';
    }
    update cards;
    Test.stopTest();
    System.assertEquals(0, [SELECT Id FROM Lead].size());
    System.assertEquals(2, [SELECT Id FROM SmartViscaf__NameCard__c WHERE SmartViscaf__contact__c!=null AND SmartViscaf__account__c!=null AND SmartViscaf__RenkeiMessage__c!=null].size());
    System.assertEquals(2, [SELECT Id FROM Contact WHERE SmartViscaf__NameCard__c!=null].size());
    System.assertEquals(4, [SELECT Id FROM Contact].size());
  }

  @isTest
  static void test_createContacts_L() {
    TestDb db = new TestDb();
    db.setPersons(new List<Person> {
      new Person('００１', 'テスト０１', '001@test.com', 'てすと株式会社', '営業部'),
      new Person('００２', 'テスト０２', '002@test.com', 'てすと株式会社', '営業部')
    });
    db.initialize();

    SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RenkeiContactMail__c = false;      // コンタクト メールアドレス
    SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RenkeiContactLastName__c = true;  // コンタクト ラストネーム
    SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RenkeiContactFirstName__c = false; // コンタクト ファーストネーム

    System.assertEquals(1, [SELECT Id FROM Account].size());
    System.assertEquals(2, [SELECT Id FROM Contact WHERE SmartViscaf__NameCard__c=null].size());
    System.assertEquals(2, [SELECT Id FROM SmartViscaf__NameCard__c WHERE SmartViscaf__contact__c=null AND SmartViscaf__account__c=null].size());

    Test.startTest();
    List<SmartViscaf__NameCard__c> cards = [SELECT Id, Name, SmartViscaf__person_name_last__c, SmartViscaf__person_name_first__c, SmartViscaf__email__c, SmartViscaf__delivery_type__c FROM SmartViscaf__NameCard__c];
    for (SmartViscaf__NameCard__c c : cards) {
      // c.SmartViscaf__email__c = c.SmartViscaf__email__c.replace('.com', '.co.jp');
      c.SmartViscaf__person_name_last__c = c.SmartViscaf__person_name_last__c + '別人';
      // c.SmartViscaf__person_name_first__c = c.SmartViscaf__person_name_first__c + '別人';
      c.Name = c.SmartViscaf__person_name_last__c + ' ' + c.SmartViscaf__person_name_first__c;
      c.SmartViscaf__delivery_type__c='2';
    }
    update cards;
    Test.stopTest();
    System.assertEquals(0, [SELECT Id FROM Lead].size());
    System.assertEquals(2, [SELECT Id FROM SmartViscaf__NameCard__c WHERE SmartViscaf__contact__c!=null AND SmartViscaf__account__c!=null AND SmartViscaf__RenkeiMessage__c!=null].size());
    System.assertEquals(2, [SELECT Id FROM Contact WHERE SmartViscaf__NameCard__c!=null].size());
    System.assertEquals(4, [SELECT Id FROM Contact].size());
  }

  @isTest
  static void test_createContacts_F() {
    TestDb db = new TestDb();
    db.setPersons(new List<Person> {
      new Person('００１', 'テスト０１', '001@test.com', 'てすと株式会社', '営業部'),
      new Person('００２', 'テスト０２', '002@test.com', 'てすと株式会社', '営業部')
    });
    db.initialize();

    SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RenkeiContactMail__c = false;      // コンタクト メールアドレス
    SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RenkeiContactLastName__c = false;  // コンタクト ラストネーム
    SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RenkeiContactFirstName__c = true; // コンタクト ファーストネーム

    System.assertEquals(1, [SELECT Id FROM Account].size());
    System.assertEquals(2, [SELECT Id FROM Contact WHERE SmartViscaf__NameCard__c=null].size());
    System.assertEquals(2, [SELECT Id FROM SmartViscaf__NameCard__c WHERE SmartViscaf__contact__c=null AND SmartViscaf__account__c=null].size());

    Test.startTest();
    List<SmartViscaf__NameCard__c> cards = [SELECT Id, Name, SmartViscaf__person_name_last__c, SmartViscaf__person_name_first__c, SmartViscaf__email__c, SmartViscaf__delivery_type__c FROM SmartViscaf__NameCard__c];
    for (SmartViscaf__NameCard__c c : cards) {
      // c.SmartViscaf__email__c = c.SmartViscaf__email__c.replace('.com', '.co.jp');
      // c.SmartViscaf__person_name_last__c = c.SmartViscaf__person_name_last__c + '別人';
      c.SmartViscaf__person_name_first__c = c.SmartViscaf__person_name_first__c + '別人';
      c.Name = c.SmartViscaf__person_name_last__c + ' ' + c.SmartViscaf__person_name_first__c;
      c.SmartViscaf__delivery_type__c='2';
    }
    update cards;
    Test.stopTest();
    System.assertEquals(0, [SELECT Id FROM Lead].size());
    System.assertEquals(2, [SELECT Id FROM SmartViscaf__NameCard__c WHERE SmartViscaf__contact__c!=null AND SmartViscaf__account__c!=null AND SmartViscaf__RenkeiMessage__c!=null].size());
    System.assertEquals(2, [SELECT Id FROM Contact WHERE SmartViscaf__NameCard__c!=null].size());
    System.assertEquals(4, [SELECT Id FROM Contact].size());
  }

  @isTest
  static void test_createContacts_ELF_E() {
    TestDb db = new TestDb();
    db.setPersons(new List<Person> {
      new Person('００１', 'テスト０１', '001@test.com', 'てすと株式会社', '営業部'),
      new Person('００２', 'テスト０２', '002@test.com', 'てすと株式会社', '営業部')
    });
    db.initialize();

    SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RenkeiContactMail__c = true;      // コンタクト メールアドレス
    SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RenkeiContactLastName__c = true;  // コンタクト ラストネーム
    SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RenkeiContactFirstName__c = true; // コンタクト ファーストネーム

    System.assertEquals(1, [SELECT Id FROM Account].size());
    System.assertEquals(2, [SELECT Id FROM Contact WHERE SmartViscaf__NameCard__c=null].size());
    System.assertEquals(2, [SELECT Id FROM SmartViscaf__NameCard__c WHERE SmartViscaf__contact__c=null AND SmartViscaf__account__c=null].size());

    Test.startTest();
    List<SmartViscaf__NameCard__c> cards = [SELECT Id, Name, SmartViscaf__person_name_last__c, SmartViscaf__person_name_first__c, SmartViscaf__email__c, SmartViscaf__delivery_type__c FROM SmartViscaf__NameCard__c];
    for (SmartViscaf__NameCard__c c : cards) {
      c.SmartViscaf__email__c = c.SmartViscaf__email__c.replace('.com', '.co.jp');
      // c.SmartViscaf__person_name_last__c = c.SmartViscaf__person_name_last__c + '別人';
      // c.SmartViscaf__person_name_first__c = c.SmartViscaf__person_name_first__c + '別人';
      // c.Name = c.SmartViscaf__person_name_last__c + ' ' + c.SmartViscaf__person_name_first__c;
      c.SmartViscaf__delivery_type__c='2';
    }
    update cards;
    Test.stopTest();
    System.assertEquals(0, [SELECT Id FROM Lead].size());
    System.assertEquals(2, [SELECT Id FROM SmartViscaf__NameCard__c WHERE SmartViscaf__contact__c!=null AND SmartViscaf__account__c!=null AND SmartViscaf__RenkeiMessage__c!=null].size());
    System.assertEquals(2, [SELECT Id FROM Contact WHERE SmartViscaf__NameCard__c!=null].size());
    System.assertEquals(4, [SELECT Id FROM Contact].size());
  }

  @isTest
  static void test_createContacts_ELF_L() {
    TestDb db = new TestDb();
    db.setPersons(new List<Person> {
      new Person('００１', 'テスト０１', '001@test.com', 'てすと株式会社', '営業部'),
      new Person('００２', 'テスト０２', '002@test.com', 'てすと株式会社', '営業部')
    });
    db.initialize();

    SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RenkeiContactMail__c = true;      // コンタクト メールアドレス
    SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RenkeiContactLastName__c = true;  // コンタクト ラストネーム
    SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RenkeiContactFirstName__c = true; // コンタクト ファーストネーム

    System.assertEquals(1, [SELECT Id FROM Account].size());
    System.assertEquals(2, [SELECT Id FROM Contact WHERE SmartViscaf__NameCard__c=null].size());
    System.assertEquals(2, [SELECT Id FROM SmartViscaf__NameCard__c WHERE SmartViscaf__contact__c=null AND SmartViscaf__account__c=null].size());

    Test.startTest();
    List<SmartViscaf__NameCard__c> cards = [SELECT Id, Name, SmartViscaf__person_name_last__c, SmartViscaf__person_name_first__c, SmartViscaf__email__c, SmartViscaf__delivery_type__c FROM SmartViscaf__NameCard__c];
    for (SmartViscaf__NameCard__c c : cards) {
      // c.SmartViscaf__email__c = c.SmartViscaf__email__c.replace('.com', '.co.jp');
      c.SmartViscaf__person_name_last__c = c.SmartViscaf__person_name_last__c + '別人';
      // c.SmartViscaf__person_name_first__c = c.SmartViscaf__person_name_first__c + '別人';
      c.Name = c.SmartViscaf__person_name_last__c + ' ' + c.SmartViscaf__person_name_first__c;
      c.SmartViscaf__delivery_type__c='2';
    }
    update cards;
    Test.stopTest();
    System.assertEquals(0, [SELECT Id FROM Lead].size());
    System.assertEquals(2, [SELECT Id FROM SmartViscaf__NameCard__c WHERE SmartViscaf__contact__c!=null AND SmartViscaf__account__c!=null AND SmartViscaf__RenkeiMessage__c!=null].size());
    System.assertEquals(2, [SELECT Id FROM Contact WHERE SmartViscaf__NameCard__c!=null].size());
    System.assertEquals(4, [SELECT Id FROM Contact].size());
  }

  @isTest
  static void test_createContacts_ELF_F() {
    TestDb db = new TestDb();
    db.setPersons(new List<Person> {
      new Person('００１', 'テスト０１', '001@test.com', 'てすと株式会社', '営業部'),
      new Person('００２', 'テスト０２', '002@test.com', 'てすと株式会社', '営業部')
    });
    db.initialize();

    SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RenkeiContactMail__c = true;      // コンタクト メールアドレス
    SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RenkeiContactLastName__c = true;  // コンタクト ラストネーム
    SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RenkeiContactFirstName__c = true; // コンタクト ファーストネーム

    System.assertEquals(1, [SELECT Id FROM Account].size());
    System.assertEquals(2, [SELECT Id FROM Contact WHERE SmartViscaf__NameCard__c=null].size());
    System.assertEquals(2, [SELECT Id FROM SmartViscaf__NameCard__c WHERE SmartViscaf__contact__c=null AND SmartViscaf__account__c=null].size());

    Test.startTest();
    List<SmartViscaf__NameCard__c> cards = [SELECT Id, Name, SmartViscaf__person_name_last__c, SmartViscaf__person_name_first__c, SmartViscaf__email__c, SmartViscaf__delivery_type__c FROM SmartViscaf__NameCard__c];
    for (SmartViscaf__NameCard__c c : cards) {
      // c.SmartViscaf__email__c = c.SmartViscaf__email__c.replace('.com', '.co.jp');
      // c.SmartViscaf__person_name_last__c = c.SmartViscaf__person_name_last__c + '別人';
      c.SmartViscaf__person_name_first__c = c.SmartViscaf__person_name_first__c + '別人';
      c.Name = c.SmartViscaf__person_name_last__c + ' ' + c.SmartViscaf__person_name_first__c;
      c.SmartViscaf__delivery_type__c='2';
    }
    update cards;
    Test.stopTest();
    System.assertEquals(0, [SELECT Id FROM Lead].size());
    System.assertEquals(2, [SELECT Id FROM SmartViscaf__NameCard__c WHERE SmartViscaf__contact__c!=null AND SmartViscaf__account__c!=null AND SmartViscaf__RenkeiMessage__c!=null].size());
    System.assertEquals(2, [SELECT Id FROM Contact WHERE SmartViscaf__NameCard__c!=null].size());
    System.assertEquals(4, [SELECT Id FROM Contact].size());
  }

  @isTest
  static void test_updateContacts_E() {
    TestDb db = new TestDb();
    db.setPersons(new List<Person> {
      new Person('００１', 'テスト０１', '001@test.com', 'てすと株式会社', '営業部'),
      new Person('００２', 'テスト０２', '002@test.com', 'てすと株式会社', '営業部')
    });
    db.initialize();

    SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RenkeiContactMail__c = true;      // コンタクト メールアドレス
    SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RenkeiContactLastName__c = false;  // コンタクト ラストネーム
    SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RenkeiContactFirstName__c = false; // コンタクト ファーストネーム

    System.assertEquals(1, [SELECT Id FROM Account].size());
    System.assertEquals(2, [SELECT Id FROM Contact WHERE SmartViscaf__NameCard__c=null].size());
    System.assertEquals(2, [SELECT Id FROM SmartViscaf__NameCard__c WHERE SmartViscaf__contact__c=null AND SmartViscaf__account__c=null].size());

    Test.startTest();
    List<SmartViscaf__NameCard__c> cards = [SELECT Id, Name, SmartViscaf__person_name_last__c, SmartViscaf__person_name_first__c, SmartViscaf__email__c, SmartViscaf__delivery_type__c FROM SmartViscaf__NameCard__c];
    for (SmartViscaf__NameCard__c c : cards) {
      // c.SmartViscaf__email__c = c.SmartViscaf__email__c.replace('.com', '.co.jp');
      c.SmartViscaf__person_name_last__c = c.SmartViscaf__person_name_last__c + '別人';
      c.SmartViscaf__person_name_first__c = c.SmartViscaf__person_name_first__c + '別人';
      c.Name = c.SmartViscaf__person_name_last__c + ' ' + c.SmartViscaf__person_name_first__c;
      c.SmartViscaf__delivery_type__c='2';
    }
    update cards;
    Test.stopTest();
    System.assertEquals(0, [SELECT Id FROM Lead].size());
    System.assertEquals(2, [SELECT Id FROM SmartViscaf__NameCard__c WHERE SmartViscaf__contact__c!=null AND SmartViscaf__account__c!=null AND SmartViscaf__RenkeiMessage__c!=null].size());
    System.assertEquals(2, [SELECT Id FROM Contact WHERE SmartViscaf__NameCard__c!=null].size());
    System.assertEquals(2, [SELECT Id FROM Contact].size());
  }

  @isTest
  static void test_updateContacts_L() {
    TestDb db = new TestDb();
    db.setPersons(new List<Person> {
      new Person('００１', 'テスト０１', '001@test.com', 'てすと株式会社', '営業部'),
      new Person('００２', 'テスト０２', '002@test.com', 'てすと株式会社', '営業部')
    });
    db.initialize();

    SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RenkeiContactMail__c = false;      // コンタクト メールアドレス
    SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RenkeiContactLastName__c = true;  // コンタクト ラストネーム
    SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RenkeiContactFirstName__c = false; // コンタクト ファーストネーム

    System.assertEquals(1, [SELECT Id FROM Account].size());
    System.assertEquals(2, [SELECT Id FROM Contact WHERE SmartViscaf__NameCard__c=null].size());
    System.assertEquals(2, [SELECT Id FROM SmartViscaf__NameCard__c WHERE SmartViscaf__contact__c=null AND SmartViscaf__account__c=null].size());

    Test.startTest();
    List<SmartViscaf__NameCard__c> cards = [SELECT Id, Name, SmartViscaf__person_name_last__c, SmartViscaf__person_name_first__c, SmartViscaf__email__c, SmartViscaf__delivery_type__c FROM SmartViscaf__NameCard__c];
    for (SmartViscaf__NameCard__c c : cards) {
      c.SmartViscaf__email__c = c.SmartViscaf__email__c.replace('.com', '.co.jp');
      // c.SmartViscaf__person_name_last__c = c.SmartViscaf__person_name_last__c + '別人';
      c.SmartViscaf__person_name_first__c = c.SmartViscaf__person_name_first__c + '別人';
      c.Name = c.SmartViscaf__person_name_last__c + ' ' + c.SmartViscaf__person_name_first__c;
      c.SmartViscaf__delivery_type__c='2';
    }
    update cards;
    Test.stopTest();
    System.assertEquals(0, [SELECT Id FROM Lead].size());
    System.assertEquals(2, [SELECT Id FROM SmartViscaf__NameCard__c WHERE SmartViscaf__contact__c!=null AND SmartViscaf__account__c!=null AND SmartViscaf__RenkeiMessage__c!=null].size());
    System.assertEquals(2, [SELECT Id FROM Contact WHERE SmartViscaf__NameCard__c!=null].size());
    System.assertEquals(2, [SELECT Id FROM Contact].size());
  }

  @isTest
  static void test_updateContacts_F() {
    TestDb db = new TestDb();
    db.setPersons(new List<Person> {
      new Person('００１', 'テスト０１', '001@test.com', 'てすと株式会社', '営業部'),
      new Person('００２', 'テスト０２', '002@test.com', 'てすと株式会社', '営業部')
    });
    db.initialize();

    SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RenkeiContactMail__c = false;      // コンタクト メールアドレス
    SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RenkeiContactLastName__c = false;  // コンタクト ラストネーム
    SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RenkeiContactFirstName__c = true; // コンタクト ファーストネーム

    System.assertEquals(1, [SELECT Id FROM Account].size());
    System.assertEquals(2, [SELECT Id FROM Contact WHERE SmartViscaf__NameCard__c=null].size());
    System.assertEquals(2, [SELECT Id FROM SmartViscaf__NameCard__c WHERE SmartViscaf__contact__c=null AND SmartViscaf__account__c=null].size());

    Test.startTest();
    List<SmartViscaf__NameCard__c> cards = [SELECT Id, Name, SmartViscaf__person_name_last__c, SmartViscaf__person_name_first__c, SmartViscaf__email__c, SmartViscaf__delivery_type__c FROM SmartViscaf__NameCard__c];
    for (SmartViscaf__NameCard__c c : cards) {
      c.SmartViscaf__email__c = c.SmartViscaf__email__c.replace('.com', '.co.jp');
      c.SmartViscaf__person_name_last__c = c.SmartViscaf__person_name_last__c + '別人';
      // c.SmartViscaf__person_name_first__c = c.SmartViscaf__person_name_first__c + '別人';
      c.Name = c.SmartViscaf__person_name_last__c + ' ' + c.SmartViscaf__person_name_first__c;
      c.SmartViscaf__delivery_type__c='2';
    }
    update cards;
    Test.stopTest();
    System.assertEquals(0, [SELECT Id FROM Lead].size());
    System.assertEquals(2, [SELECT Id FROM SmartViscaf__NameCard__c WHERE SmartViscaf__contact__c!=null AND SmartViscaf__account__c!=null AND SmartViscaf__RenkeiMessage__c!=null].size());
    System.assertEquals(2, [SELECT Id FROM Contact WHERE SmartViscaf__NameCard__c!=null].size());
    System.assertEquals(2, [SELECT Id FROM Contact].size());
  }

  @isTest
  static void test_updateContacts_ELF() {
    TestDb db = new TestDb();
    db.setPersons(new List<Person> {
      new Person('００１', 'テスト０１', '001@test.com', 'てすと株式会社', '営業部'),
      new Person('００２', 'テスト０２', '002@test.com', 'てすと株式会社', '営業部')
    });
    db.initialize();

    SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RenkeiContactMail__c = true;      // コンタクト メールアドレス
    SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RenkeiContactLastName__c = true;  // コンタクト ラストネーム
    SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RenkeiContactFirstName__c = true; // コンタクト ファーストネーム

    System.assertEquals(1, [SELECT Id FROM Account].size());
    System.assertEquals(2, [SELECT Id FROM Contact WHERE SmartViscaf__NameCard__c=null].size());
    System.assertEquals(2, [SELECT Id FROM SmartViscaf__NameCard__c WHERE SmartViscaf__contact__c=null AND SmartViscaf__account__c=null].size());

    Test.startTest();
    List<SmartViscaf__NameCard__c> cards = [SELECT Id, Name, SmartViscaf__person_name_last__c, SmartViscaf__person_name_first__c, SmartViscaf__email__c, SmartViscaf__delivery_type__c FROM SmartViscaf__NameCard__c];
    for (SmartViscaf__NameCard__c c : cards) {
      // c.SmartViscaf__email__c = c.SmartViscaf__email__c.replace('.com', '.co.jp');
      // c.SmartViscaf__person_name_last__c = c.SmartViscaf__person_name_last__c + '別人';
      // c.SmartViscaf__person_name_first__c = c.SmartViscaf__person_name_first__c + '別人';
      // c.Name = c.SmartViscaf__person_name_last__c + ' ' + c.SmartViscaf__person_name_first__c;
      c.SmartViscaf__delivery_type__c='2';
    }
    update cards;
    Test.stopTest();
    System.assertEquals(0, [SELECT Id FROM Lead].size());
    System.assertEquals(2, [SELECT Id FROM SmartViscaf__NameCard__c WHERE SmartViscaf__contact__c!=null AND SmartViscaf__account__c!=null AND SmartViscaf__RenkeiMessage__c!=null].size());
    System.assertEquals(2, [SELECT Id FROM Contact WHERE SmartViscaf__NameCard__c!=null].size());
    System.assertEquals(2, [SELECT Id FROM Contact].size());
  }

}