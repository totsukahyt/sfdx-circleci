/**
 *
 * SB_NC_PostInstallScriptBasicStteingTest
 *  名刺基本設定を 作るクラス SB_NC_PostInstallScript の内部クラス SB_NameCard_BasicSettingBuilder のテストクラス
 *
 * Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2017.06.xx
 *  @Version 2      2017.09.xx SV_DEV-582 『「上書きする」チェックボックスを表示する』機能について取引先・取責を分けて制御できるようにしたい
 *  @Version 2.1  2018.12.xx 基本設定のレコードタイプ指定の項目に適当な値をしていしない。トリガでチェックするようにしたので、
 *
 **/
@isTest
private class SB_NC_PostInstallScriptBasicStteingTest {

  // 名前空間名プレフィックス
  private static final String NS_X = SB_NameCard_Util.getNamespacePrefix_x();

  /**
  *
  * テストケース 1 何も設定がないときに正しく 基本設定が つくられてるの（= デフォルト値になってる）を確認
  *
  **/
  // 設定がない
  public virtual class TestDbNoCustomConfigNoBasicSetting extends SB_NC_TestDB {

    public override void initialize() {
    }
  } // TestDbNoCustomConfigNoBasicSetting

  @isTest static void test_convertNoCustomConfigNoBasicSettingToLatest() {
    // Ver1 環境を作る
    TestDbNoCustomConfigNoBasicSetting db = new TestDbNoCustomConfigNoBasicSetting();
    db.initialize();

    // コンバート実行
    SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder builder = new SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder();
    builder.run();
    // 基本設定レコード
    String query = SB_NameCard_Util.getQueryText(NameCardBasicSetting__c.sObjectType);
    System.debug(query);
    List<NameCardBasicSetting__c> settings = Database.query(query);
    //
    for (SB_NC_PostInstallScript.ItemBuilder ib : SB_NC_PostInstallScript.SETTINGS_ITEMBUILDERS) {
      Object val = settings[0].get(ib.field);
      System.assertEquals(ib.defaultValue, val);
    }
  }

  /**
  *
  *  テストケース 2 v1.19より前 から 最新（v1.20）への以降
  *   カスタム設定を 移行しているのを確認
  **/
  //  最新 （v1.20） で移行するカステム設定 SmartVisca設定 の値を作っておく
  public virtual class TestDbNoBasicSetting extends SB_NC_TestDB {
    // カステム設定の値
    Map<String, Object> svConfigKey2Value = new Map<String, Object> {
      'ToDoName__c' => 'TEST Subject TTT',
      'AccountNotOverWrite__c' => true,
      'ContactNotOverWrite__c' => true,
      'DispAccountRectype__c' => false,
      'DispContactRectype__c' => false
    };

    // SmartVisca設定
    public override void initializeSmartViscaConfig() {
      svConfig = SmartViscaConfig__c.getOrgDefaults();
      for (String key : svConfigKey2Value.keySet()) {
        svConfig.put(key, svConfigKey2Value.get(key));
      }
    }

    public override void initialize() {
      // SmartVisca設定
      initializeSmartViscaConfig();
      if (svConfig !=null) {
        upsert svConfig;
      }
    }
  } // TestDbNoBasicSetting
  //
  @isTest static void test_convertNoBasicSettingToLatest() {
    // Ver1 環境を作る
    TestDbNoBasicSetting db = new TestDbNoBasicSetting();
    db.initialize();

    // コンバート実行
    SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder builder = new SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder();
    builder.run();

    // SmartVisca設定
    SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    // 基本設定レコード
    String query = SB_NameCard_Util.getQueryText(NameCardBasicSetting__c.sObjectType);
    System.debug(query);
    List<NameCardBasicSetting__c> settings = Database.query(query);
    //
    for (SB_NC_PostInstallScript.ItemBuilder ib : SB_NC_PostInstallScript.SETTINGS_ITEMBUILDERS) {
      Object val = settings[0].get(ib.field);
      if (String.isNotBlank(ib.sourceField)) {
        //SmartVisca設定からの移行した値の検証
        Object oldVal;
        if (SB_NameCard_BasicSettingBuilder.nameCardBasicSettingFields.containsKey(NS_X + ib.sourceField)) {
          oldVal = settings[0].get(NS_X + ib.sourceField);
        }
        else {
          //oldVal = svConfig.get(ib.sourceField);
          Map<String, Object> customConfigMap = svConfig.getPopulatedFieldsAsMap();
          oldVal = customConfigMap.get(ib.sourceField);
        }
        System.assert(oldVal == null || oldVal == val);
      }
      else {
        // 基本設定 のデフォルト値の検証
        System.assertEquals(ib.defaultValue, val);
      }
    }
  }

  /**
  *
  * テストケース 3 v1.19 から 最新（v1.20）への以降
  * v1.19 のときの 基本設定レコードを保持して、カスタム設定を 移行しているのを確認
  **/
  // v1.19 のときの 基本設定レコードをつくる のと、 最新 （v1.20） で移行するカステム設定 SmartVisca設定 の値を作っておく
  public virtual class TestDbVer1Default extends SB_NC_TestDB {
    // カステム設定の値
    Map<String, Object> svConfigKey2Value = new Map<String, Object> {
      'ToDoName__c' => 'TEST Subject TTT',
      'AccountNotOverWrite__c' => true,
      'ContactNotOverWrite__c' => true,
      'DispAccountRectype__c' => false,
      'DispContactRectype__c' => false
    };

    // SmartVisca設定
    public override void initializeSmartViscaConfig() {
      svConfig = SmartViscaConfig__c.getOrgDefaults();
      for (String key : svConfigKey2Value.keySet()) {
        svConfig.put(key, svConfigKey2Value.get(key));
      }
    }

    // 基本設定 を作成
    public override void initializeBasicSetting() {
      SB_NameCard_BasicSettingBuilder instance = new SB_NameCard_BasicSettingBuilder();
      NameCardBasicSetting__c bs = new NameCardBasicSetting__c();
      for (SB_NC_PostInstallScript.ItemBuilder ib : SB_NC_PostInstallScript.SETTINGS_ITEMBUILDERS) {
        if (ib.since <= 1) {
          // Ver1 のだけ作る。
          bs.put(ib.field, ib.defaultValue);
        }
      }
      listBasicSetting.add(bs);
    }

    public override void initialize() {
      // SmartVisca設定
      initializeSmartViscaConfig();
      if (svConfig !=null) {
        upsert svConfig;
      }
      // 名刺基本設定
      initializeBasicSetting();
      if (!listBasicSetting.isEmpty()) {
        insert listBasicSetting;
      }
    }
  } // TestDbVer1Default
  //
  @isTest static void test_convertVer1ToLatest() {
    // Ver1 環境を作る
    TestDbVer1Default db = new TestDbVer1Default();
    db.initialize();

    // コンバート実行
    SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder builder = new SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder();
    builder.run();

    // SmartVisca設定
    SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    // 基本設定レコード
    String query = SB_NameCard_Util.getQueryText(NameCardBasicSetting__c.sObjectType);
    System.debug(query);
    List<NameCardBasicSetting__c> settings = Database.query(query);
    //
    for (SB_NC_PostInstallScript.ItemBuilder ib : SB_NC_PostInstallScript.SETTINGS_ITEMBUILDERS) {
      Object val = settings[0].get(ib.field);
      if (String.isNotBlank(ib.sourceField)) {
        //SmartVisca設定からの移行した値の検証
        Object oldVal;
        if (SB_NameCard_BasicSettingBuilder.nameCardBasicSettingFields.containsKey(NS_X + ib.sourceField)) {
          oldVal = settings[0].get(NS_X + ib.sourceField);
        }
        else {
          //oldVal = svConfig.get(ib.sourceField);
          Map<String, Object> customConfigMap = svConfig.getPopulatedFieldsAsMap();
          oldVal = customConfigMap.get(ib.sourceField);
        }
        System.assert(oldVal == null || oldVal == val);
      }
      else {
        // 基本設定 のデフォルト値の検証
        System.assertEquals(ib.defaultValue, val);
      }
    }
  }

  /**
  *
  * テストケース 4 v1.19 から 最新（v1.20）への以降 2  基本設定がデフォルトでない。
  * v1.19 のときの 基本設定レコードを保持して、カスタム設定を 移行しているのを確認
  **/
  // v1.19 のときの 基本設定レコードをつくる のと、 最新 （v1.20） で移行するカステム設定 SmartVisca設定 の値を作っておく
  public virtual class TestDbVer1Modify extends SB_NC_TestDB {
    // カステム設定の値
    Map<String, Object> svConfigKey2Value = new Map<String, Object> {
      'ToDoName__c' => 'TEST Subject TTT',
      'AccountNotOverWrite__c' => true,
      'ContactNotOverWrite__c' => true,
      'DispAccountRectype__c' => false,
      'DispContactRectype__c' => false
    };

    // SmartVisca設定
    public override void initializeSmartViscaConfig() {
      svConfig = SmartViscaConfig__c.getOrgDefaults();
      for (String key : svConfigKey2Value.keySet()) {
        svConfig.put(key, svConfigKey2Value.get(key));
      }
    }

    public Map<String, Object> basicSettingVer1 = new Map<String, Object> {
      'RenkeiActive__c' => false,      // 自動連携機能有効
      'RenkeiAccountAddressPref__c' => false,   // アカウント 都道府県
      'RenkeiAccount_Street__c' => false,   // アカウント 町名・番地
      'RenkeiAccountZipCode__c' => false,   // アカウント 郵便番号
      'RenkeiAccountCity__c' => false,      // アカウント 市区郡
      'RenkeiAccountURL__c' => false,       // アカウント URL
      'RenkeiAccountCompany__c' => true,   // アカウント 会社名
      'RenkeiAccountPhone__c' => false,     // アカウント 電話番号
      'RenkeiSpecificItems__c' => null,        // アカウント 特定項目
      'RenkeiAccountSite__c' => false,        // アカウント 部署名
      'RenkeiExcludeHojinkakuPartial__c' => true,      // 自動連携:会社名は法人格を除いて部分一致
      'RenkeiExcludeHojinkaku__c' => false,      // 自動連携:会社名は法人格を除いて完全一致
      'RenkeiAccountSitePartialMatch__c' => true,      // 自動連携:部署は中間一致検索
      'RenkeiContactMail__c' => true,      // コンタクト メールアドレス
      'RenkeiContactLastName__c' => true,  // コンタクト ラストネーム
      'RenkeiContactFirstName__c' => false, // コンタクト ファーストネーム
      'RenkeiAccountQueryRecordTypeIds__c' => null,    // 検索対象のレコードタイプタイプID カンマ区切り で羅列
      'RenkeiContactQueryRecordTypeIds__c' => null,  // 自動連携で検索対象の取引先責任者レコードタイプ
      'RenkeiAccountOverwrite__c' => true,   // 既存の取引先を上書き
      'RenkeiContactOverwrite__c' => true,   // 既存の取引先責任者を上書き
      'RenkeiAccountNOExistCreateNew__c' => true,  //既存の取引先がなければ新規作成する
      'RenkeiContactNOExistCreateNew__c' => true,  // 既存の取引先責任者がなければ新規作成する
      'RenkeiAccountRecordTypes__c' => null,     // 作成するアカウント の レコードタイプID １つ
      'RenkeiContactRecordTypes__c' => null      // 作成するコンタクト の レコードタイプID １つ
    };

    // 基本設定 を作成
    public override void initializeBasicSetting() {
      NameCardBasicSetting__c bs = new NameCardBasicSetting__c();
      for (String key : basicSettingVer1.keySet()) {
        bs.put(key, basicSettingVer1.get(key));
      }
      listBasicSetting.add(bs);
    }

    public override void initialize() {
      // SmartVisca設定
      initializeSmartViscaConfig();
      if (svConfig !=null) {
        upsert svConfig;
      }
      // 名刺基本設定
      initializeBasicSetting();
      if (!listBasicSetting.isEmpty()) {
        insert listBasicSetting;
      }
    }
  } // TestDbVer1Modify
  //
  @isTest static void test_convertModifiedVer1ToLatest() {
    // Ver1 環境を作る
    TestDbVer1Modify db = new TestDbVer1Modify();
    db.initialize();

    // コンバート実行
    SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder builder = new SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder();
    builder.run();

    // SmartVisca設定
    SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    // 基本設定レコード
    String query = SB_NameCard_Util.getQueryText(NameCardBasicSetting__c.sObjectType);
    System.debug(query);
    List<NameCardBasicSetting__c> settings = Database.query(query);
    //
    for (SB_NC_PostInstallScript.ItemBuilder ib : SB_NC_PostInstallScript.SETTINGS_ITEMBUILDERS) {
      Object val = settings[0].get(ib.field);
      if (String.isNotBlank(ib.sourceField)) {
        //SmartVisca設定からの移行した値の検証
        Object oldVal;
        if (SB_NameCard_BasicSettingBuilder.nameCardBasicSettingFields.containsKey(NS_X + ib.sourceField)) {
          oldVal = settings[0].get(NS_X + ib.sourceField);
        }
        else {
          //oldVal = svConfig.get(ib.sourceField);
          Map<String, Object> customConfigMap = svConfig.getPopulatedFieldsAsMap();
          oldVal = customConfigMap.get(ib.sourceField);
        }
        System.assert(oldVal == null || oldVal == val);
      }
      else if (db.basicSettingVer1.containsKey(ib.field)) {
        // 基本設定 のデフォルト値の検証
        Object oldVal = db.basicSettingVer1.get(ib.field);
        System.assertEquals(oldVal, val);
      }
      else {
        // 基本設定 のデフォルト値の検証
        System.assertEquals(ib.defaultValue, val);
      }
    }
  }

}