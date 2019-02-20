/**
 *
 * SB_NCL_UpdateByCardLcController 名刺で更新Lightning Controller
 *
 * Copyright (C) 2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author gao
 *  @Version 1.12      2018.5.xx SV_DEV-910 [LEX]リードの名刺で更新のLightning版対応
 *
 **/

public with sharing class SB_NCL_UpdateByCardLcController {

  private final static String NAMECARD_QUERY_FROM = 'SELECT {0} FROM SmartViscaf__NameCard__c WHERE Id = :id';

  @RemoteAction
  @AuraEnabled
  /**
    * @description SB基本設定データを取得
    * 検索条件の変更などないので、検索用のメソッドは作成しません
    * @param targetId リードID
    * @return 画面表示Datejson
  **/
  public static String getUpdateByCard(String targetId) {
    SB_NCL_UpdateByCardDTO ba = new SB_NCL_UpdateByCardDTO();
    ba.titleV.titleName = String.format(System.Label.SB_NCLD_Text_BusinessCardList, new String[]{SmartViscaf__NameCard__c.sObjectType.getDescribe().getLabel()});
    ba.titleV.iconName = 'standard:account';
    ba.titleV.iconSize = 'large';
    ba.titleV.closeValue = System.Label.SB_NCLD_Label_Close;
    Lead pageLead = getLead(targetId);
    ba.dataList = search(pageLead);
    ba.titleV.linkName = pageLead.LastName + pageLead.FirstName;
    return JSON.serialize(ba);
  }

  @RemoteAction
  @AuraEnabled
  /**
    * @description DataTable表示項目を取る
    * @return 画面表示項目リスト
  **/
  public static String getInputValue() {
    SmartViscaf__NameCardBasicSetting__c baseSetting = SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting();
    SB_NCL_UpdateByCardDTO.InputValue inputV = new SB_NCL_UpdateByCardDTO.InputValue();
    inputV.checkboxLabel = String.format(System.Label.SB_NCLD_Label_OverwriteLeadInfoDEV, new String[]{Lead.sObjectType.getDescribe().getLabel()});
    inputV.radioTitle = System.Label.SB_NCLD_Label_SearchCondition;
    inputV.radioValue = '1';
    inputV.checkboxValue = baseSetting.SmartViscaf__RegistLeadNotOverWrite__c && Lead.SObjectType.getDescribe().isUpdateable();
    return JSON.serialize(inputV);
  }

  @RemoteAction
  @AuraEnabled
  /**
    * @description DataTable表示項目を取る
    * @return 画面表示項目リスト
  **/
  public static String getFieldList() {
    List<SB_NCL_UpdateByCardDTO.DataTableColumnField> fieldList = new List<SB_NCL_UpdateByCardDTO.DataTableColumnField>();
    fieldList.add(new SB_NCL_UpdateByCardDTO.DataTableColumnField(SmartViscaf__NameCard__c.SmartViscaf__card_exchange_date__c.getDescribe().getLabel(), 'SmartViscaf__card_exchange_date__c', 'date'));
    fieldList.add(new SB_NCL_UpdateByCardDTO.DataTableColumnField(SmartViscaf__NameCard__c.SmartViscaf__company_name__c.getDescribe().getLabel(), 'SmartViscaf__company_name__c', 'text'));
    fieldList.add(new SB_NCL_UpdateByCardDTO.DataTableColumnField(SmartViscaf__NameCard__c.SmartViscaf__address_pref__c.getDescribe().getLabel(), 'SmartViscaf__address_pref__c', 'text'));
    fieldList.add(new SB_NCL_UpdateByCardDTO.DataTableColumnField(SmartViscaf__NameCard__c.SmartViscaf__division__c.getDescribe().getLabel(), 'SmartViscaf__division__c', 'text'));
    fieldList.add(new SB_NCL_UpdateByCardDTO.DataTableColumnField(SmartViscaf__NameCard__c.SmartViscaf__title_name__c.getDescribe().getLabel(), 'SmartViscaf__title_name__c', 'text'));
    SB_NCL_UpdateByCardDTO.DataTableColumnField urlB = new SB_NCL_UpdateByCardDTO.DataTableColumnField(SmartViscaf__NameCard__c.Name.getDescribe().getLabel(), 'LINK', 'url');
    urlB.setURLLabel('Name');
    fieldList.add(urlB);
    fieldList.add(new SB_NCL_UpdateByCardDTO.DataTableColumnField(SmartViscaf__NameCard__c.SmartViscaf__email__c.getDescribe().getLabel(), 'SmartViscaf__email__c', 'text'));
    SB_NCL_UpdateByCardDTO.DataTableColumnField button = new SB_NCL_UpdateByCardDTO.DataTableColumnField('更新', '更新', 'button');
    SB_NCL_UpdateByCardDTO.Button b = new SB_NCL_UpdateByCardDTO.Button();
    b.label = System.Label.SB_NCLD_Text_Update;
    button.typeAttributes = b;
    fieldList.add(button);
    return JSON.serialize(fieldList);
  }

  @RemoteAction
  @AuraEnabled
  /**
    * @description 更新保存メソッド
    * @param leadId リードID
    * @param targetId 名刺ID
    * @param overWrite チェックボックス　「既存のリードの情報を名刺情報で上書きする」に対応
    * @return 保存結果
  **/
  public static String updateLead(String leadId, String targetId, Boolean overWrite) {
    Savepoint sp;
    SaveResult sr = new SaveResult();
    try {
      SmartViscaf__NameCard__c nameCard = getNameCard(targetId);
      Lead updLead;
      if (overWrite) {
        SmartViscaf.SB_NameCard_RenkeiMapper mapper = SmartViscaf.SB_NameCard_RenkeiMapper.getInstance('Lead', true);
        updLead = (Lead)mapper.updateRecord(nameCard, leadId);
        //updLead = SB_NameCard_LeadRegist.getLead(this.pageLead.Id, ncRec.nameCard, null,null);
      } else {
        updLead = new Lead(Id = leadId, NameCard__c = targetId);
      }
      sp = Database.setSavepoint();
      Database.DMLOptions leaddml = new Database.DMLOptions();
      leaddml.OptAllOrNone = true;
      SmartViscaf.SB_NameCard_CrudFls.supdate(new List<Lead>{updLead}, leaddml);
      if (nameCard.SmartViscaf__lead__c != updLead.Id) {
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.OptAllOrNone = false;
        SmartViscaf.SB_NameCard_CrudFls.supdate(new List<SmartViscaf__NameCard__c>{new SmartViscaf__NameCard__c(Id=nameCard.Id, SmartViscaf__lead__c=updLead.Id)},dml);
      }
    }
    catch (Exception e) {
      System.debug(e.getStackTraceString());
      sr.isOk = false;
      sr.message = e.getMessage();
    }
    return JSON.serialize(sr);
  }

  /**
    * @description 名刺検索メソッド
    * @param pageLead リード
    * @return 名刺リスト
  **/
  public static List<sObject> search(Lead pageLead) {
    // return [Select Id,Name From Account];
    List<SmartViscaf__NameCard__c> nameCardList1 = new List<SmartViscaf__NameCard__c>();
    List<SmartViscaf__NameCard__c> nameCardList = getNameCardList(pageLead, false);
    if (nameCardList != null && nameCardList.size() > 1000) {
        nameCardList = getNameCardList(pageLead, true);
    }
    if (nameCardList != null && nameCardList.size() <= 1000) {
      for (SmartViscaf__NameCard__c nc : nameCardList) {
        nameCardList1.add(nc);
      }
    }
    return nameCardList1;
  }

  /**
    * @description 更新元の名刺取得メソッド
    * @param pageLead リード
    * @param latestonly 名刺表示最大値超えたらTrue
    * @return 名刺リスト
  **/
  private static List<SmartViscaf__NameCard__c> getNameCardList(Lead pageLead, Boolean latestonly) {
    if (pageLead == null) return null;

    List<String> whereList = new List<String>();
    String leadId, email, lastName, firstName;
    leadId = pageLead.Id;
    whereList.add('SmartViscaf__lead__c = :leadId');
    if (String.isNotBlank(pageLead.Email)) {
      email = pageLead.Email;
      whereList.add('SmartViscaf__email__c = :email');
    }
    if (String.isNotBlank(pageLead.LastName) && String.isNotBlank(pageLead.FirstName)) {
      lastName = pageLead.LastName;
      firstName = pageLead.FirstName;
      whereList.add('((SmartViscaf__person_name_last__c = :lastName OR SmartViscaf__last_name__c = :lastName)'
        + ' AND (SmartViscaf__person_name_first__c = :firstName OR SmartViscaf__first_name__c = :firstName))');
    }
    if (whereList.size() <= 0) return null;
    String whereStr = '';
    for (String s : whereList) whereStr += ' OR ' + s;
    whereStr = whereStr.removeStart(' OR ');
        if (latestonly) {
            whereStr = '(' + whereStr + ') AND SmartViscaf__delivery_type__c != \'1\' AND SmartViscaf__Parent__c = null';
        }
    String soql = 'SELECT Id, Name, OwnerId, Owner.Name, LastModifiedDate,SmartViscaf__division__c,'
      + ' SmartViscaf__zip_code__c, SmartViscaf__address_pref__c, SmartViscaf__address__c,'
      + ' SmartViscaf__address_bld__c, SmartViscaf__address_eng__c,'
      + ' SmartViscaf__company_name__c, SmartViscaf__web_url1__c, SmartViscaf__tel1__c, SmartViscaf__fax1__c, SmartViscaf__title_name__c,'
      + ' SmartViscaf__person_name_last__c, SmartViscaf__person_name_first__c, SmartViscaf__last_name__c, SmartViscaf__first_name__c,'
      + ' SmartViscaf__email__c, SmartViscaf__mobile__c, SmartViscaf__lead__c, campaign__c,'
      + ' SmartViscaf__list_name__c, SmartViscaf__memo__c, SmartViscaf__freehandmemo__c, SmartViscaf__card_exchange_date__c'
      + ' FROM SmartViscaf__NameCard__c'
      + ' WHERE ' + whereStr
      + ' ORDER BY SmartViscaf__card_exchange_date__c DESC NULLS LAST, SmartViscaf__company_name__c ASC NULLS LAST,'
      + ' SmartViscaf__address_pref__c ASC NULLS LAST, SmartViscaf__title_name__c ASC NULLS LAST, LastModifiedDate DESC LIMIT 1001';
    return Database.query(soql);
  }


  /**
    * @description リード取得メソッド
    * @param leadId リードID
    * @return リードレコード
  **/
  private static Lead getLead(Id leadId) {
    if (leadId == null) return null;
    for (Lead lead : [SELECT Id, Name, Email, LastName, FirstName FROM Lead WHERE Id = :leadId]) {
      return lead;
    }
    return null;
  }

  /**
    * @description 名刺取得メソッド
    * @param id 名刺ID
    * @return 名刺レコード
  **/
  private static SmartViscaf__NameCard__c getNameCard(String id) {
    Set<String> fields = SmartViscaf.SB_NameCard_RenkeiMapper.getInstance(Lead.sObjectType.getDescribe().getName(), false).getNameCardQueryFields();
    String ns = SmartViscaf.SB_NameCard_Util.getNamespacePrefix_x();
    // Name
    fields.add('Name');
    // 所有者
    fields.add('OwnerId');
    // 名刺交換日  2017.04.25
    fields.add(ns + 'card_exchange_date__c');
    // 会社名
    fields.add(ns + 'company_name__c');
    // 住所用の項目
    fields.add(ns + 'address_pref__c');
    fields.add(ns + 'address__c');
    fields.add(ns + 'address_eng__c');
    fields.add(ns + 'address_bld__c');
    // 姓名用の項目
    fields.add(ns + 'person_name_last__c');
    fields.add(ns + 'person_name_first__c');
    fields.add(ns + 'last_name__c');
    fields.add(ns + 'first_name__c');
    // 上書きしない
    fields.add(ns + 'isNotOverwrite__c');
    fields.add(ns + 'isNotOverContactwrite__c');
    // 参照項目
    fields.add(ns + 'account__c');
    fields.add(ns + 'contact__c');
    fields.add(ns + 'lead__c');
    //  CardHolder で 識別用に使っている項目
    fields.add(ns + 'division__c');
    fields.add(ns + 'zip_code__c');
    fields.add(ns + 'tel1__c');
    fields.add(ns + 'tel2__c');
    fields.add(ns + 'web_url1__c');
    fields.add(ns + 'web_url2__c');
    fields.add(ns + 'memo__c');
    fields.add(ns + 'email__c');
    //removeAddressLabel(fields);
    fields.remove('city');
    fields.remove('street');
    fields.remove('pref_address_bld');
    fields.remove('address_bld');
    fields.remove('street_nobld');
    fields.remove('last_name');
    fields.remove('first_name');
    // クエリ文字列
    String query = String.format(NAMECARD_QUERY_FROM, new String[] { String.join(new List<String>(fields), ', ') });
    System.debug('+++createNameCardMap: ' + query);
    return Database.query(query);
  }

  /**
    * @description 保存結果を表示するためのBeanクラス
  **/
  public class SaveResult {
    @AuraEnabled public Boolean isOk {get; set;}
    @AuraEnabled public String message {get; set;}
    public SaveResult() {
      this.isOk = true;
      this.message = '';
    }
  }
}