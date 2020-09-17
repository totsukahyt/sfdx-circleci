/**
 *
 * SB_NameCard_CreateFeedOnNameCardFactory
 * 名刺の追加時、既存の名刺の最新名刺を更新するので、そのとき、既存名刺の所有者にフィードで、通知します。
 *     v2.3 までは SB_NameCard_CreateFeedOnNameCard でやってた機能です。 
 *      メンション可能、トピック指定可能 にして、新ハンドラと旧ハンドラと切り分ける
 *      SV_DEV-1632 同じ人との名刺交換のフィード通知がメールでも通知されるようにする
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  History :
 *      SB_NameCard_createFeedOnNameCard.trigger の移植
 *  @Version 2      2014.4.2x
 *                  2014.7.11 動的APEX対応
 *                  2014.08.20 フィード内のリンクを 従来、最新の名刺の値が更新になった古い名刺を指してましたが、最新の名刺へのリンクへ変更
 *  @Version 2.4    2019.07.xx  初版 メンション可能、トピック指定可能 にして、新ハンドラと旧ハンドラと切り分ける
 *
 **/
public with sharing class SB_NameCard_CreateFeedOnNameCardFactory {

  // フィードを作成する実態のクラスの Interface 
  public interface CreateFeedOnNameCardBuilder {
    void run(NameCard__c[] newObjs, map<Id, NameCard__c> oldMap);
  } 

  public static Boolean enableFeedItem {
    get {
      if (enableFeedItem == null) {
        // enableFeedItem = ConnectApi.Organization.getSettings().features.chatter;
        // Schema.SObjectType targetType = Schema.getGlobalDescribe().get('FeedItem');
        // enableFeedItem = targetType.getDescribe().isCreateable() &&     // ユーザがフィードを作れる。
        //             NameCard__c.sObjectType.getDescribe().isFeedEnabled();  // 追跡フィードが有効になってる。
        if (ConnectApi.Organization.getSettings().features.chatter &&
          ConnectApi.Organization.getSettings().userSettings.hasChatter) {
          Schema.SObjectType targetType = Schema.getGlobalDescribe().get('FeedItem'); // こうしないと パッケージが Chatter 有効前提になる？
          enableFeedItem = targetType.getDescribe().isCreateable()  &&     // ユーザがフィードを作れる。
                    NameCard__c.sObjectType.getDescribe().isFeedEnabled();  // 追跡フィードが有効になってる。
        }
        else {
          enableFeedItem = false;
        }
      }
      return enableFeedItem;
    }
    private set;
  }

  // 以前のフィード作成クラス（トリガハンドラークラス）を使う
  //  グループにも所有者へもメンションしないかつトピックもない設定のとき
  private Boolean isOldHandler() {
    return SB_NameCard_Util.smartViscaConfig.FeedOnNameCardMentionToOwners__c != true &&  // 同じ人と名刺交換したフィードを名刺所有者にメンションする
      String.isBlank(SB_NameCard_Util.smartViscaConfig.FeedOnNameCardMentionToGroups__c) && // 同じ人と名刺交換したフィードをメンションするグループ
      String.isBlank(SB_NameCard_Util.smartViscaConfig.FeedOnNameCardTopic__c); // 同じ人と名刺交換したフィードのトピック
  }

  // 設定に応じた フィード作成クラス（トリガハンドラークラス）をインスタンス化
  @TestVisible
  private CreateFeedOnNameCardBuilder createBuilder() {
    CreateFeedOnNameCardBuilder result;
    if (isOldHandler()) {
      // 古いハンドラ
      result = new SB_NameCard_CreateFeedOnNameCard();
    }
    else {
      // 新しいハンドラ
      result = new SB_NameCard_CreateFeedOnNCardApiBuilder();
    }
    return result;
  }

  public void run(NameCard__c[] newObjs, map<Id, NameCard__c> oldMap) {
    CreateFeedOnNameCardBuilder builder = createBuilder();
    builder.run(newObjs, oldMap);
  }

}