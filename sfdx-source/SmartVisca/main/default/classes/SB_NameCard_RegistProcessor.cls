/**
 *
 * SB_NameCard_RegistProcessor
 *  名刺から 登録プロセスの処理クラスの抽象クラス  自動連携、UIの取引先登録 個別、一括 もこれを使う
 *  createCardHolders に名刺レコードを渡して
 *    CardHolder　-> RegistCardHolder  で名刺ごとの情報をくるんでる のを得る
 *
 * Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2017.05.xx
 *  @Version 3      2017.08.xx    自動連携検証機能対応
 *  @Version 2.2    sawano   2019.03.XX 2.1.1 パッチで で2019.02 コードスキャンをパス → セキュリティレビュー更新 2.2へ反映
 *
 **/
global with sharing abstract class SB_NameCard_RegistProcessor {

  global enum Process { Create, Modify, CreateThrow, ModifyThrow, LinkOnly }  // 処理内容の識別 2017.08.xx

  global static final Map<Process, String> PROCESS_TEXT = new Map<Process, String> {  // 2017.08.xx
    Process.Create => System.Label.SB_NC_Text_Create,     // '作成', 2019.03.xx v2.2
    Process.Modify => System.Label.SB_NC_Text_Update, // '更新', 2019.03.xx v2.2
    Process.CreateThrow => System.Label.SB_NC_Renkei_CreateElsewhere, //  '他で作成', 2019.03.xx v2.2
    Process.ModifyThrow => System.Label.SB_NC_Renkei_UpdateElsewhere, // '他で更新', 2019.03.xx v2.2
    Process.LinkOnly => System.Label.SB_NC_Renkei_UpdateReference // '参照の更新' 2019.03.xx v2.2
  };

  public static String getProcessName(Process p) {
    return PROCESS_TEXT.get(p);
  }

  private final static Map<SObjectType, String> OTYPE_REFKEY = new Map<SObjectType, String>{
    Account.sObjectType => 'account__c',
    Contact.sObjectType => 'contact__c',
    Lead.sObjectType => 'lead__c'
  };

  // シングルトン の SmartVisca 基本設定 を参照
  protected NameCardBasicSetting__c setting;
  // 名刺と対応する 既存あるいは新規の アカウント、コンタクトの情報を保持する
  public List<SB_NameCard_RegistCardHolder.RegistCardHolder> holders { get; protected set; }    // 公開する。
  // 名刺IDと関連付けた Contact OR Lead のID 個人取引先も
  protected Map<Id, Id> cardId2ContactLeadId;

  global SB_NameCard_RegistProcessor() {
    this.setting = SB_NameCard_BasicSetting.getNameCardBasicSetting();
    this.cardId2ContactLeadId = new Map<Id, Id>();
  }

  global virtual void run() {
    System.assert(this.holders != null);

    accountProc();

    contactProc();

    cardProc();

    todoProc();

    activityProc();

  }

  // アカウント について処理する工程
  global abstract void accountProc();

  // コンタクト について処理する工程
  global abstract void contactProc();

  // 名刺について処理する工程
  // （before）トリガー用、UI用は override する。
  protected virtual void cardProc() {
    for(SB_NameCard_RegistCardHolder.RegistCardHolder holder : this.holders) {
      updateCard(holder);
    }
  }

  // 名刺レコードに 名刺に関連付けた アカウント、コンタクト、リードへの参照項目をセットする。
  //   v1.22 2018.01.xx Beforeトリガでよばれるならレコードはそのまま使うけど、UIでは更新したい項目だけ持ったインスタンスを作るように override する。
  protected virtual NameCard__c updateCard(SB_NameCard_RegistCardHolder.RegistCardHolder holder) {
    NameCard__c card = holder.card;
    if (holder.isNewAccount() || (holder.isExistAccount() && setting.RenkeiAccountOverwrite__c)) {
      // アカウントを追加・更新していたら => 既存取引先上書き不可
      card.isNotOverwrite__c = !card.isNotOverwrite__c && !setting.RenkeiAccountOverwrite__c && card.account__c == null;
    }
    if (holder.isNewContact() || (holder.isExistContact() && setting.RenkeiContactOverwrite__c)) {
      // コンタクトを追加・更新していたら => 既存取引先責任者上書き不可
      card.isNotOverContactwrite__c = !card.isNotOverContactwrite__c && !setting.RenkeiContactOverwrite__c && card.contact__c == null;
    }
    card.account__c = holder.getAccountId() != null ? holder.getAccountId() : card.account__c;  // アカウントの参照 NULL かも
    card.contact__c = holder.getContactId() !=null ? holder.getContactId() : card.contact__c;   // コンタクトの参照 NULL かも
    if (card.Id != null && card.contact__c != null) { //
      putContactLead(card.Id, card.contact__c);   // 名刺ID- Contact Id  あとで活動のWhoIdにコンタクトIDをつけるのにつかう
    }
    holder.modifySomeCardFields(card);
    return card;
  }
  // 関連付けた コンタクトまたはリードの IDを保持しとく
  protected void putContactLead(Id cardId, Id targetId) {
    System.assert(cardId != null && targetId != null);
    cardId2ContactLeadId.put(cardId, targetId);
  }

  // 名刺交換 ToDo を作るプロセス 自動連携のときはスルー
  protected virtual void todoProc() {}

  // 名刺に着いてた 活動の WhoId がNULLだったら、 コンタクト、リードのIDをセットする。自動連携のときはスルー
  // スルーしない！  override する 2019.05.xx SV_DEV-893 【自動連携】1次納品段階で登録した活動履歴を取引先・取引先責任者に引き継ぎたい
  protected virtual void activityProc() {}

  // 対象の名刺が関連先に指定されていて、名前がNULLの ToDo の名前を名刺で作成した コンタクト  or Lead にする。
  protected void attachTask() {
    Set<Id> cardIds = new Set<Id>(this.cardId2ContactLeadId.keySet());
    List<Task> tasks = [SELECT Id, WhoId, WhatId FROM Task WHERE WhoId=null AND WhatId IN :cardIds];
    for(Task t : tasks) {
      Id contId = this.cardId2ContactLeadId.get(t.WhatId);
      if (contId == null) continue;
      t.WhoId = contId;
    }
    if (!tasks.isEmpty()) {
      SB_NameCard_CrudFls.supdate(tasks, false);
    }
  }

  // 対象の名刺が関連先に指定されていて、名前がNULLの 行動 の名前を名刺で作成した コンタクトor Lead  にする。
  protected void attachEvent() {
    Set<Id> cardIds = new Set<Id>(this.cardId2ContactLeadId.keySet());
    List<Event> events = [SELECT Id, WhoId, WhatId FROM Event WHERE WhoId=null AND WhatId IN :cardIds];
    for(Event e : events) {
      Id contId = this.cardId2ContactLeadId.get(e.WhatId);
      if (contId == null) continue;
      e.WhoId = contId;
    }
    if (!events.isEmpty()) {
      SB_NameCard_CrudFls.supdate(events, false);
    }
  }

}