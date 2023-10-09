namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.History;

codeunit 30258 "Shpfy Open SalesShipment" implements "Shpfy IOpenBCDocument"
{

    procedure OpenDocument(DocumentNo: Code[20])
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
    begin
        if SalesShipmentHeader.Get(DocumentNo) then begin
            SalesShipmentHeader.SetRecFilter();
            Page.Run(Page::"Posted Sales Shipment", SalesShipmentHeader);
        end;
    end;

}