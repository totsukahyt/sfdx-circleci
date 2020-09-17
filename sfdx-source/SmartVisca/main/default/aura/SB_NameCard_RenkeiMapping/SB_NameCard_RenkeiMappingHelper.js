/**
*
*  SB_NameCard_RenkeiMapping
*   連携マッピングを設定する画面 Helper
*
*   選択された連携先のオブジェクトに応じてマッピング可能な選択肢を表示させます
*
*  Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
*
*  @author mao
*  @Version 1.22      2017.07.XX SV_DEV-527 SmartVisca 基本設定の リード対応
*  @Version 1.22      2018.02.XX SV_DEV-735 基本設定レコードが二つ作成される
*  @Version 2.4       2019.05.XX SV_DEV-1630と合わせてリファクタリングを実施
*                     2019.07.XX SV_DEV-1212 ヘルプテキスト出し分けのためにリード連携拡張パッケージ有無FLG取得処理を追加
*
**/
({
  //topページのレコードタイプを取得
  setRecordType : function(component) {
    var action = component.get('c.getMyMap');
    action.setParams({});
    action.setCallback(this,function(response) {
        var state = response.getState();
        if (state === 'SUCCESS') {
          var res1 = response.getReturnValue();
          var res = JSON.parse(res1);
          var custs = [];
          for (var i = 0 ;i<res.keys.length;i++ ) {
              custs.push({label:res.labelMaps[res.keys[i]], value:res.keys[i],name:res.typeMaps[res.keys[i]]});
          }
          component.set('v.recordLabel',res.typeMaps[res.keys[0]]);
          component.set('v.labMap',res.labMap);
          component.set('v.recordTypes',custs);
          component.set('v.haveRecordTypes',custs.length > 0);
          component.set('v.isEnableLeadExtention',res.isEnableLeadExtention);
          if (custs.length <= 0) {
            component.set("v.errorMsg",component.get('v.labMap.SB_NC_MAPPING_NO_SELECT_RENKEIOBJECT_ERRORMESSAGE'));
          } else {
            component.set('v.currentRecordType', custs[0].value);
          }
          component.set('v.renkeiTargetObj',res.typeMaps[res.keys[0]]);
          if ((res.errorMessage != null && res.errorMessage != '')) {
            component.set('v.objectMsg',res.errorMessage);
          }
          if ((res.avMessage != null && res.avMessage != '')) {
            component.set('v.avMessage',res.avMessage);
          }
          if (res.lastname == res.labMap.SB_NC_MAPPING_NOUPDATE) {
            component.set('v.textHidden','');
            component.set('v.urlHidden','ishidden');
          }
          else {
            component.set('v.textHidden','ishidden');
            component.set('v.urlHidden','');
          }
        } else {
          component.set("v.errorMsg",response.getError()[0].message);
          component.set('v.login',false);
        }
    });
    $A.enqueueAction(action);
  },
  //全てデータを取得
  setData : function(component,re) {
    component.set('v.renkeiTargetObj',re);
    if (re == 'Account') {
        component.set('v.requiredMappingList',component.get('v.requiredAccMappingList'));
    } else if (re == 'Contact') {
        component.set('v.requiredMappingList',component.get('v.requiredConMappingList'));
    } else if (re == 'Lead') {
        component.set('v.requiredMappingList',component.get('v.requiredLeadMappingList'));
    } else {
        component.set('v.requiredMappingList',null);
    }
    var action = component.get('c.getMapping');
    action.setParams({
        "record":re
    });
    action.setCallback(this,function(response) {
      var state = response.getState();
      if (state === 'SUCCESS') {
        var co1 = response.getReturnValue();
        var co = JSON.parse(co1);
        component.set('v.namecardLabel',co.namecardLabel);
        component.set('v.obj2Label',co.obj2Label);
        var namecardDataTypeMap = co.namecardDataTypeMap;
        var custs = [];
        var nameCardTypeList = [];
        //旧い項目エラーメッセージ
        if ((co.namecardMsgList != null && co.namecardMsgList != '') || (co.obj2MsgList != null && co.obj2MsgList != '')) {
          component.set('v.namecardMsgList',co.namecardMsgList);
          component.set('v.obj2MsgList',co.obj2MsgList);
        }

        if (co.warningMsg != null && co.warningMsg != '') {
          component.set('v.warningMsg',co.warningMsg);
        }

        for (var i = 0 ;i<co.namecardLabelKeyList.length;i++ ) {
          custs.push({label:co.namecardLabelNameMap[co.namecardLabelKeyList[i]], value:co.namecardLabelKeyList[i]});
          nameCardTypeList.push({key:co.namecardLabelKeyList[i] , value:namecardDataTypeMap[co.namecardLabelKeyList[i]]});
        }
        var types = co.typeList;
        var dataTypeMap = co.dataTypeMap;
        var nn = co.obj2LabelNameMap;
        var typeList = [];
        var alldate = [];
        for (var i = 0;i<types.length;i++) {
          var obj2 = [];
          try{
                for (var j = 0;j<dataTypeMap[types[i]].length;j++) {
                    obj2.push({label:nn[dataTypeMap[types[i]][j]],value:dataTypeMap[types[i]][j]});
                    alldate.push({label:nn[dataTypeMap[types[i]][j]],api:dataTypeMap[types[i]][j]});
                }
                typeList.push({types : types[i],value : obj2});
              }
              catch(e) {
                  continue;
              }
        }
        var mapp = [];
        var mppStr = '';
        for (var i = 0 ;i<co.mappingList.length;i++) {
          var re = co.mappingList[i];
          mapp.push({map:re,Select:false,removeFlag:false,index : 0,iserror:false,ermsg:''});
          mppStr += re.NameCardName + re.TargetName + re.IsActive;
        }
        component.set('v.mppBackUp', mppStr);
        if (component.get('v.requiredLeadMappingList').length < 1 && co.requiredLeadMappingList.length > 0) {
         component.set('v.requiredMappingList',co.requiredLeadMappingList);
         component.set('v.requiredLeadMappingList',co.requiredLeadMappingList);
        }
        if (component.get('v.requiredConMappingList').length < 1 && co.requiredConMappingList.length > 0) {
         component.set('v.requiredConMappingList',co.requiredConMappingList);
         component.set('v.requiredMappingList',co.requiredConMappingList);
        }
        if (component.get('v.requiredAccMappingList').length < 1 && co.requiredAccMappingList.length > 0) {
         component.set('v.requiredMappingList',co.requiredAccMappingList);
         component.set('v.requiredAccMappingList',co.requiredAccMappingList);
        }
        component.set('v.obj2LabelNameMap',co.obj2LabelNameMap);
        component.set('v.nameCardTypeList1',nameCardTypeList);
        component.set('v.nameCardSelects',custs);
        component.set('v.obj2SelectList',typeList);
        component.set('v.lasttime',co.lasttime);
        component.set('v.lastid',co.lastid);
        component.set('v.nameSpace',co.nameSpace);
        component.set('v.mpp',mapp);
        component.set('v.lastname',co.lastname);
        if (co.lastname == component.get('v.labMap.SB_NC_MAPPING_NOUPDATE')) {
          component.set('v.textHidden','');
          component.set('v.urlHidden','ishidden');
        } else {
          component.set('v.textHidden','ishidden');
          component.set('v.urlHidden','');
        }

        //ログイン動画停止
        component.set('v.login',false);
        component.set('v.saveing',false);
        var loadendevent = component.getEvent("loadingEnd");
        loadendevent.fire();
      } else {
        component.set("v.errorMsg",response.getError()[0].message);
        component.set('v.login',false);
        component.set('v.saveing',false);
        var loadendevent = component.getEvent("loadingEnd");
        loadendevent.fire();
      }
    });
    $A.enqueueAction(action);
  },
   //マッピングItem削除
  remove : function(component) {
    var datas = component.get('v.mpp');
    for (var i = datas.length-1;i>=0;i--) {
      var map = datas[i];
      if (map.removeFlag == true) {
        datas.splice(i,1);
      }
    }
    component.set('v.mpp',datas);
  },
  //マッピングItem追加
  addItem : function(component) {
    var datas = component.get('v.mpp');
    // datas.push({map:{'sobjectType': 'NameCardRenkeiMapping__c', 'TargetName__c':'null','NameCardName__c' : 'null' , 'IsActive__c' : 'false' },Select:false,removefalage:false,index : 0});
    datas.push({map:{'TargetName':'','NameCardName' : '' ,'NameCardLabel' : '','TagetLabel' : '' ,'IsActive' : 'true' },Select:false,removeFlag:false,index : 0,iserror:false,ermsg:''});
    component.set('v.mpp',datas);
  },
  //レコード変更(現在使ってしません)
  changerecord: function(component,re) {

    var res = component.get('v.recordTypes');
    var reid;
    for (var i = 0;i<re.length;i++)
    {
        if (res[i].label == re)
        {
            reid = res[i].value;
            break;
        }
    }
    var action = component.get('c.changerecord');
    action.setParams({
        "relabel" : re,
        "reid" : reid
    });
    action.setCallback(this,function(response) {
      var state = response.getState();
      if (state === 'SUCCESS') {
        var co1 = response.getReturnValue();
        var co = JSON.parse(co1);
        var nn = co.obj2LabelNameMap;
        var types = co.typeList;
        var dataTypeMap = co.dataTypeMap;
        var typeList = [];
        var alldate = [];
        for (var i = 0;i<types.length;i++) {
          var obj2 = [];
          try{
              for (var j = 0;j<dataTypeMap[types[i]].length;j++) {
                obj2.push({label:nn[dataTypeMap[types[i]][j]],value:dataTypeMap[types[i]][j]});
                alldate.push({label:nn[dataTypeMap[types[i]][j]],api:dataTypeMap[types[i]][j]});
              }
              typeList.push({types : types[i],value : obj2});
          }
          catch(e) {
            continue;
          }
        }
        var mapp = [];
        for (var i = 0 ;i<co.mappingList.length;i++) {
          var re = co.mappingList[i];
          mapp.push({map:re,Select:false,removeFlag:false,index : 0,iserror:false,ermsg:''});
        }
        component.set('v.obj2SelectList',typeList);
        component.set('v.obj2LabelNameMap',co.obj2LabelNameMap);
        component.set('v.mpp',mapp);
        component.set('v.lastname',co.lastname);
        component.set('v.lasttime',co.lasttime);
        component.set('v.lastid',co.lastid);
         //ログイン動画停止
        component.set('v.login',false);
        if (co.lastname == component.get('v.labMap.SB_NC_MAPPING_NOUPDATE')) {
          component.set('v.textHidden','');
          component.set('v.urlHidden','ishidden');
        } else {
          component.set('v.textHidden','ishidden');
          component.set('v.urlHidden','');
        }
      }
    });
    $A.enqueueAction(action);
  },
  default  : function(component,re) {
    var res = component.get('v.recordTypes');
    var reid;
    for (var i = 0;i<res.length;i++) {
      if (res[i].name == re) {
          reid = res[i].value;
          break;
      }
    }
    if (reid == null) {
      component.set("v.errorMsg",component.get('v.labMap.SB_NC_MAPPING_NO_SELECT_RENKEIOBJECT_ERRORMESSAGE'));
      component.set('v.login',false);
      component.set('v.saveing',false);
      return;
    }
    component.set('v.requiredMappingList',null);
    var action = component.get('c.changetodefault');
    var remap = component.get("v.obj2LabelNameMap");
    action.setParams({
      "relabel" : re,
      "obj2LabelName" : remap,
      'reid' : reid
    });
    action.setCallback(this,function(response) {
      var state = response.getState();
      if (state === 'SUCCESS') {
        var co1 = response.getReturnValue();
        var co = JSON.parse(co1);
        var mapp = [];
        for (var i = 0 ;i<co.mappingList.length;i++) {
          var re = co.mappingList[i];
          mapp.push({map:{'TargetName':re.TargetName,'NameCardName' : re.NameCardName ,'NameCardLabel' : re.NameCardLabel,'TagetLabel' : re.TagetLabel ,'IsActive' : re.IsActive},Select:false,removeFlag:false,index : 0,iserror:false,ermsg:''});
        }
        component.set('v.mpp',mapp);
        if (co.requiredLeadMappingList.length > 0 || co.ob2api == 'Lead') {
          component.set('v.requiredMappingList',co.requiredLeadMappingList);
          component.set('v.requiredLeadMappingList',co.requiredLeadMappingList);
        }
        if (co.requiredConMappingList.length > 0 && co.ob2api == 'Contact') {
          component.set('v.requiredConMappingList',co.requiredConMappingList);
          component.set('v.requiredMappingList',co.requiredConMappingList);
        }
        if (co.requiredAccMappingList.length > 0 && co.ob2api == 'Account') {
          component.set('v.requiredMappingList',co.requiredAccMappingList);
          component.set('v.requiredAccMappingList',co.requiredAccMappingList);
        }
         //ログイン動画停止
        component.set('v.login',false);
        component.set('v.saveing',false);
        component.set('v.needSave',true);
        component.set('v.needSaveSelf',true);
      } else {
        component.set("v.errorMsg",response.getError()[0].message);
        component.set('v.login',false);
        component.set('v.saveing',false);
      }
    });
    $A.enqueueAction(action);
  },
  save : function(component,event,movepage) {
    var mapp = component.get('v.mpp');
    var action = component.get('c.saveMaps');
    var reco = component.get('v.renkeiTargetObj');
    var res = component.get('v.recordTypes');
    var iser = false;
    var ss = [];
    var ss2 = [];
    var map = {'' : ''};
    var defcodes = component.get('v.requiredMappingList');
    if (defcodes != null) {
      for (var i = 0 ;i<defcodes.length;i++) {
        var la = defcodes[i].TargetName;
        map[la] = la;
      }
    }
    var mppStr = '';
    for (var i = 0;i<mapp.length;i++) {
      var mp = mapp[i].map;
      mppStr += mp.NameCardName + mp.TargetName + mp.IsActive;
      var ta = mp.TargetName;
      if (ta == null || ta == '') {
        iser = true;
        mapp[i].ermsg = component.get('v.labMap.SB_NC_MAPPING_MSG_SELECTMAPPINGERROR');
        mapp[i].iserror = true;
      } else {
        mapp[i].iserror = false;
      }
      if (mapp[i].map.IsActive == 'false') {
      } else if (map[ta] == '' || map[ta] == null) {
          map[ta] = ta;
      } else {
          mapp[i].ermsg = component.get('v.labMap.SB_NC_MAPPING_MSG_SAMEERROR');
          mapp[i].iserror = true;
          iser = true;
      }
      ss2.push(mapp[i]);
      ss.push(mapp[i].map);
    }
    component.set('v.mpp',ss2);

    var reid = '';
    var relabel = '';
    for (var i = 0;i<res.length;i++) {
      if (res[i].name == reco) {
        reid = res[i].value;
        relabel = res[i].label;
        break;
      }
    }

    if (iser == true) {
      component.set("v.errorMsg",component.get('v.labMap.SB_NC_MAPPING_MSG_LINEERROR'));
      if (movepage == false) {
           component.set('v.login',false);
      } else {
          component.set("v.errorMsg",relabel + ' ' + component.get('v.labMap.SB_NC_MAPPING_ChangeRecordTypeError'));
      }
    }

    action.setParams({
      "mapstr" : JSON.stringify(ss),
      "record" : reid,
      "reco" : reco
    });
    action.setCallback(this,function(response) {
      var state = response.getState();

      // refEvent.fire();
      if (state === 'SUCCESS') {
        var co1 = response.getReturnValue();
        var co = JSON.parse(co1);
        component.clearMsg(component);
        if (co.state == 'ng') {
          component.set('v.errorMsg',co.message);
          component.set('v.login',false);
        } else if (co.state == 'saveerror') {
          component.set('v.saveerrorMsg',co.message);
          component.set('v.login',false);
        } else {
          if (component.get("v.showStyle") == 'LEX') {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
              "title": "Success!",
              "type":"success",
              "message": co.message
            });
            toastEvent.fire();
          } else {
            component.set("v.okMsg",co.message);
          }
          component.set('v.mppBackUp', mppStr);
          component.set('v.needSave',false);
          component.set('v.needSaveSelf',false);
          component.set('v.lastname',co.lastName);
          component.set('v.lasttime',co.lastTime);
          var refEvent = component.getEvent("ref");
          refEvent.setParams({
            "lastModefDate" : co.lastTime,
            "lastModifiedByName" : co.lastName,
            "lastModifiedById" : co.lastId
          }).fire();
          component.set('v.lastid',co.lastid);
          component.set('v.issave',true);
          component.set('v.login',false);
          if (co.lastname == component.get('v.labMap.SB_NC_MAPPING_NOUPDATE')) {
            component.set('v.textHidden','');
            component.set('v.urlHidden','ishidden');
          } else {
            component.set('v.textHidden','ishidden');
            component.set('v.urlHidden','');
          }
        }
      } else if (state === 'ERROR') {
        var error = response.getError();
        if (error) {
            if (error[0] && error[0].message) {
              component.set("v.errorMsg",error[0].message);
              component.set('v.login',false);
            }
        } else {
          component.set("v.errorMsg",'UnknowError');
          component.set('v.login',false);
        }
      }
      component.set('v.saveing',false);
    });
    if (iser == false) {
        $A.enqueueAction(action);
    }
    else {
        component.set('v.saveing',false);
    }
  }
})