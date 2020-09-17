/**
 *
 *  SB_NameCard_RenkeiAfterInsTrigerHandler
 *   納品タイプ2でInsertされたとき、Before Insert　トリガで、アカウント、コンタクトの名刺参照項目に 名刺レコードIDがNULLとなるので、
 *    それをリカバするための After Insert で動くトリガのハンドラクラス
 *
 *
 *  Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2017.03.xx
 *    SV_DEV-384 自動連携　SmartVisca 連携マッピング　条件：「新規作成」「納品タイプ : 2」での納品時にデフォルト項目以外の項目がマッピングされない。
 *  @Version 2      2017.10.05 v1.20.2
 *    SV_DEV-627 自動連携で登録された取引先または取引先責任者の「名刺」項目の参照先が異なる。
 *  @v2.0.3  2018.10.xx リード自動連携の対応
 *
 **/
public with sharing class SB_NameCard_RenkeiAfterInsTrigerHandler {

  // 名刺基本設定とマッピングと 処理の必要性を保持するクラス
  private class RequireChecker {
    private NameCardBasicSetting__c setting;
    public Boolean isAccountRequire() { return setting.RenkeiAccountNOExistCreateNew__c && acntFields != null && !acntFields.isEmpty(); }
    public Boolean isContactRequire() { return setting.RenkeiContactNOExistCreateNew__c && contFields != null && !contFields.isEmpty(); }
    public Boolean isLeadRequire() { return setting.RenkeiLeadNOExistCreateNew__c && leadFields != null && !leadFields.isEmpty(); }    // v2.0.3
    public Boolean isRequire() {
      return isAccountRequire() || isContactRequire() || isLeadRequire();    // v2.0.3
    }

    public Set<String> acntFields { get; private set; }
    public Set<String> contFields { get; private set; }
    public Set<String> leadFields { get; private set; }   // v2.0.3
    public RequireChecker() {
      init();
    }

    private void init() {
      this.setting = SB_NameCard_BasicSetting.getNameCardBasicSetting();
      Id settingId = setting.Id;
      if (!setting.RenkeiAccountNOExistCreateNew__c && !setting.RenkeiContactNOExistCreateNew__c) {
        return;
      }
      List<NameCardRenkeiMapping__c> mappinngs = [SELECT Id, Name, NameCardName__c, TargetName__c, RecordType.Name FROM NameCardRenkeiMapping__c
                            WHERE BasicSetting__c = :settingId AND NameCardName__c='Id' AND IsActive__c = true];

      if (mappinngs.isEmpty()) {
        return;
      }
      this.acntFields = new Set<String>();
      this.contFields = new Set<String>();
      this.leadFields = new Set<String>();
      for (NameCardRenkeiMapping__c mappinng : mappinngs) {
        if (mappinng.RecordType.Name == 'Account') {
          this.acntFields.add(mappinng.TargetName__c);
        }
        else if (mappinng.RecordType.Name == 'Contact') {
          this.contFields.add(mappinng.TargetName__c);
        }
        else if (mappinng.RecordType.Name == 'Lead') {    // v2.0.3
          this.leadFields.add(mappinng.TargetName__c);
        }
      }
    }

  } // class RequireChecker

  public void onAfterInsert(NameCard__c[] newObjs) {
    Set<Id> targetIds = new Set<Id>();
    for (NameCard__c obj : newObjs) {
      if (obj.delivery_type__c == '2' && (obj.account__c != null || obj.lead__c != null)) {
        targetIds.add(obj.Id);
      }
    }

    if (!targetIds.isEmpty()) {
      RequireChecker checker = new RequireChecker();
      if (checker.isRequire()) {
        repairNameCardLinkOnAccountContactLead(targetIds);
      }
    }
  }

  //  アカウント、コンタクトを作った元になる名刺の情報を保持するクラス
  private class SourceCard {
    public NameCard__c card { get; private set; }
    public Id cardId { get; private set; }
    public DateTime dt { get; private set; }
    public Id accntId { get; private set; }
    public Id contId { get; private set; }
    public Id leadId { get; private set; }  // v2.0.3
    public SourceCard(NameCard__c card) {
      this.card = card;
      this.cardId = card.Id;
      this.dt = card.LastModifiedDate;
      this.accntId = card.account__c;
      this.contId = card.contact__c;
      this.leadId = card.lead__c;       // v2.0.3
    }
    public Boolean isSameDay(SObject dest) {
      DateTime cd = (DateTime)dest.get('CreatedDate');
      DateTime lmd = (DateTime)dest.get('LastModifiedDate');
      return dt.isSameDay(cd) && dt.isSameDay(lmd);
    }
  } // SourceCard

  // 2017.10.05 v1.20.2 SV_DEV-627 自動連携で登録された取引先または取引先責任者の「名刺」項目の参照先が異なる。
  @future
  public static void repairNameCardLinkOnAccountContactLead(Set<Id> cardIds) {
    Map<Id, NameCard__c> cards = new Map<Id, NameCard__c>([SELECT Id, Name, account__c, contact__c, lead__c, LastModifiedDate FROM NameCard__c
                                WHERE Id IN :cardIds AND (account__c != null OR contact__c != null OR lead__c != null)]);
    if (cards.isEmpty()) {
      return;
    }
    Map<Id, SourceCard> acntId2Src = new Map<Id, SourceCard>();
    Map<Id, SourceCard> contId2Src = new Map<Id, SourceCard>();
    Map<Id, SourceCard> leadId2Src = new Map<Id, SourceCard>();  // v2.0.3
    for (Id cardId : cardIds) {
      NameCard__c card = cards.get(cardId);
      if (card != null) {
        SourceCard srcCard = new SourceCard(card);
        if (card.account__c != null && !acntId2Src.containsKey(card.account__c)) {
          acntId2Src.put(card.account__c, srcCard);
        }
        if (card.contact__c != null && !contId2Src.containsKey(card.contact__c)) {
          contId2Src.put(card.contact__c, srcCard);
        }
        if (card.lead__c != null && !contId2Src.containsKey(card.lead__c)) {   // v2.0.3
          leadId2Src.put(card.lead__c, srcCard);
        }
      }
    }
    RequireChecker checker = new RequireChecker();

    if (!acntId2Src.isEmpty() && checker.isAccountRequire()) {
      // アカウントを更新
      updateAccounts(acntId2Src, checker.acntFields);
    }
    if (!contId2Src.isEmpty() && checker.isContactRequire()) {
      // コンタクトを更新
      updateContacts(contId2Src, checker.contFields);
    }
    if (!leadId2Src.isEmpty() && checker.isLeadRequire()) {
      // リードを更新
      updateLeads(leadId2Src, checker.leadFields);
    }
  }

  // アカウントを更新
  private static void updateAccounts(Map<Id, SourceCard>  id2CardId, Set<String> targetFields) {
    Set<Id> ids = new Set<Id>();
    ids.addAll(id2CardId.keySet());
    List<Account> acnts = [SELECT Id, Name, NameCard__c, CreatedDate, LastModifiedDate FROM Account WHERE Id IN :ids AND NameCard__c = null];
    List<Account> targets = new List<Account>();
    for (Account acnt : acnts) {
      SourceCard card = id2CardId.get(acnt.Id);
      if (card.isSameDay(acnt)) {
        for (String f : targetFields) {
          acnt.put(f, card.cardId);
        }
        targets.add(acnt);
      }
    }
    if (!targets.isEmpty()) {
      update targets;
    }
  }

  // コンタクトを更新
  private static void updateContacts(Map<Id, SourceCard> id2CardId, Set<String> targetFields) {
    Set<Id> ids = new Set<Id>();
    ids.addAll(id2CardId.keySet());
    List<Contact> conts = [SELECT Id, Name, NameCard__c, CreatedDate, LastModifiedDate FROM Contact WHERE Id IN :ids AND NameCard__c = null];
    List<Contact> targets = new List<Contact>();
    for (Contact cont : conts) {
      SourceCard card = id2CardId.get(cont.Id);
      if (card.isSameDay(cont)) {
        for (String f : targetFields) {
          cont.put(f, card.cardId);
        }
        targets.add(cont);
      }
    }
    if (!targets.isEmpty()) {
      update targets;
    }
  }

  // LEAD の SOQL 名前空間名を動的につけるため
  private static final String LEAD_QUERY_FORM = 'SELECT Id, Name, CreatedDate, LastModifiedDate FROM Lead WHERE Id IN :ids AND {0}NameCard__c = null';

  // コンタクトを更新
  private static void updateLeads(Map<Id, SourceCard> id2CardId, Set<String> targetFields) {
    Set<Id> ids = new Set<Id>();
    ids.addAll(id2CardId.keySet());
    String query = String.format(LEAD_QUERY_FORM, new String[] { SB_NameCard_Util.getLeadExNamespacePrefix_x() });
    List<Lead> leads = Database.query(query);
    List<Lead> targets = new List<Lead>();
    for (Lead l : leads) {
      SourceCard card = id2CardId.get(l.Id);
      if (card.isSameDay(l)) {
        for (String f : targetFields) {
          l.put(f, card.cardId);
        }
        targets.add(l);
      }
    }
    if (!targets.isEmpty()) {
      update targets;
    }
  }

}