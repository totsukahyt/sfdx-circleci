/**
 *
 * SB_NameCard_MergeBuisnessCardsAfter  のテストクラス
 *
 * Copyright (C) 2014 SunBridge Inc. All Rights Reserved.
 *
 *  @author mao
 *  @Version 1      2017.5.xx
 *
 **/
@isTest
public class SB_NameCard_MergeBuisnessCardsAfterTest {
    public static Set<String> SETTINGVALUES = new Set<String>{'address_pref__c','address_eng__c','freehandmemo__c','fax1__c','division__c'};

    public class MergeTestDb extends SB_NC_TestDB{
        public void installsettingValues(){
            List<NameCardSettingValues__c> settingvalue = new List<NameCardSettingValues__c>();
            for(String str : SB_NameCard_MergeBuisnessCardsAfterTest.SETTINGVALUES){
                NameCardSettingValues__c sv = new NameCardSettingValues__c();
                sv.TextValue01__c = SB_NameCard_RenkeiMapperUtil.getManagedfileName('all',str);
                sv.Type__c = 'SaishinInherit';
                settingvalue.add(sv);
            }
            insert settingvalue;
        }

        public void updateBasic(){
            List<NameCardBasicSetting__c> basics= [Select Id,Name From NameCardBasicSetting__c];
            for(NameCardBasicSetting__c ba : basics){
                ba.SaishinInheritValues__c = true;
            }
            Update basics;
        }


        public override void initialize() {
            initializeBasicSetting();
            initializeSmartViscaConfig();
            installsettingValues();
            svConfig.TriggerMergeNameCards__c = true;
            if (!listBasicSetting.isEmpty()) 
                insert listBasicSetting;
            updateBasic();

            initializeUser();
            if (listUser.isEmpty() == false)
                insert listUser;

            NameCard__c na = new NameCard__c(Name='test',person_name_last__c='last',address_pref__c = 'testpp',address_eng__c = 'testaddress_eng__c',freehandmemo__c='freehandmemo__c',fax1__c='123',division__c='testdivision__c');
            na.delivery_type__c = '2';
            insert na;
        }

    }

    //名刺作成時の引き続ぐ
    public static testMethod void insertNamecard(){
        //テストデータを作成
        MergeTestDb db = new MergeTestDb();
        db.initialize();
        //SB_NameCard_MergeBuisnessCardsAfterクラスを動かすためにfirstRunをtrueに設定
        SB_NameCard_MergeBuisnessCardsAfter.firstRun =  true;
        //必要な項目クエリ
        String soql = 'Select Id,Saishin__c,delivery_type__c,Parent__c,person_name_last__c,person_name_first__c,email__c';
        for(String str : SETTINGVALUES){
            soql += ',' + SB_NameCard_RenkeiMapperUtil.getManagedfileName('all',str);
        }
        soql += ' from ' + SB_NameCard_RenkeiMapperUtil.getManagedObjectName('NameCard__c');
        List<NameCard__c> cards =  Database.query(soql);

        System.assertEquals(cards.size() > 0,true);

        //名刺を新規名刺交換日は明日に設定
        NameCard__c card = new NameCard__c();
        card.person_name_last__c = cards[0].person_name_last__c;
        card.person_name_first__c = cards[0].person_name_first__c;
        card.email__c = cards[0].email__c;
        card.delivery_type__c = '2';
        card.card_exchange_date__c = Date.today().addDays(1);
        insert card;
        soql += ' Where id=' + '\'' + card.Id + '\'';
        List<NameCard__c> newcard =  Database.query(soql);

        System.assertEquals(newcard.size(),1);
        System.assertEquals(newcard[0].Saishin__c,true);

        //引き継ぐassert
        for(String strb : SETTINGVALUES){
            String str = SB_NameCard_RenkeiMapperUtil.getManagedfileName('all',strb);
            System.assertEquals(newcard[0].get(str),cards[0].get(str));
        }
        List<NameCard__c> oldcards =  [Select Id,Name,Saishin__c From NameCard__c Where Id =:cards[0].Id];
        System.assertEquals(oldcards[0].Saishin__c,false);
    }

    //名刺納品タイプ更新時の引き続ぐ
    public static testMethod void updateNamecard(){
        //テストデータを作成
        MergeTestDb db = new MergeTestDb();
        db.initialize();
        //SB_NameCard_MergeBuisnessCardsAfterクラスを動かすためにfirstRunをtrueに設定
        SB_NameCard_MergeBuisnessCardsAfter.firstRun =  true;
        //必要な項目クエリ
        String soql = 'Select Id,Saishin__c,delivery_type__c,Parent__c,person_name_last__c,person_name_first__c,email__c';
        for(String str : SETTINGVALUES){
            soql += ',' + SB_NameCard_RenkeiMapperUtil.getManagedfileName('all',str);
        }
        soql += ' from ' + SB_NameCard_RenkeiMapperUtil.getManagedObjectName('NameCard__c');
        List<NameCard__c> cards =  Database.query(soql);

        System.assertEquals(cards.size() > 0,true);

        //名刺を新規名刺交換日は明日に設定
        NameCard__c card = new NameCard__c();
        card.person_name_last__c = cards[0].person_name_last__c;
        card.person_name_first__c = cards[0].person_name_first__c;
        card.email__c = cards[0].email__c;
        card.delivery_type__c = '1';
        card.card_exchange_date__c = Date.today().addDays(1);
        insert card;
        String soql1 = soql + ' Where id=' + '\'' + card.Id + '\'';
        List<NameCard__c> newcard1 =  Database.query(soql1);

        System.assertEquals(newcard1[0].Saishin__c,false);

        card.delivery_type__c = '2';
        SB_NameCard_MergeBuisnessCardsAfter.firstRun =  true;
        Update card;
        soql += ' Where id=' + '\'' + card.Id + '\'';
        List<NameCard__c> newcard =  Database.query(soql);

        System.assertEquals(newcard.size(),1);
        System.assertEquals(newcard[0].Saishin__c,true);

        //引き継ぐassert
        for(String strb : SETTINGVALUES){
            String str = SB_NameCard_RenkeiMapperUtil.getManagedfileName('all',strb);
            System.assertEquals(newcard[0].get(str),cards[0].get(str));
        }
        List<NameCard__c> oldcards =  [Select Id,Name,Saishin__c From NameCard__c Where Id =:cards[0].Id];

        System.assertEquals(oldcards[0].Saishin__c,false);
    }

    //名刺交換日更新時の引き続ぐ
    public static testMethod void changeExdate(){
        //テストデータを作成
        MergeTestDb db = new MergeTestDb();
        db.initialize();
        //SB_NameCard_MergeBuisnessCardsAfterクラスを動かすためにfirstRunをtrueに設定
        SB_NameCard_MergeBuisnessCardsAfter.firstRun =  true;
         //必要な項目クエリ
        String soql = 'Select Id,Saishin__c,delivery_type__c,Parent__c,person_name_last__c,person_name_first__c,email__c';
        for(String str : SETTINGVALUES){
            soql += ',' + SB_NameCard_RenkeiMapperUtil.getManagedfileName('all',str);
        }
        soql += ' from ' + SB_NameCard_RenkeiMapperUtil.getManagedObjectName('NameCard__c');
        List<NameCard__c> cards =  Database.query(soql);

        System.assertEquals(cards.size() > 0,true);

        //名刺を新規名刺交換日は明日に設定
        NameCard__c card = new NameCard__c();
        card.person_name_last__c = cards[0].person_name_last__c;
        card.person_name_first__c = cards[0].person_name_first__c;
        card.email__c = cards[0].email__c;
        card.delivery_type__c = '1';
        insert card;
        String soql1 = soql + ' Where id=' + '\'' + card.Id + '\'';
        List<NameCard__c> newcard1 =  Database.query(soql1);
        System.assertEquals(newcard1[0].Saishin__c,false);
        card.delivery_type__c = '2';
        SB_NameCard_MergeBuisnessCardsAfter.firstRun =  true;
        Update card;
        newcard1 =  Database.query(soql1);

        System.assertEquals(newcard1[0].Saishin__c,false);

        card.card_exchange_date__c = Date.today().addDays(1);
        SB_NameCard_MergeBuisnessCardsAfter.firstRun =  true;
        Update card;

        soql += ' Where id=' + '\'' + card.Id + '\'';
        List<NameCard__c> newcard =  Database.query(soql);

        System.assertEquals(newcard.size(),1);
        System.assertEquals(newcard[0].Saishin__c,true);

        //引き継ぐassert
        for(String strb : SETTINGVALUES){
            String str = SB_NameCard_RenkeiMapperUtil.getManagedfileName('all',strb);
            System.assertEquals(newcard[0].get(str),cards[0].get(str));
        }
        List<NameCard__c> oldcards =  [Select Id,Name,Saishin__c From NameCard__c Where Id =:cards[0].Id];
        System.assertEquals(oldcards[0].Saishin__c,false);
    }
}