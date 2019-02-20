/**
 *
 *  SB_NCL_DataTable
 *  リード拡張環境 一括統合用DataTable Controller
 *
 *
 *
 *
 *  Copyright (C) 2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author mao
 *  @Version 1.12      2017.05.XX SV_DEV-511 [LEX]リードの名刺で更新のLightning版対応
 *
 **/
({
  doInit : function(component, event, helper) {
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
    reSetThead : function(component, event, helper) {
        var fs = component.get('v.fieldList');
        for (var i = 0; i < fs.length; i ++) {
            var f = fs[i];
            var d = document.getElementById('dataTableTheadSpan' + f.fieldName);
            var parObj = d.parentNode;
            while(parObj.tagName != 'TH') {
                parObj = parObj.parentNode;
            }
            d.style.width = parObj.offsetWidth + 'px';
        }
    },
    doSomething : function(component, event, helper) {
        var name = event.getParam('name');
        var value = event.getParam('value');
        var objs = JSON.parse(JSON.stringify(component.get('v.objs')));
        var non;
        for (var i = 0; i < objs.length; i ++) {
            if (objs[i].id == value) {
                if (name == 'cleanLeadPlicklist') {
                  objs[i].cObjectMap.Lead.value = 'none';
                }
                else if (name == 'cleanContactPlicklist') {
                  objs[i].cObjectMap.Contact.value = 'none';
                }
                break;
            }
        }
        // component.set("v.objs", null);
        component.set('v.objs', objs);
    },
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
                    break;
                }
            }
            component.set('v.fieldList', fs);
        }
    }
})