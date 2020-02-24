/*
* This is an example configuration for a BlueSpiceWikiFarm setup
* In this case 'httpd' is used as wiki webserver machine name as it is in our
* docker environment.
*/
'use strict';

exports.setup = function(parsoidConfig) {
        parsoidConfig.dynamicConfig = function(domain) {
                var baseUrl = Buffer.from( domain, 'base64').toString();
                parsoidConfig.setMwApi({
                        uri: 'http://127.0.0.1/w/api.php',
                        domain: 'bluespice',
                        strictSSL: false
                });
        }
};