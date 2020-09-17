/**
 *
 *  SB_NameCard_BasicSetting
 *  SmartVisca設定 Controller
 *
 *
 *
 *
 *  Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author mao
 *  @Version 1.22      2017.02.XX  SV_DEV-527 SmartVisca 基本設定の リード対応
 *  @Version 1.22      2018.02.XX SV_DEV-735 基本設定レコードが二つ作成される
 *  @Version 2.4       2019.05.XX  SV_DEV-1630と合わせてリファクタリングを実施
 *                     2019.05.XX  SV_DEV-463  名寄せ条件のカスタマイズ 他、諸々機能強化
 *  @Version 2.5       2019.12.XX SV_DEV-2390 Classic SV設定：リード登録時のToDo登録機能に関する設定項目の追加
 *
 **/
({
  //初期化
  doInit : function(component, event, helper) {
    var basicDataMap = component.get('v.baseSet');
    if (basicDataMap != null) {
      var lastModifiedByName = basicDataMap.LastModifiedByName;
      var lastModifiedByDate = basicDataMap.LastModifiedByDate;
      var lastModifiedById = basicDataMap.LastModifiedById;
      delete basicDataMap['LastModifiedByName'];
      delete basicDataMap['LastModifiedByDate'];
      delete basicDataMap['LastModifiedById'];
      var basicData = JSON.stringify(basicDataMap)
      component.set('v.backUpbaseSet', basicData);
    }
    helper.doInit(component,helper);
    component.set('v.textHidden','ishidden');
    component.set('v.urlHidden','ishidden');
    component.set('v.login',true);
    component.set('v.showAlert',false);
  },
  //タブ変更すると保存フラグ更新
  changeTab: function(component, event, helper) {
    //alert('v.needSaveSelf is ' +  component.get('v.needSaveSelf') + '  v.needSave is ' + component.get('v.needSave') );
    var updateEvent = component.getEvent("changeTab");
    updateEvent.fire();
    component.isNeedSave(component);
  },
  // 保存メソッド
  save : function(component, event, helper) {
    var el = component.find('myAuraIdGoesHere');
    $A.util.toggleClass(el,'slds-transition-hide');
    component.set('v.saveing',true);
    component.set('v.okMsg', '');
    if (!helper.validateInputs(component)){
      component.set('v.saveing',false);
      return;
    }
    helper.save(component, helper);
  },
  // クリアメソッド
  clean : function(component, event, helper) {
    component.set("v.warningMsg",'');
    component.set('v.showAlert',true);
    component.set('v.message',component.get('v.labMap.SB_NC_MAPPING_MSG_CLEAN'));
  },
  // alert yesクリック
  yes  : function(component, event, helper) {
    component.set("v.warningMsg",'');
    component.set('v.showAlert',false);
    component.set('v.login',true);
    helper.doInit(component);
  },
  // alert noクリック
  no : function(component, event, helper) {
    component.set('v.showAlert',false);
  },
  //保存フラグ変更
  changeSaveFlag : function(component, event, helper) {
    // component.set('v.needSave',true);
  },
  // ロード開始
  loadingStart : function(component, event, helper) {
    component.set('v.isLoading',true);
  },
  // ロード終了
  loadingEnd1 : function(component, event, helper) {
    component.set('v.isLoading',false);
  },
  // メッセージクリア
  hiddenMsg : function(component, event, helper) {
    // component.set("v.warningMsg",'');
    // component.set('v.errorMsg','');
    component.set('v.okMsg','');
  },

  // ToDo件名変更
  changeTodoSub : function(component, event, helper) {
    component.isNeedSave(component);
    var se = event.target.value;
    component.set('v.baseSet.RegistToDoSubject__c' , se);
  },
  // ToDo件名変更(リード)
  changeLeadTodoSub : function(component, event, helper) {
    component.isNeedSave(component);
    var se = event.target.value;
    component.set('v.baseSet.RegistLeadToDoSubject__c' , se);
  },
  // キャンペーンの状況変更
  changeCampaignStatus : function(component, event, helper) {
    component.isNeedSave(component);
    var se = event.target.value;
    component.set('v.baseSet.RenkeiCampaignStatus__c' , se);
  },
  // htlpmouseover
  showhelpRENKEIACTIVE : function(component, event, helper) {
    document.getElementById('helpRENKEIACTIVE').style.display = 'block';
  },
  // htlpmouseover
  hidhelpRENKEIACTIVE: function(component, event, helper) {
    document.getElementById('helpRENKEIACTIVE').style.display = 'none';
  },
  // htlpmouseover
  showhelpSaishinInherit : function(component, event, helper) {
    document.getElementById('helpSaishinInherit').style.display = 'block';
  },
  // htlpmouseover
  hidhelpSaishinInherit: function(component, event, helper) {
    document.getElementById('helpSaishinInherit').style.display = 'none';
  },
  // 変更必須
  isNeedSave : function(component) {
    // component.set('v.needSave',true);
    component.set('v.needSaveSelf',true);
  },
  // メッセージクリア
  clearnFlage : function(component) {
    component.set('v.errorMsg','');
    component.set('v.saveWarningMsg','');
    component.set('v.warningMsg',null);
  },
  // 保存ウォーニングメッセージクリア
  clearnWarningMsg : function(component) {
    component.set('v.saveWarningMsg','');
  },
  refdata : function(component, event) {
    
  },
  // タブ変更時入力値変更有無確認
  checkChange : function(component, event, helper) {
    var basicDataMap = component.get('v.baseSet');
    if (basicDataMap == null) {
      return;
    }
    var basicDataMap1 = JSON.parse(JSON.stringify(basicDataMap));
    delete basicDataMap1['LastModifiedByName'];
    delete basicDataMap1['LastModifiedByDate'];
    delete basicDataMap1['LastModifiedById'];
    var basicData = JSON.stringify(basicDataMap1)
    var backUpbaseSet = component.get('v.backUpbaseSet');

    component.set('v.needSave',
        backUpbaseSet != basicData 
     || component.get('v.inheritValueSelectedList').join(';') != component.get('v.backupInherit'))
  },
  changeCheckCckbox : function(component, event, helper) {
    var boxid = event.getParam('boxid');
    if ( boxid == 'RegistAccountCompareCustomize__c' ){
      helper.changeAccountCompareCustomize(component, event, helper);
    }else if ( boxid == 'RegistLeadCompareCustomize__c' ){
      helper.changeLeadCompareCustomize(component, event, helper);
    }
  },
  // ヘルプmouseover
  showHelpCommon : function(component, event, helper) {
    document.getElementById(event.target.id + 'Msg').style.display = 'block';
  },
  // ヘルプmouseover
  hideHelpCommon: function(component, event, helper) {
    document.getElementById(event.target.id + 'Msg').style.display = 'none';
  },
  // 検索対象レコードタイプチェックボックス処理
  changeRegistRecordTypeList : function(component, event, helper) {
    var targetObj = event.target.id.substr(8,1);
    var changeItemID = event.target.id.substr(10);
    var typeList;
    var objValue;
    if ( targetObj == 'a' ){
      typeList = 'v.accRegistRecordTypeList';
      objValue = 'v.baseSet.RegistAccountQueryRecordTypeIds__c';
    }else if( targetObj == 'c' ){
      typeList = 'v.conRegistRecordTypeList';
      objValue = 'v.baseSet.RegistContactQueryRecordTypeIds__c';
    }else{
      typeList = 'v.leadRegistRecordTypeList';
      objValue = 'v.baseSet.RegistLeadQueryRecordTypeIds__c';
    }
    
    var list = component.get(typeList);
    var selectedIDs = '';
    for (var i = 0;i<list.length;i++) {
      if ( list[i].value == changeItemID ){
        if ( event.target.checked ){
          list[i].check = 'true';
        }else{
          list[i].check = 'false';
        }
        
      }
      if ( list[i].check == 'true' ){
        if (selectedIDs == '') {
          selectedIDs += list[i].value;
        } else {
          selectedIDs += ';' + list[i].value;
        }
      }
    }
    component.set(typeList,list);
    component.set(objValue,selectedIDs);
  },
  nayoseJyokenListChange: function (component) {
    var currentJoken = component.get('v.nayoseJyokenSelectedList').join(';');
    component.set('v.baseSet.NayoseJyoken__c',currentJoken);
  },
})