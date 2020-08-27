require("chromedriver");
require("date-utils");
require("jquery")
const assert = require('assert');
const webdriver =  require("selenium-webdriver");
const { Builder, By, until } = webdriver;
const path = require('path')
var chrome = require('selenium-webdriver/chrome');
const fs = require('fs');
var LOGIN_INFO
var options   = new chrome.Options().addArguments('--headless').addArguments('--disable-gpu').addArguments('--no-sandbox').addArguments('--window-size=1920x1080');


let driver;
let iframe;
const npw = "sohoTest1"

describe("SeleniumChromeTest", () => {
  before(() => {
    driver = new Builder().forBrowser('chrome').withCapabilities(options).build();
    LOGIN_INFO = fs.readFileSync("./qa_userPassword.json")
    LOGIN_INFO = JSON.parse(LOGIN_INFO).result
  });

  after(() => {
    // return driver.quit();
  });

  it("login salesforce", async () => {
    
    
    let url = LOGIN_INFO.instanceUrl+"/secur/frontdoor.jsp?sid="+LOGIN_INFO.accessToken
    await driver.get(url);

      await driver.wait(until.elementLocated(By.xpath('//*[@id="username"]')),10);
      await driver.findElement(By.id("username")).sendKeys(LOGIN_INFO.username)
      await driver.findElement(By.id("password")).sendKeys(LOGIN_INFO.password)
      await driver.findElement(By.id("Login")).click();

      await driver.wait(until.elementLocated(By.id("currentpassword")),10000);
      await driver.findElement(By.id("currentpassword")).sendKeys(LOGIN_INFO.password);
      await driver.findElement(By.id("newpassword")).sendKeys(npw);
      await driver.findElement(By.id("confirmpassword")).sendKeys(npw);
      await driver.findElement(By.id("answer")).sendKeys('東京');
      await driver.findElement(By.id("password-button")).click();

  });

  it("フィード追跡", async () => {
    let shareUrl = LOGIN_INFO.instanceUrl + "/lightning/setup/FeedTracking/home";
    await driver.get(shareUrl)

    await driver.wait(until.elementLocated(By.xpath('//*[@id="setupComponent"]/div[2]/div/force-aloha-page/div/iframe')))
    iframe = await driver.findElement(By.xpath('//*[@id="setupComponent"]/div[2]/div/force-aloha-page/div/iframe'))
    await driver.switchTo().frame(iframe);

    await driver.wait(until.elementsLocated(By.xpath('//a[@title="NameCard"]')),10000)
    await driver.findElement(By.xpath('//a[@title="NameCard"]')).click()
    await driver.wait(until.elementsLocated(By.xpath('//input[@id="j_id0:j_id7:toolbarTop:j_id32:enableTracking"]')),5000)
    const checkbox = await driver.findElement(By.xpath('//input[@id="j_id0:j_id7:toolbarTop:j_id32:enableTracking"]'))
    const isCheck = await checkbox.getAttribute("checked")
    if(!isCheck ||isCheck === null){
      await checkbox.click()
      console.log("有効化")
      await driver.findElement(By.xpath('//input[@value="保存"]')).click()
    }
    
    takeScreenShot('feed')
  })

});


async function takeScreenShot(name){
  let base64 = await driver.takeScreenshot();
  let buffer = Buffer.from(base64, 'base64');

  await fs.writeFileSync('screenshots/'+name+'.jpg',buffer)
}
