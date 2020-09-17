/**
 *
 * 連携条件を変化すれば基本設定の最新更新者と更新日を設定
 *
 *
 * Copyright (C) 2012-2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author gao
 *  History :
 *  @Version 2.1     2018.8.XX SV_DEV-864 トリガ SB_NameCard_RenkeiSettingTrigger とハンドラーSB_NameCard_RenkeiSettingTriggerHandler の命名方法が変なので治す
 *
 **/

public class SB_NameCard_RenkeiJyokenTriggerHandler {
  public SB_NameCard_RenkeiJyokenTriggerHandler(){

  }

  //連携マッピングを変更すれば基本設定の連携マッピング最終更新情報を更新されます
  public void updateLastModifyToBasicSetting(List<NameCardRenkeiJyoken__c> newCards){
    //  kou 2017.10.xx  Queries With No Where Or Limit Clause  v1.21 for code scan
    List<NameCardBasicSetting__c> bss = [Select Id,Name From NameCardBasicSetting__c ORDER BY CreatedDate ASC Limit 1];
    if(bss.size() > 0){
      if(!trigger.isDelete){
        if(newCards.size() > 0){
          List<user> userid = [Select Id,Name From User Where id=:newCards[0].LastModifiedById];
          if(userid.size() > 0 ){
            bss[0].MConditionLastModifiedUser__c = userid[0].Id;
          }
          bss[0].MConditionLastModifiedDateTime__c = newCards[0].LastModifiedDate;
        }
      } else {
         bss[0].MConditionLastModifiedUser__c = UserInfo.getUserId();
         bss[0].MConditionLastModifiedDateTime__c = Datetime.now();
      }
       SB_NameCard_CrudFls.supdate(bss, true);  //  kou 2017.10.xx  FLS Update  v1.21 for code scan
    }
  }

  //連携マッピングをupdateするとく、所属の基本設定を設定します
  public void updateLookupToBasicSetting(List<NameCardRenkeiJyoken__c> oldCards,List<NameCardRenkeiJyoken__c> newCards){
    //  kou 2017.10.xx  Queries With No Where Or Limit Clause  v1.21 for code scan
    NameCardBasicSetting__c bss = SB_NameCard_BasicSetting.getNameCardBasicSetting();
    if(String.isNotBlank(bss.Id)){
      for(NameCardRenkeiJyoken__c setting : newCards){
        setting.BasicSetting__c = bss.Id;
      }
    }
  }

  //連携マッピングをinsertするとく、所属の基本設定を設定します
  public void insertLookupToBasicSetting(List<NameCardRenkeiJyoken__c> newCards){
    //  kou 2017.10.xx  Queries With No Where Or Limit Clause  v1.21 for code scan
    NameCardBasicSetting__c bss = SB_NameCard_BasicSetting.getNameCardBasicSetting();
    if(String.isNotBlank(bss.Id)){
      for(NameCardRenkeiJyoken__c setting : newCards){
        setting.BasicSetting__c = bss.Id;
      }
    }
  }
}