// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.DataAdministration;

/// <summary>
/// The table is used as a parameter table for the ApplyRetentionPolicyAllRecordFilters and ApplyRetentionPolicySubSetFilters methods on the Reten. Pol Filtering interface.
/// </summary>
table 3906 "Reten. Pol. Filtering Param"
{
    Access = Public;
    Extensible = true;
    TableType = Temporary;
    InherentEntitlements = X;
    InherentPermissions = X;
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
        /// The date to be used to determine whether a record has expired when the date or datetime value of the record is 0D.
        /// </summary>
        field(10; "Null Date Replacement value"; Date)
        {
            DataClassification = SystemMetadata;
        }
        /// <summary>
        /// The earliest expiration date for which there are more expired records than the maximum to be deleted in a single run.
        /// </summary>
        field(100; "Expired Record Expiration Date"; Date)
        {
            DataClassification = SystemMetadata;
            Editable = false;
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