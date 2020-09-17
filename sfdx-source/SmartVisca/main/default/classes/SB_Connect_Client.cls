/**
 * @File Name          : SB_Connect_Client.cls
 * @Description        : 顧客情報
 * @Author             : 西根哲史
 * @Group              :
 * @Last Modified By   : 西根哲史
 * @Last Modified On   : 2020/3/26 12:11:22
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    2020/1/30   西根哲史     Initial Version
 * 2.0    2020/5/14   sawano      v2.5.1 重複用メソッド追加、名刺だけなら日付関連は不要なので削ります。
**/
public with sharing class SB_Connect_Client {

  /** 電話番号 */
  public String phone_number {get; private set;}

  /** 国番号付与処理なしのSalesforceに入力されたものから数字以外の文字を消した電話番号 */
  public String original_phone_number {get; private set;}

  /** 姓名 */
  public String full_name {get; private set;}

  /** 企業名 */
  public String enterprise_name {get; private set;}

  /** 重複フラグ */
  public Boolean is_duplicate {get; private set;}

  // /** 登録日時 */
  // public String registered_date {get; private set;}

  // /** 更新日時 */
  // public String updated_date {get; private set;}

  /** v2.5.1 b1 メールアドレス、個人識別用  */
  public String email {get; private set;}
  /** v2.5.1 b2 レコードID 障害時調査用とか  */
  public Id rec_id {get; private set;}

  // /**
  //   * コンストラクタ
  //   *
  //   * @param phoneNumber 電話番号
  //   * @param originalPhoneNumber 国番号付与処理なしの電話番号
  //   * @param c 取引先責任者
  //   * @param isDuplicate 重複フラグ
  //   */
  // public SB_Connect_Client(String phoneNumbedr, String originalPhoneNumber, Contact c, Boolean isDuplicate) {
  //     this.phone_number = phoneNubedr;
  //     this.original_phone_number = originalPhoneNumber;
  //     this.full_name = c.Name;
  //     this.enterprise_name = String.isNotBlank(c.Account.Name) ? c.Account.Name : '';
  //     this.is_duplicate = isDuplicate;
  //     this.registered_date = String.valueOf(c.CreatedDate);
  //     this.updated_date = String.valueOf(c.LastModifiedDate);
  //     this.email = String.isNotBlank(c.Email) ? c.Email : '';
  //     this.rec_id = c.Id;
  // }

  /**
    * コンストラクタ
    *
    * @param phoneNumber 電話番号
    * @param originalPhoneNumber 国番号付与処理なしの電話番号
    * @param n 名刺
    * @param isDuplicate 重複フラグ
    */
  public SB_Connect_Client(String phoneNumber, String originalPhoneNumber, NameCard__c n, Boolean isDuplicate) {
    this.phone_number = phoneNumber;
    this.original_phone_number = originalPhoneNumber;
    this.full_name = n.Name;
    this.enterprise_name = String.isNotBlank(n.company_name__c) ? n.company_name__c : '';
    this.is_duplicate = isDuplicate;
    // this.registered_date = String.valueOf(n.CreatedDate);
    // this.updated_date = String.valueOf(n.LastModifiedDate);
    this.email = String.isNotBlank(n.email__c) ? n.email__c : '';
    this.rec_id = n.Id;
  }

  // public void setDuplicate(Boolean b) {
  //   this.is_duplicate = b;
  // }

  public void setDuplicate(NameCard__c n) {
    if (this.is_duplicate || this.email == n.email__c || (n.Name == this.full_name && n.company_name__c == this.enterprise_name)) {
      return;
    }
    this.is_duplicate = true;
  }

}