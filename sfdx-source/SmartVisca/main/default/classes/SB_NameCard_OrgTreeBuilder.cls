/**
 *
 *  SB_NameCard_OrgTreeBuilder
 *    S1
 *    組織情報 ボタン
 *    Lightning SB_NameCard_OrgTreeBuilderComponent
 *    とかから呼ばれる
 *
 *    ### v.1.22 以降 SB_NameCard_SController の private Class OrgTreeBuilder から 移行して こっち
 * Copyright (C) 2017-2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      v1.22
 *                  2017.11.xx
 *                  SV_DEV-412 LEXの組織情報
 *                  SV_DEV-689 組織情報に役職を加味する
 *                  2018.03.xx SV_DEV-787 組織情報の部署（所属）が意図的でない箇所で改行されるケース
 *  @Version 2      v2.4 2019.06.xx SV_DEV-1498 英語名刺の場合は、組織情報の所属を半角で階層分けしないようにしてほしい
 *
 **/
global with sharing class SB_NameCard_OrgTreeBuilder {
  public class SB_NameCard_OrgTreeBuilderException extends Exception {}

  private static final Integer MAX_NODE_RECORDS = 5000; // ツリーに表示するノードを クエリする上限

  private static final String QUERY_FROM = 'SELECT Id, Name, name_kana__c, person_name_last__c, person_name_first__c' +
      ', company_name__c, company_name_kana__c, division__c, title_name__c' +
      ', zip_code__c, address_pref__c, address__c, address_bld__c, address_eng__c' +
      ', card_exchange_date__c, list_name__c, OwnerId, Owner.Name, Parent__c, tenshokugonomeishi__c, account__c, contact__c' +
      ', freehandmemo__c, memo__c, web_url1__c, email__c, tel1__c, mobile__c, fax1__c' +
      ' FROM NameCard__c WHERE {0} ORDER BY card_exchange_date__c DESC NULLS LAST LIMIT {1}';

  private static final String QUERY_TEMPL = 'SELECT {0} FROM {1} WHERE {2} ORDER BY {3} LIMIT {4}';
  private static final String QUERY_TEMPL2 = 'SELECT {0}, ({1}) FROM {2} WHERE {3}';


  private static final String STR_NameCardFields = 'Id, Name, name_kana__c, person_name_last__c, person_name_first__c' +
  ', company_name__c, company_name_kana__c, division__c, title_name__c' +
  ', zip_code__c, address_pref__c, address__c, address_bld__c, address_eng__c' +
  ', card_exchange_date__c, list_name__c, OwnerId, Owner.Name, Parent__c, tenshokugonomeishi__c, account__c, contact__c' +
  ', freehandmemo__c, memo__c, web_url1__c, email__c, tel1__c, mobile__c, fax1__c' +
  ', image_id__c, bk_image_id__c, width__c, height__c, bk_width__c, bk_height__c';

  private static final Set<String> NAMECARD_FIELDS = new Set<String> {
    'list_name__c',
    'first_name__c',
    'person_name_last__c',
    'person_name_first__c',
    'company_name__c',
    'division__c',
    'title_name__c',
    'email__c',
    'tel1__c',
    'mobile__c',
    'fax1__c',
    'zip_code__c',
    'address_pref__c',
    'address__c',
    'address_bld__c',
    'address_eng__c'
  };

  private static final Set<String> ACCOUNT_FIELDS = new Set<String> {
    'AccountNumber',
    'Site',
    'ParentId',
    'Parent.Name',
    'Parent.Site',
    'Phone'
  };

  private static final Set<String> CONTACT_FIELDS = new Set<String> {
    'AccountId',
    'Account.Name',
    'Department',
    'Title',
    'Email',
    'Phone'
  };

  private static final Set<String> LEAD_FIELDS = new Set<String> {

  };

  private static final Map<SObjectType, Set<String>> OBJTYPE2QUERYFIELDS = new Map<SObjectType, Set<String>> {
    NameCard__c.sObjectType => NAMECARD_FIELDS,
    Account.sObjectType => ACCOUNT_FIELDS,
    Contact.sObjectType => CONTACT_FIELDS,
    Lead.sObjectType => LEAD_FIELDS
  };

  private static String getQueryFieldsString(SObjectType otype) {
    Set<String> fields = new Set<String>();
    fields.addAll(OBJTYPE2QUERYFIELDS.get(otype));
    fields.add('Id');
    fields.add('Name');
    fields.add('OwnerId');
    fields.add('Owner.Name');
    fields.add('LastModifiedDate');
    return String.join(new List<String>(fields), ', ');
  }

  private static final String FORMAT_NAMECARD_NAME_LABEL = '{0}';  // 0: 名前 1: 役職 2:所有者 3:電話番号 4:メールアドレス
  private static final String FORMAT_NAMECARD_TITLED_LABEL = '{1} {0}';  // 0: 名前 1: 役職 2:所有者 3:電話番号 4:メールアドレス
  private static final String FORMAT_NAMECARD_LABEL = '{1} {0} ({2})';  // 0: 名前 1: 役職 2:所有者 3:電話番号 4:メールアドレス
  private static final String FORMAT_ACCOUNT_LABEL = '{1} {0} ({2})';  // 0: 取引先名 1:部門 2:所有者 3:電話番号
  private static final String FORMAT_CONTACT_LABEL = '{1} {0} ({2})';  // 0: 名前 1: 役職  2:所有者 3: 部署 4:電話番号 5:メールアドレス
  private static final String FORMAT_LEAD_LABEL = '{1} {0} ({2})';  // 0: 名前 1:役職 2:所有者 3:電話番号 4:メールアドレス 5:評価
  // オブジェクトごとの ラベルの フォーマットのテーブル
  // OrgTreeItemsBuilder が インスタンス化されたとき、状況の合わせて更新する。
  private static Map<SObjectType, String> otype2LabelFormat = new Map<SObjectType, String> {
    NameCard__c.sObjectType => FORMAT_NAMECARD_LABEL,
    Account.sObjectType => FORMAT_ACCOUNT_LABEL,
    Contact.sObjectType => FORMAT_CONTACT_LABEL,
    Lead.sObjectType => FORMAT_LEAD_LABEL
  };

  private static final String namespace = SB_NameCard_Util.getNamespacePrefix_x();

  @TestVisible
  private static final String TITLE_ORDER = '会長, 社長, CEO, 副社長, COO, 専務, 常務, 事業部長, 本部長, 部長, チームマネージャ, チームマネージャー, シニアマネージャ, シニアマネージャー, 次長, マネージャ, マネージャー, 室長, グループリーダ, グループリーダー, 課長, チームリーダ, チームリーダー, 主幹, 主査, 係長, 主任, チーフ, チームサブリーダ, チームサブリーダー';
  @TestVisible
  private static final Map<String, Integer> TITLE_ORDER_MAP = new Map<String, Integer> {
    '会長' => 0,
    '社長' => 1,
    'CEO' => 2,
    '副社長' => 3,
    'COO' => 4,
    '専務' => 5,
    '常務' => 7,
    '事業部長' => 9,
    '本部長' => 11,
    '部長' => 13,
    '副部長' => 14,
    'チームマネージャ' => 15,
    'チームマネージャー' => 15,
    'シニアマネージャ' => 17,
    'シニアマネージャー' => 17,
    '次長' => 19,
    '局長' => 21,
    'マネージャ' => 23,
    'マネージャー' => 23,
    '室長' => 25,
    '副室長' => 26,
    'グループ長' => 28,
    'グループリーダ' => 30,
    'グループリーダー' => 30,
    '課長' => 32,
    '参事' => 34,
    '副課長' => 34,
    '課長補佐' => 35,
    'チームリーダ' => 37,
    'チームリーダー' => 37,
    '主幹' => 39,
    '副主幹' => 40,
    '主査' => 41,
    '副主査' => 42,
    '係長' => 43,
    '副係長' => 44,
    '主任' => 45,
    '副主任' => 46,
    'チーフ' => 47,
    'チームサブリーダ' => 49,
    'チームサブリーダー' => 49
  };

  //'長'
  //'マネージャー'
  //'マネージャ'
  //'リーダ'

// +++++++  锟組锟斤拷锟侥ワ拷锟絗锟絭锟紹 锟斤拷锟斤拷锟斤拷锟斤拷
  /**
  * 锟組锟斤拷锟侥ワ拷锟絗锟轿革拷锟轿ー锟缴わ拷示锟斤拷锟斤拷锟介ス
  *
  **/
  private static Integer counter = 0;      // ノードにIDを割り振るので、そのためのカウント

  //
  // +------ Itemの詳細データを作るよう
  // 対象のオブジェクトに合わせた、Itemの詳細データ の既定
  //
  public abstract class ItemDetail {
    public String name { get; private set; }
    public String label { get; private set; }
    public Id recordId { get; private set; }
    public String ownerName { get; private set; }
    public Id ownerId { get; private set; }
    public abstract String getTitle();
    //public Map<String, Object> values { get; private set; }
    ItemDetail() {}
    public ItemDetail(SObject obj) {
      this.name = (String)obj.get('Name');
      this.recordId = obj.Id;
      this.ownerId = (Id)obj.get('OwnerId');
      //SObject ownerUser = obj.getSObject('Owner');
      //this.ownerName = ownerUser != null ? (String)ownerUser.get('Name') : null;
    }
  }  // abstract class ItemDetail

  //
  // 名刺オブジェクトに合わせた、Itemの詳細データ
  //
  public class NameCardItemDetail extends ItemDetail {
    public String title { get; private set; }
    public String division { get; private set; }
    public override String getTitle() { return title; }
    public NameCardItemDetail(NameCard__c obj) {
      super(obj);
      this.title = String.isNotBlank(obj.title_name__c) ? obj.title_name__c : '';
      this.division = String.isNotBlank(obj.division__c) ? obj.division__c : '';
      //this.values = obj.getPopulatedFieldsAsMap();
      String labelformat = otype2LabelFormat.get(NameCard__c.sObjectType);
      this.label = String.format(labelformat, // 0: 名前 1: 役職 2:所有者 3:電話番号 4:メールアドレス
                  new String[] {this.name,
                                this.title,
                                this.ownerName,
                                String.isNotBlank(obj.tel1__c) ? obj.tel1__c : '',
                                String.isNotBlank(obj.email__c) ? obj.email__c : ''});
    }
  } // public class NameCardItemDetail extends ItemDetail

  //
  // アカウント オブジェクトに合わせた、Itemの詳細データ
  //
  public class AccountItemDetail extends ItemDetail {
    public String site { get; private set; }
    public override String getTitle() { return ''; }
    public AccountItemDetail(Account obj) {
      super(obj);
      this.site = obj.site;
      //this.values = obj.getPopulatedFieldsAsMap();
      String labelformat = otype2LabelFormat.get(Account.sObjectType);
      this.label = String.format(labelformat,// 0: 取引先名 1:部門 2:所有者 3:電話番号
                  new String[] {obj.Name,
                                obj.Site,
                                this.ownerName,
                                obj.Phone});
    }
  } // public class AccountItemDetail extends ItemDetail

  //
  // コンタクト オブジェクトに合わせた、Itemの詳細データ
  //
  public class ContactItemDetail extends ItemDetail {
    public String title { get; private set; }
    public String department { get; private set; }
    public override String getTitle() { return title; }
    public ContactItemDetail(Contact obj) {
      super(obj);
      this.title = obj.Title;
      this.department = obj.Department;
      //this.values = obj.getPopulatedFieldsAsMap();
      String labelformat = otype2LabelFormat.get(Contact.sObjectType);
      this.label = String.format(labelformat, // 0: 名前 1: 役職  2:所有者 3: 部署 4:電話番号 5:メールアドレス
                  new String[] {obj.Name,
                                obj.Title,
                                this.ownerName,
                                obj.Department,
                                obj.Phone,
                                obj.EMail});
    }
  } // public class ContactItemDetail extends ItemDetail

  //
  // リード オブジェクトに合わせた、Itemの詳細データ
  //
  public class LeadItemDetail extends ItemDetail {
    public String title { get; private set; }
    //public String department { get; private set; }
    public override String getTitle() { return title; }
    public LeadItemDetail(Lead obj) {
      //this.title = obj.Title;
      //this.department = obj.Department;
      //this.values = obj.getPopulatedFieldsAsMap();
      String labelformat = otype2LabelFormat.get(Lead.sObjectType);
    }
  } // public class LeadItemDetail extends ItemDetail

  // 対象のオブジェクトに合わせて、Itemの詳細データを作る
  private static ItemDetail cretaItemDetail(SObject obj) {
    ItemDetail result = null;
    if (obj.getSObjectType() == NameCard__c.sObjectType) {
      result = new NameCardItemDetail((NameCard__c)obj);
    }
    else if (obj.getSObjectType() == Account.sObjectType) {
      result = new AccountItemDetail((Account)obj);
    }
    else if (obj.getSObjectType() == Contact.sObjectType) {
      result = new ContactItemDetail((Contact)obj);
    }
    else if (obj.getSObjectType() == Lead.sObjectType) {
      result = new LeadItemDetail((Lead)obj);
    }
    return result;
  }
  // +------ Itemの詳細データを作るよう

  // 組織階層のノード あるいは、終端の名刺
  global virtual class Item implements Comparable {
    @AuraEnabled public String label { get; set; } //  Required. The title and label for the hyperlink.
    @AuraEnabled public Integer titleOrder { get; private set; } // 役職の順位 // v1.22
    public String getTitle() { return this.info.getTitle(); }
    public ItemDetail info { get; private set; }
    @AuraEnabled public String name { get; private set; }  // The unique name for the item for the onselect event handler to return the tree item that was clicked.
    @AuraEnabled public String nodeId { get; private set; }  //
    @AuraEnabled public Boolean disabled { get; private set; }  // Specifies whether a branch is disabled. A disabled branch can't be expanded. The default is false.
    @AuraEnabled public Boolean expanded { get; private set; } // Specifies whether a branch is expanded. An expanded branch displays its nested items visually. The default is false.
    @AuraEnabled public String href { get; private set; } // The URL of the link.
    @AuraEnabled public List<Item> items { get; private set; } //

    @AuraEnabled public Boolean selected { get; private set; }  //
    @AuraEnabled public Boolean mine { get; private set; }  //
    private Map<String, Item> mapItems;
    //public Item() {
    //  this.items = new List<Item>();
    //  this.mapItems = new Map<String, Item>();
    //  this.selected = false;
    //  this.mine = false;
    //  this.disabled = false;
    //  this.expanded = true;
    //}
    public Item() {}
    // 部署ノードを作る
    public Item(String name) {
      this.items = new List<Item>();
      this.mapItems = new Map<String, Item>();
      this.label = name;
      this.nodeId = 'N' + String.valueOf(counter);
      counter++;
      this.selected = false;
      this.mine = false;
      this.disabled = false;
      this.expanded = true;
      this.href = '#';    // 2019.05.xx v2.4 SV_DEV-1629 組織図の中で名刺を目立たせる
    }
    // 終端のノードを作る
    public Item(SObject obj, Boolean selected) {
      this.info = cretaItemDetail(obj);
      this.label = info.label;               // 表示する 文字列
      this.name = JSON.serialize(this.info);
      //this.ownerName = card.Owner.Name;       // 所有者
      this.nodeId = info.recordId;
      this.selected = selected;
      this.mine = (info.ownerId == UserInfo.getUserId());         // 自分所有？
      this.disabled = false;
      this.expanded = false;
    }

    // 終端のノードを作る
    public Item(Integer titleOrder, SObject obj, Boolean selected) {
      this.info = cretaItemDetail(obj);
      this.label = info.label;               // 表示する 文字列
      this.name = JSON.serialize(this.info);
      //this.ownerName = card.Owner.Name;       // 所有者
      this.nodeId = info.recordId;
      this.selected = selected;
      this.mine = (info.ownerId == UserInfo.getUserId());         // 自分所有？
      this.disabled = false;
      this.expanded = false;
      this.titleOrder = titleOrder;   // v1.22
      System.debug(this.label + ': ' + titleOrder);
    }

    // ソートする
    public Integer compareTo(Object compareTo) {
      if (this.titleOrder == null && ((Item)compareTo).titleOrder == null) {
        // 部署をソート
        return this.label.compareTo(((Item)compareTo).label);
      }
      //　部署配下では部署より人を先にする
      else if (this.titleOrder == null && ((Item)compareTo).titleOrder != null) {
        return 1;
      }
      else if (this.titleOrder != null && ((Item)compareTo).titleOrder == null) {
        return -1;
      }
      // 役職の順位でソート
      else if (this.titleOrder == null || this.titleOrder < ((Item)compareTo).titleOrder) {
        return -1;
      }
      else if (this.titleOrder == ((Item)compareTo).titleOrder) {
        // 役職順位が同じ
        if (this.getTitle() == ((Item)compareTo).getTitle()) {
          // 同じ役職名
          return this.info.name.compareTo(((Item)compareTo).info.name);
        }
        else {
          // 役職名でソート
          return this.getTitle().compareTo(((Item)compareTo).getTitle());
        }
      }
      return 1;
    }

    // 役職の順位ぎめ
    private Integer getTitleOrder(String title) {
      if (String.isBlank(title)) {
        // 役職はない
        return 999;
      }
      else if (TITLE_ORDER_MAP.containsKey(title)) {
        return TITLE_ORDER_MAP.get(title);
      }
      for (String t : TITLE_ORDER_MAP.keySet()) {
        if (title.startsWith('副') && title.endsWith(t)) {
          return TITLE_ORDER_MAP.get(t)+1;
        }
        if (title.endsWith(t)) {
          return TITLE_ORDER_MAP.get(t);
        }
        if (title.endsWith(t+'代理')) {
          return TITLE_ORDER_MAP.get(t)+1;
        }
      }
      if (title.startsWith('副')) {
        // その他の 副 で始まる役職
        return TITLE_ORDER_MAP.size()+1;
      }
      if (title.endsWith('長')) {
        // その他の 長 で終わる役職
        return TITLE_ORDER_MAP.size();
      }
      if (title.endsWith('代理')) {
        // その他の 代理 で終わる役職
        return TITLE_ORDER_MAP.size()+1;
      }
      // 役職はあるにはある
      return 990;
    }

    private void addOrderedItem(String title, SObject obj, Boolean selected) {
      Item c = new Item(getTitleOrder(title), obj, selected);
      this.items.add(c);
      // ソート
      //if (!this.Items.isEmpty()) {
      //  this.items.sort();
      //}
    }

    public void addItem(List<String> divisions, String title, SObject obj, Boolean selected) {
      if (divisions == null || divisions.isEmpty() == true) {
        // 終端のノード = 名刺
        //Item c = new Item(obj, selected);
        //this.items.add(c);
        addOrderedItem(title, obj, selected);
      }
      else {
        //System.debug(divisions[0]);
        // 途中ののーど = 部署
        // このレベルの部署名をリストから削除
        List<String> subDiv = new List<String>();
        for (Integer n =1; n<divisions.size(); n++) {
          subDiv.add(divisions[n]);
        }
        // このレベルの部署名のノードに子ノードを追加
        Item sub = null;
        if(this.mapItems.containsKey(divisions[0]) == true) {
          sub = this.mapItems.get(divisions[0]);
        }
        else {
          sub = new Item(divisions[0]);
          this.items.add(sub);      // 子ノードをリストに追加
        }
        sub.addItem(subDiv, title, obj, selected);  //
        this.mapItems.put(divisions[0], sub);
      }
    }

    public void finalize() {
      if (Limits.getCpuTime() > Limits.getLimitCpuTime()-1000) {
        System.debug(LoggingLevel.DEBUG, String.format('Cpu Time Limit Over. Max:{0} now:{1}', new String[]{Limits.getLimitCpuTime().format(),  Limits.getCpuTime().format()}));
        return;       // 途中でやめます。
      }
      if (this.items != null && !this.items.isEmpty()) {
        this.items.sort();
        for (Item i : this.items) {
          i.finalize();
        }
      }
    }
    //public void addItem(List<String> divisions, NameCard__c card, String cardId) {
    //  if (divisions == null || divisions.isEmpty() == true) {
    //    // 終端のノード = 名刺
    //    Item c = new Item(card, card.Id == cardId);
    //    this.items.add(c);
    //  }
    //  else {
    //    // 途中ののーど = 部署
    //    // このレベルの部署名をリストから削除
    //    List<String> subDiv = new List<String>();
    //    for (Integer n =1; n<divisions.size(); n++) {
    //      subDiv.add(divisions[n]);
    //    }
    //    // このレベルの部署名のノードに子ノードを追加
    //    Item sub = null;
    //    if(this.mapItems.containsKey(divisions[0]) == true) {
    //      sub = this.mapItems.get(divisions[0]);
    //    }
    //    else {
    //      sub = new Item(divisions[0]);
    //      this.items.add(sub);      // 子ノードをリストに追加
    //    }
    //    sub.addItem(subDiv, card, cardId);  //
    //    this.mapItems.put(divisions[0], sub);
    //  }
    //}
  } // class Item

  // 部署名を階層に分割して返す。ブランクで区切る
/*  public static List<String> getDivisionNodes(String division) {
    List<String> results = new List<String>();
    if (String.isEmpty(division) == true) return null;
    return division.split('[,\\s]');
    }*/

  // 部署名を階層に分割して返す。
  // Label.SB_NC_DivisionRegex ='\\b.+社長*|事業部長*|本部長*|部門長*|部長*|室長*|課長*|係長*|グループ長*|\\s|　\\b';
  public static List<String> getDivisionNodes(String division) {
    System.assert(String.isNotBlank(division));
    List<String> results = new List<String>();
    if (SB_NameCard_Util.smartViscaConfig.OrgTreeUseRegex__c) {
      // 組織情報を作るとき正規表現（カスタム表示ラベルのSB_NC_DivisionRegex）を使う
      Pattern p = Pattern.compile(Label.SB_NC_DivisionRegex);
      Matcher m = p.matcher(division);
      Integer s =0;
      while(m.find()){ // 検索(find)し、マッチする部分文字列がある限り繰り返す
        for (Integer j = 0; j <= m.groupCount(); j++) {
          //                  System.debug(m.group(j)+ ', ('+m.start(j)+'-'+m.end(j)+')');  指定した文字列 とその開始位置、終了位置
          String div = division.substring(s, m.end(j));
          if (String.isBlank(div) == false)
          results.add(div.trim()); // 全部トリムしないと最上位の部署のみの名刺とその配下の部署が存在し、
          s = m.end(j);
        }
      }
      if (division.length() > s) {
        results.add(division.substring(s).trim());
      }
    }
    else if (division.isAsciiPrintable()) {
      // v2.4 2019.06.xx SV_DEV-1498 英語名刺の場合は、組織情報の所属を半角で階層分けしないようにしてほしい
      // 実際には ASCIIプリンタブル文字のみだったら 半角英数字のみとか
      results.add(division);
    }
    else {
      // SV_DEV-787 組織情報の部署（所属）が意図的でない箇所で改行されるケース
      String[] ss = division.split('\\s');
      for (Integer n=0; n < ss.size(); n++) {
        if (ss[n] == '兼' && n < ss.size() -1) {
          results.add(ss[n]+ ' ' + ss[n+1]);
          n++;
        }
        else {
          results.add(ss[n]);
        }
      }
    }
    return results;
  }


  ///**
  //*
  //* 锟組锟斤拷锟侥ワ拷锟絗锟斤拷锟斤拷锟诫ク锟介ス
  //*
  //**/
  //private Class OrgTreeBuilder {
  //  private Item rootItem = null;

  //  public Item getRootItem() { return this.rootItem; }

  //  public void run(String cardId, Boolean mineOnly) {
  //    List<NameCard__c> targetCard = [select Id, company_name__c from NameCard__c where Id = :cardId];
  //    if (targetCard.isEmpty() == true || targetCard[0].company_name__c==null) return;
  //    // ルートノードのインスタンス化
  //    rootItem = new Item(targetCard[0].company_name__c);
  //    List<NameCard__c> cards = getNameCardsInCompany(targetCard[0].company_name__c, mineOnly);
  //    for (NameCard__c card :cards) {
  //      String[] divisions = null;
  //      if (String.isBlank(card.division__c) == false) {
  //        // 部署名の分割した要素の取得
  //        divisions = getDivisionNodes(card.division__c);
  //      }
  //      // ルートノードに名刺を追加
  //      rootItem.addItem(divisions, card, cardId);
  //    }
  //  }

  //  //指定の会社名の
  //  private List<NameCard__c> getNameCardsInCompany(String company, Boolean mineOnly) {
  //    String condition =
  //      // 自分の名刺だけ  ||  最新の名刺だけ
  //      (mineOnly == true ? 'OwnerId = \'' + UserInfo.getUserId() + '\' and ' : '') +
  //      + 'Parent__c=null and company_name__c = \'' + company + '\'';   // 最新の名刺 and 指定の会社のもの

  //    String queryString =
  //      'SELECT ' + STR_NameCardFields + ' from NameCard__c' +
  //      (String.isBlank(condition) == false ? ' where ' + condition : '') +
  //        ' order by' +
  //        ' card_exchange_date__c DESC NULLS LAST' +        // 名刺交換日
  //        ' limit ' +
  //      SB_NameCard_Util.smartViscaConfig.SMAXOrgTreeNameCards__c.format();
  //    System.debug('++getNameCardsInCompany : '+ queryString);
  //    // Run and return the query results
  //    System.debug('++getNameCardsInCompany SOQL : '+ queryString);
  //    return(database.Query(queryString));
  //  }


  //}

  //
  // +------ 組織ツリー の Itemリストをつくる用
  // 組織ツリー の Itemリストをつくるクラスの基底
  //
  private abstract class OrgTreeItemsBuilder {
    protected Id targetId;          // 対象のレコードID
    protected Boolean mineOnly;     // 自分所有のものだけ
    protected Boolean rootOff;
    protected Integer maxRecs;      // 対象のレコード上限
    protected String queryLimit;
    protected List<Item> items;     // ツリーのノード
    public List<Item> getItems() { return items; }
    public OrgTreeItemsBuilder() {
      this.items = new List<Item>();
      this.mineOnly = false;
      this.rootOff = false;
      this.maxRecs = Math.min(SB_NameCard_Util.smartViscaConfig.SMAXOrgTreeNameCards__c.intValue(), MAX_NODE_RECORDS);
      //this.queryLimit = String.valueOf(this.maxRecs);
      setupLabelFormat(SB_NameCard_Util.smartViscaConfig.SOrgTreeShowTitle__c);
    }
    public OrgTreeItemsBuilder(Id targetId, Boolean mineOnly, Boolean rootOff) {
      this.items = new List<Item>();
      this.targetId = targetId;
      this.mineOnly = mineOnly;
      this.rootOff = rootOff;
      this.maxRecs = Math.min(SB_NameCard_Util.smartViscaConfig.SMAXOrgTreeNameCards__c.intValue(), MAX_NODE_RECORDS);
      //this.queryLimit = String.valueOf(this.maxRecs);
      setupLabelFormat(SB_NameCard_Util.smartViscaConfig.SOrgTreeShowTitle__c);
    }
    // 役所を表示するフォーマット
    //　クエリリミット の更新
    // Lightning アプリケーションビルダでの指定をこれで反映
    public void reset(Boolean showTitle, Integer maxRecs) {
      setupLabelFormat(showTitle);
      this.maxRecs = Math.min(maxRecs, MAX_NODE_RECORDS);    //
    }
    public abstract List<Item> create();
    // ノードの文字列フォーマットの設定
    //protected virtual void setupLabelFormat() {}
    protected virtual void setupLabelFormat(Boolean showTitle) {}
  } // class OrgTreeItemsBuilder

  //
  // 名刺について 組織ツリー の Item をつくる
  //
  private class NameCardOrgTreeItemsBuilder extends OrgTreeItemsBuilder {
    public NameCardOrgTreeItemsBuilder(Id targetId, Boolean mineOnly, Boolean rootOff) {
      super(targetId, mineOnly, rootOff);
    }

    // ツリー ノードのリストを作成
    public override List<Item> create() {
      Id cardId = this.targetId;
      List<NameCard__c> targetCard = [select Id, company_name__c from NameCard__c where Id = :cardId];
      if (targetCard.isEmpty() == true) {
        throw new SB_NameCard_OrgTreeBuilderException('Invalid Record Id');
      }
      if (String.isBlank(targetCard[0].company_name__c)) {
        throw new SB_NameCard_OrgTreeBuilderException('no company name');
      }
      // ルートノードのインスタンス化
      Item rootItem = new Item(targetCard[0].company_name__c);
      this.items.add(rootItem);
      List<NameCard__c> cards = getNameCardsInCompany(targetCard[0].company_name__c, this.mineOnly);
      for (NameCard__c card :cards) {
        String[] divisions = null;
        if (String.isNotBlank(card.division__c)) {
          // 部署名の分割した要素の取得
          divisions = getDivisionNodes(card.division__c);
        }
        // ルートノードに名刺を追加
        rootItem.addItem(divisions, card.title_name__c, card, card.id == cardId);
      }
      rootItem.finalize();
      return this.items;
    }

    // ノードの文字列フォーマットの設定
    //protected override void setupLabelFormat() {
    //  if (SB_NameCard_Util.smartViscaConfig.SOrgTreeShowTitle__c) {
    //    // 役職を表示する。
    //    otype2LabelFormat.put(NameCard__c.sObjectType, FORMAT_NAMECARD_TITLED_LABEL);
    //  }
    //  else {
    //    // 役職は表示しない。初期仕様
    //    otype2LabelFormat.put(NameCard__c.sObjectType, FORMAT_NAMECARD_NAME_LABEL);
    //  }
    //}

    // ノードの文字列フォーマットの設定
    protected override void setupLabelFormat(Boolean showTitle) {
      if (showTitle) {
        // 役職を表示する。
        otype2LabelFormat.put(NameCard__c.sObjectType, FORMAT_NAMECARD_TITLED_LABEL);
      }
      else {
        // 役職は表示しない。初期仕様
        otype2LabelFormat.put(NameCard__c.sObjectType, FORMAT_NAMECARD_NAME_LABEL);
      }
    }


    private List<NameCard__c> getNameCardsInCompany(String company, Boolean mineOnly) {
      // 検索受験
      String condition =
        // 自分の名刺だけ  ||  最新の名刺だけ
        (this.mineOnly == true ? 'OwnerId = \'' + UserInfo.getUserId() + '\' and ' : '') +
        + 'Parent__c=null AND company_name__c=:company';   // 最新の名刺 and 指定の会社のもの
      //System.debug('format(): ' + Integer.valueOf(this.maxRecs));
      //System.debug('String.valueOf(this.maxRecs): ' + this.maxRecs);
      //Object o = this.maxRecs;
      //String queryLimit ;
      //if (o instanceof String) {
      //  queryLimit = (String)o;
      //} else if (o instanceof Integer) {
      // queryLimit = String.valueOf(this.maxRecs);
      //}
      String query = String.format(QUERY_TEMPL, new String[]{
                  getQueryFieldsString(NameCard__c.sObjectType),   // 項目
                  'NameCard__c',
                  condition,
                  'card_exchange_date__c DESC NULLS LAST',          // 名刺交換日でソート
                  String.valueOf(this.maxRecs)});
      System.debug('++getNameCardsInCompany SOQL : '+ query);
      return(database.Query(query));
    }

  } // private class NameCardOrgTreeItemsBuilder extends OrgTreeItemsBuilder

  private static final String QUERY_ACCOUNT = 'SELECT Id,Name, Parent.Id, Parent.Parent.Id, Parent.Parent.Parent.Id, Parent.Parent.Parent.Parent.Id, Parent.Parent.Parent.Parent.Parent.Id FROM Account WHERE Id=:targetId';
  private static final String QUERY_CONTACT = 'SELECT Id,Name, Account.Id, Account.Parent.Id, Account.Parent.Parent.Id, Account.Parent.Parent.Parent.Id, Account.Parent.Parent.Parent.Parent.Id FROM Contact WHERE Id=:targetId';

  //private static final String QUERY_CHILD = 'SELECT Id, Name, Site FROM '
  private static final String QUERY_BRACHES = 'SELECT Id, Name, Site, Parent.Id, Parent.Parent.Id, Parent.Parent.Parent.Id, Parent.Parent.Parent.Parent.Id, Parent.Parent.Parent.Parent.Parent.Id FROM Account' +
        ' WHERE Id=:rootAccountId AND Parent.Id=:rootAccountId AND Parent.Parent.Id=:rootAccountId AND Parent.Parent.Parent.Id=:rootAccountId AND Parent.Parent.Parent.Parent.Id=:rootAccountId AND Parent.Parent.Parent.Parent.Parent.Id=:rootAccountId';
  private static final String QUERY_ALLCONTACTS = 'SELECT Id,Name, Account.Id, Account.Parent.Id, Account.Parent.Parent.Id, Account.Parent.Parent.Parent.Id, Account.Parent.Parent.Parent.Parent.Id FROM Contact WHERE Id=:acntMap.keySet()';

  //
  // アカウント OR コンタクト について 組織ツリー の Item をつくる
  //
  private class AccountOrgTreeItemsBuilder extends OrgTreeItemsBuilder {
    private Id rootAccountId;
    private SObjectType otype;
    private Map<Id, AccountItem> acntMap;
    public AccountOrgTreeItemsBuilder(Id targetId, Boolean mineOnly, Boolean rootOff) {
      super(targetId, mineOnly, rootOff);
      this.otype = targetId.getSObjectType();
    }
    public override List<Item> create() {
      //  最上位の アカウント ID を得る
      resolveRoot();
      //
      return this.items;
    }

    //  最上位の アカウント ID を得る
    private void resolveRoot() {
      // ルートのアカウントを求める
      if (this.otype == Account.sObjectType) {
        resolveRootFromAccount(this.targetId);
      }
      else {
        resolveRootFromContact(this.targetId);
      }
      // ルートからの全てのアカウントを得る。
      resolveBranchAccount();
      // 各アカウントのコンタクトを収集
      resolveAllContacts();
    }

    private void resolveAllContacts() {
      Set<Id> ids = new Set<Id>(acntMap.keySet());
      String query = String.format(QUERY_TEMPL, new String[]{
                  getQueryFieldsString(Contact.sObjectType),   // 項目
                  'Contact',
                  'AccountId IN :ids',
                  'AccountId DESC NULLS LAST',          // でソート
                  SB_NameCard_Util.smartViscaConfig.SMAXOrgTreeNameCards__c.format()});
      System.debug('++getContactInAccount SOQL : '+ query);
      List<Contact> conts = Database.query(query);
      for (Contact cont : conts) {

      }
    }

    private void resolveRootFromAccount(Id targetId) {
      List<Account> acnts = Database.query(QUERY_ACCOUNT);
      SObject obj = acnts.get(0);
      this.rootAccountId = obj.Id;
      do {
        obj = obj.getSObject('Parent');
        if (obj != null) {
          this.rootAccountId = obj.Id;
        }
      } while(obj != null);
    }

    private void resolveRootFromContact(Id targetId) {
      List<Contact> conts = Database.query(QUERY_CONTACT);
      SObject obj = conts.get(0);
      obj = obj.getSObject('Account');
      for (; obj!=null; obj = obj.getSObject('Parent')) {
        this.rootAccountId = obj.Id;
      }
    }
    // ブランチのアカウントを得る
    private void resolveBranchAccount() {
      List<Account> acnts = Database.query(QUERY_BRACHES);
      this.acntMap = new Map<Id, AccountItem>();
      for (Account acnt : acnts) {
        this.acntMap.put(acnt.Id, new AccountItem(acnt));
      }
      for (Account acnt : acnts) {
        if (acnt.Parent.Id != null &&
            acnt.Parent.Parent.Id == null &&
            acnt.Parent.Parent.Parent.Id == null &&
            acnt.Parent.Parent.Parent.Parent.Id == null &&
            acnt.Parent.Parent.Parent.Parent.Parent.Id == null) {
          // 親が1つのアカウント
          AccountItem parent = this.acntMap.get(acnt.Parent.Id);
          AccountItem branch = this.acntMap.get(acnt.Id);
          parent.addBranch(branch);
        }
      }
    }

  } // private class AccountOrgTreeItemsBuilder extends OrgTreeItemsBuilder

  private  class AccountItem {
    public Account acnt { get; private set; }
    public List<AccountItem> branchs { get; private set; }
    public Set<Id> accountIds { get; private set; }
    public AccountItem(Account acnt) {
      this.acnt = acnt;
    }
    public void addBranch(AccountItem branch) {
      branchs.add(branch);
    }
  }

  //
  // リード について 組織ツリー の Item をつくる
  //
  private class LeadOrgTreeItemsBuilder extends OrgTreeItemsBuilder {
    public LeadOrgTreeItemsBuilder(Id targetId, Boolean mineOnly, Boolean rootOff) {
      super(targetId, mineOnly, rootOff);
    }
    public override List<Item> create() {
      //Account
      return this.items;
    }
  } // private class LeadOrgTreeItemsBuilder extends OrgTreeItemsBuilder

  // 対象のレコードIDから ツリー ITEM を作るクラスを インスタンス化して返す
  private static OrgTreeItemsBuilder getOrgTreeItemsBuilder(Id targetId, Boolean mineOnly, Boolean rootOff) {
    OrgTreeItemsBuilder result = null;
    SObjectType otype = targetId.getSObjectType();
    if (otype == NameCard__c.sObjectType) {
      result = new NameCardOrgTreeItemsBuilder(targetId, mineOnly, rootOff);
    }
    else if (otype == Account.sObjectType || otype == Contact.sObjectType ) {
      result = new AccountOrgTreeItemsBuilder(targetId, mineOnly, rootOff);
    }
    else if (otype == Lead.sObjectType) {
      result = new LeadOrgTreeItemsBuilder(targetId, mineOnly, rootOff);
    }
    return result;
  }

  /**
  *  同一組織の名刺、アカウント・コンタクト、リード の階層表現の取得
  *   mineOnly
  **/
  //public static List<Item> getOrgTreeItems(String cardId, Boolean mineOnly) {
  //  OrgTreeBuilder builder = new OrgTreeBuilder();
  //  builder.run(cardId, mineOnly);
  //  List<Item> results = new List<Item>();
  //  results.add(builder.getRootItem());
  //  return results;
  //}
  // ツリーノードのリストを返す
  public static List<Item> getOrgTreeItems(String targetId, Boolean mineOnly) {
    OrgTreeItemsBuilder builder = getOrgTreeItemsBuilder(targetId, mineOnly, false);
    return builder.create();
  }

  // ツリーノードのリストを返す Lightning アプリケーションビルダで設定した パラメータ があるとき
  public static List<Item> getOrgTreeItems(String targetId, Boolean showTitle, Integer maxRecs) {
    OrgTreeItemsBuilder builder = getOrgTreeItemsBuilder(targetId, false, false);
    builder.reset(showTitle, maxRecs);
    return builder.create();
  }

}