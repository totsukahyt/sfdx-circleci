/**
 *
 *  SB_NameCardL_RenkeiHelper
 * SB_NameCard_RenkeiTriggerHelper + SB_NameCard_RegistProcessor の改造
 * 自動連携機能で、絞り込まれた名刺を入力として、対象のアカウント、コンタクト、リードなどを作成、更新する Helperクラス
 *
 * Copyright (C) 2017-2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  SB_NameCard_RenkeiTriggerHelper
 *  @Version 1      2017.02.xx
 *  @Version 2      2017.06.xx    トリガ版、UI版の統一化
 *  @Version 3      2017.08.xx    自動連携検証機能対応
 *  @Version 4      2018.02.xx v1.22 SV_DEV-585 自動連携で既存取引先責任者が一意に特定できるなら取引先があいまいでも重複エラーにしない
 *
 *  SB_NameCardL_RenkeiHelper
 *  lx v2.0 (v.1.12) SB_NameCard_RenkeiTriggerHelper + SB_NameCard_RegistProcessor の改造
 *  lx2.1 2020.01.xx SV_DEV-1970 自動連携のリード関連「カスタム設定」項目の移行(リード連携拡張パッケージ側改修
 *
 **/
public with sharing class SB_NameCardL_RenkeiHelper extends SB_NameCardL_RenkeiHelperAbstract {
  public enum ProcType { ACCOUNT, LEAD, BOTH }
  // public enum Process { Create, Modify, CreateSkip, ModifySkip, LinkOnly }  // 処理内容の識別 2017.08.xx

  // 2018.02.xx v1.22 複数既存アカウントがあっても、既存取引先責任者をもつ取引先が1つだけあったら、それを使う
  private static final Boolean RENKEI_USE_1ACCOUNT_CONTACT = true;

  private static Map<SObjectType, Set<Id>> oType2RectypeIds;
  static {
    oType2RectypeIds = new Map<SObjectType, Set<Id>>();
    oType2RectypeIds.put(Account.sObjectType, getRecordTypeIds(Account.sObjectType));
    oType2RectypeIds.put(Contact.sObjectType, getRecordTypeIds(Contact.sObjectType));
    oType2RectypeIds.put(Lead.sObjectType, getRecordTypeIds(Lead.sObjectType));
  }

  private static Set<Id> getRecordTypeIds(SObjectType otype) {
    Set<Id> result = new Set<Id>();
    for (Schema.RecordTypeInfo info :otype.getDescribe().getRecordTypeInfos()) {
      if (info.isAvailable() == false) continue;   // ユーザが使用可能なものだけ
      if (info.isMaster() == true) continue;   // マスターは除外
      result.add(info.getRecordTypeId());
    }
    return result;
  }

  // 指定されているIDが正しいかチェックして、OKなら、IDにキャストして返す。NGだったらNULLを返す。
  private static Id getValidRecordTypeId(SObjectType otype, String id) {

    Id result = null;
    try {
      if (String.isNotBlank(id) && oType2RectypeIds.get(otype).contains((Id)id)) {
        result = (Id)id;
      }
    }
    catch (Exception e) {
      System.debug('Illegal RecordType Id String.');
    }
    return result;
  }

  // これで連携の処理を開始
  // 2017.08.xx 結果を返すように修正
  // 2017.11.xx Query で 例外が発生したりするので キャッチする。 ← SV_DEV-629 取引先の登録数が20万を超える組織に対して会社名が「医療法人〇〇」等の名刺が納品されると自動連係処理でエラーが発生する
  public static void doRenkei(List<SmartViscaf__NameCard__c> cards, ProcType pType) {
    //System.assertEquals(ProcType.ACCOUNT, pType);
    SB_NameCardL_RenkeiHelperAbstract proc = null;
    try {
      if (pType == ProcType.ACCOUNT) {
        // 取引先・取引先責任者用の自動連携ヘルパークラスを呼び出す テストのときだけ
        proc = new SB_NameCardL_RenkeiHelper();
        SB_NameCardL_RenkeiHelper.pType = ProcType.ACCOUNT;
      }
      else if (pType == ProcType.LEAD) {
        // リード拡張パッケージの 自動連携ヘルパークラスを呼び出し
        // 取引先・取引先責任者あるいはリードを作成・更新し、キャンペーンメンバー にする。
        // String lxNamespace = SmartViscaf.SB_NameCard_Util.getLeadExNamespacePrefix();
        // Type extClass = Type.forName(lxNamespace, 'SB_NameCardL_RenkeiHelper');
        // proc = (SB_NameCardL_RenkeiHelperAbstract)extClass.newInstance();
        proc = new SB_NameCardL_RenkeiHelper();
      }
      proc.init(cards); // lx 2.0 から
      proc.run();
    }
    catch(Exception e) {
      // 2017.11.xx v1.20.3  例外メッセージを名刺の連携処理結果 項目にセットする
      setExceptionMEssage(cards, e);
    }
    return;
  }

  private static final String MSG_SEPARATOR = ' ; ';
  // 2017.11.xx v1.20.3  例外メッセージを名刺の連携処理結果 項目にセットする
  private static void setExceptionMEssage(List<SmartViscaf__NameCard__c> cards, Exception e) {
    Schema.DescribeFieldResult dfr = SmartViscaf__NameCard__c.SmartViscaf__RenkeiMessage__c.getDescribe();
    for (SmartViscaf__NameCard__c card : cards) {
      // 前に 付け足す
      card.SmartViscaf__RenkeiMessage__c = String.isNotBlank(card.SmartViscaf__RenkeiMessage__c) ? e.getMessage() + MSG_SEPARATOR + card.SmartViscaf__RenkeiMessage__c : e.getMessage();
      // 文字列が長くなってるかもしれないので切り詰める 。 画面上では切り詰められない。多分 Triggrt でも
      card.SmartViscaf__RenkeiMessage__c = card.SmartViscaf__RenkeiMessage__c.left(dfr.getLength());
    }
  }

  private static ProcType pType = ProcType.BOTH;
  private List<SB_NameCardL_RenkeiCardHolder.AccountRenkeiHolder> holders;
  private SmartViscaf__NameCardBasicSetting__c setting;

  public SB_NameCardL_RenkeiHelper() {
    this.setting = SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting();
  }

  public override void init(List<SmartViscaf__NameCard__c> cards) {
    // 対象のアカウントとコンタクトのIDを収集
    this.holders = (List<SB_NameCardL_RenkeiCardHolder.AccountRenkeiHolder>)SB_NameCardL_RenkeiCardHolderBuilder.createCardHolders(cards, pType);
  }

  public override void run() {
    // System.assert(this.holders != null);
    //
    if (this.holders.isEmpty()) {
      // 基本パッケージのSB_NameCard_RenkeiTriggerHelper.doRenkei()で来たとき。なにも処理しない
      return;
    }
    accountProc();

    contactProc();

    if (this.holders instanceOf List<SB_NameCardL_RenkeiCardHolder.LeadAccountRenkeiHolder>) {
      // リード
      leadProc();
    }

    // 名刺の更新 参照項目、処理結果
    cardProc();

    if (this.holders instanceOf List<SB_NameCardL_RenkeiCardHolder.LeadAccountRenkeiHolder> &&
      setting.SmartViscaf__RenkeiActiveCampaignMember__c) {
      // 作成した コンタクトあるいはリードを Campaign Memberにする。
      campaignProc();
    }

  }

  // アカウントについて処理する工程
  public void accountProc() {
    Map<Id, Account> acntId2UpdAccount = new Map<Id, Account>();
    Map<String, Account> companyId2NewAccount = new Map<String, Account>();
    SB_NameCardL_DMLProcessor.AutoDmlProcessor newAcntProc = new SB_NameCardL_DMLProcessor.AutoDmlProcessor(Account.sObjectType, false);
    SB_NameCardL_DMLProcessor.AutoDmlProcessor updAcntProc = new SB_NameCardL_DMLProcessor.AutoDmlProcessor(Account.sObjectType, false);

    Id recTypeId = getValidRecordTypeId(Account.sObjectType, setting.SmartViscaf__RenkeiAccountRecordTypes__c);

    for (SB_NameCardL_RenkeiCardHolder.AccountRenkeiHolder holder : this.holders) {
      // SB_NameCardL_RenkeiCardHolder.AccountRenkeiHolder holder = (SB_NameCardL_RenkeiCardHolder.AccountRenkeiHolder)h;
      // 2018.02.xx v1.22 SV_DEV-585 自動連携で既存取引先責任者が一意に特定できるなら取引先があいまいでも重複エラーにしない
      // //  → 最初に 既存を調べて 採用する アカウント、コンタクトを決めておく
      // holder.preProcess();
      //
      if (holder.isAccountTooMuch() && !holder.useExistAccount()) {
        // 既存アカウントが複数あって、どれか1つに絞れない
        holder.putMessage('[Account duplicate]');   // 2017.04.xx
        continue;
      }
      System.debug('holder.useExistAccount():' + holder.useExistAccount());
      if (holder.useExistAccount()) {
        System.debug('1');
        // 既存が1つか
        if (setting.SmartViscaf__RenkeiAccountOverwrite__c) {
          // 更新するとき
          Id acntId = holder.getTargetAccountId();
          if (acntId2UpdAccount.containsKey(acntId)) {
            // すでに別の名刺で更新用アカウントを作ってた。
            Account acnt = acntId2UpdAccount.get(acntId);
            holder.putOthers(acnt);
            // holder.acntProcess = SB_NameCardL_RenkeiCardHolder.RenkeiProcess.ModifyOther;
          }
          else {
            Account acnt = holder.buildUpdAccount();
            acntId2UpdAccount.put(acnt.Id, acnt);
            updAcntProc.addCardHolder(holder);
            holder.acntProcess = SB_NameCardL_RenkeiCardHolder.RenkeiProcess.Modify;
          }
        }
        else {
          // 更新せずリンクのみ
          //holder.bindExistAccount();
          holder.acntProcess = SB_NameCardL_RenkeiCardHolder.RenkeiProcess.ModifySkip;
        }
      }
      else if (holder.acntProcess == SB_NameCardL_RenkeiCardHolder.RenkeiProcess.Create &&
        setting.SmartViscaf__RenkeiAccountNOExistCreateNew__c && holder.isAccountNotExist()) {
        System.debug('2');
        // 新規作成する。
        if (companyId2NewAccount.containsKey(holder.companyId)) {
          // すでに別の名刺で新規アカウントを作ってた。
          Account acnt = companyId2NewAccount.get(holder.companyId);
          holder.putOthers(acnt);
          holder.putMessage('[Account create: another]');   // 2017.09.xx
          holder.acntProcess = SB_NameCardL_RenkeiCardHolder.RenkeiProcess.CreateOther;
        }
        else {
          Account acnt = holder.buildNewAccount(recTypeId, null);
          companyId2NewAccount.put(holder.companyId, acnt);
          newAcntProc.addCardHolder(holder);
          holder.acntProcess = SB_NameCardL_RenkeiCardHolder.RenkeiProcess.Create;
        }
      }
    } // for
    // 更新処理
    if (updAcntProc.haveSObjects()) {
      updAcntProc.dbUpdate();
    }
    // 作成処理
    if (newAcntProc.haveSObjects()) {
      newAcntProc.dbCreate();
    }
  } // protected void accountProc()

  // コンタクトについて処理する工程
  public void contactProc() {
    Map<Id, Contact> contId2UpdContact = new Map<Id, Contact>();
    Map<String, Contact> personId2NewContact = new Map<String, Contact>();
    SB_NameCardL_DMLProcessor.AutoDmlProcessor newContProc = new SB_NameCardL_DMLProcessor.AutoDmlProcessor(Contact.sObjectType, false);
    SB_NameCardL_DMLProcessor.AutoDmlProcessor updContProc = new SB_NameCardL_DMLProcessor.AutoDmlProcessor(Contact.sObjectType, false);

    Id recTypeId = getValidRecordTypeId(Contact.sObjectType, setting.SmartViscaf__RenkeiContactRecordTypes__c);

    for (SB_NameCardL_RenkeiCardHolder.AccountRenkeiHolder holder : this.holders) {
      // SB_NameCardL_RenkeiCardHolder.AccountRenkeiHolder holder = (SB_NameCardL_RenkeiCardHolder.AccountRenkeiHolder)h;
      if (holder.getAccountId()==null) {  // アカウントがない（作れなかった）
        continue;
      }
      if (holder.isContactTooMuch()) {    // 既存のコンタクトが複数いる
        holder.putMessage('[Contact duplicate]');   // 2017.04.xx
        continue;
      }
      if (holder.useExistContact()) {
        // 既存が1つあったとき
        if (setting.SmartViscaf__RenkeiContactOverwrite__c) {
          Id contId = holder.getTargetContactId();
          if (contId2UpdContact.containsKey(contId)) {
            // すでに別の名刺で更新用コンタクトを作ってた。
            Contact cont = contId2UpdContact.get(contId);
            holder.putOthers(cont);
            // holder.contProcess = SB_NameCardL_RenkeiCardHolder.RenkeiProcess.ModifyOther;
          }
          else {
            Contact cont = holder.buildUpdContact();
            contId2UpdContact.put(contId, cont);
            updContProc.addCardHolder(holder);
            holder.contProcess = SB_NameCardL_RenkeiCardHolder.RenkeiProcess.Modify;
          }
        }
        else {
          // 更新せずリンクのみ
          //holder.bindExistContact();
          holder.contProcess = SB_NameCardL_RenkeiCardHolder.RenkeiProcess.ModifySkip;
        }
      }
      else if (holder.contProcess == SB_NameCardL_RenkeiCardHolder.RenkeiProcess.Create &&
           setting.SmartViscaf__RenkeiContactNOExistCreateNew__c && holder.isContactNotExistWithAccount()) {
        // 新規作成する。
        if (personId2NewContact.containsKey(holder.personId)) {
          // すでに別の名刺で新規コンタクトを作ってた。
          Contact cont = personId2NewContact.get(holder.personId);
          holder.putOthers(cont);
          holder.putMessage('[Contact create: another]');   // 2017.09.xx
          holder.contProcess = SB_NameCardL_RenkeiCardHolder.RenkeiProcess.CreateOther;
        }
        else {
          Contact cont = holder.buildNewContact(recTypeId, null);
          personId2NewContact.put(holder.personId, cont);
          newContProc.addCardHolder(holder);
          holder.contProcess = SB_NameCardL_RenkeiCardHolder.RenkeiProcess.Create;
        }
      }
    } // for
    // 更新処理
    if (updContProc.haveSObjects()) {
      updContProc.dbUpdate();
    }
    // 作成処理
    if (newContProc.haveSObjects()) {
      newContProc.dbCreate();
    }
  } // protected void contactProc()

  public virtual void leadProc() {
    Map<Id, Lead> leadId2UpdLead = new Map<Id, Lead>();
    Map<String, Lead> meishiLeadId2NewLead = new Map<String, Lead>();
    SB_NameCardL_DMLProcessor.AutoDmlProcessor newLeadProc = new SB_NameCardL_DMLProcessor.AutoDmlProcessor(Lead.sObjectType, false);
    SB_NameCardL_DMLProcessor.AutoDmlProcessor updLeadProc = new SB_NameCardL_DMLProcessor.AutoDmlProcessor(Lead.sObjectType, false);

    Id recTypeId = getValidRecordTypeId(Lead.sObjectType, setting.SmartViscaf__RenkeiLeadRecordTypes__c);

    for (SB_NameCardL_RenkeiCardHolder.LeadAccountRenkeiHolder holder : (List<SB_NameCardL_RenkeiCardHolder.LeadAccountRenkeiHolder>)this.holders) {
      // SB_NameCardL_RenkeiCardHolder.AccountRenkeiHolder holder = (SB_NameCardL_RenkeiCardHolder.AccountRenkeiHolder)h;
      if (holder.isLeadTooMuch() &&   // 既存のリードが複数いる
        // SV_DEV-1970 カスタム設定からSmartVisca基本設定に移行
        // !SB_NameCardL_Util.smartViscaConfig.RenkeiUpdateAllLeadsOnCondition__c) {// 統合版自動連携:条件に合致する既存リードは全て更新する FALSE
         !setting.SmartViscaf__RenkeiUpdateAllLeadsOnCondition__c) {// 統合版自動連携:条件に合致する既存リードは全て更新する FALSE
        holder.putMessage('[Lead duplicate]');   // 2017.04.xx
        continue;
      }
      if (holder.leadProcess == SB_NameCardL_RenkeiCardHolder.RenkeiProcess.Modify) {
        // 既存を更新
        Id leadId = holder.getTargetLeadId();
        if (leadId != null) {
          // 既存リードが１つのとき
          if (leadId2UpdLead.containsKey(leadId)) {
            // すでに別の名刺で更新用コンタクトを作ってた。
            Lead l = leadId2UpdLead.get(leadId);
            holder.putOthers(l);
            // holder.contProcess = SB_NameCardL_RenkeiCardHolder.RenkeiProcess.ModifyOther;
          }
          else {
            Lead l = holder.buildUpdLead();
            leadId2UpdLead.put(leadId, l);
            updLeadProc.addCardHolder(holder);
            holder.leadProcess = SB_NameCardL_RenkeiCardHolder.RenkeiProcess.Modify;
          }
        }
        else if (!holder.haveConvertedLead() && // 取引開始済みリードはない
          // SV_DEV-1970 カスタム設定からSmartVisca基本設定に移行
          //SB_NameCardL_Util.smartViscaConfig.RenkeiUpdateAllLeadsOnCondition__c){
          setting.SmartViscaf__RenkeiUpdateAllLeadsOnCondition__c){
          // 既存リードが複数 複数を更新
          holder.putMessage('[Update All Leads]');   // 2017.04.xx
          List<Lead> leads = holder.buildUpdAllLeads(leadId2UpdLead.keySet());
          if (!leads.isEmpty()) {
            updLeadProc.addSObjects(leads);
            for (Lead l : leads) {
              leadId2UpdLead.put(l.Id, l);
            }
            updLeadProc.addCardHolder(holder);
          }
        }
      }
      else if (holder.leadProcess == SB_NameCardL_RenkeiCardHolder.RenkeiProcess.Create) {
        // 新規作成する。
        if (meishiLeadId2NewLead.containsKey(holder.personId)) {
          // すでに別の名刺で新規コンタクトを作ってた。
          Lead l = meishiLeadId2NewLead.get(holder.personId);
          holder.putOthers(l);
          holder.putMessage('[Lead create: another]');   // 2017.09.xx
          holder.leadProcess = SB_NameCardL_RenkeiCardHolder.RenkeiProcess.CreateOther;
        }
        else {
          Lead l = holder.buildNewLead(recTypeId, null);
          meishiLeadId2NewLead.put(holder.personId, l);
          newLeadProc.addCardHolder(holder);
          holder.leadProcess = SB_NameCardL_RenkeiCardHolder.RenkeiProcess.Create;
        }
      }
    } // for
    // 更新処理
    if (updLeadProc.haveSObjects()) {
      updLeadProc.dbUpdate();
    }
    // 作成処理
    if (newLeadProc.haveSObjects()) {
      newLeadProc.dbCreate();
    }

  }

  // 名刺について処理する工程
  // （before）トリガー用、UI用は override する。
  private void cardProc() {
    for(SB_NameCardL_RenkeiCardHolder.AccountRenkeiHolder holder : this.holders) {
      holder.updateCard();
    }
  }
  // // 名刺レコードに 名刺に関連付けた アカウント、コンタクト、リードへの参照項目をセットする。
  // //   v1.22 2018.01.xx Beforeトリガでよばれるならレコードはそのまま使うけど、UIでは更新したい項目だけ持ったインスタンスを作るように override する。
  // private virtual SmartViscaf__NameCard__c updateCard(SB_NameCardL_RegistCardHolder.AccountRenkeiHolder holder) {
  //   SmartViscaf__NameCard__c card = holder.card;
  //   if (holder.isNewAccount() || (holder.useExistAccount() && setting.SmartViscaf__RenkeiAccountOverwrite__c)) {
  //     // アカウントを追加・更新していたら => 既存取引先上書き不可
  //     card.SmartViscaf__isNotOverwrite__c = !card.SmartViscaf__isNotOverwrite__c && !setting.SmartViscaf__RenkeiAccountOverwrite__c && card.SmartViscaf__account__c == null;
  //   }
  //   if (holder.isNewContact() || (holder.useExistContact() && setting.SmartViscaf__RenkeiContactOverwrite__c)) {
  //     // コンタクトを追加・更新していたら => 既存取引先責任者上書き不可
  //     card.SmartViscaf__isNotOverContactwrite__c = !card.SmartViscaf__isNotOverContactwrite__c && !setting.SmartViscaf__RenkeiContactOverwrite__c && card.SmartViscaf__contact__c == null;
  //   }
  //   card.SmartViscaf__account__c = holder.getAccountId() != null ? holder.getAccountId() : card.SmartViscaf__account__c;  // アカウントの参照 NULL かも
  //   card.SmartViscaf__contact__c = holder.getContactId() !=null ? holder.getContactId() : card.SmartViscaf__contact__c;   // コンタクトの参照 NULL かも
  //   if (card.Id != null && card.SmartViscaf__contact__c != null) { //
  //     putContactLead(card.Id, card.SmartViscaf__contact__c);   // 名刺ID- Contact Id  あとで活動のWhoIdにコンタクトIDをつけるのにつかう
  //   }
  //   holder.modifySomeCardFields(card);
  //   return card;
  // }
  // // 関連付けた コンタクトまたはリードの IDを保持しとく
  // protected void putContactLead(Id cardId, Id targetId) {
  //   System.assert(cardId != null && targetId != null);
  //   cardId2ContactLeadId.put(cardId, targetId);
  // }
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
  //} // private class CampaignMemberBuilder {


  // 既存のキャンペンメンバーになってたら除外する。
  private void removeExistMember(Map<String, CampaignMember> campIdTargetId2CamMember, Set<Id> leadIds, Set<Id> contIds) {
    if (SB_NameCardL_Util.smartViscaConfig.RenkeiUpdateToCampaignMember__c == false || campIdTargetId2CamMember.isEmpty()) {
      // 更新をキャンペンメンバーにしてないなら!、チェック不要
      // キャンペーンメンバーにするのがなくてもチェック不要
      return;
    }
    List<CampaignMember> cms = [SELECT Id, CampaignId, LeadId, ContactId FROM CampaignMember WHERE LeadId IN :leadIds OR ContactId IN :contIds];
    for (CampaignMember cm : cms) {
      String campIdTargetId = null;
      if (cm.LeadId != null) {
        campIdTargetId = (String)cm.CampaignId + (String)cm.LeadId;
      }
      else if (cm.ContactId != null) {
        campIdTargetId = (String)cm.CampaignId + (String)cm.ContactId;
      }
      if (campIdTargetId2CamMember.containsKey(campIdTargetId)) {
        campIdTargetId2CamMember.remove(campIdTargetId);
      }
    }
  }
  //private void removeExistMember(Map<String, CampaignMemberBuilder> campIdTargetId2Builder, Set<Id> leadIds, Set<Id> contIds) {
  //  if (SB_NameCardL_Util.smartViscaConfig.RenkeiUpdateToCampaignMember__c == false) {
  //    // 更新をキャンペンメンバーにしてないなら!、チェック不要
  //    return;
  //  }
  //  List<CampaignMember> cms = [SELECT Id, CampaignId, LeadId, ContactId FROM CampaignMember WHERE LeadId IN :leadIds OR ContactId IN :contIds];
  //  for (CampaignMember cm : cms) {
  //    String campIdTargetId = null;
  //    if (cm.LeadId != null) {
  //      campIdTargetId = (String)cm.CampaignId + (String)cm.LeadId;
  //    }
  //    else if (cm.ContactId != null) {
  //      campIdTargetId = (String)cm.CampaignId + (String)cm.ContactId;
  //    }
  //    if (campIdTargetId2Builder.containsKey(campIdTargetId)) {
  //      campIdTargetId2Builder.remove(campIdTargetId);
  //    }
  //  }
  //}


  // 作成・更新した リード、コンタクトをキャンペーンメンバーにする。
  private void campaignProc() {
    // キャンペーンID+コンタクトorリードID と CampaignMemberBuilder のリストのマップ
    //Map<String, CampaignMemberBuilder> campIdTargetId2Builder = new  Map<String, CampaignMemberBuilder>();
    //Map<String, CampaignMember> campIdTargetId2Builder = new  Map<String, CampaignMember>();
    Map<String, CampaignMember> campIdTargetId2CamMember = new  Map<String, CampaignMember>();
    Set<Id> leadIds = new Set<Id>();
    Set<Id> contIds = new Set<Id>();
    // キャンペーンID ごとに 名刺レコード リスト をまとめる。
    for (SB_NameCardL_RenkeiCardHolder.LeadAccountRenkeiHolder holder : (List<SB_NameCardL_RenkeiCardHolder.LeadAccountRenkeiHolder>)this.holders) {
      // キャンペーンメンバー指定について調べる。
      if (String.isNotBlank(holder.card.campaign__c)) {
        // リード？
        if (holder.getLeadId() != null &&
            (SB_NameCardL_Util.smartViscaConfig.RenkeiUpdateToCampaignMember__c == true ||      // 統合版自動連携: 更新でもキャンペーンメンバーにする。 か
            holder.getLeadProcessResult() == SB_NameCardL_RegistCardHolder.ProcessResult.CREATE)) {  // 新規作成
          String key = holder.card.campaign__c + (String)holder.getLeadId();
          //if (!campIdTargetId2Builder.containsKey(key)) {
          //  campIdTargetId2Builder.put(key, new CampaignMemberBuilder(holder.card.campaign__c, holder.getLeadId(), setting.SmartViscaf__RenkeiCampaignStatus__c));
          //  leadIds.add(holder.getLeadId());
          //}
          if (!campIdTargetId2CamMember.containsKey(key)) {
            CampaignMember cm = holder.buildLeadCampaignMember(holder.card.campaign__c, setting.SmartViscaf__RenkeiCampaignStatus__c);
            campIdTargetId2CamMember.put(key, cm);
            leadIds.add(holder.getLeadId());
          }
        }
        // コンタクト？
        if (SB_NameCardL_Util.smartViscaConfig.RenkeiContactToCampaignMember__c && // コンタクトもキャンペーンメンバーにする。
            holder.getContactId() != null &&
            (SB_NameCardL_Util.smartViscaConfig.RenkeiUpdateToCampaignMember__c == true ||      // 統合版自動連携: 更新でもキャンペーンメンバーにする。 か
            holder.getContProcessResult() == SB_NameCardL_RegistCardHolder.ProcessResult.CREATE)) {  // 新規作成
          String key = holder.card.campaign__c + (String)holder.getContactId();
          //if (!campIdTargetId2Builder.containsKey(key)) {
          //  campIdTargetId2Builder.put(key, new CampaignMemberBuilder(holder.card.campaign__c, holder.getContactId(), setting.SmartViscaf__RenkeiCampaignStatus__c));
          //  contIds.add(holder.getContactId());
          //}
        if (!campIdTargetId2CamMember.containsKey(key)) {
          CampaignMember cm = holder.buildContactCampaignMember(holder.card.campaign__c, setting.SmartViscaf__RenkeiCampaignStatus__c);
          campIdTargetId2CamMember.put(key, cm);
          contIds.add(holder.getContactId());
        }
        }
      }
    }
    //if (campIdTargetId2Builder.isEmpty()) {
    //  return;
    //}
    if (campIdTargetId2CamMember.isEmpty()) {
      return;
    }
    // 既存のキャンペンメンバーになってたら除外する。
    //removeExistMember(campIdTargetId2Builder, leadIds, contIds);
    removeExistMember(campIdTargetId2CamMember, leadIds, contIds);
    // CampaignMemberBuilder をで キャンペンIDと対象ID、ステータスの キャンペンメンバー レコードを作成
    //List<CampaignMember> cms = new List<CampaignMember>();
    //for (CampaignMemberBuilder builder : campIdTargetId2Builder.values()) {
    //  cms.add(builder.create());
    //}
    //SmartViscaf.SB_NameCard_CrudFls.screate(cms, true);
    if (!campIdTargetId2CamMember.isEmpty()) {
      SmartViscaf.SB_NameCard_CrudFls.screate(campIdTargetId2CamMember.values(), true);
    }
  } // private void campaignProc() {

  //private void campaignProc() {
  //  //
  //  Map<Id, List<SB_NameCardL_RenkeiCardHolder.LeadAccountRenkeiHolder>> campId2Holders = new Map<Id, List<SB_NameCardL_RenkeiCardHolder.LeadAccountRenkeiHolder>>();
  //  // キャンペーンID ごとに 名刺レコード リスト をまとめる。
  //  for (SB_NameCardL_RenkeiCardHolder.LeadAccountRenkeiHolder holder : (List<SB_NameCardL_RenkeiCardHolder.LeadAccountRenkeiHolder>)this.holders) {
  //    Id campaignId = null;
  //    if (String.isNotBlank(holder.card.campaign__c)) {
  //      try {
  //        campaignId = (Id)holder.card.campaign__c;
  //      }
  //      catch(Exception e) {}
  //    }
  //    if (campaignId == null) {
  //      continue;
  //    }
  //    List<SB_NameCardL_RenkeiCardHolder.LeadAccountRenkeiHolder> camHolders = null;
  //    if (campId2Holders.containsKey(campaignId)) {
  //      camHolders = campId2Holders.get(campaignId);
  //    }
  //    else {
  //      camHolders = new List<SB_NameCardL_RenkeiCardHolder.LeadAccountRenkeiHolder>();
  //      campId2Holders.put(campaignId, camHolders);
  //    }
  //    camHolders.add(holder);
  //  } // for
  //  if (campId2Holders.isEmpty()) {
  //    // キャンペーンID指定なかった
  //    return;
  //  }
  //  // キャンペーンID指定ごとに リード コンタクトの キャンペーンメンバーレコードを作る。
  //  List<CampaignMember> cms = new List<CampaignMember>();
  //  for (Id campId : campId2Holders.keySet()) {
  //    Set<Id> leadIds = new Set<Id>();
  //    Set<Id> contIds = new Set<Id>();
  //    for (SB_NameCardL_RenkeiCardHolder.LeadAccountRenkeiHolder holder : campId2Holders.get(campId)) {
  //      //  リードID 重複しないように整理する。
  //      Id leadId = holder.getLeadId();
  //      if (leadId != null) {
  //        leadIds.add(leadId);
  //      }
  //      else if (SB_NameCardL_Util.smartViscaConfig.RenkeiUpdateAllLeadsOnCondition__c &&
  //        !holder.getLeadCandidates().isEmpty()) {
  //        for (SB_NameCardL_RenkeiCardHolder.Candidate can : holder.getLeadCandidates()) {
  //          leadIds.add(can.candidateId);
  //        }
  //      }
  //      if (SB_NameCardL_Util.smartViscaConfig.RenkeiContactToCampaignMember__c) {
  //        // コンタクトもキャンペーンメンバーにする。
  //        //  コンタクトID 重複しないように整理する。
  //        Id contId = holder.getContactId();
  //        if (contId != null) {
  //          contIds.add(contId);
  //        }
  //      }
  //    }
  //    for (Id contId : contIds) {
  //      cms.add(new CampaignMember(CampaignId=campId, ContactId=contId, Status = setting.SmartViscaf__RenkeiCampaignStatus__c));
  //    }
  //    for (Id leadId : leadIds) {
  //      cms.add(new CampaignMember(CampaignId=campId, LeadId=leadId, Status = setting.SmartViscaf__RenkeiCampaignStatus__c));
  //    }
  //  } // for
  //  if (cms.isEmpty()) {
  //    return;
  //  }
  //  SmartViscaf.SB_NameCard_CrudFls.screate(cms, true);
  //}

} //public with sharing class SB_NameCardL_RenkeiHelper extends SB_NameCardL_RenkeiHelperAbstract {