/**
 *
 *  SmartVisca
 *    SB_NC_SetNewCareerHelper.js
 *   転職先を設定
 *
 * Copyright (C) 2016 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2016.11.xx
 *  @Version 2.4    2019.06.xx SV_DEV-873/SV_DEV-1614 タイトル部分の表示不具合修正
 *
 **/
({

  // 最新の名刺？
  checkSaishinCard : function(cmp, targetId, callback) {
    var action = cmp.get("c.checkSaishinCard");
    action.setParams({
      "cardId": targetId
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (cmp.isValid() && state === "SUCCESS") {
        var result = JSON.parse(response.getReturnValue());
        if (result.saishin === false) {
          // 最新じゃなかったとき
          cmp.set("v.initialError", true);
          cmp.set("v.errorMsg", result.error);
          //   var createRecordEvent = $A.get("e.force:createRecord");

          // var msgToast = $A.get("e.force:showToast");
          // msgToast.setParams({
          //   "message": result.error,
          //   "type": "error",
          // });
          // msgToast.fire();

        }else{
          // 最新のとき
          cmp.set("v.fromLabel", result.fromLabel);
          cmp.set("v.fromId", result.fromId);
        }
      }
    });
    $A.enqueueAction(action);
  },

  // 名刺レコードの転職先の名刺 参照項目を更新
  setNewCareer : function(cmp, targetId, newCardId) {
    var action = cmp.get("c.setNewCareer");
    action.setParams({
      "cardId": targetId,
      "newCareerCardId": newCardId
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (cmp.isValid() && state === "SUCCESS") {
        var result = JSON.parse(response.getReturnValue());
        // 例外があってもメソッドは正常終了して エラー内容を通知する。
        if (result.success) {
          // レコード詳細ページへ
          this.gotoRecord(cmp);
        }
        else {
          // エラーがあった場合、画面に表示
          cmp.set("v.errorMsg", result.error);
          cmp.set('v.saving', false);
        }
      }
      else if (state === "ERROR") {
        cmp.set('v.saving', false);
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            cmp.set("v.errorMsg", errors[0].message);
          }
        } else {
          alert("Unknown error");
        }
      }
      else {
        cmp.set('v.saving', false);
        alert('setNewCareer other error.');
      }
    });
    $A.enqueueAction(action);
  },
  // レコード詳細ページへ
  gotoRecord : function(cmp) {
    var targetId = cmp.get("v.recordId");
    var navEvt = $A.get("e.force:navigateToSObject");
    if (navEvt) {
      // Componet で起動してるときには有効
      navEvt.setParams({
        "recordId": targetId,
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

})