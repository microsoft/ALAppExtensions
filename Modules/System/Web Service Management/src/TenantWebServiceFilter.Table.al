// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Contains tenant web service filter entities.
/// </summary>
table 6712 "Tenant Web Service Filter"
{
    Caption = 'Tenant Web Service Filter';
    DataPerCompany = false;
    Extensible = false;
    Access = Public;
    ReplicateData = false;

    fields
    {
        field(1; "Entry ID"; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry ID';
        }
        field(2; "Filter"; BLOB)
        {
            Caption = 'Filter';
        }
        field(3; TenantWebServiceID; RecordID)
        {
            Caption = 'Tenant Web Service ID';
            DataClassification = CustomerContent;
        }
        field(4; "Data Item"; Integer)
        {
            Caption = 'Data Item';
        }
    }

    keys
    {
        key(Key1; "Entry ID")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

