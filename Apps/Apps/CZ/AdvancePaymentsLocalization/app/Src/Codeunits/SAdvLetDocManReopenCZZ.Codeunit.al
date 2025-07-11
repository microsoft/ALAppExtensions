// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

codeunit 31460 "S.Adv.Let.Doc.Man.Reopen CZZ"
{
    TableNo = "Sales Adv. Letter Header CZZ";

    trigger OnRun()
    var
        RelSalesAdvLetterDocCZZ: Codeunit "Rel. Sales Adv.Letter Doc. CZZ";
    begin
        RelSalesAdvLetterDocCZZ.PerformManualReopen(Rec);
    end;
}
