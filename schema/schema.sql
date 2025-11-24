-- SirketBilgileri Tablosu
CREATE TABLE SirketBilgileri (
    Sirket_ID INT PRIMARY KEY,
    Sirket_Ad VARCHAR(100),
    Adres VARCHAR(255),
    Telefon VARCHAR(20),
    Email VARCHAR(100),
    Sifre VARCHAR(50)
);

-- Siparis Tablosu
CREATE TABLE Siparis (
    Siparis_ID INT PRIMARY KEY,
    Sirket_ID INT,
    Siparis_Isim VARCHAR(100),
    Siparis_Adresi VARCHAR(255),
    Siparis_TeslimTarihi DATE,
    Siparis_Icerik TEXT,
    FOREIGN KEY (Sirket_ID) REFERENCES SirketBilgileri(Sirket_ID)
);

-- Dagitim Tablosu
CREATE TABLE Dagitim (
    Dagitim_ID INT PRIMARY KEY,
    DagitimGorevlisi_ID INT,
    Arac_ID INT,
    Siparis_ID INT,
    FOREIGN KEY (Arac_ID) REFERENCES Araclar(Arac_ID),
    FOREIGN KEY (Siparis_ID) REFERENCES Siparis(Siparis_ID)
);

-- Araclar Tablosu
CREATE TABLE Araclar (
    Arac_ID INT PRIMARY KEY,
    Arac_model VARCHAR(100),
    Arac_Kapasite INT,
    Arac_Sogutucu_DondurucuMu BIT
);

-- LojistikPersonelleri Tablosu
CREATE TABLE LojistikPersonelleri (
    Calisan_ID INT PRIMARY KEY,
    Calisan_TC VARCHAR(11),
    Calisan_Ad_Soyad VARCHAR(100),
    Calisan_Tel VARCHAR(20),
    Birim_ID INT,
    Arac_ID INT,
    FOREIGN KEY (Birim_ID) REFERENCES Birimler(Birim_ID),
    FOREIGN KEY (Arac_ID) REFERENCES Araclar(Arac_ID)
);

-- Birimler Tablosu
CREATE TABLE Birimler (
    Birim_ID INT PRIMARY KEY,
    Birim_Ismi VARCHAR(100),
    Birim_Sorumlusu_ID INT
);

-- Yoneticiler Tablosu
CREATE TABLE Yoneticiler (
    Yonetic_ID INT PRIMARY KEY,
    Yonetic_Ad_Soyad VARCHAR(100),
    Yonetic_Tel VARCHAR(20),
    Birim_ID INT,
    FOREIGN KEY (Birim_ID) REFERENCES Birimler(Birim_ID)
);

-- TemizlikGorevlileri Tablosu
CREATE TABLE TemizlikGorevlileri (
    Calisan_TC VARCHAR(11) PRIMARY KEY,
    Calisan_Ad_Soyad VARCHAR(100),
    Calisan_Tel VARCHAR(20),
    Birim_ID INT,
    FOREIGN KEY (Birim_ID) REFERENCES Birimler(Birim_ID)
);

-- TumCalisanlar Tablosu
CREATE TABLE TumCalisanlar (
    Calisan_ID INT PRIMARY KEY,
    Calisan_TC VARCHAR(11),
    Calisan_Ad_Soyad VARCHAR(100),
    Calisan_Tel VARCHAR(20),
    Birim_ID INT,
    FOREIGN KEY (Birim_ID) REFERENCES Birimler(Birim_ID)
);

-- AsciYamak Tablosu
CREATE TABLE AsciYamak (
    Calisan_ID INT PRIMARY KEY,
    Calisan_TC VARCHAR(11),
    Calisan_Ad_Soyad VARCHAR(100),
    Calisan_Tel VARCHAR(20),
    Asci_ID INT,
    FOREIGN KEY (Asci_ID) REFERENCES Ascilar(Calisan_ID)
);

-- Ascilar Tablosu
CREATE TABLE Ascilar (
    Calisan_ID INT PRIMARY KEY,
    Calisan_TC VARCHAR(11),
    Calisan_Ad_Soyad VARCHAR(100),
    Calisan_Tel VARCHAR(20),
    Birim_ID INT,
    FOREIGN KEY (Birim_ID) REFERENCES Birimler(Birim_ID)
);

-- YemekYapma Tablosu
CREATE TABLE YemekYapma (
    Asci_ID INT,
    Yemek_ID INT,
    PRIMARY KEY (Asci_ID, Yemek_ID),
    FOREIGN KEY (Asci_ID) REFERENCES Ascilar(Calisan_ID),
    FOREIGN KEY (Yemek_ID) REFERENCES Yemekler(Yemek_ID)
);

-- Yemekler Tablosu
CREATE TABLE Yemekler (
    Yemek_ID INT PRIMARY KEY,
    Yemek_Ad VARCHAR(100),
    Yemek_Turu VARCHAR(50),
    Yemek_Porsiyon INT,
    Yemek_Birim_Tutar DECIMAL(10,2)
);

-- Stok Tablosu
CREATE TABLE Stok (
    Yemek_ID INT PRIMARY KEY,
    Stok_Miktar INT,
    Stok_SonKullanmaTarihi DATE,
    FOREIGN KEY (Yemek_ID) REFERENCES Yemekler(Yemek_ID)
);

-- Doğru Sorgu: Foreign Key İlişkileri Kontrolü
SELECT 
    fk.name AS ForeignKeyName,
    tp.name AS ParentTable,
    cp.name AS ParentColumn,
    tr.name AS ReferencedTable,
    cr.name AS ReferencedColumn
FROM 
    sys.foreign_keys AS fk
INNER JOIN 
    sys.tables AS tp ON fk.parent_object_id = tp.object_id
INNER JOIN 
    sys.tables AS tr ON fk.referenced_object_id = tr.object_id
INNER JOIN 
    sys.foreign_key_columns AS fkc ON fk.object_id = fkc.constraint_object_id
INNER JOIN 
    sys.columns AS cp ON fkc.parent_object_id = cp.object_id AND fkc.parent_column_id = cp.column_id
INNER JOIN 
    sys.columns AS cr ON fkc.referenced_object_id = cr.object_id AND fkc.referenced_column_id = cr.column_id


-- Veritabanındaki tüm tabloyu dışa aktarmak
SELECT * FROM [Araclar];
SELECT * FROM [Ascilar];
SELECT * FROM [AsciYamak];
SELECT * FROM [Birimler];
SELECT * FROM [Dagitim];
SELECT * FROM [LojistikPersonelleri];
SELECT * FROM [Siparis];
SELECT * FROM [SirketBilgileri];
SELECT * FROM [Stok];
SELECT * FROM [TemizlikGorevlileri];
SELECT * FROM [TumCalisanlar];
SELECT * FROM [Yemekler];
SELECT * FROM [YemekYapma];
SELECT * FROM [Yoneticiler];



-- TRIGGERS

-- trigger silme komutu
DROP TRIGGER IF EXISTS trg_SiparisInsert;

--INSERT Trigger (Veri Ekleme Doğrulaması)
CREATE TRIGGER trg_SiparisInsert
ON Siparis
AFTER INSERT
AS
BEGIN
    DECLARE @SiparisID INT;
    SELECT @SiparisID = Siparis_ID FROM INSERTED;

    -- Sipariş ID'si geçerli mi kontrol et
    IF @SiparisID <= 0
    BEGIN
        RAISERROR ('Geçersiz Sipariş ID', 16, 1);
        ROLLBACK TRANSACTION;
    END
END

-- UPDATE Trigger (Veri Güncelleme Doğrulaması)
CREATE TRIGGER trg_SiparisUpdate
ON Siparis
AFTER UPDATE
AS
BEGIN
    DECLARE @Siparis_ID INT, @YeniDurum VARCHAR(50);
    SELECT @Siparis_ID = Siparis_ID, @YeniDurum = Durum FROM INSERTED;

    -- Sipariş durumu geçerli mi?
    IF @YeniDurum NOT IN ('Beklemede', 'Tamamlandı', 'İptal Edildi')
    BEGIN
        RAISERROR ('Geçersiz Sipariş Durumu', 16, 1);
        ROLLBACK TRANSACTION;
    END
END

