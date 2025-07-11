// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Compensations;

codeunit 31458 "Comp. Doc. Manual Reopen CZC"
{
    TableNo = "Compensation Header CZC";

    trigger OnRun()
    var
        ReleaseCompensDocument: Codeunit "Release Compens. Document CZC";
    begin
        ReleaseCompensDocument.PerformManualReopen(Rec);
    end;
}
