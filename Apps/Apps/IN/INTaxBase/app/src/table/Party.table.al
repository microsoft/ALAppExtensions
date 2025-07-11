// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxBase;

table 18551 Party
{
    Caption = 'Party';
    DataCaptionFields = "Code", Name;
    DrillDownPageID = Parties;
    LookupPageID = Parties;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(4; Name; Text[30])
        {
            Caption = 'Name';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(5; Address; Text[50])
        {
            Caption = 'Address';
            DataClassification = EndUserIdentifiableInformation;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }
}
