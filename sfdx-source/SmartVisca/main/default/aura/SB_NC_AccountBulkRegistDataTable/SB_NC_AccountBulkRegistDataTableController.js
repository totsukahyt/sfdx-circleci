/**
 *
 *  SB_NC_AccountBulkRegistDataTable
 *  取引先・取引先責任者一括登録のデータを表示するためのコンポーネント Controller
 *
 *
 *  Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author K.Yoshida
 *  @Version 2.2       2019.02.XX SV_DEV-1558 LEX 取引先登録 一括画面をLXパッケージ同様のLC化で追加
 *
 **/
({
  doInit: function (component, event, helper) {
    var fsMap = component.get('v.fieldMap');

    fsMap.company_name__c = { width: null };
    fsMap.division__c = { width: null };
    fsMap.title_name__c = { width: null };
    fsMap.Name = { width: null };
    fsMap.Address = { width: null };
    fsMap.mobile__c = { width: null };
    fsMap.email__c = { width: null };
    fsMap.address_pref__c = { width: null };
    component.set('v.fieldMap', fsMap);

    var fs = JSON.parse(JSON.stringify(component.get('v.fieldList')));
    fs.push({ fieldName: 'company_name__c' });
    fs.push({ fieldName: 'division__c' });
    fs.push({ fieldName: 'title_name__c' });
    fs.push({ fieldName: 'Name' });
    fs.push({ fieldName: 'Address' });
    fs.push({ fieldName: 'mobile__c' });
    fs.push({ fieldName: 'email__c' });
    fs.push({ fieldName: 'address_pref__c' });
    component.set('v.fieldList2', fs);
    window.addEventListener('resize', $A.getCallback(function () {
      component.reSetThead(component, event, helper);
    }));
  },
  changeValue: function (component, event, helper) {

  },
  // ヘッダーWidthセット
  reSetThead: function (component, event, helper) {
    var fs = component.get('v.fieldList2');
    for (var i = 0; i < fs.length; i++) {
      var f = fs[i];
      var d = document.getElementById('dataTableTheadSpan' + f.fieldName);
      if (d != null) {
        var parObj = d.parentNode;
        while (parObj.tagName != 'TH') {
          parObj = parObj.parentNode;
        }
        d.style.width = parObj.offsetWidth + 'px';
      }
    }
  },
  // ヘッダー現状記録
  calculateWidth: function (component, event, helper) {
    var childObj = event.target
    var mouseStart = event.clientX;
    component.set("v.currentEle", childObj);
    component.set("v.mouseStart", mouseStart);
    // Stop text selection event so mouse move event works perfectlly.
    if (event.stopPropagation) event.stopPropagation();
    if (event.preventDefault) event.preventDefault();
    event.cancelBubble = true;
    event.returnValue = false;
  },
  // 最新ヘッダーWidth設定
  setNewWidth: function (component, event, helper) {
    var currentEle = component.get("v.currentEle");
    if (currentEle != null && currentEle.tagName) {
      var parObj = currentEle;
      while (parObj.parentNode.tagName != 'TH') {
        if (parObj.className == 'slds-resizable__handle')
          currentEle = parObj;
        parObj = parObj.parentNode;
        count++;
      }
      var count = 1;
      var mouseStart = component.get("v.mouseStart");
      var oldWidth = parObj.offsetWidth;  // Get the width of DIV
      var newWidth = oldWidth + (event.clientX - parseFloat(mouseStart));
      component.set("v.newWidth", newWidth);
      currentEle.style.right = (oldWidth - newWidth) + 'px';
      component.set("v.currentEle", currentEle);
    }
  },
  // We are setting the width which is just changed by the mouse move event     
  resetColumn: function (component, event, helper) {
    // Get the component which was used for the mouse move
    if (component.get("v.currentEle") !== null) {
      var newWidth = component.get("v.newWidth");
      var currentEle = component.get("v.currentEle").parentNode.parentNode; // Get the DIV
      var parObj = currentEle.parentNode; // Get the TH Element
      parObj.style.width = newWidth + 'px';
      currentEle.style.width = newWidth + 'px';
      console.log(newWidth);
      component.get("v.currentEle").style.right = 0; // Reset the column devided 
      component.set("v.currentEle", null); // Reset null so mouse move doesn't react again
      var idName = currentEle.id.split('dataTableTheadSpan')[1];
      var fs = component.get('v.fieldMap');
      // 固定項目のwidth設定
      if (fs[idName] != null) {
        if (newWidth < 100) {
          fs[idName].width = '100';
        }
        else {
          fs[idName].width = newWidth;
        }
        component.set('v.fieldMap', fs);
      }
      else {
        var fs = component.get('v.fieldList');
        for (var i = 0; i < fs.length; i++) {
          var f = fs[i];
          if (f.fieldName == idName) {
            if (newWidth < 100) {
              f.width = '100';
            }
            else {
              f.width = newWidth;
            }
            component.set('v.fieldList', fs);
            break;
          }
        }
      }
    }
  },
  selectAll: function (component, event, helper) {
    var objs = component.get('v.objs');
    var field = event.target.id;
    var checked = event.target.checked;
    for (var i = 0; i < objs.length; i++) {
      objs[i].cObjectMap[field].checked = checked;
    }
    var fieldList = component.get('v.fieldList');
    for (var i = 0; i < fieldList.length; i++) {
      if (fieldList[i].fieldName == field) {
        fieldList[i].checkAllCheck = checked;
        break;
      }
    }
    component.set('v.fieldList', fieldList);
    component.set('v.objs', objs);
    for (var i = 0; i < objs.length; i++) {
      document.getElementById(i + field).checked = checked;
    }
  },
  changeFieldList: function (component, event, helper) {
    var fs = JSON.parse(JSON.stringify(component.get('v.fieldList')));
    fs.push({ fieldName: 'company_name__c' });
    fs.push({ fieldName: 'division__c' });
    fs.push({ fieldName: 'title_name__c' });
    fs.push({ fieldName: 'Name' });
    fs.push({ fieldName: 'Address' });
    fs.push({ fieldName: 'mobile__c' });
    fs.push({ fieldName: 'email__c' });
    fs.push({ fieldName: 'address_pref__c' });
    component.set('v.fieldList2', fs);
  }
})