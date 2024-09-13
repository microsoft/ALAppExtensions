// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Sales;

using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxBase;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Inventory.Location;
using Microsoft.Sales.Customer;
using Microsoft.Sales.FinanceCharge;
using Microsoft.Sales.Setup;

codeunit 18148 "GST Fin Charge Memo Validation"
{
    var
        CurrencyRounding: Record Currency;
        GSTPaymentDutyErr: Label 'You can only select GST without payment Of Duty in Export or Deemed Export Customer.';
        ShiptoGSTARNErr: Label 'Either GST Registration No. or ARN No. should have a value in Ship To Code.';
        GSTGroupReverseChargeErr: Label 'GST Group Code %1 with Reverse Charge cannot be selected for Finance Charge Memo transactions.', Comment = '%1 = GST Group Code';
        GSTGroupServiceTypeErr: Label 'GST Group Code %1 with Goods Type cannot be selected for Finance Charge Memo transactions.', Comment = '%1 = GST Group Code';
        InvoiceTypeErr: Label 'You can not select the Invoice Type %1 for GST Customer Type %2.', Comment = '%1 = Invoice Type ; %2 = GST Customer Type';

    procedure CallTaxEngineOnFinanceChargeMemoHeader(FinanceChargeMemoHeader: Record "Finance Charge Memo Header")
    var
        FinanceChargeMemoLine: Record "Finance Charge Memo Line";
        CalculateTax: Codeunit "Calculate Tax";
    begin
        FinanceChargeMemoLine.SetRange(FinanceChargeMemoLine."Finance Charge Memo No.", FinanceChargeMemoHeader."No.");
        if FinanceChargeMemoLine.FindSet() then
            repeat
                CalculateTax.CallTaxEngineOnFinanceChargeMemoLine(FinanceChargeMemoLine, FinanceChargeMemoLine);
            until FinanceChargeMemoLine.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Finance Charge Memo Header", 'OnAfterFinanceChargeRounding', '', false, false)]
    local procedure UpdateGSTRoundingAmount(var FinanceChargeMemoHeader: Record "Finance Charge Memo Header")
    var
        FinanceChargeMemoLine: Record "Finance Charge Memo Line";
        GSTAmount: Decimal;
    begin
        FinanceChargeMemoLine.Reset();
        FinanceChargeMemoLine.SetRange("Finance Charge Memo No.", FinanceChargeMemoHeader."No.");
        if FinanceChargeMemoLine.FindSet() then
            repeat
                GSTAmount += GetGSTAmount(FinanceChargeMemoLine.RecordId());
            until FinanceChargeMemoLine.Next() = 0;

        GetCurrency(FinanceChargeMemoHeader);
        FinanceChargeRounding(GSTAmount, FinanceChargeMemoHeader);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Finance Charge Memo Header", 'OnAfterValidateEvent', 'Location GST Reg. No.', false, false)]
    local procedure ValidateLocationGSTRegNo(var Rec: Record "Finance Charge Memo Header")
    var
        GSTRegistrationNos: Record "GST Registration Nos.";
    begin
        if GSTRegistrationNos.Get(Rec."Location GST Reg. No.") then
            Rec."Location State Code" := GSTRegistrationNos."State Code"
        else
            Rec."Location State Code" := '';
    end;

    [EventSubscriber(ObjectType::Table, Database::"Finance Charge Memo Header", 'OnAfterValidateEvent', 'Customer No.', false, false)]
    local procedure ValidateCustomerNo(var Rec: Record "Finance Charge Memo Header"; var xRec: Record "Finance Charge Memo Header")
    begin
        UpdateCustomerDetails(Rec, xRec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Tax Transaction Value", 'OnBeforeTableFilterApplied', '', false, false)]
    local procedure OnBeforeTableFilterApplied(TableIDFilter: Integer; DocumentNoFilter: Text; LineNoFilter: Integer; var TaxRecordID: RecordID)
    begin
        if TableIDFilter = Database::"Finance Charge Memo Line" then
            GetTaxRecIDForFinChargeDocument(DocumentNoFilter, LineNoFilter, TaxRecordID);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Tax Transaction Value", 'OnBeforeTableFilterApplied', '', false, false)]
    local procedure OnBeforeTableFilterAppliedIssued(TableIDFilter: Integer; DocumentNoFilter: Text; LineNoFilter: Integer; var TaxRecordID: RecordID)
    begin
        if TableIDFilter = Database::"Issued Fin. Charge Memo Line" then
            GetTaxRecIDForIssuedFinChargeDocument(DocumentNoFilter, LineNoFilter, TaxRecordID);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Finance Charge Memo Header", 'OnAfterValidateEvent', 'GST Without Payment of Duty', false, false)]
    local procedure ValidateGSTWithoutPaymentofDuty(var Rec: Record "Finance Charge Memo Header")
    begin
        if not (Rec."GST Customer Type" in [Rec."GST Customer Type"::Export,
                                            Rec."GST Customer Type"::"Deemed Export",
                                            Rec."GST Customer Type"::"SEZ Development",
                                            Rec."GST Customer Type"::"SEZ Unit"]) then
            Error(GSTPaymentDutyErr);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FinChrgMemo-Issue", 'OnBeforeGenJnlPostLineRunWithCheck', '', false, false)]
    local procedure OnBeforeGenJnlPostLineRunWithCheck(var GenJournalLine: Record "Gen. Journal Line"; FinanceChargeMemoHeader: Record "Finance Charge Memo Header")
    var
        FinanceChargeMemoLine: Record "Finance Charge Memo Line";
    begin
        GenJournalLine."Location Code" := FinanceChargeMemoHeader."Location Code";
        GenJournalLine."Location State Code" := FinanceChargeMemoHeader."Location State Code";
        GenJournalLine."Location GST Reg. No." := FinanceChargeMemoHeader."Location GST Reg. No.";
        GenJournalLine."Customer GST Reg. No." := FinanceChargeMemoHeader."Customer GST Reg. No.";
        GenJournalLine."GST Bill-to/BuyFrom State Code" := FinanceChargeMemoHeader."GST Bill-to State Code";
        GenJournalLine."GST Ship-to State Code" := FinanceChargeMemoHeader."GST Ship-to State Code";
        GenJournalLine."Ship-to GST Reg. No." := FinanceChargeMemoHeader."Ship-to GST Reg. No.";

        FinanceChargeMemoLine.SetRange(FinanceChargeMemoLine."Finance Charge Memo No.", FinanceChargeMemoHeader."No.");
        if FinanceChargeMemoLine.FindFirst() then begin
            GenJournalLine."GST Jurisdiction Type" := FinanceChargeMemoLine."GST Jurisdiction Type";
            GenJournalLine."GST Place of Supply" := FinanceChargeMemoLine."GST Place of Supply";
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Finance Charge Memo Header", 'OnAfterValidateEvent', 'Ship-to Code', false, false)]
    local procedure ValidateShipToCode(var Rec: Record "Finance Charge Memo Header"; var xRec: Record "Finance Charge Memo Header")
    var
        Customer: Record Customer;
        ShipToAddress: Record "Ship-to Address";
        FinanceChargeMemoLine: Record "Finance Charge Memo Line";
    begin
        Rec."GST Ship-to State Code" := '';
        Rec."Ship-to GST Reg. No." := '';

        if Rec."Ship-to Code" <> '' then begin
            if xRec."Ship-to Code" <> '' then begin
                Customer.Get(Rec."Customer No.");
                if Customer."Location Code" <> '' then
                    Rec.Validate(Rec."Location Code", Customer."Location Code");
            end;

            ShipToAddress.Get(Rec."Customer No.", Rec."Ship-to Code");
            if ShipToAddress."Location Code" <> '' then
                Rec.Validate(Rec."Location Code", ShipToAddress."Location Code");

            if Rec."GST Customer Type" <> Rec."GST Customer Type"::" " then
                if Rec."GST Customer Type" in ["GST Customer Type"::Exempted,
                                  "GST Customer Type"::"Deemed Export",
                                  "GST Customer Type"::"SEZ Development",
                                  "GST Customer Type"::"SEZ Unit",
                                  "GST Customer Type"::Registered] then begin
                    ShipToAddress.TestField(State);
                    if ShipToAddress."GST Registration No." = '' then
                        if ShipToAddress."ARN No." = '' then
                            Error(ShiptoGSTARNErr);
                    Rec."GST Ship-to State Code" := ShipToAddress.State;
                    Rec."Ship-to GST Reg. No." := ShipToAddress."GST Registration No.";
                end;
        end else begin
            FinanceChargeMemoLine.SetRange("Finance Charge Memo No.", Rec."No.");
            FinanceChargeMemoLine.SetRange(FinanceChargeMemoLine."GST Place of Supply", FinanceChargeMemoLine."GST Place of Supply"::"Ship-to Address");
            if not FinanceChargeMemoLine.IsEmpty then
                Rec.TestField(Rec."Ship-to Code");
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Finance Charge Memo Header", 'OnAfterValidateEvent', 'Location Code', false, false)]
    local procedure ValidateLocationCode(var Rec: Record "Finance Charge Memo Header")
    var
        Location: Record Location;
    begin
        if Rec."Location Code" = '' then begin
            Rec."Location GST Reg. No." := '';
            Rec."Location State Code" := '';
            Rec."Ship-to Code" := '';
        end else begin
            Location.Get(Rec."Location Code");
            Rec."Location GST Reg. No." := Location."GST Registration No.";
            Rec."Location State Code" := Location."State Code";
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Finance Charge Memo Header", 'OnAfterValidateEvent', 'Invoice Type', false, false)]
    local procedure ValidateInvoiceType(var Rec: Record "Finance Charge Memo Header")
    var
        FinanceChargeMemoLine: Record "Finance Charge Memo Line";
    begin
        if Rec."GST Customer Type" <> Rec."GST Customer Type"::Exempted then
            if CheckAllLinesExemptedFinChargeMemo(Rec) then
                CheckInvoiceTypeFinChargeMemo(Rec)
            else begin
                FinanceChargeMemoLine.Reset();
                FinanceChargeMemoLine.SetRange("Finance Charge Memo No.", Rec."No.");
                if not FinanceChargeMemoLine.IsEmpty then
                    Rec.TestField(Rec."Invoice Type", Rec."Invoice Type"::"Bill of Supply")
            end
        else
            CheckInvoiceTypeFinChargeMemo(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Finance Charge Memo Header", 'OnAfterValidateEvent', 'GST Customer Type', false, false)]
    local procedure ValidateGSTCustomerType(var Rec: Record "Finance Charge Memo Header")
    begin
        UpdateInvoiceTypeFinChargeMemo(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Finance Charge Memo Line", 'OnAfterValidateEvent', 'GST Group Code', false, false)]
    local procedure ValidateGSTGroupCode(var Rec: Record "Finance Charge Memo Line")
    begin
        CheckGSTGroupCodeValidation(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Finance Charge Memo Line", 'OnAfterValidateEvent', 'Non-GST Line', false, false)]
    local procedure ValidateNonGSTLine(var Rec: Record "Finance Charge Memo Line")
    begin
        if Rec."Non-GST Line" then begin
            Rec."GST Group Code" := '';
            Rec."HSN/SAC Code" := '';
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Finance Charge Memo Line", 'OnAfterValidateEvent', 'GST Place of Supply', false, false)]
    local procedure ValidateGSTPlaceofSupply(var Rec: Record "Finance Charge Memo Line")
    begin
        ValidateGSTPlaceOfSupplyFinCharge(Rec);
    end;

    local procedure FinanceChargeRounding(GSTAmount: Decimal; var FinanceChargeHeader: Record "Finance Charge Memo Header")
    var
        FinanceChargeMemoLine: Record "Finance Charge Memo Line";
        GSTRoundAmountDiff: Decimal;
    begin
        GSTRoundAmountDiff := -Round(
            GSTAmount -
            Round(
              GSTAmount, CurrencyRounding."Invoice Rounding Precision", CurrencyRounding.InvoiceRoundingDirection()),
            CurrencyRounding."Amount Rounding Precision");

        FinanceChargeMemoLine.Reset();
        FinanceChargeMemoLine.SetRange("Finance Charge Memo No.", FinanceChargeHeader."No.");
        FinanceChargeMemoLine.SetRange("Line Type", FinanceChargeMemoLine."Line Type"::Rounding);
        if FinanceChargeMemoLine.FindFirst() then begin
            FinanceChargeMemoLine.Validate(Amount, FinanceChargeMemoLine.Amount + GSTRoundAmountDiff);
            FinanceChargeMemoLine.Modify();
        end
    end;

    local procedure GetCurrency(FinanceChargeHeader: Record "Finance Charge Memo Header")
    begin
        if FinanceChargeHeader."Currency Code" = '' then
            CurrencyRounding.InitRoundingPrecision()
        else begin
            CurrencyRounding.Get(FinanceChargeHeader."Currency Code");
            CurrencyRounding.TestField("Amount Rounding Precision");
        end;
    end;

    local procedure GetTaxRecIDForFinChargeDocument(DocumentNoFilter: Text; LineNoFilter: Integer; var TaxRecordID: RecordID)
    var
        FinanceChargeMemoLine: Record "Finance Charge Memo Line";
    begin
        if FinanceChargeMemoLine.Get(DocumentNoFilter, LineNoFilter) then
            TaxRecordID := FinanceChargeMemoLine.RecordId();
    end;

    local procedure GetTaxRecIDForIssuedFinChargeDocument(DocumentNoFilter: Text; LineNoFilter: Integer; var TaxRecordID: RecordID)
    var
        IssuedFinChargeMemoLine: Record "Issued Fin. Charge Memo Line";
    begin
        if IssuedFinChargeMemoLine.Get(DocumentNoFilter, LineNoFilter) then
            TaxRecordID := IssuedFinChargeMemoLine.RecordId();
    end;

    local procedure GetGSTAmount(RecID: RecordID): Decimal
    var
        GSTSetup: Record "GST Setup";
        TaxTransactionValue: Record "Tax Transaction Value";
    begin
        if not GSTSetup.Get() then
            exit;

        TaxTransactionValue.SetCurrentKey("Tax Record ID", "Tax Type");
        TaxTransactionValue.SetRange("Tax Record ID", RecID);
        TaxTransactionValue.SetRange("Value Type", TaxTransactionValue."Value Type"::COMPONENT);
        TaxTransactionValue.SetRange("Tax Type", GSTSetup."GST Tax Type");
        TaxTransactionValue.SetFilter(Percent, '<>%1', 0);
        if not TaxTransactionValue.IsEmpty() then
            TaxTransactionValue.CalcSums(Amount);

        exit(TaxTransactionValue.Amount);
    end;

    local procedure CheckInvoiceTypeFinChargeMemo(FinanceChargeMemoHeader: Record "Finance Charge Memo Header")
    begin
        case FinanceChargeMemoHeader."GST Customer Type" of
            "GST Customer Type"::" ",
            "GST Customer Type"::Registered,
            "GST Customer Type"::Unregistered:
                if FinanceChargeMemoHeader."Invoice Type" in [FinanceChargeMemoHeader."Invoice Type"::"Bill of Supply", FinanceChargeMemoHeader."Invoice Type"::Export] then
                    Error(InvoiceTypeErr, FinanceChargeMemoHeader."Invoice Type", FinanceChargeMemoHeader."GST Customer Type");
            "GST Customer Type"::Export,
            "GST Customer Type"::"Deemed Export",
            "GST Customer Type"::"SEZ Development",
            "GST Customer Type"::"SEZ Unit":
                if FinanceChargeMemoHeader."Invoice Type" in [FinanceChargeMemoHeader."Invoice Type"::"Bill of Supply", FinanceChargeMemoHeader."Invoice Type"::Taxable] then
                    Error(InvoiceTypeErr, FinanceChargeMemoHeader."Invoice Type", FinanceChargeMemoHeader."GST Customer Type");
            "GST Customer Type"::Exempted:
                if FinanceChargeMemoHeader."Invoice Type" in [FinanceChargeMemoHeader."Invoice Type"::"Debit Note", FinanceChargeMemoHeader."Invoice Type"::Export, FinanceChargeMemoHeader."Invoice Type"::Taxable] then
                    Error(InvoiceTypeErr, FinanceChargeMemoHeader."Invoice Type", FinanceChargeMemoHeader."GST Customer Type");
        end;
    end;

    local procedure UpdateInvoiceTypeFinChargeMemo(var FinanceChargeMemoHeader: Record "Finance Charge Memo Header")
    begin
        case FinanceChargeMemoHeader."GST Customer Type" of
            "GST Customer Type"::" ",
            "GST Customer Type"::Registered,
            "GST Customer Type"::Unregistered:
                FinanceChargeMemoHeader."Invoice Type" := FinanceChargeMemoHeader."Invoice Type"::Taxable;
            "GST Customer Type"::Export,
            "GST Customer Type"::"Deemed Export",
            "GST Customer Type"::"SEZ Development",
            "GST Customer Type"::"SEZ Unit":
                FinanceChargeMemoHeader.Validate(FinanceChargeMemoHeader."Invoice Type", FinanceChargeMemoHeader."Invoice Type"::Export);
            "GST Customer Type"::Exempted:
                FinanceChargeMemoHeader."Invoice Type" := FinanceChargeMemoHeader."Invoice Type"::"Bill of Supply";
        end;
    end;

    local procedure CheckGSTGroupCodeValidation(var FinanceChargeMemoLine: Record "Finance Charge Memo Line")
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        Customer: Record Customer;
        FinanceChargeMemoHeader: Record "Finance Charge Memo Header";
        GSTGroup: Record "GST Group";
    begin
        FinanceChargeMemoHeader.Get(FinanceChargeMemoLine."Finance Charge Memo No.");
        Customer.Get(FinanceChargeMemoHeader."Customer No.");

        FinanceChargeMemoLine.TestField("Non-GST Line", false);
        if FinanceChargeMemoLine.Type <> FinanceChargeMemoLine.Type::"Customer Ledger Entry" then
            FinanceChargeMemoLine.TestField(Type, FinanceChargeMemoLine.Type::"Customer Ledger Entry");
        if FinanceChargeMemoLine."Document Type" <> FinanceChargeMemoLine."Document Type"::Invoice then
            FinanceChargeMemoLine.TestField("Document Type", FinanceChargeMemoLine."Document Type"::Invoice);

        if GSTGroup.Get(FinanceChargeMemoLine."GST Group Code") then begin
            if GSTGroup."Reverse Charge" then
                Error(GSTGroupReverseChargeErr, FinanceChargeMemoLine."GST Group Code");
            if GSTGroup."GST Group Type" = GSTGroup."GST Group Type"::Goods then
                Error(GSTGroupServiceTypeErr, FinanceChargeMemoLine."GST Group Code");
            FinanceChargeMemoLine."GST Place of Supply" := GSTGroup."GST Place Of Supply";
            FinanceChargeMemoLine."GST Group Type" := GSTGroup."GST Group Type";
        end;

        if FinanceChargeMemoLine."GST Place of Supply" = FinanceChargeMemoLine."GST Place of Supply"::" " then begin
            SalesReceivablesSetup.Get();
            FinanceChargeMemoLine."GST Place of Supply" := SalesReceivablesSetup."GST Dependency Type";
        end;

        FinanceChargeMemoLine."HSN/SAC Code" := '';

        UpdateGSTJurisdictionType(FinanceChargeMemoLine, Customer."State Code");
    end;

    local procedure CheckAllLinesExemptedFinChargeMemo(FinanceChargeMemoHeader: Record "Finance Charge Memo Header"): Boolean
    var
        FinanceChargeMemoLine: Record "Finance Charge Memo Line";
    begin
        FinanceChargeMemoLine.SetRange("Finance Charge Memo No.", FinanceChargeMemoHeader."No.");
        FinanceChargeMemoLine.SetRange(Exempted, true);
        if not FinanceChargeMemoLine.IsEmpty then
            exit(false)
        else
            exit(true);
    end;

    local procedure UpdateCustomerDetails(var Rec: Record "Finance Charge Memo Header"; var xRec: Record "Finance Charge Memo Header")
    var
        Customer: Record Customer;
    begin
        Customer.Get(Rec."Customer No.");

        Rec."GST Customer Type" := Customer."GST Customer Type";
        Rec."GST Bill-to State Code" := '';
        Rec."Customer GST Reg. No." := '';
        if Rec."GST Customer Type" <> Rec."GST Customer Type"::" " then
            Customer.TestField(Customer.Address);

        if not (Rec."GST Customer Type" in [Rec."GST Customer Type"::Export, Rec."GST Customer Type"::"Deemed Export",
                                        Rec."GST Customer Type"::"SEZ Development", Rec."GST Customer Type"::"SEZ Unit"])
        then
            Rec."GST Bill-to State Code" := Customer."State Code";

        if not (Rec."GST Customer Type" in [Rec."GST Customer Type"::Export]) then
            Rec."Customer GST Reg. No." := Customer."GST Registration No.";
        if Rec."GST Customer Type" = Rec."GST Customer Type"::Unregistered then
            Rec."Nature of Supply" := Rec."Nature of Supply"::B2C;

        UpdateInvoiceTypeFinChargeMemo(Rec);

        if Rec."Invoice Type" = Rec."Invoice Type"::" " then
            Rec."Invoice Type" := Rec."Invoice Type"::Taxable;

        if (Rec."GST Customer Type" <> Rec."GST Customer Type"::" ") and (xRec."Customer No." <> Rec."Customer No.") then
            Rec.Validate(Rec."Invoice Type");
    end;

    local procedure ValidateGSTPlaceOfSupplyFinCharge(var FinanceChargeMemoLine: Record "Finance Charge Memo Line")
    var
        FinanceChargeMemoHeader: Record "Finance Charge Memo Header";
        Customer: Record Customer;
        ShipToAddress: Record "Ship-to Address";
        Currency: Record Currency;
    begin
        FinanceChargeMemoHeader.Get(FinanceChargeMemoLine."Finance Charge Memo No.");
        Customer.Get(FinanceChargeMemoHeader."Customer No.");
        FinanceChargeMemoHeader.TestField("Customer No.");
        FinanceChargeMemoHeader.TestField("Document Date");
        FinanceChargeMemoHeader.TestField("Customer Posting Group");
        FinanceChargeMemoHeader.TestField("Fin. Charge Terms Code");

        if FinanceChargeMemoHeader."Currency Code" = '' then
            Currency.InitRoundingPrecision()
        else begin
            Currency.Get(FinanceChargeMemoHeader."Currency Code");
            Currency.TestField("Amount Rounding Precision");
        end;

        FinanceChargeMemoHeader.TestField("Ship-to Code");
        if FinanceChargeMemoHeader."Ship-to GST Reg. No." = '' then
            if ShipToAddress.Get(FinanceChargeMemoHeader."Customer No.", FinanceChargeMemoHeader."Ship-to Code") then
                if not (FinanceChargeMemoHeader."GST Customer Type" in [FinanceChargeMemoHeader."GST Customer Type"::Unregistered, FinanceChargeMemoHeader."GST Customer Type"::Export]) then
                    if ShipToAddress."ARN No." = '' then
                        Error(ShipToGSTARNErr);

        UpdateGSTJurisdictionType(FinanceChargeMemoLine, Customer."State Code");
    end;

    local procedure UpdateGSTJurisdictionType(var FinanceChargeMemoLine: Record "Finance Charge Memo Line"; CustomerStateCode: Code[20])
    var
        FinanceChargeMemoHeader: Record "Finance Charge Memo Header";
    begin
        FinanceChargeMemoHeader.Get(FinanceChargeMemoLine."Finance Charge Memo No.");

        if FinanceChargeMemoHeader."Ship-to Code" <> '' then begin
            UpdateGSTJurisdictionShiptoAdddress(FinanceChargeMemoLine);
            exit;
        end;

        if (FinanceChargeMemoHeader."Invoice Type" = FinanceChargeMemoHeader."Invoice Type"::Export) then begin
            FinanceChargeMemoLine."GST Jurisdiction Type" := FinanceChargeMemoLine."GST Jurisdiction Type"::Interstate;
            exit;
        end;

        case true of
            FinanceChargeMemoHeader."Location State Code" <> CustomerStateCode:
                FinanceChargeMemoLine."GST Jurisdiction Type" := FinanceChargeMemoLine."GST Jurisdiction Type"::Interstate;
            FinanceChargeMemoHeader."Location State Code" = CustomerStateCode:
                FinanceChargeMemoLine."GST Jurisdiction Type" := FinanceChargeMemoLine."GST Jurisdiction Type"::Intrastate;
            (FinanceChargeMemoHeader."Location State Code" <> '') and (CustomerStateCode = ''):
                FinanceChargeMemoLine."GST Jurisdiction Type" := FinanceChargeMemoLine."GST Jurisdiction Type"::Interstate;
        end
    end;

    local procedure UpdateGSTJurisdictionShiptoAdddress(var FinanceChargeMemoLine: Record "Finance Charge Memo Line")
    var
        ShiptoAddress: Record "Ship-to Address";
        FinanceChargeMemoHeader: Record "Finance Charge Memo Header";
    begin
        if FinanceChargeMemoHeader.Get(FinanceChargeMemoLine."Document Type", FinanceChargeMemoLine."Document No.") then
            if ShiptoAddress.Get(FinanceChargeMemoHeader."Customer No.", FinanceChargeMemoHeader."Ship-to Code") then
                if FinanceChargeMemoHeader."Location State Code" <> ShiptoAddress."State" then
                    FinanceChargeMemoLine."GST Jurisdiction Type" := FinanceChargeMemoLine."GST Jurisdiction Type"::Interstate
                else
                    if FinanceChargeMemoHeader."Location State Code" = ShiptoAddress."State" then
                        FinanceChargeMemoLine."GST Jurisdiction Type" := FinanceChargeMemoLine."GST Jurisdiction Type"::Intrastate
    end;
}
