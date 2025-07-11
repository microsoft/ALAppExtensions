#pragma warning disable AA0247
codeunit 31345 "Contoso Advance Payments CZZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Advance Letter Application CZZ" = rim,
        tabledata "Advance Letter Template CZZ" = rim,
        tabledata "Purchase Header" = rim,
        tabledata "Purch. Adv. Letter Header CZZ" = rim,
        tabledata "Purch. Adv. Letter Line CZZ" = rim,
        tabledata "Sales Header" = rim,
        tabledata "Sales Adv. Letter Header CZZ" = rim,
        tabledata "Sales Adv. Letter Line CZZ" = rim,
        tabledata "VAT Posting Setup" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertAdvanceLetterTemplate(Code: Text; AdvanceLetterType: Enum "Advance Letter Type CZZ"; Description: Text[50]; AdvanceLetterGLAccount: Code[20]; AutomaticPostVATDocument: Boolean; AdvanceLetterDocumentNos: Code[20]; AdvanceLetterInvoiceNos: Code[20]; AdvanceLetterCrMemoNos: Code[20])
    var
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
        Exists: Boolean;
    begin
        if AdvanceLetterTemplateCZZ.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        AdvanceLetterTemplateCZZ.Validate(Code, Code);
        AdvanceLetterTemplateCZZ.Validate("Sales/Purchase", AdvanceLetterType);
        AdvanceLetterTemplateCZZ.Validate(Description, Description);
        AdvanceLetterTemplateCZZ.Validate("Advance Letter G/L Account", AdvanceLetterGLAccount);
        AdvanceLetterTemplateCZZ.Validate("Automatic Post VAT Document", AutomaticPostVATDocument);
        AdvanceLetterTemplateCZZ.Validate("Advance Letter Document Nos.", AdvanceLetterDocumentNos);
        AdvanceLetterTemplateCZZ.Validate("Advance Letter Invoice Nos.", AdvanceLetterInvoiceNos);
        AdvanceLetterTemplateCZZ.Validate("Advance Letter Cr. Memo Nos.", AdvanceLetterCrMemoNos);

        if Exists then
            AdvanceLetterTemplateCZZ.Modify(true)
        else
            AdvanceLetterTemplateCZZ.Insert(true);
    end;

    procedure InsertPurchAdvLetterHeader(AdvanceLetterCode: Code[20]; VendorNo: Code[20]; PostingDate: Date; AdvanceDueDate: Date; VATDate: Date; VendorAdvLetterNo: Code[35]): Record "Purch. Adv. Letter Header CZZ"
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
    begin
        PurchAdvLetterHeaderCZZ.Validate("No.", '');
        PurchAdvLetterHeaderCZZ.Validate("Advance Letter Code", AdvanceLetterCode);
        PurchAdvLetterHeaderCZZ.Insert(true);

        PurchAdvLetterHeaderCZZ.Validate("Pay-to Vendor No.", VendorNo);
        PurchAdvLetterHeaderCZZ.Validate("Posting Date", PostingDate);
        PurchAdvLetterHeaderCZZ.Validate("Advance Due Date", AdvanceDueDate);
        PurchAdvLetterHeaderCZZ.Validate("VAT Date", VATDate);
        PurchAdvLetterHeaderCZZ.Validate("Vendor Adv. Letter No.", VendorAdvLetterNo);
        PurchAdvLetterHeaderCZZ.Modify(true);

        exit(PurchAdvLetterHeaderCZZ);
    end;

    procedure InsertPurchAdvLetterLine(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; VATProdPostingGroup: Code[20]; Description: Text[50]; AmountIncludingVAT: Decimal)
    var
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
    begin
        PurchAdvLetterLineCZZ.Validate("Document No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterLineCZZ.Validate("Line No.", GetNextPurchAdvLetterLineNo(PurchAdvLetterHeaderCZZ));
        PurchAdvLetterLineCZZ.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
        PurchAdvLetterLineCZZ.Validate(Description, Description);
        PurchAdvLetterLineCZZ.Validate("Amount Including VAT", AmountIncludingVAT);
        PurchAdvLetterLineCZZ.Insert(true);
    end;

    procedure InsertPurchaseHeader(DocumentType: Enum "Purchase Document Type"; BuyFromVendorNo: Code[20]; YourReference: Code[35]; PostingDate: Date; PricesIncludingVAT: Boolean; VendorInvoiceNo: Code[35]): Record "Purchase Header"
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchaseHeader.Validate("Document Type", DocumentType);
        PurchaseHeader.Validate("Buy-from Vendor No.", BuyFromVendorNo);
        PurchaseHeader.Insert(true);

        PurchaseHeader.Validate("Your Reference", YourReference);
        PurchaseHeader.Validate("Posting Date", PostingDate);
        PurchaseHeader.Validate("Prices Including VAT", PricesIncludingVAT);
        PurchaseHeader.Validate("Vendor Invoice No.", VendorInvoiceNo);
        PurchaseHeader.Modify(true);

        exit(PurchaseHeader);
    end;

    procedure InsertSalesAdvLetterHeader(AdvanceLetterCode: Code[20]; CustomerNo: Code[20]; PostingDate: Date; AdvanceDueDate: Date; VATDate: Date): Record "sales Adv. Letter Header CZZ"
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
    begin
        SalesAdvLetterHeaderCZZ.Validate("No.", '');
        SalesAdvLetterHeaderCZZ.Validate("Advance Letter Code", AdvanceLetterCode);
        SalesAdvLetterHeaderCZZ.Insert(true);

        SalesAdvLetterHeaderCZZ.Validate("Bill-to Customer No.", CustomerNo);
        SalesAdvLetterHeaderCZZ.Validate("Posting Date", PostingDate);
        SalesAdvLetterHeaderCZZ.Validate("Advance Due Date", AdvanceDueDate);
        SalesAdvLetterHeaderCZZ.Validate("VAT Date", VATDate);
        SalesAdvLetterHeaderCZZ.Modify(true);

        exit(SalesAdvLetterHeaderCZZ);
    end;

    procedure InsertSalesAdvLetterLine(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; VATProdPostingGroup: Code[20]; Description: Text[50]; AmountIncludingVAT: Decimal)
    var
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
    begin
        SalesAdvLetterLineCZZ.Validate("Document No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterLineCZZ.Validate("Line No.", GetNextSalesAdvLetterLineNo(SalesAdvLetterHeaderCZZ));
        SalesAdvLetterLineCZZ.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
        SalesAdvLetterLineCZZ.Validate(Description, Description);
        SalesAdvLetterLineCZZ.Validate("Amount Including VAT", AmountIncludingVAT);
        SalesAdvLetterLineCZZ.Insert(true);
    end;

    procedure InsertSalesHeader(DocumentType: Enum "Sales Document Type"; SellToCustomerNo: Code[20]; YourReference: Code[35]; PostingDate: Date; PricesIncludingVAT: Boolean): Record "Sales Header"
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Validate("Document Type", DocumentType);
        SalesHeader.Validate("Sell-to Customer No.", SellToCustomerNo);
        SalesHeader.Insert(true);

        SalesHeader.Validate("Your Reference", YourReference);
        SalesHeader.Validate("Posting Date", PostingDate);
        SalesHeader.Validate("Prices Including VAT", PricesIncludingVAT);
        SalesHeader.Modify(true);

        exit(SalesHeader);
    end;

    procedure InsertAdvanceLetterApplication(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchaseHeader: Record "Purchase Header"; PostingDate: Date; LinkAmount: Decimal)
    begin
        InsertAdvanceLetterApplication(Enum::"Advance Letter Type CZZ"::Purchase, PurchAdvLetterHeaderCZZ."No.", PurchaseHeader.GetAdvLetterUsageDocTypeCZZ(), PurchaseHeader."No.", PostingDate, LinkAmount);
    end;

    procedure InsertAdvanceLetterApplication(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesHeader: Record "Sales Header"; PostingDate: Date; LinkAmount: Decimal)
    begin
        InsertAdvanceLetterApplication(Enum::"Advance Letter Type CZZ"::Sales, SalesAdvLetterHeaderCZZ."No.", SalesHeader.GetAdvLetterUsageDocTypeCZZ(), SalesHeader."No.", PostingDate, LinkAmount);
    end;

    procedure InsertAdvanceLetterApplication(AdvanceLetterType: Enum "Advance Letter Type CZZ"; AdvanceLetterNo: Code[20]; DocumentType: Enum "Adv. Letter Usage Doc.Type CZZ"; DocumentNo: Code[20]; PostingDate: Date; LinkAmount: Decimal)
    var
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
    begin
        AdvanceLetterApplicationCZZ.Init();
        AdvanceLetterApplicationCZZ.Validate("Advance Letter Type", AdvanceLetterType);
        AdvanceLetterApplicationCZZ.Validate("Advance Letter No.", AdvanceLetterNo);
        AdvanceLetterApplicationCZZ.Validate("Document Type", DocumentType);
        AdvanceLetterApplicationCZZ.Validate("Document No.", DocumentNo);
        AdvanceLetterApplicationCZZ.Validate("Posting Date", PostingDate);
        AdvanceLetterApplicationCZZ.Validate(Amount, LinkAmount);
        AdvanceLetterApplicationCZZ.Insert(true);
    end;

    procedure UpdateVATPostingSetup(VATBusinessGroupCode: Code[20]; VATProductGroupCode: Code[20]; SalesAdvLetterVATAcc: Code[20]; SalesAdvLetterAcc: Code[20]; PurchAdvLetterVATAcc: Code[20]; PurchAdvLetterAcc: Code[20])
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if not VATPostingSetup.Get(VATBusinessGroupCode, VATProductGroupCode) then
            exit;

        VATPostingSetup.Validate("Sales Adv. Letter VAT Acc. CZZ", SalesAdvLetterVATAcc);
        VATPostingSetup.Validate("Sales Adv. Letter Account CZZ", SalesAdvLetterAcc);
        VATPostingSetup.Validate("Purch. Adv.Letter VAT Acc. CZZ", PurchAdvLetterVATAcc);
        VATPostingSetup.Validate("Purch. Adv. Letter Account CZZ", PurchAdvLetterAcc);
        VATPostingSetup.Modify(true);
    end;

    local procedure GetNextPurchAdvLetterLineNo(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"): Integer
    var
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
    begin
        PurchAdvLetterLineCZZ.SetRange("Document No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterLineCZZ.SetCurrentKey("Line No.");

        if PurchAdvLetterLineCZZ.FindLast() then
            exit(PurchAdvLetterLineCZZ."Line No." + 10000)
        else
            exit(10000);
    end;

    local procedure GetNextSalesAdvLetterLineNo(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"): Integer
    var
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
    begin
        SalesAdvLetterLineCZZ.SetRange("Document No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterLineCZZ.SetCurrentKey("Line No.");

        if SalesAdvLetterLineCZZ.FindLast() then
            exit(SalesAdvLetterLineCZZ."Line No." + 10000)
        else
            exit(10000);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnAfterGeneratingDemoData', '', false, false)]
    local procedure GenerateDemoDataCZOnAfterGeneratingDemoData(Module: Enum "Contoso Demo Data Module"; ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Foundation:
                FoundationModule(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::Finance:
                FinanceModule(ContosoDemoDataLevel);
        end;
    end;

    local procedure FoundationModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create Custom Rep. Layout CZZ");
        end;
    end;

    local procedure FinanceModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create Vat Posting Groups CZZ");
        end;
    end;
}
