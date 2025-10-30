namespace Microsoft.API.V2;

using Microsoft.Purchases.Payables;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.ReceivablesPayables;

page 30073 "APIV2 - Apply Vendor Entries"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Apply Vendor Entry';
    EntitySetCaption = 'Apply Vendor Entries';
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    PageType = API;
    EntityName = 'applyVendorEntry';
    EntitySetName = 'applyVendorEntries';
    SourceTable = "Vendor Ledger Entry Buffer";
    SourceTableTemporary = true;
    Extensible = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    AboutText = 'Exposes open vendor ledger entries with key details such as posting date, document type, vendor information, and remaining amount, enabling external systems to retrieve and update application status via GET and PATCH operations. Facilitates automated accounts payable reconciliation by allowing integrations to programmatically match and apply payments or credit memos to outstanding vendor invoices, supporting AP automation and bank transaction import scenarios. Designed for seamless settlement processing and accurate maintenance of vendor balances within Business Central.';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(applied; Applied)
                {
                    Caption = 'Applied';
                }
                field(appliesToId; Rec."Applies-to ID")
                {
                    Caption = 'Applies-to Id';
                    Editable = false;
                }
                field(postingDate; Rec."Posting Date")
                {
                    Caption = 'Posting Date';
                    Editable = false;
                }
                field(documentType; Rec."Document Type")
                {
                    Caption = 'Document Type';
                    Editable = false;
                }
                field(documentNumber; Rec."Document No.")
                {
                    Caption = 'Document No.';
                    Editable = false;
                }
                field(externalDocumentNumber; Rec."External Document No.")
                {
                    Caption = 'External Document No.';
                    Editable = false;
                }
                field(vendorNumber; Rec."Vendor No.")
                {
                    Caption = 'Vendor No.';
                    Editable = false;
                }
                field(vendorName; Rec."Vendor Name")
                {
                    Caption = 'Vendor Name';
                    Editable = false;
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                    Editable = false;
                }
                field(remainingAmount; Rec."Remaining Amount")
                {
                    Caption = 'Remaining Amount';
                    Editable = false;
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                    Editable = false;
                }
            }
        }
    }

    trigger OnFindRecord(Which: Text): Boolean
    var
        VendorIdFilter: Text;
        GenJournalLineIdFilter: Text;
        FilterView: Text;
    begin
        VendorIdFilter := Rec.GetFilter("Vendor Id");
        GenJournalLineIdFilter := Rec.GetFilter("Gen. Journal Line Id");
        if (VendorIdFilter = '') or (GenJournalLineIdFilter = '') then
            Error(FiltersNotSpecifiedErr);
        if RecordsLoaded then
            exit(true);
        FilterView := Rec.GetView();
        Rec.LoadDataFromFilter(VendorIdFilter, GenJournalLineIdFilter);
        Rec.SetView(FilterView);
        if not Rec.FindFirst() then
            exit(false);
        RecordsLoaded := true;
        exit(true);
    end;

    trigger OnAfterGetRecord()
    begin
        SetCalculatedFields();
    end;

    trigger OnModifyRecord(): Boolean
    var
        GenJournalLine: Record "Gen. Journal Line";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        GenJnlApply: Codeunit "Gen. Jnl.-Apply";
    begin
        GenJournalLine.GetBySystemId(Rec."Gen. Journal Line Id");
        VendorLedgerEntry.Get(Rec."Entry No.");
        GenJnlApply.SetVendApplIdAPI(GenJournalLine, VendorLedgerEntry);
        GenJnlApply.ApplyVendorLedgerEntryAPI(GenJournalLine);
        VendorLedgerEntry.Get(Rec."Entry No.");
        Rec.TransferFields(VendorLedgerEntry);
        VendorLedgerEntry.CalcFields("Remaining Amount");
        Rec."Remaining Amount" := VendorLedgerEntry."Remaining Amount";
        Rec.Modify();
        SetCalculatedFields();
        exit(false);
    end;

    var
        FiltersNotSpecifiedErr: Label 'You must specify a vendor payment to get apply vendor entries.';
        RecordsLoaded: Boolean;
        Applied: Boolean;

    local procedure SetCalculatedFields()
    begin
        Applied := Rec."Applies-to ID" <> '';
    end;
}