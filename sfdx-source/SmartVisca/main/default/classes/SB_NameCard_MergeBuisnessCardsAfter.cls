/**
 * 名刺データをマージする機能を提供するクラスです。
 *
 * @author H.Inada@SunBridge
 * 2015.9.25
 *  use NameCard__c.key__c instead of 3 individual fields
 *  Rationale:
 *    key__c is set in before update or before insert trigger to person_name_last__c + ' ' + person_name_first__c + '&' + email__c
 *    key__c is indexed
 *    key__c will never be null
 *    key__c has been set since version 1.0 of AppExchange version. It's safe to use.
 * @Version 2.1   2018/05/07   SV_DEV-877 基本設定の引き継ぐ項目で拡張パッケージの項目が選択可能になっている。
*/
public class SB_NameCard_MergeBuisnessCardsAfter {
  //クエリ項目必要
  private static final String BEFORSTR = 'Name,ownerid,owner.Name,email__c,card_exchange_date__c,Saishin__c,Parent__c,delivery_type__c,company_name__c,company_name_kana__c,person_name_last__c,person_name_last_kana__c,person_name_first__c,person_name_first_kana__c,tenshokugonomeishi__c,tenshokuzumi__c,key__c';
  public static Boolean firstRun {
    get {
      if (firstRun == null)
        firstRun = true;
      return firstRun;
    }
    set;                // TestCode用に　publicに
  }

  public static Map<String,Schema.SObjectField> NameCardFields{
    get{
      if(NameCardFields == null){
        NameCardFields = SB_NameCard_RenkeiMapperUtil.getObjMap('NameCard__c');
      }
      return NameCardFields;
    }
    set;
  }

  public SB_NameCard_MergeBuisnessCardsAfter() {
    firstRun = false;
  }

  public void mergeBusinessCards(List<NameCard__c> nameCardList) {
    Set<String> keySet = new Set<String>();
    for (NameCard__c nc : nameCardList) {
      if (nc.email__c != null || nc.person_name_last__c != null || nc.person_name_first__c != null) {
        keySet.add(nc.key__c);
      }
    }
    if (!keySet.isEmpty()) {
      Set<String> hs = new Set<String>();
      Set<String> soqlset = new Set<String>();
      List<String> beforlist = BEFORSTR.split(',');
      for(String str : beforlist){
        soqlset.add(str);
      }
      String fs = '';
      if(SB_NameCard_BasicSetting.getNameCardBasicSetting().SaishinInheritValues__c == true){
        if(! SB_NameCard_SettingValues.saishinInheritFields.isEmpty()){
          for(NameCardSettingValues__c sv :  SB_NameCard_SettingValues.saishinInheritFields){
            if(!NameCardFields.containsKey(sv.TextValue01__c)){
              continue;
            }
            else if (NameCardFields.get(sv.TextValue01__c).getDescribe().isUpdateable() == false) {
              continue;
            }
            hs.add(sv.TextValue01__c);
            soqlset.add(sv.TextValue01__c);
          }
        }
      }

      String queryStringOld = 'SELECT Id,';
      queryStringOld += String.join(new List<String>(soqlset), ',');

      // 過去名刺データを selectする
      queryStringOld += ' FROM NameCard__c WHERE tenshokuzumi__c = false AND delivery_type__c = \'2\' AND key__c in :keySet ORDER BY person_name_last__c, person_name_first__c, email__c, card_exchange_date__c DESC nulls last, Saishin__c DESC';
      List<NameCard__c> oldNameCards = Database.query(queryStringOld);

      // 過去名刺データを参照している名刺を selectする
      List<NameCard__c> refferringNameCards = [SELECT Id, Name, ownerid, owner.Name, email__c, card_exchange_date__c, Saishin__c, Parent__c, delivery_type__c, company_name__c, company_name_kana__c, person_name_last__c, person_name_last_kana__c, person_name_first__c, person_name_first_kana__c, tenshokugonomeishi__c, tenshokuzumi__c, key__c FROM NameCard__c WHERE tenshokuzumi__c = true AND delivery_type__c = '2' AND parent__c IN :oldNameCards AND Id NOT IN :oldNameCards ORDER BY person_name_last__c, person_name_first__c, email__c, card_exchange_date__c DESC nulls last, Saishin__c DESC];

      NameCard__c older = null, escaped = null, saishin = null, newest = null, refferring = null;
      List<NameCard__c> createAccountTargets = new List<NameCard__c>();
      Integer newindex = -1;
      // 過去名刺のループ
      // 過去名刺と言いつつ、自分自身も含まれている
      System.debug('oldNameCardssize' + oldNameCards);
      for (Integer i = 0; i < oldNameCards.size(); i++) {
        older = oldNameCards[i];
        if (escaped != null && escaped.person_name_last__c == older.person_name_last__c && escaped.person_name_first__c == older.person_name_first__c && escaped.email__c == older.email__c) {
          // いま見ている過去名刺は最新ではない
          if(older.Saishin__c == true && (trigger.isUpdate || trigger.isInsert) && newindex >= 0 ){
            for(String fi : hs){
              Schema.describefieldresult f = NameCardFields.get(fi).getDescribe();
              if((String.isBlank(String.valueof(oldNameCards[newindex].get(fi))) || f.gettype() == Schema.DisplayType.BOOLEAN) && !f.isDependentPicklist()){
                oldNameCards[newindex].put(fi,older.get(fi));
              }
            }
          }
          older.Saishin__c = false;
          older.Parent__c = saishin.Id;
        }
        else {
          // いま見ている名刺が最新だ
          if(older.Saishin__c == false || trigger.isInsert){
            newindex = i;
          }
          System.debug('nameis' + older.name);
          older.Saishin__c = true;
          older.Parent__c = null;
          saishin = older;
          createAccountTargets.add(older);
          newest = older;
        }
        // 今見ている名刺を参照している名刺があるか？
        for (Integer j = 0; j < refferringNameCards.size(); j++) {
          refferring = refferringNameCards[j];
          if (older.Id == refferring.Parent__c) {
            // 今見ている名刺あった
            refferring.Parent__c = newest.Id;
            refferring.Saishin__c = false;
          }
        }
        // 今見ている名刺を覚えておく
        escaped = older;
      }

      // 名刺データ更新
      List<NameCard__c> updateTarget = new List<NameCard__c>();
      updateTarget.addAll(oldNameCards);
      updateTarget.addAll(refferringNameCards);
      update updateTarget;
    }
  }
}