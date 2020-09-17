/*
 * SB_NC_AccountBulkRgsLcController
 * LEX 取引先・取引先責任者一括登録画面 LEXコンポーネントのコントローラ
 *
 * (c) 2019 Sunbridge Inc.
 *
 *  @author K.Yoshida
 *  @Version 2.2  2019.02.XX SV_DEV-1558 LEX 取引先登録 一括画面をLXパッケージ同様のLC化で追加
 *  @Version 2.4  2019.09.xx SV_DEV-2047 LEX 取引先登録 一括：Todo任命先が「名刺の所有者」で、有効なユーザが所有者の名刺レコードで、上書き登録した場合にユーザが無効エラーメッセージが表示される
 *  @Version 2.5  2020.01.XX SV_DEV-2367 Classic /LEX 各登録画面（ 個別・一括） : Todo件名がNULL値の場合での件名の表示・登録結果が異なる
 */
public with sharing class SB_NC_AccountBulkRgsLcController {
  private static final String ACCOUNTLABEL = Account.sObjectType.getDescribe().getLabel();
  private static final String CONTACTLABEL = Contact.sObjectType.getDescribe().getLabel();

  private static final Integer SEARCHTYPE_EMAIL = 1;
  private static final Integer SEARCHTYPE_NAME  = 2;
  private static final Integer SEARCHTYPE_ACNAME = 3;
  private static final Integer SEARCHTYPE_ACNAMESITE  = 4;
  private static final Integer SEARCHTYPE_ACNAMESITESTATE = 5;
  private static final Integer SEARCHTYPE_NAMECITY  = 6;
  private static final Integer SEARCHTYPE_NAMECODE  = 7;

  public class SB_NC_AccountBulkRgsLcControllerException extends Exception {}
    
  @RemoteAction
  @AuraEnabled
  // 全てのデータここで取得
  public static String getAllData(String recordIds, String fieldListStr, String searchType, String searchContactType, String recordTypesMapstr, String searchConditionCompanyMatcing) {
    SB_NC_AccountBulkRegistDTO.SaveResult saveResult = new SB_NC_AccountBulkRegistDTO.SaveResult();
    try{
      // SV_DEV-1856 LEX 取引先登録 一括：参照権限がない場合に登録先候補がでないようにしてほしい。
      if (!Account.sObjectType.getDescribe().isAccessible() || !Contact.sObjectType.getDescribe().isAccessible()) {
        throw new SB_NC_AccountBulkRgsLcControllerException(System.Label.SB_NC_MSG_INSUFFICIENT_ACCESS);
      }

      List<SB_NC_AccountBulkRegistDTO.DataTableColumnField> fieldList;
      NameCardBasicSetting__c basicSetting = SB_NameCard_BasicSetting.getNameCardBasicSetting();
      Map<String, List<SB_NC_AccountBulkRegistDTO.DataTableColumnField>> fieldMap = (Map<String, List<SB_NC_AccountBulkRegistDTO.DataTableColumnField>> )System.JSON.deserializeStrict(getFieldList(), Map<String, List<SB_NC_AccountBulkRegistDTO.DataTableColumnField>> .Class);
      fieldList = fieldMap.get('Contact');
      List<String> recordIdList = recordIds.split(',');
      System.debug('recordIds' + recordIds);

      Set<String> fieldsSet = SB_NC_RegistQueryExecutor.getNameCardFields();
      String query = String.format('SELECT {0} FROM NameCard__c WHERE Id = :recordIdList', new String[] { String.join(new List<String>(fieldsSet), ', ')});
      List<NameCard__c> ncs = Database.query(query);
      System.debug('ncs size' + ncs.size());
      System.debug('fieldList : ' + fieldList);
      
      Map<String, Schema.SObjectField> fields = NameCard__c.sObjectType.getDescribe().fields.getMap();
      List<SB_NC_AccountBulkRegistDTO.CustomObject> dataList = new List<SB_NC_AccountBulkRegistDTO.CustomObject>();
      Map<Id, SB_NC_AccountBulkRegistDTO.CustomObject> nameCardObjMap = new Map<Id, SB_NC_AccountBulkRegistDTO.CustomObject>();
      for (NameCard__c sobj : ncs) {
        SB_NC_AccountBulkRegistDTO.CustomObject co = new SB_NC_AccountBulkRegistDTO.CustomObject();
        for (SB_NC_AccountBulkRegistDTO.DataTableColumnField field : fieldList) {
          SB_NC_AccountBulkRegistDTO.CustomField cf = new SB_NC_AccountBulkRegistDTO.CustomField();
          if (String.isNotBlank(field.fieldName) && fields.containsKey(field.fieldName)) {
            cf.label = (String)sobj.get(field.fieldName);
            cf.value = (String)sobj.get(field.fieldName);
          }
          if (field.fieldName == 'ToDo' && String.isBlank(fieldListStr) || fieldListStr == '[]') {
            cf.checked = !basicSetting.RegistNoToDo__c;
          }

          cf.type = field.type;
          cf.input = field.input;
          cf.fieldName = field.fieldName;
          co.cObjectMap.put(cf.fieldName, cf);
        }
        // 名刺所有者項目
        SB_NC_AccountBulkRegistDTO.CustomField cf = new SB_NC_AccountBulkRegistDTO.CustomField(sobj, 'OwnerId', 'string', false, null);
        co.cObjectMap.put('OwnerId', cf);
        // 名刺Id項目
        SB_NC_AccountBulkRegistDTO.CustomField cfId = new SB_NC_AccountBulkRegistDTO.CustomField(sobj, 'Id', 'string', false, null);
        co.cObjectMap.put('Id', cfId);
        // 名刺会社名項目
        SB_NC_AccountBulkRegistDTO.CustomField cfCom = new SB_NC_AccountBulkRegistDTO.CustomField(sobj, 'company_name__c', 'string', false, null);
        if (String.isNotBlank(cfCom.label)) {
          co.cObjectMap.put('company_name__c', cfCom);
        }

        SB_NC_AccountBulkRegistDTO.CustomField cfTitle = new SB_NC_AccountBulkRegistDTO.CustomField(sobj, 'title_name__c', 'string', false, null);
        if (String.isNotBlank(cftitle.label)) {
          co.cObjectMap.put('title_name__c', cftitle);
        }

        SB_NC_AccountBulkRegistDTO.CustomField cfDiv = new SB_NC_AccountBulkRegistDTO.CustomField(sobj, 'division__c', 'string', false, null);
        if (String.isNotBlank(cfDiv.label)) {
          co.cObjectMap.put('division__c', cfDiv);
        }

        SB_NC_AccountBulkRegistDTO.CustomField cfName = new SB_NC_AccountBulkRegistDTO.CustomField(sobj, 'Name', 'url', false, string.format('/one/one.app#/sObject/{0}/view',new String[]{(Id)sobj.Id}));
        co.cObjectMap.put('Name', cfName);

        SB_NC_AccountBulkRegistDTO.CustomField cfAdd = new SB_NC_AccountBulkRegistDTO.CustomField();
        String address1 = String.isBlank((String)sobj.zip_code__c) ? '' : (String)sobj.zip_code__c;
        String address2 = String.isBlank((String)sobj.address_pref__c) ? '' : (String)sobj.address_pref__c;
        String address3 = String.isBlank((String)sobj.address__c) ? '' : (String)sobj.address__c;
        String address4 = String.isBlank((String)sobj.address_bld__c) ? '' : (String)sobj.address_bld__c;
        String address5 = String.isBlank((String)sobj.address_eng__c) ? '' : (String)sobj.address_eng__c;
        cfAdd.label = address1 + address2 + address3 + address4 + address5;
        cfAdd.value = address1 + address2 + address3 + address4 + address5;
        if (String.isNotBlank(cfAdd.label)) {
          co.cObjectMap.put('Address', cfAdd);
        }

        SB_NC_AccountBulkRegistDTO.CustomField cfMobil = new SB_NC_AccountBulkRegistDTO.CustomField(sobj, 'mobile__c', 'string', false, null);
        if (String.isNotBlank(cfMobil.label)) {
          co.cObjectMap.put('mobile__c', cfMobil);
        }


        SB_NC_AccountBulkRegistDTO.CustomField cfEmail = new SB_NC_AccountBulkRegistDTO.CustomField(sobj, 'email__c', 'string', false, null);
        if (String.isNotBlank(cfEmail.label)) {
          co.cObjectMap.put('email__c', cfEmail);
        }

        SB_NC_AccountBulkRegistDTO.CustomField cfAddpref = new SB_NC_AccountBulkRegistDTO.CustomField(sobj, 'address_pref__c', 'string', false, null);
        if (String.isNotBlank(cfAddpref.label)) {
          co.cObjectMap.put('address_pref__c', cfAddpref);
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
      searchAllData(saveResult, recordIds, nameCardObjMap, searchType, searchContactType, recordTypesMap, searchConditionCompanyMatcing);
      if (saveResult.success == false) {
        return JSON.serialize(saveResult);
      }
      //dto.setDataList(ncs);
      System.debug(dataList);
      saveResult.success = true;
      saveResult.data = dataList;
      System.debug(Limits.getHeapSize());
      System.debug(Limits.getLimitHeapSize());
      if (Limits.getHeapSize() > Limits.getLimitHeapSize() * 0.9) {
        saveResult.data = null;
        throw new SB_NC_AccountBulkRgsLcControllerException(System.Label.SB_NC_Msg_ChooseLessBusinessCards);
      }
    }
    catch (Exception e) {
      saveResult.success = false;
      saveResult.message = e.getMessage();
    }
    return JSON.serialize(saveResult);
  }


  private static String searchAllData(SB_NC_AccountBulkRegistDTO.SaveResult saveResult, String nameCardIds, Map<Id, SB_NC_AccountBulkRegistDTO.CustomObject> nameCardObjMap, String searchType, String searchContactType, Map<String, List<String>> searchRecordTypesMap,String searchConditionCompanyMatcing) {
    String message = '';
    if (saveResult == null) {
        saveResult = new SB_NC_AccountBulkRegistDTO.SaveResult();
    }
    try {
        // this.hasError = false;
        System.debug(nameCardIds);
        if (String.isBlank(nameCardIds)) {
          return null;
        }
        Set<Id> nameCardIdSet = new Set<Id>((List<Id>)new List<String>(nameCardIds.split(',')));
        Set<String> fields = SB_NC_RegistQueryExecutor.getNameCardFields();
        String query = String.format('SELECT {0} FROM NameCard__c WHERE Id = :nameCardIdSet', new String[] { String.join(new List<String>(fields), ', ')});
        List<NameCard__c> nameCards = Database.query(query);

        Map<Id,Map<Schema.SObjectType,List<SObject>>> sObjectList = buildCandidateList(nameCardIdSet, nameCards, searchType, searchContactType, searchRecordTypesMap, searchConditionCompanyMatcing);
        System.debug(sObjectList);
        Map<Schema.SObjectType, Map<Id, SObject>> sObjectTypemap = new Map<Schema.SObjectType, Map<Id, SObject>>();
        Map<Id, Map<String, SB_NC_AccountBulkRegistDTO.InputPickListValue>> inputPickListVMap = new Map<Id, Map<String, SB_NC_AccountBulkRegistDTO.InputPickListValue>>();

        List<SB_NC_AccountBulkRegistDTO.CustomObject> dataList = new List<SB_NC_AccountBulkRegistDTO.CustomObject>();
        Boolean haveAccount = false;
        for (NameCard__c nc : nameCards) {
            Map<String, SB_NC_AccountBulkRegistDTO.InputPickListValue> inputPickListMap = new  Map<String, SB_NC_AccountBulkRegistDTO.InputPickListValue>();
            SB_NC_AccountBulkRegistDTO.InputPickListValue inputPickListV = new SB_NC_AccountBulkRegistDTO.InputPickListValue();
            //String leadId = 'none';
            //String accountId = 'none';
            String accountId = 'new';
            if (String.isBlank(nc.company_name__c) || String.isBlank(SB_NameCard_Util.getPersonName(nc).get('last_name'))) {
                inputPickListV.pickListOptions.add(new SB_NC_AccountBulkRegistDTO.LabelValue(System.Label.SB_NC_DontRegister_CompanyNameRequired, 'none'));
                inputPickListMap.put('Contact',inputPickListV);
            }
            Map<Schema.SObjectType,List<SObject>> sObjectMap;
            inputPickListV = new SB_NC_AccountBulkRegistDTO.InputPickListValue();
            sObjectMap = sObjectList.get(nc.Id);

            if (!inputPickListMap.containsKey('Contact')) {
              inputPickListV = new SB_NC_AccountBulkRegistDTO.InputPickListValue();
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
                  inputPickListV.pickListOptions.add(new SB_NC_AccountBulkRegistDTO.LabelValue(label, ids));
                  inputPickListV.pickListValueMap.put(con.AccountId + ':' + con.Id, label);
                  haveAccount = true;
                  //if (accountId == 'none') {
                  if (accountId == 'new') {
                    accountId = ids;
                    //leadId = 'none';
                  }
                }
              }
              if (sObjectMap.containsKey(Account.sObjecttype) && Contact.sObjectType.getDescribe().isCreateable()) {
                List<sObject> sAccountList = sObjectMap.get(Account.sObjecttype);
                for (sObject sobj : sAccountList) {
                  Account a = (Account)sobj;
                  String label = a.Name + '(' + getStr(a.Site) + ')' + '/' + String.format(System.Label.SB_NC_Label_CreateNewRecordDEV, new String[]{Contact.sObjecttype.getDescribe().getLabel()});
                  inputPickListV.pickListOptions.add(new SB_NC_AccountBulkRegistDTO.LabelValue(label, a.Id + ':'));
                  inputPickListV.pickListValueMap.put(a.Id + ':', label);
                  haveAccount = true;
                  //if (accountId == 'none') {
                  if (accountId == 'new') {
                    accountId = a.Id + ':';
                    //leadId = 'none';
                  }
                }
              }
              if(Contact.sObjectType.getDescribe().isCreateable() && Account.sObjectType.getDescribe().isCreateable()) {
                //inputPickListV.pickListOptions.add(new SB_NC_AccountBulkRegistDTO.LabelValue(System.Label.SB_NC_Create + '/' + System.Label.SB_NC_Create, 'new'));
                inputPickListV.pickListOptions.add(
                  new SB_NC_AccountBulkRegistDTO.LabelValue(
                    String.format(System.Label.SB_NC_Label_CreateNewRecordDEV, new String[] {ACCOUNTLABEL}) + '/' + 
                    String.format(System.Label.SB_NC_Label_CreateNewRecordDEV, new String[] {CONTACTLABEL}), 'new'));
                inputPickListV.pickListValueMap.put('new', 
                    String.format(System.Label.SB_NC_Label_CreateNewRecordDEV, new String[] {ACCOUNTLABEL}) + '/' + 
                    String.format(System.Label.SB_NC_Label_CreateNewRecordDEV, new String[] {CONTACTLABEL})
                );
              }

              inputPickListV.pickListOptions.add(new SB_NC_AccountBulkRegistDTO.LabelValue(System.Label.SB_NC_DontRegister, 'none'));
              inputPickListV.pickListValueMap.put('none', System.Label.SB_NC_DontRegister);
              inputPickListMap.put('Contact',inputPickListV);
            }


            nameCardObjMap.get(nc.Id).combobox = inputPickListMap;
            //nameCardObjMap.get(nc.Id).cObjectMap.get('Lead').value = leadId;
            nameCardObjMap.get(nc.Id).cObjectMap.get('Contact').value = accountId;
            // inputPickListVMap.put(nc.Id, inputPickListMap);
        }
        //if (haveAccount) {
          //saveResult.otherMessage.put('showType', 'Contact');
        //}
        saveResult.success = true;
        saveResult.data = inputPickListVMap;
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

  // 画面表示項目ここで設定
  @RemoteAction
  @AuraEnabled
  public static String getFieldList() {
    Map<String, List<SB_NC_AccountBulkRegistDTO.DataTableColumnField>> fieldMap = new Map<String, List<SB_NC_AccountBulkRegistDTO.DataTableColumnField>>();
    List<SB_NC_AccountBulkRegistDTO.DataTableColumnField> fieldList = new List<SB_NC_AccountBulkRegistDTO.DataTableColumnField>();
    SB_NC_AccountBulkRegistDTO.DataTableColumnField f2 = new SB_NC_AccountBulkRegistDTO.DataTableColumnField(String.format(System.Label.SB_NC_Label_AccountANDContact, new String[] {ACCOUNTLABEL, SB_NameCard_Util.getDesirableLabel('Account','Site'), CONTACTLABEL, Contact.Department.getDescribe().getLabel(), Contact.Email.getDescribe().getLabel()}),
                                           'Contact',
                                           'pickList',
                                           true);
    f2.eventName = 'cleanLeadPicklist';
    fieldList.add(f2);
    f2 = new SB_NC_AccountBulkRegistDTO.DataTableColumnField(System.Label.SB_NC_Label_ToDoRegistration,
                                           'ToDo',
                                           'checkbox',
                                           true);
    f2.checkAll = true;
    f2.checkAllCheck = !SB_NameCard_BasicSetting.getNameCardBasicSetting().RegistNoToDo__c;
    fieldList.add(f2);
    fieldMap.put('Contact', fieldList);
    
    return JSON.serialize(fieldMap);
  }    

  @RemoteAction
  @AuraEnabled
  // 画面表示用ラベルに関する内容ここで取得
  public static String getTitleValue() {
    SB_NC_AccountBulkRegistDTO.TitleValue titleV = new SB_NC_AccountBulkRegistDTO.TitleValue();
    titleV.titleName = String.format(System.Label.SB_NC_RegisterAllToAccountAndContactDEV, new String[]{ACCOUNTLABEL, CONTACTLABEL});
    titleV.iconName = 'standard:account';
    titleV.iconSize = 'large';
    titleV.closeValue = System.Label.SB_NC_Label_Close;
    titleV.saveValue = System.Label.SB_NC_Label_Save;
    return JSON.serialize(titleV);
  }

  @RemoteAction
  @AuraEnabled
  // 画面入力内容をここで取得
  public static String getInputValue() {
    NameCardBasicSetting__c basicSetting = SB_NameCard_BasicSetting.getNameCardBasicSetting();
    SB_NC_AccountBulkRegistDTO.InputValue inv = new SB_NC_AccountBulkRegistDTO.InputValue();
    inv.ownerLabel = '所有者';
    inv.useNameCardAccountOwnerLabel = System.Label.SB_NC_NameCardOwner;
    inv.accountOwnerLabel = System.Label.SB_NC_Label_Owner;
    inv.overWriteLabel = System.Label.SB_NC_Text_SpecifiedWhenOverWrite;
    inv.newSectionLabel = System.Label.SB_NC_Text_SpecifiedWhenCreateNew;
    inv.useNameCardOwner = true;
    inv.useNameCardAccountOwner = true;

    // 取引先上書き
    SB_NC_AccountBulkRegistDTO.InputRegistOverWritValue inputO = new SB_NC_AccountBulkRegistDTO.InputRegistOverWritValue();
    SB_NC_AccountBulkRegistDTO.LabelValueCheck lc = new SB_NC_AccountBulkRegistDTO.LabelValueCheck();
    lc.label = String.format(System.Label.SB_NC_UpdateforAccountDEV, new String[] {ACCOUNTLABEL});
    lc.disabled = inv.accountAuthority.isUpdateable == false;
    lc.checked = basicSetting.RegistAccountNotOverWrite__c == false && !lc.disabled;
    inputO.overWriteCheck = lc;
    inputO.overId = 'Account';
    inputO.show = false;
    inputO.canShow = basicSetting.RegistDispAccountOverWriteCheckbox__c;
    inv.inputRegistOverWritValues.add(inputO);
    // 取引先責任者上書き
    inputO = new SB_NC_AccountBulkRegistDTO.InputRegistOverWritValue();
    lc = new SB_NC_AccountBulkRegistDTO.LabelValueCheck();
    lc.label = String.format(System.Label.SB_NC_UpdateforContactDEV, new String[] {CONTACTLABEL});
    lc.disabled = inv.contactAuthority.isUpdateable == false;
    lc.checked = basicSetting.RegistContactNotOverWrite__c == false && !lc.disabled;
    inputO.overWriteCheck = lc;
    inputO.overId = 'Contact';
    inputO.show = false;
    inputO.canShow = basicSetting.RegistDispContactOverWriteCheckbox__c;
    inv.inputRegistOverWritValues.add(inputO);

    SB_NC_AccountBulkRegistDTO.SearchCondition scc0 = new SB_NC_AccountBulkRegistDTO.SearchCondition(CONTACTLABEL, Contact.sObjecttype.getDescribe().getLabel(), '', '');
    scc0.groupName = 'Contact';
    scc0.disabled = true;
    scc0.className = 'disContact';
    //inv.searchConditions.add(scc0);

    String accountName = Account.Name.getDescribe().getLabel();
    String accountSite = System.Label.SB_NC_Label_Site;
    String andLabel = System.Label.SB_NC_AND;

    SB_NC_AccountBulkRegistDTO.SearchCondition scc1 = new SB_NC_AccountBulkRegistDTO.SearchCondition(accountName, String.valueOf(SEARCHTYPE_ACNAME), 'utility:company', '');
    scc1.groupName = 'Contact';
    inv.searchConditions.add(scc1);
    SB_NC_AccountBulkRegistDTO.SearchCondition scc2 = new SB_NC_AccountBulkRegistDTO.SearchCondition(String.format(System.Label.SB_NC_Text_A_AND_B, new String[] {accountName, accountSite}), String.valueOf(SEARCHTYPE_ACNAMESITE), 'utility:hierarchy', '');
    scc2.groupName = 'Contact';
    inv.searchConditions.add(scc2);
    SB_NC_AccountBulkRegistDTO.SearchCondition scc3 = new SB_NC_AccountBulkRegistDTO.SearchCondition(String.format(System.Label.SB_NC_Text_A_AND_B_AND_C, new String[] {accountName, accountSite, System.Label.SB_NC_Prefecture}), String.valueOf(SEARCHTYPE_ACNAMESITESTATE), 'utility:signpost', '');
    scc3.groupName = 'Contact';
    inv.searchConditions.add(scc3);
    SB_NC_AccountBulkRegistDTO.SearchCondition scc4 = new SB_NC_AccountBulkRegistDTO.SearchCondition(String.format(System.Label.SB_NC_Text_A_AND_B_AND_C, new String[] {accountName, accountSite, System.Label.SB_NC_Label_To_Street}), String.valueOf(SEARCHTYPE_NAMECITY), 'utility:pin', '');
    scc4.groupName = 'Contact';
    inv.searchConditions.add(scc4);
    SB_NC_AccountBulkRegistDTO.SearchCondition scc5 = new SB_NC_AccountBulkRegistDTO.SearchCondition(String.format(System.Label.SB_NC_Text_A_AND_B_AND_C, new String[] {accountName, accountSite, System.Label.SB_NC_Label_Postcode}), String.valueOf(SEARCHTYPE_NAMECODE), 'utility:email', '');
    scc5.groupName = 'Contact';
    inv.searchConditions.add(scc5);
    inv.searchConditionValueContact = String.valueOf(3);

    inv.searchConditionRct.title = System.Label.SB_NC_Label_Setting;
    inv.labelMap.put('AccountContact', String.format(System.Label.SB_NC_Text_Account_Contact, new String[] {ACCOUNTLABEL, CONTACTLABEL}));
    inv.labelMap.put('AccountNew', String.format(System.Label.SB_NC_Text_SpecifiedWhenCreateNew, new String[] {String.format(System.Label.SB_NC_Text_Account_Contact, new String[] {ACCOUNTLABEL, CONTACTLABEL})}));
    inv.labelMap.put('cardLabel_company_name__c', NameCard__c.company_name__c.getDescribe().getLabel());
    inv.labelMap.put('cardLabel_division__c', NameCard__c.division__c.getDescribe().getLabel());
    inv.labelMap.put('cardLabel_title_name__c', NameCard__c.title_name__c.getDescribe().getLabel());
    inv.labelMap.put('cardLabel_Name', NameCard__c.Name.getDescribe().getLabel());
    inv.labelMap.put('cardLabel_address__c', NameCard__c.address__c.getDescribe().getLabel());
    inv.labelMap.put('cardLabel_mobile__c', NameCard__c.mobile__c.getDescribe().getLabel());
    inv.labelMap.put('cardLabel_email__c', NameCard__c.email__c.getDescribe().getLabel());
    inv.labelMap.put('address_pref__c', NameCard__c.address_pref__c.getDescribe().getLabel());
    inv.searchConditionRct.description = System.Label.SB_NC_Label_SearchRecordTypeExplanation;

    //SV_DEV-2074 LEX 取引先登録 一括：検索対象の取引先レコードタイプ / 検索対象の取引先責任者レコードタイプの初期値が初回読み込まれない への対策
    Map<String, List<String>> searchRecordTypesMap = new Map<String, List<String>>();
    List<String> accSRTList = new List<String>();
    List<String> conSRTList = new List<String>();

    //レコードタイプ情報
    SB_NameCard_RecordTypeUtil.RecordTypeInfos accInfos = SB_NameCard_RecordTypeUtil.create('Account');
    inv.accRecordTypesInfos = accInfos;
    //登録に使うレコードタイプ
    SB_NC_AccountBulkRegistDTO.InputPickListValue inputRA = new SB_NC_AccountBulkRegistDTO.InputPickListValue();
    inputRA.pickListTitle = String.format(System.Label.SB_NC_Label_RecordType, new List<String> {Account.SobjectType.getDescribe().getLabel()});
    inputRA.selectValue = SB_NameCard_Util.getDefaultRecordType(Account.sObjecttype);
    inputRA.show = isShowRecordTypeInput(accInfos);
    inv.accPickListValue= inputRA;
    //検索に使うレコードタイプ
    inv.searchConditionRct.accShow = isShowRecordTypeCondition(accInfos);
    inv.searchConditionRct.accTitle = String.format(System.Label.SB_NC_Label_RecordType, new String[] {Account.sObjecttype.getDescribe().getLabel()});
    inv.searchConditionRct.accRestricted = accInfos.restricted;
    for (SB_NameCard_RecordTypeUtil.RecordTypeInfo info : accInfos.infos) {
      if ( info.isQuery ){
        SB_NC_AccountBulkRegistDTO.LabelValueCheck lvc = new SB_NC_AccountBulkRegistDTO.LabelValueCheck(info);
        inv.searchConditionRct.accRecordTypesCondition.add(lvc);
        accSRTList.add(info.id);
      }
    }
    // (全て)対応
    if ( !accInfos.restricted ){
      SB_NC_AccountBulkRegistDTO.LabelValueCheck lvc = new SB_NC_AccountBulkRegistDTO.LabelValueCheck();
      lvc.label = '(' + System.Label.SB_Text_All + ')';
      lvc.value = 'allAccount';
      lvc.checked = true;
      inv.searchConditionRct.accRecordTypesCondition.add(lvc);
      accSRTList.add('allAccount');
    }

    //レコードタイプ情報
    SB_NameCard_RecordTypeUtil.RecordTypeInfos conInfos = SB_NameCard_RecordTypeUtil.create('Contact');
    inv.conRecordTypesInfos = conInfos;
    //登録に使うレコードタイプ
    SB_NC_AccountBulkRegistDTO.InputPickListValue inputRC = new SB_NC_AccountBulkRegistDTO.InputPickListValue();
    inputRC.pickListTitle = String.format(System.Label.SB_NC_Label_RecordType, new List<String> {Contact.SobjectType.getDescribe().getLabel()});
    inputRC.selectValue = SB_NameCard_Util.getDefaultRecordType(Contact.sObjecttype);
    inputRC.show = isShowRecordTypeInput(conInfos);
    inv.conPickListValue = inputRC;
    //検索に使うレコードタイプ
    inv.searchConditionRct.conShow = isShowRecordTypeCondition(conInfos);
    inv.searchConditionRct.conTitle = String.format(System.Label.SB_NC_Label_RecordType, new String[] {Contact.sObjecttype.getDescribe().getLabel()});
    inv.searchConditionRct.conRestricted = conInfos.restricted;
    for (SB_NameCard_RecordTypeUtil.RecordTypeInfo info : conInfos.infos) {
      if ( info.isQuery ){
        SB_NC_AccountBulkRegistDTO.LabelValueCheck lvc = new SB_NC_AccountBulkRegistDTO.LabelValueCheck(info);
        inv.searchConditionRct.conRecordTypesCondition.add(lvc);
        conSRTList.add(info.id);
      }
    }
    // (全て)対応
    if ( !conInfos.restricted ){
      SB_NC_AccountBulkRegistDTO.LabelValueCheck lvc = new SB_NC_AccountBulkRegistDTO.LabelValueCheck();
      lvc.label = '(' + System.Label.SB_Text_All + ')';
      lvc.value = 'allContact';
      lvc.checked = true;
      inv.searchConditionRct.conRecordTypesCondition.add(lvc);
      conSRTList.add('allContact');
    }

    //SV_DEV-2074 LEX 取引先登録 一括：検索対象の取引先レコードタイプ / 検索対象の取引先責任者レコードタイプの初期値が初回読み込まれない への対策
    searchRecordTypesMap.put('Account',accSRTList);
    searchRecordTypesMap.put('Contact',conSRTList);
    inv.searchRecordTypesMap = searchRecordTypesMap;

    //基本設定で表示設定が行われていて、表示するレコードタイプが2つ以上ある場合のみ描画
    inv.showRecordTypeAcc = ( basicSetting.RegistDispAccountRectype__c && inputRA.show );
    inv.showRecordTypeCon = ( basicSetting.RegistDispContactRectype__c && inputRC.show );

    inv.searchConditionCMtc.title = String.format(System.Label.SB_NC_Label_CompanyMatcingSectionName, new String[] {Account.sObjecttype.getDescribe().getLabel()});
    List<SB_NC_AccountBulkRegistDTO.LabelValueRadio> cMtcValueList = new List<SB_NC_AccountBulkRegistDTO.LabelValueRadio>();

    SB_NC_AccountBulkRegistDTO.LabelValueRadio opt0 = new SB_NC_AccountBulkRegistDTO.LabelValueRadio();
    opt0.Id = 'CorpMatch';
    opt0.label = String.format(System.Label.SB_NC_Label_CompanyMatcingCorpMatch, new String[] {Account.sObjecttype.getDescribe().getLabel()});
    opt0.value = 'CorpMatch';
    cMtcValueList.add(opt0);

    SB_NC_AccountBulkRegistDTO.LabelValueRadio opt1 = new SB_NC_AccountBulkRegistDTO.LabelValueRadio();
    opt1.Id = 'PartialMatch';
    opt1.label = String.format(System.Label.SB_NC_Label_CompanyMatcingPartialMatch, new String[] {Account.sObjecttype.getDescribe().getLabel()});
    opt1.value = 'PartialMatch';
    cMtcValueList.add(opt1);

    SB_NC_AccountBulkRegistDTO.LabelValueRadio opt2 = new SB_NC_AccountBulkRegistDTO.LabelValueRadio();
    opt2.Id = 'ExactMatch';
    opt2.label = String.format(System.Label.SB_NC_Label_CompanyMatcingExactMatch, new String[] {Account.sObjecttype.getDescribe().getLabel()});
    opt2.value = 'ExactMatch';
    cMtcValueList.add(opt2);
    
    inv.searchConditionCMtc.searchConditionpickListOptions = cMtcValueList;
    // SV_DEV-1855 初期値は保存された値を読みます
    if (basicSetting.RenkeiExcludeHojinkaku__c) {
      inv.selectedConditionCMtc = 'CorpMatch'; // 法人格抜きで一致
    }
    else if (basicSetting.RenkeiExcludeHojinkakuPartial__c) {
      inv.selectedConditionCMtc = 'PartialMatch'; // 会社名 部分一致
    }
    else {
      inv.selectedConditionCMtc = 'ExactMatch'; // 完全一致
    }

    inv.haveQueue = true;
    return JSON.serialize(inv);
  }

  // 新規作成時のレコードタイプ選択に表示する項目が2つ以上あるならTrue、なければFalse
  private static Boolean isShowRecordTypeInput(SB_NameCard_RecordTypeUtil.RecordTypeInfos rtInfos){
    Integer cnt = 0;
    for ( SB_NameCard_RecordTypeUtil.RecordTypeInfo info:rtInfos.infos ){
      if ( info.isAvailable ){
        cnt++;
      }
    }
    if ( cnt >= 2 ){
      return true;
    }else{
      return false;
    }
  }

  // 検索対象に出来るレコードタイプがあればTrue、なければFalse
  private static Boolean isShowRecordTypeCondition(SB_NameCard_RecordTypeUtil.RecordTypeInfos rtInfos){
    for ( SB_NameCard_RecordTypeUtil.RecordTypeInfo info:rtInfos.infos ){
      if ( info.isQuery ){
        return true;
      }
    }
    return false;
  }

  // 選択リスト表示のFormatに変更して返す
  public static String getLabel(String name, String email) {
    String label = String.isBlank(name) ? '' : name;
    label += String.isBlank(email) ? ' <>' : ' <'+email+'>';
    return label;
  }

  // nullの場合''に変換して返す
  public static String getStr(String s) {
    return (s == null) ? '' : s;
  }

  // SB_NC_RegistQueryOptionを初期化して取得
  private static SB_NC_RegistQueryOption getQueryOption(sObjectType type) {
    SB_NC_RegistQueryOption ot = new SB_NC_RegistQueryOption(type);
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

  // 検索条件設定
  private static Map<Id,Map<Schema.SObjectType,List<SObject>>> buildCandidateList(Set<Id> ncList, List<NameCard__c> nameCardList,
                                                                                String searchType, String searchContactType,Map<String, List<String>> searchRecordTypesMap, String searchConditionCompanyMatcing) {
    List<SB_NC_RegistQueryOption> queryOptions = new List<SB_NC_RegistQueryOption>();

    if (searchRecordTypesMap == null) {
      searchRecordTypesMap = new Map<String, List<String>>();
    }

    SB_NC_RegistQueryOption accountQueryOption = getQueryOption(Account.sObjecttype);
    SB_NC_RegistQueryOption contactQueryOption =  getQueryOption(Contact.sObjecttype);

    System.debug(searchRecordTypesMap);
    if (searchRecordTypesMap.containsKey('Account')) {
      // (全て) が選択されていたらレコードタイプを条件として使用しない
      if (!searchRecordTypesMap.get('Account').contains('allAccount')) {
        List<Id> accountRecordTypeList = searchRecordTypesMap.get('Account');
        if (accountRecordTypeList.size() > 0) {
          //Set<Id> accountRecord = new Set<Id>();
          //accountRecord.addAll(accountRecordTypeList);
          //System.debug('accountRecord = ' + accountRecord);
          //accountQueryOption.setRectypeIds(accountRecord);
          accountQueryOption.acntRecTypeIds = accountRecordTypeList;
          contactQueryOption.acntRecTypeIds = accountRecordTypeList;

        }
      }
    }

    if (searchRecordTypesMap.containsKey('Contact')) {
      // (全て) が選択されていたらレコードタイプを条件として使用しない
      if (!searchRecordTypesMap.get('Contact').contains('allContact')) {
        List<Id> contactRecordTypeList = searchRecordTypesMap.get('Contact');
        if (contactRecordTypeList.size() > 0) {
          //Set<Id> contactRecord = new Set<Id>();
          //contactRecord.addAll(contactRecordTypeList);
          //System.debug('contactRecord = ' + contactRecord);
          //contactQueryOption.setRectypeIds(contactRecord);
          accountQueryOption.contRecTypeIds = contactRecordTypeList;
          contactQueryOption.contRecTypeIds = contactRecordTypeList;
        }
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
    contactQueryOption.queryCompany = true;
    accountQueryOption.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;
    contactQueryOption.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;// v2.4

    switch on searchConditionCompanyMatcing {
      when 'CorpMatch' {
        accountQueryOption.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.CorpMatch;
        contactQueryOption.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.CorpMatch;
      }
      when 'PartialMatch' {
        accountQueryOption.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.PartialMatch;
        contactQueryOption.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.PartialMatch;
      }
      when 'ExactMatch' {
        accountQueryOption.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.ExactMatch;
        contactQueryOption.companyRule = SB_NC_RegistQueryOption.CompanyMatcing.ExactMatch;
      }
    }
    contactQueryOption.deptRule = SB_NC_RegistQueryOption.DeptMatcing.PartialMatch;// v2.4
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
    accountQueryOption.bulkRegist = true; // v2.4
    accountQueryOption.queryOnlyEMail = false;  // v2.4  EMAILだけが一致するコンタクトの親アカウントは対象にしない
    contactQueryOption.bulkRegist = true; // v2.4
    contactQueryOption.queryOnlyEMail = true;  // v2.4  EMAILだけが一致するコンタクトを対象にする

    contactQueryOption.queryLastName = true;
    contactQueryOption.queryFirstName = true;
    contactQueryOption.queryEMail = true;
    queryOptions.add(accountQueryOption);
    queryOptions.add(contactQueryOption);
    System.assert(!queryOptions.isEmpty());
    // クエリする対象のオブエジェクト ごとに　SB_NC_RegistQueryOption を作って、検索の条件を指定して、選択された名刺のレコードIDと一緒に渡します。
    SB_NameCard_RegistCanPickerAbstract picker = SB_NameCard_RegistCanPickerAbstract.createCandidatePicker(queryOptions, ncList);  //
    // 名刺IDごとの SObjectTypeごとのレコードリストを得ます。
    Map<Id,Map<Schema.SObjectType, List<SObject>>> otype2objs = picker.create();
    System.debug(otype2objs);
    return otype2objs;
  }

  // 保存
  // SV_DEV-762 名刺オブジェクトの編集権限がない場合にリードに登録の処理が終了しない。
  @RemoteAction
  @AuraEnabled
  public static String saveRecord(String customObjects, String inputVStr,String registType) {
    // saveOK = true;
    Savepoint sp;
    System.debug('start save');
    String message = '';
    SB_NC_AccountBulkRegistDTO.SaveResult saveResult = new SB_NC_AccountBulkRegistDTO.SaveResult();
    List<SB_NC_AccountBulkRegistDTO.CustomObject> dataList = (List<SB_NC_AccountBulkRegistDTO.CustomObject>)System.JSON.deserializeStrict(customObjects, List<SB_NC_AccountBulkRegistDTO.CustomObject> .Class);

    try {
        SB_NC_AccountBulkRegistDTO.InputValue inputV = (SB_NC_AccountBulkRegistDTO.InputValue)System.JSON.deserializeStrict(inputVStr, SB_NC_AccountBulkRegistDTO.InputValue .Class);
        if (String.isNotBlank(inputV.ownerId)) {
          Id inOwnerId = inputV.ownerId;
          if (inOwnerId.getSobjectType() == QueueSobject.getSobjectType()) {
            List<QueueSobject> qss = [SELECT Id,
                                             QueueId
                                        FROM QueueSobject
                                      WHERE Id = :inOwnerId];
            if (qss.isEmpty()) {
              throw new SB_NC_RegistExecutor.SB_NC_RegistExecutorException(System.Label.SB_NC_Msg_CanNotUseInActiveQueue);
            }
            inputV.ownerId = qss[0].QueueId;
          }
        }
        String ownerId = inputV.ownerId;
        String accountOwnerId = inputV.accountOwnerId;
        Boolean useNameCardOwner = inputV.useNameCardOwner;
        Boolean useNameCardAccountOwner = inputV.useNameCardAccountOwner;
        Boolean accountOverwrite = inputV.inputRegistOverWritValues[0].overWriteCheck.checked;
        Boolean contactOverwrite = inputV.inputRegistOverWritValues[1].overWriteCheck.checked;

        String accountRecordTypeId = inputV.accPickListValue.selectValue;
        String contactRecordTypeId = inputV.conPickListValue.selectValue;
        Boolean hasError = false;
        // for (NameCardRecord ncRec : this.nameCardRecordList) ncRec.hasError = false;
        sp = Database.setSavepoint();
        String str = '';

        List<SB_NC_RegistExecutor.RegistTarget> tars = new List<SB_NC_RegistExecutor.RegistTarget>();
        Boolean haveNew = false;
        Boolean haveAccountNew = false;
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
          Map<String, SB_NC_AccountBulkRegistDTO.CustomField> cObjectMap = dataList[i].cObjectMap;
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
                    noOwnerIdErrorMessage = System.Label.SB_NC_SpecifyOwnerWhenCreateAcCo;
                  }
                  else {
                    noOwnerIdErrorMessage = System.Label.SB_NC_SpecifyOwnerWhenCreateAcCo;
                  }
                  throw new SB_NC_RegistExecutor.SB_NC_RegistExecutorException(noOwnerIdErrorMessage);
                }
              }
            }
            SB_NC_RegistExecutor.RegistTarget tar = new SB_NC_RegistExecutor.RegistTarget(nameCardId,
                                                                                          accountId,
                                                                                          contactId,
                                                                                          null,
                                                                                          registTodo,
                                                                                          null);
            tars.add(tar);
          }
        }
        SB_NC_RegistExecutor.RegistParam accountRP;
        SB_NC_RegistExecutor.RegistParam contactRP;
        accountRP = new SB_NC_RegistExecutor.RegistParam('Account', accountOverwrite, accountRecordTypeId,oIdAccount,false);
        contactRP = new SB_NC_RegistExecutor.RegistParam('Contact', contactOverwrite, contactRecordTypeId,oIdAccount,false);
        NameCardBasicSetting__c basicSetting = SB_NameCard_BasicSetting.getNameCardBasicSetting();        
        //SV_DEV-2367 基本設定で値が未設定ならカスタムラベルの値を読む
        basicSetting.RegistToDoSubject__c = String.isBlank(basicSetting.RegistToDoSubject__c) ? System.Label.SB_NC_ExchangeCard : basicSetting.RegistToDoSubject__c;
        SB_NC_RegistExecutor.TodoParam todoRP = new SB_NC_RegistExecutor.TodoParam(basicSetting.RegistToDoSubject__c,null,null,null);

        SB_NC_RegistExecutor.RegistRequest re = new SB_NC_RegistExecutor.RegistRequest(tars, accountRP, contactRP, null , todoRP);
        // SV_DEV-2047 LEX 取引先登録 一括：Todo任命先が「名刺の所有者」で、有効なユーザが所有者の名刺レコードで、上書き登録した場合にユーザが無効エラーメッセージが表示される
        //  → Todo任命先が「名刺の所有者」 か判別します。
        Map<Id, String> ownerErrorMap = SB_NameCard_RegistOwnerCheckHelper.doCheck(re, basicSetting.RegistToDoOwner__c == 'NameCardOwner');
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
          throw new SB_NC_RegistExecutor.SB_NC_RegistExecutorException(str);
        }
        //doRegist内既にrollbackしていますので、ここは二度目はしません
        SB_NC_RegistExecutor.RegistResponse result = SB_NC_RegistExecutor.doRegist(re);

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
          throw new SB_NC_RegistExecutor.SB_NC_RegistExecutorException(result.title + str);
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
}