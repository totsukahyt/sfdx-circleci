/*
 * Copyright (c) 2014-2019 SunBridge Inc.
 *
 * 日経テレコン人事異動情報 WSI API バッチ スケジューラ
 *
 * @Version 0 2014.xx.xx MRESでの人事異動機能からの移植   MRESでは 対象を取引先、取引先責任者 だったのを 名刺 を対象に変更。 その名残で、 account  とか contact という名称が使われている
 * @Version 1 kou 2017.10.xx  with sharing, FLS  v1.21 for code scan　← Version 1 というか 2 Crud Fls 対応しただけ
 * @Version 2 v2.0.2 2018.07.xx SV_DEV-976 [人事異動情報] 同一人物の名刺について複数「人事異動情報取得」FLGを設定した場合、１つの名刺にしか人事異動情報が紐付けられていない。
 *                              法人格は、'株式会社', '合同会社', '合名会社', '合資会社' のみ対応だったのを SmartVisca 標準(SB_NameCard_Util)の ㈱とかも対応するように変更
 *                               5000レコード 超 だと DMLリミットなので 警告メール出して終了
 *                               名刺レコードを更新するとき、名寄せがはしらないようにする。
 * @Version 3 v2.4 2019.08.xx SV_DEV-1618 人事異動情報取得処理 新・旧役職名が長すぎた場合にSTRING_TOO_LONGエラーが発生してしまう不具合への対応
 *
 */

global with sharing class SB_NameCard_JinjiIdoBatch implements Database.Batchable<Boolean>, Database.Stateful, Database.AllowsCallouts, Schedulable
{
  global SB_NameCard_JinjiIdoBatch(){}

  global SB_NameCard_JinjiIdoBatch(Date fromDate, Date toDate, List<String> accNameList, List<String> conNameList, List<Date> prDateList){}

  global Iterable<Boolean> start(Database.BatchableContext bc)
  {
    List<Boolean> bList = new List<Boolean>();
    bList.add(true);
    return bList;
  }

  global void execute(Database.BatchableContext bc, List<Boolean> bList) {}

  global void finish(Database.BatchableContext bc) {}

  global void execute(SchedulableContext sc) {}
}