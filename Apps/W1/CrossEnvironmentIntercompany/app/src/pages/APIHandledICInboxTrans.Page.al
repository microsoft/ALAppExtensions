namespace Microsoft.Intercompany.CrossEnvironment;

using Microsoft.Intercompany;
using Microsoft.Intercompany.Inbox;

page 30400 "API - Handled IC Inbox Trans."
{
    PageType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'intercompany';
    APIVersion = 'v1.0';
    EntityName = 'handledIntercompanyInboxTransaction';
    EntitySetName = 'handledIntercompanyInboxTransactions';
    EntityCaption = 'Handled Intercompany Inbox Transaction';
    EntitySetCaption = 'Handled Intercompany Inbox Transactions';
    SourceTable = "Handled IC Inbox Trans.";
    DelayedInsert = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    ODataKeyFields = SystemId;
    Extensible = false;
    Editable = false;
    DataAccessIntent = ReadOnly;

    layout
    {
        area(Content)
        {
            repeater(Records)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                }
                field(transactionNumber; Rec."Transaction No.")
                {
                    Caption = 'Transaction Number';
                }
                field(icPartnerCode; Rec."IC Partner Code")
                {
                    Caption = 'Intercompany Partner Code';
                }
                field(sourceType; LocalSourceType)
                {
                    Caption = 'Source Type';
                    Editable = true;
                }
                field(icSourceType; Rec."IC Source Type")
                {
                    Caption = 'IC Source Type';
                    Editable = true;
                }
                field(sourceTypeIndex; SourceTypeIndex)
                {
                    Caption = 'Source Type Index';
                }
                field(documentType; Rec."Document Type")
                {
                    Caption = 'Document Type';
                }
                field(documentTypeOrdinal; DocumentTypeOrdinal)
                {
                    Caption = 'Document Type Ordinal';
                }
                field(documentNumber; Rec."Document No.")
                {
                    Caption = 'Document Number';
                }
                field(postingDate; Rec."Posting Date")
                {
                    Caption = 'Posting Date';
                }
                field(transactionSource; Rec."Transaction Source")
                {
                    Caption = 'Transaction Source';
                }
                field(transactionSourceIndex; TransactionSourceIndex)
                {
                    Caption = 'Transaction Source Index';
                }
                field(documentDate; Rec."Document Date")
                {
                    Caption = 'Document Date';
                }
                field(status; Rec."Status")
                {
                    Caption = 'Status';
                }
                field(statusIndex; StatusIndex)
                {
                    Caption = 'Status Index';
                }
                field(sourceLineNumber; Rec."Source Line No.")
                {
                    Caption = 'Source Line Number';
                }
                field(icAccountType; Rec."IC Account Type")
                {
                    Caption = 'Intercompany Account Type';
                }
                field(icAccountTypeOrdinal; IcAccountTypeOrdinal)
                {
                    Caption = 'Intercompany Account Type Ordinal';
                }
                field(icAccountNumber; Rec."IC Account No.")
                {
                    Caption = 'Intercompany Account Number';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        case Rec."IC Source Type" of
            Enum::"IC Transaction Source Type"::Journal:
                LocalSourceType := LocalSourceType::Journal;
            Enum::"IC Transaction Source Type"::"Sales Document":
                LocalSourceType := LocalSourceType::"Sales Document";
            Enum::"IC Transaction Source Type"::"Purchase Document":
                LocalSourceType := LocalSourceType::"Purchase Document";
        end;
        SourceTypeIndex := Rec."IC Source Type".AsInteger();
        DocumentTypeOrdinal := Rec."Document Type".AsInteger();
        TransactionSourceIndex := Rec."Transaction Source";
        StatusIndex := Rec."Status";
    end;

    var
        LocalSourceType: Option Journal,"Sales Document","Purchase Document";
        SourceTypeIndex, DocumentTypeOrdinal, TransactionSourceIndex, StatusIndex, IcAccountTypeOrdinal : Integer;
}