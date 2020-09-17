/**
 *
 * SB_NameCard_TagAndListCollectorTest
 *  SB_NameCard_TagAndListCollectorテストクラスタ
 *      Copyright (C) 2020 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 2.5    2020.03.xx
 *
 **/
@isTest
private class SB_NameCard_TagAndListCollectorTest {

  @TestSetup
  static void setupDB() {

    SmartViscaConfig__c config = new SmartViscaConfig__c();
    insert config;

    // 名刺　リスト名付きで追加
    List<NameCard__c> listCard = new List<NameCard__c>();
    for (Integer n=1; n<=10; n++) {
      String firstname = String.valueof(n) + '太郎';
      String email = String.valueof(n) + '@test.com';
      listCard.add(new NameCard__c(Name='テスト '+firstname, company_name__c='株式会社 テスト商事', last_name__c='テスト', first_name__c=firstname, email__c=email, list_name__c='リスト名'));
    }
    insert listCard;
    if (SB_NameCard_TagAndListCollector.enableNameCardTagPersonal) {
      // 名刺の個人タグが有効
      List<SObject> tags = new List<SObject>();
      for (NameCard__c card : listCard) {
        tags.add(createNameCardTag(card.Id, '個人タグ１', 'Personal'));
        tags.add(createNameCardTag(card.Id, '個人タグ２', 'Personal'));
        tags.add(createNameCardTag(card.Id, '個人タグ３', 'Personal'));
      }
      insert tags;
    }
  }

  private static SObject createNameCardTag(Id cardId, String label, String type) {
    Schema.SObjectType targetType = Schema.getGlobalDescribe().get(SB_NameCard_Util.getNamespacePrefix_x() + 'NameCard__Tag');
    SObject result = targetType.newSObject();
    result.put('Name', label);
    result.put('Type', type);
    result.put('ItemId', cardId);
    return result;
  }


  @isTest static void test_GetTagsRequest_tag() {
    SB_NameCard_TagAndListCollector.GetTagsRequest req = new SB_NameCard_TagAndListCollector.GetTagsRequest();
    req.type = 1;
    SB_NameCard_TagAndListCollector.GetTagsRequest instance = new SB_NameCard_TagAndListCollector.GetTagsRequest(req);

    List<SB_NameCard_TagAndListCollector.NameCardTagOrList> tags = instance.create();
    if (SB_NameCard_TagAndListCollector.enableNameCardTagPersonal) {
      Set<String> names = new Set<String> {'個人タグ１', '個人タグ２', '個人タグ３'};
      List<SObject> tagds = DataBase.query('SELECT Id, Name, Type FROM TagDefinition WHERE Name IN :names AND Type=\'Personal\'');
      System.assertEquals(tagds.size(), tags.size());  // テストだとTagDefinition のQUERYで 0件
    }
    else {
      System.assertEquals(0, tags.size());
    }
  }

  @isTest static void test_GetTagsRequest_list() {
    SB_NameCard_TagAndListCollector.GetTagsRequest req = new SB_NameCard_TagAndListCollector.GetTagsRequest();
    req.type = 2;
    SB_NameCard_TagAndListCollector.GetTagsRequest instance = new SB_NameCard_TagAndListCollector.GetTagsRequest(req);

    List<SB_NameCard_TagAndListCollector.NameCardTagOrList> tags = instance.create();
    System.assertEquals(1, tags.size());
  }

  @isTest static void test_GetTagsRequest_both() {
    SB_NameCard_TagAndListCollector.GetTagsRequest req = new SB_NameCard_TagAndListCollector.GetTagsRequest();
    req.type = 0;
    SB_NameCard_TagAndListCollector.GetTagsRequest instance = new SB_NameCard_TagAndListCollector.GetTagsRequest(req);

    List<SB_NameCard_TagAndListCollector.NameCardTagOrList> tags = instance.create();
    if (SB_NameCard_TagAndListCollector.enableNameCardTagPersonal) {
      Set<String> names = new Set<String> {'個人タグ１', '個人タグ２', '個人タグ３'};
      List<SObject> tagds = DataBase.query('SELECT Id, Name, Type FROM TagDefinition WHERE Name IN :names AND Type=\'Personal\'');
      System.assertEquals(tagds.size()+1, tags.size());  // テストだとTagDefinition のQUERYで 0件
    }
    else {
      System.assertEquals(1, tags.size());
    }
  }

  @isTest static void test_TagdNameCardsRequest_mine() {
    SB_NameCard_Util.smartViscaConfig.TaggedCardsFetchMethod__c = 0;
    SB_NameCard_TagAndListCollector.TagdNameCardsRequest instance = new SB_NameCard_TagAndListCollector.TagdNameCardsRequest();

    List<SB_NameCard_TagAndListCollector.TagdNameCards> tagdCards = instance.create();
    if (SB_NameCard_TagAndListCollector.enableNameCardTagPersonal) {
      System.assertEquals(4, tagdCards.size());  // テストだとTagDefinition のQUERYで 0件
    }
    else {
      System.assertEquals(1, tagdCards.size());
    }
  }

  @isTest static void test_TagdNameCardsRequest_org() {
    SB_NameCard_Util.smartViscaConfig.TaggedCardsFetchMethod__c = 1;
    SB_NameCard_TagAndListCollector.TagdNameCardsRequest instance = new SB_NameCard_TagAndListCollector.TagdNameCardsRequest();

    List<SB_NameCard_TagAndListCollector.TagdNameCards> tagdCards = instance.create();
    if (SB_NameCard_TagAndListCollector.enableNameCardTagPersonal) {
      System.assertEquals(4, tagdCards.size());  // テストだとTagDefinition のQUERYで 0件
    }
    else {
      System.assertEquals(1, tagdCards.size());
    }
  }

  @isTest static void test_TagdNameCardsRequest_limit() {
    SB_NameCard_Util.smartViscaConfig.TaggedCardsFetchMethod__c = 2;
    SB_NameCard_TagAndListCollector.TagdNameCardsRequest instance = new SB_NameCard_TagAndListCollector.TagdNameCardsRequest();

    List<SB_NameCard_TagAndListCollector.TagdNameCards> tagdCards = instance.create();
    if (SB_NameCard_TagAndListCollector.enableNameCardTagPersonal) {
      System.assertEquals(4, tagdCards.size());  // テストだとTagDefinition のQUERYで 0件
    }
    else {
      System.assertEquals(1, tagdCards.size());
    }
  }


}