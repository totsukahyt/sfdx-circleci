/**
 *
 * SB_NameCard_BasicSetting
 * 基本設定を保持するクラス  自動連携機能とか用の基本設定を保持するようのオブジェクト 名刺基本設定 を1レコード持つ
 *
 * Copyright (C) 2017-2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2017.02.xx
 *  @Version 2      2017.06.xx    V1.20  引継ぐ設定＋取引先登録オプション値のカスタム設定からの移行 に対応
 *  @Version 3      2017.12.xx    V1.22  Lead Extention で使うためGlobalへ
 *  @Version 4      2019.05.xx    V2.4 SV_DEV-940 取引先・取引先責任者登録時の会社名の比較対象をカスタム項目としたい
 *                                    SV_DEV-590 取引先・取引先検索の対象を、レコードタイプ単位で絞る
 *                                    SV_DEV-1644 取引先・取引先責任者に登録(更新時)のTodo任命先を名刺の所有者にしてほしい
 *  @Version 5      2020.05.xx    V2.5.2 SV_DEV-2599 コードスキャン対応
 *
 **/
global with sharing class SB_NameCard_BasicSetting {
  global class SB_NameCard_BasicSettingException extends Exception {} 

  private final String QUERY_FORM = 'SELECT {0} FROM NameCardBasicSetting__c ORDER BY CreatedDate ASC';
  private static SB_NameCard_BasicSetting instance;

  private NameCardBasicSetting__c setting;

  // 取引先登録の候補抽出で、会社名として比較するアカウントの項目 2019.05.xx    V2.4 SV_DEV-940 取引先・取引先責任者登録時の会社名の比較対象をカスタム項目としたい
  global static String accountOrgField { 
    get {
      if (accountOrgField == null) {
        NameCardBasicSetting__c setting = getNameCardBasicSetting();
        if (setting.RegistAccountCompareCustomize__c && String.isNotBlank(setting.RegistAccountCompareField__c)) {
          accountOrgField = setting.RegistAccountCompareField__c;
        }
        else {
          accountOrgField = 'Name';
        }
      }
      return accountOrgField;
    }
    private set;
  }

  // リード登録の候補抽出で、会社名として比較するリードの項目 2019.05.xx    V2.4 SV_DEV-940 取引先・取引先責任者登録時の会社名の比較対象をカスタム項目としたい
  global static String leadOrgField {  
    get {
      if (leadOrgField == null) {
        NameCardBasicSetting__c setting = getNameCardBasicSetting();
        if (setting.RegistLeadCompareCustomize__c && String.isNotBlank(setting.RegistLeadCompareField__c)) {
          leadOrgField = setting.RegistLeadCompareField__c;
        }
        else {
          leadOrgField = 'Name';
        }
      }
      return leadOrgField;
    }
    private set;
  }

  // 取引先登録、リード登録の候補抽出で、会社名として比較するアカウントの項目 2019.05.xx    V2.4 SV_DEV-940 取引先・取引先責任者登録時の会社名の比較対象をカスタム項目としたい
  // 項目APIの妥当性はチェックせず、クエリで例外にする。
  global static String getAltCompanyField(SObjectType target) {
    NameCardBasicSetting__c setting = getNameCardBasicSetting();
    if (target == Account.getSObjectType() &&
      // 取引先登録:取引先 会社名と比較する項目をカスタマイズする 
      // 取引先登録:取引先 会社名と比較する項目
      setting.RegistAccountCompareCustomize__c && String.isNotBlank(setting.RegistAccountCompareField__c)) {
      return setting.RegistAccountCompareField__c;
    }
    else if (target == Lead.getSObjectType() &&
      // 取引先登録:リード 会社名と比較する項目をカスタマイズする 
      // 取引先登録:リード 会社名と比較する項目
      setting.RegistLeadCompareCustomize__c && String.isNotBlank(setting.RegistLeadCompareField__c)) {
      return setting.RegistLeadCompareField__c;
    }
    return null;
  }

  private static final Map<String, String> REGIST_QUERY_SELECTED_RECTYPE_IDS = new Map<String, String> {
    'account' => 'RegistAccountQueryRecordTypeIds__c',
    'contact' => 'RegistContactQueryRecordTypeIds__c',
    'lead' => 'RegistLeadQueryRecordTypeIds__c'
  };

  global static String getRegistQuerySelectedRecordTypeIds(String objname) {
    String f = REGIST_QUERY_SELECTED_RECTYPE_IDS.get(objname.toLowerCase());
    NameCardBasicSetting__c setting = getNameCardBasicSetting();
    return (String)setting.get(f);
  }

  // 取引先登録の候補にする 取引先のレコードタイプ　これ以外はリストしない。 無効なIDが入ってたら無視するだけ
  // 戻り値のリストが空なら 全部
  global static List<Id> registAccountQueryRecordTypeIds {
    get {
      if (registAccountQueryRecordTypeIds == null) {
        NameCardBasicSetting__c setting = getNameCardBasicSetting();
        registAccountQueryRecordTypeIds = getSelectedRecTypeIds(Account.getSObjectType(), setting.RegistAccountQueryRecordTypeIds__c);
      }
      return registAccountQueryRecordTypeIds;
    }
    private set;
  }

  // 取引先登録の候補にする 取引先責任者のレコードタイプ　これ以外はリストしない。 無効なIDが入ってたら無視するだけ
  // 戻り値のリストが空なら 全部
  global static List<Id> registContactQueryRecordTypeIds {
    get {
      if (registContactQueryRecordTypeIds == null) {
        NameCardBasicSetting__c setting = getNameCardBasicSetting();
        registContactQueryRecordTypeIds = getSelectedRecTypeIds(Contact.getSObjectType(), setting.RegistContactQueryRecordTypeIds__c);
      }
      return registContactQueryRecordTypeIds;
    }
    private set;
  }

  // リード登録の候補にする リードのレコードタイプ　これ以外はリストしない。 無効なIDが入ってたら無視するだけ
  // 戻り値のリストが空なら 全部
  global static List<Id> registLeadQueryRecordTypeIds {
    get {
      if (registLeadQueryRecordTypeIds == null) {
        NameCardBasicSetting__c setting = getNameCardBasicSetting();
        registLeadQueryRecordTypeIds = getSelectedRecTypeIds(Lead.getSObjectType(), setting.RegistLeadQueryRecordTypeIds__c);
      }
      return registLeadQueryRecordTypeIds;
    }
    private set;
  }

  public static List<Id> getRegistQueryRecordTypeIds(String objName) {
    if (objName == 'account') {
      return registAccountQueryRecordTypeIds;
    }
    else if (objName == 'contact') {
      return registContactQueryRecordTypeIds;
    }
    else if (objName == 'lead') {
      return registLeadQueryRecordTypeIds;
    }
    throw new SB_NameCard_BasicSettingException('Invalid Parameter: ' + objName);
  }

  private static List<Id> getSelectedRecTypeIds(Schema.SObjectType otype, String value) {
    List<Id> result = new List<Id>();
    if (String.isBlank(value)) {
      return result;
    }
    String[] ids = value.split(';\\s*');
    Map<ID, Schema.RecordTypeInfo> rectypeInfos = otype.getDescribe().getRecordTypeInfosById();
    for (String id : ids) {
      if (!rectypeInfos.containsKey(id)) {
        continue;
      }
      result.add(id);
    }
    return result;
  }

  public SB_NameCard_BasicSetting() {
    this.setting = null;
    Set<String> fields = getValidFields();
    String query = String.format(QUERY_FORM, new String[] { String.join(new List<String>(fields), ', ') });
    System.debug(LoggingLevel.DEBUG, query);
    List<SObject> settings = Database.query(query);
    if (!settings.isEmpty()) {
      // ポストインストールスクリプトで レコードを作ってるので、基本的にはあるはず。
      this.setting = (NameCardBasicSetting__c)settings[0];
    }
    else {
      // テストクラスのとき、従来のテストクラスで、名刺レコードを追加・更新してるとトリガが動いて、自動連携のオンオフの判定をしてしまうので、それ用
      //this.setting = createSettingRecord();
      // SV_DEV-2599 コードスキャン対応、
      // コードスキャン時に発覚したQuery: Sharing対策として本クラス内のprivateメソッドでテストコード用のデフォルト設定を作成するよう修正
      //this.setting = SB_NC_PostInstallScript.createDefaultBasicSetting();
      this.setting = createSettingRecord();
    }
    System.assert(setting != null);
  }

  // 基本設定レコードを作る
  // テストクラスのとき、従来のテストクラスで、名刺レコードを追加・更新してるとトリガが動いて、自動連携のオンオフの判定をしてしまうので、それ用
  private NameCardBasicSetting__c createSettingRecord() {
    NameCardBasicSetting__c result = new NameCardBasicSetting__c(
      // パッケージ v1.19 Version 1 最初 Version__c がないとき
      RenkeiActive__c = false,      // 自動連携機能有効
      RenkeiAccountAddressPref__c = false,   // アカウント 都道府県
      RenkeiAccount_Street__c = false,   // アカウント 町名・番地
      RenkeiAccountZipCode__c = false,   // アカウント 郵便番号
      RenkeiAccountCity__c = false,      // アカウント 市区郡
      RenkeiAccountURL__c = false,       // アカウント URL
      RenkeiAccountCompany__c = true,   // アカウント 会社名
      RenkeiAccountPhone__c = false,     // アカウント 電話番号
      RenkeiSpecificItems__c = null,        // アカウント 特定項目
      RenkeiAccountSite__c = false,        // アカウント 部署名
      RenkeiExcludeHojinkakuPartial__c = true,      // 自動連携:会社名は法人格を除いて部分一致
      RenkeiExcludeHojinkaku__c = false,      // 自動連携:会社名は法人格を除いて完全一致
      RenkeiAccountSitePartialMatch__c = false,      // 自動連携:部署は中間一致検索
      RenkeiContactMail__c = true,      // コンタクト メールアドレス
      RenkeiContactLastName__c = true,  // コンタクト ラストネーム
      RenkeiContactFirstName__c = true, // コンタクト ファーストネーム
      RenkeiAccountQueryRecordTypeIds__c = null,    // 検索対象のレコードタイプタイプID カンマ区切り で羅列
      RenkeiContactQueryRecordTypeIds__c = null,  // 自動連携で検索対象の取引先責任者レコードタイプ
      RenkeiAccountOverwrite__c = false,   // 既存の取引先を上書き  初期値：上書きしない!
      RenkeiContactOverwrite__c = false,   // 既存の取引先責任者を上書き  初期値：上書きしない!
      RenkeiAccountNOExistCreateNew__c = true,  //既存の取引先がなければ新規作成する
      RenkeiContactNOExistCreateNew__c = true,  // 既存の取引先責任者がなければ新規作成する
      RenkeiAccountRecordTypes__c = null,     // 作成するアカウント の レコードタイプID １つ
      RenkeiContactRecordTypes__c = null,      // 作成するコンタクト の レコードタイプID １つ
      // パッケージ v1.20 Version 2
      SaishinInheritValues__c = false,          //最新名刺は値を引継ぐ
      RegistNoToDo__c = false, // 取引先・取引先任者に登録 ToDo登録しない
      RegistToDoSubject__c = Label.SB_NC_ExchangeCard, // 取引先・取引先任者に登録 ToDo件名
      RegistDispOverWriteCheckbox__c = true, // 取引先・取引先任者に登録 「上書きする」チェックボックスを表示する   → V3　から未使用 → 2つにわける
      RegistAccountNotOverWrite__c = false, // 取引先・取引先任者に登録 取引先を名刺情報で上書きしない
      RegistContactNotOverWrite__c = false, // 取引先・取引先任者に登録 取引先責任者を名刺情報で上書きしない
      RegistDispAccountRectype__c = true, // 取引先・取引先任者に登録 取引先レコードタイプ選択を表示する
      RegistDispContactRectype__c = true, // 取引先・取引先任者に登録 取引先責任者レコードタイプ選択を表示する
      // パッケージ v1.22 Version 3
      // SV_DEV-582 取引先・取引先任者に登録 「上書きする」チェックボックスを表示する  → 2つにわける
      RegistDispAccountOverWriteCheckbox__c = true,          //「既存の取引先を名刺情報で上書きする」を表示する
      RegistDispContactOverWriteCheckbox__c = true,          //「既存の取引先責任者を名刺情報で上書きする」を表示する
      // リード拡張 リード登録画面関連
      RegistDispLeadOverWriteCheckbox__c = true,          //「既存のリードを名刺情報で上書きする」を表示する
      RegistDispLeadRectype__c = true,   // リードに登録 リードレコードタイプ選択を表示する  Lead EX  V1.11 から
      // 取引先登録:リードを名刺情報で上書きしない リードに登録 名刺情報で上書きする  反転させるので注意！
      RegistLeadNotOverWrite__c = false,
      // リード拡張 キャンペーン適用用
      ScanSelectCampaign__c = false,         // スキャン:キャンペーン選択を有効化
      // リード拡張 自動連携 リード登録関連
      RenkeiLeadActive__c = false,           // 自動連携:リード登録機能を有効化
      RenkeiLeadNOExistCreateNew__c = true,  // 自動連携:既存のリードがなければ新規作成
      RenkeiLeadOverwrite__c = false,        // 自動連携:既存のリードを上書き  初期値：上書きしない!
      RenkeiLeadRecordTypes__c = null,       // 自動連携:リードレコードタイプ
      RenkeiActiveCampaignMember__c = false,  // 自動連携:スキャン時選択したキャンペーンのメンバーにする
      RenkeiCampaignStatus__c = null,         // 自動連携:キャンペーンの状況
      // SV_DEV-1244 SV_DEV-1168 【リード自動連携】SmartVisca 基本設定「自動連携:リード姓」がデフォルトでチェックが入っていない。
      // v2.0.3　v2.0.2 でSB_NameCard_BasicSettingBuilder にいれたけど、インナークラスの SB_NameCard_BasicSettingBuilder を使ってるので、こっちにいれないといけなかった
      RenkeiLeadLastName__c = true,         // v2.0.3 自動連携:リード姓
      RenkeiLeadFirstName__c = true,        // v2.0.3 自動連携:リード名
      RenkeiLeadMail__c = true,             // v2.0.3 自動連携:リードメールアドレス
      // 2019.09.XX v2.4   SV_DEV-1901 法人格の略称を正称の表記とみなして会社名を比較する 初期値オフ
      HojinkakuEquationLongAndAbbr__c = false, // v2.4 法人格の略称を正称の表記とみなして会社名を比較する
      // 2020.04.XX v2.5   SV_DEV-2390 取引先登録:リードToDo件名の初期値設定処理
      RegistLeadToDoSubject__c = Label.SB_NC_ExchangeCard, // 取引先登録:リードToDo件名
      RegistLeadToDoOwner__c = Label.SB_NC_LeadToDoOwner   // 取引先登録:リードToDoの任命先
    );
    return result;
  }

  private Set<String> getValidFields() {
    Set<String> result = new Set<String>();
    Map<String, Schema.SObjectField > fields = NameCardBasicSetting__c.getSObjectType().getDescribe().fields.getMap();
    for(Schema.SObjectField f : fields.values()) {
      Schema.DescribeFieldResult dfr = f.getDescribe();
      if (dfr.isCustom()) {
        result.add(dfr.getName());
      }
    }
    result.add('Id');
    result.add('Name');
    result.add('LastModifiedDate');     // 2017.06.16
    result.add('LastModifiedById');       // 2017.06.16
    result.add('LastModifiedBy.Name');    // 2017.06.16
    return result;
  }

  global static NameCardBasicSetting__c getNameCardBasicSetting() {
    if (instance == null) {
      instance = new SB_NameCard_BasicSetting();
    }
    return instance.setting;
  }

}