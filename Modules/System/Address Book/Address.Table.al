// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Temporary table that holds address information.
/// </summary>
table 8944 Address
{
    Access = Public;
    TableType = Temporary;

    fields
    {
        field(1; Name; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(2; "E-Mail Address"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(3; "Phone No."; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(4; Company; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(5; "Source Name"; Text[250])
        {
            DataClassification = SystemMetadata;
            Description = 'The caption of the entity from which the address information came (e.g. Contact or Customer).';
        }
    }

    keys
    {
        key(PK; "E-Mail Address")
        {
            Clustered = true;
        }
        key(Key2; "Source Name")
        {
        }
    }

}