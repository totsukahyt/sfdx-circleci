/**
 *
 *  SmartVisca
 *    SB_NC_LookupModalHelper.js
 *  何か特定のオブジェクトをルックアップするためのモーダルダイアログ
 *
 *
 * Copyright (C) 2016 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2016.10.xx
 *  @Version 2.5    2020.01.xx SV_DEV-2102 ダイアログを開きなおした際に検索ワード・エラー・結果リストを引き継がないよう修正
 *
 **/
({
  getLookupModalLabels : function(cmp, sobjName) {
    cmp.set("v.working", true);    //
    var action = cmp.get("c.getLookupModalLabels");
    action.setParams({
      "sobjName": sobjName
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (cmp.isValid() && state === "SUCCESS") {
        var result = JSON.parse(response.getReturnValue());
        if (result.success) {
          cmp.set("v.sobjLabel", result.sobjLabel);    //
        }
        else {
          // エラーがあった場合、画面に表示
          cmp.set("v.errorMsg", result.error);
        }
        cmp.set("v.working", false);    //
      }
    });
    $A.enqueueAction(action);
	},

  // SOSL
  search : function(cmp) {
    var searchString = cmp.get("v.searchString");
    if (!searchString || searchString.length < 2 ) {
      cmp.set("v.errorMsg", '');
      cmp.set("v.items", []);
      return;
    }
    cmp.set("v.working", true);    //
    var action = cmp.get("c.searchSObject");
    var req = JSON.stringify({"searchString": searchString,
      "sobjName" : "NameCard__c",
      "fields" : ["Id", "Name", "company_name__c", "division__c", "title_name__c", "address_pref__c", "card_exchange_date__c", "email__c", "list_name__c", "Parent__c", "Owner.Name"],
      "condition" : "delivery_type__c = '2'",
      "orderby" : "card_exchange_date__c",
      "ascend" : false
    });
//  最新の名刺のみ対象にするなら ↓
//       "condition" : "delivery_type__c='2' AND Saishin__c=true",
// <section class="slds-clearfix">
//   <div class="slds-text-color--weak slds-float--left slds-m-left--xx-large slds-m-horizontal--xx-small">
//     <p>*最新の名刺が対象です</p>
//   </div>
// </section>


    action.setParams({
       "req" : req
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (cmp.isValid() && state === "SUCCESS") {
        var result = JSON.parse(response.getReturnValue());
        if (result.success) {
          if (result.objs.length === 0 ) {
            cmp.set("v.errorMsg", $A.get("$Label.c.SB_NC_SEARCH_ERROR_NO_MATCHING"));    //
            cmp.set("v.severity", 'info');    //
          }
          else {
            // 検索結果あり
            // var items = result.objs;
            // // 名前空間名 を取った項目を追加する。
            // items.forEach(function(item) {
            //   var keys = Object.keys(item).filter(function(f) {
            //     return f.toLowerCase().startsWith('smvTest__');
            //   });
            //   keys.forEach(function(k) {
            //     var l = k.replace(/^smvTest__/i, '');
            //     item[l] = item[k];
            //   });
            // });
            //  表示要素にセット
            cmp.set("v.items", result.objs);    //
          }
        }
        else {
          // エラーがあった場合、画面に表示
          cmp.set("v.errorMsg", result.error);
          cmp.set("v.severity", 'error');    //
        }
        cmp.set("v.working", false);    //
      }
    });
    cmp.set("v.errorMsg", '');
    $A.enqueueAction(action);
  },

  // Modal オープンのボタン押下時
  applycss:function(cmp){
    // SV_DEV-2102 検索ワード・エラー・結果リストをクリア
    cmp.set("v.searchString", '');
    cmp.set("v.errorMsg", '');
    cmp.set("v.items", []);

    var cmpTarget = cmp.find('Modalbox');
    var cmpBack = cmp.find('MB-Back');
    $A.util.addClass(cmpTarget, 'slds-fade-in-open');
    $A.util.addClass(cmpBack, 'slds-backdrop_open');
  },

  //　Modal クローズ時
  removecss:function(cmp){
    var cmpTarget = cmp.find('Modalbox');
    var cmpBack = cmp.find('MB-Back');
    $A.util.removeClass(cmpBack,'slds-backdrop_open');
    $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
  },

})