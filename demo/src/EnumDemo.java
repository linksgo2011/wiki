package src;

/**
 * Created by nlin on 7/7/17.
 */
public class EnumDemo {
    public static void main(String args[]) {
        try{
            Day day = Day.valueOf("");
            System.out.print(day);
        }catch (Exception e){
            e.printStackTrace();
        }
    }
}

