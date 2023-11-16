// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

codeunit 31451 "Cash Document Manual Reopen"
{
    TableNo = "Cash Document Header CZP";

    trigger OnRun()
    var
        CashDocumentReleasesCZP: Codeunit "Cash Document-Release CZP";
    begin
        CashDocumentReleasesCZP.PerformManualReopen(Rec);
    end;
}
