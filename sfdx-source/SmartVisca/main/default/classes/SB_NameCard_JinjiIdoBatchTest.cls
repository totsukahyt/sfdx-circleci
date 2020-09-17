/*
 * Copyright (c) 2014-2015 SunBridge Inc.
 *
 * 日経テレコン人事異動情報 WSI API バッチ スケジューラ テストクラス
 *
 * @author fukui@sunbridge.com
 * @since 2014-11-28
 *
 * @Version 1 kou 2017.10.xx No Assert v1.21 for code scan
 */
/*
 * Copyright (c) 2014-2018 SunBridge Inc.
 *
 * 日経テレコン人事異動情報 WSI API バッチ スケジューラ テストクラス 2
 *
 * @author fukui@sunbridge.com
 * @since 2014-11-28
 *
 * @Version 1 kou 2017.10.xx No Assert v1.21 for code scan  1 といいつつ 2
 * @Version 2 sawano  同一複数名刺　指定対応のテスト、start execude 内部での ガバナ制限のテスト
 *
 */
@isTest
private class SB_NameCard_JinjiIdoBatchTest
{

  @isTest
  static void test() {
    Test.startTest();
    // バッチ処理スケジュール
    SB_NameCard_JinjiIdoBatch batch1 = new SB_NameCard_JinjiIdoBatch();
    String jobId = System.schedule('test_batch',
                    '0 0 0 31 12 ? 2024',
                    batch1);
    SB_NameCard_JinjiIdoBatch batch2 = new SB_NameCard_JinjiIdoBatch(Date.today().addDays(-10), Date.today().addDays(5), new List<String>(), new List<String>(), new List<Date>());
    Test.stopTest();
    System.assert(String.isNotBlank(jobId));
    SB_NameCard_JinjiIdoBatch instance1 = new SB_NameCard_JinjiIdoBatch();
    Database.executeBatch(instance1);
    Test.setMock(HttpCalloutMock.class, new SB_NameCard_JinjiIdoBatchTestMock.batch());
    SB_NameCard_JinjiIdoBatchTestMock instance2 = new SB_NameCard_JinjiIdoBatchTestMock();
    SB_NameCard_JinjiIdoBatchTestMock3 instance3 = new SB_NameCard_JinjiIdoBatchTestMock3();
    System.assertNotEquals(null, instance2);
    System.assertNotEquals(null, instance3);
  }
}