/**
 *
 *  SB_NC_UpdateByCard
 *  基本パッケージ Lightning名刺で更新データ操作用コンポネート Controller
 *
 *
 *
 *
 *  Copyright (C) 2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 基本パッケージ： 2.1(1.23)      2018.11.XX 初版
 *
 **/
({
  // 初期化
  doInit : function(component, event, helper) {
    component.set("v.working", true);
    var targetId = component.get("v.recordId");
    if (targetId) {
      helper.getFields(component, event, helper, targetId);
      helper.searchCard(component, event, helper, targetId);
    }
    helper.getInpitV(component, event, helper, targetId);
  },
  // 名刺で更新
  doEvent : function(component, event, helper) {
    component.set("v.working", true);
    component.set("v.errorMsg", '');
    var ename = event.getParam("name");
    if (ename == 'update') {
      helper.updateNameCard(component, event, helper);
    }
    else {
      var targetId = component.get("v.recordId");
      helper.searchCard(component, event, helper, targetId);
    }
  }
})