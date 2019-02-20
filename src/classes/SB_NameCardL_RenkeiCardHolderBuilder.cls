/**
 *
 * SB_NameCardL_RenkeiCardHolderBuilder
 *
 *  自動連携用に 名刺レコードと登録先レコード保持 クラス を作るクラス
 *
 * Copyright (C) 2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2018.05.xx lx2.0
 *
 **/
public with sharing class SB_NameCardL_RenkeiCardHolderBuilder {

  private abstract class CardHolderBuilder {
    protected SmartViscaf__NameCardBasicSetting__c setting;
    public CardHolderBuilder() {
      this.setting = SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting();   // 基本設定
    }
    protected abstract List<SB_NameCardL_RenkeiCardHolder.RenkeiCardHolder> initCardHolder(List<SmartViscaf__NameCard__c> cards);
    public abstract List<SB_NameCardL_RenkeiCardHolder.RenkeiCardHolder> create(List<SmartViscaf__NameCard__c> cards);
  } // private abstract CardHolderBuilder {

  /////////////////
  // 基本パッケージ 自動連携 用 取引先・取引先責任者 用 Lead拡張では、テストだけ
  /////////////////
  private class AccountsCardHolderBuilder extends CardHolderBuilder {
    protected SB_NameCardL_RegistQueryStrategy.AccountContactQueryStrategy acntQst;

    public AccountsCardHolderBuilder() {
      super();
      this.acntQst = new SB_NameCardL_RegistQueryStrategy.AccountContactQueryStrategy(this.setting);
    }

    // 名刺レコードから SB_NameCardL_RenkeiCardHolder.RenkeiCardHolder を初期化、リストを作成
    protected override List<SB_NameCardL_RenkeiCardHolder.RenkeiCardHolder> initCardHolder(List<SmartViscaf__NameCard__c> cards) {
      List<SB_NameCardL_RenkeiCardHolder.AccountRenkeiHolder> result = new List<SB_NameCardL_RenkeiCardHolder.AccountRenkeiHolder>();
      for (SmartViscaf__NameCard__c card : cards) {
        result.add(new SB_NameCardL_RenkeiCardHolder.AccountRenkeiHolder(card));
      }
      return result;
    }

    // 初期霞の SB_NameCardL_RenkeiCardHolder.RenkeiCardHolder に該当する 連携候補レコード情報を装填
    public override List<SB_NameCardL_RenkeiCardHolder.RenkeiCardHolder> create(List<SmartViscaf__NameCard__c> cards) {
      List<SB_NameCardL_RenkeiCardHolder.AccountRenkeiHolder> result = (List<SB_NameCardL_RenkeiCardHolder.AccountRenkeiHolder>)initCardHolder(cards); //
      SB_NameCardL_RegistQueryExecutor qExec = SB_NameCardL_RegistQueryExecutor.getInstance();
      qExec.init(cards);
      //  アカウント、コンタクトを検索
      List<Account> acnts = (List<Account>)qExec.getCandidateRecords(this.acntQst);
      // 名刺ごとに 一致してるかチェックして、対応づける
      for (SB_NameCardL_RenkeiCardHolder.AccountRenkeiHolder ch : result) {
        SmartViscaf__NameCard__c card = ch.card;
        // Account
        for (Account acnt : acnts) {
          if (this.acntQst.isMatch(card, acnt)) {
            ch.addAccountCandidate(acnt, this.acntQst.contMatcher);
          }
        } //for (Account acnt : acnts) {
        // どういう連携をするか決定する。
        ch.preProcess();
      } // for (SB_NameCardL_RenkeiCardHolder.AccountCardHolder ch : result) {
      return result;
    }
  } // private class AccountsCardHolderBuilder extends CardHolderBuilder {

  /////////////////
  // 統合 自動連携 用
  /////////////////
  private class LeadAccountsCardHolderBuilder extends CardHolderBuilder {
    protected SB_NameCardL_RegistQueryStrategy.AccountContactQueryStrategy acntQst;
    protected SB_NameCardL_RegistQueryStrategy.LeadQueryStrategy leadQst;

    public LeadAccountsCardHolderBuilder() {
      super();
      this.acntQst = new SB_NameCardL_RegistQueryStrategy.AccountContactQueryStrategy(this.setting);
      this.leadQst = new SB_NameCardL_RegistQueryStrategy.LeadQueryStrategy(this.setting);
    }

    // 名刺レコードから SB_NameCardL_RenkeiCardHolder.RenkeiCardHolder を初期化、リストを作成
    protected override List<SB_NameCardL_RenkeiCardHolder.RenkeiCardHolder> initCardHolder(List<SmartViscaf__NameCard__c> cards) {
      List<SB_NameCardL_RenkeiCardHolder.LeadAccountRenkeiHolder> result = new List<SB_NameCardL_RenkeiCardHolder.LeadAccountRenkeiHolder>();
      for (SmartViscaf__NameCard__c card : cards) {
        result.add(new SB_NameCardL_RenkeiCardHolder.LeadAccountRenkeiHolder(card));
      }
      return result;
    }

    // 初期霞の SB_NameCardL_RenkeiCardHolder.RenkeiCardHolder に該当する 連携候補レコード情報を装填
    public override List<SB_NameCardL_RenkeiCardHolder.RenkeiCardHolder> create(List<SmartViscaf__NameCard__c> cards) {
      List<SB_NameCardL_RenkeiCardHolder.LeadAccountRenkeiHolder> result = (List<SB_NameCardL_RenkeiCardHolder.LeadAccountRenkeiHolder>)initCardHolder(cards); //
      SB_NameCardL_RegistQueryExecutor qExec = SB_NameCardL_RegistQueryExecutor.getInstance();
      qExec.init(cards);
      //  アカウント、コンタクトを検索
      List<Account> acnts = (List<Account>)qExec.getCandidateRecords(this.acntQst);
      // 　リードを検索
      List<Lead> leads = (List<Lead>)qExec.getCandidateRecords(this.leadQst);
      // 名刺ごとに 一致してるかチェックして、対応づける
      for (SB_NameCardL_RenkeiCardHolder.LeadAccountRenkeiHolder ch : result) {
        SmartViscaf__NameCard__c card = ch.card;
        // Account
        for (Account acnt : acnts) {
          if (this.acntQst.isMatch(card, acnt)) {
            ch.addAccountCandidate(acnt, this.acntQst.contMatcher);
          }
        } //for (Account acnt : acnts) {
        // Lead
        for (Lead lead : leads) {
          if (this.leadQst.isMatch(card, lead)) {
            ch.addLeadCandidate(lead);
          }
        } // for (Lead lead : leads) {
        // どういう連携をするか決定する。
        ch.preProcess();
      } // for (SB_NameCardL_RenkeiCardHolder.AccountCardHolder ch : result) {
      return result;
    }
  } // private class LeadAccountsCardHolderBuilder extends CardHolderBuilder {

  /********************************************
  * 名刺のレコードIDと既存の対象（アカウントとかコンタクト）のレコードsのリスト、
  *
  * 既存の対象レコードがない名刺もある。
  ********************************************/
  public static List<SB_NameCardL_RenkeiCardHolder.RenkeiCardHolder> createCardHolders(List<SmartViscaf__NameCard__c> cards, SB_NameCardL_RenkeiHelper.ProcType pType) {
    // CardHolderBuilder を作る
    CardHolderBuilder builder;
    if (pType == SB_NameCardL_RenkeiHelper.ProcType.ACCOUNT) {
      builder = new AccountsCardHolderBuilder();
    }
    else {
      builder = new LeadAccountsCardHolderBuilder();
    }
    // CardHolder のリストを作る
    return builder.create(cards);
  }

}