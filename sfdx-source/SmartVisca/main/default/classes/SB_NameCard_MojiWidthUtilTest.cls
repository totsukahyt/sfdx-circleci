/*
 *
 * SB_NameCard_MojiWidthUtil のテストクラス
 *
 * 文字の全角半角を処理するユーティリティ
 *
 * Copyright (c) 2016 SunBridge Inc.
 *
 */
@isTest
private class SB_NameCard_MojiWidthUtilTest
{
  @isTest
  static void test()
  {

    String sub = SB_NameCard_MojiWidthUtil.toHalfWidth('Ｓｕｎｂｒｉｄｇｅ');
    System.assert(SB_NameCard_MojiWidthUtil.findIgnoreCaseWidth('1234Ｓｕｎｂｒｉｄｇｅ（）！', sub));

    sub = SB_NameCard_MojiWidthUtil.toHalfWidth('サンブリッジ');
    System.assert(SB_NameCard_MojiWidthUtil.findIgnoreCaseWidth('サンブリッジソリュ', sub));


  }
}