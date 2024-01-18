namespace Microsoft.Intercompany.CrossEnvironment;

using Microsoft.Intercompany.DataExchange;

page 30418 "API Buf IC Inbox Jnl Line"
{
    PageType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'intercompany';
    APIVersion = 'v1.0';
    EntityName = 'bufferIntercompanyInboxJournalLine';
    EntitySetName = 'bufferIntercompanyInboxJournalLines';
    EntityCaption = 'Buffer Intercompany Inbox Journal Line';
    EntitySetCaption = 'Buffer Intercompany Inbox Journal Lines';
    SourceTable = "Buffer IC Inbox Jnl. Line";
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
                    Editable = true;
                }
                field(icPartnerCode; Rec."IC Partner Code")
                {
                    Caption = 'Intercompany Partner Code';
                    Editable = true;
                }
                field(lineNumber; Rec."Line No.")
                {
                    Caption = 'Line Number';
                    Editable = true;
                }
                field(accountType; Rec."Account Type")
                {
                    Caption = 'Account Type';
                }
                field(accountTypeIndex; AccountTypeIndex)
                {
                    Caption = 'Account Type Index';
                }
                field(accountNumber; Rec."Account No.")
                {
                    Caption = 'Account Number';
                }
                field(amount; Rec.Amount)
                {
                    Caption = 'Amount';
                    Editable = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(vatAmount; Rec."VAT Amount")
                {
                    Caption = 'VAT Amount';
                    Editable = true;
                }
                field(currencyCode; Rec."Currency Code")
                {
                    Caption = 'Currency Code';
                    Editable = true;
                }
                field(dueDate; Rec."Due Date")
                {
                    Caption = 'Due Date';
                }
                field(paymentDiscount; Rec."Payment Discount %")
                {
                    Caption = 'Payment Discount %';
                }
                field(paymentDiscountDate; Rec."Payment Discount Date")
                {
                    Caption = 'Payment Discount Date';
                }
                field(quantity; Rec.Quantity)
                {
                    Caption = 'Quantity';
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
                field(documentNumber; Rec."Document No.")
                {
                    Caption = 'Document Number';
                    Editable = true;
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
        AccountTypeIndex := Rec."Account Type";
        TransactionSourceIndex := Rec."Transaction Source";
    end;

    var
        IDShouldBeSpecifiedErr: Label 'Operation ID should be specified';
        ThereAreNoNotificationsForSpecifiedIDErr: Label 'There are no notifications for specified ID';
        AccountTypeIndex, TransactionSourceIndex : Integer;
}