@isTest
/**
 * 転職制御クラスのテストを実施するクラスです。
 *
 * @author H.Inada@SunBridge
 */
private class SB_NameCard_TenshokuExtention_Test{

    /**
     * 引数の値を元に、名刺オブジェクトを newして返します。
     * データ生成はしません。
     */
    private static NameCard__c createNameCardObject( String sei, String mei, String email, String company, String tel, Date changeDate, String nohinType) {
        NameCard__c nameCard = new NameCard__c( name=sei + ' ' + mei, person_name_last__c=sei, person_name_first__c=mei, email__c=email, company_name__c=company, tel1__c=tel, card_exchange_date__c=changeDate, delivery_type__c=nohinType);
        return nameCard;
    }

    private static testMethod void test01() {
 		Test.startTest();
		SB_NameCard_TestDB db = new SB_NameCard_TestDB();
		db.initialize();

        // 名寄せされない名刺データを作っておく
        List<NameCard__c> testData = new List<NameCard__c>();
        NameCard__C nc01_1 = createNameCardObject( '姓田', '名介', 'test01@mres.jp', 'テスト興行', '00000', Date.today().addDays(0), '2');
        NameCard__C nc01_2 = createNameCardObject( '姓田', '名介', 'test01@mres.jp', 'テスト興行', '11111', Date.today().addDays(1), '2');
        NameCard__C nc02_1 = createNameCardObject( '姓田', '名介', 'test02@mres.jp', 'テスト興行', '22222', Date.today().addDays(2), '2');
        NameCard__C nc02_2 = createNameCardObject( '姓田', '名介', 'test02@mres.jp', 'テスト興行', '33333', Date.today().addDays(3), '2');
        testData.add( nc01_1);
        testData.add( nc01_2);
        testData.add( nc02_1);
        testData.add( nc02_2);
        insert testData;

        // 状態の確認
        nc01_1 = [SELECT Id, Name, Saishin__c, Parent__c, tenshokugonomeishi__c, tenshokuzumi__c FROM NameCard__c WHERE Id = :nc01_1.id];
        nc01_2 = [SELECT Id, Name, Saishin__c, Parent__c, tenshokugonomeishi__c, tenshokuzumi__c FROM NameCard__c WHERE Id = :nc01_2.id];
        nc02_1 = [SELECT Id, Name, Saishin__c, Parent__c, tenshokugonomeishi__c, tenshokuzumi__c FROM NameCard__c WHERE Id = :nc02_1.id];
        nc02_2 = [SELECT Id, Name, Saishin__c, Parent__c, tenshokugonomeishi__c, tenshokuzumi__c FROM NameCard__c WHERE Id = :nc02_2.id];
        System.assertEquals( false, nc01_1.Saishin__c, 'test01_0001');
        System.assertEquals( nc01_2.Id, nc01_1.Parent__c, 'test01_0002');
        System.assertEquals( false, nc01_1.tenshokuzumi__c, 'test01_0003');
        System.assertEquals( true, nc01_2.Saishin__c, 'test01_0004');
        System.assertEquals( null, nc01_2.Parent__c, 'test01_0005');
        System.assertEquals( false, nc01_2.tenshokuzumi__c, 'test01_0006');
        System.assertEquals( false, nc02_1.Saishin__c, 'test01_0011');
        System.assertEquals( nc02_2.id, nc02_1.Parent__c, 'test01_0012');
        System.assertEquals( false, nc02_1.tenshokuzumi__c, 'test01_0013');
        System.assertEquals( true, nc02_2.Saishin__c, 'test01_0021');
        System.assertEquals( null, nc02_2.Parent__c, 'test01_0022');
        System.assertEquals( false, nc02_2.tenshokuzumi__c, 'test01_0023');

        // 転職実施
        ApexPages.StandardController sc = new ApexPages.StandardController(nc01_2);
        SB_NameCard_TenshokuExtention testTarget = new SB_NameCard_TenshokuExtention( sc);
        nc01_2.tenshokugonomeishi__c = nc02_1.id;
        testTarget.doSave();

        // 状態確認
        nc01_1 = [SELECT Id, Name, Saishin__c, Parent__c, tenshokugonomeishi__c, tenshokuzumi__c FROM NameCard__c WHERE Id = :nc01_1.id];
        nc01_2 = [SELECT Id, Name, Saishin__c, Parent__c, tenshokugonomeishi__c, tenshokuzumi__c FROM NameCard__c WHERE Id = :nc01_2.id];
        nc02_1 = [SELECT Id, Name, Saishin__c, Parent__c, tenshokugonomeishi__c, tenshokuzumi__c FROM NameCard__c WHERE Id = :nc02_1.id];
        nc02_2 = [SELECT Id, Name, Saishin__c, Parent__c, tenshokugonomeishi__c, tenshokuzumi__c FROM NameCard__c WHERE Id = :nc02_2.id];
        System.assertEquals( false, nc01_1.Saishin__c, 'test01_1001');
        System.assertEquals( nc02_2.id, nc01_1.Parent__c, 'test01_1002');
        System.assertEquals( true, nc01_1.tenshokuzumi__c, 'test01_1003');
        System.assertEquals( false, nc01_2.Saishin__c, 'test01_1004');
        System.assertEquals( nc02_2.id, nc01_2.Parent__c, 'test01_1005');
        System.assertEquals( true, nc01_2.tenshokuzumi__c, 'test01_1006');
        System.assertEquals( false, nc02_1.Saishin__c, 'test01_1011');
        System.assertEquals( nc02_2.id, nc02_1.Parent__c, 'test01_1012');
        System.assertEquals( false, nc02_1.tenshokuzumi__c, 'test01_1013');
        System.assertEquals( true, nc02_2.Saishin__c, 'test01_1021');
        System.assertEquals( null, nc02_2.Parent__c, 'test01_1022');
        System.assertEquals( false, nc02_2.tenshokuzumi__c, 'test01_1023');

  		Test.stopTest();
    }

}