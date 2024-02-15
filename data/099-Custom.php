<?php
$wgArticlePath = "/wiki/$1";
wfLoadExtension( 'PdfHandler');
// $wgMainCacheType = CACHE_MEMCACHED;
// $wgMemCachedServers = [ "127.0.0.1:11211" ];
wfLoadExtension( 'BlueSpiceExtendedSearch' );
$GLOBALS['wgSearchType'] = 'BS\\ExtendedSearch\\MediaWiki\\Backend\\BlueSpiceSearch';
wfLoadExtension( "BlueSpiceUEModulePDF" );

// opensearch config
$GLOBALS['bsgESBackendTransport'] = 'http';
// $GLOBALS['bsgESBackendUsername'] = 'admin';
// $GLOBALS['bsgESBackendPassword'] = 'admin';
