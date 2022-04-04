// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Contains details about the results of validating Query Navigation data.
/// </summary>
table 2889 "Query Navigation Validation"
{
    DataClassification = SystemMetadata;
    Extensible = false;
    TableType = Temporary;
    ReplicateData = false;
    ObsoleteReason = 'The SmartList Designer is not supported in Business Central.';
#if not CLEAN19
    ObsoleteTag = '19.0';
    ObsoleteState = Pending;
#else
    ObsoleteTag = '22.0';
    ObsoleteState = Removed;
#endif

    fields
    {
        /// <summary>
        /// Simple primary key of the temporary table. 
        /// </summary>
        field(1; PK; Integer)
        {
            AutoIncrement = true;
            Access = Internal;
            DataClassification = SystemMetadata;
        }

        /// <summary>
        /// Indicates the success/failure of the validation
        /// </summary>
        field(2; Valid; Boolean)
        {
            DataClassification = SystemMetadata;
        }

        /// <summary>
        /// Specifies a detailed message describing why the validation failed.
        /// </summary>
        field(3; Reason; Text[500])
        {
            DataClassification = SystemMetadata;
        }
    }
}
