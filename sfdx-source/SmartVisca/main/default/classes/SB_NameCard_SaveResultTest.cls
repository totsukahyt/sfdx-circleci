/**
 *
 * SB_NameCard_SaveResultTest
 *  SB_NameCard_SaveResult Database.insert Database.update の戻り値 SaveResult から エラーメッセージとかを抽出するクラス のテストクラス
 *
 * Copyright (C) 2016 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2016.10.xx
 *
 **/
@isTest
private class SB_NameCard_SaveResultTest
{

  public class TestDb extends SB_NameCard_TestDB {

    public override void initialize() {
      // SmartVisca設定
      super.initializeSmartViscaConfig();
      if (svConfig !=null) {
        upsert svConfig;
      }
       // ユーザ
      initializeUser();
      if (listUser.isEmpty() == false) {
        insert listUser;
      }
      // 名刺関係
      initializeKaisha();     // 会社を揃えておく
      initializeEmployee();   // 会社ごとに名刺の人を揃えておく
      // 名刺
      initializeNameCard();
      if (listCard.isEmpty() == false) {
        insert listCard;
      }
      // 取引先
      initializeAccount();  // 揃えた会社について、取引先を作る。
      if (mapAccount.isEmpty() == false) {
        insert mapAccount.values();
      }
      // 取引先責任者
      initializeContact();
      if (!listContact.isEmpty()) {
        insert listContact;
      }
    }
  }

  @isTest
  static void testDMLSuccess() {
    TestDb db = new TestDb();
    db.initialize();

    List<Account> acnts = [SELECT Id, Name FROM Account limit 2];

    Database.DMLOptions dml = new Database.DMLOptions();
    dml.OptAllOrNone = false;

    List<Database.SaveResult> srs = Database.update(acnts, dml);
    SB_NameCard_SaveResult dbError = new SB_NameCard_SaveResult();
    dbError.putSaveResults(null);
    dbError.putSaveResults(srs);

    System.assertEquals(false, dbError.isError());
  }


  @isTest
  static void testDMLError() {
    TestDb db = new TestDb();
    db.initialize();

    List<Account> acnts = new List<Account>();
    acnts.add(new Account());

    Database.DMLOptions dml = new Database.DMLOptions();
    dml.OptAllOrNone = false;

    List<Database.SaveResult> srs = Database.insert(acnts, dml);
    SB_NameCard_SaveResult dbError = new SB_NameCard_SaveResult();
    dbError.putSaveResults(srs);

    System.assertEquals(true, dbError.isError());
    Map<Integer, SB_NameCard_SaveResult.DbErrorHolder> errorHolders = dbError.getDbErrorHolders();
    SB_NameCard_SaveResult.DbErrorHolder errorHolder = dbError.getDbErrorHolder(0);
    System.assertNotEquals(null, errorHolder);
    System.assertEquals(false, dbError.isDuplicateError());
    System.assertEquals(false, dbError.isAllowSave());
    List<Integer> indexs = dbError.getDuplicateRecordIndex();
    System.assertEquals(0, indexs.size());
  }


  @isTest
  static void testDuplicateErrorHolder() {
    TestDb db = new TestDb();
    db.initialize();

    List<Account> acnts = [SELECT Id, Name FROM Account limit 2];

    SB_NameCard_SaveResult.DuplicateErrorHolder errorHolder = new SB_NameCard_SaveResult.DuplicateErrorHolder();
    errorHolder.buildATags(acnts[0].Id, acnts[0].Name);
    errorHolder.buildATags(acnts[0].Id, acnts[0].Name);

    //System.assert(String.isNotBlank(errorHolder.atags));
    System.assert(!errorHolder.atags.isEmpty());
  }

  @isTest
  static void testRecordInfo() {
    TestDb db = new TestDb();
    db.initialize();

    List<Account> acnts = [SELECT Id, Name FROM Account limit 2];
    SB_NameCard_SaveResult.RecordInfo info = new SB_NameCard_SaveResult.RecordInfo(acnts[0].Id, acnts[0].Name);
    System.assertEquals('Account', info.objName);
    System.assertEquals(acnts[0].Id, info.id);
  }
}