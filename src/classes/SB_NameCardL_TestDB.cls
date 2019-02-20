/**
 *
 * SB_NameCardL_TestDB
 *
 * 新 テストクラス用のデータを作る基底クラス
 *
 *
 * Copyright (C) 2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2018.4.xx
 *
 **/
public virtual class SB_NameCardL_TestDB {
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
    , 'Id' => new Set<String>{'SmartViscaf__NameCard__c'}
    , 'SmartViscaf__list_name__c' => new Set<String>{'SmartViscaf__NameCardListName__c'}
    , 'SmartViscaf__memo__c' => new Set<String>{'SmartViscaf__NameCardMemo__c'}                // 重複してるが、テストでだけ、
    , 'SmartViscaf__freehandmemo__c' => new Set<String>{'SmartViscaf__NameCardFreehandmemo__c'}
    , 'OwnerId' => new Set<String>{'OwnerId'}
  };

  private static final Map<String, Map<String, Set<String>>> otype2DefaultMapping = new Map<String, Map<String, Set<String>>> {
    'Account' => SV_TO_ACCOUNT,
    'Contact' => SV_TO_CONTACT,
    'Lead' => SV_TO_LEAD
  };

  public static final Integer CNT_USER = 5;          // ユーザ数（所有者数）

  public Smartviscaf__SmartViscaConfig__c svConfig { get; protected set; }
  public List<User> listUser { get; private set; }
  public List<Smartviscaf__NameCardBasicSetting__c> listBasicSetting { get; protected set; }   // 名刺基本設定
  public List<Smartviscaf__NameCardRenkeiMapping__c> listMapping { get; protected set; } // マッピング
  public List<Account> listAccount { get; protected set; }
  public List<Contact> listContact { get; protected set; }
  public List<Lead> listLead { get; protected set; }
  public List<Smartviscaf__NameCard__c> listCard { get; private set; }

  public SB_NameCardL_TestDB() {
    this.listUser = new List<User>();
    this.listBasicSetting = new List<Smartviscaf__NameCardBasicSetting__c>();
    this.listMapping = new List<Smartviscaf__NameCardRenkeiMapping__c>(); // マッピング
    this.listAccount = new List<Account>();
    this.listContact = new List<Contact>();
    this.listLead = new List<Lead>();
    this.listCard = new List<Smartviscaf__NameCard__c>();
  }

  // SmartVisca設定
  public virtual void initializeSmartViscaConfig() {
    svConfig = Smartviscaf__SmartViscaConfig__c.getOrgDefaults();
    //svConfig.TriggerRegDateTime__c = true;
    //svConfig.TriggerCreateFeedOnName__c = false;
    //svConfig.TriggerMergeNameCards__c = false;
    //svConfig.TriggerHistoryIsActive__c = false;
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
      , username=firstname+lastname+'@testorg.com');
  }

  // ユーザの初期化
  public virtual void initializeUser() {
    for(Integer n=1; n<=CNT_USER; n++) {
      listUser.add(createUser(n.format()+'太郎', '名刺'));
    }
    System.assertEquals(CNT_USER, listUser.size());
  }

  //// 基本設定のデフォルト値のレコードを作る
  //protected SmartViscaf__NameCardBasicSetting__c getOrgDefaultBasicSetting() {
  //  SmartViscaf__NameCardBasicSetting__c bs = new SmartViscaf__NameCardBasicSetting__c();
  //  bs.Smartviscaf__RenkeiAccountAddressPref__c = false;   // アカウント 都道府県
  //  bs.Smartviscaf__RenkeiAccount_Street__c = false;   // アカウント 町名・番地
  //  bs.Smartviscaf__RenkeiAccountZipCode__c = false;   // アカウント 郵便番号
  //  bs.Smartviscaf__RenkeiAccountCity__c = false;      // アカウント 市区郡
  //  bs.Smartviscaf__RenkeiAccountURL__c = false;       // アカウント URL
  //  bs.Smartviscaf__RenkeiAccountCompany__c = true;   // アカウント 会社名
  //  bs.Smartviscaf__RenkeiAccountPhone__c = false;     // アカウント 電話番号
  //  bs.Smartviscaf__RenkeiSpecificItems__c = null;        // アカウント 特定項目
  //  bs.Smartviscaf__RenkeiAccountSite__c = false;        // アカウント 部署名
  //  bs.Smartviscaf__RenkeiExcludeHojinkakuPartial__c = true;      // 自動連携:会社名は法人格を除いて部分一致
  //  bs.Smartviscaf__RenkeiExcludeHojinkaku__c = false;      // 自動連携:会社名は法人格を除いて完全一致
  //  bs.Smartviscaf__RenkeiAccountSitePartialMatch__c = false;      // 自動連携:部署は中間一致検索
  //  bs.Smartviscaf__RenkeiContactMail__c = true;      // コンタクト メールアドレス
  //  bs.Smartviscaf__RenkeiContactLastName__c = true;  // コンタクト ラストネーム
  //  bs.Smartviscaf__RenkeiContactFirstName__c = true; // コンタクト ファーストネーム
  //  bs.Smartviscaf__RenkeiAccountQueryRecordTypeIds__c = null;    // 検索対象のレコードタイプタイプID カンマ区切り で羅列
  //  bs.Smartviscaf__RenkeiContactQueryRecordTypeIds__c = null;  // 自動連携で検索対象の取引先責任者レコードタイプ
  //  bs.Smartviscaf__RenkeiAccountOverwrite__c = false;   // 既存の取引先を上書き  初期値：上書きしない!
  //  bs.Smartviscaf__RenkeiContactOverwrite__c = false;   // 既存の取引先責任者を上書き  初期値：上書きしない!
  //  bs.Smartviscaf__RenkeiAccountNOExistCreateNew__c = true;  //既存の取引先がなければ新規作成する
  //  bs.Smartviscaf__RenkeiContactNOExistCreateNew__c = true;  // 既存の取引先責任者がなければ新規作成する
  //  bs.Smartviscaf__RenkeiAccountRecordTypes__c = null;     // 作成するアカウント の レコードタイプID １つ
  //  bs.Smartviscaf__RenkeiContactRecordTypes__c = null;      // 作成するコンタクト の レコードタイプID １つ
  //  // パッケージ v1.20 Version 2
  //  bs.Smartviscaf__SaishinInheritValues__c = false;          //最新名刺は値を引継ぐ
  //  bs.Smartviscaf__RegistNoToDo__c = false; // 取引先・取引先任者に登録 ToDo登録しない
  //  bs.Smartviscaf__RegistToDoSubject__c = '名刺交換'; // 取引先・取引先任者に登録 ToDo件名
  //  bs.Smartviscaf__RegistDispOverWriteCheckbox__c = true; // 取引先・取引先任者に登録 「上書きする」チェックボックスを表示する   → V3　から未使用 → 2つにわける
  //  bs.Smartviscaf__RegistAccountNotOverWrite__c = false; // 取引先・取引先任者に登録 取引先を名刺情報で上書きしない
  //  bs.Smartviscaf__RegistContactNotOverWrite__c = false; // 取引先・取引先任者に登録 取引先責任者を名刺情報で上書きしない
  //  bs.Smartviscaf__RegistDispAccountRectype__c = true; // 取引先・取引先任者に登録 取引先レコードタイプ選択を表示する
  //  bs.Smartviscaf__RegistDispContactRectype__c = true; // 取引先・取引先任者に登録 取引先責任者レコードタイプ選択を表示する
  //  // パッケージ v1.22 Version 3
  //  // SV_DEV-582 取引先・取引先任者に登録 「上書きする」チェックボックスを表示する  → 2つにわける
  //  bs.Smartviscaf__RegistDispAccountOverWriteCheckbox__c = true;          //「既存の取引先を名刺情報で上書きする」を表示する
  //  bs.Smartviscaf__RegistDispContactOverWriteCheckbox__c=true;          //「既存の取引先責任者を名刺情報で上書きする」を表示する
  //  // リード拡張 リード登録画面関連
  //  bs.Smartviscaf__RegistDispLeadOverWriteCheckbox__c = true;          //「既存のリードを名刺情報で上書きする」を表示する
  //  bs.Smartviscaf__RegistDispLeadRectype__c=true;   // リードに登録 リードレコードタイプ選択を表示する  Lead EX  V1.11 から
  //      // 取引先登録:リードを名刺情報で上書きしない リードに登録 名刺情報で上書きする  反転させるので注意！
  //  bs.Smartviscaf__RegistLeadNotOverWrite__c=false;
  //  // リード拡張 キャンペーン適用用
  //  bs.Smartviscaf__ScanSelectCampaign__c = false;         // スキャン:キャンペーン選択を有効化
  //  // リード拡張 自動連携 リード登録関連
  //  bs.Smartviscaf__RenkeiLeadActive__c = false;           // 自動連携:リード登録機能を有効化
  //  bs.Smartviscaf__RenkeiLeadNOExistCreateNew__c = true;  // 自動連携:既存のリードがなければ新規作成
  //  bs.Smartviscaf__RenkeiLeadOverwrite__c = false;        // 自動連携:既存のリードを上書き  初期値：上書きしない!
  //  bs.Smartviscaf__RenkeiLeadRecordTypes__c = null;       // 自動連携:リードレコードタイプ
  //  bs.Smartviscaf__RenkeiActiveCampaignMember__c = false;  // 自動連携:スキャン時選択したキャンペーンのメンバーにする
  //  bs.Smartviscaf__RenkeiCampaignStatus__c = null;         // 自動連携:キャンペーンの状況
  //  return bs;
  //}

  public virtual void initializeBasicSetting() {
    SmartViscaf__NameCardBasicSetting__c bs = SmartViscaf.SB_NC_PostInstallScript.createDefaultBasicSetting();
    //SmartViscaf__NameCardBasicSetting__c bs = getOrgDefaultBasicSetting();
    listBasicSetting.add(bs);
  }

  private static final Map<String, Schema.RecordTypeInfo> rectypeInfos = SmartViscaf__NameCardRenkeiMapping__c.getSObjectType().getDescribe().getRecordTypeInfosByName();
  private static final Map<String, Schema.SObjectField> ncFields = SmartViscaf__NameCard__c.getSObjectType().getDescribe().fields.getMap();

  private void addMappings(String objName, Id settingsId) {
    String ns = SmartViscaf.SB_NameCard_Util.getNamespacePrefix_x();
    Id rectypeId = rectypeInfos.get(objName).getRecordTypeId();
    for (String src : SV_TO_ACCOUNT.keySet()) {
      for (String dest : otype2DefaultMapping.get(objName).get(src)) {
        String target = dest.endsWithIgnoreCase('__c') ? ns + dest : dest;
        String nc = src.endsWithIgnoreCase('__c') ? ns + src : src;
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

  //
  public virtual void initializeAccount() {

  }

  public virtual void initializeContact() {

  }

  //
  public virtual void initalizeLead() {

  }

  public  virtual void initializeNameCard() {

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
    // リード
    initalizeLead();
    if (!listLead.isEmpty()) {
      SmartViscaf.SB_NameCard_CrudFls.screate(listLead, true);
    }
    // 名刺レコード作成
    initializeNameCard();
    if (!listCard.isEmpty()) {
      SmartViscaf.SB_NameCard_CrudFls.screate(listCard, true);
    }

  }   // initialize()


}