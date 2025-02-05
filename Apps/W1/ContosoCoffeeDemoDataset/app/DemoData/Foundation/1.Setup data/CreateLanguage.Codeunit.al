codeunit 5299 "Create Language"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoLanguage: Codeunit "Contoso Language";
    begin
        ContosoLanguage.InsertLanguage(BGR(), BulgarianLbl);
        ContosoLanguage.InsertLanguage(CHS(), SimplifiedChineseLbl);
        ContosoLanguage.InsertLanguage(CSY(), CzechLbl);
        ContosoLanguage.InsertLanguage(DAN(), DanishLbl);
        ContosoLanguage.InsertLanguage(DEA(), GermanAustrianLbl);
        ContosoLanguage.InsertLanguage(DES(), GermanSwissLbl);
        ContosoLanguage.InsertLanguage(DEU(), GermanLbl);
        ContosoLanguage.InsertLanguage(ELL(), GreekLbl);
        ContosoLanguage.InsertLanguage(ENA(), EnglishAustralianLbl);
        ContosoLanguage.InsertLanguage(ENC(), EnglishCanadianLbl);
        ContosoLanguage.InsertLanguage(ENG(), EnglishUKLbl);
        ContosoLanguage.InsertLanguage(ENI(), EnglishIrelandLbl);
        ContosoLanguage.InsertLanguage(ENP(), EnglishPhilippinesLbl);
        ContosoLanguage.InsertLanguage(ENU(), EnglishLbl);
        ContosoLanguage.InsertLanguage(ENZ(), EnglishNZLbl);
        ContosoLanguage.InsertLanguage(ESM(), SpanishMexicoLbl);
        ContosoLanguage.InsertLanguage(ESN(), SpanishSpainLbl);
        ContosoLanguage.InsertLanguage(ESO(), SpanishColombiaLbl);
        ContosoLanguage.InsertLanguage(ESP(), SpanishLbl);
        ContosoLanguage.InsertLanguage(ESR(), SpanishPeruLbl);
        ContosoLanguage.InsertLanguage(ESS(), SpanishArgentineLbl);
        ContosoLanguage.InsertLanguage(ETI(), EstonianLbl);
        ContosoLanguage.InsertLanguage(FIN(), FinnishLbl);
        ContosoLanguage.InsertLanguage(FRA(), FrenchLbl);
        ContosoLanguage.InsertLanguage(FRB(), FrenchBelgianLbl);
        ContosoLanguage.InsertLanguage(FRC(), FrenchCanadianLbl);
        ContosoLanguage.InsertLanguage(FRS(), FrenchSwissLbl);
        ContosoLanguage.InsertLanguage(HRV(), CroatianLbl);
        ContosoLanguage.InsertLanguage(HUN(), HungarianLbl);
        ContosoLanguage.InsertLanguage(IND(), IndonesianLbl);
        ContosoLanguage.InsertLanguage(ISL(), IcelandicLbl);
        ContosoLanguage.InsertLanguage(ITA(), ItalianLbl);
        ContosoLanguage.InsertLanguage(ITS(), ItalianSwissLbl);
        ContosoLanguage.InsertLanguage(JPN(), JapaneseLbl);
        ContosoLanguage.InsertLanguage(KOR(), KoreanLbl);
        ContosoLanguage.InsertLanguage(LTH(), LithuanianLbl);
        ContosoLanguage.InsertLanguage(LVI(), LatvianLbl);
        ContosoLanguage.InsertLanguage(MSL(), MalaysianLbl);
        ContosoLanguage.InsertLanguage(NLB(), DutchBelgianLbl);
        ContosoLanguage.InsertLanguage(NLD(), DutchLbl);
        ContosoLanguage.InsertLanguage(NON(), NorwegianNynorskLbl);
        ContosoLanguage.InsertLanguage(NOR(), NorwegianLbl);
        ContosoLanguage.InsertLanguage(PLK(), PolishLbl);
        ContosoLanguage.InsertLanguage(PTB(), PortugueseBrazilLbl);
        ContosoLanguage.InsertLanguage(PTG(), PortugueseLbl);
        ContosoLanguage.InsertLanguage(ROM(), RomanianLbl);
        ContosoLanguage.InsertLanguage(RUS(), RussianLbl);
        ContosoLanguage.InsertLanguage(SKY(), SlovakLbl);
        ContosoLanguage.InsertLanguage(SLV(), SloveneLbl);
        ContosoLanguage.InsertLanguage(SRP(), SerbianLbl);
        ContosoLanguage.InsertLanguage(SVE(), SwedishLbl);
        ContosoLanguage.InsertLanguage(THA(), ThaiLbl);
        ContosoLanguage.InsertLanguage(TRK(), TurkishLbl);
        ContosoLanguage.InsertLanguage(UKR(), UkrainianLbl);
    end;

    procedure BGR(): Code[10]
    begin
        exit(BGRTok);
    end;

    procedure CHS(): Code[10]
    begin
        exit(CHSTok);
    end;

    procedure CSY(): Code[10]
    begin
        exit(CSYTok);
    end;

    procedure DAN(): Code[10]
    begin
        exit(DANTok);
    end;

    procedure DEA(): Code[10]
    begin
        exit(DEATok);
    end;

    procedure DES(): Code[10]
    begin
        exit(DESTok);
    end;

    procedure DEU(): Code[10]
    begin
        exit(DEUTok);
    end;

    procedure ELL(): Code[10]
    begin
        exit(ELLTok);
    end;

    procedure ENA(): Code[10]
    begin
        exit(ENATok);
    end;

    procedure ENC(): Code[10]
    begin
        exit(ENCTok);
    end;

    procedure ENG(): Code[10]
    begin
        exit(ENGTok);
    end;

    procedure ENI(): Code[10]
    begin
        exit(ENITok);
    end;

    procedure ENP(): Code[10]
    begin
        exit(ENPTok);
    end;

    procedure ENU(): Code[10]
    begin
        exit(ENUTok);
    end;

    procedure ENZ(): Code[10]
    begin
        exit(ENZTok);
    end;

    procedure ESM(): Code[10]
    begin
        exit(ESMTok);
    end;

    procedure ESN(): Code[10]
    begin
        exit(ESNTok);
    end;

    procedure ESO(): Code[10]
    begin
        exit(ESOTok);
    end;

    procedure ESP(): Code[10]
    begin
        exit(ESPTok);
    end;

    procedure ESR(): Code[10]
    begin
        exit(ESRTok);
    end;

    procedure ESS(): Code[10]
    begin
        exit(ESSTok);
    end;

    procedure ETI(): Code[10]
    begin
        exit(ETITok);
    end;

    procedure FIN(): Code[10]
    begin
        exit(FINTok);
    end;

    procedure FRA(): Code[10]
    begin
        exit(FRATok);
    end;

    procedure FRB(): Code[10]
    begin
        exit(FRBTok);
    end;

    procedure FRC(): Code[10]
    begin
        exit(FRCTok);
    end;

    procedure FRS(): Code[10]
    begin
        exit(FRSTok);
    end;

    procedure HRV(): Code[10]
    begin
        exit(HRVTok);
    end;

    procedure HUN(): Code[10]
    begin
        exit(HUNTok);
    end;

    procedure IND(): Code[10]
    begin
        exit(INDTok);
    end;

    procedure ISL(): Code[10]
    begin
        exit(ISLTok);
    end;

    procedure ITA(): Code[10]
    begin
        exit(ITATok);
    end;

    procedure ITS(): Code[10]
    begin
        exit(ITSTok);
    end;

    procedure JPN(): Code[10]
    begin
        exit(JPNTok);
    end;

    procedure KOR(): Code[10]
    begin
        exit(KORTok);
    end;

    procedure LTH(): Code[10]
    begin
        exit(LTHTok);
    end;

    procedure LVI(): Code[10]
    begin
        exit(LVITok);
    end;

    procedure MSL(): Code[10]
    begin
        exit(MSLTok);
    end;

    procedure NLB(): Code[10]
    begin
        exit(NLBTok);
    end;

    procedure NLD(): Code[10]
    begin
        exit(NLDTok);
    end;

    procedure NON(): Code[10]
    begin
        exit(NONTok);
    end;

    procedure NOR(): Code[10]
    begin
        exit(NORTok);
    end;

    procedure PLK(): Code[10]
    begin
        exit(PLKTok);
    end;

    procedure PTB(): Code[10]
    begin
        exit(PTBTok);
    end;

    procedure PTG(): Code[10]
    begin
        exit(PTGTok);
    end;

    procedure ROM(): Code[10]
    begin
        exit(ROMTok);
    end;

    procedure RUS(): Code[10]
    begin
        exit(RUSTok);
    end;

    procedure SKY(): Code[10]
    begin
        exit(SKYTok);
    end;

    procedure SLV(): Code[10]
    begin
        exit(SLVTok);
    end;

    procedure SRP(): Code[10]
    begin
        exit(SRPTok);
    end;

    procedure SVE(): Code[10]
    begin
        exit(SVETok);
    end;

    procedure THA(): Code[10]
    begin
        exit(THATok);
    end;

    procedure TRK(): Code[10]
    begin
        exit(TRKTok);
    end;

    procedure UKR(): Code[10]
    begin
        exit(UKRTok);
    end;

    var
        BGRTok: Label 'BGR', MaxLength = 10, Locked = true;
        CHSTok: Label 'CHS', MaxLength = 10, Locked = true;
        CSYTok: Label 'CSY', MaxLength = 10, Locked = true;
        DANTok: Label 'DAN', MaxLength = 10, Locked = true;
        DEATok: Label 'DEA', MaxLength = 10, Locked = true;
        DESTok: Label 'DES', MaxLength = 10, Locked = true;
        DEUTok: Label 'DEU', MaxLength = 10, Locked = true;
        ELLTok: Label 'ELL', MaxLength = 10, Locked = true;
        ENATok: Label 'ENA', MaxLength = 10, Locked = true;
        ENCTok: Label 'ENC', MaxLength = 10, Locked = true;
        ENGTok: Label 'ENG', MaxLength = 10, Locked = true;
        ENITok: Label 'ENI', MaxLength = 10, Locked = true;
        ENPTok: Label 'ENP', MaxLength = 10, Locked = true;
        ENUTok: Label 'ENU', MaxLength = 10, Locked = true;
        ENZTok: Label 'ENZ', MaxLength = 10, Locked = true;
        ESMTok: Label 'ESM', MaxLength = 10, Locked = true;
        ESNTok: Label 'ESN', MaxLength = 10, Locked = true;
        ESOTok: Label 'ESO', MaxLength = 10, Locked = true;
        ESPTok: Label 'ESP', MaxLength = 10, Locked = true;
        ESRTok: Label 'ESR', MaxLength = 10, Locked = true;
        ESSTok: Label 'ESS', MaxLength = 10, Locked = true;
        ETITok: Label 'ETI', MaxLength = 10, Locked = true;
        FINTok: Label 'FIN', MaxLength = 10, Locked = true;
        FRATok: Label 'FRA', MaxLength = 10, Locked = true;
        FRBTok: Label 'FRB', MaxLength = 10, Locked = true;
        FRCTok: Label 'FRC', MaxLength = 10, Locked = true;
        FRSTok: Label 'FRS', MaxLength = 10, Locked = true;
        HRVTok: Label 'HRV', MaxLength = 10, Locked = true;
        HUNTok: Label 'HUN', MaxLength = 10, Locked = true;
        INDTok: Label 'IND', MaxLength = 10, Locked = true;
        ISLTok: Label 'ISL', MaxLength = 10, Locked = true;
        ITATok: Label 'ITA', MaxLength = 10, Locked = true;
        ITSTok: Label 'ITS', MaxLength = 10, Locked = true;
        JPNTok: Label 'JPN', MaxLength = 10, Locked = true;
        KORTok: Label 'KOR', MaxLength = 10, Locked = true;
        LTHTok: Label 'LTH', MaxLength = 10, Locked = true;
        LVITok: Label 'LVI', MaxLength = 10, Locked = true;
        MSLTok: Label 'MSL', MaxLength = 10, Locked = true;
        NLBTok: Label 'NLB', MaxLength = 10, Locked = true;
        NLDTok: Label 'NLD', MaxLength = 10, Locked = true;
        NONTok: Label 'NON', MaxLength = 10, Locked = true;
        NORTok: Label 'NOR', MaxLength = 10, Locked = true;
        PLKTok: Label 'PLK', MaxLength = 10, Locked = true;
        PTBTok: Label 'PTB', MaxLength = 10, Locked = true;
        PTGTok: Label 'PTG', MaxLength = 10, Locked = true;
        ROMTok: Label 'ROM', MaxLength = 10, Locked = true;
        RUSTok: Label 'RUS', MaxLength = 10, Locked = true;
        SKYTok: Label 'SKY', MaxLength = 10, Locked = true;
        SLVTok: Label 'SLV', MaxLength = 10, Locked = true;
        SRPTok: Label 'SRP', MaxLength = 10, Locked = true;
        SVETok: Label 'SVE', MaxLength = 10, Locked = true;
        THATok: Label 'THA', MaxLength = 10, Locked = true;
        TRKTok: Label 'TRK', MaxLength = 10, Locked = true;
        UKRTok: Label 'UKR', MaxLength = 10, Locked = true;
        BulgarianLbl: Label 'Bulgarian', MaxLength = 50;
        SimplifiedChineseLbl: Label 'Simplified Chinese', MaxLength = 50;
        CzechLbl: Label 'Czech', MaxLength = 50;
        DanishLbl: Label 'Danish', MaxLength = 50;
        GermanAustrianLbl: Label 'German (Austrian)', MaxLength = 50;
        GermanSwissLbl: Label 'German (Swiss)', MaxLength = 50;
        GermanLbl: Label 'German', MaxLength = 50;
        GreekLbl: Label 'Greek', MaxLength = 50;
        EnglishAustralianLbl: Label 'English (Australian)', MaxLength = 50;
        EnglishCanadianLbl: Label 'English (Canadian)', MaxLength = 50;
        EnglishUKLbl: Label 'English (United Kingdom)', MaxLength = 50;
        EnglishIrelandLbl: Label 'English (Ireland)', MaxLength = 50;
        EnglishPhilippinesLbl: Label 'English (Philippines)', MaxLength = 50;
        EnglishLbl: Label 'English', MaxLength = 50;
        EnglishNZLbl: Label 'English (New Zealand)', MaxLength = 50;
        SpanishMexicoLbl: Label 'Spanish (Mexico)', MaxLength = 50;
        SpanishSpainLbl: Label 'Spanish (Spain)', MaxLength = 50;
        SpanishColombiaLbl: Label 'Spanish (Colombia)', MaxLength = 50;
        SpanishLbl: Label 'Spanish', MaxLength = 50;
        SpanishPeruLbl: Label 'Spanish (Peru)', MaxLength = 50;
        SpanishArgentineLbl: Label 'Spanish (Argentine)', MaxLength = 50;
        EstonianLbl: Label 'Estonian', MaxLength = 50;
        FinnishLbl: Label 'Finnish', MaxLength = 50;
        FrenchLbl: Label 'French', MaxLength = 50;
        FrenchBelgianLbl: Label 'French (Belgian)', MaxLength = 50;
        FrenchCanadianLbl: Label 'French (Canadian)', MaxLength = 50;
        FrenchSwissLbl: Label 'French (Swiss)', MaxLength = 50;
        CroatianLbl: Label 'Croatian', MaxLength = 50;
        HungarianLbl: Label 'Hungarian', MaxLength = 50;
        IndonesianLbl: Label 'Indonesian', MaxLength = 50;
        IcelandicLbl: Label 'Icelandic', MaxLength = 50;
        ItalianLbl: Label 'Italian', MaxLength = 50;
        ItalianSwissLbl: Label 'Italian (Swiss)', MaxLength = 50;
        JapaneseLbl: Label 'Japanese', MaxLength = 50;
        KoreanLbl: Label 'Korean', MaxLength = 50;
        LithuanianLbl: Label 'Lithuanian', MaxLength = 50;
        LatvianLbl: Label 'Latvian', MaxLength = 50;
        MalaysianLbl: Label 'Malaysian', MaxLength = 50;
        DutchBelgianLbl: Label 'Dutch (Belgian)', MaxLength = 50;
        DutchLbl: Label 'Dutch', MaxLength = 50;
        NorwegianNynorskLbl: Label 'Norwegian (Nynorsk)', MaxLength = 50;
        NorwegianLbl: Label 'Norwegian', MaxLength = 50;
        PolishLbl: Label 'Polish', MaxLength = 50;
        PortugueseBrazilLbl: Label 'Portuguese (Brazil)', MaxLength = 50;
        PortugueseLbl: Label 'Portuguese', MaxLength = 50;
        RomanianLbl: Label 'Romanian', MaxLength = 50;
        RussianLbl: Label 'Russian', MaxLength = 50;
        SlovakLbl: Label 'Slovak', MaxLength = 50;
        SloveneLbl: Label 'Slovene', MaxLength = 50;
        SerbianLbl: Label 'Serbian', MaxLength = 50;
        SwedishLbl: Label 'Swedish', MaxLength = 50;
        ThaiLbl: Label 'Thai', MaxLength = 50;
        TurkishLbl: Label 'Turkish', MaxLength = 50;
        UkrainianLbl: Label 'Ukrainian', MaxLength = 50;
}