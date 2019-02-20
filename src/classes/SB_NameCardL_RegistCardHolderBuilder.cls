/**
 * SB_NameCardL_RegistCardHolderBuilder
 *   取引先登録UI の保存時 処理用 の SB_NameCardL_RegistCardHolder を作るクラス
 *    SB_NC_RegistExecutor の改造
 *
 * Copyright (C) 2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  SB_NC_RegistExecutor
 *  @Version 1      2016.11.xx
 *  @Version 2      2017.04.xx   クラッシク版取引先登録もこちらを使うので 調整　トリガ版、UI版の統一化
 *  SB_NameCardL_RegistCardHolderBuilder
 *  @Version 1   2018.06.xx  lx2.0
 *
 **/
public with sharing class SB_NameCardL_RegistCardHolderBuilder {
  public class SB_NameCardL_RegistCardHolderBuilderException extends Exception {}
  private static final String MSG_INVALIDOBJECTID = 'Invalid {0} record Id in request.';

  private final static String NAMECARD_QUERY_FROM = 'SELECT {0} FROM SmartViscaf__NameCard__c WHERE Id IN :ids';

  private final static Set<String> requiredCardFields = new Set<String> {
    'Name',
    // 所有者
    'OwnerId',
    // 名刺交換日  2017.04.25
    'SmartViscaf__card_exchange_date__c',
    // 会社名
    'SmartViscaf__company_name__c',
    // 住所用の項目
    'SmartViscaf__address_pref__c',
    'SmartViscaf__address__c',
    'SmartViscaf__address_eng__c',
    'SmartViscaf__address_bld__c',
    // 姓名用の項目
    'SmartViscaf__person_name_last__c',
    'SmartViscaf__person_name_first__c',
    'SmartViscaf__last_name__c',
    'SmartViscaf__first_name__c',
    // 上書きしない
    'SmartViscaf__isNotOverwrite__c',
    'SmartViscaf__isNotOverContactwrite__c',
    // 参照項目
    'SmartViscaf__account__c',
    'SmartViscaf__contact__c',
    'SmartViscaf__lead__c',
    //  CardHolder で 識別用に使っている項目
    'SmartViscaf__division__c',
    'SmartViscaf__zip_code__c',
    'SmartViscaf__tel1__c',
    'SmartViscaf__tel2__c',
    'SmartViscaf__web_url1__c',
    'SmartViscaf__web_url2__c',
    'SmartViscaf__memo__c',
    'SmartViscaf__email__c'
  };

  /////////////
  // CardHolder配列を作るクラスの基底
  /////////////
  // private abstract class CardHolderBuilder {
  //   //public CardHolderBuilder() {}
  //   public abstract List<SB_NameCardL_RegistCardHolder.CardHolder> create(List<SB_NameCardL_RegistHelper.RegistTarget> targets);

  // protected abstract List<SmartViscaf.SB_NameCard_RenkeiMapper> getMappers();

  private Map<Id, SmartViscaf__NameCard__c> createNameCardMap(Set<Id> cardIds) {
    Set<Id> ids = new Set<Id>(cardIds);
    //String query = 'SELECT ';
    List<SmartViscaf.SB_NameCard_RenkeiMapper> mappers = new List<SmartViscaf.SB_NameCard_RenkeiMapper>();
    mappers.add(SmartViscaf.SB_NameCard_RenkeiMapper.getInstance(Account.sObjectType.getDescribe().getName(), false));
    mappers.add(SmartViscaf.SB_NameCard_RenkeiMapper.getInstance(Contact.sObjectType.getDescribe().getName(), false));
    mappers.add(SmartViscaf.SB_NameCard_RenkeiMapper.getInstance(Lead.sObjectType.getDescribe().getName(), false));

    Set<String> fields = new Set<String>();
    for (SmartViscaf.SB_NameCard_RenkeiMapper mapper : mappers) {
      fields.addAll(mapper.getNameCardQueryFields());
    }
    // 照会必須の項目を追加
    fields.addAll(requiredCardFields);
    // マッピングにあるけど、項目そのものでないのを削除
    fields.remove('city');
    fields.remove('street');
    fields.remove('pref_address_bld');
    fields.remove('address_bld');
    fields.remove('street_nobld');
    fields.remove('last_name');
    fields.remove('first_name');
    // クエリ文字列
    String query = String.format(NAMECARD_QUERY_FROM, new String[] { String.join(new List<String>(fields), ', ') });
    System.debug('+++createNameCardMap: ' + query);
    return new Map<Id, SmartViscaf__NameCard__c>((List<SmartViscaf__NameCard__c>)Database.query(query));
  }
  // }

  /////////////
  // 取引先登録用の CardHolder配列を作るクラス
  /////////////
  // public class RegistCardHolderBuilder extends CardHolderBuilder {
  // 名詞から マッピングをもとに対象のレコードを作る クラス たち 、必要な名詞の項目を知るため
  // private List<SmartViscaf.SB_NameCard_RenkeiMapper> mappers;

  public SB_NameCardL_RegistCardHolderBuilder() {
  }

  // protected override List<SmartViscaf.SB_NameCard_RenkeiMapper> getMappers() {
  //   return mappers;
  // }

  // 登録元名刺と 対象レコードの情報を装填
  public List<SB_NameCardL_RegistCardHolder.AccountRegistHolder> create(List<SB_NameCardL_RegistHelper.RegistTarget> targets) {
    List<SB_NameCardL_RegistCardHolder.AccountRegistHolder> result = new List<SB_NameCardL_RegistCardHolder.AccountRegistHolder>();
    Set<Id> sourceCardIds = new Set<Id>();
    Set<Id> acntIds = new Set<Id>();
    Set<Id> contIds = new Set<Id>();
    Set<Id> leadIds = new Set<Id>();
    Boolean leadProcess = false;
    for (SB_NameCardL_RegistHelper.RegistTarget t : targets) {
      sourceCardIds.add(t.cardId);
      if (t.acntId != null) {
        acntIds.add(t.acntId);
      }
      if (t.contId != null) {
        contIds.add(t.contId);
      }
      if (t.leadId != null) {
        leadIds.add(t.leadId);
      }
      if (t.pType == SB_NameCardL_RegistHelper.ProcType.LEAD || t.pType == SB_NameCardL_RegistHelper.ProcType.BOTH) {
        leadProcess = true;
      }
    }

    Map<Id, SmartViscaf__NameCard__c> cards; // 名刺レコード
    Map<Id, Account> acnts; // 既存の アカウント
    Map<Id, Contact> conts; // 既存の コンタクト
    Map<Id, Lead> leads; // 既存の 何か

    if (!sourceCardIds.isEmpty()) {
      cards = createNameCardMap(sourceCardIds);
      if (sourceCardIds.size() != cards.size()) {
        throw new SB_NameCardL_RegistCardHolderBuilderException(String.format(MSG_INVALIDOBJECTID, new String[]{SmartViscaf__NameCard__c.SObjectType.getDescribe().getLabel()}));
      }
    }

    if (!acntIds.isEmpty()) {
      acnts = new Map<Id, Account>([SELECT Id, Name, OwnerId, Owner.Name FROM Account WHERE Id IN :acntIds]);
      if (acntIds.size() != acnts.size()) {
        throw new SB_NameCardL_RegistCardHolderBuilderException(String.format(MSG_INVALIDOBJECTID, new String[]{Account.sObjectType.getDescribe().getLabel()}));
      }
    }
    if (!contIds.isEmpty()) {
      conts = new Map<Id, Contact>([SELECT Id, Name, OwnerId, Owner.Name FROM Contact WHERE Id IN :contIds]);
      if (contIds.size() != conts.size()) {
        throw new SB_NameCardL_RegistCardHolderBuilderException(String.format(MSG_INVALIDOBJECTID, new String[]{Contact.sObjectType.getDescribe().getLabel()}));
      }
    }
    if (!leadIds.isEmpty()) {
      leads = new Map<Id, Lead>([SELECT Id, Name, OwnerId, Owner.Name FROM Lead WHERE Id IN :leadIds]);
      if (leadIds.size() != leads.size()) {
        throw new SB_NameCardL_RegistCardHolderBuilderException(String.format(MSG_INVALIDOBJECTID, new String[]{Lead.sObjectType.getDescribe().getLabel()}));
      }
    }

    SB_NameCardL_RegistCardHolder.HolderBuilder holderBuilder = SB_NameCardL_RegistCardHolder.createHolderBuilder(leadProcess);

    for (Integer n = 0; n < targets.size(); n++) {
      SB_NameCardL_RegistHelper.RegistTarget t = targets.get(n);
      SmartViscaf__NameCard__c card = cards.get(t.cardId);
      // SB_NameCardL_RegistCardHolder.AccountRegistHolder holder = new SB_NameCardL_RegistCardHolder.AccountRegistHolder(card);
      SB_NameCardL_RegistCardHolder.AccountRegistHolder holder = holderBuilder.create(card);
      holder.setNumber(n);    // リストの順番
      holder.setProcType(t.pType);
      if (t.acntId != null) {
        // holder.setAccountId(t.acntId);
        holder.setTarget(acnts.get(t.acntId));
      }
      if (t.contId != null) {
        // holder.setContactId(t.contId);
        holder.setTarget(conts.get(t.contId));
      }
      // コンタクトをキャンペーンメンバーにする。
      if (t.contCampaignId != null) {
        holder.setContactCampaign(t.contCampaignId, t.contCampaignStatus);
      }
      if (t.leadId != null) {
        // holder.setContactId(t.contId);
        holder.setTarget(leads.get(t.leadId));
      }
      // リードをキャンペーンメンバーにする。
      if (t.leadCampaignId != null) {
        holder.setLeadCampaign(t.leadCampaignId, t.leadCampaignStatus);
      }
      holder.setCreateTodo(t.createTodo);
      holder.setTodoDate(t.todoDate);
      result.add(holder);
    }
    return result;
  }

  public static List<SB_NameCardL_RegistCardHolder.AccountRegistHolder> createCardHolders(List<SB_NameCardL_RegistHelper.RegistTarget> targets) {
    SB_NameCardL_RegistCardHolderBuilder builder = new SB_NameCardL_RegistCardHolderBuilder();
    return builder.create(targets);
  }

}