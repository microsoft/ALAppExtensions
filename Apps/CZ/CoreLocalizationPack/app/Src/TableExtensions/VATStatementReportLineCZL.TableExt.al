// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

tableextension 31061 "VAT Statement Report Line CZL" extends "VAT Statement Report Line"
{
    var
        VATReportHeader: Record "VAT Report Header";

    trigger OnAfterDelete()
    var
        VATStmtReportLineDataCZL: Record "VAT Stmt. Report Line Data CZL";
    begin
        VATStmtReportLineDataCZL.SetFilterTo(Rec);
        VATStmtReportLineDataCZL.DeleteAll();
    end;

    procedure CalcBase(): Decimal
    begin
        exit(CalcAmount("VAT Report Amount Type CZL"::Base));
    end;

    procedure CalcAmount(): Decimal
    begin
        exit(CalcAmount("VAT Report Amount Type CZL"::Amount));
    end;

    procedure CalcReducedAmount(): Decimal
    begin
        exit(CalcAmount("VAT Report Amount Type CZL"::"Reduced Amount"));
    end;

    procedure CalcBaseAdditionalCurrency(): Decimal
    begin
        exit(CalcAmountAdditionalCurrency("VAT Report Amount Type CZL"::Base));
    end;

    procedure CalcAmountAdditionalCurrency(): Decimal
    begin
        exit(CalcAmountAdditionalCurrency("VAT Report Amount Type CZL"::Amount));
    end;

    procedure CalcReducedAmountAdditionalCurrency(): Decimal
    begin
        exit(CalcAmountAdditionalCurrency("VAT Report Amount Type CZL"::"Reduced Amount"));
    end;

    local procedure CalcAmount(VATReportAmountTypeCZL: Enum "VAT Report Amount Type CZL"): Decimal
    var
        VATStmtReportLineDataCZL: Record "VAT Stmt. Report Line Data CZL";
    begin
        VATStmtReportLineDataCZL.SetFilterTo(Rec);
        VATStmtReportLineDataCZL.SetRange("VAT Report Amount Type", VATReportAmountTypeCZL);
        VATStmtReportLineDataCZL.CalcSums(Amount);
        exit(VATStmtReportLineDataCZL.Amount);
    end;

    local procedure CalcAmountAdditionalCurrency(VATReportAmountTypeCZL: Enum "VAT Report Amount Type CZL"): Decimal
    var
        VATStmtReportLineDataCZL: Record "VAT Stmt. Report Line Data CZL";
    begin
        VATStmtReportLineDataCZL.SetFilterTo(Rec);
        VATStmtReportLineDataCZL.SetRange("VAT Report Amount Type", VATReportAmountTypeCZL);
        VATStmtReportLineDataCZL.CalcSums("Additional-Currency Amount");
        exit(VATStmtReportLineDataCZL."Additional-Currency Amount");
    end;

    internal procedure DrillDown(VATReportAmountTypeCZL: Enum "VAT Report Amount Type CZL")
    var
        SummaryVATStatementLine: Record "VAT Statement Line";
    begin
        GetSummaryVATStatementLine(VATReportAmountTypeCZL, SummaryVATStatementLine);
        SummaryVATStatementLine.DrillDown(GetVATReportHeader().GetVATStmtCalcParameters());
    end;

    internal procedure GetSummaryVATStatementLine(VATReportAmountTypeCZL: Enum "VAT Report Amount Type CZL"; var SummaryVATStatementLine: Record "VAT Statement Line"): Boolean
    var
        VATStatementLine: Record "VAT Statement Line";
        VATStmtReportLineDataCZL: Record "VAT Stmt. Report Line Data CZL";
        RowTotaling: Text;
    begin
        VATStmtReportLineDataCZL.SetFilterTo(Rec);
        VATStmtReportLineDataCZL.SetRange("VAT Report Amount Type", VATReportAmountTypeCZL);
        if VATStmtReportLineDataCZL.FindSet() then
            repeat
                VATStatementLine := VATStmtReportLineDataCZL.GetVATStatementLine();
                if RowTotaling = '' then
                    RowTotaling := StrSubstNo('"%1"', VATStatementLine."Row No.")
                else
                    RowTotaling := RowTotaling + '+' + StrSubstNo('"%1"', VATStatementLine."Row No.");
            until VATStmtReportLineDataCZL.Next() = 0;

        SummaryVATStatementLine.Init();
        SummaryVATStatementLine."Statement Template Name" := VATStatementLine."Statement Template Name";
        SummaryVATStatementLine."Statement Name" := VATStatementLine."Statement Name";
        SummaryVATStatementLine."Row Totaling" := CopyStr(RowTotaling, 1, MaxStrLen(SummaryVATStatementLine."Row Totaling"));
        SummaryVATStatementLine.Type := SummaryVATStatementLine.Type::"Formula CZL";
        exit(RowTotaling <> '');
    end;

    local procedure GetVATReportHeader(): Record "VAT Report Header"
    begin
        if (VATReportHeader."VAT Report Config. Code" <> "VAT Report Config. Code") or
           (VATReportHeader."No." <> "VAT Report No.")
        then
            VATReportHeader.Get("VAT Report Config. Code", "VAT Report No.");
        exit(VATReportHeader);
    end;
}