/**
 *
 * SB_NameCard_CreateFeedOnNCardApiBuilder
 * 名刺の追加時、既存の名刺の最新名刺を更新するので、そのとき、既存名刺の所有者にフィードで、通知します。
 *     v2.3 までは SB_NameCard_CreateFeedOnNameCard でやってた機能です。
 *          名刺所有者、グループにメンションする機能を追加
 *         直にレコード追加せず、 ConnectApi を使います。
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
 *  @Version 2.4    2019.07.xx  このタイプの初版 SV_DEV-1632 同じ人との名刺交換のフィード通知がメールでも通知されるようにする
 *  @Version 2.4.2  2019.11.xx  SV_DEV-2271 SmartViscaパッケージ 2.4.1インストール後にChatterが無効化できなくなる
 *
 **/
public with sharing class SB_NameCard_CreateFeedOnNCardApiBuilder implements SB_NameCard_CreateFeedOnNameCardFactory.CreateFeedOnNameCardBuilder {
  public class SB_NameCard_CreateFeedOnNCardApiBuilderException extends Exception {}

  // 名刺所有者たちへメンション
  private static Boolean isMentionToOwners() {
    return SB_NameCard_Util.smartViscaConfig.FeedOnNameCardMentionToOwners__c == true;  // null は false 扱い
  }

  // 指定されてるグループへメンション
  // SV_DEV-2271 SmartViscaパッケージ 2.4.1インストール後にChatterが無効化できなくなる
  private static List<SObject> mentionToGroups;
  static {
    if (String.isNotBlank(SB_NameCard_Util.smartViscaConfig.FeedOnNameCardMentionToGroups__c)) {
      Set<String> gNames = new Set<String>();
      String[] ss = SB_NameCard_Util.smartViscaConfig.FeedOnNameCardMentionToGroups__c.split('\\r\\n|\\n|\\r');
      for(String s : ss) {
        gNames.add(s.trim());
      }
      if (!gNames.isEmpty()) {
        String query = 'SELECT Id, Name FROM CollaborationGroup WHERE Name IN :gNames';
        mentionToGroups = Database.query(query);
      }
    }
  }

  // フィードを作成して投稿する
  // NameCard__c card 最新の名刺が変わった名刺レコード 投稿先
  // String body フィード本文
  // NameCard__c latest 最新の名刺レコード
  private ConnectApi.FeedItemInput createFeedElement(NameCard__c card, String body, NameCard__c latest) {
    // Feedを作る。
    ConnectApi.FeedItemInput feedItem = new ConnectApi.FeedItemInput();
    feedItem.subjectId = card.Id; // This can also be an objectID to post the file to.
    feedItem.feedElementType = ConnectApi.FeedElementType.FeedItem;

    // フィード要素に含めるもの
    feedItem.capabilities = new ConnectAPI.FeedElementCapabilitiesInput();
    // //  ファイルの添付
    // feedItem.capabilities.files = new ConnectAPI.FilesCapabilityInput();
    // feedItem.capabilities.files.items = new List<ConnectAPI.FileIdInput>();
    // //  作ったファイルを関連付ける。
    // for (ContentVersion version : versions) {
    //   ConnectAPI.FileIdInput attachFile = new ConnectAPI.FileIDInput();
    //   attachFile.id = version.ContentDocumentId;
    //   feedItem.capabilities.files.items.add(attachFile);
    // }

    // 最新名刺レコードへのリンク
    if (card.Parent__c != null) {
      feedItem.capabilities.link = new ConnectApi.LinkCapabilityInput();
      feedItem.capabilities.link.url = '/' + card.parent__c;
      feedItem.capabilities.link.urlName = card.Name;
    }

    //  トピック 指定があれば、あれば、
    if (String.isNotBlank(SB_NameCard_Util.smartViscaConfig.FeedOnNameCardTopic__c)) {
      // SV_DEV-2147 名寄せ：トピックの文字列長が100字以上あるとフィードが通知が行われない → 99 文字で切ります。
      String topic = String.format(SB_NameCard_Util.smartViscaConfig.FeedOnNameCardTopic__c,
                new String[] { latest == null || String.isBlank(latest.company_name__c) ? '' :latest.company_name__c,
                              latest == null || String.isBlank(latest.division__c) ? '' : latest.division__c,
                              latest == null || String.isBlank(latest.title_name__c) ? '' : latest.title_name__c }).left(99);
      // SV_DEV-2150 名寄せ：トピックの文字列長が0字になるとフィードが通知が行われない
      if (String.isNotBlank(topic)) {
        feedItem.capabilities.topics = new ConnectApi.TopicsCapabilityInput();
        feedItem.capabilities.topics.topics = new List<String> { topic };
      }
    }

    // 本文
    ConnectApi.MessageBodyInput messageBody = new ConnectApi.MessageBodyInput();
    ConnectApi.TextSegmentInput textSegment;
    messageBody.messageSegments = new List<ConnectApi.MessageSegmentInput>();
    textSegment = new ConnectApi.TextSegmentInput();
    textSegment.text = body;
    messageBody.messageSegments.add(textSegment);

    // メンション先 あれば、
    // メンション先 グループ
    if (mentionToGroups != null && !mentionToGroups.isEmpty()) {
      for (SObject g : mentionToGroups)  {
        ConnectApi.MentionSegmentInput mentionSegment;
        mentionSegment = new ConnectApi.MentionSegmentInput();
        mentionSegment.id = g.Id;
        messageBody.messageSegments.add(mentionSegment);
      }
    }
    // メンション先 名刺所有者
    if (isMentionToOwners()) {
      ConnectApi.MentionSegmentInput mentionSegment;
      mentionSegment = new ConnectApi.MentionSegmentInput();
      mentionSegment.id = card.OwnerId;
      messageBody.messageSegments.add(mentionSegment);
    }
    //
    feedItem.body = messageBody;

    return feedItem;
  }

  // 所属・役職の 変更の内容
  private static String POSITION_CHANGE_FORMAT_OUT_TO_IN = '{1} ' + System.Label.SB_NC_ExchangedToo4;
  private static String POSITION_CHANGE_FORMAT_IN_TO_IN = '{0} ' + System.Label.SB_NC_ExchangedToo3 + ' {1} ' + System.Label.SB_NC_ExchangedToo4;
  private static String POSITION_CHANGE_FORMAT_IN_TO_OUT = '{0} ' + System.Label.SB_NC_ExchangedToo3 + ' (' + System.Label.SB_NC_SETTING_LABEL_NONE + ') ' + System.Label.SB_NC_ExchangedToo4;
  @TestVisible
  private String getPositionChangeFormat(String prv, String cur) {
    if (String.isBlank(prv) && String.isNotBlank(cur)) {
      // なし から あり
      return POSITION_CHANGE_FORMAT_OUT_TO_IN;
    }
    else if (String.isNotBlank(prv) && String.isBlank(cur)) {
      // あり から なし
      return POSITION_CHANGE_FORMAT_IN_TO_OUT;
    }
    //　あり から あり
    return POSITION_CHANGE_FORMAT_IN_TO_IN;
  }

  @TestVisible
  private String getPositionChangeText(NameCard__c prv, NameCard__c cur) {
    String result;
    if (prv.division__c != cur.division__c || prv.title_name__c != + cur.title_name__c) {
      String prvPos = (String.isNotBlank(prv.division__c) ? prv.division__c : '') + (String.isNotBlank(prv.title_name__c) ? prv.title_name__c : '');
      String curPos = (String.isNotBlank(cur.division__c) ? cur.division__c : '') + (String.isNotBlank(cur.title_name__c) ? cur.title_name__c : '');
      String form = getPositionChangeFormat(prvPos, curPos);
      result = String.format(form, new String[] { prvPos, curPos });
    }
    return result;
  }

  public void run(NameCard__c[] newObjs, map<Id, NameCard__c> oldMap) {
    system.assert(newObjs !=null);
    system.assert(oldMap !=null);

    // 更新された名刺の所有者名称を Mapに格納
    List<Id> parentIds = new List<Id>();
    for ( NameCard__c cur : newObjs) {
        parentIds.add( cur.parent__c);
    }
    // あたらしい最新の名刺
    // 更新された名刺の Parent__cが参照する名刺情報を Mapに格納
    Map<ID, NameCard__c> latestCards = new Map<ID, NameCard__c>([select id, Owner.Name, company_name__c, division__c, title_name__c from NameCard__c where id in :parentIds]);

    // 最新名刺が更新された名刺　の　以前の最新の名刺の収集
    List<Id> prvParentIds = new List<Id>();
    for (NameCard__c prv : oldMap.values()) {
        prvParentIds.add(prv.parent__c);
    }
    Map<Id, NameCard__c> prvLatestCards = new Map<Id, NameCard__c>([select Id, Owner.Name, company_name__c, division__c, title_name__c from NameCard__c where id in :prvParentIds]);

    List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();  // フィードをバッチで登録する用のリスト
    for (NameCard__c cur : newObjs) {
      NameCard__c prv = oldMap.get(cur.Id);
      if ( prv.parent__c == cur.parent__c) {
        // 最新名刺が変わってない フィードしない
        continue;
      }
      // 最新名刺が変わった場合だけ
      if ( latestCards.containsKey(cur.parent__c)) {
        NameCard__c curLatest = latestCards.get(cur.parent__c);  // 更新された最新の名刺
        String bodyStr = '';
        bodyStr += latestCards.get(cur.parent__c).Owner.Name;
        bodyStr += System.Label.SB_NC_ExchangedToo1;    // さんも、
        // {0}の{1}さんと名刺交換しました。
        bodyStr += String.format(' ' + System.Label.SB_NC_ExchangedToo2,new String[]{cur.company_name__c == null ? '' : cur.company_name__c,cur.Name});
        // 所属役職変更も表示にする 2015/04/28 syu -> refactor sawano
        String positionChange;// 所属役職の変更内容
        if (prvLatestCards.get(prv.parent__c) != null) {
          NameCard__c prvLatest = prvLatestCards.get(prv.parent__c);
          positionChange = getPositionChangeText(prvLatest, curLatest);
        }
        else if (prvLatestCards.get(prv.parent__c) == null ) {
          positionChange = getPositionChangeText(prv, curLatest);
        }
        if (String.isNotBlank(positionChange)) {
          bodyStr += '\n';
          bodyStr += positionChange;
        }
        bodyStr += '\n';
        ConnectApi.FeedItemInput feedItem = createFeedElement(cur, bodyStr, curLatest);
        // ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItem);
        // feedItems.add(feedItem);
        ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItem);
        batchInputs.add(batchInput);
      }
    } // for
    ConnectApi.BatchResult[] batchRes = ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
  }

}