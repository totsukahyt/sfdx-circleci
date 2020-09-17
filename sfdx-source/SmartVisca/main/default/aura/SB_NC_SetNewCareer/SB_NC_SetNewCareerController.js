/**
*
*  SmartVisca
*    SB_NC_SetNewCareerController.js
*   転職先を設定
*
* Copyright (C) 2016 SunBridge Inc. All Rights Reserved.
*
*  @author sawano
*  @Version 1      2016.11.xx
*
**/
({

  // 初期化
  doInit : function (cmp, event, helper) {
    // SB_NC_CareerErrorNotLatest
    var targetId = cmp.get("v.recordId");
    if (!targetId)  {
      return;
    }
    helper.checkSaishinCard(cmp, targetId);

  },

  toggleSpinner : function (cmp, event) {
    var spinner = cmp.find("mySpinner");
    $A.util.toggleClass(spinner, "slds-hide");
  },

  // ルックアップ1のモーダルで選択されたときのイベントのハンドラ
  handleSelSObject : function(cmp, event, helper) {
    var selSobj = event.getParam("sobj");
    cmp.set('v.newCard', selSobj);
  },

  /**ルックアップ2
   * Handler for receiving the updateLookupIdEvent event
   */
  handleAccountIdUpdate : function(cmp, event, helper) {
    // Get the Id from the Event
    var accountId = event.getParam("sObjectId");

    // Get the Instance Id from the Event
    var instanceId = event.getParam("instanceId");

    // Determine the instance Id of the component that fired the event
    if (instanceId == "MyAccount") {
      // Set the Id bound to the View
      cmp.set('v.recordId', accountId);
    }
    else {
      console.log('Unknown instance id: ' + instanceId);
    }
  },

  /**ルックアップ2
   * Handler for receiving the clearLookupIdEvent event
   */
  handleAccountIdClear : function(cmp, event, helper) {
    // Get the Instance Id from the Event
    var instanceId = event.getParam("instanceId");

    // Determine the instance Id of the component that fired the event
    if (instanceId == "MyAccount") {
      // Clear the Id bound to the View
      cmp.set('v.recordId', null);
    }
    else {
      console.log('Unknown instance id: ' + instanceId);
    }
  },

  // キャンセル
  cancel : function(cmp, event, helper) {
    helper.gotoRecord(cmp);
  },

  // 保存
  save : function(cmp, event, helper) {
    var newCard = cmp.get('v.newCard');
    var targetId = cmp.get('v.recordId');
    if (newCard === null) {
      return;
    }
    cmp.set('v.saving', true);
    // カスタム表示ラベルの英語の方で表示されてしまうので、
    // if (newCard.Id === targetId) {
    //   var msg = $A.get("$Label.c.SB_MSG_NewCareerMustBeAnother");
    //   cmp.set("v.errorMsg", msg);
    //   return;
    // }
    helper.setNewCareer(cmp, targetId, newCard.id);
  },

  clickNewCard : function(cmp, event, helper) {
    var c = cmp.find("newCardPopover");
    $A.util.toggleClass(c, "slds-hide");
    // if ($A.util.hasClass(c, "slds-hide")) {
    //   $A.util.removeClass(c, "slds-hide");
    // }
    // else {
    //   $A.util.addClass(c, "slds-hide");
    // }
  },

})