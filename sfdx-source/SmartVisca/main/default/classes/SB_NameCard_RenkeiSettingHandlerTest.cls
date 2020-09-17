/**
 * SB_NameCard_RenkeiSettingHandlerTest
 * SB_NameCard_RenkeiSettingTriggerのテストクラス
 *
 *
 * Copyright (C) 2012-2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author gao
 *  History :
 *  @Version 1.20      2017.3.XX
 *
 **/

@isTest
private class SB_NameCard_RenkeiSettingHandlerTest {

  public static void setsetting() {
    NameCardBasicSetting__c bas = new NameCardBasicSetting__c();
    insert bas;
  }

  //連携条件を差込
  @isTest static void test_Insert() {
    setsetting();
    List<NameCardBasicSetting__c> bas = [Select Id,Name,MConditionLastModifiedUser__c From NameCardBasicSetting__c];
    System.assertEquals(bas.size(),1);
    NameCardRenkeiJyoken__c jyo = new NameCardRenkeiJyoken__c();
    jyo.Operator__c = 'Start_with_the_following_string';
    jyo.Value__c = 'test';
    jyo.NameCardName__c = 'Name';
    jyo.NameCardDataType__c = 'String';
    insert jyo;
    NameCardRenkeiJyoken__c jy = [Select Id,Name,BasicSetting__c From NameCardRenkeiJyoken__c Where Id=:jyo.Id];
    List<NameCardBasicSetting__c> bas1 = [Select Id,Name,MConditionLastModifiedUser__c From NameCardBasicSetting__c];
    System.assertEquals(jy.BasicSetting__c,bas1[0].Id);
    System.assertEquals(bas1[0].MConditionLastModifiedUser__c,UserInfo.getUserId());
  }

  //連携条件を更新
  @isTest static void test_Update() {
    setsetting();
    List<NameCardBasicSetting__c> bas = [Select Id,Name,MConditionLastModifiedUser__c From NameCardBasicSetting__c];
    System.assertEquals(bas.size(),1);
    NameCardRenkeiJyoken__c jyo = new NameCardRenkeiJyoken__c();
    jyo.Operator__c = 'Start_with_the_following_string';
    jyo.Value__c = 'test';
    jyo.NameCardName__c = 'Name';
    jyo.NameCardDataType__c = 'String';
    insert jyo;
    NameCardRenkeiJyoken__c jy = [Select Id,Name,BasicSetting__c From NameCardRenkeiJyoken__c Where Id=:jyo.Id];
    List<NameCardBasicSetting__c> bas1 = [Select Id,Name,MConditionLastModifiedUser__c From NameCardBasicSetting__c];
    System.assertEquals(jy.BasicSetting__c,bas1[0].Id);
    System.assertEquals(bas1[0].MConditionLastModifiedUser__c,UserInfo.getUserId());

    jyo.Value__c = 'test2';
    update jyo;
  }

}