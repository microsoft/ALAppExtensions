// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Holds information about directory content in a storage account.
/// </summary>
table 8950 "AFS Directory Content"
{
    Access = Public;
    InherentEntitlements = X;
    InherentPermissions = X;
    Extensible = false;
    DataClassification = SystemMetadata;
    TableType = Temporary;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Entry No.', Locked = true;
        }
        field(2; "Parent Directory"; Text[2048])
        {
            DataClassification = SystemMetadata;
            Caption = 'Parent Directory', Locked = true;
        }
        field(3; Level; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Level', Locked = true;
        }
        field(4; "Full Name"; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Full Name', Locked = true;
        }
        field(10; Name; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Name', Locked = true;
        }
        field(11; "Creation Time"; DateTime)
        {
            DataClassification = SystemMetadata;
            Caption = 'CreationTime', Locked = true;
        }
        field(12; "Last Modified"; DateTime)
        {
            DataClassification = SystemMetadata;
            Caption = 'Last-Modified', Locked = true;
        }
        field(13; "Content Length"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Content-Length', Locked = true;
        }
        field(14; "Last Access Time"; DateTime)
        {
            DataClassification = SystemMetadata;
            Caption = 'LastAccessTime', Locked = true;
        }
        field(15; "Change Time"; DateTime)
        {
            DataClassification = SystemMetadata;
            Caption = 'ChangeTime', Locked = true;
        }
        field(16; "Resource Type"; Enum "AFS File Resource Type")
        {
            DataClassification = SystemMetadata;
            Caption = 'ResourceType', Locked = true;
        }
        field(17; Etag; Text[200])
        {
            DataClassification = SystemMetadata;
            Caption = 'Etag', Locked = true;
        }
        field(18; Archive; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Archive', Locked = true;
        }
        field(19; Hidden; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Hidden', Locked = true;
        }
        field(20; "Last Write Time"; DateTime)
        {
            DataClassification = SystemMetadata;
            Caption = 'LastWriteTime', Locked = true;
        }
        field(21; "Read Only"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'ReadOnly', Locked = true;
        }
        field(22; "Permission Key"; Text[200])
        {
            DataClassification = SystemMetadata;
            Caption = 'PermissionKey', Locked = true;
        }
        field(100; "XML Value"; Blob)
        {
            DataClassification = CustomerContent;
            Caption = 'XML Value', Locked = true;
        }
        field(110; URI; Text[2048])
        {
            DataClassification = SystemMetadata;
            Caption = 'URI', Locked = true;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}