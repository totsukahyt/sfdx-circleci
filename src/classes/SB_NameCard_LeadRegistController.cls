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
 *                        SV_DEV-542 重複エラーが出たときのラジオボタン選択について
 *                        SV_DEV-760 既存リードを更新した場合に名刺のキャンペーン項目が更新される。
 */

public with sharing class SB_NameCard_LeadRegistController
{
    public class LeadRegistControllerException extends exception {}
    public class LeadRecord
    {
        public Integer index { get; set; }
        public Lead lead { get; set; }
        public SmartViscaf__NameCard__c lookUpNameCard { get; set; }
        public Boolean isNew { get; set; }

        public LeadRecord(Integer index, Lead lead)
        {
            this.index = index;
            this.lead = lead;
            this.isNew = false;
        }

        public LeadRecord(Integer index, Boolean isLookup)
        {
            this.index = index;

            if (isLookUp) {
                this.lookUpNameCard = new SmartViscaf__NameCard__c();
                this.isNew = false;
            } else {
                this.isNew = true;
            }
        }
    }

    public SmartViscaf__NameCard__c nameCard { get; set; }
    public Lead lead { get; set; }

    public SB_NameCard_LeadRegist.svConfig svConfig { get { return SB_NameCard_LeadRegist.svConfig; } }
    public Integer searchType { get; set; }
    public Integer leadRecordListIndex { get; set; }
    public Integer lookUpIndex { get; set; }
    public List<LeadRecord> leadRecordList { get; set; }
    public Boolean leadOverwrite { get; set; }

    public Task todo { get; set; }
    public Boolean registTodo { get; set; }

    private Map<Integer, String> soqlMap = new Map<Integer, String>();
    private List<Id> emailIdList = new List<Id>();
    private List<String> emailList = new List<String>();
    private List<Id> nameIdList = new List<Id>();
    private Set<String> nameSet = new Set<String>();
    private Set<String> lastNameSet = new Set<String>();
    private Set<String> firstNameSet = new Set<String>();
    private Id campaign;
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

    //SV_DEV-175 リード登録時にキャンペーン内での状況を選択
    public String campStatus{get;set;} //キャンペーンStatus
    public Boolean campDisabled{get;set;} //キャンペーンStatus Disabled フラグ
    public Boolean campLookUpDisabled{get;set;} //キャンペーン Disabled フラグ
    public  List<SelectOption> campaignStatus {get; set;}


    public Boolean isAllowDuplicateSave { get; private set; }

    //すべてのレコードタイプを取得
    private static final List<RecordTypeInfo> LEADRECORDTYPES = SB_NameCard_LeadRegistController.getRecordType('Lead');

    public SB_NameCard_LeadRegistController(ApexPages.StandardController sc)
    {
        try {

            this.leadCreateable = Schema.getGlobalDescribe().get('Lead').getDescribe().isCreateable();

            this.createNewLeadLabel = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Label_CreateNewLeadDEV);

            this.registerToLeadLabel = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Text_RegisterToLeadDEV);

            this.overwriteLeadInfoLabel = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Label_OverwriteLeadInfoDEV);

            this.specifiedWhenCreateNew = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Text_SpecifiedWhenCreateNew);

            this.leadRecTypeEdit = leadCreateable && LEADRECORDTYPES.size() > 1;

            this.canEditTodo = true;

            this.campLookUpDisabled = !SmartViscaf__NameCard__c.campaign__c.getDescribe().isAccessible();

            this.campDisabled = !Schema.getGlobalDescribe().get('CampaignMember').getDescribe().isCreateable() || campLookUpDisabled;

            this.searchType = SB_NameCard_LeadRegist.SEARCHTYPE_EMAIL;
            this.leadRecordListIndex = -1;
            this.lookUpIndex = -1;
            this.leadRecordList = new List<LeadRecord>();
            this.todo = new Task();
            this.isAllowDuplicateSave = false;

            this.leadOverwrite = this.svConfig.overwrite();
            this.todo.Subject  = this.svConfig.todoSubject();
            this.registTodo    = this.svConfig.registTodo();
            // SV_DEV-747 リード拡張パッケージのカスタム設定：リードに登録 リードレコードタイプ表示の初期値がOFF
            this.showLeadRecType = LEADRECORDTYPES.size() > 1 && this.svConfig.leadRectype();

            // SV_DEV-753 リードに登録（個別画面）でキャンペーン選択後の「キャンペーンメンバー状況」の値がデフォルト値にならない。
            if (String.isNotBlank(this.namecard.campaign__c)) {
                campStatus = this.namecard.campaign__r.Status;
            }

            //レコードタイプに関する設定
            setRecord();

            this.nameCard = SB_NameCard_LeadRegist.getNameCard(sc.getId());
            this.campaignStatus = getCampaign();
            this.lead = new Lead(OwnerId=this.nameCard.OwnerId);
            //if (this.nameCard == null) throw new SB_NameCard_LeadRegist.LeadRegistException('名刺がみつかりません');
            if (this.nameCard == null) {
                throw new SB_NameCard_LeadRegist.LeadRegistException(System.Label.SB_NCLD_Msg_BusinessCardNotFound);
            }

            if (String.isBlank(this.nameCard.SmartViscaf__email__c) && (String.isNotBlank(this.nameCard.SmartViscaf__person_name_last__c) || String.isNotBlank(this.nameCard.SmartViscaf__person_name_first__c))) {
                this.searchType = SB_NameCard_LeadRegist.SEARCHTYPE_NAME;
            }
            this.todo.ActivityDate = this.nameCard.SmartViscaf__card_exchange_date__c;
            this.campaign = this.nameCard.Campaign__c;

            List<SmartViscaf__NameCard__c> ncList = new List<SmartViscaf__NameCard__c> { this.nameCard };
            SB_NameCard_LeadRegist.setEmailSoql(this.soqlMap, this.emailIdList, this.emailList, ncList);
            //SB_NameCard_LeadRegist.setNameSoql(this.soqlMap, this.nameIdList, this.nameSet, ncList);
            SB_NameCard_LeadRegist.setLastFirstNameSoql(this.soqlMap, this.nameIdList, this.nameSet,this.lastNameSet,this.firstNameSet, ncList);
            this.search();
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
    }

    //レコードタイプをに関する初期設定
    public void setRecord() {
        leadRecordTypeId = SB_NameCard_LeadRegistController.defaultRecordType('Lead');
        leadRecType = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Label_LeadRecType);
    }

    public void checkRadio() {
        LeadRecord lea = this.leadRecordList[this.leadRecordListIndex];

        if (Schema.getGlobalDescribe().get('Lead').getDescribe().isCreateable()) {
            this.leadRecTypeEdit = lea.lookUpNameCard == null && lea.lead == null && LEADRECORDTYPES.size() > 1;
        }
    }

    //リードレコードタイプ選択リストoptopn
    public List<SelectOption> getleadRecordTypeOptions() {
        List<SelectOption> options = new List<SelectOption>();
        for (RecordTypeInfo r : LEADRECORDTYPES) {
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
    public static List<SelectOption> getSearchTypeList()
    {
        return SB_NameCard_LeadRegist.getSearchTypeList();
    }

    // 検索
    public void search()
    {
        this.leadRecordList.clear();
        // SV_DEV-542 重複エラーが出たときのラジオボタン選択について
        this.leadRecordListIndex = -1;

        try {
            List<Lead> leadList = this.getLeadList();

            if (leadList != null) {
            Integer Leadnumber = Schema.getGlobalDescribe().get('Lead').getDescribe().isCreateable() ? 998 : 999;
                if (leadList.size() <= Leadnumber) {
                    for (Lead lead : leadList) {
                        this.leadRecordList.add(new leadRecord(this.leadRecordList.size(), lead));
                    }
                } else {
                        for (Lead lead : leadList) {
                                if (lead.Id == this.nameCard.SmartViscaf__lead__c) {
                            this.leadRecordList.add(new leadRecord(this.leadRecordList.size(), lead));
                                }
                                String str = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Msg_DisplayUnderConditionsDEV);

                                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, '検索件数が制限を超えたので過去に登録したリードだけに絞って表示します。'));
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,str));
                        }
                }
            }
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
        this.leadRecordList.add(new leadRecord(this.leadRecordList.size(), true));
       if(Schema.getGlobalDescribe().get('Lead').getDescribe().isCreateable())
         {
           this.leadRecordList.add(new leadRecord(this.leadRecordList.size(), false));
         }

    }

    // リード
    private List<Lead> getLeadList()
    {
        String soql = this.soqlMap.get(this.searchType);
        if (String.isBlank(soql)) return null;
        System.debug(soql);
        return Database.query(soql);
    }

    // リードルックアップ
    public void setLookUp()
    {
        try {
            if (this.lookUpIndex >= this.leadRecordList.size()) return;
            LeadRecord leadRec = this.leadRecordList.get(this.lookUpIndex);
            Id leadId = leadRec.lookUpNameCard.SmartViscaf__lead__c;
            if (leadId == null) return;

            for (Lead lead : [SELECT Id, Company, State, Title, Name, Email, LastModifiedDate, OwnerId, Owner.Name FROM Lead WHERE Id = :leadId]) {
                leadRec.lead = lead;
            }
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
    }

    // 保存
    public PageReference save()
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

                Schema.DescribeSObjectResult tar = Schema.getGlobalDescribe().get('Lead').getDescribe();
                if(!Schema.getGlobalDescribe().get('Lead').getDescribe().isCreateable())
                {
                    throw new LeadRegistControllerException(String.format(System.Label.SB_NCLD_MSG_CrudNotCreateable,new String[]{tar.label})) ;
                }

                if (this.lead.OwnerId == null) {
                    String str = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Msg_SpecifyOwnerWhenCreateLeadDEV);

                    //throw new SB_NameCard_LeadRegist.LeadRegistException('リードを新規作成する場合は「所有者」を指定してください');
                    throw new SB_NameCard_LeadRegist.LeadRegistException(str);
                }
                ownerId = this.lead.OwnerId;
            } else {
              Schema.DescribeSObjectResult tar = Schema.getGlobalDescribe().get('Lead').getDescribe();

                 if(!Schema.getGlobalDescribe().get('Lead').getDescribe().isUpdateable())
                   {
                       throw new LeadRegistControllerException(String.format(System.Label.SB_NCLD_MSG_CrudNotUpdateable, new String[]{tar.label}));
                   }

                if (leadRec.lead == null) {
                    String str = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Msg_SelectLeadDEV);

                    //throw new SB_NameCard_LeadRegist.LeadRegistException('リードを選択してください');
                    throw new SB_NameCard_LeadRegist.LeadRegistException(str);
                }
                leadId = leadRec.lead.Id;
                ownerId = leadRec.lead.OwnerId;
            }
            Lead lead;
            if (this.leadOverwrite || leadRec.isNew) {
                lead = SB_NameCard_LeadRegist.getLead(leadId, this.nameCard, ownerId,this.leadRecTypeEdit == true ? this.leadRecordTypeId : null);
            } else {
                lead = new Lead(Id=leadId, NameCard__c = this.namecard.Id);
            }
            sp = Database.setSavepoint();
            List<Lead>leads = new List<Lead>();
            leads.add(lead);

            // リード
            this.upsertLead(leads, leadRec.isNew);

            // キャンペーン
            //SV_DEV-750 既存リードの更新時にもキャンペーンの選択が反映される。
            if (this.nameCard.campaign__c != null && leadRec.isNew) { //try
                //名刺キャンペーン参照権限がない場合エラー情報を出します
                if (!Schema.sObjectType.SmartViscaf__NameCard__c.Fields.campaign__c.isAccessible()) {
                    String er = String.format(System.Label.SB_NCLD_MSG_FlsNotAccessible,new String[]{SmartViscaf__NameCard__c.sObjectType.getDescribe().getLabel(), 
                                              Schema.sObjectType.SmartViscaf__NameCard__c.Fields.campaign__c.getLabel(), 'campaign__c'});
                    throw new SB_NameCard_LeadRegist.LeadRegistException(er);
                }

                Database.DMLOptions dml = new Database.DMLOptions();

                dml.OptAllOrNone = false;

                List< CampaignMember > cas = new List< CampaignMember >();
                System.debug('this.campStatus' + this.campStatus);
                //キャンペーンメンバーを新規作成
                //SV_DEV-175 リード登録時にキャンペーン内での状況を選択
                //SV_DEV-751 リードに登録で追加された、キャンペーンメンバーの種別が「取引先責任者」になる。
                cas.add(new CampaignMember(CampaignId=this.nameCard.campaign__c, LeadId=lead.Id, Status = this.campStatus));

                SB_NameCard_LeadCrudFls.screate(cas,dml);
            }

            //ToDo更新するのはキャンペーン? キャンペーンメンバ?

             //if (this.nameCard.campaign__c != null && leadRec.isNew) {
             //   Campaign c = [Select Id,Status From Campaign Where Id = :this.namecard.Campaign__c];
             //   c.Status = this.campStatus;
             //   Database.DMLOptions dml = new Database.DMLOptions();

             //   dml.OptAllOrNone = false;
             //   SB_NameCard_LeadCrudFls.supdate(new List<Campaign>{c},dml);
             //}


            // 名刺

            Database.DMLOptions namecarddml = new Database.DMLOptions();

            namecarddml.OptAllOrNone = false;

            List< SmartViscaf__NameCard__c > names = new List< SmartViscaf__NameCard__c >();

            if (this.nameCard.campaign__c != null && this.nameCard.campaign__c != this.campaign) {
                //SV_DEV-760 既存リードを更新した場合に名刺のキャンペーン項目が更新される。
                //新規の場合のみCampaign__c設定
                if (leadRec.isNew) {
                    names.add(new SmartViscaf__NameCard__c(Id=this.nameCard.Id, SmartViscaf__lead__c=pageLead.Id, Campaign__c=this.nameCard.campaign__c));
                } else {
                    names.add(new SmartViscaf__NameCard__c(Id=this.nameCard.Id, SmartViscaf__lead__c=pageLead.Id));
                }

                SB_NameCard_LeadCrudFls.supdate(names, namecarddml);
            } else if (this.nameCard.SmartViscaf__lead__c != lead.Id) {

                names.add(new SmartViscaf__NameCard__c(Id=this.nameCard.Id, SmartViscaf__lead__c=lead.Id));

                SB_NameCard_LeadCrudFls.supdate(names, namecarddml);
            }

            // ToDo
            if (this.registTodo) {
                // SV_DEV-727 リードへ登録、名刺所有者がキューおよリード所有者がキューの場合
                if (!String.valueOf(ownerId).startsWith('005')) {
                    throw new SB_NameCard_LeadRegist.LeadRegistException(System.Label.SB_NCLD_MSG_QUEUES_ERROR);
                }
                Database.DMLOptions dml = new Database.DMLOptions();

                dml.OptAllOrNone = false;

                List< Task > todos = new List< Task >();

                todos.add(SB_NameCard_LeadRegist.getTodo(lead.Id, ownerId, this.todo.Subject, this.todo.ActivityDate,this.todo.Description));
                SB_NameCard_LeadCrudFls.screate(todos,dml);
            }
            pageRef = (new ApexPages.StandardController(lead)).view();
        } catch (Exception e) {
            if (sp != null) Database.rollback(sp);

            ApexPages.addMessages(e);
        }
        return pageRef;
    }

    // リード
    private void upsertLead(List<Lead> lead, Boolean isInsert)
    {
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.DuplicateRuleHeader.allowSave = this.isAllowDuplicateSave; // 重複レコードを保存するか
        System.debug(lead);
        List<Database.SaveResult> sr = isInsert ? SB_NameCard_LeadCrudFls.screate(lead, dmlOpts) : SB_NameCard_LeadCrudFls.supdate(lead, dmlOpts);
        if (sr[0].isSuccess()) return;
        SB_NameCard_LeadSaveResult dbError = new SB_NameCard_LeadSaveResult();
        dbError.putSaveResults(sr);
         if (dbError.isError())
        {
            this.isAllowDuplicateSave = dbError.isAllowSave();
            String msg = lead[0].getSObjectType().getDescribe().getLabel() + ': ' + dbError.getDbErrorHolder(0).msg;
            throw new SB_NameCard_LeadRegist.LeadRegistException(msg);
        }
        //for (Database.Error err : sr[0].getErrors()) {
        //    if (err.getStatusCode() == StatusCode.DUPLICATES_DETECTED) {
        //        // Datacloud.DuplicateResult
        //        Datacloud.DuplicateResult duplicateResult = ((Database.DuplicateError)err).getDuplicateResult();
        //        this.isAllowDuplicateSave = duplicateResult.isAllowSave();
        //        String msg = lead[0].getSObjectType().getDescribe().getLabel() + ': ' + dbError.getDbErrorHolder(0).msg;
        //        throw new SB_NameCard_LeadRegist.LeadRegistException(msg);
        //    } else {
        //        throw new SB_NameCard_LeadRegist.LeadRegistException(err.getMessage());
        //    }
        //}
    }

    //オブジェクトでフォールトのレコードタイプIDを取得
    public static String defaultRecordType(String sobjectname){
        String recordTypeId;
        List<Schema.RecordTypeInfo> rs =  Schema.getGlobalDescribe().get(sobjectname).getDescribe().getRecordTypeInfos();
        for (RecordTypeInfo r : rs) {
            if (r.isDefaultRecordTypeMapping() && r.isAvailable()) {
                 recordTypeId =  r.getRecordTypeId();
            }
        }
          return recordTypeId;
    }

    //レコードタイプを取得
    public static List<RecordTypeInfo> getRecordType(String sobjectname){

        List<Schema.RecordTypeInfo> rs =  Schema.getGlobalDescribe().get(sobjectname).getDescribe().getRecordTypeInfos();
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