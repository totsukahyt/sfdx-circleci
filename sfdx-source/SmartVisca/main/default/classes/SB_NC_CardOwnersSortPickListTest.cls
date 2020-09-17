/**
 *
 * SB_NC_CardOwnersSortPickListTest
 *  SB_NC_CardOwnersSortPickList のテストクラス
 *
 *  @author sawano
 *  @Version1 v2.4 2019.06.xx SV_DEV-1593 LEX画面の名刺詳細から「同じ名刺を持つユーザ」を確認できるようにしてほしい
 *
 **/
@isTest
private class SB_NC_CardOwnersSortPickListTest {

  @isTest
  static void test_SB_NC_CardOwnersSortPickList() {
    SB_NC_CardOwnersSortPickList pickList = new SB_NC_CardOwnersSortPickList();
    System.assertEquals('name', pickList.getDefaultValue().getValue());
    VisualEditor.DynamicPickListRows opts = pickList.getValues();
    System.assert(opts.size() > 0);
  }

}