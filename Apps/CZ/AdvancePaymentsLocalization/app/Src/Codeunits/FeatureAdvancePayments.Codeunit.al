/// <summary>
/// Copies Advance Payments data from Base application to Czech localization application on enabling the AdvancePaymentsLocalizationForCzech feature
/// </summary>
#pragma warning disable AL0432
Codeunit 31085 "Feature Advance Payments CZZ" implements "Feature Data Update"
{
    Access = Internal;
#if not CLEAN19
    Permissions = tabledata "Advance Letter Line Relation" = d,
                  tabledata "Advance Letter Template CZZ" = i,
                  tabledata "Purch. Adv. Letter Header CZZ" = i,
                  tabledata "Purch. Adv. Letter Line CZZ" = i,
                  tabledata "Purch. Adv. Letter Entry CZZ" = i,
                  tabledata "Sales Adv. Letter Header CZZ" = i,
                  tabledata "Sales Adv. Letter Line CZZ" = i,
                  tabledata "Sales Adv. Letter Entry CZZ" = i,
                  tabledata "Advance Letter Application CZZ" = im,
                  tabledata "VAT Posting Setup" = m,
                  tabledata "VAT Entry" = m,
                  tabledata "Cust. Ledger Entry" = m,
                  tabledata "Vendor Ledger Entry" = m,
                  tabledata "VAT Statement Line" = d,
                  tabledata "Gen. Journal Line" = m,
                  tabledata "Cash Document Line CZP" = m,
                  tabledata "Payment Order Line CZB" = m,
                  tabledata "Iss. Payment Order Line CZB" = m,
                  tabledata "Report Selections" = m;

    var
        PurchaseAdvPaymentTemplate: Record "Purchase Adv. Payment Template";
        SalesAdvPaymentTemplate: Record "Sales Adv. Payment Template";
        PurchAdvanceLetterHeader: Record "Purch. Advance Letter Header";
        SalesAdvanceLetterHeader: Record "Sales Advance Letter Header";
        VATPostingSetup: Record "VAT Posting Setup";
        VATEntry: Record "VAT Entry";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VATStatementLine: Record "VAT Statement Line";
        GenJournalLine: Record "Gen. Journal Line";
        CashDocumentLineCZP: Record "Cash Document Line CZP";
        PaymentOrderLine: Record "Payment Order Line";
        IssuedPaymentOrderLine: Record "Issued Payment Order Line";
        ReportSelections: Record "Report Selections";
        TempDocumentEntry: Record "Document Entry" temporary;
        FeatureDataUpdateMgt: Codeunit "Feature Data Update Mgt.";
        InstallApplicationsMgtCZL: Codeunit "Install Applications Mgt. CZL";
        PrepaymentLinksManagement: Codeunit "Prepayment Links Management";
        LastEntryNo: Integer;
        DescriptionTxt: Label 'If you use Advance Payments, data from Base application to Czech localization application will be copied.';
#endif

    procedure IsDataUpdateRequired(): Boolean;
    begin
#if CLEAN19
        exit(false);
#else
        CountRecords();
        exit(not TempDocumentEntry.IsEmpty());
#endif
    end;

    procedure ReviewData();
#if CLEAN19
    begin
    end;
#else
    var
        DataUpgradeOverview: Page "Data Upgrade Overview";
    begin
        Commit();
        Clear(DataUpgradeOverview);
        DataUpgradeOverview.Set(TempDocumentEntry);
        DataUpgradeOverview.RunModal();
    end;
#endif

    procedure AfterUpdate(FeatureDataUpdateStatus: Record "Feature Data Update Status")
    begin
    end;

    procedure UpdateData(FeatureDataUpdateStatus: Record "Feature Data Update Status");
    begin
#if not CLEAN19
        if PurchaseAdvPaymentTemplate.IsEmpty() and SalesAdvPaymentTemplate.IsEmpty() then
            exit;

        BindSubscription(InstallApplicationsMgtCZL);
        UpdatePurchaseAdvanceTemplates(FeatureDataUpdateStatus);
        UpdateSalesAdvanceTemplates(FeatureDataUpdateStatus);
        UpdatePurchaseAdvances(FeatureDataUpdateStatus);
        UpdateSalesAdvances(FeatureDataUpdateStatus);
        UpdateVATPostingSetup(FeatureDataUpdateStatus);
        UpdateVATEntries(FeatureDataUpdateStatus);
        UpdateCustomerLedgerEntries(FeatureDataUpdateStatus);
        UpdateVendorLedgerEntries(FeatureDataUpdateStatus);
        UpdateVATStatementLines(FeatureDataUpdateStatus);
        UpdateGenJournalLines(FeatureDataUpdateStatus);
        UpdateCashDocumentLinesCZP(FeatureDataUpdateStatus);
        UpdatePaymentOrderLinesCZB(FeatureDataUpdateStatus);
        UpdateIssPaymentOrderLinesCZB(FeatureDataUpdateStatus);
        UpdateReportSelections(FeatureDataUpdateStatus);
        UnbindSubscription(InstallApplicationsMgtCZL);
#endif
    end;

    procedure GetTaskDescription() TaskDescription: Text;
    begin
#if not CLEAN19
        TaskDescription := DescriptionTxt;
#endif
    end;

#if not CLEAN19
    local procedure CountRecords()
    begin
        TempDocumentEntry.DeleteAll();
        InsertDocumentEntry(Database::"Purchase Adv. Payment Template", PurchaseAdvPaymentTemplate.TableCaption(), PurchaseAdvPaymentTemplate.CountApprox());
        InsertDocumentEntry(Database::"Sales Adv. Payment Template", SalesAdvPaymentTemplate.TableCaption(), SalesAdvPaymentTemplate.CountApprox());
        InsertDocumentEntry(Database::"Purch. Advance Letter Header", PurchAdvanceLetterHeader.TableCaption(), PurchAdvanceLetterHeader.CountApprox());
        InsertDocumentEntry(Database::"Sales Advance Letter Header", SalesAdvanceLetterHeader.TableCaption(), SalesAdvanceLetterHeader.CountApprox());
        InsertDocumentEntry(Database::"VAT Posting Setup", VATPostingSetup.TableCaption(), VATPostingSetup.CountApprox());
        VATEntry.SetRange("Prepayment Type", VATEntry."Prepayment Type"::Advance);
        VATEntry.SetFilter("Advance Base", '<>0');
        InsertDocumentEntry(Database::"VAT Entry", VATEntry.TableCaption(), VATEntry.CountApprox());
        CustLedgerEntry.SetRange(Prepayment, true);
        CustLedgerEntry.SetRange("Prepayment Type", CustLedgerEntry."Prepayment Type"::Advance);
        InsertDocumentEntry(Database::"Cust. Ledger Entry", CustLedgerEntry.TableCaption(), CustLedgerEntry.CountApprox());
        VendorLedgerEntry.SetRange(Prepayment, true);
        VendorLedgerEntry.SetRange("Prepayment Type", VendorLedgerEntry."Prepayment Type"::Advance);
        InsertDocumentEntry(Database::"Vendor Ledger Entry", VendorLedgerEntry.TableCaption(), VendorLedgerEntry.CountApprox());
        VATStatementLine.SetRange("Amount Type", VATStatementLine."Amount Type"::"Adv. Base");
        InsertDocumentEntry(Database::"VAT Statement Line", VATStatementLine.TableCaption(), VATStatementLine.CountApprox());
        GenJournalLine.SetFilter("Advance Letter Link Code", '<>%1', '');
        InsertDocumentEntry(Database::"Gen. Journal Line", GenJournalLine.TableCaption(), GenJournalLine.CountApprox());
        CashDocumentLineCZP.SetFilter("Advance Letter Link Code", '<>%1', '');
        InsertDocumentEntry(Database::"Cash Document Line", CashDocumentLineCZP.TableCaption(), CashDocumentLineCZP.CountApprox());
        PaymentOrderLine.SetFilter("Letter No.", '<>%1', '');
        InsertDocumentEntry(Database::"Payment Order Line", PaymentOrderLine.TableCaption(), PaymentOrderLine.CountApprox());
        IssuedPaymentOrderLine.SetFilter("Letter No.", '<>%1', '');
        InsertDocumentEntry(Database::"Issued Payment Order Line", IssuedPaymentOrderLine.TableCaption(), IssuedPaymentOrderLine.CountApprox());
        ReportSelections.SetFilter("Report ID", '%1|%2', Report::"Purchase - Invoice", Report::"Sales Invoice CZL");
        InsertDocumentEntry(Database::"Report Selections", ReportSelections.TableCaption(), ReportSelections.CountApprox());

        OnAfterCountRecords(TempDocumentEntry);
    end;

    local procedure InsertDocumentEntry(TableID: Integer; TableName: Text; RecordCount: Integer)
    begin
        if RecordCount = 0 then
            exit;

        LastEntryNo += 1;
        TempDocumentEntry.Init();
        TempDocumentEntry."Entry No." := LastEntryNo;
        TempDocumentEntry."Table ID" := TableID;
        TempDocumentEntry."Table Name" := CopyStr(TableName, 1, MaxStrLen(TempDocumentEntry."Table Name"));
        TempDocumentEntry."No. of Records" := RecordCount;
        TempDocumentEntry.Insert();
    end;

    local procedure UpdatePurchaseAdvanceTemplates(FeatureDataUpdateStatus: Record "Feature Data Update Status")
    var
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
        VendorPostingGroup: Record "Vendor Posting Group";
        StartDateTime: DateTime;
    begin
        StartDateTime := CurrentDateTime();
        if PurchaseAdvPaymentTemplate.FindSet() then
            repeat
                if not AdvanceLetterTemplateCZZ.Get('N_' + PurchaseAdvPaymentTemplate.Code) then begin
                    AdvanceLetterTemplateCZZ.Init();
                    AdvanceLetterTemplateCZZ.Code := 'N_' + PurchaseAdvPaymentTemplate.Code;
                    AdvanceLetterTemplateCZZ."Sales/Purchase" := AdvanceLetterTemplateCZZ."Sales/Purchase"::Purchase;
                    if VendorPostingGroup.Get(PurchaseAdvPaymentTemplate."Vendor Posting Group") then
                        AdvanceLetterTemplateCZZ."Advance Letter G/L Account" := VendorPostingGroup."Advance Account";
                    AdvanceLetterTemplateCZZ."Advance Letter Document Nos." := PurchaseAdvPaymentTemplate."Advance Letter Nos.";
                    AdvanceLetterTemplateCZZ."Advance Letter Invoice Nos." := PurchaseAdvPaymentTemplate."Advance Invoice Nos.";
                    AdvanceLetterTemplateCZZ."Advance Letter Cr. Memo Nos." := PurchaseAdvPaymentTemplate."Advance Credit Memo Nos.";
                    AdvanceLetterTemplateCZZ."Automatic Post VAT Document" := true;
                    AdvanceLetterTemplateCZZ."Document Report ID" := Report::"Purchase - Advance Letter CZZ";
                    AdvanceLetterTemplateCZZ."Invoice/Cr. Memo Report ID" := Report::"Purchase - Advance VAT Doc.CZZ";
                    AdvanceLetterTemplateCZZ.SystemId := PurchaseAdvPaymentTemplate.SystemId;
                    AdvanceLetterTemplateCZZ.Insert(false, true);
                end;
            until PurchaseAdvPaymentTemplate.Next() = 0;
        FeatureDataUpdateMgt.LogTask(FeatureDataUpdateStatus, AdvanceLetterTemplateCZZ.TableCaption(), StartDateTime);
    end;

    local procedure UpdateSalesAdvanceTemplates(FeatureDataUpdateStatus: Record "Feature Data Update Status")
    var
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
        CustomerPostingGroup: Record "Customer Posting Group";
        StartDateTime: DateTime;
    begin
        StartDateTime := CurrentDateTime();
        if SalesAdvPaymentTemplate.FindSet() then
            repeat
                if not AdvanceLetterTemplateCZZ.Get('P_' + SalesAdvPaymentTemplate.Code) then begin
                    AdvanceLetterTemplateCZZ.Init();
                    AdvanceLetterTemplateCZZ.Code := 'P_' + SalesAdvPaymentTemplate.Code;
                    AdvanceLetterTemplateCZZ."Sales/Purchase" := AdvanceLetterTemplateCZZ."Sales/Purchase"::Sales;
                    if CustomerPostingGroup.Get(SalesAdvPaymentTemplate."Customer Posting Group") then
                        AdvanceLetterTemplateCZZ."Advance Letter G/L Account" := CustomerPostingGroup."Advance Account";
                    AdvanceLetterTemplateCZZ."Advance Letter Document Nos." := SalesAdvPaymentTemplate."Advance Letter Nos.";
                    AdvanceLetterTemplateCZZ."Advance Letter Invoice Nos." := SalesAdvPaymentTemplate."Advance Invoice Nos.";
                    AdvanceLetterTemplateCZZ."Advance Letter Cr. Memo Nos." := SalesAdvPaymentTemplate."Advance Credit Memo Nos.";
                    AdvanceLetterTemplateCZZ."Automatic Post VAT Document" := true;
                    AdvanceLetterTemplateCZZ."Document Report ID" := Report::"Sales - Advance Letter CZZ";
                    AdvanceLetterTemplateCZZ."Invoice/Cr. Memo Report ID" := Report::"Sales - Advance VAT Doc. CZZ";
                    AdvanceLetterTemplateCZZ.SystemId := SalesAdvPaymentTemplate.SystemId;
                    AdvanceLetterTemplateCZZ.Insert(false, true);
                end;
            until SalesAdvPaymentTemplate.Next() = 0;
        FeatureDataUpdateMgt.LogTask(FeatureDataUpdateStatus, AdvanceLetterTemplateCZZ.TableCaption(), StartDateTime);
    end;

    local procedure UpdatePurchaseAdvances(FeatureDataUpdateStatus: Record "Feature Data Update Status")
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvanceLetterLine: Record "Purch. Advance Letter Line";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        StartDateTime: DateTime;
    begin
        StartDateTime := CurrentDateTime();
        if PurchAdvanceLetterHeader.FindSet() then
            repeat
                if not PurchAdvLetterHeaderCZZ.Get(PurchAdvanceLetterHeader."No.") then begin
                    PurchAdvLetterHeaderCZZ.Init();
                    PurchAdvLetterHeaderCZZ."No." := PurchAdvanceLetterHeader."No.";
                    if PurchAdvanceLetterHeader."Template Code" <> '' then
                        PurchAdvLetterHeaderCZZ."Advance Letter Code" := 'N_' + PurchAdvanceLetterHeader."Template Code";
                    PurchAdvLetterHeaderCZZ."Pay-to Vendor No." := PurchAdvanceLetterHeader."Pay-to Vendor No.";
                    PurchAdvLetterHeaderCZZ."Pay-to Name" := PurchAdvanceLetterHeader."Pay-to Name";
                    PurchAdvLetterHeaderCZZ."Pay-to Name 2" := PurchAdvanceLetterHeader."Pay-to Name 2";
                    PurchAdvLetterHeaderCZZ."Pay-to Address" := PurchAdvanceLetterHeader."Pay-to Address";
                    PurchAdvLetterHeaderCZZ."Pay-to Address 2" := PurchAdvanceLetterHeader."Pay-to Address 2";
                    PurchAdvLetterHeaderCZZ."Pay-to City" := PurchAdvanceLetterHeader."Pay-to City";
                    PurchAdvLetterHeaderCZZ."Pay-to Post Code" := PurchAdvanceLetterHeader."Pay-to Post Code";
                    PurchAdvLetterHeaderCZZ."Pay-to County" := PurchAdvanceLetterHeader."Pay-to County";
                    PurchAdvLetterHeaderCZZ."Pay-to Country/Region Code" := PurchAdvanceLetterHeader."Pay-to Country/Region Code";
                    PurchAdvLetterHeaderCZZ."Language Code" := PurchAdvanceLetterHeader."Language Code";
                    PurchAdvLetterHeaderCZZ."Pay-to Contact" := PurchAdvanceLetterHeader."Pay-to Contact";
                    PurchAdvLetterHeaderCZZ."Purchaser Code" := PurchAdvanceLetterHeader."Purchaser Code";
                    PurchAdvLetterHeaderCZZ."Shortcut Dimension 1 Code" := PurchAdvanceLetterHeader."Shortcut Dimension 1 Code";
                    PurchAdvLetterHeaderCZZ."Shortcut Dimension 2 Code" := PurchAdvanceLetterHeader."Shortcut Dimension 2 Code";
                    PurchAdvLetterHeaderCZZ."VAT Bus. Posting Group" := PurchAdvanceLetterHeader."VAT Bus. Posting Group";
                    PurchAdvLetterHeaderCZZ."Posting Date" := PurchAdvanceLetterHeader."Posting Date";
                    PurchAdvLetterHeaderCZZ."Advance Due Date" := PurchAdvanceLetterHeader."Advance Due Date";
                    PurchAdvLetterHeaderCZZ."Document Date" := PurchAdvanceLetterHeader."Document Date";
                    PurchAdvLetterHeaderCZZ."VAT Date" := PurchAdvanceLetterHeader."VAT Date";
                    PurchAdvLetterHeaderCZZ."Posting Description" := PurchAdvanceLetterHeader."Posting Description";
                    PurchAdvLetterHeaderCZZ."Payment Method Code" := PurchAdvanceLetterHeader."Payment Method Code";
                    PurchAdvLetterHeaderCZZ."Payment Terms Code" := PurchAdvanceLetterHeader."Payment Terms Code";
                    PurchAdvLetterHeaderCZZ."Registration No." := PurchAdvanceLetterHeader."Registration No.";
                    PurchAdvLetterHeaderCZZ."Tax Registration No." := PurchAdvanceLetterHeader."Tax Registration No.";
                    PurchAdvLetterHeaderCZZ."VAT Registration No." := PurchAdvanceLetterHeader."VAT Registration No.";
                    PurchAdvLetterHeaderCZZ."No. Printed" := PurchAdvanceLetterHeader."No. Printed";
                    PurchAdvLetterHeaderCZZ."Order No." := PurchAdvanceLetterHeader."Order No.";
                    PurchAdvLetterHeaderCZZ."Vendor Adv. Letter No." := PurchAdvanceLetterHeader."Vendor Adv. Payment No.";
                    PurchAdvLetterHeaderCZZ."No. Series" := PurchAdvanceLetterHeader."No. Series";
                    PurchAdvLetterHeaderCZZ."Bank Account Code" := PurchAdvanceLetterHeader."Bank Account Code";
                    PurchAdvLetterHeaderCZZ."Bank Account No." := PurchAdvanceLetterHeader."Bank Account No.";
                    PurchAdvLetterHeaderCZZ."Bank Branch No." := PurchAdvanceLetterHeader."Bank Branch No.";
                    PurchAdvLetterHeaderCZZ."Specific Symbol" := PurchAdvanceLetterHeader."Specific Symbol";
                    PurchAdvLetterHeaderCZZ."Variable Symbol" := PurchAdvanceLetterHeader."Variable Symbol";
                    PurchAdvLetterHeaderCZZ."Constant Symbol" := PurchAdvanceLetterHeader."Constant Symbol";
                    PurchAdvLetterHeaderCZZ.IBAN := PurchAdvanceLetterHeader.IBAN;
                    PurchAdvLetterHeaderCZZ."SWIFT Code" := PurchAdvanceLetterHeader."SWIFT Code";
                    PurchAdvLetterHeaderCZZ."Bank Name" := PurchAdvanceLetterHeader."Bank Name";
                    PurchAdvLetterHeaderCZZ."Transit No." := PurchAdvanceLetterHeader."Transit No.";
                    PurchAdvLetterHeaderCZZ."Responsibility Center" := PurchAdvanceLetterHeader."Responsibility Center";
                    PurchAdvLetterHeaderCZZ."Currency Code" := PurchAdvanceLetterHeader."Currency Code";
                    PurchAdvLetterHeaderCZZ."Currency Factor" := PurchAdvanceLetterHeader."Currency Factor";
                    PurchAdvLetterHeaderCZZ."VAT Country/Region Code" := PurchAdvanceLetterHeader."VAT Country/Region Code";
                    PurchAdvanceLetterHeader.CalcFields(Status);
                    PurchAdvLetterHeaderCZZ.Status := GetStatus(PurchAdvanceLetterHeader.Status);
                    PurchAdvLetterHeaderCZZ."Automatic Post VAT Usage" := true;
                    PurchAdvLetterHeaderCZZ."Dimension Set ID" := PurchAdvanceLetterHeader."Dimension Set ID";
                    PurchAdvLetterHeaderCZZ.SystemId := PurchAdvanceLetterHeader.SystemId;
                    PurchAdvLetterHeaderCZZ.Insert(false, true);

                    PurchAdvanceLetterLine.SetRange("Letter No.", PurchAdvanceLetterHeader."No.");
                    if PurchAdvanceLetterLine.FindSet() then
                        repeat
                            PurchAdvLetterLineCZZ.Init();
                            PurchAdvLetterLineCZZ."Document No." := PurchAdvanceLetterLine."Letter No.";
                            PurchAdvLetterLineCZZ."Line No." := PurchAdvanceLetterLine."Line No.";
                            PurchAdvLetterLineCZZ.Description := PurchAdvanceLetterLine.Description;
                            PurchAdvLetterLineCZZ."VAT Bus. Posting Group" := PurchAdvanceLetterLine."VAT Bus. Posting Group";
                            PurchAdvLetterLineCZZ."VAT Prod. Posting Group" := PurchAdvanceLetterLine."VAT Prod. Posting Group";
                            PurchAdvLetterLineCZZ.Amount := PurchAdvanceLetterLine.Amount;
                            PurchAdvLetterLineCZZ."VAT Amount" := PurchAdvanceLetterLine."VAT Amount";
                            PurchAdvLetterLineCZZ."Amount Including VAT" := PurchAdvanceLetterLine."Amount Including VAT";
                            if (PurchAdvLetterHeaderCZZ."Currency Factor" = 0) or (PurchAdvLetterHeaderCZZ."Currency Code" = '') then begin
                                PurchAdvLetterLineCZZ."Amount (LCY)" := PurchAdvLetterLineCZZ.Amount;
                                PurchAdvLetterLineCZZ."VAT Amount (LCY)" := PurchAdvLetterLineCZZ."VAT Amount";
                                PurchAdvLetterLineCZZ."Amount Including VAT (LCY)" := PurchAdvLetterLineCZZ."Amount Including VAT";
                            end else begin
                                PurchAdvLetterLineCZZ."Amount Including VAT (LCY)" := Round(PurchAdvLetterLineCZZ."Amount Including VAT" / PurchAdvLetterHeaderCZZ."Currency Factor");
                                PurchAdvLetterLineCZZ."VAT Amount (LCY)" := Round(PurchAdvLetterLineCZZ."VAT Amount" / PurchAdvLetterHeaderCZZ."Currency Factor");
                                PurchAdvLetterLineCZZ."Amount (LCY)" := PurchAdvLetterLineCZZ."Amount Including VAT (LCY)" - PurchAdvLetterLineCZZ."VAT Amount (LCY)";
                            end;
                            PurchAdvLetterLineCZZ."VAT %" := PurchAdvanceLetterLine."VAT %";
                            PurchAdvLetterLineCZZ."VAT Calculation Type" := PurchAdvanceLetterLine."VAT Calculation Type";
                            if VATPostingSetup.Get(PurchAdvLetterLineCZZ."VAT Bus. Posting Group", PurchAdvLetterLineCZZ."VAT Prod. Posting Group") then
                                PurchAdvLetterLineCZZ."VAT Clause Code" := VATPostingSetup."VAT Clause Code";
                            PurchAdvLetterLineCZZ."VAT Calculation Type" := PurchAdvanceLetterLine."VAT Calculation Type";
                            PurchAdvLetterLineCZZ."VAT Identifier" := PurchAdvanceLetterLine."VAT Identifier";
                            PurchAdvLetterLineCZZ.SystemId := PurchAdvanceLetterLine.SystemId;
                            PurchAdvLetterLineCZZ.Insert(false, true);
                        until PurchAdvanceLetterLine.Next() = 0;

                    UpdatePurchEntry(PurchAdvLetterHeaderCZZ);
                    UpdatePurchAdvanceApplication(PurchAdvLetterHeaderCZZ);
                end;
            until PurchAdvanceLetterHeader.Next() = 0;
        FeatureDataUpdateMgt.LogTask(FeatureDataUpdateStatus, PurchAdvanceLetterHeader.TableCaption(), StartDateTime);
    end;

    local procedure UpdatePurchEntry(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    var
        AdvanceLink: Record "Advance Link";
        PurchAdvanceLetterEntry1: Record "Purch. Advance Letter Entry";
        PurchAdvanceLetterEntry2: Record "Purch. Advance Letter Entry";
        PurchAdvLetterEntryCZZ1: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterEntryCZZ2: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterManagementCZZ: Codeunit "PurchAdvLetterManagement CZZ";
        CurrFactor: Decimal;
    begin
        if PurchAdvLetterHeaderCZZ.Status.AsInteger() = PurchAdvLetterHeaderCZZ.Status::New.AsInteger() then
            exit;

        PurchAdvLetterEntryCZZ1.LockTable();
        if PurchAdvLetterEntryCZZ1.FindLast() then;

        PurchAdvLetterHeaderCZZ.CalcFields("Amount Including VAT", "Amount Including VAT (LCY)");
        PurchAdvLetterManagementCZZ.AdvEntryInit(false);
        PurchAdvLetterManagementCZZ.AdvEntryInsert("Advance Letter Entry Type CZZ"::"Initial Entry", PurchAdvLetterHeaderCZZ."No.", PurchAdvLetterHeaderCZZ."Posting Date",
            -PurchAdvLetterHeaderCZZ."Amount Including VAT", -PurchAdvLetterHeaderCZZ."Amount Including VAT (LCY)",
            PurchAdvLetterHeaderCZZ."Currency Code", PurchAdvLetterHeaderCZZ."Currency Factor", PurchAdvLetterHeaderCZZ."No.", '',
            PurchAdvLetterHeaderCZZ."Shortcut Dimension 1 Code", PurchAdvLetterHeaderCZZ."Shortcut Dimension 2 Code", PurchAdvLetterHeaderCZZ."Dimension Set ID", false);

        AdvanceLink.Reset();
        AdvanceLink.SetRange(Type, AdvanceLink.Type::Purchase);
        AdvanceLink.SetRange("Document No.", PurchAdvLetterHeaderCZZ."No.");
        AdvanceLink.SetRange("Entry Type", AdvanceLink."Entry Type"::"Link To Letter");
        if AdvanceLink.FindSet(true) then
            repeat
                PurchAdvLetterManagementCZZ.AdvEntryInit(false);
                PurchAdvLetterManagementCZZ.AdvEntryInitVendLedgEntryNo(AdvanceLink."CV Ledger Entry No.");
                if not VendorLedgerEntry.Get(AdvanceLink."CV Ledger Entry No.") then
                    VendorLedgerEntry.Init();
                PurchAdvLetterManagementCZZ.AdvEntryInsert("Advance Letter Entry Type CZZ"::Payment, PurchAdvLetterHeaderCZZ."No.", VendorLedgerEntry."Posting Date",
                    -AdvanceLink.Amount, -AdvanceLink."Amount (LCY)",
                    PurchAdvLetterHeaderCZZ."Currency Code", VendorLedgerEntry."Original Currency Factor", VendorLedgerEntry."Document No.", VendorLedgerEntry."External Document No.",
                    VendorLedgerEntry."Global Dimension 1 Code", VendorLedgerEntry."Global Dimension 2 Code", VendorLedgerEntry."Dimension Set ID", false);

                PurchAdvLetterEntryCZZ1.FindLast();

                PurchAdvanceLetterEntry1.Reset();
                PurchAdvanceLetterEntry1.SetRange("Letter No.", PurchAdvLetterHeaderCZZ."No.");
                PurchAdvanceLetterEntry1.SetRange("Letter Line No.", AdvanceLink."Line No.");
                PurchAdvanceLetterEntry1.SetRange("Vendor Entry No.", AdvanceLink."CV Ledger Entry No.");
                PurchAdvanceLetterEntry1.SetRange("Entry Type", PurchAdvanceLetterEntry1."Entry Type"::VAT);
                if PurchAdvanceLetterEntry1.FindSet() then
                    repeat
                        PurchAdvLetterManagementCZZ.AdvEntryInit(false);
                        if PurchAdvanceLetterEntry1.Cancelled then
                            PurchAdvLetterManagementCZZ.AdvEntryInitCancel();
                        PurchAdvLetterManagementCZZ.AdvEntryInitRelatedEntry(PurchAdvLetterEntryCZZ1."Entry No.");
                        PurchAdvLetterManagementCZZ.AdvEntryInitVAT(PurchAdvanceLetterEntry1."VAT Bus. Posting Group", PurchAdvanceLetterEntry1."VAT Prod. Posting Group", PurchAdvanceLetterEntry1."VAT Date",
                            PurchAdvanceLetterEntry1."VAT Entry No.", PurchAdvanceLetterEntry1."VAT %", PurchAdvanceLetterEntry1."VAT Identifier", "TAX Calculation Type"::"Normal VAT",
                            PurchAdvanceLetterEntry1."VAT Amount", PurchAdvanceLetterEntry1."VAT Amount (LCY)", PurchAdvanceLetterEntry1."VAT Base Amount", PurchAdvanceLetterEntry1."VAT Base Amount (LCY)");
                        PurchAdvLetterManagementCZZ.AdvEntryInsert("Advance Letter Entry Type CZZ"::"VAT Payment", PurchAdvLetterHeaderCZZ."No.", PurchAdvanceLetterEntry1."Posting Date",
                            PurchAdvanceLetterEntry1."VAT Base Amount" + PurchAdvanceLetterEntry1."VAT Amount", PurchAdvanceLetterEntry1."VAT Base Amount (LCY)" + PurchAdvanceLetterEntry1."VAT Amount (LCY)",
                            PurchAdvLetterEntryCZZ1."Currency Code", PurchAdvLetterEntryCZZ1."Currency Factor", PurchAdvanceLetterEntry1."Document No.", PurchAdvLetterEntryCZZ1."External Document No.",
                            PurchAdvLetterEntryCZZ1."Global Dimension 1 Code", PurchAdvLetterEntryCZZ1."Global Dimension 2 Code", PurchAdvLetterEntryCZZ1."Dimension Set ID", false);
                    until PurchAdvanceLetterEntry1.Next() = 0;

                PurchAdvanceLetterEntry1.SetRange("Entry Type", PurchAdvanceLetterEntry1."Entry Type"::Deduction);
                if PurchAdvanceLetterEntry1.FindSet() then
                    repeat
                        if not VendorLedgerEntry.Get(PurchAdvanceLetterEntry1."Vendor Entry No.") then
                            VendorLedgerEntry.Init();
                        CurrFactor := VendorLedgerEntry."Original Currency Factor";
                        if CurrFactor = 0 then
                            CurrFactor := 1;
                        PurchAdvLetterManagementCZZ.AdvEntryInit(false);
                        if PurchAdvanceLetterEntry1.Cancelled then
                            PurchAdvLetterManagementCZZ.AdvEntryInitCancel();
                        PurchAdvLetterManagementCZZ.AdvEntryInitVendLedgEntryNo(PurchAdvanceLetterEntry1."Vendor Entry No.");
                        PurchAdvLetterManagementCZZ.AdvEntryInitRelatedEntry(PurchAdvLetterEntryCZZ1."Entry No.");
                        PurchAdvLetterManagementCZZ.AdvEntryInsert("Advance Letter Entry Type CZZ"::Usage, PurchAdvLetterHeaderCZZ."No.", PurchAdvanceLetterEntry1."Posting Date",
                            PurchAdvanceLetterEntry1.Amount, Round(PurchAdvanceLetterEntry1.Amount / CurrFactor),
                            PurchAdvanceLetterEntry1."Currency Code", VendorLedgerEntry."Original Currency Factor", PurchAdvanceLetterEntry1."Document No.", VendorLedgerEntry."External Document No.",
                            VendorLedgerEntry."Global Dimension 1 Code", VendorLedgerEntry."Global Dimension 2 Code", VendorLedgerEntry."Dimension Set ID", false);

                        PurchAdvLetterEntryCZZ2.FindLast();

                        PurchAdvanceLetterEntry2.Reset();
                        PurchAdvanceLetterEntry2.SetRange("Letter No.", PurchAdvanceLetterEntry1."Letter No.");
                        PurchAdvanceLetterEntry2.SetRange("Letter Line No.", PurchAdvanceLetterEntry1."Letter Line No.");
                        PurchAdvanceLetterEntry2.SetRange("Entry Type", PurchAdvanceLetterEntry2."Entry Type"::"VAT Deduction");
                        PurchAdvanceLetterEntry2.SetRange("Document Type", PurchAdvanceLetterEntry1."Document Type");
                        PurchAdvanceLetterEntry2.SetRange("Document No.", PurchAdvanceLetterEntry1."Document No.");
                        PurchAdvanceLetterEntry2.SetRange("Purchase Line No.", PurchAdvanceLetterEntry1."Purchase Line No.");
                        PurchAdvanceLetterEntry2.SetRange("Deduction Line No.", PurchAdvanceLetterEntry1."Deduction Line No.");
                        PurchAdvanceLetterEntry2.SetRange("Vendor Entry No.", PurchAdvanceLetterEntry1."Vendor Entry No.");
                        if PurchAdvanceLetterEntry2.FindSet() then
                            repeat
                                PurchAdvLetterManagementCZZ.AdvEntryInit(false);
                                if PurchAdvanceLetterEntry2.Cancelled then
                                    PurchAdvLetterManagementCZZ.AdvEntryInitCancel();
                                PurchAdvLetterManagementCZZ.AdvEntryInitRelatedEntry(PurchAdvLetterEntryCZZ2."Entry No.");
                                PurchAdvLetterManagementCZZ.AdvEntryInitVAT(PurchAdvanceLetterEntry2."VAT Bus. Posting Group", PurchAdvanceLetterEntry2."VAT Prod. Posting Group", PurchAdvanceLetterEntry2."VAT Date",
                                    PurchAdvanceLetterEntry2."VAT Entry No.", PurchAdvanceLetterEntry2."VAT %", PurchAdvanceLetterEntry2."VAT Identifier", "TAX Calculation Type"::"Normal VAT",
                                    PurchAdvanceLetterEntry2."VAT Amount", PurchAdvanceLetterEntry2."VAT Amount (LCY)", PurchAdvanceLetterEntry2."VAT Base Amount", PurchAdvanceLetterEntry2."VAT Base Amount (LCY)");
                                PurchAdvLetterManagementCZZ.AdvEntryInsert("Advance Letter Entry Type CZZ"::"VAT Usage", PurchAdvLetterHeaderCZZ."No.", PurchAdvanceLetterEntry2."Posting Date",
                                    PurchAdvanceLetterEntry2."VAT Base Amount" + PurchAdvanceLetterEntry2."VAT Amount", PurchAdvanceLetterEntry2."VAT Base Amount (LCY)" + PurchAdvanceLetterEntry2."VAT Amount (LCY)",
                                    PurchAdvanceLetterEntry2."Currency Code", VendorLedgerEntry."Original Currency Factor", PurchAdvanceLetterEntry2."Document No.", VendorLedgerEntry."External Document No.",
                                    VendorLedgerEntry."Global Dimension 1 Code", VendorLedgerEntry."Global Dimension 2 Code", VendorLedgerEntry."Dimension Set ID", false);
                            until PurchAdvanceLetterEntry2.Next() = 0;

                        PurchAdvanceLetterEntry2.SetRange("Entry Type", PurchAdvanceLetterEntry2."Entry Type"::"VAT Rate");
                        if PurchAdvanceLetterEntry2.FindSet() then
                            repeat
                                PurchAdvLetterManagementCZZ.AdvEntryInit(false);
                                if PurchAdvanceLetterEntry2.Cancelled then
                                    PurchAdvLetterManagementCZZ.AdvEntryInitCancel();
                                PurchAdvLetterManagementCZZ.AdvEntryInitRelatedEntry(PurchAdvLetterEntryCZZ2."Entry No.");
                                PurchAdvLetterManagementCZZ.AdvEntryInitVAT(PurchAdvanceLetterEntry2."VAT Bus. Posting Group", PurchAdvanceLetterEntry2."VAT Prod. Posting Group", PurchAdvanceLetterEntry2."VAT Date",
                                    0, PurchAdvanceLetterEntry2."VAT %", PurchAdvanceLetterEntry2."VAT Identifier", "TAX Calculation Type"::"Normal VAT",
                                    0, PurchAdvanceLetterEntry2."VAT Amount (LCY)", 0, PurchAdvanceLetterEntry2."VAT Base Amount (LCY)");
                                PurchAdvLetterManagementCZZ.AdvEntryInsert("Advance Letter Entry Type CZZ"::"VAT Rate", PurchAdvLetterHeaderCZZ."No.", PurchAdvanceLetterEntry2."Posting Date",
                                    0, PurchAdvanceLetterEntry2."VAT Base Amount (LCY)" + PurchAdvanceLetterEntry2."VAT Amount (LCY)", '', 0, PurchAdvanceLetterEntry2."Document No.", VendorLedgerEntry."External Document No.",
                                    VendorLedgerEntry."Global Dimension 1 Code", VendorLedgerEntry."Global Dimension 2 Code", VendorLedgerEntry."Dimension Set ID", false);
                            until PurchAdvanceLetterEntry2.Next() = 0;
                    until PurchAdvanceLetterEntry1.Next() = 0;

                AdvanceLink.Amount := 0;
                AdvanceLink."Amount (LCY)" := 0;
                AdvanceLink.Modify(false);
            until AdvanceLink.Next() = 0;
    end;

    local procedure UpdatePurchAdvanceApplication(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    var
        AdvanceLetterLineRelation: Record "Advance Letter Line Relation";
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        PurchaseHeader: Record "Purchase Header";
        AmtToDeduct: Decimal;
        Continue: Boolean;
    begin
        AdvanceLetterLineRelation.SetRange(Type, AdvanceLetterLineRelation.Type::Purchase);
        AdvanceLetterLineRelation.SetRange("Letter No.", PurchAdvLetterHeaderCZZ."No.");
        if AdvanceLetterLineRelation.FindSet() then begin
            repeat
                case AdvanceLetterLineRelation."Document Type" of
                    AdvanceLetterLineRelation."Document Type"::Order:
                        Continue := PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, AdvanceLetterLineRelation."Document No.");
                    AdvanceLetterLineRelation."Document Type"::Invoice:
                        Continue := PurchaseHeader.Get(PurchaseHeader."Document Type"::Invoice, AdvanceLetterLineRelation."Document No.");
                    else
                        Continue := false;
                end;
                if Continue then begin
                    AdvanceLetterApplicationCZZ.Init();
                    AdvanceLetterApplicationCZZ."Advance Letter Type" := AdvanceLetterApplicationCZZ."Advance Letter Type"::Purchase;
                    AdvanceLetterApplicationCZZ."Advance Letter No." := AdvanceLetterLineRelation."Letter No.";
                    case AdvanceLetterLineRelation."Document Type" of
                        AdvanceLetterLineRelation."Document Type"::Invoice:
                            AdvanceLetterApplicationCZZ."Document Type" := AdvanceLetterApplicationCZZ."Document Type"::"Purchase Invoice";
                        AdvanceLetterLineRelation."Document Type"::Order:
                            AdvanceLetterApplicationCZZ."Document Type" := AdvanceLetterApplicationCZZ."Document Type"::"Purchase Order";
                    end;
                    AdvanceLetterApplicationCZZ."Document No." := AdvanceLetterLineRelation."Document No.";
                    if AdvanceLetterLineRelation."Primary Link" then
                        AmtToDeduct := AdvanceLetterLineRelation.Amount
                    else
                        AmtToDeduct := AdvanceLetterLineRelation."Amount To Deduct";

                    if AdvanceLetterApplicationCZZ.Find() then begin
                        AdvanceLetterApplicationCZZ.Amount += AmtToDeduct;
                        AdvanceLetterApplicationCZZ.Modify();
                    end else begin
                        AdvanceLetterApplicationCZZ.Amount := AmtToDeduct;
                        AdvanceLetterApplicationCZZ.Insert();
                    end;
                end;
            until AdvanceLetterLineRelation.Next() = 0;

            AdvanceLetterLineRelation.DeleteAll();
        end;
    end;

    local procedure UpdateSalesAdvances(FeatureDataUpdateStatus: Record "Feature Data Update Status")
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvanceLetterLine: Record "Sales Advance Letter Line";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        StartDateTime: DateTime;
    begin
        StartDateTime := CurrentDateTime();
        if SalesAdvanceLetterHeader.FindSet() then
            repeat
                if not SalesAdvLetterHeaderCZZ.Get(SalesAdvanceLetterHeader."No.") then begin
                    SalesAdvLetterHeaderCZZ.Init();
                    SalesAdvLetterHeaderCZZ."No." := SalesAdvanceLetterHeader."No.";
                    if SalesAdvanceLetterHeader."Template Code" <> '' then
                        SalesAdvLetterHeaderCZZ."Advance Letter Code" := 'P_' + SalesAdvanceLetterHeader."Template Code";
                    SalesAdvLetterHeaderCZZ."Bill-to Customer No." := SalesAdvanceLetterHeader."Bill-to Customer No.";
                    SalesAdvLetterHeaderCZZ."Bill-to Name" := SalesAdvanceLetterHeader."Bill-to Name";
                    SalesAdvLetterHeaderCZZ."Bill-to Name 2" := SalesAdvanceLetterHeader."Bill-to Name 2";
                    SalesAdvLetterHeaderCZZ."Bill-to Address" := SalesAdvanceLetterHeader."Bill-to Address";
                    SalesAdvLetterHeaderCZZ."Bill-to Address 2" := SalesAdvanceLetterHeader."Bill-to Address 2";
                    SalesAdvLetterHeaderCZZ."Bill-to City" := SalesAdvanceLetterHeader."Bill-to City";
                    SalesAdvLetterHeaderCZZ."Bill-to Post Code" := SalesAdvanceLetterHeader."Bill-to Post Code";
                    SalesAdvLetterHeaderCZZ."Bill-to County" := SalesAdvanceLetterHeader."Bill-to County";
                    SalesAdvLetterHeaderCZZ."Bill-to Country/Region Code" := SalesAdvanceLetterHeader."Bill-to Country/Region Code";
                    SalesAdvLetterHeaderCZZ."Language Code" := SalesAdvanceLetterHeader."Language Code";
                    SalesAdvLetterHeaderCZZ."Bill-to Contact" := SalesAdvanceLetterHeader."Bill-to Contact";
                    SalesAdvLetterHeaderCZZ."Salesperson Code" := SalesAdvanceLetterHeader."Salesperson Code";
                    SalesAdvLetterHeaderCZZ."Shortcut Dimension 1 Code" := SalesAdvanceLetterHeader."Shortcut Dimension 1 Code";
                    SalesAdvLetterHeaderCZZ."Shortcut Dimension 2 Code" := SalesAdvanceLetterHeader."Shortcut Dimension 2 Code";
                    SalesAdvLetterHeaderCZZ."VAT Bus. Posting Group" := SalesAdvanceLetterHeader."VAT Bus. Posting Group";
                    SalesAdvLetterHeaderCZZ."Posting Date" := SalesAdvanceLetterHeader."Posting Date";
                    SalesAdvLetterHeaderCZZ."Advance Due Date" := SalesAdvanceLetterHeader."Advance Due Date";
                    SalesAdvLetterHeaderCZZ."Document Date" := SalesAdvanceLetterHeader."Document Date";
                    SalesAdvLetterHeaderCZZ."VAT Date" := SalesAdvanceLetterHeader."VAT Date";
                    SalesAdvLetterHeaderCZZ."Posting Description" := SalesAdvanceLetterHeader."Posting Description";
                    SalesAdvLetterHeaderCZZ."Payment Method Code" := SalesAdvanceLetterHeader."Payment Method Code";
                    SalesAdvLetterHeaderCZZ."Payment Terms Code" := SalesAdvanceLetterHeader."Payment Terms Code";
                    SalesAdvLetterHeaderCZZ."Registration No." := SalesAdvanceLetterHeader."Registration No.";
                    SalesAdvLetterHeaderCZZ."Tax Registration No." := SalesAdvanceLetterHeader."Tax Registration No.";
                    SalesAdvLetterHeaderCZZ."VAT Registration No." := SalesAdvanceLetterHeader."VAT Registration No.";
                    SalesAdvLetterHeaderCZZ."No. Printed" := SalesAdvanceLetterHeader."No. Printed";
                    SalesAdvLetterHeaderCZZ."Order No." := SalesAdvanceLetterHeader."Order No.";
                    SalesAdvLetterHeaderCZZ."No. Series" := SalesAdvanceLetterHeader."No. Series";
                    SalesAdvLetterHeaderCZZ."Bank Account Code" := SalesAdvanceLetterHeader."Bank Account Code";
                    SalesAdvLetterHeaderCZZ."Bank Account No." := SalesAdvanceLetterHeader."Bank Account No.";
                    SalesAdvLetterHeaderCZZ."Bank Branch No." := SalesAdvanceLetterHeader."Bank Branch No.";
                    SalesAdvLetterHeaderCZZ."Specific Symbol" := SalesAdvanceLetterHeader."Specific Symbol";
                    SalesAdvLetterHeaderCZZ."Variable Symbol" := SalesAdvanceLetterHeader."Variable Symbol";
                    SalesAdvLetterHeaderCZZ."Constant Symbol" := SalesAdvanceLetterHeader."Constant Symbol";
                    SalesAdvLetterHeaderCZZ.IBAN := SalesAdvanceLetterHeader.IBAN;
                    SalesAdvLetterHeaderCZZ."SWIFT Code" := SalesAdvanceLetterHeader."SWIFT Code";
                    SalesAdvLetterHeaderCZZ."Bank Name" := SalesAdvanceLetterHeader."Bank Name";
                    SalesAdvLetterHeaderCZZ."Transit No." := SalesAdvanceLetterHeader."Transit No.";
                    SalesAdvLetterHeaderCZZ."Responsibility Center" := SalesAdvanceLetterHeader."Responsibility Center";
                    SalesAdvLetterHeaderCZZ."Currency Code" := SalesAdvanceLetterHeader."Currency Code";
                    SalesAdvLetterHeaderCZZ."Currency Factor" := SalesAdvanceLetterHeader."Currency Factor";
                    SalesAdvLetterHeaderCZZ."VAT Country/Region Code" := SalesAdvanceLetterHeader."VAT Country/Region Code";
                    SalesAdvanceLetterHeader.CalcFields(Status);
                    SalesAdvLetterHeaderCZZ.Status := GetStatus(SalesAdvanceLetterHeader.Status);
                    SalesAdvLetterHeaderCZZ."Automatic Post VAT Document" := true;
                    SalesAdvLetterHeaderCZZ."Dimension Set ID" := SalesAdvanceLetterHeader."Dimension Set ID";
                    SalesAdvLetterHeaderCZZ.SystemId := SalesAdvanceLetterHeader.SystemId;
                    SalesAdvLetterHeaderCZZ.Insert(false, true);

                    SalesAdvanceLetterLine.SetRange("Letter No.", SalesAdvanceLetterHeader."No.");
                    if SalesAdvanceLetterLine.FindSet() then
                        repeat
                            SalesAdvLetterLineCZZ.Init();
                            SalesAdvLetterLineCZZ."Document No." := SalesAdvanceLetterLine."Letter No.";
                            SalesAdvLetterLineCZZ."Line No." := SalesAdvanceLetterLine."Line No.";
                            SalesAdvLetterLineCZZ.Description := SalesAdvanceLetterLine.Description;
                            SalesAdvLetterLineCZZ."VAT Bus. Posting Group" := SalesAdvanceLetterLine."VAT Bus. Posting Group";
                            SalesAdvLetterLineCZZ."VAT Prod. Posting Group" := SalesAdvanceLetterLine."VAT Prod. Posting Group";
                            SalesAdvLetterLineCZZ.Amount := SalesAdvanceLetterLine.Amount;
                            SalesAdvLetterLineCZZ."VAT Amount" := SalesAdvanceLetterLine."VAT Amount";
                            SalesAdvLetterLineCZZ."Amount Including VAT" := SalesAdvanceLetterLine."Amount Including VAT";
                            if (SalesAdvLetterHeaderCZZ."Currency Factor" = 0) or (SalesAdvLetterHeaderCZZ."Currency Code" = '') then begin
                                SalesAdvLetterLineCZZ."Amount (LCY)" := SalesAdvLetterLineCZZ.Amount;
                                SalesAdvLetterLineCZZ."VAT Amount (LCY)" := SalesAdvLetterLineCZZ."VAT Amount";
                                SalesAdvLetterLineCZZ."Amount Including VAT (LCY)" := SalesAdvLetterLineCZZ."Amount Including VAT";
                            end else begin
                                SalesAdvLetterLineCZZ."Amount Including VAT (LCY)" := Round(SalesAdvLetterLineCZZ."Amount Including VAT" / SalesAdvLetterHeaderCZZ."Currency Factor");
                                SalesAdvLetterLineCZZ."VAT Amount (LCY)" := Round(SalesAdvLetterLineCZZ."VAT Amount" / SalesAdvLetterHeaderCZZ."Currency Factor");
                                SalesAdvLetterLineCZZ."Amount (LCY)" := SalesAdvLetterLineCZZ."Amount Including VAT (LCY)" - SalesAdvLetterLineCZZ."VAT Amount (LCY)";
                            end;
                            SalesAdvLetterLineCZZ."VAT %" := SalesAdvanceLetterLine."VAT %";
                            SalesAdvLetterLineCZZ."VAT Calculation Type" := SalesAdvanceLetterLine."VAT Calculation Type";
                            if VATPostingSetup.Get(SalesAdvLetterLineCZZ."VAT Bus. Posting Group", SalesAdvLetterLineCZZ."VAT Prod. Posting Group") then
                                SalesAdvLetterLineCZZ."VAT Clause Code" := VATPostingSetup."VAT Clause Code";
                            SalesAdvLetterLineCZZ."VAT Calculation Type" := SalesAdvanceLetterLine."VAT Calculation Type";
                            SalesAdvLetterLineCZZ."VAT Identifier" := SalesAdvanceLetterLine."VAT Identifier";
                            SalesAdvLetterLineCZZ.SystemId := SalesAdvanceLetterLine.SystemId;
                            SalesAdvLetterLineCZZ.Insert(false, true);
                        until SalesAdvanceLetterLine.Next() = 0;

                    UpdateSalesEntry(SalesAdvLetterHeaderCZZ);
                    UpdateSalesAdvanceApplication(SalesAdvLetterHeaderCZZ);
                end;
            until SalesAdvanceLetterHeader.Next() = 0;
        FeatureDataUpdateMgt.LogTask(FeatureDataUpdateStatus, SalesAdvanceLetterHeader.TableCaption(), StartDateTime);
    end;

    local procedure UpdateSalesEntry(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    var
        AdvanceLink: Record "Advance Link";
        SalesAdvanceLetterEntry1: Record "Sales Advance Letter Entry";
        SalesAdvanceLetterEntry2: Record "Sales Advance Letter Entry";
        SalesAdvLetterEntryCZZ1: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterEntryCZZ2: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterManagement: Codeunit "SalesAdvLetterManagement CZZ";
        CurrFactor: Decimal;
    begin
        if SalesAdvLetterHeaderCZZ.Status.AsInteger() = SalesAdvLetterHeaderCZZ.Status::New.AsInteger() then
            exit;

        SalesAdvLetterEntryCZZ1.LockTable();
        if SalesAdvLetterEntryCZZ1.FindLast() then;

        SalesAdvLetterHeaderCZZ.CalcFields("Amount Including VAT", "Amount Including VAT (LCY)");
        SalesAdvLetterManagement.AdvEntryInit(false);
        SalesAdvLetterManagement.AdvEntryInsert("Advance Letter Entry Type CZZ"::"Initial Entry", SalesAdvLetterHeaderCZZ."No.", SalesAdvLetterHeaderCZZ."Posting Date",
            SalesAdvLetterHeaderCZZ."Amount Including VAT", SalesAdvLetterHeaderCZZ."Amount Including VAT (LCY)",
            SalesAdvLetterHeaderCZZ."Currency Code", SalesAdvLetterHeaderCZZ."Currency Factor", SalesAdvLetterHeaderCZZ."No.",
            SalesAdvLetterHeaderCZZ."Shortcut Dimension 1 Code", SalesAdvLetterHeaderCZZ."Shortcut Dimension 2 Code", SalesAdvLetterHeaderCZZ."Dimension Set ID", false);

        AdvanceLink.Reset();
        AdvanceLink.SetRange(Type, AdvanceLink.Type::Sale);
        AdvanceLink.SetRange("Document No.", SalesAdvLetterHeaderCZZ."No.");
        AdvanceLink.SetRange("Entry Type", AdvanceLink."Entry Type"::"Link To Letter");
        if AdvanceLink.FindSet(true) then
            repeat
                SalesAdvLetterManagement.AdvEntryInit(false);
                SalesAdvLetterManagement.AdvEntryInitCustLedgEntryNo(AdvanceLink."CV Ledger Entry No.");
                if not CustLedgerEntry.Get(AdvanceLink."CV Ledger Entry No.") then
                    CustLedgerEntry.Init();
                SalesAdvLetterManagement.AdvEntryInsert("Advance Letter Entry Type CZZ"::Payment, SalesAdvLetterHeaderCZZ."No.", CustLedgerEntry."Posting Date",
                    -AdvanceLink.Amount, -AdvanceLink."Amount (LCY)",
                    SalesAdvLetterHeaderCZZ."Currency Code", CustLedgerEntry."Original Currency Factor", CustLedgerEntry."Document No.",
                    CustLedgerEntry."Global Dimension 1 Code", CustLedgerEntry."Global Dimension 2 Code", CustLedgerEntry."Dimension Set ID", false);

                SalesAdvLetterEntryCZZ1.FindLast();

                SalesAdvanceLetterEntry1.Reset();
                SalesAdvanceLetterEntry1.SetRange("Letter No.", SalesAdvLetterHeaderCZZ."No.");
                SalesAdvanceLetterEntry1.SetRange("Letter Line No.", AdvanceLink."Line No.");
                SalesAdvanceLetterEntry1.SetRange("Customer Entry No.", AdvanceLink."CV Ledger Entry No.");
                SalesAdvanceLetterEntry1.SetRange("Entry Type", SalesAdvanceLetterEntry1."Entry Type"::VAT);
                if SalesAdvanceLetterEntry1.FindSet() then
                    repeat
                        SalesAdvLetterManagement.AdvEntryInit(false);
                        if SalesAdvanceLetterEntry1.Cancelled then
                            SalesAdvLetterManagement.AdvEntryInitCancel();
                        SalesAdvLetterManagement.AdvEntryInitRelatedEntry(SalesAdvLetterEntryCZZ1."Entry No.");
                        SalesAdvLetterManagement.AdvEntryInitVAT(SalesAdvanceLetterEntry1."VAT Bus. Posting Group", SalesAdvanceLetterEntry1."VAT Prod. Posting Group", SalesAdvanceLetterEntry1."VAT Date",
                            SalesAdvanceLetterEntry1."VAT Entry No.", SalesAdvanceLetterEntry1."VAT %", SalesAdvanceLetterEntry1."VAT Identifier", "TAX Calculation Type"::"Normal VAT",
                            SalesAdvanceLetterEntry1."VAT Amount", SalesAdvanceLetterEntry1."VAT Amount (LCY)", SalesAdvanceLetterEntry1."VAT Base Amount", SalesAdvanceLetterEntry1."VAT Base Amount (LCY)");
                        SalesAdvLetterManagement.AdvEntryInsert("Advance Letter Entry Type CZZ"::"VAT Payment", SalesAdvLetterHeaderCZZ."No.", SalesAdvanceLetterEntry1."Posting Date",
                            SalesAdvanceLetterEntry1."VAT Base Amount" + SalesAdvanceLetterEntry1."VAT Amount", SalesAdvanceLetterEntry1."VAT Base Amount (LCY)" + SalesAdvanceLetterEntry1."VAT Amount (LCY)",
                            SalesAdvLetterEntryCZZ1."Currency Code", SalesAdvLetterEntryCZZ1."Currency Factor", SalesAdvanceLetterEntry1."Document No.",
                            SalesAdvLetterEntryCZZ1."Global Dimension 1 Code", SalesAdvLetterEntryCZZ1."Global Dimension 2 Code", SalesAdvLetterEntryCZZ1."Dimension Set ID", false);
                    until SalesAdvanceLetterEntry1.Next() = 0;

                SalesAdvanceLetterEntry1.SetRange("Entry Type", SalesAdvanceLetterEntry1."Entry Type"::Deduction);
                if SalesAdvanceLetterEntry1.FindSet() then
                    repeat
                        if not CustLedgerEntry.Get(SalesAdvanceLetterEntry1."Customer Entry No.") then
                            CustLedgerEntry.Init();
                        CurrFactor := CustLedgerEntry."Original Currency Factor";
                        if CurrFactor = 0 then
                            CurrFactor := 1;
                        SalesAdvLetterManagement.AdvEntryInit(false);
                        if SalesAdvanceLetterEntry1.Cancelled then
                            SalesAdvLetterManagement.AdvEntryInitCancel();
                        SalesAdvLetterManagement.AdvEntryInitCustLedgEntryNo(SalesAdvanceLetterEntry1."Customer Entry No.");
                        SalesAdvLetterManagement.AdvEntryInitRelatedEntry(SalesAdvLetterEntryCZZ1."Entry No.");
                        SalesAdvLetterManagement.AdvEntryInsert("Advance Letter Entry Type CZZ"::Usage, SalesAdvLetterHeaderCZZ."No.", SalesAdvanceLetterEntry1."Posting Date",
                            SalesAdvanceLetterEntry1.Amount, Round(SalesAdvanceLetterEntry1.Amount / CurrFactor),
                            SalesAdvanceLetterEntry1."Currency Code", CustLedgerEntry."Original Currency Factor", SalesAdvanceLetterEntry1."Document No.",
                            CustLedgerEntry."Global Dimension 1 Code", CustLedgerEntry."Global Dimension 2 Code", CustLedgerEntry."Dimension Set ID", false);

                        SalesAdvLetterEntryCZZ2.FindLast();

                        SalesAdvanceLetterEntry2.Reset();
                        SalesAdvanceLetterEntry2.SetRange("Letter No.", SalesAdvanceLetterEntry1."Letter No.");
                        SalesAdvanceLetterEntry2.SetRange("Letter Line No.", SalesAdvanceLetterEntry1."Letter Line No.");
                        SalesAdvanceLetterEntry2.SetRange("Entry Type", SalesAdvanceLetterEntry2."Entry Type"::"VAT Deduction");
                        SalesAdvanceLetterEntry2.SetRange("Document Type", SalesAdvanceLetterEntry1."Document Type");
                        SalesAdvanceLetterEntry2.SetRange("Document No.", SalesAdvanceLetterEntry1."Document No.");
                        SalesAdvanceLetterEntry2.SetRange("Sale Line No.", SalesAdvanceLetterEntry1."Sale Line No.");
                        SalesAdvanceLetterEntry2.SetRange("Deduction Line No.", SalesAdvanceLetterEntry1."Deduction Line No.");
                        SalesAdvanceLetterEntry2.SetRange("Customer Entry No.", SalesAdvanceLetterEntry1."Customer Entry No.");
                        if SalesAdvanceLetterEntry2.FindSet() then
                            repeat
                                SalesAdvLetterManagement.AdvEntryInit(false);
                                if SalesAdvanceLetterEntry2.Cancelled then
                                    SalesAdvLetterManagement.AdvEntryInitCancel();
                                SalesAdvLetterManagement.AdvEntryInitRelatedEntry(SalesAdvLetterEntryCZZ2."Entry No.");
                                SalesAdvLetterManagement.AdvEntryInitVAT(SalesAdvanceLetterEntry2."VAT Bus. Posting Group", SalesAdvanceLetterEntry2."VAT Prod. Posting Group", SalesAdvanceLetterEntry2."VAT Date",
                                    SalesAdvanceLetterEntry2."VAT Entry No.", SalesAdvanceLetterEntry2."VAT %", SalesAdvanceLetterEntry2."VAT Identifier", "TAX Calculation Type"::"Normal VAT",
                                    SalesAdvanceLetterEntry2."VAT Amount", SalesAdvanceLetterEntry2."VAT Amount (LCY)", SalesAdvanceLetterEntry2."VAT Base Amount", SalesAdvanceLetterEntry2."VAT Base Amount (LCY)");
                                SalesAdvLetterManagement.AdvEntryInsert("Advance Letter Entry Type CZZ"::"VAT Usage", SalesAdvLetterHeaderCZZ."No.", SalesAdvanceLetterEntry2."Posting Date",
                                    SalesAdvanceLetterEntry2."VAT Base Amount" + SalesAdvanceLetterEntry2."VAT Amount", SalesAdvanceLetterEntry2."VAT Base Amount (LCY)" + SalesAdvanceLetterEntry2."VAT Amount (LCY)",
                                    SalesAdvanceLetterEntry2."Currency Code", CustLedgerEntry."Original Currency Factor", SalesAdvanceLetterEntry2."Document No.",
                                    CustLedgerEntry."Global Dimension 1 Code", CustLedgerEntry."Global Dimension 2 Code", CustLedgerEntry."Dimension Set ID", false);
                            until SalesAdvanceLetterEntry2.Next() = 0;

                        SalesAdvanceLetterEntry2.SetRange("Entry Type", SalesAdvanceLetterEntry2."Entry Type"::"VAT Rate");
                        if SalesAdvanceLetterEntry2.FindSet() then
                            repeat
                                SalesAdvLetterManagement.AdvEntryInit(false);
                                if SalesAdvanceLetterEntry2.Cancelled then
                                    SalesAdvLetterManagement.AdvEntryInitCancel();
                                SalesAdvLetterManagement.AdvEntryInitRelatedEntry(SalesAdvLetterEntryCZZ2."Entry No.");
                                SalesAdvLetterManagement.AdvEntryInitVAT(SalesAdvanceLetterEntry2."VAT Bus. Posting Group", SalesAdvanceLetterEntry2."VAT Prod. Posting Group", SalesAdvanceLetterEntry2."VAT Date",
                                    0, SalesAdvanceLetterEntry2."VAT %", SalesAdvanceLetterEntry2."VAT Identifier", "TAX Calculation Type"::"Normal VAT",
                                    0, SalesAdvanceLetterEntry2."VAT Amount (LCY)", 0, SalesAdvanceLetterEntry2."VAT Base Amount (LCY)");
                                SalesAdvLetterManagement.AdvEntryInsert("Advance Letter Entry Type CZZ"::"VAT Rate", SalesAdvLetterHeaderCZZ."No.", SalesAdvanceLetterEntry2."Posting Date",
                                    0, SalesAdvanceLetterEntry2."VAT Base Amount (LCY)" + SalesAdvanceLetterEntry2."VAT Amount (LCY)", '', 0, SalesAdvanceLetterEntry2."Document No.",
                                    CustLedgerEntry."Global Dimension 1 Code", CustLedgerEntry."Global Dimension 2 Code", CustLedgerEntry."Dimension Set ID", false);
                            until SalesAdvanceLetterEntry2.Next() = 0;
                    until SalesAdvanceLetterEntry1.Next() = 0;

                AdvanceLink.Amount := 0;
                AdvanceLink."Amount (LCY)" := 0;
                AdvanceLink.Modify(false);
            until AdvanceLink.Next() = 0;
    end;

    local procedure UpdateSalesAdvanceApplication(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    var
        AdvanceLetterLineRelation: Record "Advance Letter Line Relation";
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        SalesHeader: Record "Sales Header";
        AmtToDeduct: Decimal;
        Continue: Boolean;
    begin
        AdvanceLetterLineRelation.SetRange(Type, AdvanceLetterLineRelation.Type::Sale);
        AdvanceLetterLineRelation.SetRange("Letter No.", SalesAdvLetterHeaderCZZ."No.");
        if AdvanceLetterLineRelation.FindSet() then begin
            repeat
                case AdvanceLetterLineRelation."Document Type" of
                    AdvanceLetterLineRelation."Document Type"::Order:
                        Continue := SalesHeader.Get(SalesHeader."Document Type"::Order, AdvanceLetterLineRelation."Document No.");
                    AdvanceLetterLineRelation."Document Type"::Invoice:
                        Continue := SalesHeader.Get(SalesHeader."Document Type"::Invoice, AdvanceLetterLineRelation."Document No.");
                    else
                        Continue := false;
                end;
                if Continue then begin
                    AdvanceLetterApplicationCZZ.Init();
                    AdvanceLetterApplicationCZZ."Advance Letter Type" := AdvanceLetterApplicationCZZ."Advance Letter Type"::Sales;
                    AdvanceLetterApplicationCZZ."Advance Letter No." := AdvanceLetterLineRelation."Letter No.";
                    case AdvanceLetterLineRelation."Document Type" of
                        AdvanceLetterLineRelation."Document Type"::Invoice:
                            AdvanceLetterApplicationCZZ."Document Type" := AdvanceLetterApplicationCZZ."Document Type"::"Sales Invoice";
                        AdvanceLetterLineRelation."Document Type"::Order:
                            AdvanceLetterApplicationCZZ."Document Type" := AdvanceLetterApplicationCZZ."Document Type"::"Sales Order";
                    end;
                    AdvanceLetterApplicationCZZ."Document No." := AdvanceLetterLineRelation."Document No.";
                    if AdvanceLetterLineRelation."Primary Link" then
                        AmtToDeduct := AdvanceLetterLineRelation.Amount
                    else
                        AmtToDeduct := AdvanceLetterLineRelation."Amount To Deduct";

                    if AdvanceLetterApplicationCZZ.Find() then begin
                        AdvanceLetterApplicationCZZ.Amount += AmtToDeduct;
                        AdvanceLetterApplicationCZZ.Modify();
                    end else begin
                        AdvanceLetterApplicationCZZ.Amount := AmtToDeduct;
                        AdvanceLetterApplicationCZZ.Insert();
                    end;
                end;
            until AdvanceLetterLineRelation.Next() = 0;

            AdvanceLetterLineRelation.DeleteAll();
        end;
    end;

    local procedure UpdateVATPostingSetup(FeatureDataUpdateStatus: Record "Feature Data Update Status")
    var
        RecModify: Boolean;
        StartDateTime: DateTime;
    begin
        StartDateTime := CurrentDateTime();
        if VATPostingSetup.FindSet() then
            repeat
                RecModify := false;
                if VATPostingSetup."Sales Adv. Letter Account CZZ" = '' then begin
                    VATPostingSetup."Sales Adv. Letter Account CZZ" := VATPostingSetup."Sales Advance Offset VAT Acc.";
                    RecModify := true;
                end;
                if VATPostingSetup."Sales Adv. Letter VAT Acc. CZZ" = '' then begin
                    VATPostingSetup."Sales Adv. Letter VAT Acc. CZZ" := VATPostingSetup."Sales Advance VAT Account";
                    RecModify := true;
                end;
                if VATPostingSetup."Purch. Adv. Letter Account CZZ" = '' then begin
                    VATPostingSetup."Purch. Adv. Letter Account CZZ" := VATPostingSetup."Purch. Advance Offset VAT Acc.";
                    RecModify := true;
                end;
                if VATPostingSetup."Purch. Adv.Letter VAT Acc. CZZ" = '' then begin
                    VATPostingSetup."Purch. Adv.Letter VAT Acc. CZZ" := VATPostingSetup."Purch. Advance VAT Account";
                    RecModify := true;
                end;
                if RecModify then
                    VATPostingSetup.Modify();
            until VATPostingSetup.Next() = 0;
        FeatureDataUpdateMgt.LogTask(FeatureDataUpdateStatus, VATPostingSetup.TableCaption(), StartDateTime);
    end;

    local procedure GetStatus(OldStatus: Option Open,"Pending Payment","Pending Invoice","Pending Final Invoice",Closed,"Pending Approval"): Enum "Advance Letter Doc. Status CZZ"
    begin
        case OldStatus of
            OldStatus::Open:
                exit("Advance Letter Doc. Status CZZ"::New);
            OldStatus::"Pending Payment", OldStatus::"Pending Approval":
                exit("Advance Letter Doc. Status CZZ"::"To Pay");
            OldStatus::"Pending Invoice", OldStatus::"Pending Final Invoice":
                exit("Advance Letter Doc. Status CZZ"::"To Use");
            OldStatus::Closed:
                exit("Advance Letter Doc. Status CZZ"::Closed);
        end;
    end;

    local procedure UpdateVATEntries(FeatureDataUpdateStatus: Record "Feature Data Update Status")
    var
        VATEntry2: Record "VAT Entry";
        StartDateTime: DateTime;
    begin
        StartDateTime := CurrentDateTime();
        VATEntry.Reset();
        VATEntry.SetRange("Prepayment Type", VATEntry."Prepayment Type"::Advance);
        VATEntry.SetFilter("Advance Base", '<>0');
        if VATEntry.FindSet() then
            repeat
                VATEntry2 := VATEntry;
                VATEntry2.Base := VATEntry2."Advance Base";
                VATEntry2."Advance Base" := 0;
                VATEntry2."Advance Letter No. CZZ" := VATEntry2."Advance Letter No.";
                VATEntry2.Modify();
            until VATEntry.Next() = 0;
        FeatureDataUpdateMgt.LogTask(FeatureDataUpdateStatus, VATEntry.TableCaption(), StartDateTime);
    end;

    local procedure UpdateCustomerLedgerEntries(FeatureDataUpdateStatus: Record "Feature Data Update Status")
    var
        StartDateTime: DateTime;
    begin
        StartDateTime := CurrentDateTime();
        CustLedgerEntry.Reset();
        CustLedgerEntry.SetRange(Prepayment, true);
        CustLedgerEntry.SetRange("Prepayment Type", CustLedgerEntry."Prepayment Type"::Advance);
        if CustLedgerEntry.FindSet(true) then
            repeat
                CustLedgerEntry."Adv. Letter Template Code CZZ" := GetSalesAdvanceLetterTemplateCode(CustLedgerEntry."Entry No.");
                CustLedgerEntry."Advance Letter No. CZZ" := GetSalesAdvanceLetterNo(CustLedgerEntry."Entry No.");
                CustLedgerEntry.Modify();
            until CustLedgerEntry.Next() = 0;
        FeatureDataUpdateMgt.LogTask(FeatureDataUpdateStatus, CustLedgerEntry.TableCaption(), StartDateTime);
    end;

    local procedure GetSalesAdvanceLetterTemplateCode(EntryNo: Integer): Code[20]
    var
        SalesAdvanceLetterEntry: Record "Sales Advance Letter Entry";
    begin
        SalesAdvanceLetterEntry.SetRange("Customer Entry No.", EntryNo);
        if SalesAdvanceLetterEntry.FindFirst() then
            exit('P_' + SalesAdvanceLetterEntry."Template Name");
        exit('P_');
    end;

    local procedure GetSalesAdvanceLetterNo(EntryNo: Integer): Code[20]
    var
        AdvanceLink: Record "Advance Link";
    begin
        AdvanceLink.SetRange("CV Ledger Entry No.", EntryNo);
        AdvanceLink.SetRange(Type, AdvanceLink.Type::Sale);
        AdvanceLink.SetRange("Entry Type", AdvanceLink."Entry Type"::"Link To Letter");
        if AdvanceLink.FindFirst() and (AdvanceLink.Count() = 1) then
            exit(AdvanceLink."Document No.");
    end;

    local procedure UpdateVendorLedgerEntries(FeatureDataUpdateStatus: Record "Feature Data Update Status")
    var
        StartDateTime: DateTime;
    begin
        StartDateTime := CurrentDateTime();
        VendorLedgerEntry.Reset();
        VendorLedgerEntry.SetRange(Prepayment, true);
        VendorLedgerEntry.SetRange("Prepayment Type", VendorLedgerEntry."Prepayment Type"::Advance);
        if VendorLedgerEntry.FindSet(true) then
            repeat
                VendorLedgerEntry."Adv. Letter Template Code CZZ" := GetPurchAdvanceLetterTemplateCode(VendorLedgerEntry."Entry No.");
                VendorLedgerEntry."Advance Letter No. CZZ" := GetPurchAdvanceLetterNo(VendorLedgerEntry."Entry No.");
                VendorLedgerEntry.Modify();
            until VendorLedgerEntry.Next() = 0;
        FeatureDataUpdateMgt.LogTask(FeatureDataUpdateStatus, VendorLedgerEntry.TableCaption(), StartDateTime);
    end;

    local procedure GetPurchAdvanceLetterTemplateCode(EntryNo: Integer): Code[20]
    var
        PurchAdvanceLetterEntry: Record "Purch. Advance Letter Entry";
    begin
        PurchAdvanceLetterEntry.SetRange("Vendor Entry No.", EntryNo);
        if PurchAdvanceLetterEntry.FindFirst() then
            exit('N_' + PurchAdvanceLetterEntry."Template Name");
        exit('N_');
    end;

    local procedure GetPurchAdvanceLetterNo(EntryNo: Integer): Code[20]
    var
        AdvanceLink: Record "Advance Link";
    begin
        AdvanceLink.SetRange("CV Ledger Entry No.", EntryNo);
        AdvanceLink.SetRange(Type, AdvanceLink.Type::Purchase);
        AdvanceLink.SetRange("Entry Type", AdvanceLink."Entry Type"::"Link To Letter");
        if AdvanceLink.FindFirst() and (AdvanceLink.Count() = 1) then
            exit(AdvanceLink."Document No.");
    end;

    local procedure UpdateVATStatementLines(FeatureDataUpdateStatus: Record "Feature Data Update Status")
    var
        StartDateTime: DateTime;
    begin
        StartDateTime := CurrentDateTime();
        VATStatementLine.SetRange("Amount Type", VATStatementLine."Amount Type"::"Adv. Base");
        VATStatementLine.DeleteAll();
        FeatureDataUpdateMgt.LogTask(FeatureDataUpdateStatus, VATStatementLine.TableCaption(), StartDateTime);
    end;

    local procedure UpdateGenJournalLines(FeatureDataUpdateStatus: Record "Feature Data Update Status")
    var
        GenJournalLine2: Record "Gen. Journal Line";
        StartDateTime: DateTime;
    begin
        StartDateTime := CurrentDateTime();
        GenJournalLine.Reset();
        GenJournalLine.SetFilter("Advance Letter Link Code", '<>%1', '');
        if GenJournalLine.FindSet() then
            repeat
                GenJournalLine2 := GenJournalLine;
                case GenJournalLine2."Account Type" of
                    GenJournalLine2."Account Type"::Customer:
                        PrepaymentLinksManagement.UnLinkWholeSalesLetter(GenJournalLine2."Advance Letter Link Code");
                    GenJournalLine2."Account Type"::Vendor:
                        PrepaymentLinksManagement.UnLinkWholePurchLetter(GenJournalLine2."Advance Letter Link Code");
                end;
                GenJournalLine2.Validate("Advance Letter Link Code", '');
                GenJournalLine2.Validate(Prepayment, false);
                GenJournalLine2.Validate("Prepayment Type", GenJournalLine2."Prepayment Type"::" ");
                GenJournalLine2.Modify();
            until GenJournalLine.Next() = 0;
        FeatureDataUpdateMgt.LogTask(FeatureDataUpdateStatus, GenJournalLine.TableCaption(), StartDateTime);
    end;

    local procedure UpdateCashDocumentLinesCZP(FeatureDataUpdateStatus: Record "Feature Data Update Status")
    var
        CashDocumentLineCZP2: Record "Cash Document Line CZP";
        StartDateTime: DateTime;
    begin
        StartDateTime := CurrentDateTime();
        CashDocumentLineCZP.Reset();
        CashDocumentLineCZP.SetFilter("Advance Letter Link Code", '<>%1', '');
        if CashDocumentLineCZP.FindSet() then
            repeat
                CashDocumentLineCZP2 := CashDocumentLineCZP;
                case CashDocumentLineCZP2."Account Type" of
                    CashDocumentLineCZP2."Account Type"::Customer:
                        PrepaymentLinksManagement.UnLinkWholeSalesLetter(CashDocumentLineCZP2."Advance Letter Link Code");
                    CashDocumentLineCZP2."Account Type"::Vendor:
                        PrepaymentLinksManagement.UnLinkWholePurchLetter(CashDocumentLineCZP2."Advance Letter Link Code");
                end;
                CashDocumentLineCZP2.Validate("Advance Letter Link Code", '');
                CashDocumentLineCZP2.Modify();
            until CashDocumentLineCZP.Next() = 0;
        FeatureDataUpdateMgt.LogTask(FeatureDataUpdateStatus, CashDocumentLineCZP.TableCaption(), StartDateTime);
    end;

    local procedure UpdatePaymentOrderLinesCZB(FeatureDataUpdateStatus: Record "Feature Data Update Status")
    var
        PaymentOrderLineCZB: Record "Payment Order Line CZB";
        StartDateTime: DateTime;
    begin
        StartDateTime := CurrentDateTime();
        PaymentOrderLine.Reset();
        PaymentOrderLine.SetFilter("Letter No.", '<>%1', '');
        if PaymentOrderLine.FindSet() then
            repeat
                if PaymentOrderLineCZB.Get(PaymentOrderLine."No.", PaymentOrderLine."Line No.") then begin
                    PaymentOrderLineCZB."Purch. Advance Letter No. CZZ" := PaymentOrderLine."Letter No.";
                    PaymentOrderLineCZB.Modify(false);
                end;
            until PaymentOrderLine.Next() = 0;
        FeatureDataUpdateMgt.LogTask(FeatureDataUpdateStatus, PaymentOrderLine.TableCaption(), StartDateTime);
    end;

    local procedure UpdateIssPaymentOrderLinesCZB(FeatureDataUpdateStatus: Record "Feature Data Update Status")
    var
        IssPaymentOrderLineCZB: Record "Iss. Payment Order Line CZB";
        StartDateTime: DateTime;
    begin
        StartDateTime := CurrentDateTime();
        IssuedPaymentOrderLine.Reset();
        IssuedPaymentOrderLine.SetFilter("Letter No.", '<>%1', '');
        if IssuedPaymentOrderLine.FindSet() then
            repeat
                if IssPaymentOrderLineCZB.Get(IssuedPaymentOrderLine."No.", IssuedPaymentOrderLine."Line No.") then begin
                    IssPaymentOrderLineCZB."Purch. Advance Letter No. CZZ" := IssuedPaymentOrderLine."Letter No.";
                    IssPaymentOrderLineCZB.Modify(false);
                end;
            until IssuedPaymentOrderLine.Next() = 0;
        FeatureDataUpdateMgt.LogTask(FeatureDataUpdateStatus, IssuedPaymentOrderLine.TableCaption(), StartDateTime);
    end;

    local procedure UpdateReportSelections(FeatureDataUpdateStatus: Record "Feature Data Update Status")
    var
        StartDateTime: DateTime;
    begin
        StartDateTime := CurrentDateTime();
        ReportSelections.SetRange("Report ID", Report::"Purchase - Invoice");
        ReportSelections.ModifyAll("Report ID", Report::"Purchase-Invoice with Adv. CZZ");
        ReportSelections.SetRange("Report ID", Report::"Sales Invoice CZL");
        ReportSelections.ModifyAll("Report ID", Report::"Sales - Invoice with Adv. CZZ");
        FeatureDataUpdateMgt.LogTask(FeatureDataUpdateStatus, ReportSelections.TableCaption(), StartDateTime);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCountRecords(var TempDocumentEntry: Record "Document Entry" temporary)
    begin
    end;
#endif
}
