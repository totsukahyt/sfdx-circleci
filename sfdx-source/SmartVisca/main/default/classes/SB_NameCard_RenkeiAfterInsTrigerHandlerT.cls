/**
 *
 *  SB_NameCard_RenkeiAfterInsTrigerHandlerT
 *   納品タイプ2でInsertされたとき、Before Insert　トリガで、アカウント、コンタクトの名刺参照項目に 名刺レコードIDがNULLとなるので、
 *    それをリカバするための After Insert で動くトリガのハンドラクラス の テストクラス
 *
 *
 *  Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2017.03.xx
 *
 **/
@isTest
private class SB_NameCard_RenkeiAfterInsTrigerHandlerT {

  public class TestDb extends SB_NC_TestDB {

    public override void initializeBasicSetting() {
      NameCardBasicSetting__c bs = SB_NC_PostInstallScript.createDefaultBasicSetting();
      bs.RenkeiActive__c = true;      // 自動連携機能有
      //NameCardBasicSetting__c bs = new NameCardBasicSetting__c(
      //  RenkeiActive__c = true,      // 自動連携機能有効
      //  RenkeiAccountAddressPref__c = false,   // アカウント 都道府県
      //  RenkeiAccount_Street__c = false,   // アカウント 町名・番地
      //  RenkeiAccountZipCode__c = false,   // アカウント 郵便番号
      //  RenkeiAccountCity__c = false,      // アカウント 市区郡
      //  RenkeiAccountURL__c = false,       // アカウント URL
      //  RenkeiAccountCompany__c = true,   // アカウント 会社名
      //  RenkeiAccountPhone__c = false,     // アカウント 電話番号
      //  RenkeiSpecificItems__c = null,        // アカウント 特定項目
      //  RenkeiAccountSite__c = false,        // アカウント 部署名
      //  RenkeiExcludeHojinkakuPartial__c = true,      // 自動連携:会社名は法人格を除いて部分一致
      //  RenkeiExcludeHojinkaku__c = false,      // 自動連携:会社名は法人格を除いて完全一致
      //  RenkeiAccountSitePartialMatch__c = true,      // 自動連携:部署は中間一致検索
      //  RenkeiContactMail__c = true,      // コンタクト メールアドレス
      //  RenkeiContactLastName__c = true,  // コンタクト ラストネーム
      //  RenkeiContactFirstName__c = false, // コンタクト ファーストネーム
      //  RenkeiAccountQueryRecordTypeIds__c = null,    // 検索対象のレコードタイプタイプID カンマ区切り で羅列
      //  RenkeiContactQueryRecordTypeIds__c = null,  // 自動連携で検索対象の取引先責任者レコードタイプ
      //  RenkeiAccountOverwrite__c = false,   // 既存の取引先を上書き
      //  RenkeiContactOverwrite__c = false,   // 既存の取引先責任者を上書き
      //  RenkeiAccountNOExistCreateNew__c = true,  //既存の取引先がなければ新規作成する
      //  RenkeiContactNOExistCreateNew__c = true,  // 既存の取引先責任者がなければ新規作成する
      //  RenkeiAccountRecordTypes__c = null,     // 作成するアカウント の レコードタイプID １つ
      //  RenkeiContactRecordTypes__c = null,      // 作成するコンタクト の レコードタイプID １つ
      //  SaishinInheritValues__c = false,          //最新名刺は値を引継ぐ
      //  RegistToDoSubject__c = Label.SB_NC_ExchangeCard, // 取引先・取引先任者に登録 ToDo件名
      //  RegistNoToDo__c =  false, // 取引先・取引先任者に登録 ToDo登録しない
      //  RegistDispOverWriteCheckbox__c = true, // 取引先・取引先任者に登録 「上書きする」チェックボックスを表示する
      //  RegistDispAccountRectype__c = true, // 取引先・取引先任者に登録 取引先レコードタイプ選択を表示する
      //  RegistAccountNotOverWrite__c = false, // 取引先・取引先任者に登録 取引先を名刺情報で上書きしない
      //  RegistDispContactRectype__c = true, // 取引先・取引先任者に登録 取引先責任者レコードタイプ選択を表示する
      //  RegistContactNotOverWrite__c = false // 取引先・取引先任者に登録 取引先責任者を名刺情報で上書きしない
      //);
      listBasicSetting.add(bs);
    }

    public override void initializeNameCard() {
      super.initializeNameCard();
      for (NameCard__c obj : listCard) {
        obj.delivery_type__c = '2';
      }
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
      // 名刺連携項目マッピング
      initializeMapping();
      if (!listMapping.isEmpty()) {
        insert listMapping;
      }
      // 名刺関係
      initializeKaisha();     // 会社を揃えておく
      initializeEmployee();   // 会社ごとに名刺の人を揃えておく
      // 名刺
      initializeNameCard();
      if (listCard.isEmpty() == false) {
        insert listCard;
      }
    }

  } // class TestDb


  @isTest
  static void t_updateReference() {
    TestDb db = new TestDb();
    // 名刺 insert で After Insert トリガ実行
    db.initialize();

    // Future メソッドの呼び出し
    Test.startTest();
    Map<Id, NameCard__c> cards = new Map<Id, NameCard__c>([SELECT Id, Name FROM NameCard__c]);
    SB_NameCard_RenkeiAfterInsTrigerHandler.repairNameCardLinkOnAccountContactLead(cards.keySet());
    Test.stopTest();

    // 確認
    List<Account> acnts = [SELECT ID, Name, NameCard__c FROM Account];
    System.assertNotEquals(0, acnts.size());
    for(Account acnt : acnts) {
      System.assertNotEquals(null, acnt.NameCard__c);
    }
    List<Contact> conts = [SELECT ID, Name, NameCard__c FROM Contact];
    System.assertNotEquals(0, conts.size());
    for (Contact cont : conts) {
      System.assertNotEquals(null, cont.NameCard__c);
    }
  }

}