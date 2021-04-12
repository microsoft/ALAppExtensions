// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Temporary Table to sort Text values alphabetically
/// </summary>
table 87000 "Temp. Sort Table"
{
    Access = Public; // public, because it's needed in other (depending) modules as well
    Description = 'Used to bring Values in alphabetical order';
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(1; "Key"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(2; Value; Text[250])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Key")
        {
            Clustered = true;
        }
    }
}