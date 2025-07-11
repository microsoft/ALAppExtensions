namespace Microsoft.API.V2;

using Microsoft.Finance.GeneralLedger.Ledger;

page 30018 "APIV2 - G/L Entries"
{
    APIVersion = 'v2.0';
    EntityCaption = 'General Ledger Entry';
    EntitySetCaption = 'General Ledger Entries';
    DelayedInsert = true;
    DeleteAllowed = false;
    Editable = false;
    EntityName = 'generalLedgerEntry';
    EntitySetName = 'generalLedgerEntries';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = API;
    SourceTable = "G/L Entry";
    Extensible = false;
    ODataKeyFields = SystemId;

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
                field(postingDate; Rec."Posting Date")
                {
                    Caption = 'Posting Date';
                }
                field(documentNumber; Rec."Document No.")
                {
                    Caption = 'Document No.';
                }
                field(documentType; Rec."Document Type")
                {
                    Caption = 'Document Type';
                }
                field(accountId; Rec."Account Id")
                {
                    Caption = 'Account Id';
                }
                field(accountNumber; Rec."G/L Account No.")
                {
                    Caption = 'Account No.';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(debitAmount; Rec."Debit Amount")
                {
                    Caption = 'Debit Amount';
                }
                field(creditAmount; Rec."Credit Amount")
                {
                    Caption = 'Credit Amount';
                }
                field(additionalCurrencyDebitAmount; Rec."Add.-Currency Debit Amount")
                {
                    Caption = 'Additional Currency Debit Amount';
                }
                field(additionalCurrencyCreditAmount; Rec."Add.-Currency Credit Amount")
                {
                    Caption = 'Additional Currency Credit Amount';
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                }
                part(attachments; "APIV2 - Attachments")
                {
                    Caption = 'Attachments';
                    EntityName = 'attachment';
                    EntitySetName = 'attachments';
                    SubPageLink = "Document Id" = field(SystemId), "Document Type" = const(Journal);
                }
                part(dimensionSetLines; "APIV2 - Dimension Set Lines")
                {
                    Caption = 'Dimension Set Lines';
                    EntityName = 'dimensionSetLine';
                    EntitySetName = 'dimensionSetLines';
                    SubPageLink = "Parent Id" = field(SystemId), "Parent Type" = const("General Ledger Entry");
                }
            }
        }
    }

    actions
    {
    }
}