// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

codeunit 10054 "IRS Forms Facade"
{
    Access = Public;

    var
        IRSFormsOrchestrator: Codeunit "IRS Forms Orchestrator";

    procedure GetVendorFormBoxAmount(var TempVendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer" temporary; IRS1099CalcParameters: Record "IRS 1099 Calc. Params")
    begin
        IRSFormsOrchestrator.GetFormBoxCalcImplementation().GetVendorFormBoxAmount(TempVendFormBoxBuffer, IRS1099CalcParameters);
    end;

    procedure CreateFormDocs(var TempVendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer" temporary; IRS1099CalcParameters: Record "IRS 1099 Calc. Params");
    begin
        IRSFormsOrchestrator.GetCreateFormDocsImplementation().CreateFormDocs(TempVendFormBoxBuffer, IRS1099CalcParameters);
    end;

    procedure SaveContentForDocument(var IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header"; IRS1099PrintParams: Record "IRS 1099 Print Params"; ReplaceIfExists: Boolean)
    begin
        IRSFormsOrchestrator.GetPrintingImplementation().SaveContentForDocument(IRS1099FormDocHeader, IRS1099PrintParams, ReplaceIfExists);
    end;

    procedure PrintContent(IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header")
    begin
        IRSFormsOrchestrator.GetPrintingImplementation().PrintContent(IRS1099FormDocHeader);
    end;
}
