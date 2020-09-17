/**
 *
 * SB_NameCard_UserSettingTest
 * SB_NameCard_UserSetting  のテストクラス 
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2019.06.xx
 *
 **/
@isTest
private class SB_NameCard_UserSettingTest {

  // ユーザの設定レコードがないので、カスタム設定を元に作る。カスタム設定と値が一致してることを確認
  @isTest
  static void test_getNameCardUserSetting_create() {
    insert SB_NameCard_UserSetting.userConfig;
    NameCardUserSetting__c setting = SB_NameCard_UserSetting.getNameCardUserSetting();
    // Map<String, Schema.SObjectField > fields = NameCardUserSetting__c.getSObjectType().getDescribe().fields.getMap();
    for (String f : SB_NameCard_UserSetting.settingFields) {
      System.assertEquals(SB_NameCard_UserSetting.userConfig.get(f), setting.get(f));
    }
  }

  // ユーザの設定レコードが既存。既存のレコードと値が一致してることを確認、
  @isTest
  static void test_getNameCardUserSetting_exist() {
    NameCardUserSetting__c rec = new NameCardUserSetting__c();
    rec.User__c = UserInfo.getUserId();
    rec.SvLatestListView__c= 1;   // SmartVisca:最後に開いたリスト
    rec.SvInitialListView__c = 0; // SmartVisca:初期リスト
    rec.SvcRepeatMemo__c = false; //  SmartViscaカメラ:メモを引き継ぐ SvcRepeatMemo__c	チェックボックス
    rec.SvcShadeFilter__c = false; //  SmartViscaカメラ:陰影を除去する SvcShadeFilter__c	チェックボックス
    rec.SvcNoiseFilter__c = false; //  SmartViscaカメラ:陰影除去後のゴミを取る SvcNoiseFilter__c	チェックボックス
    rec.SvcGabageFilter__c = false; //  SmartViscaカメラ:陰影除去後、さらにゴミを取る SvcGabageFilter__c	チェックボックス
    // rec.SvcImageSize__c = 1000; //  SmartViscaカメラ:画像サイズ SvcImageSize__c	数値(18、0)
    rec.SvcImageTransform__c = false; //  SmartViscaカメラ:画像補正する SvcImageTransform__c	チェックボックス
    // rec.SvcInputImageSize__c = 4000; //  SmartViscaカメラ:画像補正に使う長辺のサイズ SvcInputImageSize__c	数値(18、0)
    rec.SvcConfirmTransform__c = false; //  SmartViscaカメラ:画像補正の結果を確認する SvcConfirmTransform__c	チェックボックス
    rec.SvcShowTranslateFailure__c = false; //  SmartViscaカメラ:画像補正の失敗を表示する SvcShowTranslateFailure__c	チェックボックス
    rec.SvcFreehandMemo__c = false; //  SmartViscaカメラ:手書きメモをデジタル化する（表面のみ） SvcFreehandMemo__c	チェックボックス
    rec.SvcLastListName__c = '前回のリスト名'; //  SmartViscaカメラ:前回のリスト名 SvcLastListName__c	テキスト(255)
    rec.SvcFrontOnly__c = false; //  SmartViscaカメラ:表面のみをデジタル化する SvcFrontOnly__c	チェックボックス
    rec.SvcKeepListName__c = false; //  SmartViscaカメラ:名刺リスト名を覚えておく SvcKeepListName__c	チェックボックス
    rec.SvcRepeatExchangeDate__c = false; //  SmartViscaカメラ:名刺交換日を引き継ぐ SvcRepeatExchangeDate__c	チェックボックス
    rec.SvcDoubleSide__c = false; //  SmartViscaカメラ:裏面も撮る SvcDoubleSide__c	チェックボックス
    rec.SvcGeoLocation__c = false; //  SmartViscaカメラ:位置情報を送信履歴に残す(廃止) SvcGeoLocation__c	チェックボックス
    insert rec;
    NameCardUserSetting__c setting = SB_NameCard_UserSetting.getNameCardUserSetting();
    // Map<String, Schema.SObjectField > fields = NameCardUserSetting__c.getSObjectType().getDescribe().fields.getMap();
    for (String f : SB_NameCard_UserSetting.settingFields) {
      System.assertEquals(rec.get(f), setting.get(f));
    }
  }

  @isTest
  static void test_saveSetting_create() {
    // 保存用データ
    Map<String, Object> values = new Map<String, Object>();
    values.put('svcRepeatMemo', true); //  SmartViscaカメラ:メモを引き継ぐ SvcRepeatMemo__c	チェックボックス
    values.put('svcShadeFilter', true); //  SmartViscaカメラ:陰影を除去する SvcShadeFilter__c	チェックボックス
    values.put('svcNoiseFilter', true); //  SmartViscaカメラ:陰影除去後のゴミを取る SvcNoiseFilter__c	チェックボックス
    values.put('svcGabageFilter', true); //  SmartViscaカメラ:陰影除去後、さらにゴミを取る SvcGabageFilter__c	チェックボックス
    // values.put('svcImageSize', 10000); //  SmartViscaカメラ:画像サイズ SvcImageSize__c	数値(18、0)
    values.put('svcImageTransform', true); //  SmartViscaカメラ:画像補正する SvcImageTransform__c	チェックボックス
    // values.put('svcInputImageSize', 40000); //  SmartViscaカメラ:画像補正に使う長辺のサイズ SvcInputImageSize__c	数値(18、0)
    values.put('svcConfirmTransform', true); //  SmartViscaカメラ:画像補正の結果を確認する SvcConfirmTransform__c	チェックボックス
    values.put('svcShowTranslateFailure', true); //  SmartViscaカメラ:画像補正の失敗を表示する SvcShowTranslateFailure__c	チェックボックス
    values.put('svcFreehandMemo', true); //  SmartViscaカメラ:手書きメモをデジタル化する（表面のみ） SvcFreehandMemo__c	チェックボックス
    values.put('svcLastListName', '前回のリスト名1'); //  SmartViscaカメラ:前回のリスト名 SvcLastListName__c	テキスト(255)
    values.put('svcFrontOnly', true); //  SmartViscaカメラ:表面のみをデジタル化する SvcFrontOnly__c	チェックボックス
    values.put('svcKeepListName', true); //  SmartViscaカメラ:名刺リスト名を覚えておく SvcKeepListName__c	チェックボックス
    values.put('svcRepeatExchangeDate', true); //  SmartViscaカメラ:名刺交換日を引き継ぐ SvcRepeatExchangeDate__c	チェックボックス
    values.put('svcDoubleSide', true); //  SmartViscaカメラ:裏面も撮る SvcDoubleSide__c	チェックボックス    
    SB_NameCard_UserSetting.saveSetting(values);
    NameCardUserSetting__c setting = SB_NameCard_UserSetting.getNameCardUserSetting();
    System.assertEquals(true, setting.SvcRepeatMemo__c); //  SmartViscaカメラ:メモを引き継ぐ SvcRepeatMemo__c	チェックボックス
    System.assertEquals(true, setting.SvcShadeFilter__c); //  SmartViscaカメラ:陰影を除去する SvcShadeFilter__c	チェックボックス
    System.assertEquals(true, setting.SvcNoiseFilter__c); //  SmartViscaカメラ:陰影除去後のゴミを取る SvcNoiseFilter__c	チェックボックス
    System.assertEquals(true, setting.SvcGabageFilter__c); //  SmartViscaカメラ:陰影除去後、さらにゴミを取る SvcGabageFilter__c	チェックボックス
    // System.assertEquals(10000, setting.SvcImageSize__c); //  SmartViscaカメラ:画像サイズ SvcImageSize__c	数値(18、0)
    System.assertEquals(true, setting.SvcImageTransform__c); //  SmartViscaカメラ:画像補正する SvcImageTransform__c	チェックボックス
    // System.assertEquals(40000, setting.SvcInputImageSize__c); //  SmartViscaカメラ:画像補正に使う長辺のサイズ SvcInputImageSize__c	数値(18、0)
    System.assertEquals(true, setting.SvcConfirmTransform__c); //  SmartViscaカメラ:画像補正の結果を確認する SvcConfirmTransform__c	チェックボックス
    System.assertEquals(true, setting.SvcShowTranslateFailure__c); //  SmartViscaカメラ:画像補正の失敗を表示する SvcShowTranslateFailure__c	チェックボックス
    System.assertEquals(true, setting.SvcFreehandMemo__c); //  SmartViscaカメラ:手書きメモをデジタル化する（表面のみ） SvcFreehandMemo__c	チェックボックス
    System.assertEquals('前回のリスト名1', setting.SvcLastListName__c); //  SmartViscaカメラ:前回のリスト名 SvcLastListName__c	テキスト(255)
    System.assertEquals(true, setting.SvcFrontOnly__c); //  SmartViscaカメラ:表面のみをデジタル化する SvcFrontOnly__c	チェックボックス
    System.assertEquals(true, setting.SvcKeepListName__c); //  SmartViscaカメラ:名刺リスト名を覚えておく SvcKeepListName__c	チェックボックス
    System.assertEquals(true, setting.SvcRepeatExchangeDate__c); //  SmartViscaカメラ:名刺交換日を引き継ぐ SvcRepeatExchangeDate__c	チェックボックス
    System.assertEquals(true, setting.SvcDoubleSide__c); //  SmartViscaカメラ:裏面も撮る SvcDoubleSide__c	チェックボックス
  }
  
  @isTest
  static void test_saveSetting_update() {
    NameCardUserSetting__c rec = new NameCardUserSetting__c();
    rec.User__c = UserInfo.getUserId();
    rec.SvcRepeatMemo__c = false; //  SmartViscaカメラ:メモを引き継ぐ SvcRepeatMemo__c	チェックボックス
    rec.SvcShadeFilter__c = false; //  SmartViscaカメラ:陰影を除去する SvcShadeFilter__c	チェックボックス
    rec.SvcNoiseFilter__c = false; //  SmartViscaカメラ:陰影除去後のゴミを取る SvcNoiseFilter__c	チェックボックス
    rec.SvcGabageFilter__c = false; //  SmartViscaカメラ:陰影除去後、さらにゴミを取る SvcGabageFilter__c	チェックボックス
    // rec.SvcImageSize__c = 1000; //  SmartViscaカメラ:画像サイズ SvcImageSize__c	数値(18、0)
    rec.SvcImageTransform__c = false; //  SmartViscaカメラ:画像補正する SvcImageTransform__c	チェックボックス
    // rec.SvcInputImageSize__c = 4000; //  SmartViscaカメラ:画像補正に使う長辺のサイズ SvcInputImageSize__c	数値(18、0)
    rec.SvcConfirmTransform__c = false; //  SmartViscaカメラ:画像補正の結果を確認する SvcConfirmTransform__c	チェックボックス
    rec.SvcShowTranslateFailure__c = false; //  SmartViscaカメラ:画像補正の失敗を表示する SvcShowTranslateFailure__c	チェックボックス
    rec.SvcFreehandMemo__c = false; //  SmartViscaカメラ:手書きメモをデジタル化する（表面のみ） SvcFreehandMemo__c	チェックボックス
    rec.SvcLastListName__c = '前回のリスト名'; //  SmartViscaカメラ:前回のリスト名 SvcLastListName__c	テキスト(255)
    rec.SvcFrontOnly__c = false; //  SmartViscaカメラ:表面のみをデジタル化する SvcFrontOnly__c	チェックボックス
    rec.SvcKeepListName__c = false; //  SmartViscaカメラ:名刺リスト名を覚えておく SvcKeepListName__c	チェックボックス
    rec.SvcRepeatExchangeDate__c = false; //  SmartViscaカメラ:名刺交換日を引き継ぐ SvcRepeatExchangeDate__c	チェックボックス
    rec.SvcDoubleSide__c = false; //  SmartViscaカメラ:裏面も撮る SvcDoubleSide__c	チェックボックス
    insert rec;
    NameCardUserSetting__c setting = SB_NameCard_UserSetting.getNameCardUserSetting();
    // 更新用データ
    Map<String, Object> values = new Map<String, Object>();
    values.put('svcRepeatMemo', true); //  SmartViscaカメラ:メモを引き継ぐ SvcRepeatMemo__c	チェックボックス
    values.put('svcShadeFilter', true); //  SmartViscaカメラ:陰影を除去する SvcShadeFilter__c	チェックボックス
    values.put('svcNoiseFilter', true); //  SmartViscaカメラ:陰影除去後のゴミを取る SvcNoiseFilter__c	チェックボックス
    values.put('svcGabageFilter', true); //  SmartViscaカメラ:陰影除去後、さらにゴミを取る SvcGabageFilter__c	チェックボックス
    // values.put('svcImageSize', 10000); //  SmartViscaカメラ:画像サイズ SvcImageSize__c	数値(18、0)
    values.put('svcImageTransform', true); //  SmartViscaカメラ:画像補正する SvcImageTransform__c	チェックボックス
    // values.put('svcInputImageSize', 40000); //  SmartViscaカメラ:画像補正に使う長辺のサイズ SvcInputImageSize__c	数値(18、0)
    values.put('svcConfirmTransform', true); //  SmartViscaカメラ:画像補正の結果を確認する SvcConfirmTransform__c	チェックボックス
    values.put('svcShowTranslateFailure', true); //  SmartViscaカメラ:画像補正の失敗を表示する SvcShowTranslateFailure__c	チェックボックス
    values.put('svcFreehandMemo', true); //  SmartViscaカメラ:手書きメモをデジタル化する（表面のみ） SvcFreehandMemo__c	チェックボックス
    values.put('svcLastListName', '前回のリスト名1'); //  SmartViscaカメラ:前回のリスト名 SvcLastListName__c	テキスト(255)
    values.put('svcFrontOnly', true); //  SmartViscaカメラ:表面のみをデジタル化する SvcFrontOnly__c	チェックボックス
    values.put('svcKeepListName', true); //  SmartViscaカメラ:名刺リスト名を覚えておく SvcKeepListName__c	チェックボックス
    values.put('svcRepeatExchangeDate', true); //  SmartViscaカメラ:名刺交換日を引き継ぐ SvcRepeatExchangeDate__c	チェックボックス
    values.put('svcDoubleSide', true); //  SmartViscaカメラ:裏面も撮る SvcDoubleSide__c	チェックボックス    
    SB_NameCard_UserSetting.saveSetting(values);
    setting = null;   // 一旦クリア
    setting = SB_NameCard_UserSetting.getNameCardUserSetting(); // 取り直す
    System.assertEquals(true, setting.SvcRepeatMemo__c); //  SmartViscaカメラ:メモを引き継ぐ SvcRepeatMemo__c	チェックボックス
    System.assertEquals(true, setting.SvcShadeFilter__c); //  SmartViscaカメラ:陰影を除去する SvcShadeFilter__c	チェックボックス
    System.assertEquals(true, setting.SvcNoiseFilter__c); //  SmartViscaカメラ:陰影除去後のゴミを取る SvcNoiseFilter__c	チェックボックス
    System.assertEquals(true, setting.SvcGabageFilter__c); //  SmartViscaカメラ:陰影除去後、さらにゴミを取る SvcGabageFilter__c	チェックボックス
    // System.assertEquals(10000, setting.SvcImageSize__c); //  SmartViscaカメラ:画像サイズ SvcImageSize__c	数値(18、0)
    System.assertEquals(true, setting.SvcImageTransform__c); //  SmartViscaカメラ:画像補正する SvcImageTransform__c	チェックボックス
    // System.assertEquals(40000, setting.SvcInputImageSize__c); //  SmartViscaカメラ:画像補正に使う長辺のサイズ SvcInputImageSize__c	数値(18、0)
    System.assertEquals(true, setting.SvcConfirmTransform__c); //  SmartViscaカメラ:画像補正の結果を確認する SvcConfirmTransform__c	チェックボックス
    System.assertEquals(true, setting.SvcShowTranslateFailure__c); //  SmartViscaカメラ:画像補正の失敗を表示する SvcShowTranslateFailure__c	チェックボックス
    System.assertEquals(true, setting.SvcFreehandMemo__c); //  SmartViscaカメラ:手書きメモをデジタル化する（表面のみ） SvcFreehandMemo__c	チェックボックス
    System.assertEquals('前回のリスト名1', setting.SvcLastListName__c); //  SmartViscaカメラ:前回のリスト名 SvcLastListName__c	テキスト(255)
    System.assertEquals(true, setting.SvcFrontOnly__c); //  SmartViscaカメラ:表面のみをデジタル化する SvcFrontOnly__c	チェックボックス
    System.assertEquals(true, setting.SvcKeepListName__c); //  SmartViscaカメラ:名刺リスト名を覚えておく SvcKeepListName__c	チェックボックス
    System.assertEquals(true, setting.SvcRepeatExchangeDate__c); //  SmartViscaカメラ:名刺交換日を引き継ぐ SvcRepeatExchangeDate__c	チェックボックス
    System.assertEquals(true, setting.SvcDoubleSide__c); //  SmartViscaカメラ:裏面も撮る SvcDoubleSide__c	チェックボックス
   }

  // SSmartViscaカメラでユーザによる設定変更を不可にする。 が true のときは、所得した設定値は、レコードの値でなく、カスタム設定の値と等しい
  @isTest
  static void test_getNameCardUserSetting_DisableUserConfig_true() {
    // 「SSmartViscaカメラでユーザによる設定変更を不可にする。」 が true のとき
    SB_NameCard_Util.smartViscaConfig.SCameraDisableUserConfig__c = true; 
    // カスタム設定「SmartViscaユーザ設定」の
    SmartViscaUserConfig__c userConfig = new SmartViscaUserConfig__c();
    userConfig.SvLatestListView__c =  1;  // SmartVisca:最後に開いたリスト
    userConfig.SvInitialListView__c =  0;  //SmartVisca:初期リスト
    userConfig.Development__c =  false;// Development 開発モード
    userConfig.PackageVersion__c =  null ;   // PackageVersion
    userConfig.SvcRepeatMemo__c =  true;   // メモを引き継ぐ
    userConfig.SvcGeoLocation__c =  false;   // 位置情報を送信履歴に残す
    userConfig.SvcFreehandMemo__c =  false;   // 手書きメモをデジタル化する（表面のみ）
    // userConfig.SvcLastListName__c =  null;   // 前回のリスト名
    userConfig.SvcFrontOnly__c =  false;   // 表面のみをデジタル化する
    userConfig.SvcKeepListName__c =  true;   // 名刺リスト名を覚えておく
    userConfig.SvcRepeatExchangeDate__c =  true;   // 名刺交換日を引き継ぐ
    userConfig.SvcDoubleSide__c =  true;  // 両面撮影
    // 画像補正関連
    userConfig.SvcImageTransform__c =  true;   // 画像補正する
    userConfig.SvcConfirmTransform__c =  true;   // 画像補正の結果を確認する
    userConfig.SvcShadeFilter__c =  false;   // 陰影を除去する
    userConfig.SvcNoiseFilter__c =  false;   // ゴマ塩ノイズ除去
    userConfig.SvcGabageFilter__c =  false;   // ゴミ除去
    userConfig.SvcShowTranslateFailure__c =  false;   // 画像補正の失敗を表示する
    // userConfig.SvcImageSize__c =  600;   // 画像サイズ
    // userConfig.SvcInputImageSize__c =  1200;   // 画像補正に使う長辺のサイズ
    insert userConfig;

    NameCardUserSetting__c rec = new NameCardUserSetting__c();
    rec.User__c = UserInfo.getUserId();
    rec.SvLatestListView__c= 2;   // SmartVisca:最後に開いたリスト
    rec.SvInitialListView__c = 0; // SmartVisca:初期リスト
    rec.SvcRepeatMemo__c = true; //  SmartViscaカメラ:メモを引き継ぐ SvcRepeatMemo__c	チェックボックス
    rec.SvcShadeFilter__c = true; //  SmartViscaカメラ:陰影を除去する SvcShadeFilter__c	チェックボックス
    rec.SvcNoiseFilter__c = true; //  SmartViscaカメラ:陰影除去後のゴミを取る SvcNoiseFilter__c	チェックボックス
    rec.SvcGabageFilter__c = true; //  SmartViscaカメラ:陰影除去後、さらにゴミを取る SvcGabageFilter__c	チェックボックス
    // rec.SvcImageSize__c = 1000; //  SmartViscaカメラ:画像サイズ SvcImageSize__c	数値(18、0)
    rec.SvcImageTransform__c = true; //  SmartViscaカメラ:画像補正する SvcImageTransform__c	チェックボックス
    // rec.SvcInputImageSize__c = 4000; //  SmartViscaカメラ:画像補正に使う長辺のサイズ SvcInputImageSize__c	数値(18、0)
    rec.SvcConfirmTransform__c = true; //  SmartViscaカメラ:画像補正の結果を確認する SvcConfirmTransform__c	チェックボックス
    rec.SvcShowTranslateFailure__c = true; //  SmartViscaカメラ:画像補正の失敗を表示する SvcShowTranslateFailure__c	チェックボックス
    rec.SvcFreehandMemo__c = true; //  SmartViscaカメラ:手書きメモをデジタル化する（表面のみ） SvcFreehandMemo__c	チェックボックス
    rec.SvcLastListName__c = '前回のリスト名'; //  SmartViscaカメラ:前回のリスト名 SvcLastListName__c	テキスト(255)
    rec.SvcFrontOnly__c = true; //  SmartViscaカメラ:表面のみをデジタル化する SvcFrontOnly__c	チェックボックス
    rec.SvcKeepListName__c = true; //  SmartViscaカメラ:名刺リスト名を覚えておく SvcKeepListName__c	チェックボックス
    rec.SvcRepeatExchangeDate__c = true; //  SmartViscaカメラ:名刺交換日を引き継ぐ SvcRepeatExchangeDate__c	チェックボックス
    rec.SvcDoubleSide__c = true; //  SmartViscaカメラ:裏面も撮る SvcDoubleSide__c	チェックボックス
    insert rec;

    NameCardUserSetting__c setting = SB_NameCard_UserSetting.getNameCardUserSetting();
    String nsx = SB_NameCard_Util.getNamespacePrefix_x();
    // 所得した設定値は、カスタム設定の値と全て一致、レコードの値と不一致がある
    for (String f : SB_NameCard_UserSetting.settingFields) {
      if (SB_NameCard_UserSetting.USER_SPECIFIC_FIELDS.contains(f.removeStart(nsx).toLowerCase())) {
        System.assertEquals(rec.get(f), setting.get(f));
      }
      else {
        System.assertEquals(userConfig.get(f), setting.get(f));
      }
    }
  }
    
  // SSmartViscaカメラでユーザによる設定変更を不可にする。 が false のときは、所得した設定値は、レコードの値でなく、カスタム設定の値と等しい
  @isTest
  static void test_getNameCardUserSetting_DisableUserConfig_false() {
    // 「SSmartViscaカメラでユーザによる設定変更を不可にする。」 が fasle のとき
    SB_NameCard_Util.smartViscaConfig.SCameraDisableUserConfig__c = false; 
    // カスタム設定「SmartViscaユーザ設定」の
    SmartViscaUserConfig__c userConfig = new SmartViscaUserConfig__c();
    userConfig.SvLatestListView__c =  1;  // SmartVisca:最後に開いたリスト
    userConfig.SvInitialListView__c =  0;  //SmartVisca:初期リスト
    userConfig.Development__c =  false;// Development 開発モード
    userConfig.PackageVersion__c =  null ;   // PackageVersion
    userConfig.SvcRepeatMemo__c =  true;   // メモを引き継ぐ
    userConfig.SvcGeoLocation__c =  false;   // 位置情報を送信履歴に残す
    userConfig.SvcFreehandMemo__c =  false;   // 手書きメモをデジタル化する（表面のみ）
    // userConfig.SvcLastListName__c =  null;   // 前回のリスト名
    userConfig.SvcFrontOnly__c =  false;   // 表面のみをデジタル化する
    userConfig.SvcKeepListName__c =  true;   // 名刺リスト名を覚えておく
    userConfig.SvcRepeatExchangeDate__c =  true;   // 名刺交換日を引き継ぐ
    userConfig.SvcDoubleSide__c =  true;  // 両面撮影
    // 画像補正関連
    userConfig.SvcImageTransform__c =  true;   // 画像補正する
    userConfig.SvcConfirmTransform__c =  true;   // 画像補正の結果を確認する
    userConfig.SvcShadeFilter__c =  false;   // 陰影を除去する
    userConfig.SvcNoiseFilter__c =  false;   // ゴマ塩ノイズ除去
    userConfig.SvcGabageFilter__c =  false;   // ゴミ除去
    userConfig.SvcShowTranslateFailure__c =  false;   // 画像補正の失敗を表示する
    // userConfig.SvcImageSize__c =  600;   // 画像サイズ
    // userConfig.SvcInputImageSize__c =  1200;   // 画像補正に使う長辺のサイズ
    insert userConfig;

    NameCardUserSetting__c rec = new NameCardUserSetting__c();
    rec.User__c = UserInfo.getUserId();
    rec.SvLatestListView__c= 1;   // SmartVisca:最後に開いたリスト
    rec.SvInitialListView__c = 0; // SmartVisca:初期リスト
    rec.SvcRepeatMemo__c = true; //  SmartViscaカメラ:メモを引き継ぐ SvcRepeatMemo__c	チェックボックス
    rec.SvcShadeFilter__c = true; //  SmartViscaカメラ:陰影を除去する SvcShadeFilter__c	チェックボックス
    rec.SvcNoiseFilter__c = true; //  SmartViscaカメラ:陰影除去後のゴミを取る SvcNoiseFilter__c	チェックボックス
    rec.SvcGabageFilter__c = true; //  SmartViscaカメラ:陰影除去後、さらにゴミを取る SvcGabageFilter__c	チェックボックス
    // rec.SvcImageSize__c = 1000; //  SmartViscaカメラ:画像サイズ SvcImageSize__c	数値(18、0)
    rec.SvcImageTransform__c = true; //  SmartViscaカメラ:画像補正する SvcImageTransform__c	チェックボックス
    // rec.SvcInputImageSize__c = 4000; //  SmartViscaカメラ:画像補正に使う長辺のサイズ SvcInputImageSize__c	数値(18、0)
    rec.SvcConfirmTransform__c = true; //  SmartViscaカメラ:画像補正の結果を確認する SvcConfirmTransform__c	チェックボックス
    rec.SvcShowTranslateFailure__c = true; //  SmartViscaカメラ:画像補正の失敗を表示する SvcShowTranslateFailure__c	チェックボックス
    rec.SvcFreehandMemo__c = true; //  SmartViscaカメラ:手書きメモをデジタル化する（表面のみ） SvcFreehandMemo__c	チェックボックス
    rec.SvcLastListName__c = '前回のリスト名'; //  SmartViscaカメラ:前回のリスト名 SvcLastListName__c	テキスト(255)
    rec.SvcFrontOnly__c = true; //  SmartViscaカメラ:表面のみをデジタル化する SvcFrontOnly__c	チェックボックス
    rec.SvcKeepListName__c = true; //  SmartViscaカメラ:名刺リスト名を覚えておく SvcKeepListName__c	チェックボックス
    rec.SvcRepeatExchangeDate__c = true; //  SmartViscaカメラ:名刺交換日を引き継ぐ SvcRepeatExchangeDate__c	チェックボックス
    rec.SvcDoubleSide__c = true; //  SmartViscaカメラ:裏面も撮る SvcDoubleSide__c	チェックボックス
    rec.SvcGeoLocation__c = true; //  SmartViscaカメラ:位置情報を送信履歴に残す(廃止) SvcGeoLocation__c	チェックボックス
    insert rec;

    NameCardUserSetting__c setting = SB_NameCard_UserSetting.getNameCardUserSetting();
    // 所得した設定値は、カスタム設定の値と不一致がある、レコードの値とは全て一致
    for (String f : SB_NameCard_UserSetting.settingFields) {
      System.assertEquals(rec.get(f), setting.get(f));
    }
  }

}