// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// The Reten. Pol. Filtering interface is used to set filters on the table for which a retention policy is applied.
/// </summary>
interface "Reten. Pol. Filtering"
{
    /// <summary>
    /// This method is called when the retention policy applies to all records of the table. The FilterRecordRef must contain filters whe returned.
    /// </summary>
    /// <param name="RetentionPolicySetup">The retention policy for which filters are applied.</param>
    /// <param name="FilterRecordRef">A RecordRef of the table on which the filters are applied.</param>
    /// <param name="RetenPolFilteringParam">The parameter table for this run of apply retention policy.</param>
    /// <returns>Returns true when there are expired records in the filters</returns>
    procedure ApplyRetentionPolicyAllRecordFilters(RetentionPolicySetup: Record "Retention Policy Setup"; var FilterRecordRef: RecordRef; var RetenPolFilteringParam: Record "Reten. Pol. Filtering Param" temporary): Boolean

    /// <summary>
    /// This method is called when the retention policy defines subsets of records. The records in FilterRecordRef must be marked to indicate they are part of the union of all subsets.
    /// </summary>
    /// <param name="RetentionPolicySetup">The retention policy for which filters are applied.</param>
    /// <param name="FilterRecordRef">A RecordRef of the table on which the filters are applied.</param>
    /// <param name="RetenPolFilteringParam">The parameter table for this run of apply retention policy.</param>
    /// <returns>Returns true when there are expired records in the filters</returns>
    procedure ApplyRetentionPolicySubSetFilters(RetentionPolicySetup: Record "Retention Policy Setup"; var FilterRecordRef: RecordRef; var RetenPolFilteringParam: Record "Reten. Pol. Filtering Param" temporary): Boolean

    /// <summary>
    /// This method is used to determine whether the implementation has read permission to the table specified in TableId.
    /// The permissions depend on both the user and the implementation codeunit.
    /// If the combination of user and implementation codeunit do not have read permission to the table, the retention policy will not be applied.
    /// A notification will be shown on the Retention Policy Setup card.
    /// </summary>
    /// <param name="TableId">The ID of the table for a retention policy is defined</param>
    /// <returns>Returns true if the records in the table can be read.</returns>
    /// <example>
    ///    procedure HasReadPermission(TableId: Integer): Boolean
    ///    var
    ///        RecRef: RecordRef;
    ///    begin
    ///        RecRef.Open(TableId);
    ///        exit(RecRef.ReadPermission())
    ///    end;
    /// </example>
    procedure HasReadPermission(TableId: Integer): Boolean

    /// <summary>
    /// This method is to count the records in the table specified in the RecRef.
    /// The method is only called when the base code does not have read permission to the table.
    /// </summary>
    /// <param name="RecordRef">A record reference.</param>
    /// <returns>The number of records.</returns>
    /// <example>
    ///    procedure Count(RecRef:RecordRef): Integer
    ///    begin
    ///        exit(RecRef.Count())
    ///    end;
    /// </example>
    procedure Count(RecordRef: RecordRef): Integer
}