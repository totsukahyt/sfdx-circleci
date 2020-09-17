/**
 * SB_NameCard_TagAndListCollector
 *
 * SVタブ、SVカメラ でよばれる 個人タグ、リスト名 関連の処理をするクラス
 *
 *  @author sawano
 *  @Version 2.5    2020.03.xx  System.QueryException: Aggregate query does not support queryMore() なので、COUNT() のときは LIMIT 2000 にします。
 *
 * Copyright (C) 2020 SunBridge Inc. All Rights Reserved.
 **/
public with sharing class SB_NameCard_TagAndListCollector {

  // 名刺の個人タグが使用可能
  @TestVisible
  private static Boolean enableNameCardTagPersonal {
    get {
      if (enableNameCardTagPersonal == null) {
        enableNameCardTagPersonal = false;
        try {
          Schema.SObjectType targetType = Schema.getGlobalDescribe().get(SB_NameCard_Util.getNamespacePrefix_x() + 'NameCard__tag');
          Schema.SObjectField field = targetType.getDescribe().fields.getMap().get('Type');
          List<String> types = SB_NameCard_Util.getPickListEntry(field);
          for (String t : types) {
            if (t == 'Personal' || t == System.Label.SB_NC_ValPersonalTagType) {    //個人用
              enableNameCardTagPersonal = true;
              break;
            }
          }
        }
        catch(Exception e) {
          enableNameCardTagPersonal = false;
        }
      }
      return enableNameCardTagPersonal;
    }
    private set;
  }

  // private Set<String> tagNames = new Set<String>();
  public enum SortOrder {
    COUNT, NAME
  }
  private static SortOrder sortItem;
  /**
  *   タグまたはリスト名のリスト取得
  *   type  0： 個人の  1:公開の 2:両方
  *  v2.5 2020.03.xx SV_DEV-2442 SmartViscaカメラタブを開く際にロード画面から遷移しない → リスト名付き名刺が多いとSmartViscaカメラが開かないという問題があって、処理を見直してここで処理
  **/
  // 一覧を取得するときのリクエスト 条件
  public virtual class GetTagsRequest {
    @TestVisible public Integer type { get; protected set; }           // 1: タグのみ 2: リスト名のみ その他：両方
    @TestVisible public Integer tagSecurity { get; protected set; }    // 1: Personalのみ 2: publicのみ その他：両方
    @TestVisible public String excludeId { get; protected set; }       // not null ならこのID以外についてるタグを除く
    @TestVisible public Boolean mineOnly { get; private set; }       // true なら 自分所有の名刺の タグ あるいは リスト名
    private Set<String> tagNames;
    public GetTagsRequest() {
      this.type = 0;
      this.excludeId = null;
      this.tagSecurity = 1;
      this.mineOnly = false;
      this.tagNames = new Set<String>();
    }
    public GetTagsRequest(GetTagsRequest req) {
      this.type = req.type;
      this.excludeId = req.excludeId;
      this.tagSecurity = req.tagSecurity;
      this.mineOnly = req.mineOnly;
      this.tagNames = new Set<String>();
      SB_NameCard_TagAndListCollector.sortItem = SortOrder.NAME;
    }
    @TestVisible
    private GetTagsRequest(Integer type, Integer tagSecurity, String excludeId) {
      this.type = type;
      this.tagSecurity = tagSecurity;
      this.excludeId = excludeId;
      this.mineOnly = false;
      this.tagNames = new Set<String>();
    }
    public List<NameCardTagOrList> create() {
      List<NameCardTagOrList> result = new List<NameCardTagOrList>();
      // リスト名のみでなければ、タグを収集
      if (this.type != 2 && enableNameCardTagPersonal) {
        result.addAll(getTags());
      }
      // タグのみでなければ、名刺リストを収集
      if (this.type != 1) {
        result.addAll(getListNames());
      }
      if ((this.type != 1 && this.type != 2) || SB_NameCard_TagAndListCollector.sortItem != SortOrder.Name) {
        result.sort();
      }
      return result;
    }

    // タグの収集
    private List<NameCardTagOrList> getTags() {
      List<NameCardTagOrList> result = new List<NameCardTagOrList>();
      String tagType = this.tagSecurity ==1 ? 'Personal' : (this.tagSecurity ==2 ? 'Public' : null);
      Id userID = UserInfo.getUserId();
      String countQuery = 'SELECT TagDefinitionId, COUNT(Id) cnt FROM NameCard__Tag WHERE Name!= null'
              + (this.mineOnly == true ? ' AND Item.OwnerId = :userID' : '')
              + (String.isBlank(tagType) ? '' : ' AND Type=:tagType')
              + (String.isBlank(this.excludeId) ? '' : ' AND ItemId != :excludeId')
              + ' GROUP BY TagDefinitionId LIMIT 2000';
      List<AggregateResult> ars = Database.query(countQuery);
      Map<Id, Integer> tagId2Count = new Map<Id, Integer>();
      for (AggregateResult ar : ars) {
        tagId2Count.put((Id)ar.get('TagDefinitionId'), (Integer)ar.get('cnt'));
      }
      // List<Id> tagIds = new List<Id> (tagId2Count.keySet());
      // String tagids = String.join(new List<Id> (tagId2Count.keySet()), '\',\'');
      // String tagQuery = 'SELECT Id, Name, Type FROM TagDefinition WHERE Id IN (\'' + tagids + '\') ORDER BY Name ASC';
      // List<TagDefinition> tags = Database.query(tagQuery);
      Set<Id> tagdIds = new Set<Id>(tagId2Count.keySet());
      String query = 'SELECT Id, Name, Type FROM TagDefinition WHERE Id IN :tagdIds ORDER BY Name ASC';
      List<SObject> tags = Database.query(query);
      for (SObject tag : tags) {
        Integer cnt = tagId2Count.get(tag.Id);
        result.add(new NameCardTagOrList((String)tag.get('Name'), cnt, (String)tag.get('Type')));
        this.tagNames.add((String)tag.get('Name'));
      }
      return result;
    }

    // リスト名の収集
    private List<NameCardTagOrList> getListNames() {
      List<NameCardTagOrList> result = new List<NameCardTagOrList>();
      // タグにあった以外の名称のリスト名を検索
      String query = 'SELECT list_name__c name, COUNT(Id) cnt FROM NameCard__c WHERE list_name__c != null'
            + (this.mineOnly == true ? ' AND Item.OwnerId = :userID' : '')
            + (this.tagNames.isEmpty() ? '' : ' AND list_name__c NOT IN :tagNames')
            + ' GROUP BY list_name__c ORDER BY list_name__c ASC LIMIT 2000';
      List<AggregateResult> ars = Database.query(query);
      for (AggregateResult ar : ars) {
        result.add(new NameCardTagOrList(ar));
      }
      return result;
    }


  }

  // 条件に合致した タグまたはリスト名   レスポンス
  public class NameCardTagOrList implements Comparable  {
    public String label { get; private set; }
    public Boolean tagIsTag { get; private set; }       //  true: タグ false: リスト名
    public Integer tagSecurity { get; private set; }    //  1: Personal 2: public  -1：リスト名のとき
    private Integer cnt;

    public NameCardTagOrList(String tagName, Integer cnt, String tagType) {
      this.label = tagName;
      this.tagIsTag = true;
      this.tagSecurity = tagType == 'Personal' ? 1 : 2;
      this.cnt = cnt;
    }
    public NameCardTagOrList(AggregateResult ar) {
      this.label = (String)ar.get('name');
      this.tagIsTag = false;
      this.tagSecurity = -1;
      this.cnt = (Integer)ar.get('cnt');
    }
    public Integer compareTo(Object compareTo) {
      NameCardTagOrList other = (NameCardTagOrList)compareTo;
      if (SB_NameCard_TagAndListCollector.sortItem == SortOrder.COUNT) {
        return this.cnt == other.cnt ? 0 : (this.cnt > other.cnt ? 1: -1);
      }
      return this.cnt == other.cnt ? 0 : (this.cnt > other.cnt ? 1: -1);
    }
  }


  /**
   * タグ名orリスト名 と 対応する名刺配列
   **/
  public class TagdNameCards implements Comparable {
    public String tagLabel { get; private set;}
    public Boolean tagIsTag { get; private set;}        // タグの場合： TRUE、名刺リストの場合：FALSE
    public List<Map<String, Object>> cards  { get; private set; }
    public TagdNameCards(String label) {
      cards = new List<Map<String, Object>>();
      this.tagLabel = label;
      this.tagIsTag = true;
    }

    public TagdNameCards(String label, Boolean nameCardList) {      // 名刺リストの場合nameCardList = true
      cards = new List<Map<String, Object>>();
      this.tagLabel = label;
      this.tagIsTag = !nameCardList;
    }
    public void addCard(NameCard__c card) {
      cards.add(SB_NC_NameCardDTO.buildNomalizeKeyMap(card));
    }
    public void setTagIsTag(Boolean b) {
      this.tagIsTag = b;
    }
    public Integer compareTo(Object compareTo) {
      TagdNameCards other = (TagdNameCards)compareTo;
      return this.tagLabel == other.tagLabel ? 0 : (this.tagLabel > other.tagLabel ? 1: -1);
    }
  }

  private static final String STR_NameCardFieldsList = 'Id, Name, name_kana__c, person_name_last__c, person_name_first__c' +
  ', company_name__c, company_name_kana__c, division__c, title_name__c' +
  ', card_exchange_date__c, list_name__c, OwnerId, Owner.Name, Parent__c, tenshokugonomeishi__c' +
  ', image_id__c, bk_image_id__c';

  public virtual class TagdNameCardsRequest {
    // public TagdNameCardsRequest() {
    // }
    public List<TagdNameCards> create() {
      TagdNameCardsBuilder builder;
      switch on (SB_NameCard_Util.smartViscaConfig.TaggedCardsFetchMethod__c.intValue()) {
        when 0 {
          // v2.3 までの仕様の 自分の名刺だけ対象
          builder = new MyTagdNameCardsBuilder();
        }
        when 1 {
          // v2.4 仕様の みんなの名刺も対象
          builder = new OrgWideTagdNameCardsBuilder();
        }
        when else {
          // v2.5 制限に収まるようにしたもの
          builder = new LimitedTagdNameCardsBuilder();
        }
      }
      return builder.create();
    }
  }

  private interface TagdNameCardsBuilder {
    List<TagdNameCards> create();
  }

  // v2.3 と v2.4 までの仕様に対応する用の
  private virtual class AnyTagdNameCardsBuilder implements TagdNameCardsBuilder {
    protected Boolean mineOnly;
    public AnyTagdNameCardsBuilder() {
      this.mineOnly = true;
    }
    public List<TagdNameCards> create() {
      // タグの一覧を取得
      String tagQuery = 'SELECT Id, IsDeleted, ItemId, Name, Type FROM NameCard__Tag' +
        ' where Type = \'Personal\' AND IsDeleted=false AND ItemId!=null AND Name != null' +
        ' Order by CreatedDate DESC';
      // パッケージ作成環境とかで、タグがつかえないところでテストするから対策
      List<sObject> tags = enableNameCardTagPersonal ? database.query(tagQuery) : new List<sObject>();
      // List<NameCard__Tag> tags = [SELECT CreatedDate,Id,IsDeleted,ItemId,Name,SystemModstamp,TagDefinitionId,Type
                // FROM NameCard__Tag where Type = 'Personal' Order by CreatedDate DESC];
  //     if (tags.isEmpty() == true) return results; // タグなかった  2014.6.5 リスト名を対象なので、戻ってはいけない
      // 名刺レコードID と タグObjectのマップ
      Map<Id, Set<String>> id2Tags= new Map<Id, Set<String>>();
      Set<Id> ids = new Set<Id>();
      for (sObject tag :tags) {
        Id itemId = (Id)tag.get('ItemId');
        ids.add(itemId);    // 次の検索用
        Set<String> names = null;
        if (id2Tags.containsKey(itemId) == true) {
          names = id2Tags.get(itemId);
        }
        else {
          names = new Set<String>();
        }
        names.add((String)tag.get('Name'));
        id2Tags.put(itemId, names);
      }
      // タグ付きまたはリスト名付きの 名刺を探す
      // Boolean mineOnly = true;
      String condition =
          (this.mineOnly==true ? ' OwnerId = \'' + UserInfo.getUserId() + '\'' : '' );
      if (String.isBlank(condition) == false) condition += ' AND';
      condition += ' (Id IN :ids or list_name__c != null)';
      if (SB_NameCard_Util.smartViscaConfig.SIgnoreJobChanged__c == true) {  // 転職済み の名刺は表示しない
        condition += ' AND tenshokuzumi__c=false';
      }
      String orderby = ' order by card_exchange_date__c DESC NULLS LAST';
      String limits = ' limit ' +
      (this.mineOnly == true ?
        SB_NameCard_Util.smartViscaConfig.SListQueryMineLimit__c.intValue() :
        SB_NameCard_Util.smartViscaConfig.SListQueryVisibleLimit__c.intValue() );
      String queryString = 'SELECT '+ STR_NameCardFieldsList
          + ' FROM NameCard__c' +
          + (String.isBlank(condition) == false ? ' where' + condition : '')
          + orderby   // 名刺交換日
          + limits;
      System.debug('++searchNameCards SOQL : '+ queryString);
      List<NameCard__c> cards = Database.query(queryString);      // 照会実施

      // タグと名刺を関連づける。
      Map<String, TagdNameCards> label2Class = new Map<String, TagdNameCards>();
      for (NameCard__c card :cards) {
        // この名刺に付けられたタぐのコレクション
        Set<String> names = id2Tags.get(card.Id);
        Boolean bList= false;       // 今のところのタグにない 名刺リストがあったフラグ
        // 名刺 にリスト名が あれば、リスト名を追加
        if (card.list_name__c != null) {
          if (names == null)
          names = new Set<String>();
          if (names.contains(card.list_name__c) == false) { // タグにはない名刺リストの場合
            names.add(card.list_name__c);
            bList = true;       // タグにない名刺リスト があった。
          }
          id2Tags.put(card.Id, names);
        }
        if (names == null || names.isEmpty() == true) continue;     // 念のため
        for (String name : names) {
          TagdNameCards tagdList = null;
          if (label2Class.containsKey(name) == true) {
          tagdList = label2Class.get(name);
          if (bList== false)  // 名刺リストでないとき
            tagdList.setTagIsTag(true); // タグであることを上書きセット
          }
          else {
            Boolean b = bList && name == card.list_name__c; // 名刺リストのとき TRUE
            tagdList = new TagdNameCards(name, b);
          }
          tagdList.addCard(card);
          label2Class.put(name, tagdList);
        }
      }
      return label2Class.values();
    }
  }   // private virtual class AnyTagdNameCardsBuilder implements TagdNameCardsBuilder

  // v2.3までの仕様の
  private class MyTagdNameCardsBuilder extends AnyTagdNameCardsBuilder {
    public MyTagdNameCardsBuilder() {
      this.mineOnly = true;
    }
  }

  // v2.4 の仕様の
  private class OrgWideTagdNameCardsBuilder extends AnyTagdNameCardsBuilder {
    public OrgWideTagdNameCardsBuilder() {
      this.mineOnly = false;
    }
  }

  // v2.5 から
  private class LimitedTagdNameCardsBuilder implements TagdNameCardsBuilder {
    private Boolean mineOnly;
    private Boolean withListed;   // リスト名付きも混ぜる。
    private Set<String> tagNames;
    public LimitedTagdNameCardsBuilder() {
      this.mineOnly = false;
      this.withListed = true;
      this.tagNames = new Set<String>();
    }

    public List<TagdNameCards> create() {
      List<TagdNameCards> result = new List<TagdNameCards>();
      List<NameCard__c> cards = getTargetCards();
      result.addAll(getTagdNameCardsList(cards));
      if (this.withListed) {
        result.addAll(getListdNameCardsList(cards));
        result.sort();
      }
      return result;
    }

    // リスト名付きの名刺レコードをリスト名ごとにリスト
    // タグ名と同じのは除く！
    private List<TagdNameCards> getListdNameCardsList(List<NameCard__c> cards) {
      List<TagdNameCards> result = new List<TagdNameCards>();
      Map<String, TagdNameCards> listName2Class = new Map<String, TagdNameCards>();
      for (NameCard__c card : cards) {
        if (String.isBlank(card.list_name__c) || this.tagNames.contains(card.list_name__c)) {
          continue;
        }
        TagdNameCards tc;
        if (listName2Class.containsKey(card.list_name__c)) {
          tc = listName2Class.get(card.list_name__c);
        }
        else {
          tc = new TagdNameCards(card.list_name__c, true);
          listName2Class.put(card.list_name__c, tc);
          result.add(tc);
        }
        tc.addCard(card);
      }
      return result;
    }


    // タグ付けされた名刺レコードをタグ名称ごとにリスト
    private List<TagdNameCards> getTagdNameCardsList(List<NameCard__c> cards) {
      List<TagdNameCards> result = new List<TagdNameCards> ();
      if (!enableNameCardTagPersonal) {
        // 名刺個人タグ無効のとき
        return result;
      }
      Map<Id, NameCard__c> id2Card = new Map<Id, NameCard__c>(cards);
      String query = 'SELECT Name, ItemId FROM NameCard__Tag WHERE Type = \'Personal\' AND IsDeleted=false AND Name != null AND ItemId IN :cards ORDER BY Name, Item.card_exchange_date__c DESC';
      List<SObject> tags = Database.query(query);
      TagdNameCards tc;
      for (SObject tag : tags) {
        String name = (String)tag.get('Name');
        if (tc == null || !this.tagNames.contains(name)) {
          tc = new TagdNameCards(name);
          result.add(tc);
          this.tagNames.add(name);
        }
        tc.addCard(id2Card.get((Id)tag.get('ItemId')));
      }
      return result;
    }

    private List<NameCard__c> getTargetCards() {
      Id userId = UserInfo.getUserId();
      Set<Id> taggedIds = new Set<Id>();
      if (enableNameCardTagPersonal) {
        // 名刺個人タグ有効のとき
        String taggedIdQuery = 'SELECT ItemId id FROM NameCard__Tag WHERE Type = \'Personal\' AND IsDeleted=false AND ItemId!=null AND Name != null';
        if (this.mineOnly) {
          taggedIdQuery += ' AND Item.OwnerId = :userId';
        }
        taggedIdQuery += ' GROUP BY ItemId LIMIT 50000';
        List<AggregateResult> ars = Database.query(taggedIdQuery);
        for (AggregateResult ar : ars) {
          taggedIds.add((Id)ar.get('id'));
        }
      }
      List<String> conditions = new List<String>();
      if (this.mineOnly) {
        conditions.add('OwnerId = :userId');
      }
      if (this.withListed) {
        // リスト名付きも
        conditions.add('(Id IN :taggedIds OR list_name__c != null)');
      }
      else {
        // タグ付きのみ
        conditions.add('Id IN :taggedIds');
      }
      if (SB_NameCard_Util.smartViscaConfig.SIgnoreJobChanged__c == true) {  // 転職済み の名刺は表示しない
      // 転職済を除外　?
        conditions.add('tenshokuzumi__c=false');
      }
      Integer maxCount = (this.mineOnly == true ?
        SB_NameCard_Util.smartViscaConfig.SListQueryMineLimit__c.intValue() :
        SB_NameCard_Util.smartViscaConfig.SListQueryVisibleLimit__c.intValue() );
      String cardQuery = String.format('SELECT {0} FROM NameCard__c WHERE {1} ORDER BY card_exchange_date__c DESC NULLS LAST LIMIT :maxCount',
            new String[] { STR_NameCardFieldsList, String.join(conditions, ' AND ')});
      return (List<NameCard__c>)Database.query(cardQuery);
    }

  }

}