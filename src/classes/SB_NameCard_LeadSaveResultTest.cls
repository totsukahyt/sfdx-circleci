/**
 *
 * SB_NameCard_LeadSaveResultTest
 *  SB_NameCard_LeadSaveResult Database.insert Database.update の戻り値 SaveResult から エラーメッセージとかを抽出するクラス のテストクラス
 *
 * Copyright (C) 2016 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2016.10.xx
 *
 **/
@isTest
private class SB_NameCard_LeadSaveResultTest
{
    private static void initialize()
    {
        SmartViscaf__NameCard__c nc = new SmartViscaf__NameCard__c();
        nc.SmartViscaf__zip_code__c = '150-0022';
        nc.SmartViscaf__address_pref__c = '東京都';
        nc.SmartViscaf__address__c = '渋谷区恵比寿南';
        nc.SmartViscaf__company_name__c = 'TestCompany';
        nc.SmartViscaf__tel1__c = '03-1111-1111';
        nc.SmartViscaf__fax1__c = '03-1111-1112';
        nc.SmartViscaf__title_name__c = 'TestTitle';
        nc.SmartViscaf__person_name_last__c = 'TestLast';
        nc.SmartViscaf__person_name_first__c = 'TestFirst';

        //nc.SmartViscaf__email__c = 'test@sbnc.example.com';
        nc.SmartViscaf__mobile__c = '090-1111-1111';
        nc.SmartViscaf__card_exchange_date__c = Date.today();

        Database.DMLOptions dml = new Database.DMLOptions();

        dml.OptAllOrNone = false;

        Campaign cc = new Campaign();
        cc.Name = 'test';
        Database.SaveResult sr = SB_NameCard_LeadCrudFls.screate(new List<Campaign>{cc},dml)[0];

        nc.campaign__c = cc.Id;

        Database.SaveResult sr1 = SB_NameCard_LeadCrudFls.screate(new List<SmartViscaf__NameCard__c>{nc},dml)[0];
        System.assertEquals(0, sr.getErrors().size(), 'saveCampaign error');
        System.assertEquals(0, sr1.getErrors().size(), 'savenamecard error');

        System.debug('SB_NameCard_LeadRegistTest nc.Id: '+nc.Id);

        Account a = new Account(Name = 'test');
        a.SmartViscaf__NameCard__c = nc.Id;
        insert a;
        nc.SmartViscaf__address__c = a.Id;
        update nc;
    }

  @isTest
  static void testDMLSuccess() {
    initialize();

    List<Account> acnts = [SELECT Id, Name FROM Account limit 2];

    Database.DMLOptions dml = new Database.DMLOptions();
    dml.OptAllOrNone = false;

    List<Database.SaveResult> srs = Database.update(acnts, dml);
    SB_NameCard_LeadSaveResult dbError = new SB_NameCard_LeadSaveResult();
    dbError.putSaveResults(null);
    dbError.putSaveResults(srs);

    System.assertEquals(false, dbError.isError());
  }


  @isTest
  static void testDMLError() {
    initialize();

    List<Account> acnts = new List<Account>();
    acnts.add(new Account());

    Database.DMLOptions dml = new Database.DMLOptions();
    dml.OptAllOrNone = false;

    List<Database.SaveResult> srs = Database.insert(acnts, dml);
    SB_NameCard_LeadSaveResult dbError = new SB_NameCard_LeadSaveResult();
    dbError.putSaveResults(srs);

    System.assertEquals(true, dbError.isError());
    Map<Integer, SB_NameCard_LeadSaveResult.DbErrorHolder> errorHolders = dbError.getDbErrorHolders();
    SB_NameCard_LeadSaveResult.DbErrorHolder errorHolder = dbError.getDbErrorHolder(0);
    System.assertNotEquals(null, errorHolder);
    System.assertEquals(false, dbError.isDuplicateError());
    System.assertEquals(false, dbError.isAllowSave());
    List<Integer> indexs = dbError.getDuplicateRecordIndex();
    System.assertEquals(0, indexs.size());
  }

  //@isTest
  //static void testCreateDbErrorHolder() {
  //}

  @isTest
  static void testDuplicateErrorHolder() {
    initialize();

    List<Account> acnts = [SELECT Id, Name FROM Account limit 2];

    SB_NameCard_LeadSaveResult.DuplicateErrorHolder errorHolder = new SB_NameCard_LeadSaveResult.DuplicateErrorHolder();
    errorHolder.buildATags(acnts[0].Id, acnts[0].Name);
    errorHolder.buildATags(acnts[0].Id, acnts[0].Name);

    System.assert(String.isNotBlank(errorHolder.atags));
  }

  @isTest
  static void testRecordInfo() {
    initialize();

    List<Account> acnts = [SELECT Id, Name FROM Account limit 2];
    SB_NameCard_LeadSaveResult.RecordInfo info = new SB_NameCard_LeadSaveResult.RecordInfo(acnts[0].Id, acnts[0].Name);
    System.assertEquals('Account', info.objName);
    System.assertEquals(acnts[0].Id, info.id);
  }
}