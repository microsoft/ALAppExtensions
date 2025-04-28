// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Jobs;

using Microsoft.DemoTool.Helpers;
using Microsoft.Foundation.NoSeries;

codeunit 5195 "Create Job No Series"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoNoSeries: Codeunit "Contoso No Series";
    begin
        ContosoNoSeries.InsertNoSeries(Job(), JobNosDescTok, 'PR00010', 'PR99999', '', '', 10, Enum::"No. Series Implementation"::Sequence, true);
    end;

    var
        JobsNosTok: Label 'PROJECTS', MaxLength = 20;
        JobNosDescTok: Label 'Projects', MaxLength = 100;

    procedure Job(): Code[20]
    begin
        exit(JobsNosTok);
    end;
}
