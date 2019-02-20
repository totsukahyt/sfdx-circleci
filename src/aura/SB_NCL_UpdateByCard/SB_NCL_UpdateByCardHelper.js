/**
 *
 *  SB_NCL_UpdateByCard
 *  リード拡張環境 Lightning名刺で更新共通コンポネート Helper
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
	getSelectedName : function(component, event, helper) {
		var action = event.getParam("action"),
        row = event.getParam("row");
    var seSObjEvent = component.getEvent("seSObjEvent");
        seSObjEvent.setParams({
              "selectId" : row.Id,
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
      navEvt.fire();
    }
    else if( (typeof sforce != 'undefined') && (sforce != null) ) {
      // Componet を Application に読み込んでいるときにはこっち
      sforce.one.navigateToURL('/' + targetId);
    } else {
      // クラシック
      window.open('/' + targetId, "_top");
    }
  },
  search : function(component, event, helper) {
    var action = event.getParam("action"),
        row = event.getParam("row");
    var seSObjEvent = component.getEvent("seSObjEvent");
        seSObjEvent.setParams({
              "selectId" : row.Id,
              "name" : "search"
          }).fire();
  },
})