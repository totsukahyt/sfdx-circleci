/**
 *
 * Salesforce1対応 SmartVisca VFコントローラクラス 主に JavaScriptRemotingメソッド
 *
 * Copyright (C) 2014-2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2014.5.xx
 *  @Version 2      2015.6.xx  S1カメラ対応 最初の ionic 版のとき
 *  @Version 3      2015.8.xx  S1カメラ対応 bootstrap 対応のとき
 *  @Version 4      2016.09.xx みんなの名刺の対処をどうするkla
 *  @Version 5      2017.10.xx v1.20.3 コードスキャン対応 with sharing  を追加
 *  @Version 6      2017.10.xx v1.22  名刺利用可能ユーザの 部署−ユーザs 取得 SV_DEV-339 SmartViscaカメラで名刺所有者を入力できるようにする
 *                  2017.11.xx v1.22 2017.11.xx SV_DEV-689 組織情報に役職を加味する
 *                  2018.03.xx v1.22 SV_DEV-825 S1 名刺詳細画面 URL(Web)をhref対応して欲しい
 *                  2018.03.xx v1.22 SV_DEV-823 Salesforce1 のToDoの詳細画面で期日がnullで表示されている。 → Safari 系 で発生  → 日時を unix time で受け渡す
 *
 * SB_NameCard_S2Controller Mobile 新UI用
 *  @Version 2.1  2018.11.xx API 32.0 以降 UserProfile が使えないので、 User に変更
 *     SV_DEV-1237 SmartViscaカメラの所有者選択で2千人を超えるユーザー数のサポート
 *  @Version 2.2  2019.03.xx
 *      SV_DEV-1526 モバイル 新UI 検索ページのキャプションに「Search by Company Name / Name / Email / Phone」とあるが、実際には、項目は絞っていない
 *  @Version 2.4  2019.06.xx
 *   v2.4 2019.06.xx SV_DEV-1830 要望 SmartViscaアプリでタグの登録エラーの場合、メッセージを表示してほしい
 *                    SV_DEV-1690 【SmartViscaタブ】「タグ付き名刺」に他人所有の名刺も表示してほしい
 *                    createActivityList をきれいにした ← SV_DEV-1522 モバイル 新UI 活動編集画面で取引先または取引先責任者のみ関連づけされている（名刺には関連付けされない）「Todo」「行動」を編集した場合にエラーになる。
 *                    SV_DEV-1418 モバイル 新UI 『組織』情報 でカスタム設定「S組織情報に役職を表示する」が有効状態の時に役職が重複して表示される
 *                    SV_DEV-1920 モバイル SmartViscaメニュー 新UI で 開くリストを設定で決める
 *  @Version 2.4.6 2020.02.xx オプテージ対応
 *  2020.02.xx v2.4.6 SV_DEV-2496 SmartViscaタブ 一覧にリストされる タグとリスト名はログインユーザ所有の名刺に付与されたタグとリスト名にする。
 *  2020.02.xx v2.4.6 SV_DEV-2495 @RemoteAction getNameCardDetail の tagsでリスト名も返す。タグかリスト名か判別可能にする
 *  @Version 2.5  2020.03.xx
 *        SV_DEV-2487 【SmartViscaタブ】 個人タグの取得対象のレコードを、実行ユーザ所有の名刺レコードと、実行ユーザ可視の名刺レコードのいずれを対象にするか設定できるようにする。（タグ付き名刺所得APIの修正）
 *        SV_DEV-2528 「リスト名」が全角数字を含む場合に名刺詳細で2つ表示される
 *        SV_DEV-2518 個人タグの追加時に「リスト名」が個人タグとして登録される
 *        SV_DEV-2530 S1 新SmartViscaタブ：「リスト名」に個人タグとして登録できない文字がある場合にタグ登録時にエラーになる
 *        SV_DEV-2517 S1 新SmartViscaタブ：【例外】個人タグが作成上限数以上設定した場合に「Apex CPU time limit exceeded」になる場合がある。
 *
 **/
public with sharing class SB_NameCard_S2Controller {
  public class SB_NameCard_S2ControllerException extends Exception {}

  // クエリのOFFSET指定のガバナ制限値 System.Limit クラスでは取れなさげ
  private static final Integer OFFSET_LIMIT = 2000;
  // 管理パッケージの名前空間名を
  public static String namespace {
    get {
      if (namespace == null) {
        namespace = String.isNotBlank(getSVConfig().sExtraNamespace) ?
        getSVConfig().sExtraNamespace : SB_NameCard_Util.getNamespacePrefix();
      }
      return namespace;
    }
    private set;
  }

  // JavaScript Remoting のときの レスポンス
  public class Response {
  public boolean status = true;
    public String message;
    public void setResponse(Exception ex) {
      this.status = false;
      this.message = ex.getMessage();
    }
    public void setResponse(String msg) {
      this.status = false;
      this.message = msg;
    }
  }

  // public String inputValue { get; set;}

  // 地理位置情報を設定するために一度に名刺情報を取得する件数
  public Integer getSGeolocationQueryLimit() { return SB_NameCard_Util.smartViscaConfig.SGeolocationQueryLimit__c.intValue(); }
  // 地理位置情報を取得するときのGoogleに問い合わせる間隔
  public Integer getSGeolocationQueryInterval() { return SB_NameCard_Util.smartViscaConfig.SGeolocationQueryInterval__c.intValue(); }
  // 名刺の編集を行う
  public Boolean getSEnableNameCardEdit() { return SB_NameCard_Util.smartViscaConfig.SEnableNameCardEdit__c;}
  // 地理情報を使う
  public Boolean getSUseGIS() { return SB_NameCard_Util.smartViscaConfig.SUseGIS__c;}
  // 行動やToDoは標準の画面を使う
  public Boolean getSUseStandardActivityUI() { return SB_NameCard_Util.smartViscaConfig.SUseStandardActivityUI__c;}
  // 名刺の個人タグが使用可能
  public static Boolean isEnableNameCardTagPersonal() { return enableNameCardTagPersonal;}
  private static Boolean enableNameCardTagPersonal {
    get {
      if (enableNameCardTagPersonal == null) {
        enableNameCardTagPersonal = false;
        try {
          String prefix = String.isBlank(namespace) ? '' : namespace + '__';
          Schema.SObjectType targetType = Schema.getGlobalDescribe().get(prefix + 'NameCard__tag');
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
  // Chatterが有効になってるか？
  public static Boolean isEnableFeedItem() { return enableFeedItem;}
  private static Boolean enableFeedItem {
    get {
      if (enableFeedItem == null) {
        if (Test.isRunningTest() == false) {
          // 管理パッケージのインストール先組織では、getGlobalDescribe で FeedItem がとれてくるみたい。
          // かわりに便利なクラスが存在。しかし、テスト実行ではエラーになる。
          // System.UnsupportedOperationException: ConnectApi methods are not supported in data siloed tests. Please use @IsTest(SeeAllData=true).
          enableFeedItem = ConnectApi.Organization.getSettings().features.chatter;
        }
        else {
          enableFeedItem = false;
        }
      }
      return enableFeedItem;
    }
    private set;
  }

  public String userId { get; private set; }
  public Boolean debug { get; private set; }
  public Boolean devMode { get; private set; }
  public String clientIPAddress { get; private set; }
  private String userAgent;
  public Boolean iOSDevice { get; private set; }  // iPhone版 Salesforce1なら true
  public Boolean iOS8 { get; private set; }  // iPhone OS/8 とかだったら true  2014/10/22
  public Boolean android { get; private set; }  // iPhone OS/8 とかだったら true  2014/10/22

  public SB_NameCard_S2Controller() {
    String s = System.currentPageReference().getParameters().get('debug');
    if (String.isNotBlank(s) && (s.equals('1') || s.toUpperCase().equals('TRUE')))
      this.debug = true;
    else
      this.debug = false;
    this.userId = System.currentPageReference().getParameters().get('userid');
    if (String.isBlank(userId) == true) userId = UserInfo.getUserId();
      devMode = (UserInfo.getUserEmail() == 'hsawano@sunbridge.com');
    this.userAgent = ApexPages.currentPage().getHeaders().get('USER-AGENT');                 // ブラウザの UserAgent
    clientIPAddress = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');     // クライアントIPアドレス
    System.debug('USER-AGENT : ' + userAgent);
    // iPhone OS/7.1.2 (iPhone) Salesforce1/6.0.1(3000685) XBranding/1.0 SalesforceTouchContainer/2.0 Mozilla/5.0 (iPhone; CPU iPhone OS 7_1_2 like Mac OS X) AppleWebKit/537.51.2 (KHTML, like Gecko) Mobile/11D257 (441818336)
    // iPhone OS/7.1.2 (iPad) Salesforce1/6.0.1(3000685) XBranding/1.0 SalesforceTouchContainer/2.0 Mozilla/5.0 (iPad; CPU OS 7_1_2 like Mac OS X) AppleWebKit/537.51.2 (KHTML, like Gecko) Mobile/11D257 (371725360)
    // iPhone OS/8.1 (iPhone) Salesforce1/6.0.4(3000747) XBranding/1.0 SalesforceTouchContainer/2.0 Mozilla/5.0 (iPhone; CPU iPhone OS 8_1 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Mobile/12B411 (371462944)
    // iPhone OS/8.1 (iPad) Salesforce1/6.0.4(3000747) XBranding/1.0 SalesforceTouchContainer/2.0 Mozilla/5.0 (iPad; CPU OS 8_1 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Mobile/12B410 (413432672)
    // Mozilla/5.0 (Linux; Android 4.4.2; D6503 Build/17.1.2.A.0.314) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/30.0.0.0 Mobile Safari/537.36 Salesforce1/5.3.2XBranding/1.0
    // SalesforceMobileSDK/2.2.3 android mobile/5.0.2 ( D6503) Salesforce1/7.2.1 Native XBranding/1.0 SalesforceTouchContainer/2.0 Mozilla/5.0 (Linux; Android 5.0.2; D6503 Build/23.1.A.1.28; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/43.0.2357.121 Mobile Safari/537.36
    this.iOSDevice = false;  //
    this.iOS8 = false;
    this.android = false;
    // USER-AGENT に所定の文字列（iPhone　iPad iPod など）がある場合、iOSと判断、クライアント側で処理を分ける。
    String[] tests = System.Label.SB_NC_iOSDevice.split('[,\\s]+');
    for (String t : tests) {
      if (String.isBlank(userAgent) == false &&
          SB_NameCard_MojiWidthUtil.findIgnoreCaseWidth(userAgent,SB_NameCard_MojiWidthUtil.toHalfWidth(t)) && SB_NameCard_MojiWidthUtil.findIgnoreCaseWidth(userAgent,SB_NameCard_MojiWidthUtil.toHalfWidth('Salesforce1')))  {
        this.iOSDevice = true;
        this.iOS8 = isIOS8(userAgent);
      }
    }
    System.debug('iOSDevice : ' + iOSDevice);
    this.android = (iOSDevice == false && String.isBlank(userAgent) == false && SB_NameCard_MojiWidthUtil.findIgnoreCaseWidth(userAgent,SB_NameCard_MojiWidthUtil.toHalfWidth('Android')));
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

  // 諸設定を取得
  @RemoteAction
  public static SB_NameCard_SvConfig getSVConfig() {
    // v2.4 設定専用のクラスを用意しました。
    return new SB_NameCard_SvConfig();
  }

  // ユーザの設定を保存する。
  @RemoteAction
  public static void saveUserSetting(Map<String, Object> valeus) {
    SB_NameCard_SvConfig.saveSetting(valeus);
  }

  private static final String STR_NameCardFields = 'Id, Name, name_kana__c, person_name_last__c, person_name_first__c' +
  ', company_name__c, company_name_kana__c, division__c, title_name__c' +
  ', zip_code__c, address_pref__c, address__c, address_bld__c, address_eng__c' +
  ', card_exchange_date__c, list_name__c, OwnerId, Owner.Name, Parent__c, tenshokugonomeishi__c, account__c, contact__c' +
  ', freehandmemo__c, memo__c, web_url1__c, email__c, tel1__c, mobile__c, fax1__c' +
  ', image_id__c, bk_image_id__c, width__c, height__c, bk_width__c, bk_height__c';

  private static final String STR_NameCardFieldsList = 'Id, Name, name_kana__c, person_name_last__c, person_name_first__c' +
  ', company_name__c, company_name_kana__c, division__c, title_name__c' +
  ', card_exchange_date__c, list_name__c, OwnerId, Owner.Name, Parent__c, tenshokugonomeishi__c' +
  ', image_id__c, bk_image_id__c, width__c, height__c, bk_width__c, bk_height__c';

  /**
  *   名刺一覧の取得
  *
  **/
  @RemoteAction
  public static List<NameCard__c> getNameCardList(Boolean mineOnly) {
    String condition =
    (mineOnly == true ? ' OwnerId = \'' + UserInfo.getUserId() + '\'' : '' );
//            ' and Parent__c = null';  // 最新の名刺のみ
    if (SB_NameCard_Util.smartViscaConfig.SIgnoreJobChanged__c == true) {  // 転職済み の名刺は表示しない
      if (String.isBlank(condition) == false) condition += ' AND';
      condition += ' tenshokuzumi__c=false';
    }

    String queryString =
    'SELECT ' + STR_NameCardFieldsList +
    ' FROM NameCard__c' +
    (String.isBlank(condition) == false ? ' where' + condition : '') +
    ' ORDER BY' +
//            ' person_name_last_kana__c, person_name_first_kana__c NULLS LAST' +
      ' card_exchange_date__c DESC NULLS LAST' +      // 名刺交換日
      ' LIMIT ' +
      (mineOnly == true ?
        SB_NameCard_Util.smartViscaConfig.SListQueryMineLimit__c.format() :
        SB_NameCard_Util.smartViscaConfig.SListQueryVisibleLimit__c.format() );
      System.debug('++getNameCardList : '+ queryString);
    // Run and return the query results
    return(database.Query(queryString));
    }

  // 検索の条件
  public Class SearchRequest {
    public String word  { get; private set; }
    public String index { get; private set; }   // インデックス検索の 文字
    public String target  { get; private set; }  // 'MineOnly',  'All', 'Recent', 'Actual', 'User'
    public String userId { get; private set; }  //
    public Integer page { get; private set; }   // ページ指定  1から開始
    public void setTarget(String target) {  //テストクラス用
      this.target = target;
    }
    public void setWord(String word) {//テストクラス用
      this.word = word;
    }
    public void setIndex(String index) {//テストクラス用
      this.index = index;
    }
    public void setPage(Integer page) {//テストクラス用
      this.page = page;
    }
  }
  /**
  *   名刺の検索
  **/
  @RemoteAction
  public static List<NameCard__c> searchNameCards(SearchRequest req) {
    List<NameCard__c> results =null;
    Boolean mineOnly = (String.isBlank(req.target) == false &&
        (SB_NameCard_MojiWidthUtil.findIgnoreCaseWidth(req.target,SB_NameCard_MojiWidthUtil.toHalfWidth('MineOnly')) ||
          SB_NameCard_MojiWidthUtil.findIgnoreCaseWidth(req.target,SB_NameCard_MojiWidthUtil.toHalfWidth('Actual'))));
    String userId = mineOnly ? UserInfo.getUserId() : (String.isBlank(req.userId) ?  '' : req.userId);
    String condition =
    (String.isBlank(userId) == false ? ' OwnerId = \'' + userId + '\'' : '' );
    String orderby = ' order by card_exchange_date__c DESC NULLS LAST';
    String limits = ' limit ' +
        (mineOnly == true ?
          SB_NameCard_Util.smartViscaConfig.SListQueryMineLimit__c.format() :
          SB_NameCard_Util.smartViscaConfig.SListQueryVisibleLimit__c.format() );
    // 最近みた名刺だったら、ID を絞り込む
    List<Id> ids = null;
    if (String.isBlank(req.target) == false && SB_NameCard_MojiWidthUtil.findIgnoreCaseWidth(req.target,SB_NameCard_MojiWidthUtil.toHalfWidth('Recent'))) {
      ids = getRecentNameCardIds();
      if (ids.isEmpty() == false) {
        if (String.isBlank(condition) == false)  condition += ' AND';
          condition += ' Id IN :ids';
      }
    }
    if (SB_NameCard_Util.smartViscaConfig.SIgnoreJobChanged__c == true) {  // 転職済み の名刺は表示しない
      if (String.isBlank(condition) == false) condition += ' AND';
      condition += ' tenshokuzumi__c=false';
    }
    // 検索条件の有無で SOQL SOSL を分ける
    if (String.isBlank(req.word) == true) {
      // SOQL
      String queryString =
      'SELECT '+ STR_NameCardFieldsList
      + ' from NameCard__c' +
      + (String.isBlank(condition) == false ? ' where' + condition : '')
        + orderby   // 名刺交換日
        + limits;
      System.debug('++searchNameCards SOQL : '+ queryString);
      results = database.Query(queryString);
    }
    else {
      // SOSL
      String searchWord = SB_NameCard_Util.escapeSOSLYoyakugo(req.word);    // 2016.10.xx SOLS予約語をエスケープする
      String queryString =
      'FIND {' + searchWord + '} IN ALL FIELDS RETURNING NameCard__c('
        + STR_NameCardFieldsList
        + (String.isBlank(condition) == false ? ' where' + condition : '')
        + orderby       // 名刺交換日
        + limits +')';
      System.debug('++searchNameCards SOQL : '+ queryString);
      List<List<sObject>> searchList = search.query(queryString);
      if (searchList.isEmpty() == false)
      results = searchList[0];
    }
    return results;
  }

  // 一覧取得のレスポンス
  public Class SearchResponse {
    public Integer pageNo { get; private set; }         // 取得してページ 1〜
    public Integer pageSize { get; private set; }       // 首都木した件数
    public Boolean toBeCont { get; private set; }       // 継続があるか？
    // public List<NameCard__c> cards { get; private set; }    // 取得したレコード
    public List<Map<String, Object>> cards  { get; private set; }    // v2.1 ノーマライズした取得したレコードを
    public SearchResponse(Integer pageNo, Integer pageSize, List<NameCard__c> cards) {
      this.pageNo = pageNo;
      this.pageSize = pageSize;
      this.toBeCont = cards.size() > pageSize;    // ページサイズよりおおければ、継続あり
      // 次 オフセットが OFFSET_LIMIT を超えるときは toBeCont を FALSE にする。
      this.toBeCont = (pageNo * pageSize) > OFFSET_LIMIT ?  false : this.toBeCont;
      // this.cards = cards;
      // if (cards.size() > pageSize) { // ページサイズよりおおければ、最後の1つ削る。
      //   this.cards.remove(pageSize);
      // }
      this.cards = new List<Map<String, Object>>();
      for (Integer n = 0; n < cards.size() && n < pageSize; n++) {
        this.cards.add(SB_NC_NameCardDTO.buildNomalizeKeyMap(cards[n]));
      }
    }
  }

  // SOSL で特定に項目値で絞り込む
  // 2019.03.xx v2.2
  // SV_DEV-1526 モバイル 新UI 検索ページのキャプションに「Search by Company Name / Name / Email / Phone」とあるが、実際には、項目は絞っていない
  @TestVisible
  private static String getSearchResultFilter(String word) {
    List<String> conditions = new List<String>();
    List<String> fields = Label.SB_NCS1_Text_SearchFilterFields.split('[,\\s]+');
    for (String f : fields) {
      conditions.add(String.format('{0} LIKE \'\'%{1}%\'\'', new String[] { f, word }));
    }
    return String.format('({0})', new String[]{ String.join(conditions, ' OR ')});
  }

  /**
  *   名刺の検索 オフセット対応
  *       オフセット指定は最大 OFFSET_LIMIT まで エラーは NUMBER_OUTSIDE_VALID_RANGE
  **/
  @RemoteAction
  public static SearchResponse searchNameCardsEx(SearchRequest req) {
    // 検索条件を作る
    List<String> conditions = new List<String>();
    // 所有者
    Boolean mineOnly = (String.isBlank(req.target) == false &&
              (SB_NameCard_MojiWidthUtil.findIgnoreCaseWidth(req.target,SB_NameCard_MojiWidthUtil.toHalfWidth('MineOnly')) ||        // 自分の
              SB_NameCard_MojiWidthUtil.findIgnoreCaseWidth(req.target,SB_NameCard_MojiWidthUtil.toHalfWidth('Actual'))));          // 大事な
    if (mineOnly || String.isNotBlank(req.userId)) {
      conditions.add(String.format('OwnerId = \'\'{0}\'\'', new String[] { (mineOnly ? UserInfo.getUserId() : req.userId) }));
    }
    // 最近の名刺
    Boolean recent = String.isBlank(req.target) == false && SB_NameCard_MojiWidthUtil.findIgnoreCaseWidth(req.target,SB_NameCard_MojiWidthUtil.toHalfWidth('Recent'));
    // String userId = mineOnly ? UserInfo.getUserId() : (String.isBlank(req.userId) ?  '' : req.userId);
    // String condition = (String.isBlank(userId) == false ? ' OwnerId = \'' + userId + '\'' : '' );
    if (mineOnly == false && recent ==false
      && SB_NameCard_Util.smartViscaConfig.SSearchAllIgnoreDeliveryType__c == false) {
      // 自分の名刺と最近見たい名刺 以外の時は 2次納品が対象
      conditions.add('delivery_type__c=\'2\'');
      if (!SB_NameCard_Util.smartViscaConfig.SListQueryIgnoreLatestCard__c) {      // 2016.09.xx 名刺一覧のみんなの名刺は最新の名刺以外も対象にする 以前は かならず、最新の名刺のみだった
        conditions.add('Parent__c=null');
      }
    }
    if (SB_NameCard_Util.smartViscaConfig.SIgnoreJobChanged__c == true) {  // 転職済み の名刺は表示しない
      conditions.add('tenshokuzumi__c=false');
    }
    if (String.isBlank(req.index) == false) {   // インデックス検索のとき
      // String charSet = '(';
      String[] ss = req.index.split('.{0}');
      // SV_DEV-1380 モバイル 新UI 頭文字検索でアルファベットを選択した場合にエラーになる
      // // ss.remove(0); v2.1 不要 SController.cls の方では必要、APIバージョンの違いか。
      // for (String s : ss) {
      //   charSet += '\'' + s + '\',';
      // }
      // charSet = charSet.removeEnd(',') + ')';
      // condition += String.isBlank(condition) ? '' : ' AND';
      String charSet = String.join(ss, '\', \'');
      conditions.add(String.format('Person_Name_Last_Kana_1st__c IN (\'\'{0}\'\')', new String[]{ charSet}));  // 姓カナの1文字目 がわたされた文字列のうちのどれか
    }
    // ソート インデックス検索 以外 ： 名刺交換日 降順 ＋ ID 降順 インデックス検索のとき : カナの姓名（or 英字の姓名）昇順
    String orderby =  String.isBlank(req.index) ?
        ' ORDER BY card_exchange_date__c DESC NULLS LAST, Id DESC NULLS LAST'
        : ' ORDER BY name_kana__c ASC NULLS LAST';
    // 一度の読み込む件数 の設定
    Integer size = mineOnly == true ?
          SB_NameCard_Util.smartViscaConfig.SListQueryMineLimit__c.intValue() :       // 自分の
          SB_NameCard_Util.smartViscaConfig.SListQueryVisibleLimit__c.intValue();     // みんなの
    // 設定より１件多く取得を試みて、継続があるか判断する。
    String pisition = ' LIMIT ' + String.valueOf(size+1) +
    (req.page != null && req.page > 1 ? ' OFFSET ' + String.valueOf(size*(req.page-1)) : '');
    // 最近みた名刺だったら、ID を絞り込む
    List<Id> ids = null;
    if (recent) {
      // ids = getRecentNameCardIds();
      // if (ids.isEmpty() == false) {
        // if (String.isBlank(condition) == false) condition += ' AND';    // 2014.10.25 ANDの前が全角だった
        conditions.add('LastViewedDate != null');
        orderby = ' ORDER BY LastViewedDate DESC';  // ORDER BY を上書きます。
      // }
    }

    List<NameCard__c> cards =null;
    // 文字列検索条件の有無で SOQL SOSL を分ける
    if (String.isBlank(req.word) == true ) {
      // SOQL
      String condition = !conditions.isEmpty() ? 'WHERE ' + String.join(conditions, ' AND ') : '';
      String queryString = String.format('SELECT {0} FROM NameCard__c {1} {2} {3}',
            new String[] {STR_NameCardFieldsList, condition, orderby, pisition});
      // 'SELECT '+ STR_NameCardFieldsList
      // + ' FROM NameCard__c' +
      // + (String.isBlank(condition) == false ? ' where' + condition : '')
      //   + orderby   // 名刺交換日　DESC
      //   + pisition; // limit  offset
      System.debug('++searchNameCardsEx SOQL : '+ queryString);
      cards = database.Query(queryString);
    }
    else {
      if (req.word.length() == 1 && req.word.isAsciiPrintable()) {
        throw new SB_NameCard_S2ControllerException(System.Label.SB_MSG_MoreThanOneLetter); // 2018.12.xx v2.1 SV_DEV-1386 モバイル 新UI 検索を１文字で検索した場合にエラーが表示される/されない場合/複数回表示がされる
      }
      // SOSL
      if (SB_NameCard_Util.smartViscaConfig.SFilterSearchResult__c) {
        // 2019.03.xx v2.2
        conditions.add(getSearchResultFilter(req.word));
      }
      String condition = !conditions.isEmpty() ? String.join(conditions, ' AND ') : '';
      String prefix = String.isBlank(namespace) ? '' : namespace + '__';
      String searchWord = SB_NameCard_Util.escapeSOSLYoyakugo(req.word);      // 2016.10.xx SOLS予約語をエスケープする
      String queryString =
        'FIND {' + searchWord + '} IN ALL FIELDS RETURNING ' + prefix + 'NameCard__c('    // SOSLでは、オブジェクト名には名前空間名が必要
        + STR_NameCardFieldsList           // フィールド名には名前空間名不用
        + (String.isBlank(condition) == false ? ' WHERE ' + condition : '')
        + orderby       // 名刺交換日
        + pisition +')';
      System.debug('++searchNameCardsEx SOSL : '+ queryString);
      try {
        List<List<sObject>> searchList = Search.query(queryString);
        if (searchList.isEmpty() == false)
          cards = searchList[0];
      }
      catch(Exception e) {
        if (req.word.length() == 1) {
          throw new SB_NameCard_S2ControllerException(System.Label.SB_MSG_MoreThanOneLetter); // 2018.12.xx v2.1 SV_DEV-1386 モバイル 新UI 検索を１文字で検索した場合にエラーが表示される/されない場合/複数回表示がされる
        }
        if (req.word.replaceAll('[*?()""]', '').length() == 1) {
          // SOSLの予約後+1文字のとき
          throw new SB_NameCard_S2ControllerException(System.Label.SB_NC_SoslOneCharacterWithReservedCharacters); // 2019.01.xx v2.1 SV_DEV-1459 モバイル 新UI 検索で特定の文字が先頭にある状態で検索した場合に「Script-thrown exception」エラーになる。
        }
        else {
          throw new SB_NameCard_S2ControllerException(e.getMessage());
        }
      }
    }
    SearchResponse res = new SearchResponse(req.page, size, cards);
    return res;
  }


/*
  // 名前空間名をフィードに付与する。SOQL 用に
  private static String getTextWithNamespace_x(String text) {
    String prefix = String.isBlank(namespace) ? '' : namespace + '__';
    if (String.isBlank(prefix) == true) return text;
    String result = '';
    String[] ss = text.split('[,\\s]+');
    for (String s : ss) {
      if (s.endsWith('__c')) {  // カスタム項目
        result += prefix + s +', ';
      }
      else {      // 標準項目
        result += s +', ';
      }
    }
    return result.removeEnd(', ');
  }
  */

  // 最近みた名刺のIDのリスト
  @TestVisible
  private static List<Id> getRecentNameCardIds() {
    List<Id> results = new List<Id>();
    // 2014.10.25 名前空間を意識してなかった、修正
    String query = 'SELECT Id FROM RecentlyViewed WHERE Type=\'';
    query += String.isBlank(namespace) ? '' : namespace + '__';
    query += +'NameCard__c\'';
    List<RecentlyViewed> vieweds = Database.query(query);
    for (RecentlyViewed v : vieweds) {
      results.add(v.Id);
    }
    return results;
  }

  /**
  *   タグまたはリスト名のリスト取得
  *   type  0： 個人の  1:公開の 2:両方
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
  *   タグ付きまたはリスト名付きの 名刺のリスト取得
  **/
  @RemoteAction
  public static List<SB_NameCard_TagAndListCollector.TagdNameCards> getTagdNameCards() {
    SB_NameCard_TagAndListCollector.TagdNameCardsRequest instance = new SB_NameCard_TagAndListCollector.TagdNameCardsRequest();
    return instance.create();
  }

  /**
  * 名刺にタグをつける
  *
  *   v2.5 2020.03.xx SV_DEV-2528 「リスト名」が全角数字を含む場合に名刺詳細で2つ表示される
  *      → というか、新SVでは、tagLabels にリスト名もわたされてたので、それをタグとして登録してた。なので、リスト名は全部タグになってた。
  *         リスト名がリクエストにあったら、1つ除外する。だけど、２つ目以降は除外しないので、タグになる。
  *         あと、同じタグも INSERTしてるが、重複するわけではないので、無視。
  **/
  @RemoteAction
  public static NameCardDetail saveNameCardTag(String idTarget, List<String> tagLabels) {
    try {
      String lname;
      lname = [SELECT Id, list_name__c FROM NameCard__c WHERE Id = :idTarget LIMIT 1].list_name__c;
      if (String.isNotBlank(lname) && tagLabels.indexOf(lname) != -1 ) {
        tagLabels.remove(tagLabels.indexOf(lname));
      }
    }
    catch(Exception e) {  }   // 例外はきにしない。
    List<sObject> tags = new List<sObject>();
    for (String tagLabel : tagLabels) {
      NameCardTagDTO dto = new NameCardTagDTO();
      dto.name = tagLabel;
      dto.cardId = idTarget;
      dto.type = 'Personal';
      tags.add(dto.create());     // タグ レコード作成
    }
    insert tags;
    // v2.4 2019.06.xx SV_DEV-1830 要望 SmartViscaアプリでタグの登録エラーの場合、メッセージを表示してほしい
    // 例外はそのまま、クライアントに送ります。
    return getNameCardDetail(idTarget);
  }

  // タグを削除
  private static void removeNameCardTag(List<String> cardIds, String label) {
    String tagQuery = 'Select Id from NameCard__Tag where ItemId IN :cardIds' +
            ' And Name = :label And Type=\'Personal\'';
    // パッケージ作成環境とかで、タグがつかえないところでテストするから対策
    List<sObject> tags = enableNameCardTagPersonal ? database.query(tagQuery) : new List<sObject>();
    // List<NameCard__Tag> tags = [Select Id from NameCard__Tag where ItemId IN :cardIds
              // And Name = :label And Type='Personal'];
    if (tags.isEmpty() != true) {
      delete tags;
    }
  }

  // 名刺のリスト名をクリア
  private static void removeNameCardList(List<String> cardIds, String label) {
    List<NameCard__c> cards = [Select Id, list_name__c From NameCard__c
    Where Id IN :cardIds And list_name__c=:label];
    if (cards.isEmpty() == true) return;
    for (NameCard__c card :cards) {
      card.list_name__c = null;
    }
    update cards;
  }

  /**
  * 名刺からタグ または 名刺リストを削除
  *
  **/
  @RemoteAction
  public static Response removeNameCardTag(List<String> cardIds, String label, Boolean tagIsTag) {
    Response res = new Response();
    try {
      if (tagIsTag == true) {
          // タグ
          removeNameCardTag(cardIds, label);
      }
      else {
        // リスト名
        removeNameCardList(cardIds, label);
      }
    }
    catch(Exception ex) {
        res.setResponse(ex);
    }
    return res;
  }

  @RemoteAction
  public static List<NameCard__c> getNameCardsWithoutLabel(String label, Boolean tagIsTag) {
    if (tagIsTag == true) {
      return getNameCardsWithoutTag(label);
    }
    else {
      return getNameCardsWithoutList(label);
    }
  }

  // 指定のタグのついてない名刺のリストを取得 動的に
  private static List<NameCard__c> getNameCardsWithoutTag(String label) {
    String tagQuery = 'SELECT ItemId FROM NameCard__tag' +
    ' Where ItemId != null AND Name=\'' + label  + '\' AND Type=\'Personal\'';
    // パッケージ作成環境とかで、タグがつかえないところでテストするから対策
    List<sObject> tags = enableNameCardTagPersonal ? database.query(tagQuery) : new List<sObject>();
    Set<Id> ids = new Set<Id>();
    for (sObject tag : tags) {
      ids.add((Id)tag.get('ItemId'));
    }
    List<NameCard__c> results = [select Id, Name, company_name__c, division__c, title_name__c, card_exchange_date__c
          , person_name_last_kana__c, person_name_first_kana__c
          , email__c, tel1__c, tel2__c, mobile__c, image_id__c, list_name__c
                     from NameCard__c where id not in :ids and OwnerId = :UserInfo.getUserId() LIMIT 5000];
    return results;
  }

  // 指定の名刺リストのついてない名刺のリストを取得
  private static List<NameCard__c> getNameCardsWithoutList(String label) {
    List<NameCard__c> results = [select Id, Name, company_name__c, division__c, title_name__c, card_exchange_date__c
    , person_name_last_kana__c, person_name_first_kana__c
    , email__c, tel1__c, tel2__c, mobile__c, image_id__c, list_name__c
    from NameCard__c where list_name__c != :label and OwnerId = :UserInfo.getUserId() LIMIT 5000];
    return results;
  }

  /**
  * 複数の名刺に、  タグをつける。
  * または、
  * 名刺リストの値を更新する。名刺リストは1つなので、既存の名刺リストは上書きされる。
  *
  **/
  public class TaggingRequest {
    public List<String> labels { get; private set; }
    public Boolean tagIsTag { get; public set; }     // TRUE:タグ FALSE:名刺リスト
    public List<String> nameCardIds { get; private set; }
    public TaggingRequest() {
      labels = new List<String>();
      tagIsTag = true;
      nameCardIds = new List<String>();
    }
  }
  @RemoteAction
  public static Response bindNameCardsToLabel(TaggingRequest req) {
    Response res = new Response();
    try {
      if (req.labels == null || req.labels.isEmpty())
        throw new SB_NameCard_S2ControllerException(System.Label.SB_MSG_IllegalRequest);
      if (req.nameCardIds == null || req.nameCardIds.isEmpty())
        throw new SB_NameCard_S2ControllerException(System.Label.SB_MSG_IllegalRequest);
      if (req.tagIsTag == true) {
        return bindNameCardsToTag(req);
      }
      else {
        return bindNameCardsToList(req);
      }
    }
    catch(Exception ex) {
      res.setResponse(ex);
    }
    return res;
  }
  // 名刺に既存のタグをつける。
  private static Response bindNameCardsToTag(TaggingRequest req) {
    // List<NameCard__Tag> tags = [SELECT ItemId, Name, Type
              // FROM NameCard__Tag where Name = :req.label
                // and Type='Personal'
                // and ItemId not in :req.nameCardIds];
                Response res = new Response();
/*      List<NameCard__Tag> tags = new List<NameCard__Tag>();
    for (String cardId : req.nameCardIds) {
      for (String label : req.labels) {
        tags.add( new NameCard__Tag(ItemId = cardId, Name=label, Type='Personal'));     // タグ レコード作成
      }
      }*/
    List<sObject> tags = new List<sObject>();
    for (String cardId : req.nameCardIds) {
      for (String label : req.labels) {
        NameCardTagDTO dto = new NameCardTagDTO();
        dto.name = label;
        dto.cardId = cardId;
        dto.type = 'Personal';
        // パッケージ作成環境とかで、タグがつかえないところでテストするから対策
        if (enableNameCardTagPersonal == true)
          tags.add(dto.create());     // タグ レコード作成
      }
    }
    try {
      if (tags.isEmpty() == false)
        insert tags;
    }
    catch(Exception ex) {
      System.debug(ex.getMessage());
      res.setResponse(ex);
    }
    return res;
  }

  // 名刺の（既存の）名刺リストを更新する。
  private static Response bindNameCardsToList(TaggingRequest req) {
    Response res = new Response();
    List<NameCard__c> cards = [select Id, Name, list_name__c from NameCard__c where Id in :req.nameCardIds];
    for (NameCard__c card : cards) {
      card.list_name__c = req.labels[0];
    }
    try {
      update cards;
    }
    catch(Exception ex) {
      System.debug(ex.getMessage());
      res.setResponse(ex);
    }
    return res;
  }

  /**
  *   最近みた名刺
  **/
  @RemoteAction
  public static List<NameCard__c> getRecentViewedCards() {
    List<RecentlyViewed> vieweds = [SELECT Id,LastReferencedDate,LastViewedDate,Name,Type
                from RecentlyViewed
      where Type='NameCard__c' order by LastViewedDate DESC];
    if (vieweds.isEmpty() == true) return new List<NameCard__c>();
    List<Id> ids = new List<Id>();
    for (RecentlyViewed v : vieweds) {
      ids.add(v.Id);
    }
    // return [select Id, Name, company_name__c, division__c, title_name__c, card_exchange_date__c
    //   , person_name_last_kana__c, person_name_first_kana__c
    //   , email__c, tel1__c, tel2__c, mobile__c, image_id__c
    //   from NameCard__c where Id IN :ids ];
    return [select Id, Name, company_name__c, division__c, title_name__c, card_exchange_date__c
      , person_name_last_kana__c, person_name_first_kana__c
      , email__c, tel1__c, tel2__c, mobile__c, image_id__c
      from NameCard__c where LastViewedDate!=null ORDER BY LastViewedDate DESC ];

  }

/*
  @RemoteAction
  public static String query() {
    List<NameCard__c> cards = [select Id, Name, company_name__c, division__c, title_name__c,
//              Person_Name_Last_Kana_1st__c, Person_Name_Last_Kana_1stA__c,
        email__c, tel1__c, tel2__c, mobile__c, image_id__c
        from NameCard__c order by person_name_last_kana__c, person_name_first_kana__c NULLS LAST];
    return JSON.serialize(cards);

  }
  */
  // v2.4.6 2020.02.xx
  public class TagOrList {
    public String label { get; private set; } // タグ名 または リスト名
    public Boolean isTag { get; private set; } // タグなら TRUE
    public Boolean isListed { get; private set; } // 一覧に表示されているタグ
    public Integer cnt { get; private set; } // SV_DEV-2521 S1 新SmartViscaタブ：名刺詳細のタグに件数が表示されない
    public TagOrList(String label, Boolean isTag) {
      this.label = label;
      this.isTag = isTag;
    }
    public void setCount(Integer cnt) {
      this.cnt = cnt;
    }
    // タグ一覧にあるか
    public void setListed(Boolean isListed) {
      this.isListed = isListed;
    }
  }

  public class NameCardDetail {
    public Map<String, Object>  card { get; private set; }   // v2.1
    public List<TagOrList> tags { get; private set; }
    public NameCardDetail(NameCard__c card) {
      this.card = SB_NC_NameCardDTO.buildNomalizeKeyMap(card);
      this.tags = new List<TagOrList>();
      if (String.isNotBlank(card.list_name__c)) {
        this.tags.add(new TagOrList(card.list_name__c, false));
      }
    }
    public void addTag(TagOrList tag) {
      this.tags.add(tag);
    }
    public void finalize() {
      Set<String> tags = new Set<String>();
      String listname;
      for (TagOrList t : this.tags) {
        if (t.isTag) {
          tags.add(t.label);
        }
        else {
          listname = t.label;
        }
      }
      Map<String, Integer> tag2cnt;
      Map<String, Integer> list2cnt;
      if (!tags.isEmpty()) {
        tag2cnt = getTagdCardCount(tags, false);
      }
      if (String.isNotBlank(listname)) {
        list2cnt = getListdCardCount(new Set<String> { listname }, false);
      }
      Set<String> tagNames = getListedTags();
      for (TagOrList t : this.tags) {
        if (t.isTag && tag2cnt!=null) {
          t.setCount(tag2cnt.get(t.label));
        }
        else if (!t.isTag && list2cnt!=null){
          t.setCount(list2cnt.get(t.label));
        }
        t.setListed(tagNames.contains(t.label));
      }
    }
  }

  // 名刺詳細画面に表示するように名刺のデータを取得する用
  // 2020.02.xx v2.4.6 SV_DEV-2495 @RemoteAction getNameCardDetail の tagsでリスト名も返す。タグかリスト名か判別可能にする
  @RemoteAction
  public static NameCardDetail getNameCardDetail(String idTarget) {
    String queryString =
    'SELECT '+ SB_NC_NameCardDTO.NC_QUERY_FIELDS + ' FROM NameCard__c WHERE Id = :idTarget FOR VIEW'; // FOR VIEW で LastViewedDate が更新される
    List<NameCard__c> cards = Database.query(queryString);      // 照会実施
    if (cards.isEmpty() == true) return null;
    NameCardDetail result = new NameCardDetail(cards[0]);
    // タグを所得 無効化もしれないので、動的APEX で Try Catch する
    try {
      String tagQuery = 'SELECT Id, IsDeleted, ItemId, Name, Type FROM NameCard__Tag' +
        ' WHERE ItemId=:idTarget AND Type = \'Personal\' AND IsDeleted=false AND Name != null' +
        ' Order by Name';
      List<SObject> tags = database.query(tagQuery);
      for (SObject tag : tags) {
        result.addTag(new TagOrList((String)tag.get('Name'), true));
      }
      result.finalize();
    }
    catch(Exception e) {
      System.debug('NameCard__Tag is disable.');
    }
    // 名刺に関連づく Todo、行動を取得
    // result.searchActivities();   // いずれ、ここでやらずに、別途、活動だけを取得する。
    return result;
  }

  // タグ名ごとの名刺数をカウントする
  // SV_DEV-2521 S1 新SmartViscaタブ：名刺詳細のタグに件数が表示されない
  private static Map<String, Integer> getTagdCardCount(Set<String> tags, Boolean mineOnly) {
    Map<String, Integer> result = new Map<String, Integer>();
    try {
      List<SObject> tagds = Database.query('SELECT Id, Name, Type FROM TagDefinition WHERE Name IN :tags AND Type=\'Personal\'');
      Map<Id, String> tagId2Name = new Map<Id, String>();
      for (SObject tagd : tagds) {
        tagId2Name.put(tagd.Id, (String)tagd.get('Name'));
      }
      Id userID = UserInfo.getUserId();
      Set<Id> tagdIds = new Set<Id>(tagId2Name.keySet());
      String countQuery = 'SELECT TagDefinitionId, COUNT(Id) cnt FROM NameCard__Tag WHERE TagDefinitionId IN :tagdIds AND Type=\'Personal\''
        + (mineOnly == true ? ' AND Item.OwnerId = :userID' : '')
        + ' GROUP BY TagDefinitionId';
      List<AggregateResult> ars = Database.query(countQuery);
      for (AggregateResult ar : ars) {
        Id tagId = (Id)ar.get('TagDefinitionId');
        result.put(tagId2Name.get(tagId), (Integer)ar.get('cnt'));
      }
    }
    catch(Exception e) {
      System.debug(e.getMessage());
    }
    return result;
  }

  // リスト名ごとの名刺数をカウントする
  // SV_DEV-2521 S1 新SmartViscaタブ：名刺詳細のタグに件数が表示されない
  private static Map<String, Integer> getListdCardCount(Set<String> lists, Boolean mineOnly) {
    Map<String, Integer> result = new Map<String, Integer>();
    Id userID = UserInfo.getUserId();
    String query = 'SELECT list_name__c lname, COUNT(Id) cnt FROM NameCard__c WHERE list_name__c IN :lists'
      + (mineOnly == true ? ' AND OwnerId = :userID' : '')
      + ' GROUP BY list_name__c';
    List<AggregateResult> ars = Database.query(query);
    for (AggregateResult ar : ars) {
      result.put((String)ar.get('lname'), (Integer)ar.get('cnt'));
    }
    return result;
  }

  // 一覧にでてくるタグのコレクション
  private static Set<String> getListedTags() {
    Set<String> result = new Set<String>();
    List<SB_NameCard_TagAndListCollector.TagdNameCards> listTagdCards = getTagdNameCards();
    for (SB_NameCard_TagAndListCollector.TagdNameCards tc : listTagdCards) {
      result.add(tc.tagLabel);
    }
    return result;
  }


  // 編集用に名刺データを取得する
/*    @RemoteAction
  public static NameCard__c getNameCard(String idTarget) {
    String queryString =
      'SELECT '+ SB_NC_NameCardDTO.NC_QUERY_FIELDS + ' from NameCard__c where Id = :idTarget';
    List<NameCard__c> cards = Database.query(queryString);      // 照会実施
    return cards[0];
  }
  */
  @RemoteAction
  public static SB_NC_NameCardDTO getNameCard(String idTarget) {
    String queryString =
         'SELECT '+ SB_NC_NameCardDTO.NC_QUERY_FIELDS + ' from NameCard__c where Id = :idTarget';
    List<NameCard__c> cards = Database.query(queryString);      // 照会実施
    SB_NC_NameCardDTO card = new SB_NC_NameCardDTO();
    card.bind(cards[0]);
    return card;
  }

  // 名刺を削除する。
  @RemoteAction
  public static Response deleteNameCards(LIST<String> idTargets) {
    Response res = new Response();
    try {
      LIST<NameCard__c> cards = [SELECT Id FROM NameCard__c WHERE Id IN :idTargets];
      Database.delete(cards, true);
    }
    catch(Exception ex) {
      System.debug(ex.getMessage());
      res.setResponse(ex);
    }
    return res;
  }

  // @RemoteAction
  // global static List<SB_NC_NameCardDTO> saveNameCards_Old(List<SB_NC_NameCardDTO> dtos) {
  //   System.debug('++saveNameCards : Id= ' + dtos[0].Id);
  //   System.debug('++saveNameCards : Name= ' + dtos[0].Name);
  //   List<NameCard__c> results = new List<NameCard__c>();
  //   for (SB_NC_NameCardDTO dto : dtos) {
  //     results.add((NameCard__c)dto.create());
  //   }
  //   Database.DMLOptions dml = new Database.DMLOptions();
  //   dml.optAllOrNone = true;
  //   dml.allowFieldTruncation = true;
  //   if (results[0].Id !=null) {
  //     Database.update(results, dml);
  //   }
  //   else {
  //     Database.insert(results, dml);
  //   }
  //   return dtos;
  // }

  @RemoteAction
  public static List<SB_NC_NameCardDTO> saveNameCards(List<SB_NC_NameCardDTO> dtos) {
  // public static List<SB_NC_NameCardDTO> saveNameCards(String input) {
  //   System.debug('input: ' + input);
  //   List<SB_NC_NameCardDTO> dtos = (List<SB_NC_NameCardDTO>)JSON.deserialize(input, List<SB_NC_NameCardDTO>.class);
    System.debug('++saveNameCards : Id= ' + dtos[0].Id);
    System.debug('++saveNameCards : Name= ' + dtos[0].Name);
    List<NameCard__c> cards = new List<NameCard__c>();
    for (SB_NC_NameCardDTO dto : dtos) {
      cards.add((NameCard__c)dto.createSObject());
    }
    Database.DMLOptions dml = new Database.DMLOptions();
    dml.optAllOrNone = true;
    dml.allowFieldTruncation = true;
    if (cards[0].Id !=null) {
      SB_NameCard_CrudFls.supdate(cards, dml);
    }
    else {
      SB_NameCard_CrudFls.screate(cards, dml);
    }
    return dtos;
  }

  // 名刺レコードの保存、SetGeoLocationsではこちらを使います。
  @RemoteAction
  public static List<NameCard__c> saveNameCardsRaw(List<NameCard__c> cards) {
    System.debug('++saveNameCards : Id= ' + cards[0].Id);
    System.debug('++saveNameCards : Name= ' + cards[0].Name);
    Database.DMLOptions dml = new Database.DMLOptions();
    dml.optAllOrNone = true;
    dml.allowFieldTruncation = true;
    if (cards[0].Id !=null) {
      Database.update(cards, dml);
    }
    else {
      Database.insert(cards, dml);
    }
    return cards;
  }

  // getFindNearby の引数用クラス
  public class FindNearbyRequest {
    public Boolean mineOnly { get; public set; }       // 自分所有の名刺だけ
    public String latitude { get; public set; }        // 緯度
    public String longitude { get; public set; }       // 経度
    public String target { get; public set; }          // 探す対象について
    }
  // 要求された地点から設定された距離以内の名刺のリスト取得
  @RemoteAction
  public static List<NameCard__c> getFindNearby(FindNearbyRequest req) {
    String lat, lng;
    lat = req.latitude;
    lng = req.longitude;
    // If geolocation isn't set, use San Francisco
    if(lat == null || lng == null || lat.equals('') || lng.equals('')) {
      lat = '35.679841';
      lng = '139.765092';
    }

    // SOQL query to get the nearest NameCard
    String queryString =
    'SELECT '+ SB_NC_NameCardDTO.NC_QUERY_FIELDS + ', GeoLocation__Longitude__s, GeoLocation__Latitude__s FROM NameCard__c' +
    ' WHERE DISTANCE(GeoLocation__c, GEOLOCATION('+lat+','+lng+'), \'km\') < ' +
    SB_NameCard_Util.smartViscaConfig.SFindNearByQueryDistance__c.format() +
    ' AND OwnerId = \'' + UserInfo.getUserId() + '\'' +
      // ' ORDER BY DISTANCE(GeoLocation__c, GEOLOCATION('+lat+','+lng+'), \'km\')' +
      ' ORDER BY card_exchange_date__c DESC NULLS LAST' +
      ' LIMIT ' + SB_NameCard_Util.smartViscaConfig.SFindNearByQueryLimit__c.format();
      if (Test.isRunningTest()) {
      // パッケージ作成環境で System.QueryException: field 'GeoLocation__c' can not be filtered in query call となるので、
      queryString =
      'SELECT Id, Name, GeoLocation__Longitude__s, GeoLocation__Latitude__s' +
      ', email__c, tel1__c, tel2__c, mobile__c, fax1__c, fax2__c, web_url1__c, web_url2__c' +
      ', company_name__c, company_name_kana__c, zip_code__c, address_pref__c, address__c, address_bld__c' +
      ' FROM NameCard__c' +
      ' WHERE GeoLocation__Longitude__s !=null and GeoLocation__Latitude__s !=null';
      }
    // Run and return the query results
    System.debug('++getFindNearby SOQL : '+ queryString);
    return(database.Query(queryString));
    }

  // 会社名ごとの名刺リスト
  public class NameCardCompany {
    public String companyName { get; private set; }
    public List<NameCard__c> cards { get; private set; }
    public Integer count { get; private set; }
    public NameCardCompany() {
      this.cards = new List<NameCard__c>();
      this.companyName =null;
      this.count = 0;
    }
    public void addCard(NameCard__c card) {
      this.count++;
      System.debug(' CO : ' + card.Name + ' : ' + card.company_name__c + ' : ' + this.count.format());
      if (cards.size() >= SB_NameCard_Util.smartViscaConfig.SMAXMapInfoWindowPersons__c) return; // 設定の枚数を超えてたら追加しない。 infoWindowで表示しない。
      if (String.isBlank(this.companyName) == true) {
        this.companyName = card.company_name__c;
      }
      this.cards.add(card);
    }
  }

  // 緯度経度ごとの 会社ごとの名刺のリスト
  public class NameCardLocation {
    public Decimal lat { get; private set; }
    public Decimal lng { get; private set; }
    public String address { get; private set; }
    public Integer count { get; private set; }
    public List<NameCardCompany> companies;
    public NameCardLocation(NameCard__c card) {
      this.companies = new List<NameCardCompany>();
      this.lat = card.GeoLocation__Latitude__s;
      this.lng = card.GeoLocation__Longitude__s;
      this.address = card.address__c;
      this.count = 0;
    }
    public void addCard(NameCard__c card) {
      System.debug(card.Name + ' : ' + card.company_name__c + ' : ' + this.count.format());
      NameCardCompany company = null;
      for (NameCardCompany c : this.companies) {
        if (c.companyName == card.company_name__c) {
          company = c;
          break;
        }
      }
      if (company ==null) {
        this.count++;
        System.debug('New Company' + ' : ' + this.count.format());
        if (companies.size() >= SB_NameCard_Util.smartViscaConfig.SMAXMapInfoWindowCompanies__c) return; // 設定の枚数を超えてたら追加しない。 infoWindowで表示しない。
        company = new NameCardCompany();
        companies.add(company);
      }
      company.addCard(card);
    }
  }

  //  要求された地点から設定された距離以内の名刺 を 緯度経度ごとの 会社ごとに仕訳て取得
  @RemoteAction
  public static List<NameCardLocation> getFindNearbyEx(FindNearbyRequest req) {
    Map< String, NameCardLocation> point2Companies = new Map<String, NameCardLocation> ();
    List<NameCard__c> cards = getFindNearby(req);

    if (cards.isEmpty() == true) return point2Companies.values();
    for (NameCard__c card : cards) {
      System.debug(card.company_name__c + ' : ' + card.Name + ' : ' + card.address__c);
      String point = card.GeoLocation__Latitude__s.format() + ':' + card.GeoLocation__Longitude__s.format();
      NameCardLocation location = null;
      if (point2Companies.containsKey(point) == true) {
        location = point2Companies.get(point);
      }
      else {
        location = new NameCardLocation(card);
      }
      location.addCard(card);
      point2Companies.put(point, location);
    }
    return point2Companies.values();
  }

  @RemoteAction
  public static List<NameCard__c> getNameCardsWithoutGeoLocation(String userId) {
    String queryString =
      'SELECT ' + SB_NC_NameCardDTO.NC_QUERY_FIELDS + ', GeoLocation__Longitude__s, GeoLocation__Latitude__s' + ' FROM NameCard__c' +
      ' WHERE address__c != null and (GeoLocation__Longitude__s = null or GeoLocation__Latitude__s=null)' +
      ' and OwnerId = \'' + (userId != null ? userId : UserInfo.getUserId()) + '\'' +
      ' ORDER BY card_exchange_date__c DESC NULLS LAST' +
      ' limit ' + SB_NameCard_Util.smartViscaConfig.SGeolocationQueryLimit__c.format();
    if (Test.isRunningTest()) {
      // パッケージ作成環境で System.QueryException: field 'GeoLocation__c' can not be filtered in query call となるので、
      queryString =
        'SELECT Id, Name, GeoLocation__Longitude__s, GeoLocation__Latitude__s' +
        ', zip_code__c, address_pref__c, address__c, address_bld__c' +
        ', company_name__c, company_name_kana__c' +
        ' FROM NameCard__c' +
        ' WHERE address__c != null and (GeoLocation__Longitude__s = null or GeoLocation__Latitude__s=null)' +
        ' ORDER BY card_exchange_date__c DESC NULLS LAST';
    }
    // Run and return the query results
    System.debug('++getNameCardsWithoutGeoLocation SOQL : '+ queryString);
    return(database.Query(queryString));
  }

  /**
  * getUsersHavingCard
  *   指定した名刺と同じ人（名前、メールアドレス）の名刺を持ってるユーザのリストを返す。
  *   cardId : 対象の名刺
  *   excludeMe : 自分以外
  **/
  @RemoteAction
  public static List<User> getUsersHavingCard(String cardId, Boolean excludeMe) {
    List<NameCard__c> targetCard = [select Id, Name, email__c from NameCard__c where Id = :cardId];
    if (targetCard.isEmpty() == true) return null;
    List<NameCard__c> otherCards = [select Id, OwnerId, Parent__c from NameCard__c
    where Name=:targetCard[0].Name and email__c= :targetCard[0].email__c ];
    Set<Id> ownerIds = new Set<Id>();
    for (NameCard__c card : otherCards) {
      if (excludeMe == true && card.OwnerId == UserInfo.getUserId())      // 自分以外
      continue;
      ownerIds.add(card.OwnerId);
    }
    String query = 'SELECT Id, Name, CompanyName, Country, Department, Email, Phone, Fax, EmployeeNumber' +
          (enableFeedItem == true ? ', FullPhotoUrl' : '') +         // Chatter が無効だと 項目 がないので、
          ' FROM User WHERE Id in :ownerids and IsActive=true Order By CompanyName NULLS LAST, Department NULLS LAST, Name';
    List<User> users = Database.query(query);
    return users;
  }

  // 同じ人の名刺を持ってるユーザの情報を格納するクラス
  public class SameCardUsers {
    public String latestOwnerId { get; private set;}    // 最新の名刺の所有者のユーザID
    public List<User> users { get; private set;}        // 共通の人の名刺を持っているユーザたち
    public void setLatestOwnerId(String id) {
      this.latestOwnerId = id;
    }
  }

  // 同じ人の名刺を持ってるユーザの取得
  @RemoteAction
  public static SameCardUsers getUsersHavingCardEx(String cardId, Boolean excludeMe) {
    SameCardUsers result = new SameCardUsers();
    List<NameCard__c> targetCard = [select Id, Name, email__c from NameCard__c where Id = :cardId];
    if (targetCard.isEmpty() == true) return null;
    List<NameCard__c> otherCards = [select Id, OwnerId, Parent__c from NameCard__c
    where Name=:targetCard[0].Name AND email__c=:targetCard[0].email__c ];
    Set<Id> ownerIds = new Set<Id>();
    for (NameCard__c card : otherCards) {
      if (excludeMe == true && card.OwnerId == UserInfo.getUserId())      // 自分以外
        continue;
      ownerIds.add(card.OwnerId);
      if (card.Parent__c == null)
        result.setLatestOwnerId(card.OwnerId);
    }
    String query = 'SELECT Id, Name, CompanyName, Country, Department, Email, Phone, Fax, EmployeeNumber' +
          (enableFeedItem == true ? ', FullPhotoUrl' : '') +         // Chatter が無効だと 項目 がないので、
          ' FROM User WHERE Id in :ownerids and IsActive=true Order By CompanyName NULLS LAST, Department NULLS LAST, Name';
    result.users = Database.query(query);
    return result;
  }

  private static Map<id, NameCard__c> putNameCards(List<NameCard__c> cards) {
    Map<id, NameCard__c> results = new Map<id, NameCard__c>();
    for (NameCard__c c : cards) {
      results.put(c.Id, c);
    }
    return results;
  }

  // 古い名刺、転職前の名刺 のリストを取得
  @RemoteAction
  public static List<SB_NC_NameCardDTO> getReferenced(String cardId) {
    List<SB_NC_NameCardDTO> results = new List<SB_NC_NameCardDTO>();
    Map<id, NameCard__c> mapId2Card = new Map<id, NameCard__c>();   // 重複がないように、IDとオブジェクトのマップを作る。
    // 古い名刺
    String queryString =
      'SELECT Id, Parent__c, (SELECT '+ SB_NC_NameCardDTO.NC_QUERY_FIELDS + ' FROM nc_parent__r) FROM NameCard__c WHERE Id = :cardId';
      List<NameCard__c> oldCards = Database.query(queryString);
    if (oldCards[0].nc_parent__r != null && oldCards[0].nc_parent__r.size() > 0)
      mapId2Card.putAll(putNameCards(oldCards[0].nc_parent__r));
    // 最新の名刺
    if (String.isBlank(oldCards[0].Parent__c ) == false) {
      queryString = 'SELECT Id, ' + SB_NC_NameCardDTO.NC_QUERY_FIELDS +  ' FROM NameCard__c WHERE Id = :oldCards[0].Parent__c';
      List<NameCard__c> latestCards = Database.query(queryString);
      if (latestCards.isEmpty() == false)
        mapId2Card.putAll(putNameCards(latestCards));
    }
    // 転職前の名刺
    queryString =
        'SELECT Id, (SELECT '+ SB_NC_NameCardDTO.NC_QUERY_FIELDS + ' FROM meishiwSLt__r) FROM NameCard__c WHERE Id = :cardId';
    List<NameCard__c> prvCards = Database.query(queryString);
    if (prvCards[0].meishiwSLt__r != null && prvCards[0].meishiwSLt__r.size() > 0)
      mapId2Card.putAll(putNameCards(prvCards[0].meishiwSLt__r));
    for (NameCard__c card : mapId2Card.values()) {
      SB_NC_NameCardDTO dto = new SB_NC_NameCardDTO();
      dto.bind(card);
      results.add(dto);
    }
    results.sort();
    return results;
  }

  // DTOのリストとIDのセットに 格納して返す。
  private static void addNameCards(List<SB_NC_NameCardDTO> dtos, Set<id> ids, Set<Id> tenshokugoIds,
    NameCard__c card, Integer status, Id excludeId) {
    if (card.Id == excludeId) return;
    if (ids.contains(card.Id) == true) return;
    ids.add(card.Id);
    if (card.tenshokugonomeishi__c != null)
      tenshokugoIds.add(card.tenshokugonomeishi__c);
    SB_NC_NameCardDTO dto = new SB_NC_NameCardDTO();
    dto.bind(card);
    dto.setStatus(status);
    dtos.add(dto);
  }

  // 古い名刺、転職前の名刺 のリストを取得
  // @RemoteAction
  // public static List<SB_NC_NameCardDTO> getSameCards_Old(String cardId) {
  //   List<SB_NC_NameCardDTO> results = new List<SB_NC_NameCardDTO>();
  //   Set<Id> ids = new Set<Id>();
  //   Set<Id> tenshokugoIds = new Set<Id>();
  //   Map<id, NameCard__c> mapId2Card = new Map<id, NameCard__c>();   // 重複がないように、IDとオブジェクトのマップを作る。
  //   // 最新の名刺のIDを取得
  //   List<NameCard__c> targetCard =  [SELECT Id, Name, Parent__c, email__c  FROM NameCard__c WHERE Id = :cardId];
  //   if (targetCard.isEmpty() ) return null; // 念のため
  //   ID parentId = targetCard[0].Parent__c != null ? targetCard[0].Parent__c : cardId;
  //   // 古い名刺
  //   String queryString =
  //     'SELECT ' + SB_NC_NameCardDTO.NC_QUERY_FIELDS+ ', (SELECT '+ SB_NC_NameCardDTO.NC_QUERY_FIELDS + ' FROM nc_parent__r) FROM NameCard__c WHERE Id = :parentId';
  //   List<NameCard__c> cards = Database.query(queryString);
  //   if (cards.isEmpty() ) return null;  // 念のため  最新がなくなってるとき
  //   // 最新の名刺
  //   addNameCards(results, ids, tenshokugoIds, cards[0], 0, null);
  //   // 古い名刺
  //   if (cards[0].nc_parent__r != null && cards[0].nc_parent__r.size() > 0)
  //   for(NameCard__c c : cards[0].nc_parent__r) {
  //     addNameCards(results, ids, tenshokugoIds, c, 1, null);
  //   }
  //   // 転職前の名刺
  //   queryString =
  //     'SELECT Id, (SELECT '+ SB_NC_NameCardDTO.NC_QUERY_FIELDS + ' FROM meishiwSLt__r) FROM NameCard__c WHERE Id IN :ids';
  //   List<NameCard__c> prvCards = Database.query(queryString);
  //   if (prvCards[0].meishiwSLt__r != null && prvCards[0].meishiwSLt__r.size() > 0)
  //   for(NameCard__c c : prvCards[0].meishiwSLt__r) {
  //     addNameCards(results, ids, tenshokugoIds, c, 2, null);
  //   }
  //   // 転職後の名刺
  //   if (tenshokugoIds.isEmpty()) {
  //     queryString = 'SELECT '+ SB_NC_NameCardDTO.NC_QUERY_FIELDS + ' FROM NameCard__c WHERE Id IN :tenshokugoIds';
  //     List<NameCard__c> goCards = Database.query(queryString);
  //     for(NameCard__c c : goCards) {
  //       addNameCards(results, ids, tenshokugoIds, c, 3, null);
  //     }
  //   }
  //   // 同じ氏名、同じメールアドレス の名刺
  //   queryString = 'SELECT ' + SB_NC_NameCardDTO.NC_QUERY_FIELDS + ' FROM NameCard__c WHERE Name=\''
  //       + cards[0].name + '\' AND email__c=\'' + cards[0].email__c + '\'';
  //   List<NameCard__c> otherCards = Database.query(queryString);
  //   for(NameCard__c c : otherCards) {
  //     addNameCards(results, ids, tenshokugoIds, c, 4, null);
  //   }
  //   // 名刺の所有者たち USER
  //   String fields = SB_NC_NameCardDTO.USER_QUERY_FIELDS + (enableFeedItem == true ? ', FullPhotoUrl' : ''); // Chatter が無効だと 項目 がないので、
  //   queryString =
  //     // 'SELECT Id, Name, CompanyName, Country, Department, Email, Phone, Fax, EmployeeNumber'
  //     // + (enableFeedItem == true ? ', FullPhotoUrl' : '')         // Chatter が無効だと 項目 がないので、
  //     // + ' FROM User WHERE Id IN (SELECT OwnerId FROM NameCard__c WHERE Id IN :ids)';
  //     String.format('SELECT {0} FROM User WHERE Id IN (SELECT OwnerId FROM NameCard__c WHERE Id IN :ids)',
  //                   new String[] { fields });
  //   List<User> lu = Database.query(queryString);
  //   Map<Id, User> users = new Map<Id, User>(lu);
  //   for (SB_NC_NameCardDTO dto : results) {
  //     if(users.containsKey(dto.ownerId) == false) continue;
  //     dto.setOwner(users.get(dto.ownerId));
  //   }
  //   // 交換日でソート
  //   results.sort();
  //   return results;
  // }
  // 古い名刺、転職前の名刺 のリストを取得
  @RemoteAction
  public static List<SB_NC_NameCardDTO> getSameCards(String cardId) {
    List<SB_NC_NameCardDTO> results = new List<SB_NC_NameCardDTO>();
    Set<Id> ids = new Set<Id>();
    Set<Id> tenshokugoIds = new Set<Id>();
    Map<id, NameCard__c> mapId2Card = new Map<id, NameCard__c>();   // 重複がないように、IDとオブジェクトのマップを作る。
    // 最新の名刺のIDを取得
    List<NameCard__c> targetCard =  [SELECT Id, Name, Parent__c, email__c  FROM NameCard__c WHERE Id = :cardId];
    if (targetCard.isEmpty() ) return results; // 念のため
    ID parentId = targetCard[0].Parent__c != null ? targetCard[0].Parent__c : cardId;
    // 古い名刺
    String queryString =
      'SELECT ' + SB_NC_NameCardDTO.NC_QUERY_FIELDS + ', (SELECT '+ SB_NC_NameCardDTO.NC_QUERY_FIELDS + ' FROM nc_parent__r) FROM NameCard__c WHERE Id = :parentId';
    List<NameCard__c> cards = Database.query(queryString);
    if (cards.isEmpty()) {
       // 念のため  最新がなくなってるか、見えないとき
      queryString =
        'SELECT ' + SB_NC_NameCardDTO.NC_QUERY_FIELDS + ' FROM NameCard__c WHERE Id = :cardId';
      cards = Database.query(queryString);
      // 古い名刺として 参照中の名刺をセット
      addNameCards(results, ids, tenshokugoIds, cards[0], 1, null);
    }
    else {
      // 最新の名刺
      addNameCards(results, ids, tenshokugoIds, cards[0], 0, null);
      // 古い名刺
      if (cards[0].nc_parent__r != null && cards[0].nc_parent__r.size() > 0)
      for(NameCard__c c : cards[0].nc_parent__r) {
        addNameCards(results, ids, tenshokugoIds, c, 1, null);
      }
    }
    // 転職前の名刺
    queryString =
      'SELECT Id, (SELECT '+ SB_NC_NameCardDTO.NC_QUERY_FIELDS + ' FROM meishiwSLt__r) FROM NameCard__c WHERE Id IN :ids';
    List<NameCard__c> prvCards = Database.query(queryString);
    if (prvCards[0].meishiwSLt__r != null && prvCards[0].meishiwSLt__r.size() > 0)
    for(NameCard__c c : prvCards[0].meishiwSLt__r) {
      addNameCards(results, ids, tenshokugoIds, c, 2, null);
    }
    // 転職後の名刺
    if (tenshokugoIds.isEmpty()) {
      queryString = 'SELECT '+ SB_NC_NameCardDTO.NC_QUERY_FIELDS + ' FROM NameCard__c WHERE Id IN :tenshokugoIds';
      List<NameCard__c> goCards = Database.query(queryString);
      for(NameCard__c c : goCards) {
        addNameCards(results, ids, tenshokugoIds, c, 3, null);
      }
    }
    // 同じ氏名、同じメールアドレス の名刺
    queryString = 'SELECT ' + SB_NC_NameCardDTO.NC_QUERY_FIELDS + ' FROM NameCard__c WHERE Name=\''
        + cards[0].name + '\' AND email__c=\'' + cards[0].email__c + '\'';
    List<NameCard__c> otherCards = Database.query(queryString);
    for(NameCard__c c : otherCards) {
      addNameCards(results, ids, tenshokugoIds, c, 4, null);
    }
    // 名刺の所有者たち USER
    String fields = SB_NC_NameCardDTO.USER_QUERY_FIELDS + (enableFeedItem == true ? ', FullPhotoUrl' : ''); // Chatter が無効だと 項目 がないので、
    queryString =
      // 'SELECT Id, Name, CompanyName, Country, Department, Email, Phone, Fax, EmployeeNumber'
      // + (enableFeedItem == true ? ', FullPhotoUrl' : '')         // Chatter が無効だと 項目 がないので、
      // + ' FROM User WHERE Id IN (SELECT OwnerId FROM NameCard__c WHERE Id IN :ids)';
      String.format('SELECT {0} FROM User WHERE Id IN (SELECT OwnerId FROM NameCard__c WHERE Id IN :ids)',
                    new String[] { fields });
    List<User> lu = Database.query(queryString);
    Map<Id, User> users = new Map<Id, User>(lu);
    for (SB_NC_NameCardDTO dto : results) {
      if(users.containsKey(dto.ownerId) == false) continue;
      dto.setOwner(users.get(dto.ownerId));
    }
    // 交換日でソート
    results.sort();
    return results;
  }
  /**
  * ユーザ情報の取得
  *       userId : 情報を取得するユーザのレコードID
  **/
  @RemoteAction
  public static User getUserInfo(String userId) {
    List<User> users = [select Id, Name, Username, CompanyName, Country, Department, Title
    from User where Id = :userId];
    //        return users.isEmpty() == false ? users[0] : null;
    return users[0];
  }

//// +++++++  組織ツリー関連 ここから
  /**
  * 組織ツリーの各ノードを示すクラス
  *
  *  @deprecated getCompnayTree2 を使う 未使用だけど Globalなのでパッケージからけせないので、残しておきます。v1.22 2018.01.xx
  **/
//  private static Integer counter =0;      // ノードにIDを割り振るので、そのためのカウント
//  // 組織階層のノード あるいは、終端の名刺
// 未使用だけど Globalなのでパッケージからけせないので、残しておきます。v1.22 2018.01.xx
  public class Node {
    public String nodeName { get; private set; }
    public String ownerName { get; private set; }
    public String nodeId { get; private set; }
    public Boolean selected { get; private set; }   // 階層を作る元になった名刺？
    public Boolean mine { get; private set; }       // 自分所有の名刺？  名刺ノードのとき有効
    public List<Node> children { get; private set; }
//    private Map<String, Node> mapChildren;
//    public Node() {
//      children = new List<Node>();
//      mapChildren = new Map<String, Node>();
//      this.selected = false;
//      this.mine = false;
//    }
//    // 部署ノードを作る
//    public Node(String name) {
//      children = new List<Node>();
//      mapChildren = new Map<String, Node>();
//      this.nodeName = name;
//      this.nodeId = 'N' + String.valueOf(counter);
//      counter++;
//      this.selected = false;
//      this.mine = false;
//    }
//    // 名刺ノードを作る
//    public Node(NameCard__c card, Boolean selected) {
//      this.nodeName = card.Name;              // 名刺の氏名
//      this.ownerName = card.Owner.Name;       // 名刺の所有者
//      this.nodeId = card.Id;
//      this.selected = selected;
//      this.mine = (card.OwnerId == UserInfo.getUserId());         // 自分所有の名刺？
//    }
//    public void addChildren(List<String> divisions, NameCard__c card, String cardId) {
//      if (divisions == null || divisions.isEmpty() == true) {
//        // 終端のノード = 名刺
//        Node c = new Node(card, card.Id == cardId);
//        children.add(c);
//      }
//      else {
//        // 途中ののーど = 部署
//        // このレベルの部署名をリストから削除
//        List<String> subDiv = new List<String>();
//        for (Integer n =1; n<divisions.size(); n++) {
//          subDiv.add(divisions[n]);
//        }
//        // このレベルの部署名のノードに子ノードを追加
//        Node sub = null;
//        if(mapChildren.containsKey(divisions[0]) == true) {
//          sub = mapChildren.get(divisions[0]);
//        }
//        else {
//          sub = new Node(divisions[0]);
//          children.add(sub);      // 子ノードをリストに追加
//        }
//        sub.addChildren(subDiv, card, cardId);  //
//        mapChildren.put(divisions[0], sub);
//      }
//    }
  }

//  // 部署名を階層に分割して返す。ブランクで区切る
///*  public static List<String> getDivisionNodes(String division) {
//    List<String> results = new List<String>();
//    if (String.isEmpty(division) == true) return null;
//    return division.split('[,\\s]');
//    }*/

//  // 部署名を階層に分割して返す。
//  // private final static String divisionRegex ='\\b.+社長*|事業部長*|本部長*|部門長*|部長*|室長*|課長*|係長*|グループ長*|\\s|　\\b';
//  private final static String divisionRegex =System.Label.SB_NC_DivisionRegex;
//  public static List<String> getDivisionNodes(String division) {
//    List<String> results = new List<String>();
//    Pattern p = Pattern.compile(divisionRegex);
//    Matcher m = p.matcher(division);
//    Integer s =0;
//    while(m.find()){ // 検索(find)し、マッチする部分文字列がある限り繰り返す
//      for (Integer j = 0; j <= m.groupCount(); j++) {
//        //                  System.debug(m.group(j)+ ', ('+m.start(j)+'-'+m.end(j)+')');  指定した文字列 とその開始位置、終了位置
//        String div = division.substring(s, m.end(j));
//        if (String.isBlank(div) == false)
//        results.add(div);
//        s = m.end(j);
//      }
//    }
//    if (division.length() > s) {
//      results.add(division.substring(s).trim());
//    }
//    return results;
//  }

//  /**
//  *
//  * 組織ツリーを作るクラス
//  *
//  **/
//  private Class OrgTreeBuilder {
//    private Node rootNode = null;

//    public OrgTreeBuilder() {
//    }

//    public Node getRootNode() { return rootNode; }

//    public void run(String cardId, Boolean mineOnly) {
//      List<NameCard__c> targetCard = [select Id, company_name__c from NameCard__c where Id = :cardId];
//      if (targetCard.isEmpty() == true || targetCard[0].company_name__c==null) return;
//      // ルートノードのインスタンス化
//      rootNode = new Node(targetCard[0].company_name__c);
//      List<NameCard__c> cards = getNameCardsInCompany(targetCard[0].company_name__c, mineOnly);
//      for (NameCard__c card :cards) {
//        String[] divisions = null;
//        if (String.isBlank(card.division__c) == false) {
//          // 部署名の分割した要素の取得
//          divisions = SB_NameCard_S2Controller.getDivisionNodes(card.division__c);
//        }
//        // ルートノードに名刺を追加
//        rootNode.addChildren(divisions, card, cardId);
//      }
//    }

//    //指定の会社名の
//    private List<NameCard__c> getNameCardsInCompany(String company, Boolean mineOnly) {
//      String condition =
//        // 自分の名刺だけ  ||  最新の名刺だけ
//        (mineOnly == true ? 'OwnerId = \'' + UserInfo.getUserId() + '\' and ' : '') +
//        + 'Parent__c=null and company_name__c = \'' + company + '\'';   // 最新の名刺 and 指定の会社のもの

//      String queryString =
//        'SELECT ' + SB_NC_NameCardDTO.NC_QUERY_FIELDS + ' from NameCard__c' +
///*              'SELECT Id, Name, company_name__c, division__c, title_name__c, card_exchange_date__c' +
//        ', person_name_last_kana__c, person_name_first_kana__c' +
//        ', email__c, tel1__c, tel2__c, mobile__c, image_id__c, OwnerId, Owner.Name' +
//        ' from NameCard__c' +*/
//        (String.isBlank(condition) == false ? ' where ' + condition : '') +
//          ' order by' +
//          ' card_exchange_date__c DESC NULLS LAST' +        // 名刺交換日
//          // ' company_name__c, division__c ASC NULLS LAST' +        // 会社名、部署
//          ' limit ' +
//        SB_NameCard_Util.smartViscaConfig.SMAXOrgTreeNameCards__c.format();
///*                    (mineOnly == true ?
//            SB_NameCard_Util.smartViscaConfig.SListQueryMineLimit__c.format() :
//            SB_NameCard_Util.smartViscaConfig.SListQueryVisibleLimit__c.format() );*/
//      System.debug('++getNameCardsInCompany : '+ queryString);
//      // Run and return the query results
//      System.debug('++getNameCardsInCompany SOQL : '+ queryString);
//      return(database.Query(queryString));
//    }

//  }

  // 日付整形用 2016.09.xx
  // SB_NC_NGDateFormat => yyyy/MM/dd (EEEE)
  private static String formatDate(Date d) {
    Datetime dt = Datetime.newInstance(d.year(), d.month(), d.day()); // 2018.03.xx newInstanceGmt -> newInstance
    String f = Label.SB_NC_NGDateFormat.replace('(EEEE)', '').trim();
    return dt.format(f);
  }

  // 日時整形用 2016.09.xx
  private static String formatDatetime(Datetime dt) {
    String f = '';
    if (UserInfo.getLanguage() == 'ja' && String.isNotBlank(SB_NameCard_Util.smartViscaConfig.SDatetimeFormat__c)) {
      f = SB_NameCard_Util.smartViscaConfig.SDatetimeFormat__c;
    }
    else {
      f = Label.SB_NC_NGDateFormat + ' HH:mm';
    }
    return dt.format(f, UserInfo.getTimeZone().getId());
  }

  /**
  *  同一組織の名刺の階層表現の取得
  *   mineOnly
  *  2017.11.xx v1.22 SV_DEV-689 組織情報に役職を加味する
  *     従来実装の関連する 内部クラスを破棄して SB_NameCard_OrgTreeBuilder.cls で実現
  *  @deprecated getCompnayTree2 を使う 未使用だけど Globalなのでパッケージからけせないので、残しておきます。v1.22 2018.01.xx
  **/
  @RemoteAction
  public static List<Node> getCompnayTree(String cardId, Boolean mineOnly) {
    //OrgTreeBuilder builder = new OrgTreeBuilder();
    //builder.run(cardId, mineOnly);
    //List<Node> results = new List<Node>();
    //results.add(builder.getRootNode());
    //return results;
    return null;
  }

  @RemoteAction
  public static List<SB_NameCard_OrgTreeBuilder.Item> getCompnayTree2(String cardId, Boolean mineOnly) {
    // v2.4 2019.09.xx SV_DEV-1418 モバイル 新UI 『組織』情報 でカスタム設定「S組織情報に役職を表示する」が有効状態の時に役職が重複して表示される
    return SB_NameCard_OrgTreeBuilder.getOrgTreeItems(cardId, false, SB_NameCard_Util.smartViscaConfig.SMAXOrgTreeNameCards__c.intValue());
  }
  // +++++++  組織ツリー関連 ここまで

  // +++++++  活動関連 ここから
  public class Activity implements Comparable {
    public String subject { get; private set;}
    public String targetName { get; private set;}
    public String targetCompany { get; private set;}
    public String targetDateTime { get; private set;}   // 表示用 日時
    public Task task { get; private set;}   // ToDo
    public Event event { get; private set;} // 行動
    public Datetime tempDateTime { get; private set;}
    // public Integer targetType; // 1: 取引先責任者 2: 取引先 9: 名刺

    public Activity(Event e, NameCard__c card) {
      this.event = e;
      this.subject = e.subject;
      this.targetName = e.who.Name == null && card !=null ? card.Name : e.who.Name;
      this.targetCompany = e.Account.Name == null  && card !=null ? card.company_name__c : e.Account.Name;
      if (e.IsAllDayEvent == true) {
        this.targetDateTime = formatDate(e.ActivityDate); // 2016.09.xx e.ActivityDate.format();
        if (e.EndDateTime !=null) {
          Date endDate = Date.newInstance(e.EndDateTime.year(), e.EndDateTime.month(), e.EndDateTime.day());
          if (e.ActivityDate != endDate) {
            this.targetDateTime += ' - ' + formatDate(endDate); // 2016.09.xx endDate.format();
          }
        }
      }
      else {
        this.targetDateTime = formatDatetime(e.StartDateTime); // 2016.09.xx e.StartDateTime.format(SB_NameCard_Util.smartViscaConfig.SDatetimeFormat__c, UserInfo.getTimeZone().getId());
        this.targetDateTime += e.EndDateTime != null ? ' - ' + formatDatetime(e.EndDateTime) : ''; // 2016.09.xx e.EndDateTime.format(SB_NameCard_Util.smartViscaConfig.SDatetimeFormat__c,UserInfo.getTimeZone().getId()) : '';
      }
      this.tempDateTime = e.StartDateTime;
    }
    public Activity(Task t, NameCard__c card) {
      this.task = t;
      this.subject = t.subject;
      this.targetName = t.who.Name == null  && card !=null ? card.Name : t.who.Name;
      this.targetCompany = t.Account.Name == null  && card !=null ? card.company_name__c : t.Account.Name;
      this.targetDateTime = t.ActivityDate != null ? formatDate(t.ActivityDate) : null; // t.ActivityDate.format() : null;      // 2015.08.1x null も対象
      if (t.ActivityDate != null) {
      this.tempDateTime = Datetime.newInstance(t.ActivityDate.year(), t.ActivityDate.month(), t.ActivityDate.day());
      }
    }

    public Integer compareTo(Object compareTo) {
      Activity act = (Activity)compareTo;
      if (tempDateTime ==  act.tempDateTime) return 0;
      else if (tempDateTime > act.tempDateTime) return 1;
      else return -1;
    }
  }

  @RemoteAction
  public static List<Activity> getMyActivities(Id cardId) {
    List<NameCard__c> cards = [select Id, account__c, contact__c, Name, company_name__c
    from NameCard__c where Id = :cardId];
    if (cards.isEmpty() == true) return null;
    return createActivityList(cards[0]);
  }


  // RecordTypeId はないと こける。インストールもできなさげ
  private static final String STR_QueryEvent = 'SELECT Id, subject, IsAllDayEvent, StartDateTime, ActivityDate, EndDateTime' +
            ', Location, Description, OwnerId, AccountId, Account.Name, WhatId, What.Name, whoId, who.Name' + // , RecordTypeId' +
            ' FROM Event';
  private static final String STR_QueryTask = 'SELECT Id, subject, ActivityDate, Description, status, OwnerId' +
            ', AccountId, Account.Name, WhatId, What.Name, whoId, who.Name' + // , RecordTypeId' +
            ' FROM Task';

  // 名刺自身、あるいは 名刺が参照する 取引先、取引先責任者 に関連付けられた Todo、行動を取得
  private static List<Activity> createActivityList(NameCard__c card) {
    List<Activity> results = new List<Activity>();
    // WHERE句作成
    set<Id> whatIds = new set<Id>();
    whatIds.add(card.Id);
    if (card.account__c != null) {
      whatIds.add(card.account__c);
    }
    String condition = ' WHERE (WhatId IN :whatIds';
    Id whoid;
    if (card.contact__c != null) {
      whoid = card.contact__c;
      condition += ' OR whoId = :whoid';
    }
    Id userId = UserInfo.getUserId();
    condition +=  ') AND OwnerId=:userId';
    // 行動
    String queryEvent = STR_QueryEvent;
    queryEvent += condition + ' AND EndDateTime >= TODAY'; // 2018.01.xx v2.1 SV_DEV-1442 モバイル 新UI 「本日以降の活動」での「予定」の表示
    List<Event> events = database.query(queryEvent);
    for(Event e : events) {
      results.add(new Activity(e,card));
    }
    // ToDo
    String queryTask = STR_QueryTask;
    queryTask += condition + ' AND (ActivityDate >= TODAY OR ActivityDate=null)';        // 2015.08.1x null も対象
    List<Task> tasks = database.query(queryTask);
    for(Task t :tasks) {
      results.add(new Activity(t,card));
    }
    results.sort(); // 日時でソート
    return results;
  }

  //private static final Map<String, String> MAP_OBJ2SELECT = new Map<String, String> {
  //  'Event' => STR_QueryEvent
  //  , 'Task' => STR_QueryTask
  //};

  private static final Map<SObjectType, String> MAP_OBJ2QUERY = new Map<SObjectType, String> {
    Event.sObjectType => STR_QueryEvent
    , Task.sObjectType => STR_QueryTask
  };

  @RemoteAction
  public static ActivityDTO getActivity(Id activityId) {
    ActivityDTO result = new ActivityDTO();
    SObjectType otype = activityId.getSObjectType();
    //String objectName = SB_NameCard_Util.getObjectName(activityId);
    String query = MAP_OBJ2QUERY.get(otype);
    System.assert(query != null);
    query += ' where ID=\'' + activityId +'\'';
    List<sObject> objs = Database.query(query);
    if (objs.isEmpty() == true)
      throw new SB_NameCard_S2ControllerException(System.Label.SB_MSG_IllegalRequest);
    result.bind(objs[0]);
    return result;
  }

  private class SObjectFactory {
    public void run(List<SObjectDTO> reqs) {
      List<sObject> objs = new List<sObject>();
      for (SObjectDTO req : reqs) {
        sObject obj = req.create();
        objs.add(obj);
      }
      if (objs[0].Id == null) {
        insert objs;
      }
      else {
        update objs;
      }
    }
  }

  // 名刺に関連したレコードを作るクラスの基底
  private abstract class SObjectDTO {
    // 既存の場合に
    protected NameCard__c getNameCardReference(Id cardId) {
      List<NameCard__c> cards = [select Id, account__c, contact__c, Name, company_name__c, OwnerId
          from NameCard__c where Id = :cardId];
      if (cards.isEmpty() == true)
        throw new SB_NameCard_S2ControllerException(System.Label.SB_MSG_IllegalRequest);
      return cards[0];
    }
    public abstract sObject create();       // プロパティ値をもとに 該当の おブジェクトのレコードを作る
    public abstract void bind(sObject obj); // 既存のレコードをもとにプロパティ値をセット
  }

  public class AnySObjectDTO extends SObjectDTO {
    public String id { get; private set; }
    public AnySObjectDTO(String objectId) {
      this.id = objectId;
    }
    public override sObject create() {
      AnySObjectBuilder builder = new AnySObjectBuilder();
      return builder.create(this);
    }
    public override void bind(sObject obj) {
      this.id = obj.Id;
    }
  }

  // // 名刺レコードのDTO
  // public with sharing class NameCardDTO extends SObjectDTO  implements Comparable {
  //   public String id { get; private set; }              // レコードID
  //   public String name { get; private set; }            // 氏名
  //   public String company_name { get; private set; }    // 会社名
  //   public String company_name_kana { get; private set; }
  //   public String division { get; private set; }
  //   public void setDivision(String div) { this.division = div;} // テスト用
  //   public String title_name { get; private set; }
  //   public String person_name_last { get; private set; }
  //   public String person_name_first { get; private set; }
  //   public String name_kana { get; private set; }
  //   public String ownerId { get; private set; }
  //   public String ownerName { get; private set; }
  //   public Date card_exchange_date { get; private set; }
  //   public String image_id { get; private set; }
  //   public Integer width { get; private set; }
  //   public Integer height { get; private set; }
  //   public String bk_image_id { get; private set; }
  //   public Integer bk_width { get; private set; }
  //   public Integer bk_height { get; private set; }
  //   public String address_pref { get; private set; }
  //   public String address { get; private set; }
  //   public String address_bld { get; private set; }
  //   public String tel1 { get; private set; }
  //   public String fax1 { get; private set; }
  //   public String mobile { get; private set; }
  //   public String email { get; private set; }
  //   public String list_name { get; private set; }
  //   public String parentId { get; private set; }      // 最新の名刺
  //   public String accountId { get; private set; }
  //   public String contactId { get; private set; }
  //   public String zip_code { get; private set; }
  //   public String freehandmemo { get; private set; }
  //   public String memo { get; private set; }
  //   public String web_url1 { get; private set; }
  //   public String address_eng { get; private set; }
  //   public Integer status { get; private set; }         // -1 : ? 0:最新 1: 古い 2: 転職前 3: 転職後 4:同姓同名 同メアド
  //   public String photo { get; private set; }       // 名刺の人の顔写真 デモ用 2014/09/13
  //   public void setStatus(integer s) {
  //     this.status = s;
  //   }
  //   public User owner { get; private set; }             // 所有者のユーザレコード 詳細画面で表示する用
  //   public void setOwner(User u) {
  //     this.owner = u;
  //   }
  //   public NameCardDTO() {
  //     this.status = -1;
  //   }
  //   // create といいつつ Upsert
  //   public override sObject create() {
  //     NameCardBuilder builder = new NameCardBuilder();
  //     sObject result = builder.create(this);
  //     Database.DMLOptions dml = new Database.DMLOptions();
  //     dml.optAllOrNone = true;
  //     dml.allowFieldTruncation = true;
  //     if (result.Id !=null) {
  //       Database.update(result, dml);
  //     }
  //     else {
  //       Database.insert(result, dml);
  //     }
  //     return result;
  //   }

  //   public override void bind(sObject obj) {
  //     System.assert(obj.getSObjectType() == NameCard__c.sObjectType);
  //     NameCard__c card = (NameCard__c)obj;
  //     this.id = card.Id;
  //     this.name = card.Name;
  //     this.company_name = card.company_name__c;
  //     this.company_name_kana = card.company_name_kana__c;
  //     this.division = card.division__c;
  //     this.title_name = card.title_name__c;
  //     this.person_name_last = card.person_name_last__c;
  //     this.person_name_first = card.person_name_first__c;
  //     this.name_kana = card.name_kana__c;
  //     this.ownerId = card.OwnerId;
  //     this.ownerName = card.Owner.Name;
  //     this.card_exchange_date = card.card_exchange_date__c;       // 名刺交換日
  //     this.image_id = card.image_id__c;
  //     this.width = card.width__c != null ? card.width__c.intValue() : 0;
  //     this.height = card.height__c != null ? card.height__c.intValue() : 0;
  //     this.bk_image_id = card.bk_image_id__c;
  //     this.bk_width = card.bk_width__c != null ? card.bk_width__c.intValue() : 0;
  //     this.bk_height = card.bk_height__c != null ? card.bk_height__c.intValue() : 0;
  //     this.address_pref = card.address_pref__c;
  //     this.address = card.address__c;
  //     this.address_bld = card.address_bld__c;
  //     this.tel1 = card.tel1__c;
  //     this.fax1 = card.fax1__c;
  //     this.mobile = card.mobile__c;
  //     this.email = card.email__c;
  //     this.list_name = card.list_name__c;
  //     this.parentId = card.Parent__c;
  //     this.accountId = card.account__c;
  //     this.contactId = card.contact__c;
  //     this.zip_code = card.zip_code__c;
  //     this.freehandmemo = card.freehandmemo__c;
  //     this.memo = card.memo__c;
  //     if (String.isNotBlank(card.Web_url1__c)) {
  //       this.web_url1 = card.Web_url1__c.startsWithIgnoreCase('http') ? card.Web_url1__c : 'http://' + card.Web_url1__c;  // 2018.03.xx v1.22 SV_DEV-825 S1 名刺詳細画面 URL(Web)をhref対応して欲しい
  //     }
  //     this.address_eng = card.address_eng__c;
  //     // デモ用に写真を設定 メールアドレスがファイル名
  //     this.photo = '';
  //     if (SB_NameCard_S2Controller.config.demoOrg == true) {
  //       Set<String> emails = new Set<String>(System.Label.SB_NC_DemoPhotos.toLowerCase().split('[,\\s]'));
  //       if (String.isNotBlank(this.email) && emails.contains(this.email.toLowerCase()) == true) {
  //         this.photo = this.email +'.jpg';
  //       }
  //     }
  //   }

  //   public void bindSObject(sObject obj) {
  //     System.assert(obj.getSObjectType() == NameCard__c.sObjectType);
  //     NameCard__c card = (NameCard__c)obj;
  //     card.Id = (Id)(String.isBlank(this.id) ? null : this.id);
  //     card.Name = this.name;
  //     // card.company_name__c = this.company_name;
  //     // card.company_name_kana__c = this.company_name_kana;
  //     card.division__c = this.division;
  //     card.title_name__c = this.title_name;
  //     card.person_name_last__c = this.person_name_last;
  //     card.person_name_first__c = this.person_name_first;
  //     // card.address_pref__c = this.address_pref;
  //     // card.address__c = this.address;
  //     // card.address_bld__c = this.address_bld;
  //     card.tel1__c = this.tel1;
  //     // card.fax1__c = this.fax1;
  //     // card.mobile__c = this.mobile;
  //     card.email__c = this.email;
  //     // card.list_name__c = this.list_name;
  //     // card.zip_code__c = this.zip_code;
  //     // card.freehandmemo__c = this.freehandmemo;
  //     // card.memo__c = this.memo;
  //     // card.Web_url1__c = this.web_url1;
  //     // card.address_eng__c = this.address_eng;
  //   }

  //   public Integer compareTo(Object compareTo) {
  //     NameCardDTO other = (NameCardDTO)compareTo;
  //     if (card_exchange_date ==  other.card_exchange_date) return 0;
  //     else if (card_exchange_date > other.card_exchange_date) return 1;
  //     else return -1;
  //   }
  // } // NameCardDTO

  // 名刺タグレコードのDTO
  public with sharing class NameCardTagDTO extends SObjectDTO {
    public String name;
    public String type;
    public String cardId;
    public override sObject create() {
      NameCardTagBuilder builder = new NameCardTagBuilder();
      // パッケージ作成環境とかで、タグがつかえないところでテストするから対策
      return enableNameCardTagPersonal ? builder.create(this) : null;
    }
    public override void bind(sObject obj) {
      String prefix = String.isBlank(namespace) ? '' : namespace + '__';
      System.assert(obj.getSObjectType() == Schema.getGlobalDescribe().get(prefix+'NameCard__tag'));  // NameCard__tag.sObjectType を使うと 環境にタグが必須になる。
      this.name = (String)obj.get('Name');
      this.type = (String)obj.get('Type');
      this.cardId = (String)obj.get('ItemId');
    }
  }

  //private static String zeroPad(Integer value, Integer max) {
  //  return (String.valueOf(value)).leftPad(max).replaceAll(' ', '0');
  //}

  //private static String timeOffset {
  //  get {
  //    if (timeOffset == null) {
  //      TimeZone tz = UserInfo.getTimeZone();
  //      Datetime dt = Datetime.now();
  //      Integer n = tz.getOffset(dt);
  //      n = n <0 ? n*-1 : n;
  //      System.debug(n);
  //      Time t = Time.newInstance(0,0,0, (n <0 ? n*-1 : n));
  //      timeOffset = (n <0 ? '-' : '+') + zeroPad(t.hour(), 2) + ':' + zeroPad(t.minute(), 2);
  //    }
  //    return timeOffset;
  //  }
  //  private set;
  //}

  // 活動のDTO 新 2018.03.xx v1.22 から
  public with sharing class ActivityDTO extends SObjectDTO {
    public Account account;
    public Id accountId;
    public SObject who;
    public SObject what;
    public Integer type;        // 1: Task=ToDo 2:Event
    public String subject;          // Both
    public String description;      // Both
    public String startDatetime;    // 行動 Event v1.22 以降 未使用 public なので消せない
    public String endDatetime;      // 行動 v1.22 以降 未使用 public なので消せない
    public Long startDatetimeL;    // 行動 Event       // 2018.03.xx v1.22 SV_DEV-823 Salesforce1 のToDoの詳細画面で期日がnullで表示されている。
    public Long endDatetimeL;      // 行動        // 2018.03.xx v1.22 SV_DEV-823 Salesforce1 のToDoの詳細画面で期日がnullで表示されている。
    public Boolean allDay;          // 行動
    public String activityDate;     // ToDo Taskv1.22 以降 未使用 public なので消せない
    public Long activityDateL;     // ToDo Task        // 2018.03.xx v1.22 SV_DEV-823 Salesforce1 のToDoの詳細画面で期日がnullで表示されている。
    public String location;         // 行動
    public String status;           // ToDo
    public String whatId;           // 2018.03.xx v1.22
    public String whoId;            // 2018.03.xx v1.22
    public String cardId;
    public String taskId;           // 更新の時 NULLでない
    public String eventId;          // 更新の時 NULLでない
    public String recordTypeId;     // 更新の時 NULLでない
    public Object currencyIsoCode;  // SV_DEV-1522 モバイル 新UI 活動編集画面で取引先または取引先責任者のみ関連づけされている（名刺には関連付けされない）「Todo」「行動」を編集した場合にエラーになる。

    public ActivityDTO() {
      allDay = false;     // 終日行動 FALSE
    }

    public override void bind(sObject obj) {
      if (obj.getSObjectType() == Event.sObjectType) {
        bindEvent((Event)obj);
      }
      else if (obj.getSObjectType() == Task.sObjectType) {
        bindTask((Task)obj);
      }
      else  {
        throw new SB_NameCard_S2ControllerException(System.Label.SB_MSG_IllegalRequest);
      }
    }

    public void bindEvent(Event e) {
      this.type = 2;
      this.subject = e.Subject;
      this.description = e.Description;
      this.startDatetimeL = e.StartDateTime != null ? e.StartDateTime.getTime() : null;
      if (e.ActivityDate != null) {
        Datetime dt = Datetime.newInstance(e.ActivityDate.year(), e.ActivityDate.month(), e.ActivityDate.day());
        //this.activityDate = dt.format('yyyy-MM-dd\'T00:00\'Z');
        this.activityDateL = dt.getTime();
      }
      this.allDay = e.IsAllDayEvent;
      //this.endDatetime = e.EndDatetime != null ? e.EndDatetime.format('yyyy-MM-dd\'T\'HH:mmZ') : null;
      this.endDatetimeL = e.EndDatetime != null ? e.EndDatetime.getTime() : null;
      this.location = e.Location;
      this.whatId = e.WhatId;
      this.whoId = e.WhoId;
      this.cardId = e.WhatId != null && e.WhatId.getSObjectType() == NameCard__c.sObjectType ? e.WhatId : null;
      this.eventId = e.Id;
      try {
        this.recordTypeId = (String)e.get('RecordTypeId');
      }
      catch(Exception ex) {}
    }

    public void bindTask(Task t) {
      this.type = 1;
      this.subject = t.Subject;
      this.description = t.Description;
      if (t.ActivityDate != null) {
        Datetime dt = Datetime.newInstance(t.ActivityDate.year(), t.ActivityDate.month(), t.ActivityDate.day());
        //this.activityDate = dt.format('yyyy-MM-dd\'T00:00\'Z');
        this.activityDateL = dt.getTime();
      }
      this.status = t.Status;
      this.whatId = t.WhatId;
      this.whoId = t.WhoId;
      this.cardId = t.WhatId != null && t.WhatId.getSObjectType() == NameCard__c.sObjectType ? t.WhatId : null;
      this.taskId = t.Id;
      try {
        this.recordTypeId = (String)t.get('RecordTypeId');
      }
      catch(Exception ex) {}
    }

    public override sObject create() {
      sObject result = null;
      // v1.22
      NameCard__c card = null;
      if (this.cardId != null && ((Id)this.cardId).getSObjectType() == NameCard__c.sObjectType) {
        card = getNameCardReference(this.cardId);
      }
      SObjectBuilder builder = null;
      // 状況  があれば、 ToDo
      if (String.isBlank(taskId) == false || String.isBlank(status) ==false) {
        // ToDo
        builder = new TaskBuilder();
      }
      else {
        // 行動
        builder = new EventBuilder();
      }
      result = builder.create(this);
      result.put('Subject', subject);
      result.put('Description', description);
      //result.put('WhatId', card.Id);
      // WhatId は 既存なら更新しない
      if (this.whatId != null) {
        result.put('WhatId', this.whatId);
      }
      else if (card != null) {
        result.put('WhatId', card.Id);
      }
      // WhoId は 新規の場合 で コンタクト参照があれば、セット
      if (this.whoId == null && card != null && card.contact__c != null) {
        result.put('WhoId', card.contact__c);
      }
      result.put('OwnerId', UserInfo.getUserId());
      if (String.isBlank(recordTypeId) == false) {
        result.put('recordTypeId', (Id)recordTypeId);
      }
      result.Id = String.isBlank(taskId)==false ? taskId : (String.isBlank(eventId)==false ? eventId : null); // 既存の更新
      return result;
    }
  } // public with sharing class ActivityDTO extends SObjectDTO

  // オブジェクトのレコードを作る基底
  private abstract class SObjectBuilder {
    protected sObject createSObject(String typeName)    {
      // 動的 sObject の作成
      Schema.SObjectType targetType = Schema.getGlobalDescribe().get(typeName);
      if (targetType == null) {
        throw new SB_NameCard_S2ControllerException(System.Label.SB_MSG_IllegalRequest);
      }
      return targetType.newSObject();
    }
    public abstract sObject create(SObjectDTO req);
  }

  //
  private class AnySObjectBuilder extends SObjectBuilder {
    public override sObject create(SObjectDTO r) {
      System.assert(r instanceof AnySObjectDTO);
      AnySObjectDTO req = (AnySObjectDTO)r;
      String objName = SB_NameCard_Util.getObjectName(req.id);
      sObject result = createSObject(objName);
      result.Id = req.id;
      return result;
    }
  }

  // // 名刺  レコードを作るクラス
  // private class NameCardBuilder extends SObjectBuilder {
  //   public override sObject create(SObjectDTO r) {
  //     System.assert(r instanceof SB_NC_NameCardDTO);
  //     SB_NC_NameCardDTO req = (SB_NC_NameCardDTO)r;
  //     String prefix = String.isBlank(namespace) ? '' : namespace + '__';
  //     sObject result = createSObject(prefix + 'NameCard__c');
  //     req.bindSObject(result);
  //     return result;
  //   }
  // }

  // 名刺タグ レコードを作るクラス
  private class NameCardTagBuilder extends SObjectBuilder {
    public override sObject create(SObjectDTO r) {
      System.assert(r instanceof NameCardTagDTO);
      NameCardTagDTO req = (NameCardTagDTO)r;
      // パッケージ作成環境とかで、タグがつかえないところでテストするから対策
      String prefix = String.isBlank(namespace) ? '' : namespace + '__';
      sObject result = enableNameCardTagPersonal ? createSObject(prefix + 'NameCard__tag') : null;
      if (result == null) return null;
      result.put('Name', req.name);
      result.put('Type', req.type);
      result.put('ItemId', req.cardId);
      return result;
    }
  } // private class NameCardTagBuilder extends SObjectBuilder

  // 行動 レコードを作るクラス
  private class EventBuilder extends SObjectBuilder {
    public override sObject create(SObjectDTO r) {
      System.assert(r instanceof ActivityDTO);
      ActivityDTO req = (ActivityDTO)r;
      sObject result = createSObject('Event');
      //if (req.allDay == true) {
      //  System.debug('EventBuilder create : ' + req.ActivityDate);
      //  result.put('IsAllDayEvent', true);
      //  // if (String.isBlank(req.startDatetime) == false)
      //  result.put('ActivityDate', Date.valueOf(req.ActivityDate));
      //  if (String.isBlank(req.endDateTime) == false)
      //    result.put('EndDateTime', Datetime.valueOf(req.endDateTime));
      //  result.put('StartDateTime', null);      // 更新があるので NULL をセット
      //  result.put('EndDateTime', null);        // 更新があるので NULL をセット
      //  result.put('DurationInMinutes', null);  // 更新があるので NULL をセット
      //}
      //else {
      //  result.put('IsAllDayEvent', false);
      //  result.put('ActivityDate', null);       // 更新があるので NULL をセット
      //  if (String.isBlank(req.startDatetime) == false)
      //    result.put('StartDateTime', Datetime.valueOf(req.startDatetime));
      //  if (String.isBlank(req.endDateTime) == false)
      //    result.put('EndDateTime', Datetime.valueOf(req.endDateTime));
      //  else // 終了時刻がなければ、行動の長さのデフォルト値指定
      //    result.put('DurationInMinutes', SB_NameCard_Util.smartViscaConfig.SEventDurationInMinutes__c.intValue());
      //}
      // 2018.03.xx v1.22 SV_DEV-823 Salesforce1 のToDoの詳細画面で期日がnullで表示されている。
      if (req.allDay == true) {
        result.put('IsAllDayEvent', true);
        Datetime dt = Datetime.newInstance(req.activityDateL);
        result.put('ActivityDate', dt.date());
        if (req.endDateTimeL != null) {
          Datetime dt2 = Datetime.newInstance(req.endDateTimeL);
          // 終日のEndDateTime は 2018-03-30T00:00:00.000+0000 のように持ってる GMT の 0時
          result.put('EndDateTime', Datetime.newInstanceGmt(dt2.date().year(), dt2.date().month(), dt2.date().day()));
        }
        else {
          result.put('EndDateTime', null);        // 更新があるので NULL をセット
        }
        result.put('StartDateTime', null);      // 更新があるので NULL をセッ        result.put('DurationInMinutes', null);  // 更新があるので NULL をセット
      }
      else {
        result.put('IsAllDayEvent', false);
        result.put('ActivityDate', null);       // 更新があるので NULL をセット
        if (req.startDatetimeL != null) {
          result.put('StartDateTime', Datetime.newInstance(req.startDatetimeL));
        }
        if (req.endDateTimeL != null) {
          result.put('EndDateTime', Datetime.newInstance(req.endDateTimeL));
        }
        else // 終了時刻がなければ、行動の長さのデフォルト値指定
          result.put('DurationInMinutes', SB_NameCard_Util.smartViscaConfig.SEventDurationInMinutes__c.intValue());
      }
      result.put('Location', req.location);
      return result;
    }
  } // private class EventBuilder extends SObjectBuilder

  // ToDoレコードを作るクラス
  private class TaskBuilder extends SObjectBuilder {
    public override sObject create(SObjectDTO r) {
      System.assert(r instanceof ActivityDTO);
      ActivityDTO req = (ActivityDTO)r;
      sObject result = createSObject('Task');
      //if (String.isBlank(req.activityDate) == false)
      //  result.put('ActivityDate', Date.valueOf(req.activityDate));
      // 2018.03.xx v1.22 SV_DEV-823 Salesforce1 のToDoの詳細画面で期日がnullで表示されている。
     if (req.activityDateL != null) {
        Datetime dt = Datetime.newInstance(req.activityDateL);
        result.put('ActivityDate', dt.date());
      }
      else {
      // 2019.10.xx v2.4 SV_DEV-2125 S1 新SmartViscaタブ：Androidで活動の日付が正しく編集・保存できない → NULLを許容する。
        result.put('ActivityDate', null);
      }
      result.put('status', req.status);
      return result;
    }
  } // private class TaskBuilder extends SObjectBuilder

  public class SelectOption {
    public String name { get; private set; }
    public String value { get; private set; }
    public SelectOption(String name) {
      this.name = name;
      this.value = null;
    }
  } // public class SelectOption

  private static List<SelectOption> createSelectOption(List<String> names) {
    List<SelectOption> results = new List<SelectOption>();
    for (String name :names) {
      results.add(new SelectOption(name));
    }
    return results;
  }
  // ToDo の状況の選択リスト値のリストを取得
  @RemoteAction
  public static List<SelectOption> getTaskStatusOptions() {
    return createSelectOption(SB_NameCard_Util.getPickListEntry(Task.status));
  }

  // 行動 or ToDo を保存 更新 or 作成
  @RemoteAction
  public static Response saveActivities(List<ActivityDTO> reqs) {
    Response res = new Response();
    try {
      SObjectFactory factory = new SObjectFactory();
      factory.run(reqs);
    }
    catch(DMLException ex) {
      System.debug(ex.getDmlMessage(0));
      throw new SB_NameCard_S2ControllerException(ex.getDmlMessage(0));
    }
    catch(Exception ex) {
      System.debug(ex.getMessage());
      res.setResponse(ex);
    }
    return res;
  }

  /**
  * 最近更新した ToDo、行動 の Subjectを取得する。
  * Integer type : 1: ToDo Task ,その他: 行動
  **/
  @RemoteAction
  public static List<String> getActivitySubject(Integer type) {
    List<String> results = new List<String> ();
    Schema.SObjectType targetType = Schema.getGlobalDescribe().get(type == 1 ? 'Task' : 'Event');
    Map<String, Schema.SObjectField> fields = targetType.getDescribe().fields.getMap();
    Set<String> subjects = new Set<String>();
    subjects.addAll(SB_NameCard_Util.getPickListEntry(fields.get('Subject')));
    String query = 'SELECT subject from ' + (type == 1 ? 'Task' : 'Event') +
      ' where subject != null and OwnerId = \'' + UserInfo.getUserId() + '\' Order by LastModifiedDate DESC limit 200';
    List<sObject> objs = Database.query(query);
    if (objs.isEmpty() == false) {
      for (sObject obj : objs) {
        subjects.add((String)obj.get('subject'));
      }
    }
    results.addAll(subjects);
    results.sort();
    return results;
  }

  // オブジェクトの削除
  @RemoteAction
  public static Response deleteSObjects(List<String> objectIds) {
    Response res = new Response();
    try {
      List<sObject> objs = new List<sObject>();
      for (String objectId : objectIds) {
        AnySObjectDTO porter = new AnySObjectDTO(objectId);
        sObject obj = porter.create();
        if (obj == null)
          throw new SB_NameCard_S2ControllerException(System.Label.SB_MSG_IllegalRequest);
        objs.add(obj);
      }
      delete objs;
    }
    catch(Exception ex) {
      System.debug(ex.getMessage());
      res.setResponse(ex);
    }
    return res;
  }

  /**
  * レコードタイプ情報を取得
  *
  **/
  // レコードタイプ情報
  public class RecordTypeDTO implements Comparable {
    public String objName { get; private set; }
    public String label { get; private set; }
    public String id { get; private set; }
    public Boolean defVal { get; private set; }
    public RecordTypeDTO(String objName, Schema.RecordTypeInfo info) {
      this.objName = objName;
      this.label = info.getName();
      this.id = info.getRecordTypeId();
      this.defVal = info.isDefaultRecordTypeMapping();
    }
    public RecordTypeDTO(String objName, RecordType info) {
      this.objName = objName;
      this.label = info.Name;
      this.id = info.Id;
      this.defVal = false;
    }
    public Integer compareTo(Object obj) {
      RecordTypeDTO rct = (RecordTypeDTO)obj;
      return this.label.compareTo(rct.label);
    }
  }

  private static Map<String, Schema.RecordTypeInfo> getMapRecordType(String target, Boolean standard) {
    String objName = standard == false ? namespace + '__' : '';
    objName += target;
    Schema.DescribeSObjectResult R = Schema.getGlobalDescribe().get(objName).getDescribe();
    System.assert(R != null);
    return R.getRecordTypeInfosByName();
  }
  // オブジェクトごとのレコードタイプを保持するマップ
  private static Map<String, List<RecordType>> mapName2RecTypes {
    get {
      if (mapName2RecTypes == null) {
        mapName2RecTypes = new Map<String, List<RecordType>>();
      }
      return mapName2RecTypes;
    }
    private set;
  }
  // カスタムレコードタイプかチェック
  private static Boolean isCustomRecordType(String objName, String recTypeName) {
    List<RecordType> recTypes =null;
    if (mapName2RecTypes.containsKey(objName) == true) {
      recTypes = mapName2RecTypes.get(objName);
    }
    else {
      recTypes = [Select Id, Name from RecordType Where SobjectType=:objName AND IsActive=true];
      mapName2RecTypes.put(objName, recTypes);
    }
    for (RecordType rt : recTypes) {
      if (rt.Name == recTypeName)
      return true;
    }
    return false;
  }

  /**
  * 指定されたオブジェクトのレコードタイプ情報のリストを返す。
  *
  **/
  @RemoteAction
  public static List<RecordTypeDTO> getRecordTypes(String objName) {
    List<RecordTypeDTO> results = new List<RecordTypeDTO>();
    Map<String, Schema.RecordTypeInfo> mapLabel2Info = getMapRecordType(objName, true);
    for (Schema.RecordTypeInfo info : mapLabel2Info.values()) {
      System.debug(info.getName());
      if (info.isAvailable() == false) continue;
      if (isCustomRecordType(objName, info.getName()) == false) continue;  // マスタ とかもあるので、チェックします。
      results.add(new RecordTypeDTO(objName, info));
    }
    results.sort();
    return results;
  }

  /**
  *
  *  指定されたユーザの詳細情報を返す。
  *       標準オブジェクトだからそのまま
  *       Chatterの有効無効を考慮する。
  *
  **/
  private static String getUserProfileFields() {
    String result = 'Id, Name, CompanyName, Title, Email, Phone, Fax, PostalCode, Country, State, City, Street, ManagerId, Manager.Name';
    if (enableFeedItem == true) {
      result += ', AboutMe, FullPhotoUrl, SmallPhotoUrl, Latitude, Longitude';
    }
    return result;
  }

  @RemoteAction
  public static User getUserProfile(String userId) {
    try {
      String query = 'SELECT ' + getUserProfileFields() + ' FROM User WHERE Id=:userId';
      List<User> users = Database.query(query);
      return users[0];
    }
    catch(Exception ex) {
      System.debug(ex.getMessage());
    }
    return null;
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
  // @RemoteAction
  // public static SB_NameCard_UserList.DepartmentUsers getDepartmentUsers() {
  //   return SB_NameCard_UserList.getDepartmentUsers(null, null);
  // }

  // public class GetDepartmentUsersRequest {
  //   public String dept;
  //   public String word;
  // }
  @RemoteAction
  public static SB_NameCard_UserList.DepartmentUsers getDepartmentUsers(String dept, String word) {
    return SB_NameCard_UserList.getDepartmentUsers(dept, word);
  }


}