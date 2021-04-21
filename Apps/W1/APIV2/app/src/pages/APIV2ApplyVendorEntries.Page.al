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

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(id; SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(applied; Applied)
                {
                    Caption = 'Applied';
                }
                field(appliesToId; "Applies-to ID")
                {
                    Caption = 'Applies-to Id';
                    Editable = false;
                }
                field(postingDate; "Posting Date")
                {
                    Caption = 'Posting Date';
                    Editable = false;
                }
                field(documentType; "Document Type")
                {
                    Caption = 'Document Type';
                    Editable = false;
                }
                field(documentNumber; "Document No.")
                {
                    Caption = 'Document No.';
                    Editable = false;
                }
                field(externalDocumentNumber; "External Document No.")
                {
                    Caption = 'External Document No.';
                    Editable = false;
                }
                field(vendorNumber; "Vendor No.")
                {
                    Caption = 'Vendor No.';
                    Editable = false;
                }
                field(vendorName; "Vendor Name")
                {
                    Caption = 'Vendor Name';
                    Editable = false;
                }
                field(description; Description)
                {
                    Caption = 'Description';
                    Editable = false;
                }
                field(remainingAmount; "Remaining Amount")
                {
                    Caption = 'Remaining Amount';
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
        LoadDataFromFilter(VendorIdFilter, GenJournalLineIdFilter);
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
        GenJournalLine.GetBySystemId("Gen. Journal Line Id");
        VendorLedgerEntry.Get("Entry No.");
        GenJnlApply.SetVendApplIdAPI(GenJournalLine, VendorLedgerEntry);
        GenJnlApply.ApplyVendorLedgerEntryAPI(GenJournalLine);
        VendorLedgerEntry.Get("Entry No.");
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
        Applied := "Applies-to ID" <> '';
    end;
}