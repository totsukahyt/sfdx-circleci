/*
 * Copyright (c) 2015-2017 SunBridge Inc.
 *
 * deprecated
 *  2017.05.xx コンポーネントを削除すると、インストール済のVFページで controller に このクラスが指定されているので、
 *    インストール時にエラーになるので、中身を空にしてのこします。
 *    SV_DEV-255 1.17 リソースの整理
 *
 */
@isTest
private class SB_NameCard_JinjiIdoEncKeyControllerTest
{
  private static testMethod void test()
  {
    SB_NameCard_JinjiIdoEncKeyController instance = new SB_NameCard_JinjiIdoEncKeyController();
    System.assertNotEquals(null, instance);
  }
}