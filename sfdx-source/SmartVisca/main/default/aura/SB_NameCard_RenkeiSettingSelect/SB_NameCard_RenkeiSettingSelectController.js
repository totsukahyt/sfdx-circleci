/**
 *
 *  SB_NameCard_RenkeiSettingSelect
 *   Selectコンポーネント Controller

 *  Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author mao
 *  @Version 1.20      2017.02.XX
 *  @Version 2.4       2019.05.XX  SV_DEV-1630と合わせてリファクタリングを実施
 *
 **/
({
  doInit1 : function(component, event, helper) {
  },
  selectb : function(component, event, helper) {
    component.set('v.ischange',true);
    helper.selectb(component, event);
  }
})