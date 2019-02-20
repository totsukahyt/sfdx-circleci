/**
 *
 * SB_NameCardL_RegistSoslSoqlCanPicker
 *
 *      登録先候補の 取引先、取引先責任者を 収集するクラスの1つ
 *
 *     アカウントは SOSL して 所定以上なら、SOQLで完全一致検索する
 *
 *     KDDI様向け 管理パッケージ：SmartViscaRgq1 SB_Sv_UiRegistSoslSoqlCanCreater がベース
 *
 * Copyright (c) 2017-2018 SunBridge Inc.
 *
 **/
//public with sharing class  SB_NameCardL_RegistSoslSoqlCanPicker {
public with sharing class SB_NameCardL_RegistSoslSoqlCanPicker extends SB_NameCardL_RegistCanPickerAbstract {

  private static final String ACCOUNT_SEARCH = 'FIND :orgName IN Name FIELDS RETURNING Account(Id, Name, Owner.Name, {0} {1} ORDER BY Name ASC, BillingState ASC NULLS LAST, Site ASC NULLS LAST LIMIT 998)';
  //private static final String ACCOUNT_QUERY_ID_MATCH = 'SELECT Id, Name, Owner.Name, {0} FROM Account WHERE ID = :acntId';
  //private static final String ACCOUNT_QUERY = 'SELECT Id, Name, Owner.Name, {0} FROM Account WHERE {1}';
  //private static final String CONDITION_NAME = 'Name = :name';
  //private static final String CONDITION_SITE = 'Site = :dept';
  @TestVisible
  private static final String LABEL = '取引先責任者SOQL + SOSL あるいは SOQL完全一致';

  public SB_NameCardL_RegistSoslSoqlCanPicker() {
    super();
    //this.methodLabel = Label.SB_SvTl06_QuerySoslSoql;
    this.methodLabel = LABEL;
  }

  public SB_NameCardL_RegistSoslSoqlCanPicker(String label) {
    super();
    this.methodLabel = label;
  }

  public override Map<SObjectType, List<SObject>> create() {

     return this.otype2Objs;
  }

  public override Map<SObjectType, List<SObject>> create(Id cardId) {

     return this.otype2Objs;
  }

  //public override Map<Id, List<SObject>> create(Set<Id> cardIds) {
  //  Map<Id, List<SObject>> result = new Map<Id, List<SObject>>();
  public override Map<Id, Map<SObjectType, List<SObject>>> create(Set<Id> cardIds) {
    Map<Id, Map<SObjectType, List<SObject>>> result = new Map<Id, Map<SObjectType, List<SObject>>>();

    return result;
  }

  //// 候補のアカウント、コンタクトを収集
  //// 名刺レコードから
  //public override Map<SObjectType, List<SObject>> create(List<SmartViscaf__NameCard__c> cards, QueryOption qopt) {
  //  // 1. 取引先責任者SOQL検索
  //  //法人格抜き会社名の部分一致 + 部署の部分一致 + 氏名一致 OR メールアドレス一致  の取引先責任者を抽出
  //  List<Contact> conts = getContactsByAccountPartialMatch(cards[0], qopt);
  //  if (conts.size() > getTableThreshold()) {
  //    //// コンタクトのみで 閾値超えの場合だけ、コンタクトを捨てます。
  //    //this.accoutQueryStatus = QueryStatus.ABANDON;
  //    conts.clear();
  //  }

  //  // 2. 取引先SOSL検索
  //  //法人格抜き会社名をキーワード、部署を部分一致で抽出
  //  List<Account> acnts = getAccountsBySosl(cards[0], qopt);
  //  //List<Account> acnts = getSoqlAccounts(cards[0], qopt);


  //  if (conts.size() + acnts.size() > getTableThreshold()) {
  //    // 多かったら アカウントだけすてます
  //    acnts.clear();
  //    // SOSLで多かったらアカウントの完全一致検索を行う
  //    // 3 . 取引先SOQL検索 （設定によって実施、デフォルトは実施）
  //    //会社名の完全一致 + 部署の完全一致で取引先を抽出
  //    this.accoutQueryStatus = QueryStatus.PERFECT;
  //    acnts = getAccountsByPerfectMatch(cards[0], qopt);
  //    if (conts.size() + acnts.size() > getTableThreshold()) {
  //      // 多かったら アカウントだけすてます
  //      this.accoutQueryStatus = QueryStatus.ABANDON;
  //      acnts.clear();
  //    }
  //  }

  //  Map<Id, Account> id2Account = new Map<Id, Account>(acnts);
  //  if (cards[0].SmartViscaf__account__c != null && id2Account.containsKey(cards[0].SmartViscaf__account__c)== false) {
  //    // 4. 名刺のアカウントID値でクエリ
  //    Account linkedAccount = getAccountById(cards[0].SmartViscaf__account__c);
  //    acnts.add(linkedAccount);
  //    if (conts.size() + acnts.size() > getTableThreshold()) {
  //      // 大丈夫でなかった、テストで指摘された 修正 v 1.1
  //      this.accoutQueryStatus = QueryStatus.ABANDON;
  //      acnts.clear();
  //    }
  //  }

  //  if (!acnts.isEmpty()) {
  //    this.otype2Objs.put(Account.SObjectType, acnts);
  //  }
  //  if (!conts.isEmpty()) {
  //    this.otype2Objs.put(Contact.SObjectType, conts);
  //  }

  //  return this.otype2Objs;
  //}


  ////  Account の SOSL
  //private List<Account> getAccountsBySosl(SmartViscaf__NameCard__c nc, QueryOption qopt) {
  //  String orgName = SmartViscaf.SB_NameCard_Util.getCompanyName(nc.SmartViscaf__company_name__c);
  //  String dept = '%' + varBindingExchange(nc.SmartViscaf__division__c) + '%';    // 部署

  //  String query = String.format(ACCOUNT_SEARCH, new String[]{ String.join(new List<String>(ACCOUNT_FIELDS), ', '),
  //                    //(qopt.querySite && String.isNotBlank(nc.SmartViscaf__division__c) ? 'WHERE Site LIKE :dept' : '') });
  //                    (qopt.querySite ?(String.isNotBlank(nc.SmartViscaf__division__c) ? 'WHERE Site LIKE :dept' : 'WHERE Site = null') : '' )});
  //  System.debug(query);
  //  List<List<Account>> searchList = search.query(query);

  //  //for (List<Account> acnts : searchList) {
  //  //  for(Account acnt : acnts) {
  //  //    System.debug(acnt.Name + ' ' + acnt.Site + ' ' + acnt.Owner.Name);
  //  //  }
  //  //}
  //  // 処理内容保存
  //  //addOperation(query);
  //  //addOperation('Rows: ' + (searchList.isEmpty() ? '0' : String.valueOf(searchList[0].size())));
  //  return searchList.isEmpty() ? new List<Account>() : searchList[0];
  //}

  //private static SB_NameCardL_RegistSoslSoqlCanPicker instance;

  //public static SB_NameCardL_RegistSoslSoqlCanPicker getInstance() {
  //  if (instance == null) {
  //    instance = new SB_NameCardL_RegistSoslSoqlCanPicker();
  //  }
  //  return instance;
  //}
}