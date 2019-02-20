/**
 *
 *  SB_NCL_DataTable
 *  リード拡張環境 Lightning一括画面のデータを表示するためのコンポネート Controller
 *
 *
 *
 *
 *  Copyright (C) 2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author mao
 *  @Version 拡張パッケージ：Lead Ex. 1.12
 *  @Version 拡張パッケージ：Lead Ex. 1.12 SV_DEV-1161 統合版の一括登録ではtodo登録の一括選択がない
 *
 **/
({
  doInit : function(component, event, helper) {
    var fsMap = component.get('v.fieldMap');

    // var fs = component.get('v.fieldList');
    // for (var i = 0; i < fs.length; i++) {
    //    fsMap(fs[i].fieldName) = {width:null};
    // }
    fsMap.SmartViscaf__company_name__c = {width:null};
    fsMap.SmartViscaf__division__c = {width:null};
    fsMap.SmartViscaf__title_name__c = {width:null};
    fsMap.Name = {width:null};
    fsMap.Address = {width:null};
    fsMap.SmartViscaf__mobile__c = {width:null};
    fsMap.SmartViscaf__email__c = {width:null};
    fsMap.SmartViscaf__address_pref__c = {width:null};
    fsMap.SmartViscaf__company_name__c = {width:null};
    component.set('v.fieldMap', fsMap);

    var fs = JSON.parse(JSON.stringify(component.get('v.fieldList')));
    fs.push({fieldName:'SmartViscaf__company_name__c'});
    fs.push({fieldName:'SmartViscaf__division__c'});
    fs.push({fieldName:'SmartViscaf__title_name__c'});
    fs.push({fieldName:'Name'});
    fs.push({fieldName:'Address'});
    fs.push({fieldName:'SmartViscaf__mobile__c'});
    fs.push({fieldName:'SmartViscaf__email__c'});
    fs.push({fieldName:'SmartViscaf__address_pref__c'});
    component.set('v.fieldList2', fs);
    window.addEventListener('resize', $A.getCallback(function(){
        component.reSetThead(component, event, helper);
    }));
  },
  changeValue : function(component, event, helper) {

  },
  // calculateWidth : function(component, event, helper) {
  //           var childObj = event.target
  //           var parObj = childObj.parentNode;
  //           var count = 1;
  //           while(parObj.tagName != 'TH') {
  //               parObj = parObj.parentNode;
  //               count++;
  //           }
  //           console.log('final tag Name'+parObj.tagName);
  //           var mouseStart=event.clientX;
  //           component.set("v.mouseStart",mouseStart);
  //           component.set("v.oldWidth",parObj.offsetWidth);
  //   },
    // setNewWidth : function(component, event, helper) {
    //         var childObj = event.target
    //         var parObj = childObj.parentNode;
    //         var parObj1;
    //         var count = 1;
    //         while(parObj.tagName != 'TH') {
    //             parObj = parObj.parentNode;
    //             count++;
    //             if (parObj.tagName == 'SPAN') {
    //               parObj1 = parObj;
    //             }
    //         }
    //         var mouseStart = component.get("v.mouseStart");
    //         var oldWidth = component.get("v.oldWidth");
    //         var newWidth = event.clientX- parseFloat(mouseStart)+parseFloat(oldWidth);
    //         if (newWidth >= 100 && newWidth <= 200) {
    //           parObj.style.width = newWidth+'px';
    //           parObj1.style.width = newWidth+'px';
    //         }
    //         console.log('final tag Name'+newWidth);
    // },
    // ヘッダーWidthセット
    reSetThead : function(component, event, helper) {
        var fs = component.get('v.fieldList2');
        for (var i = 0; i < fs.length; i ++) {
            var f = fs[i];
            var d = document.getElementById('dataTableTheadSpan' + f.fieldName);
            if (d != null) {
                var parObj = d.parentNode;
                while(parObj.tagName != 'TH') {
                    parObj = parObj.parentNode;
                }
                d.style.width = parObj.offsetWidth + 'px';
            }
        }
    },
    // イベントキャッチした実行するJS
    doSomething : function(component, event, helper) {
        var name = event.getParam('name');
        var value = event.getParam('value');
        var objs = JSON.parse(JSON.stringify(component.get('v.objs')));
        var objs1 = component.get('v.objs');
        var non;
        for (var i = 0; i < objs.length; i ++) {
            if (objs[i].id == value) {
                var tar = "";
                if (name == 'cleanLeadPlicklist') {
                  objs[i].cObjectMap.Lead.value = 'none';
                  objs1[i].cObjectMap.Lead.value = 'none';
                  tar = 'Lead';
                }
                else if (name == 'cleanContactPlicklist') {
                  objs[i].cObjectMap.Contact.value = 'none';
                  objs1[i].cObjectMap.Contact.value = 'none';
                  tar = 'Contact';
                }
                if (component.get('v.showType') == 'Both') {
                    var options = document.getElementById(i + tar).options;
                    for (var i = 0; i < options.length; i++) {
                        if (options[i].value == 'none') {
                            options[i].selected = true;
                        } else {
                            options[i].selected = false;
                        }
                    }
                }
                break;
            }
        }
        // component.set("v.objs", null);
        // component.set('v.objs', objs);
        component.set('v.objs', objs1);
    },
    // ヘッダー現状記録
    calculateWidth: function(component, event, helper) {
        var childObj = event.target
        var mouseStart=event.clientX;
        component.set("v.currentEle", childObj);
        component.set("v.mouseStart",mouseStart);
        // Stop text selection event so mouse move event works perfectlly.
        if(event.stopPropagation) event.stopPropagation();
        if(event.preventDefault) event.preventDefault();
        event.cancelBubble=true;
        event.returnValue=false;  
    },
    // 最新ヘッダーWidth設定
    setNewWidth: function(component, event, helper) {
        var currentEle = component.get("v.currentEle");
        if( currentEle != null && currentEle.tagName ) {
            var parObj = currentEle;
            while(parObj.parentNode.tagName != 'TH') {
                if( parObj.className == 'slds-resizable__handle')
                    currentEle = parObj;
                parObj = parObj.parentNode;
                count++;
            }
            var count = 1;
            var mouseStart = component.get("v.mouseStart");
            var oldWidth = parObj.offsetWidth;  // Get the width of DIV
            var newWidth = oldWidth + (event.clientX - parseFloat(mouseStart));
            component.set("v.newWidth", newWidth);
            currentEle.style.right = ( oldWidth - newWidth ) +'px';
            component.set("v.currentEle", currentEle);
        }
    },
    // We are setting the width which is just changed by the mouse move event     
    resetColumn: function(component, event, helper) {
        // Get the component which was used for the mouse move
        if( component.get("v.currentEle") !== null ) {
            var newWidth = component.get("v.newWidth"); 
            var currentEle = component.get("v.currentEle").parentNode.parentNode; // Get the DIV
            var parObj = currentEle.parentNode; // Get the TH Element
            parObj.style.width = newWidth+'px';
            currentEle.style.width = newWidth+'px';
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
            else{
              var fs = component.get('v.fieldList');
              for (var i = 0; i < fs.length; i ++) {
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
    selectAll : function(component, event, helper) {
        var objs = component.get('v.objs');
        var field = event.target.id;
        var checked = event.target.checked;
        for (var i = 0; i < objs.length; i ++) {
            objs[i].cObjectMap[field].checked = checked;
        }
        component.set('v.objs', objs);

        for (var i = 0; i < objs.length; i ++) {
            document.getElementById(i + field).checked = checked;
        }
    },
    changeFieldList : function(component, event, helper) {
      var fs = JSON.parse(JSON.stringify(component.get('v.fieldList')));
      fs.push({fieldName:'SmartViscaf__company_name__c'});
      fs.push({fieldName:'SmartViscaf__division__c'});
      fs.push({fieldName:'SmartViscaf__title_name__c'});
      fs.push({fieldName:'Name'});
      fs.push({fieldName:'Address'});
      fs.push({fieldName:'SmartViscaf__mobile__c'});
      fs.push({fieldName:'SmartViscaf__email__c'});
      fs.push({fieldName:'SmartViscaf__address_pref__c'});
      component.set('v.fieldList2', fs);
    }
})