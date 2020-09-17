/**
 *
 * SB_NC_DTO
 *   各オブジェクトのレコードを 名前空間プレフィクスなしで扱えるようのクラス の既定 のテストクラス
 *
 * Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2017.03.xx
 *  @Version 2      2017.10.xx  v1.21 for code scan Test Methods With No Assert
 *
 **/
@isTest
private class SB_NC_DTOTest
{

  @testSetup
  static void setupNameCards() {
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(
      Name='名刺 太郎'
      , person_name_last__c= '名刺'
      , person_name_first__c='太郎'
      , email__c='taro@test.com'
      , company_name__c= 'テスト株式会社'
      , division__c = '本社'
      , title_name__c = '役職'
      , tel1__c= '03-3333-3333'
      , zip_code__c = '115-0022'
      , address_pref__c = '東京都'
      , address__c = '渋谷区'
      , address_bld__c = '恵比寿1−5−5'
      , list_name__c ='名刺リスト'
      , memo__c = 'メモ'
      , freehandmemo__c = '自由記述'
      , delivery_type__c='1'
    ));
    listCard.add(new NameCard__c(
      Name='名刺 二郎'
      , person_name_last__c= '名刺'
      , person_name_first__c='二郎'
      , email__c='jiro@test.com'
      , company_name__c= 'テスト株式会社'
      , division__c = '本社'
      , title_name__c = '役職'
      , tel1__c= '03-3333-3333'
      , zip_code__c = '115-0022'
      , address_pref__c = '東京都'
      , address__c = '渋谷区'
      , address_bld__c = '恵比寿1−5−5'
      , list_name__c ='名刺リスト'
      , memo__c = 'メモ'
      , freehandmemo__c = '自由記述'
      , delivery_type__c='1'
    ));
    System.assertEquals(2, listCard.size());  // 2017.10.xx  v1.21 for code scan Test Methods With No Assert
    insert listCard;
  }

  @isTest
  static void test_getInstanceSingle() {
    List<NameCard__c> cards = [SELECT ID, Name, person_name_last__c, person_name_first__c, email__c FROM NameCard__c];
    SB_NC_NameCardDTO dto = (SB_NC_NameCardDTO)SB_NC_DTO.getInstance(cards[0]);
    System.assertEquals(cards[0].Name, dto.name);
  }

  @isTest
  static void test_getInstanceList() {
    List<NameCard__c> cards = [SELECT ID, Name, person_name_last__c, person_name_first__c, email__c FROM NameCard__c];
    List<SB_NC_DTO> dtos = SB_NC_DTO.getInstance(cards);
    System.assertEquals(cards.size(), dtos.size());
  }

}