/*
 * SB_NameCard_LeadBulkRegistController
 *
 * (c) 2016 Sunbridge Inc.
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
 * lx2.1 2020.01.xx SV_DEV-770 Classic リード登録 一括：重複ルールでの一致するレコードが多いとCPUタイムアウトエラーになる。
 *
 */

public with sharing class SB_NameCard_LeadBulkRegistController {
  public class LeadBulkRegistControllerException extends exception {}

  private static final String LEADLABEL = Lead.sObjectType.getDescribe().getLabel();

  public String retUrl{get;set;}
  public Boolean useNameCardOwner{get;set;}
  public String winbdowTitle{get;set;}
  public Boolean searchError{get;set;}

  //テスト addMessageキャッチよう
  @TestVisible
  private String testError;

  // 名刺レコード
  public class NameCardRecord{
    public SmartViscaf__NameCard__c nameCard { get; private set; }
    public String leadId { get; set; }
    public List<SelectOption> leadSelOptList { get; private set; }
    public Boolean registTodo { get; set; }
    public Boolean hasError { get; set; }
    public String message { get; set; }
    private Id nameCardOwnerId { get; set; }

    public NameCardRecord(SmartViscaf__NameCard__c nc, Boolean registTodo) {
      this.nameCard = nc;
      this.leadId = 'none';
      this.leadSelOptList = new List<SelectOption>();
      this.registTodo = registTodo;
      this.hasError = false;
      this.message = '';
      this.nameCardOwnerId = nc.OwnerId;
    }

    public void setLeadRecord(Map<Id, Lead> idMap, Map<String, List<Lead>> emailListMap, Map<String, List<Lead>> nameListMap) {
      this.leadSelOptList.clear();
      //this.leadSelOptList.add(new SelectOption('none', '登録しない'));
      this.leadSelOptList.add(new SelectOption('none', System.Label.SB_NCLD_Menu_NotToRegister));

      Set<Id> idSet = new Set<Id>();
      List<SelectOption> emailSelOptList = new List<SelectOption>();
      List<SelectOption> nameSelOptList = new List<SelectOption>();

      if (idMap != null && idMap.containsKey(this.nameCard.SmartViscaf__lead__c)) {
        Lead lead = idMap.get(this.nameCard.SmartViscaf__lead__c);
        this.leadSelOptList.add(new SelectOption(lead.Id, this.getLabel(lead.Name, lead.Email)));
        idSet.add(lead.Id);
      }
      if (emailListMap != null && emailListMap.containsKey(this.nameCard.SmartViscaf__email__c)) {
        for (Lead lead : emailListMap.get(this.nameCard.SmartViscaf__email__c)) {
          if (idSet.contains(lead.Id)) continue;
          emailSelOptList.add(new SelectOption(lead.Id, this.getLabel(lead.Name, lead.Email)));
          idSet.add(lead.Id);
        }
      }
      if (nameListMap != null) {
        String name = SB_NameCard_LeadRegist.getPersonName(this.nameCard);
        if (nameListMap.containsKey(name)) {
          for (Lead lead : nameListMap.get(name)) {
            if (idSet.contains(lead.Id)) continue;
            nameSelOptList.add(new SelectOption(lead.Id, this.getLabel(lead.Name,lead.Email)));
            idSet.add(lead.Id);
          }
        }
      }
      Integer Leadnumber = Lead.sObjectType.getDescribe().isCreateable() == true ? 998 : 999;
      if (this.leadSelOptList.size() + emailSelOptList.size() + nameSelOptList.size() <= Leadnumber) {
        this.leadSelOptList.addAll(emailSelOptList);
        this.leadSelOptList.addAll(nameSelOptList);
      } else {
        //this.message = '検索件数が制限を超えたので過去に登録したリードだけに絞って表示します。';
        this.message = String.format(System.Label.SB_NCLD_Msg_DisplayUnderConditionsDEV, new String[] {LEADLABEL});
      }
      //this.leadSelOptList.add(new SelectOption('new', '新規作成'))
      if(Lead.sObjectType.getDescribe().isCreateable()) {
        this.leadSelOptList.add(new SelectOption('new', System.Label.SB_NCLD_Menu_NewLead));
      }
      Integer i = leadSelOptList.size()>1 ? 1 : 0;
      SelectOption ss = leadSelOptList[i];
      this.leadId = ss.getValue();
      this.hasError = false;
    }

    private String getLabel(String name, String email) {
      String label = String.isBlank(name) ? '' : name;
      label += String.isBlank(email) ? ' <>' : ' <'+email+'>';
      return label;
    }
  }

  //private PageReference retUrl;

  public Integer searchType { get; set; }
  public Boolean leadOverwrite { get; set; }
  public Boolean showLeadOverwrite { get; set; }
  public List<NameCardRecord> nameCardRecordList { get; set; }
  public SmartViscaf__NameCard__c insertOption { get; set; }
  public Lead ownerlead { get; set; }
  public Boolean hasError { get; set; }
  public Boolean leadCreateable {get;set;}

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
  public Boolean cannotUpdataLead{get; private set;}//取引先責任者更新不可フラグ
  public  List<SelectOption> campaignStatus {get; set;}
  public  Boolean registTodoAll {get; set;}

  public  String useNameCardOwnerLabel {get; set;}

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
  private static final List<RecordTypeInfo> LEADRECORDTYPES = SB_NameCardL_Util.getRecordType(Lead.sObjectType);


  public SB_NameCard_LeadBulkRegistController(ApexPages.StandardSetController controller) {
    this.winbdowTitle = String.format(System.Label.SB_NCLD_Text_RegisterToLeadsDEVWindowTitle, new String[]{SmartViscaf__NameCard__c.sObjectType.getDescribe().getLabel(), LEADLABEL});
    PageReference page = ApexPages.currentPage();
    Map<String, String> paras = page.getParameters();
    Boolean bLex = false;
    if (paras.containsKey('vfRetURLInSFX')) {
      bLex = true;
      this.retUrl = paras.get('vfRetURLInSFX');
      //this.viewId = getViewidFromUrl(this.retUrl, bLex);
      //this.urlRoot = getUrlRoot(this.retUrl);     // LEX のときだけでいい
    } else if (paras.containsKey('retUrl')) {
      bLex = false;
      this.retUrl = paras.get('retUrl');
      //this.viewId = getViewidFromUrl(this.retUrl, bLex);
    } else {
      this.retUrl = '/home/home.jsp';
    }
    try {
        this.useNameCardOwner = true;

        this.leadCreateable = Lead.sObjectType.getDescribe().isCreateable();

        this.registerToLeadLabel = String.format(System.Label.SB_NCLD_Text_RegisterToLeadsDEV, new String[] {LEADLABEL});
        this.overwriteLeadInfoLabel = String.format(System.Label.SB_NCLD_Label_OverwriteLeadInfoDEV, new String[] {LEADLABEL});
        this.specifiedWhenCreateNew = String.format(System.Label.SB_NCLD_Text_SpecifiedWhenCreateNew, new String[] {LEADLABEL});

        this.useNameCardOwnerLabel = String.format(System.Label.SB_NCLD_Label_NameCardOwner, new String[] {LEADLABEL});

        // SV_DEV-747 リード拡張パッケージのカスタム設定：リードに登録 リードレコードタイプ表示の初期値がOFF
        this.showLeadRecType = LEADRECORDTYPES.size() > 1 && baseSetting.SmartViscaf__RegistDispLeadRectype__c;

        this.leadRecTypeEdit = leadCreateable && LEADRECORDTYPES.size() > 1;

        this.searchType = SB_NameCard_LeadRegist.SEARCHTYPE_EMAIL;
        this.leadOverwrite  = false;
        this.cannotUpdataLead = !Lead.sObjectType.getDescribe().isUpdateable();
        if (!canNotUpdataLead) {
          if (baseSetting == null) {
            this.leadOverwrite = true;
          } else {
            this.leadOverwrite = !baseSetting.SmartViscaf__RegistLeadNotOverWrite__c;
          }
        }

        this.showLeadOverwrite = true;
        if (!baseSetting.SmartViscaf__RegistDispLeadOverWriteCheckbox__c) {
          this.showLeadOverwrite = false;
        }
        this.registTodoAll = SB_NameCard_LeadRegist.svConfig.registTodo();
        List<SmartViscaf__NameCard__c> ncList = SB_NameCard_LeadRegist.getNameCardList(controller.getSelected());
        this.nameCardRecordList = getNameCardRecordList(ncList, SB_NameCard_LeadRegist.svConfig.registTodo());

        this.insertOption = new SmartViscaf__NameCard__c(OwnerId=UserInfo.getUserId());
        this.ownerlead = new Lead();
        this.hasError = false;

        this.campLookUpDisabled = !SmartViscaf__NameCard__c.campaign__c.getDescribe().isAccessible();

        this.campDisabled = true;

        //リードに関する設定
        setRecord();
        this.CampaignStatus = getCampaignS();

        SB_NameCard_LeadRegist.setEmailSoql(this.soqlMap, this.emailIdList, this.emailList, ncList);
        //SB_NameCard_LeadRegist.setNameSoql(this.soqlMap, this.nameIdList, this.nameSet, ncList);
        SB_NameCard_LeadRegist.setLastFirstNameSoql(this.soqlMap, this.nameIdList, this.nameSet,this.lastNameSet,this.firstNameSet,ncList);
        searchError = false;
        this.search();
    } catch (Exception e) {
      testError = e.getMessage();
      ApexPages.addMessages(e);
    }
  }

  public void changeCampaign() {
    this.CampaignStatus = getCampaignS();
  }

  //SV_DEV-175 リード登録時にキャンペーン内での状況を選択
  public  List<SelectOption> getCampaignS(){
    List<SelectOption> options = new List<SelectOption>();
    List<CampaignMemberStatus> cpms = [SELECT id, CampaignID, HasResponded, IsDefault, Label, SortOrder
                                        FROM CampaignMemberStatus 
                                       WHERE CampaignId = :insertOption.campaign__c];
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
    leadRecType = String.format(System.Label.SB_NCLD_Label_LeadRecType, new String[] {LEADLABEL});
  }

  //リードレコードタイプ選択リストoptopn
  public List<SelectOption> getleadrecordtypeOptions() {
    List<SelectOption> options = new List<SelectOption>();
    for (RecordTypeInfo r : LEADRECORDTYPES) {
      options.add(new SelectOption(r.getRecordTypeId(), r.getName()));
    }
    return options;
  }

  // 検索条件
  public static List<SelectOption> getSearchTypeList() {
    return SB_NameCard_LeadRegist.getSearchTypeList();
  }

  // 名刺レコードリスト
  private static List<NameCardRecord> getNameCardRecordList(List<SmartViscaf__NameCard__c> ncList, Boolean registTodo) {
    List<NameCardRecord> ncRecList = new List<NameCardRecord>();

    for (SmartViscaf__NameCard__c nc : ncList) {
      ncRecList.add(new NameCardRecord(nc, registTodo));
    }
    return ncRecList;
  }

  // 検索
  public void search() {
    String message = '';
    try {
      this.hasError = false;
      Map<Id, Lead> idMap = new Map<Id, Lead>();
      Map<String, List<Lead>> emailListMap = new Map<String, List<Lead>>();
      Map<String, List<Lead>> nameListMap = new Map<String, List<Lead>>();
      this.setLeadMap(idMap, emailListMap, nameListMap);

      for (NameCardRecord ncRec : this.nameCardRecordList) {
        if ((!SmartViscaf.SB_NameCard_Util.isEnablePersonAccount() && String.isBlank(ncRec.nameCard.SmartViscaf__company_name__c)) || String.isBlank(SmartViscaf.SB_NameCard_Util.getPersonName(ncRec.nameCard).get('last_name'))) {
          if (ncRec.leadSelOptList.isEmpty()) {
            if ((!SmartViscaf.SB_NameCard_Util.isEnablePersonAccount() && String.isBlank(ncRec.nameCard.SmartViscaf__company_name__c))) {
              ncRec.leadSelOptList.add(new SelectOption('none', System.Label.SB_NCLD_DontRegister_CompanyNameRequired));
            }
            else {
              ncRec.leadSelOptList.add(new SelectOption('none', System.Label.SB_NCLD_DontRegister_NameRequired));
            }
          }
          continue;
        }
        ncRec.setLeadRecord(idMap, emailListMap, nameListMap);
        if (ncRec.message != '') {
          message = ncRec.message;
        }
        if (Limits.getHeapSize() > Limits.getLimitHeapSize()) {
          this.nameCardRecordList = new List<NameCardRecord>();
          throw new SB_NameCard_LeadRegist.LeadRegistException(System.Label.SB_NCLD_Msg_ChooseLessBusinessCards);
        }
      }
      if (message != '') {
        testError = message;
        if (message != String.format(System.Label.SB_NCLD_Msg_DisplayUnderConditionsDEV, new String[] {LEADLABEL})) {
          this.searchError = true;
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, message));
      }
    } catch (Exception e) {
      testError = e.getMessage();
      this.searchError = true;
      ApexPages.addMessages(e);
    }
  }

  // リード
  private void setLeadMap(Map<Id, Lead> idMap, Map<String, List<Lead>> emailListMap, Map<String, List<Lead>> nameListMap) {
    this.leadOwnerIdMap.clear();
    String soql = this.soqlMap.get(this.searchType);
    System.debug(soql);
    System.debug(this.searchType);
    System.debug(soqlMap);

    if (String.isBlank(soql)) return;
      String name ='';        for (Lead lead :Database.query(soql)) {
      idMap.put(lead.Id, lead);
      this.leadOwnerIdMap.put(lead.Id, lead.OwnerId);

      // SV_DEV-746 リードに登録（一括登録）で、検索条件が「氏名」の場合でメールアドレスが一致した候補が表示される場合がある。
      if (this.searchType == SB_NameCard_LeadRegist.SEARCHTYPE_EMAIL) {
        if (String.isNotBlank(lead.Email)) {
          if (emailListMap.containsKey(lead.Email)) {
            emailListMap.get(lead.Email).add(lead);
          } else {
            emailListMap.put(lead.Email, new List<Lead>{lead});
          }
        }
      } else {
        // 姓名
        if (nameListMap.containsKey(lead.Name)) {
          nameListMap.get(lead.Name).add(lead);
        }
        else {
          nameListMap.put(lead.Name, new List<Lead>{lead});
        }

        // 姓のみ
        name = lead.LastName;
        if (nameListMap.containsKey(name)) {
          nameListMap.get(name).add(lead);
        }
        else {
          nameListMap.put(name, new List<Lead>{lead});
        }
        // 名のみ
        name = lead.FirstName;
        if (nameListMap.containsKey(name)) {
          nameListMap.get(name).add(lead);
        }
        else {
          nameListMap.put(name, new List<Lead>{lead});
        }
      }
    }
  }

  // 保存
  // SV_DEV-762 名刺オブジェクトの編集権限がない場合にリードに登録の処理が終了しない。
  public void saveLead() {
    saveOK = true;
    Savepoint sp;

    try {
      this.hasError = false;
      for (NameCardRecord ncRec : this.nameCardRecordList) ncRec.hasError = false;
      sp = Database.setSavepoint();
      String str = '';

      List<SB_NameCardL_RegistHelper.RegistTarget> tars = new List<SB_NameCardL_RegistHelper.RegistTarget>();
      Boolean haveNew = false;
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

      for (Integer i = 0; i < this.nameCardRecordList.size(); i ++) {
        NameCardRecord ncr = this.nameCardRecordList[i];
        if (ncr.leadId != 'none') {
          System.debug('111111111111 ');
          if (ncr.leadId == 'new') {
            System.debug('222222222222222 ');
            System.debug('isnew' + ncr.leadId == 'new');
            //画面上の所有者を
            if (!haveNew) {
              haveNew = true;
              if (!useNameCardOwner && String.isBlank(this.ownerlead.OwnerId)) {
                //(関連)リードを新規作成する場合は「所有者」を指定してください
                String noOwnerIdErrorMessage = String.format(System.Label.SB_NCLD_Msg_SpecifyOwnerWhenCreateLeadDEV, new String[] {LEADLABEL});
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
          if (String.isNotBlank(insertOption.campaign__c) && ncr.leadId == 'new') {
            tar.setLeadCampaign(insertOption.campaign__c, campStatus);
          }
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

       // ToDo登録エラー
      if (String.isNotBlank(todoError)) {
        throw new SB_NameCard_LeadRegist.LeadRegistException(todoError);
      }

      SB_NameCardL_RegistHelper.RegistParam leadRP = new SB_NameCardL_RegistHelper.RegistParam('Lead',this.leadOverwrite,this.leadRecordTypeId,oId,false);
      SB_NameCardL_RegistHelper.TodoParam todoRP = new SB_NameCardL_RegistHelper.TodoParam(SB_NameCard_LeadRegist.svConfig.todoSubject(),null,null,null);

      SB_NameCardL_RegistHelper.RegistRequest re = new SB_NameCardL_RegistHelper.RegistRequest(tars, null, null, leadRP, todoRP);
      Map<Id, String> ownerErrorMap = SB_NameCardL_RegistOwenrCheckHelper.doCheck(re);
      System.debug(ownerErrorMap);
      if (!ownerErrorMap.isEmpty()) {
        str = '';
        for (Integer i = 0; i<nameCardRecordList.size(); i++) {
          if (ownerErrorMap.containsKey(nameCardRecordList[i].nameCard.id)) {
            nameCardRecordList[i].hasError = true;
            // ToDo
            str += String.format('{0}' + System.Label.SB_NC_Line + ': {1}', new String[]{ ''+(i+1),ownerErrorMap.get(nameCardRecordList[i].nameCard.id) + '<br/>'});
          } else{
            nameCardRecordList[i].hasError = false;
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
          for (Integer i = 0; i<this.nameCardRecordList.size(); i++) {
            if (result.dbErrors.containsKey(this.nameCardRecordList[i].nameCard.Id)) {
              this.nameCardRecordList[i].hasError = true;
              // ToDo
              str += String.format('{0}' + System.Label.SB_NC_Line + ': {1}', new String[]{ ''+(i+1),result.dbErrors.get(this.nameCardRecordList[i].nameCard.Id).msg + '<br/>'});
            } else{
              this.nameCardRecordList[i].hasError =false;
            }
          }
        }
        str = str.removeEnd('<br/>');
        throw new SB_NameCard_LeadRegist.LeadRegistException(result.title + str);
      } else {
        this.hasError = false;
      }
    }
    catch (Exception e) {
      if (sp != null) Database.rollback(sp);
      this.hasError = true;
      saveOK = false;
      System.debug(e.getMessage());
      //SV_DEV-770 コストの高かったaddMessages(e)処理を取り止め、ApexPages.Messageをセットする仕様に変更しました
      //testError = e.getMessage();
      //ApexPages.addMessages(e);
      ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
      ApexPages.addMessage(errMsg);
    }
    //return pageRef;
  }
}