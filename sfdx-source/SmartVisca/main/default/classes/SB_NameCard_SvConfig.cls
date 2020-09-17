/**
 *
 * SB_NameCard_SvConfig
 *
 * モバイル SmartVisca 関連の設定を保持するクラス
 *    SB_NameCard_SController SB_NameCard_S2Controller  から分離
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2019.08.xx
 **/
public with sharing class SB_NameCard_SvConfig {

  public String namespacePrefix { get; private set; }     // 使ってないけど、public を一度パッケージにいれるとなくせない? 2015.07.08
  public String userId { get; private set; }
  public String userName { get; private set; }
  public Boolean devMode { get; private set; }
  public Boolean demoOrg { get; private set; }
  public Boolean sEnableNameCardEdit { get; private set; }
  public Boolean sUseGIS { get; private set; }
  public Boolean sUseStandardActivityUI { get; private set; }
  public Boolean sUseStandardNamecardViewUI { get; private set; }
  public Boolean sUseStandardNamecardEditUI { get; private set; }
  public Boolean sUseSessionStrage { get; private set; }
  public Boolean enableNameCardTag { get; private set; }
  public Boolean enableChatter { get; private set; }
  public Boolean sDetailShowNewsLink { get; private set; }
  public Boolean sDetailShowFax { get; private set; }
  public Boolean sDetailShowURL { get; private set; }
  public Boolean sDetailShowEMail { get; private set; }
  public Boolean sDetailShowMemo { get; private set; }
  public Boolean sDetailShowListName { get; private set; }
  public Boolean sDetailShowAddressEng { get; private set; }
  public Boolean sDetailShowCompanyKana { get; private set; }
  public Boolean sDetailShowMobile { get; private set; }
  public Boolean sDetailShowNameKana { get; private set; }
  public Boolean sDetailShowFreeHandMemo { get; private set; }
  public Boolean sDetailShowAddress { get; private set; }
  public Boolean sDetailShowOtherOwner { get; private set; }
  public Boolean sDetailShowTel { get; private set; }
  public Boolean sDetailShowExchangeDate { get; private set; }
  public Boolean sDetailShowZipCode { get; private set; }
  public String sScannerName { get; private set; }
  public String sSmartViscaServer { get; private set; }
  public String sExtraNamespace { get; private set; }
  public String sSmartViscaServeServiceID { get; private set; }
  public Map<String, String> sSmartViscaServerOptions { get; private set; }
  public String sUserLocale { get; private set; }       // 2015.10.1x
  public String sUserLanguage { get; private set; }       // 2016.07.xx ユーザの言語設定
  public Boolean enableAccountRegist { get; private set; }    // 2016.10.xx カスタム設定の取引先登録を使える + 名刺更新権 + アカウント参照権 + コンタクト参照権
  public Boolean enableAccountCreate { get; private set; }    // 2016.10.xx 取引先オブジェクトの作成権がある
  public Boolean enableContactCreate { get; private set; }    // 2016.10.xx 取引先責任者オブジェクトの作成権がある
  public Boolean enableAccountEdit { get; private set; }    // 2016.10.xx 取引先オブジェクトの編集権がある
  public Boolean enableContactEdit { get; private set; }    // 2016.10.xx 取引先責任者オブジェクトの編集権がある
  public Boolean enableAccountView { get; private set; }    // 2016.10.xx アカウント参照権がある。
  public Boolean enableContactView { get; private set; }    // 2016.10.xx コンタクト参照権がある。
  public Boolean enableNameCardEdit { get; private set; }    // 2016.10.xx 名刺 編集権がある。
  public Boolean enableAccount { get; private set; }    // 2016.04.xx 使ってないけど public なので消せない
  public Boolean enableContact { get; private set; }    // 2016.04.xx 使ってないけど public なので消せない
  public String accountLabel { get; private set; }    // 2016.05.xx 取引先のラベル
  public String contactLabel { get; private set; }    // 2016.05.xx 取引先責任者のラベル
  public Boolean enableActivity { get; private set; }    // 2016.07.3x 名刺の活動が許可されているか
  public Boolean sListQueryIgnoreLatestCard { get; private set; } //名刺一覧のみんなの名刺は最新の名刺以外も対象にする
  public Boolean sCameraEnableOwnerSelect { get; private set; } // v2.1 2018.11.xx S名刺カメラで所有者選択を有効にする
  public String accountRegistPage { get; private set; }  // v2.1 2018.11.xx S1取引先登録用ページ
  public String soslInvalidOneCharacterRegex { get; private set; } // v2.1 2019.01.xx 検索関連 1文字でこの正規表現に当てはまるのはSOSLでエラー ASCIIと 「＼」、「￥」、「。」 とか
  public String smartviscaCameraPage { get; private set; } // v2.4 2019.09.xx SmartVisca カメラのページ
  public String smartviscaMobilePage { get; private set; } // v2.4 2019.09.xx SmartVisca のページ
  public Boolean sDisableCameraLauncher { get; private set; } // v2.4 SSmartViscaカメラ起動ボタンを表示する デフォルト true SV_DEV-2024 S1 新SmartVisca：カメラ起動ボタンを非表示にする設定が欲しい

  // 以上は Version 2.3までにあった変数
  public Map<String, Object> userSetting { get; private set; } // // 名刺ユーザ設定 NameCardUserSetting__c の内容
  // private class User { 
  //   public Id id { get; private set; }
  //   public String name { get; private set; }
  //   public String username { get; private set; }
  //   public String uiTheme { get; private set; }
  //   public String uiThemeDisplayed { get; private set; }
  //   public String language { get; private set; }
  //   public String locale { get; private set; }
  //   User() {
  //     this.id = UserInfo.getUserId();
  //     this.name = UserInfo.getName();
  //     this.username = UserInfo.getUserName();
  //     this.uiTheme = UserInfo.getUiTheme();
  //     this.uiThemeDisplayed = UserInfo.getUiThemeDisplayed();
  //     this.language = UserInfo.getLanguage();
  //     this.locale = UserInfo.getLocale();
  //   }
  // }

  public SB_NameCard_SvConfig() {
    // Version 2.3 までの設定値をセット
    build23Values();

    this.userSetting = new Map<String, Object>();
    this.userSetting.putAll(makeNormalizedKeyValue(SB_NameCard_UserSetting.getNameCardUserSetting()));
  }

  private static final Set<String> SV_FIELDS = new Set<String> {
    'svlatestlistview__c', // SmartVisca:最後に開いたリスト
    'svinitiallistview__c' // SmartVisca:初期リスト
  };

  private Map<String, Object> makeNormalizedKeyValue(SObject obj) {
    Map<String, Object> result = new Map<String, Object>();
    String nsx = SB_NameCard_Util.getNamespacePrefix_x();
    Map<String, Object> fields = obj.getPopulatedFieldsAsMap();
    for (String apiName : fields.keySet()) {
      if (apiName.toLowerCase()=='lastmodifieddate' ||
          !SV_FIELDS.contains(apiName.removeStartIgnoreCase(nsx).toLowerCase())) {
        continue;
      }
      String key = apiName.removeEnd('__c').removeStartIgnoreCase(nsx);
      key = key.left(1).toLowerCase() + key.substring(1);
      result.put(key, fields.get(apiName));
    }
    return result;
  }

  public static void saveSetting(Map<String, Object> values) {
    Map<String, Object> saveValues = new Map<String, Object>();
    if (values.containsKey('userSetting')) {
      saveValues.putAll((Map<String, Object>)values.get('userSetting'));
    }
    else {
      saveValues.putAll(values);
    }
    if (!saveValues.isEmpty()) {
      SB_NameCard_UserSetting.saveSetting(saveValues);
    }
  }

  // Version 2.3 までの設定値をセット
  private void build23Values() {
    // 名前空間名
    //this.namespacePrefix = SB_NameCard_S2Controller.namespace;
    // ユーザID
    this.userid = UserInfo.getUserId();
    // ユーザ名
    this.userName = UserInfo.getUserName();
    // 開発用か判定
    //this.devMode = DEVELOPERS.contains(UserInfo.getUserName().toLowerCase());
    // デモ用か判定
    Set<String> demoOrgIds = new Set<String>(System.Label.SB_NC_DemoOrgs.toUpperCase().split('[,\\s]'));
    if (demoOrgIds.contains(UserInfo.getOrganizationId().toUpperCase().substring(0, 15)) == true)
    this.demoOrg = true;
    else
    this.demoOrg = false;
    // 名刺の編集を行う
    this.sEnableNameCardEdit = SB_NameCard_Util.smartViscaConfig.SEnableNameCardEdit__c;
    // 地理情報を使う
    this.sUseGIS = SB_NameCard_Util.smartViscaConfig.SUseGIS__c;
    // 行動やToDoは標準の画面を使う
    this.sUseStandardActivityUI = SB_NameCard_Util.smartViscaConfig.SUseStandardActivityUI__c;
    // S1 名刺詳細は標準の画面を使う
    this.sUseStandardNamecardViewUI = SB_NameCard_Util.smartViscaConfig.SUseStandardNamecardViewUI__c;
    // S1 名刺編集は標準の画面を使う
    this.sUseStandardNamecardEditUI = SB_NameCard_Util.smartViscaConfig.SUseStandardNamecardEditUI__c;
    // 名刺データをセッションストレージに保持する
    this.sUseSessionStrage = SB_NameCard_Util.smartViscaConfig.SUseSessionStrage__c;
    // 名刺の個人タグが有効になってる。
    this.enableNameCardTag = SB_NameCard_S2Controller.isEnableNameCardTagPersonal();
    // Chatterが有効
    this.enableChatter = SB_NameCard_S2Controller.isEnableFeedItem();
    // 名刺詳細画面に表示する項目系
    // S名刺詳細：ニュースリンクを表示する
    this.sDetailShowNewsLink = SB_NameCard_Util.smartViscaConfig.SDetailShowNewsLink__c;
    // S名刺詳細：FAX番号を表示する
    this.sDetailShowFax = SB_NameCard_Util.smartViscaConfig.SDetailShowFax__c;
    // S名刺詳細：URLを表示する
    this.sDetailShowURL = SB_NameCard_Util.smartViscaConfig.SDetailShowURL__c;
    // S名刺詳細：メールアドレスを表示する
    this.sDetailShowEMail = SB_NameCard_Util.smartViscaConfig.SDetailShowEMail__c;
    // S名刺詳細：メモを表示する
    this.sDetailShowMemo = SB_NameCard_Util.smartViscaConfig.SDetailShowMemo__c;
    // S名刺詳細：リスト名を表示する
    this.sDetailShowListName = SB_NameCard_Util.smartViscaConfig.SDetailShowListName__c;
    // S名刺詳細：英語住所を表示する
    this.sDetailShowAddressEng = SB_NameCard_Util.smartViscaConfig.SDetailShowAddressEng__c;
    // S名刺詳細：会社名カナを表示する
    this.sDetailShowCompanyKana = SB_NameCard_Util.smartViscaConfig.SDetailShowCompanyKana__c;
    // S名刺詳細：携帯電話番号を表示する
    this.sDetailShowMobile = SB_NameCard_Util.smartViscaConfig.SDetailShowMobile__c;
    // S名刺詳細：氏名カナを表示する
    this.sDetailShowNameKana = SB_NameCard_Util.smartViscaConfig.SDetailShowNameKana__c;
    // S名刺詳細：手書きメモを表示する
    this.sDetailShowFreeHandMemo = SB_NameCard_Util.smartViscaConfig.SDetailShowFreeHandMemo__c;
    // S名刺詳細：住所を表示する
    this.sDetailShowAddress = SB_NameCard_Util.smartViscaConfig.SDetailShowAddress__c;
    // S名刺詳細：所有者を表示する
    this.sDetailShowOtherOwner = SB_NameCard_Util.smartViscaConfig.SDetailShowOtherOwner__c;
    // S名刺詳細：電話番号を表示する
    this.sDetailShowTel = SB_NameCard_Util.smartViscaConfig.SDetailShowTel__c;
    // S名刺詳細：名刺交換日を表示する
    this.sDetailShowExchangeDate = SB_NameCard_Util.smartViscaConfig.SDetailShowExchangeDate__c;
    // S名刺詳細：郵便番号を表する
    this.sDetailShowZipCode = SB_NameCard_Util.smartViscaConfig.SDetailShowZipCode__c;
    // S1カメラのスキャナー名
    this.sScannerName = SB_NameCard_Util.smartViscaConfig.SScannerName__c;
    // SmartViscaサーバのURL
    this.sSmartViscaServer = SB_NameCard_Util.smartViscaConfig.SSmartViscaServer__c;
    // S開発者モードで動く
    this.devMode = SB_NameCard_Util.smartViscaConfig.SDevelopment__c;       // 2015.08.1X V1.11
    // 特別に名前空間名の指定が必要場合に使う
    this.sExtraNamespace = SB_NameCard_Util.smartViscaConfig.SExtraNamespace__c;
    // SmartVisca サーバの サービスID
    this.sSmartViscaServeServiceID = SB_NameCard_Util.smartViscaConfig.SSmartViscaServeServiceID__c;
    //// SmartViscaサーバ  proxy_flag true でリクエストする。
    //this.sSSmartViscaServerProxyFlag = SB_NameCard_Util.smartViscaConfig.SSmartViscaServerProxyFlag__c;       // 2015.08.1X V1.11
    if (String.isNotBlank(SB_NameCard_Util.smartViscaConfig.SSmartViscaServerOptions__c)) {
      this.sSmartViscaServerOptions = getKey2Value(SB_NameCard_Util.smartViscaConfig.SSmartViscaServerOptions__c);
    }
    // ロケール 2015.10.1x
    this.sUserLocale = UserInfo.getLocale();          // ja_JP とか en_US とか
    // ロケール 2016.07.xx    ユーゼ設定の言語で決める
    this.sUserLanguage = UserInfo.getLanguage();      // ja とか en_US とか  AngularJSのコントローラで受けて、表示言語を決める
    // 取引先、取引先責任者 登録機能を使えるか 2016.04.xx
    //this.enableAccount = isSufficientAccess(Account.SObjectType) && SB_NameCard_Util.smartViscaConfig.SUseAccountRegist__c;      //
    this.enableAccount = false;     // 使ってないけど、テストカバレッジ用に
    //this.enableContact = isSufficientAccess(Contact.SObjectType) && SB_NameCard_Util.smartViscaConfig.SUseAccountRegist__c;      //
    this.enableContact = false;     // 使ってないけど、テストカバレッジ用に
      // 2016.10.xx カスタム設定の取引先登録を使える + 名刺更新権 + アカウント参照権 + コンタクト参照権
    this.enableAccountRegist = SB_NameCard_Util.smartViscaConfig.SUseAccountRegist__c && getEnableEdit(NameCard__c.SObjectType) && getEnableAccess(Account.SObjectType) && getEnableAccess(Contact.SObjectType);
    this.enableAccountCreate = getEnableCreate(Account.SObjectType);      // 作成権限がある
    this.enableContactCreate = getEnableCreate(Contact.SObjectType);      //
    this.enableAccountEdit = getEnableEdit(Account.SObjectType);      // 編集権限がある
    this.enableContactEdit = getEnableEdit(Contact.SObjectType);      //
    this.enableAccountView = getEnableAccess(Account.SObjectType);    // 2016.10.xx アカウント参照権がある。
    this.enableContactView = getEnableAccess(Contact.SObjectType);    // 2016.10.xx コンタクト参照権がある。
    this.enableNameCardEdit = getEnableEdit(NameCard__c.SObjectType);    // 2016.10.xx 名刺 編集権がある。
    this.accountLabel = Schema.getGlobalDescribe().get('Account').getDescribe().getLabel();
    this.contactLabel = Schema.getGlobalDescribe().get('Contact').getDescribe().getLabel();
    this.enableActivity = isEnableActivity();   // 2016.07.3x
    // S名刺一覧のみんなの名刺は最新の名刺以外も対象にする
    this.sListQueryIgnoreLatestCard = SB_NameCard_Util.smartViscaConfig.SListQueryIgnoreLatestCard__c;            // 2016.09.xx
    this.sCameraEnableOwnerSelect = SB_NameCard_Util.smartViscaConfig.SCameraEnableOwnerSelect__c; // v2.1 2018.11.xx S名刺カメラで所有者選択を有効にする
    this.accountRegistPage = getValidAccountRegistPage(); // v2.1 2018.11.xx S1取引先登録用ページ
    this.soslInvalidOneCharacterRegex = Label.SB_NC_SoslInvalidStringRegex;    
    this.smartviscaCameraPage = 'SB_NameCard_SImageIndex'; // v2.4 2019.09.xx SmartVisca カメラのページ
    this.smartviscaMobilePage = 'SB_NameCard_SIndex'; // v2.4 2019.09.xx SmartVisca のページ
    this.sDisableCameraLauncher = SB_NameCard_Util.smartViscaConfig.SDisableCameraLauncher__c; // SSmartViscaカメラ起動ボタンを表示しない デフォルト false SV_DEV-2024 S1 新SmartVisca：カメラ起動ボタンを非表示にする設定が欲しい
  }
  // v2.1 2018.11.xx S1取引先登録用ページ
  private String getValidAccountRegistPage() {
    Set<String> validPages = new Set<String> {
      'SB_NameCard_SRegistIndex',  // 従来からのS1用取引先登録
      'SB_NC_AccountRegist' // LEX版取引先登録
    };
    if (validPages.contains(SB_NameCard_Util.smartViscaConfig.SAccountRegistPage__c)) {
      return SB_NameCard_Util.smartViscaConfig.SAccountRegistPage__c;
    }
    return 'SB_NameCard_SRegistIndex';
  }
  // ユーザがオブジェクトを参照できるか
  private Boolean getEnableAccess(SObjectType otype) {
    DescribeSObjectResult dsr = otype.getDescribe();
    return dsr.isAccessible();
  }
  // ユーザがオブジェクトを参照、作成できるか
  private Boolean getEnableCreate(SObjectType otype) {
    DescribeSObjectResult dsr = otype.getDescribe();
    return dsr.isAccessible() && dsr.isCreateable();
  }
  // ユーザがオブジェクトを参照、更新できるか
  private Boolean getEnableEdit(SObjectType otype) {
    DescribeSObjectResult dsr = otype.getDescribe();
    return dsr.isAccessible() && dsr.isUpdateable();
  }

  // 名刺に活動が許可されているかの判定
  private Boolean isEnableActivity() {
    try {
      Set<Schema.sObjectType> ots = new Set<Schema.sObjectType> (Event.WhatId.getDescribe().getReferenceTo());
      ots.addAll(Task.WhatId.getDescribe().getReferenceTo());
      return ots.contains(NameCard__c.sObjectType);
    }
    catch(Exception e) {
      return false;
    }
  }

  // 文字列を行で分けて、次に : でわけて キーと値のマップを作る。 2015.08.1x
  @TestVisible
  private static Map<String, String> getKey2Value(String text)  {
    Map<String, String> result = new Map<String, String>();
    String[] lines = text.split('[\r\n]');
    for (String line : lines) {
        String[] ss = line.split(':');
        if (ss ==null || ss.size()!=2) continue;
        result.put(ss[0], ss[1]);
    }
    return result;
  }



}