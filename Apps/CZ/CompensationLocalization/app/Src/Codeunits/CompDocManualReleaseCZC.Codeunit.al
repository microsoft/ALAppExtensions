// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Compensations;

codeunit 31457 "Comp. Doc. Manual Release CZC"
{
    TableNo = "Compensation Header CZC";

    trigger OnRun()
    var
        ReleaseCompensDocumentCZC: Codeunit "Release Compens. Document CZC";
    begin
        ReleaseCompensDocumentCZC.PerformManualRelease(Rec);
    end;
}
