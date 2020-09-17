/**
*
*  SB_NameCard_RenkeiSetting
*   連携基本設定及び更新条件を表示ためのコンポーネント
*   TODO: (DateTimeのチェックはフォーマット属性使い方わからない) Controller
*
*
*  Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
*
*  @author mao
*  @Version 1.22      2017.07.XX SV_DEV-527 SmartVisca 基本設定の リード対応
*  @Version 1.22      2018.02.XX SV_DEV-735 基本設定レコードが二つ作成される
*  @Version 2.0.2     2018.07.XX SV_DEV-1106 SmartVisca基本設定レコードの一部項目の値が反転して表示される。
*  @Version 2.4       2019.05.XX SV_DEV-1630と合わせてリファクタリングを実施
*
**/
({
  //初期化
  doInit : function(component, event, helper) {
    component.set('v.showAlert',false);
    component.set('v.login',true);
    component.set('v.textHidden','ishidden');
    component.set('v.urlHidden','ishidden');
    component.set('v.allKaKu','false');
    component.set('v.allLeadKaKu','false');
    helper.doInit(component);
  },
  // #Todo 使わないため削除べき?checkboxコンポーネントを作成した
  clickavtive: function(component, event, helper) {
    component.set("v.baseSet." + event.target.id,event.target.checked);
  },
  // 行追加
  addItem: function(component, event, helper) {
    // component.clearnFlage(component);
    var allData = component.get('v.allData');
    allData.push({data:{'Operator':'','Value' : '','NameCardName' : '','NameCardDataType':''},removeFlag:false,isError:false,erMsg:''});
    component.set('v.allData',allData);
  },
  // クリア
  clean : function(component, event, helper) {
      // component.clearnFlage(component);
      component.set('v.type','clean');
      component.set('v.message',component.get('v.labMap.SB_NC_MAPPING_MSG_CLEAN'));
      component.set('v.showAlert',true);
  },
  // タブ変更によるクリア
  clean1 : function(component, event, helper) {
      var basicDataMap = component.get('v.baseSet');
      if (basicDataMap != null) {
        var lastModifiedByName = basicDataMap.LastModifiedByName;
        var lastModifiedByDate = basicDataMap.LastModifiedByDate;
        var lastModifiedById = basicDataMap.LastModifiedById;
        delete basicDataMap['LastModifiedByName'];
        delete basicDataMap['LastModifiedByDate'];
        delete basicDataMap['LastModifiedById'];
        var basicData = JSON.stringify(basicDataMap)
        component.set('v.backUpbaseSet', basicData);
        component.set('v.nameCardAPIMapSeBackUp', JSON.stringify(component.get('v.nameCardAPIMapSe')));
      }

      var datas = component.get('v.allData');
      var allDataStr = '';
      for (var i=0;i<datas.length;i++) {
        var d = datas[i].data;
        allDataStr += d.NameCardName + d.Value + d.Operator;
      }
      component.set('v.allDataBackUp', allDataStr);
      component.set('v.showAlert',false);
      // component.clearnFlage(component);
      component.set('v.login',true);
      helper.doInit(component);
  },
  // Alert Yes
  yes : function(component, event, helper) {
    if (component.get('v.type') == 'clean') {
      component.set('v.showAlert',false);
      // component.clearnFlage(component);
      component.set('v.saveing',true);
      helper.clean(component);
    }
  },
  // Alert No
  no  : function(component, event, helper) {
    component.set('v.showAlert',false);
  },
  // 行削除
  remove: function(component, event, helper) {
    var datas = component.get('v.allData');
    for (var i = datas.length-1;i>=0;i--) {
        var map = datas[i];
        if (map.removeFlag == true)
        {
             datas.splice(i,1);
        }
    }
    component.set('v.allData',datas);

    // SV_DEV-847 エラー条件あるか判断
    var datas = component.get('v.allData');
    var haveError = false;
    for (var i=0;i<datas.length;i++) {
      var d = datas[i].data;
      var data = datas[i];
      if (data.isError) {
        haveError = true;
        break;
      }
    }

    // SV_DEV-847 エラーがなく,エラーメッセージが空白ではないの場合エラーメッセージをクリア
    if (haveError == false
        && component.get('v.errorMsg') != null
        && component.get('v.errorMsg') != '') {
      component.set('v.errorMsg', '');
    }
  },
  //保存
  save : function(component, event, helper) {
    component.set('v.saveing',true);
    component.set('v.okMsg','');
    helper.save(component, event, helper);
  },
  // #Todo 使わないため削除べき?checkboxコンポーネントを作成した
  reSelectAA  : function(component, event, helper) {
    var se = event.getSource().get('v.value');
    component.set('v.baseSet.RenkeiAccountQueryRecordTypeIds__c',se);
  },
  // 取引先レコードタイプチェックボックス処理
  accQueryRecordTypeChange  : function(component, event, helper) {
    var ids = event.getParam('value').join(';');
    component.set('v.baseSet.RenkeiAccountQueryRecordTypeIds__c',ids);
  },
  // 取引先責任者レコードタイプチェックボックス処理
  conQueryRecordTypeChange  : function(component, event, helper) {
    var ids = event.getParam('value').join(';');
    component.set('v.baseSet.RenkeiContactQueryRecordTypeIds__c',ids);
  },
  // #Todo 使わないため削除べき?checkboxコンポーネントを作成した
  reSelectCC  : function(component, event, helper) {
    var se = event.getSource().get('v.value');
    component.set('v.baseSet.RenkeiContactQueryRecordTypeIds__c',se);
  },
  // リードレコードタイプチェックボックス処理
  leadQueryRecordTypeChange  : function(component, event, helper) {
    var ids = event.getParam('value').join(';');
    component.set('v.baseSet.RenkeiLeadQueryRecordTypeIds__c', ids);
  },
  // ヘルプmouseover
  showHelpCommon : function(component, event, helper) {
    document.getElementById(event.target.id + 'Msg').style.display = 'block';
  },
  // ヘルプmouseover
  hideHelpCommon: function(component, event, helper) {
    document.getElementById(event.target.id + 'Msg').style.display = 'none';
  },

  

  // ラジオボタン表示処理
  onGroup1 : function(component, event, helper) {
    component.set('v.baseSet.RenkeiExcludeHojinkaku__c' ,'true');
    component.set('v.baseSet.RenkeiExcludeHojinkakuPartial__c','false');
    component.set('v.allKaKu','false');
    component.haveChange(component);
  },
  // ラジオボタン表示処理
  onGroup2 : function(component, event, helper) {
    component.set('v.baseSet.RenkeiExcludeHojinkaku__c' ,'false');
    component.set('v.baseSet.RenkeiExcludeHojinkakuPartial__c','true');
    component.set('v.allKaKu','false');
    component.haveChange(component);
  },
  // ラジオボタン表示処理
  onGroup3 : function(component, event, helper) {
    component.set('v.baseSet.RenkeiExcludeHojinkaku__c','false');
    component.set('v.baseSet.RenkeiExcludeHojinkakuPartial__c','false');
    component.set('v.allKaKu','true');
    component.haveChange(component);
  },
  // ラジオボタン表示処理
  onLeadGroup1 : function(component, event, helper) {
    component.set('v.baseSet.RenkeiLeadExcludeHojinkaku__c' ,'true');
    component.set('v.baseSet.RenkeiLeadExcludeHojinkakuPartial__c','false');
    component.set('v.allLeadKaKu','false');
    component.haveChange(component);
  },
  // ラジオボタン表示処理
  onLeadGroup2 : function(component, event, helper) {
    component.set('v.baseSet.RenkeiLeadExcludeHojinkaku__c' ,'false');
    component.set('v.baseSet.RenkeiLeadExcludeHojinkakuPartial__c','true');
    component.set('v.allLeadKaKu','false');
    component.haveChange(component);
  },
  // ラジオボタン表示処理
  onLeadGroup3 : function(component, event, helper) {
    component.set('v.baseSet.RenkeiLeadExcludeHojinkaku__c','false');
    component.set('v.baseSet.RenkeiLeadExcludeHojinkakuPartial__c','false');
    component.set('v.allLeadKaKu','true');
    component.haveChange(component);
  },
  // 保存必須フラグ
  changeSaveFlag : function(component, event, helper) {
    var renkeiAc = component.get('v.baseSet.RenkeiActive__c')=='true';
    component.set('v.disabledLeadActive', renkeiAc);
    if (renkeiAc == false) {
      component.set('v.baseSet.RenkeiActiveCampaignMember__c', 'false');
      component.set('v.baseSet.RenkeiLeadActive__c', 'false');
    }
    var renkeiLeadAc = component.get('v.baseSet.RenkeiLeadActive__c')=='true';
    component.set('v.disabledActiveCampaignMember',renkeiAc && renkeiLeadAc);
    if (renkeiLeadAc == false) {
      component.set('v.baseSet.RenkeiActiveCampaignMember__c', 'false');
    }

    component.set('v.campaignStatusDis' ,component.get('v.baseSet.RenkeiActiveCampaignMember__c') == 'false');
    component.set('v.needSave',true);
    component.set('v.needSaveself',true);
  },
  // 子コンポーネント編集イベント
  changeJyoukenEvent : function(component, event, helper) {
    component.haveChange(component);
  },
  // タブロード開始メソッド
  loadingStart : function(component, event, helper) {
    component.set('v.isloading',true);
  },
  // タブロード停止メソッド
  loadingEnd1 : function(component, event, helper) {
      component.set('v.isloading',false);
  },
  // 表示メッセージを隠す
  hiddenMsg : function(component, event, helper) {
    // component.clearnFlage(component);
    component.set('v.okMsg','');
  },
  // メッセージクリア
  clearMsg : function(component) {
    component.set('v.errorMsg','');
    component.set('v.warMsg',null);
    // component.set('v.warMsg1',null);
    // component.set('v.warMsgNoA',null);
    // component.set('v.warMsg1NoA',null);
  },
  // 保存ウォーニングメッセージクリア
  clearWarningMsg : function(component) {
    component.set('v.saveWarMsg','');
  },
    // タブ変更時の画面変更チェック
  checkChange : function(component, event, helper) {
    var basicDataMap = component.get('v.baseSet');
    if (basicDataMap == null) {
      return;
    }
    var basicDataMap1 = JSON.parse(JSON.stringify(basicDataMap));
    delete basicDataMap1['LastModifiedByName'];
    delete basicDataMap1['LastModifiedByDate'];
    delete basicDataMap1['LastModifiedById'];
    var basicData = JSON.stringify(basicDataMap1)
    var backUpbaseSet = component.get('v.backUpbaseSet');

    var nameCardSe1 = JSON.stringify(component.get('v.nameCardAPIMapSe'));
    var nameCardSe2 = component.get('v.nameCardAPIMapSeBackUp');
    var datas = component.get('v.allData');
    var allDataStr = '';
    for (var i=0;i<datas.length;i++) {
      var d = datas[i].data;
      allDataStr += d.NameCardName + d.Value + d.Operator;
    }
    var allDataBackUp = component.get('v.allDataBackUp');
    component.set('v.needSave',backUpbaseSet != basicData || allDataBackUp != allDataStr);
  },
  //自動連携チェックボックス変更イベント
  changeRenkeiActive : function(component, event, helper) {
    var renkeiAc = component.get('v.baseSet.RenkeiActive__c')=='true';
    component.set('v.disabledLeadActive', renkeiAc);
    if (renkeiAc == false) {
      component.set('v.baseSet.RenkeiActiveCampaignMember__c', 'false');
      component.set('v.baseSet.RenkeiLeadActive__c', 'false');
    }
    var renkeiLeadAc = component.get('v.baseSet.RenkeiLeadActive__c')=='true';
    component.set('v.disabledActiveCampaignMember',renkeiAc && renkeiLeadAc);
    if (renkeiLeadAc == false) {
      component.set('v.baseSet.RenkeiActiveCampaignMember__c', 'false');
    }

    component.set('v.campaignStatusDis' ,component.get('v.baseSet.RenkeiActiveCampaignMember__c') == 'false');
    // component.set('v.needSave',true);
  },
})