/**
 *
 *    SB_NameCard_LeadSaveResult
 *  基本の SB_NameCard_SaveResult のそのまま
 *  SB_NameCard_SaveResult Database.insert Database.update の戻り値 SaveResult から エラーメッセージとかを抽出するクラス
 *    バルク処理対応、重複エラー対応
 *
 *    公開されてるメソッドを使ってください。
 *      putSaveResults で エラー情報sを渡して
 *      getSaveErrorInfo 配列の位置を引数にして  DbErrorHolder あるいは DuplicateErrorHolder を得て メッセージ msg とかを処理してください。
 *
 *   ※マニュアルより
 *    SaveResult 配列の各要素は、データベースメソッドのsObject[] パラメータとして渡された sObject 配列に対応します。 + 順番も保証されてる。
 *
 *  Copyright (C) 2016 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2016.10.xx
 *  @Version 2      2017.09.xx v1.21
 *
 *  @lx 2.0     2018.06.xx 
 *
 **/
public with sharing class SB_NameCard_LeadSaveResult {
  private static final String ERROR_FORMAT = '{0}{1}';
  private static final String BASE_URL = URL.getSalesforceBaseUrl().toExternalForm();
  //private static final String DUPLICATE_ATAG = System.Label.SB_NC_Repeat + '{0} : <a target="_blank" href="' + BASE_URL + '/{1}">{2}</a>';  // オブジェクト名 ID, NAME
  private static final String DUPLICATE_ATAG = '{0} : <a target="_blank" href="' + BASE_URL + '/{1}">{2}</a>';  // オブジェクト名 ID, NAME
  private static final String DUPLICATE_MSG = '{0} by {1} : {2}';  //


  // DML結果のエラーメッセージの取得 重複エラーじゃないとき用
  @TestVisible
  private static String getDMLErrorMsg(Database.Error[] errs) {
    String result ='';
    for (Database.Error err : errs) {
      if (String.isNotBlank(result) == true) result += ', ';
      String fields = '';
      for(String f : err.getFields()) {
        fields += f;
        fields += ' ';
      }
      result += String.format(ERROR_FORMAT, new String[] {fields, err.getMessage()});
    }
    return result;
  }

  // このクラスエラーの情報を得る。
  public virtual class DbErrorHolder {
    public Boolean duplicate { get; protected set; }
    public String msg { get; protected set; }     // 表示用のメッセージ エラーメッセージ+ 重複レコードへのリンクのAタグ
    public String text { get; protected set; }    // 表示用のメッセージ エラーメッセージのみ
    public String dump { get; protected set; }    // String.valueOf(Database.SaveResult)   v1.21
    public DbErrorHolder() {
      this.duplicate = false;
    }
    public virtual void putErrors(Database.Error[] errs) {
      this.msg = getDMLErrorMsg(errs);
      this.text = msg;
    }
    // String.valueOf(Database.SaveResult)
    public void putDump(String dump) { // v1.21
      this.dump = dump;
    }
  }

  // 重複した既存レコードの情報を保持するようのクラス
  public class RecordInfo {
    public String objName { get; private set; }
    public String objLabel { get; private set; }
    public Id id { get; private set; }
    public String name { get; private set; }
    public RecordInfo(Id id, String name) {
      this.id = id;
      this.name = name;
      Schema.DescribeSObjectResult dr = id.getSObjectType().getDescribe();
      this.objName = dr.getName();
      this.objLabel = dr.getLabel();
    }
  }
  // 挿入しようとしたレコードごとの重複にかんする情報を保持するクラス
  public class DuplicateErrorHolder extends DbErrorHolder {
    //public String atags { get; private set; }
    public List<String> atags { get; private set; }
    public Boolean allowSave { get; private set; }
    public Map<Id, String> mapId2Name { get; private set; }   // 重複した既存レコードの オブジェクトの  ID と　Name値  ☆削除予定
    public List<RecordInfo> dups { get; private set; }        // 重複した既存レコードの情報
    public DuplicateErrorHolder() {
      super();
      this.duplicate = true;
      this.allowSave = false;
      this.mapId2Name = new  Map<Id, String>();
      this.dups = new List<RecordInfo>();
      this.atags = new List<String>();
    }

    @TestVisible
    private void buildATags(Id id, String name) {
      Schema.DescribeSObjectResult dr = id.getSObjectType().getDescribe();
      //if (String.isNotBlank(this.atags)) {
      //  this.atags += ' ';
      //}
      //this.atags += String.format(DUPLICATE_ATAG, new String[] {dr.getLabel(), id, name});
      //System.debug(atags);
      this.atags.add(String.format(DUPLICATE_ATAG, new String[] { dr.getLabel(), id, name }));
    }

    public override void putErrors(Database.Error[] errs) {
      // 注意 : 0番目だけ処理する ToDo : 複数エラー対応
      System.assert(errs[0] instanceOf Database.DuplicateError);
      Datacloud.DuplicateResult dr =((Database.DuplicateError)errs[0]).getDuplicateResult();
      //this.text = dr.getErrorMessage();
      this.allowSave = dr.isAllowSave();
      List<Datacloud.MatchResult> matchs = dr.getMatchResults();
      List<String> ids = new List<String>();
      for (Datacloud.MatchResult m : matchs) {
        System.debug('MatchEngine : ' + m.getMatchEngine());
        // 以下、重複した既存レコードについて処理
        List<Datacloud.MatchRecord> mrs = m.getMatchRecords();
        for (Datacloud.MatchRecord mr : mrs) {
          SObject obj = mr.getRecord();
          Id id = (Id)obj.get('Id');
          String name = (String)obj.get('Name');
          buildATags(id, name);           // 表示用の A タグを作る。
          ids.add(name + ':' + id);
          this.mapId2Name.put(id, name);
          this.dups.add(new RecordInfo(id, name));
        }
      }
      this.msg = String.format(DUPLICATE_MSG, new String[]{ dr.getErrorMessage(), dr.getDuplicateRule(), String.join(this.atags, ', ') });
      this.text = String.format(DUPLICATE_MSG, new String[]{ dr.getErrorMessage(), dr.getDuplicateRule(), String.join(ids, ', ') });
    }
  }

  // エラー情報を保持するクラスのインスタンスを作って、処理させて、それを返す
  @TestVisible
  private DbErrorHolder createDbErrorHolder(Database.SaveResult sr) {
    DbErrorHolder result = null;
    Database.Error[] errs = sr.getErrors();
    if (errs[0] instanceOf Database.DuplicateError) {
      result = new DuplicateErrorHolder();    // 重複エラー用クラス
    }
    else {
      result = new DbErrorHolder();     // その他のエラー用
    }
    result.putErrors(errs);
    result.putDump(String.valueOf(sr));   // v1.21
    return result;
  }

  private Boolean haveError;
  private Boolean haveDuplicateError;
  private Boolean allowSave;   // 全レコードが allowSave true なら true
  private Map<Integer, DbErrorHolder> mapIndex2ErrorHolder;      // 結果配列の位置=INSERTした　SObject 配列の順番 と重複した結果のマッピング

  // エラーがあったか？
  public Boolean isError() { return haveError; }
  // 重複のエラーがあったか？
  public Boolean isDuplicateError() { return haveDuplicateError; }
  // 重複のエラーがあっても、保存が許されているか？
  public Boolean isAllowSave() { return haveDuplicateError && allowSave; }
  // 重複エラーだったレコードの配列の位置の配列
  public List<Integer> getDuplicateRecordIndex() {
    List<Integer> result = new List<Integer>();
    for (Integer index : mapIndex2ErrorHolder.keySet()) {
      if (mapIndex2ErrorHolder.get(index).duplicate) {
        result.add(index);
      }
    }
    return result;
  }
  // index番目のレコードについての エラー情報 DMLのエラー情報や、中腹エラーの場合は重複対象へのリンクとか
  //  index番目のレコードがエラーでなければ、null を返す。
  public DbErrorHolder getDbErrorHolder(Integer index) {
    if (mapIndex2ErrorHolder.size() <= index || index < 0) {
      return null;
    }
    return mapIndex2ErrorHolder.get(index);
  }

  public Map<Integer, DbErrorHolder> getDbErrorHolders() {
    return mapIndex2ErrorHolder;
  }

  public SB_NameCard_LeadSaveResult() {
    haveError = false;
    haveDuplicateError = false;
    allowSave = true;
    mapIndex2ErrorHolder = new Map<Integer, DbErrorHolder>();
  }

  public void putSaveResults(List<Database.SaveResult> srs) {
    if (srs == null || srs.size() == 0) {
      return;
    }
    for (Integer n = 0; n < srs.size(); n++) {
      mapIndex2ErrorHolder.put(n, null);
      Database.SaveResult sr = srs[n];
      if (sr.isSuccess()) {
        continue;
      }
      this.haveError = true;
      DbErrorHolder errHolder = createDbErrorHolder(sr);
      if (errHolder.duplicate) {
        this.haveDuplicateError = true;
        this.allowSave = this.allowSave && ((DuplicateErrorHolder)errHolder).allowSave ? true : false;
      }
      mapIndex2ErrorHolder.put(n, errHolder);
    }
  }
}