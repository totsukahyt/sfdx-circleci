/**
 *
 *  SB_NCL_RecordTypeConditionModal
 *  リード拡張環境 Lightning一括統合データ操作コンポネート Helper
 *
 *
 *
 *
 *  Copyright (C) 2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author mao
 *  @Version 拡張パッケージ：Lead Ex. 1.12      2017.05.XX 初版
 *
 **/
({
  // 初期化
   searchAllData : function(cmp, event, helper, targetIds, isInit) {
    var action = cmp.get('c.getAllData');
    action.setParams(
    {
      "recordIds": targetIds,
      "fieldListStr" : JSON.stringify(cmp.get("v.fieldList")),
      "searchType" : cmp.get('v.inputV.searchConditionValue'),
      "searchContactType" : cmp.get('v.inputV.searchConditionValueContact'),
      "recordTypesMapstr" : JSON.stringify(cmp.get('v.inputV.searchRecordTypesMap'))
    });
    action.setCallback(this,function(response) {
      var state = response.getState();
      if (cmp.isValid() && state === "SUCCESS") {
        var result = JSON.parse(response.getReturnValue());
        if (result.success) {
          cmp.set("v.dataCount", result.data.length);
          var ids = targetIds.split(',');
          cmp.set('v.lookUpId', ids[0]);
          // cmp.set('v.inputV.ownerId', result[0].cObjectMap['OwnerId'].value);
          cmp.set("v.dataList", result.data);    // 対象の名刺一覧
          cmp.set('v.firstLoading', false);
          if (isInit) {
            cmp.set("v.showPlickListType", result.otherMessage.showType);
            var r = cmp.get("v.fieldMap");
            // var childCmp = cmp.find('bulkRegistComon');
            // childCmp.reSetThead();
            var value = result.otherMessage.showType;
            var inputV = cmp.get("v.inputV");    // 対象の名刺一覧
            inputV.showOverWrite = false;
            inputV.showRecordType = false;
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
                  inputV.newSectionLabel = inputV.labelMap['LeadNew'];
                }
                else if (i == 1) {
                  if (inputV.InputPlickListValues[i].canShow) {
                    inputV.InputPlickListValues[i].show = inputV.accountAuthority.isCreateable;
                  }
                  inputV.newSectionLabel = inputV.labelMap['AccountNew'];
                }
                else if (i == 2) {
                  if (inputV.InputPlickListValues[i].canShow) {
                    inputV.InputPlickListValues[i].show = inputV.contactAuthority.isCreateable;
                  }
                  inputV.newSectionLabel = inputV.labelMap['BothNew'];
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
            if (value == 'Both') {
              inputV.campaignLabel = $A.get("$Label.c.SB_NCLD_Label_Campaign") + $A.get("$Label.c.SB_NCLD_Label_Campaign_ForLead");
              inputV.campaignStatusPlick.plickListTitle = $A.get("$Label.c.SB_NCLD_Label_CampaignStatus") + $A.get("$Label.c.SB_NCLD_Label_Campaign_ForLead");
            }
            else {
              inputV.campaignLabel = $A.get("$Label.c.SB_NCLD_Label_Campaign");
              inputV.campaignStatusPlick.plickListTitle = $A.get("$Label.c.SB_NCLD_Label_CampaignStatus");
            }
            var arr = new Array();
            for (var i = 0; i < inputV.searchConditions.length; i ++) {
              var sc = inputV.searchConditions[i];
                if ((sc.groupName == value && sc.disabled != true) || value == 'Both') {
                  arr.push(sc);
                }
            }
            inputV.searchConditions = arr;
            cmp.set("v.inputV", inputV);    // 対象の名刺一覧
            cmp.set("v.fieldList", r[result.otherMessage.showType]);    // 対象の名刺一覧
          }
        }
        else {
          // エラーがあった場合、画面に表示
          cmp.set("v.errorMsg", result.message);
          cmp.set("v.working", false);    //
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
        // if (result.success) {
          var showType = cmp.get("v.showPlickListType");
          if (showType == "" || showType == null) {
            showType = "Lead";
            cmp.set("v.showPlickListType", "Lead");
          }
          cmp.set("v.fieldMap", result);
        // }
        // else {
          // エラーがあった場合、画面に表示
          // cmp.set("v.errorMsg", result.error);
          // cmp.set("v.working", false);    //
        // }
      }else {
        alert(response.getError()[0].message);
      }
      cmp.set('v.working', false);
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
        // if (result.success) {
          cmp.set("v.titleV", result);    // 対象の名刺一覧
        // }
        // else {
          // エラーがあった場合、画面に表示
          // cmp.set("v.errorMsg", result.error);
          // cmp.set("v.working", false);    //
        // }
      }else {
        alert(response.getError()[0].message);
      }
      cmp.set('v.working', false);
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
        // if (result.success) {
          cmp.set("v.allSearchConditions", JSON.parse(JSON.stringify(result.searchConditions)));    // 対象の名刺一覧
          cmp.set("v.inputV", result);    // 対象の名刺一覧


        // }
        // else {
          // エラーがあった場合、画面に表示
          // cmp.set("v.errorMsg", result.error);
          // cmp.set("v.working", false);    //
        // }
      }else {
        alert(response.getError()[0].message);
      }
      cmp.set('v.working', false);
    });
    $A.enqueueAction(action);
  },
  // 検索
  searchLead : function(cmp, event, helper, targetIds) {
    var action = cmp.get('c.searchAllLead');
    action.setParams(
    {
        "nameCardIds" : targetIds,
        "searchType" : cmp.get('v.inputV.searchConditionValue'),
        "searchContactType" : cmp.get('v.inputV.searchConditionValueContact'),
        "searchRecordTypesMap" : cmp.get('v.inputV.searchRecordTypesMap')
    });
    if (targetIds == '') {
      return;
    }
    action.setCallback(this,function(response) {
      var state = response.getState();
      if (cmp.isValid() && state === "SUCCESS") {
        var result = JSON.parse(response.getReturnValue());
        if (result.success) {
          cmp.set("v.selectMap", result.data);    // 対象の名刺一覧
          var dl = cmp.get("v.dataList");
          cmp.set("v.dataList", null);
          cmp.set("v.dataList", dl);
        }
        else {
          // エラーがあった場合、画面に表示
          cmp.set("v.errorMsg", result.message)
          cmp.set("v.showErrorMsg", true);
          cmp.set("v.working", false);    //
        }
        if (cmp.get("v.showPlickListType") == ''
          || cmp.get("v.showPlickListType") == null) {
          cmp.set("v.showPlickListType", result.otherMessage.showType); 
        }
      }else {
        alert(response.getError()[0].message);
      }
      cmp.set('v.working', false);
    });
    $A.enqueueAction(action);
  },
  // 検索条件変更
    changeSearchCondition : function(cmp, event, helper) {
      var action = cmp.get("c.getAllData");

      var recordTypes = "";
      var selectList = cmp.get('v.inputV.searchConditionRct.searchConditionRecordTypeOptionGroups.searchConditionplickListOptions');
      for (var i = 0; i < selectList.length; i ++) {
        var selectValue = selectList[i];
        if (selectValue.checked == true) {
          recordTypes += selectValue.value;
        }
      }
      action.setParams(
      {
        "recordIds": targetIds,
        "fieldListStr" : JSON.stringify(cmp.get("v.fieldMap")['Both']),
        "searchType" : cmp.get("v.inputV.searchConditionValue"),
        "searchContactType" : cmp.get('v.inputV.searchConditionValueContact'),
        "recordType" : recordTypes
      });
      action.setCallback(this,function(response) {
        var state = response.getState();
        if (cmp.isValid() && state === "SUCCESS") {
          var result = JSON.parse(response.getReturnValue());
          if (result.success) {
            cmp.set("v.dataList", result.data);    // 対象の名刺一覧
            var ids = targetIds.split(',');
            cmp.set('v.lookUpId', ids[0]);
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
    save : function(cmp, event, helper) {
      var action = cmp.get("c.saveLead");
      var recordTypes = "";
        //       "ownerId" : cmp.get('v.inputV.ownerId'),
        // "accountOwnerId" : cmp.get('v.inputV.accountOwnerId'),
        // "useNameCardOwner" : cmp.get('v.inputV.useNameCardOwner'),
        // "useNameCardAccountOwner" : cmp.get('v.inputV.useNameCardOwner'),
        // "campaign" : "",
        // "campaignStatus" : "",
        // "leadOverwrite" : cmp.get('v.inputV.inputRegistOverWritValues')[0].checked,
        // "leadRecordTypeId" : cmp.get('v.inputV.InputPlickListValues')[0].selectValue,
      action.setParams(
      {
        "customObjects": JSON.stringify(cmp.get('v.dataList')),
        "inputVStr" : JSON.stringify(cmp.get('v.inputV')),
        "registType" : cmp.get('v.showPlickListType')
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
    },
    // キャンペーン変更JS
    changeCampaign : function(cmp, event, helper) {
      var action = cmp.get('c.getCampaignStatus');
      action.setParams(
      {
          "campaignId" : cmp.get("v.inputV.campaignId")
      });
      action.setCallback(this,function(response) {
        var state = response.getState();
        if (cmp.isValid() && state === "SUCCESS") {
          var result = JSON.parse(response.getReturnValue());
          // if (result.success) {
            var inpv = cmp.get("v.inputV");
            var resValue = response.getReturnValue();
            var result = JSON.parse(response.getReturnValue());
            inpv.campaignStatusPlick.plickListOptions = result.plickListOptions;
            inpv.campaignStatusPlick.selectValue = result.selectValue;
            cmp.set("v.inputV", inpv);
          // }
          // else {
            // エラーがあった場合、画面に表示
            // cmp.set("v.errorMsg", result.error);
            // cmp.set("v.working", false);    //
          // }
        }else {
          alert(response.getError()[0].message);
        }
        cmp.set('v.working', false);
      });
      $A.enqueueAction(action);
    }
})