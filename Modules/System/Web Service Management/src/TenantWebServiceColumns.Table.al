// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

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
            AutoIncrement = true;
            Caption = 'Entry ID';
        }
        field(2; "Data Item"; Integer)
        {
            Caption = 'Data Item';
        }
        field(3; "Field Number"; Integer)
        {
            Caption = 'Field Number';
        }
        field(4; "Field Name"; Text[250])
        {
            Caption = 'Report Caption';
        }
        field(5; TenantWebServiceID; RecordID)
        {
            Caption = 'Tenant Web Service ID';
            DataClassification = CustomerContent;
        }
        field(6; "Data Item Caption"; Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Table),
                                                                           "Object ID" = FIELD("Data Item")));
            Caption = 'Table';
            FieldClass = FlowField;
        }
        field(7; Include; Boolean)
        {
            Caption = 'Include';
        }
        field(8; "Field Caption"; Text[250])
        {
            CalcFormula = Lookup(Field."Field Caption" WHERE(TableNo = FIELD("Data Item"),
                                                              "No." = FIELD("Field Number")));
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

