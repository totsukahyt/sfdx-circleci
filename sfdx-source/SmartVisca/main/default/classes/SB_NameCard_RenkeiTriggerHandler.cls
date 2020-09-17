/**
*
*  SB_NameCard_RenkeiTriggerHandler
*   名刺を新規及び更新
*
*   自動連携機能有効をオン名刺の納品タイプを新規の場合２更新の場合１から２の場合自働連携を行います
*
*  Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
*
*  @author gao
*  @Version 1.20      2017.02.XX
*  @Version 1.22      2017.09.XX  SV_DEV-515  名刺納品時のエラー情報によっては自動連携をしない
*  @Version 2.4 sawano 2019.07.xx SV_DEV-956 【例外条件】取引先名「？」で納品され、「姓（ラストネーム）」が入力されている場合に自動連携されてしまう。
*                                   会社名、姓・ラストネームも チェッカーにして、疎に。
*
**/


public with sharing class SB_NameCard_RenkeiTriggerHandler {
  public class SB_NameCard_RenkeiTriggerHandlerException extends Exception {}

  public static Boolean firstRunInsert;

  public static Boolean firstRunUpdate;
  static{
      firstRunInsert = true;
      firstRunUpdate = true;
  }

  //名刺を差込時の連携操作
  public void insertRennkei(List<NameCard__c> newNameCard){

    List<NameCard__c> renkeiCards = new List<NameCard__c>();
    for (NameCard__c namecard : newNameCard) {
      if(namecard.delivery_type__c == '2' && isNoError(namecard)) {
        SB_NameCard_RenkeiTriggerHandler.firstRunInsert = false;
        if(SB_NameCard_RenkeiChecker.getInstance().isIgnore(namecard) == false) {
          renkeiCards.add(namecard);
        }
      }
    }
    if(!renkeiCards.isEmpty()) {
      if ((SB_NameCard_BasicSetting.getNameCardBasicSetting().RenkeiLeadActive__c
            || SB_NameCard_BasicSetting.getNameCardBasicSetting().RenkeiActiveCampaignMember__c)
                && SB_NameCard_Util.isEnableLeadExt112()) {
        // リードに自動連系
        SB_NameCard_RenkeiTriggerHelper.doRenkei(renkeiCards,SB_NameCard_RenkeiTriggerHelper.ProcType.LEAD);
      } else {
        //取引先と取引先責任者に自動連携
        SB_NameCard_RenkeiTriggerHelper.doRenkei(renkeiCards,SB_NameCard_RenkeiTriggerHelper.ProcType.ACCOUNT);
      }
    }
  }

  //名刺を更新時の連携操作
  public void updateRennkei(List<NameCard__c> newNameCard,Map<Id,NameCard__c> oldNameCard){

    List<NameCard__c> renkeiCards = new List<NameCard__c>();
    for (NameCard__c ne : newNameCard) {
      NameCard__c ol = oldNameCard.get(ne.Id);
      if(ol.delivery_type__c == '1' && ne.delivery_type__c == '2' && isNoError(ne)) {
        //名刺を差込み、ワークフローで更新する時フラグを変換しない為にここでフラグを変更
        SB_NameCard_RenkeiTriggerHandler.firstRunUpdate = false;
        if(SB_NameCard_RenkeiChecker.getInstance().isIgnore(ne) == false) {
          renkeiCards.add(ne);
        }
      }
    }
    System.debug(renkeiCards);
    if(!renkeiCards.isEmpty()) {
      if ((SB_NameCard_BasicSetting.getNameCardBasicSetting().RenkeiLeadActive__c
            || SB_NameCard_BasicSetting.getNameCardBasicSetting().RenkeiActiveCampaignMember__c)
                && SB_NameCard_Util.isEnableLeadExt112()) {
        // リードに自動連系
        SB_NameCard_RenkeiTriggerHelper.doRenkei(renkeiCards,SB_NameCard_RenkeiTriggerHelper.ProcType.LEAD);
      } else {
        //取引先と取引先責任者に自動連携
        SB_NameCard_RenkeiTriggerHelper.doRenkei(renkeiCards,SB_NameCard_RenkeiTriggerHelper.ProcType.ACCOUNT);
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
  public Boolean isNoError(NameCard__c namecard){
    return String.isBlank(namecard.error__c) || !namecard.error__c.startsWithIgnoreCase('error_code');
  }
}