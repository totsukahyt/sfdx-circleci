/**
 *
 *  SB_NameCard_RenkeiSettingSelect
 *   Selectコンポーネント Helper

 *  Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author mao
 *  @Version 1.20      2017.02.XX
 *  @Version 2.4       2019.05.XX  SV_DEV-1630と合わせてリファクタリングを実施
 *
 **/
({
  selectb : function(component, event) {
     var se = event.getSource().get('v.value');
     component.set('v.selectbody',se);
  }
})