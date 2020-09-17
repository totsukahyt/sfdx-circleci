/**
 *
 * SB_NameCard_TagAndListCollectorTest2
 *  SB_NameCard_TagAndListCollectorテストクラス 大量データ用
 *      Copyright (C) 2020 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 2.5    2020.04.xx
 *
 **/
@isTest
private class SB_NameCard_TagAndListCollectorTest2 {

  // v2.5 リスト名がばらばらで2000種超、2000名刺レコード超
  @isTest static void test_GetTagsRequest_listname_over2000() {
    if (String.isNotBlank(SB_NameCard_Util.getNamespacePrefix())) {
      List<SObject> cards = Test.loadData(NameCard__c.getSObjectType(), 'SB_NC_Records_Card5000');
      System.assert(cards.size() > 2000);
      System.assertEquals(cards.size(), [SELECT Id FROM NameCard__c WHERE list_name__c!=null].size());
      SB_NameCard_TagAndListCollector.GetTagsRequest req = new SB_NameCard_TagAndListCollector.GetTagsRequest();
      req.type = 2;
      SB_NameCard_TagAndListCollector.GetTagsRequest instance = new SB_NameCard_TagAndListCollector.GetTagsRequest(req);

      List<SB_NameCard_TagAndListCollector.NameCardTagOrList> response = instance.create();
      System.assertEquals(2000, response.size());
    }
  }

  // v2.5 個人タグがばらばらで2000種超、2000レコード超
  @isTest static void test_GetTagsRequest_tag_over2000() {
    SB_NameCard_Util.smartViscaConfig.TriggerRegDateTime__c = true;
    SB_NameCard_Util.smartViscaConfig.TriggerCreateFeedOnName__c = false;
    SB_NameCard_Util.smartViscaConfig.TriggerMergeNameCards__c = false;
    SB_NameCard_Util.smartViscaConfig.TriggerHistoryIsActive__c = false;
    SB_NameCard_Util.smartViscaConfig.TriggerRenkeiTriggerHandler__c = false; // 2018.03.xx v1.22  自動連携のトリガハンドラを呼ぶ

    if (String.isNotBlank(SB_NameCard_Util.getNamespacePrefix()) && SB_NameCard_TagAndListCollector.enableNameCardTagPersonal) {
      List<SObject> cards = Test.loadData(NameCard__c.getSObjectType(), 'SB_NC_Records_Card5000');
      System.assert(cards.size() > 2000);
      cards = [SELECT Id FROM NameCard__c];
      List<SObject> tags = new List<SObject>();
      Schema.SObjectType otype = Schema.getGlobalDescribe().get(SB_NameCard_Util.getNamespacePrefix_x() + 'NameCard__Tag');
      for (Integer n = 0; n < 2001; n++) {
        SObject tag = otype.newSObject();
        tag.put('Name', '個人タグ' + String.valueOf(n));
        tag.put('Type', 'Personal');
        tag.put('ItemId', cards[n].Id);
        tags.add(tag);
      }
      insert tags;

      tags = DataBase.query('SELECT Id FROM NameCard__Tag WHERE Type=\'Personal\' AND Name!=null');
      System.assertEquals(2001, tags.size());

      SB_NameCard_TagAndListCollector.GetTagsRequest req = new SB_NameCard_TagAndListCollector.GetTagsRequest();
      req.type = 1;
      SB_NameCard_TagAndListCollector.GetTagsRequest instance = new SB_NameCard_TagAndListCollector.GetTagsRequest(req);
      List<SB_NameCard_TagAndListCollector.NameCardTagOrList> response = instance.create();
      System.assertEquals(0, response.size()); // 本当は2000だけど、テストだとTagDefinition のQUERYで 0件
    }
    else {
      SB_NameCard_TagAndListCollector.GetTagsRequest req = new SB_NameCard_TagAndListCollector.GetTagsRequest();
      req.type = 1;
      SB_NameCard_TagAndListCollector.GetTagsRequest instance = new SB_NameCard_TagAndListCollector.GetTagsRequest(req);
      List<SB_NameCard_TagAndListCollector.NameCardTagOrList> response = instance.create();
      System.assertEquals(0, response.size());
    }
  }

}