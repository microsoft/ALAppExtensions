// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.Finance.Currency;
using Microsoft.DemoTool.Helpers;
using Microsoft.DemoTool;

codeunit 5525 "Create Currency"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        Currency: Record "Currency";
        CreateGLAccount: Codeunit "Create G/L Account";
        ContosoCurrency: Codeunit "Contoso Currency";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        ContosoCurrency.InsertCurrency(AED(), '784', UnitedArabEmiratesdirhamLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.25, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        if ContosoCoffeeDemoDataSetup."Country/Region Code" <> 'AU' then
            ContosoCurrency.InsertCurrency(AUD(), '036', AustralianDollarLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(BGN(), '975', BulgarianLevaLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(BND(), '096', BruneiDarussalemDollarLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(BRL(), '986', BrazilianRealLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        if ContosoCoffeeDemoDataSetup."Country/Region Code" <> 'CA' then
            ContosoCurrency.InsertCurrency(CAD(), '124', CanadianDollarLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        if ContosoCoffeeDemoDataSetup."Country/Region Code" <> 'CH' then
            ContosoCurrency.InsertCurrency(CHF(), '756', SwissFrancLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        if ContosoCoffeeDemoDataSetup."Country/Region Code" <> 'CZ' then
            ContosoCurrency.InsertCurrency(CZK(), '203', CzechKorunaLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        if ContosoCoffeeDemoDataSetup."Country/Region Code" <> 'DK' then
            ContosoCurrency.InsertCurrency(DKK(), '208', DanishkroneLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(DZD(), '012', AlgerianDinarLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        if not (ContosoCoffeeDemoDataSetup."Country/Region Code" in ['AT', 'BE', 'DE', 'ES', 'FI', 'FR', 'IT', 'NL']) then
            ContosoCurrency.InsertCurrency(EUR(), '978', EuroLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, true, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(FJD(), '242', FijiDollarLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        if not (ContosoCoffeeDemoDataSetup."Country/Region Code" in ['GB', 'W1']) then
            ContosoCurrency.InsertCurrency(GBP(), '826', BritishPoundLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(HKD(), '344', HongKongDollarLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(HRK(), '191', CroatianKunaLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(HUF(), '348', HungarianForintLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 1, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(IDR(), '360', IndonesianRupiahLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 1, Currency."Invoice Rounding Type"::Nearest, 1, 0.1, false, '0:0', '0:3');
        if ContosoCoffeeDemoDataSetup."Country/Region Code" <> 'IN' then
            ContosoCurrency.InsertCurrency(INR(), '356', IndianRupeeLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        if ContosoCoffeeDemoDataSetup."Country/Region Code" <> 'IS' then
            ContosoCurrency.InsertCurrency(ISK(), '352', IcelandicKronaLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(JPY(), '392', JapaneseYenLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(KES(), '404', KenyanShillingLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.5, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(MAD(), '504', MoroccanDirhamLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        if ContosoCoffeeDemoDataSetup."Country/Region Code" <> 'MX' then
            ContosoCurrency.InsertCurrency(MXN(), '484', MexicanPesoLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(MYR(), '458', MalaysianRinggitLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(MZN(), '943', MozambiqueMeticalLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 10, Currency."Invoice Rounding Type"::Nearest, 1, 0.01, false, '0:0', '0:3');
        ContosoCurrency.InsertCurrency(NGN(), '566', NigerianNairaLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 1, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        if ContosoCoffeeDemoDataSetup."Country/Region Code" <> 'NO' then
            ContosoCurrency.InsertCurrency(NOK(), '578', NorwegianKroneLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        if ContosoCoffeeDemoDataSetup."Country/Region Code" <> 'NZ' then
            ContosoCurrency.InsertCurrency(NZD(), '554', NewZealandDollarLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(PHP(), '608', PhilippinesPesoLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(PLN(), '985', PolishZlotyLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(RON(), '946', RomanianLeuLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.01, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(RSD(), '941', SerbianDinarLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(RUB(), '643', RussianRubleLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(SAR(), '682', SaudiArabianRyialLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(SBD(), '090', SolomonIslandsDollarLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        if ContosoCoffeeDemoDataSetup."Country/Region Code" <> 'SE' then
            ContosoCurrency.InsertCurrency(SEK(), '752', SwedishKronaLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(SGD(), '702', SingaporeDollarLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(SZL(), '748', SwazilandLilangeniLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(THB(), '764', ThaiBahtLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 1, Currency."Invoice Rounding Type"::Nearest, 1, 1, false, '0:0', '0:3');
        ContosoCurrency.InsertCurrency(TND(), '788', TunesianDinarLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.001, 0.001, false, '3:3', '2:5');
        ContosoCurrency.InsertCurrency(TOP(), '776', TonganPaangaLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(TRY(), '949', NewTurkishLiraLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.001, false, '2:2', '2:5');
        ContosoCurrency.InsertCurrency(UGX(), '800', UgandanShillingLbl, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses(), 1, Currency."Invoice Rounding Type"::Nearest, 1, 0.1, false, '0:0', '0:3');
        if ContosoCoffeeDemoDataSetup."Country/Region Code" <> 'US' then
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
        EuroLbl: Label 'Euro', MaxLength = 30;
        AustraliandollarLbl: Label 'Australian dollar', MaxLength = 30;
        BulgarianlevaLbl: Label 'Bulgarian leva', MaxLength = 30;
        BruneiDarussalemdollarLbl: Label 'Brunei Darussalem dollar', MaxLength = 30;
        BrazilianrealLbl: Label 'Brazilian real', MaxLength = 30;
        CanadiandollarLbl: Label 'Canadian dollar', MaxLength = 30;
        CroatianKunaLbl: Label 'Croatian Kuna', MaxLength = 30;
        SwissfrancLbl: Label 'Swiss franc', MaxLength = 30;
        CzechkorunaLbl: Label 'Czech koruna', MaxLength = 30;
        DanishkroneLbl: Label 'Danish krone', MaxLength = 30;
        FijidollarLbl: Label 'Fiji dollar', MaxLength = 30;
        BritishpoundLbl: Label 'Pound Sterling', MaxLength = 30;
        HongKongdollarLbl: Label 'Hong Kong dollar', MaxLength = 30;
        IndonesianrupiahLbl: Label 'Indonesian rupiah', MaxLength = 30;
        JapaneseyenLbl: Label 'Japanese yen', MaxLength = 30;
        IndianrupeeLbl: Label 'Indian rupee', MaxLength = 30;
        IcelandickronaLbl: Label 'Icelandic krona', MaxLength = 30;
        MalaysianringgitLbl: Label 'Malaysian ringgit', MaxLength = 30;
        MexicanpesoLbl: Label 'Mexican peso', MaxLength = 30;
        NorwegiankroneLbl: Label 'Norwegian krone', MaxLength = 30;
        NewZealanddollarLbl: Label 'New Zealand dollar', MaxLength = 30;
        PhilippinespesoLbl: Label 'Philippines peso', MaxLength = 30;
        PolishzlotyLbl: Label 'Polish zloty', MaxLength = 30;
        RussianrubleLbl: Label 'Russian ruble', MaxLength = 30;
        SwedishkronaLbl: Label 'Swedish krona', MaxLength = 30;
        SingaporedollarLbl: Label 'Singapore dollar', MaxLength = 30;
        SaudiArabianryialLbl: Label 'Saudi Arabian ryial', MaxLength = 30;
        SolomonIslandsdollarLbl: Label 'Solomon Islands dollar', MaxLength = 30;
        ThaibahtLbl: Label 'Thai baht', MaxLength = 30;
        USdollarLbl: Label 'US dollar', MaxLength = 30;
        VanuatuvatuLbl: Label 'Vanuatu vatu', MaxLength = 30;
        WesternSamoantalaLbl: Label 'Western Samoan tala', MaxLength = 30;
        SouthAfricanrandLbl: Label 'South African rand', MaxLength = 30;
        UnitedArabEmiratesdirhamLbl: Label 'United Arab Emirates dirham', MaxLength = 30;
        AlgeriandinarLbl: Label 'Algerian dinar', MaxLength = 30;
        HungarianforintLbl: Label 'Hungarian forint', MaxLength = 30;
        KenyanShillingLbl: Label 'Kenyan Shilling', MaxLength = 30;
        MoroccandirhamLbl: Label 'Moroccan dirham', MaxLength = 30;
        MozambiquemeticalLbl: Label 'Mozambique metical', MaxLength = 30;
        NigeriannairaLbl: Label 'Nigerian naira', MaxLength = 30;
        RomanianleuLbl: Label 'Romanian leu', MaxLength = 30;
        SwazilandlilangeniLbl: Label 'Swaziland lilangeni', MaxLength = 30;
        SerbianDinarLbl: Label 'Serbian Dinar', MaxLength = 30;
        TunesiandinarLbl: Label 'Tunesian dinar', MaxLength = 30;
        UgandanShillingLbl: Label 'Ugandan Shilling', MaxLength = 30;
        NewTurkishliraLbl: Label 'New Turkish lira', MaxLength = 30;
        TonganPaangaLbl: Label 'Tongan Pa anga', MaxLength = 30;
        FrenchPacificFrancLbl: Label 'French Pacific Franc', MaxLength = 30;
}
