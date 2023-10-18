// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxBase;

table 18543 "Assessee Code"
{
    DataClassification = EndUserIdentifiableInformation;
    Caption = 'Assessee Code';
    DataCaptionFields = Code, Description;
    DrillDownPageId = "Assessee Codes";
    LookupPageId = "Assessee Codes";
    Access = Public;
    Extensible = true;

    fields
    {
        field(1; "Code"; Code[10])
        {
            NotBlank = true;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(2; Description; Text[100])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(3; Type; Enum "Assessee Type")
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
