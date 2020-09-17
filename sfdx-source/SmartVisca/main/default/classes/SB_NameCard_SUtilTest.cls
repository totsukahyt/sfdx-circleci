@isTest
private class SB_NameCard_SUtilTest
{

  public class TestDb extends SB_NC_TestDB {

    public void updaeDeliveryStatus() {
      List<NameCard__c> cards = [SELECT Id, Name, Parent__c, Saishin__c, delivery_type__c FROM NameCard__c];
      for (NameCard__c c : cards) {
        c.delivery_type__c = '2';
        c.Saishin__c = true;
      }
      update cards;
    }

    public override void initialize() {
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
      // 名刺にToDoをつける
      initializeTask();
      if (!listTask.isEmpty()) {
        insert listTask;
      }
      // 名刺に行動をつける
      initializeEvent();
      if (!listEvent.isEmpty()) {
        insert listEvent;
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
      // 名刺連携項目マッピング
      initializeMapping();
      if (!listMapping.isEmpty()) {
        insert listMapping;
      }
    }
  }

  // 当クラスのメソッド共通のデータベースの準備
  @TestSetup
  static void setupDB() {
    TestDb db = new TestDb();
    db.initialize();
    db.updaeDeliveryStatus();
  }


  // getNamesWithRecordTypes
  @isTest
  static void test_getNamesWithRecordTypes() {
    List<NameCard__c> objs = [SELECT Id, Name FROM NameCard__c limit 10];
    System.assert(objs.isEmpty() == false);
    Id[] ids = new Id[objs.size()];
    for (NameCard__c obj : objs) {
      ids.add(obj.Id);
    }
    //Test.setFixedSearchResults(ids);
    //List<String> recTypes = new List<String>{'マスタ', null};
    List<String> names = SB_NameCard_SUtil.getNamesWithRecordTypes(new Set<Id>(ids), 'NameCard__c', null);
    System.assert(names.isEmpty() == false);
  }


  //// getRecentlyViewed
  //@isTest
  //static void testGetRecentlyViewed() {
  //  TestDb db = new TestDb();
  //  db.initializeCard_Account_Contact();
  //  List<Account> acnts = [SELECT Name FROM Account limit 100];
  //  for (Account acnt : acnts) {
  //    System.debug(acnt.Name);
  //  }
  //  List<String> namesA = SB_NameCard_SUtil.getRecentlyViewed('Account', null);
  //  List<String> recTypes = new List<String> {'1234567890', '1234567890'};
  //  namesA = SB_NameCard_SUtil.getRecentlyViewed('Account', recTypes);

  //  System.runAs(db.listUser[0]) {
  //    List<String> namesC = SB_NameCard_SUtil.getRecentlyViewed('Contact', recTypes);
  //    System.assertEquals(0, namesC.size());
  //  }
  //}

}