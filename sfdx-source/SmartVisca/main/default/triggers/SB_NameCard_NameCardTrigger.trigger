/**
 *
 * SB_NameCard_NameCardTrigger
 * 名刺オブジェクトのトリガ
 *
 * Copyright (C) 2012-2014 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  History :
 *  @Version 1      2014.4.2x 名刺のトリガは1つにまとめます。
 *  @Version 2      2017.xx.xx 自動連携サポート
 *  @Version 3      2018.01.xx リード拡張パッケージの連携機能対応
 *  @Version 2.0.2  2018.07.xx  RenkeiLeadActive__c true で リード拡張パッケージの連携ハンドラを呼ぶ
 *  @Version 2.0.3  2018.10.xx V2.0.3 リード登録機能を有効化 してたら リード自動連携については、2次納品で新規追加したときの処理を、こっち（基本）でやる。
 *  @Version 2.4    2019.07.xx  SV_DEV-1854 自動連携: 自動連携の結果取引先が作成されても、取引先取込日時が空白のまま。ハンドラの呼び出し順序を変える。
 *                  2019.07.xx  SV_DEV-463 名寄せ条件のカスタマイズ
 *
 **/
trigger SB_NameCard_NameCardTrigger on NameCard__c (after delete, after insert, after undelete,
after update, before insert, before update, before delete) {

  // 2014.4.2x
  // キー(key__c) の値を設定する。
  // 従来、SB_NameCard_setExternalKey.trigger でやってた処理
  if (Trigger.isBefore == true &&
      (Trigger.isInsert == true || Trigger.isUpdate == true)) {  // 追加か更新 の前
      for (NameCard__c nc: Trigger.new) {
          nc.key__c = nc.person_name_last__c + ' ' + nc.person_name_first__c + '&' + nc.email__c;
      }
  }
  // 2019.07.XX
  // 名寄せ条件のカスタマイズが有効化されていた場合、before deleteで名寄せを実行します
  if (Trigger.isBefore == true && Trigger.isDelete == true) {  // 削除 の前
    if (SB_NameCard_Util.isTriggerMergeNameCards() == true) {           // カスタム設定を確認します。
      //if (SB_NameCard_Util.isTriggerMergeExpandCriteria() == true) {    // 名寄せ条件拡張設定を確認します。
      if (SB_NameCard_MergeBuisnessCardsFuture.isTriggerMergeExpandCriteria == true) {    // 名寄せ条件拡張設定を確認します。
        if ( SB_NameCard_MergeBuisnessCardsFuture.futureMergeCalled == false) {
          List<Id> targetIdList = new List<Id>();
          // 処理対象名刺データ一覧を確定
          for ( NameCard__c nc:Trigger.old ){
            targetIdList.add(nc.Id);
          }
          SB_NameCard_MergeBuisnessCardsFuture.reLinkBusinessCards(targetIdList);
        }
      }
    }
  }
  // 2014.4.2x
  // 名刺を追加、更新、削除、復活したとき、名刺を名寄します。
  // 従来、SB_NameCard_AftInsUpdDelOnNameCard.trigger でやってた処理
  system.debug('__Config.TriggerMergeNameCards : ' + SB_NameCard_Util.isTriggerMergeNameCards());
  if (SB_NameCard_Util.isTriggerMergeNameCards() == true) {           // カスタム設定を確認します。
    //if (SB_NameCard_Util.isTriggerMergeExpandCriteria() == true) {    // 名寄せ条件拡張設定を確認します
    if (SB_NameCard_MergeBuisnessCardsFuture.isTriggerMergeExpandCriteria == true) {    // 名寄せ条件拡張設定を確認します
      if (Trigger.isAfter == true &&
       (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete)) {    // 追加、更新、復活 の後
        if ( SB_NameCard_MergeBuisnessCardsFuture.futureMergeCalled == false) {
          List<Id> targetIdList = new List<Id>();
          // 処理対象名刺データ一覧を確定
          for ( NameCard__c nc:Trigger.New ){
            targetIdList.add(nc.Id);
          }
          SB_NameCard_MergeBuisnessCardsFuture.mergeBusinessCards(targetIdList);
        }
      }
    }else{
      if (Trigger.isAfter == true &&
       (Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete || Trigger.isUndelete)) {    // 追加、更新、削除、復活 の後
          // 同一リクエスト内で、重複実行を避けるために値を変更しておく
          if ( SB_NameCard_MergeBuisnessCardsAfter.firstRun == true) {
              // 処理対象名刺データ一覧を確定
              List<NameCard__c> targets = null;
              if ( Trigger.isDelete) {
                  targets = Trigger.Old;
              }
              else {
                  targets = Trigger.New;
              }
              // 名刺を名寄せする処理を実行
              SB_NameCard_MergeBuisnessCardsAfter handler = new SB_NameCard_MergeBuisnessCardsAfter();
              handler.mergeBusinessCards( targets);
          }
      }
    }
  }

  // 2014.4.2x
  // 名刺の追加時、既存の名刺の最新名刺を更新するので、そのとき、既存名刺の所有者にフィードで、通知します。
  // 従来、SB_NameCard_createFeedOnNameCard.trigger でやってた処理
  system.debug('__NameCard__c.sObjectType.getDescribe().isFeedEnabled() : ' + NameCard__c.sObjectType.getDescribe().isFeedEnabled());
  system.debug('__Config.TriggerCreateFeedOnName : ' + SB_NameCard_Util.isTriggerCreateFeedOnName());
  if (NameCard__c.sObjectType.getDescribe().isFeedEnabled() == true && // フィード追跡が有効 かつ
      SB_NameCard_Util.isTriggerCreateFeedOnName() == true &&
      SB_NameCard_MergeBuisnessCardsAfter.firstRun == false) {         // カスタム設定を確認します。
      if (Trigger.isBefore == true && Trigger.isUpdate == true) {     // 更新 の前
        // SB_NameCard_CreateFeedOnNameCardFactory の中で、カスタム設定により新旧のハンドラを呼び分けます。
        SB_NameCard_CreateFeedOnNameCardFactory f = new SB_NameCard_CreateFeedOnNameCardFactory();
        f.run(Trigger.new, Trigger.oldMap);

      }
  }
  // 2014.7.7
  // 名刺を追加、更新、削除、復活したとき、1次納品や2次納品の情報を 名刺履歴オブジェクトに保存します。
  system.debug('__Config.TriggerHistoryIsActive : ' + SB_NameCard_Util.isTriggerHistoryIsActive());
  if (SB_NameCard_Util.isTriggerHistoryIsActive() == true &&      // カスタム設定を確認します。
    Trigger.isAfter == true) {                                  // After のときだけ
    SB_NameCard_HistoryTriggerHandler handler = new SB_NameCard_HistoryTriggerHandler();
    if (Trigger.isInsert == true) {
      handler.OnAfrerInsert(Trigger.new);
    }
    else if (Trigger.isUpdate == true) {
      handler.OnAfterUpdate(Trigger.new, Trigger.oldMap);
    }
    else if (Trigger.isDelete == true) {
      handler.OnAfterDelete(Trigger.old);
    }
    else if(Trigger.isUndelete) {
      handler.OnAfterUndelete(Trigger.new);
    }
    handler.finalize();
  }

  //// v1.22 2018.03.xx
  //// 納品された キャンペーンID テキスト から キャンペーンID 参照項目 をセットする トリガ
  //if (Trigger.isBefore == true &&  (Trigger.isInsert || Trigger.isUpdate) &&
  //  SB_NameCard_BasicSetting.getNameCardBasicSetting().ScanSelectCampaign__c == true &&  // スキャン:キャンペーン選択を有効化
  //  SB_NameCard_Util.isTriggerCampaignHandler() == true) {    //トリガでキャンペーンIDをセットする。 基本設定 の指定　との AND
  //  //SB_NameCard_Util.isEnableLeadExt112()) {                // リード拡張パッケージ 1.12 以降がインストールされている
  //  //
  //  String nsLx = SB_NameCard_Util.getLeadExNamespacePrefix();
  //  SB_NameCard_TriggerHandlerAbstract handler = SB_NameCard_TriggerHandlerFactory.getInstance(nsLx, 'SB_NameCardL_CamapignIdTriggerHandler');
  //  if (Trigger.isInsert == true && handler.didInsert() == false) {
  //    handler.onBeforeInsert(Trigger.new);
  //  }
  //  else if (Trigger.isUpdate == true && handler.didUpdate() == false) {
  //    handler.onBeforeUpdate(Trigger.new, Trigger.oldmap);
  //  }
  //}

  // 2017.03.xx 自動連携 機能追加
  //マッピングハンドラー用、ワークフローを二回実行防ぐ為
  if (Trigger.isBefore == true &&  (Trigger.isInsert || Trigger.isUpdate) &&
      SB_NameCard_BasicSetting.getNameCardBasicSetting().RenkeiActive__c == true &&       // 自動連携 有効
      SB_NameCard_BasicSetting.getNameCardBasicSetting().RenkeiLeadActive__c == false &&  // v1.22 2018.01.xx  リード登録機能を有効化していない
      SB_NameCard_Util.isTriggerRenkeiHandler() == true) {  // 2018.03.xx v1.22  自動連携のトリガハンドラを呼ぶ
    SB_NameCard_RenkeiTriggerHandler handler = new SB_NameCard_RenkeiTriggerHandler();
    if(Trigger.isInsert == true && SB_NameCard_RenkeiTriggerHandler.firstRunInsert == true) {
      handler.insertRennkei(Trigger.new);
    }
    else if(Trigger.isUpdate == true && SB_NameCard_RenkeiTriggerHandler.firstRunUpdate == true) {
      handler.updateRennkei(Trigger.new,Trigger.oldmap);
    }
  }

  // 2017.03.xx 自動連携 機能追加
  // 2次納品で新規追加したとき、新規作成あるいは更新したアカウント、コンタクト名刺のIDがないので、ここでやる
  if (Trigger.isAfter == true && Trigger.isInsert  == true &&
      SB_NameCard_BasicSetting.getNameCardBasicSetting().RenkeiActive__c == true &&
      (SB_NameCard_Util.isTriggerRenkeiHandler() == true ||   // 2018.03.xx v1.22  自動連携のトリガハンドラを呼ぶ
      SB_NameCard_BasicSetting.getNameCardBasicSetting().RenkeiLeadActive__c == true)  // v1.22 2018.01.xx  リード登録機能を有効化していない  → V2.0.3 リード登録機能を有効化
      ) {
    SB_NameCard_RenkeiAfterInsTrigerHandler handler = new SB_NameCard_RenkeiAfterInsTrigerHandler();
    handler.onAfterInsert(Trigger.new);
  }

  // 2018.01.xx v1.22 リード拡張パッケージの 連携機能の呼び出し
  // リード拡張パッケージのトリガハンドラー クラスを呼ぶためのクラスを呼ぶ
  if (Trigger.isBefore == true &&  (Trigger.isInsert || Trigger.isUpdate) &&
      //SB_NameCard_Util.isTriggerLeadExRenkeiHandler() == true) { //&&    // Lead連携拡張パッケージの中にある 自動連携のトリガハンドラを呼ぶ
      SB_NameCard_BasicSetting.getNameCardBasicSetting().RenkeiActive__c == true &&       // 自動連携 有効
      SB_NameCard_BasicSetting.getNameCardBasicSetting().RenkeiLeadActive__c == true ) {   // リード登録機能を有効化
    String nsLx = SB_NameCard_Util.getLeadExNamespacePrefix();
    SB_NameCard_TriggerHandlerAbstract handler = SB_NameCard_TriggerHandlerFactory.getInstance(nsLx, 'SB_NameCardL_RenkeiTriggerHandler');
    if (Trigger.isInsert == true && handler.didInsert() == false) {
      handler.onBeforeInsert(Trigger.new);
    }
    else if (Trigger.isUpdate == true && handler.didUpdate() == false) {
      handler.onBeforeUpdate(Trigger.new, Trigger.oldmap);
    }
  }

  // 2019.07.xx v2.4  SV_DEV-1854 自動連携: 自動連携の結果取引先が作成されても、取引先取込日時が空白のまま。→ ハンドラを最後に呼ぶ
  // 2014.4.2x
  // 名刺の追加、更新時、項目「取引先」、「リード」に値がセットされていたら、取引先取込日時 リード取込日時に現在時刻をセットします。
  // 従来、SB_NameCard_BfInsUpdOnNameCard.trigger でやってた処理
  system.debug('__Config.TriggerRegDateTime : ' + SB_NameCard_Util.isTriggerRegDateTime());
  if (SB_NameCard_Util.isTriggerRegDateTime() == true) {              // カスタム設定を確認します。
      if (Trigger.isBefore == true &&
          (Trigger.isInsert == true || Trigger.isUpdate == true)) {  // 追加か更新 の前
          SB_NameCard_UpdateRegDatetime handler = new SB_NameCard_UpdateRegDatetime();
          handler.run(Trigger.new, Trigger.oldMap);
      }
  }

}