/**
 *
 * SB_NC_CardOwnersBuilderTest
 *  SB_NC_CardOwnersBuilder のテストクラス
 *
 *  @author sawano
 *  @Version1 v2.4 2019.06.xx SV_DEV-1593 LEX画面の名刺詳細から「同じ名刺を持つユーザ」を確認できるようにしてほしい
 *
 **/
@isTest
private class SB_NC_CardOwnersBuilderTest {

  private class TestDB extends SB_NC_TestDB {
    // 名刺データ作成
    public override void initializeNameCard() {
      // 転職後の名刺 名刺交換日：今日
      List<NameCard__c> newJobs = new List<NameCard__c>();
      newJobs.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社 次の会社', division__c='本社',
                    title_name__c='課長',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2',
                    card_exchange_date__c=Date.today(), OwnerId=UserInfo.getUserId()));        
      insert newJobs;

      for (Integer n = 0; n < CNT_USER; n++) {
        listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社サンブリッジ', division__c='本社',
                      title_name__c='課長',
                      zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                      tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                      last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2',
                      card_exchange_date__c=Date.today().addDays(-n-10), OwnerId=getUserId(n)));        
      }
      // 自分が所有者 一番古い 名刺交換日：20日以上前 転職後の名刺を参照
      listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社サンブリッジ', division__c='本社',
                    title_name__c='課長',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2',
                    card_exchange_date__c=Date.today().addDays(-CNT_USER-20), OwnerId=UserInfo.getUserId(),
                    tenshokugonomeishi__c=newJobs[0].Id));        

    }

    public void createTenshokuMae() {
      // // 最新の名刺に 転職後の名刺を参照さす
      List<NameCard__c> cards = [SELECT Id, tenshokugonomeishi__c FROM NameCard__c ORDER BY card_exchange_date__c ASC];

      // 前　名刺交換日：100日以上前
      List<NameCard__c> formers = new List<NameCard__c>();
      formers.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社 前の会社', division__c='本社',
                    title_name__c='課長',
                    zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                    tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                    last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2',
                    card_exchange_date__c=Date.today().addDays(-CNT_USER-100), OwnerId=UserInfo.getUserId(),
                    tenshokugonomeishi__c=cards[0].Id));        
      insert formers;
    }

    // // ユーザの初期化 無効なユーザを作っても所有者にできない。
    // public override void initializeUser() {
    //   for(Integer n=1; n<=CNT_USER; n++) {
    //     listUser.add(createUser(n.format(), 'Smart'));
    //   }
    //   for (Integer n=0; n<2; n++) { // 2人無効化
    //     User u = listUser.get(n);
    //     u.put('IsActive', false);
    //   }
    //   System.assertEquals(CNT_USER, listUser.size());  // 2017.10.xx v1.21 for code scan  Test Methods With No Assert
    // }

    public Id getUserId(Integer index) {
      return listUser.get(index).Id;
    }

    // ユーザを無効にする できない。
    // System.DmlException: Update failed. First exception on row 0 with id 0056F00000CEhueQAD; first error: MIXED_DML_OPERATION, 非設定オブジェクトを更新した後の設定オブジェクト上の DML 操作 (またはその逆) は、許可されていません: User、元のオブジェクト: NameCard__c: []
    // public void deactivateUsers(Integer cnt) {
    //   Set<Id> userIds = (new Map<Id, User>(listUser)).keySet();
    //   List<User> deactU = [SELECT Id, Name, IsActive FROM User WHERE Id IN :userIds LIMIT :cnt];
    //   for (User u : deactU) {
    //     u.IsActive = false;
    //   }
    //   update deactU;
    // }

    public List<User> getOrderedUsers(String orderBy) {
      Set<Id> userIds = (new Map<Id, User>(listUser)).keySet();
      String query = String.format('SELECT Id, Name, CompanyName, Department, Title, EMail FROM User WHERE Id IN :userIds ORDER BY {0}', new String[] { orderBy });
      return Database.query(query);
    }

    public Set<Id> getCardIds() {
      Map<Id, NameCard__c> id2card = new Map<Id, NameCard__c>(listCard);
      return id2card.keySet();
    }

    public override void initialize() {
      // SmartVisca設定
      initializeSmartViscaConfig();
      if (svConfig !=null) {
       upsert svConfig;
      }
      //　ユーザ作成
      initializeUser();
      if (!listUser.isEmpty()) {
        insert listUser;
      }
      // 名刺作成
      initializeNameCard(); 
      if (!listCard.isEmpty()) {
        insert listCard;
      }
      // 転職前後の名刺を作成
      createTenshokuMae();
    }
  }

  @isTest
  static void test_create() {
    TestDB db = new TestDB();
    db.initialize();

    NameCard__c card = [SELECT Id, OwnerId FROM NameCard__c LIMIT 1];
    SB_NC_CardOwnersBuilder builder = new SB_NC_CardOwnersBuilder(
        card.Id, // Id cardId,
        false,   // Boolean excludeMe,    // 自分を除外する
        true,   // Boolean includeCurrentOwner,  // このレコード所有者を含める
        true,   // Boolean includeInactiveUser,  // 無効なユーザも含める
        false,   // Boolean traceChangeJob, // 転職前後の名刺も含める
        true,   // Boolean showExchangeDate, // 名刺交換日を表示する
        'name', // String sortOrder, // 並び順(初期値)
        true,   // Boolean sortAsc) {   // 昇順          true, 
        'CompanyName, Department, Title',
        'CompanyName, Country, Department, Title, Email, Phone, Fax, EmployeeNumber'); // String fields,        // ユーザの表示項目 ToDo
    SB_NC_CardOwnersBuilder.GetCardOwnersResponse res = builder.create();
    System.assertEquals(db.listUser.size()+1, res.owners.size());
  }

  // 自分を除外する
  @isTest
  static void test_create_excludeMe() {
    TestDB db = new TestDB();
    db.initialize();

    NameCard__c card = [SELECT Id, OwnerId FROM NameCard__c LIMIT 1];
    SB_NC_CardOwnersBuilder builder = new SB_NC_CardOwnersBuilder(
        card.Id, // Id cardId,
        true,   // Boolean excludeMe,    // 自分を除外する
        true,   // Boolean includeCurrentOwner,  // このレコード所有者を含める
        true,   // Boolean includeInactiveUser,  // 無効なユーザも含める
        false,   // Boolean traceChangeJob, // 転職前後の名刺も含める
        true,   // Boolean showExchangeDate, // 名刺交換日を表示する
        'name', // String sortOrder, // 並び順(初期値)
        true,   // Boolean sortAsc) {   // 昇順          true, 
        'CompanyName, Department, Title',
        'CompanyName, Country, Department, Title, Email, Phone, Fax, EmployeeNumber'); // String fields,        // ユーザの表示項目 ToDo
    SB_NC_CardOwnersBuilder.GetCardOwnersResponse res = builder.create();
    System.assertEquals(db.listUser.size(), res.owners.size()); // 自分を除外する
  }

  // このレコード所有者を含める オフ
  @isTest
  static void test_create_includeCurrentOwnerOff() {
    TestDB db = new TestDB();
    db.initialize();

    NameCard__c card = [SELECT Id, OwnerId FROM NameCard__c LIMIT 1];
    SB_NC_CardOwnersBuilder builder = new SB_NC_CardOwnersBuilder(
        card.Id, // Id cardId,
        true,   // Boolean excludeMe,    // 自分を除外する
        false,   // Boolean includeCurrentOwner,  // このレコード所有者を含める
        true,   // Boolean includeInactiveUser,  // 無効なユーザも含める
        false,   // Boolean traceChangeJob, // 転職前後の名刺も含める
        true,   // Boolean showExchangeDate, // 名刺交換日を表示する
        'name', // String sortOrder, // 並び順(初期値)
        true,   // Boolean sortAsc) {   // 昇順          true, 
        'CompanyName, Department, Title',
        'CompanyName, Country, Department, Title, Email, Phone, Fax, EmployeeNumber'); // String fields,        // ユーザの表示項目 ToDo
    SB_NC_CardOwnersBuilder.GetCardOwnersResponse res = builder.create();
    System.assertEquals(db.listUser.size(), res.owners.size()); // このレコード所有者を含める オフ
  }

  // // 無効なユーザも含める オフ
  // @isTest
  // static void test_create_includeInactiveUserOff() {
  //   TestDB db = new TestDB();
  //   db.initialize();

  //   Test.startTest();
  //   db.deactivateUsers(2);  // 2人無効化

  //   NameCard__c card = [SELECT Id, OwnerId FROM NameCard__c LIMIT 1];
  //   SB_NC_CardOwnersBuilder builder = new SB_NC_CardOwnersBuilder(
  //       card.Id, // Id cardId,
  //       true,   // Boolean excludeMe,    // 自分を除外する
  //       false,   // Boolean includeCurrentOwner,  // このレコード所有者を含める
  //       false,   // Boolean includeInactiveUser,  // 無効なユーザも含める
  //       false,   // Boolean traceChangeJob, // 転職前後の名刺も含める
  //       true,   // Boolean showExchangeDate, // 名刺交換日を表示する
  //       'name', // String sortOrder, // 並び順(初期値)
  //       true,   // Boolean sortAsc) {   // 昇順          true, 
  //       'CompanyName, Country, Department, Title, Email, Phone, Fax, EmployeeNumber'); // String fields,        // ユーザの表示項目 ToDo
  //   SB_NC_CardOwnersBuilder.GetCardOwnersResponse res = builder.create();
  //   Test.stopTest();
  //   System.assertEquals(db.listUser.size()-2, res.owners.size()); // このレコード所有者を含める オフ
  // }

  // 転職前後の名刺も含める 名前でソート
  @isTest
  static void test_create_traceChangeJob_sortName() {
    TestDB db = new TestDB();
    db.initialize();

    NameCard__c card = [SELECT Id, OwnerId FROM NameCard__c LIMIT 1];
    SB_NC_CardOwnersBuilder builder = new SB_NC_CardOwnersBuilder(
        card.Id, // Id cardId,
        true,   // Boolean excludeMe,    // 自分を除外する
        true,   // Boolean includeCurrentOwner,  // このレコード所有者を含める
        true,   // Boolean includeInactiveUser,  // 無効なユーザも含める
        true,   // Boolean traceChangeJob, // 転職前後の名刺も含める
        true,   // Boolean showExchangeDate, // 名刺交換日を表示する
        'name', // String sortOrder, // 並び順(初期値)
        true,   // Boolean sortAsc) {   // 昇順          true, 
        'CompanyName, Department, Title',
        'CompanyName, Country, Department, Title, Email, Phone, Fax, EmployeeNumber'); // String fields,        // ユーザの表示項目 ToDo
    SB_NC_CardOwnersBuilder.GetCardOwnersResponse res = builder.create();
    System.assertEquals(db.listUser.size(), res.owners.size()); // このレコード所有者を含める オフ
    // System.assertEquals([SELECT Id FROM NameCard__c].size(), res.cards.size()); // 転職前後で 全部
    List<User> users = db.getOrderedUsers('Name ASC');
    System.assertEquals(users[0].Id, res.owners[0].id);
  }

  // 転職前後の名刺も含める 名前でソート 降順
  @isTest
  static void test_create_traceChangeJob_sortName_Desc() {
    TestDB db = new TestDB();
    db.initialize();

    NameCard__c card = [SELECT Id, OwnerId FROM NameCard__c LIMIT 1];
    SB_NC_CardOwnersBuilder builder = new SB_NC_CardOwnersBuilder(
        card.Id, // Id cardId,
        true,   // Boolean excludeMe,    // 自分を除外する
        true,   // Boolean includeCurrentOwner,  // このレコード所有者を含める
        true,   // Boolean includeInactiveUser,  // 無効なユーザも含める
        true,   // Boolean traceChangeJob, // 転職前後の名刺も含める
        true,   // Boolean showExchangeDate, // 名刺交換日を表示する
        'name', // String sortOrder, // 並び順(初期値)
        false,   // Boolean sortAsc) {   // 昇順          true, 
        'CompanyName, Department, Title',
        'CompanyName, Country, Department, Title, Email, Phone, Fax, EmployeeNumber'); // String fields,        // ユーザの表示項目 ToDo
    SB_NC_CardOwnersBuilder.GetCardOwnersResponse res = builder.create();
    System.assertEquals(db.listUser.size(), res.owners.size()); // このレコード所有者を含める オフ
    // System.assertEquals([SELECT Id FROM NameCard__c].size(), res.cards.size()); // 転職前後で 全部
    List<User> users = db.getOrderedUsers('Name DESC');
    System.assertEquals(users[0].Id, res.owners[0].id);    
  }

  // 転職前後の名刺も含める 部署でソート
  @isTest
  static void test_create_traceChangeJob_sortDept() {
    TestDB db = new TestDB();
    db.initialize();

    NameCard__c card = [SELECT Id, OwnerId FROM NameCard__c LIMIT 1];
    SB_NC_CardOwnersBuilder builder = new SB_NC_CardOwnersBuilder(
        card.Id, // Id cardId,
        true,   // Boolean excludeMe,    // 自分を除外する
        true,   // Boolean includeCurrentOwner,  // このレコード所有者を含める
        true,   // Boolean includeInactiveUser,  // 無効なユーザも含める
        true,   // Boolean traceChangeJob, // 転職前後の名刺も含める
        true,   // Boolean showExchangeDate, // 名刺交換日を表示する
        'department', // String sortOrder, // 並び順(初期値)
        true,   // Boolean sortAsc) {   // 昇順          true, 
        'CompanyName, Department, Title',
        'CompanyName, Country, Department, Title, Email, Phone, Fax, EmployeeNumber'); // String fields,        // ユーザの表示項目 ToDo
    SB_NC_CardOwnersBuilder.GetCardOwnersResponse res = builder.create();
    System.assertEquals(db.listUser.size(), res.owners.size()); // このレコード所有者を含める オフ
    // System.assertEquals([SELECT Id FROM NameCard__c].size(), res.cards.size()); // 転職前後で 全部
    List<User> users = db.getOrderedUsers('Department ASC');
    System.assertEquals(users[0].Id, res.owners[0].id);    
  }

  // 転職前後の名刺も含める 部署でソート 降順
  @isTest
  static void test_create_traceChangeJob_sortDept_Desc() {
    TestDB db = new TestDB();
    db.initialize();

    NameCard__c card = [SELECT Id, OwnerId FROM NameCard__c LIMIT 1];
    SB_NC_CardOwnersBuilder builder = new SB_NC_CardOwnersBuilder(
        card.Id, // Id cardId,
        true,   // Boolean excludeMe,    // 自分を除外する
        true,   // Boolean includeCurrentOwner,  // このレコード所有者を含める
        true,   // Boolean includeInactiveUser,  // 無効なユーザも含める
        true,   // Boolean traceChangeJob, // 転職前後の名刺も含める
        true,   // Boolean showExchangeDate, // 名刺交換日を表示する
        'department', // String sortOrder, // 並び順(初期値)
        false,   // Boolean sortAsc) {   // 昇順          true, 
        'CompanyName, Department, Title',
        'CompanyName, Country, Department, Title, Email, Phone, Fax, EmployeeNumber'); // String fields,        // ユーザの表示項目 ToDo
    SB_NC_CardOwnersBuilder.GetCardOwnersResponse res = builder.create();
    System.assertEquals(db.listUser.size(), res.owners.size()); // このレコード所有者を含める オフ
    // System.assertEquals([SELECT Id FROM NameCard__c].size(), res.cards.size()); // 転職前後で 全部
    List<User> users = db.getOrderedUsers('Department DESC');
    for (SB_NC_CardOwnersBuilder.CardOwner o : res.owners) {
      System.debug(o.id + ': ' + o.department);
    }
    System.assertEquals(users[0].Id, res.owners[0].id);    
  }

  // 転職前後の名刺も含める 名刺交換日でソート
  @isTest
  static void test_create_traceChangeJob_sortExchage() {
    TestDB db = new TestDB();
    db.initialize();

    NameCard__c card = [SELECT Id, OwnerId FROM NameCard__c LIMIT 1];
    SB_NC_CardOwnersBuilder builder = new SB_NC_CardOwnersBuilder(
        card.Id, // Id cardId,
        true,   // Boolean excludeMe,    // 自分を除外する
        true,   // Boolean includeCurrentOwner,  // このレコード所有者を含める
        true,   // Boolean includeInactiveUser,  // 無効なユーザも含める
        true,   // Boolean traceChangeJob, // 転職前後の名刺も含める
        true,   // Boolean showExchangeDate, // 名刺交換日を表示する
        'exchangeDate', // String sortOrder, // 並び順(初期値)
        true,   // Boolean sortAsc) {   // 昇順          true, 
        'CompanyName, Department, Title',
        'CompanyName, Country, Department, Title, Email, Phone, Fax, EmployeeNumber'); // String fields,        // ユーザの表示項目 ToDo
    SB_NC_CardOwnersBuilder.GetCardOwnersResponse res = builder.create();
    System.assertEquals(db.listUser.size(), res.owners.size()); // このレコード所有者を含める オフ
    // System.assertEquals([SELECT Id FROM NameCard__c].size(), res.cards.size()); // 転職前後で 全部
    Set<Id> userIds = (new Map<Id, User>(db.listUser)).keySet();
    List<NameCard__c> cards = [SELECT Id, Name, OwnerId FROM NameCard__c WHERE OwnerId IN :userIds ORDER BY card_exchange_date__c ASC];
    System.assertEquals(cards[0].OwnerId, res.owners[0].id);    
  }

  // 転職前後の名刺も含める 名刺交換日でソート 降順
  @isTest
  static void test_create_traceChangeJob_sortExchage_Desc() {
    TestDB db = new TestDB();
    db.initialize();

    NameCard__c card = [SELECT Id, OwnerId FROM NameCard__c LIMIT 1];
    SB_NC_CardOwnersBuilder builder = new SB_NC_CardOwnersBuilder(
        card.Id, // Id cardId,
        true,   // Boolean excludeMe,    // 自分を除外する
        true,   // Boolean includeCurrentOwner,  // このレコード所有者を含める
        true,   // Boolean includeInactiveUser,  // 無効なユーザも含める
        true,   // Boolean traceChangeJob, // 転職前後の名刺も含める
        true,   // Boolean showExchangeDate, // 名刺交換日を表示する
        'exchangeDate', // String sortOrder, // 並び順(初期値)
        false,   // Boolean sortAsc) {   // 昇順          true, 
        'CompanyName, Department, Title',
        'CompanyName, Country, Department, Title, Email, Phone, Fax, EmployeeNumber'); // String fields,        // ユーザの表示項目 ToDo
    SB_NC_CardOwnersBuilder.GetCardOwnersResponse res = builder.create();
    System.assertEquals(db.listUser.size(), res.owners.size()); // このレコード所有者を含める オフ
    // System.assertEquals([SELECT Id FROM NameCard__c].size(), res.cards.size()); // 転職前後で 全部
    Set<Id> userIds = (new Map<Id, User>(db.listUser)).keySet();
    List<NameCard__c> cards = [SELECT Id, Name, OwnerId FROM NameCard__c WHERE OwnerId IN :userIds ORDER BY card_exchange_date__c DESC];
    System.assertEquals(cards[0].OwnerId, res.owners[0].id);    
  }


}