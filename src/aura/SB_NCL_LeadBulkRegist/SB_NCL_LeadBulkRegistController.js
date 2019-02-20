/**
 *
 *  SB_NCL_LeadBulkRegist
 *  リード拡張環境 一括統合用コンポネート Controller
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
  doInit : function (cmp, event, helper) {
      var targetIds = cmp.get("v.recordId");
      cmp.set('v.working', true);
      cmp.set('v.showErrorMsg', false);
      if (targetIds != null) {
        helper.searchLead(cmp, event, helper, targetIds);
        helper.setFieldList(cmp, event, helper);
        helper.setTitleValue(cmp, event, helper);
        helper.setInputValue(cmp, event, helper);
        helper.doInit(cmp, event, helper, targetIds);
      }
      else {
        cmp.set('v.working', false);
      }
    },
    changeSearchCondition : function (cmp, event, helper) {
      // helper.changeSearchCondition(cmp, event, helper);
      cmp.set('v.working', true);
      var targetIds = cmp.get('v.recordId');
      helper.searchLead(cmp, event, helper, targetIds);
    },
    doSomething : function (cmp, event, helper) {
      var name = event.getParam('name');
      if (name == 'close') {
        sforce.one.navigateToURL(cmp.get('v.retUrl'));
        cmp.set('v.working', false);
      }
      else if (name == 'save') {
        cmp.set('v.working', true);
        helper.save(cmp, event, helper);
      }
      else if (name == 'changeCampaign') {
        helper.changeCampaign(cmp, event, helper);
      }
      else if (name == 'cleanCampaign') {
        var inpv = cmp.get("v.inputV");
        inpv.campaignStatusPlick.plickListOptions = null;
        inpv.campaignStatusPlick.selectValue = null;
        cmp.set("v.inputV", inpv);
      } else if (name == 'cleanOwner') {
        var inv = cmp.get("v.inputV");
        inv.ownerId = null;
        cmp.set("v.inputV", inv);
      }
    }
})