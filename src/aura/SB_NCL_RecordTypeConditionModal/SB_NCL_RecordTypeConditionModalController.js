/**
 *
 *  SB_NCL_RecordTypeConditionModal
 *  リード拡張環境 一括統合用Modalコンポネート Controller
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
	myAction : function(component, event, helper) {
		
	},
  close : function(component, event, helper) {
    component.set('v.show', false);
  },
  save : function(component, event, helper) {
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
      if (recs == '') {
        recs = rec;
      }
      else {
        recs += ',' + rec;
      }
    }
    component.set('v.inputV.searchConditionRct.searchConditionRecordTypeOptionGroups', recG);
    component.set('v.searchRecordTypes', recs);
    component.set('v.show', false);

    var changeSearchCondition = component.getEvent("changeSearchCondition");
    changeSearchCondition.fire();
  },
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