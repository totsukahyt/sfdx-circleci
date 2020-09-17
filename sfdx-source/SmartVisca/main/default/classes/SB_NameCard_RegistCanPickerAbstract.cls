/**
 *
 * SB_NameCard_RegistCanPickerAbstract
 *
 *  登録先候補の 取引先、取引先責任者を 収集するクラスの基底
 *     KDDI様向け 管理パッケージ：SmartViscaRgq1 SB_Sv_UiRegistCanCreaterAbstract がベース
 *
 * (c) 2019 Sunbridge Inc.
 *
 *  @author K.Yoshida
 *  @Version 2.2  2019.02.XX SV_DEV-1558 LEX 取引先登録 一括画面をLXパッケージ同様のLC化で追加
 *  @Version 2.4  2019.06.xx sawano SV_DEV-665 取引先・取引先責任者登録のLDV対応の改造 = 取引先・取引先責任者登録の取引先400万件対応（検索のSOSL化）
 *
 **/
public abstract class SB_NameCard_RegistCanPickerAbstract {
  public class SB_NameCard_RegistCanPickerAbstractException extends Exception {}

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
    queryProcessComment.put(QueryProcess.PERFECT, String.format(System.Label.SB_NC_FORM_RegistPerfectMatchCandidate, new String[] { acnt } ));
    queryProcessComment.put(QueryProcess.ABANDON, String.format(SYstem.Label.SB_NC_FORM_RegistOverCandidateRecords, new String[] { acnt } ));
  }

  public String getQueryProcessComment() {
    return queryProcessComment.get(this.queryProc);
  }

  public QueryProcess getAccountQueryProcess() {
    return queryProc;
  }

  public QueryProcess getMatchMethod() {
    return this.queryProc;
  }

  private static final Integer TABLE_THRESHOLD = 997;
  private static final Integer TABLE_THRESHOLD_NOCONTACT = 998;

  protected Map<SObjectType, List<SObject>> otype2Objs; // 検索結果を SObjectType ごとに保持

  //protected SB_NC_RegistQueryOption queryOption;
  protected SB_NC_RegistQueryStrategy.AccountQueryStrategy accountQs;
  protected SB_NC_RegistQueryStrategy.ContactQueryStrategy contactQs;
  // コンタクトのサブクエリを含む アカウント クエリ 用
  protected SB_NC_RegistQueryStrategy.AccountContactQueryStrategy acntContQs;

  protected SB_NC_RegistQueryExecutor qExecutor;

  protected Map<SObjectType, SB_NC_RegistQueryStrategy.QueryStrategy> otype2QueryStrategy;
  //  = new Map<SObjectType, SB_NC_RegistQueryStrategy.QueryStrategy> {
  //    Account.sObjectType => accountQs,
  //    Contact.sObjectType => contactQs,
  //    Lead.sObjectType => leadQs
  //};

  //protected List<String> operations;      // どんなクエリをしたか
  public virtual Boolean isRelationQuery() { return false; } // Accountのクエリで COntactのリレーションクエリする人？

  public SB_NameCard_RegistCanPickerAbstract() {
    this.otype2QueryStrategy = new Map<SObjectType, SB_NC_RegistQueryStrategy.QueryStrategy>();
    this.accountQs = null;
    this.contactQs = null;
    this.otype2Objs = new Map<SObjectType, List<SObject>>();
    this.qExecutor = SB_NC_RegistQueryExecutor.getInstance();
    //this.queryProc = QueryProcess.PARTIAL;
    //this.operations = new List<String>();
  }

  // 初期化
  // クエリオプションに従って、QueryStrategy を作っておきます。
  // アカウントとコンタクトとそれぞれに 検索オプションを渡されたとき
  public void init(List<SB_NC_RegistQueryOption> queryOptions) {
    for (SB_NC_RegistQueryOption qo : queryOptions) {
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
    }
  }

  // 初期化
  // クエリオプションに従って、QueryStrategy を作っておきます。
  // 検索オプションは１つ。
  // 一括はないので、どちらか
  public void init(SB_NC_RegistQueryOption qo) {
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
  }


  public void init(SB_NC_RegistQueryStrategy.QueryStrategy qs) {
    if (qs instanceOf SB_NC_RegistQueryStrategy.AccountQueryStrategy) {
      this.accountQs = (SB_NC_RegistQueryStrategy.AccountQueryStrategy)qs;
    }
    else if (qs instanceOf SB_NC_RegistQueryStrategy.ContactQueryStrategy) {
      this.contactQs = (SB_NC_RegistQueryStrategy.ContactQueryStrategy)qs;
    }
    else if (qs instanceOf SB_NC_RegistQueryStrategy.AccountContactQueryStrategy) {
      // コンタクトのサブクエリを含む アカウント クエリ 用
      this.acntContQs = (SB_NC_RegistQueryStrategy.AccountContactQueryStrategy)qs;
    }
  }

  public void addQueryFields(SObjectType otype, Set<String> fields) {
    if (otype == Account.sObjecttype) {
      this.accountQs.addQueryFields(fields);
    }
    else if (otype == Contact.sObjecttype) {
      this.contactQs.addQueryFields(fields);
    }
  }

  // // SObjectType をキーに Account、Contact、Leadのリスト のマップを返します。
  // // 個別登録用  SB_NC_RegistQueryExecutor は事前にインスタンス化して 条件の名刺レコードの配列を渡しておきます。
  // public Map<SObjectType, List<SObject>> create() {
  //   this.qExecutor = SB_NC_RegistQueryExecutor.getInstance();
  //   System.assert(this.qExecutor != null && this.qExecutor.isInitialized());

  //   if (this.accountQs != null && this.contactQs != null) {
  //     createAccountsContacts();
  //   }
  //   else if (this.accountQs != null) {
  //     createAccounts();
  //   }
  //   else if (this.contactQs != null) {
  //     createContacts();
  //   }
  //   return this.otype2Objs;
  // }

  // // SObjectType をキーに Account、Contact、Leadのリスト のマップを返します。
  // // 個別登録用  この中で SB_NC_RegistQueryExecutor のinit で名刺レコードを特定してます。
  // public Map<SObjectType, List<SObject>> create(Id cardId) {
  //   try { 
  //     this.qExecutor = SB_NC_RegistQueryExecutor.getInstance();
  //     this.qExecutor.init(cardId);
  //   }
  //   catch(Exception e) {
  //     System.debug(e);
  //   }
  //   if (!this.qExecutor.isInitialized()) {
  //     return this.otype2Objs;
  //   }
  //   if (this.accountQs != null && this.contactQs != null) {
  //     // これはないはず
  //     // リード拡張では、リードとアカウントと返すけど、基本の個別で２つはない
  //     createAccountsContacts();
  //   }
  //   else if (this.accountQs != null) {
  //     // 個別のときなので、これか
  //     createAccounts();
  //   }
  //   else if (this.contactQs != null) {
  //     // 個別のときなので、これか
  //     createContacts();
  //   }
  //   // リード拡張のとき
  //   // if (this.leadQs != null) {
  //   //   createLeads();
  //   // }
  //   return this.otype2Objs;
  // }

  // // 名刺のレコードIDと一致する Account、Contact、Leadのリストのマップを返します。
  // // SObject で返すので、呼び出し元でどのオブジェクトか判断します。
  // // 一括登録のときに使う この中で SB_NC_RegistQueryExecutor のinit で名刺レコードを特定してます。
  // public Map<Id, Map<SObjectType, List<SObject>>> create(Set<Id> cardIds) {
  //   Map<Id, Map<SObjectType, List<SObject>>> result = new Map<Id, Map<SObjectType, List<SObject>>> ();
  //   List<NameCard__c> cards;
  //   try { 
  //     this.qExecutor = SB_NC_RegistQueryExecutor.getInstance();
  //     cards = this.qExecutor.init(cardIds);
  //   }
  //   catch(Exception e) {
  //     System.debug(e);
  //   }
  //   if (!this.qExecutor.isInitialized()) {
  //     return result;
  //   }
  //   if (this.accountQs != null && this.contactQs != null) {
  //     // 一括のとき または、個別Classic
  //     createAccountsContacts();
  //   }
  //   else if (this.accountQs != null) {
  //     // これはないはず
  //     createAccounts();
  //   }
  //   else if (this.contactQs != null) {
  //     // これはないはず
  //     createContacts();
  //   }
  //   // リード拡張のとき
  //   // if (this.leadQs != null) {
  //   //   createLeads();
  //   // }
  //   //　名刺ごとに、該当する オブジェクト−レコードのMap を作る。
  //   for (NameCard__c card : cards) {
  //     Map<SObjectType, List<SObject>> targets = new Map<SObjectType, List<SObject>> ();
  //     result.put(card.Id, targets);
  //     for (SObjectType otype : this.otype2Objs.keySet()) {
  //       List<SObject> objs = this.otype2Objs.get(otype);
  //       List<SObject> records = new List<SObject>();
  //       targets.put(otype, records);    // オブジェクトごと 空でも リストを作っとく。
  //       if (objs.isEmpty()) {
  //         continue;
  //       }
  //       SB_NC_RegistQueryStrategy.QueryStrategy qs = this.otype2QueryStrategy.get(otype);
  //       for (SObject obj : objs) {
  //         if (!qs.isMatch(card, obj)) {
  //           continue;
  //         }
  //         // List<SObject> records = null;
  //         // if (targets.containsKey(otype)) {
  //         //   records = targets.get(otype);
  //         // }
  //         // else {
  //         //   records = new List<SObject>();
  //         //   targets.put(otype, records);
  //         // }
  //         records.add(obj);
  //       }
  //     }
  //     if (Limits.getCpuTime() > Limits.getLimitCpuTime()-1000) {
  //       throw new SB_NameCard_RegistCanPickerAbstractException(System.Label.SB_NC_Msg_ChooseLessBusinessCards);
  //     }
  //   }
  //   //printCard2Targets (result);
  //   return result;
  // }

  public Map<Id, Map<SObjectType, List<SObject>>> create() {
    Map<Id, Map<SObjectType, List<SObject>>> result = new Map<Id, Map<SObjectType, List<SObject>>> ();
    if (!this.qExecutor.isInitialized()) {
      return result;
    }
    if (this.accountQs != null && this.contactQs != null) {
      // 一括のとき または、個別Classic
      createAccountsContacts();
    }
    else if (this.accountQs != null) {
      // これはないはず
      createAccounts();
    }
    else if (this.contactQs != null) {
      // これはないはず
      createContacts();
    }
    // リード拡張のとき
    // if (this.leadQs != null) {
    //   createLeads();
    // }
    //　名刺ごとに、該当する オブジェクト−レコードのMap を作る。
    for (NameCard__c card : this.qExecutor.getNameCards()) {
      Map<SObjectType, List<SObject>> targets = new Map<SObjectType, List<SObject>> ();
      result.put(card.Id, targets);
      for (SObjectType otype : this.otype2Objs.keySet()) {
        List<SObject> objs = this.otype2Objs.get(otype);
        List<SObject> records = new List<SObject>();
        targets.put(otype, records);    // オブジェクトごと 空でも リストを作っとく。
        if (objs.isEmpty()) {
          continue;
        }
        SB_NC_RegistQueryStrategy.QueryStrategy qs = this.otype2QueryStrategy.get(otype);
        if (qs.isNeedMatching()) {
          for (SObject obj : objs) {
            if (!qs.isReferenced(card, obj) && !qs.isMatch(card, obj)) {
              continue;
            }
            records.add(obj);
          }
        }
        else {
          // 個別で、...のときは、全て候補
          records.addAll(objs);
        }
      }
      if (Limits.getCpuTime() > Limits.getLimitCpuTime()-1000) {
        throw new SB_NameCard_RegistCanPickerAbstractException(System.Label.SB_NC_Msg_ChooseLessBusinessCards);
      }
    }
    //printCard2Targets (result);
    return result;
  }

  // 候補のコンタクトを収集  共通
  // 名刺レコードから
  protected virtual Map<SObjectType, List<SObject>> createContacts() {
    this.otype2Objs.remove(Account.sObjectType);
    //SB_NC_RegistQueryExecutor qExecutor = SB_NC_RegistQueryExecutor.getInstance();
    // 1. コンタクトを収集
    //initContactQueryStrategy();  // クエリ方法を初期化
    List<Contact> conts = this.qExecutor.getCandidateRecords(this.contactQs);
    // からでも入れる
    this.otype2Objs.put(Contact.SObjectType, conts);
    return this.otype2Objs;
  }

  protected abstract Map<SObjectType, List<SObject>> createAccounts();
  protected abstract Map<SObjectType, List<SObject>> createAccountsContacts();

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

  private void initAccountQueryStrategy(SB_NC_RegistQueryOption queryOption) {
    if (this.accountQs != null) {  // わたされてたら初期化しない
      this.accountQs.setQuryOption(queryOption);
      return;
    }
    this.accountQs = new SB_NC_RegistQueryStrategy.AccountQueryStrategy(queryOption);
    // this.accountQs.setCompanyRule(SB_NC_RegistQueryOption.CompanyMatcing.PartialMatch); // 法人格除いて部分一致
    this.accountQs.setOrderBy('Name ASC, BillingState ASC NULLS LAST, Site ASC NULLS LAST');
    this.accountQs.setMaxLimit(getAccountQueryLimit());
  }

  private void initContactQueryStrategy(SB_NC_RegistQueryOption queryOption) {
    if (this.contactQs != null) {  // わたされてたら初期化しない
      this.contactQs.setQuryOption(queryOption);
      return;
    }
    this.contactQs = new SB_NC_RegistQueryStrategy.ContactQueryStrategy(queryOption);
    // this.contactQs.setCompanyRule(SB_NC_RegistQueryOption.CompanyMatcing.PartialMatch); // 法人格除いて部分一致
    // this.contactQs.setQueryLastName(true);
    // this.contactQs.setQueryFirstName(true);
    // this.contactQs.setQueryEMail(true);
    this.contactQs.setOrderBy('Account.Name ASC, MailingState ASC NULLS LAST, Department ASC NULLS LAST');
    this.contactQs.setMaxLimit(getContactQueryLimit());
  }

  /**
  * createCandidatePicker 2つで 候補抽出処理 を選択してインスタンス化します。
  *  SOSL版 か SOQL版 いずれか

  以下のいずれかの場合、SOQL
  1) カスタム設定 個別用AccountRegistSearchMethod__c、 一括用AccountBulkRegistSearchMethod__cが true なら 必ずSOQL版
  2) 会社名 完全一致 （かつ 法人格 正称と略称を区別する）場合 SOQL版 

  以下の場合、SOSL
  ・前記1)2)に当てはまらない個別登録は SOSL 版 LEX も Classicも
  *   
  */
  // 候補抽出処理をインスタンス化 
  // Wizrd形式 LEX 個別登録用
  public static SB_NameCard_RegistCanPickerAbstract createCandidatePicker(SB_NC_RegistQueryOption qo, Id cardId) {
    SB_NameCard_RegistCanPickerAbstract result;
    SB_NC_RegistQueryExecutor qExecutor = SB_NC_RegistQueryExecutor.getInstance();
    try { 
      qExecutor.init(cardId);
    }
    catch(Exception e) {
      System.debug(e);
    }
    if (qo.target != Account.getSObjectType() || qo.isUseSoqlOption() || !qExecutor.canUseSosl) {  // オプションによって SOSLではなく、SOQLを使うことになる？
      // SOQL
      result = new SB_NameCard_RegistSoqlCountCanPicker();
    }
    else {
      // SOSL
      result = new SB_NameCard_RegistSoslSoqlCanPicker();
    }
    result.init(qo);
    return result;
  }

  // 候補抽出処理をインスタンス化 
  // Classic/LEX 一括登録、Classic個別 用
  //  => 複数オブジェクトまとめて検索用
  public static SB_NameCard_RegistCanPickerAbstract createCandidatePicker(List<SB_NC_RegistQueryOption> queryOptions, Set<Id> cardIds) {
    SB_NameCard_RegistCanPickerAbstract result;
    SB_NC_RegistQueryExecutor qExecutor = SB_NC_RegistQueryExecutor.getInstance();
    try { 
      qExecutor.init(cardIds);
    }
    catch(Exception e) {
      System.debug(e);
    }
    if (isUseSoqlOptions(queryOptions) || !qExecutor.canUseSosl) { // オプションによって SOSLではなく、SOQLを使うことになる？
      // SOQL
      result = new SB_NameCard_RegistSoqlCountCanPicker();
    }
    else {
      // SOSL 
      result = new SB_NameCard_RegistSoslSoqlCanPicker();
    }
    result.init(queryOptions);
    return result;
  }  



  // // 候補抽出処理をインスタンス化 
  // // Wizrd形式 LEX 個別登録用
  // public static SB_NameCard_RegistCanPickerAbstract createCandidatePicker(SB_NC_RegistQueryOption qo) {
  //   SB_NameCard_RegistCanPickerAbstract result;
  //   if (qo.isUseSoqlOption() || qo.target != Account.getSObjectType()) {  // オプションによって SOSLではなく、SOQLを使うことになる？
  //     // SOQL
  //     result = new SB_NameCard_RegistSoqlCountCanPicker();
  //   }
  //   else {
  //     // SOSL
  //     result = new SB_NameCard_RegistSoslSoqlCanPicker();
  //   }
  //   result.init(qo);
  //   return result;
  // }

  // // 候補抽出処理をインスタンス化 
  // // Classic/LEX 一括登録、Classic個別 用
  // //  => 複数オブジェクトまとめて検索用
  // public static SB_NameCard_RegistCanPickerAbstract createCandidatePicker(List<SB_NC_RegistQueryOption> queryOptions) {
  //   SB_NameCard_RegistCanPickerAbstract result;
  //   if (isUseSoqlOptions(queryOptions)) { // オプションによって SOSLではなく、SOQLを使うことになる？
  //     // SOQL
  //     result = new SB_NameCard_RegistSoqlCountCanPicker();
  //   }
  //   else {
  //     // SOSL 
  //     result = new SB_NameCard_RegistSoslSoqlCanPicker();
  //   }
  //   result.init(queryOptions);
  //   return result;
  // }  

  // オプションによって SOSLではなく、SOQLを使うことになる？
  //  アカウントの SB_NC_RegistQueryOption.isSoqlOption で調べる
  //    一括で カスタム設定が SOQL
  //    個別で カスタム設定が SOQL
  //    会社名が完全一致検索 で 会社名の法人格は略称・正称を区別 じゃない。=> (NULL か FALSE)でない SOQLの完全一致検索
  @TestVisible
  private static Boolean isUseSoqlOptions(List<SB_NC_RegistQueryOption> queryOptions) {
    System.assert(!queryOptions.isEmpty());
    for (SB_NC_RegistQueryOption qo : queryOptions) {
      if (qo.target == Account.getSObjectType()) {
        return qo.isUseSoqlOption();
      }
    }
    return false;
  }

}