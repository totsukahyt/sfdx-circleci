/**
 *
 *  SB_NameCard_RenkeiCheckbox
 *  設定(表示)用CheckBox Controller
 *
 *  Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author mao
 *  @Version 1.20      2017.02.XX
 *  @Version 2.4       2019.05.XX  SV_DEV-1630と合わせてリファクタリングを実施
 *                                 選択されたチェックボックスのIDの返却に対応
 *
 **/
({
    doinit : function(component, event, helper) {
    },
    // クリックすると値変更
    clickbox : function(component, event, helper) {
        component.set("v.needsave",true);
        component.set("v.obj." + event.target.id,event.target.checked == true ? 'true' : 'false');  // FIXME:Boolean型をセットすべき
        var updateEvent = component.getEvent("changeSaveFlag");
        updateEvent.setParam("boxid",component.get("v.boxid"));
        updateEvent.fire();
    }
})