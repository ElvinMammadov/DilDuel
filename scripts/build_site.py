#!/usr/bin/env python3
"""Generates the static DilDuel website into docs/ (served by GitHub Pages).

Run from the repository root:  python3 scripts/build_site.py

Pages (English at the root, German in /de, Azerbaijani in /az):
  index.html, privacy/index.html, impressum/index.html
The account-deletion page (docs/delete-account) is hand written and is not
touched by this script.
"""
import html
import os
import shutil

OUT = "docs"
LANGS = ["en", "de", "az"]
LANG_LABEL = {"en": "EN", "de": "DE", "az": "AZ"}
LANG_NAME = {"en": "English", "de": "Deutsch", "az": "Azərbaycan"}
UPDATED = {"en": "October 14, 2026", "de": "14. Oktober 2026", "az": "14 oktyabr 2026"}

# Set to False once the app bundles its fonts instead of loading Google Fonts.
APP_LOADS_GOOGLE_FONTS = True

NAME = {"en": "Elvin Mammadov", "de": "Elvin Mammadov", "az": "Elvin Məmmədov"}
COUNTRY = {"en": "Germany", "de": "Deutschland", "az": "Almaniya"}
STREET = "Adolph-Schönfelder-Straße 65"
ZIP_CITY = "22083 Hamburg"
PHONE_DISPLAY = "+49 176 56884380"
PHONE_TEL = "+4917656884380"
EMAIL = "elvin.m@hotmail.com"
COPYRIGHT_YEAR = "2026"

BACK_ARROW = "M20 11H7.83l5.59-5.59L12 4l-8 8 8 8 1.41-1.41L7.83 13H20v-2z"

ICONS = {
    "search": "M15.5 14h-.79l-.28-.27A6.471 6.471 0 0016 9.5 6.5 6.5 0 109.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z",
    "grammar": "M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-5 14H7v-2h7v2zm3-4H7v-2h10v2zm0-4H7V7h10v2z",
    "school": "M5 13.18v4L12 21l7-3.82v-4L12 17l-7-3.82zM12 3L1 9l11 6 9-4.91V17h2V9L12 3z",
    "quiz": "M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z",
    "listen": "M12 3a9 9 0 00-9 9v7c0 1.1.9 2 2 2h4v-8H5v-1c0-3.87 3.13-7 7-7s7 3.13 7 7v1h-4v8h4c1.1 0 2-.9 2-2v-7a9 9 0 00-9-9z",
    "bookmark": "M17 3H7c-1.1 0-1.99.9-1.99 2L5 21l7-3 7 3V5c0-1.1-.9-2-2-2z",
    "cloud": "M19.35 10.04A7.49 7.49 0 0012 4C9.11 4 6.6 5.64 5.35 8.04A5.994 5.994 0 000 14c0 3.31 2.69 6 6 6h13c2.76 0 5-2.24 5-5 0-2.64-2.05-4.78-4.65-4.96z",
    "language": "M12.87 15.07l-2.54-2.51.03-.03A17.52 17.52 0 0014.07 6H17V4h-7V2H8v2H1v1.99h11.17C11.5 7.92 10.44 9.75 9 11.35 8.07 10.32 7.3 9.19 6.69 8h-2c.73 1.63 1.73 3.17 2.98 4.56l-5.09 5.02L4 19l5-5 3.11 3.11.76-2.04zM18.5 10h-2L12 22h2l1.12-3h4.75L21 22h2l-4.5-12zm-2.62 7l1.62-4.33L19.12 17h-3.24z",
}

COMMON = {
    "en": {
        "home": "Home", "privacy": "Privacy Policy", "impressum": "Legal Notice",
        "delete": "Delete account",
        "tagline": "German–Azerbaijani dictionary and vocabulary trainer",
        "lang_label": "Language", "back": "Back to home",
    },
    "de": {
        "home": "Startseite", "privacy": "Datenschutzerklärung", "impressum": "Impressum",
        "delete": "Konto löschen",
        "tagline": "Wörterbuch und Vokabeltrainer Deutsch–Aserbaidschanisch",
        "lang_label": "Sprache", "back": "Zurück zur Startseite",
    },
    "az": {
        "home": "Ana səhifə", "privacy": "Məxfilik siyasəti", "impressum": "Impressum",
        "delete": "Hesabı sil",
        "tagline": "Alman–Azərbaycan lüğəti və söz öyrənmə tətbiqi",
        "lang_label": "Dil", "back": "Ana səhifəyə qayıt",
    },
}

LANDING = {
    "en": {
        "title": "DilDuel – German–Azerbaijani dictionary and vocabulary trainer",
        "desc": "DilDuel is a German–Azerbaijani dictionary that works offline, with vocabulary training from A1 to C2, quizzes and listening tests.",
        "h1": "Learn German and Azerbaijani words, your way",
        "lead": "DilDuel is a German–Azerbaijani dictionary and vocabulary trainer. Look words up, practise them level by level and test yourself, online or offline.",
        "features_title": "What you can do with DilDuel",
        "features": [
            ("search", "Offline dictionary", "Search in both directions, German → Azerbaijani and Azerbaijani → German. The dictionary is stored on your device, so search works without an internet connection."),
            ("grammar", "Grammar at a glance", "Every word shows its article in colour (der, die, das), noun and verb forms, and example sentences."),
            ("school", "Training by level", "Flashcards from A1 to C2. Swipe through the words, mark the ones you don't know yet and jump to any word in a level. The app remembers where you stopped."),
            ("quiz", "Quizzes", "Translation quizzes with ten multiple-choice questions, a score at the end and a history of your results."),
            ("listen", "Listening tests", "Hear a German word read aloud and pick the correct answer."),
            ("bookmark", "Bookmarks and unknown words", "Save the words you want to keep and collect the ones you didn't know, so you can review them later."),
            ("cloud", "Optional sync", "Sign in with Google, Apple or email to keep your progress, bookmarks and results on every device. Without an account, everything stays on your device."),
            ("language", "Your language, your look", "The app is available in Azerbaijani and German, with light and dark themes."),
        ],
        "sources_title": "Dictionary data and levels",
        "sources": "The dictionary data is based on the German–Azerbaijani dictionary “Alman – Azərbaycanca lüğət” (A1–B2), compiled by Ramil Səfiyev. The levels A1, A2 and B1 follow the official word lists of the Goethe-Institut; B2, C1 and C2 are estimated from word frequency.",
        "callout_title": "Your data, your choice",
        "callout": "You can use DilDuel as a guest: everything stays on your device. Create an account only if you want to sync your progress. Read how we handle data, or delete your account at any time.",
    },
    "de": {
        "title": "DilDuel – Wörterbuch und Vokabeltrainer Deutsch–Aserbaidschanisch",
        "desc": "DilDuel ist ein Wörterbuch Deutsch–Aserbaidschanisch, das offline funktioniert, mit Vokabeltraining von A1 bis C2, Quiz und Hörtests.",
        "h1": "Deutsche und aserbaidschanische Wörter lernen – auf Ihre Art",
        "lead": "DilDuel ist ein Wörterbuch und Vokabeltrainer für Deutsch und Aserbaidschanisch. Wörter nachschlagen, Niveau für Niveau üben und sich testen – online oder offline.",
        "features_title": "Das können Sie mit DilDuel tun",
        "features": [
            ("search", "Offline-Wörterbuch", "Suchen Sie in beide Richtungen: Deutsch → Aserbaidschanisch und Aserbaidschanisch → Deutsch. Das Wörterbuch liegt auf Ihrem Gerät, die Suche funktioniert daher auch ohne Internet."),
            ("grammar", "Grammatik auf einen Blick", "Zu jedem Wort sehen Sie den Artikel in Farbe (der, die, das), Nomen- und Verbformen sowie Beispielsätze."),
            ("school", "Training nach Niveau", "Lernkarten von A1 bis C2. Wischen Sie durch die Wörter, markieren Sie unbekannte Wörter und springen Sie zu jedem Wort eines Niveaus. Die App merkt sich, wo Sie aufgehört haben."),
            ("quiz", "Quiz", "Übersetzungsquiz mit zehn Multiple-Choice-Fragen, Punktzahl am Ende und Verlauf Ihrer Ergebnisse."),
            ("listen", "Hörtests", "Ein deutsches Wort wird vorgelesen – wählen Sie die richtige Antwort."),
            ("bookmark", "Lesezeichen und unbekannte Wörter", "Speichern Sie Wörter, die Sie behalten möchten, und sammeln Sie unbekannte Wörter zum späteren Wiederholen."),
            ("cloud", "Optionale Synchronisierung", "Melden Sie sich mit Google, Apple oder E-Mail an, um Fortschritt, Lesezeichen und Ergebnisse auf allen Geräten zu behalten. Ohne Konto bleibt alles auf Ihrem Gerät."),
            ("language", "Ihre Sprache, Ihr Design", "Die App gibt es auf Aserbaidschanisch und Deutsch, mit hellem und dunklem Design."),
        ],
        "sources_title": "Wörterbuchdaten und Niveaus",
        "sources": "Die Wörterbuchdaten basieren auf dem Wörterbuch „Alman – Azərbaycanca lüğət“ (A1–B2), zusammengestellt von Ramil Səfiyev. Die Niveaus A1, A2 und B1 richten sich nach den offiziellen Wortlisten des Goethe-Instituts; B2, C1 und C2 werden anhand der Worthäufigkeit geschätzt.",
        "callout_title": "Ihre Daten, Ihre Entscheidung",
        "callout": "Sie können DilDuel als Gast nutzen: Alles bleibt auf Ihrem Gerät. Legen Sie nur ein Konto an, wenn Sie Ihren Fortschritt synchronisieren möchten. Lesen Sie, wie wir mit Daten umgehen, oder löschen Sie Ihr Konto jederzeit.",
    },
    "az": {
        "title": "DilDuel – Alman–Azərbaycan lüğəti və söz öyrənmə tətbiqi",
        "desc": "DilDuel oflayn işləyən alman–azərbaycan lüğətidir: A1-dən C2-yə qədər söz məşqi, testlər və dinləmə testləri.",
        "h1": "Alman və azərbaycan sözlərini öz tərzinizdə öyrənin",
        "lead": "DilDuel alman–azərbaycan lüğəti və söz öyrənmə tətbiqidir. Sözləri axtarın, səviyyə-səviyyə məşq edin və özünüzü yoxlayın – onlayn və ya oflayn.",
        "features_title": "DilDuel ilə nələr edə bilərsiniz",
        "features": [
            ("search", "Oflayn lüğət", "Hər iki istiqamətdə axtarın: alman → azərbaycan və azərbaycan → alman. Lüğət cihazınızda saxlanılır, ona görə axtarış internetsiz də işləyir."),
            ("grammar", "Qrammatika bir baxışda", "Hər sözün artikli rənglə (der, die, das), isim və fel formaları, həmçinin nümunə cümlələr göstərilir."),
            ("school", "Səviyyələr üzrə məşq", "A1-dən C2-yə qədər kartlar. Sözləri vərəqləyin, bilmədiklərinizi qeyd edin və səviyyədəki istənilən sözə keçin. Tətbiq harada qaldığınızı yadda saxlayır."),
            ("quiz", "Testlər", "On çoxseçimli sualdan ibarət tərcümə testləri, sonda xal və nəticələrinizin tarixçəsi."),
            ("listen", "Dinləmə testləri", "Alman sözü səsləndirilir, siz düzgün cavabı seçirsiniz."),
            ("bookmark", "Seçilmişlər və bilinməyən sözlər", "Saxlamaq istədiyiniz sözləri seçilmişlərə əlavə edin, bilmədiklərinizi sonra təkrar etmək üçün toplayın."),
            ("cloud", "İstəyə bağlı sinxronizasiya", "İrəliləyişinizi, seçilmişlərinizi və nəticələrinizi bütün cihazlarda saxlamaq üçün Google, Apple və ya e-poçtla daxil olun. Hesabsız hər şey yalnız cihazınızda qalır."),
            ("language", "Sizin diliniz, sizin görünüşünüz", "Tətbiq Azərbaycan və alman dillərində, açıq və tünd görünüşlə təqdim olunur."),
        ],
        "sources_title": "Lüğət məlumatları və səviyyələr",
        "sources": "Lüğət məlumatları Ramil Səfiyevin tərtib etdiyi “Alman – Azərbaycanca lüğət” (A1–B2) əsasında hazırlanmışdır. A1, A2 və B1 səviyyələri Goethe-Institut-un rəsmi söz siyahılarına əsasən müəyyən edilib; B2, C1 və C2 səviyyələri isə sözün işlənmə tezliyinə görə təxmini hesablanıb.",
        "callout_title": "Sizin məlumatlarınız, sizin seçiminiz",
        "callout": "DilDuel-dən qonaq kimi istifadə edə bilərsiniz: hər şey yalnız cihazınızda qalır. İrəliləyişinizi sinxronlaşdırmaq istəyirsinizsə, hesab yaradın. Məlumatlarla necə rəftar etdiyimizi oxuyun və ya hesabınızı istənilən vaxt silin.",
    },
}

# ── Privacy policy ──────────────────────────────────────────────────────────
# Each section is (heading, [blocks]); a block is ("p", html) or ("ul", [html]).
# Placeholders: {name} {address} {email} {phone} {delete_link}

PRIVACY = {
    "en": {
        "title": "Privacy Policy – DilDuel",
        "desc": "How DilDuel handles your personal data.",
        "h1": "Privacy Policy",
        "updated": "Last updated: {date}",
        "sections": [
            ("Who is responsible", [
                ("p", "The controller within the meaning of the General Data Protection Regulation (GDPR) is:"),
                ("address", "{name}<br>{address}<br>Phone: {phone}<br>Email: {email}"),
                ("p", "This policy applies to the DilDuel app for Android and iOS and to this website. We have not appointed a data protection officer."),
            ]),
            ("The short version", [
                ("ul", [
                    "Without an account (guest mode), your bookmarks, progress and results are stored only on your device. We do not receive them.",
                    "If you create an account, we store your account details and your learning data in the cloud so that they can be synced between your devices.",
                    "We do not use analytics or tracking tools of our own. The app shows advertising from Google AdMob, and only after your consent where the law requires it (see “Advertising”).",
                    "You can delete your account and all cloud data at any time.",
                ]),
            ]),
            ("Using the app without an account", [
                ("p", "The app stores the following data locally on your device: bookmarked words, words marked as unknown, training progress, quiz and listening results, recent searches, and your language and theme settings. This data is not transmitted to us."),
                ("p", "Storing it is technically necessary to provide the functions you request (Section 25(2) no. 2 TDDDG; Art. 6(1)(b) GDPR). You can remove it at any time by clearing the app's storage or uninstalling the app."),
            ]),
            ("Account and sign-in", [
                ("p", "If you create an account or sign in, we use Firebase Authentication, a service of Google. Depending on the method you choose, the following data is processed:"),
                ("ul", [
                    "<strong>Email and password:</strong> your email address, your display name and your password. The password is handled only by Firebase Authentication; we never see it in plain text.",
                    "<strong>Sign in with Google:</strong> the name, email address and profile picture link that Google shares with the app.",
                    "<strong>Sign in with Apple:</strong> the name and email address Apple shares with the app. If you use “Hide My Email”, we only receive Apple's relay address.",
                ]),
                ("p", "We also store a user ID that Firebase assigns to your account. Purpose: creating and managing your account and recognising you when you sign in. Legal basis: Art. 6(1)(b) GDPR (performance of the contract for the use of the app)."),
            ]),
            ("Cloud synchronisation", [
                ("p", "While you are signed in, the following data is stored in the cloud database Cloud Firestore (Google) so that you can use it on several devices: your email address, bookmarked words, words marked as unknown, training progress per level and topic, and quiz and listening results. Legal basis: Art. 6(1)(b) GDPR."),
                ("p", "If you already have data on your device when you sign in, the app asks whether you want to keep it (it is then merged into your account) or discard it."),
            ]),
            ("Technical data", [
                ("p", "When the app communicates with Firebase (sign-in and sync), Google processes technical data such as your IP address, device and connection information and timestamps to deliver the service and to ensure security. We have no influence on this processing. Legal basis: Art. 6(1)(f) GDPR (legitimate interest in a secure and functioning service)."),
            ]),
            ("Fonts", [
                ("p", "The app displays text in the typefaces Plus Jakarta Sans and Source Serif 4, which it loads from Google Fonts. When it does, your IP address is transmitted to Google servers. Legal basis: Art. 6(1)(f) GDPR (a consistent appearance of the app)."),
            ]),
            ("Speech output", [
                ("p", "The app can read German words aloud. For this it uses the speech synthesis (text-to-speech) built into your device's operating system. Depending on the voice and settings you have installed, your device's speech service may process the spoken word online. We do not receive this data and have no influence on it."),
            ]),
            ("This website", [
                ("p", "This website is hosted on GitHub Pages (GitHub, Inc., USA). When you visit it, GitHub processes technical data such as your IP address in server logs. Legal basis: Art. 6(1)(f) GDPR (legitimate interest in presenting our app securely). The information pages use no cookies, analytics, or external fonts or scripts. The account deletion page loads Google's Firebase scripts and connects to Firebase so that you can sign in and delete your data; Google then processes technical data such as your IP address (Art. 6(1)(b) and (f) GDPR)."),
            ]),
            ("Advertising (Google AdMob)", [
                ("p", "The app shows banner advertising from Google AdMob (Google Ireland Limited; Google LLC, USA). The banner appears at the bottom of some screens, such as the dictionary search and the training, test and bookmark screens."),
                ("p", "Before any ad is loaded, we ask for your consent where the law requires it, using Google's consent form (User Messaging Platform). On iOS we also ask, through Apple's tracking prompt, whether the app may track you across apps and websites of other companies. If you do not consent, advertising is limited accordingly: depending on your choice you will see non-personalised ads or no ads."),
                ("p", "When an ad is requested, Google and its advertising partners process data such as your IP address, device and advertising identifiers, information about the app and your interaction with ads, and the approximate location derived from your IP address, in order to deliver, measure and personalise ads and to prevent fraud. We do not receive this data and have no influence on this processing. Legal basis: your consent (Art. 6(1)(a) GDPR; Section 25(1) TDDDG). More information: <a href='https://policies.google.com/privacy'>Google's privacy policy</a>."),
                ("p", "You can change or withdraw your choice at any time under <em>Settings → Privacy options for ads</em> (shown where consent applies). On iOS you can also change the tracking permission in the system settings. Withdrawal does not affect the lawfulness of processing carried out until then."),
            ]),
            ("No analytics or tracking by us", [
                ("p", "The app does not use analytics or crash-reporting tools, and it does not access your location, contacts, camera or microphone. The only third-party tracking technology is the advertising described above, which depends on your consent. There is no automated decision-making or profiling by us within the meaning of Art. 22 GDPR."),
            ]),
            ("Recipients and transfers to third countries", [
                ("p", "We use these service providers, who process data on our behalf: Google Ireland Limited, Gordon House, Barrow Street, Dublin 4, Ireland (Firebase Authentication, Cloud Firestore and Google Sign-In); Apple Distribution International Ltd., Cork, Ireland (Sign in with Apple, if you use it); Google Ireland Limited and Google LLC, USA (Google AdMob advertising, with your consent); GitHub, Inc., USA (website hosting)."),
                ("p", "Data may be processed in countries outside the EU, in particular the USA. Where this happens, the transfer relies on the EU–US Data Privacy Framework adequacy decision or on standard contractual clauses."),
            ]),
            ("Storage period and deletion", [
                ("p", "Data on your device stays there until you delete it. Account and cloud data are kept until you delete your account. You can do this in the app under <em>Settings → Delete account</em>, on our {delete_link}, or by emailing us. Deletion removes your account and all cloud data immediately; routine backups at Google are overwritten on Google's regular schedule."),
            ]),
            ("Your rights", [
                ("p", "You have the right to:"),
                ("ul", [
                    "access your data (Art. 15 GDPR),",
                    "have inaccurate data corrected (Art. 16 GDPR),",
                    "have your data erased (Art. 17 GDPR),",
                    "restrict processing (Art. 18 GDPR),",
                    "receive your data in a portable format (Art. 20 GDPR),",
                    "object to processing based on legitimate interests (Art. 21 GDPR),",
                    "withdraw consent you have given, with effect for the future (Art. 7(3) GDPR).",
                ]),
                ("p", "To exercise your rights, contact us at {email}. You also have the right to lodge a complaint with a data protection authority. The authority responsible for us is: Der Hamburgische Beauftragte für Datenschutz und Informationsfreiheit, Ludwig-Erhard-Str. 22, 20459 Hamburg, Germany, <a href=\"https://datenschutz-hamburg.de\" rel=\"noopener\">datenschutz-hamburg.de</a>."),
            ]),
            ("Required data and children", [
                ("p", "You do not have to provide personal data to use the app; an account is optional. The app is not directed at children under 16, and we do not knowingly collect their personal data."),
            ]),
            ("Security", [
                ("p", "Data between the app and our service providers is transmitted encrypted (TLS)."),
            ]),
            ("Changes", [
                ("p", "We may update this policy when the app or legal requirements change. The current version is always available on this page."),
            ]),
        ],
        "delete_link_text": "account deletion page",
    },
    "de": {
        "title": "Datenschutzerklärung – DilDuel",
        "desc": "Wie DilDuel mit Ihren personenbezogenen Daten umgeht.",
        "h1": "Datenschutzerklärung",
        "updated": "Stand: {date}",
        "sections": [
            ("Verantwortlicher", [
                ("p", "Verantwortlicher im Sinne der Datenschutz-Grundverordnung (DSGVO) ist:"),
                ("address", "{name}<br>{address}<br>Telefon: {phone}<br>E-Mail: {email}"),
                ("p", "Diese Erklärung gilt für die App DilDuel für Android und iOS sowie für diese Website. Einen Datenschutzbeauftragten haben wir nicht benannt."),
            ]),
            ("Kurzfassung", [
                ("ul", [
                    "Ohne Konto (Gastmodus) werden Ihre Lesezeichen, Ihr Fortschritt und Ihre Ergebnisse ausschließlich auf Ihrem Gerät gespeichert. Wir erhalten sie nicht.",
                    "Wenn Sie ein Konto anlegen, speichern wir Ihre Kontodaten und Ihre Lerndaten in der Cloud, damit sie zwischen Ihren Geräten synchronisiert werden können.",
                    "Wir verwenden keine eigenen Analyse- oder Tracking-Werkzeuge. Die App zeigt Werbung von Google AdMob, und zwar erst nach Ihrer Einwilligung, soweit gesetzlich erforderlich (siehe „Werbung“).",
                    "Sie können Ihr Konto und alle Cloud-Daten jederzeit löschen.",
                ]),
            ]),
            ("Nutzung ohne Konto", [
                ("p", "Die App speichert folgende Daten lokal auf Ihrem Gerät: Lesezeichen, als unbekannt markierte Wörter, Trainingsfortschritt, Quiz- und Hörergebnisse, letzte Suchen sowie Ihre Sprach- und Designeinstellungen. Diese Daten werden nicht an uns übermittelt."),
                ("p", "Die Speicherung ist technisch erforderlich, um die von Ihnen gewünschten Funktionen bereitzustellen (§ 25 Abs. 2 Nr. 2 TDDDG; Art. 6 Abs. 1 lit. b DSGVO). Sie können sie jederzeit entfernen, indem Sie den App-Speicher löschen oder die App deinstallieren."),
            ]),
            ("Konto und Anmeldung", [
                ("p", "Wenn Sie ein Konto anlegen oder sich anmelden, nutzen wir Firebase Authentication, einen Dienst von Google. Je nach gewählter Methode werden folgende Daten verarbeitet:"),
                ("ul", [
                    "<strong>E-Mail und Passwort:</strong> Ihre E-Mail-Adresse, Ihr Anzeigename und Ihr Passwort. Das Passwort wird ausschließlich von Firebase Authentication verarbeitet; wir sehen es nie im Klartext.",
                    "<strong>Anmeldung mit Google:</strong> Name, E-Mail-Adresse und Link zum Profilbild, die Google an die App übermittelt.",
                    "<strong>Anmeldung mit Apple:</strong> Name und E-Mail-Adresse, die Apple an die App übermittelt. Wenn Sie „E-Mail-Adresse verbergen“ nutzen, erhalten wir nur die Relay-Adresse von Apple.",
                ]),
                ("p", "Außerdem speichern wir eine Nutzer-ID, die Firebase Ihrem Konto zuweist. Zweck: Anlegen und Verwalten Ihres Kontos und Wiedererkennung bei der Anmeldung. Rechtsgrundlage: Art. 6 Abs. 1 lit. b DSGVO (Vertragserfüllung für die Nutzung der App)."),
            ]),
            ("Cloud-Synchronisierung", [
                ("p", "Solange Sie angemeldet sind, werden folgende Daten in der Cloud-Datenbank Cloud Firestore (Google) gespeichert, damit Sie sie auf mehreren Geräten nutzen können: Ihre E-Mail-Adresse, Lesezeichen, als unbekannt markierte Wörter, Trainingsfortschritt je Niveau und Thema sowie Quiz- und Hörergebnisse. Rechtsgrundlage: Art. 6 Abs. 1 lit. b DSGVO."),
                ("p", "Wenn sich beim Anmelden bereits Daten auf Ihrem Gerät befinden, fragt die App, ob Sie diese behalten (sie werden dann in Ihr Konto übernommen) oder verwerfen möchten."),
            ]),
            ("Technische Daten", [
                ("p", "Wenn die App mit Firebase kommuniziert (Anmeldung und Synchronisierung), verarbeitet Google technische Daten wie Ihre IP-Adresse, Geräte- und Verbindungsinformationen sowie Zeitstempel, um den Dienst bereitzustellen und die Sicherheit zu gewährleisten. Auf diese Verarbeitung haben wir keinen Einfluss. Rechtsgrundlage: Art. 6 Abs. 1 lit. f DSGVO (berechtigtes Interesse an einem sicheren und funktionsfähigen Dienst)."),
            ]),
            ("Schriftarten", [
                ("p", "Die App stellt Texte in den Schriftarten Plus Jakarta Sans und Source Serif 4 dar, die sie von Google Fonts lädt. Dabei wird Ihre IP-Adresse an Server von Google übermittelt. Rechtsgrundlage: Art. 6 Abs. 1 lit. f DSGVO (einheitliches Erscheinungsbild der App)."),
            ]),
            ("Sprachausgabe", [
                ("p", "Die App kann deutsche Wörter vorlesen. Dafür nutzt sie die im Betriebssystem Ihres Geräts integrierte Sprachsynthese (Text-to-Speech). Je nach installierter Stimme und Einstellungen kann der Sprachdienst Ihres Geräts das gesprochene Wort online verarbeiten. Diese Daten erhalten wir nicht und haben darauf keinen Einfluss."),
            ]),
            ("Diese Website", [
                ("p", "Diese Website wird über GitHub Pages (GitHub, Inc., USA) gehostet. Beim Besuch verarbeitet GitHub technische Daten wie Ihre IP-Adresse in Server-Logfiles. Rechtsgrundlage: Art. 6 Abs. 1 lit. f DSGVO (berechtigtes Interesse an einer sicheren Darstellung unserer App). Die Informationsseiten verwenden keine Cookies, keine Analyse sowie keine externen Schriftarten oder Skripte. Die Seite zur Kontolöschung lädt Firebase-Skripte von Google und verbindet sich mit Firebase, damit Sie sich anmelden und Ihre Daten löschen können; dabei verarbeitet Google technische Daten wie Ihre IP-Adresse (Art. 6 Abs. 1 lit. b und f DSGVO)."),
            ]),
            ("Werbung (Google AdMob)", [
                ("p", "Die App zeigt Bannerwerbung von Google AdMob (Google Ireland Limited; Google LLC, USA). Der Banner erscheint am unteren Rand einiger Bildschirme, etwa der Wörterbuchsuche sowie der Trainings-, Test- und Lesezeichen-Ansichten."),
                ("p", "Bevor Werbung geladen wird, holen wir – soweit gesetzlich erforderlich – Ihre Einwilligung über das Einwilligungsformular von Google (User Messaging Platform) ein. Unter iOS fragen wir zusätzlich über die Tracking-Abfrage von Apple, ob die App Sie über Apps und Websites anderer Unternehmen hinweg nachverfolgen darf. Wenn Sie nicht einwilligen, wird die Werbung entsprechend eingeschränkt: Je nach Ihrer Auswahl sehen Sie nicht personalisierte Werbung oder keine Werbung."),
                ("p", "Wird Werbung angefordert, verarbeiten Google und seine Werbepartner Daten wie Ihre IP-Adresse, Geräte- und Werbekennungen, Informationen zur App und zu Ihrer Interaktion mit Anzeigen sowie den aus der IP-Adresse abgeleiteten ungefähren Standort, um Werbung auszuliefern, ihre Wirkung zu messen, sie zu personalisieren und Missbrauch zu verhindern. Wir erhalten diese Daten nicht und haben keinen Einfluss auf diese Verarbeitung. Rechtsgrundlage: Ihre Einwilligung (Art. 6 Abs. 1 lit. a DSGVO; § 25 Abs. 1 TDDDG). Weitere Informationen: <a href='https://policies.google.com/privacy'>Datenschutzerklärung von Google</a>."),
                ("p", "Sie können Ihre Entscheidung jederzeit unter <em>Einstellungen → Datenschutzoptionen für Werbung</em> ändern oder widerrufen (sichtbar, wo eine Einwilligung gilt). Unter iOS können Sie die Tracking-Erlaubnis außerdem in den Systemeinstellungen ändern. Der Widerruf berührt nicht die Rechtmäßigkeit der bis dahin erfolgten Verarbeitung."),
            ]),
            ("Keine Analyse oder Tracking durch uns", [
                ("p", "Die App verwendet keine Analyse- oder Absturzberichts-Werkzeuge und greift nicht auf Standort, Kontakte, Kamera oder Mikrofon zu. Die einzige Tracking-Technik von Dritten ist die oben beschriebene Werbung, die von Ihrer Einwilligung abhängt. Eine automatisierte Entscheidungsfindung einschließlich Profiling durch uns im Sinne von Art. 22 DSGVO findet nicht statt."),
            ]),
            ("Empfänger und Übermittlung in Drittländer", [
                ("p", "Wir setzen folgende Dienstleister ein, die in unserem Auftrag Daten verarbeiten: Google Ireland Limited, Gordon House, Barrow Street, Dublin 4, Irland (Firebase Authentication, Cloud Firestore und Google-Anmeldung); Apple Distribution International Ltd., Cork, Irland (Anmeldung mit Apple, falls Sie sie nutzen); Google Ireland Limited und Google LLC, USA (Werbung über Google AdMob, mit Ihrer Einwilligung); GitHub, Inc., USA (Hosting der Website)."),
                ("p", "Daten können in Ländern außerhalb der EU verarbeitet werden, insbesondere in den USA. In diesem Fall stützt sich die Übermittlung auf den Angemessenheitsbeschluss zum EU-US Data Privacy Framework oder auf Standardvertragsklauseln."),
            ]),
            ("Speicherdauer und Löschung", [
                ("p", "Daten auf Ihrem Gerät bleiben dort, bis Sie sie löschen. Konto- und Cloud-Daten speichern wir, bis Sie Ihr Konto löschen. Das geht in der App unter <em>Einstellungen → Konto löschen</em>, auf unserer {delete_link} oder per E-Mail an uns. Bei der Löschung werden Ihr Konto und alle Cloud-Daten sofort entfernt; routinemäßige Backups bei Google werden im regulären Turnus von Google überschrieben."),
            ]),
            ("Ihre Rechte", [
                ("p", "Sie haben das Recht auf:"),
                ("ul", [
                    "Auskunft über Ihre Daten (Art. 15 DSGVO),",
                    "Berichtigung unrichtiger Daten (Art. 16 DSGVO),",
                    "Löschung Ihrer Daten (Art. 17 DSGVO),",
                    "Einschränkung der Verarbeitung (Art. 18 DSGVO),",
                    "Datenübertragbarkeit (Art. 20 DSGVO),",
                    "Widerspruch gegen Verarbeitung auf Grundlage berechtigter Interessen (Art. 21 DSGVO),",
                    "Widerruf erteilter Einwilligungen mit Wirkung für die Zukunft (Art. 7 Abs. 3 DSGVO).",
                ]),
                ("p", "Um Ihre Rechte auszuüben, wenden Sie sich an {email}. Außerdem haben Sie das Recht, sich bei einer Datenschutzaufsichtsbehörde zu beschweren. Für uns zuständig ist: Der Hamburgische Beauftragte für Datenschutz und Informationsfreiheit, Ludwig-Erhard-Str. 22, 20459 Hamburg, <a href=\"https://datenschutz-hamburg.de\" rel=\"noopener\">datenschutz-hamburg.de</a>."),
            ]),
            ("Erforderliche Daten und Kinder", [
                ("p", "Für die Nutzung der App müssen Sie keine personenbezogenen Daten angeben; ein Konto ist optional. Die App richtet sich nicht an Kinder unter 16 Jahren, und wir erheben wissentlich keine personenbezogenen Daten von ihnen."),
            ]),
            ("Sicherheit", [
                ("p", "Daten zwischen der App und unseren Dienstleistern werden verschlüsselt (TLS) übertragen."),
            ]),
            ("Änderungen", [
                ("p", "Wir können diese Erklärung anpassen, wenn sich die App oder rechtliche Anforderungen ändern. Die aktuelle Fassung finden Sie stets auf dieser Seite."),
            ]),
        ],
        "delete_link_text": "Seite zur Kontolöschung",
    },
    "az": {
        "title": "Məxfilik siyasəti – DilDuel",
        "desc": "DilDuel şəxsi məlumatlarınızla necə rəftar edir.",
        "h1": "Məxfilik siyasəti",
        "updated": "Son yenilənmə: {date}",
        "sections": [
            ("Məsul şəxs", [
                ("p", "Ümumi Məlumatların Mühafizəsi Qaydası (GDPR) baxımından məlumatlara cavabdeh şəxs:"),
                ("address", "{name}<br>{address}<br>Telefon: {phone}<br>E-poçt: {email}"),
                ("p", "Bu siyasət Android və iOS üçün DilDuel tətbiqinə və bu veb saytına şamil olunur. Məlumatların mühafizəsi üzrə məsul şəxs təyin etməmişik."),
            ]),
            ("Qısa xülasə", [
                ("ul", [
                    "Hesabsız (qonaq rejimi) seçilmişləriniz, irəliləyişiniz və nəticələriniz yalnız cihazınızda saxlanılır. Biz onları almırıq.",
                    "Hesab yaratsanız, hesab məlumatlarınızı və öyrənmə məlumatlarınızı cihazlarınız arasında sinxronlaşdırmaq üçün bulud sistemində saxlayırıq.",
                    "Özümüzün analitika və ya izləmə alətlərindən istifadə etmirik. Tətbiq Google AdMob reklamları göstərir və qanunun tələb etdiyi hallarda yalnız razılığınızdan sonra (bax: „Reklam“).",
                    "Hesabınızı və bütün bulud məlumatlarını istənilən vaxt silə bilərsiniz.",
                ]),
            ]),
            ("Hesabsız istifadə", [
                ("p", "Tətbiq cihazınızda aşağıdakı məlumatları yerli olaraq saxlayır: seçilmiş sözlər, bilinməyən kimi qeyd olunan sözlər, məşq irəliləyişi, test və dinləmə nəticələri, son axtarışlar, həmçinin dil və görünüş ayarlarınız. Bu məlumatlar bizə göndərilmir."),
                ("p", "Saxlanma sizin istədiyiniz funksiyaları təmin etmək üçün texniki cəhətdən zəruridir (TDDDG § 25 maddə 2 bənd 2; GDPR maddə 6(1)(b)). Tətbiqin yaddaşını təmizləməklə və ya tətbiqi silməklə onları istənilən vaxt aradan qaldıra bilərsiniz."),
            ]),
            ("Hesab və giriş", [
                ("p", "Hesab yaratdıqda və ya daxil olduqda Google xidməti olan Firebase Authentication-dan istifadə edirik. Seçdiyiniz üsuldan asılı olaraq aşağıdakı məlumatlar emal olunur:"),
                ("ul", [
                    "<strong>E-poçt və şifrə:</strong> e-poçt ünvanınız, görünən adınız və şifrəniz. Şifrə yalnız Firebase Authentication tərəfindən emal olunur; biz onu heç vaxt açıq şəkildə görmürük.",
                    "<strong>Google ilə giriş:</strong> Google-un tətbiqə ötürdüyü ad, e-poçt ünvanı və profil şəklinin linki.",
                    "<strong>Apple ilə giriş:</strong> Apple-ın tətbiqə ötürdüyü ad və e-poçt ünvanı. “E-poçtumu gizlət” seçimindən istifadə etsəniz, yalnız Apple-ın relay ünvanını alırıq.",
                ]),
                ("p", "Bundan əlavə, Firebase-in hesabınıza təyin etdiyi istifadəçi identifikatorunu saxlayırıq. Məqsəd: hesabınızı yaratmaq və idarə etmək, girişdə sizi tanımaq. Hüquqi əsas: GDPR maddə 6(1)(b) (tətbiqdən istifadə üzrə müqavilənin icrası)."),
            ]),
            ("Bulud sinxronizasiyası", [
                ("p", "Daxil olduğunuz müddətdə aşağıdakı məlumatlar bir neçə cihazda istifadə edə bilməyiniz üçün Cloud Firestore (Google) bulud verilənlər bazasında saxlanılır: e-poçt ünvanınız, seçilmiş sözlər, bilinməyən kimi qeyd olunan sözlər, səviyyələr və mövzular üzrə məşq irəliləyişi, test və dinləmə nəticələri. Hüquqi əsas: GDPR maddə 6(1)(b)."),
                ("p", "Daxil olarkən cihazınızda artıq məlumat varsa, tətbiq onları saxlamaq (hesabınıza birləşdirilir) və ya ləğv etmək istədiyinizi soruşur."),
            ]),
            ("Texniki məlumatlar", [
                ("p", "Tətbiq Firebase ilə əlaqə qurduqda (giriş və sinxronizasiya) Google xidməti təmin etmək və təhlükəsizliyi qorumaq üçün IP ünvanınız, cihaz və bağlantı məlumatları, vaxt damğaları kimi texniki məlumatları emal edir. Bu emala təsir imkanımız yoxdur. Hüquqi əsas: GDPR maddə 6(1)(f) (təhlükəsiz və işlək xidmətdə qanuni maraq)."),
            ]),
            ("Şriftlər", [
                ("p", "Tətbiq mətnləri Plus Jakarta Sans və Source Serif 4 şriftləri ilə göstərir və onları Google Fonts-dan yükləyir. Bu zaman IP ünvanınız Google serverlərinə ötürülür. Hüquqi əsas: GDPR maddə 6(1)(f) (tətbiqin vahid görünüşü)."),
            ]),
            ("Səsləndirmə", [
                ("p", "Tətbiq alman sözlərini səsləndirə bilir. Bunun üçün cihazınızın əməliyyat sisteminə daxil edilmiş nitq sintezindən (text-to-speech) istifadə edir. Quraşdırdığınız səsdən və ayarlardan asılı olaraq cihazınızın nitq xidməti səsləndirilən sözü onlayn emal edə bilər. Bu məlumatları biz almırıq və buna təsir imkanımız yoxdur."),
            ]),
            ("Bu veb sayt", [
                ("p", "Bu veb sayt GitHub Pages-də (GitHub, Inc., ABŞ) yerləşdirilir. Ziyarət zamanı GitHub server qeydlərində IP ünvanınız kimi texniki məlumatları emal edir. Hüquqi əsas: GDPR maddə 6(1)(f) (tətbiqimizin təhlükəsiz təqdimatında qanuni maraq). Məlumat səhifələri kuki, analitika, xarici şrift və ya skriptlərdən istifadə etmir. Hesabın silinməsi səhifəsi Google-un Firebase skriptlərini yükləyir və daxil olub məlumatlarınızı silə bilməyiniz üçün Firebase ilə əlaqə qurur; bu zaman Google IP ünvanınız kimi texniki məlumatları emal edir (GDPR maddə 6(1)(b) və (f))."),
            ]),
            ("Reklam (Google AdMob)", [
                ("p", "Tətbiq Google AdMob-dan (Google Ireland Limited; Google LLC, ABŞ) banner reklamları göstərir. Banner bəzi ekranların aşağı hissəsində, məsələn lüğət axtarışında, məşq, test və seçilmişlər ekranlarında görünür."),
                ("p", "Reklam yüklənməzdən əvvəl qanunun tələb etdiyi hallarda Google-un razılıq formu (User Messaging Platform) vasitəsilə razılığınızı alırıq. iOS-da əlavə olaraq Apple-ın izləmə sorğusu ilə tətbiqin sizi digər şirkətlərin tətbiq və veb saytları üzrə izləyə bilib-bilməməsini soruşuruq. Razılıq verməsəniz, reklam buna uyğun məhdudlaşdırılır: seçiminizdən asılı olaraq fərdiləşdirilməmiş reklam görəcəksiniz və ya heç reklam görməyəcəksiniz."),
                ("p", "Reklam sorğusu göndərildikdə Google və onun reklam tərəfdaşları reklamı çatdırmaq, effektivliyini ölçmək, fərdiləşdirmək və sui-istifadənin qarşısını almaq üçün IP ünvanınız, cihaz və reklam identifikatorları, tətbiq və reklamla qarşılıqlı əlaqəniz haqqında məlumatlar, həmçinin IP ünvanından çıxarılan təxmini məkan kimi məlumatları emal edir. Bu məlumatları biz almırıq və bu emala təsir göstərmirik. Hüquqi əsas: razılığınız (GDPR maddə 6(1)(a); TDDDG § 25(1)). Əlavə məlumat: <a href='https://policies.google.com/privacy'>Google-un məxfilik siyasəti</a>."),
                ("p", "Seçiminizi istənilən vaxt <em>Parametrlər → Reklam məxfiliyi seçimləri</em> bölməsində dəyişə və ya geri ala bilərsiniz (razılıq tətbiq olunan yerlərdə göstərilir). iOS-da izləmə icazəsini sistem parametrlərində də dəyişə bilərsiniz. Geri alma, o vaxta qədər aparılmış emalın qanuniliyinə təsir etmir."),
            ]),
            ("Bizdən analitika və izləmə yoxdur", [
                ("p", "Tətbiq analitika və ya xəta hesabatı alətlərindən istifadə etmir, məkanınıza, kontaktlarınıza, kameranıza və ya mikrofonunuza giriş əldə etmir. Üçüncü tərəfin yeganə izləmə texnologiyası yuxarıda təsvir olunan, razılığınızdan asılı olan reklamdır. GDPR maddə 22 mənasında bizim tərəfimizdən avtomatlaşdırılmış qərar qəbulu və ya profilləşdirmə həyata keçirilmir."),
            ]),
            ("Alıcılar və üçüncü ölkələrə ötürmə", [
                ("p", "Bizim adımızdan məlumatları emal edən aşağıdakı xidmət təminatçılarından istifadə edirik: Google Ireland Limited, Gordon House, Barrow Street, Dublin 4, İrlandiya (Firebase Authentication, Cloud Firestore və Google ilə giriş); Apple Distribution International Ltd., Cork, İrlandiya (istifadə etsəniz, Apple ilə giriş); Google Ireland Limited və Google LLC, ABŞ (razılığınızla Google AdMob reklamı); GitHub, Inc., ABŞ (veb saytın yerləşdirilməsi)."),
                ("p", "Məlumatlar Aİ-dən kənar ölkələrdə, xüsusilə ABŞ-da emal oluna bilər. Bu halda ötürmə Aİ–ABŞ Məlumat Məxfiliyi Çərçivəsi üzrə adekvatlıq qərarına və ya standart müqavilə bəndlərinə əsaslanır."),
            ]),
            ("Saxlanma müddəti və silinmə", [
                ("p", "Cihazınızdakı məlumatlar siz silənə qədər orada qalır. Hesab və bulud məlumatlarını hesabınızı silənə qədər saxlayırıq. Bunu tətbiqdə <em>Parametrlər → Hesabı sil</em> bölməsində, {delete_link} vasitəsilə və ya bizə e-poçt göndərməklə edə bilərsiniz. Silinmə zamanı hesabınız və bütün bulud məlumatları dərhal silinir; Google-dakı müntəzəm ehtiyat nüsxələr Google-un adi qrafiki ilə üzərinə yazılır."),
            ]),
            ("Hüquqlarınız", [
                ("p", "Aşağıdakı hüquqlara maliksiniz:"),
                ("ul", [
                    "məlumatlarınıza giriş (GDPR maddə 15),",
                    "yanlış məlumatların düzəldilməsi (GDPR maddə 16),",
                    "məlumatlarınızın silinməsi (GDPR maddə 17),",
                    "emalın məhdudlaşdırılması (GDPR maddə 18),",
                    "məlumatların daşınması (GDPR maddə 20),",
                    "qanuni maraqlara əsaslanan emala etiraz (GDPR maddə 21),",
                    "verdiyiniz razılığı gələcək üçün geri götürmək (GDPR maddə 7(3)).",
                ]),
                ("p", "Hüquqlarınızdan istifadə üçün {email} ünvanına yazın. Həmçinin məlumatların mühafizəsi üzrə nəzarət orqanına şikayət etmək hüququnuz var. Bizim üçün məsul orqan: Der Hamburgische Beauftragte für Datenschutz und Informationsfreiheit, Ludwig-Erhard-Str. 22, 20459 Hamburg, Almaniya, <a href=\"https://datenschutz-hamburg.de\" rel=\"noopener\">datenschutz-hamburg.de</a>."),
            ]),
            ("Tələb olunan məlumatlar və uşaqlar", [
                ("p", "Tətbiqdən istifadə üçün şəxsi məlumat verməyiniz tələb olunmur; hesab könüllüdür. Tətbiq 16 yaşdan kiçik uşaqlara yönəlməyib və onların şəxsi məlumatlarını bilərəkdən toplamırıq."),
            ]),
            ("Təhlükəsizlik", [
                ("p", "Tətbiq ilə xidmət təminatçılarımız arasında məlumatlar şifrələnmiş (TLS) şəkildə ötürülür."),
            ]),
            ("Dəyişikliklər", [
                ("p", "Tətbiq və ya hüquqi tələblər dəyişdikdə bu siyasəti yeniləyə bilərik. Cari versiya həmişə bu səhifədə əlçatandır."),
            ]),
        ],
        "delete_link_text": "hesabın silinməsi səhifəsi",
    },
}

# ── Impressum ───────────────────────────────────────────────────────────────

IMPRESSUM = {
    "en": {
        "title": "Legal Notice (Impressum) – DilDuel",
        "desc": "Provider information for DilDuel under German law.",
        "h1": "Legal Notice (Impressum)",
        "note": "This notice follows German law (§ 5 DDG). The German version is the legally binding one.",
        "sections": [
            ("Information according to § 5 DDG", [("address", "{name}<br>{street}<br>{zip_city}<br>{country}")]),
            ("Contact", [("address", "Phone: {phone}<br>Email: {email}")]),
            ("Responsible for content (§ 18(2) MStV)", [("address", "{name}<br>{street}<br>{zip_city}<br>{country}")]),
            ("Consumer dispute resolution", [("p", "We are neither willing nor obliged to take part in dispute resolution proceedings before a consumer arbitration board.")]),
            ("Liability for content and links", [
                ("p", "As a service provider we are responsible for our own content under general law. We are not obliged to monitor transmitted or stored third-party information or to investigate circumstances that indicate unlawful activity."),
                ("p", "Our offer may contain links to external websites. We have no influence on their content and therefore accept no liability for it. The respective provider is always responsible for the linked pages."),
            ]),
        ],
    },
    "de": {
        "title": "Impressum – DilDuel",
        "desc": "Anbieterkennzeichnung für DilDuel nach deutschem Recht.",
        "h1": "Impressum",
        "note": "",
        "sections": [
            ("Angaben gemäß § 5 DDG", [("address", "{name}<br>{street}<br>{zip_city}<br>{country}")]),
            ("Kontakt", [("address", "Telefon: {phone}<br>E-Mail: {email}")]),
            ("Verantwortlich für den Inhalt nach § 18 Abs. 2 MStV", [("address", "{name}<br>{street}<br>{zip_city}<br>{country}")]),
            ("Verbraucherstreitbeilegung", [("p", "Wir sind weder bereit noch verpflichtet, an Streitbeilegungsverfahren vor einer Verbraucherschlichtungsstelle teilzunehmen.")]),
            ("Haftung für Inhalte und Links", [
                ("p", "Als Diensteanbieter sind wir für eigene Inhalte nach den allgemeinen Gesetzen verantwortlich. Wir sind jedoch nicht verpflichtet, übermittelte oder gespeicherte fremde Informationen zu überwachen oder nach Umständen zu forschen, die auf eine rechtswidrige Tätigkeit hinweisen."),
                ("p", "Unser Angebot kann Links zu externen Websites enthalten. Auf deren Inhalte haben wir keinen Einfluss und übernehmen dafür daher keine Gewähr. Für die verlinkten Seiten ist stets der jeweilige Anbieter verantwortlich."),
            ]),
        ],
    },
    "az": {
        "title": "Impressum – DilDuel",
        "desc": "Alman qanunvericiliyinə uyğun provayder məlumatı.",
        "h1": "Impressum (hüquqi məlumat)",
        "note": "Bu məlumat Alman qanunvericiliyinə (DDG § 5) uyğundur. Hüquqi qüvvəyə malik olan alman versiyasıdır.",
        "sections": [
            ("DDG § 5-ə uyğun məlumat", [("address", "{name}<br>{street}<br>{zip_city}<br>{country}")]),
            ("Əlaqə", [("address", "Telefon: {phone}<br>E-poçt: {email}")]),
            ("Məzmuna cavabdeh şəxs (MStV § 18 maddə 2)", [("address", "{name}<br>{street}<br>{zip_city}<br>{country}")]),
            ("İstehlakçı mübahisələrinin həlli", [("p", "İstehlakçı mübahisələri üzrə arbitraj orqanı qarşısında mübahisənin həlli prosedurlarında iştirak etməyə nə hazırıq, nə də borcluyuq.")]),
            ("Məzmun və linklərə görə məsuliyyət", [
                ("p", "Xidmət təminatçısı kimi öz məzmunumuza görə ümumi qanunlar üzrə məsuliyyət daşıyırıq. Ötürülən və ya saxlanılan üçüncü tərəf məlumatlarına nəzarət etmək və ya qanunsuz fəaliyyətə işarə edən halları araşdırmaq öhdəliyimiz yoxdur."),
                ("p", "Təklifimiz xarici veb saytlara linklər ehtiva edə bilər. Onların məzmununa təsir imkanımız yoxdur və buna görə məsuliyyət daşımırıq. Linklənmiş səhifələrə görə həmişə müvafiq provayder cavabdehdir."),
            ]),
        ],
    },
}

SECTION_PAGES = ("privacy", "impressum")


def base_dir(lang):
    return OUT if lang == "en" else os.path.join(OUT, lang)


def page_dir(lang, slug):
    return base_dir(lang) if slug == "" else os.path.join(base_dir(lang), slug)


def rel(from_dir, to_dir):
    path = os.path.relpath(to_dir, from_dir)
    return "./" if path == "." else path.replace(os.sep, "/") + "/"


def esc(text):
    return html.escape(text, quote=True)


def fill(template, lang, from_dir):
    address = f"{STREET}, {ZIP_CITY}, {COUNTRY[lang]}"
    delete_url = rel(from_dir, os.path.join(OUT, "delete-account")) + f"?lang={lang}"
    delete_link = f'<a href="{delete_url}">{PRIVACY[lang]["delete_link_text"]}</a>'
    return (template
            .replace("{name}", esc(NAME[lang]))
            .replace("{address}", esc(address))
            .replace("{street}", esc(STREET))
            .replace("{zip_city}", esc(ZIP_CITY))
            .replace("{country}", esc(COUNTRY[lang]))
            .replace("{phone}", f'<a href="tel:{PHONE_TEL}">{PHONE_DISPLAY}</a>')
            .replace("{email}", f'<a href="mailto:{EMAIL}">{EMAIL}</a>')
            .replace("{delete_link}", delete_link)
            .replace("{date}", UPDATED[lang]))


def render_blocks(blocks, lang, from_dir):
    out = []
    for kind, content in blocks:
        if kind == "p":
            out.append(f"<p>{fill(content, lang, from_dir)}</p>")
        elif kind == "address":
            out.append(f"<address>{fill(content, lang, from_dir)}</address>")
        else:
            items = "".join(f"<li>{fill(i, lang, from_dir)}</li>" for i in content)
            out.append(f"<ul>{items}</ul>")
    return "\n".join(out)


def switcher_link(here, slug, lang, current):
    aria = ' aria-current="true"' if current else ""
    return (f'<a href="{rel(here, page_dir(lang, slug))}" hreflang="{lang}" '
            f'lang="{lang}" data-lang="{lang}"{aria} title="{LANG_NAME[lang]}">'
            f"{LANG_LABEL[lang]}</a>")


def layout(lang, slug, title, desc, body):
    here = page_dir(lang, slug)
    assets = rel(here, os.path.join(OUT, "assets")).rstrip("/")
    common = COMMON[lang]
    alternates = "\n".join(
        f'<link rel="alternate" hreflang="{l}" href="{rel(here, page_dir(l, slug))}">'
        for l in LANGS)
    switcher = "".join(
        switcher_link(here, slug, l, current=(l == lang)) for l in LANGS)
    footer_links = "".join(
        f'<a href="{href}">{label}</a>' for href, label in [
            (rel(here, page_dir(lang, "")), common["home"]),
            (rel(here, page_dir(lang, "privacy")), common["privacy"]),
            (rel(here, page_dir(lang, "impressum")), common["impressum"]),
            (rel(here, os.path.join(OUT, "delete-account")) + f"?lang={lang}", common["delete"]),
        ])
    return f"""<!doctype html>
<html lang="{lang}">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{esc(title)}</title>
<meta name="description" content="{esc(desc)}">
<link rel="icon" href="{assets}/icon.png">
<link rel="stylesheet" href="{assets}/site.css">
{alternates}
</head>
<body>
<header class="site-header">
  <div class="wrap">
    <a class="brand" href="{rel(here, page_dir(lang, ""))}"><img src="{assets}/icon.png" alt="" width="32" height="32"><span>DilDuel</span></a>
    <nav class="lang" aria-label="{esc(common["lang_label"])}">{switcher}</nav>
  </div>
</header>
{body}
<footer>
  <div class="wrap">
    <nav>{footer_links}</nav>
    <small>© {COPYRIGHT_YEAR} {esc(NAME[lang])} · {esc(common["tagline"])}</small>
  </div>
</footer>
<script>
  document.querySelectorAll("[data-lang]").forEach(function (a) {{
    a.addEventListener("click", function () {{
      try {{ localStorage.setItem("lang", a.dataset.lang); }} catch (e) {{}}
    }});
  }});
</script>
</body>
</html>
"""


def landing_body(lang):
    here = page_dir(lang, "")
    t = LANDING[lang]
    common = COMMON[lang]
    assets = rel(here, os.path.join(OUT, "assets")).rstrip("/")
    cards = "".join(
        f'<div class="card"><span class="icon" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="{ICONS[icon]}"/></svg></span>'
        f"<h3>{esc(title)}</h3><p>{esc(text)}</p></div>"
        for icon, title, text in t["features"])
    delete_url = rel(here, os.path.join(OUT, "delete-account")) + f"?lang={lang}"
    return f"""<section class="hero">
  <div class="wrap">
    <img class="hero-icon" src="{assets}/icon.png" alt="DilDuel" width="96" height="96">
    <h1>{esc(t["h1"])}</h1>
    <p>{esc(t["lead"])}</p>
    <div class="actions">
      <a class="btn primary" href="{rel(here, page_dir(lang, "privacy"))}">{esc(common["privacy"])}</a>
      <a class="btn" href="{rel(here, page_dir(lang, "impressum"))}">{esc(common["impressum"])}</a>
    </div>
  </div>
</section>
<main class="wrap">
  <section>
    <h2>{esc(t["features_title"])}</h2>
    <div class="grid">{cards}</div>
  </section>
  <section>
    <div class="card">
      <h2>{esc(t["sources_title"])}</h2>
      <p>{esc(t["sources"])}</p>
    </div>
  </section>
  <section>
    <div class="card callout">
      <h2>{esc(t["callout_title"])}</h2>
      <p>{esc(t["callout"])}</p>
      <div class="actions">
        <a class="btn primary" href="{rel(here, page_dir(lang, "privacy"))}">{esc(common["privacy"])}</a>
        <a class="btn" href="{delete_url}">{esc(common["delete"])}</a>
      </div>
    </div>
  </section>
</main>"""


def prose_body(lang, slug, data, numbered):
    here = page_dir(lang, slug)
    sections = data["sections"]
    if slug == "privacy" and not APP_LOADS_GOOGLE_FONTS:
        fonts_heading = PRIVACY[lang]["sections"][6][0]
        sections = [s for s in sections if s[0] != fonts_heading]
    parts = []
    for index, (heading, blocks) in enumerate(sections, start=1):
        label = f"{index}. {heading}" if numbered else heading
        parts.append(f"<h2>{esc(label)}</h2>\n{render_blocks(blocks, lang, here)}")
    meta = ""
    if data.get("updated"):
        meta = f'<p class="meta">{esc(data["updated"].replace("{date}", UPDATED[lang]))}</p>'
    if data.get("note"):
        meta += f'<p class="meta">{esc(data["note"])}</p>'
    back = (f'<a class="back" href="{rel(here, page_dir(lang, ""))}">'
            f'<svg viewBox="0 0 24 24" aria-hidden="true"><path d="{BACK_ARROW}"/></svg>'
            f'{esc(COMMON[lang]["back"])}</a>')
    return (f'<main class="wrap prose">\n{back}\n<h1>{esc(data["h1"])}</h1>\n{meta}\n'
            + "\n".join(parts) + "\n</main>")


def write(path, content):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as handle:
        handle.write(content)


def main():
    for lang in LANGS:
        shutil.rmtree(os.path.join(base_dir(lang), "privacy"), ignore_errors=True)
        shutil.rmtree(os.path.join(base_dir(lang), "impressum"), ignore_errors=True)
        landing = LANDING[lang]
        write(os.path.join(page_dir(lang, ""), "index.html"),
              layout(lang, "", landing["title"], landing["desc"], landing_body(lang)))
        for slug, data, numbered in (("privacy", PRIVACY[lang], True),
                                     ("impressum", IMPRESSUM[lang], False)):
            write(os.path.join(page_dir(lang, slug), "index.html"),
                  layout(lang, slug, data["title"], data["desc"],
                         prose_body(lang, slug, data, numbered)))
    print("Site generated in", OUT)


if __name__ == "__main__":
    main()
