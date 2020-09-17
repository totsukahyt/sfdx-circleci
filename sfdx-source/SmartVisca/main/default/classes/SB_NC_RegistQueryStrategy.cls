/**
 *
 * SB_NC_RegistQueryStrategy
 *
 *  レコード抽出の条件を保持して、クエリの文字列を作ったり、レコードが条件に合致するか調べる クラス
 *      アカウント用、
 *      コンタクト用、リード用、コンタクトのサブクエリ付きのアカウント用
 *    クエリは SB_NC_RegistQueryExecutor で行う
 *
 * (c) 2019 Sunbridge Inc.
 *
 *  @author K.Yoshida
 *  @Version 2.2  2019.02.XX SV_DEV-1558 LEX 取引先登録 一括画面をLXパッケージ同様のLC化で追加
 *  @Version 2.4  2019.06.XX sawano 整理
 *  @Version 2.7  2020.09.08 ohno   PRODUCT-696 取引先登録 個別・一括 メールアドレスが空白値で一致して登録先候補が表示されてしまう。（姓・名が異なるレコードが表示される）
 *
 **/
public with sharing class SB_NC_RegistQueryStrategy {
  //public class SB_NC_RegistQueryStrategyException extends Exception {}
  private static final String QUERY_FORM = 'SELECT {0} FROM {1} {2}';
  private static final String RELQUERY_FORM = 'SELECT {0}, ({1}) FROM {2} {3}';
  private static final String COUNT_FORM = 'SELECT Count(Id) cnt FROM {0} {1}';
  private static final String ACCOUNT_SEARCH_FORM = 'FIND :orgName IN Name FIELDS RETURNING Account({0} {1})'; // SOSL 検索用
  private static final String ACCOUNT_SEARCH_FORM_ALTNAME = 'FIND :orgName RETURNING Account({0} {1})'; // SOSL で 会社名がName以外のとき IN ALL FIELDS は省略可

  private static Set<String> accountFields = new Set<String> {
    'id',
    'name',
    'owner.id',
    'owner.name',
    'lastmodifieddate',
    'site',
    'billingstate',
    'billingcity',
    'billingstreet',
    'billingpostalcode',
    'shippingstate',
    'shippingcity',
    'shippingstreet',
    'shippingpostalcode',
    'website',
    'phone',
    'fax'
  };

  private static Set<String> contactFields = new Set<String> {
    'id',
    'name',
    'owner.id',
    'owner.name',
    'lastmodifieddate',
    'firstname',
    'lastname',
    'email',
    'account.id',
    'account.name',
    'account.owner.name',
    'account.owner.id',
    'account.site',
    'mailingstate',
    'mailingcity',
    'mailingstreet',
    'mailingpostalcode',
    'otherstate',
    'othercity',
    'otherstreet',
    'otherpostalcode',
    'mobilephone',
    'phone',
    //'fax',
    'department',
    'title'
  };

  private static Set<String> leadFields = new Set<String> {
    'id',
    'name',
    'owner.id',
    'owner.name',
    'lastmodifieddate',
    'firstname',
    'lastname',
    'company',
    'email',
    'title',
    'mobilephone',
    'state',
    'city',
    'street',
    'postalcode',
    'website',
    'phone',
    'fax',
    'isconverted',   // 取引開始済み
    'convertedaccountid',  // 取引開始済み取引先  該当のアカウントが削除されても残るので注意
    'convertedaccount.name',
    'convertedcontactid',  // 取引開始済み取引先責任者  該当のコンタクトが削除されても残るので注意
    'convertedcontact.name'
  };

  private static final Map<SObjectType, Set<String>> OTYPE2QUERY_FIELDS = new Map<SObjectType, Set<String>> {
    Account.sObjectType => accountFields,
    Contact.sObjectType => contactFields,
    Lead.sObjectType => leadFields
  };

  private final static String CONVERTEDACCOUNTQUERY = 'SELECT {0}, (SELECT {1} FROM Contacts WHERE Id IN :{2}) FROM Account WHERE Id IN :{3}';
  // コンバートされたアカウント、コンタクトを取得する用のSOQL文字列取得
  public static String getConvertedAccountQuery(String acntIds, String contIds) {
    String acntFs = String.join(new List<String>(accountFields) , ', ');
    String contFs = String.join(new List<String>(contactFields), ', ');
    return String.format(CONVERTEDACCOUNTQUERY, new String[]{ acntFs, contFs, contIds, acntIds });
  }

  // // SOQL文字列を返す
  // // ids でバインドする前提
  // public static String getQueryStringByIds(SObjectType otype) {
  //   String result;
  //   String fields = String.join(new List<String>(OTYPE2QUERY_FIELDS.get(otype)), ',');
  //   result = String.format(QUERY_FORM, new String[]{ fields, otype.getDescribe().getName(), 'WHERE Id In :ids' });
  //   return result;
  // }

  private static Set<String> namecardFields = new Set<String> {
    'id',
    'name',
    'owner.id',
    'owner.name',
    'lastmodifieddate',
    'company_name__c',
    'division__c',
    'title_name__c',
    'address_pref__c',
    'address__c',
    'address_bld__c',
    'address_eng__c',
    'zip_code__c',
    'person_name_last__c',
    'last_name__c',
    'person_name_first__c',
    'first_name__c',
    'email__c',
    'tel1__c',
    'tel2__c',
    'mobile__c',
    'web_url1__c',
    'web_url2__c',
    'memo__c',
    'account__c',
    'contact__c',
    'lead__c',
    'card_exchange_date__c',
    'parent__c'
  };

  public static Set<String> getNameCardFields() {
    return namecardFields;
  }

  private static Set<Id> getValidRectypIds(SObjectType otype, String text_ids) {
    Set<Id> result = new Set<Id>();
    if (String.isBlank(text_ids)) {
      return result;
    }
    String[] ss = text_ids.split('[^0-9a-zA-Z]+');    // 2017.07.21 レコードIDなので、英数以外で分割  SV_DEV-528  自動連係 既存の取引先の検索条件 検索対象の取引先レコードタイプが全て選択されていると自動連係処理時にエラーとなる
    if (!ss.isEmpty()) {
      Map<ID, Schema.RecordTypeInfo> id2info = otype.getDescribe().getRecordTypeInfosById();
      for (String s : ss) {
        if (id2info.containsKey(s) && id2info.get(s).isAvailable()) { // 2017.09.06 SV_DEV-598 デフォルトのレコードタイプがないユーザで自動連携を行なった場合にエラーメッセージの表示
          result.add(s);
        }
      }
    }
    return result;
  }

  private static Set<Id> personRecTypeIds  { // 個人アカウント レコードタイプ
    get {
      if (personRecTypeIds== null) {
        personRecTypeIds = new Set<Id>();
        if (SB_NameCard_Util.isEnablePersonAccount() && !isAccountSupportRecType()) {
          List<AggregateResult> ars = Database.query('SELECT RecordTypeId FROM Account WHERE IsPersonAccount=true GROUP BY RecordTypeId');
          for (AggregateResult ar : ars) {
            personRecTypeIds.add((Id)ar.get('RecordTypeId'));
          }
        }
      }
      return personRecTypeIds;
    }
  }

  //// アカウントのレコードタイプを調べて、取引先と個人取引先レコードタイプ を仕分ける
  //private void setupAccountRecordType() {
  //  if (!SmartViscaf.SB_NameCard_Util.isEnablePersonAccount() || static !isAccountSupportRecType()) {
  //    return;
  //  }
  //  List<AggregateResult> ars = Database.query('SELECT RecordTypeId FROM Account WHERE IsPersonAccount=true GROUP BY RecordTypeId');
  //  for (AggregateResult ar : ars) {
  //    this.personRecTypeIds.add((Id)ar.get('RecordTypeId'));
  //  }
  //  for (Id i : this.acntRecTypeIds) {
  //    if (this.personRecTypeIds.contains(i)) {
  //      // 個人アカウント のレコードタイプを除外
  //      this.acntRecTypeIds.remove(i);
  //    }
  //  }
  //}
  private static Boolean isAccountSupportRecType() {
    Boolean result = false;
    Map<ID, Schema.RecordTypeInfo> id2info = Account.sObjectType.getDescribe().getRecordTypeInfosById();
    for (Schema.RecordTypeInfo info : id2info.values()) {
      if (!info.isMaster() && info.isActive()) {
        result = true;
        break;
      }
    }
    return true;
  }

  private static void removePersonAccountRectypeIds(Set<Id> ids) {
    ids.removeAll(personRecTypeIds);
  }

  public static Set<Id> getNonPersonAccountRectypeIds() {
    Set<Id> result = new Set<Id>();
    Map<ID, Schema.RecordTypeInfo> id2info = Account.sObjectType.getDescribe().getRecordTypeInfosById();
    for (Schema.RecordTypeInfo info : id2info.values()) {
      if (!info.isMaster() && info.isActive() && !personRecTypeIds.contains(info.getRecordTypeId())) {
        result.add(info.getRecordTypeId());
      }
    }
    return result;
  }

  // 画面や、自動連携で、個人取引サポートしてたら、のん個人取引先レコードタイプsを得る。個人取引先なければ、空か 指定されたレコードタイプのみ
  //  自動連携のとき、基本設定で取引先レコードタイプ指定されていても、個人取引先レコードタイプs を除外したのを返す.
  //  画面のとき、個人取引先があれば、それ以外のレコードタイプs、個人取引先なければ、から を返す
  // 画面のとき setting  を NULL で
  private static Set<Id> getQueryAccountRectypeIds(NameCardBasicSetting__c setting) {
    Set<Id> result = new Set<Id>();
    if (setting != null) {
      result.addAll(getValidRectypIds(Account.sObjectType, setting.RenkeiAccountQueryRecordTypeIds__c));
    }
    if (!personRecTypeIds.isEmpty()) {
      if (!result.isEmpty()) {
        result.removeAll(personRecTypeIds);
      }
      else {
        result.addAll(getNonPersonAccountRectypeIds());
      }
    }
    return result;
  }

  // 検索オプション
  // public enum CompanyMatcing { ExactMatch, CorpMatch, PartialMatch } // 法人格含み完全一致、法人格を除いて一致、法人格を除いて部分一致
  // public enum DeptMatcing { ExactMatch, PartialMatch } // 法人格含み完全一致、法人格を除いて一致、法人格を除いて部分一致

  // private final static Map<SB_NC_RegistQueryOption.CompanyMatcing, SB_NC_RegistQueryMatcher.CompanyMatcing> MAP_COMPANYMATCING = new Map<SB_NC_RegistQueryOption.CompanyMatcing, CompanyMatcing> {
  //   SB_NC_RegistQueryOption.CompanyMatcing.ExactMatch => SB_NC_RegistQueryMatcher.CompanyMatcing.ExactMatch,
  //   SB_NC_RegistQueryOption.CompanyMatcing.CorpMatch =>  SB_NC_RegistQueryMatcher.CompanyMatcing.CorpMatch,
  //   SB_NC_RegistQueryOption.CompanyMatcing.PartialMatch => SB_NC_RegistQueryMatcher.CompanyMatcing.PartialMatch
  // };

  // private final static Map<SB_NC_RegistQueryOption.DeptMatcing, DeptMatcing> MAP_DEPTMATCING = new Map<SB_NC_RegistQueryOption.DeptMatcing, DeptMatcing> {
  //   SB_NC_RegistQueryOption.DeptMatcing.ExactMatch => DeptMatcing.ExactMatch,
  //   SB_NC_RegistQueryOption.DeptMatcing.PartialMatch => DeptMatcing.PartialMatch
  // };

  ////////////////////////////////
  // 値の一致をチェックするときの対応付けを保持するクラス
  //  任意の項目用のみ。。
  ////////////////////////////////
  // public class Comparator {
  //   private Boolean use;      //  使う・使わない
  //   public String ncField { get; private set; }    // 名刺の項目
  //   public List<String> targetFields { get; private set; }   // それを比較する アカウントとか 抽出対象のオブジェクトの項目API名
  //   public Comparator(NameCardBasicSetting__c setting) {
  //     //this.use = SpecificItems_Valid__c;
  //     this.ncField = 'memo__c';     // 名刺の項目 メモ
  //     this.use = String.isNotBlank(setting.RenkeiSpecificItems__c); //setting.RenkeiSpecificItems_Valid__c;      //
  //     //this.use = String.isNotBlank(setting.RenkeiSpecificItems__c);
  //     if (this.use) {
  //       this.targetFields = new List<String> { setting.RenkeiSpecificItems__c };
  //     }
  //   }
  // }

  ////////////////////////////////
  // 既存レコードを探すときの条件とする項目について保持するクラス の抽象クラス
  ////////////////////////////////
  public abstract class QueryStrategy extends SB_NC_RegistQueryOption {
    //public Boolean ikkatu { get; private set; }   // バルクを識別する。一括登録と自動連携のとき。Where句をゆるくして、抽出したあと isMatch で絞り込む。
    // public Boolean queryState { get; private set; }
    // public Boolean queryCity { get; private set; }
    // public Boolean queryStreet { get; private set; }
    // public Boolean queryZip { get; private set; }
    // public Boolean queryPhone { get; private set; }
    // public Boolean queryCompany { get; private set; }
    // public Boolean queryDept { get; private set; }
    // public Boolean queryUrl { get; private set; }
    // public Boolean queryLastName { get; private set; }    //  画面上 ON 必須だけれど OFFで条件も可能にする。
    // public Boolean queryFirstName { get; private set; }
    // public Boolean queryEMail { get; private set; }
    // public Boolean queryTitle { get; private set; }
    // public Boolean queryMobile { get; private set; }
    // public SB_NC_RegistQueryOption.CompanyMatcing companyRule { get; private set; } // { ExactMatch, CorpMatch, PartialMatch } // 法人格含み完全一致、法人格を除いて一致、法人格を除いて部分一致
    // public SB_NC_RegistQueryOption.DeptMatcing deptRule { get; private set; }// { ExactMatch, PartialMatch } // 法人格含み完全一致、法人格を除いて一致、法人格を除いて部分一致
    public String orderBy { get; private set; }
    public Integer max { get; private set; }
    // public Set<Id> rectypeIds { get; private set; } // 検索対称のレコードタイプ
    // public String altCompanyField { get; private set; }     // アカウント、リードの 会社名 項目を Name や Company 以外の項目として扱う

    // // 検索対称のレコードタイプをセット。いまはないけど画面のとき用
    // public void setRectypeIds(Set<Id> ids) {
    //   rectypeIds.clear();
    //   rectypeIds.addAll(ids);
    // }
    public void setCompanyRule(SB_NC_RegistQueryOption.CompanyMatcing r) {
      this.companyRule = r;
    }
    public void setDeptRule(SB_NC_RegistQueryOption.DeptMatcing r) {
      this.deptRule = r;
    }

    // //
    // private QueryStrategy() {
    //   //this.ikkatu = false;
    //   this.queryState = false;
    //   this.queryCity = false;
    //   this.queryStreet = false;
    //   this.queryZip = false;
    //   this.queryPhone = false;
    //   this.queryCompany = true;
    //   this.queryDept = false;
    //   this.queryUrl = false;
    //   this.queryLastName = true;
    //   this.queryFirstName = false;
    //   this.queryEMail = false;
    //   this.queryTitle = false;
    //   this.queryMobile = false;
    //   this.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.PartialMatch;
    //   this.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;
    //   this.orderBy = null;
    //   this.max = null;
    //   this.rectypeIds = new Set<Id>();
    // }
    public QueryStrategy() {
      super();
    }

    public QueryStrategy(SB_NC_RegistQueryOption qo) {
      super();
      //this.ikkatu = false;
      setQuryOption(qo);
      this.orderBy = null;
      this.max = null;
      // this.rectypeIds = new Set<Id>();
    }

    public void setQuryOption(SB_NC_RegistQueryOption qo) {
      this.bulkRegist = qo.bulkRegist;      // TURE:一括登録 FALSE:個別登録
      this.target = qo.target;      // SObjectType
      this.queryState = qo.queryState;
      this.queryCity = qo.queryCity;
      this.queryStreet = qo.queryStreet;
      this.queryZip = qo.queryZip;
      this.queryPhone = qo.queryPhone;
      this.queryCompany = qo.queryCompany;
      this.queryDept = qo.queryDept;
      this.queryUrl = qo.queryUrl;
      this.queryLastName = qo.queryLastName;
      this.queryFirstName = qo.queryFirstName;
      this.queryEMail = qo.queryEMail;
      this.queryOnlyEMail = qo.queryOnlyEMail;
      this.queryNameOrEMail = qo.queryNameOrEMail;
      this.queryTitle = qo.queryTitle;
      this.queryMobile = qo.queryMobile;
      this.companyRule = qo.companyRule;
      this.deptRule = qo.deptRule;
      this.altCompanyField = qo.altCompanyField;
      if (String.isNotBlank(this.altCompanyField)) {
        // 抽出項目として追加 
        if (target != Contact.getSObjectType()) {
          // コンタクトでないとき
          addQueryFields(new Set<String> { this.altCompanyField.toLowerCase() });
        }
        else if (target == Contact.getSObjectType()) {
          addQueryFields(new Set<String> { 'account.' + this.altCompanyField.toLowerCase() });
        }
      }
      this.acntRecTypeIds = new List<Id>(qo.acntRecTypeIds);
      this.contRecTypeIds = new List<Id>(qo.contRecTypeIds);
      this.leadRecTypeIds = new List<Id>(qo.leadRecTypeIds);
    }

    public virtual Set<Id> getParentIds() { return null; }
    //// 画面の取引先登録やリード登録のとき
    //public QueryStrategy(Boolean ikkatu) {
    //  this.ikkatu = ikkatu;
    //  this.queryState = false;
    //  this.queryCity = false;
    //  this.queryStreet = false;
    //  this.queryZip = false;
    //  this.queryPhone = false;
    //  this.companyRule = CompanyMatcing.PartialMatch;
    //  this.deptRule = DeptMatcing.PartialMatch;
    //  this.orderBy = null;
    //  this.max = null;
    //  this.rectypeIds = new Set<Id>();
    //}
    //// 自動連携のとき
    //public QueryStrategy(NameCardBasicSetting__c setting) {
    //  this.ikkatu = true;
    //  this.queryState = false;
    //  this.queryCity = false;
    //  this.queryStreet = false;
    //  this.queryZip = false;
    //  this.queryPhone = false;
    //  this.orderBy = null;
    //  this.max = null;
    //  this.rectypeIds = new Set<Id>();
    //  //init(setting);
    //}
    // orderBy は 'ORDER BY ' のあとの文字列
    public void setOrderBy(String orderBy) {
      this.orderBy = orderBy;
    }
    // max は 'LIMIT ' の後に指定する数値
    public void setMaxLimit(Integer max) {
      this.max = max;
    }
    //private abstract void init(NameCardBasicSetting__c setting);
    public abstract SObjectType getSObjectType();
    public abstract void addQueryFields(Set<String> fs);
    public abstract String createWhereExpression(SB_NC_RegistQueryExecutor qexe, Boolean orderby);
    // SOQL文字列を返す
    public virtual String getQueryString(SB_NC_RegistQueryExecutor qexe) {
      String result;
      String fields = String.join(new List<String>(OTYPE2QUERY_FIELDS.get(getSObjectType())), ',');
      result = String.format(QUERY_FORM, new String[] { fields, getSObjectType().getDescribe().getName(), createWhereExpression(qexe, true) });
      return result;
    }
    // SOSL文字列を返す v2.4 では、Account だけ
    public virtual String getSearchString(SB_NC_RegistQueryExecutor qexe) {
      return null;
    }
    // レコード数カウントの SOQL文字列 を返す
    public virtual String getCountString(SB_NC_RegistQueryExecutor qexe) {
      String result;
      result = String.format(COUNT_FORM, new String[] { getSObjectType().getDescribe().getName(), createWhereExpression(qexe, false) });
      return result;
    }
    // 何かに参照されてるレコードを返すSOQLを返す
    public abstract String getQueryStringForReferenced(SB_NC_RegistQueryExecutor qexe);
    // 名刺と検索結果レコードの各項目の照合が必要？  true なら isMatch で調べる
    public abstract Boolean isNeedMatching();  
    // 名刺 card と target が この抽出条件において合致しているか？
    public abstract Boolean isMatch(NameCard__c card, SObject target);
    // 名刺から参照されてる か 名刺から参照されてるかメールアドレスが一致するコンタクトのいるアカウント？
    public abstract Boolean isReferenced(NameCard__c card, SObject obj);

  } // public abstract class QueryStrategy extends SB_NC_RegistQueryOption 

  /**
  * アカウント クエリ用
  *
  **/
  public virtual class AccountQueryStrategy extends QueryStrategy {
    public override SObjectType getSObjectType() { return Account.sObjectType; }
    private String compareToMemo; // 名刺のメモ 項目と比較する取引先の項目
    private Boolean noContactOnly; // コンタクトがいるだけのアカウントは検索対象外　一括とClasic個別のとき
    private Set<Id> idsByContact;  // 名刺から参照されてるかメールアドレスが一致するコンタクトのいるアカウントのID
    //protected SB_NC_RegistQueryMatcher.AccountMatcher acntMatcher;
    // public Comparator extention { get; private set; }
    public AccountQueryStrategy() {
      super();
      this.queryCompany = true;    //  取引先名 デフォルト オン
      this.queryDept = true;    //  部門  デフォルト オン
      this.acntRecTypeIds.addAll(getQueryAccountRectypeIds(null));
      this.orderby = 'Name ASC, BillingState ASC NULLS LAST, Site ASC NULLS LAST';
      //this.acntMatcher = new SB_NC_RegistQueryMatcher.AccountMatcher(this);
      this.noContactOnly = false;
      this.idsByContact = new Set<Id>();
    }

    public AccountQueryStrategy(SB_NC_RegistQueryOption qo) {
      super(qo);
      this.orderby = 'Name ASC, BillingState ASC NULLS LAST, Site ASC NULLS LAST';
      //this.acntMatcher = new SB_NC_RegistQueryMatcher.AccountMatcher(this);
      this.noContactOnly = false;
      this.idsByContact = new Set<Id>();
    }

    public AccountQueryStrategy(NameCardBasicSetting__c setting) {
      super();
      this.orderby = 'Name ASC, BillingState ASC NULLS LAST, Site ASC NULLS LAST';
      this.queryState = setting.RenkeiAccountAddressPref__c;
      this.queryCity = setting.RenkeiAccountCity__c;
      this.queryStreet = setting.RenkeiAccount_Street__c;
      this.queryZip = setting.RenkeiAccountZipCode__c;
      this.queryPhone = setting.RenkeiAccountPhone__c;
      this.queryCompany = true;
      this.queryDept = setting.RenkeiAccountSite__c;
      this.queryUrl = setting.RenkeiAccountURL__c;
      // this.extention = new Comparator(setting);
      if (setting.RenkeiExcludeHojinkakuPartial__c) {
        this.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.PartialMatch; // 会社名 部分一致
      }
      else if (setting.RenkeiExcludeHojinkaku__c) {
        this.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.CorpMatch; // 法人格抜きで一致
      }
      else {
        this.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.ExactMatch; // 完全一致
      }
      this.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;
      //this.rectypeIds = getValidRectypIds(Account.sObjectType, setting.RenkeiAccountQueryRecordTypeIds__c);
      this.acntRecTypeIds.addAll(getQueryAccountRectypeIds(setting));
      //this.acntMatcher = new SB_NC_RegistQueryMatcher.AccountMatcher(this, setting);
      // 名刺メモと比較する 取引先の項目
      if (String.isNotBlank(setting.RenkeiSpecificItems__c)) {
        this.compareToMemo = setting.RenkeiSpecificItems__c;
        addQueryFields(new Set<String> { setting.RenkeiSpecificItems__c.toLowerCase() });
      }
      this.noContactOnly = false;
    }
    public void setQueryCompany(Boolean b) {
      this.queryCompany = b;
    }
    // 部署を検索条件にするか しないか
    public void setQueryDept(Boolean b) {
      this.queryDept = b;
    }
    // true: コンタクトがいるだけのアカウントは検索対象外
    public void setNoContactOnly(Boolean b) {
      this.noContactOnly = b;
    }
    // Account 取り出す 項目 小文字で指定すること
    public override void addQueryFields(Set<String> fs) {
      accountFields.addAll(fs);
    }
    // SOSL文字列を返す
    public override String getSearchString(SB_NC_RegistQueryExecutor qexe) {
      String result;
      String fields = String.join(new List<String>(OTYPE2QUERY_FIELDS.get(getSObjectType())), ',');
      // Boolean b = this.queryCompany;
      // this.queryCompany = false; 
      // SOSL でも、WHEREを使う。 IN Name FIELDS  だと 部署でも一致しちゃうし、Name以外のときは IN ALL FIELDS で調べし、なので。WHERE句で該当項目で照合する。
      result = String.format(String.isblank(this.altCompanyField) ? ACCOUNT_SEARCH_FORM : ACCOUNT_SEARCH_FORM_ALTNAME,
                   new String[] { fields, createWhereExpression(qexe, true)});
      // this.queryCompany = b; 
      return result;
    }

    // 何かに参照されてるアカウントを返すSOQLを返す
    public override String getQueryStringForReferenced(SB_NC_RegistQueryExecutor qexe) {    
    // public virtual String getQueryStringByAccountIds(SB_NC_RegistQueryExecutor qexe) {
      String result;
      String condition;
      // コンタクト参照先から得たアカウントID
      Set<Id> byContIds = getAccountIdsByCont(qexe);
      if (!byContIds.isEmpty()) {
        qexe.acntIds.addAll(byContIds);
      }
      // アカウント参照先
      if (!qexe.acntIds.isEmpty()) {
        condition = 'WHERE Id IN :acntIds';
      }
      else {
        // アカウントへの参照が全然ない
        return null;
      }
      if (String.isNotBlank(condition) && String.isNotBlank(this.orderBy)) {
        condition += ' ORDER BY ' + this.orderBy;
      }
      String fields = String.join(new List<String>(accountFields), ',');
      result = String.format(QUERY_FORM, new String[] { fields, 'Account', condition });
      return result;
    }

    // コンタクトが一致するアカウントを候補にするための アカウントIDの所得 
    // SELECT AccountId FROM Contact WHERE (Id IN :contIds OR EMail IN :emails) AND RecordTypeId IN :contRecTypeIds
    private Set<Id> getAccountIdsByCont(SB_NC_RegistQueryExecutor qexe) {
      Set<Id> result = new Set<Id>();
      // Set<String> lastnames;
      // Set<String> firstnames;
      Set<String> emails;
      Set<Id> contIds;
      // Set<Id> contRecTypeIds;
      // List<String> andItems = new List<String>();
      // if (this.queryLastName) { // 名
      //   lastnames = new Set<String>(qexe.lastnames);
      //   andItems.add('LastName IN :lastnames');
      // }
      // if (this.queryFirstName && !qexe.firstnames.isEmpty()) { // 名
      //   firstnames = new Set<String>(qexe.firstnames);
      //   andItems.add('FirstName IN :firstnames');
      // }
      List<String> orItems = new List<String>();
      // if (!andItems.isEmpty()) {
      //   orItems.add('(' + String.join(andItems, ' AND ') + ')');
      // }
      // メールアドレス
      if (this.queryOnlyEMail && !qexe.emails.isEmpty()) {
        emails = new Set<String>();
        emails.addAll(qexe.emails);
        orItems.add('Email IN :emails');
      }
      // コンタクト参照先 あるときだけ
      if (!qexe.contIds.isEmpty()) {
        contIds = new Set<Id>();
        contIds.addAll(qexe.contIds);
        orItems.add('Id IN :contIds');
      }
      List<String> items = new List<String>();
      if (!orItems.isEmpty()) {
        items.add('(' + String.join(orItems, ' OR ') +')');
      }
      // 他の条件があって、コンタクトレコードタイプの条件 あるときだけ
      if (!items.isEmpty() && !this.contRecTypeIds.isEmpty()) {
        // contRecTypeIds = new Set<Id>();
        // contRecTypeIds.addAll(this.contRecTypeIds);
        items.add('RecordTypeId IN :contRecTypeIds');
      }
      // 親IDの指定 あるときだけ
      if (!items.isEmpty()) {
        String query = String.format('SELECT AccountId FROM Contact WHERE {0}', new String[]{ String.join(items, ' AND ') });
        List<Contact> conts = Database.query(query);
        for(Contact c : conts) {
          if (c.AccountId != null) {
            result.add(c.AccountId);
          }
        }
      }
      return result;
    }
    // Account の Where 句
    public override String createWhereExpression(SB_NC_RegistQueryExecutor qexe, Boolean orderby) {
      String result;
      List<String> andItems = new List<String>();
      if (this.queryCompany) { // 取引先名 //  && !qexe.fullOrgNames.isEmpty()) {
        String cfield = String.isblank(this.altCompanyField) ? 'Name' : this.altCompanyField;
        if (this.companyRule == SB_NC_RegistQueryOption.CompanyMatcing.PartialMatch || 
          this.companyRule == SB_NC_RegistQueryOption.CompanyMatcing.CorpMatch ||
          // 2019.05.xx v.24 SV_DEV-1647 法人格の正式名称と略称をマッチさせる（登録・自動連携） 
          (this.companyRule == SB_NC_RegistQueryOption.CompanyMatcing.ExactMatch &&
          SB_NameCard_BasicSetting.getNameCardBasicSetting().HojinkakuEquationLongAndAbbr__c == true)) { // （完全一致のとき）会社名の法人格は略称・正称を区別
          andItems.add(cfield + ' LIKE :orgNameWithParcents');
        }
        else { 
          // 完全一致 かつ 法人格は略称・正称を区別 SB_NC_RegistQueryOption.CompanyMatcing.PerfectMatch
          andItems.add(cfield + ' IN :fullOrgNames');
        }
      }
      if (this.queryDept) { // 取引先 部門 //  && !qexe.depts.isEmpty()) {
        //if (this.deptRule == SB_NC_RegistQueryOption.DeptMatcing.PartialMatch) {
        //  andItems.add('Site LIKE :deptWithParcents');
        //}
        //else {
        //  andItems.add('Site IN :depts');
        //}
        if (this.deptRule == SB_NC_RegistQueryOption.DeptMatcing.PartialMatch) {
          List<String> deptParts = new List<String>();
          if (!qexe.deptWithParcents.isEmpty()) {
            deptParts.add('Site LIKE :deptWithParcents');
          }
          if (qexe.haveNullDept()) {
              deptParts.add('Site = null');
          }
          if (!deptParts.isEmpty()) {
            String s = String.join(deptParts, ' OR ');
            andItems.add('(' + s + ')');
          }
        }
        else {
          andItems.add('Site IN :depts');
        }
      }
      //if (!this.ikkatu) {
        // バルク、自動連携 のときは 住所系は Where句にいれず、後で isMatch で調べる。
        if (this.queryState) { // 都道府県 //  && !qexe.prefs.isEmpty()) {
          andItems.add('(BillingState IN :prefs OR ShippingState IN :prefs)');
        }
        if (this.queryCity) { // 市区郡 //  && !qexe.cities.isEmpty()) {
          andItems.add('(BillingCity IN :cities OR ShippingCity IN :cities)');
        }
        if (this.queryStreet) { // 町名・番地 //  && !qexe.streets.isEmpty()) {
          andItems.add('(BillingStreet IN :streets OR ShippingStreet IN :streets)');
        }
        if (this.queryZip) { // 郵便番号 //  && !qexe.zips.isEmpty()) {
          andItems.add('(BillingPostalCode IN :zips OR ShippingPostalCode IN :zips)');
        }
        // 電話番号はクエリ条件にせず、Macherで調べる
        //if (this.queryPhone) { // 電話 //  && !qexe.Phone.isEmpty()) {
        //  andItems.add('Phone IN :phones');
        //}
        // URLはクエリ条件にせず、Macherで調べる
        //if (this.queryUrl) { // Webサイト //  && !qexe.urls.isEmpty()) {
        //  andItems.add('Website IN :urls');
        //}
      //}
      // // 名刺 メモ と 指定項目の一致
      // if (this.extention != null && this.extention.use) {
      //   andItems.add(this.extention.targetFields[0] + ' IN :memos');
      // }
      List<String> orItems = new List<String>();
      if (!andItems.isEmpty()) {
        orItems.add('(' + String.join(andItems, ' AND ') +')');
      }
      // コンタクト参照先から得たアカウントID
      if (!this.noContactOnly) { // コンタクトがいるだけかかもしれないアカウントも対象
        this.idsByContact.addAll(getAccountIdsByCont(qexe));
        if (!this.idsByContact.isEmpty()) {
          qexe.acntIds.addAll(this.idsByContact);
        }
      }
      // アカウント参照先
      if (!qexe.acntIds.isEmpty()) {
        orItems.add('Id IN :acntIds');
      }
      List<String> items = new List<String>();
      if (!orItems.isEmpty()) {
        if (orItems.size() > 1) {
          items.add('(' + String.join(orItems, ' OR ') +')');
        }
        else {
          items.add(orItems[0]);
        }
      }
      // レコードタイプの条件 あるときだけ
      if (!this.acntRecTypeIds.isEmpty()) {
        qexe.acntRecTypeIds.clear();
        qexe.acntRecTypeIds.addAll(this.acntRecTypeIds);
        items.add('RecordTypeId IN :acntRecTypeIds');
      }
      // AND でつなげる
      result = String.join(items, ' AND ');
      // // ORの部分
      // List<String> orItems = new List<String>();
      // if (String.isNotBlank(result)) {
      //   orItems.add('(' + result + ')');
      // }
      // // アカウント参照先
      // if (!qexe.acntIds.isEmpty()) {
      //   orItems.add('Id IN :acntIds');
      // }
      // OR でつなげる
      // result = String.join(orItems, ' OR ');
      // WHERE 句があれば、
      if (String.isNotBlank(result)) {
        result = 'WHERE ' + result;
      }
      if (orderby && String.isNotBlank(this.orderBy)) {
        result += ' ORDER BY ' + this.orderBy;
      }
      if (orderby && this.max != null && this.max > 0) {
        result += ' LIMIT ' + String.valueOf(this.max);
      }
      return result;
    }

    // // 名刺メモとアカウントの指定項目との一致のチェック
    // private Boolean isMatchExtension(NameCard__c card, SObject target) {
    //   System.assert(this.extention.use);
    //   String src = (String)card.get(this.extention.ncField);
    //   String dest = (String)target.get(this.extention.targetFields[0]);
    //   return src == dest;
    // }

    public virtual override Boolean isNeedMatching() {
      return this.bulkRegist ||
          this.companyRule == CompanyMatcing.CorpMatch || 
          (this.companyRule == CompanyMatcing.ExactMatch && 
            SB_NameCard_BasicSetting.getNameCardBasicSetting().HojinkakuEquationLongAndAbbr__c == true);
    }

    public virtual override Boolean isMatch(NameCard__c card, SObject target) {
      SB_NC_RegistQueryMatcher.AccountMatcher matcher = new SB_NC_RegistQueryMatcher.AccountMatcher(this);
      if (String.isNotBlank(this.compareToMemo)) {
        Map<String, String> n2a = new Map<String, String> {
          'memo__c' => this.compareToMemo
        };
        matcher.setExtensionFields(n2a);
      }
      return matcher.isMatch(card, target);
    }

    public override Boolean isReferenced(NameCard__c card, SObject obj) {
      System.assert(obj.getSObjectType() == Account.getSObjectType());
      return card.account__c == obj.Id || this.idsByContact.contains(obj.Id);
    }
    
  } // public class AccountQueryStrategy extends QueryStrategy

  /**
  * コンタクト クエリ用
  *
  **/
  public class ContactQueryStrategy extends QueryStrategy {
    public override SObjectType getSObjectType() { return Contact.sObjectType; }
    //public SB_NC_RegistQueryMatcher.ContactMatcher contMatcher;
    public Set<Id> parentIds { get; private set; }
    public override Set<Id> getParentIds() { return this.parentIds; }
    public ContactQueryStrategy() {
      super();
      this.queryLastName = true;  // 姓 デフォルト オン
      this.queryFirstName = true; // 名 デフォルト オン
      this.queryEMail = true; // メールアドレス デフォルト オン
      this.parentIds = new Set<Id>();
      this.orderby = 'Account.Name ASC, MailingState ASC NULLS LAST, Department ASC NULLS LAST';
      //this.queryDept = false; // 部署 オフ
      //this.queryTitle = false;
      //this.queryMobile = false;
      //this.deptRule = DeptMatcing.PartialMatch;
      //this.parentIds = new Set<Id>();
      //this.contMatcher = new SB_NC_RegistQueryMatcher.ContactMatcher(this);
    }
    public ContactQueryStrategy(SB_NC_RegistQueryOption qo) {
      super(qo);
      this.orderby = 'Account.Name ASC, MailingState ASC NULLS LAST, Department ASC NULLS LAST';
      this.parentIds = new Set<Id>();
      if (qo.parentIds != null && !qo.parentIds.isEmpty()) {
        this.parentIds.addAll(qo.parentIds);
      }
      //this.contMatcher = new SB_NC_RegistQueryMatcher.ContactMatcher(this);
    }
    //public ContactQueryStrategy(Boolean ikkatu) {
    //  super(ikkatu);
    //  this.queryLastName = true;  // 姓 デフォルト オン
    //  this.queryFirstName = true; // 名 デフォルト オン
    //  this.queryEMail = true; // メールアドレス デフォルト オン
    //  this.queryDept = false; // 部署 オフ
    //  this.queryTitle = false;
    //  this.queryMobile = false;
    //  this.deptRule = DeptMatcing.PartialMatch;
    //  //this.parentIds = new Set<Id>();
    //}
    //public ContactQueryStrategy(Boolean ikkatu, Boolean lastname, Boolean firstname, Boolean email) {
    //  super(ikkatu);
    //  this.queryLastName = lastname;
    //  this.queryFirstName = firstname;
    //  this.queryEMail = email;
    //  this.queryDept = false; // 部署 オフ
    //  this.queryTitle = false;
    //  this.queryMobile = false;
    //  this.deptRule = DeptMatcing.PartialMatch;
    //  //this.parentIds = new Set<Id>();
    //}
    public ContactQueryStrategy(NameCardBasicSetting__c setting) {
      super();
      //  注意  3つともオフなら、姓 だけはオンにしてしまう。
      this.queryLastName = !setting.RenkeiContactLastName__c && !setting.RenkeiContactFirstName__c && !setting.RenkeiContactMail__c ? true :  setting.RenkeiContactLastName__c;
      this.queryFirstName = setting.RenkeiContactFirstName__c;
      this.queryEMail = setting.RenkeiContactMail__c;
      this.queryDept = false; // 部署 オフ
      this.queryTitle = false;
      this.queryMobile = false;
      this.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;
      //this.parentIds = new Set<Id>();
      this.contRecTypeIds.addAll(getValidRectypIds(Contact.sObjectType, setting.RenkeiContactQueryRecordTypeIds__c));
      //this.contMatcher = new SB_NC_RegistQueryMatcher.ContactMatcher(this);
      this.parentIds = new Set<Id>();
    }
    public void setQueryLastName(Boolean b) {
      this.queryLastName = b;
    }
    public void setQueryFirstName(Boolean b) {
      this.queryFirstName = b;
    }
    public void setQueryEMail(Boolean b) {
      this.queryEMail = b;
    }
    //public void addParentId(Id pId) {
    //  this.parentIds.add(pId);
    //}
    //public void addParentIds(Set<Id> pIds) {
    //  this.parentIds.addAll(pIds);
    //}
    //public void clearParentIds() {
    //  this.parentIds.clear();
    //}
    // Contact 取り出す 項目  小文字で指定すること
    public override void addQueryFields(Set<String> fs) {
      contactFields.addAll(fs);
    }
    
    // 何かに参照されてるコンタクトを返すSOQLを返す
    public override String getQueryStringForReferenced(SB_NC_RegistQueryExecutor qexe) {
      String condition;
      // コンタクト参照先
      if (!qexe.contIds.isEmpty()) {
        condition = 'WHERE Id IN :contIds';
      }
      else {
        // コンタクトへの参照が全然ない
        return null;
      }
      if (String.isNotBlank(condition) && String.isNotBlank(this.orderBy)) {
        condition += ' ORDER BY ' + this.orderBy;
      }
      String fields = String.join(new List<String>(contactFields), ',');
      String result = String.format(QUERY_FORM, new String[]{ fields, 'Contact', condition });
      System.debug(result);
      return result;
    }

    // Contact の Where 句
    public override String createWhereExpression(SB_NC_RegistQueryExecutor qexe, Boolean orderby) {
      String result;
      String accountIdItem;
      // S1 LEX個別 登録、アカウントを選んだあと、コンタクトを選ぶケース
      //if (!this.parentIds.isEmpty()) {
      //  qexe.parentIds.clear();
      //  qexe.parentIds.addAll(this.parentIds);
      //  items.add('AccountId IN :parentIds');
      //}
      List<String> items = new List<String>();
      List<String> andItems = new List<String>();
      if (this.queryLastName) { // 名
        andItems.add('LastName IN :lastnames');
      }
      if (this.queryFirstName && !qexe.firstnames.isEmpty()) { // 名
        andItems.add('FirstName IN :firstnames');
      }
      // 部署 は isMatch で照合する
      //if (this.queryDept) { // 部署 //  && !qexe.depts.isEmpty()) {
      //  if (this.deptRule == SB_NC_RegistQueryOption.DeptMatcing.PartialMatch) {
      //    andItems.add('Department LIKE :deptWithParcents');
      //  }
      //  else {
      //    andItems.add('Department IN :depts');
      //  }
      //}
      if (this.queryTitle) { // 役職
        andItems.add('Title IN :titles');
      }
      if (this.queryMobile) { // 携帯番号
        andItems.add('MobilePhone IN :mobiles');
      }
      if (this.queryState) { // 都道府県
        andItems.add('(MailingState IN :prefs OR OtherState IN :prefs)');
      }
      if (this.queryCity) { // 市区郡
        andItems.add('(MailingCity IN :cities OR OtherCity IN :cities)');
      }
      if (this.queryStreet) { // 町名・番地
        andItems.add('(MailingStreet IN :streets OR OtherStreet IN :streets)');
      }
      if (this.queryZip) { // 郵便番号
        andItems.add('(MailingPostalCode IN :zips OR OtherPostalCode IN :zips)');
      }
      if (this.queryEmail) { // EMail
        if (andItems.isEmpty() || this.queryNameOrEMail == false) {
          andItems.add('Email IN :emailsWithNull');
        }
        else {
          String personCond = String.format('(({0}) OR Email IN :emailsWithNull)', new String[] { String.join(andItems, ' AND ') });
          andItems.clear();
          andItems.add(personCond);
        }
      }
      // 電話番号はクエリ条件にせず、Macherで調べる
      //if (this.queryPhone) { // 電話
      //  items.add('Phone IN :phones');
      //}
      if (this.parentIds != null && !this.parentIds.isEmpty()) {
        // 親IDの指定があるときは、その範囲で、メアド、コンタクトIDが有効
        List<String> orItems = new List<String>();
        if (!andItems.isEmpty()) {
          orItems.add('(' + String.join(andItems, ' AND ') + ')');
        }
        // ORの部分
        // メールアドレスのでも一致とする
        if (queryOnlyEMail && !qexe.emails.isEmpty()) {
          orItems.add('Email IN :emails');
        }
        // コンタクト参照先 あるときだけ
        if (!qexe.contIds.isEmpty()) {
          orItems.add('Id IN :contIds');
          // result = String.format('({0}) OR Id IN :contIds', new String[]{ result });
        }      
        if (!orItems.isEmpty()) {
          if (orItems.size() > 1) {
            items.add('(' + String.join(orItems, ' OR ') +')');
          }
          else {
            items.add(orItems[0]);
          }
        }
        items.add('AccountId IN :parentIds');
      }
      else {
        if (this.queryCompany) { // 取引先名 //  && !qexe.fullOrgNames.isEmpty()) {
          String cfield = String.isblank(this.altCompanyField) ? 'Account.Name' : 'Account.' + this.altCompanyField;
          // 2019.05.xx v.24 SV_DEV-1647 法人格の正式名称と略称をマッチさせる（登録・自動連携） 
          if (this.companyRule == SB_NC_RegistQueryOption.CompanyMatcing.PartialMatch ||
            this.companyRule == SB_NC_RegistQueryOption.CompanyMatcing.CorpMatch ||
            SB_NameCard_BasicSetting.getNameCardBasicSetting().HojinkakuEquationLongAndAbbr__c == true) { // （完全一致のとき）会社名の法人格は略称・正称を区別
            // メールアドレスとかで検索するので、基本、会社名は中間一致でヨシとします。
            andItems.add(cfield + ' LIKE :orgNameWithParcents');
          }
          else { // 完全一致
            andItems.add(cfield + ' IN :fullOrgNames');
          }
        }
        if (this.queryDept) { // 取引先 部門 //  && !qexe.depts.isEmpty()) {
          if (this.deptRule == SB_NC_RegistQueryOption.DeptMatcing.PartialMatch) {
            List<String> deptParts = new List<String>();
            if (!qexe.deptWithParcents.isEmpty()) {
              deptParts.add('Account.Site LIKE :deptWithParcents OR Department LIKE :deptWithParcents');
            }
            if (qexe.haveNullDept()) {
                deptParts.add('Account.Site = null OR Department = null');
            }
            if (!deptParts.isEmpty()) {
              andItems.add('(' + String.join(deptParts, ' OR ') + ')');
            }
          }
          else {
            andItems.add('(Account.Site IN :depts OR Department IN :depts)');
          }
        }
        // ANDの部分
        List<String> orItems = new List<String>();
        if (!andItems.isEmpty()) {
          orItems.add('(' + String.join(andItems, ' AND ') + ')');
        }
        // ORの部分
        // メールアドレスのでも一致とする
        if (queryOnlyEMail && !qexe.emails.isEmpty()) {
          orItems.add('Email IN :emails');
        }
        // コンタクト参照先 あるときだけ
        if (!qexe.contIds.isEmpty()) {
          orItems.add('Id IN :contIds');
          // result = String.format('({0}) OR Id IN :contIds', new String[]{ result });
        }      
        if (!orItems.isEmpty()) {
          if (orItems.size() > 1) {
            items.add('(' + String.join(orItems, ' OR ') +')');
          }
          else {
            items.add(orItems[0]);
          }
        }

      }

      // レコードタイプの条件 あるときだけ
      if (!this.contRecTypeIds.isEmpty()) {
        qexe.contRecTypeIds.clear();
        qexe.contRecTypeIds.addAll(this.contRecTypeIds);
        items.add('RecordTypeId IN :contRecTypeIds');
      }
      // // 親IDの指定 あるときだけ
      // if (String.isNotBlank(accountIdItem)) {
      //   result = String.format('{0} AND ({1})', new String[]{ accountIdItem, result });
      // }
      // AND でつなげる
      result = String.join(items, ' AND ');
      // WHERE 句があれば、
      if (String.isNotBlank(result)) {
        result = 'WHERE ' + result;
      }      
      if (orderby && String.isNotBlank(this.orderBy)) {
        result += ' ORDER BY ' + this.orderBy;
      }
      if (orderby && this.max != null && this.max > 0) {
        result += ' LIMIT ' + String.valueOf(this.max);
      }
      return result;
    }

    public override Boolean isNeedMatching() {
      return this.bulkRegist || this.queryDept || this.queryEMail; // 一括か 部署、Emailも条件 
    }

    // 一括でも、Where 句 を厳密にするから、不要？
    public override Boolean isMatch(NameCard__c card, SObject target) {

      if (this.parentIds!=null && !this.parentIds.isEmpty()) {
      // 取引先の指定があったら、取引先をチェック
        Contact cont = (Contact)target;
        if (cont.Account.Id == null || !this.parentIds.contains(cont.Account.Id)) {
          return false;
        }
      }
      SB_NC_RegistQueryMatcher.ContactMatcher matcher = new SB_NC_RegistQueryMatcher.ContactMatcher(this);
      return matcher.isMatch(card, target);
      // Contact cont = (Contact)target;
      // Map<String, String> pnMap = SmartViscaf.SB_NameCard_Util.getPersonName(card);
      // String last_name = pnMap.get('last_name');
      // String first_name = pnMap.get('first_name');
      // return
      //   (!this.queryEmail || card.email__c == cont.Email) &&
      //   (!this.queryFirstName || first_name == cont.FirstName) &&
      //   (!this.queryLastName || last_name == cont.LastName);
      // return true;
    }

    public override Boolean isReferenced(NameCard__c card, SObject obj) {
      System.assert(obj.getSObjectType() == Contact.getSObjectType());
      return card.contact__c == obj.Id;
    }

  } // public class ContactQueryStrategy extends QueryStrategy



  /**
  * コンタクトのサブクエリ付きのアカウント クエリ用
  *
  **/
  public class AccountContactQueryStrategy extends AccountQueryStrategy {
    private ContactQueryStrategy cQSt;
    // private SB_NC_RegistQueryMatcher.AccountMatcher acntMatcher;
    public SB_NC_RegistQueryMatcher.ContactMatcher contMatcher { get; private set; }

    public AccountContactQueryStrategy() {
      super();
      this.cQSt = new ContactQueryStrategy();
      this.contMatcher = new SB_NC_RegistQueryMatcher.ContactMatcher(this.cQSt);
    }
    public AccountContactQueryStrategy(SB_NC_RegistQueryOption qo) {
      super(qo);
      this.cQSt = new ContactQueryStrategy(qo);
      this.contMatcher = new SB_NC_RegistQueryMatcher.ContactMatcher(this.cQSt);
    }

    public AccountContactQueryStrategy(NameCardBasicSetting__c setting) {
      super(setting);
      this.cQSt = new ContactQueryStrategy(setting);
      this.contMatcher = new SB_NC_RegistQueryMatcher.ContactMatcher(this.cQSt);
    }

    // コンタクトのサブクエリ
    private String getSubQuery(SB_NC_RegistQueryExecutor qexe) {
      qexe.parentIds.clear(); // コンタクトの親取引先はWhere句にいれない。
      String fields = String.join(new List<String>(contactFields), ',');
      return String.format(QUERY_FORM, new String[] { fields, 'Contacts', cQSt.createWhereExpression(qexe, true) });
    }

    // Contact 用のSOQL
    public override String getQueryString(SB_NC_RegistQueryExecutor qexe) {
      String result;
      String fields = String.join(new List<String>(accountFields), ',');
      result = String.format(RELQUERY_FORM, new String[] { fields, getSubQuery(qexe), 'Account', createWhereExpression(qexe, true) });
      return result;
    }

    // // アカウントと子のコンタクとを調べる。
    // public override Boolean isMatch(NameCard__c card, SObject target) {
    //   // return super.isMatch(card, target);
    //   this.acntMatcher.isMatch(card, target);
    // }

    // クエリしたコンタクトレコードが一致するか
    public Boolean isMatchContact(NameCard__c card, Contact cont) {
      return this.cQSt.isMatch(card, cont);
    }

  } // public class AccountContactQueryStrategy extends AccountContactQueryStrategy


}