package mermeid;


import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.openqa.selenium.By;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.interactions.Actions;
import org.openqa.selenium.support.ui.WebDriverWait;
import org.openqa.selenium.support.ui.ExpectedConditions;

import java.time.Duration;
import java.util.ArrayList;
import java.util.List;


import static net.bytebuddy.matcher.ElementMatchers.is;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.junit.jupiter.api.Assertions.assertEquals;
public class HTMLRenderingTest extends WebDriverSettings{
    @Test
    @Order(1)
    public void checkHTMLRendering(){
        System.out.println("***********************************");
        System.out.println("* Test: `checkHTMLRendering` *");
        System.out.println("***********************************");

        String randomString = Common.generatingRandomAlphabeticString();
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(10));
        Actions builder = new Actions(driver);

        Common.enterLogin();
        WebElement editButton = driver.findElement(By.xpath("//form[@action='http://localhost:8080/forms/edit-work-case.xml'][input/@value='nielsen_maskarade.xml']/button"));
        editButton.click();


        // wait for page to have loaded
        wait.until(ExpectedConditions.elementToBeClickable(By.xpath("//span[@id='xf-293']/a")));

        // set text inputs with randomString
        List<WebElement> inputs = driver.findElements(By.xpath("//input[@type='text']"));
        ArrayList<String> changedIds = new ArrayList<String>();
        for (WebElement input: inputs) {
            if (input.isDisplayed()) {
                System.out.print("Setting input text for id: ");
                System.out.println(input.getAttribute("id"));
                Common.setText(input, randomString);
                changedIds.add(input.getAttribute("id"));
            }
        }

        // Save changes and return to main menu
        Common.saveChangesAndReturnToMainPage();

        // open html rendering page

        driver.get("http://localhost:8080/modules/present.xq?doc=nielsen_maskarade.xml");
        wait = new WebDriverWait(driver, Duration.ofSeconds(10));

        try {
            //check composer
            assertEquals(driver.findElement(By.cssSelector(".composer_top")).getText(), randomString);
//che       //check title and subtitle
            assertEquals(driver.findElement(By.cssSelector(".work_title > .preferred_language")).getText(), randomString);
            assertEquals(driver.findElement(By.cssSelector(".subtitle > .preferred_language")).getText(), randomString);

            assertEquals(driver.findElement(By.cssSelector(".work_title > .alternative_language")).getText(), randomString);
            assertEquals(driver.findElement(By.cssSelector(".subtitle > .alternative_language")).getText(), randomString);


            assertEquals(driver.findElement(By.xpath("//div[@id=\'main_content\']/p[3]")).getText(), "Author: " + randomString);

            assertEquals(driver.findElement(By.xpath("//div[@id=\'main_content\']/p[4]")).getText(), randomString);


        } catch(org.openqa.selenium.TimeoutException e) {
            System.out.println("Timed out waiting for page 'http://localhost:8080/modules/present.xq?doc=nielsen_maskarade.xml'!");
            assertTrue(false);
        }
        catch(NoSuchElementException e){
            assertTrue(false);
        }

        // check changes
       /* for (String id: changedIds) {
            System.out.print("Checking input text for id: ");
            System.out.println(id);
            checkText(driver.findElement(By.id(id)), randomString);
        }*/

    }
}
