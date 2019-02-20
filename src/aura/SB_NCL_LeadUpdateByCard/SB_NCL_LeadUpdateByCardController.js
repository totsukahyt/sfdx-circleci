/**
 *
 *  SB_NCL_LeadUpdateByCard
 *  リード拡張環境 Lightning名刺で更新用コンポネート Controller
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
	doInit : function(component, event, helper) {
    component.set("v.working", true);
    var targetId = component.get("v.recordId");
    if (targetId) {
      helper.getFields(component, event, helper, targetId);
      helper.searchCard(component, event, helper, targetId);
    }
    helper.getInpitV(component, event, helper, targetId);
	},
  updateNameCard : function(component, event, helper) {
    component.set("v.working", true);
    component.set("v.errorMsg", '');
    helper.updateNameCard(component, event, helper);
  }
})