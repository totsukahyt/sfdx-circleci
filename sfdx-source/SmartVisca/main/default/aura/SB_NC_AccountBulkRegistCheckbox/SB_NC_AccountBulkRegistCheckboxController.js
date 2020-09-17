/**
 *
 *  SB_NC_AccountBulkRegistCheckbox
 *  取引先・取引先責任者一括登録 LightningスタイルのCheckBoxコンポーネント Controller
 *
 *
 *  Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author K.Yoshida
 *  @Version 2.2  2019.02.XX SV_DEV-1558 LEX 取引先登録 一括画面をLXパッケージ同様のLC化で追加
 *
 **/
({
    doinit : function(component, event, helper) {
    },
    // クリックすると値変更
    clickbox : function(component, event, helper) {
      var cObjectMap = component.get('v.cObjectMap');
      var fieldName = component.get('v.fieldName');
      if (cObjectMap != null && fieldName != null) {
        cObjectMap[fieldName].checked = event.target.checked;
        component.set('v.cObjectMap', cObjectMap);
      }
      component.set("v.checked", event.target.checked);

      var eventName = component.get('v.eventName');
      if (eventName != null) {
        var seSObjEvent = component.getEvent("accountBulkRegistEvent");
        seSObjEvent.setParams({
          "name" : eventName,
          "value": component.get('v.boxid'),
          "fieldName": component.get('v.fieldName')
        }).fire();
      }
    }
})