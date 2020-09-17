/**
 *
 * SB_NameCard_SettingsController
 * vfページLightning表示用
 *  Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author gao
 *  @Version 1      2017.02.20
 *
 **/


public with sharing class SB_NameCard_SettingsController {
    public String settingname{get;set;}
    public String appname{get;set;}
    public SB_NameCard_SettingsController() {
        String pre = SB_NameCard_Util.getNamespacePrefix();
        Boolean havesp = String.isNotBlank(pre);
        this.appname = havesp ? pre + ':SB_NC_CardApp' : 'c:SB_NC_CardApp';
        this.settingname = havesp ? pre + ':SB_NameCard_Settings' : 'c:SB_NameCard_Settings';
    }
}