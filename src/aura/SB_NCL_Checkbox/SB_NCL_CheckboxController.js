/**
 *
 *  SB_NCL_Checkbox
 *  リード拡張環境 LightningCheckboxコンポネート Controller
 *
 *
 *
 *
 *  Copyright (C) 2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author mao
 *  @Version 1.12      2017.05.XX SV_DEV-511 [LEX]リードの名刺で更新のLightning版対応
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
        var seSObjEvent = component.getEvent("leadBulkRegistEvent");
        seSObjEvent.setParams({
          "name" : eventName
        }).fire();
      }
    }
})