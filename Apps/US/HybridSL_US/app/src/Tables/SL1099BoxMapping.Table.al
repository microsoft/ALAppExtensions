// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47201 "SL 1099 Box Mapping"
{
    Access = Internal;
    DataPerCompany = false;
    Caption = 'SL 1099 Box Mapping';
    DataClassification = SystemMetadata;

    Fields
    {
        field(1; "Tax Year"; Integer)
        {
            Caption = 'Tax Year';
            NotBlank = true;
            TableRelation = "SL Supported Tax Year"."Tax Year";
        }
        field(2; "SL Data Value"; Text[2])
        {
            Caption = 'SL Data Value';
        }
        field(3; "SL 1099 Box No."; Text[3])
        {
            Caption = 'SL 1099 Box No.';
            NotBlank = true;
        }
        field(4; "Form Type"; Text[4])
        {
            Caption = 'Form Type';
            NotBlank = true;
        }
        field(5; "BC IRS 1099 Code"; Code[10])
        {
            Caption = 'BC IRS 1099 Code';
            NotBlank = true;
        }
    }
    Keys
    {
        key(Key1; "Tax Year", "SL Data Value")
        {
            Clustered = true;
        }
    }
}