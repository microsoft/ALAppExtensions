#pragma warning disable AA0247
codeunit 31467 "Create Cash Desk Event CZP"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCashDeskCZP: Codeunit "Contoso Cash Desk CZP";
        CreateGLAccount: Codeunit "Create G/L Account";
        CreateGLAccountCZ: Codeunit "Create G/L Account CZ";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        CreateVATPostingGroupsCZ: Codeunit "Create VAT Posting Groups CZ";
        GenPostingType: Option " ",Purchase,Sale;
    begin
        ContosoCashDeskCZP.InsertCashDeskEvent(Fuel(), FuelpurchaseLbl, Enum::"Cash Document Type CZP"::Withdrawal, Enum::"Cash Document Account Type CZP"::"G/L Account", CreateGLAccountCZ.Fuel(), GenPostingType::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21I(), Enum::"Cash Document Gen.Doc.Type CZP"::" ", false);
        ContosoCashDeskCZP.InsertCashDeskEvent(TravelCosts(), TravelcostsLbl, Enum::"Cash Document Type CZP"::Withdrawal, Enum::"Cash Document Account Type CZP"::"G/L Account", CreateGLAccountCZ.TravelExpenses(), GenPostingType::" ", '', '', Enum::"Cash Document Gen.Doc.Type CZP"::" ", false);
        ContosoCashDeskCZP.InsertCashDeskEvent(Subsidy(), CashreceiptfromthebankLbl, Enum::"Cash Document Type CZP"::Receipt, Enum::"Cash Document Account Type CZP"::"G/L Account", CreateGLAccountCZ.Cashtransfer(), GenPostingType::" ", '', '', Enum::"Cash Document Gen.Doc.Type CZP"::" ", false);
        ContosoCashDeskCZP.InsertCashDeskEvent(CashPaymentInvoice(), CashpaymentoftheinvoiceLbl, Enum::"Cash Document Type CZP"::Receipt, Enum::"Cash Document Account Type CZP"::Customer, '', GenPostingType::" ", '', '', Enum::"Cash Document Gen.Doc.Type CZP"::Payment, true);
        ContosoCashDeskCZP.InsertCashDeskEvent(CashPaymentCM(), CashpaymentofcreditmemoLbl, Enum::"Cash Document Type CZP"::Withdrawal, Enum::"Cash Document Account Type CZP"::Customer, '', GenPostingType::" ", '', '', Enum::"Cash Document Gen.Doc.Type CZP"::Refund, true);
        ContosoCashDeskCZP.InsertCashDeskEvent(Transfer(), CashdeposittothebankLbl, Enum::"Cash Document Type CZP"::Withdrawal, Enum::"Cash Document Account Type CZP"::"G/L Account", CreateGLAccountCZ.Cashtransfer(), GenPostingType::" ", '', '', Enum::"Cash Document Gen.Doc.Type CZP"::" ", false);
        ContosoCashDeskCZP.InsertCashDeskEvent(OfficeSupplies(), OfficesuppliesLbl, Enum::"Cash Document Type CZP"::Withdrawal, Enum::"Cash Document Account Type CZP"::"G/L Account", CreateGLAccountCZ.ConsumptionOfMaterial(), GenPostingType::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21I(), Enum::"Cash Document Gen.Doc.Type CZP"::" ", false);
        ContosoCashDeskCZP.InsertCashDeskEvent(RepresentationCosts(), RepresentationcostsLbl, Enum::"Cash Document Type CZP"::Withdrawal, Enum::"Cash Document Account Type CZP"::"G/L Account", CreateGLAccountCZ.RepresentationCosts(), GenPostingType::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.NOVAT(), Enum::"Cash Document Gen.Doc.Type CZP"::" ", false);
        ContosoCashDeskCZP.InsertCashDeskEvent(Repairs(), RepairandmaintenanceLbl, Enum::"Cash Document Type CZP"::Withdrawal, Enum::"Cash Document Account Type CZP"::"G/L Account", CreateGLAccount.RepairsandMaintenance(), GenPostingType::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21S(), Enum::"Cash Document Gen.Doc.Type CZP"::" ", false);
        ContosoCashDeskCZP.InsertCashDeskEvent(MaterialPaidByCash(), MaterialpaidbycashLbl, Enum::"Cash Document Type CZP"::Withdrawal, Enum::"Cash Document Account Type CZP"::"G/L Account", CreateGLAccountCZ.ConsumptionOfMaterial(), GenPostingType::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21I(), Enum::"Cash Document Gen.Doc.Type CZP"::" ", false);
    end;

    procedure Fuel(): Code[10]
    begin
        exit(FUELLbl);
    end;

    procedure TravelCosts(): Code[10]
    begin
        exit(TRVLCOSTSLbl);
    end;

    procedure Subsidy(): Code[10]
    begin
        exit(SUBSIDYLbl);
    end;

    procedure CashPaymentInvoice(): Code[10]
    begin
        exit(CASHPMTINVLbl);
    end;

    procedure CashPaymentCM(): Code[10]
    begin
        exit(CASHPMTCMLbl);
    end;

    procedure Transfer(): Code[10]
    begin
        exit(TRANSFERLbl);
    end;

    procedure OfficeSupplies(): Code[10]
    begin
        exit(OFFSUPPLbl);
    end;

    procedure RepresentationCosts(): Code[10]
    begin
        exit(REPCOSTSLbl);
    end;

    procedure Repairs(): Code[10]
    begin
        exit(REPAIRSLbl);
    end;

    procedure MaterialPaidByCash(): Code[10]
    begin
        exit(MATPAIDLbl);
    end;

    var
        FUELLbl: Label 'FUEL', MaxLength = 10;
        TRVLCOSTSLbl: Label 'TRVLCOSTS', Comment = 'Travel costs', MaxLength = 10;
        SUBSIDYLbl: Label 'SUBSIDY', MaxLength = 10;
        CASHPMTINVLbl: Label 'CASHPMTINV', MaxLength = 10;
        CASHPMTCMLbl: Label 'CASHPMTCM', MaxLength = 10;
        TRANSFERLbl: Label 'TRANSFER', MaxLength = 10;
        OFFSUPPLbl: Label 'OFFSUP', Comment = 'Office supplies', MaxLength = 10;
        REPCOSTSLbl: Label 'REPCOSTS', Comment = 'Representation costs', MaxLength = 10;
        REPAIRSLbl: Label 'REPAIRS', MaxLength = 10;
        MATPAIDLbl: Label 'MATPAID', Comment = 'Material paid by cash', MaxLength = 10;
        FuelpurchaseLbl: Label 'Fuel purchase', MaxLength = 50;
        TravelcostsLbl: Label 'Travel costs', MaxLength = 50;
        CashreceiptfromthebankLbl: Label 'Cash receipt from the bank', MaxLength = 50;
        CashpaymentoftheinvoiceLbl: Label 'Cash payment of the invoice', MaxLength = 50;
        CashpaymentofcreditmemoLbl: Label 'Cash payment of credit memo', MaxLength = 50;
        CashdeposittothebankLbl: Label 'Cash deposit to the bank', MaxLength = 50;
        OfficesuppliesLbl: Label 'Office supplies', MaxLength = 50;
        RepresentationcostsLbl: Label 'Representation costs', MaxLength = 50;
        RepairandmaintenanceLbl: Label 'Repair and maintenance', MaxLength = 50;
        MaterialpaidbycashLbl: Label 'Material paid by cash', MaxLength = 50;
}