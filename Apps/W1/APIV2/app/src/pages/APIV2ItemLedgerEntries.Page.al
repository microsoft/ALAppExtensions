namespace Microsoft.API.V2;

using Microsoft.Inventory.Ledger;

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
    AboutText = 'Provides read-only access to detailed item ledger entries, including inventory transactions such as receipts, shipments, adjustments, and transfers. Supports GET operations to retrieve item numbers, quantities, locations, posting dates, and financial amounts for inventory analysis, audit, and integration with external warehouse management or analytics systems. Enables tracking of inventory movements and reconciliation of stock levels for compliance and reporting purposes.';

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
                field(entryNumber; Rec."Entry No.")
                {
                    Caption = 'Entry No.';
                    Editable = false;
                }
                field(itemNumber; Rec."Item No.")
                {
                    Caption = 'Item No.';
                }
                field(postingDate; Rec."Posting Date")
                {
                    Caption = 'Posting Date';
                }
                field(entryType; Rec."Entry Type")
                {
                    Caption = 'Entry Type';
                }
                field(sourceNumber; Rec."Source No.")
                {
                    Caption = 'Source No.';
                }
                field(sourceType; Rec."Source Type")
                {
                    Caption = 'Source Type';
                }
                field(documentNumber; Rec."Document No.")
                {
                    Caption = 'Document No.';
                }
                field(documentType; Rec."Document Type")
                {
                    Caption = 'Document Type';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(quantity; Rec.Quantity)
                {
                    Caption = 'Quantity';
                }
                field(salesAmountActual; Rec."Sales Amount (Actual)")
                {
                    Caption = 'Sales Amount (Actual)';
                }
                field(costAmountActual; Rec."Cost Amount (Actual)")
                {
                    Caption = 'Cost Amount (Actual)';
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
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