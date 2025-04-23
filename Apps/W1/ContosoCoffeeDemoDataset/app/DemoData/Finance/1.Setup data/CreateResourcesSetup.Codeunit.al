// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoData.Foundation;
using Microsoft.DemoTool.Helpers;

codeunit 5574 "Create Resources Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateNoSeries: Codeunit "Create No. Series";
        ContosoProjects: Codeunit "Contoso Projects";
    begin
        ContosoProjects.InsertResourcesSetup(CreateNoSeries.Resource(), CreateNoSeries.TimeSheet());
    end;
}
