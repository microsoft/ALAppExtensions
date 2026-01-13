namespace Microsoft.API.V2;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Purchases.Vendor;
using Microsoft.Integration.Entity;
using Microsoft.Purchases.History;
using Microsoft.Integration.Graph;

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

    AboutText = 'Manages vendor payment transactions including payment amounts, dates, methods, and invoice application details. Supports full CRUD operations for automating accounts payable, integrating with banking systems, and streamlining vendor settlement processes. Enables external systems to create, retrieve, update, and delete vendor payment records for efficient payables reconciliation and payment workflow integration.';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(journalId; Rec."Journal Batch Id")
                {
                    Caption = 'Journal Id';

                    trigger OnValidate()
                    begin
                        if (not IsNullGuid(xRec."Journal Batch Id")) and (xRec."Journal Batch Id" <> Rec."Journal Batch Id") then
                            Error(CannotEditJournalIdErr);
                    end;
                }
                field(journalDisplayName; Rec."Journal Batch Name")
                {
                    Caption = 'Journal Display Name';

                    trigger OnValidate()
                    begin
                        if (xRec."Journal Batch Name" <> '') and (xRec."Journal Batch Name" <> Rec."Journal Batch Name") then
                            Error(CannotEditBatchNameErr);
                    end;
                }
                field(lineNumber; Rec."Line No.")
                {
                    Caption = 'Line No.';
                }
                field(vendorId; Rec."Vendor Id")
                {
                    Caption = 'Vendor Id';

                    trigger OnValidate()
                    begin
                        if Rec."Vendor Id" = BlankGUID then begin
                            Rec."Account No." := '';
                            exit;
                        end;

                        if not Vendor.GetBySystemId(Rec."Vendor Id") then
                            Error(VendorIdDoesNotMatchAVendorErr);

                        Rec."Account No." := Vendor."No.";
                    end;
                }
                field(vendorNumber; Rec."Account No.")
                {
                    Caption = 'Vendor No.';
                    TableRelation = Vendor;

                    trigger OnValidate()
                    begin
                        if Vendor."No." <> '' then begin
                            if Vendor."No." <> Rec."Account No." then
                                Error(VendorValuesDontMatchErr);
                            exit;
                        end;

                        if Rec."Account No." = '' then begin
                            Rec."Vendor Id" := BlankGUID;
                            exit;
                        end;

                        if not Vendor.Get(Rec."Account No.") then
                            Error(VendorNumberDoesNotMatchAVendorErr);

                        Rec."Vendor Id" := Vendor.SystemId;
                    end;
                }
                field(postingDate; Rec."Posting Date")
                {
                    Caption = 'Posting Date';
                }
                field(documentNumber; Rec."Document No.")
                {
                    Caption = 'Document No.';
                }
                field(externalDocumentNumber; Rec."External Document No.")
                {
                    Caption = 'External Document No.';
                }
                field(amount; Rec.Amount)
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
                        Rec."Applies-to Invoice Id" := AppliesToInvoiceIdText;
                        if Rec."Applies-to Invoice Id" = BlankGUID then begin
                            AppliesToInvoiceNumberText := '';
                            exit;
                        end;

                        PurchInvHeader.Reset();
                        if not PurchaseInvoiceAggregator.GetPurchaseInvoiceHeaderFromId(Format(AppliesToInvoiceIdText), PurchInvHeader) then
                            Error(AppliesToInvoiceIdDoesNotMatchAnInvoiceErr);

                        AppliesToInvoiceNumberText := PurchInvHeader."No.";

                        if Rec."Account No." = '' then
                            if PurchInvHeader."Pay-to Vendor No." <> '' then
                                Rec."Account No." := PurchInvHeader."Pay-to Vendor No."
                            else
                                Rec."Account No." := PurchInvHeader."Buy-from Vendor No.";
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
                        Rec."Applies-to Doc. No." := AppliesToInvoiceNumberText;

                        if PurchInvHeader."No." <> '' then begin
                            if PurchInvHeader."No." <> AppliesToInvoiceNumberText then
                                Error(AppliesToDocValuesDontMatchErr);
                            exit;
                        end;

                        if PurchInvHeader.Get(AppliesToInvoiceNumberText) then begin
                            AppliesToInvoiceIdText := PurchaseInvoiceAggregator.GetPurchaseInvoiceHeaderId(PurchInvHeader);
                            if Rec."Account No." = '' then
                                if PurchInvHeader."Pay-to Vendor No." <> '' then
                                    Rec."Account No." := PurchInvHeader."Pay-to Vendor No."
                                else
                                    Rec."Account No." := PurchInvHeader."Buy-from Vendor No.";
                        end else
                            AppliesToInvoiceIdText := BlankGUID;
                    end;
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(comment; Rec.Comment)
                {
                    Caption = 'Comment';
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                    Editable = false;
                }
                part(dimensionSetLines; "APIV2 - Dimension Set Lines")
                {
                    Caption = 'Dimension Set Lines';
                    EntityName = 'dimensionSetLine';
                    EntitySetName = 'dimensionSetLines';
                    SubPageLink = "Parent Id" = field(SystemId), "Parent Type" = const("Journal Line");
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
        if not Rec.Find(Which) then
            exit(false);

        if ShowRecord() then
            exit(true);

        repeat
            NextRecNotFound := Rec.Next() <= 0;
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
            ResultSteps := Rec.Next(Steps);
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
        if IsNullGuid(Rec."Journal Batch Id") then begin
            JournalBatchIdFilter := Rec.GetFilter("Journal Batch Id");
            if JournalBatchIdFilter = '' then
                Error(FiltersNotSpecifiedErr);
            JournalBatchId := JournalBatchIdFilter;
        end else begin
            JournalBatchIdFilter := Rec.GetFilter("Journal Batch Id");
            if (JournalBatchIdFilter <> '') then begin
                JournalBatchId := JournalBatchIdFilter;
                if (JournalBatchId <> Rec."Journal Batch Id") then
                    Error(JournalBatchIdNameNotMatchErr)
            end else
                JournalBatchId := Rec."Journal Batch Id";
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

        GenJournalLine.GetBySystemId(Rec.SystemId);

        if Rec."Line No." = GenJournalLine."Line No." then
            Rec.Modify(true)
        else begin
            GenJournalLine.TransferFields(Rec, false);
            GenJournalLine.Rename(Rec."Journal Template Name", Rec."Journal Batch Name", Rec."Line No.");
            Rec.TransferFields(GenJournalLine, true);
        end;

        SetCalculatedFields();

        exit(false);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        ClearCalculatedFields();

        Rec."Document Type" := Rec."Document Type"::Payment;
        Rec."Account Type" := Rec."Account Type"::Vendor;
        Rec."Applies-to Doc. Type" := Rec."Applies-to Doc. Type"::Invoice;
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
            GenJournalLine."Document No." := Rec."Document No.";
    end;

    local procedure SetCalculatedFields()
    begin
        AppliesToInvoiceNumberText := Rec."Applies-to Doc. No.";
        AppliesToInvoiceIdText := Rec."Applies-to Invoice Id";
    end;

    local procedure ClearCalculatedFields()
    begin
        Clear(AppliesToInvoiceIdText);
        Clear(AppliesToInvoiceNumberText);
    end;

    local procedure ProcessAppliesToInvoiceNumberAndId()
    begin
        if AppliesToInvoiceNumberText <> '' then
            Rec."Applies-to Doc. No." := AppliesToInvoiceNumberText;
        Rec."Applies-to Invoice Id" := AppliesToInvoiceIdText;
    end;

    local procedure CheckFilters()
    begin
        if (Rec.GetFilter("Journal Batch Id") = '') and
           (Rec.GetFilter(SystemId) = '')
        then
            Error(FiltersNotSpecifiedErr);
    end;

    local procedure ShowRecord(): Boolean
    begin
        exit((Rec."Applies-to Doc. Type" = Rec."Applies-to Doc. Type"::Invoice) or (Rec."Applies-to ID" <> ''));
    end;
}