/**
 *
 * SB_NameCard_RenkeiMappingHandlerTest    (SB_NameCard_RenkeiMappingHandlerのテストクラス)
 *  連携マッピングを変化があった時基本設定の更新
 *
 *  Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author gao
 *  @Version 1.20      2017.02.XX
 *
 **/
@isTest
private class SB_NameCard_RenkeiMappingHandlerTest {

  public static void setsetting() {
    NameCardBasicSetting__c bas = new NameCardBasicSetting__c();
    insert bas;
  }

  //連携マッピングを新規作成時の基本設定の更新
  @isTest static void test_Insert() {
    setsetting();
    List<NameCardBasicSetting__c> bas = [Select Id,Name,MappingLastModifiedUser__c From NameCardBasicSetting__c];
    System.assertEquals(bas.size(),1);
    NameCardRenkeiMapping__c mapping = new NameCardRenkeiMapping__c();
    mapping.TargetName__c = 'Name';
    mapping.NameCardName__c = 'Name';
    insert mapping;
    NameCardRenkeiMapping__c jy = [Select Id,Name,BasicSetting__c From NameCardRenkeiMapping__c Where Id=:mapping.Id];
    List<NameCardBasicSetting__c> bas1 = [Select Id,Name,MappingLastModifiedUser__c From NameCardBasicSetting__c];
    System.assertEquals(jy.BasicSetting__c,bas1[0].Id);
    System.assertEquals(bas1[0].MappingLastModifiedUser__c,UserInfo.getUserId());
  }

  //連携マッピングを更新時の基本設定の更新
  @isTest static void test_Update() {
    setsetting();
    List<NameCardBasicSetting__c> bas = [Select Id,Name,MappingLastModifiedUser__c From NameCardBasicSetting__c];
    System.assertEquals(bas.size(),1);
    NameCardRenkeiMapping__c mapping = new NameCardRenkeiMapping__c();
    mapping.TargetName__c = 'Name';
    mapping.NameCardName__c = 'Name';
    insert mapping;
    NameCardRenkeiMapping__c jy = [Select Id,Name,BasicSetting__c From NameCardRenkeiMapping__c Where Id=:mapping.Id];
    List<NameCardBasicSetting__c> bas1 = [Select Id,Name,MappingLastModifiedUser__c From NameCardBasicSetting__c];
    System.assertEquals(jy.BasicSetting__c,bas1[0].Id);
    System.assertEquals(bas1[0].MappingLastModifiedUser__c,UserInfo.getUserId());
    mapping.NameCardName__c = 'Phone';
    update mapping;
  }
}