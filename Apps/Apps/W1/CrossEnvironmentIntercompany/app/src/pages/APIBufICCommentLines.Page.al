namespace Microsoft.Intercompany.CrossEnvironment;

using Microsoft.Intercompany.DataExchange;

page 30416 "API Buf IC Comment Lines"
{
    PageType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'intercompany';
    APIVersion = 'v1.0';
    EntityName = 'bufferIntercompanyCommentLine';
    EntitySetName = 'bufferIntercompanyCommentLines';
    EntityCaption = 'Buffer Intercompany Comment Line';
    EntitySetCaption = 'Buffer Intercompany Comment Lines';
    SourceTable = "Buffer IC Comment Line";
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
                field(tableName; Rec."Table Name")
                {
                    Caption = 'Table Name';
                }
                field(tableNameIndex; TableNameIndex)
                {
                    Caption = 'Table Name Index';
                }
                field(transactionNumber; Rec."Transaction No.")
                {
                    Caption = 'Transaction Number';
                }
                field(icPartnerCode; Rec."IC Partner Code")
                {
                    Caption = 'Intercompany Partner Code';
                }
                field(lineNumber; Rec."Line No.")
                {
                    Caption = 'Line Number';
                }
                field(date; Rec.Date)
                {
                    Caption = 'Date';
                }
                field(comment; Rec.Comment)
                {
                    Caption = 'Comment';
                }
                field(transactionSource; Rec."Transaction Source")
                {
                    Caption = 'Transaction Source';
                }
                field(transactionSourceIndex; TransactionSourceIndex)
                {
                    Caption = 'Transaction Source Index';
                }
                field(createdByIcPartnerCode; Rec."Created By IC Partner Code")
                {
                    Caption = 'Created By Intercompany Partner Code';
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
        TableNameIndex := Rec."Table Name";
        TransactionSourceIndex := Rec."Transaction Source";
    end;

    var
        IDShouldBeSpecifiedErr: Label 'Operation ID should be specified';
        ThereAreNoNotificationsForSpecifiedIDErr: Label 'There are no notifications for specified ID';
        TableNameIndex, TransactionSourceIndex : Integer;
}