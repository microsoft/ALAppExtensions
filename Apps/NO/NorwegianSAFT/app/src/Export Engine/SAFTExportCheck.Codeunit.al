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
        SAFTMappingHelper: Codeunit "SAF-T Mapping Helper";
        SAFTExportMgt: Codeunit "SAF-T Export Mgt.";
        ErrorMessageManagement: Codeunit "Error Message Management";
    begin
        TestField("Mapping Range Code");
        TestField("Starting Date");
        TestField("Ending Date");
        SAFTMappingHelper.VerifyMappingIsDone("Mapping Range Code");
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
        FieldValueIsNotSpecifiedErr: Label '%1 is not specified';

}
