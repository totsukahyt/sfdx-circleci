/**
 *
 * SB_NC_RegistOptionCreater
 *  SmartVisca 取引先・取引先責任者へ登録 画面 で選択可能なオプションを調べて作るクラス
 *
 * Copyright (C) 2016-2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2016.10.xx
 *  @Version 2      2017.06.xx getAccountOptions ,getContactOptions で クエリでエスケープしてなかったので修正
 *  @Version 3      2017.11.xx v1.20.3 メアド + 氏名 で コンタクトを抽出 SV_DEV-658 LEX画面 :取引先・取引先責任者に登録（個別登録）でメールアドレスのみで取引先責任者の候補が表示される
 *  @Version 4      2017.11.xx v1.20.4 SV_DEV-673 会社名に全角バックスラッシュが含まれる名刺を自動連携すると、ORA-01423.9エラーが発生
 *  @Version 5      2017.12.xx v1.22 コンタクトの検索条件で 姓 名 は　Nameでなく LastName FirstName を使う。
 *                  2018.02.xx v1.22 個別の取引先候補取得 getAccountOptions の LDV 対策
 *  v2.0.3  2018.10.xx SV_DEV-1263 LEX 取引先・取引先責任者に登録 一括 で 名刺から参照している取引先あるいは取引先責任者が候補にならない
 *  v2.1    2018.11.xx SV_DEV-853 LEX 取引先・取引先責任者に登録(個別登録)画面 カスタム設定「S取引先登録時表示する取引先の項目1」にSiteがないとSObject row was retrieved via SOQL without querying the requested field: Account.Siteエラー
 *                      SV_DEV-1363 LEX版 取引先・取引先責任者に登録（個別・一括）で ユーザの参照アクセス出来ない場合に"Attempt to de-reference a null object"
 *  @Version 2.4    2019.06.xx sawano SV_DEV-665 取引先・取引先責任者登録のLDV対応の改造 = 取引先・取引先責任者登録の取引先400万件対応（検索のSOSL化）
 *                                    SV_DEV-1827 LEX 取引先登録 個別：S取引先登録時表示する取引先の項目、S取引先登録時表示する取引先責任者の項目 に 住所複合型を指定すると、候補が表示されない。
 *                                    SV_DEV-1645 取引先･取引先責任者に登録」ボタン登録先レコードの項目表示
 *  @Version 2.5    2020.03.xx SV_DEV-2146 LEX 取引先登録 個別：取引先の日付（カスタム項目）をマッピングに設定した際に登録先候補で表示されるポップアップが日付で表示されない
 *
 **/
public with sharing class SB_NC_RegistOptionCreater {
  public class SB_NC_RegistOptionCreaterException extends Exception {}

  // アカウント or コンタクト の対象は 既存のレコードか新規レコードか
  @TestVisible private static final Integer OPT_MATH = 1;    // 既存で名刺と一致してるアカウント or コンタクトレコードが対象
  @TestVisible private static final Integer OPT_SELECT = 2;    // 既存で選択してもらう アカウント or コンタクトレコードが対象
  @TestVisible private static final Integer OPT_NEW = 3;    // 新規で アカウント or コンタクトレコードが対象
  @TestVisible private static final Integer OPT_NOPE = 4;    //  一括登録のときの 登録しない

  // オブジェクトと表示ラベルのマップ
  private static Map<SObjectType, String> sobj2Label {
    get {
      if (sobj2Label == null) {
        sobj2Label = new Map<SObjectType, String>();
        sobj2Label.put(Account.sObjectType, Account.getSObjectType().getDescribe().getLabel());
        sobj2Label.put(Contact.sObjectType, Contact.getSObjectType().getDescribe().getLabel());
        sobj2Label.put(Lead.sObjectType, Lead.getSObjectType().getDescribe().getLabel());
        sobj2Label.put(NameCard__c.sObjectType, NameCard__c.getSObjectType().getDescribe().getLabel());
      }
      return sobj2Label;
    }
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

  // SV_DEV-1645 取引先･取引先責任者に登録」ボタン登録先レコードの項目表示 → 2019.09.19 やっぱやらない 戸井、吉田、沢野 → ユーザのカスタム項目に絞ってやる 2019.10.11 戸井、沢野
  //  Popover の表示に 名刺とマッピングしてる項目を追加します。
  private static List<QueryField> createQueryFieldsFromMapping(String oname) {
    List<QueryField> result = new List<QueryField>();
    String prefix = SB_NameCard_Util.getNamespacePrefix_x() + 'NameCard'; // パッケージ で入れたカスタム項目のプレフィクス
    List<NameCardRenkeiMapping__c> mappings = [SELECT TargetName__c FROM NameCardRenkeiMapping__c WHERE IsActive__c = true AND RecordType.Name =:oname ORDER BY BasicSetting__c, RecordType.Name];
    for (NameCardRenkeiMapping__c mapping : mappings) {
      if (mapping.TargetName__c.endsWith('__c') && !mapping.TargetName__c.startsWithIgnoreCase(prefix) // ユーザ設定のカスタム項目のみ
        && !mapping.TargetName__c.endsWithIgnoreCase('__namecard__c')) { // 2020.08.31 PRODUCT-26 自動連携する際に、名刺交換日が最新の場合にのみ取引先・取引先責任者・リードを上書きするようなオプションがほしい
          result.add(new QueryField(mapping.TargetName__c));
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
        tempList = createQueryFields(SB_NameCard_Util.smartViscaConfig.SRegistQueryAccountFields1__c);
        tempList.addAll(createQueryFields(SB_NameCard_Util.smartViscaConfig.SRegistQueryAccountFields2__c));
        tempList.addAll(createQueryFieldsFromMapping('account'));  // SV_DEV-1645 取引先･取引先責任者に登録」ボタン登録先レコードの項目表示
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
        tempList = createQueryFields(SB_NameCard_Util.smartViscaConfig.SRegistQueryContactFields1__c);
        tempList.addAll(createQueryFields(SB_NameCard_Util.smartViscaConfig.SRegistQueryContactFields2__c));
        tempList.addAll(createQueryFieldsFromMapping('contact'));  // SV_DEV-1645 取引先･取引先責任者に登録」ボタン登録先レコードの項目表示
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
  private static Set<String> getQueryFields(SObjectType otype) {
    Set<String> result = new Set<String>();
    for (QueryField f : sobj2Fields.get(otype)) {
      result.add(f.name);
    }
    return result;
  }

  private static final String USER_LANGUAGE = UserInfo.getLanguage().toLowerCase();
  // 端末での表示用に値を整形する
  private static Object getCanonicalValue(Object val, DescribeFieldResult dfr) {
    Object result;
    if (val == null) {
      return null;
    }
    if (dfr.getName().endsWithIgnoreCase('PostalCode')) {// NULL だったらださない v2.4 2019.09.xx SV_DEV-1998 LEX 取引先登録 個別：取引先候補のポップアップで郵便番号の値がNULLで表示される
      result = (USER_LANGUAGE == 'ja' ?  '〒': '') + (String) val;
    }
    else if (dfr.getType() == Schema.DisplayType.ADDRESS) {
      // v2.4 2019.06.xx SV_DEV-1827 LEX 取引先登録 個別：S取引先登録時表示する取引先の項目、S取引先登録時表示する取引先責任者の項目 に 住所複合型を指定すると、候補が表示されない。
      Address a = (Address)val;
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
    else if (dfr.getType() == Schema.DisplayType.Datetime && val instanceOf DateTime) {
      result = ((DateTime)val).format();
    }
    else if (dfr.getType() == Schema.DisplayType.Date && val instanceOf Date) {
      result = ((Date)val).format();
    }
    else {
      result = val;
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

  // 一括登録の選択オプションに文字列として表示する項目
  private static final Map<SObjectType, List<String>> OBJ2OPTION_LABEL_FIELDS = new Map<SObjectType, List<String>> {
    Account.sObjectType => new List<String> {'Site'},
    Contact.sObjectType => new List<String> {'Department', 'Email'},
    Lead.sObjectType => new List<String> {'Company', 'Title', 'Email'}
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
    public String otype { get; private set; }      // "Account", "Contact", "Lead"  lx 2.0 より
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
    @TestVisible RegistOption(SObject obj, Integer index, Integer type) {
      this.optLabel = makeLabel(obj);
      this.index = index;
      this.selected = false;
      this.id = obj.Id;
      this.otype = obj.Id.getSObjectType().getDescribe().getName();    // オブジェクトの名前 lx 2.0
      this.title = (String)obj.get('Name');
      if (obj.getSObject('Owner') != null) {  // SV_DEV-1363 LEX版 取引先・取引先責任者に登録（個別・一括）で ユーザの参照アクセス出来ない場合に"Attempt to de-reference a null object"
        this.owner = (String)obj.getSObject('Owner').get('Name');
      }
      this.info = null;
      this.type = type; // OPT_MATH, OPT_SELECT
      label2val = new Map<String, Object>();
      summary = new List<Object>();
      values = new List<Object>();
      Map<String, Schema.SObjectField > fMap = obj.getSObjectType().getDescribe().fields.getMap();
      List<QueryField> fields = sobj2Fields.get(obj.getSObjectType());
      // Map<String, Object> enabelValues = obj.getPopulatedFieldsAsMap();
      for (QueryField field : fields) {
        DescribeFieldResult dfr = fMap.get(field.name.toLowerCase()).getDescribe();
        // if (!enabelValues.containsKey(dfr.getName())) {
        //   // 念の為 → やめ
        //   continue;
        // }
        String label = dfr.getLabel();
        Object val = getCanonicalValue(obj.get(dfr.getName()), dfr);
        this.label2val.put(label, val);
        if (field.summary == 1 || field.summary == 2) {
          this.summary.add(val);
        }
        if (field.summary != 1) {
          this.values.add(val);
        }
      }
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
    private NameCard__c card;
    // public Contact cont { get; private set; }
    public List<RegistOption> contOptions { get; private set; }
    AccountContactsOption(NameCard__c card, Account acnt, Integer index) {
      super(acnt, index, OPT_MATH); //
      this.card = card;
      this.contOptions = new List<RegistOption>();
      // 取引先責任者
      // this.cont = cont;
      //this.selected = card.account__c == acnt.Id;
    }
    public void addContact(Contact cont) {
      // 既存のコンタクトを追加
      RegistOption contOption = new RegistOption(cont, this.contOptions.size(), OPT_MATH);
      Boolean bAlready = (card.contact__c == cont.Id);   // 以前 登録したコンタクト？
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

  public class Card_RegistOption {
    //public NameCard__c card { get; private set; }
    SB_NC_NameCardDTO card { get; private set; }
    public Boolean createTodo { get; private set; }
    public List<RegistOption> options { get; private set; }
    Card_RegistOption(NameCard__c card) {
      NameCardBasicSetting__c setting = SB_NameCard_BasicSetting.getNameCardBasicSetting();
      //this.card = card;
      this.card = new SB_NC_NameCardDTO();
      this.card.bindSimple(card);
      //this.createTodo = !smartViscaConfig.ToDo__c;   // ToDo登録する。
      this.createTodo = !setting.RegistNoToDo__c;     // 基本設定から 2017.06.xx
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

  // 名刺にアカウント、コンタクトを紐付け、選択可能な登録オプションを作成
  // 検索した アカウント-コンタクト から 名刺の条件にある ものを探して、名刺と関連付ける。
  private static Card_RegistOption createCardRegistOption(NameCard__c card, List<Account> acnts, List<Contact> conts) {
    Card_RegistOption result = new Card_RegistOption(card);
    DescribeSObjectResult dsrAccount = Account.getSObjectType().getDescribe();
    DescribeSObjectResult dsrContact = Contact.getSObjectType().getDescribe();
    Boolean alreadyRegisted = false;
    if (String.isNotBlank(card.company_name__c)) {
      // 名刺に会社名がある
      // 一致したアカウントを候補リストに追加
      for (Account acnt : acnts) {
        AccountContactsOption reg_opt = new AccountContactsOption(card, acnt, result.options.size());
        result.addRegistOption(reg_opt);
        // アカウントごと 一致したコンタクトを候補リストに追加
        for (Contact cont : conts) {
          // アカウント配下のコンタクトを候補リストに追加
          if (cont.AccountId == acnt.Id) {
            reg_opt.addContact((Contact)cont);
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
      //  System.debug(LoggingLevel.DEBUG, 'opt: ' + res);
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

    //System.debug(LoggingLevel.DEBUG, 'NCID : ' + card.Id + ' Options : ' + result.options.size());
    //for (RegistOption res : result.options) {
    //  System.debug(LoggingLevel.DEBUG, 'opt: ' + res);
    //}
    return result;
  }

  @TestVisible
  private static List<NameCard__c> getNameCardsSimpleFields(List<Id> targetIds) {
    //Map<Id, SObject> result = null;
    System.debug(LoggingLevel.DEBUG, 'getNameCardsSimpleFields targetIds.size(): ' + targetIds.size());
    Set<Id> ids = new Set<Id>(targetIds);
    String query = 'SELECT ' + SB_NC_NameCardDTO.NC_QUERY_SIMPLE_FIELDS + ' FROM NameCard__c WHERE Id IN :ids';
    //result = new  Map<Id,SObject>(Database.query(query));
    List<NameCard__c> result = Database.query(query);
    return result;
  }

  /*
  *  getRegistOptions
  *   名刺単位の選択可能なオプションを返す。 一括登録用
  *   v2.4 一括のときは SB_NC_RegistQueryOption をオブジェクトごとに作ってリストで渡すようにします。
  */
  public static List<Card_RegistOption> getRegistOptions(List<Id> cardIds, List<SB_NC_RegistQueryOption> qos) {
    List<Card_RegistOption> result = new List<Card_RegistOption>();
    Map<Id, Card_RegistOption> card2Option = new Map<Id, Card_RegistOption>();
    // 選択されてる　名刺について値を抽出
    List<NameCard__c> cards = getNameCardsSimpleFields(cardIds);
    // 該当するアカウント、コンタクト を抽出
    SB_NameCard_RegistCanPickerAbstract picker = SB_NameCard_RegistCanPickerAbstract.createCandidatePicker(qos, new Set<Id>(cardIds));  //
    picker.addQueryFields(Account.sObjectType, getQueryFields(Account.sObjectType));
    picker.addQueryFields(Contact.sObjectType, getQueryFields(Contact.sObjectType));
    Map<Id, Map<SObjectType, List<SObject>>> cardId2objs = picker.create();
    // 名刺にアカウント、コンタクトを紐付け、選択可能な登録オプションを作成
    for (NameCard__c card : cards) {
      Map<SObjectType, List<SObject>> otype2objs = cardId2objs.get(card.Id);
      Card_RegistOption reg_opt = createCardRegistOption(card, otype2objs.get(Account.getSObjectType()), otype2objs.get(Contact.getSObjectType()));
      card2Option.put(card.Id, reg_opt);
    }
    // リストの順に並び替え
    for (Id ncId : cardIds) {
      result.add(card2Option.get(ncId));
      System.debug(LoggingLevel.DEBUG, 'Card_RegistOption options: ' + card2Option.get(ncId).options);
    }
    return result;
  }

  ////////////////////////////////////////
  // Wizard 形式用の 登録先候補作るくんたち
  ////////////////////////////////////////
  private abstract class OptionListBuilder {
    public abstract List<RegistOption> run(Id cardId, SB_NC_RegistQueryOption qo);
    // 検索結果以外の アカウント、コンタクト 更新、追加の オプションを 追加
    //   enabelSelect その他を選択して更新 が可能か アカウント新規作成の場合はない。
    protected void addAltRegitOption(List<RegistOption> opt, SObjectType otype, Boolean enabelSelect) {
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
  }

  // Wizard 形式 1st step アカウントだけで登録先候補作る
  private class AccountOptionListBuilder extends OptionListBuilder {
    public override List<RegistOption> run(Id cardId, SB_NC_RegistQueryOption qo) {
      List<RegistOption> result = new List<RegistOption>();
      // 1. 検索の準備
      // SB_NC_RegistQueryOption qo = SB_NC_RegistQueryOption.convertQueryOption(Account.sObjectType, opt);
      // 2. 検索
      // SB_NameCard_RegistCanPickerAbstract picker = new SB_NameCard_RegistSoqlCountCanPicker();
      // picker.init(qo);
      SB_NameCard_RegistCanPickerAbstract picker = SB_NameCard_RegistCanPickerAbstract.createCandidatePicker(qo, cardId);  //
      picker.addQueryFields(Account.sObjectType, getQueryFields(Account.sObjectType));
      // Map<SObjectType, List<SObject>> otype2objs = picker.create(cardId);
      Map<Id, Map<SObjectType, List<SObject>>>id2otype2objs = picker.create();
      Map<SObjectType, List<SObject>> otype2objs = id2otype2objs.get(cardId);
      // 3. 検索結果から、候補リストを作る
      if (otype2objs.containsKey(Account.sObjectType)) {
        for (SObject obj : otype2objs.get(Account.sObjectType)) {
          // 既存のアカウント
          result.add(new AccountOption((Account)obj, result.size(), OPT_MATH));
        }
      }
      // アカウントその他ルックアップ、新規追加
      addAltRegitOption(result, Account.sObjectType, true);
      return result;
    }
  }

  // Wizard 形式 2st step コンタクトの登録先候補作る
  private class ContactOptionListBuilder extends OptionListBuilder {
    public override List<RegistOption> run(Id cardId, SB_NC_RegistQueryOption qo) {
      List<RegistOption> result = new List<RegistOption>();
      if (qo.haveParents()) {
        // 1. 検索の準備
        // SB_NC_RegistQueryOption qo = SB_NC_RegistQueryOption.convertQueryOption(Contact.sObjectType, opt);
        // 2. 検索
        // SB_NameCard_RegistCanPickerAbstract picker = new SB_NameCard_RegistSoqlCountCanPicker();
        // picker.init(qo);
        SB_NameCard_RegistCanPickerAbstract picker = SB_NameCard_RegistCanPickerAbstract.createCandidatePicker(qo, cardId);  //
        picker.addQueryFields(Contact.sObjectType, getQueryFields(Contact.sObjectType));
        // Map<SObjectType, List<SObject>> otype2objs = picker.create(cardId);
        Map<Id, Map<SObjectType, List<SObject>>>id2otype2objs = picker.create();
        Map<SObjectType, List<SObject>> otype2objs = id2otype2objs.get(cardId);
        // 3. 検索結果から、候補リストを作る
        for (SObject obj : otype2objs.get(Contact.sObjectType)) {
          // 既存のアカウント
          result.add(new RegistOption(obj, result.size(), OPT_MATH));
        }
      }
      // アカウントその他ルックアップ、新規追加
      addAltRegitOption(result, Contact.sObjectType, qo.haveParents());
      return result;
    }
  }

  /**
  *  getAccountOptions 名刺に該当する登録可能な取引先オプションを取得
  **/
  public static List<RegistOption> getAccountOptions(Id cardId, SB_NC_RegistQueryOption qo) {
    System.debug(LoggingLevel.DEBUG, qo);
    System.assert(qo.target == Account.getSObjectType());
    OptionListBuilder builder = new AccountOptionListBuilder();
    return builder.run(cardId, qo);
  }

  /**
  *  getContactOptions 名刺と取引先に該当する登録可能な取引先責任者オプションを取得
  **/
  public static List<RegistOption> getContactOptions(Id cardId, SB_NC_RegistQueryOption qo) {
    System.debug(LoggingLevel.DEBUG, qo);
    System.assert(qo.target == Contact.getSObjectType());
    ContactOptionListBuilder builder = new ContactOptionListBuilder();
    return builder.run(cardId, qo);
  }

  private static final Map<SObjectType, Set<String>> OBJ_MUST_FIELDS =  new Map<SObjectType, Set<String>> {
    Account.sObjectType => new Set<String> { 'site' },
    Contact.sObjectType => new Set<String> { 'department', 'title', 'email' },
    User.sObjectType => new Set<String> { 'department', 'title', 'email', 'username' }
  };

  /**
  * SOSL で 取引先 を検索して RegistOption で返す
  **/
  public static List<RegistOption> searchAccount(String word, List<String> recTypes) {
    List<RegistOption> result = new List<RegistOption>();
    Set<Id> recTypeIds = null;
    String searchWord = SB_NameCard_Util.escapeSOSLYoyakugo(word);
    String query ='FIND {' + searchWord + '} IN ALL FIELDS RETURNING Account(Id, Name, Owner.Name, ';
    Set<String> fields = new Set<String> ( OBJ_MUST_FIELDS.get(Account.sObjectType) );
    for (QueryField f : accountFields) {
      fields.add(f.name);
    }
    query += String.join(new List<String>(fields), ', ');

    // for (QueryField f : accountFields) {
    //   query += ', ' + f.name;
    // }
    if (recTypes != null && recTypes.size() > 0) {
      if (!Account.sObjectType.getDescribe().fields.getMap().containsKey('RecordTypeId')) {
        throw new SB_NC_RegistOptionCreaterException('RecordTypeId request not allowed');
      }
      recTypeIds = new Set<Id>((List<Id>)recTypes);
    }
    if (recTypeIds == null && !SB_NameCard_BasicSetting.registAccountQueryRecordTypeIds.isEmpty()) {
      // 設定で選択されている範囲のレコードタイプに絞って検索
      recTypeIds = new Set<Id>(SB_NameCard_BasicSetting.registAccountQueryRecordTypeIds);
    }
    if (recTypeIds != null && !recTypeIds.isEmpty()) {
      query += ' WHERE RecordTypeId IN :recTypeIds';
    }
    query += ')';
    System.debug(LoggingLevel.DEBUG, '++Account SOSL : '+ query);
    List<List<SObject>> searchList = search.query(query);
    if (searchList.isEmpty() == false && searchList[0].isEmpty() == false) {
      //List<Account> acnts = getAccounts(searchList[0]);
      for (SObject acnt : searchList[0]) {
        result.add(new AccountOption((Account)acnt, result.size(), OPT_SELECT));
      }
    }
    return result;
  }

  /**
  * SOSL で 取引先責任者 を検索して RegistOption で返す
  **/
  public static List<RegistOption> searchContact(String word, Id accountId, List<String> recTypes) {
    List<RegistOption> result = new List<RegistOption>();
    Id aId = accountId;
    Set<Id> recTypeIds = null;
    String searchWord = SB_NameCard_Util.escapeSOSLYoyakugo(word);
    String query = 'FIND {' + searchWord + '} IN ALL FIELDS RETURNING Contact(Id, Name, Owner.Name, ';
    Set<String> fields = new Set<String> ( OBJ_MUST_FIELDS.get(Contact.sObjectType) );
    for (QueryField f : contactFields) {
      fields.add(f.name);
    }
    query += String.join(new List<String>(fields), ', ');
    // for (QueryField f : contactFields) {
    //   query += ', ' + f.name;
    // }
    //query += ' WHERE AccountId =\'' + accountId + '\'';
    query += ' WHERE AccountId = :aId';
    if (recTypes != null && recTypes.size() > 0) {
      if (!Contact.sObjectType.getDescribe().fields.getMap().containsKey('RecordTypeId')) {
        throw new SB_NC_RegistOptionCreaterException('RecordTypeId request not allowed');
      }
      recTypeIds = new Set<Id>((List<Id>)recTypes);
    }
    if (recTypeIds == null && !SB_NameCard_BasicSetting.registContactQueryRecordTypeIds.isEmpty()) {
      // 設定で選択されている範囲のレコードタイプに絞って検索
      recTypeIds = new Set<Id>(SB_NameCard_BasicSetting.registContactQueryRecordTypeIds);
    }
    if (recTypeIds != null && !recTypeIds.isEmpty()) {
      query += ' AND RecordTypeId IN :recTypeIds';
    }
    query += ')';
    System.debug(LoggingLevel.DEBUG, '++Contact SOSL : '+ query);
    List<List<sObject>> searchList = search.query(query);
    if (searchList.isEmpty() == false && searchList[0].isEmpty() == false) {
      for (SObject obj : searchList[0]) {
        result.add(new RegistOption(obj, result.size(), OPT_SELECT));
      }
    }
    return result;
  }

  /**
  * SOSL で 所定のオブジェクトを検索して RegistOption で返す 親のアカウントのIDを指定可能
  **/
  public static List<RegistOption> searchRegistOptions(String word, String objName, Id accountId, List<String> recTypes) {
    SObjectType otype = Schema.getGlobalDescribe().get(objName);
    System.assert(otype != null);
    List<RegistOption> result = new List<RegistOption>();
    String searchWord = SB_NameCard_Util.escapeSOSLYoyakugo(word);
    Id aId = accountId;
    Set<Id> recTypeIds = null;
    String query = 'FIND {' + searchWord + '} IN ALL FIELDS RETURNING ' + objName +'(Id, Name, Owner.Name, ';
    // 指定のオブジェクト用の項目を取得
    Set<String> fields = new Set<String> ( OBJ_MUST_FIELDS.get(otype) );
    List<QueryField> qfields = sobj2Fields.get(otype);
    for (QueryField f : qfields) {
      fields.add(f.name);
    }
    query += String.join(new List<String>(fields), ', ');
    // List<QueryField> fields = sobj2Fields.get(otype);
    // for (QueryField f : fields) {
    //   query += ', ' + f.name;
    // }
    //query += ' WHERE AccountId =\'' + accountId + '\'';
    String conditon = '';
    conditon += String.isNotBlank(aId) ? ' WHERE AccountId = :aId' : '';
    if (recTypes != null && recTypes.size() > 0) {
      recTypeIds = new Set<Id>((List<Id>)recTypes);
    }
    if (recTypeIds == null && !SB_NameCard_BasicSetting.getRegistQueryRecordTypeIds(objName).isEmpty()) {
      // 設定で選択されている範囲のレコードタイプに絞って検索
      recTypeIds = new Set<Id>(SB_NameCard_BasicSetting.getRegistQueryRecordTypeIds(objName));
    }
    if (recTypeIds != null && !recTypeIds.isEmpty()) {
      conditon += String.isNotBlank(conditon) ? ' AND' : ' WHERE';
      conditon += ' RecordTypeId IN :recTypeIds';
    }
    query += conditon;
    query += ') LIMIT 2000';
    System.debug(LoggingLevel.DEBUG, String.format('++{0} SOSL : {1}', new String[] {objName, query} ));
    List<List<sObject>> searchList = search.query(query);
    if (searchList.isEmpty() == false && searchList[0].isEmpty() == false) {
      for (SObject obj : searchList[0]) {
        result.add(new RegistOption(obj, result.size(), OPT_SELECT));
      }
    }
    return result;
  }

}