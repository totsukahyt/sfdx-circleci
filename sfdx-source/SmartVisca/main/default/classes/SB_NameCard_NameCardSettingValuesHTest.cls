/**
 * Copyright (c) 2011-2015 SunBridge
 *
 * SB_NameCard_NameCardSettingValuesHandler TestClass
 *
 *  @author gao
 *  @Version 2.1      2018.04.xx SV_DEV-865 名刺基本設定オブジェクトのトリガを作って不正な値で保存されたらエラーにする。
 *
 **/
 @isTest
public with sharing class SB_NameCard_NameCardSettingValuesHTest {
  /**
   * @description 名刺設定値新規 -> テキスト値01:標準項目test
  */
  public static testMethod void createNameCardSettingValuesStan(){
    NameCardSettingValues__c ncsv = new NameCardSettingValues__c(TextValue01__c = 'Name',
                                                                Type__c = 'SaishinInherit',
                                                                Index__c = 1);
    Database.SaveResult lsr = Database.insert(ncsv, false);
    System.assertEquals(true, lsr.isSuccess());
    System.assertEquals(0, lsr.getErrors().size());
  }

  /**
   * @description 名刺設定値新規 -> テキスト値01:カスタム項目test
  */
  public static testMethod void createNameCardSettingValuesCustom(){
    NameCardSettingValues__c ncsv = new NameCardSettingValues__c(TextValue01__c = SB_NameCard_RenkeiMapperUtil.getManagedfileName('namecard__c', 'company_name__c'),
                                                                Type__c = 'SaishinInherit',
                                                                Index__c = 1);
    Database.SaveResult lsr = Database.insert(ncsv, false);
    System.assertEquals(true, lsr.isSuccess());
    System.assertEquals(0, lsr.getErrors().size());
  }

  /**
   * @description 名刺設定値新規 -> テキスト値01:無し
  */
  public static testMethod void createNameCardSettingValuesNotValue(){
    NameCardSettingValues__c ncsv = new NameCardSettingValues__c(TextValue01__c = '',
                                                                Type__c = 'SaishinInherit',
                                                                Index__c = 1);
    Database.SaveResult lsr = Database.insert(ncsv, false);
    System.assertEquals(true, lsr.isSuccess());
    System.assertEquals(0, lsr.getErrors().size());
  }

  /**
   * @description 名刺設定値新規 -> テキスト値01:存在しない
  */
  public static testMethod void createNameCardSettingValuesWrongValue(){
    NameCardSettingValues__c ncsv = new NameCardSettingValues__c(TextValue01__c = 'Test',
                                                                Type__c = 'SaishinInherit',
                                                                Index__c = 1);
    Database.SaveResult lsr = Database.insert(ncsv, false);
    System.assertEquals(false, lsr.isSuccess());
    System.assertEquals(1, lsr.getErrors().size());
    System.assertEquals(String.format(System.Label.SB_NC_MAPPING_Ingert_ErrorMessage, new String[]{'Test'}), lsr.getErrors()[0].getMessage());
  }


  /**
   * @description 名刺設定値更新 -> テキスト値01:標準項目test
  */
  public static testMethod void updateNameCardSettingValuesStan(){
    NameCardSettingValues__c ncsv = new NameCardSettingValues__c(Type__c = 'SaishinInherit',
                                                                Index__c = 1);
    insert ncsv;
    ncsv.TextValue01__c = 'Name';
    Database.SaveResult lsr = Database.update(ncsv, false);
    System.assertEquals(true, lsr.isSuccess());
    System.assertEquals(0, lsr.getErrors().size());
  }

  /**
   * @description 名刺設定値更新 -> テキスト値01:カスタム項目test
  */
  public static testMethod void updateNameCardSettingValuesCustom(){
    NameCardSettingValues__c ncsv = new NameCardSettingValues__c(Type__c = 'SaishinInherit',
                                                                Index__c = 1);
    insert ncsv;
    ncsv.TextValue01__c = SB_NameCard_RenkeiMapperUtil.getManagedfileName('namecard__c', 'company_name__c');
    Database.SaveResult lsr = Database.update(ncsv, false);
    System.assertEquals(true, lsr.isSuccess());
    System.assertEquals(0, lsr.getErrors().size());
  }

  /**
   * @description 名刺設定値更新 -> テキスト値01:無し
  */
  public static testMethod void updateNameCardSettingValuesNotValue(){
    NameCardSettingValues__c ncsv = new NameCardSettingValues__c(Type__c = 'SaishinInherit',
                                                                Index__c = 1);
    insert ncsv;
    ncsv.TextValue01__c = '';
    Database.SaveResult lsr = Database.update(ncsv, false);
    System.assertEquals(true, lsr.isSuccess());
    System.assertEquals(0, lsr.getErrors().size());
  }

  /**
   * @description 名刺設定値更新 -> テキスト値01:存在しない
  */
  public static testMethod void updateNameCardSettingValuesWrongValue(){
    NameCardSettingValues__c ncsv = new NameCardSettingValues__c(Type__c = 'SaishinInherit',
                                                                Index__c = 1);
    insert ncsv;
    ncsv.TextValue01__c = 'Test';
    Database.SaveResult lsr = Database.update(ncsv, false);
    System.assertEquals(false, lsr.isSuccess());
    System.assertEquals(1, lsr.getErrors().size());
    System.assertEquals(String.format(System.Label.SB_NC_MAPPING_Ingert_ErrorMessage, new String[]{'Test'}), lsr.getErrors()[0].getMessage());
  }
}