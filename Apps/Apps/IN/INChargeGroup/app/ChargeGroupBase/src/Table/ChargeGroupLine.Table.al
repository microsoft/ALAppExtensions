// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.ChargeGroup.ChargeGroupBase;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Inventory.Item;
using Microsoft.Purchases.Vendor;

table 18511 "Charge Group Line"
{
    Caption = 'Charge Group Line';
    LookupPageId = "Charge Group SubPage";
    DrillDownPageId = "Charge Group SubPage";

    fields
    {
        field(1; "Charge Group Code"; Code[10])
        {
            Caption = 'Charge Group Code';
            DataClassification = CustomerContent;
            TableRelation = "Charge Group Header";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(20; Type; Enum "Charge Group Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec.Type <> xRec.Type then
                    clearChargeline();
            end;
        }
        field(30; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            TableRelation = if (Type = const("Charge (Item)")) "Item Charge"
            else
            if (Type = const("G/L Account")) "G/L Account";

            trigger OnValidate()
            begin
                ValidateChargeGroupNo(Type);
            end;
        }
        field(40; "Description"; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(50; Assignment; Enum "Charge Assignment")
        {
            Caption = 'Assignment';
            DataClassification = CustomerContent;
        }
        field(60; "Third Party Invoice"; Boolean)
        {
            Caption = 'Third Party Invoice';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if not Rec."Third Party Invoice" then
                    ClearThirdPartyInvoiceDetails();

                if Rec."Third Party Invoice" then
                    CheckInvoiceCombination();

                if Rec.Type = Rec.Type::"Charge (Item)" then
                    TestField("Third Party Invoice", false);
            end;
        }
        field(70; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = CustomerContent;
            TableRelation = if ("Third Party Invoice" = const(true)) Vendor;

            trigger OnValidate()
            begin
                Testfield("Third Party Invoice");
            end;
        }
        field(80; "G/L Account No."; Code[20])
        {
            Caption = 'G/L Account No.';
            DataClassification = CustomerContent;
            TableRelation = if ("Third Party Invoice" = const(true)) "G/L Account";

            trigger OnValidate()
            begin
                Testfield("Third Party Invoice");
            end;
        }
        field(90; "Computation Method"; Enum "Charge Computation Method")
        {
            Caption = 'Computation Method';
            DataClassification = CustomerContent;
        }
        field(100; "Value"; Decimal)
        {
            Caption = 'Value';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Charge Group Code", "Line No.")
        {
            Clustered = true;
        }
    }

    local procedure ValidateChargeGroupNo(ChargeGroupType: Enum "Charge Group Type")
    begin
        case ChargeGroupType of
            ChargeGroupType::"Charge (Item)":
                CopyFromItemCharge();
            ChargeGroupType::"G/L Account":
                CopyFromGLAccount();
        end;
    end;

    local procedure CopyFromGLAccount()
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount.Get("No.");
        GLAccount.CheckGLAcc();
        GLAccount.TestField("Direct Posting", true);
        Description := GLAccount.Name;
    end;

    local procedure CopyFromItemCharge()
    var
        ItemCharge: Record "Item Charge";
    begin
        ItemCharge.Get("No.");
        Description := ItemCharge.Description;
    end;

    local procedure clearChargeline()
    begin
        Clear("No.");
        Clear(Description);
    end;

    local procedure ClearThirdPartyInvoiceDetails()
    begin
        Clear("Vendor No.");
        Clear("G/l Account No.");
    end;

    local procedure CheckInvoiceCombination()
    var
        ChargeGroupHeader: Record "Charge Group Header";
    begin
        ChargeGroupHeader.Get(Rec."Charge Group Code");
        ChargeGroupHeader.TestField("Invoice Combination");
    end;
}
