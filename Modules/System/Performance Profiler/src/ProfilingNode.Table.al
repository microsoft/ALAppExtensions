// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// A buffer table containing the information recorded by a performance profiler.
/// </summary>
table 1921 "Profiling Node"
{
    Access = Public;
    TableType = Temporary;

    fields
    {
        field(1; "Session ID"; Integer)
        {
        }
        field(2; "No."; Integer)
        {
        }
        field(3; "Hit Count"; Integer)
        {
        }
        field(4; "Object Type"; Text[250])
        {
        }
        field(5; "Object ID"; Integer)
        {
        }
        field(6; "Object Name"; Text[250])
        {
        }
        field(7; "App Name"; Text[250])
        {
        }
        field(8; "App Publisher"; Text[250])
        {
        }
        field(9; "Line No"; Integer)
        {
        }
        field(10; "Method Name"; Text[1024])
        {
        }
        field(11; "Self Time"; Duration)
        {
        }
        field(12; "Full Time"; Duration)
        {
        }
        field(13; Indentation; Integer)
        {
        }
    }

    keys
    {
        key(PK; "Session ID", "No.")
        {
            Clustered = true;
            SumIndexFields = "Self Time", "Full Time";
        }
        key(key1; "Object Type", "Object ID")
        {
        }
        key(key2; "Object Type", "Object ID", "Method Name")
        {
        }
        key(key3; Indentation)
        {
        }
        key(key4; "Self Time")
        {
        }
        key(key5; "Full Time")
        {
        }
    }
}

