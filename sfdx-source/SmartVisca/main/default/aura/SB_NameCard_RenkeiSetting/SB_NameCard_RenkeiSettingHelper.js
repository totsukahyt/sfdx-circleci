/**
*
*  SB_NameCard_RenkeiSetting
*   連携基本設定及び更新条件を表示ためのコンポーネント
*   TODO: (DateTimeのチェックはフォーマット属性使い方わからない) Helper
*
*
*  Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
*
*  @author mao
*  @Version 1.22      2017.07.XX SV_DEV-527 SmartVisca 基本設定の リード対応
*  @Version 1.22      2018.02.XX SV_DEV-735 基本設定レコードが二つ作成される
*  @Version 2.0.2      2018.07.XX SV_DEV-1106 SmartVisca基本設定レコードの一部項目の値が反転して表示される。
*  @Version 2.1       2018.04.XX SV_DEV-847 「連携対象の名刺の条件」エラー通知処理のみなし
*  @Version 2.4       2019.05.XX  SV_DEV-1630と合わせてリファクタリングを実施
*
**/
({
  doInit : function(component) {
    //基本
    var action = component.get('c.getAllMap');
    action.setCallback(this, function (response) {
      var status = response.getState();
      if (status == 'SUCCESS') {
        component.set('v.errorMsg','');
        var res1 = response.getReturnValue();
        var res = JSON.parse(res1);
        var adata = res.PardotIgnore;
        var allData = [];
        var allDataStr = '';
        for (var i = 0 ;i<adata.length;i++) {
          allData.push({data:adata[i],removeFlag:false,isError:false,erMsg:'', nameCardError : '', operatorError : ''});
          allDataStr += adata[i].NameCardName + adata[i].Value + adata[i].Operator;
        }
        component.set('v.allDataBackUp', allDataStr);
        component.set('v.labMap',res.labMap);
        component.set('v.namecardLabel',res.namecardLabel);
        var namecardDataTypeMap = res.namecardDataTypeMap;
        var custs = [];
        var nameCardMap = component.get('v.nameCardMap');
        for (var i = 0 ;i<res.namecardLabelKeyList.length;i++ ) {
          var aa = res.namecardLabelKeyList[i];
          custs.push({label:res.namecardLabelNameMap[res.namecardLabelKeyList[i]], value:res.namecardLabelKeyList[i]});
          nameCardMap[res.namecardLabelKeyList[i]] = namecardDataTypeMap[res.namecardLabelKeyList[i]];
        }

        component.set('v.helpText',res.helpText);
        component.set('v.accUpsertRecordType',res.accUpsertRecordType);
        component.set('v.accQueryRecordTypeList', res.accQueryRecordTypeList);
        component.set('v.accQuerySelectedList', res.accQuerySelectedList);
        component.set('v.conUpsertRecordType',res.conUpsertRecordType);
        component.set('v.conQueryRecordTypeList', res.conQueryRecordTypeList);
        component.set('v.conQuerySelectedList', res.conQuerySelectedList);
        component.set('v.leadUpsertRecordType',res.leadUpsertRecordType);
        component.set('v.leadQueryRecordTypeList', res.leadQueryRecordTypeList);
        component.set('v.leadQuerySelectedList', res.leadQuerySelectedList);
        component.set('v.isEnableLeadExtention', res.isEnableLeadExtention);
        component.set('v.isEnableLeadExtention21', res.isEnableLeadExtention21);

        component.set('v.baseSet',res.baseSet);
        // Lastに関する項目は削除
        var backUpbaseSet = JSON.parse(JSON.stringify(res.baseSet));
        delete backUpbaseSet['LastModifiedByName'];
        delete backUpbaseSet['LastModifiedByDate'];
        delete backUpbaseSet['LastModifiedById'];
        component.set('v.backUpbaseSet', JSON.stringify(backUpbaseSet));
        component.set('v.nameCardMap',nameCardMap);
        component.set('v.nameCardSelects',custs);
        component.set('v.typeCondition',res.typeCondition);
        component.set('v.allData',allData);
        component.set('v.baseSetmap',res.mappingSetMap);
        component.set('v.accountList',res.accountListMap);
        component.set('v.warMsg',res.warMsg);
        component.set('v.login',false);
        var loadendevent = component.getEvent("loadingEnd");
        loadendevent.fire();
        component.set('v.disList',res.disList);
        component.set('v.lastName',res.lastName);
        component.set('v.lastTime',res.lastTime);
        component.set('v.lastId',res.lastId);
        component.set('v.campaignMemberStatusOptions',res.campaignMemberStatusOptions);

        //リード自動連携設定制御
        component.set('v.disabledLeadActive',component.get('v.baseSet.RenkeiActive__c')=='true');
        component.set('v.disabledActiveCampaignMember',component.get('v.baseSet.RenkeiActive__c')=='true' && component.get('v.baseSet.RenkeiLeadActive__c')=='true');
        component.set('v.campaignStatusDis' ,component.get('v.baseSet.RenkeiActiveCampaignMember__c') == 'false');
        if (res.baseSet.RenkeiExcludeHojinkaku__c == 'false' && res.baseSet.RenkeiExcludeHojinkakuPartial__c == 'false') {
          component.set('v.allKaKu','true');
        }
        else {
          component.set('v.allKaKu','false');
        }

        if (res.baseSet.RenkeiLeadExcludeHojinkaku__c == 'false' && res.baseSet.RenkeiLeadExcludeHojinkakuPartial__c == 'false') {
          component.set('v.allLeadKaKu','true');
        }
        else {
          component.set('v.allLeadKaKu','false');
        }
        if (res.lastName == res.labMap.SB_NC_MAPPING_NOUPDATE) {
          component.set('v.textHidden','');
          component.set('v.urlHidden','ishidden');
        }
        else {
          component.set('v.textHidden','ishidden');
          component.set('v.urlHidden','');
        }
      } else {
        var error = response.getError();
        component.set('v.errorMsg',error[0].getmessage);
        component.set('v.login',false);
        var loadendevent = component.getEvent("loadingEnd");
        loadendevent.fire();
      }
      component.set('v.saveing',false);
    });
    $A.enqueueAction(action);
  },
  clean : function(component) {
    var action = component.get('c.getAllData');
    action.setCallback(this, function (response) {
      var status = response.getState();
      if (status == 'SUCCESS') {
        var res1 = response.getReturnValue();
        var res = JSON.parse(res1);
        var adata = res;
        var allData = [];
        for (var i = 0 ;i<adata.length;i++) {
          allData.push({data:adata[i],removeFlag:false});
        }
        component.set('v.allData',allData);
        component.set('v.login',false);
        component.set('v.errorMsg','');
      } else {
        var error = response.getError();
        component.set('v.errorMsg',error[0].getmessage);
        component.set('v.login',false);
      }
      component.set('v.saveing',false);
    });
    $A.enqueueAction(action);
  },
  save : function(component, event, helper) {
    var datas = component.get('v.allData');
    var baseSetting = component.get('v.baseSet');
    var haveerror = false;
    var lis = [];
    var tyufuku = [];
    var ss2 = [];

    var typeMap = component.get('v.nameCardMap');


    function Reg(reg,str){
      return reg.test(str);
    }

    var allDataStr = '';
    for (var i=0;i<datas.length;i++)
    {
        var d = datas[i].data;
        var data = datas[i];
        data.isError = false;
        data.erMsg = '';
        data.nameCardError = '';
        data.operatorError = '';
        // lis.push({'Operator__c':d.Operator__c,'Value__c' : d.Value__c,'NameCardName__c' : d.NameCardName__c,'NameCardDataType__c':d.NameCardDataType__c,'aaa':'aaa'});
        lis.push(d);
        allDataStr += d.NameCardName + d.Value + d.Operator;

        // 名刺項目選択されていないの場合エラーメッセージを表示
        // 項目を選択してください
        if (d.NameCardName == '' || d.NameCardName == null || d.NameCardName == 'null') {
          data.isError = true;
          data.nameCardError = $A.get("$Label.c.SB_NC_MAPPING_MSG_No_NameCardField");

        } else if (tyufuku[d.NameCardName] == '' || tyufuku[d.NameCardName] == null) {
            tyufuku[d.NameCardName] = 'a';
        } else {
            data.isError = true;
            data.nameCardError = component.get('v.labMap.SB_NC_MAPPING_MSG_SAMEERRORSET');
        }

        // 演算子を選択されていないの場合エラーメッセージを表示
        // 演算子を入力してください
        if (d.Operator == '' || d.Operator == null) {
            data.isError = true;
            data.operatorError = $A.get("$Label.c.SB_NC_MAPPING_MSG_No_Operator");
        }

        // 項目演算子がエラーある場合valueのチェックはしません
        if (data.isError == false) {

          var type = typeMap[d.NameCardName];
          var va = d.Value;
          if(type == 'BOOLEAN' && va != 'true' && va != 'false'){
            data.isError = true;
            data.erMsg = component.get('v.labMap.SB_NC_MAPPING_MSG_TYPEBOOLEANERROR');
          }
          else if((type == 'DATE' || type == 'DATETIME' ) && !Reg(/^(?:(?!0000)[0-9]{4}-(?:(?:0[1-9]|1[0-2])-(?:0[1-9]|1[0-9]|2[0-8])|(?:0[13-9]|1[0-2])-(?:29|30)|(?:0[13578]|1[02])-31)|(?:[0-9]{2}(?:0[48]|[2468][048]|[13579][26])|(?:0[48]|[2468][048]|[13579][26])00)-02-29)$/,(va)) && (va != '' && va != null)) {
            data.isError = true;
            data.erMsg = component.get('v.labMap.SB_NC_MAPPING_MSG_TYPEDATEERROR');
          } else if (type == 'URL' && (d.Operator == 'Matches_next_character_string' || d.Operator ==  'Does_not_match_next_character_string') && !Reg(/^((ht|f)tps?):\/\/[\w\-]+(\.[\w\-]+)+([\w\-\.,@?^=%&:\/~\+#]*[\w\-\@?^=%&\/~\+#])?$/,va) && (va != '' && va != null)) {
            data.isError = true;
            data.erMsg = component.get('v.labMap.SB_NC_MAPPING_MSG_TYPEURLERROR');
          } else if (type == 'EMAIL' && (d.Operator == 'Matches_next_character_string' || d.Operator ==  'Does_not_match_next_character_string') && !Reg(/^[a-zA-Z0-9_-]+@[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)+$/,va) && (va != '' && va != null)) {
            data.isError = true;
            data.erMsg = component.get('v.labMap.SB_NC_MAPPING_MSG_TYPEEMAILERROR');
          } else if (type == 'INTEGER' || type == 'DOUBLE' && (!Reg(/^(\-|\+)?\d+(\.\d+)?$/,va) || (va == '' || va == null))) {
            data.isError = true;
            if (va == '' || va == null || va == 'null') {
              data.erMsg = component.get('v.labMap.SB_NC_MAPPING_MSG_CANNOTBLANK');
            } else {
              data.erMsg = component.get('v.labMap.SB_NC_MAPPING_MSG_TYPENUMBERERROR');
            }
          } else if ((type == 'STRING' || type == 'TEXTAREA' || type == 'URL' || type == 'EMAIL' || type == 'PHONE') && d.Operator == 'Matches_the_following_regular_expression') {
            try{
              new RegExp(va);
            }
            catch(e) {
              data.isError = true;
              data.erMsg = component.get('v.labMap.SB_NC_MAPPING_MSG_REGEXERROR');
            }
          } else {
            if(d.NameCardName == 'CreatedDate' && va == '') {
              data.isError = true;
              data.erMsg = component.get('v.labMap.SB_NC_MAPPING_MSG_CreateDate');
            } else if (d.NameCardName == 'LastModifiedDate' && va == '') {
              data.isError = true;
              data.erMsg = component.get('v.labMap.SB_NC_MAPPING_MSG_LastModifiedDate');
            }
          }

         if (d.Operator != 'Matches_next_character_string' && d.Operator != 'Does_not_match_next_character_string'
                && (va == '' || va == null) && data.erMsg == '') {
            data.isError = true;
            data.erMsg = component.get('v.labMap.SB_NC_MAPPING_MSG_CANNOTBLANK');
          }
          if (data.isError) {
            haveerror = true;
          }
        } else {
            haveerror = true;
        }

        ss2.push(data);
    }

    component.set('v.allData',ss2);
    if (haveerror == true) {
       component.set('v.errorMsg',component.get('v.labMap.SB_NC_MAPPING_MSG_LINEERROR'));
       component.set('v.login',false);
       component.set('v.saveing',false);
       //component.set('v.allData',ss2);
       return;
    }
    var action = component.get('c.saveSetting');

    action.setParams({
        "settings" : JSON.stringify(lis),
        "base" : baseSetting,
        "jyoukenErrorBreak" : component.get('v.jyoukenErrorBreak')
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      component.set('v.saveWarMsg','');
      if (state == 'SUCCESS') {
        component.set('v.errorMsg','');
        var res1 = response.getReturnValue();
        var data = JSON.parse(res1);

        if (data.state == 'ok') {
          component.set('v.errorMsg','');
          component.set('v.errorMsgs', null);
          component.set('v.warMsg',null);
          if (component.get("v.showStyle") == 'LEX') {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
              "title": "Success!",
              "type":"success",
              "message": data.message
            });
            toastEvent.fire();
          } else {
            component.set("v.okMsg",data.message);
          }
          if (component.get('v.jyoukenErrorBreak') == true) {
            component.set('v.saveing',true);
            helper.clean(component);
          }
          component.set('v.allDataBackUp', allDataStr);
          component.set('v.jyoukenErrorBreak', false);
          component.set('v.needSave',false);
          component.set('v.needSaveSelf',false);
          component.set('v.login',false);
          component.set('v.lastName',data.lastName);
          component.set('v.lastTime',data.lastTime);
          var refEvent = component.getEvent("ref");
          refEvent.setParams({
            "lastModefDate" : data.lastTime,
            "lastModifiedByName" : data.lastName,
            "lastModifiedById" : data.lastId
          }).fire();
          component.set('v.lastId',data.lastId);
          baseSetting.LastModifiedByDate = data.lastTime;
          component.set('v.baseSet', baseSetting);
          // Lastに関する項目は削除
          var backUpbaseSet = JSON.parse(JSON.stringify(baseSetting));
          delete backUpbaseSet['LastModifiedByName'];
          delete backUpbaseSet['LastModifiedByDate'];
          delete backUpbaseSet['LastModifiedById'];
          component.set('v.backUpbaseSet', JSON.stringify(backUpbaseSet));
          if (data.lastName == component.get('v.labMap.SB_NC_MAPPING_NOUPDATE')) {
            component.set('v.textHidden','');
            component.set('v.urlHidden','ishidden');
          } else {
            component.set('v.textHidden','ishidden');
            component.set('v.urlHidden','');
          }
        } else {
          if (data.state == 'warning') {
            component.set('v.saveWarMsg',data.message);
            if (data.message == component.get('v.labMap.SB_NC_SETTING_ERROR_OtherSection_Saved')) {
              component.set('v.showAlert',false);
              // component.set('v.login',true);
              component.set('v.textHidden','ishidden');
              component.set('v.urlHidden','ishidden');
              component.set('v.allKaKu','false');
              component.set('v.allLeadKaKu','false');
              helper.doInit(component);
              return;
            }
          } else if (data.state == 'ngs') {
            component.set('v.errorMsgs',data.messages);
            component.set('v.login',false);
            component.set('v.jyoukenErrorBreak', true);
          }
           else {
            component.set('v.errorMsg',data.message);
            component.set('v.login',false);
            // alert(component.get('v.labMap.SB_NC_SETTING_ERROR_OtherSection_Saved'));
            // alert(data.message == component.get('v.labMap.SB_NC_SETTING_ERROR_OtherSection_Saved'));
          }
        }
        component.set('v.login',false);
      } else {
       var error = response.getError();
       component.set('v.errorMsg',error[0].getmessage);
       component.set('v.login',false);
      }
      component.set('v.saveing',false);
    });

    $A.enqueueAction(action);
  }
})