/**
 *
 *  SB_NCL_BulkRegistComon
 *  リード拡張環境 Lightning統合用共通コンポネート Controller
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
	doInit : function(component, event, helper) {
	},
  selectedSearchMenu : function(component, event, helper) {
    var selectedMenuItemValue = event.getParam("value");
    var cods = component.get('v.inputV.searchConditions');
    for (var i = 0; i < cods.length; i ++) {
      var cod = cods[i];
      if (cod.value == selectedMenuItemValue) {
        if (cod.groupName != 'Contact') {
          component.set('v.inputV.searchConditionValue', selectedMenuItemValue);
        }
        else {
          component.set('v.inputV.searchConditionValueContact', selectedMenuItemValue);
        }
      }
    }
    var changeSearchCondition = component.getEvent("changeSearchCondition");
    changeSearchCondition.fire();
  },
  changeUseNameCardOwner : function(component, event, helper) {
     component.set("v.inputV.useNameCardOwner", event.target.checked);
  },
  changeUseNameCardOwnerContact : function(component, event, helper) {
     component.set("v.inputV.useNameCardAccountOwner", event.target.checked);
  },
  close : function(component, event, helper) {
    var seSObjEvent = component.getEvent("leadBulkRegistEvent");
    seSObjEvent.setParams({
          "name" : "close"
      }).fire();
  },
  save : function(component, event, helper) {
    var seSObjEvent = component.getEvent("leadBulkRegistEvent");
    seSObjEvent.setParams({
          "name" : "save"
      }).fire();
  },
  showModal : function(component, event, helper) {
    component.set('v.showModal', true);
  },
  // 候補登録先変更する際に実行するJS
  changeShowType : function(component, event, helper) {
    var seSObjEvent = component.getEvent("leadBulkRegistEvent");
    var va = event.getParam("value");
    component.set("v.showType", va);
    seSObjEvent.setParams({
          "name" : "changeShowType",
          "value" : va
      }).fire();
  },
  hiddenError : function(component, event, helper) {
    component.set("v.showErrorMsg", false);
    var childCmp = component.find('dataTable');
    childCmp.reSetThead();
  },
  reSetThead : function(component, event, helper) {
    var childCmp = component.find('dataTable');
    childCmp.reSetThead();
  },
  changeNewSection : function(component, event, helper) {
    component.set("v.openNewSection",component.get("v.openNewSection") == false);
  },
  changeOverWriteSection : function(component, event, helper) {
    component.set("v.openOverWriteSection",component.get("v.openOverWriteSection") == false);
  }
})