// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Holds information about folder entity.
/// </summary>
table 9106 "SharePoint Folder"
{
    Access = Public;
    DataClassification = CustomerContent;
    Caption = 'SharePoint Folder';
    TableType = Temporary;
    Extensible = false;

    fields
    {
        field(1; "Unique Id"; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Unique Id';
        }

        field(2; Name; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Title';
        }

        field(3; Created; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Created';
        }

        field(4; "Item Count"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Item Count';
        }

        field(5; "Exists"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Exists';
        }

        field(6; "Server Relative Url"; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Server Relative Url';
        }

        field(7; OdataId; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Odata.Id';
        }

        field(8; OdataType; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Odata.Type';
        }

        field(9; OdataEditLink; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Odata.EditLink';
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