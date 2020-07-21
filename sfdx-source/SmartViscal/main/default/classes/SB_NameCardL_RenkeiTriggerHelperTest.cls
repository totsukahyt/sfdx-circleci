/**
 *
 *  SB_NameCardL_RenkeiTriggerHelperTest
 *    SB_NameCardL_RenkeiTriggerHelper のテストクラス
 *
 * Copyright (C) 2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  lx 2.0    2018.06.xx
 *
 **/
@isTest
private class SB_NameCardL_RenkeiTriggerHelperTest
{
  @isTest
  static void test_instance()
  {
    SB_NameCardL_RenkeiTriggerHelper instance = new SB_NameCardL_RenkeiTriggerHelper();
    System.assert(instance != null);
    instance.run();
    instance.accountProc();
    instance.contactProc();
    System.assert(instance != null);
  }
}