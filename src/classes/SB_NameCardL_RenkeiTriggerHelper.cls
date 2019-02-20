/**
 * SB_NameCardL_RenkeiTriggerHelper
 *  基本の SB_NameCard_RenkeiTriggerHelper の改造
 *   リード
 *
 *  Copyright (C) 2017-2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1.22      2018.01.xx 
 *  SB_NameCard_RenkeiTriggerHelper がベース
 *  lx 2.0 2018.06.xx 基底クラスの global メソッドがたりなかったので、一旦 スルーする形で
 *
 **/
public with sharing class SB_NameCardL_RenkeiTriggerHelper extends SmartViscaf.SB_NameCard_RegistProcessor {

  public override void run() {}
  public override void accountProc() {} 
  public override void contactProc() {}
      
}