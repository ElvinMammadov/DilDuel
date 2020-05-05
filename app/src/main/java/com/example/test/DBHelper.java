package com.example.test;

import android.content.Context;
import android.database.Cursor;
import android.database.SQLException;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.util.Log;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;

public class DBHelper extends SQLiteOpenHelper {


    private Context mContext;
    public static final String DATABASE_NAME = "luget.db";
    public static final int DATABASE_VERSION = 1;


    private String DATABASE_LOCATION = "";
    private String DATABASE_FULL_PATH = "";

    private final String de_Az = "DeAz";
    private  final String az_De = "AzDe";
    private final String bookmark = "bookmark";

    private final String col_key = "key";
    private final String col_value = "value";
    private final String col_type = "type";

    public SQLiteDatabase mDB;

    public DBHelper(Context context){

        super(context,DATABASE_NAME,null,DATABASE_VERSION);
        mContext = context;

        DATABASE_LOCATION = "data/data/" + mContext.getPackageName()+ "/" + "databases/";
        DATABASE_FULL_PATH = DATABASE_LOCATION + DATABASE_NAME;

        if (!isExistingDB()){

            try {

                File dbLocation = new File(DATABASE_LOCATION);
                dbLocation.mkdirs();
                extractAssetToDatabaseDirectory(DATABASE_NAME);


            } catch (IOException e) {
                e.printStackTrace();
            }

        }
        mDB = SQLiteDatabase.openOrCreateDatabase(DATABASE_FULL_PATH,null);
    }

    boolean isExistingDB(){

        File file = new File(DATABASE_FULL_PATH);
        return file.exists();
    }

    public void extractAssetToDatabaseDirectory(String fileName) throws IOException {

        int length;
        InputStream sourceDatabase = this.mContext.getAssets().open(fileName);
        File destinationPath = new File(DATABASE_FULL_PATH);
        OutputStream destination = new FileOutputStream(destinationPath);

        byte[] buffer = new byte[4096];
        while ((length = sourceDatabase.read(buffer)) > 0) {
            destination.write(buffer, 0, length);
        }
        sourceDatabase.close();
        destination.flush();
        destination.close();
    }


    @Override
    public void onCreate(SQLiteDatabase db) {

    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {

    }

    public ArrayList<String> getWord(int dicType){



        String tableName = getTableName(dicType);
        String q = "SELECT * FROM "+tableName;

        Log.i("Table Name ",  tableName +"Isleyir 1");

        Log.i("Her shey","Isleyir 1");
        Cursor result = mDB.rawQuery(q,null);

        Log.i("Her shey","Isleyir 2");

        ArrayList<String> source = new ArrayList<>();

        while (result.moveToNext()){
            source.add(result.getString(result.getColumnIndex(col_key)));
        }
        return source;

    }

    public Word getWord(String key, int dicType)
    {

        final String tableName = getTableName(dicType);
        final String q = String.format("SELECT * FROM %s  WHERE upper([key]) = upper(?)", tableName);
        Log.i("Burdan ","kecdi 1");
        final Word word = new Word();
        Cursor result = null;
        try {
            result = mDB.rawQuery(q,new String[]{key});
            if (result.moveToFirst()){
                word.key = result.getString(result.getColumnIndex(col_key));
                word.value = result.getString(result.getColumnIndex(col_value));
            }
        }
        finally {
            if (result != null) {
                result.close();
            }
        }

        return word;
    }

    public void addBookmark(Word word){

        try{
            String q = "INSERT INTO bookmark(["+col_key+"],["+col_value+"],["+col_type+"]) VALUES (?,?,?);";
            mDB.execSQL(q, new Object[]{word.key,word.value,word.dicType});

        }catch(SQLException ex){


        }

    }

    public void removeBookmark(Word word){

        try{
            String q = "DELETE FROM bookmark WHERE upper(["+col_key+"]) = upper(?) AND ["+col_value+"] = ?;";
            mDB.execSQL(q, new Object[]{word.key,word.value});

        }catch(SQLException ex){


        }
    }

    public void removeBookmark(String key){

        try{
            String bir = String.valueOf(1);
            String q = "DELETE FROM bookmark WHERE upper(["+col_key+"]) = upper(?)";
            Log.i("Burdan ","kecdi 2"+key +bir);



            mDB.execSQL(q, new Object[]{key});
            Log.i("Burdan ","kece bilmedi");

        }catch(SQLException ex){

        }
    }

    public ArrayList<String> getAllWordFromBookmark()
    {

        String q = "SELECT * FROM bookmark ORDER BY [date] DESC;";
        Cursor result = mDB.rawQuery(q,null);

        ArrayList<String> source = new ArrayList<>();

        while (result.moveToNext()){
            source.add(result.getString(result.getColumnIndex(col_key)));

        }

        return source;

    }

    public boolean isWordMark(Word word){

        String q = "SELECT * FROM bookmark WHERE upper([key]) = upper(?) AND [value] = ?";
        Cursor result = mDB.rawQuery(q,new String[]{word.key,word.value});

        return result.getCount() > 0;

    }

    public Word getWordFromBookmark(String key){

        String q = "SELECT * FROM bookmark WHERE upper([key]) = upper(?)";
        Cursor result = mDB.rawQuery(q,new String[]{key});


        Word word = null;

        while (result.moveToNext()){
            word = new Word();
            word.key = result.getString(result.getColumnIndex(col_key));
            word.value = result.getString(result.getColumnIndex(col_value));
            word.dicType = result.getInt(result.getColumnIndex(col_type));

        }

        return word;


    }


    public String getTableName(int dicTyp){

        String tableName = "";

        if(dicTyp == 321){
            tableName = de_Az;


        }else if(dicTyp == 123 ){

            tableName = az_De;
        }
        return  tableName;
    }

    public void clearBookmark() {

        try{
            String q = "DELETE FROM bookmark ";
            mDB.execSQL(q);

        }catch(SQLException ex){


        }
    }
}
