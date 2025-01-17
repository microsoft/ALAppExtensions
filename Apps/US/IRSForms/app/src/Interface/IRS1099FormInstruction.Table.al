// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

table 10042 "IRS 1099 Form Instruction"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Period No."; Code[20])
        {
            TableRelation = "IRS Reporting Period";
        }
        field(2; "Form No."; Code[20])
        {
            TableRelation = "IRS 1099 Form"."No." where("Period No." = field("Period No."));
        }
        field(3; "Line No."; Integer)
        {
            AutoIncrement = true;
            NotBlank = true;
        }
        field(5; Header; Text[250])
        {

        }
        field(6; Description; Text[2048])
        {

        }
    }

    keys
    {
        key(PK; "Period No.", "Form No.", "Line No.")
        {
            Clustered = true;
        }
    }
}
