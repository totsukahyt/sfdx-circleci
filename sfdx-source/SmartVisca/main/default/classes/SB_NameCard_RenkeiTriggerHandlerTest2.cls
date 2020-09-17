/**
*
*  SB_NameCard_RenkeiTriggerHandlerTest2
*   自動連携トリガハンドラテスト
*   SV_DEV-956 【例外条件】取引先名「？」で納品され、「姓（ラストネーム）」が入力されている場合に自動連携されてしまう。
*
*    テスト内容
*     会社名 ? を無視するか。姓 ? を無視するか、姓なし ラストネームありを 処理するか。 姓 ? を無視するか
*
*  Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
*
*  @author sawano
*  @Version 2.4      2019.07.XX
*
**/

@isTest
public with sharing class SB_NameCard_RenkeiTriggerHandlerTest2 {

  public virtual class TestDb extends SB_NC_TestDB {

    public virtual override void initializeBasicSetting() {
      NameCardBasicSetting__c bs = new NameCardBasicSetting__c(
        RenkeiActive__c = true,      // 自動連携機能有効
        RenkeiAccountAddressPref__c = true,   // アカウント 都道府県
        RenkeiAccount_Street__c = true,   // アカウント 町名・番地
        RenkeiAccountZipCode__c = true,   // アカウント 郵便番号
        RenkeiAccountCity__c = true,      // アカウント 市区郡
        RenkeiAccountURL__c = true,       // アカウント URL
        RenkeiAccountCompany__c = true,   // アカウント 会社名
        RenkeiAccountPhone__c = true,     // アカウント 電話番号
        RenkeiSpecificItems__c = null,        // アカウント 特定項目
        RenkeiAccountSite__c = true,        // アカウント 部署名
        RenkeiExcludeHojinkakuPartial__c = true,      // 自動連携:会社名は法人格を除いて部分一致
        RenkeiExcludeHojinkaku__c = true,      // 自動連携:会社名は法人格を除いて完全一致
        RenkeiAccountSitePartialMatch__c = true,      // 自動連携:部署は中間一致検索
        RenkeiContactLastName__c = true,  // コンタクト 姓
        RenkeiContactFirstName__c = true, // コンタクト 名
        RenkeiContactMail__c = true,      // コンタクト メールアドレス
        RenkeiAccountQueryRecordTypeIds__c = null,    // 検索対象のレコードタイプタイプID カンマ区切り で羅列
        RenkeiContactQueryRecordTypeIds__c = null,  // 自動連携で検索対象の取引先責任者レコードタイプ
        RenkeiAccountOverwrite__c = true,   // 既存の取引先を上書き
        RenkeiContactOverwrite__c = true,   // 既存の取引先責任者を上書き
        RenkeiAccountNOExistCreateNew__c = true,  //既存の取引先がなければ新規作成する
        RenkeiContactNOExistCreateNew__c = true,  // 既存の取引先責任者がなければ新規作成する
        RenkeiAccountRecordTypes__c = null,     // 作成するアカウント の レコードタイプID １つ
        RenkeiContactRecordTypes__c = null,      // 作成するコンタクト の レコードタイプID １つ
        SaishinInheritValues__c = false,          //最新名刺は値を引継ぐ
        RegistToDoSubject__c = Label.SB_NC_ExchangeCard, // 取引先・取引先任者に登録 ToDo件名
        RegistNoToDo__c =  false, // 取引先・取引先任者に登録 ToDo登録しない
        RegistDispOverWriteCheckbox__c = true, // 取引先・取引先任者に登録 「上書きする」チェックボックスを表示する
        RegistDispAccountRectype__c = true, // 取引先・取引先任者に登録 取引先レコードタイプ選択を表示する
        RegistAccountNotOverWrite__c = false, // 取引先・取引先任者に登録 取引先を名刺情報で上書きしない
        RegistDispContactRectype__c = true, // 取引先・取引先任者に登録 取引先責任者レコードタイプ選択を表示する
        RegistContactNotOverWrite__c = false // 取引先・取引先任者に登録 取引先責任者を名刺情報で上書きしない
      );
      listBasicSetting.add(bs);
    }

    public override void initialize() {
      initializeUser();
      if (listUser.isEmpty() == false)
        insert listUser;
      // 名刺基本設定
      initializeBasicSetting();
      if (!listBasicSetting.isEmpty()) {
        insert listBasicSetting;
      }
      //// 名刺連携項目マッピング
      initializeMapping();
      if (!listMapping.isEmpty()) {
        insert listMapping;
      }
    }
  }

  @isTest static void test_insertNameCard_Renkei_ok() {
    TestDb db = new TestDb();
    db.initialize();
    
    test.startTest();
    NameCard__c card = new NameCard__c(
      Name = '姓 名'
      , person_name_last__c = '姓'
      , person_name_first__c = '名'
      , last_name__c = 'last'
      , first_name__c = 'first'
      , company_name__c= 'テスト会社'
      , delivery_type__c ='2'
      , OwnerId = Userinfo.getuserId()
      );
    insert card;
    test.stopTest();

    List<NameCard__c> cards = [SELECT Id, Name, account__c, contact__c, RenkeiMessage__c FROM NameCard__c WHERE Name = '姓 名'];
    System.assert(cards[0].RenkeiMessage__c != null);
  }


  @isTest static void test_insertNameCard_Renkei_Skip_company_name_null() {
    TestDb db = new TestDb();
    db.initialize();
    
    test.startTest();
    NameCard__c card = new NameCard__c(
      Name = '姓 名'
      , person_name_last__c = '姓'
      , person_name_first__c = '名'
      , last_name__c = 'last'
      , first_name__c = 'first'
      , company_name__c= null
      , delivery_type__c ='2'
      , OwnerId = Userinfo.getuserId()
      );
    insert card;
    test.stopTest();

    List<NameCard__c> cards = [SELECT Id, Name, account__c, contact__c, RenkeiMessage__c FROM NameCard__c WHERE Name = '姓 名'];
    System.assert(cards[0].RenkeiMessage__c == null);
  }



  @isTest static void test_insertNameCard_Renkei_Skip_company_name_Q() {
    TestDb db = new TestDb();
    db.initialize();
    
    test.startTest();
    NameCard__c card = new NameCard__c(
      Name = '姓 名'
      , person_name_last__c = '姓'
      , person_name_first__c = '名'
      , last_name__c = 'last'
      , first_name__c = 'first'
      , company_name__c= '?'
      , delivery_type__c ='2'
      , OwnerId = Userinfo.getuserId()
      );
    insert card;
    test.stopTest();

    List<NameCard__c> cards = [SELECT Id, Name, account__c, contact__c, RenkeiMessage__c FROM NameCard__c WHERE Name = '姓 名'];
    System.assert(cards[0].RenkeiMessage__c == null);
  }

  @isTest static void test_insertNameCard_Renkei_Skip_lastname_null() {
    TestDb db = new TestDb();
    db.initialize();
    
    test.startTest();
    NameCard__c card = new NameCard__c(
      Name = '姓 名'
      , person_name_last__c = null
      , person_name_first__c = '名'
      , last_name__c =  null
      , first_name__c = 'first'
      , company_name__c= 'テスト会社'
      , delivery_type__c ='2'
      , OwnerId = Userinfo.getuserId()
      );
    insert card;
    test.stopTest();

    List<NameCard__c> cards = [SELECT Id, Name, account__c, contact__c, RenkeiMessage__c FROM NameCard__c WHERE Name = '姓 名'];
    System.assert(cards[0].RenkeiMessage__c == null);
  }
  
  @isTest static void test_insertNameCard_Renkei_Skip_lastname_Q() {
    TestDb db = new TestDb();
    db.initialize();
    
    test.startTest();
    NameCard__c card = new NameCard__c(
      Name = '姓 名'
      , person_name_last__c = '?'
      , person_name_first__c = '名'
      , last_name__c =  null
      , first_name__c = 'first'
      , company_name__c= 'テスト会社'
      , delivery_type__c ='2'
      , OwnerId = Userinfo.getuserId()
      );
    insert card;
    test.stopTest();

    List<NameCard__c> cards = [SELECT Id, Name, account__c, contact__c, RenkeiMessage__c FROM NameCard__c WHERE Name = '姓 名'];
    System.assert(cards[0].RenkeiMessage__c == null);
  }

  @isTest static void test_insertNameCard_Renkei_Ok_lastname_null_fill() {
    TestDb db = new TestDb();
    db.initialize();
    
    test.startTest();
    NameCard__c card = new NameCard__c(
      Name = '姓 名'
      , person_name_last__c = null
      , person_name_first__c = '名'
      , last_name__c =  'last'
      , first_name__c = 'first'
      , company_name__c= 'テスト会社'
      , delivery_type__c ='2'
      , OwnerId = Userinfo.getuserId()
      );
    insert card;
    test.stopTest();

    List<NameCard__c> cards = [SELECT Id, Name, account__c, contact__c, RenkeiMessage__c FROM NameCard__c WHERE Name = '姓 名'];
    System.assert(cards[0].RenkeiMessage__c != null);
  }
  
}