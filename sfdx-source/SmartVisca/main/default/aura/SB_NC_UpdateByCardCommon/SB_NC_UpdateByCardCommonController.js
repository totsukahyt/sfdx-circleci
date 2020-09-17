/**
 *
 *  SB_NC_UpdateByCardCommon
 *  基本パッケージ Lightning名刺で更新画面表示入力用コンポネート Controller
 *
 *
 *
 *
 *  Copyright (C) 2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author mao
 *  @Version 基本パッケージ： V2.1(1.23)      2018.11.XX 初版
 *
 **/
({
  search1 : function(component, event, helper) {
    var oldSelectIndex = component.get("v.inputV.radioValue");
    var newSelectIndex = component.get("v.inputV.searchTypeSelectOpts[0].value");
    if (oldSelectIndex != newSelectIndex) {
      component.set("v.inputV.radioValue", newSelectIndex);
      helper.search(component, event, helper);
    }
  },
  search2 : function(component, event, helper) {
    var oldSelectIndex = component.get("v.inputV.radioValue");
    var newSelectIndex = component.get("v.inputV.searchTypeSelectOpts[1].value");
    if (oldSelectIndex != newSelectIndex) {
      component.set("v.inputV.radioValue", newSelectIndex);
      helper.search(component, event, helper);
    }
  },
  search3 : function(component, event, helper) {
    var oldSelectIndex = component.get("v.inputV.radioValue");
    var newSelectIndex = component.get("v.inputV.searchTypeSelectOpts[2].value");
    if (oldSelectIndex != newSelectIndex) {
      component.set("v.inputV.radioValue", newSelectIndex);
      helper.search(component, event, helper);
    }
  },
  getSelectedName : function(component, event, helper) {
    helper.getSelectedName(component, event, helper);
  },
  close : function(component, event, helper) {
    helper.gotoRecord(component);
  }
})