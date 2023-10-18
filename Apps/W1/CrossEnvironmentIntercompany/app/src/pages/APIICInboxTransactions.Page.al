namespace Microsoft.Intercompany.CrossEnvironment;

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
            field(sourceType; Rec."Source Type")
            {
                Caption = 'Source Type';
                Editable = true;
            }
            field(documentType; Rec."Document Type")
            {
                Caption = 'Document Type';
                Editable = true;
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
            field(documentDate; Rec."Document Date")
            {
                Caption = 'Document Date';
                Editable = true;
            }
            field(lineAction; Rec."Line Action")
            {
                Caption = 'Line Action';
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
            field(icAccountNumber; Rec."IC Account No.")
            {
                Caption = 'Intercompany Account Number';
            }
        }
    }
}