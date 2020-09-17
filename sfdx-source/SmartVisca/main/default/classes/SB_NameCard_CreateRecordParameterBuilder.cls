/*
 *
 * SB_NameCard_CreateRecordParameterBuilder
 *
 *  新規レコード作成の標準画面にデフォルト値をセットするためのパラメータ用の文字列を作るクラス
 *  SmartViscaT05 パケージから
 *
 *  @author sawano
 *  @Version 1      2017.08.xx
 *
 * Copyright (c) 2017 SunBridge Inc.
 *
 */
public with sharing class SB_NameCard_CreateRecordParameterBuilder {

  // Classic の Account 作成画面のレコード項目API名と入力項目キー
  private static final Map<String, String> ACCOUNT_FIELD_KEY = new Map<String, String> {
    'Name' => 'acc2',
    'Site' => 'acc23',
    'Website' => 'acc12',
    'BillingPostalCode' => 'acc17zip',
    'BillingState' => 'acc17state',
    'BillingCity' => 'acc17city',
    'BillingStreet' => 'acc17street',
    'ShippingPostalCode' => 'acc18zip',
    'ShippingState' => 'acc18state',
    'ShippingCity' => 'acc18city',
    'ShippingStreet' => 'acc18street',
    'Phone' => 'acc10',
    'Fax' => 'acc11',
    //'NameCard__c' => '',
    //'NameCardListName__c' => '',
    //'NameCardMemo__c' => '',
    //'NameCardFreehandmemo__c' => ''
    //'OwnerId' => ''
    'Description' => 'acc20'
  };

  // Classic の Contact 作成画面のレコード項目API名と入力項目キー
  private static final Map<String, String> CONTACT_FIELD_KEY = new Map<String, String> {
    'LastName' => 'name_lastcon2',
    'FirstName' => 'name_firstcon2',
    'AccountId' => 'con4_lkid',
    'MailingPostalCode' => 'con19zip',
    'MailingState' => 'con19state',
    'MailingCity' => 'con19city',
    'MailingStreet' => 'con19street',
    'OtherPostalCode' => 'con18zip',
    'OtherState' => 'con18state',
    'OtherCity' => 'con18city',
    'OtherStreet' => 'con18street',
    'Phone' => 'con10',
    'Fax' => 'con11',
    'MobilePhone' => 'con12',
    'OtherPhone' => 'con14',
    'Email' => 'con15',
    'Department' => 'con6',
    'Title' => 'con5',
    //'SmartViscaf__NameCard__c' => '',
    //'SmartViscaf__NameCardListName__c' => '',
    //'SmartViscaf__NameCardMemo__c' => '',
    //'SmartViscaf__NameCardFreehandmemo__c' => '',
    //'OwnerId' => ''
    'Description' => 'con20'
  };

  private static final Map<String, String> LEAD_FIELD_KEY = new Map<String, String> {
    'LastName' => 'name_lastlea2',
    'FirstName' => 'name_firstlea2',
    'PostalCode' => 'lea16zip',
    'State' => 'lea16state',
    'City' => 'lea16city',
    'Street' => 'lea16street',
    'Company' => 'lea3',
    'Phone' => 'lea8',
    'Fax' => 'lea10',
    'MobilePhone' => 'lea9',
    'Email' => 'lea11',
    'Title' => 'lea4',
    //'SmartViscaf__NameCard__c' => '',
    //'SmartViscaf__NameCardListName__c' => '',
    //'SmartViscaf__NameCardMemo__c' => '',
    //'SmartViscaf__NameCardFreehandmemo__c' => '',
    //'OwnerId' => ''
    'Description' => 'lea17'
  };

  // Classic の Lead 作成画面のレコード項目API名と入力項目キー
  private static Map<SObjectType, Map<String, String>> SOBJ_FIELD_KEY = new Map<SObjectType, Map<String, String>> {
    Account.sObjectType => ACCOUNT_FIELD_KEY,
    Contact.sObjectType => CONTACT_FIELD_KEY,
    Lead.sObjectType => LEAD_FIELD_KEY
  };


  public static String buildClassic(SObject obj) {
    Map<String, String> field2Key = SOBJ_FIELD_KEY.get(obj.getSObjectType());
    Map<String,Object> values = obj.getPopulatedFieldsAsMap();
    System.assert(field2Key != null);
    List<String> params = new List<String>();
    for (String f : values.keySet()) {
      if (field2Key.containsKey(f) == false) {
        continue;
      }
      String key = field2Key.get(f);
      Object val = obj.get(f);
      if (!(val instanceof String) && String.isBlank((String)val)) {
        continue;
      }
      String param = key + '=' + EncodingUtil.urlEncode((String)val, 'UTF-8');  // IE11だと、UNICODE　エンコードされてないとエラーになるので。
      params.add(param);
    }
    //&RecordType=0126F000000oB2Q&ent=Account
    if (values.containsKey('RecordTypeId')) {
      Id rectypeId = (Id)obj.get('RecordTypeId');
      if (rectypeId != null && String.isNotBlank(rectypeId)) {
        params.add('RecordType='+ rectypeId);
      }
    }
    if (obj.getSObjectType() == Contact.sObjectType && values.containsKey('AccountId')) {
      // 取引先責任者の取引先ID指定で必要な感じ
      params.add('con4_mod=1');
    }
    params.add('ent=' + obj.getSObjectType().getDescribe().getName());
    return String.join(params, '&');
  }

  public static String buildLex(SObject obj) {
    return JSON.serialize(obj.getPopulatedFieldsAsMap());
  }

}