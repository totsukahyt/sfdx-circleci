trigger SB_NameCard_NameCardSettingValuesTrigger on NameCardSettingValues__c(before insert, before update) {
  // Handler インスタンス作成
  SB_NameCard_NameCardSettingValuesHandler handler = new SB_NameCard_NameCardSettingValuesHandler();
  // beforeの場合実行メソッド
  if (Trigger.isBefore) {
    // before insertの場合実行メソッド
    if (Trigger.isInsert) {
      handler.beforeInsert(Trigger.new);
    }
    // before updateの場合実行メソッド
    if (Trigger.isUpdate) {
      handler.beforeUpdate(Trigger.new);
    }
  }
}