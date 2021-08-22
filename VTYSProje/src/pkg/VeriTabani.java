package pkg;

import java.sql.*;
import java.util.Scanner;

public class VeriTabani {
    String ad;
    String soyad;
    int yas;
    String cinsiyet;
    private Connection Baglan(){
        Connection conn=null;
        try{
            conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/HastaneVT",
                    "postgres", "134466ay.");
            if (conn != null)
                System.out.println();
            else
                System.out.println("Bağlantı girişimi başarısız!");

        } catch (SQLException throwables) {
            throwables.printStackTrace();
        }
        return conn;
    }
    public void HastaBilgileriGuncelle(int hastaId) {

        Scanner scanner = new Scanner(System.in);
        System.out.println("Guncellemek istediginiz veriyi yaziniz.");
        System.out.println("1.Ad");
        System.out.println("2.Soyad");
        System.out.println("3.Yas");
        int veri = scanner.nextInt();
        String sql=null;
        Connection conn=this.Baglan();
        switch (veri) {
            case 1:
                System.out.print("Yeni ad bilgisini yazınız. :");
                ad = scanner.next();
                sql = "UPDATE \"Hasta\" SET \"ad\"= "+ ad+
                        " WHERE \"hastaID\"='"+ hastaId+"'";
                try {
                    Statement stmt = conn.createStatement();
                    stmt.executeUpdate(sql);
                    //***** Bağlantı sonlandırma *****
                    conn.close();
                    stmt.close();
                    System.out.println("----->Hastaya ait bilgiler başarılı bir şekilde güncellenmiştir.");
                } catch (SQLException throwables) {
                    throwables.printStackTrace();
                }

            break;
            case 2:
                System.out.print("Yeni soyad bilgisini yazınız. :");
                soyad = scanner.next();
                sql = "UPDATE \"Hasta\" SET \"soyad\"= "+ soyad+
                        " WHERE \"hastaID\"='"+ hastaId+"'";
                try {
                    Statement stmt = conn.createStatement();
                    stmt.executeUpdate(sql);
                    //***** Bağlantı sonlandırma *****
                    conn.close();
                    stmt.close();
                    System.out.println("----->Hastaya ait bilgiler başarılı bir şekilde güncellenmiştir.");
                } catch (SQLException throwables) {
                    throwables.printStackTrace();
                }
                break;
            case 3:
                System.out.print("Yeni yas bilgisini yazınız. :");
                yas = scanner.nextInt();
                sql = "UPDATE \"Hasta\" SET \"yas\"= "+ yas+
                        " WHERE \"hastaID\"='"+ hastaId+"'";
                try {
                    Statement stmt = conn.createStatement();
                    stmt.executeUpdate(sql);
                    //***** Bağlantı sonlandırma *****
                    conn.close();
                    stmt.close();
                    System.out.println("----->Hastaya ait bilgiler başarılı bir şekilde güncellenmiştir.");
                } catch (SQLException throwables) {
                    throwables.printStackTrace();
                }
                break;
            default:
                break;

        }

    }
    public void HastaAra(int hastaId) {
        Connection conn=this.Baglan();
        String sql = "SELECT * FROM \"Hasta\" WHERE \"hastaID\"= "+hastaId;
        try {
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql);
            //***** Bağlantı sonlandırma *****
            conn.close();
            int hastaid;
            String adi;
            String soyadi;
            int yas;
            String cinsiyet;
            System.out.println("hastaid \t adi \t    soyadi \t    cinsiyet \t yas");
            System.out.println("-----------------------------------------------------");
            while(rs.next())
            {
                hastaid  = rs.getInt("hastaID");
                adi = rs.getString("ad");
                soyadi  = rs.getString("soyad");
                yas  = rs.getInt("yas");
                cinsiyet  = rs.getString("cinsiyet");

                System.out.println("   "+hastaid+"\t\t"+adi+"\t\t"+soyadi+"\t\t"+cinsiyet+"\t\t"+yas);


            }
            rs.close();
            stmt.close();
            System.out.println();
        } catch (SQLException throwables) {
            throwables.printStackTrace();
        }
    }
    public void HastalariListele() {
        Connection conn=this.Baglan();
        String sql = "SELECT * FROM \"Hasta\" ";

        try {
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql);
            //***** Bağlantı sonlandırma *****
            conn.close();
            int hastaid;
            String adi;
            String soyadi;
            int yas;
            String cinsiyet;
            System.out.println("hastaid \t adi \t    soyadi \t    cinsiyet \t yas");
            System.out.println("-----------------------------------------------------");
            while(rs.next())
            {
                hastaid  = rs.getInt("hastaID");
                adi = rs.getString("ad");
                soyadi  = rs.getString("soyad");
                yas  = rs.getInt("yas");
                cinsiyet  = rs.getString("cinsiyet");
                System.out.println("   "+hastaid+"\t\t"+adi+"\t\t"+soyadi+"\t\t"+cinsiyet+"\t\t"+yas);


            }
            rs.close();
            stmt.close();
            System.out.println();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    public void HastaEkle(int hastaId,String ad, String soyad,String cinsiyet, int yas) {
        Connection conn=this.Baglan();
        String sql = "INSERT INTO \"Hasta\" (\"hastaID\", \"ad\", \"soyad\",\"cinsiyet\", \"yas\") " +
                "VALUES ("+hastaId+",\'"+ad+"\',\'"+soyad+"\',\'"+cinsiyet+"\',"+yas+")";

        try {
            Statement stmt = conn.createStatement();
            stmt.executeUpdate(sql);
            //***** Bağlantı sonlandırma *****
            conn.close();
            stmt.close();
            System.out.println("----->Yeni hasta başarılı bir şekilde kaydedilmiştir.");
        } catch (SQLException throwables) {
            throwables.printStackTrace();
        }
    }
    public void HastaSil(int hastaId) {
        String sql = "DELETE FROM \"Hasta\" WHERE \"hastaID\"= "+hastaId;
        Connection conn=this.Baglan();
        try {
            Statement stmt = conn.createStatement();
            stmt.executeUpdate(sql);
            //***** Bağlantı sonlandırma *****
            conn.close();
            stmt.close();
            System.out.println("----->Hasta bilgileri silindi.");
        } catch (SQLException throwables) {
            throwables.printStackTrace();
        }
    }
}
