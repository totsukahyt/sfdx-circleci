/**
 *
 *  SB_NameCard_TriggerHandlerDummyTest
 *   ダミーの トリガハンドラを呼ぶテストクラス
 *
 *  Copyright (C) 2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 2.0      2018.04.xx
 *
 **/
@isTest
private class SB_NameCard_TriggerHandlerDummyTest {

  @isTest
  static void test_TriggerHandlerDummyFromFactory() {
    List<NameCard__c> listObjs = new List<NameCard__c>();
    listObjs.add(new NameCard__c(Name='山田 太郎', company_name__c='テスト商事有限会社', last_name__c='山田', first_name__c='太郎'));
    listObjs.add(new NameCard__c(Name='鈴木 花子', company_name__c='サンプル商事有限会社', last_name__c='鈴木', first_name__c='花子'));
    insert listObjs;
    listObjs = [SELECT Id, Name FROM NameCard__c];
    Map<Id, NameCard__c> mapObjs = new Map<Id, NameCard__c>(listObjs);

    // SB_NameCard_TriggerHandlerFactory を使ってインスタンスをつくる
    SB_NameCard_TriggerHandlerAbstract handler = SB_NameCard_TriggerHandlerFactory.getInstance(null, 'SB_NameCard_TriggerHandlerDummy');
    handler.onBeforeInsert(listObjs);
    System.assertEquals(true, handler.didInsert());
    handler.onBeforeUpdate(listObjs, mapObjs);
    System.assertEquals(true, handler.didUpdate());
    handler.onBeforeDelete(listObjs, mapObjs);
    System.assertEquals(true, handler.didDelete());
    handler.onAfterInsert(listObjs);
    handler.onAfterUpdate(listObjs, mapObjs);
    handler.onAfterDelete(listObjs, mapObjs);
    handler.onUndelete(listObjs);
    System.assertEquals(true, handler.didUndelete());
  }

  @isTest
  static void test_TriggerHandlerDummyMethods() {
    List<NameCard__c> listObjs = new List<NameCard__c>();
    listObjs.add(new NameCard__c(Name='山田 太郎', company_name__c='テスト商事有限会社', last_name__c='山田', first_name__c='太郎'));
    listObjs.add(new NameCard__c(Name='鈴木 花子', company_name__c='サンプル商事有限会社', last_name__c='鈴木', first_name__c='花子'));
    insert listObjs;
    listObjs = [SELECT Id, Name FROM NameCard__c];
    Map<Id, NameCard__c> mapObjs = new Map<Id, NameCard__c>(listObjs);

    // 直接クラスを new して インスタンスをつくる
    SB_NameCard_TriggerHandlerDummy handler = new SB_NameCard_TriggerHandlerDummy();
    handler.onBeforeInsert(listObjs);
    System.assertEquals(true, handler.didInsert());
    handler.onBeforeUpdate(listObjs, mapObjs);
    System.assertEquals(true, handler.didUpdate());
    handler.onBeforeDelete(listObjs, mapObjs);
    System.assertEquals(true, handler.didDelete());
    handler.onAfterInsert(listObjs);
    handler.onAfterUpdate(listObjs, mapObjs);
    handler.onAfterDelete(listObjs, mapObjs);
    handler.onUndelete(listObjs);
    System.assertEquals(true, handler.didUndelete());
  }

  @isTest
  static void test_TriggerHandlerDummyConstructor2() {
    String o = 'DUMMY';
    SB_NameCard_TriggerHandlerDummy handler = new SB_NameCard_TriggerHandlerDummy(o);

    System.assertEquals(false, handler.didInsert());
    System.assertEquals(false, handler.didUpdate());
    System.assertEquals(false, handler.didDelete());
    System.assertEquals(false, handler.didUndelete());
  }




}