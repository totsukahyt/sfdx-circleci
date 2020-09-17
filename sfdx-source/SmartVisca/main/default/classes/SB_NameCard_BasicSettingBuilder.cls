/**
 *
 * SB_NameCard_BasicSettingBuilder
 * 名刺基本設定レコード を新規作成、カスタム設定からの移行、バージョンアップ時の項目追加でデフォルト値セットする
 *  SB_NC_PostInstallScript から呼ばれる。
 *
 * Copyright (C) 2017-2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2017.06.xx
 *  @Version 2      2017.09.xx SV_DEV-582 『「上書きする」チェックボックスを表示する』機能について取引先・取責を分けて制御できるようにしたい
 *                  2017.12.xx v1.22 対応 BasicSetting Version 3
 *                                    with sharing  を取ります。
 *  v2.0.2  2018.08.xx リード検索条件の 姓、名、メアドをON に  直接でないけど の対応で→ SV_DEV-1106 SmartVisca基本設定レコードの一部項目の値が反転して表示される。
 *
 *  @deprecated PostInstallScript の内部クラスにした
 *
 **/
public class SB_NameCard_BasicSettingBuilder {
  // NameCardBasicSetting__c のフォーマットのバージョン
  // V1.20 => 2 から始めます。
  // V1.21 => 3
  @TestVisible
  private static final Integer CURRENT_SETTING_VERSION = 3;  // 2017.12.xx v1.22
  // 基本設定の項目
  @TestVisible
  private static final Map<String, Schema.SObjectField > nameCardBasicSettingFields
    = NameCardBasicSetting__c.getSObjectType().getDescribe().fields.getMap();
  // 名前空間名プレフィックス
  //private static String NS_X = SB_NC_PostInstallScript.getNamespacePrefix_x();
  private static String getNamespacePrefix_x() { return String.isEmpty(namespacePrefix) ? '' : namespacePrefix+'__'; }
  //private static String getNamespacePrefix() { return namespacePrefix; }
  private static void setNamespacePrefix(String ns) {
    namespacePrefix = ns;
  }
  private static String namespacePrefix;


  @TestVisible
  public virtual class ItemBuilder {
    public Integer since { get; private set; }    //  この項目が発生したバージョン
    public String field { get; private set; }     //
    public String sourceField { get; private set; }     // 移行する項目 カスタム設定  SmartViscaConfig__c か 基本設定オブジェクト NameCardBasicSetting__c の項目のどちらか。 （注意）重複するAPI名の項目はない前提
    public Object defaultValue { get; private set; }
    //public ItemBuilder(Integer since, String field) {
    //  this.since = since;
    //  this.field = field;
    //  this.sourceField = null;
    //  this.defaultValue = null;
    //}
    // カスタム設定から移行でない項目
    public ItemBuilder(Integer since, String field, Object defaultValue ) {
      this.since = since;
      this.field = field;
      this.sourceField = null;
      this.defaultValue = defaultValue;
    }
    // カスタム設定から移行の項目
    public ItemBuilder(Integer since, String field, String sourceField, Object defaultValue ) {
      this.since = since;
      this.field = field;
      this.sourceField = sourceField;
      this.defaultValue = defaultValue;
    }
    //
    public Object create(NameCardBasicSetting__c setting, SmartViscaConfig__c customConfig) {
      if (setting.Id == null ||       // 新規レコード ＝ 新規インストール
        (setting.Version__c == null && this.since > 1) ||  // 名刺基本設定オブジェクトができれた最初のバージョンのレコード v1.19  に対して 以降に発生した項目をセット
        (setting.Version__c != null && this.since > setting.Version__c)) {  // v1.20 以降のレコード で そのレコードのバージョン以降に発生した項目をセット
        //Object prvVal = setting.get(this.field);    // 念のため NULL の項目にだけ値をセット
        if ((setting != null || customConfig != null) && String.isNotBlank(this.sourceField)) {
          Object val;
          if (nameCardBasicSettingFields.containsKey(getNamespacePrefix_x() + this.sourceField) && setting != null) {
            System.debug(getNamespacePrefix_x() + this.sourceField);
            val = setting.get(getNamespacePrefix_x() + this.sourceField);    // NameCardBasicSetting__c から
          }
          else if (customConfig != null) {
            System.debug(this.sourceField);
            //val = customConfig.get(this.sourceField);     // カスタム設定 SmartViscaConfig__c から
            Map<String, Object> customConfigMap = customConfig.getPopulatedFieldsAsMap();
            val = customConfigMap.get(getNamespacePrefix_x() + this.sourceField);
          }
          if (this.field == 'RegistLeadNotOverWrite__c' && val != null && val instanceOf Boolean) { // 項目によってはそのまま移行しない
            val = !(Boolean)val; // 反転
          }
          else {
            val = val == null ? this.defaultValue : val;      // NULLなら、デフォルト値
          }
          setting.put(this.field, val);
        }
        else if (this.defaultValue != null) {
          setting.put(this.field, this.defaultValue);
        }
      }
      return setting.get(this.field);
    }
    //  カスタム設定からの移行はなく、単純にデフォルトのレコードを作る
    public Object create(NameCardBasicSetting__c setting) {
      if (this.defaultValue != null) {
        setting.put(this.field, this.defaultValue);
      }
      return setting.get(this.field);
    }

  }   // public virtual class ItemBuilder
  // 各項目の 発生バージョン と デフォルト値 を処理するクラス の テーブル
  @TestVisible
  private List<ItemBuilder> itemBuilders =  new List<ItemBuilder> {
    // パッケージ v1.19 Version 1 最初 Version__c がないとき
    new ItemBuilder(1, 'RenkeiAccountAddressPref__c', false),   // アカウント 都道府県
    new ItemBuilder(1, 'RenkeiAccount_Street__c', false),   // アカウント 町名・番地
    new ItemBuilder(1, 'RenkeiAccountZipCode__c', false),   // アカウント 郵便番号
    new ItemBuilder(1, 'RenkeiAccountCity__c', false),      // アカウント 市区郡
    new ItemBuilder(1, 'RenkeiAccountURL__c', false),       // アカウント URL
    new ItemBuilder(1, 'RenkeiAccountCompany__c', true),   // アカウント 会社名
    new ItemBuilder(1, 'RenkeiAccountPhone__c', false),     // アカウント 電話番号
    new ItemBuilder(1, 'RenkeiSpecificItems__c', null),        // アカウント 特定項目
    new ItemBuilder(1, 'RenkeiAccountSite__c', false),        // アカウント 部署名
    new ItemBuilder(1, 'RenkeiExcludeHojinkakuPartial__c', true),      // 自動連携:会社名は法人格を除いて部分一致
    new ItemBuilder(1, 'RenkeiExcludeHojinkaku__c', false),      // 自動連携:会社名は法人格を除いて完全一致
    new ItemBuilder(1, 'RenkeiAccountSitePartialMatch__c', false),      // 自動連携:部署は中間一致検索
    new ItemBuilder(1, 'RenkeiContactMail__c', true),      // コンタクト メールアドレス
    new ItemBuilder(1, 'RenkeiContactLastName__c', true),  // コンタクト ラストネーム
    new ItemBuilder(1, 'RenkeiContactFirstName__c', true), // コンタクト ファーストネーム
    new ItemBuilder(1, 'RenkeiAccountQueryRecordTypeIds__c', null),    // 検索対象のレコードタイプタイプID カンマ区切り で羅列
    new ItemBuilder(1, 'RenkeiContactQueryRecordTypeIds__c', null),  // 自動連携で検索対象の取引先責任者レコードタイプ
    new ItemBuilder(1, 'RenkeiAccountOverwrite__c', false),   // 既存の取引先を上書き  初期値：上書きしない!
    new ItemBuilder(1, 'RenkeiContactOverwrite__c', false),   // 既存の取引先責任者を上書き  初期値：上書きしない!
    new ItemBuilder(1, 'RenkeiAccountNOExistCreateNew__c', true),  //既存の取引先がなければ新規作成する
    new ItemBuilder(1, 'RenkeiContactNOExistCreateNew__c', true),  // 既存の取引先責任者がなければ新規作成する
    new ItemBuilder(1, 'RenkeiAccountRecordTypes__c', null),     // 作成するアカウント の レコードタイプID １つ
    new ItemBuilder(1, 'RenkeiContactRecordTypes__c', null),      // 作成するコンタクト の レコードタイプID １つ
    // パッケージ v1.20 Version 2
    new ItemBuilder(2, 'SaishinInheritValues__c', false),          //最新名刺は値を引継ぐ
    new ItemBuilder(2, 'RegistNoToDo__c', 'ToDo__c', false), // 取引先・取引先任者に登録 ToDo登録しない
    new ItemBuilder(2, 'RegistToDoSubject__c', 'ToDoName__c', Label.SB_NC_ExchangeCard), // 取引先・取引先任者に登録 ToDo件名
    new ItemBuilder(2, 'RegistDispOverWriteCheckbox__c', true), // 取引先・取引先任者に登録 「上書きする」チェックボックスを表示する   → V3　から未使用 → 2つにわける
    new ItemBuilder(2, 'RegistAccountNotOverWrite__c', 'AccountNotOverWrite__c', false), // 取引先・取引先任者に登録 取引先を名刺情報で上書きしない
    new ItemBuilder(2, 'RegistContactNotOverWrite__c', 'ContactNotOverWrite__c', false), // 取引先・取引先任者に登録 取引先責任者を名刺情報で上書きしない
    new ItemBuilder(2, 'RegistDispAccountRectype__c', 'DispAccountRectype__c', true), // 取引先・取引先任者に登録 取引先レコードタイプ選択を表示する
    new ItemBuilder(2, 'RegistDispContactRectype__c', 'DispContactRectype__c', true), // 取引先・取引先任者に登録 取引先責任者レコードタイプ選択を表示する
    // パッケージ v1.22 Version 3
    // SV_DEV-582 取引先・取引先任者に登録 「上書きする」チェックボックスを表示する  → 2つにわける
    new ItemBuilder(3, 'RegistDispAccountOverWriteCheckbox__c', 'RegistDispOverWriteCheckbox__c', true),          //「既存の取引先を名刺情報で上書きする」を表示する
    new ItemBuilder(3, 'RegistDispContactOverWriteCheckbox__c', 'RegistDispOverWriteCheckbox__c', true),          //「既存の取引先責任者を名刺情報で上書きする」を表示する
    // リード拡張 リード登録画面関連
    new ItemBuilder(3, 'RegistDispLeadOverWriteCheckbox__c', true),          //「既存のリードを名刺情報で上書きする」を表示する
    new ItemBuilder(3, 'RegistDispLeadRectype__c', 'SmartViscal__LeadRegist_DispLeadRectype__c', true),   // リードに登録 リードレコードタイプ選択を表示する  Lead EX  V1.11 から
        // 取引先登録:リードを名刺情報で上書きしない リードに登録 名刺情報で上書きする  反転させるので注意！
    new ItemBuilder(3, 'RegistLeadNotOverWrite__c', 'SmartViscal__LeadRegist_Overwrite__c', false),
    // リード拡張 キャンペーン適用用
    new ItemBuilder(3, 'ScanSelectCampaign__c', false),         // スキャン:キャンペーン選択を有効化
    // リード拡張 自動連携 リード登録関連
    new ItemBuilder(3, 'RenkeiLeadActive__c', false),           // 自動連携:リード登録機能を有効化
    new ItemBuilder(3, 'RenkeiLeadNOExistCreateNew__c', true),  // 自動連携:既存のリードがなければ新規作成
    new ItemBuilder(3, 'RenkeiLeadOverwrite__c', false),        // 自動連携:既存のリードを上書き  初期値：上書きしない!
    new ItemBuilder(3, 'RenkeiLeadRecordTypes__c', null),       // 自動連携:リードレコードタイプ
    new ItemBuilder(3, 'RenkeiActiveCampaignMember__c', false),  // 自動連携:スキャン時選択したキャンペーンのメンバーにする
    new ItemBuilder(3, 'RenkeiCampaignStatus__c', null),         // 自動連携:キャンペーンの状況
    new ItemBuilder(3, 'RenkeiLeadLastName__c', true),         // v2.0.2 自動連携:リード姓
    new ItemBuilder(3, 'RenkeiLeadFirstName__c', true),         // v2.0.2 自動連携:リード名
    new ItemBuilder(3, 'RenkeiLeadMail__c', true)         // v2.0.2 自動連携:リードメールアドレス


  };


  //// デフォルトのレコードを作る
  ////  既存の設定の移行はなし
  //public static NameCardBasicSetting__c createDefaultRecord() {
  //  NameCardBasicSetting__c result = new NameCardBasicSetting__c();
  //  SB_NameCard_BasicSettingBuilder instance = new SB_NameCard_BasicSettingBuilder();
  //  for (ItemBuilder ib : instance.itemBuilders) {
  //    ib.create(result);
  //  }
  //  result.Version__c = CURRENT_SETTING_VERSION;
  //  return result;
  //}

  // 名刺基本設定の項目のコレクション
  @TestVisible
  private Set<String> getValidFields() {
    Set<String> result = new Set<String>();
    for (Schema.SObjectField f : nameCardBasicSettingFields.values()) {
      Schema.DescribeFieldResult dfr = f.getDescribe();
      if (dfr.isCustom()) {
        result.add(dfr.getName());
      }
    }
    result.add('Id');
    result.add('Name');
    return result;
  }

  // 名刺基本設定のクエリ文字列
  @TestVisible
  private final String QUERY_FORM = 'SELECT {0} FROM NameCardBasicSetting__c ORDER BY CreatedDate ASC';

  // 新規作成 OR 最新バージョンへの更新
  public void upsertSetting() {
    // SmartVisca カスタム設定
    SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    // 名刺基本設定レコード取得
    Set<String> fields = getValidFields();
    String query = String.format(QUERY_FORM, new String[] { String.join(new List<String>(fields), ', ') });
    System.debug(query);
    List<NameCardBasicSetting__c> settings = Database.query(query);
    // 名刺基本設定レコード取得 がなければ 1レコード追加 ← 新規インストールのとき
    if (settings.isEmpty()) {
      NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
      settings.add(setting);
    }
    List<NameCardBasicSetting__c> targets = new List<NameCardBasicSetting__c>();
    // 名刺基本設定レコード をセットアップ
    for (NameCardBasicSetting__c setting : settings) {
      // 最新バージョンなら何もしない
      if (setting.Version__c != null && setting.Version__c >= CURRENT_SETTING_VERSION) {
        continue;
      }
      // 項目ごとの処理クラスへ
      for (ItemBuilder ib : itemBuilders) {
        ib.create(setting, svConfig);
      }
      // バージョン を最新にセット
      setting.Version__c = CURRENT_SETTING_VERSION;
      targets.add(setting);
    }
    if (targets.isEmpty()) {
      return;
    }
    // DML
    if (targets[0].Id == null) {
      // 新規
      SB_NameCard_CrudFls.screate(settings, true);
    }
    else {
      // カスタム設定があった場合だけ、移行してるので
      // 更新
      SB_NameCard_CrudFls.supdate(settings, true);
    }
  }

  // 外から呼ぶよう
  public static void run(String ns) {
    setNamespacePrefix(ns);
    SB_NameCard_BasicSettingBuilder instance = new SB_NameCard_BasicSettingBuilder();
    instance.upsertSetting();
  }

}