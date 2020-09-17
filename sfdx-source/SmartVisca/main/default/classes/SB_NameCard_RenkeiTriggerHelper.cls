/**
 *
 * SB_NameCard_RenkeiTriggerHelper
 * 自動連携機能で、絞り込まれた名刺を入力として、対象のアカウント、コンタクト、リードなどを作成、更新する Helperクラス
 *
 * Copyright (C) 2017-2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2017.02.xx
 *  @Version 2      2017.06.xx    トリガ版、UI版の統一化
 *  @Version 3      2017.08.xx    自動連携検証機能対応
 *  @Version 4      2018.02.xx v1.22 SV_DEV-585 自動連携で既存取引先責任者が一意に特定できるなら取引先があいまいでも重複エラーにしない
 *  @Version 5      2019.05.xx v2.4 SV_DEV-893 【自動連携】1次納品段階で登録した活動履歴を取引先・取引先責任者に引き継ぎたい
 *                                  SV_DEV-1684 【自動連携】設定により取引先を作成せず「未登録」となった場合の自動連携処理情報に記載される文言を変えて欲しい
 *  @Version 2.6 全 2020.08.19 PRODUCT-34 自動連携処理結果の文言変更
 *  @Version 2.6 全 2020.08.26 PRODUCT-26 自動連携する際に、名刺交換日が最新の場合にのみ取引先・取引先責任者・リードを上書きするようなオプションがほしい
 * 
 **/
public with sharing class SB_NameCard_RenkeiTriggerHelper extends SB_NameCard_RegistProcessor {

  public enum ProcType { ACCOUNT, LEAD }
  // 2018.02.xx v1.22 複数既存アカウントがあっても、既存取引先責任者をもつ取引先が1つだけあったら、それを使う
  private static final Boolean RENKEI_USE_1ACCOUNT_CONTACT = true;

  private static Map<SObjectType, Set<Id>> oType2RectypeIds;
  static {
    oType2RectypeIds = new Map<SObjectType, Set<Id>>();
    oType2RectypeIds.put(Account.sObjectType, getRecordTypeIds(Account.sObjectType));
    oType2RectypeIds.put(Contact.sObjectType, getRecordTypeIds(Contact.sObjectType));
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
  public static List<SB_NameCard_RegistCardHolder.AccountCardHolder> doRenkei(List<NameCard__c> cards, ProcType pType) {
  //public static void doRenkei(List<NameCard__c> cards, ProcType pType) {
    //System.assertEquals(ProcType.ACCOUNT, pType);
    SB_NameCard_RegistProcessor proc = null;
    try {
      if (pType == ProcType.ACCOUNT) {
        // 取引先・取引先責任者用の自動連携ヘルパークラスを呼び出す
        proc = new SB_NameCard_RenkeiTriggerHelper(cards);
      }
      else if (pType == ProcType.LEAD) {
        // リード拡張パッケージの 自動連携ヘルパークラスを呼び出し
        // 取引先・取引先責任者あるいはリードを作成・更新し、キャンペーンメンバー にする。
        String lxNamespace = SB_NameCard_Util.getLeadExNamespacePrefix();
        Type extClass = Type.forName(lxNamespace, 'SB_NameCardL_RenkeiTriggerHelper');
        proc = (SB_NameCard_RegistProcessor)extClass.newInstance();
      }
      proc.run();
    }
    catch(Exception e) {
      // 2017.11.xx v1.20.3  例外メッセージを名刺の連携処理結果 項目にセットする
      setExceptionMEssage(cards, e);
      return null;
    }
    return (List<SB_NameCard_RegistCardHolder.AccountCardHolder>)proc.holders;
  }

  private static final String MSG_SEPARATOR = ' ; ';
  // 2017.11.xx v1.20.3  例外メッセージを名刺の連携処理結果 項目にセットする
  private static void setExceptionMEssage(List<NameCard__c> cards, Exception e) {
    Schema.DescribeFieldResult dfr = NameCard__c.RenkeiMessage__c.getDescribe();
    for (NameCard__c card : cards) {
      // 前に 付け足す
      card.RenkeiMessage__c = String.isNotBlank(card.RenkeiMessage__c) ? e.getMessage() + MSG_SEPARATOR + card.RenkeiMessage__c : e.getMessage();
      // 文字列が長くなってるかもしれないので切り詰める 。 画面上では切り詰められない。多分 Triggrt でも
      card.RenkeiMessage__c = card.RenkeiMessage__c.left(dfr.getLength());
    }
  }

  ///////////////////////////////
  // アカウント用の連携プロセス
  ///////////////////////////////

  public SB_NameCard_RenkeiTriggerHelper(List<NameCard__c> cards) {
    super();
    // 対象のアカウントとコンタクトのIDを収集
    this.holders = (List<SB_NameCard_RegistCardHolder.AccountCardHolder> )SB_NameCard_RenkeiTargetsPicker.createCardHolders(cards, Account.sObjectType);
  }

  // アカウントについて処理する工程
  public override void accountProc() {
    Map<Id, Account> acntId2UpdAccount = new Map<Id, Account>();
    Map<String, Account> companyId2NewAccount = new Map<String, Account>();
    SB_NameCard_DMLProcessor.AutoDmlProcessor newAcntProc = new SB_NameCard_DMLProcessor.AutoDmlProcessor(Account.sObjectType, false);
    SB_NameCard_DMLProcessor.AutoDmlProcessor updAcntProc = new SB_NameCard_DMLProcessor.AutoDmlProcessor(Account.sObjectType, false);

    Id recTypeId = getValidRecordTypeId(Account.sObjectType, setting.RenkeiAccountRecordTypes__c);

    for (SB_NameCard_RegistCardHolder.RegistCardHolder h : this.holders) {
      SB_NameCard_RegistCardHolder.AccountCardHolder holder = (SB_NameCard_RegistCardHolder.AccountCardHolder)h;
      // 2018.02.xx v1.22 SV_DEV-585 自動連携で既存取引先責任者が一意に特定できるなら取引先があいまいでも重複エラーにしない
      //  → 最初に 既存を調べて 採用する アカウント、コンタクトを決めておく
      holder.preProcess(RENKEI_USE_1ACCOUNT_CONTACT);
      //
      if (holder.isAccountTooMuch() && !holder.useExistAccount()) {
        // 既存アカウントが複数あって、どれか1つに絞れない
        holder.putMessage('[Account duplicate]');   // 2017.04.xx
        continue;
      }
      if (holder.useExistAccount()) {
        // 既存が1つか
        if (setting.RenkeiAccountOverwrite__c) {
          // 更新するとき
          Id acntId = holder.getTargetAccountId();
          if (acntId2UpdAccount.containsKey(acntId)) {
            // すでに別の名刺で更新用アカウントを作ってた。
            Account acnt = acntId2UpdAccount.get(acntId);
            holder.putAccount(acnt);
            holder.putMessage('[Account update: another]');   // 2019.05.xx SV_DEV-1684 【自動連携】設定により取引先を作成せず「未登録」となった場合の自動連携処理情報に記載される文言を変えて欲しい
            holder.acntProcess = Process.ModifyThrow;
          }
          else if (holder.isOldAccount == true) {  // PRODUCT-26 自動連携する際に、名刺交換日が最新の場合にのみ取引先・取引先責任者・リードを上書きするようなオプションがほしい
            Account acnt = holder.buildUpdAccount();
            acntId2UpdAccount.put(acnt.Id, acnt);
            updAcntProc.addCardHolder(holder);
            holder.putMessage('[Account update]');   // v2.4 2019.08.xx SV_DEV-1684 【自動連携】設定により取引先を作成せず「未登録」となった場合の自動連携処理情報に記載される文言を変えて欲しい
            holder.acntProcess = Process.Modify;
          }
          else {
            holder.acntProcess = Process.LinkOnly;
            holder.putMessage('[Account link]');
          }
        }
        else {
          // 更新せずリンクのみ
          //holder.bindExistAccount();
          holder.acntProcess = Process.LinkOnly;
          holder.putMessage('[Account link]');   // 2019.05.xx SV_DEV-1684 【自動連携】設定により取引先を作成せず「未登録」となった場合の自動連携処理情報に記載される文言を変えて欲しい
        }
      }
      else if (holder.isAccountNotExist()) {
        if (setting.RenkeiAccountNOExistCreateNew__c) {
          // 新規作成する。
          if (companyId2NewAccount.containsKey(holder.companyId)) {
            // すでに別の名刺で新規アカウントを作ってた。
            Account acnt = companyId2NewAccount.get(holder.companyId);
            holder.putAccount(acnt);
            holder.putMessage('[Account create: another]');   // 2017.09.xx
            holder.acntProcess = Process.CreateThrow;
          }
          else {
            Account acnt = holder.buildNewAccount(recTypeId, null);
            companyId2NewAccount.put(holder.companyId, acnt);
            newAcntProc.addCardHolder(holder);
            holder.putMessage('[Account create]');   // v2.4 2019.08.xx SV_DEV-1684 【自動連携】設定により取引先を作成せず「未登録」となった場合の自動連携処理情報に記載される文言を変えて欲しい
            holder.acntProcess = Process.Create;
          }
        }
        else {
          // 新規作成しない。
          holder.putMessage('[Account not create]');   // 2019.05.xx SV_DEV-1684 【自動連携】設定により取引先を作成せず「未登録」となった場合の自動連携処理情報に記載される文言を変えて欲しい
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
  public override void contactProc() {
    Map<Id, Contact> contId2UpdContact = new Map<Id, Contact>();
    Map<String, Contact> personId2NewContact = new Map<String, Contact>();
    SB_NameCard_DMLProcessor.AutoDmlProcessor newContProc = new SB_NameCard_DMLProcessor.AutoDmlProcessor(Contact.sObjectType, false);
    SB_NameCard_DMLProcessor.AutoDmlProcessor updContProc = new SB_NameCard_DMLProcessor.AutoDmlProcessor(Contact.sObjectType, false);

    Id recTypeId = getValidRecordTypeId(Contact.sObjectType, setting.RenkeiContactRecordTypes__c);

    for (SB_NameCard_RegistCardHolder.RegistCardHolder h : this.holders) {
      SB_NameCard_RegistCardHolder.AccountCardHolder holder = (SB_NameCard_RegistCardHolder.AccountCardHolder)h;
      if (holder.getAccountId()==null) {  // アカウントがない（作れなかった）
        // PRODUCT-34 自動連携処理結果の文言変更
        if (setting.RenkeiAccountNOExistCreateNew__c == false && setting.RenkeiContactNOExistCreateNew__c == true) {
          holder.putMessage('[Contact not create:no account match]');
        } else {
          holder.putMessage('[Contact not create]');
        }
        continue;
      }
      if (holder.isContactTooMuch()) {    // 既存のコンタクトが複数いる
        holder.putMessage('[Contact duplicate]');   // 2017.04.xx
        continue;
      }
      if (holder.useExistContact()) {
        // 既存が1つあったとき
        if (setting.RenkeiContactOverwrite__c) {
          Id contId = holder.getTargetContactId();
          if (contId2UpdContact.containsKey(contId)) {
            // すでに別の名刺で更新用コンタクトを作ってた。
            Contact cont = contId2UpdContact.get(contId);
            holder.putContact(cont);
            holder.putMessage('[Contact update: another]');   // 2019.05.xx SV_DEV-1684 【自動連携】設定により取引先を作成せず「未登録」となった場合の自動連携処理情報に記載される文言を変えて欲しい
            holder.contProcess = Process.ModifyThrow;
          }
          else if (holder.isOldContact == true) { // PRODUCT-26 自動連携する際に、名刺交換日が最新の場合にのみ取引先・取引先責任者・リードを上書きするようなオプションがほしい
            Contact cont = holder.buildUpdContact();
            contId2UpdContact.put(contId, cont);
            updContProc.addCardHolder(holder);
            holder.putMessage('[Contact update]');   // v2.4 2019.08.xx SV_DEV-1684 【自動連携】設定により取引先を作成せず「未登録」となった場合の自動連携処理情報に記載される文言を変えて欲しい
            holder.contProcess = Process.Modify;
          }
          else {
            holder.contProcess = Process.LinkOnly;
            holder.putMessage('[Contact link]');
          }
        }
        else {
          // 更新せずリンクのみ
          //holder.bindExistContact();
          holder.contProcess = Process.LinkOnly;
          holder.putMessage('[Contact link]');   // 2019.05.xx SV_DEV-1684 【自動連携】設定により取引先を作成せず「未登録」となった場合の自動連携処理情報に記載される文言を変えて欲しい
        }
      }
      else if (holder.isContactNotExistWithAccount()) {
        if (setting.RenkeiContactNOExistCreateNew__c) {
          // 新規作成する。
          if (personId2NewContact.containsKey(holder.personId)) {
            // すでに別の名刺で新規コンタクトを作ってた。
            Contact cont = personId2NewContact.get(holder.personId);
            holder.putContact(cont);
            holder.putMessage('[Contact create: another]');   // 2017.09.xx
            holder.contProcess = Process.CreateThrow;
          }
          else {
            Contact cont = holder.buildNewContact(recTypeId, null);
            personId2NewContact.put(holder.personId, cont);
            newContProc.addCardHolder(holder);
            holder.putMessage('[Contact create]');   // v2.4 2019.08.xx SV_DEV-1684 【自動連携】設定により取引先を作成せず「未登録」となった場合の自動連携処理情報に記載される文言を変えて欲しい
            holder.contProcess = Process.Create;
          }
        }
        else {
          // 新規作成しない。
          holder.putMessage('[Contact not create]');   // 2019.05.xx SV_DEV-1684 【自動連携】設定により取引先を作成せず「未登録」となった場合の自動連携処理情報に記載される文言を変えて欲しい
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

  // 2019.05.xx SV_DEV-893 【自動連携】1次納品段階で登録した活動履歴を取引先・取引先責任者に引き継ぎたい
  // 名刺に着いてた 活動の WhoId がNULLだったら、 コンタクト、リードのIDをセットする。
  protected override void activityProc() {
    if (!setting.RenkeiInheritEvent__c || this.cardId2ContactLeadId.isEmpty()) {
      return;
    }
    attachTask();
    attachEvent();
  }

}