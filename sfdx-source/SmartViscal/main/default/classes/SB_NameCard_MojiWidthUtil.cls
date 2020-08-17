/*
 *
 * SB_NameCard_MojiWidthUtil
 *
 * 文字の全角半角を処理するユーティリティ
 *
 * Copyright (c) 2016 SunBridge Inc.
 *
 * @author gao
 * @Version 1.22 2017.12.XX SV_DEV-695  クエリの シングルクオート、バックスラッシュ のエスケープ処理を最適化する。
 */
public with sharing class SB_NameCard_MojiWidthUtil {

  // すべての全角ASCIIの文字列
  @TestVisible
  private static final String zenkaku =
    '！＂＃＄％＆’（）＊＋，－．／０１２３４５６７８９：；＜＝＞？＠ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ［＼］＾＿｀ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ｛｜｝～';

  // 全角 ACII と 半角ACIIのマップ
  @TestVisible
  private static final Map<String, String> zenkaku2Hankaku  = new Map<String, String> {
            '！' =>  '!',
            '＂' =>  '"',
            '＃' =>  '#',
            '＄' =>  '$',
            '％' =>  '%',
            '＆' =>  '&',
            // '＇' =>  '\'',
            //SV_DEV-695  クエリの シングルクオート、バックスラッシュ のエスケープ処理を最適化する。
            '’' =>  '\'',
            '（' =>  '(',
            '）' =>  ')',
            '＊' =>  '*',
            '＋' =>  '+',
            '，' =>  ',',
            '－' =>  '-',
            '．' =>  '.',
            '／' =>  '/',
            '０' =>  '0',
            '１' =>  '1',
            '２' =>  '2',
            '３' =>  '3',
            '４' =>  '4',
            '５' =>  '5',
            '６' =>  '6',
            '７' =>  '7',
            '８' =>  '8',
            '９' =>  '9',
            '：' =>  ':',
            '；' =>  ';',
            '＜' =>  '<',
            '＝' =>  '=',
            '＞' =>  '>',
            '？' =>  '?',
            '＠' =>  '@',
            'Ａ' =>  'A',
            'Ｂ' =>  'B',
            'Ｃ' =>  'C',
            'Ｄ' =>  'D',
            'Ｅ' =>  'E',
            'Ｆ' =>  'F',
            'Ｇ' =>  'G',
            'Ｈ' =>  'H',
            'Ｉ' =>  'I',
            'Ｊ' =>  'J',
            'Ｋ' =>  'K',
            'Ｌ' =>  'L',
            'Ｍ' =>  'M',
            'Ｎ' =>  'N',
            'Ｏ' =>  'O',
            'Ｐ' =>  'P',
            'Ｑ' =>  'Q',
            'Ｒ' =>  'R',
            'Ｓ' =>  'S',
            'Ｔ' =>  'T',
            'Ｕ' =>  'U',
            'Ｖ' =>  'V',
            'Ｗ' =>  'W',
            'Ｘ' =>  'X',
            'Ｙ' =>  'Y',
            'Ｚ' =>  'Z',
            '［' =>  '[',
            '＼' =>  '\\',
            '］' =>  ']',
            '＾' =>  '^',
            '＿' =>  '_',
            '｀' =>  '`',
            'ａ' =>  'a',
            'ｂ' =>  'b',
            'ｃ' =>  'c',
            'ｄ' =>  'd',
            'ｅ' =>  'e',
            'ｆ' =>  'f',
            'ｇ' =>  'g',
            'ｈ' =>  'h',
            'ｉ' =>  'i',
            'ｊ' =>  'j',
            'ｋ' =>  'k',
            'ｌ' =>  'l',
            'ｍ' =>  'm',
            'ｎ' =>  'n',
            'ｏ' =>  'o',
            'ｐ' =>  'p',
            'ｑ' =>  'q',
            'ｒ' =>  'r',
            'ｓ' =>  's',
            'ｔ' =>  't',
            'ｕ' =>  'u',
            'ｖ' =>  'v',
            'ｗ' =>  'w',
            'ｘ' =>  'x',
            'ｙ' =>  'y',
            'ｚ' =>  'z',
            '｛' =>  '{',
            '｜' =>  '|',
            '｝' =>  '}',
            '～' =>  '~' };

  // 文字列中の全角ACSII を 半角に変換した文字列を戻す
  public static String toHalfWidth(String src) {
    if (src.indexOfAny(zenkaku) < 0) {
      // 全角がない
      return src;
    }
    String result = '';
    for (Integer n =0; n < src.length(); n++) {
      String s = src.mid(n, 1);
      if (zenkaku2Hankaku.containsKey(s)) {
        result += zenkaku2Hankaku.get(s);
      }
      else {
        result += s;
      }
    }
    return result;
  }

  // 文字列 text の一部に指定の文字列 sub が含まれているかチェック 全角半角を区別せずチェック
  // 含まれていれば TRUE
  // text は 全角半角が混在で可
  // sub は 全角文字は （toHalfWidth を使って）半角に変換されている前提
  public static Boolean findIgnoreCaseWidth(String text, String sub) {
    String half = toHalfWidth(text);
    return half.indexOfIgnoreCase(sub) >= 0;
  }

}