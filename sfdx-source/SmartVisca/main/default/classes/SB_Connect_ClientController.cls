/**
 * @File Name\t      : SB_Connect_Clients.cls
 * @Description        : SmartViscaConnect向けclients API
 * @Author             : 西根哲史
 * @Group              :
 * @Last Modified By   : 西根哲史
 * @Last Modified On   : 2020/5/8 11:58:27
 * @Modification Log   :
 *
 *  インスタンスURL/services/apexrest/clients   か インスタンスURL/services/apexrest/clients
 *
 * Ver       Date            Author      		    Modification
 * 1.0    2020/1/29   西根哲史     Initial Version
 * 1.1    2020/5/7    西根哲史     ガバナ制限対応
 * 2.0    2020/5/13   sawano      v2.5 名刺のみで自分所有のもののみの対応に変更 + リファクタリング
**/
@RestResource(urlMapping = '/clients')
global with sharing class SB_Connect_ClientController {

  /**
    * 電話番号毎の名刺・取引先責任者の情報を取得します。
    *
    * @return 電話番号毎の名刺・取引先責任者情報
    */
  @HttpGet
  global static Map<String, List<SB_Connect_Client>> getClients() {

    DirectoryEntryBuilder builder = new DirectoryEntryBuilder();
    return new Map<String, List<SB_Connect_Client>>{ 'clients' => builder.create() };
  }

  private class DirectoryEntryBuilder {
    private SB_Connect_Utils util;
    private Map<String, SB_Connect_Client> clientMap;
    public DirectoryEntryBuilder() {
      this.util = new SB_Connect_Utils();
      this.clientMap = new Map<String, SB_Connect_Client>();
    }

    public List<SB_Connect_Client> create() {
      Id userId = UserInfo.getUserId();
      if (!havePermission()) {
        // SV_DEV-2613 SmartVIsca connect：名刺の参照権限がないユーザでデータの同期が行えてしまう場合がある。
        return new List<SB_Connect_Client>();
      }
      Integer limits = Limits.getLimitQueryRows() - Limits.getQueryRows();
      System.debug('Limits.getLimitQueryRows(): ' + limits);
      // List<NameCard__c> nameCards = [
      //   SELECT
      //       tel1__c,
      //       tel2__c,
      //       mobile__c,
      //       // Parent__c, Parent__r.tel1__c, Parent__r.tel2__c, Parent__r.mobile__c,
      //       Name,
      //       company_name__c,
      //       CreatedDate,
      //       LastModifiedDate
      //   FROM NameCard__c
      //       // WHERE (tel1__c != null or tel2__c != null or mobile__c != null) AND Saishin__c = true
      //       WHERE (tel1__c != null or tel2__c != null or mobile__c != null) AND OwnerId = :userId
      //       ORDER BY card_exchange_date__c DESC NULLS LAST
      //       LIMIT :limits];
      // 2020.05.13 List と Soql for loop と比べると List のほうが若干早い=たくさん処理できるみたいだけど、HEAP LIMIT になるときがあるみたいなので、 for loop にしとく。
      for (List<NameCard__c> nameCards : [
        SELECT
            Id, Name,
            tel1__c,
            tel2__c,
            mobile__c,
            // Parent__c, Parent__r.tel1__c, Parent__r.tel2__c, Parent__r.mobile__c,
            company_name__c,
            email__c,
            CreatedDate,
            LastModifiedDate
        FROM NameCard__c
            // WHERE (tel1__c != null or tel2__c != null or mobile__c != null) AND Saishin__c = true
            WHERE (tel1__c != null or tel2__c != null or mobile__c != null) AND OwnerId = :userId
            ORDER BY card_exchange_date__c DESC NULLS LAST
            LIMIT :limits]) {
        for (NameCard__c n : nameCards) {
          if (n.mobile__c != null) {
            appendPhoneNumber(n.mobile__c, n);
          }
          if (n.tel1__c != null) {
            appendPhoneNumber(n.tel1__c, n);
          }
          if (n.tel2__c != null && n.tel1__c != n.tel2__c) {  // 同じ人で同じ番号ではいってただけではみない
            appendPhoneNumber(n.tel2__c, n);
          }
          // for (String phoneNumber : phoneNumberMap.keySet()) {
          //   SB_Connect_Client client = clientMap.get(phoneNumber);
          //   if (client == null) {
          //     clientMap.put(phoneNumber, new SB_Connect_Client(phoneNumber, phoneNumberMap.get(phoneNumber), n, false));
          //   }
          //   else {
          //     if (n.LastModifiedDate > Datetime.valueOf(client.updated_date)) {
          //       clientMap.put(phoneNumber, new SB_Connect_Client(phoneNumber, phoneNumberMap.get(phoneNumber), n, true));
          //     } else {
          //       client.is_duplicate = true;
          //     }
          //   }
          // }

          if (System.Limits.getLimitCpuTime() - System.Limits.getCpuTime() < 500) {
            break;
          }
        }
        if (System.Limits.getLimitCpuTime() - System.Limits.getCpuTime() < 500) { // 2重のfor loop なのでここでもみる。
          break;
        }
        if (System.Limits.getLimitHeapSize() - System.Limits.getHeapSize() < 1000) { // ヒープもみる。 みないほうがいいかも。。
          break;
        }
        // SV_DEV-2610 SmartVIsca connect：20000件名刺レコードの同期でエラーになる場合がある
        if (clientMap.values().size() > 18000) {
          break;
        }
      }
      return clientMap.values();
    }

    private void appendPhoneNumber(String value, NameCard__c n) {
      // String orginal = value..replaceAll('[^0-9]', '');
      String orginal = value.replaceAll('\\D', '');  // 文字列から数字を抽出します。 こっちのほうが速そう。
      String i18nNum = convertPhoneNumber(orginal);
      if (!this.clientMap.containsKey(i18nNum)) {
        this.clientMap.put(i18nNum, new SB_Connect_Client(i18nNum, orginal, n, false));
      }
      else {
        this.clientMap.get(i18nNum).setDuplicate(n);
      }
    }

    /**
     * 電話番号から、ハイフン、括弧の文字を消去し、
     * 電話番号の先頭が0始まりでない場合はそのまま、
     * 電話番号が0始まりの場合はデフォルトの国番号を付与した国際電話番号形式に変換します。  → 国項目がないオブエジェクト用
     *
     * @param phoneNumber 電話番号
     * @return 変換した電話番号
     */
    private String convertPhoneNumber(String phoneNumber) {
      if (!phoneNumber.startsWith('0')) {
          return phoneNumber;
      }
      return phoneNumber.replaceFirst('0', this.util.getDefaultContryCode());
    }

    /**
      * 電話番号から、ハイフン、括弧の文字を消去して国際電話番号形式に変換します。
      * 電話番号の先頭が0始まりでない場合はそのまま、
      * 電話番号が0始まりの場合は国番号を付与した国際電話番号形式に変換します。 → 国項目があるオブエジェクト用
      *
      * @param phoneNumber 電話番号
      * @param countryName 国名
      * @return 国番号始まりの電話番号
      */
    private String convertPhoneNumber(String phoneNumber, String countryName) {
        if (!phoneNumber.startsWith('0')) {
            return phoneNumber;
        }
        String countryCode = this.util.getCallingCode(countryName);
        return phoneNumber.replaceFirst('0', countryCode);
    }

  }

  // SV_DEV-2613 SmartVIsca connect：名刺の参照権限がないユーザでデータの同期が行えてしまう場合がある。
  private static Boolean havePermission() {
    DescribeSObjectResult dsr = NameCard__c.getSObjectType().getDescribe();
    if (dsr.isAccessible()) {
      Set<Schema.DescribeFieldResult> dfrs = new Set<Schema.DescribeFieldResult> {
        Schema.SObjectType.NameCard__c.fields.tel1__c,
        Schema.SObjectType.NameCard__c.fields.tel2__c,
        Schema.SObjectType.NameCard__c.fields.mobile__c,
        Schema.SObjectType.NameCard__c.fields.company_name__c };
      for (Schema.DescribeFieldResult dfr : dfrs) {
        System.debug(dfr.getLabel());
        if (!dfr.isAccessible()) {
          return false;
        }
      }
      return true;
    }
    return false;
  }

}