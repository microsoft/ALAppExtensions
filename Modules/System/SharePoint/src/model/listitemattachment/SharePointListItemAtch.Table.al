// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Holds information about list item attachment entity.
/// </summary>
table 9104 "SharePoint List Item Atch"
{
    Access = Public;
    DataClassification = SystemMetadata;
    Caption = 'SharePoint List Item Attachment';
    TableType = Temporary;
    Extensible = false;

    fields
    {

        field(1; OdataId; Text[2048])
        {
            DataClassification = SystemMetadata;
            Caption = 'Odata.Id';
        }

        field(2; OdataEditLink; Text[2048])
        {
            DataClassification = SystemMetadata;
            Caption = 'Odata.editLink';
        }

        field(3; "File Name"; Text[2048])
        {
            DataClassification = SystemMetadata;
            Caption = 'File Name';
        }

        field(4; "Server Relative Url"; Text[2048])
        {
            DataClassification = SystemMetadata;
            Caption = 'Server Relative Url';
        }

        field(5; "List Id"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'List Id';
        }

        field(6; "List Item Id"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'List Item Id';
        }

        field(7; OdataType; Text[2048])
        {
            DataClassification = SystemMetadata;
            Caption = 'Odata.Type';
        }

    }

    keys
    {
        key(PK; "OdataId")
        {
            Clustered = true;
        }
    }
}