// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

/// <summary>
/// Holds the information for all file accounts that are registered via the Local File connector
/// </summary>
table 4820 "Ext. Local File Account"
{
    Access = Internal;
    Caption = 'Local File Account';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Id"; Guid)
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(2; Name; Text[250])
        {
            Caption = 'Account Name';
        }
        field(3; "Base Path"; Text[2048])
        {
            Caption = 'Base Path';

            trigger OnValidate()
            begin
                if "Base Path" = '' then
                    exit;

                if not "Base Path".EndsWith('\') then
                    "Base Path" += '\';
            end;
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