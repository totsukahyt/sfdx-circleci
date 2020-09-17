/**
 *
 * テストクラス用のデータを作る基底クラス
 *
 * SB_NameCard_TestDB
 *
 * Copyright (C) 2014 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2014.5.xx
 **/
public virtual class SB_NameCard_TestDB {
  // 名刺データを作るための 個人情報を持つクラス
  public class Employee {
    public String kaisha { get; private set; }
    public String name { get; private set; }
    public String sei { get; private set; }
    public String mei { get; private set; }
    public String mail { get; private set; }
    public Integer num { get; private set; }
    Employee(String kaisha, String sei, String mei, String mail, Integer num) {
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
  public List<String> listKaisha { get; private set; }
  public List<Employee> listEmp { get; private set; }
  public Map<String, Account> mapAccount { get; private set; }    // 取引先 は、名前からオブジェクトを取得出来るようにします。
  public List<Contact> listContact { get; private set; }
  public List<sObject> listLead { get; private set; }
  public SmartViscaConfig__c svConfig { get; set; }
  public List<Event> listEvent { get; private set; }      // 行動
  public List<Task> listTask { get; private set; }        // ToDo


  public SB_NameCard_TestDB() {
    listUser = new List<User>();
    listCard = new List<NameCard__c>();
    listKaisha = new List<String>();
    listEmp = new List<Employee>();
    mapAccount = new Map<String, Account>();
    listContact = new List<Contact>();
    listLead = new List<sObject>();
    listEvent = new List<Event>();
    listTask = new List<Task>();
  }

  //private void createSObject(List<sObject> objs, String objName, Map<String, Object> values) {
  //  sObject obj = Schema.getGlobalDescribe().get(objName).newSObject();
  //  for (String key : values.keySet()) {
  //    obj.put(key, values.get(key));
  //  }
  //  objs.add(obj);
  //}

  // 作成するユーザのプロファイル
  private Profile profStd {
    get {
      if (profStd == null) {
        profStd = [select id from profile where name='Standard User' or name='標準ユーザ' limit 1];
      }
      return profStd;
    }
    set;
  }

  // ユーザレコードの作成
  public User createUser(String firstname, String lastname) {
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
    for (String actName :listKaisha) {
      mapAccount.put(actName, new Account(Name= actName));
    }
    System.assertEquals(listKaisha.size(), mapAccount.size());  // 2017.10.xx v1.21 for code scan  Test Methods With No Assert
  }

  // 取引先責任者を既存にするために名刺にする取引先責任者を事前に追加
  //  存在するユーザごとに所有者を変えて同一の取引先責任者を追加
  public virtual void initializeContact() {
    for(Employee emp :listEmp) {
      Account acnt = mapAccount.get(emp.kaisha);
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
    for (Integer c = 1; c<=CNT_COMPANY; c++) {
      listKaisha.add('Company'+c.format());
    }
    System.assertEquals(CNT_COMPANY, listKaisha.size());  // 2017.10.xx v1.21 for code scan  Test Methods With No Assert
  }

  // 名刺用の会社に個人をつける
  public void initializeEmployee() {
    for (String kaisha : listKaisha) {
      for (Integer e = 1; e<=CNT_EMPLOYEE; e++) {
        listEmp.add(new Employee(kaisha
          , '名刺'
          , e.format()
          , 'emp'+e.format()+'@'+kaisha +'.com'
          , e));
      }
    }
    System.assertEquals(listKaisha.size() * CNT_EMPLOYEE, listEmp.size());  // 2017.10.xx v1.21 for code scan  Test Methods With No Assert
  }

  // 所有者が User u の Employee emp の名刺を作成
  public NameCard__c createNameCard(Employee emp, User u) {
    System.assert(emp != null);  // 2017.10.xx v1.21 for code scan  Test Methods With No Assert
    return new NameCard__c(
      name= emp.name
      , person_name_last__c= emp.sei
      , person_name_first__c= emp.mei
      , email__c= emp.mail
      , company_name__c= emp.kaisha
      , division__c = '第' + emp.num.format() + '部 第' + emp.num.format() + '課'
      , title_name__c = '役職'+emp.num.format()
      , tel1__c= '0333333333'
      , fax1__c= '0344444444'
      , mobile__c = '09099999999'
      , web_url1__c = 'http://www.'+'company'+emp.kaisha +'.com'
      , zip_code__c = '1550022'
      , address_pref__c = '東京都'
      , address__c = '渋谷区'+ emp.kaisha
      , address_bld__c = emp.kaisha + 'ビル'
      //                    , list_name__c ='名刺'
      , memo__c = 'メモ : ' + emp.kaisha +' '+ emp.num.format()
      , freehandmemo__c = '自由記述 : ' + emp.kaisha +' '+ emp.num.format()
      , delivery_type__c='1'
      , OwnerId = u.Id);
  }

  // 名刺データ作成
  //  存在するユーザごとに所有者を変えて同一の名刺を追加
  public virtual void initializeNameCard() {
    for (Employee emp :listEmp) {
      // 所有者の異なる名刺を作成
      for (User u : listUser) {
        listCard.add(createNameCard(emp, u));
      }
    }
    System.assertEquals(listEmp.size() * listUser.size(), listCard.size());  // 2017.10.xx v1.21 for code scan  Test Methods With No Assert
  }

    // 名刺の個人タグの 作成　
/*    public virtual void initializeNameCardTag() {
        for (NameCard__c card : listCard) {
            for (Integer n=0; n < CNT_TAG; n++) {
                listCardTag.add(new NameCard__tag(ItemId = card.Id, Name='tag'+n.format(), Type='Personal'));
            }
        }
        }*/

/*
    public void updateDeliveryType2() {
        for (NameCard__c card :listCard) {
            card.delivery_type__c = '2';
        }
        update listCard;
    }

    public void validateNameCardCount() {
        List<NameCard__c> cards =[select Id from NameCard__c];
        system.assertEquals(listCard.size(), cards.size());
    }

    public void printContactAndNameCard() {
        List<Contact> conts =[select Id,Name, AccountId, FirstName, LastName, email from Contact Order by Id];
        for (Contact cont : conts) {
            system.debug('__CONTACT__ : ' + cont.AccountId + cont.LastName + cont.FirstName + cont.email);
        }
        List<NameCard__c> cards =[select Id, Name, person_name_last__c, person_name_first__c, email__c, company_name__c from NameCard__c];
        for (NameCard__c card : cards) {
            system.debug('__NameCard__c__ : ' + card.company_name__c + card.person_name_first__c+ card.person_name_last__c+ card.email__c);
        }
    }

    // kaisha TRUE：会社名を指定する。　FALSE：会社名未指定のテストをする
    public void updateKaishaNULLAndDeliveryType2() {
        for (NameCard__c card :listCard) {
            card.company_name__c = null;
            card.delivery_type__c = '2';
        }
        update listCard;
    }
    */
  // SmartVisca設定　トリガを有効にする。
  // 2016.05.xx S1取引先登録対応 設定の初期値
  public virtual void initializeSmartViscaConfig() {
    svConfig = SmartViscaConfig__c.getOrgDefaults();
    svConfig.TriggerRegDateTime__c = true;
    svConfig.TriggerCreateFeedOnName__c = true;
    svConfig.TriggerMergeNameCards__c = true;
    svConfig.TriggerHistoryIsActive__c = true;
    svConfig.SSmartViscaServerOptions__c = 'Opt1:AAA\r\nOpt2:BBB';
    // +--- 2016.05.xx S1取引先登録対応
    svConfig.SRegistAccountFields1__c = 'OwnerId:OwnerId,company_name__c:Name,division__c:Site,zip_code__c:BillingPostalCode,address_pref__c:BillingState,city:BillingCity,street:BillingStreet,tel1__c:Phone,fax1__c:Fax,web_url1__c:Website';  // 2016.05.xx S1取引先登録対応
    svConfig.SRegistAccountFields2__c = 'Id:NameCard__c';     // 2016.05.xx S1取引先登録対応
    svConfig.SRegistAccountFields3__c = 'list_name__c:NameCardListName__c,memo__c:NameCardMemo__c,freehandmemo__c:NameCardFreehandmemo__c';     // 2016.05.xx S1取引先登録対応
    svConfig.SRegistContactFields1__c = 'OwnerId:OwnerId,last_name:LastName,first_name:FirstName,zip_code__c:MailingPostalCode,address_pref__c:MailingState,city:MailingCity,street:MailingStreet';      // 2016.05.xx S1取引先登録対応
    svConfig.SRegistContactFields2__c = 'tel1__c:Phone,fax1__c:Fax,mobile__c:MobilePhone,email__c:Email,title_name__c:Title,division__c:Department';      // 2016.05.xx S1取引先登録対応
    svConfig.SRegistContactFields3__c = 'Id:NameCard__c,list_name__c:NameCardListName__c,memo__c:NameCardMemo__c,freehandmemo__c:NameCardFreehandmemo__c';      // 2016.05.xx S1取引先登録対応
    svConfig.SRegistQueryAccountFields1__c = Label.SB_NC_RegistQueryAccountFields;    // 2016.05.xx S1取引先登録対応
    svConfig.SRegistQueryAccountFields2__c = Label.SB_NC_RegistQueryAccountFields;    // 2016.05.xx S1取引先登録対応
    svConfig.SRegistQueryContactFields1__c = Label.SB_NC_RegistQueryContactFields;    // 2016.05.xx S1取引先登録対応
    svConfig.SRegistQueryContactFields2__c = Label.SB_NC_RegistQueryContactFields;    // 2016.05.xx S1取引先登録対応
    // +--- 2016.05.xx S1取引先登録対応
    System.assert(svConfig != null);  // 2017.10.xx v1.21 for code scan  Test Methods With No Assert
  }

  //// 名刺の人達を事前にリードにしときます。
  //public virtual void initalizeLead() {
  //  Map<String, Object> values = new Map<String, Object>();
  //  for (Employee emp :listEmp) {
  //    values.put('LastName', emp.sei);
  //    values.put('firstName', emp.mei);
  //    values.put('Company', emp.kaisha);
  //    createSObject(listLead, 'Lead', values);
  //    values.clear();
  //  }
  //}
  public virtual void initializeEvent() {
    for (NameCard__c card : listCard) {
      listEvent.add(new Event(Subject=card.Name + 'event', OwnerId=UserInfo.getUserId()
        , IsAllDayEvent=false, ActivityDateTime=Datetime.now().addHours(-1), EndDateTime=Datetime.now()
        , whatId=card.Id));
    }
    System.assertEquals(listCard.size(), listEvent.size());  // 2017.10.xx v1.21 for code scan  Test Methods With No Assert
  }

  public virtual void initializeTask() {
    for (NameCard__c card : listCard) {
      listTask.add(new Task(Subject=card.Name + 'task', OwnerId=UserInfo.getUserId()
        ,ActivityDate=Date.today(), whatId=card.Id));
    }
    System.assertEquals(listCard.size(), listTask.size());  // 2017.10.xx v1.21 for code scan  Test Methods With No Assert
  }

  //public virtual void initializeEvent() {
  //  for (NameCard__c card : listCard) {
  //    listEvent.add(new Event(Subject=card.Name + 'event', OwnerId=card.OwnerId
  //      , IsAllDayEvent=true, ActivityDate=date.today(), whatId=card.Id));
  //  }
  //}

  //public virtual void initializeTask() {
  //  for (NameCard__c card : listCard) {
  //    listTask.add(new Task(Subject=card.Name + 'task', OwnerId=card.OwnerId, whatId=card.Id));
  //  }
  //}

  public virtual void initialize() {
/*
    initializeUser();
    if (listUser.isEmpty() == false)
        insert listUser;
    initializeKaisha();     // 会社を揃えておく
    initializeEmployee();   // 会社ごとに名刺の人を揃えておく
    initializeAccount();    // 揃えた会社について、取引先を作る。
    if (mapAccount.isEmpty() == false)
        insert mapAccount.values();

    initializeContact();    // 揃えた会社ごとに名刺の人で、取引先責任者を作る。
    if (listContact.isEmpty() == false)
        insert listContact;

    initalizeLead();        // 揃えた会社ごとに名刺の人で、リードを作る。
    if (listLead.isEmpty() == false) {
        insert listLead;
    }
    initializeNameCard();
    if (listCard.isEmpty() == false)
        insert listCard;

            */
    // SmartVisca設定
    initializeSmartViscaConfig();
    if (svConfig !=null) {
      upsert svConfig;
    }
  }   // initialize()

}