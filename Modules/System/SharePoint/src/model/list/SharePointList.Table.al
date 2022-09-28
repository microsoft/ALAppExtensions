// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Holds information about list entity.
/// </summary>
table 9105 "SharePoint List"
{
    Access = Public;
    DataClassification = CustomerContent;
    Caption = 'SharePoint List';
    TableType = Temporary;
    Extensible = false;

    fields
    {
        field(1; Id; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Id';
        }

        field(2; Title; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Title';
        }

        field(3; Created; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Created';
        }

        field(4; Description; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }

        field(5; "Base Template"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Base Template';
        }

        field(6; "Base Type"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Base Type';
        }

        field(7; "Is Catalog"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Is Catalog';
        }

        field(8; "List Item Entity Type"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'List Item Entity Type Full Name';
        }

        field(9; OdataId; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Odata.Id';
        }

        field(10; OdataType; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Odata.Type';
        }

        field(11; OdataEditLink; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Odata.EditLink';
        }
    }

    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
    }

}