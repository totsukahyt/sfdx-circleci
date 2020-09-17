/**
 *  sb_nc_ownerListItem.js
 *      
 *  @author sawano
 *  @Version1 2019.06.xx v2.4 SV_DEV-1593 LEX画面の名刺詳細から「同じ人の名刺を持つユーザ」を確認できるようにしてほしい
 *  
 */

import { LightningElement, api } from 'lwc';
// import LANG from '@salesforce/i18n/lang';
import exchangedate from '@salesforce/label/c.SB_NCS1C_Label_NCExchangeDate';

export default class Sb_nc_ownerListItem extends LightningElement {
  @api user;
  @api showdate;
  // lang = LANG;
  label = {
    exchangedate
  };

  handleClick(event) {
    // 1. Prevent default behavior of anchor tag click which is to navigate to the href url
    event.preventDefault();
    // 2. Read about event best practices at http://developer.salesforce.com/docs/component-library/documentation/lwc/lwc.events_best_practices
    const selectEvent = new CustomEvent('select', {
        detail: this.user.id
    });
    // 3. Fire the custom event
    this.dispatchEvent(selectEvent);
  }

  handleDateClick(event) {
    // 1. Prevent default behavior of anchor tag click which is to navigate to the href url
    event.preventDefault();
    // 2. Read about event best practices at http://developer.salesforce.com/docs/component-library/documentation/lwc/lwc.events_best_practices
    const selectEvent = new CustomEvent('select', {
        detail: this.user.cardId
    });
    // 3. Fire the custom event
    this.dispatchEvent(selectEvent);
  }  
}