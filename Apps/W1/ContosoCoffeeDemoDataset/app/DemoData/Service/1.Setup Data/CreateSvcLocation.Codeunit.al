// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Service;

using Microsoft.DemoData.Common;

codeunit 4778 "Create Svc Location"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        SvcDemoDataSetup: Record "Service Module Setup";
        CommonLocation: Codeunit "Create Common Location";
    begin
        SvcDemoDataSetup.Get();

        if SvcDemoDataSetup."Service Location" = '' then
            SvcDemoDataSetup.Validate("Service Location", CommonLocation.MainLocation());

        SvcDemoDataSetup.Modify();
    end;
}
