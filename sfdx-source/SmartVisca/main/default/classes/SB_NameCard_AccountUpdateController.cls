/*  $Id: SB_NameCard_AccountUpdateController.cls 10 2012-10-19 02:48:43Z ume $  */

/*
 * Copyright (c) 2011-2015 Sunbridge Inc.
 *
 * 取引先・取引先責任者の名刺情報を使った更新
 * @author gao
 *  @Version 2.4    2019.05.XX  SV_DEV-958 入力規則エラーメッセージを加工せずそのまま表示させる対応
 */
public with sharing class SB_NameCard_AccountUpdateController {
  public class AccountUpdateControllerException extends exception {}
  private PageReference retUrl;      //更新後のURL
  private String nId;                //名刺ID
  private String aId;                //取引先ID
  private String cId;                //取引先責任者ID
  public  String backLabel{get; private set;} //戻すらべる
  private final static String NAMECARD_QUERY_FROM = 'SELECT {0} FROM NameCard__c WHERE Id = :id';

  public SB_NameCard_AccountUpdateController() {
    try {
      this.backLabel = System.Label.SB_NC_Return;
      this.nId = System.currentPageReference().getParameters().get('nid');
      this.aId = System.currentPageReference().getParameters().get('aid');
      this.cId = System.currentPageReference().getParameters().get('cid');

      System.debug(Logginglevel.DEBUG, '################################################################################');
      System.debug(Logginglevel.DEBUG, 'parameter nid: ' + this.nId);
      System.debug(Logginglevel.DEBUG, 'parameter aid: ' + this.aId);
      System.debug(Logginglevel.DEBUG, 'parameter cid: ' + this.cId);
      System.debug(Logginglevel.DEBUG, '################################################################################');
      String name = '';
      if (this.aId != null && this.aId.length() > 0) {
          this.retUrl = new PageReference('/' + this.aId);
        name = 'Account';
      } else if (this.cId != null && this.cId.length() > 0) {
        this.retUrl = new PageReference('/' + this.cId);
        name = 'Contact';
      } else {
        this.retUrl = new PageReference('/home/home.jsp');
      }
      Schema.DescribeSObjectResult tar = Schema.getGlobalDescribe().get(name).getDescribe();
      if(!Schema.getGlobalDescribe().get(name).getDescribe().isUpdateable()) {
        throw new AccountUpdateControllerException(String.format(System.Label.SB_MSG_CrudNotUpdateable, new String[]{tar.label}));
      }
    } catch (Exception e) {
      String path = '';
      if (this.aId != null && this.aId.length() > 0) {
          path = '/' + this.aId;
      } else if (this.cId != null && this.cId.length() > 0) {
          path = '/' + this.cId;
      } else {
          path = '/home/home.jsp';
      }
      String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
      String error = e.getMessage() + '<a href="' + baseUrl  + path +'">' + this.backLabel + '</a>' + '<br>';
      e.setMessage(error);
      ApexPages.addMessages(e);
    }
  }

  //back
  public PageReference backaction() {
    return this.retUrl;
  }

  // 更新
  public PageReference save(){
    NameCard__c nameCard;

    try {
      nameCard = this.getNameCard(this.nId);
      System.debug(Logginglevel.DEBUG, '################################################################################');
      System.debug(Logginglevel.DEBUG, 'this.nId: ' + this.nId);
      if (nameCard == null) {
        System.debug(Logginglevel.DEBUG, 'nameCard.size: null');
        return this.retUrl; // 2014.4.2x NULLなら以降処理不用
      } else {
        System.debug(Logginglevel.DEBUG, 'nameCard.size: not null');
      }
      System.debug(Logginglevel.DEBUG, '################################################################################');
      // 2014.4.2x CodeScan で Bulkify Apex Methods - Using Collections in methods と勘違いされるので、修正
      list<Account> acnts = new list<Account>();
      list<Contact> conts = new list<Contact>();
      list<NameCard__c> ncs = new list<NameCard__c>();
      list<Task> tasks = new list<Task>();
      list<Event> events = new list<Event>();
      if (this.aId != null && this.aId.length() > 0) {
        //acnts.add(this.updateAccount(this.aId, nameCard));
        SB_NameCard_RenkeiMapper mapper = SB_NameCard_RenkeiMapper.getInstance('Account', true);
        acnts.add((Account)mapper.updateRecord(nameCard, this.aId));
        nameCard.account__c = this.aId;
      } else if (this.cId != null && this.cId.length() > 0) {
        SB_NameCard_RenkeiMapper mapper = SB_NameCard_RenkeiMapper.getInstance('Contact', true);
        Contact c = (Contact)mapper.updateRecord(nameCard, this.cId);
        conts.add(c);
        //conts.add(this.updateContact(this.cId, nameCard));
        nameCard.contact__c = this.cId;
        tasks = this.refTask(this.cId, nameCard);
        events = this.refEvent(this.cId, nameCard);
      }

      ncs.add(nameCard);

      List<Database.SaveResult> results = null;
      Database.DMLOptions dmlOptions = new Database.DMLOptions();
      dmlOptions.allowFieldTruncation = true;
      dmlOptions.DuplicateRuleHeader.allowSave = false;
      dmlOptions.DuplicateRuleHeader.runAsCurrentUser = true;

      if (acnts.isEmpty() == false) {
        // SV_DEV-958 入力規則エラーメッセージを加工せずそのまま表示させる対応
        //SB_NameCard_CrudFls.supdate(acnts, true);
        results = SB_NameCard_CrudFls.supdate(acnts, dmlOptions);
        SB_NameCard_SaveResult dbError = new SB_NameCard_SaveResult();
        dbError.putSaveResults(results);
        if (dbError.isError()) {
          throw new AccountUpdateControllerException(dbError.getDbErrorHolder(0).text);
        }
      }
      if (conts.isEmpty() == false) {
        // SV_DEV-958 入力規則エラーメッセージを加工せずそのまま表示させる対応
        //SB_NameCard_CrudFls.supdate(conts, true);
        results = SB_NameCard_CrudFls.supdate(conts, dmlOptions);
        SB_NameCard_SaveResult dbError = new SB_NameCard_SaveResult();
        dbError.putSaveResults(results);
        if (dbError.isError()) {
          throw new AccountUpdateControllerException(dbError.getDbErrorHolder(0).text);
        }
        if (tasks.isEmpty() == false) {
          SB_NameCard_CrudFls.supdate(tasks, true);
        }
        if (events.isEmpty() == false) {
            SB_NameCard_CrudFls.supdate(events, true);
        }
      }
      // 取引先,取引先責任者を名刺に紐づく by syu@sunbridge.com 04/23/2015
      SB_NameCard_CrudFls.supdate(ncs, true);

      return this.retUrl;
    }
    catch (Exception e) {

      String path = '';
      String name = '';
      if (this.aId != null && this.aId.length() > 0) {
        path = '/' + this.aId;
      } else if (this.cId != null && this.cId.length() > 0) {
        path = '/' + this.cId;
      } else {
        name = 'else';
        path = '/home/home.jsp';
      }
      String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
      String error = e.getMessage() + '<a href="' + baseUrl + path +'">' + this.backLabel + '</a>' + '<br>';
      AccountUpdateControllerException aa = new AccountUpdateControllerException();
      aa.setMessage(error);
      ApexPages.addMessages(aa);
      return null;
    }
  }

  public List<SB_NameCard_RenkeiMapper> getMappers() {
    List<SB_NameCard_RenkeiMapper> mappers = new List<SB_NameCard_RenkeiMapper>();
    mappers.add(SB_NameCard_RenkeiMapper.getInstance(Account.sObjectType.getDescribe().getName(), false));
    mappers.add(SB_NameCard_RenkeiMapper.getInstance(Contact.sObjectType.getDescribe().getName(), false));
    return mappers;
  }

  // todo紐づく by syu@sunbridge.com 05/01/2015
  private List<Task> refTask (String id, NameCard__c nameCard) {
    List<Task> taskList = [SELECT WhoId FROM Task WHERE WhatId = :nameCard.Id];
    if (taskList.isEmpty() == false) {
      for (Integer i = 0; i < taskList.size(); i++) {
        if (String.isBlank(taskList[i].WhoId) == TRUE) {
          taskList[i].WhoId = id;
        }
      }
    }
    return taskList;
  }//

  // 行動紐づく by syu@sunbridge.com 05/07/2015
  private List<Event> refEvent (String id, NameCard__c nameCard) {
    List<Event> eventList = [SELECT WhoId FROM Event WHERE WhatId = :nameCard.Id];
    if (eventList.isEmpty() == false) {
      for (Integer i = 0; i < eventList.size(); i++) {
        if (String.isBlank(eventList[i].WhoId) == TRUE) {
          eventList[i].WhoId = id;
        }
      }
    }
    return eventList;
  }

  // 名刺
  private NameCard__c getNameCard(String id) {
    Set<String> fields = new Set<String>();
    for (SB_NameCard_RenkeiMapper mapper : getMappers()) {
      fields.addAll(mapper.getNameCardQueryFields());
    }
    String ns = SB_NameCard_Util.getNamespacePrefix_x();
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
}