/**
 *
 *  SB_NameCard_RenkeiCheckerTest
 *   自動連携で 名刺レコードを対象OR除外とするか判定するクラス  トリガハンドラで使う。
 *    シングルトンで使う
 *   連携条件オブジェクトから作る。
 *
 *  除外を指定するか、対象をしていするか課題。
 *  条件 AND OR の組み合わせをどのように処理するか課題
 *
 *  Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author mao
 *  @Version 1      2017.02.15
 *  @Version 1.21 mao 2017.10.xx No Assert v1.21 for code scan
 *  @Version 1.22 SV_DEV-676 自動連携：連携対象の名刺の条件 同一の項目を使用した設定を複数登録しようとするとエラーが発生する
 *  @Version 2.0.1     2018.04.XX SV_DEV-883 【自動連携】過去分名刺を除外できる設定が欲しい
 *  @Version 2.4 sawano 2019.07.xx SV_DEV-956 【例外条件】取引先名「？」で納品され、「姓（ラストネーム）」が入力されている場合に自動連携されてしまう。
 *                                  Checker 見直し。責務を分配、局所化。でこっちも修正
 *
 **/

@isTest
private class SB_NameCard_RenkeiCheckerTest {

  public  static NameCardBasicSetting__c setOperatordata(){

    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    setting.Name = 'BasicSetting';
    insert setting;

    List<NameCardRenkeiJyoken__c> jyuos = new List<NameCardRenkeiJyoken__c>();


    NameCardRenkeiJyoken__c jyouken1 = new NameCardRenkeiJyoken__c();
    jyouken1.NameCardName__c = 'Name';
    jyouken1.Operator__c = 'Matches_next_character_string';
    jyouken1.NameCardDataType__c = 'STRING';
    jyouken1.Value__c = 'test';
    jyuos.add(jyouken1);

    NameCardRenkeiJyoken__c jyouken2 = new NameCardRenkeiJyoken__c();
    jyouken2.NameCardName__c = 'Name';
    jyouken2.Operator__c = 'Does_not_match_next_character_string';
    jyouken2.NameCardDataType__c = 'DATE';
    jyouken2.Value__c = '2017-02-21';
    jyuos.add(jyouken2);

    NameCardRenkeiJyoken__c jyouken3 = new NameCardRenkeiJyoken__c();
    jyouken3.NameCardName__c = 'Name';
    jyouken3.Operator__c = 'Start_with_the_following_string';
    jyouken3.Value__c = '2017-02-21';
    jyouken3.NameCardDataType__c = 'DATETIME';
    jyuos.add(jyouken3);

    NameCardRenkeiJyoken__c jyouken4 = new NameCardRenkeiJyoken__c();
    jyouken4.NameCardName__c = 'Name';
    jyouken4.Operator__c = 'Contains_the_following_character_string';
    jyouken4.Value__c = 'test';
    jyouken4.NameCardDataType__c = 'STRING';
    jyuos.add(jyouken4);

    NameCardRenkeiJyoken__c jyouken5 = new NameCardRenkeiJyoken__c();
    jyouken5.NameCardName__c = 'Name';
    jyouken5.Operator__c = 'Matches_the_following_regular_expression';
    jyouken5.Value__c = 'test';
    jyouken5.NameCardDataType__c = 'STRING';
    jyuos.add(jyouken5);

    NameCardRenkeiJyoken__c jyouken6 = new NameCardRenkeiJyoken__c();
    jyouken6.NameCardName__c = 'Name';
    jyouken6.Operator__c = '＜';
    jyouken6.Value__c = 'test';
    jyouken6.NameCardDataType__c = 'STRING';
    jyuos.add(jyouken6);

    NameCardRenkeiJyoken__c jyouken7 = new NameCardRenkeiJyoken__c();
    jyouken7.NameCardName__c = 'Name';
    jyouken7.Operator__c = '＞';
    jyouken7.Value__c = 'test';
    jyouken7.NameCardDataType__c = 'STRING';
    jyuos.add(jyouken7);

    NameCardRenkeiJyoken__c jyouken8 = new NameCardRenkeiJyoken__c();
    jyouken8.NameCardName__c = 'Name';
    jyouken8.Operator__c = '＜＝';
    jyouken8.Value__c = 'test';
    jyouken8.NameCardDataType__c = 'STRING';
    jyuos.add(jyouken8);

    NameCardRenkeiJyoken__c jyouken9 = new NameCardRenkeiJyoken__c();
    jyouken9.NameCardName__c = 'Name';
    jyouken9.Operator__c = '＞＝';
    jyouken9.Value__c = 'test';
    jyouken9.NameCardDataType__c = 'STRING';
    jyuos.add(jyouken9);

    NameCardRenkeiJyoken__c jyouken10 = new NameCardRenkeiJyoken__c();
    jyouken10.NameCardName__c = 'Name';
    jyouken10.Operator__c = 'Not_contain_the_following_character_string';
    jyouken10.Value__c = 'test';
    jyouken10.NameCardDataType__c = 'STRING';
    jyuos.add(jyouken10);

    insert jyuos;
    return setting;
  }

  //文字列をチェック
  public static void checkstring(String Operator,String OperatorValue,String Value1,String Value2,Boolean ncc1,Boolean ncc2) {
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    setting.Name = 'BasicSetting';
    insert setting;
    NameCardRenkeiJyoken__c jyouken = new NameCardRenkeiJyoken__c();
    jyouken.NameCardName__c = 'Name';
    jyouken.Operator__c = Operator;
    jyouken.Value__c = OperatorValue;
    jyouken.NameCardDataType__c = 'STRING';
    insert jyouken;
    SB_NameCard_RenkeiChecker ce =SB_NameCard_RenkeiChecker.getInstance();

    NameCard__c n1 = new NameCard__c(person_name_last__c='苗字', company_name__c='会社名');
    n1.Name = Value1;
    insert n1;

    NameCard__c n2 = new NameCard__c(person_name_last__c='苗字', company_name__c='会社名');
    n2.Name = Value2;
    insert n2;
    System.assertEquals(ce.isIgnore(n1),ncc1);
    System.assertEquals(ce.isIgnore(n2),ncc2);
  }

  //連携條件がない
  @isTest static void test_Operator0() {
    SB_NameCard_RenkeiChecker ce = SB_NameCard_RenkeiChecker.getInstance();
    System.assertNotEquals(ce, null);  //  kou  2017.10.xx  Test Methods With No Assert  v1.21 for code scan
  }

  //連携條件がある
  @isTest static void test_Operato1() {
    setOperatordata();
    SB_NameCard_RenkeiChecker ce =SB_NameCard_RenkeiChecker.getInstance();
    System.assertNotEquals(ce, null);  //  kou  2017.10.xx  Test Methods With No Assert  v1.21 for code scan
  }
//if(op == 'Matches_next_character_string'){
//       return 0;
//     }
//     //次の文字列と一致しない
//     else if(op == 'Does_not_match_next_character_string'){
//       return 1;
//     }
//     //次の文字列で始まる
//     else if(op == 'Start_with_the_following_string'){
//       return 2;
//     }
//     //次の文字列を含む
//     else if(op == 'Contains_the_following_character_string'){
//       return 3;
//     }
//     //次の文字列を含まない
//     else if(op == 'Not_contain_the_following_character_string'){
//       return 4;
//     }
//     //次の正規表現に合致する

//     else if(op == 'Matches_the_following_regular_expression'){
//       return 5;
//     }
//     else if(op == '＜'){
//       return 6;
//     }
//     else if(op == '＞'){
//       return 7;
//     }
//     else if(op == '＜＝'){
//       return 8;
//     }
//     else {//＞＝
//       return 9;
//     }
   //文字列をチェック
  @isTest static void test_CardCheck0() {
    checkstring('Matches_next_character_string','test','test','test1',false,true);
  }

  @isTest static void test_CardCheck1() {
    checkstring('Does_not_match_next_character_string','test','test','test1',true,false);
  }

  @isTest static void test_CardCheck2() {
    checkstring('Start_with_the_following_string','test','test123','123test',false,true);
  }

  @isTest static void test_CardCheck2blank() {
    checkstring('Start_with_the_following_string','','','test1',false,true);
  }

  @isTest static void test_CardCheck3() {
    checkstring('Contains_the_following_character_string','test','111test111','1t1e1s1t1',false,true);
  }

  @isTest static void test_CardCheck4() {
    checkstring('Not_contain_the_following_character_string','test','111test111','1t1e1s1t1',true,false);
  }

  @isTest static void test_CardCheck5() {
    checkstring('Matches_the_following_regular_expression','^(ABC|XYZ)$','ABC','test1',false,true);
  }
  //次の正規表現に合致する
  //指定文字列含まない  学校法人|社団法人|特殊法人|財団法人|監査法人|企業組合|協同組合|労働組合|医療法人社団|医療法人財団|社会医療法人|特定医療法人|医療法人|一般社団法人|一般財団法人|公益社団法人|公益財団法人|宗教法人|社会福祉法人|更生保護法人|独立行政法人|地方独立行政法人
  @isTest static void test_CardCheck51() {
    checkstring('Matches_the_following_regular_expression','^(?!.*(学校法人|社団法人|特殊法人|財団法人|監査法人|企業組合|協同組合|労働組合|医療法人社団|医療法人財団|社会医療法人|特定医療法人|医療法人|一般社団法人|一般財団法人|公益社団法人|公益財団法人|宗教法人|社会福祉法人|更生保護法人|独立行政法人|地方独立行政法人))(.*)$','test1','Test独立行政法人Test',false,true);
  }

  //次の正規表現に合致する
  //指定文字列先頭と末尾に含まない  学校法人|社団法人|特殊法人|財団法人|監査法人|企業組合|協同組合|労働組合|医療法人社団|医療法人財団|社会医療法人|特定医療法人|医療法人|一般社団法人|一般財団法人|公益社団法人|公益財団法人|宗教法人|社会福祉法人
  @isTest static void test_CardCheck52() {
    checkstring('Matches_the_following_regular_expression','^(?!(学校法人|社団法人|特殊法人|財団法人|監査法人|企業組合|協同組合|労働組合|医療法人社団|医療法人財団|社会医療法人|特定医療法人|医療法人|一般社団法人|一般財団法人|公益社団法人|公益財団法人|宗教法人|社会福祉法人))(.*)(?<!(学校法人|社団法人|特殊法人|財団法人|監査法人|企業組合|協同組合|労働組合|医療法人社団|医療法人財団|社会医療法人|特定医療法人|医療法人|一般社団法人|一般財団法人|公益社団法人|公益財団法人|宗教法人|社会福祉法人))$','test1','学校法人Test',false,true);
  }

  //指定文字列先頭と末尾に含まない  学校法人|社団法人|特殊法人|財団法人|監査法人|企業組合|協同組合|労働組合|医療法人社団|医療法人財団|社会医療法人|特定医療法人|医療法人|一般社団法人|一般財団法人|公益社団法人|公益財団法人|宗教法人|社会福祉法人
  @isTest static void test_CardCheck521() {
    checkstring('Matches_the_following_regular_expression','^(?!(学校法人|社団法人|特殊法人|財団法人|監査法人|企業組合|協同組合|労働組合|医療法人社団|医療法人財団|社会医療法人|特定医療法人|医療法人|一般社団法人|一般財団法人|公益社団法人|公益財団法人|宗教法人|社会福祉法人))(.*)(?<!(学校法人|社団法人|特殊法人|財団法人|監査法人|企業組合|協同組合|労働組合|医療法人社団|医療法人財団|社会医療法人|特定医療法人|医療法人|一般社団法人|一般財団法人|公益社団法人|公益財団法人|宗教法人|社会福祉法人))$','test1','Test学校法人',false,true);
  }

  //指定文字列先頭に含む  学校法人|社団法人|特殊法人|財団法人|監査法人|企業組合|協同組合|労働組合|医療法人社団|医療法人財団|社会医療法人|特定医療法人|医療法人|一般社団法人|一般財団法人|公益社団法人|公益財団法人|宗教法人|社会福祉法人|更生保護法人|独立行政法人|地方独立行政法人
  @isTest static void test_CardCheck53() {
    checkstring('Matches_the_following_regular_expression','^(学校法人|社団法人|特殊法人|財団法人|監査法人|企業組合|協同組合|労働組合|医療法人社団|医療法人財団|社会医療法人|特定医療法人|医療法人|一般社団法人|一般財団法人|公益社団法人|公益財団法人|宗教法人|社会福祉法人|更生保護法人|独立行政法人|地方独立行政法人)(.*)$','test1','学校法人Test',true,false);
  }

  //指定文字列先頭に含む  学校法人|社団法人|特殊法人|財団法人|監査法人|企業組合|協同組合|労働組合|医療法人社団|医療法人財団|社会医療法人|特定医療法人|医療法人|一般社団法人|一般財団法人|公益社団法人|公益財団法人|宗教法人|社会福祉法人|更生保護法人|独立行政法人|地方独立行政法人
  @isTest static void test_CardCheck531() {
    checkstring('Matches_the_following_regular_expression','^(学校法人|社団法人|特殊法人|財団法人|監査法人|企業組合|協同組合|労働組合|医療法人社団|医療法人財団|社会医療法人|特定医療法人|医療法人|一般社団法人|一般財団法人|公益社団法人|公益財団法人|宗教法人|社会福祉法人|更生保護法人|独立行政法人|地方独立行政法人)(.*)$','test1','Test学校法人',true,true);
  }

  //指定文字列末尾に含む  学校法人|社団法人|特殊法人|財団法人|監査法人|企業組合|協同組合|労働組合|医療法人社団|医療法人財団|社会医療法人|特定医療法人|医療法人|一般社団法人|一般財団法人|公益社団法人|公益財団法人|宗教法人|社会福祉法人|更生保護法人|独立行政法人|地方独立行政法人|更生保護法人|独立行政法人|地方独立行政法人
  @isTest static void test_CardCheck54() {
    checkstring('Matches_the_following_regular_expression','^.*(学校法人|社団法人|特殊法人|財団法人|監査法人|企業組合|協同組合|労働組合|医療法人社団|医療法人財団|社会医療法人|特定医療法人|医療法人|一般社団法人|一般財団法人|公益社団法人|公益財団法人|宗教法人|社会福祉法人|更生保護法人|独立行政法人|地方独立行政法人)$','test1','Test学校法人',true,false);
  }

  //指定文字列末尾に含む  学校法人|社団法人|特殊法人|財団法人|監査法人|企業組合|協同組合|労働組合|医療法人社団|医療法人財団|社会医療法人|特定医療法人|医療法人|一般社団法人|一般財団法人|公益社団法人|公益財団法人|宗教法人|社会福祉法人|更生保護法人|独立行政法人|地方独立行政法人|更生保護法人|独立行政法人|地方独立行政法人
  @isTest static void test_CardCheck541() {
    checkstring('Matches_the_following_regular_expression','^.*(学校法人|社団法人|特殊法人|財団法人|監査法人|企業組合|協同組合|労働組合|医療法人社団|医療法人財団|社会医療法人|特定医療法人|医療法人|一般社団法人|一般財団法人|公益社団法人|公益財団法人|宗教法人|社会福祉法人|更生保護法人|独立行政法人|地方独立行政法人)$','test1','学校法人Test',true,true);
  }

  //正規表現空白テスト
  @isTest static void test_CardCheck55() {
    checkstring('Matches_the_following_regular_expression','','test1','',false,false);
  }

   //正規表現nullテスト
  @isTest static void test_CardCheck551() {
    checkstring('Matches_the_following_regular_expression', null, 'test1', null,false,false);
  }

  //255超えでます
  // ^(?!(学校法人|社団法人|特殊法人|財団法人|監査法人|企業組合|協同組合|労働組合|医療法人社団|医療法人財団|社会医療法人|特定医療法人|医療法人|一般社団法人|一般財団法人|公益社団法人|公益財団法人|宗教法人|社会福祉法人|更生保護法人|独立行政法人|地方独立行政法人))(.*)(?<!(学校法人|社団法人|特殊法人|財団法人|監査法人|企業組合|協同組合|労働組合|医療法人社団|医療法人財団|社会医療法人|特定医療法人|医療法人|一般社団法人|一般財団法人|公益社団法人|公益財団法人|宗教法人|社会福祉法人|更生保護法人|独立行政法人|地方独立行政法人))$

  @isTest static void test_CardCheck6() {
    checkstring('＜','c','b','d',false,true);
  }

  @isTest static void test_CardCheck7() {
    checkstring('＞','c','b','d',true,false);
  }

  @isTest static void test_CardCheck8() {
    checkstring('＜＝','c','c','d',false,true);
  }

  @isTest static void test_CardCheck9() {
    checkstring('＞＝','c','c','b',false,true);
  }


  //日付をチェック
  public static void checkDate(String Operator,String OperatorValue,String Value1,String Value2,Boolean ncc1,Boolean ncc2) {
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    setting.Name = 'BasicSetting';
    insert setting;
    NameCardRenkeiJyoken__c jyouken = new NameCardRenkeiJyoken__c();
    jyouken.NameCardName__c = SB_NameCard_RenkeiMapperUtil.getManagedfileName('NameCard__c','card_exchange_date__c');
    jyouken.Operator__c = Operator;
    jyouken.Value__c = OperatorValue;
    jyouken.NameCardDataType__c = 'DATE';
    insert jyouken;
    SB_NameCard_RenkeiChecker ce =SB_NameCard_RenkeiChecker.getInstance();

    NameCard__c n1 = new NameCard__c(person_name_last__c='苗字', company_name__c='会社名');
    n1.Name = 'test';
    n1.card_exchange_date__c = Date.valueOf(Value1);
    insert n1;

    NameCard__c n2 = new NameCard__c(person_name_last__c='苗字', company_name__c='会社名');
    n2.Name = 'test1';
    n2.card_exchange_date__c = Date.valueOf(Value2);
    insert n2;
    System.assertEquals(ce.isIgnore(n1),ncc1);
    System.assertEquals(ce.isIgnore(n2),ncc2);
  }

  //時間をチェック
  public static void checkDateTime(String Operator,String OperatorValue,String Value1,String Value2,Boolean ncc1,Boolean ncc2) {
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    setting.Name = 'BasicSetting';
    insert setting;

    NameCardRenkeiJyoken__c jyouken2 = new NameCardRenkeiJyoken__c();
    jyouken2.NameCardName__c = SB_NameCard_RenkeiMapperUtil.getManagedfileName('NameCard__c','accountRegDateTime__c');
    jyouken2.Operator__c = Operator;
    jyouken2.Value__c = OperatorValue;
    jyouken2.NameCardDataType__c = 'DATETIME';
    insert jyouken2;
    SB_NameCard_RenkeiChecker ce2 =SB_NameCard_RenkeiChecker.getInstance();

    NameCard__c n3 = new NameCard__c(person_name_last__c='苗字', company_name__c='会社名');
    n3.Name = 'test';
    Date dday = Date.valueOf(Value1);
    n3.accountRegDateTime__c =  datetime.newInstance(dday.year(), dday.month(),dday.day());
    insert n3;

    NameCard__c n4 = new NameCard__c(person_name_last__c='苗字', company_name__c='会社名');
    n4.Name = 'test1';
    Date dday2 = Date.valueOf(Value2);
    n4.accountRegDateTime__c =  datetime.newInstance(dday2.year(), dday2.month(),dday2.day());
    insert n4;
    System.assertEquals(ce2.isIgnore(n3),ncc1);
    System.assertEquals(ce2.isIgnore(n4),ncc2);
  }


   //if(op == 'Matches_next_character_string'){
//       return 0;
//     }
//     //次の文字列と一致しない
//     else if(op == 'Does_not_match_next_character_string'){
//       return 1;
//     }
//     else if(op == '＜'){
//       return 6;
//     }
//     else if(op == '＞'){
//       return 7;
//     }
//     else if(op == '＜＝'){
//       return 8;
//     }
//     else {//＞＝
//       return 9;
//     }
 //日付をチェック
  @isTest static void test_CardCheckDate0() {
    checkDate('Matches_next_character_string','2017-02-01','2017-02-01','2017-02-02',false,true);
  }
  @isTest static void test_CardCheckDate1() {
    checkDate('Does_not_match_next_character_string','2017-02-01','2017-02-02','2017-02-01',false,true);
  }
  @isTest static void test_CardCheckDate6() {
    checkDate('＜','2017-02-02','2017-02-01','2017-02-02',false,true);
  }
  @isTest static void test_CardCheckDate7() {
    checkDate('＞','2017-02-02','2017-02-03','2017-02-02',false,true);
  }
  @isTest static void test_CardCheckDate8() {
    checkDate('＜＝','2017-02-02','2017-02-01','2017-02-03',false,true);
  }
  @isTest static void test_CardCheckDate9() {
    checkDate('＞＝','2017-02-02','2017-02-03','2017-02-01',false,true);
  }

  //時間をチェック
  @isTest static void test_CardCheckDateTime0() {
    checkDateTime('Matches_next_character_string','2017-02-01','2017-02-01','2017-02-02',false,true);
  }
  @isTest static void test_CardCheckDateTime1() {
    checkDateTime('Does_not_match_next_character_string','2017-02-01','2017-02-02','2017-02-01',false,true);
  }
  @isTest static void test_CardCheckDateTime6() {
    checkDateTime('＜','2017-02-02','2017-02-01','2017-02-02',false,true);
  }
  @isTest static void test_CardCheckDateTime7() {
    checkDateTime('＞','2017-02-02','2017-02-03','2017-02-02',false,true);
  }
  @isTest static void test_CardCheckDateTime8() {
    checkDateTime('＜＝','2017-02-02','2017-02-01','2017-02-03',false,true);
  }
  @isTest static void test_CardCheckDateTime9() {
    checkDateTime('＞＝','2017-02-02','2017-02-03','2017-02-01',false,true);
  }


  //時間をチェック
  public static void checkDouble(String Operator,String OperatorValue,Double Value1,Double Value2,Boolean ncc1,Boolean ncc2) {
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    setting.Name = 'BasicSetting';
    insert setting;

    NameCardRenkeiJyoken__c jyouken2 = new NameCardRenkeiJyoken__c();
    jyouken2.NameCardName__c = SB_NameCard_RenkeiMapperUtil.getManagedfileName('NameCard__c','longitude__c');
    jyouken2.Operator__c = Operator;
    jyouken2.Value__c = OperatorValue;
    jyouken2.NameCardDataType__c = 'DOUBLE';
    insert jyouken2;
    SB_NameCard_RenkeiChecker ce2 =SB_NameCard_RenkeiChecker.getInstance();

    NameCard__c n3 = new NameCard__c(person_name_last__c='苗字', company_name__c='会社名');
    n3.Name = 'test';
    n3.longitude__c = Value1;
    insert n3;

    NameCard__c n4 = new NameCard__c(person_name_last__c='苗字', company_name__c='会社名');
    n4.Name = 'test1';
    n4.longitude__c = Value2;
    insert n4;
    System.assertEquals(ce2.isIgnore(n3),ncc1);
    System.assertEquals(ce2.isIgnore(n4),ncc2);
  }

  //数値をチェック
  @isTest static void test_CardCheckDouble0() {
    checkDouble('Matches_next_character_string', '7', 13, 88, true, true);
  }
  @isTest static void test_CardCheckDouble1() {
    checkDouble('Does_not_match_next_character_string', '7', 13, 88, false, false);
  }
  @isTest static void test_CardCheckDouble2() {
    checkDouble('＜','7', 13, 6, true, false);
  }
  @isTest static void test_CardCheckDouble3() {
    checkDouble('＞','7', 13, 6,false, true);
  }
  @isTest static void test_CardCheckDouble4() {
    checkDouble('＜＝','7', 13, 6,true, false);
  }
  @isTest static void test_CardCheckDouble5() {
    checkDouble('＞＝','7', 13, 6, false, true);
  }
  @isTest static void test_CardCheckDouble6() {
    checkDouble('Matches_next_character_string','13', 31, 13, true, false);
  }
  @isTest static void test_CardCheckDouble7() {
    checkDouble('Does_not_match_next_character_string','13', 31, 13, false, true);
  }
  @isTest static void test_CardCheckDouble8() {
    checkDouble('＜','13', 99, 8, true, false);
  }
  @isTest static void test_CardCheckDouble9() {
    checkDouble('＞','13', 7, 31, true, false);
  }
  @isTest static void test_CardCheckDouble10() {
    checkDouble('＜＝','13', 3, 31, false, true);
  }
  @isTest static void test_CardCheckDouble11() {
    checkDouble('＞＝','13', 31, 3, false, true);
  }

  // 条件 null
  @isTest static void test_CardCheckDouble12() {
    checkDouble('Matches_next_character_string', null, null, 13, false, true);
  }
  @isTest static void test_CardCheckDouble13() {
    checkDouble('Does_not_match_next_character_string', null, null, 13, true, false);
  }
  @isTest static void test_CardCheckDouble14() {
    checkDouble('＜', null, null, 8, false, false);
  }
  @isTest static void test_CardCheckDouble15() {
    checkDouble('＞', null, null, 31, false, false);
  }
  @isTest static void test_CardCheckDouble16() {
    checkDouble('＜＝', null, null, 31, false, false);
  }
  @isTest static void test_CardCheckDouble17() {
    checkDouble('＞＝', null, null, 3, false, false);
  }


  // 値がnull
  @isTest static void test_CardCheckDouble18() {
    checkDouble('Matches_next_character_string','13', null, 13, true, false);
  }
  @isTest static void test_CardCheckDouble19() {
    checkDouble('Does_not_match_next_character_string','13', null, 13, false, true);
  }
  @isTest static void test_CardCheckDouble20() {
    checkDouble('＜','13', null, 8, true, false);
  }
  @isTest static void test_CardCheckDouble21() {
    checkDouble('＞','13', null, 31, true, false);
  }
  @isTest static void test_CardCheckDouble22() {
    checkDouble('＜＝','13', null, 31, true, true);
  }
  @isTest static void test_CardCheckDouble23() {
    checkDouble('＞＝','13', null, 3, true, true);
  }









  //他のケースをチェック
  @isTest static void test_CardCheckElse() {
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    insert setting;
    NameCardRenkeiJyoken__c jyouken = new NameCardRenkeiJyoken__c();
    jyouken.NameCardName__c = 'account__r.Name';
    jyouken.Operator__c = 'Matches_next_character_string';
    jyouken.Value__c = 'test';
    jyouken.NameCardDataType__c = 'STRING';
    insert jyouken;
    SB_NameCard_RenkeiChecker ce =SB_NameCard_RenkeiChecker.getInstance();

    Account a1 = new Account();
    a1.Name = 'test';
    insert a1;

    Account a2 = new Account();
    a2.Name = 'tes1';
    insert a2;

    NameCard__c n1 = new NameCard__c(person_name_last__c='苗字', company_name__c='会社名');
    n1.Name = 'test';
    n1.account__c = a1.Id;
    insert n1;

    NameCard__c n2 = new NameCard__c(person_name_last__c='苗字', company_name__c='会社名');
    n2.Name = 'xxx';
    n2.account__c = a2.Id;
    insert n2;
    NameCard__c nn1 = [Select Id,Name,account__r.Name, person_name_last__c, last_name__c, company_name__c From NameCard__c Where Id=:n1.Id];
    NameCard__c nn2 = [Select Id,Name,account__r.Name, person_name_last__c, last_name__c, company_name__c From NameCard__c Where Id=:n2.Id];
    System.assertEquals(ce.isIgnore(nn1),false);
    System.assertEquals(ce.isIgnore(nn2),false);
  }

  @isTest static void test_CardCheckElsenull() {
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    setting.Name = 'BasicSetting';
    insert setting;
    NameCardRenkeiJyoken__c jyouken = new NameCardRenkeiJyoken__c();
    jyouken.NameCardName__c = 'account__r.aa';
    jyouken.Operator__c = 'Matches_next_character_string';
    jyouken.Value__c = 'test';
    jyouken.NameCardDataType__c = 'STRING';
    insert jyouken;
    SB_NameCard_RenkeiChecker ce =SB_NameCard_RenkeiChecker.getInstance();

    Account a1 = new Account();
    a1.Name = 'test';
    insert a1;

    NameCard__c n1 = new NameCard__c(person_name_last__c='苗字', company_name__c='会社名');
    n1.Name = 'test';
    n1.account__c = a1.Id;
    insert n1;

    System.assertEquals(ce.isIgnore(n1),false);
  }

  // String Operator,String OperatorValue,String Value1,String Value2,Boolean ncc1,Boolean ncc2

  //Name 次の文字列を含む Test
  //company_name__c 次の正規表現に合致する  ^(?!.*(学校法人|社団法人|特殊法人|財団法人|監査法人|企業組合|協同組合|労働組合|医療法人社団|医療法人財団|社会医療法人|特定医療法人|医療法人|一般社団法人|一般財団法人|公益社団法人|公益財団法人|宗教法人|社会福祉法人|更生保護法人|独立行政法人|地方独立行政法人))(.*)$
  //->     次の文字列含まない  学校法人|社団法人|特殊法人|財団法人|監査法人|企業組合|協同組合|労働組合|医療法人社団|医療法人財団|社会医療法人|特定医療法人|医療法人|一般社団法人|一般財団法人|公益社団法人|公益財団法人|宗教法人|社会福祉法人|更生保護法人|独立行政法人|地方独立行政法人
  @isTest static void test_String_Matches_the_following_regular_expression_string() {
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    setting.Name = 'BasicSetting';
    insert setting;

    List<NameCardRenkeiJyoken__c> jos = new List<NameCardRenkeiJyoken__c>();
    NameCardRenkeiJyoken__c jyouken = new NameCardRenkeiJyoken__c();
    jyouken.NameCardName__c = 'Name';
    jyouken.Operator__c = 'Contains_the_following_character_string';
    jyouken.Value__c = 'Test';
    jyouken.NameCardDataType__c = 'STRING';
    jos.add(jyouken);

    NameCardRenkeiJyoken__c jyouken1 = new NameCardRenkeiJyoken__c();
    jyouken1.NameCardName__c = SB_NameCard_Util.getNamespacePrefix_x() + 'company_name__c';
    jyouken1.Operator__c = 'Matches_the_following_regular_expression';
    //指定文字列含まない
    jyouken1.Value__c = '^(?!.*(学校法人|社団法人|特殊法人|財団法人|監査法人|企業組合|協同組合|労働組合|医療法人社団|医療法人財団|社会医療法人|特定医療法人|医療法人|一般社団法人|一般財団法人|公益社団法人|公益財団法人|宗教法人|社会福祉法人|更生保護法人|独立行政法人|地方独立行政法人))(.*)$';
    jyouken1.NameCardDataType__c = 'STRING';
    jos.add(jyouken1);

    insert jos;
    SB_NameCard_RenkeiChecker ce =SB_NameCard_RenkeiChecker.getInstance();
    List<NameCard__c> ns = new List<NameCard__c>();
    NameCard__c n1 = new NameCard__c(person_name_last__c='苗字');
    n1.Name = 'AATestBB';
    n1.company_name__c = 'Testcompany';
    ns.add(n1);

    NameCard__c n2 = new NameCard__c(person_name_last__c='苗字');
    n2.Name = 'AATestBB';
    n2.company_name__c = 'Test社団法人company';
    ns.add(n2);

    NameCard__c n3 = new NameCard__c(person_name_last__c='苗字');
    n3.Name = 'AABB';
    n3.company_name__c = 'Testcompany1';
    ns.add(n3);
    insert ns;

    //含まれてますので排除します
    System.assertEquals(ce.isIgnore(n1),false);
    System.assertEquals(ce.isIgnore(n2),true);
    System.assertEquals(ce.isIgnore(n3),true);
  }


  //person_name_last__c 次の文字列で始まる Test
  //person_name_first__c 次の文字列を含まない Test
  //company_name__c 次の正規表現に合致する  ^(?!.*(学校法人|社団法人|特殊法人|財団法人|監査法人|企業組合|協同組合|労働組合|医療法人社団|医療法人財団|社会医療法人|特定医療法人|医療法人|一般社団法人|一般財団法人|公益社団法人|公益財団法人|宗教法人|社会福祉法人|更生保護法人|独立行政法人|地方独立行政法人))(.*)$
  //->     次の文字列含まない  学校法人|社団法人|特殊法人|財団法人|監査法人|企業組合|協同組合|労働組合|医療法人社団|医療法人財団|社会医療法人|特定医療法人|医療法人|一般社団法人|一般財団法人|公益社団法人|公益財団法人|宗教法人|社会福祉法人|更生保護法人|独立行政法人|地方独立行政法人
  @isTest static void test_String_Matches_the_following_regular_expression_string2() {
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    setting.Name = 'BasicSetting';
    insert setting;

    List<NameCardRenkeiJyoken__c> jos = new List<NameCardRenkeiJyoken__c>();
    NameCardRenkeiJyoken__c jyouken = new NameCardRenkeiJyoken__c();
    jyouken.NameCardName__c = SB_NameCard_Util.getNamespacePrefix_x() + 'person_name_last__c';
    //含む
    jyouken.Operator__c = 'Start_with_the_following_string';
    jyouken.Value__c = 'Test';
    jyouken.NameCardDataType__c = 'STRING';
    jos.add(jyouken);

    NameCardRenkeiJyoken__c jyouken0 = new NameCardRenkeiJyoken__c();
    jyouken0.NameCardName__c = SB_NameCard_Util.getNamespacePrefix_x() + 'person_name_first__c';
    //含まない
    jyouken0.Operator__c = 'Not_contain_the_following_character_string';
    jyouken0.Value__c = 'Test';
    jyouken0.NameCardDataType__c = 'STRING';
    jos.add(jyouken0);

    NameCardRenkeiJyoken__c jyouken1 = new NameCardRenkeiJyoken__c();
    jyouken1.NameCardName__c = SB_NameCard_Util.getNamespacePrefix_x() + 'company_name__c';
    jyouken1.Operator__c = 'Matches_the_following_regular_expression';
    //指定文字列含まない
    jyouken1.Value__c = '^(?!.*(学校法人|社団法人|特殊法人|財団法人|監査法人|企業組合|協同組合|労働組合|医療法人社団|医療法人財団|社会医療法人|特定医療法人|医療法人|一般社団法人|一般財団法人|公益社団法人|公益財団法人|宗教法人|社会福祉法人|更生保護法人|独立行政法人|地方独立行政法人))(.*)$';
    jyouken1.NameCardDataType__c = 'STRING';
    jos.add(jyouken1);

    insert jos;
    SB_NameCard_RenkeiChecker ce =SB_NameCard_RenkeiChecker.getInstance();
    List<NameCard__c> ns = new List<NameCard__c>();
    NameCard__c n1 = new NameCard__c();
    n1.Name = 'Test';
    n1.company_name__c = 'Test社団A法人company';
    n1.person_name_last__c = 'TestLastLL';
    n1.person_name_first__c = 'First';
    ns.add(n1);

    NameCard__c n2 = new NameCard__c();
    n2.Name = 'Test';
    n2.company_name__c = 'Test社団法人company';
    n2.person_name_last__c = 'TestLastLL';
    n2.person_name_first__c = 'First';
    ns.add(n2);

    NameCard__c n3 = new NameCard__c();
    n3.Name = 'Test';
    n3.company_name__c = 'Testcompany1';
    n3.person_name_last__c = 'LastLL';
    n3.person_name_first__c = 'First';
    ns.add(n3);

    NameCard__c n4 = new NameCard__c();
    n3.Name = 'Test';
    n3.company_name__c = 'Testcompany1';
    n4.person_name_last__c = 'TestLastLL';
    n4.person_name_first__c = 'Test';
    ns.add(n4);

    insert ns;

    //含まれてますので排除します
    System.assertEquals(ce.isIgnore(n1),false);
    System.assertEquals(ce.isIgnore(n2),true);
    System.assertEquals(ce.isIgnore(n3),true);
    System.assertEquals(ce.isIgnore(n4),true);
  }

  //person_name_last__c 次の文字列で始まる Test
  //person_name_first__c 次の文字列を含まない Test
  //company_name__c 次の正規表現に合致する  ^(?!(学校法人|社団法人|特殊法人|財団法人|監査法人|企業組合|協同組合|労働組合|医療法人社団|医療法人財団|社会医療法人|特定医療法人|医療法人|一般社団法人|一般財団法人|公益社団法人|公益財団法人|宗教法人|社会福祉法人))(.*)(?<!(学校法人|社団法人|特殊法人|財団法人|監査法人|企業組合|協同組合|労働組合|医療法人社団|医療法人財団|社会医療法人|特定医療法人|医療法人|一般社団法人|一般財団法人|公益社団法人|公益財団法人|宗教法人|社会福祉法人))$
  //->     指定文字列先頭と末尾に含まない  学校法人|社団法人|特殊法人|財団法人|監査法人|企業組合|協同組合|労働組合|医療法人社団|医療法人財団|社会医療法人|特定医療法人|医療法人|一般社団法人|一般財団法人|公益社団法人|公益財団法人|宗教法人|社会福祉法人
  @isTest static void test_String_Matches_the_following_regular_expression_string3() {
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    setting.Name = 'BasicSetting';
    insert setting;

    List<NameCardRenkeiJyoken__c> jos = new List<NameCardRenkeiJyoken__c>();
    NameCardRenkeiJyoken__c jyouken = new NameCardRenkeiJyoken__c();
    jyouken.NameCardName__c = SB_NameCard_Util.getNamespacePrefix_x() + 'person_name_last__c';
    //含む
    jyouken.Operator__c = 'Start_with_the_following_string';
    jyouken.Value__c = 'Test';
    jyouken.NameCardDataType__c = 'STRING';
    jos.add(jyouken);

    NameCardRenkeiJyoken__c jyouken0 = new NameCardRenkeiJyoken__c();
    jyouken0.NameCardName__c = SB_NameCard_Util.getNamespacePrefix_x() + 'person_name_first__c';
    //含まない
    jyouken0.Operator__c = 'Not_contain_the_following_character_string';
    jyouken0.Value__c = 'Test';
    jyouken0.NameCardDataType__c = 'STRING';
    jos.add(jyouken0);

    NameCardRenkeiJyoken__c jyouken1 = new NameCardRenkeiJyoken__c();
    jyouken1.NameCardName__c = SB_NameCard_Util.getNamespacePrefix_x() + 'company_name__c';
    jyouken1.Operator__c = 'Matches_the_following_regular_expression';
    //指定文字列含まない
    jyouken1.Value__c = '^(?!(学校法人|社団法人|特殊法人|財団法人|監査法人|企業組合|協同組合|労働組合|医療法人社団|医療法人財団|社会医療法人|特定医療法人|医療法人|一般社団法人|一般財団法人|公益社団法人|公益財団法人|宗教法人|社会福祉法人))(.*)(?<!(学校法人|社団法人|特殊法人|財団法人|監査法人|企業組合|協同組合|労働組合|医療法人社団|医療法人財団|社会医療法人|特定医療法人|医療法人|一般社団法人|一般財団法人|公益社団法人|公益財団法人|宗教法人|社会福祉法人))$';
    jyouken1.NameCardDataType__c = 'STRING';
    jos.add(jyouken1);

    insert jos;
    SB_NameCard_RenkeiChecker ce =SB_NameCard_RenkeiChecker.getInstance();
    List<NameCard__c> ns = new List<NameCard__c>();
    NameCard__c n1 = new NameCard__c();
    n1.Name = 'Test';
    n1.company_name__c = '社団A法人company';
    n1.person_name_last__c = 'TestLastLL';
    n1.person_name_first__c = 'First';
    ns.add(n1);

    NameCard__c n2 = new NameCard__c();
    n2.Name = 'Test';
    n2.company_name__c = '社団法人Testcompany';
    n2.person_name_last__c = 'TestLastLL';
    n2.person_name_first__c = 'First';
    ns.add(n2);

    NameCard__c n3 = new NameCard__c();
    n3.Name = 'Test';
    n3.company_name__c = 'Testcompany1';
    n3.person_name_last__c = 'LastLL';
    n3.person_name_first__c = 'First';
    ns.add(n3);

    NameCard__c n4 = new NameCard__c();
    n3.Name = 'Test';
    n3.company_name__c = 'Testcompany1';
    n4.person_name_last__c = 'TestLastLL';
    n4.person_name_first__c = 'Test';
    ns.add(n4);

    NameCard__c n5 = new NameCard__c();
    n5.Name = 'Test';
    n5.company_name__c = 'company社団A法人';
    n5.person_name_last__c = 'TestLastLL';
    n5.person_name_first__c = 'First';
    ns.add(n5);

    NameCard__c n6 = new NameCard__c();
    n6.Name = 'Test';
    n6.company_name__c = 'Testcompany社団法人';
    n6.person_name_last__c = 'TestLastLL';
    n6.person_name_first__c = 'First';
    ns.add(n6);

    insert ns;

    //含まれてますので排除します
    System.assertEquals(ce.isIgnore(n1),false);
    System.assertEquals(ce.isIgnore(n2),true);
    System.assertEquals(ce.isIgnore(n3),true);
    System.assertEquals(ce.isIgnore(n4),true);
    System.assertEquals(ce.isIgnore(n5),false);
    System.assertEquals(ce.isIgnore(n6),true);
  }

  //person_name_last__c 次の文字列で始まる Test
  //person_name_first__c 次の文字列を含まない Test
  //company_name__c 次の正規表現に合致する  ^(学校法人|社団法人|特殊法人|財団法人|監査法人|企業組合|協同組合|労働組合|医療法人社団|医療法人財団|社会医療法人|特定医療法人|医療法人|一般社団法人|一般財団法人|公益社団法人|公益財団法人|宗教法人|社会福祉法人|更生保護法人|独立行政法人|地方独立行政法人)(.*)$
  //->     指定文字列先頭に含む  学校法人|社団法人|特殊法人|財団法人|監査法人|企業組合|協同組合|労働組合|医療法人社団|医療法人財団|社会医療法人|特定医療法人|医療法人|一般社団法人|一般財団法人|公益社団法人|公益財団法人|宗教法人|社会福祉法人|更生保護法人|独立行政法人|地方独立行政法人
  @isTest static void test_String_Matches_the_following_regular_expression_string4() {
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    setting.Name = 'BasicSetting';
    insert setting;

    List<NameCardRenkeiJyoken__c> jos = new List<NameCardRenkeiJyoken__c>();
    NameCardRenkeiJyoken__c jyouken = new NameCardRenkeiJyoken__c();
    jyouken.NameCardName__c = SB_NameCard_Util.getNamespacePrefix_x() + 'person_name_last__c';
    //含む
    jyouken.Operator__c = 'Start_with_the_following_string';
    jyouken.Value__c = 'Test';
    jyouken.NameCardDataType__c = 'STRING';
    jos.add(jyouken);

    NameCardRenkeiJyoken__c jyouken0 = new NameCardRenkeiJyoken__c();
    jyouken0.NameCardName__c = SB_NameCard_Util.getNamespacePrefix_x() + 'person_name_first__c';
    //含まない
    jyouken0.Operator__c = 'Not_contain_the_following_character_string';
    jyouken0.Value__c = 'Test';
    jyouken0.NameCardDataType__c = 'STRING';
    jos.add(jyouken0);

    NameCardRenkeiJyoken__c jyouken1 = new NameCardRenkeiJyoken__c();
    jyouken1.NameCardName__c = SB_NameCard_Util.getNamespacePrefix_x() + 'company_name__c';
    jyouken1.Operator__c = 'Matches_the_following_regular_expression';
    //指定文字列含まない
    jyouken1.Value__c = '^(学校法人|社団法人|特殊法人|財団法人|監査法人|企業組合|協同組合|労働組合|医療法人社団|医療法人財団|社会医療法人|特定医療法人|医療法人|一般社団法人|一般財団法人|公益社団法人|公益財団法人|宗教法人|社会福祉法人|更生保護法人|独立行政法人|地方独立行政法人)(.*)$';
    jyouken1.NameCardDataType__c = 'STRING';
    jos.add(jyouken1);

    insert jos;
    SB_NameCard_RenkeiChecker ce =SB_NameCard_RenkeiChecker.getInstance();
    List<NameCard__c> ns = new List<NameCard__c>();
    NameCard__c n1 = new NameCard__c();
    n1.Name = 'Test';
    n1.company_name__c = '社団A法人company';
    n1.person_name_last__c = 'TestLastLL';
    n1.person_name_first__c = 'First';
    ns.add(n1);

    NameCard__c n2 = new NameCard__c();
    n2.Name = 'Test';
    n2.company_name__c = '社団法人Testcompany';
    n2.person_name_last__c = 'TestLastLL';
    n2.person_name_first__c = 'First';
    ns.add(n2);

    NameCard__c n3 = new NameCard__c();
    n3.Name = 'Test';
    n3.company_name__c = 'Testcompany1';
    n3.person_name_last__c = 'LastLL';
    n3.person_name_first__c = 'First';
    ns.add(n3);

    NameCard__c n4 = new NameCard__c();
    n3.Name = 'Test';
    n3.company_name__c = 'Testcompany1';
    n4.person_name_last__c = 'TestLastLL';
    n4.person_name_first__c = 'Test';
    ns.add(n4);

    NameCard__c n5 = new NameCard__c();
    n5.Name = 'Test';
    n5.company_name__c = 'company社団A法人';
    n5.person_name_last__c = 'TestLastLL';
    n5.person_name_first__c = 'First';
    ns.add(n5);

    NameCard__c n6 = new NameCard__c();
    n6.Name = 'Test';
    n6.company_name__c = 'Testcompany社団法人';
    n6.person_name_last__c = 'TestLastLL';
    n6.person_name_first__c = 'First';
    ns.add(n6);

    insert ns;

    //含まれてますので排除します
    System.assertEquals(ce.isIgnore(n1),true);
    System.assertEquals(ce.isIgnore(n2),false);
    System.assertEquals(ce.isIgnore(n3),true);
    System.assertEquals(ce.isIgnore(n4),true);
    System.assertEquals(ce.isIgnore(n5),true);
    System.assertEquals(ce.isIgnore(n6),true);
  }

  //person_name_last__c 次の文字列で始まる Test
  //person_name_first__c 次の文字列を含まない Test
  //company_name__c 次の正規表現に合致する  ^.*(学校法人|社団法人|特殊法人|財団法人|監査法人|企業組合|協同組合|労働組合|医療法人社団|医療法人財団|社会医療法人|特定医療法人|医療法人|一般社団法人|一般財団法人|公益社団法人|公益財団法人|宗教法人|社会福祉法人|更生保護法人|独立行政法人|地方独立行政法人)$
  //->     指定文字列末尾に含む  学校法人|社団法人|特殊法人|財団法人|監査法人|企業組合|協同組合|労働組合|医療法人社団|医療法人財団|社会医療法人|特定医療法人|医療法人|一般社団法人|一般財団法人|公益社団法人|公益財団法人|宗教法人|社会福祉法人|更生保護法人|独立行政法人|地方独立行政法人
  @isTest static void test_String_Matches_the_following_regular_expression_string5() {
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    setting.Name = 'BasicSetting';
    insert setting;

    List<NameCardRenkeiJyoken__c> jos = new List<NameCardRenkeiJyoken__c>();
    NameCardRenkeiJyoken__c jyouken = new NameCardRenkeiJyoken__c();
    jyouken.NameCardName__c = SB_NameCard_Util.getNamespacePrefix_x() + 'person_name_last__c';
    //含む
    jyouken.Operator__c = 'Start_with_the_following_string';
    jyouken.Value__c = 'Test';
    jyouken.NameCardDataType__c = 'STRING';
    jos.add(jyouken);

    NameCardRenkeiJyoken__c jyouken0 = new NameCardRenkeiJyoken__c();
    jyouken0.NameCardName__c = SB_NameCard_Util.getNamespacePrefix_x() + 'person_name_first__c';
    //含まない
    jyouken0.Operator__c = 'Not_contain_the_following_character_string';
    jyouken0.Value__c = 'Test';
    jyouken0.NameCardDataType__c = 'STRING';
    jos.add(jyouken0);

    NameCardRenkeiJyoken__c jyouken1 = new NameCardRenkeiJyoken__c();
    jyouken1.NameCardName__c = SB_NameCard_Util.getNamespacePrefix_x() + 'company_name__c';
    jyouken1.Operator__c = 'Matches_the_following_regular_expression';
    //指定文字列含まない
    jyouken1.Value__c = '^.*(学校法人|社団法人|特殊法人|財団法人|監査法人|企業組合|協同組合|労働組合|医療法人社団|医療法人財団|社会医療法人|特定医療法人|医療法人|一般社団法人|一般財団法人|公益社団法人|公益財団法人|宗教法人|社会福祉法人|更生保護法人|独立行政法人|地方独立行政法人)$';
    jyouken1.NameCardDataType__c = 'STRING';
    jos.add(jyouken1);

    insert jos;
    SB_NameCard_RenkeiChecker ce =SB_NameCard_RenkeiChecker.getInstance();
    List<NameCard__c> ns = new List<NameCard__c>();
    NameCard__c n1 = new NameCard__c();
    n1.Name = 'Test';
    n1.company_name__c = '社団A法人company';
    n1.person_name_last__c = 'TestLastLL';
    n1.person_name_first__c = 'First';
    ns.add(n1);

    NameCard__c n2 = new NameCard__c();
    n2.Name = 'Test';
    n2.company_name__c = '社団法人Testcompany';
    n2.person_name_last__c = 'TestLastLL';
    n2.person_name_first__c = 'First';
    ns.add(n2);

    NameCard__c n3 = new NameCard__c();
    n3.Name = 'Test';
    n3.company_name__c = 'Testcompany1';
    n3.person_name_last__c = 'LastLL';
    n3.person_name_first__c = 'First';
    ns.add(n3);

    NameCard__c n4 = new NameCard__c();
    n3.Name = 'Test';
    n3.company_name__c = 'Testcompany1';
    n4.person_name_last__c = 'TestLastLL';
    n4.person_name_first__c = 'Test';
    ns.add(n4);

    NameCard__c n5 = new NameCard__c();
    n5.Name = 'Test';
    n5.company_name__c = 'company社団A法人';
    n5.person_name_last__c = 'TestLastLL';
    n5.person_name_first__c = 'First';
    ns.add(n5);

    NameCard__c n6 = new NameCard__c();
    n6.Name = 'Test';
    n6.company_name__c = 'Testcompany社団法人';
    n6.person_name_last__c = 'TestLastLL';
    n6.person_name_first__c = 'First';
    ns.add(n6);

    insert ns;

    //含まれてますので排除します
    System.assertEquals(ce.isIgnore(n1),true);
    System.assertEquals(ce.isIgnore(n2),true);
    System.assertEquals(ce.isIgnore(n3),true);
    System.assertEquals(ce.isIgnore(n4),true);
    System.assertEquals(ce.isIgnore(n5),true);
    System.assertEquals(ce.isIgnore(n6),false);
  }


  //Name 次の文字列で始まる Test
  //Name 次の文字列を含まない XX
  @isTest static void test_String_Commis1() {
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    setting.Name = 'BasicSetting';
    insert setting;

    List<NameCardRenkeiJyoken__c> jos = new List<NameCardRenkeiJyoken__c>();
    NameCardRenkeiJyoken__c jyouken = new NameCardRenkeiJyoken__c();
    jyouken.NameCardName__c = 'Name';
    //含まない
    jyouken.Operator__c = 'Not_contain_the_following_character_string';
    jyouken.Value__c = 'XX';
    jyouken.NameCardDataType__c = 'STRING';
    jos.add(jyouken);

    NameCardRenkeiJyoken__c jyouken1 = new NameCardRenkeiJyoken__c();
    jyouken1.NameCardName__c = 'Name';
    //で始まる
    jyouken1.Operator__c = 'Start_with_the_following_string';
    jyouken1.Value__c = 'Test';
    jyouken1.NameCardDataType__c = 'STRING';
    jos.add(jyouken1);


    insert jos;
    SB_NameCard_RenkeiChecker ce =SB_NameCard_RenkeiChecker.getInstance();
    List<NameCard__c> ns = new List<NameCard__c>();
    NameCard__c n1 = new NameCard__c();
    n1.Name = 'Test1234321';
    n1.company_name__c = 'Test社団A法人company';
    n1.person_name_last__c = 'TestLastLL';
    n1.person_name_first__c = 'First';
    ns.add(n1);

    NameCard__c n2 = new NameCard__c();
    n2.Name = 'Test1234321XX';
    n2.company_name__c = 'Test社団法人company';
    n2.person_name_last__c = 'TestLastLL';
    n2.person_name_first__c = 'First';
    ns.add(n2);

    NameCard__c n3 = new NameCard__c();
    n3.Name = 'TestXssX';
    n3.company_name__c = 'Testcompany1';
    n3.person_name_last__c = 'LastLL';
    n3.person_name_first__c = 'First';
    ns.add(n3);

    NameCard__c n4 = new NameCard__c();
    n4.Name = 'XXTest';
    n4.company_name__c = 'Testcompany1';
    n4.person_name_last__c = 'LastLL';
    n4.person_name_first__c = 'First';
    ns.add(n4);
    insert ns;

    //含まれてますので排除します
    System.assertEquals(ce.isIgnore(n1),false);
    System.assertEquals(ce.isIgnore(n2),true);
    System.assertEquals(ce.isIgnore(n3),false);
    System.assertEquals(ce.isIgnore(n4),true);
  }

  //Name 次の文字列で始まる Test
  //Name 次の文字列で始まる XX
  @isTest static void test_String_Commis2() {
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    setting.Name = 'BasicSetting';
    insert setting;

    List<NameCardRenkeiJyoken__c> jos = new List<NameCardRenkeiJyoken__c>();
    NameCardRenkeiJyoken__c jyouken = new NameCardRenkeiJyoken__c();
    jyouken.NameCardName__c = 'Name';
    //含む
    jyouken.Operator__c = 'Start_with_the_following_string';
    jyouken.Value__c = 'XX';
    jyouken.NameCardDataType__c = 'STRING';
    jos.add(jyouken);

    NameCardRenkeiJyoken__c jyouken1 = new NameCardRenkeiJyoken__c();
    jyouken1.NameCardName__c = 'Name';
    //含む
    jyouken1.Operator__c = 'Start_with_the_following_string';
    jyouken1.Value__c = 'Test';
    jyouken1.NameCardDataType__c = 'STRING';
    jos.add(jyouken1);

    insert jos;
    SB_NameCard_RenkeiChecker ce =SB_NameCard_RenkeiChecker.getInstance();
    List<NameCard__c> ns = new List<NameCard__c>();
    NameCard__c n1 = new NameCard__c();
    n1.Name = 'Test1234321';
    n1.company_name__c = 'Test社団A法人company';
    n1.person_name_last__c = 'TestLastLL';
    n1.person_name_first__c = 'First';
    ns.add(n1);

    NameCard__c n2 = new NameCard__c();
    n2.Name = 'Test1234321XX';
    n2.company_name__c = 'Test社団法人company';
    n2.person_name_last__c = 'TestLastLL';
    n2.person_name_first__c = 'First';
    ns.add(n2);

    NameCard__c n3 = new NameCard__c();
    n3.Name = 'TestXssX';
    n3.company_name__c = 'Testcompany1';
    n3.person_name_last__c = 'LastLL';
    n3.person_name_first__c = 'First';
    ns.add(n3);

    NameCard__c n4 = new NameCard__c();
    n4.Name = 'XXTest';
    n4.company_name__c = 'Testcompany1';
    n4.person_name_last__c = 'LastLL';
    n4.person_name_first__c = 'First';
    ns.add(n4);
    insert ns;

    //含まれてますので排除します
    System.assertEquals(ce.isIgnore(n1),true);
    System.assertEquals(ce.isIgnore(n2),true);
    System.assertEquals(ce.isIgnore(n3),true);
    System.assertEquals(ce.isIgnore(n4),true);
  }

  //Name 次の文字列と一致 Test
  //Name 次の文字列と一致しない XX
  @isTest static void test_String_Commis3() {
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    setting.Name = 'BasicSetting';
    insert setting;

    List<NameCardRenkeiJyoken__c> jos = new List<NameCardRenkeiJyoken__c>();
    NameCardRenkeiJyoken__c jyouken = new NameCardRenkeiJyoken__c();
    jyouken.NameCardName__c = 'Name';
    //次の文字列と一致しない
    jyouken.Operator__c = 'Does_not_match_next_character_string';
    jyouken.Value__c = 'XX';
    jyouken.NameCardDataType__c = 'STRING';
    jos.add(jyouken);

    NameCardRenkeiJyoken__c jyouken1 = new NameCardRenkeiJyoken__c();
    jyouken1.NameCardName__c = 'Name';
    //次の文字列と一致
    jyouken1.Operator__c = 'Matches_next_character_string';
    jyouken1.Value__c = 'Test';
    jyouken1.NameCardDataType__c = 'STRING';
    jos.add(jyouken1);

    insert jos;
    SB_NameCard_RenkeiChecker ce =SB_NameCard_RenkeiChecker.getInstance();
    List<NameCard__c> ns = new List<NameCard__c>();
    NameCard__c n1 = new NameCard__c();
    n1.Name = 'Test1234321';
    n1.company_name__c = 'Test社団A法人company';
    n1.person_name_last__c = 'TestLastLL';
    n1.person_name_first__c = 'First';
    ns.add(n1);

    NameCard__c n2 = new NameCard__c();
    n2.Name = 'Test1234321XX';
    n2.company_name__c = 'Test社団法人company';
    n2.person_name_last__c = 'TestLastLL';
    n2.person_name_first__c = 'First';
    ns.add(n2);

    NameCard__c n3 = new NameCard__c();
    n3.Name = 'TestXssX';
    n3.company_name__c = 'Testcompany1';
    n3.person_name_last__c = 'LastLL';
    n3.person_name_first__c = 'First';
    ns.add(n3);

    NameCard__c n4 = new NameCard__c();
    n4.Name = 'XXTest';
    n4.company_name__c = 'Testcompany1';
    n4.person_name_last__c = 'LastLL';
    n4.person_name_first__c = 'First';
    ns.add(n4);

    NameCard__c n5 = new NameCard__c();
    n5.Name = 'Test';
    n5.company_name__c = 'Testcompany1';
    n5.person_name_last__c = 'LastLL';
    n5.person_name_first__c = 'First';
    ns.add(n5);
    insert ns;

    //含まれてますので排除します
    System.assertEquals(ce.isIgnore(n1),true);
    System.assertEquals(ce.isIgnore(n2),true);
    System.assertEquals(ce.isIgnore(n3),true);
    System.assertEquals(ce.isIgnore(n4),true);
    System.assertEquals(ce.isIgnore(n5),false);
  }
  //accountRegDateTime__c > 昨日
  //accountRegDateTime__c < 明日
  @isTest static void test_String_Commis4() {
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    setting.Name = 'BasicSetting';
    insert setting;

    List<NameCardRenkeiJyoken__c> jos = new List<NameCardRenkeiJyoken__c>();
    NameCardRenkeiJyoken__c jyouken = new NameCardRenkeiJyoken__c();
    jyouken.NameCardName__c = SB_NameCard_RenkeiMapperUtil.getManagedfileName('NameCard__c','accountRegDateTime__c');
    //>
    jyouken.Operator__c = '>';
    jyouken.Value__c = Datetime.now().adddays(-1).format('yyyy-MM-dd');
    jyouken.NameCardDataType__c = 'DATETIME';
    System.debug(jyouken.Value__c);
    jos.add(jyouken);

    NameCardRenkeiJyoken__c jyouken1 = new NameCardRenkeiJyoken__c();
    jyouken1.NameCardName__c = SB_NameCard_RenkeiMapperUtil.getManagedfileName('NameCard__c','accountRegDateTime__c');
    //<
    jyouken1.Operator__c = '<';
    jyouken1.Value__c = Datetime.now().adddays(+1).format('yyyy-MM-dd');
    jyouken1.NameCardDataType__c = 'DATETIME';
    jos.add(jyouken1);

    insert jos;
    SB_NameCard_RenkeiChecker ce =SB_NameCard_RenkeiChecker.getInstance();
    List<NameCard__c> ns = new List<NameCard__c>();
    NameCard__c n1 = new NameCard__c();
    n1.Name = 'Test1234321';
    n1.company_name__c = 'Test社団A法人company';
    n1.person_name_last__c = 'TestLastLL';
    n1.person_name_first__c = 'First';
    n1.accountRegDateTime__c = Datetime.now().adddays(1);
    ns.add(n1);

    NameCard__c n2 = new NameCard__c();
    n2.Name = 'Test1234321XX';
    n2.company_name__c = 'Test社団法人company';
    n2.person_name_last__c = 'TestLastLL';
    n2.person_name_first__c = 'First';
    n2.accountRegDateTime__c = Datetime.now().adddays(-1);
    ns.add(n2);

    NameCard__c n3 = new NameCard__c();
    n3.Name = 'TestXssX';
    n3.company_name__c = 'Testcompany1';
    n3.person_name_last__c = 'LastLL';
    n3.person_name_first__c = 'First';
    n3.accountRegDateTime__c = Datetime.now();
    ns.add(n3);

    insert ns;

    //含まれてますので排除します
    System.assertEquals(ce.isIgnore(n1),true);
    System.assertEquals(ce.isIgnore(n2),true);
    System.assertEquals(ce.isIgnore(n3),false);
  }


  //accountRegDateTime__c < 昨日
  //accountRegDateTime__c > 明日
  @isTest static void test_String_Commis5() {
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    setting.Name = 'BasicSetting';
    insert setting;

    List<NameCardRenkeiJyoken__c> jos = new List<NameCardRenkeiJyoken__c>();
    NameCardRenkeiJyoken__c jyouken = new NameCardRenkeiJyoken__c();
    jyouken.NameCardName__c = SB_NameCard_RenkeiMapperUtil.getManagedfileName('NameCard__c','accountRegDateTime__c');
    //<
    jyouken.Operator__c = '<';
    jyouken.Value__c = Datetime.now().adddays(-1).format('yyyy-MM-dd');
    jyouken.NameCardDataType__c = 'DATETIME';
    System.debug(jyouken.Value__c);
    jos.add(jyouken);

    NameCardRenkeiJyoken__c jyouken1 = new NameCardRenkeiJyoken__c();
    jyouken1.NameCardName__c = SB_NameCard_RenkeiMapperUtil.getManagedfileName('NameCard__c','accountRegDateTime__c');
    //>
    jyouken1.Operator__c = '>';
    jyouken1.Value__c = Datetime.now().adddays(+1).format('yyyy-MM-dd');
    jyouken1.NameCardDataType__c = 'DATETIME';
    jos.add(jyouken1);

    insert jos;
    SB_NameCard_RenkeiChecker ce =SB_NameCard_RenkeiChecker.getInstance();
    List<NameCard__c> ns = new List<NameCard__c>();
    NameCard__c n1 = new NameCard__c();
    n1.Name = 'Test1234321';
    n1.company_name__c = 'Test社団A法人company';
    n1.person_name_last__c = 'TestLastLL';
    n1.person_name_first__c = 'First';
    n1.accountRegDateTime__c = Datetime.now().adddays(1);
    ns.add(n1);

    NameCard__c n2 = new NameCard__c();
    n2.Name = 'Test1234321XX';
    n2.company_name__c = 'Test社団法人company';
    n2.person_name_last__c = 'TestLastLL';
    n2.person_name_first__c = 'First';
    n2.accountRegDateTime__c = Datetime.now().adddays(-1);
    ns.add(n2);

    NameCard__c n3 = new NameCard__c();
    n3.Name = 'TestXssX';
    n3.company_name__c = 'Testcompany1';
    n3.person_name_last__c = 'LastLL';
    n3.person_name_first__c = 'First';
    n3.accountRegDateTime__c = Datetime.now();
    ns.add(n3);

    insert ns;

    //含まれてますので排除します
    System.assertEquals(ce.isIgnore(n1),true);
    System.assertEquals(ce.isIgnore(n2),true);
    System.assertEquals(ce.isIgnore(n3),true);
  }

  //存在しない項目ケース
  @isTest static void test_NoField() {
    NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
    setting.Name = 'BasicSetting';
    insert setting;

    List<NameCardRenkeiJyoken__c> jos = new List<NameCardRenkeiJyoken__c>();
    NameCardRenkeiJyoken__c jyouken = new NameCardRenkeiJyoken__c();
    jyouken.NameCardName__c = 'Test';
    //含まない
    jyouken.Operator__c = 'Not_contain_the_following_character_string';
    jyouken.Value__c = 'XX';
    jyouken.NameCardDataType__c = 'STRING';
    jos.add(jyouken);

    NameCardRenkeiJyoken__c jyouken1 = new NameCardRenkeiJyoken__c();
    jyouken1.NameCardName__c = 'Test';
    //で始まる
    jyouken1.Operator__c = 'Start_with_the_following_string';
    jyouken1.Value__c = 'Test';
    jyouken1.NameCardDataType__c = 'STRING';
    jos.add(jyouken1);


    insert jos;
    SB_NameCard_RenkeiChecker ce =SB_NameCard_RenkeiChecker.getInstance();
    List<NameCard__c> ns = new List<NameCard__c>();
    NameCard__c n1 = new NameCard__c();
    n1.Name = 'Test1234321';
    n1.company_name__c = 'Test社団A法人company';
    n1.person_name_last__c = 'TestLastLL';
    n1.person_name_first__c = 'First';
    ns.add(n1);

    NameCard__c n2 = new NameCard__c();
    n2.Name = 'Test1234321XX';
    n2.company_name__c = 'Test社団法人company';
    n2.person_name_last__c = 'TestLastLL';
    n2.person_name_first__c = 'First';
    ns.add(n2);

    NameCard__c n3 = new NameCard__c();
    n3.Name = 'TestXssX';
    n3.company_name__c = 'Testcompany1';
    n3.person_name_last__c = 'LastLL';
    n3.person_name_first__c = 'First';
    ns.add(n3);

    NameCard__c n4 = new NameCard__c();
    n4.Name = 'XXTest';
    n4.company_name__c = 'Testcompany1';
    n4.person_name_last__c = 'LastLL';
    n4.person_name_first__c = 'First';
    ns.add(n4);
    insert ns;

    //含まれてますので排除します
    System.assertEquals(ce.isIgnore(n1),false);
    System.assertEquals(ce.isIgnore(n2),false);
    System.assertEquals(ce.isIgnore(n3),false);
    System.assertEquals(ce.isIgnore(n4),false);
  }

  //0-次の文字列と一致する
  //Matches_next_character_string 条件満たす
  @isTest static void test_CreatedDate_Insert0() {
    test_CreatedDate_Insert('Matches_next_character_string', Datetime.now(), true);
  }

  //Matches_next_character_string 条件満たさない
  @isTest static void test_CreatedDate_Insert01() {
    test_CreatedDate_Insert('Matches_next_character_string', Datetime.now().adddays(-1), false);
  }

  //1-次の文字列と一致しない
  //Does_not_match_next_character_string 条件満たさない
  @isTest static void test_CreatedDate_Insert1() {
    test_CreatedDate_Insert('Does_not_match_next_character_string', Datetime.now(), false);
  }

  //Does_not_match_next_character_string 条件満たす
  @isTest static void test_CreatedDate_Insert11() {
    test_CreatedDate_Insert('Does_not_match_next_character_string', Datetime.now().adddays(-1), true);
  }

  //6-＜ 条件満たさない
  @isTest static void test_CreatedDate_Insert6() {
    test_CreatedDate_Insert('<', Datetime.now(), false);
  }

  //6-＜ 条件満たす
  @isTest static void test_CreatedDate_Insert61() {
    test_CreatedDate_Insert('<', Datetime.now().adddays(1), true);
  }

  //7-＞ 条件満たさない
  @isTest static void test_CreatedDate_Insert7() {
    test_CreatedDate_Insert('>', Datetime.now(), false);
  }

  //7-＞ 条件満たさない
  @isTest static void test_CreatedDate_Insert71() {
    test_CreatedDate_Insert('>', Datetime.now().adddays(1), false);
  }

  //8-＜＝ 条件満たす =
  @isTest static void test_CreatedDate_Insert8() {
    test_CreatedDate_Insert('<=', Datetime.now(), true);
  }

  //8-＜＝ 条件満たす <
  @isTest static void test_CreatedDate_Insert81() {
    test_CreatedDate_Insert('<=', Datetime.now().adddays(1), true);
  }

  //8-＜＝ 条件満たさない >
  @isTest static void test_CreatedDate_Insert82() {
    test_CreatedDate_Insert('<=', Datetime.now().adddays(-1), false);
  }

  //9-＞＝ 条件満たす =
  @isTest static void test_CreatedDate_Insert9() {
    test_CreatedDate_Insert('>=', Datetime.now(), true);
  }

  //9-＞＝ 条件満たす >
  @isTest static void test_CreatedDate_Insert91() {
    test_CreatedDate_Insert('>=', Datetime.now().adddays(-1), true);
  }

  //9-＞＝ 条件満たさない <
  @isTest static void test_CreatedDate_Insert92() {
    test_CreatedDate_Insert('>=', Datetime.now().adddays(1), false);
  }

  // 時間null判断
  //0-次の文字列と一致する
  @isTest static void test_TypeDateTime0() {
    test_TypeDateTime('Matches_next_character_string', Datetime.now(), null,true);
  }

  @isTest static void test_TypeDateTime01() {
    test_TypeDateTime('Matches_next_character_string', null, Datetime.now(), true);
  }

  @isTest static void test_TypeDateTime02() {
    test_TypeDateTime('Matches_next_character_string', null, null, false);
  }

  //1-次の文字列と一致しない
  @isTest static void test_TypeDateTime1() {
    test_TypeDateTime('Does_not_match_next_character_string', Datetime.now(), null, false);
  }

  @isTest static void test_TypeDateTime11() {
    test_TypeDateTime('Does_not_match_next_character_string', null, Datetime.now(), false);
  }

  @isTest static void test_TypeDateTime12() {
    test_TypeDateTime('Does_not_match_next_character_string', null, null, true);
  }

  //6-＜
  @isTest static void test_TypeDateTime6() {
    test_TypeDateTime('<', Datetime.now(), null, true);
  }

  //6-＜
  @isTest static void test_TypeDateTime61() {
    test_TypeDateTime('<', null, Datetime.now(), false);
  }

  //6-＜
  @isTest static void test_TypeDateTime62() {
    test_TypeDateTime('<', null, null, false);
  }

  //7-＞
  @isTest static void test_TypeDateTime7() {
    test_TypeDateTime('>', Datetime.now(), null, true);
  }

  //7-＞
  @isTest static void test_TypeDateTime71() {
    test_TypeDateTime('>', null, Datetime.now(), false);
  }

  //7-＞
  @isTest static void test_TypeDateTime72() {
    test_TypeDateTime('>', null, null, false);
  }

  //8-＜＝
  @isTest static void test_TypeDateTime8() {
    test_TypeDateTime('<=', Datetime.now(), null, true);
  }

  //8-＜＝
  @isTest static void test_TypeDateTime81() {
    test_TypeDateTime('<=', null, Datetime.now(), false);
  }

   //8-＜＝
  @isTest static void test_TypeDateTime82() {
    test_TypeDateTime('<=', null, null, false);
  }

  //9-＞＝
  @isTest static void test_TypeDateTime9() {
    test_TypeDateTime('>=', Datetime.now(), null, true);
  }

  //9-＞＝
  @isTest static void test_TypeDateTime91() {
    test_TypeDateTime('>=', null, Datetime.now(), false);
  }

  //9-＞＝
  @isTest static void test_TypeDateTime92() {
    test_TypeDateTime('>=', null, null, false);
  }




  // 作成日の作成チェックテスト
  static void test_CreatedDate_Insert(String operator, Datetime cDate, Boolean assertF) {
    NameCardBasicSetting__c setting = SB_NameCard_BasicSetting.getNameCardBasicSetting();
    setting.RenkeiActive__c = true;
    setting.RenkeiAccountOverwrite__c = true;
    setting.RenkeiContactOverwrite__c = true;
    setting.RenkeiAccountNOExistCreateNew__c = true;
    setting.RenkeiContactNOExistCreateNew__c = true;
    insert setting;

    List<NameCardRenkeiJyoken__c> jos = new List<NameCardRenkeiJyoken__c>();
    NameCardRenkeiJyoken__c jyouken = new NameCardRenkeiJyoken__c();
    jyouken.NameCardName__c = 'CreatedDate';
    jyouken.Operator__c = operator;
    jyouken.Value__c = cDate.format('yyyy-MM-dd');
    jyouken.NameCardDataType__c = 'DATETIME';
    jyouken.BasicSetting__c = setting.Id;
    jos.add(jyouken);

    insert jos;
    SB_NameCard_RenkeiChecker ce =SB_NameCard_RenkeiChecker.getInstance();
    List<NameCard__c> ns = new List<NameCard__c>();
    NameCard__c n1 = new NameCard__c();
    n1.Name = 'Test1234321';
    n1.company_name__c = 'Test社団A法人company';
    n1.person_name_last__c = 'TestLastLL';
    n1.person_name_first__c = 'First';
    n1.delivery_type__c = '2';
    insert n1;
    List<NameCard__c> ncs = [Select Id, RenkeiMessage__c From NameCard__c];
    System.assertEquals(1, ncs.size());
    System.assertEquals(assertF, String.isNotBlank(ncs[0].RenkeiMessage__c));
  }


  // 時間チェックテスト
  static void test_TypeDateTime(String operator, Datetime date1, Datetime date2, Boolean assertF) {
    NameCardBasicSetting__c setting = SB_NameCard_BasicSetting.getNameCardBasicSetting();
    setting.RenkeiActive__c = true;
    setting.RenkeiAccountOverwrite__c = true;
    setting.RenkeiContactOverwrite__c = true;
    setting.RenkeiAccountNOExistCreateNew__c = true;
    setting.RenkeiContactNOExistCreateNew__c = true;
    insert setting;

    List<NameCardRenkeiJyoken__c> jos = new List<NameCardRenkeiJyoken__c>();
    NameCardRenkeiJyoken__c jyouken = new NameCardRenkeiJyoken__c();
    jyouken.NameCardName__c = SB_NameCard_Util.getNamespacePrefix_x() + 'card_exchange_date__c';
    jyouken.Operator__c = operator;
    if (date1 != null) {
      jyouken.Value__c = date1.format('yyyy-MM-dd');
    }
    jyouken.NameCardDataType__c = 'DATE';
    jyouken.BasicSetting__c = setting.Id;
    jos.add(jyouken);

    insert jos;
    SB_NameCard_RenkeiChecker ce =SB_NameCard_RenkeiChecker.getInstance();
    List<NameCard__c> ns = new List<NameCard__c>();
    NameCard__c n1 = new NameCard__c();
    n1.Name = 'Test1234321';
    n1.company_name__c = 'Test社団A法人company';
    n1.person_name_last__c = 'TestLastLL';
    n1.person_name_first__c = 'First';
    n1.delivery_type__c = '2';
    n1.card_exchange_date__c = Date.valueOf(date2);

    NameCard__c n2 = new NameCard__c();
    n2.Name = 'Test1234321';
    n2.company_name__c = 'Test社団A法人company';
    n2.person_name_last__c = 'TestLastLL';
    n2.person_name_first__c = 'First';
    n2.delivery_type__c = '2';
    n2.accountRegDateTime__c = date2;
    insert new NameCard__c[]{n1, n2};
    System.assertEquals(ce.isIgnore(n1), assertF);
    jyouken.NameCardName__c = SB_NameCard_Util.getNamespacePrefix_x() + 'accountRegDateTime__c';
    jyouken.NameCardDataType__c = 'DATETIME';
    update jyouken;
    ce = new SB_NameCard_RenkeiChecker();
    System.assertEquals(ce.isIgnore(n2), assertF);
  }


  //0-次の文字列と一致する
  //Matches_next_character_string 条件満たす
  @isTest static void test_CreatedDate_Update0() {
    test_CreatedDate_Update('Matches_next_character_string', Datetime.now(), Datetime.now(), true);
  }

  //Matches_next_character_string 条件満たさない
  @isTest static void test_CreatedDate_Update01() {
    test_CreatedDate_Update('Matches_next_character_string', Datetime.now(), Datetime.now().adddays(-1), false);
  }

  //1-次の文字列と一致しない
  //Does_not_match_next_character_string 条件満たさない
  @isTest static void test_CreatedDate_Update1() {
    test_CreatedDate_Update('Does_not_match_next_character_string', Datetime.now(), Datetime.now(), false);
  }

  //Does_not_match_next_character_string 条件満たす
  @isTest static void test_CreatedDate_Update11() {
    test_CreatedDate_Update('Does_not_match_next_character_string', Datetime.now(), Datetime.now().adddays(-1), true);
  }

  //6-＜ 条件満たさない
  @isTest static void test_CreatedDate_Update6() {
    test_CreatedDate_Update('<', Datetime.now(), Datetime.now(), false);
  }

  //6-＜ 条件満たす
  @isTest static void test_CreatedDate_Update61() {
    test_CreatedDate_Update('<', Datetime.now(), Datetime.now().adddays(-1), true);
  }

  //7-＞ 条件満たさない
  @isTest static void test_CreatedDate_Update7() {
    test_CreatedDate_Update('>', Datetime.now(), Datetime.now(), false);
  }

  ////7-＞ 条件満たす
  @isTest static void test_CreatedDate_Update71() {
    test_CreatedDate_Update('>', Datetime.now().adddays(-1), Datetime.now(), true);
  }

  //8-＜＝ 条件満たす =
  @isTest static void test_CreatedDate_Update8() {
    test_CreatedDate_Update('<=', Datetime.now(), Datetime.now(), true);
  }

  //8-＜＝ 条件満たす <
  @isTest static void test_CreatedDate_Update81() {
    test_CreatedDate_Update('<=', Datetime.now(), Datetime.now().adddays(-1), true);
  }

  //8-＜＝ 条件満たさない >
  @isTest static void test_CreatedDate_Update82() {
    test_CreatedDate_Update('<=', Datetime.now().adddays(-1), Datetime.now(), false);
  }

  //9-＞＝ 条件満たす =
  @isTest static void test_CreatedDate_Update9() {
    test_CreatedDate_Update('>=', Datetime.now(), Datetime.now(), true);
  }

  //9-＞＝ 条件満たす >
  @isTest static void test_CreatedDate_Update91() {
    test_CreatedDate_Update('>=', Datetime.now().adddays(-1), Datetime.now(), true);
  }

  //9-＞＝ 条件満たさない <
  @isTest static void test_CreatedDate_Update92() {
    test_CreatedDate_Update('>=', Datetime.now(), Datetime.now().adddays(-1), false);
  }


  // 作成日の更新チェックテスト
  static void test_CreatedDate_Update(String operator, Datetime cDate, Datetime createDate, Boolean assertF) {
    NameCardBasicSetting__c setting = SB_NameCard_BasicSetting.getNameCardBasicSetting();
    setting.RenkeiActive__c = true;
    setting.RenkeiAccountOverwrite__c = true;
    setting.RenkeiContactOverwrite__c = true;
    setting.RenkeiAccountNOExistCreateNew__c = true;
    setting.RenkeiContactNOExistCreateNew__c = true;
    insert setting;

    List<NameCardRenkeiJyoken__c> jos = new List<NameCardRenkeiJyoken__c>();
    NameCardRenkeiJyoken__c jyouken = new NameCardRenkeiJyoken__c();
    jyouken.NameCardName__c = 'CreatedDate';
    jyouken.Operator__c = operator;
    jyouken.Value__c = cDate.format('yyyy-MM-dd');
    jyouken.NameCardDataType__c = 'Datetime';
    jyouken.BasicSetting__c = setting.Id;
    jos.add(jyouken);

    insert jos;
    SB_NameCard_RenkeiChecker ce =SB_NameCard_RenkeiChecker.getInstance();
    List<NameCard__c> ns = new List<NameCard__c>();
    NameCard__c n1 = new NameCard__c();
    n1.Name = 'Test1234321';
    n1.company_name__c = 'Test社団A法人company';
    n1.person_name_last__c = 'TestLastLL';
    n1.person_name_first__c = 'First';
    n1.delivery_type__c = '1';
    insert n1;
    Test.setCreatedDate(n1.Id, createDate);
    n1.delivery_type__c = '2';
    update n1;
    List<NameCard__c> ncs = [Select Id, RenkeiMessage__c From NameCard__c];
    System.assertEquals(1, ncs.size());
    System.assertEquals(assertF, String.isNotBlank(ncs[0].RenkeiMessage__c));
  }

  //0-次の文字列と一致する
  //Matches_next_character_string 条件満たす
  @isTest static void test_LastM_Insert0() {
    test_LastM_Insert('Matches_next_character_string', Datetime.now(), true);
  }

  //Matches_next_character_string 条件満たさない
  @isTest static void test_LastM_Insert01() {
    test_LastM_Insert('Matches_next_character_string', Datetime.now().adddays(-1), false);
  }

  //1-次の文字列と一致しない
  //Does_not_match_next_character_string 条件満たさない
  @isTest static void test_LastM_Insert1() {
    test_LastM_Insert('Does_not_match_next_character_string', Datetime.now(), false);
  }

  //Does_not_match_next_character_string 条件満たす
  @isTest static void test_LastM_Insert11() {
    test_LastM_Insert('Does_not_match_next_character_string', Datetime.now().adddays(-1), true);
  }

  //6-＜ 条件満たさない
  @isTest static void test_LastM_Insert6() {
    test_LastM_Insert('<', Datetime.now(), false);
  }

  //6-＜ 条件満たす
  @isTest static void test_LastM_Insert61() {
    test_LastM_Insert('<', Datetime.now().adddays(1), true);
  }

  //7-＞ 条件満たさない
  @isTest static void test_LastM_Insert7() {
    test_LastM_Insert('>', Datetime.now(), false);
  }

  //7-＞ 条件満たさない
  @isTest static void test_LastM_Insert71() {
    test_LastM_Insert('>', Datetime.now().adddays(1), false);
  }

  //8-＜＝ 条件満たす =
  @isTest static void test_LastM_Insert8() {
    test_LastM_Insert('<=', Datetime.now(), true);
  }

  //8-＜＝ 条件満たす <
  @isTest static void test_LastM_Insert81() {
    test_LastM_Insert('<=', Datetime.now().adddays(1), true);
  }

  //8-＜＝ 条件満たさない >
  @isTest static void test_LastM_Insert82() {
    test_LastM_Insert('<=', Datetime.now().adddays(-1), false);
  }

  //9-＞＝ 条件満たす =
  @isTest static void test_LastM_Insert9() {
    test_LastM_Insert('>=', Datetime.now(), true);
  }

  //9-＞＝ 条件満たす >
  @isTest static void test_LastM_Insert91() {
    test_LastM_Insert('>=', Datetime.now().adddays(-1), true);
  }

  //9-＞＝ 条件満たさない <
  @isTest static void test_LastM_Insert92() {
    test_LastM_Insert('>=', Datetime.now().adddays(1), false);
  }

  // 最終更新日の作成チェックテスト
  static void test_LastM_Insert(String operator, Datetime cDate, Boolean assertF) {
    NameCardBasicSetting__c setting = SB_NameCard_BasicSetting.getNameCardBasicSetting();
    setting.RenkeiActive__c = true;
    setting.RenkeiAccountOverwrite__c = true;
    setting.RenkeiContactOverwrite__c = true;
    setting.RenkeiAccountNOExistCreateNew__c = true;
    setting.RenkeiContactNOExistCreateNew__c = true;
    insert setting;

    List<NameCardRenkeiJyoken__c> jos = new List<NameCardRenkeiJyoken__c>();
    NameCardRenkeiJyoken__c jyouken = new NameCardRenkeiJyoken__c();
    jyouken.NameCardName__c = 'LastModifiedDate';
    jyouken.Operator__c = operator;
    jyouken.Value__c = cDate.format('yyyy-MM-dd');
    jyouken.NameCardDataType__c = 'Datetime';
    jyouken.BasicSetting__c = setting.Id;
    jos.add(jyouken);

    insert jos;
    SB_NameCard_RenkeiChecker ce =SB_NameCard_RenkeiChecker.getInstance();
    List<NameCard__c> ns = new List<NameCard__c>();
    NameCard__c n1 = new NameCard__c();
    n1.Name = 'Test1234321';
    n1.company_name__c = 'Test社団A法人company';
    n1.person_name_last__c = 'TestLastLL';
    n1.person_name_first__c = 'First';
    n1.delivery_type__c = '2';
    insert n1;
    List<NameCard__c> ncs = [Select Id, RenkeiMessage__c From NameCard__c];
    System.assertEquals(1, ncs.size());
    System.assertEquals(assertF, String.isNotBlank(ncs[0].RenkeiMessage__c));
  }

  //255越えたのでコメントアウト
  // @isTest static void test_String_Matches_the_following_regular_expression_string2() {
  //   NameCardBasicSetting__c setting = new NameCardBasicSetting__c();
  //   setting.Name = 'BasicSetting';
  //   insert setting;

  //   List<NameCardRenkeiJyoken__c> jos = new List<NameCardRenkeiJyoken__c>();
  //   NameCardRenkeiJyoken__c jyouken = new NameCardRenkeiJyoken__c();
  //   jyouken.NameCardName__c = 'Name';
  //   jyouken.Operator__c = 'Matches_next_character_string';
  //   jyouken.Value__c = 'Testcompany';
  //   jyouken.NameCardDataType__c = 'STRING';
  //   jos.add(jyouken);

  //   NameCardRenkeiJyoken__c jyouken1 = new NameCardRenkeiJyoken__c();
  //   jyouken1.NameCardName__c = SB_NameCard_Util.getNamespacePrefix_x() + 'company_name__c';
  //   jyouken1.Operator__c = 'Matches_the_following_regular_expression';
  //   //指定文字列含まない
  //   jyouken1.Value__c = '^(?!(学校法人|社団法人|特殊法人|財団法人|監査法人|企業組合|協同組合|労働組合|医療法人社団|医療法人財団|社会医療法人|特定医療法人|医療法人|一般社団法人|一般財団法人|公益社団法人|公益財団法人|宗教法人|社会福祉法人|更生保護法人|独立行政法人|地方独立行政法人))(.*)(?<!(学校法人|社団法人|特殊法人|財団法人|監査法人|企業組合|協同組合|労働組合|医療法人社団|医療法人財団|社会医療法人|特定医療法人|医療法人|一般社団法人|一般財団法人|公益社団法人|公益財団法人|宗教法人|社会福祉法人|更生保護法人|独立行政法人|地方独立行政法人))$';
  //   jyouken1.NameCardDataType__c = 'STRING';
  //   jos.add(jyouken1);

  //   insert jos;
  //   SB_NameCard_RenkeiChecker ce =SB_NameCard_RenkeiChecker.getInstance();
  //   List<NameCard__c> ns = new List<NameCard__c>();
  //   NameCard__c n1 = new NameCard__c();
  //   n1.Name = 'Test';
  //   n1.company_name__c = 'Test社団法人company';
  //   ns.add(n1);

  //   NameCard__c n2 = new NameCard__c();
  //   n2.Name = 'Test1';
  //   n2.company_name__c = '社団法人company';
  //   ns.add(n2);

  //   NameCard__c n3 = new NameCard__c();
  //   n3.Name = 'Test';
  //   n3.company_name__c = 'company社団法人';
  //   ns.add(n3);
  //   insert ns;

  //   //含まれてますので排除します
  //   System.assertEquals(ce.isIgnore(n1),true);
  //   System.assertEquals(ce.isIgnore(n2),false);
  //   System.assertEquals(ce.isIgnore(n3),true);
  // }
}