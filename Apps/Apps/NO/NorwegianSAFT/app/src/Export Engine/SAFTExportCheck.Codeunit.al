// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Foundation.Company;
using System.Utilities;

codeunit 10677 "SAF-T Export Check"
{
    TableNo = "SAF-T Export Header";

    trigger OnRun()
    var
        CompanyInformation: Record "Company Information";
        SAFTExportMgt: Codeunit "SAF-T Export Mgt.";
        ErrorMessageManagement: Codeunit "Error Message Management";
    begin
        TestField("Mapping Range Code");
        TestField("Starting Date");
        TestField("Ending Date");
        VerifyMapping(Rec);
        SAFTMappingHelper.VerifyDimensionsHaveAnalysisCode();
        SAFTMappingHelper.VerifyVATPostingSetupHasTaxCodes();
        SAFTMappingHelper.VerifySourceCodesHasSAFTCodes();
        SAFTExportMgt.CheckNoFilesInFolder(Rec);
        CompanyInformation.Get();
        If CompanyInformation."SAF-T Contact No." = '' then
            ErrorMessageManagement.LogErrorMessage(
                0, StrSubstNo(FieldValueIsNotSpecifiedErr, CompanyInformation.FieldCaption("SAF-T Contact No.")),
                CompanyInformation, CompanyInformation.FieldNo("SAF-T Contact No."), '');
    end;

    var
        SAFTMappingHelper: Codeunit "SAF-T Mapping Helper";
        FieldValueIsNotSpecifiedErr: Label '%1 is not specified';

    local procedure VerifyMapping(SAFTExportHeader: Record "SAF-T Export Header")
    var
        IsHandled: Boolean;
    begin
        OnBeforeVerifyMapping(SAFTExportHeader, IsHandled);
        if IsHandled then
            exit;
        case SAFTExportHeader.Version of
            SAFTExportHeader.Version::"1.20":
                SAFTMappingHelper.VerifyMappingIsDone(SAFTExportHeader."Mapping Range Code");
            SAFTExportHeader.Version::"1.30":
                SAFTMappingHelper.VerifyMapping13IsDone(SAFTExportHeader."Mapping Range Code");
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeVerifyMapping(SAFTExportHeader: Record "SAF-T Export Header"; var IsHandled: Boolean)
    begin
    end;

}
