package pkg;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Scanner;

public class Islemler {
    private VeriTabani psql=new VeriTabani();

    public void basla() {

        Scanner scanner = new Scanner(System.in);
        int hastaId=0;
        int islem;


        do{
            System.out.println("Yapmak istediğiniz İşlemi seçiniz.");
            System.out.println("1.Hasta Arama.");
            System.out.println("2.Hasta Ekleme.");
            System.out.println("3.Hasta Bilgilerini Güncelleme.");
            System.out.println("4.Hasta Bilgilerini Listele.");
            System.out.println("5.Hasta Kaydı Silme.");
            System.out.println("6.Çıkış.");
            islem = scanner.nextInt();
            switch (islem) {
                 case 1:
                     System.out.println("Aramak istediğiniz hastaya ait id numarasını giriniz.");
                     hastaId=scanner.nextInt();
                     psql.HastaAra(hastaId);
                   break;
                 case 2:
                     System.out.println("Yeni hastaya ait bilgileri giriniz.");
                     System.out.print("Hasta Id :");
                     hastaId=scanner.nextInt();
                     System.out.print("Hasta Adı :");
                     String ad=scanner.next();
                     System.out.print("Hasta Soyadı :");
                     String soyad=scanner.next();
                     System.out.print("Hastanın Cinsiyeti :");
                     String cinsiyet=scanner.next();
                     System.out.print("Hastanın yaşı :");
                     int yas=scanner.nextInt();
                     psql.HastaEkle(hastaId,ad,soyad,cinsiyet,yas);
                     break;
                case 3:
                    System.out.println("Bilgilerini güncellemek istediğiniz hastaya ait id bilgisini giriniz.");
                    hastaId=scanner.nextInt();
                    psql.HastaBilgileriGuncelle(hastaId);
                    break;
                case 4:
                    psql.HastalariListele();
                    break;
                case 5:
                    System.out.println("Kaydını silmek istediğiniz hastaya ait id bilgisini giriniz.");
                    hastaId=scanner.nextInt();
                    psql.HastaSil(hastaId);
                    break;
                case 6:
                     System.out.println("Program kapatılıyor.");
               break;
                default:
                    break;
            }
        }while (islem==0 || islem!=6);

    }
}
