/**
 *
 *  SB_NCL_LeadUpdateByCard
 *  リード拡張環境 Lightning名刺で更新データ操作用コンポネート Controller
 *
 *
 *
 *
 *  Copyright (C) 2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author gao
 *  @Version 拡張パッケージ：Lead Ex. 1.12      2017.05.XX 初版
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
  updateNameCard : function(component, event, helper) {
    component.set("v.working", true);
    component.set("v.errorMsg", '');
    helper.updateNameCard(component, event, helper);
  }
})