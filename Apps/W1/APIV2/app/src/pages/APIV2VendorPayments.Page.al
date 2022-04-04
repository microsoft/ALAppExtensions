page 30060 "APIV2 - Vendor Payments"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Vendor Payment';
    EntitySetCaption = 'Vendor Payments';
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    PageType = API;
    EntityName = 'vendorPayment';
    EntitySetName = 'vendorPayments';
    SourceTable = "Gen. Journal Line";
    Extensible = false;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(journalId; "Journal Batch Id")
                {
                    Caption = 'Journal Id';

                    trigger OnValidate()
                    begin
                        if (not IsNullGuid(xRec."Journal Batch Id")) and (xRec."Journal Batch Id" <> Rec."Journal Batch Id") then
                            Error(CannotEditJournalIdErr);
                    end;
                }
                field(journalDisplayName; "Journal Batch Name")
                {
                    Caption = 'Journal Display Name';

                    trigger OnValidate()
                    begin
                        if (xRec."Journal Batch Name" <> '') and (xRec."Journal Batch Name" <> Rec."Journal Batch Name") then
                            Error(CannotEditBatchNameErr);
                    end;
                }
                field(lineNumber; "Line No.")
                {
                    Caption = 'Line No.';
                }
                field(vendorId; "Vendor Id")
                {
                    Caption = 'Vendor Id';

                    trigger OnValidate()
                    begin
                        if "Vendor Id" = BlankGUID then begin
                            "Account No." := '';
                            exit;
                        end;

                        if not Vendor.GetBySystemId("Vendor Id") then
                            Error(VendorIdDoesNotMatchAVendorErr);

                        "Account No." := Vendor."No.";
                    end;
                }
                field(vendorNumber; "Account No.")
                {
                    Caption = 'Vendor No.';
                    TableRelation = Vendor;

                    trigger OnValidate()
                    begin
                        if Vendor."No." <> '' then begin
                            if Vendor."No." <> "Account No." then
                                Error(VendorValuesDontMatchErr);
                            exit;
                        end;

                        if "Account No." = '' then begin
                            "Vendor Id" := BlankGUID;
                            exit;
                        end;

                        if not Vendor.Get("Account No.") then
                            Error(VendorNumberDoesNotMatchAVendorErr);

                        "Vendor Id" := Vendor.SystemId;
                    end;
                }
                field(postingDate; "Posting Date")
                {
                    Caption = 'Posting Date';
                }
                field(documentNumber; "Document No.")
                {
                    Caption = 'Document No.';
                }
                field(externalDocumentNumber; "External Document No.")
                {
                    Caption = 'External Document No.';
                }
                field(amount; Amount)
                {
                    Caption = 'Amount';
                }
                field(appliesToInvoiceId; AppliesToInvoiceIdText)
                {
                    Caption = 'Applies To Invoice Id';

                    trigger OnValidate()
                    var
                        PurchaseInvoiceAggregator: Codeunit "Purch. Inv. Aggregator";
                    begin
                        "Applies-to Invoice Id" := AppliesToInvoiceIdText;
                        if "Applies-to Invoice Id" = BlankGUID then begin
                            AppliesToInvoiceNumberText := '';
                            exit;
                        end;

                        PurchInvHeader.Reset();
                        if not PurchaseInvoiceAggregator.GetPurchaseInvoiceHeaderFromId(Format(AppliesToInvoiceIdText), PurchInvHeader) then
                            Error(AppliesToInvoiceIdDoesNotMatchAnInvoiceErr);

                        AppliesToInvoiceNumberText := PurchInvHeader."No.";

                        if "Account No." = '' then
                            if PurchInvHeader."Pay-to Vendor No." <> '' then
                                "Account No." := PurchInvHeader."Pay-to Vendor No."
                            else
                                "Account No." := PurchInvHeader."Buy-from Vendor No.";
                    end;
                }
                field(appliesToInvoiceNumber; AppliesToInvoiceNumberText)
                {
                    Caption = 'Applies To Invoice No.';

                    trigger OnValidate()
                    var
                        PurchaseInvoiceAggregator: Codeunit "Purch. Inv. Aggregator";
                        BlankGUID: Guid;
                    begin
                        "Applies-to Doc. No." := AppliesToInvoiceNumberText;

                        if PurchInvHeader."No." <> '' then begin
                            if PurchInvHeader."No." <> AppliesToInvoiceNumberText then
                                Error(AppliesToDocValuesDontMatchErr);
                            exit;
                        end;

                        if PurchInvHeader.Get(AppliesToInvoiceNumberText) then begin
                            AppliesToInvoiceIdText := PurchaseInvoiceAggregator.GetPurchaseInvoiceHeaderId(PurchInvHeader);
                            if "Account No." = '' then
                                if PurchInvHeader."Pay-to Vendor No." <> '' then
                                    "Account No." := PurchInvHeader."Pay-to Vendor No."
                                else
                                    "Account No." := PurchInvHeader."Buy-from Vendor No.";
                        end else
                            AppliesToInvoiceIdText := BlankGUID;
                    end;
                }
                field(description; Description)
                {
                    Caption = 'Description';
                }
                field(comment; Comment)
                {
                    Caption = 'Comment';
                }
                field(lastModifiedDateTime; SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                    Editable = false;
                }
                part(dimensionSetLines; "APIV2 - Dimension Set Lines")
                {
                    Caption = 'Dimension Set Lines';
                    EntityName = 'dimensionSetLine';
                    EntitySetName = 'dimensionSetLines';
                    SubPageLink = "Parent Id" = Field(SystemId), "Parent Type" = const("Journal Line");
                }
                part(applyVendorEntries; "APIV2 - Apply Vendor Entries")
                {
                    Caption = 'Apply Vendor Entries';
                    EntityName = 'applyVendorEntry';
                    EntitySetName = 'applyVendorEntries';
                    SubPageLink = "Vendor Id" = field("Vendor Id"), "Gen. Journal Line Id" = field(SystemId);
                }
            }
        }
    }

    actions
    {

    }

    trigger OnFindRecord(Which: Text): Boolean
    var
        NextRecNotFound: Boolean;
    begin
        if not Find(Which) then
            exit(false);

        if ShowRecord() then
            exit(true);

        repeat
            NextRecNotFound := Next() <= 0;
            if ShowRecord() then
                exit(true);
        until NextRecNotFound;

        exit(false);
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    var
        ResultSteps: Integer;
    begin
        repeat
            ResultSteps := Next(Steps);
        until (ResultSteps = 0) or ShowRecord();
        exit(ResultSteps);
    end;

    trigger OnAfterGetCurrRecord()
    begin
        if not FiltersChecked then begin
            CheckFilters();
            FiltersChecked := true;
        end;
    end;

    trigger OnAfterGetRecord()
    begin
        SetCalculatedFields();
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        TempGenJournalLine: Record "Gen. Journal Line" temporary;
        JournalBatchId: Guid;
        JournalBatchIdFilter: Text;
    begin
        if IsNullGuid("Journal Batch Id") then begin
            JournalBatchIdFilter := Rec.GetFilter("Journal Batch Id");
            if JournalBatchIdFilter = '' then
                Error(FiltersNotSpecifiedErr);
            JournalBatchId := JournalBatchIdFilter;
        end else begin
            JournalBatchIdFilter := Rec.GetFilter("Journal Batch Id");
            if (JournalBatchIdFilter <> '') then begin
                JournalBatchId := JournalBatchIdFilter;
                if (JournalBatchId <> "Journal Batch Id") then
                    Error(JournalBatchIdNameNotMatchErr)
            end else
                JournalBatchId := "Journal Batch Id";
        end;

        ProcessAppliesToInvoiceNumberAndId();

        TempGenJournalLine.Reset();
        TempGenJournalLine.Copy(Rec);

        Clear(Rec);
        GraphMgtVendorPayments.SetVendorPaymentsTemplateAndBatch(
          Rec, LibraryAPIGeneralJournal.GetBatchNameFromId(JournalBatchId));
        LibraryAPIGeneralJournal.InitializeLine(
          Rec, TempGenJournalLine."Line No.", TempGenJournalLine."Document No.", TempGenJournalLine."External Document No.");
        TransferGeneratedFieldsFromInitializeLine(TempGenJournalLine);

        GraphMgtVendorPayments.SetVendorPaymentsValues(Rec, TempGenJournalLine);

        SetCalculatedFields();
    end;

    trigger OnModifyRecord(): Boolean
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        ProcessAppliesToInvoiceNumberAndId();

        GenJournalLine.GetBySystemId(SystemId);

        if "Line No." = GenJournalLine."Line No." then
            Modify(true)
        else begin
            GenJournalLine.TransferFields(Rec, false);
            GenJournalLine.Rename("Journal Template Name", "Journal Batch Name", "Line No.");
            TransferFields(GenJournalLine, true);
        end;

        SetCalculatedFields();

        exit(false);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        ClearCalculatedFields();

        "Document Type" := "Document Type"::Payment;
        "Account Type" := "Account Type"::Vendor;
        "Applies-to Doc. Type" := "Applies-to Doc. Type"::Invoice;
    end;

    trigger OnOpenPage()
    begin
        GraphMgtVendorPayments.SetVendorPaymentsFilters(Rec);
    end;

    var
        Vendor: Record Vendor;
        PurchInvHeader: Record "Purch. Inv. Header";
        GraphMgtVendorPayments: Codeunit "Graph Mgt - Vendor Payments";
        LibraryAPIGeneralJournal: Codeunit "Library API - General Journal";
        AppliesToInvoiceNumberText: Code[20];
        AppliesToInvoiceIdText: Guid;
        FiltersNotSpecifiedErr: Label 'You must specify a journal batch ID or a journal ID to get a journal line.';
        JournalBatchIdNameNotMatchErr: Label 'The Journal Id and Journal Display Name do not match.';
        CannotEditBatchNameErr: Label 'The Journal Batch Display Name cannot be changed.';
        CannotEditJournalIdErr: Label 'The Journal Id cannot be changed.';
        VendorValuesDontMatchErr: Label 'The vendor values do not match to a specific Vendor.';
        VendorIdDoesNotMatchAVendorErr: Label 'The "vendorId" does not match to a Vendor.', Comment = 'vendorId is a field name and should not be translated.';
        VendorNumberDoesNotMatchAVendorErr: Label 'The "vendorNumber" does not match to a Vendor.', Comment = 'vendorNumber is a field name and should not be translated.';
        AppliesToDocValuesDontMatchErr: Label 'The Applies To Invoice values do not match to the same Invoice.';
        AppliesToInvoiceIdDoesNotMatchAnInvoiceErr: Label 'The "appliesToInvoiceId" should be the ID of an Open, Paid, Corrective, or Canceled Invoice.', Comment = 'appliesToInvoiceId is a field name and should not be translated.';
        FiltersChecked: Boolean;
        BlankGUID: Guid;

    local procedure TransferGeneratedFieldsFromInitializeLine(var GenJournalLine: Record "Gen. Journal Line")
    begin
        if GenJournalLine."Document No." = '' then
            GenJournalLine."Document No." := "Document No.";
    end;

    local procedure SetCalculatedFields()
    begin
        AppliesToInvoiceNumberText := "Applies-to Doc. No.";
        AppliesToInvoiceIdText := "Applies-to Invoice Id";
    end;

    local procedure ClearCalculatedFields()
    begin
        Clear(AppliesToInvoiceIdText);
        Clear(AppliesToInvoiceNumberText);
    end;

    local procedure ProcessAppliesToInvoiceNumberAndId()
    begin
        if AppliesToInvoiceNumberText <> '' then
            "Applies-to Doc. No." := AppliesToInvoiceNumberText;
        "Applies-to Invoice Id" := AppliesToInvoiceIdText;
    end;

    local procedure CheckFilters()
    begin
        if (GetFilter("Journal Batch Id") = '') and
           (GetFilter(SystemId) = '')
        then
            Error(FiltersNotSpecifiedErr);
    end;

    local procedure ShowRecord(): Boolean
    begin
        exit(("Applies-to Doc. Type" = "Applies-to Doc. Type"::Invoice) or ("Applies-to ID" <> ''));
    end;
}