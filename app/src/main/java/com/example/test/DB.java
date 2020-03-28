package com.example.test;

public class DB {

    public static String[] getData(int id){

        if (id ==R.id.de_az){
           return getDeAz();

        }else if(id == R.id.az_de){

            return getAzDe();
        }
        return new String[0];
    }

    public static String[] getDeAz(){
        String [] source = new String[]{
                "Mutter",
                "Vater",
                "Ich",
                "Du",
                "Sie",
                "Er",
                "Wir"
        };
        return source;
    }
    public static String[] getAzDe(){
        String [] source = new String[]{
                "Ana",
                "Ata",
                "Mən",
                "Sən",
                "O (qadın)",
                "O (kişi)",
                "Biz"
        };
        return source;
    }
}
