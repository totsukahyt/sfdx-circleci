/**
 *
 *  SB_NameCardL_Util
 *  ユーティリティ クラス
 *
 *  @author sawano
 *  @Version 1    2017.12.xx
 *
 *  Lead拡張パッケージ用縮小バージョン
 *
 * Copyright (c) 2011-2018 SunBridge Inc.
 *
 **/
public with sharing class SB_NameCardL_Util {

  // 活動状況の選択肢を取得, キーは 'Completed' か 'NotStarted' のみ有効
  public static Map<String, String> taskStatusValues {
    get {
      if (taskStatusValues == null) {
        taskStatusValues = new Map<String, String>();
        List<TaskStatus> taskstatuses = [ SELECT IsClosed, IsDefault, MasterLabel, SortOrder FROM TaskStatus ORDER BY SortOrder ];
        for (TaskStatus ts : taskstatuses) {
          if (ts.isClosed && ! taskStatusValues.containsKey('Completed')) {
            taskStatusValues.put('Completed', ts.MasterLabel);
          } else if (ts.isDefault && ! taskStatusValues.containsKey('NotStarted')) {
             taskStatusValues.put('NotStarted', ts.MasterLabel);
          }
        }
        if (! taskStatusValues.containsKey('Completed')) {
          taskStatusValues.put('Completed', System.Label.SB_NCL_Completed);
        } else if (! taskStatusValues.containsKey('NotStarted')) {
          taskStatusValues.put('NotStarted', System.Label.SB_NCL_NotStarted);
        }
      }
      return taskStatusValues;
    }
  }

  //// SOQLで 部分一致検索 するときは、これを通した文字列を使う
  //public static String getStringForPartialMatch(String str) {
  //  if (String.isBlank(str)) {
  //    return str;
  //  }
  //  //アポストロフィーがある場合、escapeSingleQuotesメソッドがエスケープされるはずですが、
  //  //なぜかうまくエスケープできてないので、エスケープする前にアポストロフィーをbase64を使って暗号化して、エスケープ後に元に戻す
  //  String result;
  //  Blob b = Blob.valueOf(EncodingUtil.urlEncode(str, 'UTF-8'));
  //  String b64 = EncodingUtil.base64Encode(b);
  //  result = str.replaceAll('\'',b64);
  //  result = String.escapeSingleQuotes(result.replaceAll('＼', '_'));
  //  result = result.replaceAll(b64,'\'');
  //  return result;
  //}

  // 取引先・取引先責任者登録 の 取引先の表示項目設定
  private static final String REGIST_ACCOUNT_QUERYFIELD = 'BillingPostalCode, BillingState:2, BillingCity, BillingStreet, Site:2';
  // 取引先・取引先責任者登録 の 取引先責任者の表示項目設定
  private static final String REGIST_CONTACT_QUERYFIELD = 'Department:2, Title:2, Email:2, MailingPostalCode, MailingState, MailingCity, MailingStreet';
  // 取引先・取引先責任者登録 の 取引先責任者の表示項目設定
  private static final String REGIST_LEAD_QUERYFIELD = 'Company:2, Title:2, Email:2, PostalCode, State, City, Street';

  public static SmartViscaf__SmartViscaConfig__c smartViscaConfig {
    get {
      if (smartViscaConfig == null) {
        smartViscaConfig = SmartViscaf__SmartViscaConfig__c.getInstance(UserInfo.getUserId());   //  個人の設定
        if (smartViscaConfig.Id ==null) {
          smartViscaConfig =  SmartViscaf__SmartViscaConfig__c.getInstance(UserInfo.getProfileId());   //プロファイルの設定
        }
        if (smartViscaConfig.id == null) {
          smartViscaConfig = SmartViscaf__SmartViscaConfig__c.getOrgDefaults();    // 組織の設定
        }
        if (smartViscaConfig.id == null) {
        }
        // 統合版自動連携:リードなく、取引先既存で取引先責任者を作成する
        smartViscaConfig.RenkeiCreateContactOnAcountWithoutLead__c = smartViscaConfig.RenkeiCreateContactOnAcountWithoutLead__c == null ? false : smartViscaConfig.RenkeiCreateContactOnAcountWithoutLead__c;
        // 統合版自動連携:リード、取引先既存で取引先責任者を作成する
        smartViscaConfig.RenkeiCreateContactOnAcountWithLead__c = smartViscaConfig.RenkeiCreateContactOnAcountWithLead__c == null ? false : smartViscaConfig.RenkeiCreateContactOnAcountWithLead__c;
        // 統合版自動連携: 既存取引先が複数あり特定できないとき、リードを作る。
        smartViscaConfig.RenkeiCreateLeadOnTooManyAccounts__c = smartViscaConfig.RenkeiCreateLeadOnTooManyAccounts__c == null ? false : smartViscaConfig.RenkeiCreateLeadOnTooManyAccounts__c;
        // 統合版自動連携: 取引先責任者もキャンペーンメンバーにする。
        smartViscaConfig.RenkeiContactToCampaignMember__c = smartViscaConfig.RenkeiContactToCampaignMember__c == null ? false : smartViscaConfig.RenkeiContactToCampaignMember__c;
        // 統合版自動連携: 更新でもキャンペーンメンバーにする。
        smartViscaConfig.RenkeiUpdateToCampaignMember__c = smartViscaConfig.RenkeiUpdateToCampaignMember__c == null ? false : smartViscaConfig.RenkeiUpdateToCampaignMember__c;
        // 統合版自動連携:条件に合致する既存リードは全て更新する。
        smartViscaConfig.RenkeiUpdateAllLeadsOnCondition__c = smartViscaConfig.RenkeiUpdateAllLeadsOnCondition__c == null ? true : smartViscaConfig.RenkeiUpdateAllLeadsOnCondition__c;

        // LEX版 CRM登録* 個別 関連
        // CRMに登録 の 取引先の表示項目設定
        smartViscaConfig.SmartViscaf__SRegistQueryAccountFields1__c = String.isBlank(smartViscaConfig.SmartViscaf__SRegistQueryAccountFields1__c) ?
        REGIST_ACCOUNT_QUERYFIELD : smartViscaConfig.SmartViscaf__SRegistQueryAccountFields1__c;
        // CRMに登録 の 取引先責任者の表示項目設定
        smartViscaConfig.SmartViscaf__SRegistQueryContactFields1__c = String.isBlank(smartViscaConfig.SmartViscaf__SRegistQueryContactFields1__c) ?
        REGIST_CONTACT_QUERYFIELD : smartViscaConfig.SmartViscaf__SRegistQueryContactFields1__c;
        // CRMに登録 の リードの表示項目設定
        smartViscaConfig.SRegistQueryLeadFields1__c = String.isBlank(smartViscaConfig.SRegistQueryLeadFields1__c) ?
        REGIST_LEAD_QUERYFIELD : smartViscaConfig.SRegistQueryLeadFields1__c;

      }
      return smartViscaConfig;
    }
  }

  public static String getNamespacePrefix_x() { return String.isEmpty(namespacePrefix) ? '' : namespacePrefix+'__'; }
  public static String getNamespacePrefix() { return namespacePrefix; }
  private static String namespacePrefix {
    get {
      if (namespacePrefix ==null) {
        List<ApexClass> classes = [SELECT Name, NamespacePrefix FROM ApexClass WHERE Name='SB_NameCardL_Util'];
        if (classes.size() == 1) { // 別のパッケージで SB_NameCard_Utilを持ってる場合に対処 2018.08.xx
          namespacePrefix = classes[0].NamespacePrefix != null ? classes[0].NamespacePrefix : '';
        }
        else if (classes.size() > 1) {
           namespacePrefix = 'SmartViscal';
        }
        else {
          namespacePrefix = '';
        }
      }
      return namespacePrefix;
    }
    private set;
  }


  // キャンペーンの状況のデフォルト
  public static String getDefaultCampaignStatus() {
    String result;
    List<String> statuss = new List<String>();
    Schema.DescribeFieldResult F = Campaign.Status.getDescribe();
    List<Schema.PicklistEntry> P = F.getPicklistValues();
    for (Schema.PicklistEntry ent : P) {
      if (ent.isActive()) {
        statuss.add(ent.getLabel());
        System.debug('active item : ' + ent.getLabel());
      }
      else {
        System.debug('inactive item : ' + ent.getLabel());
      }
      if (ent.isDefaultValue()) {
        result = ent.getLabel();
        System.debug('Default item : ' + ent.getLabel());
      }
    }
    return result;
  }

  //オブジェクトでフォールトのレコードタイプIDを取得
  public static String getDefaultRecordType(SObjectType otype){
    String recordTypeId;
    List<Schema.RecordTypeInfo> rs =  otype.getDescribe().getRecordTypeInfos();
    for (RecordTypeInfo r : rs) {
        if (r.isDefaultRecordTypeMapping() && r.isAvailable() && !r.isMaster()) {
             recordTypeId = r.getRecordTypeId();
        }
    }
    return recordTypeId;
  }

  //レコードタイプを取得
  public static List<RecordTypeInfo> getRecordType(SObjectType otype){
    List<Schema.RecordTypeInfo> rs =  otype.getDescribe().getRecordTypeInfos();
    List<RecordTypeInfo> recordtypes = new List<RecordTypeInfo>();
    for (RecordTypeInfo r : rs) {
      if (r.isAvailable()) {
        recordtypes.add(r);
      }
    }
    //isMasterメソード使えるにはWinter'16　APIバージョン35.0以降でなければならない、
    //そのため、今最後のレコードタイプMasterをリストから削除します
    if (recordtypes.size()>0) {
      recordtypes.remove(recordtypes.size()-1);
    }
    return recordtypes;
  }

  //
  @TestVisible
  private static final Set<String> SV_OBJECT_NAMES = new Set<String> {
    'namecard__c',  // 名刺
    'namecardhistory__c', // 名刺履歴
    'namecardrenkeimapping__c', // 名刺連携項目マッピング
    'jinjiido__c',  // 人事異動情報
    'jinjiidoemail__c', // 人事異動情報メール通知
    'namecardbasicsetting',  // 名刺基本設定
    'namecardsettingvalues__c',  // 名刺設定値
    'namecardrenkeijyoken__c'  // 名刺自動連携条件設定
  };

  public static String getManagedObjectName(String oName) {
    String result = oName;
    if (SV_OBJECT_NAMES.contains(oName.toLowerCase())) {
      String ns = SB_NameCardL_Util.getNamespacePrefix_x();
      result = ns + oName;
    }
    return result;
  }

  // SOSL の予約語をエスケープする。 2016.10.xx
  private static final String SOSL_YOYAKUGO = '?&|!{}[]()^~*:"\'+-\\';
  public static String escapeSOSLYoyakugo(String text) {
    if (!text.containsAny(SOSL_YOYAKUGO)) {
      return text;
    }
    String result = text;
    result = result.replace('\\', '\\\\');
    result = result.replace('?', '\\?');
    result = result.replace('&', '\\&');
    result = result.replace('|', '\\|');
    result = result.replace('!', '\\!');
    result = result.replace('{', '\\{');
    result = result.replace('}', '\\}');
    result = result.replace('[', '\\[');
    result = result.replace(']', '\\]');
    result = result.replace('(', '\\(');
    result = result.replace(')', '\\)');
    result = result.replace('^', '\\^');
    result = result.replace('~', '\\~');
    result = result.replace('*', '\\*');
    result = result.replace(':', '\\:');
    result = result.replace('"', '\\"');
    result = result.replace('\'', '\\\'');
    result = result.replace('+', '\\+');
    result = result.replace('-', '\\-');
    System.debug(result);
    return result;
  }



}