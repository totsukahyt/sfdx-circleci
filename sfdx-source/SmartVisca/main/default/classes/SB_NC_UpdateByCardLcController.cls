/**
 *
 *  SB_NC_UpdateByCardLcController.cls
 *  SmartVisca LEX対応
 *  名刺で更新 Lightningコンポーネント 用 コントローラ
 *
 *  clasic での以下に相当
 *      SB_NameCard_NameCardList    候補の名刺所得
 *      SB_NameCard_AccountUpdate   更新
 *
 * Copyright (C) 2016 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2016.10.xx
 *
 **/
public with sharing class SB_NC_UpdateByCardLcController {
  public class SB_NC_UpdateByCardLcControllerException extends Exception {}

  // 名刺で更新する対象のオブジェクトか？
  @TestVisible
  private static Boolean isEnabileObject(SObjectType otype) {
    String objName = otype.getDescribe().getName();
    List<Schema.RecordTypeInfo> rectypeInfos = NameCardRenkeiMapping__c.getSObjectType().getDescribe().getRecordTypeInfos();
    for (Schema.RecordTypeInfo rectypeInfo : rectypeInfos) {
      if (rectypeInfo.getName() == objName) {
        return true;
      }
    }
    return false;
  }

  //////////////// 候補の名刺取得処理 ////////////////
  public class GetNamecardsResponse {
    @AuraEnabled public Boolean success { get; private set; }
    @AuraEnabled public Boolean isShowRadio { get; private set; } // クエリラジオボタン表示フラグ
    @AuraEnabled public String error { get; private set; }
    @AuraEnabled public List<Object> cards { get; private set; }    // 候補の名刺
    @AuraEnabled public Id targetId  { get; private set; }     // 対象のレコードID
    @AuraEnabled public String targetName  { get; private set; }   // 対象のレコードのName 値
    @AuraEnabled public String objLabel { get; private set; }    // 対象のレコードのオブジェクト ラベル名
    @AuraEnabled public String objName { get; private set; }     // 対象のレコードのオブジェクト API名
    @AuraEnabled public List<Map<String, String>> searchTypeSelectOpts { get; private set; }     // 対象のレコードのオブジェクト API名

    public void run(Id targetId) {
      run(targetId, '0');
    }

    public void run(Id targetId, String searchType) {
      try {
        if(targetId == null) {
          return;
        }
        this.targetId = targetId;
        Schema.SObjectType otype = this.targetId.getSObjectType();
        this.objName = otype.getDescribe().getName();
        this.objLabel = otype.getDescribe().getLabel();
        Id tempId = this.targetId;
        String query = 'SELECT Name FROM ' + this.objName + ' WHERE Id = :tempId';
        List<SObject> objs = Database.query(query);
        this.targetName = (String)objs[0].get('Name');
        NameCardListBuilder builder = null;
        // クエリラジオボタン表示フラグ
        isShowRadio = otype == Contact.sObjectType;
        if (otype == Account.sObjectType) {
          builder = new FromAccountBuilder();
        }
        else if (otype == Contact.sObjectType) {
          builder = new FromContactBuilder();
        }
        else {
          throw new SB_NC_UpdateByCardLcControllerException('Unsupported Object Record Selected !');
        }

        searchTypeSelectOpts = new List<Map<String, String>>();
        String str = NameCard__c.email__c.getDescribe().getLabel();
        //ラベル:姓名
        String str1 = NameCard__c.person_name_last__c.getDescribe().getLabel()
                + '、' + NameCard__c.person_name_first__c.getDescribe().getLabel();
        searchTypeSelectOpts.add(new Map<String, String> {'value' => '0', 'label' => str + System.Label.SB_NC_AND + str1, 'check' => 'true'});
        searchTypeSelectOpts.add(new Map<String, String> {'value' => '1', 'label' => str, 'check' => 'false'});
        searchTypeSelectOpts.add(new Map<String, String> {'value' => '2', 'label' => str1, 'check' => 'false'});

        this.cards = builder.build(targetId, searchType);
        this.success = true;
      }
      catch(Exception e) {
        //throw new SB_NC_UpdateByCardLcControllerException(e.getMessage());
        // AuraHandledException で 単純にスローすると、クライアント側でとれるメッセージは Script-thrown exception なので、正常に完了させて、エラーを伝える。
        this.success = false;
        this.error = e.getMessage();
      }
    }
  }

  //@RemoteAction
  //@AuraEnabled
  //public static GetNamecardsResponse getNamecards(Id targetId) {
  //  GetNamecardsResponse result = new GetNamecardsResponse();
  //  result.run(targetId);
  //  return result;
  //}
  @RemoteAction
  @AuraEnabled
  public static String getNamecards(Id targetId) {
    GetNamecardsResponse result = new GetNamecardsResponse();
    result.run(targetId);
    return JSON.serialize(result);
  }

  // ID から 候補となる 名刺のリストを取得する クラス用
  private interface NameCardListBuilder {
    List<Object> build(Id targetId, String searchType);
  }

  //  取引先責任者 から 名刺リスト
  private class FromContactBuilder implements NameCardListBuilder {
    public List<Object> build(Id cId, String searchType) {
      List<NameCard__c> sobjs = new List<NameCard__c>();
      System.debug('CID IS  :' + cId);

      // 2012.02.21 - 姓、名、メールアドレスが合致する名刺を表示

      Contact cobj = [SELECT FirstName, LastName, Email FROM Contact WHERE Id =:cId AND IsDeleted <> true];

      String query;
      // if (cobj.FirstName != null && cobj.LastName != null && cobj.Email != null) {
      String wher = '';
      String fname = cobj.FirstName;
      String lname = cobj.LastName;
      String email = cobj.Email;

      if (searchType == '0' && String.isNotBlank(email) && String.isNotBlank(lname) && String.isNotBlank(fname)) {
        wher = '(first_name__c=:fname OR person_name_first__c=:fname) '
                + 'AND (last_name__c=:lname OR person_name_last__c=:lname) '
                + 'AND email__c=:email';
      } else if (searchType == '1' && String.isNotBlank(email)) {
        wher = ' email__c=:email';
      } else if (searchType == '2'  && String.isNotBlank(lname) && String.isNotBlank(fname)) {
        wher = '(first_name__c=:fname OR person_name_first__c=:fname) '
                + 'AND (last_name__c=:lname OR person_name_last__c=:lname) ';
      }

      if (String.isNotBlank(wher)) {

        query = 'SELECT ' + SB_NC_NameCardDTO.NC_QUERY_FIELDS +
                ' FROM NameCard__c WHERE ' + wher + ' AND IsDeleted <> true' +
                ' ORDER BY card_exchange_date__c desc NULLS LAST limit 1001';
        sobjs = Database.query(query);

        if (sobjs.size() > 1000) {
          query = 'SELECT ' + SB_NC_NameCardDTO.NC_QUERY_FIELDS +
                  ' FROM NameCard__c WHERE ' + wher + ' AND Parent__c = null AND delivery_type__c != \'1\'' +
                  ' AND IsDeleted <> true';
          sobjs = Database.query(query);
        }
      }
      List<SB_NC_NameCardDTO> cards = new List<SB_NC_NameCardDTO>();
      for (NameCard__c card : sobjs) {
        SB_NC_NameCardDTO result = new SB_NC_NameCardDTO();
        result.bind(card);
        cards.add(result);
      }
      // }
      return cards;
    }
      //if (cobj.FirstName != null && cobj.LastName != null && cobj.Email != null) {
      // sobjs = [SELECT
      //   Account__r.Name, Contact__r.Name,
      //   Id, company_name__c, Name, division__c,
      //   title_name__c, person_name_last__c, person_name_first__c, last_name__c, first_name__c,
      //   zip_code__c, address_pref__c, address__c, address_bld__c,
      //   tel1__c, fax1__c, mobile__c, email__c, web_url1__c,
      //   LastModifiedDate, OwnerId, Owner.Name, card_exchange_date__c
      //   FROM NameCard__c WHERE (first_name__c=:cobj.FirstName OR person_name_first__c=:cobj.FirstName)
      //   AND (last_name__c=:cobj.LastName OR person_name_last__c=:cobj.LastName)
      //   AND email__c=:cobj.Email AND IsDeleted <> true
      //   ORDER BY card_exchange_date__c desc NULLS LAST limit 1001];

      // if (sobjs.size() > 1000) {
      //  sobjs = [SELECT
      //    Account__r.Name, Contact__r.Name,
      //    Id, company_name__c, Name, division__c,
      //    title_name__c, person_name_last__c, person_name_first__c, last_name__c, first_name__c,
      //    zip_code__c, address_pref__c, address__c, address_bld__c,
      //    tel1__c, fax1__c, mobile__c, email__c, web_url1__c,
      //    LastModifiedDate, OwnerId, Owner.Name, card_exchange_date__c
      //    FROM NameCard__c WHERE (first_name__c=:cobj.FirstName OR person_name_first__c=:cobj.FirstName)
      //    AND (last_name__c=:cobj.LastName OR person_name_last__c=:cobj.LastName)
      //    AND email__c=:cobj.Email AND Parent__c = null AND delivery_type__c != '1'
      //    AND IsDeleted <> true];
      //}
      //}

      //if (sobjs == null)
      //sobjs = new List<NameCard__c>();

      //return sobjs;
    //}
  }

  // 名刺リスト 取引先
  //  取引先責任者 から 名刺リスト
  private class FromAccountBuilder implements NameCardListBuilder {
    public List<Object> build(Id aId, String searchType) {
      List<NameCard__c> sobjs = new List<NameCard__c>();
      System.debug('AID IS  :' + aId);
      // 2012.02.21 - 会社名が合致する名刺を表示
      Account aobj = [SELECT Name FROM Account WHERE Id =:aId AND IsDeleted <> true];

      String query;
      if (aobj.Name != null) {
        String name = aobj.Name;
        query = 'SELECT ' + SB_NC_NameCardDTO.NC_QUERY_FIELDS +
                ' FROM NameCard__c WHERE company_name__c=:name AND IsDeleted <> true' +
                ' ORDER BY card_exchange_date__c desc NULLS LAST limit 1001';
        sobjs = Database.query(query);

        if (sobjs.size() > 1000) {
          query = 'SELECT ' + SB_NC_NameCardDTO.NC_QUERY_FIELDS +
            ' FROM NameCard__c WHERE company_name__c=:aobj.Name AND Parent__c = null AND delivery_type__c != \'1\'' +
            ' AND IsDeleted <> true' +
            ' ORDER BY card_exchange_date__c desc NULLS LAST limit 1001';
          sobjs = Database.query(query);

          if (sobjs.size() > 1000) {
            throw new SB_NC_UpdateByCardLcControllerException('検索件数が制限値（1000件）を超えました');
          }
        }
      }
      List<SB_NC_NameCardDTO> cards = new List<SB_NC_NameCardDTO>();
      for (NameCard__c card : sobjs) {
        SB_NC_NameCardDTO result = new SB_NC_NameCardDTO();
        result.bind(card);
        cards.add(result);
      }
      return cards;
    }
    //  if (aobj.Name != null) {
    //    sobjs = [SELECT
    //      Account__r.Name, Contact__r.Name,
    //      Id, company_name__c, Name, division__c,
    //      title_name__c, person_name_last__c, person_name_first__c, last_name__c, first_name__c,
    //      zip_code__c, address_pref__c, address__c, address_bld__c,
    //      tel1__c, fax1__c, mobile__c, email__c, web_url1__c,
    //      LastModifiedDate, OwnerId, Owner.Name, card_exchange_date__c
    //      FROM NameCard__c WHERE company_name__c=:aobj.Name AND IsDeleted <> true
    //      ORDER BY card_exchange_date__c desc NULLS LAST limit 1001];

    //    if (sobjs.size() > 1000) {
    //      sobjs = [SELECT
    //        Account__r.Name, Contact__r.Name,
    //        Id, company_name__c, Name, division__c,
    //        title_name__c, person_name_last__c, person_name_first__c, last_name__c, first_name__c,
    //        zip_code__c, address_pref__c, address__c, address_bld__c,
    //        tel1__c, fax1__c, mobile__c, email__c, web_url1__c,
    //        LastModifiedDate, OwnerId, Owner.Name, card_exchange_date__c
    //        FROM NameCard__c WHERE company_name__c=:aobj.Name AND Parent__c = null AND delivery_type__c != '1'
    //        AND IsDeleted <> true
    //        ORDER BY card_exchange_date__c desc NULLS LAST limit 1001];

    //      if (sobjs.size() > 1000) {
    //        throw new SB_NC_UpdateByCardLcControllerException('検索件数が制限値（1000件）を超えました');
    //      }
    //    }
    //  }

    //  if (sobjs == null)
    //  sobjs = new List<NameCard__c>();

    //  return sobjs;
    //}
  }

  //////////////// 更新処理 ////////////////
  public class UpdateByCardResponse {
    @AuraEnabled public Boolean success { get; private set; }
    @AuraEnabled public String error { get; private set; }
    @AuraEnabled public SObject target { get; private set; }
    private Id targetId;
    private Id cardId;
    // 処理実行
    public void run(Id targetId, Id cardId) {
      this.success = false;
      this.targetId = targetId;
      this.cardId = cardId;
      try {
        // 対象のオブジェクトのインスタンスを構築
        Schema.SObjectType otype = targetId.getSObjectType();
        SObjectUpdater updater = null;
        updater = new SObjectUpdater(targetId, cardId);
        this.target = updater.run();

        // コンタクトなら活動のWhoId にコンタクトID をセッにする。
        if (targetId.getSObjectType() == Contact.sObjectType) {
          activityProc();
        }

        this.success = true;
      }
      catch(Exception e) {
        //throw new AuraHandledException(e.getMessage());
        // AuraHandledException で 単純にスローすると、クライアント側でとれるメッセージは Script-thrown exception なので、正常に完了させて、エラーを伝える。
        this.success = false;
        this.error = e.getMessage();
      }
    }

    private void activityProc() {
      System.assertEquals(Contact.sObjectType, this.targetId.getSObjectType());
      // ToDo
      List<Task> tasks = [SELECT Id, WhoId FROM Task WHERE WhatId=:this.cardId AND WhoId=null];
      for (Task t : tasks) {
        t.WhoId = this.targetId;
      }
      SB_NameCard_CrudFls.supdate(tasks, true);
      // 行動
      List<Event> events = [SELECT Id, WhoId FROM Event WHERE WhatId=:this.cardId AND WhoId=null];
      for (Event e : events) {
        e.WhoId = this.targetId;
      }
      SB_NameCard_CrudFls.supdate(events, true);
    }

  }

  // 名刺のアカウントやコンタクトへの参照項目
  private static final Map<SObjectType, String> otype2RefField = new Map<SObjectType, String> {
    Account.sObjectType => 'account__c',
    Contact.sObjectType => 'contact__c'
  };

  //　対象のレコードを更新するクラス
  private virtual class SObjectUpdater {
    protected SB_NameCard_RenkeiMapper mapper;      //
    protected Id targetId;
    protected Id cardId;
    //
    public SObjectUpdater(Id targetId, Id cardId) {
      this.targetId = targetId;
      this.cardId = cardId;
      String obj_name = targetId.getSobjectType().getDescribe().getName();
      this.mapper = SB_NameCard_RenkeiMapper.getInstance(obj_name, false);
    }
    //
    public virtual SObject run() {
      SObject result;
      try {
        SB_NameCard_SaveResult dbError;
        // 対象のレコードを名刺の情報で更新
        NameCard__c card = getNameCard(cardId);
        result = this.mapper.updateRecord(card, targetId);
        dbError = dbupsert(result, false);
        if (dbError.isError()) {
          // エラー
          throw new SB_NC_UpdateByCardLcControllerException(dbError.getDbErrorHolder(0).text);
        }

        // 名刺の参照項目を更新
        String refField = otype2RefField.get(targetId.getSObjectType());
        card.put(refField, result.Id);
        dbError = dbupsert(card, false);
        if (dbError.isError()) {
          // エラー
          throw new SB_NC_UpdateByCardLcControllerException(dbError.getDbErrorHolder(0).text);
        }
      }
      catch(Exception e) {
        throw new SB_NC_UpdateByCardLcControllerException(e.getMessage());
      }
      return result;
    }

    // 更新処理
    // TODO 共通化する
    private SB_NameCard_SaveResult dbupsert(SObject obj, Boolean allowSave) {
      Database.DMLOptions dmlOptions = new Database.DMLOptions();
      dmlOptions.allowFieldTruncation = true;     // 文字列が長かったら詰める。
      dmlOptions.DuplicateRuleHeader.allowSave = allowSave;
      dmlOptions.DuplicateRuleHeader.runAsCurrentUser = true;
      List<Database.SaveResult> results = null;
      List<SObject> objs = new List<SObject>();
      if (obj.Id == null) {
        objs.add(obj);
        //result = Database.insert(obj, dmlOptions);
        results = SB_NameCard_CrudFls.screate(objs, dmlOptions);
      }
      else {
        objs.add(obj);
        //result = Database.update(obj, dmlOptions);
        results = SB_NameCard_CrudFls.supdate(objs, dmlOptions);
      }
      SB_NameCard_SaveResult dbError = new SB_NameCard_SaveResult();
      dbError.putSaveResults(results);
      return dbError;
    }

    // 選択した名刺の情報を取得
    private NameCard__c getNameCard(Id cardId) {
      NameCard__c sobj = null;
      String query = String.format(NAMECARD_QUERY_FROM, new String[] { String.join(new List<String>(this.mapper.getNameCardQueryFields()), ', '), ':cardId' });
      System.debug('+++getNameCard: ' + query);
      List<NameCard__c> sobjs = Database.query(query);
      return sobjs[0];
    }

  } //SObjectUpdater

  private static String NAMECARD_QUERY_FROM = 'SELECT {0} FROM NameCard__c WHERE Id = {1} AND IsDeleted <> true' ;

  //@RemoteAction
  //@AuraEnabled
  //public static UpdateByCardResponse updateByCard(Id targetId, Id cardId) {
  //  UpdateByCardResponse result = new UpdateByCardResponse();
  //  result.run(targetId, cardId);
  //  return result;
  //}
  @RemoteAction
  @AuraEnabled
  public static String updateByCard(Id targetId, Id cardId) {
    UpdateByCardResponse result = new UpdateByCardResponse();
    result.run(targetId, cardId);
    return JSON.serialize(result);
  }

  //////
  public class GetUserInfoResponse {
    @AuraEnabled public Boolean success { get; private set; }
    @AuraEnabled public String error { get; private set; }
    @AuraEnabled public User user { get; private set; }
    public GetUserInfoResponse(Id userId) {
      try {
        this.user = [SELECT Id, Name, Username, Email, Alias, CompanyName, Department, Division, Title, UserRole.Name FROM User WHERE Id = :userId LIMIT 1];
        this.success = true;
      }
      catch(Exception e) {
        this.success = false;
        this.error = e.getMessage();
      }
    }
  }


  //@RemoteAction
  //@AuraEnabled
  //public static GetUserInfoResponse getUserInfo(Id userId) {
  //  GetUserInfoResponse result = new GetUserInfoResponse(userId);
  //  return result;
  //}
  @RemoteAction
  @AuraEnabled
  public static String getUserInfo(Id userId) {
    GetUserInfoResponse result = new GetUserInfoResponse(userId);
    return JSON.serialize(result);
  }

  @RemoteAction
  @AuraEnabled
  public static String searchData(Id targetId, String searchType) {
    GetNamecardsResponse result = new GetNamecardsResponse();
    result.run(targetId, searchType);
    return JSON.serialize(result);
  }


    @RemoteAction
  @AuraEnabled
  /**
    * @description DataTable表示項目を取る
    * @return 画面表示項目リスト
  **/
  public static String getFieldList(Id targetId) {
    List<SB_NC_UpdateByCardDTO.DataTableColumnField> fieldList = new List<SB_NC_UpdateByCardDTO.DataTableColumnField>();
    fieldList.add(new SB_NC_UpdateByCardDTO.DataTableColumnField(NameCard__c.card_exchange_date__c.getDescribe().getLabel(), 'card_exchange_date', 'date'));
    fieldList.add(new SB_NC_UpdateByCardDTO.DataTableColumnField(System.Label.SB_NC_Owner, 'ownerName', 'text'));
    fieldList.add(new SB_NC_UpdateByCardDTO.DataTableColumnField(NameCard__c.company_name__c.getDescribe().getLabel(), 'company_name', 'text'));
    // fieldList.add(new SB_NC_UpdateByCardDTO.DataTableColumnField(NameCard__c.address_pref__c.getDescribe().getLabel(), 'displayAddress', 'text'));
    fieldList.add(new SB_NC_UpdateByCardDTO.DataTableColumnField(NameCard__c.division__c.getDescribe().getLabel(), 'division', 'text'));
    fieldList.add(new SB_NC_UpdateByCardDTO.DataTableColumnField(NameCard__c.title_name__c.getDescribe().getLabel(), 'title_name', 'text'));
    SB_NC_UpdateByCardDTO.DataTableColumnField urlB = new SB_NC_UpdateByCardDTO.DataTableColumnField(NameCard__c.Name.getDescribe().getLabel(), 'LINK', 'url');
    urlB.setURLLabel('name');
    fieldList.add(urlB);
    fieldList.add(new SB_NC_UpdateByCardDTO.DataTableColumnField(NameCard__c.address__c.getDescribe().getLabel(), 'displayAddress', 'text'));
    fieldList.add(new SB_NC_UpdateByCardDTO.DataTableColumnField(NameCard__c.tel1__c.getDescribe().getLabel(), 'tel1', 'text'));
    fieldList.add(new SB_NC_UpdateByCardDTO.DataTableColumnField(NameCard__c.email__c.getDescribe().getLabel(), 'email', 'text'));
    SB_NC_UpdateByCardDTO.DataTableColumnField button = new SB_NC_UpdateByCardDTO.DataTableColumnField(System.Label.SB_NC_UpdateUsingCardInfo, System.Label.SB_NC_UpdateUsingCardInfo, 'button');
    SB_NC_UpdateByCardDTO.Button b = new SB_NC_UpdateByCardDTO.Button();
    b.label = System.Label.SB_NC_UpdateUsingCardInfo;
    button.typeAttributes = b;
    fieldList.add(button);
    return JSON.serialize(fieldList);
  }


  @RemoteAction
  @AuraEnabled
  /**
    * @description SB基本設定データを取得
    * 検索条件の変更などないので、検索用のメソッドは作成しません
    * @param targetId リードID
    * @return 画面表示Datejson
  **/
  public static String getUpdateByCard(Id targetId, String searchType) {
    GetNamecardsResponse result = new GetNamecardsResponse();
    result.run(targetId, String.isBlank(searchType) ? '0' : searchType);

    SB_NC_UpdateByCardDTO ba = new SB_NC_UpdateByCardDTO();
    ba.titleV.titleName = System.Label.SB_NC_CardList;
    if (targetId.getSObjectType() == Contact.sObjectType) {
      ba.titleV.iconName = 'standard:contact';
    }
    else {
      ba.titleV.iconName = 'standard:account';
    }
    ba.titleV.iconSize = 'large';
    ba.titleV.closeValue = System.Label.SB_NC_Label_Close;
    // Lead pageLead = getLead(targetId);
    ba.dataList = result.cards;
    ba.titleV.linkName = result.targetName;
    return JSON.serialize(ba);
  }


    @RemoteAction
  @AuraEnabled
  /**
    * @description DataTable表示項目を取る
    * @return 画面表示項目リスト
  **/
  public static String getInputValue(Id targetId) {
    NameCardBasicSetting__c baseSetting = SB_NameCard_BasicSetting.getNameCardBasicSetting();
    SB_NC_UpdateByCardDTO.InputValue inputV = new SB_NC_UpdateByCardDTO.InputValue();
    // inputV.checkboxLabel = String.format(System.Label.SB_NCLD_Label_OverwriteLeadInfoDEV, new String[]{Lead.sObjectType.getDescribe().getLabel()});
    inputV.radioTitle = System.Label.SB_NC_SearchCondition;
    inputV.radioValue = '0';
    if (targetId.getSObjectType() == Contact.sObjectType) {
      String str = NameCard__c.email__c.getDescribe().getLabel();
      //ラベル:姓名
      String str1 = NameCard__c.person_name_last__c.getDescribe().getLabel()
              + '、' + NameCard__c.person_name_first__c.getDescribe().getLabel();
      inputV.searchTypeSelectOpts.add(new SB_NC_UpdateByCardDTO.LabelValue(str + System.Label.SB_NC_AND + str1, '0'));
      inputV.searchTypeSelectOpts.add(new SB_NC_UpdateByCardDTO.LabelValue(str, '1'));
      inputV.searchTypeSelectOpts.add(new SB_NC_UpdateByCardDTO.LabelValue(str1, '2'));
      // inputV.checkboxValue = !baseSetting.ficuspop__RegistLeadNotOverWrite__c && Lead.SObjectType.getDescribe().isUpdateable();
    }
    return JSON.serialize(inputV);
  }

}