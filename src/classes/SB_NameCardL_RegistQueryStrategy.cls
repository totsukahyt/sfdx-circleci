/**
 *
 * SB_NameCardL_RegistQueryStrategy
 *
 *  レコード抽出の条件を保持して、クエリの文字列を作ったり、レコードが条件に合致するか調べる クラス
 *      アカウント用、
 *      コンタクト用、リード用、コンタクトのサブクエリ付きのアカウント用
 *    クエリは SB_NameCardL_RegistQueryExecutor で行う
 *
 * Copyright (C) 2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2018.4.xx
 *
 **/
public with sharing class SB_NameCardL_RegistQueryStrategy {
  //public class SB_NameCardL_RegistQueryStrategyException extends Exception {}

  private static final String QUERY_FORM = 'SELECT {0} FROM {1} WHERE {2}';
  private static final String RELQUERY_FORM = 'SELECT {0}, ({1}) FROM {2} WHERE {3}';
  private static final String COUNT_FORM = 'SELECT Count(Id) cnt FROM {0} WHERE {1}';

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
    'convertedcontactid'  // 取引開始済み取引先責任者  該当のコンタクトが削除されても残るので注意
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

  // SOQL文字列を返す
  // ids でバインドする前提
  public static String getQueryStringByIds(SObjectType otype) {
    String result;
    String fields = String.join(new List<String>(OTYPE2QUERY_FIELDS.get(otype)), ',');
    result = String.format(QUERY_FORM, new String[]{ fields, otype.getDescribe().getName(), 'Id In :ids' });
    return result;
  }

  private static Set<String> namecardFields = new Set<String> {
    'id',
    'name',
    'owner.id',
    'owner.name',
    'lastmodifieddate',
    'smartviscaf__company_name__c',
    'smartviscaf__division__c',
    'smartviscaf__title_name__c',
    'smartviscaf__address_pref__c',
    'smartviscaf__address__c',
    'smartviscaf__address_bld__c',
    'smartviscaf__address_eng__c',
    'smartviscaf__zip_code__c',
    'smartviscaf__person_name_last__c',
    'smartviscaf__last_name__c',
    'smartviscaf__person_name_first__c',
    'smartviscaf__first_name__c',
    'smartviscaf__email__c',
    'smartviscaf__tel1__c',
    'smartviscaf__tel2__c',
    'smartviscaf__mobile__c',
    'smartviscaf__web_url1__c',
    'smartviscaf__web_url2__c',
    'smartviscaf__memo__c',
    'smartviscaf__account__c',
    'smartviscaf__contact__c',
    'smartviscaf__lead__c',
    'smartviscaf__card_exchange_date__c',
    'smartviscaf__parent__c',
    'campaign__c'
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
        if (SmartViscaf.SB_NameCard_Util.isEnablePersonAccount() && !isAccountSupportRecType()) {
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
  private static Set<Id> getQueryAccountRectypeIds(SmartViscaf__NameCardBasicSetting__c setting) {
    Set<Id> result = new Set<Id>();
    if (setting != null) {
      result = getValidRectypIds(Account.sObjectType, setting.SmartViscaf__RenkeiAccountQueryRecordTypeIds__c);
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
  // public enum CompanyMatcing { FullMatch, CorpMatch, PartialMatch } // 法人格含み完全一致、法人格を除いて一致、法人格を除いて部分一致
  // public enum DeptMatcing { FullMatch, PartialMatch } // 法人格含み完全一致、法人格を除いて一致、法人格を除いて部分一致

  // private final static Map<SB_NameCardL_RegistQueryOption.CompanyMatcing, SB_NameCardL_RegistQueryMatcher.CompanyMatcing> MAP_COMPANYMATCING = new Map<SB_NameCardL_RegistQueryOption.CompanyMatcing, CompanyMatcing> {
  //   SB_NameCardL_RegistQueryOption.CompanyMatcing.FullMatch => SB_NameCardL_RegistQueryMatcher.CompanyMatcing.FullMatch,
  //   SB_NameCardL_RegistQueryOption.CompanyMatcing.CorpMatch =>  SB_NameCardL_RegistQueryMatcher.CompanyMatcing.CorpMatch,
  //   SB_NameCardL_RegistQueryOption.CompanyMatcing.PartialMatch => SB_NameCardL_RegistQueryMatcher.CompanyMatcing.PartialMatch
  // };

  // private final static Map<SB_NameCardL_RegistQueryOption.DeptMatcing, DeptMatcing> MAP_DEPTMATCING = new Map<SB_NameCardL_RegistQueryOption.DeptMatcing, DeptMatcing> {
  //   SB_NameCardL_RegistQueryOption.DeptMatcing.FullMatch => DeptMatcing.FullMatch,
  //   SB_NameCardL_RegistQueryOption.DeptMatcing.PartialMatch => DeptMatcing.PartialMatch
  // };

  ////////////////////////////////
  // 値の一致をチェックするときの対応付けを保持するクラス
  //  任意の項目用のみ。。
  ////////////////////////////////
  // public class Comparator {
  //   private Boolean use;      //  使う・使わない
  //   public String ncField { get; private set; }    // 名刺の項目
  //   public List<String> targetFields { get; private set; }   // それを比較する アカウントとか 抽出対象のオブジェクトの項目API名
  //   public Comparator(SmartViscaf__NameCardBasicSetting__c setting) {
  //     //this.use = SpecificItems_Valid__c;
  //     this.ncField = 'SmartViscaf__memo__c';     // 名刺の項目 メモ
  //     this.use = String.isNotBlank(setting.SmartViscaf__RenkeiSpecificItems__c); //setting.RenkeiSpecificItems_Valid__c;      //
  //     //this.use = String.isNotBlank(setting.RenkeiSpecificItems__c);
  //     if (this.use) {
  //       this.targetFields = new List<String> { setting.SmartViscaf__RenkeiSpecificItems__c };
  //     }
  //   }
  // }

  ////////////////////////////////
  // 既存レコードを探すときの条件とする項目について保持するクラス の抽象クラス
  ////////////////////////////////
  public abstract class QueryStrategy extends SB_NameCardL_RegistQueryOption {
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
    // public SB_NameCardL_RegistQueryOption.CompanyMatcing companyRule { get; private set; } // { FullMatch, CorpMatch, PartialMatch } // 法人格含み完全一致、法人格を除いて一致、法人格を除いて部分一致
    // public SB_NameCardL_RegistQueryOption.DeptMatcing deptRule { get; private set; }// { FullMatch, PartialMatch } // 法人格含み完全一致、法人格を除いて一致、法人格を除いて部分一致
    public String orderBy { get; private set; }
    public Integer max { get; private set; }
    // public Set<Id> rectypeIds { get; private set; } // 検索対称のレコードタイプ
    // public String altCompanyField { get; private set; }     // アカウント、リードの 会社名 項目を Name や Company 以外の項目として扱う

    // // 検索対称のレコードタイプをセット。いまはないけど画面のとき用
    // public void setRectypeIds(Set<Id> ids) {
    //   rectypeIds.clear();
    //   rectypeIds.addAll(ids);
    // }
    public void setCompanyRule(SB_NameCardL_RegistQueryOption.CompanyMatcing r) {
      this.companyRule = r;
    }
    public void setDeptRule(SB_NameCardL_RegistQueryOption.DeptMatcing r) {
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
    //   this.companyRule = SB_NameCardL_RegistQueryOption.CompanyMatcing.PartialMatch;
    //   this.deptRule = SB_NameCardL_RegistQueryOption.DeptMatcing.PartialMatch;
    //   this.orderBy = null;
    //   this.max = null;
    //   this.rectypeIds = new Set<Id>();
    // }
    public QueryStrategy() {
      super();
    }

    public QueryStrategy(SB_NameCardL_RegistQueryOption qo) {
      super();
      //this.ikkatu = false;
      setQuryOption(qo);
      this.orderBy = null;
      this.max = null;
      // this.rectypeIds = new Set<Id>();
    }

    public void setQuryOption(SB_NameCardL_RegistQueryOption qo) {
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
      this.queryTitle = qo.queryTitle;
      this.queryMobile = qo.queryMobile;
      this.companyRule = qo.companyRule;
      this.deptRule = qo.deptRule;
      this.altCompanyField = qo.altCompanyField;
      if (String.isNotBlank(this.altCompanyField)) {
        addQueryFields(new Set<String> { this.altCompanyField });
      }
      for (Id rid : qo.rectypeIds) {
        System.debug('rid: ' + rid);
      }
      this.rectypeIds = new Set<Id>(qo.rectypeIds);
      SYstem.debug(this.rectypeIds.size());
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
    //public QueryStrategy(SmartViscaf__NameCardBasicSetting__c setting) {
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
    //private abstract void init(SmartViscaf__NameCardBasicSetting__c setting);
    public abstract SObjectType getSObjectType();
    public abstract void addQueryFields(Set<String> fs);
    public abstract String createWhereExpression(SB_NameCardL_RegistQueryExecutor qexe, Boolean orderby);
    // SOQL文字列を返す
    public virtual String getQueryString(SB_NameCardL_RegistQueryExecutor qexe) {
      String result;
      String fields = String.join(new List<String>(OTYPE2QUERY_FIELDS.get(getSObjectType())), ',');
      result = String.format(QUERY_FORM, new String[] { fields, getSObjectType().getDescribe().getName(), createWhereExpression(qexe, true) });
      return result;
    }
    // SOSL文字列を返す
    public virtual String getSearchString(SB_NameCardL_RegistQueryExecutor qexe) {
      String result;
      String fields = String.join(new List<String>(OTYPE2QUERY_FIELDS.get(getSObjectType())), ',');

      return result;
    }

    // レコード数カウントの SOQL文字列 を返す
    public virtual String getCountString(SB_NameCardL_RegistQueryExecutor qexe) {
      String result;
      result = String.format(COUNT_FORM, new String[] { getSObjectType().getDescribe().getName(), createWhereExpression(qexe, false) });
      return result;
    }

    // 名刺 card と target が この抽出条件において合致しているか？
    public abstract Boolean isMatch(SmartViscaf__NameCard__c card, SObject target);


  }

  /**
  * アカウント クエリ用
  *
  **/
  public virtual class AccountQueryStrategy extends QueryStrategy {
    public override SObjectType getSObjectType() { return Account.sObjectType; }
    private String compareToMemo; // 名刺のメモ 項目と比較する取引先の項目
    //protected SB_NameCardL_RegistQueryMatcher.AccountMatcher acntMatcher;
    // public Comparator extention { get; private set; }
    public AccountQueryStrategy() {
      super();
      this.queryCompany = true;    //  取引先名 デフォルト オン
      this.queryDept = true;    //  部門  デフォルト オン
      this.rectypeIds.addAll(getQueryAccountRectypeIds(null));
      this.orderby = 'Name ASC, BillingState ASC NULLS LAST, Site ASC NULLS LAST';
      //this.acntMatcher = new SB_NameCardL_RegistQueryMatcher.AccountMatcher(this);
    }

    public AccountQueryStrategy(SB_NameCardL_RegistQueryOption qo) {
      super(qo);
      this.orderby = 'Name ASC, BillingState ASC NULLS LAST, Site ASC NULLS LAST';
      //this.acntMatcher = new SB_NameCardL_RegistQueryMatcher.AccountMatcher(this);
    }

    public AccountQueryStrategy(SmartViscaf__NameCardBasicSetting__c setting) {
      super();
      this.orderby = 'Name ASC, BillingState ASC NULLS LAST, Site ASC NULLS LAST';
      this.queryState = setting.SmartViscaf__RenkeiAccountAddressPref__c;
      this.queryCity = setting.SmartViscaf__RenkeiAccountCity__c;
      this.queryStreet = setting.SmartViscaf__RenkeiAccount_Street__c;
      this.queryZip = setting.SmartViscaf__RenkeiAccountZipCode__c;
      this.queryPhone = setting.SmartViscaf__RenkeiAccountPhone__c;
      this.queryCompany = true;
      this.queryDept = setting.SmartViscaf__RenkeiAccountSite__c;
      this.queryUrl = setting.SmartViscaf__RenkeiAccountURL__c;
      // this.extention = new Comparator(setting);
      if (setting.SmartViscaf__RenkeiExcludeHojinkakuPartial__c) {
        this.companyRule = SB_NameCardL_RegistQueryOption.CompanyMatcing.PartialMatch; // 会社名 部分一致
      }
      else if (setting.SmartViscaf__RenkeiExcludeHojinkaku__c) {
        this.companyRule = SB_NameCardL_RegistQueryOption.CompanyMatcing.CorpMatch; // 法人格抜きで一致
      }
      else {
        this.companyRule = SB_NameCardL_RegistQueryOption.CompanyMatcing.FullMatch; // 完全一致
      }
      this.deptRule = SB_NameCardL_RegistQueryOption.DeptMatcing.PartialMatch;
      //this.rectypeIds = getValidRectypIds(Account.sObjectType, setting.SmartViscaf__RenkeiAccountQueryRecordTypeIds__c);
      this.rectypeIds = getQueryAccountRectypeIds(setting);
      //this.acntMatcher = new SB_NameCardL_RegistQueryMatcher.AccountMatcher(this, setting);
      // 名刺メモと比較する 取引先の項目
      if (String.isNotBlank(setting.SmartViscaf__RenkeiSpecificItems__c)) {
        this.compareToMemo = setting.SmartViscaf__RenkeiSpecificItems__c;
        addQueryFields(new Set<String> { setting.SmartViscaf__RenkeiSpecificItems__c });
      }
    }
    public void setQueryCompany(Boolean b) {
      this.queryCompany = b;
    }
    // 部署を検索条件にするか しないか
    public void setQueryDept(Boolean b) {
      this.queryDept = b;
    }
    // Account 取り出す 項目 小文字で指定すること
    public override void addQueryFields(Set<String> fs) {
      accountFields.addAll(fs);
    }
    // Account の Where 句
    public override String createWhereExpression(SB_NameCardL_RegistQueryExecutor qexe, Boolean orderby) {
      String result;
      List<String> items = new List<String>();
      if (this.queryCompany) { // 取引先名 //  && !qexe.fullOrgNames.isEmpty()) {
        String cfield = String.isblank(this.altCompanyField) ? 'Name' : this.altCompanyField;
        if (this.companyRule == SB_NameCardL_RegistQueryOption.CompanyMatcing.PartialMatch || this.companyRule == SB_NameCardL_RegistQueryOption.CompanyMatcing.CorpMatch) {
          items.add(cfield + ' LIKE :orgNameWithParcents');
        }
        else { // 完全一致
          items.add(cfield + ' IN :fullOrgNames');
        }
      }
      if (this.queryDept) { // 取引先 部門 //  && !qexe.depts.isEmpty()) {
        //if (this.deptRule == SB_NameCardL_RegistQueryOption.DeptMatcing.PartialMatch) {
        //  items.add('Site LIKE :deptWithParcents');
        //}
        //else {
        //  items.add('Site IN :depts');
        //}
        if (this.deptRule == SB_NameCardL_RegistQueryOption.DeptMatcing.PartialMatch) {
          List<String> deptParts = new List<String>();
          if (!qexe.deptWithParcents.isEmpty()) {
            deptParts.add('Site LIKE :deptWithParcents');
          }
          if (qexe.haveNullDept()) {
              deptParts.add('Site = null');
          }
          if (!deptParts.isEmpty()) {
            String s = String.join(deptParts, ' OR ');
            items.add('(' + s + ')');
          }
        }
        else {
          items.add('Site IN :depts');
        }
      }
      //if (!this.ikkatu) {
        // バルク、自動連携 のときは 住所系は Where句にいれず、後で isMatch で調べる。
        if (this.queryState) { // 都道府県 //  && !qexe.prefs.isEmpty()) {
          items.add('(BillingState IN :prefs OR ShippingState IN :prefs)');
        }
        if (this.queryCity) { // 市区郡 //  && !qexe.cities.isEmpty()) {
          items.add('(BillingCity IN :cities OR ShippingCity IN :cities)');
        }
        if (this.queryStreet) { // 町名・番地 //  && !qexe.streets.isEmpty()) {
          items.add('(BillingStreet IN :streets OR ShippingStreet IN :streets)');
        }
        if (this.queryZip) { // 郵便番号 //  && !qexe.zips.isEmpty()) {
          items.add('(BillingPostalCode IN :zips OR ShippingPostalCode IN :zips)');
        }
        // 電話番号はクエリ条件にせず、Macherで調べる
        //if (this.queryPhone) { // 電話 //  && !qexe.Phone.isEmpty()) {
        //  items.add('Phone IN :phones');
        //}
        // URLはクエリ条件にせず、Macherで調べる
        //if (this.queryUrl) { // Webサイト //  && !qexe.urls.isEmpty()) {
        //  items.add('Website IN :urls');
        //}
      //}
      // // 名刺 メモ と 指定項目の一致
      // if (this.extention != null && this.extention.use) {
      //   items.add(this.extention.targetFields[0] + ' IN :memos');
      // }
      // レコードタイプの条件 あるときだけ
      if (!this.rectypeIds.isEmpty()) {
        qexe.acntRecTypeIds.clear();
        qexe.acntRecTypeIds.addAll(this.rectypeIds);
        items.add('RecordTypeId IN :acntRecTypeIds');
      }
      // AND でつなげる
      result = String.join(items, ' AND ');
      // ORの部分
      List<String> orItems = new List<String>();
      if (String.isNotBlank(result)) {
        orItems.add('(' + result + ')');
      }
      // アカウント参照先
      if (!qexe.acntIds.isEmpty()) {
        orItems.add('Id IN :acntIds');
      }
      // OR でつなげる
      result = String.join(orItems, ' OR ');
      if (orderby && String.isNotBlank(this.orderBy)) {
        result += ' ORDER BY ' + this.orderBy;
      }
      if (orderby && this.max != null && this.max > 0) {
        result += ' LIMIT ' + String.valueOf(this.max);
      }
      return result;
    }

    // // 名刺メモとアカウントの指定項目との一致のチェック
    // private Boolean isMatchExtension(SmartViscaf__NameCard__c card, SObject target) {
    //   System.assert(this.extention.use);
    //   String src = (String)card.get(this.extention.ncField);
    //   String dest = (String)target.get(this.extention.targetFields[0]);
    //   return src == dest;
    // }

    public virtual override Boolean isMatch(SmartViscaf__NameCard__c card, SObject target) {
      SB_NameCardL_RegistQueryMatcher.AccountMatcher matcher = new SB_NameCardL_RegistQueryMatcher.AccountMatcher(this);
      if (String.isNotBlank(this.compareToMemo)) {
        Map<String, String> n2a = new Map<String, String> {
          'SmartViscaf__memo__c' => this.compareToMemo
        };
        matcher.setExtensionFields(n2a);
      }
      return matcher.isMatch(card, target);

    }

  } // public class AccountQueryStrategy extends QueryStrategy

  /**
  * コンタクト クエリ用
  *
  **/
  public class ContactQueryStrategy extends QueryStrategy {
    public override SObjectType getSObjectType() { return Contact.sObjectType; }
    //public SB_NameCardL_RegistQueryMatcher.ContactMatcher contMatcher;
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
      //this.contMatcher = new SB_NameCardL_RegistQueryMatcher.ContactMatcher(this);
    }
    public ContactQueryStrategy(SB_NameCardL_RegistQueryOption qo) {
      super(qo);
      this.orderby = 'Account.Name ASC, MailingState ASC NULLS LAST, Department ASC NULLS LAST';
      this.parentIds = new Set<Id>();
      if (qo.parentIds != null && !qo.parentIds.isEmpty()) {
        this.parentIds.addAll(qo.parentIds);
      }
      //this.contMatcher = new SB_NameCardL_RegistQueryMatcher.ContactMatcher(this);
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
    public ContactQueryStrategy(SmartViscaf__NameCardBasicSetting__c setting) {
      super();
      //  注意  3つともオフなら、姓 だけはオンにしてしまう。
      this.queryLastName = !setting.SmartViscaf__RenkeiContactLastName__c && !setting.SmartViscaf__RenkeiContactFirstName__c && !setting.SmartViscaf__RenkeiContactMail__c ? true :  setting.SmartViscaf__RenkeiContactLastName__c;
      this.queryFirstName = setting.SmartViscaf__RenkeiContactFirstName__c;
      this.queryEMail = setting.SmartViscaf__RenkeiContactMail__c;
      this.queryDept = false; // 部署 オフ
      this.queryTitle = false;
      this.queryMobile = false;
      this.deptRule = SB_NameCardL_RegistQueryOption.DeptMatcing.PartialMatch;
      //this.parentIds = new Set<Id>();
      this.rectypeIds.addAll(getValidRectypIds(Contact.sObjectType, setting.SmartViscaf__RenkeiContactQueryRecordTypeIds__c));
      //this.contMatcher = new SB_NameCardL_RegistQueryMatcher.ContactMatcher(this);
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
    // Contact の Where 句
    public override String createWhereExpression(SB_NameCardL_RegistQueryExecutor qexe, Boolean orderby) {
      String result;
      String accountIdItem;
      List<String> items = new List<String>();
      // S1 LEX個別 登録、アカウントを選んだあと、コンタクトを選ぶケース
      //if (!this.parentIds.isEmpty()) {
      //  qexe.parentIds.clear();
      //  qexe.parentIds.addAll(this.parentIds);
      //  items.add('AccountId IN :parentIds');
      //}
      if (this.parentIds != null && !this.parentIds.isEmpty()) {
        accountIdItem = 'AccountId IN :parentIds';
      }
      else {
        if (this.queryCompany) { // 取引先名 //  && !qexe.fullOrgNames.isEmpty()) {
          String cfield = String.isblank(this.altCompanyField) ? 'Account.Name' : 'Account.' + this.altCompanyField;
          if (this.companyRule == SB_NameCardL_RegistQueryOption.CompanyMatcing.PartialMatch || this.companyRule == SB_NameCardL_RegistQueryOption.CompanyMatcing.CorpMatch) {
            items.add(cfield + ' LIKE :orgNameWithParcents');
          }
          else { // 完全一致
            items.add(cfield + ' IN :fullOrgNames');
          }
        }
        if (this.queryDept) { // 取引先 部門 //  && !qexe.depts.isEmpty()) {
        //  if (this.deptRule == SB_NameCardL_RegistQueryOption.DeptMatcing.PartialMatch) {
        //
        //  }
        //  else {
        //    items.add('(Account.Site IN :depts OR Department IN :depts)');
        //  }
          if (this.deptRule == SB_NameCardL_RegistQueryOption.DeptMatcing.PartialMatch) {
            List<String> deptParts = new List<String>();
            if (!qexe.deptWithParcents.isEmpty()) {
              deptParts.add('Account.Site LIKE :deptWithParcents OR Department LIKE :deptWithParcents');
            }
            if (qexe.haveNullDept()) {
                deptParts.add('Account.Site = null OR Department = null');
            }
            if (!deptParts.isEmpty()) {
              String s = String.join(deptParts, ' OR ');
              items.add('(' + s + ')');
            }
          }
          else {
            items.add('(Account.Site IN :depts OR Department IN :depts)');
          }
        }
      }
      if (this.queryLastName) { // 名
        items.add('LastName IN :lastnames');
      }
      if (this.queryFirstName) { // 名
        items.add('FirstName IN :firstnames');
      }
      //if (this.queryDept) { // 部署 //  && !qexe.depts.isEmpty()) {
      //  if (this.deptRule == SB_NameCardL_RegistQueryOption.DeptMatcing.PartialMatch) {
      //    items.add('Department LIKE :deptWithParcents');
      //  }
      //  else {
      //    items.add('Department IN :depts');
      //  }
      //}
      if (this.queryTitle) { // 役職
        items.add('Title IN :titles');
      }
      if (this.queryMobile) { // 携帯番号
        items.add('MobilePhone IN :mobiles');
      }
      if (this.queryState) { // 都道府県
        items.add('(MailingState IN :prefs OR OtherState IN :prefs)');
      }
      if (this.queryCity) { // 市区郡
        items.add('(MailingCity IN :cities OR OtherCity IN :cities)');
      }
      if (this.queryStreet) { // 町名・番地
        items.add('(MailingStreet IN :streets OR OtherStreet IN :streets)');
      }
      if (this.queryZip) { // 郵便番号
        items.add('(MailingPostalCode IN :zips OR OtherPostalCode IN :zips)');
      }
      // 電話番号はクエリ条件にせず、Macherで調べる
      //if (this.queryPhone) { // 電話
      //  items.add('Phone IN :phones');
      //}
      // AND でつなげる
      result = String.join(items, ' AND ');
      // ORの部分
      List<String> orItems = new List<String>();
      if (String.isNotBlank(result)) {
        orItems.add('(' + result + ')');
      }
      // メールアドレス
      if (this.queryEmail) {
        orItems.add('Email IN :emails');
      }
      // OR でつなげる
      result = String.join(orItems, ' OR ');
      // レコードタイプの条件 あるときだけ
      if (!this.rectypeIds.isEmpty()) {
        qexe.contRecTypeIds.clear();
        qexe.contRecTypeIds.addAll(this.rectypeIds);
        result = String.format('({0}) AND RecordTypeId IN :contRecTypeIds', new String[]{ result });
      }
      // 親IDの指定 あるときだけ
      if (String.isNotBlank(accountIdItem)) {
        result = String.format('{0} AND ({1})', new String[]{ accountIdItem, result });
      }
      // コンタクト参照先 あるときだけ
      if (!qexe.contIds.isEmpty()) {
        result = String.format('({0}) OR Id IN :contIds', new String[]{ result });
      }
      if (orderby && String.isNotBlank(this.orderBy)) {
        result += ' ORDER BY ' + this.orderBy;
      }
      if (orderby && this.max != null && this.max > 0) {
        result += ' LIMIT ' + String.valueOf(this.max);
      }
      return result;
    }

    // 一括でも、Where 句 を厳密にするから、不要？
    public override Boolean isMatch(SmartViscaf__NameCard__c card, SObject target) {

      if (this.parentIds!=null && !this.parentIds.isEmpty()) {
      // 取引先の指定があったら、取引先をチェック
        Contact cont = (Contact)target;
        if (cont.Account.Id == null || !this.parentIds.contains(cont.Account.Id)) {
          return false;
        }
      }
      SB_NameCardL_RegistQueryMatcher.ContactMatcher matcher = new SB_NameCardL_RegistQueryMatcher.ContactMatcher(this);
      return matcher.isMatch(card, target);
      // Contact cont = (Contact)target;
      // Map<String, String> pnMap = SmartViscaf.SB_NameCard_Util.getPersonName(card);
      // String last_name = pnMap.get('last_name');
      // String first_name = pnMap.get('first_name');
      // return
      //   (!this.queryEmail || card.SmartViscaf__email__c == cont.Email) &&
      //   (!this.queryFirstName || first_name == cont.FirstName) &&
      //   (!this.queryLastName || last_name == cont.LastName);
      // return true;
    }
  } // public class ContactQueryStrategy extends QueryStrategy

  /**
  * リード クエリ用
  *
  **/
  public class LeadQueryStrategy extends QueryStrategy {
    public override SObjectType getSObjectType() { return Lead.sObjectType; }
    //public SB_NameCardL_RegistQueryMatcher.LeadMatcher leadMatcher;
    //public CompanyMatcing companyRule { get; private set; } // { FullMatch, CorpMatch, PartialMatch } // 法人格含み完全一致、法人格を除いて一致、法人格を除いて部分一致
    public Boolean queryExceptConverted { get; private set; } // TRUE: SOQLで取引開始済みを除く
    public LeadQueryStrategy() {
      super();
      this.queryLastName = true;  // 姓 デフォルト オフ
      this.queryFirstName = true; // 名 デフォルト オフ
      this.queryEMail = true; // メールアドレス デフォルト オン
      this.queryTitle = false;
      this.queryMobile = false;
      this.queryCompany = false;
      this.queryUrl = false;
      this.queryExceptConverted = true;
      this.orderby = 'Company ASC NULLS LAST, State ASC NULLS LAST, Title ASC NULLS LAST, Name ASC NULLS LAST, Email ASC NULLS LAST';
      //this.companyRule = CompanyMatcing.PartialMatch;
      //this.leadMatcher = new SB_NameCardL_RegistQueryMatcher.LeadMatcher(this);
    }
    public LeadQueryStrategy(SB_NameCardL_RegistQueryOption qo) {
      super(qo);
      this.queryExceptConverted = true;
      this.orderby = 'Company ASC NULLS LAST, State ASC NULLS LAST, Title ASC NULLS LAST, Name ASC NULLS LAST, Email ASC NULLS LAST';
      //this.leadMatcher = new SB_NameCardL_RegistQueryMatcher.LeadMatcher(this);
    }
    //public LeadQueryStrategy(Boolean ikkatu) {
    //  super(ikkatu);
    //  this.queryLastName = false;  // 姓 デフォルト オフ
    //  this.queryFirstName = false; // 名 デフォルト オフ
    //  this.queryEMail = true; // メールアドレス デフォルト オン
    //  this.queryTitle = false;
    //  this.queryMobile = false;
    //  this.queryCompany = true;
    //  this.queryUrl = false;
    //  //this.companyRule = CompanyMatcing.PartialMatch;
    //}
    //public LeadQueryStrategy(Boolean ikkatu, Boolean queryCompany, Boolean queryLastName, Boolean queryFirstName, Boolean queryEMail) {
    //  super(ikkatu);
    //  this.queryLastName = queryLastName;
    //  this.queryFirstName = queryFirstName;
    //  this.queryEMail = queryEMail;
    //  this.queryTitle = false;
    //  this.queryMobile = false;
    //  this.queryCompany = true;
    //  this.queryUrl = false;
    //  this.companyRule = CompanyMatcing.PartialMatch;
    //}

    public LeadQueryStrategy(SmartViscaf__NameCardBasicSetting__c setting) {
      super();
      this.orderby = 'Company ASC NULLS LAST, State ASC NULLS LAST, Title ASC NULLS LAST, Name ASC NULLS LAST, Email ASC NULLS LAST';
      // 住所系
      this.queryState = setting.SmartViscaf__RenkeiLeadAddressPref__c;
      this.queryCity = setting.SmartViscaf__RenkeiLeadCity__c;
      this.queryStreet = setting.SmartViscaf__RenkeiLeadStreet__c;
      this.queryZip = setting.SmartViscaf__RenkeiLeadZipCode__c;
      this.queryPhone = setting.SmartViscaf__RenkeiLeadPhone__c;
      //  注意  3つともオフなら、姓 だけはオンにしてしまう。
      this.queryLastName = !setting.SmartViscaf__RenkeiLeadLastName__c && !setting.SmartViscaf__RenkeiLeadFirstName__c && !setting.SmartViscaf__RenkeiLeadMail__c ? true :  setting.SmartViscaf__RenkeiLeadLastName__c;
      this.queryFirstName = setting.SmartViscaf__RenkeiLeadFirstName__c;
      this.queryEMail = setting.SmartViscaf__RenkeiLeadMail__c;
      this.queryTitle = false;
      this.queryMobile = false;
      this.queryCompany = setting.SmartViscaf__RenkeiLeadCompany__c;
      this.queryUrl = setting.SmartViscaf__RenkeiLeadURL__c;
      if (setting.SmartViscaf__RenkeiLeadExcludeHojinkakuPartial__c) {
        this.companyRule = SB_NameCardL_RegistQueryOption.CompanyMatcing.PartialMatch;
      }
      else if (setting.SmartViscaf__RenkeiLeadExcludeHojinkaku__c) {
        this.companyRule = SB_NameCardL_RegistQueryOption.CompanyMatcing.CorpMatch;
      }
      else {
        this.companyRule = SB_NameCardL_RegistQueryOption.CompanyMatcing.FullMatch;
      }
      this.rectypeIds.addAll(getValidRectypIds(Lead.sObjectType, setting.SmartViscaf__RenkeiLeadQueryRecordTypeIds__c));
      //this.leadMatcher = new SB_NameCardL_RegistQueryMatcher.LeadMatcher(this);
      this.queryExceptConverted = false;    //  　基本設定を読むとき = 自動連携のとき は 取引開始済み を除外しない
    }
    public void setQueryCompany(Boolean b) {
      this.queryCompany = b;
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
    //// 取引開始済みを除外するかどうか
    //// 自動連携で、候補を探すときは含めて、登録時は除外するので、
    //public void setQueryExceptConverted(Boolean b) {
    //  this.queryExceptConverted = b;
    //}
    // Lead 取り出す 項目  小文字で指定すること
    public override void addQueryFields(Set<String> fs) {
      leadFields.addAll(fs);
    }
    // Lead の Where 句
    public override String createWhereExpression(SB_NameCardL_RegistQueryExecutor qexe, Boolean orderby) {
      String result;
      List<String> items = new List<String>();
      if (this.queryCompany) { // 会社名
        String cfield = String.isblank(this.altCompanyField) ? 'Company' : this.altCompanyField;
        if (this.companyRule == SB_NameCardL_RegistQueryOption.CompanyMatcing.PartialMatch || this.companyRule == SB_NameCardL_RegistQueryOption.CompanyMatcing.CorpMatch) {  //
          items.add(cfield + ' LIKE :orgNameWithParcents');
        }
        else { // 完全一致
          items.add(cfield + ' IN :fullOrgNames');
        }
      }
      if (this.queryLastName) { // 名
        items.add('LastName IN :lastnames');
      }
      if (this.queryFirstName) { // 名
        items.add('FirstName IN :firstnames');
      }
      //if (this.queryLastName && this.queryEmail) { // メールアドレス 姓も条件 なら、メアドの NULL も条件
      //  items.add('Email IN :emailsWithNull');
      //}
      //if (!this.queryLastName && this.queryEmail) { // メールアドレス 姓も条件 じゃないなら、メアドの NULL は除外
      //  items.add('Email IN :emails');
      //}
      if (this.queryTitle) { // 役職
        items.add('Title IN :titles');
      }
      if (this.queryMobile) { // 携帯番号
        items.add('MobilePhone IN :mobiles');
      }
      if (this.queryState) { // 都道府県
        items.add('State IN :prefs');
      }
      if (this.queryCity) { // 市区郡
        items.add('City IN :cities');
      }
      if (this.queryStreet) { // 町名・番地
        items.add('Street IN :streets');
      }
      if (this.queryZip) { // 郵便番号
        items.add('PostalCode IN :zips');
      }
      // メールアドレス
      if (this.queryEmail) {
        items.add('Email IN :emails');
      }      // 電話番号はクエリ条件にせず、Macherで調べる
      //if (this.queryPhone) { // 電話
      //  items.add('Phone IN :phones');
      //}
      // URLはクエリ条件にせず、Macherで調べる
      //if (this.queryUrl) { // Webサイト
      //  items.add('Website IN :urls');
      //}
      // レコードタイプの条件 あるときだけ
      if (!this.rectypeIds.isEmpty()) {
        qexe.leadRecTypeIds.clear();
        qexe.leadRecTypeIds.addAll(this.rectypeIds);
        items.add('RecordTypeId IN :leadRecTypeIds');
      }
      // AND でつなげる
      result = String.join(items, ' AND ');
      // ORの部分
      List<String> orItems = new List<String>();
      if (String.isNotBlank(result)) {
        orItems.add('(' + result + ')');
      }
      //// メールアドレス
      //if (this.queryEmail) {
      //  orItems.add('Email IN :emails');
      //}
      // コンタクト参照先 あるときだけ
      if (!qexe.leadIds.isEmpty()) {
        orItems.add('Id IN :leadIds');
      }
      // OR でつなげる
      result = String.join(orItems, ' OR ');
      //　取引開始済み
      if (this.queryExceptConverted) {
        // 除外する
        result = String.format('({0}) AND IsConverted = false', new String[]{ result });
      }
      // Order by
      if (orderby && String.isNotBlank(this.orderBy)) {
        result += ' ORDER BY ' + this.orderBy;
      }
      if (orderby && this.max != null && this.max > 0) {
        result += ' LIMIT ' + String.valueOf(this.max);
      }
      return result;
    }

    public override Boolean isMatch(SmartViscaf__NameCard__c card, SObject target) {
      SB_NameCardL_RegistQueryMatcher.LeadMatcher matcher = new SB_NameCardL_RegistQueryMatcher.LeadMatcher(this);
      return matcher.isMatch(card, target);
    }

  } // public class LeadQueryStrategy extends QueryStrategy

  /**
  * コンタクトのサブクエリ付きのアカウント クエリ用
  *
  **/
  public class AccountContactQueryStrategy extends AccountQueryStrategy {
    private ContactQueryStrategy cQSt;
    // private SB_NameCardL_RegistQueryMatcher.AccountMatcher acntMatcher;
    public SB_NameCardL_RegistQueryMatcher.ContactMatcher contMatcher { get; private set; }

    public AccountContactQueryStrategy() {
      super();
      this.cQSt = new ContactQueryStrategy();
      this.contMatcher = new SB_NameCardL_RegistQueryMatcher.ContactMatcher(this.cQSt);
    }
    public AccountContactQueryStrategy(SB_NameCardL_RegistQueryOption qo) {
      super(qo);
      this.cQSt = new ContactQueryStrategy(qo);
      this.contMatcher = new SB_NameCardL_RegistQueryMatcher.ContactMatcher(this.cQSt);
    }

    public AccountContactQueryStrategy(SmartViscaf__NameCardBasicSetting__c setting) {
      super(setting);
      this.cQSt = new ContactQueryStrategy(setting);
      this.contMatcher = new SB_NameCardL_RegistQueryMatcher.ContactMatcher(this.cQSt);
    }

    // コンタクトのサブクエリ
    private String getSubQuery(SB_NameCardL_RegistQueryExecutor qexe) {
      qexe.parentIds.clear(); // コンタクトの親取引先はWhere句にいれない。
      String fields = String.join(new List<String>(contactFields), ',');
      return String.format(QUERY_FORM, new String[] { fields, 'Contacts', cQSt.createWhereExpression(qexe, true) });
    }

    // Contact 用のSOQL
    public override String getQueryString(SB_NameCardL_RegistQueryExecutor qexe) {
      String result;
      String fields = String.join(new List<String>(accountFields), ',');
      result = String.format(RELQUERY_FORM, new String[] { fields, getSubQuery(qexe), 'Account', createWhereExpression(qexe, true) });
      return result;
    }

    // // アカウントと子のコンタクとを調べる。
    // public override Boolean isMatch(SmartViscaf__NameCard__c card, SObject target) {
    //   // return super.isMatch(card, target);
    //   this.acntMatcher.isMatch(card, target);
    // }

    // クエリしたコンタクトレコードが一致するか
    public Boolean isMatchContact(SmartViscaf__NameCard__c card, Contact cont) {
      return this.cQSt.isMatch(card, cont);
    }

  } // public class AccountContactQueryStrategy extends AccountContactQueryStrategy


  // SB_NameCardL_RegistQueryOption から 必要な分の オブジェクトごとの QueryStrategy を作って返す。
  public static QueryStrategy createQueryStrategy(SB_NameCardL_RegistQueryOption queryOption) {
    if (queryOption.target == Account.sObjectType) {
      return new AccountQueryStrategy(queryOption);
    }
    else if (queryOption.target == Contact.sObjectType) {
      return new ContactQueryStrategy(queryOption);
    }
    else if (queryOption.target == Lead.sObjectType) {
      return new LeadQueryStrategy(queryOption);
    }
    return null;
  }

  //public static Map<SObjectType, QueryStrategy> createQueryStrategy(SB_NameCardL_RegistQueryOption queryOption) {

  //  Map<SObjectType, QueryStrategy> result = new Map<SObjectType, QueryStrategy> ();
  //  if (qo.target == SB_NameCardL_RegistQueryOption.TargetObject.Account ||
  //    qo.target == SB_NameCardL_RegistQueryOption.TargetObject.AccountContact ||
  //    qo.target == SB_NameCardL_RegistQueryOption.TargetObject.AccountContactLead) {
  //    result.put(Account.sObjectType, new AccountQueryStrategy(qo));
  //  }
  //  if (qo.target == SB_NameCardL_RegistQueryOption.TargetObject.Contact ||
  //    qo.target == SB_NameCardL_RegistQueryOption.TargetObject.AccountContact ||
  //    qo.target == SB_NameCardL_RegistQueryOption.TargetObject.AccountContactLead) {
  //    result.put(Contact.sObjectType, new ContactQueryStrategy(qo));
  //  }
  //  if (qo.target == SB_NameCardL_RegistQueryOption.TargetObject.Lead ||
  //    qo.target == SB_NameCardL_RegistQueryOption.TargetObject.AccountContactLead) {
  //    result.put(Lead.sObjectType, new LeadQueryStrategy(qo));
  //  }
  //  return result;
  //}


}