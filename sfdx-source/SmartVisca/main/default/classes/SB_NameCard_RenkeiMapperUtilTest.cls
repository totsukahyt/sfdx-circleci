/**
 *
 * SB_NameCard_RenkeiMapperUtilTest   SB_NameCard_RenkeiMapperUtilテストクラス
 *
 *
 *
 *  Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author mao
 *  @Version 1      2017.02.XX
 *  @Version 2 mao 2017.10.xx No Assert v1.21 for code scan
 *
 **/

@isTest
private class SB_NameCard_RenkeiMapperUtilTest {

  //設定でオブジェクトを取得
  @isTest static void test_IsSetting() {
    Map<String,String> objDataTypeMap = new Map<String,String>();
    Map<String,String> objLabelNameMap = new Map<String,String>();
    String objlabel = '名刺';
    String record = 'NameCard__c';
    SB_NameCard_RenkeiMapperUtil.createApiNameKeyDataTypeMap(record,objDataTypeMap,objLabelNameMap,objlabel + ' : ',true);
    for(String str : objLabelNameMap.keySet()){
      System.assertEquals(objLabelNameMap.get(str).startsWith(objlabel + ' : '),true);
    }
  }

  //マッピングでオブジェクトを取得
  @isTest static void test_IstSetting() {
    Map<String,String> objDataTypeMap = new Map<String,String>();
    Map<String,String> objLabelNameMap = new Map<String,String>();
    String objlabel = '名刺';
    String record = 'NameCard__c';
    SB_NameCard_RenkeiMapperUtil.createApiNameKeyDataTypeMap(record,objDataTypeMap,objLabelNameMap,objlabel + ' : ',false);
    for(String str : objLabelNameMap.keySet()){
      System.assertEquals(objLabelNameMap.get(str).startsWith(objlabel + ' : '),true);
    }
  }

  //オブジェクトの項目Mapを作成テスト(参照先チェック用)
  @isTest static void test_GetTypeMap() {
    Map<String,Set<Schema.SObjectType>> sTypeMap = SB_NameCard_RenkeiMapperUtil.getTypeMap('Account');
    System.assertNotEquals(sTypeMap.size(), 0);  //  kou  2017.10.xx  Test Methods With No Assert  v1.21 for code scan
  }
}