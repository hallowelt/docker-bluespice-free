var page = require('webpage').create();
page.customHeaders = {
	"User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) HalloWelt/1.0",
	"Accept-Language": 'en;q=0.8'
};

page.open('https://bluespice.com/docker.html', function() {
    setTimeout(function() {
        page.render('/dev/null');
        phantom.exit();
    }, 200);
});
