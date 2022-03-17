<?php
$wgArticlePath = "/wiki/$1";
$wgUsePathInfo = true;
wfLoadExtension( 'VisualEditor' );
wfLoadExtension( 'PdfHandler');
$wgMainCacheType = CACHE_MEMCACHED;
$wgMemCachedServers = [ "127.0.0.1:11211" ];
wfLoadExtension( 'BlueSpiceExtendedSearch' );
$GLOBALS['wgSearchType'] = 'BS\\ExtendedSearch\\MediaWiki\\Backend\\BlueSpiceSearch';
wfLoadExtension( 'BlueSpicePrivacy' );
wfLoadExtension( "BlueSpiceUEModulePDF" );
wfLoadExtension( "BlueSpiceVisualEditorConnector" );
$GLOBALS['bsgVisualEditorConnectorUploadDialogType'] = 'simple';
$GLOBALS['wgUploadDialog']['fields']['categories'] = true;
$GLOBALS['wgUploadDialog']['format']['filepage'] = '$DESCRIPTION $CATEGORIES';
$wgDefaultUserOptions['visualeditor-enable'] = 1;
$wgDefaultUserOptions['visualeditor-enable-experimental'] = 1;
$wgDefaultUserOptions['visualeditor-newwikitext'] = 1;
$wgHiddenPrefs[] = 'visualeditor-enable';
$wgHiddenPrefs[] = 'visualeditor-newwikitext';
$wgVisualEditorAvailableNamespaces = [
    NS_MAIN => true,
    NS_USER => true,
    102 => true,
    "_merge_strategy" => "array_plus"
];
$wgVisualEditorEnableWikitext = true;

wfLoadExtension( 'Parsoid', "$IP/vendor/wikimedia/parsoid/extension.json" );
$wgVirtualRestConfig['modules']['parsoid'] = array(
        'url' => 'http://localhost:10080/w/rest.php/',
        'forwardCookies' => true
);
