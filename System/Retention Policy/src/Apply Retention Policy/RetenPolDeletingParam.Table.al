// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// The table is used as a parameter table for the DeleteRecords method on the Reten. Pol Deleting interface.
///
/// if "Indirect Permission Required" is true and the implementation does not have the required indirect permissions, 
/// then "Skip Event Indirect Perm. Req." should be set to false. This will allow a subscriber to handle the deletion.
///
/// if there are more records to be deleted than as indicated by "Max. Number of Rec. to Delete",
/// then only a number of records equal to "Max. Number of Rec. to Delete" should be deleted.
/// In the case where not all records were deleted, "Skip Event Rec. Limit Exceeded" should be set to false. This
/// will allow either a subscriber or the user to schedule another run to delete the remaining records.
///
/// "Total Max. Nr. of Rec. to Del." is provided for information only. This is the maximum number of records recommended to delete
/// in a single run of Apply Retention Policies.
///
/// "User Invoked Run" is provided for information only.
/// </summary>
table 3907 "Reten. Pol. Deleting Param"
{
    Access = Public;
    Extensible = true;
    TableType = Temporary;
    DataClassification = SystemMetadata;

    fields
    {
        /// <summary>
        /// Identifies the record in the table
        /// </summary>
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = SystemMetadata;
        }
        /// <summary>
        /// Indicates that indirect permissions are required to delete expired records for the retention policy.
        /// </summary>
        field(2; "Indirect Permission Required"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
        /// <summary>
        /// if set to true the event OnApplyRetentionPolicyIndirectPermissionRequired will not be raised.
        /// </summary>
        field(3; "Skip Event Indirect Perm. Req."; Boolean)
        {
            DataClassification = SystemMetadata;
        }
        /// <summary>
        /// Indicates the maximum number of records to be deleted.
        /// </summary>
        field(4; "Max. Number of Rec. to Delete"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        /// <summary>
        /// if set to true the event OnApplyRetentionPolicyRecordLimitExceeded will not be raised.
        /// </summary>
        field(5; "Skip Event Rec. Limit Exceeded"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
        /// <summary>
        /// Indicates the maximum number of records that can be deleted at the same time accross all retention policies
        /// </summary>
        field(6; "Total Max. Nr. of Rec. to Del."; Integer)
        {
            DataClassification = SystemMetadata;
        }
        /// <summary>
        /// If true, indicates that user is applying the retention policies manually.
        /// If false, the retention policies are applied by a scheduled task.
        /// </summary>
        field(7; "User Invoked Run"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}