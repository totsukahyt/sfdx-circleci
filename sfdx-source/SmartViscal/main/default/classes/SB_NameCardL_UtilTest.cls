@isTest
private class SB_NameCardL_UtilTest
{


  // getManagedObjectName  2017.01.xx
  @isTest
  static void test_getManagedObjectName() {
    System.assertEquals('Account',  SB_NameCardL_Util.getManagedObjectName('Account'));
    String ns = SB_NameCardL_Util.getNamespacePrefix_x();
    String nc = 'NameCard__c';
    System.assertEquals(ns+nc,  SB_NameCardL_Util.getManagedObjectName(nc));
  }

  // escapeSOSLYoyakugo のテスト 2016.10.xx
  @isTest
  static void testEscapeSOSLYoyakugo() {
    String nomal = SB_NameCardL_Util.escapeSOSLYoyakugo('ABC');
    String yoyakugo = '?&|!{}[]()^~*:"\'+-\\';
    String esc = SB_NameCardL_Util.escapeSOSLYoyakugo(yoyakugo);
    System.assertNotEquals(yoyakugo.length(), esc.length());
  }
}