"""
Assigns CEFR levels (A1 / A2 / B1 / B2) to every entry in
Dictionary_Last.xlsx and writes four separate output files.

Classification strategy:
  1. Strip leading article tokens (der/die/das/sich).
  2. Match the bare lemma against embedded Goethe-Institut word lists.
  3. German compound-word prefix matching: if the first syllable-cluster of a
     compound word is an A1 root, the compound is A2; if it is an A2 root,
     the compound is B1.
  4. Words not found in A1/A2/B1 → classified as B2.

Usage:
    python3 scripts/create_level_excel.py
"""

import os
import re
import openpyxl
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
from openpyxl.utils import get_column_letter

# ---------------------------------------------------------------------------
# Goethe-Institut CEFR vocabulary lists (lemma / base forms, lowercase)
# ---------------------------------------------------------------------------

A1_WORDS = {
    # Pronouns & determiners
    "ich", "du", "er", "sie", "es", "wir", "ihr", "man",
    "mich", "dich", "ihn", "uns", "euch", "sich",
    "mir", "dir", "ihm", "ihnen",
    "mein", "dein", "sein", "unser", "euer",
    "der", "die", "das", "ein", "eine", "kein", "keine",
    "dieser", "diese", "dieses", "jeder", "jede", "jedes",
    # Core verbs
    "sein", "haben", "werden", "heißen", "kommen", "gehen", "fahren",
    "machen", "sagen", "sprechen", "verstehen", "schreiben", "lesen",
    "hören", "sehen", "kaufen", "essen", "trinken", "wohnen", "leben",
    "arbeiten", "lernen", "spielen", "fragen", "antworten", "rufen",
    "nehmen", "geben", "bringen", "holen", "zeigen", "suchen", "finden",
    "kennen", "wissen", "denken", "glauben", "helfen", "brauchen",
    "mögen", "möchten", "können", "müssen", "sollen", "wollen", "dürfen",
    "stehen", "sitzen", "liegen", "legen", "stellen", "setzen",
    "öffnen", "schließen", "anfangen", "aufhören", "aufmachen", "zumachen",
    "schlafen", "aufstehen", "aufwachen", "kochen", "waschen", "putzen",
    "einkaufen", "bezahlen", "kosten", "passen", "tragen", "gefallen",
    "reden", "warten", "besuchen", "reisen", "studieren", "tanzen",
    "singen", "schwimmen", "laufen", "ankommen", "abfahren",
    "starten", "fliegen", "buchstabieren", "wiederholen", "erklären",
    "notieren", "feiern", "lieben", "heiraten", "treffen",
    "mitnehmen", "mitbringen", "anrufen", "einladen",
    "telefonieren", "fotografieren", "zeichnen",
    # Nouns – people & family
    "mann", "frau", "kind", "familie", "mutter", "vater", "eltern",
    "bruder", "schwester", "sohn", "tochter", "oma", "opa",
    "freund", "freundin", "kollege", "kollegin",
    "lehrer", "lehrerin", "schüler", "schülerin",
    "arzt", "ärztin", "student", "studentin",
    "herr", "dame", "junge", "mädchen", "baby", "mensch",
    # Identity / personal data
    "name", "vorname", "nachname", "familienname", "adresse",
    "telefon", "telefonnummer", "handy", "handynummer",
    "e-mail", "alter", "geburtstag", "geburtsdatum",
    "nationalität", "land", "heimatland", "herkunft",
    # Places & infrastructure
    "stadt", "straße", "haus", "wohnung", "zimmer", "küche",
    "bad", "badezimmer", "tür", "fenster", "treppe", "keller",
    "bahnhof", "flughafen", "hotel", "restaurant", "café",
    "supermarkt", "laden", "geschäft", "markt", "krankenhaus",
    "schule", "universität", "büro", "kino", "theater",
    "park", "platz", "weg", "dorf", "hauptstadt",
    # Furniture & objects
    "tisch", "stuhl", "bett", "schrank", "lampe",
    "buch", "heft", "stift", "tasche", "schlüssel",
    "computer", "internet", "fernseher", "radio",
    "foto", "bild", "brief", "zeitung", "zeitschrift",
    # Transport
    "auto", "bus", "bahn", "zug", "flugzeug", "fahrrad",
    "taxi", "straßenbahn", "ticket", "fahrkarte",
    # Food & drink
    "essen", "trinken", "wasser", "kaffee", "tee", "milch", "saft",
    "brot", "brötchen", "obst", "gemüse", "fleisch", "fisch",
    "suppe", "salat", "kuchen", "eis", "schokolade",
    "frühstück", "mittagessen", "abendessen",
    "butter", "käse", "ei", "joghurt",
    "apfel", "banane", "orange",
    # Time
    "uhr", "zeit", "tag", "nacht", "morgen", "mittag", "abend",
    "woche", "monat", "jahr", "stunde", "minute", "sekunde",
    "montag", "dienstag", "mittwoch", "donnerstag", "freitag",
    "samstag", "sonntag",
    "januar", "februar", "märz", "april", "mai", "juni",
    "juli", "august", "september", "oktober", "november", "dezember",
    "frühling", "sommer", "herbst", "winter",
    "heute", "gestern", "übermorgen", "vorgestern",
    "früh", "spät", "abends", "morgens", "mittags",
    # Weather
    "wetter", "sonne", "regen", "schnee", "wind", "wolke",
    "warm", "kalt", "heiß", "kühl",
    # Numbers & ordinals
    "null", "eins", "zwei", "drei", "vier", "fünf",
    "sechs", "sieben", "acht", "neun", "zehn",
    "elf", "zwölf", "dreizehn", "vierzehn", "fünfzehn",
    "sechzehn", "siebzehn", "achtzehn", "neunzehn",
    "zwanzig", "dreißig", "vierzig", "fünfzig",
    "sechzig", "siebzig", "achtzig", "neunzig",
    "hundert", "tausend", "million",
    "erste", "zweite", "dritte", "vierte", "fünfte",
    "sechste", "siebte", "achte", "neunte", "zehnte",
    # Core adjectives
    "gut", "schlecht", "schön", "groß", "klein",
    "alt", "jung", "neu", "billig", "teuer",
    "richtig", "falsch", "leicht", "schwer",
    "krank", "gesund", "müde", "hungrig", "durstig",
    "interessant", "langweilig", "lustig", "traurig",
    "schnell", "langsam", "laut", "leise",
    "hell", "dunkel", "sauber", "schmutzig",
    "offen", "geschlossen", "frei", "besetzt",
    "fertig", "kaputt", "toll", "super", "prima",
    "gleich", "verschieden", "möglich",
    # Colours
    "rot", "blau", "grün", "gelb", "schwarz", "weiß",
    "grau", "braun", "orange", "rosa", "lila",
    # Adverbs & particles
    "ja", "nein", "bitte", "danke", "gern", "gerne",
    "auch", "nicht", "noch", "schon", "sehr", "viel",
    "wenig", "hier", "da", "dort", "links", "rechts",
    "oben", "unten", "vorne", "hinten", "jetzt", "gleich",
    "immer", "nie", "oft", "manchmal", "zusammen", "allein",
    "genau", "natürlich", "vielleicht", "leider",
    "doch", "zwar", "gerade", "sofort", "bald",
    "später", "vorher", "zuerst", "dann", "danach", "zuletzt",
    "endlich", "meistens", "normalerweise",
    # Conjunctions
    "und", "oder", "aber", "denn", "weil", "dass", "wenn",
    "als", "ob",
    # Prepositions
    "in", "an", "auf", "zu", "mit", "von", "aus",
    "nach", "bei", "bis", "für", "um", "über",
    "unter", "vor", "hinter", "zwischen", "durch",
    "ohne", "gegen", "ab", "seit",
    # Greetings & exclamations
    "hallo", "tschüss", "wiedersehen", "entschuldigung",
    "entschuldigen", "moment", "klasse", "okay",
    # Body
    "kopf", "hand", "auge", "ohr", "nase", "mund",
    "bein", "arm", "bauch", "rücken", "herz", "hals",
    "fuß", "finger", "zahn", "haar",
    # Clothing
    "jacke", "mantel", "hose", "rock", "hemd",
    "kleid", "schuh", "mütze", "strumpf",
    # School & work
    "klasse", "kurs", "sprache", "deutsch",
    "englisch", "arabisch", "türkisch", "russisch", "französisch",
    "antwort", "aufgabe", "beispiel", "seite", "nummer",
    "geld", "preis", "euro", "cent",
    "beruf", "arbeit", "job", "stelle",
    "urlaub", "reise", "ausland",
    # Nature & animals
    "tier", "hund", "katze", "vogel",
    "berg", "see", "meer", "fluss", "wald",
    "blume", "baum", "gras",
    # Sport & hobbies
    "sport", "fußball", "musik", "hobby", "spiel",
    # Other
    "formular", "pass", "personalausweis",
    "wort", "satz", "text", "zeile",
    "übung", "lektion", "gruppe", "team",
}

A2_WORDS = {
    # Extended verbs
    "beginnen", "enden", "passieren", "geschehen", "entstehen",
    "zubereiten", "bestellen", "empfehlen", "probieren",
    "absagen", "gratulieren", "organisieren",
    "planen", "vereinbaren", "anmelden", "abmelden",
    "zurückrufen", "umziehen", "einziehen", "ausziehen",
    "reparieren", "beschreiben", "erkennen", "vergleichen",
    "entscheiden", "erinnern", "vergessen",
    "aufräumen", "wegräumen",
    "spazieren", "wandern", "joggen", "radfahren",
    "abholen", "begleiten",
    "mieten", "verkaufen", "reservieren",
    "unterschreiben", "ausfüllen", "einschicken",
    "fernsehen", "herstellen", "produzieren",
    "schenken", "wünschen", "hoffen", "träumen",
    "fühlen", "freuen", "ärgern", "interessieren",
    "meinen", "vorstellen", "kennenlernen",
    "klappen", "funktionieren", "klingeln",
    "schicken", "senden",
    "nachdenken", "überlegen", "aufpassen",
    "einschlafen", "weitergehen", "zurückkommen",
    "mitkommen", "weitermachen", "nachfragen",
    "aussteigen", "einsteigen", "umsteigen",
    "einschalten", "ausschalten", "aufladen",
    "stattfinden", "teilnehmen", "mitmachen",
    "vorbereiten", "vorlesen", "nachschlagen",
    "übersetzen", "zusammenfassen",
    "gewinnen", "verlieren", "üben",
    "schneien", "regnen",
    "schicken", "posten",
    "gebrauchen", "benutzen",
    "ankündigen", "versprechen",
    "erscheinen", "verschwinden",
    "sammeln", "ordnen",
    "aufnehmen", "annehmen", "ablehnen",
    "vermissen", "zurücklassen",
    # Nouns – daily life
    "termin", "verabredung", "einladung", "party", "fest",
    "jubiläum", "glückwunsch", "feier",
    "rezept", "geschmack", "geruch",
    "rechnung", "quittung", "wechselgeld", "rabatt",
    "angebot", "sonderangebot",
    "nachricht", "meldung", "sendung", "programm",
    "kanal", "sender",
    "abfahrt", "ankunft", "verspätung",
    "fahrplan", "gleis", "bahnsteig",
    "mietwagen", "tankstelle", "parkplatz",
    "gepäck", "koffer", "rucksack",
    "reisepass", "visum", "grenze", "zoll",
    "stadtplan", "stadtführung", "sehenswürdigkeit",
    "ausflug", "wanderung",
    # Housing
    "miete", "nebenkosten", "heizung", "strom",
    "erdgeschoss", "stockwerk", "etage", "aufzug", "lift",
    "balkon", "garten", "hof", "garage", "dachboden",
    "nachbar", "nachbarin", "vermieter", "vermieterin",
    "handwerker", "elektriker", "klempner",
    "kühlschrank", "herd", "spülmaschine", "waschmaschine",
    # Health
    "erkältung", "grippe", "fieber", "schmerz",
    "tablette", "medikament", "apotheke",
    "zahnarzt", "tierarzt",
    "krankenkasse", "versicherung",
    "gesundheit", "verletzung", "wunde",
    # Education
    "abitur", "zeugnis", "note", "prüfung", "test",
    "hausaufgaben", "referat", "vortrag",
    "fach", "mathematik", "biologie", "chemie", "physik",
    "geschichte", "erdkunde", "kunst", "informatik",
    "fremdsprache", "unterricht",
    # Work & career
    "bewerbung", "lebenslauf", "vorstellungsgespräch",
    "gehalt", "lohn", "überstunden",
    "chef", "chefin", "mitarbeiter", "mitarbeiterin",
    "firma", "unternehmen", "abteilung",
    "besprechung", "konferenz", "projekt",
    # Shopping & money
    "konto", "girokonto", "sparkonto",
    "kreditkarte", "ec-karte", "pin", "überweisung",
    "einzahlung", "auszahlung", "bankverbindung",
    # Nature
    "pferd", "kuh", "schwein", "schaf",
    # Food (extended)
    "nudeln", "reis", "kartoffel", "mehl", "zucker",
    "salz", "pfeffer", "gewürz", "öl", "essig",
    "erdbeere", "traube",
    "tomate", "gurke", "paprika", "zwiebel", "knoblauch",
    "hähnchen", "rindfleisch", "schweinefleisch",
    "lecker", "satt",
    # Clothing (extended)
    "anzug", "krawatte", "sportkleidung",
    "größe", "baumwolle", "wolle",
    "bügeln",
    # Adjectives (A2)
    "wichtig", "nötig", "nützlich", "praktisch",
    "bequem", "angenehm",
    "freundlich", "höflich", "pünktlich",
    "zuverlässig", "ruhig", "aufgeregt",
    "nervös", "entspannt", "beschäftigt",
    "fleißig", "faul", "klar",
    "einfach", "kompliziert",
    "modern", "traditionell", "typisch",
    "beliebt", "bekannt", "berühmt",
    "öffentlich", "privat", "persönlich",
    "kostenlos", "umsonst", "gratis",
    "täglich", "wöchentlich", "monatlich", "jährlich",
    "möglich", "unmöglich",
    "nett", "wunderbar", "spannend",
    "schwierig", "genauso",
    "sicher", "unsicher",
    "frisch", "leer", "voll",
    "glücklich", "zufrieden",
    "neugierig", "mutig",
    "ähnlich", "anders", "eigen",
    "direkt", "deutlich",
    "kaputt",
    # Adverbs (A2)
    "wahrscheinlich", "doch", "trotzdem", "deshalb", "daher",
    "nämlich", "außerdem", "übrigens",
    "kaum", "fast", "ziemlich",
    "eigentlich", "besonders",
    # Question words
    "warum", "wieso", "weshalb", "wozu", "wofür",
    "womit", "worüber", "wohin", "woher",
    # Conjunctions (A2)
    "damit", "obwohl", "sobald",
    "solange", "bevor", "nachdem", "während",
    # Prepositions (A2)
    "wegen", "gegenüber", "entlang",
    "außerhalb", "innerhalb", "statt",
    # Other A2
    "beide", "alles", "nichts", "jemand", "niemand",
    "klima", "umwelt", "energie",
    "brief", "paket", "postkarte", "briefkasten",
    "stempel", "porto",
    "antrag", "kündigung",
    "kalender", "datum",
    "ferien", "feiertag",
    "geschenk", "glück", "pech",
    "unterschied", "vorteil", "nachteil",
    "problem", "lösung", "meinung",
    "wunsch", "ziel", "plan",
    "ordnung", "regel",
    "möglichkeit", "gelegenheit", "chance",
    "erfahrung", "idee", "gedanke",
    "grund", "ursache", "folge",
    "kontakt", "verbindung", "beziehung",
    "freude", "spaß", "humor",
    "angst", "sorge",
    "interesse", "lust",
    "schwierigkeit", "fehler", "verbesserung",
    "verständnis", "hilfe", "unterstützung",
    "freizeit",
    "wörterbuch", "nachschlagewerk",
    "übersetzung",
    # Common separable verb forms
    "abgeben", "abschließen", "absagen", "abschalten",
    "ausgehen", "aussteigen", "ausziehen",
    "einladen", "einschalten", "einsteigen", "einziehen",
    "mitbringen", "mitkommen", "mitmachen", "mitnehmen",
    "nachfragen", "nachschauen", "nachschlagen",
    "umziehen", "umsteigen",
    "vorbereiten", "vorhaben", "vorlesen", "vorstellen",
    "zurückgeben", "zurückkommen", "zurückrufen",
    "aufgeben", "aufheben", "aufmachen", "aufräumen",
    "aufnehmen", "aufpassen",
    "anmelden", "anrufen", "ansehen", "anziehen",
}

B1_WORDS = {
    # Advanced verbs
    "analysieren", "auswerten", "bewerten", "beurteilen",
    "argumentieren", "begründen", "rechtfertigen",
    "überzeugen", "widersprechen", "zustimmen",
    "vorschlagen", "abraten", "raten",
    "fordern", "verlangen", "beanspruchen",
    "kritisieren", "loben", "tadeln",
    "behaupten", "beweisen", "widerlegen",
    "annehmen", "feststellen", "bemerken",
    "unterscheiden", "kombinieren",
    "entwickeln", "aufbauen", "gestalten",
    "bearbeiten", "verbessern", "korrigieren",
    "lösen", "beheben", "verhindern", "vermeiden",
    "zunehmen", "abnehmen", "steigen", "fallen",
    "wachsen", "schrumpfen", "verändern",
    "darstellen", "präsentieren",
    "zusammenfassen", "berichten", "schildern",
    "mitteilen", "informieren", "benachrichtigen",
    "erledigen", "durchführen", "abschließen",
    "verwalten", "leiten", "führen",
    "gründen", "erweitern",
    "finanzieren", "investieren",
    "beeinflussen", "bestimmen", "regeln",
    "bedeuten", "bezeichnen", "definieren",
    "nachweisen", "belegen",
    "berücksichtigen", "beachten", "einhalten",
    "optimieren", "steigern",
    "einschränken", "begrenzen", "reduzieren",
    "unterstützen", "fördern", "ermöglichen",
    "erreichen", "erzielen", "schaffen",
    "schätzen", "respektieren", "tolerieren",
    "einsetzen", "verwenden",
    "beschäftigen", "anstellen", "entlassen",
    "umgehen", "handeln", "reagieren",
    "zweifeln", "vermuten",
    "vereinfachen", "verdeutlichen",
    "verwalten", "koordinieren",
    "prüfen", "untersuchen", "testen",
    "genehmigen", "ablehnen", "bestätigen",
    "beantragen", "einreichen", "vorlegen",
    "zusammenarbeiten", "kooperieren",
    "kommunizieren", "diskutieren",
    # Society & politics
    "gesellschaft", "gemeinschaft", "bevölkerung",
    "bürger", "bürgerin", "staat", "regierung",
    "parlament", "demokratie", "wahl", "politik",
    "partei", "gesetz", "recht", "pflicht",
    "freiheit", "gleichberechtigung", "gerechtigkeit",
    "solidarität", "toleranz", "respekt",
    "konflikt", "diskussion", "debatte",
    "reform", "fortschritt",
    "verfassung", "grundgesetz", "menschenrechte",
    "demonstration", "streik", "protest",
    "migration", "integration", "flüchtling",
    "asyl", "einwanderung", "auswanderung",
    # Economy & work
    "wirtschaft", "markt", "produkt", "dienstleistung",
    "handel", "import", "export", "globalisierung",
    "konkurrenz", "wettbewerb",
    "arbeitslosigkeit", "beschäftigung", "arbeitsmarkt",
    "rente", "pension", "sozialversicherung",
    "steuer", "haushalt", "budget",
    "betrieb", "konzern",
    "karriere", "aufstieg", "beförderung",
    "ausbildung", "praktikum", "weiterbildung",
    "vertrag", "kündigung", "entlassung",
    "gewerkschaft", "tarifvertrag",
    # Education & culture
    "bildung", "erziehung",
    "abschluss", "diplom", "bachelor", "master",
    "forschung", "wissenschaft", "technologie",
    "kreativität", "talent", "begabung",
    "literatur", "museum", "ausstellung",
    "tradition", "veranstaltung", "festival", "konzert",
    "hochschule", "akademie", "institut",
    "lehrplan", "curriculum",
    # Media & communication
    "medien", "presse", "rundfunk",
    "magazin", "onlinemedien",
    "kommunikation", "werbung",
    "datenschutz", "privatsphäre",
    "digitalisierung",
    # Health & body
    "operation", "behandlung", "therapie", "rehabilitation",
    "vorsorge", "vorbeugung", "ernährung",
    "fitness", "bewegung", "entspannung", "stress",
    "psychologie", "wohlbefinden",
    "abhängigkeit", "sucht",
    # Environment & nature
    "klimawandel", "erderwärmung", "treibhausgas",
    "solarenergie", "windenergie",
    "naturschutz", "biodiversität",
    "nachhaltigkeit", "ökologie",
    "verschmutzung", "abfall",
    "naturkatastrophe", "überschwemmung", "dürre",
    "ressource", "rohstoff",
    # Technology
    "programm", "software", "hardware", "netzwerk",
    "datei", "dokument", "drucker", "scanner",
    "passwort", "sicherheit",
    "smartphone", "tablet", "laptop",
    "anwendung", "app", "plattform",
    # Adjectives (B1)
    "kompetent", "qualifiziert", "erfahren",
    "erfolgreich", "effizient", "produktiv",
    "kreativ", "innovativ", "flexibel",
    "zielstrebig", "engagiert", "motiviert",
    "selbstständig", "unabhängig",
    "kooperativ", "kommunikativ",
    "analytisch", "kritisch", "objektiv",
    "nachhaltig", "umweltfreundlich", "ökologisch",
    "wirtschaftlich", "finanziell", "sozial",
    "politisch", "kulturell", "gesellschaftlich",
    "global", "international", "national", "regional",
    "urban", "ländlich", "städtisch",
    "technisch", "wissenschaftlich", "theoretisch",
    "realistisch", "optimistisch", "pessimistisch",
    "skeptisch", "konservativ", "progressiv", "liberal",
    "verantwortlich", "zuständig", "komplex",
    "grundlegend", "wesentlich", "erheblich",
    "gültig", "wirksam", "effektiv",
    "aktuell", "relevant", "bedeutsam",
    "umstritten", "kontrovers",
    # Modal particles & connectors (B1)
    "allerdings", "dennoch", "jedoch", "hingegen",
    "einerseits", "andererseits",
    "infolge", "aufgrund", "angesichts",
    "hinsichtlich", "bezüglich",
    "abgesehen", "anstatt",
    # Reporting & academic
    "bericht", "studie", "ergebnis", "schlussfolgerung",
    "überblick", "hypothese", "theorie", "methode",
    "quelle", "zitat", "referenz",
    "statistik", "umfrage", "erhebung",
    "analyse", "untersuchung", "beweis",
    "fazit", "einleitung",
    # Emotions & personality
    "einsamkeit", "sehnsucht", "heimweh",
    "begeisterung", "enthusiasmus", "leidenschaft",
    "vertrauen", "misstrauen", "hoffnung",
    "enttäuschung", "erleichterung", "stolz",
    "scham", "schuld", "reue", "empathie",
    "geduld", "ausdauer", "ehrgeiz",
    "selbstvertrauen", "selbstbewusstsein",
    # Law & administration
    "vertrag", "klausel", "bedingung",
    "strafe", "buße", "klage",
    "gericht", "richter", "anwalt",
    "behörde", "amt", "verwaltung",
    "genehmigung", "erlaubnis", "verbot",
    # Medicine (B1)
    "diagnose", "symptom", "untersuchung",
    "allergie", "asthma",
    "impfung", "impfstoff",
}

# ---------------------------------------------------------------------------
# Compound-word prefix roots  (A1-root → A2 bump, A2-root → B1 bump)
# ---------------------------------------------------------------------------

A1_COMPOUND_ROOTS = {
    "abend", "arbeit", "auto", "bahn", "buch", "brief",
    "essen", "familie", "haus", "kind", "land",
    "lehrer", "schule", "sport", "sprache", "stadt",
    "tag", "tisch", "wasser", "wetter", "woche", "wort",
    "zeitung", "zimmer", "zug", "arzt", "schul",
    "kind", "geld", "berg", "blume", "baum",
    "hand", "kopf", "fuß", "herz", "auge",
}

A2_COMPOUND_ROOTS = {
    "arbeit", "bank", "berufs", "bildung",
    "bürger", "dienst", "gesundheit", "gesellschaft",
    "lebens", "markt", "natur", "preis",
    "recht", "reise", "sicherheit", "sozial",
    "verkehr", "wirtschaft", "zukunft",
    "umwelt", "kultur", "familien", "jugend",
}

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

ARTICLE_TOKENS = {"der", "die", "das", "sich"}


def extract_base(word: str) -> str:
    """Return lowercase bare lemma (strip leading article token)."""
    if not word:
        return ""
    cleaned = re.sub(r"\s+", " ", word.strip()).lower()
    parts = cleaned.split(" ", 1)
    if parts[0] in ARTICLE_TOKENS:
        return parts[1] if len(parts) > 1 else ""
    return cleaned


def assign_level(word: str) -> str:
    """Classify a German word/phrase into A1 / A2 / B1 / B2."""
    base = extract_base(word)
    first_token = base.split()[0] if base else ""

    # Direct exact match
    if base in A1_WORDS or first_token in A1_WORDS:
        return "A1"
    if base in A2_WORDS or first_token in A2_WORDS:
        return "A2"
    if base in B1_WORDS or first_token in B1_WORDS:
        return "B1"

    # Compound-root matching: A1 root → A2
    for root in A1_COMPOUND_ROOTS:
        if base.startswith(root) and len(base) > len(root) + 1:
            return "A2"

    # Compound-root matching: A2 root → B1
    for root in A2_COMPOUND_ROOTS:
        if base.startswith(root) and len(base) > len(root) + 1:
            return "B1"

    return "B2"


# ---------------------------------------------------------------------------
# Styling helpers
# ---------------------------------------------------------------------------

LEVEL_COLORS = {
    "A1": "C6EFCE",   # light green
    "A2": "FFEB9C",   # light yellow
    "B1": "FCE4D6",   # light orange/pink
    "B2": "DAE8FC",   # light blue
}

HEADER_COLOR = "1F4E79"   # dark navy


def _side() -> Side:
    return Side(style="thin", color="CCCCCC")


def _border() -> Border:
    s = _side()
    return Border(left=s, right=s, top=s, bottom=s)


def apply_header_style(cell: openpyxl.cell.Cell) -> None:
    cell.font = Font(bold=True, color="FFFFFF", size=11)
    cell.fill = PatternFill("solid", fgColor=HEADER_COLOR)
    cell.alignment = Alignment(horizontal="center", vertical="center",
                               wrap_text=True)
    cell.border = _border()


def apply_data_style(cell: openpyxl.cell.Cell, level: str,
                     col_idx: int) -> None:
    color = LEVEL_COLORS.get(level, "FFFFFF")
    if col_idx == 0:
        cell.fill = PatternFill("solid", fgColor=color)
        cell.font = Font(bold=True, size=10)
        cell.alignment = Alignment(horizontal="center", vertical="center")
    else:
        cell.alignment = Alignment(vertical="top", wrap_text=True)
    cell.border = _border()


def set_column_widths(
    ws: openpyxl.worksheet.worksheet.Worksheet,
) -> None:
    widths = [8, 12, 32, 10, 12, 18, 18, 40, 18, 18, 15, 15, 18, 18, 55]
    for i, w in enumerate(widths, start=1):
        if i <= ws.max_column:
            ws.column_dimensions[get_column_letter(i)].width = w


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

SOURCE = (
    "/Users/elvinmammadov/Desktop/german/final dics/Dictionary_Last.xlsx"
)
OUT_DIR = "/Users/elvinmammadov/Desktop/german/final dics/levels"

os.makedirs(OUT_DIR, exist_ok=True)


def main() -> None:
    print(f"Loading {SOURCE} ...")
    wb_src = openpyxl.load_workbook(SOURCE, read_only=True, data_only=True)
    ws_src = wb_src.active
    all_rows = list(ws_src.iter_rows(min_row=1, values_only=True))
    wb_src.close()

    headers = list(all_rows[0])
    data = all_rows[1:]
    new_headers = ["Level"] + headers

    buckets: dict[str, list] = {"A1": [], "A2": [], "B1": [], "B2": []}
    for row in data:
        word = row[1] if len(row) > 1 else ""
        level = assign_level(str(word) if word else "")
        buckets[level].append((level, *row))

    for level, rows in buckets.items():
        out_path = os.path.join(OUT_DIR, f"Dictionary_{level}.xlsx")
        wb_out = openpyxl.Workbook()
        ws_out = wb_out.active
        ws_out.title = f"{level} Vocabulary"

        ws_out.row_dimensions[1].height = 30
        for col_idx, h in enumerate(new_headers, start=1):
            cell = ws_out.cell(row=1, column=col_idx, value=h)
            apply_header_style(cell)
        ws_out.freeze_panes = "A2"

        for row_idx, row in enumerate(rows, start=2):
            ws_out.row_dimensions[row_idx].height = 20
            for col_idx, value in enumerate(row, start=1):
                cell = ws_out.cell(row=row_idx, column=col_idx, value=value)
                apply_data_style(cell, level, col_idx - 1)

        set_column_widths(ws_out)
        wb_out.save(out_path)
        print(f"  ✓ {level}: {len(rows):>5} words  → {out_path}")

    total = sum(len(v) for v in buckets.values())
    print(f"\nDone. {total} words classified:")
    for level in ("A1", "A2", "B1", "B2"):
        pct = len(buckets[level]) / total * 100
        print(f"  {level}: {len(buckets[level]):>5}  ({pct:.1f}%)")


if __name__ == "__main__":
    main()

