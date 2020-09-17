/*  $Id: SB_NameCard_AccountBulkRegistController.cls 16 2014-03-14 11:33:00Z ume $  */

/*
 *
 * SV_DEV-522  取引先・取引先責任者/リード登録画面で新規データ登録の際に複数回登録ボタンが押下されると同一データが複数登録されてしまう -> add public Boolean saveok{get;set;}//保存状況
 * SV_DEV-607  Classic画面で名刺登録を「言語：英語」（英語表示）の状態で登録した場合にレコードタイプ設定のラベル名変更が反映されない
 * SV_DEV-684 部署名に全角バックスラッシュが含まれる名刺を自動連携すると、ORA-01424エラーが発生する
 * Copyright (c) 2011-2015 SunBridge Inc.
 *
 * 名刺情報から取引先・取引先責任者への登録、一括登録
 *
 * @author gao
 *
 * @Version 1.20.1 2017.8.XX SV_DEV-533  取引先・取引先責任者登録画面の無効化状態での文字の表示（灰色にならない）
 * @Version 1.20.3 2017.10.XX SV_DEV-631  取引先・取引先一括登録画面に1名刺のみ選択して遷移した場合と2名刺以上選択して遷移した場合で検索結果が変わるパターンがある
 *                       SV_DEV-657  Classic画面：複数名刺を選択し、取引先・取引先責任者に登録（一括登録）画面へ遷移した場合に１行目の名刺データの検索候補で「姓・名」のみの候補が表示されない。
 * @Version 1.22 2017.10.XX SV_DEV-591  取引先・取引先責任者一括登録時の所有者について
 * @Version 1.22 2017.10.XX SV_DEV-607  Classic画面で名刺登録を「言語：英語」（英語表示）の状態で登録した場合にレコードタイプ設定のラベル名変更が反映されない
 * @Version 1.22 2017.11.XX SV_DEV-684  部署名に全角バックスラッシュが含まれる名刺を自動連携すると、ORA-01424エラーが発生する
 * @Version 1.20.4 2017.11.XX SV_DEV-685  名刺の姓、名に　シングルクォーテーション 　が入った場合　取引先、取引先責任者へ一括登録にて、該当名刺を選択すると、unexpected token:エラーが発生します
 * @Version 2.4  2019.05.XX yoshida SV_DEV-1743 無効なユーザを所有者としたTodo登録が行われた場合にエラー発生行を明示する
 *                2019.07.xx sawano SV_DEV-1355 取引先・取引先責任者に登録（個別/一括_Classic）で参照権限がない場合に登録先候補がでないようにしてほしい。 
 *                2019.08.xx sawano SV_DEV-940 取引先・取引先責任者登録時の会社名の比較対象をカスタム項目としたい
 *                                    SV_DEV-590 取引先・取引先検索の対象を、レコードタイプ単位で絞る
 * @Version 2.5  2020.01.XX yoshida SV_DEV-2367 Classic /LEX 各登録画面（ 個別・一括） : Todo件名がNULL値の場合での件名の表示・登録結果が異なる
 *
 */

public with sharing class SB_NameCard_AccountBulkRegistController{
  public String retUrl{get;set;}
  public Boolean enableSave {get;set;}    // 保存ボタン 有効・無効判定
  public class SB_NameCard_AccountBulkRegistControllerException extends Exception {}

  public Integer searchType { get; set; } // 検索対象
  public Boolean accountOverWrite { get; set; } // 取引先を上書き
  public Boolean contactOverWrite { get; set; } // 取引責任者を上書き
  public Boolean isError { get; private set; } //重複エラーがある
  public String  accountAndContact{get; private set;}//表示ラベル
  public String  rulesOfCreate{get; private set;}
  public String  registerAllToAccountAndContact{get; private set;}
  public String  updateForContact{get; private set;}//既存の取引先の情報を名刺情報で上書きする
  public String  updateForAccount{get; private set;}//既存の取引先責任者の情報を名刺情報で上書きする
  public String  title{get; private set;}
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
  public String  canNotUseStyleAcc{get; private set;}//取引先上書き表示ラベルCSS
  public String  canNotusestylecon{get; private set;}//取引先責任者上書き表示ラベルCSS
  public Boolean showUpdate{get; private set;}//基本設定上書き表示
  public Boolean showUpdateAccount{get; private set;}//基本設定 既存の取引先を名刺情報で上書きする」を表示する
  public Boolean showUpdateContact{get; private set;}//「既存の取引先責任者を名刺情報で上書きする」を表示する
  public Boolean saveOk{get; set;}//保存状況
  //SV_DEV-591 取引先・取引先責任者一括登録時の所有者について
  public Account owner {get;set;} //新規作成時の指定(所有者)
  public Boolean useNameCardOwner{get;set;} //名刺所有者
  public Boolean showSelectWhenNew{get;set;} //新規作成セクション表示フラグ
  public Boolean registTodoAll {get; set;}
  public static Boolean isCPULimitError = false;
  public String altCompanyField;    // SV_DEV-940 取引先・取引先責任者登録時の会社名の比較対象をカスタム項目としたい

  public NameCardBasicSetting__c  baseSetting{
    get{
      if (baseSetting == null) {
        baseSetting = SB_NameCard_BasicSetting.getNameCardBasicSetting();
        //SV_DEV-2367 基本設定で値が未設定ならカスタムラベルの値を読む
        baseSetting.RegistToDoSubject__c = String.isBlank(baseSetting.RegistToDoSubject__c) ? System.Label.SB_NC_ExchangeCard : baseSetting.RegistToDoSubject__c;
      }
      return baseSetting;
    }
    set;
  }
  public static SmartViscaConfig__c smartViscaConfig{
    get{
      if (smartViscaConfig == null) {
        smartViscaConfig = SmartViscaConfig__c.getInstance(UserInfo.getUserId()); // 個人の設定
        if (smartViscaConfig.Id ==null) {
          smartViscaConfig = SmartViscaConfig__c.getInstance(UserInfo.getProfileId()); //プロファイルの設定
        }
        if (smartViscaConfig.id == null) {
          smartViscaConfig = SmartViscaConfig__c.getOrgDefaults(); // 組織の設定
        }
        if (smartViscaConfig.id == null) {

        }
        smartViscaConfig.ToDoName__c = String.isBlank(smartViscaConfig.ToDoName__c) ? System.Label.SB_NC_ExchangeCard : smartViscaConfig.ToDoName__c;
      }
      return smartViscaConfig;
    }
    set;
  }

  private static final List<RecordTypeInfo> ACNT_RECORDTYPES;
  private static final List<RecordTypeInfo> CONT_RECORDTYPES;
  //複数Account.sObjectType.でオブジェクトとらないようにため
  //取引先オブジェクト表示ラベル
  public static final String AC_LABEL;
  //取引先責任者オブジェクト表示ラベル
  public static final String CO_LABEL;

  static {
    ACNT_RECORDTYPES = SB_NameCard_AccountBulkRegistController.getRecordType(Account.sObjectType);
    CONT_RECORDTYPES = SB_NameCard_AccountBulkRegistController.getRecordType(Contact.sObjectType);
    AC_LABEL = Account.sObjectType.getDescribe().getLabel();
    CO_LABEL = Contact.sObjectType.getDescribe().getLabel();
  }

  //取引先責任者レコードタイプOption取得
  public List<SelectOption> getContRecTypeSelectOpts(){
    List<SelectOption> options = new List<SelectOption>();
      //options.add(new SelectOption('', ''));
    for (RecordTypeInfo r : CONT_RECORDTYPES) {
      options.add(new SelectOption(r.getRecordTypeId(),r.getName()));
    }
    return options;
  }

  //取引先レコードタイプOption取得
  public List<SelectOption> getAccRecTypeSelectOpts(){
    List<SelectOption> options = new List<SelectOption>();
      //options.add(new SelectOption('', ''));
    for (RecordTypeInfo r : ACNT_RECORDTYPES) {
      options.add(new SelectOption(r.getRecordTypeId(), r.getName()));
    }
    return options;
  }

  public Boolean isFullCompanyNameForSearch { get; set; } // 商号あり会社名

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

  //名刺データ
  public class NameCardRecord{
    public NameCard__c nc { get; set; }
    public Integer accAndCon { get; set; }
    public List<SelectOption> accAndConSelectOpts { get; set; }
    public Boolean regist { get; set; }
    public Id accountId { get; set; }
    public Id contactId { get; set; }
    public Boolean registTask { get; set; }
    public Boolean hasSaveError { get; private set; }
    @TestVisible
    private List<AccAndCon> accAndConList;
    private String altCompanyField;    // SV_DEV-940 取引先・取引先責任者登録時の会社名の比較対象をカスタム項目としたい

    public NameCardRecord(NameCard__c nc, Integer searchType,
      Map<Id, Contact> cIdMap, Map<String, List<Contact>> cEmailMap, Map<String, List<Contact>> cNameMap, Map<String, List<Contact>> cLastNameMap,
      Map<Id, Account> aIdMap, List<Account> aNameList){
      this.nc = nc;
      this.accAndCon = 1;
      this.accAndConList = new List<AccAndCon>();
      this.altCompanyField = SB_NameCard_BasicSetting.getAltCompanyField(Account.getSObjectType()); // SV_DEV-940 取引先・取引先責任者登録時の会社名の比較対象をカスタム項目としたい

      Map<String, String> pnMap = SB_NameCard_Util.getPersonName(nc);
      List<SelectOption> opts = new List<SelectOption>();

      if (nc.company_name__c == null || String.isBlank(pnMap.get('last_name'))) {
        this.accAndConList.add(new AccAndCon());
        opts.add(new SelectOption('0', System.Label.SB_NC_DontRegister_CompanyNameRequired));
      } else {
        List<Contact> cList = this.getContactList(searchType, pnMap.get('last_name'), pnMap.get('first_name'), cIdMap, cEmailMap, cNameMap, cLastNameMap);
        List<Account> aList = this.getAccountList(searchType, aIdMap, aNameList);
        System.debug('cList.size: ' + cList.size() + ' aList.size: ' + aList.size());

        Integer index = 0;
        this.accAndConList.add(new AccAndCon());
        opts.add(new SelectOption(String.valueOf(index), System.Label.SB_NC_DontRegister));
        index++;
        Boolean cor = Schema.SObjectType.Contact.isCreateable();
        Boolean acc = Schema.SObjectType.Account.isCreateable();
        //オブジェクトの作成権限がないため、新規作成のタブを表示しないとなりました、
        //その結果、タブを1000件のうち、自分で追加するのは１件しかないです
        Integer optsnumber = 998;
        if (cor == false) {
          optsnumber = 999;
        }
        // 合計で1000行（「<新規作成><新規作成>」、「登録しない」含む）を超えない場合データをドロップダウンリストに表示する
        if ( cList.size() + aList.size() <= optsnumber ) {
          for (Contact c : cList) {
            this.accAndConList.add(new AccAndCon(c.AccountId, c.Id));
            opts.add(new SelectOption(String.valueOf(index), c.Account.Name + '(' + SB_NameCard_Util.getStr(c.Account.Site) + ')' + '/' + c.Name + '(' + SB_NameCard_Util.getStr(c.Department) + '/' + SB_NameCard_Util.getStr(c.Email) + ')'));
            index++;
          }
          if (cor != null && cor == true) {
            for (Account a : aList) {
              this.accAndConList.add(new AccAndCon(a.Id, null));
              opts.add(new SelectOption(String.valueOf(index), a.Name + '(' + SB_NameCard_Util.getStr(a.Site) + ')' + '/' + System.Label.SB_NC_Create));
              index++;
            }
          }
          if (Limits.getCpuTime() > Limits.getLimitCpuTime()-1000) {
            isCPULimitError = true;
            throw new SB_NameCard_AccountBulkRegistControllerException(System.Label.SB_NC_Msg_ChooseLessBusinessCards);
          }
        }

          this.accAndConList.add(new AccAndCon(null, null));
          if (cor != null && cor == true  && acc != null && acc == true) {
            opts.add(new SelectOption(String.valueOf(index), System.Label.SB_NC_Create + '/' + System.Label.SB_NC_Create));
          }
        }
        this.accAndConSelectOpts = opts;
        this.regist = false;
        this.registTask = !SB_NameCard_BasicSetting.getNameCardBasicSetting().RegistNoToDo__c;
    }

    // 取引先責任者取得
    private List<Contact> getContactList(Integer searchType, String lastName, String firstName, Map<Id, Contact> cIdMap, Map<String, List<Contact>> cEmailMap,
      Map<String, List<Contact>> cNameMap, Map<String, List<Contact>> cLastNameMap){
      Map<Id, Boolean> idMap = new Map<Id, Boolean>();
      List<Contact> cList = new List<Contact>();

      if (this.nc.contact__c != null && cIdMap.containsKey(this.nc.contact__c)) {
        Contact c = cIdMap.get(this.nc.contact__c);
        idMap.put(c.Id, true);
        cList.add(c);
      }

      List<Contact> cTmpList = new List<Contact>();
      if (this.nc.email__c != null && cEmailMap.containsKey(this.nc.email__c)) {
        cTmpList.addAll(cEmailMap.get(this.nc.email__c));

        for (Contact c : cTmpList) {
          if (!idMap.containsKey(c.Id)) {
            idMap.put(c.Id, true);
            cList.add(c);
          }
        }
      }

      cTmpList.clear();
      if (String.isNotBlank(firstName)) {
        String name = lastName + ' ' + firstName;

        if (cNameMap.containsKey(name)) {
          cTmpList.addAll(cNameMap.get(name));
        }
      } else {
        String name = lastName; // 姓のみ

        if (cLastNameMap.containsKey(name)) {
          cTmpList.addAll(cLastNameMap.get(name));
        }
      }

      String accountName = SB_NameCard_Util.getCompanyName(nc.company_name__c);
      if (String.isNotBlank(accountName)) {
        String division = nc.division__c;
        Boolean f;

        for (Contact c : cTmpList) {
          if (!idMap.containsKey(c.Id)) {
              f = false;

              if (String.isNotBlank(c.Account.Name) && SB_NameCard_MojiWidthUtil.findIgnoreCaseWidth(c.Account.Name,SB_NameCard_MojiWidthUtil.toHalfWidth(accountName))) {
                if (searchType == SB_NameCard_Util.SEARCHTYPE_NAME_SITE) {
                  if (String.isNotBlank(division)) {
                    if (String.isNotBlank(c.Department) && SB_NameCard_MojiWidthUtil.findIgnoreCaseWidth(c.Department,SB_NameCard_MojiWidthUtil.toHalfWidth(division))) {
                      f = true;
                    }
                  } else {
                    if (String.isBlank(c.Department)) {
                      f = true;
                    }
                  }
                } else {
                  f = true;
                }
            }
            if (f) {
              idMap.put(c.Id, true);
              cList.add(c);
            }
          }
          if (Limits.getCpuTime() > Limits.getLimitCpuTime()-1000) {
            isCPULimitError = true;
            throw new SB_NameCard_AccountBulkRegistControllerException(System.Label.SB_NC_Msg_ChooseLessBusinessCards);
          }
        }
      }

      return cList;
    }

    // 取引先取得
    private List<Account> getAccountList(Integer searchType, Map<Id, Account> aIdMap, List<Account> aNameList) {
      Map<Id, Boolean> idMap = new Map<Id, Boolean>();
      List<Account> aList = new List<Account>();

      if (this.nc.account__c != null && aIdMap.containsKey(this.nc.account__c)) {

        Account a = aIdMap.get(this.nc.account__c);
        idMap.put(a.Id, true);
        aList.add(a);
      }

      String accountName = SB_NameCard_Util.getCompanyName(nc.company_name__c);
      if (String.isNotBlank(accountName)) {

        String division = nc.division__c;
        Boolean f;
        String cfield = String.isblank(this.altCompanyField) ? 'Name' : this.altCompanyField;   // SV_DEV-940 取引先・取引先責任者登録時の会社名の比較対象をカスタム項目としたい
        for (Account a : aNameList) {
          if (!idMap.containsKey(a.Id)) {
            f = false;
            String aName = (String)a.get(cfield);     // 取引先の会社名
            if (String.isNotBlank(aName) && SB_NameCard_MojiWidthUtil.findIgnoreCaseWidth(aName,SB_NameCard_MojiWidthUtil.toHalfWidth(accountName))) {
              if (searchType == SB_NameCard_Util.SEARCHTYPE_NAME_SITE) {
                  if (String.isNotBlank(division)) {
                    if (String.isNotBlank(a.Site) && SB_NameCard_MojiWidthUtil.findIgnoreCaseWidth(a.Site,SB_NameCard_MojiWidthUtil.toHalfWidth(division))) {
                      f = true;
                    }
                  } else {
                    if (String.isBlank(a.Site)) {
                      f = true;
                    }
                  }
              } else {
                f = true;
              }
            }
            if (f) {
              idMap.put(a.Id, true);
              aList.add(a);
            }
          }
          if (Limits.getCpuTime() > Limits.getLimitCpuTime()-1000) {
            isCPULimitError = true;
            throw new SB_NameCard_AccountBulkRegistControllerException(System.Label.SB_NC_Msg_ChooseLessBusinessCards);
          }
        }
      }
      return aList;
    }
  }
  private List<NameCard__c> nameCardList;
  public List<NameCardRecord> nameCardTable { get; set; } // 名刺テーブル
   
  public SB_NameCard_AccountBulkRegistController(ApexPages.StandardSetController controller) {
    PageReference page = ApexPages.currentPage();
    Map<String, String> paras = page.getParameters();
    Boolean bLex = false;
    if (paras.containsKey('vfRetURLInSFX')) {
      bLex = true;
      this.retUrl = paras.get('vfRetURLInSFX');
      //this.viewId = getViewidFromUrl(this.retUrl, bLex);
      //this.urlRoot = getUrlRoot(this.retUrl);     // LEX のときだけでいい
    } else if (paras.containsKey('retURL')) {
      bLex = false;
      this.retUrl = paras.get('retUrl');
      //this.viewId = getViewidFromUrl(this.retUrl, bLex);
    } else {
        this.retUrl = '/home/home.jsp';
    }
    try {
      // v2.4 SV_DEV-1355 取引先・取引先責任者に登録（個別/一括_Classic）で参照権限がない場合に登録先候補がでないようにしてほしい。
      if (!Account.sObjectType.getDescribe().isAccessible() || !Contact.sObjectType.getDescribe().isAccessible()) {
        throw new SB_NameCard_AccountBulkRegistControllerException(System.Label.SB_NC_MSG_INSUFFICIENT_ACCESS);
      }
      this.altCompanyField = SB_NameCard_BasicSetting.getAltCompanyField(Account.getSObjectType()); // SV_DEV-940 取引先・取引先責任者登録時の会社名の比較対象をカスタム項目としたい
      String accstr = SB_NameCard_AccountBulkRegistController.defaultRecordType(Account.sObjectType);
      String constr = SB_NameCard_AccountBulkRegistController.defaultRecordType(Contact.sObjectType);

      Boolean ab = ACNT_RECORDTYPES.size() > 1;
      Boolean cb = CONT_RECORDTYPES.size() > 1;

      this.registTodoAll = !SB_NameCard_BasicSetting.getNameCardBasicSetting().RegistNoToDo__c;

      this.accountRecTypeEdit = !Account.sObjectType.getDescribe().isCreateable() || (ACNT_RECORDTYPES.size() < 1);

      this.contactRecTypeEdit = !Contact.sObjectType.getDescribe().isCreateable() || (CONT_RECORDTYPES.size() < 1);

      this.showSelectWhenNew = Contact.sObjectType.getDescribe().isCreateable() && Account.sObjectType.getDescribe().isCreateable();

      //既存の取引先を名刺情報で上書きする」を表示する
      this.showUpdateAccount = baseSetting.RegistDispAccountOverWriteCheckbox__c;
      //既存の取引先責任者を名刺情報で上書きする」を表示する
      this.showUpdateContact = baseSetting.RegistDispContactOverWriteCheckbox__c;

      this.showUpdate = this.showUpdateAccount || this.showUpdateContact;

      this.canNotUpdataAccount = !Account.sObjectType.getDescribe().isUpdateable();

      this.accountOverWrite = false;

      this.canNotUseStyleAcc = '';

      if (this.canNotUpdataAccount) {
        this.canNotUseStyleAcc = 'color:#999999;';
      }

      this.canNotUpdataContact = !Contact.sObjectType.getDescribe().isUpdateable();

      this.contactOverWrite = false;

      this.canNotusestylecon = '';

      if (this.canNotUpdataContact) {
        this.canNotusestylecon = 'color:#999999;';
      }

      //SV_DEV-842 Classic一括登録画面の所有者選択の初期値をデフォルトでオンにしたい。
      this.useNameCardOwner = true;

      this.owner = new Account();

      this.recordTypeExplain = System.Label.SB_NC_RecordTypeExplain;

      this.accountRecTypeId = String.isBlank(accstr) ? 'nano' : accstr;

      this.contactRecTypeId = String.isBlank(constr) ? 'nano' : constr;

      //SV_DEV-605 changeLabelメソッドを使わず
      // SV_DEV-607  Classic画面で名刺登録を「言語：英語」（英語表示）の状態で登録した場合にレコードタイプ設定のラベル名変更が反映されない
      //ラベル:取引先レコードタイプ
      this.accountRecType = String.format(System.Label.SB_NC_AccRecType,new String[]{SB_NameCard_AccountBulkRegistController.AC_LABEL, System.Label.SB_NC_RecType});
      //ラベル:取引先責任者レコードタイプ
      this.contactRecType = String.format(System.Label.SB_NC_CntRecType,new String[]{SB_NameCard_AccountBulkRegistController.CO_LABEL, System.Label.SB_NC_RecType});
      //ラベル:新規作成時の指定
      this.rulesOfCreate = String.format(System.Label.SB_NC_RulesOfCreate,new String[]{SB_NameCard_AccountBulkRegistController.AC_LABEL, SB_NameCard_AccountBulkRegistController.CO_LABEL});
      //ラベル:取引先(部門)/取引先責任者(部署/メール)
      this.accountAndContact = String.format(System.Label.SB_NC_Label_AccountANDContact, new String[] {SB_NameCard_AccountBulkRegistController.AC_LABEL, SB_NameCard_Util.getDesirableLabel('Account','Site'), SB_NameCard_AccountBulkRegistController.CO_LABEL, Contact.Department.getDescribe().getLabel(), Contact.Email.getDescribe().getLabel()});
      //ラベル:取引先・取引先責任者への一括登録
      this.registerAllToAccountAndContact = String.format(System.Label.SB_NC_RegisterAllToAccountAndContactDEV,new String[]{SB_NameCard_AccountBulkRegistController.AC_LABEL, SB_NameCard_AccountBulkRegistController.CO_LABEL});
      //ラベル:既存の取引先の情報を名刺情報で上書きする
      this.updateForAccount = String.format(System.Label.SB_NC_UpdateforAccountDEV,new String[]{SB_NameCard_AccountBulkRegistController.AC_LABEL});
      //ラベル:既存の取引先責任者の情報を名刺情報で上書きする
      this.updateForContact =  String.format(System.Label.SB_NC_UpdateforContactDEV,new String[]{SB_NameCard_AccountBulkRegistController.CO_LABEL});

      // デフォルトチェックはカスタム設定から取得
      if (smartViscaConfig.id == null) {
        this.searchType = SB_NameCard_Util.SEARCHTYPE_NAME_SITE;
      } else if (smartViscaConfig.AccountSearchType__c == null) {
        this.searchType = SB_NameCard_Util.SEARCHTYPE_NAME_SITE;
      } else {
        this.searchType = smartViscaConfig.AccountSearchType__c ? SB_NameCard_Util.SEARCHTYPE_NAME : SB_NameCard_Util.SEARCHTYPE_NAME_SITE;
      }

      if (!canNotUpdataAccount) {
        if (baseSetting == null) {
          this.accountOverWrite = true;
        } else {
          this.accountOverWrite = !baseSetting.RegistAccountNotOverWrite__c;
        }
      }

      if (!canNotUpdataContact) {
        if (baseSetting == null) {
          this.contactOverWrite = true;
        } else {
          this.contactOverWrite = !baseSetting.RegistContactNotOverWrite__c;
        }
      }
      if (baseSetting == null) {
        this.showAccountRecType = ab;

        this.showContactRecType = cb;
      } else {

        this.showAccountRecType = baseSetting.RegistDispAccountRectype__c && ab;

        this.showContactRecType = baseSetting.RegistDispContactRectype__c && cb;
      }

      this.showRecTypeSectionItem = this.showAccountRecType || this.showContactRecType;

      this.isFullCompanyNameForSearch = false;

      this.title = System.Label.SB_NC_BusinessCard + '：' + String.format(System.Label.SB_NC_RegisterAllToAccountAndContactDEV,new String[]{SB_NameCard_AccountBulkRegistController.AC_LABEL, SB_NameCard_AccountBulkRegistController.CO_LABEL});

      this.nameCardTable = new List<NameCardRecord>();

      List<NameCard__c> ncList = controller.getSelected();

      if (ncList != null && ncList.size() > 0) {
        this.nameCardList = [SELECT Id, company_name__c, division__c, title_name__c, Name,
          zip_code__c, address_pref__c, address__c, address_bld__c, address_eng__c, mobile__c, email__c,
          account__c, contact__c, person_name_last__c, person_name_first__c, last_name__c, first_name__c,
          tel1__c, fax1__c, web_url1__c, list_name__c, memo__c, freehandmemo__c, card_exchange_date__c, OwnerId
          FROM NameCard__c WHERE Id IN :ncList];
      }
      if (this.nameCardList == null) {
        this.nameCardList = new List<NameCard__c>();
      }
      System.debug('nameCardList.size: ' + this.nameCardList.size());
      this.setNameCardTable();
      System.debug('nameCardTable.size: ' + nameCardTable.size());
      this.enableSave = true;  // 保存ボタン 有効
    }
    catch (Exception e) {
      ApexPages.addMessages(e);
      this.enableSave = false;  // 保存ボタン 無効
    }
  }

  // selectOptions 取引先検索条件
  public List<SelectOption> getSearchTypeSelectOpts(){
    List<SelectOption> opts = new List<SelectOption>();

    //opts.add(new SelectOption(String.valueOf(SB_NameCard_Util.SEARCHTYPE_NAME_SITE), '取引先名と所属名で検索'));
    //opts.add(new SelectOption(String.valueOf(SB_NameCard_Util.SEARCHTYPE_NAME), '取引先名のみで検索'));
    String str = String.format(System.Label.SB_NC_SearchForAccountAndDepartmentDEV,new String[]{SB_NameCard_AccountBulkRegistController.AC_LABEL});
    opts.add(new SelectOption(String.valueOf(SB_NameCard_Util.SEARCHTYPE_NAME_SITE),str));
    String str1 = String.format(System.Label.SB_NC_SearchForAccountDEV,new String[]{SB_NameCard_AccountBulkRegistController.AC_LABEL});
    opts.add(new SelectOption(String.valueOf(SB_NameCard_Util.SEARCHTYPE_NAME),str1));

    return opts;
  }

  // 名刺テーブル設定
  public void setNameCardTable(){
    try {
      List<Account> aclist;
      List<Contact> colist;
      Map<Id, Contact> cIdMap = new Map<Id, Contact>();
      Map<String, List<Contact>> cEmailMap = new Map<String, List<Contact>>();
      Map<String, List<Contact>> cNameMap = new Map<String, List<Contact>>();
      Map<String, List<Contact>> cLastNameMap = new Map<String, List<Contact>>();
      colist = this.setContactMap(cIdMap);

      Map<Id, Account> aIdMap = new Map<Id, Account>();
      List<Account> aNameList = new List<Account>();
      aclist = this.setAccountMap(aIdMap);

      // 合計で998を超えた時に絞り込み検索を行う
      Boolean cor = Schema.SObjectType.Contact.isCreateable();
      Integer limitnumber = 998;
      if (cor == false) {
        limitnumber = 999;
      }
      if ( colist.size() + aclist.size() > limitnumber ) {
        this.isFullCompanyNameForSearch = true;

        cIdMap = new Map<Id, Contact>();
        cEmailMap = new Map<String, List<Contact>>();
        cNameMap = new Map<String, List<Contact>>();
        cLastNameMap = new Map<String, List<Contact>>();
        colist = this.setContactMap(cIdMap);

        aIdMap = new Map<Id, Account>();
        aNameList = new List<Account>();
        aclist = this.setAccountMap(aIdMap);
      }

      //取引先責任者関するMap設定
      setData(cIdMap, cEmailMap, cNameMap, cLastNameMap, colist);
      //取引先関するMap設定
      for (Account a : aclist) {
        aIdMap.put(a.Id, a);
        aNameList.add(a);
      }
      // this.nameCardTable.clear();
      Integer i = 0;
      for (NameCard__c nc : this.nameCardList) {
        NameCardRecord ncr = new NameCardRecord(nc, this.searchType, cIdMap, cEmailMap, cNameMap, cLastNameMap, aIdMap, aNameList);
        if (i + 1 > this.nameCardTable.size()) {
          this.nameCardTable.add(ncr);
        }
        else {
          ncr.registTask = this.nameCardTable[i].registTask;
          this.nameCardTable[i] = ncr;
        }
        // this.nameCardTable.add(new NameCardRecord(nc, this.searchType, cIdMap, cEmailMap, cNameMap, cLastNameMap, aIdMap, aNameList));
        if (Limits.getHeapSize() > Limits.getLimitHeapSize()) {
          this.nameCardTable = new List<NameCardRecord>();
          throw new SB_NameCard_AccountBulkRegistControllerException(System.Label.SB_NC_Msg_ChooseLessBusinessCards);
        }
        i ++;
      }
    }
    catch (Exception e) {
      if (isCPULimitError) {
        this.nameCardTable = new List<NameCardRecord>();
      }
      ApexPages.addMessages(e);
    }
  }

  //取引先責任者関連用Mapを作成
  public void setData(Map<Id, Contact> cIdMap, Map<String, List<Contact>> cEmailMap, Map<String, List<Contact>> cNameMap, Map<String, List<Contact>> cLastNameMap, List<Contact> contactList){
    List<Contact> cList;
    for (Contact c : contactList) {
      cIdMap.put(c.Id, c);

      if (cEmailMap.containsKey(c.Email)) {
        cList = cEmailMap.get(c.Email);
      } else {
        cList = new List<Contact>();
      }
      cList.add(c);
      cEmailMap.put(c.Email, cList);
      //  L229のソースによってこちのキーも同じようにLastName + ' ' + FirstNameで設定する
      String name = c.LastName + ' ' + c.FirstName;
      if (cNameMap.containsKey(name)) {
        cList = cNameMap.get(name);
      } else {
        cList = new List<Contact>();
      }
      cList.add(c);
      cNameMap.put(name, cList);

      if (cLastNameMap.containsKey(c.LastName)) {
        cList = cLastNameMap.get(c.LastName);
      }
      else {
        cList = new List<Contact>();
      }
      cList.add(c);
      cLastNameMap.put(c.LastName, cList);
    }
  }

  // 取引先責任者設定
  public List<Contact> setContactMap(Map<Id, Contact> cIdMap){
    Set<Id> cIdSet = new Set<Id>();
    Set<String> emailSet = new Set<String>();
    Set<String> accountNameSet = new Set<String>();
    Set<String> divisionSet = new Set<String>();
    //SV_DEV-631　不具合修正　:姓名の条件をここに保存
    Set<String> contactNameSet = new Set<String>();
    String accountName;
    Map<String, String> pnMap;

    for (NameCard__c nc : this.nameCardList) {
      if (nc.contact__c != null) {
        cIdSet.add(nc.contact__c);
      }

      if (String.isNotBlank(nc.email__c)) {
        emailSet.add(nc.email__c);
      }
      // 会社名を取得
      if (this.isFullCompanyNameForSearch == false) {
        accountName = SB_NameCard_Util.getCompanyName(nc.company_name__c);
      } else {
        accountName = nc.company_name__c;
      }
      pnMap = SB_NameCard_Util.getPersonName(nc);

      if (String.isNotBlank(accountName) && String.isNotBlank(pnMap.get('last_name'))) {
        accountNameSet.add(SB_NameCard_AccountBulkRegistController.varBindingExchange(accountName));
        if (this.searchType == SB_NameCard_Util.SEARCHTYPE_NAME_SITE) {
          if (String.isNotBlank(nc.division__c)) {
            divisionSet.add(SB_NameCard_AccountBulkRegistController.varBindingExchange(nc.division__c));
          } else {
            divisionSet.add(null);
          }
        }

        //SV_DEV-631　不具合修正　: 名がある場合、姓名合わせて姓名の検索条件になる
        // 'がある場合escapeが必要です
        if (String.isNotBlank(pnMap.get('first_name'))) {
          String last = pnMap.get('last_name');
          String first = pnMap.get('first_name');
          contactNameSet.add(' (LastName = \'' + String.escapeSingleQuotes(last) + '\'  AND  FirstName = \'' + String.escapeSingleQuotes(first) + '\') ');
        } else {
          //SV_DEV-631　不具合修正　: 姓のみの場合姓だけ姓名の検索条件になる
          String last = pnMap.get('last_name');
          contactNameSet.add(' (LastName = \'' + String.escapeSingleQuotes(last) + '\') ');
        }
      }
    }

    //姓名のクエリ条件をSetから文字列に変換
    String contactNamestr = '(' + String.join(new List<String>(contactNameSet), 'OR ') + ')';

    List<String> whereOrList = new List<String>();

    if (cIdSet.size() > 0) {
      whereOrList.add('Id = :cIdSet');
    }

    if (emailSet.size() > 0) {
      whereOrList.add('Email = :emailSet');
    }

    if (accountNameSet.size() > 0) {
      String cfield = String.isblank(this.altCompanyField) ? 'Name' : this.altCompanyField;   // SV_DEV-940 取引先・取引先責任者登録時の会社名の比較対象をカスタム項目としたい
      if (this.searchType == SB_NameCard_Util.SEARCHTYPE_NAME_SITE) {
        if (divisionSet.size() > 0) {
          whereOrList.add(String.format('(Account.{0} LIKE :accountNameSet AND (Account.Site LIKE :divisionSet OR Department LIKE :divisionSet) AND {1})', new String[] { cfield, contactNamestr }));
        } 
        else {
          whereOrList.add(String.format('(Account.{0} LIKE :accountNameSet AND (Account.Site = null OR Department = null) AND {1})', new String[] { cfield, contactNamestr }));
        }
      } 
      else {
        whereOrList.add(String.format('(Account.{0} LIKE :accountNameSet AND {1})', new String[] { cfield, contactNamestr }));
      }
    }

    String whereExpression;
    List<String> whereAndList = new List<String>();
    if (!whereOrList.isEmpty()) {
      whereAndList.add('(' + String.join(whereOrList, ' OR ') + ')');
    }
    // v2.4 2019.08xx v2.4 2019.08xx SV_DEV-590 取引先・取引先検索の対象を、レコードタイプ単位で絞る
    List<Id> contRecTypeIds = new List<Id>(SB_NameCard_BasicSetting.registContactQueryRecordTypeIds);
    if (!contRecTypeIds.isEmpty()) {
      whereAndList.add('RecordTypeId = :contRecTypeIds');
    }
    whereAndList.add('IsDeleted = false');
    whereExpression = String.join(whereAndList, ' AND ');

    if (!whereOrList.isEmpty()) { // v2.4 でも 名刺の条件があるときのみ クエリ
      String soql_form  = 'SELECT'
        + ' AccountId, Account.Name{0},  Account.Site, Id, Department, Name, LastName, Email, FirstName, OwnerId'
        + ' FROM Contact WHERE {1}'
        + ' ORDER BY Account.Name ASC, MailingState ASC NULLS LAST, Department ASC NULLS LAST limit 999';
      String soql = String.format(soql_form, new String[] { (String.isblank(this.altCompanyField) ? '' : ', Account.' + this.altCompanyField), whereExpression });
      System.debug(soql);
      return Database.query(soql);
    }
    return new List<Contact>();
  }

  // 取引先設定
  public List<Account> setAccountMap(Map<Id, Account> aIdMap){
    Set<Id> aIdSet = new Set<Id>();
    Set<String> accountNameSet = new Set<String>();
    Set<String> divisionSet = new Set<String>();
    String accountName;

    for (NameCard__c nc : this.nameCardList) {
      if (nc.account__c != null) {
        aIdSet.add(nc.account__c);
      }

      // 会社名を取得
      if (this.isFullCompanyNameForSearch == false) {
        accountName = SB_NameCard_Util.getCompanyName(nc.company_name__c);
      } 
      else {
        accountName = nc.company_name__c;
      }
      if (String.isNotBlank(accountName)) {
        accountNameSet.add(SB_NameCard_AccountBulkRegistController.varBindingExchange(accountName));
        if (this.searchType == SB_NameCard_Util.SEARCHTYPE_NAME_SITE) {
          if (String.isNotBlank(nc.division__c)) {
            divisionSet.add(SB_NameCard_AccountBulkRegistController.varBindingExchange(nc.division__c));
            // divisionSet.add('%' + SB_NameCard_Util.getBackslashToWildcardEtc(nc.division__c) + '%');
          } 
          else {
            divisionSet.add(null);
          }
        }
      }
    }

    List<String> whereOrList = new List<String>();

    if (aIdSet.size() > 0) {
      whereOrList.add('Id = :aIdSet');
    }

    if (accountNameSet.size() > 0) {
      String cfield = String.isblank(this.altCompanyField) ? 'Name' : this.altCompanyField;   // SV_DEV-940 取引先・取引先責任者登録時の会社名の比較対象をカスタム項目としたい
      if (this.searchType == SB_NameCard_Util.SEARCHTYPE_NAME_SITE) {
        if (divisionSet.size() > 0) {
          whereOrList.add(String.format('({0} LIKE :accountNameSet AND Site LIKE :divisionSet)', new String[] { cfield }));
        } 
        else {
          whereOrList.add(String.format('({0} LIKE :accountNameSet AND Site = null)', new String[] { cfield }));
        }
      } 
      else {
        whereOrList.add(String.format('{0} LIKE :accountNameSet', new String[] { cfield }));
      }
    }

    String whereExpression;
    List<String> whereAndList = new List<String>();
    if (!whereOrList.isEmpty()) {
      whereAndList.add('(' + String.join(whereOrList, ' OR ') + ')');
    }
    // v2.4 2019.08xx SV_DEV-590 取引先・取引先検索の対象を、レコードタイプ単位で絞る
    List<Id> acntRecTypeIds = new List<Id>(SB_NameCard_BasicSetting.registAccountQueryRecordTypeIds);
    if (!acntRecTypeIds.isEmpty()) {
      whereAndList.add('RecordTypeId = :acntRecTypeIds');
    }
    whereAndList.add('IsDeleted = false');
    whereExpression = String.join(whereAndList, ' AND ');

    if (!whereOrList.isEmpty()) {  // v2.4 でも 名刺の条件があるときのみ クエリ
      String soql_form = 'SELECT Id, Name{0}, Site FROM Account WHERE {1}'
        + ' ORDER BY Name ASC, BillingState ASC NULLS LAST, Site ASC NULLS LAST limit 999';
      String soql = String.format(soql_form, new String[] { (String.isblank(this.altCompanyField) ? '' : ', ' + this.altCompanyField), whereExpression });
      return Database.query(soql);
    }
    return new List<Account>();
  }

  // 保存
  public void saveNC(){
    PageReference p;
    saveok = true;

    try {
      AccAndCon aacTmp;
      Account a;
      List<Account> aList = new List<Account>();
      list<Account> newAccounts = new List<Account>();        // 2014.4.2x CRUD/FLS 対応
      list<Account> existAccounts = new List<Account>();      // 2014.4.2x CRUD/FLS 対応
      Map<Id, Boolean> idMap = new Map<Id, Boolean>();

      //重複フラグを初期化
      for (NameCardRecord ncr : this.nameCardTable) {
        ncr.hasSaveError = false;
      }


      if (this.accountRecTypeEdit) {
        this.accountRecTypeId = null;
      }

      if (this.contactRecTypeEdit) {
        this.contactRecTypeId = null;
      }

      Id oId;
      if (!useNameCardOwner && String.isNotBlank(this.owner.OwnerId)) {
        oId = this.owner.OwnerId;
      }

      List<SB_NC_RegistExecutor.RegistTarget> tars = new List<SB_NC_RegistExecutor.RegistTarget>();
      Boolean haveNew = false;
      String str = '';
      Integer j = 0;
      for (NameCardRecord ncr : this.nameCardTable) {
        AccAndCon aacTmp1 = ncr.accAndConList[ncr.accAndCon];
        if (aacTmp1.regist == true) {
          if (!haveNew) {
            haveNew = String.isBlank(aacTmp1.accountId) || String.isBlank(aacTmp1.contactId);
          }
          SB_NC_RegistExecutor.RegistTarget tar = new SB_NC_RegistExecutor.RegistTarget(ncr.nc.Id,aacTmp1.accountId,aacTmp1.contactId,null,ncr.registTask,null);
          //ToDo登録AND責任者が新規の場合キュー判断，更新の場合取引先責任者の所有者に設定しますので，キューになる事がありません
          if (ncr.registTask && String.isBlank(aacTmp1.contactId) && (String.isNotBlank(oId) || useNameCardOwner)) {
            String oId1 = useNameCardOwner ? ncr.nc.OwnerId : oId;
            if (!String.valueOf(oId1).startsWith('005')) {
              this.nameCardTable[j].hasSaveError = true;
              str += String.format('{0}' + System.Label.SB_NC_Line + ': {1}', new String[]{ ''+(j+1), System.Label.SB_NC_MSG_NAMECARD_OWNER_QUEUE + '<br/>'});
            }
          }
          tars.add(tar);
        }
        j ++;
      }

      if (String.isNotBlank(str)) {
        this.isError = true;
        throw new SB_NameCard_AccountBulkRegistControllerException(str.removeEnd('<br/>'));
      }

      if (!useNameCardOwner && String.isBlank(owner.OwnerId) && haveNew) {
        throw new SB_NameCard_AccountBulkRegistControllerException(System.Label.SB_NC_SpecifyOwnerWhenCreateAcCo);
      }

      SB_NC_RegistExecutor.RegistParam acre = new SB_NC_RegistExecutor.RegistParam('Account',this.accountOverWrite,this.accountRecTypeId,oId,false);
      SB_NC_RegistExecutor.RegistParam conre = new SB_NC_RegistExecutor.RegistParam('Contact',this.contactOverWrite,this.contactRecTypeId,oId,false);
      SB_NC_RegistExecutor.TodoParam todo = new SB_NC_RegistExecutor.TodoParam(baseSetting.RegistToDoSubject__c,null,null,null);

      SB_NC_RegistExecutor.RegistRequest re = new SB_NC_RegistExecutor.RegistRequest(tars,acre,conre,null,todo);
      //SV_DEV-1743 リード連携拡張パッケージ 統合版画面と同等の所有者の有効性チェックを実施
      // SV_DEV-2046 Classic 取引先登録 一括：Todo任命先が「名刺の所有者」で、有効なユーザが所有者の名刺レコードで、上書き登録した場合にユーザが無効エラーメッセージが表示される
      //  → Todo任命先が「名刺の所有者」 か判別します。
      Map<Id, String> ownerErrorMap = SB_NameCard_RegistOwnerCheckHelper.doCheck(re, this.baseSetting.RegistToDoOwner__c == 'NameCardOwner');
      System.debug(ownerErrorMap);
      if (!ownerErrorMap.isEmpty()) {
        for (Integer i = 0; i<nameCardTable.size(); i++) {
          if (ownerErrorMap.containsKey(nameCardTable[i].nc.id)) {
            nameCardTable[i].hasSaveError = true;
            str += String.format('{0}' + System.Label.SB_NC_Line + ': {1}', new String[]{ ''+(i+1),ownerErrorMap.get(nameCardTable[i].nc.id) + '<br/>'});
          } else{
            nameCardTable[i].hasSaveError = false;
          }
        }
        throw new SB_NC_RegistExecutor.SB_NC_RegistExecutorException(str);
      }
      //doRegist内既にrollbackしていますので、ここは二度目はしません
      SB_NC_RegistExecutor.RegistResponse result = SB_NC_RegistExecutor.doRegist(re);
      if (result.success == false) {
        str = '<br/>';
        this.isError = true;
        if (result.dbErrors!=null) {
          for (Integer i = 0; i<this.nameCardTable.size(); i++) {
            if (result.dbErrors.containsKey(this.nameCardTable[i].nc.Id)) {
              this.nameCardTable[i].hasSaveError = true;
              str += String.format('{0}' + System.Label.SB_NC_Line + ': {1}', new String[]{ ''+(i+1),result.dbErrors.get(this.nameCardTable[i].nc.Id).msg + '<br/>'});
            } else{
              this.nameCardTable[i].hasSaveError =false;
            }
          }
        }
        str = str.removeEnd('<br/>');
        throw new SB_NameCard_AccountBulkRegistControllerException(result.title + str);
      } else {
        this.isError = false;
      }
    }
    catch (Exception e) {
      saveok = false;
      ApexPages.addMessages(e);
    }
  }

  public static String defaultRecordType(Schema.sObjectType obj){
    String recordTypeName;
    List<Schema.RecordTypeInfo> rs =  obj.getDescribe().getRecordTypeInfos();
    for (RecordTypeInfo r : rs) {
      if (r.isDefaultRecordTypeMapping() && r.isAvailable()) {
        recordTypeName =  r.getRecordTypeId();
      }
    }
    return recordTypeName;
  }

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

  public static String varBindingExchange(String str) {
    //アポストロフィーがある場合、escapeSingleQuotesメソッドがエスケープされるはずですが、
    //なぜかうまくエスケープできてないので、エスケープする前にアポストロフィーをbase64を使って暗号化して、エスケープ後に元に戻す
    String str1 = EncodingUtil.urlEncode(str, 'UTF-8');
    Blob b = Blob.valueOf(str1);
    String b64 = EncodingUtil.base64Encode(b);
    str = str.replaceAll('\'',b64);
    str = String.escapeSingleQuotes('%' + SB_NameCard_Util.getZenkakuBackslashToWildcard(str) + '%');
    str = str.replaceAll(b64,'\'');
    return str;
  }
}