package com.example.test;

import android.annotation.SuppressLint;
import android.content.ActivityNotFoundException;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.res.Configuration;
import android.os.Build;
import android.os.Bundle;
import android.speech.RecognizerIntent;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.PopupWindow;
import android.widget.TextView;
import android.widget.Toast;
import android.speech.RecognizerIntent;

import androidx.annotation.RequiresApi;
import androidx.appcompat.app.ActionBarDrawerToggle;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.core.view.GravityCompat;
import androidx.drawerlayout.widget.DrawerLayout;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentTransaction;

import com.google.android.material.navigation.NavigationView;


import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class MainActivity extends AppCompatActivity implements NavigationView.OnNavigationItemSelectedListener{


//    MenuItem menuDeAz;
//    MenuItem menuAzDe;
    MenuItem menuAzer;
    MenuItem menuAlman;
    MenuItem menuProqramDili;
    private PopupWindow pw;
    private Button btnSpeak;
    private Button btnClear,btnChange;
    FrameLayout newFrame;

    private TextView textView1, textView2;

    Toolbar toolbar,toolbar2;

    DBHelper dbHelper;

    DictionaryFragment dictionaryFragment;
    BookmarkFragment bookmarkFragment;

    private final int REQ_CODE_SPEECH_INPUT = 100;


    @RequiresApi(api = Build.VERSION_CODES.JELLY_BEAN_MR1)
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        Application.getInstance().initAppLanguage(this);

        setContentView(R.layout.activity_main);
        toolbar = findViewById(R.id.toolbar);
        toolbar2 = findViewById(R.id.toolbar2);
        newFrame = findViewById(R.id.frame);
        setSupportActionBar(toolbar);

        textView1 = (TextView)findViewById(R.id.dil1);
        textView2 = (TextView)findViewById(R.id.dil2);

//        btnSpeak = (Button) findViewById(R.id.voice);
        btnClear = (Button) findViewById(R.id.clear);
        btnChange = (Button) findViewById(R.id.change);

        btnClear.setVisibility(View.INVISIBLE);
        final EditText editText = findViewById(R.id.edit_search);

        final TextView textView =findViewById(R.id.textView);
        textView.setVisibility(View.INVISIBLE);


        dbHelper = new DBHelper(this);

        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(this,drawer,toolbar,R.string.navigation_drawer_open,
                R.string.navigation_drawer_close);

        drawer.addDrawerListener(toggle);
        toggle.syncState();


        NavigationView navigationView = (NavigationView) findViewById(R.id.nav_view);
        navigationView.setNavigationItemSelectedListener(this);

        dictionaryFragment = new DictionaryFragment();
        bookmarkFragment = BookmarkFragment.getNewInstance(dbHelper);

        goToFragment(dictionaryFragment,true);

        String id =  Global.getState(this,"dic_type");

        Log.i("teze Id",id +" budur");

                if (id == null) {
//                    Global.saveState(this, "dic_type", String.valueOf(id));

                    id = "321";
                    Global.saveState(this, "dic_type", String.valueOf(id));
                    textView1.setText("DE");
                    textView2.setText("AZ");

                    Log.i("I deyishdi oldu",id +" budur");
                    ArrayList<String> source = dbHelper.getWord(Integer.valueOf(id));
                    dictionaryFragment.resetDataSource(source);


        }else if (id.equals("123")) {
                    id = "123";


//                    Global.saveState(this, "dic_type", String.valueOf(id));
                    Global.saveState(this, "dic_type", String.valueOf(id));
                    textView1.setText("AZ");
                    textView2.setText("DE");

                    Log.i("I deyishdi oldu",id +" budur");

                    ArrayList<String> source = dbHelper.getWord(Integer.valueOf(id));

                    dictionaryFragment.resetDataSource(source);
                    Log.i("Item Selected", "az_de");
                }else {

                    Log.i("Burdasan",id +" budur");
                    id = "321";
                    textView1.setText("DE");
                    textView2.setText("AZ");
                    Global.saveState(this, "dic_type", String.valueOf(id));

                    ArrayList<String> source = dbHelper.getWord(Integer.valueOf(id));
                    dictionaryFragment.resetDataSource(source);

                }

        dictionaryFragment.setOnFragmentListener(new FragmentListener() {
            @Override
            public void onItemClick(String value) {

                String id =  Global.getState(MainActivity.this,"dic_type");
                int dicType = id == null? 123:Integer.valueOf(id);

                goToFragment(DetailFragment.getNewInstances(value,dbHelper,dicType),false);
                toolbar.findViewById(R.id.edit_search).setVisibility(View.GONE);
                toolbar.findViewById(R.id.textView).setVisibility(View.VISIBLE);
                newFrame.setVisibility(View.GONE);
                //toolbar2.setVisibility(View.INVISIBLE);
                //toolbar.findViewById(R.id.edit_search).setVisibility(View.GONE);
            }
        });

        bookmarkFragment.setOnFragmentListener(new FragmentListener() {
            @Override
            public void onItemClick(String value) {

                String id =  Global.getState(MainActivity.this,"dic_type");
                int dicType = id == null? 123:Integer.valueOf(id);

                goToFragment(DetailFragmentBookmark.getNewInstances(value,dbHelper),false);

            }
        });

//        btnSpeak.setOnClickListener(new View.OnClickListener() {
//
//            @Override
//            public void onClick(View v) {
//                promptSpeechInput();
//            }
//        });

        btnClear.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                editText.setText("");
                btnClear.setVisibility(View.INVISIBLE);
            }
        });

        btnChange.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {


                int id = 0;

                String a = textView1.getText().toString();

                if(a.equals("AZ")){
                    textView1.setText("DE");
                    textView2.setText("AZ");
                    id = 321;


                    Global.saveState(MainActivity.this,"dic_type",String.valueOf(id));

                    ArrayList<String> source = dbHelper.getWord(id);
                    dictionaryFragment.resetDataSource(source);
                }else if(a.equals("DE")){

                    id = 123;
                    textView1.setText("AZ");
                    textView2.setText("DE");

                    Global.saveState(MainActivity.this,"dic_type",String.valueOf(id));

                    ArrayList<String> source = dbHelper.getWord(id);
                    dictionaryFragment.resetDataSource(source);
                }
            }
        });




        editText.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

//                dictionaryFragment.filterValue(s.toString());

                dictionaryFragment.adapter.getFilter().filter(s);

                if(s.length() > 0){
                    btnClear.setVisibility(View.VISIBLE);
                }else{
                    btnClear.setVisibility(View.INVISIBLE);
                }


            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        });

        }



    /**
     * Receiving speech input
     * */
    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        final EditText editText = findViewById(R.id.edit_search);
        switch (requestCode) {
            case REQ_CODE_SPEECH_INPUT: {
                if (resultCode == RESULT_OK && null != data) {

                    ArrayList<String> result = data
                            .getStringArrayListExtra(RecognizerIntent.EXTRA_RESULTS);
                    editText.setText(result.get(0));
                }
                break;
            }

        }
    }


    @Override
    public void onBackPressed() {
        boolean value = false;

        Fragment fr=getSupportFragmentManager().findFragmentById(R.id.fragment_container);
        String fragmentName = fr.getClass().getSimpleName();
        Log.i("Fragment", " budur " + fragmentName);

        String check= "DetailFragment";

        if(fragmentName.equals(check)){

            value = true;
            Log.i("value", " budur " + value);
            menuAlman.setVisible(true);
            menuAzer.setVisible(true);
            menuProqramDili.setVisible(true);
            toolbar.findViewById(R.id.edit_search).setVisibility(View.VISIBLE);
            toolbar.findViewById(R.id.textView).setVisibility(View.GONE);
            toolbar.setTitle("");
            newFrame.setVisibility(View.VISIBLE);


        }

//        String activeFragment = getSupportFragmentManager().findFragmentById(R.id.fragment_container).getClass().getSimpleName();
//
//        if(activeFragment.equals(DictionaryFragment.class.getSimpleName())) {
//            menuAlman.setVisible(true);
//            menuAzer.setVisible(true);
//            menuProqramDili.setVisible(true);
//            toolbar.findViewById(R.id.edit_search).setVisibility(View.VISIBLE);
//            toolbar.findViewById(R.id.textView).setVisibility(View.GONE);
//            toolbar.setTitle("");
//            newFrame.setVisibility(View.VISIBLE);
//        }



        DrawerLayout drawer =(DrawerLayout) findViewById(R.id.drawer_layout);
        if (drawer.isDrawerOpen(GravityCompat.START)){
            drawer.closeDrawer(GravityCompat.START);

        }else{
            super.onBackPressed();
        }

    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        super.onCreateOptionsMenu(menu);
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.main, menu);

//        menuDeAz = menu.findItem(R.id.de_az);
//        menuAzDe= menu.findItem(R.id.az_de);
        menuAzer = menu.findItem(R.id.azer);
        menuAlman= menu.findItem(R.id.alman);
        menuProqramDili = menu.findItem(R.id.proqramdili);

       String id =  Global.getState(this,"dic_type");

        Log.i("Id",id +" budur");



        return true;
    }

    public boolean onOptionsItemSelected(MenuItem item){

        int id = item.getItemId();



        if (id == R.id.alman){
            Log.i("Idimiz indi ","budur"+id);

            Log.i("Alman id  ","budur "+ R.id.alman);

            LocaleUtils.setSelectedLanguageId("de");
            Intent i = getBaseContext().getPackageManager()
                    .getLaunchIntentForPackage( getBaseContext().getPackageName() );
            i.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_CLEAR_TASK);
            startActivity(i);

            return true;
        }

        else if (id == R.id.azer){
            Log.i("Idimiz indi ","budur"+id);
            Log.i("Az id  ","budur "+ R.id.azer);

        LocaleUtils.setSelectedLanguageId("en");
            Intent i = getBaseContext().getPackageManager()
                    .getLaunchIntentForPackage( getBaseContext().getPackageName() );
            i.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_CLEAR_TASK);
            startActivity(i);


        return true;
    }
        return super.onOptionsItemSelected(item);

    }

    public boolean onNavigationItemSelected(MenuItem item){

        int id = item.getItemId();

        if(id==R.id.nav_bookmark){
            String activeFragment = getSupportFragmentManager().findFragmentById(R.id.fragment_container).getClass().getSimpleName();
            if(!activeFragment.equals(BookmarkFragment.class.getSimpleName())){
                goToFragment(bookmarkFragment,false);
                //toolbar2.setVisibility(View.INVISIBLE);
            }

        }else if(id==R.id.nav_about){

            initiatePopupWindow();

        }else if (id == R.id.nav_share){

            Intent sharingIntent = new Intent(android.content.Intent.ACTION_SEND);
            sharingIntent.setType("text/plain");
            String shareBody = "Here is the share content body";
            sharingIntent.putExtra(android.content.Intent.EXTRA_SUBJECT, "Subject Here");
            sharingIntent.putExtra(android.content.Intent.EXTRA_TEXT, shareBody);
            startActivity(Intent.createChooser(sharingIntent, "Share via"));

        }

        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        drawer.closeDrawer(GravityCompat.START);


        return true;
    }

    void goToFragment(Fragment fragment, boolean isTop){

        FragmentManager fragmentManager = getSupportFragmentManager();
        FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();

        fragmentTransaction.replace(R.id.fragment_container, fragment);

        if (!isTop){
            fragmentTransaction.addToBackStack(null);

        }
        fragmentTransaction.commit();
    }


    @Override
    public boolean onPrepareOptionsMenu(Menu menu) {
       String activeFragment = getSupportFragmentManager().findFragmentById(R.id.fragment_container).getClass().getSimpleName();
       if (activeFragment.equals(BookmarkFragment.class.getSimpleName())){

//           menuDeAz.setVisible(false);
//           menuAzDe.setVisible(false);
           menuAlman.setVisible(false);
           menuAzer.setVisible(false);
           menuProqramDili.setVisible(false);
           toolbar.findViewById(R.id.edit_search).setVisibility(View.GONE);
           toolbar.findViewById(R.id.textView).setVisibility(View.VISIBLE);
           newFrame.setVisibility(View.GONE);

       }else if(activeFragment.equals(DetailFragmentBookmark.class.getSimpleName())) {
//           menuDeAz.setVisible(true);
//           menuAzDe.setVisible(true);
           menuAlman.setVisible(true);
           menuAzer.setVisible(true);
           menuProqramDili.setVisible(true);
           toolbar.findViewById(R.id.edit_search).setVisibility(View.GONE);
           toolbar.findViewById(R.id.textView).setVisibility(View.VISIBLE);
           newFrame.setVisibility(View.GONE);
       }
//       else if(activeFragment.equals(DetailFragment.class.getSimpleName())) {
////           menuDeAz.setVisible(true);
////           menuAzDe.setVisible(true);
//           menuAlman.setVisible(true);
//           menuAzer.setVisible(true);
//           menuProqramDili.setVisible(true);
//           toolbar.findViewById(R.id.edit_search).setVisibility(View.GONE);
//           toolbar.findViewById(R.id.textView).setVisibility(View.VISIBLE);
//           newFrame.setVisibility(View.GONE);
//       }

       else {
//           menuDeAz.setVisible(true);
//           menuAzDe.setVisible(true);
           menuAlman.setVisible(true);
           menuAzer.setVisible(true);
           menuProqramDili.setVisible(true);
           toolbar.findViewById(R.id.edit_search).setVisibility(View.VISIBLE);
           toolbar.findViewById(R.id.textView).setVisibility(View.GONE);
           toolbar.setTitle("");
           newFrame.setVisibility(View.VISIBLE);

       }
       return  true;
    }


    public String idOyren(){

        return Global.getState(this,"dic_type");
    }

    @SuppressWarnings("deprecation")
    private void initiatePopupWindow() {

        LayoutInflater inflater = (LayoutInflater) MainActivity.this
                .getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        @SuppressLint("WrongViewCast") View layout = inflater.inflate(R.layout.custome_dialog_layout,
                (ViewGroup) findViewById(R.id.button_close));
        WindowManager.LayoutParams lp = new WindowManager.LayoutParams();
        lp.width = WindowManager.LayoutParams.FILL_PARENT;
        lp.height = WindowManager.LayoutParams.WRAP_CONTENT;
        pw = new PopupWindow(layout, lp.width, lp.height, true);
        pw.showAtLocation(layout, Gravity.CENTER_VERTICAL, 0, 0);


        ImageButton btnCancel = (ImageButton) layout.findViewById(R.id.button_close);

        btnCancel.setOnClickListener(cancel_click);

    }

    private View.OnClickListener cancel_click = new View.OnClickListener() {
        public void onClick(View v) {
            pw.dismiss();

        }
    };



}


