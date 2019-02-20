/**
 *
 *    SB_NameCardL_DMLProcessor
 * 基本の SB_NameCard_DMLProcessor を持ってきた
 *  アカウント、コンタクト、リード レコードのDMLを処理のクラス
 *
 * Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2017.04.xx
 *  @Version 2      2017.09.xx v1.21
 *
 *  @Version lx2.0      2018.06.xx v1.21
 *
 **/
public with sharing class SB_NameCardL_DMLProcessor {

  /***
  * 名刺に関連して レコードを更新する DML を処理するクラスの基底
  ***/
  public abstract class DmlProcessor {
    public Boolean success { get; private set; }
    public Boolean haveSObjects() { return !objs.isEmpty(); }
    //public Boolean allowRetry { get; private set; }
    protected Boolean allowSave;
    protected SB_NameCard_LeadSaveResult saveResult;
    protected List<SB_NameCardL_RegistCardHolder.CardHolder> holders;    //  このDMLで 処理する レコードに元ネタの名刺 CardHolder
    protected List<SObject> objs;   // DMLでバルク処理する レコード
    protected SObjectType otype;
    protected String msgForm;

    // allowSave   true : 重複警告は無視して保存
    public DmlProcessor(SObjectType otype, Boolean allowSave) {
      this.otype = otype;
      this.allowSave = allowSave;
      this.saveResult = new SB_NameCard_LeadSaveResult();
      this.objs = new List<SObject>();

      this.holders = new List<SB_NameCardL_RegistCardHolder.CardHolder>();
      this.msgForm = '[{0} {1}]';

    }

    public void addCardHolder(SB_NameCardL_RegistCardHolder.CardHolder holder) {
      this.holders.add(holder);
      SObject obj = holder.getSObject(this.otype);
      System.debug('obj.Id: ' + obj.Id);
      this.objs.add(obj);
    }

    protected abstract void setErrors();

    public void dbCreate() {
      System.assertEquals(false, this.objs.isEmpty());
      this.msgForm = String.format(this.msgForm, new String[] { otype.getDescribe().getName(), ' create: {0}' });
      Database.DMLOptions dmlOptions = new Database.DMLOptions();
      dmlOptions.allowFieldTruncation = true;     // 文字列が長かったら詰める。
      dmlOptions.DuplicateRuleHeader.allowSave = this.allowSave;
      dmlOptions.DuplicateRuleHeader.runAsCurrentUser = true;
      dmlOptions.optAllOrNone = false;        // 部分的な完了を許可。一部にエラーがあっても処理を完結させる。
      List<Database.SaveResult> results = null;
      results = SmartViscaf.SB_NameCard_CrudFls.screate(this.objs, dmlOptions);
      this.saveResult.putSaveResults(results);
      this.success = !saveResult.isError();
      if (saveResult.isError()) {
        setErrors();
      }
    }

    public void dbUpdate() {
      System.assertEquals(false, this.objs.isEmpty());
      this.msgForm = String.format(this.msgForm, new String[] { otype.getDescribe().getName(), ' update: {0}' });
      Database.DMLOptions dmlOptions = new Database.DMLOptions();
      dmlOptions.allowFieldTruncation = true;     // 文字列が長かったら詰める。
      dmlOptions.DuplicateRuleHeader.allowSave = this.allowSave;
      dmlOptions.DuplicateRuleHeader.runAsCurrentUser = true;
      dmlOptions.optAllOrNone = false;        // 部分的な完了を許可。一部にエラーがあっても処理を完結させる。
      List<Database.SaveResult> results = null;
      results = SmartViscaf.SB_NameCard_CrudFls.supdate(this.objs, dmlOptions);
      this.saveResult.putSaveResults(results);
      this.success = !saveResult.isError();
      if (saveResult.isError()) {
        setErrors();
      }
    }
  }


  /***
  * UI をとうして 取引先登録するとき用
  ***/
  public class UiDmlProcessor extends DmlProcessor {

    public Boolean allowRetry { get; private set; }
    public List<String> messages { get; private set; }
    public Map<Id, SB_NameCard_LeadSaveResult.DbErrorHolder> id2dbError;

    public UiDmlProcessor(SObjectType otype, Boolean allowSave) {
      super(otype, allowSave);

      this.allowRetry = false;
      this.messages = new List<String>();
      this.id2dbError = new Map<Id, SB_NameCard_LeadSaveResult.DbErrorHolder>();
    }

    protected override void setErrors() {
      System.assert(saveResult.isError());
      Map<Integer, SB_NameCard_LeadSaveResult.DbErrorHolder> dbErrorMap = saveResult.getDbErrorHolders();
      System.assert(dbErrorMap.size() == objs.size());
      Integer size = dbErrorMap.size();
      Integer paddLen = String.valueOf(size+1).length();
      for(Integer n=0; n < size; n++) {
        //Id cardId = this.cardIds.get(n);
        //Integer originalOrder = this.originalOrders.get(n);
        SB_NameCard_LeadSaveResult.DbErrorHolder error = dbErrorMap.get(n);
        if (error == null) continue;        // エラーが無い行
        SB_NameCardL_RegistCardHolder.CardHolder holder = this.holders.get(n);
        this.id2dbError.put(holder.card.Id, error);
        //this.order2dbError.put(originalOrder, error);
        String rowNum = String.valueOf(n+1).leftPad(paddLen);
        String t = String.isNotBlank(error.text) ? error.text : '';
        this.messages.add(String.format('{0}行目: {1}', new String[]{ rowNum, t }));  // エラー内容表示用テキスト
      }
      this.allowRetry = saveResult.isAllowSave();
    }

  } // class UiDmlProcessor

  /***
  * トリガで（自動で） 取引先登録するとき用
  ***/
  public class AutoDmlProcessor extends DmlProcessor {

    public AutoDmlProcessor(SObjectType otype, Boolean allowSave) {
      super(otype, allowSave);
    }

    protected override void setErrors() {
      System.assert(saveResult.isError());
      Map<Integer, SB_NameCard_LeadSaveResult.DbErrorHolder> dbErrorMap = saveResult.getDbErrorHolders();
      System.assert(dbErrorMap.size() == objs.size());
      Integer size = dbErrorMap.size();
      Integer paddLen = String.valueOf(size+1).length();
      for(Integer n=0; n < size; n++) {
        SB_NameCard_LeadSaveResult.DbErrorHolder error = dbErrorMap.get(n);
        if (error == null || String.isBlank(error.text)) continue;        // エラーが無い行
        SB_NameCardL_RegistCardHolder.CardHolder holder = this.holders.get(n);
        holder.putMessage(String.format(this.msgForm, new String[] { error.text }));   // 2017.04.xx
        holder.putMessage(error.dump);   // v1.21 2017.09.xx
      }
    }


  } // class DmlProcessor
}