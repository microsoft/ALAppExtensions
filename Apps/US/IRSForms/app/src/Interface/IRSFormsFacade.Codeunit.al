// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Utilities;

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

    procedure CreateTransmission(var Transmission: Record "Transmission IRIS"; PeriodNo: Text[4])
    begin
        IRSFormsOrchestrator.GetIRISImplementation().CreateTransmission(Transmission, PeriodNo);
    end;

    procedure CheckOriginalTransmission(var Transmission: Record "Transmission IRIS")
    begin
        IRSFormsOrchestrator.GetIRISImplementation().CheckOriginalTransmission(Transmission);
    end;

    procedure CheckReplacementTransmission(var Transmission: Record "Transmission IRIS")
    begin
        IRSFormsOrchestrator.GetIRISImplementation().CheckReplacementTransmission(Transmission);
    end;

    procedure CheckCorrectionTransmission(var Transmission: Record "Transmission IRIS")
    begin
        IRSFormsOrchestrator.GetIRISImplementation().CheckCorrectionTransmission(Transmission);
    end;

    procedure CheckDataToReport(var Transmission: Record "Transmission IRIS")
    begin
        IRSFormsOrchestrator.GetIRISImplementation().CheckDataToReport(Transmission);
    end;

    procedure CreateTransmissionXmlContent(var Transmission: Record "Transmission IRIS"; TransmissionType: Enum "Transmission Type IRIS"; CorrectionToZeroMode: Boolean; var UniqueTransmissionId: Text[100]; var TempIRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header" temporary; var TempBlob: Codeunit "Temp Blob")
    begin
        IRSFormsOrchestrator.GetIRISXmlImplementation().CreateTransmissionXmlContent(Transmission, TransmissionType, CorrectionToZeroMode, UniqueTransmissionId, TempIRS1099FormDocHeader, TempBlob);
    end;

    procedure CreateGetStatusRequestXmlContent(SearchParamType: Enum "Search Param Type IRIS"; SearchId: Text; var TempBlob: Codeunit "Temp Blob")
    begin
        IRSFormsOrchestrator.GetIRISXmlImplementation().CreateGetStatusRequestXmlContent(SearchParamType, SearchId, TempBlob);
    end;

    procedure CreateAcknowledgmentRequestXmlContent(SearchParamType: Enum "Search Param Type IRIS"; SearchId: Text; var TempBlob: Codeunit "Temp Blob")
    begin
        IRSFormsOrchestrator.GetIRISXmlImplementation().CreateAcknowledgmentRequestXmlContent(SearchParamType, SearchId, TempBlob);
    end;
}
