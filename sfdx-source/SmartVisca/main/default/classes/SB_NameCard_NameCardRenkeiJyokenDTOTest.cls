/**
 *
 * SB_NameCard_NameCardRenkeiJyokenDTOTest
 * SB_NameCard_NameCardRenkeiJyokenDTOのテストクラス
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
private class SB_NameCard_NameCardRenkeiJyokenDTOTest {

  //NameCardRenkeiJyoken__c -> bin
  @isTest static void test_Bind() {
    NameCardRenkeiJyoken__c jyo = new NameCardRenkeiJyoken__c();
    jyo.Operator__c = 'test';
    jyo.NameCardName__c = 'Name';
    jyo.NameCardDataType__c = 'STRING';
    jyo.Value__c = 'testdata';
    SB_NameCard_NameCardRenkeiJyokenDTO dto = new SB_NameCard_NameCardRenkeiJyokenDTO();
    dto.bind(jyo);
    System.assertEquals(dto.Operator,'test');
    System.assertEquals(dto.NameCardName,'Name');
    System.assertEquals(dto.NameCardDataType,'STRING');
    System.assertEquals(dto.Value,'testdata');
  }

  //bin -> NameCardRenkeiJyoken__c
  @isTest static void test_DeBind() {
    NameCardRenkeiJyoken__c jyo = new NameCardRenkeiJyoken__c();
    jyo.Operator__c = 'test';
    jyo.NameCardName__c = 'Name';
    jyo.NameCardDataType__c = 'STRING';
    jyo.Value__c = 'testdata';
    SB_NameCard_NameCardRenkeiJyokenDTO dto = new SB_NameCard_NameCardRenkeiJyokenDTO();
    dto.bind(jyo);
    NameCardRenkeiJyoken__c dto2 = dto.debind();
    System.assertEquals(dto2.Operator__c,'test');
    System.assertEquals(dto2.NameCardName__c,'Name');
    System.assertEquals(dto2.NameCardDataType__c,'STRING');
    System.assertEquals(dto2.Value__c,'testdata');
  }

}