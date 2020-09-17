/*	$Id: SB_NameCard_HistoryTest.cls 22 2014-07-02 05:32:59Z ume $	*/

/*
 * Copyright (c) 2014 SunBridge Inc.
 */

@isTest
private class SB_NameCard_HistoryTest
{
	private static testMethod void test()
	{
 		Test.startTest();
		SB_NameCard_TestDB db = new SB_NameCard_TestDB();
		db.initialize();

		// 名刺作成(一次納品)
		NameCard__c nc = new NameCard__c();
		nc.Name = '姓 名';
		nc.card_id__c = 'ABCDEFGH1234567890';
		nc.person_name_last__c = '姓';
		nc.person_name_first__c = '名';
		nc.company_name__c = '会社名';
		nc.delivery_type__c = '1';
		Database.insert(nc);

		nc = [SELECT Id, CreatedDate FROM NameCard__c WHERE Id = :nc.Id];
		NameCardHistory__c nch = [SELECT Id, primary_delivery_time__c, secondary_delivery_time__c, delete_time__c, error_code__c FROM NameCardHistory__c WHERE NameCard__c = :nc.Id];

		System.assertEquals(nc.CreatedDate, nch.primary_delivery_time__c, '一次納品日時');
		System.assertEquals(null, nch.secondary_delivery_time__c, '二次納品日時');
		System.assertEquals(null, nch.delete_time__c, '削除日時');
		System.assertEquals(null, nch.error_code__c, 'エラーコード');

		// 名刺更新(二次納品)
		nc.delivery_type__c = '2';
		Database.update(nc);

		nc = [SELECT Id, CreatedDate, LastModifiedDate FROM NameCard__c WHERE Id = :nc.Id];
		nch = [SELECT Id, primary_delivery_time__c, secondary_delivery_time__c, delete_time__c, error_code__c FROM NameCardHistory__c WHERE NameCard__c = :nc.Id];

		System.assertEquals(nc.CreatedDate, nch.primary_delivery_time__c, '一次納品日時');
		System.assertEquals(nc.LastModifiedDate, nch.secondary_delivery_time__c, '二次納品日時');
		System.assertEquals(null, nch.delete_time__c, '削除日時');
		System.assertEquals(null, nch.error_code__c, 'エラーコード');

		// 名刺更新(一次納品)
		nc.delivery_type__c = '1';
		Database.update(nc);

		nc = [SELECT Id, CreatedDate, LastModifiedDate FROM NameCard__c WHERE Id = :nc.Id];
		nch = [SELECT Id, primary_delivery_time__c, secondary_delivery_time__c, delete_time__c, error_code__c FROM NameCardHistory__c WHERE NameCard__c = :nc.Id];

		System.assertEquals(nc.LastModifiedDate, nch.primary_delivery_time__c, '一次納品日時');
		System.assertEquals(null, nch.delete_time__c, '削除日時');
		System.assertEquals(null, nch.error_code__c, 'エラーコード');

		// 名刺更新(二次納品 エラーコード1)
		nc.delivery_type__c = '2';
		nc.error__c = 'error_code: 1\nエラー\nエラー';
		Database.update(nc);

		nc = [SELECT Id, CreatedDate, LastModifiedDate FROM NameCard__c WHERE Id = :nc.Id];
		nch = [SELECT Id, primary_delivery_time__c, secondary_delivery_time__c, delete_time__c, error_code__c FROM NameCardHistory__c WHERE NameCard__c = :nc.Id];

		System.assertEquals(nc.LastModifiedDate, nch.secondary_delivery_time__c, '二次納品日時');
		System.assertEquals(null, nch.delete_time__c, '削除日時');
		System.assertEquals('1', nch.error_code__c, 'エラーコード');

		// 名刺削除
		Database.delete(nc.Id);

		nch = [SELECT Id, primary_delivery_time__c, secondary_delivery_time__c, delete_time__c, error_code__c FROM NameCardHistory__c WHERE NameCard__c = :nc.Id];

		System.assertEquals(nc.LastModifiedDate, nch.secondary_delivery_time__c, '二次納品日時');
		System.assertNotEquals(null, nch.delete_time__c, '削除日時');
		System.assertEquals('1', nch.error_code__c, 'エラーコード');

		// 名刺復元
		Database.undelete(nc.Id);

		nch = [SELECT Id, primary_delivery_time__c, secondary_delivery_time__c, delete_time__c, error_code__c FROM NameCardHistory__c WHERE NameCard__c = :nc.Id];

		System.assertEquals(nc.LastModifiedDate, nch.secondary_delivery_time__c, '二次納品日時');
		System.assertEquals(null, nch.delete_time__c, '削除日時');
		System.assertEquals('1', nch.error_code__c, 'エラーコード');

		// 名刺履歴削除
		Database.delete(nch.Id);

		// 名刺更新(一次納品)
		nc.delivery_type__c = '1';
		Database.update(nc);

		nc = [SELECT Id, CreatedDate, LastModifiedDate FROM NameCard__c WHERE Id = :nc.Id];
		nch = [SELECT Id, primary_delivery_time__c, secondary_delivery_time__c, delete_time__c, error_code__c FROM NameCardHistory__c WHERE NameCard__c = :nc.Id];

		System.assertEquals(nc.LastModifiedDate, nch.primary_delivery_time__c, '一次納品日時');
		System.assertEquals(null, nch.delete_time__c, '削除日時');
		System.assertEquals(null, nch.error_code__c, 'エラーコード');

		// 名刺履歴削除
		Database.delete(nch.Id);

		// 名刺更新(二次納品 エラーコード3)
		nc.delivery_type__c = '2';
		nc.error__c = 'error_code: 3\nエラー';
		Database.update(nc);

		nc = [SELECT Id, CreatedDate, LastModifiedDate FROM NameCard__c WHERE Id = :nc.Id];
		nch = [SELECT Id, primary_delivery_time__c, secondary_delivery_time__c, delete_time__c, error_code__c FROM NameCardHistory__c WHERE NameCard__c = :nc.Id];

		System.assertEquals(nc.LastModifiedDate, nch.secondary_delivery_time__c, '二次納品日時');
		System.assertEquals(null, nch.delete_time__c, '削除日時');
		System.assertEquals('3', nch.error_code__c, 'エラーコード');
	}
}