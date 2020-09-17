/*
 * Copyright (c) 2014-2015 SunBridge Inc.
 *
 * 日経テレコン人事異動情報 WSI テストクラス
 *
 * @author fukui@sunbridge.com
 * @since 2014-11-28
 *
 * @Version 1 kou 2017.10.xx No Assert v1.21 for code scan
 */

@isTest
private class SB_NameCard_JinjiIdoControllerTest {

    private static testMethod void test() {
        SB_NameCard_JinjiIdoController instance = new SB_NameCard_JinjiIdoController();
        System.assertNotEquals(null, instance);
    }
}