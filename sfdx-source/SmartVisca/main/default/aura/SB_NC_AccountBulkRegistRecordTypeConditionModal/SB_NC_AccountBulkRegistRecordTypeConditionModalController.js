/**
 *
 *  SB_NC_AccountBulkRegistRecordTypeConditionModal
 *  レコードタイプ選択用モーダルウィンドウ用コンポーネント Controller
 *
 *  Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author K.Yoshida
 *  @Version 2.2  2019.02.XX SV_DEV-1558 LEX 取引先登録 一括画面をLXパッケージ同様のLC化で追加
 *
 **/
({
	// 閉じる
  close : function(component, event, helper) {
    var inputV = component.get('v.inputV');
    var backupV = component.get('v.backupV');
    inputV.selectedConditionCMtc = backupV.selectedConditionCMtc;
    inputV.searchConditionRct = backupV.searchConditionRct;
    component.set('v.inputV', inputV);
    component.set('v.show', false);
  },
  // 保存
  save : function(component, event, helper) {
    var searchRecordTypesMap = {};
    var recs = component.get('v.inputV.searchConditionRct.accRecordTypesCondition');
    var recordTypeList = new Array;

    for (var i = 0; i < recs.length; i ++) {
      if (recs[i].checked) {
        recordTypeList.push(recs[i].value);
      }
    }
    searchRecordTypesMap['Account'] = recordTypeList;

    recs = component.get('v.inputV.searchConditionRct.conRecordTypesCondition');
    recordTypeList = new Array;

    for (var i = 0; i < recs.length; i ++) {
      if (recs[i].checked) {
        recordTypeList.push(recs[i].value);
      }
    }
    searchRecordTypesMap['Contact'] = recordTypeList;
    component.set('v.searchRecordTypesMap', searchRecordTypesMap);
    component.set('v.show', false);

    var changeSearchCondition = component.getEvent("changeSearchCondition");
    changeSearchCondition.fire();
  },
  // 検索条件変更
  modalSearchRecordTypeChanged : function(component, event, helper) {
    var name = event.getParam("name");
    var fieldName = event.getParam("fieldName");
    var changeItem = event.getParam("value");

    var recOps = {};
    var recOps2 = {};
    if (name == 'modalSearchRecordTypeEvent') {
      if ( fieldName == 'account' ){
        recOps = component.get('v.inputV.searchConditionRct.accRecordTypesCondition');
        recOps2 = component.get('v.inputV.searchConditionRct.conRecordTypesCondition');
      }else{
        recOps = component.get('v.inputV.searchConditionRct.conRecordTypesCondition');
        recOps2 = component.get('v.inputV.searchConditionRct.accRecordTypesCondition');
      }

      // (全て)がチェックされた場合には他のチェックボックスにチェックを入れる
      if (changeItem.startsWith('all') && recOps[recOps.length-1].checked) {
        for (var i = 0; i < recOps.length-1; i ++) {
          recOps[i].checked = true;
        }
      }else if(changeItem.startsWith('all') && !recOps[recOps.length-1].checked) {
        for (var i = 0; i < recOps.length-1; i ++) {
          recOps[i].checked = false;
        }
      }

      // グループ内の一部でもOFFならチェックを外す
      //SV_DEV-2086 LEX 取引先登録 一括：検索対象のレコードタイプが絞られている場合に最下部のレコードタイプのチェックが他のレコードタイプの設定を変更した際にチェックが外れる
      //最後のチェックボックスが「(全て)」でないならSKIP
      if (recOps[recOps.length - 1].value.startsWith('all') && !changeItem.startsWith('all')) {
        for (var i = 0; i < recOps.length-1; i ++) {
          if (!recOps[i].checked) {
            recOps[recOps.length - 1].checked = false;
            break;
          }
        }
      }

      if ( fieldName == 'account' ){
        component.set('v.inputV.searchConditionRct.accRecordTypesCondition',recOps);
      }else{
        component.set('v.inputV.searchConditionRct.conRecordTypesCondition',recOps);
      }

      // 1つでもグループ内のすべてのチェックボックスがOFFのグループがある場合はOKボタン無効化
      var chkExistFlg1 = false;
      for (var i = 0; i < recOps.length; i ++) {
        if (recOps[i].checked) {
          chkExistFlg1 = true;
          break;
        }
      }
      // もう一方もレコードタイプがあるならチェック
      if (recOps2.length > 0) {
        var chkExistFlg2 = false;
        for (var i = 0; i < recOps2.length; i ++) {
          if (recOps2[i].checked) {
            chkExistFlg2 = true;
            break;
          }
        }
      } else {
        var chkExistFlg2 = true;
      }
      
      component.set('v.disabledOKButton', !chkExistFlg1 || !chkExistFlg2 );
    }
  },
  searchConditionCMtcChange : function(component, event, helper) {
    var sel = "";
    var opts = document.getElementsByName("searchConditionCompanyMatcing");
    for (var i = 0; i < opts.length; i++) {
      if (opts[i].checked) {
        sel = opts[i].value;
        break;
      }
    }
    component.set('v.inputV.selectedConditionCMtc', sel);
  },
})