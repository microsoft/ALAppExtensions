// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 1437 "Headline Details Per User"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20])
        {

            DataClassification = CustomerContent;
        }

        field(2; Name; Text[100])
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

        field(6; "Type"; Option)
        {
            OptionMembers = Item,Resource,Customer;
            DataClassification = CustomerContent;
        }

        field(7; "User Id"; Guid)
        {
            DataClassification = EndUserPseudonymousIdentifiers;
        }
    }

    keys
    {
        key(PK; "No.", Type, "User Id")
        {
            Clustered = true;
        }
    }
}