/**
 *
 * SB_NameCard_RenkeiSettingLcTest    (SB_NameCard_RenkeiSettingLcController)
 *
 *
 *  Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author mao
 *  @Version 1.20      2017.02.20
 *  @Version 1.21 kou 2017.10.xx No Assert v1.21 for code scan
 *  @Version 2.1       2018.04.XX  SV_DEV-876   連携設定条件に名刺項目に参照項目が選択できないことを変更
 *  @Version 2.1       2018.04.XX  SV_DEV-885 基本設定、連携条件設定、連携マッピングタブ切り替えの見直し
 *  @Version 2.1       2018.04.XX  SV_DEV-1106 SmartVisca基本設定レコードの一部項目の値が反転して表示される。
 **/


@isTest
private class SB_NameCard_RenkeiSettingLcTest {

  public  static NameCardBasicSetting__c setDate(){
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    setting.Name = 'BasicSetting';
    setting.RenkeiContactFirstName__c = true;
    setting.RenkeiContactLastName__c = true;
    setting.RenkeiAccountCompany__c = true;
    setting.RenkeiContactMail__c = true;
    setting.RenkeiAccountSite__c = true;
    setting.RenkeiAccountZipCode__c = true;
    setting.RenkeiSpecificItems__c = 'Name';
    setting.RenkeiAccountAddressPref__c = true;
    setting.RenkeiAccountCity__c = true;
    setting.RenkeiAccountOverwrite__c = true;
    setting.RenkeiAccountNOExistCreateNew__c = true;
    insert setting;

    NameCardRenkeiJyoken__c jyouken = new NameCardRenkeiJyoken__c();
    jyouken.NameCardName__c = 'Name';
    jyouken.Operator__c = 'Matches_next_character_string';
    jyouken.Value__c = 'test';
    insert jyouken;

    return SB_NameCard_BasicSetting.getNameCardBasicSetting();
  }

  // データ取得テスト
  @isTest static void test_GetAllData() {
    NameCardBasicSetting__c bas = setdate();
    NameCardRenkeiJyoken__c jyouken1 = new NameCardRenkeiJyoken__c();
    jyouken1.NameCardName__c = 'Name';
    jyouken1.Operator__c = 'Matches_next_character_string';
    jyouken1.Value__c = '';
    insert jyouken1;
    SB_NameCard_RenkeiSettingLcController.getallmap();
    String jyous1 = SB_NameCard_RenkeiSettingLcController.getalldata();
    List<SB_NameCard_NameCardRenkeiJyokenDTO> jyous = new List<SB_NameCard_NameCardRenkeiJyokenDTO>();
    jyous = (List<SB_NameCard_NameCardRenkeiJyokenDTO>)System.JSON.deserializeStrict(jyous1,List<SB_NameCard_NameCardRenkeiJyokenDTO> .Class);
    System.assertEquals(jyous.size(),2);
  }

  // 連携条件更新テスト
  @isTest static void test_Updae() {
    NameCardBasicSetting__c bas = setdate();
    List<NameCardRenkeiJyoken__c> ses = [Select Id,Name,NameCardName__c,Operator__c,Value__c From  NameCardRenkeiJyoken__c];
    ses[0].NameCardName__c = 'Name';
    ses[0].Operator__c = 'Does_not_match_next_character_string';
    ses[0].Value__c = 'tttt';
    List<SB_NameCard_NameCardRenkeiJyokenDTO> ds = new List<SB_NameCard_NameCardRenkeiJyokenDTO>();
    for(NameCardRenkeiJyoken__c jyo : ses){
      SB_NameCard_NameCardRenkeiJyokenDTO d = new SB_NameCard_NameCardRenkeiJyokenDTO();
      d.bind(jyo);
      ds.add(d);
    }
    SB_NameCard_RenkeiSettingLcController.savesetting(JSON.serialize(ds),SB_NameCard_NameCardBasicSettingDTO.bind(bas), false);
    ses = [Select Id,Name,NameCardName__c,Operator__c,Value__c From  NameCardRenkeiJyoken__c ORDER BY CreatedDate DESC];
    System.debug(ses);
    System.assertEquals(ses[0].Value__c,'tttt');
    System.assertEquals(ses[0].Operator__c,'Does_not_match_next_character_string');
    System.assertEquals(ses[0].NameCardName__c,'Name');
  }

  // 連携条件新規テスト
  @isTest static void test_crete() {
    List<NameCardRenkeiJyoken__c> ses = [Select Id,Name,NameCardName__c,Operator__c,Value__c From  NameCardRenkeiJyoken__c];
    System.assertEquals(ses.size(),0);
    SB_NameCard_RenkeiSettingLcController.getallmap();
    NameCardBasicSetting__c aa = new NameCardBasicSetting__c ();
    aa.RenkeiContactMail__c = true;
    List<SB_NameCard_NameCardRenkeiJyokenDTO> ds = new List<SB_NameCard_NameCardRenkeiJyokenDTO>();
    for(NameCardRenkeiJyoken__c jyo : ses){
      SB_NameCard_NameCardRenkeiJyokenDTO d = new SB_NameCard_NameCardRenkeiJyokenDTO();
      d.bind(jyo);
      ds.add(d);
    }
    SB_NameCard_RenkeiSettingLcController.savesetting(JSON.serialize(ds),SB_NameCard_NameCardBasicSettingDTO.bind(aa), false);
    List<NameCardBasicSetting__c> sett = [Select Id,Name From NameCardBasicSetting__c ORDER BY LastModifiedDate DESC];
    System.assertEquals(sett.size(),1);
  }

  // 基本設定がなく，保存すると新規作成テスト
  @isTest static void test_BaseSetInsert() {
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    setting.Name = 'Test';
    setting.RenkeiContactMail__c = true;
    String backmessage1 = SB_NameCard_RenkeiSettingLcController.savesetting(JSON.serialize(new List<SB_NameCard_NameCardRenkeiJyokenDTO>()),SB_NameCard_NameCardBasicSettingDTO.bind(setting), false);
    SB_NameCard_RenkeiSettingLcController.SaveRenkeiData backmessage = new SB_NameCard_RenkeiSettingLcController.SaveRenkeiData();
    backmessage = (SB_NameCard_RenkeiSettingLcController.SaveRenkeiData)System.JSON.deserializeStrict(backmessage1,SB_NameCard_RenkeiSettingLcController.SaveRenkeiData .Class);
    List<NameCardBasicSetting__c> ssting = [Select Id,Name From  NameCardBasicSetting__c];
    System.assertEquals(ssting.size() , 1);
    System.assertEquals(backmessage.state , 'ok');
  }

  // 基本設定保存すると更新作成テスト
  @isTest static void test_BaseSetUpdate() {

    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    setting.Name = 'Test';
    setting.RenkeiContactMail__c = true;
    insert setting;
    setting = SB_NameCard_BasicSetting.getNameCardBasicSetting();
    String backmessage1 = SB_NameCard_RenkeiSettingLcController.savesetting(JSON.serialize(new List<SB_NameCard_NameCardRenkeiJyokenDTO>()),SB_NameCard_NameCardBasicSettingDTO.bind(setting), false);
    SB_NameCard_RenkeiSettingLcController.SaveRenkeiData backmessage = new SB_NameCard_RenkeiSettingLcController.SaveRenkeiData();
    backmessage = (SB_NameCard_RenkeiSettingLcController.SaveRenkeiData)System.JSON.deserializeStrict(backmessage1,SB_NameCard_RenkeiSettingLcController.SaveRenkeiData .Class);
    System.assertEquals(backmessage.state , 'ok');
  }

  // 連携条件新規保存エラー
  @isTest static void test_JyouKenErrorInsert() {
    List<NameCardRenkeiJyoken__c>jyous = new List<NameCardRenkeiJyoken__c>();
    jyous.add(new NameCardRenkeiJyoken__c());
    jyous.add(new NameCardRenkeiJyoken__c());
    List<SB_NameCard_NameCardRenkeiJyokenDTO> ds = new List<SB_NameCard_NameCardRenkeiJyokenDTO>();
    for(NameCardRenkeiJyoken__c jyo : jyous){
      SB_NameCard_NameCardRenkeiJyokenDTO d = new SB_NameCard_NameCardRenkeiJyokenDTO();
      d.bind(jyo);
      ds.add(d);
    }
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    setting.Name = 'Test';
    setting.RenkeiContactMail__c = true;
    String backmessage = SB_NameCard_RenkeiSettingLcController.savesetting(JSON.serialize(ds),SB_NameCard_NameCardBasicSettingDTO.bind(setting), false);
    SB_NameCard_RenkeiSettingLcController.SaveRenkeiData backmessage1 = new SB_NameCard_RenkeiSettingLcController.SaveRenkeiData();
    backmessage1 = (SB_NameCard_RenkeiSettingLcController.SaveRenkeiData)System.JSON.deserializeStrict(backmessage, SB_NameCard_RenkeiSettingLcController.SaveRenkeiData .Class);
    System.assertEquals(backmessage1.messages[0] , String.format(System.Label.SB_NC_SETTING_NoNCField_ErrorMessage,
                    new String[]{jyous[0].NameCardName__c}));
    System.assertEquals(backmessage1.state , 'ngs');
  }

  // 連携条件更新保存エラー
  @isTest static void test_JyouKenErrorUpdate() {
    setdate();
    setdate();
    List<NameCardRenkeiJyoken__c> ses = [Select Id,Name,NameCardName__c,Operator__c,Value__c,NameCardDataType__c,LastModifiedBy.Name,LastModifiedById,LastModifiedDate From  NameCardRenkeiJyoken__c];
    System.assertEquals(ses.size(),2);
    List<SB_NameCard_NameCardRenkeiJyokenDTO> ds = new List<SB_NameCard_NameCardRenkeiJyokenDTO>();
    for(NameCardRenkeiJyoken__c jyo : ses){
      SB_NameCard_NameCardRenkeiJyokenDTO d = new SB_NameCard_NameCardRenkeiJyokenDTO();
      d.bind(jyo);
      ds.add(d);
    }
    String backmessage1 = SB_NameCard_RenkeiSettingLcController.savesetting(JSON.serialize(ds),SB_NameCard_NameCardBasicSettingDTO.bind(SB_NameCard_BasicSetting.getNameCardBasicSetting()), false);
    SB_NameCard_RenkeiSettingLcController.SaveRenkeiData backmessage = new SB_NameCard_RenkeiSettingLcController.SaveRenkeiData();
    backmessage = (SB_NameCard_RenkeiSettingLcController.SaveRenkeiData)System.JSON.deserializeStrict(backmessage1,SB_NameCard_RenkeiSettingLcController.SaveRenkeiData .Class);
    System.assertEquals(backmessage.state , 'ok');
  }

  // 連携条件削除保存
  @isTest static void test_JyouKenDelete() {
    setdate();
    setdate();
    List<NameCardRenkeiJyoken__c> ses = [Select Id,Name,NameCardName__c,Operator__c,Value__c From  NameCardRenkeiJyoken__c];
    System.assertEquals(ses.size(),2);
    String backmessage1 = SB_NameCard_RenkeiSettingLcController.savesetting(JSON.serialize(new List<SB_NameCard_NameCardRenkeiJyokenDTO>()),SB_NameCard_NameCardBasicSettingDTO.bind(SB_NameCard_BasicSetting.getNameCardBasicSetting()), false);
    SB_NameCard_RenkeiSettingLcController.SaveRenkeiData backmessage = new SB_NameCard_RenkeiSettingLcController.SaveRenkeiData();
    backmessage = (SB_NameCard_RenkeiSettingLcController.SaveRenkeiData)System.JSON.deserializeStrict(backmessage1,SB_NameCard_RenkeiSettingLcController.SaveRenkeiData .Class);
    System.debug('aaaaaaaaaa' + backmessage.state);
    System.assertEquals(backmessage.state , 'ok');
  }

  // 基本設定レコードない場合のエラーメッセージ
  @isTest static void test_NoBasicSettingError() {
    List<NameCardRenkeiJyoken__c> ses = [Select Id,Name,NameCardName__c,Operator__c,Value__c From  NameCardRenkeiJyoken__c];
    System.assertEquals(ses.size(),0);
    String str = SB_NameCard_RenkeiSettingLcController.getallmap();

    SB_NameCard_RenkeiSettingLcController.RenkeiPageAllDate renkeiSetting = new SB_NameCard_RenkeiSettingLcController.RenkeiPageAllDate();
    renkeiSetting = (SB_NameCard_RenkeiSettingLcController.RenkeiPageAllDate)System.JSON.deserializeStrict(str, SB_NameCard_RenkeiSettingLcController.RenkeiPageAllDate .Class);
    System.assertEquals(renkeiSetting.warMsg.size(), 1);
    System.assertEquals(renkeiSetting.warMsg[0], System.Label.SB_NC_SETTING_ERROR_No_NameCardBasicSetting);
  }

  // 基本設定他ユーザ変更のエラーメッセージ
  @isTest static void test_OtherUserSaved() {
    NameCardBasicSetting__c bas = setdate();

    List<NameCardRenkeiJyoken__c> ses = [Select Id,Name,NameCardName__c,Operator__c,Value__c From  NameCardRenkeiJyoken__c];
    ses[0].NameCardName__c = 'test';
    ses[0].Operator__c = 'Does_not_match_next_character_string';
    ses[0].Value__c = 'tttt';
    List<SB_NameCard_NameCardRenkeiJyokenDTO> ds = new List<SB_NameCard_NameCardRenkeiJyokenDTO>();
    for(NameCardRenkeiJyoken__c jyo : ses){
      SB_NameCard_NameCardRenkeiJyokenDTO d = new SB_NameCard_NameCardRenkeiJyokenDTO();
      d.bind(jyo);
      ds.add(d);
    }

    Map<String,String> jyoukenMap = SB_NameCard_NameCardBasicSettingDTO.bind(bas);
    jyoukenMap.put('LastModifiedByDate', String.valueOf(Datetime.valueOf(Datetime.now().addDays(-1))));
    String saveDate = SB_NameCard_RenkeiSettingLcController.savesetting(JSON.serialize(ds), jyoukenMap, false);

    SB_NameCard_RenkeiSettingLcController.SaveRenkeiData renkeiSetting = new SB_NameCard_RenkeiSettingLcController.SaveRenkeiData();
    renkeiSetting = (SB_NameCard_RenkeiSettingLcController.SaveRenkeiData)System.JSON.deserializeStrict(saveDate, SB_NameCard_RenkeiSettingLcController.SaveRenkeiData .Class);
    System.assertEquals(renkeiSetting.state, 'warning');
    System.assertEquals(renkeiSetting.message, System.Label.SB_NC_SETTING_ERROR_OtherSection_Saved);
  }

  // 指定項目が存在しない項目場合Warningメッセージテスト
  // Triggerにはチェックがあるためデーターが作成できません
  // @isTest static void test_WrongSpecificItems() {
  //   NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
  //   setting.Name = 'testba';
  //   setting.RenkeiContactFirstName__c = true;
  //   setting.RenkeiContactLastName__c = true;
  //   setting.RenkeiAccountCompany__c = true;
  //   setting.RenkeiContactMail__c = true;
  //   setting.RenkeiAccountSite__c = true;
  //   setting.RenkeiAccountZipCode__c = true;
  //   // setting.RenkeiSpecificItems__c = 'TestXX__x';
  //   setting.RenkeiAccountAddressPref__c = true;
  //   setting.RenkeiAccountCity__c = true;
  //   setting.RenkeiAccountOverwrite__c = true;
  //   setting.RenkeiAccountNOExistCreateNew__c = true;
  //   insert setting;

  //   String str = SB_NameCard_RenkeiSettingLcController.getallmap();

  //   SB_NameCard_RenkeiSettingLcController.RenkeiPageAllDate renkeiSetting = new SB_NameCard_RenkeiSettingLcController.RenkeiPageAllDate();
  //   renkeiSetting = (SB_NameCard_RenkeiSettingLcController.RenkeiPageAllDate)System.JSON.deserializeStrict(str, SB_NameCard_RenkeiSettingLcController.RenkeiPageAllDate .Class);
  //   System.assertEquals(renkeiSetting.warMsg.size(), 1);
  //   System.assertEquals(renkeiSetting.warMsg[0], String.format(System.Label.SB_NC_SETTING_ERROR_Wrong_RenkeiSpecificItems, new String[]{setting.RenkeiSpecificItems__c}));
  // }


  // 指定項目が存在する項目場合Warningメッセージテスト
  @isTest static void test_RightSpecificItems() {
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    setting.Name = 'testba';
    setting.RenkeiContactFirstName__c = true;
    setting.RenkeiContactLastName__c = true;
    setting.RenkeiAccountCompany__c = true;
    setting.RenkeiContactMail__c = true;
    setting.RenkeiAccountSite__c = true;
    setting.RenkeiAccountZipCode__c = true;
    setting.RenkeiSpecificItems__c = 'Name';
    setting.RenkeiAccountAddressPref__c = true;
    setting.RenkeiAccountCity__c = true;
    setting.RenkeiAccountOverwrite__c = true;
    setting.RenkeiAccountNOExistCreateNew__c = true;
    insert setting;

    String str = SB_NameCard_RenkeiSettingLcController.getallmap();

    SB_NameCard_RenkeiSettingLcController.RenkeiPageAllDate renkeiSetting = new SB_NameCard_RenkeiSettingLcController.RenkeiPageAllDate();
    renkeiSetting = (SB_NameCard_RenkeiSettingLcController.RenkeiPageAllDate)System.JSON.deserializeStrict(str, SB_NameCard_RenkeiSettingLcController.RenkeiPageAllDate .Class);
    System.assertEquals(renkeiSetting.warMsg.size(), 0);
  }


}