namespace Microsoft.Intercompany.CrossEnvironment;

using Microsoft.Intercompany.DataExchange;

page 30424 "API Buf IC InOut Jnl Line Dim"
{
    PageType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'intercompany';
    APIVersion = 'v1.0';
    EntityName = 'bufferIntercompanyInOutJournalLineDimension';
    EntitySetName = 'bufferIntercompanyInOutJournalLineDimensions';
    EntityCaption = 'Buffer Intercompany Inbox/Outbox Journal Line Dimension';
    EntitySetCaption = 'Buffer Intercompany Inbox/Outbox Journal Line Dimension';
    SourceTable = "Buffer IC InOut Jnl. Line Dim.";
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
                field(tableId; Rec."Table ID")
                {
                    Caption = 'Table Id';
                }
                field(icPartnerCode; Rec."IC Partner Code")
                {
                    Caption = 'Intercompany Partner Code';
                }
                field(transactionNumber; Rec."Transaction No.")
                {
                    Caption = 'Transaction Number';
                }
                field(lineNumber; Rec."Line No.")
                {
                    Caption = 'Line Number';
                }
                field(dimensionCode; Rec."Dimension Code")
                {
                    Caption = 'Dimension Code';
                }
                field(dimensionValueCode; Rec."Dimension Value Code")
                {
                    Caption = 'Dimension Value Code';
                }
                field(transactionSource; Rec."Transaction Source")
                {
                    Caption = 'Transaction Source';
                }
                field(transactionSourceIndex; TransactionSourceIndex)
                {
                    Caption = 'Transaction Source Index';
                }
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

    trigger OnAfterGetRecord()
    begin
        TransactionSourceIndex := Rec."Transaction Source";
    end;

    var
        IDShouldBeSpecifiedErr: Label 'Operation ID should be specified';
        ThereAreNoNotificationsForSpecifiedIDErr: Label 'There are no notifications for specified ID';
        TransactionSourceIndex: Integer;
}