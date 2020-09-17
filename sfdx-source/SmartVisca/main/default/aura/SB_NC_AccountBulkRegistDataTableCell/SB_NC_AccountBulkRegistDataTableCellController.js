/**
 *
 *  SB_NC_AccountBulkRegistDataTableCell
 *  取引先・取引先責任者一括登録 DataTable用Cell Controller
 *
 *
 *  Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author K.Yoshida
 *  @Version 2.2  2019.02.XX SV_DEV-1558 LEX 取引先登録 一括画面をLXパッケージ同様のLC化で追加
 *
 **/
({
  // 初期化
  doInit: function (component, event, helper) {
    var fieldName = component.get('v.field.fieldName');
    var cObjectMap = component.get('v.cObjectMap');
    var field = cObjectMap[fieldName];
    // 項目に値がないなら何も表示させない
    if (field == null) {
      return;
    }
    component.set('v.value', cObjectMap[fieldName].value);
    component.set('v.label', cObjectMap[fieldName].label);
    component.set('v.checked', cObjectMap[fieldName].checked);

    if (component.get('v.field.type') == 'pickList') {
      var value = cObjectMap[fieldName].value;
      var recordId = component.get('v.recordId');
      var selectM = component.get('v.selectMap');
      if (recordId != null && selectM != null) {
        var pickOps = selectM[fieldName].pickListOptions;
        //旧一括登録画面に合わせて常にプルダウンリスト先頭の値をセット
        cObjectMap[fieldName].value = pickOps[0].value;
        component.set('v.value', cObjectMap[fieldName].value);
        component.set('v.pickList', pickOps);
      }
    }

    var gid = component.getGlobalId();
    component.set("v.gid", gid);

  },
  // 画面値変更イベント
  changeValue: function (component, event, helper) {
    var ls = event.target.value;
    var cObjectMap = component.get('v.cObjectMap');
    var fieldName = component.get('v.field.fieldName');
    cObjectMap[fieldName].value = ls;
    component.set('v.cObjectMap', cObjectMap);
    component.set('v.value', ls);
    var eventName = component.get('v.eventName');
  }
})