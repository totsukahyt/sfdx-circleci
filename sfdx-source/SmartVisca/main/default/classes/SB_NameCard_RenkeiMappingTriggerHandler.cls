/**
 * SB_NameCard_RenkeiMappingTriggerHandler
 * 名刺連携マッピングトリガHandler
 * マッピングを新規及更新するたびに基本設定のマッピング最新更新者を更新します
 *
 * Copyright (C) 2012-2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author gao
 *  History :
 *  @Version 1.20      2017.3.XX
 *  @Version 1.21 kou 2017.10.xx  FLS  v1.21 for code scan
 *
 **/

public class SB_NameCard_RenkeiMappingTriggerHandler {
  public SB_NameCard_RenkeiMappingTriggerHandler(){

  }

  //連携マッピングを変更すれば基本設定の連携マッピング最終更新情報を更新されます
  public void updateLastModifyToBasicSetting(List<NameCardRenkeiMapping__c> newCard){
    List<NameCardBasicSetting__c> bsss = [Select Id From NameCardBasicSetting__c Order By CreatedDate ASC Limit 1];
    if(!bsss.isEmpty()){
      NameCardBasicSetting__c bss = bsss[0];
      if(!trigger.isDelete){
        if(newCard.size() > 0){
          List<user> userid = [Select Id,Name From User Where id=:newCard[0].LastModifiedById];
          if(userid.size() > 0 ){
            bss.MappingLastModifiedUser__c = userid[0].Id;
          }
          bss.MappingLastModifiedDateTime__c = newCard[0].LastModifiedDate;
        }
      } else {
        bss.MappingLastModifiedUser__c = UserInfo.getUserId();
        bss.MappingLastModifiedDateTime__c = Datetime.now();
      }
      SB_NameCard_CrudFls.supdate(new NameCardBasicSetting__c[]{bss}, true);  //  kou 2017.10.xx  FLS Update  v1.21 for code scan
    }
  }

  //連携マッピングをupdateするとく、所属の基本設定を設定します
  public void updateLookupToBasicSetting(List<NameCardRenkeiMapping__c> oldCard,List<NameCardRenkeiMapping__c> newCard){
    NameCardBasicSetting__c bss = SB_NameCard_BasicSetting.getNameCardBasicSetting();
    if(String.isNotBlank(bss.Id)){
      for(NameCardRenkeiMapping__c mapping : newCard){
        mapping.BasicSetting__c = bss.Id;
      }
    }
  }

  //連携マッピングをinsertするとく、所属の基本設定を設定します
  public void insertLookupToBasicSetting(List<NameCardRenkeiMapping__c> newCard){
    NameCardBasicSetting__c bss = SB_NameCard_BasicSetting.getNameCardBasicSetting();
    if(String.isNotBlank(bss.Id)){
      for(NameCardRenkeiMapping__c mapping : newCard){
        mapping.BasicSetting__c = bss.Id;
      }
    }
  }
}