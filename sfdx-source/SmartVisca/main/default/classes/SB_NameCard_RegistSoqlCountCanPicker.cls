/**
 *
 * SB_NameCard_RegistSoqlCountCanPicker
 *     登録先候補の 取引先、取引先責任者を 収集するクラスの1つ
 *     SOQLでカウントして続ける。
 *     KDDI様向け 管理パッケージ：SmartViscaRgq1 SB_Sv_UiRegistSoqlCountCanCreater がベース
 *
 * (c) 2019 Sunbridge Inc.
 *
 *  @author K.Yoshida
 *  @Version 2.2  2019.02.XX SV_DEV-1558 LEX 取引先登録 一括画面をLXパッケージ同様のLC化で追加
 *  @Version 2.4  2019.06.xx sawano SV_DEV-665 取引先・取引先責任者登録のLDV対応の改造 = 取引先・取引先責任者登録の取引先400万件対応（検索のSOSL化）
 *                        個別では基本はSOSLだけど、条件によっては、あるいは一括はこちらを使います。
 *
 **/
public with sharing class SB_NameCard_RegistSoqlCountCanPicker extends SB_NameCard_RegistCanPickerAbstract {

  public SB_NameCard_RegistSoqlCountCanPicker() {
    super();
  }

  // 候補のアカウントを収集
  // 名刺レコードから
  // LEX 個別 Wizard  ほんとの完全一致か SOQL指定のとき
  protected override Map<SObjectType, List<SObject>> createAccounts() {
    this.otype2Objs.remove(Account.sObjectType);
    if (this.accountQs.isCompanyQueryPartial()) {
      // 部分一致検索 が指定
      // 1. 部分一致する アカウント を カウント
      this.queryProc = QueryProcess.PARTIAL;  // 部分一致
      Integer partialMatchAccount = this.qExecutor.getCandidateRecordCount(this.accountQs);
      System.debug(partialMatchAccount);
      if (0 <= partialMatchAccount && partialMatchAccount < getAccountTableThreshold()) {
        // 少なかったら
        // 2.1. 部分一致する アカウント と 名刺から参照してるアカウントを収集
        List<Account> acnts = this.qExecutor.getCandidateRecords(this.accountQs);
        this.otype2Objs.put(Account.SObjectType, acnts);
      }
      else {
        // 多かったら
        // 2.2. 完全一致するアカウントと 参照してるアカウントを 収集
        createAccountsFullMatch(getAccountTableThreshold());
      }
    }
    else {
      // 本当に完全一致検索する。
      // 完全一致するアカウントと 参照してるアカウントを 収集 法人格の略称・正称を区別
      createAccountsFullMatch(getAccountTableThreshold());
    }
    return this.otype2Objs;
  }

  // 完全一致するアカウントと 参照してるアカウントを 収集
  //  多かったら、参照してるアカウントのみを抽出 
  private void createAccountsFullMatch(Integer maxCount) {
    List<Account> acnts;
    // 1. 完全一致するアカウントを収集
    this.accountQs.setCompanyRule(SB_NC_RegistQueryOption.CompanyMatcing.PerfectMatch); // 完全一致
    this.accountQs.setDeptRule(SB_NC_RegistQueryOption.DeptMatcing.ExactMatch);   // 完全一致
    this.queryProc = QueryProcess.PERFECT;
    acnts = this.qExecutor.getCandidateRecords(this.accountQs);
    if (acnts.size() > maxCount) {
      // 完全一致するアカウントでも多かったら  すてる。
      this.queryProc = QueryProcess.ABANDON;
      acnts.clear();
      // 2. 名刺からアカウント参照してるアカウントを抽出 新仕様なので注意
      List<Account> referencedAccounts = this.qExecutor.getReferencedCandidateRecords(this.accountQs);
      if (referencedAccounts != null && !referencedAccounts.isEmpty()) {
        acnts.addAll(referencedAccounts);
      }
    }
    // acnts がからでも入れる。
    this.otype2Objs.put(Account.SObjectType, acnts);
  }

  // 候補のアカウント、コンタクトを収集
  // 名刺レコードから
  // 一括
  protected override Map<SObjectType, List<SObject>> createAccountsContacts() {
    this.otype2Objs.remove(Account.sObjectType);
    this.otype2Objs.remove(Contact.sObjectType);
    // コンタクトがいるだけのアカウントは検索対象外
    this.accountQs.setNoContactOnly(true);   
    // 1. コンタクトを収集
    List<Contact> conts = this.qExecutor.getCandidateRecords(this.contactQs);
    this.otype2Objs.put(Contact.SObjectType, conts);
    
    if (this.accountQs.isCompanyQueryPartial()) {
      // 部分一致検索 が指定
      // 2. 部分一致する アカウント を カウント
      this.queryProc = QueryProcess.PARTIAL;  // 部分一致
      Integer partialMatchAccount = this.qExecutor.getCandidateRecordCount(this.accountQs);
      System.debug(partialMatchAccount);
      if (0 <= partialMatchAccount && (conts.size() + partialMatchAccount) < getAccountTableThreshold()) {
        // 少なかったら
        // 3.1. 部分一致する アカウント と 名刺から参照してるアカウントを収集
        List<Account> acnts = this.qExecutor.getCandidateRecords(this.accountQs);
        this.otype2Objs.put(Account.SObjectType, acnts);
      }
      else {
        // 多かったら
        // 3.2. 完全一致するアカウントを収集
        createAccountsFullMatch(getAccountTableThreshold()-conts.size());
      }
    }
    else {
      // 本当に完全一致検索する。
      // 完全一致するアカウントを収集 法人格の略称・正称は区別
      createAccountsFullMatch(getAccountTableThreshold()-conts.size());
    }

    // // 2. 部分一致する アカウント を カウント
    // //initAccountQueryStrategy(); // クエリ方法を初期化
    // this.queryProc = QueryProcess.PARTIAL;  // 最初は部分一致   のはず。
    // Integer partialMatchAccount = this.qExecutor.getCandidateRecordCount(this.accountQs);

    // System.debug(partialMatchAccount);
    // List<Account> acnts; //  = new List<Account>();
    // if (0 <= partialMatchAccount && (conts.size() + partialMatchAccount) < getAccountTableThreshold()) {
    //   // 少なかったら
    //   // 3.1. 部分一致する アカウント と 名刺から参照してるアカウントを収集 アカウント 0件でもクエリすいるけど、よしとしま。
    //   acnts = this.qExecutor.getCandidateRecords(this.accountQs);
    // }
    // else {
    //   // 多かったら
    //   // 3.2. 完全一致するアカウントを収集
    //   this.accountQs.setCompanyRule(SB_NC_RegistQueryOption.CompanyMatcing.ExactMatch); // 完全一致
    //   this.queryProc = QueryProcess.PERFECT;
    //   acnts = this.qExecutor.getCandidateRecords(this.accountQs);
    //   if ((acnts.isEmpty() && conts.size() > getAccountTableThreshold()) ||
    //       (!acnts.isEmpty() && conts.size() + acnts.size() > getAccountTableThreshold())) {
    //     // 完全一致するアカウントでも多かったら  すてる。
    //     this.queryProc = QueryProcess.ABANDON;
    //     acnts.clear();
    //     if (conts.size() >= getAccountTableThreshold()) {
    //       // コンタクトだけでも多かったら捨てる。
    //       conts.clear();
    //       // 名刺からコンタクト参照してるコンタクトを抽出 新仕様なので注意
    //       List<Contact> referencedContacts = this.qExecutor.getReferencedCandidateRecords(this.contactQs);
    //       if (referencedContacts != null && !referencedContacts.isEmpty()) {
    //         conts.addAll(referencedContacts);
    //       }
    //     }
    //     // 名刺からアカウント参照してるアカウントを抽出 新仕様なので注意
    //     List<Account> referencedAccounts = this.qExecutor.getReferencedCandidateRecords(this.accountQs);
    //     if (referencedAccounts != null && !referencedAccounts.isEmpty()) {
    //       acnts.addAll(referencedAccounts);
    //     }
    //   }

    // }
    // //if (!acnts.isEmpty()) {
    //   this.otype2Objs.put(Account.SObjectType, acnts);
    // //}
    // //if (!conts.isEmpty()) {
    //   this.otype2Objs.put(Contact.SObjectType, conts);
    // //}
    return this.otype2Objs;
  }

}