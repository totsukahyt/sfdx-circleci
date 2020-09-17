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
  // 名刺詳細 取得
  getNamecard : function(cmp, targetId) {
    cmp.set("v.working", true);    //
    var action = cmp.get("c.getNamecard");
    action.setParams({
      "targetId": targetId
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (cmp.isValid() && state === "SUCCESS") {
        var result = JSON.parse(response.getReturnValue());
        if (result.success) {
          cmp.set("v.namecard", result.card);    // 対象の名刺
          // Slick 用コード
          // $('.div-carusel').slick({
          //   // lazyLoad: 'ondemand',
          //   dots: true,
          //   slidesToShow: 2,
          //   arrows: true,
          //   prevArrow: '<lightning:buttonIcon  variant="bare"  iconName="utility:chevronleft" />',
          //   responsive: [
          //     {
          //       breakpoint: 768,
          //       settings: {
          //         arrows: true,
          //         centerMode: true,
          //         centerPadding: '40px',
          //         slidesToShow: 2
          //       }
          //     },
          //     {
          //       breakpoint: 480,
          //       settings: {
          //         arrows: true,
          //         centerMode: true,
          //         centerPadding: '40px',
          //         slidesToShow: 1
          //       }
          //     }
          //   ]
          // });
        }
        else {
          // エラーがあった場合、画面に表示
          cmp.set("v.errorMsg", response.getReturnValue().error);
        }
      }
    });
    cmp.set("v.cssloaded", true);
    $A.enqueueAction(action);
  },

})