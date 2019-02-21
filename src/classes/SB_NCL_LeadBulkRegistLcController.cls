public with sharing class SB_NCL_LeadBulkRegistLcController {

  private static final String LEADLABEL = Lead.sObjectType.getDescribe().getLabel();
  private static SB_NameCardL_RegistCanPickerAbstract picker = new SB_NameCardL_RegistSoqlCountCanPicker();  //

  @RemoteAction
  @AuraEnabled
  // 全てのデータをここで取得
  public static String getAllData(String recordIds, String fieldListStr, String searchType, String recordType) {
    SB_NameCardL_BulkRegistDTO.SaveResult saveResult = new SB_NameCardL_BulkRegistDTO.SaveResult();
    try{
      List<SB_NameCardL_BulkRegistDTO.DataTableColumnField> fieldList;
      if (String.isNotBlank(fieldListStr)) {
        fieldList = (List<SB_NameCardL_BulkRegistDTO.DataTableColumnField> )System.JSON.deserializeStrict(fieldListStr, List<SB_NameCardL_BulkRegistDTO.DataTableColumnField> .Class);
        if (fieldList.isEmpty()) {
          Map<String, List<SB_NameCardL_BulkRegistDTO.DataTableColumnField>> fieldMap = (Map<String, List<SB_NameCardL_BulkRegistDTO.DataTableColumnField>> )System.JSON.deserializeStrict(getFieldList(), Map<String, List<SB_NameCardL_BulkRegistDTO.DataTableColumnField>> .Class);
          fieldList = fieldMap.get('Lead');
        }
      }
      else {
        Map<String, List<SB_NameCardL_BulkRegistDTO.DataTableColumnField>> fieldMap = (Map<String, List<SB_NameCardL_BulkRegistDTO.DataTableColumnField>> )System.JSON.deserializeStrict(getFieldList(), Map<String, List<SB_NameCardL_BulkRegistDTO.DataTableColumnField>> .Class);
        fieldList = fieldMap.get('Lead');
      }
      List<String> recordIdList = recordIds.split(',');

      Set<String> fieldsSet = SB_NameCardL_RegistQueryExecutor.getNameCardFields();
      String query = String.format('SELECT {0} FROM SmartViscaf__NameCard__c WHERE Id = :recordIdList', new String[] { String.join(new List<String>(fieldsSet), ', ')});
      List<SmartViscaf__NameCard__c> ncs = Database.query(query);
      System.debug('ncs size' + ncs.size());
      System.debug('fieldList : ' + fieldList);
      Map<String, Schema.SObjectField> fields = SmartViscaf__NameCard__c.sObjectType.getDescribe().fields.getMap();
      List<SB_NameCardL_BulkRegistDTO.CustomObject> dataList = new List<SB_NameCardL_BulkRegistDTO.CustomObject>();
      for (SmartViscaf__NameCard__c sobj : ncs) {
        SB_NameCardL_BulkRegistDTO.CustomObject co = new SB_NameCardL_BulkRegistDTO.CustomObject();
        for (SB_NameCardL_BulkRegistDTO.DataTableColumnField field : fieldList) {
          SB_NameCardL_BulkRegistDTO.CustomField cf = new SB_NameCardL_BulkRegistDTO.CustomField();
          if (String.isNotBlank(field.fieldName) && fields.containsKey(field.fieldName)) {
            cf.label = (String)sobj.get(field.fieldName);
            cf.value = (String)sobj.get(field.fieldName);
          }
          if (field.type == 'url') {
            cf.value = string.format('/one/one.app#/sObject/{0}/view',new String[]{(Id)sobj.get('Id')});
          }
          cf.type = field.type;
          cf.input = field.input;
          cf.fieldName = field.fieldName;
          co.cObjectMap.put(cf.fieldName, cf);
        }
        SB_NameCardL_BulkRegistDTO.CustomField cf = new SB_NameCardL_BulkRegistDTO.CustomField();
        cf.label = (String)sobj.get('OwnerId');
        cf.value = (String)sobj.get('OwnerId');
        co.cObjectMap.put('OwnerId', cf);
        SB_NameCardL_BulkRegistDTO.CustomField cfId = new SB_NameCardL_BulkRegistDTO.CustomField();
        cfId.label = (String)sobj.get('Id');
        cfId.value = (String)sobj.get('Id');
        co.cObjectMap.put('Id', cfId);
        co.id = (Id)sobj.get('Id');
        co.nameCard = sobj;
        // if (String.isBlank(dto.lookUpId)) {
          // dto.lookUpId = co.id;
        // }
        dataList.add(co);
      }
      //dto.setDataList(ncs);
      System.debug(dataList);
      saveResult.success = true;
      saveResult.data = dataList;
    }
    catch (Exception e) {
      saveResult.success = false;
      saveResult.message = e.getMessage();
    }
    return JSON.serialize(saveResult);
  }

  @RemoteAction
  @AuraEnabled
  // タイトルに関する内容ここで取得
  public static String getTitleValue() {
    SB_NameCardL_BulkRegistDTO.TitleValue titleV = new SB_NameCardL_BulkRegistDTO.TitleValue();
    titleV.titleName = String.format(System.Label.SB_NCLD_Text_RegisterToLeadsDEV, new String[]{Lead.sObjecttype.getDescribe().getLabel()});
    titleV.iconName = 'standard:account';
    titleV.iconSize = 'large';
    titleV.closeValue = System.Label.SB_NCLD_Label_Close;
    titleV.saveValue = System.Label.SB_NCLD_Label_Save;
    return JSON.serialize(titleV);
  }

  @RemoteAction
  @AuraEnabled
  // 入力に関する内容はここで取得
  public static String getInputValue() {
    SB_NameCardL_BulkRegistDTO.InputValue inv = new SB_NameCardL_BulkRegistDTO.InputValue();
    SB_NameCardL_BulkRegistDTO.InputPlickListValue inputR = new SB_NameCardL_BulkRegistDTO.InputPlickListValue();
    inputR.plickListTitle = Lead.SobjectType.getDescribe().getLabel();

    inputR.selectValue = SB_NameCardL_Util.getDefaultRecordType(Lead.sObjectType);

    inv.InputPlickListValues.add(inputR);
    inv.useNameCardOwnerLabel = String.format(System.Label.SB_NCLD_Label_NameCardOwner, new String[] {LEADLABEL});
    inv.campaignStatusPlick.plickListTitle = System.Label.SB_NCLD_Label_CampaignStatus;
    inv.campaignLabel = SmartViscaf__NameCard__c.Campaign__c.getDescribe().getLabel();
    inv.ownerLabel = SmartViscaf__NameCard__c.OwnerId.getDescribe().getLabel();
    inv.newSectionLabel = String.format(System.Label.SB_NCLD_Text_SpecifiedWhenCreateNew, new String[] {LEADLABEL});


    SB_NameCardL_BulkRegistDTO.InputRegistOverWritValue inputO = new SB_NameCardL_BulkRegistDTO.InputRegistOverWritValue();
    SB_NameCardL_BulkRegistDTO.LabelValueCheck lc = new SB_NameCardL_BulkRegistDTO.LabelValueCheck();
    lc.label = String.format(System.Label.SB_NCLD_Label_OverwriteLeadInfoDEV, new String[] {LEADLABEL});
    inputO.overWriteCheck = lc;
    inputO.show = true;
    inv.inputRegistOverWritValues.add(inputO);
    inv.searchConditions.add(new SB_NameCardL_BulkRegistDTO.SearchCondition(Lead.Email.getDescribe().getLabel(), String.valueOf(SB_NameCard_LeadRegist.SEARCHTYPE_EMAIL), 'utility:email', ''));
    inv.searchConditions.add(new SB_NameCardL_BulkRegistDTO.SearchCondition(Lead.Name.getDescribe().getLabel(), String.valueOf(SB_NameCard_LeadRegist.SEARCHTYPE_NAME), 'utility:user', ''));
    inv.searchConditionValue = String.valueOf(SB_NameCard_LeadRegist.SEARCHTYPE_EMAIL);

    inv.searchConditionRct.title = System.Label.SB_NCLD_Label_Setting;
    inv.searchConditionRct.description = '検索の対象にするレコードタイプを指定します。';

    List<RecordTypeInfo> leadRecordTypes = SB_NameCardL_Util.getRecordType(Lead.sObjectType);
    SB_NameCardL_BulkRegistDTO.SearchConditionRecordTypeOptionGroup optionGroup = new SB_NameCardL_BulkRegistDTO.SearchConditionRecordTypeOptionGroup();
    optionGroup.title = String.format(System.Label.SB_NCLD_Label_LeadRecType, new String[] {Lead.sObjecttype.getDescribe().getLabel()});
    optionGroup.titleId = 'LeadRecTypes';
    for (RecordTypeInfo info : leadRecordTypes) {
      inputR.plickListOptions.add(new SB_NameCardL_BulkRegistDTO.LabelValue(info.getName(), info.getRecordTypeId()));
      SB_NameCardL_BulkRegistDTO.LabelValueCheck lvc = new SB_NameCardL_BulkRegistDTO.LabelValueCheck();
      lvc.label = info.getName();
      lvc.value = info.getRecordTypeId();
      lvc.checked = true;
      optionGroup.searchConditionplickListOptions.add(lvc);
      if (String.isBlank(inv.searchRecordTypes)) {
        inv.searchRecordTypes = info.getRecordTypeId();
      }
      else {
        inv.searchRecordTypes += ',' + info.getRecordTypeId();
      }
    }
    inv.searchConditionRct.searchConditionRecordTypeOptionGroups.add(optionGroup);
    inv.haveQueue = ![Select QueueId, SobjectType, Queue.Name
                          FROM QueueSobject
                         WHERE SobjectType = 'Lead'].isEmpty();


    return JSON.serialize(inv);
  }

  @RemoteAction
  @AuraEnabled
  // 画面表示項目リストここで取得
  public static String getFieldList() {
    Map<String, List<SB_NameCardL_BulkRegistDTO.DataTableColumnField>> fieldMap = new Map<String, List<SB_NameCardL_BulkRegistDTO.DataTableColumnField>>();
    List<SB_NameCardL_BulkRegistDTO.DataTableColumnField> fieldList = new List<SB_NameCardL_BulkRegistDTO.DataTableColumnField>();
    fieldList.add(new SB_NameCardL_BulkRegistDTO.DataTableColumnField(SmartViscaf__NameCard__c.SmartViscaf__company_name__c.getDescribe().getLabel(),
                                           'SmartViscaf__company_name__c',
                                           'string',
                                           false));
    fieldList.add(new SB_NameCardL_BulkRegistDTO.DataTableColumnField(SmartViscaf__NameCard__c.SmartViscaf__division__c.getDescribe().getLabel(),
                                           'SmartViscaf__division__c',
                                           'string',
                                           false));
    fieldList.add(new SB_NameCardL_BulkRegistDTO.DataTableColumnField(SmartViscaf__NameCard__c.SmartViscaf__title_name__c.getDescribe().getLabel(),
                                           'SmartViscaf__title_name__c',
                                           'string',
                                           false));
    fieldList.add(new SB_NameCardL_BulkRegistDTO.DataTableColumnField(SmartViscaf__NameCard__c.Name.getDescribe().getLabel(),
                                           'Name',
                                           'url',
                                           false));
    fieldList.add(new SB_NameCardL_BulkRegistDTO.DataTableColumnField(SmartViscaf__NameCard__c.SmartViscaf__address__c.getDescribe().getLabel(),
                                           'SmartViscaf__address__c',
                                           'string',
                                           false));
    fieldList.add(new SB_NameCardL_BulkRegistDTO.DataTableColumnField(SmartViscaf__NameCard__c.SmartViscaf__mobile__c.getDescribe().getLabel(),
                                           'SmartViscaf__mobile__c',
                                           'string',
                                           false));
    fieldList.add(new SB_NameCardL_BulkRegistDTO.DataTableColumnField(System.Label.SB_NCLD_Label_Registration,
                                           'Lead',
                                           'plicklist',
                                           true));
    fieldList.add(new SB_NameCardL_BulkRegistDTO.DataTableColumnField(System.Label.SB_NCLD_Label_ToDoRegistration,
                                           'ToDo',
                                           'checkbox',
                                           true));
    fieldMap.put('Lead', fieldList);
    return JSON.serialize(fieldMap);
    // return fieldList;
  }

  @RemoteAction
  @AuraEnabled
  public static String getCampaignStatus(String campaignId) {
    List<CampaignMemberStatus> cpms = [SELECT id, CampaignID, HasResponded, IsDefault, Label, SortOrder
                                        FROM CampaignMemberStatus 
                                       WHERE CampaignId = :campaignId];
    SB_NameCardL_BulkRegistDTO.InputPlickListValue inputR = new SB_NameCardL_BulkRegistDTO.InputPlickListValue();
    for (CampaignMemberStatus f: cpms) {
      if (f.IsDefault == true) {
        inputR.selectValue = f.Label;
      }
      inputR.plickListOptions.add(new SB_NameCardL_BulkRegistDTO.LabelValue(f.Label, f.Label));
    }
    // this.campDisabled = options.size() <= 0 || campLookUpDisabled;
    return JSON.serialize(inputR);
  }




// ********************************************* 検索 *********************************************//


  @RemoteAction
  @AuraEnabled
  // 検索
  public static String searchAllLead(String nameCardIds, String searchType, String searchRecordTypes) {
    String message = '';
    SB_NameCardL_BulkRegistDTO.SaveResult saveResult = new SB_NameCardL_BulkRegistDTO.SaveResult();
    try {
        // this.hasError = false;
        System.debug(nameCardIds);
        if (String.isBlank(nameCardIds)) {
          return null;
        }
        Set<Id> nameCardIdSet = new Set<Id>((List<Id>)new List<String>(nameCardIds.split(',')));

        Set<String> fields = SB_NameCardL_RegistQueryExecutor.getNameCardFields();
        String query = String.format('SELECT {0} FROM SmartViscaf__NameCard__c WHERE Id = :nameCardIdSet', new String[] { String.join(new List<String>(fields), ', ')});
        List<SmartViscaf__NameCard__c> nameCards = Database.query(query);
        Map<Id, Lead> idMap = new Map<Id, Lead>();
        Map<String, List<Lead>> emailListMap = new Map<String, List<Lead>>();
        Map<String, List<Lead>> nameListMap = new Map<String, List<Lead>>();

        Map<Id,Map<Schema.SObjectType,List<SObject>>> sObjectList = buildCandidateList(nameCardIdSet, nameCards, searchType, searchRecordTypes);
        Map<Schema.SObjectType, Map<Id, SObject>> sObjectTypemap = new Map<Schema.SObjectType, Map<Id, SObject>>();
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

        // setLeadMap(idMap, emailListMap, nameListMap, sObjectTypemap.get(Lead.sObjectType).values(), searchType);
        Map<Id,Map<String, SB_NameCardL_BulkRegistDTO.InputPlickListValue>> inputPlickListVMap = new Map<Id,Map<String, SB_NameCardL_BulkRegistDTO.InputPlickListValue>>();

        List<SB_NameCardL_BulkRegistDTO.CustomObject> dataList = new List<SB_NameCardL_BulkRegistDTO.CustomObject>();

        for (SmartViscaf__NameCard__c nc : nameCards) {
          SB_NameCardL_BulkRegistDTO.InputPlickListValue inputPlickListV = new SB_NameCardL_BulkRegistDTO.InputPlickListValue();
          if ((!SmartViscaf.SB_NameCard_Util.isEnablePersonAccount() && String.isBlank(nc.SmartViscaf__company_name__c)) || String.isBlank(SmartViscaf.SB_NameCard_Util.getPersonName(nc).get('last_name'))) {
            if (!SmartViscaf.SB_NameCard_Util.isEnablePersonAccount() && String.isBlank(nc.SmartViscaf__company_name__c)) {
              inputPlickListV.plickListOptions.add(new SB_NameCardL_BulkRegistDTO.LabelValue(System.Label.SB_NCLD_DontRegister_CompanyNameRequired, 'none'));
            }
            else {
              inputPlickListV.plickListOptions.add(new SB_NameCardL_BulkRegistDTO.LabelValue(System.Label.SB_NCLD_DontRegister_NameRequired, 'none'));
            }
            continue;
          }
          // setLeadRecord(idMap, emailListMap, nameListMap, nc, inputPlickListV.plickListOptions);

          Map<String, SB_NameCardL_BulkRegistDTO.InputPlickListValue> inputPlickListVMap1 = new Map<String, SB_NameCardL_BulkRegistDTO.InputPlickListValue>();
          Map<Schema.SObjectType,List<SObject>> sObjectMap = sObjectList.get(nc.Id);
          if (sObjectMap.containsKey(Lead.sObjecttype)) {
            List<sObject> sLeadList = sObjectMap.get(Lead.sObjecttype);
            for (sObject obj : sLeadList) {
              Lead lead = (Lead)obj;
              String label = getLabel(lead.Name, lead.Email);
              inputPlickListV.plickListOptions.add(new SB_NameCardL_BulkRegistDTO.LabelValue(label, lead.Id));
              inputPlickListV.plickListValueMap.put(lead.Id, label);
            }
          }

          if(Lead.sObjectType.getDescribe().isCreateable()) {
            String label = System.Label.SB_NCLD_Menu_NewLead;
            inputPlickListV.plickListOptions.add(new SB_NameCardL_BulkRegistDTO.LabelValue(label, 'new'));
            inputPlickListV.plickListValueMap.put('new', label);
          }
          inputPlickListV.plickListOptions.add(new SB_NameCardL_BulkRegistDTO.LabelValue(System.Label.SB_NCLD_Menu_NotToRegister, 'none'));
          inputPlickListV.plickListValueMap.put('none', System.Label.SB_NCLD_Menu_NotToRegister);

          inputPlickListVMap1.put('Lead', inputPlickListV);
          // inputPlickListVMap1.put('Contact', inputPlickListV);
          inputPlickListVMap.put(nc.Id, inputPlickListVMap1);
        }
        if (message != '') {
                // testError = message;
                // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, message));
        }
        saveResult.success = true;
        saveResult.data = inputPlickListVMap;
    } catch (Exception e) {
      // testError = e.getMessage();
      saveResult.success = false;
      saveResult.message = e.getMessage();
    }
    return JSON.serialize(saveResult);
  }


  public static String getLabel(String name, String email) {
    String label = String.isBlank(name) ? '' : name;
    label += String.isBlank(email) ? ' <>' : ' <'+email+'>';
    return label;
  }

  // 検索用メソッド
  public static Map<Id,Map<Schema.SObjectType,List<SObject>>> buildCandidateList(Set<Id> ncList, List<SmartViscaf__NameCard__c> nameCardList,
                                                                                String searchType, String searchRecordTypes) {
    List<SB_NameCardL_RegistQueryOption> queryOptions = new List<SB_NameCardL_RegistQueryOption>();
    SB_NameCardL_RegistQueryOption queryOption = new SB_NameCardL_RegistQueryOption(Lead.sObjecttype);
    if (searchType == String.valueOf(SB_NameCard_LeadRegist.SEARCHTYPE_EMAIL)) {
      queryOption.queryEMail = true;
    }
    else if (searchType == String.valueOf(SB_NameCard_LeadRegist.SEARCHTYPE_NAME)) {
      queryOption.queryLastName = true;
      queryOption.queryFirstName = true;
    }
    if (String.isNotBlank(searchRecordTypes)) {
            queryOption.setRectypeIds(new Set<Id>((List<Id>)new List<String>(searchRecordTypes.split(','))));
    }
    queryOptions.add(queryOption);
    System.assert(!queryOptions.isEmpty());
    // クエリする対象のオブエジェクト ごとに　SB_NameCardL_RegistQueryOption を作って、検索の条件を指定して渡します。
    picker.init(queryOptions);
    //picker.setQueryStrategys(qss);
    SB_NameCardL_RegistQueryExecutor qExecutor = SB_NameCardL_RegistQueryExecutor.getInstance();
    qExecutor.init(nameCardList);      // init は オーバーロード されてて、 個別の場合は、これか、 Id をt１つ渡すメソッドをつかって、一括の場合は 複数を渡すのを使います。
    // picker の create もオーバーロード されてて、個別ならこれとかで、一括の場合は Map<Id, List<SObject>> create(Set<Id> cardIds); を名刺レコードIDと 一致するSObjectのリストのマップを返すのを使います。
    Map<Id,Map<Schema.SObjectType, List<SObject>>> otype2objs = picker.create(ncList);
    return otype2objs;
  }


  // リード
  // private static void setLeadMap(Map<Id, Lead> idMap, Map<String, List<Lead>> emailListMap, Map<String, List<Lead>> nameListMap, List<Lead> leads, String searchType) {
  //   String name ='';
  //   Set<String> s1 = new Set<String>{String.valueof(SB_NameCard_LeadRegist.SEARCHTYPE_EMAIL)};
  //   if (String.isBlank(searchType)) {
  //     searchType = String.valueOf(SB_NameCard_LeadRegist.SEARCHTYPE_EMAIL);
  //   }
  //   for (Lead lead : leads) {
  //     idMap.put(lead.Id, lead);
  //     // SV_DEV-746 リードに登録（一括登録）で、検索条件が「氏名」の場合でメールアドレスが一致した候補が表示される場合がある。
  //     if (s1.contains(searchType)) {
  //       if (String.isNotBlank(lead.Email)) {
  //         if (emailListMap.containsKey(lead.Email)) {
  //           emailListMap.get(lead.Email).add(lead);
  //         }
  //         else {
  //           emailListMap.put(lead.Email, new List<Lead>{lead});
  //         }
  //       }
  //     } else {
  //       // 姓名
  //       if (nameListMap.containsKey(lead.Name)) {
  //         nameListMap.get(lead.Name).add(lead);
  //       }
  //       else {
  //         nameListMap.put(lead.Name, new List<Lead>{lead});
  //       }

  //       // 姓のみ
  //       name = lead.LastName;
  //       if (nameListMap.containsKey(name)) {
  //         nameListMap.get(name).add(lead);
  //       }
  //       else {
  //         nameListMap.put(name, new List<Lead>{lead});
  //       }
  //       // 名のみ
  //       name = lead.FirstName;
  //       if (nameListMap.containsKey(name)) {
  //         nameListMap.get(name).add(lead);
  //       }
  //       else {
  //         nameListMap.put(name, new List<Lead>{lead});
  //       }
  //     }
  //   }
  // }



  //   //取引先責任者関連用Mapを作成
  // public static void setData(Map<Id, Contact> cIdMap, Map<String, List<Contact>> cEmailMap, Map<String, List<Contact>> cNameMap, Map<String, List<Contact>> cLastNameMap, List<Contact> contactList){
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


  // 保存
  // SV_DEV-762 名刺オブジェクトの編集権限がない場合にリードに登録の処理が終了しない。
  @RemoteAction
  @AuraEnabled
  public static String saveLead(String customObjects, String ownerId, Boolean useNameCardOwner, String campaign, String campaignStatus, Boolean leadOverwrite, String leadRecordTypeId) {
      // saveOK = true;
      Savepoint sp;
      System.debug('start save');
      String message = '';
      SB_NameCardL_BulkRegistDTO.SaveResult saveResult = new SB_NameCardL_BulkRegistDTO.SaveResult();
      try {
          List<SB_NameCardL_BulkRegistDTO.CustomObject> dataList = (List<SB_NameCardL_BulkRegistDTO.CustomObject>)System.JSON.deserializeStrict(customObjects, List<SB_NameCardL_BulkRegistDTO.CustomObject> .Class);
          Boolean hasError = false;
          // for (NameCardRecord ncRec : this.nameCardRecordList) ncRec.hasError = false;
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
          if (!useNameCardOwner && String.isNotBlank(ownerId)) {
            oId = ownerId;
          }

          for (Integer i = 0; i < dataList.size(); i ++) {
            Map<String, SB_NameCardL_BulkRegistDTO.CustomField> cObjectMap = dataList[i].cObjectMap;
            String leadId = cObjectMap.get('Lead').value;
            System.debug(cObjectMap.get('Lead'));
            if (leadId != 'none') {
              if (leadId == 'new') {
                //画面上の所有者を
                if (!haveNew) {
                  haveNew = true;
                  if (!useNameCardOwner && String.isBlank(ownerId)) {
                    //(関連)リードを新規作成する場合は「所有者」を指定してください
                    String noOwnerIdErrorMessage = String.format(System.Label.SB_NCLD_Msg_SpecifyOwnerWhenCreateLeadDEV, new String[] {LEADLABEL});
                    throw new SB_NameCard_LeadRegist.LeadRegistException(noOwnerIdErrorMessage);
                  }
                }
                Id leadOwnerId = String.isBlank(oId) ? cObjectMap.get('OwnerId').value : oId;
                newOwnerMap.put(i + 1, leadOwnerId);
              }
              if (cObjectMap.get('ToDo').value == 'true') {

                todoIndexMap.put(i + 1, leadId == 'new' ? null : leadId);
                todoList.add(i + 1);
              }
              SB_NameCardL_RegistHelper.RegistTarget tar = new SB_NameCardL_RegistHelper.RegistTarget(SB_NameCardL_RegistHelper.ProcType.LEAD,
                                                                                                      dataList[i].id,
                                                                                                      null,
                                                                                                      null,
                                                                                                      leadId == 'new' ? null : leadId,
                                                                                                      cObjectMap.get('ToDo').checked,
                                                                                                      null);
              tars.add(tar);
            }
            j ++;
          }

          // if (!todoIndexMap.isEmpty()) {
          //   Map<Id, Id> todoLeadIdOwnerId = new Map<Id, Id>();
          //   Set<Integer> todoIndexMapKey = todoIndexMap.keySet();
          //   Set<Integer> needSearchIndex = new Set<Integer>();
          //   for (Integer key : todoIndexMapKey) {
          //     if (!newOwnerMap.containsKey(key)) {
          //       todoLeadIdOwnerId.put(todoIndexMap.get(key), null);
          //       needSearchIndex.add(key);
          //     } else {
          //       todoIndexMap.put(key, newOwnerMap.get(key));
          //     }
          //   }

          //   if (!todoLeadIdOwnerId.isEmpty()) {
          //     List<Lead> ls = [Select Id, OwnerId
          //                 FROM Lead
          //                WHERE Id = :todoLeadIdOwnerId.keySet()];
          //     for (Lead l : ls) {
          //       todoLeadIdOwnerId.put(l.Id, l.OwnerId);
          //     }
          //     for (Integer index : needSearchIndex) {
          //       todoIndexMap.put(index, todoLeadIdOwnerId.get(todoIndexMap.get(index)));
          //     }
          //   }
          //   for (Integer index : todoList) {
          //     Id leadOwnerId = todoIndexMap.get(index);
          //     SB_NameCardL_BulkRegistDTO.CustomObject ncr = dataList[index - 1];

          //     //SV_DEV-727 リードへ登録、名刺所有者がキューおよリード所有者がキューの場合
          //     if(!String.valueOf(leadOwnerId).startsWith('005')) {
          //       //SV_DEV-755 無効なユーザでTODO登録したときのエラー
          //       String todoE = todoLabel + System.Label.SB_NCLD_MSG_Regist_Error;
          //       ncr.haveError = true;
          //       String msg = index + System.Label.SB_NC_Line + ': ' + todoE + ': ' + System.Label.SB_NCLD_MSG_QUEUES_ERROR + '<br>';
          //       todoError += msg;
          //       continue;
          //     }
          //   }
          // }

          //  // ToDo登録エラー
          // if (String.isNotBlank(todoError)) {
          //   throw new SB_NameCard_LeadRegist.LeadRegistException(todoError);
          // }

          // 新規リードがある場合
          // if (!newOwnerMap.isEmpty()) {
          //   // 名刺所有者を使うなら，キューはリードにサポートしているかのチェックがいる
          //   if (useNameCardOwner) {
          //     Map<Integer ,Id> queIdMap = new Map<Integer ,Id>();
          //     for (Integer key : newOwnerMap.keySet()) {
          //       if (!String.valueOf(newOwnerMap.get(key)).startsWith('005')) {
          //         queIdMap.put(key, newOwnerMap.get(key));
          //       }
          //     }

          //     List<QueueSobject> qss = [Select QueueId, SobjectType, Queue.Name
          //               FROM QueueSobject
          //              WHERE QueueId = :queIdMap.values()];
          //     Set<Id> canUserLeadQueues = new Set<Id>();
          //     Map<Id, String> qssMap = new Map<Id, String>();
          //     for (QueueSobject qs : qss) {
          //         qssMap.put(qs.QueueId, qs.Queue.Name);
          //         if (qs.SobjectType == 'Lead') {
          //             canUserLeadQueues.add(qs.QueueId);
          //         }
          //     }
          //     String errMsg = '';
          //     for (Integer index : queIdMap.keySet()) {
          //       Id qId = queIdMap.get(index);
          //       if (!canUserLeadQueues.contains(qId)) {
          //           dataList[index - 1].haveError = true;
          //           String msg1 = index + System.Label.SB_NC_Line + ': ' + Lead.getSobjectType().getDescribe().getLabel()
          //                       + System.Label.SB_NCLD_MSG_Regist_Error + ': ' + String.format(System.Label.SB_NCLD_MSG_QUEUES_LEAD_ERROR,new String[]{qssMap.get(qId)}) + '<br>';
          //           errMsg += msg1;
          //       }
          //     }
          //     if (String.isNotBlank(errMsg)) {
          //         throw new SB_NameCard_LeadRegist.LeadRegistException(errMsg);
          //     }
          //   }
          //   // 名刺所有者使ってないの場合基本的には画面上の所有者を使っても問題ないですが
          //   // 画面開いたまま他のユーザがキューを変更した場合のケースがあるかも知らないので，ここで1回チエックします
          //   else {
          //     if (!String.valueOf(oId).startsWith('005')) {
          //       List<QueueSobject> qss = [Select QueueId, SobjectType, Queue.Name
          //               FROM QueueSobject
          //              WHERE QueueId = :oId];
          //       Boolean leadQueue = false;
          //       Map<Id, String> qssMap = new Map<Id, String>();
          //       for (QueueSobject qs : qss) {
          //         qssMap.put(qs.QueueId, qs.Queue.Name);
          //         if (qs.SobjectType == 'Lead') {
          //             leadQueue = true;
          //         }
          //       }
          //       String errMsg = '';
          //       if (leadQueue == false) {
          //         String msg1 = Lead.getSobjectType().getDescribe().getLabel()
          //                       + System.Label.SB_NCLD_MSG_Regist_Error + ': ' + String.format(System.Label.SB_NCLD_MSG_QUEUES_LEAD_ERROR,new String[]{qssMap.get(oId)}) + '<br>';
          //         errMsg += msg1;
          //         throw new SB_NameCard_LeadRegist.LeadRegistException(errMsg);
          //       }
          //     }
          //   }
          // }

          SB_NameCardL_RegistHelper.RegistParam leadRP = new SB_NameCardL_RegistHelper.RegistParam('Lead', leadOverwrite, leadRecordTypeId,oId,false);
          SB_NameCardL_RegistHelper.TodoParam todoRP = new SB_NameCardL_RegistHelper.TodoParam(SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RegistToDoSubject__c,null,null,null);

          SB_NameCardL_RegistHelper.RegistRequest re = new SB_NameCardL_RegistHelper.RegistRequest(tars, null, null, leadRP, todoRP);
          //doRegist内既にrollbackしていますので、ここは二度目はしません
          SB_NameCardL_RegistHelper.RegistResponse result = SB_NameCardL_RegistHelper.doRegist(re);

          if (result.success == false) {
            str = '<br/>';
            // this.hasError = true;
            if (result.dbErrors!=null) {
              for (Integer i = 0; i<dataList.size(); i++) {
                if (result.dbErrors.containsKey(dataList[i].id)) {
                  dataList[i].haveError = true;
                  // ToDo
                  str += String.format('{0}' + System.Label.SB_NC_Line + ': {1}', new String[]{ ''+(i+1),result.dbErrors.get(dataList[i].id).msg + '<br/>'});
                } else{
                  dataList[i].haveError = false;
                }
              }
            }
            str = str.removeEnd('<br/>');
            throw new SB_NameCard_LeadRegist.LeadRegistException(result.title + str);
          } else {
            // this.hasError = false;
          }
          message += 'save ok';
      }
      catch (Exception e) {
          if (sp != null) Database.rollback(sp);
          // this.hasError = true;
          // saveOK = false;
          System.debug(e.getMessage());
          // message += e.getStackTraceString();
          message += e.getMessage();
          saveResult.errorMessage = message;
          saveResult.success = false;
          // testError = e.getMessage();
          // ApexPages.addMessages(e);
      }
      return JSON.serialize(saveResult);
      //return pageRef;
  }
}