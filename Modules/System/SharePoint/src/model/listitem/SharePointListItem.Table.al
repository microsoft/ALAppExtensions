// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Holds information about list item entity.
/// </summary>
table 9103 "SharePoint List Item"
{
    Access = Public;
    DataClassification = CustomerContent;
    Caption = 'SharePoint List Item';
    TableType = Temporary;
    Extensible = false;

    fields
    {
        field(1; Guid; Guid)
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

        field(4; Attachments; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Attachments';
        }

        field(5; "File System Object Type"; Integer)
        {
            //Enum with negative values
            // Invalid -	Enumeration whose values specify whether the object is invalid. The value = -1.
            // File	- Enumeration whose values specify whether the object is a file. The value = 0.
            // Folder	- Enumeration whose values specify whether the object is a folder. The value = 1.
            // Web - Enumeration whose values specify whether the object is a site. The values = 2.
            DataClassification = CustomerContent;
            Caption = 'File System Object Type';
        }

        field(6; "Content Type Id"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Content Type Id';
        }

        field(7; Id; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Id';
        }

        field(8; "List Id"; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'List Id';
        }

        field(9; OdataEditLink; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Odata.editLink';
        }
    }

    keys
    {
        key(PK; Guid)
        {
            Clustered = true;
        }
    }

}