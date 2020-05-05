package com.example.test;

import android.content.Context;
import android.os.Bundle;
import android.speech.tts.TextToSpeech;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebView;
import android.widget.ImageButton;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import java.util.Locale;


public class DetailFragment extends Fragment {

    private String value = "";
    private TextView tvWord;
    private ImageButton btnBookmark, btnVolume,btnVolumeOff;
    private WebView tvWordTranslate;
    private DBHelper mDBHelper;
    private int mDicType;
    private TextToSpeech mTTS;
    private Word word;

    public DetailFragment() {
        // Required empty public constructor
    }

    public static DetailFragment getNewInstances(String value,DBHelper dbHelper,int dicType){

        DetailFragment fragment = new DetailFragment();
        fragment.value = value;
        fragment.mDBHelper = dbHelper;
        fragment.mDicType = dicType;

        return fragment;


    }


    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        word =  mDBHelper.getWord(value,mDicType);
        word.dicType = mDicType;
        Log.i("Key ","is "+ word.key);
        Log.i("Value ","is "+ word.value);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {

        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.fragment_detail, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        tvWord = (TextView) view.findViewById(R.id.tvWord);
        tvWordTranslate = (WebView) view.findViewById(R.id.tvWordTranslate);
        btnBookmark = (ImageButton) view.findViewById(R.id.btnBookmark);
        btnVolume = (ImageButton) view.findViewById(R.id.btnVolume);

       tvWord.setText(word.key);
       tvWordTranslate.loadDataWithBaseURL(null,word.value,"text/html","utf-8",null);

        String idiniOyren = ((MainActivity)getActivity()).idOyren();

        Log.i("Buranin idisi","budur "+ idiniOyren);

        int azer = 123;
        int alman = 321;

        int ikinciAlman = 2131230830;


        int idiniDeyish = 0;

        if (idiniOyren==null||Integer.parseInt(idiniOyren) == 2131230830){

            idiniDeyish = alman;
        }else if(Integer.parseInt(idiniOyren)==azer){

            idiniDeyish = azer;
        }

        if (azer== idiniDeyish){


            Log.i("Buradasan","azeridir "+ idiniOyren);
            btnVolume.setImageResource(R.drawable.ic_volume_off);

        }else if (alman ==idiniDeyish){


            Log.i("Buradasan","almandir "+ idiniOyren);
            btnVolume.setImageResource(R.drawable.ic_volume_up);

        }else {


            Log.i("Buradasan","almandir "+ idiniOyren);
            btnVolume.setImageResource(R.drawable.ic_volume_up);

        }


       Word bookmarkWord = mDBHelper.getWordFromBookmark(value);
       int isMark = bookmarkWord == null? 0:1;
       btnBookmark.setTag(isMark);


       int icon = bookmarkWord == null? R.drawable.ic_bookmark_border:R.drawable.ic_bookmark_fill;
       btnBookmark.setImageResource(icon);

        btnBookmark.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                int i = (int)btnBookmark.getTag();
                if(i == 0){
                    btnBookmark.setImageResource(R.drawable.ic_bookmark_fill);
                    btnBookmark.setTag(1);
                    mDBHelper.addBookmark(word);
                }else if(i==1){
                    btnBookmark.setImageResource(R.drawable.ic_bookmark_border);
                    btnBookmark.setTag(0);
                    mDBHelper.removeBookmark(word);
                }
            }
        });

        btnVolume.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {



                String idiniOyren = ((MainActivity)getActivity()).idOyren();

                Log.i("Buranin idisi","budur "+ idiniOyren);

                int azer = 123;
                int alman = 321;

                int ikinciAlman = 2131230830;


                int idiniDeyish = 0;

                if (idiniOyren==null||Integer.parseInt(idiniOyren) == 2131230830){

                    idiniDeyish = alman;
                }else if(Integer.parseInt(idiniOyren)==azer){

                    idiniDeyish = azer;
                }
                if (azer== idiniDeyish){

                    Toast.makeText(getActivity(), "Azərbaycan sözlərinin səslənməsi mümkün deyil",
                            Toast.LENGTH_LONG).show();
                    Log.i("Buradasan","azeridir "+ idiniOyren);


                }else if (alman ==idiniDeyish){

                    speak();

                    Log.i("Buradasan","almandir "+ idiniOyren);

                }else{

                    Log.i("Buradasan","ferqli Id dir "+ idiniOyren);
                    speak();

                }

            }
        });

        mTTS = new TextToSpeech(getActivity(), new TextToSpeech.OnInitListener() {
            @Override
            public void onInit(int status) {
                if (status == TextToSpeech.SUCCESS) {
                    int result = mTTS.setLanguage(Locale.GERMAN);
                }

            }
        });


    }

    private void speak() {

        mTTS.speak(value, TextToSpeech.QUEUE_FLUSH, null);
    }

    @Override
    public void onDestroy() {
        if (mTTS != null) {
            mTTS.stop();
            mTTS.shutdown();
        }

        super.onDestroy();
    }

    public void onAttach(Context context){
        super.onAttach(context);
    }
    public void onDetach(){
        super.onDetach();
    }
}