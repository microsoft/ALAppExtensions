// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.FixedAsset;

using Microsoft.DemoTool.Helpers;
using Microsoft.Foundation.NoSeries;

codeunit 11717 "Create No. Series CZF"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoNoSeries: Codeunit "Contoso No Series";
    begin
        ContosoNoSeries.InsertNoSeries(FAHIS(), FAHistoryEntriesLbl, 'DH2500001', 'DH2599999', '', '', 1, Enum::"No. Series Implementation"::Normal, false);
    end;

    procedure FAHIS(): Code[20]
    begin
        exit(FAHISTok);
    end;

    var
        FAHISTok: Label 'FA-HIST', MaxLength = 20, Comment = 'Fixed Asset History';
        FAHistoryEntriesLbl: Label 'FA - History Entries', MaxLength = 100;
}
