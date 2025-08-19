// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Purchases.Vendor;

table 10045 "IRS 1099 Vendor Form Box Adj."
{
    Caption = 'IRS 1099 Vendor Form Box Adjustment';
    DataClassification = CustomerContent;
    DrillDownPageId = "IRS 1099 Vend. Form Box Adjmts";
    LookupPageId = "IRS 1099 Vend. Form Box Adjmts";

    fields
    {
        field(1; "Period No."; Code[20])
        {
            TableRelation = "IRS Reporting Period";
        }
        field(2; "Vendor No."; Code[20])
        {
            TableRelation = Vendor;
        }
        field(3; "Form No."; Code[20])
        {
            TableRelation = "IRS 1099 Form"."No." where("Period No." = field("Period No."));
            NotBlank = true;
        }
        field(4; "Form Box No."; Code[20])
        {
            TableRelation = "IRS 1099 Form Box"."No." where("Period No." = field("Period No."), "Form No." = field("Form No."));
            NotBlank = true;
        }
        field(10; Amount; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = '';
        }
        field(100; "Vendor Name"; Text[100])
        {
            CalcFormula = lookup(Vendor.Name where("No." = field("Vendor No.")));
            FieldClass = FlowField;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Period No.", "Vendor No.", "Form No.", "Form Box No.")
        {
            Clustered = true;
        }
    }
}
