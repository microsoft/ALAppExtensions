// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Payments;

table 18244 "Bank Charge Deemed Value Setup"
{
    Caption = 'Bank Charge Deemed Value Setup';
    DataCaptionFields = "Bank Charge Code";

    fields
    {
        field(1; "Bank Charge Code"; code[10])
        {
            Caption = 'Bank Charge Code';
            DataClassification = CustomerContent;
            TableRelation = "Bank Charge" where("Foreign Exchange" = const(true));
            NotBlank = true;
        }
        field(2; "Lower Limit"; Decimal)
        {
            Caption = 'Lower Limit';
            DataClassification = CustomerContent;
        }
        field(3; "Upper Limit"; Decimal)
        {
            Caption = 'Upper Limit';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(4; "Formula"; enum "Deemed Value Calculation")
        {
            Caption = 'Formula';
            DataClassification = CustomerContent;
        }
        field(5; "Min. Deemed Value"; Decimal)
        {
            Caption = 'Min. Deemed Value';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(6; "Max. Deemed Value"; Decimal)
        {
            Caption = 'Max. Deemed Value';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(7; "Deemed %"; Decimal)
        {
            Caption = 'Deemed %';
            DataClassification = CustomerContent;
            MinValue = 0;
            MaxValue = 100;
        }
        field(8; "Fixed Amount"; Decimal)
        {
            Caption = 'Fixed Amount';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
    }

    keys
    {
        key(PK; "Bank Charge Code", "Lower Limit", "Upper Limit")
        {
            Clustered = true;
        }
    }
}
