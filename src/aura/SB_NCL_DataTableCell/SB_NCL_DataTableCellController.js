/**
 *
 *  SB_NCL_DataTableCell
 *  リード拡張環境 一括統合用DataTable 用Cell Controller
 *
 *
 *
 *
 *  Copyright (C) 2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author mao
 *  @Version 拡張パッケージ：Lead Ex. 1.12
 *
 **/
({
  // 初期化
  doInit : function(component, event, helper) {
    var fieldName = component.get('v.field.fieldName');
    var cObjectMap = component.get('v.cObjectMap');
    component.set('v.value', cObjectMap[fieldName].value);
    component.set('v.label', cObjectMap[fieldName].label);
    component.set('v.checked', cObjectMap[fieldName].checked);
    if (component.get('v.field.type') == 'plicklist') {
      var value = cObjectMap[fieldName].value;
      // if (showPlickListType != '' && showPlickListType != null) {
        var recordId = component.get('v.recordId');
        var selectM = component.get('v.selectMap');
        if (recordId != null && selectM != null) {
          // alert(JSON.stringify(selectM[recordId].plickListOptions));
          var plickOps = selectM[fieldName].plickListOptions;
          if (value == null || value == '') {
            // component.set('v.value', cObjectMap[fieldName].value);

            // if (fieldName == 'Lead') {
            //   if (selectM['Contact'] != null) {
            //     var plickOps1 = selectM['Contact'].plickListOptions;
            //     if (plickOps1[0].value != 'new' && plickOps1[0].value != 'none') {
            //       cObjectMap[fieldName].value = 'none';
            //     }
            //     else {
            //       if (plickOps[0].value == 'new' && plickOps1[0].value == 'new') {
            //         var showType = component.get('v.showType');
            //         if (showType != 'Contact') {
            //           cObjectMap['Contact'].value = 'none';
            //           cObjectMap[fieldName].value = plickOps[0].value;
            //         }
            //         else {
            //           cObjectMap[fieldName].value = 'none';
            //         }
            //       }
            //       else {
            //         cObjectMap[fieldName].value = plickOps[0].value;
            //       }
            //       // cObjectMap[fieldName].value = plickOps[0].value;
            //     }
            //   }
            //   else {
            //     cObjectMap[fieldName].value = plickOps[0].value;
            //   }
            // }
            // else if (fieldName == 'Contact') {
            //   if (selectM['Lead'] != null) {
            //     var plickOps1 = selectM['Lead'].plickListOptions;
            //     if (plickOps1[0].value != 'new' && plickOps1[0].value != 'none'
            //       && (plickOps[0].value == 'new' || plickOps[0].value == 'none')) {
            //       cObjectMap[fieldName].value = 'none';
            //     }
            //     else {
            //       if (plickOps[0].value == 'new' && plickOps1[0].value == 'new') {
            //         var showType = component.get('v.showType');
            //         if (showType == 'Contact') {
            //           cObjectMap['Lead'].value = 'none';
            //           cObjectMap[fieldName].value = plickOps[0].value;
            //         }
            //         else {
            //           cObjectMap[fieldName].value = 'none';
            //         }
            //       }
            //       else {
            //         cObjectMap[fieldName].value = plickOps[0].value;
            //       }
            //       // cObjectMap[fieldName].value = plickOps[0].value;
            //     }
            //   }
            //   else {
            //     cObjectMap[fieldName].value = plickOps[0].value;
            //   }
            // }
            // else {
            //   cObjectMap[fieldName].value = plickOps[0].value;
            // }
            // component.set('v.cObjectMap', cObjectMap);
          }
          else if (selectM[fieldName].plickListValueMap != null && selectM[fieldName].plickListValueMap[value] == null) {
            cObjectMap[fieldName].value = plickOps[0].value;
          }
          // else if () {

          // }
          component.set('v.value', cObjectMap[fieldName].value);
          component.set('v.plickList', plickOps);
        }
      // }
      // else {
      //   cObjectMap[fieldName].value = plickOps[0].value;
      // }
    }
    var gid = component.getGlobalId();
    component.set("v.gid", gid);

  },
  // 画面値変更イベント
  changeValue : function(component, event, helper) {
    // var ls = event.getSource().get('v.value');
    var ls = event.target.value;
    var cObjectMap = component.get('v.cObjectMap');
    var fieldName = component.get('v.field.fieldName');
    cObjectMap[fieldName].value = ls;
    component.set('v.cObjectMap', cObjectMap);
    component.set('v.value', ls);
    var eventName = component.get('v.eventName');
    if (eventName != null && eventName != '') {
      var seSObjEvent = component.getEvent("leadBulkRegistEvent");
      seSObjEvent.setParams({
        "name" : eventName,
        "value" : component.get('v.recordId')
      }).fire();
    }
  },
  // 選択リストを登録しないに設定
  cleanPlickList : function(component, event, helper) {
    var cObjectMap = component.get('v.cObjectMap');
    var fieldName = component.get('v.field.fieldName');
    cObjectMap[fieldName].value = 'none';
    component.set('v.cObjectMap', cObjectMap);
    component.set('v.value', 'none');
  }
})