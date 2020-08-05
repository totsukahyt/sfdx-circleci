/*
 * (c) 2018 Sunbridge Inc.
 * SB_NameCardL_RegistOwenrCheckHelper
 * SB_NameCardL_RegistOwenrCheckHelperクラスのテストクラス
 *
 * @author mao
 * @Version 拡張パッケージ：Lead Ex. 1.12 2018/8/XX
 *
 */

@isTest
public class SB_NameCardL_RegistOwenrCheckHelperTest {
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

    list<PermissionSet> psList = [SELECT Id FROM PermissionSet WHERE Name IN ('SmartViscaAdminUser','SmartViscaAdvancedUser','SmartViscaRenkeiUser','SmartViscaUser','SmartViscaLeadAdminUser')];
    PermissionSetAssignment psa1 = new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = psList[0].Id);
    PermissionSetAssignment psa2 = new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = psList[1].Id);
    PermissionSetAssignment psa3 = new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = psList[2].Id);
    PermissionSetAssignment psa4 = new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = psList[3].Id);
    PermissionSetAssignment psa5 = new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = psList[4].Id);
    insert new PermissionSetAssignment[]{psa1,psa2,psa3,psa4,psa5};

    us.add(u);
    us.add(u1);
    return [SELECT Id, Name From User Where Id in: us];
  }

  private static Id insertQueue(Boolean leadCanUse) {
    Group g1 = new Group(Name='group name', type='Queue');
    insert g1;
    List<QueuesObject> qss = new List<QueuesObject>();
    if (leadCanUse) {
        QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Lead');
        qss.add(q1);
    }
    QueuesObject q2 = new QueueSObject(QueueID = g1.id, SobjectType = 'SmartViscaf__NameCard__c');
    qss.add(q2);
    insert qss;
    return g1.Id;
  }

    private static Id createQueue(Boolean spLead) {
      Group g1 = new Group(Name='group name', type='Queue');
      insert g1;
      List<QueuesObject> qss = new List<QueuesObject>();
      if (spLead) {
        QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Lead');
        qss.add(q1);
      }
      QueuesObject q2 = new QueueSObject(QueueID = g1.id, SobjectType = 'SmartViscaf__NameCard__c');
      qss.add(q2);
      insert qss;
      return g1.Id;
  }


  /* --------------------------------------------- 取引先登録に関するテストStart --------------------------------------------- */

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  OFF   |     OFF      | OFF| OFF     |     OFF     |     OFF    |     OFF     |
  **/
  @isTest
  static void testAccount1() {
    checkAccount(false, false, false, false, false, false, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  ON   |     OFF      | OFF | OFF     |     OFF     |     OFF    |     OFF     |
  **/
  @isTest
  static void testAccount2() {
    checkAccount(true, false, false, false, false, false, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  OFF   |     ON       | OFF| OFF     |     OFF     |     OFF    |     OFF     |
  **/
  @isTest
  static void testAccount3() {
    checkAccount(false, true, false, false, false, false, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  ON   |     ON       | OFF| OFF     |     OFF     |     OFF    |     OFF     |
  **/
  @isTest
  static void testAccount4() {
    checkAccount(true, true, false, false, false, false, false, false, false, false, false);
  }

    /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  OFF   |     OFF      | ON | OFF     |     OFF     |     OFF    |     OFF     |
  **/
  @isTest
  static void testAccount5() {
    checkAccount(false, false, true, false, false, false, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  ON   |     OFF      | ON  | OFF     |     OFF     |     OFF    |     OFF     |
  **/
  @isTest
  static void testAccount6() {
    checkAccount(true, false, true, false, false, false, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  OFF   |     ON       | ON | OFF     |     OFF     |     OFF    |     OFF     |
  **/
  @isTest
  static void testAccount7() {
    checkAccount(false, true, true, false, false, false, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  ON   |     ON       | ON | OFF     |     OFF     |     OFF    |     OFF     |
  **/
  @isTest
  static void testAccount8() {
    checkAccount(true, true, true, false, false, false, false, false, false, false, false);
  }

    /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  OFF   |     OFF      | OFF| OFF     |     OFF     |     OFF    |     OFF     |
  **/
  @isTest
  static void testAccount9() {
    checkAccount(false, false, false, true, false, false, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  ON   |     OFF      | OFF | ON     |     OFF     |     OFF    |     OFF     |
  **/
  @isTest
  static void testAccount10() {
    checkAccount(true, false, false, true, false, false, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  OFF   |     ON       | OFF| ON     |     OFF     |     OFF    |     OFF     |
  **/
  @isTest
  static void testAccount11() {
    checkAccount(false, true, false, true, false, false, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  ON   |     ON       | OFF| ON     |     OFF     |     OFF    |     OFF     |
  **/
  @isTest
  static void testAccount12() {
    checkAccount(true, true, false, true, false, false, false, false, false, false, false);
  }

    /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  OFF   |     OFF      | ON | ON     |     OFF     |     OFF    |     OFF     |
  **/
  @isTest
  static void testAccount13() {
    checkAccount(false, false, true, true, false, false, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  ON   |     OFF      | ON  | ON     |     OFF     |     OFF    |     OFF     |
  **/
  @isTest
  static void testAccount14() {
    checkAccount(true, false, true, true, false, false, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  OFF   |     ON       | ON | ON     |     OFF     |     OFF    |     OFF     |
  **/
  @isTest
  static void testAccount15() {
    checkAccount(false, true, true, true, false, false, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  ON   |     ON       | ON | ON     |     OFF     |     OFF    |     OFF     |
  **/
  @isTest
  static void testAccount16() {
    checkAccount(true, true, true, true, false, false, false, false, false, false, false);
  }

/**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  OFF   |     OFF      | OFF| OFF     |     ON      |     OFF    |     OFF     |
  **/
  @isTest
  static void testAccount17() {
    checkAccount(false, false, false, false, true, false, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  ON   |     OFF      | OFF | OFF     |     ON      |     OFF    |     OFF     |
  **/
  @isTest
  static void testAccount18() {
    checkAccount(true, false, false, false, true, false, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  OFF   |     ON       | OFF| OFF     |     ON      |     OFF    |     OFF     |
  **/
  @isTest
  static void testAccount19() {
    checkAccount(false, true, false, false, true, false, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  ON   |     ON       | OFF| OFF     |     ON      |     OFF    |     OFF     |
  **/
  @isTest
  static void testAccount20() {
    checkAccount(true, true, false, false, true, false, false, false, false, false, false);
  }

    /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  OFF   |     OFF      | ON | OFF     |     ON      |     OFF    |     OFF     |
  **/
  @isTest
  static void testAccount21() {
    checkAccount(false, false, true, false, true, false, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  ON   |     OFF      | ON  | OFF     |     ON      |     OFF    |     OFF     |
  **/
  @isTest
  static void testAccount22() {
    checkAccount(true, false, true, false, true, false, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  OFF   |     ON       | ON | OFF     |     ON      |     OFF    |     OFF     |
  **/
  @isTest
  static void testAccount23() {
    checkAccount(false, true, true, false, true, false, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  ON   |     ON       | ON | OFF     |     ON      |     OFF    |     OFF     |
  **/
  @isTest
  static void testAccount24() {
    checkAccount(true, true, true, false, true, false, false, false, false, false, false);
  }

    /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  OFF   |     OFF      | OFF| OFF     |     ON      |     OFF    |     OFF     |
  **/
  @isTest
  static void testAccount25() {
    checkAccount(false, false, false, true, true, false, false, true, true, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  ON   |     OFF      | OFF | ON     |     ON      |     OFF    |     OFF     |
  **/
  @isTest
  static void testAccount26() {
    checkAccount(true, false, false, true, true, false, false, true, true, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  OFF   |     ON       | OFF| ON     |     ON      |     OFF    |     OFF     |
  **/
  @isTest
  static void testAccount27() {
    checkAccount(false, true, false, true, true, false, false, true, true, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  ON   |     ON       | OFF| ON     |     ON      |     OFF    |     OFF     |
  **/
  @isTest
  static void testAccount28() {
    checkAccount(true, true, false, true, true, false, false, false, false, false, false);
  }

    /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  OFF   |     OFF      | ON | ON     |     ON      |     OFF    |     OFF     |
  **/
  @isTest
  static void testAccount29() {
    checkAccount(false, false, true, true, true, false, false, true, true, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  ON   |     OFF      | ON  | ON     |     ON      |     OFF    |     OFF     |
  **/
  @isTest
  static void testAccount30() {
    checkAccount(true, false, true, true, true, false, false, true, true, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  OFF   |     ON       | ON | ON     |     ON      |     OFF    |     OFF     |
  **/
  @isTest
  static void testAccount31() {
    checkAccount(false, true, true, true, true, false, false, true, true, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  ON   |     ON       | ON | ON     |     ON      |     OFF    |     OFF     |
  **/
  @isTest
  static void testAccount32() {
    checkAccount(true, true, true, true, true, false, false, false, false, false, false);
  }

    /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  OFF   |     OFF      | OFF| OFF     |     OFF     |     ON     |     OFF     |
  **/
  @isTest
  static void testAccount33() {
    checkAccount(false, false, false, false, false, true, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  ON   |     OFF      | OFF | OFF     |     OFF     |     ON     |     OFF     |
  **/
  @isTest
  static void testAccount34() {
    checkAccount(true, false, false, false, false, true, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  OFF   |     ON       | OFF| OFF     |     OFF     |     ON     |     OFF     |
  **/
  @isTest
  static void testAccount35() {
    checkAccount(false, true, false, false, false, true, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  ON   |     ON       | OFF| OFF     |     OFF     |     ON     |     OFF     |
  **/
  @isTest
  static void testAccount36() {
    checkAccount(true, true, false, false, false, true, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  OFF   |     OFF      | ON | OFF     |     OFF     |     ON     |     OFF     |
  **/
  @isTest
  static void testAccount37() {
    checkAccount(false, false, true, false, false, true, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  ON   |     OFF      | ON  | OFF     |     OFF     |     ON     |     OFF     |
  **/
  @isTest
  static void testAccount38() {
    checkAccount(true, false, true, false, false, true, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  OFF   |     ON       | ON | OFF     |     OFF     |     ON     |     OFF     |
  **/
  @isTest
  static void testAccount39() {
    checkAccount(false, true, true, false, false, true, false, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  ON   |     ON       | ON | OFF     |     OFF     |     ON     |     OFF     |
  **/
  @isTest
  static void testAccount40() {
    checkAccount(true, true, true, false, false, true, false, false, false, false, false);
  }

    /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  OFF   |     OFF      | OFF| ON      |     OFF     |     ON     |     OFF     |
  **/
  @isTest
  static void testAccount41() {
    checkAccount(false, false, false, true, false, true, false, true, false, false, true);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  ON   |     OFF      | OFF | ON     |     OFF     |     ON     |     OFF     |
  **/
  @isTest
  static void testAccount42() {
    checkAccount(true, false, false, true, false, true, false, true, false, false, true);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  OFF   |     ON       | OFF| ON     |     OFF     |     ON     |     OFF     |
  **/
  @isTest
  static void testAccount43() {
    checkAccount(false, true, false, true, false, true, false, true, false, false, true);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  ON   |     ON       | OFF| ON     |     OFF     |     ON     |     OFF     |
  **/
  @isTest
  static void testAccount44() {
    checkAccount(true, true, false, true, false, true, false, false, false, false, false);
  }

    /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  OFF   |     OFF      | ON | ON     |     OFF     |     ON     |     OFF     |
  **/
  @isTest
  static void testAccount45() {
    checkAccount(false, false, true, true, false, true, false, true, false, false, true);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  ON   |     OFF      | ON  | ON     |     OFF     |     ON     |     OFF     |
  **/
  @isTest
  static void testAccount46() {
    checkAccount(true, false, true, true, false, true, false, true, false, false, true);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  OFF   |     ON       | ON | ON     |     OFF     |     ON     |     OFF     |
  **/
  @isTest
  static void testAccount47() {
    checkAccount(false, true, true, true, false, true, false, true, false, false, true);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  ON   |     ON       | ON | ON     |     OFF     |     ON     |     OFF     |
  **/
  @isTest
  static void testAccount48() {
    checkAccount(true, true, true, true, false, true, false, false, false, false, false);
  }

    /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  OFF   |     ON       | OFF| OFF     |     OFF     |     OFF    |     ON      |
  **/
  @isTest
  static void testAccount49() {
    checkAccount(false, true, false, false, false, false, true, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  ON   |     ON       | OFF| OFF     |     OFF     |     OFF    |     ON      |
  **/
  @isTest
  static void testAccount50() {
    checkAccount(true, true, false, false, false, false, true, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  OFF   |     ON       | ON | OFF     |     OFF     |     OFF    |     ON      |
  **/
  @isTest
  static void testAccount51() {
    checkAccount(false, true, true, false, false, false, true, true, false, false, true);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  ON   |     ON       | ON | OFF     |     OFF     |     OFF    |     ON      |
  **/
  @isTest
  static void testAccount52() {
    checkAccount(true, true, true, false, false, false, true, true, false, false, true);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  OFF   |     ON       | OFF| ON     |     OFF     |     OFF    |     ON      |
  **/
  @isTest
  static void testAccount53() {
    checkAccount(false, true, false, true, false, false, true, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  ON   |     ON       | OFF| ON     |     OFF     |     OFF    |     ON      |
  **/
  @isTest
  static void testAccount54() {
    checkAccount(true, true, false, true, false, false, true, false, false, false, false);
  }


  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  OFF   |     ON       | ON | ON     |     OFF     |     OFF    |     ON      |
  **/
  @isTest
  static void testAccount55() {
    checkAccount(false, true, true, true, false, false, true, true, false, false, true);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  ON   |     ON       | ON | ON     |     OFF     |     OFF    |     ON      |
  **/
  @isTest
  static void testAccount56() {
    checkAccount(true, true, true, true, false, false, true, true, false, false, true);
  }


  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  OFF   |     ON       | OFF| OFF     |     ON      |     OFF    |     ON      |
  **/
  @isTest
  static void testAccount57() {
    checkAccount(false, true, false, false, true, false, true, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  ON   |     ON       | OFF| OFF     |     ON      |     OFF    |     ON      |
  **/
  @isTest
  static void testAccount58() {
    checkAccount(true, true, false, false, true, false, true, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  OFF   |     ON       | ON | OFF     |     ON      |     OFF    |     ON      |
  **/
  @isTest
  static void testAccount59() {
    checkAccount(false, true, true, false, true, false, true, true, false, false, true);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  ON   |     ON       | ON | OFF     |     ON      |     OFF    |     ON      |
  **/
  @isTest
  static void testAccount60() {
    checkAccount(true, true, true, false, true, false, true, true, false, false, true);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  OFF   |     ON       | OFF| ON     |     ON      |     OFF    |     ON      |
  **/
  @isTest
  static void testAccount61() {
    checkAccount(false, true, false, true, true, false, true, true, true, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  ON   |     ON       | OFF| ON     |     ON      |     OFF    |     ON      |
  **/
  @isTest
  static void testAccount62() {
    checkAccount(true, true, false, true, true, false, true, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  OFF   |     ON       | ON | ON     |     ON      |     OFF    |     ON      |
  **/
  @isTest
  static void testAccount63() {
    checkAccount(false, true, true, true, true, false, true, true, false, false, true);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  ON   |     ON       | ON | ON     |     ON      |     OFF    |     ON      |
  **/
  @isTest
  static void testAccount64() {
    checkAccount(true, true, true, true, true, false, true, true, false, false, true);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  OFF   |     ON       | OFF| OFF     |     OFF     |     ON     |     ON      |
  **/
  @isTest
  static void testAccount65() {
    checkAccount(false, true, false, false, false, true, true, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  ON   |     ON       | OFF| OFF     |     OFF     |     ON     |     ON      |
  **/
  @isTest
  static void testAccount66() {
    checkAccount(true, true, false, false, false, true, true, false, false, false, false);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  OFF   |     ON       | ON | OFF     |     OFF     |     ON     |     ON      |
  **/
  @isTest
  static void testAccount67() {
    checkAccount(false, true, true, false, false, true, true, true, false, false, true);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  ON   |     ON       | ON | OFF     |     OFF     |     ON     |     ON      |
  **/
  @isTest
  static void testAccount68() {
    checkAccount(true, true, true, false, false, true, true, true, false, false, true);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  OFF   |     ON       | OFF| ON     |     OFF     |     ON     |     ON      |
  **/
  @isTest
  static void testAccount69() {
    checkAccount(false, true, false, true, false, true, true, true, false, false, true);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  ON   |     ON       | OFF| ON     |     OFF     |     ON     |     ON      |
  **/
  @isTest
  static void testAccount70() {
    checkAccount(true, true, false, true, false, true, true, false, false, false, false);
  }


  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  OFF   |     ON       | ON | ON     |     OFF     |     ON     |     ON      |
  **/
  @isTest
  static void testAccount71() {
    checkAccount(false, true, true, true, false, true, true, true, false, false, true);
  }

  /**
     * @description |取引先更新|取引先責任者更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者無効|責任者所有者無効|
     *              |  ON   |     ON       | ON | ON     |     OFF     |     ON     |     ON      |
  **/
  @isTest
  static void testAccount72() {
    checkAccount(true, true, true, true, false, true, true, true, false, false, true);
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
                            Boolean todoError,
                            Boolean activeUserError) {
    List<User> us = insertUser();
    System.runAs(us[0]) {
      SmartViscaf__NameCard__c nc = new SmartViscaf__NameCard__c(Name = 'TestNameCard',
                                                                 SmartViscaf__company_name__c = 'Testcompany',
                                                                 SmartViscaf__person_name_last__c = 'TestLast',
                                                                 SmartViscaf__person_name_first__c = 'TestFirst'
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
        ac = new Account(Name = nc.SmartViscaf__company_name__c);
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
      List<SB_NameCardL_RegistHelper.RegistTarget> tars = new List<SB_NameCardL_RegistHelper.RegistTarget>();
      SB_NameCardL_RegistHelper.RegistTarget tar = new SB_NameCardL_RegistHelper.RegistTarget(SB_NameCardL_RegistHelper.ProcType.ACCOUNT,
                                                                                                        nc.Id,
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

      SB_NameCardL_RegistHelper.TodoParam todoRP = new SB_NameCardL_RegistHelper.TodoParam(SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RegistToDoSubject__c,null,null,null);
      SB_NameCardL_RegistHelper.RegistParam accountRP = new SB_NameCardL_RegistHelper.RegistParam('Account', true, null,oIdAccount,false);
      SB_NameCardL_RegistHelper.RegistParam contactRP = new SB_NameCardL_RegistHelper.RegistParam('Contact', true, null,oIdAccount,false);
      SB_NameCardL_RegistHelper.RegistRequest re = new SB_NameCardL_RegistHelper.RegistRequest(tars, accountRP, contactRP, null, todoRP);
      Map<Id, String> ownerErrorMap = SB_NameCardL_RegistOwenrCheckHelper.doCheck(re);

      if (queueError == false
         && todoError == false
         && activeUserError == false) {
        System.assertEquals(true, ownerErrorMap.isEmpty());
      }
      else if (queueError) {
        System.assertEquals(true, !ownerErrorMap.isEmpty());
        System.assertEquals(true, ownerErrorMap.containsKey(nc.Id));
        System.assertEquals(System.Label.SB_NCLD_Label_NameCard_Owner_Queue, ownerErrorMap.get(nc.Id));
      }
      else if (todoError) {
        System.assertEquals(true, !ownerErrorMap.isEmpty());
        System.assertEquals(true, ownerErrorMap.containsKey(nc.Id));
        String todoLabel = Task.getSobjectType().getDescribe().getLabel();
        String message = todoLabel +
                                    System.Label.SB_NCLD_MSG_Regist_Error + ': ' +
                                    String.format(System.Label.SB_NCLD_MSG_QUEUES_ERROR, new String[]{'group name'});
        System.assertEquals(message, ownerErrorMap.get(nc.Id));
      }
      else if (activeUserError) {
        System.assertEquals(true, !ownerErrorMap.isEmpty());
        System.assertEquals(true, ownerErrorMap.containsKey(nc.Id));
        if (haveToDo) {
          System.assertEquals(String.format(System.Label.SB_NCLD_MSG_CanNotSetInActiveUserToOwnerToDo, new String[] {us[1].Name}), ownerErrorMap.get(nc.Id));
        }
        else {
          System.assertEquals(System.Label.SB_NCLD_MSG_CanNotSetInActiveUserToOwner, ownerErrorMap.get(nc.Id));
        }
      }
    }
  }

  /* --------------------------------------------- 取引先登録に関するテストEnd --------------------------------------------- */

  /* --------------------------------------------- リードに関するStart --------------------------------------------- */

  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  OFF   | OFF| OFF    |       OFF    |           OFF                |     OFF    |       OFF      |      OFF    |
  **/
  @isTest
  static void testLead1() {
    checkLead(false, false, false, false, false, false, false, false, false, false, false, false, false);
  }

  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  ON    | OFF| OFF    |       OFF    |           OFF                |     OFF    |       OFF      |      OFF    |
  **/
  @isTest
  static void testLead2() {
    checkLead(true, false, false, false, false, false, false, false, false, false, false, false, false);
  }

  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  OFF   | ON | OFF    |       OFF    |           OFF                |     OFF    |       OFF      |      OFF    |
  **/
  @isTest
  static void testLead3() {
    checkLead(false, true, false, false, false, false, false, false, false, false, false, false, false);
  }

  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  ON    | ON | OFF    |       OFF    |           OFF                |     OFF    |       OFF      |      OFF    |
  **/
  @isTest
  static void testLead4() {
    checkLead(true, true, false, false, false, false, false, false, false, false, false, false, false);
  }

  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  OFF   | OFF| ON     |       OFF    |           OFF                |     OFF    |       OFF      |      OFF    |
  **/
  @isTest
  static void testLead5() {
    checkLead(false, false, true, false, false, false, false, false, false, false, false, false, false);
  }

  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  ON    | OFF| ON    |       OFF    |           OFF                |     OFF    |       OFF      |      OFF    |
  **/
  @isTest
  static void testLead6() {
    checkLead(true, false, true, false, false, false, false, false, false, false, false, false, false);
  }

  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  OFF   | ON | ON    |       OFF    |           OFF                |     OFF    |       OFF      |      OFF    |
  **/
  @isTest
  static void testLead7() {
    checkLead(false, true, true, false, false, false, false, false, false, false, false, false, false);
  }

  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  ON    | ON | ON    |       OFF    |           OFF                |     OFF    |       OFF      |      OFF    |
  **/
  @isTest
  static void testLead8() {
    checkLead(true, true, true, false, false, false, false, false, false, false, false, false, false);
  }

  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  OFF   | OFF| ON     |       ON     |           OFF                |     OFF    |       OFF      |      OFF    |
  **/
  @isTest
  static void testLead9() {
    checkLead(false, false, true, true, false, false, false, false, false, false, false, false, false);
  }

  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  ON    | OFF| ON    |       ON     |           OFF                |     OFF    |       OFF      |      OFF    |
  **/
  @isTest
  static void testLead10() {
    checkLead(true, false, true, true, false, false, false, false, false, false, false, false, false);
  }

  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  OFF   | ON | ON    |       ON     |           OFF                |     OFF    |       OFF      |      OFF    |
  **/
  @isTest
  static void testLead11() {
    checkLead(false, true, true, true, false, false, false, false, true, false, false, true, false);
  }

  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  ON    | ON | ON    |       ON     |           OFF                |     OFF    |       OFF      |      OFF    |
  **/
  @isTest
  static void testLead12() {
    checkLead(true, true, true, true, false, false, false, false, false, false, false, false, false);
  }

  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  OFF   | OFF| ON     |       ON     |           ON                 |     OFF    |       OFF      |      OFF    |
  **/
  @isTest
  static void testLead13() {
    checkLead(false, false, true, true, true, false, false, false, true, false, true, false, false);
  }

  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  ON    | OFF| ON    |       ON     |           ON                 |     OFF    |       OFF      |      OFF    |
  **/
  @isTest
  static void testLead14() {
    checkLead(true, false, true, true, true, false, false, false, false, false, false, false, false);
  }

  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  OFF   | ON | ON    |       ON     |           ON                 |     OFF    |       OFF      |      OFF    |
  **/
  @isTest
  static void testLead15() {
    checkLead(false, true, true, true, true, false, false, false, true, false, false, true, false);
  }

  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  ON    | ON | ON    |       ON     |           ON                 |     OFF    |       OFF      |      OFF    |
  **/
  @isTest
  static void testLead16() {
    checkLead(true, true, true, true, true, false, false, false, false, false, false, false, false);
  }

  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  OFF   | OFF| ON     |       OFF    |           OFF                |     ON     |       OFF      |      OFF    |
  **/
  @isTest
  static void testLead17() {
    checkLead(false, false, true, false, false, true, false, false, true, false, false, false, true);
  }

  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  ON    | OFF| ON    |       OFF    |           OFF                |     ON     |       OFF      |      OFF    |
  **/
  @isTest
  static void testLead18() {
    checkLead(true, false, true, false, false, true, false, false, false, false, false, false, false);
  }

  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  OFF   | ON | ON    |       OFF    |           OFF                |     ON     |       OFF      |      OFF    |
  **/
  @isTest
  static void testLead19() {
    checkLead(false, true, true, false, false, true, false, false, true, false, false, false, true);
  }

  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  ON    | ON | ON    |       OFF    |           OFF                |     ON     |       OFF      |      OFF    |
  **/
  @isTest
  static void testLead20() {
    checkLead(true, true, true, false, false, true, false, false, false, false, false, false, false);
  }

    /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  OFF   | OFF| OFF    |       OFF    |           OFF                |     OFF    |       ON       |      OFF    |
  **/
  @isTest
  static void testLead21() {
    checkLead(false, false, false, false, false, false, true, false, false, false, false, false, false);
  }

  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  ON    | OFF| OFF    |       OFF    |           OFF                |     OFF    |       ON       |      OFF    |
  **/
  @isTest
  static void testLead22() {
    checkLead(true, false, false, false, false, false, true, false, false, false, false, false, false);
  }

  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  OFF   | ON | OFF    |       OFF    |           OFF                |     OFF    |       ON       |      OFF    |
  **/
  @isTest
  static void testLead23() {
    checkLead(false, true, false, false, false, false, true, false, false, false, false, false, false);
  }

  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  ON    | ON | OFF    |       OFF    |           OFF                |     OFF    |       ON       |      OFF    |
  **/
  @isTest
  static void testLead24() {
    checkLead(true, true, false, false, false, false, true, false, true, false, false, true, false);
  }

  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  OFF   | OFF| ON     |       OFF    |           OFF                |     OFF    |       ON       |      OFF    |
  **/
  @isTest
  static void testLead25() {
    checkLead(false, false, true, false, false, false, true, false, false, false, false, false, false);
  }

  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  ON    | OFF| ON    |       OFF    |           OFF                |     OFF    |       ON       |      OFF    |
  **/
  @isTest
  static void testLead26() {
    checkLead(true, false, true, false, false, false, true, false, false, false, false, false, false);
  }

  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  OFF   | ON | ON    |       OFF    |           OFF                |     OFF    |       ON       |      OFF    |
  **/
  @isTest
  static void testLead27() {
    checkLead(false, true, true, false, false, false, true, false, false, false, false, false, false);
  }

  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  ON    | ON | ON    |       OFF    |           OFF                |     OFF    |       ON       |      OFF    |
  **/
  @isTest
  static void testLead28() {
    checkLead(true, true, true, false, false, false, true, false, true, false, false, true, false);
  }

  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  OFF   | OFF| ON     |       ON     |           OFF                |     OFF    |       ON       |      OFF    |
  **/
  @isTest
  static void testLead29() {
    checkLead(false, false, true, true, false, false, true, false, false, false, false, false, false);
  }

  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  ON    | OFF| ON    |       ON     |           OFF                |     OFF    |       ON       |      OFF    |
  **/
  @isTest
  static void testLead30() {
    checkLead(true, false, true, true, false, false, true, false, false, false, false, false, false);
  }

  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  OFF   | ON | ON    |       ON     |           OFF                |     OFF    |       ON       |      OFF    |
  **/
  @isTest
  static void testLead31() {
    checkLead(false, true, true, true, false, false, true, false, true, false, false, true, false);
  }

  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  ON    | ON | ON    |       ON     |           OFF                |     OFF    |       ON       |      OFF    |
  **/
  @isTest
  static void testLead32() {
    checkLead(true, true, true, true, false, false, true, false, true, false, false, true, false);
  }

  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  OFF   | OFF| ON     |       ON     |           ON                 |     OFF    |       ON       |      OFF    |
  **/
  @isTest
  static void testLead33() {
    checkLead(false, false, true, true, true, false, true, false, true, false, true, false, false);
  }

  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  ON    | OFF| ON    |       ON     |           ON                 |     OFF    |       ON       |      OFF    |
  **/
  @isTest
  static void testLead34() {
    checkLead(true, false, true, true, true, false, true, false, false, false, false, false, false);
  }

  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  OFF   | ON | ON    |       ON     |           ON                 |     OFF    |       ON       |      OFF    |
  **/
  @isTest
  static void testLead35() {
    checkLead(false, true, true, true, true, false, true, false, true, false, false, true, false);
  }

  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  ON    | ON | ON    |       ON     |           ON                 |     OFF    |       ON       |      OFF    |
  **/
  @isTest
  static void testLead36() {
    checkLead(true, true, true, true, true, false, true, false, true, false, false, true, false);
  }

  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  OFF   | OFF| ON     |       OFF    |           OFF                |     ON     |       ON       |      OFF    |
  **/
  @isTest
  static void testLead37() {
    checkLead(false, false, true, false, false, true, true, false, true, false, false, false, true);
  }

  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  ON    | OFF| ON    |       OFF    |           OFF                |     ON     |       ON       |      OFF    |
  **/
  @isTest
  static void testLead38() {
    checkLead(true, false, true, false, false, true, true, false, false, false, false, false, false);
  }

  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  OFF   | ON | ON    |       OFF    |           OFF                |     ON     |       ON       |      OFF    |
  **/
  @isTest
  static void testLead39() {
    checkLead(false, true, true, false, false, true, true, false, true, false, false, false, true);
  }

  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  ON    | ON | ON    |       OFF    |           OFF                |     ON     |       ON       |      OFF    |
  **/
  @isTest
  static void testLead40() {
    checkLead(true, true, true, false, false, true, true, false, true, false, false, true, false);
  }



  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  OFF   | ON | OFF    |       OFF    |           OFF                |     OFF    |       OFF      |      ON     |
  **/
  @isTest
  static void testLead41() {
    checkLead(false, true, false, false, false, false, false, true, false, false, false, false, false);
  }

  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  ON    | ON | OFF    |       OFF    |           OFF                |     OFF    |       OFF      |      ON     |
  **/
  @isTest
  static void testLead42() {
    checkLead(true, true, false, false, false, false, false, true, true, false, false, false, true);
  }


  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  OFF   | ON | ON    |       OFF    |           OFF                |     OFF    |       OFF      |      ON     |
  **/
  @isTest
  static void testLead43() {
    checkLead(false, true, true, false, false, false, false, true, false, false, false, false, false);
  }

  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  ON    | ON | ON    |       OFF    |           OFF                |     OFF    |       OFF      |      ON     |
  **/
  @isTest
  static void testLead44() {
    checkLead(true, true, true, false, false, false, false, true, true, false, false, false, true);
  }

  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  OFF   | ON | ON    |       ON     |           OFF                |     OFF    |       OFF      |      ON     |
  **/
  @isTest
  static void testLead45() {
    checkLead(false, true, true, true, false, false, false, true, true, false, false, true, false);
  }

  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  ON    | ON | ON    |       ON     |           OFF                |     OFF    |       OFF      |      ON     |
  **/
  @isTest
  static void testLead46() {
    checkLead(true, true, true, true, false, false, false, true, true, false, false, false, true);
  }


  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  OFF   | ON | ON    |       ON     |           ON                 |     OFF    |       OFF      |      ON     |
  **/
  @isTest
  static void testLead47() {
    checkLead(false, true, true, true, true, false, false, true, true, false, false, true, false);
  }

  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  ON    | ON | ON    |       ON     |           ON                 |     OFF    |       OFF      |      ON     |
  **/
  @isTest
  static void testLead48() {
    checkLead(true, true, true, true, true, false, false, true, true, false, false, false, true);
  }

  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  OFF   | ON | ON    |       OFF    |           OFF                |     ON     |       OFF      |      ON     |
  **/
  @isTest
  static void testLead49() {
    checkLead(false, true, true, false, false, true, false, true, true, false, false, false, true);
  }

  /**
     * @description |リード更新|ToDo|名刺所有者|名刺所有者キュー|名刺所有者キューリードサポートしない|名刺所有者無効|リード所有者キュー|リード所有者無効|
     *              |  ON    | ON | ON    |       OFF    |           OFF                |     ON     |       OFF      |      ON     |
  **/
  @isTest
  static void testLead50() {
    checkLead(true, true, true, false, false, true, false, true, true, false, false, false, true);
  }


  private static void checkLead(Boolean updateLead,
                            Boolean haveToDo,
                            Boolean useNameCard,
                            Boolean nameCardQueue,
                            Boolean queueNotSPLead,
                            Boolean nameCardNoActive,
                            Boolean leadQueue,
                            Boolean leadNoActive,
                            Boolean haveError,
                            Boolean queueError,
                            Boolean spError,
                            Boolean todoError,
                            Boolean activeUserError) {
    List<User> us = insertUser();
    System.runAs(us[0]) {
      SmartViscaf__NameCard__c nc = new SmartViscaf__NameCard__c(Name = 'TestNameCard',
                                                                 SmartViscaf__company_name__c = 'Testcompany',
                                                                 SmartViscaf__person_name_last__c = 'TestLast',
                                                                 SmartViscaf__person_name_first__c = 'TestFirst'
                                                                 );
      Id queueId = createQueue(queueNotSPLead == false);
      // 名刺所有者はキュー
      if (nameCardQueue) {
        nc.OwnerId = queueId;
      }
      else if (nameCardNoActive) {
        nc.OwnerId = us[1].Id;
      }
      insert nc;
      // リード
      Lead le = new Lead();
      if (updateLead) {
        le = new Lead(LastName = 'TestLast',
                      FirstName = 'TestFirst',
                      Company = 'Testcompany');
        if (leadNoActive) {
          le.OwnerId = us[1].Id;
        }
        else if (leadQueue) {
          le.OwnerId = queueId;
        }
        insert le;
      }
      // リード責任者
      if (nameCardNoActive || leadNoActive) {
        us[1].IsActive = false;
        update us[1];
      }
      List<SB_NameCardL_RegistHelper.RegistTarget> tars = new List<SB_NameCardL_RegistHelper.RegistTarget>();
      SB_NameCardL_RegistHelper.RegistTarget tar = new SB_NameCardL_RegistHelper.RegistTarget(SB_NameCardL_RegistHelper.ProcType.LEAD,
                                                                                                        nc.Id,
                                                                                                        null,
                                                                                                        null,
                                                                                                        le.Id,
                                                                                                        haveToDo,
                                                                                                        null);
      tars.add(tar);

      String oIdLead = null;
      if (useNameCard == false) {
        oIdLead = UserInfo.getUserId();
      }

      SB_NameCardL_RegistHelper.TodoParam todoRP = new SB_NameCardL_RegistHelper.TodoParam(SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting().SmartViscaf__RegistToDoSubject__c,null,null,null);
      SB_NameCardL_RegistHelper.RegistParam leadRP = new SB_NameCardL_RegistHelper.RegistParam('Lead', true, null,oIdLead,false);
      SB_NameCardL_RegistHelper.RegistRequest re = new SB_NameCardL_RegistHelper.RegistRequest(tars, null, null, leadRP, todoRP);
      Map<Id, String> ownerErrorMap = SB_NameCardL_RegistOwenrCheckHelper.doCheck(re);

      if (queueError == false
         && todoError == false
         && activeUserError == false
         && spError == false) {
        System.assertEquals(true, ownerErrorMap.isEmpty());
      }
      else if (queueError) {
        System.assertEquals(true, !ownerErrorMap.isEmpty());
        System.assertEquals(true, ownerErrorMap.containsKey(nc.Id));
        System.assertEquals(System.Label.SB_NCLD_Label_NameCard_Owner_Queue, ownerErrorMap.get(nc.Id));
      }
      else if (todoError) {
        System.assertEquals(true, !ownerErrorMap.isEmpty());
        System.assertEquals(true, ownerErrorMap.containsKey(nc.Id));
        String todoLabel = Task.getSobjectType().getDescribe().getLabel();
        String message = todoLabel +
                                    System.Label.SB_NCLD_MSG_Regist_Error + ': ' +
                                    String.format(System.Label.SB_NCLD_MSG_QUEUES_ERROR, new String[]{'group name'});
        System.assertEquals(message, ownerErrorMap.get(nc.Id));
      }
      else if (activeUserError) {
        System.assertEquals(true, !ownerErrorMap.isEmpty());
        System.assertEquals(true, ownerErrorMap.containsKey(nc.Id));
        if (haveToDo) {
          System.assertEquals(String.format(System.Label.SB_NCLD_MSG_CanNotSetInActiveUserToOwnerToDo, new String[] {us[1].Name}), ownerErrorMap.get(nc.Id));
        }
        else {
          System.assertEquals(System.Label.SB_NCLD_MSG_CanNotSetInActiveUserToOwner, ownerErrorMap.get(nc.Id));
        }
      }
      else if (spError) {
        String errorMessage = Lead.getSobjectType().getDescribe().getLabel() +
                                  System.Label.SB_NCLD_MSG_Regist_Error + ': ' +
                                  String.format(System.Label.SB_NCLD_MSG_QUEUES_LEAD_ERROR,new String[]{'group name'});
        System.assertEquals(true, !ownerErrorMap.isEmpty());
        System.assertEquals(true, ownerErrorMap.containsKey(nc.Id));
        System.assertEquals(errorMessage, ownerErrorMap.get(nc.Id));
      }
    }
  }

  /* --------------------------------------------- リードに関するEnd --------------------------------------------- */
}