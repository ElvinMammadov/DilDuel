package com.example.test;

import android.content.Context;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ListView;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;


public class BookmarkFragment extends Fragment {

    private FragmentListener listener;
    private DBHelper mDbHelper;
    private  BookmarkAdapter adapter;

    private String value = "Hello";


    public BookmarkFragment() {
        // Required empty public constructor
    }

    public static BookmarkFragment getNewInstance(DBHelper dbHelper){

        BookmarkFragment fragment = new BookmarkFragment();
        fragment.mDbHelper = dbHelper;
        return fragment;
    }


    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.fragment_bookmark, container, false);
    }

    public void onViewCreated(View view,Bundle savedInstanceState){
        super.onViewCreated(view,savedInstanceState);

        setHasOptionsMenu(true);


        ListView bookmarkList = (ListView) view.findViewById(R.id.bookmarkList);

        adapter = new BookmarkAdapter(getActivity(),mDbHelper.getAllWordFromBookmark());

        bookmarkList.setAdapter(adapter);

        adapter.setOnItemClick(new ListItemListener() {
            @Override
            public void onItemClick(int position) {

                if (listener!=null){
                    listener.onItemClick(String.valueOf(adapter.getItem(position)));
                }
            }
        });


        adapter.setOnItemDeleteClick(new ListItemListener() {
            @Override
            public void onItemClick(int position) {

                String key = (String) adapter.getItem(position);
                mDbHelper.removeBookmark(key);
              adapter.removeItem(position);
              adapter.notifyDataSetChanged();
            }
        });
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


    @Override
    public void onCreateOptionsMenu(@NonNull Menu menu, @NonNull MenuInflater inflater) {
       inflater.inflate(R.menu.menu_clear,menu);
    }

    @Override
    public boolean onOptionsItemSelected(@NonNull MenuItem item) {

        int id = item.getItemId();
        if (id == R.id.action_clear){
            mDbHelper.clearBookmark();
            adapter.clear();
            adapter.notifyDataSetChanged();

        }
        return super.onOptionsItemSelected(item);
    }
}

