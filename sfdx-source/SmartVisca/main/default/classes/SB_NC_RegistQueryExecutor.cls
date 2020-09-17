/**
 *
 * SB_NC_RegistQueryExecutor
 *  名刺データからの検索条件 を 保持し、アカウント、コンタクトの検索を実行するクラス
 *  SB_NC_RegistQueryStrategy.QueryStrategy に従って、実行、　Where句の バインドする変数はこのクラスで持つから。
 *    検索条件の レコードタイプは QueryStrategy からもらう
 *
 * (c) 2019 Sunbridge Inc.
 *
 *  @author K.Yoshida
 *  @Version 2.2  2019.02.XX SV_DEV-1558 LEX 取引先登録 一括画面をLXパッケージ同様のLC化で追加
 *  @Version 2.4  2019.06.xx sawano SV_DEV-665 取引先・取引先責任者登録のLDV対応の改造 = 取引先・取引先責任者登録の取引先400万件対応（検索のSOSL化）
 *
 **/
public with sharing class SB_NC_RegistQueryExecutor {
  public class SB_NC_RegistQueryExecutorException extends Exception {}

  public Set<Id> cardIds { get; private set;}    // 保持してる名刺レコード値の名刺レコードID
  private List<NameCard__c> cards;    // Id 指定されて検索して 保持してる名刺レコード
  public List<NameCard__c> getNameCards() { return this.cards; }
  // 条件になる 名刺の 値を保持しとく
  public String orgName { get; private set;}    // 法人格を除いた法人名 SOSL 用 個別では1語、一括では OR で連携
  public Set<String> orgNameWithParcents { get; private set;}    // 法人格を除いた法人名 %付き 部分一致用
  public Set<String> fullOrgNames { get; private set;}    // 法人格+法人名
  public Set<String> depts { get; private set;}     // 所属
  //public Boolean nullDepts { get; private set;}     // 所属 が NULLの名刺があったとき
  public Set<String> titles { get; private set;}     // 役職
  public Set<String> deptWithParcents { get; private set;}     // 所属 %付き 部分一致用
  public Set<String> firstnames { get; private set;}    // 名
  public Set<String> lastnames { get; private set;}    // 姓
  public Set<String> emails { get; private set;}    // メアド
  public Set<String> emailsWithNull { get; private set;}    // メアド NULも含む
  public Set<String> urls { get; private set;}    // URL
  public Set<String> prefs { get; private set;}    // 都道府県
  public Set<String> cities { get; private set;}   // 市区郡
  public Set<String> streets { get; private set;}   // 町名・番地
  public Set<String> zips { get; private set;}     // 郵便番号
  public Set<String> phones { get; private set;}     // 電話番号
  public Set<String> mobiles { get; private set;}     // 携帯番号
  public Set<String> memos { get; private set;}     // メモ
  public Set<Id> acntIds { get; private set;}     // アカウント参照  注意 queryOnlyEMail:true なら、メアドのみ一致するコンタクトの親アカウントのIDも入る
  public Set<Id> contIds { get; private set;}     // コンタクト参照
  public Set<Id> leadIds { get; private set;}     // リード参照
  public Set<Id> parentIds { get; private set;}     // コンタクトの親アカウント
  public Set<Id> acntRecTypeIds { get; private set;}  // アカウント レコードタイプ
  //public Set<Id> personRecTypeIds { get; private set;}  // 個人アカウント レコードタイプ
  public Set<Id> contRecTypeIds { get; private set;}  // コンタクト レコードタイプ
  public Set<Id> leadRecTypeIds { get; private set;}  // リード レコードタイプ
  private Map<SObjectType, Set<Id>> otype2referedIds; // オブジェクトごとの 参照ID のセット
  public Boolean canUseSosl { get; private set;}  // SOSL を使える？ 法人格覗いて 英数2文字以上あり 、その他SOSL不適合文字がない

  // SOSL が使えるか？
  // SearchQuery の文字制限: SearchQuery 文字列が 10,000 字を超えると、結果行は返されません。
  public Boolean isEnableSoslLength() {
    return String.isNotBlank(this.orgName) && this.orgName.length() < 10000;
  }

  // public Boolean isReferenced(Id recId) {
  //   if (recId.getSobjectType() == Account.getSObjectType()) {
  //     return this.acntIds.contains(recid);
  //   }
  //   else if (recId.getSobjectType() == Contact.getSObjectType()) {
  //     return this.contIds.contains(recid);
  //   }
  //   else if (recId.getSobjectType() == Lead.getSObjectType()) {
  //     return this.leadIds.contains(recid);
  //   }
  //   return false;
  // }

  //// 名刺基本設定レコード
  //private NameCardBasicSetting__c setting;

  //// アカウントのレコードタイプを調べて、取引先と個人取引先レコードタイプ を仕分ける
  //private void setupAccountRecordType() {
  //  if (!SB_NameCard_Util.isEnablePersonAccount() || !isAccountSupportRecType()) {
  //    return;
  //  }
  //  List<AggregateResult> ars = Database.query('SELECT RecordTypeId FROM Account WHERE IsPersonAccount=true GROUP BY RecordTypeId');
  //  for (AggregateResult ar : ars) {
  //    this.personRecTypeIds.add((Id)ar.get('RecordTypeId'));
  //  }
  //  for (Id i : this.acntRecTypeIds) {
  //    if (this.personRecTypeIds.contains(i)) {
  //      // 個人アカウント のレコードタイプを除外
  //      this.acntRecTypeIds.remove(i);
  //    }
  //  }
  //}

  //private Boolean isAccountSupportRecType() {
  //  Boolean result = false;
  //  Map<ID, Schema.RecordTypeInfo> id2info = Account.sObjectType.getDescribe().getRecordTypeInfosById();
  //  for (Schema.RecordTypeInfo info : id2info.values()) {
  //    if (!info.isMaster() && info.isActive()) {
  //      result = true;
  //      break;
  //    }
  //  }
  //  return true;
  //}

  // SOSLの検索語として有効か？
  // ２文字以上あるか、１文字でもASCIIのだけでなければ、TRUE
  private Boolean isEnableSoslWord(String text) {
    return String.isNotBlank(text) && (text.length() > 1 || !text.isAsciiPrintable());
  }

  private void setupVAlues(List<NameCard__c> cards) {
    List<String> orgNames = new List<String>();
    for (NameCard__c card : cards) {
      this.cardIds.add(card.Id);
      // 会社名
      // 2017.11.xx v1.20.4  SV_DEV-673 会社名に全角バックスラッシュが含まれる名刺を自動連携すると、ORA-01423.9エラーが発生
      // this.orgName が for ループで入れ替わるけど、使うのは個別のときだけなので
      String orgName = getZenkakuBackslashToWildcard(SB_NameCard_Util.getCompanyName(card.company_name__c));
      this.canUseSosl &= isEnableSoslWord(orgName); // 複数 検索後 を OR 連結するとき、１つでもSOSLできるならいいみたい。→ だけど、1つでもできないならSOSLしない
      // orgNames.add('\'' + orgName + '\''); // \'はなくてもいい ？
      orgNames.add(orgName); // \'はなくてもいい ？
      if (String.isNotBlank(orgName)) {
        //orgNames.add(accountName);      // 法人格を除いた法人名
        this.orgNameWithParcents.add('%' + varBindingExchange(orgName) + '%'); // 法人格を除いた法人名 %付き 部分一致用
      }
      if (String.isNotBlank(card.company_name__c)) {
        this.fullOrgNames.add(card.company_name__c);    // 法人格+法人名
      }
      // 部署
      this.depts.add(card.division__c);
      if (String.isNotBlank(card.division__c)) {
        // 2017.11.xx v1.20.4 SV_DEV-673 会社名に全角バックスラッシュが含まれる名刺を自動連携すると、ORA-01423.9エラーが発生
        String dept = varBindingExchange(card.division__c);
        this.deptWithParcents.add('%' + dept + '%');
      }
      //else {
      //  this.nullDepts = true;   // 1つでもNULLのがあったら、NULLあり処理をするので、
      //}
      // 役職
      this.titles.add(card.title_name__c);
      // 姓名
      //Map<String, String> pnMap = SB_NameCard_Util.getPersonName(card);
      //String last_name = pnMap.get('last_name');
      //String first_name = pnMap.get('first_name');
      //lastnames.add(last_name);    // 姓 NULLも入れてIN条件とする
      //firstnames.add(first_name);   // 名 NULLも入れてIN条件とする
      // mastail 2017.12.xx NULLも入れてIN条件とする
      //emails.add(card.email__c);
      // 都道府県 NULLも条件
      this.prefs.add(card.address_pref__c);
      // 市区郡
      if (String.isNotBlank(card.address__c)) {
        Map<String, String> addrs = SB_NameCard_Util.getAddress(card);
        String city = addrs.get('city');
        //if (String.isNotBlank(city)) {
          this.cities.add(city); // NULLも条件
        //}
        String street = addrs.get('street_nobld');  // 建物名なし
        //if (String.isNotBlank(street)) {
          this.streets.add(street);  // NULLも条件
        //}
      }
      // 郵便番号
      //if (String.isNotBlank(card.zip_code__c)) {
        this.zips.add(card.zip_code__c);
      //}
      // コンタクト 用の検索用の 値
      //Map<String, String> names = SB_NameCard_Util.getPersonName(card);
      // 姓
      if (String.isNotBlank(card.person_name_last__c)) {
        this.lastnames.add(card.person_name_last__c);
      }
      // ラストネーム
      if (String.isNotBlank(card.last_name__c)) {
        this.lastnames.add(card.last_name__c);
      }
      // 姓 が NULL
      if (card.person_name_last__c == null && card.last_name__c == null) {
        this.lastnames.add(null);
      }
      // 名
      if (String.isNotBlank(card.person_name_first__c)) {
        this.firstnames.add(card.person_name_first__c);
      }
      // ファーストネーム
      if (String.isNotBlank(card.first_name__c)) {
        this.firstnames.add(card.first_name__c);
      }
      // 名 が NULL
      if (card.person_name_first__c == null && card.first_name__c == null) {
        this.firstnames.add(null);
      }
      // メール NULL でも条件
      this.emailsWithNull.add(card.email__c);
      // メール NULL以外 の条件
      if (String.isNotBlank(card.email__c)) {
        this.emails.add(card.email__c);
      }
      // URL
      this.urls.add(card.web_url1__c);
      // URL2
      if (String.isNotBlank(card.web_url2__c)) {
        this.urls.add(card.web_url2__c);
      }
      // 電話番号 NULL でも条件にする。
      //if (String.isNotBlank(card.tel1__c)) {
        this.phones.add(card.tel1__c);
      //}
      // 電話番号 2 NULLは除外
      if (String.isNotBlank(card.tel2__c)) {
        this.phones.add(card.tel2__c);
      }
      // 携帯番号 NULL でも
      //if (String.isNotBlank(card.mobile__c)) {
        this.mobiles.add(card.mobile__c);
      //}
      // メモ 取引先の指定項目と比較する NULL以外
      if (String.isNotBlank(card.memo__c)) {
        this.memos.add(card.memo__c);
      }
      // アカウント参照先
      if (card.account__c != null) {
        this.acntIds.add(card.account__c);
      }
      // コンタクト参照先
      if (card.contact__c != null) {
        this.contIds.add(card.contact__c);
      }
      // リード参照先
      if (card.lead__c != null) {
        this.leadIds.add(card.lead__c);
      }
    } // for
    // SOSL の検索語
    this.orgName = String.join(orgNames, ' OR ');
    this.canUseSosl &= isEnableSoslLength();   // クエリがSOSLの長さ制限だったら、SOQLに変える
  }

  private static String varBindingExchange(String str) {
    if (String.isBlank(str)) {
      return str;
    }
    //アポストロフィーがある場合、escapeSingleQuotesメソッドがエスケープされるはずですが、
    //なぜかうまくエスケープできてないので、エスケープする前にアポストロフィーをbase64を使って暗号化して、エスケープ後に元に戻す
    String str1 = EncodingUtil.urlEncode(str, 'UTF-8');
    Blob b = Blob.valueOf(str1);
    String b64 = EncodingUtil.base64Encode(b);
    str = str.replaceAll('\'',b64);
    str = String.escapeSingleQuotes(getZenkakuBackslashToWildcard(str));
    str = str.replaceAll(b64,'\'');
    return str;
  }

  public static String getZenkakuBackslashToWildcard(String text) {
    return String.isBlank(text) ? text : text.replaceAll('＼', '_');
  }


  //private static Set<Id> getValidRectypIds(SObjectType otype, String text_ids) {
  //  Set<Id> result = new Set<Id>();
  //  if (String.isBlank(text_ids)) {
  //    return result;
  //  }
  //  String[] ss = text_ids.split('[^0-9a-zA-Z]+');    // 2017.07.21 レコードIDなので、英数以外で分割  SV_DEV-528  自動連係 既存の取引先の検索条件 検索対象の取引先レコードタイプが全て選択されていると自動連係処理時にエラーとなる
  //  if (!ss.isEmpty()) {
  //    Map<ID, Schema.RecordTypeInfo> id2info = otype.getDescribe().getRecordTypeInfosById();
  //    for (String s : ss) {
  //      if (id2info.containsKey(s) && id2info.get(s).isAvailable()) { // 2017.09.06 SV_DEV-598 デフォルトのレコードタイプがないユーザで自動連携を行なった場合にエラーメッセージの表示
  //        result.add(s);
  //      }
  //    }
  //  }
  //  return result;
  //}

  private SB_NC_RegistQueryExecutor() {
    //this.setting = SB_NameCard_BasicSetting.getNameCardBasicSetting();   // 基本設定
    //orgNames = new Set<String>();    // 法人格を除いた法人名
    this.cardIds = new Set<Id>();
    this.orgNameWithParcents = new Set<String>();    // 法人格を除いた法人名 %付き 部分一致用
    this.fullOrgNames = new Set<String>();    // 法人格+法人名
    this.firstnames = new Set<String>();
    this.lastnames = new Set<String>();
    this.emails = new Set<String>();
    this.emailsWithNull = new Set<String>();
    this.urls = new Set<String>();
    this.depts = new Set<String>();
    //this.nullDepts = false;
    this.deptWithParcents = new Set<String>();
    this.titles = new Set<String>();
    this.prefs = new Set<String>();
    this.cities = new Set<String>();
    this.streets = new Set<String>();
    this.zips = new Set<String>();
    this.phones = new Set<String>();
    this.mobiles = new Set<String>();
    this.memos = new Set<String>();
    this.acntIds = new Set<Id>();
    this.contIds = new Set<Id>();
    this.leadIds = new Set<Id>();
    this.parentIds = new Set<Id>();
    //this.acntRecTypeIds = getValidRectypIds(Account.sObjectType, this.setting.RenkeiAccountQueryRecordTypeIds__c);
    //this.contRecTypeIds = getValidRectypIds(Contact.sObjectType, this.setting.RenkeiContactQueryRecordTypeIds__c);
    //this.leadRecTypeIds = getValidRectypIds(Lead.sObjectType, this.setting.RenkeiLeadQueryRecordTypeIds__c);
    this.acntRecTypeIds = new Set<Id>();
    this.contRecTypeIds = new Set<Id>();
    this.leadRecTypeIds = new Set<Id>();
    //this.personRecTypeIds = new Set<Id>();
    //setupAccountRecordType();
    //setupVAlues(cards);
    this.otype2referedIds = new Map<SObjectType, Set<Id>>();
    this.otype2referedIds.put(Account.sObjectType, this.acntIds);
    this.otype2referedIds.put(Contact.sObjectType, this.contIds);
    this.otype2referedIds.put(Lead.sObjectType, this.leadIds);
    this.canUseSosl = true;
  }

  // アカウントを絞ったあと、コンタクトを照会するとき用
  public void setContactParentIds(Set<Id> ids) {
    this.parentIds.clear();
    this.parentIds.addAll(ids);
  }

  public Boolean haveNullDept() {
    return this.depts.contains(null);
  }

  //
  public List<SObject> getCandidateRecords(SB_NC_RegistQueryStrategy.QueryStrategy qSt) {
    System.assert(!this.cardIds.isEmpty());
    //this.parentIds.clear();
    System.debug(LoggingLevel.DEBUG, qSt);
    if (qSt instanceOf SB_NC_RegistQueryStrategy.ContactQueryStrategy && !qSt.getParentIds().isEmpty()) {
      this.parentIds.clear();
      this.parentIds.addAll(qSt.getParentIds());
    }
    String query = qSt.getQueryString(this);
    System.debug(LoggingLevel.DEBUG, query);
    List<SObject> records = Database.query(query);
    // // v2.4 2019.06.xx
    // // クエリ結果をそのまま返さず、
    // if (this.cards.size() == 1 && qSt.isNeedMatching()) {
    //   // 個別で 取引先名は法人格を除いて一致か、取引先名は完全一致（法人格の正称・略称を区別する = FALSE) 、
    //   // クエリ後、名刺レコードとの照合が必要
    //   List<SObject> result = new List<SObject>();
    //   for (SObject rec : records) {
    //     if (isReferenced(qSt.target, rec.Id) || qSt.isMatch(this.cards[0], rec)) { // 参照されてるか、名刺に合致してるか
    //       result.add(rec);
    //     }
    //   }
    //   return result;
    // }
    // else {
    //   // 全部返す。
    //   // 個別 法人格除いて中間一致は 名刺との照合不要
    //   // 一括 あとで、名刺ごとにMatchingする。
      return records;
    // }
  }

  // // レコードID 指定で該当レコードをクエリ
  // public List<SObject> getReferencedCandidateRecords(SObjectType otype) {
  //   System.assert(!this.cardIds.isEmpty());
  //   System.assert(otype2referedIds.containsKey(otype));
  //   Set<Id> ids = new Set<Id>(otype2referedIds.get(otype));
  //   if (ids.isEmpty()) {
  //     return null;
  //   }
  //   String fields = String.join(new List<String>(SB_NC_RegistQueryStrategy.getQueryFields(otype)), ',');
  //   String query = String.format('SELECT {0} FROM {1} {2}', new String[]{ fields, otype.getDescribe().getName(), 'WHERE Id In :ids' });
  //   System.debug(LoggingLevel.DEBUG, query);
  //   return Database.query(query);
  // }

  // レコードID 指定で該当レコードをクエリ
  public List<SObject> getReferencedCandidateRecords(SB_NC_RegistQueryStrategy.QueryStrategy qSt) {
    System.assert(!this.cardIds.isEmpty());
    System.debug(LoggingLevel.DEBUG, qSt);
    // Id を条件にするクエリを得る
    String query = qSt.getQueryStringForReferenced(this);
    System.debug(LoggingLevel.DEBUG, query);
    if (String.isBlank(query)) {
      return new List<SObject>();
    }
    return Database.query(query);
  }

  // SOSLでレコードを得る Accountのみ
  public List<SObject> getCandidateRecordsBySosl(SB_NC_RegistQueryStrategy.QueryStrategy qSt) {
    System.assert(!this.cardIds.isEmpty());
    //this.parentIds.clear();
    System.assert(qSt instanceOf SB_NC_RegistQueryStrategy.AccountQueryStrategy);
    if (!isEnableSoslLength()) {
      throw new SB_NC_RegistQueryExecutorException('SOSL SearchQuery too long. Reduce business card records.');
    }
    System.debug(LoggingLevel.DEBUG, this.orgName);
    System.debug(LoggingLevel.DEBUG, this.orgNameWithParcents);
    String query = qSt.getSearchString(this);
    System.debug(LoggingLevel.DEBUG, query);
    List<List<SObject>> searchList = Search.query(query);
    // // return searchList.isEmpty() ? new List<SObject>() : searchList[0];
    // // v2.4 2019.06.xx
    // // クエリ結果をそのまま返さず、
    // if (!searchList.isEmpty() && this.cards.size() == 1 && qSt.isNeedMatching()) {
    //   System.debug(searchList[0].size());
    //   // 個別で 取引先名は法人格を除いて一致か、取引先名は完全一致（法人格の正称・略称を区別する = FALSE) 、
    //   // クエリ後、名刺レコードとの照合が必要
    //   List<SObject> result = new List<SObject>();
    //   for (SObject rec : searchList[0]) {
    //     if (isReferenced(qSt.target, rec.Id) || qSt.isMatch(this.cards[0], rec)) { // 参照されてるか、名刺に合致してるか
    //       result.add(rec);
    //     }
    //   }
    //   System.debug(result.size());
    //   return result;
    // }
    // else {
    //   // 全部返す。
    //   // 個別 法人格除いて部分一致は 名刺との照合不要
    //   // 一括 あとで、名刺ごとにMatchingする。
    //   System.debug(searchList[0].size());
      return searchList.isEmpty() ? new List<SObject>() : searchList[0];
    // }


  }

  public Integer getCandidateRecordCount(SB_NC_RegistQueryStrategy.QueryStrategy qSt) {
    System.assert(!this.cardIds.isEmpty());
    Integer result = 0;
    //this.parentIds.clear();
    String query = qSt.getCountString(this);
    System.debug(LoggingLevel.DEBUG, query);
    List<AggregateResult> ars = Database.query(query);
    for (AggregateResult ar : ars) {
      result = (Integer)ar.get('cnt');
      break;
    }
    return result;
  }

  // // 初期化
  // // 名刺レコード を指定して
  // public List<NameCard__c> init(NameCard__c card) {
  //   // ToDo
  //   List<NameCard__c> cards = new List<NameCard__c>();
  //   cards.add(card);
  //   setupVAlues(cards);
  //   return cards;
  // }

  // 初期化
  // 名刺レコードID を指定して
  public List<NameCard__c> init(Id cardId) {
    Set<String> fields = getNameCardFields();
    String query = String.format('SELECT {0} FROM NameCard__c WHERE Id = :cardId', new String[] { String.join(new List<String>(fields), ', ')});
    this.cards = Database.query(query);
    if (this.cards.isEmpty()) {
      throw new SB_NC_RegistQueryExecutorException('Invalid Operation');
    }
    setupVAlues(this.cards);
    if (String.isBlank(this.orgName) || this.lastnames.isEmpty()) {
      this.cardIds.clear();
      throw new SB_NC_RegistQueryExecutorException('Invalid Business Card');
    }
    return this.cards;
  }

  // 初期化
  // 名刺レコードID コレクション を指定して
  public List<NameCard__c> init(Set<Id> cardIds) {
    // ToDo
    Set<String> fields = getNameCardFields();
    String query = String.format('SELECT {0} FROM NameCard__c WHERE Id IN :cardIds', new String[] { String.join(new List<String>(fields), ', ')});
    this.cards = Database.query(query);
    if (this.cards.isEmpty()) {
      throw new SB_NC_RegistQueryExecutorException('Invalid Operation');
    }
    setupVAlues(this.cards);
    if (this.fullOrgNames.isEmpty() || this.lastnames.isEmpty()) {
      this.cardIds.clear();
      throw new SB_NC_RegistQueryExecutorException('Invalid Business Cards');
    }
    return this.cards;
  }

  // // 初期化
  // // 名刺レコード コレクション を指定して
  // public List<NameCard__c> init(List<NameCard__c> cards) {
  //   setupVAlues(cards);
  //   return cards;
  // }


  // // 対称の名刺を変えるとき
  // public void reset(List<NameCard__c> cards) {
  //   this.cardIds.clear();
  //   this.orgNameWithParcents.clear();    // 法人格を除いた法人名 %付き 部分一致用
  //   this.fullOrgNames.clear();    // 法人格+法人名
  //   this.firstnames.clear();
  //   this.lastnames.clear();
  //   this.emails.clear();
  //   this.emailsWithNull.clear();
  //   this.urls.clear();
  //   this.depts.clear();
  //   //this.nullDepts = false;
  //   this.deptWithParcents.clear();
  //   this.titles.clear();
  //   this.prefs.clear();
  //   this.cities.clear();
  //   this.streets.clear();
  //   this.zips.clear();
  //   this.phones.clear();
  //   this.mobiles.clear();
  //   this.memos.clear();
  //   this.acntIds.clear();
  //   this.contIds.clear();
  //   this.leadIds.clear();
  //   this.parentIds.clear();
  //   //this.acntRecTypeIds = getValidRectypIds(Account.sObjectType, this.setting.RenkeiAccountQueryRecordTypeIds__c);
  //   //this.contRecTypeIds = getValidRectypIds(Contact.sObjectType, this.setting.RenkeiContactQueryRecordTypeIds__c);
  //   //this.leadRecTypeIds = getValidRectypIds(Lead.sObjectType, this.setting.RenkeiLeadQueryRecordTypeIds__c);
  //   //this.personRecTypeIds = new Set<Id>();
  //   //setupAccountRecordType();
  //   setupVAlues(cards);
  // }

  public Boolean needRefresh(Set<Id> cardIds) {
    return !this.cardIds.equals(cardIds);
  }

  // 初期化済み？
  public Boolean isInitialized() {
    return !this.cardIds.isEmpty();
  }

  private static SB_NC_RegistQueryExecutor instance;

  // 基本的には特定の名刺たちに対して、検索をあれこれおこなうので、名刺データを保持するインスタンスを使いまわす。
  public static SB_NC_RegistQueryExecutor getInstance() {
    if (instance == null) {
      instance = new SB_NC_RegistQueryExecutor();
    }
    return instance;
  }

  // 候補抽出に必要な名刺の項目s
  public static Set<String> getNameCardFields() {
    return SB_NC_RegistQueryStrategy.getNameCardFields();
  }

}