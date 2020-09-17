/**
 *
 * SB_NameCard_SRegistController
 * Salesforce1対応 SmartVisca 取引先・取引先責任者へ登録 画面の コンロローラ
 *
 * Copyright (C) 2016 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2016.04.xx
 *  @Version 2      2017.11.xx v1.20.3 メアド + 氏名 で コンタクトを抽出 SV_DEV-658 LEX画面 :取引先・取引先責任者に登録（個別登録）でメールアドレスのみで取引先責任者の候補が表示される
 *  @Version 3      2017.11.xx v1.20.4 SV_DEV-673 会社名に全角バックスラッシュが含まれる名刺を自動連携すると、ORA-01424エラーが発生して wait 状態
 *  @Version 4      2018.01.xx v1.22 SV_DEV-435 S1の取引先･取引先責任者に登録のマッピングとLEX・Classicのマッピングを同じにします。
 *  @Version 2.1    2018.11.xx SV_DEV-1346 S1 取引先登録で、遷移元を識別し戻る
 *  @Version 2.5    2020.03.xx SV_DEV-2301 S1 取引先登録：S取引先登録時表示する取引先の項目1,2 に 複合住所項目 を指定した場合、JSON形式のまま表示される。
 *                             SV_DEV-2146 LEX 取引先登録 個別：取引先の日付（カスタム項目）をマッピングに設定した際に登録先候補で表示されるポップアップが日付で表示されない
 *
 **/
global with sharing class SB_NameCard_SRegistController {
  public class SB_NameCard_SRegistControllerException extends Exception {}

  // アカウント or コンタクト の対象は 既存のレコードか新規レコードか
  private static final Integer OPT_MATH = 1;    // 既存で名刺と一致してるアカウント or コンタクトレコードが対象
  private static final Integer OPT_SELECT = 2;    // 既存で選択してもらう アカウント or コンタクトレコードが対象
  private static final Integer OPT_NEW = 3;    // 新規で アカウント or コンタクトレコードが対象

  public Id targetId { get; private set; }
  public String uiType { get; private set; } // v2.1 2018.11.xx 起動パラメータの uitype
  public String retUrl { get; private set; } // v2.1 2018.11.xx /apex/ からに変える
  public NameCard__c card { get; private set; }
  public String getNameSpace() { return SB_NameCard_Util.getNamespacePrefix(); }
  public Boolean getDevMode() { return getConfig().devMode; }

  private static final String NMAECARD_FIELDS = 'Id, Name, name_kana__c, person_name_last__c, person_name_first__c' +
  ', company_name__c, company_name_kana__c, division__c, title_name__c' +
  ', zip_code__c, address_pref__c, address__c, address_bld__c, address_eng__c' +
  ', card_exchange_date__c, list_name__c, OwnerId, Owner.Name, Parent__c, tenshokugonomeishi__c, account__c, contact__c' +
  ', freehandmemo__c, memo__c, web_url1__c, email__c, tel1__c, mobile__c, fax1__c' +
  ', image_id__c, bk_image_id__c, width__c, height__c, bk_width__c, bk_height__c';

/*
  private static final Map<String, Set<String>> SV_TO_ACCOUNT = new Map<String, Set<String>> {
    'web_url1__c' => new Set<String>{'Website'}
    ,'zip_code__c' => new Set<String>{'BillingPostalCode'}
    ,'address_pref__c' => new Set<String>{'BillingState'}
    ,'city' => new Set<String>{'BillingCity'}
    ,'street' => new Set<String>{'BillingStreet'}
    ,'tel1__c' => new Set<String>{'Phone'}
    ,'fax1__c' => new Set<String>{'Fax'}
    ,'Id' => new Set<String>{'NameCard__c'}
    ,'list_name__c' => new Set<String>{'NameCardListName__c'}
    ,'memo__c' => new Set<String>{'NameCardMemo__c'}
    ,'freehandmemo__c' => new Set<String>{'NameCardFreehandmemo__c'}
  };

  private static final Map<String, Set<String>> SV_TO_CONTACT = new Map<String, Set<String>> {
    'last_name' => new Set<String>{'LastName'}
    , 'first_name' => new Set<String>{'FirstName'}
    , 'person_name_last_kana__c' => new Set<String>{'ChargeKana__c'}
    , 'person_name_first_kana__c' => new Set<String>{'ChargeKanaFirst__c'}
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
    , 'memo__c' => new Set<String>{'NameCardMemo__c'}
    , 'freehandmemo__c' => new Set<String>{'NameCardFreehandmemo__c'}
  };
*/
  // アカウントとコンタクトの表示ラベル
  private static final String ACCOUNT_LABEL = Schema.getGlobalDescribe().get('Account').getDescribe().getLabel();
  private static final String CONTACT_LABEL = Schema.getGlobalDescribe().get('Contact').getDescribe().getLabel();
  // オブジェクトと表示ラベルのマップ
  private static Map<SObjectType, String> sobj2Label {
    get {
      if (sobj2Label == null) {
        sobj2Label = new Map<SObjectType, String>();
        sobj2Label.put(Account.sObjectType, ACCOUNT_LABEL);
        sobj2Label.put(Contact.sObjectType, CONTACT_LABEL);
      }
      return sobj2Label;
    }
  }

 private class QueryField {
    public String name { get; private set; }      // クエリする項目のAPI名
    public Integer summary { get; private set; }   // 要約部の表示の有無 1:要約部のみに表示 2:要約部とモーダル内両方表示  その他、-1とか:要約部に表示しない
    public QueryField(String s) {
      String[] ss = s.split(':\\s*');
      name = ss[0];
      summary = ss.size() > 1 ? Integer.valueOf(ss[1]): -1;
    }
  }

  private static List<QueryField> getQueryField(String source) {
    List<QueryField> result = new List<QueryField>();
    if (String.isNotBlank(source)) {
      String[] lines = source.split(',\\s*');
      for (String line : lines) {
        result.add(new QueryField(line));
      }
    }
    return result;
  }

  // 表示して欲しい取引先の項目API名
  private static List<QueryField> accountFields {
    get {
      if (accountFields ==null) {
        List<QueryField>  tempList = new List<QueryField>();
        tempList = getQueryField(SB_NameCard_Util.smartViscaConfig.SRegistQueryAccountFields1__c);
        tempList.addAll(getQueryField(SB_NameCard_Util.smartViscaConfig.SRegistQueryAccountFields2__c));
        accountFields = new List<QueryField>();
        Set<String> tempSet = new Set<String>{'id', 'name'};     // 重複チェック用
        Map<String, Schema.SObjectField > fMap = Account.sObjectType.getDescribe().fields.getMap();
        for (QueryField f : tempList) {
          if (tempSet.contains(f.name.toLowerCase())) continue;      // 重複してたらスキップ
          if (!fMap.containsKey(f.name.toLowerCase())) continue;     // API名不正ならスキップ
          if (!fMap.get(f.name.toLowerCase()).getDescribe().isAccessible()) continue; // 参照負荷ならスキップ
          accountFields.add(f);
          tempSet.add(f.name.toLowerCase());
        }
      }
      return accountFields;
    }
  }

  // 表示して欲しい取引先責任者の項目API名
  private static List<QueryField> contactFields {
    get {
      if (contactFields ==null) {
        List<QueryField>  tempList = new List<QueryField>();
        tempList = getQueryField(SB_NameCard_Util.smartViscaConfig.SRegistQueryContactFields1__c);
        tempList.addAll(getQueryField(SB_NameCard_Util.smartViscaConfig.SRegistQueryContactFields2__c));
        contactFields = new List<QueryField>();
        Set<String> tempSet = new Set<String>{'id', 'name'};     // 重複チェック用
        Map<String, Schema.SObjectField > fMap = Contact.sObjectType.getDescribe().fields.getMap();
        for (QueryField f : tempList) {
          if (tempSet.contains(f.name.toLowerCase())) continue;      // 重複してたらスキップ
          if (!fMap.containsKey(f.name.toLowerCase())) continue;     // API名不正ならスキップ
          if (!fMap.get(f.name.toLowerCase()).getDescribe().isAccessible()) continue; // 参照負荷ならスキップ
          contactFields.add(f);
          tempSet.add(f.name.toLowerCase());
        }
      }
      return contactFields;
    }
  }

  // オブジェクトと 表示して欲しい項目API名s のマッピング
  private static Map<SObjectType, List<QueryField>> sobj2Fields {
    get {
      if (sobj2Fields == null)  {
        sobj2Fields = new Map<SObjectType, List<QueryField>>();
        sobj2Fields.put(Account.sObjectType, accountFields);
        sobj2Fields.put(Contact.sObjectType, contactFields);
      }
      return sobj2Fields;
    }
  }

  @TestVisible
  private static Map<String, Set<String>> getSepareteCRLF_Conma(Map<String, Set<String>> s2d, String text) {
    try {
      String[] lines = text.split(',\\s*');
      for (String line : lines) {
        String[] ss = line.split(':\\s*');
        Set<String> val = null;
        if (s2d.containsKey(ss[0])) {
          val = s2d.get(ss[0]);
        }
        else {
          val = new Set<String>();
        }
        val.add(ss[1]);
        s2d.put(ss[0], val);
      }
    }
    catch(Exception e) {
      throw new SB_NameCard_SRegistControllerException(e.getMessage());
    }
    return s2d;
  }

  // 取引先登録するときの 名刺の項目とのマッピング
  // 定義が空なら 値の複写をしない。
  public static Map<String, Set<String>> nc2account {
    get {
      if (nc2account == null) {
        nc2account = new Map<String, Set<String>>();
        if (String.isNotBlank(SB_NameCard_Util.smartViscaConfig.SRegistAccountFields1__c)) {
          getSepareteCRLF_Conma(nc2account, SB_NameCard_Util.smartViscaConfig.SRegistAccountFields1__c);
        }
        if (String.isNotBlank(SB_NameCard_Util.smartViscaConfig.SRegistAccountFields2__c)) {
          getSepareteCRLF_Conma(nc2account, SB_NameCard_Util.smartViscaConfig.SRegistAccountFields2__c);
        }
        if (String.isNotBlank(SB_NameCard_Util.smartViscaConfig.SRegistAccountFields3__c)) {
          getSepareteCRLF_Conma(nc2account, SB_NameCard_Util.smartViscaConfig.SRegistAccountFields3__c);
        }
      }
      return nc2account;
    }
  }

  // 取引先登録するときの 名刺の項目とのマッピング
  // 定義が空なら 値の複写をしない。
  public static Map<String, Set<String>> nc2contact {
    get {
      if (nc2contact == null) {
        nc2contact = new Map<String, Set<String>>();
        if (String.isNotBlank(SB_NameCard_Util.smartViscaConfig.SRegistContactFields1__c)) {
          getSepareteCRLF_Conma(nc2contact, SB_NameCard_Util.smartViscaConfig.SRegistContactFields1__c);
        }
        if (String.isNotBlank(SB_NameCard_Util.smartViscaConfig.SRegistContactFields2__c)) {
          getSepareteCRLF_Conma(nc2contact, SB_NameCard_Util.smartViscaConfig.SRegistContactFields2__c);
        }
        if (String.isNotBlank(SB_NameCard_Util.smartViscaConfig.SRegistContactFields3__c)) {
          getSepareteCRLF_Conma(nc2contact, SB_NameCard_Util.smartViscaConfig.SRegistContactFields3__c);
        }
      }
      return nc2contact;
    }
  }

  private static Map<SObjectType, Map<String, Set<String>>> obj2FieldMapping {
    get {
      if (obj2FieldMapping == null) {
        obj2FieldMapping = new Map<SObjectType, Map<String, Set<String>>>();
        obj2FieldMapping.put(Account.SObjectType, nc2account);
        obj2FieldMapping.put(Contact.SObjectType, nc2contact);
      }
      return obj2FieldMapping;
    }
  }

  private static final String USER_LANGUAGE = UserInfo.getLanguage().toLowerCase();
  // 端末での表示用に値を整形する
  private static Object getCanonicalValue(SObject obj, DescribeFieldResult dfr) {
    Object result = obj.get(dfr.getName());
    if (dfr.getName().containsIgnoreCase('PostalCode') && result != null) {
      result = (USER_LANGUAGE == 'ja' ?  '〒': '') + (String) result;
    }
    else if (result != null) {
      if (dfr.getType() == Schema.DisplayType.ADDRESS) {
        // v2.5 2020.03.xx SV_DEV-2301 S1 取引先登録：S取引先登録時表示する取引先の項目1,2 に 複合住所項目 を指定した場合、JSON形式のまま表示される。
        Address a = (Address)result;
        result = String.format(System.Label.SB_NC_AddressFormat,
            new String[] { String.isNotBlank(a.getCountry())? a.getCountry() : '',
                            String.isNotBlank(a.getCountryCode())? a.getCountryCode() : '',
                            String.isNotBlank(a.getPostalCode())? a.getPostalCode() : '',
                            String.isNotBlank(a.getState())? a.getState() : '',
                            String.isNotBlank(a.getStateCode())? a.getStateCode() : '',
                            String.isNotBlank(a.getCity())? a.getCity() : '',
                            String.isNotBlank(a.getStreet())? a.getStreet() : '' });
      }
      // v2.5 2020.03.xx SV_DEV-2146 LEX 取引先登録 個別：取引先の日付（カスタム項目）をマッピングに設定した際に登録先候補で表示されるポップアップが日付で表示されない
      else if (dfr.getType() == Schema.DisplayType.Datetime && result instanceOf DateTime) {
        result = ((DateTime)result).format();
      }
      else if (dfr.getType() == Schema.DisplayType.Date && result instanceOf Date) {
        result = ((Date)result).format();
      }
    }
    return result;
  }

  // 取引先責任者 の処理の 選択するオプション
  public virtual class RegistOption {
    public Integer index { get; private set; }
    public Boolean selected { get; private set; }
    public Id id { get; private set; }
    public Integer type { get; private set; }
    public String title { get; private set; }      // Name とか 表示用の名称
    public String owner { get; private set; }      // 所有者
    public String info { get; private set; }
    public Map<String, Object> label2val { get; private set; }
    public List<Object> summary { get; private set; }
    public List<Object> values { get; private set; }
    // 一致したレコードを選択するとき
    RegistOption(SObject obj, Integer index, Integer type) {
      this.index = index;
      this.selected = false;
      this.id = obj.Id;
      this.title = (String)obj.get('Name');
      this.owner = (String)obj.getSObject('Owner').get('Name');
      this.info = null;
      this.type = type; // OPT_MATH, OPT_SELECT
      label2val = new Map<String, Object>();
      summary = new List<Object>();
      values = new List<Object>();
      Map<String, Schema.SObjectField > fMap = obj.getSObjectType().getDescribe().fields.getMap();
      List<QueryField> fields = sobj2Fields.get(obj.getSObjectType());
      for (QueryField field : fields) {
        DescribeFieldResult dfr = fMap.get(field.name.toLowerCase()).getDescribe();
        String label = dfr.getLabel();
        Object val = getCanonicalValue(obj, dfr);
        this.label2val.put(label, val);
        if (field.summary == 1 || field.summary == 2) {
          this.summary.add(val);
        }
        if (field.summary != 1) {
          this.values.add(val);
        }
      }
      System.debug(this.values);
    }
    // 既存レコードを選択 or 新規追加する とき
    RegistOption(AltRegistOption opt, Integer index, SObjectType otype) {
      this.index = index;
      this.selected = false;
      this.id = null;
      String label = sobj2Label.get(otype);   // オブジェクトの表示ラベル
      this.title = String.format(opt.title_format, new String[]{label});
      this.info = String.format(opt.info_format, new String[]{label});
      this.type = opt.type;     // 2 or 3
    }
  }

  // 取引先 の処理の 選択するオプション
  public class AccountOption extends RegistOption {
    //public Integer contactCount;        // 取引先責任者の数
    public Integer contactCount;        // 取引先責任者の数 名刺からの検索では、メアド、姓名が一致した数
    public Integer oppotunityCount;     // 商談の数
    AccountOption(Account acnt, Integer index, Integer type) {
      super(acnt, index, type);
      // 取引先責任者の数
      List<SObject> conts = acnt.Contacts;
      this.contactCount = (conts == null || conts.isEmpty()) ? 0 : conts.size();
      List<Opportunity> opps = acnt.Opportunities;
      this.oppotunityCount = (opps == null || opps.isEmpty()) ? 0 : opps.size();
    }

    //AccountOption(AltRegistOption opt, Integer index, SObjectType otype) {
    //  super(opt, index, otype);
    //  this.contactCount = 0;
    //  this.oppotunityCount = 0;
    //}
  }

  // 既存のアカウント、コンタクト 以外の選択肢 のひな形用クラス
  private class AltRegistOption {
    public Integer type;
    public String title_format;
    public String info_format;
    AltRegistOption(Integer type, String title, String info) {
      this.type = type;
      this.title_format = title;
      this.info_format = info;
    }
  }

  // 既存のアカウント、コンタクト 以外の選択肢 のひな形
  private static final Map<Integer, AltRegistOption> ALT_REGIST_OPTIONS = new Map<Integer, AltRegistOption> {
    OPT_SELECT => new AltRegistOption(OPT_SELECT, Label.SB_NCS1R_Text_SelectOther, Label.SB_NCS1R_Text_SelectOtherDiscription), // 'その他の{0}を指定', '既存の{0}を検索して指定します。',
    OPT_NEW => new AltRegistOption(OPT_NEW, Label.SB_NCS1R_Text_CreateNewRecord, Label.SB_NCS1R_Text_CreateNewRecordDiscription)     // '新規{0}追加', '{0}を新たに追加します。'
  };

  // 諸設定を取得
  @RemoteAction
  public static SB_NameCard_S1Config getConfig() {
    return SB_NameCard_S1Config.config;
  }

  public SB_NameCard_SRegistController() {
  }

  // 戻り先URLのフォーム {0} namespave {1} smartvisca tab page {2} l$location.path() or record id
  private final String RETURN_URL_FORM = '/apex/{0}SB_NameCard_S1Index?#{1}';
  private final String RETURN_UI2_URL_FORM = '/apex/{0}SB_NameCard_SIndex?#/card/{1}/detail';
  private final String RETURN_URL_DETAIL_FORM = '/apex/{0}SB_NameCard_S1Index?#/detail/{1}/ret/MineOnly';

  // 戻り先URLを作る。 ただし、's1RecDetail'だったらそのまま v2.1 2018.11.xx SV_DEV-1346 S1 取引先登録で、遷移元を識別し戻る
  @TestVisible
  private String buildReturnUrl() {
    String result;
    String retUrl = System.currentPageReference().getParameters().get('retUrl');
    if (this.uiType == '2') {
      // 新UI
      result = String.format(RETURN_UI2_URL_FORM, new String[]{ SB_NameCard_Util.getNamespacePrefix_x(), this.targetId });
    }
    else if (String.isBlank(retUrl)) {
      //  retUrl指定なし -> レコードIDからこさえる。
      result = String.format(RETURN_URL_DETAIL_FORM, new String[]{ SB_NameCard_Util.getNamespacePrefix_x(), this.targetId });
    }
    else if (retUrl != 's1RecDetail') {
      // S1 旧 SmartViscaタブの取引に登録ボタンからきた  $location.path() "/detail/a066F00001G1kxmQAB/ret/MineOnly"
      result = String.format(RETURN_URL_FORM, new String[]{ SB_NameCard_Util.getNamespacePrefix_x(), retUrl });
    }
    else {
      // 's1RecDetail' S1標準のレコード詳細からよばれたとき -> Javascriptで振り分ける。
      result = retUrl;
    }
    return result;
  }

  public SB_NameCard_SRegistController(ApexPages.StandardController stdController) {
    this.targetId = String.isNotBlank(((Sobject)stdController.getRecord()).Id) ? ((Sobject)stdController.getRecord()).Id : 'a001000000q38or'; // null はテスト用 'a001000000q38or'
    this.uiType = System.currentPageReference().getParameters().get('uitype'); // v2.1
    this.retUrl = buildReturnUrl(); // v2.1 2018.11.xx SV_DEV-1346 S1 取引先登録で、遷移元を識別し戻る
    System.debug(this.targetId);
  }

  public void init() {
    try {
      String query =
        'SELECT '+ NMAECARD_FIELDS + ' FROM NameCard__c WHERE Id = :targetId';
      List<NameCard__c> cards = Database.query(query);      // 照会実施
      if (cards.isEmpty() == true) {
        throw new SB_NameCard_SRegistControllerException(Label.SB_MSG_IllegalRequest + 'Id : ' + targetId);
      }
      card = cards[0];
    }
    catch(Exception e) {
      throw new SB_NameCard_SRegistControllerException(e.getMessage());
    }
  }

  // レコードタイプに関する情報
  public class RecordTypeInfo {
    public String  label;
    //public String  apiname;
    public String  id;
    public Boolean use;
    RecordTypeInfo(Schema.RecordTypeInfo info) {
      this.label = info.getName();
      this.id = info.getRecordTypeId();
      this.use = true;
    }
  }

  // レコードタイプに関する情報を返す。
  @RemoteAction
  public static List<RecordTypeInfo> getRecordTypeInfo(String objname) {
    List<RecordTypeInfo> result = new List<RecordTypeInfo>();
    Map<String, Schema.RecordTypeInfo> mapRecordTypes;
    Schema.DescribeSObjectResult R = Schema.getGlobalDescribe().get(objname).getDescribe();
    mapRecordTypes = R.getRecordTypeInfosByName();
    for (String key : mapRecordTypes.keySet()) {
      Schema.RecordTypeInfo info = mapRecordTypes.get(key);
      if (info.isAvailable() == false) continue;   // ユーザが使用可能なものだけ
      if (info.isMaster() == true) continue;   // マスターは除外
      if (info.isDefaultRecordTypeMapping() && !result.isEmpty()) {
       // デフォルトは一番目に
        result.add(0, new RecordTypeInfo(info));
      }
      else {
        result.add(new RecordTypeInfo(info));
      }
    }
    return result;
  }

  // 表示用の名刺情報を取得する
  @RemoteAction
  public static SB_NameCard_SController.NameCardDTO getNameCard(String targetId) {
    String query =
         'SELECT '+ NMAECARD_FIELDS + ' FROM NameCard__c WHERE Id = :targetId';
    List<NameCard__c> cards = Database.query(query);      // 照会実施
    if (cards.isEmpty()) {
      throw new SB_NameCard_SRegistControllerException(Label.SB_MSG_IllegalRequest + 'Id : ' + targetId);
    }
    SB_NameCard_SController.NameCardDTO result = new SB_NameCard_SController.NameCardDTO();
    result.bind(cards[0]);
    return  result;
  }

  public class QueryOption {
    public Boolean querySite;      // 取引先検索で 所属名を条件にして検索 0: 取引先名と所属名で検索 1,その他: 取引先名のみで検索
    public Boolean queryState;     // 取引先検索で 都道府県を条件にして検索
    public Boolean queryCity;       // 取引先検索で 市区郡を条件にして検索
    public Boolean queryZip;       // 取引先検索で 郵便番号を条件にして検索
    public List<String> acntRecTypeIds;  // アカウントのレコードタイプ名を条件にする
    public List<String> contRecTypeIds;  // コンタクトのレコードタイプ名を条件にする
    public QueryOption() {
      this.querySite = false;
      this.queryState = false;
      this.queryCity = false;
      this.queryZip = false;
      this.acntRecTypeIds = null;
      this.contRecTypeIds = null;
    }
  }

  // アカウント、コンタクトを検索するときに必要な名刺データをクエリ
  @TestVisible
  private static NameCard__c getSimpleNameCard(Id targetId) {
    List<NameCard__c> cards = [SELECT Id, Name,
              company_name__c, company_name_kana__c, division__c, title_name__c,
              zip_code__c, address_pref__c, address__c, address_bld__c, address_eng__c,
              last_name__c, first_name__c, person_name_last__c, person_name_first__c, email__c
              FROM NameCard__c WHERE Id = :targetId];
    if (cards.isEmpty()) {
      throw new SB_NameCard_SRegistControllerException(Label.SB_MSG_IllegalRequest + 'Id : ' + targetId);
    }
    return cards[0];
  }

  // 取引先責任者の名前の条件
  @TestVisible
  private static Set<String> getContactNameSet(NameCard__c card) {
    Set<String> result = new Set<String>();
    Map<String, String> pnMap = SB_NameCard_Util.getPersonName(card);
    String last_name = pnMap.get('last_name');
    String first_name = pnMap.get('first_name');
    if (String.isNotEmpty(last_name) && String.isNotEmpty(first_name)) {
      result.add(last_name + ' ' + first_name);
    }
    else if (String.isNotEmpty(last_name)) {
      result.add(last_name);
      result.add(last_name + '%');
    }
    return result;
  }

  // 検索結果以外の アカウント、コンタクト 更新、追加の オプションを 追加
  //   enabelSelect その他を選択して更新 が可能か アカウント新規作成の場合はない。
  private static void addAltRegitOption(List<RegistOption> opt, SObjectType otype, Boolean enabelSelect) {
    AltRegistOption alt = null;
    if (enabelSelect) {  // アカウントを選ばれてないとコンタクトは選択できないの
      alt = ALT_REGIST_OPTIONS.get(OPT_SELECT);      // その他を更新
      opt.add(new RegistOption(alt, opt.size(), otype));
    }
    DescribeSObjectResult dsr = otype.getDescribe();
    if (dsr.isCreateable()) {  // 新規追加出来ないユーザでは 新規オプションはおくらない。
      alt = ALT_REGIST_OPTIONS.get(OPT_NEW);      // 新規追加
      opt.add(new RegistOption(alt, opt.size(), otype));
    }
  }

  // 名刺に該当する取引先を取得
  @RemoteAction
  public static List<RegistOption> getAccountOptions(Id cardId, QueryOption opt) {
    System.debug(opt);
    List<RegistOption> result = new List<RegistOption>();
    // 該当の名刺
    NameCard__c card = getSimpleNameCard(cardId);
    Set<String> names = getContactNameSet(card);
    // 2017.11.xx v1.20.4 SV_DEV-673 会社名に全角バックスラッシュが含まれる名刺を自動連携すると、ORA-01424エラーが発生して wait 状態
    String accountName = SB_NameCard_Util.getZenkakuBackslashToWildcard(SB_NameCard_Util.getCompanyName(card.company_name__c));
    List<String> acntRIds = null;   // アカウントのレコードタイプ 条件
    if (opt != null && opt.acntRecTypeIds !=null && !opt.acntRecTypeIds.isEmpty()) {
      acntRIds = new List<String>(opt.acntRecTypeIds);
    }
    List<String> contRIds = null;   // コンタクトのレコードタイプ 条件
    String contactRecTypeConditon = '';   // コンタクトのレコードタイプ WHERE 句
    if (opt != null && opt.contRecTypeIds !=null && !opt.contRecTypeIds.isEmpty()) {
      contRIds = new List<String>(opt.contRecTypeIds);
      contactRecTypeConditon = Test.isRunningTest() ? '' : ' AND RecordTypeId IN :contRIds';
    }
    // 検索条件
    String query = 'SELECT Id, Name, Owner.Name';
    for (QueryField f : accountFields) {
      query += ', ' + f.name;
    }

    // コンタクトのクエリ
    if (String.isNotBlank(card.email__c)) {
      // メアドがあれば、メアドからコンタクト取得
      query += ', (SELECT Id FROM Contacts WHERE email=\'' + card.email__c + '\'' + contactRecTypeConditon +')';
    }
    else if (!names.isEmpty()){
      // メアドがなくて、姓名があれば、姓名からコンタクト取得
      query += ', (SELECT Id FROM Contacts WHERE Name LIKE :names' + contactRecTypeConditon +')';
    }
    // 商談のクエリ
    query += ', (SELECT Id FROM Opportunities)';
    query += ' FROM Account WHERE '; //, RecordTypeId, RcordType.Name)';
    // 会社名
    if (String.isNotBlank(accountName)) {
      //accountName = '%' + accountName + '%'; // // 2017.11.xx v1.20.4
      //query += ' Name LIKE :accountName';
      query += ' Name LIKE \'%' + String.escapeSingleQuotes(accountName) + '%\'';
    }
    else {
      query += ' Name=null';
    }
    // 所属
    if (opt != null && opt.querySite) {    // 所属を使う
      query += ' AND Site';
      query += String.isNotBlank(card.division__c) ? ' LIKE \'%' + card.division__c + '%\'' : '=null';     // 所属がなければ、NULLが条件
    }
    // 都道府県
    if (opt != null && opt.queryState && String.isNotBlank(card.address_pref__c)) { // 都道府県を使うで名刺の都道府県があるとき
      query += ' AND (BillingState=\'' + card.address_pref__c + '\' OR ShippingState=\'' + card.address_pref__c + '\')';
    }
    else if (opt != null && opt.queryState && String.isBlank(card.address_pref__c)) { // 都道府県を使うで名刺の都道府県がないとき
      query += ' AND (BillingState=null OR ShippingState=null)';
    }
    // 市区郡
    if (opt != null && opt.queryCity) {
      Map<String, String> addrs = SB_NameCard_Util.getAddress(card);
      String city = addrs.get('city');
      if (String.isNotBlank(city)) {
        query += ' AND (BillingCity=\'' + city + '\' OR ShippingCity=\'' + city + '\')';
      }
      else {
        query += ' AND (BillingCity=null OR ShippingCity=null)';
      }
    }
    // 郵便番号
    if (opt != null && opt.queryZip && String.isNotBlank(card.zip_code__c)) { //
      query += ' AND (BillingPostalCode=\'' + card.zip_code__c + '\' OR ShippingPostalCode=\'' + card.zip_code__c + '\')';
    }
    else if (opt != null && opt.queryZip && String.isBlank(card.zip_code__c)) { //
      query += ' AND (BillingPostalCode=null OR ShippingPostalCode=null)';
    }
    // アカウント レコードタイプ 条件
    if (acntRIds != null && !acntRIds.isEmpty()) {
      query += Test.isRunningTest() ? '' : ' AND RecordTypeId IN :acntRIds';
    }
    query +=' AND IsDeleted = false ORDER BY Name, LastModifiedDate DESC LIMIT 201';
    System.debug('++Account SOQL : '+ query);
    List<account> acnts = Database.query(query);  // SOQL
    for(Account acnt : acnts) {
      result.add(new AccountOption(acnt, result.size(), OPT_MATH));
    }
    addAltRegitOption(result, Account.sObjectType, true);
    return result;
  }

  // 名刺と取引先に該当する取引先責任者を取得
  @RemoteAction
  public static List<RegistOption> getContactOptions(Id cardId, Id accountId, QueryOption opt) {
    System.debug(opt);
    List<RegistOption> result = new List<RegistOption>();
    if (accountId !=null) {
      // アカウントが指定されてたとき
      // 名刺の検索
      NameCard__c card = getSimpleNameCard(cardId);
      Set<String> names = getContactNameSet(card);
      String accountName = SB_NameCard_Util.getCompanyName(card.company_name__c);

      String query = 'SELECT Id, Name, Owner.Name';
      for (QueryField f : contactFields) {
        query += ', ' + f.name;
      }
      query += ' FROM Contact WHERE AccountId = \'' + accountId + '\'';
      if (String.isNotBlank(card.email__c)) {
        // メアドがあれば、メアドからコンタクト取得
        query += ' AND email=\'' + card.email__c + '\'';
      }
      if (!names.isEmpty()) {
        // 2017.11.xx v1.20.3 メアド + 氏名 で コンタクトを抽出
        // SV_DEV-658 LEX画面 :取引先・取引先責任者に登録（個別登録）でメールアドレスのみで取引先責任者の候補が表示される
        query += ' AND Name LIKE :names';
      }
      // レコードタイプ名
      List<String> rids = null;
      if (opt != null && opt.contRecTypeIds !=null && !opt.contRecTypeIds.isEmpty()) {
        rids = new List<String>(opt.contRecTypeIds);
        query +=  Test.isRunningTest() ? '' : ' AND RecordTypeId IN :rids';
      }
      query +=' AND IsDeleted = false ORDER BY Name, LastModifiedDate DESC LIMIT 201';
      System.debug('++Contact SOQL : '+ query);
      List<Contact> conts = Database.query(query);  // SOQL
      for(Contact cont : conts) {
        result.add(new RegistOption(cont, result.size(), OPT_MATH));
      }
    }
    addAltRegitOption(result, Contact.sObjectType, accountId != null);
    return result;
  }

  //private static List<Account> getAccounts(List<SObject> acnts) {
  //  Set<Id> ids = new Set<Id>();
  //  for (SObject obj : acnts) {
  //    ids.add(obj.Id);
  //  }
  //  String query = 'SELECT Id, Name, Owner.Name';
  //  for (QueryField f : accountFields) {
  //    query += ', ' + f.name;
  //  }
  //  query += ', (SELECT Id FROM Contacts)';
  //  query += ', (SELECT Id FROM Opportunities)';
  //  query += ' FROM Account WHERE Id IN :ids';
  //  System.debug('++Account SOQL : '+ query);
  //  return Database.query(query);
  //}
  //@TestVisible
  //private static List<String> getNamesWithRecordTypes(Set<Id>ids, String obj_name, List<String> recTypes) {
  //  List<String> result = new List<String>();
  //  Set<Id> targetIds = new Set<Id>(ids);
  //  String oname =  obj_name;
  //  Set<String> targetRecTypeIds = new Set<String>(recTypes);
  //  String query = 'SELECT Id, Name FROM ' + obj_name + ' WHERE Id IN :targetIds AND RecordTypeId IN :targetRecTypeIds';
  //  List<SObject> objs  = Database.query(query);
  //  for (SObject obj : objs) {
  //    result.add((String)obj.get('Name'));
  //  }
  //  return result;
  //}


  // 指定のオブジェクトで最近参照したレコードのNameを返す 最大 100件
  @RemoteAction
  public static List<String> getRecentlyViewed(String obj_name, List<String> recTypes) {
    return SB_NameCard_SUtil.getRecentlyViewed(obj_name, recTypes);
    //List<String> result = new List<String>();
    //String oname =  obj_name;
    //List<AggregateResult> ars = [SELECT Id, Name, Type FROM RecentlyViewed WHERE Type = :oname Group by Id, Type, Name Order by Type, Name LIMIT 100];
    //if (ars.isEmpty()) {
    //  return result;
    //}
    //if (recTypes == null || recTypes.isEmpty()) {
    //  for (AggregateResult ar : ars) {
    //    result.add((String)ar.get('Name'));
    //  }
    //}
    //else {
    //  Set<Id> ids = new Set<Id>();
    //  for (AggregateResult ar : ars) {
    //    ids.add((Id)ar.get('Id'));
    //  }
    //  result.addAll(getNamesWithRecordTypes(ids, obj_name, recTypes));
    //}
    //return result;
  }

  // 指定したアカウントのコンタクトのNameを返す 最大 100件
  @RemoteAction
  public static List<String> getAccountContacts(Id accountId, List<String> recTypes) {
    List<String> result = new List<String>();
    Id aId = accountId;
    Set<String> recTypeIds = null;
    String query = 'SELECT Name FROM Contact WHERE AccountId = :aId';
    if (recTypes != null && recTypes.size() > 0) {
      recTypeIds = new Set<String>(recTypes);
      query += ' AND RecordTypeId IN :recTypeIds';
    }
    query += ' Group by Name Order by Name LIMIT 100';
    //List<AggregateResult> ars = [SELECT Name FROM Contact WHERE AccountId = :aId Group by Name Order by Name LIMIT 100];
    List<AggregateResult> ars = Database.query(query);
    for (AggregateResult ar : ars) {
      result.add((String)ar.get('Name'));
    }
    return result;
  }

  // SOSL で 取引先 を検索
  @RemoteAction
  public static List<RegistOption> searchAccount(String word, List<String> recTypes) {
    List<RegistOption> result = new List<RegistOption>();
    Set<String> recTypeIds = null;
    String searchWord = SB_NameCard_Util.escapeSOSLYoyakugo(word);
    String query ='FIND {' + searchWord + '} IN ALL FIELDS RETURNING Account(Id, Name, Owner.Name';
    for (QueryField f : accountFields) {
      query += ', ' + f.name;
    }
    if (recTypes != null && recTypes.size() > 0) {
      recTypeIds = new Set<String>(recTypes);
      query += ' WHERE RecordTypeId IN :recTypeIds';
    }
    query += ')';
    System.debug('++Account SOSL : '+ query);
    List<List<SObject>> searchList = search.query(query);
    if (searchList.isEmpty() == false && searchList[0].isEmpty() == false) {
      //List<Account> acnts = getAccounts(searchList[0]);
      for (SObject acnt : searchList[0]) {
        result.add(new AccountOption((Account)acnt, result.size(), OPT_SELECT));
      }
    }
    return result;
  }

  // SOSL で 取引先責任者 を検索
  @RemoteAction
  public static List<RegistOption> searchContact(String word, Id accountId, List<String> recTypes) {
    List<RegistOption> result = new List<RegistOption>();
    Id aId = accountId;
    Set<String> recTypeIds = null;
    String searchWord = SB_NameCard_Util.escapeSOSLYoyakugo(word);
    String query = 'FIND {' + searchWord + '} IN ALL FIELDS RETURNING Contact(Id, Name, Owner.Name';
    for (QueryField f : contactFields) {
      query += ', ' + f.name;
    }
    //query += ' WHERE AccountId =\'' + accountId + '\'';
    query += ' WHERE AccountId = :aId';
    if (recTypes != null && recTypes.size() > 0) {
      recTypeIds = new Set<String>(recTypes);
      query += ' AND RecordTypeId IN :recTypeIds';
    }
    query += ')';
    System.debug('++Contact SOSL : '+ query);
    List<List<sObject>> searchList = search.query(query);
    if (searchList.isEmpty() == false && searchList[0].isEmpty() == false) {
      for (SObject obj : searchList[0]) {
        result.add(new RegistOption(obj, result.size(), OPT_SELECT));
      }
    }
    return result;
  }

  //// +---- 登録 用　
  //// リクエスト
  //public class RegistRequestOld {
  //  public Id cardId { get; private set; }
  //  public RegistParamOld acntParam { get; private set; }
  //  public RegistParamOld contParam { get; private set; }
  //  public RegistRequestOld(Id cardId, RegistParamOld acntParam, RegistParamOld contParam) {
  //    this.cardId = cardId;
  //    this.acntParam = acntParam;
  //    this.contParam = contParam;
  //  }
  //}

  //public class RegistParamOld {
  //  public Id targetId { get; private set; }
  //  public Boolean overwrite { get; private set; }
  //  public Id recTypeId { get; private set; }
  //  public Boolean allowSave { get; private set; }      // 重複してても作成・更新する。
  //  public RegistParamOld(Id targetId, Boolean overwrite, Id recTypeId) {
  //    this.targetId = targetId;
  //    this.overwrite = overwrite;
  //    this.recTypeId = recTypeId;
  //  }
  //}

  //// レスポンス
  //public class RegistProcess {
  //  public Boolean success { get; private set; }
  //  public String error { get; private set; }
  //  public String errorObject { get; private set; }    // エラーのあったオブジェクト
  //  //public Boolean htmMsg { get; private set; }       // error が HTML タグを含むとき TRUE
  //  public Boolean allowRetry { get; private set; }    // 再試行を許可する場合 TRUE  重複エラーの場合にありえる。
  //  public Id cardId { get; private set; }
  //  public List<SB_NameCard_SaveResult.RecordInfo> dups { get; private set; }  // 重複した レコードのIDと名前
  //  public Account acnt { get; private set; }
  //  public Contact cont { get; private set; }
  //  RegistProcess() {
  //    success = false;
  //    //htmMsg = false;
  //    allowRetry = false;
  //    errorObject = null;
  //  }
  //  public void run(RegistRequestOld req) {
  //    NameCard__c card = getNameCardValues(req.cardId);
  //    cardId = card.Id;
  //    System.debug(' cardId : ' + cardId);
  //    Savepoint sp = null;
  //    SB_NameCard_SaveResult dbError = null;
  //    try {
  //      sp = Database.setSavepoint();
  //      Id acntId = req.acntParam.targetId;
  //      Id contId = req.contParam.targetId;
  //      // アカウント
  //      if (req.acntParam.targetId == null || (req.acntParam.targetId != null && req.acntParam.overwrite)) {
  //        // 新規作成 or 上書き 指定のとき
  //        acnt = (Account)createSObject(card, Account.sObjectType, req.acntParam);
  //        errorObject = 'Account';
  //        dbError = dbupsert(acnt, req.acntParam.allowSave);
  //        if (dbError.isError()) {
  //          throw new SB_NameCard_SRegistControllerException(Account.getSObjectType().getDescribe().getLabel()
  //                      + ': ' +  dbError.getDbErrorHolder(0).text);
  //        }
  //        errorObject = null;
  //        dbError = null;
  //        System.debug(' acnt : ' + acnt);
  //        acntId = acnt.Id;
  //      }
  //      List<Account> acnts = [SELECT Id, Name FROM Account WHERE Id =:acntId];
  //      if (acnts.isEmpty()) {
  //        throw new SB_NameCard_SRegistControllerException('Inbalid request Acount Id : ' + acntId);
  //      }
  //      acnt = acnts[0];
  //      // コンタクト
  //      if (req.contParam.targetId == null || (req.contParam.targetId != null && req.contParam.overwrite)) {
  //        // 新規作成 or 上書き 指定のとき
  //        cont = (Contact)createSObject(card, Contact.sObjectType, req.contParam);
  //        cont.AccountId = acnt.Id;  // アカウントID
  //        errorObject = 'Contact';
  //        dbError = dbupsert(cont, req.contParam.allowSave);
  //        if (dbError.isError()) {
  //          throw new SB_NameCard_SRegistControllerException(Contact.getSObjectType().getDescribe().getLabel()
  //                      + ': ' +  dbError.getDbErrorHolder(0).text);
  //        }
  //        errorObject = null;
  //        dbError = null;
  //        System.debug(' cont : ' + cont);
  //        contId = cont.Id;
  //      }
  //      List<Contact> conts = [SELECT Id, Name FROM Contact WHERE Id =:contId];
  //      if (conts.isEmpty()) {
  //        throw new SB_NameCard_SRegistControllerException('Inbalid request Contact Id : ' + contId);
  //      }
  //      cont = conts[0];
  //      // 名刺の更新
  //      card.account__c = req.acntParam.targetId != null ? req.acntParam.targetId : acnt.Id;
  //      card.contact__c = req.contParam.targetId != null ? req.contParam.targetId : cont.Id;
  //      //update card;
  //      errorObject = 'NameCard__c';
  //      List<NameCard__c> cards = new List<NameCard__c>();
  //      cards.add(card);
  //      SB_NameCard_CrudFls.supdate(cards, true);
  //      errorObject = null;
  //      success = true;
  //    }
  //    catch(Exception e) {
  //      if (sp != null) {
  //        Database.rollback(sp);
  //      }
  //      success = false;
  //      error = e.getMessage();
  //      if (dbError != null && dbError.isError()) {
  //        //htmMsg = dbError.isDuplicateError();
  //        allowRetry = dbError.isAllowSave();
  //        dups = ((SB_NameCard_SaveResult.DuplicateErrorHolder)dbError.getDbErrorHolder(0)).dups;
  //      }
  //    }
  //  }

  //  private SB_NameCard_SaveResult dbupsert(SObject obj, Boolean allowSave) {
  //    Database.DMLOptions dmlOptions = new Database.DMLOptions();
  //    dmlOptions.allowFieldTruncation = true;     // 文字列が長かったら詰める。
  //    dmlOptions.DuplicateRuleHeader.allowSave = allowSave;
  //    dmlOptions.DuplicateRuleHeader.runAsCurrentUser = true;
  //    List<Database.SaveResult> results = null;
  //    List<SObject> objs = new List<SObject>();
  //    if (obj.Id == null) {
  //      objs.add(obj);
  //      //result = Database.insert(obj, dmlOptions);
  //      results = SB_NameCard_CrudFls.screate(objs, dmlOptions);
  //    }
  //    else {
  //      objs.add(obj);
  //      //result = Database.update(obj, dmlOptions);
  //      results = SB_NameCard_CrudFls.supdate(objs, dmlOptions);
  //    }
  //    SB_NameCard_SaveResult dbError = new SB_NameCard_SaveResult();
  //    dbError.putSaveResults(results);
  //    //if (dbError.isError()) {
  //    //  String msg = obj.getSObjectType().getDescribe().getLabel() + ': ' +  dbError.getDbErrorHolder(0).msg;
  //    //  throw new SB_NameCard_SRegistControllerException(msg);
  //    //}
  //    return dbError;
  //  }
  //}   // RegistProcess

  //// DML結果のエラーメッセージの取得
  //@TestVisible
  //private static String getDMLErrorMsg(Database.Error[] errs) {
  //  String msg ='';
  //  for (Database.Error err : errs) {
  //    if (String.isNotBlank(msg) == true) msg += ', ';
  //    msg += err.getMessage();
  //  }
  //  return msg;
  //}

  //private static NameCard__c getNameCardValues(Id cardId) {
  //  String query = 'SELECT ';
  //  Set<String> fields = new Set<String>();
  //  fields.addAll(nc2account.keySet());     // アカウントに複写する項目
  //  fields.addAll(nc2contact.keySet());           // コンタクトに複写する項目
  //  // 会社名
  //  fields.add('company_name__c');
  //  // 住所用の項目
  //  fields.add('address__c');
  //  fields.add('address_eng__c');
  //  fields.add('address_bld__c');
  //  // 姓名用の項目
  //  fields.add('person_name_last__c');
  //  fields.add('person_name_first__c');
  //  fields.add('last_name__c');
  //  fields.add('first_name__c');
  //  //removeAddressLabel(fields);
  //  fields.remove('city');
  //  fields.remove('street');
  //  fields.remove('last_name');
  //  fields.remove('first_name');
  //  for (String f : fields) {
  //    query += f + ', ';
  //  }
  //  query = query.left(query.length()-2);
  //  query += ' FROM NameCard__c WHERE Id=\'' + cardId + '\' LIMIT 1';
  //  return Database.query(query);
  //}

  //private static SObject createSObject(NameCard__c card, SObjectType otype, RegistParamOld param) {
  //  SObject result = otype.newSObject(param.recTypeId, false);   //
  //  if (param.targetId == null && param.recTypeId != null) {
  //    result.put('RecordTypeId', param.recTypeId);      // newSObject で false だと 指定したレコードタイプが無効になるので。 2016.10.11
  //  }
  //  if (param.targetId != null) {
  //    // 既存レコード
  //    System.assert(param.targetId.getSObjectType() == otype);
  //    result.Id = param.targetId;
  //  }
  //  if (param.targetId ==null || param.overwrite) {
  //    // 新規か上書きのとき -> 項目のマッピング定義を取得
  //    Map<String, Set<String>> nc2target = obj2FieldMapping.get(otype);
  //    // 市区郡、町名・番地+建物
  //    Map<String, String> addrs = SB_NameCard_Util.getAddress(card);
  //    Map<String, String> names = SB_NameCard_Util.getPersonName(card);
  //    // Name の 省略時値をセットしとく  設定にあれば、おきかえる。
  //    //setDefaultName(result, card, names);
  //    //if (obj.getSObjectType() == Account.sObjectType) {
  //    //  obj.Name = card.company_name__c;
  //    //}
  //    for (String f : nc2target.keySet()) {
  //      Object val = null;
  //       // 住所 の項目
  //      if (f.equalsIgnoreCase('city') || f.equalsIgnoreCase('street')) {
  //        val = addrs.get(f);
  //      }
  //      // 姓名 の項目
  //      else if (f.equalsIgnoreCase('last_name') || f.equalsIgnoreCase('first_name')) {
  //        val = names.get(f);
  //      }
  //      else {
  //        val = card.get(f);
  //      }
  //      for (String t : nc2target.get(f)) {
  //        result.put(t, val);
  //      }
  //    }
  //  }
  //  return result;
  //}

  ///**
  //*
  //*  登録用メソッド
  //*
  //**/
  //@RemoteAction
  //public static RegistProcess registAccountContactOld(RegistRequestOld req) {
  //  System.debug(req.acntParam);
  //  System.debug(req.contParam);
  //  RegistProcess result = new RegistProcess();
  //  result.run(req);
  //  return result;
  //}

  /**
  *
  *  registAccountContact 登録用メソッド
  *  2018.01.xx v1.22 SV_DEV-435 S1の取引先･取引先責任者に登録のマッピングとLEX・Classicのマッピングを同じにします。
  *
  **/
  // リクエスト
  public class RegistRequest extends SB_NC_RegistExecutor.RegistRequest {
    public RegistRequest(List<RegistTarget> targets, RegistParam acntParam, RegistParam contParam, RegistParam someParam, TodoParam todoParam) {
      super(targets, acntParam, contParam, someParam, todoParam);
    }
  }
    //public virtual class RegistRequest {
    //  public List<RegistTarget> targets { get; private set; } // 対象のレコード達のID
    //  public RegistParam acntParam { get; private set; }      // アカウント登録のオプション
    //  public RegistParam contParam { get; private set; }
    //  public RegistParam someParam { get; private set; }
    //  public TodoParam todoParam { get; private set; }
  // 対象のオブジェクトIDたち  クライアント側で参照して値をセットする
  public class RegistTarget extends SB_NC_RegistExecutor.RegistTarget {
    public RegistTarget(Id cardId, Id acntId, Id contId, Id someId, Boolean createTodo, Date todoDate) {
      super(cardId, acntId, contId, someId, createTodo, todoDate);
    }
  }
    //public virtual class RegistTarget {
    //  public Id cardId { get; private set; }
    //  public Id acntId { get; private set; }
    //  public Id contId { get; private set; }
    //  public Id someId { get; private set; }
    //  public Boolean makeTodo { get; private set; }
    //  public Date todoDate { get; private set; }
  //　登録のオプション クライアント側で参照して値をセットする
  public class RegistParam extends SB_NC_RegistExecutor.RegistParam {
    public RegistParam(String objName, Boolean overwrite, Id recTypeId, Id ownerId, Boolean allowSave) {
      super(objName, overwrite, recTypeId, ownerId, allowSave);
    }
  }
    //public virtual class RegistParam {
    //  //public Id targetId { get; private set; }
    //  public String objName { get; private set; }
    //  public Boolean overwrite { get; private set; }
    //  public Id recTypeId { get; private set; }
    //  public Boolean allowSave { get; private set; }      // 重複してても作成・更新する。
    //  public Map<String, Object> filed2value { get; private set; }  // 特定の項目の値を指定してよこす リードの キャンペーンIDとか
  // 登録するToDo の内容
  public class TodoParam extends SB_NC_RegistExecutor.TodoParam {}
    //public virtual class TodoParam {
    //  public String subject { get; private set; }
    //  public Date activityDate { get; private set; }
    //  public String comment { get; private set; }

  @RemoteAction
  public static SB_NC_RegistExecutor.RegistResponse registAccountContact(RegistRequest req) {
    System.debug(req.acntParam);
    System.debug(req.contParam);
    return SB_NC_RegistExecutor.doRegist(req);
  }


} // class SB_NameCard_SRegistController