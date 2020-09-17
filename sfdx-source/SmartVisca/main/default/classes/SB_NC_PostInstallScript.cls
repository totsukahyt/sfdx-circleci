/**
 *
 *  SB_NC_PostInstallScript
 *  インストール後に実行されるクラス
 *    カスタム設定を作る。
 *    連携マッピング用のオブジェクトにデフォルト値のレコードを作る。
 *
 *  @author sawano
 *  @Version 1      2017.01.xx
 *  @Version 2      2017.05.xx SV_DEV-414 カスタム設定の整理 対応
 *  @Version 3      2017.10.xx  with sharing, CRUD FLS  v1.21 for code scan だけど、インストールで「インストール後スクリプトが失敗しました。」になる
 *  @Version 4      2017.10.xx  他の with sharing のクラスを InstallHandler でコールするろとアクセスエラーになる。
 *                                -> SB_NameCard_CrudFls、SB_NameCard_Util とかは使えない
 *                               このクラス自体は with sharing をやめてもCode Scanはパスする
 *  @Version 5      2018.04.xx v2.0  カスタム設定の リード拡張の項目で  デフォルト値を変える
 *  @Version 6      2018.07.xx v2.0.2 SV_DEV-1004 ポストインストールスクリプト の リード用カスタム設定 「リードまたは取引先へ登録の時両方とも既存存在しない場合のデフォルトリードを表示」のデフォルト値が不正
 *  @Version 7      2018.09.05 v2.0.3 SV_DEV-1128 SmartVisca2.0.2へアップデートした場合に自動連携処理が行われなくなる。
 *  v2.0.3          2018.10.xx SV_DEV-1244 SV_DEV-1168 【リード自動連携】SmartVisca 基本設定「自動連携:リード姓」がデフォルトでチェックが入っていない。
 *  v2.4            2019.07.xx SV_DEV-463 SV_DEV-1634 SV_DEV-1901 新規カスタム設定に関する初期値設定処理の追加
 *  v2.4.1          2019.10.xx SV_DEV-2194 インストール/アップデート操作時はNameCardBasicSettingのトリガで実行している入力チェックをスキップする
 *  v2.5            2020.01.xx SV_DEV-2178 ポストインストールスクリプトで発生した例外をキャッチして通知する。
 *                  2020.03.xx ↑メール送信が機能しないためSF問い合わせ中、SFの仕様か不具合(修正見込みが立つ？)か不明なため一旦コメントアウト
 *                  2020.04.XX SV_DEV-2390 取引先登録:リードToDo件名の初期値設定処理を追加
 *
 *    注）Code Scan でwith sharing でないといわれれて、つけると、インストールで 「エラーメッセージ: インストール後スクリプトが失敗しました。」となるので、つけれない。
 *
 *
 **/
global class SB_NC_PostInstallScript implements InstallHandler {
  private SB_NameCard_CrudFlsInt crudFls;
  public static Boolean isInstall = false;  // インストール/アップデート時:true

  // 基本設定の項目
  @TestVisible
  private static final Map<String, Schema.SObjectField > nameCardBasicSettingFields
    = NameCardBasicSetting__c.getSObjectType().getDescribe().fields.getMap();

  public static String getNamespacePrefix_x() { return String.isEmpty(namespacePrefix) ? '' : namespacePrefix+'__'; }
  public static String getNamespacePrefix() { return namespacePrefix; }
  private static String namespacePrefix {
    get {
      if (namespacePrefix ==null) {
        list<ApexClass> classes = [select Name, NamespacePrefix from ApexClass where Name='SB_NC_PostInstallScript' limit 1];
        if (classes.isEmpty() == false)
        namespacePrefix = classes[0].NamespacePrefix != null ? classes[0].NamespacePrefix : '';
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
  private void setLeadExDeafultValues(SmartViscaConfig__c svConfig) {
    // カスタム設定されている項目
    Map<String, Object> customConfigMap = svConfig.getPopulatedFieldsAsMap();
    // カスタム設定にある項目
    Map<String, Schema.SObjectField > fields = SmartViscaConfig__c.getSObjectType().getDescribe().fields.getMap();
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
  // SV_DEV-1634 SmartVisca設定タブの自動連携に関する設定の表示/非表示を切り替えるカスタム設定を作る DispRenkeiSetting__c
  // SV_DEV-463 名寄せ条件のカスタマイズ TriggerMergeExpandCriteria__c
  public void setupSmartViscaConfig() {
    SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    //this.svConfig = SmartViscaConfig__c.getOrgDefaults();
    List<SmartViscaConfig__c> records = new List<SmartViscaConfig__c>();
    if (svConfig.Id == null) {
      svConfig.TriggerHistoryIsActive__c = true;
      svConfig.DispRenkeiSetting__c = false;
      svConfig.TriggerMergeExpandCriteria__c = false;
      // カスタム設定の リード拡張の項目で  デフォルト値を変える v2.0
      setLeadExDeafultValues(svConfig);
      // 2017.10.xx  CRUD FLS  v1.21 for code scan
      records.add(svConfig);
      this.crudFls.screate(records, true);
    }
    else {
      // 2018.03.xx v1.22 追加の項目について デフォルト値をセットする
      // SV_DEV-807 1.22（ベータ版）にアップデートした場合に自動連携機能が動作しない。 上書きインストールのとき追加項目はデフォルト値でなくNULLの模様
      // 2018.09.05 v2.0.3 SV_DEV-1128 SmartVisca2.0.2へアップデートした場合に自動連携処理が行われなくなる。
      // 2019.03.29 v2.2.1 SV_DEV-1523 モバイル 新UI アップデート時に「SSmartViscaカメラで所有者選択を有効にする」のデフォルトがオフになっている。
      // 2019.07.XX v2.4   SV_DEV-1634 自動連携に関する設定を表示 v2.4以前のパッケージインストール済み組織についてはデフォルト値をオンで設定
      // 2019.07.XX v2.4   SV_DEV-463 名寄せ条件のカスタマイズ 初期値オフ
      svConfig.TriggerRenkeiTriggerHandler__c = svConfig.get('TriggerRenkeiTriggerHandler__c') == null ? true : svConfig.TriggerRenkeiTriggerHandler__c;  // Call Auto Conversion Trigger デフォルト値で更新する。
      svConfig.TriggerLeadExRenkeiTriggerHandler__c = svConfig.get('TriggerLeadExRenkeiTriggerHandler__c') == null ? false : svConfig.TriggerLeadExRenkeiTriggerHandler__c;  // Call LeadEx Auto Conversion Trigger デフォルト値で更新する。
      svConfig.SCameraEnableOwnerSelect__c = svConfig.get('SCameraEnableOwnerSelect__c') == null ? True : svConfig.SCameraEnableOwnerSelect__c;
      svConfig.DispRenkeiSetting__c = svConfig.get('DispRenkeiSetting__c') == null ? True : svConfig.DispRenkeiSetting__c;
      svConfig.TriggerMergeExpandCriteria__c = svConfig.get('TriggerMergeExpandCriteria__c') == null ? false : svConfig.TriggerMergeExpandCriteria__c;
      // カスタム設定の リード拡張の項目で  デフォルト値を変える v2.0
      setLeadExDeafultValues(svConfig);
      records.add(svConfig);
      this.crudFls.supdate(records, true);
    }

  }

  // 名刺基本設定がなかったら作る。
  // 開発コンソールで使えるように Static メソッド
  public void setupBasicSetting() {
    SB_NameCard_BasicSettingBuilder builder = new SB_NameCard_BasicSettingBuilder();
    builder.run();
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
          (otype == NameCard__c.SObjectType && COMPLEX_FIELDS.containsKey(field))) {
        return field;
      }
      return getNamespacePrefix_x() + field;
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
    List<Schema.RecordTypeInfo> rectypeInfos = NameCardRenkeiMapping__c.getSObjectType().getDescribe().getRecordTypeInfos();
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
    Set<SObjectType> otypes = new Set<SObjectType> { NameCard__c.SObjectType };
    otypes.addAll(objName2OType.values());
    ApiNameResolver nameResolver = new ApiNameResolver(otypes);
    // レコードタイプごとに既存のレコードがないか調べる
    // 2017.10.xx for code scan Queries With No Where Or Limit Clause
    Set<String> ignoreRecordTypes = new Set<String>();
    List<AggregateResult> ars = [SELECT Count(Id) cnt, RecordType.Name RecordTypeName FROM NameCardRenkeiMapping__c GROUP BY RecordType.Name LIMIT 100];
    for (AggregateResult ar : ars) {
      String rname = (String)ar.get('RecordTypeName');
      Integer cnt = (Integer)ar.get('cnt');
      if (cnt != null && cnt > 0) {
        ignoreRecordTypes.add(rname.toLowerCase());
      }
    }
    // 基本設定のレコードを取得  参照をセットするので、
    // 2017.10.xx for code scan Queries With No Where Or Limit Clause
    List<NameCardBasicSetting__c> settings = [SELECT Id, Name FROM NameCardBasicSetting__c ORDER BY CreatedDate ASC LIMIT 1];
    Id settingsId = null;
    if (!settings.isEmpty()) {
      settingsId  = settings[0].Id;
    }
    // デフォルト連携マッピング
    // 2017.10.xx for code scan Queries With No Where Or Limit Clause
    List<DefaultRenkeiMapping__mdt> defaults = [SELECT Id, TargetName__c, NameCardName__c, RecordType__c, IsActive__c
                FROM DefaultRenkeiMapping__mdt LIMIT 1000];  // とりあえず、全部取ってきて、レコード対応名はあとで比較する。大文字小文字を区別しない比較をするため
    // 連携マッピング
    List<NameCardRenkeiMapping__c> records = new List<NameCardRenkeiMapping__c>();
    for (DefaultRenkeiMapping__mdt def : defaults) {
      if (ignoreRecordTypes.contains(def.RecordType__c.toLowerCase())) {
        // レコードタイプごとに既存のレコードがあれば、追加しない。
        continue;
      }
      Id rId = objName2RectypeId.get(def.RecordType__c.toLowerCase());
      String target = nameResolver.getProperApiName(objName2OType.get(def.RecordType__c.toLowerCase()), def.TargetName__c);
      String source = nameResolver.getProperApiName(NameCard__c.SObjectType, def.NameCardName__c);
      records.add(new NameCardRenkeiMapping__c(TargetName__c=target, NameCardName__c=source, RecordTypeId=rid, BasicSetting__c=settingsId));
    }
    if (!records.isEmpty()) {
      this.crudFls.screate(records, true);
    }
  }

  // カスタム設定がなかったら作る。
  public void setupSmartViscaUserConfig() {
    SmartViscaUserConfig__c svuConfig = SmartViscaUserConfig__c.getOrgDefaults();
    List<SmartViscaUserConfig__c> records = new List<SmartViscaUserConfig__c>();
    if (svuConfig.Id == null) {
      svuConfig.SvcRepeatMemo__c = true;
      svuConfig.SvcRepeatExchangeDate__c = true;
      svuConfig.SvcShadeFilter__c = false;
      svuConfig.SvcKeepListName__c = true;
      svuConfig.SvcFreehandMemo__c = false;
      svuConfig.SvcFrontOnly__c = false;

      svuConfig.SvcDoubleSide__c = true;
      svuConfig.SvcImageTransform__c = true;
      svuConfig.SvcConfirmTransform__c = true;
      svuConfig.SvcShowTranslateFailure__c = false;
      svuConfig.SvcNoiseFilter__c = false;
      svuConfig.SvcGabageFilter__c = false;
      // 2017.10.xx  CRUD FLS  v1.21 for code scan
      records.add(svuConfig);
      this.crudFls.screate(records, true);
    }
    else {
      // 移行する設定があったら定義する
      // records.add(svuConfig);
      // this.crudFls.supdate(records, true);
    }
  }

  global void onInstall(InstallContext context) {
    this.crudFls = new SB_NameCard_CrudFlsInt();
    isInstall = true;
    try{
      // 基本設定を作る。 先につくる。
      setupBasicSetting();

      // カスタム設定がなかったら作る。
      setupSmartViscaConfig();

      //// 連携マッピング用のオブジェクトにデフォルト値のレコードを作る。
      setupRenkeiMapping();
      //// バッチのスケジュール
      //if (context.previousVersion() == null) {    //以前のバージョンが null である場合、つまりパッケージが初めてインストールされている場合
      //}
      // SmartViscaユーザ設定なかったら作る。
      setupSmartViscaUserConfig();
    }catch(Exception e){
      // SV_DEV-2178 インストールエラー時には原因を記載したメールをインストール操作実施ユーザに送信する
      // 2020.03.27 メール送信が行われないためSF問い合わせ中、仕様か不具合か判明するまで一旦コメントアウト
      // if ( context != null ){
      //   User u = [Select Id, Email from User where Id =:context.installerId()];   
      //   String toAddress= u.Email;
      //   String[] toAddresses = new String[]{toAddress};
      //   Messaging.SingleEmailMessage mail = 
      //     new Messaging.SingleEmailMessage();
      //   mail.setToAddresses(toAddresses);
      //   mail.setReplyTo(Label.SB_MSG_InstallErrMailReplyTo);
      //   mail.setSenderDisplayName(Label.SB_MSG_InstallErrMailSenderDisplayName);
      //   mail.setSubject(Label.SB_MSG_InstallErrMailSubject);
      //   mail.setPlainTextBody(String.format(Label.SB_MSG_InstallErrMailBody,
      //                                   new String[] {e.getMessage()}));
      //   Messaging.sendEmail(new Messaging.Email[] { mail });
      // }
      throw e;
    }
  }

  //private class SB_NameCard_RenkeiMapper {
    public static final Map<String, Set<String>> COMPLEX_FIELDS = new Map<String, Set<String>> {
      'last_name' => new Set<String> {'person_name_last__c', 'last_name__c'},
      'first_name' => new Set<String> {'person_name_first__c', 'first_name__c'},
      'city' => new Set<String> {'address__c', 'address_eng__c'},   // 市区郡
      'street' => new Set<String> {'address__c', 'address_eng__c', 'address_bld__c'},     // 町名・番地 建物名つき
      'pref_address_bld' => new Set<String> {'address_pref__c', 'address__c', 'address_eng__c', 'address_bld__c'},   // 都道府県 + 住所 + 建物名  2017.03.xx
      'address_bld' => new Set<String> {'address__c', 'address_eng__c', 'address_bld__c'},    // 住所 + 建物名  2017.03.xx
      'street_nobld' => new Set<String> {'address__c', 'address_eng__c'}          // 町名・番地  建物名なし  2017.03.xx
    };
  //}


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
            if (customConfigMap.containsKey(getNamespacePrefix_x() + this.sourceField)){
              val = customConfigMap.get(getNamespacePrefix_x() + this.sourceField);
            }
            //リード連携拡張パッケージ用のカスタム設定引き継ぎ
            else if (customConfigMap.containsKey(getExNamespacePrefix_x() + this.sourceField)){
              val = customConfigMap.get(getExNamespacePrefix_x() + this.sourceField);
            }
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
  private static List<ItemBuilder> SETTINGS_ITEMBUILDERS =  new List<ItemBuilder> {
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
    // SV_DEV-1244 SV_DEV-1168 【リード自動連携】SmartVisca 基本設定「自動連携:リード姓」がデフォルトでチェックが入っていない。
    // v2.0.3　v2.0.2 でSB_NameCard_BasicSettingBuilder にいれたけど、インナークラスの SB_NameCard_BasicSettingBuilder を使ってるので、こっちにいれないといけなかった
    new ItemBuilder(4, 'RenkeiLeadLastName__c', true),         // v2.0.3 自動連携:リード姓
    new ItemBuilder(4, 'RenkeiLeadFirstName__c', true),        // v2.0.3 自動連携:リード名
    new ItemBuilder(4, 'RenkeiLeadMail__c', true),             // v2.0.3 自動連携:リードメールアドレス
    // 2019.09.XX v2.4   SV_DEV-1901 法人格の略称を正称の表記とみなして会社名を比較する 初期値オフ
    new ItemBuilder(5, 'HojinkakuEquationLongAndAbbr__c', false), // v2.4 法人格の略称を正称の表記とみなして会社名を比較する
    // 2020.04.XX v2.5   SV_DEV-2390 取引先登録:リードToDo件名の初期値設定処理
    new ItemBuilder(6, 'RegistLeadToDoSubject__c', 'LeadRegist_TodoSubject__c', Label.SB_NC_ExchangeCard), // 取引先登録:リードToDo件名
    new ItemBuilder(6, 'RegistLeadToDoOwner__c', Label.SB_NC_LeadToDoOwner)  // 取引先登録:リードToDoの任命先
  };

  // V1.20 => 2 から始めます。
  // V1.21 => 3
  // V2.0  => 4
  // V2.4  => 5
  // V2.5  => 6
  @TestVisible
  private static final Integer CURRENT_SETTING_VERSION = 6;  // 3: 2017.12.xx v1.22 4: 2018.10.xx v2.0 5: 2019.09.XX v2.4 6: 2020.04.XX v2.5 

  @TestVisible
  private class SB_NameCard_BasicSettingBuilder {

    private SB_NameCard_CrudFlsInt crudFls;

    public SB_NameCard_BasicSettingBuilder() {
      this.crudFls = new SB_NameCard_CrudFlsInt();
    }

    //// デフォルトのレコードを作る
    //public static NameCardBasicSetting__c createDefaultRecord() {
    //  NameCardBasicSetting__c result = new NameCardBasicSetting__c();
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
      SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
      // 名刺基本設定レコード取得
      Set<String> fields = getValidFields();
      String query = String.format('SELECT {0} FROM NameCardBasicSetting__c ORDER BY CreatedDate ASC',
                    new String[] { String.join(new List<String>(fields), ', ') });
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
        for (ItemBuilder ib : SETTINGS_ITEMBUILDERS) {
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
  global static NameCardBasicSetting__c createDefaultBasicSetting() {
    NameCardBasicSetting__c result = new NameCardBasicSetting__c();
    for (ItemBuilder ib : SETTINGS_ITEMBUILDERS) {
      ib.create(result);
    }
    result.Version__c = CURRENT_SETTING_VERSION;
    return result;
  }


  public class CrudFlsException extends exception {}
  private class SB_NameCard_CrudFlsInt {

    // // パッチリリースでは、カスタム表示ラベルが追加できないので、
    // private static final String SB_MSG_CrudNotCreateable = '{0} オブジェクトの作成権限がありません。';
    // private static final String SB_MSG_CrudNotUpdateable ='{0} オブジェクトの編集権限がありません。';
    // private static final String SB_MSG_FlsNotCreateable = '{0} オブジェクトの項目 {1} ({2}) の作成権限がありません。';
    // private static final String SB_MSG_FlsNotUpdateable = '{0} オブジェクトの項目 {1} ({2}) の編集権限がありません。';
    //
    // // private static String namespace = SB_NameCard_Util.getNamespacePrefix_x();

    // そもそも オブジェクトが内部処理用なので、ユーザの権限に依存しないもの
    private Set<Schema.SObjectType> ignoreObjects {
      get {
        if (ignoreObjects == null) {
          ignoreObjects  = new Set<Schema.SObjectType> {
            User.sObjectType          // ユーザ
            , SmartViscaConfig__c.sObjectType   // SVカスタム設定
            //    , Schema.getGlobalDescribe().get('Lead')
          };
        }
        return ignoreObjects;
      }
      Set;
    }

    // SV_DEV-164 リードの「名刺で更新」時にリードの住所項目の編集権限がない場合のエラーメッセージが「リード オブジェクトの項目 郵便番号 (PostalCode) の編集権限がありません。」
    //
    // 住所複合項目は個々の項目でなく 住所でアクセス権を設定するので、 住所項目として 例外を表示しようとしたけど 実行中のコードでは 住所複合項目 の DescribeFieldResult はとれない！
    // 項目をアクセス権の設定単位に読み替えるためのマッピング
    //private static final Map<String, String> NMAE2SWITCHEDNAME = new Map<String, String> {
    //  // リードの住所用
    //  'country' => 'Address',
    //  'postalcode' => 'Address',
    //  'state' => 'Address',
    //  'city' => 'Address',
    //  'street' => 'Address',
    //  // 取引先の住所用 請求先
    //  'billingcountry' => 'BillingAddress',
    //  'billingpostalcode' => 'BillingAddress',
    //  'billingstate' => 'BillingAddress',
    //  'billingcity' => 'BillingAddress',
    //  'billingstreet' => 'BillingAddress',
    //  // 取引先の住所用 納入先
    //  'shippingcountry' => 'ShippingAddress',
    //  'shippingpostalcode' => 'ShippingAddress',
    //  'shippingstate' => 'ShippingAddress',
    //  'shippingcity' => 'ShippingAddress',
    //  'shippingstreet' => 'ShippingAddress',
    //  // 取引先の責任者の住所用 郵送先
    //  'mailingcountry' => 'MailingAddress',
    //  'mailingpostalcode' => 'MailingAddress',
    //  'mailingstate' => 'MailingAddress',
    //  'mailingcity' => 'MailingAddress',
    //  'mailingstreet' => 'MailingAddress',
    //  // 取引先の責任者の住所用 その他の
    //  'othercountry' => 'OtherAddress',
    //  'otherpostalcode' => 'OtherAddress',
    //  'otherstate' => 'OtherAddress',
    //  'othercity' => 'OtherAddress',
    //  'otherstreet' => 'OtherAddress'
    //};

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
              throw new CrudFlsException(String.format(Label.SB_MSG_FlsNotCreateable,
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
          throw new CrudFlsException(String.format(Label.SB_MSG_CrudNotUpdateable, new String[] {sobjResult.label}));
        }

        Map<string, Schema.SObjectField> m = sobjResult.fields.getMap();
        // Anonymous Executeなら できるが、ここでは 複合項目の Address についてはとれない！
        //for (String key : m.keySet()) {
        //  Schema.DescribeFieldResult descField = m.get(key).getDescribe();
        //  System.debug('111 '  + descField.getLabel() + ' : ' + descField.getName() + ' : ' + descField.isPermissionable() + ' : ' + descField.isCreateable() + ' : ' + descField.isUpdateable());
        //}

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
              throw new CrudFlsException(String.format(Label.SB_MSG_FlsNotUpdateable,
                                        new String[] {sobjResult.label, descField.getLabel(), descField.getName()}));
          }
        }
      }

      List<Database.SaveResult> sr = Database.update(os, dml);
      return sr;
    }
  } // private class SB_NameCard_CrudFlsInt

}