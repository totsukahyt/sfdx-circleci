/*
 * Copyright (c) 2014-2018 SunBridge Inc.
 *
 * 日経テレコン人事異動情報 WSI API メール通知バッチ
 *
 * @Version 1  kou 2017.10.xx  with sharing, FLS  v1.21 for code scan
 * v2.0.2   2018.08.xx sawano SV_DEV-1095 [人事異動情報] 「人事異動情報メール通知」同一会社のメール通知で本文に会社名が表示されない場合がある。
 *                ORDER BY で OwnerId を1番目にして、ユーザ単位にメール本文作成
 *          同一ユーザへのメール作成がチャンクをまたがったときへの対処 → チャンクの最後に作ったメールレコード を覚えておくために Database.Stateful にします。
 *          → パッチでは Interface を追加できなかった。リリース版パッケージのアップロードでエラー
 *          → クエリして、今回の最初のユーザが前回最後のユーザかしらべる。レコードを探す。
 *
 */

global with sharing class SB_NameCard_JinjiIdoEmailNoticeBatch implements Database.Batchable<SObject>, Schedulable
{

  global Database.QueryLocator start(Database.BatchableContext bc) {
		String soql = 'SELECT Id FROM JinjiIdo__c LIMIT 1';
		return Database.getQueryLocator(soql);
	}

  global void execute(Database.BatchableContext bc, List<JinjiIdo__c> jiList) {}

  global void finish(Database.BatchableContext bc) {}

  global void execute(SchedulableContext sc)
  {
    SB_NameCard_JinjiIdoEmailNoticeBatch b = new SB_NameCard_JinjiIdoEmailNoticeBatch();
    Database.executeBatch(b);
  }
}