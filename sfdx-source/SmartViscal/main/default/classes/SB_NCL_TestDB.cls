/**
 *
 * SB_NCL_TestDB
 *
 * 新 テストクラス用のデータを作る基底クラス
 *
 *
 * Copyright (C) 2014 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2014.5.xx
 **/
public virtual class SB_NCL_TestDB {

  public static final String NC_QUERY_SIMPLEFIELDS = 'Id, Name'  +
              ', SmartViscaf__company_name__c, SmartViscaf__company_name_kana__c, SmartViscaf__division__c, SmartViscaf__title_name__c' +
              ', SmartViscaf__zip_code__c, SmartViscaf__address_pref__c, SmartViscaf__address__c, SmartViscaf__address_bld__c, SmartViscaf__address_eng__c' +
              ', SmartViscaf__last_name__c, SmartViscaf__first_name__c, SmartViscaf__person_name_last__c, SmartViscaf__person_name_first__c, SmartViscaf__email__c' +
              ', SmartViscaf__tel1__c, SmartViscaf__fax1__c, SmartViscaf__web_url1__c' +
              ', SmartViscaf__account__c, SmartViscaf__contact__c';

  // 項目マッピング用のデータ
  //　アカウント用
  public static final Map<String, Set<String>> SV_TO_ACCOUNT = new Map<String, Set<String>> {
    'SmartViscaf__company_name__c' => new Set<String>{'Name'}
    , 'SmartViscaf__division__c' => new Set<String>{'Site'}
    , 'SmartViscaf__web_url1__c' => new Set<String>{'Website'}
    , 'SmartViscaf__zip_code__c' => new Set<String>{'BillingPostalCode', 'ShippingPostalCode'}
    , 'SmartViscaf__address_pref__c' => new Set<String>{'BillingState', 'ShippingState'}
    , 'city' => new Set<String>{'BillingCity', 'ShippingCity'}
    , 'street' => new Set<String>{'BillingStreet', 'ShippingStreet'}
    , 'street_nobld' => new Set<String>{'dummy'}    // 重複してるが、テストでだけ、
    , 'pref_address_bld' => new Set<String>{'dummy'}    // 重複してるが、テストでだけ、
    , 'address_bld' => new Set<String>{'dummy'}    // 重複してるが、テストでだけ、
    , 'SmartViscaf__tel1__c' => new Set<String>{'Phone'}
    , 'SmartViscaf__fax1__c' => new Set<String>{'Fax'}
    , 'Id' => new Set<String>{'SmartViscaf__NameCard__c'}
    , 'SmartViscaf__list_name__c' => new Set<String>{'SmartViscaf__NameCardListName__c'}
    , 'SmartViscaf__memo__c' => new Set<String>{'SmartViscaf__NameCardMemo__c'}
    , 'SmartViscaf__freehandmemo__c' => new Set<String>{'SmartViscaf__NameCardFreehandmemo__c'}
    , 'OwnerId' => new Set<String>{'OwnerId'}
  };

  // コンタクト用
  public static final Map<String, Set<String>> SV_TO_CONTACT = new Map<String, Set<String>> {
    'last_name' => new Set<String>{'LastName'}
    , 'first_name' => new Set<String>{'FirstName'}
    , 'SmartViscaf__person_name_last_kana__c' => new Set<String>{'dummy'}     // 重複してるが、テストでだけ、
    , 'SmartViscaf__person_name_first_kana__c' => new Set<String>{'dummy'}   // 重複してるが、テストでだけ、
    , 'SmartViscaf__zip_code__c' => new Set<String>{'MailingPostalCode'}
    , 'SmartViscaf__address_pref__c' => new Set<String>{'MailingState'}
    , 'city' => new Set<String>{'MailingCity'}
    , 'street' => new Set<String>{'MailingStreet'}
    , 'SmartViscaf__tel1__c' => new Set<String>{'Phone'}
    , 'SmartViscaf__fax1__c' => new Set<String>{'Fax'}
    , 'SmartViscaf__mobile__c' => new Set<String>{'MobilePhone'}
    , 'SmartViscaf__email__c' => new Set<String>{'Email'}
    , 'SmartViscaf__division__c' => new Set<String>{'Department'}
    , 'SmartViscaf__title_name__c' => new Set<String>{'Title'}
    , 'Id' => new Set<String>{'SmartViscaf__NameCard__c'}
    , 'SmartViscaf__list_name__c' => new Set<String>{'SmartViscaf__NameCardListName__c'}
    , 'SmartViscaf__memo__c' => new Set<String>{'SmartViscaf__NameCardMemo__c'}                // 重複してるが、テストでだけ、
    , 'SmartViscaf__freehandmemo__c' => new Set<String>{'SmartViscaf__NameCardFreehandmemo__c'}
    , 'OwnerId' => new Set<String>{'OwnerId'}
  };

  // リード用
  public static final Map<String, Set<String>> SV_TO_LEAD = new Map<String, Set<String>> {
    'last_name' => new Set<String>{'LastName'}
    , 'first_name' => new Set<String>{'FirstName'}
    , 'SmartViscaf__company_name__c' => new Set<String>{'Company'}
    , 'SmartViscaf__web_url1__c' => new Set<String>{'Website'}
    , 'SmartViscaf__zip_code__c' => new Set<String>{'PostalCode'}
    , 'SmartViscaf__address_pref__c' => new Set<String>{'State'}
    , 'city' => new Set<String>{'City'}
    , 'street' => new Set<String>{'Street'}
    , 'SmartViscaf__tel1__c' => new Set<String>{'Phone'}
    , 'SmartViscaf__fax1__c' => new Set<String>{'Fax'}
    , 'SmartViscaf__mobile__c' => new Set<String>{'MobilePhone'}
    , 'SmartViscaf__email__c' => new Set<String>{'Email'}
    , 'SmartViscaf__title_name__c' => new Set<String>{'Title'}
    , 'Id' => new Set<String>{'NameCard__c'}
    , 'SmartViscaf__list_name__c' => new Set<String>{'NameCardListName__c'}
    , 'SmartViscaf__memo__c' => new Set<String>{'NameCardMemo__c'}                // 重複してるが、テストでだけ、
    , 'SmartViscaf__freehandmemo__c' => new Set<String>{'NameCardFreehandmemo__c'}
    , 'OwnerId' => new Set<String>{'OwnerId'}
  };

  private static final Map<String, Map<String, Set<String>>> otype2DefaultMapping = new Map<String, Map<String, Set<String>>> {
    'Account' => SV_TO_ACCOUNT,
    'Contact' => SV_TO_CONTACT,
    'Lead' => SV_TO_LEAD
  };

  private static final Map<String, Schema.RecordTypeInfo> rectypeInfos = SmartViscaf__NameCardRenkeiMapping__c.getSObjectType().getDescribe().getRecordTypeInfosByName();
  private static final Map<String, Schema.SObjectField> ncFields = SmartViscaf__NameCard__c.getSObjectType().getDescribe().fields.getMap();

  public class Kaisha {
    public String name { get; private set; }
    public String zip { get; private set; }
    public String pref { get; private set; }
    public String address { get; private set; }
    public String bld { get; private set; }
    public String phone { get; private set; }
    public String domain { get; private set; }
    //public List<Employee> emps { get; private set; }
    public Kaisha(String name, String zip, String pref, String address, String bld, String phone, String domain) {
      this.name = name;
      this.zip = zip;
      this.pref = pref;
      this.address = address;
      this.bld = bld;
      this.phone = phone;
      this.domain =domain;
      //this.emps = new List<Employee>();
    }
    //public void addEmp(Employee emp) {
    //  this.emps.add(emp);
    //}
  }

  // 名刺データを作るための 個人情報を持つクラス
  public class Employee {
    public Kaisha kaisha { get; private set; }
    public String name { get; private set; }
    public String sei { get; private set; }
    public String mei { get; private set; }
    public String mail { get; private set; }
    public Integer num { get; private set; }
    Employee(Kaisha kaisha, String sei, String mei, String mail, Integer num) {
      this.kaisha = kaisha;
      this.name = sei + ' ' + mei;
      this.sei = sei;
      this.mei = mei;
      this.mail = mail;
      this.num = num;
    }
  }

  public static final Integer CNT_USER = 5;          // ユーザ数（所有者数）
  public static final Integer CNT_COMPANY = 4;          // 会社数
  public static final Integer CNT_EMPLOYEE = 2;         // 名刺数／会社
  public static final Integer CNT_LEAD = 2;         // リード
  public static final Integer CNT_TAG = 5;          // タグ / 名刺 数

  public List<User> listUser { get; private set; }
  public List<SmartViscaf__NameCard__c> listCard { get; private set; }
  public List<Kaisha> listKaisha { get; private set; }
  public List<Employee> listEmp { get; private set; }
  public Map<String, Account> mapAccount { get; private set; }    // 取引先 は、名前からオブジェクトを取得出来るようにします。
  public List<Contact> listContact { get; private set; }
  public List<sObject> listLead { get; private set; }
  public SmartViscaf__SmartViscaConfig__c svConfig { get; set; }
  public List<Event> listEvent { get; private set; }      // 行動
  public List<Task> listTask { get; private set; }        // ToDo
  public List<SmartViscaf__NameCardRenkeiMapping__c> listMapping { get; private set; }   // 連携マッピング
  public List<SmartViscaf__NameCardBasicSetting__c> listBasicSetting { get; private set; }   // 名刺基本設定
  public List<Account> listAccount;
  public List<Campaign> listCampaign; // キャンペーン
  public List<CampaignMember> listCampaignMember; // キャンペーンメンバー
  public List<CampaignMemberStatus> listCampaignMemberStatus; // キャンペーンメンバーステータス


  public SB_NCL_TestDB() {
    listUser = new List<User>();
    listCard = new List<SmartViscaf__NameCard__c>();
    listKaisha = new List<Kaisha>();
    listEmp = new List<Employee>();
    mapAccount = new Map<String, Account>();
    listContact = new List<Contact>();
    listLead = new List<sObject>();
    listEvent = new List<Event>();
    listTask = new List<Task>();
    listMapping = new List<SmartViscaf__NameCardRenkeiMapping__c>();   // 連携マッピング
    listBasicSetting = new List<SmartViscaf__NameCardBasicSetting__c>();   // 名刺基本設定
    listAccount = new List<Account>();
    listCampaign = new List<Campaign>();    // キャンペーン
    listCampaignMember = new List<CampaignMember> (); // キャンペーンメンバー
    listCampaignMemberStatus = new List<CampaignMemberStatus>(); // キャンペーンメンバーステータス
  }

  private void createSObject(List<sObject> objs, String objName, Map<String, Object> values) {
    sObject obj = Schema.getGlobalDescribe().get(objName).newSObject();
    for (String key : values.keySet()) {
      obj.put(key, values.get(key));
    }
    objs.add(obj);
  }

  // 作成するユーザのプロファイル
  protected Profile profStd {
    get {
      if (profStd == null) {
        profStd = [SELECT Id FROM profile WHERE name='Standard User' or name='標準ユーザ' LIMIT 1];
      }
      return profStd;
    }
    set;
  }

  // ユーザレコードの作成
  public virtual User createUser(String firstname, String lastname) {
    return new User(
      Alias = String.format('{0}-{1}', new String[]{firstname,lastname}).subString(0, 7)
      , email= firstname+lastname+'@testorg.com'
      , emailencodingkey='UTF-8'
      , firstname = firstname
      , lastname = lastname
      , languagelocalekey='ja'
      , localesidkey='ja_JP'
      , profileid = profStd.Id
      , timezonesidkey='Asia/Tokyo'
      , username=firstname+lastname+'@testorg.com');
  }

  // ユーザの初期化
  public virtual void initializeUser() {
    for(Integer n=1; n<=CNT_USER; n++) {
      listUser.add(createUser(n.format(), 'Smart'));
    }
    System.assertEquals(CNT_USER, listUser.size());  // 2017.10.xx v1.21 for code scan  Test Methods With No Assert
  }

  // 取引先を既存にするために名刺にある取引先を事前に追加
  public virtual void initializeAccount() {
    List<SmartViscaf__NameCard__c> cards = Database.query('SELECT ' + NC_QUERY_SIMPLEFIELDS + ' FROM SmartViscaf__NameCard__c ORDER BY SmartViscaf__company_name__c, Id');
    for (SmartViscaf__NameCard__c card : cards) {
      Map<String, String> addrs = SmartViscaf.SB_NameCard_Util.getAddress(card);
      String city = addrs.get('city');
      String street = addrs.get('street');
      mapAccount.put(card.SmartViscaf__company_name__c,
          new Account(Name = card.SmartViscaf__company_name__c,
                      Site = card.SmartViscaf__division__c,
                      BillingState = card.SmartViscaf__address_pref__c,
                      BillingCity = city,
                      BillingStreet = street + card.SmartViscaf__address_bld__c,
                      BillingPostalCode = card.SmartViscaf__zip_code__c,
                      ShippingState = card.SmartViscaf__address_pref__c,
                      ShippingCity = city,
                      ShippingStreet = street + card.SmartViscaf__address_bld__c,
                      ShippingPostalCode = card.SmartViscaf__zip_code__c,
                      Phone = card.SmartViscaf__tel1__c,
                      Fax= card.SmartViscaf__fax1__c,
                      Website = card.SmartViscaf__web_url1__c));
    }
    System.assert(mapAccount.size() <= cards.size());  // 2017.10.xx v1.21 for code scan  Test Methods With No Assert
  }

  // 存在するユーザごとに所有者を変えて同一の取引先責任者を追加
  //  Name は 名 姓 になるので、注意!?
  public virtual void initializeContact() {
    for(Employee emp :listEmp) {
      Account acnt = mapAccount.get(emp.kaisha.name);
      listContact.add(new Contact(AccountId=acnt.Id
        , LastName=emp.sei
        , FirstName=emp.mei
        , Email=emp.mail
        ));
    }
    System.assertEquals(listEmp.size(), listContact.size());  // 2017.10.xx v1.21 for code scan  Test Methods With No Assert
  }

  // 名刺用に会社を作る
  public void initializeKaisha() {
    listKaisha.add(new Kaisha('サンブリッジ株式会社', '115-0022','東京都', '渋谷区恵比寿南1-5-5', 'JR恵比寿ビル', '03-0000-1111', 'sunbridge.com'));
    listKaisha.add(new Kaisha('テスト１株式会社', '111-0022','東京都', '品川区品川1-5-5', 'JR品川ビル', '03-1111-1111', 'test1.com'));
    listKaisha.add(new Kaisha('テスト２株式会社', '222-0022','東京都', '港区港1-5-5', 'JR港ビル', '03-2222-1111', 'test2.com'));
    listKaisha.add(new Kaisha('テスト３株式会社', '333-0022','東京都', '新宿区新宿1-5-5', 'JR新宿ビル', '03-3333-1111', 'test3.com'));
    listKaisha.add(new Kaisha('テスト４株式会社', '444-0022','東京都', '豊島区豊島1-5-5', 'JR豊島ビル', '03-4444-1111', 'test4.com'));
    listKaisha.add(new Kaisha('テスト５株式会社', '555-0022','東京都', '板橋区板橋1-5-5', 'JR板橋ビル', '03-5555-1111', 'test5.com'));
    listKaisha.add(new Kaisha('テスト６株式会社', '666-0022','東京都', '荒川区荒川1-5-5', 'JR荒川ビル', '03-6666-1111', 'test6.com'));
    listKaisha.add(new Kaisha('テスト７株式会社', '777-0022','東京都', '墨田区墨田1-5-5', 'JR墨田ビル', '03-7777-1111', 'test7.com'));
    listKaisha.add(new Kaisha('テスト８株式会社', '888-0022','東京都', '世田谷区世田谷1-5-5', 'JR世田谷ビル', '03-8888-1111', 'test8.com'));
    listKaisha.add(new Kaisha('テスト９株式会社', '999-0022','千葉県', '千葉市千葉区1-5-5', 'JR千葉ビル', '044-1111-1111', 'test9.com'));
    //listKaisha.add(new Kaisha('テスト１０株式会社', '000-0022','神奈川県', '横浜市中区横浜1-5-5', 'JR横浜ビル', '045-1111-1111', 'test10.com'));
    System.assertEquals(10, listKaisha.size());  // 2017.10.xx v1.21 for code scan  Test Methods With No Assert
  }

  // 名刺用の会社に個人をつける
  public void initializeEmployee() {
    for (Kaisha kaisha : listKaisha) {
      for (Integer e = 1; e <= CNT_EMPLOYEE; e++) {
        listEmp.add(new Employee(
          kaisha                  // 会社名
          , '苗字' + e.format()    // 姓
          , '名' + e.format()      // 名
          , 'emp'+e.format()+'@'+kaisha.domain // メアド
          , e));            // 番号
      }
    }
    System.assertEquals(listKaisha.size() * CNT_EMPLOYEE, listEmp.size());  // 2017.10.xx v1.21 for code scan  Test Methods With No Assert
  }

  // 名刺データ作成
  //  存在するユーザごとに所有者を変えて同一の名刺を追加
  public virtual void initializeNameCard() {
    for (Employee emp :listEmp) {
      // 所有者の異なる名刺を作成
      for (User u : listUser) {
        listCard.add(
          new SmartViscaf__NameCard__c(
            name= emp.name
            , SmartViscaf__person_name_last__c= emp.sei
            , SmartViscaf__person_name_first__c= emp.mei
            , SmartViscaf__last_name__c= emp.sei.replace('苗字', 'Myoji')
            , SmartViscaf__first_name__c= emp.mei.replace('名', 'Na')
            , SmartViscaf__email__c= emp.mail
            , SmartViscaf__company_name__c= emp.kaisha.name
            , SmartViscaf__division__c = '本社'
            , SmartViscaf__title_name__c = '役職'+emp.num.format()
            , SmartViscaf__tel1__c= emp.kaisha.phone
            , SmartViscaf__tel2__c= emp.kaisha.phone
            , SmartViscaf__fax1__c= '0344444444'
            , SmartViscaf__mobile__c = '09099999999'
            , SmartViscaf__web_url1__c = 'http://www.'+emp.kaisha.domain
            , SmartViscaf__web_url2__c = 'http://www.'+emp.kaisha.domain
            , SmartViscaf__zip_code__c = emp.kaisha.zip
            , SmartViscaf__address_pref__c = emp.kaisha.pref
            , SmartViscaf__address__c = emp.kaisha.address
            , SmartViscaf__address_bld__c = emp.kaisha.bld
            //                    , SmartViscaf__list_name__c ='名刺'
            , SmartViscaf__memo__c = 'メモ : ' + emp.kaisha.name +' '+ emp.num.format()
            , SmartViscaf__freehandmemo__c = '自由記述 : ' + emp.kaisha.name +' '+ emp.num.format()
            , SmartViscaf__delivery_type__c='1'
            , OwnerId = u.Id
        ));
      }
    }
    System.assertEquals(listEmp.size() * listUser.size(), listCard.size());  // 2017.10.xx v1.21 for code scan  Test Methods With No Assert
  }

  // SmartVisca設定　トリガを有効にする。
  // 2016.05.xx S1取引先登録対応 設定の初期値
  public virtual void initializeSmartViscaConfig() {
    svConfig = SmartViscaf__SmartViscaConfig__c.getOrgDefaults();
    //svConfig.SmartViscaf__TriggerRegDateTime__c = true;
    //svConfig.SmartViscaf__TriggerCreateFeedOnName__c = false;
    //svConfig.SmartViscaf__TriggerMergeNameCards__c = false;
    //svConfig.SmartViscaf__TriggerHistoryIsActive__c = false;
    //svConfig.SmartViscaf__SSmartViscaServerOptions__c = 'Opt1:AAA\r\nOpt2:BBB';
    //// +--- 2016.05.xx S1取引先登録対応
    //svConfig.SmartViscaf__SRegistAccountFields1__c = 'SmartViscaf__company_name__c:Name,SmartViscaf__division__c:Site,SmartViscaf__zip_code__c:BillingPostalCode,SmartViscaf__address_pref__c:BillingState,city:BillingCity,street:BillingStreet,SmartViscaf__tel1__c:Phone,SmartViscaf__fax1__c:Fax,SmartViscaf__web_url1__c:Website';  // 2016.05.xx S1取引先登録対応
    //svConfig.SmartViscaf__SRegistAccountFields2__c = 'Id:SmartViscaf__NameCard__c';     // 2016.05.xx S1取引先登録対応
    //svConfig.SmartViscaf__SRegistAccountFields3__c = 'SmartViscaf__list_name__c:SmartViscaf__NameCardListName__c,SmartViscaf__memo__c:SmartViscaf__NameCardMemo__c,SmartViscaf__freehandmemo__c:SmartViscaf__NameCardFreehandmemo__c';     // 2016.05.xx S1取引先登録対応
    //svConfig.SmartViscaf__SRegistContactFields1__c = 'last_name:LastName,first_name:FirstName,SmartViscaf__zip_code__c:MailingPostalCode,SmartViscaf__address_pref__c:MailingState,city:MailingCity,street:MailingStreet';      // 2016.05.xx S1取引先登録対応
    //svConfig.SmartViscaf__SRegistContactFields2__c = 'SmartViscaf__tel1__c:Phone,SmartViscaf__fax1__c:Fax,SmartViscaf__mobile__c:MobilePhone,SmartViscaf__email__c:Email,SmartViscaf__title_name__c:Title,SmartViscaf__division__c:Department';      // 2016.05.xx S1取引先登録対応
    //svConfig.SmartViscaf__SRegistContactFields3__c = 'Id:SmartViscaf__NameCard__c,SmartViscaf__list_name__c:SmartViscaf__NameCardListName__c,SmartViscaf__memo__c:SmartViscaf__NameCardMemo__c,SmartViscaf__freehandmemo__c:SmartViscaf__NameCardFreehandmemo__c';      // 2016.05.xx S1取引先登録対応
    // svConfig.SmartViscaf__SRegistQueryAccountFields1__c = Label.SB_NC_RegistQueryAccountFields;    // 2016.05.xx S1取引先登録対応
    // svConfig.SmartViscaf__SRegistQueryAccountFields2__c = Label.SB_NC_RegistQueryAccountFields;    // 2016.05.xx S1取引先登録対応
    // svConfig.SmartViscaf__SRegistQueryContactFields1__c = Label.SB_NC_RegistQueryContactFields;    // 2016.05.xx S1取引先登録対応
    // svConfig.SmartViscaf__SRegistQueryContactFields2__c = Label.SB_NC_RegistQueryContactFields;    // 2016.05.xx S1取引先登録対応
    // +--- 2016.05.xx S1取引先登録対応
    // 自動連携のトリガハンドラを呼ぶ
    svConfig.SmartViscaf__TriggerRenkeiTriggerHandler__c = false;
    // Lead連携拡張パッケージの中にある 自動連携のトリガハンドラを呼ぶ
    svConfig.SmartViscaf__TriggerLeadExRenkeiTriggerHandler__c = true;
    // Lead 拡張パッケージ v2.0 からの項目
    // 統合版自動連携:リードなく、取引先既存で取引先責任者を作成する
    svConfig.RenkeiCreateContactOnAcountWithoutLead__c = false; // デフォルト false
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

  // 名刺の人達を事前にリードにしときます。
  public virtual void initalizeLead() {
    Map<String, Object> values = new Map<String, Object>();
    for (Employee emp :listEmp) {
      values.put('LastName', emp.sei);
      values.put('firstName', emp.mei);
      values.put('Company', emp.kaisha.name);
      createSObject(listLead, 'Lead', values);
      values.clear();
    }
  }

  // 名刺にToDoをつける
  public virtual void initializeTask() {
    for (SmartViscaf__NameCard__c card : listCard) {
      listTask.add(new Task(Subject=card.Name + 'task', OwnerId=card.OwnerId, whatId=card.Id));
    }
    System.assertEquals(listCard.size(), listTask.size());  // 2017.10.xx v1.21 for code scan  Test Methods With No Assert
  }

  // 名刺に行動をつける
  public virtual void initializeEvent() {
    for (SmartViscaf__NameCard__c card : listCard) {
      listEvent.add(new Event(Subject=card.Name + 'event', OwnerId=card.OwnerId
        , IsAllDayEvent=true, ActivityDate=date.today(), whatId=card.Id));
    }
    System.assertEquals(listCard.size(), listEvent.size());  // 2017.10.xx v1.21 for code scan  Test Methods With No Assert
  }


  private Boolean isLeadExtensionField(String f) {
    return  !f.startsWithIgnoreCase('SmartViscaf__') && f.endsWithIgnoreCase('__c');
  }

  // 名刺連携項目マッピング レコードの作成
  private void addMappings(String objName, Id settingsId) {
    String ns = SB_NameCardL_Util.getNamespacePrefix_x();
    Id rectypeId = rectypeInfos.get(objName).getRecordTypeId();
    Map<String, Set<String>> sv2Targets = otype2DefaultMapping.get(objName);
    System.assertNotEquals(null, sv2Targets);
    for (String src : sv2Targets.keySet()) {
      for (String dest : sv2Targets.get(src)) {
        String target = isLeadExtensionField(dest) ? ns + dest : dest;
        String nc = isLeadExtensionField(src) ? ns + src : src;
        if (dest == 'dummy') {
          continue;
        }
        if (ncFields.get(nc) == null) {      // 名前空間があるときとないときと　
          nc = src;
        }
        listMapping.add(new Smartviscaf__NameCardRenkeiMapping__c(Smartviscaf__NameCardName__c=nc, Smartviscaf__TargetName__c=target, RecordTypeId=rectypeId, Smartviscaf__BasicSetting__c=settingsId, Smartviscaf__IsActive__c=true));
      }
    }
  }


  // 名刺連携項目マッピング レコードの作成
  public virtual void initializeMapping() {
    List<Smartviscaf__NameCardBasicSetting__c> settings = [SELECT Id, Name FROM Smartviscaf__NameCardBasicSetting__c ORDER BY CreatedDate ASC LIMIT 100];
    Id settingsId = null;
    if (!settings.isEmpty()) {
      settingsId  = settings[0].Id;
    }

    addMappings('Account', settingsId);
    addMappings('Contact', settingsId);
    addMappings('Lead', settingsId);
  }

  // 名刺基本設定
  public virtual void initializeBasicSetting() {
    SmartViscaf__NameCardBasicSetting__c bs = SmartViscaf.SB_NC_PostInstallScript.createDefaultBasicSetting();
    //bs.SmartViscaf__RenkeiAccountOverwrite__c = true;  // 既存の取引先を上書き
    //bs.SmartViscaf__RenkeiContactOverwrite__c = true;   // 既存の取引先責任者を上書き
    //SmartViscaf__NameCardBasicSetting__c bs = new SmartViscaf__NameCardBasicSetting__c(
    //  SmartViscaf__RenkeiActive__c = false,      // 自動連携機能有効
    //  SmartViscaf__RenkeiAccountAddressPref__c = false,   // アカウント 都道府県
    //  SmartViscaf__RenkeiAccount_Street__c = false,   // アカウント 町名・番地
    //  SmartViscaf__RenkeiAccountZipCode__c = false,   // アカウント 郵便番号
    //  SmartViscaf__RenkeiAccountCity__c = false,      // アカウント 市区郡
    //  SmartViscaf__RenkeiAccountURL__c = false,       // アカウント URL
    //  SmartViscaf__RenkeiAccountCompany__c = true,   // アカウント 会社名
    //  SmartViscaf__RenkeiAccountPhone__c = false,     // アカウント 電話番号
    //  SmartViscaf__RenkeiSpecificItems__c = null,        // アカウント 特定項目
    //  SmartViscaf__RenkeiAccountSite__c = false,        // アカウント 部署名
    //  SmartViscaf__RenkeiExcludeHojinkakuPartial__c = true,      // 自動連携:会社名は法人格を除いて部分一致
    //  SmartViscaf__RenkeiExcludeHojinkaku__c = false,      // 自動連携:会社名は法人格を除いて完全一致
    //  SmartViscaf__RenkeiAccountSitePartialMatch__c = true,      // 自動連携:部署は中間一致検索
    //  SmartViscaf__RenkeiContactMail__c = true,      // コンタクト メールアドレス
    //  SmartViscaf__RenkeiContactLastName__c = true,  // コンタクト ラストネーム
    //  SmartViscaf__RenkeiContactFirstName__c = false, // コンタクト ファーストネーム
    //  SmartViscaf__RenkeiAccountQueryRecordTypeIds__c = null,    // 検索対象のレコードタイプタイプID カンマ区切り で羅列
    //  SmartViscaf__RenkeiContactQueryRecordTypeIds__c = null,  // 自動連携で検索対象の取引先責任者レコードタイプ
    //  SmartViscaf__RenkeiAccountOverwrite__c = true,   // 既存の取引先を上書き FALSE
    //  SmartViscaf__RenkeiContactOverwrite__c = true,   // 既存の取引先責任者を上書き FALSE
    //  SmartViscaf__RenkeiAccountNOExistCreateNew__c = true,  //既存の取引先がなければ新規作成する
    //  SmartViscaf__RenkeiContactNOExistCreateNew__c = true,  // 既存の取引先責任者がなければ新規作成する
    //  SmartViscaf__RenkeiAccountRecordTypes__c = null,     // 作成するアカウント の レコードタイプID １つ
    //  SmartViscaf__RenkeiContactRecordTypes__c = null,      // 作成するコンタクト の レコードタイプID １つ
    //  // パッケージ v1.20 Version 2
    //  SmartViscaf__SaishinInheritValues__c = false,          //最新名刺は値を引継ぐ
    //  SmartViscaf__RegistToDoSubject__c = Label.SB_NC_ExchangeCard, // 取引先・取引先任者に登録 ToDo件名
    //  SmartViscaf__RegistNoToDo__c =  false, // 取引先・取引先任者に登録 ToDo登録しない
    //  SmartViscaf__RegistDispOverWriteCheckbox__c = true, // 取引先・取引先任者に登録 「上書きする」チェックボックスを表示する  → V3　から
    //  SmartViscaf__RegistDispAccountRectype__c = true, // 取引先・取引先任者に登録 取引先レコードタイプ選択を表示する
    //  SmartViscaf__RegistAccountNotOverWrite__c = false, // 取引先・取引先任者に登録 取引先を名刺情報で上書きしない
    //  SmartViscaf__RegistDispContactRectype__c = true, // 取引先・取引先任者に登録 取引先責任者レコードタイプ選択を表示する
    //  SmartViscaf__RegistContactNotOverWrite__c = false, // 取引先・取引先任者に登録 取引先責任者を名刺情報で上書きしない
    //  // パッケージ v1.21 Version 3
    //  SmartViscaf__RegistDispLeadOverWriteCheckbox__c = true,          //「既存のリードを名刺情報で上書きする」を表示する
    //  SmartViscaf__RegistDispAccountOverWriteCheckbox__c = true,          //「既存の取引先を名刺情報で上書きする」を表示する
    //  SmartViscaf__RegistDispContactOverWriteCheckbox__c = true          //「既存の取引先責任者を名刺情報で上書きする」を表示する
    //);
    ////bs.put('SmartViscaf__RenkeiHavePlural__c', '新規作成');
    ////bs.put('SmartViscaf__RenkeiNOExistingAccount__c', '新規作成');
    listBasicSetting.add(bs);
  }

  // リード
  public virtual void initializeLead() { }

  //　キャンペーン
  public virtual void initializeCampaign() {
    listCampaign.add(new Campaign(Name='キャンペーン01', IsActive=true, Status='進行中'));
    listCampaign.add(new Campaign(Name='キャンペーン02', IsActive=true, Status='進行中'));
    listCampaign.add(new Campaign(Name='無効キャンペーン', IsActive=false, Status='完了'));
  }

  // // コードスキャンで FLS Update、FLS Create がでるので、
  // protected Boolean canUpsert(SObjectType otype) {
  //   return otype.getDescribe().isCreateable() && otype.getDescribe().isUpdateable();
  // }

  // // コードスキャンで FLS Update、FLS Create がでるので、
  // protected Boolean canInsert(SObjectType otype) {
  //   return otype.getDescribe().isCreateable();
  // }

  public virtual void initialize() {

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
    //　ユーザ
    initializeUser();
    if (!listUser.isEmpty()) {
      SmartViscaf.SB_NameCard_CrudFls.screate(listUser, true);
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
    // 名刺レコード作成
    initializeKaisha();     // 会社を揃えておく
    initializeEmployee();   // 会社ごとに名刺の人を揃えておく
    initializeNameCard();
    if (!listCard.isEmpty()) {
      SmartViscaf.SB_NameCard_CrudFls.screate(listCard, true);
    }
    // 名刺にToDoをつける
    initializeTask();
    if (!listTask.isEmpty()) {
      SmartViscaf.SB_NameCard_CrudFls.screate(listTask, true);
    }
    // 名刺に行動をつける
    initializeEvent();
    if (!listEvent.isEmpty()) {
      SmartViscaf.SB_NameCard_CrudFls.screate(listEvent, true);
    }
    // アカウント
    initializeAccount();    // 揃えた会社について、取引先を作る。
    if (!mapAccount.isEmpty()) {
      SmartViscaf.SB_NameCard_CrudFls.screate(mapAccount.values(), true);
    }
    // コンタクト
    initializeContact();    // 揃えた会社ごとに名刺の人で、取引先責任者を作る。
    if (!listContact.isEmpty()) {
      SmartViscaf.SB_NameCard_CrudFls.screate(listContact, true);
    }
    // リード
    initalizeLead();        // 揃えた会社ごとに名刺の人で、リードを作る。
    if (!listLead.isEmpty()) {
      SmartViscaf.SB_NameCard_CrudFls.screate(listLead, true);
    }
    // キャンペーン
    initializeCampaign();
    if (!listCampaign.isEmpty()) {
      SmartViscaf.SB_NameCard_CrudFls.screate(listCampaign, true);
    }

  }   // initialize()

}