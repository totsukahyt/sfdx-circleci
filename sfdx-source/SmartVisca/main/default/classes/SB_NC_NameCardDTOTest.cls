/**
 *
 *  SB_NC_NameCardDTOTest
 *
 *  SB_NC_NameCardDTO のテストクラス
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1     v2.4 2019.06.xx 2019.05.24 SV_DEV-1794 S1 新SmartViscaタブ：名刺情報の編集画面で「Unknown field: SmartViscaf.SB_NC_NameCardDTO.currencyIsoCode」エラーになる（Salesforceのマルチ通貨の有効環境）
 *
 **/
@isTest
private class SB_NC_NameCardDTOTest
{

//  StandardController でのテスト
  @isTest
  static void test_buildNomalizeKeyMap_ignoreFields() {
    List<NameCard__c> listCard = new List<NameCard__c>();
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='株式会社テスト商事', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='一郎', email__c='ichiro@test.com', delivery_type__c='2'));
    listCard.add(new NameCard__c(Name='テスト 一郎', company_name__c='（株）　サンプル物産', division__c='本社',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-5555-5555', tel2__c = '03-6666-6666', // 電話番号
                    last_name__c='テスト', first_name__c='一郎', email__c='ichiro@sample.com', delivery_type__c='2'));

    insert listCard;

    Map<String, Object>  f2v = SB_NC_NameCardDTO.buildNomalizeKeyMap([SELECT Id, Name, LastModifiedDate FROM NameCard__c LIMIT 1]);
    System.assertEquals(false, f2v.containsKey('lastModifiedDate'));

  }

}
