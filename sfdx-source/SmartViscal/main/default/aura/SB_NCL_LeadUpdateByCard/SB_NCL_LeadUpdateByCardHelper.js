/**
 *
 *  SB_NCL_LeadUpdateByCard
 *  リード拡張環境 Lightning名刺で更新データ操作用コンポネート Helper
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
  // 名刺検索
	searchCard : function(component, event, helper, targetId) {
		var action = component.get('c.getUpdateByCard');
    action.setParams({
      "targetId": targetId,
    });
    action.setCallback(this,function(response) {
      var state = response.getState();
      if (state == 'SUCCESS') {
        var res1 = response.getReturnValue();
        var res = JSON.parse(res1);
        for (var i = 0 ;i<res.dataList.length;i++) {
          var r = res.dataList[i];
          r.LINK = window.location.origin + '/one/one.app#/sObject/' + r.Id + '/view';
        }
        component.set('v.sObjectDto', res);
      }
      else {
        component.set("v.errorMsg",response.getError()[0].message);
        component.set('v.loading',false);
      }
      component.set("v.working", false);
    });
    $A.enqueueAction(action);
	},
  // 表示項目を取得
  getFields : function(component, event, helper) {
    var action = component.get('c.getFieldList');
    action.setCallback(this,function(response) {
      var state = response.getState();
      if (state == 'SUCCESS') {
        var res1 = response.getReturnValue();
        var res = JSON.parse(res1);
        component.set('v.fieldList', res);
      }
      else {
        component.set("v.errorMsg",response.getError()[0].message);
        component.set('v.loading',false);
      }
      component.set("v.working", false);
    });
    $A.enqueueAction(action);
  },
  // 入力内容を取得
  getInpitV : function(component, event, helper) {
        var action = component.get('c.getInputValue');
    action.setCallback(this,function(response) {
      var state = response.getState();
      if (state == 'SUCCESS') {
        var res1 = response.getReturnValue();
        var res = JSON.parse(res1);
        component.set('v.inputV', res);
      }
      else {
        component.set("v.errorMsg",response.getError()[0].message);
        component.set('v.loading',false);
      }
      component.set("v.working", false);
    });
    $A.enqueueAction(action);
  },
  // 名刺で更新
  updateNameCard : function(component, event, helper) {
    var targetId = event.getParam("selectId")
    var action = component.get('c.updateLead');
    var sObjectDto = component.get('v.sObjectDto');
    action.setParams({
      'leadId' : component.get("v.recordId"),
      "targetId": targetId,
      "overWrite": component.get('v.inputV.checkboxValue')
    });
    action.setCallback(this,function(response) {
      var state = response.getState();
      component.set('v.saveing',false);
      if (state == 'SUCCESS') {
        var res1 = response.getReturnValue();
        var res = JSON.parse(res1);
        if (res.isOk == true) {
          var childCmp = component.find('updateNameCardCmp');
          childCmp.close();
        }
        else {
          component.set("v.errorMsg", res.message);
          component.set("v.working", false);
        }
      }
      else {
        component.set("v.errorMsg",response.getError()[0].message);
        component.set('v.loading',false);
        component.set("v.working", false);
      }
    });
    $A.enqueueAction(action);
  }
})