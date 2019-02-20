/**
 *
 * SB_NameCardL_RegistQueryExecutor
 *  名刺データからの検索条件 を 保持し、アカウント、コンタクト、リード の検索を実行するクラス
 *  SB_NameCardL_RegistQueryStrategy.QueryStrategy に従って、実行、　Where句の バインドする変数はこのクラスで持つから。
 *    検索条件の レコードタイプは QueryStrategy からもらう
 *
 * Copyright (C) 2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2018.4.xx
 *
 **/
public with sharing class SB_NameCardL_RegistQueryExecutor {
  public class SB_NameCardL_RegistQueryExecutorException extends Exception {}

  public Set<Id> cardIds { get; private set;}    // 保持してる名刺レコード値の名刺レコードID
  // 条件になる 名刺の 値を保持しとく
  public Set<String> orgNameWithParcents { get; private set;}    // 法人格を除いた法人名 %付き 部分一致用
  public Set<String> fullOrgNames { get; private set;}    // 法人格+法人名
  public Set<String> depts { get; private set;}     // 所属
  public Set<String> titles { get; private set;}     // 役職
  public Set<String> deptWithParcents { get; private set;}     // 所属 %付き 部分一致用
  public Set<String> firstnames { get; private set;}    // 名
  public Set<String> lastnames { get; private set;}    // 姓
  public Set<String> emails { get; private set;}    // メアド
  public Set<String> prefs { get; private set;}    // 都道府県
  public Set<String> cities { get; private set;}   // 市区郡
  public Set<String> streets { get; private set;}   // 町名・番地
  public Set<String> zips { get; private set;}     // 郵便番号
  public Set<String> phones { get; private set;}     // 電話番号
  public Set<String> mobiles { get; private set;}     // 携帯番号
  public Set<String> memos { get; private set;}     // メモ
  public Set<Id> acntIds { get; private set;}     // アカウント参照
  public Set<Id> contIds { get; private set;}     // コンタクト参照
  public Set<Id> leadIds { get; private set;}     // リード参照
  public Set<Id> parentIds { get; private set;}     // コンタクトの親アカウント
  public Set<Id> acntRecTypeIds { get; private set;}  // アカウント レコードタイプ
  //public Set<Id> personRecTypeIds { get; private set;}  // 個人アカウント レコードタイプ
  public Set<Id> contRecTypeIds { get; private set;}  // コンタクト レコードタイプ
  public Set<Id> leadRecTypeIds { get; private set;}  // リード レコードタイプ
  private Map<SObjectType, Set<Id>> otype2referedIds; // オブジェクトごとの 参照ID のセット

  //// 名刺基本設定レコード
  //private SmartViscaf__NameCardBasicSetting__c setting;

  //// アカウントのレコードタイプを調べて、取引先と個人取引先レコードタイプ を仕分ける
  //private void setupAccountRecordType() {
  //  if (!SmartViscaf.SB_NameCard_Util.isEnablePersonAccount() || !isAccountSupportRecType()) {
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

  private void setupVAlues(List<SmartViscaf__NameCard__c> cards) {
    for (SmartViscaf__NameCard__c card : cards) {
      this.cardIds.add(card.Id);
      // 会社名
      // 2017.11.xx v1.20.4  SV_DEV-673 会社名に全角バックスラッシュが含まれる名刺を自動連携すると、ORA-01423.9エラーが発生
      String accountName = getZenkakuBackslashToWildcard(SmartViscaf.SB_NameCard_Util.getCompanyName(card.SmartViscaf__company_name__c));
      if (String.isNotBlank(accountName)) {
        //orgNames.add(accountName);      // 法人格を除いた法人名
        orgNameWithParcents.add('%' + varBindingExchange(accountName) + '%'); // 法人格を除いた法人名 %付き 部分一致用
        fullOrgNames.add(card.SmartViscaf__company_name__c);    // 法人格+法人名
      }
      // 部署
      if (String.isNotBlank(card.SmartViscaf__division__c)) {
        depts.add(card.SmartViscaf__division__c);
        // 2017.11.xx v1.20.4 SV_DEV-673 会社名に全角バックスラッシュが含まれる名刺を自動連携すると、ORA-01423.9エラーが発生
        String dept = varBindingExchange(card.SmartViscaf__division__c);
        deptWithParcents.add('%' + dept + '%');
      }
      // 役職
      titles.add(card.SmartViscaf__title_name__c);
      // 姓名
      //Map<String, String> pnMap = SmartViscaf.SB_NameCard_Util.getPersonName(card);
      //String last_name = pnMap.get('last_name');
      //String first_name = pnMap.get('first_name');
      //lastnames.add(last_name);    // 姓 NULLも入れてIN条件とする
      //firstnames.add(first_name);   // 名 NULLも入れてIN条件とする
      // mastail 2017.12.xx NULLも入れてIN条件とする
      //emails.add(card.SmartViscaf__email__c);
      // 都道府県 NULLも条件
      prefs.add(card.SmartViscaf__address_pref__c);
      // 市区郡
      if (String.isNotBlank(card.SmartViscaf__address__c)) {
        Map<String, String> addrs = SmartViscaf.SB_NameCard_Util.getAddress(card);
        String city = addrs.get('city');
        //if (String.isNotBlank(city)) {
          cities.add(city); // NULLも条件
        //}
        String street = addrs.get('street_nobld');  // 建物名なし
        //if (String.isNotBlank(street)) {
          streets.add(street);  // NULLも条件
        //}
      }
      // 郵便番号
      //if (String.isNotBlank(card.SmartViscaf__zip_code__c)) {
        zips.add(card.SmartViscaf__zip_code__c);
      //}
      // コンタクト 用の検索用の 値
      //Map<String, String> names = SmartViscaf.SB_NameCard_Util.getPersonName(card);
      // 姓
      if (String.isNotBlank(card.SmartViscaf__person_name_last__c)) {
        lastnames.add(card.SmartViscaf__person_name_last__c);
      }
      // ラストネーム
      if (String.isNotBlank(card.SmartViscaf__last_name__c)) {
        lastnames.add(card.SmartViscaf__last_name__c);
      }
      // 姓 が NULL
      if (card.SmartViscaf__person_name_last__c == null && card.SmartViscaf__last_name__c == null) {
        lastnames.add(null);
      }
      // 名
      if (String.isNotBlank(card.SmartViscaf__person_name_first__c)) {
        firstnames.add(card.SmartViscaf__person_name_first__c);
      }
      // ファーストネーム
      if (String.isNotBlank(card.SmartViscaf__first_name__c)) {
        firstnames.add(card.SmartViscaf__first_name__c);
      }
      // 名 が NULL
      if (card.SmartViscaf__person_name_first__c == null && card.SmartViscaf__first_name__c == null) {
        firstnames.add(null);
      }
      // メール NULL でも条件にする。
      emails.add(card.SmartViscaf__email__c);
      // 電話番号 NULL でも条件にする。
      //if (String.isNotBlank(card.SmartViscaf__tel1__c)) {
        phones.add(card.SmartViscaf__tel1__c);
      //}
      // 電話番号 2 NULLは除外
      if (String.isNotBlank(card.SmartViscaf__tel2__c)) {
        phones.add(card.SmartViscaf__tel2__c);
      }
      // 携帯番号 NULL でも
      //if (String.isNotBlank(card.SmartViscaf__mobile__c)) {
        mobiles.add(card.SmartViscaf__mobile__c);
      //}
      // メモ 取引先の指定項目と比較する NULL以外
      if (String.isNotBlank(card.SmartViscaf__memo__c)) {
        memos.add(card.SmartViscaf__memo__c);
      }
      // アカウント参照先
      if (card.SmartViscaf__account__c != null) {
        acntIds.add(card.SmartViscaf__account__c);
      }
      // コンタクト参照先
      if (card.SmartViscaf__contact__c != null) {
        contIds.add(card.SmartViscaf__contact__c);
      }
      // リード参照先
      if (card.SmartViscaf__lead__c != null) {
        leadIds.add(card.SmartViscaf__lead__c);
      }
    }
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

  private SB_NameCardL_RegistQueryExecutor() {
    //this.setting = SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting();   // 基本設定
    //orgNames = new Set<String>();    // 法人格を除いた法人名
    this.cardIds = new Set<Id>();
    this.orgNameWithParcents = new Set<String>();    // 法人格を除いた法人名 %付き 部分一致用
    this.fullOrgNames = new Set<String>();    // 法人格+法人名
    this.firstnames = new Set<String>();
    this.lastnames = new Set<String>();
    this.emails = new Set<String>();
    this.depts = new Set<String>();
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
    //this.acntRecTypeIds = getValidRectypIds(Account.sObjectType, this.setting.SmartViscaf__RenkeiAccountQueryRecordTypeIds__c);
    //this.contRecTypeIds = getValidRectypIds(Contact.sObjectType, this.setting.SmartViscaf__RenkeiContactQueryRecordTypeIds__c);
    //this.leadRecTypeIds = getValidRectypIds(Lead.sObjectType, this.setting.SmartViscaf__RenkeiLeadQueryRecordTypeIds__c);
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
  }

  // アカウントを絞ったあと、コンタクトを照会するとき用
  public void setContactParentIds(Set<Id> ids) {
    this.parentIds.clear();
    this.parentIds.addAll(ids);
  }

  //
  public List<SObject> getCandidateRecords(SB_NameCardL_RegistQueryStrategy.QueryStrategy qSt) {
    if (this.cardIds.isEmpty()) {
      throw new SB_NameCardL_RegistQueryExecutorException('not initialized');
    }
    //this.parentIds.clear();
    String query = qSt.getQueryString(this);
    System.debug(query);
    return Database.query(query);
  }


  // レコードID 指定で該当レコードをクエリ
  public List<SObject> getReferencedCandidateRecords(SObjectType otype) {
    if (this.cardIds.isEmpty()) {
      throw new SB_NameCardL_RegistQueryExecutorException('not initialized');
    }
    System.assert(otype2referedIds.containsKey(otype));
    Set<Id> ids = new Set<Id>(otype2referedIds.get(otype));
    if (ids.isEmpty()) {
      return null;
    }
    String query = SB_NameCardL_RegistQueryStrategy.getQueryStringByIds(otype); // SELECT ... FROM .. WHER Id IN :ids
    System.debug(query);
    return Database.query(query);
  }

  // SOSLでレコードを得る
  public List<SObject> getCandidateRecordsBySosl(SB_NameCardL_RegistQueryStrategy.QueryStrategy qSt) {
    if (this.cardIds.isEmpty()) {
      throw new SB_NameCardL_RegistQueryExecutorException('not initialized');
    }
    //this.parentIds.clear();
    System.assert(qSt instanceOf SB_NameCardL_RegistQueryStrategy.AccountQueryStrategy
                  || qSt instanceOf SB_NameCardL_RegistQueryStrategy.LeadQueryStrategy); // これだけサポート
    String query = qSt.getQueryString(this);
    System.debug(query);
    return Database.query(query);
  }

  public Integer getCandidateRecordCount(SB_NameCardL_RegistQueryStrategy.QueryStrategy qSt) {
    if (this.cardIds.isEmpty()) {
      throw new SB_NameCardL_RegistQueryExecutorException('not initialized');
    }
    Integer result = 0;
    //this.parentIds.clear();
    String query = qSt.getCountString(this);
    System.debug(query);
    List<AggregateResult> ars = Database.query(query);
    for (AggregateResult ar : ars) {
      result = (Integer)ar.get('cnt');
      break;
    }
    return result;
  }

  // 初期化
  // 名刺レコード を指定して
  public List<SmartViscaf__NameCard__c> init(SmartViscaf__NameCard__c card) {
    // ToDo
    List<SmartViscaf__NameCard__c> cards = new List<SmartViscaf__NameCard__c>();
    cards.add(card);
    setupVAlues(cards);
    return cards;
  }

  // 初期化
  // 名刺レコードID を指定して
  public List<SmartViscaf__NameCard__c> init(Id cardId) {
    Set<String> fields = getNameCardFields();
    String query = String.format('SELECT {0} FROM SmartViscaf__NameCard__c WHERE Id = :cardId', new String[] { String.join(new List<String>(fields), ', ')});
    List<SmartViscaf__NameCard__c> cards = Database.query(query);
    if (cards.isEmpty()) {
      throw new SB_NameCardL_RegistQueryExecutorException('');
    }
    setupVAlues(cards);
    return cards;
  }

  // 初期化
  // 名刺レコードID コレクション を指定して
  public List<SmartViscaf__NameCard__c> init(Set<Id> cardIds) {
    // ToDo
    Set<String> fields = getNameCardFields();
    String query = String.format('SELECT {0} FROM SmartViscaf__NameCard__c WHERE Id IN :cardIds', new String[] { String.join(new List<String>(fields), ', ')});
    List<SmartViscaf__NameCard__c> cards = Database.query(query);
    if (cards.isEmpty()) {
      throw new SB_NameCardL_RegistQueryExecutorException('');
    }
    setupVAlues(cards);
    return cards;
  }

  // 初期化
  // 名刺レコード コレクション を指定して
  public List<SmartViscaf__NameCard__c> init(List<SmartViscaf__NameCard__c> cards) {
    setupVAlues(cards);
    return cards;
  }


  // 対称の名刺を変えるとき
  public void reset(List<SmartViscaf__NameCard__c> cards) {
    this.cardIds.clear();
    this.orgNameWithParcents.clear();    // 法人格を除いた法人名 %付き 部分一致用
    this.fullOrgNames.clear();    // 法人格+法人名
    this.firstnames.clear();
    this.lastnames.clear();
    this.emails.clear();
    this.depts.clear();
    this.deptWithParcents.clear();
    this.titles.clear();
    this.prefs.clear();
    this.cities.clear();
    this.streets.clear();
    this.zips.clear();
    this.phones.clear();
    this.mobiles.clear();
    this.memos.clear();
    this.acntIds.clear();
    this.contIds.clear();
    this.leadIds.clear();
    this.parentIds.clear();
    //this.acntRecTypeIds = getValidRectypIds(Account.sObjectType, this.setting.SmartViscaf__RenkeiAccountQueryRecordTypeIds__c);
    //this.contRecTypeIds = getValidRectypIds(Contact.sObjectType, this.setting.SmartViscaf__RenkeiContactQueryRecordTypeIds__c);
    //this.leadRecTypeIds = getValidRectypIds(Lead.sObjectType, this.setting.SmartViscaf__RenkeiLeadQueryRecordTypeIds__c);
    //this.personRecTypeIds = new Set<Id>();
    //setupAccountRecordType();
    setupVAlues(cards);
  }

  // 初期化済み？
  public Boolean isInitialized() {
    return !this.cardIds.isEmpty();
  }

  private static SB_NameCardL_RegistQueryExecutor instance;

  // 基本的には特定の名刺たちに対して、検索をあれこれおこなうので、名刺データを保持するインスタンスを使いまわす。
  public static SB_NameCardL_RegistQueryExecutor getInstance() {
    if (instance == null) {
      instance = new SB_NameCardL_RegistQueryExecutor();
    }
    return instance;
  }

  // 候補抽出に必要な名刺の項目s
  public static Set<String> getNameCardFields() {
    return SB_NameCardL_RegistQueryStrategy.getNameCardFields();
  }

}