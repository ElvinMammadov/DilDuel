package com.Dictionary;

import androidx.test.ext.junit.runners.AndroidJUnit4;
import androidx.test.filters.LargeTest;
import androidx.test.rule.ActivityTestRule;

import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;

import static androidx.test.espresso.Espresso.onView;
import static androidx.test.espresso.action.ViewActions.click;
import static androidx.test.espresso.action.ViewActions.typeText;
import static androidx.test.espresso.assertion.ViewAssertions.matches;
import static androidx.test.espresso.matcher.ViewMatchers.isDisplayed;
import static androidx.test.espresso.matcher.ViewMatchers.withId;
import static androidx.test.espresso.matcher.ViewMatchers.withText;
import static org.junit.Assert.assertEquals;


@RunWith(AndroidJUnit4.class)
@LargeTest
public class GettingTranslationTest {

    @Rule
    public ActivityTestRule<MainActivity> activityRule =
            new ActivityTestRule<>(MainActivity.class);

    @Test
    public void typeTextInSearchField() {
        onView(withId(R.id.edit_search))
                .perform(click()).perform(typeText("abb"));
    }

    @Test
    public void typingTextGivesResults() throws InterruptedException {
        onView(withId(R.id.edit_search))
                .perform(click()).perform(typeText("abb"));
        Thread.sleep(2000);
        onView(withText("abberufen")).check(matches(isDisplayed()));
    }
}

