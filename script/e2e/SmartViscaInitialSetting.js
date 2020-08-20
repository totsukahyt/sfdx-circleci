require("chromedriver");
require("date-utils");
require("jquery")
const webdriver =  require("selenium-webdriver");
const { Builder, By, until } = webdriver;
const path = require('path')
var chrome    = require('selenium-webdriver/chrome');
const fs = require('fs');

var options   = new chrome.Options().addArguments('--headless').addArguments('--disable-gpu').addArguments('--no-sandbox').addArguments('--window-size=1920x1080');


let driver;
let iframe;


describe("SeleniumChromeTest", () => {
  before(() => {
    driver = new Builder().forBrowser('chrome').withCapabilities(options).build();
    
  });

  after(() => {
    return driver.quit();
  });

  it("login salesforce", async () => {

    let url = fs.readFileSync("script/e2e/qa_url.txt","utf-8")
              + "/secur/frontdoor.jsp?sid="
              + fs.readFileSync("script/e2e/qa_token.txt","utf-8");
    let un = fs.readFileSync("script/e2e/qa_un.txt","utf-8");
    let opw = fs.readFileSync("script/e2e/qa_pw.txt","utf-8");
    let npw = fs.readFileSync("qa_scratch_pw.txt","utf-8");
    let nwid = fs.readFileSync("network_id.txt","utf-8");
    // let url = " https://power-energy-6468-dev-ed.cs72.my.salesforce.com/secur/frontdoor.jsp?sid=00D5D0000009gpG!AQcAQC8HGVjEsAQDl4bSn4mUWaky0uQhgZcyB3oThgbq.mApSY6p0sRIkA87DmOBuuXhzc.XnI.BK7tx4x_d1sWt3F7NVmYC"
    await driver.get(url);
    
    // 要素を取得
    await driver.wait(until.elementLocated(By.xpath('//*[@id="username"]')));
    await driver.findElement(By.id("username")).sendKeys(un)
    await driver.findElement(By.id("password")).sendKeys(opw)
    await driver.findElement(By.id("Login")).click();

  });

  it("組織の共有設定", async () => {
    let shareUrl = fs.readFileSync("scripts/e2e/qa_inurl.txt","utf-8").replace(/\r?\n/g,"")
    　　　　　　　　+ "/lightning/setup/SecuritySharing/home";
    await driver.wait(until.elementLocated(By.xpath('//*[@value="編集"]')),10)
  })

});

