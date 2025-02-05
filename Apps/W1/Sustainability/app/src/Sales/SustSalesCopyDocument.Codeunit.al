namespace Microsoft.Sustainability.Sales;

using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Utilities;

codeunit 6252 "Sust. Sales Copy Document"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnCopySalesDocLineOnAfterCalcShouldValidateQuantityMoveNegLines', '', false, false)]
    local procedure OnCopyPurchLineOnBeforeValidateQuantity(var ToSalesLine: Record "Sales Line"; FromSalesLine: Record "Sales Line")
    begin
        CopyFromSalesLine(ToSalesLine, FromSalesLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnCopySalesShptLinesToDocOnAfterCopySalesShptLineToSalesLine', '', false, false)]
    local procedure OnAfterCopyPurchRcptLine(ToSalesLine: Record "Sales Line"; FromSalesShptLine: Record "Sales Shipment Line")
    begin
        CopyFromSalesShipmentLine(ToSalesLine, FromSalesShptLine);
    end;

    local procedure CopyFromSalesLine(var ToSalesLine: Record "Sales Line"; FromSalesLine: Record "Sales Line")
    begin
        ToSalesLine."Posted Total CO2e" := 0;

        if ToSalesLine."Sust. Account No." <> FromSalesLine."Sust. Account No." then
            ToSalesLine.Validate("Sust. Account No.", FromSalesLine."Sust. Account No.");

        if ToSalesLine."Sust. Account Category" <> FromSalesLine."Sust. Account Category" then
            ToSalesLine.Validate("Sust. Account Category", FromSalesLine."Sust. Account Category");

        if ToSalesLine."Sust. Account Subcategory" <> FromSalesLine."Sust. Account Subcategory" then
            ToSalesLine.Validate("Sust. Account Subcategory", FromSalesLine."Sust. Account Subcategory");

        ToSalesLine.Validate("CO2e per Unit", FromSalesLine."CO2e per Unit");
    end;

    local procedure CopyFromSalesShipmentLine(var ToSalesLine: Record "Sales Line"; FromSalesShptLine: Record "Sales Shipment Line")
    begin
        ToSalesLine."Posted Total CO2e" := 0;

        if ToSalesLine."Sust. Account No." <> FromSalesShptLine."Sust. Account No." then
            ToSalesLine.Validate("Sust. Account No.", FromSalesShptLine."Sust. Account No.");

        if ToSalesLine."Sust. Account Category" <> FromSalesShptLine."Sust. Account Category" then
            ToSalesLine.Validate("Sust. Account Category", FromSalesShptLine."Sust. Account Category");

        if ToSalesLine."Sust. Account Subcategory" <> FromSalesShptLine."Sust. Account Subcategory" then
            ToSalesLine.Validate("Sust. Account Subcategory", FromSalesShptLine."Sust. Account Subcategory");

        ToSalesLine.Validate("CO2e per Unit", FromSalesShptLine."CO2e per Unit");
    end;
}