/**
 *
 *  SB_NameCard_BasicSetting
 *  SmartVisca設定 Helper
 *
 *
 *
 *
 *  Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author mao
 *  @Version 1.22      2017.07.XX SV_DEV-527 SmartVisca 基本設定の リード対応
 *  @Version 1.22      2018.02.XX SV_DEV-735 基本設定レコードが二つ作成される
 *  @Version 2.4       2019.05.XX SV_DEV-463  名寄せ条件のカスタマイズ 他、諸々機能強化
 *  @Version 2.5       2019.12.XX SV_DEV-2390 Classic SV設定：リード登録時のToDo登録機能に関する設定項目の追加
 *                     2020.03.XX SV_DEV-2497 SV設定：基本設定タブ helperメソッド中の余計な処理で画面操作時にエラーが発生してしまう場合がある
 *
 **/
({
  // 初期データ取得
  doInit : function(component,helper) {
    var action = component.get('c.getSetting');
    action.setCallback(this,function(response) {
      var state = response.getState();
      component.set('v.saveing',false);
      if (state == 'SUCCESS') {
        var res1 = response.getReturnValue();
        var res = JSON.parse(res1);
        // Lastに関する項目はControllerで削除
        var backUpbaseSet = JSON.parse(JSON.stringify(res.data));
        delete backUpbaseSet['LastModifiedByName'];
        delete backUpbaseSet['LastModifiedByDate'];
        delete backUpbaseSet['LastModifiedById'];
        component.set('v.backUpbaseSet',JSON.stringify(backUpbaseSet));
        component.set('v.baseSet',res.data);

        component.set('v.disabledAccountCompareFieldSelect',component.get('v.baseSet.RegistAccountCompareCustomize__c')=='false');
        component.set('v.registAccountCompareFieldList',res.registAccountCompareFieldList);
        component.set('v.disabledLeadCompareFieldSelect',component.get('v.baseSet.RegistLeadCompareCustomize__c')=='false');
        component.set('v.registLeadCompareFieldList',res.registLeadCompareFieldList);

        component.set('v.accRegistRecordTypeList',res.accRegistRecordTypeList);
        component.set('v.conRegistRecordTypeList',res.conRegistRecordTypeList);
        component.set('v.leadRegistRecordTypeList',res.leadRegistRecordTypeList);
        component.set('v.registToDoOwnerList', res.registToDoOwnerList);
        component.set('v.registLeadToDoOwnerList',res.registLeadToDoOwnerList);

        component.set("v.nayoseJyokenAvailableList", res.nayoseJyokenAvailableList);
        component.set("v.nayoseJyokenSelectedList",  res.nayoseJyokenSelectedList);
        component.set("v.nayoseJyokenRequiredList",  res.nayoseJyokenRequiredList);

        component.set('v.inheritValueAvailableList',res.inheritValueAvailableList);
        component.set('v.inheritValueSelectedList',res.inheritValueSelectedList);
        component.set('v.inheritValueRequiredList',res.inheritValueRequiredList);
        component.set('v.backupInherit', res.inheritValueSelectedList.join(';'));

        component.set('v.isTriggerMergeExpandCriteria',res.isTriggerMergeExpandCriteria);

        component.set('v.login',false);
        var loadendevent = component.getEvent("loadingEnd");
        loadendevent.fire();
        if (res.message != null && res.message != '') {
          this.showmessage(component,res.message,'Warning','warningMsg');
        }
      }
      else {
        component.set("v.errorMsg",response.getError()[0].message);
        component.set('v.login',false);
        var loadendevent = component.getEvent("loadingEnd");
        loadendevent.fire();
      }
      component.set('v.labMap',res.labMap);

      component.set('v.isEnableLeadExtention',res.isEnableLeadExtention);
      component.set('v.isEnableLeadExtention21', res.isEnableLeadExtention21);
      component.set('v.showInheritSetting',res.showInheritSetting);


      if (res.data.LastModifiedByName == res.labMap.SB_NC_MAPPING_NOUPDATE) {
        component.set('v.textHidden','');
        component.set('v.urlHidden','ishidden');
      }
      else {
        component.set('v.textHidden','ishidden');
        component.set('v.urlHidden','');
      }
    });
    $A.enqueueAction(action);
  },
  // 保存
  save : function(component, helper) {
    var action = component.get('c.saveSettingcu');
    action.setParams(
        {
            "baseSet"            : component.get('v.baseSet'),
            "inheritSelectedList": component.get('v.inheritValueSelectedList'),
        });
    action.setCallback(this,function(response)
    {
      var state = response.getState();
      if (state == 'SUCCESS') {
        var res1 = response.getReturnValue();
        var res = JSON.parse(res1);
        component.set('v.saveWarningMsg','');
        if (res.state == 'ok') {
          component.set('v.errorMsg','');
          component.set('v.saveWarningMsg','');
          component.set('v.warningMsg',null);
          this.showmessage(component,res.message,'Success','okMsg');
          // component.set('v.needSave',false);

          component.set('v.needSaveSelf',false);
          component.set('v.baseSet',res.data);
          // Lastに関する項目はControllerで削除
          var backUpbaseSet = JSON.parse(JSON.stringify(res.data));
          delete backUpbaseSet['LastModifiedByName'];
          delete backUpbaseSet['LastModifiedByDate'];
          delete backUpbaseSet['LastModifiedById'];
          component.set('v.backUpbaseSet',JSON.stringify(backUpbaseSet));
          var refEvent = component.getEvent("ref");
          refEvent.setParams({
              "lastModefDate" : res.lastTime,
              "lastModifiedByName" : res.lastName,
              "lastModifiedById" : res.lastId
          }).fire();
          component.set('v.login',false);
          if (res.data.LastModifiedByName == component.get('v.labMap.SB_NC_MAPPING_NOUPDATE')) {
            component.set('v.textHidden','');
            component.set('v.urlHidden','ishidden');
          }
          else {
            component.set('v.textHidden','ishidden');
            component.set('v.urlHidden','');
          }
        }
        else {
          if (res.state == 'warning') {
            this.showmessage(component,res.message,'Warning','saveWarningMsg');
          } else {
            this.showmessage(component,res.message,'Error','errorMsg');
          }
          if (res.message == component.get('v.labMap.SB_NC_SETTING_ERROR_OtherSection_Saved')) {
            component.set('v.textHidden','ishidden');
            component.set('v.urlHidden','ishidden');
            component.set('v.showAlert',false);
            helper.doInit(component);
            return;
          }
        }
        component.set('v.login',false);
      }
      else {
        this.showmessage(component,response.getError()[0].message,'Error','errorMsg');
        component.set('v.login',false);
      }
      component.set('v.saveing',false);
    });
    $A.enqueueAction(action);
  },
  // LEXalert表示(共有)
  showmessage : function(component,message,type,type1) {
    if (component.get("v.showStyle") == 'LEX') {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        "title": type+"!",
        "type":type,
        "message": message
      });
      toastEvent.fire();
    }
    else {
      component.set("v." + type1,message);
    }
  },
  validateInputs : function(component) {
    // 「最新の名刺が値を引継ぐ機能を有効化」がONなら未選択はNG
    var ses = component.get('v.inheritValueSelectedList').join(';');
    var saisinn = component.get('v.baseSet.SaishinInheritValues__c');
    if (ses.length <= 0 && saisinn == 'true') {
      component.set('v.login',false);
      component.set('v.saveing',false);
      component.set("v.errorMsg",component.get('v.labMap.SB_NC_MAPPING_Mapping_inherit_ErrorMessage'));
      return false;
    }

    // 取引先名以外と比較するがONなら未選択はNG
    if (component.get('v.baseSet.RegistAccountCompareCustomize__c') == 'true' &&
       !component.get('v.baseSet.RegistAccountCompareField__c') ){
      component.set('v.login',false);
      component.set('v.saveing',false);
      component.set("v.errorMsg",component.get('v.labMap.SB_NC_SETTING_ERROR_Required_RegistAccountCompareField'));
      return false;
    }

    // リード会社名以外と比較するがONなら未選択はNG/OFFなら選択済みはNG
    if (component.get('v.baseSet.RegistLeadCompareCustomize__c') == 'true'  &&
       !component.get('v.baseSet.RegistLeadCompareField__c') ){
      component.set('v.login',false);
      component.set('v.saveing',false);
      component.set("v.errorMsg",component.get('v.labMap.SB_NC_SETTING_ERROR_Required_RegistLeadCompareField'));
      return false;
    }
    return true;
  },
  // 取引先の会社名の比較対象チェックボックス切り替え処理
  changeAccountCompareCustomize : function(component, event, helper) {
    if (component.get('v.baseSet.RegistAccountCompareCustomize__c') == 'true'){
      component.set('v.disabledAccountCompareFieldSelect' ,false);
    }else{
      component.set('v.disabledAccountCompareFieldSelect' ,true);
      component.set('v.baseSet.RegistAccountCompareField__c','');
    }
  },
  // リードの会社名の比較対象チェックボックス切り替え処理
  changeLeadCompareCustomize : function(component, event, helper) {
    if (component.get('v.baseSet.RegistLeadCompareCustomize__c') == 'true'){
      component.set('v.disabledLeadCompareFieldSelect' ,false);
    }else{
      component.set('v.disabledLeadCompareFieldSelect' ,true);
      component.set('v.baseSet.RegistLeadCompareField__c','');
    }
  },
     
})