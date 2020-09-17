/**
 *
 *  SB_NameCard_RenkeiJyokenCell
 *  名刺連携連携条件を列毎に表示するコンポーネント Controller
 *
 *
 *  Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author mao
 *  @Version 1.20      2017.02.XX
 *  @Version 2.0.2      2018.07.XX SV_DEV-1106 SmartVisca基本設定レコードの一部項目の値が反転して表示される。
 *  @Version 2.1       2018.04.XX  SV_DEV-876   連携設定条件に名刺項目に参照項目が選択できないことを変更
 *  @Version 2.1       2018.04.XX  SV_DEV-885 基本設定、連携条件設定、連携マッピングタブ切り替えの見直し
 *  @Version 2.1       2018.04.XX  SV_DEV-1106 SmartVisca基本設定レコードの一部項目の値が反転して表示される。
 *  @Version 2.4       2019.05.XX  SV_DEV-1630と合わせてリファクタリングを実施
 *
 **/
({
  // 初期化
  doInit2 : function(component, event, helper) {
    component.set("v.filesError",false);
    component.set("v.gid",component.getGlobalId());
    component.set("v.rightSelects",component.get('v.typeCondition')[component.get('v.nameCardMap')[component.get('v.baseSet.NameCardName')]]);
    component.set("v.type",component.get('v.nameCardMap')[component.get('v.baseSet.NameCardName')]);
    component.set("v.timeClass",'ishidden');
    component.set("v.booleanClass",'ishidden');
    component.set("v.doubleClass",'ishidden');
    component.set("v.urlClass",'ishidden');
    component.set("v.emailClass",'ishidden');
    component.set("v.textareaClass",'ishidden');
    component.set("v.textClass",'ishidden');
    var type = component.get('v.nameCardMap')[component.get('v.baseSet.NameCardName')];
    // String.prototype.endwith=function(oString){
    //     var   reg=new   RegExp(oString+"$");
    //     return   reg.test(this);
    // }
    var reg = new   RegExp("__s"+"$");
    var endofs = reg.test(component.get('v.baseSet.NameCardName'));
    if(endofs){
      component.set("v.textClass",'');
      component.set('v.baseSet.Value','');
    }
    else if(type =='DOUBLE')
    {
      component.set("v.number",component.get('v.baseSet.Value'));
      component.set("v.doubleClass",'');
    }
    else if(type=='DATE' || type == 'DATETIME'){
      component.set("v.timeClass",'');
    }
    else if(type=='BOOLEAN'){
      component.set("v.booleanClass",'');
    }
    else if(type=='URL'){
      component.set("v.urlClass",'');
    }
    else if(type=='EMAIL'){
      component.set("v.emailClass",'');
    }
    else if(type=='TEXTAREA'){
      component.set("v.textareaClass",'');
    }
    else{
      component.set("v.textClass",'');
    }
  },
  // 名刺項目変更
  changLeft : function(component, event, helper) {
    component.set("v.timeClass",'ishidden');
    component.set("v.booleanClass",'ishidden');
    component.set("v.doubleClass",'ishidden');
    component.set("v.urlClass",'ishidden');
    component.set("v.emailClass",'ishidden');
    component.set("v.textareaClass",'ishidden');
    component.set("v.textClass",'ishidden');

    var ls = event.getSource().get('v.value');
    var type = component.get('v.nameCardMap')[ls];

    var reg = new   RegExp("__s"+"$");
    var endofs = reg.test(ls);
    if(endofs){
      component.set("v.textClass",'');
      component.set('v.baseSet.Value','');
    }
    else if(type =='DOUBLE' || type == 'INTEGER')
    {
      component.set('v.baseSet.Value','');
      component.set("v.doubleClass",'');
    }
    else if(type=='DATE' || type == 'DATETIME'){
      component.set("v.baseSet.Value",'');
      component.set("v.timeClass",'');
    }
    else if(type=='BOOLEAN'){
      component.set('v.baseSet.Value','true');
      component.set("v.booleanClass",'');
    }
    else if(type=='URL'){
      component.set("v.urlClass",'');
      component.set('v.baseSet.Value','');
    }
    else if(type=='EMAIL'){
      component.set("v.emailClass",'');
      component.set('v.baseSet.Value','');
    }
    else if(type=='TEXTAREA'){
      component.set("v.textareaClass",'');
      component.set('v.baseSet.Value','');
    }
    else{
      component.set("v.textClass",'');
      component.set('v.baseSet.Value','');
    }

    if(ls == 'CreatedDate')
    {
      component.set('v.filesError',true);
      component.set('v.filesErrormessage',component.get('v.labmap.SB_NC_MAPPING_MSG_CreateDate'));
    }
    else if(ls == 'LastModifiedDate'){
      component.set('v.filesError',true);
      component.set('v.filesErrormessage',component.get('v.labmap.SB_NC_MAPPING_MSG_LastModifiedDate'));
    }
    else{
      component.set('v.filesError',false);
    }
    component.set("v.number",'');
    component.set('v.baseSet.NameCardName',ls);
    var rightselests = component.get('v.typeCondition')[component.get('v.nameCardMap')[ls]];

    //現在保存されているの演算子を取得
    var op = component.get('v.baseSet.Operator');
    //変更後演算子前の演算子選択可能フラグ
    var haveop = false;
    if (rightselests != null) {
      for (var i = 0 ;i<rightselests.length;i++ ) {
        //演算子選択可能
        if (rightselests[i].value == op) {
          haveop = true;
          break;
        }
      }
    }
    //前の選択肢が選択できない場合クリア
    if (haveop == false) {
      component.set('v.baseSet.Operator', '');
    }

    component.set("v.rightSelects",rightselests);
    var typ = component.get('v.nameCardMap')[ls];
    if(typ != null && typ != ''){
      component.set("v.type",typ);
      component.set("v.baseSet.NameCardDataType",typ);
    }
    else{
      component.set("v.type",'');
      component.set("v.baseSet.NameCardDataType",'');
    }
    var updateEvent = component.getEvent("changeJyoukenEvent");
    updateEvent.fire();
  },
  // 演算子変更
  changeRight : function(component, event, helper) {
    var rs = event.getSource().get('v.value');
    component.set('v.baseSet.Operator',rs);
    var updateEvent = component.getEvent("changeJyoukenEvent");
    updateEvent.fire();
  },
  // 削除フラグ変更
  removeChange: function(component, event, helper) {
    component.set("v.removeFlag",event.target.checked);
    var updateEvent = component.getEvent("changeJyoukenEvent");
    updateEvent.fire();
  },
  // 与え変更
  changeValue: function(component, event, helper) {
    //helper.changevalue(component, event);
    var updateEvent = component.getEvent("changeJyoukenEvent");
    updateEvent.fire();
  },
  // Booleanタイプ値を設定
  booleanChangeValue: function(component, event, helper) {
    //helper.changevalue(component, event);
    var va = event.getSource().get('v.value');
    component.set('v.baseSet.Value', va);
    var updateEvent = component.getEvent("changeJyoukenEvent");
    updateEvent.fire();
  },
  // 数値変更
  changeNumber : function(component, event, helper) {
    component.set("v.baseSet.Value",''  + component.get('v.number'));
    var updateEvent = component.getEvent("changeJyoukenEvent");
    updateEvent.fire();
  }
})