/**
 *  SB_NC_CardOwnersBuilder
 *  同じ人の名刺を持つユーザ Lightning Web Component の処理の実態
 *
 *  @author sawano
 *  @Version1 v2.4 2019.06.xx SV_DEV-1593 LEX画面の名刺詳細から「同じ名刺を持つユーザ」を確認できるようにしてほしい
 *  @Version2 v2.5 2020.02.xx SV_DEV-2220 「同じ名刺を持つユーザ」で表示されるユーザの画像が拡大して表示されていない → ConnectApi を使います。
 *
 **/
public with sharing class SB_NC_CardOwnersBuilder {
  private Id cardId;      // 対象の名刺
  private Boolean excludeMe;    // 自分を除外する
  private Boolean includeCurrentOwner;  // このレコード所有者を含める
  private String titleFields;  // 所属役所の表示項目
  private String fields;        // ユーザの表示項目
  private Boolean traceChangeJob; // 転職前後の名刺も含める
  private Boolean showExchangeDate; // 名刺交換日を表示する
  private Boolean includeInactiveUser;  // 無効なユーザも含める
  private String sortField; // 並び順(初期値)
  private Boolean sortAsc;   // 昇順
  //
  private static TitileFormatter titleFormatter;
  @TestVisible private static void createTitileFormatter(String titleFields) {
    titleFormatter = new JoinSpaceTitleFormatter(User.sObjectType, titleFields);
  }
  //
  private static ItemListCreater itemListCreater;
  @TestVisible private static void createItemListCreator(String fields) {
    itemListCreater = new ItemListCreater(fields);
  }

  private static TitileFormatter cardLabelFormatter {
    get {
      if (cardLabelFormatter == null) {
        String nsx = SB_NameCard_Util.getNamespacePrefix_x();
        String fields = 'Name,' + nsx + 'company_name__c,' + nsx + 'division__c,' +  nsx + 'title_name__c';
        cardLabelFormatter = new JoinSpaceTitleFormatter(NameCard__c.sObjectType, fields);
      }
      return cardLabelFormatter;
    }
    private set;
  }

  // クエリするユーザの項目
  private static final Set<String> USER_FIELDS = new Set<String> {
    'id',
    'name',
    'companyname',
    'country',
    'department',
    'title',
    'email',
    'phone',
    'fax',
    'mobilephone',
    'employeenumber'};

  private static final String NAMECARD_QUERY = 'SELECT Id, Name, OwnerId, Parent__c, tenshokugonomeishi__c, card_exchange_date__c, company_name__c, division__c, title_name__c FROM NameCard__c WHERE {0} ORDER BY OwnerId, card_exchange_date__c {1} NULLS FIRST';
  private static final String USER_QUERY = 'SELECT {0} FROM User WHERE Id in :ownerIds {1} {2}';

  private static final String ORDER_DEPT = 'ORDER BY CompanyName {0} NULLS LAST, Department {0} NULLS LAST';
  private static final String ORDER_NAME = 'ORDER BY Name {0}';

  // 対象が最新名刺だったときの WHERE 句 自分が最新の名刺
  private static final String NC_WHERE_LATEST = '(Name=:name AND email__c=:email) OR Parent__c = :cardId OR Id = :cardId';
  // 対象が最新名刺でないときの WHERE 句　→ 最新と 同じのが最新の名刺
  private static final String NC_WHERE_OLDCARD = '(Name=:name AND email__c=:email) OR Id=:parentId OR Parent__c = :parentId OR Id = :cardId';
  // Chatterが有効？ プロファイル画像がある
  private static Boolean enableFeedItem {
    get {
      if (enableFeedItem == null) {
        if (Test.isRunningTest() == false) {
          enableFeedItem = ConnectApi.Organization.getSettings().features.chatter;
        }
        else {
          enableFeedItem = false;
        }
      }
      return enableFeedItem;
    }
    private set;
  }

  public SB_NC_CardOwnersBuilder(
        Id cardId,
        Boolean excludeMe,    // 自分を除外する
        Boolean includeCurrentOwner,  // このレコード所有者を含める
        Boolean includeInactiveUser,  // 無効なユーザも含める
        Boolean traceChangeJob, // 転職前後の名刺も含める
        Boolean showExchangeDate, // 名刺交換日を表示する
        String sortField, // 並び順(初期値)
        Boolean sortAsc,   // 昇順
        String titleFields,  // 所属役所の表示項目
        String fields) {       // ユーザの表示項目 ToDo
    this.cardId = cardId;
    this.excludeMe = excludeMe;    // 自分を除外する
    this.includeCurrentOwner = includeCurrentOwner;  // このレコード所有者を含める
    this.includeInactiveUser = includeInactiveUser;  // 無効なユーザも含める
    this.traceChangeJob = traceChangeJob; // 転職前後の名刺も含める
    this.showExchangeDate = showExchangeDate; // 名刺交換日を表示する
    this.sortField = String.isNotBlank(sortField) ? sortField : 'name'; // 並び順(初期値)
    this.sortAsc = sortAsc;   // 昇順
    this.titleFields = String.isNotBlank(titleFields) ? titleFields : 'CompanyName, Department, Title';// 所属役所の表示項目
    // this.titleFormatter = new JoinSpaceTitleFormatter(titleFields);
    SB_NC_CardOwnersBuilder.createTitileFormatter(this.titleFields);
    this.fields = String.isNotBlank(fields) ? fields : 'EMail, Phone';        // ユーザの表示項目
    SB_NC_CardOwnersBuilder.createItemListCreator(this.fields);
  }

  private String createCurrentCardsWhereExpression(Id parentId) {
    List<String> orItems = new List<String>();
    orItems.add('(Name=:name AND email__c=:email)');
    orItems.add('Id = :cardId');  // これ
    if (parentId == null) {
      // これが最新
      orItems.add('Parent__c = :cardId'); // これを最新にしてるレコード
    }
    else {
      // これは最新でない
      orItems.add('Id=:parentId');  // 最新名刺レコード
      orItems.add('Parent__c = :parentId'); // 同じのを最新としているレコード
    }
    return String.join(orItems, ' OR ');
  }

  private List<NameCard__c> getSameCards(NameCard__c card) {
    String name = card.Name;
    String email = card.email__c;
    Id cardId = card.Id;
    Id parentId = card.Parent__c;
    String query = String.format(NAMECARD_QUERY,
          new String[]{ createCurrentCardsWhereExpression(parentId), 'ASC' }); // 名刺は常に 交換日 昇順 で取ってくる
    return Database.query(query);
  }

  // 転職前後の名刺をさがす WHERE句
  private String createCurrentAndCahangeJobCardsWhereExpression(Set<Id> newCarrerIds) {
    List<String> orItems = new List<String>();
    orItems.add('Id IN :cardIds'); // 今の
    orItems.add('tenshokugonomeishi__c IN :cardIds'); // 転職前の
    if (!newCarrerIds.isEmpty()) {
      orItems.add('Id IN :newCarrerIds'); // 転職後の
    }
    return String.join(orItems, ' OR ');
  }

  private List<NameCard__c> getCurrentAndCahangeJobCards(List<NameCard__c> cards) {
    Set<Id> cardIds = new Set<Id>();
    Set<Id> newCarrerIds = new Set<Id>(); // 転職後の名刺レコードIDｓ
    for (NameCard__c c : cards) {
      cardIds.add(c.Id);
      if (c.tenshokugonomeishi__c != null) {
        newCarrerIds.add(c.tenshokugonomeishi__c);
      }
    }
    String query = String.format(NAMECARD_QUERY,
          new String[]{ createCurrentAndCahangeJobCardsWhereExpression(newCarrerIds), 'ASC' }); // 名刺は常に 交換日 昇順 で取ってくる
    return Database.query(query);
  }



  public enum SortKey { NAME, DEPT, EXCHANGE }

  private static Map<String, SortKey> SORT_KEY_MAP = new Map<String, SortKey> {
    'name' => SortKey.NAME,
    'department' => SortKey.DEPT,
    'exchangeDate' => SortKey.EXCHANGE
  };

  @TestVisible private static SortKey ownerSortKey = SortKey.Name;
  @TestVisible private static Boolean ownerSortAsc = true;

  private static final Set<String> PHONE_FIELDS = new Set<String> {
    'phone', 'mobilephone'
  };

  public class RecordField {
    private String label { get; private set; }
    @AuraEnabled public Object value { get; private set; }
    @AuraEnabled public boolean email { get; private set; }     // 項目の型 0: その他 1: 電話(Fax除く) 2:EMail
    @AuraEnabled public boolean phone { get; private set; }     // 項目の型 0: その他 1: 電話(Fax除く) 2:EMail
    @AuraEnabled public boolean other { get; private set; }     // 項目の型 0: その他 1: 電話(Fax除く) 2:EMail
    public RecordField(String label, Object value) {
      this.label = label.toLowerCase();
      this.value = value;
      this.phone = PHONE_FIELDS.contains(this.label);
      this.email = this.label == 'email';
      this.other = !this.phone && !this.email;
    }
  }

  public with sharing class CardOwner implements Comparable {
    @AuraEnabled public Id id { get; private set; }
    @AuraEnabled public String photoUrl { get; private set; }
    @AuraEnabled public String deptTitle { get; private set; }

    @AuraEnabled public String name { get; private set; }
    @AuraEnabled public String alias { get; private set; }
    // @AuraEnabled public String email { get; private set; }
    // @AuraEnabled public String phone { get; private set; }
    // @AuraEnabled public String mobilePhone { get; private set; }
    @AuraEnabled public String exchangeDate { get; private set; }
    @AuraEnabled public String department { get; private set; }
    // @AuraEnabled public Map<String, Object> values { get; private set; }
    @AuraEnabled public List<RecordField> items { get; private set; }
    @AuraEnabled public Id cardId { get; private set; }
    @AuraEnabled public String cardLabel { get; private set; }
    private NameCard__c card;

    public CardOwner(User u, NameCard__c card) {
      Map<String, Object> values = new Map<String, Object>();
      values.putAll(u.getPopulatedFieldsAsMap());
      this.id = (Id)values.get('Id');
      // v2.5 2020.02.xx SV_DEV-2220 「同じ名刺を持つユーザ」で表示されるユーザの画像が拡大して表示されていない → ConnectApi を使います。
      if (!System.Test.isRunningTest()) {
        // ConnectApi はテストでは 例外発生する。SeeAllDataにすると別の問題あるし
        ConnectApi.Photo photo = ConnectApi.UserProfiles.getPhoto(null, u.Id);
        this.photoUrl = photo.smallPhotoUrl;
      }
      this.name = (String)values.get('Name');
      this.alias = (String)values.get('Alias');
      // this.email = (String)values.remove('Email');
      // this.phone = (String)values.remove('Phone');
      // this.mobilePhone = (String)values.remove('MobilePhone');
      this.cardId = card.Id;
      this.card = card;
      if (card.card_exchange_date__c != null) {
        this.exchangeDate = String.valueOf(card.card_exchange_date__c); // 指定した date を表す string を、標準の「yyyy-MM-dd」形式で返します。
      }
      else {
        this.exchangeDate = '?';
      }
      this.department = (String)values.get('Department');
      this.deptTitle = SB_NC_CardOwnersBuilder.titleFormatter.format(u);
      this.items = SB_NC_CardOwnersBuilder.itemListCreater.create(u);
      this.cardLabel = SB_NC_CardOwnersBuilder.cardLabelFormatter.format(card);
    }
    public Integer compareTo(Object compareTo) {
      CardOwner other = (CardOwner)compareTo;
      Object thisKey;
      Object otherKey;
      switch on ownerSortKey {
        when DEPT {
          thisKey = this.department;
          otherKey = other.department;
        }
        when EXCHANGE {
          thisKey = this.exchangeDate;
          otherKey = other.exchangeDate;
          // thisKey = this.values.get('exchangeDate');
          // otherKey = other.values.get('exchangeDate');

          // if (this.exchangeDate != null && other.exchangeDate!=null) {
          //   return ownerSortAsc ? 0-this.exchangeDate.daysBetween(other.exchangeDate) : this.exchangeDate.daysBetween(other.exchangeDate);
          // }
          // else if (other.exchangeDate== null && this.exchangeDate == null) {
          //   return 0;
          // }
          // else if (this.exchangeDate == null) {
          //   return ownerSortAsc ? 1 : -1;
          // }
          // else {
          //   return ownerSortAsc ? -1: 1;
          // }
        }
        when else {
          thisKey = this.name;
          otherKey = other.name;
        }
      }
      if ((String)thisKey == (String)otherKey) {
        return 0;
      }
      else if (otherKey!= null && (thisKey == null || (String)thisKey > (String)otherKey)) {
        return ownerSortAsc ? 1 : -1;
      }
      else {
        return ownerSortAsc ? -1: 1;
      }
    }
  }

  public abstract class LwcResponse {
    @AuraEnabled public Boolean success { get; private set; }
    @AuraEnabled public String message { get; private set; }

    public LwcResponse() {
      this.success = true;
    }
    public void setException(Exception e) {
      this.message = e.getMessage();
      this.success = false;
    }
  }

  public with sharing class GetCardOwnersResponse extends LwcResponse {
    @AuraEnabled public String sortField { get; private set; }
    @AuraEnabled public Boolean sortAsc { get; private set; }
    @AuraEnabled public Id cardId { get; private set; }
    @AuraEnabled public List<CardOwner> owners { get; private set; }
    // @AuraEnabled public List<NameCard__c> cards { get; private set; }
    @AuraEnabled public Integer count { get; private set; }
    // @AuraEnabled public Integer getCardCount() { return this.cards.size(); }

    public GetCardOwnersResponse() {
      this.owners = new List<CardOwner>();
    }
    public void init(ID cardId, String sortField, Boolean sortAsc) {
      this.cardId = cardId;
      this.sortField = sortField;
      this.sortAsc = sortAsc;
    }

    public void addOwner(User u, NameCard__c card) {
      try {
        this.owners.add(new CardOwner(u, card));
      }
      catch(Exception e) {
        this.message = e.getMessage();
        this.success = false;
      }
    }

    // public void addCards(List<NameCard__c> cards) {
    //   this.cards = new List<NameCard__c>(cards);
    // }

    public void finalize() {
      ownerSortKey = SORT_KEY_MAP.get(this.sortField);
      ownerSortAsc = this.sortAsc;
      this.owners.sort();   // ソートが必要なのは 名刺交換日のときだけだけど
      this.count = this.owners.size();
    }

  }

  // 所属、役職等の表示クラス の基底
  @TestVisible
  private abstract class TitileFormatter {
    @TestVisible protected List<String> titleFields;
    public List<String> getTitleFields() { return titleFields; }

    public TitileFormatter(SObjectType otype, String sourceText) {
      // this.titleFormat = sourceText;
      this.titleFields = new List<String>();
      List<String> fields = parseTitleFields(sourceText.toLowerCase());
      Map<String, Schema.SObjectField > fMap = otype.getDescribe().fields.getMap();
      for(String f : fields) {
        if (fMap.containsKey(f)) {
          // 有効なAPI名のみ
          if (fMap.get(f).getDescribe().getSoapType() != Schema.SoapType.String) {
            continue;   // 文字列型のみ
          }
          this.titleFields.add(f);
        }
        // else {
        //   //  なかったら取り除く
        //   this.titleFormat = this.titleFormat.replace('{' + f + '}', '').trim();
        // }
      }
    }
    private abstract List<String> parseTitleFields(String text);
    public abstract String format(SObject o);
  }

  // 所属、役職等の表示クラス 1
  // 不完全、こもじにしちゃってるのと、無効な項目APIを残すので
  @TestVisible
  private with sharing class ReplaceTitileFormatter extends TitileFormatter {
    @TestVisible private String titleFormat;   // String text = '{CompanyName}{Department} {Title} {XXXX__c}';

    public ReplaceTitileFormatter(SObjectType otype, String sourceText) {
      super(otype, sourceText);
      this.titleFormat = sourceText.toLowerCase();      // ToDo
      for (Integer n = 0; n < this.titleFields.size(); n++) {
        String f = this.titleFields.get(n);
        this.titleFormat = this.titleFormat.replaceAll(f, String.valueOf(n)); // 同じのは前の数字を使う。後のは、なくなってるけど、このステップは通す
      }
    }

    private override List<String> parseTitleFields(String text) {
      List<String> result = new List<String>();
      if (String.isBlank(text)) {
        return result;
      }
      Pattern ptn = Pattern.compile('\\{([a-zA-Z0-9_]+?)\\}');
      Matcher matcher = ptn.matcher(text);
      while (matcher.find()) {
        if (matcher.groupCount() == 1) {
          // マッピングに追加
          result.add(matcher.group(1));
        }
      }
      return result;
    }

    public override String format(SObject obj) {
      List<String> values = new List<String>();
      // Map<String, Object> f2v = obj.getPopulatedFieldsAsMap();
      for (String f : this.titleFields) {
        String val = (String)obj.get(f);
        if (val != null) {
          values.add(val);
        }
        else {
          values.add(''); // NULLの項目も必要
        }
      }
      return String.format(this.titleFormat, values);
    }

  } // private with sharing class ReplaceTitileFormatter extends TitileFormatter {

  // 所属、役職等の表示クラス 2
  @TestVisible
  private with sharing class JoinSpaceTitleFormatter extends TitileFormatter {
    public JoinSpaceTitleFormatter(SObjectType otype, String sourceText) {
      super(otype, sourceText);
    }

    private override List<String> parseTitleFields(String text) {
      List<String> result = new List<String>();
      if (String.isNotBlank(text)) {
        result.addAll(text.split(',\\s*'));
      }
      return result;
    }

    public override String format(SObject obj) {
      List<String> values = new List<String>();
      for (String f : this.titleFields) {
        String val = (String)obj.get(f);
        if (val != null) {
          values.add(val);
        }

      }
      return String.join(values, ' ');
    }

  } //private with sharing class JoinSpaceTitleFormatter extends TitileFormatter {



  private class ItemListCreater {
    private List<String> fields;    // 全部小文字のAPI名
    public List<String> getFields() { return fields; }
    private List<String> camelFields;    // API名
    public ItemListCreater(String source) {
      this.fields = new List<String>();
      this.camelFields = new List<String>();
      Map<String, Schema.SObjectField > fMap = User.sObjectType.getDescribe().fields.getMap();
      for(String f : source.toLowerCase().split(',\\s*')) {
        if (fMap.containsKey(f) && fMap.get(f).getDescribe().getSoapType() == Schema.SoapType.String) {
          // 有効なAPI名 で 文字列型のみ
          this.fields.add(f);
          this.camelFields.add(fMap.get(f).getDescribe().getName());
        }
      }
    }
    public List<Object> create(Map<String, Object> f2v) {
      List<Object> result = new List<Object>();
      // // Map<String, Object> f2v = rec.getPopulatedFieldsAsMap();
      // for (String f : f2v.keySet()) {
      //   if (this.fields.contains(f.toLowerCase())) {
      //     result.add(f2v.get(f));
      //   }
      // }
      for (String f : this.camelFields) {
        if (f2v.containsKey(f)) {
          result.add(f2v.get(f));
        }
      }
      return result;
    }
    public List<RecordField> create(User u) {
      List<RecordField> result = new List<RecordField>();
      // // Map<String, Object> f2v = rec.getPopulatedFieldsAsMap();
      // for (String f : f2v.keySet()) {
      //   if (this.fields.contains(f.toLowerCase())) {
      //     result.add(f2v.get(f));
      //   }
      // }
      for (String f : this.camelFields) {
        Object v = u.get(f);
        if (v != null) {
          result.add(new RecordField(f, v));
        }
      }
      return result;
    }

    // public List<Object> create(SObject rec) {
    //   List<Object> result = new List<Object>();
    //   Map<String, Object> f2v = rec.getPopulatedFieldsAsMap();
    //   for (String f : this.fields) {
    //     if (f2v.containsKey(f)) {
    //       result.add(f2v.get(f));
    //     }
    //   }
    //   return result;
    // }
  }

  public GetCardOwnersResponse create() {
    GetCardOwnersResponse result = new GetCardOwnersResponse();
    try {
      result.init(this.cardId, this.sortField, this.sortAsc);
      List<NameCard__c> targets = [select Id, Name, email__c, Parent__c, OwnerId, tenshokugonomeishi__c FROM NameCard__c WHERE Id = :cardId];
      if (targets.isEmpty() == true){
        return null;
      }
      List<NameCard__c> cards;
      cards = getSameCards(targets[0]);
      if (this.traceChangeJob) {
        cards = getCurrentAndCahangeJobCards(cards);
      }
      // 結果に名刺s を追加
      // result.addCards(cards);
      Set<Id> ownerIds = new Set<Id>();
      Map<Id, NameCard__c> user2card = new Map<Id, NameCard__c>();
      for (NameCard__c card : cards) {
        if (this.excludeMe && card.OwnerId == UserInfo.getUserId()) { // 自分以外
          continue;
        }
        if (!this.includeCurrentOwner && card.OwnerId == targets[0].OwnerId) {// このレコード所有者を含める
          continue;
        }
        user2card.put(card.OwnerId, card); // 名刺は常に 所有者 昇順 交換日 昇順(NULL先) で取ってるので、後の日で上書き 交換日は新しい方を残す
        ownerIds.add(card.OwnerId);
      }
      // Set<String> cols = new Set<String>(USER_FIELDS);
      Set<String> cols = new Set<String> {'id', 'name', 'alias', 'department'}; //　必須
      // cols.addAll(this.fields.toLowerCase().split(',\\s*')); // 無効な項目もクエリするエラーにする。
      // cols.addAll(this.titleFields.toLowerCase().split(',\\s*')); // 無効な項目もクエリするエラーにする。
      cols.addAll(SB_NC_CardOwnersBuilder.titleFormatter.getTitleFields()); //
      cols.addAll(SB_NC_CardOwnersBuilder.itemListCreater.getFields()); //

      if (enableFeedItem) {
        cols.add('fullphotourl');
      }
      String orderby = '';
      if (sortField == 'name') {
        orderby = String.format(ORDER_NAME, new String[] { this.sortAsc ? 'ASC' : 'DESC'});
      }
      else if (sortField == 'department') {
        orderby = String.format(ORDER_DEPT, new String[] { this.sortAsc ? 'ASC' : 'DESC'});
      }
      String query = String.format(USER_QUERY,
        new String[]{ String.join(new List<String>(cols), ', '), (this.includeInactiveUser ? '' : 'and IsActive=true'), orderby });
      System.debug(query);
      List<User> users = Database.query(query);
      for (User u : users){
        // 結果に所有者s を追加
        result.addOwner(u, user2card.get(u.Id));
      }
      // 結果の並べ替えとか
      result.finalize();
    }
    catch(Exception e) {
      result.setException(e);
    }
    return result;
  }

}