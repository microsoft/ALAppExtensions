// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.Currency;
using Microsoft.Sales.Setup;
using Microsoft.Sales.Document;
using Microsoft.Purchases.Setup;
using Microsoft.Purchases.Document;
using Microsoft.Inventory.Item;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Purchases.Posting;
using System.Telemetry;
using Microsoft.Purchases.History;
using Microsoft.Sales.Posting;

codeunit 10552 "Reverse Charge VAT Subscribers"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Access = Internal;

    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        Text1041000Msg: Label 'Warning: You have selected an item that is subject to Reverse Charge VAT. Please check that the VAT Code %1 in the %2 field is correct. If necessary, update this field before posting. ', Comment = '%1 = field value; %2 = field caption';
        Text1041001Msg: Label 'cannot be %1. %2 %3 is not subjected to Reverse Charge', Comment = '%1, %2, %3 = field values';
        Text1041002Msg: Label 'cannot be %1. %1 can only be used for domestic customers and vendors. ', Comment = '%1 = field value';
        Text1041003Msg: Label 'cannot be %1. %1 can only be used for reverse charge items. ', Comment = '%1 = field value';
        ReverseChargeEventNameTok: Label 'Reverse Charge GB has been used', Locked = true;
        ReverseChargeFeatureNameTok: Label 'Reverse Charge GB', Locked = true;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnAfterAssignHeaderValues, '', false, false)]
    local procedure OnAfterAssignHeaderValues(var PurchLine: Record "Purchase Line"; PurchHeader: Record "Purchase Header")
    begin
        PurchLine."Reverse Charge Item GB" := false;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnValidateVATProdPostingGroupOnAfterCalcShouldUpdateUnitCost, '', false, false)]
    local procedure OnValidateVATProdPostingGroupOnAfterCalcShouldUpdateUnitCost(var PurchaseLine: Record "Purchase Line"; VATPostingSetup: Record "VAT Posting Setup"; var ShouldUpdateUnitCost: Boolean)
    var
        PurchSetup: Record "Purchases & Payables Setup";
        PurchHeader: Record "Purchase Header";
    begin
        PurchSetup.Get();
        if PurchHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.") then;

        if (PurchaseLine."VAT Bus. Posting Group" = PurchSetup."Reverse Charge VAT Post. Gr.") and
           (PurchHeader."VAT Bus. Posting Group" <> PurchSetup."Domestic Vendors GB") and
           (not PurchaseLine."Reverse Charge Item GB")
        then
            PurchaseLine.FieldError("VAT Bus. Posting Group", StrSubstNo(Text1041002Msg, PurchaseLine."VAT Bus. Posting Group"));
        if (not PurchaseLine."Reverse Charge Item GB") and
           (PurchaseLine."VAT Bus. Posting Group" = PurchSetup."Reverse Charge VAT Post. Gr.")
        then
            PurchaseLine.FieldError("VAT Bus. Posting Group", StrSubstNo(Text1041003Msg, PurchaseLine."VAT Bus. Posting Group"));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnInsertOnAfterLockTable, '', false, false)]
    local procedure OnInsertOnAfterLockTable(var PurchaseLine: Record "Purchase Line"; CurrFieldNo: Integer)
    begin
        DomesticVendorWarning(PurchaseLine, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnAfterModifyOnAfterVerifyChange, '', false, false)]
    local procedure OnAfterModifyOnAfterVerifyChange(var PurchaseLine: Record "Purchase Line"; CurrFieldNo: Integer)
    begin
        DomesticVendorWarning(PurchaseLine, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnCopyFromItemOnAfterCheck, '', false, false)]
    local procedure OnCopyFromItemOnAfterCheck(var PurchaseLine: Record "Purchase Line"; Item: Record Item; CallingFieldNo: Integer)
    begin
        PurchaseLine."Reverse Charge Item GB" := Item."Reverse Charge Applies GB";
    end;

    local procedure DomesticVendorWarning(var PurchaseLine: Record "Purchase Line"; CurrFieldNo: Integer)
    var
        GLSetup: Record "General Ledger Setup";
        PurchSetup: Record "Purchases & Payables Setup";
        PurchHeader: Record "Purchase Header";
    begin
        if not GuiAllowed() then
            exit;
        GLSetup.Get();
        PurchSetup.Get();
        PurchHeader := PurchaseLine.GetPurchHeader();
        if (CurrFieldNo = 0) and GLSetup."Threshold applies GB" and
           (PurchHeader."VAT Registration No." <> '') and
           (PurchaseLine.Type = PurchaseLine.Type::Item) and PurchaseLine."Reverse Charge Item GB" and
           (PurchaseLine."VAT Bus. Posting Group" = PurchSetup."Domestic Vendors GB")
        then
            Message(Text1041000Msg, PurchaseLine."VAT Bus. Posting Group", PurchaseLine.FieldCaption("VAT Bus. Posting Group"));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnAfterAssignHeaderValues, '', false, false)]
    local procedure OnAfterAssignHeaderValues2(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header")
    begin
        SalesLine."Reverse Charge Item GB" := false;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnValidateVATProdPostingGroupOnBeforeUpdateUnitPrice, '', false, false)]
    local procedure OnValidateVATProdPostingGroupOnBeforeUpdateUnitPrice(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; Currency: Record Currency)
    var
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        SalesSetup.Get();
        if (SalesLine."VAT Bus. Posting Group" = SalesSetup."Reverse Charge VAT Post. Gr.") and not SalesLine."Reverse Charge Item GB" then
            SalesLine.FieldError("VAT Bus. Posting Group", StrSubstNo(Text1041001Msg, SalesLine."VAT Bus. Posting Group", SalesLine.Type, SalesLine."No."));

        if SalesLine."Document Type" = SalesLine."Document Type"::"Credit Memo" then begin
            SalesLine."Reverse Charge GB" := 0;
            if (SalesLine."VAT Bus. Posting Group" = SalesSetup."Reverse Charge VAT Post. Gr.") and
             (SalesHeader."VAT Bus. Posting Group" = SalesSetup."Domestic Customers GB")
          then
                SalesLine."Reverse Charge GB" :=
                  Round(SalesLine.Amount * (1 - SalesHeader."VAT Base Discount %" / 100) * xSalesLine."VAT %" / 100,
                    Currency."Amount Rounding Precision", Currency.VATRoundingDirection());
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnAfterInsertOnAfterUpdateDeferralAmounts, '', false, false)]
    local procedure OnAfterInsertOnAfterUpdateDeferralAmounts(var SalesLine: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        DomesticCustomerWarning(SalesLine, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnAfterModifyOnAfterVerifyChangeForSalesLineReserve, '', false, false)]
    local procedure OnAfterModifyOnAfterVerifyChangeForSalesLineReserve(var SalesLine: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        DomesticCustomerWarning(SalesLine, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnCopyFromItemOnAfterCheck, '', false, false)]
    local procedure OnCopyFromItemOnAfterCheck2(var SalesLine: Record "Sales Line"; Item: Record Item)
    begin
        SalesLine."Reverse Charge Item GB" := Item."Reverse Charge Applies GB";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnCalcVATAmountLinesOnBeforeGetDeferralAmount, '', false, false)]
    local procedure OnCalcVATAmountLinesOnBeforeGetDeferralAmount(var SalesLine: Record "Sales Line")
    var
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        if SalesLine.GetReverseChargeApplies() and SalesLine."Reverse Charge Item GB" then begin
            SalesLine."Reverse Charge GB" := SalesLine."Amount Including VAT" - SalesLine.Amount;
            SalesLine.SuspendStatusCheck(true);
            SalesSetup.Get();
            SalesLine.Validate("VAT Bus. Posting Group", SalesSetup."Reverse Charge VAT Post. Gr.");
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnCalcVATAmountLinesOnBeforeProcessSalesLine, '', false, false)]
    local procedure OnCalcVATAmountLinesOnBeforeProcessSalesLine(var SalesLine: Record "Sales Line")
    var
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        if SalesLine.GetReverseChargeApplies() and SalesLine."Reverse Charge Item GB" then begin
            SalesLine."Reverse Charge GB" := SalesLine."Amount Including VAT" - SalesLine.Amount;
            SalesLine.SuspendStatusCheck(true);
            SalesSetup.Get();
            SalesLine.Validate("VAT Bus. Posting Group", SalesSetup."Reverse Charge VAT Post. Gr.");
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnInsertVATAmountOnBeforeInsert, '', false, false)]
#if not CLEAN25
#pragma warning disable AL0432
#endif
    local procedure OnInsertVATAmountOnBeforeInsert(var SalesLine: Record "Sales Line"; var VATAmountLine: Record "VAT Amount Line")
#if not CLEAN25
#pragma warning restore  AL0432
#endif
    begin
#if not CLEAN25
#pragma warning disable AL0432
#endif
        VATAmountLine."Reverse Charge GB" := SalesLine."Reverse Charge GB";
#if not CLEAN25
#pragma warning restore  AL0432
#endif
    end;

    local procedure DomesticCustomerWarning(SalesLine: Record "Sales Line"; CurrFieldNo: Integer)
    var
        GLSetup: Record "General Ledger Setup";
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        if not GuiAllowed() then
            exit;
        SalesSetup.Get();
        GLSetup.Get();
        if GLSetup."Threshold applies GB" and (CurrFieldNo = 0) and (SalesLine."Document Type" = SalesLine."Document Type"::"Credit Memo") and
           (SalesLine.Type = SalesLine.Type::Item) and SalesLine."Reverse Charge Item GB" and
           (SalesLine."VAT Bus. Posting Group" = SalesSetup."Domestic Customers GB")
        then
            Message(Text1041000Msg, SalesLine."VAT Bus. Posting Group", SalesLine.FieldCaption("VAT Bus. Posting Group"));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", OnBeforePurchInvLineInsert, '', false, false)]
    local procedure OnBeforePurchInvLineInsert(var PurchInvLine: Record "Purch. Inv. Line"; var PurchInvHeader: Record "Purch. Inv. Header"; var PurchaseLine: Record "Purchase Line"; CommitIsSupressed: Boolean; var xPurchaseLine: Record "Purchase Line")
    var
        TempPurchLine2: Record "Purchase Line" temporary;
        PurchSetup: Record "Purchases & Payables Setup";
        PurchHeader: Record "Purchase Header";
        Currency: Record Currency;
    begin
        if not PurchaseLine."Reverse Charge Item GB" then
            exit;
        PurchSetup.Get();
        PurchHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
        Currency.Initialize(PurchHeader."Currency Code");
        if (PurchSetup."Reverse Charge VAT Post. Gr." = PurchaseLine."VAT Bus. Posting Group") and
            PurchaseLine."Reverse Charge Item GB"
        then begin
            TempPurchLine2 := xPurchaseLine;
            TempPurchLine2.SuspendStatusCheck(true);
            TempPurchLine2.Validate("VAT Bus. Posting Group", PurchSetup."Domestic Vendors GB");
            TempPurchLine2.Validate(Amount);
            PurchInvLine."Reverse Charge GB" :=
              Round(
                (TempPurchLine2."Amount Including VAT" - TempPurchLine2.Amount) *
                TempPurchLine2."Qty. to Invoice" / TempPurchLine2.Quantity,
                Currency."Amount Rounding Precision");
            FeatureTelemetry.LogUsage('0000PBB', ReverseChargeFeatureNameTok, ReverseChargeEventNameTok);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnRunOnBeforeCalcVATAmountLines, '', false, false)]
#if not CLEAN25
#pragma warning disable AL0432
#endif
    local procedure OnRunOnBeforeCalcVATAmountLines(var TempSalesLineGlobal: Record "Sales Line" temporary; var SalesHeader: Record "Sales Header"; var TempVATAmountLine: Record "VAT Amount Line" temporary; var IsHandled: Boolean)
#if not CLEAN25
#pragma warning restore  AL0432
#endif
    begin
        if SalesHeader.GetReverseChargeApplies() then
            TempSalesLineGlobal.SetReverseChargeAppliesGB();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnPostSalesLineOnAfterTestUpdatedSalesLine, '', false, false)]
    local procedure OnPostSalesLineOnAfterTestUpdatedSalesLine(var SalesLine: Record "Sales Line"; var EverythingInvoiced: Boolean; SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    var
        SalesSetup: Record "Sales & Receivables Setup";
        Currency: Record Currency;
    begin
        if not (SalesLine.Quantity = 0) then
            exit;

        SalesSetup.Get();
        Currency.Initialize(SalesHeader."Currency Code");
        if SalesHeader.GetReverseChargeApplies() and SalesLine."Reverse Charge Item GB" then begin
            SalesLine."Reverse Charge GB" :=
              Round((SalesLine."Amount Including VAT" - SalesLine.Amount) *
                SalesLine."Qty. to Invoice" / SalesLine.Quantity, Currency."Amount Rounding Precision");
            SalesLine.SuspendStatusCheck(true);
            SalesLine.Validate("VAT Bus. Posting Group", SalesSetup."Reverse Charge VAT Post. Gr.");
            FeatureTelemetry.LogUsage('0000PBC', ReverseChargeFeatureNameTok, ReverseChargeEventNameTok);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnInsertPostedHeadersOnAfterCalcShouldInsertInvoiceHeader, '', false, false)]
    local procedure OnInsertPostedHeadersOnAfterCalcShouldInsertInvoiceHeader(var SalesHeader: Record "Sales Header"; var ShouldInsertInvoiceHeader: Boolean)
    var
        ReverseChargeVATProcedures: Codeunit "Reverse Charge VAT Procedures";
    begin
        if ShouldInsertInvoiceHeader then
            SalesHeader.SetReverseChargeApplies(ReverseChargeVATProcedures.CheckIfReverseChargeApplies(SalesHeader));
    end;
}