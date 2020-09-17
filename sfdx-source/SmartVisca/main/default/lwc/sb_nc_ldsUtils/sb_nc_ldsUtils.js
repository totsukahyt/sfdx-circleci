/**
 *  sb_nc_ldsUtils.js
 *      
 *  @author sawano
 *  @Version1 2019.06.xx v2.4 SV_DEV-1593 LEX画面の名刺詳細から「同じ名刺を持つユーザ」を確認できるようにしてほしい
 *  
 */
/**
 * Reduces one or more LDS errors into a string[] of error messages.
 * @param {FetchResponse|FetchResponse[]} errors
 * @return {String[]} Error messages
 */
// LWC Smaples lwc-recipes
// https://github.com/trailheadapps/lwc-recipes
export function reduceErrors(errors) {
  if (!Array.isArray(errors)) {
      errors = [errors];
  }

  return (
      errors
          // Remove null/undefined items
          .filter(error => !!error)
          // Extract an error message
          .map(error => {
              // UI API read errors
              if (Array.isArray(error.body)) {
                  return error.body.map(e => e.message);
              }
              // UI API DML, Apex and network errors
              else if (error.body && typeof error.body.message === 'string') {
                  return error.body.message;
              }
              // JS errors
              else if (typeof error.message === 'string') {
                  return error.message;
              }
              // Unknown error shape so try HTTP status text
              return error.statusText;
          })
          // Flatten
          .reduce((prev, curr) => prev.concat(curr), [])
          // Remove empty strings
          .filter(message => !!message)
  );
}