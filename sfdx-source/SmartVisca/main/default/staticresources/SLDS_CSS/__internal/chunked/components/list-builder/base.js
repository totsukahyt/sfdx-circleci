var SLDS=webpackJsonpSLDS([46,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123],{0:function(e,t){e.exports=React},92:function(e,t,l){"use strict";function a(e){return e&&e.__esModule?e:{default:e}}Object.defineProperty(t,"__esModule",{value:!0}),t.states=void 0;var d=a(l(0)),s=l(11),c=l(36),r=l(8),n=l(22),o=l(18),i=l(9),u=a(l(1)),m=a(l(4)),f=["Name","Product Code","List Price","Product Family"],E=[{name:"Analytics",productCode:"ANTLY",listPrice:"5000.00",productFamily:"Analytics Product"},{name:"Analytics",productCode:"ANTLY",listPrice:"5000.00",productFamily:"Analytics Product"},{name:"Analytics",productCode:"ANTLY",listPrice:"5000.00",productFamily:"Analytics Product"},{name:"Analytics",productCode:"ANTLY",listPrice:"5000.00",productFamily:"Analytics Product"},{name:"Analytics",productCode:"ANTLY",listPrice:"5000.00",productFamily:"Analytics Product"},{name:"Analytics",productCode:"ANTLY",listPrice:"5000.00",productFamily:"Analytics Product"},{name:"Analytics",productCode:"ANTLY",listPrice:"5000.00",productFamily:"Analytics Product"},{name:"Analytics",productCode:"ANTLY",listPrice:"5000.00",productFamily:"Analytics Product"}],b=function(e){return d.default.createElement(r.Listbox,{className:"slds-dropdown slds-dropdown_fluid",vertical:!0},d.default.createElement(r.ListboxItem,null,d.default.createElement(r.EntityOption,{id:"listbox-option-unique-id-01",entityTitle:"Acme",entityMeta:!0,focused:e.focused})),d.default.createElement(r.ListboxItem,null,d.default.createElement(r.EntityOption,{id:"listbox-option-unique-id-02",entityTitle:"Salesforce.com, Inc.",entityMeta:!0})))},p=function(e){return d.default.createElement("div",{className:"slds-p-vertical_x-small slds-p-horizontal_large slds-shrink-none slds-theme_shade"},d.default.createElement(r.ComboboxContainer,{autocomplete:!0,hideLabel:!0,inputIcon:"right",inputIconRightSymbol:"search",listbox:d.default.createElement(b,null)}),e.selectedFilters?e.selectedFilters:null,d.default.createElement("div",{className:"slds-text-title slds-m-top_x-small","aria-live":"polite"},e.itemsSelected||"0"," Item(s) Selected"))},y=function(e){return d.default.createElement("div",{className:"slds-scrollable slds-grow"},d.default.createElement("table",{role:"grid",className:"slds-table slds-table_fixed-layout slds-table_bordered slds-table_resizable-cols slds-no-row-hover slds-scrollable_none"},d.default.createElement("thead",null,d.default.createElement("tr",{className:"slds-line-height_reset"},d.default.createElement("th",{scope:"col",style:{width:"3.75rem"}}),m.default.times(f.length,function(e){return d.default.createElement(n.Th,{key:e,columnName:f[e],"aria-label":f[e]})}))),d.default.createElement("tbody",null,e.children)))},N=function(e){var t="Select item "+e.index;return d.default.createElement("tr",{className:(0,u.default)("slds-hint-parent",e.className),"aria-selected":e.checked},d.default.createElement("td",{role:"gridcell",tabIndex:1===e.index?"0":"-1",className:"slds-text-align_right",style:{width:"3.75rem"}},d.default.createElement(c.CheckboxAddButton,{label:t,checked:e.checked,tabIndex:"-1"})),d.default.createElement("th",{scope:"row"},d.default.createElement("div",{className:"slds-truncate",title:e.name},e.name)),d.default.createElement("td",{role:"gridcell"},d.default.createElement("div",{className:"slds-truncate",title:e.productCode},e.productCode)),d.default.createElement("td",{role:"gridcell"},d.default.createElement("div",{className:"slds-truncate",title:e.listPrice},e.listPrice)),d.default.createElement("td",{role:"gridcell"},d.default.createElement("div",{className:"slds-truncate",title:e.productFamily},e.productFamily)))},h=function(e){return d.default.createElement(o.PillContainer,{className:"slds-pill_container_bare"},d.default.createElement(r.Listbox,{horizonta:!0},d.default.createElement(r.ListboxItem,null,d.default.createElement(i.ListboxPill,{label:"Analytics",tabIndex:"0"}))))},x=function(e){return d.default.createElement(o.PillContainer,{className:"slds-pill_container_bare"},d.default.createElement(r.Listbox,{horizontal:!0},d.default.createElement(r.ListboxItem,null,d.default.createElement(i.ListboxPill,{label:"Option A",tabIndex:"0"})),d.default.createElement(r.ListboxItem,null,d.default.createElement(i.ListboxPill,{label:"Option B"}))))};t.default=d.default.createElement("div",{className:"demo-only",style:{height:"640px"}},d.default.createElement(s.Modal,{className:"slds-modal_large slds-list-builder","aria-labelledby":"id-of-modalheader-h2"},d.default.createElement(s.ModalHeader,null,d.default.createElement("h2",{id:"id-of-modalheader-h2",className:"slds-text-heading_medium"},"Add Products"),d.default.createElement("p",{className:"slds-m-top_x-small"},"Pricebook: Salesforce Products")),d.default.createElement(s.ModalContent,{className:"slds-grid slds-grow"},d.default.createElement("div",{className:"slds-grid slds-grid_vertical"},d.default.createElement(p,null),d.default.createElement(y,null,m.default.times(E.length,function(e){return d.default.createElement(N,{key:e,index:e+1,name:E[e].name,productCode:E[e].productCode,listPrice:E[e].listPrice,productFamily:E[e].productFamily})})))),d.default.createElement(s.ModalFooter,null,d.default.createElement("button",{className:"slds-button slds-button_neutral"},"Cancel"),d.default.createElement("button",{className:"slds-button slds-button_brand"},"Next"))),d.default.createElement("div",{className:"slds-backdrop slds-backdrop_open"}));t.states=[{id:"items-selected",label:"Items selected",element:d.default.createElement("div",{className:"demo-only",style:{height:"640px"}},d.default.createElement(s.Modal,{className:"slds-modal_large","aria-labelledby":"id-of-modalheader-h2"},d.default.createElement(s.ModalHeader,null,d.default.createElement("h2",{id:"id-of-modalheader-h2",className:"slds-text-heading_medium"},"Add Products"),d.default.createElement("p",{className:"slds-m-top_x-small"},"Pricebook: Salesforce Products")),d.default.createElement(s.ModalContent,{className:"slds-grid slds-nowrap"},d.default.createElement("div",{className:"slds-col slds-grid slds-grid_vertical slds-nowrap"},d.default.createElement(p,{selectedFilters:d.default.createElement(h,null),itemsSelected:"1"}),d.default.createElement(y,null,m.default.times(E.length,function(e){return d.default.createElement(N,{key:e,index:e+1,checked:0===e||null,name:E[e].name,productCode:E[e].productCode,listPrice:E[e].listPrice,productFamily:E[e].productFamily})})))),d.default.createElement(s.ModalFooter,null,d.default.createElement("button",{className:"slds-button slds-button_neutral"},"Cancel"),d.default.createElement("button",{className:"slds-button slds-button_brand"},"Next"))),d.default.createElement("div",{className:"slds-backdrop slds-backdrop_open"}))},{id:"filtered",label:"Filtered Results",element:d.default.createElement("div",{className:"demo-only",style:{height:"640px"}},d.default.createElement(s.Modal,{className:"slds-modal_large","aria-labelledby":"id-of-modalheader-h2"},d.default.createElement(s.ModalHeader,null,d.default.createElement("h2",{id:"id-of-modalheader-h2",className:"slds-text-heading_medium"},"Add Products"),d.default.createElement("p",{className:"slds-m-top_x-small"},"Pricebook: Salesforce Products")),d.default.createElement(s.ModalContent,{className:"slds-grid slds-grow"},d.default.createElement("div",{className:"slds-grid slds-grid_vertical"},d.default.createElement(p,{selectedFilters:d.default.createElement(x,null),itemsSelected:"2"}),d.default.createElement(y,null,d.default.createElement(N,{index:1,name:E[0].name,productCode:E[0].productCode,listPrice:E[0].listPrice,productFamily:E[0].productFamily})))),d.default.createElement(s.ModalFooter,null,d.default.createElement("button",{className:"slds-button slds-button_neutral"},"Cancel"),d.default.createElement("button",{className:"slds-button slds-button_brand"},"Next"))),d.default.createElement("div",{className:"slds-backdrop slds-backdrop_open"}))}]}},[92]);