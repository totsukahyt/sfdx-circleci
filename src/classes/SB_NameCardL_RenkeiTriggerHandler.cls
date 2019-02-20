/**
 *
 *  SB_NameCardL_RenkeiTriggerHandler
 *   リード拡張パッケージ 取引先、リード統合登録機能用のハンドラ
 *
 *  Copyright (C) 2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 2.0      2018.07.xx
 *
 **/
global with sharing Class SB_NameCardL_RenkeiTriggerHandler extends SmartViscaf.SB_NameCard_TriggerHandlerAbstract {

  global override void onBeforeInsert(List<SObject> newObjs) {
    doneInsert();
    List<SmartViscaf__NameCard__c> renkeiCards = new List<SmartViscaf__NameCard__c>();
    for (SmartViscaf__NameCard__c namecard : (List<SmartViscaf__NameCard__c>)newObjs) {
      if(String.isBlank(namecard.SmartViscaf__company_name__c) || (String.isBlank(namecard.SmartViscaf__person_name_last__c) && String.isBlank(namecard.SmartViscaf__last_name__c))) {
          continue;
      }
      if(namecard.SmartViscaf__delivery_type__c == '2' && isNoError(namecard)) {
        if(SB_NameCardL_RenkeiChecker.getInstance().isIgnore(namecard) == false) {
          renkeiCards.add(namecard);
        }
      }
    }
    if(!renkeiCards.isEmpty()) {
      if (SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RenkeiLeadActive__c
            || SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RenkeiActiveCampaignMember__c) {
        System.debug(SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RenkeiLeadActive__c);
        System.debug(SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RenkeiActiveCampaignMember__c);
        // リードに自動連系
        SB_NameCardL_RenkeiHelper.doRenkei(renkeiCards,SB_NameCardL_RenkeiHelper.ProcType.LEAD);
      }
      else {
        //取引先と取引先責任者に自動連携
        SB_NameCardL_RenkeiHelper.doRenkei(renkeiCards,SB_NameCardL_RenkeiHelper.ProcType.ACCOUNT);
      }
    }
  }

  //名刺を更新時の連携操作
  global override void onBeforeUpdate(List<SObject> newObjs, Map<Id, SObject> oldMap) {
    doneUpdate();
    List<SmartViscaf__NameCard__c> renkeiCards = new List<SmartViscaf__NameCard__c>();
    for (SmartViscaf__NameCard__c ne :  (List<SmartViscaf__NameCard__c>)newObjs) {
      SmartViscaf__NameCard__c ol = (SmartViscaf__NameCard__c)oldMap.get(ne.Id);
      if(String.isBlank(ne.SmartViscaf__company_name__c) || (String.isBlank(ne.SmartViscaf__person_name_last__c) && String.isBlank(ne.SmartViscaf__last_name__c))) {
        continue;
      }
      if(ol.SmartViscaf__delivery_type__c == '1' && ne.SmartViscaf__delivery_type__c == '2' && isNoError(ne)) {
        //名刺を差込み、ワークフローで更新する時フラグを変換しない為にここでフラグを変更
        if(SB_NameCardL_RenkeiChecker.getInstance().isIgnore(ne) == false) {
          renkeiCards.add(ne);
        }
      }
    }
    // System.debug(renkeiCards);
    if(!renkeiCards.isEmpty()) {
      if (SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RenkeiLeadActive__c
            || SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RenkeiActiveCampaignMember__c) {
        // リードに自動連系
        SB_NameCardL_RenkeiHelper.doRenkei(renkeiCards,SB_NameCardL_RenkeiHelper.ProcType.LEAD);
      }
      else {
        //取引先と取引先責任者に自動連携
        SB_NameCardL_RenkeiHelper.doRenkei(renkeiCards,SB_NameCardL_RenkeiHelper.ProcType.ACCOUNT);
      }
    }
  }

  //1．error_code:1
  //＝言語エラー
  //・日英中以外の言語で全く入力が出来ない場合
  //・例外として、電話番号やメールアドレスなど入力できる項目があれば、その部分を入力して納品し、エラーにはなりません。

  //2．error_code:2
  //＝重送エラー
  //・名刺スキャン時に2枚重なった状態でスキャンしてしまった状態で、重要項目が隠れてしまったり切れてしまって入力が出来ない場合

  //3．error_code:3
  //＝不鮮明エラー　対応していない言語の場合に出ます。
  //・名刺画像がピンボケしていたり、汚れていたりしてほとんど読めないと判断された場合
  //・名刺以外の画像（会員権や診断書、ハガキを含む）や全て手書きの名刺の場合

  //4．INVALID_EMAIL_ADDRESS
  //＝メールアドレスの入力エラー

  //SmartViscaでは入力できない文字や不鮮明な文字は「？」で納品させて頂きますが
  //Salesforceの項目のルールとして、メールアドレスに「？」を入れる事が出来ません。

  //その他、メールアドレスとしてありえない文字列が入力された際に不正な文字列としてSalesforceがエラーを返します。
  //その内容を「INVALID_EMAIL_ADDRESS」と言う形でエラー情報に表示させて頂きます。
  //このままでは納品出来ませんので
  //エラー情報に内容を入れた上で、メールアドレスの項目は空白に置き換えて名刺データに納品させて頂きます。

  //エラー名刺判断
  public Boolean isNoError(SmartViscaf__NameCard__c namecard){
    return String.isBlank(namecard.SmartViscaf__error__c) || !namecard.SmartViscaf__error__c.startsWithIgnoreCase('error_code');
  }


  global override void onBeforeDelete(List<SObject>  oldObjs, Map<Id, SObject> oldMap) {

  }

  global override void onAfterInsert(List<SObject> newObjs) {

  }

  global override void onAfterUpdate(List<SObject>  newObjs, Map<Id, SObject> oldMap) {

  }

  global override void onAfterDelete(List<SObject>  oldObjs, Map<Id, SObject> oldMap) {

  }

  global override void onUndelete(List<SObject> newObjs) {

  }
}