// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Holds information about file handles that are currently open.
/// </summary>
table 8951 "AFS Handle"
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
            Caption = 'Entry No.';
        }
        field(10; "Handle ID"; Text[50])
        {
            Caption = 'HandleId';
        }
        field(11; Path; Text[2048])
        {
            Caption = 'Path';
        }
        field(12; "Client IP"; Text[2048])
        {
            Caption = 'ClientIp';
            DataClassification = EndUserPseudonymousIdentifiers;
        }
        field(13; "Open Time"; DateTime)
        {
            Caption = 'OpenTime';
        }
        field(14; "Last Reconnect Time"; DateTime)
        {
            Caption = 'LastReconnectTime';
        }
        field(15; "File ID"; Text[50])
        {
            Caption = 'FileId';
        }
        field(16; "Parent ID"; Text[50])
        {
            Caption = 'ParentId';
        }
        field(17; "Session ID"; Text[50])
        {
            Caption = 'SessionId';
        }
        field(20; "Next Marker"; Text[2048])
        {
            Caption = 'NextMarker';
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