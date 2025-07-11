// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

codeunit 5287 "Data Check SAF-T" implements DataCheckSAFT
{
    procedure CheckDataToExport(var AuditFileExportHeader: Record "Audit File Export Header") DataCheckStatus: enum "Audit Data Check status"
    begin
        DataCheckStatus := Enum::"Audit Data Check Status"::" ";
    end;

    procedure CheckAuditDocReadyToExport(var AuditFileExportHeader: Record "Audit File Export Header") DataCheckStatus: enum "Audit Data Check Status"
    begin
        DataCheckStatus := Enum::"Audit Data Check Status"::" ";
    end;
}
