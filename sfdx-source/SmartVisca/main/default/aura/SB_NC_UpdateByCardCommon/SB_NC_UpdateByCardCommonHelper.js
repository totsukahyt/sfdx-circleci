/**
 *
 *  SB_NC_UpdateByCardCommon
 *  基本パッケージ Lightning名刺で更新画面表示入力用コンポネート Helper
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
  getSelectedName : function(component, event, helper) {
    var action = event.getParam("action"),
        row = event.getParam("row");
    var seSObjEvent = component.getEvent("seSObjEvent");
        seSObjEvent.setParams({
              "selectId" : row.id,
              "name" : "update"
          }).fire();
  },// レコード詳細ページへ
  gotoRecord : function(cmp) {
    var targetId = cmp.get("v.reId");
    var navEvt = $A.get("e.force:navigateToSObject");
    if (navEvt) {
      // Componet で起動してるときには有効
      navEvt.setParams({
        "reId": targetId,
        "slideDevName": "detail"
      });
      //navEvt.fire();
      window.location.href = '/' + targetId;
    }
    else if( (typeof sforce != 'undefined') && (sforce != null) ) {
      // Componet を Application に読み込んでいるときにはこっち
      //sforce.one.navigateToURL('/' + targetId);
      window.location.href = '/' + targetId;
    } else {
      // クラシック
      window.open('/' + targetId, "_top");
    }
  },
  search : function(component, event, helper) {
    var seSObjEvent = component.getEvent("seSObjEvent");
        seSObjEvent.setParams({
              "name" : "search"
          }).fire();
  },
})