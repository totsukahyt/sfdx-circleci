/**
 *  sb_nc_cardOwners.js
 *      名刺レコード詳細画面で 同じ人の名刺を持つユーザ をリストする LWC
 * 
 *  @author sawano
 *  @Version1 2019.06.xx v2.4 SV_DEV-1593 LEX画面の名刺詳細から「同じ名刺を持つユーザ」を確認できるようにしてほしい
 *  
 */
import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
// @salesforce Modules https://developer.salesforce.com/docs/component-library/documentation/lwc/lwc.reference_salesforce_modules
import getUsersHavingCard from '@salesforce/apex/SB_NC_CardOwnersLwcController.getUsersHavingCard';
// import { refreshApex } from '@salesforce/apex';
// Access Internalization Properties https://developer.salesforce.com/docs/component-library/documentation/lwc/lwc.create_i18n
// import LANG from '@salesforce/i18n/lang';
// Access Labels https://developer.salesforce.com/docs/component-library/documentation/lwc/lwc.create_labels
import apptitle from '@salesforce/label/c.SB_NCSCOWNER_AppTitle';
import exchangedate from '@salesforce/label/c.SB_NCS1C_Label_NCExchangeDate';
import menu_order from '@salesforce/label/c.SB_NC_MENU_ORDER';
import label_name from '@salesforce/label/c.SB_NC_Name';
import label_dept from '@salesforce/label/c.SB_NC_USER_DEPARTMENT';
// Use the Wire Service to Get Data https://developer.salesforce.com/docs/component-library/documentation/lwc/lwc.data_wire_service_about
import user_name from '@salesforce/schema/User.Name';
import user_department from '@salesforce/schema/User.Department';
import exchange_date from '@salesforce/schema/NameCard__c.card_exchange_date__c';

export default class Sb_nc_cardOwners extends NavigationMixin(LightningElement) {
  @api recordId; // 
  @api titleFields // 所属役職等の表示項目
  @api fields; // 表示するカラム
  @api includeCurrentOwner; // 表示中のレコードの所有者を含める
  @api traceChangeJob; // 転職先名刺も含める
  @api showExchangeDate; // 名刺交換日を表示する
  @api includeInactiveUser;  // 無効なユーザも含める
  @api sortField; // label="並び順(初期値)" type="String" datasource="apex://SB_NC_CardOwnersSortPickList"
  @api sortOrder; // 設定の初期値を保持し続けるlabel="並び順(初期値)" type="String" datasource="apex://SB_NC_CardOwnersSortOrderPickList"
  @track sortAsc;
  @track working=true;   // ローディング中
  @track owners;
  @track selectedOwner;
  @track error;  
  @track showMenu;  
  // lang = LANG;
  label = {
    apptitle,
    exchangedate,
    menu_order,
    label_name,
    label_dept,
    user_name,
    user_department,
    exchange_date
  };

  // The constructor() method is invoked when a component instance is created.
  constructor() {
    super();
    this.fields = "EMail, Phone" ;
    this.titleFields = "CompanyName, Department, Title";
    this.sortField = "name";
    this.sortOrder = "asc";
    this.sortAsc = this.sortOrder !== "desc";  // 並べ替え順の初期値
    this.working = true;  
  }

  // The connectedCallback() lifecycle hook is invoked when a component is inserted into the DOM.
  connectedCallback() {
    this.sortAsc = this.sortOrder !== "desc";  // 並べ替え順の初期値
    this.working = true;  
  }
  // サーバからデータ取得
  // Call Apex Methods https://developer.salesforce.com/docs/component-library/documentation/lwc/apex
  // Wire an Apex Method to a Function
  @wire(getUsersHavingCard, { cardId: '$recordId',
                                excludeMe: false,
                                includeCurrentOwner: '$includeCurrentOwner',
                                includeInactiveUser: '$includeInactiveUser',
                                traceChangeJob: '$traceChangeJob',
                                showExchangeDate: '$showExchangeDate',
                                sortField: '$sortField',
                                sortAsc: '$sortAsc' ,
                                titleFields: '$titleFields',
                                fields: '$fields'}) 
                                wiredOwners({ error, data }) {
                                  if (data) {
                                    this.error = undefined;
                                    this.owners = data.owners;
                                    this.showMenu = this.owners.length > 1;
                                    // refreshApex(this.owners);
                                  } else if (error) {
                                    this.error = error;
                                    this.owners = undefined;
                                    this.showMenu = false;
                                  }
                                  this.working = false;  
                              }

  // ユーザを選択したとき
  handleSelect(event) {
    const userId = event.detail;
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
          recordId: userId,
          // objectApiName: "User",
          actionName: "view"
      }
    });    
  }

  // ソートキーを選択したとき
  handleSortKeySelect(event) {
    const selKey = event.detail.value;
    if (this.sortField === selKey) {
      this.sortAsc = !this.sortAsc;
    }
    else {
      this.sortField = selKey;
      this.sortAsc = this.sortOrder !== "desc";  // 並べ替え順の初期値
    }
    this.working = true;  // ローディング中に
  }

  // 氏名でソート
  get sortName() {
    return this.sortField === "name";
  }
  // 部署でソート
  get sortDept() {
    return this.sortField === "department";
  }
  // 名刺交換日でソート
  get sortExchange() {
    return this.sortField === "exchangeDate";
  }

  // get isShowMenu() {
  //   return this.owners.length > 1;
  // }

}