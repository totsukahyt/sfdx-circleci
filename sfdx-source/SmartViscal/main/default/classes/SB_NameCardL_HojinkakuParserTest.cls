/**
 *
 *  SB_NameCardL_HojinkakuParserTest
 *   SB_NameCardL_HojinkakuParser のテストクラス
 *
 *  Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 2.4      2019.05.xx 
 *
 *  @Version 2.1 全 2020.07.31 PRODUCT-357 【自動連携】リード連携拡張：会社名の比較条件「法人格の略称を正称の表記とみなして会社名を比較する」の対応 SB_NameCard_HojinkakuParserTest.clsの移植
 *  
 **/
@isTest
private class SB_NameCardL_HojinkakuParserTest {

  @isTest
  static void test_isEqualeKaishamei_true() {
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ', 'サンブリッジ'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('株式会社サンブリッジ', '株式会社サンブリッジ'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('株式会社サンブリッジ', '株式会社 サンブリッジ'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('株式会社サンブリッジ', '株式会社　サンブリッジ'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('株式会社サンブリッジ', '(株) サンブリッジ'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('株式会社サンブリッジ', '(株)　サンブリッジ'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('株式会社サンブリッジ', '(株)サンブリッジ'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('株式会社サンブリッジ', '（株）サンブリッジ'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('株式会社サンブリッジ', '（株)サンブリッジ'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('株式会社サンブリッジ', '(株）サンブリッジ'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('株式会社サンブリッジ', '㈱ サンブリッジ'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('株式会社サンブリッジ', '㈱　サンブリッジ'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('株式会社サンブリッジ', '㈱サンブリッジ'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('株式会社サンブリッジ', '㈱ 　　 サンブリッジ'));

    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ株式会社', 'サンブリッジ株式会社'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ株式会社', 'サンブリッジ 株式会社'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ株式会社', 'サンブリッジ　株式会社'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ株式会社', 'サンブリッジ (株)'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ株式会社', 'サンブリッジ　(株)'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ株式会社', 'サンブリッジ(株)'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ株式会社', 'サンブリッジ（株）'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ株式会社', 'サンブリッジ（株)'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ株式会社', 'サンブリッジ(株）'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ株式会社', 'サンブリッジ ㈱'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ株式会社', 'サンブリッジ　㈱'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ株式会社', 'サンブリッジ㈱'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ 　　 株式会社', 'サンブリッジ㈱'));

    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('有限会社サンブリッジ', '（有）サンブリッジ'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('有限会社サンブリッジ', '㈲サンブリッジ'));

    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('公益社団法人サンブリッジ', '(公社)サンブリッジ'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('公益社団法人サンブリッジ', '(公社) サンブリッジ'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('公益社団法人サンブリッジ', '(公社)　サンブリッジ'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('公益社団法人サンブリッジ', '(公社)サンブリッジ'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('公益社団法人サンブリッジ', '(公社) サンブリッジ'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('公益社団法人サンブリッジ', '（公社）サンブリッジ'));

    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ公益社団法人', 'サンブリッジ(公社)'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ公益社団法人', 'サンブリッジ (公社)'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ公益社団法人', 'サンブリッジ　(公社)'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ公益社団法人', 'サンブリッジ(公社)'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ公益社団法人', 'サンブリッジ (公社)'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ公益社団法人', 'サンブリッジ（公社）'));

    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('公益財団法人サンブリッジ', '(公財)サンブリッジ'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('公益財団法人サンブリッジ', '(公財) サンブリッジ'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('公益財団法人サンブリッジ', '(公財)　サンブリッジ'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('公益財団法人サンブリッジ', '(公財)サンブリッジ'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('公益財団法人サンブリッジ', '(公財) サンブリッジ'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('公益財団法人サンブリッジ', '（公財）サンブリッジ'));

    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ公益財団法人', 'サンブリッジ(公財)'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ公益財団法人', 'サンブリッジ (公財)'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ公益財団法人', 'サンブリッジ　(公財)'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ公益財団法人', 'サンブリッジ(公財)'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ公益財団法人', 'サンブリッジ (公財)'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ公益財団法人', 'サンブリッジ（公財）'));

    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ一般社団法人', 'サンブリッジ(一社)'));    
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ一般財団法人', 'サンブリッジ（一財）'));

    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ社団法人', 'サンブリッジ(社)'));   
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ社団法人', 'サンブリッジ㈳'));   
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ財団法人', 'サンブリッジ(財)'));   
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ財団法人', 'サンブリッジ㈶'));   
    // 社会福祉法人, 福
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ社会福祉法人', 'サンブリッジ （福）'));   
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('社会福祉法人サンブリッジ', ' （福） サンブリッジ'));   
    // 弁護士法人, 弁
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ弁護士法人', 'サンブリッジ （弁）'));   
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('弁護士法人サンブリッジ', ' （弁）サンブリッジ'));   
    // 行政書士法人, 行
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ行政書士法人', 'サンブリッジ （行）'));   
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('行政書士法人サンブリッジ', '（行） サンブリッジ'));   
    // 司法書士法人, 司
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ司法書士法人', 'サンブリッジ （司）'));   
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('司法書士法人サンブリッジ', '（司）　　 サンブリッジ'));   
    // 税理士法人, 税
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ税理士法人', 'サンブリッジ （税）'));   
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('税理士法人サンブリッジ', ' （税）  　　サンブリッジ'));   

    // 医療法人, 医, 医療法人社団, 医療法人財団, 社会医療法人
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('医療法人社団サンブリッジ', '(医)サンブリッジ'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ医療法人', 'サンブリッジ(医)'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ医療法人社団', 'サンブリッジ(医)'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ医療法人財団', 'サンブリッジ(医)'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('社会医療法人サンブリッジ', '(医)サンブリッジ'));        
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('社会医療法人財団 石心会 川崎幸病院', '(医)財団 石心会 川崎幸病院'));        
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ社会医療法人', 'サンブリッジ(医)'));    

    // 大:国立大学法人, 公立大学法人
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ国立大学法人', 'サンブリッジ （大）'));    
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('国立大学法人サンブリッジ', '（大）サンブリッジ'));    
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ公立大学法人', 'サンブリッジ （大）'));    
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('公立大学法人サンブリッジ', '（大）サンブリッジ'));    
    // 中:有限責任中間法人, 無限責任中間法人
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ有限責任中間法人', 'サンブリッジ （中）'));    
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('有限責任中間法人サンブリッジ', '（中）サンブリッジ'));    
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ無限責任中間法人', 'サンブリッジ （中）'));    
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('無限責任中間法人サンブリッジ', '（中）サンブリッジ'));    

    // 日本生命保険相互会社
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('日本生命保険相互会社', '日本生命保険（相)'));    

  }

  @isTest
  static void test_isEqualeKaishamei_width_true() {
    // アルファベット 大文字、小文字、全角、半角 は同一視する。
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('ABC株式会社', 'ＡＢＣ株式会社'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('ABC株式会社', 'ａｂｃ株式会社'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('ABC株式会社', 'abc株式会社'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('abc株式会社', 'ａｂｃ株式会社'));
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('abc株式会社', 'ＡＢＣ株式会社'));
    // カタカナ全半角は不一致、、
    System.assertEquals(false, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ', 'ｻﾝﾌﾞﾘｯｼﾞ'));
    System.assertEquals(false, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('株式会社サンブリッジ', '株式会社ｻﾝﾌﾞﾘｯｼﾞ'));
    System.assertEquals(false, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('株式会社サンブリッジ', '(株)ｻﾝﾌﾞﾘｯｼﾞ'));
    System.assertEquals(false, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('株式会社サンブリッジ', '㈱ ｻﾝﾌﾞﾘｯｼﾞ'));
  }

  @isTest
  static void test_isEqualeKaishamei_false() {
    System.assertEquals(false, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ', 'ヨンブリッジ'));
    System.assertEquals(false, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('株式会社サンブリッジ', 'サンブリッジ'));
    System.assertEquals(false, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ株式会社', 'サンブリッジ'));
    System.assertEquals(false, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ株式会社', '(株) サンブリッジ'));
    System.assertEquals(false, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ株式会社', '(株)サンブリッジ'));
    System.assertEquals(false, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ株式会社', '㈱ サンブリッジ'));
    System.assertEquals(false, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ株式会社', '㈱サンブリッジ'));
    System.assertEquals(false, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ株式会社', 'サンブリッジ'));
    System.assertEquals(false, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ', '㈱サンブリッジ'));
    System.assertEquals(false, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ', '㈱サンブリッジ'));

    System.assertEquals(false, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('株式会社サンブリッジ', '有限会社サンブリッジ'));
    System.assertEquals(false, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ株式会社', 'サンブリッジ有限会社'));

    System.assertEquals(false, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ有限会社', '（有）サンブリッジ'));
    System.assertEquals(false, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ有限会社', '㈲サンブリッジ'));

    System.assertEquals(false, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ株式会社', 'サン　ブリッジ株式会社'));
    System.assertEquals(false, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ株式会社', 'サン ブリッジ株式会社'));
    System.assertEquals(false, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ株式会社', 'サン・ブリッジ株式会社'));

    //特定医療法人
    System.assertEquals(false, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('特定医療法人サンブリッジ', '(医)サンブリッジ')); 
    // 医療法人 
    System.assertEquals(false, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ社会医療法人', 'サンブリッジ医療法人'));    
    System.assertEquals(false, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ社会医療法人', 'サンブリッジ医療法人社団'));    
    System.assertEquals(false, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ社会医療法人', 'サンブリッジ医療法人財団'));    

    // 大:国立大学法人, 公立大学法人
    System.assertEquals(false, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ国立大学法人', 'サンブリッジ公立大学法人'));    
    System.assertEquals(false, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ国立大学法人', 'サンブリッジ （中）'));    
    System.assertEquals(false, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('国立大学法人サンブリッジ', '公立大学法人サンブリッジ'));    
    // 中:有限責任中間法人, 無限責任中間法人
    System.assertEquals(false, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ有限責任中間法人', 'サンブリッジ 無限責任中間法人'));    
    System.assertEquals(false, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ有限責任中間法人', 'サンブリッジ （大）'));    
    System.assertEquals(false, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('有限責任中間法人サンブリッジ', '無限責任中間法人サンブリッジ'));    

  }

  //会社名 アルファベット半角
  @isTest  
  static void test_isEqualeKaishamei_alphabet() {
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('株式会社sss19', '（株) sss19'));    
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('一般財団法人sss19', '（一財) sss19'));    
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('一般社団法人sss19', '（一社) sss19'));    
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('一般社団法人sss19', '（一社)sss19'));    
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('一般社団法人abc19', '（一社) abc19'));    
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('sss19一般財団法人', 'sss19（一財)'));    
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('sss19一般財団法人', 'sss19 （一財)'));    
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('sss19一般財団法人', 'sss19　（一財)'));    
  }

  // uSonar式 略称
  // 　・弁護士法人：（弁法）　
  // 　・税理士法人：（税法）
  // 　・国立大学法人：（国法）
  @isTest  
  static void test_uSonor() {
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('弁護士法人サンブリッジ', '（弁法) サンブリッジ'));    
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ弁護士法人', 'サンブリッジ （弁法)'));    
    System.assertEquals(false, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('弁護士法人サンブリッジ', 'サンブリッジ （弁法)'));    
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('税理士法人サンブリッジ', '（税法) サンブリッジ'));    
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ税理士法人', 'サンブリッジ （税法)'));    
    System.assertEquals(false, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('税理士法人サンブリッジ', 'サンブリッジ （税法)'));    
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('国立大学法人サンブリッジ', '（国法) サンブリッジ'));    
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ国立大学法人', 'サンブリッジ （国法)'));    
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ国立大学法人', 'サンブリッジ （大)'));    
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ（国法)', 'サンブリッジ （大)'));    
    System.assertEquals(false, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('国立大学法人サンブリッジ', 'サンブリッジ （国法)'));        
    // 0011000001LQLB9 医療法人社団緑眞会 （医社）緑眞会
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('医療法人社団緑眞会', '（医社）緑眞会'));            
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('緑眞会医療法人社団', '緑眞会（医社）'));            
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('医療法人社団緑眞会', '（医）緑眞会'));            
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('（医社）緑眞会', '（医）緑眞会'));            
    System.assertEquals(false, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('医療法人社団緑眞会', '緑眞会（医社）'));            
    // 0011000001HnSlP	特定非営利活動法人難民支援協会	（特定）難民支援協会     特定非営利活動法人, 特非, 特定
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('特定非営利活動法人難民支援協会', '（特定）難民支援協会'));            
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('難民支援協会特定非営利活動法人', '難民支援協会（特定）'));  
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('難民支援協会特定非営利活動法人', '難民支援協会（特非）'));  
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('（特非）難民支援協会', '（特定）難民支援協会'));            
    System.assertEquals(false, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('特定非営利活動法人難民支援協会', '難民支援協会（特定）'));            
    // 0011000001PLSmA	日本シノプシス合同会社	日本シノプシス（合同）合同会社, 同, 合同
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('日本シノプシス合同会社', '日本シノプシス（合同）'));            
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('合同会社日本シノプシス', '（合同）日本シノプシス'));            
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('合同会社日本シノプシス', '（合同）日本シノプシス'));            
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('合同会社日本シノプシス', '（同）日本シノプシス'));            
    System.assertEquals(false, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('合同会社日本シノプシス', '日本シノプシス（合同）'));            
    // 0011000001FiSCG	デロイトトーマツコーポレートソリューション合同会社	デロイトトーマツコーポレートソリューション（合同）
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('デロイトトーマツコーポレートソリューション合同会社', 'デロイトトーマツコーポレートソリューション（合同）'));            
    // 有限責任あずさ監査法人	有限責任あずさ（監法） 監, 監法, ㈼
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('有限責任あずさ監査法人', '有限責任あずさ（監法）'));            
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('監査法人有限責任あずさ', '（監法）有限責任あずさ'));            
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('監査法人有限責任あずさ', '（監）有限責任あずさ'));            
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('監査法人有限責任あずさ', '㈼有限責任あずさ'));            
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('（監法）有限責任あずさ', '（監）有限責任あずさ'));            
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('（監法）有限責任あずさ', '㈼有限責任あずさ'));            
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('（監）有限責任あずさ', '㈼有限責任あずさ'));            
    System.assertEquals(false, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('監査法人有限責任あずさ', '有限責任あずさ（監法）'));            
    // 001100000001u1K	ジェフリーズ証券会社	ジェフリーズ・ジャパン・リミテッド（証券会社） ← 対応しない
  }

  @isTest  
  static void test_Dopou() {
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('独立行政法人サンブリッジ', '（独) サンブリッジ'));    
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ独立行政法人', 'サンブリッジ （独)'));    
    System.assertEquals(false, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('独立行政法人サンブリッジ', 'サンブリッジ （独)'));  
    System.assertEquals(false, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('独立行政法人サンブリッジ', '（地独)サンブリッジ'));  

    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('地方独立行政法人サンブリッジ', '（地独) サンブリッジ'));    
    System.assertEquals(true, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ地方独立行政法人', 'サンブリッジ （地独)'));    
    System.assertEquals(false, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('地方独立行政法人サンブリッジ', 'サンブリッジ （地独)'));  
    System.assertEquals(false, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('地方独立行政法人サンブリッジ', '（独)サンブリッジ'));  
    System.assertEquals(false, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('地方独立行政法人サンブリッジ', '独立行政法人サンブリッジ'));  
    System.assertEquals(false, SB_NameCardL_HojinkakuParser.isEqualeKaishamei('サンブリッジ地方独立行政法人', 'サンブリッジ独立行政法人'));  
 }
}