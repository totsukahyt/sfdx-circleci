/**
 *
 *  SmartVisca
 *    SB_NC_CardDetail.js
 *  名刺詳細表示 コンポーネント
 *
 * Copyright (C) 2016 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2016.10.xx
 *
 **/
({
  // 初期化
  doInit : function(cmp, event, helper) {
    var targetId = cmp.get("v.recordId");
    if (!targetId)  {
      return;
    }
    helper.getNamecard(cmp, targetId);
  },

  // JS ロード -> 名刺詳細 取得
  jsLoaded: function(cmp, event, helper) {

    // cmp.set("v.cssloaded", true);
          // $('.div-carusel').slick({
          //   dots: true,
          //   slidesToShow: 1
          // });
  },

})