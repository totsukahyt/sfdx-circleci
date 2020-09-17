/**
 *
 * SB_NameCard_RegistCanPickerAbstractTest
 *
 *  取引先登録の候補抽出処理の基底クラスのテスト  適切に候補抽出処理のインスタンスを作るかくらいのテスト
 * 
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2019.06.xx v2.4
 *
 **/
@isTest
private class SB_NameCard_RegistCanPickerAbstractTest {

  /**** 個別編 ****/

  // 個別で カスタム設定デフォルトでSOSL
  @isTest
  static void test_createCandidatePicker_Sosl() {
    SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder builder = new SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder();
    builder.run();

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.sObjecttype);

    System.assertEquals(false, qo_a.isUseSoqlOption()); //SOSL

    // SB_NameCard_RegistCanPickerAbstract picker = SB_NameCard_RegistCanPickerAbstract.createCandidatePicker(qo_a);
    // System.assert(picker instanceOf SB_NameCard_RegistSoslSoqlCanPicker); // 個別で 会社名Nameでなくても SOSL
  }

  // 個別で カスタム設定でSOQL
  @isTest
  static void test_createCandidatePicker_Soql() {
    SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    svConfig.AccountRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(個別) 登録先候補の検索方法  SOQL
    // svConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL
    upsert svConfig;

    SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder builder = new SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder();
    builder.run();
    NameCardBasicSetting__c setting = [SELECT Id, HojinkakuEquationLongAndAbbr__c FROM NameCardBasicSetting__c LIMIT 1];
    setting.HojinkakuEquationLongAndAbbr__c = true; // v2.4 会社名の法人格は略称・正称を同一視
    update setting;

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.sObjecttype);

    System.assertEquals(true, qo_a.isUseSoqlOption()); // SOQL

    // SB_NameCard_RegistCanPickerAbstract picker = SB_NameCard_RegistCanPickerAbstract.createCandidatePicker(qo_a);
    // System.assert(picker instanceOf SB_NameCard_RegistSoqlCountCanPicker); // SOQL
  }

  // 個別で 会社名Nameでなくて SOSL
  @isTest
  static void test_createCandidatePicker_AltName_Sosl() {
    SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder builder = new SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder();
    builder.run();

    NameCardBasicSetting__c setting = [SELECT Id, Name, RegistAccountCompareCustomize__c, RegistAccountCompareField__c FROM NameCardBasicSetting__c LIMIT 1];
    setting.RegistAccountCompareCustomize__c = true;
    setting.RegistAccountCompareField__c = 'SicDesc';
    update setting;

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.sObjecttype);

    System.assertEquals(true, qo_a.isUseSoqlOption()); // 個別で 会社名Nameでないと SOQL

    // SB_NameCard_RegistCanPickerAbstract picker = SB_NameCard_RegistCanPickerAbstract.createCandidatePicker(qo_a);
    // System.assert(picker instanceOf SB_NameCard_RegistSoqlCountCanPicker); 
  }

  // 個別で 会社名Nameでなくて カスタム設定でSOQL
  @isTest
  static void test_createCandidatePicker_AltName_Soql() {
    SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    svConfig.AccountRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(個別) 登録先候補の検索方法  SOQL
    // svConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL
    upsert svConfig;

    SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder builder = new SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder();
    builder.run();
    NameCardBasicSetting__c setting = [SELECT Id, HojinkakuEquationLongAndAbbr__c FROM NameCardBasicSetting__c LIMIT 1];
    setting.HojinkakuEquationLongAndAbbr__c = true; // v2.4 会社名の法人格は略称・正称を同一視
    update setting;

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.sObjecttype);

    System.assertEquals(true, qo_a.isUseSoqlOption()); // 個別で 会社名Nameでなくて SOQL

    // SB_NameCard_RegistCanPickerAbstract picker = SB_NameCard_RegistCanPickerAbstract.createCandidatePicker(qo_a);
    // System.assert(picker instanceOf SB_NameCard_RegistSoqlCountCanPicker); 
  }

  // 個別 完全一致 正略区別なし SOSL
  @isTest
  static void test_createCandidatePicker_Exactmatch_nostrict_SOSL() {
    // SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    // svConfig.AccountRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(個別) 登録先候補の検索方法  SOQL
    // // svConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL
    // upsert svConfig;

    SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder builder = new SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder();
    builder.run();
    NameCardBasicSetting__c setting = [SELECT Id, HojinkakuEquationLongAndAbbr__c FROM NameCardBasicSetting__c LIMIT 1];
    setting.HojinkakuEquationLongAndAbbr__c = true; // v2.4 会社名の法人格は略称・正称を同一視
    update setting;

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.sObjecttype);
    qo_a.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.ExactMatch;

    System.assertEquals(false, qo_a.isUseSoqlOption());  // SOSL

    // SB_NameCard_RegistCanPickerAbstract picker = SB_NameCard_RegistCanPickerAbstract.createCandidatePicker(qo_a);
    // System.assert(picker instanceOf SB_NameCard_RegistSoslSoqlCanPicker); // SOSL 
  }

  // 個別 完全一致 正略区別なし SOQL
  @isTest
  static void test_createCandidatePicker_Exactmatch_nostrict_SOQL() {
    SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    svConfig.AccountRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(個別) 登録先候補の検索方法  SOQL
    // // svConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL
    upsert svConfig;

    SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder builder = new SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder();
    builder.run();

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.sObjecttype);
    qo_a.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.ExactMatch;

    System.assertEquals(true, qo_a.isUseSoqlOption());  // SOQL

    // SB_NameCard_RegistCanPickerAbstract picker = SB_NameCard_RegistCanPickerAbstract.createCandidatePicker(qo_a);
    // System.assert(picker instanceOf SB_NameCard_RegistSoqlCountCanPicker); // SOQL 
  }

  // 個別 完全一致 正略区別 SOSL でなく SOQL
  @isTest
  static void test_createCandidatePicker_Exactmatch_strict_SOSL() {
    SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    // svConfig.AccountRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(個別) 登録先候補の検索方法  SOQL
    // // svConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL
    upsert svConfig;

    SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder builder = new SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder();
    builder.run();
    SB_NameCard_BasicSetting.getNameCardBasicSetting().HojinkakuEquationLongAndAbbr__c = false; // // v2.4 会社名の法人格は略称・正称を区別

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.sObjecttype);
    qo_a.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.ExactMatch;

    System.assertEquals(true, qo_a.isUseSoqlOption());  // 正略区別 なら SOSL の設定でも SOQL

    // SB_NameCard_RegistCanPickerAbstract picker = SB_NameCard_RegistCanPickerAbstract.createCandidatePicker(qo_a);
    // System.assert(picker instanceOf SB_NameCard_RegistSoqlCountCanPicker); // 正略区別 なら SOSL の設定でも SOQL
  }

  // 個別 完全一致 正略区別 SOQL
  @isTest
  static void test_createCandidatePicker_Exactmatch_strict_SOQL() {
    SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    svConfig.AccountRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(個別) 登録先候補の検索方法  SOQL
    // // svConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL
    upsert svConfig;

    SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder builder = new SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder();
    builder.run();

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.sObjecttype);
    qo_a.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.ExactMatch;

    System.assertEquals(true, qo_a.isUseSoqlOption());  // SOQL

    // SB_NameCard_RegistCanPickerAbstract picker = SB_NameCard_RegistCanPickerAbstract.createCandidatePicker(qo_a);
    // System.assert(picker instanceOf SB_NameCard_RegistSoqlCountCanPicker); // SOQL 
  }

  /**** 一括編 ****/

  // 一括 カスタム設定デフォルト SOSL
  @isTest
  static void test_createCandidatePicker_Bulk_Sosl() {
    SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder builder = new SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder();
    builder.run();

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.sObjecttype);
    qo_a.bulkRegist = true;
    SB_NC_RegistQueryOption qo_c = new SB_NC_RegistQueryOption(Contact.sObjecttype);
    qo_c.bulkRegist = true;
    List<SB_NC_RegistQueryOption> qos = new List<SB_NC_RegistQueryOption> { qo_a, qo_c };

    System.assertEquals(false, SB_NameCard_RegistCanPickerAbstract.isUseSoqlOptions(qos));  // SOSL

    // SB_NameCard_RegistCanPickerAbstract picker = SB_NameCard_RegistCanPickerAbstract.createCandidatePicker(qos);
    // System.assert(picker instanceOf SB_NameCard_RegistSoslSoqlCanPicker); // SOSL
  }

  // 一括 カスタム設定変更 SOQL
  @isTest
  static void test_createCandidatePicker_Bulk_soql() {
    SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    // svConfig.AccountRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(個別) 登録先候補の検索方法  SOQL
    svConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL
    upsert svConfig;

    SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder builder = new SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder();
    builder.run();
    NameCardBasicSetting__c setting = [SELECT Id, HojinkakuEquationLongAndAbbr__c FROM NameCardBasicSetting__c LIMIT 1];
    setting.HojinkakuEquationLongAndAbbr__c = true; // v2.4 会社名の法人格は略称・正称を同一視
    update setting;

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.sObjecttype);
    qo_a.bulkRegist = true;
    SB_NC_RegistQueryOption qo_c = new SB_NC_RegistQueryOption(Contact.sObjecttype);
    qo_c.bulkRegist = true;
    List<SB_NC_RegistQueryOption> qos = new List<SB_NC_RegistQueryOption> { qo_a, qo_c };

    System.assertEquals(true, SB_NameCard_RegistCanPickerAbstract.isUseSoqlOptions(qos));  // SOSL

    // SB_NameCard_RegistCanPickerAbstract picker = SB_NameCard_RegistCanPickerAbstract.createCandidatePicker(qos);
    // System.assert(picker instanceOf SB_NameCard_RegistSoqlCountCanPicker); // SOQL
  }

  // 一括 Nameでなくて SOSL
  @isTest
  static void test_createCandidatePicker_Bulk_AltName_notsosl() {
    // SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    // // svConfig.AccountRegistSearchMethod__c = 1; // 取引先・取引先任者に登録(個別) 登録先候補の検索方法  SOSL
    // // svConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL
    // upsert svConfig;

    SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder builder = new SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder();
    builder.run();

    NameCardBasicSetting__c setting = [SELECT Id, Name, RegistAccountCompareCustomize__c, RegistAccountCompareField__c FROM NameCardBasicSetting__c LIMIT 1];
    setting.RegistAccountCompareCustomize__c = true;
    setting.RegistAccountCompareField__c = 'SicDesc';
    update setting;

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.sObjecttype);
    qo_a.bulkRegist = true;
    SB_NC_RegistQueryOption qo_c = new SB_NC_RegistQueryOption(Contact.sObjecttype);
    qo_c.bulkRegist = true;
    List<SB_NC_RegistQueryOption> qos = new List<SB_NC_RegistQueryOption> { qo_a, qo_c };

    System.assertEquals(true, SB_NameCard_RegistCanPickerAbstract.isUseSoqlOptions(qos));  // Name以外と比較なら SOSL でなく SOQL

    // SB_NameCard_RegistCanPickerAbstract picker = SB_NameCard_RegistCanPickerAbstract.createCandidatePicker(qos);
    // System.assert(picker instanceOf SB_NameCard_RegistSoqlCountCanPicker); // Name以外と比較なら SOSL でなく SOQL
  }

  // 一括 Nameでなくて SOQL
  @isTest
  static void test_createCandidatePicker_Bulk_AltName_soql() {
    SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    // svConfig.AccountRegistSearchMethod__c = 1; // 取引先・取引先任者に登録(個別) 登録先候補の検索方法  SOSL
    svConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL
    upsert svConfig;

    SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder builder = new SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder();
    builder.run();

    NameCardBasicSetting__c setting = [SELECT Id, Name, RegistAccountCompareCustomize__c, RegistAccountCompareField__c FROM NameCardBasicSetting__c LIMIT 1];
    setting.RegistAccountCompareCustomize__c = true;
    setting.RegistAccountCompareField__c = 'SicDesc';
    update setting;

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.sObjecttype);
    qo_a.bulkRegist = true;
    SB_NC_RegistQueryOption qo_c = new SB_NC_RegistQueryOption(Contact.sObjecttype);
    qo_c.bulkRegist = true;
    List<SB_NC_RegistQueryOption> qos = new List<SB_NC_RegistQueryOption> { qo_a, qo_c };

    System.assertEquals(true, SB_NameCard_RegistCanPickerAbstract.isUseSoqlOptions(qos));  // SOQL

    // SB_NameCard_RegistCanPickerAbstract picker = SB_NameCard_RegistCanPickerAbstract.createCandidatePicker(qos);
    // System.assert(picker instanceOf SB_NameCard_RegistSoqlCountCanPicker); // SOQL
  } 


  // 一括 完全一致 正略区別なし SOSL
  @isTest
  static void test_createCandidatePicker_Bulk_Exactmatch_nostrict_SOSL() {
    SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder builder = new SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder();
    builder.run();
    NameCardBasicSetting__c setting = [SELECT Id, HojinkakuEquationLongAndAbbr__c FROM NameCardBasicSetting__c LIMIT 1];
    setting.HojinkakuEquationLongAndAbbr__c = true; // v2.4 会社名の法人格は略称・正称を同一視
    update setting;

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.sObjecttype);
    qo_a.bulkRegist = true;
    qo_a.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.ExactMatch;
    SB_NC_RegistQueryOption qo_c = new SB_NC_RegistQueryOption(Contact.sObjecttype);
    qo_c.bulkRegist = true;
    List<SB_NC_RegistQueryOption> qos = new List<SB_NC_RegistQueryOption> { qo_a, qo_c };

    System.assertEquals(false, SB_NameCard_RegistCanPickerAbstract.isUseSoqlOptions(qos));  // 完全一致でも SOSL 

    // SB_NameCard_RegistCanPickerAbstract picker = SB_NameCard_RegistCanPickerAbstract.createCandidatePicker(qos);
    // System.assert(picker instanceOf SB_NameCard_RegistSoslSoqlCanPicker); // 完全一致でも SOSL 
  }

  // 一括 完全一致 正略区別なし SOQL
  @isTest
  static void test_createCandidatePicker_Bulk_Exactmatch_nostrict_SOQL() {
    SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();    
    // svConfig.AccountRegistSearchMethod__c = 1; // 取引先・取引先任者に登録(個別) 登録先候補の検索方法  SOSL
    svConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL
    upsert svConfig;

    SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder builder = new SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder();
    builder.run();
    NameCardBasicSetting__c setting = [SELECT Id, HojinkakuEquationLongAndAbbr__c FROM NameCardBasicSetting__c LIMIT 1];
    setting.HojinkakuEquationLongAndAbbr__c = true; // v2.4 会社名の法人格は略称・正称を同一視
    update setting;

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.sObjecttype);
    qo_a.bulkRegist = true;
    qo_a.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.ExactMatch;
    SB_NC_RegistQueryOption qo_c = new SB_NC_RegistQueryOption(Contact.sObjecttype);
    qo_c.bulkRegist = true;
    List<SB_NC_RegistQueryOption> qos = new List<SB_NC_RegistQueryOption> { qo_a, qo_c };

    System.assertEquals(true, SB_NameCard_RegistCanPickerAbstract.isUseSoqlOptions(qos));  // カスタム設定で SOQL 

    // SB_NameCard_RegistCanPickerAbstract picker = SB_NameCard_RegistCanPickerAbstract.createCandidatePicker(qos);
    // System.assert(picker instanceOf SB_NameCard_RegistSoqlCountCanPicker); // カスタム設定で SOQL 
  }

  // 一括 完全一致 正略区別 SOSL でなく SOQL
  @isTest
  static void test_createCandidatePicker_Bulk_Exactmatch_strict_SOSL() {
    SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    upsert svConfig;

    SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder builder = new SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder();
    builder.run();
    SB_NameCard_BasicSetting.getNameCardBasicSetting().HojinkakuEquationLongAndAbbr__c = false; // // v2.4 会社名の法人格は略称・正称を区別

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.sObjecttype);
    qo_a.bulkRegist = true;
    qo_a.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.ExactMatch;
    SB_NC_RegistQueryOption qo_c = new SB_NC_RegistQueryOption(Contact.sObjecttype);
    qo_c.bulkRegist = true;
    List<SB_NC_RegistQueryOption> qos = new List<SB_NC_RegistQueryOption> { qo_a, qo_c };

    System.assertEquals(true, SB_NameCard_RegistCanPickerAbstract.isUseSoqlOptions(qos));  // 正略区別 なら SOSL の設定でも SOQL

    // SB_NameCard_RegistCanPickerAbstract picker = SB_NameCard_RegistCanPickerAbstract.createCandidatePicker(qos);
    // System.assert(picker instanceOf SB_NameCard_RegistSoqlCountCanPicker); // 正略区別 なら SOSL の設定でも SOQL
  }

  // 一括 完全一致 正略区別 SOQL
  @isTest
  static void test_createCandidatePicker_Bulk_Exactmatch_strict_SOQL() {
    SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    // svConfig.AccountRegistSearchMethod__c = 1; // 取引先・取引先任者に登録(個別) 登録先候補の検索方法  SOSL
    svConfig.AccountBulkRegistSearchMethod__c = 0; // 取引先・取引先任者に登録(一括) 登録先候補の検索方法 SOQL
    upsert svConfig;

    SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder builder = new SB_NC_PostInstallScript.SB_NameCard_BasicSettingBuilder();
    builder.run();

    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.sObjecttype);
    qo_a.bulkRegist = true;
    qo_a.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.ExactMatch;
    SB_NC_RegistQueryOption qo_c = new SB_NC_RegistQueryOption(Contact.sObjecttype);
    qo_c.bulkRegist = true;
    List<SB_NC_RegistQueryOption> qos = new List<SB_NC_RegistQueryOption> { qo_a, qo_c };

    System.assertEquals(true, SB_NameCard_RegistCanPickerAbstract.isUseSoqlOptions(qos));  // SOQL

    // SB_NameCard_RegistCanPickerAbstract picker = SB_NameCard_RegistCanPickerAbstract.createCandidatePicker(qos);
    // System.assert(picker instanceOf SB_NameCard_RegistSoqlCountCanPicker); // SOQL 
  }

}