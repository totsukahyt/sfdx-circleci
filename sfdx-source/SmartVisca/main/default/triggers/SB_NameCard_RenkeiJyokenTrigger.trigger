/**
 *
 * 名刺連携設定トリガ
 *
 *
 * Copyright (C) 2012-2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author gao
 *  History :
 *  @Version 2.1     2018.4.XX
 *
 **/
trigger SB_NameCard_RenkeiJyokenTrigger on NameCardRenkeiJyoken__c(after insert,after update,after Delete,after undelete,before insert,before update) {
  //連携設定を変更すれば基本設定の連携設定最終更新情報を更新されます
  SB_NameCard_RenkeiJyokenTriggerHandler handler = new SB_NameCard_RenkeiJyokenTriggerHandler();
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