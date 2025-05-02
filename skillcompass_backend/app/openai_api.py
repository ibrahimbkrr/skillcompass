import openai

# OpenAI API anahtarınızı buraya ekleyin
openai.api_key = "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"

def analyze_user(user_data: dict):
    # Burada kullanıcı verisine dayalı daha gelişmiş bir prompt hazırlıyoruz
    prompt = f"""
    Aşağıdaki kullanıcı verilerini dikkatlice analiz et:

    Kullanıcı Verileri:
    {user_data}

    Cevap verirken şunlara dikkat et:

    ## 1. Eğitim Geçmişi Analizi
    - Kullanıcının eğitim durumu ve bölümüne göre hangi alanlarda uzmanlaşabileceğini, hangi sektörlerde öne çıkabileceğini açıklayın. Lisans ve sertifikalarıyla hangi mesleklerde fark yaratabileceğini belirtin.

    ## 2. Yetenek ve Beceriler Analizi
    - Kullanıcının teknik ve sosyal becerilerini detaylı şekilde analiz et. Hangi pozisyonlarda ve sektörlerde bu becerilerin öne çıkabileceğini belirleyin.
    - Yaratıcılık, analitik düşünme ve problem çözme gibi becerilerini hangi spesifik rollerle ilişkilendirebilirsiniz?

    ## 3. Çalışma Tecrübesi Analizi
    - Kullanıcının iş deneyimlerini göz önünde bulundurarak, nasıl kariyer basamağında ilerleyebileceğini açıklayın. Hangi pozisyonlardan başlayarak, hangi stratejik pozisyonlara yükselebileceğini belirtin.

    ## 4. İlgi Alanları ve Kariyer Hedefleri Analizi
    - Kullanıcının ilgi alanlarına göre **hangi sektörlerde, hangi rollerle** daha başarılı olabileceğini önerin.
    - 1 yıl, 5 yıl gibi sürelerle **somut hedefler belirleyin**. Bu hedeflerin her birini nasıl ulaşabileceğini maddelerle açıklayın.

    ## 5. Çalışma Stili ve Motivasyon Analizi
    - Kullanıcının çalışma tercihlerini ve motivasyon kaynaklarını göz önünde bulundurarak, ona uygun iş ortamını tanımlayın.
    - Çalışma saatleri, işin türü (uzaktan, ofis), şirket büyüklüğü gibi tercihler doğrultusunda en uygun iş ortamını nasıl oluşturabileceğini açıklayın.

    ## 6. Kişisel Güçlü ve Zayıf Yönler Analizi
    - Kullanıcının güçlü ve gelişmesi gereken yönlerini analiz edin ve her biri için özel gelişim tavsiyeleri verin.
    - Kullanıcının güçlü yönlerine göre, **hangi mesleklerde ve pozisyonlarda daha fazla başarı sağlayabileceğini** belirleyin.

    ## 7. Öğrenme Tarzı ve Eğitim Önerileri
    - Kullanıcının öğrenme tarzına göre **eğitim ve gelişim fırsatları önerin**. Hangi mentorluk programları, online eğitimler veya sertifikalar kullanıcının kariyer hedeflerine ulaşmasına yardımcı olabilir?
    - Özellikle dijital pazarlama veya büyüme stratejisi konularında önerilerde bulunun.

    ## 8. 1 Yıllık ve 5 Yıllık Kariyer Planı
    - **1 yıllık hedeflerde** kariyer adımları belirleyin: Hangi becerileri geliştirebilir ve hangi projelerde yer alabilir?
    - **5 yıllık hedeflerde** nasıl bir kariyer gelişimi sağlamalı, hangi pozisyonlara yükselebilir, hangi liderlik rollerini hedeflemeli?

    Cevap dilinin profesyonel, analitik ve bilgilendirici olmasını sağlayın. Yapıyı başlıklar, alt başlıklar ve madde işaretleri ile düzenli bir biçimde sunun.
    """

    # OpenAI API çağrısı yapıyoruz
    response = openai.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[
            {"role": "system", "content": "Sen profesyonel bir kariyer danışmanısın."},
            {"role": "user", "content": prompt}
        ],
        temperature=0.7,
        max_tokens=1000
    )

    # GPT'den gelen tavsiyeyi alıyoruz
    advice = response.choices[0].message.content
    return advice
