/**
 *
 * 名刺の追加時、既存の名刺の最新名刺を更新するので、そのとき、既存名刺の所有者にフィードで、通知します。
 *      従来 SB_NameCard_createFeedOnNameCard.trigger でやってた処理
 *
 * Copyright (C) 2012-2015 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  History :
 *      SB_NameCard_createFeedOnNameCard.trigger の移植
 *  @Version 2      2014.4.2x
 *                  2014.7.11 動的APEX対応
 *                  2014.08.20 フィード内のリンクを 従来、最新の名刺の値が更新になった古い名刺を指してましたが、最新の名刺へのリンクへ変更
 *  @Version 2.4    2019.07.xx  設定によって、別の フィード作成クラスを使うようにします。interface を implements 
 *
 **/
public with sharing class SB_NameCard_CreateFeedOnNameCard implements SB_NameCard_CreateFeedOnNameCardFactory.CreateFeedOnNameCardBuilder {

    // フィードが使えるか
    public static Boolean enableFeedItem {
        get {
            if (enableFeedItem == null) {
                enableFeedItem = false;
                try {
                    Schema.SObjectType targetType = Schema.getGlobalDescribe().get('FeedItem');
                    enableFeedItem = targetType.getDescribe().isCreateable() &&     // ユーザがフィードを作れる。
                                NameCard__c.sObjectType.getDescribe().isFeedEnabled();  // 追跡フィードが有効になってる。
                }
                catch(Exception e) {
                    enableFeedItem = false;
                }
            }
            return enableFeedItem;
        }
        private set;
    }

    public void run(NameCard__c[] newObjs, map<Id, NameCard__c> oldMap) {
        system.assert(newObjs !=null);
        system.assert(oldMap !=null);
        // 更新された名刺の所有者名称を Mapに格納
        List<Id> parentIds = new List<Id>();

        for ( NameCard__c localNameCard : newObjs) {
            parentIds.add( localNameCard.parent__c);
        }
        Map<ID, NameCard__c> ownerMap = new Map<ID, NameCard__c>([select id, owner.Name, division__c, title_name__c from NameCard__c where id in :parentIds]);

        //
        List<Id> oldParentIds = new List<Id>();
        for (NameCard__c prvParentNameCard : oldMap.values()) {
            oldParentIds.add(prvParentNameCard.parent__c);
        }
        Map<Id, NameCard__c> oldOwnerMap = new Map<Id, NameCard__c>([select Id, owner.Name, division__c, title_name__c from NameCard__c where id in :oldParentIds]);

        // 更新された名刺の Parent__cが参照する名刺情報を Mapに格納
//      FeedItem item = null;
//      NameCard__c nameCardOld = null, nameCardNew = null;
        // +-- 2014.7.11 動的APEX対応
//      List<FeedItem> feedItems = new List<FeedItem>();
        List<sObject> feedItems = new List<sObject>();
        FeedItemBuilder builder = new FeedItemBuilder();
        for (NameCard__c cur : newObjs) {
//          nameCardOld = Trigger.Old[i];
//          cur = Trigger.New[i];
            NameCard__c prv = oldMap.get(cur.Id);
            if ( prv.parent__c != cur.parent__c) {
                if ( ownerMap.get( cur.parent__c) != null) {
                    String bodyStr = ''; //所属役職変更も表示にする 2015/04/28 syu
                    bodyStr += ownerMap.get( cur.parent__c).owner.Name;
                    bodyStr += System.Label.SB_NC_ExchangedToo1;
                    bodyStr += String.format(' ' + System.Label.SB_NC_ExchangedToo2,new String[]{cur.company_name__c == null ? '' : cur.company_name__c,cur.Name});
                    system.debug('++++++debug:' + oldOwnerMap.get(prv.parent__c));
                    if (oldOwnerMap.get(prv.parent__c) != null && ownerMap.get( cur.parent__c).division__c + ownerMap.get( cur.parent__c).title_name__c != oldOwnerMap.get(prv.parent__c).division__c + oldOwnerMap.get(prv.parent__c).title_name__c) {
                        bodyStr += '\n';
                        if (String.isBlank(oldOwnerMap.get(prv.parent__c).division__c) == false) {
                            bodyStr += oldOwnerMap.get(prv.parent__c).division__c;
                        }
                        if (String.isBlank(oldOwnerMap.get(prv.parent__c).title_name__c) == false) {
                            bodyStr += oldOwnerMap.get(prv.parent__c).title_name__c;
                        }
                        if (String.isBlank(oldOwnerMap.get(prv.parent__c).division__c + oldOwnerMap.get(prv.parent__c).title_name__c) == false) {
                            bodyStr += System.Label.SB_NC_ExchangedToo3;
                        }
                        if (String.isBlank(ownerMap.get( cur.parent__c).division__c) == false) {
                            bodyStr += ownerMap.get( cur.parent__c).division__c;
                        }
                        if (String.isBlank(ownerMap.get( cur.parent__c).title_name__c) == false) {
                            bodyStr += ownerMap.get( cur.parent__c).title_name__c;
                        }
                        bodyStr += System.Label.SB_NC_ExchangedToo4;
                    } else if (oldOwnerMap.get(prv.parent__c) == null && ownerMap.get( cur.parent__c).division__c + ownerMap.get( cur.parent__c).title_name__c != prv.division__c + prv.title_name__c) {
                        bodyStr += '\n';
                        if (String.isBlank(prv.division__c) == false) {
                            bodyStr += prv.division__c;
                        }
                        if (String.isBlank(prv.title_name__c) == false) {
                            bodyStr += prv.title_name__c;
                        }
                        if (String.isBlank(prv.division__c + prv.title_name__c) == false) {
                            bodyStr += System.Label.SB_NC_ExchangedToo3;
                        }
                        if (String.isBlank(ownerMap.get( cur.parent__c).division__c) == false) {
                            bodyStr += ownerMap.get( cur.parent__c).division__c;
                        }
                        if (String.isBlank(ownerMap.get( cur.parent__c).title_name__c) == false) {
                            bodyStr += ownerMap.get( cur.parent__c).title_name__c;
                        }
                        bodyStr += System.Label.SB_NC_ExchangedToo4;
                    } else {
                        //
                    }
                    sObject item = builder.create(
                        bodyStr,
                        'LinkPost',
                        cur.id,
                        cur.Name,
                        // '/' + cur.Id);
                        '/' + cur.parent__c);   // 2014.08.20 従来、最新の名刺の値が更新になった古い名刺を指してましたが、最新の名刺へのリンクへ変更
/*                  FeedItem item = new FeedItem(
                        Body = ownerMap.get( nameCardNew.parent__c).owner.Name + System.Label.SB_NC_ExchangedToo1 + nameCardNew.Name + System.Label.SB_NC_ExchangedToo2,
                        Type = 'LinkPost',
                        ParentId = nameCardNew.id,
                        Title= nameCardNew.Name,
                        LinkURL = '/' + nameCardNew.Id
                    );*/
                    if (item == null) continue;
                    feedItems.add(item);
                }
            }
        }
//      insert feedItems;
        // 2014.4.2x CRUD/FLS 対応
        SB_NameCard_CrudFls.screate(feedItems, false);
    }

    public class SB_NameCard_CreateFeedOnNameCard_Exception extends Exception {}

    // 動的APEX 対応
    // テストのコードカバー率を稼ぐため、Feed が作れないことを事前にチェクせず、例外をスローさせます。
    private class FeedItemBuilder {
        public sObject create(String body, String type, Id parentId, String title, String linkUrl) {
            try {
                sObject result = createSObject('FeedItem');
                result.put('Body', body);
                result.put('Type', type);
                result.put('ParentId', parentId);
                result.put('Title', title);
                result.put('LinkURL', linkUrl);
                return result;
            }
            catch(Exception ex) {
                System.debug(ex.getMessage());
            }
            return null;
        }

        private sObject createSObject(String typeName)   {
            // 動的 sObject の作成
            Schema.SObjectType targetType = Schema.getGlobalDescribe().get(typeName);
            if (targetType == null) {
                throw new SB_NameCard_CreateFeedOnNameCard_Exception(system.Label.SB_MSG_IllegalRequest);
            }
            return targetType.newSObject();
        }
    }


}