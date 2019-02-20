/*
 * (c) 2018 Sunbridge Inc.
 *
 * CLassic 統合一括登録 コントローラ
 * @author kou
 * @Version 拡張パッケージ：Lead Ex. 1.12 2018/8/XX
 *
 */

public with sharing class SB_NameCardL_TwowayBulkRegistController {
  public class LeadBulkRegistControllerException extends exception {}
  public String retUrl{get;set;}
  public Boolean useNameCardOwner{get;set;}
  public Boolean useNameCardContactOwner{get;set;}

  private static final String LD_LABEL = Lead.sObjectType.getDescribe().getLabel();
  //取引先オブジェクト表示ラベル
  public static final String AC_LABEL = Account.sObjectType.getDescribe().getLabel();
  //取引先責任者オブジェクト表示ラベル
  public static final String CO_LABEL = Contact.sObjectType.getDescribe().getLabel();

  private static final List<RecordTypeInfo> ACNT_RECORDTYPES;
  private static final List<RecordTypeInfo> CONT_RECORDTYPES;

  static {
    ACNT_RECORDTYPES = SB_NameCardL_Util.getRecordType(Account.sObjectType);
    CONT_RECORDTYPES = SB_NameCardL_Util.getRecordType(Contact.sObjectType);
  }

  // 新規作成のラベル
  private static final String createAccountLabel;
  private static final String createContactLabel;
  private static final String createLeadLabel;
  static {
    // ToDo カスタム表示ラベル
    createAccountLabel = String.format(System.Label.SB_NCLD_Label_CreateNewLeadDEV, new String[]{ AC_LABEL });
    createContactLabel = String.format(System.Label.SB_NCLD_Label_CreateNewLeadDEV, new String[]{ CO_LABEL });
    createLeadLabel = String.format(System.Label.SB_NCLD_Label_CreateNewLeadDEV, new String[]{ LD_LABEL });
  }

  private List<SmartViscaf__NameCard__c> nameCardList;
  private Set<Id> nameCardIdSet;
  public Boolean isFullCompanyNameForSearch { get; set; } // 商号あり会社名

  private SB_NameCardL_RegistQueryOption accountQueryOption;  // アカウント検索オプション
  private SB_NameCardL_RegistQueryOption contactQueryOption; // コンタクト検索オプション
  private SB_NameCardL_RegistQueryOption leadQueryOption;  // リード検索オプション
  private enum RegistType { AccountContact, AccountContactLead, Lead }
  private RegistType registObjs;


  //テスト addMessageキャッチよう
  @TestVisible
  private String testError;

  //列のDATA
    public class AccAndCon{
      public Boolean regist { get; set; }
      public Id accountId { get; set; }
      public Id contactId { get; set; }

      public AccAndCon(){
        this.regist = false;
      }

      public AccAndCon(Id accountId, Id contactId){
        this.regist = true;
        this.accountId = accountId;
        this.contactId = contactId;
      }
    }


  //private PageReference retUrl;

  public Integer searchType { get; set; }
  public Boolean leadOverwrite { get; set; }
  // public List<NameCardRecord> nameCardRecordList { get; set; }
  public SmartViscaf__NameCard__c campaignOption { get; set; }
  public Lead ownerlead { get; set; }
  public Account ownerAccount { get; set; }
  public Boolean hasError { get; set; }
  public Boolean leadCreateable {get;set;}
  public Boolean accountCreateable {get;set;}
  public Boolean contactCreateable {get;set;}

  private Map<Integer, String> soqlMap = new Map<Integer, String>();
  private List<Id> emailIdList = new List<Id>();
  private List<String> emailList = new List<String>();
  private List<Id> nameIdList = new List<Id>();
  private Set<String> nameSet = new Set<String>();
  private Set<String> lastNameSet = new Set<String>();
  private Set<String> firstNameSet = new Set<String>();
  private Map<Id, Id> leadOwnerIdMap = new Map<Id, Id>();

  public String overwriteLeadInfoLabel{get;set;}
  public String registerToLeadLabel{get;set;}
  public String specifiedWhenCreateNew{get;set;}
  public Boolean saveOK{get;set;}//保存状況
  public Boolean leadRecTypeEdit{get; private set;} //リードレコードタイプを変更できるflag
  public Boolean showLeadRecType{get;private set;} //リードレコードタイプ選択を表示フラグ
  public String leadRecType{get;set;}    //ラベルSB_NCLD_Label_LeadRecType リードレコードタイプ
  public String leadRecordTypeId{get;set;} //リードレコードタイプID
  //SV_DEV-175 リード登録時にキャンペーン内での状況を選択
  public String campStatus{get;set;} //キャンペーンStatus
  public Boolean campDisabled{get;set;} //キャンペーンStatus Disabled フラグ
  public Boolean campLookUpDisabled{get;set;} //キャンペーン Disabled フラグ
  public  List<SelectOption> campaignStatus {get; set;}


  public String  recordTypeExplain{get; private set;}
  public String  accountRecTypeId{get;set;}//選んだの取引先レコードタイプ
  public String  contactRecTypeId{get;set;}//選んだの取引先責任者レコードタイプ
  public String  accountRecType{get;set;}//取引先レコードタイプの表示ラベル
  public Boolean accountRecTypeEdit{get; private set;}//取引先レコードタイプ編集不可
  public Boolean contactRecTypeEdit{get; private set;}//取引先責任者レコードタイプ編集不可
  public String  contactRecType{get; private set;}//取引先責任者レコードタイプの表示ラベル
  public Boolean showAccountRecType{get; private set;}//取引先レコードタイプ表示するか
  public Boolean showContactRecType{get; private set;}//取引先責任者レコードタイプ表示するか
  public Boolean showRecTypeSectionItem{get; private set;}//レコードタイプのSectionItemを表示するか
  public Boolean canNotUpdataAccount{get; private set;}//取引先更新不可フラグ
  public Boolean canNotUpdataContact{get; private set;}//取引先責任者更新不可フラグ
  public Boolean canNotUpdataLead{get; private set;}//リード更新不可フラグ
  public String  canNotUseStyleAcc{get; private set;}//取引先上書き表示ラベルCSS
  public String  canNotusestylecon{get; private set;}//取引先責任者上書き表示ラベルCSS
  public Boolean showUpdate{get; private set;}//基本設定上書き表示
  public Boolean showUpdateAccount{get; private set;}//基本設定 既存の取引先を名刺情報で上書きする」を表示する
  public Boolean showUpdateContact{get; private set;}//「既存の取引先責任者を名刺情報で上書きする」を表示する
  public Boolean showUpdateLead{get; private set;}//「既存のリードを名刺情報で上書きする」を表示する
  public Boolean accountOverWrite { get; set; } // 取引先を上書き
  public Boolean contactOverWrite { get; set; } // 取引責任者を上書き
  public String  updateForContact{get; private set;}//既存の取引先の情報を名刺情報で上書きする
  public String  updateForAccount{get; private set;}//既存の取引先責任者の情報を名刺情報で上書きする
  public String  renkeiType{get; set;}//既存の取引先責任者の情報を名刺情報で上書きする
  public Integer searchTypeContact { get; set; }

  public String  leadOwnerLabel{get; set;}//既存の取引先責任者の情報を名刺情報で上書きする
  public String  accountOwnerLabel { get; set; }

  public Integer searchField { get; set; }  // 検索条件の項目
  public Integer queryMatch { get; set; }   // 完全一致もする？
  public Boolean firstSearch { get; set; }   // 初期クエリ

  @TestVisible private static final Integer SEARCHTYPE_DEFAULT = 0;    // 検索方法のデフォルト値
  @TestVisible private static final Integer FIELD_NAMESITE = 0;  // 検索条件の項目
  @TestVisible private static final Integer FIELD_NAME = 1;
  @TestVisible private static final Integer QUERY_PERFECT_NO = 0;  //
  @TestVisible private static final Integer QUERY_PERFECT = 1;   // 完全一致もする


  public List<SB_NameCardL_BulkRegistDTO.CustomObject> nameCardRecordListDTO { get; set; } // 名刺テーブル
  public Map<Id, Map<String, List<SelectOption>>> inputPlickListVMap { get; set; }





  @TestVisible
  private static SB_NameCardL_RegistCanPickerAbstract searchMethod = new SB_NameCardL_RegistSoqlCountCanPicker();

  public SmartViscaf__NameCardBasicSetting__c  baseSetting{
    get{
      if (baseSetting == null) {
        baseSetting = SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting();
      }
      return baseSetting;
    }
    set;
  }

  //すべてのレコードタイプを取得
  private static final List<RecordTypeInfo> leadRecordTypes = SB_NameCardL_Util.getRecordType(Lead.sObjectType);
  //すべてのレコードタイプを取得
  private static final List<RecordTypeInfo> accountRecordTypes = SB_NameCardL_Util.getRecordType(Account.sObjectType);
  //すべてのレコードタイプを取得
  private static final List<RecordTypeInfo> contactRecordTypes = SB_NameCardL_Util.getRecordType(Contact.sObjectType);


  public SB_NameCardL_TwowayBulkRegistController(ApexPages.StandardSetController controller)
  {
      PageReference page = ApexPages.currentPage();
      Map<String, String> paras = page.getParameters();
      Boolean bLex = false;
      if (paras.containsKey('vfRetURLInSFX')) {
        bLex = true;
        this.retUrl = paras.get('vfRetURLInSFX');
        //this.viewId = getViewidFromUrl(this.retUrl, bLex);
        //this.urlRoot = getUrlRoot(this.retUrl);     // LEX のときだけでいい
      }
      else if (paras.containsKey('retUrl')) {
        bLex = false;
        this.retUrl = paras.get('retUrl');
        //this.viewId = getViewidFromUrl(this.retUrl, bLex);
      }
      else {
          this.retUrl = '/home/home.jsp';
      }
      try {

          this.registObjs = RegistType.AccountContactLead;

          this.accountQueryOption = getQueryOption(Account.sObjecttype);
          this.contactQueryOption =  getQueryOption(Contact.sObjecttype);
          // if (this.registObjs == RegistType.AccountContactLead || this.registObjs == RegistType.Lead) {
            this.leadQueryOption =  getQueryOption(Lead.sObjecttype);
          // }

          if (SB_NameCard_LeadRegist.svConfig.defaultDisplayExistingLead()) {
            renkeiType = 'Lead';
          } else {
            renkeiType = 'Contact';
          }
          this.firstSearch = true;

          if (SB_NameCard_LeadRegist.svConfig.config.id == null) {
            this.searchTypeContact = SmartViscaf.SB_NameCard_Util.SEARCHTYPE_NAME_SITE;
          } else if (SB_NameCard_LeadRegist.svConfig.config.SmartViscaf__AccountSearchType__c == null) {
            this.searchTypeContact = SmartViscaf.SB_NameCard_Util.SEARCHTYPE_NAME_SITE;
          } else {
            this.searchTypeContact = SB_NameCard_LeadRegist.svConfig.config.SmartViscaf__AccountSearchType__c ? SmartViscaf.SB_NameCard_Util.SEARCHTYPE_NAME : SmartViscaf.SB_NameCard_Util.SEARCHTYPE_NAME_SITE;
          }
          //既存の取引先を名刺情報で上書きする」を表示する
          this.showUpdateAccount = baseSetting.SmartViscaf__RegistDispAccountOverWriteCheckbox__c;
          //既存の取引先責任者を名刺情報で上書きする」を表示する
          this.showUpdateContact = baseSetting.SmartViscaf__RegistDispContactOverWriteCheckbox__c;
          //既存のリードを名刺情報で上書きする」を表示する
          this.showUpdateLead = baseSetting.SmartViscaf__RegistDispLeadOverWriteCheckbox__c;

          this.showUpdate = this.showUpdateAccount || this.showUpdateContact;

          this.canNotUpdataAccount = !Account.sObjectType.getDescribe().isUpdateable();
          this.canNotUpdataContact = !Contact.sObjectType.getDescribe().isUpdateable();
          this.canNotUpdataLead = !Lead.sObjectType.getDescribe().isUpdateable();

          this.accountOverWrite = false;
          this.contactOverWrite = false;
          this.leadOverwrite = false;
          if (!canNotUpdataAccount) {
            if (baseSetting == null) {
              this.accountOverWrite = true;
            } else {
              this.accountOverWrite = !baseSetting.SmartViscaf__RegistAccountNotOverWrite__c;
            }
          }

          if (!canNotUpdataContact) {
            if (baseSetting == null) {
              this.contactOverWrite = true;
            } else {
              this.contactOverWrite = !baseSetting.SmartViscaf__RegistContactNotOverWrite__c;
            }
          }

          if (!canNotUpdataLead) {
            if (baseSetting == null) {
              this.leadOverwrite = true;
            } else {
              this.leadOverwrite = !baseSetting.SmartViscaf__RegistLeadNotOverWrite__c;
            }
          }


          //ラベル:既存の取引先の情報を名刺情報で上書きする
          this.updateForAccount = String.format(System.Label.SB_NCLD_Label_OverwriteLeadInfoDEV,new String[]{SB_NameCardL_TwowayBulkRegistController.AC_LABEL});
          //ラベル:既存の取引先責任者の情報を名刺情報で上書きする
          this.updateForContact =  String.format(System.Label.SB_NCLD_Label_OverwriteLeadInfoDEV,new String[]{SB_NameCardL_TwowayBulkRegistController.CO_LABEL});

          this.useNameCardOwner = false;
          this.useNameCardContactOwner = false;

          this.leadCreateable = Lead.sObjectType.getDescribe().isCreateable();
          this.accountCreateable = Account.sObjectType.getDescribe().isCreateable();
          this.contactCreateable = Contact.sObjectType.getDescribe().isCreateable();

          this.leadOwnerLabel = String.format(System.Label.SB_NCLD_Label_NameCardOwner, new String[]{LD_LABEL});
          this.accountOwnerLabel = String.format(System.Label.SB_NCLD_Label_NameCardOwner, new String[]{CO_LABEL});


          // --------------------- changelabel start ---------------------
          // this.registerToLeadLabel = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Text_RegisterToLeadsDEV);
          // this.registerToLeadLabel = String.format(System.Label.SB_NCLD_Text_RegisterToLeadsDEV, new String[] {LD_LABEL});
          this.registerToLeadLabel = System.Label.SB_NCLD_Text_RegisterToLead_OR_Account_Contact;
          // this.overwriteLeadInfoLabel = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Label_OverwriteLeadInfoDEV);
          this.overwriteLeadInfoLabel = String.format(System.Label.SB_NCLD_Label_OverwriteLeadInfoDEV, new String[] {LD_LABEL});
          // this.specifiedWhenCreateNew = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Text_SpecifiedWhenCreateNew);
          this.specifiedWhenCreateNew = String.format(System.Label.SB_NCLD_Text_SpecifiedWhenCreateNew, new String[] {LD_LABEL});

          // --------------------- changelabel end ---------------------
          // SV_DEV-747 リード拡張パッケージのカスタム設定：リードに登録 リードレコードタイプ表示の初期値がOFF
          this.showLeadRecType = leadRecordTypes.size() > 1 && baseSetting.SmartViscaf__RegistDispLeadRectype__c;

          this.showAccountRecType = accountRecordTypes.size() > 1 && baseSetting.SmartViscaf__RegistDispAccountRectype__c;
          this.showContactRecType = contactRecordTypes.size() > 1 && baseSetting.SmartViscaf__RegistDispContactRectype__c;

          this.leadRecTypeEdit = leadCreateable && leadRecordTypes.size() > 1;

          this.searchType = SB_NameCard_LeadRegist.SEARCHTYPE_EMAIL;

          List<SmartViscaf__NameCard__c> ncList = SB_NameCard_LeadRegist.getNameCardList(controller.getSelected());
          // this.nameCardRecordList = getNameCardRecordList(ncList, SB_NameCard_LeadRegist.svConfig.registTodo());

          this.nameCardRecordListDTO = getNameCardRecordListDTO(ncList, !baseSetting.SmartViscaf__RegistNoToDo__c);

          this.campaignOption = new SmartViscaf__NameCard__c(OwnerId=UserInfo.getUserId());
          this.ownerlead = new Lead();
          this.ownerAccount = new Account();
          this.hasError = false;

          this.campLookUpDisabled = !SmartViscaf__NameCard__c.campaign__c.getDescribe().isAccessible();

          this.campDisabled = true;

          //リードに関する設定
          setRecord();
          this.CampaignStatus = getCampaignS();

          SB_NameCard_LeadRegist.setEmailSoql(this.soqlMap, this.emailIdList, this.emailList, ncList);
          //SB_NameCard_LeadRegist.setNameSoql(this.soqlMap, this.nameIdList, this.nameSet, ncList);
          SB_NameCard_LeadRegist.setLastFirstNameSoql(this.soqlMap, this.nameIdList, this.nameSet,this.lastNameSet,this.firstNameSet,ncList);

            if (ncList != null && ncList.size() > 0) {
              Map<Id, SmartViscaf__NameCard__c> ncMap = new Map<Id, SmartViscaf__NameCard__c>([SELECT Id, SmartViscaf__company_name__c, SmartViscaf__division__c, SmartViscaf__title_name__c, Name, SmartViscaf__lead__c,
                SmartViscaf__zip_code__c, SmartViscaf__address_pref__c, SmartViscaf__address__c, SmartViscaf__address_bld__c, SmartViscaf__address_eng__c, SmartViscaf__mobile__c, SmartViscaf__email__c,
                SmartViscaf__account__c, SmartViscaf__contact__c, SmartViscaf__person_name_last__c, SmartViscaf__person_name_first__c, SmartViscaf__last_name__c, SmartViscaf__first_name__c, SmartViscaf__tel2__c,
                SmartViscaf__tel1__c, SmartViscaf__fax1__c, SmartViscaf__web_url1__c, SmartViscaf__list_name__c, SmartViscaf__memo__c, SmartViscaf__freehandmemo__c, SmartViscaf__card_exchange_date__c, OwnerId
                FROM SmartViscaf__NameCard__c WHERE Id IN :ncList]);
              this.nameCardIdSet = ncMap.keySet();
              this.nameCardList = ncMap.values();

            }

            if (this.nameCardList == null) {
              this.nameCardList = new List<SmartViscaf__NameCard__c>();
              this.nameCardIdSet = new Set<Id>();
            }
            System.debug('nameCardList.size: ' + this.nameCardList.size());

          this.search();
      } catch (Exception e) {
          testError = e.getMessage();
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, e.getMessage()));
          // ApexPages.addMessage(e.getStackTraceString());
      }
  }


  // 連携タイプ
  public static List<SelectOption> getRenkeiTypeList() {
    List<SelectOption> os = new List<SelectOption>();
    os.add(new SelectOption('Lead', LD_LABEL));
    os.add(new SelectOption('Contact', Account.sObjecttype.getDescribe().getLabel() + '・' + Contact.sObjecttype.getDescribe().getLabel()));
    os.add(new SelectOption('Both', System.Label.SB_NCLD_Label_Both_display));
    return os;
  }

  public void changeCampaign() {
      this.CampaignStatus = getCampaignS();
  }

  //SV_DEV-175 リード登録時にキャンペーン内での状況を選択
  public  List<SelectOption> getCampaignS(){
      List<SelectOption> options = new List<SelectOption>();
      List<CampaignMemberStatus> cpms = [SELECT id, CampaignID, HasResponded, IsDefault, Label, SortOrder
                                      FROM CampaignMemberStatus Where CampaignId = :campaignOption.campaign__c];
      for (CampaignMemberStatus f: cpms) {
          if (f.IsDefault == true) {
              campStatus = f.Label;
          }
          options.add(new SelectOption(f.Label, f.Label));
      }
      this.campDisabled = options.size() <= 0 || campLookUpDisabled;
      System.debug(campDisabled);
      return options;
  }

  //レコードタイプをに関する初期設定
  public void setRecord() {
      leadRecordTypeId = SB_NameCardL_Util.getDefaultRecordType(Lead.sObjectType);
      // leadRecType = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Label_LeadRecType);
      accountRecTypeId = SB_NameCardL_Util.getDefaultRecordType(Account.sObjectType);
      contactRecTypeId = SB_NameCardL_Util.getDefaultRecordType(Contact.sObjectType);
      leadRecType = String.format(System.Label.SB_NCLD_Label_LeadRecType, new String[] {LD_LABEL});
      accountRecType = String.format(System.Label.SB_NCLD_Label_LeadRecType, new String[] {AC_LABEL});
      contactRecType = String.format(System.Label.SB_NCLD_Label_LeadRecType, new String[] {CO_LABEL});
  }

  //リードレコードタイプ選択リストoptopn
  public List<SelectOption> getleadrecordtypeOptions() {
      List<SelectOption> options = new List<SelectOption>();
      for (RecordTypeInfo r : leadRecordTypes) {
          options.add(new SelectOption(r.getRecordTypeId(), r.getName()));
      }
      return options;
  }

  //取引先レコードタイプ選択リストoptopn
  public List<SelectOption> getAccountRecordtypeOptions() {
      List<SelectOption> options = new List<SelectOption>();
      for (RecordTypeInfo r : accountRecordTypes) {
          options.add(new SelectOption(r.getRecordTypeId(), r.getName()));
      }
      return options;
  }

  //取引先責任者レコードタイプ選択リストoptopn
  public List<SelectOption> getContactRecordtypeOptions() {
      List<SelectOption> options = new List<SelectOption>();
      for (RecordTypeInfo r : contactRecordTypes) {
          options.add(new SelectOption(r.getRecordTypeId(), r.getName()));
      }
      return options;
  }

  // 検索条件
  public static List<SelectOption> getSearchTypeList() {
      return SB_NameCard_LeadRegist.getSearchTypeList();
  }

  // selectOptions 取引先検索条件
  public List<SelectOption> getSearchTypeSelectOpts(){
    List<SelectOption> opts = new List<SelectOption>();

    //opts.add(new SelectOption(String.valueOf(SB_NameCard_Util.SEARCHTYPE_NAME_SITE), '取引先名と所属名で検索'));
    //opts.add(new SelectOption(String.valueOf(SB_NameCard_Util.SEARCHTYPE_NAME), '取引先名のみで検索'));
    String accountNameLabel = Account.Name.getDescribe().getLabel();
    String str = accountNameLabel + System.Label.SB_NCLD_Label_AND + System.Label.SB_NCLD_Label_Site;
    opts.add(new SelectOption(String.valueOf(SmartViscaf.SB_NameCard_Util.SEARCHTYPE_NAME_SITE),str));
    String str1 = accountNameLabel;
    opts.add(new SelectOption(String.valueOf(SmartViscaf.SB_NameCard_Util.SEARCHTYPE_NAME),str1));

    return opts;
  }

  // 名刺レコードリスト
  private static List<SB_NameCardL_BulkRegistDTO.CustomObject> getNameCardRecordListDTO(List<SmartViscaf__NameCard__c> ncList, Boolean registTodo) {
      List<SB_NameCardL_BulkRegistDTO.CustomObject> ncRecListDTO = new List<SB_NameCardL_BulkRegistDTO.CustomObject>();

      for (SmartViscaf__NameCard__c nc : ncList) {
          ncRecListDTO.add(new SB_NameCardL_BulkRegistDTO.CustomObject(nc, registTodo));
      }
      return ncRecListDTO;
  }


  public Map<Id,Map<Schema.SObjectType,List<SObject>>> buildCandidateList(Set<Id> ncList) {
    List<SB_NameCardL_RegistQueryOption> queryOptions = new List<SB_NameCardL_RegistQueryOption>();
    if (this.accountQueryOption != null) {
      // 部門を検索する？
      this.accountQueryOption.queryDept = (this.searchTypeContact == SmartViscaf.SB_NameCard_Util.SEARCHTYPE_NAME_SITE);
      this.accountQueryOption.queryCompany = true; // 会社名は常に 照合
      // // 取引先名 は完全に一致？
      // this.accountQueryOption.companyRule = this.queryMatch == QUERY_PERFECT_NO ?
      //       SB_NameCardL_RegistQueryOption.CompanyMatcing.PartialMatch : SB_NameCardL_RegistQueryOption.CompanyMatcing.FullMatch;
      // // 部門の検索は完全一致？
      // this.accountQueryOption.deptRule = this.queryMatch == QUERY_PERFECT_NO ?
      //       SB_NameCardL_RegistQueryOption.DeptMatcing.PartialMatch : SB_NameCardL_RegistQueryOption.DeptMatcing.FullMatch;
      queryOptions.add(this.accountQueryOption);
    }
    if (this.contactQueryOption !=null) {
      this.contactQueryOption.queryDept = (this.searchTypeContact == SmartViscaf.SB_NameCard_Util.SEARCHTYPE_NAME_SITE);
      queryOptions.add(this.contactQueryOption);
    }
    if (this.leadQueryOption != null) {
      this.leadQueryOption.queryCompany = false;
      if (searchType == SB_NameCard_LeadRegist.SEARCHTYPE_EMAIL) {
          this.leadQueryOption.queryEMail = true;
          this.leadQueryOption.queryLastName = false;
          this.leadQueryOption.queryFirstName = false;
      }
      else {
          this.leadQueryOption.queryLastName = true;
          this.leadQueryOption.queryFirstName = true;
          this.leadQueryOption.queryEMail = false;
      }
      queryOptions.add(this.leadQueryOption);
    }
    System.assert(!queryOptions.isEmpty());
    SB_NameCardL_RegistCanPickerAbstract picker = searchMethod;
    // クエリする対象のオブエジェクト ごとに　SB_NameCardL_RegistQueryOption を作って、検索の条件を指定して渡します。
    picker.init(queryOptions);
    //picker.setQueryStrategys(qss);
    SB_NameCardL_RegistQueryExecutor qExecutor = SB_NameCardL_RegistQueryExecutor.getInstance();
    qExecutor.init(this.nameCardList);      // init は オーバーロード されてて、 個別の場合は、これか、 Id をt１つ渡すメソッドをつかって、一括の場合は 複数を渡すのを使います。
    // picker の create もオーバーロード されてて、個別ならこれとかで、一括の場合は Map<Id, List<SObject>> create(Set<Id> cardIds); を名刺レコードIDと 一致するSObjectのリストのマップを返すのを使います。
    Map<Id,Map<Schema.SObjectType,List<SObject>>> otype2objs = picker.create(ncList);
    return otype2objs;
  }


  // 検索
  public void search() {
    String message = '';
    try {
        this.hasError = false;
        Map<Id, Lead> idMap = new Map<Id, Lead>();
        Map<String, List<Lead>> emailListMap = new Map<String, List<Lead>>();
        Map<String, List<Lead>> nameListMap = new Map<String, List<Lead>>();

        if (this.nameCardIdSet.size() == 0) {
          return;
        }

        Map<Id,Map<Schema.SObjectType,List<SObject>>> sObjectList = buildCandidateList(this.nameCardIdSet);
        Boolean cor = Schema.SObjectType.Contact.isCreateable();
        Boolean acc = Schema.SObjectType.Account.isCreateable();

        inputPlickListVMap = new Map<Id, Map<String, List<SelectOption>>>();

        for (Integer i = 0; i < this.nameCardRecordListDTO.size(); i ++) {
            Boolean leadSelect = true;
            SB_NameCardL_BulkRegistDTO.CustomObject ncRec = this.nameCardRecordListDTO[i];
            ncRec.index = i;
            ncRec.leadId = 'none';
            Map<String, List<SelectOption>> opsMap = new Map<String, List<SelectOption>>();
            if (String.isBlank(ncRec.nameCard.SmartViscaf__company_name__c) || String.isBlank(SmartViscaf.SB_NameCard_Util.getPersonName(ncRec.nameCard).get('last_name'))) {
                if (!SmartViscaf.SB_NameCard_Util.isEnablePersonAccount()) {
                  opsMap.put('Lead', new List<SelectOption> {new SelectOption('none', System.Label.SB_NCLD_DontRegister_CompanyNameRequired)});
                }
                else if (SmartViscaf.SB_NameCard_Util.isEnablePersonAccount()
                  && String.isBlank(SmartViscaf.SB_NameCard_Util.getPersonName(ncRec.nameCard).get('last_name'))) {
                  opsMap.put('Lead', new List<SelectOption> {new SelectOption('none', System.Label.SB_NCLD_DontRegister_NameRequired)});
                }
                opsMap.put('Account', new List<SelectOption> {new SelectOption('-1', System.Label.SB_NCLD_DontRegister_CompanyNameRequired)});
                // opsMap.put('Account', setNameCardRecord(ncRec.nameCard, this.searchTypeContact, cIdMap, cEmailMap, cNameMap, cLastNameMap, aIdMap, aNameList, ncRec, null));
                ncRec.accAndCon = 0;
                ncRec.leadId = 'none';
            }
            // String leadId = '';
            // opsMap.put('Lead', setLeadRecord(idMap, emailListMap, nameListMap, ncRec, leadId));
            // opsMap.put('Account', setNameCardRecord(ncRec.nameCard, this.searchTypeContact, cIdMap, cEmailMap, cNameMap, cLastNameMap, aIdMap, aNameList, ncRec, leadId));
            List<SelectOption> opts = new List<SelectOption>();
            Integer index = 0;
            Map<Schema.SObjectType,List<SObject>> objMap;
            if (!opsMap.containsKey('Account')
                || !opsMap.containsKey('Lead')) {
              objMap = sObjectList.get(ncRec.nameCard.Id);
            }
                opts.add(new SelectOption(String.valueOf(index), System.Label.SB_NCLD_Menu_NotToRegister));
                index ++;
              if (sObjectList.containsKey(ncRec.nameCard.Id)) {
                  if (!opsMap.containsKey('Account')) {
                  ncRec.accAndConList = new List<SB_NameCardL_BulkRegistDTO.AccAndCon>();
                  List<SB_NameCardL_BulkRegistDTO.AccAndCon> accAndConList = ncRec.accAndConList;
                  if (objMap.containsKey(Contact.sObjectType)) {
                    for (sObject sobj : objMap.get(Contact.sObjectType)) {
                      Contact c = (Contact) sobj;
                      accAndConList.add(new SB_NameCardL_BulkRegistDTO.AccAndCon(c.AccountId, c.Id));
                      opts.add(new SelectOption(String.valueOf(index), c.Account.Name + '(' + getStr(c.Account.Site) + ')' + '/' + c.Name + '(' + getStr(c.Department) + '/' + getStr(c.Email) + ')'));
                      index ++;
                    }
                  }

                  if (objMap.containsKey(Account.sObjectType)) {
                    for (sObject sobj : objMap.get(Account.sObjectType)) {
                      Account a = (Account) sobj;
                      accAndConList.add(new SB_NameCardL_BulkRegistDTO.AccAndCon(a.Id, null));
                      opts.add(new SelectOption(String.valueOf(index), a.Name + '(' + getStr(a.Site) + ')' + '/' + System.Label.SB_NCLD_Menu_NewLead));
                      index++;
                    }
                  }
                  if (opts.size() > 1) {
                    leadSelect = false;
                    if (firstSearch) {
                      renkeiType = 'Contact';
                    }
                  }
                  if (accountCreateable && contactCreateable) {
                    opts.add(new SelectOption(String.valueOf(index), System.Label.SB_NCLD_Menu_NewLead + '/' + System.Label.SB_NCLD_Menu_NewLead));
                    accAndConList.add(new SB_NameCardL_BulkRegistDTO.AccAndCon());
                  }
                  if (opts.size() > 1) {
                    ncRec.accAndCon = 1;
                  }
                  opsMap.put('Account', opts);
              }

              if (!opsMap.containsKey('Lead')) {
                  opts = new List<SelectOption>();
                  opts.add(new SelectOption('none', System.Label.SB_NCLD_Menu_NotToRegister));
                  if (objMap.containsKey(Lead.sObjectType)) {
                    for (sObject sobj : objMap.get(Lead.sObjectType)) {
                      Lead lead = (Lead) sobj;
                      if (String.isBlank(ncRec.leadId)
                        || ncRec.leadId == 'none'
                        && leadSelect) {
                        ncRec.leadId = lead.Id;
                        ncRec.accAndCon = 0;
                        if (firstSearch) {
                          renkeiType = 'Lead';
                        }
                      }
                      // accAndConList.add(new SB_NameCardL_BulkRegistDTO.AccAndCon(c.AccountId, c.Id));
                      opts.add(new SelectOption(lead.Id, getLabel(lead.Name, lead.Email)));
                      index ++;
                    }
                  }
                  if (leadCreateable) {
                    opts.add(new SelectOption('new', System.Label.SB_NCLD_Menu_NewLead));
                    if (String.isBlank(ncRec.leadId)
                        || (leadSelect && ncRec.leadId == 'none' && renkeiType == 'Lead')) {
                      ncRec.leadId = 'new';
                      ncRec.accAndCon = 0;
                    }
                  }
                  opsMap.put('Lead', opts);
              }
            }
            else {
              opts.add(new SelectOption(String.valueOf(index), System.Label.SB_NCLD_Menu_NewLead + '/' + System.Label.SB_NCLD_Menu_NewLead));
              opsMap.put('Account', opts);
              opsMap.put('Lead', new List<SelectOption> {new SelectOption('new', System.Label.SB_NCLD_Menu_NewLead)});
            }
            inputPlickListVMap.put(ncRec.nameCard.Id, opsMap);
        }

        if (message != '') {
                testError = message;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, message));
        }
        firstSearch = false;
    } catch (Exception e) {
        System.debug(e.getStackTraceString());
        testError = e.getMessage();
        // ApexPages.addMessages(e);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, e.getMessage()));
    }
  }

  public String getStr(String s) {
    return (s == null) ? '' : s;
  }

  private String getLabel(String name, String email) {
      String label = String.isBlank(name) ? '' : name;
      label += String.isBlank(email) ? ' <>' : ' <'+email+'>';
      return label;
  }

  // 保存
  // SV_DEV-762 名刺オブジェクトの編集権限がない場合にリードに登録の処理が終了しない。
  public void saveLead() {
    saveOK = true;
    Savepoint sp;

    try {
        this.hasError = false;
        for (SB_NameCardL_BulkRegistDTO.CustomObject ncRec : this.nameCardRecordListDTO) ncRec.hasError = false;
        sp = Database.setSavepoint();
        String str = '';

        List<SB_NameCardL_RegistHelper.RegistTarget> tars = new List<SB_NameCardL_RegistHelper.RegistTarget>();
        Boolean haveNew = false;
        Boolean haveNewAccount = false;
        Integer j = 0;
        String todoError = '';
        String todoLabel = Task.getSobjectType().getDescribe().getLabel();
        Map<Integer, Id> newOwnerMap = new Map<Integer, Id>();
        Map<Integer, Id> todoIndexMap = new Map<Integer, Id>();
        List<Integer> todoList = new List<Integer>();

        //画面上の所有者を取得
        Id oId;
        if (!useNameCardOwner && String.isNotBlank(this.ownerlead.OwnerId)) {
          oId = this.ownerlead.OwnerId;
        }

        Id oIdA;
        if (!useNameCardContactOwner && String.isNotBlank(this.ownerAccount.OwnerId)) {
          oIdA = this.ownerAccount.OwnerId;
        }

        for (Integer i = 0; i < this.nameCardRecordListDTO.size(); i ++) {
          SB_NameCardL_BulkRegistDTO.CustomObject ncr = this.nameCardRecordListDTO[i];
          if (ncr.leadId != 'none' && renkeiType != 'Contact') {
            if (ncr.leadId == 'new') {
              //画面上の所有者を
              if (!haveNew) {
                haveNew = true;
                if (!useNameCardOwner && String.isBlank(this.ownerlead.OwnerId)) {
                  //(関連)リードを新規作成する場合は「所有者」を指定してください
                  // String noOwnerIdErrorMessage = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Msg_SpecifyOwnerWhenCreateLeadDEV);
                  String noOwnerIdErrorMessage = String.format(System.Label.SB_NCLD_Msg_SpecifyOwnerWhenCreateLeadDEV, new String[] {LD_LABEL});
                  throw new SB_NameCard_LeadRegist.LeadRegistException(noOwnerIdErrorMessage);
                }
              }
              Id leadOwnerId = String.isBlank(oId) ? ncr.nameCard.OwnerId : oId;
              newOwnerMap.put(i + 1, leadOwnerId);
            }
            if (ncr.registTodo == true) {

              todoIndexMap.put(i + 1, ncr.leadId == 'new' ? null : ncr.leadId);
              todoList.add(i + 1);
            }

            SB_NameCardL_RegistHelper.RegistTarget tar = new SB_NameCardL_RegistHelper.RegistTarget(SB_NameCardL_RegistHelper.ProcType.LEAD,
                                                                                                    ncr.nameCard.Id,
                                                                                                    null,
                                                                                                    null,
                                                                                                    ncr.leadId == 'new' ? null : ncr.leadId,
                                                                                                    ncr.registTodo,
                                                                                                    null);
            if (String.isNotBlank(campaignOption.campaign__c) && ncr.leadId == 'new') {
              tar.setLeadCampaign(campaignOption.campaign__c, campStatus);
            }
            tars.add(tar);
          }
          System.debug(ncr.accAndConList);
          // System.debug(ncr.accAndCon);
          if (ncr.accAndCon > 0 && renkeiType != 'Lead') {
            SB_NameCardL_BulkRegistDTO.AccAndCon aacTmp1 = ncr.accAndConList[ncr.accAndCon - 1];
            if (!haveNewAccount) {
              haveNewAccount = String.isBlank(aacTmp1.accountId) || String.isBlank(aacTmp1.contactId);
              if (haveNewAccount) {
                if (!useNameCardContactOwner && String.isBlank(this.ownerAccount.OwnerId)) {
                  //(関連)リードを新規作成する場合は「所有者」を指定してください
                  // String noOwnerIdErrorMessage = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Msg_SpecifyOwnerWhenCreateLeadDEV);
                  String noOwnerIdErrorMessage;
                  if (String.isBlank(aacTmp1.accountId)) {
                    noOwnerIdErrorMessage = String.format(System.Label.SB_NCLD_Msg_SpecifyOwnerWhenCreateLeadDEV, new String[] {AC_LABEL});
                  }
                  else {
                    noOwnerIdErrorMessage = String.format(System.Label.SB_NCLD_Msg_SpecifyOwnerWhenCreateLeadDEV, new String[] {CO_LABEL});
                  }
                  throw new SB_NameCard_LeadRegist.LeadRegistException(noOwnerIdErrorMessage);
                }
              }
            }
            SB_NameCardL_RegistHelper.RegistTarget tar = new SB_NameCardL_RegistHelper.RegistTarget(SB_NameCardL_RegistHelper.ProcType.ACCOUNT,
                                                                                                    ncr.nameCard.Id,
                                                                                                    aacTmp1.accountId,
                                                                                                    aacTmp1.contactId,
                                                                                                    null,
                                                                                                    ncr.registTodo,
                                                                                                    null);
            tars.add(tar);
          }
          j ++;
        }

        if (!todoIndexMap.isEmpty()) {
          Map<Id, Id> todoLeadIdOwnerId = new Map<Id, Id>();
          Set<Integer> todoIndexMapKey = todoIndexMap.keySet();
          Set<Integer> needSearchIndex = new Set<Integer>();
          for (Integer key : todoIndexMapKey) {
            if (!newOwnerMap.containsKey(key)) {
              todoLeadIdOwnerId.put(todoIndexMap.get(key), null);
              needSearchIndex.add(key);
            } else {
              todoIndexMap.put(key, newOwnerMap.get(key));
            }
          }

          if (!todoLeadIdOwnerId.isEmpty()) {
            List<Lead> ls = [Select Id, OwnerId
                        FROM Lead
                       WHERE Id = :todoLeadIdOwnerId.keySet()];
            for (Lead l : ls) {
              todoLeadIdOwnerId.put(l.Id, l.OwnerId);
            }
            for (Integer index : needSearchIndex) {
              todoIndexMap.put(index, todoLeadIdOwnerId.get(todoIndexMap.get(index)));
            }
          }
        }

        SB_NameCardL_RegistHelper.RegistParam leadRP;
        SB_NameCardL_RegistHelper.RegistParam acre;
        SB_NameCardL_RegistHelper.RegistParam conre;
        if (renkeiType != 'Contact') {
          leadRP = new SB_NameCardL_RegistHelper.RegistParam('Lead',this.leadOverwrite,this.leadRecordTypeId,oId,false);
        }
        if (renkeiType != 'Lead') {
          acre = new SB_NameCardL_RegistHelper.RegistParam('Account',this.accountOverWrite,this.accountRecTypeId,oIdA,false);
          conre = new SB_NameCardL_RegistHelper.RegistParam('Contact',this.contactOverWrite,this.contactRecTypeId,oIdA,false);
        }
        System.debug(leadRP);
        System.debug(acre);
        System.debug(conre);
        System.debug(renkeiType);

        SB_NameCardL_RegistHelper.TodoParam todoRP = new SB_NameCardL_RegistHelper.TodoParam(baseSetting.SmartViscaf__RegistToDoSubject__c,null,null,null);

        SB_NameCardL_RegistHelper.RegistRequest re = new SB_NameCardL_RegistHelper.RegistRequest(tars, acre, conre, leadRP, todoRP);
        Map<Id, String> ownerErrorMap = SB_NameCardL_RegistOwenrCheckHelper.doCheck(re);
        System.debug(ownerErrorMap);
        if (!ownerErrorMap.isEmpty()) {
          for (Integer i = 0; i<nameCardRecordListDTO.size(); i++) {
            if (ownerErrorMap.containsKey(nameCardRecordListDTO[i].nameCard.id)) {
              nameCardRecordListDTO[i].hasError = true;
              // ToDo
              str += String.format('{0}' + System.Label.SB_NC_Line + ': {1}', new String[]{ ''+(i+1),ownerErrorMap.get(nameCardRecordListDTO[i].nameCard.id) + '<br/>'});
            } else{
              nameCardRecordListDTO[i].hasError = false;
            }
          }
          str = str.removeEnd('<br/>');
          throw new SB_NameCard_LeadRegist.LeadRegistException(str);
        }
        //doRegist内既にrollbackしていますので、ここは二度目はしません
        SB_NameCardL_RegistHelper.RegistResponse result = SB_NameCardL_RegistHelper.doRegist(re);

        if (result.success == false) {
          str = '<br/>';
          this.hasError = true;
          if (result.dbErrors!=null) {
            for (Integer i = 0; i<this.nameCardRecordListDTO.size(); i++) {
              if (result.dbErrors.containsKey(this.nameCardRecordListDTO[i].nameCard.Id)) {
                this.nameCardRecordListDTO[i].hasError = true;
                // ToDo
                str += String.format('{0}' + System.Label.SB_NC_Line + ': {1}', new String[]{ ''+(i+1),result.dbErrors.get(this.nameCardRecordListDTO[i].nameCard.Id).msg + '<br/>'});
              } else{
                this.nameCardRecordListDTO[i].hasError =false;
              }
            }
          }
          str = str.removeEnd('<br/>');
          throw new SB_NameCard_LeadRegist.LeadRegistException(result.title + str);
        } else {
          this.hasError = false;
        }

        //Integer i = this.insertLead();
        //i += this.updateLead();
        //String str = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Msg_SelectLeadDEV);
        //if (i <= 0) throw new SB_NameCard_LeadRegist.LeadRegistException('リードを選択してください');
        //System.debug(str);
        //if (i <= 0) throw new SB_NameCard_LeadRegist.LeadRegistException(str);

        //pageRef = this.retUrl;
    }
    catch (Exception e) {
        if (sp != null) Database.rollback(sp);
        this.hasError = true;
        saveOK = false;
        System.debug(e.getMessage());
        System.debug(e.getStackTraceString());
        testError = e.getMessage();
        testError += e.getStackTraceString();
        ApexPages.addMessages(e);
        // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, e.getStackTraceString()));
    }
    //return pageRef;
  }

  public void submit() {

  }

  // SB_NameCardL_RegistQueryOptionを初期化して取得
  private SB_NameCardL_RegistQueryOption getQueryOption(sObjectType type) {
    SB_NameCardL_RegistQueryOption ot = new SB_NameCardL_RegistQueryOption(type);
    ot.queryState = false;
    ot.queryCity = false;
    ot.queryStreet = false;
    ot.queryZip = false;
    ot.queryPhone = false;
    ot.queryCompany = false;
    ot.queryDept = false;
    ot.queryUrl = false;
    ot.queryLastName = false;
    ot.queryFirstName = false;
    ot.queryEMail = false;
    ot.queryTitle = false;
    ot.queryMobile = false;
    return ot;
  }
}