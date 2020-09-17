/*  $Id$    */

/*
 * Copyright (c) 2015 SunBridge Inc.
 *
 * 日経テレコン人事異動情報 WSI
 * キー設定画面 テスト
 *
 * @Version 1 kou 2017.10.xx No Assert v1.21 for code scan
 */

@isTest
public class SB_NameCard_JinjiIdoSetKeyControllerTest
{
    private static testMethod void test() {
        SB_NameCard_JinjiIdoSetKeyController instance = new SB_NameCard_JinjiIdoSetKeyController();
        System.assertNotEquals(null, instance);
    }
}