// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Finance.GeneralLedger.Journal;

tableextension 10040 "IRS 1099 Gen. Jnl. Line" extends "Gen. Journal Line"
{
    fields
    {
        field(10051; "IRS 1099 Reporting Period"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "IRS Reporting Period";
            Editable = false;

            trigger OnValidate()
            begin
                Validate("IRS 1099 Form No.", '');
            end;
        }
        field(10052; "IRS 1099 Form No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "IRS 1099 Form"."No." where("Period No." = field("IRS 1099 Reporting Period"));

            trigger OnValidate()
            begin
                Validate("IRS 1099 Form Box No.", '');
            end;
        }
        field(10053; "IRS 1099 Form Box No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "IRS 1099 Form Box"."No." where("Period No." = field("IRS 1099 Reporting Period"), "Form No." = field("IRS 1099 Form No."));

            trigger OnValidate()
            begin
                Validate("IRS 1099 Reporting Amount", 0);
            end;
        }
        field(10054; "IRS 1099 Reporting Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
    }
}
