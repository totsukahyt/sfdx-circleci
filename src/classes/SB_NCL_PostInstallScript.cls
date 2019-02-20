/**
 *
 *  SB_NCL_PostInstallScript
 *  リード拡張パッケージ用の インストール後に実行されるクラス
 *    連携マッピング用のオブジェクトにLEAD用のデフォルト値のレコードを作る。
 *
 *  @author sawano
 *  @Version 1      2018.01.xx
 *
 **/
//global class SB_NCL_PostInstallScript {
global class SB_NCL_PostInstallScript implements InstallHandler {
  private SB_NameCard_CrudFlsInt crudFls;

  //// 基本設定の項目
  //@TestVisible
  //private static final Map<String, Schema.SObjectField> nameCardBasicSettingFields
  //  = SMartViscaf__NameCardBasicSetting__c.getSObjectType().getDescribe().fields.getMap();

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