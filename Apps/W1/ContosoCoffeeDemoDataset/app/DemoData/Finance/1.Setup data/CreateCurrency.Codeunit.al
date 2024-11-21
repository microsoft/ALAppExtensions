codeunit 5525 "Create Currency"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        Currency: Record "Currency";
        CreateGLAccount: Codeunit "Create G/L Account";
        ContosoCurrency: Codeunit "Contoso Currency";
    begin
        ContosoCurrency.InsertCurrency(AED(), '784', UnitedArabEmiratesdirhamLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.25, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(AUD(), '036', AustralianDollarLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(BGN(), '975', BulgarianLevaLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(BND(), '096', BruneiDarussalemDollarLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(BRL(), '986', BrazilianRealLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(CAD(), '124', CanadianDollarLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(CHF(), '756', SwissFrancLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(CZK(), '203', CzechKorunaLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(DKK(), '208', DanishkroneLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(DZD(), '012', AlgerianDinarLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(EUR(), '978', EuroLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, true, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(FJD(), '242', FijiDollarLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(GBP(), '826', BritishPoundLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(HKD(), '344', HongKongDollarLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(HRK(), '191', CroatianKunaLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(HUF(), '348', HungarianForintLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 1, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(IDR(), '360', IndonesianRupiahLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 1, Currency."Invoice Rounding Type"::Nearest, 1, 0.1, false, '0:0', '0:3');
        ContosoCurrency.InsertCurrency(INR(), '356', IndianRupeeLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(ISK(), '352', IcelandicKronaLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(JPY(), '392', JapaneseYenLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(KES(), '404', KenyanShillingLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.5, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(MAD(), '504', MoroccanDirhamLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(MXN(), '484', MexicanPesoLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(MYR(), '458', MalaysianRinggitLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(MZN(), '943', MozambiqueMeticalLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 10, Currency."Invoice Rounding Type"::Nearest, 1, 0.01, false, '0:0', '0:3');
        ContosoCurrency.InsertCurrency(NGN(), '566', NigerianNairaLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 1, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(NOK(), '578', NorwegianKroneLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(NZD(), '554', NewZealandDollarLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(PHP(), '608', PhilippinesPesoLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(PLN(), '985', PolishZlotyLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(RON(), '946', RomanianLeuLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.01, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(RSD(), '941', SerbianDinarLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(RUB(), '643', RussianRubleLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(SAR(), '682', SaudiArabianRyialLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(SBD(), '090', SolomonIslandsDollarLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(SEK(), '752', SwedishKronaLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(SGD(), '702', SingaporeDollarLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(SZL(), '748', SwazilandLilangeniLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(THB(), '764', ThaiBahtLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 1, Currency."Invoice Rounding Type"::Nearest, 1, 1, false, '0:0', '0:3');
        ContosoCurrency.InsertCurrency(TND(), '788', TunesianDinarLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.001, 0.001, false, '3:3', '2:5');
        ContosoCurrency.InsertCurrency(TOP(), '776', TonganPaangaLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(TRY(), '949', NewTurkishLiraLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(UGX(), '800', UgandanShillingLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 1, Currency."Invoice Rounding Type"::Nearest, 1, 0.1, false, '0:0', '0:3');
        ContosoCurrency.InsertCurrency(USD(), '840', USDollarLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(VUV(), '548', VanuatuVatuLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(WST(), '882', WesternSamoanTalaLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(XPF(), '953', FrenchPacificFrancLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(ZAR(), '710', SouthAfricanRandLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
    end;

    procedure AED(): Code[10]
    begin
        exit('AED');
    end;

    procedure AUD(): Code[10]
    begin
        exit('AUD');
    end;

    procedure BGN(): Code[10]
    begin
        exit('BGN');
    end;

    procedure BND(): Code[10]
    begin
        exit('BND');
    end;

    procedure BRL(): Code[10]
    begin
        exit('BRL');
    end;

    procedure CAD(): Code[10]
    begin
        exit('CAD');
    end;

    procedure CHF(): Code[10]
    begin
        exit('CHF');
    end;

    procedure CZK(): Code[10]
    begin
        exit('CZK');
    end;

    procedure DKK(): Code[10]
    begin
        exit('DKK');
    end;

    procedure DZD(): Code[10]
    begin
        exit('DZD');
    end;

    procedure EUR(): Code[10]
    begin
        exit('EUR');
    end;

    procedure FJD(): Code[10]
    begin
        exit('FJD');
    end;

    procedure GBP(): Code[10]
    begin
        exit('GBP');
    end;

    procedure HKD(): Code[10]
    begin
        exit('HKD');
    end;

    procedure HRK(): Code[10]
    begin
        exit('HRK');
    end;

    procedure HUF(): Code[10]
    begin
        exit('HUF');
    end;

    procedure IDR(): Code[10]
    begin
        exit('IDR');
    end;

    procedure INR(): Code[10]
    begin
        exit('INR');
    end;

    procedure ISK(): Code[10]
    begin
        exit('ISK');
    end;

    procedure JPY(): Code[10]
    begin
        exit('JPY');
    end;

    procedure KES(): Code[10]
    begin
        exit('KES');
    end;

    procedure MAD(): Code[10]
    begin
        exit('MAD');
    end;

    procedure MXN(): Code[10]
    begin
        exit('MXN');
    end;

    procedure MYR(): Code[10]
    begin
        exit('MYR');
    end;

    procedure MZN(): Code[10]
    begin
        exit('MZN');
    end;

    procedure NGN(): Code[10]
    begin
        exit('NGN');
    end;

    procedure NOK(): Code[10]
    begin
        exit('NOK');
    end;

    procedure NZD(): Code[10]
    begin
        exit('NZD');
    end;

    procedure PHP(): Code[10]
    begin
        exit('PHP');
    end;

    procedure PLN(): Code[10]
    begin
        exit('PLN');
    end;

    procedure RON(): Code[10]
    begin
        exit('RON');
    end;

    procedure RSD(): Code[10]
    begin
        exit('RSD');
    end;

    procedure RUB(): Code[10]
    begin
        exit('RUB');
    end;

    procedure SAR(): Code[10]
    begin
        exit('SAR');
    end;

    procedure SBD(): Code[10]
    begin
        exit('SBD');
    end;

    procedure SEK(): Code[10]
    begin
        exit('SEK');
    end;

    procedure SGD(): Code[10]
    begin
        exit('SGD');
    end;

    procedure SZL(): Code[10]
    begin
        exit('SZL');
    end;

    procedure THB(): Code[10]
    begin
        exit('THB');
    end;

    procedure TND(): Code[10]
    begin
        exit('TND');
    end;

    procedure TOP(): Code[10]
    begin
        exit('TOP');
    end;

    procedure TRY(): Code[10]
    begin
        exit('TRY');
    end;

    procedure UGX(): Code[10]
    begin
        exit('UGX');
    end;

    procedure USD(): Code[10]
    begin
        exit('USD');
    end;

    procedure VUV(): Code[10]
    begin
        exit('VUV');
    end;

    procedure WST(): Code[10]
    begin
        exit('WST');
    end;

    procedure XPF(): Code[10]
    begin
        exit('XPF');
    end;

    procedure ZAR(): Code[10]
    begin
        exit('ZAR');
    end;

    var
        EuroLbl: Label 'Euro';
        AustraliandollarLbl: Label 'Australian dollar';
        BulgarianlevaLbl: Label 'Bulgarian leva';
        BruneiDarussalemdollarLbl: Label 'Brunei Darussalem dollar';
        BrazilianrealLbl: Label 'Brazilian real';
        CanadiandollarLbl: Label 'Canadian dollar';
        CroatianKunaLbl: Label 'Croatian Kuna';
        SwissfrancLbl: Label 'Swiss franc';
        CzechkorunaLbl: Label 'Czech koruna';
        DanishkroneLbl: Label 'Danish krone';
        FijidollarLbl: Label 'Fiji dollar';
        BritishpoundLbl: Label 'Pound Sterling';
        HongKongdollarLbl: Label 'Hong Kong dollar';
        IndonesianrupiahLbl: Label 'Indonesian rupiah';
        JapaneseyenLbl: Label 'Japanese yen';
        IndianrupeeLbl: Label 'Indian rupee';
        IcelandickronaLbl: Label 'Icelandic krona';
        MalaysianringgitLbl: Label 'Malaysian ringgit';
        MexicanpesoLbl: Label 'Mexican peso';
        NorwegiankroneLbl: Label 'Norwegian krone';
        NewZealanddollarLbl: Label 'New Zealand dollar';
        PhilippinespesoLbl: Label 'Philippines peso';
        PolishzlotyLbl: Label 'Polish zloty';
        RussianrubleLbl: Label 'Russian ruble';
        SwedishkronaLbl: Label 'Swedish krona';
        SingaporedollarLbl: Label 'Singapore dollar';
        SaudiArabianryialLbl: Label 'Saudi Arabian ryial';
        SolomonIslandsdollarLbl: Label 'Solomon Islands dollar';
        ThaibahtLbl: Label 'Thai baht';
        USdollarLbl: Label 'US dollar';
        VanuatuvatuLbl: Label 'Vanuatu vatu';
        WesternSamoantalaLbl: Label 'Western Samoan tala';
        SouthAfricanrandLbl: Label 'South African rand';
        UnitedArabEmiratesdirhamLbl: Label 'United Arab Emirates dirham';
        AlgeriandinarLbl: Label 'Algerian dinar';
        HungarianforintLbl: Label 'Hungarian forint';
        KenyanShillingLbl: Label 'Kenyan Shilling';
        MoroccandirhamLbl: Label 'Moroccan dirham';
        MozambiquemeticalLbl: Label 'Mozambique metical';
        NigeriannairaLbl: Label 'Nigerian naira';
        RomanianleuLbl: Label 'Romanian leu';
        SwazilandlilangeniLbl: Label 'Swaziland lilangeni';
        SerbianDinarLbl: Label 'Serbian Dinar';
        TunesiandinarLbl: Label 'Tunesian dinar';
        UgandanShillingLbl: Label 'Ugandan Shilling';
        NewTurkishliraLbl: Label 'New Turkish lira';
        TonganPaangaLbl: Label 'Tongan Pa anga';
        FrenchPacificFrancLbl: Label 'French Pacific Franc';
}