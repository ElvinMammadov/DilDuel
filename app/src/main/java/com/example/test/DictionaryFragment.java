package com.example.test;

import android.content.Context;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ListView;

import androidx.fragment.app.Fragment;

import java.util.ArrayList;


public class DictionaryFragment extends Fragment {


    private String value = "";

    private FragmentListener listener;
    ArrayAdapter<String> adapter;
    ListView dicList;
    private ArrayList<String> mSource = new ArrayList<String>();



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

        return inflater.inflate(R.layout.fragment_dictionary, container, false);
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


