/*
 * SB_NameCard_RegistOwnerCheckHelper
 * 統合画面登録,リードに登録時の所有者チェック
 * 機能
 * 1,ToDo場合の無効ユーザ,キューチェック
 * 2,取引先と責任者の場合無効ユーザ,キューチェック
 * 3,リードに登録に場合無効ユーザ,キューのチェック
 *
 * (c) 2019 Sunbridge Inc.
 *
 *  @author K.Yoshida
 *  @Version 2.2  2019.02.XX SV_DEV-1558 LEX 取引先登録 一括画面をLXパッケージ同様のLC化で追加
 *  @Version 2.4  2019.09.xx sawano
 *                            SV_DEV-1993 Classic 取引先登録 個別：無効ユーザを所有者として登録した場合のメッセージ表示
 *                            SV_DEV-1994 LEX 取引先登録 個別：無効ユーザを所有者として登録した場合のメッセージ表示
 */
public with sharing class SB_NameCard_RegistOwnerCheckHelper {

  private static String todoLabel = Task.getSobjectType().getDescribe().getLabel();

  // 処理の実行は この 　staticメソッドを外部から呼び出します。
  public static Map<Id, String> doCheck(SB_NC_RegistExecutor.RegistRequest req, Boolean todoOwnerIsCardOwner) {
    // 名刺エラーMAP
    Map<Id, String> ownerErrorMap = new Map<Id, String>();
    // 取引先新規名刺所有者使用
    Set<Id> needCheckAccountUseCardOwner = new Set<Id>();
    // 取引先責任者新規名刺所有者使用
    Set<Id> needCheckContactUseCardOwner = new Set<Id>();
    // ToDo名刺所有者使用
    Set<Id> needCheckToDoUseCardOwner = new Set<Id>();
    // 所有者ID を直接指定してる 2.4  2019.09.xx
    Map<Id, Id> cardId2UserId = new Map<Id, Id>();
    // Key所有者ID  Value使用する名刺
    Map<Id, List<Id>> needCheckUserActiveMap = new Map<Id, List<Id>>();
    // ToDo責任者ユーザ使用
    Map<Id, List<Id>> needCheckToDoUseContactOwner = new Map<Id, List<Id>>();
    // ToDoキューName検索
    Map<Id, Id> todoQueueName = new Map<Id, Id>();

    for (SB_NC_RegistExecutor.RegistTarget ret : req.targets) {
        // 名刺にすでにエラーがあったら他のチェックしなくてもいいです
        if (ownerErrorMap.containsKey(ret.cardId)) {
          continue;
        }
        if (req.acntParam != null) {
          // 取引先新規作成
          if (String.isBlank(ret.acntId)) {
            // 名刺所有者使用
            if (String.isBlank(req.acntParam.ownerid)) {
              // 取引先新規,名刺所有者使用
              needCheckAccountUseCardOwner.add(ret.cardId);
            }
            // 画面所有者使用
            else {
              // 画面所有者はキュー
              if (isQueue(req.acntParam.ownerid)) {
                // ToDo画面表示時のキューはリードサポート,保存する際にポートしないのケースは今考えない
                ownerErrorMap.put(ret.cardId, System.Label.SB_NC_MSG_NAMECARD_OWNER_QUEUE);
                continue;
              }
              else {
                // 2.4  2019.09.xx
                cardId2UserId.put(ret.cardId, req.acntParam.ownerid);
              }
            }
          }
          // 取引先更新
          else {
            // ToDo更新は何もしません
          }
        }

        if (req.contParam != null) {
          // 名刺にすでにエラーがあったら他のチェックしなくてもいいです
          if (ownerErrorMap.containsKey(ret.cardId)) {
            continue;
          }
          // 取引先責任者新規作成
          if (String.isBlank(ret.contId)) {
            if (ret.createTodo) {
              // todoUseOwner.add(ret.cardId);
              if (todoOwnerIsCardOwner) { // v2.4
                //  ToDoの任命先は名刺の所有者 v2.4 から
                // 名刺所有者 を指定していない場合、無効なユーザを選択することはないので、名刺所有者指定のケースだけチェック
                needCheckToDoUseCardOwner.add(ret.cardId);
              }
            }
            // 名刺所有者使用
            if (String.isBlank(req.contParam.ownerid)) {
              // 取引先新規,名刺所有者使用
              needCheckContactUseCardOwner.add(ret.cardId);
            }
            else {
              // 画面所有者はキュー
              if (isQueue(req.contParam.ownerid)) {
                // ToDo画面表示時のキューはリードサポート,保存する際にポートしないのケースは今考えない
                ownerErrorMap.put(ret.cardId, System.Label.SB_NC_MSG_NAMECARD_OWNER_QUEUE);
                continue;
              }
              else {
                // 2.4  2019.09.xx
                cardId2UserId.put(ret.cardId, req.contParam.ownerid);        // あっても上書きする。まずないでしょう。        
              }
            }
          }
          // 取引先責任者更新
          else {
            if (ret.createTodo) {
              if (!todoOwnerIsCardOwner) { // v2.4
                //  ToDoの任命先は取引先責任者の所有者 従来仕様
                if (!needCheckToDoUseContactOwner.containsKey(ret.contId)) {
                  needCheckToDoUseContactOwner.put(ret.contId, new List<Id>());
                }
                needCheckToDoUseContactOwner.get(ret.contId).add(ret.cardId);
              }
              else {
                //  ToDoの任命先は名刺の所有者 v2.4 から
                needCheckToDoUseCardOwner.add(ret.cardId);
              }
            }
          }
        }
    }

    // ToDoしよう責任者所有者
    if (!needCheckToDoUseContactOwner.isEmpty()) {
      List<Contact> cons = [SELECT Id,
                                   Owner.Name,
                                   OwnerId,
                                   Owner.IsActive
                              FROM Contact
                             WHERE Id =: needCheckToDoUseContactOwner.keySet()];
      for (Contact c: cons) {
        // 責任者所有者が無効
        if (c.Owner.IsActive == false) {
          for (Id ncId : needCheckToDoUseContactOwner.get(c.Id)) {
            ownerErrorMap.put(ncId, String.format(System.Label.SB_NC_MSG_CanNotSetInActiveUserToOwnerToDo, new String[] {c.Owner.Name}));
            continue;
          }
        }
      }
    }

    // 名刺Id使用チェック
    if ( !needCheckAccountUseCardOwner.isEmpty()
      || !needCheckContactUseCardOwner.isEmpty()
      || !needCheckToDoUseCardOwner.isEmpty()) {
      List<NameCard__c> ncs = [SELECT Id,
                                      Owner.Name,
                                      OwnerId,
                                      Owner.IsActive
                                FROM NameCard__c
                                WHERE Id IN :needCheckAccountUseCardOwner  // アカウントの所有者
                                  OR Id IN :needCheckContactUseCardOwner   // コンタクトの所有者
                                  OR Id IN :needCheckToDoUseCardOwner];   // ToDoの任命先 名刺所有者
      Map<Id, Id> queueMap = new Map<Id, Id>();
      for (NameCard__c nc : ncs) {
        // すでにエラーメッセージがあったら何もしません
        if (ownerErrorMap.containsKey(nc.Id)) {
          continue;
        }
        // 無効ユーザ
        if (nc.Owner.IsActive == false) {
          if (needCheckToDoUseCardOwner.contains(nc.Id)) {
            ownerErrorMap.put(nc.Id, String.format(System.Label.SB_NC_MSG_CanNotSetInActiveUserToOwnerToDo, new String[] {nc.Owner.Name}));
          }
          else {
            ownerErrorMap.put(nc.Id, System.Label.SB_NC_MSG_CanNotSetInActiveUserToOwner);
          }
          continue;
        }
        //ユーザ以外の場合
        if (isQueue(nc.OwnerId)) {
          // 取引先と責任者の場合
          if (needCheckAccountUseCardOwner.contains(nc.Id)
            || needCheckContactUseCardOwner.contains(nc.Id)) {
            ownerErrorMap.put(nc.Id, System.Label.SB_NC_MSG_NAMECARD_OWNER_QUEUE);
            continue;
          }
          if (needCheckToDoUseCardOwner.contains(nc.Id)) {
            // String errorMessage = 
            //     todoLabel +
            //               System.Label.SB_NCLD_MSG_Regist_Error + ': ' +
            //               System.Label.SB_NCLD_MSG_QUEUES_ERROR;
            // ownerErrorMap.put(nc.Id, errorMessage);
            todoQueueName.put(nc.Id, nc.OwnerId);
          }
        }
      }
    }

    if (!todoQueueName.isEmpty()) {
      List<QueueSobject> qss = [Select QueueId, SobjectType, Queue.Name
                                    FROM QueueSobject
                                   WHERE QueueId = :todoQueueName.values()];
      Map<Id, String> qMap = new Map<Id, String>();
      for (QueueSobject qs : qss) {
        qMap.put(qs.QueueId, qs.Queue.Name);
      }
      for (Id cardId : todoQueueName.keySet()) {
        String errorMessage = 
          todoLabel +
                                System.Label.SB_NC_MSG_Regist_Error + ': ' +
                                String.format(System.Label.SB_NC_MSG_QUEUES_ERROR, new String[]{qMap.get(todoQueueName.get(cardId))});
          ownerErrorMap.put(cardId, errorMessage);
      }
    }

    // v2.4 所有者直指定のを調べる
    if (!cardId2UserId.isEmpty()) {
      Map<Id, User> users = new Map<Id, User>([SELECT Id, Name, IsActive FROM User WHERE Id IN : cardId2UserId.values()]);
      for (Id cardId : cardId2UserId.keySet()) {
        User u = users.get(cardId2UserId.get(cardId));
        if (u != null && u.IsActive == false) {
           ownerErrorMap.put(cardId, System.Label.SB_NC_MSG_CanNotSetInActiveUserToOwner);
        }
      }
    }
    return ownerErrorMap;
  }

  /**
    * @description Idはキューなのか判断するメソッド
    * @param objId 判断するId
  **/
  private static Boolean isQueue(Id objId) {
    return String.isNotBlank(objId) && objId.getSobjectType() != User.getSobjectType() && String.valueOf(objId).startsWith('00G');
  }
}