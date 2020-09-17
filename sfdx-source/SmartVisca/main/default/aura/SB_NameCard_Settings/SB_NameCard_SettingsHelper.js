/**
 *
 *  SB_NameCard_Settings
 *   コンポーネントを表示するタブ付きコンポーネント Helper
 *
 *  Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author mao
 *  @Version 1.20      2017.02.XX
 *  @Version 1.20      2017.09.XX SV_DEV-1219 salesforce最新環境での「SmartVisca設定」内タブがまた大文字で表示される
 *  @Version 2.4       2019.06.XX SV_DEV-1634 SmartVisca設定タブの自動連携に関する設定の表示/非表示を切り替えるカスタム設定を作る
 *
 **/
({
  doInitf : function(component) {
    var action = component.get('c.check');
    action.setCallback(this,function(response) {
      var state = response.getState();
      if(state == 'SUCCESS'){
        var res2 = response.getReturnValue();
        var res1 = JSON.parse(res2);
        var res = res1.message;
        if(res != '' && res != null){
          component.set('v.showPage1',true);
        } else if(res == '' || res == null) {
          component.set('v.showPage2',true);
          component.set('v.dispRenkeiSetting',res1.isDispRenkeiSetting);
        }
        component.set('v.message',res);
      }
      component.set('v.loading',false);
    });
    $A.enqueueAction(action);
  }
})