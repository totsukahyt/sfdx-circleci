/**
 *
 *  SB_NameCard_RenkeiMappingCell
 *   連携マッピングCellComponet Controller
 *
 *  Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @Version 1.20      2017.02.XX
 *  @Version 2.4       2019.05.XX  SV_DEV-1630と合わせてリファクタリングを実施
 *  @Author mao
 **/
({
  // 初期化
  doInit1 : function(component, event, helper) {
    component.set("v.gid",component.getGlobalId());
    if(component.get('v.dis') == true){
      component.set('v.disclass','Ishidden');
      component.set('v.showclass','');
    } else{
      component.set('v.disclass','');
      component.set('v.showclass','Ishidden');
   }
   helper.setright(component, helper);
  },
  // 名刺選択変更
  changeNameCardSelect : function(component, event, helper) {
    component.set("v.iserror",false);
    var updateEvent = component.getEvent("changese");
    updateEvent.fire();
    helper.changenamecardselect(component, event, helper);
  },
 //選択を交換すると
  unsave : function(component, event, helper) {
    component.set("v.iserror",false);
    var ls = event.getSource().get('v.value');
    var les = component.get('v.rightSelects');
    var tar = '';
    for(var i = 0;i<les.length;i++) {
      if(les[i].value == ls) {
        tar = les[i].label;
      }
    }
    component.set('v.mapp.TargetName',ls);
    component.set('v.mapp.TagetLabel',tar);
    var updateEvent = component.getEvent("changese");
    updateEvent.fire();
  },
  // 削除boxクリック
  removeChange : function(component, event, helper) {
     component.set("v.iserror",false);
     var updateEvent = component.getEvent("changese");
     updateEvent.fire();
     component.set("v.removeFlag",event.target.checked);
  },
  // 有効boxクリック
  avtiveChange : function(component, event, helper) {
     component.set("v.iserror",false);
     component.set("v.mapp.IsActive",event.target.checked == true ? 'true' : 'false');
     var updateEvent = component.getEvent("changese");
     updateEvent.fire();
  }
})