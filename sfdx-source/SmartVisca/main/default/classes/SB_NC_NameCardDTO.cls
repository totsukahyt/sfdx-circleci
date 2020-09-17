/**
 *
 * SB_NC_NameCardDTO
 *   Lightning Express 対応 名刺レコードを 名前空間プレフィクスなしで扱えるようのクラス
 *
 * Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2017.02.xx
 *
 *  @Version 2.4    2019.05.24 SV_DEV-1794 S1 新SmartViscaタブ：名刺情報の編集画面で「Unknown field: SmartViscaf.SB_NC_NameCardDTO.currencyIsoCode」エラーになる（Salesforceのマルチ通貨の有効環境）
 *
 **/
public with sharing class SB_NC_NameCardDTO extends SB_NC_DTO implements Comparable {
  public class SB_NC_NameCardDTOException extends Exception {}

  public static final String NC_QUERY_SIMPLE_FIELDS = 'Id, Name, Parent__c, name_kana__c'  +
              ', account__c, contact__c' +
              //', Account__r.Name, Contact__r.Name' +
              ', company_name__c, company_name_kana__c, division__c, title_name__c' +
              ', zip_code__c, address_pref__c, address__c, address_bld__c, address_eng__c' +
              ', last_name__c, first_name__c, person_name_last__c, person_name_first__c' +
              ', email__c, tel1__c, fax1__c, mobile__c, Web_url1__c' +
              //', image_id__c, width__c, height__c, bk_image_id__c, bk_width__c, bk_height__c' +
              //', list_name__c, freehandmemo__c, memo__c' +
              ', isNotOverwrite__c, isNotOverContactwrite__c' +
              ', LastModifiedDate, card_exchange_date__c, OwnerId, Owner.Name';

  public static final String NC_QUERY_FIELDS = 'Id, Name, Parent__c, name_kana__c'  +
              ', account__c, contact__c' +
              ', Account__r.Name, Contact__r.Name' +
              ', company_name__c, company_name_kana__c, division__c, title_name__c' +
              ', zip_code__c, address_pref__c, address__c, address_bld__c, address_eng__c' +
              ', last_name__c, first_name__c, person_name_last__c, person_name_first__c' +
              ', email__c, tel1__c, fax1__c, mobile__c, Web_url1__c' +
              ', image_id__c, width__c, height__c, bk_image_id__c, bk_width__c, bk_height__c' +
              ', list_name__c, freehandmemo__c, memo__c' +
              ', isNotOverwrite__c, isNotOverContactwrite__c' +
              ', LastModifiedDate, card_exchange_date__c, OwnerId, Owner.Name' +
              // v2.1 以降を追加
              ', lead__c, lead__r.Name' +
              ', middle_name__c, person_name_last_kana__c, person_name_first_kana__c' +
              ', tel2__c, fax2__c, web_url2__c, tenshokuzumi__c, tenshokugonomeishi__c';

  public static final String USER_QUERY_FIELDS  = 'Id, Name, CompanyName, Country, Department, Email, Phone, Fax, EmployeeNumber' +
              // ', FullPhotoUrl' +
              // これ以降は V2.1 で追加
              ', Alias, City,  Division, FirstName, IsActive' +
              ', LanguageLocaleKey, LastName, PostalCode, State, Street, Title, TimeZoneSidKey, Username';

      // + (enableFeedItem == true ? ', FullPhotoUrl' : '')         // Chatter が無効だと 項目

  // public static Set<String> user_query_fields  {
  //   get {
  //     if (user_query_fields == null) {
  //       user_query_fields = new Set<String>();
  //       Set<>
  //     Map<String, Schema.SObjectField > fields = User.getSObjectType().getDescribe().fields.getMap();
  //     for(Schema.SObjectField f : fields.values()) {
  //       Schema.DescribeFieldResult dfr = f.getDescribe();
  //       if (!dfr.isCustom() && dfr.isAccessible() &&
  //           (dfr.getSoapType()== Schema.SOAPType.String || dfr.getSoapType()== Schema.SOAPType.Integer)) {
  //         user_query_fields.add(dfr.getName());
  //       }
  //     }
  //       user_query_fields.add('Id');
  //       user_query_fields.add('Name');
  //     }
  //     return user_query_fields;
  //   }
  // }
  @AuraEnabled @TestVisible public String id { get; private set; }              // レコードID
  @AuraEnabled @TestVisible public String parentId { get; private set; }      // 最新の名刺
  @AuraEnabled @TestVisible public String name { get; private set; }            // 氏名
  @AuraEnabled @TestVisible public String company_name { get; private set; }    // 会社名
  @AuraEnabled @TestVisible public String company_name_kana { get; private set; }
  @AuraEnabled @TestVisible public String division { get; private set; }
  @AuraEnabled @TestVisible public String title_name { get; private set; }
  @AuraEnabled @TestVisible public String person_name_last { get; private set; }
  @AuraEnabled @TestVisible public String person_name_first { get; private set; }
  @AuraEnabled @TestVisible public String name_kana { get; private set; }
  @AuraEnabled @TestVisible public DateTime lastModifiedDate { get; private set; }
  @AuraEnabled @TestVisible public String ownerId { get; private set; }
  @AuraEnabled @TestVisible public String ownerName { get; private set; }
  @AuraEnabled @TestVisible public Date card_exchange_date { get; private set; }
  @AuraEnabled @TestVisible public String zip_code { get; private set; }
  @AuraEnabled @TestVisible public String address_pref { get; private set; }
  @AuraEnabled @TestVisible public String address { get; private set; }
  @AuraEnabled @TestVisible public String address_bld { get; private set; }
  @AuraEnabled @TestVisible public String address_eng { get; private set; }
  @AuraEnabled @TestVisible public String displayAddress { get; private set; }   // 表示用に連結した住所
  @AuraEnabled @TestVisible public String tel1 { get; private set; }
  @AuraEnabled @TestVisible public String fax1 { get; private set; }
  @AuraEnabled @TestVisible public String mobile { get; private set; }
  @AuraEnabled @TestVisible public String email { get; private set; }
  @AuraEnabled @TestVisible public String web_url1 { get; private set; }
  @AuraEnabled @TestVisible public Boolean isNotOverwrite { get; private set; }  // 上書き不可
  @AuraEnabled @TestVisible public Boolean isNotOverContactwrite { get; private set; } // コンタクト上書き不可
  @AuraEnabled @TestVisible public String accountId { get; private set; }
  @AuraEnabled @TestVisible public String contactId { get; private set; }
  @AuraEnabled @TestVisible public String account { get; private set; } // v2.1
  @AuraEnabled @TestVisible public String contact { get; private set; } // v2.1
  // 　以下Simple だとない
  @AuraEnabled @TestVisible public String accountName { get; private set; }
  @AuraEnabled @TestVisible public String contactName { get; private set; }
  @AuraEnabled @TestVisible public String image_id { get; private set; }
  @AuraEnabled @TestVisible public Integer width { get; private set; }
  @AuraEnabled @TestVisible public Integer height { get; private set; }
  @AuraEnabled @TestVisible public String bk_image_id { get; private set; }
  @AuraEnabled @TestVisible public Integer bk_width { get; private set; }
  @AuraEnabled @TestVisible public Integer bk_height { get; private set; }
  @AuraEnabled @TestVisible public String list_name { get; private set; }
  @AuraEnabled @TestVisible public String freehandmemo { get; private set; }
  @AuraEnabled @TestVisible public String memo { get; private set; }
  @AuraEnabled @TestVisible public Boolean saishin { get; private set; } // 2017.03.xx
  @AuraEnabled @TestVisible public Integer status { get; private set; }         // -1 : ? 0:最新 1: 古い 2: 転職前 3: 転職後 4:同姓同名 同メアド
  // public String photo { get; private set; }
  @AuraEnabled @TestVisible public User owner { get; private set; }             // 所有者のユーザレコード 詳細画面で表示する用
  // 以下は v2.1  から
  @AuraEnabled @TestVisible public String leadId { get; private set; }
  @AuraEnabled @TestVisible public String lead { get; private set; } //
  @AuraEnabled @TestVisible public String leadName { get; private set; }
  @AuraEnabled @TestVisible public String first_name { get; private set; }
  @AuraEnabled @TestVisible public String middle_name { get; private set; }
  @AuraEnabled @TestVisible public String last_name { get; private set; }
  @AuraEnabled @TestVisible public String person_name_last_kana { get; private set; }
  @AuraEnabled @TestVisible public String person_name_first_kana { get; private set; }
  @AuraEnabled @TestVisible public String tel2 { get; private set; }
  @AuraEnabled @TestVisible public String fax2 { get; private set; }
  @AuraEnabled @TestVisible public String web_url2 { get; private set; }
  @AuraEnabled @TestVisible public Boolean tenshokuzumi { get; private set; }
  @AuraEnabled @TestVisible public String parent { get; private set; } // Parent__c をクエリしてるので、parent が戻ってくるので、
  @AuraEnabled @TestVisible public String tenshokugonomeishi { get; private set; } // tenshokugonomeishi__c をクエリしてるので、tenshokugonomeishi が戻ってくるので、
  @AuraEnabled @TestVisible public Boolean latest { get; private set; } // SV_DEV-1437 モバイル新UI 一覧「この名刺データは最新ではありません」が名刺詳細で履歴を表示した場合にしか表示されない

  public void setStatus(integer s) {
    this.status = s;
  }
  public void setOwner(User u) {
    this.owner = u;
  }

  // 表示用に連結した住所
  private String getDisplayAddress(NameCard__c card) {
    return String.isNotBlank(card.address__c) ?
              ((String.isNotBlank(card.zip_code__c) ? card.zip_code__c + ' ' : '')  +
              (String.isNotBlank(card.address_pref__c) ? card.address_pref__c + ' ' : '') +
              card.address__c +
              (String.isNotBlank(card.address_bld__c) ? ' ' + card.address_bld__c : '')) :
              (String.isNotBlank(card.address_eng__c) ? card.address_eng__c : '');
  }

  // 表示用に連結した住所 それぞれ値を抜いたあとによばれる前提。
  private String getDisplayAddress() {
    return String.isNotBlank(this.address) ?
              ((String.isNotBlank(this.zip_code) ? this.zip_code + ' ' : '')  +
              (String.isNotBlank(this.address_pref) ? this.address_pref + ' ' : '') +
              this.address +
              (String.isNotBlank(this.address_bld) ? ' ' + this.address_bld : '')) :
              (String.isNotBlank(this.address_eng) ? this.address_eng : '');
  }

  public SB_NC_NameCardDTO() {
  }

  public SB_NC_NameCardDTO(SObject obj) {
    System.assert(obj != null);
    System.assert(obj.getSObjectType() == NameCard__c.sObjectType);
    bindPopulatedFields(obj);
  }
  // public void setLastModifiedDate(DateTime dt) {
  //   this.lastModifiedDate = dt;
  // }
  private void bindPopulatedFields(SObject obj) {
    Set<String> fields = obj.getPopulatedFieldsAsMap().keySet();
    NameCard__c card = (NameCard__c)obj;
    String ns = SB_NameCard_Util.getNamespacePrefix_x();    // 名前空間名プレフィクス
    this.id = card.Id;
    this.name = card.Name;
    this.parentId = fields.contains(ns + 'Parent__c') ? card.Parent__c : null;
    this.company_name = fields.contains(ns + 'company_name__c') ? card.company_name__c : null;
    this.company_name_kana = fields.contains(ns + 'company_name_kana__c') ? card.company_name_kana__c : null;
    this.division = fields.contains(ns + 'division__c') ? card.division__c : null;
    this.title_name = fields.contains(ns + 'title_name__c') ? card.title_name__c : null;
    this.person_name_last = fields.contains(ns + 'person_name_last__c') ? card.person_name_last__c : null;
    this.person_name_first = fields.contains(ns + 'person_name_first__c') ? card.person_name_first__c : null;
    this.name_kana = fields.contains(ns + 'name_kana__c') ? card.name_kana__c : null;
    this.lastModifiedDate = fields.contains('LastModifiedDate') ? card.LastModifiedDate : null;
    this.ownerId = fields.contains('OwnerId') ? card.OwnerId : null;
    this.ownerName = fields.contains('Owner') ? card.Owner.Name : null;     // Nameはある前庭で
    this.card_exchange_date = fields.contains(ns + 'card_exchange_date__c') ? card.card_exchange_date__c : null;       // 名刺交換 : null日
    this.zip_code = fields.contains(ns + 'zip_code__c') ? card.zip_code__c : null;
    this.address_pref = fields.contains(ns + 'address_pref__c') ? card.address_pref__c : null;
    this.address = fields.contains(ns + 'address__c') ? card.address__c : null;
    this.address_bld = fields.contains(ns + 'address_bld__c') ? card.address_bld__c : null;
    this.address_eng = fields.contains(ns + 'address_eng__c') ? card.address_eng__c : null;
    this.displayAddress = getDisplayAddress();   // 表示用に連結した住所
    this.tel1 = fields.contains(ns + 'tel1__c') ? card.tel1__c : null;
    this.fax1 = fields.contains(ns + 'fax1__c') ? card.fax1__c : null;
    this.mobile = fields.contains(ns + 'mobile__c') ? card.mobile__c : null;
    this.email = fields.contains(ns + 'email__c') ? card.email__c : null;
    this.web_url1 = fields.contains(ns + 'Web_url1__c') ? card.Web_url1__c : null;
    this.isNotOverwrite = fields.contains(ns + 'isNotOverwrite__c') ? card.isNotOverwrite__c : null;     // 上書き不可
    this.isNotOverContactwrite = fields.contains(ns + 'isNotOverContactwrite__c') ? card.isNotOverContactwrite__c : null;  // コンタクト上書き不 : null可
    this.accountId = fields.contains(ns + 'account__c') ? card.account__c : null;
    this.contactId = fields.contains(ns + 'contact__c') ? card.contact__c : null;
    this.account = fields.contains(ns + 'account__c') ? card.account__c : null;
    this.contact = fields.contains(ns + 'contact__c') ? card.contact__c : null;
    // 以下は SIMPLEじゃないものたち
    this.accountName = fields.contains(ns + 'account__r') ? card.account__r.Name : null;   // Nameはある前庭で
    this.contactName = fields.contains(ns + 'contact__r') ? card.contact__r.Name : null;   // Nameはある前庭で
    this.image_id = fields.contains(ns + 'image_id__c') ? card.image_id__c : null;
    this.width = fields.contains(ns + 'width__c') ?  card.width__c.intValue() : null;
    this.height = fields.contains(ns + 'height__c') ? card.height__c.intValue() : null;
    this.bk_image_id = fields.contains(ns + 'bk_image_id__c') ? card.bk_image_id__c : null;
    this.bk_width = fields.contains(ns + 'bk_width__c') ? card.bk_width__c.intValue() : null;
    this.bk_height = fields.contains(ns + 'bk_height__c') ? card.bk_height__c.intValue() : null;
    this.list_name = fields.contains(ns + 'list_name__c') ? card.list_name__c : null;
    this.freehandmemo = fields.contains(ns + 'freehandmemo__c') ? card.freehandmemo__c : null;
    this.memo = fields.contains(ns + 'memo__c') ? card.memo__c : null;
    this.saishin = fields.contains(ns + 'Saishin__c') ? card.Saishin__c : null;
    // v2.1
    this.leadId = fields.contains(ns + 'lead__c') ? card.lead__c : null;
    this.lead = fields.contains(ns + 'lead__c') ? card.lead__c : null;
    this.leadName = fields.contains(ns + 'lead__r') ? card.lead__r.Name : null;
    this.first_name = fields.contains(ns + 'first_name__c') ? card.first_name__c : null;
    this.middle_name = fields.contains(ns + 'middle_name__c') ? card.middle_name__c : null;
    this.last_name = fields.contains(ns + 'last_name__c') ? card.last_name__c : null;
    this.person_name_last_kana = fields.contains(ns + 'person_name_last_kana__c') ? card.person_name_last_kana__c : null;
    this.person_name_first_kana = fields.contains(ns + 'person_name_first_kana__c') ? card.person_name_first_kana__c : null;
    this.tel2 = fields.contains(ns + 'tel2__c') ? card.tel2__c : null;
    this.fax2 = fields.contains(ns + 'fax2__c') ? card.fax2__c : null;
    this.web_url2 = fields.contains(ns + 'web_url2__c') ? card.web_url2__c : null;
    this.tenshokuzumi = fields.contains(ns+ 'tenshokuzumi__c') ? card.tenshokuzumi__c : null;
    this.latest = this.parentId == null;
  }

  private static Map<String, String> convertKeys = new Map<String, String> {
    'owner' => 'ownerId',
    'parent' => 'parentId'
  };

  private static Map<String, List<String>> referenceKeys = new Map<String, List<String>> {
    'account__r' => new List<String> {'accountId', 'accountName'},
    'contact__r' => new List<String> {'contactId', 'contactName'},
    'lead__r' => new List<String> {'leadId', 'leadName'}
  };

  // 2019.05.24 SV_DEV-1794 S1 新SmartViscaタブ：名刺情報の編集画面で「Unknown field: SmartViscaf.SB_NC_NameCardDTO.currencyIsoCode」エラーになる（Salesforceのマルチ通貨の有効環境）
  // 転送しない項目 Setでもっとく
  private static final Set<String> IGNORE_FIELDS = new Set<String> {  
    'lastmodifieddate',
    'currencyisocode'  // マルチ通貨 有効化 組織だけ SObject にはいってくる。
  };

  public static Map<String, Object> buildNomalizeKeyMap(SObject obj) {
    Map<String, Object> result = new Map<String, Object>();
    String ns = SB_NameCard_Util.getNamespacePrefix_x();    // 名前空間名プレフィクス
    Map<String, Object> fields = obj.getPopulatedFieldsAsMap();
    for (String apiName : fields.keySet()) {
      System.debug('apiName: ' + apiName);
      if (IGNORE_FIELDS.contains(apiName.toLowerCase())) { // 転送不用の項目？ 2019.05.24
        continue;
      }
      if (apiName.endsWithIgnoreCase('__r') && referenceKeys.containsKey(apiName.removeStartIgnoreCase(ns))) {
        SObject refObj = obj.getSObject(apiName.removeStartIgnoreCase(ns));
        List<String> refFields = referenceKeys.get(apiName.removeStartIgnoreCase(ns).toLowerCase());
        result.put(refFields[0], refObj.Id);
        result.put(refFields[1], refObj.get('Name'));
      }
      else {
        String key = apiName.removeEnd('__c').removeStartIgnoreCase(ns);
        key = key.left(1).toLowerCase() + key.substring(1);
        result.put(key, fields.get(apiName));
        if (convertKeys.containsKey(key)) {
          result.put(convertKeys.get(key), fields.get(apiName));
        }
      }
    }
    // 最新の名刺 は 最新の名刺 参照がない
    result.put('latest', !result.containsKey('parentId'));
    return result;
  }

  //public override void bind(SObject obj) {
  //}

  public void bind(NameCard__c card) {
    this.id = card.Id;
    this.name = card.Name;
    this.parentId = card.Parent__c;
    this.company_name = card.company_name__c;
    this.company_name_kana = card.company_name_kana__c;
    this.division = card.division__c;
    this.title_name = card.title_name__c;
    this.person_name_last = card.person_name_last__c;
    this.person_name_first = card.person_name_first__c;
    this.name_kana = card.name_kana__c;
    this.lastModifiedDate = card.LastModifiedDate;
    this.ownerId = card.OwnerId;
    this.ownerName = card.Owner.Name;
    this.card_exchange_date = card.card_exchange_date__c;       // 名刺交換日
    this.zip_code = card.zip_code__c;
    this.address_pref = card.address_pref__c;
    this.address = card.address__c;
    this.address_bld = card.address_bld__c;
    this.address_eng = card.address_eng__c;
    this.displayAddress = getDisplayAddress(card);   // 表示用に連結した住所
    this.tel1 = card.tel1__c;
    this.fax1 = card.fax1__c;
    this.mobile = card.mobile__c;
    this.email = card.email__c;
    this.web_url1 = card.Web_url1__c;
    this.isNotOverwrite = card.isNotOverwrite__c;     // 上書き不可
    this.isNotOverContactwrite = card.isNotOverContactwrite__c;  // コンタクト上書き不可
    this.accountId = card.account__c;
    this.contactId = card.contact__c;
    this.account = card.account__c;
    this.contact = card.contact__c;
    // 以下は SIMPLEじゃないのである
    this.accountName = card.account__r.Name;
    this.contactName = card.contact__r.Name;
    this.image_id = card.image_id__c;
    this.width = card.width__c != null ? card.width__c.intValue() : 0;
    this.height = card.height__c != null ? card.height__c.intValue() : 0;
    this.bk_image_id = card.bk_image_id__c;
    this.bk_width = card.bk_width__c != null ? card.bk_width__c.intValue() : 0;
    this.bk_height = card.bk_height__c != null ? card.bk_height__c.intValue() : 0;
    this.list_name = card.list_name__c;
    this.freehandmemo = card.freehandmemo__c;
    this.memo = card.memo__c;
    // v2.1
    this.leadId = card.lead__c;
    this.lead = card.lead__c;
    this.leadName = card.lead__r.Name;
    this.first_name = card.first_name__c;
    this.middle_name = card.middle_name__c;
    this.last_name = card.last_name__c;
    this.person_name_last_kana = card.person_name_last_kana__c;
    this.person_name_first_kana = card.person_name_first_kana__c;
    this.tel2 = card.tel2__c;
    this.fax2 = card.fax2__c;
    this.web_url2 = card.web_url2__c;
    this.tenshokuzumi = card.tenshokuzumi__c;
    this.latest = this.parentId == null;
  }

  // SB_NameCard_SController.NameCardDTO から こっちに移行したけど、そっちでは lastModifiedDate をわたしてなかった。
  // DateTime は RemoteAction の引数の中になったとき、デシリアライズできないので、saveNameCard でもどされるとエラーになるので、抜く
  public void bind_nullDatetime(NameCard__c card) {
    bind(card);
    this.lastModifiedDate = null;
  }

  public void bindSimple(NameCard__c card) {
    //NameCard__c card = (NameCard__c)obj;
    this.id = card.Id;
    this.name = card.Name;
    this.parentId = card.Parent__c;
    this.company_name = card.company_name__c;
    this.company_name_kana = card.company_name_kana__c;
    this.division = card.division__c;
    this.title_name = card.title_name__c;
    this.person_name_last = card.person_name_last__c;
    this.person_name_first = card.person_name_first__c;
    this.name_kana = card.name_kana__c;
    this.ownerId = card.OwnerId;
    this.ownerName = card.Owner.Name;
    this.card_exchange_date = card.card_exchange_date__c;       // 名刺交換日
    this.zip_code = card.zip_code__c;
    this.address_pref = card.address_pref__c;
    this.address = card.address__c;
    this.address_bld = card.address_bld__c;
    this.address_eng = card.address_eng__c;
    this.displayAddress = getDisplayAddress(card);   // 表示用に連結した住所
    this.tel1 = card.tel1__c;
    this.fax1 = card.fax1__c;
    this.mobile = card.mobile__c;
    this.email = card.email__c;
    this.web_url1 = card.Web_url1__c;
    this.account = card.account__c;
    this.contact = card.contact__c;
    //  v2.1
    this.latest = this.parentId == null;
    // 以下は SIMPLEではない
    //this.accountName = card.account__r.Name;
    //this.contactName = card.contact__r.Name;
    //this.image_id = card.image_id__c;
    //this.width = card.width__c != null ? card.width__c.intValue() : 0;
    //this.height = card.height__c != null ? card.height__c.intValue() : 0;
    //this.bk_image_id = card.bk_image_id__c;
    //this.bk_width = card.bk_width__c != null ? card.bk_width__c.intValue() : 0;
    //this.bk_height = card.bk_height__c != null ? card.bk_height__c.intValue() : 0;
    //this.list_name = card.list_name__c;
    //this.freehandmemo = card.freehandmemo__c;
    //this.memo = card.memo__c;
  }

  public SObject createSObject() {
    NameCard__c result = (NameCard__c)NameCard__c.sObjectType.newSObject();
    result.Id = this.id;
    // result.Name = this.name;
    // result.Parent__c = this.parentId;
    result.company_name__c = this.company_name;
    result.company_name_kana__c = this.company_name_kana;
    result.division__c = this.division;
    result.title_name__c = this.title_name;
    result.person_name_last__c = this.person_name_last;
    result.person_name_first__c = this.person_name_first;
    // result.name_kana__c = this.name_kana;
    // result.LastModifiedDate = this.lastModifiedDate;
    // result.OwnerId = this.ownerId;
    // result.Owner = this.ownerName.Name;
    // result.card_exchange_date__c = this.card_exchange_date;       // 名刺交換日
    result.zip_code__c = this.zip_code;
    result.address_pref__c = this.address_pref;
    result.address__c = this.address;
    result.address_bld__c = this.address_bld;
    result.address_eng__c = this.address_eng;
    result.tel1__c = this.tel1;
    result.fax1__c = this.fax1;
    result.mobile__c = this.mobile;
    result.email__c = this.email;
    result.Web_url1__c = this.web_url1;
    // result.isNotOverwrite__c = this.isNotOverwrite;     // 上書き不可
    // result.isNotOverContactwrite__c = this.isNotOverContactwrite;  // コンタクト上書き不可
    // result.account__c = this.account;
    // result.contact__c = this.contact;
    // 以下は SIMPLEじゃないのである
    // result.account__r = this.accountName.Name;
    // result.contact__r = this.contactName.Name;
    // result.image_id__c = this.image_id;
    // result.width__c = this.width;
    // result.height__c = this.height;
    // result.bk_image_id__c = this.bk_image_id;
    // result.bk_width__c = this.bk_width;
    // result.bk_height__c = this.bk_height;
    result.list_name__c = this.list_name;
    result.freehandmemo__c = this.freehandmemo;
    result.memo__c = this.memo;
    // v2.1
    // result.lead__c = this.lead;
    // result.lead__r = this.leadName;
    result.first_name__c = this.first_name;
    result.middle_name__c = this.middle_name;
    result.last_name__c = this.last_name;
    result.person_name_last_kana__c = this.person_name_last_kana;
    result.person_name_first_kana__c = this.person_name_first_kana;
    result.tel2__c = this.tel2;
    result.fax2__c = this.fax2;
    result.web_url2__c = this.web_url2;
    // result.tenshokuzumi__c = this.tenshokuzumi;
    return result;
  }

  //// 1つ検索
  //public static SB_NC_NameCardDTO getNameCard(String targetId) {
  //  SB_NC_NameCardDTO result;
  //  String query = 'SELECT '+ NC_QUERY_FIELDS + ' FROM NameCard__c WHERE Id = :targetId';
  //  List<NameCard__c> cards = Database.query(query);      // 照会実施
  //  if (cards.isEmpty()) {
  //    throw new SB_NC_NameCardDTOException(Label.SB_MSG_IllegalRequest + 'Id : ' + targetId);
  //  }
  //  result = new SB_NC_NameCardDTO();
  //  result.bind(cards[0]);
  //  return result;
  //}
  public Integer compareTo(Object compareTo) {
    SB_NC_NameCardDTO other = (SB_NC_NameCardDTO)compareTo;
    if (card_exchange_date ==  other.card_exchange_date) return 0;
    else if (card_exchange_date > other.card_exchange_date) return -1;
    else return 1;
  }

  public static List<SB_NC_NameCardDTO> createNameCardDto(List<NameCard__c> cards) {
    List<SB_NC_NameCardDTO> result = new List<SB_NC_NameCardDTO>();
    for (NameCard__c card : cards) {
      SB_NC_NameCardDTO dto = new SB_NC_NameCardDTO();
      dto.bindSimple(card);
      result.add(dto);
    }
    return result;
  }
}