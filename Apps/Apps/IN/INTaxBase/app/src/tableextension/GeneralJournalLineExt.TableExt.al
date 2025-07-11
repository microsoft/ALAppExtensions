// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;

using Microsoft.Finance.TaxBase;
using Microsoft.Inventory.Location;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;

tableextension 18545 "GeneralJournalLineExt" extends "Gen. Journal Line"
{
    fields
    {
        field(18543; "Location Code"; code[10])
        {
            TableRelation = Location;
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            begin
                CreateDimFromDefaultDim(Rec.FieldNo("Location Code"));
            end;
        }
        field(18544; "TDS Section Code"; Code[10])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18545; "Work Tax Nature Of Deduction"; Code[10])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18546; "T.A.N. No."; Code[10])
        {
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = "TAN Nos.";
        }
        field(18547; "Party Type"; Enum "GenJnl Party Type")
        {
            Caption = 'Party Type';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18548; "Party Code"; code[20])
        {
            Caption = 'Party Code';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = if ("Party Type" = const(Party)) Party.Code
            else
            if ("Party Type" = const(Vendor)) Vendor."No." else
            if ("Party Type" = const(Customer)) Customer."No.";
        }
        field(18549; "Old Document No."; Code[20])
        {
            Caption = 'Old Document No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18550; "Provisional Entry"; Boolean)
        {
            Caption = 'Provisional Entry';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18551; "Applied Provisional Entry"; Integer)
        {
            Caption = 'Applied Provisional Entry';
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18552; "TDS Certificate Receivable"; Boolean)
        {
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            begin
                if "TDS Certificate Receivable" then begin
                    TestField("Account Type", "Account Type"::Customer);
                    Validate("TDS Section Code", '');
                end;
            end;
        }
    }
}
