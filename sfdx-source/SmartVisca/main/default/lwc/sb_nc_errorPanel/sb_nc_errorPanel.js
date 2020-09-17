/**
 *  sb_nc_errPanel.js
 *      
 *  @author sawano
 *  @Version1 2019.06.xx v2.4 SV_DEV-1593 LEX画面の名刺詳細から「同じ名刺を持つユーザ」を確認できるようにしてほしい
 *  
 */
// LWC Smaples lwc-recipes
// https://github.com/trailheadapps/lwc-recipes
import { LightningElement, api, track } from 'lwc';
import { reduceErrors } from 'c/sb_nc_ldsUtils';

export default class Sb_nc_errorPanel extends LightningElement {  
    /** Generic / user-friendly message */
    @api friendlyMessage = 'Error retrieving data';

    @track viewDetails = false;

    /** Single or array of LDS errors */
    @api errors;

    get errorMessages() {
        return reduceErrors(this.errors);
    }

    handleCheckboxChange(event) {
        this.viewDetails = event.target.checked;
    }
}