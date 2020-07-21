/**
 * SB_NCL_RegistOptionCreater
 *  v2.0.1 SB_NC_RegistOptionCreater の流用
 *  SmartVisca 取引先・取引先責任者へ登録 画面 で選択可能なオプションを調べて作るクラス
 *
 * Copyright (C) 2016 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2016.10.xx
 *  @Version 2      2017.06.xx getAccountOptions ,getContactOptions で クエリでエスケープしてなかったので修正
 *  @Version 3      2017.11.xx v1.20.3 メアド + 氏名 で コンタクトを抽出 SV_DEV-658 LEX画面 :取引先・取引先責任者に登録（個別登録）でメールアドレスのみで取引先責任者の候補が表示される
 *  @Version 4      2017.11.xx v1.20.4 SV_DEV-673 会社名に全角バックスラッシュが含まれる名刺を自動連携すると、ORA-01423.9エラーが発生
 *  @Version 5      2017.12.xx v1.22 コンタクトの検索条件で 姓 名 は　Nameでなく LastName FirstName を使う。
 *                  2018.02.xx v1.22 個別の取引先候補取得 getAccountOptions の LDV 対策
 *
 **/
public with sharing class SB_NCL_RegistOptionCreater {
  public class SB_NCL_RegistOptionCreaterException extends Exception {}

  // アカウント or コンタクト の対象は 既存のレコードか新規レコードか
  private static final Integer OPT_MATH = 1;    // 既存で名刺と一致してるアカウント or コンタクトレコードが対象
  private static final Integer OPT_SELECT = 2;    // 既存で選択してもらう アカウント or コンタクトレコードが対象
  private static final Integer OPT_NEW = 3;    // 新規で アカウント or コンタクトレコードが対象
  private static final Integer OPT_NOPE = 4;    //  一括登録のときの 登録しない

  //private static final Integer BULK_OPT_MATCH = 1;      // バルク登録のとき 既存アカウント/既存コンタクト
  //private static final Integer BULK_OPT_NEW_CONTACT = 2;   // バルク登録のとき 既存アカウント/新規コンタクト
  //private static final Integer BULK_OPT_NEW_PAIR = 3;    // バルク登録のとき  新規アカウント/新規コンタクト

  //public static SmartViscaf__SmartViscaConfig__c smartViscaConfig;
  // オブジェクトと表示ラベルのマップ
  private static Map<SObjectType, String> sobj2Label;

  static {
    //// smartViscaConfig
    //smartViscaConfig = SmartViscaf__SmartViscaConfig__c.getInstance(UserInfo.getUserId());   //  個人の設定
    //if (smartViscaConfig.Id ==null) {
    //    smartViscaConfig =  SmartViscaf__SmartViscaConfig__c.getInstance(UserInfo.getProfileId());   //プロファイルの設定
    //}
    //if (smartViscaConfig.id == null) {
    //  smartViscaConfig = SmartViscaf__SmartViscaConfig__c.getOrgDefaults();    // 組織の設定
    //}
    //if (smartViscaConfig.id == null) {
    //  smartViscaConfig.SmartViscaf__ToDo__c = false;   // ToDo登録する。
    //}
    // sobj2Label
    sobj2Label = new Map<SObjectType, String>();
    sobj2Label.put(Account.sObjectType, Account.getSObjectType().getDescribe().getLabel());
    sobj2Label.put(Contact.sObjectType, Contact.getSObjectType().getDescribe().getLabel());
    sobj2Label.put(Lead.sObjectType, Lead.getSObjectType().getDescribe().getLabel());
    sobj2Label.put(SmartViscaf__NameCard__c.sObjectType, SmartViscaf__NameCard__c.getSObjectType().getDescribe().getLabel());
  }

  private class QueryField {
    public String name { get; private set; }      // クエリする項目のAPI名
    public Integer summary { get; private set; }   // 要約部の表示の有無 1:要約部のみに表示 2:要約部とモーダル内両方表示  その他、-1とか:要約部に表示しない
    public QueryField(String s) {
      String[] ss = s.split(':\\s*');
      name = ss[0].toLowerCase();
      summary = ss.size() > 1 ? Integer.valueOf(ss[1]): -1;
    }
  }

  private static List<QueryField> createQueryFields(String source) {
    List<QueryField> result = new List<QueryField>();
    if (String.isNotBlank(source)) {
      String[] fields = source.split(',\\s*');
      for (String f : fields) {
        result.add(new QueryField(f));
      }
    }
    return result;
  }

  // 表示して欲しいアカウントの項目API名
  private static List<QueryField> accountFields {
    get {
      if (accountFields ==null) {
        accountFields = new List<QueryField>();
        List<QueryField>  tempList = new List<QueryField>();
        tempList = createQueryFields(SB_NameCardL_Util.smartViscaConfig.SmartViscaf__SRegistQueryAccountFields1__c);
        tempList.addAll(createQueryFields(SB_NameCardL_Util.smartViscaConfig.SmartViscaf__SRegistQueryAccountFields2__c));
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

  // 表示して欲しい取引先責任者の項目API名 暫定
  private static List<QueryField> contactFields {
    get {
      if (contactFields ==null) {
        contactFields = new List<QueryField>();
        List<QueryField>  tempList = new List<QueryField>();
        tempList = createQueryFields(SB_NameCardL_Util.smartViscaConfig.SmartViscaf__SRegistQueryContactFields1__c);
        tempList.addAll(createQueryFields(SB_NameCardL_Util.smartViscaConfig.SmartViscaf__SRegistQueryContactFields2__c));
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

  // 表示して欲しい取引先責任者の項目API名 暫定
  private static List<QueryField> leadFields {
    get {
      if (leadFields ==null) {
        leadFields = new List<QueryField>();
        List<QueryField>  tempList = new List<QueryField>();
        tempList = createQueryFields(SB_NameCardL_Util.smartViscaConfig.SRegistQueryLeadFields1__c);
        tempList.addAll(createQueryFields(SB_NameCardL_Util.smartViscaConfig.SRegistQueryLeadFields2__c));
        Set<String> tempSet = new Set<String>{'id', 'name'};     // 重複チェック用
        Map<String, Schema.SObjectField > fMap = Lead.sObjectType.getDescribe().fields.getMap();
        for (QueryField f : tempList) {
          if (tempSet.contains(f.name.toLowerCase())) continue;      // 重複してたらスキップ
          if (!fMap.containsKey(f.name.toLowerCase())) continue;     // API名不正ならスキップ
          if (!fMap.get(f.name.toLowerCase()).getDescribe().isAccessible()) continue; // 参照負荷ならスキップ
          leadFields.add(f);
          tempSet.add(f.name.toLowerCase());
        }
      }
      return leadFields;
    }
  }


  // オブジェクトと 表示して欲しい項目API名s のマッピング
  private static Map<SObjectType, List<QueryField>> sobj2Fields {
    get {
      if (sobj2Fields == null)  {
        sobj2Fields = new Map<SObjectType, List<QueryField>>();
        sobj2Fields.put(Account.sObjectType, accountFields);
        sobj2Fields.put(Contact.sObjectType, contactFields);
        sobj2Fields.put(Lead.sObjectType, leadFields);
      }
      return sobj2Fields;
    }
  }

  private static Set<String> getQueryFields(SObjectType otype) {
    Set<String> result = new Set<String>();
    for (QueryField f : sobj2Fields.get(otype)) {
      result.add(f.name);
    }
    return result;
  }


  private static final String USER_LANGUAGE = UserInfo.getLanguage().toLowerCase();
  // 端末での表示用に値を整形する
  private static Object getCanonicalValue(SObject obj, DescribeFieldResult dfr) {
    Object result = obj.get(dfr.getName());
    if (dfr.getName().containsIgnoreCase('PostalCode') && result != null) {
      result = (USER_LANGUAGE == 'ja' ?  '〒': '') + (String) result;
    }
    return result;
  }

  public class SfdcValue {
    public String key;      // api名
    public String label;    //  表示ラベル
    public Integer type;    //
    public Object value;    // 値
  }

  // Salesforce側の レコードの情報を転送するようのクラス
  public class SfdcRecord {
    public Id id;
    public String objName;
    public String name;
    //public Map<String, SfdcValue> values;   // api名 と
    public Map<String, Object> values;   // api名 と 値
    public SfdcRecord(SObject obj) {
      objName = obj.getSObjectType().getDescribe().getName();
      id = (Id)obj.get('Id');
      name = (String)obj.get('Name');
      values = obj.getPopulatedFieldsAsMap();
    }

  }

  //// 名刺に対応する既存レコードの情報
  //public class TargetRecotd {
  //  public Boolean selected;
  //  public Id ncId;
  //  public Integer acntOpt;       //
  //  public Integer contOpt;       //
  //  public String title;
  //  public SfdcRecord acnt;   // アカウント
  //  public SfdcRecord cont;   // コンタクト
  //  public SfdcRecord lead;   // リード
  //}

  // 一括登録の選択オプションに文字列として表示する項目
  private static final Map<SObjectType, List<String>> OBJ2OPTION_LABEL_FIELDS = new Map<SObjectType, List<String>> {
    Account.sObjectType => new List<String> {'site'},
    Contact.sObjectType => new List<String> {'department', 'email'},
    Lead.sObjectType => new List<String> {'company', 'title', 'email'}
  };

  // 一括登録の選択オプションに文字列として表示する項目 OBJ2OPTION_LABEL_FIELDS のうち アクセス権のあるもの
  // 2018.02.xx SV_DEV-780 LEX 取引先・取引先責任者に登録(個別登録)画面でSObject row was retrieved via SOQL without querying the requested field: Account.Siteエラー
  private static Map<SObjectType, List<String>> visibleLabelFields {
    get {
      if (visibleLabelFields == null) {
        visibleLabelFields = new Map<SObjectType, List<String>>();
        for (SObjectType otype: OBJ2OPTION_LABEL_FIELDS.keySet()) {
          Map<String, Schema.SObjectField > fMap = otype.getDescribe().fields.getMap();
          List<String> ff = new List<String>();
          for (String f : OBJ2OPTION_LABEL_FIELDS.get(otype)) {
            if (!fMap.get(f).getDescribe().isAccessible()) continue;
            ff.add(f);
          }
          visibleLabelFields.put(otype, ff);
        }
      }
      return visibleLabelFields;
    }
  }

  // レコードから 一括登録のSelect に表示するラベル を作る
  @TestVisible
  private static String makeLabel(SObject obj) {
    String result = (String)(obj.get('Name'));
    List<String> ff = visibleLabelFields.get(obj.getSObjectType());
    List<String> values = new List<String>();
    for (String f : ff) {
      Object val = obj.get(f);
      if (val != null) {
        values.add((String)val);
      }
    }
    if (!values.isEmpty()) {
      result += '(' + String.join(values, '/') + ')';
    }
    return result;
  }

  // 取引先責任者 の処理の 選択するオプション
  public virtual class RegistOption {
    public Id ncId;       // TODO!!!!
    public String optLabel;     // 一括登録のSelect に表示するラベル
    public Integer index { get; private set; }
    public Boolean selected { get; private set; }
    public Id id { get; private set; }
    public String otype { get; private set; }      // "Account", "Contact", "Lead"  lx 2.0
    public Integer type { get; private set; }
    public String title { get; private set; }      // Name とか 表示用の名称
    public String owner { get; private set; }      // 所有者
    public String info { get; private set; }
    public Map<String, Object> label2val { get; private set; }
    public List<Object> summary { get; private set; }
    public List<Object> values { get; private set; }
    RegistOption() {
      this.index = -1;
      this.selected = false;
    }
    // 一致したレコードを選択するとき
    RegistOption(SObject obj, Integer index, Integer type) {
      this.optLabel = makeLabel(obj);
      this.index = index;
      this.selected = false;
      this.id = obj.Id;
      this.otype = obj.Id.getSObjectType().getDescribe().getName();    // オブジェクトの名前 lx 2.0
      this.title = (String)obj.get('Name');
      SObject o = obj.getSObject('owner');
      this.owner = o != null ? (String)o.get('Name') : ''; // テストのき（だけ？）LEAD レコードの、Owner  がなくて、OwnerId になってる。
      this.info = null;
      this.type = type; // OPT_MATH, OPT_SELECT
      this.label2val = new Map<String, Object>();
      this.summary = new List<Object>();
      this.values = new List<Object>();
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
      //System.debug(this.values);
    }
    // 既存レコードを選択 or 新規追加する とき
    RegistOption(AltRegistOption opt, Integer index, SObjectType otype) {
      this.index = index;
      this.selected = false;
      this.id = null;
      this.otype = otype.getDescribe().getName();    // オブジェクトの名前   lx 2.0
      String olabel = '';
      if (otype != null) {
        olabel = sobj2Label.get(otype);   // オブジェクトの表示ラベル
      }
      this.title = String.format(opt.title_format, new String[]{olabel});
      this.optLabel = String.format('<{0}>', new String[]{this.title});
      this.info = String.format(opt.info_format, new String[]{olabel});
      this.type = opt.type;     // 2 or 3
    }
    // 初期選択状態にする用
    public void setSelected(Boolean b) {
      this.selected = b;
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
  }

  private static final String FORM_BULK_OPTION = '{0}({1})/{2}({3}/{4})';
  // 取引先/取引先責任者 の処理の 選択するオプション
  public class AccountContactsOption extends RegistOption {
    private SmartViscaf__NameCard__c card;
    public Contact cont { get; private set; }
    public List<RegistOption> contOptions { get; private set; }
    AccountContactsOption(SmartViscaf__NameCard__c card, Account acnt, Integer index) {
      super(acnt, index, OPT_MATH); //
      this.card = card;
      this.contOptions = new List<RegistOption>();
      // 取引先責任者
      this.cont = cont;
      //this.selected = card.SmartViscaf__account__c == acnt.Id;
    }
    public void addContact(Contact cont) {
      // 既存のコンタクトを追加
      RegistOption contOption = new RegistOption(cont, this.contOptions.size(), OPT_MATH);
      Boolean bAlready = (card.SmartViscaf__contact__c == cont.Id);   // 以前 登録したコンタクト？
      //contOption.setSelected(bSelected);
      if (this.contOptions.size() > 0 && bAlready) {   // 以前 登録したコンタクトだったら先頭に追加  あとで先頭を選択状態にする。
        this.contOptions.add(0, contOption);
      }
      else {
        this.contOptions.add(contOption);
      }
    }
    public void addNewOption() {
      // 新規のコンタクトを追加
      AltRegistOption alt = ALT_REGIST_OPTIONS.get(OPT_NEW);
      this.contOptions.add(new RegistOption(alt, this.contOptions.size(), Contact.sObjectType));
    }
    // 新規作成 / 新規作成
    AccountContactsOption(AltRegistOption opt, Integer index) {
      super(opt, index, Account.sObjectType);
      this.contOptions = new List<RegistOption>();
      this.contOptions.add(new RegistOption(opt, 0, Contact.sObjectType));
    }
    // 登録しない
    AccountContactsOption(Integer index) {
      this.index = index;
      this.selected = false;
      this.type = OPT_NOPE;
      this.title = Label.SB_NC_DontRegister;        // 登録しない
      this.info = Label.SB_NC_DontRegister;
      this.optLabel = Label.SB_NC_DontRegister;
    }
    // 登録しない 　会社名なし
    AccountContactsOption() {
      this.index = 0;
      this.selected = false;
      this.type = OPT_NOPE;
      this.title = Label.SB_NC_DontRegister_CompanyNameRequired;      // 登録しない(名刺の会社名、姓を設定してください)
      this.info = Label.SB_NC_DontRegister_CompanyNameRequired;
      this.optLabel = Label.SB_NC_DontRegister_CompanyNameRequired;
    }
  } //AccountContactsOption

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

  // 既存の上書き対象のレコードを探すオプション
  public virtual class QueryOption {
    public Integer registTarget;    // 登録先候補の表示状態 -1: 初期表示、0: 両方、1: アカウント、2:リード
                                    // -1 初期表示時のみ
                                    // → 取引先があれば、取引先のみ、リードがあってもださない ＝ 1。
                                    // → カスタム設定 リードまたは取引先に登録の際、ともに既存がない場合、リードのリストを表示(LeadRegist_DefaultShowLeadListNoExsiting__c)
                                    //   TRUEなら 両方がなければ、リードを出す。＝ 2
                                    //   FALSEなら 両方なければ、取引先を出す。＝ 1
    public Boolean bulkRegist;      // TURE:一括登録 FALSE:個別登録
    public Boolean querySite;      // 所属名を条件にして検索 0: 取引先名と所属名で検索 1,その他: 取引先名のみで検索
    public Boolean queryState;     // 都道府県を条件にして検索
    public Boolean queryCity;      // 市区郡を条件にして検索
    public Boolean queryZip;       // 郵便番号を条件にして検索
    public Boolean queryPersonName;   // lx 2.0
    public Boolean queryPersonEMail;      // lx 2.0
    public List<Id> parentIds;               // lx 2.0
    public List<String> acntRecTypeIds;  // アカウントのレコードタイプ名を条件にする
    public List<String> contRecTypeIds;  // コンタクトのレコードタイプ名を条件にする
    public List<String> leadRecTypeIds;  // lx 2.0 リードのレコードタイプ名を条件にする
    public QueryOption() {
      this.registTarget = -1;
      this.bulkRegist = false;
      this.querySite = false;
      this.queryState = false;
      this.queryCity = false;
      this.queryZip = false;
      this.queryPersonName = false;   // lx 2.0
      this.queryPersonEMail = true;  // lx 2.0
      this.parentIds = null; // lx 2.0
      this.acntRecTypeIds = null;
      this.contRecTypeIds = null;
      this.leadRecTypeIds = null;
    }
    public Boolean haveParents() {
      return this.parentIds != null && !this.parentIds.isEmpty();
    }
  }

  public class Card_RegistOption {
    //public SmartViscaf__NameCard__c card { get; private set; }
    SB_NCL_NameCardDTO card { get; private set; }
    public Boolean createTodo { get; private set; }
    public List<RegistOption> options { get; private set; }
    Card_RegistOption(SmartViscaf__NameCard__c card) {
      SmartViscaf__NameCardBasicSetting__c setting = SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting();
      //this.card = card;
      this.card = new SB_NCL_NameCardDTO();
      this.card.bindSimple(card);
      //this.createTodo = !smartViscaConfig.SmartViscaf__ToDo__c;   // ToDo登録する。
      this.createTodo = !setting.SmartViscaf__RegistNoToDo__c;     // 基本設定から 2017.06.xx
      this.options = new List<RegistOption>();
    }
    public void addRegistOption(AccountContactsOption opt) {
      Boolean bAlready = (opt.id != null && card.accountId == opt.id);   // 以前 登録したアカウント?
      if (options.size() > 0 && bAlready) {   // 以前 登録したアカウントだったら先頭にリストする。あとで先頭を選択状態にする。
        options.add(0, opt);
      }
      else {
        options.add(opt);
      }
    }
    // リストの先頭の組み合わせを初期選択する。 既に登録されてた場合は既に選択されているけど、同じ用に処理する。
    public void setDefaultSelet() {
      if (options == null || options.size() == 0) {
        return;
      }
      AccountContactsOption option = (AccountContactsOption)options.get(0);
      option.setSelected(true);
      if (option.contOptions == null || option.contOptions.size() == 0) {
        return;
      }
      RegistOption contOption = option.contOptions.get(0);
      contOption.setSelected(true);
    }
  }

  // アカウント、コンタクトの検索につかう名刺の項目を抽出するクラス
  private class CardValues {
    public Set<String> comps { get; private set;}    // 会社名
    public Set<String> depts { get; private set;}     // 所属
    public Set<String> fnames { get; private set;}    // 名 2017.12.xx v1.22
    public Set<String> lnames { get; private set;}    // 姓 2017.12.xx v1.22
    public Set<String> mails { get; private set;}    // メアド
    public Set<String> prefs { get; private set;}    // 都道府県
    public Set<String> cities { get; private set;}   // 市区郡
    public Set<String> zips { get; private set;}     // 郵便番号
    public Set<Id> acntIds { get; private set;}     //
    public Set<Id> contIds { get; private set;}     //
    public CardValues() {
      comps = new Set<String>();    // 会社名
      fnames = new Set<String>();
      lnames = new Set<String>();
      mails = new Set<String>();
      depts = new Set<String>();
      prefs = new Set<String>();
      cities = new Set<String>();
      zips = new Set<String>();
      acntIds = new Set<Id>();
      contIds = new Set<Id>();
    }
    public void build(List<SmartViscaf__NameCard__c> cards) {
      for (SmartViscaf__NameCard__c card : cards) {
        // 会社名
        // 2017.11.xx v1.20.4  SV_DEV-673 会社名に全角バックスラッシュが含まれる名刺を自動連携すると、ORA-01423.9エラーが発生
        String accountName = SmartViscaf.SB_NameCard_Util.getStringForPartialMatch(SmartViscaf.SB_NameCard_Util.getCompanyName(card.SmartViscaf__company_name__c));
        //accountName = accountName.replaceAll('\\\\', '__');
        if (String.isNotBlank(accountName)) {
          //comps.add('%' + String.escapeSingleQuotes(accountName) + '%');      // 2017.12.xx v1.22 スラッシュ2つ // が検索できないので、
          //if (accountName.contains('////')) {
          //  comps.add('%' + String.escapeSingleQuotes(accountName) + '%');      // 2017.12.xx v1.22 スラッシュ2つ // が検索できないので、
          //}
          //else {
            comps.add('%' + accountName + '%');      // 2017.12.xx v1.22 スラッシュ2つ // が検索できないので、
          //}
        }
        // 部署
        if (String.isNotBlank(card.SmartViscaf__division__c)) {
          // 2017.11.xx v1.20.4 SV_DEV-673 会社名に全角バックスラッシュが含まれる名刺を自動連携すると、ORA-01423.9エラーが発生
          String dept = SmartViscaf.SB_NameCard_Util.getStringForPartialMatch(card.SmartViscaf__division__c);
          depts.add('%' + dept + '%');
        }
        // 姓名
        Map<String, String> pnMap = SmartViscaf.SB_NameCard_Util.getPersonName(card);
        String last_name = pnMap.get('last_name');
        String first_name = pnMap.get('first_name');
        // 2017.12.xx
        lnames.add(last_name);    // 姓 NULLも入れてIN条件とする
        fnames.add(first_name);   // 名 NULLも入れてIN条件とする
        // mail 2017.12.xx NULLも入れてIN条件とする
        mails.add(card.SmartViscaf__email__c);
        // 都道府県
        if (String.isNotBlank(card.SmartViscaf__address_pref__c)) {
          prefs.add(card.SmartViscaf__address_pref__c);
        }
        // 市区郡
        if (String.isNotBlank(card.SmartViscaf__address__c)) {
          Map<String, String> addrs = SmartViscaf.SB_NameCard_Util.getAddress(card);
          String city = addrs.get('city');
          if (String.isNotBlank(city)) {
            cities.add(city);
          }
        }
        // 郵便番号
        if (String.isNotBlank(card.SmartViscaf__zip_code__c)) {
          zips.add(card.SmartViscaf__zip_code__c);
        }
        // アカウント
        if (card.SmartViscaf__account__c != null) {
          acntIds.add(card.SmartViscaf__account__c);
        }
        // コンタクト
        if (card.SmartViscaf__contact__c != null) {
          contIds.add(card.SmartViscaf__contact__c);   // 2017.12.xx v1.22
        }
      }
    }
  }

  private Boolean isMatchAccount(SmartViscaf__NameCard__c card, Account acnt, QueryOption opt) {
    String city = '';
    if (opt.queryCity) {
      Map<String, String> addrs = SmartViscaf.SB_NameCard_Util.getAddress(card);
      city = addrs.get('city');
    }
    String accountName = SmartViscaf.SB_NameCard_Util.getCompanyName(card.SmartViscaf__company_name__c); // v1.20 2017.06.xx
    //if (opt.queryZip && card.SmartViscaf__zip_code__c != acnt.BillingPostalCode && card.SmartViscaf__zip_code__c != acnt.ShippingPostalCode) {
    //  return false;
    //}
    //if (opt.queryCity && city != acnt.BillingCity && city != acnt.ShippingCity) {
    //  return false;
    //}
    //if (opt.queryState && card.SmartViscaf__address_pref__c != acnt.BillingState && card.SmartViscaf__address_pref__c != acnt.ShippingState) {
    //  return false;
    //}
    //if (opt.querySite && String.isNotBlank(acnt.Site) && !acnt.Site.contains(card.SmartViscaf__division__c))  {
    //  return false;
    //}
    //if (String.isNotBlank(card.SmartViscaf__company_name__c) && !acnt.Name.contains(card.SmartViscaf__company_name__c)) {
    //  return false;
    //}
    //return true;
    return
      (!opt.queryZip || card.SmartViscaf__zip_code__c == acnt.BillingPostalCode || card.SmartViscaf__zip_code__c == acnt.ShippingPostalCode) &&
      (!opt.queryCity || city == acnt.BillingCity || city == acnt.ShippingCity) &&
      (!opt.queryState || card.SmartViscaf__address_pref__c == acnt.BillingState || card.SmartViscaf__address_pref__c == acnt.ShippingState) &&
      (!opt.querySite || acnt.Site == card.SmartViscaf__division__c) &&      // containsだと 全角、半角を区別するので、区別しないように
      (card.SmartViscaf__company_name__c == acnt.Name || (String.isNotBlank(acnt.Name) && acnt.Name.contains(accountName))); // card.SmartViscaf__company_name__c -> accountName v1.20 2017.06.xx

    //return
    //  (!opt.queryZip || (String.isNotBlank(card.SmartViscaf__zip_code__c) && (card.SmartViscaf__zip_code__c == acnt.BillingPostalCode || card.SmartViscaf__zip_code__c == acnt.ShippingPostalCode))) &&
    //  (!opt.queryCity || (String.isNotBlank(city) && (city == acnt.BillingCity || city == acnt.ShippingCity))) &&
    //  (!opt.queryState || (String.isNotBlank(card.SmartViscaf__address_pref__c) && (card.SmartViscaf__address_pref__c == acnt.BillingState || card.SmartViscaf__address_pref__c == acnt.ShippingState))) &&
    //  (!opt.querySite || (String.isNotBlank(card.SmartViscaf__division__c) && String.isNotBlank(acnt.Site) && acnt.Site.contains(card.SmartViscaf__division__c))) &&
    //  (String.isNotBlank(card.SmartViscaf__company_name__c) && acnt.Name.contains(card.SmartViscaf__company_name__c));


  }

  private Boolean isMatchContact(SmartViscaf__NameCard__c card, Contact cont) {
    Map<String, String> pnMap = SmartViscaf.SB_NameCard_Util.getPersonName(card);
    String last_name = pnMap.get('last_name');
    String first_name = pnMap.get('first_name');
    return
      (String.isBlank(card.SmartViscaf__email__c) || card.SmartViscaf__email__c == cont.Email) &&
      (((String.isBlank(first_name) || first_name == cont.FirstName) &&  last_name == cont.LastName) ||
      cont.Name == (last_name + ' ' + first_name).trim());
  }

  // 名刺にアカウント、コンタクトを紐付け、選択可能な登録オプションを作成
  //  検索した アカウント-コンタクト から 名刺の条件にある ものを探して、名刺と関連付ける。
  private Card_RegistOption createCardRegistOption(SmartViscaf__NameCard__c card, List<Account> acnts, QueryOption opt) {
    Card_RegistOption result = new Card_RegistOption(card);
    DescribeSObjectResult dsrAccount = Account.getSObjectType().getDescribe();
    DescribeSObjectResult dsrContact = Contact.getSObjectType().getDescribe();
    Boolean alreadyRegisted = false;
    if (String.isNotBlank(card.SmartViscaf__company_name__c)) {
      // 名刺に会社名がある
      for (Account acnt : acnts) {
        if (!isMatchAccount(card, acnt, opt)) {
          continue;
        }
        AccountContactsOption reg_opt = new AccountContactsOption(card, acnt, result.options.size());
        result.addRegistOption(reg_opt);
        // 一致する既存アカウントがあった場合
        List<SObject> conts = acnt.Contacts;
        for (SObject cont : conts) {
          if (isMatchContact(card, (Contact)cont)) {
            // 一致する既存コンタクトがあった場合
            reg_opt.addContact((Contact)cont);
            //Boolean b = acnt.Id == card.SmartViscaf__account__c && cont.Id == card.SmartViscaf__contact__c;
            //reg_opt.setSelected(acnt.Id == card.SmartViscaf__account__c);
          }
        }
        // 既存アカウント/新規コンタクト
        if (dsrContact.isCreateable()) {  // 新規追加出来ないユーザでは 新規オプションはおくらない。
          reg_opt.addNewOption();     // <新規取引先責任者> オプション
        }
      }
      // 新規/新規
      if (dsrAccount.isCreateable() && dsrContact.isCreateable()) {  // 新規追加出来ないユーザでは 新規オプションは作らない。
        AccountContactsOption optNewPair = new AccountContactsOption(ALT_REGIST_OPTIONS.get(OPT_NEW), result.options.size());
        result.addRegistOption(optNewPair);
        //AccountContactsOption reg_opt = new AccountContactsOption(optNewPair, result.options.size());
        //result.addRegistOption(optNewPair);
      }
      // 登録しない
      AccountContactsOption optNope = new AccountContactsOption(result.options.size());
      result.addRegistOption(optNope);
      //for (RegistOption res : result.options) {
      //  System.debug('opt: ' + res);
      //}
    }
    else {
      // 名刺に会社名がない
      // 登録しない(名刺の会社名、姓を設定してください)
      AccountContactsOption optNope = new AccountContactsOption();
      result.addRegistOption(optNope);
    }
    // 初期選択状態の選択肢を作る。
    result.setDefaultSelet();

    //System.debug('NCID : ' + card.Id + ' Options : ' + result.options.size());
    //for (RegistOption res : result.options) {
    //  System.debug('opt: ' + res);
    //}
    return result;
  }

  private Set<String> getQueryFieldsSet(SObjectType otype) {
    Set<String> result = new Set<String>();
    List<QueryField> ff = sobj2Fields.get(otype);
    for(QueryField f : ff) {
      result.add(f.name);
    }
    result.add('id');
    result.add('name');
    if (otype == Contact.sObjectType) {
      String[] ss = CONT_FIELDS.split(', *');
      for (String s : ss) {
        result.add(s);
      }
    }
    return result;
  }

  private static final String CONT_FIELDS = 'firstname, lastname, email, accountid, account.name, department, owner.name, title';

  private String getQueryFieldsString(SObjectType otype) {
    String result = '';
    Set<String> ff = getQueryFieldsSet(otype);
    result = String.join(new List<String>(ff), ', ');
    //for (String f : ff) {
    //  result += f + ', ';
    //}
    //result = result.removeEnd(', ');
    return result;
  }

  private String getQueryFormat(SObjectType otype) {
    String result = 'SELECT ';
    if (otype == Account.sObjectType) {
      return ACCOUNT_QUERY;
    }
    else if (otype == Contact.sObjectType) {
      result += getQueryFieldsString(otype);
      result += ' FROM Contacts WHERE ({0}) {1}';
    }
    return result;
  }

  //
  private static final String ACCOUNT_QUERY = 'SELECT Id, Name, Owner.Name, {0}, ({1}), ({2}) FROM Account WHERE ({3}) {4} ORDER BY Id LIMIT 10000';
  //private static final String CONTACTS_REL_QUERY = 'SELECT Id, Name, FirstName, LastName, Email, AccountId, Account.Name, Department, Owner.Name, Title FROM Contacts WHERE ({0}) {1}';
  private static final String OPO_REL_QUERY = 'SELECT Id, Name, AccountId, Account.Name FROM Opportunities';

  @TestVisible
  private List<Account> getAccounts(List<SmartViscaf__NameCard__c> cards, QueryOption opt) {
    // 検索に使う名刺の値たちを取得
    CardValues cardValues = new CardValues();
    cardValues.build(cards);
    Set<String> comps, depts, prefs, cities, zips;
    Set<String> fnames, lnames, mails;
    Set<Id> acntIds;  // 名刺からアカウント への参照
    Set<Id> contIds;  // 名刺からコンタクト への参照 今までなかったよ。。
    // アカウントのレコードタイプ 条件
    List<String> acntRIds = null;
    if (opt != null && opt.acntRecTypeIds !=null && !opt.acntRecTypeIds.isEmpty()) {
      acntRIds = new List<String>(opt.acntRecTypeIds);
    }
    // コンタクトのレコードタイプ 条件
    List<String> contRIds = null;
    if (opt != null && opt.contRecTypeIds !=null && !opt.contRecTypeIds.isEmpty()) {
      contRIds = new List<String>(opt.contRecTypeIds);
    }
    // 検索条件
    String query;
    String acntF = '';       // 取得するアカウントの項目
    String queryC = '';      // コンタクトへのリレーションクエリ
    String queryO = '';      //　商談へのリレーションクエリ
    String condition = '';   // アカウント検索条件
    String refId = '';       // アカウント参照してるID
    Set<String> fields = new Set<String>();
    for (QueryField f : accountFields) {
      fields.add(f.name);
    }
    fields.add('site');
    fields.add('billingstate');
    fields.add('shippingstate');
    fields.add('billingcity');
    fields.add('shippingcity');
    fields.add('billingpostalcode');
    fields.add('shippingpostalcode');
    acntF = String.join(new List<String>(fields), ', ');
    //for (String f : fields) {
    //  acntF += f + ', ';
    //}
    //acntF = acntF.removeEnd(', ');

    // コンタクトのクエリ
    {
      //String c0 = '';
      List<String> conds0 = new List<String>();
      String c1 = '';
      //　メアド
      mails = new Set<String>(cardValues.mails);
      conds0.add('email IN :mails');
      // 姓
      lnames = new Set<String>(cardValues.lnames);
      conds0.add('LastName IN :lnames');
      // 名
      fnames = new Set<String>(cardValues.fnames);
      conds0.add('FirstName IN :fnames');
      // コンタクト の レコードタイプ
      if (contRIds != null && !contRIds.isEmpty()) {
        conds0.add('RecordTypeId IN :contRIds');
      }
      // 名刺参照先コンタクト
      if (!cardValues.contIds.isEmpty()) {
        contIds = new Set<Id>(cardValues.contIds);
        c1 = 'OR Id IN :contIds';   // 2017.12.28 修正
      }
      String cForm = getQueryFormat(Contact.SObjectType);
      queryC += String.format(cForm, new String[] { String.join(conds0, ' AND '), c1 });
    }
    // 商談のクエリ
    {
      queryO = OPO_REL_QUERY;
    }
    comps = new Set<String> (cardValues.comps);
    // 会社名
    condition = 'Name LIKE :comps'; //, RecordTypeId, RcordType.Name)';
    // 所属
    if (opt != null && opt.querySite && !cardValues.depts.isEmpty()) {    // 所属を使う
      depts = new Set<String> (cardValues.depts);
      condition += ' AND Site LIKE :depts';
    }
    // 都道府県
    if (opt != null && opt.queryState && !cardValues.prefs.isEmpty()) { // 都道府県を使うで名刺の都道府県があるとき
      prefs = new Set<String> (cardValues.prefs);
      condition += ' AND (BillingState IN :prefs OR ShippingState IN :prefs)';
    }
    // 市区郡
    if (opt != null && opt.queryCity && !cardValues.cities.isEmpty()) {
      cities = new Set<String> (cardValues.cities);
      condition += ' AND (BillingCity IN :cities OR ShippingCity IN :cities)';
    }
    // 郵便番号
    if (opt != null && opt.queryZip && !cardValues.zips.isEmpty()) {
      zips = new Set<String> (cardValues.zips);
      condition += ' AND (BillingPostalCode IN :zips OR ShippingPostalCode IN :zips)';
    }
    // アカウント レコードタイプ 条件
    if (acntRIds != null && !acntRIds.isEmpty()) {
      condition += Test.isRunningTest() ? '' : ' AND RecordTypeId IN :acntRIds';
    }
    // 名刺参照先アカウント
    if (!cardValues.acntIds.isEmpty()) {
      acntIds = new Set<Id>(cardValues.acntIds);
      refId = 'OR Id IN :acntIds';
    }
    query = String.format(ACCOUNT_QUERY, new String[] {acntF, queryC, queryO, condition, refId});
    System.debug('++Account SOQL : '+ query);
    List<account> acnts = Database.query(query);  // SOQL
    System.debug('++Match Account : '+ acnts.size());
    return acnts;
  }


  //// 複数の名刺レコードに対して既存リードの候補を収集 lx 2.0
  //private List<Account> getAccounts(Set<Id> cardIds, QueryOption opt) {
  //  SB_NameCardL_RegistQueryExecutor qex = SB_NameCardL_RegistQueryExecutor.getInstance();
  //  if (!qex.isInitialized() || qex.needRefresh(cardIds)) {
  //    // 初クエリ or 名刺セット変更
  //    qex.init(cardIds);
  //  }

  //  SB_NameCardL_RegistQueryOption qo = SB_NameCardL_RegistQueryOption.convertQueryOption(Account.sObjectType, opt);
  //  SB_NameCardL_RegistQueryStrategy.QueryStrategy qs = SB_NameCardL_RegistQueryStrategy.createQueryStrategy(qo);
  //  Set<String> fields = new Set<String>();
  //  for (QueryField f : accountFields) {
  //    fields.add(f.name);
  //  }
  //  qs.addQueryFields(fields);
  //  return qex.getCandidateRecords(qs);
  //}

  //// 1つの名刺レコードに対して既存リードの候補を収集 lx 2.0
  //private List<Account> getAccounts(Id cardId, QueryOption opt) {
  //  Set<Id> ids = new Set<Id> { cardId };
  //  return getAccounts(ids, opt);
  //}


  //// 複数の名刺レコードに対して既存リードの候補を収集 lx 2.0
  //private List<Lead> getLeads(Set<Id> cardIds, QueryOption opt) {
  //  SB_NameCardL_RegistQueryExecutor qex = SB_NameCardL_RegistQueryExecutor.getInstance();
  //  if (!qex.isInitialized() || qex.needRefresh(cardIds)) {
  //    // 初クエリ or 名刺セット変更
  //    qex.init(cardIds);
  //  }

  //  SB_NameCardL_RegistQueryOption qo = SB_NameCardL_RegistQueryOption.convertQueryOption(Lead.sObjectType, opt);
  //  SB_NameCardL_RegistQueryStrategy.QueryStrategy qs = SB_NameCardL_RegistQueryStrategy.createQueryStrategy(qo);
  //  Set<String> fields = new Set<String>();
  //  for (QueryField f : leadFields) {
  //    fields.add(f.name);
  //  }
  //  qs.addQueryFields(fields);
  //  return qex.getCandidateRecords(qs);
  //}

  //// 1つの名刺レコードに対して既存リードの候補を収集 lx 2.0
  //private List<Lead> getLeads(Id cardId, QueryOption opt) {
  //  Set<Id> ids = new Set<Id> { cardId };
  //  return getLeads(ids, opt);
  //}


  //// アカウント、コンタクトの名前の条件
  //@TestVisible
  //private static void getCardValues(List<SmartViscaf__NameCard__c> cards, Set<String>companies, Set<String> names, Set<String> mails) {
  //  for (SmartViscaf__NameCard__c card : cards) {
  //    // 姓名
  //    Map<String, String> pnMap = SmartViscaf.SB_NameCard_Util.getPersonName(card);
  //    String last_name = pnMap.get('last_name');
  //    String first_name = pnMap.get('first_name');
  //    if (String.isNotEmpty(last_name) && String.isNotEmpty(first_name)) {
  //      names.add(last_name + ' ' + first_name);
  //    }
  //    else if (String.isNotEmpty(last_name)) {
  //      names.add(last_name);
  //      names.add(last_name + '%');
  //    }
  //    // mail
  //    mails.add(card.SmartViscaf__email__c);
  //    // 会社名
  //    String accountName = SmartViscaf.SB_NameCard_Util.getCompanyName(card.SmartViscaf__company_name__c);
  //    if (String.isNotBlank(accountName)) {
  //      companies.add('%' + accountName + '%');
  //    }
  //  }
  //}

  @TestVisible
  private List<SmartViscaf__NameCard__c> getNameCardsSimpleFields(List<Id> targetIds) {
    //Map<Id, SObject> result = null;
    System.debug('getNameCardsSimpleFields targetIds.size(): ' + targetIds.size());
    Set<Id> ids = new Set<Id>(targetIds);
    String query = 'SELECT ' + SB_NCL_NameCardDTO.NC_QUERY_SIMPLE_FIELDS + ' FROM SmartViscaf__NameCard__c WHERE Id IN :ids';
    //result = new  Map<Id,SObject>(Database.query(query));
    List<SmartViscaf__NameCard__c> result = Database.query(query);
    return result;
  }

  //// アカウント、コンタクトを検索するときに必要な名刺データをクエリ
  //@TestVisible
  //private static SmartViscaf__NameCard__c getNameCardSimpleFields(Id targetId) {
  //  Id id = targetId;
  //  String query = 'SELECT ' + SB_NCL_NameCardDTO.NC_QUERY_SIMPLE_FIELDS + ' FROM SmartViscaf__NameCard__c WHERE Id = :id';
  //  //result = new  Map<Id,SObject>(Database.query(query));
  //  List<SmartViscaf__NameCard__c> cards = Database.query(query);
  //  if (cards.isEmpty()) {
  //    throw new SB_NCL_RegistOptionCreaterException(Label.SB_MSG_IllegalRequest + 'Id : ' + targetId);
  //  }
  //  return cards[0];
  //}

  /*
  *  getRegistOptions
  *   名刺単位の選択可能なオプションを返す。 一括登録用
  *
  */
  //public List<Card_RegistOption> getRegistOptions(List<Id> ncIds, SB_NC_AccountBulkRegistController.QueryOption opt) {
  public List<Card_RegistOption> getRegistOptions(List<Id> cardIds, QueryOption opt) {
    List<Card_RegistOption> result = new List<Card_RegistOption>();
    Map<Id, Card_RegistOption> card2Option = new Map<Id, Card_RegistOption>();
    // 選択されてる　名刺について値を抽出
    List<SmartViscaf__NameCard__c> cards = getNameCardsSimpleFields(cardIds);
    // 該当するアカウントを抽出
    List<Account> acnts = getAccounts(cards, opt);
    // 名刺にアカウント、コンタクトを紐付け、選択可能な登録オプションを作成
    for (SmartViscaf__NameCard__c card : cards) {
      Card_RegistOption reg_opt = createCardRegistOption(card, acnts, opt);
      card2Option.put(card.Id, reg_opt);
    }
    // リストの順に並び替え
    for (Id ncId : cardIds) {
      result.add(card2Option.get(ncId));
      System.debug('Card_RegistOption options: ' + card2Option.get(ncId).options);
    }
    return result;
  }


  //// 取引先責任者の名前の条件
  //@TestVisible
  //private static Set<String> getContactNameSet(SmartViscaf__NameCard__c card) {
  //  Set<String> result = new Set<String>();
  //  Map<String, String> pnMap = SmartViscaf.SB_NameCard_Util.getPersonName(card);
  //  String last_name = pnMap.get('last_name');
  //  String first_name = pnMap.get('first_name');
  //  if (String.isNotEmpty(last_name) && String.isNotEmpty(first_name)) {
  //    result.add(last_name + ' ' + first_name);
  //  }
  //  else if (String.isNotEmpty(last_name)) {
  //    result.add(last_name);
  //    result.add(last_name + '%');
  //  }
  //  return result;
  //}

  // 検索結果以外の アカウント、コンタクト 更新、追加の オプションを 追加
  //   enableLookup その他を選択して更新 が可能か アカウント新規作成の場合はない。
  private static void addAltRegitOption(List<RegistOption> opt, SObjectType otype, Boolean enableLookup) {
    AltRegistOption alt = null;
    if (enableLookup) {  // アカウントを選ばれてないとコンタクトは選択できないの
      alt = ALT_REGIST_OPTIONS.get(OPT_SELECT);      // その他を更新
      opt.add(new RegistOption(alt, opt.size(), otype));
    }
    DescribeSObjectResult dsr = otype.getDescribe();
    if (dsr.isCreateable()) {  // 新規追加出来ないユーザでは 新規オプションは作らない。
      alt = ALT_REGIST_OPTIONS.get(OPT_NEW);      // 新規追加
      opt.add(new RegistOption(alt, opt.size(), otype));
    }
  }

  //// getAccountOptions での コンタクトへのサブクエリの文字列取得
  //private static String getContactSubQuery(Set<String> names, String email, Set<String> contRIds, Id contId) {
  //  String result = '';
  //  // コンタクトのクエリ
  //  if (String.isNotBlank(email)) {
  //    // メアドがあれば、メアドからコンタクト取得 メアドが一致していればOK
  //    result = 'Email=:email';
  //  }
  //  else if (!names.isEmpty()) {
  //    // メアドがなくて、姓名があれば、姓名からコンタクト取得
  //    result = 'Name LIKE :names';
  //  }
  //  if (contRIds != null && !contRIds.isEmpty() && !Test.isRunningTest()) {
  //    result += ' AND RecordTypeId IN :contRIds';
  //  }
  //  if (String.isNotBlank(contId)) {
  //    result = '(' + result + ') OR Id=:contId';
  //  }
  //  result = '(SELECT Id FROM Contacts WHERE ' + result + ')';
  //  return result;
  //}

  //// getAccountOptions での WHERE句 の文字列取得
  //private static String getAccountCondition(SmartViscaf__NameCard__c card, Set<String> acntRIds, QueryOption opt, Boolean partial) {
  //  List<String> conds = new List<String>();  //
  //  //List<String> conds = new List<String>();  //
  //  // 会社名
  //  if (String.isNotBlank(card.SmartViscaf__company_name__c)) {
  //    if (partial) {
  //      // 部分一致
  //      // 2017.11.xx v1.20.4 SV_DEV-673 会社名に全角バックスラッシュが含まれる名刺を自動連携すると、ORA-01423.9エラーが発生
  //      String accountName = SmartViscaf.SB_NameCard_Util.getStringForPartialMatch(SmartViscaf.SB_NameCard_Util.getCompanyName(card.SmartViscaf__company_name__c));     // 法人格抜き社名 検索用エスケープ
  //      conds.add('Name LIKE \'%' + String.escapeSingleQuotes(accountName) + '%\'');
  //    }
  //    else {
  //      String accountName = SmartViscaf.SB_NameCard_Util.getStringForPartialMatch(card.SmartViscaf__company_name__c);     // 社名 検索用エスケープ
  //      conds.add('Name = \'' + String.escapeSingleQuotes(accountName) + '\'');
  //    }
  //  }
  //  else {
  //    conds.add('Name = null');
  //  }
  //  // 所属
  //  if (opt != null && opt.querySite) {    // 所属を使う
  //    if (String.isNotBlank(card.SmartViscaf__division__c)) {
  //      if (partial) {
  //      // 部分一致
  //        String dept = SmartViscaf.SB_NameCard_Util.getStringForPartialMatch(card.SmartViscaf__division__c);     // 部署名 検索用エスケープ
  //        conds.add('Site LIKE \'%' + dept + '%\'');
  //      }
  //      else {
  //        conds.add('Site = \'' + card.SmartViscaf__division__c + '\'');
  //      }
  //    }
  //    else {
  //      conds.add('Site = null');
  //    }
  //  }
  //  // 都道府県
  //  if (opt != null && opt.queryState) {
  //    if (String.isNotBlank(card.SmartViscaf__address_pref__c)) { // 名刺の都道府県があるとき
  //      conds.add('(BillingState=\'' + String.escapeSingleQuotes(card.SmartViscaf__address_pref__c)
  //                + '\' OR ShippingState=\'' + String.escapeSingleQuotes(card.SmartViscaf__address_pref__c) + '\')');
  //    }
  //    else {
  //      conds.add('(BillingState=null OR ShippingState=null)');
  //    }
  //  }
  //  // 市区郡
  //  if (opt != null && opt.queryCity) {
  //    Map<String, String> addrs = SmartViscaf.SB_NameCard_Util.getAddress(card);
  //    String city = addrs.get('city');
  //    if (String.isNotBlank(city)) {  // 名刺に市区郡がある
  //      conds.add('(BillingCity=\'' + String.escapeSingleQuotes(city) + '\' OR ShippingCity=\'' + String.escapeSingleQuotes(city) + '\')');
  //    }
  //    else {
  //      conds.add('(BillingCity=null OR ShippingCity=null)');
  //    }
  //  }
  //  // 郵便番号
  //  if (opt != null && opt.queryZip) {
  //    if (String.isNotBlank(card.SmartViscaf__zip_code__c)) {  // 名刺に郵便番号がある
  //      conds.add('(BillingPostalCode=\'' + String.escapeSingleQuotes(card.SmartViscaf__zip_code__c)
  //              + '\' OR ShippingPostalCode=\'' + String.escapeSingleQuotes(card.SmartViscaf__zip_code__c) + '\')');
  //    }
  //    else {
  //      conds.add('(BillingPostalCode=null OR ShippingPostalCode=null)');
  //    }
  //  }
  //  // アカウント レコードタイプ 条件
  //  if (acntRIds != null && !acntRIds.isEmpty() && !Test.isRunningTest()) {   // テストのときは つかわない
  //    conds.add('RecordTypeId IN :acntRIds');
  //  }
  //  return String.join(conds, ' AND ');
  //}

  ////////////////////////////////////////
  // Wizard 形式用の 登録先候補作るくんたち
  ////////////////////////////////////////
  private interface OptionListBuilder {
    List<RegistOption> run(Id cardId, QueryOption opt);
  }

  // Wizard 形式 1st step アカウントだけで登録先候補作る
  private class AccountOptionListBuilder implements OptionListBuilder {
    public List<RegistOption> run(Id cardId, QueryOption opt) {
      List<RegistOption> result = new List<RegistOption>();
      // 1. 検索の準備
      SB_NameCardL_RegistQueryOption qo = SB_NameCardL_RegistQueryOption.convertQueryOption(Account.sObjectType, opt);
      // 2. 検索
      SB_NameCardL_RegistCanPickerAbstract picker = new SB_NameCardL_RegistSoqlCountCanPicker();
      picker.init(qo);
      picker.addQueryFields(Account.sObjectType, getQueryFields(Account.sObjectType));
      Map<SObjectType, List<SObject>> otype2objs = picker.create(cardId);
      // 3. 検索結果から、候補リストを作る
      for (SObject obj : otype2objs.get(Account.sObjectType)) {
        // 既存のアカウント
        result.add(new AccountOption((Account)obj, result.size(), OPT_MATH));
      }
      // アカウントその他ルックアップ、新規追加
      addAltRegitOption(result, Account.sObjectType, true);
      return result;
    }
  }

  // Wizard 形式 1st step リードだけで登録先候補作る
  private class LeadOptionListBuilder implements OptionListBuilder {
    public List<RegistOption> run(Id cardId, QueryOption opt) {
      List<RegistOption> result = new List<RegistOption>();
      // 1. 検索の準備
      SB_NameCardL_RegistQueryOption qo = SB_NameCardL_RegistQueryOption.convertQueryOption(Lead.sObjectType, opt);
      // 2. 検索
      SB_NameCardL_RegistCanPickerAbstract picker = new SB_NameCardL_RegistSoqlCountCanPicker();
      picker.init(qo);
      picker.addQueryFields(Lead.sObjectType, getQueryFields(Lead.sObjectType));
      Map<SObjectType, List<SObject>> otype2objs = picker.create(cardId);
      // 3. 検索結果から、候補リストを作る
      for (SObject obj : otype2objs.get(Lead.sObjectType)) {
        // 既存のアカウント
        result.add(new RegistOption(obj, result.size(), OPT_MATH));
      }
      // アカウントその他ルックアップ、新規追加
      addAltRegitOption(result, Lead.sObjectType, true);
      return result;
    }
  }

  // Wizard 形式 1st step アカウントとリードで登録先候補作る
  private class AccountLeadOptionListBuilder implements OptionListBuilder {
    public List<RegistOption> run(Id cardId, QueryOption opt) {
      List<RegistOption> result = new List<RegistOption>();
      // 1. 検索の準備
      List<SB_NameCardL_RegistQueryOption> queryOptions = new List<SB_NameCardL_RegistQueryOption>();
      queryOptions.add(SB_NameCardL_RegistQueryOption.convertQueryOption(Account.sObjectType, opt));
      queryOptions.add(SB_NameCardL_RegistQueryOption.convertQueryOption(Lead.sObjectType, opt));
      // 2. 検索
      SB_NameCardL_RegistCanPickerAbstract picker = new SB_NameCardL_RegistSoqlCountCanPicker();
      picker.init(queryOptions);
      picker.addQueryFields(Account.sObjectType, getQueryFields(Account.sObjectType));
      picker.addQueryFields(Lead.sObjectType, getQueryFields(Lead.sObjectType));
      Map<SObjectType, List<SObject>> otype2objs = picker.create(cardId);
      // 3. 検索結果から、候補リストを作る
      // 3.1 リードを入れる。
      for (SObject obj : otype2objs.get(Lead.sObjectType)) {
        // 既存のリード
        result.add(new RegistOption(obj, result.size(), OPT_MATH));
      }
      // リードその他ルックアップ、新規追加
      addAltRegitOption(result, Lead.sObjectType, true);
      // 3.2 アカウントを入れる。
      for (SObject obj : otype2objs.get(Account.sObjectType)) {
        // 既存のアカウント
        result.add(new AccountOption((Account)obj, result.size(), OPT_MATH));
      }
      // アカウントその他ルックアップ、新規追加
      addAltRegitOption(result, Account.sObjectType, true);
      return result;
    }
  }
  // Wizard 形式 1st step アカウントとリードを対象に検索して、アカウントを優先で登録先候補作る
  // LEX 個別の 初期表示 既存アカウントがあればアカウントで、アカウントなくリードあればリードで、両方なければ設定によりどちらか一方
  private class AccountYusenOptionListBuilder implements OptionListBuilder {
    public List<RegistOption> run(Id cardId, QueryOption opt) {
      List<RegistOption> result = new List<RegistOption>();
      // 1. 検索の準備
      List<SB_NameCardL_RegistQueryOption> queryOptions = new List<SB_NameCardL_RegistQueryOption>();
      queryOptions.add(SB_NameCardL_RegistQueryOption.convertQueryOption(Account.sObjectType, opt));
      queryOptions.add(SB_NameCardL_RegistQueryOption.convertQueryOption(Lead.sObjectType, opt));
      // 2. 検索
      SB_NameCardL_RegistCanPickerAbstract picker = new SB_NameCardL_RegistSoqlCountCanPicker();
      picker.init(queryOptions);
      picker.addQueryFields(Account.sObjectType, getQueryFields(Account.sObjectType));
      picker.addQueryFields(Lead.sObjectType, getQueryFields(Lead.sObjectType));
      Map<SObjectType, List<SObject>> otype2objs = picker.create(cardId);
      // 3. 検索結果から、候補リストを作る
      // アカウントがあればアカウントのみ
      if (!otype2objs.get(Account.sObjectType).isEmpty()) {
        // アカウントがあった
        for (SObject obj : otype2objs.get(Account.sObjectType)) {
          // 既存のアカウント
          result.add(new AccountOption((Account)obj, result.size(), OPT_MATH));
        }
        // アカウントその他ルックアップ、新規追加
        addAltRegitOption(result, Account.sObjectType, true);
      }
      else if (!otype2objs.get(Lead.sObjectType).isEmpty()) {
        // アカウントなくて リードがあった
        for (SObject obj : otype2objs.get(Lead.sObjectType)) {
          // 既存のリード
          result.add(new RegistOption(obj, result.size(), OPT_MATH));
        }
        // リードその他ルックアップ、新規追加
        addAltRegitOption(result, Lead.sObjectType, true);
      }
      else {
        // アカウント、リードともなかった。
        if (SB_NameCardL_Util.smartViscaConfig.LeadRegist_DefaultShowLeadListNoExsiting__c)  {
          // カスタム設定 リードまたは取引先に登録の際、ともに既存がない場合、リードのリストを表示
          // リードその他ルックアップ、新規追加
          addAltRegitOption(result, Lead.sObjectType, true);
        }
        else {
          // アカウントその他ルックアップ、新規追加
          addAltRegitOption(result, Account.sObjectType, true);
        }
      }
      return result;
    }
  }

  // Wizard 形式 2st step コンタクトの登録先候補作る
  private class ContactOptionListBuilder implements OptionListBuilder {
    public List<RegistOption> run(Id cardId, QueryOption opt) {
      List<RegistOption> result = new List<RegistOption>();
      if (opt.haveParents()) {
        // 1. 検索の準備
        SB_NameCardL_RegistQueryOption qo = SB_NameCardL_RegistQueryOption.convertQueryOption(Contact.sObjectType, opt);
        // 2. 検索
        SB_NameCardL_RegistCanPickerAbstract picker = new SB_NameCardL_RegistSoqlCountCanPicker();
        picker.init(qo);
        picker.addQueryFields(Contact.sObjectType, getQueryFields(Contact.sObjectType));
        Map<SObjectType, List<SObject>> otype2objs = picker.create(cardId);
        // 3. 検索結果から、候補リストを作る
        for (SObject obj : otype2objs.get(Contact.sObjectType)) {
          // 既存のアカウント
          result.add(new RegistOption(obj, result.size(), OPT_MATH));
        }
      }
      // アカウントその他ルックアップ、新規追加
      addAltRegitOption(result, Contact.sObjectType, opt.haveParents());
      return result;
    }
  }

  // Wizard 形式 1st step 登録先対象選択に応じで登録先候補作るくんをインスタンス化
  private static OptionListBuilder createOptionListBuilder(Integer registTarget) {
    if (registTarget == 1) { // Account
      return new AccountOptionListBuilder();
    }
    else if (registTarget == 2) { // Lead
      return new LeadOptionListBuilder();
    }
    else if (registTarget == 0) { // Both
      return new AccountLeadOptionListBuilder();
    }
    // registTarget == -1 初期、既存の有無によりどちらか一方
    return new AccountYusenOptionListBuilder();
  }

  ///**
  //*
  //*  getAccountOptions 名刺に該当する登録可能な取引先オプションを取得
  //*     2018.02.xx v1.22 LDV を考慮 カウントしてから 抽出
  //*   lx 2.0  新クエリクラス に移行
  //**/
  public static List<RegistOption> getAccountOptions(Id cardId, QueryOption opt) {
    System.debug(opt);
    OptionListBuilder builder = createOptionListBuilder(opt.registTarget);
    return builder.run(cardId, opt);
  }

  //public List<RegistOption> getAccountOptions(Id cardId, QueryOption opt) {
  //  System.debug(opt);
  //  List<RegistOption> result = new List<RegistOption>();

  //  // 1. Account
  //  // まず、既存アカウントを探す
  //  if (opt.registTarget == -1 || opt.registTarget == 0 || opt.registTarget == 1 ) {
  //    //List<Account> acnts = getAccounts(cards, opt);
  //    List<Account> acnts = getAccounts(cardId, opt);
  //    // アカウントが999 以上だったら候補ださない
  //    if (acnts.size() < 999) {
  //      for(Account acnt : acnts) {
  //        // 既存のアカウント
  //        result.add(new AccountOption(acnt, result.size(), OPT_MATH));
  //      }
  //    }
  //    // アカウントが999 以上だったら候補ださないけど、既存を使う前提
  //    if (!acnts.isEmpty() || opt.registTarget == 0 || opt.registTarget == 1) {
  //      // アカウント 検索、新規追加
  //      addAltRegitOption(result, Account.sObjectType, true);
  //    }
  //    if (acnts.size() >= 999) {
  //      acnts.clear();
  //    }
  //  }

  //  // 2. Lead
  //  // 既存アカウントの有無にかかわらず、リードを探す
  //  if ((opt.registTarget == -1 && result.isEmpty()) || opt.registTarget == 0 || opt.registTarget == 2 ) {
  //    List<Lead> leads = getLeads(cardId, opt);
  //    if (leads.size() < 999) {
  //      for(Lead l : leads) {
  //        result.add(new RegistOption(l, result.size(), OPT_MATH));
  //      }
  //    }
  //    if (!leads.isEmpty() || opt.registTarget == 0 || opt.registTarget == 2) {
  //      // リード 検索、新規追加
  //      addAltRegitOption(result, Lead.sObjectType, true);
  //    }
  //    if (leads.size() >= 999) {
  //      leads.clear();
  //    }
  //  }
  //  // アカウントもリードも 既存はない
  //  if (result.isEmpty()) {
  //    // カスタム設定 リードまたは取引先に登録の際、ともに既存がない場合、リードのリストを表示
  //    if (SB_NameCardL_Util.smartViscaConfig.LeadRegist_DefaultShowLeadListNoExsiting__c) {
  //      // リード 検索、新規追加
  //      addAltRegitOption(result, Lead.sObjectType, true);
  //    }
  //    else {
  //      // アカウント 検索、新規追加
  //      addAltRegitOption(result, Account.sObjectType, true);
  //    }
  //  }
  //  return result;
  //}

  /**
  *
  *  getContactOptions 名刺と取引先に該当する登録可能な取引先責任者オプションを取得
  *
  *   2018.02.xx v1.22 検索条件見直し
  *  ((メールアドレス AND 氏名　AND レコードタイプ) OR 参照先コンタクトID) AND アカウントID AND 未削除
  *
  **/
  public static List<RegistOption> getContactOptions(Id cardId, QueryOption opt) {
    System.debug(opt);
    ContactOptionListBuilder builder = new ContactOptionListBuilder();
    return builder.run(cardId, opt);
  }
  //public static List<RegistOption> getContactOptions(Id cardId, QueryOption opt) {
  //  System.debug(opt);
  //  Id accountId = opt.parentId;
  //  List<RegistOption> result = new List<RegistOption>();
  //  if (accountId !=null) {
  //    // アカウントが指定されてたとき
  //    // 名刺の検索
  //    SmartViscaf__NameCard__c card = getNameCardSimpleFields(cardId);
  //    Set<String> names = getContactNameSet(card);
  //    Id contId = card.SmartViscaf__contact__c; // リンクしてる登録済のコンタクト
  //    //String query = 'SELECT Id, Name, Owner.Name';
  //    // 取得する項目
  //    Set<String> fields = new Set<String>();
  //    fields.add('id');
  //    fields.add('name');
  //    fields.add('owner.name');
  //    fields.add('department');
  //    fields.add('email');
  //    fields.add('title');
  //    for (QueryField f : contactFields) {
  //      fields.add(f.name);
  //      //query += ', ' + f.name;
  //    }
  //    //query += ' FROM Contact WHERE AccountId = :accountId + '\'';
  //    List<String> conds = new List<String>();
  //    if (String.isNotBlank(card.SmartViscaf__email__c)) {
  //      // メアドがあれば、メアドからコンタクト取得
  //      conds.add('email=\'' + String.escapeSingleQuotes(card.SmartViscaf__email__c) + '\'');
  //    }
  //    if (!names.isEmpty()){
  //      // 2017.11.xx v1.20.3 メアド + 氏名 で コンタクトを抽出
  //      // SV_DEV-658 LEX画面 :取引先・取引先責任者に登録（個別登録）でメールアドレスのみで取引先責任者の候補が表示される
  //      conds.add('Name LIKE :names');
  //    }
  //    // レコードタイプ名
  //    List<String> rids = null;
  //    if (opt != null && opt.contRecTypeIds !=null && !opt.contRecTypeIds.isEmpty() && !Test.isRunningTest()) {
  //      rids = new List<String>(opt.contRecTypeIds);
  //      //query +=   ? '' : ' AND RecordTypeId IN :rids';
  //      conds.add('RecordTypeId IN :rids');
  //    }
  //    String condition = String.join(conds, ' AND ');
  //    if (contId != null) {
  //      condition = '((' + condition + ') OR Id = :contId)';
  //    }
  //    String query = String.format('SELECT {0} FROM Contact WHERE {1} AND AccountId = :accountId AND IsDeleted = false ORDER BY Name, LastModifiedDate DESC LIMIT 201'
  //          , new String[] { String.join( new List<String>(fields), ', '), condition });
  //    //query +=' AND IsDeleted = false ORDER BY Name, LastModifiedDate DESC LIMIT 201';
  //    System.debug('++Contact SOQL : '+ query);
  //    List<Contact> conts = Database.query(query);  // SOQL
  //    for(Contact cont : conts) {
  //      result.add(new RegistOption(cont, result.size(), OPT_MATH));
  //    }
  //  }
  //  addAltRegitOption(result, Contact.sObjectType, accountId != null);
  //  return result;
  //}

  // SOSL で 取引先 を検索して RegistOption で返す
  public static List<RegistOption> searchAccount(String word, List<String> recTypes) {
    List<RegistOption> result = new List<RegistOption>();
    Set<String> recTypeIds = null;
    String searchWord = SB_NameCardL_Util.escapeSOSLYoyakugo(word);
    String query ='FIND {' + searchWord + '} IN ALL FIELDS RETURNING Account(Id, Name, Owner.Name';
    for (QueryField f : accountFields) {
      query += ', ' + f.name;
    }
    if (recTypes != null && recTypes.size() > 0 ) {
      if (!Account.sObjectType.getDescribe().fields.getMap().containsKey('RecordTypeId')) {
        throw new SB_NCL_RegistOptionCreaterException('RecordTypeId request not allowed');
      }
      recTypeIds = new Set<String>(recTypes);
      query += ' WHERE RecordTypeId IN :recTypeIds';
    }
    query += ')';
    System.debug('++Account SOSL : '+ query);
    List<List<SObject>> searchList = search.query(query);
    if (searchList.isEmpty() == false && searchList[0].isEmpty() == false) {
      for (SObject acnt : searchList[0]) {
        result.add(new AccountOption((Account)acnt, result.size(), OPT_SELECT));
      }
    }
    return result;
  }

  // SOSL で 取引先責任者 を検索して RegistOption で返す
  public static List<RegistOption> searchContact(String word, Id accountId, List<String> recTypes) {
    List<RegistOption> result = new List<RegistOption>();
    Id aId = accountId;
    Set<String> recTypeIds = null;
    String searchWord = SB_NameCardL_Util.escapeSOSLYoyakugo(word);
    String query = 'FIND {' + searchWord + '} IN ALL FIELDS RETURNING Contact(';
    Set<String> fields = new Set<String> { 'id', 'name', 'owner.name', 'department' };
    for (QueryField f : contactFields) {
      fields.add(f.name);
    }
    query += String.join(new List<String>(fields), ', ');
    query += ' WHERE AccountId = :aId';
    if (recTypes != null && recTypes.size() > 0) {
      if (!Contact.sObjectType.getDescribe().fields.getMap().containsKey('RecordTypeId')) {
        throw new SB_NCL_RegistOptionCreaterException('RecordTypeId request not allowed');
      }
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

  // SOSL で リード を検索して RegistOption で返す
  // lx 2.0
  public static List<RegistOption> searchLead(String word, List<String> recTypes) {
    List<RegistOption> result = new List<RegistOption>();
    Set<String> recTypeIds = null;
    String searchWord = SB_NameCardL_Util.escapeSOSLYoyakugo(word);
    String query ='FIND {' + searchWord + '} IN ALL FIELDS RETURNING Lead(';
    Set<String> fields = new Set<String> { 'id', 'name', 'owner.name', 'company', 'email', 'firstname', 'lastname', 'title'};
    for (QueryField f : leadFields) {
      fields.add(f.name);
    }
    query += String.join(new List<String>(fields), ', ');
    if (recTypes != null && recTypes.size() > 0 ) {
      if (!Account.sObjectType.getDescribe().fields.getMap().containsKey('RecordTypeId')) {
        throw new SB_NCL_RegistOptionCreaterException('RecordTypeId request not allowed');
      }
      recTypeIds = new Set<String>(recTypes);
      query += ' WHERE RecordTypeId IN :recTypeIds';
    }
    query += ')';
    System.debug('++Lead SOSL : '+ query);
    List<List<SObject>> searchList = search.query(query);
    if (searchList.isEmpty() == false && searchList[0].isEmpty() == false) {
      for (SObject obj : searchList[0]) {
        result.add(new RegistOption(obj, result.size(), OPT_SELECT));
      }
    }
    return result;
  }

  // SOSL で Campaign を検索して Campaign レコード で 返す
  // lx 2.0
  public static List<Campaign> searchCampaign(String word) {
    String searchWord = SB_NameCardL_Util.escapeSOSLYoyakugo(word);
    String query ='FIND {' + searchWord +
       '} IN ALL FIELDS RETURNING Campaign(Id, Name, Description, StartDate, EndDate, Status, Type WHERE IsActive=true)';
    System.debug('++Campaign SOSL : '+ query);
    List<List<SObject>> searchList = search.query(query);
    if (searchList.isEmpty() == false) {
      return searchList[0];
    }
    return null;
  }

  // SOSL で 所定のオブジェクトを検索して RegistOption で返す 親のアカウントのIDを指定可能
  public static List<RegistOption> searchRegistOptions(String word, String objName, Id accountId, List<String> recTypes) {
    SObjectType otype = Schema.getGlobalDescribe().get(objName);
    System.assert(otype != null);
    List<RegistOption> result = new List<RegistOption>();
    String searchWord = SB_NameCardL_Util.escapeSOSLYoyakugo(word);
    Id aId = accountId;
    Set<String> recTypeIds = null;
    String query = 'FIND {' + searchWord + '} IN ALL FIELDS RETURNING ' + objName +'(';
    Set<String> fields = new Set<String> { 'id', 'name', 'owner.name' };
    fields.addAll(OBJ2OPTION_LABEL_FIELDS.get(otype));
    for (QueryField f : sobj2Fields.get(otype)) {
      fields.add(f.name);
    }
    //query += ' WHERE AccountId =\'' + accountId + '\'';
    query += String.join(new List<String>(fields), ', ');
    //query += ' WHERE AccountId =\'' + accountId + '\'';
    //String conditon = '';
    //conditon += String.isNotBlank(aId) ? ' WHERE AccountId = :aId' : '';
    List<String> conditons = new List<String>();
    if (String.isNotBlank(aId)) {
      conditons.add('AccountId = :aId');
    }
    if (recTypes != null && recTypes.size() > 0) {
      recTypeIds = new Set<String>(recTypes);
      //conditon += String.isNotBlank(conditon) ? ' AND' : ' WHERE';
      //conditon += ' RecordTypeId IN :recTypeIds';
      conditons.add('RecordTypeId IN :recTypeIds');
    }
    if (objName == 'campaign') {
      conditons.add('IsActive = true');
    }
    //query += conditon;
    query += conditons.isEmpty() ? '' : ' WHERE ' + String.join(new List<String>(conditons), ' AND ');
    query += ')';
    System.debug(String.format('++{0} SOSL : {1}', new String[] {objName, query} ));
    List<List<sObject>> searchList = search.query(query);
    if (searchList.isEmpty() == false && searchList[0].isEmpty() == false) {
      for (SObject obj : searchList[0]) {
        result.add(new RegistOption(obj, result.size(), OPT_SELECT));
      }
    }
    return result;
  }

}