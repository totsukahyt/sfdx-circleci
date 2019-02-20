/*
 * (c) 2018 Sunbridge Inc.
 * SB_NameCardL_RegistOwenrCheckHelper
 * 統合画面登録,リードに登録時の所有者チェック
 * 機能
 * 1,ToDo場合の無効ユーザ,キューチェック
 * 2,取引先と責任者の場合無効ユーザ,キューチェック
 * 3,リードに登録に場合無効ユーザ,キューのチェック
 *
 *
 * @author mao
 * @Version 拡張パッケージ：Lead Ex. 1.12 2018/8/XX
 *
 */


public with sharing class SB_NameCardL_RegistOwenrCheckHelper {

  private static String todoLabel = Task.getSobjectType().getDescribe().getLabel();

  // 処理の実行は この 　staticメソッドを外部から呼び出します。
  public static Map<Id, String> doCheck(SB_NameCardL_RegistHelper.RegistRequest req) {
    // 名刺エラーMAP
    Map<Id, String> ownerErrorMap = new Map<Id, String>();

    // リード規名刺所有者使用
    Set<Id> needCheckLeadUseCardOwner = new Set<Id>();
    // 取引先新規名刺所有者使用
    Set<Id> needCheckAccountUseCardOwner = new Set<Id>();
    // 取引先責任者新規名刺所有者使用
    Set<Id> needCheckContactUseCardOwner = new Set<Id>();
    // ToDo名刺所有者使用
    Set<Id> needCheckToDoUseCardOwner = new Set<Id>();
    // ToDo名刺所有者使用
    Set<Id> todoUseOwner = new Set<Id>();

    // Key所有者ID  Value使用する名刺
    Map<Id, List<Id>> needCheckUserActiveMap = new Map<Id, List<Id>>();

    // ToDoリードユーザ使用
    Map<Id, List<Id>> needCheckToDoUseLeadOwner = new Map<Id, List<Id>>();

    // ToDo責任者ユーザ使用
    Map<Id, List<Id>> needCheckToDoUseContactOwner = new Map<Id, List<Id>>();

    // ToDoキューName検索
    Map<Id, Id> todoQueueName = new Map<Id, Id>();



    for (SB_NameCardL_RegistHelper.RegistTarget ret : req.targets) {

      // リード
      if ((ret.pType == SB_NameCardL_RegistHelper.ProcType.LEAD
          || ret.pType == SB_NameCardL_RegistHelper.ProcType.BOTH)) {
        if (req.leadParam != null) {
          // リード新規
          if (String.isBlank(ret.leadId)) {
            // 名刺所有者使用
            if (String.isBlank(req.leadParam.ownerid)) {
              needCheckLeadUseCardOwner.add(ret.cardId);
              if (ret.createTodo) {
                needCheckToDoUseCardOwner.add(ret.cardId);
              }
            }
            // 画面所有者使用
            else {
              // 画面所有者はキュー
              if (isQueue(req.leadParam.ownerid)) {
                // ToDo画面表示時のキューはリードサポート,保存する際にポート市内のケースは今考えない

                // ToDo登録の場合キューを選択していればエラー通知
                if (ret.createTodo) {
                  // String errorMessage = 
                  // todoLabel +
                  //           System.Label.SB_NCLD_MSG_Regist_Error + ': ' +
                  //           System.Label.SB_NCLD_MSG_QUEUES_ERROR;
                  // ownerErrorMap.put(ret.cardId, errorMessage);
                  todoQueueName.put(ret.cardId, req.leadParam.ownerid);
                  continue;
                }
              }
              // 画面所有者はユーザ
              else {
                // ToDo画面上から選択する際にユーザは有効で,保存の時無効になったケースは今考えない
                // if (!needCheckUserActiveMap.containsKey(req.leadParam.ownerid)) {
                //   needCheckUserActiveMap.put(req.leadParam.ownerid, new List<Id>());
                // }
                // needCheckUserActiveMap.get(ret.cardId).add(req.leadParam.ownerid);
                // needCheckUserActiveSet.add(req.leadParam.ownerid);
              }
            }
          }
          // リード更新
          else {
            // ToDo登録
            if (ret.createTodo) {
              // 複数名刺は同じリードに設定する場合があります
              if (!needCheckToDoUseLeadOwner.containsKey(ret.leadId)) {
                needCheckToDoUseLeadOwner.put(ret.leadId, new List<Id>());
              }
              needCheckToDoUseLeadOwner.get(ret.leadId).add(ret.cardId);
              todoUseOwner.add(ret.cardId);
            }
          }
        }
      }
      // 取引先責任者に登録
      if ((ret.pType == SB_NameCardL_RegistHelper.ProcType.ACCOUNT
          || ret.pType == SB_NameCardL_RegistHelper.ProcType.BOTH)) {
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

                ownerErrorMap.put(ret.cardId, System.Label.SB_NCLD_Label_NameCard_Owner_Queue);
                continue;
              }
              else {
                // ToDo画面上から選択する際にユーザは有効で,保存の時無効になったケースは今考えない
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
              todoUseOwner.add(ret.cardId);
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

                ownerErrorMap.put(ret.cardId, System.Label.SB_NCLD_Label_NameCard_Owner_Queue);
                continue;
              }
              else {
                // ToDo画面上から選択する際にユーザは有効で,保存の時無効になったケースは今考えない
              }
            }
          }
          // 取引先責任者更新
          else {
            if (ret.createTodo) {
              if (!needCheckToDoUseContactOwner.containsKey(ret.contId)) {
                needCheckToDoUseContactOwner.put(ret.contId, new List<Id>());
              }
              needCheckToDoUseContactOwner.get(ret.contId).add(ret.cardId);
              todoUseOwner.add(ret.cardId);
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
            ownerErrorMap.put(ncId, String.format(System.Label.SB_NCLD_MSG_CanNotSetInActiveUserToOwnerToDo, new String[] {c.Owner.Name}));
            continue;
          }
        }
      }
    }


    if (!needCheckToDoUseLeadOwner.isEmpty()) {
      List<Lead> leads = [SELECT Id,
                                   Owner.Name,
                                   OwnerId,
                                   Owner.IsActive
                              FROM Lead
                             WHERE Id =: needCheckToDoUseLeadOwner.keySet()];
      for (Lead le : leads) {
        // 責任者所有者が無効
        if (le.Owner.IsActive == false) {
          for (Id ncId : needCheckToDoUseLeadOwner.get(le.Id)) {
            ownerErrorMap.put(ncId, String.format(System.Label.SB_NCLD_MSG_CanNotSetInActiveUserToOwnerToDo, new String[] {le.Owner.Name}));
            continue;
          }
        }
        else if (isQueue(le.OwnerId)) {
          for (Id ncId : needCheckToDoUseLeadOwner.get(le.Id)) {
            // String errorMessage = 
            // todoLabel +
            //                       System.Label.SB_NCLD_MSG_Regist_Error + ': ' +
            //                       System.Label.SB_NCLD_MSG_QUEUES_ERROR;
            // ownerErrorMap.put(ncId, errorMessage);
            todoQueueName.put(ncId, le.OwnerId);
            continue;
          }
        }
      }
    }

    // 名刺Id使用チェック
    if (!needCheckLeadUseCardOwner.isEmpty()
      || !needCheckAccountUseCardOwner.isEmpty()
      || !needCheckContactUseCardOwner.isEmpty()) {
      List<SmartViscaf__NameCard__c> ncs = [SELECT Id,
                                                   Owner.Name,
                                                   OwnerId,
                                                   Owner.IsActive
                                              FROM SmartViscaf__NameCard__c
                                             WHERE Id = :needCheckLeadUseCardOwner
                                                OR Id = :needCheckAccountUseCardOwner
                                                OR Id = :needCheckContactUseCardOwner];
      Map<Id, Id> queueMap = new Map<Id, Id>();
      for (SmartViscaf__NameCard__c nc : ncs) {
        // すでにエラーメッセージがあったら何もしません
        if (ownerErrorMap.containsKey(nc.Id)) {
          continue;
        }
        // 無効ユーザ
        if (nc.Owner.IsActive == false) {
          if (needCheckToDoUseCardOwner.contains(nc.Id) ||
              todoUseOwner.contains(nc.Id)) {
            ownerErrorMap.put(nc.Id, String.format(System.Label.SB_NCLD_MSG_CanNotSetInActiveUserToOwnerToDo, new String[] {nc.Owner.Name}));
          }
          else {
            ownerErrorMap.put(nc.Id, System.Label.SB_NCLD_MSG_CanNotSetInActiveUserToOwner);
          }
          continue;
        }
        //ユーザ以外の場合
        if (isQueue(nc.OwnerId)) {
          // 取引先と責任者の場合
          if (needCheckAccountUseCardOwner.contains(nc.Id)
            || needCheckContactUseCardOwner.contains(nc.Id)) {
            ownerErrorMap.put(nc.Id, System.Label.SB_NCLD_Label_NameCard_Owner_Queue);
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
          if (needCheckLeadUseCardOwner.contains(nc.Id)) {
            queueMap.put(nc.Id, nc.OwnerId);
          }
        }
      }

      // リードキューチェック
      if (!queueMap.isEmpty()) {
        // LeadサポートされていないQueue.Nameがいるので
        // Where SobjectType ＝ 'Lead' が追加しません
        List<QueueSobject> qss = [Select QueueId, SobjectType, Queue.Name
                                    FROM QueueSobject
                                   WHERE QueueId = :queueMap.values()];
        Set<Id> canUserLeadQueues = new Set<Id>();
        Map<Id, String> qssMap = new Map<Id, String>();
        for (QueueSobject qs : qss) {
            qssMap.put(qs.QueueId, qs.Queue.Name);
            if (qs.SobjectType == 'Lead') {
                canUserLeadQueues.add(qs.QueueId);
            }
        }
        for (Id ncId : queueMap.keySet()) {
          if (ownerErrorMap.containsKey(ncId)) {
            continue;
          }
          Id qId = queueMap.get(ncId);
          if (!canUserLeadQueues.contains(qId)) {
            String errorMessage = Lead.getSobjectType().getDescribe().getLabel() +
                                  System.Label.SB_NCLD_MSG_Regist_Error + ': ' +
                                  String.format(System.Label.SB_NCLD_MSG_QUEUES_LEAD_ERROR,new String[]{qssMap.get(qId)});
            ownerErrorMap.put(ncId, errorMessage);
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
                                System.Label.SB_NCLD_MSG_Regist_Error + ': ' +
                                String.format(System.Label.SB_NCLD_MSG_QUEUES_ERROR, new String[]{qMap.get(todoQueueName.get(cardId))});
          ownerErrorMap.put(cardId, errorMessage);
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