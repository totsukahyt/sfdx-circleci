/*	$Id$	*/

/*
 * Copyright (c) 2014 SunBridge Inc.
 *
 * 日経テレコン人事異動情報 WSI API 削除バッチ
 * @Version 1  2017.10.xx  with sharing, CRUD  v1.21 for code scan
 */

global with sharing class SB_NameCard_JinjiIdoDeleteBatch implements Database.Batchable<SObject> {
	global Database.QueryLocator start(Database.BatchableContext bc) {
		String soql = 'SELECT Id FROM JinjiIdo__c LIMIT 1';
		return Database.getQueryLocator(soql);
	}

	global void execute(Database.BatchableContext bc, List<JinjiIdo__c> cipList) {}

	global void finish(Database.BatchableContext bc) {}
}