/**
 *
 *  SB_NameCard_NameCardBasicSettingHandler 基本設定トリガHandler
 *
 *
 *  Copyright (C) 2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author gao
 *  @Version 2.1      2018.04.xx SV_DEV-865 名刺基本設定オブジェクトのトリガを作って不正な値で保存されたらエラーにする。
 *  @Version 2.5.4 sawano 2020.08.xx PRODUCT-594 新規Salesforce組織にSVインストール後、リード拡張パッケージをインストールすると、インストールがエラー終了してインストールできないので、対応する。
 *
 **/

trigger SB_NameCard_NameCardBasicSettingTrigger on NameCardBasicSetting__c(before insert, before update) {
  // Handler インスタンス作成
  SB_NameCard_NameCardBasicSettingHandler handler = new SB_NameCard_NameCardBasicSettingHandler();
  // beforeの場合実行メソッド
  if (Trigger.isBefore) {
    // before insertの場合実行メソッド
    if (Trigger.isInsert) {
      handler.beforeInsert(Trigger.new);
    }
    // before updateの場合実行メソッド
    if (Trigger.isUpdate) {
      handler.beforeUpdate(Trigger.new, Trigger.oldMap);
    }
  }
}