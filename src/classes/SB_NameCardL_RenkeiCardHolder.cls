public with sharing class SB_NameCardL_RenkeiCardHolder {

  // public enum RegistProcess { Create, Modify, CreateSkip, ModifySkip, LinkOnly }  // 処理内容の識別

  private static final Boolean RENKEI_USE_1ACCOUNT_CONTACT = true;

  ////////////////////////////////////////
  // 名刺に対する既存のレコードの IDを保持するようのクラス
  ////////////////////////////////////////
  public virtual class Candidate {
    public Id candidateId { get; private set; }
    public Candidate(SObject obj) {
      this.candidateId = obj.Id;
    }
    //public virtual Integer getChildCount() { return 0; }
  }

  ////////////////////////////////////////
  // 名刺に対する既存のアカウント、コンタクト レコードの IDを保持するようのクラス
  ////////////////////////////////////////
  public class AccountCandidate extends Candidate {
    public List<Id> childIds { get; private set; }
    public AccountCandidate(SObject obj) {
      super(obj);
      childIds = new List<Id>();
    }
    public void addChild(SObject obj) {
      childIds.add(obj.Id);
    }
    public Integer getChildCount() { return childIds.size(); }
  }

  // 処理内容の識別
  public enum RenkeiProcess { None,
                              Create,       // 新規作成
                              CreateOther,  // 既存がないけど、新規作成しない 同トランザクションの別名刺で作成した → 名刺からリンクする
                              CreateSkip,  // 既存がないけど、新規作成しない 作成しない設定
                              Modify,       // 該当する1つがあった 既存の更新
                              ModifyOther,  // 該当する1つがあった 既存の更新しない 同トランザクションの別名刺で更新した → 名刺からリンクする
                              ModifySkip,  // 該当する1つがあった 既存の更新しない 上書きしない設定 → 名刺からリンクのみ
                              TooMany }

  // 自動連携の検証 SB_NameCard_RenkeiMonitorController で使う
  public static final Map<RenkeiProcess, String> RENKEIPROCESS_TEXT = new Map<RenkeiProcess, String> {  // 2017.08.xx
    RenkeiProcess.Create => '作成',
    RenkeiProcess.CreateOther => '他で作成',
    RenkeiProcess.CreateSkip => '作成保留',
    RenkeiProcess.Modify => '更新',
    RenkeiProcess.ModifyOther => '他で更新',
    RenkeiProcess.ModifySkip => '更新保留・リンクのみ',
    RenkeiProcess.TooMany => '複数の既存レコード'
  };

  // 自動連携の検証 SB_NameCard_RenkeiMonitorController で使う
  public static String getProcessName(RenkeiProcess p) {
    return RENKEIPROCESS_TEXT.get(p);
  }

  ////////////////////////////////////////
  // 名刺と関連するレコードに関する情報を保持する用のクラス
  ////////////////////////////////////////
  public abstract class RenkeiCardHolder extends SB_NameCardL_RegistCardHolder.CardHolder {
    // public String companyId { get; private set; }   // この名刺の会社の識別用文字列
    // public String personId { get; private set; }   // この名刺の個人の識別用文字列
    //public String getKaishaKojinName() { return companyId + personId; }
    public RenkeiCardHolder(SmartViscaf__NameCard__c card) {
      super(card);
    }
  } // public abstract class RenkeiCardHolder extends SB_NameCardL_RegistCardHolder.CardHolder {


  ////////////////////////////////////////
  // 名刺と関連するアカウント、コンタクト レコードに関する情報を保持し、アカウント、コンタクト レコードを更新、作成する用のクラス
  //  取引先登録 = UI で 操作するとき用
  // RegistCardHolder はやめます 2018.06.xx
  ////////////////////////////////////////
  public static final String MSG_SEPARATOR = ' ; ';

  ////////////////////////////////////////
  // 名刺と関連するアカウント、コンタクト レコードに関する情報を保持し、アカウント、コンタクト レコードを更新、作成する用のクラス
  //  トリガ用 = 自動連携用
  ////////////////////////////////////////
  public virtual class AccountRenkeiHolder extends RenkeiCardHolder {
    public Integer num { get; protected set; } // リストにしたときの順番 = リクエストの順番
    // protected Id acntId;    //
    // protected Id contId;    //
    protected Id targetOwnerId; // 2017.12.xx ToDo の任命先用 作成・更新するレコードの所有者、更新の場合は コンタクトあるいはリードの所有者 年のため、NULLなら 名刺の所有者 //
    private Boolean createTodo;     //  名刺交換ToDOを作る？
    private Date todoDate;          // 名刺交換ToDO の日付の指定
    // public Account acnt { get; protected set; }            // この名刺に紐付けるアカウント  新規 OR 更新 OR ヒモ付のみ
    // public Contact cont { get; protected set; }            // この名刺に紐付けるコンタクト  新規 OR 更新 OR ヒモ付のみ
    public Task todo { get; private set; }

    //public Boolean isAccountUpsert() { return acnt != null;}    // アカウントの新規作成または 上書き（更新）をする。
    //public Boolean isContactUpsert() { return cont != null;}    // コンタクトの新規作成または 上書き（更新）をする。
    // この名刺に検索条件を満たすアカウント、コンタクトの情報
    @TestVisible private List<AccountCandidate> acntCandidates;
    public List<AccountCandidate> getAccountCandidates() { return acntCandidates; }
    private AccountCandidate acntWinner; // 採用した対象
    public String renkeiMessage { get; private set; }
    public RenkeiProcess acntProcess;
    public RenkeiProcess contProcess;
    public Boolean isSuccess() { return this.messages != null && this.messages.isEmpty(); }   // 連携成功
    public AccountRenkeiHolder(SmartViscaf__NameCard__c card) {
      super(card);
      this.acnt = null;
      this.cont = null;
      this.createTodo = false;
      this.acntCandidates = new List<AccountCandidate>();
      this.messages = new List<String>();
      this.acntWinner = null;
      this.acntProcess = RenkeiProcess.None;
      this.contProcess = RenkeiProcess.None;
    }
    // public Id getAccountId() { return acntId !=null ? acntId : (acnt !=null ? acnt.Id : null); }
    // public Id getContactId() { return contId !=null ? contId : (cont !=null ? cont.Id : null); }

    // リストにしたときの順番 = リクエストの順番 のセット
    public void setNumber(Integer n) {
      this.num = n;
    }

    // // 指定された方の SObject を返す。
    // public virtual override SObject getSObject(SObjectType otype) {
    //   if (otype == Account.sObjectType) {
    //     return acnt;
    //   }
    //   else if (otype == Contact.sObjectType) {
    //     return cont;
    //   }
    //   return null;
    // }

    public void addAccountCandidate(Account acnt, SB_NameCardL_RegistQueryMatcher.ContactMatcher cMatcher) {
      AccountCandidate can = new AccountCandidate(acnt);
      // Contact
      List<SObject> conts = acnt.Contacts;
      for (SObject cont : conts) {
        if (cMatcher.isMatch(card, (Contact)cont)) {
          can.addChild(cont);
        }
      }
      this.acntCandidates.add(can);
    }

    // 1. 対象レコードの処理をする前の処理
    // 2018.02.xx v1.22 SV_DEV-585 自動連携で既存取引先責任者が一意に特定できるなら取引先があいまいでも重複エラーにしない
    //  → 最初に 既存を調べて 採用する アカウント、コンタクトを決めておく
    public virtual void preProcess() {
      judgeAccount();
    }
    // 1.1 アカウント、コンタクトについて判定
    protected void judgeAccount() {
      if (acntCandidates.isEmpty()) {
        // なかったら、作るかどうか
        this.acntProcess = this.setting.SmartViscaf__RenkeiAccountNOExistCreateNew__c ? RenkeiProcess.Create : RenkeiProcess.CreateSkip;
        this.contProcess = this.setting.SmartViscaf__RenkeiContactNOExistCreateNew__c ? RenkeiProcess.Create : RenkeiProcess.CreateSkip;
        return;
      }
      if (this.acntCandidates.size() == 1) {
        // 既存取引先が１つだけのとき
        this.acntWinner = acntCandidates.get(0);
      }
      else if (RENKEI_USE_1ACCOUNT_CONTACT == true) {
        // 既存取引先が複数あったとき
        Integer index = -1;
        for (Integer n=0; n < this.acntCandidates.size(); n++) {
          AccountCandidate t = acntCandidates.get(n);
          if (t.getChildCount() > 0) {
            // コンタクトが1つ以上ある。
            index = index == -1 ? n : -1;
            if (index == -1) {
              break;      // 2つめがあった
            }
          }
        }
        if (index != -1) {
          this.acntWinner = acntCandidates.get(index);
        }
      }
      if (this.acntWinner !=null) {
        this.acntId = this.acntWinner.candidateId;
        this.acntProcess = this.setting.SmartViscaf__RenkeiAccountOverwrite__c ? RenkeiProcess.Modify : RenkeiProcess.ModifySkip;
        this.contId = ((AccountCandidate)this.acntWinner).getChildCount() == 1 ? ((AccountCandidate)this.acntWinner).childIds[0] : null;
        if (this.contId != null) {
          // アカウント配下に 既存コンタクトが１つあった。
          this.contProcess = this.setting.SmartViscaf__RenkeiContactOverwrite__c ? RenkeiProcess.Modify : RenkeiProcess.ModifySkip;
        }
        else {
          // アカウント配下に 既存コンタクトがなかった。
          this.contProcess = this.setting.SmartViscaf__RenkeiContactNOExistCreateNew__c ? RenkeiProcess.Create : RenkeiProcess.CreateSkip;
        }
      }
      else {
        this.acntProcess = RenkeiProcess.TooMany;
        this.contProcess = RenkeiProcess.TooMany;
      }
    }
    // 2. アカウントの処理用
    // 一致する既存のアカウントが複数ある
    public Boolean isAccountTooMuch() {
      return acntCandidates.size() > 1;
    }

    public Boolean useExistAccount() { return this.acntProcess == RenkeiProcess.Modify && acntWinner != null; }

    public virtual Id getTargetAccountId() {
      return this.acntId;
    }

    // 一致する既存のアカウントがない
    public virtual Boolean isAccountNotExist() {
      return this.acntId == null;
    }

    // 3. コンタクトの処理用
    // 一致する既存のコンタクトが複数ある
    public Boolean isContactTooMuch() {
      return acntWinner != null && acntWinner.childIds.size() > 1;
    }

    //// 一致する既存のコンタクトが1つだけある。
    public Boolean useExistContact() {
      return  this.contProcess == RenkeiProcess.Modify &&
        acntWinner != null && acntWinner.childIds.size() == 1;
    }

    public virtual Id getTargetContactId() {
      return this.contId;
    }

    // アカウントはある（作った OR 既存）けど、一致する既存のコンタクトがない
    public Boolean isContactNotExistWithAccount() {
      //return (acntCandidates.isEmpty() && this.acnt !=null) || (acntCandidates.size() == 1 && acntCandidates[0].childIds.isEmpty());
      return (acntCandidates.isEmpty() && this.acnt !=null) || (acntWinner != null && acntWinner.childIds.isEmpty());
    }

    // 連携処理情報を書き出す
    public override void modifySomeCardFields(SmartViscaf__NameCard__c nc) {
      String msg = this.messages.isEmpty() ?  'OK' : String.join(this.messages, ' ');
      // 前に 付け足す
      nc.SmartViscaf__RenkeiMessage__c = String.isNotBlank(this.card.SmartViscaf__RenkeiMessage__c) ? msg + MSG_SEPARATOR + this.card.SmartViscaf__RenkeiMessage__c : msg;
      // 文字列が長くなってるかもしれないので切り詰める 。 画面上では切り詰められない。多分 Triggrt でも
      Schema.DescribeFieldResult dfr = SmartViscaf__NameCard__c.SmartViscaf__RenkeiMessage__c.getDescribe();
      nc.SmartViscaf__RenkeiMessage__c = nc.SmartViscaf__RenkeiMessage__c.left(dfr.getLength());
      // v1.19 SmartViscaf__ではRenkeiMessage__c がないので、SmartViscaT05　では 項目にはいれず、このクラスのプロパティで保持 → 画面の結果表示にはこれを使う
      this.renkeiMessage = msg;
    }

  }  // class AccountRenkeiHolder

  ////////////////////////////////////////
  // 名刺と関連するアカウント、コンタクト レコードに関する情報を保持し、アカウント、コンタクト レコードを更新、作成する用のクラス
  //  トリガ用 = 自動連携用
  ////////////////////////////////////////
  public class LeadAccountRenkeiHolder extends AccountRenkeiHolder {
    @TestVisible private List<Candidate> leadCandidates;
    public List<Candidate> getLeadCandidates() { return leadCandidates; }
    private Candidate leadWinner;    // 採用したリードの対象
    public RenkeiProcess leadProcess;

    public LeadAccountRenkeiHolder(SmartViscaf__NameCard__c card) {
      super(card);
      this.leadCandidates = new List<Candidate>();
      this.lead = null;
      this.leadWinner = null;
      this.leadProcess = RenkeiProcess.None;
    }

    public void addLeadCandidate(Lead l) {
      Candidate can = new Candidate(l);
      leadCandidates.add(can);
    }

    // 1. リード統合版 対象レコードの処理をする前の処理
    // 既存のリード確認、既存
    public override void preProcess() {
      //if (acntCandidates.isEmpty() && leadCandidates.isEmpty()) {
      //  return;
      //}
      // 1.1. アカウント、コンタクトについて判定 acntWinner を決める。
      judgeAccount();
      if (SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RenkeiLeadActive__c == false) {
        // 自動連携:リード登録機能を有効化 FALSE なら リードの判定はしない.
        return;
      }
      // 1.2. リードについて判定 leadWinner を決める。
      judgeLead();
    }

    // private Boolean isExistAccount() {
    //   return this.acntId != null;
    // }
    // private Boolean isExistContact() {
    //   return this.contId != null;
    // }
    // 1.2. リードについて判定 leadWinner を決める。
    private void judgeLead() {
      if (this.leadCandidates.isEmpty()) {
        // リード ない
        if (this.acntCandidates.isEmpty()) {
          // アカウント ない
          this.leadProcess = this.setting.SmartViscaf__RenkeiLeadNOExistCreateNew__c ? RenkeiProcess.Create : RenkeiProcess.CreateSkip;
          this.acntProcess = RenkeiProcess.CreateSkip; // アカウント作らない
          this.contProcess = RenkeiProcess.CreateSkip; // コンタクト作らない
        }
        //  アカウント ある
        else if (this.acntId != null && this.contId == null) {
          //  アカウント あるけど コンタクトない。
          if (SB_NameCardL_Util.smartViscaConfig.RenkeiCreateContactOnAcountWithoutLead__c) {
            // (リードなく、取引先既存で取引先責任者を作成する オン)
            this.leadProcess = RenkeiProcess.CreateSkip;  // リード作らない + コンタクト作る（判定そのまま）
          }
          else {
            // (リードなく、取引先既存で取引先責任者を作成する オフ)
            this.leadProcess = this.setting.SmartViscaf__RenkeiLeadNOExistCreateNew__c ? RenkeiProcess.Create : RenkeiProcess.CreateSkip;
            this.contProcess = RenkeiProcess.CreateSkip; // リード作る + コンタクト作らない（判定変える）
          }
        }
        else if (this.acntId != null && this.contId != null) {
          //  アカウント ある コンタクト ある
          this.leadProcess = RenkeiProcess.CreateSkip; // リード 作らない。
        }
        else {
          // アカウント特定できない
          if (SB_NameCardL_Util.smartViscaConfig.RenkeiCreateLeadOnTooManyAccounts__c ) {
            //  (既存取引先が複数あり特定できないとき、リードを作る。オン)
            this.leadProcess = this.setting.SmartViscaf__RenkeiLeadNOExistCreateNew__c ? RenkeiProcess.Create : RenkeiProcess.CreateSkip;
          }
          else {
            this.leadProcess = RenkeiProcess.CreateSkip;   // リード作らない
          }
        }
        return;
      }
      else {
        // 既存リードある。
        if (this.leadCandidates.size() == 1) {
          // 既存取引先が１つだけのとき
          this.leadWinner = leadCandidates.get(0);
          this.leadId = this.leadWinner.candidateId;
          this.leadProcess = this.setting.SmartViscaf__RenkeiLeadOverwrite__c ? RenkeiProcess.Modify : RenkeiProcess.ModifySkip;
        }
        else if (
          // 既存リード沢山
          SB_NameCardL_Util.smartViscaConfig.RenkeiUpdateAllLeadsOnCondition__c ) {// 統合版自動連携:条件に合致する既存リードは全て更新する。
          this.leadProcess = this.setting.SmartViscaf__RenkeiLeadOverwrite__c ? RenkeiProcess.Modify : RenkeiProcess.ModifySkip;
        }
        if (this.acntCandidates.isEmpty()) {
          // アカウント ない
          this.acntProcess = RenkeiProcess.CreateSkip; // アカウント作らない
          this.contProcess = RenkeiProcess.CreateSkip; // コンタクト作らない
        }
        //  アカウント ある
        else if (this.acntId != null && this.contId == null) {
          //  アカウント あるけど コンタクトない。
          if (!SB_NameCardL_Util.smartViscaConfig.RenkeiCreateContactOnAcountWithLead__c) {
            // リード、取引先既存で取引先責任者を作成する オフ
            this.contProcess = RenkeiProcess.CreateSkip; // コンタクト作らない
          }
        }
      }

    }

    // 4. リードの処理用
    // 一致する既存のリードが複数ある
    public Boolean isLeadTooMuch() {
      return leadCandidates.size() > 1;
    }

    public Boolean useExistLead() { return this.leadProcess == RenkeiProcess.Modify && leadWinner != null; }

    public virtual Id getTargetLeadId() {
      return this.leadId;
    }

    // 一致する既存のリードがない
    public virtual Boolean isLeadNotExist() {
      return this.leadId == null;
    }

    // 既存のリードを更新用に作成 複数あったら複数
    public List<Lead> buildUpdAllLeads(Set<Id> withoutLeadIds) {
      List<Lead> result = new List<Lead>();
      if (this.leadCandidates.isEmpty() ||
        (this.leadCandidates.size() > 1 && SB_NameCardL_Util.smartViscaConfig.RenkeiUpdateAllLeadsOnCondition__c == false)) {
          return result;
      }
      SmartViscaf.SB_NameCard_RenkeiMapper mapper = SmartViscaf.SB_NameCard_RenkeiMapper.getInstance('Lead', true);
      for (Candidate t : this.leadCandidates) {
        if (withoutLeadIds.contains(t.candidateId)) {
          continue; // 他の名刺で更新してたとき
        }
        Lead l = (Lead)mapper.updateRecord(this.card, t.candidateId);
        result.add(l);
      }
      // this.otype2upserted.put(Schema.Lead.sObjectType, this.lead);
      return result;
    }

  }  // class LeadAccountRenkeiHolder

}