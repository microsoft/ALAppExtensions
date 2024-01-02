namespace Microsoft.Intercompany.CrossEnvironment;

using Microsoft.Intercompany.DataExchange;

page 30419 "API Buf IC Inbox Purchase Line"
{
    PageType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'intercompany';
    APIVersion = 'v1.0';
    EntityName = 'bufferIntercompanyInboxPurchaseLine';
    EntitySetName = 'bufferIntercompanyInboxPurchaseLines';
    EntityCaption = 'Buffer Intercompany Inbox Purchase Line';
    EntitySetCaption = 'Buffer Intercompany Inbox Purchase Lines';
    SourceTable = "Buffer IC Inbox Purchase Line";
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
                field(directUnitCost; Rec."Direct Unit Cost")
                {
                    Caption = 'Direct Unit Cost';
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
                field(indirectCost; Rec."Indirect Cost %")
                {
                    Caption = 'Indirect Cost %';
                    Editable = true;
                }
                field(receiptNumber; Rec."Receipt No.")
                {
                    Caption = 'Receipt Number';
                    Editable = true;
                }
                field(receiptLineNumber; Rec."Receipt Line No.")
                {
                    Caption = 'Receipt Line Number';
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
                field(unitCost; Rec."Unit Cost")
                {
                    Caption = 'Unit Cost';
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
                    Caption = 'Intercompany Itemreference Number';
                }
                field(unitOfMeasureCode; Rec."Unit of Measure Code")
                {
                    Caption = 'Unit of Measure Code';
                    Editable = true;
                }
                field(requestedReceiptDate; Rec."Requested Receipt Date")
                {
                    Caption = 'Requested Receipt Date';
                    Editable = true;
                }
                field(promisedReceiptDate; Rec."Promised Receipt Date")
                {
                    Caption = 'Promised Receipt Date';
                }
                field(returnShipmentNumber; Rec."Return Shipment No.")
                {
                    Caption = 'Return Shipment Number';
                    Editable = true;
                }
                field(returnShipmentLineNumber; Rec."Return Shipment Line No.")
                {
                    Caption = 'Return Shipment Line Number';
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