/**
 *
 *  SB_NameCard_RenkeiMappingCell
 *   連携マッピングCellComponet Helper
 *
 *  Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @Version 1.20      2017.02.XX
 *  @Author mao
 **/
({
  //初期マッピング先項目設定
  setright : function(component, helper){

    var v = component.get('v.rightAllSelects');
    var n = component.get('v.nameCardTypeList2');
    var t = component.get('v.mapp.NameCardName');
    var t2 = component.get('v.mapp.TargetName');
    var nameSpace = component.get('v.nameSpace');
    var isRef = false;
    var type = '';
    for(var i = 0;i<n.length;i++) {
      if (n[i].key == t) {
        type = n[i].value;
      }
    }

    for(var i = 0;i<v.length;i++) {
      if (v[i].types.startsWith('REFERENCE')) {
        for(var j = 0;j<v[i].value.length;j++) {
          if (v[i].value[j].value == t2) {
            isRef = true;
            break;
          }
        }
      }
    }

    var vv = [];
    //選択さた名刺項目がnullではないの場合のみ参照先の項目選択できます
    if (type != null) {
      for(var i = 0; i<v.length;i++) {
        var type2 = v[i].types;
        if(type2 == type || helper.mappingTypeCheck(type, type2, nameSpace, isRef)) {
          for(var j = 0;j<v[i].value.length;j++) {
            var c = v[i].value[j];
            vv.push({value:c.value,label:c.label});
          }
        }
      }
    }
    component.set('v.rightSelects',vv);
  },
  //名刺項目変更マッピング先項目設定
  changenamecardselect : function(component, event, helper) {

    var ls = event.getSource().get('v.value');
    var v = component.get('v.rightAllSelects');
    var n = component.get('v.nameCardTypeList2');
    var nameSpace = component.get('v.nameSpace');
    var type = '';
    for(var i = 0;i<n.length;i++) {
      if(n[i].key == ls) {
              type = n[i].value;
      }
    }
    var vv = [];
    //選択さた名刺項目がnullではないの場合のみ参照先の項目選択できます
    if (type != null) {
      for(var i = 0; i<v.length;i++) {
        var type2 = v[i].types;
        if(type2 == type || helper.mappingTypeCheck(type, type2, nameSpace, false)) {
          for(var j = 0;j<v[i].value.length;j++) {
            var c = v[i].value[j];
            vv.push({value:c.value,label:c.label});
          }
        }
      }
    }
    var les = component.get('v.leftselects');
    var tar = '';
    for(var i = 0;i<les.length;i++) {
      if(les[i].value == ls) {
        tar = les[i].label;
      }
    }
    component.set('v.mapp.NameCardName',ls);
    component.set('v.mapp.NameCardLabel',tar);
    component.set('v.rightSelects',vv);
    if(vv.length > 0){
      component.set('v.mapp.TargetName',vv[0].value);
      component.set('v.mapp.TagetLabel',vv[0].label);
    } else{
      component.set('v.mapp.TargetName','');
      component.set('v.mapp.TagetLabel','');
    }
  },
  unsave : function(component,event) {
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
  },
  //マッピングタイプチェック
  mappingTypeCheck : function (str, str1, nameSpace, isInit, isRef){

    if(str == 'STRING' || str == 'TEXTAREA') {
      if (str1 == 'STRING' || str1 == 'TEXTAREA' || str1 == 'EMAIL' || str1 == 'URL' || str1 == 'ID' || (str1.startsWith('REFERENCE') && isInit == true) || str1 == 'PICKLIST' || str1 == 'PHONE'){
          return true;
      }
      return false
    } else if (str == 'EMAIL' || str == 'PHONE' || str == 'URL' || str == 'PICKLIST') {
      if (str1 == 'STRING' || str1 == 'TEXTAREA'){
          return true;
      }
      return false
    } else if (str == 'ID' && ((str1 == 'REFERENCE' + nameSpace + 'NameCard__c') || (str1 == 'STRING' || str1 == 'TEXTAREA'))) {
      return true;
    }
    return str.startsWith('REFERENCE') && (str1 == 'STRING' || str1 == 'TEXTAREA');
  }
})