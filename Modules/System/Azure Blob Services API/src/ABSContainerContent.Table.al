// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Holds information about container content in a storage account.
/// </summary>
table 9043 "ABS Container Content"
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
            Access = Internal;
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
            DataClassification = SystemMetadata;
            Caption = 'Full Name', Locked = true;
        }
        field(10; Name; Text[2048])
        {
            DataClassification = SystemMetadata;
            Caption = 'Name', Locked = true;
        }
        field(11; "Creation Time"; DateTime)
        {
            DataClassification = SystemMetadata;
            Caption = 'Creation-Time', Locked = true;
            Description = 'Caption matches the corresponding property as defined in https://go.microsoft.com/fwlink/?linkid=2210588#response-body';
        }
        field(12; "Last Modified"; DateTime)
        {
            DataClassification = SystemMetadata;
            Caption = 'Last-Modified', Locked = true;
            Description = 'Caption matches the corresponding property as defined in https://go.microsoft.com/fwlink/?linkid=2210588#response-body';
        }
        field(13; "Content Length"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Content-Length', Locked = true;
            Description = 'Caption matches the corresponding property as defined in https://go.microsoft.com/fwlink/?linkid=2210588#response-body';
        }
        field(14; "Content Type"; Text[2048])
        {
            DataClassification = SystemMetadata;
            Caption = 'Content-Type', Locked = true;
            Description = 'Caption matches the corresponding property as defined in https://go.microsoft.com/fwlink/?linkid=2210588#response-body';
        }
#pragma warning disable AS0086
        field(15; "Blob Type"; Text[2048])
        {
            DataClassification = SystemMetadata;
            Caption = 'BlobType', Locked = true;
            Description = 'Caption matches the corresponding property as defined in https://go.microsoft.com/fwlink/?linkid=2210588#response-body';
        }
#pragma warning restore AS0086
        field(16; "Resource Type"; Enum "ABS Blob Resource Type")
        {
            DataClassification = SystemMetadata;
            Caption = 'ResourceType', Locked = true;
            Description = 'Caption matches the corresponding property as defined in https://go.microsoft.com/fwlink/?linkid=2210588#response-body';
        }
        field(100; "XML Value"; Blob)
        {
            DataClassification = SystemMetadata;
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