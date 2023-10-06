// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.AccessControl;

/// <summary>
/// Buffer table for permission options
/// </summary>
table 9865 "Permission Lookup Buffer"
{
    Access = Internal;
    Caption = 'Permission Lookup Buffer';
    TableType = Temporary;
    InherentEntitlements = RIMDX;
    InherentPermissions = RIMDX;

    fields
    {
        field(1; ID; Integer)
        {
            Caption = 'ID';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(2; "Option Caption"; Text[50])
        {
            Caption = 'Permission';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(3; "Option Description"; Text[100])
        {
            Caption = 'Description';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(4; "Lookup Type"; Option)
        {
            Caption = 'Lookup Type';
            DataClassification = SystemMetadata;
            Editable = false;
            OptionMembers = Include,Exclude;

        }
    }

    keys
    {
        key(Key1; "Option Caption", "Option Description")
        {
            Clustered = true;
        }
        key(Key2; ID)
        {
        }
    }
}

