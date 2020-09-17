var SLDS=webpackJsonpSLDS([55,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123],{0:function(e,t){e.exports=React},82:function(e,t,i){"use strict";function a(e){return e&&e.__esModule?e:{default:e}}Object.defineProperty(t,"__esModule",{value:!0}),t.states=void 0;var l=a(i(0)),r=a(i(2)),s=a(i(1)),o=(i(25),function(e){return l.default.createElement("div",{className:(0,s.default)("slds-file-selector slds-file-selector_integrated",e.className)},l.default.createElement("div",{className:(0,s.default)("slds-file-selector__dropzone slds-file-selector__dropzone_integrated",e.drag?"slds-has-drag":null,e.draggover?"slds-has-drag-over":null),"aria-hidden":"true"},l.default.createElement("input",{className:"slds-file-selector__input slds-assistive-text",accept:"image/png",type:"file",id:"file-upload-input-01",disabled:e.draggoverError,tabIndex:"-1"}),l.default.createElement("label",{className:"slds-file-selector__body slds-file-selector__body_integrated",htmlFor:"file-upload-input-01"},e.draggoverError?l.default.createElement(r.default,{className:"slds-file-selector__body-icon slds-icon slds-icon-text-default",sprite:"utility",symbol:"ban"}):l.default.createElement(r.default,{className:"slds-file-selector__body-icon slds-icon slds-icon-text-default",sprite:"utility",symbol:"upload"}),l.default.createElement("span",{className:"slds-file-selector__text slds-file-selector__text_integrated slds-text-heading_medium slds-text-align_center"},e.draggoverError?"Too many files selected. Attach up to 1 file.":"Drop Files"))),e.children)});t.default=l.default.createElement("div",{className:"demo-only",style:{width:"320px",height:"320px"}},l.default.createElement(o,{className:"slds-file-selector_integrated"},"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."));t.states=[{id:"integrated-file-selector-drag",label:"Drag",element:l.default.createElement("div",{className:"demo-only",style:{width:"320px",height:"320px"}},l.default.createElement(o,{className:"slds-file-selector_integrated",drag:!0},"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."))},{id:"integrated-file-selector-draggover",label:"Dragover",element:l.default.createElement("div",{className:"demo-only",style:{width:"320px",height:"320px"}},l.default.createElement(o,{className:"slds-file-selector_integrated",drag:!0,draggover:!0},"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."))},{id:"integrated-file-selector-draggover-error",label:"Dragover with error",element:l.default.createElement("div",{className:"demo-only",style:{width:"320px",height:"320px"}},l.default.createElement(o,{className:"slds-file-selector_integrated",drag:!0,draggoverError:!0,error:!0},"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."))}]}},[82]);