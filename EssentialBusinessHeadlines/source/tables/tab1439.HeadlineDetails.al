// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

table 1439 "Headline Details"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[10])
        {

            DataClassification = CustomerContent;
        }

        field(2; Name; Text[50])
        {

            DataClassification = CustomerContent;
        }

        field(3; Quantity; Decimal)
        {
            DataClassification = CustomerContent;
        }

        field(4; "Unit of Measure"; Code[10])
        {
            DataClassification = CustomerContent;
        }

        field(5; "Amount (LCY)"; Decimal)
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }
}