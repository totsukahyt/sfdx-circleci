/**
 *
 * 名刺の追加、更新、削除、復活時、1次納品、2次納品の情報を名刺履歴オブジェクトに保存します。
 *      SB_NameCard_History.trigger でやってた処理
 *
 * Copyright (C) 2012-2014 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  History :
 *      SB_NameCard_History.trigger の移植
 *  @Version 2      
 *      2014.08.20 名刺のオブジェクトIDで識別していたのを 名刺IDに変更。本来の仕様
 *      2014.09.04 追加、更新時、名刺所有者をセット
 *  @Version 2.4  SV_DEV-1226 対象外の名刺のスキップ処理を修正
 **/
public with sharing class SB_NameCard_HistoryTriggerHandler {
    List<NameCardHistory__c> inNchList;
    List<NameCardHistory__c> upNchList;

    public SB_NameCard_HistoryTriggerHandler() {
        inNchList = new List<NameCardHistory__c>();
        upNchList = new List<NameCardHistory__c>();
    }

    // 追加後トリガ
    public void OnAfrerInsert(NameCard__c[] arrNewObject) {
        for (NameCard__c nc : arrNewObject) {
            if (String.isBlank(nc.card_id__c) == true ) continue;       //名刺IDのがない場合作らない。
            NameCardHistory__c nch = new NameCardHistory__c();
            nch.NameCard__c = nc.Id; // 名刺オブジェクトID
            nch.card_id__c = nc.card_id__c; // 名刺ID
            nch.NameCardOwner__c = nc.OwnerId;  // 所有者

            if (nc.delivery_type__c == '1') {
                nch.primary_delivery_time__c = nc.CreatedDate; // 一次納品日時
            } else if (nc.delivery_type__c == '2') {
                nch.secondary_delivery_time__c = nc.CreatedDate; // 二次納品日時
                String error_code;

                if (String.isNotBlank(nc.error__c)) {
                    for (String s : nc.error__c.split('\n')) {
                        if (s.startsWith('error_code:')) {
                            error_code = s.substringAfterLast(':').trim().substring(0,1);
                            break;
                        }
                    }
                }
                nch.error_code__c = error_code; // エラーコード
            }
            inNchList.add(nch);
        }
    }

    // 更新後トリガ
    public void OnAfterUpdate(NameCard__c[] arrNewObject,
                                map<ID, NameCard__c> mapOldObject) {
        Set<String> ncIds = new Set<String>();
        for (NameCard__c ncNew : arrNewObject) {
            NameCard__c ncOld = mapOldObject.get(ncNew.Id);
            // 名刺IDがない名刺 または、 納品タイプ または 所有者(2014.09.04) が変わっていない名刺は 対象外
            if (String.isBlank(ncNew.card_id__c) == true || 
                (ncNew.delivery_type__c == ncOld.delivery_type__c && ncNew.OwnerId == ncOld.OwnerId)) continue;     
            ncIds.add(ncNew.Id);
        }
        if (ncIds.isEmpty() == true) return;

        // 既存の名刺履歴レコードを検索
        Map<String, NameCardHistory__c> nchMap = new Map<String, NameCardHistory__c>();
        for (NameCardHistory__c nch : [SELECT Id, NameCard__c FROM NameCardHistory__c WHERE NameCard__c IN :ncIds]) {
            nchMap.put(nch.NameCard__c, nch);
        }
        System.debug('nchMap.size: ' + nchMap.size());

        for (NameCard__c ncNew : arrNewObject) {
            // 対象外の名刺をスキップ
            if (!ncIds.contains(ncNew.Id)) continue;
            NameCard__c ncOld = mapOldObject.get(ncNew.Id);

            if (ncNew.delivery_type__c != ncOld.delivery_type__c || ncNew.OwnerId != ncOld.OwnerId) { 
                // 納品タイプ または 所有者(2014.09.04) が変わってる場合
                if (nchMap.containsKey(ncNew.Id)) {
                    NameCardHistory__c nch = nchMap.get(ncNew.Id);
                    nch.NameCardOwner__c = ncNew.OwnerId;   // 所有者

                    if (ncNew.delivery_type__c == '1' && ncOld.delivery_type__c != '1') {
                        nch.primary_delivery_time__c = ncNew.LastModifiedDate; // 一次納品日時、変更された場合のみ
                    } else if (ncNew.delivery_type__c == '2' && ncOld.delivery_type__c != '2') {
                        nch.secondary_delivery_time__c = ncNew.LastModifiedDate; // 二次納品日時、変更された場合のみ
                        String error_code;

                        if (String.isNotBlank(ncNew.error__c)) {
                            for (String s : ncNew.error__c.split('\n')) {
                                if (s.startsWith('error_code:')) {
                                    error_code = s.substringAfterLast(':').trim().substring(0,1);
                                    break;
                                }
                            }
                        }
                        nch.error_code__c = error_code; // エラーコード
                    }
                    upNchList.add(nch);
                } else {
                    NameCardHistory__c nch = new NameCardHistory__c();
                    nch.NameCard__c = ncNew.Id; // 名刺オブジェクトID
                    nch.card_id__c = ncNew.card_id__c; // 名刺ID
                    nch.NameCardOwner__c = ncNew.OwnerId;   // 所有者

                    if (ncNew.delivery_type__c == '1') {
                        nch.primary_delivery_time__c = ncNew.LastModifiedDate; // 一次納品日時
                    } else if (ncNew.delivery_type__c == '2') {
                        nch.secondary_delivery_time__c = ncNew.LastModifiedDate; // 二次納品日時
                        String error_code;

                        if (String.isNotBlank(ncNew.error__c)) {

                            for (String s : ncNew.error__c.split('\n')) {
                                if (s.startsWith('error_code:')) {
                                    error_code = s.substringAfterLast(':').trim().substring(0,1);
                                    break;
                                }
                            }
                        }
                        nch.error_code__c = error_code; // エラーコード
                    }
                    inNchList.add(nch);
                }
            }
        }

    }

    public void OnAfterDelete(NameCard__c[] arrOldObject) {
        Set<String> ncIds = new Set<String>();
        for (NameCard__c ncNew : arrOldObject) {
            if (String.isBlank(ncNew.card_id__c) == true) continue;     // 名刺IDがない名刺は対象外
            ncIds.add(ncNew.Id);
        }
        if (ncIds.isEmpty() == true) return;

        Map<String, NameCardHistory__c> nchMap = new Map<String, NameCardHistory__c>();
        for (NameCardHistory__c nch : [SELECT Id, NameCard__c FROM NameCardHistory__c WHERE NameCard__c IN :ncIds]) {
            nchMap.put(nch.NameCard__c, nch);
        }

        System.debug('nchMap.size: ' + nchMap.size());

        NameCardHistory__c nch;

        for (NameCard__c nc : arrOldObject) {
            // 対象外の名刺をスキップ
            if (!ncIds.contains(nc.Id)) continue;
            if (nchMap.containsKey(nc.Id)) {
                nch = nchMap.get(nc.Id);
                nch.delete_time__c = Datetime.now(); // 削除日時
                upNchList.add(nch);
            } else {
                nch = new NameCardHistory__c();
                nch.NameCard__c = nc.Id; // 名刺オブジェクトID
                nch.card_id__c = nc.card_id__c; // 名刺ID
                nch.delete_time__c = Datetime.now(); // 削除日時
                inNchList.add(nch);
            }
        }
    }

    public void OnAfterUndelete(NameCard__c[] arrNewObject) {
        Set<String> ncIds = new Set<String>();
        for (NameCard__c ncNew : arrNewObject) {
            if (String.isBlank(ncNew.card_id__c) == true) continue;     // 名刺IDがない名刺は対象外
            ncIds.add(ncNew.Id);
        }
        if (ncIds.isEmpty() == true) return;  

        Map<String, NameCardHistory__c> nchMap = new Map<String, NameCardHistory__c>();
        for (NameCardHistory__c nch : [SELECT Id, NameCard__c FROM NameCardHistory__c WHERE NameCard__c IN :ncIds]) {
            nchMap.put(nch.NameCard__c, nch);
        }
        System.debug('nchMap.size: ' + nchMap.size());

        NameCardHistory__c nch;

        for (NameCard__c nc : arrNewObject) {
            // 対象外の名刺をスキップ
            if (!ncIds.contains(nc.Id)) continue;
            if (nchMap.containsKey(nc.Id)) {
                nch = nchMap.get(nc.Id);
                nch.delete_time__c = null; // 削除日時
                upNchList.add(nch);
            } else {
                nch = new NameCardHistory__c();
                nch.NameCard__c = nc.Id; // 名刺オブジェクトID
                nch.card_id__c = nc.card_id__c; // 名刺ID
                nch.delete_time__c = null; // 削除日時
                inNchList.add(nch);
            }
        }
    }

    public void finalize() {
        if (inNchList.size() > 0) {
//          Database.insert(inNchList);
            //  CRUD/FLS 対応
            SB_NameCard_CrudFls.screate(inNchList, true);
        }
        if (upNchList.size() > 0) {
//          Database.upsert(upNchList);
            //  CRUD/FLS 対応
            SB_NameCard_CrudFls.supdate(upNchList, true);
        }
    }
}