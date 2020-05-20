package com.Dictionary;

public class Word {


    public String key;
    public String value;
    public int dicType;

    public Word(){


    }

    public Word(String key,String value){
        this.key = key;
        this.value = value;


    }
    public Word(String key,String value,int type){
        this.key = key;
        this.value = value;
        this.dicType = type;


    }



}
