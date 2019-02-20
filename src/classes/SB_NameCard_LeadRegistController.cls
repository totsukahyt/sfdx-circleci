/*
 * (c) 2016 Sunbridge Inc.
 *
 * リードに登録
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

    //
    public String registerToLeadLabel{get;set;}
    public String overwriteLeadInfoLabel{get;set;}
    public String createNewLeadLabel{get;set;}
    public String specifiedWhenCreateNew{get;set;}

    public Boolean isAllowDuplicateSave { get; private set; }

    public SB_NameCard_LeadRegistController(ApexPages.StandardController sc)
    {
        try {
            this.createNewLeadLabel = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Label_CreateNewLeadDEV);

            this.registerToLeadLabel = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Text_RegisterToLeadDEV);

            this.overwriteLeadInfoLabel = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Label_OverwriteLeadInfoDEV);

            this.specifiedWhenCreateNew = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Text_SpecifiedWhenCreateNew);

            this.lead = new Lead();
            this.searchType = SB_NameCard_LeadRegist.SEARCHTYPE_EMAIL;
            this.leadRecordListIndex = -1;
            this.lookUpIndex = -1;
            this.leadRecordList = new List<LeadRecord>();
            this.todo = new Task();
            this.isAllowDuplicateSave = false;

            this.leadOverwrite = this.svConfig.overwrite();
            this.todo.Subject  = this.svConfig.todoSubject();
            this.registTodo    = this.svConfig.registTodo();

            this.nameCard = SB_NameCard_LeadRegist.getNameCard(sc.getId());
            //if (this.nameCard == null) throw new SB_NameCard_LeadRegist.LeadRegistException('名刺がみつかりません');
            if (this.nameCard == null) throw new SB_NameCard_LeadRegist.LeadRegistException(System.Label.SB_NCLD_Msg_BusinessCardNotFound);

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

    // 検索条件
    public static List<SelectOption> getSearchTypeList()
    {
        return SB_NameCard_LeadRegist.getSearchTypeList();
    }

    // 検索
    public void search()
    {
        this.leadRecordList.clear();

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
                          
                if (this.nameCard.OwnerId == null) {
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
                lead = SB_NameCard_LeadRegist.getLead(leadId, this.nameCard, ownerId);
            } else {
                lead = new Lead(Id=leadId, NameCard__c = this.namecard.Id);
            }
            sp = Database.setSavepoint();
            List<Lead>leads = new List<Lead>();
            leads.add(lead);

            // リード
            this.upsertLead(leads, leadRec.isNew);

            // キャンペーン
            if (this.nameCard.campaign__c != null && (leadRec.isNew || this.campaign != this.nameCard.campaign__c)) { //try
             Database.DMLOptions dml = new Database.DMLOptions();

             dml.OptAllOrNone = false;
            
             List< CampaignMember > cas = new List< CampaignMember >();
              cas.add(new CampaignMember(CampaignId=this.nameCard.campaign__c, LeadId=lead.Id, ContactId=this.nameCard.SmartViscaf__contact__c));
             
              SB_NameCard_LeadCrudFls.screate(cas,dml);
            }

            // 名刺
            
              Database.DMLOptions namecarddml = new Database.DMLOptions();
             
              namecarddml.OptAllOrNone = false;
             
              List< SmartViscaf__NameCard__c > names = new List< SmartViscaf__NameCard__c >();
             
            if (this.nameCard.campaign__c != null && this.nameCard.campaign__c != this.campaign) {
             
                names.add(new SmartViscaf__NameCard__c(Id=this.nameCard.Id, SmartViscaf__lead__c=lead.Id, Campaign__c=this.nameCard.campaign__c));
                
                SB_NameCard_LeadCrudFls.supdate(names, namecarddml);
            } else if (this.nameCard.SmartViscaf__lead__c != lead.Id) {
            
                names.add(new SmartViscaf__NameCard__c(Id=this.nameCard.Id, SmartViscaf__lead__c=lead.Id));
                
                SB_NameCard_LeadCrudFls.supdate(names, namecarddml);
            }

            // ToDo
            if (this.registTodo) {
                 Database.DMLOptions dml = new Database.DMLOptions();
                
                 dml.OptAllOrNone = false;
                
                 List< Task > todos = new List< Task >();
                
                 todos.add(SB_NameCard_LeadRegist.getTodo(lead.Id, ownerId, this.todo.Subject, this.todo.ActivityDate,this.todo.Description));
                           SB_NameCard_LeadCrudFls.screate(todos,dml);

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
        //List<Lead> objets = new List<Lead>();
        //objets.add(lead);
        Database.SaveResult sr = isInsert ? SB_NameCard_LeadCrudFls.screate(lead, dmlOpts)[0] : SB_NameCard_LeadCrudFls.supdate(lead, dmlOpts)[0];
        if (sr.isSuccess()) return;

        for (Database.Error err : sr.getErrors()) {
            if (err.getStatusCode() == StatusCode.DUPLICATES_DETECTED) {
                // Datacloud.DuplicateResult
                Datacloud.DuplicateResult duplicateResult = ((Database.DuplicateError)err).getDuplicateResult();
                this.isAllowDuplicateSave = duplicateResult.isAllowSave();
                throw new SB_NameCard_LeadRegist.LeadRegistException(duplicateResult.getErrorMessage());
            } else {
                throw new SB_NameCard_LeadRegist.LeadRegistException(err.getMessage());
            }
        }
    }

    // キャンセル
    public PageReference cancel()
    {
        if (this.nameCard == null) return null;
        return (new ApexPages.StandardController(this.nameCard)).view();
    }
}