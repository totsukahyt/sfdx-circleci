/**
*
*  SB_NameCard_RenkeiTriggerHandlerTest
*   自動連携トリガハンドラテスト
*   自動連携機能有効をオン名刺の納品タイプを新規の場合２更新の場合１から２の場合自働連携を行います
*
*    テスト内容
*         １、自働連携ロジクをはしているか
*         ２、自働連携の結果は正しいなのか
*
*  Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
*
*  @author gao
*  @Version 1.20      2017.02.XX
*
**/

@isTest
private class SB_NameCard_RenkeiTriggerHandlerTest {

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

  public static void setDate(){
    NameCardRenkeiJyoken__c jyouken = new NameCardRenkeiJyoken__c();
    jyouken.NameCardName__c = 'Name';
    jyouken.Operator__c = 'Matches_next_character_string';
    jyouken.Value__c = 'test';
    //insert jyouken;
    TestDb db = new TestDb();
    db.initialize();
  }

  //オブジェクトの項目を取得
  private static String getValidFields(String objname) {
    Set<String> result = new Set<String>();
    Map<String,Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    String nobj = SB_NameCard_RenkeiMapperUtil.getManagedObjectName(objname);
    Map<String,Schema.SObjectField> fieldMap = schemaMap.get(nobj).getDescribe().fields.getMap();
    String sql = '';
    for(String f : fieldMap.keySet()){
      sql += f + ',';
    }
    return 'Select ' + sql.removeend(',') + ' From ' + objname;
  }

//自働連携の項目マッピングチェック
private static void checkMapping(NameCard__c card , List<NameCardRenkeiMapping__c> acmappings, List<NameCardRenkeiMapping__c> cpmappings,Account ac,Contact co){
  if(ac != null && !acmappings.isEmpty()){
    //取引先の連携assert
    //今回はカスタムの選択肢は処理しません
    for(NameCardRenkeiMapping__c mp : acmappings){
      if(SB_NameCard_RenkeiMapperUtil.ADDRESS_FIELDS.contains(mp.NameCardName__c)){
          continue;
      }
      System.debug(mp.NameCardName__c + mp.TargetName__c);
      System.assertEquals(card.get(mp.NameCardName__c),ac.get(mp.TargetName__c));
    }
    System.assertEquals(card.get('Account__c'),ac.get('Id'));
  }
  //取引先責任者の連携assert
  //今回はカスタムの選択肢は処理しません
  if(co != null && !cpmappings.isEmpty()){
    for(NameCardRenkeiMapping__c mp : cpmappings){
      if(SB_NameCard_RenkeiMapperUtil.ADDRESS_FIELDS.contains(mp.NameCardName__c) || mp.NameCardName__c == 'first_name' || mp.NameCardName__c == 'last_name'){
          continue;
      }
      System.assertEquals(card.get(mp.NameCardName__c),co.get(mp.TargetName__c));
    }
    System.assertEquals(card.get('Contact__c'),co.get('Id'));
  }
}

  //新規作成の自働連携マッピングの連携
  @isTest static void test_insertNameCard() {
    setDate();
    NameCard__c card = new NameCard__c(
      name= 'test'
      , person_name_last__c= '姓'
      , person_name_first__c= '名'
      , last_name__c= 'last'
      , first_name__c= 'first'
      , email__c= 'test@test.com'
      , company_name__c= 'テスト会社'
      , division__c = '本社'
      , title_name__c = '役職'
      , tel1__c= '22222222222'
      , tel2__c= '11111111111'
      , fax1__c= '0344444444'
      , mobile__c = '09099999999'
      , web_url1__c = 'http://www.web_url1__c'
      , web_url2__c = 'http://www.web_url2__c'
      , zip_code__c = '0210034'
      , address_pref__c = 'test'
      , address__c = 'address__c'
      , address_bld__c = 'address_bld__c'
      , memo__c = 'メモ : '
      , freehandmemo__c = '自由記述 : '
      , delivery_type__c='2'
      , OwnerId = Userinfo.getuserId()
      );
    test.starttest();
    insert card;
    test.stoptest();
    String sqlcard = getValidFields('NameCard__c');
    String sqlac = getValidFields('Account');
    String sqlco = getValidFields('Contact');
    System.debug(sqlac);
    List<NameCard__c> cards = Database.query(sqlcard);
    List<Account> ass = Database.query(sqlac);
    List<Contact> css = Database.query(sqlco);
    System.assertEquals(cards.size(),1);
    System.assertEquals(ass.size(),cards.size());
    System.assertEquals(css.size(),cards.size());
    Account a = [Select NameCard__c From Account];
    //System.assertEquals(cards[0].Id,a.NameCard__c);
    List<NameCardRenkeiMapping__c> acmappings = [Select Id,TargetName__c,NameCardName__c,Recordtype.Developername From NameCardRenkeiMapping__c Where Recordtype.Developername = 'Account'];
    List<NameCardRenkeiMapping__c> comappings = [Select Id,TargetName__c,NameCardName__c,Recordtype.Developername From NameCardRenkeiMapping__c Where Recordtype.Developername = 'Contact'];
    System.assertNotEquals(acmappings.size(),0);
    System.assertNotEquals(comappings.size(),0);
    checkMapping(cards[0],acmappings,comappings,ass[0],css[0]);
  }

  //新規作成の自働連携マッピングしないケースの連携
   @isTest static void test_InsertNameCardNoMapping() {
    setDate();
    NameCard__c card = new NameCard__c(
      name= 'test'
      , person_name_last__c= '姓'
      , person_name_first__c= '名'
      , last_name__c= 'last'
      , first_name__c= 'first'
      , email__c= 'test@test.com'
      , company_name__c= 'テスト会社'
      , division__c = '本社'
      , title_name__c = '役職'
      , tel1__c= '22222222222'
      , tel2__c= '11111111111'
      , fax1__c= '0344444444'
      , mobile__c = '09099999999'
      , web_url1__c = 'http://www.web_url1__c'
      , web_url2__c = 'http://www.web_url2__c'
      , zip_code__c = '0210034'
      , address_pref__c = 'test'
      , address__c = 'address__c'
      , address_bld__c = 'address_bld__c'
      , memo__c = 'メモ : '
      , freehandmemo__c = '自由記述 : '
      , delivery_type__c='1'
      , OwnerId = Userinfo.getuserId()
      );
    test.starttest();
    insert card;
    test.stoptest();
    String sqlcard = getValidFields('NameCard__c');
    String sqlac = getValidFields('Account');
    String sqlco = getValidFields('Contact');
    System.debug(sqlac);
    List<NameCard__c> cards = Database.query(sqlcard);
    List<Account> ass = Database.query(sqlac);
    List<Contact> css = Database.query(sqlco);
    System.assertEquals(cards.size(),1);
    System.assertEquals(ass.size(),0);
    System.assertEquals(css.size(),0);
    //System.assertEquals(cards[0].Id,a.NameCard__c);
  }

  //名刺更新ラストネームがないケースの連携
  @isTest static void test_UpdateNameCardNoLastName() {
    setDate();
    NameCard__c card = new NameCard__c(
      name= 'test'
      , person_name_last__c= '姓'
      , person_name_first__c= '名'
      , first_name__c= 'first'
      , email__c= 'test@test.com'
      , company_name__c= 'テスト会社'
      , division__c = '本社'
      , title_name__c = '役職'
      , tel1__c= '22222222222'
      , tel2__c= '11111111111'
      , fax1__c= '0344444444'
      , mobile__c = '09099999999'
      , web_url1__c = 'http://www.web_url1__c'
      , web_url2__c = 'http://www.web_url2__c'
      , zip_code__c = '0210034'
      , address_pref__c = 'test'
      , address__c = 'address__c'
      , address_bld__c = 'address_bld__c'
      , memo__c = 'メモ : '
      , freehandmemo__c = '自由記述 : '
      , delivery_type__c='1'
      , OwnerId = Userinfo.getuserId()
      );
    insert card;
    card.delivery_type__c = '2';
    update card;
    String sqlcard = getValidFields('NameCard__c');
    String sqlac = getValidFields('Account');
    String sqlco = getValidFields('Contact');
    System.debug(sqlac);
    List<NameCard__c> cards = Database.query(sqlcard);
    List<Account> ass = Database.query(sqlac);
    List<Contact> css = Database.query(sqlco);
    List<NameCardRenkeiMapping__c> acmappings = [Select Id,TargetName__c,NameCardName__c,Recordtype.Developername From NameCardRenkeiMapping__c Where Recordtype.Developername = 'Account'];
    List<NameCardRenkeiMapping__c> comappings = [Select Id,TargetName__c,NameCardName__c,Recordtype.Developername From NameCardRenkeiMapping__c Where Recordtype.Developername = 'Contact'];
    System.assertEquals(cards.size(),1);
    System.assertEquals(ass.size(),cards.size());
    System.assertEquals(css.size(),cards.size());
    checkMapping(cards[0],acmappings,comappings,ass[0],css[0]);
  }

  //名刺更新姓とラーストネームがないケースの連携
  @isTest static void test_UpdataNameCardNoLastNoPLast() {
    setDate();
    NameCard__c card = new NameCard__c(
      name= 'test'
      , person_name_first__c= '名'
      , first_name__c= 'first'
      , email__c= 'test@test.com'
      , company_name__c= 'テスト会社'
      , division__c = '本社'
      , title_name__c = '役職'
      , tel1__c= '22222222222'
      , tel2__c= '11111111111'
      , fax1__c= '0344444444'
      , mobile__c = '09099999999'
      , web_url1__c = 'http://www.web_url1__c'
      , web_url2__c = 'http://www.web_url2__c'
      , zip_code__c = '0210034'
      , address_pref__c = 'test'
      , address__c = 'address__c'
      , address_bld__c = 'address_bld__c'
      , memo__c = 'メモ : '
      , freehandmemo__c = '自由記述 : '
      , delivery_type__c='2'
      , OwnerId = Userinfo.getuserId()
      );
    insert card;
    card.delivery_type__c = '2';
    update card;
    List<Account> ass = [Select Id,Name From Account];
    List<Contact> css = [Select Id From Contact];
    List<NameCard__c> cards = [Select Id,Name From NameCard__c];
    System.assertEquals(cards.size(),1);
    System.assertEquals(ass.size(),0);
    System.assertEquals(css.size(),0);
  }

  //名刺更新会社名がないケースの連携
  @isTest static void test_UpdataNameCardNoCompanyName() {
    setDate();
    NameCard__c card = new NameCard__c(
      name= 'test'
      , person_name_last__c= '姓'
      , person_name_first__c= '名'
      , last_name__c= 'last'
      , first_name__c= 'first'
      , email__c= 'test@test.com'
      , division__c = '本社'
      , title_name__c = '役職'
      , tel1__c= '22222222222'
      , tel2__c= '11111111111'
      , fax1__c= '0344444444'
      , mobile__c = '09099999999'
      , web_url1__c = 'http://www.web_url1__c'
      , web_url2__c = 'http://www.web_url2__c'
      , zip_code__c = '0210034'
      , address_pref__c = 'test'
      , address__c = 'address__c'
      , address_bld__c = 'address_bld__c'
      , memo__c = 'メモ : '
      , freehandmemo__c = '自由記述 : '
      , delivery_type__c='1'
      , OwnerId = Userinfo.getuserId()
      );
    insert card;
    card.delivery_type__c = '2';
    update card;
    List<Account> ass = [Select Id,Name From Account];
    List<Contact> css = [Select Id From Contact];
    List<NameCard__c> cards = [Select Id,Name From NameCard__c];
    System.assertEquals(cards.size(),1);
    System.assertEquals(ass.size(),0);
    System.assertEquals(css.size(),0);
  }

  //名刺更新姓がないケースの連携
  @isTest static void test_UpdateNameCardNoPLastName() {
    setDate();
    NameCard__c card = new NameCard__c(
      name= 'test'
      , person_name_first__c= '名'
      , last_name__c= 'last'
      , first_name__c= 'first'
      , email__c= 'test@test.com'
      , company_name__c= 'テスト会社'
      , division__c = '本社'
      , title_name__c = '役職'
      , tel1__c= '22222222222'
      , tel2__c= '11111111111'
      , fax1__c= '0344444444'
      , mobile__c = '09099999999'
      , web_url1__c = 'http://www.web_url1__c'
      , web_url2__c = 'http://www.web_url2__c'
      , zip_code__c = '0210034'
      , address_pref__c = 'test'
      , address__c = 'address__c'
      , address_bld__c = 'address_bld__c'
      , memo__c = 'メモ : '
      , freehandmemo__c = '自由記述 : '
      , delivery_type__c='1'
      , OwnerId = Userinfo.getuserId()
      );
    insert card;
    card.delivery_type__c = '2';
    update card;
    String sqlcard = getValidFields('NameCard__c');
    String sqlac = getValidFields('Account');
    String sqlco = getValidFields('Contact');
    System.debug(sqlac);
    List<NameCard__c> cards = Database.query(sqlcard);
    List<Account> ass = Database.query(sqlac);
    List<Contact> css = Database.query(sqlco);
    System.assertEquals(cards.size(),1);
    System.assertEquals(ass.size(),cards.size());
    System.assertEquals(css.size(),cards.size());
    List<NameCardRenkeiMapping__c> acmappings = [Select Id,TargetName__c,NameCardName__c,Recordtype.Developername From NameCardRenkeiMapping__c Where Recordtype.Developername = 'Account'];
    List<NameCardRenkeiMapping__c> comappings = [Select Id,TargetName__c,NameCardName__c,Recordtype.Developername From NameCardRenkeiMapping__c Where Recordtype.Developername = 'Contact'];
    checkMapping(cards[0],acmappings,comappings,ass[0],css[0]);
  }

  //upsertの連携
  @isTest static void test_UpsertNameCard() {
    setDate();
    NameCard__c card = new NameCard__c(
      name= 'test'
      , person_name_last__c= '姓'
      , person_name_first__c= '名'
      , last_name__c= 'last'
      , first_name__c= 'first'
      , email__c= 'test@test.com'
      , company_name__c= 'テスト会社'
      , division__c = '本社'
      , title_name__c = '役職'
      , tel1__c= '22222222222'
      , tel2__c= '11111111111'
      , fax1__c= '0344444444'
      , mobile__c = '09099999999'
      , web_url1__c = 'http://www.web_url1__c'
      , web_url2__c = 'http://www.web_url2__c'
      , zip_code__c = '0210034'
      , address_pref__c = 'test'
      , address__c = 'address__c'
      , address_bld__c = 'address_bld__c'
      , memo__c = 'メモ : '
      , freehandmemo__c = '自由記述 : '
      , delivery_type__c='1'
      , OwnerId = Userinfo.getuserId()
      );
    insert card;
    List<NameCard__c> ns = new  List<NameCard__c>();
    NameCard__c card1 = new NameCard__c(
      name= 'test'
      , person_name_last__c= '姓1'
      , person_name_first__c= '名1'
      , last_name__c= 'last1'
      , first_name__c= 'first1'
      , email__c= 'test@test123.com'
      , company_name__c= 'テスト1会社'
      , division__c = '本社'
      , title_name__c = '役職'
      , tel1__c= '22222222222'
      , tel2__c= '11111111111'
      , fax1__c= '0344444444'
      , mobile__c = '09099999999'
      , web_url1__c = 'http://www.web_url1__c'
      , web_url2__c = 'http://www.web_url2__c'
      , zip_code__c = '0220034'
      , address_pref__c = 'test'
      , address__c = 'address__c'
      , address_bld__c = 'address_bld__c'
      , memo__c = 'メモ : '
      , freehandmemo__c = '自由記述 : '
      , delivery_type__c='2'
      , OwnerId = Userinfo.getuserId()
      );
    //納品タイプ２の新規名刺をリストに差し込みinserのHandlerロジクをはしる
    ns.add(card1);

    System.assertEquals(SB_NameCard_RenkeiTriggerHandler.firstRunUpdate,true);
    System.assertEquals(SB_NameCard_RenkeiTriggerHandler.firstRunInsert,true);

    NameCard__c card2 = [Select Id,Name From NameCard__c];
    card2.delivery_type__c = '2';
    //納品タイプから２に更新の名刺をリストに差し込みupdateのHandlerロジクをはしる
    ns.add(card2);
    upsert ns;
    System.assertEquals(SB_NameCard_RenkeiTriggerHandler.firstRunUpdate,false);
    System.assertEquals(SB_NameCard_RenkeiTriggerHandler.firstRunInsert,false);
    String sqlcard = getValidFields('NameCard__c');
    String sqlac = getValidFields('Account');
    String sqlco = getValidFields('Contact');
    System.debug(sqlac);
    List<NameCard__c> cards = Database.query(sqlcard);
    List<Account> ass = Database.query(sqlac);
    List<Contact> css = Database.query(sqlco);
    System.assertEquals(cards.size(),ass.size());
    System.assertEquals(cards.size(),css.size());
    List<NameCardRenkeiMapping__c> acmappings = [Select Id,TargetName__c,NameCardName__c,Recordtype.Developername From NameCardRenkeiMapping__c Where Recordtype.Developername = 'Account'];
    List<NameCardRenkeiMapping__c> comappings = [Select Id,TargetName__c,NameCardName__c,Recordtype.Developername From NameCardRenkeiMapping__c Where Recordtype.Developername = 'Contact'];
    Map<Id,Account> am = new Map<Id,Account>();
    Map<Id,Contact> cm = new Map<Id,Contact>();
    for(Account a : ass){
      am.put(a.NameCard__c,a);
    }
    for(Contact c : css){
      cm.put(c.NameCard__c,c);
    }
    for(NameCard__c nc : cards){
      checkMapping(nc,acmappings,comappings,am.get(nc.Id),cm.get(nc.Id));
    }
  }

  //upsertの連携エラー1ケース
  @isTest static void test_UpsertNameCardError1() {
    setDate();
    NameCard__c card = new NameCard__c(
      name= 'test'
      , person_name_last__c= '姓'
      , person_name_first__c= '名'
      , last_name__c= 'last'
      , first_name__c= 'first'
      , email__c= 'test@test.com'
      , company_name__c= 'テスト会社'
      , division__c = '本社'
      , title_name__c = '役職'
      , tel1__c= '22222222222'
      , tel2__c= '11111111111'
      , fax1__c= '0344444444'
      , mobile__c = '09099999999'
      , web_url1__c = 'http://www.web_url1__c'
      , web_url2__c = 'http://www.web_url2__c'
      , zip_code__c = '0210034'
      , address_pref__c = 'test'
      , address__c = 'address__c'
      , address_bld__c = 'address_bld__c'
      , memo__c = 'メモ : '
      , freehandmemo__c = '自由記述 : '
      , delivery_type__c='1'
      , OwnerId = Userinfo.getuserId()
      ,error__c = 'error_code:1'
      );
    insert card;
    List<NameCard__c> ns = new  List<NameCard__c>();
    NameCard__c card1 = new NameCard__c(
      name= 'test'
      , person_name_last__c= '姓1'
      , person_name_first__c= '名1'
      , last_name__c= 'last1'
      , first_name__c= 'first1'
      , email__c= 'test@test123.com'
      , company_name__c= 'テスト1会社'
      , division__c = '本社'
      , title_name__c = '役職'
      , tel1__c= '22222222222'
      , tel2__c= '11111111111'
      , fax1__c= '0344444444'
      , mobile__c = '09099999999'
      , web_url1__c = 'http://www.web_url1__c'
      , web_url2__c = 'http://www.web_url2__c'
      , zip_code__c = '0220034'
      , address_pref__c = 'test'
      , address__c = 'address__c'
      , address_bld__c = 'address_bld__c'
      , memo__c = 'メモ : '
      , freehandmemo__c = '自由記述 : '
      , delivery_type__c='2'
      ,error__c = 'error_code:1'
      , OwnerId = Userinfo.getuserId()
      );
    //納品タイプ２の新規名刺をリストに差し込みinserのHandlerロジクをはしる
    ns.add(card1);

    System.assertEquals(SB_NameCard_RenkeiTriggerHandler.firstRunUpdate,true);
    System.assertEquals(SB_NameCard_RenkeiTriggerHandler.firstRunInsert,true);

    NameCard__c card2 = [Select Id,Name From NameCard__c];
    card2.delivery_type__c = '2';
    //納品タイプから２に更新の名刺をリストに差し込みupdateのHandlerロジクをはしる
    ns.add(card2);
    upsert ns;
    System.assertEquals(SB_NameCard_RenkeiTriggerHandler.firstRunUpdate,true);
    System.assertEquals(SB_NameCard_RenkeiTriggerHandler.firstRunInsert,true);
    String sqlcard = getValidFields('NameCard__c');
    String sqlac = getValidFields('Account');
    String sqlco = getValidFields('Contact');
    System.debug(sqlac);
    List<NameCard__c> cards = Database.query(sqlcard);
    List<Account> ass = Database.query(sqlac);
    List<Contact> css = Database.query(sqlco);
    System.assertEquals(0,ass.size());
    System.assertEquals(0,css.size());
  }

  //upsertの連携エラー2ケース
  @isTest static void test_UpsertNameCardError2() {
    setDate();
    NameCard__c card = new NameCard__c(
      name= 'test'
      , person_name_last__c= '姓'
      , person_name_first__c= '名'
      , last_name__c= 'last'
      , first_name__c= 'first'
      , email__c= 'test@test.com'
      , company_name__c= 'テスト会社'
      , division__c = '本社'
      , title_name__c = '役職'
      , tel1__c= '22222222222'
      , tel2__c= '11111111111'
      , fax1__c= '0344444444'
      , mobile__c = '09099999999'
      , web_url1__c = 'http://www.web_url1__c'
      , web_url2__c = 'http://www.web_url2__c'
      , zip_code__c = '0210034'
      , address_pref__c = 'test'
      , address__c = 'address__c'
      , address_bld__c = 'address_bld__c'
      , memo__c = 'メモ : '
      , freehandmemo__c = '自由記述 : '
      , delivery_type__c='1'
      , OwnerId = Userinfo.getuserId()
      ,error__c = 'error_code:2'
      );
    insert card;
    List<NameCard__c> ns = new  List<NameCard__c>();
    NameCard__c card1 = new NameCard__c(
      name= 'test'
      , person_name_last__c= '姓1'
      , person_name_first__c= '名1'
      , last_name__c= 'last1'
      , first_name__c= 'first1'
      , email__c= 'test@test123.com'
      , company_name__c= 'テスト1会社'
      , division__c = '本社'
      , title_name__c = '役職'
      , tel1__c= '22222222222'
      , tel2__c= '11111111111'
      , fax1__c= '0344444444'
      , mobile__c = '09099999999'
      , web_url1__c = 'http://www.web_url1__c'
      , web_url2__c = 'http://www.web_url2__c'
      , zip_code__c = '0220034'
      , address_pref__c = 'test'
      , address__c = 'address__c'
      , address_bld__c = 'address_bld__c'
      , memo__c = 'メモ : '
      , freehandmemo__c = '自由記述 : '
      , delivery_type__c='2'
      ,error__c = 'error_code:2'
      , OwnerId = Userinfo.getuserId()
      );
    //納品タイプ２の新規名刺をリストに差し込みinserのHandlerロジクをはしる
    ns.add(card1);

    System.assertEquals(SB_NameCard_RenkeiTriggerHandler.firstRunUpdate,true);
    System.assertEquals(SB_NameCard_RenkeiTriggerHandler.firstRunInsert,true);

    NameCard__c card2 = [Select Id,Name From NameCard__c];
    card2.delivery_type__c = '2';
    //納品タイプから２に更新の名刺をリストに差し込みupdateのHandlerロジクをはしる
    ns.add(card2);
    upsert ns;
    System.assertEquals(SB_NameCard_RenkeiTriggerHandler.firstRunUpdate,true);
    System.assertEquals(SB_NameCard_RenkeiTriggerHandler.firstRunInsert,true);
    String sqlcard = getValidFields('NameCard__c');
    String sqlac = getValidFields('Account');
    String sqlco = getValidFields('Contact');
    System.debug(sqlac);
    List<NameCard__c> cards = Database.query(sqlcard);
    List<Account> ass = Database.query(sqlac);
    List<Contact> css = Database.query(sqlco);
    System.assertEquals(0,ass.size());
    System.assertEquals(0,css.size());
  }

   //upsertの連携エラー3ケース
  @isTest static void test_UpsertNameCardError3() {
    setDate();
    NameCard__c card = new NameCard__c(
      name= 'test'
      , person_name_last__c= '姓'
      , person_name_first__c= '名'
      , last_name__c= 'last'
      , first_name__c= 'first'
      , email__c= 'test@test.com'
      , company_name__c= 'テスト会社'
      , division__c = '本社'
      , title_name__c = '役職'
      , tel1__c= '22222222222'
      , tel2__c= '11111111111'
      , fax1__c= '0344444444'
      , mobile__c = '09099999999'
      , web_url1__c = 'http://www.web_url1__c'
      , web_url2__c = 'http://www.web_url2__c'
      , zip_code__c = '0210034'
      , address_pref__c = 'test'
      , address__c = 'address__c'
      , address_bld__c = 'address_bld__c'
      , memo__c = 'メモ : '
      , freehandmemo__c = '自由記述 : '
      , delivery_type__c='1'
      , OwnerId = Userinfo.getuserId()
      ,error__c = 'error_code:3'
      );
    insert card;
    List<NameCard__c> ns = new  List<NameCard__c>();
    NameCard__c card1 = new NameCard__c(
      name= 'test'
      , person_name_last__c= '姓1'
      , person_name_first__c= '名1'
      , last_name__c= 'last1'
      , first_name__c= 'first1'
      , email__c= 'test@test123.com'
      , company_name__c= 'テスト1会社'
      , division__c = '本社'
      , title_name__c = '役職'
      , tel1__c= '22222222222'
      , tel2__c= '11111111111'
      , fax1__c= '0344444444'
      , mobile__c = '09099999999'
      , web_url1__c = 'http://www.web_url1__c'
      , web_url2__c = 'http://www.web_url2__c'
      , zip_code__c = '0220034'
      , address_pref__c = 'test'
      , address__c = 'address__c'
      , address_bld__c = 'address_bld__c'
      , memo__c = 'メモ : '
      , freehandmemo__c = '自由記述 : '
      , delivery_type__c='2'
      ,error__c = 'error_code:3'
      , OwnerId = Userinfo.getuserId()
      );
    //納品タイプ２の新規名刺をリストに差し込みinserのHandlerロジクをはしる
    ns.add(card1);

    System.assertEquals(SB_NameCard_RenkeiTriggerHandler.firstRunUpdate,true);
    System.assertEquals(SB_NameCard_RenkeiTriggerHandler.firstRunInsert,true);

    NameCard__c card2 = [Select Id,Name From NameCard__c];
    card2.delivery_type__c = '2';
    //納品タイプから２に更新の名刺をリストに差し込みupdateのHandlerロジクをはしる
    ns.add(card2);
    upsert ns;
    System.assertEquals(SB_NameCard_RenkeiTriggerHandler.firstRunUpdate,true);
    System.assertEquals(SB_NameCard_RenkeiTriggerHandler.firstRunInsert,true);
    String sqlcard = getValidFields('NameCard__c');
    String sqlac = getValidFields('Account');
    String sqlco = getValidFields('Contact');
    System.debug(sqlac);
    List<NameCard__c> cards = Database.query(sqlcard);
    List<Account> ass = Database.query(sqlac);
    List<Contact> css = Database.query(sqlco);
    System.assertEquals(0,ass.size());
    System.assertEquals(0,css.size());
  }

   //upsertの連携エラー4ケース
  @isTest static void test_UpsertNameCardError4() {
    setDate();
    NameCard__c card = new NameCard__c(
      name= 'test'
      , person_name_last__c= '姓'
      , person_name_first__c= '名'
      , last_name__c= 'last'
      , first_name__c= 'first'
      , email__c= 'test@test.com'
      , company_name__c= 'テスト会社'
      , division__c = '本社'
      , title_name__c = '役職'
      , tel1__c= '22222222222'
      , tel2__c= '11111111111'
      , fax1__c= '0344444444'
      , mobile__c = '09099999999'
      , web_url1__c = 'http://www.web_url1__c'
      , web_url2__c = 'http://www.web_url2__c'
      , zip_code__c = '0210034'
      , address_pref__c = 'test'
      , address__c = 'address__c'
      , address_bld__c = 'address_bld__c'
      , memo__c = 'メモ : '
      , freehandmemo__c = '自由記述 : '
      , delivery_type__c='1'
      , OwnerId = Userinfo.getuserId()
      ,error__c = 'INVALID_EMAIL_ADDRESS'
      );
    insert card;
    List<NameCard__c> ns = new  List<NameCard__c>();
    NameCard__c card1 = new NameCard__c(
      name= 'test'
      , person_name_last__c= '姓1'
      , person_name_first__c= '名1'
      , last_name__c= 'last1'
      , first_name__c= 'first1'
      , email__c= 'test@test123.com'
      , company_name__c= 'テスト1会社'
      , division__c = '本社'
      , title_name__c = '役職'
      , tel1__c= '22222222222'
      , tel2__c= '11111111111'
      , fax1__c= '0344444444'
      , mobile__c = '09099999999'
      , web_url1__c = 'http://www.web_url1__c'
      , web_url2__c = 'http://www.web_url2__c'
      , zip_code__c = '0220034'
      , address_pref__c = 'test'
      , address__c = 'address__c'
      , address_bld__c = 'address_bld__c'
      , memo__c = 'メモ : '
      , freehandmemo__c = '自由記述 : '
      , delivery_type__c='2'
      ,error__c = 'INVALID_EMAIL_ADDRESS'
      , OwnerId = Userinfo.getuserId()
      );
    //納品タイプ２の新規名刺をリストに差し込みinserのHandlerロジクをはしる
    ns.add(card1);

    System.assertEquals(SB_NameCard_RenkeiTriggerHandler.firstRunUpdate,true);
    System.assertEquals(SB_NameCard_RenkeiTriggerHandler.firstRunInsert,true);

    NameCard__c card2 = [Select Id,Name From NameCard__c];
    card2.delivery_type__c = '2';
    //納品タイプから２に更新の名刺をリストに差し込みupdateのHandlerロジクをはしる
    ns.add(card2);
    upsert ns;
    System.assertEquals(SB_NameCard_RenkeiTriggerHandler.firstRunUpdate,false);
    System.assertEquals(SB_NameCard_RenkeiTriggerHandler.firstRunInsert,false);
    String sqlcard = getValidFields('NameCard__c');
    String sqlac = getValidFields('Account');
    String sqlco = getValidFields('Contact');
    System.debug(sqlac);
    List<NameCard__c> cards = Database.query(sqlcard);
    List<Account> ass = Database.query(sqlac);
    List<Contact> css = Database.query(sqlco);
    System.assertEquals(cards.size(),ass.size());
    System.assertEquals(cards.size(),css.size());
    List<NameCardRenkeiMapping__c> acmappings = [Select Id,TargetName__c,NameCardName__c,Recordtype.Developername From NameCardRenkeiMapping__c Where Recordtype.Developername = 'Account'];
    List<NameCardRenkeiMapping__c> comappings = [Select Id,TargetName__c,NameCardName__c,Recordtype.Developername From NameCardRenkeiMapping__c Where Recordtype.Developername = 'Contact'];
    Map<Id,Account> am = new Map<Id,Account>();
    Map<Id,Contact> cm = new Map<Id,Contact>();
    for(Account a : ass){
      am.put(a.NameCard__c,a);
    }
    for(Contact c : css){
      cm.put(c.NameCard__c,c);
    }
    for(NameCard__c nc : cards){
      checkMapping(nc,acmappings,comappings,am.get(nc.Id),cm.get(nc.Id));
    }
  }

}