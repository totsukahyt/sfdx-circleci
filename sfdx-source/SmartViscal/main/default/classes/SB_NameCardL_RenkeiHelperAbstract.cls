/**
 *
 * SB_NameCardL_RenkeiHelperAbstract
 *  自動連携プロセスの処理クラスの抽象クラス  
 *  基本 v2.0までは、 SB_NameCard_RegistProcessor を 自動連携、UIの取引先登録 個別、一括 でつかってたけそ、 
 *    lx2.0 から 基本から Lead拡張の自動連携処理を呼ぶためだけように。でも 形だけ
 *
 * Copyright (C) 2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      lx v2.0  
 *
 **/
public abstract class SB_NameCardL_RenkeiHelperAbstract {
  public abstract void init(List<SmartViscaf__NameCard__c> cards);
  public virtual void run() {
    // accountProc();
    // contactProc();
    // leadProc();
    // cardProc();
  }
  // protected abstract void accountProc();
  // protected abstract void contactProc();
  // protected virtual void leadProc() {}
  // protected abstract void cardProc();
}