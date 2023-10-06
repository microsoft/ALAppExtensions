// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Integration;

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
            DataClassification = SystemMetadata;
            AutoIncrement = true;
            Caption = 'Entry ID';
        }
        field(2; "Filter"; BLOB)
        {
            DataClassification = CustomerContent;
            Caption = 'Filter';
        }
        field(3; TenantWebServiceID; RecordID)
        {
            Caption = 'Tenant Web Service ID';
            DataClassification = CustomerContent;
        }
        field(4; "Data Item"; Integer)
        {
            DataClassification = SystemMetadata;
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

