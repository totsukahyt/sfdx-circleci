/**
 *
 *  SmartVisca LEX対応
 *      SB_NC_CardDetailLcController
 *  名刺詳細表示用 Lightningコンポーネント 用 コントローラ
 *
 *  TODO：
 *    Lightning Data Service が 使えるようになったら移行する
 *
 * Copyright (C) 2016 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2016.10.xx
 *
 **/
public with sharing class SB_NC_CardDetailLcController {
  public class SB_NC_CardDetailLcControllerException extends Exception {}

  private static final String NMAECARD_FIELDS = 'Id, Name, name_kana__c, person_name_last__c, person_name_first__c' +
  ', company_name__c, company_name_kana__c, division__c, title_name__c' +
  ', zip_code__c, address_pref__c, address__c, address_bld__c, address_eng__c' +
  ', card_exchange_date__c, list_name__c, OwnerId, Owner.Name, Parent__c, tenshokugonomeishi__c, account__c, contact__c' +
  ', freehandmemo__c, memo__c, web_url1__c, email__c, tel1__c, mobile__c, fax1__c' +
  ', image_id__c, bk_image_id__c, width__c, height__c, bk_width__c, bk_height__c' +
  ', Saishin__c';

  public class GetNamecardResponse {
    @AuraEnabled public Boolean success { get; private set; }
    @AuraEnabled public String error { get; private set; }
    @AuraEnabled public SB_NC_NameCardDTO card { get; private set; }

    public void run(Id targetId) {
      try {
        String query =
          'SELECT '+ NMAECARD_FIELDS + ' FROM NameCard__c WHERE Id = :targetId';
        List<NameCard__c> cards = Database.query(query);      // 照会実施
        if (cards.isEmpty() == true) {
          throw new SB_NC_CardDetailLcControllerException(Label.SB_MSG_IllegalRequest + 'Id : ' + targetId);
        }
        this.card = new SB_NC_NameCardDTO(cards[0]);
        this.success = true;
      }
      catch(Exception e) {
        //throw new SB_NC_CardDetailLcControllerException(e.getMessage());
        this.error = e.getMessage();
        this.success = false;
      }
    }
  }

  //@RemoteAction
  //@AuraEnabled
  //public static GetNamecardResponse getNamecard(Id targetId) {
  //  GetNamecardResponse result = new GetNamecardResponse();
  //  result.run(targetId);
  //  return result;
  //}

  @RemoteAction
  @AuraEnabled
  public static String getNamecard(Id targetId) {
    GetNamecardResponse result = new GetNamecardResponse();
    result.run(targetId);
    return JSON.serialize(result);
  }

}