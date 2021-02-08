codeunit 11742 "VAT Date Handler CZL"
{
    var
        GLSetup: Record "General Ledger Setup";
        UserSetup: Record "User Setup";
        ErrorMessageMgt: Codeunit "Error Message Management";
        ForwardLinkMgt: Codeunit "Forward Link Mgt.";
        VatDateNotAllowedErr: Label '%1 %2 is not within your range of allowed dates.', Comment = '%1 - VAT Date FieldCaption, %2 = VAT Date';

    [EventSubscriber(ObjectType::Table, Database::"G/L Entry", 'OnAfterCopyGLEntryFromGenJnlLine', '', false, false)]
    local procedure UpdateVatDateOnAfterCopyGenJnlLineFromGLEntry(var GLEntry: Record "G/L Entry"; var GenJournalLine: Record "Gen. Journal Line")
    begin
        GLEntry."VAT Date CZL" := GenJournalLine."VAT Date CZL";
    end;

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

    [EventSubscriber(ObjectType::Table, Database::"Cust. Ledger Entry", 'OnAfterCopyCustLedgerEntryFromGenJnlLine', '', false, false)]
    local procedure UpdateVatDateOnAfterCopyCustLedgerEntryFromGenJnlLine(var CustLedgerEntry: Record "Cust. Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        CustLedgerEntry."VAT Date CZL" := GenJournalLine."VAT Date CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Ledger Entry", 'OnAfterCopyVendLedgerEntryFromGenJnlLine', '', false, false)]
    local procedure UpdateVatDateOnAfterCopyVendorLedgerEntryFromGenJnlLine(var VendorLedgerEntry: Record "Vendor Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        VendorLedgerEntry."VAT Date CZL" := GenJournalLine."VAT Date CZL";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostInvPostBuffer', '', false, false)]
    local procedure UpdateVatDateOnBeforePostInvPostBufferSales(var GenJnlLine: Record "Gen. Journal Line"; var InvoicePostBuffer: Record "Invoice Post. Buffer"; var SalesHeader: Record "Sales Header")
    begin
        GenJnlLine."VAT Date CZL" := InvoicePostBuffer."VAT Date CZL";
        GenJnlLine."EU 3-Party Intermed. Role CZL" := SalesHeader."EU 3-Party Intermed. Role CZL";
        GenJnlLine."Original Doc. VAT Date CZL" := InvoicePostBuffer."Original Doc. VAT Date CZL";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterCheckSalesDoc', '', false, false)]
    local procedure CheckVatDateOnAfterCheckSalesDoc(var SalesHeader: Record "Sales Header")
    begin
        CheckVATDateCZL(SalesHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePostInvPostBuffer', '', false, false)]
    local procedure UpdateVatDateOnBeforePostInvPostBufferPurch(var GenJnlLine: Record "Gen. Journal Line"; var InvoicePostBuffer: Record "Invoice Post. Buffer"; var PurchHeader: Record "Purchase Header")
    begin
        GenJnlLine."VAT Date CZL" := InvoicePostBuffer."VAT Date CZL";
        GenJnlLine."EU 3-Party Intermed. Role CZL" := PurchHeader."EU 3-Party Intermed. Role CZL";
        GenJnlLine."Original Doc. VAT Date CZL" := InvoicePostBuffer."Original Doc. VAT Date CZL";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterCheckPurchDoc', '', false, false)]
    local procedure CheckVatDateOnAfterCheckPurchDoc(var PurchHeader: Record "Purchase Header")
    begin
        CheckVATDateCZL(PurchHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Serv-Posting Journals Mgt.", 'OnBeforePostInvoicePostBuffer', '', false, false)]
    local procedure UpdateVatDateOnBeforePostInvPostBufferServ(var GenJournalLine: Record "Gen. Journal Line"; var InvoicePostBuffer: Record "Invoice Post. Buffer")
    begin
        GenJournalLine."VAT Date CZL" := InvoicePostBuffer."VAT Date CZL";
        GenJournalLine."Original Doc. VAT Date CZL" := InvoicePostBuffer."Original Doc. VAT Date CZL";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service-Post", 'OnBeforePostWithLines', '', false, false)]
    local procedure CheckVatDateOnBeforePostWithLines(var PassedServHeader: Record "Service Header")
    begin
        CheckVATDateCZL(PassedServHeader);
    end;

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
            GLSetup.Get();
            VATAllowPostingFrom := GLSetup."Allow VAT Posting From CZL";
            VATAllowPostingTo := GLSetup."Allow VAT Posting To CZL";
            SetupRecordID := GLSetup.RecordId;
        end;
        if VATAllowPostingTo = 0D then
            VATAllowPostingTo := DMY2Date(31, 12, 9999);
        exit((VATDate < VATAllowPostingFrom) or (VATDate > VATAllowPostingTo));
    end;

    procedure CheckVATDateCZL(GenJournalLine: Record "Gen. Journal Line")
    var
        VATRangeErr: Label ' %1 is not within your range of allowed VAT dates', Comment = '%1 = VAT Date';
    begin
        GLSetup.Get();
        if not GLSetup."Use VAT Date CZL" then
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
        GLSetup.Get();
        if not GLSetup."Use VAT Date CZL" then
            SalesHeader.TestField("VAT Date CZL", SalesHeader."Posting Date")
        else begin
            SalesHeader.TestField("VAT Date CZL");
            if IsVATDateCZLNotAllowed(SalesHeader."VAT Date CZL", SetupRecID) then
                ErrorMessageMgt.LogContextFieldError(
                  SalesHeader.FieldNo(SalesHeader."VAT Date CZL"), StrSubstNo(VatDateNotAllowedErr, SalesHeader.FieldCaption(SalesHeader."VAT Date CZL"), SalesHeader."VAT Date CZL"),
                  SetupRecID, ErrorMessageMgt.GetFieldNo(SetupRecID.TableNo, GLSetup.FieldName("Allow VAT Posting From CZL")),
                  ForwardLinkMgt.GetHelpCodeForAllowedPostingDate());
            VATPeriodCZLCheck(SalesHeader."VAT Date CZL");
        end;
    end;

    procedure CheckVATDateCZL(var PurchHeader: Record "Purchase Header")
    var
        SetupRecID: RecordID;
        MustBeLessOrEqualErr: Label 'must be less or equal to %1', Comment = '%1 = fieldcaption of VAT Date CZL';
    begin
        GLSetup.Get();
        if not GLSetup."Use VAT Date CZL" then
            PurchHeader.TestField("VAT Date CZL", PurchHeader."Posting Date")
        else begin
            PurchHeader.TestField("VAT Date CZL");
            if IsVATDateCZLNotAllowed(PurchHeader."VAT Date CZL", SetupRecID) then
                ErrorMessageMgt.LogContextFieldError(
                  PurchHeader.FieldNo(PurchHeader."VAT Date CZL"), StrSubstNo(VatDateNotAllowedErr, PurchHeader.FieldCaption(PurchHeader."VAT Date CZL"), PurchHeader."VAT Date CZL"),
                  SetupRecID, ErrorMessageMgt.GetFieldNo(SetupRecID.TableNo, GLSetup.FieldName("Allow VAT Posting From CZL")),
                  ForwardLinkMgt.GetHelpCodeForAllowedPostingDate());
            VATPeriodCZLCheck(PurchHeader."VAT Date CZL");
            if PurchHeader.Invoice then
                PurchHeader.TestField("Original Doc. VAT Date CZL");
            if PurchHeader."Original Doc. VAT Date CZL" > PurchHeader."VAT Date CZL" then
                PurchHeader.FieldError("Original Doc. VAT Date CZL", StrSubstNo(MustBeLessOrEqualErr, PurchHeader.FieldCaption(PurchHeader."VAT Date CZL")));
        end;
    end;

    procedure CheckVATDateCZL(var ServiceHeader: Record "Service Header")
    var
        SetupRecID: RecordID;
    begin
        GLSetup.Get();
        if not GLSetup."Use VAT Date CZL" then
            ServiceHeader.TestField(ServiceHeader."VAT Date CZL", ServiceHeader."Posting Date")
        else begin
            ServiceHeader.TestField(ServiceHeader."VAT Date CZL");
            if IsVATDateCZLNotAllowed(ServiceHeader."VAT Date CZL", SetupRecID) then
                ErrorMessageMgt.LogContextFieldError(
                  ServiceHeader.FieldNo(ServiceHeader."VAT Date CZL"), StrSubstNo(VatDateNotAllowedErr, ServiceHeader.FieldCaption(ServiceHeader."VAT Date CZL"), ServiceHeader."VAT Date CZL"),
                  SetupRecID, ErrorMessageMgt.GetFieldNo(SetupRecID.TableNo, GLSetup.FieldName("Allow VAT Posting From CZL")),
                  ForwardLinkMgt.GetHelpCodeForAllowedPostingDate());
            VATPeriodCZLCheck(ServiceHeader."VAT Date CZL");
        end;
    end;
}
