package com.Dictionary;

import android.content.Context;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.LinearLayout;
import android.widget.ListView;

import androidx.fragment.app.Fragment;

import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdSize;
import com.google.android.gms.ads.AdView;
import com.google.android.gms.ads.MobileAds;
import com.google.android.gms.ads.RequestConfiguration;
import com.google.android.gms.ads.initialization.InitializationStatus;
import com.google.android.gms.ads.initialization.OnInitializationCompleteListener;


import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;


public class DictionaryFragment extends Fragment {


    private String value = "";

    private FragmentListener listener;
    ArrayAdapter<String> adapter;
    ListView dicList;
    private ArrayList<String> mSource = new ArrayList<String>();


    private AdView adView;
    private AdRequest adRequest;


    public DictionaryFragment() {
        // Required empty public constructor
    }


    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);




    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment


        View rootView = inflater.inflate(R.layout.fragment_dictionary, container, false);

        List<String> testDeviceIds = Arrays.asList("d59bdc327d63");
        RequestConfiguration configuration =
                new RequestConfiguration.Builder().setTestDeviceIds(testDeviceIds).build();
        MobileAds.setRequestConfiguration(configuration);
        adView = new AdView(getActivity());
        //adView.setAdUnitId("ca-app-pub-3940256099942544/6300978111");
        //adView.setAdSize(AdSize.BANNER);
        //LinearLayout layout = (LinearLayout) rootView.findViewById(R.id.layout_admob);
        //layout.addView(adView);
        adView = (AdView) rootView.findViewById(R.id.adView);
        adRequest = new AdRequest.Builder().build();

        Log.i("Ads ","budur " +adRequest);
        adView.loadAd(adRequest);

        return rootView;




    }

    public void onViewCreated(View view,Bundle savedInstanceState){
        super.onViewCreated(view,savedInstanceState);




       dicList = view.findViewById(R.id.dictionaryList);
        adapter = new ArrayAdapter<String>(getContext(),android.R.layout.simple_list_item_1,mSource);

        dicList.setAdapter(adapter);

        dicList.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                if (listener!=null){

                    String selectedText = (String) parent.getItemAtPosition(position);
                   listener.onItemClick(selectedText);


                    Log.i("Position ","budur "+ selectedText);
               }
            }
        });
    }

    public void resetDataSource(ArrayList<String> source){
        mSource =source;

        if(getActivity()!=null){

            adapter = new ArrayAdapter<String>(getContext(),android.R.layout.simple_list_item_1,mSource);
            dicList.setAdapter(adapter);
        }


    }


        public void adMobs(){




     }



    public void onAttach(Context context){
        super.onAttach(context);
    }
    public void onDetach(){
        super.onDetach();
    }

    public  void setOnFragmentListener(FragmentListener listener ){
        this.listener = listener;

    }

}


