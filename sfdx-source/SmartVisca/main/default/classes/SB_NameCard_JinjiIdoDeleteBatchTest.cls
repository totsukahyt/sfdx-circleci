/*
 * Copyright (c) 2014 SunBridge Inc.
 *
 * 日経テレコン人事異動情報 WSI API 削除バッチ テストクラス
 *
 * @author fukui@sunbridge.com
 * @since 2014-11-28
 *
 * @Version 1 kou 2017.10.xx No Assert v1.21 for code scan
 */
@isTest
private class SB_NameCard_JinjiIdoDeleteBatchTest {

    static testMethod void test() {
        JinjiIdo__c ji = new JinjiIdo__c();
        ji.name = '人事異動情報１';
        ji.ContactName__c = 'テスト姓名';
        ji.AccountName__c = '株式会社サンブリッジ';
        ji.PrintedDate__c = Date.today().addDays(-40);  // 掲載日
        ji.AnnounceDate__c = Date.today().addDays(-30); // 発令日
        insert ji;
        SB_NameCard_JinjiIdoDeleteBatch instance = new SB_NameCard_JinjiIdoDeleteBatch();
        Database.executeBatch(instance);
        System.assertNotEquals(null, instance);
    }
}