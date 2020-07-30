/**
 *
 * SB_NameCardL_RegistSoqlCountCanPicker
 *
 *      登録先候補の 取引先、取引先責任者を 収集するクラスの1つ
 *
 *     SOQLでカウントして続ける。
 *
 *     KDDI様向け 管理パッケージ：SmartViscaRgq1 SB_Sv_UiRegistSoqlCountCanCreater がベース
 *
 * Copyright (c) 2017-2018 SunBridge Inc.
 *
 **/
public with sharing class SB_NameCardL_RegistSoqlCountCanPicker extends SB_NameCardL_RegistCanPickerAbstract {

  @TestVisible
  private static final String LABEL = '取引先責任者SOQL + SOQLでカウントしてから続ける';

  //public SB_NameCardL_RegistSoqlCountCanPicker() {

  //}

  public SB_NameCardL_RegistSoqlCountCanPicker() {
    super();
    //this.methodLabel = Label.SB_SvTl06_QuerySoslSoql;
    this.methodLabel = LABEL;
  }

  public SB_NameCardL_RegistSoqlCountCanPicker(String label) {
    super();
    this.methodLabel = label;
  }

  //public SB_NameCardL_RegistSoqlCountCanPicker() {
  //  super();
  //  //this.methodLabel = Label.SB_SvTl06_QuerySoqlCount;
  //  this.methodLabel = LABEL;
  //}

  //public SB_NameCardL_RegistSoqlCountCanPicker(String label) {
  //  super();
  //  this.methodLabel = label;
  //}

  //public override Map<SObjectType, List<SObject>> create(SmartViscaf__NameCard__c card, TargetObject target) {
  //  List<SmartViscaf__NameCard__c> cards = new List<SmartViscaf__NameCard__c>();
  //  cards.add(card);
  //  return create(cards, target);
  //}

  //public override Map<SObjectType, List<SObject>> create(List<SmartViscaf__NameCard__c> cards, TargetObject target) {
  //  if (target == TargetObject.AccountContact) {
  //    return createAccountsContacts(cards);
  //  }
  //  else if (target == TargetObject.Lead) {
  //    return createLeads(cards);
  //  }
  //  return createBoth(cards);
  //}

  // 個別登録用  事前に SB_NameCardL_RegistQueryExecutor のinit で名刺レコードを特定しておきます。
  public override Map<SObjectType, List<SObject>> create() {
    this.qExecutor = SB_NameCardL_RegistQueryExecutor.getInstance();
    System.assert(this.qExecutor != null && this.qExecutor.isInitialized());

    //this.qExecutor.init(cardId);

    if (this.accountQs != null && this.contactQs != null) {
      createAccountsContacts();
    }
    else if (this.accountQs != null) {
      createAccounts();
    }
    else if (this.contactQs != null) {
      createContacts();
    }
    if (this.leadQs != null) {
      createLeads();
    }
    return this.otype2Objs;
  }

  //
  // SObjectType をキーに Account、Contact、Leadのリスト のマップを返します。
  // 個別登録のときに使う
  // SB_NameCardL_RegistQueryExecutor は事前にインスタンス化して 条件の名刺レコードの配列を渡しておきます。
  public override Map<SObjectType, List<SObject>> create(Id cardId) {

    this.qExecutor = SB_NameCardL_RegistQueryExecutor.getInstance();
    this.qExecutor.init(cardId);

    if (this.accountQs != null && this.contactQs != null) {
      createAccountsContacts();
    }
    else if (this.accountQs != null) {
      createAccounts();
    }
    else if (this.contactQs != null) {
      createContacts();
    }
    if (this.leadQs != null) {
      createLeads();
    }
    return this.otype2Objs;
  }

  // 名刺のレコードIDと一致する Account、Contact、Leadのリストのマップを返します。
  // SObject で返すので、呼び出し元でどのオブジェクトか判断します。
  // 一括登録のときに使う
  // SB_NameCardL_RegistQueryExecutor は事前にインスタンス化して 条件の名刺レコードの配列を渡しておきます。
  //public override Map<Id, List<SObject>> create(Set<Id> cardIds) {
  public override Map<Id, Map<SObjectType, List<SObject>>> create(Set<Id> cardIds) {
    //Map<Id, List<SObject>> result = new Map<Id, List<SObject>> ();
    Map<Id, Map<SObjectType, List<SObject>>> result = new Map<Id, Map<SObjectType, List<SObject>>> ();
    this.qExecutor = SB_NameCardL_RegistQueryExecutor.getInstance();
    List<SmartViscaf__NameCard__c> cards = this.qExecutor.init(cardIds);
    if (this.accountQs != null && this.contactQs != null) {
      createAccountsContacts();
    }
    else if (this.accountQs != null) {
      createAccounts();
    }
    else if (this.contactQs != null) {
      createContacts();
    }
    if (this.leadQs != null) {
      createLeads();
    }
    //　名刺ごとに、該当する オブジェクト−レコードのMap を作る。
    for (SmartViscaf__NameCard__c card : cards) {
      Map<SObjectType, List<SObject>> targets = new Map<SObjectType, List<SObject>> ();
      result.put(card.Id, targets);
      for (SObjectType otype : this.otype2Objs.keySet()) {
        List<SObject> objs = this.otype2Objs.get(otype);
        if (objs.isEmpty()) {
          continue;
        }
        SB_NameCardL_RegistQueryStrategy.QueryStrategy qs = this.otype2QueryStrategy.get(otype);
        for (SObject obj : objs) {
          if (!qs.isMatch(card, obj)) {
            continue;
          }
          List<SObject> records = null;
          if (targets.containsKey(otype)) {
            records = targets.get(otype);
          }
          else {
            records = new List<SObject>();
            targets.put(otype, records);
          }
          records.add(obj);
        }
      }
      if (Limits.getCpuTime() > Limits.getLimitCpuTime()-1000) {
        throw new SB_NameCardL_RegistCanPickerAbstractException(System.Label.SB_NCLD_Msg_ChooseLessBusinessCards);
      }
    }
    //printCard2Targets (result);
    return result;
  }

  //// デバッグ用
  //@TestVisible
  //private static void printCard2Targets(Map<Id, Map<SObjectType, List<SObject>>> input) {
  //  Set<String> fields = SB_NameCardL_RegistQueryStrategy.getNameCardFields();
  //  Set<Id> cardIds = new Set<Id>(input.keySet());
  //  String query = String.format('SELECT {0} FROM SmartViscaf__NameCard__c WHERE Id = :cardIds', new String[] { String.join(new List<String>(fields), ', ')});
  //  Map<Id, SObject> cards = new Map<Id, SObject>(Database.query(query));

  //  for(Id d : input.keySet()) {
  //    System.debug('NameCard: ' + cards.get(d));
  //    Map<SObjectType, List<SObject>> records = input.get(d);
  //    if (records.containsKey(Account.sObjecttype)) {
  //      for (SObject obj : records.get(Account.sObjecttype)) {
  //        Account acnt = (Account)obj;
  //        System.debug(acnt);
  //      }
  //    }
  //    if (records.containsKey(Contact.sObjecttype)) {
  //      for (SObject obj : records.get(Contact.sObjecttype)) {
  //        Contact cont = (Contact)obj;
  //        System.debug(cont);
  //      }
  //    }
  //    if (records.containsKey(Lead.sObjecttype)) {
  //      for (SObject obj : records.get(Lead.sObjecttype)) {
  //        Lead l = (Lead)obj;
  //        System.debug(l);
  //      }
  //    }
  //  }

  //}

  //// 個別登録での既存レコード検索
  //private Map<SObjectType, List<SObject>> createAccountsContacts(SmartViscaf__NameCard__c card) {
  //  cards.add(card);
  //  return createAccountsContacts(cards);
  //}

  // 候補のアカウント、コンタクトを収集
  // 名刺レコードから
  private Map<SObjectType, List<SObject>> createAccountsContacts() {
    this.otype2Objs.remove(Account.sObjectType);
    this.otype2Objs.remove(Contact.sObjectType);
    //SB_NameCardL_RegistQueryExecutor qExecutor = SB_NameCardL_RegistQueryExecutor.getInstance();
    // 1. コンタクトを収集
    //initContactQueryStrategy();  // クエリ方法を初期化
    List<Contact> conts = this.qExecutor.getCandidateRecords(this.contactQs);
    // 2. 部分一致する アカウント を カウント
    //initAccountQueryStrategy(); // クエリ方法を初期化
    this.queryProc = QueryProcess.PARTIAL;  // 最初は部分一致   のはず。
    Integer partialMatchAccount = this.qExecutor.getCandidateRecordCount(this.accountQs);

    System.debug(partialMatchAccount);
    List<Account> acnts; //  = new List<Account>();
    if (0 <= partialMatchAccount && (conts.size() + partialMatchAccount) < getAccountTableThreshold()) {
      // 少なかったら
      // 3.1. 部分一致する アカウント と 名刺から参照してるアカウントを収集 アカウント 0件でもクエリすいるけど、よしとしま。
      acnts = this.qExecutor.getCandidateRecords(this.accountQs);
    }
    else {
      // 多かったら
      // 3.2. 完全一致するアカウントを収集
      this.accountQs.setCompanyRule(SB_NameCardL_RegistQueryOption.CompanyMatcing.PerfectMatch); // 完全一致
      this.queryProc = QueryProcess.PERFECT;
      acnts = this.qExecutor.getCandidateRecords(this.accountQs);
      if ((acnts.isEmpty() && conts.size() > getAccountTableThreshold()) ||
          (!acnts.isEmpty() && conts.size() + acnts.size() > getAccountTableThreshold())) {
        // 完全一致するアカウントでも多かったら  すてる。
        this.queryProc = QueryProcess.ABANDON;
        acnts.clear();
        if (conts.size() >= getAccountTableThreshold()) {
          // コンタクトだけでも多かったら捨てる。
          conts.clear();
          // 名刺からコンタクト参照してるコンタクトを抽出 新仕様なので注意
          List<Contact> referencedContacts = this.qExecutor.getReferencedCandidateRecords(Contact.sObjectType);
          if (referencedContacts != null && !referencedContacts.isEmpty()) {
            conts.addAll(referencedContacts);
          }
        }
        // 名刺からアカウント参照してるアカウントを抽出 新仕様なので注意
        List<Account> referencedAccounts = this.qExecutor.getReferencedCandidateRecords(Account.sObjectType);
        if (referencedAccounts != null && !referencedAccounts.isEmpty()) {
          acnts.addAll(referencedAccounts);
        }
      }
      //Map<Id, Account> id2Account = new Map<Id, Account>();
      //if (!acnts.isEmpty()) {
      //  id2Account.putAll(acnts);
      //}
      //if (cards[0].SmartViscaf__account__c != null && id2Account.containsKey(cards[0].SmartViscaf__account__c) == false) {
      //  // 4. 名刺から参照してるアカウントを追加  超過する可能性があるけど、まあ大丈夫でしょう。
      //  Account linkedAccount = getReferencedCandidateRecords(cards[0].SmartViscaf__account__c);
      //  acnts.add(linkedAccount);
      //  if (conts.size() + acnts.size() > getAccountTableThreshold()) {
      //    // 大丈夫でなかった、テストで指摘された 修正 v 1.1
      //    this.queryProc = QueryProcess.ABANDON;
      //    acnts.clear();
      //  }
      //}
    }
    //if (!acnts.isEmpty()) {
      this.otype2Objs.put(Account.SObjectType, acnts);
    //}
    //if (!conts.isEmpty()) {
      this.otype2Objs.put(Contact.SObjectType, conts);
    //}
    return this.otype2Objs;
  }

  // 候補のアカウント、コンタクトを収集
  // 名刺レコードから
  private Map<SObjectType, List<SObject>> createContacts() {
    this.otype2Objs.remove(Account.sObjectType);
    //SB_NameCardL_RegistQueryExecutor qExecutor = SB_NameCardL_RegistQueryExecutor.getInstance();
    // 1. コンタクトを収集
    //initContactQueryStrategy();  // クエリ方法を初期化
    List<Contact> conts = this.qExecutor.getCandidateRecords(this.contactQs);
    //if (!conts.isEmpty()) {
      this.otype2Objs.put(Contact.SObjectType, conts);
    //}
    return this.otype2Objs;
  }

  // 候補のアカウントを収集
  // 名刺レコードから
  private Map<SObjectType, List<SObject>> createAccounts() {
    this.otype2Objs.remove(Account.sObjectType);
    //SB_NameCardL_RegistQueryExecutor qExecutor = SB_NameCardL_RegistQueryExecutor.getInstance();
    // 2. 部分一致する アカウント を カウント
    //initAccountQueryStrategy(); // クエリ方法を初期化
    this.queryProc = QueryProcess.PARTIAL;  // 最初は部分一致   のはず。
    Integer partialMatchAccount = this.qExecutor.getCandidateRecordCount(this.accountQs);

    System.debug(partialMatchAccount);
    List<Account> acnts; //  = new List<Account>();
    if (0 <= partialMatchAccount && partialMatchAccount < getAccountTableThreshold()) {
      // 少なかったら
      // 3.1. 部分一致する アカウント と 名刺から参照してるアカウントを収集
      acnts = this.qExecutor.getCandidateRecords(this.accountQs);
    }
    else {
      // 多かったら
      // 3.2. 完全一致するアカウントを収集
      this.accountQs.setCompanyRule(SB_NameCardL_RegistQueryOption.CompanyMatcing.PerfectMatch); // 完全一致
      this.queryProc = QueryProcess.PERFECT;
      acnts = this.qExecutor.getCandidateRecords(this.accountQs);
      if (acnts.size() > getAccountTableThreshold()) {
        // 完全一致するアカウントでも多かったら  すてる。
        this.queryProc = QueryProcess.ABANDON;
        acnts.clear();
        // 名刺からアカウント参照してるアカウントを抽出 新仕様なので注意
        List<Account> referencedAccounts = this.qExecutor.getReferencedCandidateRecords(Account.sObjectType);
        if (referencedAccounts != null && !referencedAccounts.isEmpty()) {
          acnts.addAll(referencedAccounts);
        }
      }
      //Map<Id, Account> id2Account = new Map<Id, Account>();
      //if (!acnts.isEmpty()) {
      //  id2Account.putAll(acnts);
      //}
      //if (cards[0].SmartViscaf__account__c != null && id2Account.containsKey(cards[0].SmartViscaf__account__c) == false) {
      //  // 4. 名刺から参照してるアカウントを追加  超過する可能性があるけど、まあ大丈夫でしょう。
      //  Account linkedAccount = getReferencedCandidateRecords(cards[0].SmartViscaf__account__c);
      //  acnts.add(linkedAccount);
      //  if (conts.size() + acnts.size() > getAccountTableThreshold()) {
      //    // 大丈夫でなかった、テストで指摘された 修正 v 1.1
      //    this.queryProc = QueryProcess.ABANDON;
      //    acnts.clear();
      //  }
      //}
    }
    //if (!acnts.isEmpty()) {
      this.otype2Objs.put(Account.SObjectType, acnts);
    //}
    return this.otype2Objs;
  }

  private Map<SObjectType, List<SObject>> createLeads() {
    this.otype2Objs.remove(Lead.sObjectType);
    //SB_NameCardL_RegistQueryExecutor qExecutor = SB_NameCardL_RegistQueryExecutor.getInstance();
    // 1. 部分一致する リード を カウント
    //initLeadQueryStrategy(); // クエリ方法を初期化
    this.queryProc = QueryProcess.PARTIAL;  // 最初は部分一致   のはず。
    Integer partialMatchLead = this.qExecutor.getCandidateRecordCount(this.leadQs);
    System.debug(partialMatchLead);
    List<Lead> leads; //  = new List<Account>();
    if (0 <= partialMatchLead && partialMatchLead < getLeadTableThreshold()) {
      // 少なかったら
      // 2.1. 部分一致する リード と 名刺から参照してるリードを収集
      leads = this.qExecutor.getCandidateRecords(this.leadQs);
    }
    else {
      // 多かったら
      // 2.2. 完全一致するリードを収集
      this.leadQs.setCompanyRule(SB_NameCardL_RegistQueryOption.CompanyMatcing.PerfectMatch); // 完全一致
      this.queryProc = QueryProcess.PERFECT;
      leads = this.qExecutor.getCandidateRecords(this.leadQs);
      if (leads.size() > getLeadTableThreshold()) {
        // 完全一致するアカウントでも多かったら  すてる。
        this.queryProc = QueryProcess.ABANDON;
        leads.clear();
        // 名刺からリード参照してるリードを抽出 新仕様なので注意
        List<Lead> referencedLeads = this.qExecutor.getReferencedCandidateRecords(Lead.sObjectType);
        if (referencedLeads != null && !referencedLeads.isEmpty()) {
          leads.addAll(referencedLeads);
        }
      }
    }
    //if (!leads.isEmpty()) {
      this.otype2Objs.put(Lead.SObjectType, leads);
    //}
    return this.otype2Objs;
  }

  private Map<SObjectType, List<SObject>> createBoth() {
    createAccountsContacts();
    createLeads();
    return this.otype2Objs;
  }

  //// 名刺からアカウント参照してるアカウントを抽出
  //private List<Account> getReferencedAccounts(List<SmartViscaf__NameCard__c> cards) {
  //  Set<Id> ids = new Set<Id>();
  //  for (SmartViscaf__NameCard__c c : cards) {
  //    if (c.SmartViscaf__account__c != null) {
  //      ids.add(c.SmartViscaf__account__c);
  //    }
  //  }
  //  if (!ids.isEmpty()) {
  //    return qExecutor.getReferencedCandidateRecords(this.accountQs, ids);
  //  }
  //  else {
  //    return null;
  //  }
  //}

  //// 名刺からアカウント参照してるリードを抽出
  //private List<Lead> getReferencedLeads(List<SmartViscaf__NameCard__c> cards) {
  //  Set<Id> ids = new Set<Id>();
  //  for (SmartViscaf__NameCard__c c : cards) {
  //    if (c.SmartViscaf__lead__c != null) {
  //      ids.add(c.SmartViscaf__lead__c);
  //    }
  //  }
  //  if (!ids.isEmpty()) {
  //    return qExecutor.getReferencedCandidateRecords(this.leadQs, ids);
  //  }
  //  else {
  //    return null;
  //  }
  //}

  // 部分一致する アカウント と 名刺から参照してるアカウント のレコード数をカウント
  //private Integer getAccountCountByPartialMatch(SmartViscaf__NameCard__c nc, QueryOption qopt) {
  //  if (String.isBlank(nc.SmartViscaf__company_name__c)) {
  //    return 0;
  //  }
  //  Integer result = -1;
  //  String name = '%' + varBindingExchange(SmartViscaf.SB_NameCard_Util.getCompanyName(nc.SmartViscaf__company_name__c)) + '%';
  //  String dept = '%' + varBindingExchange(nc.SmartViscaf__division__c) + '%';

  //  List<String> params = new List<String>();
  //  params.add('Name LIKE :name');
  //  if (qopt.querySite) {
  //    params.add( String.isNotBlank(nc.SmartViscaf__division__c) ? 'Site LIKE :dept' : 'Site = null');
  //  }
  //  String condition = String.join(params, ' AND ');
  //  if (nc.SmartViscaf__account__c != null) {
  //    condition = '(' + condition +') OR Id=\'' + nc.SmartViscaf__account__c +'\'';
  //  }

  //  String query = String.format(ACCOUNT_QUERY_COUNT,  new String[]{ String.join(new List<String>(ACCOUNT_FIELDS), ', '), condition });
  //  System.debug(query);
  //  List<AggregateResult> ars = Database.query(query);
  //  System.debug(ars);
  //  for (AggregateResult ar : ars) {
  //    result = (Integer)ar.get('cnt');
  //    break;
  //  }
  //  // 処理内容保存
  //  //addOperation(query);
  //  //addOperation('Count: ' + result);
  //  return result;
  //}

  //// 部分一致する アカウント と 名刺から参照してるアカウントを収集
  //private List<Account> getAccountsByPartialMatch(SmartViscaf__NameCard__c nc, QueryOption qopt) {
  //  String name = '%' + varBindingExchange(SmartViscaf.SB_NameCard_Util.getCompanyName(nc.SmartViscaf__company_name__c)) + '%';
  //  String dept = '%' + varBindingExchange(nc.SmartViscaf__division__c) + '%';
  //  List<String> params = new List<String>();
  //  params.add('Name LIKE :name');
  //  if (qopt.querySite) {
  //    params.add( String.isNotBlank(nc.SmartViscaf__division__c) ? 'Site LIKE :dept' : 'Site = null');
  //  }
  //  String condition = String.join(params, ' AND ');
  //  if (nc.SmartViscaf__account__c != null) {
  //    condition = '(' + condition +') OR Id=\'' + nc.SmartViscaf__account__c +'\'';
  //  }

  //  String query = String.format(ACCOUNT_QUERY,  new String[]{ String.join(new List<String>(ACCOUNT_FIELDS), ', '), condition, getQueryLimit() });
  //  System.debug('query is' + query);
  //  List<Account> acnts = Database.query(query);
  //  //System.assert(!acnts.isEmpty());  やめます
  //  // 処理内容保存
  //  //addOperation(query);
  //  //addOperation('Rows: ' + acnts.size());
  //  return acnts;

  //}

  //private static SB_NameCardL_RegistSoqlCountCanPicker instance;

  //public static SB_NameCardL_RegistSoqlCountCanPicker getInstance() {
  //  if (instance == null) {
  //    instance = new SB_NameCardL_RegistSoqlCountCanPicker();
  //  }
  //  return instance;
  //}
}