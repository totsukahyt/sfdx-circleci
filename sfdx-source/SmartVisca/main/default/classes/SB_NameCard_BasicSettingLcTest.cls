/**
 *
 * SB_NameCard_BasicSettingLcControllerのテストクラス
 * 
 *
 * Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author mao
 *  @Version 1.20      2017.02.xx
 *  @Version 2.1       2018.04.XX  SV_DEV-876   連携設定条件に名刺項目に参照項目が選択できないことを変更
 *  @Version 2.1       2018.04.XX  SV_DEV-885 基本設定、連携条件設定、連携マッピングタブ切り替えの見直し
 *  @Version 2.1       2018.04.XX  SV_DEV-1106 SmartVisca基本設定レコードの一部項目の値が反転して表示される。
 *  @Version 2.4       2019.06.XX SV_DEV-XXXX SmartVisca 基本設定機能追加
 *
 **/

@isTest
private class SB_NameCard_BasicSettingLcTest {
  //データ作成
  public  static NameCardBasicSetting__c setData(){
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
    setting.RenkeiActive__c = true;
    insert setting;
    NameCardSettingValues__c sv = new NameCardSettingValues__c();
    sv.TextValue01__c  = 'Name';
    sv.Type__c = 'SaishinInherit';
    insert sv;
    return SB_NameCard_BasicSetting.getNameCardBasicSetting();
  }

  //基本設定検索テスト
  @isTest static void test_SelectBasicSetting() {
    NameCardBasicSetting__c setting = setData();
    String sett = SB_NameCard_BasicSettingLcController.getsetting();
    SB_NameCard_BasicSettingLcController.Basicdata lstFilters = new SB_NameCard_BasicSettingLcController.Basicdata();
    if(String.isNotBlank(sett)){
      lstFilters = (SB_NameCard_BasicSettingLcController.Basicdata )System.JSON.deserializeStrict(sett,SB_NameCard_BasicSettingLcController.Basicdata .Class);
    }
    System.assertEquals(setting.Id,lstFilters.data.get('Id'));
  }

  //基本設定の新規作成
  @isTest static void test_CreateBasicSetting() {
    String sett = SB_NameCard_BasicSettingLcController.getsetting();
    SB_NameCard_BasicSettingLcController.Basicdata lstFilters = new SB_NameCard_BasicSettingLcController.Basicdata();
    if(String.isNotBlank(sett)){
      lstFilters = (SB_NameCard_BasicSettingLcController.Basicdata )System.JSON.deserializeStrict(sett,SB_NameCard_BasicSettingLcController.Basicdata .Class);
    }
    System.assertEquals(String.isBlank(lstFilters.data.get('Id')), true);
    System.assertEquals(lstFilters.message, System.Label.SB_NC_SETTING_ERROR_No_NameCardBasicSetting);
  }

  //基本設定の更新
  @isTest static void test_UpdateBasicSetting() {
    NameCardBasicSetting__c setting = setData();
    setting.Name = 'TestName';
    setting.RenkeiActive__c = false;
    Map<String,String> dto = SB_NameCard_NameCardBasicSettingDTO.bindSimple(setting);
    System.debug(dto);
    String sett = SB_NameCard_BasicSettingLcController.savesettingcu(dto,new List<String>{'Name','Id'});
    SB_NameCard_BasicSettingLcController.Basicdata lstFilters = new SB_NameCard_BasicSettingLcController.Basicdata();
    if(String.isNotBlank(sett)){
      lstFilters = (SB_NameCard_BasicSettingLcController.Basicdata )System.JSON.deserializeStrict(sett,SB_NameCard_BasicSettingLcController.Basicdata .Class);
    }
    System.assertEquals(lstFilters.state,'ok');
    List<NameCardBasicSetting__c> sets = [Select Id,Name,RenkeiActive__c From NameCardBasicSetting__c];
    System.assertEquals(sets.size(),1);
    System.assertEquals(sets[0].RenkeiActive__c,false);
  }

  //基本設定の更新 (値が設定してない)
  @isTest static void test_BasicSetting() {
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    Map<String,String> dto = SB_NameCard_NameCardBasicSettingDTO.bindSimple(setting);
    String sett = SB_NameCard_BasicSettingLcController.savesettingcu(dto,new List<String>{'Name','Id'});
    SB_NameCard_BasicSettingLcController.Basicdata lstFilters = new SB_NameCard_BasicSettingLcController.Basicdata();
    if(String.isNotBlank(sett)){
      lstFilters = (SB_NameCard_BasicSettingLcController.Basicdata )System.JSON.deserializeStrict(sett,SB_NameCard_BasicSettingLcController.Basicdata .Class);
    }
    System.assertEquals(lstFilters.state,'ok');
  }

  // 他のユーザ保存
  @isTest static void test_ErrorBasicSettingOtherUserSaved() {
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    Map<String,String> dto = SB_NameCard_NameCardBasicSettingDTO.bindSimple(setting);
    dto.put('LastModifiedByDate', String.valueOf(Datetime.valueOf(Datetime.now().addDays(-1))));
    String sett = SB_NameCard_BasicSettingLcController.savesettingcu(dto,new List<String>{'Name','Id'});
    SB_NameCard_BasicSettingLcController.Basicdata lstFilters = new SB_NameCard_BasicSettingLcController.Basicdata();
    //lstFilters.setCampaignStatus();
    if(String.isNotBlank(sett)){
      lstFilters = (SB_NameCard_BasicSettingLcController.Basicdata )System.JSON.deserializeStrict(sett,SB_NameCard_BasicSettingLcController.Basicdata .Class);
    }
    System.assertEquals(lstFilters.state,'warning');
    System.assertEquals(lstFilters.message, System.Label.SB_NC_SETTING_ERROR_OtherSection_Saved);
  }
}