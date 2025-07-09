// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

using Microsoft.Sales.Document;
using Microsoft.Purchases.Setup;
using Microsoft.Sales.Reports;
using Microsoft.Purchases.Document;
using Microsoft.Inventory.Item;
using Microsoft.Purchases.Reports;

codeunit 10581 "Reports Subscribers"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Access = Internal;

    var
        Text10500Err: Label 'Reverse charge item - please check correct VAT rate is entered. Reverse Charge %1', Comment = '%1 = reverse charge value';

    [EventSubscriber(ObjectType::Report, Report::"Sales Document - Test", OnAfterSalesPostGetSalesLines, '', false, false)]
    local procedure OnAfterSalesPostGetSalesLines(var SalesHeader: Record "Sales Header"; var TempSalesLine: Record "Sales Line" temporary)
    begin
        if SalesHeader.GetReverseChargeApplies() then
            TempSalesLine.SetReverseChargeAppliesGB();
    end;

    [EventSubscriber(ObjectType::Report, Report::"Purchase Document - Test", OnAfterCheckPurchLine, '', false, false)]
    local procedure OnAfterCheckPurchLine(PurchaseLine: Record "Purchase Line"; var PurchaseHeader: Record "Purchase Header"; var ErrorCounter: Integer; var ErrorText: Text[250])
    var
        PurchLine: Record "Purchase Line";
        PurchSetup: Record "Purchases & Payables Setup";
        Item: Record Item;
    begin
        if not (PurchaseLine.Type = PurchaseLine.Type::Item) then
            exit;
        if (PurchaseLine."No." = '') and (PurchaseLine.Quantity = 0) then
            exit;
        if not (PurchaseLine."No." <> '') then
            exit;
        if not Item.Get(PurchaseLine."No.") then
            exit;

        PurchSetup.Get();
        PurchaseHeader.SetReverseCharge(0);
        if PurchaseLine."Reverse Charge Item GB" and
           (PurchaseHeader."VAT Bus. Posting Group" = PurchSetup."Domestic Vendors GB") and
           (PurchaseHeader."VAT Registration No." <> '')
        then
            if PurchSetup."Reverse Charge VAT Post. Gr." = PurchaseLine."VAT Bus. Posting Group" then begin
                PurchLine := PurchaseLine;
                PurchLine.SuspendStatusCheck(true);
                PurchLine.Validate("VAT Bus. Posting Group", PurchSetup."Domestic Vendors GB");
                PurchLine.Validate(Amount);
                PurchaseHeader.SetReverseCharge(Round(
                    (PurchLine."Amount Including VAT" - PurchLine.Amount) *
                    PurchLine."Qty. to Invoice" / PurchLine.Quantity));
                AddError(StrSubstNo(Text10500Err, PurchaseHeader.GetReverseCharge()), ErrorCounter, ErrorText);
                PurchaseHeader.SetTotalReverseCharge(PurchaseHeader.GetTotalReverseCharge() + PurchaseHeader.GetReverseCharge());
            end else
                AddError(StrSubstNo(Text10500Err, Round(0)), ErrorCounter, ErrorText);
    end;

    local procedure AddError(Text: Text; var ErrorCounter: Integer; var ErrorText: Text[250])
    begin
        ErrorCounter := ErrorCounter + 1;
        ErrorText := CopyStr(Text, 1, MaxStrLen(ErrorText[ErrorCounter]));
    end;
}