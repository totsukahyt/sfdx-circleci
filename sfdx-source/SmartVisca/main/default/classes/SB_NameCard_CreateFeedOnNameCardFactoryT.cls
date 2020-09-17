/**
 *
 * SB_NameCard_CreateFeedOnNameCardFactoryT
 *    SB_NameCard_CreateFeedOnNameCardFactory のテストクラス
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  History :
 *  @Version 1 v 2.4    2019.07.xx  初版
 *
 **/
@isTest
private class SB_NameCard_CreateFeedOnNameCardFactoryT {

  // テストクラスで ConnectApi は SeeAllData でないと使えない
  @isTest(SeeAllData=true)
  static void test_isEnableFeedItem() {
    System.assertEquals(ConnectApi.Organization.getSettings().features.chatter, SB_NameCard_CreateFeedOnNameCardFactory.enableFeedItem);
  }

  @isTest
  static void test_create_SB_NameCard_CreateFeedOnNameCard() {
    SB_NameCard_CreateFeedOnNameCardFactory factory = new SB_NameCard_CreateFeedOnNameCardFactory();
    SB_NameCard_CreateFeedOnNameCardFactory.CreateFeedOnNameCardBuilder builder = factory.createBuilder();
    System.assert(builder instanceOf SB_NameCard_CreateFeedOnNameCard);
  }

  @isTest
  static void test_create_SB_NameCard_CreateFeedOnNCardApiBuilder_toOwners() {
    SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    svConfig.FeedOnNameCardMentionToOwners__c = true;  // 同じ人と名刺交換したフィードを名刺所有者にメンションする
    // svConfig.FeedOnNameCardMentionToGroups__c = '名刺交換共有グループ\nその他のグループ'; // 同じ人と名刺交換したフィードをメンションするグループ
    // svConfig.FeedOnNameCardTopic__c = '最新の名刺ですよ {0}{1}{2}';
    upsert svConfig;

    SB_NameCard_CreateFeedOnNameCardFactory factory = new SB_NameCard_CreateFeedOnNameCardFactory();
    SB_NameCard_CreateFeedOnNameCardFactory.CreateFeedOnNameCardBuilder builder = factory.createBuilder();
    System.assert(builder instanceOf SB_NameCard_CreateFeedOnNCardApiBuilder);
  }

  @isTest
  static void test_create_SB_NameCard_CreateFeedOnNCardApiBuilder_toGroups() {
    SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    // svConfig.FeedOnNameCardMentionToOwners__c = true;  // 同じ人と名刺交換したフィードを名刺所有者にメンションする
    svConfig.FeedOnNameCardMentionToGroups__c = '名刺交換共有グループ\nその他のグループ'; // 同じ人と名刺交換したフィードをメンションするグループ
    // svConfig.FeedOnNameCardTopic__c = '最新の名刺ですよ {0}{1}{2}';
    upsert svConfig;

    SB_NameCard_CreateFeedOnNameCardFactory factory = new SB_NameCard_CreateFeedOnNameCardFactory();
    SB_NameCard_CreateFeedOnNameCardFactory.CreateFeedOnNameCardBuilder builder = factory.createBuilder();
    System.assert(builder instanceOf SB_NameCard_CreateFeedOnNCardApiBuilder);
  }

  @isTest
  static void test_create_SB_NameCard_CreateFeedOnNCardApiBuilder_topic() {
    SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    svConfig.FeedOnNameCardMentionToOwners__c = true;  // 同じ人と名刺交換したフィードを名刺所有者にメンションする
    svConfig.FeedOnNameCardMentionToGroups__c = '名刺交換共有グループ\nその他のグループ'; // 同じ人と名刺交換したフィードをメンションするグループ
    svConfig.FeedOnNameCardTopic__c = '最新の名刺ですよ {0}{1}{2}';
    upsert svConfig;

    SB_NameCard_CreateFeedOnNameCardFactory factory = new SB_NameCard_CreateFeedOnNameCardFactory();
    SB_NameCard_CreateFeedOnNameCardFactory.CreateFeedOnNameCardBuilder builder = factory.createBuilder();
    System.assert(builder instanceOf SB_NameCard_CreateFeedOnNCardApiBuilder);
  }

}