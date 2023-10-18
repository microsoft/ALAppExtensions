#if not CLEAN22
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Inventory.Intrastat;

codeunit 13694 "Intrastat Export Lines"
{
    ObsoleteState = Pending;
#pragma warning disable AS0072
    ObsoleteTag = '22.0';
#pragma warning restore AS0072
    ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';

    TableNo = "Intrastat Jnl. Line";
    trigger OnRun();
    var
        IntrastatJnlLine: Record "Intrastat Jnl. Line";
    begin
        IntrastatJnlLine.COPYFILTERS(Rec);
        IntrastatJnlLine.SETRANGE("Journal Template Name", Rec."Journal Template Name");
        IntrastatJnlLine.SETRANGE("Journal Batch Name", "Journal Batch Name");
        REPORT.RUN(REPORT::"Intrastat - Make Disk Tax Auth", TRUE, FALSE, IntrastatJnlLine);
    end;
}
#endif
