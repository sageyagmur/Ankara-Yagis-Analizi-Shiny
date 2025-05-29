# Ankara-Yagis-Analizi-Shiny
Ankara için yağış, baraj doluluk ve sıcaklık verilerini görselleştiren ve çeşitli analizler (zaman serisi, kümeleme, korelasyon, anomali) sunan interaktif R Shiny uygulaması.
# Ankara İli İklim Değişkenliği ve Su Kaynakları Analiz Platformu

**[➡️ UYGULAMAYI CANLI GÖRÜNTÜLEMEK İÇİN TIKLAYIN ⬅️](https://yagmurporsuk.shinyapps.io/ankara-yagmur/)**

---

## 📝 Proje Hakkında

Bu proje, Ankara ilinin çok yıllı yağış, baraj doluluk ve uzun dönem sıcaklık verilerini analiz etmek ve görselleştirmek amacıyla R programlama dili ve Shiny web uygulama çerçevesi kullanılarak geliştirilmiş interaktif bir gösterge panelidir (dashboard). Uygulama, ham veriyi anlamlı ve yorumlanabilir bilgilere dönüştürerek, iklimsel trendlerin ve su kaynakları durumunun daha iyi anlaşılmasına katkıda bulunmayı hedefler.

Ankara gibi büyük bir metropolün su kaynaklarının sürdürülebilir yönetimi ve iklim değişikliğinin potansiyel etkilerine karşı hazırlıklı olunması kritik öneme sahiptir. 
Bu araç, karar vericilere, araştırmacılara ve konuya ilgi duyan herkese veri odaklı bir bakış açısı sunmak için tasarlanmıştır.

---

## ✨ Temel Özellikler ve Analizler

Uygulama aşağıdaki analiz modüllerini içermektedir:

* **Zaman Serisi Analizi:** Seçilen yıla ait aylık yağış miktarı ile uzun dönemli ortalama sıcaklık trendlerinin karşılaştırmalı gösterimi.
* **Kutu Grafiği (Boxplot):** Tüm yıllar için aylık yağış verilerinin dağılımı, merkezi eğilimleri ve aykırı değerlerinin incelenmesi.
* **Saçılım Grafiği:** Seçilen yıl için aylık yağış miktarı ile baraj doluluk oranları arasındaki ilişkinin, trend çizgisi ve aylık etiketlerle birlikte görselleştirilmesi.
* **Kümeleme Analizi (K-Means):** Ayların yağış ve baraj doluluk özelliklerine göre benzer gruplara (kümelere) ayrılması ve bu kümelerin elipslerle görselleştirilmesi.
* **Korelasyon Isı Haritası:** Yağış, baraj doluluğu ve ortalama sıcaklık değişkenlerinin birbirleriyle olan korelasyon ilişkilerinin renkli bir matris üzerinde gösterimi.
* **Aykırı Yıl (Anomali) Analizi:** Seçilen bir ay özelinde, tüm yılların yağış miktarlarının tarihsel ortalama ve standart sapma ile karşılaştırılarak anormal (kurak/yağışlı) yılların tespiti.
* **İnteraktif Grafikler:** Saçılım ve kümeleme analizlerinin, üzerine gelindiğinde detaylı bilgi sunan, yakınlaştırılabilen interaktif versiyonları.

---

## 🖼️ Uygulama Görüntüleri

**Örnek 1: Ana Gösterge Paneli**
![image](https://github.com/user-attachments/assets/29761d4b-38af-4b9a-a206-62cfb8fbc954)


**Örnek 2: Korelasyon Isı Haritası**
![image](https://github.com/user-attachments/assets/97479cab-354e-4d4d-85b6-71c523c048a1)

---

## 🛠️ Kullanılan Teknolojiler

* **Programlama Dili:** R
* **Web Uygulama Çerçevesi:** Shiny, shinydashboard
* **Veri Manipülasyonu:** dplyr, tidyr
* **Veri Görselleştirme:** ggplot2, plotly
* **Veri Okuma:** readxl
* **Metin İşleme:** stringr

---

## 📊 Veri Kaynakları

Bu projede kullanılan veriler aşağıdaki kamu kurumlarından temin edilmiştir:

* Yağış ve İklim Verileri: Meteoroloji Genel Müdürlüğü (MGM) ve T.C. Çevre, Şehircilik ve İklim Değişikliği Bakanlığı (Ulaşım Ağları Veri Portalı).
* Baraj Doluluk Verileri: Ankara Su ve Kanalizasyon İdaresi (ASKİ).

---

## 🚀 Kurulum ve Yerel Çalıştırma

Bu Shiny uygulamasını kendi bilgisayarınızda çalıştırmak için aşağıdaki adımları izleyebilirsiniz:

1.  **Bu Repository'yi Klonlayın veya İndirin:**
    ```bash
    git clone https://github.com/sageyagmur/Ankara-Yagis-Analizi-Shiny/tree/main
    cd [Ankara-Yagis-Analizi-Shiny]
    ```
2.  **Gerekli R Paketlerini Yükleyin:**
    R veya RStudio konsolunda aşağıdaki komutu çalıştırın:
    ```R
    install.packages(c("shiny", "shinydashboard", "readxl", "readr", "dplyr", "tidyr", "ggplot2", "stringr", "plotly"))
    ```
3.  **Uygulamayı Çalıştırın:**
    RStudio'da `app.R` dosyasını açın ve sağ üst köşedeki "Run App" butonuna tıklayın veya konsola aşağıdaki komutu yazın:
    ```R
    shiny::runApp()
    ```
    *(Not: Veri dosyalarının (`.xlsx`) `app.R` dosyasıyla aynı dizinde veya kodda belirtilen doğru yolda olduğundan emin olun.)*

---

## 📄 Lisans

Bu proje [MIT Lisansı](LICENSE) altında lisanslanmıştır. 

---

## 👤 İletişim 

Eğer bu proje ile ilgili sorularınız, önerileriniz veya geri bildirimleriniz olursa, benimle Yağmur Porsuk - (yagmurporsuk0@gmail.com)  üzerinden iletişime geçebilirsiniz.
