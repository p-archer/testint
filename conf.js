exports.config = {
	seleniumAddress: 'http://localhost:4444/wd/hub',
	framework: 'jasmine2',
	capabilities: {
		browserName: 'chrome',
		chromeOptions: {
			args: [
				'--start-maximized'
			]
		}
	}
};
