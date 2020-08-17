/**
 *
 *  SB_NameCardL_RenkeiTriggerHandlerTest
 *    SB_NameCardL_RenkeiTriggerHandler のテストクラス
 *
 * Copyright (C) 2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  lx 2.0    2018.06.xx
 *
 **/
@isTest
private class SB_NameCardL_RenkeiTriggerHandlerTest
{

  @isTest
  static void test_nope_methods()
  {
    List<SmartViscaf__NameCard__c> cards = new List<SmartViscaf__NameCard__c>();
    cards.add(new SmartViscaf__NameCard__c(
              Name = '恵比寿 太郎'
              , SmartViscaf__person_name_last__c = '恵比寿'
              , SmartViscaf__person_name_first__c = '太郎'
              , SmartViscaf__email__c = 'user01@sunbridge.com'
              , SmartViscaf__company_name__c= 'サンブリッジ株式会社'
              , SmartViscaf__division__c = '開発部'
              , SmartViscaf__title_name__c = '課長'
              , SmartViscaf__delivery_type__c = '1'));
    insert cards;
    cards = [SELECT Id, Name FROM SmartViscaf__NameCard__c];
    Map<Id, SmartViscaf__NameCard__c> id2Obj = new Map<Id, SmartViscaf__NameCard__c>(cards);
    // トリガハンドラ クラスのインスタンス化
    SB_NameCardL_RenkeiTriggerHandler handler = new SB_NameCardL_RenkeiTriggerHandler();
    handler.onAfterInsert(cards);
    handler.onAfterUpdate(cards, id2Obj);
    handler.onBeforeDelete(cards, id2Obj);
    handler.onAfterDelete(cards, id2Obj);
    handler.onUndelete(cards);
    System.assert(!cards.isEmpty());
  }
}