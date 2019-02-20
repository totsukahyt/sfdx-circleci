/*
 * (c) 2016 Sunbridge Inc.
 *
 * リードに一括登録
 */

public with sharing class SB_NameCard_LeadBulkRegistController
{
    public class LeadBulkRegistControllerException extends exception {}
    public String retUrl{get;set;}
    public Boolean useNameCardOwner{get;set;}
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
                 String str = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Msg_DisplayUnderConditionsDEV);

                //this.message = '検索件数が制限を超えたので過去に登録したリードだけに絞って表示します。';
                this.message = str;
            }
            //this.leadSelOptList.add(new SelectOption('new', '新規作成'))
             if(Lead.sObjectType.getDescribe().isCreateable())
             {
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
    public static SmartViscaf__SmartViscaConfig__c smartViscaConfig {
        get{
            if (smartViscaConfig == null){
                smartViscaConfig = SmartViscaf__SmartViscaConfig__c.getInstance(UserInfo.getUserId()); // 個人の設定
                if (smartViscaConfig.Id ==null) {
                     smartViscaConfig = SmartViscaf__SmartViscaConfig__c.getInstance(UserInfo.getProfileId()); //プロファイルの設定
                }
                if (smartViscaConfig.id == null) {
                    smartViscaConfig = SmartViscaf__SmartViscaConfig__c.getOrgDefaults(); // 組織の設定
                }
                if (smartViscaConfig.id == null) {
                    smartViscaConfig.LeadRegist_DispEmail__c = true;
                    smartViscaConfig.LeadRegist_DispLastModifiedDate__c = true;
                    smartViscaConfig.LeadRegist_DispOwner__c = true;
                    smartViscaConfig.LeadRegist_DispState__c = true;
                    smartViscaConfig.LeadRegist_Overwrite__c = true;
                    smartViscaConfig.LeadRegist_DispTitle__c = true;
                    smartViscaConfig.LeadRegist_DispLeadRectype__c = true;
                }
                smartViscaConfig.LeadRegist_TodoSubject__c = String.isBlank(smartViscaConfig.LeadRegist_TodoSubject__c) ? System.Label.SB_NCLD_Text_BusinessCardExchange : smartViscaConfig.LeadRegist_TodoSubject__c;
            }
            return smartViscaConfig;
        }
        set;
    }

    //すべてのレコードタイプを取得
    private static final List<RecordTypeInfo> LEADRECORDTYPES = SB_NameCard_LeadRegistController.getRecordType('Lead');


    public SB_NameCard_LeadBulkRegistController(ApexPages.StandardSetController controller)
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
            this.useNameCardOwner = false;
            
            this.leadCreateable = Lead.sObjectType.getDescribe().isCreateable();

            this.registerToLeadLabel = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Text_RegisterToLeadsDEV);

            this.overwriteLeadInfoLabel = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Label_OverwriteLeadInfoDEV);

            this.specifiedWhenCreateNew = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Text_SpecifiedWhenCreateNew);

            this.showLeadRecType = LEADRECORDTYPES.size() > 1 && smartViscaConfig.LeadRegist_DispLeadRectype__c;

            this.leadRecTypeEdit = leadCreateable && LEADRECORDTYPES.size() > 1;

            this.searchType = SB_NameCard_LeadRegist.SEARCHTYPE_EMAIL;
            this.leadOverwrite = SB_NameCard_LeadRegist.svConfig.overwrite();

            List<SmartViscaf__NameCard__c> ncList = SB_NameCard_LeadRegist.getNameCardList(controller.getSelected());
            this.nameCardRecordList = getNameCardRecordList(ncList, SB_NameCard_LeadRegist.svConfig.registTodo());

            this.insertOption = new SmartViscaf__NameCard__c(OwnerId=UserInfo.getUserId());
            this.ownerlead = new Lead();
            this.hasError = false;

            this.campLookUpDisabled = !SmartViscaf__NameCard__c.campaign__c.getDescribe().isAccessible();

            this.campDisabled = true;

            //リードに関する設定
            setRecord();

            SB_NameCard_LeadRegist.setEmailSoql(this.soqlMap, this.emailIdList, this.emailList, ncList);
            //SB_NameCard_LeadRegist.setNameSoql(this.soqlMap, this.nameIdList, this.nameSet, ncList);
            SB_NameCard_LeadRegist.setLastFirstNameSoql(this.soqlMap, this.nameIdList, this.nameSet,this.lastNameSet,this.firstNameSet,ncList);
            this.search();
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
    }

    //SV_DEV-175 リード登録時にキャンペーン内での状況を選択
    public  List<SelectOption> getCampaignStatus(){
        List<SelectOption> options = new List<SelectOption>();
        if (String.isBlank(insertOption.campaign__c)) {
            options.add(new SelectOption(System.Label.SB_NCLD_Menu_NotToRegister,''));
            return options;
        }
        List<CampaignMemberStatus> cpms = [SELECT id, CampaignID, HasResponded, IsDefault, Label, SortOrder
                                        FROM CampaignMemberStatus Where CampaignId = :insertOption.campaign__c];
        for (CampaignMemberStatus f: cpms) {
            if (f.IsDefault == true) {
                campStatus = f.Label;
            }
            options.add(new SelectOption(f.Label, f.Label));
        }
        campDisabled = options.size() <= 0 || campLookUpDisabled;
        return options;
    }

    //レコードタイプをに関する初期設定
    public void setRecord() {
        leadRecordTypeId = SB_NameCard_LeadRegistController.defaultRecordType('Lead');
        leadRecType = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Label_LeadRecType);
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
                ncRec.setLeadRecord(idMap, emailListMap, nameListMap);
                if (ncRec.message != '') {
                        message = ncRec.message;
                }
            }
            if (message != '') {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, message));
            }
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
    }

    // リード
    private void setLeadMap(Map<Id, Lead> idMap, Map<String, List<Lead>> emailListMap, Map<String, List<Lead>> nameListMap) {
        this.leadOwnerIdMap.clear();
        String soql = this.soqlMap.get(this.searchType);
        if (String.isBlank(soql)) return;
        String name ='';
        for (Lead lead :Database.query(soql)) {
            idMap.put(lead.Id, lead);
            this.leadOwnerIdMap.put(lead.Id, lead.OwnerId);

            if (String.isNotBlank(lead.Email)) {
                if (emailListMap.containsKey(lead.Email)) {
                    emailListMap.get(lead.Email).add(lead);
                } else {
                    emailListMap.put(lead.Email, new List<Lead>{lead});
                }
            }

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

    // 保存
    public void save() {
        saveOK = true;
        Savepoint sp;

        try {
            this.hasError = false;
            for (NameCardRecord ncRec : this.nameCardRecordList) ncRec.hasError = false;
            sp = Database.setSavepoint();

            Integer i = this.insertLead();
            i += this.updateLead();
            String str = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Msg_SelectLeadDEV);
            //if (i <= 0) throw new SB_NameCard_LeadRegist.LeadRegistException('リードを選択してください');
            System.debug(str);
            if (i <= 0) throw new SB_NameCard_LeadRegist.LeadRegistException(str);

            //pageRef = this.retUrl;
        }
        catch (Exception e) {
            if (sp != null) Database.rollback(sp);
            this.hasError = true;
            saveOK = false;
            System.debug(e.getMessage());
            ApexPages.addMessages(e);
        }
        //return pageRef;
    }

    // リード作成
    private Integer insertLead() {
        List<Lead> leadList = new List<Lead>();
        List<NameCardRecord> ncRecList = new List<NameCardRecord>();
        String str = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Msg_SpecifyOwnerWhenCreateLeadDEV);


        Schema.DescribeSObjectResult tar = Schema.getGlobalDescribe().get('Lead').getDescribe();
        for (NameCardRecord ncRec : this.nameCardRecordList) {
            if (ncRec.leadId != 'new') {
                continue;
            }

            if (this.ownerlead.OwnerId == null && useNameCardOwner == false) {
                //throw new SB_NameCard_LeadRegist.LeadRegistException('リードを新規作成する場合は「所有者」を指定してください');
                throw new SB_NameCard_LeadRegist.LeadRegistException(str);
            }

            if(!leadCreateable) {
                 throw new LeadBulkRegistControllerException(String.format(System.Label.SB_NCLD_MSG_CrudNotUpdateable, new String[]{tar.label}));
            }

            leadList.add(SB_NameCard_LeadRegist.getLead(null, ncRec.nameCard,!useNameCardOwner ? this.ownerlead.OwnerId : ncRec.nameCardOwnerId,this.leadRecTypeEdit == true  ? this.leadRecordTypeId : null));
            ncRecList.add(ncRec);
        }

        if (leadList.size() <= 0) return 0;
            Database.DMLOptions dml = new Database.DMLOptions();

            dml.OptAllOrNone = false;

        // リード
        this.setResult(SB_NameCard_LeadCrudFls.screate(leadList,dml), ncRecList);

        // キャンペーンメンバー
        insertCampaignMember(this.insertOption.campaign__c, leadList, ncRecList, campStatus);

        // 名刺
        updateNameCard(leadList, ncRecList, this.insertOption.campaign__c);

        // ToDo
        if(!useNameCardOwner && String.valueOf(this.ownerlead.ownerId).startsWith('005')) {
            insertTodo(leadList, ncRecList);
        }

        return leadList.size();
    }

    // リード更新
    private Integer updateLead()
    {
        Id leadId;
        Set<Id> leadIdSet = new Set<Id>();
        List<Lead> leadList = new List<Lead>();
        List<NameCardRecord> ncRecList = new List<NameCardRecord>();
        String str = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Text_LeadOverLapDEV);
        Schema.DescribeSObjectResult tar = Schema.getGlobalDescribe().get('Lead').getDescribe();
        for (NameCardRecord ncRec : this.nameCardRecordList) {
            if (ncRec.leadId == 'none' || ncRec.leadId == 'new') continue;

            leadId = Id.valueOf(ncRec.leadId);

             if(!Schema.getGlobalDescribe().get('Lead').getDescribe().isUpdateable()) {
                 throw new LeadBulkRegistControllerException(String.format(System.Label.SB_NCLD_MSG_CrudNotUpdateable, new String[]{tar.label}));
              }
            //if (leadIdSet.contains(leadId)) throw new SB_NameCard_LeadRegist.LeadRegistException('リードが重複しています');
            if (leadIdSet.contains(leadId)) throw new SB_NameCard_LeadRegist.LeadRegistException(str);
            leadIdSet.add(leadId);

            if (this.leadOverwrite) {
                leadList.add(SB_NameCard_LeadRegist.getLead(leadId, ncRec.nameCard, this.leadOwnerIdMap.get(leadId),null));
            }
            else {
                leadList.add(new Lead(Id=leadId, NameCard__c=ncRec.nameCard.Id));
            }
            ncRecList.add(ncRec);
        }
        if (leadList.size() <= 0) return 0;

        //SB_NameCard_LeadCrudFls.screateLead(leadList);

        Database.DMLOptions dml = new Database.DMLOptions();

        //エラーなってでも保存続く
        dml.OptAllOrNone = false;

        // リード
        this.setResult(SB_NameCard_LeadCrudFls.supdate(leadList, dml), ncRecList);

        // キャンペーンメンバー
        insertCampaignMember(this.insertOption.campaign__c, leadList, ncRecList, campStatus);

        // 名刺
        updateNameCard(leadList, ncRecList, this.insertOption.campaign__c);

        // ToDo
        insertTodo(leadList, ncRecList);

        return leadList.size();
    }

    // リード処理結果
    private void setResult(List<Database.SaveResult> srList, List<NameCardRecord> ncRecList) {
        String errMsg = '';

        Map<Id,Integer> cardindex = new Map<Id,Integer>();
        for (Integer i = 0 ; i<nameCardRecordList.size() ; i++) {
            NameCardRecord nr = nameCardRecordList[i];
            cardindex.put(nr.nameCard.Id,i);
        }

        SB_NameCard_LeadSaveResult dbError = new SB_NameCard_LeadSaveResult();
        dbError.putSaveResults(srList);

        if (dbError.isError()) {
            String leadl = Lead.getSObjectType().getDescribe().getLabel();
            for (Integer i = 0; i < srList.size(); i++) {
                SB_NameCard_LeadSaveResult.DbErrorHolder err = dbError.getDbErrorHolder(i);
                NameCardRecord n = ncRecList[i];
                if (err == null) {
                    n.hasError = false;
                     ncRecList[i].hasError = false;
                    continue;
                }
                n.hasError = true;
                 ncRecList[i].hasError = true;
                String msg = (cardindex.get(n.nameCard.Id)  + 1) + System.Label.SB_NC_Line + ': ' + leadl + ': ' + err.msg + '<br>';
                errMsg += msg;
            }
            //errorMsg += msg;
            if (String.isNotBlank(errMsg)) throw new SB_NameCard_LeadRegist.LeadRegistException(errMsg);
            //throw new SB_NameCard_LeadRegist.LeadRegistException(errMsg);
        }

        //for (Integer i = 0; i < srList.size(); i++) {
        //    if (srList[i].isSuccess()) {
        //        ncRecList[i].hasError = false;
        //        continue;
        //    }
        //    ncRecList[i].hasError = true;

        //    for (Database.Error err : srList[i].getErrors()) {
        //        errMsg += i+1 + System.Label.SB_NC_Line + ': ' + err.getMessage() + '<br/>';
        //    }
        //}
        //if (String.isNotBlank(errMsg)) throw new SB_NameCard_LeadRegist.LeadRegistException(errMsg);
    }

    // キャンペーンメンバー
    private static void insertCampaignMember(Id campId, List<Lead> leadList, List<NameCardRecord> ncRecList, String campStatus) {
        if (campId == null) return;
        List<CampaignMember> cmList = new List<CampaignMember>();

        for (Integer i = 0, len = leadList.size(); i < len; i++) {
            cmList.add(new CampaignMember(CampaignId=campId, LeadId=leadList[i].Id, ContactId=ncRecList[i].nameCard.SmartViscaf__contact__c, Status = campStatus));
        }
        if (cmList.size() > 0) {
            Database.DMLOptions dml = new Database.DMLOptions();

            dml.OptAllOrNone = true;
            System.debug(cmList);
            SB_NameCard_LeadCrudFls.screate(cmList,dml);
            System.debug(cmList);

         }
    }

    // 名刺
    private static void updateNameCard(List<Lead> leadList, List<NameCardRecord> ncRecList, Id campId) {
        List<SmartViscaf__NameCard__c> ncList = new List<SmartViscaf__NameCard__c>();
        Id leadId;

        for (Integer i = 0, len = leadList.size(); i < len; i++) {
            leadId = leadList[i].Id;
            if (campId != null && ncRecList[i].nameCard.campaign__c != campId) {
                ncList.add(new SmartViscaf__NameCard__c(Id=ncRecList[i].nameCard.Id, SmartViscaf__lead__c=leadId, campaign__c=campId));
            }
            else if (leadId != ncRecList[i].nameCard.SmartViscaf__lead__c) {

                ncList.add(new SmartViscaf__NameCard__c(Id=ncRecList[i].nameCard.Id, SmartViscaf__lead__c=leadId));
            }
        }

        if (ncList.size() > 0) {
            Database.DMLOptions dml = new Database.DMLOptions();

            dml.OptAllOrNone = true;

            SB_NameCard_LeadCrudFls.supdate(ncList, dml);

        }
    }

    // ToDo
    private void insertTodo(List<Lead> leadList, List<NameCardRecord> ncRecList) {
        String subject = SB_NameCard_LeadRegist.svConfig.todoSubject();
        List<Task> todoList = new List<Task>();
        Id leadId;
        Id ownerId;

        for (Integer i = 0, len = leadList.size(); i < len; i++) {
            if (!ncRecList[i].registTodo) continue;
            leadId = leadList[i].Id;
            ownerId = this.leadOwnerIdMap.get(leadId);
            if (ownerId == null)
                ownerId = leadList[i].OwnerId;
                if(!String.valueOf(ownerId).startsWith('005')) {
                    continue;
                }
            todoList.add(SB_NameCard_LeadRegist.getTodo(leadId, ownerId, subject, ncRecList[i].nameCard.SmartViscaf__card_exchange_date__c));
        }

        if (todoList.size() > 0) {
            Database.DMLOptions dml = new Database.DMLOptions();

            dml.OptAllOrNone = true;

            SB_NameCard_LeadCrudFls.screate(todoList,dml);

         }
    }

    // キャンセル
    //public PageReference cancel()
    //{
    //    return this.retUrl;
    //}
}