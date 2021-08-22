--
-- PostgreSQL database dump
--

-- Dumped from database version 13.0
-- Dumped by pg_dump version 13.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: hastaEkleTR1(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public."hastaEkleTR1"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN  
    IF NEW."ad" IS NULL OR NEW."soyad" IS NULL THEN
            RAISE EXCEPTION 'Hasta isim bilgileri boş bırakılamaz!';  
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public."hastaEkleTR1"() OWNER TO postgres;

--
-- Name: hastaKayitEkleTR1(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public."hastaKayitEkleTR1"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN  
    IF NEW."hastaID" IS NULL THEN
            RAISE EXCEPTION 'Hasta kaydetme işleminde hastaID boş bırakılamaz!';  
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public."hastaKayitEkleTR1"() OWNER TO postgres;

--
-- Name: kadinpersoneller(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.kadinpersoneller() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    kadinPersonelSayisi INTEGER;
    personelSayisi INTEGER;
    sonuc TEXT;
    oran FLOAT;
BEGIN     
   sonuc:='';
   kadinPersonelSayisi = (SELECT COUNT(*) FROM "Personel" where "cinsiyet"='Kadın');
   personelSayisi=(SELECT COUNT(*) FROM "Personel");
   oran= kadinPersonelSayisi*100/personelSayisi;
   return sonuc|| 'Hastanedeki kadın personellerin orani '||oran||'%.';

   
END;
$$;


ALTER FUNCTION public.kadinpersoneller() OWNER TO postgres;

--
-- Name: personelKayitEkleTR1(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public."personelKayitEkleTR1"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW."ad" = LTRIM(NEW."ad");
    NEW."soyad" = LTRIM(NEW."soyad");
    NEW."cinsiyet" = LTRIM(NEW."cinsiyet");
    NEW."ad"= upper(substring(NEW."ad" from 1 for 1)) || substring(NEW."ad" from 2 for length(NEW."ad"));
    NEW."soyad"= upper(substring(NEW."soyad" from 1 for 1)) || substring(NEW."soyad" from 2 for length(NEW."soyad"));
    NEW."cinsiyet"= upper(substring(NEW."cinsiyet" from 1 for 1)) || substring(NEW."cinsiyet" from 2 for length(NEW."cinsiyet"));   
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public."personelKayitEkleTR1"() OWNER TO postgres;

--
-- Name: personelara(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.personelara(personelid integer) RETURNS TABLE(numara integer, adi character varying, soyadi character varying, cinsiyeti character varying, bolumu integer, maasi integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT "personelNo", "ad", "soyad","cinsiyet", "bolumNo","maas" FROM "Personel"
                 WHERE "personelNo" = personelID;
END;
$$;


ALTER FUNCTION public.personelara(personelid integer) OWNER TO postgres;

--
-- Name: randevuDegisikligiTR1(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public."randevuDegisikligiTR1"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW."randevuTarihi" <> OLD."randevuTarihi" THEN
        INSERT INTO "RandevuDegisikligi"("randevuNo", "eskiRandevuTarihi", "guncelRandevuTarihi", "degisiklikTarihi")
        VALUES(OLD."randevuNo", OLD."randevuTarihi", NEW."randevuTarihi", CURRENT_TIMESTAMP::TIMESTAMP);
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public."randevuDegisikligiTR1"() OWNER TO postgres;

--
-- Name: randevularilistele(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.randevularilistele(personelid integer) RETURNS TABLE(numara integer, doktoradi character varying, doktorsoyadi character varying, poliklinik character varying, hastaadi character varying, hastasoyadi character varying, tarih date)
    LANGUAGE plpgsql
    AS $$

BEGIN     
 RETURN QUERY SELECT 
  "public"."Personel"."personelNo","public"."Personel"."ad", "public"."Personel"."soyad","public"."Poliklinik"."poliklinikAdi","public"."Hasta"."ad","public"."Hasta"."soyad","public"."Randevu"."randevuTarihi"
FROM "Doktor"
INNER JOIN "Personel" ON "Personel"."personelNo" = "Doktor"."personelNo" 
INNER JOIN "Poliklinik" ON "Doktor"."poliklinikNo"="Poliklinik"."poliklinikNo"
INNER JOIN "Randevu" ON "Doktor"."personelNo"="Randevu"."doktorID"
Inner JOIN "Hasta" On "Hasta"."hastaID"="Randevu"."hastaID"
where "Doktor"."personelNo"=personelID;
   
END;
$$;


ALTER FUNCTION public.randevularilistele(personelid integer) OWNER TO postgres;

--
-- Name: yillikodeme(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.yillikodeme(personelid integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    personel RECORD;
    miktar INTEGER;
    isGunu INTEGER;
BEGIN
    isGunu:=251;
    personel := personelAra(personelID);
    miktar := personel."maasi"*isGunu; 

    RETURN personel."numara" || E'\t' || personel."adi" || E'\t' ||personel."soyadi"|| E'\t' || personel."bolumu"|| E'\t' || miktar;
END
$$;


ALTER FUNCTION public.yillikodeme(personelid integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: AcilBolumu; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."AcilBolumu" (
    "bolumNo" integer NOT NULL,
    "hastaneNo" integer NOT NULL
);


ALTER TABLE public."AcilBolumu" OWNER TO postgres;

--
-- Name: Bashekim; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Bashekim" (
    "personelNo" integer NOT NULL,
    "bolumNo" integer NOT NULL
);


ALTER TABLE public."Bashekim" OWNER TO postgres;

--
-- Name: Bashemsire; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Bashemsire" (
    "personelNo" integer NOT NULL,
    "bolumNo" integer NOT NULL
);


ALTER TABLE public."Bashemsire" OWNER TO postgres;

--
-- Name: Doktor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Doktor" (
    "personelNo" integer NOT NULL,
    "poliklinikNo" integer NOT NULL
);


ALTER TABLE public."Doktor" OWNER TO postgres;

--
-- Name: Hasta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Hasta" (
    "hastaID" integer NOT NULL,
    ad character varying(40) NOT NULL,
    soyad character varying(40) NOT NULL,
    cinsiyet character varying(10) NOT NULL,
    yas integer NOT NULL
);


ALTER TABLE public."Hasta" OWNER TO postgres;

--
-- Name: HastaKayit; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."HastaKayit" (
    "hastaID" integer NOT NULL,
    "hastaneNo" integer NOT NULL
);


ALTER TABLE public."HastaKayit" OWNER TO postgres;

--
-- Name: Hastane; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Hastane" (
    "hastaneNo" integer NOT NULL,
    "hastaneAdi" character varying(50) NOT NULL,
    adres character varying(60) NOT NULL
);


ALTER TABLE public."Hastane" OWNER TO postgres;

--
-- Name: Hemsire; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Hemsire" (
    "personelNo" integer NOT NULL,
    "poliklinikNo" integer NOT NULL
);


ALTER TABLE public."Hemsire" OWNER TO postgres;

--
-- Name: IdariBolum; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."IdariBolum" (
    "bolumNo" integer NOT NULL,
    "hastaneNo" integer NOT NULL
);


ALTER TABLE public."IdariBolum" OWNER TO postgres;

--
-- Name: KirmiziAlan; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."KirmiziAlan" (
    "alanKodu" character(1) NOT NULL,
    "bolumNo" integer NOT NULL
);


ALTER TABLE public."KirmiziAlan" OWNER TO postgres;

--
-- Name: Mudur; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Mudur" (
    "personelNo" integer NOT NULL,
    "bolumNo" integer NOT NULL
);


ALTER TABLE public."Mudur" OWNER TO postgres;

--
-- Name: Personel; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Personel" (
    "personelNo" integer NOT NULL,
    "hastaneNo" integer NOT NULL,
    cinsiyet character varying(10) NOT NULL,
    maas integer NOT NULL,
    ad character varying(40) NOT NULL,
    soyad character varying(40) NOT NULL,
    "bolumNo" integer NOT NULL
);


ALTER TABLE public."Personel" OWNER TO postgres;

--
-- Name: Poliklinik; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Poliklinik" (
    "poliklinikNo" integer NOT NULL,
    "poliklinikAdi" character varying(40) NOT NULL,
    "bolumNo" integer NOT NULL
);


ALTER TABLE public."Poliklinik" OWNER TO postgres;

--
-- Name: PoliklinikBolumu; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."PoliklinikBolumu" (
    "bolumNo" integer NOT NULL,
    "hastaneNo" integer NOT NULL
);


ALTER TABLE public."PoliklinikBolumu" OWNER TO postgres;

--
-- Name: Randevu; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Randevu" (
    "randevuNo" integer NOT NULL,
    "doktorID" integer NOT NULL,
    "hastaID" integer NOT NULL,
    "randevuTarihi" date NOT NULL
);


ALTER TABLE public."Randevu" OWNER TO postgres;

--
-- Name: RandevuDegisikligi; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."RandevuDegisikligi" (
    "guncelRandevuTarihi" date NOT NULL,
    "eskiRandevuTarihi" date NOT NULL,
    "randevuNo" integer NOT NULL,
    "degisiklikTarihi" date NOT NULL
);


ALTER TABLE public."RandevuDegisikligi" OWNER TO postgres;

--
-- Name: Recete; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Recete" (
    "receteID" integer NOT NULL,
    "yazildigiTarih" date NOT NULL,
    "Doktor_id" integer NOT NULL,
    "Hasta_id" integer NOT NULL
);


ALTER TABLE public."Recete" OWNER TO postgres;

--
-- Name: SariAlan; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SariAlan" (
    "alanKodu" character(1) NOT NULL,
    "bolumNo" integer NOT NULL
);


ALTER TABLE public."SariAlan" OWNER TO postgres;

--
-- Name: YesilAlan; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."YesilAlan" (
    "alanKodu" character(1) NOT NULL,
    "bolumNo" integer NOT NULL
);


ALTER TABLE public."YesilAlan" OWNER TO postgres;

--
-- Data for Name: AcilBolumu; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."AcilBolumu" VALUES
	(3, 1);


--
-- Data for Name: Bashekim; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: Bashemsire; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: Doktor; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Doktor" VALUES
	(2, 1),
	(1, 2),
	(9, 3),
	(10, 4);


--
-- Data for Name: Hasta; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Hasta" VALUES
	(1, 'Asım', 'Yılmaz', 'Erkek', 39),
	(3, 'Aynur', 'Yiğit', 'Kadın', 58),
	(4, 'Serhat ', 'Öztürk', 'Erkek', 70),
	(6, 'Halil', 'Kara', 'Erkek', 63),
	(7, 'Onur', 'Sayın', 'Erkek', 51),
	(8, 'Eren', 'Bulut', 'Erkek', 19),
	(9, 'Şenay', 'Gürler', 'Kadın', 40),
	(2, 'Kerim', 'Yıldız', 'Erkek', 40),
	(11, 'Pelin', 'Aral', 'Kadın', 21),
	(10, 'Mutlu', 'Eren', 'Erkek', 67),
	(5, 'Hale', 'Akbulut', 'Kadın', 49);


--
-- Data for Name: HastaKayit; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: Hastane; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Hastane" VALUES
	(1, 'A Hastanesi', 'A mahallesi No:15');


--
-- Data for Name: Hemsire; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Hemsire" VALUES
	(3, 1),
	(4, 3),
	(5, 4),
	(6, 2),
	(7, 1),
	(8, 3);


--
-- Data for Name: IdariBolum; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."IdariBolum" VALUES
	(2, 1);


--
-- Data for Name: KirmiziAlan; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."KirmiziAlan" VALUES
	('K', 3);


--
-- Data for Name: Mudur; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Mudur" VALUES
	(7, 2);


--
-- Data for Name: Personel; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Personel" VALUES
	(1, 1, 'Erkek', 5000, 'Ayhan', 'Kaya', 1),
	(2, 1, 'Kadın', 7000, 'Sevim', 'Hakan', 1),
	(3, 1, 'Kadın', 6000, 'Nisa', 'Peker', 2),
	(4, 1, 'Kadın', 4500, 'Gülay', 'Doğan', 3),
	(5, 1, 'Erkek', 3000, 'Harun', 'Güler', 3),
	(6, 1, 'Erkek', 7000, 'Arda', 'Yılmaz', 2),
	(7, 1, 'Erkek', 8000, 'Davut', 'Aymaz', 2),
	(8, 1, 'Kadın', 4000, 'Münevver', 'Kara', 3),
	(9, 1, 'Kadın', 5000, 'Aslı', 'Yılmaz', 1),
	(10, 1, 'Erkek', 6500, 'Ahmet', 'Sezer', 1),
	(11, 1, 'Erkek', 5500, 'Faruk', 'Doğan', 3),
	(13, 1, 'Kadın', 4900, 'Ayşe', 'Kutlu', 3),
	(14, 1, 'Kadın', 3300, 'Aylin', 'Eker', 1);


--
-- Data for Name: Poliklinik; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Poliklinik" VALUES
	(1, 'Göz Plkn.', 1),
	(2, 'Dahiliye Plkn.', 1),
	(3, 'Nöroloji Plkn', 1),
	(4, 'Cildiye Plkn.', 1);


--
-- Data for Name: PoliklinikBolumu; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."PoliklinikBolumu" VALUES
	(1, 1);


--
-- Data for Name: Randevu; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Randevu" VALUES
	(6, 9, 3, '2021-09-01'),
	(1, 1, 1, '2021-09-01'),
	(2, 1, 2, '2021-09-02'),
	(3, 2, 3, '2021-09-03'),
	(5, 2, 5, '2021-09-03'),
	(12, 2, 9, '2021-09-07'),
	(11, 10, 9, '2021-09-08'),
	(10, 10, 8, '2021-09-10'),
	(8, 9, 4, '2021-09-11'),
	(4, 2, 4, '2021-09-13'),
	(7, 9, 6, '2021-09-03'),
	(9, 10, 7, '2020-10-01');


--
-- Data for Name: RandevuDegisikligi; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."RandevuDegisikligi" VALUES
	('2021-09-06', '2012-12-28', 13, '2021-08-21'),
	('2021-09-07', '2012-10-20', 12, '2021-08-21'),
	('2020-10-01', '2021-09-15', 9, '2021-08-22');


--
-- Data for Name: Recete; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Recete" VALUES
	(1, '2012-03-02', 1, 1),
	(2, '2012-03-04', 10, 7),
	(3, '2012-10-20', 2, 9),
	(4, '2012-01-14', 9, 6),
	(5, '2012-01-14', 9, 4);


--
-- Data for Name: SariAlan; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."SariAlan" VALUES
	('S', 3);


--
-- Data for Name: YesilAlan; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."YesilAlan" VALUES
	('Y', 3);


--
-- Name: AcilBolumu AcilBolumu_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AcilBolumu"
    ADD CONSTRAINT "AcilBolumu_pkey" PRIMARY KEY ("bolumNo", "hastaneNo");


--
-- Name: Bashekim Bashekim_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Bashekim"
    ADD CONSTRAINT "Bashekim_pkey" PRIMARY KEY ("personelNo");


--
-- Name: Bashemsire Bashemsire_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Bashemsire"
    ADD CONSTRAINT "Bashemsire_pkey" PRIMARY KEY ("personelNo");


--
-- Name: Doktor Doktor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Doktor"
    ADD CONSTRAINT "Doktor_pkey" PRIMARY KEY ("personelNo");


--
-- Name: HastaKayit HastaKayit_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."HastaKayit"
    ADD CONSTRAINT "HastaKayit_pkey" PRIMARY KEY ("hastaID", "hastaneNo");


--
-- Name: Hasta Hasta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Hasta"
    ADD CONSTRAINT "Hasta_pkey" PRIMARY KEY ("hastaID");


--
-- Name: Hastane Hastane_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Hastane"
    ADD CONSTRAINT "Hastane_pkey" PRIMARY KEY ("hastaneNo");


--
-- Name: Hemsire Hemsire_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Hemsire"
    ADD CONSTRAINT "Hemsire_pkey" PRIMARY KEY ("personelNo");


--
-- Name: IdariBolum IdariBolum_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."IdariBolum"
    ADD CONSTRAINT "IdariBolum_pkey" PRIMARY KEY ("bolumNo", "hastaneNo");


--
-- Name: KirmiziAlan KirmiziAlan_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."KirmiziAlan"
    ADD CONSTRAINT "KirmiziAlan_pkey" PRIMARY KEY ("alanKodu", "bolumNo");


--
-- Name: Mudur Mudur_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Mudur"
    ADD CONSTRAINT "Mudur_pkey" PRIMARY KEY ("personelNo");


--
-- Name: Personel Personel_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Personel"
    ADD CONSTRAINT "Personel_pkey" PRIMARY KEY ("personelNo");


--
-- Name: PoliklinikBolumu PoliklinikBolumu_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PoliklinikBolumu"
    ADD CONSTRAINT "PoliklinikBolumu_pkey" PRIMARY KEY ("bolumNo", "hastaneNo");


--
-- Name: Poliklinik Poliklinik_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Poliklinik"
    ADD CONSTRAINT "Poliklinik_pkey" PRIMARY KEY ("poliklinikNo");


--
-- Name: RandevuDegisikligi RandevuDegisikligi_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."RandevuDegisikligi"
    ADD CONSTRAINT "RandevuDegisikligi_pkey" PRIMARY KEY ("randevuNo");


--
-- Name: Randevu Randevu_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Randevu"
    ADD CONSTRAINT "Randevu_pkey" PRIMARY KEY ("randevuNo");


--
-- Name: Recete Recete_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Recete"
    ADD CONSTRAINT "Recete_pkey" PRIMARY KEY ("receteID");


--
-- Name: SariAlan SariAlan_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SariAlan"
    ADD CONSTRAINT "SariAlan_pkey" PRIMARY KEY ("alanKodu", "bolumNo");


--
-- Name: YesilAlan YesilAlan_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."YesilAlan"
    ADD CONSTRAINT "YesilAlan_pkey" PRIMARY KEY ("bolumNo", "alanKodu");


--
-- Name: AcilBolumu unique_AcilBolumu_bolumNo; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AcilBolumu"
    ADD CONSTRAINT "unique_AcilBolumu_bolumNo" UNIQUE ("bolumNo");


--
-- Name: AcilBolumu unique_AcilBolumu_hastaneNo; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AcilBolumu"
    ADD CONSTRAINT "unique_AcilBolumu_hastaneNo" UNIQUE ("hastaneNo");


--
-- Name: Bashekim unique_Bashekim_bolumNo; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Bashekim"
    ADD CONSTRAINT "unique_Bashekim_bolumNo" UNIQUE ("bolumNo");


--
-- Name: Bashekim unique_Bashekim_personelNo; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Bashekim"
    ADD CONSTRAINT "unique_Bashekim_personelNo" UNIQUE ("personelNo");


--
-- Name: Bashemsire unique_Bashemsire_bolumNo; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Bashemsire"
    ADD CONSTRAINT "unique_Bashemsire_bolumNo" UNIQUE ("bolumNo");


--
-- Name: Bashemsire unique_Bashemsire_personelNo; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Bashemsire"
    ADD CONSTRAINT "unique_Bashemsire_personelNo" UNIQUE ("personelNo");


--
-- Name: Doktor unique_Doktor_personelNo; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Doktor"
    ADD CONSTRAINT "unique_Doktor_personelNo" UNIQUE ("personelNo");


--
-- Name: Doktor unique_Doktor_poliklinikNo; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Doktor"
    ADD CONSTRAINT "unique_Doktor_poliklinikNo" UNIQUE ("poliklinikNo");


--
-- Name: HastaKayit unique_HastaKayit_hastaID; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."HastaKayit"
    ADD CONSTRAINT "unique_HastaKayit_hastaID" UNIQUE ("hastaID");


--
-- Name: Hasta unique_Hasta_hastaID; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Hasta"
    ADD CONSTRAINT "unique_Hasta_hastaID" UNIQUE ("hastaID");


--
-- Name: Hastane unique_Hastane_hastaneNo; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Hastane"
    ADD CONSTRAINT "unique_Hastane_hastaneNo" UNIQUE ("hastaneNo");


--
-- Name: Hemsire unique_Hemsire_personelNo; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Hemsire"
    ADD CONSTRAINT "unique_Hemsire_personelNo" UNIQUE ("personelNo");


--
-- Name: IdariBolum unique_IdariBolum_bolumNo; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."IdariBolum"
    ADD CONSTRAINT "unique_IdariBolum_bolumNo" UNIQUE ("bolumNo");


--
-- Name: IdariBolum unique_IdariBolum_hastaneNo; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."IdariBolum"
    ADD CONSTRAINT "unique_IdariBolum_hastaneNo" UNIQUE ("hastaneNo");


--
-- Name: KirmiziAlan unique_KirmiziAlan_alanKodu; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."KirmiziAlan"
    ADD CONSTRAINT "unique_KirmiziAlan_alanKodu" UNIQUE ("alanKodu");


--
-- Name: KirmiziAlan unique_KirmiziAlan_bolumNo; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."KirmiziAlan"
    ADD CONSTRAINT "unique_KirmiziAlan_bolumNo" UNIQUE ("bolumNo");


--
-- Name: Mudur unique_Mudur_bolumNo; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Mudur"
    ADD CONSTRAINT "unique_Mudur_bolumNo" UNIQUE ("bolumNo");


--
-- Name: Mudur unique_Mudur_perosnelNo; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Mudur"
    ADD CONSTRAINT "unique_Mudur_perosnelNo" UNIQUE ("personelNo");


--
-- Name: Personel unique_Personel_personelNo; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Personel"
    ADD CONSTRAINT "unique_Personel_personelNo" UNIQUE ("personelNo");


--
-- Name: PoliklinikBolumu unique_PoliklinikBolumu_bolumNo; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PoliklinikBolumu"
    ADD CONSTRAINT "unique_PoliklinikBolumu_bolumNo" UNIQUE ("bolumNo");


--
-- Name: PoliklinikBolumu unique_PoliklinikBolumu_hastaneNo; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PoliklinikBolumu"
    ADD CONSTRAINT "unique_PoliklinikBolumu_hastaneNo" UNIQUE ("hastaneNo");


--
-- Name: Poliklinik unique_Poliklinik_poliklinikNo; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Poliklinik"
    ADD CONSTRAINT "unique_Poliklinik_poliklinikNo" UNIQUE ("poliklinikNo");


--
-- Name: RandevuDegisikligi unique_RandevuDegisikligi_randevuNo; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."RandevuDegisikligi"
    ADD CONSTRAINT "unique_RandevuDegisikligi_randevuNo" UNIQUE ("randevuNo");


--
-- Name: Randevu unique_Randevu_randevuNo; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Randevu"
    ADD CONSTRAINT "unique_Randevu_randevuNo" UNIQUE ("randevuNo");


--
-- Name: Recete unique_Recete_receteID; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Recete"
    ADD CONSTRAINT "unique_Recete_receteID" UNIQUE ("receteID");


--
-- Name: SariAlan unique_SariAlan_alanKodu; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SariAlan"
    ADD CONSTRAINT "unique_SariAlan_alanKodu" UNIQUE ("alanKodu");


--
-- Name: SariAlan unique_SariAlan_bolumNo; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SariAlan"
    ADD CONSTRAINT "unique_SariAlan_bolumNo" UNIQUE ("bolumNo");


--
-- Name: YesilAlan unique_YesilAlan_alanKodu; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."YesilAlan"
    ADD CONSTRAINT "unique_YesilAlan_alanKodu" UNIQUE ("alanKodu");


--
-- Name: YesilAlan unique_YesilAlan_bolumNo; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."YesilAlan"
    ADD CONSTRAINT "unique_YesilAlan_bolumNo" UNIQUE ("bolumNo");


--
-- Name: index_Doktor_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "index_Doktor_id" ON public."Recete" USING btree ("Doktor_id");


--
-- Name: index_Hasta_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "index_Hasta_id" ON public."Recete" USING btree ("Hasta_id");


--
-- Name: index_bolumNo; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "index_bolumNo" ON public."Poliklinik" USING btree ("bolumNo");


--
-- Name: index_bolumNo1; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "index_bolumNo1" ON public."Personel" USING btree ("bolumNo");


--
-- Name: index_doktorID; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "index_doktorID" ON public."Randevu" USING btree ("doktorID");


--
-- Name: index_hastaID; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "index_hastaID" ON public."Randevu" USING btree ("hastaID");


--
-- Name: index_hastaneNo; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "index_hastaneNo" ON public."HastaKayit" USING btree ("hastaneNo");


--
-- Name: index_hastaneNo1; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "index_hastaneNo1" ON public."Personel" USING btree ("hastaneNo");


--
-- Name: index_poliklinikNo; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "index_poliklinikNo" ON public."Poliklinik" USING btree ("poliklinikNo");


--
-- Name: index_poliklinikNo1; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "index_poliklinikNo1" ON public."Hemsire" USING btree ("poliklinikNo");


--
-- Name: Hasta hastaEkleKontrol; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "hastaEkleKontrol" BEFORE INSERT OR UPDATE ON public."Hasta" FOR EACH ROW EXECUTE FUNCTION public."hastaEkleTR1"();


--
-- Name: HastaKayit hastaKayitKontrol; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "hastaKayitKontrol" BEFORE INSERT OR UPDATE ON public."HastaKayit" FOR EACH ROW EXECUTE FUNCTION public."hastaKayitEkleTR1"();


--
-- Name: Randevu randevuTarihiDegistiginde; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "randevuTarihiDegistiginde" BEFORE UPDATE ON public."Randevu" FOR EACH ROW EXECUTE FUNCTION public."randevuDegisikligiTR1"();


--
-- Name: Personel yeniPersonelKaydi; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "yeniPersonelKaydi" BEFORE INSERT OR UPDATE ON public."Personel" FOR EACH ROW EXECUTE FUNCTION public."personelKayitEkleTR1"();


--
-- Name: Personel hastane_personel; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Personel"
    ADD CONSTRAINT hastane_personel FOREIGN KEY ("hastaneNo") REFERENCES public."Hastane"("hastaneNo") MATCH FULL;


--
-- Name: Bashekim idariBolum_bashekim; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Bashekim"
    ADD CONSTRAINT "idariBolum_bashekim" FOREIGN KEY ("bolumNo") REFERENCES public."IdariBolum"("bolumNo") MATCH FULL;


--
-- Name: Bashemsire idariBolum_bashemsire; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Bashemsire"
    ADD CONSTRAINT "idariBolum_bashemsire" FOREIGN KEY ("bolumNo") REFERENCES public."IdariBolum"("bolumNo") MATCH FULL;


--
-- Name: Mudur idariBolum_mudur; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Mudur"
    ADD CONSTRAINT "idariBolum_mudur" FOREIGN KEY ("bolumNo") REFERENCES public."IdariBolum"("bolumNo") MATCH FULL;


--
-- Name: Randevu lnk_Doktor_Randevu; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Randevu"
    ADD CONSTRAINT "lnk_Doktor_Randevu" FOREIGN KEY ("doktorID") REFERENCES public."Doktor"("personelNo") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Recete lnk_Doktor_Recete; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Recete"
    ADD CONSTRAINT "lnk_Doktor_Recete" FOREIGN KEY ("Doktor_id") REFERENCES public."Doktor"("personelNo") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: HastaKayit lnk_Hasta_HastaKayit; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."HastaKayit"
    ADD CONSTRAINT "lnk_Hasta_HastaKayit" FOREIGN KEY ("hastaID") REFERENCES public."Hasta"("hastaID") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Randevu lnk_Hasta_Randevu; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Randevu"
    ADD CONSTRAINT "lnk_Hasta_Randevu" FOREIGN KEY ("hastaID") REFERENCES public."Hasta"("hastaID") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Recete lnk_Hasta_Recete; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Recete"
    ADD CONSTRAINT "lnk_Hasta_Recete" FOREIGN KEY ("Hasta_id") REFERENCES public."Hasta"("hastaID") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: HastaKayit lnk_Hastane_HastaKayit; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."HastaKayit"
    ADD CONSTRAINT "lnk_Hastane_HastaKayit" FOREIGN KEY ("hastaneNo") REFERENCES public."Hastane"("hastaneNo") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: PoliklinikBolumu lnk_Hastane_PoliklinikBolumu; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PoliklinikBolumu"
    ADD CONSTRAINT "lnk_Hastane_PoliklinikBolumu" FOREIGN KEY ("hastaneNo") REFERENCES public."Hastane"("hastaneNo") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Doktor personel_doktor; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Doktor"
    ADD CONSTRAINT personel_doktor FOREIGN KEY ("personelNo") REFERENCES public."Personel"("personelNo") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Hemsire personel_hemsire; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Hemsire"
    ADD CONSTRAINT personel_hemsire FOREIGN KEY ("personelNo") REFERENCES public."Personel"("personelNo") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Poliklinik poliklinikBolumu_poliklinik; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Poliklinik"
    ADD CONSTRAINT "poliklinikBolumu_poliklinik" FOREIGN KEY ("bolumNo") REFERENCES public."PoliklinikBolumu"("bolumNo") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Doktor poliklinik_doktor; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Doktor"
    ADD CONSTRAINT poliklinik_doktor FOREIGN KEY ("poliklinikNo") REFERENCES public."Poliklinik"("poliklinikNo") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: AcilBolumu public.AcilBolumu.hastane_acilBolumu; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AcilBolumu"
    ADD CONSTRAINT "public.AcilBolumu.hastane_acilBolumu" FOREIGN KEY ("hastaneNo") REFERENCES public."Hastane"("hastaneNo") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: IdariBolum public.IdariBolum.hastane_idariNolum; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."IdariBolum"
    ADD CONSTRAINT "public.IdariBolum.hastane_idariNolum" FOREIGN KEY ("hastaneNo") REFERENCES public."Hastane"("hastaneNo") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: KirmiziAlan public.KirmiziAlan.acilBolumu_kirmiziAlan; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."KirmiziAlan"
    ADD CONSTRAINT "public.KirmiziAlan.acilBolumu_kirmiziAlan" FOREIGN KEY ("bolumNo") REFERENCES public."AcilBolumu"("bolumNo") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SariAlan public.SariAlan.acilBolumu_sariAlan; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SariAlan"
    ADD CONSTRAINT "public.SariAlan.acilBolumu_sariAlan" FOREIGN KEY ("bolumNo") REFERENCES public."AcilBolumu"("bolumNo") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: YesilAlan public.YesilAlan.acilBolumu_yesilAlan; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."YesilAlan"
    ADD CONSTRAINT "public.YesilAlan.acilBolumu_yesilAlan" FOREIGN KEY ("bolumNo") REFERENCES public."AcilBolumu"("bolumNo") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

