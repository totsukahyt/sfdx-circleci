/*
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
 *
 */

public with sharing class SB_NameCard_LeadBulkRegistController
{
    public class LeadBulkRegistControllerException extends exception {}
    public String retUrl{get;set;}
    public Boolean useNameCardOwner{get;set;}

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
    public  List<SelectOption> campaignStatus {get; set;}
    

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

            // SV_DEV-747 リード拡張パッケージのカスタム設定：リードに登録 リードレコードタイプ表示の初期値がOFF
            this.showLeadRecType = LEADRECORDTYPES.size() > 1 && SB_NameCard_LeadRegist.svConfig.LeadRectype();

            this.leadRecTypeEdit = leadCreateable && LEADRECORDTYPES.size() > 1;

            this.searchType = SB_NameCard_LeadRegist.SEARCHTYPE_EMAIL;
            this.leadOverwrite = SB_NameCard_LeadRegist.svConfig.overwrite() && Lead.sObjectType.getDescribe().isUpdateable();

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
                                        FROM CampaignMemberStatus Where CampaignId = :insertOption.campaign__c];
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
                    testError = message;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, message));
            }
        } catch (Exception e) {
            testError = e.getMessage();
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
            testError = e.getMessage();
            ApexPages.addMessages(e);
        }
        //return pageRef;
    }

    // リード作成
    private Integer insertLead() {
        List<Lead> leadList = new List<Lead>();
        List<NameCardRecord> ncRecList = new List<NameCardRecord>();
        String str = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Msg_SpecifyOwnerWhenCreateLeadDEV);

        // SV_DEV-565 リード登録のリード所有者の修正
        String errMsg = '';
        Map<Integer, Id> insertOwnerMap = new Map<Integer, Id>();

        Schema.DescribeSObjectResult tar = Lead.sObjecttype.getDescribe();

        Integer i = 0;
        for (NameCardRecord ncRec : this.nameCardRecordList) {
            i ++;
            if (ncRec.leadId != 'new') {
                continue;
            }

            if (this.ownerlead.OwnerId == null && useNameCardOwner == false) {
                //throw new SB_NameCard_LeadRegist.LeadRegistException('リードを新規作成する場合は「所有者」を指定してください');
                throw new SB_NameCard_LeadRegist.LeadRegistException(str);
            }

            if(!leadCreateable) {
                 throw new LeadBulkRegistControllerException(String.format(System.Label.SB_NCLD_MSG_CrudNotCreateable, new String[]{tar.label}));
            }
            // SV_DEV-565 リード登録のリード所有者の修正
            Id oId = !useNameCardOwner ? this.ownerlead.OwnerId : ncRec.nameCardOwnerId;
            if (!String.valueOf(oId).startsWith('005')) {
                insertOwnerMap.put(i, oId);
            }

            leadList.add(SB_NameCard_LeadRegist.getLead(null, ncRec.nameCard, oId,this.leadRecTypeEdit == true  ? this.leadRecordTypeId : null));
            ncRecList.add(ncRec);
        }

        // SV_DEV-565 リード登録のリード所有者の修正
        if (!insertOwnerMap.isEmpty()) {

            List<QueueSobject> qss = [Select QueueId, SobjectType, Queue.Name
                        FROM QueueSobject
                       WHERE QueueId = :insertOwnerMap.values()];
            Set<Id> canUserLeadQueues = new Set<Id>();
            Map<Id, String> qssMap = new Map<Id, String>();
            for (QueueSobject qs : qss) {
                qssMap.put(qs.QueueId, qs.Queue.Name);
                if (qs.SobjectType == 'Lead') {
                    canUserLeadQueues.add(qs.QueueId);
                }
            }

            for (Integer line : insertOwnerMap.keySet()) {
                Id qId = insertOwnerMap.get(line);
                if (!canUserLeadQueues.contains(qId)) {
                    nameCardRecordList[line-1].hasError = true;
                    String msg = line + System.Label.SB_NC_Line + ': ' + Lead.getSobjectType().getDescribe().getLabel()
                                 + System.Label.SB_NCLD_MSG_Regist_Error + ': ' + String.format(System.Label.SB_NCLD_MSG_QUEUES_LEAD_ERROR,new String[]{qssMap.get(qId)}) + '<br>';
                    errMsg += msg;
                }
            }
            if (String.isNotBlank(errMsg)) {
                throw new SB_NameCard_LeadRegist.LeadRegistException(errMsg);
            }
        }



        if (leadList.size() <= 0) return 0;
            Database.DMLOptions dml = new Database.DMLOptions();

            dml.OptAllOrNone = false;

        // リード
        //SV_DEV-755 無効なユーザでTODO登録したときのエラー
        this.setResult(SB_NameCard_LeadCrudFls.screate(leadList,dml), ncRecList, Lead.getSObjectType(), true);

        // キャンペーンメンバー
        insertCampaignMember(this.insertOption.campaign__c, leadList, ncRecList, campStatus);

        // 名刺
        // SV_DEV-760 既存リードを更新した場合に名刺のキャンペーン項目が更新される。
        updateNameCard(leadList, ncRecList, this.insertOption.campaign__c, false);

        // ToDo
        // if(!useNameCardOwner && String.valueOf(this.ownerlead.ownerId).startsWith('005')) {
            insertTodo(leadList, ncRecList);
        // }

        return leadList.size();
    }

    // リード更新
    private Integer updateLead()
    {
        Id leadId;
        Set<Id> leadIdSet = new Set<Id>();
        List<Lead> leadList = new List<Lead>();
        // SV_DEV-565 リード登録のリード所有者の修正
        String errMsg = '';
        Map<Integer, Id> updateOwnerMap = new Map<Integer, Id>();
        List<NameCardRecord> ncRecList = new List<NameCardRecord>();
        String str = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Text_LeadOverLapDEV);
        Schema.DescribeSObjectResult tar = Lead.sObjectType.getDescribe();

        Integer i = 0;

        for (NameCardRecord ncRec : this.nameCardRecordList) {
            i++;
            if (ncRec.leadId == 'none' || ncRec.leadId == 'new') continue;

            leadId = Id.valueOf(ncRec.leadId);

             if(!Lead.sObjectType.getDescribe().isUpdateable()) {
                 throw new LeadBulkRegistControllerException(String.format(System.Label.SB_NCLD_MSG_CrudNotUpdateable, new String[]{tar.label}));
              }
            //if (leadIdSet.contains(leadId)) throw new SB_NameCard_LeadRegist.LeadRegistException('リードが重複しています');
            if (leadIdSet.contains(leadId)) throw new SB_NameCard_LeadRegist.LeadRegistException(str);
            leadIdSet.add(leadId);

            if (this.leadOverwrite) {
                Id oId = this.leadOwnerIdMap.get(leadId);

                if (!String.valueOf(oId).startsWith('005')) {
                    updateOwnerMap.put(i, oId);
                }
                leadList.add(SB_NameCard_LeadRegist.getLead(leadId, ncRec.nameCard, oId,null));
            }
            else {
                leadList.add(new Lead(Id=leadId, NameCard__c=ncRec.nameCard.Id));
            }
            ncRecList.add(ncRec);
        }
        if (leadList.size() <= 0) return 0;

        // SV_DEV-565 リード登録のリード所有者の修正
        if (!updateOwnerMap.isEmpty()) {

            List<QueueSobject> qss = [Select QueueId, SobjectType, Queue.Name
                        FROM QueueSobject
                       WHERE QueueId = :updateOwnerMap.values()];
            Set<Id> canUserLeadQueues = new Set<Id>();
            Map<Id, String> qssMap = new Map<Id, String>();
            for (QueueSobject qs : qss) {
                qssMap.put(qs.QueueId, qs.Queue.Name);
                if (qs.SobjectType == 'Lead') {
                    canUserLeadQueues.add(qs.QueueId);
                }
            }

            for (Integer line : updateOwnerMap.keySet()) {
                Id qId = updateOwnerMap.get(line);
                if (!canUserLeadQueues.contains(qId)) {
                    nameCardRecordList[line-1].hasError = true;
                    String msg = line + System.Label.SB_NC_Line + ': ' + Lead.getSobjectType().getDescribe().getLabel()
                                 + System.Label.SB_NCLD_MSG_Update_Error + ': ' + String.format(System.Label.SB_NCLD_MSG_QUEUES_LEAD_ERROR,new String[]{qssMap.get(qId)}) + '<br>';
                    errMsg += msg;
                }
            }
            if (String.isNotBlank(errMsg)) {
                throw new SB_NameCard_LeadRegist.LeadRegistException(errMsg);
            }
        }

        //SB_NameCard_LeadCrudFls.screateLead(leadList);

        Database.DMLOptions dml = new Database.DMLOptions();

        //エラーなってでも保存続く
        dml.OptAllOrNone = false;

        // リード
        //SV_DEV-755 無効なユーザでTODO登録したときのエラー
        this.setResult(SB_NameCard_LeadCrudFls.supdate(leadList, dml), ncRecList, Lead.getSObjectType(), false);

        // キャンペーンメンバー
        // SV_DEV-750 既存リードの更新時にもキャンペーンの選択が反映される。
        // insertCampaignMember(this.insertOption.campaign__c, leadList, ncRecList, campStatus);

        // 名刺
        // SV_DEV-760 既存リードを更新した場合に名刺のキャンペーン項目が更新される。
        updateNameCard(leadList, ncRecList, this.insertOption.campaign__c, true);

        // ToDo
        insertTodo(leadList, ncRecList);

        return leadList.size();
    }

    // リード処理結果
    private void setResult(List<Database.SaveResult> srList, List<NameCardRecord> ncRecList, sObjectType sobj, Boolean isCreate) {
        String errMsg = '';

        Map<Id,Integer> cardindex = new Map<Id,Integer>();
        for (Integer i = 0 ; i<nameCardRecordList.size() ; i++) {
            NameCardRecord nr = nameCardRecordList[i];
            cardindex.put(nr.nameCard.Id,i);
        }

        SB_NameCard_LeadSaveResult dbError = new SB_NameCard_LeadSaveResult();
        dbError.putSaveResults(srList);

        if (dbError.isError()) {
            String leadl = sobj.getDescribe().getLabel();
            //SV_DEV-755 無効なユーザでTODO登録したときのエラー
            leadl += isCreate ? System.Label.SB_NCLD_MSG_Regist_Error : System.Label.SB_NCLD_MSG_Update_Error;
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
            //SV_DEV-751 リードに登録で追加された、キャンペーンメンバーの種別が「取引先責任者」になる。
            cmList.add(new CampaignMember(CampaignId=campId, LeadId=leadList[i].Id, Status = campStatus));
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
    // SV_DEV-760 既存リードを更新した場合に名刺のキャンペーン項目が更新される。
    private static void updateNameCard(List<Lead> leadList, List<NameCardRecord> ncRecList, Id campId, Boolean isUpdate) {
        List<SmartViscaf__NameCard__c> ncList = new List<SmartViscaf__NameCard__c>();
        Id leadId;

        for (Integer i = 0, len = leadList.size(); i < len; i++) {
            leadId = leadList[i].Id;
            if (campId != null && ncRecList[i].nameCard.campaign__c != campId) {
              // SV_DEV-760 既存リードを更新した場合に名刺のキャンペーン項目が更新される。
              if (!isUpdate) {
                ncList.add(new SmartViscaf__NameCard__c(Id=ncRecList[i].nameCard.Id, SmartViscaf__lead__c=leadId, campaign__c=campId));
              } else {
                ncList.add(new SmartViscaf__NameCard__c(Id=ncRecList[i].nameCard.Id, SmartViscaf__lead__c=leadId));
              }
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
        String errMsg = '';
        Map<Id,Integer> cardindex = new Map<Id,Integer>();
        for (Integer i = 0 ; i<nameCardRecordList.size() ; i++) {
            NameCardRecord nr = nameCardRecordList[i];
            cardindex.put(nr.nameCard.Id,i);
        }
        for (Integer i = 0, len = leadList.size(); i < len; i++) {
            if (!ncRecList[i].registTodo) continue;
            leadId = leadList[i].Id;
            ownerId = this.leadOwnerIdMap.get(leadId);
            if (ownerId == null) {
                ownerId = leadList[i].OwnerId;
            }
            // SV_DEV-727 リードへ登録、名刺所有者がキューおよリード所有者がキューの場合
            if(!String.valueOf(ownerId).startsWith('005')) {
                String todoE = Task.getSobjectType().getDescribe().getLabel();
                //SV_DEV-755 無効なユーザでTODO登録したときのエラー
                todoE += System.Label.SB_NCLD_MSG_Regist_Error;
                ncRecList[i].hasError = true;
                String msg = (cardindex.get(ncRecList[i].nameCard.Id) + 1) + System.Label.SB_NC_Line + ': ' + todoE + ': ' + System.Label.SB_NCLD_MSG_QUEUES_ERROR + '<br>';
                errMsg += msg;
                continue;
            }
            todoList.add(SB_NameCard_LeadRegist.getTodo(leadId, ownerId, subject, ncRecList[i].nameCard.SmartViscaf__card_exchange_date__c));
        }

        if (String.isNotBlank(errMsg)) throw new SB_NameCard_LeadRegist.LeadRegistException(errMsg.removeEnd('<br>'));

        if (todoList.size() > 0) {
            Database.DMLOptions dml = new Database.DMLOptions();

            dml.OptAllOrNone = false;

            //SV_DEV-755 無効なユーザでTODO登録したときのエラー
            this.setResult(SB_NameCard_LeadCrudFls.screate(todoList,dml), ncRecList, Task.getSObjectType(), true);

         }
    }

    // キャンセル
    //public PageReference cancel()
    //{
    //    return this.retUrl;
    //}
}