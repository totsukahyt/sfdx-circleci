/*	$Id$	*/

/*
 * Copyright (c) 2014 SunBridge Inc.
 *
 * 日経テレコン人事異動情報 WSI API 人事異動情報取得日設定バッチ
 * @Version 1  2017.10.xx  with sharing, FLS  v1.21 for code scan
 */

global with sharing class SB_NameCard_JinjiIdoFinishBatch implements Database.Batchable<SObject>
{
	global Database.QueryLocator start(Database.BatchableContext bc)
	{
		String soql = 'SELECT Id FROM NameCard__c LIMIT 1';
		return Database.getQueryLocator(soql);
	}

	global void execute(Database.BatchableContext bc, List<NameCard__c> ncList) {}

	global void finish(Database.BatchableContext bc) {}
}