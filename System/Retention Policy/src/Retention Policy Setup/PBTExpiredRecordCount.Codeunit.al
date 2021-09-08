// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// A page background task can call this codeunit to calculate the number of expired records for a retention policy.
///
/// The PageBackgroundParameters dictionary must contain a key called SystemId, and the value of the key must be the SystemId of the Retention Policy Setup record for which to count expired records.
/// The result is returned in the BackgroundTaskResult dictionary where the key is the SystemId value of the Retention Policy Setup record and the value is the number of expired records..
/// </summary>
codeunit 3911 "PBT Expired Record Count"
{
    Access = Internal;

    trigger OnRun()
    var
        RetentionPolicySetup: Record "Retention Policy Setup";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
        PageBackgroundParameters: Dictionary of [Text, Text];
        BackgroundTaskResult: Dictionary of [Text, Text];
        RetentionPolicySetupSystemId: Guid;
        ExpiredRecordCount: Integer;
    begin
        PageBackgroundParameters := Page.GetBackgroundParameters();
        if not Evaluate(RetentionPolicySetupSystemId, PageBackgroundParameters.Get(RetentionPolicySetup.FieldName(SystemId))) then
            exit;

        if not RetentionPolicySetup.GetBySystemId(RetentionPolicySetupSystemId) then
            exit;

        ExpiredRecordCount := ApplyRetentionPolicy.GetExpiredRecordCount(RetentionPolicySetup);

        BackgroundTaskResult.Add(Format(RetentionPolicySetupSystemId), format(ExpiredRecordCount));
        Page.SetBackgroundTaskResult(BackgroundTaskResult);
    end;
}