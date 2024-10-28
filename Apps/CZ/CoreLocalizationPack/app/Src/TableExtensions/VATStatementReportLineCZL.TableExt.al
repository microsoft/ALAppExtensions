// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

tableextension 31061 "VAT Statement Report Line CZL" extends "VAT Statement Report Line"
{
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

    local procedure CalcAmount(VATReportAmountTypeCZL: Enum "VAT Report Amount Type CZL"): Decimal
    var
        VATStmtReportLineDataCZL: Record "VAT Stmt. Report Line Data CZL";
    begin
        VATStmtReportLineDataCZL.SetFilterTo(Rec);
        VATStmtReportLineDataCZL.SetRange("VAT Report Amount Type", VATReportAmountTypeCZL);
        VATStmtReportLineDataCZL.CalcSums(Amount);
        exit(VATStmtReportLineDataCZL.Amount);
    end;
}