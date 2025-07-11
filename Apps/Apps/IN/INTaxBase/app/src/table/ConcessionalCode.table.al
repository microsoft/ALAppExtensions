// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxBase;

table 18544 "Concessional Code"
{
    Caption = 'Concessional Codes';
    DataClassification = EndUserIdentifiableInformation;
    DrillDownPageId = "Concessional Codes";
    LookupPageId = "Concessional Codes";
    Access = Public;
    Extensible = true;

    fields
    {
        field(1; Code; Code[10])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(2; Description; Text[30])
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
