/**
 *
 * SB_NC_CardOwnersSortOrderPickListTest
 *  SB_NC_CardOwnersSortOrderPickList のテストクラス
 *
 *  @author sawano
 *  @Version1 v2.4 2019.06.xx SV_DEV-1593 LEX画面の名刺詳細から「同じ名刺を持つユーザ」を確認できるようにしてほしい
 *
 **/
@isTest
private class SB_NC_CardOwnersSortOrderPickListTest {

  @isTest
  static void test_SB_NC_CardOwnersSortOrderPickList() {
    SB_NC_CardOwnersSortOrderPickList pickList = new SB_NC_CardOwnersSortOrderPickList();
    System.assertEquals('asc', pickList.getDefaultValue().getValue());
    VisualEditor.DynamicPickListRows opts = pickList.getValues();
    System.assertEquals(2, opts.size());
  }

}