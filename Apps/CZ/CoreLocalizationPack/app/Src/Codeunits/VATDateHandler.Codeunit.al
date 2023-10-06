codeunit 11742 "VAT Date Handler CZL"
{

    Permissions = tabledata "G/L Entry" = m,
                  tabledata "VAT Entry" = m,
                  tabledata "Sales Invoice Header" = m,
                  tabledata "Sales Cr.Memo Header" = m,
                  tabledata "Purch. Inv. Header" = m,
                  tabledata "Purch. Cr. Memo Hdr." = m,
                  tabledata "Service Invoice Header" = m,
                  tabledata "Service Cr.Memo Header" = m,
                  tabledata "Cust. Ledger Entry" = m,
                  tabledata "Vendor Ledger Entry" = m;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        UserSetup: Record "User Setup";
        ErrorMessageManagement: Codeunit "Error Message Management";
        VATReportingDateMgt: Codeunit "VAT Reporting Date Mgt";
        ForwardLinkMgt: Codeunit "Forward Link Mgt.";
        VatDateNotAllowedErr: Label '%1 %2 is not within your range of allowed dates.', Comment = '%1 - VAT Date FieldCaption, %2 = VAT Date';

    [EventSubscriber(ObjectType::Table, Database::"G/L Entry", 'OnAfterCopyGLEntryFromGenJnlLine', '', false, false)]
    local procedure UpdateVatDateOnAfterCopyGenJnlLineFromGLEntry(var GLEntry: Record "G/L Entry"; var GenJournalLine: Record "Gen. Journal Line")
    begin
#if not CLEAN22
#pragma warning disable AL0432
        GLEntry."VAT Date CZL" := GenJournalLine."VAT Date CZL";
#pragma warning restore AL0432
#endif
        GLEntry."VAT Reporting Date" := GenJournalLine."VAT Reporting Date";
    end;

#if not CLEAN23
#pragma warning disable AL0432
    [EventSubscriber(ObjectType::Table, Database::"Invoice Post. Buffer", 'OnAfterInvPostBufferPrepareSales', '', false, false)]
    local procedure UpdateVatDateInvoicePostBufferFromSalesHeader(var InvoicePostBuffer: Record "Invoice Post. Buffer"; var SalesLine: Record "Sales Line")
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        if not SalesHeader.IsReplaceVATDateEnabled() then
            SalesHeader."VAT Reporting Date" := SalesHeader."VAT Date CZL";
        InvoicePostBuffer."VAT Date CZL" := SalesHeader."VAT Reporting Date";
        InvoicePostBuffer."Original Doc. VAT Date CZL" := SalesHeader."Original Doc. VAT Date CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Invoice Post. Buffer", 'OnAfterInvPostBufferPreparePurchase', '', false, false)]
    local procedure UpdateVatDateInvoicePostBufferFromPurchaseHeader(var InvoicePostBuffer: Record "Invoice Post. Buffer"; var PurchaseLine: Record "Purchase Line")
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
        if not PurchaseHeader.IsReplaceVATDateEnabled() then
            PurchaseHeader."VAT Reporting Date" := PurchaseHeader."VAT Date CZL";
        InvoicePostBuffer."VAT Date CZL" := PurchaseHeader."VAT Reporting Date";
        InvoicePostBuffer."Original Doc. VAT Date CZL" := PurchaseHeader."Original Doc. VAT Date CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Invoice Post. Buffer", 'OnAfterInvPostBufferPrepareService', '', false, false)]
    local procedure UpdateVatDateInvoicePostBufferFromServiceHeader(var InvoicePostBuffer: Record "Invoice Post. Buffer"; var ServiceLine: Record "Service Line")
    var
        ServiceHeader: Record "Service Header";
    begin
        ServiceHeader.Get(ServiceLine."Document Type", ServiceLine."Document No.");
        if not ServiceHeader.IsReplaceVATDateEnabled() then
            ServiceHeader."VAT Reporting Date" := ServiceHeader."VAT Date CZL";
        InvoicePostBuffer."VAT Date CZL" := ServiceHeader."VAT Reporting Date";
    end;

#pragma warning restore AL0432
#endif
    [EventSubscriber(ObjectType::Table, Database::"Invoice Posting Buffer", 'OnAfterPrepareSales', '', false, false)]
    local procedure UpdateInvoicePostingBufferOnAfterPrepareSales(var InvoicePostingBuffer: Record "Invoice Posting Buffer"; var SalesLine: Record "Sales Line")
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
#if not CLEAN22
#pragma warning disable AL0432
        if not SalesHeader.IsReplaceVATDateEnabled() then
            SalesHeader."VAT Reporting Date" := SalesHeader."VAT Date CZL";
#pragma warning restore AL0432
#endif
        InvoicePostingBuffer."VAT Date CZL" := SalesHeader."VAT Reporting Date";
        InvoicePostingBuffer."Original Doc. VAT Date CZL" := SalesHeader."Original Doc. VAT Date CZL";
        InvoicePostingBuffer."Correction CZL" := SalesHeader.Correction xor SalesLine."Negative CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Invoice Posting Buffer", 'OnAfterPreparePurchase', '', false, false)]
    local procedure UpdateInvoicePostingBufferOnAfterPreparePurchase(var InvoicePostingBuffer: Record "Invoice Posting Buffer"; var PurchaseLine: Record "Purchase Line")
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
#if not CLEAN22
#pragma warning disable AL0432
        if not PurchaseHeader.IsReplaceVATDateEnabled() then
            PurchaseHeader."VAT Reporting Date" := PurchaseHeader."VAT Date CZL";
#pragma warning restore AL0432
#endif
        InvoicePostingBuffer."VAT Date CZL" := PurchaseHeader."VAT Reporting Date";
        InvoicePostingBuffer."Original Doc. VAT Date CZL" := PurchaseHeader."Original Doc. VAT Date CZL";
        InvoicePostingBuffer."Correction CZL" := PurchaseHeader.Correction xor PurchaseLine."Negative CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Invoice Posting Buffer", 'OnAfterPrepareService', '', false, false)]
    local procedure UpdateInvoicePostingBufferOnAfterPrepareService(var InvoicePostingBuffer: Record "Invoice Posting Buffer"; var ServiceLine: Record "Service Line")
    var
        ServiceHeader: Record "Service Header";
    begin
        ServiceHeader.Get(ServiceLine."Document Type", ServiceLine."Document No.");
#if not CLEAN22
#pragma warning disable AL0432
        if not ServiceHeader.IsReplaceVATDateEnabled() then
            ServiceHeader."VAT Reporting Date" := ServiceHeader."VAT Date CZL";
#pragma warning restore AL0432
#endif
        InvoicePostingBuffer."VAT Date CZL" := ServiceHeader."VAT Reporting Date";
        InvoicePostingBuffer."Correction CZL" := ServiceHeader.Correction xor ServiceLine."Negative CZL";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Posting To G/L", 'OnPostInvtPostBufOnBeforeSetAmt', '', false, false)]
    local procedure ClearVatDateOnPostInvtPostBufOnBeforeSetAmt(var GenJournalLine: Record "Gen. Journal Line")
    begin
#if not CLEAN22
#pragma warning disable AL0432
        GenJournalLine."VAT Date CZL" := 0D;
#pragma warning restore AL0432
#endif
        GenJournalLine."VAT Reporting Date" := 0D;
        GenJournalLine."Original Doc. VAT Date CZL" := 0D;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"G/L Entry-Edit", 'OnBeforeGLLedgEntryModify', '', false, false)]
    local procedure MyProcedure(var GLEntry: Record "G/L Entry"; FromGLEntry: Record "G/L Entry")
    begin
#if not CLEAN22
#pragma warning disable AL0432
        GLEntry."VAT Date CZL" := FromGLEntry."VAT Date CZL";
#pragma warning restore AL0432
#endif
        GLEntry."VAT Reporting Date" := FromGLEntry."VAT Reporting Date";
    end;

    procedure VATDateNotAllowed(VATDate: Date): Boolean
    var
        SetupRecordID: RecordId;
    begin
        exit(IsVATDateCZLNotAllowed(VATDate, SetupRecordID));
    end;

    procedure VATPeriodCZLCheck(VATDate: Date)
    var
        VATPeriodCZL: Record "VAT Period CZL";
        VATPeriodNotExistErr: Label '%1 does not exist for date %2.', Comment = '%1 = VAT Period TableCaption, %2 = VAT Date';
    begin
        VATPeriodCZL.SetRange("Starting Date", 0D, VATDate);
        if VATPeriodCZL.FindLast() then
            VATPeriodCZL.TestField(Closed, false)
        else
            Error(VATPeriodNotExistErr, VATPeriodCZL.TableCaption(), VATDate);
    end;

    procedure IsVATDateCZLNotAllowed(VATDate: Date; var SetupRecordID: RecordId): Boolean
    var
        VATAllowPostingFrom: Date;
        VATAllowPostingTo: Date;
    begin
        if UserId <> '' then
            if UserSetup.Get(UserId) then begin
                VATAllowPostingFrom := UserSetup."Allow VAT Posting From CZL";
                VATAllowPostingTo := UserSetup."Allow VAT Posting To CZL";
                SetupRecordID := UserSetup.RecordId;
            end;
        if (VATAllowPostingFrom = 0D) and (VATAllowPostingTo = 0D) then begin
            GeneralLedgerSetup.Get();
            VATAllowPostingFrom := GeneralLedgerSetup."Allow VAT Posting From CZL";
            VATAllowPostingTo := GeneralLedgerSetup."Allow VAT Posting To CZL";
            SetupRecordID := GeneralLedgerSetup.RecordId;
        end;
        if VATAllowPostingTo = 0D then
            VATAllowPostingTo := DMY2Date(31, 12, 9999);
        exit((VATDate < VATAllowPostingFrom) or (VATDate > VATAllowPostingTo));
    end;

    procedure CheckVATDateCZL(GenJournalLine: Record "Gen. Journal Line")
    var
        VATRangeErr: Label ' %1 is not within your range of allowed VAT dates', Comment = '%1 = VAT Date';
    begin
#if not CLEAN22
#pragma warning disable AL0432
        if not GenJournalLine.IsReplaceVATDateEnabled() then begin
            GeneralLedgerSetup.Get();
            if not GeneralLedgerSetup."Use VAT Date CZL" then
                GenJournalLine.TestField("VAT Date CZL", GenJournalLine."Posting Date")
            else begin
                GenJournalLine.TestField("VAT Date CZL");
                if VATDateNotAllowed(GenJournalLine."VAT Date CZL") then
                    GenJournalLine.FieldError("VAT Date CZL", StrSubstNo(VATRangeErr, GenJournalLine."VAT Date CZL"));
                VATPeriodCZLCheck(GenJournalLine."VAT Date CZL");
            end;
            exit;
        end;
#pragma warning restore AL0432
#endif
        if not VATReportingDateMgt.IsVATDateEnabled() then
            GenJournalLine.TestField("VAT Reporting Date", GenJournalLine."Posting Date")
        else begin
            GenJournalLine.TestField("VAT Reporting Date");
            if VATDateNotAllowed(GenJournalLine."VAT Reporting Date") then
                GenJournalLine.FieldError("VAT Reporting Date", StrSubstNo(VATRangeErr, GenJournalLine."VAT Reporting Date"));
            VATPeriodCZLCheck(GenJournalLine."VAT Reporting Date");
        end;
    end;

    procedure CheckVATDateCZL(var SalesHeader: Record "Sales Header")
    var
        SetupRecID: RecordId;
    begin
#if not CLEAN22
#pragma warning disable AL0432
        if not SalesHeader.IsReplaceVATDateEnabled() then begin
            GeneralLedgerSetup.Get();
            if not GeneralLedgerSetup."Use VAT Date CZL" then
                SalesHeader.TestField("VAT Date CZL", SalesHeader."Posting Date")
            else begin
                SalesHeader.TestField("VAT Date CZL");
                if IsVATDateCZLNotAllowed(SalesHeader."VAT Date CZL", SetupRecID) then
                    ErrorMessageManagement.LogContextFieldError(
                    SalesHeader.FieldNo(SalesHeader."VAT Date CZL"), StrSubstNo(VatDateNotAllowedErr, SalesHeader.FieldCaption(SalesHeader."VAT Date CZL"), SalesHeader."VAT Date CZL"),
                    SetupRecID, ErrorMessageManagement.GetFieldNo(SetupRecID.TableNo, GeneralLedgerSetup.FieldName("Allow VAT Posting From CZL")),
                    ForwardLinkMgt.GetHelpCodeForAllowedPostingDate());
                VATPeriodCZLCheck(SalesHeader."VAT Date CZL");
            end;
            exit;
        end;
#pragma warning restore AL0432
#endif
        if not VATReportingDateMgt.IsVATDateEnabled() then
            SalesHeader.TestField("VAT Reporting Date", SalesHeader."Posting Date")
        else begin
            SalesHeader.TestField("VAT Reporting Date");
            if IsVATDateCZLNotAllowed(SalesHeader."VAT Reporting Date", SetupRecID) then
                ErrorMessageManagement.LogContextFieldError(
                    SalesHeader.FieldNo(SalesHeader."VAT Reporting Date"), StrSubstNo(VatDateNotAllowedErr, SalesHeader.FieldCaption(SalesHeader."VAT Reporting Date"), SalesHeader."VAT Reporting Date"),
                    SetupRecID, ErrorMessageManagement.GetFieldNo(SetupRecID.TableNo, GeneralLedgerSetup.FieldName("Allow VAT Posting From CZL")),
                    ForwardLinkMgt.GetHelpCodeForAllowedPostingDate());
            VATPeriodCZLCheck(SalesHeader."VAT Reporting Date");
        end;
    end;

    procedure CheckVATDateCZL(var PurchaseHeader: Record "Purchase Header")
    var
        SetupRecID: RecordId;
        MustBeLessOrEqualErr: Label 'must be less or equal to %1', Comment = '%1 = fieldcaption of VAT Date CZL';
    begin
#if not CLEAN22
#pragma warning disable AL0432
        if not PurchaseHeader.IsReplaceVATDateEnabled() then begin
            GeneralLedgerSetup.Get();
            if not GeneralLedgerSetup."Use VAT Date CZL" then
                PurchaseHeader.TestField("VAT Date CZL", PurchaseHeader."Posting Date")
            else begin
                PurchaseHeader.TestField("VAT Date CZL");
                if IsVATDateCZLNotAllowed(PurchaseHeader."VAT Date CZL", SetupRecID) then
                    ErrorMessageManagement.LogContextFieldError(
                    PurchaseHeader.FieldNo(PurchaseHeader."VAT Date CZL"), StrSubstNo(VatDateNotAllowedErr, PurchaseHeader.FieldCaption(PurchaseHeader."VAT Date CZL"), PurchaseHeader."VAT Date CZL"),
                    SetupRecID, ErrorMessageManagement.GetFieldNo(SetupRecID.TableNo, GeneralLedgerSetup.FieldName("Allow VAT Posting From CZL")),
                    ForwardLinkMgt.GetHelpCodeForAllowedPostingDate());
                VATPeriodCZLCheck(PurchaseHeader."VAT Date CZL");
                if PurchaseHeader.Invoice then
                    PurchaseHeader.TestField("Original Doc. VAT Date CZL");
                if PurchaseHeader."Original Doc. VAT Date CZL" > PurchaseHeader."VAT Date CZL" then
                    PurchaseHeader.FieldError("Original Doc. VAT Date CZL", StrSubstNo(MustBeLessOrEqualErr, PurchaseHeader.FieldCaption(PurchaseHeader."VAT Date CZL")));
            end;
            exit;
        end;
#pragma warning restore AL0432
#endif
        if not VATReportingDateMgt.IsVATDateEnabled() then
            PurchaseHeader.TestField("VAT Reporting Date", PurchaseHeader."Posting Date")
        else begin
            PurchaseHeader.TestField("VAT Reporting Date");
            if IsVATDateCZLNotAllowed(PurchaseHeader."VAT Reporting Date", SetupRecID) then
                ErrorMessageManagement.LogContextFieldError(
                    PurchaseHeader.FieldNo(PurchaseHeader."VAT Reporting Date"), StrSubstNo(VatDateNotAllowedErr, PurchaseHeader.FieldCaption(PurchaseHeader."VAT Reporting Date"), PurchaseHeader."VAT Reporting Date"),
                    SetupRecID, ErrorMessageManagement.GetFieldNo(SetupRecID.TableNo, GeneralLedgerSetup.FieldName("Allow VAT Posting From CZL")),
                    ForwardLinkMgt.GetHelpCodeForAllowedPostingDate());
            VATPeriodCZLCheck(PurchaseHeader."VAT Reporting Date");
            if PurchaseHeader.Invoice then
                PurchaseHeader.TestField("Original Doc. VAT Date CZL");
            if PurchaseHeader."Original Doc. VAT Date CZL" > PurchaseHeader."VAT Reporting Date" then
                PurchaseHeader.FieldError("Original Doc. VAT Date CZL", StrSubstNo(MustBeLessOrEqualErr, PurchaseHeader.FieldCaption(PurchaseHeader."VAT Reporting Date")));
        end;
    end;

    procedure CheckVATDateCZL(var ServiceHeader: Record "Service Header")
    var
        SetupRecID: RecordId;
    begin
#if not CLEAN22
#pragma warning disable AL0432
        if not ServiceHeader.IsReplaceVATDateEnabled() then begin
            GeneralLedgerSetup.Get();
            if not GeneralLedgerSetup."Use VAT Date CZL" then
                ServiceHeader.TestField(ServiceHeader."VAT Date CZL", ServiceHeader."Posting Date")
            else begin
                ServiceHeader.TestField(ServiceHeader."VAT Date CZL");
                if IsVATDateCZLNotAllowed(ServiceHeader."VAT Date CZL", SetupRecID) then
                    ErrorMessageManagement.LogContextFieldError(
                    ServiceHeader.FieldNo(ServiceHeader."VAT Date CZL"), StrSubstNo(VatDateNotAllowedErr, ServiceHeader.FieldCaption(ServiceHeader."VAT Date CZL"), ServiceHeader."VAT Date CZL"),
                    SetupRecID, ErrorMessageManagement.GetFieldNo(SetupRecID.TableNo, GeneralLedgerSetup.FieldName("Allow VAT Posting From CZL")),
                    ForwardLinkMgt.GetHelpCodeForAllowedPostingDate());
                VATPeriodCZLCheck(ServiceHeader."VAT Date CZL");
            end;
            exit;
        end;
#pragma warning restore AL0432
#endif
        if not VATReportingDateMgt.IsVATDateEnabled() then
            ServiceHeader.TestField("VAT Reporting Date", ServiceHeader."Posting Date")
        else begin
            ServiceHeader.TestField("VAT Reporting Date");
            if IsVATDateCZLNotAllowed(ServiceHeader."VAT Reporting Date", SetupRecID) then
                ErrorMessageManagement.LogContextFieldError(
                    ServiceHeader.FieldNo(ServiceHeader."VAT Reporting Date"), StrSubstNo(VatDateNotAllowedErr, ServiceHeader.FieldCaption(ServiceHeader."VAT Reporting Date"), ServiceHeader."VAT Reporting Date"),
                    SetupRecID, ErrorMessageManagement.GetFieldNo(SetupRecID.TableNo, GeneralLedgerSetup.FieldName("Allow VAT Posting From CZL")),
                    ForwardLinkMgt.GetHelpCodeForAllowedPostingDate());
            VATPeriodCZLCheck(ServiceHeader."VAT Reporting Date");
        end;
    end;

    procedure InitVATDateFromRecordCZL(TableNo: Integer)
    var
        DummyGLEntry: Record "G/L Entry";
        DummyCustLedgerEntry: Record "Cust. Ledger Entry";
        DummyVATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL";
        DataTypeManagement: Codeunit "Data Type Management";
#if not CLEAN22
#pragma warning disable AL0432
        ReplaceVATDateMgtCZL: Codeunit "Replace VAT Date Mgt. CZL";
#pragma warning restore AL0432
#endif
        RecordRef: RecordRef;
        PostingDateFieldRef: FieldRef;
        VATDateFieldRef: FieldRef;
    begin
        RecordRef.Open(TableNo);
#if not CLEAN22
#pragma warning disable AL0432
        if not ReplaceVATDateMgtCZL.IsEnabled() then
            if not DataTypeManagement.FindFieldByName(RecordRef, VATDateFieldRef, DummyCustLedgerEntry.FieldName("VAT Date CZL")) then
                DataTypeManagement.FindFieldByName(RecordRef, VATDateFieldRef, DummyVATCtrlReportLineCZL.FieldName("VAT Date"));
        if ReplaceVATDateMgtCZL.IsEnabled() then
#pragma warning restore AL0432
#endif
        if not DataTypeManagement.FindFieldByName(RecordRef, VATDateFieldRef, DummyGLEntry.FieldName("VAT Reporting Date")) then
                if not DataTypeManagement.FindFieldByName(RecordRef, VATDateFieldRef, DummyVATCtrlReportLineCZL.FieldName("VAT Date")) then
                    DataTypeManagement.FindFieldByName(RecordRef, VATDateFieldRef, DummyCustLedgerEntry.FieldName("VAT Date CZL"));
        DataTypeManagement.FindFieldByName(RecordRef, PostingDateFieldRef, DummyCustLedgerEntry.FieldName("Posting Date"));
        VATDateFieldRef.SetRange(0D);
        PostingDateFieldRef.SetFilter('<>%1', 0D);
        if RecordRef.FindSet(true) then
            repeat
                VATDateFieldRef.Value := PostingDateFieldRef.Value;
                RecordRef.Modify();
            until RecordRef.Next() = 0;
    end;
#if not CLEAN22
#pragma warning disable AL0432
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"VAT Reporting Date Mgt", 'OnBeforeIsVATDateEnabledForUse', '', false, false)]
    local procedure OnBeforeIsVATDateEnabledForUse(var IsEnabled: Boolean; var IsHandled: Boolean)
    var
        GLSetup: Record "General Ledger Setup";
        ReplaceVATDateMgt: Codeunit "Replace VAT Date Mgt. CZL";
    begin
        if ReplaceVATDateMgt.IsEnabled() then
            exit;
        if GLSetup.Get() then begin
            IsEnabled := GLSetup."Use VAT Date CZL";
            IsHandled := true;
        end;
    end;
#pragma warning restore AL0432
#endif

    [EventSubscriber(ObjectType::Table, Database::"General Ledger Setup", 'OnAfterInsertEvent', '', false, false)]
    local procedure InitVATReportingDateUsageOnAfteInsertEvent(var Rec: Record "General Ledger Setup")
    begin
        Rec."VAT Reporting Date Usage" := Rec."VAT Reporting Date Usage"::"Enabled (Prevent modification)";
    end;
}
