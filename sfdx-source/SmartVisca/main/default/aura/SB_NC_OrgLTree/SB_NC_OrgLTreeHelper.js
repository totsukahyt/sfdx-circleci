/**
 *
 *  SmartVisca
 *    SB_NC_OrgLTreeHelper.js
 *  Lightning Component による 組織ツリー
 *
 * Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2017.11.xx
 *
 **/
({
  // 対象のレコード に合致する候補の名刺を収集
  createOrgTreeItems : function(cmp, targetId, showTitle, maxRecs) {
  // createOrgTreeItems : function(cmp, targetId, showTitle) {
    cmp.set("v.working", true);    //
    var action = cmp.get("c.getOrgTreeItems");
    // 個別の引数にすると、Integer がうまく渡せないので シリアライズ して 文字列を引数にする
    var req = JSON.stringify({
      "targetId": targetId,
      "showTitle" : showTitle,
      "maxRecs" : maxRecs,
    });
    action.setParams({
       "req" : req
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (cmp.isValid() && state === "SUCCESS") {
        var result = response.getReturnValue(); // v2.4 2019.10.xx serializeされてないレスポンスを受るのに変更
        if (result.success) {
          cmp.set("v.items", result.items);    // 対象の名刺一覧
          cmp.set("v.rootLabel", result.rootLabel);    // ルートの名称 会社名
          cmp.set("v.working", false);    //
        }
        else {
          // エラーがあった場合、画面に表示
          cmp.set("v.errorMsg", result.error);
          cmp.set("v.working", false);    //
        }
      }
      else {
        cmp.set("v.errorMsg", "Request failed");
        cmp.set("v.working", false);    //
      }
    });
    $A.enqueueAction(action);
  },

})