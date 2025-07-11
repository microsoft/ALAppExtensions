// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.C5;

table 1895 "C5 ExchRate"
{
    ReplicateData = false;

    fields
    {
        field(1; RecId; Integer)
        {
            Caption = 'Row number';
        }
        field(2; LastChanged; Date)
        {
            Caption = 'Last changed';
        }
        field(3; Currency; Code[3])
        {
            Caption = 'Currency';
        }
        field(4; ExchRate; Decimal)
        {
            Caption = 'Exch. rate';
        }
        field(5; FromDate; Date)
        {
            Caption = 'From date';
        }
        field(6; Comment; Text[50])
        {
            Caption = 'Comment';
        }
        field(7; Triangulation; Option)
        {
            Caption = 'Triangulation';
            OptionMembers = No,Yes;
        }
    }

    keys
    {
        key(PK; RecId)
        {
            Clustered = true;
        }
    }
}

