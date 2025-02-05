codeunit 11401 "Create Area BE"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoMiscellaneousBE: Codeunit "Contoso Miscellaneous BE";
    begin
        ContosoMiscellaneousBE.InsertArea(FlemishRegion(), FlemishRegionLbl);
        ContosoMiscellaneousBE.InsertArea(WalloonRegion(), WalloonRegionLbl);
        ContosoMiscellaneousBE.InsertArea(BrusselsCapitalRegion(), BrusselsCapitalRegionLbl);
        InsertDisputeStatus();
    end;

    local procedure InsertDisputeStatus()
    var
        ContosoCustomerVendor: Codeunit "Contoso Customer/Vendor";
    begin
        ContosoCustomerVendor.InsertDisputeStatus(Invoice(), InvoiceDesLbl);
        ContosoCustomerVendor.InsertDisputeStatus(Price(), PriceDescLbl);
        ContosoCustomerVendor.InsertDisputeStatus(Quality(), QualityDescLbl);
        InsertExportProtocol();
    end;

    local procedure InsertExportProtocol()
    var
        ContosoMiscellaneousBE: Codeunit "Contoso Miscellaneous BE";
    begin
        ContosoMiscellaneousBE.InsertExportProtocol(DOMESTIC(), DomesticDescLbl, 2000002, 2000001, 0, 1);
        ContosoMiscellaneousBE.InsertExportProtocol(INTERNATIONALBEN(), InternationalBenDescLbl, 2000003, 2000002, 0, 2);
        ContosoMiscellaneousBE.InsertExportProtocol(INTERNATIONALOUR(), InternationalOURDescLbl, 2000003, 2000002, 0, 3);
        ContosoMiscellaneousBE.InsertExportProtocol(INTERNATIONALSHA(), InternationalSHADescLbl, 2000003, 2000002, 0, 1);
        ContosoMiscellaneousBE.InsertExportProtocol(NONEUROSEPA(), NonEuroSEPADescLbl, 2000005, 2000006, 0, 1);
        ContosoMiscellaneousBE.InsertExportProtocol(NONEUROSEPA00100109(), NonEuroSEPADescLbl, 2000005, 2000008, 0, 1);
        ContosoMiscellaneousBE.InsertExportProtocol(SEPA(), SEPADescLbl, 2000004, 2000005, 0, 1);
        ContosoMiscellaneousBE.InsertExportProtocol(SEPA00100109(), SEPADescLbl, 2000004, 2000007, 0, 1);
        ContosoMiscellaneousBE.InsertExportProtocol(ZERO(), ZeroDescLbl, 0, 1000, 1, 0);
        InsertIBLCBLWITransactionCode();
    end;

    local procedure InsertIBLCBLWITransactionCode()
    var
        ContosoMiscellaneousBE: Codeunit "Contoso Miscellaneous BE";
    begin
        ContosoMiscellaneousBE.InsertIBLCBLWITransactionCode('090', TransactionsofgoodscrossingnationalbordersDescLbl);
        ContosoMiscellaneousBE.InsertIBLCBLWITransactionCode('091', ReimbursementLbl);
        ContosoMiscellaneousBE.InsertIBLCBLWITransactionCode('092', EU3PartyTradeTransitLbl);
    end;

    procedure Invoice(): Code[10]
    begin
        exit(InvoiceTok);
    end;

    procedure Price(): Code[10]
    begin
        exit(PriceTok);
    end;

    procedure Quality(): Code[10]
    begin
        exit(QualityTok);
    end;

    procedure FlemishRegion(): Code[10]
    begin
        exit(FlemishRegionTok);
    end;

    procedure WalloonRegion(): Code[10]
    begin
        exit(WalloonRegionTok);
    end;

    procedure BrusselsCapitalRegion(): Code[10]
    begin
        exit(BrusselsCapitalRegionTok);
    end;

    procedure DOMESTIC(): Code[20]
    begin
        exit(DOMESTICTok);
    end;

    procedure INTERNATIONALBEN(): Code[20]
    begin
        exit(INTERNATIONALBENTok);
    end;

    procedure INTERNATIONALOUR(): Code[20]
    begin
        exit(INTERNATIONALOURTok);
    end;

    procedure INTERNATIONALSHA(): Code[20]
    begin
        exit(INTERNATIONALSHATok);
    end;

    procedure NONEUROSEPA(): Code[20]
    begin
        exit(NONEUROSEPATok);
    end;

    procedure NONEUROSEPA00100109(): Code[20]
    begin
        exit(NONEUROSEPA00100109Tok);
    end;

    procedure SEPA(): Code[20]
    begin
        exit(SEPATok);
    end;

    procedure SEPA00100109(): Code[20]
    begin
        exit(SEPA00100109Tok);
    end;

    procedure ZERO(): Code[20]
    begin
        exit(ZEROTok);
    end;

    var
        FlemishRegionTok: Label '1', Locked = true, MaxLength = 10;
        WalloonRegionTok: Label '2', Locked = true, MaxLength = 10;
        BrusselsCapitalRegionTok: Label '3', Locked = true, MaxLength = 10;
        FlemishRegionLbl: Label 'Flemish Region', MaxLength = 50;
        WalloonRegionLbl: Label 'Walloon Region', MaxLength = 50;
        BrusselsCapitalRegionLbl: Label 'Brussels Capital Region', MaxLength = 50;
        DOMESTICTok: Label 'DOMESTIC', MaxLength = 20, Locked = true;
        INTERNATIONALBENTok: Label 'INTERNATIONAL-BEN', MaxLength = 20, Locked = true;
        INTERNATIONALOURTok: Label 'INTERNATIONAL-OUR', MaxLength = 20, Locked = true;
        INTERNATIONALSHATok: Label 'INTERNATIONAL-SHA', MaxLength = 20, Locked = true;
        NONEUROSEPATok: Label 'NON-EURO SEPA', MaxLength = 20, Locked = true;
        NONEUROSEPA00100109Tok: Label 'NONEURO SEPA00100109', MaxLength = 20, Locked = true;
        SEPATok: Label 'SEPA', MaxLength = 20, Locked = true;
        SEPA00100109Tok: Label 'SEPA00100109', MaxLength = 20, Locked = true;
        ZEROTok: Label 'ZERO', MaxLength = 20, Locked = true;
        TransactionsofgoodscrossingnationalbordersDescLbl: Label 'Transactions of goods crossing national borders', MaxLength = 132;
        ReimbursementLbl: Label 'Reimbursement', MaxLength = 132;
        EU3PartyTradeTransitLbl: Label 'EU 3 Party Trade - Transit', MaxLength = 132;
        InvoiceTok: Label 'INVOICE', MaxLength = 10, Locked = true;
        InvoiceDesLbl: Label 'Duplicate invoice dispute arguments', MaxLength = 100;
        PriceTok: Label 'PRICE', MaxLength = 10, Locked = true;
        PriceDescLbl: Label 'Disputed invoices relating to the price', MaxLength = 100;
        QualityTok: Label 'QUALITY', MaxLength = 10, Locked = true;
        QualityDescLbl: Label 'A disputed invoice due to quality', MaxLength = 100;
        DomesticDescLbl: Label 'Domestic export protocol.', MaxLength = 50;
        InternationalBenDescLbl: Label 'Receiver pays the fees for an intl. payment.', MaxLength = 50;
        SEPADescLbl: Label 'Sender pays fees.', MaxLength = 50;
        NonEuroSEPADescLbl: Label 'Parties share fees.', MaxLength = 50;
        InternationalOURDescLbl: Label 'The sender pays the fees for an intl. payment.', MaxLength = 50;
        InternationalSHADescLbl: Label 'Parties share transfer fees for an intl. payment.', MaxLength = 50;
        ZeroDescLbl: Label 'The sending bank decides who pays the bank fees.', MaxLength = 50;
}