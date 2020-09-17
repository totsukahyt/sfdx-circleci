/**
 *
 *  SB_NameCard_Settings
 *   コンポーネントを表示するタブ付きコンポーネント Controller
 *
 *  Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author mao
 *  @Version 1.20      2017.02.XX
 *  @Version 1.20      2017.09.XX SV_DEV-1219 salesforce最新環境での「SmartVisca設定」内タブがまた大文字で表示される
 *
 *
 **/
({
  //初期化
  doInitf : function(component, event, helper) {
    component.set('v.selectTab','tabcustom');
    component.set('v.map1',true);
    component.set('v.tabMsg',component.get('v.tab1'));
    component.set('v.message','');
    component.set('v.loading',true);
    component.set('v.nowId','tabcustom');
    helper.doInitf(component);
  },
  // タブ変更
  changeTab: function(component, event, helper) {
    var aa = component.get('v.selectTab');
    if(aa != component.get('v.nowId')){
      component.set('v.nextId',aa);
    }
    if(component.get('v.nowId') == 'tabcustom'){
      var childCmp = component.find('basicsetting');
      childCmp.checkChange();
    } else if(component.get('v.nowId') == 'renkeiset') {
      var childCmp = component.find('renkeisetting');
      childCmp.checkChange();
    } else if(component.get('v.nowId') == 'renkeimapping') {
      var childCmp = component.find('renkeimappingc');
      childCmp.checkChange();
    }

    if(component.get("v.ischange") == false) {
      if(component.get('v.selectTab') == 'tabcustom'){
        component.set('v.tabMsg',component.get('v.tab1'));
      } else if(component.get('v.selectTab') == 'renkeiset') {
        component.set('v.tabMsg',component.get('v.tab2'));
      } else if(component.get('v.selectTab') == 'renkeimapping') {
        component.set('v.tabMsg',component.get('v.tab3'));
      }

      if(component.get('v.nowId') == 'tabcustom'){
        var childCmp = component.find('basicsetting');
        childCmp.hiddenMsg();
      } else if(component.get('v.nowId') == 'renkeiset') {
        var childCmp = component.find('renkeisetting');
        childCmp.hiddenMsg();
      } else if(component.get('v.nowId') == 'renkeimapping') {
        var childCmp = component.find('renkeimappingc');
        childCmp.hiddenMsg();
      }
      component.set('v.nowId',aa);
    } else {
      component.set('v.selectTab',component.get('v.nowId'));
      component.set('v.showAlert',true);
    }
  },
  // 基本設定更新
  ref: function(component, event, helper) {
    if (component.get('v.selectTab') != 'tabcustom') {
      var childCmp = component.find("basicsetting");
      childCmp.set("v.baseSet.LastModifiedByDate", event.getParam("lastModefDate"));
      childCmp.set("v.baseSet.LastModifiedByName", event.getParam("lastModifiedByName"));
      childCmp.set("v.baseSet.LastModifiedById", event.getParam("lastModifiedById"));
      //childCmp.refdata(component, event);
    }

    if (component.get('v.selectTab') != 'renkeiset') {
      var childCmp1 = component.find("renkeisetting");
      if (childCmp1 != undefined) {
        childCmp1.set("v.baseSet.LastModifiedByDate", event.getParam("lastModefDate"));
        childCmp1.set("v.baseSet.LastModifiedByName", event.getParam("lastModifiedByName"));
        childCmp1.set("v.baseSet.LastModifiedById", event.getParam("lastModifiedById"));
        //childCmp1.refdata(event.getParam("lastModefDate"));
      }
    }
  },
  // Alert Yes
  yes : function(component, event, helper) {
    component.set('v.showAlert',false);
    component.set('v.ischange',false);
    if(component.get('v.nextId') == 'tabcustom') {
      var childCmp = component.find('basicsetting');
      childCmp.loadingStart();
      component.set('v.tabMsg',component.get('v.tab1'));
    }
    else if(component.get('v.nextId') == 'renkeiset') {
      var childCmp = component.find('renkeisetting');
      childCmp.loadingStart();
      component.set('v.tabMsg',component.get('v.tab2'));
    } else if(component.get('v.nextId') == 'renkeimapping') {
      var childCmp = component.find('renkeimappingc');
      childCmp.loadingStart();
      component.set('v.tabMsg',component.get('v.tab3'));
    }

    if(component.get('v.nowId') == 'tabcustom'){
      var childCmp = component.find('basicsetting');
      childCmp.refdata();
    }
    else if(component.get('v.nowId') == 'renkeiset'){
      var childCmp = component.find('renkeisetting');
      childCmp.clean();
    } else if(component.get('v.nowId') == 'renkeimapping') {
      var childCmp = component.find('renkeimappingc');
      childCmp.clean();
    }
    component.set('v.selectTab',component.get('v.nextId'));
    component.set('v.nowId',component.get('v.nextId'));
  },
  // Alert No
  no : function(component, event, helper) {
    component.set('v.showAlert',false);
  },
  // ロード終了
  loadEnd : function(component, event, helper) {
    if(component.get('v.nextId') == 'tabcustom') {
      var childCmp = component.find('basicsetting');
      childCmp.loadingEnd1();
    }
    else if(component.get('v.nextId') == 'renkeiset') {
      var childCmp = component.find('renkeisetting');
      childCmp.loadingEnd1();
    }
    else if(component.get('v.nextId') == 'renkeimapping') {
      var childCmp = component.find('renkeimappingc');
      childCmp.loadingEnd1();
    }
  }
})