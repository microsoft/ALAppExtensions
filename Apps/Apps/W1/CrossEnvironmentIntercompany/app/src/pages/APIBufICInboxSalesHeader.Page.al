namespace Microsoft.Intercompany.CrossEnvironment;

using Microsoft.Intercompany.DataExchange;

page 30421 "API Buf IC Inbox Sales Header"
{
    PageType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'intercompany';
    APIVersion = 'v1.0';
    EntityName = 'bufferIntercompanyInboxSalesHeader';
    EntitySetName = 'bufferIntercompanyInboxSalesHeaders';
    EntityCaption = 'Buffer Intercompany Inbox Sales Header';
    EntitySetCaption = 'Buffer Intercompany Inbox Sales Headers';
    SourceTable = "Buffer IC Inbox Sales Header";
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
                field(sellToCustomerNumber; Rec."Sell-to Customer No.")
                {
                    Caption = 'Sell-to Customer Number';
                    Editable = true;
                }
                field(number; Rec."No.")
                {
                    Caption = 'Number';
                    Editable = true;
                }
                field(billToCustomerNumber; Rec."Bill-to Customer No.")
                {
                    Caption = 'Bill-to Customer Number';
                    Editable = true;
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
                field(shipToName; Rec."Ship-to Name")
                {
                    Caption = 'Ship-to Name';
                    Editable = true;
                }
                field(shipToAddress; Rec."Ship-to Address")
                {
                    Caption = 'Ship-to Address';
                    Editable = true;
                }
                field(shipToAddress2; Rec."Ship-to Address 2")
                {
                    Caption = 'Ship-to Address 2';
                    Editable = true;
                }
                field(shipToCity; Rec."Ship-to City")
                {
                    Caption = 'Ship-to City';
                    Editable = true;
                }
                field(postingDate; Rec."Posting Date")
                {
                    Caption = 'Posting Date';
                }
                field(dueDate; Rec."Due Date")
                {
                    Caption = 'Due Date';
                }
                field(paymentDiscount; Rec."Payment Discount %")
                {
                    Caption = 'Payment Discount %';
                    Editable = true;
                }
                field(paymentDiscountDate; Rec."Pmt. Discount Date")
                {
                    Caption = 'Payment Discount Date';
                    Editable = true;
                }
                field(currencyCode; Rec."Currency Code")
                {
                    Caption = 'Currency Code';
                    Editable = true;
                }
                field(pricesIncludingVat; Rec."Prices Including VAT")
                {
                    Caption = 'Prices Including VAT';
                }
                field(shipToPostCode; Rec."Ship-to Post Code")
                {
                    Caption = 'Ship-to Post Code';
                    Editable = true;
                }
                field(shipToCounty; Rec."Ship-to County")
                {
                    Caption = 'Ship-to County';
                }
                field(shipToCountryRegionCode; Rec."Ship-to Country/Region Code")
                {
                    Caption = 'Ship-to Country/Region Code';
                }
                field(documentDate; Rec."Document Date")
                {
                    Caption = 'Document Date';
                }
                field(externalDocumentNumber; Rec."External Document No.")
                {
                    Caption = 'External Document Number';
                }
                field(intercompanyPartnerCode; Rec."IC Partner Code")
                {
                    Caption = 'Intercompany Partner Code';
                    Editable = true;
                }
                field(intercompanyTransactionNumber; Rec."IC Transaction No.")
                {
                    Caption = 'Intercompany Transaction Number';
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
                field(requestedDeliveryDate; Rec."Requested Delivery Date")
                {
                    Caption = 'Requested Delivery Date';
                    Editable = true;
                }
                field(promisedDeliveryDate; Rec."Promised Delivery Date")
                {
                    Caption = 'Promised Delivery Date';
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
        DocumentTypeOrdinal := Rec."Document Type".AsInteger();
        TransactionSourceIndex := Rec."Transaction Source";
    end;

    var
        IDShouldBeSpecifiedErr: Label 'Operation ID should be specified';
        ThereAreNoNotificationsForSpecifiedIDErr: Label 'There are no notifications for specified ID';
        DocumentTypeOrdinal, TransactionSourceIndex : Integer;
}