namespace Microsoft.Intercompany.CrossEnvironment;

using Microsoft.Intercompany;
using Microsoft.Intercompany.Inbox;

page 30411 "API - IC Inbox Transactions"
{
    PageType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'intercompany';
    APIVersion = 'v1.0';
    EntityName = 'intercompanyInboxTransaction';
    EntitySetName = 'intercompanyInboxTransactions';
    EntityCaption = 'Intercompany Inbox Transaction';
    EntitySetCaption = 'Intercompany Inbox Transactions';
    SourceTable = "IC Inbox Transaction";
    DelayedInsert = true;
    Extensible = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    ODataKeyFields = SystemId;

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
                    Editable = true;
                }
                field(icPartnerCode; Rec."IC Partner Code")
                {
                    Caption = 'Intercompany Partner Code';
                    Editable = true;
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
                    Editable = true;
                }
                field(documentTypeOrdinal; DocumentTypeOrdinal)
                {
                    Caption = 'Document Type Ordinal';
                }
                field(documentNumber; Rec."Document No.")
                {
                    Caption = 'Document Number';
                    Editable = true;
                }
                field(postingDate; Rec."Posting Date")
                {
                    Caption = 'Posting Date';
                    Editable = true;
                }
                field(transactionSource; Rec."Transaction Source")
                {
                    Caption = 'Transaction Source';
                    Editable = true;
                }
                field(transactionSourceIndex; TransactionSourceIndex)
                {
                    Caption = 'Transaction Source Index';
                }
                field(documentDate; Rec."Document Date")
                {
                    Caption = 'Document Date';
                    Editable = true;
                }
                field(lineAction; Rec."Line Action")
                {
                    Caption = 'Line Action';
                }
                field(lineActionIndex; LineActionIndex)
                {
                    Caption = 'Line Action Index';
                }
                field(originalDocumentNumber; Rec."Original Document No.")
                {
                    Caption = 'Original Document Number';
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
        LineActionIndex := Rec."Line Action";
        IcAccountTypeOrdinal := Rec."IC Account Type".AsInteger();
    end;

    var
        LocalSourceType: Option Journal,"Sales Document","Purchase Document";
        SourceTypeIndex, DocumentTypeOrdinal, TransactionSourceIndex, LineActionIndex, IcAccountTypeOrdinal : Integer;
}