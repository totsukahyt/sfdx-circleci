/**
 *
 *  SB_NC_AccountBulkRegist
 *  取引先・取引先責任者一括登録コンポーネント Controller
 *
 *  Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author K.Yoshida
 *  @Version 2.2  2019.02.XX SV_DEV-1558 LEX 取引先登録 一括画面をLXパッケージ同様のLC化で追加
 *
 **/
({
  doInit: function (cmp, event, helper) {
    var targetIds = cmp.get("v.recordId");
    cmp.set('v.working', true);
    if (targetIds != null) {
      // helper.searchLead(cmp, event, helper, targetIds);
      helper.setFieldList(cmp, event, helper);
      helper.setTitleValue(cmp, event, helper);
      helper.setInputValue(cmp, event, helper);
      // setInputValueのコールバック時に呼ぶよう変更
      //helper.searchAllData(cmp, event, helper, targetIds, true);
    }
    else {
      cmp.set('v.working', false);
    }
  },
  // 検索条件変更JS
  changeSearchCondition: function (cmp, event, helper) {
    // helper.changeSearchCondition(cmp, event, helper);
    cmp.set('v.working', false);
    var targetIds = cmp.get('v.recordId');
    helper.searchAllData(cmp, event, helper, targetIds, false);
  },
  // イベントをキャッチしたJS
  doSomething: function (cmp, event, helper) {
    var name = event.getParam('name');
    if (name == 'close') {
      sforce.one.navigateToURL(cmp.get('v.retUrl'));
      cmp.set('v.working', false);
    }
    else if (name == 'save') {
      cmp.set('v.working', true);
      helper.save(cmp, event, helper);
    }
    else if (name == 'cleanOwner') {
      var inv = cmp.get("v.inputV");
      inv.ownerId = null;
      cmp.set("v.inputV", inv);
    }
  }
})