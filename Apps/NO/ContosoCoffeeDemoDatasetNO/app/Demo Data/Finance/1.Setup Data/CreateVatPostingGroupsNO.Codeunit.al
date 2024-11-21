codeunit 10707 "Create Vat Posting Groups NO"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        InsertVatReportingCode();
        InsertVATProductPostingGroup();
        InsertVATBusinessPostingGroups();
    end;

    local procedure InsertVatReportingCode()
    var
        ContosoPostingSetupNo: Codeunit "Contoso Posting Setup NO";
    begin
        ContosoPostingSetupNo.InsertVatReportingCode(VatRepCode0(), NoVATtreatmentLbl, 1, 0, 0);
        ContosoPostingSetupNo.InsertVatReportingCode(VatRepCode1(), InputVATdeductdomesticLbl, 1, 14, 0);
        ContosoPostingSetupNo.InsertVatReportingCode(VatRepCode11(), InputVATdeductdomesticLbl, 1, 15, 0);
        ContosoPostingSetupNo.InsertVatReportingCode(VatRepCode12(), InputVATdeductdomesticLbl, 1, 15, 0);
        ContosoPostingSetupNo.InsertVatReportingCode(VatRepCode13(), InputVATdeductdomesticLbl, 1, 16, 0);
        ContosoPostingSetupNo.InsertVatReportingCode(VatRepCode14(), InputVATdeductimportLbl, 1, 17, 0);
        ContosoPostingSetupNo.InsertVatReportingCode(VatRepCode15(), InputVATdeductimportLbl, 1, 18, 0);
        ContosoPostingSetupNo.InsertVatReportingCode(VatRepCode2(), PurchaseVATandInvTaxLbl, 1, 0, 0);
        ContosoPostingSetupNo.InsertVatReportingCode(VatRepCode21(), BasisonimportofgoodsLbl, 1, 0, 0);
        ContosoPostingSetupNo.InsertVatReportingCode(VatRepCode22(), BasisonimportofgoodsLbl, 1, 0, 0);
        ContosoPostingSetupNo.InsertVatReportingCode(VatRepCode23(), BasisonimportofgoodsLbl, 1, 0, 0);
        ContosoPostingSetupNo.InsertVatReportingCode(VatRepCode3(), OutputVATLbl, 2, 3, 0);
        ContosoPostingSetupNo.InsertVatReportingCode(VatRepCode31(), OutputVATLbl, 2, 4, 0);
        ContosoPostingSetupNo.InsertVatReportingCode(VatRepCode32(), OutputVATLbl, 2, 4, 0);
        ContosoPostingSetupNo.InsertVatReportingCode(VatRepCode33(), OutputVATLbl, 2, 5, 0);
        ContosoPostingSetupNo.InsertVatReportingCode(VatRepCode4(), PurchVATand0InvTaxLbl, 1, 0, 0);
        ContosoPostingSetupNo.InsertVatReportingCode(VatRepCode5(), NooutputVATLbl, 2, 6, 0);
        ContosoPostingSetupNo.InsertVatReportingCode(VatRepCode51(), DomsalesofrevchVAToblLbl, 2, 7, 0);
        ContosoPostingSetupNo.InsertVatReportingCode(VatRepCode52(), ExportofgoodsandservicesLbl, 2, 8, 0);
        ContosoPostingSetupNo.InsertVatReportingCode(VatRepCode6(), NotliabletoVATtreatmentLbl, 2, 0, 0);
        ContosoPostingSetupNo.InsertVatReportingCode(VatRepCode7(), NoVATtreatmentLbl, 2, 0, 0);
        ContosoPostingSetupNo.InsertVatReportingCode(VatRepCode81(), ImpofgoodsVATdeductLbl, 1, 9, 17);
        ContosoPostingSetupNo.InsertVatReportingCode(VatRepCode82(), ImpofgoodswodedofVATLbl, 1, 9, 0);
        ContosoPostingSetupNo.InsertVatReportingCode(VatRepCode83(), ImpofgoodsVATdeductLbl, 1, 10, 18);
        ContosoPostingSetupNo.InsertVatReportingCode(VatRepCode84(), ImpofgoodswodedofVATLbl, 1, 10, 0);
        ContosoPostingSetupNo.InsertVatReportingCode(VatRepCode85(), ImpofgoodsnaforVATLbl, 1, 0, 0);
        ContosoPostingSetupNo.InsertVatReportingCode(VatRepCode86(), ServpurchabroadVATdeductLbl, 1, 12, 17);
        ContosoPostingSetupNo.InsertVatReportingCode(VatRepCode87(), ServpurchabroadwodedVATLbl, 1, 12, 0);
        ContosoPostingSetupNo.InsertVatReportingCode(VatRepCode88(), ServpurchabroadVATdeductLbl, 1, 12, 17);
        ContosoPostingSetupNo.InsertVatReportingCode(VatRepCode89(), ServpurchabroadwodedVATLbl, 1, 12, 0);
        ContosoPostingSetupNo.InsertVatReportingCode(VatRepCode91(), PurchofemisstrgolddeductLbl, 1, 13, 14);
        ContosoPostingSetupNo.InsertVatReportingCode(VatRepCode92(), PurofemisstrgoldwodeducLbl, 1, 14, 0);
    end;

    local procedure InsertVATProductPostingGroup()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
    begin
        ContosoPostingGroup.InsertVATProductPostingGroup(Full(), FullDescriptionLbl);
        ContosoPostingGroup.InsertVATProductPostingGroup(Low(), LowDescriptionLbl);
        ContosoPostingGroup.InsertVATProductPostingGroup(OutSide(), OutSideDescriptionLbl);
        ContosoPostingGroup.InsertVATProductPostingGroup(High(), HighDescriptionLbl);
        ContosoPostingGroup.InsertVATProductPostingGroup(Service(), ServiceDescriptionLbl);
        ContosoPostingGroup.InsertVATProductPostingGroup(Without(), WithOutDescriptionLbl);
    end;

    local procedure InsertVATBusinessPostingGroups()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        if ContosoCoffeeDemoDataSetup."Company Type" = ContosoCoffeeDemoDataSetup."Company Type"::"Sales Tax" then
            exit;

        ContosoPostingGroup.InsertVATBusinessPostingGroup(CUSTHIGH(), CustomerhighvatDescLbl);
        ContosoPostingGroup.InsertVATBusinessPostingGroup(CUSTLOW(), CustomerlowvatDescLbl);
        ContosoPostingGroup.InsertVATBusinessPostingGroup(CUSTNOVAT(), CustomernovatDescLbl);

        ContosoPostingGroup.InsertVATBusinessPostingGroup(VENDHIGH(), VendorhighvatLDescLbl);
        ContosoPostingGroup.InsertVATBusinessPostingGroup(VENDLOW(), VendorlowvatDescLbl);
        ContosoPostingGroup.InsertVATBusinessPostingGroup(VENDNOVAT(), VendornovatDescLbl);
    end;

    procedure InsertVATPostingSetup()
    var
        ContosoPostingSetupNO: Codeunit "Contoso Posting Setup NO";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoPostingSetupNO.SetOverwriteData(true);

        ContosoPostingSetupNO.InsertVATPostingSetup(CUSTHIGH(), Full(), CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), Full(), 0, Enum::"Tax Calculation Type"::"Full VAT", 'E', '', '', VatRepCode52(), '', VatRepCode13());
        ContosoPostingSetupNO.InsertVATPostingSetup(CUSTHIGH(), High(), CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), High(), 25, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', VatRepCode3(), '', VatRepCode3());
        ContosoPostingSetupNO.InsertVATPostingSetup(CUSTHIGH(), Low(), CreateGLAccount.SalesVAT10(), CreateGLAccount.PurchaseVAT10(), Low(), 11.11, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', VatRepCode33(), '', '');
        ContosoPostingSetupNO.InsertVATPostingSetup(CUSTHIGH(), OutSide(), CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), OutSide(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', VatRepCode52(), '', '');
        ContosoPostingSetupNO.InsertVATPostingSetup(CUSTHIGH(), Without(), CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), Without(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', VatRepCode5(), '', '');
        ContosoPostingSetupNO.InsertVATPostingSetup(CUSTLOW(), High(), CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), Low(), 11.11, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', VatRepCode31(), '', '');
        ContosoPostingSetupNO.InsertVATPostingSetup(CUSTLOW(), Low(), CreateGLAccount.SalesVAT10(), CreateGLAccount.PurchaseVAT10(), Low(), 11.11, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', VatRepCode32(), '', '');
        ContosoPostingSetupNO.InsertVATPostingSetup(CUSTLOW(), OutSide(), CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), OutSide(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', VatRepCode52(), '', '');
        ContosoPostingSetupNO.InsertVATPostingSetup(CUSTLOW(), Without(), CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), Without(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', VatRepCode5(), '', '');

        ContosoPostingSetupNO.InsertVATPostingSetup(CUSTNOVAT(), High(), CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), Without(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', VatRepCode81(), VatRepCode81(), '');
        ContosoPostingSetupNO.InsertVATPostingSetup(CUSTNOVAT(), Low(), CreateGLAccount.SalesVAT10(), CreateGLAccount.PurchaseVAT10(), Without(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', VatRepCode82(), VatRepCode82(), '');
        ContosoPostingSetupNO.InsertVATPostingSetup(CUSTNOVAT(), OutSide(), CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), OutSide(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', VatRepCode83(), VatRepCode83(), '');
        ContosoPostingSetupNO.InsertVATPostingSetup(CUSTNOVAT(), Without(), CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), Without(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', VatRepCode84(), '', VatRepCode0());

        ContosoPostingSetupNO.InsertVATPostingSetup(VENDHIGH(), Full(), CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), Full(), 0, Enum::"Tax Calculation Type"::"Full VAT", 'E', '', '', '', VatRepCode15(), VatRepCode11());
        ContosoPostingSetupNO.InsertVATPostingSetup(VENDHIGH(), High(), CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), High(), 25, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', '', VatRepCode1(), VatRepCode1());
        ContosoPostingSetupNO.InsertVATPostingSetup(VENDHIGH(), Low(), CreateGLAccount.SalesVAT10(), CreateGLAccount.PurchaseVAT10(), Low(), 25, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', '', VatRepCode1(), '');
        ContosoPostingSetupNO.InsertVATPostingSetup(VENDHIGH(), Without(), CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), Without(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', '', VatRepCode13(), '');

        ContosoPostingSetupNO.InsertVATPostingSetup(VENDLOW(), High(), CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), Low(), 11.11, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', '', VatRepCode11(), '');
        ContosoPostingSetupNO.InsertVATPostingSetup(VENDLOW(), Low(), CreateGLAccount.SalesVAT10(), CreateGLAccount.PurchaseVAT10(), Low(), 11.11, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', '', VatRepCode12(), '');
        ContosoPostingSetupNO.InsertVATPostingSetup(VENDLOW(), Without(), CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), Without(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', '', VatRepCode13(), '');

        ContosoPostingSetupNO.InsertVATPostingSetup(VENDNOVAT(), High(), CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), Without(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', VatRepCode88(), VatRepCode88(), '');
        ContosoPostingSetupNO.InsertVATPostingSetup(VENDNOVAT(), Low(), CreateGLAccount.SalesVAT10(), CreateGLAccount.PurchaseVAT10(), Without(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', VatRepCode87(), '', '');
        ContosoPostingSetupNO.InsertVATPostingSetup(VENDNOVAT(), Service(), CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), Without(), 0, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateGLAccount.PurchaseVAT25(), '', VatRepCode86(), VatRepCode86(), VatRepCode14());
        ContosoPostingSetupNO.InsertVATPostingSetup(VENDNOVAT(), Without(), CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), Without(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', VatRepCode89(), '', '');
        ContosoPostingSetupNO.SetOverwriteData(false);
    end;

    procedure Full(): Code[20]
    begin
        exit(FullTok);
    end;

    procedure Low(): Code[20]
    begin
        exit(LowTok);
    end;

    procedure OutSide(): Code[20]
    begin
        exit(OutSideTok);
    end;

    procedure High(): Code[20]
    begin
        exit(HighTok);
    end;

    procedure Service(): Code[20]
    begin
        exit(SERVICETok);
    end;

    procedure Without(): Code[20]
    begin
        exit(WithoutTok);
    end;

    procedure CUSTHIGH(): Code[20]
    begin
        exit(CUSTHIGHTok);
    end;

    procedure CUSTLOW(): Code[20]
    begin
        exit(CUSTLOWTok);
    end;

    procedure CUSTNOVAT(): Code[20]
    begin
        exit(CUSTNOVATTok);
    end;

    procedure VENDHIGH(): Code[20]
    begin
        exit(VENDHIGHTok);
    end;

    procedure VENDLOW(): Code[20]
    begin
        exit(VENDLOWTok);
    end;

    procedure VENDNOVAT(): Code[20]
    begin
        exit(VENDNOVATTok);
    end;

    procedure VatRepCode0(): Code[20]
    begin
        exit(VatRepCode0Tok);
    end;

    procedure VatRepCode1(): Code[20]
    begin
        exit(VatRepCode1Tok);
    end;

    procedure VatRepCode11(): Code[20]
    begin
        exit(VatRepCode11Tok);
    end;

    procedure VatRepCode12(): Code[20]
    begin
        exit(VatRepCode12Tok);
    end;

    procedure VatRepCode13(): Code[20]
    begin
        exit(VatRepCode13Tok);
    end;

    procedure VatRepCode14(): Code[20]
    begin
        exit(VatRepCode14Tok);
    end;

    procedure VatRepCode15(): Code[20]
    begin
        exit(VatRepCode15Tok);
    end;

    procedure VatRepCode2(): Code[20]
    begin
        exit(VatRepCode2Tok);
    end;

    procedure VatRepCode21(): Code[20]
    begin
        exit(VatRepCode21Tok);
    end;

    procedure VatRepCode22(): Code[20]
    begin
        exit(VatRepCode22Tok);
    end;

    procedure VatRepCode23(): Code[20]
    begin
        exit(VatRepCode23Tok);
    end;

    procedure VatRepCode3(): Code[20]
    begin
        exit(VatRepCode3Tok);
    end;

    procedure VatRepCode31(): Code[20]
    begin
        exit(VatRepCode31Tok);
    end;

    procedure VatRepCode32(): Code[20]
    begin
        exit(VatRepCode32Tok);
    end;

    procedure VatRepCode33(): Code[20]
    begin
        exit(VatRepCode33Tok);
    end;

    procedure VatRepCode4(): Code[20]
    begin
        exit(VatRepCode4Tok);
    end;

    procedure VatRepCode5(): Code[20]
    begin
        exit(VatRepCode5Tok);
    end;

    procedure VatRepCode51(): Code[20]
    begin
        exit(VatRepCode51Tok);
    end;

    procedure VatRepCode52(): Code[20]
    begin
        exit(VatRepCode52Tok);
    end;

    procedure VatRepCode6(): Code[20]
    begin
        exit(VatRepCode6Tok);
    end;

    procedure VatRepCode7(): Code[20]
    begin
        exit(VatRepCode7Tok);
    end;

    procedure VatRepCode81(): Code[20]
    begin
        exit(VatRepCode81Tok);
    end;

    procedure VatRepCode82(): Code[20]
    begin
        exit(VatRepCode82Tok);
    end;

    procedure VatRepCode83(): Code[20]
    begin
        exit(VatRepCode83Tok);
    end;

    procedure VatRepCode84(): Code[20]
    begin
        exit(VatRepCode84Tok);
    end;

    procedure VatRepCode85(): Code[20]
    begin
        exit(VatRepCode85Tok);
    end;

    procedure VatRepCode86(): Code[20]
    begin
        exit(VatRepCode86Tok);
    end;

    procedure VatRepCode87(): Code[20]
    begin
        exit(VatRepCode87Tok);
    end;

    procedure VatRepCode88(): Code[20]
    begin
        exit(VatRepCode88Tok);
    end;

    procedure VatRepCode89(): Code[20]
    begin
        exit(VatRepCode89Tok);
    end;

    procedure VatRepCode91(): Code[20]
    begin
        exit(VatRepCode91Tok);
    end;

    procedure VatRepCode92(): Code[20]
    begin
        exit(VatRepCode92Tok);
    end;

    var
        FullTok: Label 'Full', Locked = true, MaxLength = 20;
        FullDescriptionLbl: Label 'Full vat.', MaxLength = 100;
        LowTok: Label 'LOW', Locked = true, MaxLength = 20;
        LowDescriptionLbl: Label 'Misc - low vat.', MaxLength = 100;
        HighTok: Label 'HIGH', Locked = true, MaxLength = 20;
        HighDescriptionLbl: Label 'Misc - high vat.', MaxLength = 100;
        OutSideTok: Label 'OUTSIDE', Locked = true, MaxLength = 20;
        OutSideDescriptionLbl: Label 'Misc - outside vat area ', MaxLength = 100;
        ServiceTok: Label 'SERVICE', Locked = true, MaxLength = 20;
        ServiceDescriptionLbl: Label 'Inverse vat.', MaxLength = 100;
        WithOutTok: Label 'WITHOUT', Locked = true, MaxLength = 20;
        WithOutDescriptionLbl: Label 'Misc - without vat.', MaxLength = 100;
        CUSTHIGHTok: Label 'CUSTHIGH', Locked = true, MaxLength = 20;
        CUSTLOWTok: Label 'CUSTLOW', Locked = true, MaxLength = 20;
        CUSTNOVATTok: Label 'CUSTNOVAT', Locked = true, MaxLength = 20;
        VENDHIGHTok: Label 'VENDHIGH', Locked = true, MaxLength = 20;
        VENDLOWTok: Label 'VENDLOW', Locked = true, MaxLength = 20;
        VENDNOVATTok: Label 'VENDNOVAT', Locked = true, MaxLength = 20;
        CustomerhighvatDescLbl: Label 'Customer - high vat', MaxLength = 100;
        CustomerlowvatDescLbl: Label 'Customer - low vat', MaxLength = 100;
        CustomernovatDescLbl: Label 'Customer - no vat.', MaxLength = 100;
        VendorhighvatLDescLbl: Label 'Vendor - high vat', MaxLength = 100;
        VendorlowvatDescLbl: Label 'Vendor - low vat', MaxLength = 100;
        VendornovatDescLbl: Label 'Vendor - no vat.', MaxLength = 100;
        VatRepCode0Tok: Label '0', MaxLength = 20, Locked = true;
        VatRepCode1Tok: Label '1', MaxLength = 20, Locked = true;
        VatRepCode11Tok: Label '11', MaxLength = 20, Locked = true;
        VatRepCode12Tok: Label '12', MaxLength = 20, Locked = true;
        VatRepCode13Tok: Label '13', MaxLength = 20, Locked = true;
        VatRepCode14Tok: Label '14', MaxLength = 20, Locked = true;
        VatRepCode15Tok: Label '15', MaxLength = 20, Locked = true;
        VatRepCode2Tok: Label '2', MaxLength = 20, Locked = true;
        VatRepCode21Tok: Label '21', MaxLength = 20, Locked = true;
        VatRepCode22Tok: Label '22', MaxLength = 20, Locked = true;
        VatRepCode23Tok: Label '23', MaxLength = 20, Locked = true;
        VatRepCode3Tok: Label '3', MaxLength = 20, Locked = true;
        VatRepCode31Tok: Label '31', MaxLength = 20, Locked = true;
        VatRepCode32Tok: Label '32', MaxLength = 20, Locked = true;
        VatRepCode33Tok: Label '33', MaxLength = 20, Locked = true;
        VatRepCode4Tok: Label '4', MaxLength = 20, Locked = true;
        VatRepCode5Tok: Label '5', MaxLength = 20, Locked = true;
        VatRepCode51Tok: Label '51', MaxLength = 20, Locked = true;
        VatRepCode52Tok: Label '52', MaxLength = 20, Locked = true;
        VatRepCode6Tok: Label '6', MaxLength = 20, Locked = true;
        VatRepCode7Tok: Label '7', MaxLength = 20, Locked = true;
        VatRepCode81Tok: Label '81', MaxLength = 20, Locked = true;
        VatRepCode82Tok: Label '82', MaxLength = 20, Locked = true;
        VatRepCode83Tok: Label '83', MaxLength = 20, Locked = true;
        VatRepCode84Tok: Label '84', MaxLength = 20, Locked = true;
        VatRepCode85Tok: Label '85', MaxLength = 20, Locked = true;
        VatRepCode86Tok: Label '86', MaxLength = 20, Locked = true;
        VatRepCode87Tok: Label '87', MaxLength = 20, Locked = true;
        VatRepCode88Tok: Label '88', MaxLength = 20, Locked = true;
        VatRepCode89Tok: Label '89', MaxLength = 20, Locked = true;
        VatRepCode91Tok: Label '91', MaxLength = 20, Locked = true;
        VatRepCode92Tok: Label '92', MaxLength = 20, Locked = true;
        NoVATtreatmentLbl: Label 'No VAT treatment', MaxLength = 250;
        InputVATdeductdomesticLbl: Label 'Input VAT deduct. (domestic)', MaxLength = 250;
        InputVATdeductimportLbl: Label 'Input VAT deduct. (import)', MaxLength = 250;
        PurchaseVATandInvTaxLbl: Label 'Purchase - VAT and Inv. Tax', MaxLength = 250;
        BasisonimportofgoodsLbl: Label 'Basis on import of goods', MaxLength = 250;
        OutputVATLbl: Label 'Output VAT', MaxLength = 250;
        PurchVATand0InvTaxLbl: Label 'Purch. - VAT and 0% Inv. Tax', MaxLength = 250;
        NooutputVATLbl: Label 'No output VAT', MaxLength = 250;
        DomsalesofrevchVAToblLbl: Label 'Dom. sales of rev.ch./VAT obl', MaxLength = 250;
        ExportofgoodsandservicesLbl: Label 'Export of goods and services', MaxLength = 250;
        NotliabletoVATtreatmentLbl: Label 'Not liable to VAT treatment', MaxLength = 250;
        ImpofgoodsVATdeductLbl: Label 'Imp. of goods, VAT deduct.', MaxLength = 250;
        ImpofgoodswodedofVATLbl: Label 'Imp. of goods, w/o ded. of VAT', MaxLength = 250;
        ImpofgoodsnaforVATLbl: Label 'Imp. of goods, n/a for VAT', MaxLength = 250;
        ServpurchabroadVATdeductLbl: Label 'Serv.purch.abroad, VAT deduct.', MaxLength = 250;
        ServpurchabroadwodedVATLbl: Label 'Serv.purch.abroad, w/o ded.VAT', MaxLength = 250;
        PurchofemisstrgolddeductLbl: Label 'Purch. of emiss.tr,gold,deduct', MaxLength = 250;
        PurofemisstrgoldwodeducLbl: Label 'Pur.of emiss.tr,gold,w/o deduc', MaxLength = 250;
}