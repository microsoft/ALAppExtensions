// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 8701 "Company Size Cache"
{
    DataPerCompany = false;
    ReplicateData = false;
    Access = Internal;
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Company Name"; Text[30])
        {
            Caption = 'Company Name';
        }
        field(6; "Size (KB)"; Integer)
        {
            Caption = 'Size (KB)';
        }
        field(8; "Data Size (KB)"; Integer)
        {
            Caption = 'Data Size (KB)';
        }
        field(9; "Index Size (KB)"; Integer)
        {
            Caption = 'Index Size (KB)';
        }

    }

    keys
    {
        key(pk; "Company Name")
        {
            SumIndexFields = "Size (KB)", "Data Size (KB)", "Index Size (KB)";
        }
        key(sort; "Size (KB)")
        {
        }
    }
}