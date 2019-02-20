/**
 *SB_NameCardL_RegistCardHolder
 * 基本の SB_NameCard_RegistCardHolder そのまま
 *  アカウント、コンタクト、リードへ登録する 名刺 について、名刺ごとのデータを保持するクラス
 *
 * Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2017.04.xx
 *  @Version 2      2017.07.xx V1.20.1 取引先のない既存の取引先責任者対応
 *                              SV_DEV-549 自動連係 所有者に関するマッピングが機能していない
 *  @Version 3      2017.12.xx ToDoの任命先を NULL指定のとき 作成・更新した コンタクトのオーナに変更. SV_DEV-715 「取引先・取引先責任者に登録」の更新時のTodoの任命先は取引先責任者の所有者にする
 *                  2018.04.xx v2.0 global にするP
 *  @Version 4      2018.04.xx LeadEx v2.0  public にしとく
 *    → 次は 基本の v2.1 にこれを移す そのときは global  になる
 *
 * lx2.0 2018.06.xx
 *
 **/
public with sharing class SB_NameCardL_RegistCardHolder {

  public enum ProcessResult { NONE, CREATE, MODIFY, OTHERS }

  ////////////////////////////////////////
  // 名刺と関連するレコードに関する情報を保持する用のクラス CardHolder
  ////////////////////////////////////////
  public abstract class CardHolder {
    protected SmartViscaf__NameCardBasicSetting__c setting;
    public SmartViscaf__NameCard__c card { get; private set; }
    public String companyId { get; private set; }   // この名刺の会社の識別用文字列
    public String personId { get; private set; }   // この名刺の個人の識別用文字列
    public String meishiLeadId { get; private set; }   // この名刺のリード用の識別用文字列
    protected Id acntId;    //
    protected Id contId;    //
    protected Id leadId;    //
    public Account acnt { get; protected set; }            // この名刺に紐付けるアカウント  新規 OR 更新 OR ヒモ付のみ
    public Contact cont { get; protected set; }            // この名刺に紐付けるコンタクト  新規 OR 更新 OR ヒモ付のみ
    public Lead lead { get; protected set; }            // この名刺に紐付けるコンタクト  新規 OR 更新 OR ヒモ付のみ
    public CampaignMember contCampaignMember { get; protected set; }            // この名刺で登録したコンタクトで作ったキャンペーンメンバー
    public CampaignMember leadCampaignMember { get; protected set; }            // この名刺で登録したリードで作ったキャンペーンメンバー
    protected ProcessResult acntResult;
    protected ProcessResult contResult;
    protected ProcessResult leadResult;
    public ProcessResult getAcntProcessResult() { return this.acntResult; }
    public ProcessResult getContProcessResult() { return this.contResult; }
    public ProcessResult getLeadProcessResult() { return this.leadResult; }
    protected Id todoOwnerId; // 2017.12.xx ToDo の任命先用 作成・更新するレコードの所有者、更新の場合は コンタクトあるいはリードの所有者 年のため、NULLなら 名刺の所有者 //
    // //public String getKaishaKojinName() { return companyId + personId; }
    public CardHolder(SmartViscaf__NameCard__c card) {
      this.card =card;
      this.acnt = null;
      this.acntId = null;
      this.cont = null;
      this.contId = null;
      this.lead = null;
      this.leadId = null;
      this.acntResult = ProcessResult.NONE;
      this.contResult = ProcessResult.NONE;
      this.leadResult = ProcessResult.NONE;
      // this.otype2upserted = new Map<SObjectType, SObject>();
      this.setting = SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting();   // 基本設定
      buildCompanyId();
      buildPersonId();
      buildLeadKojinId();
      // this.personId = this.companyId + 'L=' + this.personId;
      this.messages = new List<String>();
    }
    // オブジェクトタイプと 更新 or 作成 したオブジェクトのマップ リードで複数更新してたらNULL
    //  同一トランザクションでの他の名刺で作成、更新したものを含む
    // protected Map<SObjectType, SObject> otype2upserted;x
    // // 指定された方の SObject を返す。
    public SObject getSObject(SObjectType otype) {
      if (otype == Account.sObjectType) {
        return this.acnt;
      }
      else if (otype == Contact.sObjectType) {
        return this.cont;
      }
      else if (otype == Schema.Lead.sObjectType) {
        return this.lead;
      }
      return null;
      // if (this.otype2upserted.containsKey(otype)) {
      //   return this.otype2upserted.get(otype);
      // }
      // return null;
    }
    public Id getSObjectId(SObjectType otype) {
      SObject obj = getSObject(otype);
      // SObject obj = this.otype2upserted.get(otype);
      if (obj != null) {
        return obj.Id;
      }
      return null;
    }

    //
    // 既存のコンタクトか 新規作成中の アカウントをセット  同一トランザクションに同じ名刺（会社）が他にあったときはこれ
    public virtual void putOthers(Account acnt) {
      this.acnt = acnt;
      this.acntId = acnt.Id;    // NULLかも
      this.acntResult = ProcessResult.OTHERS;
    }
    // 既存のコンタクトか 新規作成中の コンタクトをセット  同一トランザクションに同じ名刺が他にあったときはこれ
    public virtual void putOthers(Contact cont) {
      this.cont = cont;
      this.contId = cont.Id;    // NULLかも
      this.contResult = ProcessResult.OTHERS;
      this.todoOwnerId = cont.OwnerId != null ? cont.OwnerId : this.todoOwnerId;    // この名刺でのコンタクトのToDoの任命先 新規のとき : 更新のとき
    }
    // 既存のリードか 新規作成中の リードをセット  同一トランザクションに同じ名刺が他にあったときはこれ
    public virtual void putOthers(Lead l) {
      this.lead = l;
      this.leadId = l.Id;
      this.leadResult = ProcessResult.OTHERS;
      this.todoOwnerId = l.OwnerId != null ? l.OwnerId : this.todoOwnerId;    // この名刺でのリードのToDoの任命先 新規のとき : 更新のとき
    }

    // 既存のアカウントを更新用に作成
    public Account buildUpdAccount() {
      //bindExistAccount();
      SmartViscaf.SB_NameCard_RenkeiMapper mapper = SmartViscaf.SB_NameCard_RenkeiMapper.getInstance('Account', true);
      this.acnt = (Account)mapper.updateRecord(this.card, this.acntId);
      // this.otype2upserted.put(Account.sObjectType, this.acnt);
      this.acntResult = ProcessResult.MODIFY;
      return this.acnt;
    }

    // 新規にアカウントを作成
    public Account buildNewAccount(Id rectypeId, Id ownerId) {
      System.assert(this.acnt==null);
      SmartViscaf.SB_NameCard_RenkeiMapper mapper = SmartViscaf.SB_NameCard_RenkeiMapper.getInstance('Account', true);
      this.acnt = (Account)mapper.createRecord(this.card, rectypeId);
      if (ownerId != null) {
        // 所有者を指定されていたら変更 SV_DEV-549 自動連係 所有者に関するマッピングが機能していない
        this.acnt.OwnerId = ownerId;
      }
      // this.otype2upserted.put(Account.sObjectType, this.acnt);
      this.acntResult = ProcessResult.CREATE;
      return this.acnt;
    }

    // 既存のコンタクトを更新用に作成
    public Contact buildUpdContact() {
      //bindExistContact();
      SmartViscaf.SB_NameCard_RenkeiMapper mapper = SmartViscaf.SB_NameCard_RenkeiMapper.getInstance('Contact', true);
      this.cont = (Contact)mapper.updateRecord(this.card, this.contId);
      this.cont.AccountId = this.acntId;
      // this.otype2upserted.put(Contact.sObjectType, this.cont);
      this.contResult = ProcessResult.MODIFY;
      return this.cont;
    }

    // 新規にコンタクトを作成
    public Contact buildNewContact(Id rectypeId, Id ownerId) {
      System.assert(this.cont==null);
      SmartViscaf.SB_NameCard_RenkeiMapper mapper = SmartViscaf.SB_NameCard_RenkeiMapper.getInstance('Contact', true);
      this.cont = (Contact)mapper.createRecord(this.card, rectypeId);
      this.cont.AccountId = this.acnt != null && this.acnt.Id != null ? this.acnt.Id : this.acntId;  // 新規作成したアカウントの場合か、既存のアカウントの場合か
      if (ownerId != null) {
        // 所有者を指定されていたら変更 SV_DEV-549 自動連係 所有者に関するマッピングが機能していない
        this.cont.OwnerId = ownerId;
      }
      // コンタクトの所有者ID をとっておく 新規のときのToDo所有者用
      this.todoOwnerId = this.cont.OwnerId;   // この名刺でのコンタクトのToDoの任命先
      // this.otype2upserted.put(Contact.sObjectType, this.cont);
      this.contResult = ProcessResult.CREATE;
      return this.cont;
    }

    // 既存のリードを更新用に作成
    public Lead buildUpdLead() {
      // リード用のマッピングレコードから、変換クラスを作成
      // 注意）第２引数 本当は true だけど、基本v2.0.2まで、自動連携のとき用で OWNERID 以外で更新してはいけない 項目マップ  RENKEI_DONOT_UPDATE_FIELDS に LEADのがないので NULL Po 例外になるので 更新できないのないし false にしとく
      SmartViscaf.SB_NameCard_RenkeiMapper mapper = SmartViscaf.SB_NameCard_RenkeiMapper.getInstance('Lead', false);
      this.lead = (Lead)mapper.updateRecord(this.card, this.leadId);
      // this.otype2upserted.put(Schema.Lead.sObjectType, this.lead);
      this.leadResult = ProcessResult.MODIFY;
      return this.lead;
    }

    // 新規にリードを作成
    public Lead buildNewLead(Id rectypeId, Id ownerId) {
      System.assert(this.lead==null);
      // リード用のマッピングレコードから、変換クラスを作成
      // 注意）第２引数 本当は true だけど、基本v2.0.2まで、自動連携のとき用で OWNERID 以外で更新してはいけない 項目マップ  RENKEI_DONOT_UPDATE_FIELDS に LEADのがないので NULL Po 例外になるので 更新できないのないし false にしとく
      SmartViscaf.SB_NameCard_RenkeiMapper mapper = SmartViscaf.SB_NameCard_RenkeiMapper.getInstance('Lead', false);
      this.lead = (Lead)mapper.createRecord(this.card, rectypeId);
      if (ownerId != null) {
        this.lead.OwnerId = ownerId;
      }
      // リードの所有者ID をとっておく 新規のときのToDo所有者用
      this.todoOwnerId = this.lead.OwnerId; // この名刺でのリードのToDoの任命先
      // this.otype2upserted.put(Schema.Lead.sObjectType, this.lead);
      this.leadResult = ProcessResult.CREATE;
      return this.lead;
    }

    private CampaignMember buildCampaignMember(Id campId, Id targetId, String status) {
      CampaignMember result = null;
      if (targetId!=null && targetId.getSobjectType() == Contact.sObjectType) {
        result = new CampaignMember(CampaignId=campId, ContactId=targetId, Status = status);
      }
      else if (targetId!=null && targetId.getSobjectType() == Schema.Lead.sObjectType) {
        result = new CampaignMember(CampaignId=campId, LeadId=targetId, Status = status);
      }
      return result;
    }

    // コンタクト で キャンペーンメンバーを作成
    public CampaignMember buildContactCampaignMember(Id campId, String status) {
      this.contCampaignMember = buildCampaignMember(campId, getContactId(), status);
      return this.contCampaignMember;
    }

    // リード で キャンペーンメンバーを作成
    public CampaignMember buildLeadCampaignMember(Id campId, String status) {
      this.leadCampaignMember = buildCampaignMember(campId, getLeadId(), status);
      return this.leadCampaignMember;
    }

    public Id getAccountId() {
      return this.acnt != null ? this.acnt.Id : this.acntId;  // リンクだけのときは this.acntId
      // return getSObjectId(Account.sObjectType);
      // return this.acntId;
    }
    public Id getContactId() {
      return this.cont != null ? this.cont.Id : this.contId;  // リンクだけのときは this.contId
      // return getSObjectId(Contact.sObjectType);
      // return this.contId;
    }
    public Id getLeadId() {
      return this.lead != null ? this.lead.Id : this.leadId;  // リンクだけのときは this.leadId
      // return getSObjectId(Schema.Lead.sObjectType);
      // return this.leadId;
    }
    // 名刺レコードに 名刺に関連付けた アカウント、コンタクト、リードへの参照項目をセットする。
    //   v1.22 2018.01.xx Beforeトリガでよばれるならレコードはそのまま使うけど、UIでは更新したい項目だけ持ったインスタンスを作るように override する。
    public virtual SmartViscaf__NameCard__c updateCard() {
       if (this.acntResult == ProcessResult.CREATE || this.acntResult == ProcessResult.MODIFY || this.acntResult == ProcessResult.OTHERS) {
         // アカウントを追加・更新していたら => 既存取引先上書き不可
         this.card.SmartViscaf__isNotOverwrite__c = !this.card.SmartViscaf__isNotOverwrite__c && !this.setting.SmartViscaf__RenkeiAccountOverwrite__c && this.card.SmartViscaf__account__c == null;
       }
       if (this.contResult == ProcessResult.CREATE || this.contResult == ProcessResult.MODIFY || this.contResult == ProcessResult.OTHERS) {
         // コンタクトを追加・更新していたら => 既存取引先責任者上書き不可
         this.card.SmartViscaf__isNotOverContactwrite__c = !this.card.SmartViscaf__isNotOverContactwrite__c && !this.setting.SmartViscaf__RenkeiContactOverwrite__c && this.card.SmartViscaf__contact__c == null;
       }
      this.card.SmartViscaf__account__c = getAccountId() != null ? getAccountId() : this.card.SmartViscaf__account__c;  // アカウントの参照 NULL かも
      this.card.SmartViscaf__contact__c = getContactId() !=null ? getContactId() : this.card.SmartViscaf__contact__c;   // コンタクトの参照 NULL かも
      this.card.SmartViscaf__lead__c = getLeadId() !=null ? getLeadId() : this.card.SmartViscaf__lead__c;   // コンタクトの参照 NULL かも
      // if (this.card.Id != null && this.card.SmartViscaf__contact__c != null) { //
      //   putContactLead(this.card.Id, this.card.SmartViscaf__contact__c);   // 名刺ID- Contact Id  あとで活動のWhoIdにコンタクトIDをつけるのにつかう
      // }
      modifySomeCardFields(this.card);
      return this.card;
    }
    // 名刺の項目を更新する。派生クラスごと、名刺の項目の更新する要素が違うときは
    protected virtual void modifySomeCardFields(SmartViscaf__NameCard__c nc) {}

    // 会社識別子作成
    // 作成する アカウントの識別用に 名刺の会社系データからこさえる
    private void buildCompanyId() {
      // SmartViscaf__NameCardBasicSetting__c setting = SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting();   // 基本設定
      this.companyId = this.card.SmartViscaf__company_name__c;
      Map<String, String> address = SmartViscaf.SB_NameCard_Util.getAddress(this.card);
      if (this.setting.SmartViscaf__RenkeiAccountSite__c) {
        this.companyId += 'D=' + this.card.SmartViscaf__division__c;
      }
      if (this.setting.SmartViscaf__RenkeiAccountAddressPref__c) {
        this.companyId += 'P=' + this.card.SmartViscaf__address_pref__c;
      }
      if (this.setting.SmartViscaf__RenkeiAccountCity__c) {
        this.companyId += 'C=' + address.get('city');
      }
      if (this.setting.SmartViscaf__RenkeiAccount_Street__c) {
        this.companyId += 'S=' + address.get('street_nobld'); // 町名・番地 建物なし
      }
      if (this.setting.SmartViscaf__RenkeiAccountZipCode__c) {
        this.companyId += 'Z=' + this.card.SmartViscaf__zip_code__c;
      }
      if (this.setting.SmartViscaf__RenkeiAccountPhone__c) {
        this.companyId += 'T=' + this.card.SmartViscaf__tel1__c + ',' + this.card.SmartViscaf__tel2__c;
      }
      if (this.setting.SmartViscaf__RenkeiAccountURL__c) {
        this.companyId += 'W=' + this.card.SmartViscaf__web_url1__c + ',' + this.card.SmartViscaf__web_url2__c;
      }
      if (String.isNotBlank(this.setting.SmartViscaf__RenkeiSpecificItems__c)) {
        this.companyId += 'E=' + this.card.SmartViscaf__memo__c;
      }
    }

    // 個人識別子作成
    // この名刺の個人の識別用文字列 同時に処理される同内容の名刺を識別するよう
    private void buildPersonId() {
      // SmartViscaf__NameCardBasicSetting__c setting = SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting();   // 基本設定
      if (String.isNotBlank(this.card.SmartViscaf__person_name_last__c)) {
        this.personId = this.card.SmartViscaf__person_name_last__c;
      }
      else if (String.isNotBlank(this.card.SmartViscaf__last_name__c)) {
        this.personId = this.card.SmartViscaf__last_name__c;
      }
      if (this.setting.SmartViscaf__RenkeiContactFirstName__c) {
        if (String.isNotBlank(this.card.SmartViscaf__person_name_first__c)) {
          this.personId += 'F=' + this.card.SmartViscaf__person_name_first__c;
        }
        else if (String.isNotBlank(this.card.SmartViscaf__first_name__c)) {
          this.personId += 'F=' + this.card.SmartViscaf__first_name__c;
        }
      }
      if (this.setting.SmartViscaf__RenkeiContactMail__c) {
        this.personId += 'M=' + this.card.SmartViscaf__email__c;
      }
    }

    private void buildLeadKojinId() {
      this.meishiLeadId = this.card.SmartViscaf__company_name__c;
      Map<String, String> address = SmartViscaf.SB_NameCard_Util.getAddress(this.card);
      if (this.setting.SmartViscaf__RenkeiLeadAddressPref__c) {
        this.meishiLeadId += 'P=' + this.card.SmartViscaf__address_pref__c;
      }
      if (this.setting.SmartViscaf__RenkeiLeadCity__c) {
        this.meishiLeadId += 'C=' + address.get('city');
      }
      if (this.setting.SmartViscaf__RenkeiLeadStreet__c) {
        this.meishiLeadId += 'S=' + address.get('street_nobld'); // 町名・番地 建物なし
      }
      if (this.setting.SmartViscaf__RenkeiLeadZipCode__c) {
        this.meishiLeadId += 'Z=' + this.card.SmartViscaf__zip_code__c;
      }
      if (this.setting.SmartViscaf__RenkeiLeadPhone__c) {
        this.meishiLeadId += 'T=' + this.card.SmartViscaf__tel1__c + ',' + this.card.SmartViscaf__tel2__c;
      }
      if (this.setting.SmartViscaf__RenkeiLeadURL__c) {
        this.meishiLeadId += 'W=' + this.card.SmartViscaf__web_url1__c + ',' + this.card.SmartViscaf__web_url2__c;
      }
      if (String.isNotBlank(this.setting.SmartViscaf__RenkeiSpecificItems__c)) {
        this.meishiLeadId += 'E=' + this.card.SmartViscaf__memo__c;
      }
      // 個人系
      if (this.setting.SmartViscaf__RenkeiLeadLastName__c) {
        if (String.isNotBlank(this.card.SmartViscaf__person_name_last__c)) {
          this.meishiLeadId+= 'Ln=' + this.card.SmartViscaf__person_name_last__c;
        }
        else if (String.isNotBlank(this.card.SmartViscaf__last_name__c)) {
          this.meishiLeadId+= 'Ln=' + this.card.SmartViscaf__last_name__c;
        }
      }
      if (this.setting.SmartViscaf__RenkeiLeadFirstName__c) {
        if (String.isNotBlank(this.card.SmartViscaf__person_name_first__c)) {
          this.meishiLeadId += 'Fn=' + this.card.SmartViscaf__person_name_first__c;
        }
        else if (String.isNotBlank(this.card.SmartViscaf__first_name__c)) {
          this.meishiLeadId += 'Fn=' + this.card.SmartViscaf__first_name__c;
        }
      }
      if (this.setting.SmartViscaf__RenkeiLeadMail__c) {
        this.meishiLeadId += 'M=' + this.card.SmartViscaf__email__c;
      }
    }

    // // 必要なら、処理状況を保持する。
    // public virtual void putMessage(String msg) {}
    protected List<String> messages;
    // DMLの処理情報を追加する。
    public void putMessage(String msg) {
      this.messages.add(msg);
    }

  }  // class CardHolder

  // ////////////////////////////////////////
  // // 名刺と関連するアカウント、コンタクト レコードに関する情報を保持し、アカウント、コンタクト レコードを更新、作成する用のクラス
  // //  トリガ用 = 自動連携用
  // ////////////////////////////////////////
  public virtual class AccountRegistHolder extends CardHolder {
    public Integer num { get; protected set; } // リストにしたときの順番 = リクエストの順番
    public SB_NameCardL_RegistHelper.ProcType pType { get; private set;}
    private Boolean createTodo;     //  名刺交換ToDOを作る？
    private Date todoDate;          // 名刺交換ToDO の日付の指定
    public Task todo { get; private set; }
    public Id contCampaignId;
    public String contCampaignStatus;

    public AccountRegistHolder(SmartViscaf__NameCard__c card) {
      super(card);
      this.createTodo = false;
      this.pType = SB_NameCardL_RegistHelper.ProcType.NONE;
    }

    public void setProcType(SB_NameCardL_RegistHelper.ProcType pType) {
      this.pType = pType;
    }

    // リストにしたときの順番 = リクエストの順番 のセット
    public void setNumber(Integer n) {
      this.num = n;
    }

    // アカウントを更新？
    public Boolean isUpdateAccount() {
     return this.acntId != null;
    }
    // コンタクトを更新？
    public Boolean isUpdateContact() {
      return this.contId != null;
    }

    public Id getTargetAccountId() {
      return this.acntId;
    }

    public Id getTargetContactId() {
      return this.contId;
    }

    // 更新するアカウント レコードをセット
    public void setTarget(Account acnt) {
      this.acnt = acnt;
      this.acntId = acnt.Id;
    }

    // 更新するコンタクト レコードをセット
    public void setTarget(Contact cont) {
      System.debug(cont);
      this.cont = cont;
      this.contId = cont.Id;
      this.todoOwnerId = cont.OwnerId;    // 2017.12.xx コンタクトの所有者ID をとっておく 更新のときのToDo所有者用
      System.debug(this.cont);
    }

    // 更新するリード レコードをセット
    public virtual void setTarget(Lead l) {}

    // ToDo関連
    //  名刺交換ToDOを作る？
    public void setCreateTodo(Boolean b) {
      this.createTodo = b;
    }

    //  名刺交換ToDOを作る？
    public Boolean getCreateTodo() {
      return this.createTodo;
    }

    // 名刺交換ToDO の日付の指定
    public void setTodoDate(Date d) {
      this.todoDate = d;
    }

    public Task createTodoPrototype(Id ownerId) {
      System.debug(this.cont);
      this.todo = new Task();
      if (this.pType != SB_NameCardL_RegistHelper.ProcType.LEAD) {
        // 取引先の処理をしたとき
        this.todo.WhatId = getAccountId();
        this.todo.WhoId = getContactId();
      }
      else {
        //　リードの処理をしたとき
        this.todo.WhoId = getLeadId();
      }
      this.todo.ActivityDate = todoDate != null ? todoDate : this.card.SmartViscaf__card_exchange_date__c;     //  日付 は指定された日付か 名刺交換日
      // 任命先
      // 2017.04.25 NULLの場合、UserInfo.getUserId();からthis.card.OwnerIdへ変更
      // 2017.12.xx 作成・更新した コンタクトのオーナに変更. SV_DEV-715 「取引先・取引先責任者に登録」の更新時のTodoの任命先は取引先責任者の所有者にする
      System.debug('ownerId: ' + ownerId);
      this.todo.OwnerId = ownerId != null ? ownerId : (this.todoOwnerId != null ? this.todoOwnerId : this.card.OwnerId);
      System.debug('this.todoOwnerId: ' + this.todoOwnerId);
      System.debug('this.todo.OwnerId: ' + this.todo.OwnerId);
      return todo;
    }

    // キャンペーン関連
    // コンタクトをキャンペーンメンバーにする。
    public Boolean isContactCampaignMember() { return this.contCampaignId != null; }
    // コンタクトのキャンペーンメンバーの指定
    public void setContactCampaign(Id campaignId, String campaignStatus) {
      this.contCampaignId = campaignId;
      this.contCampaignStatus = campaignStatus;
    }
    //public void setContactCampaignId(Id id) { this.contCampaignId = id; }
    public Id getContactCampaignId() { return this.contCampaignId; }
    //  キャンペーンメンバーのステータス
    //public void setContactCampaignStatus(String s ) { this.contCampaignStatus = s; }
    public String getContactCampaignStatus() { return this.contCampaignStatus; }

    //public Boolean isContactCampaignMember() { return false; }  // コンタクトをキャンペーンメンバーにする。
    //public Id getContactCampaignId() { return null; }  // コンタクトをキャンペーンメンバーにする。
    //public String getContactCampaignStatus() { return null; } //  コンタクト キャンペーンメンバーのステータス
      // リード をキャンペーンメンバーにする用
    public virtual Boolean isLeadCampaignMember() { return false; }
    public virtual Id getLeadCampaignId() { return null; }
    public virtual String getLeadCampaignStatus() { return null; }
    // リードのキャンペーンメンバーの指定
    public virtual void setLeadCampaign(Id campaignId, String campaignStatus) { }


  }  // class AccountRegistHolder


  // ////////////////////////////////////////
  // // 名刺と関連するアカウント、コンタクト レコードに関する情報を保持し、アカウント、コンタクト、リード レコードを更新、作成する用のクラス
  // //  トリガ用 = 自動連携用
  // ////////////////////////////////////////
  public class LeadAccountRegistHolder extends AccountRegistHolder {
    public Id leadCampaignId;
    public String leadCampaignStatus;
    public LeadAccountRegistHolder(SmartViscaf__NameCard__c card) {
      super(card);
      // this.lead = null;
      // this.leadId = null;
    }

    public Boolean isUpdateLead() {
     return this.leadId != null;
    }

    public Id getTargetLeadId() {
      return this.leadId;
    }

    // 更新するリード レコードをセット
    public override void setTarget(Lead l) {
      this.lead = l;
      this.leadId = l.Id;
      this.todoOwnerId = l.OwnerId;    // 2017.12.xx コンタクトの所有者ID をとっておく 更新のときのToDo所有者用
    }

    public override Boolean isLeadCampaignMember() { return this.leadCampaignId != null; }  // リード をキャンペーンメンバーにする。
    public override void setLeadCampaign(Id campaignId, String campaignStatus) {
      this.leadCampaignId = campaignId;
      this.leadCampaignStatus = campaignStatus;
    }
    // リードまたはコンタクトをキャンペーンメンバーにする。
    public override Id getLeadCampaignId() { return this.leadCampaignId; }
    //  キャンペーンメンバーのステータス
    public override String getLeadCampaignStatus() { return this.leadCampaignStatus; }


    // 名刺 更新関連
    // 連携処理情報を書き出す
    public override void modifySomeCardFields(SmartViscaf__NameCard__c nc) {
      if (!isLeadCampaignMember()) {
        return;
      }
      nc.campaign__c = getLeadCampaignId();
    }


  } // public class LeadAccountRegistHolder extends AccountRegistHolder {

}