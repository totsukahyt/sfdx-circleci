/**
 *
 * SB_NameCard_NameCardBasicSettingDTOTest
 * SB_NameCard_NameCardBasicSettingDTOのテストクラス
 *
 *
 *
 *  Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author mao
 *  @Version 1.20      2017.02.XX
 *
 **/


@isTest
private class SB_NameCard_NameCardBasicSettingDTOTest {

  //NameCardBasicSetting__c から map trueの場合
  @isTest static void test_DTOBindTrue() {
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c(
    RenkeiActive__c = true,      // 自動連携機能有効
    RenkeiAccountAddressPref__c = true,   // アカウント 都道府県
    RenkeiAccount_Street__c = true,   // アカウント 町名・番地
    RenkeiAccountZipCode__c = true,   // アカウント 郵便番号
    RenkeiAccountCity__c = true,      // アカウント 市区郡
    RenkeiAccountURL__c = true,       // アカウント URL
    RenkeiAccountCompany__c = true,   // アカウント 会社名
    RenkeiAccountPhone__c = true,     // アカウント 電話番号
    RenkeiSpecificItems__c = 'sp',        // アカウント 特定項目
    RenkeiAccountSite__c = true,        // アカウント 部署名
    RenkeiContactMail__c = true,      // コンタクト メールアドレス
    RenkeiContactLastName__c = true,  // コンタクト 姓
    RenkeiContactFirstName__c = true, // コンタクト 名
    RenkeiAccountQueryRecordTypeIds__c = '123;321',    // 検索対象のレコードタイプタイプID カンマ区切り で羅列
    RenkeiContactQueryRecordTypeIds__c = '123;321',  // 自動連携で検索対象の取引先責任者レコードタイプ
    RenkeiAccountOverwrite__c = true,   // 既存の取引先を上書き
    RenkeiContactOverwrite__c = true,   // 既存の取引先責任者を上書き
    RenkeiAccountNOExistCreateNew__c = true,  //既存の取引先がなければ新規作成する
    RenkeiContactNOExistCreateNew__c = true,  // 既存の取引先責任者がなければ新規作成する
    RenkeiAccountRecordTypes__c = '321',      // 作成するアカウント の レコードタイプID １つ
    SaishinInheritValues__c = true
    );
    Map<String,String> basicmap = SB_NameCard_NameCardBasicSettingDTO.bind(setting);
    Map<String,String> basicmap1 = SB_NameCard_NameCardBasicSettingDTO.bindSimple(setting);
    System.assertEquals(basicmap1.get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('RenkeiActive__c')),'true');
    System.assertEquals(basicmap.get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('RenkeiAccountAddressPref__c')),'true');
    System.assertEquals(basicmap.get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('RenkeiAccount_Street__c')),'true');
    System.assertEquals(basicmap.get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('RenkeiAccountZipCode__c')),'true');
    System.assertEquals(basicmap.get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('RenkeiAccountCity__c')),'true');
    System.assertEquals(basicmap.get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('RenkeiAccountURL__c')),'true');
    System.assertEquals(basicmap.get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('RenkeiAccountCompany__c')),'true');
    System.assertEquals(basicmap.get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('RenkeiAccountPhone__c')),'true');
    System.assertEquals(basicmap.get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('RenkeiSpecificItems__c')),'sp');
    System.assertEquals(basicmap.get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('RenkeiAccountSite__c')),'true');
    System.assertEquals(basicmap.get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('RenkeiContactMail__c')),'true');
    System.assertEquals(basicmap.get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('RenkeiContactLastName__c')),'true');
    System.assertEquals(basicmap.get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('RenkeiContactFirstName__c')),'true');
    System.assertEquals(basicmap.get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('RenkeiAccountQueryRecordTypeIds__c')),'123;321');
    System.assertEquals(basicmap.get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('RenkeiContactQueryRecordTypeIds__c')),'123;321');
    System.assertEquals(basicmap.get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('RenkeiAccountOverwrite__c')),'true');
    System.assertEquals(basicmap.get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('RenkeiContactOverwrite__c')),'true');
    System.assertEquals(basicmap.get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('RenkeiAccountNOExistCreateNew__c')),'true');
    System.assertEquals(basicmap.get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('RenkeiContactNOExistCreateNew__c')),'true');
    System.assertEquals(basicmap.get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('RenkeiAccountRecordTypes__c')),'321');
    System.assertEquals(basicmap1.get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('SaishinInheritValues__c')),'true');
  }

  //NameCardBasicSetting__c から map falseの場合
  @isTest static void test_DTOBindFalse() {
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c(
    RenkeiActive__c = false,      // 自動連携機能有効
    RenkeiAccountAddressPref__c = false,   // アカウント 都道府県
    RenkeiAccount_Street__c = false,   // アカウント 町名・番地
    RenkeiAccountZipCode__c = false,   // アカウント 郵便番号
    RenkeiAccountCity__c = false,      // アカウント 市区郡
    RenkeiAccountURL__c = false,       // アカウント URL
    RenkeiAccountCompany__c = false,   // アカウント 会社名
    RenkeiAccountPhone__c = false,     // アカウント 電話番号
    RenkeiSpecificItems__c = 'sp',        // アカウント 特定項目
    RenkeiAccountSite__c = false,        // アカウント 部署名
    RenkeiContactMail__c = false,      // コンタクト メールアドレス
    RenkeiContactLastName__c = true,  // コンタクト 姓
    RenkeiContactFirstName__c = true, // コンタクト 名
    RenkeiAccountQueryRecordTypeIds__c = '123;321',    // 検索対象のレコードタイプタイプID カンマ区切り で羅列
    RenkeiContactQueryRecordTypeIds__c = '123;321',  // 自動連携で検索対象の取引先責任者レコードタイプ
    RenkeiAccountOverwrite__c = false,   // 既存の取引先を上書き
    RenkeiContactOverwrite__c = false,   // 既存の取引先責任者を上書き
    RenkeiAccountNOExistCreateNew__c = false,  //既存の取引先がなければ新規作成する
    RenkeiContactNOExistCreateNew__c = false,  // 既存の取引先責任者がなければ新規作成する
    RenkeiAccountRecordTypes__c = '321',      // 作成するアカウント の レコードタイプID １つ
    SaishinInheritValues__c = false
    );
    Map<String,String> basicmap = SB_NameCard_NameCardBasicSettingDTO.bind(setting);
    Map<String,String> basicmap1 = SB_NameCard_NameCardBasicSettingDTO.bindSimple(setting);
    System.assertEquals(basicmap1.get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('RenkeiActive__c')),'false');
    System.assertEquals(basicmap.get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('RenkeiAccountAddressPref__c')),'false');
    System.assertEquals(basicmap.get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('RenkeiAccount_Street__c')),'false');
    System.assertEquals(basicmap.get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('RenkeiAccountZipCode__c')),'false');
    System.assertEquals(basicmap.get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('RenkeiAccountCity__c')),'false');
    System.assertEquals(basicmap.get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('RenkeiAccountURL__c')),'false');
    System.assertEquals(basicmap.get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('RenkeiAccountCompany__c')),'false');
    System.assertEquals(basicmap.get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('RenkeiAccountPhone__c')),'false');
    System.assertEquals(basicmap.get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('RenkeiSpecificItems__c')),'sp');
    System.assertEquals(basicmap.get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('RenkeiAccountSite__c')),'false');
    System.assertEquals(basicmap.get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('RenkeiContactMail__c')),'false');
    System.assertEquals(basicmap.get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('RenkeiContactLastName__c')),'true');
    System.assertEquals(basicmap.get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('RenkeiContactFirstName__c')),'true');
    System.assertEquals(basicmap.get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('RenkeiAccountQueryRecordTypeIds__c')),'123;321');
    System.assertEquals(basicmap.get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('RenkeiContactQueryRecordTypeIds__c')),'123;321');
    System.assertEquals(basicmap.get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('RenkeiAccountOverwrite__c')),'false');
    System.assertEquals(basicmap.get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('RenkeiContactOverwrite__c')),'false');
    System.assertEquals(basicmap.get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('RenkeiAccountNOExistCreateNew__c')),'false');
    System.assertEquals(basicmap.get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('RenkeiContactNOExistCreateNew__c')),'false');
    System.assertEquals(basicmap.get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('RenkeiAccountRecordTypes__c')),'321');
    System.assertEquals(basicmap1.get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('SaishinInheritValues__c')),'false');
  }

  //NameCardBasicSetting__c から map true
  @isTest static void test_DTODeBindTrue() {
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c(
    RenkeiActive__c = true,      // 自動連携機能有効
    RenkeiAccountAddressPref__c = true,   // アカウント 都道府県
    RenkeiAccount_Street__c = true,   // アカウント 町名・番地
    RenkeiAccountZipCode__c = true,   // アカウント 郵便番号
    RenkeiAccountCity__c = true,      // アカウント 市区郡
    RenkeiAccountURL__c = true,       // アカウント URL
    RenkeiAccountCompany__c = true,   // アカウント 会社名
    RenkeiAccountPhone__c = true,     // アカウント 電話番号
    RenkeiSpecificItems__c = 'sp',        // アカウント 特定項目
    RenkeiAccountSite__c = true,        // アカウント 部署名
    RenkeiContactMail__c = true,      // コンタクト メールアドレス
    RenkeiContactLastName__c = true,  // コンタクト 姓
    RenkeiContactFirstName__c = true, // コンタクト 名
    RenkeiAccountQueryRecordTypeIds__c = '123;321',    // 検索対象のレコードタイプタイプID カンマ区切り で羅列
    RenkeiContactQueryRecordTypeIds__c = '123;321',  // 自動連携で検索対象の取引先責任者レコードタイプ
    RenkeiAccountOverwrite__c = true,   // 既存の取引先を上書き
    RenkeiContactOverwrite__c = true,   // 既存の取引先責任者を上書き
    RenkeiAccountNOExistCreateNew__c = true,  //既存の取引先がなければ新規作成する
    RenkeiContactNOExistCreateNew__c = true,  // 既存の取引先責任者がなければ新規作成する
    RenkeiAccountRecordTypes__c = '321',      // 作成するアカウント の レコードタイプID １つ
    SaishinInheritValues__c = true
    );
    Map<String,String> basicmap = SB_NameCard_NameCardBasicSettingDTO.bind(setting);
    Map<String,String> basicmap1 = SB_NameCard_NameCardBasicSettingDTO.bindSimple(setting);
    NameCardBasicSetting__c basic = SB_NameCard_NameCardBasicSettingDTO.debind(basicmap);
    NameCardBasicSetting__c basic1 = SB_NameCard_NameCardBasicSettingDTO.DebindSimple(basicmap1);
    System.assertEquals(basic1.RenkeiActive__c,true);
    System.assertEquals(basic1.SaishinInheritValues__c,true);
    System.assertEquals(basic.RenkeiAccountAddressPref__c,true);
    System.assertEquals(basic.RenkeiAccount_Street__c,true);
    System.assertEquals(basic.RenkeiAccountZipCode__c,true);
    System.assertEquals(basic.RenkeiAccountCity__c,true);
    System.assertEquals(basic.RenkeiAccountURL__c,true);
    System.assertEquals(basic.RenkeiAccountCompany__c,true);
    System.assertEquals(basic.RenkeiAccountPhone__c,true);
    System.assertEquals(basic.RenkeiSpecificItems__c,'sp');
    System.assertEquals(basic.RenkeiAccountSite__c,true);
    System.assertEquals(basic.RenkeiContactMail__c,true);
    System.assertEquals(basic.RenkeiContactLastName__c,true);
    System.assertEquals(basic.RenkeiContactFirstName__c,true);
    System.assertEquals(basic.RenkeiAccountQueryRecordTypeIds__c,'123;321');
    System.assertEquals(basic.RenkeiContactQueryRecordTypeIds__c,'123;321');
    System.assertEquals(basic.RenkeiAccountOverwrite__c,true);
    System.assertEquals(basic.RenkeiContactOverwrite__c,true);
    System.assertEquals(basic.RenkeiAccountNOExistCreateNew__c,true);
    System.assertEquals(basic.RenkeiContactNOExistCreateNew__c,true);
    System.assertEquals(basic.RenkeiAccountRecordTypes__c,'321');
  }


  //NameCardBasicSetting__c から map falseの場合
  @isTest static void test_DTODeBindFalse() {
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c(
    RenkeiActive__c = false,      // 自動連携機能有効
    RenkeiAccountAddressPref__c = false,   // アカウント 都道府県
    RenkeiAccount_Street__c = false,   // アカウント 町名・番地
    RenkeiAccountZipCode__c = false,   // アカウント 郵便番号
    RenkeiAccountCity__c = false,      // アカウント 市区郡
    RenkeiAccountURL__c = false,       // アカウント URL
    RenkeiAccountCompany__c = false,   // アカウント 会社名
    RenkeiAccountPhone__c = false,     // アカウント 電話番号
    RenkeiSpecificItems__c = 'sp',        // アカウント 特定項目
    RenkeiAccountSite__c = false,        // アカウント 部署名
    RenkeiContactMail__c = false,      // コンタクト メールアドレス
    RenkeiContactLastName__c = true,  // コンタクト 姓
    RenkeiContactFirstName__c = true, // コンタクト 名
    RenkeiAccountQueryRecordTypeIds__c = '123;321',    // 検索対象のレコードタイプタイプID カンマ区切り で羅列
    RenkeiContactQueryRecordTypeIds__c = '123;321',  // 自動連携で検索対象の取引先責任者レコードタイプ
    RenkeiAccountOverwrite__c = false,   // 既存の取引先を上書き
    RenkeiContactOverwrite__c = false,   // 既存の取引先責任者を上書き
    RenkeiAccountNOExistCreateNew__c = false,  //既存の取引先がなければ新規作成する
    RenkeiContactNOExistCreateNew__c = false,  // 既存の取引先責任者がなければ新規作成する
    RenkeiAccountRecordTypes__c = '321',      // 作成するアカウント の レコードタイプID １つ
    SaishinInheritValues__c = false
    );
    Map<String,String> basicmap = SB_NameCard_NameCardBasicSettingDTO.bind(setting);
    NameCardBasicSetting__c basic = SB_NameCard_NameCardBasicSettingDTO.debind(basicmap);
    System.assertEquals(basic.RenkeiActive__c,false);
    System.assertEquals(basic.RenkeiAccountAddressPref__c,false);
    System.assertEquals(basic.RenkeiAccount_Street__c,false);
    System.assertEquals(basic.RenkeiAccountZipCode__c,false);
    System.assertEquals(basic.RenkeiAccountCity__c,false);
    System.assertEquals(basic.RenkeiAccountURL__c,false);
    System.assertEquals(basic.RenkeiAccountCompany__c,false);
    System.assertEquals(basic.RenkeiAccountPhone__c,false);
    System.assertEquals(basic.RenkeiSpecificItems__c,'sp');
    System.assertEquals(basic.RenkeiAccountSite__c,false);
    System.assertEquals(basic.RenkeiContactMail__c,false);
    System.assertEquals(basic.RenkeiContactLastName__c,true);
    System.assertEquals(basic.RenkeiContactFirstName__c,true);
    System.assertEquals(basic.RenkeiAccountQueryRecordTypeIds__c,'123;321');
    System.assertEquals(basic.RenkeiContactQueryRecordTypeIds__c,'123;321');
    System.assertEquals(basic.RenkeiAccountOverwrite__c,false);
    System.assertEquals(basic.RenkeiContactOverwrite__c,false);
    System.assertEquals(basic.RenkeiAccountNOExistCreateNew__c,false);
    System.assertEquals(basic.RenkeiContactNOExistCreateNew__c,false);
    System.assertEquals(basic.RenkeiAccountRecordTypes__c,'321');
    System.assertEquals(basic.SaishinInheritValues__c,false);
  }

  //map から NameCardBasicSetting__c true
  @isTest static void test_DTOBindSmpTrue() {
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c(
    RenkeiActive__c = true     // 自動連携機能有効
    );
    Map<String,String> basicmap = SB_NameCard_NameCardBasicSettingDTO.bindSimple(setting);
    System.assertEquals(basicmap.get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('RenkeiActive__c')),'true');
  }

 //map から NameCardBasicSetting__c falseの場合
  @isTest static void test_DTOBindSmpFalse() {
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c(
    RenkeiActive__c = false     // 自動連携機能有効
    );
    Map<String,String> basicmap = SB_NameCard_NameCardBasicSettingDTO.bindSimple(setting);
    System.assertEquals(basicmap.get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('RenkeiActive__c')),'false');
  }

}