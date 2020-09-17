var SLDS=webpackJsonpSLDS([29,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123],{0:function(e,t){e.exports=React},111:function(e,t,l){"use strict";function s(e){return e&&e.__esModule?e:{default:e}}function a(e,t){var l={};for(var s in e)t.indexOf(s)>=0||Object.prototype.hasOwnProperty.call(e,s)&&(l[s]=e[s]);return l}Object.defineProperty(t,"__esModule",{value:!0}),t.examples=t.states=t.Toast=void 0;var n=s(l(0)),i=l(3),d=l(12),r=(s(l(2)),s(l(1))),m=function(e){var t=e.containerClassName,l=e.className,s=e.type,d=e.children;a(e,["containerClassName","className","type","children"]);return n.default.createElement("div",{className:(0,r.default)("slds-notify_container",t)},n.default.createElement("div",{className:(0,r.default)("slds-notify slds-notify_toast",l,s?"slds-theme_"+s:null),role:"alert"},n.default.createElement("span",{className:"slds-assistive-text"},s||"info"),d,n.default.createElement(i.ButtonIcon,{className:"slds-notify__close slds-button_icon-inverse",iconClassName:"slds-button__icon_large",symbol:"close",assistiveText:"Close",title:"Close"})))};t.Toast=m,t.default=n.default.createElement("div",{className:"demo-only",style:{height:"4rem"}},n.default.createElement(m,{type:"info",containerClassName:"slds-is-relative"},n.default.createElement(d.UtilityIcon,{containerClassName:"slds-m-right_small slds-no-flex slds-align-top",className:"slds-icon_small",assistiveText:!1,symbol:"info"}),n.default.createElement("div",{className:"slds-notify__content"},n.default.createElement("h2",{className:"slds-text-heading_small"},"26 potential duplicate leads were found. ",n.default.createElement("a",{href:"javascript:void(0);"},"Select Leads to Merge")))));t.states=[{id:"success",label:"Success",element:n.default.createElement("div",{className:"demo-only",style:{height:"4rem"}},n.default.createElement(m,{type:"success",containerClassName:"slds-is-relative"},n.default.createElement(d.UtilityIcon,{containerClassName:"slds-m-right_small slds-no-flex slds-align-top",className:"slds-icon_small",assistiveText:!1,symbol:"success"}),n.default.createElement("div",{className:"slds-notify__content"},n.default.createElement("h2",{className:"slds-text-heading_small "},"Account ",n.default.createElement("a",{href:"javascript:void(0);"},"ACME - 100")," widgets was created."))))},{id:"warning",label:"Warning",element:n.default.createElement("div",{className:"demo-only",style:{height:"4rem"}},n.default.createElement(m,{type:"warning",containerClassName:"slds-is-relative"},n.default.createElement(d.UtilityIcon,{containerClassName:"slds-m-right_small slds-no-flex slds-align-top",className:"slds-icon_small",assistiveText:!1,symbol:"warning"}),n.default.createElement("div",{className:"slds-notify__content"},n.default.createElement("h2",{className:"slds-text-heading_small "},"Can’t share file “report-q3.pdf” with the selected users."))))},{id:"error",label:"Error",element:n.default.createElement("div",{className:"demo-only",style:{height:"4rem"}},n.default.createElement(m,{type:"error",containerClassName:"slds-is-relative"},n.default.createElement(d.UtilityIcon,{containerClassName:"slds-m-right_small slds-no-flex slds-align-top",className:"slds-icon_small",assistiveText:!1,symbol:"error"}),n.default.createElement("div",{className:"slds-notify__content"},n.default.createElement("h2",{className:"slds-text-heading_small "},"Can’t save lead “Sally Wong” because another lead has the same name."))))},{id:"error-with-details",label:"Error With Details",element:n.default.createElement("div",{className:"demo-only",style:{height:"4rem"}},n.default.createElement(m,{type:"error",containerClassName:"slds-is-relative"},n.default.createElement(d.UtilityIcon,{containerClassName:"slds-m-right_small slds-no-flex slds-align-top",className:"slds-icon_small",assistiveText:!1,symbol:"error"}),n.default.createElement("div",{className:"slds-notify__content"},n.default.createElement("h2",{className:"slds-text-heading_small"},"You've encountered some errors when trying to save edits to Samuel Smith."),n.default.createElement("p",null,"Here's some detail of what happened, being very descriptive and transparent."))))}],t.examples=[{id:"small",label:"Small Column",element:n.default.createElement("div",{className:"demo-only",style:{height:"4rem",width:"25rem"}},n.default.createElement("div",{className:"slds-region_narrow slds-is-relative"},n.default.createElement(m,{type:"info",containerClassName:"slds-is-absolute"},n.default.createElement("div",{className:"slds-notify__content"},n.default.createElement("h2",{className:"slds-text-heading_small"},"26 potential duplicate leads were found.")))))}]}},[111]);