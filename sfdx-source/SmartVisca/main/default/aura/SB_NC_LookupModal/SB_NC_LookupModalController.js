/**
 *
 *  SmartVisca
 *    SB_NC_LookupModal.cmp
 *  何か特定のオブジェクトをルックアップするためのモーダルダイアログ
 *
 *
 * Copyright (C) 2016 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2016.10.xx
 *  @Version 2      2017.03.xx
 *
 **/
({
  doInit : function(cmp, event, helper) {
    var sobjName = cmp.get("v.sobjName");
    if (sobjName) {
      helper.getLookupModalLabels(cmp, sobjName);
    }
  },

  openModal :function(cmp, event, helper) {
    helper.applycss(cmp);
  },

  closeModal :function(cmp, event, helper) {
    helper.removecss(cmp);
  },

  doSearch : function (cmp, event, helper) {
    event.preventDefault();
    // var text = cmp.get("v.searchString");
    // if (text && text.length > 1 ) {
      helper.search(cmp);
    // }
  },

  // 検索文字列を変更
  changeSearhString : function (cmp, event, helper) {
    cmp.set("v.errorMsg", '');
    cmp.set("v.items", []);
    // if (event.getParams("keyCode").keyCode === 13 ) {
    //   var searchString = cmp.get("v.searchString");
    //   if (searchString && searchString.length > 0) {
    //     helper.search(cmp);
    //   }
    // }
  },

  touchItem : function(cmp, event, helper) {
    console.log(event);
    event.currentTarget.getElementsByTagName("input")[0].checked = true;
  },

  //
  selectItem :function(cmp, event, helper){
    var items = cmp.get("v.items");
    if (!items) {
      return;
    }
    var sel = -1;
    var opts = document.getElementsByName("options");   // 2017.03.xx
    for (var i = 0; i < opts.length; i++) {
      if (opts[i].checked) {
        sel = i;
        break;
      }
    }
    if (sel === -1) {
      return;
    }
    console.log("Sel : " + items[sel].Id);
    var selSObjEvent = cmp.getEvent("selSObjEvent");

    // Populate the event with the selected Object Id
    selSObjEvent.setParams({
        "sobjId" : items[sel].Id,
        "sobjName" : items[sel].Name,
        "sobj" : items[sel],
    });

    // Fire the event
    selSObjEvent.fire();

    helper.removecss(cmp);
  },
})