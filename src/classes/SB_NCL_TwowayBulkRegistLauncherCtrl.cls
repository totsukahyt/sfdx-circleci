public with sharing class SB_NCL_TwowayBulkRegistLauncherCtrl {
  public class SB_NCL_TwowayBulkRegistLauncherCtrlException extends Exception {}

  public String targetIds { get; private set; }          // 対象のレコードID 名刺とか 取引先とか、取引先責任者とか、ロードとか
  public List<SObject> targets { get; private set; }
  public String retUrl { get; private set; }     // Lightning Componet 名
  public String component { get; private set; }     // Lightning Componet 名
  // 管理パッケージの名前空間名を
  public String namespace_x { get; private set; }
  public String viewId { get; private set; }   // 選択したビューのId
  public String viewLabel { get; private set; } // 選択したビューの名称
  public String fromLabel { get; private set; } // 選択したビューの名称
  public String fromId { get; private set; } // 選択したビューの名称
  public String urlRoot { get; private set; }

  private static final String QUERY_VIEW_FORMAT = 'SELECT {0} FROM {1}{2} LIMIT 200';

  //  コンストラクタ
  //    LEXで URLで起動させるため、IDを受ける用にVFの中にコンポーネントを展開するので、
  public SB_NCL_TwowayBulkRegistLauncherCtrl(ApexPages.StandardSetController controller) {
    try {
      PageReference page = ApexPages.currentPage();
      Map<String, String> paras = page.getParameters();
      List<ApexClass> classes = [SELECT Name, NamespacePrefix FROM ApexClass WHERE Name IN ('SB_NameCard_LeadBulkRegistController', 'SB_NameCard_LeadNameCardListController', 'SB_NameCard_LeadRegistController') OR NamespacePrefix='SmartViscal'];
      String namesp = '';
      if (!classes.isEmpty()) {
        namesp = classes[0].NamespacePrefix;
      }
      this.namespace_x = String.isNotBlank(namesp) ?
            namesp : 'c';
      this.namespace_x += ':';
      this.targets = controller.getSelected();
      this.targetIds = '';
      List<String> targetIdList = new List<String>();
      for (SObject obj : controller.getSelected()) {
        targetIdList.add(obj.Id);
      }
      this.targetIds = String.join(targetIdList, ',');
      this.retUrl = (Id)paras.get('retUrl');
      String app = (String)paras.get('app');
      this.component = 'SB_NCL_TwowayBulkRegist';
      this.retUrl = System.currentPageReference().getParameters().get('vfRetURLInSFX');
      this.viewLabel = getViewLabel('SmartViscaf__NameCard__c', getViewidFromUrl(this.retUrl, true));
      this.viewId = this.retUrl;
      this.fromId = 'one/one.app#/sObject/SmartViscaf__NameCard__c/list?filterName=Recent';
      this.fromLabel = SmartViscaf__NameCard__c.SObjectType.getDescribe().getLabel();
      String referer = page.getHeaders().get('Referer');
      this.urlRoot = getUrlRoot(referer);
      if (this.component == null && app.startsWithIgnoreCase('SB_NC_')) {
        this.component = app;     // SB_NC_ で始まってたら Lightningコンポーネントだと判断しちゃう。
      }
      else if (this.component == null) {
        throw new SB_NCL_TwowayBulkRegistLauncherCtrlException('Invalid URL Parameter.');
      }
    }
    catch (Exception e) {
      ApexPages.addMessages(e);
    }
  }

  private String getUrlRoot(String url) {
    String result = '';
    if (String.isNotBlank(url) && url.startsWithIgnoreCase('https://')) {
      // LEXのときだけ。LEX だとプロトコルからあるので、
      String[] ss = url.substringAfter('https://').split('/');
      result = 'https://' + (ss.size() > 0 ? ss[0] : '');   // 念のため
    }
    return result;
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


  /**
   *  StandardSetController を作るメソッド
   **/
  public static ApexPages.StandardSetController createStandardSetController(String obj_name, String fields, String order, Boolean isAsc) {
    String query = createQueryString(obj_name, fields, order, isAsc);
    System.debug(query);
    ApexPages.StandardSetController scon = new ApexPages.StandardSetController(Database.getQueryLocator(query));
    return scon;
  }

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

  private static final Set<String> SV_OBJECT_NAMES = new Set<String> {
    'namecard__c',
    'namecardhistory__c',
    'namecardrenkeimapping__c',
    'jinjiido__c',
    'jinjiidoemail__c',
    'namecardhistory__c'
  };

  public static String getManagedObjectName(String oName) {
    String result = oName;
    if (SV_OBJECT_NAMES.contains(oName.toLowerCase())) {
      String ns = SmartViscaf.SB_NameCard_Util.getNamespacePrefix_x();
      result = ns + oName;
    }
    return result;
  }

  private static String getColName(String obj_name, String col) {
    String col_name = null;
    Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    String oname = getManagedObjectName(obj_name);
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
}