// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Codeunit that is executed by the task scheduler during the feature data update.
/// </summary>
codeunit 2612 "Update Feature Data"
{
    TableNo = "Feature Data Update Status";

    trigger OnRun()
    var
        FeatureManagementFacade: Codeunit "Feature Management Facade";
    begin
        FeatureManagementFacade.UpdateData(Rec);
    end;
}