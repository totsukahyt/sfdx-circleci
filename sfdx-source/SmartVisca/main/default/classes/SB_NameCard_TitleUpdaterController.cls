/*  $Id$    */

/*
 * Copyright (c) 2014-2015 SunBridge Inc.
 *
 * 日経テレコン人事異動情報 役職更新
 * @Version 1 kou 2017.10.xx  FLS  v1.21 for code scan
 */

public with sharing class SB_NameCard_TitleUpdaterController {

    public String targetId { get; private set;}
    public String parentId { get; private set;}
    public JinjiIdo__c targetRecord { get; private set;}
    public String newTitle { get; set;}
    public String contactlabel{get;set;}

    public String returnURL { get; private set;}
    public Boolean isError { get; private set;}
    
    public String reflectToTitle{get;set;}//表示ラベル
    public String replaceContactTitle{get;set;}

    /** VFページ用のコンストラクタです。 */
    public SB_NameCard_TitleUpdaterController( ApexPages.StandardController controller) {
        //SV_DEV-605 によってgetGlobalDescribeを使わないようにする
        this.contactlabel = Contact.sObjectType.getDescribe().getLabel();
        //SV_DEV-605 changeLabelメソッド使わない
        //ラベル:取引先責任者の役職に反映
        this.reflectToTitle = String.format(System.Label.SB_NC_ReflectToTitleDEV,new String[]{contactlabel});
        //ラベル:取引先責任者の役職を新職名で更新
        this.replaceContactTitle = String.format(System.Label.SB_NC_ReplaceContactTitleDEV,new String[]{contactlabel});

        this.targetId = controller.getId();
        this.isError = false;
    }

    public PageReference cancel() {
        return new PageReference('/' + this.targetId);
    }

    public void init() {
        System.debug( '-----:init start');

        // idが選ばれているか？
        if ( this.targetId == null) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.SB_MSG_SelectPersonnelChangeInfo));
            this.returnURL = '/home/home.jsp';
            this.isError = true;
            return;
        }

        // 人事異動情報を select
        try {
            this.targetRecord = [SELECT NameCard__r.contact__c, NameCard__r.contact__r.Name, NameCard__r.contact__r.Account.Name, NameCard__r.contact__r.Title, NewTitle__c FROM JinjiIdo__c WHERE Id = :this.targetId];

            if (this.targetRecord.NameCard__r.contact__c == null) {
                String str = String.format(System.Label.SB_MSG_ContactNotSetDEV,new String[]{Contact.sObjectType.getDescribe().getLabel()});

                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, str));
            } else {
                this.parentId = this.targetRecord.NameCard__r.contact__c;
                this.returnURL = '/' + this.targetId;
                this.newTitle = this.targetRecord.NewTitle__c;
            }
        }
        catch ( Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.SB_MSG_CantGetPersonnelChangeInfo + '\n' + e.getMessage()));
            this.isError = true;
            return;
        }
    }

    public PageReference updateContact() {

        PageReference p = null;

        if (this.targetRecord.NameCard__r.contact__c == null) {
            String str = String.format(System.Label.SB_MSG_ContactNotSetDEV,new String[]{Contact.sObjectType.getDescribe().getLabel()});

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, str));
        } else {
            Savepoint sp = null;

            // contactを更新
            Contact contact = new Contact( id=this.targetRecord.NameCard__r.contact__c);
            contact.Title = this.newTitle;

            try {
                sp = Database.setSavepoint();
                SB_NameCard_CrudFls.supdate(new Contact[]{contact}, true); //  kou 2017.10.xx  FLS Update  v1.21 for code scan
                p = new PageReference('/' + this.parentId);
            }
            catch ( Exception e) {
                Database.rollback(sp);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.SB_MSG_CantUpdateTitle + '\n' + e.getMessage()));
                this.isError = true;
                return null;
            }
        }

        return p;
    }
}