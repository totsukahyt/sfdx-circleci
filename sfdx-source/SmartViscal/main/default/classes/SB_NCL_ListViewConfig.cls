/**
 *
 * SB_NCL_ListViewConfig
 *  基本 v2.0.1 SB_NC_ListViewConfig の療養
 *  リストビューの情報と項目の情報を保持するクラス
 *
 * Copyright (C) 2016 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2016.10.xx
 *  @Version 2      2017.06.xx Summer17 からの問題 LEXので ViewIDが Recent となってるときがある。 https://sbproj.backlog.jp/view/SV_DEV-476
 *  SB_NCL_ListViewConfig
 *  lx 2.0 2018.08.xx
 *
 **/
public with sharing class SB_NCL_ListViewConfig {

  // オブジェクトの ビューの情報を保持するクラス
  public class ListViewInfo {
    public String label;
    public Id value;    // ビューの Id
    public Boolean disabled;
    ListViewInfo(SelectOption opt) {
      this.value = opt.getValue();
      this.label = opt.getLabel();
      this.disabled = opt.getDisabled();
    }
  }

  // 項目の情報を保持するクラス
  public class FiledInfo {
    public String label { get; private set; }
    public String apiName { get; private set; }
    public Integer type { get; private set; } //  0: ID系 1:文字系 2:数値 3:通貨 4:日付 5:日時 6:論理値 9:処理不可
    public FiledInfo(Schema.SObjectField sof) {
      Schema.DescribeFieldResult dfr = sof.getDescribe();
      this.label = dfr.getLabel();
      this.apiName = dfr.getName();
      this.type = DISPLAYTYPE_TYPE.containsKey(dfr.getType()) ? DISPLAYTYPE_TYPE.get(dfr.getType()) : 9;
    }
    public FiledInfo(String label, String apiName, Integer type) {
      this.label = label;
      this.apiName = apiName;
      this.type = type;

    }
  }

  public List<ListViewInfo> views { get; private set; }   // リストビューの表示設定
  public String objectName { get; private set; }          // オブジェクト名
  public List<String> filedNames { get; private set; }    // オブジェクトの項目
  public Map<String, FiledInfo> col2Field { get; private set; }   // オブジェクトの項目（ビューの表示項目）の情報

  /**
   *
   * objectName : ビューを取得するオブジェクト
   * jointedFields :  クライアント側で表示する項目について、項目をしていする。その項目に関する情報を収集する。
   *
   **/
  public SB_NCL_ListViewConfig(String objectName, String jointedFields) {
    this.objectName = objectName;
    if (String.isNotBlank(jointedFields)) {
      this.filedNames = jointedFields.split('\\s*,\\s*');
    }
    //this.pageSize = pageSize;
    // ビューのリスト
    this.views = new List<ListViewInfo>();
    ApexPages.StandardSetController scon = createStandardSetController(objectName, 'Id, Name', null, true);
    for(SelectOption opt : scon.getListViewOptions()) {
      this.views.add(new ListViewInfo(opt));
    }
    if (this.filedNames != null) {
      // （ビューの表示項目が前提の項目）の情報を取得
      buildFieldInfo();
    }
  }

  // ビューのIDから 名称を得る。
  //2017.06.xx Summer17 からの問題 LEXので ViewIDが Recent となってるときがある。 https://sbproj.backlog.jp/view/SV_DEV-476
  public static String getViewLabel(String objectName, String viewId) {
    ApexPages.StandardSetController scon = createStandardSetController(objectName, 'Id, Name', null, true);
    for(SelectOption opt : scon.getListViewOptions()) {
      System.debug(opt);
      System.debug(opt.getValue());
      System.debug(opt.getLabel());
      if (opt.getValue() == viewId) {
        return opt.getLabel();
      }
    }
    return '';
  }

  // ビューの表示項目の情報を取得
  private void buildFieldInfo() {
    this.col2Field = new Map<String, FiledInfo>();
    Schema.DescribeSObjectResult dsr = SmartViscaf__NameCard__c.sObjectType.getDescribe();
    Map<String, Schema.SObjectField> fieldsmap = dsr.fields.getMap();
    for (String f : this.filedNames) {
      if (!fieldsmap.containsKey(f)) continue;
      col2Field.put(f, new FiledInfo(fieldsmap.get(f)));
    }
  }

  private static final String QUERY_VIEW_FORMAT = 'SELECT {0} FROM {1}{2} LIMIT 200';

  private static String createQueryString(String obj_name, String fields, String order, Boolean isAsc) {
    String[] ss = fields.split('\\s*,\\s*');
    Set<String> cols = new Set<String>(ss);
    cols.add('Id');
    String fs = '';
    for (String s : cols) {
      fs += s + ',';
    }
    fs = fs.removeEnd(',');
    String orderBy =String.isNotBlank(order) ?
                ' ORDER BY ' + getColName(obj_name, order) + (isAsc ? ' ASC NULLS FIRST' :' DESC NULLS LAST')
                : '';
    String query = String.format(QUERY_VIEW_FORMAT, new String[] {fs, obj_name, orderBy});
    return query;
  }

  private static String getColName(String obj_name, String col) {
    String col_name = null;
    Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    String oname = SB_NameCardL_Util.getManagedObjectName(obj_name);
    Schema.DescribeSObjectResult dsr = gd.get(oname).getDescribe();
    Map<String, Schema.SObjectField> fieldsmap = dsr.fields.getMap();
    List<String> fields = new List<String>();
    for (String key : fieldsmap.keySet()) {
      fields.add(key);
    }
    for (String c : fields) {
      if (c == col.toLowerCase()) {
        col_name = c;
      }
    }
    if (null == col_name) {
      col_name = 'Id';
    }
    return col_name;
  }

  /**
   *  StandardSetController を作るメソッド
   **/
  public static ApexPages.StandardSetController createStandardSetController(String obj_name, String fields, String order, Boolean isAsc) {
    String query = createQueryString(obj_name, fields, order, isAsc);
    System.debug(query);
    ApexPages.StandardSetController scon = new ApexPages.StandardSetController(Database.getQueryLocator(query));
    return scon;
  }

  /**
   *  指定されたオブジェクトのビューの一覧を返す。
   **/
  public static List<ListViewInfo> getListViewOptions(String obj_name, String fields) {
    List<ListViewInfo> result = new List<ListViewInfo>();
    ApexPages.StandardSetController scon = createStandardSetController(obj_name, fields, null, true);
    for(SelectOption opt : scon.getListViewOptions()) {
      result.add(new ListViewInfo(opt));
    }
    return result;
  }

  private static Map<Schema.DisplayType, Integer> DISPLAYTYPE_TYPE = new Map<Schema.DisplayType, Integer> {
    Schema.DisplayType.anytype => 9,
    Schema.DisplayType.base64 => 9,       //  Base64 で符号化された任意のバイナリデータ (型は base64Binary)
    Schema.DisplayType.Boolean => 6,      //  boolean の (true または false) の値
    Schema.DisplayType.Combobox => 1,       //
    Schema.DisplayType.Currency => 3,       //  通貨の値
    Schema.DisplayType.DataCategoryGroupReference => 1,       //  データカテゴリグループまたはカテゴリの一意名への参照。
    Schema.DisplayType.Date => 4,       //  日付の値
    Schema.DisplayType.DateTime => 5,       //  日時値
    Schema.DisplayType.Double => 2,       //  倍精度浮動小数点値
    Schema.DisplayType.Email => 1,      //  メールアドレス
    Schema.DisplayType.EncryptedString => 9,      //  暗号化された文字列
    Schema.DisplayType.ID => 0,       //  オブジェクトの主キー項目
    Schema.DisplayType.Integer => 2,      //  整数値
    Schema.DisplayType.MultiPicklist => 1,      //  複数の値を選択可能な列挙のセットを提供する複数選択の選択リスト
    Schema.DisplayType.Percent => 6,      //  パーセント値
    Schema.DisplayType.Phone => 1,      //
    Schema.DisplayType.Picklist => 1,       //
    Schema.DisplayType.Reference => 0,      //  外部キー項目に似ている、別のオブジェクトへの相互参照
    Schema.DisplayType.String => 1,       //  文字列の値
    Schema.DisplayType.TextArea => 1,       //  複数行のテキスト項目として表示される文字列値
    Schema.DisplayType.Time => 5,       //  時間の値
    Schema.DisplayType.URL => 1      //  ハイパーリンクとして表示される URL 値
  };

  //+---------- レコード取得用の クラス ----------+
  // 取得のリクエスト
  public virtual class FilteredQueryRequest {
    public String obj_name;
    public String fields;
    public String order;
    public Boolean isAsc;
    public String filterId;   // リストビューのID
    public Integer pageNo;
    public Integer pageSize;
    public FilteredQueryRequest() {
      order = 'Id';
      isAsc = true;
      pageNo = 0;
    }
    public void setDummy() {
      obj_name = 'SmartViscaf__NameCard__c';
      fields = 'Name,SmartViscaf__company_name__c,SmartViscaf__division__c,SmartViscaf__title_name__c';
      order = 'Id';
      isAsc = true;
      filterId = null;   // リストビューのI D
      pageNo = 0;
      pageSize = 20;
    }
  }

  // 取得のレスポンス
  public virtual class FilteredQueryResponse {
    public FilteredQueryRequest req;
    public List<SObject> records;
    public FilteredQueryResponse() {}
    public FilteredQueryResponse(FilteredQueryRequest req) {
      this.req = req;
    }
    public void run() {
      ApexPages.StandardSetController scon = createStandardSetController(req.obj_name, req.fields, req.order, req.isAsc);
      scon.setPageSize(req.pageSize);
      scon.setpageNumber(req.pageNo);
      scon.setFilterId(req.filterId);
      records = scon.getRecords();
    }
  }

}