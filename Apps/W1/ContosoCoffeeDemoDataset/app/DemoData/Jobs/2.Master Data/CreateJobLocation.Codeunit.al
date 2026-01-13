// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Jobs;

using Microsoft.DemoData.Common;

codeunit 5196 "Create Job Location"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        JobsModuleSetup: Record "Jobs Module Setup";
        CommonLocation: Codeunit "Create Common Location";
    begin
        JobsModuleSetup.Get();

        if JobsModuleSetup."Job Location" = '' then
            JobsModuleSetup.Validate("Job Location", CommonLocation.MainLocation());

        JobsModuleSetup.Modify(true);
    end;
}
