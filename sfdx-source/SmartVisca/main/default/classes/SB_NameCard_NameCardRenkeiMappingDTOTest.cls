/**
 *
 * SB_NameCard_NameCardRenkeiMappingDTOTest
 * SB_NameCard_NameCardRenkeiMappingDTOのテストクラス
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
private class SB_NameCard_NameCardRenkeiMappingDTOTest {

  //NameCardRenkeiMapping__c -> bin
  @isTest static void test_Bind() {
    NameCardRenkeiMapping__c mapp = new NameCardRenkeiMapping__c();
    mapp.TargetName__c = 'tarname';
    mapp.NameCardName__c = 'ncname';
    mapp.IsActive__c = true;
    SB_NameCard_NameCardRenkeiMappingDTO dto = new SB_NameCard_NameCardRenkeiMappingDTO();
    dto.bind(mapp);
    System.assertEquals(dto.TargetName,'tarname');
    System.assertEquals(dto.NameCardName,'ncname');
    System.assertEquals(dto.IsActive,'true');
  }

  //bin -> NameCardRenkeiMapping__c
  @isTest static void test_DeBind() {
    NameCardRenkeiMapping__c mapp = new NameCardRenkeiMapping__c();
    mapp.TargetName__c = 'tarname';
    mapp.NameCardName__c = 'ncname';
    mapp.IsActive__c = true;
    SB_NameCard_NameCardRenkeiMappingDTO dto = new SB_NameCard_NameCardRenkeiMappingDTO();
    dto.bind(mapp);
    NameCardRenkeiMapping__c maap = dto.debind();
    System.assertEquals(maap.TargetName__c,'tarname');
    System.assertEquals(maap.NameCardName__c,'ncname');
    System.assertEquals(maap.IsActive__c,true);
  }

}