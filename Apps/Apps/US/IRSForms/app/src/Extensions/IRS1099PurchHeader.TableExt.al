// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Purchases.Document;

tableextension 10036 "IRS 1099 Purch. Header" extends "Purchase Header"
{
    fields
    {
        field(10031; "IRS 1099 Reporting Period"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "IRS Reporting Period";
            Editable = false;

            trigger OnValidate()
            begin
                Validate("IRS 1099 Form No.", '');
            end;
        }
        field(10032; "IRS 1099 Form No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "IRS 1099 Form"."No." where("Period No." = field("IRS 1099 Reporting Period"));

            trigger OnValidate()
            begin
                Validate("IRS 1099 Form Box No.", '');
            end;
        }
        field(10033; "IRS 1099 Form Box No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "IRS 1099 Form Box"."No." where("Period No." = field("IRS 1099 Reporting Period"), "Form No." = field("IRS 1099 Form No."));
        }
    }
}
