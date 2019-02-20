/**
 *
 * SB_NameCardL_RegistCanPickerAbstract
 *
 *  登録先候補の 取引先、取引先責任者を 収集するクラスの基底
 *     KDDI様向け 管理パッケージ：SmartViscaRgq1 SB_Sv_UiRegistCanCreaterAbstract がベース
 *
 * Copyright (c) 2017-2018 SunBridge Inc.
 *
 **/
public abstract class SB_NameCardL_RegistCanPickerAbstract {

  private static final Map<Integer, String> QUERY_ORGNAME = new Map<Integer, String> {
    0 => '取引先名は法人格を除いて検索',
    1 => '取引先名は法人格を除いて部分一致検索',
    2 => '取引先名は完全一致検索'
  };

  // クエリで上限を超えたときメッセージを表示するため、
  public enum QueryProcess { PARTIAL, PERFECT, ABANDON } // 部分一致検索, 完全一致検索, 完全一致検索でも多くて捨てた
  @TestVisible
  protected QueryProcess queryProc;

  private static Map<QueryProcess, String> queryProcessComment;
  static {
    //Map<String, Schema.SObjectField> fields = Account.sObjectType.getDescribe().fields.getMap();
    //String acntName = fields.get('Name').getDescribe().getLabel();
    //String dept = fields.get('Site').getDescribe().getLabel();
    String acnt = Account.sObjectType.getDescribe().getLabel();
    queryProcessComment = new Map<QueryProcess, String>();
    queryProcessComment.put(QueryProcess.PARTIAL, null);
    queryProcessComment.put(QueryProcess.PERFECT, String.format('{0}名あるいは部門の部分一致検索では該当するレコード数が表示できる上限を超えたため完全一致検索を行いました。', new String[] { acnt, acnt } ));
    queryProcessComment.put(QueryProcess.ABANDON, String.format('{0}名あるいは部門の部分一致検索および完全一致検索で該当するレコード数が表示できる上限を超えたため{1}既存レコードは表示されません。', new String[] { acnt, acnt } ));
  }

  public String getQueryProcessComment() {
    return queryProcessComment.get(this.queryProc);
  }
  public QueryProcess getMatchMethod() {
    return this.queryProc;
  }

  private static final Integer TABLE_THRESHOLD = 997;
  private static final Integer TABLE_THRESHOLD_NOCONTACT = 998;

  protected String methodLabel;   // クラスに応じた検索手法の名称
  protected Map<SObjectType, List<SObject>> otype2Objs; // 検索結果を SObjectType ごとに保持

  //protected SB_NameCardL_RegistQueryOption queryOption;
  protected SB_NameCardL_RegistQueryStrategy.AccountQueryStrategy accountQs;
  protected SB_NameCardL_RegistQueryStrategy.ContactQueryStrategy contactQs;
  protected SB_NameCardL_RegistQueryStrategy.LeadQueryStrategy leadQs;

  protected SB_NameCardL_RegistQueryExecutor qExecutor;

  protected Map<SObjectType, SB_NameCardL_RegistQueryStrategy.QueryStrategy> otype2QueryStrategy;
  //  = new Map<SObjectType, SB_NameCardL_RegistQueryStrategy.QueryStrategy> {
  //    Account.sObjectType => accountQs,
  //    Contact.sObjectType => contactQs,
  //    Lead.sObjectType => leadQs
  //};

  //protected List<String> operations;      // どんなクエリをしたか
  public virtual Boolean isRelationQuery() { return false; } // Accountのクエリで COntactのリレーションクエリする人？

  public SB_NameCardL_RegistCanPickerAbstract() {
    this.otype2QueryStrategy = new Map<SObjectType, SB_NameCardL_RegistQueryStrategy.QueryStrategy>();
    this.accountQs = null;
    this.contactQs = null;
    this.leadQs = null;
    this.otype2Objs = new Map<SObjectType, List<SObject>>();
    //this.queryProc = QueryProcess.PARTIAL;
    //this.operations = new List<String>();
  }

  // 初期化
  // クエリオプションに従って、QueryStrategy を作っておきます。
  public void init(List<SB_NameCardL_RegistQueryOption> queryOptions) {
    for (SB_NameCardL_RegistQueryOption qo : queryOptions) {
      if (qo.target == Account.sObjectType) {
        // アカウント用のクエリ戦略
        initAccountQueryStrategy(qo);
        this.otype2QueryStrategy.put(Account.sObjectType, this.accountQs);
      }
      else if (qo.target == Contact.sObjectType) {
        // コンタクト用のクエリ戦略
        initContactQueryStrategy(qo);
        this.otype2QueryStrategy.put(Contact.sObjectType, this.contactQs);
      }
      else if (qo.target == Lead.sObjectType) {
        // リード用のクエリ戦略
        initLeadQueryStrategy(qo);
        this.otype2QueryStrategy.put(Lead.sObjectType, this.leadQs);
      }
    }
  }

  // 個別登録用  事前に SB_NameCardL_RegistQueryExecutor のinit で名刺レコードを特定しておきます。
  public abstract Map<SObjectType, List<SObject>> create();
  // 個別登録用  この中で SB_NameCardL_RegistQueryExecutor のinit で名刺レコードを特定してます。
  public abstract Map<SObjectType, List<SObject>> create(Id cardId);
  // 一括の場合は Map<Id, List<SObject>> create(Set<Id> cardIds); を名刺レコードIDと 一致するSObjectのリストのマップを返すのを使います。
  //public abstract Map<Id, List<SObject>> create(Set<Id> cardIds);
  public abstract Map<Id, Map<SObjectType, List<SObject>>> create(Set<Id> cardIds);

  // 表示する候補のレコード数 アカウント用
  protected Integer getAccountTableThreshold() {
    if (Schema.SObjectType.Contact.isCreateable()) {
      return TABLE_THRESHOLD;
    }
    return TABLE_THRESHOLD_NOCONTACT;
  }

  protected Integer getAccountQueryLimit() {
    return getAccountTableThreshold() +1;
  }

  protected Integer getContactQueryLimit() {
    return getAccountQueryLimit();
  }

  // 表示する候補のレコード数 リード用
  protected Integer getLeadTableThreshold() {
    return TABLE_THRESHOLD_NOCONTACT;
  }

  protected Integer getLeadQueryLimit() {
    return getLeadTableThreshold() +1;
  }

  //protected String getQueryLimit() {
  //  return String.valueOf(getTableThreshold() +1);
  //}

  //public static Integer tableThreshold {
  //  get {
  //    if (tableThreshold == null) {
  //      if (Schema.SObjectType.Contact.isCreateable()) {
  //        tableThreshold =  TABLE_THRESHOLD;
  //      }
  //      else {
  //        tableThreshold = TABLE_THRESHOLD_NOCONTACT;
  //      }
  //    }
  //    return tableThreshold;
  //  }
  //}

  public String getMethodLabel() {
    return this.methodLabel;
  }

  private void initAccountQueryStrategy(SB_NameCardL_RegistQueryOption queryOption) {
    if (this.accountQs != null) {  // わたされてたら初期化しない
      this.accountQs.setQuryOption(queryOption);
      return;
    }
    this.accountQs = (SB_NameCardL_RegistQueryStrategy.AccountQueryStrategy)SB_NameCardL_RegistQueryStrategy.createQueryStrategy(queryOption);
        //accountQs = (SB_NameCardL_RegistQueryStrategy.AccountQueryStrategy)SB_NameCardL_RegistQueryStrategy.createQueryStrategy(qo);
    this.accountQs.setCompanyRule(SB_NameCardL_RegistQueryOption.CompanyMatcing.PartialMatch); // 法人格除いて部分一致
    this.accountQs.setOrderBy('Name ASC, BillingState ASC NULLS LAST, Site ASC NULLS LAST');
    this.accountQs.setMaxLimit(getAccountQueryLimit());
  }

  private void initContactQueryStrategy(SB_NameCardL_RegistQueryOption queryOption) {
    if (this.contactQs != null) {  // わたされてたら初期化しない
      this.contactQs.setQuryOption(queryOption);
      return;
    }
    this.contactQs = (SB_NameCardL_RegistQueryStrategy.ContactQueryStrategy)SB_NameCardL_RegistQueryStrategy.createQueryStrategy(queryOption);
    this.contactQs.setCompanyRule(SB_NameCardL_RegistQueryOption.CompanyMatcing.PartialMatch); // 法人格除いて部分一致
    this.contactQs.setQueryLastName(true);
    this.contactQs.setQueryFirstName(true);
    this.contactQs.setQueryEMail(true);
    this.contactQs.setOrderBy('Account.Name ASC, MailingState ASC NULLS LAST, Department ASC NULLS LAST');
    this.contactQs.setMaxLimit(getContactQueryLimit());
  }

  private void initLeadQueryStrategy(SB_NameCardL_RegistQueryOption queryOption) {
    if (this.leadQs != null) {  // わたされてたら初期化しない
      this.leadQs.setQuryOption(queryOption);
      return;
    }
    this.leadQs = (SB_NameCardL_RegistQueryStrategy.LeadQueryStrategy)SB_NameCardL_RegistQueryStrategy.createQueryStrategy(queryOption);
    this.leadQs.setCompanyRule(SB_NameCardL_RegistQueryOption.CompanyMatcing.PartialMatch); // 法人格除いて部分一致
    this.leadQs.setOrderBy('Company ASC NULLS LAST, State ASC NULLS LAST, Title ASC NULLS LAST, Name ASC NULLS LAST, Email ASC NULLS LAST');
    this.leadQs.setMaxLimit(getLeadQueryLimit());
  }
  //// Accountの
  //public void setAccountQueryStrategy(SB_NameCardL_RegistQueryStrategy.AccountQueryStrategy accountQs) {
  //  this.accountQs = accountQs;
  //}
  //public SB_NameCardL_RegistQueryStrategy.AccountQueryStrategy retAccountQueryStrategy() {
  //  return this.accountQs;
  //}

  //// Contactの
  //public void setContactQueryStrategy(SB_NameCardL_RegistQueryStrategy.ContactQueryStrategy contactQs) {
  //  this.contactQs = contactQs;
  //}
  //public SB_NameCardL_RegistQueryStrategy.ContactQueryStrategy getContactQueryStrategy() {
  //  return this.contactQs;
  //}

  //// Leadの
  //public void setLeadQueryStrategy(SB_NameCardL_RegistQueryStrategy.LeadQueryStrategy leadQs) {
  //  this.leadQs = leadQs;
  //}
  //public SB_NameCardL_RegistQueryStrategy.LeadQueryStrategy getLeadQueryStrategy() {
  //  return this.leadQs;
  //}


  //// 検索条件を指定する
  //public virtual Map<SObjectType, List<SObject>> create(List<SmartViscaf__NameCard__c> cards,
  //                                  SB_NameCardL_RegistQueryStrategy.QueryStrategy qs1) { return null; }
  //public virtual Map<SObjectType, List<SObject>> create(List<SmartViscaf__NameCard__c> cards,
  //                                  SB_NameCardL_RegistQueryStrategy.QueryStrategy qs1) { return null; }
  //public virtual Map<SObjectType, List<SObject>> create(List<SmartViscaf__NameCard__c> cards,
  //                                  SB_NameCardL_RegistQueryStrategy.QueryStrategy qs1,
  //                                  SB_NameCardL_RegistQueryStrategy.QueryStrategy qs2) { return null; }
  //public virtual Map<SObjectType, List<SObject>> create(List<SmartViscaf__NameCard__c> cards,
  //                                  SB_NameCardL_RegistQueryStrategy.QueryStrategy qs1,
  //                                  SB_NameCardL_RegistQueryStrategy.QueryStrategy qs2,
  //                                  SB_NameCardL_RegistQueryStrategy.QueryStrategy qs3) { return null; }


  //// 既存の上書き対象のレコードを探すオプション
  //public virtual class QueryOption {
  //  public Boolean bulkRegist;      // TURE:一括登録 FALSE:個別登録
  //  public Integer queryOrgName;    // 0: 取引先名は法人格を除いて検索 1: 取引先名は法人格を除いて部分一致検索 2:取引先名は完全一致検索
  //  public Boolean querySite;      // 所属名を条件にして検索 0: 取引先名と所属名で検索 1,その他: 取引先名のみで検索
  //  public Boolean queryState;     // 都道府県を条件にして検索
  //  public Boolean queryCity;      // 市区郡を条件にして検索
  //  public Boolean queryZip;       // 郵便番号を条件にして検索
  //  //public Integer accountPartial; // 取引先は  法人格を除いて
  //  public List<Id> acntRecTypeIds;  // アカウントのレコードタイプ名を条件にする
  //  public List<Id> contRecTypeIds;  // コンタクトのレコードタイプ名を条件にする
  //  //public Boolean queryAccountPerfectMatch; // アカウントの部分一致で多かったらアカウントの完全一致検索を行う 従来仕様は除外
  //  public QueryOption() {
  //    this.queryOrgName = 1;
  //    this.bulkRegist = true;
  //    this.querySite = true;
  //    this.queryState = false;
  //    this.queryCity = false;
  //    this.queryZip = false;
  //    this.acntRecTypeIds = null;
  //    this.contRecTypeIds = null;
  //  }
  //  public String getDescription() {
  //    String result;
  //    List<String> params = new List<String>();
  //    params.add(QUERY_ORGNAME.get(this.queryOrgName));
  //    if (this.querySite) {
  //      params.add('取引先 所属');
  //    }
  //    if (this.queryState) {
  //      params.add('都道府県');
  //    }
  //    return String.join(params, ', ');
  //  }
  //} //public virtual class QueryOption

  //// アカウント、コンタクトの検索につかう名刺の項目を抽出するクラス
  //public class CardValues {
  //  public Set<String> orgNames { get; private set;}    // 法人格を除いた法人名
  //  public Set<String> orgNameWithParcents { get; private set;}    // 法人格を除いた法人名 %付き 部分一致用
  //  public Set<String> fullOrgNames { get; private set;}    // 法人格+法人名
  //  public Set<String> comps { get; private set;}     // 所属
  //  public Set<String> deptsWithParcents { get; private set;}     // 所属
  //  public Set<String> depts { get; private set;}     // 所属
  //  public Set<String> fnames { get; private set;}    // 名
  //  public Set<String> lnames { get; private set;}    // 姓
  //  public Set<String> mails { get; private set;}    // メアド
  //  public Set<String> prefs { get; private set;}    // 都道府県
  //  public Set<String> cities { get; private set;}   // 市区郡
  //  public Set<String> zips { get; private set;}     // 郵便番号
  //  public Set<Id> acntIds { get; private set;}     //
  //  public Set<Id> contIds { get; private set;}     //

  //  public CardValues() {
  //    orgNames = new Set<String>();    // 法人格を除いた法人名
  //    orgNameWithParcents = new Set<String>();    // 法人格を除いた法人名 %付き 部分一致用
  //    fullOrgNames = new Set<String>();    // 法人格+法人名
  //    fnames = new Set<String>();
  //    lnames = new Set<String>();
  //    mails = new Set<String>();
  //    deptsWithParcents = new Set<String>();
  //    depts = new Set<String>();
  //    prefs = new Set<String>();
  //    cities = new Set<String>();
  //    zips = new Set<String>();
  //    acntIds = new Set<Id>();
  //    contIds = new Set<Id>();
  //  }

  //  public void build(List<SmartViscaf__NameCard__c> cards) {
  //    for (SmartViscaf__NameCard__c card : cards) {
  //      // 会社名
  //      // 2017.11.xx v1.20.4  SV_DEV-673 会社名に全角バックスラッシュが含まれる名刺を自動連携すると、ORA-01423.9エラーが発生
  //      String accountName = getZenkakuBackslashToWildcard(SmartViscaf.SB_NameCard_Util.getCompanyName(card.SmartViscaf__company_name__c));
  //      if (String.isNotBlank(accountName)) {
  //        orgNames.add(accountName);      // 法人格を除いた法人名
  //        orgNameWithParcents.add('%' + varBindingExchange(accountName) + '%'); // 法人格を除いた法人名 %付き 部分一致用
  //        fullOrgNames.add(card.SmartViscaf__company_name__c);    // 法人格+法人名
  //      }
  //      // 部署
  //      if (String.isNotBlank(card.SmartViscaf__division__c)) {
  //        // 2017.11.xx v1.20.4 SV_DEV-673 会社名に全角バックスラッシュが含まれる名刺を自動連携すると、ORA-01423.9エラーが発生
  //        String dept = varBindingExchange(card.SmartViscaf__division__c);
  //        deptsWithParcents.add('%' + dept + '%');
  //        depts.add(card.SmartViscaf__division__c);
  //      }
  //      // 姓名
  //      Map<String, String> pnMap = SmartViscaf.SB_NameCard_Util.getPersonName(card);
  //      String last_name = pnMap.get('last_name');
  //      String first_name = pnMap.get('first_name');
  //      lnames.add(last_name);    // 姓 NULLも入れてIN条件とする
  //      fnames.add(first_name);   // 名 NULLも入れてIN条件とする
  //      // mail 2017.12.xx NULLも入れてIN条件とする
  //      mails.add(card.SmartViscaf__email__c);
  //      // 都道府県
  //      if (String.isNotBlank(card.SmartViscaf__address_pref__c)) {
  //        prefs.add(card.SmartViscaf__address_pref__c);
  //      }
  //      // 市区郡
  //      if (String.isNotBlank(card.SmartViscaf__address__c)) {
  //        Map<String, String> addrs = SmartViscaf.SB_NameCard_Util.getAddress(card);
  //        String city = addrs.get('city');
  //        if (String.isNotBlank(city)) {
  //          cities.add(city);
  //        }
  //      }
  //      // 郵便番号
  //      if (String.isNotBlank(card.SmartViscaf__zip_code__c)) {
  //        zips.add(card.SmartViscaf__zip_code__c);
  //      }
  //      // アカウント
  //      if (card.SmartViscaf__account__c != null) {
  //        acntIds.add(card.SmartViscaf__account__c);
  //      }
  //      // コンタクト
  //      if (card.SmartViscaf__contact__c != null) {
  //        acntIds.add(card.SmartViscaf__contact__c);
  //      }
  //    }
  //  }

  //  private String varBindingExchange(String str) {
  //    if (String.isBlank(str)) {
  //      return str;
  //    }
  //    //アポストロフィーがある場合、escapeSingleQuotesメソッドがエスケープされるはずですが、
  //    //なぜかうまくエスケープできてないので、エスケープする前にアポストロフィーをbase64を使って暗号化して、エスケープ後に元に戻す
  //    String str1 = EncodingUtil.urlEncode(str, 'UTF-8');
  //    Blob b = Blob.valueOf(str1);
  //    String b64 = EncodingUtil.base64Encode(b);
  //    str = str.replaceAll('\'',b64);
  //    str = String.escapeSingleQuotes(getZenkakuBackslashToWildcard(str));
  //    str = str.replaceAll(b64,'\'');
  //    return str;
  //  }
  //} // public class CardValues


  //public String getOperations() {
  //  return String.join(this.operations, '<BR/>');
  //}

  //protected void addOperation(String text) {
  //  System.debug(text);
  //  //this.operations.add(text);
  //}

  //public abstract Map<SObjectType, List<SObject>> create(List<SmartViscaf__NameCard__c> cards, QueryOption qopt);

//  // 名刺の取引先IDで アカウントをクエリ
//  @TestVisible
//  protected Account getAccountById(Id acntId) {
//    System.assert(acntId != null);
//    String query = String.format(ACCOUNT_QUERY_ID_MATCH, new String[]{ String.join(new List<String>(ACCOUNT_FIELDS), ', ') });
//    List<Account> acnts = Database.query(query);
//    System.assert(!acnts.isEmpty());
//    // 処理内容保存
//    //addOperation(query);
//    //addOperation('Rows: ' + acnts.size());
//    return acnts[0];
//  }

//  @TestVisible
//  protected List<Account> getAccountsByPerfectMatch(SmartViscaf__NameCard__c nc, QueryOption qopt) {
//    String name = nc.SmartViscaf__company_name__c;
//    String dept = nc.SmartViscaf__division__c;
//    List<String> params = new List<String>();
//    params.add('Name=:name');
//    if (qopt.querySite) {
//      params.add('Site=:dept');
//    }
//    String query = String.format(ACCOUNT_QUERY,  new String[]{ String.join(new List<String>(ACCOUNT_FIELDS), ', '),
//                                                               String.join(params, ' AND '),
//                                                               getQueryLimit()});
//    List<Account> acnts = Database.query(query);
//    // 処理内容保存
//    //addOperation(query);
//    //addOperation('Rows: ' + acnts.size());
//    return acnts;
//  }

//  // 取引先名、所属 の 部分一致 する 取引先責任者 の収集
//  // v1.21までの  private List<Contact> setAccountTableByContact(NameCard__c nc)  から ちょっと変更
//  protected List<Contact> getContactsByAccountPartialMatch(SmartViscaf__NameCard__c nc, QueryOption qopt) {
//      List<String> whereOrList = new List<String>();

//      Id cId;
//      if (nc.SmartViscaf__contact__c != null) {
//          cId = nc.SmartViscaf__contact__c;
//          whereOrList.add('Id = :cId');
//      }

//      String email;
//      if (String.isNotBlank(nc.SmartViscaf__email__c)) {
//          email = nc.SmartViscaf__email__c;
//          whereOrList.add('Email = :email');
//      }

//      // 会社名を取得
//      String accountName;
//      Map<String, String> pnMap = SmartViscaf.SB_NameCard_Util.getPersonName(nc);
//      String contactNamestr = '';
//      String last = '';
//      String first = '';
//      String division;
//      List<Contact> contactList = new List<Contact>();
//      if (String.isNotBlank(nc.SmartViscaf__company_name__c) && String.isNotBlank(pnMap.get('last_name'))) {
//      //if (this.isFullCompanyNameForSearch == false) {
//          if (qopt.queryOrgName == 1) {
//              accountName = SmartViscaf.SB_NameCard_Util.getCompanyName(nc.SmartViscaf__company_name__c);
//          }
//          else {
//              accountName = nc.SmartViscaf__company_name__c;
//          }
//          //accountName = String.escapeSingleQuotes('%' + accountName.replaceAll('＼', '_') + '%');

//          String str = EncodingUtil.urlEncode(accountName, 'UTF-8');
//          Blob b = Blob.valueOf(str);
//          String b64 = EncodingUtil.base64Encode(b);
//          accountName = accountName.replaceAll('\'',b64);
//          accountName = String.escapeSingleQuotes(accountName.replaceAll('＼', '_'));
//          accountName = accountName.replaceAll(b64,'\'');
//          if (qopt.queryOrgName == 1) {
//            accountName = '%' + accountName + '%';
//          }
//          System.debug('333333' + accountName);
//          if (String.isNotBlank(pnMap.get('first_name'))) {
//              last = pnMap.get('last_name');
//              first = pnMap.get('first_name');
//              contactNamestr = 'LastName = :last AND FirstName = :first';
//          }
//          else {
//              // 姓のみ
//              last = pnMap.get('last_name');
//              contactNamestr = 'LastName = :last';
//          }

//          //if (this.searchType == SmartViscaf.SB_NameCard_Util.SEARCHTYPE_NAME_SITE) {
//          if (qopt.querySite) {
//              if (String.isNotBlank(nc.SmartViscaf__division__c))
//                  division = '%' + varBindingExchange(nc.SmartViscaf__division__c) + '%';

//              if (String.isNotBlank(division))
//                  whereOrList.add('(Account.Name LIKE :accountName AND (Account.Site LIKE :division OR Department LIKE :division) AND ' + contactNamestr + ')');
//              else
//                  whereOrList.add('(Account.Name LIKE :accountName AND Account.Site = null And Department = null AND ' + contactNamestr + ')');
//          }
//          else {
//              whereOrList.add('(Account.Name LIKE :accountName AND ' + contactNamestr + ')');
//          }
//      }

//      String whereOrStr = '';
//      for (String s : whereOrList) {
//          whereOrStr += ' OR ' + s;
//      }
//      if (String.isNotBlank(whereOrStr))
//          whereOrStr = whereOrStr.removeStart(' OR ');

//      if (String.isNotBlank(whereOrStr)) {
//          Integer limitnumber = 997;
//          //オブジェクトの作成権限がないため、新規作成のタブを表示しないとなりました、
//          //その結果、タブを1000件のうち、自分で追加するのは１件しかないです
//          Boolean cor = Schema.sObjectType.Contact.isCreateable();
//          if (!cor == true) {
//              limitnumber = 999;
//          }
//          String soql = 'SELECT'
//              + ' AccountId, Id, Account.Name, Account.Owner.Name, Department, Name, Owner.Name,'
//              + ' MailingState, Title, MobilePhone, Email, LastModifiedDate'
//              + ' FROM Contact WHERE' + ' (' + whereOrStr + ') AND IsDeleted = false'
//              + ' ORDER BY Account.Name ASC, MailingState ASC NULLS LAST, Department ASC NULLS LAST limit ' + String.valueOf(limitnumber);
//          System.debug('setAccountTableByContact: soql: ' + soql);

//          contactList = Database.query(soql);
//          // 処理内容保存
//          //addOperation(soql);
//          //addOperation('Rows: ' + contactList.size());

//      }
//      return contactList;
////        System.debug('setAccountTableByContact: accTbl.size: ' + accTbl.size());
//  }

//  protected String varBindingExchange(String str) {
//    if (String.isBlank(str)) {
//      return str;
//    }
//    //アポストロフィーがある場合、escapeSingleQuotesメソッドがエスケープされるはずですが、
//    //なぜかうまくエスケープできてないので、エスケープする前にアポストロフィーをbase64を使って暗号化して、エスケープ後に元に戻す
//    String str1 = EncodingUtil.urlEncode(str, 'UTF-8');
//    Blob b = Blob.valueOf(str1);
//    String b64 = EncodingUtil.base64Encode(b);
//    str = str.replaceAll('\'',b64);
//    str = String.escapeSingleQuotes(getZenkakuBackslashToWildcard(str));
//    str = str.replaceAll(b64,'\'');
//    return str;
//  }

//  public static String getZenkakuBackslashToWildcard(String text) {
//    return String.isBlank(text) ? text : text.replaceAll('＼', '_');
//  }


}