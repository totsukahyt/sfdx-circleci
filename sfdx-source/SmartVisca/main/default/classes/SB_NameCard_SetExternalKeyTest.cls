/**
 *
 * 名刺オブジェクトのトリガ でやっている 外部キーをセットしているのをテスト
 *
 *	@author sawano
 *	@Version 2		2014.4.2x
 *
 */
@isTest
private class SB_NameCard_SetExternalKeyTest {

	public class SetExternalKeyTestDb extends SB_NameCard_TestDB {

	    public override void initialize() {
	        // SmartVisca設定
	        initializeSmartViscaConfig();
	        initializeUser();
	        if (listUser.isEmpty() == false)
	            insert listUser;
	        initializeNameCard();
	        if (listCard.isEmpty() == false)
	            insert listCard;
	        if (svConfig !=null) {
	        	if (svConfig.id == null) {
					insert svConfig;
	        	}
	        	else {
					update svConfig;
	        	}
	        }
	    }
	}

	private static testMethod void testSetExternalKey() {
		Test.startTest();
		SetExternalKeyTestDb db = new SetExternalKeyTestDb();
		db.initialize();

		list<NameCard__c> cards = [select Id, Name, key__c, person_name_last__c, person_name_first__c, email__c
				from  NameCard__c];
		for (NameCard__c nc : cards) {
			system.assertEquals(nc.person_name_last__c + ' ' + nc.person_name_first__c + '&' + nc.email__c, nc.key__c);
		}

      	Test.stopTest();
	}
}