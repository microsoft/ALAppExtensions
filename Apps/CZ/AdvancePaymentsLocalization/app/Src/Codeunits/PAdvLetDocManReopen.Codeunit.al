// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

codeunit 31462 "P.Adv.Let.Doc.Man.Reopen CZZ"
{
    TableNo = "Purch. Adv. Letter Header CZZ";

    trigger OnRun()
    var
        RelPurchAdvLetterDocCZZ: Codeunit "Rel. Purch.Adv.Letter Doc. CZZ";
    begin
        RelPurchAdvLetterDocCZZ.PerformManualReopen(Rec);
    end;
}
