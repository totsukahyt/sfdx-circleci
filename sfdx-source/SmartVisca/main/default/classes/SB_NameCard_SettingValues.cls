/**
 *
 * SB_NameCard_SettingValues
 *  名刺設定値のレコードを参照する用のクラス with sharing で動かす（共有設定に依存する）ためにクラスを分けます。
 *
 * Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2017.01.xx
 *
 **/
public with sharing class SB_NameCard_SettingValues {

  // 最新の名刺へ 引継ぐ項目 のリスト
  public static List<NameCardSettingValues__c> saishinInheritFields {
    get {
      if (saishinInheritFields == null) {
        Schema.DescribeSObjectResult sobjResult = NameCardSettingValues__c.getSObjectType().getDescribe();
        if (sobjResult.isAccessible()) {
          saishinInheritFields = [Select Id, Name, TextValue01__c From NameCardSettingValues__c Where Type__c = 'SaishinInherit'];
        }
        else {
          saishinInheritFields = new List<NameCardSettingValues__c>();
        }
      }
      return saishinInheritFields;
    }
    private set;
  }
}