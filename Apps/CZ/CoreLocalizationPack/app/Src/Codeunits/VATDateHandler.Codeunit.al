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
        ForwardLinkMgt: Codeunit "Forward Link Mgt.";
        VatDateNotAllowedErr: Label '%1 %2 is not within your range of allowed dates.', Comment = '%1 - VAT Date FieldCaption, %2 = VAT Date';

    [EventSubscriber(ObjectType::Table, Database::"G/L Entry", 'OnAfterCopyGLEntryFromGenJnlLine', '', false, false)]
    local procedure UpdateVatDateOnAfterCopyGenJnlLineFromGLEntry(var GLEntry: Record "G/L Entry"; var GenJournalLine: Record "Gen. Journal Line")
    begin
        GLEntry."VAT Date CZL" := GenJournalLine."VAT Date CZL";
    end;

#pragma warning disable AL0432
    [EventSubscriber(ObjectType::Table, Database::"Invoice Post. Buffer", 'OnAfterInvPostBufferPrepareSales', '', false, false)]
    local procedure UpdateVatDateInvoicePostBufferFromSalesHeader(var InvoicePostBuffer: Record "Invoice Post. Buffer"; var SalesLine: Record "Sales Line")
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        InvoicePostBuffer."VAT Date CZL" := SalesHeader."VAT Date CZL";
        InvoicePostBuffer."Original Doc. VAT Date CZL" := SalesHeader."Original Doc. VAT Date CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Invoice Post. Buffer", 'OnAfterInvPostBufferPreparePurchase', '', false, false)]
    local procedure UpdateVatDateInvoicePostBufferFromPurchaseHeader(var InvoicePostBuffer: Record "Invoice Post. Buffer"; var PurchaseLine: Record "Purchase Line")
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
        InvoicePostBuffer."VAT Date CZL" := PurchaseHeader."VAT Date CZL";
        InvoicePostBuffer."Original Doc. VAT Date CZL" := PurchaseHeader."Original Doc. VAT Date CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Invoice Post. Buffer", 'OnAfterInvPostBufferPrepareService', '', false, false)]
    local procedure UpdateVatDateInvoicePostBufferFromServiceHeader(var InvoicePostBuffer: Record "Invoice Post. Buffer"; var ServiceLine: Record "Service Line")
    var
        ServiceHeader: Record "Service Header";
    begin
        ServiceHeader.Get(ServiceLine."Document Type", ServiceLine."Document No.");
        InvoicePostBuffer."VAT Date CZL" := ServiceHeader."VAT Date CZL";
    end;
#pragma warning restore AL0432

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Posting To G/L", 'OnPostInvtPostBufOnBeforeSetAmt', '', false, false)]
    local procedure ClearVatDateOnPostInvtPostBufOnBeforeSetAmt(var GenJournalLine: Record "Gen. Journal Line")
    begin
        GenJournalLine."VAT Date CZL" := 0D;
        GenJournalLine."Original Doc. VAT Date CZL" := 0D;
    end;

    procedure VATDateNotAllowed(VATDate: Date): Boolean
    var
        SetupRecordID: RecordID;
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

    procedure IsVATDateCZLNotAllowed(VATDate: Date; var SetupRecordID: RecordID): Boolean
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
        GeneralLedgerSetup.Get();
        if not GeneralLedgerSetup."Use VAT Date CZL" then
            GenJournalLine.TestField("VAT Date CZL", GenJournalLine."Posting Date")
        else begin
            GenJournalLine.TestField("VAT Date CZL");
            if VATDateNotAllowed(GenJournalLine."VAT Date CZL") then
                GenJournalLine.FieldError("VAT Date CZL", StrSubstNo(VATRangeErr, GenJournalLine."VAT Date CZL"));
            VATPeriodCZLCheck(GenJournalLine."VAT Date CZL");
        end;
    end;

    procedure CheckVATDateCZL(var SalesHeader: Record "Sales Header")
    var
        SetupRecID: RecordID;
    begin
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
    end;

    procedure CheckVATDateCZL(var PurchaseHeader: Record "Purchase Header")
    var
        SetupRecID: RecordID;
        MustBeLessOrEqualErr: Label 'must be less or equal to %1', Comment = '%1 = fieldcaption of VAT Date CZL';
    begin
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
    end;

    procedure CheckVATDateCZL(var ServiceHeader: Record "Service Header")
    var
        SetupRecID: RecordID;
    begin
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
    end;

    procedure InitVATDateFromRecordCZL(TableNo: Integer)
    var
        DataTypeManagement: Codeunit "Data Type Management";
        RecordRef: RecordRef;
        PostingDateFieldRef: FieldRef;
        VATDateFieldRef: FieldRef;
    begin
        RecordRef.Open(TableNo);
        DataTypeManagement.FindFieldByName(RecordRef, VATDateFieldRef, 'VAT Date');
        DataTypeManagement.FindFieldByName(RecordRef, PostingDateFieldRef, 'Posting Date');
        VATDateFieldRef.SetRange(0D);
        PostingDateFieldRef.SetFilter('<>%1', 0D);
        if RecordRef.FindSet(true) then
            repeat
                VATDateFieldRef.Value := PostingDateFieldRef.Value;
                RecordRef.Modify();
            until RecordRef.Next() = 0;
    end;
}
