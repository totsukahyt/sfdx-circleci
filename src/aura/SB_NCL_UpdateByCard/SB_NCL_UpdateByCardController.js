/**
 *
 *  SB_NCL_UpdateByCard
 *  リード拡張環境 Lightning名刺で更新共通コンポネート Controller
 *
 *
 *
 *
 *  Copyright (C) 2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author gao
 *  @Version 1.12      2017.05.XX SV_DEV-910 [LEX]リードの名刺で更新のLightning版対応
 *
 **/
({
  search1 : function(component, event, helper) {
    component.set("v.inputV.radioValue", component.get("v.inputV.searchTypeSelectOpts[0].value"));
    helper.search(component, event, helper);
  },
  search2 : function(component, event, helper) {
    component.set("v.inputV.radioValue", component.get("v.inputV.searchTypeSelectOpts[1].value"));
    helper.search(component, event, helper);
  },
  search3 : function(component, event, helper) {
    component.set("v.inputV.radioValue", component.get("v.inputV.searchTypeSelectOpts[2].value"));
    helper.search(component, event, helper);
  },
  getSelectedName : function(component, event, helper) {
    helper.getSelectedName(component, event, helper);
  },
  close : function(component, event, helper) {
    helper.gotoRecord(component);
  }
})