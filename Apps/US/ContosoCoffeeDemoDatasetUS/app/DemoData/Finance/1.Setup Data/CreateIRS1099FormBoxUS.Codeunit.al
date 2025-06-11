#if not CLEAN27
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;

codeunit 11451 "Create IRS 1099 Form-Box US"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    ObsoleteReason = 'Moved to IRS Forms App.';
    ObsoleteState = Pending;
    ObsoleteTag = '27.0';

    trigger OnRun()
    var
        ContosoIRS1099US: Codeunit "Contoso IRS 1099 US";
    begin
        ContosoIRS1099US.InsertIRS1099FormBox(BTok, ProceedsFromBrokerBarterExchangeTransactionsLbl, 0);
        ContosoIRS1099US.InsertIRS1099FormBox(B02Tok, StocksbondsetcLbl, 0);
        ContosoIRS1099US.InsertIRS1099FormBox(B03Tok, BarteringLbl, 0);
        ContosoIRS1099US.InsertIRS1099FormBox(B04Tok, FederalincometaxwithheldLbl, 0);
        ContosoIRS1099US.InsertIRS1099FormBox(B06Tok, ProfitlossrealizedthisyearLbl, 0);
        ContosoIRS1099US.InsertIRS1099FormBox(B07Tok, UnrealprofitlossonopencontractslastyearLbl, 0);
        ContosoIRS1099US.InsertIRS1099FormBox(B08Tok, UnrealprofitlossonopencontractsthisyearLbl, 0);
        ContosoIRS1099US.InsertIRS1099FormBox(B09Tok, AggregateprofitlossLbl, 0);
        ContosoIRS1099US.InsertIRS1099FormBox(DIVTok, DividendsandDistributionsLbl, 0);
        ContosoIRS1099US.InsertIRS1099FormBox(DIV01ATok, TotalordinarydividendsLbl, 10);
        ContosoIRS1099US.InsertIRS1099FormBox(DIV01BTok, QualifieddividendsLbl, 10);
        ContosoIRS1099US.InsertIRS1099FormBox(DIV02ATok, TotalcapitalgaindistrLbl, 0);
        ContosoIRS1099US.InsertIRS1099FormBox(DIV02BTok, UnrecapSec1250gainLbl, 10);
        ContosoIRS1099US.InsertIRS1099FormBox(DIV02CTok, Section1202gainLbl, 0);
        ContosoIRS1099US.InsertIRS1099FormBox(DIV02DTok, Collectibles28gainLbl, 0);
        ContosoIRS1099US.InsertIRS1099FormBox(DIV02ETok, Section897ordinarydividendsLbl, 0);
        ContosoIRS1099US.InsertIRS1099FormBox(DIV02FTok, Section897capitalgainLbl, 0);
        ContosoIRS1099US.InsertIRS1099FormBox(DIV03Tok, NondividenddistributionsLbl, 10);
        ContosoIRS1099US.InsertIRS1099FormBox(DIV04Tok, FederalincometaxwithheldLbl, -1);
        ContosoIRS1099US.InsertIRS1099FormBox(DIV05Tok, Section199AdividendsLbl, 10);
        ContosoIRS1099US.InsertIRS1099FormBox(DIV06Tok, InvestmentexpensesLbl, 10);
        ContosoIRS1099US.InsertIRS1099FormBox(DIV07Tok, ForeigntaxpaidLbl, -1);
        ContosoIRS1099US.InsertIRS1099FormBox(DIV09Tok, CashliquidationdistributionsLbl, 600);
        ContosoIRS1099US.InsertIRS1099FormBox(DIV10Tok, NoncashliquidationdistributionsLbl, 600);
        ContosoIRS1099US.InsertIRS1099FormBox(DIV12Tok, ExemptinterestdividendsLbl, 0);
        ContosoIRS1099US.InsertIRS1099FormBox(DIV13Tok, SpecifiedprivateactivitybondinterestdividendsLbl, 0);
        ContosoIRS1099US.InsertIRS1099FormBox(INTTok, InterestIncomeLbl, 0);
        ContosoIRS1099US.InsertIRS1099FormBox(INT01Tok, InterestincomeLbl, 10);
        ContosoIRS1099US.InsertIRS1099FormBox(INT02Tok, EarlywithdrawalpenaltyLbl, -1);
        ContosoIRS1099US.InsertIRS1099FormBox(INT03Tok, InterestonUSSavingsBondsandTreasobligationsLbl, 10);
        ContosoIRS1099US.InsertIRS1099FormBox(INT04Tok, FederalincometaxwithheldLbl, -1);
        ContosoIRS1099US.InsertIRS1099FormBox(INT05Tok, InvestmentexpensesLbl, 10);
        ContosoIRS1099US.InsertIRS1099FormBox(INT06Tok, ForeigntaxpaidLbl, -1);
        ContosoIRS1099US.InsertIRS1099FormBox(INT08Tok, TaxexemptinterestLbl, 10);
        ContosoIRS1099US.InsertIRS1099FormBox(INT09Tok, SpecifiedprivateactivitybondinterestLbl, 10);
        ContosoIRS1099US.InsertIRS1099FormBox(INT10Tok, MarketdiscountLbl, 10);
        ContosoIRS1099US.InsertIRS1099FormBox(INT11Tok, BondpremiumLbl, 0.01);
        ContosoIRS1099US.InsertIRS1099FormBox(INT12Tok, BondPremiumonTreasuryObligationLbl, 0.01);
        ContosoIRS1099US.InsertIRS1099FormBox(INT13Tok, BondpremiumontaxexemptbondLbl, 0.01);
        ContosoIRS1099US.InsertIRS1099FormBox(MISCTok, MiscellaneousIncomeLbl, 0);
        ContosoIRS1099US.InsertIRS1099FormBox(MISC01Tok, RentsLbl, 600);
        ContosoIRS1099US.InsertIRS1099FormBox(MISC02Tok, RoyaltiesLbl, 10);
        ContosoIRS1099US.InsertIRS1099FormBox(MISC03Tok, OtherIncomeLbl, 600);
        ContosoIRS1099US.InsertIRS1099FormBox(MISC04Tok, FederalincometaxwithheldLbl, -1);
        ContosoIRS1099US.InsertIRS1099FormBox(MISC05Tok, FishingboatproceedsLbl, 1);
        ContosoIRS1099US.InsertIRS1099FormBox(MISC06Tok, MedicalandhealthcarepaymentsLbl, 600);
        ContosoIRS1099US.InsertIRS1099FormBox(MISC07Tok, Payermadedirectsalesof5000ormoreofconsumerproductsLbl, 5000);
        ContosoIRS1099US.InsertIRS1099FormBox(MISC08Tok, SubstitutepaymentsinlieuofdividendsorinterestLbl, 10);
        ContosoIRS1099US.InsertIRS1099FormBox(MISC09Tok, CropinsuranceproceedsLbl, 1);
        ContosoIRS1099US.InsertIRS1099FormBox(MISC10Tok, GrossproceedspaidtoanattorneyLbl, 0);
        ContosoIRS1099US.InsertIRS1099FormBox(MISC11Tok, FishpurchasedforresaleLbl, 600);
        ContosoIRS1099US.InsertIRS1099FormBox(MISC12Tok, Section409AdeferralsLbl, 600);
        ContosoIRS1099US.InsertIRS1099FormBox(MISC14Tok, ExcessgoldenparachutepaymentsLbl, 0);
        ContosoIRS1099US.InsertIRS1099FormBox(MISC15Tok, NonqualifieddeferredcompensationLbl, 0);
        ContosoIRS1099US.InsertIRS1099FormBox(MISC16Tok, StatetaxwithheldLbl, 0);
        ContosoIRS1099US.InsertIRS1099FormBox(NEC01Tok, NonemployeecompensationLbl, 600);
        ContosoIRS1099US.InsertIRS1099FormBox(NEC02Tok, Payermadedirectsalestotaling5000ormoreofconsumerproductstorecipientforresaleLbl, 5000);
        ContosoIRS1099US.InsertIRS1099FormBox(NEC04Tok, FederalincometaxwithheldLbl, 0);
        ContosoIRS1099US.InsertIRS1099FormBox(RTok, PensionsAnnRetirementProfitSharPlansIRAsLbl, 0);
        ContosoIRS1099US.InsertIRS1099FormBox(R01Tok, GrossdistributionLbl, 0);
        ContosoIRS1099US.InsertIRS1099FormBox(R02ATok, TaxableAmountLbl, 0);
        ContosoIRS1099US.InsertIRS1099FormBox(R03Tok, AmountinBox2eligibleforcapitalgainelectionLbl, 0);
        ContosoIRS1099US.InsertIRS1099FormBox(R04Tok, FederalincometaxwithheldLbl, 0);
        ContosoIRS1099US.InsertIRS1099FormBox(R05Tok, EmployeecontributionsinsurancepremiumsLbl, 0);
        ContosoIRS1099US.InsertIRS1099FormBox(R06Tok, NetunrealappreciationinemployerssecuritiesLbl, 0);
        ContosoIRS1099US.InsertIRS1099FormBox(R10Tok, StateincometaxwithheldLbl, 0);
        ContosoIRS1099US.InsertIRS1099FormBox(R12Tok, LocalincometaxwithheldLbl, 0);
        ContosoIRS1099US.InsertIRS1099FormBox(STok, ProceedsFromRealEstateTransactionsLbl, 0);
        ContosoIRS1099US.InsertIRS1099FormBox(S02Tok, GrossproceedsLbl, 0);
    end;

    procedure B(): Code[10]
    begin
        exit(BTok);
    end;

    procedure B02(): Code[10]
    begin
        exit(B02Tok);
    end;

    procedure B03(): Code[10]
    begin
        exit(B03Tok);
    end;

    procedure B04(): Code[10]
    begin
        exit(B04Tok);
    end;

    procedure B06(): Code[10]
    begin
        exit(B06Tok);
    end;

    procedure B07(): Code[10]
    begin
        exit(B07Tok);
    end;

    procedure B08(): Code[10]
    begin
        exit(B08Tok);
    end;

    procedure B09(): Code[10]
    begin
        exit(B09Tok);
    end;

    procedure DIV(): Code[10]
    begin
        exit(DIVTok);
    end;

    procedure DIV01A(): Code[10]
    begin
        exit(DIV01ATok);
    end;

    procedure DIV01B(): Code[10]
    begin
        exit(DIV01BTok);
    end;

    procedure DIV02A(): Code[10]
    begin
        exit(DIV02ATok);
    end;

    procedure DIV02B(): Code[10]
    begin
        exit(DIV02BTok);
    end;

    procedure DIV02C(): Code[10]
    begin
        exit(DIV02CTok);
    end;

    procedure DIV02D(): Code[10]
    begin
        exit(DIV02DTok);
    end;

    procedure DIV02E(): Code[10]
    begin
        exit(DIV02ETok);
    end;

    procedure DIV02F(): Code[10]
    begin
        exit(DIV02FTok);
    end;

    procedure DIV03(): Code[10]
    begin
        exit(DIV03Tok);
    end;

    procedure DIV04(): Code[10]
    begin
        exit(DIV04Tok);
    end;

    procedure DIV05(): Code[10]
    begin
        exit(DIV05Tok);
    end;

    procedure DIV06(): Code[10]
    begin
        exit(DIV06Tok);
    end;

    procedure DIV07(): Code[10]
    begin
        exit(DIV07Tok);
    end;

    procedure DIV09(): Code[10]
    begin
        exit(DIV09Tok);
    end;

    procedure DIV10(): Code[10]
    begin
        exit(DIV10Tok);
    end;

    procedure DIV12(): Code[10]
    begin
        exit(DIV12Tok);
    end;

    procedure DIV13(): Code[10]
    begin
        exit(DIV13Tok);
    end;

    procedure INT(): Code[10]
    begin
        exit(INTTok);
    end;

    procedure INT01(): Code[10]
    begin
        exit(INT01Tok);
    end;

    procedure INT02(): Code[10]
    begin
        exit(INT02Tok);
    end;

    procedure INT03(): Code[10]
    begin
        exit(INT03Tok);
    end;

    procedure INT04(): Code[10]
    begin
        exit(INT04Tok);
    end;

    procedure INT05(): Code[10]
    begin
        exit(INT05Tok);
    end;

    procedure INT06(): Code[10]
    begin
        exit(INT06Tok);
    end;

    procedure INT08(): Code[10]
    begin
        exit(INT08Tok);
    end;

    procedure INT09(): Code[10]
    begin
        exit(INT09Tok);
    end;

    procedure INT10(): Code[10]
    begin
        exit(INT10Tok);
    end;

    procedure INT11(): Code[10]
    begin
        exit(INT11Tok);
    end;

    procedure INT12(): Code[10]
    begin
        exit(INT12Tok);
    end;

    procedure INT13(): Code[10]
    begin
        exit(INT13Tok);
    end;

    procedure MISC(): Code[10]
    begin
        exit(MISCTok);
    end;

    procedure MISC01(): Code[10]
    begin
        exit(MISC01Tok);
    end;

    procedure MISC02(): Code[10]
    begin
        exit(MISC02Tok);
    end;

    procedure MISC03(): Code[10]
    begin
        exit(MISC03Tok);
    end;

    procedure MISC04(): Code[10]
    begin
        exit(MISC04Tok);
    end;

    procedure MISC05(): Code[10]
    begin
        exit(MISC05Tok);
    end;

    procedure MISC06(): Code[10]
    begin
        exit(MISC06Tok);
    end;

    procedure MISC07(): Code[10]
    begin
        exit(MISC07Tok);
    end;

    procedure MISC08(): Code[10]
    begin
        exit(MISC08Tok);
    end;

    procedure MISC09(): Code[10]
    begin
        exit(MISC09Tok);
    end;

    procedure MISC10(): Code[10]
    begin
        exit(MISC10Tok);
    end;

    procedure MISC11(): Code[10]
    begin
        exit(MISC11Tok);
    end;

    procedure MISC12(): Code[10]
    begin
        exit(MISC12Tok);
    end;

    procedure MISC14(): Code[10]
    begin
        exit(MISC14Tok);
    end;

    procedure MISC15(): Code[10]
    begin
        exit(MISC15Tok);
    end;

    procedure MISC16(): Code[10]
    begin
        exit(MISC16Tok);
    end;

    procedure NEC01(): Code[10]
    begin
        exit(NEC01Tok);
    end;

    procedure NEC02(): Code[10]
    begin
        exit(NEC02Tok);
    end;

    procedure NEC04(): Code[10]
    begin
        exit(NEC04Tok);
    end;

    procedure R(): Code[10]
    begin
        exit(RTok);
    end;

    procedure R01(): Code[10]
    begin
        exit(R01Tok);
    end;

    procedure R02A(): Code[10]
    begin
        exit(R02ATok);
    end;

    procedure R03(): Code[10]
    begin
        exit(R03Tok);
    end;

    procedure R04(): Code[10]
    begin
        exit(R04Tok);
    end;

    procedure R05(): Code[10]
    begin
        exit(R05Tok);
    end;

    procedure R06(): Code[10]
    begin
        exit(R06Tok);
    end;

    procedure R10(): Code[10]
    begin
        exit(R10Tok);
    end;

    procedure R12(): Code[10]
    begin
        exit(R12Tok);
    end;

    procedure S(): Code[10]
    begin
        exit(STok);
    end;

    procedure S02(): Code[10]
    begin
        exit(S02Tok);
    end;

    var
        BTok: Label 'B', MaxLength = 10, Locked = true;
        B02Tok: Label 'B-02', MaxLength = 10, Locked = true;
        B03Tok: Label 'B-03', MaxLength = 10, Locked = true;
        B04Tok: Label 'B-04', MaxLength = 10, Locked = true;
        B06Tok: Label 'B-06', MaxLength = 10, Locked = true;
        B07Tok: Label 'B-07', MaxLength = 10, Locked = true;
        B08Tok: Label 'B-08', MaxLength = 10, Locked = true;
        B09Tok: Label 'B-09', MaxLength = 10, Locked = true;
        DIVTok: Label 'DIV', MaxLength = 10, Locked = true;
        DIV01ATok: Label 'DIV-01-A', MaxLength = 10, Locked = true;
        DIV01BTok: Label 'DIV-01-B', MaxLength = 10, Locked = true;
        DIV02ATok: Label 'DIV-02-A', MaxLength = 10, Locked = true;
        DIV02BTok: Label 'DIV-02-B', MaxLength = 10, Locked = true;
        DIV02CTok: Label 'DIV-02-C', MaxLength = 10, Locked = true;
        DIV02DTok: Label 'DIV-02-D', MaxLength = 10, Locked = true;
        DIV02ETok: Label 'DIV-02-E', MaxLength = 10, Locked = true;
        DIV02FTok: Label 'DIV-02-F', MaxLength = 10, Locked = true;
        DIV03Tok: Label 'DIV-03', MaxLength = 10, Locked = true;
        DIV04Tok: Label 'DIV-04', MaxLength = 10, Locked = true;
        DIV05Tok: Label 'DIV-05', MaxLength = 10, Locked = true;
        DIV06Tok: Label 'DIV-06', MaxLength = 10, Locked = true;
        DIV07Tok: Label 'DIV-07', MaxLength = 10, Locked = true;
        DIV09Tok: Label 'DIV-09', MaxLength = 10, Locked = true;
        DIV10Tok: Label 'DIV-10', MaxLength = 10, Locked = true;
        DIV12Tok: Label 'DIV-12', MaxLength = 10, Locked = true;
        DIV13Tok: Label 'DIV-13', MaxLength = 10, Locked = true;
        INTTok: Label 'INT', MaxLength = 10, Locked = true;
        INT01Tok: Label 'INT-01', MaxLength = 10, Locked = true;
        INT02Tok: Label 'INT-02', MaxLength = 10, Locked = true;
        INT03Tok: Label 'INT-03', MaxLength = 10, Locked = true;
        INT04Tok: Label 'INT-04', MaxLength = 10, Locked = true;
        INT05Tok: Label 'INT-05', MaxLength = 10, Locked = true;
        INT06Tok: Label 'INT-06', MaxLength = 10, Locked = true;
        INT08Tok: Label 'INT-08', MaxLength = 10, Locked = true;
        INT09Tok: Label 'INT-09', MaxLength = 10, Locked = true;
        INT10Tok: Label 'INT-10', MaxLength = 10, Locked = true;
        INT11Tok: Label 'INT-11', MaxLength = 10, Locked = true;
        INT12Tok: Label 'INT-12', MaxLength = 10, Locked = true;
        INT13Tok: Label 'INT-13', MaxLength = 10, Locked = true;
        MISCTok: Label 'MISC', MaxLength = 10, Locked = true;
        MISC01Tok: Label 'MISC-01', MaxLength = 10, Locked = true;
        MISC02Tok: Label 'MISC-02', MaxLength = 10, Locked = true;
        MISC03Tok: Label 'MISC-03', MaxLength = 10, Locked = true;
        MISC04Tok: Label 'MISC-04', MaxLength = 10, Locked = true;
        MISC05Tok: Label 'MISC-05', MaxLength = 10, Locked = true;
        MISC06Tok: Label 'MISC-06', MaxLength = 10, Locked = true;
        MISC07Tok: Label 'MISC-07', MaxLength = 10, Locked = true;
        MISC08Tok: Label 'MISC-08', MaxLength = 10, Locked = true;
        MISC09Tok: Label 'MISC-09', MaxLength = 10, Locked = true;
        MISC10Tok: Label 'MISC-10', MaxLength = 10, Locked = true;
        MISC11Tok: Label 'MISC-11', MaxLength = 10, Locked = true;
        MISC12Tok: Label 'MISC-12', MaxLength = 10, Locked = true;
        MISC14Tok: Label 'MISC-14', MaxLength = 10, Locked = true;
        MISC15Tok: Label 'MISC-15', MaxLength = 10, Locked = true;
        MISC16Tok: Label 'MISC-16', MaxLength = 10, Locked = true;
        NEC01Tok: Label 'NEC-01', MaxLength = 10, Locked = true;
        NEC02Tok: Label 'NEC-02', MaxLength = 10, Locked = true;
        NEC04Tok: Label 'NEC-04', MaxLength = 10, Locked = true;
        RTok: Label 'R', MaxLength = 10, Locked = true;
        R01Tok: Label 'R-01', MaxLength = 10, Locked = true;
        R02ATok: Label 'R-02A', MaxLength = 10, Locked = true;
        R03Tok: Label 'R-03', MaxLength = 10, Locked = true;
        R04Tok: Label 'R-04', MaxLength = 10, Locked = true;
        R05Tok: Label 'R-05', MaxLength = 10, Locked = true;
        R06Tok: Label 'R-06', MaxLength = 10, Locked = true;
        R10Tok: Label 'R-10', MaxLength = 10, Locked = true;
        R12Tok: Label 'R-12', MaxLength = 10, Locked = true;
        STok: Label 'S', MaxLength = 10, Locked = true;
        S02Tok: Label 'S-02', MaxLength = 10, Locked = true;
        ProceedsFromBrokerBarterExchangeTransactionsLbl: Label 'Proceeds From Broker+Barter Exchange Transactions', MaxLength = 100;
        StocksbondsetcLbl: Label 'Stocks, bonds, etc.', MaxLength = 100;
        BarteringLbl: Label 'Bartering', MaxLength = 100;
        ProfitlossrealizedthisyearLbl: Label 'Profit/loss realized - this year', MaxLength = 100;
        UnrealprofitlossonopencontractslastyearLbl: Label 'Unreal. profit/loss on open contracts - last year', MaxLength = 100;
        UnrealprofitlossonopencontractsthisyearLbl: Label 'Unreal. profit/loss on open contracts - this year', MaxLength = 100;
        AggregateprofitlossLbl: Label 'Aggregate profit/loss', MaxLength = 100;
        DividendsandDistributionsLbl: Label 'Dividends and Distributions', MaxLength = 100;
        TotalordinarydividendsLbl: Label 'Total ordinary dividends', MaxLength = 100;
        QualifieddividendsLbl: Label 'Qualified dividends', MaxLength = 100;
        TotalcapitalgaindistrLbl: Label 'Total capital gain distr.', MaxLength = 100;
        UnrecapSec1250gainLbl: Label 'Unrecap. Sec. 1250 gain', MaxLength = 100;
        Section1202gainLbl: Label 'Section 1202 gain', MaxLength = 100;
        Collectibles28gainLbl: Label 'Collectibles (28%) gain', MaxLength = 100;
        Section897ordinarydividendsLbl: Label 'Section 897 ordinary dividends', MaxLength = 100;
        Section897capitalgainLbl: Label 'Section 897 capital gain', MaxLength = 100;
        NondividenddistributionsLbl: Label 'Nondividend distributions', MaxLength = 100;
        Section199AdividendsLbl: Label 'Section 199A dividends', MaxLength = 100;
        InvestmentexpensesLbl: Label 'Investment expenses', MaxLength = 100;
        ForeigntaxpaidLbl: Label 'Foreign tax paid', MaxLength = 100;
        CashliquidationdistributionsLbl: Label 'Cash liquidation distributions', MaxLength = 100;
        NoncashliquidationdistributionsLbl: Label 'Noncash liquidation distributions', MaxLength = 100;
        ExemptinterestdividendsLbl: Label 'Exempt-interest dividends', MaxLength = 100;
        SpecifiedprivateactivitybondinterestdividendsLbl: Label 'Specified private activity bond interest dividends', MaxLength = 100;
        InterestIncomeLbl: Label 'Interest Income', MaxLength = 100;
        EarlywithdrawalpenaltyLbl: Label 'Early withdrawal penalty', MaxLength = 100;
        InterestonUSSavingsBondsandTreasobligationsLbl: Label 'Interest on US Savings Bonds and Treas. obligations', MaxLength = 100;
        TaxexemptinterestLbl: Label 'Tax-exempt interest', MaxLength = 100;
        SpecifiedprivateactivitybondinterestLbl: Label 'Specified private activity bond interest', MaxLength = 100;
        MarketdiscountLbl: Label 'Market discount', MaxLength = 100;
        BondpremiumLbl: Label 'Bond premium', MaxLength = 100;
        BondPremiumonTreasuryObligationLbl: Label 'Bond Premium on Treasury Obligation', MaxLength = 100;
        BondpremiumontaxexemptbondLbl: Label 'Bond premium on tax-exempt bond', MaxLength = 100;
        MiscellaneousIncomeLbl: Label 'Miscellaneous Income', MaxLength = 100;
        RentsLbl: Label 'Rents', MaxLength = 100;
        RoyaltiesLbl: Label 'Royalties', MaxLength = 100;
        OtherIncomeLbl: Label 'Other Income', MaxLength = 100;
        FederalincometaxwithheldLbl: Label 'Federal income tax withheld', MaxLength = 100;
        FishingboatproceedsLbl: Label 'Fishing boat proceeds', MaxLength = 100;
        MedicalandhealthcarepaymentsLbl: Label 'Medical and health care payments', MaxLength = 100;
        Payermadedirectsalesof5000ormoreofconsumerproductsLbl: Label 'Payer made direct sales of $5000 or more of consumer products', MaxLength = 100;
        SubstitutepaymentsinlieuofdividendsorinterestLbl: Label 'Substitute payments in lieu of dividends or interest', MaxLength = 100;
        CropinsuranceproceedsLbl: Label 'Crop insurance proceeds', MaxLength = 100;
        GrossproceedspaidtoanattorneyLbl: Label 'Gross proceeds paid to an attorney', MaxLength = 100;
        FishpurchasedforresaleLbl: Label 'Fish purchased for resale', MaxLength = 100;
        Section409AdeferralsLbl: Label 'Section 409A deferrals', MaxLength = 100;
        ExcessgoldenparachutepaymentsLbl: Label 'Excess golden parachute payments', MaxLength = 100;
        NonqualifieddeferredcompensationLbl: Label 'Nonqualified deferred compensation', MaxLength = 100;
        StatetaxwithheldLbl: Label 'State tax withheld', MaxLength = 100;
        NonemployeecompensationLbl: Label 'Nonemployee compensation', MaxLength = 100;
        Payermadedirectsalestotaling5000ormoreofconsumerproductstorecipientforresaleLbl: Label 'Payer made direct sales totaling $5,000 or more of consumer products to recipient for resale', MaxLength = 100;
        PensionsAnnRetirementProfitSharPlansIRAsLbl: Label 'Pensions/Ann./Retirement/Profit-Shar.Plans/IRAs...', MaxLength = 100;
        GrossdistributionLbl: Label 'Gross distribution', MaxLength = 100;
        TaxableAmountLbl: Label 'Taxable Amount', MaxLength = 100;
        AmountinBox2eligibleforcapitalgainelectionLbl: Label 'Amount in Box 2 eligible for capital gain election', MaxLength = 100;
        EmployeecontributionsinsurancepremiumsLbl: Label 'Employee contributions/insurance premiums', MaxLength = 100;
        NetunrealappreciationinemployerssecuritiesLbl: Label 'Net unreal. appreciation in employers securities', MaxLength = 100;
        StateincometaxwithheldLbl: Label 'State income tax withheld', MaxLength = 100;
        LocalincometaxwithheldLbl: Label 'Local income tax withheld', MaxLength = 100;
        ProceedsFromRealEstateTransactionsLbl: Label 'Proceeds From Real Estate Transactions', MaxLength = 100;
        GrossproceedsLbl: Label 'Gross proceeds', MaxLength = 100;
}
#endif