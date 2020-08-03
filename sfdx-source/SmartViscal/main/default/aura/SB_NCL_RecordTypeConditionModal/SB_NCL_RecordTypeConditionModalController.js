/**
 *
 *  SB_NCL_RecordTypeConditionModal
 *  リード拡張環境 一括統合画面
 *  検索対象のレコードタイプ選択用のModalウィンドゥ用コンポネート Controller
 *
 *
 *
 *
 *  Copyright (C) 2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author mao
 *  @Version 拡張パッケージ：Lead Ex. 1.12      2017.05.XX 初版
 *  @Version 拡張パッケージ：Lead Ex. 2.1  PRODUCT-389 LEX 統合版登録 一括：「設定」の「Cancel」ボタン「×」ボタンを押下した際に変更前の値に戻らない
 *  @Version 拡張パッケージ：Lead Ex. 2.2  2020.08.03   PRODUCT-379 LEX 統合版登録 一括：会社名の検索方法での検索対応
 *
 **/
({
	changeShowOKButton : function(component, event, helper) {
    var searchGroups = component.get('v.inputV.searchConditionRct.searchConditionRecordTypeOptionGroups');
    var showType = component.get('v.showType');
    var showOkBotton = false;
    for (var i = 0; i < searchGroups.length; i ++) {
      var searchGroup = searchGroups[i];
      var ops = searchGroup.searchConditionplickListOptions;
      if (((searchGroup.titleId != 'Lead' && showType != 'Lead') || searchGroup.titleId == showType || showType == 'Both') && ops.length > 0) {
        showOkBotton = true;
      }
    }
		component.set('v.showOKButton', showOkBotton);
	},
  // 閉じる
  close : function(component, event, helper) {
    var inputV = component.get('v.inputV');
    var backupV = component.get('v.backupV');
    inputV = backupV;
    component.set('v.inputV', inputV);
    component.set('v.show', false);
  },
  // 保存
  save : function(component, event, helper) {
    var recG = component.get('v.inputV.searchConditionRct.searchConditionRecordTypeOptionGroups');
    var searchRecordTypesMap = {};
    var recs = '';
    for (var i = 0; i < recG.length; i ++) {
      var recordTypeList = new Array;
      var recOps = recG[i].searchConditionplickListOptions;
      var rec = '';
      for (var j = 0; j < recOps.length; j ++) {
        if (recOps[j].checked) {
          if (rec == '') {
            rec = recOps[j].value;
          }
          else {
            rec += ',' + recOps[j].value;
          }
          recordTypeList.push(recOps[j].value);
        }
      }
      searchRecordTypesMap[recG[i].titleId] = recordTypeList;
      if (recs == '') {
        recs = rec;
      }
      else {
        recs += ',' + rec;
      }
    }
    // fs.push({fieldName:'Name'});
    component.set('v.inputV.searchConditionRct.searchConditionRecordTypeOptionGroups', recG);
    component.set('v.searchRecordTypes', recs);
    component.set('v.searchRecordTypesMap', searchRecordTypesMap);
    component.set('v.show', false);

    var changeSearchCondition = component.getEvent("changeSearchCondition");
    changeSearchCondition.fire();
  },
  // 検索条件変更
  modalSearchRecordTypeChanged : function(component, event, helper) {
    var name = event.getParam("name");
    if (name == 'modalSearchRecordTypeEvent') {
      var recG = component.get('v.inputV.searchConditionRct.searchConditionRecordTypeOptionGroups');
      var recs = '';
      for (var i = 0; i < recG.length; i ++) {
        var recOps = recG[i].searchConditionplickListOptions;
        var rec = '';
        for (var j = 0; j < recOps.length; j ++) {
          if (recOps[j].checked) {
            if (rec == '') {
              rec = recOps[j].value;
            }
            else {
              rec += ',' + recOps[j].value;
            }
          }
        }
        if (rec == '') {
          for (var j = 0; j < recOps.length; j ++) {
            recOps[j].checked = true;
            if (rec == '') {
              rec = recOps[j].value;
            }
            else {
              rec += ',' + recOps[j].value;
            }
          }
        }
        recG[i].searchConditionplickListOptions = recOps;
        if (recs == '') {
          recs = rec;
        }
        else {
          recs += ',' + rec;
        }
      }
      component.set('v.inputV.searchConditionRct.searchConditionRecordTypeOptionGroups', recG);
    }
  },
  searchConditionAccountCMtcChange : function(component, event, helper) {
    var sel = "";
    var opts = document.getElementsByName("searchConditionAccountCompanyMatcing");
    for (var i = 0; i < opts.length; i++) {
      if (opts[i].checked) {
        sel = opts[i].value;
        break;
      }
    }
    component.set('v.inputV.selectedConditionAccountCMtc', sel);
  },
  searchConditionLeadCMtcChange : function(component, event, helper) {
    var sel = "";
    var opts = document.getElementsByName("searchConditionLeadCompanyMatcing");
    for (var i = 0; i < opts.length; i++) {
      if (opts[i].checked) {
        sel = opts[i].value;
        break;
      }
    }
    component.set('v.inputV.selectedConditionLeadCMtc', sel);
  },
})