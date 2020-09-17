/*    $Id: SB_NameCard_AccountRegistController.cls 17 2014-03-17 02:09:52Z ume $    */
/*
 * SB_NameCard_AccountRegistController
 *  
 * SV_DEV-607  Classic画面で名刺登録を「言語：英語」（英語表示）の状態で登録した場合にレコードタイプ設定のラベル名変更が反映されない
 * SV_DEV-684 部署名に全角バックスラッシュが含まれる名刺を自動連携すると、ORA-01424エラーが発生する
 * 名刺情報から取引先・取引先責任者の登録
 * @author gao
 * @Version 1.20.1  2017.8.XX SV_DEV-533  取引先・取引先責任者登録画面の無効化状態での文字の表示（灰色にならない）
 * @Version 1.22 2017.10.XX SV_DEV-607  Classic画面で名刺登録を「言語：英語」（英語表示）の状態で登録した場合にレコードタイプ設定のラベル名変更が反映されない
 * @Version 1.22 2017.11.XX SV_DEV-684  部署名に全角バックスラッシュが含まれる名刺を自動連携すると、ORA-01424エラーが発生する
 * @Version 1.22 2018.02.xx SV_DEV-781  個別取引先登録 で 既存の アカウント、コンタクトを選択していても、「新規作成時の指定」の所有者をしていしていないとエラーになる。
 * @Version 2.0.4   2019.02.xx SV_DEV-1514 英訳ミス対応に伴いページタイトルの英語化対応を実施。
 * 
 * KDDI向け 取引先LDV対応 名刺情報から取引先・取引先責任者の登録 の履歴
 * @Version 1      2018.01.xx
 * @Version 2      2018.02.xx  上限を超えたときメッセージを表示する。 sawano
 * @Version 3      2018.03.xx  テスト用にメッセージ用のステータスを保持 sawano
 * 
 * @Version 2.4  2019.07.xx sawano SV_DEV-1355 取引先・取引先責任者に登録（個別/一括_Classic）で参照権限がない場合に登録先候補がでないようにしてほしい。 
 * 
 * Copyright (c) 2017-2019 SunBridge Inc.
 *
 */
public with sharing class SB_NameCard_AccountRegistController
{
  private static String CREATE_ACCOUT = String.format(System.Label.SB_NC_NewAccountDEV, new String[]{ Account.sObjectType.getDescribe().getLabel() });
  private static String CREATE_CONTACT = String.format(System.Label.SB_NC_NewContactDEV, new String[]{ Contact.sObjectType.getDescribe().getLabel() });
  private static final List<RecordTypeInfo> ACNT_RECORDTYPES = SB_NameCard_AccountRegistController.getRecordType(Account.sObjectType);
  private static final List<RecordTypeInfo> CONT_RECORDTYPES = SB_NameCard_AccountRegistController.getRecordType(Contact.sObjectType);

  public class SB_NameCard_AccountRegistControllerException extends Exception {}

  public String queryProcessMessage { get; private set; }          // 2018.02.xx

  @TestVisible
  private SB_NameCard_RegistCanPickerAbstract.QueryProcess accoutQueryProcess;          // 2018.03.xx
  // 取引先テーブル
  public class AccountRecord {
    public Integer index { get; set; }           //インデクス
    public Boolean showLookUpAccount { get; set; }   //取引先参照フラグ
    public Boolean showLookUpContact { get; set; }   //取引先責任者参照フラグ
    public ID accountId { get; set; }            //取引先ID
    public ID contactId { get; set; }            //取引先責任者ID
    public String accountName { get; private set; }      //取引先名
    public String accountOwner { get; private set; }     //取引先所有者
    public String division { get; private set; }         //部署
    public String contactName { get; private set; }      //取引先責任者名
    public String contactOwner { get; private set; }     //取引先責任者所有者
    public String state { get; private set; }            //
    public String title { get; private set; }            //取引先責任者役職
    public String mobile { get; private set; }           //取引先責任者携帯
    public String email { get; private set; }            //メールアドレス
    public Datetime lastModifiedDate { get; private set; }//最終更新日

    //レコードタイプ
    public String acntRecTypeID{get;set;}          //取引先レコードタイプID
    public String contRectypeID{get;set;}          //取引先責任者レコードタイプID

    public AccountRecord(Integer index, Contact c) {
      this.index = index;
      this.showLookUpAccount = false;
      this.showLookUpContact = false;
      this.accountId = c.AccountId;
      this.contactId = c.Id;
      this.accountName = c.Account.Name;
      this.accountOwner = c.Account.Owner.Name;
      this.division = c.Department;
      this.contactName = c.Name;
      this.contactOwner = c.Owner.Name;
      this.state = c.MailingState;
      this.title = c.Title;
      this.mobile = c.MobilePhone;
      this.email = c.Email;
      this.lastModifiedDate = c.LastModifiedDate;
    }

    public AccountRecord(Integer index, Account acc) {
      this.index = index;
      this.showLookUpAccount = false;
      this.showLookUpContact = false;
      this.accountId = acc.Id;
      this.accountName = acc.Name;
      this.accountOwner = acc.Owner.Name;
      this.division = acc.Site;
      this.contactName  = CREATE_CONTACT;
      this.state = acc.BillingState;
      this.lastModifiedDate = acc.LastModifiedDate;
    }

    public AccountRecord(Integer index, Boolean lookUpAccount, Boolean lookUpContact) {
      this.index = index;
      this.showLookUpAccount = lookUpAccount;
      this.showLookUpContact = lookUpContact;
      if (lookUpAccount) {
          this.contactName = CREATE_CONTACT;
      }
    }

    public AccountRecord(Integer index) {
      this.index = index;
      this.showLookUpAccount = false;
      this.showLookUpContact = false;
      this.accountName = CREATE_ACCOUT;
      this.contactName = CREATE_CONTACT;
    }

  } // AccountRecord

  public Boolean debug { get; set; }
  public NameCard__c nameCard { get; set; } // 名刺
  public NameCard__c lookUpAccount { get; set; } // ルックアップ(取引先)
  public Account lookUpContactAccount { get; set; } // ルックアップ(取引先責任者の取引先)
  public NameCard__c lookUpContact { get; set; } // ルックアップ(取引先責任者)

  public Integer searchType { get; set; } // 検索条件

  public Integer accountTableIndex { get; set;} // 取引先テーブルIndex
  public List<AccountRecord> accountTable { get; set; } // 取引先テーブル
  public Boolean accountOverwrite { get; set; } // 取引先を上書き
  public Boolean contactOverwrite { get; set; } // 取引責任者を上書き

  public Account owner { get; set; } // 新規作成時の指定(所有者)
  public Task todo { get; set; } // ToDo(活動)
  public boolean registTodo { get; set; } // ToDo(活動)登録

  public Boolean dispAccountOwner { get; private set; }//取引先所有者表示
  public Boolean dispContactOwner { get; private set; }//取引先責任者所有者表示
  public Boolean dispState { get; private set; }//都道府県表示
  public Boolean dispTitle { get; private set; }//役職表示
  public Boolean dispMail { get; private set; }//メールアドレス表示
  public Boolean dispLastModifiedDate { get; private set; }//最終更新日表示
  public Boolean dispMobile { get; private set; }//携帯電話表示

  public Boolean isAllowDuplicateSave { get;  set; }//アラート無視保存
  public Boolean dispDuplicateCheck { get; set; }

  // public Boolean isFullCompanyNameForSearch { get; set; } // 商号あり会社名
  // public String accountOwnerstr{get;set;}
  // public String contactOwnerstr{get;set;}

  // public String  accountRegistController{get;set;}//表示ラベル
  public String  rulesOfCreate{get;set;}
  public String  accountOwnerlabel{get; private set;}//取引先(所有者)
  public String  contactOwnerlabel{get; private set;}//取引先責任者(所有者)
  public String  registerToContact{get; private set;}//取引先。取引先責任者に登録
  public String  updateForContact{get; private set;}//既存の取引先の情報を名刺情報で上書きする
  public String  updateForAccount{get; private set;}//既存の取引先責任者の情報を名刺情報で上書きする
  public String  recordTypeExplain{get; private set;}//新規作成の場合、レコードタイプを選択します。
  public String  accountRecTypeId{get; set;}//選んだの取引先レコードタイプ
  public String  contactRecTypeId{get; set;}//選んだの取引先責任者レコードタイプ
  public String  accountRecType{get; private set;}//取引先レコードタイプの表示ラベル
  public String  contactRecType{get; private set;}//取引先責任者レコードタイプの表示ラベル
  public Boolean accountRecTypeEdit{get; private set;}//取引先レコードタイプ編集不可
  public Boolean contactRecTypeEdit{get; private set;}//取引先責任者レコードタイプ編集不可
  public Boolean showAccountRecType{get; private set;}//取引先レコードタイプ表示するか
  public Boolean showContactRecType{get; private set;}//取引先責任者レコードタイプ表示するか
  public Boolean showRecTypeSectionItem{get; private set;}//レコードタイプのSectionItemを表示するか
  public Boolean cannotUpdataAccount{get; private set;}//取引先更新不可フラグ
  public Boolean cannotUpdataContact{get; private set;}//取引先責任者更新不可フラグ
  public String  cannotUseStyleAcc{get; private set;}//取引先上書き表示ラベルCSS
  public String  cannotUseStyleCon{get; private set;}//取引先責任者上書き表示ラベルCSS
  public Boolean showUpdate{get; private set;}//基本設定上書き表示
  public Boolean showUpdateAccount{get; private set;}//基本設定 既存の取引先を名刺情報で上書きする」を表示する
  public Boolean showUpdateContact{get; private set;}//「既存の取引先責任者を名刺情報で上書きする」を表示する
  public String windowTitle { get; private set; }  // v2.0.4 Windowタイトル
  public Boolean enableOperation { get; private set; } // v2.4 登録する権限揃ってる。

  // 名刺基本設定
  private static NameCardBasicSetting__c basesetting {
    get {
      if (basesetting == null) {
        basesetting = SB_NameCard_BasicSetting.getNameCardBasicSetting();
      }
      return basesetting;
    } 
    private set;
  }
  // カスタム設定
  private static SmartViscaConfig__c smartViscaConfig {
    get {
      if (smartViscaConfig == null){
        smartViscaConfig = SmartViscaConfig__c.getInstance(UserInfo.getUserId()); // 個人の設定
        if (smartViscaConfig.Id ==null) {
          smartViscaConfig = SmartViscaConfig__c.getInstance(UserInfo.getProfileId()); //プロファイルの設定
        }
        if (smartViscaConfig.id == null) {
          smartViscaConfig = SmartViscaConfig__c.getOrgDefaults(); // 組織の設定
        }
        if (smartViscaConfig.id == null) {
          smartViscaConfig.DispAccountOwner__c = true;
          smartViscaConfig.DispContactOwner__c = true;
          smartViscaConfig.DispState__c = true;
          smartViscaConfig.DispTitle__c = true;
          smartViscaConfig.DispMail__c = true;
          smartViscaConfig.DispLastModifiedDate__c = true;
          smartViscaConfig.DispMobile__c = true;
        }
        smartViscaConfig.ToDoName__c = String.isBlank(smartViscaConfig.ToDoName__c) ? System.Label.SB_NC_ExchangeCard : smartViscaConfig.ToDoName__c;
    }
      return smartViscaConfig;
    }
    private set;
  }

  // 変数
  private Id ncId;      // 処理対象の名刺レコードID
  // public ScreenData screenData { get; private set; }
  // public OperaionReport opeReport { get; private set; } // 登録先候補テーブルの内訳
  // public List<CandidateRecord> candidateTable { get; private set; } // 登録先候補テーブル
  public Integer searchMethod { get; set; }   // 検索方法
  //public Integer searchField { get; set; }  // 検索条件の項目
  public Integer queryMatch { get; set; }   // 完全一致もする？
  // @TestVisible private static final Integer SEARCHTYPE_NAME_SITE = 0;  // 検索条件の項目
  // @TestVisible private static final Integer SEARCHTYPE_NAME = 1;
  // @TestVisible private static final Integer SEARCHTYPE_DEFAULT = SEARCHTYPE_NAME_SITE;    // 検索方法のデフォルト値
  @TestVisible private static final Integer SEARCHMETHOD_OLD = 0;    // SB_Sv_UiRegistSoqlTwiceCanCreater
  @TestVisible private static final Integer SEARCHMETHOD_SOSL = 1;    // SB_Sv_UiRegistSoslSoqlCanCreater
  @TestVisible private static final Integer SEARCHMETHOD_SOQL_COUNT = 2;    // SB_Sv_UiRegistSoqlCountCanCreater
  @TestVisible private static final Integer SEARCHMETHOD_SOQL_RELATIONQ = 3;    // SB_Sv_UiRegistAccountRelCanCreater
  @TestVisible private static final Integer SEARCHMETHOD_DEFAULT = SEARCHMETHOD_SOSL;
  @TestVisible private static final Integer QUERY_PERFECT_NO = 0;  //
  @TestVisible private static final Integer QUERY_PERFECT = 1;   // 完全一致もする

  //取引先責任者レコードタイプOption取得
  public List<SelectOption> getContRecTypeSelectOpts() {
    List<SelectOption> options = new List<SelectOption>();
    //options.add(new SelectOption('', ''));
    for (RecordTypeInfo r : CONT_RECORDTYPES) {
      options.add(new SelectOption(r.getRecordTypeId(), r.getName()));
    }
    return options;
  }

  //取引先レコードタイプOption取得
  public List<SelectOption> getAccRecTypeSelectOpts() {
    List<SelectOption> options = new List<SelectOption>();
    //options.add(new SelectOption('', ''));
    for (RecordTypeInfo r : ACNT_RECORDTYPES) {
      options.add(new SelectOption(r.getRecordTypeId(), r.getName()));
    }
    return options;
  }

  public boolean getIsShowOwnerSelector() {
    return Schema.SObjectType.Account.isCreateable() || Schema.SObjectType.Contact.isCreateable();
  }

  // コンストラクタ
  public SB_NameCard_AccountRegistController() {
    this.enableOperation = false;
    String accstr = SB_NameCard_AccountRegistController.defaultRecordType(Account.sObjectType);

    String constr = SB_NameCard_AccountRegistController.defaultRecordType(Contact.sObjectType);
    if (System.currentPageReference().getParameters().containsKey('searchMethod')) {
      this.searchMethod = Integer.valueof(System.currentPageReference().getParameters().get('searchMethod'));
    }
    else {
      this.searchMethod = SEARCHMETHOD_DEFAULT;
    }

    this.queryMatch = QUERY_PERFECT;

    //既存の取引先を名刺情報で上書きする」を表示する
    this.showUpdateAccount = basesetting.RegistDispAccountOverWriteCheckbox__c; 
    //既存の取引先責任者を名刺情報で上書きする」を表示する
    this.showUpdateContact = basesetting.RegistDispContactOverWriteCheckbox__c;
    this.showUpdate = this.showUpdateAccount || this.showUpdateContact;
    this.cannotUpdataAccount = !Account.sObjectType.getDescribe().isUpdateable();

    // this.opeReport = new OperaionReport();

    this.recordTypeExplain = System.Label.SB_NC_RecordTypeExplain;  // todo

    this.cannotupdataAccount = !Account.sObjectType.getDescribe().isUpdateable();

    this.accountOverwrite = false;

    this.cannotUseStyleAcc = '';

    if(this.cannotUpdataAccount)
    {
      this.cannotUseStyleAcc = 'color:#999999;';
    }

    this.cannotUpdataContact = !Contact.sObjectType.getDescribe().isUpdateable();

    this.contactOverwrite = false;

    this.cannotUseStyleCon = '';

    if (this.cannotUpdataContact) {
      this.cannotUseStyleCon = 'color:#999999;';
    }

    this.accountRecTypeEdit = !Account.sObjectType.getDescribe().isCreateable() || ACNT_RECORDTYPES.isEmpty();

    this.contactRecTypeEdit = !Contact.sObjectType.getDescribe().isCreateable() || CONT_RECORDTYPES.isEmpty();

    this.accountRecTypeId = String.isBlank(accstr) ? 'nano' : accstr;

    this.contactRecTypeId = String.isBlank(constr) ? 'nano' : constr;
    //  SV_DEV-605, SV_DEV-607
    //  取引先レコードタイプ Classic画面で名刺登録を「言語：英語」（英語表示）の状態で登録した場合にレコードタイプ設定のラベル名変更が反映されない
    this.accountRecType = String.format(System.Label.SB_NC_AccRecType,new String[]{ Account.sObjectType.getDescribe().getLabel(), System.Label.SB_NC_RecType });
    //  取引先責任者レコードタイプ
    this.contactRecType = String.format(System.Label.SB_NC_CntRecType,new String[]{ Contact.sObjectType.getDescribe().getLabel(), System.Label.SB_NC_RecType });
    //  新規作成の場合、レコードタイプを選択します。 
    this.recordTypeExplain = String.format(System.Label.SB_NC_RecordTypeExplain, new String[]{ Account.sObjectType.getDescribe().getLabel(), Contact.sObjectType.getDescribe().getLabel() });
    //ラベル:取引先 (所有者)
    this.accountOwnerlabel = String.format(System.Label.SB_NC_AccountOwnerDEV,new String[]{Account.sObjectType.getDescribe().getLabel()});
    //ラベル:取引先責任者 (所有者)
    this.contactOwnerlabel = String.format(System.Label.SB_NC_ContactOwnerDEV,new String[]{Contact.sObjectType.getDescribe().getLabel()});
    //ラベル:取引先・取引先責任者に登録
    this.registerToContact = String.format(System.Label.SB_NC_RegisterToContactDEV,new String[]{Account.sObjectType.getDescribe().getLabel(), Contact.sObjectType.getDescribe().getLabel()});
    //ラベル:既存の取引先の情報を名刺情報で上書きする
    this.updateForAccount = String.format(System.Label.SB_NC_UpdateforAccountDEV,new String[]{Account.sObjectType.getDescribe().getLabel()});
    //ラベル:既存の取引先責任者の情報を名刺情報で上書きする
    this.updateForContact = String.format(System.Label.SB_NC_UpdateforContactDEV,new String[]{Contact.sObjectType.getDescribe().getLabel()});
    //ラベル:新規作成時の指定
    this.rulesOfCreate = String.format(System.Label.SB_NC_RulesOfCreate,new String[]{ Account.sObjectType.getDescribe().getLabel(), Contact.sObjectType.getDescribe().getLabel() });

    SmartViscaConfig__c smartViscaConfig;
    smartViscaConfig = SmartViscaConfig__c.getInstance(UserInfo.getUserId()); // 個人の設定

    if (smartViscaConfig.Id ==null) {
      smartViscaConfig = SmartViscaConfig__c.getInstance(UserInfo.getProfileId()); //プロファイルの設定
    }

    if (smartViscaConfig.id == null) {
      smartViscaConfig = SmartViscaConfig__c.getOrgDefaults(); // 組織の設定
    }

    if (basesetting == null) {
      this.showAccountRecType = ACNT_RECORDTYPES.size() > 1;
      this.showContactRecType = CONT_RECORDTYPES.size() > 1;
    }
    else{
      this.showAccountRecType = basesetting.RegistDispAccountRectype__c && ACNT_RECORDTYPES.size() > 1;
      this.showContactRecType = basesetting.RegistDispContactRectype__c && CONT_RECORDTYPES.size() > 1;
    }

    this.showRecTypeSectionItem = this.showAccountRecType || this.showContactRecType;
    // Boolean caccount = Schema.SObjectType.Account.isCreateable();
    // Boolean ccontact = Schema.SObjectType.Contact.isCreateable();
    // this.isShow = caccount == true || ccontact == true;
    String s = System.currentPageReference().getParameters().get('debug');
    if (String.isNotBlank(s) && (s.equals('1') || s.toUpperCase().equals('TRUE'))) {
      this.debug = true;
    }
    else {
      this.debug = false;
    }
    String ncId = System.currentPageReference().getParameters().get('id');

    System.debug('SB_NameCard_AccountRegistController: ncId: ' + ncId);

    try {

      this.setDisplayFlg();

      if (!this.dispAccountOwner) {
        this.accountOwnerlabel = Account.sObjectType.getDescribe().getLabel();
      }
      if (!this.dispContactOwner) {
        this.contactOwnerlabel = Contact.sObjectType.getDescribe().getLabel();
      }
      // デフォルトチェックはカスタム設定から取得
      if (smartViscaConfig.id == null) {
        this.searchType = SB_NameCard_Util.SEARCHTYPE_NAME_SITE;
      } 
      else if (smartViscaConfig.AccountSearchType__c == null) {
        this.searchType = SB_NameCard_Util.SEARCHTYPE_NAME_SITE;
      } 
      else {
        this.searchType = smartViscaConfig.AccountSearchType__c ? SB_NameCard_Util.SEARCHTYPE_NAME : SB_NameCard_Util.SEARCHTYPE_NAME_SITE;
      }

      // クエリパラメータにあったら、それを優先
      String searchT = System.currentPageReference().getParameters().get('searchType');
      this.searchType = String.isBlank(searchT) ? this.searchType : Integer.valueof(searchT);

      // this.isFullCompanyNameForSearch = false;

      if (String.isBlank(ncId)) {
          throw new SB_NameCard_AccountRegistControllerException(System.Label.SB_MSG_IdMissing);
      }
      this.lookUpAccount = new NameCard__c();
      this.lookUpAccount.Id = ncId;
      this.lookUpContactAccount = new Account();
      this.lookUpContact = new NameCard__c();
      this.lookUpContact.Id = ncId;
      this.owner = new Account();
      this.accountTable = new List<AccountRecord>();
      this.accountTableIndex = -1;

      if (!cannotUpdataAccount) {
        // デフォルトチェックはカスタム設定から取得
        if (basesetting == null){
          this.accountOverwrite = true;
        }
        else {
          this.accountOverwrite = !basesetting.RegistAccountNotOverWrite__c;
        }
      }

      if (!cannotUpdataContact) {
        if (basesetting == null) {
          this.contactOverwrite = true;
        } else {
          this.contactOverwrite = !basesetting.RegistContactNotOverWrite__c;
        }
      }

      String str = basesetting.RegistToDoSubject__c;
      System.debug(str);
      if (String.isBlank(str)){
        str = System.Label.SB_NC_ExchangeCard;
      }
      this.todo = new Task(Subject=str);

      this.registTodo = !basesetting.RegistNoToDo__c; // ToDo(活動)登録

      if ((this.nameCard = this.getNameCard(ncId)) != null) {
        // v2.4 SV_DEV-1355 取引先・取引先責任者に登録（個別/一括_Classic）で参照権限がない場合に登録先候補がでないようにしてほしい。
        if (!Account.sObjectType.getDescribe().isAccessible() || !Contact.sObjectType.getDescribe().isAccessible()) {
          throw new SB_NameCard_AccountRegistControllerException(System.Label.SB_NC_MSG_INSUFFICIENT_ACCESS);
        }
        // 登録実績有り
        ////    アカウント上書きする?  権限とか設定がTRUE で 上書き不可がFALSE なら TRUE 、アカウント参照項目のNOT NULL はみない 2017.02.15
        //this.accountOverwrite = this.accountOverwrite && !this.nameCard.isNotOverwrite__c;
        ////    コンタクト上書きする?  権限とか設定がTRUE で 上書き不可がFALSE なら TRUE 、コンタクト参照項目のNOT NULL はみない 2017.02.15
        //this.contactOverwrite = this.contactOverwrite && !this.nameCard.isNotOverContactwrite__c;
        //名刺所有者がユーザの場合画面上表示するの所有者にデフォルト値を設定
        if (String.valueOf(this.nameCard.OwnerId).startsWith('005')) {
          this.owner.OwnerId = this.nameCard.OwnerId; // 所有者
        } else {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.SB_NC_MSG_NAMECARD_OWNER_QUEUE));
        }
        this.todo.ActivityDate = this.nameCard.card_exchange_date__c; // 期日
        this.todo.Description = this.nameCard.freehandmemo__c; // コメント

        Map<String, String> pnMap = SB_NameCard_Util.getPersonName(nameCard);

        if (nameCard.company_name__c == null || String.isBlank(pnMap.get('last_name'))){
          throw new SB_NameCard_AccountRegistControllerException(System.Label.SB_MSG_CompanyNameMissing);
        }
        // Windowタイトル v2.0.4
        String titleForm = '{2}: '+ Label.SB_NC_RegisterToContactDEV;
        this.windowTitle = String.format(titleForm,
              new String[] { Account.getSobjectType().getDescribe().getLabel(),
                              Contact.getSobjectType().getDescribe().getLabel(),
                              NameCard__c.getSobjectType().getDescribe().getLabel() });

        // this.setAccountTable(this.nameCard, this.accountTable);
        buildCandidateTable();
        this.enableOperation = true;
      } 
      else {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.SB_MSG_CardNotFound));
      }
    } catch (Exception e) {
      ApexPages.addMessages(e);
    }
  }

  // selectOptions 取引先検索条件
  public List<SelectOption> getSearchTypeSelectOpts(){
    List<SelectOption> opts = new List<SelectOption>();
    //ラベル:取引先名と所属名で検索
    String str = String.format(System.Label.SB_NC_SearchForAccountAndDepartmentDEV, new String[]{ Account.sObjectType.getDescribe().getLabel() });
    opts.add(new SelectOption(String.valueOf(SB_NameCard_Util.SEARCHTYPE_NAME_SITE), str));
    //ラベル:取引先名のみで検索
    String str1 = String.format(System.Label.SB_NC_SearchForAccountDEV, new String[]{ Account.sObjectType.getDescribe().getLabel() });
    opts.add(new SelectOption(String.valueOf(SB_NameCard_Util.SEARCHTYPE_NAME), str1));

    return opts;
  }

  public void checkradio(Integer index){
    System.debug(index);
  }
  public void checkradio(){
    AccountRecord acc = this.accountTable[this.accountTableIndex];

    if (Account.sObjectType.getDescribe().isCreateable()) {
      this.accountRecTypeEdit = String.isNotBlank(acc.accountId) || acc.showLookUpAccount || acc.showLookUpContact || ACNT_RECORDTYPES.size() < 1;
    }

    if (Contact.sObjectType.getDescribe().isCreateable()) {
      this.contactRecTypeEdit = String.isNotBlank(acc.contactId) || acc.showLookUpContact || CONT_RECORDTYPES.size() < 1;
    }
  }

  // 表示設定
  private void setDisplayFlg()
  {
//        Map<String, SmartViscaSetting__c> svs = SmartViscaSetting__c.getAll();
    SmartViscaConfig__c smartViscaConfig = SmartViscaConfig__c.getOrgDefaults();

//        if (svs.size() <= 0) {
    if (smartViscaConfig.id == null)
    {
      this.dispAccountOwner = true;
      this.dispContactOwner = true;
      this.dispState = true;
      this.dispTitle = true;
      this.dispMail = true;
      this.dispLastModifiedDate = true;
      this.dispMobile = true;
    }
    else
    {
//            for (String key : svs.keySet()) {
      this.dispAccountOwner = smartViscaConfig.DispAccountOwner__c;
      this.dispContactOwner = smartViscaConfig.DispContactOwner__c;
      this.dispState = smartViscaConfig.DispState__c;
      this.dispTitle = smartViscaConfig.DispTitle__c;
      this.dispMail = smartViscaConfig.DispMail__c;
      this.dispLastModifiedDate = smartViscaConfig.DispLastModifiedDate__c;
      this.dispMobile = smartViscaConfig.DispMobile__c;
//            }
    }
  }

  // 名刺
  private NameCard__c getNameCard(String id)
  {
    NameCard__c sobj = null;

    List<NameCard__c> sobjList = [SELECT
        Id, Name, OwnerId,
        account__c, account__r.Name, account__r.Owner.Name,
        contact__c,
        company_name__c, company_name_kana__c, division__c, title_name__c,
        person_name_last__c, person_name_first__c, last_name__c, first_name__c,
        email__c, tel1__c, fax1__c, mobile__c,
        zip_code__c, address_pref__c, address__c, address_bld__c, address_eng__c,
        web_url1__c, freehandmemo__c, card_exchange_date__c, list_name__c, memo__c, isNotOverwrite__c
        ,isNotOverContactwrite__c
        FROM NameCard__c WHERE Id = :id AND IsDeleted = false];

    if (sobjList.size() > 0) 
      sobj = sobjList[0];
    return sobj;
  }

  private void buildCandidateTable() {
    SB_NC_RegistQueryOption accountQueryOption = new SB_NC_RegistQueryOption(Account.getSObjectType());
    SB_NC_RegistQueryOption contactQueryOption = new SB_NC_RegistQueryOption(Contact.getSObjectType());
    accountQueryOption.queryDept = (this.searchType == SB_NameCard_Util.SEARCHTYPE_NAME_SITE);    // 所属を検索する。
    accountQueryOption.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.PartialMatch;
    accountQueryOption.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;
    accountQueryOption.forceSoql = this.searchMethod == SEARCHMETHOD_SOQL_COUNT;  // SOQL強制？
    accountQueryOption.acntRecTypeIds = SB_NameCard_BasicSetting.registAccountQueryRecordTypeIds;
    accountQueryOption.contRecTypeIds = SB_NameCard_BasicSetting.registContactQueryRecordTypeIds;
    // accountQueryOption.queryOnlyEMail = true;
    contactQueryOption.queryDept = (this.searchType == SB_NameCard_Util.SEARCHTYPE_NAME_SITE);    // 所属を検索する。
    contactQueryOption.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.PartialMatch;
    contactQueryOption.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;
    contactQueryOption.queryEMail = true;
    contactQueryOption.queryOnlyEMail = true;
    contactQueryOption.queryFirstName = true;
    contactQueryOption.queryLastName  = true;
    contactQueryOption.acntRecTypeIds = SB_NameCard_BasicSetting.registAccountQueryRecordTypeIds;
    contactQueryOption.contRecTypeIds = SB_NameCard_BasicSetting.registContactQueryRecordTypeIds;
    // 条件にあわせて適切な検索ロジッククラスを生成
    SB_NameCard_RegistCanPickerAbstract picker = 
        SB_NameCard_RegistCanPickerAbstract.createCandidatePicker(
          new List<SB_NC_RegistQueryOption> { accountQueryOption, contactQueryOption }, 
          new Set<Id> { this.nameCard.Id } );
    Map<Id, Map<SObjectType, List<SObject>>>id2otype2objs = picker.create();
    Map<SObjectType, List<SObject>> otype2SObjects = id2otype2objs.get(this.nameCard.Id);

    // クエリで上限を超えたときメッセージを得る
    this.queryProcessMessage = picker.getQueryProcessComment();          // 2018.02.xx
    this.accoutQueryProcess = picker.getAccountQueryProcess(); // 2018.03.xx
    // テーブルへ追加してく。
    this.accountTable.clear();  // クリアしてから
    // 1. コンタクトの候補
    if (otype2SObjects.containsKey(Contact.sObjectType)) {
      addContact2Table((List<Contact>)otype2SObjects.get(Contact.sObjectType));
    }
    // 2. アカウントの候補
    if (picker.isRelationQuery()) {
      // Accountのクエリで Contactをリレーションクエリしてるとき、アカウント単位に コンタクトからテーブルに追加
      addAccountContact2Table((List<Account>)otype2SObjects.get(Account.sObjectType));
    }
    else {
      if (otype2SObjects.containsKey(Account.sObjectType) && Schema.SObjectType.Contact.isCreateable()) {
        // 既存取引先＋新規取引先責任者 をテーブルへ追加
        addAccount2Table((List<Account>)otype2SObjects.get(Account.sObjectType));
      }
    }
    // 3: 既存取引先責任者ルックアップ
    this.accountTable.add(new AccountRecord(this.accountTable.size(), false, true));
    // 4: 既存取引先ルックアップ+新規取引先責任者
    if (Schema.SObjectType.Contact.isCreateable()) {
      this.accountTable.add(new AccountRecord(this.accountTable.size(), true, false));
    }
    // 5: 新規取引先+新規取引先責任者
    if (Schema.SObjectType.Account.isCreateable() && Schema.SObjectType.Contact.isCreateable()) {
      this.accountTable.add(new AccountRecord(this.accountTable.size()));
    }
    // 処理レポートの確定
    // this.opeReport.finalize(method.getOperations());
  }

  // Contact をテーブルへ追加
  private void addContact2Table(List<Contact> conts) {
    for (Contact cont : conts) {
      // 0: 既存取引先+既存取引先責任者
      this.accountTable.add(new AccountRecord(this.accountTable.size(), cont));
      // this.opeReport.plusContact();
    }
  }

  // Account をテーブルへ追加
  private void addAccount2Table(List<Account> acnts) {
    for (Account acnt : acnts) {
      //// 1: 既存取引先+既存取引先責任者ルックアップ
      // this.accountTable.add(new AccountRecord(this.accountTable.size(), acnt));
      // 2: 既存取引先+新規取引先責任者
      this.accountTable.add(new AccountRecord(this.accountTable.size(), acnt));
      // this.opeReport.plusAccount();
    }
  }

  // 表示する候補のレコード数
  @TestVisible
  private Integer getTableThreshold() {
    if (Schema.SObjectType.Contact.isCreateable()) {
      return 997;
    }
    return 998;
  }

  // Accountのクエリで Contactをリレーションクエリしてるとき、アカウント単位に コンタクトからテーブルに追加
  private void addAccountContact2Table(List<Account> acnts) {
    for (Account acnt : acnts) {
      List<Contact> conts = (List<Contact>)acnt.getSObjects('Contacts');
      // CanCreaterの中では アカウントの数チェックしていないので、コンタクトが多いいのはここで調べます。
      if (conts != null && !conts.isEmpty()) {
          if (this.accountTable.size() + conts.size() > getTableThreshold()) {
              this.accountTable.clear();
              break;
          }
        // COntact をテーブルへ追加
        // 0: 既存取引先+既存取引先責任者
        addContact2Table(conts);
      }
      //// 1: 既存取引先+既存取引先責任者ルックアップ
      //this.candidateTable.add(new AccountCandidate(this.candidateTable.size(), acnt, true));
      // 2: 既存取引先+新規取引先責任者
      if (Schema.SObjectType.Contact.isCreateable()) {
        this.accountTable.add(new AccountRecord(this.accountTable.size(), acnt));
        // this.opeReport.plusAccount();
      }
    }
  }


  // 検索
  public PageReference search()
  {
    try {
      this.accountTable.clear();
      this.accountTableIndex = -1;
      // this.setAccountTable(this.nameCard, this.accountTable);
      buildCandidateTable();
    }
    catch (Exception e) {
      ApexPages.addMessages(e);
    }
    return null;
  }

  // ルックアップ設定
  public PageReference setLookUp(){
    try {
      for (Account acc : [SELECT Id, Name, Owner.Name FROM Account
                          WHERE Id IN (SELECT AccountId FROM Contact 
                          WHERE Id = :this.lookUpContact.contact__c AND IsDeleted = false) 
                          AND IsDeleted = false]) {
        this.lookUpContactAccount = acc;
      }
    }
    catch (Exception e) {
      ApexPages.addMessages(e);
    }
    return null;
  }

  // 保存
  public PageReference save(){

    try {
      AccountRecord accRec;
      //System.debug('save: accountTable: size: ' + this.accountTable.size() + ' index: ' + this.accountTableIndex);

      if (this.accountTableIndex >= 0) {
        accRec = this.accountTable[this.accountTableIndex];
      } else {
        throw new SB_NameCard_AccountRegistControllerException(System.Label.SB_MSG_SelectDestination);
      }
      if (accRec == null) {
        throw new SB_NameCard_AccountRegistControllerException(System.Label.SB_MSG_SelectCorrectDestination);
      }
      Account acc;
      Contact c;

      if (!this.accountRecTypeEdit) {
        acc = (Account)Account.sObjectType.newSObject(this.accountRecTypeId, false);
        acc.put('RecordTypeId',this.accountRecTypeId);
      } else {
        acc = (Account)Account.sObjectType.newSObject(null, false);
      }

      if (!this.contactRecTypeEdit) {
        c = (Contact)Contact.sObjectType.newSObject(this.contactRecTypeId, false);
        c.put('RecordTypeId',this.contactRecTypeId);
      } else {
        c = (Contact)Contact.sObjectType.newSObject(null, false);
      }
      //ラベル:取引先を入力してください
      String straccount = String.format(System.Label.SB_MSG_EnterAccountDEV,new String[]{ Account.sObjectType.getDescribe().getLabel() });
      //ラベル:取引先責任者を入力してください
      String strcontact = String.format(System.Label.SB_MSG_EnterContactDEV,new String[]{ Contact.sObjectType.getDescribe().getLabel() });

      if (accRec.showLookUpAccount) {
        if (this.lookUpAccount.account__c == null) {
          throw new SB_NameCard_AccountRegistControllerException(straccount);
        }

        acc.Id=this.lookUpAccount.account__c;
        //c = new Contact();
      } else if (accRec.showLookUpContact) {
        if (this.lookUpContact.contact__c == null) {
          throw new SB_NameCard_AccountRegistControllerException(strcontact);
        }

        acc.Id = this.lookUpContactAccount.Id;
        c.Id=this.lookUpContact.contact__c;
      } else{
        if (!String.isBlank(accRec.accountId)) {
          acc.Id=accRec.accountId;
        }
        if (!String.isBlank(accRec.contactId)) {
          c.Id=accRec.contactId;
        }
      }
      c.AccountId = acc.Id;
      if (this.accountRecTypeEdit) {
        this.accountRecTypeId = null;
      }
      // SV_DEV-781  個別取引先登録 で 既存の アカウント、コンタクトを選択していても、「新規作成時の指定」の所有者をしていしていないとエラーになる。
      if ((String.isBlank(acc.Id) || String.isBlank(c.Id)) && String.isBlank(this.owner.OwnerId)) {
        throw new SB_NameCard_AccountRegistControllerException(System.Label.SB_NC_SpecifyOwnerWhenCreateAcCo);
      }
      SB_NC_RegistExecutor.RegistParam acre = new SB_NC_RegistExecutor.RegistParam('Account',this.accountOverwrite,this.accountRecTypeId,acc.Id == null ? this.owner.OwnerId : acc.OwnerId,this.isAllowDuplicateSave);

      if (this.contactRecTypeEdit) {
        this.contactRecTypeId = null;
      }
      SB_NC_RegistExecutor.RegistParam conre = new SB_NC_RegistExecutor.RegistParam('Contact',this.contactOverwrite,this.contactRecTypeId,c.Id == null ? this.owner.OwnerId : c.OwnerId,this.isAllowDuplicateSave);

      SB_NC_RegistExecutor.TodoParam todo = new SB_NC_RegistExecutor.TodoParam(this.todo.Subject,this.todo.ActivityDate,this.todo.Description,null);

      System.debug(this.registTodo + 'nid ' + ' ' +  this.nameCard.Id + 'aid ' + acc.Id + 'cid' + c.Id);
      SB_NC_RegistExecutor.RegistTarget tar = new SB_NC_RegistExecutor.RegistTarget(this.nameCard.Id,acc.Id,c.Id,null,this.registTodo,this.todo.ActivityDate);
      System.debug(acre);
      System.debug(conre);
      System.debug(tar);
      SB_NC_RegistExecutor.RegistRequest re = new SB_NC_RegistExecutor.RegistRequest(new List<SB_NC_RegistExecutor.RegistTarget>{tar},acre,conre,null,todo);
      //doRegist内既にrollbackしていますので、ここは二度目はしません
      SB_NC_RegistExecutor.RegistResponse result = SB_NC_RegistExecutor.doRegist(re);
      if (result.success == false) {
        System.debug(result.title);
        System.debug(result.errorObject);
        System.debug(result.message);
        System.debug(result.dbErrors);
        this.isAllowDuplicateSave = result.allowRetry;
        this.dispDuplicateCheck = result.allowRetry;
        String str = '';
        if (result.dbErrors != null) {
          str = result.dbErrors.get(this.nameCard.Id).msg;
        }
        str = String.isBlank(str) ? result.title : result.title + '<br/>' + str;
        throw new SB_NameCard_AccountRegistControllerException(str);
      }
      PageReference retUrl;
      SB_NC_RegistExecutor.SObjectInfo cc = result.registeds.get(this.nameCard.Id).cont;
      System.debug(cc);
      if (!this.debug && cc.Id != null) {
        retUrl = new PageReference('/' + cc.Id);
      }

      return retUrl;
    }
    catch (Exception e){
      ApexPages.addMessages(e);
      return null;
    }
  }

  // キャンセル
  public PageReference cancel() {
    PageReference retUrl;

    if (this.nameCard != null) {
      retUrl = new PageReference('/' + this.nameCard.Id);
    }
    return retUrl;
  }

  public static String defaultRecordType(Schema.SObjectType sobj) {
    String recordTypeName;
    List<Schema.RecordTypeInfo> rs =  sobj.getDescribe().getRecordTypeInfos();
    for (RecordTypeInfo r : rs) {
      if(r.isDefaultRecordTypeMapping() && r.isAvailable()) {
        recordTypeName =  r.getRecordTypeId();
      }
    }
    return recordTypeName;
  }

  public static List<RecordTypeInfo> getRecordType(Schema.SObjectType sobj) {

    List<Schema.RecordTypeInfo> rs =  sobj.getDescribe().getRecordTypeInfos();
    List<RecordTypeInfo> recordtypes = new List<RecordTypeInfo>();
    for (RecordTypeInfo r : rs) {
      if(r.isAvailable()) {
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

}