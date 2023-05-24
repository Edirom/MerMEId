package mermeid;


import org.junit.jupiter.api.MethodOrderer;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestMethodOrder;
import org.openqa.selenium.By;
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


@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class EditorTest extends WebDriverSettings {

    @Test
    @Order(1)
    public void OpenEditPage(){
        System.out.println("**************************");
        System.out.println("* Test 1: `OpenEditPage` *");
        System.out.println("**************************");

        String title = driver.getTitle();
        System.out.println("Title: " + title);
        assertTrue(title.equals("MerMEId – Metadata Editor and Repository for MEI Data"));

        WebElement button = driver.findElement(By.cssSelector("button"));
        String buttonText = button.getText();
        System.out.print("Function `OpenEditPage` log: ");
        System.out.println(buttonText);

        assertTrue(buttonText.equals("Try MerMEId"));

        Common.enterLogin();
        WebElement editButton = driver.findElement(By.xpath("//form[@action='http://localhost:8080/forms/edit-work-case.xml'][input/@value='incipit_demo.xml']/button"));
        editButton.click();

        try {
            new WebDriverWait(driver, Duration.ofSeconds(10)).until(ExpectedConditions.titleContains("MerMEId "));
        }
        catch(org.openqa.selenium.TimeoutException e) {
            System.out.print("Test `OpenEditPage` log: ");
            System.out.println("Timed out waiting for edit page to load!");
            assertTrue(false);
        }
    }

    @Test
    @Order(2)
    public void checkWorkTabInputText(){
        System.out.println("***********************************");
        System.out.println("* Test 2: `checkWorkTabInputText` *");
        System.out.println("***********************************");

        String randomString = Common.generatingRandomAlphabeticString();
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(10));
        Actions builder = new Actions(driver);

        Common.enterLogin();
        WebElement editButton = driver.findElement(By.xpath("//form[@action='http://localhost:8080/forms/edit-work-case.xml'][input/@value='incipit_demo.xml']/button"));
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
        // assert that there are 5 changed text inputs
        assertEquals(6, changedIds.size());

        // Save changes and return to main menu
        Common.saveChangesAndReturnToMainPage();

        // Reopen edit pane
        editButton = driver.findElement(By.xpath("//form[@action='http://localhost:8080/forms/edit-work-case.xml'][input/@value='incipit_demo.xml']/button"));
        editButton.click();
        // wait for page to have loaded
        wait.until(ExpectedConditions.elementToBeClickable(By.xpath("//span[@id='xf-293']/a")));

        // check changes
        for (String id: changedIds) {
            System.out.print("Checking input text for id: ");
            System.out.println(id);
            Common.checkText(driver.findElement(By.id(id)), randomString);
        }
    }

    @Test
    @Order(3)
    public void checkWorkTabPopupInputText(){
        System.out.println("****************************************");
        System.out.println("* Test 3: `checkWorkTabPopupInputText` *");
        System.out.println("****************************************");

        String randomString = Common.generatingRandomAlphabeticString();
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(10));
        Actions builder = new Actions(driver);

        Common.enterLogin();
        WebElement editButton = driver.findElement(By.xpath("//form[@action='http://localhost:8080/forms/edit-work-case.xml'][input/@value='incipit_demo.xml']/button"));
        editButton.click();

        // hover over "add more titles"
        WebElement addTitlesButton =
            wait.until(ExpectedConditions.elementToBeClickable(By.xpath("//span[@id='xf-293']/a")));
        builder.moveToElement(addTitlesButton).perform();

        // Add rows for additional titles
        List<WebElement> buttons = addTitlesButton.findElements(By.xpath(".//button"));
        // assert that there are 5 buttons
        assertEquals(5, buttons.size());
        // iterate over buttons and add rows for additional titles
        for (WebElement button: buttons) {
            System.out.println(button.getText());
            builder.moveToElement(button).perform();
            button.click();
        }

        // set text inputs to $randomString$
        // and assert that there are 48 text inputs on the page (most of them invisible)
        List<WebElement> inputs =
            wait.until(ExpectedConditions.numberOfElementsToBe(By.xpath("//input[@type='text']"), 51));

        // array to be filled with changed ids
        ArrayList<String> changedIds = new ArrayList<String>();
        // iterate over text inputs and set to $randomString$
        for (WebElement input: inputs) {
            if (input.isDisplayed()) {
                System.out.print("Setting input text for id: ");
                System.out.println(input.getAttribute("id"));
                Common.setText(input, randomString);
                changedIds.add(input.getAttribute("id"));
            }
        }
        // assert that there are 10 changed text inputs
        assertEquals(11, changedIds.size());

        // Save changes and return to main menu
        Common.saveChangesAndReturnToMainPage();

        // Reopen edit pane
        editButton = driver.findElement(By.xpath("//form[@action='http://localhost:8080/forms/edit-work-case.xml'][input/@value='incipit_demo.xml']/button"));
        editButton.click();


        // check changes
        for (String id: changedIds) {
            System.out.print("Checking input text for id: ");
            System.out.println(id);
            Common.checkText(driver.findElement(By.id(id)), randomString);
        }

        // cleanup: remove additional title rows again
        WebElement titlesFieldset =
            wait.until(ExpectedConditions.elementToBeClickable(By.xpath("//fieldset[legend='Titles']")));
        List<WebElement> removeButtons = titlesFieldset.findElements(By.xpath(".//a[img/@title='Delete row']"));
        for (WebElement removeButton: removeButtons) {
            System.out.print("Removing row for id: ");
            System.out.println(removeButton.getAttribute("id"));
            removeButton.click();
        }

        // Save changes and return to main menu
        Common.saveChangesAndReturnToMainPage();
    }


    
    // This function is not called anywhere, hence commenting out (PS)
    /*private void checkAfterRemove(ArrayList<String> removeIds) {
        for (String id: removeIds) {
            try {
                Thread.sleep(3000);
                if(driver.findElements(By.id(id)).size() != 0){
                    System.out.println("Test log: " + "Item with id: " +id + " was not deleted");
                    assertTrue(false);
                }

            } catch(InterruptedException e) {
                System.out.print("Test log: ");
                System.out.println("got interrupted!");
            }
        }
    }*/

    //

}
