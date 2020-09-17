/**
 *
 *  SB_NameCard_OrgTreeBuilderTest
 *        SB_NameCard_OrgTreeBuilder のテストクラス
 *
 * Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      v1.22
 *                  2017.11.xx
 *                  SV_DEV-412 LEXの組織情報
 *                  SV_DEV-689 組織情報に役職を加味する
 *                  2018.03.xx SV_DEV-787 組織情報の部署（所属）が意図的でない箇所で改行されるケース
 *  @Version 2      v2.4 2019.06.xx SV_DEV-1498 英語名刺の場合は、組織情報の所属を半角で階層分けしないようにしてほしい
 *
 **/
@isTest
private class SB_NameCard_OrgTreeBuilderTest
{

  @TestSetup
  static void setupDB() {
    // アカウント
    List<Account> listAccount = new List<Account>();
    listAccount.add(new Account(Name='株式会社 テスト商事', Site='本社'));
    insert listAccount;

    // コンタクト 役職付きで追加
    List<Contact> listContact = new List<Contact>();
    {
      Integer n = 0;
      for (String title : SB_NameCard_OrgTreeBuilder.TITLE_ORDER_MAP.keySet()) {
        n++;
        String firstname = String.valueof(n) + '太郎';
        String email = String.valueof(n) + '@test.com';
        listContact.add(new Contact(LastName='テスト', FirstName=firstname, Title=title, Email=email, AccountId=listAccount[0].Id));
      }
      n++;
      String title = '副' + String.valueOf(n);
      String firstname = String.valueOf(n) + '太郎';
      String email = String.valueOf(n) + '@test.com';
      listContact.add(new Contact(LastName='テスト', FirstName=firstname, Title=title, Email=email, AccountId=listAccount[0].Id));
      n++;
      title = String.valueOf(n) + '代理';
      firstname = String.valueOf(n) + '太郎';
      email = String.valueOf(n) + '@test.com';
      listContact.add(new Contact(LastName='テスト', FirstName=firstname, Title=title, Email=email, AccountId=listAccount[0].Id));
      n++;
      title = String.valueOf(n) + '長';
      firstname = String.valueOf(n) + '太郎';
      email = String.valueOf(n) + '@test.com';
      listContact.add(new Contact(LastName='テスト', FirstName=firstname, Title=title, Email=email, AccountId=listAccount[0].Id));
      insert listContact;
    }

    // 名刺　役職付きで追加
    List<NameCard__c> listCard = new List<NameCard__c>();
    {
      Integer n = 0;
      for (String title : SB_NameCard_OrgTreeBuilder.TITLE_ORDER_MAP.keySet()) {
        n++;
        String firstname = String.valueof(n) + '太郎';
        String email = String.valueof(n) + '@test.com';
        listCard.add(new NameCard__c(Name='テスト '+firstname, company_name__c='株式会社 テスト商事', last_name__c='テスト', first_name__c=firstname, email__c=email, title_name__c=title));
      }
      n++;
      String title = '副' + String.valueOf(n);
      String firstname = String.valueOf(n) + '太郎';
      String email = String.valueOf(n) + '@test.com';
      listCard.add(new NameCard__c(Name='テスト '+firstname, company_name__c='株式会社 テスト商事', last_name__c='テスト', first_name__c=firstname, email__c=email, title_name__c=title));
      n++;
      title = String.valueOf(n) + '代理';
      firstname = String.valueOf(n) + '太郎';
      email = String.valueOf(n) + '@test.com';
      listCard.add(new NameCard__c(Name='テスト '+firstname, company_name__c='株式会社 テスト商事', last_name__c='テスト', first_name__c=firstname, email__c=email, title_name__c=title));
      n++;
      title = String.valueOf(n) + '長';
      firstname = String.valueOf(n) + '太郎';
      email = String.valueOf(n) + '@test.com';
      listCard.add(new NameCard__c(Name='テスト '+firstname, company_name__c='株式会社 テスト商事', last_name__c='テスト', first_name__c=firstname, email__c=email, title_name__c=title));
      insert listCard;
    }


    // リード 役職付きで追加
    List<Lead> listLead = new List<Lead>();
    {
      Integer n = 0;
      for (String title : SB_NameCard_OrgTreeBuilder.TITLE_ORDER_MAP.keySet()) {
        n++;
        String firstname = String.valueof(n) + '太郎';
        String email = String.valueof(n) + '@test.com';
        listLead.add(new Lead(LastName='テスト', FirstName=firstname, Title=title, Email=email, Company='株式会社 テスト商事'));
      }
      n++;
      String title = '副' + String.valueOf(n);
      String firstname = String.valueOf(n) + '太郎';
      String email = String.valueOf(n) + '@test.com';
      listLead.add(new Lead(LastName='テスト', FirstName=firstname, Title=title, Email=email, Company='株式会社 テスト商事'));
      n++;
      title = String.valueOf(n) + '代理';
      firstname = String.valueOf(n) + '太郎';
      email = String.valueOf(n) + '@test.com';
      listLead.add(new Lead(LastName='テスト', FirstName=firstname, Title=title, Email=email, Company='株式会社 テスト商事'));
      n++;
      title = String.valueOf(n) + '長';
      firstname = String.valueOf(n) + '太郎';
      email = String.valueOf(n) + '@test.com';
      listLead.add(new Lead(LastName='テスト', FirstName=firstname, Title=title, Email=email, Company='株式会社 テスト商事'));
      insert listLead;
    }
  }

  @isTest
  static void test_createTitleOrderMap() {
    String[] titles = SB_NameCard_OrgTreeBuilder.TITLE_ORDER.split('[,\\s]+');
    Map<String, Integer> titleOrder = new Map<String, Integer>();
    for (Integer n =0; n < titles.size(); n++) {
      titleOrder.put(titles[n], n);
    }
    System.assertEquals(titles.size(), titleOrder.size());
  }

  // コンタクトで 組織ツリー作成
  @isTest
  static void test_getTreeItems_Contact() {
    List<Contact> conts = [SELECT Id, Name FROM Contact ];
    List<SB_NameCard_OrgTreeBuilder.Item> items = SB_NameCard_OrgTreeBuilder.getOrgTreeItems(conts[0].Id, false);
    System.debug(items.size());
    //System.assertEquals(0, items[0].items[0].titleOrder);
  }

  // リードで 組織ツリー作成
  @isTest
  static void test_getTreeItems_Lead() {
    List<Lead> leads = [SELECT Id, Name FROM Lead ];
    List<SB_NameCard_OrgTreeBuilder.Item> items = SB_NameCard_OrgTreeBuilder.getOrgTreeItems(leads[0].Id, false);
    System.debug(items.size());
    //System.assertEquals(0, items[0].items[0].titleOrder);
  }

  // 名刺で 組織ツリー作成
  @isTest
  static void test_getTreeItems_NameCard() {
    List<NameCard__c> cards = [SELECT Id, Name FROM NameCard__c ];
    List<SB_NameCard_OrgTreeBuilder.Item> items = SB_NameCard_OrgTreeBuilder.getOrgTreeItems(cards[0].Id, false);
    System.assertEquals(0, items[0].items[0].titleOrder);
  }

  // 名刺で 組織ツリー作成 LC用 メソッド
  @isTest
  static void test_getTreeItems_NameCard_Lc() {
    List<NameCard__c> cards = [SELECT Id, Name FROM NameCard__c ];
    List<SB_NameCard_OrgTreeBuilder.Item> items = SB_NameCard_OrgTreeBuilder.getOrgTreeItems(cards[0].Id, true, 1000);
    System.assertEquals(0, items[0].items[0].titleOrder);
  }

  // SV_DEV-787 組織情報の部署（所属）が意図的でない箇所で改行されるケース
  // 2018.03.xx
  // 部署の 正規表現での分割 従来仕様
  @isTest
  static void test_getDivisionNodes_Regex() {
    SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    svConfig.OrgTreeUseRegex__c = true;
    upsert svConfig;

    String division = '中部支社 営業部 営業課';
    List<String> ss = SB_NameCard_OrgTreeBuilder.getDivisionNodes(division);
    System.assertEquals(4, ss.size());
    System.assertEquals('中部', ss[0]);
  }

  // SV_DEV-787 組織情報の部署（所属）が意図的でない箇所で改行されるケース
  // 2018.03.xx
  // 部署の 半角空白での分割 v1.22 以降の デフォルト
  @isTest
  static void test_getDivisionNodes_SplitSPace() {
    String division = '中部支社 営業部 営業課';
    List<String> ss = SB_NameCard_OrgTreeBuilder.getDivisionNodes(division);
    System.assertEquals(3, ss.size());
    System.assertEquals('中部支社', ss[0]);
  }

  @isTest
  static void test_getDivisionNodes_SplitSPace_ken() {
    String division = '中部支社 兼 営業課';
    List<String> ss = SB_NameCard_OrgTreeBuilder.getDivisionNodes(division);
    System.assertEquals(2, ss.size());
    System.assertEquals('中部支社', ss[0]);
    System.assertEquals('兼 営業課', ss[1]);

    division = '中部支社 営業課 兼';
    ss = SB_NameCard_OrgTreeBuilder.getDivisionNodes(division);
    System.assertEquals(3, ss.size());
    System.assertEquals('中部支社', ss[0]);

    division = '兼 営業課';
    ss = SB_NameCard_OrgTreeBuilder.getDivisionNodes(division);
    System.assertEquals(1, ss.size());
    System.assertEquals('兼 営業課', ss[0]);
  }

  // v2.4 2019.06.xx SV_DEV-1498 英語名刺の場合は、組織情報の所属を半角で階層分けしないようにしてほしい
  @isTest
  static void test_getDivisionNodes_ASCII_only() {
    String division = 'Product Type Divisions, Productivity and Business Processes';
    List<String> ss = SB_NameCard_OrgTreeBuilder.getDivisionNodes(division);
    System.assertEquals(1, ss.size());
    System.assertEquals(division, ss[0]);

    division = 'Product Type Divisions, Productivity and Business Processes Dev Group';
    ss = SB_NameCard_OrgTreeBuilder.getDivisionNodes(division);
    System.assertEquals(1, ss.size());
    System.assertEquals(division, ss[0]);

    division = 'Product Type Divisions, Productivity and Business Processes Sales Group';
    ss = SB_NameCard_OrgTreeBuilder.getDivisionNodes(division);
    System.assertEquals(1, ss.size());
    System.assertEquals(division, ss[0]);

  }

}