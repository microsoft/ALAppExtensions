// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxBase;

table 18545 "Deductor Category"
{
    DataClassification = EndUserIdentifiableInformation;
    Caption = 'Deductor Category';
    DrillDownPageId = "Deductor Categories";
    LookupPageId = "Deductor Categories";
    Access = Public;
    Extensible = true;

    fields
    {
        field(1; Code; Code[1])
        {
            NotBlank = true;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(2; Description; Text[50])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(3; "PAO Code Mandatory"; Boolean)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(4; "DDO Code Mandatory"; Boolean)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(5; "State Code Mandatory"; Boolean)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(6; "Ministry Details Mandatory"; Boolean)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(7; "Transfer Voucher No. Mandatory"; Boolean)
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
