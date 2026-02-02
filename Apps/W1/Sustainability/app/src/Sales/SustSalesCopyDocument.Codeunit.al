namespace Microsoft.Sustainability.Sales;

using Microsoft.Inventory.Ledger;
using Microsoft.Manufacturing.Capacity;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sustainability.Posting;
using Microsoft.Utilities;

codeunit 6252 "Sust. Sales Copy Document"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnCopySalesDocLineOnAfterCalcShouldValidateQuantityMoveNegLines', '', false, false)]
    local procedure OnCopyPurchLineOnBeforeValidateQuantity(var ToSalesLine: Record "Sales Line"; FromSalesLine: Record "Sales Line")
    begin
        CopyFromSalesLine(ToSalesLine, FromSalesLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnCopySalesInvLinesToDocOnBeforeCopySalesLine', '', false, false)]
    local procedure OnCopySalesInvLinesToDocOnBeforeCopySalesLine(var FromSalesLine: Record "Sales Line"; var ToSalesLine: Record "Sales Line"; FromSalesInvLine: Record "Sales Invoice Line")
    begin
        if FromSalesInvLine.Type <> FromSalesInvLine.Type::Item then
            exit;
        if FromSalesLine.Quantity = 0 then
            exit;

        GetTotalCO2eFromSalesInvLine(FromSalesInvLine, FromSalesLine."Total CO2e");
        ToSalesLine."Total CO2e" := FromSalesLine."Total CO2e";
        ToSalesLine."CO2e per Unit" := FromSalesLine."Total CO2e" / Abs(FromSalesLine.Quantity);
        FromSalesLine."CO2e per Unit" := FromSalesLine."Total CO2e" / Abs(FromSalesLine.Quantity);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnCopySalesShptLinesToDocOnAfterCopySalesShptLineToSalesLine', '', false, false)]
    local procedure OnAfterCopyPurchRcptLine(ToSalesLine: Record "Sales Line"; FromSalesShptLine: Record "Sales Shipment Line")
    begin
        CopyFromSalesShipmentLine(ToSalesLine, FromSalesShptLine);
    end;

    local procedure CopyFromSalesLine(var ToSalesLine: Record "Sales Line"; FromSalesLine: Record "Sales Line")
    begin
        ToSalesLine."Posted Total CO2e" := 0;
        ToSalesLine."Posted Total EPR Fee" := 0;

        if ToSalesLine."Sust. Account No." <> FromSalesLine."Sust. Account No." then
            ToSalesLine.Validate("Sust. Account No.", FromSalesLine."Sust. Account No.");

        if ToSalesLine."Sust. Account Category" <> FromSalesLine."Sust. Account Category" then
            ToSalesLine.Validate("Sust. Account Category", FromSalesLine."Sust. Account Category");

        if ToSalesLine."Sust. Account Subcategory" <> FromSalesLine."Sust. Account Subcategory" then
            ToSalesLine.Validate("Sust. Account Subcategory", FromSalesLine."Sust. Account Subcategory");

        ToSalesLine.Validate("CO2e per Unit", FromSalesLine."CO2e per Unit");
        ToSalesLine.Validate("EPR Fee Per Unit", FromSalesLine."EPR Fee Per Unit");
    end;

    local procedure GetTotalCO2eFromSalesInvLine(var FromSalesInvLine: Record "Sales Invoice Line"; var TotalCO2e: Decimal)
    var
        TempItemLedgerEntry: Record "Item Ledger Entry" temporary;
        SustainabilityPostMgt: Codeunit "Sustainability Post Mgt";
        PerILECO2e: Decimal;
        CapacityTypeJournal: Enum "Capacity Type Journal";
    begin
        if not SustainabilityPostMgt.IsCarbonTrackingSpecificItem(FromSalesInvLine."No.") then
            exit;

        TotalCO2e := 0;
        FromSalesInvLine.GetItemLedgEntries(TempItemLedgerEntry, false);
        if not TempItemLedgerEntry.FindSet() then
            exit;

        repeat
            SustainabilityPostMgt.GetTotalCO2eAmount(TempItemLedgerEntry, CapacityTypeJournal::" ", PerILECO2e, 0);
            TotalCO2e += PerILECO2e;
        until TempItemLedgerEntry.Next() = 0;
    end;

    local procedure CopyFromSalesShipmentLine(var ToSalesLine: Record "Sales Line"; FromSalesShptLine: Record "Sales Shipment Line")
    begin
        ToSalesLine."Posted Total CO2e" := 0;
        ToSalesLine."Posted Total EPR Fee" := 0;

        if ToSalesLine."Sust. Account No." <> FromSalesShptLine."Sust. Account No." then
            ToSalesLine.Validate("Sust. Account No.", FromSalesShptLine."Sust. Account No.");

        if ToSalesLine."Sust. Account Category" <> FromSalesShptLine."Sust. Account Category" then
            ToSalesLine.Validate("Sust. Account Category", FromSalesShptLine."Sust. Account Category");

        if ToSalesLine."Sust. Account Subcategory" <> FromSalesShptLine."Sust. Account Subcategory" then
            ToSalesLine.Validate("Sust. Account Subcategory", FromSalesShptLine."Sust. Account Subcategory");

        ToSalesLine.Validate("CO2e per Unit", FromSalesShptLine."CO2e per Unit");
        ToSalesLine.Validate("EPR Fee Per Unit", FromSalesShptLine."EPR Fee per Unit");
    end;
}