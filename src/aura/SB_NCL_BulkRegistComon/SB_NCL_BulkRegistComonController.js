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
    var inputv = component.get("v.inputV");
    if (va == 'Both') {
      inputv.campaignLabel = $A.get("$Label.c.SB_NCLD_Label_Campaign") + $A.get("$Label.c.SB_NCLD_Label_Campaign_ForLead");
      inputv.campaignStatusPlick.plickListTitle = $A.get("$Label.c.SB_NCLD_Label_CampaignStatus") + $A.get("$Label.c.SB_NCLD_Label_Campaign_ForLead");
    }
    else {
      inputv.campaignLabel = $A.get("$Label.c.SB_NCLD_Label_Campaign");
      inputv.campaignStatusPlick.plickListTitle = $A.get("$Label.c.SB_NCLD_Label_CampaignStatus");
    }
    component.set("v.showType", va);
    seSObjEvent.setParams({
          "name" : "changeShowType",
          "value" : va
      }).fire();
  },
  // エラー表示画面のOKボタンクリックする際に実行するJS
  hiddenError : function(component, event, helper) {
    component.set("v.showErrorMsg", false);
    var childCmp = component.find('dataTable');
    childCmp.reSetThead();
  },
  // DataTabeleのヘタ際セット
  reSetThead : function(component, event, helper) {
    var childCmp = component.find('dataTable');
    childCmp.reSetThead();
  },
  // 新規作成時の指定セクションクリックする際に実行するJS
  changeNewSection : function(component, event, helper) {
    component.set("v.openNewSection",component.get("v.openNewSection") == false);
  },
  // 上書きの指定セクションクリックする際に実行するJS
  changeOverWriteSection : function(component, event, helper) {
    component.set("v.openOverWriteSection",component.get("v.openOverWriteSection") == false);
  }
})