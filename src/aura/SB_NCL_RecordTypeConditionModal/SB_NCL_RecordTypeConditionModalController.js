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
 *
 **/
({
	myAction : function(component, event, helper) {
		
	},
  // 閉じる
  close : function(component, event, helper) {
    component.set('v.show', false);
  },
  // 保存
  save : function(component, event, helper) {
    var recG = component.get('v.inputV.searchConditionRct.searchConditionRecordTypeOptionGroups');
    var searchRecordTypesMap =  new Map;
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
  }
})