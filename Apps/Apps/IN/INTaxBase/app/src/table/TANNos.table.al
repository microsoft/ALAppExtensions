// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxBase;

table 18548 "TAN Nos."
{
    Caption = 'T.A.N. Nos.';
    DataCaptionFields = Code, Description;
    DataClassification = EndUserIdentifiableInformation;
    DrillDownPageId = "T.A.N. Nos.";
    LookupPageId = "T.A.N. Nos.";
    Access = Public;
    Extensible = true;

    fields
    {
        field(1; "Code"; Code[10])
        {
            NotBlank = true;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(2; Description; Text[50])
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
