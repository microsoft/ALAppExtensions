// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

codeunit 31461 "P.Adv.Let.Doc.Man.Release CZZ"
{
    TableNo = "Purch. Adv. Letter Header CZZ";

    trigger OnRun()
    var
        RelPurchAdvLetterDocCZZ: Codeunit "Rel. Purch.Adv.Letter Doc. CZZ";
    begin
        RelPurchAdvLetterDocCZZ.PerformManualRelease(Rec);
    end;
}
