/**
 *
 * SB_NameCard_RenkeiMappingLcTest    (SB_NameCard_RenkeiMappingLcControllernoのテストクラス)
 *
 *
 *  Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author mao
 *  @Version 1      2017.02.20
 *  @Version 2.1       2018.04.XX  SV_DEV-876   連携設定条件に名刺項目に参照項目が選択できないことを変更
 *  @Version 2.1       2018.04.XX  SV_DEV-885 基本設定、連携条件設定、連携マッピングタブ切り替えの見直し
 *  @Version 2.1       2018.04.XX  SV_DEV-1106 SmartVisca基本設定レコードの一部項目の値が反転して表示される。
 *  @Version 2.4       2019.05.XX  SV_DEV-1630と合わせてリファクタリングを実施
 *                     2019.08.XX  SV_DEV-1630 固定のマッピングが削除された場合/無効化された場合にエラーメッセージを出すよう変更
 *
 **/



@isTest
private class SB_NameCard_RenkeiMappingLcTest {
  //レコードタイプID
  public static String ARECORDTYPEID = '';
  public static String CRECORDTYPEID = '';

  //テストデータを作成
  private static void setMappingDate() {
    NameCardBasicSetting__c s = SB_NameCard_BasicSetting.getNameCardBasicSetting();
    if(String.isBlank(s.Id)){
      insert s;
    }
    String objname = SB_NameCard_RenkeiMapperUtil.getManagedObjectName('NameCardRenkeiMapping__c');
    List<RecordType> res = [SELECT Id,Name,Developername FROM RecordType WHERE SobjectType = :objname AND (Developername ='Account' OR Developername = 'Contact')];
    System.debug('resresres' + res);
    ARECORDTYPEID = res[0].Developername == 'Account' ? res[0].Id : res[1].Id;
    CRECORDTYPEID = res[0].Developername == 'Contact' ? res[0].Id : res[1].Id;
    List<NameCardRenkeiMapping__c> testmapplist = new List<NameCardRenkeiMapping__c>();
    NameCardRenkeiMapping__c amap = new NameCardRenkeiMapping__c();
    amap.IsActive__c = true;
    amap.TargetName__c = SB_NameCard_Util.getNamespacePrefix_x() + 'NameCardMemo__c';
    amap.NameCardName__c = 'Name';
    amap.BasicSetting__c = s.Id;

    if(res.size()>0){
      amap.RecordTypeId = ARECORDTYPEID;
    }
    testmapplist.add(amap);

    NameCardRenkeiMapping__c cmap = new NameCardRenkeiMapping__c();
    cmap.IsActive__c = true;
    cmap.TargetName__c = SB_NameCard_Util.getNamespacePrefix_x() + 'NameCardMemo__c';
    cmap.NameCardName__c = 'Name';
    cmap.BasicSetting__c = s.Id;
    if(res.size()>1){
      cmap.RecordTypeId =CRECORDTYPEID;
    }
    testmapplist.add(cmap);

    insert testmapplist;
  }

  //テストデータを作成
  private static void setInactiveMappingDate() {
    NameCardBasicSetting__c s = SB_NameCard_BasicSetting.getNameCardBasicSetting();
    if(String.isBlank(s.Id)){
      insert s;
    }
    String objname = SB_NameCard_RenkeiMapperUtil.getManagedObjectName('NameCardRenkeiMapping__c');
    List<RecordType> res = [SELECT Id,Name,Developername FROM RecordType WHERE SobjectType = :objname AND (Developername ='Account' OR Developername = 'Contact')];
    System.debug('resresres' + res);
    ARECORDTYPEID = res[0].Developername == 'Account' ? res[0].Id : res[1].Id;
    CRECORDTYPEID = res[0].Developername == 'Contact' ? res[0].Id : res[1].Id;
    List<NameCardRenkeiMapping__c> testmapplist = new List<NameCardRenkeiMapping__c>();

    NameCardRenkeiMapping__c amap = new NameCardRenkeiMapping__c();
    amap.IsActive__c = false;
    amap.TargetName__c = 'OwnerId';
    amap.NameCardName__c = 'OwnerId';
    amap.BasicSetting__c = s.Id;
    if(res.size()>0){
      amap.RecordTypeId = ARECORDTYPEID;
    }
    testmapplist.add(amap);


    NameCardRenkeiMapping__c cmap = new NameCardRenkeiMapping__c();
    cmap.IsActive__c = false;
    cmap.TargetName__c = 'OwnerId';
    cmap.NameCardName__c = 'OwnerId';
    cmap.BasicSetting__c = s.Id;
    if(res.size()>1){
      cmap.RecordTypeId =CRECORDTYPEID;
    }
    testmapplist.add(cmap);

    insert testmapplist;
  }

  //保存テスト
  @isTest static void test_RenkeiMappingSaveMapping() {
    setMappingDate();
    List<NameCardRenkeiMapping__c> amap = [Select Id,Name,IsActive__c,TargetName__c,NameCardName__c From NameCardRenkeiMapping__c Where Recordtype.Developername = 'Account'];
    System.assertEquals(amap.size(),1);

    List<NameCardRenkeiMapping__c> cmap = [Select Id,Name,IsActive__c,TargetName__c,NameCardName__c From NameCardRenkeiMapping__c Where Recordtype.Developername = 'Contact'];
    System.assertEquals(cmap.size(),1);

    List<NameCardRenkeiMapping__c> upse = new List<NameCardRenkeiMapping__c>();

    NameCardRenkeiMapping__c amap0 = new NameCardRenkeiMapping__c();
    amap0.IsActive__c = true;
    amap0.TargetName__c = 'Fax';
    amap0.NameCardName__c = 'AccountNCTestSaveName';
    amap0.ID = amap[0].ID;
    upse.add(amap0);

    NameCardRenkeiMapping__c amap1 = new NameCardRenkeiMapping__c();
    amap1.IsActive__c = true;
    amap1.TargetName__c = 'AccountTestSaveName';
    amap1.NameCardName__c = 'AccountNCTestSaveName';
    upse.add(amap1);

    List<SB_NameCard_NameCardRenkeiMappingDTO> ds = new List<SB_NameCard_NameCardRenkeiMappingDTO>();
    for(NameCardRenkeiMapping__c maps : upse){
      SB_NameCard_NameCardRenkeiMappingDTO dd = new SB_NameCard_NameCardRenkeiMappingDTO();
      dd.bind(maps);
      ds.add(dd);
    }

    String savemsg = SB_NameCard_RenkeiMappingLcController.savemaps(JSON.serialize(ds),ARECORDTYPEID,'Account');
    SB_NameCard_RenkeiMappingLcController.Renkeidata lstFilters = new SB_NameCard_RenkeiMappingLcController.Renkeidata();
    lstFilters = (SB_NameCard_RenkeiMappingLcController.Renkeidata )System.JSON.deserializeStrict(savemsg,SB_NameCard_RenkeiMappingLcController.Renkeidata .Class);
    System.assertEquals(lstFilters.message,System.Label.SB_NC_MAPPING_MSG_SAVEOK);
    amap = [Select Id,Name,IsActive__c,TargetName__c,NameCardName__c From NameCardRenkeiMapping__c Where Recordtype.Developername = 'Account'];
    System.assertEquals(amap.size(),5);

  }

  //レコードタイプ変更テスト
  @isTest static void test_RenkeiMappingChangeRecord() {
    setMappingDate();
    List<NameCardRenkeiMapping__c> amap = [Select Id,Name,IsActive__c,TargetName__c,NameCardName__c From NameCardRenkeiMapping__c Where Recordtype.Developername = 'Account'];
    System.assertEquals(amap.size(),1);

    List<NameCardRenkeiMapping__c> cmap = [Select Id,Name,IsActive__c,TargetName__c,NameCardName__c From NameCardRenkeiMapping__c Where Recordtype.Developername = 'Contact'];
    System.assertEquals(cmap.size(),1);


    String cr = SB_NameCard_RenkeiMappingLcController.changerecord('Contact',CRECORDTYPEID);
    SB_NameCard_RenkeiMappingLcController.RecordTypedata lstFilters = new SB_NameCard_RenkeiMappingLcController.RecordTypedata();
    lstFilters = (SB_NameCard_RenkeiMappingLcController.RecordTypedata )System.JSON.deserializeStrict(cr,SB_NameCard_RenkeiMappingLcController.RecordTypedata .Class);
    System.assertEquals(lstFilters.mappingList.size(),1);
    System.assertEquals(lstFilters.mappingList[0].TargetName,SB_NameCard_Util.getNamespacePrefix_x() + 'NameCardMemo__c');
    System.assertEquals(lstFilters.mappingList[0].NameCardName, 'Name');
    String def1 = SB_NameCard_RenkeiMappingLcController.changetodefault('Contact',lstFilters.obj2LabelNameMap,CRECORDTYPEID);
    SB_NameCard_RenkeiMappingLcController.Metadata def = new SB_NameCard_RenkeiMappingLcController.Metadata();
    def = (SB_NameCard_RenkeiMappingLcController.Metadata )System.JSON.deserializeStrict(def1,SB_NameCard_RenkeiMappingLcController.Metadata .Class);
    List<DefaultRenkeiMapping__mdt> metas = [Select ID,TargetName__c,NameCardName__c,IsActive__c,recordtype__c
                                                                        From DefaultRenkeiMapping__mdt
                                                                        Where recordtype__c = 'Contact' ];
    System.assertEquals(def.mappingList.size(),metas.size()-4);

  }

  //最終更新者
  @isTest static void test_RenkeiMappingLast() {
    setMappingDate();
    List<NameCardRenkeiMapping__c> amap = [Select Id,Name,IsActive__c,TargetName__c,NameCardName__c From NameCardRenkeiMapping__c Where Recordtype.Developername = 'Account'];
    System.assertEquals(amap.size(),1);

    List<NameCardRenkeiMapping__c> cmap = [Select Id,Name,IsActive__c,TargetName__c,NameCardName__c From NameCardRenkeiMapping__c Where Recordtype.Developername = 'Contact'];
    System.assertEquals(cmap.size(),1);

    List<NameCardRenkeiMapping__c> upse = new List<NameCardRenkeiMapping__c>();

    List<SB_NameCard_NameCardRenkeiMappingDTO> ds = new List<SB_NameCard_NameCardRenkeiMappingDTO>();
    //for(NameCardRenkeiMapping__c maps : upse){
    //    SB_NameCard_NameCardRenkeiMappingDTO dd = new SB_NameCard_NameCardRenkeiMappingDTO();
    //    dd.bind(maps);
    //    ds.add(dd);
    //}

    String savemsg = SB_NameCard_RenkeiMappingLcController.savemaps(JSON.serialize(ds),ARECORDTYPEID,'Account');
    String acalldata = SB_NameCard_RenkeiMappingLcController.getmapping('Account');
    SB_NameCard_RenkeiMappingLcController.RenkeiMappingAlldata acalldata0 = new SB_NameCard_RenkeiMappingLcController.RenkeiMappingAlldata();
    acalldata0 = (SB_NameCard_RenkeiMappingLcController.RenkeiMappingAlldata )System.JSON.deserializeStrict(acalldata,SB_NameCard_RenkeiMappingLcController.RenkeiMappingAlldata .Class);
    System.debug(acalldata0.requiredAccMappingList);
    System.assertEquals(acalldata0.requiredAccMappingList.size(),3);
    System.assertEquals(acalldata0.mappingList.size(),0);
    //System.assertEquals(acalldata0.lastid,UserInfo.getUserId());
    //System.assertEquals(acalldata0.lastname,UserInfo.getName());

  }


  //データを取得する
  @isTest static void test_RenkeiMappinggetMapping() {
    setMappingDate();
    List<NameCardRenkeiMapping__c> amap = [Select Id,Name,IsActive__c,TargetName__c,NameCardName__c From NameCardRenkeiMapping__c Where Recordtype.Developername = 'Account'];
    System.assertEquals(amap.size(),1);

    List<NameCardRenkeiMapping__c> cmap = [Select Id,Name,IsActive__c,TargetName__c,NameCardName__c From NameCardRenkeiMapping__c Where Recordtype.Developername = 'Contact'];
    System.assertEquals(cmap.size(),1);


    String acalldata = SB_NameCard_RenkeiMappingLcController.getmapping('');
    SB_NameCard_RenkeiMappingLcController.RenkeiMappingAlldata acalldata1 = new SB_NameCard_RenkeiMappingLcController.RenkeiMappingAlldata();
    acalldata1 = (SB_NameCard_RenkeiMappingLcController.RenkeiMappingAlldata )System.JSON.deserializeStrict(acalldata,SB_NameCard_RenkeiMappingLcController.RenkeiMappingAlldata .Class);
    System.assertEquals(acalldata1.requiredAccMappingList.size(),0);
    System.assertEquals(acalldata1.mappingList.size(),1);
    String acalldata01 = SB_NameCard_RenkeiMappingLcController.getmapping('Contact');
    SB_NameCard_RenkeiMappingLcController.RenkeiMappingAlldata acalldata2 = new SB_NameCard_RenkeiMappingLcController.RenkeiMappingAlldata();
    acalldata2 = (SB_NameCard_RenkeiMappingLcController.RenkeiMappingAlldata )System.JSON.deserializeStrict(acalldata01,SB_NameCard_RenkeiMappingLcController.RenkeiMappingAlldata .Class);
    System.assertEquals(acalldata2.requiredConMappingList.size(),0);
    System.assertEquals(acalldata2.mappingList.size(),1);

  }

  //テータを削除
  @isTest static void test_RenkeiMappingDelete() {
    setMappingDate();
    List<NameCardRenkeiMapping__c> amap = [Select Id,Name,IsActive__c,TargetName__c,NameCardName__c From NameCardRenkeiMapping__c Where Recordtype.Developername = 'Account'];
    System.assertEquals(amap.size(),1);

    List<NameCardRenkeiMapping__c> cmap = [Select Id,Name,IsActive__c,TargetName__c,NameCardName__c From NameCardRenkeiMapping__c Where Recordtype.Developername = 'Contact'];
    System.assertEquals(cmap.size(),1);


    List<NameCardRenkeiMapping__c> upse = new List<NameCardRenkeiMapping__c>();

    List<SB_NameCard_NameCardRenkeiMappingDTO> ds = new List<SB_NameCard_NameCardRenkeiMappingDTO>();
    for(NameCardRenkeiMapping__c maps : upse){
      SB_NameCard_NameCardRenkeiMappingDTO dd = new SB_NameCard_NameCardRenkeiMappingDTO();
      dd.bind(maps);
      ds.add(dd);
    }

    String savemsg = SB_NameCard_RenkeiMappingLcController.savemaps(JSON.serialize(ds),ARECORDTYPEID,'Account');
    SB_NameCard_RenkeiMappingLcController.Renkeidata acalldata2 = new SB_NameCard_RenkeiMappingLcController.Renkeidata();
    acalldata2 = (SB_NameCard_RenkeiMappingLcController.Renkeidata )System.JSON.deserializeStrict(savemsg,SB_NameCard_RenkeiMappingLcController.Renkeidata .Class);
    amap = [Select Id,Name,IsActive__c,TargetName__c,NameCardName__c From NameCardRenkeiMapping__c Where Recordtype.Developername = 'Account'];
    System.assertEquals(amap.size(),3);

  }

    //エラーcase
  @isTest static void test_RenkeiMappingError() {
    setMappingDate();
    setMappingDate();
    List<NameCardRenkeiMapping__c> amap = [Select Id,Name,IsActive__c,TargetName__c,NameCardName__c From NameCardRenkeiMapping__c Where Recordtype.Developername = 'Account'];
    System.assertEquals(amap.size(),2);

    List<NameCardRenkeiMapping__c> cmap = [Select Id,Name,IsActive__c,TargetName__c,NameCardName__c From NameCardRenkeiMapping__c Where Recordtype.Developername = 'Contact'];
    System.assertEquals(cmap.size(),2);


    List<NameCardRenkeiMapping__c> upse = new List<NameCardRenkeiMapping__c>();
    List<NameCardRenkeiMapping__c> testmapplist = new List<NameCardRenkeiMapping__c>();
    amap[0].IsActive__c = !amap[0].IsActive__c;
    amap[1].IsActive__c = !amap[1].IsActive__c;
    upse.add(amap[0]);
    upse.add(amap[1]);
    List<SB_NameCard_NameCardRenkeiMappingDTO> ds = new List<SB_NameCard_NameCardRenkeiMappingDTO>();
    for(NameCardRenkeiMapping__c maps : upse){
      SB_NameCard_NameCardRenkeiMappingDTO dd = new SB_NameCard_NameCardRenkeiMappingDTO();
      dd.bind(maps);
      ds.add(dd);
    }
    String savemsg11 = SB_NameCard_RenkeiMappingLcController.savemaps(JSON.serialize(ds),ARECORDTYPEID,'Account');
    SB_NameCard_RenkeiMappingLcController.Renkeidata savemsg = new SB_NameCard_RenkeiMappingLcController.Renkeidata();
    savemsg = (SB_NameCard_RenkeiMappingLcController.Renkeidata )System.JSON.deserializeStrict(savemsg11,SB_NameCard_RenkeiMappingLcController.Renkeidata .Class);
    System.assertEquals(savemsg.state,'ok');
    List<NameCardRenkeiMapping__c> inse = new List<NameCardRenkeiMapping__c>();
    inse.add(new NameCardRenkeiMapping__c());
    inse.add(new NameCardRenkeiMapping__c());
    List<SB_NameCard_NameCardRenkeiMappingDTO> ds1 = new List<SB_NameCard_NameCardRenkeiMappingDTO>();
    for(NameCardRenkeiMapping__c maps : inse){
      SB_NameCard_NameCardRenkeiMappingDTO dd = new SB_NameCard_NameCardRenkeiMappingDTO();
      dd.bind(maps);
      ds1.add(dd);
    }
    String savemsg12 = SB_NameCard_RenkeiMappingLcController.savemaps(JSON.serialize(ds1),ARECORDTYPEID,'Account');
    SB_NameCard_RenkeiMappingLcController.Renkeidata savemsg1 = new SB_NameCard_RenkeiMappingLcController.Renkeidata();
    savemsg1 = (SB_NameCard_RenkeiMappingLcController.Renkeidata )System.JSON.deserializeStrict(savemsg12,SB_NameCard_RenkeiMappingLcController.Renkeidata .Class);
    System.assertEquals(savemsg1.state,'saveerror');
    String err = '';
    try{
      String cr1 = SB_NameCard_RenkeiMappingLcController.changerecord('error','error');
      SB_NameCard_RenkeiMappingLcController.Renkeidata cr = new SB_NameCard_RenkeiMappingLcController.Renkeidata();
      cr = (SB_NameCard_RenkeiMappingLcController.Renkeidata )System.JSON.deserializeStrict(cr1,SB_NameCard_RenkeiMappingLcController.Renkeidata .Class);
    }
    catch(Exception e){
      err = e.getMessage();
    }
    System.assertNotEquals(String.isBlank(err),true);
  }

  // 連携マッピング取引先デフォルトボタンクリックテスト
  @isTest static void test_RenkeiMappingChangeRecordAc() {
    setMappingDate();
    List<NameCardRenkeiMapping__c> amap = [Select Id,Name,IsActive__c,TargetName__c,NameCardName__c From NameCardRenkeiMapping__c Where Recordtype.Developername = 'Account'];
    System.assertEquals(amap.size(),1);

    List<NameCardRenkeiMapping__c> cmap = [Select Id,Name,IsActive__c,TargetName__c,NameCardName__c From NameCardRenkeiMapping__c Where Recordtype.Developername = 'Contact'];
    System.assertEquals(cmap.size(),1);


    String cr = SB_NameCard_RenkeiMappingLcController.changerecord('Account',CRECORDTYPEID);
    SB_NameCard_RenkeiMappingLcController.RecordTypedata lstFilters = new SB_NameCard_RenkeiMappingLcController.RecordTypedata();
    lstFilters = (SB_NameCard_RenkeiMappingLcController.RecordTypedata )System.JSON.deserializeStrict(cr,SB_NameCard_RenkeiMappingLcController.RecordTypedata .Class);
    System.assertEquals(lstFilters.mappingList.size(),1);
    System.assertEquals(lstFilters.mappingList[0].TargetName,SB_NameCard_Util.getNamespacePrefix_x() + 'NameCardMemo__c');
    System.assertEquals(lstFilters.mappingList[0].NameCardName, 'Name');
    String def1 = SB_NameCard_RenkeiMappingLcController.changetodefault('Account',lstFilters.obj2LabelNameMap,CRECORDTYPEID);
    SB_NameCard_RenkeiMappingLcController.Metadata def = new SB_NameCard_RenkeiMappingLcController.Metadata();
    def = (SB_NameCard_RenkeiMappingLcController.Metadata )System.JSON.deserializeStrict(def1,SB_NameCard_RenkeiMappingLcController.Metadata .Class);
    List<DefaultRenkeiMapping__mdt> metas = [Select ID,TargetName__c,NameCardName__c,IsActive__c,recordtype__c
                                                                        From DefaultRenkeiMapping__mdt
                                                                        Where recordtype__c = 'Account' ];
    System.assertEquals(def.mappingList.size(),metas.size()-3);
  }

  // 連携マッピング取引先責任者デフォルトボタンクリックテスト
  @isTest static void test_RenkeiMappingChangeRecordCo() {
    setMappingDate();
    List<NameCardRenkeiMapping__c> amap = [Select Id,Name,IsActive__c,TargetName__c,NameCardName__c From NameCardRenkeiMapping__c Where Recordtype.Developername = 'Account'];
    System.assertEquals(amap.size(),1);

    List<NameCardRenkeiMapping__c> cmap = [Select Id,Name,IsActive__c,TargetName__c,NameCardName__c From NameCardRenkeiMapping__c Where Recordtype.Developername = 'Contact'];
    System.assertEquals(cmap.size(),1);

    List<NameCardRenkeiMapping__c> upse = new List<NameCardRenkeiMapping__c>();

    NameCardRenkeiMapping__c amap0 = new NameCardRenkeiMapping__c();
    amap0.IsActive__c = true;
    amap0.TargetName__c = 'Fax';
    amap0.NameCardName__c = 'AccountNCTestSaveName';
    amap0.ID = amap[0].ID;
    upse.add(amap0);

    NameCardRenkeiMapping__c amap1 = new NameCardRenkeiMapping__c();
    amap1.IsActive__c = true;
    amap1.TargetName__c = 'AccountTestSaveName';
    amap1.NameCardName__c = 'AccountNCTestSaveName';
    upse.add(amap1);

    List<SB_NameCard_NameCardRenkeiMappingDTO> ds = new List<SB_NameCard_NameCardRenkeiMappingDTO>();
    for(NameCardRenkeiMapping__c maps : upse){
      SB_NameCard_NameCardRenkeiMappingDTO dd = new SB_NameCard_NameCardRenkeiMappingDTO();
      dd.bind(maps);
      ds.add(dd);
    }

    String savemsg = SB_NameCard_RenkeiMappingLcController.savemaps(JSON.serialize(ds),CRECORDTYPEID,'Contact');
    SB_NameCard_RenkeiMappingLcController.Renkeidata lstFilters = new SB_NameCard_RenkeiMappingLcController.Renkeidata();
    lstFilters = (SB_NameCard_RenkeiMappingLcController.Renkeidata )System.JSON.deserializeStrict(savemsg,SB_NameCard_RenkeiMappingLcController.Renkeidata .Class);
    System.assertEquals(lstFilters.message,System.Label.SB_NC_MAPPING_MSG_SAVEOK);
    amap = [Select Id,Name,IsActive__c,TargetName__c,NameCardName__c From NameCardRenkeiMapping__c Where Recordtype.Developername = 'Contact'];
    System.assertEquals(amap.size(),5);
  }

  // 存在しない連携先テスト
  @isTest static void test_RenkeiMappingNorRenkei() {
    String cr1 = SB_NameCard_RenkeiMappingLcController.changerecord('Account','error');
    SB_NameCard_RenkeiMappingLcController.RecordTypedata cr = new SB_NameCard_RenkeiMappingLcController.RecordTypedata();
    cr = (SB_NameCard_RenkeiMappingLcController.RecordTypedata )System.JSON.deserializeStrict(cr1,SB_NameCard_RenkeiMappingLcController.RecordTypedata .Class);
    System.assertEquals(cr.mappingList.size(),0);
  }

  // すべてデータの取得
  @isTest static void test_RenkeiMappingnoGetDatagetMyMap() {
    String cr1 = SB_NameCard_RenkeiMappingLcController.getMyMap();
    SB_NameCard_RenkeiMappingLcController.RecordTypebin cr = (SB_NameCard_RenkeiMappingLcController.RecordTypebin )System.JSON.deserializeStrict(cr1,SB_NameCard_RenkeiMappingLcController.RecordTypebin .Class);
    System.assertNotEquals(cr.keys.size(),0);
  }

  // レコードタイプBean取得
  @isTest static void test_RenkeiMappingnoGetDatagetMyRecordType() {
    SB_NameCard_RenkeiMappingLcController.RecordTypebin cr = SB_NameCard_RenkeiMappingLcController.getMyRecordType();
    System.assertNotEquals(cr.keys.size(),0);
  }

  //基本設定レコードないエラー
  @isTest static void test_RenkeiMappingNoBasicSettingError() {

    String acalldata = SB_NameCard_RenkeiMappingLcController.getmapping('');
    SB_NameCard_RenkeiMappingLcController.RenkeiMappingAlldata acalldata1 = new SB_NameCard_RenkeiMappingLcController.RenkeiMappingAlldata();
    acalldata1 = (SB_NameCard_RenkeiMappingLcController.RenkeiMappingAlldata )System.JSON.deserializeStrict(acalldata,SB_NameCard_RenkeiMappingLcController.RenkeiMappingAlldata .Class);
    System.assertEquals(acalldata1.warningMsg, System.Label.SB_NC_SETTING_ERROR_No_NameCardBasicSetting);
  }

  //無効データを取得する
  @isTest static void test_RenkeiMappinggetInactiveMapping() {
    setInactiveMappingDate();
    List<NameCardRenkeiMapping__c> amap = [Select Id,Name,IsActive__c,TargetName__c,NameCardName__c From NameCardRenkeiMapping__c Where Recordtype.Developername = 'Account'];
    System.assertEquals(amap.size(),1);

    List<NameCardRenkeiMapping__c> cmap = [Select Id,Name,IsActive__c,TargetName__c,NameCardName__c From NameCardRenkeiMapping__c Where Recordtype.Developername = 'Contact'];
    System.assertEquals(cmap.size(),1);


    String acalldata = SB_NameCard_RenkeiMappingLcController.getmapping('');
    SB_NameCard_RenkeiMappingLcController.RenkeiMappingAlldata acalldata1 = new SB_NameCard_RenkeiMappingLcController.RenkeiMappingAlldata();
    acalldata1 = (SB_NameCard_RenkeiMappingLcController.RenkeiMappingAlldata )System.JSON.deserializeStrict(acalldata,SB_NameCard_RenkeiMappingLcController.RenkeiMappingAlldata .Class);
    System.assertEquals(acalldata1.requiredAccMappingList.size(),0);
    System.assertEquals(acalldata1.mappingList.size(),0);
    System.assertEquals(acalldata1.namecardMsgList.size(),3); // 無効1(所有者ID) + 削除2(会社名・名刺オブジェクトID)
    String acalldata01 = SB_NameCard_RenkeiMappingLcController.getmapping('Contact');
    SB_NameCard_RenkeiMappingLcController.RenkeiMappingAlldata acalldata2 = new SB_NameCard_RenkeiMappingLcController.RenkeiMappingAlldata();
    acalldata2 = (SB_NameCard_RenkeiMappingLcController.RenkeiMappingAlldata )System.JSON.deserializeStrict(acalldata01,SB_NameCard_RenkeiMappingLcController.RenkeiMappingAlldata .Class);
    System.assertEquals(acalldata2.requiredConMappingList.size(),0);
    System.assertEquals(acalldata2.mappingList.size(),0);
    System.assertEquals(acalldata2.namecardMsgList.size(),4); // 無効1(所有者ID) + 削除3(姓・取引先ID・名刺オブジェクトID)

  }
}