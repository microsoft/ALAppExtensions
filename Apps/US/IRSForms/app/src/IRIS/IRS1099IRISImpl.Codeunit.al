// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Utilities;

codeunit 10045 "IRS 1099 IRIS Impl." implements "IRS 1099 IRIS Transmission", "IRS 1099 IRIS Xml"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        DataCheckIRIS: Codeunit "Data Check IRIS";
        ProcessTransmission: Codeunit "Process Transmission IRIS";
        GenerateXmlFileIRIS: Codeunit "Generate Xml File IRIS";
        ShowIRS1099FormDocumentsTxt: Label 'Show IRS 1099 Form Documents';
        NoDocumentToReportErr: Label 'There are no 1099 forms to report for the period %1. Make sure that IRS 1099 form documents for the given period are released and have lines to report.', Comment = '%1 - period year, e.g. 2024';

    procedure CreateTransmission(var Transmission: Record "Transmission IRIS"; PeriodNo: Text[4])
    var
        DocsCount: Integer;
        ErrorInfo: ErrorInfo;
    begin
        Transmission.InitTransmissionRecord();
        Transmission."Period No." := PeriodNo;
        Transmission.Insert();

        // collect all released forms for the period
        DocsCount := ProcessTransmission.AddReleasedFormDocsToTransmission(Transmission);

        if DocsCount = 0 then begin
            ErrorInfo.Message := StrSubstNo(NoDocumentToReportErr, PeriodNo);
            ErrorInfo.AddAction(ShowIRS1099FormDocumentsTxt, Codeunit::"Helper IRIS", 'ShowIRS1099FormDocuments');
            Error(ErrorInfo);
        end
    end;

    procedure CheckDataToReport(var Transmission: Record "Transmission IRIS")
    begin
        DataCheckIRIS.CheckDataToReport(Transmission);
    end;

    procedure CheckOriginalTransmission(var Transmission: Record "Transmission IRIS")
    begin
        ProcessTransmission.CheckOriginal(Transmission);
    end;

    procedure CheckReplacementTransmission(var Transmission: Record "Transmission IRIS")
    begin
        ProcessTransmission.CheckReplacement(Transmission);
    end;

    procedure CheckCorrectionTransmission(var Transmission: Record "Transmission IRIS")
    begin
        ProcessTransmission.CheckCorrection(Transmission);
    end;

    procedure CreateTransmissionXmlContent(var Transmission: Record "Transmission IRIS"; TransmissionType: Enum "Transmission Type IRIS"; CorrectionToZeroMode: Boolean; var UniqueTransmissionId: Text[100]; var TempIRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header" temporary; var TempBlob: Codeunit "Temp Blob")
    begin
        GenerateXmlFileIRIS.SetCorrectionToZeroMode(CorrectionToZeroMode);
        GenerateXmlFileIRIS.CreateTransmission(Transmission, TransmissionType, UniqueTransmissionId, TempIRS1099FormDocHeader, TempBlob);
    end;

    procedure CreateGetStatusRequestXmlContent(SearchParamType: Enum "Search Param Type IRIS"; SearchId: Text; var TempBlob: Codeunit "Temp Blob")
    begin
        GenerateXmlFileIRIS.CreateGetStatusRequest(SearchParamType, SearchId, TempBlob);
    end;

    procedure CreateAcknowledgmentRequestXmlContent(SearchParamType: Enum "Search Param Type IRIS"; SearchId: Text; var TempBlob: Codeunit "Temp Blob")
    begin
        GenerateXmlFileIRIS.CreateAcknowledgementRequest(SearchParamType, SearchId, TempBlob);
    end;
}