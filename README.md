# **Proje Adı: EventFlow**
Event_Flow_Application GitHub projesi, Flutter kullanarak bir etkinlik yönetim uygulamasıdır. Uygulama, etkinliklerinizi listeler, yeni etkinlikler eklemenize izin verir, mevcut etkinlikleri silmenize ve seçilen etkinlikleri kaldırmanıza olanak tanır. Ayrıca, etkinliklere göre geri kalan zamanı gösterir ve etkinliklere resim eklemenize izin verir.

## Kullanılan Teknolojiler:
Dart
Flutter
SQLite (sqflite paketi kullanılarak)
## Uygulama İçeriği:
- EventListScreen: Ana ekran, mevcut etkinlikleri listeler ve silmeyi, seçmeyi ve yeni etkinlik eklemeyi sağlar.
- AddEventScreen: Yeni etkinlik eklemek için ekran, etkinlik adı, tarih, katılımcı sayısı ve etkinlik resmi eklemenizi sağlar.
- Event: Etkinlik veri modeli, etkinlik özelliklerini içerir ve SQLite veritabanına ekleme ve sorgulama işlemleri için yardımcı fonksiyonlara sahiptir.
- EventDatabase: SQLite veritabanı işlemlerini gerçekleştiren sınıf, etkinlik ekleme, sorgulama ve silme fonksiyonlarını içerir.
## Nasıl Kullanılır:
Uygulama başladığında, mevcut etkinlikler EventListScreen ekranında listelenir.
"+" simgesine tıklayarak yeni bir etkinlik ekleyebilirsiniz. Ekran, etkinlik adı, tarih, katılımcı sayısı ve etkinlik resmi eklemenizi sağlar.
Etkinlikler listelenirken, etkinliklerin yanındaki onay kutularını işaretleyerek istediğiniz etkinlikleri seçebilirsiniz.
Seçilen etkinlikleri silmek için "Remove Selected" düğmesine tıklayabilirsiniz.
Etkinliklerin altunda bulunan slider ile etkinliğe kalan süre gösterilir. Süre, etkinliğin tarihine göre dinamik olarak güncellenir.
## Projeyi Çalıştırma Adımları:
Flutter ortamınızı kurun.
Projeyi bir Flutter projesi olarak oluşturun.
Projenizi bir akıllı telefon simülatöründe veya fiziksel bir cihazda çalıştırın.
## Notlar:
Uygulama, Flutter ve Dart programlama dillerini kullanarak geliştirilmiştir.
Veritabanı işlemleri için sqflite paketi kullanılmıştır.
Etkinlik resimleri, etkinlik nesnesine dahil edilebilir.
Etkinliklerin yanındaki sürgü, etkinliğin geri kalan süresini temsil eder.
## Örnek Ekran Görüntüleri:

<img width="266" alt="ss1" src="https://github.com/betulaltunl/Event_Flow_Application/assets/101793578/b9c123c5-3531-408f-9c4e-b79dc2bb3e67">
<img width="271" alt="ss2" src="https://github.com/betulaltunl/Event_Flow_Application/assets/101793578/2415f00e-fda3-4797-83d0-62b886e97060">
<img width="262" alt="ss3" src="https://github.com/betulaltunl/Event_Flow_Application/assets/101793578/207d3f3a-7c36-4a3d-9041-92471d48d731">
<img width="267" alt="ss4" src="https://github.com/betulaltunl/Event_Flow_Application/assets/101793578/78843209-bc42-454a-a6d7-9f6f2964435f">
<img width="270" alt="ss5" src="https://github.com/betulaltunl/Event_Flow_Application/assets/101793578/3fa24251-e080-46ed-a0fd-d8fdbffe4963">
<img width="264" alt="ss6" src="https://github.com/betulaltunl/Event_Flow_Application/assets/101793578/4fddb968-ff69-43f1-81b4-307a21c62cfb">
