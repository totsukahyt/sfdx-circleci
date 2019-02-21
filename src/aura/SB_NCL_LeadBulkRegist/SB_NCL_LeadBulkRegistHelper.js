/**
 *
 *  SB_NCL_LeadBulkRegist
 *  リード拡張環境 一括統合用コンポネート Helper
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
          cmp.set('v.firstLoading', false);
          var childCmp = component.find('dataTable');
          childCmp.reSetThead();
        }
        else {
          // エラーがあった場合、画面に表示
          cmp.set("v.errorMsg", result.message);
          cmp.set("v.working", false);    //
          cmp.set("v.showErrorMsg", true);
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
          cmp.set("v.fieldList", result['Lead']);    // 対象の名刺一覧
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
          cmp.set("v.errorMsg", result.message);
          cmp.set("v.working", false);    //
          cmp.set("v.showErrorMsg", true);
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
        "fieldListStr" : JSON.stringify(cmp.get("v.fieldList")),
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
            cmp.set("v.working", false);    //
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
      action.setParams(
      {
        "customObjects": JSON.stringify(cmp.get('v.dataList')),
        "ownerId" : cmp.get('v.inputV.ownerId'),
        "useNameCardOwner" : cmp.get('v.inputV.useNameCardOwner'),
        "campaign" : "",
        "campaignStatus" : "",
        "leadOverwrite" : cmp.get('v.inputV.inputRegistOverWritValues')[0].checked,
        "leadRecordTypeId" : cmp.get('v.inputV.InputPlickListValues')[0].selectValue
      });
      action.setCallback(this,function(response) {
        var state = response.getState();
        if (cmp.isValid() && state === "SUCCESS") {
          cmp.set('v.working', false);
          var result = JSON.parse(response.getReturnValue());
          if (result.success) {
            sforce.one.navigateToURL(cmp.get('v.retUrl'));
            cmp.set('v.working', false);
          }
          else {
            // エラーがあった場合、画面に表示
            cmp.set("v.errorMsg", result.errorMessage);
            cmp.set("v.showErrorMsg", true);
            cmp.set("v.working", false);    //
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