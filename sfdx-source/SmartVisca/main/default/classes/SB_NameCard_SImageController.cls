/**
 * SB_NameCard_SImageController
 *
 *
 * v2.5 2020.03.xx SV_DEV-2442 SmartViscaカメラタブを開く際にロード画面から遷移しない → リスト名付き名刺が多いとSmartViscaカメラが開かないという問題があって、処理を見直し
 *
 **/
public with sharing class SB_NameCard_SImageController {
  public class SB_NameCard_SImageControllerException extends Exception {}

  // 管理パッケージの名前空間名を
  public static String namespace {
    get {
      if (namespace == null) {
        namespace = config.get('sExtraNamespace') != null ?
            (String)config.get('sExtraNamespace') : SB_NameCard_Util.getNamespacePrefix();
      }
      return namespace;
    }
    private set;
  }

  // Chatterが有効になってるか？
  public static Boolean isEnableFeedItem() { return enableFeedItem;}
  private static Boolean enableFeedItem {
    get {
      if (enableFeedItem == null) {
        enableFeedItem = ConnectApi.Organization.getSettings().features.chatter;
      }
      return enableFeedItem;
    }
    private set;
  }

  public String userId { get; private set; }
  public Boolean debug { get; private set; }
  public Boolean devMode { get; private set; }
  public String clientIPAddress { get; private set; }
  public String userAgent { get; private set; }
  public Boolean iOSDevice { get; private set; }  // iPhone版 Salesforce1なら true
  public Boolean iOS8 { get; private set; }  // iPhone OS/8 とかだったら true  2014/10/22
  public Boolean android { get; private set; }  // iPhone OS/8 とかだったら true  2014/10/22

  public SB_NameCard_SImageController() {
    String s = System.currentPageReference().getParameters().get('debug');
    if (String.isNotBlank(s) && (s.equals('1') || s.toUpperCase().equals('TRUE')))
      this.debug = true;
    else
      this.debug = false;
    userId = System.currentPageReference().getParameters().get('userid');
    if (String.isBlank(userId) == true) userId = UserInfo.getUserId();
      devMode = (UserInfo.getUserEmail() == 'hsawano@sunbridge.com');
    userAgent = ApexPages.currentPage().getHeaders().get('USER-AGENT');                 // ブラウザの UserAgent
    clientIPAddress = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');     // クライアントIPアドレス
    System.debug('USER-AGENT : ' + userAgent);
    // iPhone OS/7.1.2 (iPhone) Salesforce1/6.0.1(3000685) XBranding/1.0 SalesforceTouchContainer/2.0 Mozilla/5.0 (iPhone; CPU iPhone OS 7_1_2 like Mac OS X) AppleWebKit/537.51.2 (KHTML, like Gecko) Mobile/11D257 (441818336)
    // iPhone OS/7.1.2 (iPad) Salesforce1/6.0.1(3000685) XBranding/1.0 SalesforceTouchContainer/2.0 Mozilla/5.0 (iPad; CPU OS 7_1_2 like Mac OS X) AppleWebKit/537.51.2 (KHTML, like Gecko) Mobile/11D257 (371725360)
    // iPhone OS/8.1 (iPhone) Salesforce1/6.0.4(3000747) XBranding/1.0 SalesforceTouchContainer/2.0 Mozilla/5.0 (iPhone; CPU iPhone OS 8_1 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Mobile/12B411 (371462944)
    // iPhone OS/8.1 (iPad) Salesforce1/6.0.4(3000747) XBranding/1.0 SalesforceTouchContainer/2.0 Mozilla/5.0 (iPad; CPU OS 8_1 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Mobile/12B410 (413432672)
    // Mozilla/5.0 (Linux; Android 4.4.2; D6503 Build/17.1.2.A.0.314) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/30.0.0.0 Mobile Safari/537.36 Salesforce1/5.3.2XBranding/1.0
    // SalesforceMobileSDK/2.2.3 android mobile/5.0.2 ( D6503) Salesforce1/7.2.1 Native XBranding/1.0 SalesforceTouchContainer/2.0 Mozilla/5.0 (Linux; Android 5.0.2; D6503 Build/23.1.A.1.28; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/43.0.2357.121 Mobile Safari/537.36
    iOSDevice = false;  //
    iOS8 = false;
    android = false;
    // USER-AGENT に所定の文字列（iPhone　iPad iPod など）がある場合、iOSと判断、クライアント側で処理を分ける。
    String[] tests = System.Label.SB_NC_iOSDevice.split('[,\\s]+');
    for (String t : tests) {
      if (String.isBlank(userAgent) == false &&
          SB_NameCard_MojiWidthUtil.findIgnoreCaseWidth(userAgent,SB_NameCard_MojiWidthUtil.toHalfWidth(t)) && SB_NameCard_MojiWidthUtil.findIgnoreCaseWidth(userAgent,SB_NameCard_MojiWidthUtil.toHalfWidth('Salesforce1')))  {
        iOSDevice = true;
        iOS8 = isIOS8(userAgent);
      }
    }
    System.debug('iOSDevice : ' + iOSDevice);
    android = (iOSDevice == false && String.isBlank(userAgent) == false && SB_NameCard_MojiWidthUtil.findIgnoreCaseWidth(userAgent,SB_NameCard_MojiWidthUtil.toHalfWidth('Android')));
  }

  // iOS8 だと画像拡大したとき、画像だけスワイプができずページごとスワイプしてしてしまう。かつ ピンチイン・ピンチアウトが出来ないので、識別する。 2014/10/22
  @TestVisible
  private Boolean isIOS8(String text) {
    String[] ss = Label.SB_NC_iOS8Device.split('[,]');
    for (String s : ss) {
      if (text.contains(s) == true)
        return true;
    }
    return false;
  }

  public virtual class Response {
    @TestVisible public Boolean success { get; private set; }
    @TestVisible public String error { get; private set; }
    protected Response() {
      this.success = false;
    }
  }


  // 諸設定を取得
  @RemoteAction
  public static Map<String, Object> getSVConfig() {
    return config;
  }
  private static Map<String, Object> config {
    get {
      if (config == null) {
        config = SB_NameCard_SvcConfig.getInstance().getValues();
      }
      return config;
    }
    set;
  }

  // 名刺の個人タグが使用可能
  public static Boolean isEnableNameCardTagPersonal() { return enableNameCardTagPersonal;}
  private static Boolean enableNameCardTagPersonal {
    get {
      if (enableNameCardTagPersonal == null) {
        enableNameCardTagPersonal = false;
        try {
          Schema.SObjectType targetType = Schema.getGlobalDescribe().get(SB_NameCard_Util.getNamespacePrefix_x()  + 'NameCard__tag');
          Schema.SObjectField field = targetType.getDescribe().fields.getMap().get('Type');
          List<String> types = SB_NameCard_Util.getPickListEntry(field);
          for (String t : types) {
            if (t == 'Personal' || t == System.Label.SB_NC_ValPersonalTagType) {    //個人用
              enableNameCardTagPersonal = true;
              break;
            }
          }
        }
        catch(Exception e) {
          enableNameCardTagPersonal = false;
        }
      }
      return enableNameCardTagPersonal;
    }
    private set;
  }

  /**
  *   タグまたはリスト名のリスト取得
  *   type  0： 個人の  1:公開の 2:両方
  *  v2.5 2020.03.xx SV_DEV-2442 SmartViscaカメラタブを開く際にロード画面から遷移しない → リスト名付き名刺が多いとSmartViscaカメラが開かないという問題があって、処理を見直し
  **/
  // 一覧を取得するときのリクエスト 条件
  public class GetTagsRequest extends SB_NameCard_TagAndListCollector.GetTagsRequest {
    public GetTagsRequest(Integer type, Integer tagSecurity, String excludeId) {
      this.type = type;
      this.tagSecurity = tagSecurity;
      this.excludeId = excludeId;
    }
  }
  // リクエストに応じて タグのリストを返す
  @RemoteAction
  public static List<SB_NameCard_TagAndListCollector.NameCardTagOrList> getTagsOrListnames(GetTagsRequest req) {
    SB_NameCard_TagAndListCollector.GetTagsRequest instance = new SB_NameCard_TagAndListCollector.GetTagsRequest(req);
    return instance.create();
  }


  /**
  *
  *  名刺利用可能ユーザの 部署−ユーザs 取得
  *  2017.10.xx v1.22
  *     SV_DEV-339 SmartViscaカメラで名刺所有者を入力できるようにする
  *  2018.11.xx v2.1
  *     条件指定可能に
  *     SV_DEV-1237 SmartViscaカメラの所有者選択で2千人を超えるユーザー数のサポート
  ***/
  @RemoteAction
  public static SB_NameCard_UserList.DepartmentUsers getDepartmentUsers(String dept, String word) {
    return SB_NameCard_UserList.getDepartmentUsers(dept, word);
  }

  // ユーザの設定を保存する。
  @RemoteAction
  public static Response saveUserSetting(Map<String, Object> valeus) {
    Response result = new Response();
    try {
      SB_NameCard_UserSetting.saveSetting(valeus);
      result.success = true;
    }
    catch(Exception e) {
      result.success = false;
      result.error = e.getMessage();
    }
    return result;
  }

}