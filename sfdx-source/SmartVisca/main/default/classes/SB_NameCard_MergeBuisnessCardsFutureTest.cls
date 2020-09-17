/**
 *
 * SB_NameCard_MergeBuisnessCardsFuture  のテストクラス
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author K.Yoshida
 *  @Version 2.4  2019.06.XX
 *
 **/
@isTest
public class SB_NameCard_MergeBuisnessCardsFutureTest {
  public static Set<String> INHERIT_SETTING = new Set < String > {'memo__c','freehandmemo__c'}; //最新の名刺への引継ぎ対象データ
  public static Set<String> NAYOSE_SETTING = new Set<String>{'company_name__c','tel1__c','web_url1__c'}; //名寄せ条件

  public class MergeTestDb extends SB_NC_TestDB {
    public override void initialize() {
      //基本設定の投入
      initializeBasicSetting();
      if (!listBasicSetting.isEmpty()) 
          insert listBasicSetting;
      updateBasic();

      //カスタム設定の投入
      initializeSmartViscaConfig();
      svConfig.TriggerMergeNameCards__c = true;      //名寄せ処理有効化
      //svConfig.TriggerMergeExpandCriteria__c = true; //トリガで実施する名寄せの条件を拡張する有効化
      SB_NameCard_MergeBuisnessCardsFuture.isTriggerMergeExpandCriteria = true; // future実装版クラスをテストクラスからコールする用
      insert svConfig;

      //設定値の投入(値引継ぎ機能)
      initializeSaishinInheritConfig();

      //ダミーユーザの投入
      initializeUser();
      if (listUser.isEmpty() == false)
          insert listUser;

      //ダミー名刺の投入
      initializeTestData();
    }

    //基本設定足りない部分を上書き
    public void updateBasic(){
      List<NameCardBasicSetting__c> basics= [Select Id,Name From NameCardBasicSetting__c];
      for(NameCardBasicSetting__c ba : basics){
        ba.SaishinInheritValues__c = true;
        String jyoken = '';
        for ( String field:NAYOSE_SETTING ){
          jyoken = jyoken + SB_NameCard_RenkeiMapperUtil.getManagedfileName('all',field) + ';';
        }
        jyoken = jyoken.substring(0, jyoken.length() - 1);
        ba.NayoseJyoken__c = jyoken; //名寄せ条件
      }
      Update basics;
    }

    // 最新の名刺引継ぎ設定
    private void initializeSaishinInheritConfig() {
      List < NameCardSettingValues__c > settingvalue = new List < NameCardSettingValues__c > ();
      for (String str: SB_NameCard_MergeBuisnessCardsFutureTest.INHERIT_SETTING) {
        NameCardSettingValues__c sv = new NameCardSettingValues__c();
        sv.TextValue01__c = SB_NameCard_RenkeiMapperUtil.getManagedfileName('all',str);
        sv.Type__c = 'SaishinInherit';
        settingvalue.add(sv);
      }
      insert settingvalue;
      System.assert(!SB_NameCard_SettingValues.saishinInheritFields.isEmpty());  // for code scan
    }

    // 名刺データ作成
    //  名寄せ済みを想定したデータを作成する
    public void initializeTestData() {
      List<NameCard__c> ncList = new List<NameCard__c>();
      // 日本語名刺データの作成
      NameCard__c newNc = makeTestNameCard(0);
      newNc.Parent__c = null;
      newNc.Saishin__c = true;
      insert newNc;

      // 過去分名刺データ
      for (Integer i = 1 ; i < 10 ; i++ ){
        NameCard__c tmpNc = makeTestNameCard(i);
        tmpNc.Parent__c = newNc.Id;
        tmpNc.Saishin__c = false;
        ncList.add(tmpNc);
      }
      // 転職済みデータ
      NameCard__c tenshokuNc = makeTestNameCard(10);
      tenshokuNc.tenshokugonomeishi__c = newNc.Id;
      tenshokuNc.Parent__c = newNc.Id;
      tenshokuNc.Saishin__c = false;
      tenshokuNc.tenshokuzumi__c = true;
      ncList.add(tenshokuNc);

      // 英語名刺データの作成
      NameCard__c newEngNc = makeTestEngNameCard(0);
      newEngNc.Parent__c = null;
      newEngNc.Saishin__c = true;
      insert newEngNc;

      // 過去分名刺データ
      for (Integer i = 1 ; i < 10 ; i++ ){
        NameCard__c tmpNc = makeTestEngNameCard(i);
        tmpNc.Parent__c = newEngNc.Id;
        tmpNc.Saishin__c = false;
        ncList.add(tmpNc);
      }
      // 転職済みデータ
      NameCard__c tenshokuEngNc = makeTestEngNameCard(10);
      tenshokuEngNc.tenshokugonomeishi__c = newEngNc.Id;
      tenshokuEngNc.Parent__c = newEngNc.Id;
      tenshokuEngNc.Saishin__c = false;
      tenshokuEngNc.tenshokuzumi__c = true;
      ncList.add(tenshokuEngNc);
      System.assertEquals(ncList.size(),20);  // for code scan
      insert ncList;
    }

    public NameCard__c makeTestNameCard(Integer param){
      NameCard__c nc = new NameCard__c(
              name= '試験 太郎'
              , person_name_last__c= '試験'
              , person_name_first__c= '太郎'
              , email__c= 'test@nayose.com'
              , company_name__c= '株式会社試験システム開発'
              , division__c = '本社'
              , title_name__c = '役職'
              , tel1__c= '03-1111-1111'
              , tel2__c= '03-1111-1121'
              , fax1__c= '03-1111-1131'
              , mobile__c = '090-9999-9999'
              , web_url1__c = 'http://www.testdev.com'
              , zip_code__c = '111-1111'
              , address_pref__c = '東京都'
              , address__c = '渋谷区恵比寿1-1-1'
              , address_bld__c = '恵比寿第一ビル'
              , memo__c = 'メモ : ' + param
              , freehandmemo__c = '自由記述 : ' + param
              , card_exchange_date__c = date.today().addDays( (param * -1) )
              , delivery_type__c='2'
              , OwnerId = listUser[0].Id
      );

      return nc;
    }

    public NameCard__c makeTestEngNameCard(Integer param){
      NameCard__c nc = new NameCard__c(
              name= 'Test Taro'
              , last_name__c= 'Test'
              , first_name__c= 'Taro'
              , email__c= 'taro@nayose.com'
              , company_name__c= 'Test System Development Co.,Ltd.'
              , division__c = 'Honsha'
              , title_name__c = 'Yakushoku'
              , tel1__c= '+81-3-1111-1111'
              , tel2__c= '+81-3-1111-1121'
              , fax1__c= '+81-3-1111-1131'
              , mobile__c = '+8190-9999-9999'
              , web_url1__c = 'http://www.testdev.com'
              , address_eng__c = 'Ebisu Bldg. 1-1-1 Ebisu, Shibuya-ku, Tokyo 111-1111 Japan'
              , memo__c = 'メモ : ' + param
              , freehandmemo__c = '自由記述 : ' + param
              , card_exchange_date__c = date.today().addDays( (param * -1) )
              , delivery_type__c='2'
              , OwnerId = listUser[0].Id
      );
      return nc;
    }

    
  }

  //メールアドレスでの名寄せ
  public static testMethod void mergeNameCardEmail() {
    SB_NameCard_MergeBuisnessCardsFuture.futureMergeCalled = true;  //この段階では名寄せ処理を行わない
    //テストデータを作成
    MergeTestDb db = new MergeTestDb();
    db.initialize();
    List<NameCard__c> beforeSaishin = [Select Id, Name, Saishin__c,memo__c,freehandmemo__c From NameCard__c Where Saishin__c = true and Name = '試験 太郎'];
    System.assert(beforeSaishin.size() == 1);

    //トリガを起動させる名刺の初期化
    NameCard__c card = db.makeTestNameCard(-1);
    //card.email__c = null;
    card.company_name__c = null;
    card.tel1__c = null;
    card.web_url1__c = null;
    card.memo__c = '';
    card.freehandmemo__c = '';

    Test.startTest();
    SB_NameCard_MergeBuisnessCardsFuture.futureMergeCalled = false;  //名寄せを実行
    insert card;
    Test.stopTest();

    System.assert(SB_NameCard_MergeBuisnessCardsFuture.futureMergeCalled);
    verifyMargeResult(beforeSaishin,card);
  }

  //条件1での名寄せ
  public static testMethod void mergeNameCardJyoken1() {
    SB_NameCard_MergeBuisnessCardsFuture.futureMergeCalled = true;  //この段階では名寄せ処理を行わない
    //テストデータを作成
    MergeTestDb db = new MergeTestDb();
    db.initialize();
    List<NameCard__c> beforeSaishin = [Select Id, Name, Saishin__c,memo__c,freehandmemo__c From NameCard__c Where Saishin__c = true and Name = '試験 太郎'];
    System.assert(beforeSaishin.size() == 1);

    //トリガを起動させる名刺の初期化
    NameCard__c card = db.makeTestNameCard(-1);
    card.email__c = null;
    //card.company_name__c = null;
    card.tel1__c = null;
    card.web_url1__c = null;
    card.memo__c = '';
    card.freehandmemo__c = '';

    Test.startTest();
    SB_NameCard_MergeBuisnessCardsFuture.futureMergeCalled = false;  //名寄せを実行
    insert card;
    Test.stopTest();

    System.assert(SB_NameCard_MergeBuisnessCardsFuture.futureMergeCalled);
    verifyMargeResult(beforeSaishin,card);
  }

  //条件2での名寄せ
  public static testMethod void mergeNameCardJyoken2() {
    SB_NameCard_MergeBuisnessCardsFuture.futureMergeCalled = true;  //この段階では名寄せ処理を行わない
    //テストデータを作成
    MergeTestDb db = new MergeTestDb();
    db.initialize();
    List<NameCard__c> beforeSaishin = [Select Id, Name, Saishin__c,memo__c,freehandmemo__c From NameCard__c Where Saishin__c = true and Name = '試験 太郎'];
    System.assert(beforeSaishin.size() == 1);

    //トリガを起動させる名刺の初期化
    NameCard__c card = db.makeTestNameCard(-1);
    card.email__c = null;
    card.company_name__c = null;
    //card.tel1__c = null;
    card.web_url1__c = null;
    card.memo__c = '';
    card.freehandmemo__c = '';

    Test.startTest();
    SB_NameCard_MergeBuisnessCardsFuture.futureMergeCalled = false;  //名寄せを実行
    insert card;
    Test.stopTest();

    System.assert(SB_NameCard_MergeBuisnessCardsFuture.futureMergeCalled);
    verifyMargeResult(beforeSaishin,card);
  }

  //条件3での名寄せ
  public static testMethod void mergeNameCardJyoken3() {
    SB_NameCard_MergeBuisnessCardsFuture.futureMergeCalled = true;  //この段階では名寄せ処理を行わない
    //テストデータを作成
    MergeTestDb db = new MergeTestDb();
    db.initialize();
    List<NameCard__c> beforeSaishin = [Select Id, Name, Saishin__c,memo__c,freehandmemo__c From NameCard__c Where Saishin__c = true and Name = '試験 太郎'];
    System.assert(beforeSaishin.size() == 1);

    //トリガを起動させる名刺の初期化
    NameCard__c card = db.makeTestNameCard(-1);
    card.email__c = null;
    card.company_name__c = null;
    card.tel1__c = null;
    //card.web_url1__c = null;
    card.memo__c = '';
    card.freehandmemo__c = '';

    Test.startTest();
    SB_NameCard_MergeBuisnessCardsFuture.futureMergeCalled = false;  //名寄せを実行
    insert card;
    Test.stopTest();

    System.assert(SB_NameCard_MergeBuisnessCardsFuture.futureMergeCalled);
    verifyMargeResult(beforeSaishin,card);
  }

  //英語名刺で名寄せ
  public static testMethod void mergeNameCardEng() {
    SB_NameCard_MergeBuisnessCardsFuture.futureMergeCalled = true;  //この段階では名寄せ処理を行わない
    //テストデータを作成
    MergeTestDb db = new MergeTestDb();
    db.initialize();
    List<NameCard__c> beforeSaishin = [Select Id, Name, Saishin__c,memo__c,freehandmemo__c From NameCard__c Where Saishin__c = true and Name = 'Test Taro'];
    System.assert(beforeSaishin.size() == 1);

    //トリガを起動させる名刺の初期化
    NameCard__c card = db.makeTestEngNameCard(-1);
    //card.email__c = null;
    card.company_name__c = null;
    card.tel1__c = null;
    card.web_url1__c = null;
    card.memo__c = '';
    card.freehandmemo__c = '';

    Test.startTest();
    SB_NameCard_MergeBuisnessCardsFuture.futureMergeCalled = false;  //名寄せを実行
    insert card;
    Test.stopTest();

    System.assert(SB_NameCard_MergeBuisnessCardsFuture.futureMergeCalled);
    verifyMargeResult(beforeSaishin,card);
  }

  //赤の他人での検証
  public static testMethod void mergeNameOtherCard() {
    SB_NameCard_MergeBuisnessCardsFuture.futureMergeCalled = true;  //この段階では名寄せ処理を行わない
    //テストデータを作成
    MergeTestDb db = new MergeTestDb();
    db.initialize();
    List<NameCard__c> beforeSaishin = [Select Id, Name, Saishin__c,memo__c,freehandmemo__c From NameCard__c Where Saishin__c = true and Name = '試験 太郎'];
    System.assert(beforeSaishin.size() == 1);

    //トリガを起動させる名刺の初期化
    NameCard__c card = db.makeTestNameCard(-1);
    card.email__c = 'hoge@hoge.com';
    card.company_name__c = 'hogehoge';
    card.tel1__c = '000';
    card.web_url1__c = 'http://hoge.com';
    card.memo__c = '';
    card.freehandmemo__c = '';

    Test.startTest();
    SB_NameCard_MergeBuisnessCardsFuture.futureMergeCalled = false;  //名寄せを実行
    insert card;
    Test.stopTest();

    System.assert(SB_NameCard_MergeBuisnessCardsFuture.futureMergeCalled);
    //古い名刺はない
    List<NameCard__c> margedList = [Select Id, Name, Saishin__c,memo__c,freehandmemo__c,card_exchange_date__c From NameCard__c Where Parent__c =: card.Id ];
    System.assert(margedList.isEmpty());

    //この名刺が最新
    List<NameCard__c> afterSaishin = [Select Id, Name, Saishin__c,memo__c,freehandmemo__c,card_exchange_date__c From NameCard__c Where Saishin__c = true and Id =: card.Id];
    System.assertEquals(afterSaishin.size(), 1);
  }

  //古い名刺が取り込まれた場合の検証
  public static testMethod void mergeNameCardOldCard() {
    SB_NameCard_MergeBuisnessCardsFuture.futureMergeCalled = true;  //この段階では名寄せ処理を行わない
    //テストデータを作成
    MergeTestDb db = new MergeTestDb();
    db.initialize();
    List<NameCard__c> beforeSaishin = [Select Id, Name, Saishin__c,memo__c,freehandmemo__c From NameCard__c Where Saishin__c = true and Name = '試験 太郎'];
    System.assert(beforeSaishin.size() == 1);

    //トリガを起動させる名刺の初期化
    NameCard__c card = db.makeTestNameCard(30);

    Test.startTest();
    SB_NameCard_MergeBuisnessCardsFuture.futureMergeCalled = false;  //名寄せを実行
    insert card;
    Test.stopTest();

    System.assert(SB_NameCard_MergeBuisnessCardsFuture.futureMergeCalled);
    //最新名刺は変わらない
    List<NameCard__c> afterSaishin = [Select Id, Name, Saishin__c,memo__c,freehandmemo__c From NameCard__c Where Saishin__c = true and Name = '試験 太郎'];
    System.assertEquals(afterSaishin[0].Id,beforeSaishin[0].Id);
    //取り込まれた名刺が最新名刺を参照している
    NameCard__c thisCard = [Select Id, Name, Saishin__c,memo__c,freehandmemo__c,Parent__c From NameCard__c Where Id =: card.Id];
    System.assertEquals(thisCard.Saishin__c,false);
    System.assertEquals(thisCard.Parent__c,beforeSaishin[0].Id);
  }

  //同じ名刺交換日の名刺が複数あった場合の検証
  public static testMethod void mergeNameCardSameDate() {
    SB_NameCard_MergeBuisnessCardsFuture.futureMergeCalled = true;  //この段階では名寄せ処理を行わない
    //テストデータを作成
    MergeTestDb db = new MergeTestDb();
    db.initialize();
    List<NameCard__c> beforeSaishin = [Select Id, Name, Saishin__c,memo__c,freehandmemo__c From NameCard__c Where Saishin__c = true and Name = '試験 太郎'];
    System.assert(beforeSaishin.size() == 1);

    //トリガを起動させる名刺の初期化
    List<NameCard__c> cardList = new List<NameCard__c>();
    cardList.add(db.makeTestNameCard(0));
    cardList.add(db.makeTestNameCard(0));
    cardList.add(db.makeTestNameCard(0));

    Test.startTest();
    SB_NameCard_MergeBuisnessCardsFuture.futureMergeCalled = false;  //名寄せを実行
    insert cardList;
    Test.stopTest();

    System.assert(SB_NameCard_MergeBuisnessCardsFuture.futureMergeCalled);
    //同日内での取り込みのため最新名刺は変わらない
    List<NameCard__c> afterSaishin = [Select Id, Name, Saishin__c,memo__c,freehandmemo__c From NameCard__c Where Saishin__c = true and Name = '試験 太郎'];
    System.assertEquals(afterSaishin[0].Id,beforeSaishin[0].Id);
    //取り込まれた名刺が最新名刺を参照している
    List<NameCard__c> thisCardList = [Select Id, Name, Saishin__c,memo__c,freehandmemo__c,Parent__c From NameCard__c Where Id in: cardList];
    System.assertEquals(thisCardList[0].Saishin__c,false);
    System.assertEquals(thisCardList[1].Saishin__c,false);
    System.assertEquals(thisCardList[2].Saishin__c,false);
    System.assertEquals(thisCardList[0].Parent__c,beforeSaishin[0].Id);
    System.assertEquals(thisCardList[1].Parent__c,beforeSaishin[0].Id);
    System.assertEquals(thisCardList[2].Parent__c,beforeSaishin[0].Id);
  }

  //赤の他人が複数枚
  public static testMethod void mergeNameCardOtherCards() {
    SB_NameCard_MergeBuisnessCardsFuture.futureMergeCalled = true;  //この段階では名寄せ処理を行わない
    //テストデータを作成
    MergeTestDb db = new MergeTestDb();
    db.initialize();

    //トリガを起動させる名刺の初期化
    List<NameCard__c> cardList = new List<NameCard__c>();
    NameCard__c card = db.makeTestNameCard(0);
    card.email__c = 'hoge@hoge.com';
    cardList.add(card);
    card = db.makeTestNameCard(0);
    card.person_name_last__c = '試験姓ほげほげ';
    cardList.add(card);
    card = db.makeTestNameCard(0);
    card.person_name_first__c = '試験名ほげほげ';
    cardList.add(card);

    Test.startTest();
    SB_NameCard_MergeBuisnessCardsFuture.futureMergeCalled = false;  //名寄せを実行
    insert cardList;
    Test.stopTest();

    System.assert(SB_NameCard_MergeBuisnessCardsFuture.futureMergeCalled);
    //全て最新名刺
    List<NameCard__c> afterSaishin = [Select Id, Name, Saishin__c,memo__c,freehandmemo__c From NameCard__c Where Saishin__c = true and Id in:cardList];
    System.assertEquals(afterSaishin.size(),3);
  }

  //Update
  //古い名刺が更新で最新化された場合の検証
  public static testMethod void mergeNameCardFromUpdate() {
    MergeTestDb db = new MergeTestDb();
    db.initialize();
    //現在の名刺リストを取得
    List<NameCard__c> currentNameCardList = [Select Id, Name, Saishin__c,memo__c,freehandmemo__c,card_exchange_date__c From NameCard__c Where Saishin__c = false and tenshokuzumi__c = false and Name = '試験 太郎' order by card_exchange_date__c desc nulls last];
    System.assert(currentNameCardList.size() == 9);

    //トリガを起動させる名刺の初期化
    NameCard__c card = currentNameCardList[0];
    card.card_exchange_date__c = date.today().addDays(30);

    Test.startTest();
    SB_NameCard_MergeBuisnessCardsFuture.futureMergeCalled = false;  //名寄せを実行
    update card;
    Test.stopTest();

    System.assert(SB_NameCard_MergeBuisnessCardsFuture.futureMergeCalled);
    //最新名刺は更新対象の名刺
    List<NameCard__c> afterSaishin = [Select Id, Name, Saishin__c,memo__c,freehandmemo__c From NameCard__c Where Saishin__c = true and Name = '試験 太郎'];
    System.assertEquals(afterSaishin[0].Id,card.Id);
    //それ以外の名刺の最新名刺への参照が更新されている
    List<NameCard__c> oldCards = [Select Id, Name, Saishin__c,memo__c,freehandmemo__c,Parent__c From NameCard__c Where Name = '試験 太郎' and Id <>: card.Id];
    for (NameCard__c oldCard:oldCards){
      System.assertEquals(oldCard.Saishin__c,false);
      System.assertEquals(oldCard.Parent__c,card.Id);
    }
  }

  //Delete(最新名刺)
  public static testMethod void mergeNameCardDeleteNewOne() {
    MergeTestDb db = new MergeTestDb();
    db.initialize();
    //現在の名刺リストを取得
    List<NameCard__c> currentNameCardList = [Select Id, Name, Saishin__c,memo__c,freehandmemo__c From NameCard__c Where tenshokuzumi__c = false and Name = '試験 太郎' order by card_exchange_date__c desc nulls last];
    System.assert(currentNameCardList.size() == 10);
    NameCard__c card = currentNameCardList[0];

    Test.startTest();
    delete card;
    Test.stopTest();

    //最新名刺は2番目に新しい名刺
    List<NameCard__c> afterSaishin = [Select Id, Name, Saishin__c,memo__c,freehandmemo__c From NameCard__c Where Saishin__c = true and Name = '試験 太郎'];
    System.assertEquals(afterSaishin[0].Id,currentNameCardList[1].Id);

    //それ以外の名刺の最新名刺への参照が更新されている
    List<NameCard__c> oldCards = [Select Id, Name, Parent__c, Saishin__c,memo__c,freehandmemo__c From NameCard__c Where Saishin__c = false and Name = '試験 太郎'];
    for (NameCard__c oldCard:oldCards){
      System.assertEquals(oldCard.Parent__c,afterSaishin[0].Id);
    }
  }

  //Delete(それ以外の名刺)
  public static testMethod void mergeNameCardDeleteOldOne() {
    MergeTestDb db = new MergeTestDb();
    db.initialize();
    //現在の名刺リストを取得
    List<NameCard__c> currentNameCardList = [Select Id, Name, Saishin__c,memo__c,freehandmemo__c From NameCard__c Where tenshokuzumi__c = false and Name = '試験 太郎' order by card_exchange_date__c desc nulls last];
    System.assert(currentNameCardList.size() == 10);
    NameCard__c card = currentNameCardList[1];

    Test.startTest();
    delete card;
    Test.stopTest();

    //最新名刺は変わらない
    List<NameCard__c> afterSaishin = [Select Id, Name, Saishin__c,memo__c,freehandmemo__c From NameCard__c Where Saishin__c = true and Name = '試験 太郎'];
    System.assertEquals(afterSaishin[0].Id,currentNameCardList[0].Id);
  }

  //Undelete
  public static testMethod void mergeNameCardUndelete() {
    SB_NameCard_MergeBuisnessCardsFuture.futureMergeCalled = true;  //この段階では名寄せ処理を行わない
    MergeTestDb db = new MergeTestDb();
    db.initialize();
    //現在の名刺リストを取得
    List<NameCard__c> currentSaishin = [Select Id, Name, Saishin__c,memo__c,freehandmemo__c From NameCard__c Where Saishin__c = true and Name = '試験 太郎'];
    System.assert(currentSaishin.size() == 1);
    NameCard__c card = currentSaishin[0];

    Test.startTest();
    delete card;
    SB_NameCard_MergeBuisnessCardsFuture.futureMergeCalled = false;  //名寄せを実行
    undelete card;
    Test.stopTest();

    //結果として最新名刺は変わらない
    List<NameCard__c> afterSaishin = [Select Id, Name, Saishin__c,memo__c,freehandmemo__c From NameCard__c Where Saishin__c = true and Name = '試験 太郎'];
    System.assertEquals(afterSaishin[0].Id,currentSaishin[0].Id);

    //古い名刺の参照も直っていることを確認
    List<NameCard__c> oldCards = [Select Id, Name, Saishin__c,Parent__c,memo__c,freehandmemo__c From NameCard__c Where Saishin__c = false and Name = '試験 太郎'];
    for (NameCard__c oldCard:oldCards){
      System.assertEquals(oldCard.Parent__c,currentSaishin[0].Id);
    }

  }

  // 名寄せ結果検証
  private static void verifyMargeResult(List<NameCard__c> beforeSaishin,NameCard__c card){
    //最新名刺判断
    List<NameCard__c> afterSaishin = [Select Id, Name, Saishin__c,memo__c,freehandmemo__c,card_exchange_date__c From NameCard__c Where Saishin__c = true and Id =: card.Id];
    System.assertEquals(afterSaishin.size(), 1);

    //古い名刺の洗い替え
    List<NameCard__c> margedList = [Select Id, Name, Saishin__c,memo__c,freehandmemo__c,card_exchange_date__c From NameCard__c Where Parent__c =: card.Id ];
    System.assertEquals(margedList.size(), 11);
    List<NameCard__c> oldCards = [Select Id, Name, Saishin__c,Parent__c From NameCard__c Where Id = :beforeSaishin[0].Id];
    System.assertEquals(oldCards[0].Saishin__c, false);
    System.assertEquals(oldCards[0].Parent__c, card.Id);

    //転職済み名刺の親の洗い替え
    List<NameCard__c> tenshokuCards = [Select Id, Name, Saishin__c,Parent__c From NameCard__c Where tenshokuzumi__c = true and tenshokugonomeishi__c =:beforeSaishin[0].Id ];
    System.assertEquals(tenshokuCards[0].Parent__c, card.Id);

    //値引継ぎ
    List<NameCardSettingValues__c> saishinInheritFields = [Select Id, Name, TextValue01__c From NameCardSettingValues__c Where Type__c = 'SaishinInherit'];
    System.assertEquals(afterSaishin[0].get('memo__c'), beforeSaishin[0].get('memo__c'));
    System.assertEquals(afterSaishin[0].get('freehandmemo__c'), beforeSaishin[0].get('freehandmemo__c'));
  }

}