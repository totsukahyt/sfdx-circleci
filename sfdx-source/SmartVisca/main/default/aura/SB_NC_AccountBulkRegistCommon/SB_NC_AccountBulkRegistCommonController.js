/**
 *
 *  SB_NC_AccountBulkRegistCommon
 *  取引先・取引先責任者一括登録 データ入力用コンポーネント Controller
 *
 *  Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author K.Yoshida
 *  @Version 2.2  2019.02.XX SV_DEV-1558 LEX 取引先登録 一括画面をLXパッケージ同様のLC化で追加
 *
 **/
({
  doInit : function(component, event, helper) {
  },
  // 検索条件を選択する際に実行するJS
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
  // 名刺リード所有者使用をクリックする際に実行するJS
  changeUseNameCardOwner : function(component, event, helper) {
     component.set("v.inputV.useNameCardOwner", event.target.checked);
  },
  // 名刺取引先責任者所有者使用をクリックする際に実行するJS
  changeUseNameCardOwnerContact : function(component, event, helper) {
     component.set("v.inputV.useNameCardAccountOwner", event.target.checked);
  },
  // 閉じるボタンをクリックする際に実行するJS
  close : function(component, event, helper) {
    var seSObjEvent = component.getEvent("accountBulkRegistEvent");
    seSObjEvent.setParams({
          "name" : "close"
      }).fire();
  },
  // 保存ボタンをクリックする際に実行するJS
  save : function(component, event, helper) {
    var seSObjEvent = component.getEvent("accountBulkRegistEvent");
    seSObjEvent.setParams({
          "name" : "save"
      }).fire();
  },
  // レコードタイプ検索条件表示のボタンをクリックする際に実行するJS
  showModal : function(component, event, helper) {
    component.set('v.backupV', JSON.parse(JSON.stringify(component.get('v.inputV'))));
    component.set('v.showModal', true);
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