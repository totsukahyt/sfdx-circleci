/**
 *
 * SB_NameCard_RegistSoslSoqlCanPicker
 *
 *      登録先候補の 取引先、取引先責任者を 収集するクラスの1つ
 *     アカウントは SOSL して 所定以上なら、SOQLで完全一致検索する
 *
 * LDV対応取引先登録拡張バージョン
 *
 *     KDDI様向け 管理パッケージ：SmartViscaRgq1 SB_Sv_UiRegistSoslSoqlCanCreater がベース
 *
 * Copyright (c) 2017-2019 SunBridge Inc.
 *
 *  @author sawano
 *  @Version1  2019.06.xx v2.4 SV_DEV-665 取引先・取引先責任者登録のLDV対応の改造（SOSL化）
 *
 **/
public with sharing class SB_NameCard_RegistSoslSoqlCanPicker extends SB_NameCard_RegistCanPickerAbstract {

  private static final String ACCOUNT_SEARCH = 'FIND :orgName IN Name FIELDS RETURNING Account(Id, Name, Owner.Name, {0} {1} ORDER BY Name ASC, BillingState ASC NULLS LAST, Site ASC NULLS LAST LIMIT 998)';

  public SB_NameCard_RegistSoslSoqlCanPicker() {
    super();
  }


  // 候補のアカウントを収集
  // 名刺レコードから
  // LEX 個別 Wizard で 中間一致 または、完全一致だけど法人格正称・略称同一視 のとき
  protected override Map<SObjectType, List<SObject>> createAccounts() {
    this.otype2Objs.remove(Account.sObjectType);
    // 1. 参照されてるアカウントを収集 SOQLでやるしかない
    List<Account> acnts = (List<Account>)this.qExecutor.getReferencedCandidateRecords(this.accountQs);
    Map<Id, Account> refAcntMap = new Map<Id, Account>(acnts);
    // 2. SOSL で アカウント を 収集
    this.queryProc = QueryProcess.PARTIAL;  // 最初は部分一致   のはず。
    Map<Id, Account> acntMap = new Map<Id, Account>((List<Account>)this.qExecutor.getCandidateRecordsBySosl(this.accountQs));
    acntMap.keySet().removeAll(refAcntMap.keySet()); // 参照されてるアカウントの重複を排除
    if (acnts.size() + acntMap.size() > getAccountTableThreshold()) {
      // 多かったら SOSLした アカウントだけすてます
      acntMap.clear();
      // SOSLで多かったらアカウントの完全一致検索を行う
      // 3 . 取引先SOQL検索 
      //会社名の一字一句完全一致 + 部署の完全一致で取引先を抽出
      this.accountQs.setCompanyRule(SB_NC_RegistQueryOption.CompanyMatcing.PerfectMatch); // 完全一致
      this.accountQs.setDeptRule(SB_NC_RegistQueryOption.DeptMatcing.ExactMatch);   // 完全一致
      this.queryProc = QueryProcess.PERFECT;
      acntMap = new Map<Id, Account>((List<Account>)this.qExecutor.getCandidateRecords(this.accountQs));
      acntMap.keySet().removeAll(refAcntMap.keySet()); // 参照されてるアカウントの重複を排除
      if (acnts.size() + acntMap.size() > getAccountTableThreshold()) {
        // 多かったら アカウントだけすてます
        this.queryProc = QueryProcess.ABANDON;
         acntMap.clear();
      }
    }
    if (!acntMap.isEmpty()) {
      acnts.addAll(acntMap.values());
    }
    this.otype2Objs.put(Account.SObjectType, acnts);
    return this.otype2Objs;
  }

  // 候補のアカウント、コンタクトを収集
  // アカウント SOSL　と コンタクト SOQL 
  // Classic の個別 のみ
  protected override Map<SObjectType, List<SObject>> createAccountsContacts() {
    this.otype2Objs.remove(Account.sObjectType);
    this.otype2Objs.remove(Contact.sObjectType);
    // コンタクトがいるだけのアカウントは検索対象外
    this.accountQs.setNoContactOnly(true);   

    // 1. コンタクトを収集
    List<Contact> conts = this.qExecutor.getCandidateRecords(this.contactQs);
    if (conts.size() > getAccountTableThreshold()) {
      //// コンタクトのみで 閾値超えの場合だけ、コンタクトを捨てます。
      //this.accoutQueryStatus = QueryStatus.ABANDON;
      conts.clear();
    }
    // 2. 参照されてるアカウントを収集
    List<Account> acnts = (List<Account>)this.qExecutor.getReferencedCandidateRecords(this.accountQs);
    Map<Id, Account> refAcntMap = new Map<Id, Account>(acnts);
    // 3. SOSL で 部分一致する アカウント を 収集
    this.queryProc = QueryProcess.PARTIAL;  // 最初は部分一致   のはず。
    Map<Id, Account> acntMap = new Map<Id, Account>((List<Account>)this.qExecutor.getCandidateRecordsBySosl(this.accountQs));
    acntMap.keySet().removeAll(refAcntMap.keySet()); // 参照されてるアカウントの重複を排除
    if (conts.size() + acnts.size() + acntMap.size() > getAccountTableThreshold()) {
      // 多かったら アカウントだけすてます
      acntMap.clear();
      // SOSLで多かったらアカウントの完全一致検索を行う
      // 4. 取引先SOQL検索 （設定によって実施、デフォルトは実施）
      //会社名の一字一句完全一致 + 部署の完全一致で取引先を抽出
      this.accountQs.setCompanyRule(SB_NC_RegistQueryOption.CompanyMatcing.PerfectMatch); // 完全一致
      this.accountQs.setDeptRule(SB_NC_RegistQueryOption.DeptMatcing.ExactMatch);   // 完全一致
      this.queryProc = QueryProcess.PERFECT;
      acntMap = new Map<Id, Account>((List<Account>)this.qExecutor.getCandidateRecords(this.accountQs));
      acntMap.keySet().removeAll(refAcntMap.keySet()); // 参照されてるアカウントの重複を排除
      if (conts.size() + acnts.size() + acntMap.size() > getAccountTableThreshold()) {
        // 多かったら アカウントだけすてます
        this.queryProc = QueryProcess.ABANDON;
         acntMap.clear();
      }
    }
    if (!acntMap.isEmpty()) {
      acnts.addAll(acntMap.values());
    }
    this.otype2Objs.put(Account.SObjectType, acnts);
    this.otype2Objs.put(Contact.SObjectType, conts);
    return this.otype2Objs;
  }    

}