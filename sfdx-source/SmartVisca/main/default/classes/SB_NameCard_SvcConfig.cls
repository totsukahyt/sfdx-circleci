/**
 *
 * SB_NameCard_SvcConfig
 *
 * SmartViscaカメラ関連の設定を保持するクラス
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2019.05.xx
 **/
public with sharing class SB_NameCard_SvcConfig {

  private class User { 
    public Id id { get; private set; }
    public String name { get; private set; }
    public String username { get; private set; }
    public String uiTheme { get; private set; }
    public String uiThemeDisplayed { get; private set; }
    public String language { get; private set; }
    public String locale { get; private set; }
    public String sessionId { get; private set; }
    public String orgId { get; private set; }
    User() {
      this.id = UserInfo.getUserId();
      this.name = UserInfo.getName();
      this.username = UserInfo.getUserName();
      this.uiTheme = UserInfo.getUiTheme();
      this.uiThemeDisplayed = UserInfo.getUiThemeDisplayed();
      this.language = UserInfo.getLanguage();
      this.locale = UserInfo.getLocale();
      this.sessionId = UserInfo.getSessionId();
      this.orgId = UserInfo.getOrganizationId();
    }
  }

  private String nsx;    // 名前空間名プレフィクス
  private Map<String, Object> values;
  
  private SB_NameCard_SvcConfig() {
    this.nsx = SB_NameCard_Util.getNamespacePrefix_x();
    this.values = new Map<String, Object>();
    // SmartViscaCameraConfig__c svcConfig = getSvCameraConfig();
    makeNormalizedKeyValue(SB_NameCard_UserSetting.getNameCardUserSetting());
    makeNormalizedKeyValue(SB_NameCard_Util.smartViscaConfig);
    // 所有者選択の有効化は 2.0 ではカスタム設定になかったので、
    Boolean sCameraEnableOwnerSelect = true;
    if (SB_NameCard_Util.smartViscaConfig.getPopulatedFieldsAsMap().containsKey(this.nsx + 'SCameraEnableOwnerSelect__c')) { // getPopulatedFieldsAsMap() では 名前空間名が必要
      sCameraEnableOwnerSelect = (Boolean)SB_NameCard_Util.smartViscaConfig.get(this.nsx + 'SCameraEnableOwnerSelect__c');
    }
    this.values.put('sCameraEnableOwnerSelect', sCameraEnableOwnerSelect);
    // ユーザ情報
    this.values.put('user', new User());
    this.values.put('maxFileCount', 20);
    // VFページの情報 固定
    this.values.put('smartviscaCameraPage', 'SB_NameCard_SImageIndex'); // SmartVisca カメラのページ
    this.values.put('smartviscaMobilePage', 'SB_NameCard_SIndex');// SmartVisca タブ のページ
  }

  public Map<String, Object> getValues() {
    return this.values;
  }

  private void makeNormalizedKeyValue(SObject obj) {
    Map<String, Object> fields = obj.getPopulatedFieldsAsMap();
    for (String apiName : fields.keySet()) {
      System.debug('apiName: ' + apiName);
      if (apiName.toLowerCase()=='lastmodifieddate') {
        continue;
      }
      String key = apiName.removeEnd('__c').removeStartIgnoreCase(this.nsx);
      key = key.left(1).toLowerCase() + key.substring(1);
      if (FIELD_CONVERTER.containsKey(key)) {
        Object val = fields.get(apiName);
        if (val == null) {
          continue;
        }
        ConfigValueConverter cnv = FIELD_CONVERTER.get(key);
        this.values.put(key, cnv.convert(val));
      }
      else {
        this.values.put(key, fields.get(apiName));
      }
    }
  }

  private interface ConfigValueConverter {
    Object convert(Object value);
  }

  private class StringToStringMapConverter implements ConfigValueConverter {
    public Object convert(Object value) {
      String text = (String)value; 
      if (String.isBlank(text)) {
        return null;
      }
      Map<String, String> result = new Map<String, String>();
      String[] lines = text.split('[\r\n]');
      for (String line : lines) {
          String[] ss = line.split(':');
          if (ss ==null || ss.size()!=2) continue;
          result.put(ss[0].trim(), ss[1].trim());
      }
      return (Object)result;
    }
  }

  private Map<String, ConfigValueConverter> FIELD_CONVERTER = new Map<String, ConfigValueConverter> {
    'sSmartViscaServerOptions' => new StringToStringMapConverter()
  };

  // private static Map<String, String> getKey2Value(String text)  {
  //   Map<String, String> result = new Map<String, String>();
  //   String[] lines = text.split('[\r\n]');
  //   for (String line : lines) {
  //     String[] ss = line.split(':');
  //     if (ss ==null || ss.size()!=2) continue;
  //     result.put(ss[0], ss[1]);
  //   }
  //   return result;
  // }

  private static SB_NameCard_SvcConfig instance;

  public static SB_NameCard_SvcConfig getInstance() {
    if (instance == null) {
      instance = new SB_NameCard_SvcConfig();
    } 
    return instance;
  }
}