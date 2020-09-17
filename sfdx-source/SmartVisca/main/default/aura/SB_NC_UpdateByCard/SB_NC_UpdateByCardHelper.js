/**
 *
 *  SB_NC_UpdateByCard
 *  基本パッケージ Lightning名刺で更新データ操作用コンポネート Helper
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
  // 名刺検索
  searchCard : function(component, event, helper, targetId) {
    var action = component.get('c.getUpdateByCard');
    action.setParams({
      "targetId": targetId,
      "searchType" : component.get('v.inputV.radioValue')
    });
    action.setCallback(this,function(response) {
      var state = response.getState();
      if (state == 'SUCCESS') {
        var res1 = response.getReturnValue();
        var res = JSON.parse(res1);
        for (var i = 0 ;i<res.dataList.length;i++) {
          var r = res.dataList[i];
          r.LINK = window.location.origin + '/one/one.app#/sObject/' + r.id + '/view';
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
  getFields : function(component, event, helper, targetId) {
    var action = component.get('c.getFieldList');
    action.setParams({
      "targetId": targetId
    });
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
  getInpitV : function(component, event, helper, targetId) {
    var action = component.get('c.getInputValue');
    action.setParams({
      "targetId": targetId
    });
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
    var action = component.get('c.updateByCard');
    var sObjectDto = component.get('v.sObjectDto');
    action.setParams({
      'targetId' : component.get("v.recordId"),
      "cardId": targetId
    });
    action.setCallback(this,function(response) {
      var state = response.getState();
      component.set('v.saveing',false);
      if (state == 'SUCCESS') {
        var res1 = response.getReturnValue();
        var res = JSON.parse(res1);
        if (res.success == true) {
          var childCmp = component.find('updateNameCardCmp');
          childCmp.close();
        }
        else {
          component.set("v.errorMsg", res.error);
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