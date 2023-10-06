namespace Microsoft.Intercompany.CrossEnvironment;

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
            field(sourceType; Rec."Source Type")
            {
                Caption = 'Source Type';
            }
            field(documentType; Rec."Document Type")
            {
                Caption = 'Document Type';
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
            field(documentDate; Rec."Document Date")
            {
                Caption = 'Document Date';
            }
            field(status; Rec."Status")
            {
                Caption = 'Status';
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