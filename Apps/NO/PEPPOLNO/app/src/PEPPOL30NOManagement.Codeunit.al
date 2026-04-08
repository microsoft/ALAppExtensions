// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Peppol;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Sales.Document;
using Microsoft.Sales.FinanceCharge;
using Microsoft.Sales.Reminder;
using Microsoft.Utilities;

codeunit 37350 "PEPPOL30 NO Management"
{
    Access = Public;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        TAXTxt: Label 'TAX', Locked = true;
        BusinessEnterprisesTxt: Label 'Foretaksregisteret', Locked = true;
        AllowanceChargeReasonReminderTxt: Label 'REM', Locked = true;
        PaymentMeansFundsTransferCodeTxt: Label '31', Locked = true;
        ReminderLineTxt: Label 'Invoice %1 amount %2', Comment = '%1 - invoice no., %2 - amount.';
        VATTxt: Label 'VAT', Locked = true;

    procedure GetAccountingSupplierPartyTaxSchemeNO(var CompanyID: Text; var CompanyIDSchemeID: Text; var TaxSchemeID: Text)
    begin
        CompanyID := BusinessEnterprisesTxt;
        CompanyIDSchemeID := '';
        TaxSchemeID := TAXTxt;
    end;

    procedure GetPaymentMeansInfoReminder(SalesHeader: Record "Sales Header"; var PaymentMeansCode: Text; var PaymentChannelCode: Text; var PaymentID: Text; var PrimaryAccountNumberID: Text; var NetworkID: Text)
    var
        DocumentTools: Codeunit DocumentTools;
    begin
        PaymentMeansCode := PaymentMeansFundsTransferCodeTxt;
        PaymentChannelCode := '';
        PaymentID := DocumentTools.GetEHFDocumentPaymentID(SalesHeader, SalesHeader."Doc. No. Occurrence");
        PrimaryAccountNumberID := '';
        NetworkID := '';
    end;

    procedure GetAllowanceChargeInfoReminder(VATAmtLine: Record "VAT Amount Line"; SalesHeader: Record "Sales Header"; var ChargeIndicator: Text; var AllowanceChargeReasonCode: Text; var AllowanceChargeReason: Text; var Amount: Text; var AllowanceChargeCurrencyID: Text; var TaxCategoryID: Text; var TaxCategorySchemeID: Text; var Percent: Text; var AllowanceChargeTaxSchemeID: Text)
    begin
        ChargeIndicator := 'true';
        AllowanceChargeReasonCode := '';
        AllowanceChargeReason := AllowanceChargeReasonReminderTxt;
        Amount := Format(VATAmtLine."Amount Including VAT" - VATAmtLine."VAT Amount", 0, 9);
        AllowanceChargeCurrencyID := GetSalesDocCurrencyCode(SalesHeader);
        TaxCategoryID := VATAmtLine."Tax Category";
        TaxCategorySchemeID := '';
        Percent := Format(VATAmtLine."VAT %", 0, 9);
        AllowanceChargeTaxSchemeID := VATTxt;
    end;

    procedure CopyIssuedFinCharge(var TempSalesHeader: Record "Sales Header" temporary; var TempSalesLine: Record "Sales Line" temporary; var TempSalesLineInvRounding: Record "Sales Line" temporary; FinChargeNo: Code[20])
    var
        IssuedFinChargeMemoHeader: Record "Issued Fin. Charge Memo Header";
        IssuedFinChargeMemoLine: Record "Issued Fin. Charge Memo Line";
        IssuedReminderHeader: Record "Issued Reminder Header";
        IssuedReminderLine: Record "Issued Reminder Line";
    begin
        IssuedFinChargeMemoHeader.Get(FinChargeNo);
        IssuedReminderHeader.TransferFields(IssuedFinChargeMemoHeader);
        ReminderHeaderToSalesHeader(TempSalesHeader, IssuedReminderHeader, 2);
        IssuedFinChargeMemoLine.SetRange("Finance Charge Memo No.", FinChargeNo);
        if IssuedFinChargeMemoLine.FindSet() then
            repeat
                IssuedReminderLine.TransferFields(IssuedFinChargeMemoLine);
                ReminderLineToSalesLine(TempSalesLine, TempSalesLineInvRounding, IssuedReminderHeader, IssuedReminderLine);
            until IssuedFinChargeMemoLine.Next() = 0;
    end;

    procedure CopyIssuedReminder(var TempSalesHeader: Record "Sales Header" temporary; var TempSalesLine: Record "Sales Line" temporary; var TempSalesLineInvRounding: Record "Sales Line" temporary; ReminderNo: Code[20])
    var
        IssuedReminderHeader: Record "Issued Reminder Header";
        IssuedReminderLine: Record "Issued Reminder Line";
    begin
        IssuedReminderHeader.Get(ReminderNo);
        ReminderHeaderToSalesHeader(TempSalesHeader, IssuedReminderHeader, 3);

        IssuedReminderLine.SetRange("Reminder No.", ReminderNo);
        if IssuedReminderLine.FindSet() then
            repeat
                ReminderLineToSalesLine(TempSalesLine, TempSalesLineInvRounding, IssuedReminderHeader, IssuedReminderLine);
            until IssuedReminderLine.Next() = 0;
    end;

    procedure CopyFinCharge(var TempSalesHeader: Record "Sales Header" temporary; var TempSalesLine: Record "Sales Line" temporary; FinChargeNo: Code[20])
    var
        FinanceChargeMemoHeader: Record "Finance Charge Memo Header";
        FinanceChargeMemoLine: Record "Finance Charge Memo Line";
        IssuedReminderHeader: Record "Issued Reminder Header";
        IssuedReminderLine: Record "Issued Reminder Line";
        TempSalesLineInvRounding: Record "Sales Line" temporary;
    begin
        FinanceChargeMemoHeader.Get(FinChargeNo);
        IssuedReminderHeader.TransferFields(FinanceChargeMemoHeader);
        ReminderHeaderToSalesHeader(TempSalesHeader, IssuedReminderHeader, 2);
        FinanceChargeMemoLine.SetRange("Finance Charge Memo No.", FinChargeNo);
        if FinanceChargeMemoLine.FindSet() then
            repeat
                IssuedReminderLine.TransferFields(FinanceChargeMemoLine);
                ReminderLineToSalesLine(TempSalesLine, TempSalesLineInvRounding, IssuedReminderHeader, IssuedReminderLine);
            until FinanceChargeMemoLine.Next() = 0;
    end;

    procedure CopyReminder(var TempSalesHeader: Record "Sales Header" temporary; var TempSalesLine: Record "Sales Line" temporary; ReminderNo: Code[20])
    var
        ReminderHeader: Record "Reminder Header";
        ReminderLine: Record "Reminder Line";
        IssuedReminderHeader: Record "Issued Reminder Header";
        IssuedReminderLine: Record "Issued Reminder Line";
        TempSalesLineInvRounding: Record "Sales Line" temporary;
    begin
        ReminderHeader.Get(ReminderNo);
        IssuedReminderHeader.TransferFields(ReminderHeader);
        ReminderHeaderToSalesHeader(TempSalesHeader, IssuedReminderHeader, 3);
        ReminderLine.SetRange("Reminder No.", ReminderNo);
        if ReminderLine.FindSet() then
            repeat
                IssuedReminderLine.TransferFields(ReminderLine);
                ReminderLineToSalesLine(TempSalesLine, TempSalesLineInvRounding, IssuedReminderHeader, IssuedReminderLine);
            until ReminderLine.Next() = 0;
    end;

    procedure GetBillingReferenceInfo(var TempSalesLine: Record "Sales Line" temporary; var InvoiceDocRefID: Text)
    begin
        TempSalesLine.SetFilter("Document No.", '<>%1', '');
        TempSalesLine.FindFirst();
        InvoiceDocRefID := TempSalesLine."Document No.";
    end;

    procedure GetReminderLineNote(SalesLine: Record "Sales Line"): Text
    begin
        if SalesLine.Type = SalesLine.Type::"G/L Account" then
            exit(Format(SalesLine.Type));

        exit(
          StrSubstNo(ReminderLineTxt, SalesLine."Description 2", SalesLine."Outstanding Amount"))
    end;

    local procedure ReminderHeaderToSalesHeader(var TempSalesHeader: Record "Sales Header" temporary; IssuedReminderHeader: Record "Issued Reminder Header"; GiroKIDDocType: Integer)
    begin
        TempSalesHeader.Init();
        TempSalesHeader."No." := IssuedReminderHeader."No.";
        TempSalesHeader."Document Date" := IssuedReminderHeader."Document Date";
        TempSalesHeader."Posting Date" := IssuedReminderHeader."Posting Date";
        TempSalesHeader."Due Date" := IssuedReminderHeader."Due Date";
        TempSalesHeader."Currency Code" := IssuedReminderHeader."Currency Code";
        TempSalesHeader."Bill-to Customer No." := IssuedReminderHeader."Customer No.";
        TempSalesHeader."Bill-to Country/Region Code" := IssuedReminderHeader."Country/Region Code";
        TempSalesHeader."Bill-to Name" := IssuedReminderHeader.Name;
        TempSalesHeader."Bill-to Address" := IssuedReminderHeader.Address;
        TempSalesHeader."Bill-to Address 2" := IssuedReminderHeader."Address 2";
        TempSalesHeader."Bill-to City" := IssuedReminderHeader.City;
        TempSalesHeader."Bill-to Post Code" := IssuedReminderHeader."Post Code";
        TempSalesHeader."Bill-to County" := IssuedReminderHeader.County;
        if IssuedReminderHeader."Your Reference" = '' then
            TempSalesHeader."Your Reference" := IssuedReminderHeader."No."
        else
            TempSalesHeader."Your Reference" := IssuedReminderHeader."Your Reference";
        TempSalesHeader."Language Code" := IssuedReminderHeader."Language Code";
        TempSalesHeader."VAT Registration No." := IssuedReminderHeader."VAT Registration No.";
#if not CLEAN29
#pragma warning disable AL0432
        TempSalesHeader.GLN := IssuedReminderHeader.GLN;
#pragma warning restore AL0432
#endif
        TempSalesHeader."Doc. No. Occurrence" := GiroKIDDocType;
        TempSalesHeader."Shipment Date" := TempSalesHeader."Document Date";
        TempSalesHeader."Ship-to Address" := TempSalesHeader."Bill-to Address";
        TempSalesHeader."Ship-to City" := TempSalesHeader."Bill-to City";
        TempSalesHeader."Ship-to Post Code" := TempSalesHeader."Bill-to Post Code";
        TempSalesHeader."Ship-to Country/Region Code" := TempSalesHeader."Bill-to Country/Region Code";
        TempSalesHeader.Insert();
    end;

    local procedure ReminderLineToSalesLine(var TempSalesLine: Record "Sales Line" temporary; var TempSalesLineInvRounding: Record "Sales Line" temporary; IssuedReminderHeader: Record "Issued Reminder Header"; IssuedReminderLine: Record "Issued Reminder Line")
    var
        PEPPOL30: Codeunit "PEPPOL30";
    begin
        if (IssuedReminderLine.Type = IssuedReminderLine.Type::" ") and (IssuedReminderLine."No." = '') and
           (IssuedReminderLine.Description = '')
        then
            exit;

        TempSalesLine.Init();
        TempSalesLine."Document No." := IssuedReminderLine."Reminder No.";
        TempSalesLine."Bill-to Customer No." := IssuedReminderHeader."Customer No.";
        TempSalesLine."Line No." := IssuedReminderLine."Line No.";

        if IssuedReminderLine.Amount <> 0 then begin
            TempSalesLine.Type := TempSalesLine.Type::"G/L Account";
            TempSalesLine.Quantity := 0;
        end else begin
            TempSalesLine.Type := TempSalesLine.Type::" ";
            TempSalesLine.Quantity := 0;
        end;
        TempSalesLine."No." := IssuedReminderLine."No.";
        TempSalesLine.Description := IssuedReminderLine.Description;
        TempSalesLine."Description 2" := IssuedReminderLine."Document No.";
        TempSalesLine."Unit Price" := IssuedReminderLine.Amount;
        TempSalesLine.Amount := IssuedReminderLine.Amount;
        TempSalesLine."Amount Including VAT" := IssuedReminderLine.Amount + IssuedReminderLine."VAT Amount";
        TempSalesLine."VAT Bus. Posting Group" := IssuedReminderHeader."VAT Bus. Posting Group";
        TempSalesLine."VAT Prod. Posting Group" := IssuedReminderLine."VAT Prod. Posting Group";
        TempSalesLine."VAT %" := IssuedReminderLine."VAT %";
        TempSalesLine."VAT Calculation Type" := IssuedReminderLine."VAT Calculation Type";
        TempSalesLine."Tax Group Code" := IssuedReminderLine."Tax Group Code";
        TempSalesLine."Outstanding Amount" := IssuedReminderLine."Remaining Amount";
        if PEPPOL30.IsRoundingLine(TempSalesLine, IssuedReminderHeader."Customer No.") then
            PEPPOL30.GetInvoiceRoundingLine(TempSalesLineInvRounding, TempSalesLine)
        else
            TempSalesLine.Insert();
    end;

    local procedure GetSalesDocCurrencyCode(SalesHeader: Record "Sales Header"): Code[10]
    var
        GLSetup: Record "General Ledger Setup";
    begin
        if SalesHeader."Currency Code" = '' then begin
            GLSetup.Get();
            GLSetup.TestField("LCY Code");
            exit(GLSetup."LCY Code");
        end;
        exit(SalesHeader."Currency Code");
    end;
}
