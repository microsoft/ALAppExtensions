// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

table 31091 "Commodity Setup CZL"
{
    Caption = 'Commodity Setup';
    DataCaptionFields = "Commodity Code";
    DrillDownPageId = "Commodity Setup CZL";
    LookupPageId = "Commodity Setup CZL";

    fields
    {
        field(1; "Commodity Code"; Code[10])
        {
            Caption = 'Commodity Code';
            NotBlank = true;
            TableRelation = "Commodity CZL";
            DataClassification = CustomerContent;
        }
        field(2; "Valid From"; Date)
        {
            Caption = 'Valid From';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(3; "Valid To"; Date)
        {
            Caption = 'Valid To';
            DataClassification = CustomerContent;
        }
        field(4; "Commodity Limit Amount LCY"; Decimal)
        {
            Caption = 'Commodity Limit Amount LCY';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; "Commodity Code", "Valid From")
        {
            Clustered = true;
        }
    }
}
