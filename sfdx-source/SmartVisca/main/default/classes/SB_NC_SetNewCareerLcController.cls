/**
 *
 *  SmartVisca
 *    SB_NC_SetNewCareerLcController.cls
 *   転職先を設定
 *
 * Copyright (C) 2016 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2016.11.xx
 *  @version2.4     2019.06.XX SV_DEV-873/SV_DEV-1614 タイトル部分の表示不具合修正
 *
 **/
public with sharing class SB_NC_SetNewCareerLcController {
  public class SB_NC_SetNewCareerLcControllerException extends Exception {}

  // +---- 最新の名刺だけが対象ので、最新の名刺 論理値の取得
  public class CheckSaishinCardResponse {
    @AuraEnabled public Boolean saishin { get; private set; }
    @AuraEnabled public String error { get; private set; }
    public String fromLabel { get; private set; } // パンくず ラベル
    public String fromId { get; private set; }    // パンくず 戻り先ID
    public CheckSaishinCardResponse() {
      this.saishin = true;
    }
    public void run(Id cardId) {
      List<NameCard__c> cards =  [SELECT Saishin__c FROM NameCard__c WHERE Id = :cardId];
      this.saishin = !cards.isEmpty() && cards[0].Saishin__c;
      this.error = this.saishin ? '' : Label.SB_NC_CareerErrorNotLatest;

      this.fromLabel = NameCard__c.SObjectType.getDescribe().getLabel();
      this.fromId = '/' + NameCard__c.getSObjectType().getDescribe().getKeyPrefix() + '/o';
      
    }
  }

  //@RemoteAction
  //@AuraEnabled
  //public static CheckSaishinCardResponse checkSaishinCard(Id cardId) {
  //  CheckSaishinCardResponse result = new CheckSaishinCardResponse();
  //  result.run(cardId);
  //  return result;
  //}
  @RemoteAction
  @AuraEnabled
  public static String checkSaishinCard(Id cardId) {
    CheckSaishinCardResponse result = new CheckSaishinCardResponse();
    result.run(cardId);
    return JSON.serialize(result);
  }


  // +---- 最新の名刺を設定 における 更新処理
  public class SetNewCareerResponse {
    @AuraEnabled public Boolean success { get; private set; }
    @AuraEnabled public String error { get; private set; }
    // コンストラクタ 処理もしちゃう
    public SetNewCareerResponse(Id cardId, Id newCareerCardId) {
      System.assert(cardId != null);
      System.assert(newCareerCardId != null);
      if (cardId == newCareerCardId) {      // js の方でやると英語で表示されてしまうので、こちらでメッセージを作る。
        this.success = true;
        this.error = Label.SB_MSG_NewCareerMustBeAnother;
      }
      try {
        NameCard__c nameCard = new NameCard__c(Id = cardId);
        // 自分自身を参照する名刺データを、転職後の名刺グループの最新のものに関連付ける
        // 自分自身を参照する名刺データを select
        List<NameCard__c> refferring = [SELECT Id FROM NameCard__c WHERE Parent__c = :nameCard.Id AND delivery_type__c = '2'];
        //List<NameCard__c> refferring_self = [SELECT Id, Parent__c, tenshokugonomeishi__c, tenshokuzumi__c
        //                      FROM NameCard__c WHERE (Parent__c = :cardId OR Id = ) AND delivery_type__c = '2'];

        // 転職後の名刺グループの最新名刺を取得
        NameCard__c newSaishin = getSaishinReccursive(newCareerCardId);

        if (newSaishin == null) {
          throw new SB_NC_SetNewCareerLcControllerException(Label.SB_MSG_NoLatestCardSelected);
        }

        // 2014.08.20 最新の名刺を転職後の名刺にするので、循環参照しないようにチェックします。
        if (newSaishin.Id == nameCard.Id) {
          throw new SB_NC_SetNewCareerLcControllerException(Label.SB_MSG_NewCareerCantBeOldOfSelf);
        }

        list<NameCard__c> cards = new list<NameCard__c>();
        // 対象の名刺を最新にしていた名刺の最新名刺参照先を更新
        for (NameCard__c local : refferring) {
          NameCard__c card = new NameCard__c(Id =local.Id);
          card.Parent__c = newSaishin.id;
          card.tenshokuzumi__c = true;
          cards.add(card);
        }
        // 対象の名刺の最新名刺のデータを更新
        nameCard.tenshokugonomeishi__c = newCareerCardId;   // 転職後の名刺
        nameCard.Parent__c = newSaishin.id;     // 最新の名刺
        nameCard.saishin__c = false;
        nameCard.tenshokuzumi__c = true;
        // 2014.4.2x CRUD/FLS 対応
        cards.add(nameCard);
        SB_NameCard_CrudFls.supdate(cards, true);

        this.success = true;
      }
      catch(Exception e) {
        this.success = false;
        this.error = e.getMessage();
      }
    }

    // 転職後の名刺グループの最新名刺を遡って取得
    @TestVisible
    private NameCard__c getSaishinReccursive(Id input) {
      NameCard__c ret = null;
      List<NameCard__c> nameCard = [SELECT Id, Name, Parent__c, Saishin__c FROM NameCard__c WHERE Id = :input AND delivery_type__c = '2' Limit 1];
      if ( nameCard.size() == 0) {
        return null;
      }
      else {
        if ( nameCard[0].Saishin__c == true) {
          ret = NameCard[0];
        }
        else {
          ret = getSaishinReccursive(nameCard[0].Parent__c);
        }
      }
      return ret;
    }
  }

  //@RemoteAction
  //@AuraEnabled
  //public static SetNewCareerResponse setNewCareer(Id cardId, Id newCareerCardId) {
  //  SetNewCareerResponse result = new SetNewCareerResponse(cardId, newCareerCardId);
  //  return result;
  //}
  @RemoteAction
  @AuraEnabled
  public static String setNewCareer(Id cardId, Id newCareerCardId) {
    SetNewCareerResponse result = new SetNewCareerResponse(cardId, newCareerCardId);
    return JSON.serialize(result);
  }


}