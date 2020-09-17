/**
 *
 * SB_NC_TestDB
 *
 * 新 テストクラス用のデータを作る基底クラス
 *
 *
 * Copyright (C) 2014 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2014.5.xx
 *  @Version ...
 *  @Version 2.4    2019.7.xx  作成するUserレコードに 部署を追加
 **/
public virtual class SB_NC_TestDB {

  public static final String NC_QUERY_SIMPLEFIELDS = 'Id, Name'  +
              ', company_name__c, company_name_kana__c, division__c, title_name__c' +
              ', zip_code__c, address_pref__c, address__c, address_bld__c, address_eng__c' +
              ', last_name__c, first_name__c, person_name_last__c, person_name_first__c, email__c' +
              ', tel1__c, fax1__c, web_url1__c' +
              ', account__c, contact__c';

  // 項目マッピング用のデータ
  //　アカウント用
  public static final Map<String, Set<String>> SV_TO_ACCOUNT = new Map<String, Set<String>> {
    'company_name__c' => new Set<String>{'Name'}
    , 'division__c' => new Set<String>{'Site'}
    , 'web_url1__c' => new Set<String>{'Website'}
    , 'zip_code__c' => new Set<String>{'BillingPostalCode', 'ShippingPostalCode'}
    , 'address_pref__c' => new Set<String>{'BillingState', 'ShippingState'}
    , 'city' => new Set<String>{'BillingCity', 'ShippingCity'}
    , 'street' => new Set<String>{'BillingStreet', 'ShippingStreet'}
    , 'street_nobld' => new Set<String>{'dummy'}    // 重複してるが、テストでだけ、
    , 'pref_address_bld' => new Set<String>{'dummy'}    // 重複してるが、テストでだけ、
    , 'address_bld' => new Set<String>{'dummy'}    // 重複してるが、テストでだけ、
    , 'tel1__c' => new Set<String>{'Phone'}
    , 'fax1__c' => new Set<String>{'Fax'}
    , 'Id' => new Set<String>{'NameCard__c'}
    , 'list_name__c' => new Set<String>{'NameCardListName__c'}
    , 'memo__c' => new Set<String>{'NameCardMemo__c'}
    , 'freehandmemo__c' => new Set<String>{'NameCardFreehandmemo__c'}
    , 'OwnerId' => new Set<String>{'OwnerId'}
  };

  // コンタクト用
  public static final Map<String, Set<String>> SV_TO_CONTACT = new Map<String, Set<String>> {
    'last_name' => new Set<String>{'LastName'}
    , 'first_name' => new Set<String>{'FirstName'}
    , 'person_name_last_kana__c' => new Set<String>{'dummy'}     // 重複してるが、テストでだけ、
    , 'person_name_first_kana__c' => new Set<String>{'dummy'}   // 重複してるが、テストでだけ、
    , 'zip_code__c' => new Set<String>{'MailingPostalCode'}
    , 'address_pref__c' => new Set<String>{'MailingState'}
    , 'city' => new Set<String>{'MailingCity'}
    , 'street' => new Set<String>{'MailingStreet'}
    , 'tel1__c' => new Set<String>{'Phone'}
    , 'fax1__c' => new Set<String>{'Fax'}
    , 'mobile__c' => new Set<String>{'MobilePhone'}
    , 'email__c' => new Set<String>{'Email'}
    , 'division__c' => new Set<String>{'Department'}
    , 'title_name__c' => new Set<String>{'Title'}
    , 'Id' => new Set<String>{'NameCard__c'}
    , 'list_name__c' => new Set<String>{'NameCardListName__c'}
    , 'memo__c' => new Set<String>{'NameCardMemo__c'}                // 重複してるが、テストでだけ、
    , 'freehandmemo__c' => new Set<String>{'NameCardFreehandmemo__c'}
    , 'OwnerId' => new Set<String>{'OwnerId'}
  };

  // リード用
  public static final Map<String, Set<String>> SV_TO_LEAD = new Map<String, Set<String>> {
    'last_name' => new Set<String>{'LastName'}
    , 'first_name' => new Set<String>{'FirstName'}
    , 'company_name__c' => new Set<String>{'Company'}
    , 'web_url1__c' => new Set<String>{'Website'}
    , 'zip_code__c' => new Set<String>{'PostalCode'}
    , 'address_pref__c' => new Set<String>{'State'}
    , 'city' => new Set<String>{'City'}
    , 'street' => new Set<String>{'Street'}
    , 'tel1__c' => new Set<String>{'Phone'}
    , 'fax1__c' => new Set<String>{'Fax'}
    , 'mobile__c' => new Set<String>{'MobilePhone'}
    , 'email__c' => new Set<String>{'Email'}
    , 'title_name__c' => new Set<String>{'Title'}
    , 'Id' => new Set<String>{'NameCard__c'}
    , 'list_name__c' => new Set<String>{'NameCardListName__c'}
    , 'memo__c' => new Set<String>{'NameCardMemo__c'}                // 重複してるが、テストでだけ、
    , 'freehandmemo__c' => new Set<String>{'NameCardFreehandmemo__c'}
    , 'OwnerId' => new Set<String>{'OwnerId'}
  };

  private static final Map<String, Map<String, Set<String>>> otype2DefaultMapping = new Map<String, Map<String, Set<String>>> {
    'Account' => SV_TO_ACCOUNT,
    'Contact' => SV_TO_CONTACT,
    'Lead' => SV_TO_LEAD
  };
  public static Map<String, Schema.RecordTypeInfo> rectypeInfos = NameCardRenkeiMapping__c.getSObjectType().getDescribe().getRecordTypeInfosByName();

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
  public List<NameCard__c> listCard { get; private set; }
  public List<Kaisha> listKaisha { get; private set; }
  public List<Employee> listEmp { get; private set; }
  public Map<String, Account> mapAccount { get; private set; }    // 取引先 は、名前からオブジェクトを取得出来るようにします。
  public List<Contact> listContact { get; private set; }
  public List<sObject> listLead { get; private set; }
  public SmartViscaConfig__c svConfig { get; set; }
  public List<Event> listEvent { get; private set; }      // 行動
  public List<Task> listTask { get; private set; }        // ToDo
  public List<NameCardRenkeiMapping__c> listMapping { get; private set; }   // 連携マッピング
  public List<NameCardBasicSetting__c> listBasicSetting { get; private set; }   // 名刺基本設定

  public SB_NC_TestDB() {
    listUser = new List<User>();
    listCard = new List<NameCard__c>();
    listKaisha = new List<Kaisha>();
    listEmp = new List<Employee>();
    mapAccount = new Map<String, Account>();
    listContact = new List<Contact>();
    listLead = new List<sObject>();
    listEvent = new List<Event>();
    listTask = new List<Task>();
    listMapping = new List<NameCardRenkeiMapping__c>();   // 連携マッピング
    listBasicSetting = new List<NameCardBasicSetting__c>();   // 名刺基本設定
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
      alias = String.format('{0}-{1}', new String[]{firstname,lastname}).subString(0, 7)
      , email= firstname+lastname+'@testorg.com'
      , emailencodingkey='UTF-8'
      , firstname = firstname
      , lastname = lastname
      , languagelocalekey='ja'
      , localesidkey='ja_JP'
      , profileid = profStd.Id
      , timezonesidkey='Asia/Tokyo'
      , username=firstname+lastname+'@testorg.com'
      , Department= firstname + '事業部');
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
    List<NameCard__c> cards = Database.query('SELECT ' + NC_QUERY_SIMPLEFIELDS + ' FROM NameCard__c ORDER BY company_name__c, Id');
    for (NameCard__c card : cards) {
      Map<String, String> addrs = SB_NameCard_Util.getAddress(card);
      String city = addrs.get('city');
      String street = addrs.get('street');
      mapAccount.put(card.company_name__c,
          new Account(Name = card.company_name__c,
                      Site = card.division__c,
                      BillingState = card.address_pref__c,
                      BillingCity = city,
                      BillingStreet = street + card.address_bld__c,
                      BillingPostalCode = card.zip_code__c,
                      ShippingState = card.address_pref__c,
                      ShippingCity = city,
                      ShippingStreet = street + card.address_bld__c,
                      ShippingPostalCode = card.zip_code__c,
                      Phone = card.tel1__c,
                      Fax= card.fax1__c,
                      Website = card.web_url1__c));
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
          new NameCard__c(
            name= emp.name
            , person_name_last__c= emp.sei
            , person_name_first__c= emp.mei
            , last_name__c= emp.sei.replace('苗字', 'Myoji')
            , first_name__c= emp.mei.replace('名', 'Na')
            , email__c= emp.mail
            , company_name__c= emp.kaisha.name
            , division__c = '本社'
            , title_name__c = '役職'+emp.num.format()
            , tel1__c= emp.kaisha.phone
            , tel2__c= emp.kaisha.phone
            , fax1__c= '0344444444'
            , mobile__c = '09099999999'
            , web_url1__c = 'http://www.'+emp.kaisha.domain
            , web_url2__c = 'http://www.'+emp.kaisha.domain
            , zip_code__c = emp.kaisha.zip
            , address_pref__c = emp.kaisha.pref
            , address__c = emp.kaisha.address
            , address_bld__c = emp.kaisha.bld
            //                    , list_name__c ='名刺'
            , memo__c = 'メモ : ' + emp.kaisha.name +' '+ emp.num.format()
            , freehandmemo__c = '自由記述 : ' + emp.kaisha.name +' '+ emp.num.format()
            , delivery_type__c='1'
            , OwnerId = u.Id
        ));
      }
    }
    System.assertEquals(listEmp.size() * listUser.size(), listCard.size());  // 2017.10.xx v1.21 for code scan  Test Methods With No Assert
  }

  // SmartVisca設定　トリガを有効にする。
  // 2016.05.xx S1取引先登録対応 設定の初期値
  public virtual void initializeSmartViscaConfig() {
    svConfig = SmartViscaConfig__c.getOrgDefaults();
    svConfig.TriggerRegDateTime__c = true;
    svConfig.TriggerCreateFeedOnName__c = false;
    svConfig.TriggerMergeNameCards__c = false;
    svConfig.TriggerHistoryIsActive__c = false;
    svConfig.SSmartViscaServerOptions__c = 'Opt1:AAA\r\nOpt2:BBB';
    // +--- 2016.05.xx S1取引先登録対応
    svConfig.SRegistAccountFields1__c = 'company_name__c:Name,division__c:Site,zip_code__c:BillingPostalCode,address_pref__c:BillingState,city:BillingCity,street:BillingStreet,tel1__c:Phone,fax1__c:Fax,web_url1__c:Website';  // 2016.05.xx S1取引先登録対応
    svConfig.SRegistAccountFields2__c = 'Id:NameCard__c';     // 2016.05.xx S1取引先登録対応
    svConfig.SRegistAccountFields3__c = 'list_name__c:NameCardListName__c,memo__c:NameCardMemo__c,freehandmemo__c:NameCardFreehandmemo__c';     // 2016.05.xx S1取引先登録対応
    svConfig.SRegistContactFields1__c = 'last_name:LastName,first_name:FirstName,zip_code__c:MailingPostalCode,address_pref__c:MailingState,city:MailingCity,street:MailingStreet';      // 2016.05.xx S1取引先登録対応
    svConfig.SRegistContactFields2__c = 'tel1__c:Phone,fax1__c:Fax,mobile__c:MobilePhone,email__c:Email,title_name__c:Title,division__c:Department';      // 2016.05.xx S1取引先登録対応
    svConfig.SRegistContactFields3__c = 'Id:NameCard__c,list_name__c:NameCardListName__c,memo__c:NameCardMemo__c,freehandmemo__c:NameCardFreehandmemo__c';      // 2016.05.xx S1取引先登録対応
    svConfig.SRegistQueryAccountFields1__c = Label.SB_NC_RegistQueryAccountFields;    // 2016.05.xx S1取引先登録対応
    svConfig.SRegistQueryAccountFields2__c = Label.SB_NC_RegistQueryAccountFields;    // 2016.05.xx S1取引先登録対応
    svConfig.SRegistQueryContactFields1__c = Label.SB_NC_RegistQueryContactFields;    // 2016.05.xx S1取引先登録対応
    svConfig.SRegistQueryContactFields2__c = Label.SB_NC_RegistQueryContactFields;    // 2016.05.xx S1取引先登録対応
    // +--- 2016.05.xx S1取引先登録対応
    svConfig.AccountRegistSearchMethod__c = 1; // v2.4 取引先・取引先任者に登録(個別) 登録先候補の検索方法 SOSL
    svConfig.AccountBulkRegistSearchMethod__c = 1; // v2.4 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOSL　に
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
    for (NameCard__c card : listCard) {
      listTask.add(new Task(Subject=card.Name + 'task', OwnerId=card.OwnerId, whatId=card.Id));
    }
    System.assertEquals(listCard.size(), listTask.size());  // 2017.10.xx v1.21 for code scan  Test Methods With No Assert
  }

  // 名刺に行動をつける
  public virtual void initializeEvent() {
    for (NameCard__c card : listCard) {
      listEvent.add(new Event(Subject=card.Name + 'event', OwnerId=card.OwnerId
        , IsAllDayEvent=true, ActivityDate=date.today(), whatId=card.Id));
    }
    System.assertEquals(listCard.size(), listEvent.size());  // 2017.10.xx v1.21 for code scan  Test Methods With No Assert
  }


  //// 名刺連携項目マッピング レコードの作成
  //private void addMappings(String objName, Id settingsId) {
  //  String ns = SB_NameCard_Util.getNamespacePrefix_x();
  //  Map<String, Schema.SObjectField> ncFields = NameCard__c.getSObjectType().getDescribe().fields.getMap();
  //  Id rectypeId = rectypeInfos.get(objName).getRecordTypeId();
  //  Map<String, Set<String>> sv2Targets = otype2DefaultMapping.get(objName);
  //  System.assertNotEquals(null, sv2Targets);
  //  for (String src : sv2Targets.keySet()) {
  //    for (String dest : sv2Targets.get(src)) {
  //      //String target = isLeadExtensionField(dest) ? ns + dest : dest;
  //      //String nc = isLeadExtensionField(src) ? ns + src : src;
  //      String target = dest.endsWithIgnoreCase('__c') ? ns + dest : dest;
  //      String nc = src.endsWithIgnoreCase('__c') ? ns + src : src;
  //      if (dest == 'dummy') {
  //        continue;
  //      }
  //      if (ncFields.get(nc) == null) {      // 名前空間があるときとないときと　
  //        nc = src;
  //      }
  //      listMapping.add(new NameCardRenkeiMapping__c(NameCardName__c=nc, TargetName__c=target, RecordTypeId=rectypeId, BasicSetting__c=settingsId, IsActive__c=true));
  //    }
  //  }
  //}

  //// 名刺連携項目マッピング レコードの作成
  //public virtual void initializeMapping() {
  //  List<NameCardBasicSetting__c> settings = [SELECT Id, Name FROM NameCardBasicSetting__c ORDER BY CreatedDate ASC];
  //  Id settingsId = null;
  //  if (!settings.isEmpty()) {
  //    settingsId  = settings[0].Id;
  //  }

  //  addMappings('Account', settingsId);
  //  addMappings('Contact', settingsId);
  //  addMappings('Lead', settingsId);
  //}

  // 名刺連携項目マッピング レコードの作成
  public virtual void initializeMapping() {
    List<NameCardBasicSetting__c> settings = [SELECT Id, Name FROM NameCardBasicSetting__c ORDER BY CreatedDate ASC];
    Id settingsId = null;
    if (!settings.isEmpty()) {
      settingsId  = settings[0].Id;
    }
    String ns = SB_NameCard_Util.getNamespacePrefix_x();
    Map<String, Schema.SObjectField> ncFields = NameCard__c.getSObjectType().getDescribe().fields.getMap();
    Map<String, Schema.SObjectField> fields;
    Id rectypeId;
    // Account 用
    //fields = Account.getSObjectType().getDescribe().fields.getMap();
    rectypeId = rectypeInfos.get('Account').getRecordTypeId();
    for (String src : SV_TO_ACCOUNT.keySet()) {
      for (String dest : SV_TO_ACCOUNT.get(src)) {
        String target = dest.endsWithIgnoreCase('__c') ? ns + dest : dest;
        String nc = src.endsWithIgnoreCase('__c') ? ns + src : src;
        if (dest == 'dummy') {
          continue;
        }
        if (ncFields.get(nc) == null) {      // 名前空間があるときとないときと　
          nc = src;
        }
        //else {
        //  nc = src.endsWithIgnoreCase('__c') ? ns + src : src;
        //}
        listMapping.add(new NameCardRenkeiMapping__c(NameCardName__c=nc, TargetName__c=target, RecordTypeId=rectypeId, BasicSetting__c=settingsId, IsActive__c=true));
      }
    }
    // Contact 用
    //fields = Contact.getSObjectType().getDescribe().fields.getMap();
    rectypeId = rectypeInfos.get('Contact').getRecordTypeId();
    for (String src : SV_TO_CONTACT.keySet()) {
      for (String dest : SV_TO_CONTACT.get(src)) {
        String target = dest.endsWithIgnoreCase('__c') ? ns + dest : dest;
        String nc = src.endsWithIgnoreCase('__c') ? ns + src : src;
        if (dest == 'dummy') {
          continue;
        }
        if (ncFields.get(nc) == null) {      // 名前空間があるときとないときと　
          nc = src;
        }
        //else {
        //  nc = src.endsWithIgnoreCase('__c') ? ns + src : src;
        //}
        listMapping.add(new NameCardRenkeiMapping__c(NameCardName__c=nc, TargetName__c=target, RecordTypeId=rectypeId, BasicSetting__c=settingsId, IsActive__c=true));
      }
    }
    System.assert(listMapping.size() <= (SV_TO_ACCOUNT.size() + SV_TO_CONTACT.size()));  // 2017.10.xx v1.21 for code scan  Test Methods With No Assert
  }

  // 名刺基本設定
  public virtual void initializeBasicSetting() {
    NameCardBasicSetting__c bs = SB_NC_PostInstallScript.createDefaultBasicSetting();
    //bs.RenkeiAccountOverwrite__c = true;  // 既存の取引先を上書き
    //bs.RenkeiContactOverwrite__c = true;   // 既存の取引先責任者を上書き
    //NameCardBasicSetting__c bs = new NameCardBasicSetting__c(
    //  RenkeiActive__c = false,      // 自動連携機能有効
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
    //  RenkeiAccountOverwrite__c = true,   // 既存の取引先を上書き FALSE
    //  RenkeiContactOverwrite__c = true,   // 既存の取引先責任者を上書き FALSE
    //  RenkeiAccountNOExistCreateNew__c = true,  //既存の取引先がなければ新規作成する
    //  RenkeiContactNOExistCreateNew__c = true,  // 既存の取引先責任者がなければ新規作成する
    //  RenkeiAccountRecordTypes__c = null,     // 作成するアカウント の レコードタイプID １つ
    //  RenkeiContactRecordTypes__c = null,      // 作成するコンタクト の レコードタイプID １つ
    //  // パッケージ v1.20 Version 2
    //  SaishinInheritValues__c = false,          //最新名刺は値を引継ぐ
    //  RegistToDoSubject__c = Label.SB_NC_ExchangeCard, // 取引先・取引先任者に登録 ToDo件名
    //  RegistNoToDo__c =  false, // 取引先・取引先任者に登録 ToDo登録しない
    //  RegistDispOverWriteCheckbox__c = true, // 取引先・取引先任者に登録 「上書きする」チェックボックスを表示する  → V3　から
    //  RegistDispAccountRectype__c = true, // 取引先・取引先任者に登録 取引先レコードタイプ選択を表示する
    //  RegistAccountNotOverWrite__c = false, // 取引先・取引先任者に登録 取引先を名刺情報で上書きしない
    //  RegistDispContactRectype__c = true, // 取引先・取引先任者に登録 取引先責任者レコードタイプ選択を表示する
    //  RegistContactNotOverWrite__c = false, // 取引先・取引先任者に登録 取引先責任者を名刺情報で上書きしない
    //  // パッケージ v1.21 Version 3
    //  RegistDispLeadOverWriteCheckbox__c = true,          //「既存のリードを名刺情報で上書きする」を表示する
    //  RegistDispAccountOverWriteCheckbox__c = true,          //「既存の取引先を名刺情報で上書きする」を表示する
    //  RegistDispContactOverWriteCheckbox__c = true          //「既存の取引先責任者を名刺情報で上書きする」を表示する
    //);
    ////bs.put('RenkeiHavePlural__c', '新規作成');
    ////bs.put('RenkeiNOExistingAccount__c', '新規作成');
    listBasicSetting.add(bs);
  }

  public virtual void initialize() {

    //// SmartVisca設定
    //initializeSmartViscaConfig();
    //if (svConfig !=null) {
    //  upsert svConfig;
    //}
    //　ユーザ
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
    // 名刺レコード作成
    initializeKaisha();     // 会社を揃えておく
    initializeEmployee();   // 会社ごとに名刺の人を揃えておく
    initializeNameCard();
    if (listCard.isEmpty() == false)
      insert listCard;

    // 名刺にToDoをつける
    initializeTask();
    if (!listTask.isEmpty()) {
      insert listTask;
    }
    // 名刺に行動をつける
    initializeEvent();
    if (!listEvent.isEmpty()) {
      insert listEvent;
    }

    // アカウント
    initializeAccount();    // 揃えた会社について、取引先を作る。
    if (mapAccount.isEmpty() == false)
      insert mapAccount.values();

    // コンタクト
    initializeContact();    // 揃えた会社ごとに名刺の人で、取引先責任者を作る。
    if (listContact.isEmpty() == false)
      insert listContact;

    // リード
    initalizeLead();        // 揃えた会社ごとに名刺の人で、リードを作る。
    if (listLead.isEmpty() == false) {
        insert listLead;
    }

  }   // initialize()

}