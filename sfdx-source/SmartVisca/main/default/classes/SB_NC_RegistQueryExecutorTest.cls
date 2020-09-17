/**
 *
 * SB_NC_RegistQueryExecutorTest
 *  SB_NC_RegistQueryExecutorのテストクラス
 *
 * (c) 2019 Sunbridge Inc.
 *
 *  @author K.Yoshida
 *  @Version 2.2  2019.02.XX SV_DEV-1558 LEX 取引先登録 一括画面をLXパッケージ同様のLC化で追加
 **/
@isTest
private class SB_NC_RegistQueryExecutorTest
{

  public virtual class TestDb extends SB_NC_TestDB {
    public List<Account> listAccount { get; private set; }
    public List<Contact> listContact { get; private set; }
    public List<NameCard__c> listCard { get; private set; }
    
    
    public testDb(){
      listAccount = new List<Account>();
      listContact = new List<Contact>();
      listCard = new List<NameCard__c>();
    }

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

    //public override void initializeLead() {
    //  listLead.add(new Lead(Company='サンブリッジ株式会社', FirstName='太郎', LastName='恵比寿', Title='課長', Email='user01@sunbridge.com'));
    //  listLead.add(new Lead(Company='目黒商事株式会社', FirstName='次郎', LastName='不動前', Title='部長', Email='user01@meguro.co.jp'));
    //}

    //public void initializeCampaignMember() {
    //  listCampaignMember.add(new CampaignMember(CampaignId=listCampaign[0].Id, LeadId=listLead[0].Id, Status = SB_NameCard_Util.getDefaultCampaignStatus()));
    //  listCampaignMember.add(new CampaignMember(CampaignId=listCampaign[0].Id, LeadId=listLead[1].Id, Status = SB_NameCard_Util.getDefaultCampaignStatus()));
    //}

    //  名刺を追加
    public void initializeNameCard(String delivery_type) {
      listCard.add(new NameCard__c(
              Name = '恵比寿 太郎'
              , person_name_last__c = '恵比寿'
              , person_name_first__c = '太郎'
              , last_name__c = null
              , first_name__c = null
              , email__c = 'user01@sunbridge.com'
              , company_name__c= 'サンブリッジ株式会社'
              , division__c = '開発部'
              , title_name__c = '課長'
              , account__c = listAccount[0].Id
              , contact__c = listContact[0].Id
              , delivery_type__c = delivery_type));
      listCard.add(new NameCard__c(
              Name = '不動前 次郎'
              , person_name_last__c = '不動前'
              , person_name_first__c = '次郎'
              , last_name__c = null
              , first_name__c = null
              , email__c = 'user01@meguro.co.jp'
              , company_name__c= '目黒商事株式会社'
              , division__c = '営業部'
              , title_name__c = '部長'
              , account__c = listAccount[1].Id
              , contact__c = listContact[1].Id
              , delivery_type__c = delivery_type));
    }

    // 初期データ作成  他に影響のないものだけ
    public override void initialize() {
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

      initializeNameCard('2');
      if (listCard.isEmpty() == false) {
        insert listCard;
      }

    }
  } // class TestDb

  @isTest
  static void test_bulkQuery_soql() {
    TestDb db = new TestDb();
    db.initialize();

    Test.startTest();

    String query = String.format('SELECT {0} FROM NameCard__c', new String[]{ String.join(new List<String>(SB_NC_RegistQueryExecutor.getNameCardFields()), ', ') });
    List<NameCard__c> cards = Database.query(query);
    Map<Id, NameCard__c> id2card = new Map<Id, NameCard__c>(cards);
    SB_NC_RegistQueryExecutor instance = SB_NC_RegistQueryExecutor.getInstance();
    instance.init(id2card.keySet());
    System.assert(instance.isInitialized());

    //// アカウント
    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.sObjectType);
    SB_NC_RegistQueryStrategy.QueryStrategy qs_a = new SB_NC_RegistQueryStrategy.AccountQueryStrategy(qo_a);
    List<Account> acnts = instance.getCandidateRecords(qs_a);
    System.assertEquals(2, acnts.size());
    System.debug(qs_a.isMatch(id2card.values()[0], acnts[0]));

    //// コンタクト
    SB_NC_RegistQueryOption qo_c = new SB_NC_RegistQueryOption(Contact.sObjectType);
    SB_NC_RegistQueryStrategy.QueryStrategy qs_c = new SB_NC_RegistQueryStrategy.ContactQueryStrategy(qo_c);
    List<Contact> conts = instance.getCandidateRecords(qs_c);
    System.assertEquals(2, conts.size());
    System.debug(qs_c.isMatch(id2card.values()[0], conts[0]));

    //// リード
    //SB_NC_RegistQueryOption qo_l = new SB_NC_RegistQueryOption(Lead.sObjectType);
    //SB_NC_RegistQueryStrategy.QueryStrategy qs_l = new SB_NC_RegistQueryStrategy.LeadQueryStrategy(qo_l);
    //List<Lead> leads = instance.getCandidateRecords(qs_l);
    //System.assertEquals(2, leads.size());
    //System.debug(qs_l.isMatch(id2card.values()[0], leads[0]));

    Test.stopTest();
  }

  // 名刺の参照項目から該当のレコードをクエリするテスト
  @isTest
  static void test_getReferencedCandidateRecords() {
    TestDb db = new TestDb();
    db.initialize();

    Test.startTest();

    Map<Id, NameCard__c> id2card = new Map<Id, NameCard__c>([SELECT Id FROM NameCard__c]);
    SB_NC_RegistQueryExecutor instance = SB_NC_RegistQueryExecutor.getInstance();
    instance.init(id2card.keySet());
    System.assert(instance.isInitialized());
    System.assert(instance.needRefresh(id2card.keySet()) == false);
    SB_NC_RegistQueryOption qo_a = new SB_NC_RegistQueryOption(Account.sObjectType);
    SB_NC_RegistQueryStrategy.QueryStrategy qs_a = new SB_NC_RegistQueryStrategy.AccountQueryStrategy(qo_a);
    List<Account> acnts = (List<Account>)instance.getReferencedCandidateRecords(qs_a);
    System.assertEquals(2, acnts.size());
    SB_NC_RegistQueryOption qo_c = new SB_NC_RegistQueryOption(Contact.sObjectType);
    SB_NC_RegistQueryStrategy.QueryStrategy qs_c = new SB_NC_RegistQueryStrategy.ContactQueryStrategy(qo_c);
    List<Contact> conts = (List<Contact>)instance.getReferencedCandidateRecords(qs_c);
    System.assertEquals(2, conts.size());

    Test.stopTest();
  }

  @isTest
  static void test_etc() {
    TestDb db = new TestDb();
    db.initialize();

    Test.startTest();

    System.assertEquals(false, SB_NC_RegistQueryExecutor.getNameCardFields().isEmpty());
    String query = String.format('SELECT {0} FROM NameCard__c', new String[]{ String.join(new List<String>(SB_NC_RegistQueryExecutor.getNameCardFields()), ', ') });
    List<NameCard__c> cards = Database.query(query);
    SB_NC_RegistQueryExecutor instance = SB_NC_RegistQueryExecutor.getInstance();
    instance.init(cards[0].Id);
    System.assert(instance.isInitialized());
    // instance.reset(cards);
    // System.assert(instance.isInitialized());

    Test.stopTest();
  }

}