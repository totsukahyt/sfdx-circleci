/*
 * (c) 2016 Sunbridge Inc.
 *
 * リードに登録this.isAllowDuplicateSave;
 *
 * @Version 1 2018/01/XX  SV_DEV-753 リードに登録（個別画面）でキャンペーン選択後の「キャンペーンメンバー状況」の値がデフォルト値にならない。
 *                        SV_DEV-747 リード拡張パッケージのカスタム設定：リードに登録 リードレコードタイプ表示の初期値がOFF
 *                        SV_DEV-727 リードへ登録、名刺所有者がキューおよリード所有者がキューの場合
 *                        SV_DEV-751 リードに登録で追加された、キャンペーンメンバーの種別が「取引先責任者」になる。
 *                        SV_DEV-750 既存リードの更新時にもキャンペーンの選択が反映される。
 *                        SV_DEV-762 名刺オブジェクトの編集権限がない場合にリードに登録の処理が終了しない。
 *                        SV_DEV-542 重複エラーが出たときのラジオボタン選択について
 *                        SV_DEV-760 既存リードを更新した場合に名刺のキャンペーン項目が更新される。
 *                        SV_DEV-565 リード登録のリード所有者の修正
 * @Version 1。12 2018/03/XX  SV_DEV-715 「取引先・取引先責任者に登録」の更新時のTodoの任命先は取引先責任者の所有者にする
 *
 */

public with sharing class SB_NameCard_LeadRegistController {
  public class LeadRegistControllerException extends exception {}
  public class LeadRecord {
    public Integer index { get; set; }
    public Lead pageLead { get; set; }
    public SmartViscaf__NameCard__c lookUpNameCard { get; set; }
    public Boolean isNew { get; set; }

    public LeadRecord(Integer index, Lead lead) {
      this.index = index;
      this.pageLead = lead;
      this.isNew = false;
    }

    public LeadRecord(Integer index, Boolean isLookup) {
      this.index = index;

      if (isLookUp) {
        this.lookUpNameCard = new SmartViscaf__NameCard__c();
        this.isNew = false;
      } else {
        this.isNew = true;
      }
    }
  }

  //テスト addMessageキャッチ用
  @TestVisible
  private String testError;

  public SmartViscaf__NameCard__c nameCard { get; set; }
  public Lead pageLead { get; set; }

  public SB_NameCard_LeadRegist.svConfig svConfig { get { return SB_NameCard_LeadRegist.svConfig; } }
  public Integer searchType { get; set; }
  public Integer leadRecordListIndex { get; set; }
  public Integer lookUpIndex { get; set; }
  public List<LeadRecord> leadRecordList { get; set; }
  public Boolean leadOverwrite { get; set; }
  public Boolean showLeadOverwrite { get; set; }

  public Task todo { get; set; }
  public Boolean registTodo { get; set; }

  private Map<Integer, String> soqlMap = new Map<Integer, String>();
  private List<Id> emailIdList = new List<Id>();
  private List<String> emailList = new List<String>();
  private List<Id> nameIdList = new List<Id>();
  private Set<String> nameSet = new Set<String>();
  private Set<String> lastNameSet = new Set<String>();
  private Set<String> firstNameSet = new Set<String>();
  public   Boolean  canEditTodo{get;set;}

  //
  public String registerToLeadLabel{get;set;}
  public String overwriteLeadInfoLabel{get;set;}
  public String createNewLeadLabel{get;set;}
  public String specifiedWhenCreateNew{get;set;}
  public Boolean leadCreateable{get;set;}
  public Boolean leadRecTypeEdit{get; private set;} //リードレコードタイプを変更できるflag
  public Boolean showLeadRecType{get;private set;} //リードレコードタイプ選択を表示フラグ
  public String leadRecType{get;set;}    //ラベルSB_NCLD_Label_LeadRecType リードレコードタイプ
  public String leadRecordTypeId{get;set;} //リードレコードタイプID
  public Boolean cannotUpdataLead{get; private set;}//取引先責任者更新不可フラグ

  //SV_DEV-175 リード登録時にキャンペーン内での状況を選択
  public String campStatus{get;set;} //キャンペーンStatus
  public Boolean campDisabled{get;set;} //キャンペーンStatus Disabled フラグ
  public Boolean campLookUpDisabled{get;set;} //キャンペーン Disabled フラグ
  public  List<SelectOption> campaignStatus {get; set;}

  private static final String LEADLABEL = Lead.sObjectType.getDescribe().getLabel();


  public Boolean isAllowDuplicateSave { get; private set; }

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

    public SB_NameCard_LeadRegistController(ApexPages.StandardController sc) {
      try {

        this.leadCreateable = Lead.sObjectType.getDescribe().isCreateable();

        // --------------------- changelabel start ---------------------
        // this.createNewLeadLabel = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Label_CreateNewLeadDEV);
        this.createNewLeadLabel = String.format(System.Label.SB_NCLD_Label_CreateNewLeadDEV, new String[] {LEADLABEL});
        // this.registerToLeadLabel = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Text_RegisterToLeadDEV);
        this.registerToLeadLabel = String.format(System.Label.SB_NCLD_Text_RegisterToLeadDEV, new String[] {LEADLABEL});
        // this.overwriteLeadInfoLabel = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Label_OverwriteLeadInfoDEV);
        this.overwriteLeadInfoLabel = String.format(System.Label.SB_NCLD_Label_OverwriteLeadInfoDEV, new String[] {LEADLABEL});
        // this.specifiedWhenCreateNew = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Text_SpecifiedWhenCreateNew);
        this.specifiedWhenCreateNew = String.format(System.Label.SB_NCLD_Text_SpecifiedWhenCreateNew, new String[] {LEADLABEL});
        // --------------------- changelabel end ---------------------

        this.leadRecTypeEdit = leadCreateable && leadRecordTypes.size() > 1;

        this.canEditTodo = true;

        this.campLookUpDisabled = !SmartViscaf__NameCard__c.campaign__c.getDescribe().isAccessible();

        this.campDisabled = !CampaignMember.sObjectType.getDescribe().isCreateable() || campLookUpDisabled;

        this.searchType = SB_NameCard_LeadRegist.SEARCHTYPE_EMAIL;
        this.leadRecordListIndex = -1;
        this.lookUpIndex = -1;
        this.leadRecordList = new List<LeadRecord>();
        this.todo = new Task();
        this.isAllowDuplicateSave = false;

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
        this.todo.Subject = baseSetting.SmartViscaf__RegistToDoSubject__c;
        if (String.isBlank(this.todo.Subject)) {
          this.todo.Subject = System.Label.SB_NCLD_Text_BusinessCardExchange;
        }
        this.registTodo = !baseSetting.SmartViscaf__RegistNoToDo__c;
        // SV_DEV-747 リード拡張パッケージのカスタム設定：リードに登録 リードレコードタイプ表示の初期値がOFF
        this.showLeadRecType = leadRecordTypes.size() > 1 && baseSetting.SmartViscaf__RegistDispLeadRectype__c;

        // SV_DEV-753 リードに登録（個別画面）でキャンペーン選択後の「キャンペーンメンバー状況」の値がデフォルト値にならない。
        if (String.isNotBlank(this.namecard.campaign__c)) {
          campStatus = this.namecard.campaign__r.Status;
        }

        //レコードタイプに関する設定
        setRecord();

        this.nameCard = SB_NameCard_LeadRegist.getNameCard(sc.getId());
        this.pageLead = new Lead();
        this.campaignStatus = getCampaign();
        if (this.nameCard.Owner.IsActive) {
          if (this.nameCard.OwnerId.getSObjectType() == User.getSobjectType()) {
             this.pageLead = new Lead(OwnerId=this.nameCard.OwnerId);
          }
          else {
            List<QueueSobject> qss = [Select QueueId, SobjectType, Queue.Name
                                    FROM QueueSobject
                                   WHERE QueueId = :this.nameCard.OwnerId
                                     AND SobjectType = 'Lead'];
            if (qss.size() > 0) {
                this.pageLead = new Lead(OwnerId = this.nameCard.OwnerId);
            }
          }
        }

        //if (this.nameCard == null) throw new SB_NameCard_LeadRegist.LeadRegistException('名刺がみつかりません');
        if (this.nameCard == null) {
          throw new SB_NameCard_LeadRegist.LeadRegistException(System.Label.SB_NCLD_Msg_BusinessCardNotFound);
        }

        if (nameCard.SmartViscaf__company_name__c == null || String.isBlank(SmartViscaf.SB_NameCard_Util.getPersonName(nameCard).get('last_name'))) {
          if (!SmartViscaf.SB_NameCard_Util.isEnablePersonAccount()) {
            throw new SB_NameCard_LeadRegist.LeadRegistException(System.Label.SB_NCLD_MSG_CompanyNameMissing);
          }
          else if (String.isBlank(SmartViscaf.SB_NameCard_Util.getPersonName(nameCard).get('last_name'))) {
            throw new SB_NameCard_LeadRegist.LeadRegistException(System.Label.SB_NCLD_MSG_NameMissing);
          }
        }

        if (String.isBlank(this.nameCard.SmartViscaf__email__c) && (String.isNotBlank(this.nameCard.SmartViscaf__person_name_last__c) || String.isNotBlank(this.nameCard.SmartViscaf__person_name_first__c))) {
          this.searchType = SB_NameCard_LeadRegist.SEARCHTYPE_NAME;
        }
        this.todo.ActivityDate = this.nameCard.SmartViscaf__card_exchange_date__c;

        List<SmartViscaf__NameCard__c> ncList = new List<SmartViscaf__NameCard__c> { this.nameCard };
        SB_NameCard_LeadRegist.setEmailSoql(this.soqlMap, this.emailIdList, this.emailList, ncList);
        //SB_NameCard_LeadRegist.setNameSoql(this.soqlMap, this.nameIdList, this.nameSet, ncList);
        SB_NameCard_LeadRegist.setLastFirstNameSoql(this.soqlMap, this.nameIdList, this.nameSet,this.lastNameSet,this.firstNameSet, ncList);
        this.search();
      } catch (Exception e) {
        ApexPages.addMessages(e);
        testError = e.getMessage();
      }
    }

    //レコードタイプをに関する初期設定
    public void setRecord() {
      // leadRecType = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Label_LeadRecType);
      leadRecType = String.format(System.Label.SB_NCLD_Label_LeadRecType, new String[] {LEADLABEL});
    }

    public void checkRadio() {
      LeadRecord lea = this.leadRecordList[this.leadRecordListIndex];

      if (Lead.sObjectType.getDescribe().isCreateable()) {
        this.leadRecTypeEdit = lea.lookUpNameCard == null && lea.pageLead == null && leadRecordTypes.size() > 1;
      }
    }

    //リードレコードタイプ選択リストoptopn
    public List<SelectOption> getleadRecordTypeOptions() {
      List<SelectOption> options = new List<SelectOption>();
      for (RecordTypeInfo r : leadRecordTypes) {
        options.add(new SelectOption(r.getRecordTypeId(), r.getName()));
      }
      return options;
    }

    public void changeCampaign() {
      this.campaignStatus = getCampaign();
    }

    //SV_DEV-175 リード登録時にキャンペーン内での状況を選択
    public  List<SelectOption> getCampaign() {
      List<SelectOption> options = new List<SelectOption>();
      //キャンペーンがない時登録しないで表示
      List<CampaignMemberStatus> cpms = [SELECT id, CampaignID, HasResponded, IsDefault, Label, SortOrder
                                      FROM CampaignMemberStatus Where CampaignId = :namecard.campaign__c];
      for (CampaignMemberStatus f: cpms) {
        if (f.IsDefault == true) {
          campStatus = f.Label;
        }
        options.add(new SelectOption(f.Label, f.Label));
      }
      campDisabled = options.size() <= 0 || campLookUpDisabled;
      return options;
    }

    // 検索条件
    public static List<SelectOption> getSearchTypeList() {
      return SB_NameCard_LeadRegist.getSearchTypeList();
    }

    // 検索
    public void search() {
      this.leadRecordList.clear();
      // SV_DEV-542 重複エラーが出たときのラジオボタン選択について
      this.leadRecordListIndex = -1;

      try {
        List<Lead> leadList = this.getLeadList();

        if (leadList != null) {
        Integer Leadnumber = Lead.sObjectType.getDescribe().isCreateable() ? 998 : 999;
          if (leadList.size() <= Leadnumber) {
            for (Lead lead : leadList) {
              this.leadRecordList.add(new leadRecord(this.leadRecordList.size(), lead));
            }
          } else {
            for (Lead lea : leadList) {
              if (lea.Id == this.nameCard.SmartViscaf__lead__c) {
                this.leadRecordList.add(new leadRecord(this.leadRecordList.size(), lea));
              }
              // String str = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Msg_DisplayUnderConditionsDEV);
              String str = String.format(System.Label.SB_NCLD_Msg_DisplayUnderConditionsDEV, new String[] {LEADLABEL});

              //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, '検索件数が制限を超えたので過去に登録したリードだけに絞って表示します。'));
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,str));
              testError = str;
            }
          }
        }
      } catch (Exception e) {
        ApexPages.addMessages(e);
        testError = e.getMessage();
      }
      this.leadRecordList.add(new leadRecord(this.leadRecordList.size(), true));
      if(Lead.sObjectType.getDescribe().isCreateable()) {
        this.leadRecordList.add(new leadRecord(this.leadRecordList.size(), false));
      }

    }

    // リード
    private List<Lead> getLeadList() {
      String soql = this.soqlMap.get(this.searchType);
      if (String.isBlank(soql)) return null;
      System.debug(soql);
      return Database.query(soql);
    }

    // リードルックアップ
    public void setLookUp() {
      try {
        if (this.lookUpIndex >= this.leadRecordList.size()) return;
        LeadRecord leadRec = this.leadRecordList.get(this.lookUpIndex);
        Id leadId = leadRec.lookUpNameCard.SmartViscaf__lead__c;
        if (leadId == null) return;

        for (Lead lead : [SELECT Id, Company, State, Title, Name, Email, LastModifiedDate, OwnerId, Owner.Name FROM Lead WHERE Id = :leadId]) {
          leadRec.pageLead = lead;
        }
      } catch (Exception e) {
        ApexPages.addMessages(e);
        testError = e.getMessage();
      }
    }

    // 保存
    // SV_DEV-762 名刺オブジェクトの編集権限がない場合にリードに登録の処理が終了しない。
    public PageReference saveLead()
    {
        PageReference pageRef;
        Savepoint sp;

        try {
            if (this.leadRecordListIndex < 0 || this.leadRecordListIndex >= this.leadRecordList.size()) {
                //throw new SB_NameCard_LeadRegist.LeadRegistException('登録先を選択してください');
                throw new SB_NameCard_LeadRegist.LeadRegistException(System.Label.SB_NCLD_Msg_SelectRegisterDestination);
            }
            LeadRecord leadRec = this.leadRecordList.get(this.leadRecordListIndex);
            Id leadId, ownerId;
            if (leadRec.isNew) {

                Schema.DescribeSObjectResult tar = Lead.sObjectType.getDescribe();
                if(!Lead.sObjectType.getDescribe().isCreateable())
                {
                    throw new LeadRegistControllerException(String.format(System.Label.SB_NCLD_MSG_CrudNotCreateable,new String[]{tar.label})) ;
                }

                if (this.pageLead.OwnerId == null) {
                    String str = String.format(System.Label.SB_NCLD_Msg_SpecifyOwnerWhenCreateLeadDEV, new String[]{Lead.sObjectType.getDescribe().getLabel()});

                    //throw new SB_NameCard_LeadRegist.LeadRegistException('リードを新規作成する場合は「所有者」を指定してください');
                    throw new SB_NameCard_LeadRegist.LeadRegistException(str);
                }
                ownerId = this.pageLead.OwnerId;
            } else {
              Schema.DescribeSObjectResult tar = Lead.sObjectType.getDescribe();

                if(!Lead.sObjectType.getDescribe().isUpdateable() && this.leadOverwrite) {
                   throw new LeadRegistControllerException(String.format(System.Label.SB_NCLD_MSG_CrudNotUpdateable, new String[]{tar.label}));
                }

                if (leadRec.pageLead == null) {
                    String str = String.format(System.Label.SB_NCLD_Msg_SelectLeadDEV, new String[]{Lead.sObjectType.getDescribe().getLabel()});

                    //throw new SB_NameCard_LeadRegist.LeadRegistException('リードを選択してください');
                    throw new SB_NameCard_LeadRegist.LeadRegistException(str);
                }
                leadId = leadRec.pageLead.Id;
                ownerId = leadRec.pageLead.OwnerId;
            }
            List<Lead>leads = new List<Lead>();

            // SV_DEV-565 リード登録のリード所有者の修正
            // if (!String.valueOf(ownerId).startsWith('005')) {
            //     List<QueueSobject> qss = [Select QueueId, Queue.Name, SobjectType
            //             FROM QueueSobject
            //            WHERE QueueId = :ownerId];
            //     Boolean canUserLead = false;
            //     String qName = qss[0].Queue.Name;
            //     for (QueueSobject qs : qss) {
            //         if (qs.SobjectType == 'Lead') {
            //             canUserLead = true;
            //             break;
            //         }
            //     }
            //     if (canUserLead == false) {
            //         throw new SB_NameCard_LeadRegist.LeadRegistException(String.format(System.Label.SB_NCLD_MSG_QUEUES_LEAD_ERROR,new String[]{qName}));
            //     }
            // }

            // if (this.registTodo) {
            //     // SV_DEV-727 リードへ登録、名刺所有者がキューおよリード所有者がキューの場合
            //     if (!String.valueOf(ownerId).startsWith('005')) {
            //         throw new SB_NameCard_LeadRegist.LeadRegistException(System.Label.SB_NCLD_MSG_QUEUES_ERROR);
            //     }
            // }



            SB_NameCardL_RegistHelper.RegistParam leadRP = new SB_NameCardL_RegistHelper.RegistParam('Lead', this.leadOverwrite, this.leadRecordTypeId, ownerId, this.isAllowDuplicateSave);
            SB_NameCardL_RegistHelper.TodoParam todoRP = new SB_NameCardL_RegistHelper.TodoParam(this.todo.Subject, this.todo.ActivityDate,this.todo.Description,null);
            SB_NameCardL_RegistHelper.RegistTarget tar = new SB_NameCardL_RegistHelper.RegistTarget(SB_NameCardL_RegistHelper.ProcType.LEAD,
                                                                                                                      this.nameCard.Id,
                                                                                                                      null,
                                                                                                                      null,
                                                                                                                      leadId,
                                                                                                                      registTodo,
                                                                                                                      this.todo.ActivityDate);
            if (String.isNotBlank(this.nameCard.Campaign__c) && String.isBlank(pageLead.Id)) {
              tar.setLeadCampaign(this.nameCard.Campaign__c, campStatus);
            }

            SB_NameCardL_RegistHelper.RegistRequest re = new SB_NameCardL_RegistHelper.RegistRequest(new SB_NameCardL_RegistHelper.RegistTarget[]{tar}, null, null, leadRP, todoRP);
            Map<Id, String> ownerErrorMap = SB_NameCardL_RegistOwenrCheckHelper.doCheck(re);
            System.debug(ownerErrorMap);
            if (!ownerErrorMap.isEmpty()) {
              String str = '';
              if (ownerErrorMap.containsKey(this.nameCard.Id)) {
                str += ownerErrorMap.get(this.nameCard.Id);
              }
              throw new SB_NameCard_LeadRegist.LeadRegistException(str);
            }
            //doRegist内既にrollbackしていますので、ここは二度目はしません
            SB_NameCardL_RegistHelper.RegistResponse result = SB_NameCardL_RegistHelper.doRegist(re);
            if (result.success == false) {
              System.debug(result.title);
              System.debug(result.errorObject);
              System.debug(result.message);
              System.debug(result.dbErrors);
              this.isAllowDuplicateSave = result.allowRetry;
              // this.dispDuplicateCheck = result.allowRetry;
              String str = '';
              if (result.dbErrors != null) {
                str = result.dbErrors.get(this.nameCard.Id).msg;
              }
              str = String.isBlank(str) ? result.title : result.title + '<br/>' + str;
              throw new LeadRegistControllerException(str);
            }
            PageReference retUrl;
            SB_NameCardL_RegistHelper.SObjectInfo le = result.registeds.get(this.nameCard.Id).lead;
            System.debug(le);
            System.debug(result.registeds);
            if (le.Id != null) {
              retUrl = new PageReference('/' + le.Id);
            }
            return retUrl;
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            if (sp != null) Database.rollback(sp);
            ApexPages.addMessages(e);
            testError = e.getMessage();
        }
        return pageRef;
    }

    // リード
    // private void upsertLead(List<Lead> lead, Boolean isInsert)
    // {
    //     Database.DMLOptions dmlOpts = new Database.DMLOptions();
    //     dmlOpts.DuplicateRuleHeader.allowSave = this.isAllowDuplicateSave; // 重複レコードを保存するか
    //     System.debug(lead);
    //     List<Database.SaveResult> sr = isInsert ? SmartViscaf.SB_NameCard_CrudFls.screate(lead, dmlOpts) : SmartViscaf.SB_NameCard_CrudFls.supdate(lead, dmlOpts);
    //     if (sr[0].isSuccess()) return;
    //     SB_NameCard_LeadSaveResult dbError = new SB_NameCard_LeadSaveResult();
    //     dbError.putSaveResults(sr);
    //      if (dbError.isError())
    //     {
    //         this.isAllowDuplicateSave = dbError.isAllowSave();
    //         String msg = lead[0].getSObjectType().getDescribe().getLabel() + ': ' + dbError.getDbErrorHolder(0).msg;
    //         throw new SB_NameCard_LeadRegist.LeadRegistException(msg);
    //     }
    //     //for (Database.Error err : sr[0].getErrors()) {
    //     //    if (err.getStatusCode() == StatusCode.DUPLICATES_DETECTED) {
    //     //        // Datacloud.DuplicateResult
    //     //        Datacloud.DuplicateResult duplicateResult = ((Database.DuplicateError)err).getDuplicateResult();
    //     //        this.isAllowDuplicateSave = duplicateResult.isAllowSave();
    //     //        String msg = lead[0].getSObjectType().getDescribe().getLabel() + ': ' + dbError.getDbErrorHolder(0).msg;
    //     //        throw new SB_NameCard_LeadRegist.LeadRegistException(msg);
    //     //    } else {
    //     //        throw new SB_NameCard_LeadRegist.LeadRegistException(err.getMessage());
    //     //    }
    //     //}
    // }

    public void changeOwner()
    {
        if (this.canEditTodo == false) {
            this.registTodo = false;
        }
        //if(String.isNotBlank(this.lead.ownerId)){
        //     if(String.valueOf(this.lead.ownerId).startsWith('005')){
        //        this.canEditTodo = true;
        //    }
        //    else{
        //        this.canEditTodo = false;
        //        this.registTodo = false;
        //    }
        //}
    }

    // キャンセル
    public PageReference cancel()
    {
        if (this.nameCard == null) {
            return null;
        }
        return (new ApexPages.StandardController(this.nameCard)).view();
    }
}