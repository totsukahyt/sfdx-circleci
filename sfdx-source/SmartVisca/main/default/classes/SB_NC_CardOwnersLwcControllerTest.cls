/**
 *
 * SB_NC_CardOwnersLwcControllerTest
 *  SB_NC_CardOwnersLwcController のテストクラス
 *
 *  @author sawano
 *  @Version1 v2.4 2019.06.xx SV_DEV-1593 LEX画面の名刺詳細から「同じ名刺を持つユーザ」を確認できるようにしてほしい
 *
 **/
@isTest
private class SB_NC_CardOwnersLwcControllerTest {

  private class TestDB extends SB_NC_TestDB {
    // 名刺データ作成
    public override void initializeNameCard() {
      for (Integer n = 0; n < CNT_USER; n++) {
        listCard.add(new NameCard__c(Name='テスト 太郎', company_name__c='株式会社サンブリッジ', division__c='本社',
                      title_name__c='課長',
                      zip_code__c='150-0022', address_pref__c='東京都', address__c='渋谷区恵比寿南1-5-5',
                      tel1__c = '03-3333-3333', tel2__c = '03-4444-4444', // 電話番号
                      last_name__c='テスト', first_name__c='太郎', email__c='taro@test.com', delivery_type__c='2',
                      card_exchange_date__c=Date.today().addDays(-n), OwnerId=getUserId(n)));        
      }
    }

    public Id getUserId(Integer index) {
      return listUser.get(index).Id;
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
    }
  }

  @isTest
  static void test_getUsersHavingCard() {
    TestDB db = new TestDB();
    db.initialize();

    NameCard__c card = [SELECT Id FROM NameCard__c LIMIT 1];
    SB_NC_CardOwnersBuilder.GetCardOwnersResponse res = SB_NC_CardOwnersLwcController.getUsersHavingCard(
      card.Id, // Id cardId,
      false,   // Boolean excludeMe,    // 自分を除外する
      true,   // Boolean includeCurrentOwner,  // このレコード所有者を含める
      true,   // Boolean includeInactiveUser,  // 無効なユーザも表示する
      false,   // Boolean traceChangeJob, // 転職前後の名刺も含める
      true,   // Boolean showExchangeDate, // 名刺交換日を表示する
      'exchangeDate', // String sortField, // 並び替え項目
      true,   // Boolean sortAsc) {   // 昇順          true, 
      'CompanyName, Department, Title',
      'CompanyName, Country, Department, Title, Email, Phone, Fax, EmployeeNumber'); // String fields,        // ユーザの表示項目 ToDo    System.assertEquals(db.listUser.size(), res.owners.size());
    System.assertEquals(db.listUser.size(), res.owners.size());
  }

}