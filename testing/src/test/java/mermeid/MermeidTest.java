package mermeid;


import org.junit.Assert;
import org.junit.Test;
import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;

import java.util.ArrayList;
import java.util.Random;


public class MermeidTest extends WebDriverSettings {
    public void enterLogin(){
        driver.get("http://localhost:8080/index.html");
        WebElement button = driver.findElement(By.cssSelector("button"));
        button.click();

        driver.findElement(By.id("user")).sendKeys("mermeid");
        driver.findElement(By.id("password")).sendKeys("mermeid");

        WebElement submit = driver.findElement(By.cssSelector("button"));
        submit.click();


    }
    @Test
    public void OpenEditPage(){
        String title = driver.getTitle();
        Assert.assertTrue(title.equals("MerMEId – Metadata Editor and Repository for MEI Data"));

        WebElement button = driver.findElement(By.cssSelector("button"));
        String buttonText = button.getText();
        System.out.println(buttonText);
        Assert.assertTrue(buttonText.equals("Try MerMEId"));

        enterLogin();

        WebElement edit = driver.findElement(By.cssSelector("[href=\"../forms/edit-work-case.xml?doc=incipit_demo.xml\"]"));
        edit.click();

    }

    public void setText(ArrayList<String> ids, String text ){
        for (String id: ids) {
            driver.findElement(By.id(id)).clear();
            driver.findElement(By.id(id)).sendKeys(text);
        }
    }

    public void checkText(ArrayList<String> ids, String expected_text ){
        for (String id: ids) {
            //checkTitle
            WebElement input_title = driver.findElement(By.id(id));

            String text =input_title.getAttribute("value");
            System.out.println(expected_text);
            Assert.assertTrue(text.equals(expected_text));
        }

    }

    @Test
    public void checkWorkTabInputText(){
        enterLogin();
        WebElement edit = driver.findElement(By.cssSelector("[href=\"../forms/edit-work-case.xml?doc=incipit_demo.xml\"]"));
        edit.click();

        // driver.findElement(By.id("work-tab")).click();


        String randomString = generatingRandomAlphabeticString();

        //ids for input text
        ArrayList<String> ids = new ArrayList<String>();
        ids.add("xf-216≡xforms-input-1⊙1");
        ids.add("xf-301≡xforms-input-1⊙1");
        ids.add("xf-309≡xf-2011≡xforms-input-1⊙1");
        ids.add("xf-370≡xforms-input-1⊙1");


        setText(ids, randomString );

        //save changes
        driver.findElement(By.id("save-button-image")).click();
        driver.findElement(By.id("home-button-image")).click();


        //open edit view
        driver.get("http://localhost:8080/modules/list_files.xq");
        edit = driver.findElement(By.cssSelector("[href=\"../forms/edit-work-case.xml?doc=incipit_demo.xml\"]"));
        edit.click();

        //check changes
        checkText(ids, randomString);


    }


    public String generatingRandomAlphabeticString() {
        int leftLimit = 97; // letter 'a'
        int rightLimit = 122; // letter 'z'
        int targetStringLength = 10;
        Random random = new Random();

        String generatedString = random.ints(leftLimit, rightLimit + 1)
                .limit(targetStringLength)
                .collect(StringBuilder::new, StringBuilder::appendCodePoint, StringBuilder::append)
                .toString();

        return generatedString;
    }

   /* @Test
    public void firstTest(){
        driver.get("http://localhost:8080/index.html");
        String title = driver.getTitle();
        Assert.assertTrue(title.equals("MerMEId – Metadata Editor and Repository for MEI Data"));
    }
    @Test
    public void clickTryMermeid(){
        driver.get("http://localhost:8080/index.html");
        WebElement button = driver.findElement(By.cssSelector("button"));
        String buttonText = button.getText();
        System.out.println(buttonText);
        Assert.assertTrue(buttonText.equals("Try MerMEId"));
        button.click();

    }
    @Test
    public void enterLogin(){
        driver.get("http://localhost:8080/index.html");
        WebElement button = driver.findElement(By.cssSelector("button"));
        button.click();

        driver.findElement(By.id("user")).sendKeys("mermeid");
        driver.findElement(By.id("password")).sendKeys("mermeid");

        WebElement submit = driver.findElement(By.cssSelector("button"));
        submit.click();


    }*/
  /*  public static void main(String[] args) {
        System.setProperty("webdriver.chrome.driver", "/Users/olina/Downloads/chromedriver");
        WebDriver driver = new ChromeDriver();
        driver.manage().window().maximize();
        driver.get("http://localhost:8080/index.html");
        System.out.println(driver.getTitle());

        driver.quit();
    }*/
}
