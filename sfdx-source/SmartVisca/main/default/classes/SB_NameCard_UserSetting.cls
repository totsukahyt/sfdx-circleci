public with sharing class SB_NameCard_UserSetting {

  public class SB_NameCard_UserSettingException extends Exception {} 

  private final String QUERY_FORM = 'SELECT {0} FROM NameCardUserSetting__c WHERE User__c = :userId ORDER BY CreatedDate ASC';
  private static SB_NameCard_UserSetting instance;

//  private String nsx;    // 名前空間名プレフィクス
  @TestVisible private NameCardUserSetting__c setting;

  // 名刺ユーザ設定の項目 参照する設定値のある項目
  @TestVisible
  private static Set<String> settingFields {
    get {
      if (settingFields == null) {
        settingFields = new Set<String>();
        Map<String, Schema.SObjectField > configFields = SmartViscaUserConfig__c.getSObjectType().getDescribe().fields.getMap();
        Map<String, Schema.SObjectField > objectFields = NameCardUserSetting__c.getSObjectType().getDescribe().fields.getMap();
        for (Schema.SObjectField f : configFields.values()) {
          Schema.DescribeFieldResult dfr = f.getDescribe();
          if (dfr.isCustom() && objectFields.containsKey(dfr.getName())) {
            settingFields.add(dfr.getName());
          }
        }
      }
      return settingFields;
    }
    private set;
  }

  // SmartViscaユーザ設定 ユーザ設定値の初期値
  @TestVisible
  private static SmartViscaUserConfig__c userConfig {
    get {
      if (userConfig == null) {
        userConfig = SmartViscaUserConfig__c.getInstance(UserInfo.getUserId());   //  個人の設定
        if (userConfig.Id ==null) {
          userConfig =  SmartViscaUserConfig__c.getInstance(UserInfo.getProfileId());   //プロファイルの設定
        }
        if (userConfig.id == null) {
          userConfig = SmartViscaUserConfig__c.getOrgDefaults();    // 組織の設定
        }
        if (userConfig.id == null) { 
          // Boolean の項目は　NULLでもなく、デフォルト値でもなく、falseになってるので、こうします。
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
        }
      }
      return userConfig;
    }
    private set;
  }


//  SmartViscaカメラ:メモを引き継ぐ SvcRepeatMemo__c	チェックボックス
//  SmartViscaカメラ:陰影を除去する SvcShadeFilter__c	チェックボックス
//  SmartViscaカメラ:陰影除去後のゴミを取る SvcNoiseFilter__c	チェックボックス
//  SmartViscaカメラ:陰影除去後、さらにゴミを取る SvcGabageFilter__c	チェックボックス
//  SmartViscaカメラ:画像サイズ SvcImageSize__c	数値(18、0)
//  SmartViscaカメラ:画像補正する SvcImageTransform__c	チェックボックス
//  SmartViscaカメラ:画像補正に使う長辺のサイズ SvcInputImageSize__c	数値(18、0)
//  SmartViscaカメラ:画像補正の結果を確認する SvcConfirmTransform__c	チェックボックス
//  SmartViscaカメラ:画像補正の失敗を表示する SvcShowTranslateFailure__c	チェックボックス
//  SmartViscaカメラ:手書きメモをデジタル化する（表面のみ） SvcFreehandMemo__c	チェックボックス
//  SmartViscaカメラ:前回のリスト名 SvcLastListName__c	テキスト(255)
//  SmartViscaカメラ:表面のみをデジタル化する SvcFrontOnly__c	チェックボックス
//  SmartViscaカメラ:名刺リスト名を覚えておく SvcKeepListName__c	チェックボックス
//  SmartViscaカメラ:名刺交換日を引き継ぐ SvcRepeatExchangeDate__c	チェックボックス
//  SmartViscaカメラ:裏面も撮る SvcDoubleSide__c	チェックボックス
//  ユーザ  User__c	参照関係(ユーザ)

  // @TestVisible
  // private static final Map<String, String> CONFIG2SETTING =  new Map<String, String> {
  //   'RepeatMemo__c' => 'SvcRepeatMemo__c', //  SmartViscaカメラ:メモを引き継ぐ SvcRepeatMemo__c	チェックボックス
  //   'ShadeFilter__c' => 'SvcShadeFilter__c', //  SmartViscaカメラ:陰影を除去する SvcShadeFilter__c	チェックボックス
  //   'NoiseFilter__c' => 'SvcNoiseFilter__c', //  SmartViscaカメラ:陰影除去後のゴミを取る SvcNoiseFilter__c	チェックボックス
  //   'GabageFilter__c' => 'SvcGabageFilter__c', //  SmartViscaカメラ:陰影除去後、さらにゴミを取る SvcGabageFilter__c	チェックボックス
  //   'ImageSize__c' => 'SvcImageSize__c', //  SmartViscaカメラ:画像サイズ SvcImageSize__c	数値(18、0)
  //   'ImageTransform__c' => 'SvcImageTransform__c', //  SmartViscaカメラ:画像補正する SvcImageTransform__c	チェックボックス
  //   'InputImageSize__c' => 'SvcInputImageSize__c', //  SmartViscaカメラ:画像補正に使う長辺のサイズ SvcInputImageSize__c	数値(18、0)
  //   'ConfirmTransform__c' => 'SvcConfirmTransform__c', //  SmartViscaカメラ:画像補正の結果を確認する SvcConfirmTransform__c	チェックボックス
  //   'ShowTranslateFailure__c' => 'SvcShowTranslateFailure__c', //  SmartViscaカメラ:画像補正の失敗を表示する SvcShowTranslateFailure__c	チェックボックス
  //   'FreehandMemo__c' => 'SvcFreehandMemo__c', //  SmartViscaカメラ:手書きメモをデジタル化する（表面のみ） SvcFreehandMemo__c	チェックボックス
  //   'LastListName__c' => 'SvcLastListName__c', //  SmartViscaカメラ:前回のリスト名 SvcLastListName__c	テキスト(255)
  //   'FrontOnly__c' => 'SvcFrontOnly__c', //  SmartViscaカメラ:表面のみをデジタル化する SvcFrontOnly__c	チェックボックス
  //   'KeepListName__c' => 'SvcKeepListName__c', //  SmartViscaカメラ:名刺リスト名を覚えておく SvcKeepListName__c	チェックボックス
  //   'RepeatExchangeDate__c' => 'SvcRepeatExchangeDate__c', //  SmartViscaカメラ:名刺交換日を引き継ぐ SvcRepeatExchangeDate__c	チェックボックス
  //   'DoubleSide__c' => 'SvcDoubleSide__c' //  SmartViscaカメラ:裏面も撮る SvcDoubleSide__c	チェックボックス
  // };

  private SB_NameCard_UserSetting() {
    // this.nsx = SB_NameCard_Util.getNamespacePrefix_x();
    this.setting = null;
    Set<String> fields = new Set<String>(settingFields);
    fields.add('Id');
    fields.add('Name');
    String query = String.format(QUERY_FORM, new String[] { String.join(new List<String>(fields), ', ') });
    System.debug(LoggingLevel.DEBUG, query);
    Id userId = UserInfo.getUserId();
    List<SObject> settings = Database.query(query);
    if (!settings.isEmpty()) {
      // 該当ユーザの設定レコードがあって、
      this.setting = (NameCardUserSetting__c)settings[0];
      fillNullFields();
      if (SB_NameCard_Util.smartViscaConfig.SCameraDisableUserConfig__c != false) {
        // 「SSmartViscaカメラでユーザによる設定変更を不可にする。」 が true のとき → 初期値に
        setDefaultValues();
      }
    }
    else {
      // なかったら作る。
      // 「SSmartViscaカメラでユーザによる設定変更を不可にする。」 が true のときは、カスタム設定「SmartViscaユーザ設定」の値でインスタンスをつくる。レコード挿入しない。
      // レコード挿入は、SSmartViscaカメラでユーザによる設定変更を不可にする。が falseのとき
      // 　→ やっぱり作る。SVタブでも保存するので、
      createSettingRecord(true);
    }
  }

  // 値がないの項目の場合、カスタム設定から初期値をセットします。
  private void fillNullFields() {
    for (String f :settingFields) {
      if (this.setting.get(f) != null) {
        continue;
      }
      Object val = userConfig.get(f);
      this.setting.put(f, val);
    }    
  }

  @TestVisible
  private static Set<String> USER_SPECIFIC_FIELDS = new Set<String> {
    'svlatestlistview__c',
    'svinitiallistview__c',
    'svclastlistname__c'
  };

  private void setDefaultValues() {
    System.assert(this.setting != null);
    String nsx = SB_NameCard_Util.getNamespacePrefix_x();
    for (String f :settingFields) {
      Object val = this.setting.get(f);
      if (val != null && USER_SPECIFIC_FIELDS.contains(f.removeStart(nsx).toLowerCase())) {
        // ユーザ固有の項目値があったら、初期値にしない
        continue;
      }
      Object def = userConfig.get(f);
      this.setting.put(f, def);
    }
  }

  // カスタム設定で設定されてるデフォルト値から NameCardUserSetting__c レコードを作成して挿入
  private void createSettingRecord(Boolean recordInsert) {
    try {
      this.setting = new NameCardUserSetting__c();
      setDefaultValues();
      this.setting.User__c = UserInfo.getUserId();
      if (recordInsert) {
        // 新規レコードを保存する
        List<NameCardUserSetting__c> objs = new List<NameCardUserSetting__c>();
        objs.add(this.setting);
        SB_NameCard_CrudFls.screate(objs, true);
      }
    }
    catch(Exception e) {
      System.debug(LoggingLevel.ERROR, e);
    }
  }

  // private final Set<String> NO_SETTING_FIELDS = new Set<String> {
  //   'Development__c',
  //   'PackageVersion__c',
  //   'Reserved01__c',
  //   'Reserved02__c',
  //   'Reserved03__c'
  // };

  // @TestVisible
  // private static Set<String> getsettingFields() {
  //   Set<String> result = new Set<String>();
  //   Map<String, Schema.SObjectField > settingFields = SmartViscaUserConfig__c.getSObjectType().getDescribe().fields.getMap();
  //   Map<String, Schema.SObjectField > settingFields = NameCardUserSetting__c.getSObjectType().getDescribe().fields.getMap();
  //   for (Schema.SObjectField f : settingFields.values()) {
  //     Schema.DescribeFieldResult dfr = f.getDescribe();
  //     if (dfr.isCustom() && settingFields.containsKey(dfr.getName())) {
  //       result.add(dfr.getName());
  //     }
  //   }
  //   // result.add('LastModifiedDate');
  //   // result.add('LastModifiedById');
  //   // result.add('LastModifiedBy.Name');
  //   return result;
  // }

  public static void saveSetting(Map<String, Object> values) {
    // SObject setting = createSObject(values);
    String nsx = SB_NameCard_Util.getNamespacePrefix_x();
    NameCardUserSetting__c currentSetting = getNameCardUserSetting();
    Id userId = UserInfo.getUserId();
    List<NameCardUserSetting__c> recs = [SELECT Id, Name FROM NameCardUserSetting__c WHERE User__c = :userId];
    if (recs.isEmpty()) {
      // 読んだときなければ作ってるから、ないはずだけど
      return;
    }
    NameCardUserSetting__c newSetting = new NameCardUserSetting__c(Id = recs[0].Id);
    Map<String, Schema.SObjectField > settingFields = NameCardUserSetting__c.getSObjectType().getDescribe().fields.getMap();
    for (String key : values.keySet()) {
      if (key == 'user') {
        continue;
      }
      String f = nsx + key.left(1).toUpperCase() + key.substring(1) + '__c';
      if (settingFields.containsKey(f)) {
        // 有効な項目API名だったら。
        newSetting.put(f, values.get(key));
        currentSetting.put(f, values.get(key));  // インスタンスの方も更新しとく
      }
    }    
    List<NameCardUserSetting__c> objs = new List<NameCardUserSetting__c>();
    objs.add(newSetting);
    SB_NameCard_CrudFls.supdate(objs, true);
  }

  // public static SObject createSObject(Map<String, Object> values) {
  //   Id userId = UserInfo.getUserId();
  //   // 既存のレコードIDを調べる
  //   List<NameCardUserSetting__c> recs = [SELECT Id FROM NameCardUserSetting__c WHERE User__c = :userId];
  //   Id recId; 
  //   if (recs.isEmpty()) {
  //     // 削除されてたら作る
  //     NameCardUserSetting__c rec = new NameCardUserSetting__c(User__c=userId);
  //     insert rec;
  //     recId = rec.Id;
  //   }
  //   else {
  //     recId = recs[0].Id;
  //   }
  //   // 新しく
  //   NameCardUserSetting__c result = (NameCardUserSetting__c)NameCardUserSetting__c.sObjectType.newSObject();
  //   result.Id = recId;
  //   Map<String, Schema.SObjectField > settingFields = NameCardUserSetting__c.getSObjectType().getDescribe().fields.getMap();
  //   for (String key : values.keySet()) {
  //     String f = key.left(1).toUpperCase() + key.substring(1) + '__c';
  //     if (settingFields.containsKey(f)) {
  //       // 有効な項目API名だったら。
  //       result.put(f, values.get(key));
  //     }
  //   }
  //   return result;
  // }
 
  public static NameCardUserSetting__c getNameCardUserSetting() {
    if (instance == null) {
      instance = new SB_NameCard_UserSetting();
    }
    return instance.setting;
  }

}