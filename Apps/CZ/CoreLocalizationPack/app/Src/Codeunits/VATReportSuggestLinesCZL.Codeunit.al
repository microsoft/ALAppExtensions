// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

codeunit 31168 "VAT Report Suggest Lines CZL"
{
    TableNo = "VAT Report Header";

    trigger OnRun()
    begin
        Report.RunModal(Report::"VAT Report Request Page CZL", true, false, Rec);
    end;
}