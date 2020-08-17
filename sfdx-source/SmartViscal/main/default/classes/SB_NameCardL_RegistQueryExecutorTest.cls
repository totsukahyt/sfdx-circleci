@isTest
private class SB_NameCardL_RegistQueryExecutorTest
{

  public virtual class TestDb extends SB_NCL_TestDB {

    // アカウント
    public override void initializeAccount() {
      listAccount.add(new Account(Name='サンブリッジ株式会社', Site='開発部'));
      listAccount.add(new Account(Name='目黒商事株式会社', Site='営業部'));
    }

    //　コンタクト
    public override void initializeContact() {
      listContact.add(new Contact(AccountId=listAccount[0].Id, FirstName='太郎', LastName='恵比寿', Title='課長', Email='user01@sunbridge.com'));
      listContact.add(new Contact(AccountId=listAccount[1].Id, FirstName='次郎', LastName='不動前', Title='部長', Email='user01@meguro.co.jp'));
    }

    public override void initializeLead() {
      listLead.add(new Lead(Company='サンブリッジ株式会社', FirstName='太郎', LastName='恵比寿', Title='課長', Email='user01@sunbridge.com'));
      listLead.add(new Lead(Company='目黒商事株式会社', FirstName='次郎', LastName='不動前', Title='部長', Email='user01@meguro.co.jp'));
    }

    //public void initializeCampaignMember() {
    //  listCampaignMember.add(new CampaignMember(CampaignId=listCampaign[0].Id, LeadId=listLead[0].Id, Status = SB_NameCardL_Util.getDefaultCampaignStatus()));
    //  listCampaignMember.add(new CampaignMember(CampaignId=listCampaign[0].Id, LeadId=listLead[1].Id, Status = SB_NameCardL_Util.getDefaultCampaignStatus()));
    //}

    //  名刺を追加
    public void initializeNameCard(String delivery_type) {
      listCard.add(new SmartViscaf__NameCard__c(
              Name = '恵比寿 太郎'
              , SmartViscaf__person_name_last__c = '恵比寿'
              , SmartViscaf__person_name_first__c = '太郎'
              , SmartViscaf__last_name__c = null
              , SmartViscaf__first_name__c = null
              , SmartViscaf__email__c = 'user01@sunbridge.com'
              , SmartViscaf__company_name__c= 'サンブリッジ株式会社'
              , SmartViscaf__division__c = '開発部'
              , SmartViscaf__title_name__c = '課長'
              , SmartViscaf__account__c = listAccount[0].Id
              , SmartViscaf__contact__c = listContact[0].Id
              , SmartViscaf__lead__c = listLead[0].Id
              , campaign__c = listCampaign[0].Id
              , SmartViscaf__delivery_type__c = delivery_type));
      listCard.add(new SmartViscaf__NameCard__c(
              Name = '不動前 次郎'
              , SmartViscaf__person_name_last__c = '不動前'
              , SmartViscaf__person_name_first__c = '次郎'
              , SmartViscaf__last_name__c = null
              , SmartViscaf__first_name__c = null
              , SmartViscaf__email__c = 'user01@meguro.co.jp'
              , SmartViscaf__company_name__c= '目黒商事株式会社'
              , SmartViscaf__division__c = '営業部'
              , SmartViscaf__title_name__c = '部長'
              , SmartViscaf__account__c = listAccount[1].Id
              , SmartViscaf__contact__c = listContact[1].Id
              , SmartViscaf__lead__c = listLead[1].Id
              , campaign__c = listCampaign[0].Id
              , SmartViscaf__delivery_type__c = delivery_type));
    }

    // 初期データ作成  他に影響のないものだけ
    public override void initialize() {
      // キャンペーン
      initializeCampaign();
      if (listCampaign.isEmpty() == false) {
          insert listCampaign;
      }
      // アカウント
      initializeAccount();
      if (listAccount.isEmpty() == false) {
        insert listAccount;
      }
      //　コンタクト
      initializeContact();
      if (listContact.isEmpty() == false) {
        insert listContact;
      }
      // リード
      initializeLead();
      if (listLead.isEmpty() == false) {
        insert listLead;
      }

      initializeNameCard('2');
      if (listCard.isEmpty() == false) {
        insert listCard;
      }

    }
  } // class TestDb

  @isTest
  static void test_bulkQuery() {
    TestDb db = new TestDb();
    db.initialize();

    Test.startTest();

    String query = String.format('SELECT {0} FROM SmartViscaf__NameCard__c', new String[]{ String.join(new List<String>(SB_NameCardL_RegistQueryExecutor.getNameCardFields()), ', ') });
    List<SmartViscaf__NameCard__c> cards = Database.query(query);
    Map<Id, SmartViscaf__NameCard__c> id2card = new Map<Id, SmartViscaf__NameCard__c>(cards);
    SB_NameCardL_RegistQueryExecutor instance = SB_NameCardL_RegistQueryExecutor.getInstance();
    instance.init(id2card.keySet());
    System.assert(instance.isInitialized());

    //// アカウント
    SB_NameCardL_RegistQueryOption qo_a = new SB_NameCardL_RegistQueryOption(Account.sObjectType);
    SB_NameCardL_RegistQueryStrategy.QueryStrategy qs_a = SB_NameCardL_RegistQueryStrategy.createQueryStrategy(qo_a);
    List<Account> acnts = instance.getCandidateRecords(qs_a);
    System.assertEquals(2, acnts.size());
    System.debug(qs_a.isMatch(id2card.values()[0], acnts[0]));

    //// コンタクト
    SB_NameCardL_RegistQueryOption qo_c = new SB_NameCardL_RegistQueryOption(Contact.sObjectType);
    SB_NameCardL_RegistQueryStrategy.QueryStrategy qs_c = SB_NameCardL_RegistQueryStrategy.createQueryStrategy(qo_c);
    List<Contact> conts = instance.getCandidateRecords(qs_c);
    System.assertEquals(2, conts.size());
    System.debug(qs_c.isMatch(id2card.values()[0], conts[0]));

    //// リード
    SB_NameCardL_RegistQueryOption qo_l = new SB_NameCardL_RegistQueryOption(Lead.sObjectType);
    SB_NameCardL_RegistQueryStrategy.QueryStrategy qs_l = SB_NameCardL_RegistQueryStrategy.createQueryStrategy(qo_l);
    List<Lead> leads = instance.getCandidateRecords(qs_l);
    System.assertEquals(2, leads.size());
    System.debug(qs_l.isMatch(id2card.values()[0], leads[0]));

    Test.stopTest();
  }

  // 名刺の参照項目から該当のレコードをクエリするテスト
  @isTest
  static void test_getReferencedCandidateRecords() {
    TestDb db = new TestDb();
    db.initialize();

    Test.startTest();

    Map<Id, SmartViscaf__NameCard__c> id2card = new Map<Id, SmartViscaf__NameCard__c>([SELECT Id FROM SmartViscaf__NameCard__c]);
    SB_NameCardL_RegistQueryExecutor instance = SB_NameCardL_RegistQueryExecutor.getInstance();
    instance.init(id2card.keySet());
    System.assert(instance.isInitialized());
    System.assert(instance.needRefresh(id2card.keySet()) == false);
    List<Account> acnts = (List<Account>)instance.getReferencedCandidateRecords(Account.sObjectType);
    System.assertEquals(2, acnts.size());
    List<Contact> conts = (List<Contact>)instance.getReferencedCandidateRecords(Contact.sObjectType);
    System.assertEquals(2, conts.size());
    List<Lead> leads = (List<Lead>)instance.getReferencedCandidateRecords(Lead.sObjectType);
    System.assertEquals(2, leads.size());

    Test.stopTest();
  }

  @isTest
  static void test_etc() {
    TestDb db = new TestDb();
    db.initialize();

    Test.startTest();

    System.assertEquals(false, SB_NameCardL_RegistQueryExecutor.getNameCardFields().isEmpty());
    String query = String.format('SELECT {0} FROM SmartViscaf__NameCard__c', new String[]{ String.join(new List<String>(SB_NameCardL_RegistQueryExecutor.getNameCardFields()), ', ') });
    List<SmartViscaf__NameCard__c> cards = Database.query(query);
    SB_NameCardL_RegistQueryExecutor instance = SB_NameCardL_RegistQueryExecutor.getInstance();
    instance.init(cards[0].Id);
    System.assert(instance.isInitialized());
    instance.reset(cards);
    System.assert(instance.isInitialized());

    Test.stopTest();
  }

}