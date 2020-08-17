/**
 *
 *  SB_NCL_PostInstallScript
 *  リード拡張パッケージ用の インストール後に実行されるクラス
 *    連携マッピング用のオブジェクトにLEAD用のデフォルト値のレコードを作る。
 *
 *  @author sawano
 *  @Version 1      2018.01.xx
 *  lx v1.12    SV_DEV-1251 【カスタム設定】移行済みリード項目の値が反映されない。 → setupBasicSetting の追加
 *  lx v2.1     SV_DEV-1970 自動連携のリード関連「カスタム設定」項目の移行(リード連携拡張パッケージ側改修
 *
 **/
//global class SB_NCL_PostInstallScript {
global class SB_NCL_PostInstallScript implements InstallHandler {
  private SB_NameCard_CrudFlsInt crudFls;

  //// 基本設定の項目
  //@TestVisible
  private static final Map<String, Schema.SObjectField> nameCardBasicSettingFields
    = SMartViscaf__NameCardBasicSetting__c.getSObjectType().getDescribe().fields.getMap();

  // 基本パッケージの名前空間名
  public static String getNamespacePrefix_x() { return String.isEmpty(namespacePrefix) ? '' : namespacePrefix+'__'; }
  public static String getNamespacePrefix() { return namespacePrefix; }
  private static String namespacePrefix {
    get {
      if (namespacePrefix ==null) {
        list<ApexClass> classes = [select Name, NamespacePrefix from ApexClass where Name='SB_NC_PostInstallScript' limit 1];
        if (classes.isEmpty() == false) {
          namespacePrefix = classes[0].NamespacePrefix != null ? classes[0].NamespacePrefix : '';
        }
      }
      return namespacePrefix;
    }
    private set;
  }

  // 拡張パッケージの名前空間名
  public static String getExNamespacePrefix_x() { return String.isEmpty(exNamespacePrefix) ? '' : exNamespacePrefix+'__'; }
  public static String getExNamespacePrefix() { return exNamespacePrefix; }
  private static String exNamespacePrefix {
    get {
      if (exNamespacePrefix ==null) {
        list<ApexClass> classes = [select Name, NamespacePrefix from ApexClass where Name='SB_NCL_PostInstallScript' limit 1];
        if (classes.isEmpty() == false) {
          exNamespacePrefix = classes[0].NamespacePrefix != null ? classes[0].NamespacePrefix : '';
        }
      }
      return exNamespacePrefix;
    }
    private set;
  }



  // 2018.04.xx
  // カスタム設定の リード拡張の項目で デフォルトを変えたい項目  = リード v1.11 のときのデフォルト false では良くない項目  = リード登録用の項目
  private static final Map<String, Object> leadExCustomSettingFields = new Map<String, Object> {
    'SmartViscal__LeadRegist_RegistTodo__c' => true, // リードに登録 ToDo登録
    'SmartViscal__LeadRegist_DispEmail__c' => true, // リードに登録 メール表示
    'SmartViscal__LeadRegist_DispLeadRectype__c' => true, // リードに登録 リードレコードタイプ表示
    'SmartViscal__LeadRegist_DispCompany__c' => true, // リードに登録 会社名表示
    'SmartViscal__LeadRegist_DispLastModifiedDate__c' => true, // リードに登録 最終更新日表示
    'SmartViscal__LeadRegist_DispOwner__c' => true, // リードに登録 所有者表示
    'SmartViscal__LeadRegist_DispState__c' => true, // リードに登録 都道府県表示
    'SmartViscal__LeadRegist_Overwrite__c' => true, // リードに登録 名刺情報で上書きする
    'SmartViscal__LeadRegist_DispTitle__c' => true, // リードに登録 役職表示
    'SmartViscal__LeadRegist_DefaultShowLeadListNoExsiting__c' => true //リードまたは取引先へ登録の時両方とも既存存在しない場合のデフォルトリードを表示  v1.12 から
              // false から true に変更 2018.07.xx v2.0.2   SV_DEV-1004 ポストインストールスクリプト の リード用カスタム設定 「リードまたは取引先へ登録の時両方とも既存存在しない場合のデフォルトリードを表示」のデフォルト値が不正
  };

  // カスタム設定の リード拡張の項目で  デフォルト値を変える
  private void setLeadExDeafultValues(SmartViscaf__SmartViscaConfig__c svConfig) {
    // カスタム設定されている項目
    Map<String, Object> customConfigMap = svConfig.getPopulatedFieldsAsMap();
    // カスタム設定にある項目
    Map<String, Schema.SObjectField > fields = SmartViscaf__SmartViscaConfig__c.getSObjectType().getDescribe().fields.getMap();
    for (String f : leadExCustomSettingFields.keySet()) {
      Object val = customConfigMap.get(f);
      if (fields.containsKey(f) && val == null) {
        // カスタム設定にある項目 で 設定されてない項目
        svConfig.put(f, leadExCustomSettingFields.get(f));
      }
    }
  }

// カスタム設定がなかったら作る。
  // SV_DEV-285 ポストインストールスクリプトでカスタム設定「トリガで名刺履歴を保存する」をオンにする。トリガで名刺履歴を保存する TriggerHistoryIsActive__c
  public void setupSmartViscaConfig() {
    SmartViscaf__SmartViscaConfig__c svConfig = SmartViscaf__SmartViscaConfig__c.getOrgDefaults();
    // カスタム設定の リード拡張の項目で  デフォルト値を変える v2.0
    setLeadExDeafultValues(svConfig);
    List<SmartViscaf__SmartViscaConfig__c> records = new List<SmartViscaf__SmartViscaConfig__c>();
    records.add(svConfig);
    if (svConfig.Id != null) {
      // ないことはないので更新のみ処理する。
      this.crudFls.supdate(records, true);
    }
  }

  // 名刺基本設定がなかったら作る。
  // 開発コンソールで使えるように Static メソッド
  public void setupBasicSetting(InstallContext context) {
    if (context!=null && context.isUpgrade() && context.previousVersion().major() < 2) {
      // Lead Ex v1系からのアップデータだったら、Lead Exのカスタム設定の項目を 基本設定に移す
      // Lead Ex v2以降では、基本パッケージの方で移してるので、不要
      SB_NameCard_BasicSettingBuilder builder = new SB_NameCard_BasicSettingBuilder();
      builder.run();
    }
  }

  // 項目API名 について、必要なら 名前空間名を付与して返す用のクラス
  @TestVisible
  private class ApiNameResolver {
    Map<SObjectType, Map<String, Schema.SObjectField>> otype2Fields;
    public ApiNameResolver(Set<SObjectType> otypes) {
      this.otype2Fields = new Map<SObjectType, Map<String, Schema.SObjectField>>();
      for (SObjectType otype : otypes) {
        this.otype2Fields.put(otype, otype.getDescribe().fields.getMap());
      }
    }

    public String getProperApiName(SObjectType otype, String field) {
      Map<String, Schema.SObjectField> fields = this.otype2Fields.get(otype);
      if (fields.containsKey(field) ||
          (otype == SmartViscaf__NameCard__c.SObjectType && COMPLEX_FIELDS.containsKey(field))) {
        return field;
      }
      String ns = otype == Lead.sObjecttype ?  getExNamespacePrefix_x() : getNamespacePrefix_x();
      return ns + field;
    }
  } // private class ApiNameResolver

  //　連携マッピング用のオブジェクト(名刺連携項目マッピング)にデフォルト値のレコードを作る。
  //  SV_DEV-293 項目のマッピングの初期値はカスタムメタデータから読み込む
  // 開発コンソールで使えるように Static メソッド
  public void setupRenkeiMapping() {
    // 名刺連携項目マッピング  のレコードタイプ取得
    Map<String, Id> objName2RectypeId = new Map<String, Id>();
    // レコードタイプ名とそれがしめすオブジェクトのSObjectType のマップ
    Map<String, SObjectType> objName2OType = new Map<String, SObjectType>();
    List<Schema.RecordTypeInfo> rectypeInfos = SmartViscaf__NameCardRenkeiMapping__c.getSObjectType().getDescribe().getRecordTypeInfos();
    for (Schema.RecordTypeInfo rectypeInfo : rectypeInfos) {
      if (rectypeInfo.isMaster() ) {
        continue;
      }
      // 現在のユーザのアクセス権にかかわらず、存在するレコードタイプについて保持する。
      objName2RectypeId.put(rectypeInfo.getName().toLowerCase(), rectypeInfo.getRecordTypeId());
      SObjectType otype = Schema.getGlobalDescribe().get(rectypeInfo.getName());
      if (otype == null) {
        // 不正な マッピングオブジェクトの レコードタイプのラベル名
        continue;
      }
      objName2OType.put(rectypeInfo.getName().toLowerCase(), otype);
    }
    Set<SObjectType> otypes = new Set<SObjectType> { SmartViscaf__NameCard__c.SObjectType };
    otypes.addAll(objName2OType.values());
    ApiNameResolver nameResolver = new ApiNameResolver(otypes);
    // レコードタイプごとに既存のレコードがないか調べる
    // 2017.10.xx for code scan Queries With No Where Or Limit Clause
    Set<String> ignoreRecordTypes = new Set<String>();
    List<AggregateResult> ars = [SELECT Count(Id) cnt, RecordType.Name RecordTypeName FROM SmartViscaf__NameCardRenkeiMapping__c GROUP BY RecordType.Name LIMIT 1000];
    for (AggregateResult ar : ars) {
      String rname = (String)ar.get('RecordTypeName');
      Integer cnt = (Integer)ar.get('cnt');
      if (cnt != null && cnt > 0) {
        ignoreRecordTypes.add(rname.toLowerCase());
      }
    }
    //
    // 基本設定のレコードを取得  参照をセットするので、
    // 2017.10.xx for code scan Queries With No Where Or Limit Clause
    List<SmartViscaf__NameCardBasicSetting__c> settings = [SELECT Id, Name FROM SmartViscaf__NameCardBasicSetting__c ORDER BY CreatedDate ASC LIMIT 1];
    Id settingsId = null;
    if (!settings.isEmpty()) {
      settingsId  = settings[0].Id;
    }
    // デフォルト連携マッピング
    // 2017.10.xx for code scan Queries With No Where Or Limit Clause
    List<SmartViscaf__DefaultRenkeiMapping__mdt> defaults = [SELECT Id, SmartViscaf__TargetName__c, SmartViscaf__NameCardName__c, SmartViscaf__RecordType__c, SmartViscaf__IsActive__c
                FROM SmartViscaf__DefaultRenkeiMapping__mdt WHERE SmartViscaf__RecordType__c = 'Lead' LIMIT 1000];  // とりあえず、全部取ってきて、レコード対応名はあとで比較する。大文字小文字を区別しない比較をするため
    // 連携マッピング
    List<SmartViscaf__NameCardRenkeiMapping__c> records = new List<SmartViscaf__NameCardRenkeiMapping__c>();
    for (SmartViscaf__DefaultRenkeiMapping__mdt def : defaults) {
      if (ignoreRecordTypes.contains(def.SmartViscaf__RecordType__c.toLowerCase())) {
        // レコードタイプごとに既存のレコードがあれば、追加しない。
        continue;
      }
      Id rId = objName2RectypeId.get(def.SmartViscaf__RecordType__c.toLowerCase());
      String target = nameResolver.getProperApiName(objName2OType.get(def.SmartViscaf__RecordType__c.toLowerCase()), def.SmartViscaf__TargetName__c);
      String source = nameResolver.getProperApiName(SmartViscaf__NameCard__c.SObjectType, def.SmartViscaf__NameCardName__c);
      records.add(new SmartViscaf__NameCardRenkeiMapping__c(SmartViscaf__TargetName__c=target, SmartViscaf__NameCardName__c=source, RecordTypeId=rid, SmartViscaf__BasicSetting__c=settingsId));
    }
    if (!records.isEmpty()) {
      if (this.crudFls == null) {
        this.crudFls = new SB_NameCard_CrudFlsInt();
      }
      this.crudFls.screate(records, true);
    }
  }

  global void onInstall(InstallContext context) {
    this.crudFls = new SB_NameCard_CrudFlsInt();

    ////// 連携マッピング用のオブジェクトにデフォルト値のレコードを作る。
    //setupRenkeiMapping();

    //// カスタム設定のリード分を設定する
    //setupSmartViscaConfig();

    // 基本設定を作る。 先につくる。
    setupBasicSetting(context);

    // カスタム設定がなかったら作る。
    setupSmartViscaConfig();

    //// 連携マッピング用のオブジェクトにデフォルト値のレコードを作る。
    setupRenkeiMapping();
  }

  public static final Map<String, Set<String>> COMPLEX_FIELDS = new Map<String, Set<String>> {
    'last_name' => new Set<String> {'SmartViscaf__person_name_last__c', 'SmartViscaf__last_name__c'},
    'first_name' => new Set<String> {'SmartViscaf__person_name_first__c', 'SmartViscaf__first_name__c'},
    'city' => new Set<String> {'SmartViscaf__address__c', 'SmartViscaf__address_eng__c'},   // 市区郡
    'street' => new Set<String> {'SmartViscaf__address__c', 'SmartViscaf__address_eng__c', 'SmartViscaf__address_bld__c'},     // 町名・番地 建物名つき
    'pref_address_bld' => new Set<String> {'SmartViscaf__address_pref__c', 'SmartViscaf__address__c', 'SmartViscaf__address_eng__c', 'SmartViscaf__address_bld__c'},   // 都道府県 + 住所 + 建物名  2017.03.xx
    'address_bld' => new Set<String> {'SmartViscaf__address__c', 'SmartViscaf__address_eng__c', 'SmartViscaf__address_bld__c'},    // 住所 + 建物名  2017.03.xx
    'street_nobld' => new Set<String> {'SmartViscaf__address__c', 'SmartViscaf__address_eng__c'}          // 町名・番地  建物名なし  2017.03.xx
  };

  //
  //
  @TestVisible
  public virtual class ItemBuilder {
    public Integer since { get; private set; }    //  この項目が発生したバージョン
    public String field { get; private set; }     //
    public String sourceField { get; private set; }     // 移行する項目 カスタム設定  SmartViscaf__SmartViscaConfig__c か 基本設定オブジェクト SmartViscaf__NameCardBasicSetting__c の項目のどちらか。 （注意）重複するAPI名の項目はない前提
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
    public Object create(SmartViscaf__NameCardBasicSetting__c setting, SmartViscaf__SmartViscaConfig__c customConfig) {
      //if (setting.Id == null ||       // 新規レコード ＝ 新規インストール
      //  (setting.SmartViscaf__Version__c == null && this.since > 1) ||  // 名刺基本設定オブジェクトができれた最初のバージョンのレコード v1.19  に対して 以降に発生した項目をセット
      //  (setting.SmartViscaf__Version__c != null && this.since > setting.SmartViscaf__Version__c)) {  // v1.20 以降のレコード で そのレコードのバージョン以降に発生した項目をセット
      //  //Object prvVal = setting.get(this.field);    // 念のため NULL の項目にだけ値をセット
        if ((setting != null || customConfig != null) && String.isNotBlank(this.sourceField)) {
          Object val;
          //if (nameCardBasicSettingFields.containsKey(getNamespacePrefix_x() + this.sourceField) && setting != null) {
          //  System.debug(getNamespacePrefix_x() + this.sourceField);
          //  val = setting.get(getNamespacePrefix_x() + this.sourceField);    // SmartViscaf__NameCardBasicSetting__c から
          //}
          //else
          if (customConfig != null) {
            System.debug(this.sourceField);
            //val = customConfig.get(this.sourceField);     // カスタム設定 SmartViscaf__SmartViscaConfig__c から
            Map<String, Object> customConfigMap = customConfig.getPopulatedFieldsAsMap();
            val = customConfigMap.get(getExNamespacePrefix_x() + this.sourceField);
          }
          if (this.field == 'SmartViscaf__RegistLeadNotOverWrite__c' && val != null && val instanceOf Boolean) { // 項目によってはそのまま移行しない
            val = !(Boolean)val; // 反転
          }
          else {
            val = val == null ? this.defaultValue : val;      // NULLなら、デフォルト値
          }
          setting.put(this.field, val);
        }
      //  else if (this.defaultValue != null) {
      //    setting.put(this.field, this.defaultValue);
      //  }
      //}
      return setting.get(this.field);
    }
    //  カスタム設定からの移行はなく、単純にデフォルトのレコードを作る
    public Object create(SmartViscaf__NameCardBasicSetting__c setting) {
      if (this.defaultValue != null) {
        setting.put(this.field, this.defaultValue);
      }
      return setting.get(this.field);
    }

  }   // public virtual class ItemBuilder

  // 各項目の 発生バージョン と デフォルト値 を処理するクラス の テーブル
  @TestVisible
  private static List<ItemBuilder> SETTINGS_ITEMBUILDERS =  new List<ItemBuilder> {
    //// パッケージ v1.19 Version 1 最初 SmartViscaf__Version__c がないとき
    //new ItemBuilder(1, 'RenkeiAccountAddressPref__c', false),   // アカウント 都道府県
    //new ItemBuilder(1, 'RenkeiAccount_Street__c', false),   // アカウント 町名・番地
    //new ItemBuilder(1, 'RenkeiAccountZipCode__c', false),   // アカウント 郵便番号
    //new ItemBuilder(1, 'RenkeiAccountCity__c', false),      // アカウント 市区郡
    //new ItemBuilder(1, 'RenkeiAccountURL__c', false),       // アカウント URL
    //new ItemBuilder(1, 'RenkeiAccountCompany__c', true),   // アカウント 会社名
    //new ItemBuilder(1, 'RenkeiAccountPhone__c', false),     // アカウント 電話番号
    //new ItemBuilder(1, 'RenkeiSpecificItems__c', null),        // アカウント 特定項目
    //new ItemBuilder(1, 'RenkeiAccountSite__c', false),        // アカウント 部署名
    //new ItemBuilder(1, 'RenkeiExcludeHojinkakuPartial__c', true),      // 自動連携:会社名は法人格を除いて部分一致
    //new ItemBuilder(1, 'RenkeiExcludeHojinkaku__c', false),      // 自動連携:会社名は法人格を除いて完全一致
    //new ItemBuilder(1, 'RenkeiAccountSitePartialMatch__c', false),      // 自動連携:部署は中間一致検索
    //new ItemBuilder(1, 'RenkeiContactMail__c', true),      // コンタクト メールアドレス
    //new ItemBuilder(1, 'RenkeiContactLastName__c', true),  // コンタクト ラストネーム
    //new ItemBuilder(1, 'RenkeiContactFirstName__c', true), // コンタクト ファーストネーム
    //new ItemBuilder(1, 'RenkeiAccountQueryRecordTypeIds__c', null),    // 検索対象のレコードタイプタイプID カンマ区切り で羅列
    //new ItemBuilder(1, 'RenkeiContactQueryRecordTypeIds__c', null),  // 自動連携で検索対象の取引先責任者レコードタイプ
    //new ItemBuilder(1, 'RenkeiAccountOverwrite__c', false),   // 既存の取引先を上書き  初期値：上書きしない!
    //new ItemBuilder(1, 'RenkeiContactOverwrite__c', false),   // 既存の取引先責任者を上書き  初期値：上書きしない!
    //new ItemBuilder(1, 'RenkeiAccountNOExistCreateNew__c', true),  //既存の取引先がなければ新規作成する
    //new ItemBuilder(1, 'RenkeiContactNOExistCreateNew__c', true),  // 既存の取引先責任者がなければ新規作成する
    //new ItemBuilder(1, 'RenkeiAccountRecordTypes__c', null),     // 作成するアカウント の レコードタイプID １つ
    //new ItemBuilder(1, 'RenkeiContactRecordTypes__c', null),      // 作成するコンタクト の レコードタイプID １つ
    //// パッケージ v1.20 Version 2
    //new ItemBuilder(2, 'SaishinInheritValues__c', false),          //最新名刺は値を引継ぐ
    //new ItemBuilder(2, 'RegistNoToDo__c', 'ToDo__c', false), // 取引先・取引先任者に登録 ToDo登録しない
    //new ItemBuilder(2, 'RegistToDoSubject__c', 'ToDoName__c', Label.SB_NC_ExchangeCard), // 取引先・取引先任者に登録 ToDo件名
    //new ItemBuilder(2, 'RegistDispOverWriteCheckbox__c', true), // 取引先・取引先任者に登録 「上書きする」チェックボックスを表示する   → V3　から未使用 → 2つにわける
    //new ItemBuilder(2, 'RegistAccountNotOverWrite__c', 'AccountNotOverWrite__c', false), // 取引先・取引先任者に登録 取引先を名刺情報で上書きしない
    //new ItemBuilder(2, 'RegistContactNotOverWrite__c', 'ContactNotOverWrite__c', false), // 取引先・取引先任者に登録 取引先責任者を名刺情報で上書きしない
    //new ItemBuilder(2, 'RegistDispAccountRectype__c', 'DispAccountRectype__c', true), // 取引先・取引先任者に登録 取引先レコードタイプ選択を表示する
    //new ItemBuilder(2, 'RegistDispContactRectype__c', 'DispContactRectype__c', true), // 取引先・取引先任者に登録 取引先責任者レコードタイプ選択を表示する
    //// パッケージ v1.22 Version 3
    //// SV_DEV-582 取引先・取引先任者に登録 「上書きする」チェックボックスを表示する  → 2つにわける
    //new ItemBuilder(3, 'RegistDispAccountOverWriteCheckbox__c', 'RegistDispOverWriteCheckbox__c', true),          //「既存の取引先を名刺情報で上書きする」を表示する
    //new ItemBuilder(3, 'RegistDispContactOverWriteCheckbox__c', 'RegistDispOverWriteCheckbox__c', true)          //「既存の取引先責任者を名刺情報で上書きする」を表示する
    //// リード拡張 リード登録画面関連
    //new ItemBuilder(3, 'SmartViscaf__RegistDispLeadOverWriteCheckbox__c', true),          //「既存のリードを名刺情報で上書きする」を表示する
    new ItemBuilder(3, 'SmartViscaf__RegistDispLeadRectype__c', 'LeadRegist_DispLeadRectype__c', true),   // リードに登録 リードレコードタイプ選択を表示する  Lead EX  V1.11 から
    //    // 取引先登録:リードを名刺情報で上書きしない リードに登録 名刺情報で上書きする  反転させるので注意！
    new ItemBuilder(3, 'SmartViscaf__RegistLeadNotOverWrite__c', 'LeadRegist_Overwrite__c', false),
    //// リード拡張 キャンペーン適用用
    //new ItemBuilder(3, 'ScanSelectCampaign__c', false),         // スキャン:キャンペーン選択を有効化
    //// リード拡張 自動連携 リード登録関連
    //new ItemBuilder(3, 'RenkeiLeadActive__c', false),           // 自動連携:リード登録機能を有効化
    //new ItemBuilder(3, 'RenkeiLeadNOExistCreateNew__c', true),  // 自動連携:既存のリードがなければ新規作成
    //new ItemBuilder(3, 'RenkeiLeadOverwrite__c', false),        // 自動連携:既存のリードを上書き  初期値：上書きしない!
    //new ItemBuilder(3, 'RenkeiLeadRecordTypes__c', null),       // 自動連携:リードレコードタイプ
    //new ItemBuilder(3, 'RenkeiActiveCampaignMember__c', false),  // 自動連携:スキャン時選択したキャンペーンのメンバーにする
    //new ItemBuilder(3, 'RenkeiCampaignStatus__c', null),         // 自動連携:キャンペーンの状況
    //// SV_DEV-1244 SV_DEV-1168 【リード自動連携】SmartVisca 基本設定「自動連携:リード姓」がデフォルトでチェックが入っていない。
    //// v2.0.3　v2.0.2 でSB_NameCard_BasicSettingBuilder にいれたけど、インナークラスの SB_NameCard_BasicSettingBuilder を使ってるので、こっちにいれないといけなかった
    //new ItemBuilder(3, 'RenkeiLeadLastName__c', true),         // v2.0.3 自動連携:リード姓
    //new ItemBuilder(3, 'RenkeiLeadFirstName__c', true),         // v2.0.3 自動連携:リード名
    //new ItemBuilder(3, 'RenkeiLeadMail__c', true)         // v2.0.3 自動連携:リードメールアドレス
    // パッケージ v2.1 Version 4
    new ItemBuilder(4,'SmartViscaf__RenkeiCreateContactOnAcountWithLead__c','RenkeiCreateContactOnAcountWithLead__c',false),        // 自動連携:リード、取引先既存で取引先責任者を作成する
    new ItemBuilder(4,'SmartViscaf__RenkeiCreateContactOnAcountWithoutLead__c','RenkeiCreateContactOnAcountWithoutLead__c',false),  // 自動連携:リードなく、取引先既存で取引先責任者を作成する
    new ItemBuilder(4,'SmartViscaf__RenkeiCreateLeadOnTooManyAccounts__c','RenkeiCreateLeadOnTooManyAccounts__c',false),            // 自動連携:既存取引先が複数あり特定できないとき、リードを作る
    new ItemBuilder(4,'SmartViscaf__RenkeiUpdateAllLeadsOnCondition__c','RenkeiUpdateAllLeadsOnCondition__c',false),                // 自動連携:条件に合致する既存リードは全て更新する
    new ItemBuilder(4,'SmartViscaf__RegistLeadNoToDo__c','LeadRegist_RegistTodo__c',false),                                         // 取引先登録:リードToDo登録しない
    new ItemBuilder(4,'SmartViscaf__RegistLeadToDoSubject__c','LeadRegist_TodoSubject__c',Label.SmartViscaf.SB_NC_ExchangeCard)     // 取引先登録:リードToDo件名
  };

  // V1.20 => 2 から始めます。
  // V1.21 => 3
  // V2.1  => 4
  @TestVisible
  private static final Integer CURRENT_SETTING_VERSION = 4;  // 2020.01.xx v2.1

  @TestVisible
  private class SB_NameCard_BasicSettingBuilder {

    private SB_NameCard_CrudFlsInt crudFls;

    public SB_NameCard_BasicSettingBuilder() {
      this.crudFls = new SB_NameCard_CrudFlsInt();
    }

    //// デフォルトのレコードを作る
    //public static SmartViscaf__NameCardBasicSetting__c createDefaultRecord() {
    //  SmartViscaf__NameCardBasicSetting__c result = new SmartViscaf__NameCardBasicSetting__c();
    //  SB_NameCard_BasicSettingBuilder instance = new SB_NameCard_BasicSettingBuilder();
    //  for (ItemBuilder ib : instance.SETTINGS_ITEMBUILDERS) {
    //    ib.create(result);
    //  }
    //  return result;
    //}

    // 名刺基本設定の項目のコレクション
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

    // 新規作成 OR 最新バージョンへの更新
    public void upsertSetting() {
      // SmartVisca カスタム設定
      SmartViscaf__SmartViscaConfig__c svConfig = SmartViscaf__SmartViscaConfig__c.getOrgDefaults();
      // 名刺基本設定レコード取得
      Set<String> fields = getValidFields();
      String query = String.format('SELECT {0} FROM SmartViscaf__NameCardBasicSetting__c ORDER BY CreatedDate ASC',
                    new String[] { String.join(new List<String>(fields), ', ') });
      System.debug(query);
      List<SmartViscaf__NameCardBasicSetting__c> settings = Database.query(query);
      // 名刺基本設定レコード取得 がなければ 1レコード追加 ← 新規インストールのとき
      if (settings.isEmpty()) {
        SmartViscaf__NameCardBasicSetting__c setting = new SmartViscaf__NameCardBasicSetting__c();
        settings.add(setting);
      }
      List<SmartViscaf__NameCardBasicSetting__c> targets = new List<SmartViscaf__NameCardBasicSetting__c>();
      // 名刺基本設定レコード をセットアップ
      for (SmartViscaf__NameCardBasicSetting__c setting : settings) {
        //// 最新バージョンなら何もしない
        //if (setting.SmartViscaf__Version__c != null && setting.SmartViscaf__Version__c >= CURRENT_SETTING_VERSION) {
        //  continue;
        //}
        // 項目ごとの処理クラスへ
        for (ItemBuilder ib : SETTINGS_ITEMBUILDERS) {
          ib.create(setting, svConfig);
        }
        //// バージョン を最新にセット
        //setting.SmartViscaf__Version__c = CURRENT_SETTING_VERSION;
        targets.add(setting);
      }
      if (targets.isEmpty()) {
        return;
      }
      // DML
      if (targets[0].Id == null) {
        // 新規
        this.crudFls.screate(settings, true);
      }
      else {
        // カスタム設定があった場合だけ、移行してるので
        // 更新
        this.crudFls.supdate(settings, true);
      }
    }

    // 外から呼ぶよう
    public void run() {
      SB_NameCard_BasicSettingBuilder instance = new SB_NameCard_BasicSettingBuilder();
      instance.upsertSetting();
    }

  }

  // デフォルトのレコードを作る
  //  既存の設定の移行はなし
  global static SmartViscaf__NameCardBasicSetting__c createDefaultBasicSetting() {
    SmartViscaf__NameCardBasicSetting__c result = new SmartViscaf__NameCardBasicSetting__c();
    for (ItemBuilder ib : SETTINGS_ITEMBUILDERS) {
      ib.create(result);
    }
    result.SmartViscaf__Version__c = CURRENT_SETTING_VERSION;
    return result;
  }

  // +------------- SB_NameCard_CrudFlsInt -------------+
  public class CrudFlsException extends exception {}
  @TestVisible
  private class SB_NameCard_CrudFlsInt {

    // そもそも オブジェクトが内部処理用なので、ユーザの権限に依存しないもの
    private Set<Schema.SObjectType> ignoreObjects {
      get {
        if (ignoreObjects == null) {
          ignoreObjects  = new Set<Schema.SObjectType> {
            User.sObjectType          // ユーザ
            , SmartViscaf__SmartViscaConfig__c.sObjectType   // SVカスタム設定
            //    , Schema.getGlobalDescribe().get('Lead')
          };
        }
        return ignoreObjects;
      }
      Set;
    }

    // 入力のあった項目API名を抽出する。
    @TestVisible
    private Set<String> getCheckFields(List<SObject> os) {
      Set<String> result = new Set<String>();
      for (SObject o : os) {
        result.addAll(o.getPopulatedFieldsAsMap().keySet());
      }
      return result;
    }

    // CRDU FLS チェック付き 作成
    public void screate(List<SObject> os, Boolean opt_allOrNone) {
      if (os == null || os.size() == 0){
        return;
      }
      Database.DMLOptions dml = new Database.DMLOptions();
      dml.OptAllOrNone = opt_allOrNone;
      screate(os, dml);

    }

    // CRDU FLS チェック付き 作成
    // DMLOptions指定、結果を返す。 重複管理用で追加
    public List<Database.SaveResult> screate(List<SObject> os, Database.DMLOptions dml) {
      if (os == null || os.isEmpty()) {
        return null;
      }
      if (ignoreObjects.contains(os[0].getSObjectType()) == false) {
        // Get Describe Result of the SObject
        Schema.SObjectType targetType = os[0].getSObjectType();
        Schema.DescribeSObjectResult sobjResult = targetType.getDescribe();
        // オブジェクト作成権限があるか
        if (!sobjResult.isCreateable()) {
          throw new CrudFlsException(String.format(Label.SB_MSG_CrudNotCreateable, new String[] {sobjResult.label}));
        }

        Map<string, Schema.SObjectField> m = sobjResult.fields.getMap();
        Set<String> keys = getCheckFields(os);    // 入力のあった項目s
        // 入力のあった項目が作成可能でないと例外
        for (String key : keys) {
          // String k = key.removeStart(namespace);   // SVのカスタム項目だとネームスペースがついてるので、とる  -> 37.0あたりでは不要        Schema.` descField = m.get(key).getDescribe();
          Schema.DescribeFieldResult descField = m.get(key).getDescribe();
          if (descField.getType() != DisplayType.location        // 2015.01.22  Location 型は isCreateable() とかでエラーになる。
            && descField.isPermissionable()           // 権限設定出来る項目だけ
            && descField.isCreateable() == false      // 作成可能?
            && descField.isAutoNumber() == false      // 自動採番?
            && descField.isCalculated() == false) {   // 数式?
              throw new CrudFlsException(String.format(Label.SmartViscaf.SB_MSG_FlsNotCreateable,
                                        new String[] {sobjResult.label, descField.getLabel(), descField.getName()}));
          }
        }
      }

      // INSERT
      List<Database.SaveResult> sr = Database.insert(os, dml);
      return sr;
    }

    // CRDU FLS チェック付き 更新
    public void supdate(List<SObject> os, Boolean opt_allOrNone){
      if (os == null || os.isEmpty()) {
        return;
      }
      Database.DMLOptions dml = new Database.DMLOptions();
      dml.OptAllOrNone = opt_allOrNone;
      supdate(os, dml);
    }

    // CRDU FLS チェック付き 更新
    // DMLOptions指定、結果を返す。 重複管理用で追加
    public List<Database.SaveResult> supdate(List<SObject> os, Database.DMLOptions dml) {
      if (os == null || os.isEmpty()) {
        return null;
      }

      if (ignoreObjects.contains(os[0].getSObjectType()) == false) {
        Schema.SObjectType targetType = os[0].getSObjectType();
        Schema.DescribeSObjectResult sobjResult = targetType.getDescribe();
        // オブジェクトの編集権限があるか
        if (!sobjResult.isUpdateable()) {
          throw new CrudFlsException(String.format(Label.SmartViscaf.SB_MSG_CrudNotUpdateable, new String[] {sobjResult.label}));
        }

        Map<string, Schema.SObjectField> m = sobjResult.fields.getMap();

        Set<String> keys = getCheckFields(os);    // 入力のあった項目s
        // 入力のあった項目が編集可能でないと例外
        for (String key : keys) {
          // String k = key.removeStart(namespace);   // SVのカスタム項目だとネームスペースがついてるので、とる  -> 37.0あたりでは不要
          Schema.DescribeFieldResult descField = m.get(key).getDescribe();
          if (descField.getType() != DisplayType.location         // 2015.01.22  Location 型は isCreateable() とかでエラーになる。
            && descField.isPermissionable()       // 権限設定出来る項目だけ
            && descField.isUpdateable() == false      // 更新可能？
            && descField.isAutoNumber() == false      // 自動採番?
            && descField.isCalculated() == false) {   // 数式?
              throw new CrudFlsException(String.format(Label.SmartViscaf.SB_MSG_FlsNotUpdateable,
                                        new String[] {sobjResult.label, descField.getLabel(), descField.getName()}));
          }
        }
      }

      List<Database.SaveResult> sr = Database.update(os, dml);
      return sr;
    }
  } // private class SB_NameCard_CrudFlsInt

}