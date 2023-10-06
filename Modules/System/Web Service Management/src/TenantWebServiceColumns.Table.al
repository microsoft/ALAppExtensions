// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Integration;

using System.Reflection;

/// <summary>
/// Contains tenant web service column entities.
/// </summary>
table 6711 "Tenant Web Service Columns"
{
    Caption = 'Tenant Web Service Columns';
    DataPerCompany = false;
    ReplicateData = false;
    Extensible = false;
    Access = Public;

    fields
    {
        field(1; "Entry ID"; Integer)
        {
            DataClassification = SystemMetadata;
            AutoIncrement = true;
            Caption = 'Entry ID';
        }
        field(2; "Data Item"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Data Item';
        }
        field(3; "Field Number"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Field Number';
        }
        field(4; "Field Name"; Text[250])
        {
            DataClassification = SystemMetadata;
            Caption = 'Report Caption';
        }
        field(5; TenantWebServiceID; RecordID)
        {
            Caption = 'Tenant Web Service ID';
            DataClassification = CustomerContent;
        }
        field(6; "Data Item Caption"; Text[250])
        {
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Table),
                                                                           "Object ID" = field("Data Item")));
            Caption = 'Table';
            FieldClass = FlowField;
        }
        field(7; Include; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Include';
        }
        field(8; "Field Caption"; Text[250])
        {
            CalcFormula = lookup(Field."Field Caption" where(TableNo = field("Data Item"),
                                                              "No." = field("Field Number")));
            Caption = 'Field Caption';
            FieldClass = FlowField;
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

