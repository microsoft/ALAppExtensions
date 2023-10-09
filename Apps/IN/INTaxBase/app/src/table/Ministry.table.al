// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxBase;

table 18546 "Ministry"
{
    DataClassification = EndUserIdentifiableInformation;
    Caption = 'Ministry';
    DrillDownPageId = Ministries;
    LookupPageId = Ministries;
    Access = Public;
    Extensible = true;

    fields
    {
        field(1; "Code"; Code[3])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(2; Name; Text[150])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(3; "Other Ministry"; Boolean)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }
}
