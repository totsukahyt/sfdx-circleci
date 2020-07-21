/**
 *
 * SB_NCL_NameCardDTO
 *    基本 v2.0.1 SB_NC_NameCardDTO から流用
 *   Lightning Express 対応 名刺レコードを 名前空間プレフィクスなしで扱えるようのクラス
 *
 * Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2017.02.xx
 *  SB_NCL_NameCardDTO
 *
 **/
public with sharing class SB_NCL_NameCardDTO  {
  public class SB_NC_NameCardDTOException extends Exception {}

  public static final String NC_QUERY_SIMPLE_FIELDS = 'Id, Name, SmartViscaf__Parent__c, SmartViscaf__name_kana__c'  +
              ', SmartViscaf__account__c, SmartViscaf__contact__c' +
              //', SmartViscaf__Account__r.Name, SmartViscaf__Contact__r.Name' +
              ', SmartViscaf__company_name__c, SmartViscaf__company_name_kana__c, SmartViscaf__division__c, SmartViscaf__title_name__c' +
              ', SmartViscaf__zip_code__c, SmartViscaf__address_pref__c, SmartViscaf__address__c, SmartViscaf__address_bld__c, SmartViscaf__address_eng__c' +
              ', SmartViscaf__last_name__c, SmartViscaf__first_name__c, SmartViscaf__person_name_last__c, SmartViscaf__person_name_first__c' +
              ', SmartViscaf__email__c, SmartViscaf__tel1__c, SmartViscaf__fax1__c, SmartViscaf__mobile__c, SmartViscaf__Web_url1__c' +
              //', SmartViscaf__image_id__c, SmartViscaf__width__c, SmartViscaf__height__c, SmartViscaf__bk_image_id__c, SmartViscaf__bk_width__c, SmartViscaf__bk_height__c' +
              //', SmartViscaf__list_name__c, SmartViscaf__freehandmemo__c, SmartViscaf__memo__c' +
              ', SmartViscaf__isNotOverwrite__c, SmartViscaf__isNotOverContactwrite__c' +
              ', LastModifiedDate, SmartViscaf__card_exchange_date__c, OwnerId, Owner.Name, Owner.IsActive';

  public static final String NC_QUERY_FIELDS = 'Id, Name, SmartViscaf__Parent__c, SmartViscaf__name_kana__c'  +
              ', SmartViscaf__account__c, SmartViscaf__contact__c' +
              ', SmartViscaf__Account__r.Name, SmartViscaf__Contact__r.Name' +
              ', SmartViscaf__company_name__c, SmartViscaf__company_name_kana__c, SmartViscaf__division__c, SmartViscaf__title_name__c' +
              ', SmartViscaf__zip_code__c, SmartViscaf__address_pref__c, SmartViscaf__address__c, SmartViscaf__address_bld__c, SmartViscaf__address_eng__c' +
              ', SmartViscaf__last_name__c, SmartViscaf__first_name__c, SmartViscaf__person_name_last__c, SmartViscaf__person_name_first__c' +
              ', SmartViscaf__email__c, SmartViscaf__tel1__c, SmartViscaf__fax1__c, SmartViscaf__mobile__c, SmartViscaf__Web_url1__c' +
              ', SmartViscaf__image_id__c, SmartViscaf__width__c, SmartViscaf__height__c, SmartViscaf__bk_image_id__c, SmartViscaf__bk_width__c, SmartViscaf__bk_height__c' +
              ', SmartViscaf__list_name__c, SmartViscaf__freehandmemo__c, SmartViscaf__memo__c' +
              ', SmartViscaf__isNotOverwrite__c, SmartViscaf__isNotOverContactwrite__c' +
              ', LastModifiedDate, SmartViscaf__card_exchange_date__c, OwnerId, Owner.Name, Owner.IsActive';

  @AuraEnabled public String id { get; private set; }              // レコードID
  @AuraEnabled public String parentId { get; private set; }      // 最新の名刺
  @AuraEnabled public String name { get; private set; }            // 氏名
  @AuraEnabled public String company_name { get; private set; }    // 会社名
  @AuraEnabled public String company_name_kana { get; private set; }
  @AuraEnabled public String division { get; private set; }
  @AuraEnabled public String title_name { get; private set; }
  @AuraEnabled public String person_name_last { get; private set; }
  @AuraEnabled public String person_name_first { get; private set; }
  @AuraEnabled public String name_kana { get; private set; }
  @AuraEnabled public DateTime lastModifiedDate { get; private set; }
  @AuraEnabled public String ownerId { get; private set; }
  @AuraEnabled public String ownerName { get; private set; }
  @AuraEnabled public Boolean ownerActive { get; private set; } // lx 2.0
  @AuraEnabled public Date card_exchange_date { get; private set; }
  @AuraEnabled public String zip_code { get; private set; }
  @AuraEnabled public String address_pref { get; private set; }
  @AuraEnabled public String address { get; private set; }
  @AuraEnabled public String address_bld { get; private set; }
  @AuraEnabled public String address_eng { get; private set; }
  @AuraEnabled public String displayAddress { get; private set; }   // 表示用に連結した住所
  @AuraEnabled public String tel1 { get; private set; }
  @AuraEnabled public String fax1 { get; private set; }
  @AuraEnabled public String mobile { get; private set; }
  @AuraEnabled public String email { get; private set; }
  @AuraEnabled public String web_url1 { get; private set; }
  @AuraEnabled public Boolean isNotOverwrite { get; private set; }  // 上書き不可
  @AuraEnabled public Boolean isNotOverContactwrite { get; private set; } // コンタクト上書き不可
  @AuraEnabled public String accountId { get; private set; }
  @AuraEnabled public String contactId { get; private set; }
  // 　以下Simple だとない
  @AuraEnabled public String accountName { get; private set; }
  @AuraEnabled public String contactName { get; private set; }
  @AuraEnabled public String image_id { get; private set; }
  @AuraEnabled public Integer width { get; private set; }
  @AuraEnabled public Integer height { get; private set; }
  @AuraEnabled public String bk_image_id { get; private set; }
  @AuraEnabled public Integer bk_width { get; private set; }
  @AuraEnabled public Integer bk_height { get; private set; }
  @AuraEnabled public String list_name { get; private set; }
  @AuraEnabled public String freehandmemo { get; private set; }
  @AuraEnabled public String memo { get; private set; }
  @AuraEnabled public Boolean saishin { get; private set; } // 2017.03.xx
  //public Integer status { get; private set; }         // -1 : ? 0:最新 1: 古い 2: 転職前 3: 転職後 4:同姓同名 同メアド
  //public String photo { get; private set; }

  // 表示用に連結した住所
  private String getDisplayAddress(SmartViscaf__NameCard__c card) {
    return String.isNotBlank(card.SmartViscaf__address__c) ?
              ((String.isNotBlank(card.SmartViscaf__zip_code__c) ? card.SmartViscaf__zip_code__c + ' ' : '')  +
              (String.isNotBlank(card.SmartViscaf__address_pref__c) ? card.SmartViscaf__address_pref__c + ' ' : '') +
              card.SmartViscaf__address__c +
              (String.isNotBlank(card.SmartViscaf__address_bld__c) ? ' ' + card.SmartViscaf__address_bld__c : '')) :
              (String.isNotBlank(card.SmartViscaf__address_eng__c) ? card.SmartViscaf__address_eng__c : '');
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

  public SB_NCL_NameCardDTO() {
  }

  public SB_NCL_NameCardDTO(SObject obj) {
    System.assert(obj != null);
    System.assert(obj.getSObjectType() == SmartViscaf__NameCard__c.sObjectType);
    bindPopulatedFields(obj);
  }

  private void bindPopulatedFields(SObject obj) {
    Set<String> fields = obj.getPopulatedFieldsAsMap().keySet();
    SmartViscaf__NameCard__c card = (SmartViscaf__NameCard__c)obj;
    this.id = card.Id;
    this.name = card.Name;
    this.parentId = fields.contains('SmartViscaf__Parent__c') ? card.SmartViscaf__Parent__c : null;
    this.company_name = fields.contains('SmartViscaf__company_name__c') ? card.SmartViscaf__company_name__c : null;
    this.company_name_kana = fields.contains('SmartViscaf__company_name_kana__c') ? card.SmartViscaf__company_name_kana__c : null;
    this.division = fields.contains('SmartViscaf__division__c') ? card.SmartViscaf__division__c : null;
    this.title_name = fields.contains('SmartViscaf__title_name__c') ? card.SmartViscaf__title_name__c : null;
    this.person_name_last = fields.contains('SmartViscaf__person_name_last__c') ? card.SmartViscaf__person_name_last__c : null;
    this.person_name_first = fields.contains('SmartViscaf__person_name_first__c') ? card.SmartViscaf__person_name_first__c : null;
    this.name_kana = fields.contains('SmartViscaf__name_kana__c') ? card.SmartViscaf__name_kana__c : null;
    this.lastModifiedDate = fields.contains('LastModifiedDate') ? card.LastModifiedDate : null;
    this.ownerId = fields.contains('OwnerId') ? card.OwnerId : null;
    this.ownerName = fields.contains('Owner') ? card.Owner.Name : null;     // Nameはある前庭で
    this.ownerActive = fields.contains('Owner') ? card.Owner.IsActive : null;     // lx2.0
    this.card_exchange_date = fields.contains('SmartViscaf__card_exchange_date__c') ? card.SmartViscaf__card_exchange_date__c : null;       // 名刺交換 : null日
    this.zip_code = fields.contains('SmartViscaf__zip_code__c') ? card.SmartViscaf__zip_code__c : null;
    this.address_pref = fields.contains('SmartViscaf__address_pref__c') ? card.SmartViscaf__address_pref__c : null;
    this.address = fields.contains('SmartViscaf__address__c') ? card.SmartViscaf__address__c : null;
    this.address_bld = fields.contains('SmartViscaf__address_bld__c') ? card.SmartViscaf__address_bld__c : null;
    this.address_eng = fields.contains('SmartViscaf__address_eng__c') ? card.SmartViscaf__address_eng__c : null;
    this.displayAddress = getDisplayAddress();   // 表示用に連結した住所
    this.tel1 = fields.contains('SmartViscaf__tel1__c') ? card.SmartViscaf__tel1__c : null;
    this.fax1 = fields.contains('SmartViscaf__fax1__c') ? card.SmartViscaf__fax1__c : null;
    this.mobile = fields.contains('SmartViscaf__mobile__c') ? card.SmartViscaf__mobile__c : null;
    this.email = fields.contains('SmartViscaf__email__c') ? card.SmartViscaf__email__c : null;
    this.web_url1 = fields.contains('SmartViscaf__Web_url1__c') ? card.SmartViscaf__Web_url1__c : null;
    this.isNotOverwrite = fields.contains('SmartViscaf__isNotOverwrite__c') ? card.SmartViscaf__isNotOverwrite__c : null;     // 上書き不可
    this.isNotOverContactwrite = fields.contains('SmartViscaf__isNotOverContactwrite__c') ? card.SmartViscaf__isNotOverContactwrite__c : null;  // コンタクト上書き不 : null可
    this.accountId = fields.contains('SmartViscaf__account__c') ? card.SmartViscaf__account__c : null;
    this.contactId = fields.contains('SmartViscaf__contact__c') ? card.SmartViscaf__contact__c : null;
    // 以下は SIMPLEじゃないものたち
    this.accountName = fields.contains('SmartViscaf__account__r') ? card.SmartViscaf__account__r.Name : null;   // Nameはある前庭で
    this.contactName = fields.contains('SmartViscaf__contact__r') ? card.SmartViscaf__contact__r.Name : null;   // Nameはある前庭で
    this.image_id = fields.contains('SmartViscaf__image_id__c') ? card.SmartViscaf__image_id__c : null;
    this.width = fields.contains('SmartViscaf__width__c') ?  card.SmartViscaf__width__c.intValue() : null;
    this.height = fields.contains('SmartViscaf__height__c') ? card.SmartViscaf__height__c.intValue() : null;
    this.bk_image_id = fields.contains('SmartViscaf__bk_image_id__c') ? card.SmartViscaf__bk_image_id__c : null;
    this.bk_width = fields.contains('SmartViscaf__bk_width__c') ? card.SmartViscaf__bk_width__c.intValue() : null;
    this.bk_height = fields.contains('SmartViscaf__bk_height__c') ? card.SmartViscaf__bk_height__c.intValue() : null;
    this.list_name = fields.contains('SmartViscaf__list_name__c') ? card.SmartViscaf__list_name__c : null;
    this.freehandmemo = fields.contains('SmartViscaf__freehandmemo__c') ? card.SmartViscaf__freehandmemo__c : null;
    this.memo = fields.contains('SmartViscaf__memo__c') ? card.SmartViscaf__memo__c : null;
    this.saishin = fields.contains('SmartViscaf__Saishin__c') ? card.SmartViscaf__Saishin__c : null;
  }

  //public override void bind(SObject obj) {
  //}

  public void bind(SmartViscaf__NameCard__c card) {
    this.id = card.Id;
    this.name = card.Name;
    this.parentId = card.SmartViscaf__Parent__c;
    this.company_name = card.SmartViscaf__company_name__c;
    this.company_name_kana = card.SmartViscaf__company_name_kana__c;
    this.division = card.SmartViscaf__division__c;
    this.title_name = card.SmartViscaf__title_name__c;
    this.person_name_last = card.SmartViscaf__person_name_last__c;
    this.person_name_first = card.SmartViscaf__person_name_first__c;
    this.name_kana = card.SmartViscaf__name_kana__c;
    this.lastModifiedDate = card.LastModifiedDate;
    this.ownerId = card.OwnerId;
    this.ownerName = card.Owner.Name;
    this.ownerActive = card.Owner.IsActive;     // lx2.0
    this.card_exchange_date = card.SmartViscaf__card_exchange_date__c;       // 名刺交換日
    this.zip_code = card.SmartViscaf__zip_code__c;
    this.address_pref = card.SmartViscaf__address_pref__c;
    this.address = card.SmartViscaf__address__c;
    this.address_bld = card.SmartViscaf__address_bld__c;
    this.address_eng = card.SmartViscaf__address_eng__c;
    this.displayAddress = getDisplayAddress(card);   // 表示用に連結した住所
    this.tel1 = card.SmartViscaf__tel1__c;
    this.fax1 = card.SmartViscaf__fax1__c;
    this.mobile = card.SmartViscaf__mobile__c;
    this.email = card.SmartViscaf__email__c;
    this.web_url1 = card.SmartViscaf__Web_url1__c;
    this.isNotOverwrite = card.SmartViscaf__isNotOverwrite__c;     // 上書き不可
    this.isNotOverContactwrite = card.SmartViscaf__isNotOverContactwrite__c;  // コンタクト上書き不可
    this.accountId = card.SmartViscaf__account__c;
    this.contactId = card.SmartViscaf__contact__c;
    // 以下は SIMPLEじゃないのである
    this.accountName = card.SmartViscaf__account__r.Name;
    this.contactName = card.SmartViscaf__contact__r.Name;
    this.image_id = card.SmartViscaf__image_id__c;
    this.width = card.SmartViscaf__width__c != null ? card.SmartViscaf__width__c.intValue() : 0;
    this.height = card.SmartViscaf__height__c != null ? card.SmartViscaf__height__c.intValue() : 0;
    this.bk_image_id = card.SmartViscaf__bk_image_id__c;
    this.bk_width = card.SmartViscaf__bk_width__c != null ? card.SmartViscaf__bk_width__c.intValue() : 0;
    this.bk_height = card.SmartViscaf__bk_height__c != null ? card.SmartViscaf__bk_height__c.intValue() : 0;
    this.list_name = card.SmartViscaf__list_name__c;
    this.freehandmemo = card.SmartViscaf__freehandmemo__c;
    this.memo = card.SmartViscaf__memo__c;
  }

  public void bindSimple(SmartViscaf__NameCard__c card) {
    //SmartViscaf__NameCard__c card = (SmartViscaf__NameCard__c)obj;
    this.id = card.Id;
    this.name = card.Name;
    this.parentId = card.SmartViscaf__Parent__c;
    this.company_name = card.SmartViscaf__company_name__c;
    this.company_name_kana = card.SmartViscaf__company_name_kana__c;
    this.division = card.SmartViscaf__division__c;
    this.title_name = card.SmartViscaf__title_name__c;
    this.person_name_last = card.SmartViscaf__person_name_last__c;
    this.person_name_first = card.SmartViscaf__person_name_first__c;
    this.name_kana = card.SmartViscaf__name_kana__c;
    this.ownerId = card.OwnerId;
    this.ownerName = card.Owner.Name;
    this.card_exchange_date = card.SmartViscaf__card_exchange_date__c;       // 名刺交換日
    this.zip_code = card.SmartViscaf__zip_code__c;
    this.address_pref = card.SmartViscaf__address_pref__c;
    this.address = card.SmartViscaf__address__c;
    this.address_bld = card.SmartViscaf__address_bld__c;
    this.address_eng = card.SmartViscaf__address_eng__c;
    this.displayAddress = getDisplayAddress(card);   // 表示用に連結した住所
    this.tel1 = card.SmartViscaf__tel1__c;
    this.fax1 = card.SmartViscaf__fax1__c;
    this.mobile = card.SmartViscaf__mobile__c;
    this.email = card.SmartViscaf__email__c;
    this.web_url1 = card.SmartViscaf__Web_url1__c;
    this.accountId = card.SmartViscaf__account__c;
    this.contactId = card.SmartViscaf__contact__c;
    // 以下は SIMPLEではない
    //this.accountName = card.SmartViscaf__account__r.Name;
    //this.contactName = card.SmartViscaf__contact__r.Name;
    //this.image_id = card.SmartViscaf__image_id__c;
    //this.width = card.SmartViscaf__width__c != null ? card.SmartViscaf__width__c.intValue() : 0;
    //this.height = card.SmartViscaf__height__c != null ? card.SmartViscaf__height__c.intValue() : 0;
    //this.bk_image_id = card.SmartViscaf__bk_image_id__c;
    //this.bk_width = card.SmartViscaf__bk_width__c != null ? card.SmartViscaf__bk_width__c.intValue() : 0;
    //this.bk_height = card.SmartViscaf__bk_height__c != null ? card.SmartViscaf__bk_height__c.intValue() : 0;
    //this.list_name = card.SmartViscaf__list_name__c;
    //this.freehandmemo = card.SmartViscaf__freehandmemo__c;
    //this.memo = card.SmartViscaf__memo__c;
  }

  //// 1つ検索
  //public static SB_NCL_NameCardDTO getNameCard(String targetId) {
  //  SB_NCL_NameCardDTO result;
  //  String query = 'SELECT '+ NC_QUERY_FIELDS + ' FROM SmartViscaf__NameCard__c WHERE Id = :targetId';
  //  List<SmartViscaf__NameCard__c> cards = Database.query(query);      // 照会実施
  //  if (cards.isEmpty()) {
  //    throw new SB_NC_NameCardDTOException(Label.SB_MSG_IllegalRequest + 'Id : ' + targetId);
  //  }
  //  result = new SB_NCL_NameCardDTO();
  //  result.bind(cards[0]);
  //  return result;
  //}

  public static List<SB_NCL_NameCardDTO> createNameCardDto(List<SmartViscaf__NameCard__c> cards) {
    List<SB_NCL_NameCardDTO> result = new List<SB_NCL_NameCardDTO>();
    for (SmartViscaf__NameCard__c card : cards) {
      SB_NCL_NameCardDTO dto = new SB_NCL_NameCardDTO();
      dto.bindSimple(card);
      result.add(dto);
    }
    return result;
  }
}