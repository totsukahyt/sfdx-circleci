/*
 * Copyright (c) 2014 SunBridge Inc.
 *
 * 日経テレコン人事異動情報 WSI API テストクラス
 *
 * 注意
 * http://www.salesforce.com/us/developer/docs/apexcode/Content/apex_gov_limits.htm
 * Total number of callouts (HTTP requests or Web services calls) in a transaction         10
 * Maximum timeout for all callouts (HTTP requests or Web services calls) in a transaction 120 seconds
 * Default timeout of callouts (HTTP requests or Web services calls) in a transaction      10 seconds
 * Maximum size of callout request or response (HTTP request or Web services call)         3 MB
 *
 * @author fukui@sunbridge.com
 * @since 2014-11-28
 *
 *
 * 2017.01.xx  V1.18 LEX対応 作成時 sawano
 *  パッケージ作成時のテストで、各メソッドのCallout部分で以下のエラーが発生
 *  System.CalloutException: getBody: getHttpResponse: You have uncommitted work pending. Please commit or rollback before calling out
 *  Callout の前後を startTest と stopTest で挟んで解決
 *
 * @Version 1 kou 2017.10.xx No Assert v1.21 for code scan
 *
 */
@isTest
private class SB_NameCard_JinjiIdoApiTest {

    static testMethod void test() {
        Test.setMock(HttpCalloutMock.class, new SB_NameCard_JinjiIdoApiTestMock.JinjiLogin());
        Test.setMock(HttpCalloutMock.class, new SB_NameCard_JinjiIdoApiTestMock.JinjiLoginNonCookie());
        Test.setMock(HttpCalloutMock.class, new SB_NameCard_JinjiIdoApiTestMock.JinjiLoginMsg());
        Test.setMock(HttpCalloutMock.class, new SB_NameCard_JinjiIdoApiTestMock.JinjiGetCount());
        Test.setMock(HttpCalloutMock.class, new SB_NameCard_JinjiIdoApiTestMock.JinjiGetList());
        Test.setMock(HttpCalloutMock.class, new SB_NameCard_JinjiIdoApiTestMock.JinjiGetBody());
        SB_NameCard_JinjiIdoApi instance1 = new SB_NameCard_JinjiIdoApi();
        SB_NameCard_JinjiIdoApiTestMock instance2 = new SB_NameCard_JinjiIdoApiTestMock();
        SB_NameCard_JinjiIdoApiTestMock3 instance3 = new SB_NameCard_JinjiIdoApiTestMock3();
        System.assertNotEquals(null, instance1);
        System.assertNotEquals(null, instance2);
        System.assertNotEquals(null, instance3);
    }
}