/**
 * SB_NameCard_RenkeiMappingTrigger
 * 名刺連携マッピングトリガ
 *
 *
 * Copyright (C) 2012-2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author gao
 *  History :
 *  @Version 1.20      2017.3.xx
 *
 **/

trigger SB_NameCard_RenkeiMappingTrigger on NameCardRenkeiMapping__c (after insert,after update,after Delete,after undelete,before insert,before update){

  //連携マッピングを変更すれば基本設定の連携マッピング最終更新情報を更新されます
  SB_NameCard_RenkeiMappingTriggerHandler handler = new SB_NameCard_RenkeiMappingTriggerHandler();
  if (trigger.isAfter && (trigger.isInsert || trigger.isUpdate || trigger.isDelete || trigger.isUndelete)) {
    handler.updateLastModifyToBasicSetting(trigger.new);
  }

  if (trigger.isBefore) {
    if (trigger.isInsert) {
      handler.insertLookupToBasicSetting(trigger.new);
    } else if (trigger.isUpdate) {
      handler.updateLookupToBasicSetting(trigger.old,trigger.new);
    }
  }
}