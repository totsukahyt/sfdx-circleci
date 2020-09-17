/*
 * Copyright (c) 2014 SunBridge Inc.
 *
 * 日経テレコン人事異動情報 WSI API 人事異動情報取得日設定バッチ テストクラス
 *
 * @author fukui@sunbridge.com
 * @since 2014-11-28
 *
 * @Version 1 kou 2017.10.xx No Assert v1.21 for code scan
 */
@isTest
private class SB_NameCard_JinjiIdoFinishBatchTest {

    static testMethod void test() {
        NameCard__c n1 = new NameCard__c(
            tel1__c = '03-1111-1111',
            Name = '佐藤 一郎',
            company_name__c = '株式会社テスト１'
        );
        insert n1;
        SB_NameCard_JinjiIdoFinishBatch instance = new SB_NameCard_JinjiIdoFinishBatch();
        Database.executeBatch(instance);
        System.assertNotEquals(null, instance);
    }
}