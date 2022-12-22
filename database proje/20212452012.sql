-- phpMyAdmin SQL Dump
-- version 5.1.2
-- https://www.phpmyadmin.net/
--
-- Anamakine: localhost:3306
-- Üretim Zamanı: 21 Ara 2022, 19:17:27
-- Sunucu sürümü: 5.7.24
-- PHP Sürümü: 8.0.1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Veritabanı: `karagozkiralama`
--

DELIMITER $$
--
-- Yordamlar
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `1-model-yili-between` (IN `yil1` INT, IN `yil2` INT)   SELECT arac_marka.marka_ad, araclar.model_yili, araclar.modeli FROM araclar INNER JOIN arac_marka ON arac_marka.marka_id = araclar.marka_id WHERE araclar.model_yili BETWEEN yil1 AND yil2$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `10-detaylı-arac-tedarigi` ()   SELECT tedarikci.tedarikci_ad as 'Tedarikci Ad', tedarikci.tedarikci_adresi as 'Tedarikci Adres', tedarikci.tedarikci_telno as 'Tedarikci Telefon NO', arac_marka.marka_ad as 'Araç Marka' FROM arac_tedarik INNER JOIN tedarikci ON arac_tedarik.tedarikci_id = tedarikci.tedarikci_id INNER JOIN araclar ON arac_tedarik.arac_id = araclar.arac_id INNER JOIN arac_marka ON araclar.marka_id = arac_marka.marka_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `11-kiralama-tablosuna-veri-girme` (IN `musteri_id` INT, IN `arac_id` INT, IN `edilis_tarih` DATETIME, IN `alis_tarihi` DATETIME, IN `tutar` FLOAT)   INSERT INTO kiralama VALUES (NULL, musteri_id, arac_id, edilis_tarih, alis_tarihi, tutar)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `2-musteri-telno-ile-arama-kiralama-getirme` (IN `telno` VARCHAR(12))   SELECT CONCAT(musteri.musteri_ad, " ", musteri.musteri_soyad) as MusteriAd, arac_marka.marka_ad, kiralama.teslim_edilis_tarihi, kiralama.teslim_alis_tarihi FROM kiralama, araclar, arac_marka, musteri WHERE kiralama.musteri_id = musteri.musteri_id AND kiralama.arac_id = araclar.arac_id AND araclar.marka_id = arac_marka.marka_id AND musteri.telefon_no LIKE telno$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `3-in-ile-sigortaya-gore-arac-getirtme` (IN `s1` VARCHAR(255), IN `s2` VARCHAR(255))   SELECT araclar.arac_id, arac_marka.marka_ad, sigorta.sirket_ad FROM araclar, arac_marka, sigorta, police WHERE araclar.marka_id = arac_marka.marka_id AND police.sigorta_id = sigorta.sigorta_id AND police.arac_id = araclar.arac_id AND sigorta.sirket_ad IN(s1, s2)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `4-in-ile-tedarikciye-gore-arac-getirtme` (IN `t1` VARCHAR(255), IN `t2` VARCHAR(255))   SELECT araclar.arac_id, arac_marka.marka_ad, tedarikci.tedarikci_ad FROM araclar, arac_marka, tedarikci, arac_tedarik WHERE araclar.marka_id = arac_marka.marka_id AND arac_tedarik.tedarikci_id = tedarikci.tedarikci_id AND arac_tedarik.arac_id = araclar.arac_id AND tedarikci.tedarikci_ad IN(t1, t2)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `5-en-cok-kiralanan marka` ()   SELECT arac_marka.marka_ad, COUNT(kiralama.arac_id) as toplamArac FROM arac_marka, araclar, kiralama
WHERE arac_marka.marka_id = araclar.arac_id AND araclar.arac_id = kiralama.arac_id
GROUP BY kiralama.arac_id
HAVING toplamArac = (SELECT MAX(toplam) FROM (SELECT COUNT(kiralama.arac_id) as toplam FROM arac_marka, araclar, kiralama
WHERE arac_marka.marka_id = araclar.arac_id AND araclar.arac_id = kiralama.arac_id
GROUP BY kiralama.arac_id) as sonuc)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `6-kiralama-tutar-order-by-asc` ()   SELECT arac_marka.marka_ad, kiralama.tutar FROM araclar INNER JOIN arac_marka ON araclar.marka_id = arac_marka.marka_id INNER JOIN kiralama ON araclar.arac_id = kiralama.arac_id ORDER BY kiralama.tutar ASC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `7-kiralama-tutar-order-by-desc` ()   SELECT arac_marka.marka_ad, kiralama.tutar FROM araclar INNER JOIN arac_marka ON araclar.marka_id = arac_marka.marka_id INNER JOIN kiralama ON araclar.arac_id = kiralama.arac_id ORDER BY kiralama.tutar DESC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `8-en-az-tedarik-yapilan-firmalar` ()   SELECT tedarikci.tedarikci_ad, COUNT(arac_tedarik.tedarikci_id) as toplamTedarik FROM arac_tedarik, araclar, tedarikci
WHERE arac_tedarik.arac_id = araclar.arac_id AND arac_tedarik.tedarikci_id = tedarikci.tedarikci_id
GROUP BY arac_tedarik.tedarikci_id
HAVING toplamTedarik = (SELECT MIN(toplam) FROM (SELECT COUNT(arac_tedarik.tedarikci_id) as toplam FROM arac_tedarik, araclar, tedarikci
WHERE arac_tedarik.arac_id = araclar.arac_id AND arac_tedarik.tedarikci_id = tedarikci.tedarikci_id
GROUP BY arac_tedarik.tedarikci_id) as sonuc)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `9-arac-adina-gore-kiralama-detayları` (IN `marka` VARCHAR(255))   SELECT araclar.arac_id, arac_marka.marka_ad, kiralama.teslim_edilis_tarihi, kiralama.teslim_alis_tarihi, kiralama.tutar FROM araclar, arac_marka, kiralama WHERE araclar.marka_id = arac_marka.marka_id AND araclar.arac_id = kiralama.arac_id AND arac_marka.marka_ad IN (marka)$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `araclar`
--

CREATE TABLE `araclar` (
  `arac_id` int(11) NOT NULL,
  `marka_id` int(11) DEFAULT NULL,
  `model_yili` int(11) NOT NULL,
  `modeli` varchar(50) COLLATE utf8_turkish_ci NOT NULL,
  `kira_durumu` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_turkish_ci;

--
-- Tablo döküm verisi `araclar`
--

INSERT INTO `araclar` (`arac_id`, `marka_id`, `model_yili`, `modeli`, `kira_durumu`) VALUES
(1, 1, 2021, 'A6', 0),
(2, 1, 2020, 'A3', 0),
(3, 2, 2022, 'AMG', 1),
(4, 3, 2021, 'M5', 0),
(5, 3, 2021, 'M5', 0),
(6, 4, 2019, 'DB11', 0),
(7, 5, 2020, 'ROMA', 1),
(8, 7, 2022, 'EGEA', 1),
(9, 7, 2021, 'PUNTO', 1),
(10, 9, 2021, 'GIULETTA', 0),
(11, 5, 2021, '812 Superfast', 1);

--
-- Tetikleyiciler `araclar`
--
DELIMITER $$
CREATE TRIGGER `1-arac-eklendiginde-loglama` AFTER INSERT ON `araclar` FOR EACH ROW INSERT INTO arac_log VALUES (new.arac_id, new.marka_id, now())
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `arac_log`
--

CREATE TABLE `arac_log` (
  `arac_id` int(11) DEFAULT NULL,
  `marka_id` int(11) DEFAULT NULL,
  `islem_tarihi` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_turkish_ci;

--
-- Tablo döküm verisi `arac_log`
--

INSERT INTO `arac_log` (`arac_id`, `marka_id`, `islem_tarihi`) VALUES
(11, 5, '2022-12-21 21:17:52');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `arac_marka`
--

CREATE TABLE `arac_marka` (
  `marka_id` int(11) NOT NULL,
  `marka_ad` varchar(50) COLLATE utf8_turkish_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_turkish_ci;

--
-- Tablo döküm verisi `arac_marka`
--

INSERT INTO `arac_marka` (`marka_id`, `marka_ad`) VALUES
(1, 'AUDI'),
(2, 'MERCEDES'),
(3, 'BMW'),
(4, 'ASTON MARTIN'),
(5, 'FERRARI'),
(6, 'LANCIA'),
(7, 'FIAT'),
(8, 'TOYOTA'),
(9, 'ALFA ROMEO'),
(10, 'HYUNDAI');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `arac_tedarik`
--

CREATE TABLE `arac_tedarik` (
  `aractedarik_id` int(11) NOT NULL,
  `tedarikci_id` int(11) DEFAULT NULL,
  `arac_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_turkish_ci;

--
-- Tablo döküm verisi `arac_tedarik`
--

INSERT INTO `arac_tedarik` (`aractedarik_id`, `tedarikci_id`, `arac_id`) VALUES
(1, 1, 2),
(2, 2, 1),
(3, 3, 4),
(4, 4, 3),
(5, 5, 6),
(6, 6, 5),
(7, 7, 8),
(8, 8, 7),
(9, 10, 10),
(10, 10, 9);

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `kiralama`
--

CREATE TABLE `kiralama` (
  `kiralama_id` int(11) NOT NULL,
  `musteri_id` int(11) DEFAULT NULL,
  `arac_id` int(11) DEFAULT NULL,
  `teslim_edilis_tarihi` datetime DEFAULT NULL,
  `teslim_alis_tarihi` datetime DEFAULT NULL,
  `tutar` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_turkish_ci;

--
-- Tablo döküm verisi `kiralama`
--

INSERT INTO `kiralama` (`kiralama_id`, `musteri_id`, `arac_id`, `teslim_edilis_tarihi`, `teslim_alis_tarihi`, `tutar`) VALUES
(1, 1, 2, '2022-12-20 00:00:00', '2022-12-21 00:00:00', 200),
(2, 2, 1, '2022-12-20 00:00:00', '2022-12-26 00:00:00', 300),
(3, 3, 4, '2022-12-20 00:00:00', '2022-12-23 00:00:00', 300),
(4, 4, 3, '2022-12-20 00:00:00', '2022-12-25 00:00:00', 400),
(5, 5, 6, '2022-12-20 00:00:00', '2022-12-31 00:00:00', 700),
(6, 6, 5, '2022-12-20 00:00:00', '2023-01-02 00:00:00', 500),
(7, 7, 8, '2022-12-20 00:00:00', '2022-12-21 00:00:00', 800),
(8, 8, 7, '2022-12-20 00:00:00', '2022-12-29 00:00:00', 900),
(9, 9, 10, '2022-12-20 00:00:00', '2022-12-22 00:00:00', 300),
(10, 10, 1, '2022-12-20 00:00:00', '2022-12-25 00:00:00', -1500),
(11, 1, 1, '2022-12-21 00:00:00', '2022-12-25 00:00:00', 100),
(12, 7, 11, '2022-12-21 21:25:30', '2022-12-23 21:25:30', 8000);

--
-- Tetikleyiciler `kiralama`
--
DELIMITER $$
CREATE TRIGGER `2-kiralanan-aracı-durumunu-true-yapma` AFTER INSERT ON `kiralama` FOR EACH ROW UPDATE araclar SET araclar.kira_durumu = true
WHERE araclar.arac_id = new.arac_id
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `musteri`
--

CREATE TABLE `musteri` (
  `musteri_id` int(11) NOT NULL,
  `musteri_ad` varchar(255) COLLATE utf8_turkish_ci NOT NULL,
  `musteri_soyad` varchar(255) COLLATE utf8_turkish_ci NOT NULL,
  `musteri_adres` varchar(255) COLLATE utf8_turkish_ci NOT NULL,
  `telefon_no` varchar(12) COLLATE utf8_turkish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_turkish_ci;

--
-- Tablo döküm verisi `musteri`
--

INSERT INTO `musteri` (`musteri_id`, `musteri_ad`, `musteri_soyad`, `musteri_adres`, `telefon_no`) VALUES
(1, 'Salih', 'Karagoz', 'Gaziemir', '5323585225'),
(2, 'Yagiz', 'Turasan', 'Bornova', '5323585227'),
(3, 'Cem', 'Ates', 'Bornova', '5323585221'),
(4, 'Samet', 'Gunes', 'Balcova', '5323585222'),
(5, 'Yagiz', 'Akyuz', 'Gaziemir', '5323968016'),
(6, 'Baris', 'Bal', 'Bornova', '5323585223'),
(7, 'Alper', 'Boyacı', 'Bornova', '5323585224'),
(8, 'Yagmur', 'Gur', 'Buca', '5323585228'),
(9, 'Senem', 'Bil', 'Bozyaka', '5323585229'),
(10, 'Burak', 'Evrentug', 'Karsiyaka', '5323585220');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `police`
--

CREATE TABLE `police` (
  `police_id` int(11) NOT NULL,
  `sigorta_id` int(11) DEFAULT NULL,
  `arac_id` int(11) DEFAULT NULL,
  `police_detay` varchar(255) COLLATE utf8_turkish_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_turkish_ci;

--
-- Tablo döküm verisi `police`
--

INSERT INTO `police` (`police_id`, `sigorta_id`, `arac_id`, `police_detay`) VALUES
(1, 1, 2, 'carpani dusuk'),
(2, 2, 1, 'ozel police'),
(3, 3, 4, 'carpan yuksek'),
(4, 4, 3, 'ozel police'),
(5, 5, 6, 'carpan yuksek'),
(6, 6, 5, 'ozel police'),
(7, 7, 8, 'kiralama ozel police'),
(8, 8, 7, 'ozel police'),
(9, 9, 10, 'carpan yuksek'),
(10, 10, 9, 'kiralama ozel police');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `sigorta`
--

CREATE TABLE `sigorta` (
  `sigorta_id` int(11) NOT NULL,
  `sirket_ad` varchar(50) COLLATE utf8_turkish_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_turkish_ci;

--
-- Tablo döküm verisi `sigorta`
--

INSERT INTO `sigorta` (`sigorta_id`, `sirket_ad`) VALUES
(1, 'AK SIGORTA'),
(2, 'ALLIANZ'),
(3, 'ANADOLU SIGORTA'),
(4, 'GROUPAMA'),
(5, 'ANKARA SIGORTA'),
(6, 'ACN TURK SIGORTA'),
(7, 'ANA SIGORTA'),
(8, 'AREX SIGORTA'),
(9, 'DOGA SIGORTA'),
(10, 'AVEON SIGORTA');

--
-- Tetikleyiciler `sigorta`
--
DELIMITER $$
CREATE TRIGGER `3-güncel-sigorta-firmasi-sayisi-ekleme` AFTER INSERT ON `sigorta` FOR EACH ROW INSERT INTO toplam_sigorta VALUES ((SELECT COUNT(*) FROM sigorta), now())
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `4-güncel-sigorta-firmasi-sayisi-silme` AFTER DELETE ON `sigorta` FOR EACH ROW INSERT INTO toplam_sigorta VALUES ((SELECT COUNT(*) FROM sigorta), now())
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `tedarikci`
--

CREATE TABLE `tedarikci` (
  `tedarikci_id` int(11) NOT NULL,
  `tedarikci_ad` varchar(50) COLLATE utf8_turkish_ci NOT NULL,
  `tedarikci_adresi` varchar(255) COLLATE utf8_turkish_ci NOT NULL,
  `tedarikci_telno` varchar(12) COLLATE utf8_turkish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_turkish_ci;

--
-- Tablo döküm verisi `tedarikci`
--

INSERT INTO `tedarikci` (`tedarikci_id`, `tedarikci_ad`, `tedarikci_adresi`, `tedarikci_telno`) VALUES
(1, 'Ege OTO Galeri', 'Buca', '5323568520'),
(2, 'Karadeniz OTO Galeri', 'Trabzon Ortahisar', '5326616161'),
(3, 'Marmara OTO Galeri', 'Beykoz', '5323562850'),
(4, 'Güney Dogu OTO Galeri', 'Gaziantep', '5233568520'),
(5, 'Akdeniz OTO Galeri', 'Kemer', '5323678520'),
(6, 'Ic Anadolu OTO Galeri', 'Kızılay', '5326168520'),
(7, 'Istanbullu OTO Galeri', 'Uskudar', '5323568520'),
(8, 'Denizli OTO Galeri', 'Denizli', '5323598520'),
(9, 'Gaziemir OTO Galeri', 'Gaziemir', '5323563320'),
(10, 'Kaba OTO Galeri', 'Bornova', '5323268520');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `toplam_sigorta`
--

CREATE TABLE `toplam_sigorta` (
  `toplam_sigorta_firmasi` int(11) DEFAULT NULL,
  `islem_tarihi` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_turkish_ci;

--
-- Tablo döküm verisi `toplam_sigorta`
--

INSERT INTO `toplam_sigorta` (`toplam_sigorta_firmasi`, `islem_tarihi`) VALUES
(11, '2022-12-21 22:04:08'),
(10, '2022-12-21 22:04:11');

--
-- Dökümü yapılmış tablolar için indeksler
--

--
-- Tablo için indeksler `araclar`
--
ALTER TABLE `araclar`
  ADD PRIMARY KEY (`arac_id`),
  ADD KEY `araclar_marka_fk` (`marka_id`);

--
-- Tablo için indeksler `arac_marka`
--
ALTER TABLE `arac_marka`
  ADD PRIMARY KEY (`marka_id`);

--
-- Tablo için indeksler `arac_tedarik`
--
ALTER TABLE `arac_tedarik`
  ADD PRIMARY KEY (`aractedarik_id`),
  ADD KEY `at_tedarikci_fk` (`tedarikci_id`),
  ADD KEY `at_arac_fk` (`arac_id`);

--
-- Tablo için indeksler `kiralama`
--
ALTER TABLE `kiralama`
  ADD PRIMARY KEY (`kiralama_id`),
  ADD KEY `kiralama_musteri_fk` (`musteri_id`),
  ADD KEY `kiralama_arac_fk` (`arac_id`);

--
-- Tablo için indeksler `musteri`
--
ALTER TABLE `musteri`
  ADD PRIMARY KEY (`musteri_id`);

--
-- Tablo için indeksler `police`
--
ALTER TABLE `police`
  ADD PRIMARY KEY (`police_id`),
  ADD KEY `police_sigorta_fk` (`sigorta_id`),
  ADD KEY `police_arac_fk` (`arac_id`);

--
-- Tablo için indeksler `sigorta`
--
ALTER TABLE `sigorta`
  ADD PRIMARY KEY (`sigorta_id`);

--
-- Tablo için indeksler `tedarikci`
--
ALTER TABLE `tedarikci`
  ADD PRIMARY KEY (`tedarikci_id`);

--
-- Dökümü yapılmış tablolar için AUTO_INCREMENT değeri
--

--
-- Tablo için AUTO_INCREMENT değeri `araclar`
--
ALTER TABLE `araclar`
  MODIFY `arac_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- Tablo için AUTO_INCREMENT değeri `arac_marka`
--
ALTER TABLE `arac_marka`
  MODIFY `marka_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- Tablo için AUTO_INCREMENT değeri `arac_tedarik`
--
ALTER TABLE `arac_tedarik`
  MODIFY `aractedarik_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- Tablo için AUTO_INCREMENT değeri `kiralama`
--
ALTER TABLE `kiralama`
  MODIFY `kiralama_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- Tablo için AUTO_INCREMENT değeri `musteri`
--
ALTER TABLE `musteri`
  MODIFY `musteri_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- Tablo için AUTO_INCREMENT değeri `police`
--
ALTER TABLE `police`
  MODIFY `police_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- Tablo için AUTO_INCREMENT değeri `sigorta`
--
ALTER TABLE `sigorta`
  MODIFY `sigorta_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- Tablo için AUTO_INCREMENT değeri `tedarikci`
--
ALTER TABLE `tedarikci`
  MODIFY `tedarikci_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- Dökümü yapılmış tablolar için kısıtlamalar
--

--
-- Tablo kısıtlamaları `araclar`
--
ALTER TABLE `araclar`
  ADD CONSTRAINT `araclar_marka_fk` FOREIGN KEY (`marka_id`) REFERENCES `arac_marka` (`marka_id`);

--
-- Tablo kısıtlamaları `arac_tedarik`
--
ALTER TABLE `arac_tedarik`
  ADD CONSTRAINT `at_arac_fk` FOREIGN KEY (`arac_id`) REFERENCES `araclar` (`arac_id`),
  ADD CONSTRAINT `at_tedarikci_fk` FOREIGN KEY (`tedarikci_id`) REFERENCES `tedarikci` (`tedarikci_id`);

--
-- Tablo kısıtlamaları `kiralama`
--
ALTER TABLE `kiralama`
  ADD CONSTRAINT `kiralama_arac_fk` FOREIGN KEY (`arac_id`) REFERENCES `araclar` (`arac_id`),
  ADD CONSTRAINT `kiralama_musteri_fk` FOREIGN KEY (`musteri_id`) REFERENCES `musteri` (`musteri_id`);

--
-- Tablo kısıtlamaları `police`
--
ALTER TABLE `police`
  ADD CONSTRAINT `police_arac_fk` FOREIGN KEY (`arac_id`) REFERENCES `araclar` (`arac_id`),
  ADD CONSTRAINT `police_sigorta_fk` FOREIGN KEY (`sigorta_id`) REFERENCES `sigorta` (`sigorta_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
