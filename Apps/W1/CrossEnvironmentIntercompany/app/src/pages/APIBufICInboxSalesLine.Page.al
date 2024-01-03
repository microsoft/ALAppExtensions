namespace Microsoft.Intercompany.CrossEnvironment;

using Microsoft.Intercompany.DataExchange;

page 30422 "API Buf IC Inbox Sales Line"
{
    PageType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'intercompany';
    APIVersion = 'v1.0';
    EntityName = 'bufferIntercompanyInboxSalesLine';
    EntitySetName = 'bufferIntercompanyInboxSalesLines';
    EntityCaption = 'Buffer Intercompany Inbox Sales Line';
    EntitySetCaption = 'Buffer Intercompany Inbox Sales Lines';
    SourceTable = "Buffer IC Inbox Sales Line";
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
                field(lineNumber; Rec."Line No.")
                {
                    Caption = 'Line Number';
                    Editable = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(description2; Rec."Description 2")
                {
                    Caption = 'Description 2';
                }
                field(quantity; Rec.Quantity)
                {
                    Caption = 'Quantity';
                    Editable = true;
                }
                field(unitPrice; Rec."Unit Price")
                {
                    Caption = 'Unit Price';
                    Editable = true;
                }
                field(lineDiscount; Rec."Line Discount %")
                {
                    Caption = 'Line Discount %';
                }
                field(lineDiscountAmount; Rec."Line Discount Amount")
                {
                    Caption = 'Line Discount Amount';
                }
                field(amountIncludingVat; Rec."Amount Including VAT")
                {
                    Caption = 'Amount Including VAT';
                    Editable = true;
                }
                field(jobNumber; Rec."Job No.")
                {
                    Caption = 'Job Number';
                    Editable = true;
                }
                field(dropShipment; Rec."Drop Shipment")
                {
                    Caption = 'Drop Shipment';
                    Editable = true;
                }
                field(currencyCode; Rec."Currency Code")
                {
                    Caption = 'Currency Code';
                    Editable = true;
                }
                field(vatBaseAmount; Rec."VAT Base Amount")
                {
                    Caption = 'VAT Base Amount';
                    Editable = true;
                }
                field(lineAmount; Rec."Line Amount")
                {
                    Caption = 'Line Amount';
                    Editable = true;
                }
                field(icPartnerReferenceType; Rec."IC Partner Ref. Type")
                {
                    Caption = 'Intercompany Partner Reference Type';
                    Editable = true;
                }
                field(icPartnerReferenceTypeOrdinal; IcPartnerReferenceTypeOrdinal)
                {
                    Caption = 'Intercompany Partner Reference Type Ordinal';
                }
                field(icPartnerReference; Rec."IC Partner Reference")
                {
                    Caption = 'Intercompany Partner Reference';
                }
                field(icPartnerCode; Rec."IC Partner Code")
                {
                    Caption = 'Intercompany Partner Code';
                    Editable = true;
                }
                field(icTransactionNumber; Rec."IC Transaction No.")
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
                field(itemReference; Rec."Item Ref.")
                {
                    Caption = 'Item Reference';
                    Editable = true;
                }
                field(itemReferenceIndex; ItemReferenceIndex)
                {
                    Caption = 'Item Reference Index';
                }
                field(icItemReferenceNumber; Rec."IC Item Reference No.")
                {
                    Caption = 'Intercompany Item Reference Number';
                }
                field(unitOfMeasureCode; Rec."Unit of Measure Code")
                {
                    Caption = 'Unit of Measure Code';
                    Editable = true;
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
        IcPartnerReferenceTypeOrdinal := Rec."IC Partner Ref. Type".AsInteger();
        TransactionSourceIndex := Rec."Transaction Source";
        ItemReferenceIndex := Rec."Item Ref.";
    end;

    var
        IDShouldBeSpecifiedErr: Label 'Operation ID should be specified';
        ThereAreNoNotificationsForSpecifiedIDErr: Label 'There are no notifications for specified ID';
        DocumentTypeOrdinal, IcPartnerReferenceTypeOrdinal, TransactionSourceIndex, ItemReferenceIndex : Integer;
}