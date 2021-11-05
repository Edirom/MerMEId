package mermeid;


import org.junit.Assert;
import org.junit.Test;
import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;



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
    public void MermeidTest(){
       // driver.get("http://localhost:8080/index.html");
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
