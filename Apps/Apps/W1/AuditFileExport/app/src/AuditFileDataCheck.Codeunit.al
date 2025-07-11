// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

codeunit 5267 "Audit File Data Check" implements "Audit File Export Data Check"
{
    Access = Internal;

    procedure CheckDataToExport(var AuditFileExportHeader: Record "Audit File Export Header") DataCheckStatus: enum "Audit Data Check Status"
    begin
    end;

    procedure CheckAuditDocReadyToExport(var AuditFileExportHeader: Record "Audit File Export Header") DataCheckStatus: enum "Audit Data Check Status"
    begin
    end;
}
