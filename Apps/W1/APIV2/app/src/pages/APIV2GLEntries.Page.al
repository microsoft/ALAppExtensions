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
                field(postingDate; "Posting Date")
                {
                    Caption = 'Posting Date';
                }
                field(documentNumber; "Document No.")
                {
                    Caption = 'Document No.';
                }
                field(documentType; "Document Type")
                {
                    Caption = 'Document Type';
                }
                field(accountId; "Account Id")
                {
                    Caption = 'Account Id';
                }
                field(accountNumber; "G/L Account No.")
                {
                    Caption = 'Account No.';
                }
                field(description; Description)
                {
                    Caption = 'Description';
                }
                field(debitAmount; "Debit Amount")
                {
                    Caption = 'Debit Amount';
                }
                field(creditAmount; "Credit Amount")
                {
                    Caption = 'Credit Amount';
                }
                field(lastModifiedDateTime; SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                }
                part(attachments; "APIV2 - Attachments")
                {
                    Caption = 'Attachments';
                    EntityName = 'attachment';
                    EntitySetName = 'attachments';
                    SubPageLink = "Document Id" = Field(SystemId), "Document Type" = const(Journal);
                }
                part(dimensionSetLines; "APIV2 - Dimension Set Lines")
                {
                    Caption = 'Dimension Set Lines';
                    EntityName = 'dimensionSetLine';
                    EntitySetName = 'dimensionSetLines';
                    SubPageLink = "Parent Id" = Field(SystemId), "Parent Type" = const("General Ledger Entry");
                }
            }
        }
    }

    actions
    {
    }
}