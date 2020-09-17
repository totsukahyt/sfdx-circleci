@isTest
/**
 * 名刺関連のテストを実施するクラスです。
 *
 * @author H.Inada@SunBridge
 */
private class SB_NameCard_Various_Test {

    /**
     * 引数の値を元に、名刺オブジェクトを newして返します。
     * データ生成はしません。
     */
    private static NameCard__c createNameCardObject( String sei, String mei, String email, String company, String tel, Date changeDate, String nohinType) {
        NameCard__c nameCard = new NameCard__c( name=sei + ' ' + mei, person_name_last__c=sei, person_name_first__c=mei, email__c=email, company_name__c=company, tel1__c=tel, card_exchange_date__c=changeDate, delivery_type__c=nohinType);
        return nameCard;
    }


    /**
     * トリガー複数回起動抑制クラスのテストをします。
     * 過去名刺が2つある状態で、3つ目の名刺を登録します。
     * テスト対象  SB_NameCard_FirstRunKeeper
     */
    public static testMethod void test00() {
        System.assertEquals( true, SB_NameCard_MergeBuisnessCardsAfter.firstRun, 'test00_001');
    }

    /**
     * 名刺名寄機能のテストを実施します。
     * 過去名刺が2つある状態で、3つ目の名刺を登録します。
     * テスト対象  SB_NameCard_AftInsUpdDelOnNameCard
     *             SB_NameCard_MergeBuisnessCardsAfter
     */
    public static testMethod void test01() {
        Test.startTest();
        SB_NameCard_TestDB db = new SB_NameCard_TestDB();
        db.initialize();

        List<NameCard__c> testData = new List<NameCard__c>();

        // 名刺データを生成
        NameCard__C nc01 = createNameCardObject( '姓田', '名介', 'test@test.com', 'テスト興行', '11111', Date.today().addDays(0), '2');
        NameCard__C nc02 = createNameCardObject( '姓田', '名介', 'test@test.com', 'テスト興行', '22222', Date.today().addDays(3), '2');
        testData.add( nc01);
        testData.add( nc02);
        insert testData;


        nc01 = [SELECT Id, Name, person_name_last__c, person_name_first__c, email__c, company_name__c, tel1__c, card_exchange_date__c, Saishin__c, Parent__c, delivery_type__c FROM NameCard__c WHERE Id = :nc01.Id];
        nc02 = [SELECT Id, Name, person_name_last__c, person_name_first__c, email__c, company_name__c, tel1__c, card_exchange_date__c, Saishin__c, Parent__c, delivery_type__c FROM NameCard__c WHERE Id = :nc02.Id];

        // 現状を確認
        System.assertEquals( false, nc01.Saishin__c, 'test01_001');
        System.assertEquals( true, nc02.Saishin__c, 'test01_002');
        System.assertEquals( nc02.Id, nc01.Parent__c, 'test01_003');
        System.assertEquals( null, nc02.Parent__c, 'test01_004');

        // 3つ目の名刺データを追加
        SB_NameCard_MergeBuisnessCardsAfter.firstRun = true;
        NameCard__C nc03 = createNameCardObject( '姓田', '名介', 'test@test.com', 'テスト興行', '33333', Date.today().addDays(4), '2');
        insert nc03;

        // 追加後の状況を確認
        nc01 = [SELECT Id, Name, person_name_last__c, person_name_first__c, email__c, company_name__c, tel1__c, card_exchange_date__c, Saishin__c, Parent__c, delivery_type__c FROM NameCard__c WHERE Id = :nc01.Id];
        nc02 = [SELECT Id, Name, person_name_last__c, person_name_first__c, email__c, company_name__c, tel1__c, card_exchange_date__c, Saishin__c, Parent__c, delivery_type__c FROM NameCard__c WHERE Id = :nc02.Id];
        nc03 = [SELECT Id, Name, person_name_last__c, person_name_first__c, email__c, company_name__c, tel1__c, card_exchange_date__c, Saishin__c, Parent__c, delivery_type__c FROM NameCard__c WHERE Id = :nc03.Id];
        System.assertEquals( false, nc01.Saishin__c, 'test01_011');
        System.assertEquals( false, nc02.Saishin__c, 'test01_012');
        System.assertEquals( true, nc03.Saishin__c, 'test01_013');
        System.assertEquals( nc03.Id, nc01.Parent__c, 'test01_015');
        System.assertEquals( nc03.Id, nc02.Parent__c, 'test01_016');
        System.assertEquals( null, nc03.Parent__c, 'test01_017');

        // 4枚目は、最新とはならない名刺として追加する
        SB_NameCard_MergeBuisnessCardsAfter.firstRun = true;
        NameCard__C nc04 = createNameCardObject( '姓田', '名介', 'test@test.com', 'テスト興行', '4444', Date.today().addDays(2), '2');
        insert nc04;

        // 追加後の状況を確認
        nc01 = [SELECT Id, Name, person_name_last__c, person_name_first__c, email__c, company_name__c, tel1__c, card_exchange_date__c, Saishin__c, Parent__c, delivery_type__c FROM NameCard__c WHERE Id = :nc01.Id];
        nc02 = [SELECT Id, Name, person_name_last__c, person_name_first__c, email__c, company_name__c, tel1__c, card_exchange_date__c, Saishin__c, Parent__c, delivery_type__c FROM NameCard__c WHERE Id = :nc02.Id];
        nc03 = [SELECT Id, Name, person_name_last__c, person_name_first__c, email__c, company_name__c, tel1__c, card_exchange_date__c, Saishin__c, Parent__c, delivery_type__c FROM NameCard__c WHERE Id = :nc03.Id];
        nc04 = [SELECT Id, Name, person_name_last__c, person_name_first__c, email__c, company_name__c, tel1__c, card_exchange_date__c, Saishin__c, Parent__c, delivery_type__c FROM NameCard__c WHERE Id = :nc04.Id];
        System.assertEquals( false, nc01.Saishin__c, 'test01_021');
        System.assertEquals( false, nc02.Saishin__c, 'test01_022');
        System.assertEquals( true, nc03.Saishin__c, 'test01_023');
        System.assertEquals( false, nc04.Saishin__c, 'test01_024');
        System.assertEquals( nc03.Id, nc01.Parent__c, 'test01_025');
        System.assertEquals( nc03.Id, nc02.Parent__c, 'test01_026');
        System.assertEquals( null, nc03.Parent__c, 'test01_027');
        System.assertEquals( nc03.id, nc04.Parent__c, 'test01_028');

        // 最新の nc03を削除する
        SB_NameCard_MergeBuisnessCardsAfter.firstRun = true;
        delete nc03;
        // 追加後の状況を確認
        nc01 = [SELECT Id, Name, person_name_last__c, person_name_first__c, email__c, company_name__c, tel1__c, card_exchange_date__c, Saishin__c, Parent__c, delivery_type__c FROM NameCard__c WHERE Id = :nc01.Id];
        nc02 = [SELECT Id, Name, person_name_last__c, person_name_first__c, email__c, company_name__c, tel1__c, card_exchange_date__c, Saishin__c, Parent__c, delivery_type__c FROM NameCard__c WHERE Id = :nc02.Id];
        try {
            nc03 = [SELECT Id, Name, person_name_last__c, person_name_first__c, email__c, company_name__c, tel1__c, card_exchange_date__c, Saishin__c, Parent__c, delivery_type__c FROM NameCard__c WHERE Id = :nc03.Id];
            System.assertEquals( true, false, 'test01_030');
        }
        catch ( System.QueryException sqe) {
        }
        nc04 = [SELECT Id, Name, person_name_last__c, person_name_first__c, email__c, company_name__c, tel1__c, card_exchange_date__c, Saishin__c, Parent__c, delivery_type__c FROM NameCard__c WHERE Id = :nc04.Id];
        System.assertEquals( false, nc01.Saishin__c, 'test01_031');
        System.assertEquals( true, nc02.Saishin__c, 'test01_032');
//        System.assertEquals( true, nc03.Saishin__c, 'test01_033');
        System.assertEquals( false, nc04.Saishin__c, 'test01_034');
        System.assertEquals( nc02.Id, nc01.Parent__c, 'test01_035');
        System.assertEquals( null, nc02.Parent__c, 'test01_036');
//        System.assertEquals( null, nc03.Parent__c, 'test01_037');
        System.assertEquals( nc02.id, nc04.Parent__c, 'test01_038');

        Test.stopTest();
    }

    /**
     * 名刺名寄機能のテストを実施します。
     * 過去名刺が2つある状態で、3つ目に、未納品の名刺を登録し、名寄の対象とならないことをテストします。
     * テスト対象  SB_NameCard_AftInsUpdDelOnNameCard
     *             SB_NameCard_MergeBuisnessCardsAfter
     */
    public static testMethod void test02() {
        Test.startTest();
        SB_NameCard_TestDB db = new SB_NameCard_TestDB();
        db.initialize();

        List<NameCard__c> testData = new List<NameCard__c>();

        // 名刺データを生成
        NameCard__C nc01 = createNameCardObject( '姓田', '名介', 'test@test.com', 'テスト興行', '11111', Date.today().addDays(0), '2');
        NameCard__C nc02 = createNameCardObject( '姓田', '名介', 'test@test.com', 'テスト興行', '22222', Date.today().addDays(3), '2');
        testData.add( nc01);
        testData.add( nc02);
        insert testData;


        nc01 = [SELECT Id, Name, person_name_last__c, person_name_first__c, email__c, company_name__c, tel1__c, card_exchange_date__c, Saishin__c, Parent__c, delivery_type__c FROM NameCard__c WHERE Id = :nc01.Id];
        nc02 = [SELECT Id, Name, person_name_last__c, person_name_first__c, email__c, company_name__c, tel1__c, card_exchange_date__c, Saishin__c, Parent__c, delivery_type__c FROM NameCard__c WHERE Id = :nc02.Id];

        // 現状を確認
        System.assertEquals( false, nc01.Saishin__c, 'test02_001');
        System.assertEquals( true, nc02.Saishin__c, 'test02_002');
        System.assertEquals( nc02.Id, nc01.Parent__c, 'test02_003');
        System.assertEquals( null, nc02.Parent__c, 'test02_004');

        // 3つ目の名刺データを追加
        SB_NameCard_MergeBuisnessCardsAfter.firstRun = true;
        NameCard__C nc03 = createNameCardObject( '姓田', '名介', 'test@test.com', 'テスト興行', '33333', Date.today().addDays(4), '1');
        insert nc03;

        // 追加後の状況を確認
        nc01 = [SELECT Id, Name, person_name_last__c, person_name_first__c, email__c, company_name__c, tel1__c, card_exchange_date__c, Saishin__c, Parent__c, delivery_type__c FROM NameCard__c WHERE Id = :nc01.Id];
        nc02 = [SELECT Id, Name, person_name_last__c, person_name_first__c, email__c, company_name__c, tel1__c, card_exchange_date__c, Saishin__c, Parent__c, delivery_type__c FROM NameCard__c WHERE Id = :nc02.Id];
        nc03 = [SELECT Id, Name, person_name_last__c, person_name_first__c, email__c, company_name__c, tel1__c, card_exchange_date__c, Saishin__c, Parent__c, delivery_type__c FROM NameCard__c WHERE Id = :nc03.Id];
        System.assertEquals( false, nc01.Saishin__c, 'test02_011');
        System.assertEquals( true, nc02.Saishin__c, 'test02_012');
        System.assertEquals( false, nc03.Saishin__c, 'test02_013');
        System.assertEquals( nc02.Id, nc01.Parent__c, 'test02_015');
        System.assertEquals( null, nc02.Parent__c, 'test02_016');
        System.assertEquals( null, nc03.Parent__c, 'test02_017');

        Test.stopTest();
    }


    /**
     * 名刺名寄機能のテストを実施します。
     * 同時に異なる人の名刺を登録し、名寄せされないことを確認します。
     * テスト対象  SB_NameCard_AftInsUpdDelOnNameCard
     *             SB_NameCard_MergeBuisnessCardsAfter
     */
    public static testMethod void test03() {
        Test.startTest();
        SB_NameCard_TestDB db = new SB_NameCard_TestDB();
        db.initialize();

        List<NameCard__c> testData = new List<NameCard__c>();

        // 名刺データを生成
        NameCard__C nc01 = createNameCardObject( '姓田', '名介1', 'test@test.com', 'テスト興行', '11111', Date.today().addDays(0), '2');
        NameCard__C nc02 = createNameCardObject( '姓田', '名介2', 'test@test.com', 'テスト興行', '22222', Date.today().addDays(1), '2');
        NameCard__C nc03 = createNameCardObject( '姓田', '名介3', 'test@test.com', 'テスト興行', '33333', Date.today().addDays(2), '2');
        testData.add( nc01);
        testData.add( nc02);
        testData.add( nc03);
        insert testData;


        nc01 = [SELECT Id, Name, person_name_last__c, person_name_first__c, email__c, company_name__c, tel1__c, card_exchange_date__c, Saishin__c, Parent__c, delivery_type__c FROM NameCard__c WHERE Id = :nc01.Id];
        nc02 = [SELECT Id, Name, person_name_last__c, person_name_first__c, email__c, company_name__c, tel1__c, card_exchange_date__c, Saishin__c, Parent__c, delivery_type__c FROM NameCard__c WHERE Id = :nc02.Id];
        nc03 = [SELECT Id, Name, person_name_last__c, person_name_first__c, email__c, company_name__c, tel1__c, card_exchange_date__c, Saishin__c, Parent__c, delivery_type__c FROM NameCard__c WHERE Id = :nc03.Id];

        // 現状を確認
        System.assertEquals( true, nc01.Saishin__c, 'test03_001');
        System.assertEquals( true, nc02.Saishin__c, 'test03_002');
        System.assertEquals( true, nc03.Saishin__c, 'test03_003');
        System.assertEquals( null, nc01.Parent__c, 'test03_004');
        System.assertEquals( null, nc02.Parent__c, 'test03_005');
        System.assertEquals( null, nc03.Parent__c, 'test03_006');

        // 4つ目の名刺データを追加
        SB_NameCard_MergeBuisnessCardsAfter.firstRun = true;
        NameCard__C nc04 = createNameCardObject( '姓田', '名介1', 'test@test.com', 'テスト興行', '44444', Date.today().addDays(-1), '2');
        insert nc04;

        // nc01に名寄せされることを確認
        nc01 = [SELECT Id, Name, person_name_last__c, person_name_first__c, email__c, company_name__c, tel1__c, card_exchange_date__c, Saishin__c, Parent__c, delivery_type__c FROM NameCard__c WHERE Id = :nc01.Id];
        nc02 = [SELECT Id, Name, person_name_last__c, person_name_first__c, email__c, company_name__c, tel1__c, card_exchange_date__c, Saishin__c, Parent__c, delivery_type__c FROM NameCard__c WHERE Id = :nc02.Id];
        nc03 = [SELECT Id, Name, person_name_last__c, person_name_first__c, email__c, company_name__c, tel1__c, card_exchange_date__c, Saishin__c, Parent__c, delivery_type__c FROM NameCard__c WHERE Id = :nc03.Id];
        nc04 = [SELECT Id, Name, person_name_last__c, person_name_first__c, email__c, company_name__c, tel1__c, card_exchange_date__c, Saishin__c, Parent__c, delivery_type__c FROM NameCard__c WHERE Id = :nc04.Id];
        System.assertEquals( true, nc01.Saishin__c, 'test03_011');
        System.assertEquals( true, nc02.Saishin__c, 'test03_012');
        System.assertEquals( true, nc03.Saishin__c, 'test03_013');
        System.assertEquals( false, nc04.Saishin__c, 'test03_014');
        System.assertEquals( null, nc01.Parent__c, 'test03_011');
        System.assertEquals( null, nc02.Parent__c, 'test03_012');
        System.assertEquals( null, nc03.Parent__c, 'test03_013');
        System.assertEquals( nc01.Id, nc04.Parent__c, 'test03_014');

        Test.stopTest();
    }

}