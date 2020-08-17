/**
 *
 * SB_NCL_NameCardDTOTest
 *   各オブジェクトのレコードを 名前空間プレフィクスなしで扱えるようのクラス の既定 のテストクラス
 *
 * Copyright (C) 2017-2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2017.03.xx
 *  SB_NCL_NameCardDTOTest
 *
 *
 **/
@isTest
private class SB_NCL_NameCardDTOTest
{

  @testSetup
  static void setupNameCards() {
    List<SmartViscaf__NameCard__c> listCard = new List<SmartViscaf__NameCard__c>();
    listCard.add(new SmartViscaf__NameCard__c(
      Name='名刺 太郎'
      , SmartViscaf__person_name_last__c= '名刺'
      , SmartViscaf__person_name_first__c='太郎'
      , SmartViscaf__email__c='taro@test.com'
      , SmartViscaf__company_name__c= 'テスト株式会社'
      , SmartViscaf__division__c = '本社'
      , SmartViscaf__title_name__c = '役職'
      , SmartViscaf__tel1__c= '03-3333-3333'
      , SmartViscaf__zip_code__c = '115-0022'
      , SmartViscaf__address_pref__c = '東京都'
      , SmartViscaf__address__c = '渋谷区'
      , SmartViscaf__address_bld__c = '恵比寿1−5−5'
      , SmartViscaf__list_name__c ='名刺リスト'
      , SmartViscaf__memo__c = 'メモ'
      , SmartViscaf__freehandmemo__c = '自由記述'
      , SmartViscaf__delivery_type__c='1'
    ));
    listCard.add(new SmartViscaf__NameCard__c(
      Name='名刺 二郎'
      , SmartViscaf__person_name_last__c= '名刺'
      , SmartViscaf__person_name_first__c='二郎'
      , SmartViscaf__email__c='jiro@test.com'
      , SmartViscaf__company_name__c= 'テスト株式会社'
      , SmartViscaf__division__c = '本社'
      , SmartViscaf__title_name__c = '役職'
      , SmartViscaf__tel1__c= '03-3333-3333'
      , SmartViscaf__zip_code__c = '115-0022'
      , SmartViscaf__address_pref__c = '東京都'
      , SmartViscaf__address__c = '渋谷区'
      , SmartViscaf__address_bld__c = '恵比寿1−5−5'
      , SmartViscaf__list_name__c ='名刺リスト'
      , SmartViscaf__memo__c = 'メモ'
      , SmartViscaf__freehandmemo__c = '自由記述'
      , SmartViscaf__delivery_type__c='1'
    ));
    insert listCard;
  }

  @isTest
  static void test_Etc() {
    String query = String.format('SELECT {0} FROM SmartViscaf__NameCard__c', new String[]{ SB_NCL_NameCardDTO.NC_QUERY_FIELDS });
    List<SmartViscaf__NameCard__c> cards = Database.query(query);

    List<SB_NCL_NameCardDTO> dtos = SB_NCL_NameCardDTO.createNameCardDto(cards);
    System.assertEquals(2, dtos.size());
  }


}