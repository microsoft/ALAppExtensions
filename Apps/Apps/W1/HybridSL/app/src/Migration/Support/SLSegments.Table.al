// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47008 "SL Segments"
{
    Access = Internal;
    DataClassification = SystemMetadata;
    ReplicateData = false;

    fields
    {
        field(1; Id; Text[20])
        {
        }
        field(2; Name; Text[30])
        {
        }
        field(3; CodeCaption; Text[80])
        {
        }
        field(4; FilterCaption; Text[80])
        {
        }
        field(5; SegmentNumber; Integer)
        {
        }
    }

    keys
    {
        key(Key1; Id)
        {
            Clustered = true;
        }
    }
}