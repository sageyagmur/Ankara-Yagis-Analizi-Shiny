# Gerekli paketler
library(shiny)
library(shinydashboard)
library(readxl)
library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(stringr)
library(plotly)



#VERİ HAZIRLIK BÖLÜMÜ



# Dosya yolları 
rain_file_path <- "data/2000-2021-temmuz-arasi-aylik-ortalama-yai-miktarlari.xlsx"
baraj_file_path <- "data/Baraj_Su_Miktarlari_2000_2022.xlsx"
iklim_file_path <- "data/Ankara_Iklim_Verileri_1927_2024.xlsx"


# Dosya yolları
#rain_file_path <- "C:/Users/yagmu/Desktop/2000-2021-temmuz-arasi-aylik-ortalama-yai-miktarlari.xlsx"
#baraj_file_path <- "C:/Users/yagmu/Desktop/Baraj_Su_Miktarlari_2000_2022.xlsx"
#iklim_file_path <- "C:/Users/yagmu/Desktop/Ankara_Iklim_Verileri_1927_2024.xlsx"

# Dosya varlık kontrolü
if (!file.exists(rain_file_path)) stop("Yagis verisi dosyasi bulunamadi")
if (!file.exists(baraj_file_path)) stop("Baraj verisi dosyasi bulunamadi")
if (!file.exists(iklim_file_path)) stop("Iklim verisi dosyasi bulunamadi")

# Veriler Excel'de temizlendiği için basit ay temizleme
ay_temizle <- function(ay_sutunu) {
  toupper(ay_sutunu) %>%
    str_trim()
}

# Ay sıralaması
ay_sirasi <- c("OCAK", "SUBAT", "MART", "NISAN", "MAYIS", "HAZIRAN",
               "TEMMUZ", "AGUSTOS", "EYLUL", "EKIM", "KASIM", "ARALIK")


rain_raw <- read_excel(rain_file_path, sheet = "Sayfa1")
colnames(rain_raw) <- c("YIL", "AY_raw", "YAGIS_str", "VERI_ORANI_str")
rain_data <- rain_raw %>%
  mutate(
    AY = ay_temizle(AY_raw),
    YAGIS = as.numeric(gsub(",", ".", YAGIS_str)),
    YIL = as.integer(YIL)
  ) %>%
  select(YIL, AY, YAGIS) %>%
  mutate(AY = factor(AY, levels = ay_sirasi, ordered = TRUE)) %>%
  filter(!is.na(AY))


baraj_raw <- read_excel(baraj_file_path, sheet = 1)
baraj_temiz_isimler <- c("YIL", "Ocak", "Subat", "Mart", "Nisan", "Mayis", "Haziran",
                         "Temmuz", "Agustos", "Eylul", "Ekim", "Kasim", "Aralik", "Toplam")
names(baraj_raw) <- baraj_temiz_isimler
baraj_long <- baraj_raw %>%
  select(-Toplam) %>%
  pivot_longer(cols = -YIL, names_to = "AY_raw", values_to = "Doluluk") %>%
  mutate(
    AY = ay_temizle(AY_raw),
    Doluluk = as.numeric(Doluluk),
    YIL = as.integer(YIL)
  ) %>%
  mutate(AY = factor(AY, levels = ay_sirasi, ordered = TRUE)) %>%
  filter(!is.na(AY))


iklim_raw <- read_excel(iklim_file_path, sheet = 1)
iklim_temiz_isimler <- c("Olcum_Periyodu", "Degisken", "Ocak", "Subat", "Mart", "Nisan", "Mayis", "Haziran",
                         "Temmuz", "Agustos", "Eylul", "Ekim", "Kasim", "Aralik", "Yillik")
names(iklim_raw) <- iklim_temiz_isimler
long_term_avg_temp <- iklim_raw %>%
  filter(str_detect(Degisken, "Ortalama S")) %>%
  select(-Yillik, -Olcum_Periyodu, -Degisken) %>%
  pivot_longer(cols = everything(), names_to = "AY_raw", values_to = "SICAKLIK_str") %>%
  mutate(
    AY = ay_temizle(AY_raw),
    SICAKLIK = as.numeric(gsub(",", ".", SICAKLIK_str))
  ) %>%
  select(AY, SICAKLIK) %>%
  mutate(AY = factor(AY, levels = ay_sirasi, ordered = TRUE)) %>%
  filter(!is.na(AY))



# UI (Arayüz) BÖLÜMÜ 
ui <- dashboardPage(
  dashboardHeader(title = "Ankara Veri Analizi"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Analiz", tabName = "analysis", icon = icon("chart-line")),
      selectInput("selected_year", "Yil Seciniz:",
                  choices = sort(unique(rain_data$YIL), decreasing = TRUE),
                  selected = max(rain_data$YIL, na.rm = TRUE)),
      radioButtons("analysis_type", "Analiz Turu:",
                   choices = c("Zaman Serisi", "Boxplot", "Sacilim Grafigi", "Kumeleme",
                               "Korelasyon Isi Haritasi",
                               "Aykiri Yil Analizi", 
                               "Interaktif Sacilim", "Interaktif Kumeleme"),
                   selected = "Zaman Serisi"),
      
     
      
      conditionalPanel(
        condition = "input.analysis_type == 'Aykiri Yil Analizi'",
        selectInput("selected_month", "Ay Seciniz:",
                    choices = levels(rain_data$AY), 
                    selected = "ARALIK") 
      )
    )
  ),
  
  dashboardBody(
 
    tabItems(
      tabItem(tabName = "analysis",
              fluidRow(
                box(title = "Analiz Grafigi", status = "primary", solidHeader = TRUE, width = 12,
                    conditionalPanel(
                      condition = "input.analysis_type == 'Interaktif Sacilim' || input.analysis_type == 'Interaktif Kumeleme'",
                      plotlyOutput("interactivePlot", height = "600px")
                    ),
                    conditionalPanel(
                      condition = "input.analysis_type != 'Interaktif Sacilim' && input.analysis_type != 'Interaktif Kumeleme'",
                      plotOutput("mainPlot", height = "600px")
                    )
                )
              )
      )
    )
  )
)



# SERVER (Sunucu) BÖLÜMÜ -
server <- function(input, output, session) {
  
  filtered_rain <- reactive({ req(input$selected_year); rain_data %>% filter(YIL == input$selected_year) })
  filtered_baraj <- reactive({ req(input$selected_year); baraj_long %>% filter(YIL == input$selected_year) })
  
  output$mainPlot <- renderPlot({
    selected_year_num <- as.integer(input$selected_year)
    
    if (input$analysis_type == "Zaman Serisi") {
    
      req(selected_year_num)
      rain_for_year <- filtered_rain()
      data_for_plot <- left_join(rain_for_year, long_term_avg_temp, by = "AY")
      p <- ggplot(data_for_plot, aes(x = AY, group = 1))
      if (any(!is.na(data_for_plot$YAGIS))) { p <- p + geom_line(aes(y = YAGIS, color = "Yagis Miktari (mm)")) + geom_point(aes(y = YAGIS, color = "Yagis Miktari (mm)")) }
      if (any(!is.na(data_for_plot$SICAKLIK))) { p <- p + geom_line(aes(y = SICAKLIK, color = "Uzun Donem Ort. Sicaklik (C)"), linetype = "dashed") + geom_point(aes(y = SICAKLIK, color = "Uzun Donem Ort. Sicaklik (C)")) }
      p + labs(title = paste(selected_year_num, "Yili Yagis Miktari ve Uzun Donem Ortalama Sicakliklar"), x = "Ay", y = "Degerler") + scale_color_manual(name = "Gosterge", values = c("Yagis Miktari (mm)" = "blue", "Uzun Donem Ort. Sicaklik (C)" = "red")) + theme_minimal() + theme(legend.position = "top")
      
    } else if (input$analysis_type == "Boxplot") {
    
      ggplot(rain_data, aes(x = AY, y = YAGIS)) + geom_boxplot(fill = "lightblue") + labs(title = "Yillara Gore Aylik Yagis Dagilimi (Boxplot)", x = "Ay", y = "Yagis (mm)") + theme_minimal()
      
    } else if (input$analysis_type == "Sacilim Grafigi") {
    
      merged <- inner_join(filtered_rain(), filtered_baraj(), by = c("YIL", "AY"))
      if(nrow(na.omit(merged)) > 1) { ggplot(merged, aes(x = YAGIS, y = Doluluk)) + geom_point(aes(color = AY), size = 5, alpha = 0.7) + geom_smooth(method = "lm", se = FALSE, color = "#2c3e50", linetype = "dashed", size = 1) + geom_text(aes(label = AY), nudge_y = 5, size = 3, check_overlap = TRUE) + theme_bw() + labs(title = paste(selected_year_num, "- Yagis ve Baraj Doluluk Iliskisi"), subtitle = "Aylik veriler ve lineer trend cizgisi", x = "Aylik Yagis Miktari (mm)", y = "Baraj Doluluk (Milyon m3)", color = "Aylar") + theme(legend.position = "none", plot.title = element_text(face = "bold", hjust = 0.5, size=16), plot.subtitle = element_text(hjust = 0.5, size=12)) }
      
    } else if (input$analysis_type == "Kumeleme") {
     
      merged <- inner_join(filtered_rain(), filtered_baraj(), by = c("YIL", "AY")) %>% na.omit()
      if (nrow(merged) >= 2) { set.seed(123); data_for_kmeans <- merged %>% select(YAGIS, Doluluk); data_for_kmeans_scaled <- scale(data_for_kmeans); km <- kmeans(data_for_kmeans_scaled, centers = 3, nstart = 25); merged$Cluster <- factor(km$cluster); ggplot(merged, aes(x = YAGIS, y = Doluluk, color = Cluster, shape = Cluster)) + stat_ellipse(geom = "polygon", aes(fill = Cluster), alpha = 0.2, type = "t") + geom_point(size = 5, alpha = 0.8) + geom_text(aes(label = AY), nudge_y = 5, size = 3, color = "black", check_overlap = TRUE) + theme_bw() + labs(title = paste(selected_year_num, "- Yagis ve Baraj Dolulugu Kumeleme Analizi"), subtitle = "K-Means Kumelemesi (k=3)", x = "Aylik Yagis Miktari (mm)", y = "Baraj Doluluk (Milyon m3)") + theme(plot.title = element_text(face = "bold", hjust = 0.5, size=16), plot.subtitle = element_text(hjust = 0.5, size=12), legend.position = "bottom") }
      
    } else if (input$analysis_type == "Korelasyon Isi Haritasi") {
    
      avg_rain_monthly <- rain_data %>% group_by(AY) %>% summarize(YAGIS = mean(YAGIS, na.rm = TRUE)); avg_dam_monthly <- baraj_long %>% group_by(AY) %>% summarize(DOLULUK = mean(Doluluk, na.rm = TRUE)); summary_data <- long_term_avg_temp %>% rename(SICAKLIK = SICAKLIK) %>% left_join(avg_rain_monthly, by = "AY") %>% left_join(avg_dam_monthly, by = "AY"); corr_matrix_data <- summary_data %>% select(SICAKLIK, YAGIS, DOLULUK); corr_matrix <- cor(corr_matrix_data, use = "complete.obs"); corr_matrix_long <- as.data.frame(corr_matrix) %>% tibble::rownames_to_column(var = "Var1") %>% pivot_longer(cols = -Var1, names_to = "Var2", values_to = "value"); ggplot(corr_matrix_long, aes(x = Var1, y = Var2, fill = value)) + geom_tile(color = "white", lwd = 1.5, linetype = 1) + geom_text(aes(label = round(value, 2)), color = "black", size = 6) + scale_fill_gradient2(low = "#d7191c", high = "#2c7bb6", mid = "white", midpoint = 0, limit = c(-1,1), name="Korelasyon") + coord_fixed() + theme_minimal() + labs(title = "Degiskenler Arasi Korelasyon Isi Haritasi", subtitle = "Tum yillarin aylik ortalamalari uzerinden hesaplanmistir", x = "", y = "") + theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1, size = 12), axis.text.y = element_text(size = 12), plot.title = element_text(face="bold", hjust=0.5, size=16), plot.subtitle = element_text(hjust=0.5, size=12), legend.position = "bottom", panel.grid.major = element_blank())
      
    } else if (input$analysis_type == "Aykiri Yil Analizi") {
   
      req(input$selected_month)
      
     
      monthly_data <- rain_data %>%
        filter(AY == input$selected_month & !is.na(YAGIS))
      
      if(nrow(monthly_data) > 0) {
     
        mean_yagis <- mean(monthly_data$YAGIS)
        sd_yagis <- sd(monthly_data$YAGIS)
        upper_bound <- mean_yagis + sd_yagis
        lower_bound <- mean_yagis - sd_yagis
        
        monthly_data_plot <- monthly_data %>%
          mutate(Vurgu = ifelse(YIL == selected_year_num, "Secilen Yil", "Diger Yillar"))
 
        ggplot(monthly_data_plot, aes(x = factor(YIL), y = YAGIS, fill = Vurgu)) +
          geom_col(width = 0.8) +
          geom_hline(aes(yintercept = mean_yagis, linetype = "Ortalama"), color = "black", size = 1) +
          geom_hline(aes(yintercept = upper_bound, linetype = "Standart Sapma"), color = "blue", size = 1) +
          geom_hline(aes(yintercept = lower_bound, linetype = "Standart Sapma"), color = "blue", size = 1) +
          scale_fill_manual(name = "", values = c("Secilen Yil" = "#e41a1c", "Diger Yillar" = "#377eb8")) +
          scale_linetype_manual(name = "Istatistikler", values = c("Ortalama" = "solid", "Standart Sapma" = "dashed")) +
          labs(
            title = paste(input$selected_month, "Ayi Yagis Miktari Anomalileri"),
            subtitle = paste("Secilen yil (", selected_year_num, ") diger yillara ve tarihsel ortalamaya gore durumu"),
            x = "Yil",
            y = "Yagis Miktari (mm)"
          ) +
          theme_bw() +
          guides(fill = guide_legend(order = 1), linetype = guide_legend(order = 2)) + # Legend sırasını ayarla
          theme(
            axis.text.x = element_text(angle = 90, vjust = 0.5, size = 10),
            plot.title = element_text(face="bold", hjust=0.5, size=16),
            plot.subtitle = element_text(hjust=0.5, size=12),
            legend.position = "bottom",
            legend.box = "vertical"
          )
      }
    }
  })
  
  # İnteraktif plotlar 
  output$interactivePlot <- renderPlotly({
   
    selected_year_num <- as.integer(input$selected_year); req(selected_year_num); merged <- inner_join(filtered_rain(), filtered_baraj(), by = c("YIL", "AY")) %>% na.omit()
    if (input$analysis_type == "Interaktif Sacilim") {
      if(nrow(merged) > 1) { tooltip_text <- paste("Ay:", merged$AY, "<br>Yagis:", round(merged$YAGIS, 1), "mm", "<br>Doluluk:", round(merged$Doluluk, 1), "Milyon m3"); p <- ggplot(merged, aes(x = YAGIS, y = Doluluk, text = tooltip_text)) + geom_point(aes(color = AY), size = 5, alpha = 0.7) + geom_smooth(method = "lm", se = FALSE, color = "#2c3e50", linetype = "dashed", size = 1) + theme_bw() + labs(title = paste(selected_year_num, "- Yagis ve Baraj Doluluk Iliskisi (Interaktif)"), x = "Aylik Yagis Miktari (mm)", y = "Baraj Doluluk (Milyon m3)") + theme(legend.position = "none", plot.title = element_text(face = "bold", hjust = 0.5, size=16)); ggplotly(p, tooltip = "text") }
    } else if (input$analysis_type == "Interaktif Kumeleme") {
      if (nrow(merged) >= 3) { set.seed(123); data_for_kmeans <- merged %>% select(YAGIS, Doluluk); data_for_kmeans_scaled <- scale(data_for_kmeans); km <- kmeans(data_for_kmeans_scaled, centers = 3, nstart = 25); merged$Cluster <- factor(km$cluster); tooltip_text <- paste("Ay:", merged$AY, "<br>Yagis:", round(merged$YAGIS, 1), "mm", "<br>Doluluk:", round(merged$Doluluk, 1), "Milyon m3", "<br>Kume:", merged$Cluster); p <- ggplot(merged, aes(x = YAGIS, y = Doluluk, color = Cluster, shape = Cluster, text = tooltip_text)) + stat_ellipse(geom = "polygon", aes(fill = Cluster), alpha = 0.2, type = "t") + geom_point(size = 5, alpha = 0.8) + theme_bw() + labs(title = paste(selected_year_num, "- Yagis ve Baraj Dolulugu Kumeleme Analizi (Interaktif)"), subtitle = "K-Means Kumelemesi (k=3)", x = "Aylik Yagis Miktari (mm)", y = "Baraj Doluluk (Milyon m3)") + theme(plot.title = element_text(face = "bold", hjust = 0.5, size=16), plot.subtitle = element_text(hjust = 0.5, size=12), legend.position = "bottom"); ggplotly(p, tooltip = "text") }
    }
  })
}

# Uygulamayı Başlat
shinyApp(ui = ui, server = server)

