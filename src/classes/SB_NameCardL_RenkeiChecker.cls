/**
 *
 *  SB_NameCardL_RenkeiChecker
 *  基本の SB_NameCardL_RenkeiChecker を持ってきた
 *
 *   自動連携で 名刺レコードを対象OR除外とするか判定するクラス  トリガハンドラで使う。
 *    シングルトンで使う
 *   連携条件オブジェクトから作る。
 *
 *  除外を指定するか、対象をしていするか課題。
 *  条件 AND OR の組み合わせをどのように処理するか課題
 *
 *  Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author mao
 *  @Version 1.20      2017.02.15
 *  @Version 2.0.1     2018.04.XX SV_DEV-883 【自動連携】過去分名刺を除外できる設定が欲しい
 *
 *
 **/
public with sharing class SB_NameCardL_RenkeiChecker {

  // シングルトンのインスタンス
  private static SB_NameCardL_RenkeiChecker instance;
  // 名刺項目チェック用Map
  private static Map<String,Schema.SObjectField> nameCardFieldMap = SmartViscaf__NameCard__c.sObjectType.getDescribe().fields.getMap();


  // データ型ごとに検査クラスを分けます。
  // チェックルーチン(＝検査クラス）ごとテストできるので、テストクラスを作りやすいと思います。

  // 各データ型向けの検査クラスの基底
  public abstract class Checker {
    public String field { get; private set;}      // 対象の項目API名 Nameとか SmartViscaf__company_name__cとか, Owner.UserRole.Name とか
    // コンストラクタ
    // TODO 除外条件を持ったレコードから から該当の項目とか、条件を抽出
    //   SObject はそれに変える
    public Checker(SmartViscaf__NameCardRenkeiJyoken__c obj)  {
      field = obj.SmartViscaf__NameCardName__c;
    }
    // 該当の項目の値を貰って判定するクラス
    public abstract Boolean isMatch(Object obj);
  }


  // 文字列型の検査クラス 正規表現で処理する。
  public class StringChecker extends Checker {
    private Pattern ptn;
    private String target;
    private Integer operator;
    public StringChecker(SmartViscaf__NameCardRenkeiJyoken__c obj,Integer op) {
      super(obj);
      operator = op;
      target = obj.SmartViscaf__Value__c;
      if(op == 5 && String.isNotBlank(obj.SmartViscaf__Value__c)) {
        ptn = Pattern.compile(obj.SmartViscaf__Value__c);
      }
    }

    //0-次の文字列と一致する
    //1-次の文字列と一致しない
    //2-次の文字列で始まる
    //3-次の文字列を含む
    //4-次の文字列を含まない
    //5-次の正規表現に合致する
    //6-＜
    //7-＞
    //8-＜＝
    //9-＞＝
    public override Boolean isMatch(Object val) {
      if (operator == 99) {
        return true;
      }
      if(operator == 5){
        if (ptn == null) {
          return false;
        }
        String valu = val == null? '' : (String)val;
        Matcher matcher = ptn.matcher(valu);
        return !matcher.find();
      }
      val = String.valueOf(val);
      if(String.isBlank((String)val)) {
         val = '';
      }
      if(String.isBlank(target)) {
         target = '';
      }
      if(operator == 6 || operator == 7 || operator == 8 || operator ==9) {
        return ((String)val < target && (operator ==7 || operator ==9)) ||       // 条件より前
          ((String)val > target && (operator ==6 || operator == 8)) || ((String)val == target && (operator ==6 || operator == 7)) ;    // 条件より
      } else if(operator == 0 || operator == 1) {
        return (((String)val == target && operator == 1) || ((String)val != target && operator == 0));
      } else if (operator == 4 || operator == 3) {
        return ((((String)val).IndexOf(target)>=0 && operator == 4) || (((String)val).IndexOf(target)<0 && operator == 3));
      } else {
        if(String.isBlank((String)val) || String.isBlank(target)) {
          return target != (String)val;
        }
        return !((String)val).startsWith(target);
      }
    }
  }

  // 日時型の検査クラス
  public class DateTimeChecker extends Checker {
    private Date target;
    private Integer operator;  // < <= = >= >
    public DateTimeChecker(SmartViscaf__NameCardRenkeiJyoken__c obj,Integer op) {
      super(obj);
      //target = (DateTime) JSON.deserialize('"' + obj.SmartViscaf__Value__c +'"', DateTime.class);
      if (String.isNotBlank(obj.SmartViscaf__Value__c)) {
        target = Date.valueOf(obj.SmartViscaf__Value__c);
      }
      operator = op;
    }

    //0-次の文字列と一致する
    //1-次の文字列と一致しない
    //2-次の文字列で始まる
    //3-次の文字列を含む
    //4-次の文字列を含まない
    //5-次の正規表現に合致する
    //6-＜
    //7-＞
    //8-＜＝
    //9-＞＝
    public override Boolean isMatch(Object val) {
      if (operator == 99) {
        return true;
      }
      // nullの場合は別判断
      if (target == null){
        // operator 0と1以外,条件値がnullの場合,判断しない(連携する)として判断します
        if (operator != 0
            && operator != 1) {
            return false;
        } else if (operator == 0) {
          return val != null;
        } else {
          return val == null;
        }
      }
      if(val == null){
        if(operator == 0) {
          return target != null;
        } else if(operator == 1) {
          return target == null;
        } else {
          return true;
        }
      }
      System.assert(val instanceOf DateTime);     // 一応
      Datetime dt = (Datetime)val;
      Date va = Date.newInstance(dt.year(),dt.month(),dt.day());
      // TODO 日時でチェックか日付でチェックか？  揃える。
      return (va < target && (operator == 0 || operator ==7 || operator ==9)) ||       // 条件より前
        (target  == va && (operator == 1 || operator == 6 || operator == 7)) ||   // 条件と同じ
        (va > target && (operator == 0 || operator ==6 || operator == 8));    // 条件より後
    }
  }

  // 日時型の検査クラス
  public class DateChecker extends Checker {
    private Date target;
    private Integer operator;  // < <= = >= >
    public DateChecker(SmartViscaf__NameCardRenkeiJyoken__c obj,Integer op) {
      super(obj);
      if (String.isNotBlank(obj.SmartViscaf__Value__c)) {
        target = Date.valueOf(obj.SmartViscaf__Value__c);
      }
      operator = op;
    }

    //0-次の文字列と一致する
    //1-次の文字列と一致しない
    //2-次の文字列で始まる
    //3-次の文字列を含む
    //4-次の文字列を含まない
    //5-次の正規表現に合致する
    //6-＜
    //7-＞
    //8-＜＝
    //9-＞＝
    public override Boolean isMatch(Object val) {
      if (operator == 99) {
        return true;
      }
      // nullの場合は別判断
      if (target == null){
        // operator 0と1以外,条件値がnullの場合,判断しない(連携する)として判断します
        if (operator != 0
            && operator != 1) {
            return false;
        } else if (operator == 0) {
          return val != null;
        } else {
          return val == null;
        }
      }
      if(val == null){
        if(operator == 0) {
          return target != null;
        } else if(operator == 1){
          return target == null;
        } else {
          return true;
        }
      }
      System.assert(val instanceOf Date);     // 一応
      // TODO 日時でチェックか日付でチェックか？  揃える。
      return ((Date)val < target && (operator == 0 || operator ==7 || operator ==9)) ||       // 条件より前
        (target.isSameDay((Date)val) && (operator == 1 || operator == 6 || operator == 7)) ||   // 条件と同じ
        ((Date)val > target && (operator == 0 || operator ==6 || operator == 8));    // 条件より後
    }
  }

  // 日時型の検査クラス
  public class NumberChecker extends Checker {
    private Double target;
    private Integer operator;  // < <= = >= >
    public NumberChecker(SmartViscaf__NameCardRenkeiJyoken__c obj,Integer op) {
      super(obj);
      if (String.isNotBlank(obj.SmartViscaf__Value__c)) {
        target = Double.valueOf(obj.SmartViscaf__Value__c);
      }
      operator = op;
    }


    //0-次の文字列と一致する
    //1-次の文字列と一致しない
    //2-次の文字列で始まる
    //3-次の文字列を含む
    //4-次の文字列を含まない
    //5-次の正規表現に合致する
    //6-＜
    //7-＞
    //8-＜＝
    //9-＞＝
    public override Boolean isMatch(Object val) {
      if (operator == 99) {
        return true;
      }
      // 数値タイプの設定値は空白に設定できないため,Nullの場合判断しない(連携する)として判断します
      // nullの場合は別判断
      if (target == null){
        // operator 0と1以外,条件値がnullの場合,判断しない(連携する)として判断します
        if (operator != 0
            && operator != 1) {
            return false;
        } else if (operator == 0) {
          return val != null;
        } else {
          return val == null;
        }
      }
      if(val == null){
        if(operator == 0) {
          return target != null;
        } else if(operator == 1){
          return target == null;
        } else {
          return true;
        }
      }
      System.assert(val instanceOf Double);     // 一応
      // TODO 日時でチェックか日付でチェックか？  揃える。
      return ((Double)val < target && (operator == 0 || operator ==7 || operator ==9)) ||       // 条件より前
        ((Double)val == target && (operator == 1 || operator == 6 || operator == 7)) ||   // 条件と同じ
        ((Double)val > target && (operator == 0 || operator ==6 || operator == 8));    // 条件より後
    }
  }

  // TODO 論理値型
  // TODO 数値型


  // 項目API名と 検査クラスの配列のマップ  同じ項目で複数条件を許容する
  private Map<String, List<Checker>> field2checkers;

  // コンストラクタ
  // 除外条件オブジェクトを検索して、必要な検査クラスのインスタンスを作成します。
  @TestVisible
  private SB_NameCardL_RenkeiChecker() {
    //更新条件を検査のクエリ
    SmartViscaf__NameCardBasicSetting__c ba = SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting();
    List<SmartViscaf__NameCardRenkeiJyoken__c> conditions = [Select Id,Name,SmartViscaf__Operator__c,SmartViscaf__Value__c,SmartViscaf__NameCardName__c,SmartViscaf__NameCardDataType__c from SmartViscaf__NameCardRenkeiJyoken__c Where SmartViscaf__BasicSetting__c != null AND SmartViscaf__BasicSetting__c = :ba.Id Limit 1000];// TODO 条件保持オブジェクトへのクエリ
    //List<SObject> conditions = [SELECT Id, Name FROM Account];
    field2checkers = new Map<String, List<Checker>>();
    for (SmartViscaf__NameCardRenkeiJyoken__c obj : conditions) {    // 条件保持オブジェクト レコード分処理
      // 連携条件を集める
      try{
        String f = obj.SmartViscaf__NameCardName__c;// 対象の名刺項目
        // 存在しない項目があったらnameCardFieldMapに入れない
        if (!nameCardFieldMap.containsKey(f)) {
          continue;
        }
        List<Checker> checkers = null;
        if (field2checkers.containsKey(f)) {
          checkers = field2checkers.get(f);
        } else {
          checkers =  new List<Checker>();
        }
        // TODO 項目のデータ型ごとに振り分ける。データ型の区別は事前に設定画面の制御でされ、レコードが作成されている前提
        String datatype = obj.SmartViscaf__NameCardDataType__c;
        if (datatype == 'DATE') {
          // 日付 用だったら
          DateChecker dc = new DateChecker(obj,changeOperator(obj.SmartViscaf__Operator__c));
          checkers.add(dc);
        } else if (datatype == 'DATETIME') {
          // 日付時間 用だったら
          DateTimeChecker dc = new DateTimeChecker(obj,changeOperator(obj.SmartViscaf__Operator__c));
          checkers.add(dc);
        } else if (datatype == 'DOUBLE') {
          NumberChecker sc = new NumberChecker(obj,changeOperator(obj.SmartViscaf__Operator__c));
          checkers.add(sc);
        }else {
          StringChecker sc = new StringChecker(obj,changeOperator(obj.SmartViscaf__Operator__c));
          checkers.add(sc);
          // ToDo 論理値 用 だったら
        }
         // ToDo 数値 用 だったら
        field2checkers.put(f, checkers);
      }
      // Exception がありましたらその条件を無視する
      catch(Exception e) {
      }
    }
  }



  public Integer changeOperator(String op){
    //次の文字列と一致する
    if(op == 'Matches_next_character_string'){
      return 0;
    }
    //次の文字列と一致しない
    else if(op == 'Does_not_match_next_character_string'){
      return 1;
    }
    //次の文字列で始まる
    else if(op == 'Start_with_the_following_string'){
      return 2;
    }
    //次の文字列を含む
    else if(op == 'Contains_the_following_character_string'){
      return 3;
    }
    //次の文字列を含まない
    else if(op == 'Not_contain_the_following_character_string'){
      return 4;
    }
    //次の正規表現に合致する
    else if(op == 'Matches_the_following_regular_expression'){
      return 5;
    }
    else if(op == '＜'){
      return 6;
    }
    else if(op == '＞'){
      return 7;
    }
    else if(op == '＜＝'){
      return 8;
    }
    else if (op == '＞＝') {
      return 9;
    }
    // 不正演算子
    return 99;
  }


  // 名刺レコードから 該当の項目 の値を取得します。 参照先の項目も取得します。
  private Object getValue(SmartViscaf__NameCard__c card, String field) {
    String[] ff = field.split('\\.');
    if (ff.size() > 1) {
      Sobject obj = card;
      for(Integer n =0; n < ff.size()-1; n++) {
        obj = obj.getSObject(ff[n]);
        if (obj == null) {
          return null;
        }
      }
      return obj.get(ff[ff.size()-1]);
    }
    return card.get(field);
  }

  // 名刺レコードを渡されて、作成済の検索クラスに渡して 除外するか判定します。
  public Boolean isIgnore(SmartViscaf__NameCard__c card) {
    for (String f : field2checkers.keySet()) {
      Object val = getValue(card, f);
      for (Checker checker : field2checkers.get(f)) {
        try {
          // beforeTriggerで実行されます
          // 現在時刻を保持していないので、現在時刻を強制的にセット
          // 最終更新日は毎回現在時間設定
          // 作成日は作成の場合のみ現在時間を設定
          if((String.isBlank(card.Id) && checker.field == 'CreatedDate') || checker.field == 'LastModifiedDate'){
            val = Datetime.now();
          }
          if (checker.isMatch(val)) {
            return true;
          }
        }
        // 連携条件で項目をチェックする際にExceptionがあったらそのチェックを無視します
        catch (Exception e) {
        }
      }
    }
    return false;
  }

  public static SB_NameCardL_RenkeiChecker getInstance() {
    if (instance == null) {
      instance = new SB_NameCardL_RenkeiChecker();
    }
    return instance;
  }
}