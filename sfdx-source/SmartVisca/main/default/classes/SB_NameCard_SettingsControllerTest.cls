/**
 *
 * SB_NameCard_SettingsControllerTest
 * SB_NameCard_SettingsControllerテストクラスタ
 *  Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author gao
 *  @Version 1      2017.02.20
 *
 **/


@isTest
private class SB_NameCard_SettingsControllerTest {
    // 環境によって(ネームスペース)Lightningコンポネートの使用テスト
    @isTest static void testGetUrl() {
        SB_NameCard_SettingsController con = new SB_NameCard_SettingsController();
        String pre = SB_NameCard_Util.getNamespacePrefix();
        Boolean havesp = String.isNotBlank(pre);
        System.assertEquals(con.appname,havesp ? pre + ':SB_NC_CardApp' : 'c:SB_NC_CardApp');
        System.assertEquals(con.settingname,havesp ? pre + ':SB_NameCard_Settings' : 'c:SB_NameCard_Settings');
    }

}