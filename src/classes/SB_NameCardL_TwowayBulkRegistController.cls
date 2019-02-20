/*
 * (c) 2016 Sunbridge InameCard.SmartViscaf__
 *
 * リードに一括登録
 * @Version 1 2017/11/XX  SV_DEV-747 リード拡張パッケージのカスタム設定：リードに登録 リードレコードタイプ表示の初期値がOFF
 *                        SV_DEV-746 リードに登録（一括登録）で、検索条件が「氏名」の場合でメールアドレスが一致した候補が表示される場合がある。
 *                        SV_DEV-727 リードへ登録、名刺所有者がキューおよリード所有者がキューの場合
 *                        SV_DEV-755 無効なユーザでTODO登録したときのエラー
 *                        SV_DEV-751 リードに登録で追加された、キャンペーンメンバーの種別が「取引先責任者」になる。
 *                        SV_DEV-750 既存リードの更新時にもキャンペーンの選択が反映される。
 *                        SV_DEV-762 名刺オブジェクトの編集権限がない場合にリードに登録の処理が終了しない。
 *                        SV_DEV-760 既存リードを更新した場合に名刺のキャンペーン項目が更新される。
 *                        SV_DEV-565 リード登録のリード所有者の修正
 * @Version 1。12 2018/03/XX  SV_DEV-715 「取引先・取引先責任者に登録」の更新時のTodoの任命先は取引先責任者の所有者にする
 *
 */

public with sharing class SB_NameCardL_TwowayBulkRegistController
{
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

            this.accountQueryOption = new SB_NameCardL_RegistQueryOption(Account.sObjecttype);
            this.contactQueryOption =  new SB_NameCardL_RegistQueryOption(Contact.sObjecttype);
            // if (this.registObjs == RegistType.AccountContactLead || this.registObjs == RegistType.Lead) {
              this.leadQueryOption =  new SB_NameCardL_RegistQueryOption(Lead.sObjecttype);
            // }

            if (SB_NameCard_LeadRegist.svConfig.defaultDisplayExistingLead()) {
              renkeiType = 'Lead';
            } else {
              renkeiType = 'Contact';
            }

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
                this.leadOverwrite = baseSetting.SmartViscaf__RegistLeadNotOverWrite__c;
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





  // 取引先責任者設定
  // public List<Contact> setContactMap(Map<Id, Contact> cIdMap){
  //   Set<Id> cIdSet = new Set<Id>();
  //   Set<String> emailSet = new Set<String>();
  //   Set<String> accountNameSet = new Set<String>();
  //   Set<String> divisionSet = new Set<String>();
  //   //SV_DEV-631　不具合修正　:姓名の条件をここに保存
  //   Set<String> contactNameSet = new Set<String>();
  //   String accountName;
  //   Map<String, String> pnMap;

  //   for (SmartViscaf__NameCard__c nc : this.nameCardList) {
  //     if (nc.SmartViscaf__contact__c != null) {
  //       cIdSet.add(nc.SmartViscaf__contact__c);
  //     }

  //     if (String.isNotBlank(nc.SmartViscaf__email__c)) {
  //       emailSet.add(nc.SmartViscaf__email__c);
  //     }
  //     // 会社名を取得
  //     if (this.isFullCompanyNameForSearch == false) {
  //       accountName = SmartViscaf.SB_NameCard_Util.getCompanyName(nc.SmartViscaf__company_name__c);
  //     } else {
  //       accountName = nc.SmartViscaf__company_name__c;
  //     }
  //     pnMap = SmartViscaf.SB_NameCard_Util.getPersonName(nc);

  //     if (String.isNotBlank(accountName) && String.isNotBlank(pnMap.get('last_name'))) {
  //       accountNameSet.add(SB_NameCardL_TwowayBulkRegistController.varBindingExchange(accountName));
  //       if (this.searchTypeContact == SmartViscaf.SB_NameCard_Util.SEARCHTYPE_NAME_SITE) {
  //         if (String.isNotBlank(nc.SmartViscaf__division__c)) {
  //           divisionSet.add(SB_NameCardL_TwowayBulkRegistController.varBindingExchange(nc.SmartViscaf__division__c));
  //         } else {
  //           divisionSet.add(null);
  //         }
  //       }

  //       //SV_DEV-631　不具合修正　: 名がある場合、姓名合わせて姓名の検索条件になる
  //       // 'がある場合escapeが必要です
  //       if (String.isNotBlank(pnMap.get('first_name'))) {
  //         String last = pnMap.get('last_name');
  //         String first = pnMap.get('first_name');
  //         contactNameSet.add(' (LastName = \'' + String.escapeSingleQuotes(last) + '\'  AND  FirstName = \'' + String.escapeSingleQuotes(first) + '\') ');
  //       } else {
  //         //SV_DEV-631　不具合修正　: 姓のみの場合姓だけ姓名の検索条件になる
  //         String last = pnMap.get('last_name');
  //         contactNameSet.add(' (LastName = \'' + String.escapeSingleQuotes(last) + '\') ');
  //       }
  //     }
  //   }

  //   //姓名のクエリ条件をSetから文字列に変換
  //   String contactNamestr = '(' + String.join(new List<String>(contactNameSet), 'OR ') + ')';

  //   List<String> whereOrList = new List<String>();

  //   if (cIdSet.size() > 0) {
  //     whereOrList.add('Id = :cIdSet');
  //   }

  //   if (emailSet.size() > 0) {
  //     whereOrList.add('Email = :emailSet');
  //   }

  //   if (accountNameSet.size() > 0) {
  //     if (this.searchTypeContact == SmartViscaf.SB_NameCard_Util.SEARCHTYPE_NAME_SITE) {
  //       if (divisionSet.size() > 0) {
  //         whereOrList.add('(Account.Name LIKE :accountNameSet AND (Account.Site LIKE :divisionSet OR Department LIKE :divisionSet) AND ' + contactNamestr + ')');
  //       } else {
  //         whereOrList.add('(Account.Name LIKE :accountNameSet AND (Account.Site = null OR Department = null) AND ' + contactNamestr + ' )');
  //       }
  //     } else {
  //       whereOrList.add('(Account.Name LIKE :accountNameSet AND ' + contactNamestr  + ')');
  //     }
  //   }

  //   String whereOrStr = '';
  //   for (String s : whereOrList) {
  //     whereOrStr += ' OR ' + s;
  //   }
  //   if (String.isNotBlank(whereOrStr)) {
  //     whereOrStr = whereOrStr.removeStart(' OR ');
  //   }

  //   if (String.isNotBlank(whereOrStr)) {
  //     String soql = 'SELECT'
  //       + ' AccountId, Account.Name, Account.Site, Id, Department, Name, LastName, Email, FirstName, OwnerId'
  //       + ' FROM Contact WHERE' + ' (' + whereOrStr + ') AND IsDeleted = false'
  //       + ' ORDER BY Account.Name ASC, MailingState ASC NULLS LAST, Department ASC NULLS LAST limit 999';
  //     System.debug(soql);
  //     return Database.query(soql);
  //   }
  //   return new List<Contact>();
  // }

  // // 取引先設定
  // public List<Account> setAccountMap(Map<Id, Account> aIdMap){
  //   Set<Id> aIdSet = new Set<Id>();
  //   Set<String> accountNameSet = new Set<String>();
  //   Set<String> divisionSet = new Set<String>();
  //   String accountName;

  //   for (SmartViscaf__NameCard__c nc : this.nameCardList) {
  //     if (nc.SmartViscaf__account__c != null) {
  //       aIdSet.add(nc.SmartViscaf__account__c);
  //     }

  //     // 会社名を取得
  //     if (this.isFullCompanyNameForSearch == false) {
  //       accountName = SmartViscaf.SB_NameCard_Util.getCompanyName(nc.SmartViscaf__company_name__c);
  //     } else {
  //         accountName = nc.SmartViscaf__company_name__c;
  //     }
  //     if (String.isNotBlank(accountName)) {
  //       accountNameSet.add(SB_NameCardL_TwowayBulkRegistController.varBindingExchange(accountName));
  //       if (this.searchTypeContact == SmartViscaf.SB_NameCard_Util.SEARCHTYPE_NAME_SITE) {
  //         if (String.isNotBlank(nc.SmartViscaf__division__c)) {
  //           divisionSet.add(SB_NameCardL_TwowayBulkRegistController.varBindingExchange(nc.SmartViscaf__division__c));
  //           // divisionSet.add('%' + SB_NameCard_Util.getBackslashToWildcardEtc(nc.division__c) + '%');
  //         } else {
  //           divisionSet.add(null);
  //         }
  //       }
  //     }
  //   }

  //   List<String> whereOrList = new List<String>();

  //   if (aIdSet.size() > 0) {
  //     whereOrList.add('Id = :aIdSet');
  //   }

  //   if (accountNameSet.size() > 0) {
  //     if (this.searchTypeContact == SmartViscaf.SB_NameCard_Util.SEARCHTYPE_NAME_SITE) {
  //       if (divisionSet.size() > 0) {
  //         whereOrList.add('(Name LIKE :accountNameSet AND Site LIKE :divisionSet)');
  //       } else {
  //         whereOrList.add('(Name LIKE :accountNameSet AND Site = null)');
  //       }
  //     } else {
  //       whereOrList.add('(Name LIKE :accountNameSet)');
  //     }
  //   }

  //   String whereOrStr = '';
  //   for (String s : whereOrList) {
  //       whereOrStr += ' OR ' + s;
  //   }
  //   if (String.isNotBlank(whereOrStr)) {
  //     whereOrStr = whereOrStr.removeStart(' OR ');
  //   }

  //   if (String.isNotBlank(whereOrStr)) {
  //     String soql = 'SELECT Id, Name, Site FROM Account WHERE' + ' (' + whereOrStr + ') AND IsDeleted = false'
  //       + ' ORDER BY Name ASC, BillingState ASC NULLS LAST, Site ASC NULLS LAST limit 999';
  //     return Database.query(soql);
  //   }
  //   return new List<Account>();
  // }


  //取引先責任者関連用Mapを作成
  // public void setData(Map<Id, Contact> cIdMap, Map<String, List<Contact>> cEmailMap, Map<String, List<Contact>> cNameMap, Map<String, List<Contact>> cLastNameMap, List<Contact> contactList){
  //   List<Contact> cList;
  //   for (Contact c : contactList) {
  //     cIdMap.put(c.Id, c);

  //     if (cEmailMap.containsKey(c.Email)) {
  //       cList = cEmailMap.get(c.Email);
  //     } else {
  //       cList = new List<Contact>();
  //     }
  //     cList.add(c);
  //     cEmailMap.put(c.Email, cList);
  //     //  L229のソースによってこちのキーも同じようにLastName + ' ' + FirstNameで設定する
  //     String name = c.LastName + ' ' + c.FirstName;
  //     if (cNameMap.containsKey(name)) {
  //       cList = cNameMap.get(name);
  //     } else {
  //       cList = new List<Contact>();
  //     }
  //     cList.add(c);
  //     cNameMap.put(name, cList);

  //     if (cLastNameMap.containsKey(c.LastName)) {
  //       cList = cLastNameMap.get(c.LastName);
  //     }
  //     else {
  //       cList = new List<Contact>();
  //     }
  //     cList.add(c);
  //     cLastNameMap.put(c.LastName, cList);
  //   }
  // }

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
    // private static List<NameCardRecord> getNameCardRecordList(List<SmartViscaf__NameCard__c> ncList, Boolean registTodo) {
    //     List<NameCardRecord> ncRecList = new List<NameCardRecord>();

    //     for (SmartViscaf__NameCard__c nc : ncList) {
    //         ncRecList.add(new NameCardRecord(nc, registTodo));
    //     }
    //     return ncRecList;
    // }

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


            Map<Id,Map<Schema.SObjectType,List<SObject>>> sObjectList = buildCandidateList(this.nameCardIdSet);
            // Map<Schema.SObjectType, Map<Id, SObject>> sObjectTypemap = new Map<Schema.SObjectType, Map<Id, SObject>>();
            // sObjectTypemap.put(Lead.sObjectType, new Map<Id, SObject>());
            // for (Id ncId : sObjectList.keySet()) {
            //   Map<Schema.SObjectType,List<SObject>> stMap = sObjectList.get(ncId);
            //   for (Schema.SObjectType sobjType : stMap.keySet()) {
            //     if (!sObjectTypemap.containsKey(sobjType)) {
            //       sObjectTypemap.put(sobjType, new Map<Id, SObject>());
            //     }
            //     for (SObject sObj : stMap.get(sobjType)) {
            //       sObjectTypemap.get(sobj.getSObjectType()).put((Id)sobj.get('Id'), sobj);
            //     }
            //   }
            // }












            // this.setLeadMap(idMap, emailListMap, nameListMap, sObjectTypemap.get(Lead.sObjectType).values());
            // List<Account> aclist = new List<Account>();
            // List<Contact> colist = new List<Contact>();
            // if (sObjectTypemap.containsKey(Account.sObjectType)) {
            //   aclist = sObjectTypemap.get(Account.sObjectType).values();
            // }
            // if (sObjectTypemap.containsKey(Contact.sObjectType)) {
            //   colist = sObjectTypemap.get(Contact.sObjectType).values();
            // }
            // Map<Id, Contact> cIdMap = new Map<Id, Contact>();
            // Map<String, List<Contact>> cEmailMap = new Map<String, List<Contact>>();
            // Map<String, List<Contact>> cNameMap = new Map<String, List<Contact>>();
            // Map<String, List<Contact>> cLastNameMap = new Map<String, List<Contact>>();
            // //colist = this.setContactMap(cIdMap);

            // Map<Id, Account> aIdMap = new Map<Id, Account>();
            // List<Account> aNameList = new List<Account>();
            // //aclist = this.setAccountMap(aIdMap);

            // // 合計で998を超えた時に絞り込み検索を行う
            // Boolean cor = Schema.SObjectType.Contact.isCreateable();
            // Integer limitnumber = 998;
            // if (cor == false) {
            // limitnumber = 999;
            // }
            // if ( colist.size() + aclist.size() > limitnumber ) {
            // this.isFullCompanyNameForSearch = true;

            // cIdMap = new Map<Id, Contact>();
            // cEmailMap = new Map<String, List<Contact>>();
            // cNameMap = new Map<String, List<Contact>>();
            // cLastNameMap = new Map<String, List<Contact>>();
            // colist = this.setContactMap(cIdMap);

            // aIdMap = new Map<Id, Account>();
            // aNameList = new List<Account>();
            // aclist = this.setAccountMap(aIdMap);
            // }

            // //取引先責任者関するMap設定
            // setData(cIdMap, cEmailMap, cNameMap, cLastNameMap,colist);
            // //取引先関するMap設定
            // for (Account a : aclist) {
            //     aIdMap.put(a.Id, a);
            //     aNameList.add(a);
            // }

            // for (Integer i = 0; i < this.nameCardRecordList.size(); i ++) {
            //     NameCardRecord ncRec = this.nameCardRecordList[i];
            //     if (String.isBlank(ncRec.nameCard.SmartViscaf__company_name__c) || String.isBlank(SmartViscaf.SB_NameCard_Util.getPersonName(ncRec.nameCard).get('last_name'))) {
            //         ncRec.leadSelOptList.add(new SelectOption('none', System.Label.SB_NCLD_DontRegister_CompanyNameRequired));
            //         ncRec.setNameCardRecord(ncRec.nameCard, this.searchTypeContact, cIdMap, cEmailMap, cNameMap, cLastNameMap, aIdMap, aNameList);
            //         continue;
            //     }
            //     ncRec.setLeadRecord(idMap, emailListMap, nameListMap);
            //     ncRec.setNameCardRecord(ncRec.nameCard, this.searchTypeContact, cIdMap, cEmailMap, cNameMap, cLastNameMap, aIdMap, aNameList);
            //     ncRec.index = i;
            //     if (ncRec.message != '') {
            //             message = ncRec.message;
            //     }
            // }
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
                    opsMap.put('Account', new List<SelectOption> {new SelectOption('none', System.Label.SB_NCLD_DontRegister_CompanyNameRequired)});
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
                            && leadSelect) {
                            ncRec.leadId = lead.Id;
                            ncRec.accAndCon = 0;
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
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            testError = e.getMessage();
            // ApexPages.addMessages(e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, e.getMessage()));
        }
    }

    // public List<SelectOption> setNameCardRecord(SmartViscaf__NameCard__c nc, Integer searchType,
    //       Map<Id, Contact> cIdMap, Map<String, List<Contact>> cEmailMap, Map<String, List<Contact>> cNameMap, Map<String, List<Contact>> cLastNameMap,
    //       Map<Id, Account> aIdMap, List<Account> aNameList, SB_NameCardL_BulkRegistDTO.CustomObject dto, String leadId){
    //       // this.nameCard = nc;
    //       Integer accAndCon = 1;
    //       dto.accAndConList = new List<SB_NameCardL_BulkRegistDTO.AccAndCon>();
    //       List<SB_NameCardL_BulkRegistDTO.AccAndCon> accAndConList = dto.accAndConList;

    //       Boolean registTask = false;

    //       Map<String, String> pnMap = SmartViscaf.SB_NameCard_Util.getPersonName(nc);
    //       List<SelectOption> opts = new List<SelectOption>();

    //       if (String.isBlank(nc.SmartViscaf__company_name__c) || String.isBlank(pnMap.get('last_name'))) {
    //         accAndConList.add(new SB_NameCardL_BulkRegistDTO.AccAndCon());
    //         opts.add(new SelectOption('0', System.Label.SB_NCLD_DontRegister_CompanyNameRequired));
    //       } else {
    //         List<Contact> cList = getContactList(searchType, pnMap.get('last_name'), pnMap.get('first_name'), cIdMap, cEmailMap, cNameMap, cLastNameMap, nc);
    //         List<Account> aList = getAccountList(searchType, aIdMap, aNameList, nc);
    //         System.debug('cList.size: ' + cList.size() + ' aList.size: ' + aList.size());

    //         Integer index = 0;
    //         accAndConList.add(new SB_NameCardL_BulkRegistDTO.AccAndCon());
    //         opts.add(new SelectOption(String.valueOf(index), System.Label.SB_NCLD_Menu_NotToRegister));
    //         index++;
    //         Boolean cor = Schema.SObjectType.Contact.isCreateable();
    //         Boolean acc = Schema.SObjectType.Account.isCreateable();
    //         //オブジェクトの作成権限がないため、新規作成のタブを表示しないとなりました、
    //         //その結果、タブを1000件のうち、自分で追加するのは１件しかないです
    //         Integer optsnumber = 998;
    //         if (cor == false) {
    //           optsnumber = 999;
    //         }
    //         // 合計で1000行（「<新規作成><新規作成>」、「登録しない」含む）を超えない場合データをドロップダウンリストに表示する
    //         if ( cList.size() + aList.size() <= optsnumber ) {
    //           for (Contact c : cList) {
    //             accAndConList.add(new SB_NameCardL_BulkRegistDTO.AccAndCon(c.AccountId, c.Id));
    //             opts.add(new SelectOption(String.valueOf(index), c.Account.Name + '(' + getStr(c.Account.Site) + ')' + '/' + c.Name + '(' + getStr(c.Department) + '/' + getStr(c.Email) + ')'));
    //             index++;
    //           }
    //           if (cor != null && cor == true) {
    //             for (Account a : aList) {
    //               accAndConList.add(new SB_NameCardL_BulkRegistDTO.AccAndCon(a.Id, null));
    //               opts.add(new SelectOption(String.valueOf(index), a.Name + '(' + getStr(a.Site) + ')' + '/' + System.Label.SB_NCLD_Menu_NewLead));
    //               index++;
    //             }
    //           }
    //         }

    //         if (String.isNotBlank(leadId) && opts.size() > 1 || (String.isBlank(leadId) && opts.size() > 1 )) {
    //           leadId = 'none';
    //           registTask = !SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RegistNoToDo__c;
    //         } else if (String.isNotBlank(leadId) && opts.size() <= 1 ) {
    //           accAndCon = 0;
    //         } else {
    //           if (SB_NameCard_LeadRegist.svConfig.defaultDisplayExistingLead()) {
    //             accAndCon = 0;
    //           } else {
    //             leadId = 'none';
    //             registTask = !SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RegistNoToDo__c;
    //           }
    //         }


    //           accAndConList.add(new SB_NameCardL_BulkRegistDTO.AccAndCon(null, null));
    //           if (cor != null && cor == true  && acc != null && acc == true) {
    //             opts.add(new SelectOption(String.valueOf(index), System.Label.SB_NCLD_Menu_NewLead + '/' + System.Label.SB_NCLD_Menu_NewLead));
    //           }
    //         }
    //         dto.accAndCon = accAndCon;
    //         // accAndConSelectOpts = opts;
    //         // regist = false;
    //         return opts;
    //     }

    public String getStr(String s) {
        return (s == null) ? '' : s;
      }


        // 取引先責任者取得
    // private List<Contact> getContactList(Integer searchType, String lastName, String firstName, Map<Id, Contact> cIdMap, Map<String, List<Contact>> cEmailMap,
    //   Map<String, List<Contact>> cNameMap, Map<String, List<Contact>> cLastNameMap, SmartViscaf__NameCard__c nameCard){
    //   Map<Id, Boolean> idMap = new Map<Id, Boolean>();
    //   List<Contact> cList = new List<Contact>();

    //   if (nameCard.SmartViscaf__contact__c != null && cIdMap.containsKey(nameCard.SmartViscaf__contact__c)) {
    //     Contact c = cIdMap.get(nameCard.SmartViscaf__contact__c);
    //     idMap.put(c.Id, true);
    //     cList.add(c);
    //   }

    //   List<Contact> cTmpList = new List<Contact>();
    //   if (nameCard.SmartViscaf__email__c != null && cEmailMap.containsKey(nameCard.SmartViscaf__email__c)) {
    //     cTmpList.addAll(cEmailMap.get(nameCard.SmartViscaf__email__c));

    //     for (Contact c : cTmpList) {
    //       if (!idMap.containsKey(c.Id)) {
    //         idMap.put(c.Id, true);
    //         cList.add(c);
    //       }
    //     }
    //   }

    //   cTmpList.clear();
    //   if (String.isNotBlank(firstName)) {
    //     String name = lastName + ' ' + firstName;

    //     if (cNameMap.containsKey(name)) {
    //       cTmpList.addAll(cNameMap.get(name));
    //     }
    //   } else {
    //     String name = lastName; // 姓のみ

    //     if (cLastNameMap.containsKey(name)) {
    //       cTmpList.addAll(cLastNameMap.get(name));
    //     }
    //   }

    //   String accountName = SmartViscaf.SB_NameCard_Util.getCompanyName(nameCard.SmartViscaf__company_name__c);
    //   if (String.isNotBlank(accountName)) {
    //     String division = nameCard.SmartViscaf__division__c;
    //     Boolean f;

    //     for (Contact c : cTmpList) {
    //       if (!idMap.containsKey(c.Id)) {
    //           f = false;

    //           if (String.isNotBlank(c.Account.Name) && SB_NameCard_MojiWidthUtil.findIgnoreCaseWidth(c.Account.Name,SB_NameCard_MojiWidthUtil.toHalfWidth(accountName))) {
    //             if (searchType == SmartViscaf.SB_NameCard_Util.SEARCHTYPE_NAME_SITE) {
    //               if (String.isNotBlank(division)) {
    //                 if (String.isNotBlank(c.Department) && SB_NameCard_MojiWidthUtil.findIgnoreCaseWidth(c.Department,SB_NameCard_MojiWidthUtil.toHalfWidth(division))) {
    //                   f = true;
    //                 }
    //               } else {
    //                 if (String.isBlank(c.Department)) {
    //                   f = true;
    //                 }
    //               }
    //             } else {
    //               f = true;
    //             }
    //         }
    //         if (f) {
    //           idMap.put(c.Id, true);
    //           cList.add(c);
    //         }
    //       }
    //     }
    //   }

    //   return cList;
    // }

    // 取引先取得
    // private List<Account> getAccountList(Integer searchType, Map<Id, Account> aIdMap, List<Account> aNameList, SmartViscaf__NameCard__c nameCard) {
    //   Map<Id, Boolean> idMap = new Map<Id, Boolean>();
    //   List<Account> aList = new List<Account>();

    //   if (nameCard.SmartViscaf__account__c != null && aIdMap.containsKey(nameCard.SmartViscaf__account__c)) {

    //     Account a = aIdMap.get(nameCard.SmartViscaf__account__c);
    //     idMap.put(a.Id, true);
    //     aList.add(a);
    //   }

    //   String accountName = SmartViscaf.SB_NameCard_Util.getCompanyName(nameCard.SmartViscaf__company_name__c);
    //   if (String.isNotBlank(accountName)) {

    //     String division = nameCard.SmartViscaf__division__c;
    //     Boolean f;

    //     for (Account a : aNameList) {
    //       if (!idMap.containsKey(a.Id)) {
    //         f = false;

    //         if (String.isNotBlank(a.Name) && SB_NameCard_MojiWidthUtil.findIgnoreCaseWidth(a.Name,SB_NameCard_MojiWidthUtil.toHalfWidth(accountName))) {
    //           if (searchType == SmartViscaf.SB_NameCard_Util.SEARCHTYPE_NAME_SITE) {
    //               if (String.isNotBlank(division)) {
    //                 if (String.isNotBlank(a.Site) && SB_NameCard_MojiWidthUtil.findIgnoreCaseWidth(a.Site,SB_NameCard_MojiWidthUtil.toHalfWidth(division))) {
    //                   f = true;
    //                 }
    //               } else {
    //                 if (String.isBlank(a.Site)) {
    //                   f = true;
    //                 }
    //               }
    //           } else {
    //             f = true;
    //           }
    //         }
    //         if (f) {
    //           idMap.put(a.Id, true);
    //           aList.add(a);
    //         }
    //       }
    //     }
    //   }
    //   return aList;
    // }



    // public List<SelectOption> setLeadRecord(Map<Id, Lead> idMap, Map<String, List<Lead>> emailListMap, Map<String, List<Lead>> nameListMap, SB_NameCardL_BulkRegistDTO.CustomObject dto,
    //                                         String leadId) {
    //         List<SelectOption> leadSelOptList = new List<SelectOption>();
    //         //this.leadSelOptList.add(new SelectOption('none', '登録しない'));
    //         leadSelOptList.add(new SelectOption('none', System.Label.SB_NCLD_Menu_NotToRegister));

    //         String message = '';

    //         Set<Id> idSet = new Set<Id>();
    //         List<SelectOption> emailSelOptList = new List<SelectOption>();
    //         List<SelectOption> nameSelOptList = new List<SelectOption>();
    //         SmartViscaf__NameCard__c nameCard = dto.nameCard;
    //         if (idMap != null && idMap.containsKey(nameCard.SmartViscaf__lead__c)) {
    //             Lead lead = idMap.get(nameCard.SmartViscaf__lead__c);
    //             leadSelOptList.add(new SelectOption(lead.Id, getLabel(lead.Name, lead.Email)));
    //             idSet.add(lead.Id);
    //         }
    //         if (emailListMap != null && emailListMap.containsKey(nameCard.SmartViscaf__email__c)) {
    //             for (Lead lead : emailListMap.get(nameCard.SmartViscaf__email__c)) {
    //                 if (idSet.contains(lead.Id)) continue;
    //                 emailSelOptList.add(new SelectOption(lead.Id, getLabel(lead.Name, lead.Email)));
    //                 idSet.add(lead.Id);
    //             }
    //         }
    //         if (nameListMap != null) {
    //             String name = SB_NameCard_LeadRegist.getPersonName(nameCard);
    //             if (nameListMap.containsKey(name)) {
    //                 for (Lead lead : nameListMap.get(name)) {
    //                     if (idSet.contains(lead.Id)) continue;
    //                     nameSelOptList.add(new SelectOption(lead.Id, getLabel(lead.Name,lead.Email)));
    //                     idSet.add(lead.Id);
    //                 }
    //             }
    //         }
    //         Integer Leadnumber = Lead.sObjectType.getDescribe().isCreateable() == true ? 998 : 999;
    //         if (leadSelOptList.size() + emailSelOptList.size() + nameSelOptList.size() <= Leadnumber) {
    //             leadSelOptList.addAll(emailSelOptList);
    //             leadSelOptList.addAll(nameSelOptList);
    //         } else {
    //             // String str = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Msg_DisplayUnderConditionsDEV);
    //             //this.message = '検索件数が制限を超えたので過去に登録したリードだけに絞って表示します。';
    //             message = String.format(System.Label.SB_NCLD_Msg_DisplayUnderConditionsDEV, new String[] {LD_LABEL});
    //         }
    //         //this.leadSelOptList.add(new SelectOption('new', '新規作成'))
    //          if(Lead.sObjectType.getDescribe().isCreateable())
    //          {
    //             leadSelOptList.add(new SelectOption('new', System.Label.SB_NCLD_Menu_NewLead));
    //          }
    //          Integer i = leadSelOptList.size()>1 ? 1 : 0;
    //         SelectOption ss = leadSelOptList[i];
    //         leadId = ss.getValue();
    //         // hasError = false;
    //         return leadSelOptList;
    //     }

        private String getLabel(String name, String email) {
            String label = String.isBlank(name) ? '' : name;
            label += String.isBlank(email) ? ' <>' : ' <'+email+'>';
            return label;
        }

    // リード
    // private void setLeadMap(Map<Id, Lead> idMap, Map<String, List<Lead>> emailListMap, Map<String, List<Lead>> nameListMap, List<Lead> leads) {
    //     this.leadOwnerIdMap.clear();
    //     String soql = this.soqlMap.get(this.searchType);
    //     System.debug(soql);
    //     System.debug(this.searchType);
    //     System.debug(soqlMap);

    //     if (String.isBlank(soql)) return;
    //         String name ='';
    //       //for (Lead lead : Database.query(soql)) {
    //       for (Lead lead : leads) {
    //         idMap.put(lead.Id, lead);
    //         this.leadOwnerIdMap.put(lead.Id, lead.OwnerId);

    //         // SV_DEV-746 リードに登録（一括登録）で、検索条件が「氏名」の場合でメールアドレスが一致した候補が表示される場合がある。
    //         if (this.searchType == SB_NameCard_LeadRegist.SEARCHTYPE_EMAIL) {
    //             if (String.isNotBlank(lead.Email)) {
    //                 if (emailListMap.containsKey(lead.Email)) {
    //                     emailListMap.get(lead.Email).add(lead);
    //                 } else {
    //                     emailListMap.put(lead.Email, new List<Lead>{lead});
    //                 }
    //             }
    //         } else {

    //             // 姓名
    //             if (nameListMap.containsKey(lead.Name)) {

    //                 nameListMap.get(lead.Name).add(lead);
    //             }
    //             else {
    //                 nameListMap.put(lead.Name, new List<Lead>{lead});
    //             }

    //             // 姓のみ
    //             name = lead.LastName;
    //             if (nameListMap.containsKey(name)) {
    //                 nameListMap.get(name).add(lead);
    //             }
    //             else {
    //                 nameListMap.put(name, new List<Lead>{lead});
    //             }
    //             // 名のみ
    //             name = lead.FirstName;
    //             if (nameListMap.containsKey(name)) {
    //                 nameListMap.get(name).add(lead);
    //             }
    //             else {
    //                 nameListMap.put(name, new List<Lead>{lead});
    //             }
    //         }
    //     }
    // }

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
              str = '<br/>';
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
            testError = e.getMessage();
            testError += e.getStackTraceString();
            ApexPages.addMessages(e);
            // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, e.getStackTraceString()));
        }
        //return pageRef;
    }

    // リード作成
    // private Integer insertLead() {
    //     List<Lead> leadList = new List<Lead>();
    //     List<SB_NameCardL_BulkRegistDTO.CustomObject> ncRecList = new List<SB_NameCardL_BulkRegistDTO.CustomObject>();
    //     // String str = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Msg_SpecifyOwnerWhenCreateLeadDEV);
    //     String str = String.format(System.Label.SB_NCLD_Msg_SpecifyOwnerWhenCreateLeadDEV, new String[] {LD_LABEL});

    //     // SV_DEV-565 リード登録のリード所有者の修正
    //     String errMsg = '';
    //     Map<Integer, Id> insertOwnerMap = new Map<Integer, Id>();

    //     Schema.DescribeSObjectResult tar = Lead.sObjecttype.getDescribe();

    //     Integer i = 0;
    //     for (SB_NameCardL_BulkRegistDTO.CustomObject ncRec : this.nameCardRecordListDTO) {
    //         i ++;
    //         if (ncRec.leadId != 'new') {
    //             continue;
    //         }

    //         if (this.ownerlead.OwnerId == null && useNameCardOwner == false) {
    //             //throw new SB_NameCard_LeadRegist.LeadRegistException('リードを新規作成する場合は「所有者」を指定してください');
    //             throw new SB_NameCard_LeadRegist.LeadRegistException(str);
    //         }

    //         if(!leadCreateable) {
    //              throw new LeadBulkRegistControllerException(String.format(System.Label.SB_NCLD_MSG_CrudNotCreateable, new String[]{tar.label}));
    //         }
    //         // SV_DEV-565 リード登録のリード所有者の修正
    //         Id oId = !useNameCardOwner ? this.ownerlead.OwnerId : ncRec.nameCard.OwnerId;
    //         if (!String.valueOf(oId).startsWith('005')) {
    //             insertOwnerMap.put(i, oId);
    //         }

    //         leadList.add(SB_NameCard_LeadRegist.getLead(null, ncRec.nameCard, oId,this.leadRecTypeEdit == true  ? this.leadRecordTypeId : null));
    //         ncRecList.add(ncRec);
    //     }

    //     // SV_DEV-565 リード登録のリード所有者の修正
    //     if (!insertOwnerMap.isEmpty()) {

    //         List<QueueSobject> qss = [Select QueueId, SobjectType, Queue.Name
    //                     FROM QueueSobject
    //                    WHERE QueueId = :insertOwnerMap.values()];
    //         Set<Id> canUserLeadQueues = new Set<Id>();
    //         Map<Id, String> qssMap = new Map<Id, String>();
    //         for (QueueSobject qs : qss) {
    //             qssMap.put(qs.QueueId, qs.Queue.Name);
    //             if (qs.SobjectType == 'Lead') {
    //                 canUserLeadQueues.add(qs.QueueId);
    //             }
    //         }

    //         for (Integer line : insertOwnerMap.keySet()) {
    //             Id qId = insertOwnerMap.get(line);
    //             if (!canUserLeadQueues.contains(qId)) {
    //                 nameCardRecordListDTO[line-1].hasError = true;
    //                 String msg = line + System.Label.SB_NC_Line + ': ' + Lead.getSobjectType().getDescribe().getLabel()
    //                              + System.Label.SB_NCLD_MSG_Regist_Error + ': ' + String.format(System.Label.SB_NCLD_MSG_QUEUES_LEAD_ERROR,new String[]{qssMap.get(qId)}) + '<br>';
    //                 errMsg += msg;
    //             }
    //         }
    //         if (String.isNotBlank(errMsg)) {
    //             throw new SB_NameCard_LeadRegist.LeadRegistException(errMsg);
    //         }
    //     }



    //     if (leadList.size() <= 0) return 0;
    //         Database.DMLOptions dml = new Database.DMLOptions();

    //         dml.OptAllOrNone = false;

    //     // リード
    //     //SV_DEV-755 無効なユーザでTODO登録したときのエラー
    //     this.setResult(SmartViscaf.SB_NameCard_CrudFls.screate(leadList,dml), ncRecList, Lead.getSObjectType(), true);

    //     // キャンペーンメンバー
    //     insertCampaignMember(this.campaignOption.campaign__c, leadList, ncRecList, campStatus);

    //     // 名刺
    //     // SV_DEV-760 既存リードを更新した場合に名刺のキャンペーン項目が更新される。
    //     updateNameCard(leadList, ncRecList, this.campaignOption.campaign__c, false);

    //     // ToDo
    //     // if(!useNameCardOwner && String.valueOf(this.ownerlead.ownerId).startsWith('005')) {
    //         insertTodo(leadList, ncRecList);
    //     // }

    //     return leadList.size();
    // }

    // リード更新
    // private Integer updateLead()
    // {
    //     Id leadId;
    //     Set<Id> leadIdSet = new Set<Id>();
    //     List<Lead> leadList = new List<Lead>();
    //     // SV_DEV-565 リード登録のリード所有者の修正
    //     String errMsg = '';
    //     Map<Integer, Id> updateOwnerMap = new Map<Integer, Id>();
    //     List<SB_NameCardL_BulkRegistDTO.CustomObject> ncRecList = new List<SB_NameCardL_BulkRegistDTO.CustomObject>();
    //     // String str = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Text_LeadOverLapDEV);
    //     String str = String.format(System.Label.SB_NCLD_Text_LeadOverLapDEV, new String[] {LD_LABEL});
    //     Schema.DescribeSObjectResult tar = Lead.sObjectType.getDescribe();

    //     Integer i = 0;

    //     for (SB_NameCardL_BulkRegistDTO.CustomObject ncRec : this.nameCardRecordListDTO) {
    //         i++;
    //         if (ncRec.leadId == 'none' || ncRec.leadId == 'new') continue;

    //         leadId = Id.valueOf(ncRec.leadId);

    //          if(!Lead.sObjectType.getDescribe().isUpdateable() && this.leadOverwrite) {
    //              throw new LeadBulkRegistControllerException(String.format(System.Label.SB_NCLD_MSG_CrudNotUpdateable, new String[]{tar.label}));
    //           }
    //         //if (leadIdSet.contains(leadId)) throw new SB_NameCard_LeadRegist.LeadRegistException('リードが重複しています');
    //         if (leadIdSet.contains(leadId)) throw new SB_NameCard_LeadRegist.LeadRegistException(str);
    //         leadIdSet.add(leadId);

    //         if (this.leadOverwrite) {
    //             Id oId = this.leadOwnerIdMap.get(leadId);

    //             if (!String.valueOf(oId).startsWith('005')) {
    //                 updateOwnerMap.put(i, oId);
    //             }
    //             leadList.add(SB_NameCard_LeadRegist.getLead(leadId, ncRec.nameCard, oId,null));
    //         }
    //         else {
    //             leadList.add(new Lead(Id=leadId, NameCard__c=ncRec.nameCard.Id));
    //         }
    //         ncRecList.add(ncRec);
    //     }
    //     if (leadList.size() <= 0) return 0;

    //     // SV_DEV-565 リード登録のリード所有者の修正
    //     if (!updateOwnerMap.isEmpty()) {

    //         List<QueueSobject> qss = [Select QueueId, SobjectType, Queue.Name
    //                     FROM QueueSobject
    //                    WHERE QueueId = :updateOwnerMap.values()];
    //         Set<Id> canUserLeadQueues = new Set<Id>();
    //         Map<Id, String> qssMap = new Map<Id, String>();
    //         for (QueueSobject qs : qss) {
    //             qssMap.put(qs.QueueId, qs.Queue.Name);
    //             if (qs.SobjectType == 'Lead') {
    //                 canUserLeadQueues.add(qs.QueueId);
    //             }
    //         }

    //         for (Integer line : updateOwnerMap.keySet()) {
    //             Id qId = updateOwnerMap.get(line);
    //             if (!canUserLeadQueues.contains(qId)) {
    //                 nameCardRecordListDTO[line-1].hasError = true;
    //                 String msg = line + System.Label.SB_NC_Line + ': ' + Lead.getSobjectType().getDescribe().getLabel()
    //                              + System.Label.SB_NCLD_MSG_Update_Error + ': ' + String.format(System.Label.SB_NCLD_MSG_QUEUES_LEAD_ERROR,new String[]{qssMap.get(qId)}) + '<br>';
    //                 errMsg += msg;
    //             }
    //         }
    //         if (String.isNotBlank(errMsg)) {
    //             throw new SB_NameCard_LeadRegist.LeadRegistException(errMsg);
    //         }
    //     }

    //     //SmartViscaf.SB_NameCard_CrudFls.screateLead(leadList);

    //     Database.DMLOptions dml = new Database.DMLOptions();

    //     //エラーなってでも保存続く
    //     dml.OptAllOrNone = false;

    //     // リード
    //     //SV_DEV-755 無効なユーザでTODO登録したときのエラー
    //     if (this.leadOverwrite) {
    //         this.setResult(SmartViscaf.SB_NameCard_CrudFls.supdate(leadList, dml), ncRecList, Lead.getSObjectType(), false);
    //     }

    //     // キャンペーンメンバー
    //     // SV_DEV-750 既存リードの更新時にもキャンペーンの選択が反映される。
    //     // insertCampaignMember(this.campaignOption.campaign__c, leadList, ncRecList, campStatus);

    //     // 名刺
    //     // SV_DEV-760 既存リードを更新した場合に名刺のキャンペーン項目が更新される。
    //     updateNameCard(leadList, ncRecList, this.campaignOption.campaign__c, true);

    //     // ToDo
    //     insertTodo(leadList, ncRecList);

    //     return leadList.size();
    // }

    // リード処理結果
    // private void setResult(List<Database.SaveResult> srList, List<SB_NameCardL_BulkRegistDTO.CustomObject> ncRecList, sObjectType sobj, Boolean isCreate) {
    //     String errMsg = '';

    //     Map<Id,Integer> cardindex = new Map<Id,Integer>();
    //     for (Integer i = 0 ; i<nameCardRecordListDTO.size() ; i++) {
    //         SB_NameCardL_BulkRegistDTO.CustomObject nr = nameCardRecordListDTO[i];
    //         cardindex.put(nr.nameCard.Id,i);
    //     }

    //     SB_NameCard_LeadSaveResult dbError = new SB_NameCard_LeadSaveResult();
    //     dbError.putSaveResults(srList);

    //     if (dbError.isError()) {
    //         String leadl = sobj.getDescribe().getLabel();
    //         //SV_DEV-755 無効なユーザでTODO登録したときのエラー
    //         leadl += isCreate ? System.Label.SB_NCLD_MSG_Regist_Error : System.Label.SB_NCLD_MSG_Update_Error;
    //         for (Integer i = 0; i < srList.size(); i++) {
    //             SB_NameCard_LeadSaveResult.DbErrorHolder err = dbError.getDbErrorHolder(i);
    //             SB_NameCardL_BulkRegistDTO.CustomObject n = ncRecList[i];
    //             if (err == null) {
    //                 n.hasError = false;
    //                  ncRecList[i].hasError = false;
    //                 continue;
    //             }
    //             n.hasError = true;
    //              ncRecList[i].hasError = true;
    //             String msg = (cardindex.get(n.nameCard.Id)  + 1) + System.Label.SB_NC_Line + ': ' + leadl + ': ' + err.msg + '<br>';
    //             errMsg += msg;
    //         }
    //         //errorMsg += msg;
    //         if (String.isNotBlank(errMsg)) throw new SB_NameCard_LeadRegist.LeadRegistException(errMsg);
    //         //throw new SB_NameCard_LeadRegist.LeadRegistException(errMsg);
    //     }

    //     //for (Integer i = 0; i < srList.size(); i++) {
    //     //    if (srList[i].isSuccess()) {
    //     //        ncRecList[i].hasError = false;
    //     //        continue;
    //     //    }
    //     //    ncRecList[i].hasError = true;

    //     //    for (Database.Error err : srList[i].getErrors()) {
    //     //        errMsg += i+1 + System.Label.SB_NC_Line + ': ' + err.getMessage() + '<br/>';
    //     //    }
    //     //}
    //     //if (String.isNotBlank(errMsg)) throw new SB_NameCard_LeadRegist.LeadRegistException(errMsg);
    // }

    // キャンペーンメンバー
    // private static void insertCampaignMember(Id campId, List<Lead> leadList, List<SB_NameCardL_BulkRegistDTO.CustomObject> ncRecList, String campStatus) {
    //     if (campId == null) return;
    //     List<CampaignMember> cmList = new List<CampaignMember>();

    //     for (Integer i = 0, len = leadList.size(); i < len; i++) {
    //         //SV_DEV-751 リードに登録で追加された、キャンペーンメンバーの種別が「取引先責任者」になる。
    //         cmList.add(new CampaignMember(CampaignId=campId, LeadId=leadList[i].Id, Status = campStatus));
    //     }
    //     if (cmList.size() > 0) {
    //         Database.DMLOptions dml = new Database.DMLOptions();

    //         dml.OptAllOrNone = true;
    //         System.debug(cmList);
    //         SmartViscaf.SB_NameCard_CrudFls.screate(cmList,dml);
    //         System.debug(cmList);

    //      }
    // }

    // // 名刺
    // // SV_DEV-760 既存リードを更新した場合に名刺のキャンペーン項目が更新される。
    // private static void updateNameCard(List<Lead> leadList, List<SB_NameCardL_BulkRegistDTO.CustomObject> ncRecList, Id campId, Boolean isUpdate) {
    //     List<SmartViscaf__NameCard__c> ncList = new List<SmartViscaf__NameCard__c>();
    //     Id leadId;

    //     for (Integer i = 0, len = leadList.size(); i < len; i++) {
    //         leadId = leadList[i].Id;
    //         if (campId != null && ncRecList[i].nameCard.campaign__c != campId) {
    //           // SV_DEV-760 既存リードを更新した場合に名刺のキャンペーン項目が更新される。
    //           if (!isUpdate) {
    //             ncList.add(new SmartViscaf__NameCard__c(Id=ncRecList[i].nameCard.Id, SmartViscaf__lead__c=leadId, campaign__c=campId));
    //           } else {
    //             ncList.add(new SmartViscaf__NameCard__c(Id=ncRecList[i].nameCard.Id, SmartViscaf__lead__c=leadId));
    //           }
    //         }
    //         else if (leadId != ncRecList[i].nameCard.SmartViscaf__lead__c) {

    //             ncList.add(new SmartViscaf__NameCard__c(Id=ncRecList[i].nameCard.Id, SmartViscaf__lead__c=leadId));
    //         }
    //     }

    //     if (ncList.size() > 0) {
    //         Database.DMLOptions dml = new Database.DMLOptions();

    //         dml.OptAllOrNone = true;

    //         SmartViscaf.SB_NameCard_CrudFls.supdate(ncList, dml);

    //     }
    // }

    // ToDo
    // private void insertTodo(List<Lead> leadList, List<SB_NameCardL_BulkRegistDTO.CustomObject> ncRecList) {
    //     String subject = SB_NameCard_LeadRegist.svConfig.todoSubject();
    //     List<Task> todoList = new List<Task>();
    //     Id leadId;
    //     Id ownerId;
    //     String errMsg = '';
    //     Map<Id,Integer> cardindex = new Map<Id,Integer>();
    //     for (Integer i = 0 ; i<nameCardRecordListDTO.size() ; i++) {
    //         SB_NameCardL_BulkRegistDTO.CustomObject nr = nameCardRecordListDTO[i];
    //         cardindex.put(nr.nameCard.Id,i);
    //     }
    //     for (Integer i = 0, len = leadList.size(); i < len; i++) {
    //         if (!ncRecList[i].registTodo) continue;
    //         leadId = leadList[i].Id;
    //         ownerId = this.leadOwnerIdMap.get(leadId);
    //         if (ownerId == null) {
    //             ownerId = leadList[i].OwnerId;
    //         }
    //         // SV_DEV-727 リードへ登録、名刺所有者がキューおよリード所有者がキューの場合
    //         if(!String.valueOf(ownerId).startsWith('005')) {
    //             String todoE = Task.getSobjectType().getDescribe().getLabel();
    //             //SV_DEV-755 無効なユーザでTODO登録したときのエラー
    //             todoE += System.Label.SB_NCLD_MSG_Regist_Error;
    //             ncRecList[i].hasError = true;
    //             String msg = (cardindex.get(ncRecList[i].nameCard.Id) + 1) + System.Label.SB_NC_Line + ': ' + todoE + ': ' + System.Label.SB_NCLD_MSG_QUEUES_ERROR + '<br>';
    //             errMsg += msg;
    //             continue;
    //         }
    //         todoList.add(SB_NameCard_LeadRegist.getTodo(leadId, ownerId, subject, ncRecList[i].nameCard.SmartViscaf__card_exchange_date__c));
    //     }

    //     if (String.isNotBlank(errMsg)) throw new SB_NameCard_LeadRegist.LeadRegistException(errMsg.removeEnd('<br>'));

    //     if (todoList.size() > 0) {
    //         Database.DMLOptions dml = new Database.DMLOptions();

    //         dml.OptAllOrNone = false;

    //         //SV_DEV-755 無効なユーザでTODO登録したときのエラー
    //         this.setResult(SmartViscaf.SB_NameCard_CrudFls.screate(todoList,dml), ncRecList, Task.getSObjectType(), true);

    //      }
    // }

    // キャンセル
    //public PageReference cancel()
    //{
    //    return this.retUrl;
    //}
    // public static String varBindingExchange(String str) {
    //     //アポストロフィーがある場合、escapeSingleQuotesメソッドがエスケープされるはずですが、
    //     //なぜかうまくエスケープできてないので、エスケープする前にアポストロフィーをbase64を使って暗号化して、エスケープ後に元に戻す
    //     String str1 = EncodingUtil.urlEncode(str, 'UTF-8');
    //     Blob b = Blob.valueOf(str1);
    //     String b64 = EncodingUtil.base64Encode(b);
    //     str = str.replaceAll('\'',b64);
    //     str = String.escapeSingleQuotes('%' + (String.isBlank(str) ? str : str.replaceAll('＼', '_')) + '%');
    //     str = str.replaceAll(b64,'\'');
    //     return str;
    //   }

      public static List<RecordTypeInfo> getRecordType(Schema.sObjectType obj){

        List<Schema.RecordTypeInfo> rs =  obj.getDescribe().getRecordTypeInfos();
        List<RecordTypeInfo> recordtypes = new List<RecordTypeInfo>();
        for (RecordTypeInfo r : rs) {
          if (r.isAvailable()) {
            recordtypes.add(r);
          }
        }
        //isMasterメソード使えるにはWinter'16　APIバージョン35.0以降でなければならない、
        //そのため、今最後のレコードタイプMasterをリストから削除します
        if (recordtypes.size()>0) {
          recordtypes.remove(recordtypes.size()-1);
        }
        return recordtypes;
      }

      public void submit() {

      }
}