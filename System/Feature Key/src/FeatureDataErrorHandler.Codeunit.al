// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Error handler codeunit used by the task scheduler during feature data update.
/// </summary>
codeunit 2613 "Feature Data Error Handler"
{
    TableNo = "Feature Data Update Status";

    trigger OnRun()
    var
        FeatureManagementImpl: Codeunit "Feature Management Impl.";
    begin
        FeatureManagementImpl.HandleUpdateError(Rec);
        OnLogError(Rec);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnLogError(FeatureDataUpdateStatus: Record "Feature Data Update Status")
    begin
    end;
}