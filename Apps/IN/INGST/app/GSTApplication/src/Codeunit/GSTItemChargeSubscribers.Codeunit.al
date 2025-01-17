// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Application;

using Microsoft.Finance.GST.Base;
using Microsoft.Finance.GST.Payments;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Inventory.Journal;
using Microsoft.Inventory.Tracking;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Posting;

codeunit 18438 "GST Item Charge Subscribers"
{
    var
        GSTSetup: Record "GST Setup";
        GSTApplicationSessionMgt: Codeunit "GST Application Session Mgt.";
        Sign: Integer;

    local procedure GetItemChargeGSTAmount(PurchaseLine: Record "Purchase Line") GSTAmountLoaded: Decimal;
    var
        TaxTransactionValue: Record "Tax Transaction Value";
        GSTPurchaseNonAvailment: Codeunit "GST Purchase Non Availment";
    begin
        if (PurchaseLine.Type = PurchaseLine.Type::"Charge (Item)") and (PurchaseLine."GST Credit" = PurchaseLine."GST Credit"::"Non-Availment") then begin
            if not GSTSetup.Get() then
                exit;

            GSTSetup.TestField("GST Tax Type");

            TaxTransactionValue.SetLoadFields("Tax Record ID", "Tax Type", Percent, "Value ID", "Amount (LCY)");
            TaxTransactionValue.SetCurrentKey("Tax Record ID", "Tax Type");
            TaxTransactionValue.SetRange("Tax Type", GSTSetup."GST Tax Type");
            TaxTransactionValue.SetRange("Tax Record ID", PurchaseLine.RecordId);
            TaxTransactionValue.SetFilter(Percent, '<>%1', 0);
            if TaxTransactionValue.FindSet() then
                repeat
                    GSTAmountLoaded += GSTPurchaseNonAvailment.RoundTaxAmount(GSTSetup."GST Tax Type", TaxTransactionValue."Value ID", TaxTransactionValue."Amount (LCY)");
                until TaxTransactionValue.Next() = 0;

            if PurchaseLine."Document Type" in [PurchaseLine."Document Type"::Order,
                PurchaseLine."Document Type"::Invoice,
                PurchaseLine."Document Type"::Quote,
                PurchaseLine."Document Type"::"Blanket Order"] then
                Sign := 1
            else
                Sign := -1;

            GSTAmountLoaded := GSTAmountLoaded * Sign;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePostItemChargePerOrder', '', false, false)]
    local procedure PurchPostOnBeforePostItemChargePerOrder(
        var PurchHeader: Record "Purchase Header";
        var PurchLine: Record "Purchase Line";
        var ItemJnlLine2: Record "Item Journal Line";
        var ItemChargePurchLine: Record "Purchase Line";
        var TempTrackingSpecificationChargeAssmt: Record "Tracking Specification" temporary;
        CommitIsSupressed: Boolean;
        var TempItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)" temporary)
    var
        PurchaseLine: Record "Purchase Line";
        GSTAmountLoaded: Decimal;
    begin
        PurchaseLine.Get(PurchLine."Document Type", PurchLine."Document No.", TempItemChargeAssgntPurch."Document Line No.");
        GSTAmountLoaded := GetItemChargeGSTAmount(PurchaseLine);
        if PurchHeader."Document Type" in [PurchHeader."Document Type"::"Credit Memo", PurchHeader."Document Type"::"Return Order"] then
            TempItemChargeAssgntPurch."Amount to Assign" -= GSTAmountLoaded * TempItemChargeAssgntPurch."Qty. to Assign"
        else
            TempItemChargeAssgntPurch."Amount to Assign" += GSTAmountLoaded * TempItemChargeAssgntPurch."Qty. to Assign";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnPostItemChargeOnBeforePostItemJnlLine', '', false, false)]
    local procedure PurchPostOnPostItemChargeOnBeforePostItemJnlLine(
        var PurchaseLineToPost: Record "Purchase Line";
        var PurchaseLine: Record "Purchase Line";
        QtyToAssign: Decimal;
        var TempItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)" temporary)
    var
        GSTAmountLoaded: Decimal;
    begin
        GSTAmountLoaded := GetItemChargeGSTAmount(PurchaseLine);
        if TempItemChargeAssgntPurch."Document Type" in [TempItemChargeAssgntPurch."Document Type"::"Credit Memo", TempItemChargeAssgntPurch."Document Type"::"Return Order"] then
            GSTAmountLoaded := -1 * GSTAmountLoaded;

        if (TempItemChargeAssgntPurch."Document Type" = Enum::"Purchase Document Type"::Invoice) and
            (TempItemChargeAssgntPurch."Applies-to Doc. Type" = Enum::"Purchase Applies-to Document Type"::"Sales Shipment") then
            GSTAmountLoaded := -1 * GSTAmountLoaded;

        GSTApplicationSessionMgt.SetGSTAmountLoaded(GSTAmountLoaded * TempItemChargeAssgntPurch."Qty. to Assign");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnPostItemChargePerTransferOnBeforePostItemJnlLine', '', false, false)]
    local procedure PurchPostOnPostItemChargePerTransferOnBeforePostItemJnlLine(
        var PurchLine: Record "Purchase Line";
        ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)")
    var
        GSTAmountLoaded: Decimal;
    begin
        GSTAmountLoaded := GetItemChargeGSTAmount(PurchLine);
        if ItemChargeAssignmentPurch."Document Type" in [ItemChargeAssignmentPurch."Document Type"::"Credit Memo", ItemChargeAssignmentPurch."Document Type"::"Return Order"] then
            GSTAmountLoaded := -1 * GSTAmountLoaded;

        GSTApplicationSessionMgt.SetGSTAmountLoaded(GSTAmountLoaded * ItemChargeAssignmentPurch."Qty. to Assign");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnPostItemJnlLineOnAfterPrepareItemJnlLine', '', false, false)]
    local procedure PurchPostOnPostItemJnlLineOnAfterPrepareItemJnlLine(
        var ItemJournalLine: Record "Item Journal Line";
        PurchaseLine: Record "Purchase Line";
        PurchaseHeader: Record "Purchase Header")
    var
        GSTAmountLoaded: Decimal;
        Factor: Decimal;
    begin
        if (PurchaseLine.Type = PurchaseLine.Type::"Charge (Item)") and
            (PurchaseLine."GST Credit" = PurchaseLine."GST Credit"::"Non-Availment")
        then begin
            GSTAmountLoaded := GSTApplicationSessionMgt.GetGSTAmountLoaded();
            if PurchaseLine."Qty. to Invoice" <> 0 then
                Factor := (ItemJournalLine."Invoiced Quantity" / PurchaseLine."Qty. to Invoice");

            if PurchaseHeader."Document Type" in [PurchaseHeader."Document Type"::"Credit Memo", PurchaseHeader."Document Type"::"Return Order"] then
                ItemJournalLine.Amount := ItemJournalLine.Amount - Round(GSTAmountLoaded * Factor)
            else
                ItemJournalLine.Amount := ItemJournalLine.Amount + Round(GSTAmountLoaded * Factor);

            GSTApplicationSessionMgt.SetGSTAmountLoaded(0);
        end;
    end;
}
