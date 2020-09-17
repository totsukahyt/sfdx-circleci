/**
 *
 *  SmartVisca
 *    SB_NC_OrgLTreeController.js
 *  Lightning Component による 組織ツリー
 *
 * Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2017.11.xx
 *
 **/
({
  // 画面 初期化 候補の名刺一覧取得
  doInit : function(cmp, event, helper) {
    var targetId = cmp.get("v.recordId");
    var showTitle = cmp.get("v.showTitle");
    var maxRecs = cmp.get("v.maxRecs");
    if (targetId) {
      // helper.createOrgTreeItems(cmp, targetId, showTitle);
      helper.createOrgTreeItems(cmp, targetId, showTitle, maxRecs);
    }
  },
  // 選択されたノードが 氏名 だったら 該当の名刺レコード詳細画面へ遷移
  onSelect: function (cmp, event, helper) {
    //return name of selected tree item
    var sleName = event.getParam('name');
    var clickToRecord = cmp.get("v.clickToRecord");
    if (sleName && clickToRecord) {
      // 選択された レコードへ
      var info = JSON.parse(sleName);
      var targetId = cmp.get("v.recordId");
      if (info.recordId === targetId) {
        return;
      }
      var navEvt = $A.get("e.force:navigateToSObject");
      navEvt.setParams({
        "isredirect": false,    // ナビゲーション履歴の現在の URL を新しい URL に置き換える
        "recordId": info.recordId,
        "slideDevName": "detail"  // レコード詳細スライド
      });
      navEvt.fire();
    }
  }

})