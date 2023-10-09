#if not CLEAN22
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Inventory.Intrastat;

using Microsoft.Foundation.Reporting;

codeunit 13693 "Intrastat Validate Lines"
{
    TableNo = "Intrastat Jnl. Line";
    ObsoleteState = Pending;
#pragma warning disable AS0072
    ObsoleteTag = '22.0';
#pragma warning restore AS0072
    ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';

    trigger OnRun();
    var
        TestReportPrint: Codeunit "Test Report-Print";
    begin
        TestReportPrint.PrintIntrastatJnlLine(Rec);
    end;
}
#endif
