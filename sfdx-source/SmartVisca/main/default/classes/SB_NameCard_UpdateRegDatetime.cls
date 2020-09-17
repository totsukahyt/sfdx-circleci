/**
 *
 * 名刺の追加、更新時、項目「取引先」、「リード」に値がセットされていたら、取引先取込日時 リード取込日時に現在時刻をセットします。
 *		従来 SB_NameCard_BfInsUpdOnNameCard.trigger でやってた処理
 *
 * Copyright (C) 2012-2014 SunBridge Inc. All Rights Reserved.
 *
 *	@author sawano
 *	History :
 *		SB_NameCard_BfInsUpdOnNameCard.trigger の移植
 *	@Version 2		2014.4.2x
 **/
public with sharing class SB_NameCard_UpdateRegDatetime {

	public void run(NameCard__c[] newObjs, map<Id, NameCard__c> oldMap) {
		for (NameCard__c tmpNc : newObjs) {
			NameCard__c prvNc = oldMap == null ? null : oldMap.get(tmpNc.Id);
			if (tmpNc.account__c != null &&
				(prvNc ==null || prvNc.account__c != tmpNc.account__c)) { // 最新か、変更のあったとき
				tmpNc.accountRegDateTime__c = datetime.now();
			}
			if (tmpNc.lead__c != null &&
				(prvNc ==null || prvNc.lead__c != tmpNc.lead__c)) {	// 最新か、変更のあったとき
				tmpNc.leadRegDateTime__c = datetime.now();
			}
		}
	}
}