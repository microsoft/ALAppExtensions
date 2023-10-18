namespace Microsoft.Intercompany.CrossEnvironment;

using Microsoft.Intercompany.DataExchange;

page 30423 "API Buf IC Inbox Transaction"
{
    PageType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'intercompany';
    APIVersion = 'v1.0';
    EntityName = 'bufferIntercompanyInboxTransaction';
    EntitySetName = 'bufferIntercompanyInboxTransactions';
    EntityCaption = 'Buffer Intercompany Inbox Transaction';
    EntitySetCaption = 'Buffer Intercompany Inbox Transactions';
    SourceTable = "Buffer IC Inbox Transaction";
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

    trigger OnOpenPage()
    var
        APIICNotificationOutbox: Record "IC Outgoing Notification";
        IdFilter: Text;
    begin
        IdFilter := Rec.GetFilter(Rec."Operation ID");
        if (IdFilter = '') then
            error(IDShouldBeSpecifiedErr);

        if not APIICNotificationOutbox.Get(IdFilter) then
            error(ThereAreNoNotificationsForSpecifiedIDErr);
    end;

    var
        IDShouldBeSpecifiedErr: Label 'Operation ID should be specified';
        ThereAreNoNotificationsForSpecifiedIDErr: Label 'There are no notifications for specified ID';
}