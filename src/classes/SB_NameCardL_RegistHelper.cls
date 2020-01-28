/**
 * SB_NameCardL_RegistHelper
 *   SB_NC_RegistExecutor の改造
 *   Lightning Express 対応 取引先・取引先責任者  一括登録画面
 *   SV v1.20 から Classic版 取引先登録もこちらを使ってマッピングを反映する。
 *
 * Copyright (C) 2016-2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 * SB_NC_RegistExecutor
 *  @Version 1      2016.11.xx
 *  @Version 2      2017.04.xx   クラッシク版取引先登録もこちらを使うので 調整　トリガ版、UI版の統一化
 * SB_NameCardL_RegistHelper
 *  lx2.0   2018.06.xx
 *
 **/
public with sharing class SB_NameCardL_RegistHelper  {
  public class SB_NameCardL_RegistHelperException extends Exception {}

  //public static final Integer ProcNone = 0;
  //public static final Integer ProcAccount = 1;
  //public static final Integer ProcLead = 2;
  //public static final Integer ProcBoth = 3;
  //public enum ProcType2 { ProcNone, ProcAccount, ProcLead, ProcBoth } //
  public enum ProcType { NONE, ACCOUNT, LEAD, BOTH } //



  // 処理の実行は この 　staticメソッドを外部から呼び出します。
  public static RegistResponse doRegist(RegistRequest req) {
    System.debug('RegistRequest: ' +  req);
    SB_NameCardL_RegistHelper proc = new SB_NameCardL_RegistHelper(req);
    proc.run();
    return proc.getRegistResponse();
  }

  // 所有者が適切かチェックしてから登録処理をします。
  // 処理の実行は この 　staticメソッドを外部から呼び出します。
  public static RegistResponse doRegistEx(RegistRequest req) {
    System.debug('RegistRequest: ' +  req);
    SB_NameCardL_RegistHelper proc = new SB_NameCardL_RegistHelper(req);
    if (proc.canRegist(req)) {
      proc.run();
    }
    return proc.getRegistResponse();
  }


  // +--------------------------------------------------------+
  // +---- リクエスト用 ----+
  // +---- リクエスト全体 ----+
  public virtual class RegistRequest {
    @TestVisible public List<RegistTarget> targets { get; private set; } // 対象のレコード達のID
    @TestVisible public RegistParam acntParam { get; private set; }      // アカウント登録のパラメータ
    @TestVisible public RegistParam contParam { get; private set; }      // コンタクト登録のパラメータ
    @TestVisible public RegistParam leadParam { get; private set; }      // リード登録のパラメータ を想定  未実装
    @TestVisible public TodoParam todoParam { get; private set; }     // 作成するToDo用のパラメータ
    public RegistRequest() {}
    // 2017.04.xx
    public RegistRequest(List<RegistTarget> targets, RegistParam acntParam, RegistParam contParam, RegistParam leadParam, TodoParam todoParam) {
      this.targets = targets;
      this.acntParam = acntParam;
      this.contParam = contParam;
      this.leadParam = leadParam;
      this.todoParam = todoParam;
    }
    //public Boolean isAccountContact() {
    //  return leadParam == null;
    //}
    //public Set<SObjectType> getTargetSObject() {
    //  Set<SObjectType> result = new Set<SObjectType>();
    //  if (isAccountContact()) {
    //    result.add(Account.getSObjectType());
    //    result.add(Contact.getSObjectType());
    //  }
    //  else {
    //    result.add(leadParam.getSObjectType());
    //  }
    //  return result;
    //}
  }
  // +---- リクエスト 対象のオブジェクトID と ToDo オン・オフ を保持する用 クラス----+
  public virtual class RegistTarget {
    @TestVisible public ProcType pType { get; protected set; }     //  Accountの処理か Leadの処理か
    @TestVisible public Integer pType2 { get; protected set; }     //  ProcType の JSRemoteing用 暫定
    @TestVisible public Id cardId { get; protected set; }     //  名刺のID 必須
    @TestVisible public Id acntId { get; protected set; }     //  アカウントのID acntParam で NULL なら 新規作成する
    @TestVisible public Id contId { get; protected set; }     //  コンタクトのID contParam で NULL なら 新規作成する
    @TestVisible public Id leadId { get; protected set; }     //  リードのIDを想定 leadParam で NULL なら 新規作成する 未実装
    @TestVisible public Id contCampaignId { get; protected set; }     //  コンタクトを キャンペーンメンバーにする。
    @TestVisible public String contCampaignStatus { get; protected set; }     //  コンタクト キャンペーンメンバーのステータス
    @TestVisible public Id leadCampaignId { get; protected set; }     //  リード を キャンペーンメンバーにする。
    @TestVisible public String leadCampaignStatus { get; protected set; }     //  リード キャンペーンメンバーのステータス
    @TestVisible public Boolean createTodo { get; protected set; }   // TRUE： ToDoを作る
    @TestVisible public Date todoDate { get; protected set; }        // ToDoの日付
    public RegistTarget() {}
    // 2017.04.xx
    public RegistTarget(ProcType pType, Id cardId, Id acntId, Id contId, Id leadId, Boolean createTodo, Date todoDate) {
      this.pType = pType;
      this.cardId = cardId;
      this.acntId = acntId;
      this.contId = contId;
      this.leadId = leadId;
      this.createTodo = createTodo;
      this.todoDate = todoDate;      // 2017.04.25 null だったら名刺交換日、名刺交換日もNULLなら Date.today();
    }

    //  ProcType の JSRemoteing用 暫定
    Public void convertProcType() {
      System.assert(pType2 != null);
      switch on this.pType2 {
        when 1 {
             this.pType = ProcType.ACCOUNT;
        }
        when 2 {
          this.pType = ProcType.LEAD;
        }
        when 3 {
          this.pType = ProcType.BOTH;
        }
        when else {
          this.pType = ProcType.NONE;
        }
      }
    }

    //// LEX 版 SB_NCL_TwowayRegistContoller の registAccountContact からのとき
    //public RegistTarget(Integer pType, Id cardId, Id acntId, Id contId, Id leadId, Boolean createTodo, Date todoDate) {
    //  this.pType = pType == null || pType == 0 ? ProcType.ACCOUNT : ProcType.LEAD;
    //  this.cardId = cardId;
    //  this.acntId = acntId;
    //  this.contId = contId;
    //  this.leadId = leadId;
    //  this.createTodo = createTodo;
    //  this.todoDate = todoDate;      // 2017.04.25 null だったら名刺交換日、名刺交換日もNULLなら Date.today();
    //}

    // コンタクトのキャンペーンメンバーの指定
    public void setContactCampaign(Id campaignId, String campaignStatus) {
      this.contCampaignId = campaignId;
      this.contCampaignStatus = campaignStatus;
    }
    // リードのキャンペーンメンバーの指定
    public void setLeadCampaign(Id campaignId, String campaignStatus) {
      this.leadCampaignId = campaignId;
      this.leadCampaignStatus = campaignStatus;
    }

    //// 名刺レコードの値が必要かどうか
    // 新規作成がある？  some TRUE:アカウント・コンタク 登録でないとき
    public Boolean isCopyCardValues(RegistRequest req) {
      //return (req.isAccountContact() && (acntId ==null || req.acntParam.overwrite || contId ==null || req.contParam.overwrite))
      //  || (!req.isAccountContact() && (leadId ==null || req.leadParam.overwrite));
      return true;
    }
  }

  // +---- リクエスト 登録条件用クラス ----+
  public virtual class RegistParam {
    @TestVisible public String objName { get; private set; }
    @TestVisible public Boolean overwrite { get; private set; }
    @TestVisible public Id recTypeId { get; private set; }
    @TestVisible public Id ownerId { get; private set; }   //
    @TestVisible public Boolean allowSave { get; private set; }      // 重複してても作成・更新する。
    @TestVisible public Map<String, Object> filed2value { get; private set; }  // 特定の項目の値を指定してよこす リードの キャンペーンIDとか
    public RegistParam() {}
    // 2017.04.xx
    public RegistParam(String objName, Boolean overwrite, Id recTypeId, Id ownerId, Boolean allowSave) {
      this.objName = objName;
      this.overwrite = overwrite;
      this.recTypeId = recTypeId;
      this.ownerId = ownerId;
      this.allowSave = allowSave;
    }
    public SObjectType getSObjectType() {
      return Schema.getGlobalDescribe().get(objName);
    }
  }

  // +---- リクエスト 登録するToDo の内容用クラス ----+
  public virtual class TodoParam {
    @TestVisible public String subject { get; private set; }        // ToDoの件名
    @TestVisible public String subjectL{ get; private set; }        // ToDoの件名(リード)
    @TestVisible public Date activityDate { get; private set; }     // 未使用？
    @TestVisible public String comment { get; private set; }        // コメント
    @TestVisible public Id ownerId { get; private set; }   // ToDoの所有者
    public TodoParam() {}
    // 2017.04.xx
    public TodoParam(String subject, Date activityDate, String comment, Id ownerId) {
      this.subject = subject;
      this.activityDate = activityDate;
      this.comment = comment;
      this.ownerId = ownerId;
    }
    public TodoParam(String subject, String subjectL, Date activityDate, String comment, Id ownerId) {
      this.subject = subject;
      this.subjectL = subjectL;
      this.activityDate = activityDate;
      this.comment = comment;
      this.ownerId = ownerId;
    }
  }
  // +---- リクエスト用 ----+
  // +--------------------------------------------------------+


  // +--------------------------------------------------------+
  // +---- レスポンス用 ----+
  // +---- レスポンス全体 ----+
  public class RegistResponse {
    public RegistRequest req { get; private set; }
    public Boolean success { get; private set; }
    public String process { get; private set; }       // 何の処理をやるとこか  エラーの通知用
    public Map<Id, SB_NameCard_LeadSaveResult.DbErrorHolder> dbErrors;
    public Map<Id, RegistedSummary> registeds; // new
    public String title { get; private set; }       // エラーのタイトル
    public String message { get; private set; }        // エラーメッセージ
    public List<String> messages { get; private set; } // エラーメッセージ DMLでのエラー
    public String errorObject { get; private set; }    // エラーのあったオブジェクト
    //public Boolean htmMsg { get; private set; }       // title が HTML タグを含むとき TRUE
    public Boolean allowRetry { get; private set; }    // 再試行を許可する場合 TRUE  重複エラーの場合にありえる。


    private Map<Id, SObject> querySObjects(String objName, Set<Id> ids) {
      Map<Id, SObject> result = new Map<Id, SObject>();
      if (!ids.isEmpty()) {
        Set<Id> targetIds = ids;
        List<String> fields = new List<String>{'Id', 'Name'};
        if (objName != 'CampaignMember') {
          fields.add('OwnerId');
          fields.add('Owner.Name');
        }
        else {
          fields.add('LeadOrContactId');
          fields.add('Status');
        }
        String query = String.format('SELECT {0} FROM {1} WHERE Id IN :targetIds', new String[] { String.join(fields, ', '), objName });
        result.putAll(Database.query(query));
      }
      return result;
    }

    public RegistResponse(RegistRequest req) {
      this.req = req;
      this.success = false;
      this.allowRetry = false;
      this.errorObject = null;
    }

    public void finalize(List<SB_NameCardL_RegistCardHolder.AccountRegistHolder> holders) {
      this.success = true;
      Set<Id> acntIds = new Set<Id>();
      Set<Id> contIds = new Set<Id>();
      Set<Id> leadIds = new Set<Id>();
      Set<Id> cmIds = new Set<Id>(); // コンタクトかリードのキャンペーンメンバー
      //Set<Id> leadCmIds = new Set<Id>(); // リードのキャンペーンメンバー
      for (SB_NameCardL_RegistCardHolder.AccountRegistHolder holder : holders ) {
        if (holder.getAccountId() != null) {
          acntIds.add(holder.getAccountId());
        }
        if (holder.getContactId() != null) {
          contIds.add(holder.getContactId());
        }
        if (holder.getLeadId() != null) {
          leadIds.add(holder.getLeadId());
        }
        if (holder.getLeadId() != null) {
          leadIds.add(holder.getLeadId());
        }
        if (holder.contCampaignMember != null && holder.contCampaignMember.Id != null) {
          cmIds.add(holder.contCampaignMember.Id);
        }
        if (holder.leadCampaignMember != null && holder.leadCampaignMember.Id != null) {
          cmIds.add(holder.leadCampaignMember.Id);
        }
      }
      Map<Id, SObject> acnts = querySObjects('Account', acntIds);
      Map<Id, SObject> conts = querySObjects('Contact', contIds);
      Map<Id, SObject> leads = querySObjects('Lead', leadIds);
      Map<Id, SObject> cms = querySObjects('CampaignMember', cmIds);
      //resetRegistedSObjects(cardId2Registed);   // Inseet or Update 後のレコードに 入れ換え  TODO 入れ換えずに RegistedSummary をあたしいレコードで作る。
      this.registeds = new Map<Id, RegistedSummary>();
      for (SB_NameCardL_RegistCardHolder.AccountRegistHolder holder : holders) {
        RegistedSummary sum = new RegistedSummary(holder.card.Id);
        if (holder.getAccountId() != null) {
          SObject acnt = acnts.get(holder.getAccountId());
          sum.addRecord(acnt);
        }
        if (holder.getContactId() != null) {
          SObject cont = conts.get(holder.getContactId());
          sum.addRecord(cont);
        }
        if (holder.getLeadId() != null) {
          SObject lead = leads.get(holder.getLeadId());
          sum.addRecord(lead);
        }
        // CampaignMember
        if (holder.contCampaignMember != null && holder.contCampaignMember.Id != null) {
          SObject cm = cms.get(holder.contCampaignMember.Id);
          sum.addRecord(cm);
        }
        if (holder.leadCampaignMember != null && holder.leadCampaignMember.Id != null) {
          SObject cm = cms.get(holder.leadCampaignMember.Id);
          sum.addRecord(cm);
        }
        if (holder.todo != null) {
          sum.addRecord(holder.todo);
        }
        this.registeds.put(holder.card.Id, sum);
      }
    }

    public void falt(String title, String message, Integer lineNumber) {
      this.title = title;
      this.message = String.format('{0} ({1})', new String[] {message, String.valueOf(lineNumber)});
    }
    // 例外が発生したとき
    public void falt(String message) {
      this.title = message;   // 残します。 ← SV_DEV-816 重複ルール設定時のClassic画面の一括登録でのエラーメッセージ内がnullで表示される箇所がある。
      this.success = false;
      this.message = message;
    }
    // DML でエラーがあったらこれをよんで、エラー内容をセット して、終わる。
    public void setError(SB_NameCardL_DMLProcessor.UiDmlProcessor error) {
      this.success = false;
      this.dbErrors = error.id2dbError;
      this.allowRetry = error.allowRetry;
      this.messages = error.messages;
    }

    // 所有者チェック でエラーがあったらこれをよんで、エラー内容をセット して、終わる。
    public void setOwnerCheckError(Map<Id, String> owner2Error) {
      this.success = false;
      this.messages = new List<String>();
      for (RegistTarget target : this.req.targets) {
        if (owner2Error.containsKey(target.cardId)) {
          this.messages.add(owner2Error.get(target.cardId));
        }
      }
      this.message = String.join(this.messages, '/r/n');
      this.success =false;
    }

  }   // RegistResponse

  public class RegistedSummary {
    public Id cardId { get; private set; }
    public SObjectInfo acnt { get; private set; }
    public SObjectInfo cont { get; private set; }
    public SObjectInfo lead { get; private set; }
    public SObjectInfo contCampaignMember { get; private set; }
    public SObjectInfo leadCampaignMember { get; private set; }
    public SObjectInfo todo { get; private set; }

    //public RegistedSummary(RegistedSObjects registed) {
    //  this.cardId = registed.cardId;
    //  for (SObjectType otype : registed.objs.keySet()) {
    //    SObject obj = registed.objs.get(otype);
    //    SObjectInfo info = new SObjectInfo(obj);
    //    if (otype == Account.sObjectType) {
    //      acnt = info;
    //    }
    //    else if (otype == Contact.sObjectType) {
    //      cont = info;
    //    }
    //    else if (otype == Task.sObjectType) {
    //      todo = info;
    //    }
    //    else {
    //      lead = info;
    //    }
    //  }
    //}
    public RegistedSummary(Id cardId) {
      this.cardId = cardId;
    }
    public void addRecord(SObject obj) {
      if (obj == null) {
        return;
      }
      SObjectInfo info = new SObjectInfo(obj);
      if (obj.getSObjectType() == Account.sObjectType) {
        acnt = info;
      }
      else if (obj.getSObjectType() == Contact.sObjectType) {
        cont = info;
      }
      else if (obj.getSObjectType() == Schema.Lead.sObjectType) {
        lead = info;
      }
      else if (obj.getSObjectType() == CampaignMember.sObjectType) {
        Id lcId = (Id)(String)obj.get('LeadOrContactId');
        if (lcId.getSObjectType() == Schema.Lead.sObjectType) {
          leadCampaignMember = info;
        }
        else if (lcId.getSObjectType() == Contact.sObjectType) {
          contCampaignMember = info;
        }
      }
      else if (obj.getSObjectType() == Task.sObjectType) {
        todo = info;
      }
    }
  }

  public class SObjectInfo {
    public Id id { get; private set; }
    public Object name { get; private set; }
    public Id ownerId { get; private set; }
    public Object ownerName { get; private set; }
    public Object status { get; private set; }
    public SObjectInfo(SObject obj) {
      this.id = obj.Id;
      if (obj.Id.getSObjectType() != CampaignMember.sObjecttype) {
        // CampaignMember では Owener がない
        this.ownerid = (Id)obj.get('OwnerId');
        SObject ownerUser = obj.getSObject('Owner');
        this.ownerName = ownerUser != null ? ownerUser.get('Name') : null;
      }
      else {
        this.status = obj.get('Status');
      }
      if (obj.getSObjectType() == Task.sObjectType || obj.getSObjectType() == Event.sObjectType) {
        this.name = obj.get('Subject');
      }
      else {
        this.name = obj.get('Name');
      }

      System.debug(this.name);
    }
  }

  //// 作成・更新したレコードを持ってるクラス
  //private class RegistedSObjects {
  //  private Id cardId { get; private set; }
  //  private Map<SObjectType, SObject> objs { get; private set; }
  //  public RegistedSObjects(Id cardIed) {
  //    this.cardId = cardId;
  //    objs = new Map<SObjectType, SObject>();
  //  }
  //  public void putSObject(SObject obj) {
  //    objs.put(obj.getSObjectType(), obj);
  //  }
  //  public SOBject getSObject(SObjectType otype) {
  //    return objs.get(otype);
  //  }
  //}
  // +---- レスポンス用 ----+
  // +--------------------------------------------------------+

  // +---- 所有者を調べるクラス ----+
  private class OwnerChecker {
    public Map<Id, String> run(RegistRequest req) {
      Map<Id, String> result = new Map<Id, String>();

      return result;
    }
  }


  // +--------------------------------------------------------+
  // SB_NameCardL_RegistHelper
  // +--------------------------------------------------------+
  @TestVisible private RegistRequest req;
  @TestVisible private RegistResponse result;

  public RegistResponse getRegistResponse() {
    return result;
  }

  @TestVisible private Boolean success;
  @TestVisible private Map<SObjectType, SmartViscaf.SB_NameCard_RenkeiMapper> mappers;
  // シングルトン の SmartVisca 基本設定 を参照
  private SmartViscaf__NameCardBasicSetting__c setting;
  // 名刺と対応する 既存あるいは新規の アカウント、コンタクトの情報を保持する
  public List<SB_NameCardL_RegistCardHolder.AccountRegistHolder> holders { get; private set; }    // 公開する。
  // 名刺IDと関連付けた Contact OR Lead のID 個人取引先も
  private Map<Id, Id> cardId2ContactLeadId;

  public SB_NameCardL_RegistHelper() {
    this.setting = SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting();
    this.cardId2ContactLeadId = new Map<Id, Id>();
    this.success = false;
    this.req = null;
    this.result = new RegistResponse(this.req);
  }

  public SB_NameCardL_RegistHelper(RegistRequest req) {
    this.setting = SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting();
    this.cardId2ContactLeadId = new Map<Id, Id>();
    this.success = false;
    this.req = req;
    this.result = new RegistResponse(this.req);
  }

  // 登録処理ができるか確認。1. 所有者が適切か
  public Boolean canRegist(RegistRequest req) {
    if (req.targets.isEmpty()) {
      throw new SB_NameCardL_RegistHelperException('Request do not have target Id.');
    }
    this.result.process = 'CheckOwner';
    // 所有者のチェック
    Map<Id, String> owner2Error = SB_NameCardL_RegistOwenrCheckHelper.doCheck(req);
    if (!owner2Error.isEmpty()) {
      this.result.setOwnerCheckError(owner2Error);
      return false;
    }
    return true;
  }

  public void run() {
    Savepoint sp = null;
    try {
      // 関連する既存のレコードを集める
      this.result.process = 'start';
      // 対象のアカウントとコンタクトのIDを収集
      // SB_NameCardL_RegistCardHolderBuilder builder = new SB_NameCardL_RegistCardHolderBuilder();
      // this.holders = (List<SB_NameCardL_RegistCardHolder.AccountRegistHolder> )builder.create(req.targets);
      this.holders = (List<SB_NameCardL_RegistCardHolder.AccountRegistHolder> )SB_NameCardL_RegistCardHolderBuilder.createCardHolders(req.targets);

      sp = Database.setSavepoint();

      this.result.process = 'account';
      if (this.req.acntParam != null) {
        accountProc();
      }

      this.result.process = 'contact';
      if (this.req.contParam != null) {
        contactProc();
      }

      //if (this.holders instanceOf List<SB_NameCardL_RegistCardHolder.LeadAccountRegistHolder>) {
      if (this.req.leadParam != null) {
        this.result.process = 'lead';
        leadProc();
      }
      //}

      this.result.process = 'campaign';
      campaignProc();

      this.result.process = 'namecard';
      cardProc();

      // ToDo を作成
      this.result.process = 'todo';
      todoProc();

      // 既存の行動、ToDoの 名前WhoIdを作成したコンタクトにする。
      this.result.process = 'activity';
      activityProc();

      this.result.process = 'finalize';
      //this.result.finalize(this.cardId2Registed);
      this.result.finalize(this.holders);
      this.result.process = 'end';
    }
    catch(Exception e) {
      if (sp != null) {
        Database.rollback(sp);
      }
      this.success = false;
      if (e instanceOf SB_NameCardL_RegistHelperException) {
        this.result.falt(e.getMessage());
      }
      else if (e instanceOf SmartViscaf.SB_NameCard_CrudFls.CrudFlsException) {
        this.result.falt(e.getMessage());
      }
      else {
        throw e;
      }
    }
    //return this.result;
  }

  // private static final String MSG_INVALIDOBJECTID = 'リクエストに不正な{0}IDがあります。';
  //private static final String MSG_INVALIDOBJECTID = 'Invalid {0} record Id in request.';

  // アカウントを作成 か 更新
  // アカウントについて処理する工程
  public void accountProc() {
    Map<Id, Account> acntId2UpdAccount = new Map<Id, Account>();
    Map<String, Account> companyId2NewAccount = new Map<String, Account>();
    System.debug('this.req.acntParam: ' + this.req.acntParam);
    SB_NameCardL_DMLProcessor.UiDmlProcessor newAcntProc = new SB_NameCardL_DMLProcessor.UiDmlProcessor(Account.sObjectType, this.req.acntParam.allowSave);
    SB_NameCardL_DMLProcessor.UiDmlProcessor updAcntProc = new SB_NameCardL_DMLProcessor.UiDmlProcessor(Account.sObjectType, this.req.acntParam.allowSave);

    for(SB_NameCardL_RegistCardHolder.AccountRegistHolder holder : this.holders) {
      if (holder.isUpdateAccount()) {
        // 既存の更新
        if (this.req.acntParam.overwrite) {
          // 更新するとき
          Id acntId = holder.getTargetAccountId();
          if (acntId2UpdAccount.containsKey(acntId)) {
            // すでに別の名刺で更新用アカウントを作ってた。
            Account acnt = acntId2UpdAccount.get(acntId);
            holder.putOthers(acnt);
          }
          else {
            Account acnt = holder.buildUpdAccount();
            acntId2UpdAccount.put(acnt.Id, acnt);
            updAcntProc.addCardHolder(holder);
          }
        }
        else {
          // 更新せずリンクのみ
          //holder.bindExistAccount();
          System.debug('Account: not overwrite');
        }
      }
      else if (holder.pType == ProcType.ACCOUNT || holder.pType == ProcType.BOTH) {
        // 新規作成する。
        if (companyId2NewAccount.containsKey(holder.companyId)) {
          // すでに別の名刺で新規アカウントを作ってた。
          Account acnt = companyId2NewAccount.get(holder.companyId);
          holder.putOthers(acnt);
        }
        else {
          Id ownerId = this.req.acntParam.ownerId == null ? holder.card.OwnerId : this.req.acntParam.ownerId; // NULL は一括登録のとき、
          Account acnt = holder.buildNewAccount(this.req.acntParam.recTypeId, ownerId);
          companyId2NewAccount.put(holder.companyId, acnt);
          newAcntProc.addCardHolder(holder);
        }
      }
    } // for
    // 更新処理
    if (updAcntProc.haveSObjects()) {
      updAcntProc.dbUpdate();
      if (!updAcntProc.success) {
        this.result.setError(updAcntProc);
        throw new SB_NameCardL_RegistHelperException(String.format(Label.SB_NCL_Regist_Error_Occured, new String[]{Account.SObjectType.getDescribe().getLabel()}));
      }
    }
    // 作成処理
    if (newAcntProc.haveSObjects()) {
      newAcntProc.dbCreate();
      if (!newAcntProc.success) {
        this.result.setError(newAcntProc);
        throw new SB_NameCardL_RegistHelperException(String.format(Label.SB_NCL_Regist_Error_Occured, new String[]{Account.SObjectType.getDescribe().getLabel()}));
      }
    }
  } // private void accountProc()

  // コンタクトを作成 か 更新
  // コンタクトについて処理する工程
  public void contactProc() {
    Map<Id, Contact> contId2UpdContact = new Map<Id, Contact>();
    Map<String, Contact> personId2NewContact = new Map<String, Contact>();
    SB_NameCardL_DMLProcessor.UiDmlProcessor newContProc = new SB_NameCardL_DMLProcessor.UiDmlProcessor(Contact.sObjectType, this.req.contParam.allowSave);
    SB_NameCardL_DMLProcessor.UiDmlProcessor updContProc = new SB_NameCardL_DMLProcessor.UiDmlProcessor(Contact.sObjectType, this.req.contParam.allowSave);

    for(SB_NameCardL_RegistCardHolder.AccountRegistHolder holder : this.holders) {
      //if (holder.getAccountId()== null || holder.isContactTooMuch()) {    // アカウントがない（作れなかった） OR 既存のコンタクが複数いる
      //  continue;
      //}
      if (holder.isUpdateContact()) {
        // 既存の更新
        if (this.req.contParam.overwrite) {
          Id contId = holder.getTargetContactId();
          if (contId2UpdContact.containsKey(contId)) {
            // すでに別の名刺で更新用コンタクトを作ってた。
            Contact cont = contId2UpdContact.get(contId);
            holder.putOthers(cont);
          }
          else {
            Contact cont = holder.buildUpdContact();
            contId2UpdContact.put(contId, cont);
            updContProc.addCardHolder(holder);
          }
        }
        else {
          // 更新せずリンクのみ
          //holder.bindExistContact();
          System.debug('Contact: not overwrite');
        }
      }
      else if (holder.pType == ProcType.ACCOUNT || holder.pType == ProcType.BOTH) {
        // 新規作成する。
        if (personId2NewContact.containsKey(holder.personId)) {
          // すでに別の名刺で新規コンタクトを作ってた。
          Contact cont = personId2NewContact.get(holder.personId);
          holder.putOthers(cont);
        }
        else {
          Id ownerId = this.req.contParam.ownerId == null ? holder.card.OwnerId : this.req.contParam.ownerId; // NULL は一括登録のとき、
          Contact cont = holder.buildNewContact(this.req.contParam.recTypeId, ownerId);
          personId2NewContact.put(holder.personId, cont);
          newContProc.addCardHolder(holder);
        }
      }
    } // for
    // 更新処理
    if (updContProc.haveSObjects()) {
      updContProc.dbUpdate();
      if (!updContProc.success) {
        this.result.setError(updContProc);
        throw new SB_NameCardL_RegistHelperException(String.format(Label.SB_NCL_Regist_Error_Occured, new String[]{Contact.SObjectType.getDescribe().getLabel()}));
      }
    }
    // 作成処理
    if (newContProc.haveSObjects()) {
      newContProc.dbCreate();
      if (!newContProc.success) {
        this.result.setError(newContProc);
        throw new SB_NameCardL_RegistHelperException(String.format(Label.SB_NCL_Regist_Error_Occured, new String[]{Contact.SObjectType.getDescribe().getLabel()}));
      }
    }
  } // private void contactProc()

  // リードを作成 か 更新
  // リードについて処理する工程
  public void leadProc() {
    Map<Id, Lead> leadId2UpdLead = new Map<Id, Lead>();
    Map<String, Lead> meishiLeadId2NewLead = new Map<String, Lead>();
    SB_NameCardL_DMLProcessor.UiDmlProcessor newLeadProc = new SB_NameCardL_DMLProcessor.UiDmlProcessor(Lead.sObjectType, this.req.leadParam.allowSave);
    SB_NameCardL_DMLProcessor.UiDmlProcessor updLeadProc = new SB_NameCardL_DMLProcessor.UiDmlProcessor(Lead.sObjectType, this.req.leadParam.allowSave);

    for(SB_NameCardL_RegistCardHolder.AccountRegistHolder arh : (List<SB_NameCardL_RegistCardHolder.AccountRegistHolder>)this.holders) {
      if (!(arh instanceOf SB_NameCardL_RegistCardHolder.LeadAccountRegistHolder)) {
        continue;
      }
      SB_NameCardL_RegistCardHolder.LeadAccountRegistHolder holder = (SB_NameCardL_RegistCardHolder.LeadAccountRegistHolder)arh;
      //if (holder.getAccountId()== null || holder.isContactTooMuch()) {    // アカウントがない（作れなかった） OR 既存のコンタクが複数いる
      //  continue;
      //}
      if (holder.isUpdateLead()) {
        // 既存の更新
        if (this.req.leadParam.overwrite) {
          Id leadId = holder.getTargetLeadId();
          if (leadId2UpdLead.containsKey(leadId)) {
            // すでに別の名刺で更新用リードを作ってた。
            Lead l = leadId2UpdLead.get(leadId);
            holder.putOthers(l);
          }
          else {
            Lead l = holder.buildUpdLead();
            leadId2UpdLead.put(leadId, l);
            updLeadProc.addCardHolder(holder);
          }
        }
        else {
          // 更新せずリンクのみ
          //holder.bindExistContact();
          System.debug('Lead: not overwrite');
        }
      }
      else if (holder.pType == ProcType.Lead || holder.pType == ProcType.BOTH) {
        // 新規作成する。
        if (meishiLeadId2NewLead.containsKey(holder.meishiLeadId)) {
          // すでに別の名刺で新規リードを作ってた。
          Lead l = meishiLeadId2NewLead.get(holder.meishiLeadId);
          holder.putOthers(l);
        }
        else {
          Id ownerId = this.req.leadParam.ownerId == null ? holder.card.OwnerId : this.req.leadParam.ownerId; // NULL は一括登録のとき、
          Lead l = holder.buildNewLead(this.req.leadParam.recTypeId, ownerId);
          meishiLeadId2NewLead.put(holder.meishiLeadId, l);
          newLeadProc.addCardHolder(holder);
        }
      }
    } // for
    // 更新処理
    if (updLeadProc.haveSObjects()) {
      updLeadProc.dbUpdate();
      if (!updLeadProc.success) {
        this.result.setError(updLeadProc);
        throw new SB_NameCardL_RegistHelperException(String.format(Label.SB_NCL_Regist_Error_Occured, new String[]{Lead.SObjectType.getDescribe().getLabel()}));
      }
    }
    // 作成処理
    if (newLeadProc.haveSObjects()) {
      newLeadProc.dbCreate();
      if (!newLeadProc.success) {
        this.result.setError(newLeadProc);
        throw new SB_NameCardL_RegistHelperException(String.format(Label.SB_NCL_Regist_Error_Occured, new String[]{Lead.SObjectType.getDescribe().getLabel()}));
      }
    }
  } // private void leadProc()

  // ToDo を作成
  private void todoProc() {
    List<Task> tasks = new List<Task>();

    for(SB_NameCardL_RegistCardHolder.AccountRegistHolder holder : this.holders) {
      if (holder.getCreateTodo() == false) {
        continue;
      }
      Task todo = holder.createTodoPrototype(req.todoParam.ownerId);
      // SV_DEV-1092 適切な件名を付与する
      //todo.Subject = this.req.todoParam.subject;
      if ( String.isBlank(this.req.todoParam.subjectL) ){
        todo.Subject = this.req.todoParam.subject;
      } else {
        if ( holder.pType != SB_NameCardL_RegistHelper.ProcType.LEAD){
          todo.Subject = this.req.todoParam.subject;
        }else{
          todo.Subject = this.req.todoParam.subjectL;
        }
      }

      todo.Description = this.req.todoParam.comment;
      if (todo.ActivityDate <= Date.today() || todo.ActivityDate == null)  {
        todo.Status = SB_NameCardL_Util.taskStatusValues.get('Completed');
      }
      else {
        todo.Status = SB_NameCardL_Util.taskStatusValues.get('NotStarted');
      }
      tasks.add(todo);
    }
    SmartViscaf.SB_NameCard_CrudFls.screate(tasks, true);
  }

  // 名刺に着いてた 活動の WhoId がNULLだったら、 コンタクト、リードのIDをセットする。
  private void activityProc() {
    if (this.cardId2ContactLeadId.isEmpty()) {
      return;
    }
    attachTask();
    attachEvent();
  }

  // 対象の名刺が関連先に指定されていて、名前がNULLの ToDo の名前を名刺で作成した コンタクト  or Lead にする。
  private void attachTask() {
    Set<Id> cardIds = new Set<Id>(this.cardId2ContactLeadId.keySet());
    List<Task> tasks = [SELECT Id, WhoId, WhatId FROM Task WHERE WhoId=null AND WhatId IN :cardIds];
    for(Task t : tasks) {
      Id contLeadId = this.cardId2ContactLeadId.get(t.WhatId);
      if (contLeadId == null) continue;
      t.WhoId = contLeadId;
    }
    if (!tasks.isEmpty()) {
      SMartViscaf.SB_NameCard_CrudFls.supdate(tasks, false);
    }
  }

  // 対象の名刺が関連先に指定されていて、名前がNULLの 行動 の名前を名刺で作成した コンタクトor Lead  にする。
  private void attachEvent() {
    Set<Id> cardIds = new Set<Id>(this.cardId2ContactLeadId.keySet());
    List<Event> events = [SELECT Id, WhoId, WhatId FROM Event WHERE WhoId=null AND WhatId IN :cardIds];
    for(Event e : events) {
      Id contLeadId = this.cardId2ContactLeadId.get(e.WhatId);
      if (contLeadId == null) continue;
      e.WhoId = contLeadId;
    }
    if (!events.isEmpty()) {
      SMartViscaf.SB_NameCard_CrudFls.supdate(events, false);
    }
  }


  // 名刺 参照項目をセットして更新
  private void cardProc() {
    List<SmartViscaf__NameCard__c> cards = new List<SmartViscaf__NameCard__c>();
    for(SB_NameCardL_RegistCardHolder.AccountRegistHolder holder : this.holders) {
      SmartViscaf__NameCard__c card = holder.updateCard();
      cards.add(card);
    }
    SmartViscaf.SB_NameCard_CrudFls.supdate(cards, true);
  }

  //// キャンペーンID+コンタクトorリードID、ステータスを保持して、CampaignMember レコードを作るクラス
  //private class CampaignMemberBuilder {
  //  public Id campId { get; private set; }
  //  public Id targetId { get; private set; }
  //  public String status { get; private set; }
  //  public CampaignMemberBuilder(Id campId, Id targetId, String status) {
  //    this.campId = campId;
  //    this.targetId = targetId;
  //    this.status = status;
  //  }
  //  public CampaignMember create() {
  //    CampaignMember result = null;
  //    if (targetId.getSobjectType() == Contact.sObjectType) {
  //      result = new CampaignMember(CampaignId=campId, ContactId=targetId, Status = status);
  //    }
  //    else if (targetId.getSobjectType() == Lead.sObjectType) {
  //      result = new CampaignMember(CampaignId=campId, LeadId=targetId, Status = status);
  //    }
  //    return result;
  //  }
  //}

  // 作成・更新した リード・コンタクトをキャンペーンメンバーにする。
  private void campaignProc() {
    // キャンペーンID+コンタクトorリードID と CampaignMemberBuilder のリストのマップ
    //Map<String, CampaignMemberBuilder> campIdTargetId2Builder = new  Map<String, CampaignMemberBuilder>();
    Map<String, CampaignMember> campIdTargetId2CamMember = new  Map<String, CampaignMember>();
    // キャンペーンID ごとに 名刺レコード リスト をまとめる。
    for (SB_NameCardL_RegistCardHolder.AccountRegistHolder holder : (List<SB_NameCardL_RegistCardHolder.AccountRegistHolder>)this.holders) {
      // コンタクトのキャンペーンメンバー指定について調べる。
      if (holder.isContactCampaignMember() && holder.getContactId() != null) {
        String key = (String)holder.getContactCampaignId() + (String)holder.getContactId();
        //if (!campIdTargetId2Builder.containsKey(key)) {
        //  campIdTargetId2Builder.put(key, new CampaignMemberBuilder(holder.getContactCampaignId(), holder.getContactId(), holder.getContactCampaignStatus()));
        //}
        if (!campIdTargetId2CamMember.containsKey(key)) {
          CampaignMember cm = holder.buildContactCampaignMember(holder.getContactCampaignId(), holder.getContactCampaignStatus());
          campIdTargetId2CamMember.put(key, cm);
        }
      }
      // リードのキャンペーンメンバー指定について調べる。
      if (holder.isLeadCampaignMember() && holder.getLeadId() != null) {
        String key = (String)holder.getLeadCampaignId() + (String)holder.getLeadId();
        //if (!campIdTargetId2Builder.containsKey(key)) {
        //  campIdTargetId2Builder.put(key, new CampaignMemberBuilder(holder.getLeadCampaignId(), holder.getLeadId(), holder.getLeadCampaignStatus()));
        //}
        if (!campIdTargetId2CamMember.containsKey(key)) {
          CampaignMember cm = holder.buildLeadCampaignMember(holder.getLeadCampaignId(), holder.getLeadCampaignStatus());
          campIdTargetId2CamMember.put(key, cm);
        }
      }
    }
    //if (campIdTargetId2Builder.isEmpty()) {
    //  return;
    //}
    //List<CampaignMember> cms = new List<CampaignMember>();
    //for (CampaignMemberBuilder builder : campIdTargetId2Builder.values()) {
    //  cms.add(builder.create());
    //}
    //SmartViscaf.SB_NameCard_CrudFls.screate(cms, true);
    if (!campIdTargetId2CamMember.isEmpty()) {
      SmartViscaf.SB_NameCard_CrudFls.screate(campIdTargetId2CamMember.values(), true);
    }
  }

}