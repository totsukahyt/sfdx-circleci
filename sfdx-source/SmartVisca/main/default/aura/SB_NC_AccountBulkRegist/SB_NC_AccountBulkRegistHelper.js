/**
 *
 *  SB_NC_AccountBulkRegist
 *  取引先・取引先責任者一括登録コンポーネント Helper
 *
 *  Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author K.Yoshida
 *  @Version 2.2  2019.02.XX SV_DEV-1558 LEX 取引先登録 一括画面をLXパッケージ同様のLC化で追加
 *
 **/
({
  // 検索処理
   searchAllData : function(cmp, event, helper, targetIds, isInit) {
    var action = cmp.get('c.getAllData');
    var searchConditionRecordType = JSON.stringify(cmp.get('v.inputV.searchRecordTypesMap'));
    if (isInit == false) {
      // 検索条件に一切変更がないならばなにもせず離脱
      var searchCondition = JSON.stringify(cmp.get('v.inputV.searchConditionValue'));
      var searchConditionContact = JSON.stringify(cmp.get('v.inputV.searchConditionValueContact'));
      var searchConditionB = JSON.stringify(cmp.get('v.inputVBack.searchConditionValue'));
      var searchConditionContactB = JSON.stringify(cmp.get('v.inputVBack.searchConditionValueContact'));
      var searchConditionRecordTypeB = JSON.stringify(cmp.get('v.inputVBack.searchRecordTypesMap'));
      var selectedConditionCMtc = JSON.stringify(cmp.get('v.inputV.selectedConditionCMtc'));
      var selectedConditionCMtcB = JSON.stringify(cmp.get('v.inputVBack.selectedConditionCMtc'));
      if (searchCondition == searchConditionB
        && searchConditionContact == searchConditionContactB
        && searchConditionRecordType == searchConditionRecordTypeB
        && selectedConditionCMtc == selectedConditionCMtcB) {
        return;
      }
    }
    cmp.set('v.working', true);
    action.setParams(
    {
      "recordIds": targetIds,
      "fieldListStr" : JSON.stringify(cmp.get("v.fieldList")),
      "searchType" : cmp.get('v.inputV.searchConditionValue'),
      "searchContactType" : cmp.get('v.inputV.searchConditionValueContact'),
      "recordTypesMapstr" : searchConditionRecordType,
      "searchConditionCompanyMatcing" : cmp.get('v.inputV.selectedConditionCMtc')
    });
    action.setCallback(this,function(response) {
      var state = response.getState();
      if (cmp.isValid() && state === "SUCCESS") {
        var result = JSON.parse(response.getReturnValue());
        if (result.success) {
          cmp.set("v.dataCount", result.data.length);
          var ids = targetIds.split(',');
          if (isInit == false){
            var dataList = cmp.get("v.dataList");
            for (var i = 0; i < result.data.length; i++) {
               result.data[i].cObjectMap.Lead = dataList[i].cObjectMap.Lead;
               result.data[i].cObjectMap.Contact = dataList[i].cObjectMap.Contact;
               result.data[i].cObjectMap.ToDo = dataList[i].cObjectMap.ToDo;
            }
            cmp.set("v.dataList", result.data);
          }
          else {
            cmp.set("v.dataList", result.data);
          }
          cmp.set('v.firstLoading', false);
          if (isInit) {
            //cmp.set("v.showPickListType", result.otherMessage.showType);
            var fMap = cmp.get("v.fieldMap");
            //var value = result.otherMessage.showType;
            // 上書きの指定セクションの初期化
            var inputV = cmp.get("v.inputV");
            inputV.showOverWrite = false;
            for (var i = 0; i < inputV.inputRegistOverWritValues.length; i ++) {
              if (inputV.inputRegistOverWritValues[i].canShow == true) {
                inputV.inputRegistOverWritValues[i].show = true;
                inputV.showOverWrite = true;
              }
            }
            var arr = new Array();
            for (var i = 0; i < inputV.searchConditions.length; i ++) {
              var sc = inputV.searchConditions[i];
                //if ((sc.groupName == value && sc.disabled != true) || value == 'Both') {
                //  arr.push(sc);
                //}
                arr.push(sc);
            }
            inputV.searchConditions = arr;
            cmp.set("v.inputV", inputV);
            //cmp.set("v.fieldList", fMap[result.otherMessage.showType]);    // DataTable表示するもの
            cmp.set("v.fieldList", fMap['Contact']); 
          }
          cmp.set("v.inputVBack", JSON.parse(JSON.stringify(cmp.get('v.inputV'))));
        }
        else {
          // エラーがあった場合、画面に表示
          cmp.set("v.errorMsg", result.message);
          cmp.set("v.showErrorMsg", true);
          cmp.set("v.working", false);    //
          // 初期の検索エラー
          if (isInit == true) {
            cmp.set("v.searchError", true);
          }
          var inputV = cmp.get("v.inputV");
          var inputVBack = cmp.get("v.inputVBack");
          inputV.searchRecordTypesMap = inputVBack.searchRecordTypesMap;
          inputV.searchConditionValue = inputVBack.searchConditionValue;
          inputV.searchConditionValueContact = inputVBack.searchConditionValueContact;
          cmp.set("v.inputV", inputV);
        }
      }else {
        alert(response.getError()[0].message);
      }
      cmp.set('v.working', false);
    });
    $A.enqueueAction(action);
  },
  // 表示項目リストを取得
  setFieldList : function(cmp, event, helper) {
    var action = cmp.get('c.getFieldList');
    action.setCallback(this,function(response) {
          var state = response.getState();
      if (cmp.isValid() && state === "SUCCESS") {
        var result = JSON.parse(response.getReturnValue());
        cmp.set("v.fieldMap", result);
      }else {
        alert(response.getError()[0].message);
        cmp.set('v.working', false);
      }
    });
    $A.enqueueAction(action);
  },
  // タイトルに関する内容を取得
  setTitleValue : function(cmp, event, helper) {
    var action = cmp.get('c.getTitleValue');
    action.setCallback(this,function(response) {
          var state = response.getState();
      if (cmp.isValid() && state === "SUCCESS") {
        var result = JSON.parse(response.getReturnValue());
          cmp.set("v.titleV", result);
      }else {
        alert(response.getError()[0].message);
        cmp.set('v.working', false);
      }
    });
    $A.enqueueAction(action);
  },
  // 画面入力に関する内容を取得
  setInputValue : function(cmp, event, helper) {
    var action = cmp.get('c.getInputValue');
    action.setCallback(this,function(response) {
      var state = response.getState();
      if (cmp.isValid() && state === "SUCCESS") {
        var result = JSON.parse(response.getReturnValue());
        cmp.set("v.inputV", result);
        var targetIds = cmp.get("v.recordId");
        helper.searchAllData(cmp, event, helper, targetIds, true);
      }else {
        alert(response.getError()[0].message);
        cmp.set('v.working', false);
      }
    });
    $A.enqueueAction(action);
  },
  // 検索条件変更
  changeSearchCondition : function(cmp, event, helper) {
    var action = cmp.get("c.getAllData");

    var recordTypes = "";
    var selectList = cmp.get('v.inputV.searchConditionRct.searchConditionRecordTypeOptionGroups.searchConditionpickListOptions');
    for (var i = 0; i < selectList.length; i ++) {
      var selectValue = selectList[i];
      if (selectValue.checked == true) {
        recordTypes += selectValue.value;
      }
    }
    action.setParams(
    {
      "recordIds": targetIds,
      "fieldListStr" : JSON.stringify(cmp.get("v.fieldMap")['Contact']),
      "searchType" : cmp.get("v.inputV.searchConditionValue"),
      "searchContactType" : cmp.get('v.inputV.searchConditionValueContact'),
      "recordType" : recordTypes,
      "searchConditionCompanyMatcing" : cmp.get('v.inputV.selectedConditionCMtc')
    });
    action.setCallback(this,function(response) {
      var state = response.getState();
      if (cmp.isValid() && state === "SUCCESS") {
        var result = JSON.parse(response.getReturnValue());
        if (result.success) {
          cmp.set("v.dataList", result.data);
        }
        else {
          // エラーがあった場合、画面に表示
          cmp.set("v.errorMsg", result.message);
          cmp.set("v.showErrorMsg", true);
        }
      }else {
        alert(response.getError()[0].message);
      }
      cmp.set('v.working', false);
    });
    $A.enqueueAction(action);
  },
  // 保存
  save : function(cmp, event, helper) {
      var action = cmp.get("c.saveRecord");
      var recordTypes = "";
      action.setParams(
      {
        "customObjects": JSON.stringify(cmp.get('v.dataList')),
        "inputVStr" : JSON.stringify(cmp.get('v.inputV'))
      });
      action.setCallback(this,function(response) {
        var state = response.getState();
        if (cmp.isValid() && state === "SUCCESS") {
          cmp.set('v.working', false);
          var result = JSON.parse(response.getReturnValue());
          if (result.success) {
            sforce.one.navigateToURL(cmp.get('v.retUrl'));
            // cmp.set('v.working', false);
            // cmp.set("v.dataList", result.data);    //
            // cmp.set("v.dataHasError", result.dataError);    //
          }
          else {
            // エラーがあった場合、画面に表示
            cmp.set("v.errorMsg", result.errorMessage);
            cmp.set("v.showErrorMsg", true);
            cmp.set("v.working", false);    //
            cmp.set("v.dataList", result.data);    //
            cmp.set("v.dataHasError", result.dataError);    //
          }
        }else {
          alert(response.getError()[0].message);
        }
        cmp.set('v.working', false);
      });
      $A.enqueueAction(action);
    }
})