/**
 *
 * Salesforce1対応 SmartVisca の挙動を決める 諸設定を保持するクラス
 *
 * Copyright (C) 2014-2020 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2014.05.xx
 *  @Version 2      2016.04.xx  SB_NameCard_SController から分離
 *  @Version 3      2017.06.xx  SmartVisca基本設定の参照
 *  @Version 4      2017.07.xx  Salesforce1 の判別
 *  @Version 5      2018.03.xx  v1.22 SV_DEV-582 『「上書きする」チェックボックスを表示する』機能について取引先・取責を分けて制御できるようにしたい
 *  @Version 6      v2.0.2 2018.08.xx ObjectLabels LeadLabels に email, CampaignLabels に status を追加
 *  @Version 7      v2.0.3 2018.09.xx バージョン番号 追加
 *  @Version 7      v2.0.3 2018.09.xx バージョン番号 追加
 *  @Version 2.1    2019.01.xx SV_DEV-862 S1での取引先登録の既存上書き設定をSmartVisca基本設定の項目から設定したい。
 *  @Version 2.0.4  2019.02.xx オブジェクト名の複数系も返す
 *  @Version 2.4    2019.08.xx    2019.08.xx 取引先登録のときの検索方法をクライアントに渡す 0:CorpMatch 1:PartialMatch 2:ExactMatch
 *                                    ↑ SV_DEV-1647 法人格の正式名称と略称をマッチさせる（登録・自動連携）からの派生
 *                                    重要な更新『カスタム設定に対する直接の「参照」アクセスには「アプリケーションのカスタマイズ」権限が必要です。』対策 で with sharing  をつけます
 *  @Version 2.5    2020.01.XX SV_DEV-2367 Classic /LEX 各登録画面（ 個別・一括） : Todo件名がNULL値の場合での件名の表示・登録結果が異なる
 *  @Version 2.6    2020.09.xx lx 2.1 用に リード登録時のToDo登録の ToDo作成初期値、件名、はリード用の値にします。 global プロパティの追加があるので、パッチでできません。
 **/
global with sharing class SB_NameCard_S1Config {

  private static Integer CONFIG_VERSION = 7;

  global static SB_NameCard_S1Config config {
    get {
      if (config == null) {
        config = new SB_NameCard_S1Config();
      }
      return config;
    }
    set;
  }

  private final static String namespace = SB_NameCard_Util.getNamespacePrefix();

  public Integer configVersion { get; private set; }
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
  public Map<String, String> sSmartViscaServerOptions { get; private set; }     // SmartViscaサーバへのレゴリスAPIへの追加のオプション、
  public String sUserLocale { get; private set; }       // 2015.10.1x ユーザのローケール設定
  public String sUserLanguage { get; private set; }       // 2016.07.xx ユーザの言語設定
  public Boolean enableAccountRegist { get; private set; }    // 2016.10.xx カスタム設定の取引先登録を使える + 名刺更新権 + アカウント参照権 + コンタクト参照権
  public Boolean enableAccountCreate { get; private set; }    // 2016.10.xx 取引先オブジェクトの作成権がある
  public Boolean enableContactCreate { get; private set; }    // 2016.10.xx 取引先責任者オブジェクトの作成権がある
  public Boolean enableLeadCreate { get; private set; }    // v2.0.2 2018.08.xx リードオブジェクトの作成権がある
  public Boolean enableAccountEdit { get; private set; }    // 2016.10.xx 取引先オブジェクトの編集権がある
  public Boolean enableContactEdit { get; private set; }    // 2016.10.xx 取引先責任者オブジェクトの編集権がある
  public Boolean enableLeadEdit { get; private set; }    // v2.0.2 2018.08.xx リードオブジェクトの編集権がある
  public String accountLabel { get; private set; }    // 2016.05.xx 取引先のラベル
  public String contactLabel { get; private set; }    // 2016.05.xx 取引先責任者のラベル
  public String leadLabel { get; private set; }    // 2018.08.xx リードのラベル v2.0.2
  public String namecardLabel { get; private set; }    // 2016.11.xx 名刺のラベル
  public String namecardPrefix { get; private set; }    // 2016.11.xx 名刺の　プレフィクス 3桁の識別子
  public Boolean sOverwriteAccount { get; private set; } // 2016.06.xx 取引先情報を名刺情報で上書きする
  public Boolean sOverwriteContact { get; private set; } // 2016.06.xx 取引先責任者情報を名刺情報で上書きする
  global Boolean enableActivity { get; private set; }    // 2016.07.3x 名刺の活動が許可されているか
  global Boolean createTodo { get; private set; }     // 2016.11.xx 取引先・取引先任者に登録 ToDo登録しない
  global String todoSubject { get; private set; }     // 2016.11.xx 取引先・取引先任者に登録 ToDo件名
  global Boolean createTodoLead { get; private set; }     // 2020.09.xx lx2.1 向け PRODUCT-782 LEX 統合版登録 個別：リード登録時にTodo件名が取引先責任者の「ToDo件名」の初期値が参照されている
  global String todoSubjectLead { get; private set; }     // 2020.09.xx lx2.1 向け PRODUCT-782 LEX 統合版登録 個別：リード登録時にTodo件名が取引先責任者の「ToDo件名」の初期値が参照されている
  global String todoLabel { get; private set; }       // 2016.11.xx 取引先・取引先任者に登録 ToDo ラベル
  global String todoLabelSubject { get; private set; }      // 2016.11.xx 取引先・取引先任者に登録 ToDo ラベル
  global String todoLabelActivityDate { get; private set; } // 2016.11.xx 取引先・取引先任者に登録 ToDo ラベル
  global String todoLabelDescription { get; private set; }  // 2016.11.xx 取引先・取引先任者に登録 ToDo ラベル
  global String todoLabelCreate { get; private set; }       // 2016.11.xx 取引先・取引先任者に登録 ToDo ラベル
  public Boolean accountNotOverWrite { get; private set; }  // 2017.01.xx 取引先・取引先任者に登録 取引先を名刺情報で上書きしない
  public Boolean contactNotOverWrite { get; private set; }  // 2017.01.xx 取引先・取引先任者に登録 取引先責任者を名刺情報で上書きしない
  public Boolean leadNotOverWrite { get; private set; }     // 2018.03.xx 取引先登録:リードを名刺情報で上書きしない
  //public Boolean registDispOverWriteCheckbox { get; private set; }  // 2017.06.xx「上書きする」チェックボックスを表示する
  public Boolean registDispAccountOverWriteCheckbox { get; private set; }   // 2018.03.xx  v1.22 SV_DEV-582 『「上書きする」チェックボックスを表示する』機能について取引先・取責を分けて制御できるようにしたい
  public Boolean registDispContactOverWriteCheckbox { get; private set; }   // 2018.03.xx  v1.22 SV_DEV-582 『「上書きする」チェックボックスを表示する』機能について取引先・取責を分けて制御できるようにしたい
  public Boolean registDispLeadOverWriteCheckbox { get; private set; }      // 2018.03.xx  取引先登録:「既存のリードを名刺情報で上書きする」を表示する
  public Boolean registDispAccountRectype { get; private set; }  // 2017.06.xx 取引先・取引先任者に登録 取引先レコードタイプ表示
  public Boolean registDispContactRectype { get; private set; }  // 2017.06.xx 取引先・取引先任者に登録 取引先責任者レコードタイプ表示
  public Boolean registDispLeadRectype { get; private set; }     // 2018.03.xx 取引先登録:リードレコードタイプ選択を表示する
  public Boolean scanSelectCampaign { get; private set; } // 2018.04.xx v2.0 スキャン:キャンペーン選択を有効化
  public Boolean s1  { get; private set; }  // Salesforce1 で動いている
  public Boolean leadRegistDefaultShowLeadListNoExsiting { get; private set; } // v2.0.2 LeadEx 2.0 対応 リードまたは取引先に登録の際、ともに既存がない場合、リードのリストを表示
  public RegistQuerySetting registQuerySetting { get; private set; }  // v2.4 取引先登録のときの検索設定
  public class User {   // 2017.01.xx
    public Id id { get; private set; }
    public String name { get; private set; }
    public String username { get; private set; }
    User() {
      this.id = UserInfo.getUserId();
      this.name = UserInfo.getName();
      this.username = UserInfo.getUserName();
    }
  }
  User user { get; private set; } // 2017.01.xx

  //private abstract LabelsAbstract  {
  //  Map<String, Schema.SObjectField> fields;
  //  public String objName { get; protected set; }
  //  public String name { get; protected set; }
  //  LabelsAbstract(SObjectType otype) {
  //    DescribeSObjectResult dsr = otype.getDescribe();
  //    this.objName = dsr.getLabel();
  //    this.fields = dsr.fields.getMap();
  //  }
  //  protected String getFieldLabel(String f) {
  //    return this.fields(f).getDescribe().getLabel();
  //  }
  //}

  // v2.4 取引先登録のときの検索設定
  // クライアントで持つ型に合わせて渡す
  public class RegistQuerySetting {
    public Boolean bulkRegist { get; private set; }  // ダミー
    public Integer queryType { get; private set; }  // 取引先の検索条件項目
    public Integer queryOrgType { get; private set; }  // v2.4 取引先登録のときの検索方法 0:CorpMatch 1:PartialMatch 2:ExactMatch
    public Boolean querySite { get; private set; }
    public Boolean queryState { get; private set; }
    public Boolean queryCity { get; private set; }
    public Boolean queryZip { get; private set; }
    public List<String> acntRecTypeIds  { get; private set; }
    public List<String> contRecTypeIds  { get; private set; }
    public RegistQuerySetting() {
      NameCardBasicSetting__c setting = SB_NameCard_BasicSetting.getNameCardBasicSetting(); // 2017.06.xx カスタム設定読み込みの一部を基本設定読み込みに変更
      this.bulkRegist = false;
      this.queryType = 0;     // 取引先の検索条件項目
      this.queryOrgType = setting.RenkeiExcludeHojinkaku__c ? 0 : (setting.RenkeiExcludeHojinkakuPartial__c ? 1 : 2); // v2.4 取引先登録のときの検索方法 0:CorpMatch 1:PartialMatch 2:ExactMatch
      this.querySite = false;
      this.queryState = false;
      this.queryCity = false;
      this.queryZip = false;
      this.acntRecTypeIds = new List<String>();
      this.contRecTypeIds = new List<String>();
    }
  }

  // v1.21 2017.11.xx
  public class NameCardLabels { // 名刺オブジェクトの項目ラベル
    public String objName { get; private set; }   // 名刺 オブジェクト
    public String name { get; private set; }   // 名刺 オブジェクト
    public String company { get; private set; }   // 会社名
    public String division { get; private set; }  // 所属
    public String title { get; private set; } //役職
    public String prefecture { get; private set; } // 都道府県
    public String address { get; private set; } // 住所
    public String building { get; private set; } // 建物名
    public String tel1 { get; private set; }  // 電話番号
    public String fax1 { get; private set; }  //    FAX番号
    public String mobile { get; private set; }  // 携帯電話
    public String email { get; private set; }   // メールアドレス
    public String owner { get; private set; }   // 所有者
    NameCardLabels() {
      this.objName = NameCard__c.sObjectType.getDescribe().getLabel();
      Map<String, Schema.SObjectField> fields = NameCard__c.sObjectType.getDescribe().fields.getMap();
      this.name = fields.get('Name').getDescribe().getLabel();   // 会社名
      String ns = SB_NameCard_Util.getNamespacePrefix_x();
      this.company = fields.get(ns + 'company_name__c').getDescribe().getLabel();   // 会社名
      this.division = fields.get(ns + 'division__c').getDescribe().getLabel(); // 所属
      this.title = fields.get(ns + 'title_name__c').getDescribe().getLabel(); //役職
      this.prefecture = fields.get(ns + 'address_pref__c').getDescribe().getLabel(); // 都道府県
      this.address = fields.get(ns + 'address__c').getDescribe().getLabel(); // 住所
      this.building = fields.get(ns + 'address_bld__c').getDescribe().getLabel(); // 建物名
      this.tel1 = fields.get(ns + 'tel1__c').getDescribe().getLabel(); // 電話番号
      this.fax1 = fields.get(ns + 'fax1__c').getDescribe().getLabel(); //    FAX番号
      this.mobile = fields.get(ns + 'mobile__c').getDescribe().getLabel();   // 携帯電話
      this.email = fields.get(ns + 'email__c').getDescribe().getLabel();    // メールアドレス
      this.owner = Label.SB_NC_Owner; // 所有者
    }
  }
  public class AccountLabels {
    String objName { get; private set; }
    String objNamePlural { get; private set; }
    String name { get; private set; }
    String site { get; private set; }
    String state { get; private set; }
    String city { get; private set; }
    String zipcode { get; private set; }
    String parent { get; private set; } // v2.4
    AccountLabels() {
      DescribeSObjectResult dsr = Account.sObjectType.getDescribe();
      this.objName = dsr.getLabel();    // v1.21改造 after 2016.11.xx 取引先・取引先任者に登録 ToDo ラベル
      this.objNamePlural = dsr.getLabelPlural();
      Map<String, Schema.SObjectField> fields = dsr.fields.getMap();
      this.name = fields.get('Name').getDescribe().getLabel();   //
      this.site = fields.get('Site').getDescribe().getLabel().removeStart(dsr.getLabel()).trim();   // '取引先 部門' => '部門'
      this.state = fields.get('BillingState').getDescribe().getLabel().replace('(請求先)', '').replace('Billing ', '');   // v2.0.2 ToDo ラベル化
      this.city = fields.get('BillingCity').getDescribe().getLabel().replace('(請求先)', '').replace('Billing ', '');   // v2.0.2
      this.zipcode = fields.get('BillingPostalCode').getDescribe().getLabel().replace('(請求先)', '').replace('Billing ', '');   // v2.0.2
      this.parent = fields.get('ParentId').getDescribe().getLabel();   // v2.4 親取引先
    }
  }
  public class ContactLabels {
    String objName { get; private set; }
    String objNamePlural { get; private set; }
    String name { get; private set; }
    String title { get; private set; }
    String email { get; private set; }
    ContactLabels() {
      DescribeSObjectResult dsr = Contact.sObjectType.getDescribe();
      this.objName = dsr.getLabel();    // v1.21改造 after 2016.11.xx 取引先・取引先任者に登録 ToDo ラベル
      this.objNamePlural = dsr.getLabelPlural();
      Map<String, Schema.SObjectField> fields = dsr.fields.getMap();
      this.name = fields.get('Name').getDescribe().getLabel();   //
      this.title = fields.get('Title').getDescribe().getLabel();   //
      this.email = fields.get('Email').getDescribe().getLabel();   //
    }
  }
  public class LeadLabels {
    String objName { get; private set; }
    String objNamePlural { get; private set; }
    String name { get; private set; }
    String email { get; private set; }    // v2.0.2
    LeadLabels() {
      DescribeSObjectResult dsr = Lead.sObjectType.getDescribe();
      this.objName = dsr.getLabel();    // v1.21改造 after 2016.11.xx 取引先・取引先任者に登録 ToDo ラベル
      this.objNamePlural = dsr.getLabelPlural();
      Map<String, Schema.SObjectField> fields = dsr.fields.getMap();
      this.name = fields.get('Name').getDescribe().getLabel();   //
      this.email = fields.get('Email').getDescribe().getLabel();   // v2.0.2
    }
  }

  public class CampaignLabels {
    String objName { get; private set; }
    String objNamePlural { get; private set; }
    String name { get; private set; }
    String status { get; private set; } // v2.0.2
    String statusLabel { get; private set; } // v2.0.2
    CampaignLabels() {
      SObjectType otype = Schema.getGlobalDescribe().get('Campaign');
      if (otype != null) {
        DescribeSObjectResult dsr = otype .getDescribe();
        this.objName = dsr.getLabel();    // v1.21改造 after 2016.11.xx 取引先・取引先任者に登録 ToDo ラベル
        this.objNamePlural = dsr.getLabelPlural();
        Map<String, Schema.SObjectField> fields = dsr.fields.getMap();
        this.name = fields.get('Name').getDescribe().getLabel();   //
        this.status = fields.get('Status').getDescribe().getLabel();   // v2.0.2
        this.statusLabel = String.format('{0}の{1}', new String[] { this.name, this.status });
      }
    }
  }

  public class CampaignMemberLabels {  // v2.0.2
    String objName { get; private set; }
    String objNamePlural { get; private set; }
    String name { get; private set; }
    String status { get; private set; }
    String statusLabel { get; private set; }
    CampaignMemberLabels() {
      SObjectType otype = Schema.getGlobalDescribe().get('CampaignMember');
      if (otype != null) {
        DescribeSObjectResult dsr = otype .getDescribe();
        this.objName = dsr.getLabel();
        this.objNamePlural = dsr.getLabelPlural();
        Map<String, Schema.SObjectField> fields = dsr.fields.getMap();
        this.name = fields.get('Name').getDescribe().getLabel();   //
        this.status = fields.get('Status').getDescribe().getLabel();
        this.statusLabel = String.format('{0} - {1}', new String[] { this.objName, this.status }); // 2.0.3  name から objName
      }
    }
  }


  public class TodoLabels {
    String objName { get; private set; }
    String objNamePlural { get; private set; }
    String subject { get; private set; }
    String activityDate { get; private set; }
    String description { get; private set; }
    String createTodo { get; private set; }
    TodoLabels() {
      DescribeSObjectResult dsr = Task.sObjectType.getDescribe();
      this.objName = dsr.getLabel();    // v1.21改造 after 2016.11.xx 取引先・取引先任者に登録 ToDo ラベル
      this.objNamePlural = dsr.getLabelPlural();
      Map<String, Schema.SObjectField> fields = dsr.fields.getMap();
      this.subject = Label.SB_NC_Subject;  //v1.21改造 after  fields.get('Subject').getDescribe().getLabel();    // 2016.11.xx 取引先・取引先任者に登録 ToDo ラベル
      this.activityDate = Label.SB_NC_DueDate; // v1.21改造 after  fields.get('ActivityDate').getDescribe().getLabel();    // 2016.11.xx 取引先・取引先任者に登録 ToDo ラベル
      this.description = Label.SB_NC_Comment;  // v1.21改造 after  fields.get('Description').getDescribe().getLabel();    // 2016.11.xx 取引先・取引先任者に登録 ToDo ラベル
      this.createTodo = Label.SB_NC_AddTodo;  // v1.21改造  2016.11.xx
    }
  }
  public class ObjectLabels {
    public NameCardLabels namecard { get; private set; }
    public TodoLabels todo { get; private set; }
    public AccountLabels account { get; private set; }
    public ContactLabels contact { get; private set; }
    public LeadLabels lead { get; private set; }
    public CampaignLabels campaign { get; private set; }
    public CampaignMemberLabels campaignMember { get; private set; }
    public String accountRegistTo { get; private set; } // 企業/企業担当者(部署/メール)  | Account (Department) & Contact (Department/Mail)
    public String leadRegistTo { get; private set; } // 	リード | Lead
    ObjectLabels() {
      this.namecard = new NameCardLabels();
      this.todo = new TodoLabels();
      this.account = new AccountLabels();
      this.contact = new ContactLabels();
      this.lead = new LeadLabels();
      this.campaign = new CampaignLabels();
      this.campaignMember = new CampaignMemberLabels(); // v2.0.2
      this.accountRegistTo = getAccountRegistTo();
      this.leadRegistTo = Schema.Lead.sObjectType.getDescribe().getLabel();
      //this.lead = Lead.sObjectType.getDescribe().getLabel();
      //this.campaign = Campaign.sObjectType.getDescribe().getLabel();
    }
    private String getAccountRegistTo() {
      List<String> labels = new List<String>();
      labels.addAll(getRegistToLabels(Schema.Account.sObjectType, new List<String> {'Site'}));
      labels.addAll(getRegistToLabels(Schema.Contact.sObjectType, new List<String> {'Department', 'Email'}));
      return String.format('{0}({1})/{2}({3}/{4})', labels);  // フォーマットをカスタム表示ラベルにするほうがいいけど
    }
    private List<String> getRegistToLabels(SObjectType otype, List<String> fields) {
      List<String> result = new List<String>();
      DescribeSObjectResult dsr = otype.getDescribe();
      Map<String, Schema.SObjectField> sof = dsr.fields.getMap();
      result.add(dsr.getLabel());
      for (String f : fields) {
        String fLabel = sof.get(f).getDescribe().getLabel();
        if (f=='Site') {
          fLabel = fLabel.removeStart(dsr.getLabel()).trim();
        }
        result.add(fLabel);
      }
      return result;
    }
  }
  public ObjectLabels labels { get; private set; }

  public SB_NameCard_S1Config() {
    this.configVersion = CONFIG_VERSION;
    this.s1 = (UserInfo.getUiThemeDisplayed() == 'Theme4t');     // Salesforce1 ?
    NameCardBasicSetting__c setting = SB_NameCard_BasicSetting.getNameCardBasicSetting(); // 2017.06.xx カスタム設定読み込みの一部を基本設定読み込みに変更
    // ユーザID
    this.userid = UserInfo.getUserId();
    // ユーザ名
    this.userName = UserInfo.getUserName();
    // デモ用か判定
    Set<String> demoOrgIds = new Set<String>(Label.SB_NC_DemoOrgs.toUpperCase().split('[,\\s]'));
    this.demoOrg = (demoOrgIds.contains(UserInfo.getOrganizationId().toUpperCase().substring(0, 15)) == true);
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
    this.enableNameCardTag = isEnableNameCardTagPersonal();
    // Chatterが有効
    this.enableChatter = isEnableFeedItem();
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
      // 2016.10.xx カスタム設定の取引先登録を使える + 名刺更新権 + アカウント参照権 + コンタクト参照権
      // 2017.07.xx v1.20.1 以降 S1だけカスタム設定
    this.enableAccountRegist = (!this.s1 || SB_NameCard_Util.smartViscaConfig.SUseAccountRegist__c)
              && getEnableEdit(NameCard__c.sObjectType) && getEnableAccess(Account.sObjectType) && getEnableAccess(Contact.sObjectType);
    this.enableAccountCreate = getEnableCreate(Account.sObjectType);      // 作成権限がある
    this.enableContactCreate = getEnableCreate(Contact.sObjectType);      //
    this.enableLeadCreate = getEnableCreate(Lead.sObjectType);      // v2.0.2
    this.enableAccountEdit = getEnableEdit(Account.sObjectType);      // 編集権限がある
    this.enableContactEdit = getEnableEdit(Contact.sObjectType);      //
    this.enableLeadEdit = getEnableEdit(Lead.sObjectType);      //v2.0.2
    this.accountLabel = Account.getSObjectType().getDescribe().getLabel();
    this.contactLabel = Contact.getSObjectType().getDescribe().getLabel();
    this.leadLabel = Lead.getSObjectType().getDescribe().getLabel();
    this.namecardLabel = NameCard__c.getSObjectType().getDescribe().getLabel();
    this.namecardPrefix = NameCard__c.getSObjectType().getDescribe().getKeyPrefix();
    this.sOverwriteAccount = !setting.RegistAccountNotOverWrite__c; // アカウント情報の上書き 2019.01.xx SV_DEV-862 S1での取引先登録の既存上書き設定をSmartVisca基本設定の項目から設定したい。
    this.sOverwriteContact = !setting.RegistContactNotOverWrite__c; // コンタクト情報の上書き 2019.01.xx SV_DEV-862 S1での取引先登録の既存上書き設定をSmartVisca基本設定の項目から設定したい。
    this.enableActivity = isEnableActivity();   // 2016.07.2x
    //this.createTodo =  !SB_NameCard_Util.smartViscaConfig.ToDo__c;   // 2016.11.xx 取引先・取引先任者に登録 ToDo登録しない
    this.createTodo = !setting.RegistNoToDo__c;        // 2017.06.xx
    //this.todoSubject = String.isNotBlank(SB_NameCard_Util.smartViscaConfig.ToDoName__c) ?
    //                        SB_NameCard_Util.smartViscaConfig.ToDoName__c : Label.SB_NC_ExchangeCard;   // 2016.11.xx 取引先・取引先任者に登録 ToDo件名
    //SV_DEV-2367 基本設定で値が未設定ならカスタムラベルの値を読む
    this.todoSubject = String.isBlank(setting.RegistToDoSubject__c) ? System.Label.SB_NC_ExchangeCard : setting.RegistToDoSubject__c;
    // 2020.09.xx lx2.1 向け PRODUCT-782 LEX 統合版登録 個別：リード登録時にTodo件名が取引先責任者の「ToDo件名」の初期値が参照されている
    this.createTodoLead = !setting.RegistLeadNoToDo__c;
    this.todoSubjectLead = String.isBlank(setting.RegistLeadToDoSubject__c) ? System.Label.SB_NC_ExchangeCard : setting.RegistLeadToDoSubject__c;
    DescribeSObjectResult dsr = Task.sObjectType.getDescribe();
    Map<String, Schema.SObjectField> fields = dsr.fields.getMap();
    this.todoLabel = dsr.getLabel();    // 2016.11.xx 取引先・取引先任者に登録 ToDo ラベル
    this.todoLabelSubject = Label.SB_NC_Subject;  //fields.get('Subject').getDescribe().getLabel();    // 2016.11.xx 取引先・取引先任者に登録 ToDo ラベル
    this.todoLabelActivityDate = Label.SB_NC_DueDate; //fields.get('ActivityDate').getDescribe().getLabel();    // 2016.11.xx 取引先・取引先任者に登録 ToDo ラベル
    this.todoLabelDescription = Label.SB_NC_Comment;  //fields.get('Description').getDescribe().getLabel();    // 2016.11.xx 取引先・取引先任者に登録 ToDo ラベル
    this.todoLabelCreate = Label.SB_NC_AddTodo;  //fields.get('Description').getDescribe().getLabel();    // 2016.11.xx 取引先・取引先任者に登録 ToDo ラベル
    // 取引先・取引先任者に登録 取引先を名刺情報で上書きしない
    //this.accountNotOverWrite = SB_NameCard_Util.smartViscaConfig.AccountNotOverWrite__c;    // 2017.01.xx
    this.accountNotOverWrite = setting.RegistAccountNotOverWrite__c;      // 2017.06.xx
    // 取引先・取引先任者に登録 取引先責任者を名刺情報で上書きしない
    //this.contactNotOverWrite = SB_NameCard_Util.smartViscaConfig.ContactNotOverWrite__c;    // 2017.01.xx
    this.contactNotOverWrite = setting.RegistContactNotOverWrite__c;       // 2017.06.xx
    this.leadNotOverWrite = setting.RegistLeadNotOverWrite__c;   // 2018.03.xx 取引先登録:リードを名刺情報で上書きしない
    //this.registDispOverWriteCheckbox = setting.RegistDispOverWriteCheckbox__c;  // 2017.06.xx「上書きする」チェックボックスを表示する
    this.registDispAccountOverWriteCheckbox = setting.RegistDispAccountOverWriteCheckbox__c;  // 2018.03.xx  v1.22 SV_DEV-582 『「上書きする」チェックボックスを表示する』機能について取引先・取責を分けて制御できるようにしたい
    this.registDispContactOverWriteCheckbox = setting.RegistDispContactOverWriteCheckbox__c;  // 2018.03.xx  v1.22 SV_DEV-582 『「上書きする」チェックボックスを表示する』機能について取引先・取責を分けて制御できるようにしたい
    this.registDispLeadOverWriteCheckbox = setting.RegistDispLeadOverWriteCheckbox__c;  // 2018.03.xx  取引先登録:「既存のリードを名刺情報で上書きする」を表示する
    this.registDispAccountRectype = setting.RegistDispAccountRectype__c;  // 2017.06.xx 取引先・取引先任者に登録 取引先レコードタイプ表示
    this.registDispContactRectype = setting.RegistDispContactRectype__c;  // 2017.06.xx 取引先・取引先任者に登録 取引先責任者レコードタイプ表示
    this.registDispLeadRectype = setting.RegistDispLeadRectype__c;  // 2018.03.xx 取引先登録:リードレコードタイプ選択を表示する
    this.scanSelectCampaign = setting.ScanSelectCampaign__c;  // 2018.04.xx v2.0 スキャン:キャンペーン選択を有効化
    if (SB_NameCard_Util.isEnableLeadExt112()) {
      this.leadRegistDefaultShowLeadListNoExsiting = (Boolean)getLeadExCustumSettingsValue('LeadRegist_DefaultShowLeadListNoExsiting__c'); // v2.0.2 LeadEx 2.0 対応 リードまたは取引先に登録の際、ともに既存がない場合、リードのリストを表示
    }
    this.registQuerySetting = new RegistQuerySetting(); // v2.4 取引先登録のときの検索設定
    this.user = new User(); // 2017.01.xx
    this.labels = new ObjectLabels(); // 2017.11.xx v1.21
  }

  // 名刺の個人タグが使用可能
  private static Boolean isEnableNameCardTagPersonal() {
    Boolean enable =false;
    try {
      String prefix = String.isBlank(namespace) ? '' : namespace + '__';
      Schema.sObjectType targetType = Schema.getGlobalDescribe().get(prefix + 'NameCard__tag');
      Schema.SObjectField field = targetType.getDescribe().fields.getMap().get('Type');
      List<String> types = SB_NameCard_Util.getPickListEntry(field);
      for (String t : types) {
        if (t == 'Personal' || t == Label.SB_NC_ValPersonalTagType) {    //個人用
          enable = true;
          break;
        }
      }
    }
    catch(Exception e) {
      enable = false;
    }
    return enable;
  }

  // Chatterが有効になってるか？
  private static Boolean isEnableFeedItem() {
    Boolean enable = false;
    if (Test.isRunningTest() == false) {
      // 管理パッケージのインストール先組織では、getGlobalDescribe で FeedItem がとれてくるみたい。
      // かわりに便利なクラスが存在。しかし、テスト実行ではエラーになる。
      // System.UnsupportedOperationException: ConnectApi methods are not supported in data siloed tests. Please use @IsTest(SeeAllData=true).
      enable = ConnectApi.Organization.getSettings().features.chatter;
    }
    else {
      enable = false;
    }
    return enable;
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

  // ユーザがオブジェクトを参照できるか
  public static Boolean getEnableAccess(sObjectType otype) {
    DescribeSObjectResult dsr = otype.getDescribe();
    return dsr.isAccessible();
  }

  // ユーザがオブジェクトを参照、作成できるか
  public static Boolean getEnableCreate(sObjectType otype) {
    DescribeSObjectResult dsr = otype.getDescribe();
    return dsr.isAccessible() && dsr.isCreateable();
  }
  // ユーザがオブジェクトを参照、更新できるか
  public static Boolean getEnableEdit(sObjectType otype) {
    DescribeSObjectResult dsr = otype.getDescribe();
    return dsr.isAccessible() && dsr.isUpdateable();
  }

  // 名刺に活動が許可されているかの判定
  private static Boolean isEnableActivity() {
    try {
      Set<Schema.sObjectType> ots = new Set<Schema.sObjectType> (Event.WhatId.getDescribe().getReferenceTo());
      ots.addAll(Task.WhatId.getDescribe().getReferenceTo());
      return ots.contains(NameCard__c.sObjectType);
    }
    catch(Exception e) {
      return false;
    }
  }

  // リード拡張パッケージの追加のかステム設定の項目とそのデフォルト値
  private static final Map<String, Object> LEAD_EXTENSION_CUSTOMSETTINGS = new Map<String, Object> {
    'LeadRegist_DefaultShowLeadListNoExsiting__c' => true
  };

  private Object getLeadExCustumSettingsValue(String field) {
    String f = SB_NameCard_Util.getLeadExNamespacePrefix_x() + field;
    Object val = SB_NameCard_Util.smartViscaConfig.getPopulatedFieldsAsMap().get(f);
    if ( val == null) {
      val = LEAD_EXTENSION_CUSTOMSETTINGS.get(field);
    }
    return val;
  }
}