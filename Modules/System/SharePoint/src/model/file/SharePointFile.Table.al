// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Integration.Sharepoint;

/// <summary>
/// Holds information about file entity.
/// </summary>
table 9100 "SharePoint File"
{
    Access = Public;
    InherentEntitlements = X;
    InherentPermissions = X;
    DataClassification = SystemMetadata; // Data classification is SystemMetadata as the table is temporary
    Caption = 'SharePoint File';
    TableType = Temporary;
    Extensible = false;

    fields
    {
        field(1; "Unique Id"; Guid)
        {
            Caption = 'Unique Id';
        }

        field(2; Name; Text[250])
        {
            Caption = 'Name';
        }

        field(3; Created; DateTime)
        {
            Caption = 'Created';
        }

        field(4; Length; Integer)
        {
            Caption = 'Length';
        }

        field(5; Exists; Boolean)
        {
            Caption = 'Exists';
        }

        field(6; "Server Relative Url"; Text[2048])
        {
            Caption = 'Server Relative Url';
        }

        field(7; Title; Text[250])
        {
            Caption = 'Title';
        }

        field(8; OdataId; Text[2048])
        {
            Caption = 'Odata.Id';
        }

        field(9; OdataType; Text[2048])
        {
            Caption = 'Odata.Type';
        }

        field(10; OdataEditLink; Text[2048])
        {
            Caption = 'Odata.EditLink';
        }

        field(11; Id; Integer)
        {
            Caption = 'Id';
        }
    }

    keys
    {
        key(PK; "Unique Id")
        {
            Clustered = true;
        }
    }

}