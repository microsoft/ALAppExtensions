codeunit 5205 "Create Country/Region"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Description = 'Should contain all country or region where BC is available, updated as of 2024-08-26.';

    trigger OnRun()
    var
        ContosoCountryOrRegion: Codeunit "Contoso Country Or Region";
    begin
        ContosoCountryOrRegion.InsertCountryOrRegion(AE(), UnitedArabEmiratesLbl, '784', '', '', Enum::"Country/Region Address Format"::"City+Post Code", 1, '', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(AT(), AustriaLbl, '040', ATTok, ATTok, Enum::"Country/Region Address Format"::"Blank Line+Post Code+City", 1, '0007', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(AU(), AustraliaLbl, '036', '', '', Enum::"Country/Region Address Format"::"City+County+Post Code", 1, '', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(BE(), BelgiumLbl, '056', BETok, BETok, Enum::"Country/Region Address Format"::"Post Code+City", 1, '9925', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(BG(), BulgariaLbl, '100', BGTok, BGTok, Enum::"Country/Region Address Format"::"City+County+Post Code", 1, '9926', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(BN(), BruneiDarussalamLbl, '096', '', '', Enum::"Country/Region Address Format"::"City+Post Code", 0, '', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(BR(), BrazilLbl, '076', '', '', Enum::"Country/Region Address Format"::"City+Post Code", 0, '', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(CA(), CanadaLbl, '124', '', '', Enum::"Country/Region Address Format"::"City+County+Post Code", 1, '', 'Province');
        ContosoCountryOrRegion.InsertCountryOrRegion(CH(), SwitzerlandLbl, '756', '', '', Enum::"Country/Region Address Format"::"Post Code+City", 1, '', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(CN(), ChinaLbl, '156', '', '', Enum::"Country/Region Address Format"::"Post Code+City", 0, '', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(CR(), CostaRicaLbl, '188', '', '', Enum::"Country/Region Address Format"::"Post Code+City", 0, '', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(CY(), CyprusLbl, '196', CYTok, CYTok, Enum::"Country/Region Address Format"::"Post Code+City", 1, '9928', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(CZ(), CzechiaLbl, '203', CZTok, CZTok, Enum::"Country/Region Address Format"::"Post Code+City", 1, '9929', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(DE(), GermanyLbl, '276', DETok, DETok, Enum::"Country/Region Address Format"::"Blank Line+Post Code+City", 1, '9930', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(DK(), DenmarkLbl, '208', DKTok, DKTok, Enum::"Country/Region Address Format"::"Post Code+City", 1, '0184', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(DZ(), AlgeriaLbl, '012', '', '', Enum::"Country/Region Address Format"::"Post Code+City", 1, '', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(EE(), EstoniaLbl, '233', EETok, EETok, Enum::"Country/Region Address Format"::"Post Code+City", 1, '9931', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(EL(), GreeceLbl, '300', ELTok, ELTok, Enum::"Country/Region Address Format"::"Post Code+City", 1, '', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(ES(), SpainLbl, '724', ESTok, ESTok, Enum::"Country/Region Address Format"::"Post Code+City", 1, '9920', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(FI(), FinlandLbl, '246', FITok, FITok, Enum::"Country/Region Address Format"::"Post Code+City", 1, '', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(FJ(), FijiIslandsLbl, '242', '', '', Enum::"Country/Region Address Format"::"City+Post Code", 0, '', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(FR(), FranceLbl, '250', FRTok, FRTok, Enum::"Country/Region Address Format"::"Post Code+City", 1, '0009', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(GB(), GreatBritainLbl, '826', '', GBTok, Enum::"Country/Region Address Format"::"City+County+Post Code", 1, '9932', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(HR(), CroatiaLbl, '191', HRTok, HRTok, Enum::"Country/Region Address Format"::"Post Code+City", 1, '9934', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(HU(), HungaryLbl, '348', HUTok, HUTok, Enum::"Country/Region Address Format"::"City+Post Code", 1, '9910', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(ID(), IndonesiaLbl, '360', '', '', Enum::"Country/Region Address Format"::"Post Code+City", 1, '', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(IE(), IrelandLbl, '372', IETok, IETok, Enum::"Country/Region Address Format"::"City+County+Post Code", 1, '9935', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(IND(), IndiaLbl, '356', '', '', Enum::"Country/Region Address Format"::"City+Post Code", 0, '', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(IS(), IcelandLbl, '352', '', '', Enum::"Country/Region Address Format"::"Post Code+City", 1, '', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(IT(), ItalyLbl, '380', ITTok, ITTok, Enum::"Country/Region Address Format"::"Post Code+City", 1, '0097', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(JP(), JapanLbl, '392', '', '', Enum::"Country/Region Address Format"::"City+Post Code", 0, '', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(KE(), KenyaLbl, '404', '', '', Enum::"Country/Region Address Format"::"Post Code+City", 1, '', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(LT(), LithuaniaLbl, '440', LTTok, LTTok, Enum::"Country/Region Address Format"::"Post Code+City", 1, '0200', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(LU(), LuxembourgLbl, '442', LUTok, LUTok, Enum::"Country/Region Address Format"::"Post Code+City", 1, '9938', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(LV(), LatviaLbl, '428', LVTok, LVTok, Enum::"Country/Region Address Format"::"Post Code+City", 1, '9939', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(MA(), MoroccoLbl, '504', '', '', Enum::"Country/Region Address Format"::"Post Code+City", 1, '', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(ME(), MontenegroLbl, '499', '', '', Enum::"Country/Region Address Format"::"Post Code+City", 1, '9941', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(MT(), MaltaLbl, '470', MTTok, MTTok, Enum::"Country/Region Address Format"::"Post Code+City", 1, '9943', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(MX(), MexicoLbl, '484', '', '', Enum::"Country/Region Address Format"::"City+County+Post Code", 1, '', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(MY(), MalaysiaLbl, '458', '', '', Enum::"Country/Region Address Format"::"Post Code+City", 1, '', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(MZ(), MozambiqueLbl, '508', '', '', Enum::"Country/Region Address Format"::"Post Code+City", 1, '', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(NG(), NigeriaLbl, '566', '', '', Enum::"Country/Region Address Format"::"City+Post Code", 1, '', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(NI(), NothernIrelandLbl, CopyStr(GB(), 1, 2), '826', GBNTok, GBNTok, Enum::"Country/Region Address Format"::"City+County+Post Code", 1, '9932', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(NL(), NetherlandsLbl, '528', NLTok, NLTok, Enum::"Country/Region Address Format"::"Post Code+City", 1, '9944', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(NO(), NorwayLbl, '578', '', '', Enum::"Country/Region Address Format"::"Post Code+City", 1, '0192', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(NZ(), NewZealandLbl, '554', '', '', Enum::"Country/Region Address Format"::"City+Post Code", 1, '', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(PH(), PhilippinesLbl, '608', '', '', Enum::"Country/Region Address Format"::"Post Code+City", 1, '', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(PL(), PolandLbl, '616', PLTok, PLTok, Enum::"Country/Region Address Format"::"Post Code+City", 1, '9945', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(PT(), PortugalLbl, '620', PTTok, PTTok, Enum::"Country/Region Address Format"::"Post Code+City", 1, '9946', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(RO(), RomaniaLbl, '642', ROTok, ROTok, Enum::"Country/Region Address Format"::"Post Code+City", 1, '9947', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(RS(), SerbiaLbl, '688', '', '', Enum::"Country/Region Address Format"::"Post Code+City", 1, '9948', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(RU(), RussiaLbl, '643', '', '', Enum::"Country/Region Address Format"::"City+Post Code", 2, '', 'Region');
        ContosoCountryOrRegion.InsertCountryOrRegion(SA(), SaudiArabiaLbl, '682', '', '', Enum::"Country/Region Address Format"::"City+Post Code", 0, '', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(SB(), SolomonIslandsLbl, '090', '', '', Enum::"Country/Region Address Format"::"City+Post Code", 0, '', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(SE(), SwedenLbl, '752', SETok, SETok, Enum::"Country/Region Address Format"::"Post Code+City", 1, '9955', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(SG(), SingaporeLbl, '702', '', '', Enum::"Country/Region Address Format"::"City+Post Code", 1, '', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(SI(), SloveniaLbl, '705', SITok, SITok, Enum::"Country/Region Address Format"::"Post Code+City", 1, '9949', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(SK(), SlovakiaLbl, '703', SKTok, SKTok, Enum::"Country/Region Address Format"::"Post Code+City", 1, '9950', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(SZ(), SwazilandLbl, '748', '', '', Enum::"Country/Region Address Format"::"City+Post Code", 1, '', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(TH(), ThailandLbl, '764', '', '', Enum::"Country/Region Address Format"::"Post Code+City", 1, '', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(TN(), TunisiaLbl, '788', '', '', Enum::"Country/Region Address Format"::"Post Code+City", 1, '', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(TR(), TürkiyeLbl, '792', '', '', Enum::"Country/Region Address Format"::"Post Code+City", 0, '9952', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(TZ(), TanzaniaLbl, '834', '', '', Enum::"Country/Region Address Format"::"Post Code+City", 1, '', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(UG(), UgandaLbl, '800', '', '', Enum::"Country/Region Address Format"::"City+Post Code", 1, '', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(US(), USALbl, '840', '', '', Enum::"Country/Region Address Format"::"City+County+Post Code", 1, '', 'State');
        ContosoCountryOrRegion.InsertCountryOrRegion(VU(), VanuatuLbl, '548', '', '', Enum::"Country/Region Address Format"::"City+Post Code", 0, '', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(WS(), SamoaLbl, '882', '', '', Enum::"Country/Region Address Format"::"City+Post Code", 0, '', '');
        ContosoCountryOrRegion.InsertCountryOrRegion(ZA(), SouthAfricaLbl, '710', '', '', Enum::"Country/Region Address Format"::"City+Post Code", 0, '', '');
    end;

    procedure AE(): Code[10]
    begin
        exit(AETok);
    end;

    procedure AT(): Code[10]
    begin
        exit(ATTok);
    end;

    procedure AU(): Code[10]
    begin
        exit(AUTok);
    end;

    procedure BE(): Code[10]
    begin
        exit(BETok);
    end;

    procedure BG(): Code[10]
    begin
        exit(BGTok);
    end;

    procedure BN(): Code[10]
    begin
        exit(BNTok);
    end;

    procedure BR(): Code[10]
    begin
        exit(BRTok);
    end;

    procedure CA(): Code[10]
    begin
        exit(CATok);
    end;

    procedure CH(): Code[10]
    begin
        exit(CHTok);
    end;

    procedure CN(): Code[10]
    begin
        exit(CNTok);
    end;

    procedure CR(): Code[10]
    begin
        exit(CRTok);
    end;

    procedure CY(): Code[10]
    begin
        exit(CYTok);
    end;

    procedure CZ(): Code[10]
    begin
        exit(CZTok);
    end;

    procedure DE(): Code[10]
    begin
        exit(DETok);
    end;

    procedure DK(): Code[10]
    begin
        exit(DKTok);
    end;

    procedure DZ(): Code[10]
    begin
        exit(DZTok);
    end;

    procedure EE(): Code[10]
    begin
        exit(EETok);
    end;

    procedure EL(): Code[10]
    begin
        exit(ELTok);
    end;

    procedure ES(): Code[10]
    begin
        exit(ESTok);
    end;

    procedure FI(): Code[10]
    begin
        exit(FITok);
    end;

    procedure FJ(): Code[10]
    begin
        exit(FJTok);
    end;

    procedure FR(): Code[10]
    begin
        exit(FRTok);
    end;

    procedure GB(): Code[10]
    begin
        exit(GBTok);
    end;

    procedure HR(): Code[10]
    begin
        exit(HRTok);
    end;

    procedure HU(): Code[10]
    begin
        exit(HUTok);
    end;

    procedure ID(): Code[10]
    begin
        exit(IDTok);
    end;

    procedure IE(): Code[10]
    begin
        exit(IETok);
    end;

    procedure IND(): Code[10]
    begin
        exit(INTok);
    end;

    procedure IS(): Code[10]
    begin
        exit(ISTok);
    end;

    procedure IT(): Code[10]
    begin
        exit(ITTok);
    end;

    procedure JP(): Code[10]
    begin
        exit(JPTok);
    end;

    procedure KE(): Code[10]
    begin
        exit(KETok);
    end;

    procedure LT(): Code[10]
    begin
        exit(LTTok);
    end;

    procedure LU(): Code[10]
    begin
        exit(LUTok);
    end;

    procedure LV(): Code[10]
    begin
        exit(LVTok);
    end;

    procedure MA(): Code[10]
    begin
        exit(MATok);
    end;

    procedure ME(): Code[10]
    begin
        exit(METok);
    end;

    procedure MT(): Code[10]
    begin
        exit(MTTok);
    end;

    procedure MX(): Code[10]
    begin
        exit(MXTok);
    end;

    procedure MY(): Code[10]
    begin
        exit(MYTok);
    end;

    procedure MZ(): Code[10]
    begin
        exit(MZTok);
    end;

    procedure NG(): Code[10]
    begin
        exit(NGTok);
    end;

    procedure NI(): Code[10]
    begin
        exit(NITok);
    end;

    procedure NL(): Code[10]
    begin
        exit(NLTok);
    end;

    procedure NO(): Code[10]
    begin
        exit(NOTok);
    end;

    procedure NZ(): Code[10]
    begin
        exit(NZTok);
    end;

    procedure PH(): Code[10]
    begin
        exit(PHTok);
    end;

    procedure PL(): Code[10]
    begin
        exit(PLTok);
    end;

    procedure PT(): Code[10]
    begin
        exit(PTTok);
    end;

    procedure RO(): Code[10]
    begin
        exit(ROTok);
    end;

    procedure RS(): Code[10]
    begin
        exit(RSTok);
    end;

    procedure RU(): Code[10]
    begin
        exit(RUTok);
    end;

    procedure SA(): Code[10]
    begin
        exit(SATok);
    end;

    procedure SB(): Code[10]
    begin
        exit(SBTok);
    end;

    procedure SE(): Code[10]
    begin
        exit(SETok);
    end;

    procedure SG(): Code[10]
    begin
        exit(SGTok);
    end;

    procedure SI(): Code[10]
    begin
        exit(SITok);
    end;

    procedure SK(): Code[10]
    begin
        exit(SKTok);
    end;

    procedure SZ(): Code[10]
    begin
        exit(SZTok);
    end;

    procedure TH(): Code[10]
    begin
        exit(THTok);
    end;

    procedure TN(): Code[10]
    begin
        exit(TNTok);
    end;

    procedure TR(): Code[10]
    begin
        exit(TRTok);
    end;

    procedure TZ(): Code[10]
    begin
        exit(TZTok);
    end;

    procedure UG(): Code[10]
    begin
        exit(UGTok);
    end;

    procedure US(): Code[10]
    begin
        exit(USTok);
    end;

    procedure VU(): Code[10]
    begin
        exit(VUTok);
    end;

    procedure WS(): Code[10]
    begin
        exit(WSTok);
    end;

    procedure ZA(): Code[10]
    begin
        exit(ZATok);
    end;

    var
        AETok: Label 'AE', MaxLength = 10, Locked = true;
        ATTok: Label 'AT', MaxLength = 10, Locked = true;
        AUTok: Label 'AU', MaxLength = 10, Locked = true;
        BETok: Label 'BE', MaxLength = 10, Locked = true;
        BGTok: Label 'BG', MaxLength = 10, Locked = true;
        BNTok: Label 'BN', MaxLength = 10, Locked = true;
        BRTok: Label 'BR', MaxLength = 10, Locked = true;
        CATok: Label 'CA', MaxLength = 10, Locked = true;
        CHTok: Label 'CH', MaxLength = 10, Locked = true;
        CNTok: Label 'CN', MaxLength = 10, Locked = true;
        CRTok: Label 'CR', MaxLength = 10, Locked = true;
        CYTok: Label 'CY', MaxLength = 10, Locked = true;
        CZTok: Label 'CZ', MaxLength = 10, Locked = true;
        DETok: Label 'DE', MaxLength = 10, Locked = true;
        DKTok: Label 'DK', MaxLength = 10, Locked = true;
        DZTok: Label 'DZ', MaxLength = 10, Locked = true;
        EETok: Label 'EE', MaxLength = 10, Locked = true;
        ELTok: Label 'EL', MaxLength = 10, Locked = true;
        ESTok: Label 'ES', MaxLength = 10, Locked = true;
        FITok: Label 'FI', MaxLength = 10, Locked = true;
        FJTok: Label 'FJ', MaxLength = 10, Locked = true;
        FRTok: Label 'FR', MaxLength = 10, Locked = true;
        GBTok: Label 'GB', MaxLength = 10, Locked = true;
        HRTok: Label 'HR', MaxLength = 10, Locked = true;
        HUTok: Label 'HU', MaxLength = 10, Locked = true;
        IDTok: Label 'ID', MaxLength = 10, Locked = true;
        IETok: Label 'IE', MaxLength = 10, Locked = true;
        INTok: Label 'IN', MaxLength = 10, Locked = true;
        ISTok: Label 'IS', MaxLength = 10, Locked = true;
        ITTok: Label 'IT', MaxLength = 10, Locked = true;
        JPTok: Label 'JP', MaxLength = 10, Locked = true;
        KETok: Label 'KE', MaxLength = 10, Locked = true;
        LTTok: Label 'LT', MaxLength = 10, Locked = true;
        LUTok: Label 'LU', MaxLength = 10, Locked = true;
        LVTok: Label 'LV', MaxLength = 10, Locked = true;
        MATok: Label 'MA', MaxLength = 10, Locked = true;
        METok: Label 'ME', MaxLength = 10, Locked = true;
        MTTok: Label 'MT', MaxLength = 10, Locked = true;
        MXTok: Label 'MX', MaxLength = 10, Locked = true;
        MYTok: Label 'MY', MaxLength = 10, Locked = true;
        MZTok: Label 'MZ', MaxLength = 10, Locked = true;
        NGTok: Label 'NG', MaxLength = 10, Locked = true;
        NITok: Label 'NI', MaxLength = 10, Locked = true;
        NLTok: Label 'NL', MaxLength = 10, Locked = true;
        NOTok: Label 'NO', MaxLength = 10, Locked = true;
        NZTok: Label 'NZ', MaxLength = 10, Locked = true;
        PHTok: Label 'PH', MaxLength = 10, Locked = true;
        PLTok: Label 'PL', MaxLength = 10, Locked = true;
        PTTok: Label 'PT', MaxLength = 10, Locked = true;
        ROTok: Label 'RO', MaxLength = 10, Locked = true;
        RSTok: Label 'RS', MaxLength = 10, Locked = true;
        RUTok: Label 'RU', MaxLength = 10, Locked = true;
        SATok: Label 'SA', MaxLength = 10, Locked = true;
        SBTok: Label 'SB', MaxLength = 10, Locked = true;
        SETok: Label 'SE', MaxLength = 10, Locked = true;
        SGTok: Label 'SG', MaxLength = 10, Locked = true;
        SITok: Label 'SI', MaxLength = 10, Locked = true;
        SKTok: Label 'SK', MaxLength = 10, Locked = true;
        SZTok: Label 'SZ', MaxLength = 10, Locked = true;
        THTok: Label 'TH', MaxLength = 10, Locked = true;
        TNTok: Label 'TN', MaxLength = 10, Locked = true;
        TRTok: Label 'TR', MaxLength = 10, Locked = true;
        TZTok: Label 'TZ', MaxLength = 10, Locked = true;
        UGTok: Label 'UG', MaxLength = 10, Locked = true;
        USTok: Label 'US', MaxLength = 10, Locked = true;
        VUTok: Label 'VU', MaxLength = 10, Locked = true;
        WSTok: Label 'WS', MaxLength = 10, Locked = true;
        ZATok: Label 'ZA', MaxLength = 10, Locked = true;
        GBNTok: Label 'GBN', MaxLength = 10, Locked = true;
        UnitedArabEmiratesLbl: Label 'United Arab Emirates', MaxLength = 50;
        AustriaLbl: Label 'Austria', MaxLength = 50;
        AustraliaLbl: Label 'Australia', MaxLength = 50;
        BelgiumLbl: Label 'Belgium', MaxLength = 50;
        BulgariaLbl: Label 'Bulgaria', MaxLength = 50;
        BruneiDarussalamLbl: Label 'Brunei Darussalam', MaxLength = 50;
        BrazilLbl: Label 'Brazil', MaxLength = 50;
        CanadaLbl: Label 'Canada', MaxLength = 50;
        SwitzerlandLbl: Label 'Switzerland', MaxLength = 50;
        ChinaLbl: Label 'China', MaxLength = 50;
        CostaRicaLbl: Label 'Costa Rica', MaxLength = 50;
        CyprusLbl: Label 'Cyprus', MaxLength = 50;
        CzechiaLbl: Label 'Czechia', MaxLength = 50;
        GermanyLbl: Label 'Germany', MaxLength = 50;
        DenmarkLbl: Label 'Denmark', MaxLength = 50;
        AlgeriaLbl: Label 'Algeria', MaxLength = 50;
        EstoniaLbl: Label 'Estonia', MaxLength = 50;
        GreeceLbl: Label 'Greece', MaxLength = 50;
        SpainLbl: Label 'Spain', MaxLength = 50;
        FinlandLbl: Label 'Finland', MaxLength = 50;
        FijiIslandsLbl: Label 'Fiji Islands', MaxLength = 50;
        FranceLbl: Label 'France', MaxLength = 50;
        GreatBritainLbl: Label 'Great Britain', MaxLength = 50;
        CroatiaLbl: Label 'Croatia', MaxLength = 50;
        HungaryLbl: Label 'Hungary', MaxLength = 50;
        IndonesiaLbl: Label 'Indonesia', MaxLength = 50;
        IrelandLbl: Label 'Ireland', MaxLength = 50;
        IndiaLbl: Label 'India', MaxLength = 50;
        IcelandLbl: Label 'Iceland', MaxLength = 50;
        ItalyLbl: Label 'Italy', MaxLength = 50;
        JapanLbl: Label 'Japan', MaxLength = 50;
        KenyaLbl: Label 'Kenya', MaxLength = 50;
        LithuaniaLbl: Label 'Lithuania', MaxLength = 50;
        LuxembourgLbl: Label 'Luxembourg', MaxLength = 50;
        LatviaLbl: Label 'Latvia', MaxLength = 50;
        MoroccoLbl: Label 'Morocco', MaxLength = 50;
        MontenegroLbl: Label 'Montenegro', MaxLength = 50;
        MaltaLbl: Label 'Malta', MaxLength = 50;
        MexicoLbl: Label 'Mexico', MaxLength = 50;
        MalaysiaLbl: Label 'Malaysia', MaxLength = 50;
        MozambiqueLbl: Label 'Mozambique', MaxLength = 50;
        NigeriaLbl: Label 'Nigeria', MaxLength = 50;
        NothernIrelandLbl: Label 'Nothern Ireland', MaxLength = 50;
        NetherlandsLbl: Label 'Netherlands', MaxLength = 50;
        NorwayLbl: Label 'Norway', MaxLength = 50;
        NewZealandLbl: Label 'New Zealand', MaxLength = 50;
        PhilippinesLbl: Label 'Philippines', MaxLength = 50;
        PolandLbl: Label 'Poland', MaxLength = 50;
        PortugalLbl: Label 'Portugal', MaxLength = 50;
        RomaniaLbl: Label 'Romania', MaxLength = 50;
        SerbiaLbl: Label 'Serbia', MaxLength = 50;
        RussiaLbl: Label 'Russia', MaxLength = 50;
        SaudiArabiaLbl: Label 'Saudi Arabia', MaxLength = 50;
        SolomonIslandsLbl: Label 'Solomon Islands', MaxLength = 50;
        SwedenLbl: Label 'Sweden', MaxLength = 50;
        SingaporeLbl: Label 'Singapore', MaxLength = 50;
        SloveniaLbl: Label 'Slovenia', MaxLength = 50;
        SlovakiaLbl: Label 'Slovakia', MaxLength = 50;
        SwazilandLbl: Label 'Swaziland', MaxLength = 50;
        ThailandLbl: Label 'Thailand', MaxLength = 50;
        TunisiaLbl: Label 'Tunisia', MaxLength = 50;
        TürkiyeLbl: Label 'Türkiye', MaxLength = 50;
        TanzaniaLbl: Label 'Tanzania', MaxLength = 50;
        UgandaLbl: Label 'Uganda', MaxLength = 50;
        USALbl: Label 'USA', MaxLength = 50;
        VanuatuLbl: Label 'Vanuatu', MaxLength = 50;
        SamoaLbl: Label 'Samoa', MaxLength = 50;
        SouthAfricaLbl: Label 'South Africa', MaxLength = 50;

}