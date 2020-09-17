/*
 * SB_NameCard_RegistOwnerCheckHelper
 * SB_NameCard_RegistOwnerCheckHelperクラスのテストクラス
 *
 * (c) 2019 Sunbridge Inc.
 *
 *  @author K.Yoshida
 *  @Version 2.2  2019.02.XX SV_DEV-1558 LEX 取引先登録 一括画面をLXパッケージ同様のLC化で追加
 *  @Version 2.4  2019.09.xx sawano
 *                            SV_DEV-1993 Classic 取引先登録 個別：無効ユーザを所有者として登録した場合のメッセージ表示
 *                            SV_DEV-1994 LEX 取引先登録 個別：無効ユーザを所有者として登録した場合のメッセージ表示
 */
@isTest
public class SB_NameCard_RegistOwnerCheckHelperTest {
  private static List<User> insertUser() {
    List<User> us = new List<User>();
    Profile prof = [SELECT Id, UserType, Name FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
    User u = new User(Alias = 'test', Email='newusertest@testorgtest.com',
    EmailEncodingKey='UTF-8', LastName='Testingtest', LanguageLocaleKey='en_US',
    LocaleSidKey='en_US', ProfileId = prof.Id,UserPermissionsMarketingUser = true,
    TimeZoneSidKey='America/Los_Angeles', UserName='newusertesttest@testorgtestA.com',
    IsActive = true);

    User u1 = new User(Alias = 'test1', Email='newusertest1@testorgtest.com',
    EmailEncodingKey='UTF-8', LastName='Testingtest1', LanguageLocaleKey='en_US',
    LocaleSidKey='en_US', ProfileId = prof.Id,UserPermissionsMarketingUser = true,
    TimeZoneSidKey='America/Los_Angeles', UserName='newusertesttest1@testorgtestB.com',
    IsActive = true);
    insert new User[]{u, u1};

    us.add(u);
    us.add(u1);
    return [SELECT Id, Name From User Where Id in: us];
  }

  // private static Id insertQueue(Boolean leadCanUse) {
  //   Group g1 = new Group(Name='group name', type='Queue');
  //   insert g1;
  //   List<QueuesObject> qss = new List<QueuesObject>();
  //   if (leadCanUse) {
  //       QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Lead');
  //       qss.add(q1);
  //   }
  //   String ns = SB_NameCard_Util.getNamespacePrefix_x();
  //   QueuesObject q2 = new QueueSObject(QueueID = g1.id, SobjectType = ns + 'NameCard__c');
  //   qss.add(q2);
  //   insert qss;
  //   return g1.Id;
  // }

  private static Id createQueue(Boolean spLead) {
    Group g1 = new Group(Name='group name', type='Queue');
    insert g1;
    List<QueuesObject> qss = new List<QueuesObject>();
    if (spLead) {
      QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Lead');
      qss.add(q1);
    }
    String ns = SB_NameCard_Util.getNamespacePrefix_x();
    QueuesObject q2 = new QueueSObject(QueueID = g1.id, SobjectType = ns + 'NameCard__c');
    qss.add(q2);
    insert qss;
    return g1.Id;
  }


  /* --------------------------------------------- 取引先登録に関するテストStart --------------------------------------------- */

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | false  |    false     |false|false    |    false    |    false   |    false    |
  **/
  @isTest
  static void testAccount1() {
    checkAccount(false, false, false, false, false, false, false, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | true  |    false     |false|false    |    false    |    false   |    false    |
  **/
  @isTest
  static void testAccount2() {
    checkAccount(true, false, false, false, false, false, false, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | false  |    true      |false|false    |    false    |    false   |    false    |
  **/
  @isTest
  static void testAccount3() {
    checkAccount(false, true, false, false, false, false, false, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | true  |    true      |false|false    |    false    |    false   |    false    |
  **/
  @isTest
  static void testAccount4() {
    checkAccount(true, true, false, false, false, false, false, false, false, false, false, false);
  }

    /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | false  |    false     |true|false    |    false    |    false   |    false    |
  **/
  @isTest
  static void testAccount5() {
    checkAccount(false, false, true, false, false, false, false, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | true  |    false     |true |false    |    false    |    false   |    false    |
  **/
  @isTest
  static void testAccount6() {
    checkAccount(true, false, true, false, false, false, false, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | false  |    true      |true|false    |    false    |    false   |    false    |
  **/
  @isTest
  static void testAccount7() {
    checkAccount(false, true, true, false, false, false, false, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | true  |    true      |true|false    |    false    |    false   |    false    |
  **/
  @isTest
  static void testAccount8() {
    checkAccount(true, true, true, false, false, false, false, false, false, false, false, false);
  }

    /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | false  |    false     |false|false    |    false    |    false   |    false    |
  **/
  @isTest
  static void testAccount9() {
    checkAccount(false, false, false, true, false, false, false, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | true  |    false     |false|true    |    false    |    false   |    false    |
  **/
  @isTest
  static void testAccount10() {
    checkAccount(true, false, false, true, false, false, false, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | false  |    true      |false|true    |    false    |    false   |    false    |
  **/
  @isTest
  static void testAccount11() {
    checkAccount(false, true, false, true, false, false, false, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | true  |    true      |false|true    |    false    |    false   |    false    |
  **/
  @isTest
  static void testAccount12() {
    checkAccount(true, true, false, true, false, false, false, false, false, false, false, false);
  }

    /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | false  |    false     |true|true    |    false    |    false   |    false    |
  **/
  @isTest
  static void testAccount13() {
    checkAccount(false, false, true, true, false, false, false, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | true  |    false     |true |true    |    false    |    false   |    false    |
  **/
  @isTest
  static void testAccount14() {
    checkAccount(true, false, true, true, false, false, false, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | false  |    true      |true|true    |    false    |    false   |    false    |
  **/
  @isTest
  static void testAccount15() {
    checkAccount(false, true, true, true, false, false, false, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | true  |    true      |true|true    |    false    |    false   |    false    |
  **/
  @isTest
  static void testAccount16() {
    checkAccount(true, true, true, true, false, false, false, false, false, false, false, false);
  }

/**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | false  |    false     |false|false    |    true     |    false   |    false    |
  **/
  @isTest
  static void testAccount17() {
    checkAccount(false, false, false, false, true, false, false, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | true  |    false     |false|false    |    true     |    false   |    false    |
  **/
  @isTest
  static void testAccount18() {
    checkAccount(true, false, false, false, true, false, false, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | false  |    true      |false|false    |    true     |    false   |    false    |
  **/
  @isTest
  static void testAccount19() {
    checkAccount(false, true, false, false, true, false, false, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | true  |    true      |false|false    |    true     |    false   |    false    |
  **/
  @isTest
  static void testAccount20() {
    checkAccount(true, true, false, false, true, false, false, false, false, false, false, false);
  }

    /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | false  |    false     |true|false    |    true     |    false   |    false    |
  **/
  @isTest
  static void testAccount21() {
    checkAccount(false, false, true, false, true, false, false, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | true  |    false     |true |false    |    true     |    false   |    false    |
  **/
  @isTest
  static void testAccount22() {
    checkAccount(true, false, true, false, true, false, false, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | false  |    true      |true|false    |    true     |    false   |    false    |
  **/
  @isTest
  static void testAccount23() {
    checkAccount(false, true, true, false, true, false, false, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | true  |    true      |true|false    |    true     |    false   |    false    |
  **/
  @isTest
  static void testAccount24() {
    checkAccount(true, true, true, false, true, false, false, false, false, false, false, false);
  }

    /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | false  |    false     |false|false    |    true     |    false   |    false    |
  **/
  @isTest
  static void testAccount25() {
    checkAccount(false, false, false, true, true, false, false, true, true, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | true  |    false     |false|true    |    true     |    false   |    false    |
  **/
  @isTest
  static void testAccount26() {
    checkAccount(true, false, false, true, true, false, false, true, true, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | false  |    true      |false|true    |    true     |    false   |    false    |
  **/
  @isTest
  static void testAccount27() {
    checkAccount(false, true, false, true, true, false, false, true, true, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | true  |    true      |false|true    |    true     |    false   |    false    |
  **/
  @isTest
  static void testAccount28() {
    checkAccount(true, true, false, true, true, false, false, false, false, false, false, false);
  }

    /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | false  |    false     |true|true    |    true     |    false   |    false    |
  **/
  @isTest
  static void testAccount29() {
    checkAccount(false, false, true, true, true, false, false, true, true, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | true  |    false     |true |true    |    true     |    false   |    false    |
  **/
  @isTest
  static void testAccount30() {
    checkAccount(true, false, true, true, true, false, false, true, true, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | false  |    true      |true|true    |    true     |    false   |    false    |
  **/
  @isTest
  static void testAccount31() {
    checkAccount(false, true, true, true, true, false, false, true, true, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | true  |    true      |true|true    |    true     |    false   |    false    |
  **/
  @isTest
  static void testAccount32() {
    checkAccount(true, true, true, true, true, false, false, false, false, false, false, false);
  }

    /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | false  |    false     |false|false    |    false    |    true    |    false    |
  **/
  @isTest
  static void testAccount33() {
    checkAccount(false, false, false, false, false, true, false, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | true  |    false     |false|false    |    false    |    true    |    false    |
  **/
  @isTest
  static void testAccount34() {
    checkAccount(true, false, false, false, false, true, false, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | false  |    true      |false|false    |    false    |    true    |    false    |
  **/
  @isTest
  static void testAccount35() {
    checkAccount(false, true, false, false, false, true, false, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | true  |    true      |false|false    |    false    |    true    |    false    |
  **/
  @isTest
  static void testAccount36() {
    checkAccount(true, true, false, false, false, true, false, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|エラー|キューエラー|ToDoキューエラー|無効ユーザエラー|ToDoの任命先は名刺の所有者
     *              | false  |    false     |true| false  |    false    |    true    |    false    |true | false    |  false       |    true     | true
  **/
  @isTest
  static void testAccount37() {
    checkAccount(false, false, true, false, false, true, false, true, false, false, true, true);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|エラー|キューエラー|ToDoキューエラー|無効ユーザエラー|ToDoの任命先は名刺の所有者
     *              | false  |    false     |true|false    |    false    |    true    |    false   |false | false    |  false  |    false     | false 
  **/
  @isTest
  static void testAccount37_TodoOwnerContOwner() {
    checkAccount(false, false, true, false, false, true, false, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|エラー|キューエラー|ToDoキューエラー|無効ユーザエラー|ToDoの任命先は名刺の所有者
     *              | true  |    false     |true |false    |    false    |    true    |    false   |true | false    |  false  |    true     |true
  **/
  @isTest
  static void testAccount38() {
    checkAccount(true, false, true, false, false, true, false, true, false, false, true, true);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|エラー|キューエラー|ToDoキューエラー|無効ユーザエラー|ToDoの任命先は名刺の所有者
     *              | false  |    true      |true|false    |    false    |    true    |    false    |true | false    |  false  |    true     |true
  **/
  @isTest
  static void testAccount39() {
    checkAccount(false, true, true, false, false, true, false, true, false, false, true, true);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|エラー|キューエラー|ToDoキューエラー|無効ユーザエラー|ToDoの任命先は名刺の所有者
     *              | true  |    true      |true|false    |    false    |    true    |    false    |true | false    |  false  |    true     |true
  **/
  @isTest
  static void testAccount40() {
    checkAccount(true, true, true, false, false, true, false, true, false, false, true, true);
  }

    /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | false  |    false     |false|true     |    false    |    true    |    false    |
  **/
  @isTest
  static void testAccount41() {
    checkAccount(false, false, false, true, false, true, false, true, false, false, true, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | true  |    false     |false|true    |    false    |    true    |    false    |
  **/
  @isTest
  static void testAccount42() {
    checkAccount(true, false, false, true, false, true, false, true, false, false, true, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | false  |    true      |false|true    |    false    |    true    |    false    |
  **/
  @isTest
  static void testAccount43() {
    checkAccount(false, true, false, true, false, true, false, true, false, false, true, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | true  |    true      |false|true    |    false    |    true    |    false    |
  **/
  @isTest
  static void testAccount44() {
    checkAccount(true, true, false, true, false, true, false, false, false, false, false, false);
  }

    /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|エラー|キューエラー|ToDoキューエラー|無効ユーザエラー|ToDoの任命先は名刺の所有者
     *              | false  |    false     |true|  true  |    false    |    true    |    false    | true|  false   | false        | true        | true
  **/
  @isTest
  static void testAccount45() {
    checkAccount(false, false, true, true, false, true, false, true, false, false, true, true);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|エラー|キューエラー|ToDoキューエラー|無効ユーザエラー|ToDoの任命先は名刺の所有者
     *              | true  |    false     |true |true    |    false    |    true    |    false    | true|  false   | false        | true        | true
  **/
  @isTest
  static void testAccount46() {
    checkAccount(true, false, true, true, false, true, false, true, false, false, true, true);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|エラー|キューエラー|ToDoキューエラー|無効ユーザエラー|ToDoの任命先は名刺の所有者
     *              | false  |    true      |true|true    |    false    |    true    |    false    | true|  false   | false        | true        | true
  **/
  @isTest
  static void testAccount47() {
    checkAccount(false, true, true, true, false, true, false, true, false, false, true, true);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|エラー|キューエラー|ToDoキューエラー|無効ユーザエラー|ToDoの任命先は名刺の所有者
     *              | true  |    true      |true|true    |    false    |    true    |    false     | true | false    |  false  |    true     |true
  **/
  @isTest
  static void testAccount48() {
    checkAccount(true, true, true, true, false, true, false, true, false, false, true, true);
  }

    /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | false  |    true      |false|false    |    false    |    false   |    true     |
  **/
  @isTest
  static void testAccount49() {
    checkAccount(false, true, false, false, false, false, true, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | true  |    true      |false|false    |    false    |    false   |    true     |
  **/
  @isTest
  static void testAccount50() {
    checkAccount(true, true, false, false, false, false, true, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | false  |    true      |true|false    |    false    |    false   |    true     |
  **/
  @isTest
  static void testAccount51() {
    checkAccount(false, true, true, false, false, false, true, true, false, false, true, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | true  |    true      |true|false    |    false    |    false   |    true     |
  **/
  @isTest
  static void testAccount52() {
    checkAccount(true, true, true, false, false, false, true, true, false, false, true, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | false  |    true      |false|true    |    false    |    false   |    true     |
  **/
  @isTest
  static void testAccount53() {
    checkAccount(false, true, false, true, false, false, true, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | true  |    true      |false|true    |    false    |    false   |    true     |
  **/
  @isTest
  static void testAccount54() {
    checkAccount(true, true, false, true, false, false, true, false, false, false, false, false);
  }


  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | false  |    true      |true|true    |    false    |    false   |    true     |
  **/
  @isTest
  static void testAccount55() {
    checkAccount(false, true, true, true, false, false, true, true, false, false, true, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | true  |    true      |true|true    |    false    |    false   |    true     |
  **/
  @isTest
  static void testAccount56() {
    checkAccount(true, true, true, true, false, false, true, true, false, false, true, false);
  }


  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | false  |    true      |false|false    |    true     |    false   |    true     |
  **/
  @isTest
  static void testAccount57() {
    checkAccount(false, true, false, false, true, false, true, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | true  |    true      |false|false    |    true     |    false   |    true     |
  **/
  @isTest
  static void testAccount58() {
    checkAccount(true, true, false, false, true, false, true, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | false  |    true      |true|false    |    true     |    false   |    true     |
  **/
  @isTest
  static void testAccount59() {
    checkAccount(false, true, true, false, true, false, true, true, false, false, true, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | true  |    true      |true|false    |    true     |    false   |    true     |
  **/
  @isTest
  static void testAccount60() {
    checkAccount(true, true, true, false, true, false, true, true, false, false, true, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | false  |    true      |false|true    |    true     |    false   |    true     |
  **/
  @isTest
  static void testAccount61() {
    checkAccount(false, true, false, true, true, false, true, true, true, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | true  |    true      |false|true    |    true     |    false   |    true     |
  **/
  @isTest
  static void testAccount62() {
    checkAccount(true, true, false, true, true, false, true, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | false  |    true      |true|true    |    true     |    false   |    true     |
  **/
  @isTest
  static void testAccount63() {
    checkAccount(false, true, true, true, true, false, true, true, false, false, true, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | true  |    true      |true|true    |    true     |    false   |    true     |
  **/
  @isTest
  static void testAccount64() {
    checkAccount(true, true, true, true, true, false, true, true, false, false, true, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | false  |    true      |false|false    |    false    |    true    |    true     |
  **/
  @isTest
  static void testAccount65() {
    checkAccount(false, true, false, false, false, true, true, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | true  |    true      |false|false    |    false    |    true    |    true     |
  **/
  @isTest
  static void testAccount66() {
    checkAccount(true, true, false, false, false, true, true, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | false  |    true      |true|false    |    false    |    true    |    true     |
  **/
  @isTest
  static void testAccount67() {
    checkAccount(false, true, true, false, false, true, true, true, false, false, true, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | true  |    true      |true|false    |    false    |    true    |    true     |
  **/
  @isTest
  static void testAccount68() {
    checkAccount(true, true, true, false, false, true, true, true, false, false, true, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | false  |    true      |false|true    |    false    |    true    |    true     |
  **/
  @isTest
  static void testAccount69() {
    checkAccount(false, true, false, true, false, true, true, true, false, false, true, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | true  |    true      |false|true    |    false    |    true    |    true     |
  **/
  @isTest
  static void testAccount70() {
    checkAccount(true, true, false, true, false, true, true, false, false, false, false, false);
  }


  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | false  |    true      |true|true    |    false    |    true    |    true     |
  **/
  @isTest
  static void testAccount71() {
    checkAccount(false, true, true, true, false, true, true, true, false, false, true, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              | true  |    true      |true|true    |    false    |    true    |    true     |
  **/
  @isTest
  static void testAccount72() {
    checkAccount(true, true, true, true, false, true, true, true, false, false, true, false);
  }

  private static void checkAccount(Boolean updateAccount,
                            Boolean updateContact,
                            Boolean haveToDo,
                            Boolean useNameCard,
                            Boolean nameCardQueue,
                            Boolean nameCardNoActive,
                            Boolean contactNoActive,
                            Boolean haveError,
                            Boolean queueError,
                            Boolean todoQuesuError,
                            Boolean activeUserError,
                            Boolean todoOwnerIsCardOwner) { // ToDoの任命先は名刺の所有者
    List<User> us = insertUser();
    System.runAs(us[0]) {
      NameCard__c nc = new NameCard__c(Name = 'TestNameCard',
                                      company_name__c = 'Testcompany',
                                      person_name_last__c = 'TestLast',
                                      person_name_first__c = 'TestFirst'
                                      );
      // 名刺所有者はキュー
      if (nameCardQueue) {
        nc.OwnerId = createQueue(false);
      }
      else if (nameCardNoActive) {
        nc.OwnerId = us[1].Id;
      }
      insert nc;
      // 取引先
      Account ac = new Account();
      if (updateAccount) {
        ac = new Account(Name = nc.company_name__c);
        insert ac;
      }
      // 取引先責任者
      Contact con = new Contact();
      if (updateContact) {
        con = new Contact(LastName = 'TestLast',
                          AccountId = ac.Id);
        if (contactNoActive) {
          con.OwnerId = us[1].Id;
        }
        insert con;
      }
      if (nameCardNoActive || contactNoActive) {
        us[1].IsActive = false;
        update us[1];
      }
      List<SB_NC_RegistExecutor.RegistTarget> tars = new List<SB_NC_RegistExecutor.RegistTarget>();
      SB_NC_RegistExecutor.RegistTarget tar = new SB_NC_RegistExecutor.RegistTarget(nc.Id,
                                                                                    ac.Id,
                                                                                    con.Id,
                                                                                    null,
                                                                                    haveToDo,
                                                                                    null);
      tars.add(tar);

      String oIdAccount = null;
      if (useNameCard == false) {
        oIdAccount = UserInfo.getUserId();
      }

      SB_NC_RegistExecutor.TodoParam todoRP = new SB_NC_RegistExecutor.TodoParam(SB_NameCard_BasicSetting.getNameCardBasicSetting().RegistToDoSubject__c,null,null,null);
      SB_NC_RegistExecutor.RegistParam accountRP = new SB_NC_RegistExecutor.RegistParam('Account', true, null,oIdAccount,false);
      SB_NC_RegistExecutor.RegistParam contactRP = new SB_NC_RegistExecutor.RegistParam('Contact', true, null,oIdAccount,false);
      SB_NC_RegistExecutor.RegistRequest re = new SB_NC_RegistExecutor.RegistRequest(tars, accountRP, contactRP, null, todoRP);
      Map<Id, String> ownerErrorMap = SB_NameCard_RegistOwnerCheckHelper.doCheck(re, todoOwnerIsCardOwner);

      if (queueError == false
         && todoQuesuError == false
         && activeUserError == false) {
        System.assertEquals(true, ownerErrorMap.isEmpty());
      }
      else if (queueError) {
        System.assertEquals(true, !ownerErrorMap.isEmpty());
        System.assertEquals(true, ownerErrorMap.containsKey(nc.Id));
        System.assertEquals(System.Label.SB_NC_MSG_NAMECARD_OWNER_QUEUE, ownerErrorMap.get(nc.Id));
      }
      else if (todoQuesuError) {
        System.assertEquals(true, !ownerErrorMap.isEmpty());
        System.assertEquals(true, ownerErrorMap.containsKey(nc.Id));
        String todoLabel = Task.getSobjectType().getDescribe().getLabel();
        String message = todoLabel +
                                    System.Label.SB_NC_MSG_Regist_Error + ': ' +
                                    String.format(System.Label.SB_NC_MSG_QUEUES_ERROR, new String[]{'group name'});
        System.assertEquals(message, ownerErrorMap.get(nc.Id));
      }
      else if (activeUserError) {
        System.assertEquals(true, !ownerErrorMap.isEmpty());
        System.assertEquals(true, ownerErrorMap.containsKey(nc.Id));
        if (haveToDo) {
          System.assertEquals(String.format(System.Label.SB_NC_MSG_CanNotSetInActiveUserToOwnerToDo, new String[] {us[1].Name}), ownerErrorMap.get(nc.Id));
        }
        else {
          System.assertEquals(System.Label.SB_NC_MSG_CanNotSetInActiveUserToOwner, ownerErrorMap.get(nc.Id));
        }
      }
    }
  }

  /* --------------------------------------------- 取引先登録に関するテストEnd --------------------------------------------- */


}