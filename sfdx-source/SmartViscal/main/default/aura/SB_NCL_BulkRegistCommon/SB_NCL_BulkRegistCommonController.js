/**
 *
 *  SB_NCL_BulkRegistComon
 *  リード拡張環境 Lightning リードまたは取引先・取引先責任者に登録画面[一括登録画面]を表示入力用の共通コンポネート Controller
 *
 *
 *
 *
 *  Copyright (C) 2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author mao
 *  @Version 拡張パッケージ：Lead Ex. 1.12
 *  @Version 拡張パッケージ：Lead Ex. 2.1  PRODUCT-389 LEX 統合版登録 一括：「設定」の「Cancel」ボタン「×」ボタンを押下した際に変更前の値に戻らない
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
    var seSObjEvent = component.getEvent("leadBulkRegistEvent");
    seSObjEvent.setParams({
          "name" : "close"
      }).fire();
  },
  // 保存ボタンをクリックする際に実行するJS
  save : function(component, event, helper) {
    var seSObjEvent = component.getEvent("leadBulkRegistEvent");
    seSObjEvent.setParams({
          "name" : "save"
      }).fire();
  },
  // レコードタイプ検索条件表示のボタンをクリックする際に実行するJS
  showModal : function(component, event, helper) {
    component.set('v.backupV', JSON.parse(JSON.stringify(component.get('v.inputV'))));
    component.set('v.showModal', true);
  },
  // 候補登録先変更する際に実行するJS
  changeShowType : function(component, event, helper) {
    var seSObjEvent = component.getEvent("leadBulkRegistEvent");
    var va = event.getParam("value");
    var inputv = component.get("v.inputV");
    if (va == 'Both') {
      inputv.campaignLabel = inputv.labelMap.campaignAPILabel + $A.get("$Label.c.SB_NCLD_Label_Campaign_ForLead");
      inputv.campaignStatusPlick.plickListTitle = $A.get("$Label.c.SB_NCLD_Label_CampaignStatus") + $A.get("$Label.c.SB_NCLD_Label_Campaign_ForLead");
    }
    else {
      inputv.campaignLabel =  inputv.labelMap.campaignAPILabel;
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