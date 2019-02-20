/*
 * SB_NCL_TwowayBulkRgsLcController
 *
 * (c) 2018 Sunbridge Inc.
 *
 * 統合版一括登録Lex コントローラ
 * @Version 拡張パッケージ：Lead Ex. 1.12 SV_DEV-1161 統合版の一括登録ではtodo登録の一括選択がない
 * @Version 拡張パッケージ：Lead Ex. 1.12  2018/09/XX   SV_DEV-1195 [要望]（LEX用・Classic用「リードまたは取引先・取引先責任者に登録」一括登録画面)候補登録先「両方」の場合、「新規作成時の指定」でのキャンペーン指定をリードだけだとわかるようにしてほしい
 * @Version 拡張パッケージ：Lead Ex. 1.12  2018/09/XX   SV_DEV-1231 LEX画面「リードまたは取引先・取引先責任者に登録*」一括登録で、ビル情報・英語住所が住所項目に表示されない。
 *
 */
public with sharing class SB_NCL_TwowayBulkRgsLcController {

  private static final String LEADLABEL = Lead.sObjectType.getDescribe().getLabel();
  private static final String ACCOUNTLABEL = Account.sObjectType.getDescribe().getLabel();
  private static final String CONTACTLABEL = Contact.sObjectType.getDescribe().getLabel();

  private static final Integer SEARCHTYPE_EMAIL = 1;
  private static final Integer SEARCHTYPE_NAME  = 2;
  private static final Integer SEARCHTYPE_ACNAME = 3;
  private static final Integer SEARCHTYPE_ACNAMESITE  = 4;
  private static final Integer SEARCHTYPE_ACNAMESITESTATE = 5;
  private static final Integer SEARCHTYPE_NAMECITY  = 6;
  private static final Integer SEARCHTYPE_NAMECODE  = 7;
  private static SB_NameCardL_RegistCanPickerAbstract picker = new SB_NameCardL_RegistSoqlCountCanPicker();  //

  @RemoteAction
  @AuraEnabled
  // 全てのデータここで取得
   public static String getAllData(String recordIds, String fieldListStr, String searchType, String searchContactType, String recordTypesMapstr) {
    SB_NameCardL_BulkRegistDTO.SaveResult saveResult = new SB_NameCardL_BulkRegistDTO.SaveResult();
    try{
      List<SB_NameCardL_BulkRegistDTO.DataTableColumnField> fieldList;
      SmartViscaf__NameCardBasicSetting__c basicSetting = SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting();
      Map<String, List<SB_NameCardL_BulkRegistDTO.DataTableColumnField>> fieldMap = (Map<String, List<SB_NameCardL_BulkRegistDTO.DataTableColumnField>> )System.JSON.deserializeStrict(getFieldList(), Map<String, List<SB_NameCardL_BulkRegistDTO.DataTableColumnField>> .Class);
      fieldList = fieldMap.get('Both');
      List<String> recordIdList = recordIds.split(',');

      Set<String> fieldsSet = SB_NameCardL_RegistQueryExecutor.getNameCardFields();
      String query = String.format('SELECT {0} FROM SmartViscaf__NameCard__c WHERE Id = :recordIdList', new String[] { String.join(new List<String>(fieldsSet), ', ')});
      List<SmartViscaf__NameCard__c> ncs = Database.query(query);
      System.debug('ncs size' + ncs.size());
      System.debug('fieldList : ' + fieldList);
      Map<String, Schema.SObjectField> fields = SmartViscaf__NameCard__c.sObjectType.getDescribe().fields.getMap();
      List<SB_NameCardL_BulkRegistDTO.CustomObject> dataList = new List<SB_NameCardL_BulkRegistDTO.CustomObject>();

      Map<Id, SB_NameCardL_BulkRegistDTO.CustomObject> nameCardObjMap = new Map<Id, SB_NameCardL_BulkRegistDTO.CustomObject>();
      for (SmartViscaf__NameCard__c sobj : ncs) {
        SB_NameCardL_BulkRegistDTO.CustomObject co = new SB_NameCardL_BulkRegistDTO.CustomObject();
        for (SB_NameCardL_BulkRegistDTO.DataTableColumnField field : fieldList) {
          SB_NameCardL_BulkRegistDTO.CustomField cf = new SB_NameCardL_BulkRegistDTO.CustomField();
          if (String.isNotBlank(field.fieldName) && fields.containsKey(field.fieldName)) {
            cf.label = (String)sobj.get(field.fieldName);
            cf.value = (String)sobj.get(field.fieldName);
          }
          if (field.fieldName == 'ToDo' && String.isBlank(fieldListStr) || fieldListStr == '[]') {
            cf.checked = !basicSetting.SmartViscaf__RegistNoToDo__c;
          }

          cf.type = field.type;
          cf.input = field.input;
          cf.fieldName = field.fieldName;
          co.cObjectMap.put(cf.fieldName, cf);
        }
        // 名刺所有者項目
        SB_NameCardL_BulkRegistDTO.CustomField cf = new SB_NameCardL_BulkRegistDTO.CustomField(sobj, 'OwnerId', 'string', false, null);
        co.cObjectMap.put('OwnerId', cf);
        // 名刺Id項目
        SB_NameCardL_BulkRegistDTO.CustomField cfId = new SB_NameCardL_BulkRegistDTO.CustomField(sobj, 'Id', 'string', false, null);
        co.cObjectMap.put('Id', cfId);
        // 名刺会社名項目
        SB_NameCardL_BulkRegistDTO.CustomField cfCom = new SB_NameCardL_BulkRegistDTO.CustomField(sobj, 'SmartViscaf__company_name__c', 'string', false, null);
        if (String.isNotBlank(cfCom.label)) {
          co.cObjectMap.put('SmartViscaf__company_name__c', cfCom);
        }

        SB_NameCardL_BulkRegistDTO.CustomField cfTitle = new SB_NameCardL_BulkRegistDTO.CustomField(sobj, 'SmartViscaf__title_name__c', 'string', false, null);
        if (String.isNotBlank(cftitle.label)) {
          co.cObjectMap.put('SmartViscaf__title_name__c', cftitle);
        }

        SB_NameCardL_BulkRegistDTO.CustomField cfDiv = new SB_NameCardL_BulkRegistDTO.CustomField(sobj, 'SmartViscaf__division__c', 'string', false, null);
        if (String.isNotBlank(cfDiv.label)) {
          co.cObjectMap.put('SmartViscaf__division__c', cfDiv);
        }

        SB_NameCardL_BulkRegistDTO.CustomField cfName = new SB_NameCardL_BulkRegistDTO.CustomField(sobj, 'Name', 'url', false, string.format('/one/one.app#/sObject/{0}/view',new String[]{(Id)sobj.Id}));
        co.cObjectMap.put('Name', cfName);

        SB_NameCardL_BulkRegistDTO.CustomField cfAdd = new SB_NameCardL_BulkRegistDTO.CustomField();
        String address1 = String.isBlank((String)sobj.SmartViscaf__zip_code__c) ? '' : (String)sobj.SmartViscaf__zip_code__c;
        String address2 = String.isBlank((String)sobj.SmartViscaf__address_pref__c) ? '' : (String)sobj.SmartViscaf__address_pref__c;
        String address3 = String.isBlank((String)sobj.SmartViscaf__address__c) ? '' : (String)sobj.SmartViscaf__address__c;
        String address4 = String.isBlank((String)sobj.SmartViscaf__address_bld__c) ? '' : (String)sobj.SmartViscaf__address_bld__c;
        String address5 = String.isBlank((String)sobj.SmartViscaf__address_eng__c) ? '' : (String)sobj.SmartViscaf__address_eng__c;
        cfAdd.label = address1 + address2 + address3 + address4 + address5;
        cfAdd.value = address1 + address2 + address3 + address4 + address5;
        if (String.isNotBlank(cfAdd.label)) {
          co.cObjectMap.put('Address', cfAdd);
        }

        SB_NameCardL_BulkRegistDTO.CustomField cfMobil = new SB_NameCardL_BulkRegistDTO.CustomField(sobj, 'SmartViscaf__mobile__c', 'string', false, null);
        if (String.isNotBlank(cfMobil.label)) {
          co.cObjectMap.put('SmartViscaf__mobile__c', cfMobil);
        }


        SB_NameCardL_BulkRegistDTO.CustomField cfEmail = new SB_NameCardL_BulkRegistDTO.CustomField(sobj, 'SmartViscaf__email__c', 'string', false, null);
        if (String.isNotBlank(cfEmail.label)) {
          co.cObjectMap.put('SmartViscaf__email__c', cfEmail);
        }

        SB_NameCardL_BulkRegistDTO.CustomField cfAddpref = new SB_NameCardL_BulkRegistDTO.CustomField(sobj, 'SmartViscaf__address_pref__c', 'string', false, null);
        if (String.isNotBlank(cfAddpref.label)) {
          co.cObjectMap.put('SmartViscaf__address_pref__c', cfAddpref);
        }

        co.id = (Id)sobj.Id;
        co.nameCard = sobj;
        // if (String.isBlank(dto.lookUpId)) {
          // dto.lookUpId = co.id;
        // }
        nameCardObjMap.put(co.id, co);
        dataList.add(co);
      }
      Map<String, List<String>> recordTypesMap = new Map<String, List<String>>();
      if (String.isNotBlank(recordTypesMapstr) && recordTypesMapstr != 'null') {
        recordTypesMap = (Map<String, List<String>>)System.JSON.deserializeStrict(recordTypesMapstr, Map<String, List<String>> .Class);
      }
      searchAllLead(saveResult, recordIds, nameCardObjMap, searchType, searchContactType, recordTypesMap);
      if (saveResult.success == false) {
        return JSON.serialize(saveResult);
      }
      //dto.setDataList(ncs);
      System.debug(dataList);
      saveResult.success = true;
      saveResult.data = dataList;
      System.debug(Limits.getHeapSize());
      System.debug(Limits.getLimitHeapSize());
      if (Limits.getHeapSize() > Limits.getLimitHeapSize() * 0.5) {
        saveResult.data = null;
        throw new SB_NameCard_LeadRegist.LeadRegistException(System.Label.SB_NCLD_Msg_ChooseLessBusinessCards);
      }
    }
    catch (Exception e) {
      saveResult.success = false;
      saveResult.message = e.getMessage();
    }
    return JSON.serialize(saveResult);
  }

   public static String searchAllLead(SB_NameCardL_BulkRegistDTO.SaveResult saveResult, String nameCardIds, Map<Id, SB_NameCardL_BulkRegistDTO.CustomObject> nameCardObjMap, String searchType, String searchContactType, Map<String, List<String>> searchRecordTypesMap) {
    String message = '';
    if (saveResult == null) {
        saveResult = new SB_NameCardL_BulkRegistDTO.SaveResult();
    }
    try {
        // this.hasError = false;
        System.debug(nameCardIds);
        if (String.isBlank(nameCardIds)) {
          return null;
        }
        Set<Id> nameCardIdSet = new Set<Id>((List<Id>)new List<String>(nameCardIds.split(',')));

        // List<SmartViscaf__NameCard__c> nameCards = [Select Name, SmartViscaf__company_name__c, SmartViscaf__division__c, SmartViscaf__title_name__c,
        //                                              SmartViscaf__address__c, SmartViscaf__mobile__c, SmartViscaf__person_name_last__c, SmartViscaf__person_name_first__c,
        //                                              SmartViscaf__lead__c, SmartViscaf__email__c
        //                                         FROM SmartViscaf__NameCard__c
        //                                         WHERE id in :nameCardIdSet];
        Set<String> fields = SB_NameCardL_RegistQueryExecutor.getNameCardFields();
        String query = String.format('SELECT {0} FROM SmartViscaf__NameCard__c WHERE Id = :nameCardIdSet', new String[] { String.join(new List<String>(fields), ', ')});
        List<SmartViscaf__NameCard__c> nameCards = Database.query(query);
        // Map<Id, Lead> idMap = new Map<Id, Lead>();
        // Map<String, List<Lead>> emailListMap = new Map<String, List<Lead>>();
        // Map<String, List<Lead>> nameListMap = new Map<String, List<Lead>>();

        Map<Id,Map<Schema.SObjectType,List<SObject>>> sObjectList = buildCandidateList(nameCardIdSet, nameCards, searchType, searchContactType, searchRecordTypesMap);
        System.debug(sObjectList);
        Map<Schema.SObjectType, Map<Id, SObject>> sObjectTypemap = new Map<Schema.SObjectType, Map<Id, SObject>>();
        sObjectTypemap.put(Lead.sObjectType, new Map<Id, SObject>());
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
        // sObjectTypemap.put(Lead.sObjectType, new Map<Id, SObject>([Select Id, LastName, FirstName, Email, Name From Lead]));
        // setLeadMap(idMap, emailListMap, nameListMap, sObjectTypemap.get(Lead.sObjectType).values(), searchType);
        Map<Id, Map<String, SB_NameCardL_BulkRegistDTO.InputPlickListValue>> inputPlickListVMap = new Map<Id, Map<String, SB_NameCardL_BulkRegistDTO.InputPlickListValue>>();

        List<SB_NameCardL_BulkRegistDTO.CustomObject> dataList = new List<SB_NameCardL_BulkRegistDTO.CustomObject>();
        Boolean haveLead = false;
        Boolean haveAccount = false;
        Integer i = 0;
        for (SmartViscaf__NameCard__c nc : nameCards) {
            Map<String, SB_NameCardL_BulkRegistDTO.InputPlickListValue> inputPlickListMap = new  Map<String, SB_NameCardL_BulkRegistDTO.InputPlickListValue>();
            SB_NameCardL_BulkRegistDTO.InputPlickListValue inputPlickListV = new SB_NameCardL_BulkRegistDTO.InputPlickListValue();
            String leadId = 'none';
            String accountId = 'none';
            if (String.isBlank(nc.SmartViscaf__company_name__c) || String.isBlank(SmartViscaf.SB_NameCard_Util.getPersonName(nc).get('last_name'))) {
                inputPlickListV.plickListOptions.add(new SB_NameCardL_BulkRegistDTO.LabelValue(System.Label.SB_NCLD_DontRegister_CompanyNameRequired, 'none'));
                if (!SmartViscaf.SB_NameCard_Util.isEnablePersonAccount()) {
                  inputPlickListMap.put('Lead',inputPlickListV);
                }
                inputPlickListMap.put('Contact',inputPlickListV);
                if (SmartViscaf.SB_NameCard_Util.isEnablePersonAccount()
                  && String.isBlank(SmartViscaf.SB_NameCard_Util.getPersonName(nc).get('last_name'))) {
                  SB_NameCardL_BulkRegistDTO.InputPlickListValue inputPlickListV1 = new SB_NameCardL_BulkRegistDTO.InputPlickListValue();
                  inputPlickListV1.plickListOptions.add(new SB_NameCardL_BulkRegistDTO.LabelValue(System.Label.SB_NCLD_DontRegister_NameRequired, 'none'));
                  inputPlickListMap.put('Lead',inputPlickListV1);
                }
            }
            // setLeadRecord(idMap, emailListMap, nameListMap, nc, inputPlickListV.plickListOptions);
            // ncRec.setNameCardRecord(ncRec.nameCard, this.searchTypeContact, cIdMap, cEmailMap, cNameMap, cLastNameMap, aIdMap, aNameList);
            // ncRec.index = i;
            // if (ncRec.message != '') {
                    // message = ncRec.message;
            // }
            Map<Schema.SObjectType,List<SObject>> sObjectMap;
            inputPlickListV = new SB_NameCardL_BulkRegistDTO.InputPlickListValue();
            if (!inputPlickListMap.containsKey('Lead')
              || !inputPlickListMap.containsKey('Contact')) {
              sObjectMap = sObjectList.get(nc.Id);
            }
            if (!inputPlickListMap.containsKey('Lead')) {
              if (sObjectMap.containsKey(Lead.sObjecttype)) {
                List<sObject> sLeadList = sObjectMap.get(Lead.sObjecttype);
                for (sObject obj : sLeadList) {
                  Lead lead = (Lead)obj;
                  String label = getLabel(lead.Name, lead.Email);
                  inputPlickListV.plickListOptions.add(new SB_NameCardL_BulkRegistDTO.LabelValue(label, lead.Id));
                  inputPlickListV.plickListValueMap.put(lead.Id, label);
                  haveLead = true;
                  if (leadId == 'none') {
                    leadId = lead.Id;
                  }
                }
              }

              if(Lead.sObjectType.getDescribe().isCreateable()) {
                String label = System.Label.SB_NCLD_Menu_NewLead;
                inputPlickListV.plickListOptions.add(new SB_NameCardL_BulkRegistDTO.LabelValue(label, 'new'));
                inputPlickListV.plickListValueMap.put('new', label);
                if (leadId == 'none') {
                  leadId = 'new';
                }
              }
              inputPlickListV.plickListOptions.add(new SB_NameCardL_BulkRegistDTO.LabelValue(System.Label.SB_NCLD_Menu_NotToRegister, 'none'));
              inputPlickListV.plickListValueMap.put('none', System.Label.SB_NCLD_Menu_NotToRegister);

              inputPlickListMap.put('Lead',inputPlickListV);
            }

            if (!inputPlickListMap.containsKey('Contact')) {

              inputPlickListV = new SB_NameCardL_BulkRegistDTO.InputPlickListValue();
              if (sObjectMap.containsKey(Contact.sObjecttype)) {
                List<sObject> sContactList = sObjectMap.get(Contact.sObjecttype);
                for (sObject sobj : sContactList) {
                  Contact con = (Contact)sobj;
                  String label = con.Account.Name + '(' + getStr(con.Account.Site) + ')' + '/' + con.Name + '(' + getStr(con.Department) + '/' + getStr(con.Email) + ')';
                  String ids = '';
                  if (String.isNotBlank(con.AccountId)) {
                    ids = con.AccountId + ':' + con.Id;
                  }
                  else {
                    ids = ':' + con.Id;
                  }
                  inputPlickListV.plickListOptions.add(new SB_NameCardL_BulkRegistDTO.LabelValue(label, ids));
                  inputPlickListV.plickListValueMap.put(con.AccountId + ':' + con.Id, label);
                  haveAccount = true;
                  if (accountId == 'none') {
                    accountId = ids;
                    leadId = 'none';
                  }
                }
              }
              if (sObjectMap.containsKey(Account.sObjecttype) && Contact.sObjectType.getDescribe().isCreateable()) {
                List<sObject> sAccountList = sObjectMap.get(Account.sObjecttype);
                for (sObject sobj : sAccountList) {
                  Account a = (Account)sobj;
                  String label = a.Name + '(' + getStr(a.Site) + ')' + '/' + String.format(System.Label.SB_NCLD_Label_CreateNewLeadDEV, new String[]{Contact.sObjecttype.getDescribe().getLabel()});
                  inputPlickListV.plickListOptions.add(new SB_NameCardL_BulkRegistDTO.LabelValue(label, a.Id + ':'));
                  inputPlickListV.plickListValueMap.put(a.Id + ':', label);
                  haveAccount = true;
                  if (accountId == 'none') {
                    accountId = a.Id + ':';
                    leadId = 'none';
                  }
                }
              }
              // String.valueOf(index), c.Account.Name + '(' + SB_NameCard_Util.getStr(c.Account.Site) + ')' + '/' + c.Name + '(' + SB_NameCard_Util.getStr(c.Department) + '/' + SB_NameCard_Util.getStr(c.Email) + ')')
              if(Contact.sObjectType.getDescribe().isCreateable() && Account.sObjectType.getDescribe().isCreateable()) {
                inputPlickListV.plickListOptions.add(new SB_NameCardL_BulkRegistDTO.LabelValue(System.Label.SB_NCLD_Menu_NewLead + '/' + System.Label.SB_NCLD_Menu_NewLead, 'new'));
                inputPlickListV.plickListValueMap.put('new', System.Label.SB_NCLD_Menu_NewLead);
              }
              inputPlickListV.plickListOptions.add(new SB_NameCardL_BulkRegistDTO.LabelValue(System.Label.SB_NCLD_Menu_NotToRegister, 'none'));
              inputPlickListV.plickListValueMap.put('none', System.Label.SB_NCLD_Menu_NotToRegister);

              inputPlickListMap.put('Contact',inputPlickListV);
            }


            nameCardObjMap.get(nc.Id).combobox = inputPlickListMap;
            nameCardObjMap.get(nc.Id).cObjectMap.get('Lead').value = leadId;
            nameCardObjMap.get(nc.Id).cObjectMap.get('Contact').value = accountId;
            // inputPlickListVMap.put(nc.Id, inputPlickListMap);
            i ++;
            if (Limits.getHeapSize() > Limits.getLimitHeapSize() * 0.5) {
              saveResult.data = null;
              throw new SB_NameCard_LeadRegist.LeadRegistException(System.Label.SB_NCLD_Msg_ChooseLessBusinessCards);
            }
        }
        if (message != '') {
                // testError = message;
                // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, message));
        }
        if (haveAccount && haveLead) {
          saveResult.otherMessage.put('showType', 'Both');
        }
        else if (haveAccount) {
          saveResult.otherMessage.put('showType', 'Contact');
        }
        else if (haveAccount == false && haveLead == false) {
          saveResult.otherMessage.put('showType', SB_NameCard_LeadRegist.svConfig.defaultDisplayExistingLead() ? 'Lead' : 'Contact');
        }
        else {
          saveResult.otherMessage.put('showType', 'Lead');
        }
        // saveResult.success = true;
        // saveResult.data = inputPlickListVMap;
    } catch (Exception e) {
      System.debug(e.getStackTraceString());
      saveResult.success = false;
      saveResult.message = e.getMessage();
      // saveResult.message += e.getStackTraceString();
      // testError = e.getMessage();
      // ApexPages.addMessages(e);
    }
    return JSON.serialize(saveResult);
  }

  @RemoteAction
  @AuraEnabled
  // タイトルに関する内容ここで取得
  public static String getTitleValue() {
    SB_NameCardL_BulkRegistDTO.TitleValue titleV = new SB_NameCardL_BulkRegistDTO.TitleValue();
    titleV.titleName = String.format(System.Label.SB_NCLD_Text_RegisterToLeads_OR_Accounts_Contacts, new String[]{LEADLABEL, ACCOUNTLABEL, CONTACTLABEL});
    titleV.iconName = 'standard:account';
    titleV.iconSize = 'large';
    titleV.closeValue = System.Label.SB_NCLD_Label_Close;
    titleV.saveValue = System.Label.SB_NCLD_Label_Save;
    return JSON.serialize(titleV);
  }

  @RemoteAction
  @AuraEnabled
  // 画面入力内容をここで取得
  public static String getInputValue() {
    SmartViscaf__NameCardBasicSetting__c basicSetting = SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting();
    SB_NameCardL_BulkRegistDTO.InputValue inv = new SB_NameCardL_BulkRegistDTO.InputValue();
    inv.useNameCardOwnerLabel = String.format(System.Label.SB_NCLD_Label_UseNameCardOwnerByObject, new String[]{LEADLABEL});
    inv.useNameCardAccountOwnerLabel = String.format(System.Label.SB_NCLD_Label_UseNameCardOwnerByObject, new String[]{ACCOUNTLABEL});
    inv.campaignStatusPlick.plickListTitle = System.Label.SB_NCLD_Label_CampaignStatus;
    inv.campaignLabel = SmartViscaf__NameCard__c.Campaign__c.getDescribe().getLabel();
    inv.ownerLabel = LEADLABEL + System.Label.SB_NCLD_Label_Owner;
    inv.accountOwnerLabel = ACCOUNTLABEL + System.Label.SB_NCLD_Label_Owner;
    inv.newSectionLabel = String.format(System.Label.SB_NCLD_Text_SpecifiedWhenCreateNew, new String[] {LEADLABEL});
    inv.overWriteLabel = System.Label.SB_NCLD_Text_SpecifiedWhenOverWrite;
    inv.useNameCardOwner = true;
    inv.useNameCardAccountOwner = true;

    // リード上書き
    SB_NameCardL_BulkRegistDTO.InputRegistOverWritValue inputO = new SB_NameCardL_BulkRegistDTO.InputRegistOverWritValue();
    SB_NameCardL_BulkRegistDTO.LabelValueCheck lc = new SB_NameCardL_BulkRegistDTO.LabelValueCheck();
    lc.label = String.format(System.Label.SB_NCLD_Label_OverwriteLeadInfoDEV, new String[] {LEADLABEL});
    lc.disabled = inv.leadAuthority.isUpdateable == false;
    lc.checked = basicSetting.SmartViscaf__RegistLeadNotOverWrite__c == false && !lc.disabled;
    inputO.overWriteCheck = lc;
    inputO.overId = 'Lead';
    inputO.show = false;
    inputO.canShow = basicSetting.SmartViscaf__RegistDispLeadOverWriteCheckbox__c;
    inv.inputRegistOverWritValues.add(inputO);

    // 取引先上書き
    inputO = new SB_NameCardL_BulkRegistDTO.InputRegistOverWritValue();
    lc = new SB_NameCardL_BulkRegistDTO.LabelValueCheck();
    lc.label = String.format(System.Label.SB_NCLD_Label_OverwriteLeadInfoDEV, new String[] {ACCOUNTLABEL});
    lc.disabled = inv.accountAuthority.isUpdateable == false;
    lc.checked = basicSetting.SmartViscaf__RegistAccountNotOverWrite__c == false && !lc.disabled;
    inputO.overWriteCheck = lc;
    inputO.overId = 'Account';
    inputO.show = false;
    inputO.canShow = basicSetting.SmartViscaf__RegistDispAccountOverWriteCheckbox__c;
    inv.inputRegistOverWritValues.add(inputO);
    // 取引先責任者上書き
    inputO = new SB_NameCardL_BulkRegistDTO.InputRegistOverWritValue();
    lc = new SB_NameCardL_BulkRegistDTO.LabelValueCheck();
    lc.label = String.format(System.Label.SB_NCLD_Label_OverwriteLeadInfoDEV, new String[] {CONTACTLABEL});
    lc.disabled = inv.contactAuthority.isUpdateable == false;
    lc.checked = basicSetting.SmartViscaf__RegistContactNotOverWrite__c == false && !lc.disabled;
    inputO.overWriteCheck = lc;
    inputO.overId = 'Contact';
    inputO.show = false;
    inputO.canShow = basicSetting.SmartViscaf__RegistDispContactOverWriteCheckbox__c;
    inv.inputRegistOverWritValues.add(inputO);

    SB_NameCardL_BulkRegistDTO.SearchCondition sc0 = new SB_NameCardL_BulkRegistDTO.SearchCondition(LEADLABEL, Lead.sObjecttype.getDescribe().getLabel(), '', '');
    sc0.groupName = 'Lead';
    sc0.disabled = true;
    sc0.className = 'disLead';
    inv.searchConditions.add(sc0);

    SB_NameCardL_BulkRegistDTO.SearchCondition sc1 = new SB_NameCardL_BulkRegistDTO.SearchCondition(Lead.Email.getDescribe().getLabel(), String.valueOf(SEARCHTYPE_EMAIL), 'utility:email', '');
    sc1.groupName = 'Lead';
    inv.searchConditions.add(sc1);
    SB_NameCardL_BulkRegistDTO.SearchCondition sc2 = new SB_NameCardL_BulkRegistDTO.SearchCondition(System.Label.SB_NCLD_Label_Name, String.valueOf(SEARCHTYPE_NAME), 'utility:user', '');
    sc2.groupName = 'Lead';
    inv.searchConditions.add(sc2);
    inv.searchConditionValue = String.valueOf(SEARCHTYPE_EMAIL);

    SB_NameCardL_BulkRegistDTO.SearchCondition scc0 = new SB_NameCardL_BulkRegistDTO.SearchCondition(CONTACTLABEL, Contact.sObjecttype.getDescribe().getLabel(), '', '');
    scc0.groupName = 'Contact';
    scc0.disabled = true;
    scc0.className = 'disContact';
    inv.searchConditions.add(scc0);

    String accountName = Account.Name.getDescribe().getLabel();
    String accountSite = System.Label.SB_NCLD_Label_Site;
    String andLabel = System.Label.SB_NCLD_Label_AND;

    SB_NameCardL_BulkRegistDTO.SearchCondition scc1 = new SB_NameCardL_BulkRegistDTO.SearchCondition(accountName, String.valueOf(SEARCHTYPE_ACNAME), 'utility:company', '');
    scc1.groupName = 'Contact';
    inv.searchConditions.add(scc1);
    SB_NameCardL_BulkRegistDTO.SearchCondition scc2 = new SB_NameCardL_BulkRegistDTO.SearchCondition(String.format(System.Label.SB_NCLD_Text_A_AND_B, new String[] {accountName, accountSite}), String.valueOf(SEARCHTYPE_ACNAMESITE), 'utility:hierarchy', '');
    scc2.groupName = 'Contact';
    inv.searchConditions.add(scc2);
    SB_NameCardL_BulkRegistDTO.SearchCondition scc3 = new SB_NameCardL_BulkRegistDTO.SearchCondition(String.format(System.Label.SB_NCLD_Text_A_AND_B_AND_C, new String[] {accountName, accountSite, System.Label.SB_NCLD_Label_Prefectures}), String.valueOf(SEARCHTYPE_ACNAMESITESTATE), 'utility:signpost', '');
    scc3.groupName = 'Contact';
    inv.searchConditions.add(scc3);
    SB_NameCardL_BulkRegistDTO.SearchCondition scc4 = new SB_NameCardL_BulkRegistDTO.SearchCondition(String.format(System.Label.SB_NCLD_Text_A_AND_B_AND_C, new String[] {accountName, accountSite, System.Label.SB_NCLD_Label_To_Street}), String.valueOf(SEARCHTYPE_NAMECITY), 'utility:pin', '');
    scc4.groupName = 'Contact';
    inv.searchConditions.add(scc4);
    SB_NameCardL_BulkRegistDTO.SearchCondition scc5 = new SB_NameCardL_BulkRegistDTO.SearchCondition(String.format(System.Label.SB_NCLD_Text_A_AND_B_AND_C, new String[] {accountName, accountSite, System.Label.SB_NCLD_Label_Postcode}), String.valueOf(SEARCHTYPE_NAMECODE), 'utility:email', '');
    scc5.groupName = 'Contact';
    inv.searchConditions.add(scc5);
    inv.searchConditionValueContact = String.valueOf(3);

    inv.searchConditionRct.title = System.Label.SB_NCLD_Label_Setting;
    inv.labelMap.put('AccountContact', String.format(System.Label.SB_NCLD_Text_Account_Contact, new String[] {ACCOUNTLABEL, CONTACTLABEL}));
    inv.labelMap.put('LeadLabel', Lead.sObjecttype.getDescribe().getLabel());
    inv.labelMap.put('LeadNew', String.format(System.Label.SB_NCLD_Text_SpecifiedWhenCreateNew, new String[] {LEADLABEL}));
    inv.labelMap.put('AccountNew', String.format(System.Label.SB_NCLD_Text_SpecifiedWhenCreateNew, new String[] {String.format(System.Label.SB_NCLD_Text_Account_Contact, new String[] {ACCOUNTLABEL, CONTACTLABEL})}));
    inv.labelMap.put('BothNew', String.format(System.Label.SB_NCLD_Text_SpecifiedWhenCreateNew, new String[] {'Record'}));
    inv.labelMap.put('cardLabel_SmartViscaf__company_name__c', SmartViscaf__NameCard__c.SmartViscaf__company_name__c.getDescribe().getLabel());
    inv.labelMap.put('cardLabel_SmartViscaf__division__c', SmartViscaf__NameCard__c.SmartViscaf__division__c.getDescribe().getLabel());
    inv.labelMap.put('cardLabel_SmartViscaf__title_name__c', SmartViscaf__NameCard__c.SmartViscaf__title_name__c.getDescribe().getLabel());
    inv.labelMap.put('cardLabel_Name', SmartViscaf__NameCard__c.Name.getDescribe().getLabel());
    inv.labelMap.put('cardLabel_SmartViscaf__address__c', SmartViscaf__NameCard__c.SmartViscaf__address__c.getDescribe().getLabel());
    inv.labelMap.put('cardLabel_SmartViscaf__mobile__c', SmartViscaf__NameCard__c.SmartViscaf__mobile__c.getDescribe().getLabel());
    inv.labelMap.put('cardLabel_SmartViscaf__email__c', SmartViscaf__NameCard__c.SmartViscaf__email__c.getDescribe().getLabel());
    inv.labelMap.put('SmartViscaf__address_pref__c', SmartViscaf__NameCard__c.SmartViscaf__address_pref__c.getDescribe().getLabel());
    inv.labelMap.put('campaignAPILabel', Campaign.getSObjectType().getDescribe().getLabel());
    inv.searchConditionRct.description = System.Label.SB_NCLD_Label_SearchRecordTypeExplanation;

    List<RecordTypeInfo> leadRecordTypes = SB_NCL_TwowayBulkRgsLcController.getRecordType(Lead.sObjecttype);
    SB_NameCardL_BulkRegistDTO.SearchConditionRecordTypeOptionGroup   optionGroup = new SB_NameCardL_BulkRegistDTO.SearchConditionRecordTypeOptionGroup();
    optionGroup.title = String.format(System.Label.SB_NCLD_Label_LeadRecType, new String[] {Lead.sObjecttype.getDescribe().getLabel()});
    optionGroup.titleId = 'Lead';
    SB_NameCardL_BulkRegistDTO.InputPlickListValue inputR = new SB_NameCardL_BulkRegistDTO.InputPlickListValue();
    inputR.plickListTitle = String.format(System.Label.SB_NCLD_Label_LeadRecType, new List<String> {Lead.SobjectType.getDescribe().getLabel()});
    inputR.selectValue = SB_NameCardL_Util.getDefaultRecordType(Lead.sObjecttype);
    inputR.show = inv.leadAuthority.isCreateable;
    inv.InputPlickListValues.add(inputR);
    for (RecordTypeInfo info : leadRecordTypes) {
      inputR.plickListOptions.add(new SB_NameCardL_BulkRegistDTO.LabelValue(info.getName(), info.getRecordTypeId()));
      SB_NameCardL_BulkRegistDTO.LabelValueCheck lvc = new SB_NameCardL_BulkRegistDTO.LabelValueCheck();
      lvc.label = info.getName();
      lvc.value = info.getRecordTypeId();
      lvc.checked = true;
      optionGroup.searchConditionplickListOptions.add(lvc);
      if (!inv.searchRecordTypesMap.containsKey('Lead')) {
        inv.searchRecordTypesMap.put('Lead', new List<String>());
      }
      inv.searchRecordTypesMap.get('Lead').add(info.getRecordTypeId());
      // if (String.isBlank(inv.searchRecordTypes)) {
      //   inv.searchRecordTypes = info.getRecordTypeId();
      // }
      // else {
      //   inv.searchRecordTypes += ',' + info.getRecordTypeId();
      // }
    }
    inv.showRecordType = !inputR.plickListOptions.isEmpty();
    inputR.canShow = inputR.plickListOptions.size() > 1 && inv.leadAuthority.isCreateable && basicSetting.SmartViscaf__RegistDispLeadRectype__c;
    inv.searchConditionRct.searchConditionRecordTypeOptionGroups.add(optionGroup);

    List<RecordTypeInfo> accountRecordTypes = SB_NCL_TwowayBulkRgsLcController.getRecordType(Account.sObjecttype);
    optionGroup = new SB_NameCardL_BulkRegistDTO.SearchConditionRecordTypeOptionGroup();
    optionGroup.title = String.format(System.Label.SB_NCLD_Label_LeadRecType, new String[] {Account.sObjecttype.getDescribe().getLabel()});
    optionGroup.titleId = 'Account';
    inputR = new SB_NameCardL_BulkRegistDTO.InputPlickListValue();
    inputR.plickListTitle = String.format(System.Label.SB_NCLD_Label_LeadRecType, new List<String> {Account.SobjectType.getDescribe().getLabel()});
    inputR.selectValue = SB_NameCardL_Util.getDefaultRecordType(Account.sObjecttype);
    inputR.show = false;
    inv.InputPlickListValues.add(inputR);
    for (RecordTypeInfo info : accountRecordTypes) {
      inputR.plickListOptions.add(new SB_NameCardL_BulkRegistDTO.LabelValue(info.getName(), info.getRecordTypeId()));
      SB_NameCardL_BulkRegistDTO.LabelValueCheck lvc = new SB_NameCardL_BulkRegistDTO.LabelValueCheck();
      lvc.label = info.getName();
      lvc.value = info.getRecordTypeId();
      lvc.checked = true;
      optionGroup.searchConditionplickListOptions.add(lvc);
      if (!inv.searchRecordTypesMap.containsKey('Account')) {
        inv.searchRecordTypesMap.put('Account', new List<String>());
      }
      inv.searchRecordTypesMap.get('Account').add(info.getRecordTypeId());
      // if (String.isBlank(inv.searchRecordTypes)) {
      //   inv.searchRecordTypes = info.getRecordTypeId();
      // }
      // else {
      //   inv.searchRecordTypes += ',' + info.getRecordTypeId();
      // }
    }
    inputR.canShow = inputR.plickListOptions.size() > 1 && inv.accountAuthority.isCreateable && basicSetting.SmartViscaf__RegistDispAccountRectype__c;
    inv.searchConditionRct.searchConditionRecordTypeOptionGroups.add(optionGroup);

    List<RecordTypeInfo> contactRecordTypes = SB_NCL_TwowayBulkRgsLcController.getRecordType(Contact.sObjecttype);
    optionGroup = new SB_NameCardL_BulkRegistDTO.SearchConditionRecordTypeOptionGroup();
    optionGroup.title = String.format(System.Label.SB_NCLD_Label_LeadRecType, new String[] {Contact.sObjecttype.getDescribe().getLabel()});
    optionGroup.titleId = 'Contact';
    inputR = new SB_NameCardL_BulkRegistDTO.InputPlickListValue();
    inputR.plickListTitle = String.format(System.Label.SB_NCLD_Label_LeadRecType, new List<String> {Contact.SobjectType.getDescribe().getLabel()});
    inputR.selectValue = SB_NameCardL_Util.getDefaultRecordType(Contact.sObjecttype);
    inputR.show = false;
    inv.InputPlickListValues.add(inputR);
    for (RecordTypeInfo info : contactRecordTypes) {
      inputR.plickListOptions.add(new SB_NameCardL_BulkRegistDTO.LabelValue(info.getName(), info.getRecordTypeId()));
      SB_NameCardL_BulkRegistDTO.LabelValueCheck lvc = new SB_NameCardL_BulkRegistDTO.LabelValueCheck();
      lvc.label = info.getName();
      lvc.value = info.getRecordTypeId();
      lvc.checked = true;
      optionGroup.searchConditionplickListOptions.add(lvc);
      if (!inv.searchRecordTypesMap.containsKey('Contact')) {
        inv.searchRecordTypesMap.put('Contact', new List<String>());
      }
      inv.searchRecordTypesMap.get('Contact').add(info.getRecordTypeId());
      // if (String.isBlank(inv.searchRecordTypes)) {
      //   inv.searchRecordTypes = info.getRecordTypeId();
      // }
      // else {
      //   inv.searchRecordTypes += ',' + info.getRecordTypeId();
      // }
    }
    inputR.canShow = inputR.plickListOptions.size() > 1 && inv.contactAuthority.isCreateable && basicSetting.SmartViscaf__RegistDispContactRectype__c;
    inv.searchConditionRct.searchConditionRecordTypeOptionGroups.add(optionGroup);

    // inv.haveQueue = ![Select QueueId, SobjectType, Queue.Name
    //                       FROM QueueSobject
    //                      WHERE SobjectType = 'Lead'].isEmpty();
    inv.haveQueue = true;

    return JSON.serialize(inv);
  }

  // 画面表示項目ここで設定
  @RemoteAction
  @AuraEnabled
  public static String getFieldList() {
    Map<String, List<SB_NameCardL_BulkRegistDTO.DataTableColumnField>> fieldMap = new Map<String, List<SB_NameCardL_BulkRegistDTO.DataTableColumnField>>();

    List<SB_NameCardL_BulkRegistDTO.DataTableColumnField> fieldList = new List<SB_NameCardL_BulkRegistDTO.DataTableColumnField>();
    // fieldList.add(new SB_NameCardL_BulkRegistDTO.DataTableColumnField(SmartViscaf__NameCard__c.SmartViscaf__company_name__c.getDescribe().getLabel(),
    //                                        'SmartViscaf__company_name__c',
    //                                        'string',
    //                                        false));
    // fieldList.add(new SB_NameCardL_BulkRegistDTO.DataTableColumnField(SmartViscaf__NameCard__c.SmartViscaf__division__c.getDescribe().getLabel(),
    //                                        'SmartViscaf__division__c',
    //                                        'string',
    //                                        false));
    // fieldList.add(new SB_NameCardL_BulkRegistDTO.DataTableColumnField(SmartViscaf__NameCard__c.SmartViscaf__title_name__c.getDescribe().getLabel(),
    //                                        'SmartViscaf__title_name__c',
    //                                        'string',
    //                                        false));
    // fieldList.add(new SB_NameCardL_BulkRegistDTO.DataTableColumnField(SmartViscaf__NameCard__c.Name.getDescribe().getLabel(),
    //                                        'Name',
    //                                        'url',
    //                                        false));
    // fieldList.add(new SB_NameCardL_BulkRegistDTO.DataTableColumnField(SmartViscaf__NameCard__c.SmartViscaf__address__c.getDescribe().getLabel(),
    //                                        'Address',
    //                                        'string',
    //                                        false));
    // fieldList.add(new SB_NameCardL_BulkRegistDTO.DataTableColumnField(SmartViscaf__NameCard__c.SmartViscaf__mobile__c.getDescribe().getLabel(),
    //                                        'SmartViscaf__mobile__c',
    //                                        'string',
    //                                        false));
    SB_NameCardL_BulkRegistDTO.DataTableColumnField f1 = new SB_NameCardL_BulkRegistDTO.DataTableColumnField(Lead.sObjectType.getDescribe().getLabel(),
                                           'Lead',
                                           'plicklist',
                                           true);
    f1.eventName = 'cleanContactPlicklist';
    fieldList.add(f1);
    f1 = new SB_NameCardL_BulkRegistDTO.DataTableColumnField(System.Label.SB_NCLD_Label_ToDoRegistration,
                                           'ToDo',
                                           'checkbox',
                                           true);
    f1.checkAll = true;
    f1.checkAllCheck = !SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RegistNoToDo__c;
    fieldList.add(f1);
    fieldMap.put('Lead', fieldList);
    fieldList = new List<SB_NameCardL_BulkRegistDTO.DataTableColumnField>();
    // fieldList.add(new SB_NameCardL_BulkRegistDTO.DataTableColumnField(SmartViscaf__NameCard__c.SmartViscaf__company_name__c.getDescribe().getLabel(),
    //                                        'SmartViscaf__company_name__c',
    //                                        'string',
    //                                        false));
    // fieldList.add(new SB_NameCardL_BulkRegistDTO.DataTableColumnField(SmartViscaf__NameCard__c.SmartViscaf__division__c.getDescribe().getLabel(),
    //                                        'SmartViscaf__division__c',
    //                                        'string',
    //                                        false));
    // fieldList.add(new SB_NameCardL_BulkRegistDTO.DataTableColumnField(SmartViscaf__NameCard__c.SmartViscaf__title_name__c.getDescribe().getLabel(),
    //                                        'SmartViscaf__title_name__c',
    //                                        'string',
    //                                        false));
    // fieldList.add(new SB_NameCardL_BulkRegistDTO.DataTableColumnField(SmartViscaf__NameCard__c.Name.getDescribe().getLabel(),
    //                                        'Name',
    //                                        'url',
    //                                        false));
    // fieldList.add(new SB_NameCardL_BulkRegistDTO.DataTableColumnField(SmartViscaf__NameCard__c.SmartViscaf__address__c.getDescribe().getLabel(),
    //                                        'Address',
    //                                        'string',
    //                                        false));
    // fieldList.add(new SB_NameCardL_BulkRegistDTO.DataTableColumnField(SmartViscaf__NameCard__c.SmartViscaf__mobile__c.getDescribe().getLabel(),
    //                                        'SmartViscaf__mobile__c',
    //                                        'string',
    //                                        false));
    // fieldList.add(new SB_NameCardL_BulkRegistDTO.DataTableColumnField(SmartViscaf__NameCard__c.SmartViscaf__email__c.getDescribe().getLabel(),
    //                                        'SmartViscaf__email__c',
    //                                        'string',
    //                                        false));
    SB_NameCardL_BulkRegistDTO.DataTableColumnField f2 = new SB_NameCardL_BulkRegistDTO.DataTableColumnField(String.format(System.Label.SB_NCLD_Label_AccountANDContact, new String[] {ACCOUNTLABEL, CONTACTLABEL, Contact.Department.getDescribe().getLabel(), Contact.Email.getDescribe().getLabel()}),
                                           'Contact',
                                           'plicklist',
                                           true);
    f2.eventName = 'cleanLeadPlicklist';
    fieldList.add(f2);
    f2 = new SB_NameCardL_BulkRegistDTO.DataTableColumnField(System.Label.SB_NCLD_Label_ToDoRegistration,
                                           'ToDo',
                                           'checkbox',
                                           true);
    f2.checkAll = true;
    f2.checkAllCheck = !SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RegistNoToDo__c;
    fieldList.add(f2);
    fieldMap.put('Contact', fieldList);
    fieldList = new List<SB_NameCardL_BulkRegistDTO.DataTableColumnField>();
    // fieldList.add(new SB_NameCardL_BulkRegistDTO.DataTableColumnField(SmartViscaf__NameCard__c.SmartViscaf__company_name__c.getDescribe().getLabel(),
    //                                        'SmartViscaf__company_name__c',
    //                                        'string',
    //                                        false));
    // fieldList.add(new SB_NameCardL_BulkRegistDTO.DataTableColumnField(SmartViscaf__NameCard__c.SmartViscaf__division__c.getDescribe().getLabel(),
    //                                        'SmartViscaf__division__c',
    //                                        'string',
    //                                        false));
    // fieldList.add(new SB_NameCardL_BulkRegistDTO.DataTableColumnField(SmartViscaf__NameCard__c.SmartViscaf__title_name__c.getDescribe().getLabel(),
    //                                        'SmartViscaf__title_name__c',
    //                                        'string',
    //                                        false));
    // fieldList.add(new SB_NameCardL_BulkRegistDTO.DataTableColumnField(SmartViscaf__NameCard__c.Name.getDescribe().getLabel(),
    //                                        'Name',
    //                                        'url',
    //                                        false));
    // fieldList.add(new SB_NameCardL_BulkRegistDTO.DataTableColumnField(SmartViscaf__NameCard__c.SmartViscaf__address__c.getDescribe().getLabel(),
    //                                        'Address',
    //                                        'string',
    //                                        false));
    // fieldList.add(new SB_NameCardL_BulkRegistDTO.DataTableColumnField(SmartViscaf__NameCard__c.SmartViscaf__mobile__c.getDescribe().getLabel(),
    //                                        'SmartViscaf__mobile__c',
    //                                        'string',
    //                                        false));
    // fieldList.add(new SB_NameCardL_BulkRegistDTO.DataTableColumnField(SmartViscaf__NameCard__c.SmartViscaf__email__c.getDescribe().getLabel(),
    //                                        'SmartViscaf__email__c',
    //                                        'string',
    //                                        false));
    f1 = new SB_NameCardL_BulkRegistDTO.DataTableColumnField(Lead.sObjectType.getDescribe().getLabel(),
                                           'Lead',
                                           'plicklist',
                                           true);
    f1.eventName = 'cleanContactPlicklist';
    fieldList.add(f1);
    f2 = new SB_NameCardL_BulkRegistDTO.DataTableColumnField(String.format(System.Label.SB_NCLD_Label_AccountANDContact, new String[] {ACCOUNTLABEL, CONTACTLABEL, Contact.Department.getDescribe().getLabel(), Contact.Email.getDescribe().getLabel()}),
                                           'Contact',
                                           'plicklist',
                                           true);
    f2.eventName = 'cleanLeadPlicklist';
    fieldList.add(f2);
    f2 = new SB_NameCardL_BulkRegistDTO.DataTableColumnField(System.Label.SB_NCLD_Label_ToDoRegistration,
                                           'ToDo',
                                           'checkbox',
                                           true);
    f2.checkAll = true;
    f2.checkAllCheck = !SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RegistNoToDo__c;
    fieldList.add(f2);
    fieldMap.put('Both', fieldList);

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
  public static String searchAllLead(String nameCardIds, String searchType, String searchContactType, Map<String, List<String>> searchRecordTypesMap) {
    String message = '';
    SB_NameCardL_BulkRegistDTO.SaveResult saveResult = new SB_NameCardL_BulkRegistDTO.SaveResult();
    try {
        // this.hasError = false;
        System.debug(nameCardIds);
        if (String.isBlank(nameCardIds)) {
          return null;
        }
        Set<Id> nameCardIdSet = new Set<Id>((List<Id>)new List<String>(nameCardIds.split(',')));

        // List<SmartViscaf__NameCard__c> nameCards = [Select Name, SmartViscaf__company_name__c, SmartViscaf__division__c, SmartViscaf__title_name__c,
        //                                              SmartViscaf__address__c, SmartViscaf__mobile__c, SmartViscaf__person_name_last__c, SmartViscaf__person_name_first__c,
        //                                              SmartViscaf__lead__c, SmartViscaf__email__c
        //                                         FROM SmartViscaf__NameCard__c
        //                                         WHERE id in :nameCardIdSet];
        Set<String> fields = SB_NameCardL_RegistQueryExecutor.getNameCardFields();
        String query = String.format('SELECT {0} FROM SmartViscaf__NameCard__c WHERE Id = :nameCardIdSet', new String[] { String.join(new List<String>(fields), ', ')});
        List<SmartViscaf__NameCard__c> nameCards = Database.query(query);
        // Map<Id, Lead> idMap = new Map<Id, Lead>();
        // Map<String, List<Lead>> emailListMap = new Map<String, List<Lead>>();
        // Map<String, List<Lead>> nameListMap = new Map<String, List<Lead>>();

        Map<Id,Map<Schema.SObjectType,List<SObject>>> sObjectList = buildCandidateList(nameCardIdSet, nameCards, searchType, searchContactType, searchRecordTypesMap);
        System.debug(sObjectList);
        Map<Schema.SObjectType, Map<Id, SObject>> sObjectTypemap = new Map<Schema.SObjectType, Map<Id, SObject>>();
        sObjectTypemap.put(Lead.sObjectType, new Map<Id, SObject>());
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
        // sObjectTypemap.put(Lead.sObjectType, new Map<Id, SObject>([Select Id, LastName, FirstName, Email, Name From Lead]));
        // setLeadMap(idMap, emailListMap, nameListMap, sObjectTypemap.get(Lead.sObjectType).values(), searchType);
        Map<Id, Map<String, SB_NameCardL_BulkRegistDTO.InputPlickListValue>> inputPlickListVMap = new Map<Id, Map<String, SB_NameCardL_BulkRegistDTO.InputPlickListValue>>();

        List<SB_NameCardL_BulkRegistDTO.CustomObject> dataList = new List<SB_NameCardL_BulkRegistDTO.CustomObject>();
        Boolean haveLead = false;
        Boolean haveAccount = false;
        for (SmartViscaf__NameCard__c nc : nameCards) {
            Map<String, SB_NameCardL_BulkRegistDTO.InputPlickListValue> inputPlickListMap = new  Map<String, SB_NameCardL_BulkRegistDTO.InputPlickListValue>();
            SB_NameCardL_BulkRegistDTO.InputPlickListValue inputPlickListV = new SB_NameCardL_BulkRegistDTO.InputPlickListValue();
            if (String.isBlank(nc.SmartViscaf__company_name__c) || String.isBlank(SmartViscaf.SB_NameCard_Util.getPersonName(nc).get('last_name'))) {
                inputPlickListV.plickListOptions.add(new SB_NameCardL_BulkRegistDTO.LabelValue(System.Label.SB_NCLD_DontRegister_CompanyNameRequired, 'none'));
                if (!SmartViscaf.SB_NameCard_Util.isEnablePersonAccount()) {
                  inputPlickListMap.put('Lead',inputPlickListV);
                }
                inputPlickListMap.put('Contact',inputPlickListV);
                if (SmartViscaf.SB_NameCard_Util.isEnablePersonAccount()
                  && String.isBlank(SmartViscaf.SB_NameCard_Util.getPersonName(nc).get('last_name'))) {
                  SB_NameCardL_BulkRegistDTO.InputPlickListValue inputPlickListV1 = new SB_NameCardL_BulkRegistDTO.InputPlickListValue();
                  inputPlickListV1.plickListOptions.add(new SB_NameCardL_BulkRegistDTO.LabelValue(System.Label.SB_NCLD_DontRegister_NameRequired, 'none'));
                  inputPlickListMap.put('Lead',inputPlickListV1);
                }
            }
            // setLeadRecord(idMap, emailListMap, nameListMap, nc, inputPlickListV.plickListOptions);
            // ncRec.setNameCardRecord(ncRec.nameCard, this.searchTypeContact, cIdMap, cEmailMap, cNameMap, cLastNameMap, aIdMap, aNameList);
            // ncRec.index = i;
            // if (ncRec.message != '') {
                    // message = ncRec.message;
            // }
            Map<Schema.SObjectType,List<SObject>> sObjectMap;
            inputPlickListV = new SB_NameCardL_BulkRegistDTO.InputPlickListValue();
            if (!inputPlickListMap.containsKey('Lead')
              || !inputPlickListMap.containsKey('Contact')) {
              sObjectMap = sObjectList.get(nc.Id);
            }
            if (!inputPlickListMap.containsKey('Lead')) {
              if (sObjectMap.containsKey(Lead.sObjecttype)) {
                List<sObject> sLeadList = sObjectMap.get(Lead.sObjecttype);
                for (sObject obj : sLeadList) {
                  Lead lead = (Lead)obj;
                  String label = getLabel(lead.Name, lead.Email);
                  inputPlickListV.plickListOptions.add(new SB_NameCardL_BulkRegistDTO.LabelValue(label, lead.Id));
                  inputPlickListV.plickListValueMap.put(lead.Id, label);
                  haveLead = true;
                }
              }

              if(Lead.sObjectType.getDescribe().isCreateable()) {
                String label = System.Label.SB_NCLD_Menu_NewLead;
                inputPlickListV.plickListOptions.add(new SB_NameCardL_BulkRegistDTO.LabelValue(label, 'new'));
                inputPlickListV.plickListValueMap.put('new', label);
              }
              inputPlickListV.plickListOptions.add(new SB_NameCardL_BulkRegistDTO.LabelValue(System.Label.SB_NCLD_Menu_NotToRegister, 'none'));
              inputPlickListV.plickListValueMap.put('none', System.Label.SB_NCLD_Menu_NotToRegister);

              inputPlickListMap.put('Lead',inputPlickListV);
            }

            if (!inputPlickListMap.containsKey('Contact')) {

              inputPlickListV = new SB_NameCardL_BulkRegistDTO.InputPlickListValue();
              if (sObjectMap.containsKey(Contact.sObjecttype)) {
                List<sObject> sContactList = sObjectMap.get(Contact.sObjecttype);
                for (sObject sobj : sContactList) {
                  Contact con = (Contact)sobj;
                  String label = con.Account.Name + '(' + getStr(con.Account.Site) + ')' + '/' + con.Name + '(' + getStr(con.Department) + '/' + getStr(con.Email) + ')';
                  String ids = '';
                  if (String.isNotBlank(con.AccountId)) {
                    ids = con.AccountId + ':' + con.Id;
                  }
                  else {
                    ids = ':' + con.Id;
                  }
                  inputPlickListV.plickListOptions.add(new SB_NameCardL_BulkRegistDTO.LabelValue(label, ids));
                  inputPlickListV.plickListValueMap.put(con.AccountId + ':' + con.Id, label);
                  haveAccount = true;
                }
              }
              if (sObjectMap.containsKey(Account.sObjecttype) && Contact.sObjectType.getDescribe().isCreateable()) {
                List<sObject> sAccountList = sObjectMap.get(Account.sObjecttype);
                for (sObject sobj : sAccountList) {
                  Account a = (Account)sobj;
                  String label = a.Name + '(' + getStr(a.Site) + ')' + '/' + String.format(System.Label.SB_NCLD_Label_CreateNewLeadDEV, new String[]{Contact.sObjecttype.getDescribe().getLabel()});
                  inputPlickListV.plickListOptions.add(new SB_NameCardL_BulkRegistDTO.LabelValue(label, a.Id + ':'));
                  inputPlickListV.plickListValueMap.put(a.Id + ':', label);
                  haveAccount = true;
                }
              }
              // String.valueOf(index), c.Account.Name + '(' + SB_NameCard_Util.getStr(c.Account.Site) + ')' + '/' + c.Name + '(' + SB_NameCard_Util.getStr(c.Department) + '/' + SB_NameCard_Util.getStr(c.Email) + ')')
              if(Contact.sObjectType.getDescribe().isCreateable() && Account.sObjectType.getDescribe().isCreateable()) {
                inputPlickListV.plickListOptions.add(new SB_NameCardL_BulkRegistDTO.LabelValue(System.Label.SB_NCLD_Menu_NewLead + '/' + System.Label.SB_NCLD_Menu_NewLead, 'new'));
                inputPlickListV.plickListValueMap.put('new', System.Label.SB_NCLD_Menu_NewLead);
              }
              inputPlickListV.plickListOptions.add(new SB_NameCardL_BulkRegistDTO.LabelValue(System.Label.SB_NCLD_Menu_NotToRegister, 'none'));
              inputPlickListV.plickListValueMap.put('none', System.Label.SB_NCLD_Menu_NotToRegister);

              inputPlickListMap.put('Contact',inputPlickListV);
            }
            inputPlickListVMap.put(nc.Id, inputPlickListMap);
        }
        if (message != '') {
                // testError = message;
                // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, message));
        }
        if (haveAccount && haveLead) {
          saveResult.otherMessage.put('showType', 'Both');
        }
        else if (haveAccount) {
          saveResult.otherMessage.put('showType', 'Contact');
        }
        else if (!haveLead) {
          saveResult.otherMessage.put('showType', SB_NameCard_LeadRegist.svConfig.defaultDisplayExistingLead() ? 'Lead' : 'Contact');
        }
        else {
          saveResult.otherMessage.put('showType', 'Lead');
        }
        saveResult.success = true;
        saveResult.data = inputPlickListVMap;
    } catch (Exception e) {
      System.debug(e.getStackTraceString());
      saveResult.success = false;
      saveResult.message = e.getMessage();
      // saveResult.message += e.getStackTraceString();
      // testError = e.getMessage();
      // ApexPages.addMessages(e);
    }
    return JSON.serialize(saveResult);
  }
  // nullの場合''に変換して返す
  public static String getStr(String s) {
    return (s == null) ? '' : s;
  }

  // 選択リスト表示のFormatに変更して返す
  public static String getLabel(String name, String email) {
    String label = String.isBlank(name) ? '' : name;
    label += String.isBlank(email) ? ' <>' : ' <'+email+'>';
    return label;
  }

  public static Map<Id,Map<Schema.SObjectType,List<SObject>>> buildCandidateList(Set<Id> ncList, List<SmartViscaf__NameCard__c> nameCardList,
                                                                                String searchType, String searchContactType,Map<String, List<String>> searchRecordTypesMap) {
    List<SB_NameCardL_RegistQueryOption> queryOptions = new List<SB_NameCardL_RegistQueryOption>();

    if (searchRecordTypesMap == null) {
      searchRecordTypesMap = new Map<String, List<String>>();
    }

    SB_NameCardL_RegistQueryOption queryOption = getQueryOption(Lead.sObjecttype);
    if (searchType == String.valueOf(SEARCHTYPE_NAME)) {
      queryOption.queryLastName = true;
      queryOption.queryFirstName = true;
      queryOption.queryEMail = false;
    }
    else {
      queryOption.queryLastName = false;
      queryOption.queryFirstName = false;
      queryOption.queryEMail = true;
    }
    SB_NameCardL_RegistQueryOption accountQueryOption = getQueryOption(Account.sObjecttype);
    SB_NameCardL_RegistQueryOption contactQueryOption =  getQueryOption(Contact.sObjecttype);

    System.debug(searchRecordTypesMap);
    // リードMap
    if (searchRecordTypesMap.containsKey('Lead')) {
      // System.debug(searchRecordTypesMap.get('Lead'));
      List<Id> leadRecordTypeList = (List<Id>)searchRecordTypesMap.get('Lead');
      if (leadRecordTypeList.size() > 0) {
        Set<Id> leadRecord = new Set<Id>();
        leadRecord.addAll(leadRecordTypeList);
        System.debug('leadRecordTypeList = ' + leadRecordTypeList);
        queryOption.setRectypeIds(leadRecord);
      }
    }

    if (searchRecordTypesMap.containsKey('Account')) {
      List<Id> accountRecordTypeList = searchRecordTypesMap.get('Account');
      if (accountRecordTypeList.size() > 0) {
        Set<Id> accountRecord = new Set<Id>();
        accountRecord.addAll(accountRecordTypeList);
        System.debug('accountRecord = ' + accountRecord);
        accountQueryOption.setRectypeIds(accountRecord);
      }
    }

    if (searchRecordTypesMap.containsKey('Contact')) {
      List<Id> contactRecordTypeList = searchRecordTypesMap.get('Contact');
      if (contactRecordTypeList.size() > 0) {
        Set<Id> contactRecord = new Set<Id>();
        contactRecord.addAll(contactRecordTypeList);
        System.debug('contactRecord = ' + contactRecord);
        contactQueryOption.setRectypeIds(contactRecord);
      }
    }

    // if (String.isNotBlank(searchRecordTypes)) {
    //   Set<Id> recordTypeSet =  new Set<Id>((List<Id>)new List<String>(searchRecordTypes.split(',')));
    //   System.debug(recordTypeSet.size());
    //   System.debug(recordTypeSet);
    //   queryOption.setRectypeIds(recordTypeSet);
    //   accountQueryOption.setRectypeIds(recordTypeSet);
    //   contactQueryOption.setRectypeIds(recordTypeSet);
    // }

    accountQueryOption.queryCompany = true;
    accountQueryOption.deptRule = SB_NameCardL_RegistQueryOption.DeptMatcing.PartialMatch;
    contactQueryOption.queryCompany = true;
    // accountQueryOption.companyRule = SB_NameCardL_RegistQueryOption.CompanyMatcing.PartialMatch;
    Integer searchContactTypeInt;
    if (String.isNotBlank(searchContactType)) {
      searchContactTypeInt = Integer.valueOf(searchContactType);
    }
    else {
      searchContactTypeInt = Integer.valueOf(SEARCHTYPE_ACNAME);
    }
    System.debug(searchContactTypeInt);
    System.debug(searchContactType);
    if (searchContactTypeInt == SEARCHTYPE_ACNAME) {

    }
    else if (searchContactTypeInt == SEARCHTYPE_ACNAMESITE) {
      accountQueryOption.queryDept = true;
      contactQueryOption.queryDept = true;
    }
    else if (searchContactTypeInt == SEARCHTYPE_ACNAMESITESTATE) {
      accountQueryOption.queryDept = true;
      accountQueryOption.queryState = true;
      contactQueryOption.queryDept = true;
      contactQueryOption.queryState = true;
    }
    else if (searchContactTypeInt == SEARCHTYPE_NAMECITY) {
      accountQueryOption.queryDept = true;
      accountQueryOption.queryCity = true;
      contactQueryOption.queryDept = true;
      contactQueryOption.queryCity = true;
    }
    else if (searchContactTypeInt == SEARCHTYPE_NAMECODE) {
      accountQueryOption.queryDept = true;
      accountQueryOption.queryZip = true;
      contactQueryOption.queryDept = true;
      contactQueryOption.queryZip = true;
    }

    queryOptions.add(queryOption);
    queryOptions.add(accountQueryOption);
    queryOptions.add(contactQueryOption);
    System.assert(!queryOptions.isEmpty());
    // クエリする対象のオブエジェクト ごとに　SB_NameCardL_RegistQueryOption を作って、検索の条件を指定して渡します。
    picker.init(queryOptions);
    //picker.setQueryStrategys(qss);
    SB_NameCardL_RegistQueryExecutor qExecutor = SB_NameCardL_RegistQueryExecutor.getInstance();
    qExecutor.init(ncList);      // init は オーバーロード されてて、 個別の場合は、これか、 Id をt１つ渡すメソッドをつかって、一括の場合は 複数を渡すのを使います。
    // picker の create もオーバーロード されてて、個別ならこれとかで、一括の場合は Map<Id, List<SObject>> create(Set<Id> cardIds); を名刺レコードIDと 一致するSObjectのリストのマップを返すのを使います。
    Map<Id,Map<Schema.SObjectType, List<SObject>>> otype2objs = picker.create(ncList);
    System.debug(otype2objs);
    return otype2objs;
  }

  // 保存
  // SV_DEV-762 名刺オブジェクトの編集権限がない場合にリードに登録の処理が終了しない。
  @RemoteAction
  @AuraEnabled
  public static String saveLead(String customObjects, String inputVStr,String registType) {
    // saveOK = true;
    Savepoint sp;
    System.debug('start save');
    String message = '';
    SB_NameCardL_BulkRegistDTO.SaveResult saveResult = new SB_NameCardL_BulkRegistDTO.SaveResult();
    List<SB_NameCardL_BulkRegistDTO.CustomObject> dataList = (List<SB_NameCardL_BulkRegistDTO.CustomObject>)System.JSON.deserializeStrict(customObjects, List<SB_NameCardL_BulkRegistDTO.CustomObject> .Class);
    try {
        SB_NameCardL_BulkRegistDTO.InputValue inputV = (SB_NameCardL_BulkRegistDTO.InputValue)System.JSON.deserializeStrict(inputVStr, SB_NameCardL_BulkRegistDTO.InputValue .Class);
        if (String.isNotBlank(inputV.ownerId)) {
          Id inOwnerId = inputV.ownerId;
          if (inOwnerId.getSobjectType() == QueueSobject.getSobjectType()) {
            List<QueueSobject> qss = [SELECT Id,
                                             QueueId
                                        FROM QueueSobject
                                      WHERE Id = :inOwnerId];
            if (qss.isEmpty()) {
              throw new SB_NameCard_LeadRegist.LeadRegistException(System.Label.SB_NCLD_Msg_CanNotUseInActiveQueue);
            }
            inputV.ownerId = qss[0].QueueId;
          }
        }
        String ownerId = inputV.ownerId;
        String accountOwnerId = inputV.accountOwnerId;
        Boolean useNameCardOwner = inputV.useNameCardOwner;
        Boolean useNameCardAccountOwner = inputV.useNameCardAccountOwner;
        String campaignId = inputV.campaignId;
        String campaignStatus = inputV.campaignStatusPlick.selectValue;
        Boolean leadOverwrite = inputV.inputRegistOverWritValues[0].overWriteCheck.checked;
        Boolean accountOverwrite = inputV.inputRegistOverWritValues[1].overWriteCheck.checked;
        Boolean contactOverwrite = inputV.inputRegistOverWritValues[2].overWriteCheck.checked;
        // String leadRecordTypeId =  inputV.searchRecordTypes;
        String leadRecordTypeId = inputV.InputPlickListValues[0].selectValue;
        String accountRecordTypeId = inputV.InputPlickListValues[1].selectValue;
        String contactRecordTypeId = inputV.InputPlickListValues[2].selectValue;
        Boolean hasError = false;
        // for (NameCardRecord ncRec : this.nameCardRecordList) ncRec.hasError = false;
        sp = Database.setSavepoint();
        String str = '';

        List<SB_NameCardL_RegistHelper.RegistTarget> tars = new List<SB_NameCardL_RegistHelper.RegistTarget>();
        Boolean haveNew = false;
        Boolean haveAccountNew = false;
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

        Id oIdAccount;
        if (!useNameCardAccountOwner && String.isNotBlank(accountOwnerId)) {
          oIdAccount = accountOwnerId;
        }
        for (Integer i = 0; i < dataList.size(); i ++) {
          Map<String, SB_NameCardL_BulkRegistDTO.CustomField> cObjectMap = dataList[i].cObjectMap;
          if (registType != 'Contact') {
            String leadId = cObjectMap.get('Lead').value;
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
              System.debug(cObjectMap.get('ToDo'));
              SB_NameCardL_RegistHelper.RegistTarget tar = new SB_NameCardL_RegistHelper.RegistTarget(SB_NameCardL_RegistHelper.ProcType.LEAD,
                                                                                                      dataList[i].id,
                                                                                                      null,
                                                                                                      null,
                                                                                                      leadId == 'new' ? null : leadId,
                                                                                                      cObjectMap.get('ToDo').checked,
                                                                                                      null);
              if (String.isNotBlank(campaignId) && leadId == 'new') {
                tar.setLeadCampaign(campaignId, campaignStatus);
              }
              tars.add(tar);
            }
          }
          if (registType != 'Lead') {
            String accId = cObjectMap.get('Contact').value;
            Boolean registTodo = cObjectMap.get('ToDo').checked;
            Id nameCardId = cObjectMap.get('Id').value;
            Id nameCardOwnerId = cObjectMap.get('Id').value;
            if (accId != 'none') {
              Id accountId;
              Id contactId;
              if (accId != 'new') {
                List<String> ids = accId.split(':');
                if (accId.startsWith(':')) {
                  contactId = ids[1];
                }
                else if (accId.endsWith(':')) {
                  accountId = ids[0];
                }
                else {
                  accountId = ids[0];
                  contactId = ids[1];
                }
              }
              if (!haveAccountNew) {
                haveAccountNew = String.isBlank(accountId) || String.isBlank(contactId);
                if (haveAccountNew) {
                  if (!useNameCardAccountOwner && String.isBlank(accountOwnerId)) {
                     String noOwnerIdErrorMessage;
                    if (String.isBlank(accountId)) {
                      noOwnerIdErrorMessage = String.format(System.Label.SB_NCLD_Msg_SpecifyOwnerWhenCreateLeadDEV, new String[] {ACCOUNTLABEL});
                    }
                    else {
                      noOwnerIdErrorMessage = String.format(System.Label.SB_NCLD_Msg_SpecifyOwnerWhenCreateLeadDEV, new String[] {CONTACTLABEL});
                    }
                    throw new SB_NameCard_LeadRegist.LeadRegistException(noOwnerIdErrorMessage);
                  }
                }
              }
              SB_NameCardL_RegistHelper.RegistTarget tar = new SB_NameCardL_RegistHelper.RegistTarget(SB_NameCardL_RegistHelper.ProcType.ACCOUNT,
                                                                                                      nameCardId,
                                                                                                      accountId,
                                                                                                      contactId,
                                                                                                      null,
                                                                                                      registTodo,
                                                                                                      null);
              tars.add(tar);
              }
            }

          j ++;
        }
        SB_NameCardL_RegistHelper.RegistParam leadRP;
        SB_NameCardL_RegistHelper.RegistParam accountRP;
        SB_NameCardL_RegistHelper.RegistParam contactRP;
        if (registType != 'Contact') {
          leadRP = new SB_NameCardL_RegistHelper.RegistParam('Lead', leadOverwrite, leadRecordTypeId,oId,false);
        }

        if (registType != 'Lead') {
          accountRP = new SB_NameCardL_RegistHelper.RegistParam('Account', accountOverwrite, accountRecordTypeId,oIdAccount,false);
          contactRP = new SB_NameCardL_RegistHelper.RegistParam('Contact', contactOverwrite, contactRecordTypeId,oIdAccount,false);
        }
        SB_NameCardL_RegistHelper.TodoParam todoRP = new SB_NameCardL_RegistHelper.TodoParam(SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RegistToDoSubject__c,null,null,null);

        SB_NameCardL_RegistHelper.RegistRequest re = new SB_NameCardL_RegistHelper.RegistRequest(tars, accountRP, contactRP, leadRP, todoRP);
        Map<Id, String> ownerErrorMap = SB_NameCardL_RegistOwenrCheckHelper.doCheck(re);
        System.debug(ownerErrorMap);
        if (!ownerErrorMap.isEmpty()) {
          for (Integer i = 0; i<dataList.size(); i++) {
            if (ownerErrorMap.containsKey(dataList[i].id)) {
              dataList[i].haveError = true;
              saveResult.dataError = true;
              // ToDo
              str += String.format('{0}' + System.Label.SB_NC_Line + ': {1}', new String[]{ ''+(i+1),ownerErrorMap.get(dataList[i].id) + '<br/>'});
            } else{
              dataList[i].haveError = false;
            }
          }
          throw new SB_NameCard_LeadRegist.LeadRegistException(str);
        }
        //doRegist内既にrollbackしていますので、ここは二度目はしません
        SB_NameCardL_RegistHelper.RegistResponse result = SB_NameCardL_RegistHelper.doRegist(re);

        if (result.success == false) {
          str = '<br/>';
          // this.hasError = true;
          if (result.dbErrors!=null) {
            for (Integer i = 0; i<dataList.size(); i++) {
              if (result.dbErrors.containsKey(dataList[i].id)) {
                dataList[i].haveError = true;
                saveResult.dataError = true;
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
        saveResult.data = dataList;
    }
    catch (Exception e) {
        if (sp != null) Database.rollback(sp);
        // this.hasError = true;
        // saveOK = false;
        System.debug(e.getMessage());
        // message += e.getStackTraceString();
        message += e.getMessage();
        saveResult.errorMessage = message;
        saveResult.testClassMessage = e.getStackTraceString() + message;
        saveResult.success = false;
        saveResult.data = dataList;
        // testError = e.getMessage();
        // ApexPages.addMessages(e);
    }
    return JSON.serialize(saveResult);
    //return pageRef;
  }
  // SB_NameCardL_RegistQueryOptionを初期化して取得
  private static SB_NameCardL_RegistQueryOption getQueryOption(sObjectType type) {
    SB_NameCardL_RegistQueryOption ot = new SB_NameCardL_RegistQueryOption(type);
    ot.queryState = false;
    ot.queryCity = false;
    ot.queryStreet = false;
    ot.queryZip = false;
    ot.queryPhone = false;
    ot.queryCompany = false;
    ot.queryDept = false;
    ot.queryUrl = false;
    ot.queryLastName = false;
    ot.queryFirstName = false;
    ot.queryEMail = false;
    ot.queryTitle = false;
    ot.queryMobile = false;
    return ot;
  }

  // Lightning標準と同じ順で表示
  //レコードタイプを取得
  public static List<RecordTypeInfo> getRecordType(SObjectType otype){
    List<Schema.RecordTypeInfo> rs =  otype.getDescribe().getRecordTypeInfos();
    List<RecordTypeInfo> recordtypes = new List<RecordTypeInfo>();
    for (RecordTypeInfo r : rs) {
      if (r.isAvailable()) {
        if (r.isDefaultRecordTypeMapping() && recordtypes.size() > 0) {
          recordtypes.add(0, r);
        }
        else {
          recordtypes.add(r);
        }
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