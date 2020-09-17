/**
 *
 *  SB_NameCard_MergeBuisnessCardsFuture
 *  名刺データ名寄せロジックのfuture実装版クラス
 *
 *  Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author K.Yoshida
 *  @Version 2.4   2019.06.XX
 *  @Version 2.5.2 2020.05.xx SV_DEV-2599 コードスキャン対応
 *
 **/
public with sharing class SB_NameCard_MergeBuisnessCardsFuture {
  private static final String QUERY_FORM = 'SELECT {0} FROM NameCard__c ';
  private static final String SELECT_FIELD = 'Id,person_name_last__c,person_name_first__c,last_name__c,first_name__c,email__c,card_exchange_date__c,CreatedDate,card_id__c,Saishin__c,Parent__c';
  private static final Map<String,Schema.SObjectField> NameCardFields = SB_NameCard_RenkeiMapperUtil.getObjMap('NameCard__c');

  public static List<NameCard__c> targetCardList = new List<NameCard__c>();
  public static Boolean isTriggerMergeExpandCriteria = false; // future実装版クラスをテストクラスからコールする用
  public static Boolean futureMergeCalled = false;
  public static Set<Id> deliveredLatestCardIds = new Set<Id>();
  
  private static Set<String> selectFieldSet = new Set<String>();
  private static Set<String> jyokenSet = new Set<String>();
  private static Set<String> inheritValuesSet = new Set<String>();

  private static List<String> criteriaFNameList = new List<String>();
  private static List<String> criteriaLNameList = new List<String>();
  private static List<String> criteriaEFNameList = new List<String>();
  private static List<String> criteriaELNameList = new List<String>();
  private static List<String> criteriaList1 = new List<String>();
  private static List<String> criteriaList2 = new List<String>();
  private static List<String> criteriaList3 = new List<String>();
  private static List<String> criteriaList4 = new List<String>();

  /**
   * Comparable名刺オブジェクト
   */
  public class ComparableNameCard implements Comparable {
    public Boolean isDeliveredCard {get;set;}
    public NameCard__c namecard {get;set;}

    public ComparableNameCard(Boolean flg,NameCard__c nc){
      isDeliveredCard = flg;
      namecard = nc;
    }

    public Integer compareTo(Object compareTo) {
      ComparableNameCard compareToNc = (ComparableNameCard)compareTo;
      // 名刺交換日が同じ
      if (this.namecard.card_exchange_date__c == compareToNc.namecard.card_exchange_date__c){
        // 第2優先順位 先に2次納品された名刺
        if ( this.namecard.Saishin__c && !compareToNc.namecard.Saishin__c ){
          return -1;
        }else if( !this.namecard.Saishin__c && compareToNc.namecard.Saishin__c ){
          return 1;
        }else{
          return 0;
        }
      }else{
        // 片方Nullなら値がある方が新しい名刺 
        if (this.namecard.card_exchange_date__c != null && 
          compareToNc.namecard.card_exchange_date__c == null ) {
        return -1;
        }
        if (this.namecard.card_exchange_date__c == null && 
            compareToNc.namecard.card_exchange_date__c != null ) {
          return 1;
        }
        // 名刺交換日 新しい名刺
        if (this.namecard.card_exchange_date__c > compareToNc.namecard.card_exchange_date__c) {
          return -1;
        }else{
          return 1;
        }
      }
    }
  }

  /**
   * before delete用名寄せ処理
   * 子名刺側 ParentIdを元に紐付けの修正を実施するため、同期処理で実装します
   */
  public static void reLinkBusinessCards(List<Id> cardIds) {
    futureMergeCalled = true; // 実行済みフラグ

    // 設定読み込み
    loadSetting();

    // 削除対象の名刺を最新名刺 かつ 未転職の名刺に絞り込む
    List<NameCard__c> reLinkTargets = [SELECT Id,Parent__c FROM NameCard__c WHERE Saishin__c = true AND tenshokuzumi__c = false AND delivery_type__c = '2' AND ID IN :cardIds];

    // 削除対象の名刺に紐付く過去名刺の読み込み(転職済み名刺を除く)
    String soql = String.format(QUERY_FORM , new String[] {String.join(new List<String>(selectFieldSet), ',')}) + ' WHERE delivery_type__c = \'2\' AND tenshokuzumi__c = false AND parent__c IN :reLinkTargets AND Id NOT IN :reLinkTargets';
    List<NameCard__c> olderCardList = Database.query(soql);
    
    // 削除対象の名刺に紐付く転職済み名刺を検索
    List<NameCard__c> tenshokuzumiCardList = [SELECT Id,Parent__c FROM NameCard__c WHERE delivery_type__c = '2' AND tenshokuzumi__c = true AND ( tenshokugonomeishi__c IN :reLinkTargets OR tenshokugonomeishi__c IN :olderCardList )];
    system.debug('tenshokuzumiCardList size is' + tenshokuzumiCardList.size());

    // 同じ名刺同士リストを格納するMap
    Map<Id,List<ComparableNameCard>> sameCardMap = new Map<Id,List<ComparableNameCard>>();
    Set<Id> skipCardIDs = new Set<Id>();
    
    // 過去名刺を捜索し、同じ親を見ている名刺をまとめる
    for ( NameCard__c src:olderCardList ){
      if ( skipCardIDs.contains(src.Id) ){
        continue;
      }
      List<ComparableNameCard> tmpCNCList = new List<ComparableNameCard>();
      tmpCNCList.add(new ComparableNameCard(false,src));
      skipCardIDs.add(src.Id);
      for ( NameCard__c dst:olderCardList ){
        if (src == dst){
          continue;
        }
        if ( skipCardIDs.contains(dst.Id) ){
          continue;
        }
        if (src.parent__c == dst.parent__c){
          tmpCNCList.add(new ComparableNameCard(false,dst));
          skipCardIDs.add(dst.Id);
        }
      }
      sameCardMap.put(src.Id,tmpCNCList);
    }

    List<NameCard__c> updateTarget = new List<NameCard__c>();
    // 同一人物の名刺同士リストを取り出して紐付けを修正
    for (Id sKey : sameCardMap.keySet()) {
      List<ComparableNameCard> tmpNCList = sameCardMap.get(sKey);
      tmpNCList.sort();
      
      // 最新名刺名刺に対する処理
      NameCard__c latestCard = tmpNCList.get(0).namecard;
      String currentParentID = latestCard.Parent__c;
      latestCard.Parent__c = null;
      latestCard.Saishin__c = true;
      updateTarget.add(latestCard);

      // 転職済み名刺の紐付けを修正
      if ( tenshokuzumiCardList != null ){
        for ( NameCard__c tzCard:tenshokuzumiCardList ){
          if (currentParentID == tzCard.Parent__c) {
            tzCard.Parent__c = latestCard.Id;
            tzCard.Saishin__c = false;
            updateTarget.add(tzCard);
          }
        }
      }

      // 2枚目以降に対する処理
      if ( tmpNCList.size() > 1 ){
        for ( Integer i = 1 ; i < tmpNCList.size() ; i++ ){
          NameCard__c olderCard = tmpNCList.get(i).namecard;
          // 値の引継ぎ
          if (olderCard.Saishin__c){
            for ( String inheritValues:inheritValuesSet ){
              Schema.describefieldresult field = NameCardFields.get(inheritValues).getDescribe();
              if((String.isBlank(String.valueof(latestCard.get(inheritValues))) || field.gettype() == Schema.DisplayType.BOOLEAN) && !field.isDependentPicklist()){
                latestCard.put(inheritValues,olderCard.get(inheritValues));
              }
            }
          }
          olderCard.Parent__c = latestCard.Id;
          olderCard.Saishin__c = false;
          updateTarget.add(olderCard);
        }
      }
    }
    //SV_DEV-2599 コードスキャン対応、FLSチェックを実施
    //update updateTarget;
    SB_NameCard_CrudFls.supdate(updateTarget,true);
  }

  /**
   * after insert、update、undelete名寄せ処理
   */
  @future
  public static void mergeBusinessCards(List<Id> cardIds) {
    futureMergeCalled = true; // 実行済みフラグ

    // 設定読み込み
    loadSetting();

    // 今回操作された名刺のうち2次納品名刺を絞り込み(転職済み名刺は除く)
    String soql = String.format(QUERY_FORM , new String[] {String.join(new List<String>(selectFieldSet), ',')}) + ' Where Id in: cardIds and delivery_type__c = \'2\' and tenshokuzumi__c = false';
    List<NameCard__c> deliveredCardList = Database.query(soql);

    // 今回操作された名刺を含めて条件に合致する2次納品名刺の読み込み
    soql = String.format(QUERY_FORM , new String[] {String.join(new List<String>(selectFieldSet), ',')}) + ' Where tenshokuzumi__c = false and delivery_type__c = \'2\'' + getCriteria(deliveredCardList);
    List<NameCard__c> oldCardList = Database.query(soql);

    // 同一人物の名刺を探索
    Map<Id,List<ComparableNameCard>> sameCardMap = new Map<Id,List<ComparableNameCard>>();
    Set<Id> processedIDs = new Set<Id>();          //処理済み名刺ID
    Map<Id,Id> referenceMap = new Map<Id,Id>();    //子の検索用
    Map<Id,Id> parentSearchMap = new Map<Id,Id>(); //親の検索用

    // 同一人物の名刺を探索
    for ( NameCard__c src:oldCardList ){
      ComparableNameCard comCard;
      for ( NameCard__c dst:deliveredCardList ){
        // 名寄せ条件に合致する名刺
        if (isSameNameCard(src, dst)){
          if ( cardIds.contains(src.Id) ){
            // 今回操作された名刺
            comCard = new ComparableNameCard(true,src);
          }else{
            // 名寄せされる名刺
            comCard = new ComparableNameCard(false,src);
          }
          List<ComparableNameCard> tmpCNCList = sameCardMap.get(dst.Id);
          if ( tmpCNCList == null ){
            tmpCNCList = new List<ComparableNameCard>();
            sameCardMap.put(dst.Id,tmpCNCList);
          }
          tmpCNCList.add(comCard);

          processedIDs.add(src.Id);
          referenceMap.put(src.Id,dst.Id);
          if ( src.Parent__c != null ){
            parentSearchMap.put(src.Parent__c,dst.Id);
          }
          break;
        }
      }
    }
   
    // 紐付けを直す必要がある子名刺をマージ
    if (referenceMap.size() > 0){
      Set<Id> rKey = referenceMap.KeySet();
      soql = String.format(QUERY_FORM , new String[] {String.join(new List<String>(selectFieldSet), ',')}) + ' Where parent__c in: rKey and Id not in: processedIDs and delivery_type__c = \'2\'';
      List<NameCard__c> tmpCardCardList = Database.query(soql);
      for ( NameCard__c tmpCard:tmpCardCardList ){
        List<ComparableNameCard> tmpCNCList = sameCardMap.get(referenceMap.get(tmpCard.parent__c));
        tmpCNCList.add(new ComparableNameCard(false,tmpCard));
        processedIDs.add(tmpCard.Id);
      }
    }

    // 紐付けを直す必要がある親名刺をマージ
    if (parentSearchMap.size() > 0){
      Set<Id> rKey = referenceMap.KeySet();
      Set<Id> pKey = parentSearchMap.keySet();
      soql = String.format(QUERY_FORM , new String[] {String.join(new List<String>(selectFieldSet), ',')}) + ' Where Id in: pKey and Id not in: processedIDs and delivery_type__c = \'2\'';
      List<NameCard__c> tmpCardCardList = Database.query(soql);
      system.debug('tmpCard size is :' + tmpCardCardList.size());
      for ( NameCard__c tmpCard:tmpCardCardList ){
        List<ComparableNameCard> tmpCNCList = sameCardMap.get(parentSearchMap.get(tmpCard.Id));
        tmpCNCList.add(new ComparableNameCard(false,tmpCard));
        processedIDs.add(tmpCard.Id);
      }

      // 同じ親を見ている子をマージ
      soql = String.format(QUERY_FORM , new String[] {String.join(new List<String>(selectFieldSet), ',')}) + ' Where parent__c in: pKey and Id not in: processedIDs and delivery_type__c = \'2\'';
      tmpCardCardList = Database.query(soql);
      system.debug('tmpCard size is :' + tmpCardCardList.size());
      for ( NameCard__c tmpCard:tmpCardCardList ){
        List<ComparableNameCard> tmpCNCList = sameCardMap.get(parentSearchMap.get(tmpCard.parent__c));
        tmpCNCList.add(new ComparableNameCard(false,tmpCard));
        processedIDs.add(tmpCard.Id);
      }
    }

    List<NameCard__c> updateTarget = new List<NameCard__c>();
    // 同一人物の名刺同士リストを取り出して紐付けを修正
    for (Id sKey : sameCardMap.keySet()) {
      List<ComparableNameCard> tmpNCList = sameCardMap.get(sKey);
      tmpNCList.sort();
      
      // 最新名刺名刺に対する処理
      NameCard__c latestCard = tmpNCList.get(0).namecard;
      system.debug('latestCard is:' + latestCard.Id );
      if (tmpNCList.get(0).isDeliveredCard){
        deliveredLatestCardIds.add(latestCard.Id);
      }
      latestCard.Parent__c = null;
      latestCard.Saishin__c = true;
      updateTarget.add(latestCard);

      // 2枚目以降に対する処理＋値の引継ぎ
      if ( tmpNCList.size() > 1 ){
        for ( Integer i = 1 ; i < tmpNCList.size() ; i++ ){
          NameCard__c olderCard = tmpNCList.get(i).namecard;
          // 値の引継ぎ
          if (olderCard.Saishin__c){
            for ( String inheritValues:inheritValuesSet ){
              Schema.describefieldresult field = NameCardFields.get(inheritValues).getDescribe();
              if((String.isBlank(String.valueof(latestCard.get(inheritValues))) || field.gettype() == Schema.DisplayType.BOOLEAN) && !field.isDependentPicklist()){
                latestCard.put(inheritValues,olderCard.get(inheritValues));
              }
            }
          }
          olderCard.Parent__c = latestCard.Id;
          olderCard.Saishin__c = false;
          updateTarget.add(olderCard);
        }
      }
    }
    //SV_DEV-2599 コードスキャン対応、FLSチェックを実施
    //update updateTarget;
    SB_NameCard_CrudFls.supdate(updateTarget,true);
  }

  /**
   * 同一人物の名刺かを判定
   */
  private static Boolean isSameNameCard(NameCard__c src,NameCard__c dst){
    //　同じレコードなら同一人物
    if ( src.Id == dst.Id ){
      return true;
    }
    // 姓＋名が一致することを比較(姓・名がnullなら英名で比較
    if ( src.person_name_last__c != null || src.person_name_first__c != null ) {
      if ( src.person_name_last__c != dst.person_name_last__c ){
        return false;
      }
      if ( src.person_name_first__c != dst.person_name_first__c ){
        return false;
      }
    }
    else {
      if ( src.last_name__c != dst.last_name__c ){
        return false;
      }
      if ( src.first_name__c != dst.first_name__c ){
        return false;
      }
    }
    
    // メールアドレス 片方がnullならその他の条件での判断へ
    if ( src.email__c != null && dst.email__c != null ){
      if ( src.email__c == dst.email__c ){
        // 値アリ かつ 値一致は同一人物
        return true;
      }else{
        // 値アリ かつ 値不一致は他の条件を見ずに別の人物と判断
        return false;
      }
    }

    // どれか1個合致した段階で同一人物と判断
    Boolean mismatch = false;
    for ( String jyoken:jyokenSet ){
      // nullは一致と認めない
      if (src.get(jyoken) == null || dst.get(jyoken) == null){
        continue;
      }
      if (src.get(jyoken) == dst.get(jyoken)){
        return true;
      }else{
        mismatch = true;
      }
    }

    // 互換性維持：その他の条件に不一致項目がなく、メールアドレスがnullの場合は同一人物と判断
    if ( !mismatch && src.email__c == null && dst.email__c == null ) {
      return true;
    }

    return false;
  }

  /**
   * 現行最新名刺の読み込みSOQLの条件部分を生成
   */
  private static String getCriteria(List<NameCard__c> cardList){
    String criteria = '';

    Integer cnt = 0;
    List<String> jyokenList = new List<String>(jyokenSet);
    // メールアドレスは最優先
    if ( jyokenList.size() > 0 ){
      jyokenList.add(0,'email__c');
    }else{
      jyokenList.add('email__c');
    }
    
    for ( String jyoken:jyokenList ){
      for ( NameCard__c card:cardList ){
        if ( cnt == 0 ){
          criteriaList1.add((String)card.get(jyoken));
        }
        else if ( cnt == 1 ){
          criteriaList2.add((String)card.get(jyoken));
        }
        else if ( cnt == 2 ){
          criteriaList3.add((String)card.get(jyoken));
        }
        else if ( cnt == 3 ){
          criteriaList4.add((String)card.get(jyoken));
        }
      }
      cnt++;
    }
    criteria = jyokenList[0] + ' in : criteriaList1'; // メールアドレスは最優先
    if ( criteriaList2.size() > 0 ) criteria +=  ' or ' + jyokenList[1] + ' in : criteriaList2';
    if ( criteriaList3.size() > 0 ) criteria +=  ' or ' + jyokenList[2] + ' in : criteriaList3';
    if ( criteriaList4.size() > 0 ) criteria +=  ' or ' + jyokenList[3] + ' in : criteriaList4';
    if ( criteria <> '' ){
      criteria = ' and ( ' + criteria + ' ) ';
    }

    // 姓・名(またはファーストネームラストネーム)は必ず使う
    for ( NameCard__c card:cardList ){
      criteriaLNameList.add(card.person_name_last__c);
      criteriaFNameList.add(card.person_name_first__c);
      criteriaELNameList.add(card.last_name__c);
      criteriaEFNameList.add(card.first_name__c);
    }
    criteria = ' and ( ( person_name_last__c in :criteriaLNameList and person_name_first__c in :criteriaFNameList ) or ( last_name__c in :criteriaELNameList and first_name__c in :criteriaEFNameList ) )' + criteria;
    return criteria;
  }

  /**
   * 設定値の読み込み
   */
  private static void loadSetting(){
    // 必ず検索する項目
    selectFieldSet.addAll(SELECT_FIELD.split(','));

    // 名寄せ条件フィールド読み込み
    NameCardBasicSetting__c setting = SB_NameCard_BasicSetting.getNameCardBasicSetting();

    // 名寄せ条件設定読み込み
    if ( setting.NayoseJyoken__c != null ) {
      for ( String field:setting.NayoseJyoken__c.split(';') ){
        if(!NameCardFields.containsKey(field)){
          continue;
        }
        else if (NameCardFields.get(field).getDescribe().isUpdateable() == false) {
          continue;
        }
        selectFieldSet.add(field);
        jyokenSet.add(field);
      }
    }

    // 最新の名刺値引継ぎ機能設定読み込み
    if(setting.SaishinInheritValues__c){
      if(! SB_NameCard_SettingValues.saishinInheritFields.isEmpty()){
        for(NameCardSettingValues__c sv :  SB_NameCard_SettingValues.saishinInheritFields){
          if(!NameCardFields.containsKey(sv.TextValue01__c)){
              continue;
          }
          else if (NameCardFields.get(sv.TextValue01__c).getDescribe().isUpdateable() == false) {
            continue;
          }
          selectFieldSet.add(sv.TextValue01__c);
          inheritValuesSet.add(sv.TextValue01__c);
        }
      }
    }
  }
}