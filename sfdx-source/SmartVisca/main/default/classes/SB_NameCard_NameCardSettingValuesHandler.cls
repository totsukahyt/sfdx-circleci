/**
 *
 *  SB_NameCard_NameCardSettingValuesHandler 名刺設定値トリガHandler
 *
 *
 *  Copyright (C) 2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author gao
 *  @Version 2.1      2018.04.xx SV_DEV-865 名刺基本設定オブジェクトのトリガを作って不正な値で保存されたらエラーにする。
 *
 **/


public with sharing class SB_NameCard_NameCardSettingValuesHandler {

  // 項目APIを保存する項目
  // TextValue01__c テキスト値01
  private final Set<String> fieldCheckSet = new Set<String> {'TextValue01__c'};

  public SB_NameCard_NameCardSettingValuesHandler() {

  }

  /**
   * @description beforeInsert実行メソッド
   * @param newList Trigger.new
   * @return
  */
  public void beforeInsert(List<NameCardSettingValues__c> newList) {
    // 念の為ここも判断
    if (Trigger.isBefore && Trigger.isInsert) {
      beforeCheck(newList);
    }
  }

  /**
   * @description beforeUpdate実行メソッド
   * @param newList Trigger.new
   * @return
  */
  public void beforeUpdate(List<NameCardSettingValues__c> newList) {
    // 念の為ここも判断
    if (Trigger.isBefore && Trigger.isUpdate) {
      beforeCheck(newList);
    }
  }

  /**
   * @description 値が正しいがどうかチェックメソッド
   * @param newList Trigger.new
   * @return
  */
  private void beforeCheck(List<NameCardSettingValues__c> newList) {
    // 項目チェック
    fieldCheck(newList);
  }

  /**
   * @description 項目APIに関するチェックメソッド
   * @param newList Trigger.new
   * @return
  */
  private void fieldCheck(List<NameCardSettingValues__c> newList) {
    Map<String, Schema.SObjectField> nameCardFieldsMap = NameCard__c.getSObjectType().getDescribe().fields.getMap();
    for (NameCardSettingValues__c basicSetting : newList) {
      for (String field : fieldCheckSet) {
        if (String.isNotBlank((String)basicSetting.get(field))) {
          String fieldAPI = (String)basicSetting.get(field);
          if (!nameCardFieldsMap.containsKey(fieldAPI)) {
            basicSetting.addError(String.format(System.Label.SB_NC_MAPPING_Ingert_ErrorMessage, new String[]{fieldAPI}));
          }
        }
      }
    }
  }
}