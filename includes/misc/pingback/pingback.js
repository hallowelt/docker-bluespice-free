var page = require('webpage').create();
page.customHeaders = {
	"User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) HalloWelt-dfd/3.1.8",
	"Accept-Language": 'en;q=0.8'
};

page.open('https://bluespice.com/docker/', function() {
    setTimeout(function() {
        page.render('/dev/null');
        phantom.exit();
    }, 200);
});
