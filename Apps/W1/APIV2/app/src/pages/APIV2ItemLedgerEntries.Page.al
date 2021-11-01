page 30069 "APIV2 - Item Ledger Entries"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Item Ledger Entry';
    EntitySetCaption = 'Item Ledger Entries';
    DelayedInsert = true;
    DeleteAllowed = false;
    Editable = false;
    EntityName = 'itemLedgerEntry';
    EntitySetName = 'itemLedgerEntries';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = API;
    SourceTable = "Item Ledger Entry";
    Extensible = false;
    ODataKeyFields = SystemId;

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
                field(entryNumber; "Entry No.")
                {
                    Caption = 'Entry No.';
                    Editable = false;
                }
                field(itemNumber; "Item No.")
                {
                    Caption = 'Item No.';
                }
                field(postingDate; "Posting Date")
                {
                    Caption = 'Posting Date';
                }
                field(entryType; "Entry Type")
                {
                    Caption = 'Entry Type';
                }
                field(sourceNumber; "Source No.")
                {
                    Caption = 'Source No.';
                }
                field(sourceType; "Source Type")
                {
                    Caption = 'Source Type';
                }
                field(documentNumber; "Document No.")
                {
                    Caption = 'Document No.';
                }
                field(documentType; "Document Type")
                {
                    Caption = 'Document Type';
                }
                field(description; Description)
                {
                    Caption = 'Description';
                }
                field(quantity; Quantity)
                {
                    Caption = 'Quantity';
                }
                field(salesAmountActual; "Sales Amount (Actual)")
                {
                    Caption = 'Sales Amount (Actual)';
                }
                field(costAmountActual; "Cost Amount (Actual)")
                {
                    Caption = 'Cost Amount (Actual)';
                }
                field(lastModifiedDateTime; SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                }
            }
        }
    }

    actions
    {
    }
}