// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This codeunit provides functions to apply a retention policy.
/// </summary>
codeunit 3910 "Apply Retention Policy"
{
    Access = Public;

    /// <summary>
    /// Applies all enabled, non-manual retention polices. This will delete records according to the settings defined in the Retention Policy Setup table.
    /// </summary>
    trigger OnRun()
    begin
        Codeunit.Run(Codeunit::"Apply Retention Policy Impl.");
    end;

    /// <summary>
    /// Applies all enabled, non-manual retention polices. This will delete records according to the settings defined in the Retention Policy Setup table.
    /// </summary>
    /// <param name="UserInvokedRun">Use this value to indicate whether the user initiated the function call or an automated process did. This value is later passed in the event OnApplyRetentionPolicyRecordLimitExceeded.</param>
    procedure ApplyRetentionPolicy(UserInvokedRun: Boolean)
    var
        ApplyRetentionPolicyImpl: Codeunit "Apply Retention Policy Impl.";
    begin
        ApplyRetentionPolicyImpl.ApplyRetentionPolicy(UserInvokedRun);
    end;

    /// <summary>
    /// Applies the given Retention Policy. This will delete records according to the settings defined in the Retention Policy Setup table.
    /// </summary>
    /// <param name="RetentionPolicySetup">This is the setup record which defines the retention policy to apply.</param>
    /// <param name="UserInvokedRun">Use this value to indicate whether the user initiated the functioncall or an automated process did. This value is later passed in the event OnApplyRetentionPolicyRecordLimitExceeded.</param>
    procedure ApplyRetentionPolicy(RetentionPolicySetup: Record "Retention Policy Setup"; UserInvokedRun: Boolean)
    var
        ApplyRetentionPolicyImpl: Codeunit "Apply Retention Policy Impl.";
    begin
        ApplyRetentionPolicyImpl.ApplyRetentionPolicy(RetentionPolicySetup, RetentionPolicySetup.Manual, UserInvokedRun);
    end;

    /// <summary>
    /// Returns the number of expired records for the given Retention Policy Setup record. These records would be deleted if the Retention Policy was applied.
    /// </summary>
    /// <param name="RetentionPolicySetup">This is the setup record which defines the retention policy for which the expired records will be counted.</param>
    /// <returns>The number of records which are expired.</returns>
    procedure GetExpiredRecordCount(RetentionPolicySetup: Record "Retention Policy Setup"): Integer;
    var
        ApplyRetentionPolicyImpl: Codeunit "Apply Retention Policy Impl.";
    begin
        Exit(ApplyRetentionPolicyImpl.GetExpiredRecordCount(RetentionPolicySetup))
    end;

    /// <summary>
    /// This method places a filter on the record reference where records are older than the ExpirationDate. The filter excludes any record where the date field specified in DateFieldNo has no value.
    /// </summary>
    /// <param name="DateFieldNo">The date or datetime field the filter will be placed on.</param>
    /// <param name="ExpirationDate">The expiration date used in the filter.</param>
    /// <param name="RecordRef">The record reference on which the filter will be placed.</param>
    /// <param name="FilterGroup">The filtergroup in which the filter will be placed.</param>
    /// <param name="NullDateFilterGroup">The filtergroup in which the null date filter will be placed.</param>
    /// <param name="NullDateReplacementValue">The date to be used to determine whether a record has expired when the date or datetime value of the record is 0D.</param>
    procedure SetWhereOlderExpirationDateFilter(DateFieldNo: Integer; ExpirationDate: Date; var RecordRef: RecordRef; FilterGroup: Integer; NullDateReplacementValue: Date)
    var
        ApplyRetentionPolicyImpl: Codeunit "Apply Retention Policy Impl.";
    begin
        ApplyRetentionPolicyImpl.SetWhereOlderExpirationDateFilter(DateFieldNo, ExpirationDate, RecordRef, FilterGroup, NullDateReplacementValue);
    end;

    /// <summary>
    /// This method places a filter on the record reference where records are newer than the ExpirationDate. The filter excludes any record where the date field specified in DateFieldNo has no value.
    /// </summary>
    /// <param name="DateFieldNo">The date or datetime field the filter will be placed on.</param>
    /// <param name="ExpirationDate">The expiration date used in the filter.</param>
    /// <param name="RecordRef">The record reference on whic the filter will be placed.</param>
    /// <param name="FilterGroup">The filtergroup in which the filter will be placed.</param>
    /// <param name="NullDateFilterGroup">The filtergroup in which the null date filter will be placed.</param>
    /// <param name="NullDateReplacementValue">The date to be used to determine whether a record has expired when the date or datetime value of the record is 0D.</param>
    procedure SetWhereNewerExpirationDateFilter(DateFieldNo: Integer; ExpirationDate: Date; var RecordRef: RecordRef; FilterGroup: Integer; NullDateReplacementValue: Date)
    var
        ApplyRetentionPolicyImpl: Codeunit "Apply Retention Policy Impl.";
    begin
        ApplyRetentionPolicyImpl.SetWhereNewerExpirationDateFilter(DateFieldNo, ExpirationDate, RecordRef, FilterGroup, NullDateReplacementValue);
    end;

    /// <summary>
    /// This event is raised once the maximum number of records which can be deleted in a single run is reached. The limit is defined internally and cannot be changed. The event can be used to schedule a new run to delete the remaining records.
    /// </summary>
    /// <param name="CurrTableId">Specifies the Id of the table on which the limit was reached.</param>
    /// <param name="NumberOfRecordsRemainingToBeDeleted">Show the number of records remaining to be deleted for the table specified in CurrTableId.</param>
    /// <param name="ApplyAllRetentionPolicies">Specifies where the interupted run was for all retention policies or only one retention policy.</param>
    /// <param name="UserInvokedRun">Specifies whether the run was initiated by a user or not.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnApplyRetentionPolicyRecordLimitExceeded(CurrTableId: Integer; NumberOfRecordsRemainingToBeDeleted: Integer; ApplyAllRetentionPolicies: Boolean; UserInvokedRun: Boolean; var Handled: Boolean)
    begin
    end;

    /// <summary>
    /// This event is raised when the user applying the retention policy has indirect permissions to delete records in the table.
    /// A subscriber to this event with indirect permissions can delete the records on behalf of the user.
    /// </summary>
    /// <param name="RecRef">The record reference which contains the expired records to be deleted.</param>
    /// <param name="Handled">Indicates whether the event has been handled.</param>
#pragma warning disable AA0072
    [IntegrationEvent(false, false)]
    internal procedure OnApplyRetentionPolicyIndirectPermissionRequired(var RecRef: RecordRef; var Handled: Boolean)
    begin
    end;
#pragma warning restore
}