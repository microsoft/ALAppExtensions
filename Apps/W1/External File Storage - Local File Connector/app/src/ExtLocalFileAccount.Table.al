// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

/// <summary>
/// Holds the information for all file accounts that are registered via the File Share connector
/// </summary>
table 4820 "Ext. Local File Account"
{
    Access = Internal;
    DataClassification = CustomerContent;
    Caption = 'Local File Account';

    fields
    {
        field(1; "Id"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Primary Key';
        }
        field(2; Name; Text[250])
        {
            Caption = 'Name of account';
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