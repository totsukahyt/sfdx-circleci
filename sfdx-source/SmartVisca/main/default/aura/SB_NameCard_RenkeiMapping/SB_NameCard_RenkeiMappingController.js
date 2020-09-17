/**
*
*  SB_NameCard_RenkeiMapping
*   連携マッピングを設定する画面 Controller
*
*   選択された連携先のオブジェクトに応じてマッピング可能な選択肢を表示させます
*
*  Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
*
*  @author mao
*  @Version 1.22      2017.07.XX SV_DEV-527 SmartVisca 基本設定の リード対応
*  @Version 1.22      2018.02.XX SV_DEV-735 基本設定レコードが二つ作成される
*  @Version 2.4       2019.05.XX SV_DEV-1630と合わせてリファクタリングを実施
*
**/
({
  //初期化
  doInit : function(component, event, helper) {
     component.set('v.issave',true);
     component.set('v.textHidden','ishidden');
     component.set('v.urlHidden','ishidden');
     component.set('v.login',true);
     component.set('v.showAlert',false);
     component.set('v.none', component.get('v.labMap.SB_NC_SETTING_LABEL_NONE'));
     helper.setRecordType(component);
     helper.setData(component,'');
  },
  //レコードタイプ変更
  changeRecord: function (component, event, helper) {
    var res = component.get('v.recordTypes');
    var re = event.getSource().get('v.value');
    component.set('v.okMsg','');
    component.clearMsg(component);
    component.set("v.errorMsg",'');
    component.set("v.saveerrorMsg",'');
    var rename;
    for(var i = 0;i<res.length;i++) {
      if (res[i].value == re) {
        rename = res[i].name;
        break;
      }
    }
    //component.set('v.sereLabel',rename);
    if (component.get('v.issave') == false) {
      component.set('v.type','changeRecord');
      component.set('v.showAlert',true);
      component.set('v.message',component.get('v.labMap.SB_NC_MAPPING_LABEL_AUSAVE'));
    } else {
      component.set('v.login', true);
      helper.setData(component, rename);
      component.set('v.currentRecordType',re);
    }
  },
  //マッピングItemを削除
  remove : function(component,event,helper) {
    helper.remove(component);
  },
  //マッピングItemを追加
  addItem : function(component,event,helper) {
    helper.addItem(component);
  },
  // デフォルト
  default : function(component,event,helper) {
    component.set('v.type','def');
    component.set('v.showAlert',true);
    component.set('v.message',component.get('v.labMap.SB_NC_MAPPING_MSG_DEFAULT'));
  },
  no: function (component, event, helper) {
    component.find("recordTypeSelect").set("v.value",component.get('v.currentRecordType'));
    component.set('v.showAlert',false);
  },
  yes : function(component,event,helper) {
    component.set('v.okMsg','');
    var type = component.get('v.type');
    if (type == 'def') {
      var re = component.get('v.renkeiTargetObj');
      component.set('v.showAlert',false);
      component.set('v.saveing',true);
      component.set('v.issave',false);
      helper.default(component,re);
    } else if (type == 'changeRecord') {
      component.clearMsg(component);
      var re = component.find("recordTypeSelect").get("v.value");
      var res = component.get('v.recordTypes');
      var rename;
      component.set('v.login', true);
      component.set('v.showAlert',false);
      component.set('v.issave', true);
      for(var i = 0;i<res.length;i++) {
        if (res[i].value == re) {
          rename = res[i].name;
          break;
        }
      }
      helper.setData(component,rename);
    } else if (type == 'clean') {
      component.clearMsg(component);
      component.set('v.showAlert',false);
      component.set('v.saveing', true);
      helper.setData(component,component.get('v.renkeiTargetObj'));
    }
  },
  //タブ切り替え時のリセット操作
  clean1: function(component,event,helper) {
    var mapp = component.get('v.mpp');
    var mppStr = '';
    for (var i = 0;i<mapp.length;i++) {
      var mp = mapp[i].map;
      mppStr += mp.NameCardName + mp.TargetName + mp.IsActive;
    }
    component.set('v.mppBackUp', mppStr);
    component.set('v.showAlert',false);
    component.set('v.login',true);
    component.set("v.errorMsg",'');
    helper.setData(component,component.get('v.renkeiTargetObj'));
  },
  //クリアボタン押下
  clean: function(component,event,helper) {
    component.set('v.type','clean');
    component.set('v.showAlert',true);
    component.set('v.message',component.get('v.labMap.SB_NC_MAPPING_MSG_CLEAN'));
  },
  //変更call
  changese : function(component,event,helper) {
    component.set('v.issave',false);
    component.set('v.needSave',true);
    component.set('v.needSaveSelf',true);
  },
  //保存
  save : function(component,event,helper) {
    component.set('v.okMsg','');
    component.set('v.saveing',true);
    // component.clearnFlage(component);
    helper.save(component,event,false);
  },
  // タブロード開始
  loadingStart : function(component, event, helper) {
    component.set('v.isLoading',true);
  },
  // タブロード停止
  loadingEnd1 : function(component, event, helper) {
    component.set('v.isLoading',false);
  },
  // 表示メッセージを隠す
  hiddenMsg : function(component, event, helper) {
    // component.set('v.errorMsg','');
    component.set('v.okMsg','');
    // component.clearnFlage(component);
  },
  // メッセージ削除
  clearMsg : function(component) {
    component.set('v.errorMsg','');
    component.set('v.obj2MsgList',null);
    component.set('v.namecardMsgList',null);
    component.set('v.warningMsg',null);
    // component.set('v.objectMsg',null);
    // component.set('v.avMessage',null);
  },
  // タブ変更時の画面変更チェック
  checkChange : function(component, event, helper) {
    var mppBackUp = component.get('v.mppBackUp');
    var mapp = component.get('v.mpp');
    var mppStr = '';
    for (var i = 0;i<mapp.length;i++) {
      var mp = mapp[i].map;
      mppStr += mp.NameCardName + mp.TargetName + mp.IsActive;
    }
    component.set('v.needSave',mppBackUp != mppStr);
  },
})