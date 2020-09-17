/**
 *
 * SB_NC_CardOwnersBuilderTest2
 *  SB_NC_CardOwnersBuilder のテストクラス
 *
 *  @author sawano
 *  @Version1 v2.4 2019.09.xx
 *
 **/

@isTest
private class SB_NC_CardOwnersBuilderTest2 {

  // 所属、役職等の表示クラス 1 のテスト
  @isTest
  static void test_ReplaceTitileFormatter() {
    SB_NC_CardOwnersBuilder.ReplaceTitileFormatter tf = new SB_NC_CardOwnersBuilder.ReplaceTitileFormatter(User.sObjectType, '{CompanyName} {Department} {Title} あいう');
    System.assertEquals('companyname,department,title', String.join(tf.titleFields, ','));
    System.assertEquals('{0} {1} {2} あいう', tf.titleFormat);
    System.assertEquals('テスト商事株式会社 開発部 役職 あいう', tf.format(new User(CompanyName='テスト商事株式会社', Department='開発部', Title='役職')));
    System.assertEquals('テスト商事株式会社 開発部  あいう', tf.format(new User(CompanyName='テスト商事株式会社', Department='開発部')));
    System.assertEquals('テスト商事株式会社  役職 あいう', tf.format(new User(CompanyName='テスト商事株式会社', Title='役職')));
  }

  // 所属、役職等の表示クラス 2 のテスト
  @isTest
  static void test_JoinSpaceTitleFormatter() {
    SB_NC_CardOwnersBuilder.JoinSpaceTitleFormatter tf = new SB_NC_CardOwnersBuilder.JoinSpaceTitleFormatter(User.sObjectType, 'CompanyName, Department, Title, XXXX__c');
    System.assertEquals('companyname,department,title', String.join(tf.titleFields, ','));
    // System.assertEquals('CompanyName, Department, Title, XXXX__c', tf.titleFormat);
    System.assertEquals('テスト商事株式会社 開発部 役職', tf.format(new User(CompanyName='テスト商事株式会社', Department='開発部', Title='役職')));
    System.assertEquals('テスト商事株式会社 開発部', tf.format(new User(CompanyName='テスト商事株式会社', Department='開発部')));
    System.assertEquals('テスト商事株式会社 役職', tf.format(new User(CompanyName='テスト商事株式会社', Title='役職')));
  } 

  // 所属、役職等の表示クラス 2 のテスト
  @isTest
  static void test_JoinSpaceTitleFormatter_namecard() {
    String nsx = SB_NameCard_Util.getNamespacePrefix_x();
    String fields = 'Name,' + nsx + 'company_name__c,' + nsx + 'division__c,' +  nsx + 'title_name__c';
    SB_NC_CardOwnersBuilder.JoinSpaceTitleFormatter tf = new SB_NC_CardOwnersBuilder.JoinSpaceTitleFormatter(NameCard__c.sObjectType, fields);
    System.assertEquals(fields.toLowerCase(), String.join(tf.titleFields, ','));
    System.assertEquals('恵比寿 五郎 テスト商事株式会社 開発部 役職', tf.format(new NameCard__c(Name='恵比寿 五郎', company_name__c='テスト商事株式会社', division__c='開発部', title_name__c='役職')));
  } 

  private class TestDb {
    private List<User> listUsers = new List<User>();
    public void initializeUser() {
      Profile profStd = [SELECT Id FROM Profile WHERE name='Standard User' or name='標準ユーザ' LIMIT 1];
      listUsers.add(new User(FirstName='1', LastName='テストデータ', Department='第1部', Title='投手', UserName='1@testdata.com', ProfileId=profStd.Id, Email='1@testdata.com', Alias='1', TimeZoneSidKey='Asia/Tokyo', LocaleSidKey='ja_JP', EmailEncodingKey='UTF-8', LanguageLocaleKey='ja'));
      listUsers.add(new User(FirstName='2', LastName='テストデータ', Department='第2部', Title='捕手', UserName='2@testdata.com', ProfileId=profStd.Id, Email='2@testdata.com', Alias='2', TimeZoneSidKey='Asia/Tokyo', LocaleSidKey='ja_JP', EmailEncodingKey='UTF-8', LanguageLocaleKey='ja'));
      listUsers.add(new User(FirstName='3', LastName='テストデータ', Department='第3部', Title='一塁手', UserName='3@testdata.com', ProfileId=profStd.Id, Email='3@testdata.com', Alias='3', TimeZoneSidKey='Asia/Tokyo', LocaleSidKey='ja_JP', EmailEncodingKey='UTF-8', LanguageLocaleKey='ja'));
      listUsers.add(new User(FirstName='4', LastName='テストデータ', Department='第4部', Title='二塁手', UserName='4@testdata.com', ProfileId=profStd.Id, Email='4@testdata.com', Alias='4', TimeZoneSidKey='Asia/Tokyo', LocaleSidKey='ja_JP', EmailEncodingKey='UTF-8', LanguageLocaleKey='ja'));
      listUsers.add(new User(FirstName='5', LastName='テストデータ', Department='第5部', Title='三塁手', UserName='5@testdata.com', ProfileId=profStd.Id, Email='5@testdata.com', Alias='5', TimeZoneSidKey='Asia/Tokyo', LocaleSidKey='ja_JP', EmailEncodingKey='UTF-8', LanguageLocaleKey='ja'));
      listUsers.add(new User(FirstName='6', LastName='テストデータ', Department='第6部', Title='遊撃手', UserName='6@testdata.com', ProfileId=profStd.Id, Email='6@testdata.com', Alias='6', TimeZoneSidKey='Asia/Tokyo', LocaleSidKey='ja_JP', EmailEncodingKey='UTF-8', LanguageLocaleKey='ja'));
      listUsers.add(new User(FirstName='7', LastName='テストデータ', Department='第7部', Title='外野手', UserName='7@testdata.com', ProfileId=profStd.Id, Email='7@testdata.com', Alias='7', TimeZoneSidKey='Asia/Tokyo', LocaleSidKey='ja_JP', EmailEncodingKey='UTF-8', LanguageLocaleKey='ja'));
      listUsers.add(new User(FirstName='8', LastName='テストデータ', Department=null, Title='オーナー', UserName='8@testdata.com', ProfileId=profStd.Id, Email='8@testdata.com', Alias='8', TimeZoneSidKey='Asia/Tokyo', LocaleSidKey='ja_JP', EmailEncodingKey='UTF-8', LanguageLocaleKey='ja'));
    }
    public void initialize() {
      initializeUser();
      if (!listUsers.isEmpty()) {
        INSERT listUsers;
      }
    }
  }

  // // ユーザレコードの作成
  // public virtual User createUser(String firstname, String lastname) {
  //   return new User(
  //     alias = String.format('{0}-{1}', new String[]{firstname,lastname}).subString(0, 7)
  //     , email= firstname+lastname+'@testorg.com'
  //     , emailencodingkey='UTF-8'
  //     , firstname = firstname
  //     , lastname = lastname
  //     , languagelocalekey='ja'
  //     , localesidkey='ja_JP'
  //     , profileid = profStd.Id
  //     , timezonesidkey='Asia/Tokyo'
  //     , username=firstname+lastname+'@testorg.com'
  //     , Department= firstname + '事業部');
  // }


  @isTest
  static void test_CardOwnerSort() {
    TestDb db = new TestDb();
    db.initialize();

    List<User> users = [SELECT Id, Name, Department, Title, EMail FROM User WHERE LastName='テストデータ' ORDER BY FirstName]; // 

    SB_NC_CardOwnersBuilder.createTitileFormatter('Department, Title');
    SB_NC_CardOwnersBuilder.createItemListCreator('EMail');
    List<SB_NC_CardOwnersBuilder.CardOwner> owners = new List<SB_NC_CardOwnersBuilder.CardOwner>();
    owners.add(new SB_NC_CardOwnersBuilder.CardOwner(users[0], new NameCard__c(card_exchange_date__c=Date.today().addDays(-7))));
    owners.add(new SB_NC_CardOwnersBuilder.CardOwner(users[1], new NameCard__c(card_exchange_date__c=Date.today().addDays(-6))));
    owners.add(new SB_NC_CardOwnersBuilder.CardOwner(users[2], new NameCard__c(card_exchange_date__c=Date.today().addDays(-5))));
    owners.add(new SB_NC_CardOwnersBuilder.CardOwner(users[3], new NameCard__c(card_exchange_date__c=Date.today().addDays(-4))));
    owners.add(new SB_NC_CardOwnersBuilder.CardOwner(users[4], new NameCard__c(card_exchange_date__c=Date.today().addDays(-3))));
    owners.add(new SB_NC_CardOwnersBuilder.CardOwner(users[5], new NameCard__c(card_exchange_date__c=Date.today().addDays(-2))));
    owners.add(new SB_NC_CardOwnersBuilder.CardOwner(users[6], new NameCard__c(card_exchange_date__c=Date.today().addDays(-1))));
    owners.add(new SB_NC_CardOwnersBuilder.CardOwner(users[7], new NameCard__c(card_exchange_date__c=null)));
    // NAME, DEPT, EXCHANGE
    String order=''; 
    // 氏名 降順
    SB_NC_CardOwnersBuilder.ownerSortKey = SB_NC_CardOwnersBuilder.SortKey.Name;
    SB_NC_CardOwnersBuilder.ownerSortAsc = false;
    owners.sort();
    order=''; 
    for (SB_NC_CardOwnersBuilder.CardOwner o : owners) {
      order += o.name.right(1);
    }
    System.assertEquals('87654321', order);
    // 氏名 昇順
    SB_NC_CardOwnersBuilder.ownerSortKey = SB_NC_CardOwnersBuilder.SortKey.Name;
    SB_NC_CardOwnersBuilder.ownerSortAsc = true;
    owners.sort();
    order=''; 
    for (SB_NC_CardOwnersBuilder.CardOwner o : owners) {
      order += o.name.right(1);
    }
    System.assertEquals('12345678', order);
    // 部署 降順 NULL最初
    SB_NC_CardOwnersBuilder.ownerSortKey = SB_NC_CardOwnersBuilder.SortKey.DEPT;
    SB_NC_CardOwnersBuilder.ownerSortAsc = false;
    owners.sort();
    order=''; 
    for (SB_NC_CardOwnersBuilder.CardOwner o : owners) {
      order += o.name.right(1);
    }
    System.assertEquals('87654321', order);
    // 部署 昇順 NULL最後
    SB_NC_CardOwnersBuilder.ownerSortKey = SB_NC_CardOwnersBuilder.SortKey.DEPT;
    SB_NC_CardOwnersBuilder.ownerSortAsc = true;
    owners.sort();
    order=''; 
    for (SB_NC_CardOwnersBuilder.CardOwner o : owners) {
      order += o.name.right(1);
    }
    System.assertEquals('12345678', order);
    // 名刺交換日 降順 NULL最後
    SB_NC_CardOwnersBuilder.ownerSortKey = SB_NC_CardOwnersBuilder.SortKey.EXCHANGE;
    SB_NC_CardOwnersBuilder.ownerSortAsc = false;
    owners.sort();
    order=''; 
    for (SB_NC_CardOwnersBuilder.CardOwner o : owners) {
      order += o.name.right(1);
    }
    System.assertEquals('76543218', order);
    // 名刺交換日 昇順 NULL最初
    SB_NC_CardOwnersBuilder.ownerSortKey = SB_NC_CardOwnersBuilder.SortKey.EXCHANGE;
    SB_NC_CardOwnersBuilder.ownerSortAsc = true;
    owners.sort();
    order=''; 
    for (SB_NC_CardOwnersBuilder.CardOwner o : owners) {
      order += o.name.right(1);
    }
    System.assertEquals('81234567', order);

 }


}