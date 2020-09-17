/*
  *  @author mou
  *  @Version 1      2016.04.xx
  *
  */
  @isTest
private class SB_NameCard_TitleUpdaterControllertest{
  public static void insertCustomjinji()
  {
      
      	Contact c = new Contact();
			c.LastName = 'テスト姓';
			c.FirstName = 'テスト名';
			c.Email = 'test' + '@example.com';
      insert c;
      
  NameCard__c nc = new NameCard__c();
        nc.company_name__c = '株式会社サンブリッジ';
        nc.company_name_kana__c = 'カブシキガイシャサンブリッジ';
        nc.division__c = 'テスト部署';
        nc.person_name_last__c = 'テスト姓';
        nc.person_name_first__c = 'テスト名';
        nc.email__c = 'test@sb.example.com';
        nc.contact__c = c.Id;
        insert nc;
     JinjiIdo__c ji = new JinjiIdo__c();
        ji.name = 'test1';
        ji.NameCard__c = nc.Id;
        ji.ContactName__c = nc.person_name_last__c + ' ' + nc.person_name_first__c;
        ji.AccountName__c = nc.company_name__c;
        ji.OldTitle__c = '課長';
        ji.NewTitle__c = '部長';
        ji.PrintedDate__c = Date.today();
        ji.AnnounceDate__c = Date.today();
        insert ji;
  }
    
     public static void insertCustomjinjinoc()
  {
  NameCard__c nc = new NameCard__c();
        nc.company_name__c = '株式会社サンブリッジ';
        nc.company_name_kana__c = 'カブシキガイシャサンブリッジ';
        nc.division__c = 'テスト部署';
        nc.person_name_last__c = 'テスト姓';
        nc.person_name_first__c = 'テスト名';
        nc.email__c = 'test@sb.example.com';
        insert nc;
     JinjiIdo__c ji = new JinjiIdo__c();
        ji.name = 'test1';
        ji.NameCard__c = nc.Id;
        ji.ContactName__c = nc.person_name_last__c + ' ' + nc.person_name_first__c;
        ji.AccountName__c = nc.company_name__c;
        ji.OldTitle__c = '課長';
        ji.NewTitle__c = '部長';
        ji.PrintedDate__c = Date.today();
        ji.AnnounceDate__c = Date.today();
        insert ji;
  }
  
  public static testMethod void test1()
  {
      insertCustomjinji();
      List<JinjiIdo__c> jinjis = [Select Id From JinjiIdo__c Where Name = 'test1'];
      System.assertEquals(1,jinjis.size());
      PageReference pageRef = Page.SB_NameCard_TitleUpdater;
      Test.setCurrentPage(pageRef);
      ApexPages.StandardController sc = new ApexPages.StandardController(jinjis[0]);
      SB_NameCard_TitleUpdaterController ctrl = new SB_NameCard_TitleUpdaterController(sc);
      ctrl.init();
      PageReference pageRef1 = ctrl.updateContact();
      System.assertNotEquals(null, pageRef1, 'error');
      ctrl.cancel();
      
  }
    
      
  public static testMethod void test2()
  {
     insertCustomjinji();
      List<JinjiIdo__c> jinjis = [Select Id From JinjiIdo__c Where Name = 'test1'];
      System.assertEquals(1,jinjis.size());
      PageReference pageRef = Page.SB_NameCard_TitleUpdater;
      Test.setCurrentPage(pageRef);
      jinjis[0].Id=null;
      ApexPages.StandardController sc = new ApexPages.StandardController(jinjis[0]);
      SB_NameCard_TitleUpdaterController ctrl = new SB_NameCard_TitleUpdaterController(sc);
      ctrl.init();
      PageReference pageRef1 = ctrl.updateContact();
      System.assertEquals(null, pageRef1, 'error');
      ctrl.cancel();
      
  }
    
     public static testMethod void test3()
  {
     insertCustomjinjinoc();
      List<JinjiIdo__c> jinjis = [Select Id From JinjiIdo__c Where Name = 'test1'];
      System.assertEquals(1,jinjis.size());
      PageReference pageRef = Page.SB_NameCard_TitleUpdater;
      Test.setCurrentPage(pageRef);
      ApexPages.StandardController sc = new ApexPages.StandardController(jinjis[0]);
      SB_NameCard_TitleUpdaterController ctrl = new SB_NameCard_TitleUpdaterController(sc);
      ctrl.init();
      PageReference pageRef1 = ctrl.updateContact();
      System.assertEquals(null, pageRef1, 'error');
      ctrl.cancel();
      
  }

}