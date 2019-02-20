/**
 *
 *  SB_NCL_RecordTypeConditionModal
 *  リード拡張環境 一括統合用コンポネート Helper
 *
 *
 *
 *
 *  Copyright (C) 2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author mao
 *  @Version 1.12      2017.05.XX SV_DEV-910 [LEX]リードの名刺で更新のLightning版対応
 *
 **/
({
	doInit : function(cmp, event, helper, targetIds) {
		var action = cmp.get('c.getAllData');
    action.setParams(
    {
      "recordIds": targetIds,
      "fieldListStr" : JSON.stringify(cmp.get("v.fieldList"))
    });
    action.setCallback(this,function(response) {
      var state = response.getState();
      if (cmp.isValid() && state === "SUCCESS") {
        var result = JSON.parse(response.getReturnValue());
        if (result.success) {
          cmp.set("v.dataList", result.data);    // 対象の名刺一覧
          cmp.set("v.dataCount", result.data.length);
          var ids = targetIds.split(',');
          cmp.set('v.lookUpId', ids[0]);
          // cmp.set('v.inputV.ownerId', result[0].cObjectMap['OwnerId'].value);
          cmp.set('v.firstLoading', false);
          // var childCmp = cmp.find('bulkRegistComon');
          // childCmp.reSetThead();
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
          var r = cmp.get("v.fieldMap");
          cmp.set("v.fieldList", result[showType]);    // 対象の名刺一覧
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
  setInputValue : function(cmp, event, helper) {
    var action = cmp.get('c.getInputValue');
    action.setCallback(this,function(response) {
      var state = response.getState();
      if (cmp.isValid() && state === "SUCCESS") {
        var result = JSON.parse(response.getReturnValue());
        // if (result.success) {
          cmp.set("v.allSearchConditions", JSON.parse(JSON.stringify(result.searchConditions)));    // 対象の名刺一覧

          var value = cmp.get("v.showPlickListType");
          result.showOverWrite = false;
          result.showRecordType = false;
          for (var i = 0; i < result.InputPlickListValues.length; i ++) {
            if ((value == 'Lead' && (i == 1 || i == 2))
                || (value == 'Contact' && i == 0)
               ) {
              result.InputPlickListValues[i].show = false;
              result.inputRegistOverWritValues[i].show = false;
            }
            else {
              if (i == 0) {
                if (result.InputPlickListValues[i].canShow) {
                  result.InputPlickListValues[i].show = result.leadAuthority.isCreateable;
                }
                result.newSectionLabel = result.labelMap['LeadNew'];
              }
              else if (i == 1) {
                if (result.InputPlickListValues[i].canShow) {
                  result.InputPlickListValues[i].show = result.accountAuthority.isCreateable;
                }
                result.newSectionLabel = result.labelMap['AccountNew'];
              }
              else if (i == 2) {
                if (result.InputPlickListValues[i].canShow) {
                  result.InputPlickListValues[i].show = result.contactAuthority.isCreateable;
                }
                result.newSectionLabel = result.labelMap['BothNew'];
              }
              if (result.inputRegistOverWritValues[i].canShow == true) {
                result.inputRegistOverWritValues[i].show = true;
                result.showOverWrite = true;
              }
              if (result.showRecordType == false) {
                result.showRecordType = result.InputPlickListValues[i].plickListOptions.length > 0 && result.InputPlickListValues[i].canShow;
              }
            }
          }
          var arr = new Array();
          for (var i = 0; i < result.searchConditions.length; i ++) {
            var sc = result.searchConditions[i];
            if (sc.groupName == cmp.get("v.showPlickListType") && sc.disabled != true) {
              arr.push(sc);
            }
          }
          result.searchConditions = arr;
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
  searchLead : function(cmp, event, helper, targetIds) {
    var action = cmp.get('c.searchAllLead');
    action.setParams(
    {
        "nameCardIds" : targetIds,
        "searchType" : cmp.get('v.inputV.searchConditionValue'),
        "searchContactType" : cmp.get('v.inputV.searchConditionValueContact'),
        "searchRecordTypes" : cmp.get('v.inputV.searchRecordTypes')
    });
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