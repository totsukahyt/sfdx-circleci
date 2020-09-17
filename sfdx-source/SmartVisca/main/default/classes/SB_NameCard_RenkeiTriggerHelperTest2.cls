/**
 *
 * SB_NameCard_RenkeiTriggerHelperTest2
 *  自動連携機能の、おもに 例外的なケースとか 会社名の照合のテストクラス
 *
 * Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2017.11.xx v1.22 から
 *
 **/
@isTest
private class SB_NameCard_RenkeiTriggerHelperTest2
{

  // +--------------------
  public virtual class TestDb extends SB_NC_TestDB {

    public virtual override void initialize() {
      initializeUser();
      if (listUser.isEmpty() == false)
        insert listUser;
      // 名刺基本設定
      initializeBasicSetting();
      if (!listBasicSetting.isEmpty()) {
        insert listBasicSetting;
      }
      // 名刺連携項目マッピング
      initializeMapping();
      if (!listMapping.isEmpty()) {
        insert listMapping;
      }
    }
  } // public virtual class TestDb extends SB_NC_TestDB

  // 自動連携して 会社名は法人格を除いて完全一致
  public virtual class TestDbRenkeiExcludeHojinkaku extends TestDb {

    public virtual override void initializeBasicSetting() {
      NameCardBasicSetting__c bs = SB_NC_PostInstallScript.createDefaultBasicSetting();
      bs.RenkeiActive__c = true;      // 自動連携機能有効
      bs.RenkeiAccountOverwrite__c = true;   // 既存の取引先を上書き
      bs.RenkeiContactOverwrite__c = true;   // 既存の取引先責任者を上書き
      //bs.RenkeiAccountNOExistCreateNew__c = true; // 既存の取引先がなければ新規作成
      //bs.RenkeiContactNOExistCreateNew__c = true; // 既存の取引先責任者がなければ新規作成する
      //bs.RenkeiAccountAddressPref__c = false;   // アカウント 都道府県
      //bs.RenkeiAccount_Street__c = false;   // アカウント 町名・番地
      //bs.RenkeiAccountZipCode__c = false;   // アカウント 郵便番号
      //bs.RenkeiAccountCity__c = false;      // アカウント 市区郡
      //bs.RenkeiAccountURL__c = false;       // アカウント URL
      //bs.RenkeiAccountCompany__c = true;   // アカウント 会社名
      //bs.RenkeiAccountPhone__c = false;     // アカウント 電話番号
      //bs.RenkeiSpecificItems__c = null;        // アカウント 特定項目
      //bs.RenkeiAccountSite__c = false;        // アカウント 部署名
      bs.RenkeiExcludeHojinkakuPartial__c = false;      // 自動連携:会社名は法人格を除いて部分一致
      bs.RenkeiExcludeHojinkaku__c = true;      // 自動連携:会社名は法人格を除いて完全一致
      //bs.RenkeiAccountSitePartialMatch__c = true;      // 自動連携:部署は中間一致検索
      //bs.RenkeiContactMail__c = true;      // コンタクト メールアドレス
      //bs.RenkeiContactLastName__c = true;  // コンタクト ラストネーム
      //bs.RenkeiContactFirstName__c = false; // コンタクト ファーストネーム
      listBasicSetting.add(bs);
    }
  } // public virtual class TestDbRenkeiExcludeHojinkaku extends TestDb

  // 自動連携して 会社名は法人格を除いて部分一致
  public virtual class TestDbRenkeiExcludeHojinkakuPartial extends TestDb {

    public virtual override void initializeBasicSetting() {
      NameCardBasicSetting__c bs = SB_NC_PostInstallScript.createDefaultBasicSetting();
      bs.RenkeiActive__c = true;      // 自動連携機能有効
      bs.RenkeiAccountOverwrite__c = true;   // 既存の取引先を上書き
      bs.RenkeiContactOverwrite__c = true;   // 既存の取引先責任者を上書き
      //bs.RenkeiAccountNOExistCreateNew__c = true; // 既存の取引先がなければ新規作成
      //bs.RenkeiContactNOExistCreateNew__c = true; // 既存の取引先責任者がなければ新規作成する
      //bs.RenkeiAccountAddressPref__c = false;   // アカウント 都道府県
      //bs.RenkeiAccount_Street__c = false;   // アカウント 町名・番地
      //bs.RenkeiAccountZipCode__c = false;   // アカウント 郵便番号
      //bs.RenkeiAccountCity__c = false;      // アカウント 市区郡
      //bs.RenkeiAccountURL__c = false;       // アカウント URL
      //bs.RenkeiAccountCompany__c = true;   // アカウント 会社名
      //bs.RenkeiAccountPhone__c = false;     // アカウント 電話番号
      //bs.RenkeiSpecificItems__c = null;        // アカウント 特定項目
      //bs.RenkeiAccountSite__c = false;        // アカウント 部署名
      bs.RenkeiExcludeHojinkakuPartial__c = true;      // 自動連携:会社名は法人格を除いて部分一致
      bs.RenkeiExcludeHojinkaku__c = false;      // 自動連携:会社名は法人格を除いて完全一致
      //bs.RenkeiAccountSitePartialMatch__c = true;      // 自動連携:部署は中間一致検索
      //bs.RenkeiContactMail__c = true;      // コンタクト メールアドレス
      //bs.RenkeiContactLastName__c = true;  // コンタクト ラストネーム
      //bs.RenkeiContactFirstName__c = false; // コンタクト ファーストネーム
      listBasicSetting.add(bs);
    }
  } // public virtual class TestDbRenkeiExcludeHojinkakuPartial extends TestDb

  // 自動連携して 会社名は完全一致
  public virtual class TestDbRenkeiAccountNameMatch extends TestDb {

    public virtual override void initializeBasicSetting() {
      NameCardBasicSetting__c bs = SB_NC_PostInstallScript.createDefaultBasicSetting();
      bs.RenkeiActive__c = true;      // 自動連携機能有効
      bs.RenkeiAccountOverwrite__c = true;   // 既存の取引先を上書き
      bs.RenkeiContactOverwrite__c = true;   // 既存の取引先責任者を上書き
      //bs.RenkeiAccountNOExistCreateNew__c = true; // 既存の取引先がなければ新規作成
      //bs.RenkeiContactNOExistCreateNew__c = true; // 既存の取引先責任者がなければ新規作成する
      //bs.RenkeiAccountAddressPref__c = false;   // アカウント 都道府県
      //bs.RenkeiAccount_Street__c = false;   // アカウント 町名・番地
      //bs.RenkeiAccountZipCode__c = false;   // アカウント 郵便番号
      //bs.RenkeiAccountCity__c = false;      // アカウント 市区郡
      //bs.RenkeiAccountURL__c = false;       // アカウント URL
      //bs.RenkeiAccountCompany__c = true;   // アカウント 会社名
      //bs.RenkeiAccountPhone__c = false;     // アカウント 電話番号
      //bs.RenkeiSpecificItems__c = null;        // アカウント 特定項目
      //bs.RenkeiAccountSite__c = false;        // アカウント 部署名
      bs.RenkeiExcludeHojinkakuPartial__c = false;      // 自動連携:会社名は法人格を除いて部分一致
      bs.RenkeiExcludeHojinkaku__c = false;      // 自動連携:会社名は法人格を除いて完全一致
      //bs.RenkeiAccountSitePartialMatch__c = true;      // 自動連携:部署は中間一致検索
      //bs.RenkeiContactMail__c = true;      // コンタクト メールアドレス
      //bs.RenkeiContactLastName__c = true;  // コンタクト ラストネーム
      //bs.RenkeiContactFirstName__c = false; // コンタクト ファーストネーム
      bs.HojinkakuEquationLongAndAbbr__c = true; // 	法人格の略称を正称の表記とみなして会社名を比較する
      listBasicSetting.add(bs);
    }
  } // public virtual class TestDbRenkeiAccountNameMatch extends TestDb
  // +--------------------

  // 自動連携して 会社名は法人格を除いて完全一致
  @isTest
  static void test_RenkeiExcludeHojinkaku() {
    TestDb db = new TestDbRenkeiExcludeHojinkaku();
    db.initialize();

    Test.startTest();
    List<Account> listAccount = new List<Account>();
    listAccount.add(new Account(Name='株式会社 テスト商事'));
    insert listAccount;
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社テスト商事', last_name__c='テスト', first_name__c='一郎', email__c='ichiro@test.com', delivery_type__c='2'));
    listCard.add(new NameCard__c(Name='テスト 二郎', company_name__c='㈱テスト商事', last_name__c='テスト', first_name__c='二郎', email__c='jiro@test.com', delivery_type__c='2'));
    insert listCard;
    Test.stopTest();
    List<Account> updatedAccount = [SELECT Id, Name FROM Account];
    System.assertEquals(1, updatedAccount.size());
    List<Contact> updatedContact = [SELECT Id, Name FROM Contact];
    System.assertEquals(listCard.size(), updatedContact.size());
  }

  // 自動連携して 会社名は法人格を除いて部分一致
  @isTest
  static void test_RenkeiExcludeHojinkakuPartial() {
    TestDb db = new TestDbRenkeiExcludeHojinkakuPartial();
    db.initialize();

    Test.startTest();
    List<Account> listAccount = new List<Account>();
    listAccount.add(new Account(Name='株式会社いわゆるテスト商事商会'));
    insert listAccount;
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社テスト商事', last_name__c='テスト', first_name__c='一郎', email__c='ichiro@test.com', delivery_type__c='2'));
    listCard.add(new NameCard__c(Name='テスト 二郎', company_name__c='㈱テスト商事', last_name__c='テスト', first_name__c='二郎', email__c='jiro@test.com', delivery_type__c='2'));
    insert listCard;
    Test.stopTest();
    List<Account> updatedAccount = [SELECT Id, Name FROM Account];
    System.assertEquals(1, updatedAccount.size());
    List<Contact> updatedContact = [SELECT Id, Name FROM Contact];
    System.assertEquals(listCard.size(), updatedContact.size());
  }

  // 自動連携して 会社名は完全一致
  @isTest
  static void test_RenkeiAccountNameMatch() {
    TestDb db = new TestDbRenkeiAccountNameMatch();
    db.initialize();

    Test.startTest();
    List<Account> listAccount = new List<Account>();
    listAccount.add(new Account(Name='株式会社 テスト商事'));
    insert listAccount;
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社テスト商事', last_name__c='テスト', first_name__c='一郎', email__c='ichiro@test.com', delivery_type__c='2'));
    listCard.add(new NameCard__c(Name='テスト 二郎', company_name__c='㈱テスト商事', last_name__c='テスト', first_name__c='二郎', email__c='jiro@test.com', delivery_type__c='2'));
    insert listCard;
    Test.stopTest();
    List<Account> updatedAccount = [SELECT Id, Name FROM Account];
    // System.assertEquals(3, updatedAccount.size());
    System.assertEquals(1, updatedAccount.size());    // 2019.05.xx v2.4 SV_DEV-1647 法人格の正式名称と略称をマッチさせる（登録・自動連携） により 1つになる
    List<Contact> updatedContact = [SELECT Id, Name FROM Contact];
    System.assertEquals(listCard.size(), updatedContact.size());
  }


  // バックスラッシュとか、シングルクオートとかちゃんとしょりできるかテスト
  // 自動連携して 会社名は法人格を除いて一致。＼は ワイルドカード _ に変換してるので、SOQL で = で条件にするとヒットしないので、これでテスト
  // SV_DEV-673 会社名に全角バックスラッシュが含まれる名刺を自動連携すると、ORA-01424エラーが発生
  @isTest
  static void test_RenkeiAccountNameEscaoe() {
    TestDb db = new TestDbRenkeiExcludeHojinkakuPartial(); // 自動連携して 会社名は法人格を除いて一致
    db.initialize();

    List<Account> listAccount = new List<Account>();
    //listAccount.add(new Account(Name='株式会社テスト商事'));
    listAccount.add(new Account(Name='株式会社aaa\\aaa'));
    listAccount.add(new Account(Name='株式会社aaa\\\\aaa'));
    listAccount.add(new Account(Name='株式会社aaa\\\\aa\'a'));
    listAccount.add(new Account(Name='株式会社TBWA＼HAKUHODO'));
    listAccount.add(new Account(Name='HOGEHOGE＼FUGAFUGA'));
    listAccount.add(new Account(Name='株式会社TBWA＼HAKUH\'ODO'));
    listAccount.add(new Account(Name='恵比寿\'株式会社'));
    insert listAccount;
    List<Account> acnts = [SELECT Id, Name FROM Account];
    System.assertEquals(listAccount.size(), acnts.size());
    List<Contact> conts = [SELECT Id, Name FROM Contact];
    System.assertEquals(0, conts.size());

    Test.startTest();
    List<NameCard__c> listCard = new List<NameCard__c>();
    //listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社テスト商事', last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社aaa\\aaa', last_name__c='テスト', first_name__c='一郎', email__c='ichiro@test.com', delivery_type__c='2'));
    // 以下の２つ \\ がつづくと SB_NameCard_Util.getStringForPartialMatch の方をつかわないとだめ
    listCard.add(new NameCard__c(Name='テスト 二郎', company_name__c='株式会社aaa\\\\aaa', last_name__c='テスト', first_name__c='二郎', email__c='jiro@test.com', delivery_type__c='2'));
    listCard.add(new NameCard__c(Name='テスト 三郎', company_name__c='株式会社aaa\\\\aa\'a', last_name__c='テスト', first_name__c='三郎', email__c='saburo@test.com', delivery_type__c='2'));
    listCard.add(new NameCard__c(Name='テスト 四郎', company_name__c='株式会社TBWA＼HAKUHODO', last_name__c='テスト', first_name__c='四郎', email__c='shiro@test.com', delivery_type__c='2'));
    listCard.add(new NameCard__c(Name='テスト 四郎', company_name__c='HOGEHOGE＼FUGAFUGA', last_name__c='テスト', first_name__c='四郎', email__c='shiro@test.com', delivery_type__c='2'));
    listCard.add(new NameCard__c(Name='テスト 五郎', company_name__c='株式会社TBWA＼HAKUH\'ODO', last_name__c='テスト', first_name__c='五郎', email__c='goro@test.com', delivery_type__c='2'));
    listCard.add(new NameCard__c(Name='テスト 六郎', company_name__c='恵比寿\'株式会社', last_name__c='テスト', first_name__c='六郎', email__c='rokuro@test.com', delivery_type__c='2'));
    insert listCard;
    Test.stopTest();
    acnts = [SELECT Id, Name FROM Account];
    System.assertEquals(listAccount.size(), acnts.size());
    conts = [SELECT Id, Name FROM Contact];
    System.assertEquals(listCard.size(), conts.size());
  }


  // バックスラッシュとか、シングルクオートとかちゃんとしょりできるかテスト
  // 完全一致なら、置換やエスケープはしないので、それでいいかどうか
  @isTest
  static void test_RenkeiAccountNameWIthoutEscaoe() {
    TestDb db = new TestDbRenkeiAccountNameMatch(); // 自動連携して 会社名は 完全一致
    db.initialize();

    List<Account> listAccount = new List<Account>();
    //listAccount.add(new Account(Name='株式会社テスト商事'));
    listAccount.add(new Account(Name='株式会社aaa\\aaa'));
    listAccount.add(new Account(Name='株式会社aaa\\\\aaa'));
    listAccount.add(new Account(Name='株式会社aaa\\\\aa\'a'));
    listAccount.add(new Account(Name='株式会社TBWA＼HAKUHODO'));
    listAccount.add(new Account(Name='HOGEHOGE＼FUGAFUGA'));
    listAccount.add(new Account(Name='株式会社TBWA＼HAKUH\'ODO'));
    listAccount.add(new Account(Name='恵比寿\'株式会社'));
    insert listAccount;
    List<Account> acnts = [SELECT Id, Name FROM Account];
    System.assertEquals(listAccount.size(), acnts.size());
    List<Contact> conts = [SELECT Id, Name FROM Contact];
    System.assertEquals(0, conts.size());

    Test.startTest();
    List<NameCard__c> listCard = new List<NameCard__c>();
    //listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社テスト商事', last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2'));
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社aaa\\aaa', last_name__c='テスト', first_name__c='一郎', email__c='ichiro@test.com', delivery_type__c='2'));
    listCard.add(new NameCard__c(Name='テスト 二郎', company_name__c='株式会社aaa\\\\aaa', last_name__c='テスト', first_name__c='二郎', email__c='jiro@test.com', delivery_type__c='2'));
    listCard.add(new NameCard__c(Name='テスト 三郎', company_name__c='株式会社aaa\\\\aa\'a', last_name__c='テスト', first_name__c='三郎', email__c='saburo@test.com', delivery_type__c='2'));
    listCard.add(new NameCard__c(Name='テスト 四郎', company_name__c='株式会社TBWA＼HAKUHODO', last_name__c='テスト', first_name__c='四郎', email__c='shiro@test.com', delivery_type__c='2'));
    listCard.add(new NameCard__c(Name='テスト 四郎', company_name__c='HOGEHOGE＼FUGAFUGA', last_name__c='テスト', first_name__c='四郎', email__c='shiro@test.com', delivery_type__c='2'));
    listCard.add(new NameCard__c(Name='テスト 五郎', company_name__c='株式会社TBWA＼HAKUH\'ODO', last_name__c='テスト', first_name__c='五郎', email__c='goro@test.com', delivery_type__c='2'));
    listCard.add(new NameCard__c(Name='テスト 六郎', company_name__c='恵比寿\'株式会社', last_name__c='テスト', first_name__c='六郎', email__c='rokuro@test.com', delivery_type__c='2'));
    insert listCard;
    Test.stopTest();
    acnts = [SELECT Id, Name FROM Account];
    System.assertEquals(listAccount.size(), acnts.size());
    conts = [SELECT Id, Name FROM Contact];
    System.assertEquals(listCard.size(), conts.size());
  }



}