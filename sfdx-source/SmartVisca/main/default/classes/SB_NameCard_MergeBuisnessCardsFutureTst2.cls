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
public with sharing class SB_NameCard_MergeBuisnessCardsFutureTst2 {
  public static String NAYOSE_SETTING = 'mobile__c;tel1__c;web_url1__c'; //名寄せ条件

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
        ba.NayoseJyoken__c = NAYOSE_SETTING; //名寄せ条件
      }
      Update basics;
    }

    // 名刺データ作成
    //  名寄せ済みを想定したデータを作成する
    public void initializeTestData() {
      // 親データの作成
      List<NameCard__c> parentList = new List<NameCard__c>();
      
      NameCard__c nc1 = makeTestNameCard(1);
      nc1.mobile__c = '090-1111-1111';
      nc1.tel1__c= '03-1111-1111';
      nc1.Saishin__c = true;
      parentList.add(nc1);

      NameCard__c nc2 = makeTestNameCard2(1);
      nc2.tel1__c= '03-2222-2222';

      nc2.Saishin__c = true;
      parentList.add(nc2);

      insert parentList;

      // 子データの作成
      List<NameCard__c> childList = new List<NameCard__c>();

      NameCard__c nc11 = makeTestNameCard(2);
      nc11.tel1__c= '03-1111-1111';
      nc11.Parent__c = parentList[0].Id;
      childList.add(nc11);

      NameCard__c nc12 = makeTestNameCard(3);
      nc12.tel1__c= '03-1111-1111';
      nc12.Parent__c = parentList[0].Id;
      childList.add(nc12);

      NameCard__c nc13 = makeTestNameCard(4);
      nc13.tel1__c= '03-1111-1111';
      nc13.Parent__c = parentList[0].Id;
      childList.add(nc13);


      NameCard__c nc21 = makeTestNameCard2(2);
      nc21.tel1__c= '03-2222-2222';
      nc21.Parent__c = parentList[1].Id;
      childList.add(nc21);

      NameCard__c nc22 = makeTestNameCard2(3);
      nc22.tel1__c= '03-2222-2222';
      nc22.Parent__c = parentList[1].Id;
      childList.add(nc22);

      NameCard__c nc23 = makeTestNameCard2(4);
      nc23.tel1__c= '03-2222-2222';
      nc23.Parent__c = parentList[1].Id;
      nc23.web_url1__c = 'http://www.nayose.com';
      childList.add(nc23);

      insert childList;
    }

    public NameCard__c makeTestNameCard(Integer param){
      NameCard__c nc = new NameCard__c(
                company_name__c= '株式会社マージテスト'
              , name= '試験 太郎'
              , person_name_last__c= '試験'
              , person_name_first__c= '太郎'
              , email__c= 'test@marge.com'
              , card_exchange_date__c = date.today().addDays( (param * -1) )
              , delivery_type__c='2'
              , OwnerId = listUser[0].Id
      );
      return nc;
    }

    public NameCard__c makeTestNameCard2(Integer param){
      NameCard__c nc = new NameCard__c(
                company_name__c= '株式会社名寄せ試験'
              , name= 'テスト 二郎'
              , person_name_last__c= 'テスト'
              , person_name_first__c= '二郎'
              , card_exchange_date__c = date.today().addDays( (param * -1) )
              , delivery_type__c='2'
              , OwnerId = listUser[0].Id
      );
      return nc;
    }
  }

  public static testMethod void mergeNameCardHasChildCards() {
    SB_NameCard_MergeBuisnessCardsFuture.futureMergeCalled = true;  //この段階では名寄せ処理を行わない
    //テストデータを作成
    MergeTestDb db = new MergeTestDb();
    db.initialize();
    List<NameCard__c> beforeSaishin = [Select Id, Name, Saishin__c,memo__c,freehandmemo__c From NameCard__c Where Saishin__c = true and Name = '試験 太郎'];
    System.assert(beforeSaishin.size() == 1);

    //トリガを起動させる名刺の初期化
    NameCard__c card = db.makeTestNameCard(-1);
    card.mobile__c = '090-1111-1111';

    Test.startTest();
    SB_NameCard_MergeBuisnessCardsFuture.futureMergeCalled = false;  //名寄せを実行
    insert card;
    Test.stopTest();

    System.assert(SB_NameCard_MergeBuisnessCardsFuture.futureMergeCalled);
    verifyMargeResult(beforeSaishin,card);
  }

  public static testMethod void mergeNameCardHasParentCards() {
    SB_NameCard_MergeBuisnessCardsFuture.futureMergeCalled = true;  //この段階では名寄せ処理を行わない
    //テストデータを作成
    MergeTestDb db = new MergeTestDb();
    db.initialize();
    List<NameCard__c> beforeSaishin = [Select Id, Name, Saishin__c,memo__c,freehandmemo__c From NameCard__c Where Saishin__c = true and Name = 'テスト 二郎'];
    System.assert(beforeSaishin.size() == 1);

    //トリガを起動させる名刺の初期化
    NameCard__c card = db.makeTestNameCard2(-1);
    card.web_url1__c = 'http://www.nayose.com';

    Test.startTest();
    SB_NameCard_MergeBuisnessCardsFuture.futureMergeCalled = false;  //名寄せを実行
    insert card;
    Test.stopTest();

    System.assert(SB_NameCard_MergeBuisnessCardsFuture.futureMergeCalled);
    verifyMargeResult(beforeSaishin,card);
  }

  // 名寄せ結果検証
  private static void verifyMargeResult(List<NameCard__c> beforeSaishin,NameCard__c card){
    //最新名刺判断
    List<NameCard__c> afterSaishin = [Select Id, Name, Saishin__c,memo__c,freehandmemo__c,card_exchange_date__c From NameCard__c Where Saishin__c = true and Id =: card.Id];
    System.assertEquals(afterSaishin.size(), 1);

    //古い名刺の洗い替え
    List<NameCard__c> margedList = [Select Id, Name, Saishin__c,memo__c,freehandmemo__c,card_exchange_date__c From NameCard__c Where Parent__c =: card.Id ];
    System.assertEquals(margedList.size(), 4);
    List<NameCard__c> oldCards = [Select Id, Name, Saishin__c,Parent__c From NameCard__c Where Id = :beforeSaishin[0].Id];
    System.assertEquals(oldCards[0].Saishin__c, false);
    System.assertEquals(oldCards[0].Parent__c, card.Id);
  }

}