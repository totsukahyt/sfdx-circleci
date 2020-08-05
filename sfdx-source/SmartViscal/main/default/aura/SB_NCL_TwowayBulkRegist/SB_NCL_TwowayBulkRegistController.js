/**
 *
 *  SB_NCL_RecordTypeConditionModal
 *  リード拡張環境 Lightning一括統合データ操作コンポネート Controller
 *
 *
 *
 *
 *  Copyright (C) 2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author mao
 *  @Version 拡張パッケージ：Lead Ex. 1.12      2017.05.XX 初版
 *  @Version 拡張パッケージ：Lead Ex. 2.1  2020.08.03   PRODUCT-379 LEX 統合版登録 一括：会社名の検索方法での検索対応
 *
 **/
({
  doInit : function (cmp, event, helper) {
      var targetIds = cmp.get("v.recordId");
      cmp.set('v.working', true);
      if (targetIds != null) {
        // helper.searchLead(cmp, event, helper, targetIds);
        helper.setFieldList(cmp, event, helper);
        helper.setTitleValue(cmp, event, helper);
        helper.setInputValue(cmp, event, helper);
        // setInputValueのコールバック時に呼ぶよう変更
        // helper.searchAllData(cmp, event, helper, targetIds, true);
      }
      else {
        cmp.set('v.working', false);
      }
    },
    // 検索条件変更JS
    changeSearchCondition : function (cmp, event, helper) {
      // helper.changeSearchCondition(cmp, event, helper);
      cmp.set('v.working', false);
      var targetIds = cmp.get('v.recordId');
      helper.searchAllData(cmp, event, helper, targetIds, false);
    },
    // イベントをキャッチしたJS
    doSomething : function (cmp, event, helper) {
      var name = event.getParam('name');
      if (name == 'close') {
        sforce.one.navigateToURL(cmp.get('v.retUrl'));
        cmp.set('v.working', false);
      }
      else if (name == 'save') {
        cmp.set('v.working', true);
        helper.save(cmp, event, helper);
      }
      else if (name == 'changeCampaign') {
        helper.changeCampaign(cmp, event, helper);
      }
      else if (name == 'cleanCampaign') {
        var inpv = cmp.get("v.inputV");
        inpv.campaignStatusPlick.plickListOptions = null;
        inpv.campaignStatusPlick.selectValue = null;
        cmp.set("v.inputV", inpv);
      }
      else if (name == 'cleanOwner') {
        var inv = cmp.get("v.inputV");
        inv.ownerId = null;
        cmp.set("v.inputV", inv);
      }
      else if (name == 'changeShowType') {
        var value = event.getParam('value');
        cmp.set("v.showPlickListType", value);
        var fieldMap = cmp.get("v.fieldMap");
        var selectMap = cmp.get("v.selectMap");
        var dl = cmp.get("v.dataList");
        // cmp.set("v.fieldList", null);
        // cmp.set("v.dataList", null);
        // cmp.set("v.selectMap", null);
        // cmp.set("v.selectMap", selectMap);
        // cmp.set("v.dataList", dl);
        // $A.get('e.force:refreshView').fire();
        var inputV = cmp.get("v.inputV");
        inputV.showRecordType = false;
        inputV.showOverWrite = false;
        for (var i = 0; i < inputV.InputPlickListValues.length; i ++) {
          if ((value == 'Lead' && (i == 1 || i == 2))
              || (value == 'Contact' && i == 0)
             ) {
            inputV.InputPlickListValues[i].show = false;
            inputV.inputRegistOverWritValues[i].show = false;
          }
          else {
            if (i == 0) {
              if (inputV.InputPlickListValues[i].canShow) {
                inputV.InputPlickListValues[i].show = inputV.leadAuthority.isCreateable;
              }
              if (value == 'Lead') {
                inputV.newSectionLabel = inputV.labelMap['LeadNew'];
              }
            }
            else if (i == 1) {
              if (inputV.InputPlickListValues[i].canShow) {
                inputV.InputPlickListValues[i].show = inputV.accountAuthority.isCreateable;
              }
              if (value == 'Contact') {
                inputV.newSectionLabel = inputV.labelMap['AccountNew'];
              }
            }
            else if (i == 2) {
              if (inputV.InputPlickListValues[i].canShow) {
                inputV.InputPlickListValues[i].show = inputV.contactAuthority.isCreateable;
              }
              if (value == 'Both') {
                inputV.newSectionLabel = inputV.labelMap['BothNew'];
              }
            }
            if (inputV.inputRegistOverWritValues[i].canShow == true) {
              inputV.inputRegistOverWritValues[i].show = true;
              inputV.showOverWrite = true;
            }
            if (inputV.showRecordType == false) {
              inputV.showRecordType = inputV.InputPlickListValues[i].plickListOptions.length > 0 && inputV.InputPlickListValues[i].canShow;
            }
          }
        }

        var scs = cmp.get("v.allSearchConditions");    // 対象の名刺一覧
        var arr = new Array();
        for (var i = 0; i < scs.length; i ++) {
          var sc = scs[i];
          if ((sc.groupName == value && sc.disabled != true) || value == 'Both') {
            arr.push(sc);
          }
        }
        inputV.searchConditions = arr;
        cmp.set("v.inputV", inputV);
        var fieldList = cmp.get("v.fieldList");
        var fieldList2 = fieldMap[value];
        for (var i = 0; i < fieldList.length; i ++) {
          for (var j = 0; j < fieldList2.length; j ++) {
            if (fieldList[i].fieldName == fieldList2[j].fieldName) {
              fieldList2[j].checkAllCheck = fieldList[i].checkAllCheck;
            }
          }
        }
        cmp.set("v.fieldList", fieldList2);
        // $A.get('e.force:refreshView').fire();
      }
    }
})