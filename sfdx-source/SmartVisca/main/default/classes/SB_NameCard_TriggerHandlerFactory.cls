/**
 *
 *  SB_NameCard_TriggerHandlerFactory
 *   トリガーハンドラを管理するクラス
 *
 *  Copyright (C) 2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1.22      2018.03.xx 今は外部パッケージ リード拡張パッケージの ハンドラクラスだけが範疇
 *
 **/
public with sharing class SB_NameCard_TriggerHandlerFactory {
  public class SB_NameCard_TriggerHandlerFactoryException extends Exception {}

  private static Map<String, SB_NameCard_TriggerHandlerAbstract> hadlers = new Map<String, SB_NameCard_TriggerHandlerAbstract>();

  public static SB_NameCard_TriggerHandlerAbstract getInstance(String ns, String cn) {
    SB_NameCard_TriggerHandlerAbstract result;
    try {
      if (hadlers.containsKey(cn)) {
        result = hadlers.get(cn);
      }
      else {
        Type extClass;
        if (SB_NameCard_Util.isEnableLeadExt112()) {            // リード拡張パッケージ 1.12 以降がインストールされている) {
          //
          extClass = Type.forName(ns, cn);
        }
        else {
          // 基本パッケージしかない。テスト中とか
          extClass = Type.forName(null, 'SB_NameCard_TriggerHandlerDummy');
        }
        result = (SB_NameCard_TriggerHandlerAbstract)extClass.newInstance();
        hadlers.put(cn, result);
      }
    }
    catch(Exception e) {
      throw new SB_NameCard_TriggerHandlerFactoryException('Invalid Lead Extention Package Environment: ' + e.getMessage());
    }
    return result;
  }

}