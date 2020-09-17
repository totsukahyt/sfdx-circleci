/**
 *
 *  SB_NameCard_RenkeiJyokenCell
 *  名刺連携連携条件を列毎に表示するコンポーネント Helper
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
 *
 **/
({
  changevalue : function(component, event) {

    function Reg(reg,str){
      return reg.test(str);
    } 

    var isok = true;
    var type = component.get("v.type");
    var va = event.getSource().get('v.value');

    var ri = component.get('v.reg');
    if(type == 'BOOLEAN' && va != 'true' && va != 'false'){
      isok = false;
      component.set('v.filesError',true);
      component.set('v.filesErrormessage',component.get('v.labMap.SB_NC_MAPPING_MSG_TYPEBOOLEANERROR'));
    }
    else if((type == 'DATE' || type == 'DATETIME' ) && !Reg(/^(?:(?!0000)[0-9]{4}-(?:(?:0[1-9]|1[0-2])-(?:0[1-9]|1[0-9]|2[0-8])|(?:0[13-9]|1[0-2])-(?:29|30)|(?:0[13578]|1[02])-31)|(?:[0-9]{2}(?:0[48]|[2468][048]|[13579][26])|(?:0[48]|[2468][048]|[13579][26])00)-02-29)$/,(va)) && (va != '' && va != null)) {
      isok = false;
      component.set('v.filesError',true);
      component.set('v.filesErrormessage',component.get('v.labMap.SB_NC_MAPPING_MSG_TYPEDATEERROR'));
    } else if (type == 'URL' && !Reg(/^((ht|f)tps?):\/\/[\w\-]+(\.[\w\-]+)+([\w\-\.,@?^=%&:\/~\+#]*[\w\-\@?^=%&\/~\+#])?$/,va) && (va != '' && va != null)) {
      isok = false;
      component.set('v.filesError',true);
      component.set('v.filesErrormessage',component.get('v.labMap.SB_NC_MAPPING_MSG_TYPEURLERROR'));
    } else if (type == 'EMAIL' && !Reg(/^[a-zA-Z0-9_-]+@[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)+$/,va) && (va != '' && va != null)) {
      isok = false;
      component.set('v.filesError',true);
      component.set('v.filesErrormessage',component.get('v.labMap.SB_NC_MAPPING_MSG_TYPEEMAILERROR'));
    } else if (type == 'INTEGER' || type == 'DOUBLE' && (!Reg(/^(\-|\+)?\d+(\.\d+)?$/,va) || (va == '' || va == null))) {
      component.set('v.filesError',true);
      component.set('v.filesErrormessage',component.get('v.labMap.SB_NC_MAPPING_MSG_TYPENUMBERERROR'));
    } else if ((type == 'STRING' || type == 'TEXTAREA') && component.get('v.baseSet.Operator') == 'Matches_the_following_regular_expression') {
      try{
        new RegExp(va);
      }
      catch(e) {
        isok = false;
        component.set('v.filesError',true);
        component.set('v.filesErrormessage',component.get('v.labMap.SB_NC_MAPPING_MSG_REGEXERROR'));
      }
    } else{
      if(component.get('v.baseSet.NameCardName') == 'CreatedDate' && va == '') {
        isok = false;
        component.set('v.filesError',true);
        component.set('v.filesErrormessage',component.get('v.labMap.SB_NC_MAPPING_MSG_CreateDate'));
      } else if (component.get('v.baseSet.NameCardName') == 'LastModifiedDate' && va == '') {
        isok = false;
        component.set('v.filesError',true);
        component.set('v.filesErrormessage',component.get('v.labMap.SB_NC_MAPPING_MSG_LastModifiedDate'));
      }
    }
    if (isok == true) {
      component.set('v.baseSet.Value',va);
      component.set('v.filesError',false);
      component.set('v.isError',false);
    } else {
      component.set('v.filesError',true);
      component.set('v.isError',true);
    }
  }
})