// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 8700 "Table Information Cache"
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
        field(2; "Table No."; Integer)
        {
            Caption = 'Table No.';
        }
        field(3; "Table Name"; Text[30])
        {
            Caption = 'Table Name';
        }
        field(4; "No. of Records"; Integer)
        {
            Caption = 'No. of Records';
        }
        field(5; "Record Size"; Decimal)
        {
            Caption = 'Record Size';
        }
        field(6; "Size (KB)"; Integer)
        {
            Caption = 'Size (KB)';
        }
        field(7; "Compression"; Option)
        {
            Caption = 'Compression';
            OptionMembers = None,Row,Page,Columnstore,"Columnstore Archive";
        }
        field(8; "Data Size (KB)"; Integer)
        {
            Caption = 'Data Size (KB)';
        }
        field(9; "Index Size (KB)"; Integer)
        {
            Caption = 'Index Size (KB)';
        }
        field(8700; "Last Period Data Size (KB)"; Integer)
        {
            Caption = 'Last Period Size (30D)';
        }
        field(8702; "Growth %"; Decimal)
        {
            Caption = 'Growth % (30D)';
        }
        field(8701; "Last Period No. of Records"; Integer)
        {
            caption = 'Last Period No. of Records (30D)';
        }

    }

    keys
    {
        key(pk; "Company Name", "Table No.")
        {
            SumIndexFields = "Size (KB)", "Data Size (KB)", "Index Size (KB)";
        }
        key(sort; "Data Size (KB)")
        {
        }
    }
}