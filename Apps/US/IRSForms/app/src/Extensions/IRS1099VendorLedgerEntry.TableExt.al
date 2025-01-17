// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Purchases.Payables;

tableextension 10035 "IRS 1099 Vendor Ledger Entry" extends "Vendor Ledger Entry"
{

    fields
    {
        field(10030; "IRS 1099 Subject For Reporting"; Boolean)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(10031; "IRS 1099 Reporting Period"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "IRS Reporting Period";

            trigger OnValidate()
            begin
                IRS1099FormDocument.CheckIfVendLedgEntryAllowed(Rec."Entry No.");
                Validate("IRS 1099 Form No.", '');
            end;
        }
        field(10032; "IRS 1099 Form No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "IRS 1099 Form"."No." where("Period No." = field("IRS 1099 Reporting Period"));

            trigger OnValidate()
            begin
                IRS1099FormDocument.CheckIfVendLedgEntryAllowed(Rec."Entry No.");
                Validate("IRS 1099 Form Box No.", '');
                Validate("IRS 1099 Reporting Amount", 0);
            end;
        }
        field(10033; "IRS 1099 Form Box No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "IRS 1099 Form Box"."No." where("Period No." = field("IRS 1099 Reporting Period"), "Form No." = field("IRS 1099 Form No."));

            trigger OnValidate()
            begin
                IRS1099FormDocument.CheckIfVendLedgEntryAllowed(Rec."Entry No.");
                "IRS 1099 Subject For Reporting" := "IRS 1099 Form Box No." <> '';
            end;
        }
        field(10034; "IRS 1099 Reporting Amount"; Decimal)
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                IRS1099FormDocument.CheckIfVendLedgEntryAllowed(Rec."Entry No.");
                if "IRS 1099 Reporting Amount" <> 0 then begin
                    CalcFields(Amount);
                    if ("Document Type" = "Document Type"::Invoice) and ("IRS 1099 Reporting Amount" > 0) then
                        FieldError("IRS 1099 Reporting Amount", MustBeNegativeErr);
                    if ("Document Type" = "Document Type"::"Credit Memo") and ("IRS 1099 Reporting Amount" < 0) then
                        FieldError("IRS 1099 Reporting Amount", MustBePositiveErr);
                    if Abs("IRS 1099 Reporting Amount") > Abs(Amount) then
                        error(IRSReportingAmountCannotBeMoreThanAmountErr);
                end;
                "IRS 1099 Subject For Reporting" := ("IRS 1099 Form Box No." <> '') and ("IRS 1099 Reporting Amount" <> 0);
            end;
        }
    }

    var
        IRS1099FormDocument: Codeunit "IRS 1099 Form Document";
        IRSReportingAmountCannotBeMoreThanAmountErr: Label 'IRS Reporting Amount cannot be more than Amount';
        MustBePositiveErr: Label 'must be positive';
        MustBeNegativeErr: Label 'must be negative';
}
