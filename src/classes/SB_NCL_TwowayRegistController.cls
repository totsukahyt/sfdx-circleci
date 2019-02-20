/**
 * SB_NCL_TwowayRegistController
 *
 *    基本 V2.0.1 時点の SB_NC_AccountRegistCommonController の流用
 *   Lightning Express 対応 取引先・取引先責任者  一括・個別 登録画面 共通 コントローラ
 *
 * Copyright (C) 2016 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2016.11.xx
 *  @Version 2      2017.08.xx IE を区別する
 *  SB_NCL_TwowayRegistController
 *    lx 2.0 2018.08.xx
 **/
/*
  Exception のときの event オブジェクトの内容
    action:"SB_NC_AccountBulkRegistController"
    data:""
    message:"getListViewConfig Error"
    method:"getListViewConfig"
    ref:false
    result:null
    status:false
    statusCode:400
    tid:2
    type:"exception"
    vfDbg:true
    vfTx:true
    where:""
*/
// getConfig 諸設定を取得
// getListViewConfig リストビューの一覧を取得
// getFilteredRecords 選択したビューに該当するレコードを取得 Pagenation 対応
// getRecordTypeInfo レコードタイプの一覧を取得 オフセット対応
// getNameCard 名刺の詳細を取得
// getAccountOptions 名刺に該当する取引先を取得
public with sharing class SB_NCL_TwowayRegistController {
  public class SB_NCL_TwowayRegistControllerException extends Exception {}

  private static final String NMAECARD_FIELDS = 'Id, Name, SmartViscaf__name_kana__c, SmartViscaf__person_name_last__c, SmartViscaf__person_name_first__c' +
    ', SmartViscaf__company_name__c, SmartViscaf__company_name_kana__c, SmartViscaf__division__c, SmartViscaf__title_name__c' +
    ', SmartViscaf__zip_code__c, SmartViscaf__address_pref__c, SmartViscaf__address__c, SmartViscaf__address_bld__c, SmartViscaf__address_eng__c' +
    ', SmartViscaf__card_exchange_date__c, SmartViscaf__list_name__c, OwnerId, Owner.Name, SmartViscaf__Parent__c, SmartViscaf__tenshokugonomeishi__c, SmartViscaf__account__c, SmartViscaf__contact__c' +
    ', SmartViscaf__freehandmemo__c, SmartViscaf__memo__c, SmartViscaf__web_url1__c, SmartViscaf__email__c, SmartViscaf__tel1__c, SmartViscaf__mobile__c, SmartViscaf__fax1__c' +
    ', SmartViscaf__image_id__c, SmartViscaf__bk_image_id__c, SmartViscaf__width__c, SmartViscaf__height__c, SmartViscaf__bk_width__c, SmartViscaf__bk_height__c' +
    ', SmartViscaf__isNotOverwrite__c, SmartViscaf__isNotOverContactwrite__c';    // 既存取引先上書き不可,既存取引先責任者上書き不可

  // 起動の引数
  //public String obj_name {get; private set; }
  //public String fields { get; private set; }
  public String retUrl { get; private set; }
  public String viewId { get; private set; }   // 選択したビューのId
  public String viewLabel { get; private set; } // 選択したビューの名称
  public String urlRoot { get; private set; } // Edge での LEX のとき用 URL の プロトコル+ホスト名 部分 ex. https://svdev06-dev-ed--c.ap0.visual.force.com
  public Boolean isIE { get; private set; }   // 2017.08.xx IE を区別する

  // 詳細画面で開いたら名刺レコードID
  public Id targetId { get; private set; }
  // ビューで選択されたオブジェクト VF の方にはIDのリストでバインドされる。
  public List<String> targetIds { get; private set; }
  public List<SObject> targets { get; private set; }
  // 名前空間名
  public String getNameSpace() { return SB_NameCardL_Util.getNamespacePrefix(); }

  /**
   * Constructor
   **/
  public SB_NCL_TwowayRegistController() {
    try {
      PageReference page = ApexPages.currentPage();
      System.debug('URL: ' + page.getUrl());
      Map<String, String> paras = page.getParameters();
      if (paras.containsKey('id')) {
        this.targetId = (Id)paras.get('id');
      }
      if (paras.containsKey('viewId')) {
        this.viewId = paras.get('viewId');
        System.debug('viewId: ' + this.viewId);   // 2017.06.xx Summer17 からの問題の調査用
      }
      if (paras.containsKey('retURL')) {
        this.retUrl = paras.get('retUrl');
        //this.urlRoot = getUrlRoot(this.retUrl);
      }
      for (String h : page.getHeaders().keySet()) {
        System.debug('HEADER: ' + h + '=' + page.getHeaders().get(h));
      }
      //this.urlRoot = 'https://' + page.getHeaders().get('Host');
      //System.debug('this.urlRoot: ' + this.urlRoot);
      // 2017.08.xx IE を区別する
      String userAgent = page.getHeaders().get('USER-AGENT');
      System.debug('userAgent: ' + userAgent);
      this.isIE = String.isNotBlank(userAgent) && userAgent.containsIgnoreCase('Windows');
      System.debug('isIE: ' + this.isIE);

      String referer = page.getHeaders().get('Referer');
      this.urlRoot = getUrlRoot(referer);
      System.debug('this.urlRoot: ' + this.urlRoot);
      if (String.isNotBlank(this.viewId)) {
        this.viewLabel = SB_NCL_ListViewConfig.getViewLabel('SmartViscaf__NameCard__c', this.viewId);
      }
      if (paras.containsKey('idskey')) {
        // 一括登録
        String idskey = paras.get('idskey');
        System.debug('idskey: ' + idskey);
        Map<String, System.Cookie> key2cookie = ApexPages.currentPage().getCookies();
        for (String k : key2cookie.keySet()) {
          System.debug(' ' +  k + ':  ' + key2cookie.get(k));
        }
        System.Cookie cookie = key2cookie.get(idskey);
        System.debug(cookie);
        this.targetIds = cookie.getValue().split(',');
        System.debug('SB_NCL_TwowayRegistController Id: ' + this.targetIds.size());
        System.debug(this.targetIds);
      }
      if (String.isBlank(this.targetId) && this.targetIds.isEmpty()) {
        throw new SB_NCL_TwowayRegistControllerException('Invalid request. target not specified.');
      }
    } catch (Exception e) {
      ApexPages.addMessages(e);
    }
  }

  @TestVisible
  private String getUrlRoot(String url) {
    String result = '';
    if (String.isNotBlank(url) && url.startsWithIgnoreCase('https://')) {
      // LEXのときだけ。LEX だとプロトコルからあるので、
      String[] ss = url.substringAfter('https://').split('/');
      result = 'https://' + (ss.size() > 0 ? ss[0] : '');   // 念のため
    }
    return result;
  }

  /**
   * Constructor
   **/
  //public SB_NCL_TwowayRegistController() {
  //  this.obj_name = System.currentPageReference().getParameters().get('sobject');
  //  String f = System.currentPageReference().getParameters().get('fields');
  //  if (String.isNotBlank(f)) {
  //    String[] ss = f.split('\\s*,\\s*');
  //    this.fields = '';
  //    for (String s : ss) {
  //      this.fields += s + ',';
  //    }
  //    this.fields = this.fields.removeEnd(',');
  //  }
  //  //this.cols = new Set<String>(ss);
  //  this.retUrl = System.currentPageReference().getParameters().get('retUrl');
  //}

  /**
   * View から 呼ばれるときの Constructor　
   *    名刺レコードを選択されている。
   **/
  // LEX
  // URL: /apex/SB_NCL_AccountBulkRegist?ids=a0210000016psccAAA&isdtp=p1&sfdcIFrameHost=web&sfdcIFrameOrigin=https%3A%2F%2Fsvdev06-dev-ed.lightning.force.com&use307redirect=true&vfRetURLInSFX=https%3A%2F%2Fsvdev06-dev-ed.lightning.force.com%2Fone%2Fone.app%23%2FsObject%SmartViscaf__2FNameCard__c%2Flist%3FfilterName%3D00B1000000580lnEAA%26t%3D1482406041888&wrapMassAction=1
  // vfRetURLInSFX https://svdev06-dev-ed.lightning.force.com/one/one.app#/sObject/SmartViscaf__NameCard__c/list?filterName=00B1000000580lnEAA&t=1482406041888
  //              or https://svdev06-dev-ed.lightning.force.com/one/one.app?source=aloha#/sObject/SmartViscaf__NameCard__c/list?filterName=00B1000000580lnEAA&t=1482409047718
  // Classic
  // URL: /apex/SB_NCL_AccountBulkRegist?00B1000000580ln_pageState=1&00B1000000580ln_rolodexState=-1&accountbulkregistlex=LEX%E4%B8%80%E6%8B%AC%E5%8F%96%E7%99%BB%E9%8C%B2%E3%83%86%E3%82%B9%E3%83%88&fcf=00B1000000580ln&ids=a0210000016pscc&retURL=%2Fa02%3Ffcf%3D00B1000000580ln&scontrolCaching=1&wrapMassAction=1
  // retURL /a02?fcf=00B1000000580ln
  public SB_NCL_TwowayRegistController(ApexPages.StandardSetController controller) {

    PageReference page = ApexPages.currentPage();
    Map<String, String> paras = page.getParameters();
    Boolean bLex = false;
    if (paras.containsKey('vfRetURLInSFX')) {
      bLex = true;
      this.retUrl = paras.get('vfRetURLInSFX');
      this.viewId = getViewidFromUrl(this.retUrl, bLex);
      this.urlRoot = getUrlRoot(this.retUrl);     // LEX のときだけでいい
    }
    else if (paras.containsKey('retURL')) {
      bLex = false;
      this.retUrl = paras.get('retUrl');
      this.viewId = getViewidFromUrl(this.retUrl, bLex);
    }
    if (String.isNotBlank(this.viewId)) {
      this.viewLabel = SB_NCL_ListViewConfig.getViewLabel('SmartViscaf__NameCard__c', viewId);
    }
    this.targets = controller.getSelected();
    this.targetIds = new List<String>();
    for (SObject obj : controller.getSelected()) {
      targetIds.add(obj.Id);
    }
    System.debug('SB_NCL_TwowayRegistController Id: ' +  targetIds.size());
    System.debug(targetIds);
  }

  private String getViewidFromUrl(String u, Boolean bLex) {
    if (String.isBlank(u)) {    // LEXのときはない
      return '';
    }
    //String[] ss= u.substringAfter('?').split('&');
    String[] ss= u.split('[?&]');     // LEX のとき、URLが不定かも？
    if (bLex) {
      for(String s : ss) {
        if (s.startsWithIgnoreCase('filterName=')) {
          return s.substringAfter('filterName=');
        }
      }
    }
    else {
      for(String s : ss) {
        if (s.startsWithIgnoreCase('fcf=')) {
          return s.substringAfter('fcf=');
        }
      }
    }
    return '';
  }


  // 諸設定を取得
  @RemoteAction
  public static SmartViscaf.SB_NameCard_S1Config getSVConfig() {
    return SmartViscaf.SB_NameCard_S1Config.config;
  }

  /**
   *
   *  getListViewOptions 指定したオブジェクトの ビューの一覧を取得する
   *
   **/
  @RemoteAction
  public static List<SB_NCL_ListViewConfig.ListViewInfo> getListViewOptions(String obj_name, String fields) {
    return SB_NCL_ListViewConfig.getListViewOptions(obj_name, fields);
  }

  // リストビューに表示する項目
  // Todo 参照先も可にする。
  private static final String LISTVIEW_COLS = 'Id, Name, SmartViscaf__name_kana__c, SmartViscaf__company_name__c, SmartViscaf__division__c, SmartViscaf__title_name__c, SmartViscaf__address_pref__c, SmartViscaf__card_exchange_date__c, SmartViscaf__email__c';
  // リストビュー 1ページにに表示する行数
  private static final Integer LISTVIEW_PAGESIZE = 20;

  /**
   *
   * getListViewConfig リストビューの一覧を取得
   *
   **/
  @RemoteAction
  public static SB_NCL_ListViewConfig getListViewConfig() {
    //throw new SB_NCL_AccountBulkRegistControllerException('getListViewConfig Error');
    SB_NCL_ListViewConfig result = new SB_NCL_ListViewConfig('SmartViscaf__NameCard__c', LISTVIEW_COLS);
    return result;
  }

  /*
  *  getFilteredRecords 　ビューを使った 検索
  *
  */
  public class FilteredQueryRequest extends SB_NCL_ListViewConfig.FilteredQueryRequest {}
  //public class FilteredQueryRequest {
  //  public String obj_name;
  //  public String fields;
  //  public String order;
  //  public Boolean isAsc;
  //  public String filterId;   // リストビューのID
  //  public Integer pageNo;
  //  public Integer pageSize;
  //  public FilteredQueryRequest() {
  //    order = 'Id';
  //    isAsc = true;
  //    pageNo = 0;
  //  }
  //  public void setDummy() {
  //    obj_name = 'SmartViscaf__NameCard__c';
  //    fields = 'Name,SmartViscaf__company_name__c,SmartViscaf__division__c,SmartViscaf__title_name__c';
  //    order = 'Id';
  //    isAsc = true;
  //    filterId = '00B1000000443gFEAQ';   // リストビューのI D
  //    pageNo = 0;
  //    pageSize = 20;
  //  }
  //}
  public class FilteredQueryResponse  extends SB_NCL_ListViewConfig.FilteredQueryResponse {
    public FilteredQueryResponse(FilteredQueryRequest req) {
      this.req = req;
    }
  }
  //public class FilteredQueryResponse {
  //  public FilteredQueryRequest req;
  //  public List<SObject> records;
  //  public FilteredQueryResponse(FilteredQueryRequest req) {
  //    this.req = req;
  //  }
  //  public void run() {
  //    ApexPages.StandardSetController scon = SB_NCL_ListViewConfig.createStandardSetController(req.obj_name, req.fields, req.order, req.isAsc);
  //    scon.setPageSize(req.pageSize);
  //    scon.setpageNumber(req.pageNo);
  //    scon.setFilterId(req.filterId);
  //    records = scon.getRecords();
  //  }
  //}

  @RemoteAction
  public static FilteredQueryResponse getFilteredRecords(FilteredQueryRequest req) {
    FilteredQueryResponse response = new FilteredQueryResponse(req);
    response.run();
    return response;
  }

  /**
   *
   *  getRecordTypeInfo 　指定されたオブジェクトのレコードタイプを返す。
   *
   **/
  // レコードタイプに関する情報
  public class RecordTypeInfo {
    public String  label;
    //public String  apiname;
    public String  id;
    public Boolean use;
    RecordTypeInfo(Schema.RecordTypeInfo info) {
      this.label = info.getName();
      this.id = info.getRecordTypeId();
      this.use = true;
    }
  }

  public class RecordTypeInfos {
    public String objName;
    public String objLabel;
    public List<RecordTypeInfo> infos;
    // constructor
    public RecordTypeInfos(String objName) {
      this.infos = new List<RecordTypeInfo>();
      this.objName = objName;
      Schema.DescribeSObjectResult dsr = Schema.getGlobalDescribe().get(objName).getDescribe();
      this.objLabel = dsr.getLabel();
      Map<String, Schema.RecordTypeInfo> mapRecordTypes = dsr.getRecordTypeInfosByName();
      for (String key : mapRecordTypes.keySet()) {
        Schema.RecordTypeInfo info = mapRecordTypes.get(key);
        if (info.isAvailable() == false) continue;   // ユーザが使用可能なものだけ
        if (info.isMaster() == true) continue;   // マスターは除外
        if (info.isDefaultRecordTypeMapping() && !this.infos.isEmpty()) {
         // デフォルトは一番目に
          this.infos.add(0, new RecordTypeInfo(info));
        }
        else {
          this.infos.add(new RecordTypeInfo(info));
        }
      }
    }
  }


  //// レコードタイプに関する情報を返す。
  //@RemoteAction
  //public static List<RecordTypeInfos> getRecordTypeInfos(List<String> objNames) {
  //  List<RecordTypeInfos> result = new List<RecordTypeInfos> ();
  //  for (String objName : objNames) {
  //    result.add(new RecordTypeInfos(objName));
  //  }
  //  return result;
  //}

  @RemoteAction
  public static Map<String, RecordTypeInfos> getRecordTypeInfos(List<String> objNames) {
    Map<String, RecordTypeInfos> result = new Map<String, RecordTypeInfos> ();
    for (String objName : objNames) {
      result.put(objName, new RecordTypeInfos(objName));
    }
    return result;
  }

  /**
   *
   *  getRegistOptions 　名刺単位の選択可能なオプションを返す。
   *
   **/
  //// 引数 名刺IDと 検索のオプション
  public class RegistOptionRequest extends SB_NCL_RegistOptionCreater.RegistOptionRequest {
    @TestVisible
    private RegistOptionRequest(List<Id> ncIds, QueryOption opt) {
      super(ncIds, opt);
    }
  }
  //  public List<Id> ncIds;
  //  QueryOption opt;    // 既存の上書き対象のレコードを探すオプション
  //  public RegistOptionRequest(List<Id> ncIds, QueryOption opt) {
  //    this.ncIds = ncIds;
  //    this.opt = opt;
  //  }
  //}

  //// 既存の上書き対象のレコードを探すオプション
  public class QueryOption extends SB_NCL_RegistOptionCreater.QueryOption {}
  //  public Boolean bulkRegist;      // TURE:一括登録 FALSE:個別登録
  //  public Boolean querySite;      // 所属名を条件にして検索 0: 取引先名と所属名で検索 1,その他: 取引先名のみで検索
  //  public Boolean queryState;     // 都道府県を条件にして検索
  //  public Boolean queryCity;      // 市区郡を条件にして検索
  //  public Boolean queryZip;       // 郵便番号を条件にして検索
  //  public List<String> acntRecTypeIds;  // アカウントのレコードタイプ名を条件にする
  //  public List<String> contRecTypeIds;  // コンタクトのレコードタイプ名を条件にする
  //  public QueryOption() {
  //    this.bulkRegist = false;
  //    this.querySite = false;
  //    this.queryState = false;
  //    this.queryCity = false;
  //    this.queryZip = false;
  //    this.acntRecTypeIds = null;
  //    this.contRecTypeIds = null;
  //  }
  //}

  // getRegistOptions 　名刺単位の選択可能なオプションを返す。
  @RemoteAction
  public static List<SB_NCL_RegistOptionCreater.Card_RegistOption> getRegistOptions(RegistOptionRequest req) {
    SB_NCL_RegistOptionCreater creater = new SB_NCL_RegistOptionCreater();
    return creater.getRegistOptions(req);
  }

  /**
  *
  *  getNameCard 表示用の名刺情報を取得する
  *
  **/
  @RemoteAction
  public static SB_NCL_NameCardDTO getNameCard(String targetId) {
    String query =
         'SELECT '+ SB_NCL_NameCardDTO.NC_QUERY_FIELDS + ' FROM SmartViscaf__NameCard__c WHERE Id = :targetId';
    List<SmartViscaf__NameCard__c> cards = Database.query(query);      // 照会実施
    if (cards.isEmpty()) {
      throw new SB_NCL_TwowayRegistControllerException(Label.SB_MSG_IllegalRequest + 'Id : ' + targetId);
    }
    SB_NCL_NameCardDTO result = new SB_NCL_NameCardDTO();
    result.bind(cards[0]);
    return  result;
  }

  /**
  *
  *  getAccountOptions 名刺に該当する取引先を取得
  *
  **/
  @RemoteAction
  public static List<SB_NCL_RegistOptionCreater.RegistOption> getAccountOptions(Id cardId, QueryOption opt) {
    System.debug(opt);
    return SB_NCL_RegistOptionCreater.getAccountOptions(cardId, opt);
  }

  /**
  *
  *  getContactOptions 名刺と取引先に該当する取引先責任者を取得
  *
  **/
  @RemoteAction
  public static List<SB_NCL_RegistOptionCreater.RegistOption> getContactOptions(Id cardId, Id accountId, QueryOption opt) {
    System.debug(opt);
    return SB_NCL_RegistOptionCreater.getContactOptions(cardId, accountId, opt);

  }


  /**
  *
  *  registAccountContact 登録用メソッド
  *
  **/
  // リクエスト
  public class RegistRequest extends SB_NameCardL_RegistHelper.RegistRequest {}
    //public virtual class RegistRequest {
    //  public List<RegistTarget> targets { get; private set; } // 対象のレコード達のID
    //  public RegistParam acntParam { get; private set; }      // アカウント登録のオプション
    //  public RegistParam contParam { get; private set; }
    //  public RegistParam someParam { get; private set; }
    //  public TodoParam todoParam { get; private set; }
  // 対象のオブジェクトIDたち  クライアント側で参照して値をセットする
  public class RegistTarget extends SB_NameCardL_RegistHelper.RegistTarget {}
    //public virtual class RegistTarget {
    //  public Id cardId { get; private set; }
    //  public Id acntId { get; private set; }
    //  public Id contId { get; private set; }
    //  public Id someId { get; private set; }
    //  public Boolean makeTodo { get; private set; }
    //  public Date todoDate { get; private set; }
  //　登録のオプション クライアント側で参照して値をセットする
  public class RegistParam extends SB_NameCardL_RegistHelper.RegistParam {}
    //public virtual class RegistParam {
    //  //public Id targetId { get; private set; }
    //  public String objName { get; private set; }
    //  public Boolean overwrite { get; private set; }
    //  public Id recTypeId { get; private set; }
    //  public Boolean allowSave { get; private set; }      // 重複してても作成・更新する。
    //  public Map<String, Object> filed2value { get; private set; }  // 特定の項目の値を指定してよこす リードの キャンペーンIDとか
  // 登録するToDo の内容
  public class TodoParam extends SB_NameCardL_RegistHelper.TodoParam {}
    //public virtual class TodoParam {
    //  public String subject { get; private set; }
    //  public Date activityDate { get; private set; }
    //  public String comment { get; private set; }

  @RemoteAction
  public static SB_NameCardL_RegistHelper.RegistResponse registAccountContact(RegistRequest req) {
    System.debug(req.acntParam);
    System.debug(req.contParam);
    System.debug(req.leadParam);
    //SB_NameCardL_RegistHelper proc = new SB_NC_RegistExecutor(req);
    //SB_NameCardL_RegistHelper.RegistResponse result = proc.run();
    //return result;
    return SB_NameCardL_RegistHelper.doRegist(req);
  }

  // SOSL で 取引先 を検索して RegistOption で返す
  @RemoteAction
  public static List<SB_NCL_RegistOptionCreater.RegistOption> searchAccount(String word, List<String> recTypes) {
    return SB_NCL_RegistOptionCreater.searchAccount(word, recTypes);
  }

  // SOSL で 取引先責任者 を検索して RegistOption で返す
  @RemoteAction
  public static List<SB_NCL_RegistOptionCreater.RegistOption> searchContact(String word, Id accountId, List<String> recTypes) {
    return SB_NCL_RegistOptionCreater.searchContact(word, accountId, recTypes);
  }

  // SOSL で リード を検索して RegistOption で返す lx 2.0
  @RemoteAction
  public static List<SB_NCL_RegistOptionCreater.RegistOption> searchLead(String word, List<String> recTypes) {
    return SB_NCL_RegistOptionCreater.searchLead(word, recTypes);
  }

  // SOSL で Campaign を検索して Campaign レコード で 返す lx 2.0
  @RemoteAction
  public static List<Campaign> searchCampaign(String word) {
    return SB_NCL_RegistOptionCreater.searchCampaign(word);
  }

  public class CampaignStatus {
    public String label;
    public String value;
    public Boolean defaultValue;
    public CampaignStatus(Schema.PicklistEntry entry) {
      this.label = entry.getLabel();
      this.value = entry.getValue();
      this.defaultValue = entry.isDefaultValue();
    }
  }
  // キャンペーンの状況のデフォルト
  @RemoteAction
  public static List<CampaignStatus> getCampaignStatusList() {
    List<CampaignStatus> result = new List<CampaignStatus>();
    for (Schema.PicklistEntry entry : Campaign.Status.getDescribe().getPicklistValues()) {
      if (entry.isActive()) {
        result.add(new CampaignStatus(entry));
      }
    }
    return result;
  }

  // SOSL で 所定のオブジェクトを検索して RegistOption で返す 親のアカウントのIDを指定可能
  @RemoteAction
  public static List<SB_NCL_RegistOptionCreater.RegistOption> searchRegistOptions(String word, String objName, Id accountId, List<String> recTypes) {
    return SB_NCL_RegistOptionCreater.searchRegistOptions(word, objName, accountId, recTypes);
  }

  @RemoteAction
  public static List<SB_NCL_RegistOptionCreater.RegistOption> searchSObject(String word, String objName, Id accountId, List<String> recTypes) {
    return SB_NCL_RegistOptionCreater.searchRegistOptions(word, objName, accountId, recTypes);
  }


  /**
  *
  * 補助的なメソッド
  *
  **/
  @TestVisible
  private static List<String> getNamesWithRecordTypes(Set<Id>ids, String obj_name, List<String> recTypes) {
    List<String> result = new List<String>();
    Set<Id> targetIds = new Set<Id>(ids);
    String query = 'SELECT Id, Name FROM ' + obj_name + ' WHERE Id IN :targetIds';
    Set<String> targetRecTypeIds = null;
    if (recTypes !=null && !recTypes.isEmpty()) {   // テストコードように、recTypes の指定がなくてもとおるようにする
      targetRecTypeIds = new Set<String>(recTypes);
      query += ' AND RecordTypeId IN :targetRecTypeIds';
    }
    List<SObject> objs  = Database.query(query);
    for (SObject obj : objs) {
      result.add((String)obj.get('Name'));
    }
    return result;
  }


  // 指定のオブジェクトで最近参照したレコードのNameを返す 最大 100件
  @RemoteAction
  public static List<String> getRecentlyViewed(String obj_name, List<String> recTypes) {
    List<String> result = new List<String>();
    List<AggregateResult> ars = [SELECT Id, Name, Type FROM RecentlyViewed WHERE Type = :obj_name Group by Id, Type, Name Order by Type, Name LIMIT 100];
    if (ars.isEmpty()) {
      return result;
    }
    if (recTypes == null || recTypes.isEmpty()) {
      for (AggregateResult ar : ars) {
        result.add((String)ar.get('Name'));
      }
    }
    else {
      Set<Id> ids = new Set<Id>();
      for (AggregateResult ar : ars) {
        ids.add((Id)ar.get('Id'));
      }
      result.addAll(getNamesWithRecordTypes(ids, obj_name, recTypes));
    }
    return result;
  }

  /*
  *  シンプルな　ルックアップ用のメソッド
  *
  */
  private static final Map<String, String> objName2Fields = new Map<String, String> {
    'user' =>  'Id, Name, Username, Email, Division, Title'
  };

  static final String FIND_DEF_FIELDS = 'Id, Name, Owner.Name';

  private static String getFindFields(String objName) {
    if (objName2Fields.containsKey(objName)) {
      return objName2Fields.get(objName);
    }
    return FIND_DEF_FIELDS;
  }


  private static final Map<SObjectType, String> otype2Fields = new Map<SObjectType, String> {
    User.sObjectType =>  'Id, Name, Username, Email, Division, Title',
    Account.sObjectType =>  'Id, Name, Owner.Name',
    Contact.sObjectType =>  'Id, Name, Owner.Name'
  };

  private static String getFindFields(SObjectType otype) {
    if (otype2Fields.containsKey(otype)) {
      return otype2Fields.get(otype);
    }
    return FIND_DEF_FIELDS;
  }

  // SOSL で 所定のオブジェクトを検索して RegistOption で返す 親のアカウントのIDを指定可能
  @RemoteAction
  public static List<SOBject> searchSObjects(String word, String objName, List<String> recTypes) {
    String oname = SB_NameCardL_Util.getManagedObjectName(objName);
    SObjectType otype = Schema.getGlobalDescribe().get(oname);
    System.assert(otype != null);
    String searchWord = SB_NameCardL_Util.escapeSOSLYoyakugo(word);
    Set<String> recTypeIds = null;
    String query = 'FIND {' + searchWord + '} IN ALL FIELDS RETURNING ' + oname +'(' + getFindFields(objName.toLowerCase());
    if (recTypes != null && recTypes.size() > 0) {
      recTypeIds = new Set<String>(recTypes);
      query += ' WHERE RecordTypeId IN :recTypeIds';
    }
    query += ')';
    System.debug(String.format('++{0} SOSL : {1}', new String[] {oname, query} ));
    List<List<sObject>> searchList = search.query(query);
    if (searchList.isEmpty() == false && searchList[0].isEmpty() == false) {
      return searchList[0];
    }
    return null;
  }

  private static final String QUERY_ID_FORMAT = 'SELECT {0} FROM {1} WHERE Id = \'\'{2}\'\'';

  @RemoteAction
  public static SObject getRecordById(String objName, String id) {
    String oname = SB_NameCardL_Util.getManagedObjectName(objName);
    SObjectType otype = Schema.getGlobalDescribe().get(oname);
    System.assert(otype != null);
    String query = String.format(QUERY_ID_FORMAT, new String[]{ getFindFields(objName.toLowerCase()), objName, id});
    List<SObject> objs = Database.query(query);
    return objs.isEmpty() ? null : objs[0];
  }

  @RemoteAction
  public static SObject getRecordById(Id id) {
    SObjectType otype = id.getSobjectType();
    String objName = otype.getDescribe().getName();
    String query = String.format(QUERY_ID_FORMAT, new String[]{ getFindFields(otype), objName, id});
    List<SObject> objs = Database.query(query);
    return objs.isEmpty() ? null : objs[0];
  }


}