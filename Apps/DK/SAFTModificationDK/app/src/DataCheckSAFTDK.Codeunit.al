// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Foundation.Company;
using System.Utilities;

codeunit 13697 "Data Check SAF-T DK" implements DataCheckSAFT
{
    Access = Internal;

    var
        FieldValueIsNotSpecifiedErr: label '%1 is not specified', Comment = '%1 - missed field caption';

    procedure CheckDataToExport(var AuditFileExportHeader: Record "Audit File Export Header") DataCheckStatus: enum "Audit Data Check status"
    begin
        DataCheckStatus := Enum::"Audit Data Check Status"::" ";
    end;

    procedure CheckAuditDocReadyToExport(var AuditFileExportHeader: Record "Audit File Export Header") DataCheckStatus: enum "Audit Data Check Status"
    var
        CompanyInformation: Record "Company Information";
        AuditFileExportSetup: Record "Audit File Export Setup";
        ErrorMessageManagement: Codeunit "Error Message Management";
        RecId: RecordId;
    begin
        CompanyInformation.Get();
        if CompanyInformation."Registration No." = '' then
            ErrorMessageManagement.LogErrorMessage(
                0, StrSubstNo(FieldValueIsNotSpecifiedErr, CompanyInformation.FieldCaption("Registration No.")),
                CompanyInformation, CompanyInformation.FieldNo("Registration No."), '');

        if AuditFileExportSetup.Get() then begin
            RecId := AuditFileExportSetup.RecordId;
            if AuditFileExportSetup."Default Payment Method Code" = '' then
                ErrorMessageManagement.LogErrorMessage(
                    0, StrSubstNo(FieldValueIsNotSpecifiedErr, AuditFileExportSetup.FieldCaption("Default Payment Method Code")),
                    AuditFileExportSetup, AuditFileExportSetup.FieldNo("Default Payment Method Code"), '');

            if AuditFileExportSetup."Default Post Code" = '' then
                ErrorMessageManagement.LogErrorMessage(
                    0, StrSubstNo(FieldValueIsNotSpecifiedErr, AuditFileExportSetup.FieldCaption("Default Post Code")),
                    AuditFileExportSetup, AuditFileExportSetup.FieldNo("Default Post Code"), '');
        end;

        if (ErrorMessageManagement.GetLastErrorID() <> 0) then
            exit(Enum::"Audit Data Check Status"::Failed);

        DataCheckStatus := Enum::"Audit Data Check Status"::Passed;
    end;
}
