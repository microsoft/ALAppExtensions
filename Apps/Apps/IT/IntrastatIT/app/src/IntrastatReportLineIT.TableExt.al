// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.FixedAssets.FixedAsset;
using Microsoft.Foundation.Address;
using Microsoft.Inventory.Item;

tableextension 148122 "Intrastat Report Line IT" extends "Intrastat Report Line"
{
    fields
    {
        field(148121; "Company/Representative VAT No."; Text[20])
        {
            Caption = 'Company/Representative VAT No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(148122; "File Disk No."; Code[20])
        {
            Caption = 'File Disk No.';
            Editable = false;
            Numeric = true;
            FieldClass = FlowField;
            CalcFormula = lookup("Intrastat Report Header"."File Disk No." where("No." = field("Intrastat No.")));
        }
        field(148123; "EU 3d-Party Trade"; Boolean)
        {
            Caption = 'EU 3d-Party Trade';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                if "EU 3d-Party Trade" then begin
                    "Total Weight" := 0;
                    "Supplementary Quantity" := 0;
                    "Statistical Value" := 0;
                    "Group Code" := '';
                    "Transport Method" := '';
                    "Transaction Specification" := '';
                    "Country/Region of Origin Code" := '';
                    "Area" := '';
                    "Transaction Type" := '';
                end;
            end;
        }
        modify("Source Type")
        {
            trigger OnAfterValidate()
            begin
                if "Source Type" <> xRec."Source Type" then
                    "Source Entry No." := 0;
            end;
        }
        modify("Source Entry No.")
        {
            trigger OnAfterValidate()
            begin
                Validate("EU 3d-Party Trade", IntrastatReportMgtIT.IsEU3PartyTrade(Rec));
            end;
        }
        modify(Amount)
        {
            trigger OnAfterValidate()
            begin
                if "Cost Regulation %" = 0 then
                    CheckIndirectCost();
            end;
        }
        modify("Cost Regulation %")
        {
            trigger OnAfterValidate()
            begin
                CheckIndirectCost();
            end;
        }
        modify("Indirect Cost")
        {
            trigger OnAfterValidate()
            begin
                CheckIndirectCost();
            end;
        }
        modify("Item No.")
        {
            trigger OnAfterValidate()
            var
                FixedAsset: Record "Fixed Asset";
                Item: Record Item;
                ItemFAOrigCountryCode: Code[10];
            begin
                if "Source Type" = "Source Type"::"FA Entry" then begin
                    FixedAsset.Get("Item No.");
                    ItemFAOrigCountryCode := FixedAsset."Country/Region of Origin Code";
                end else begin
                    Item.Get("Item No.");
                    ItemFAOrigCountryCode := Item."Country/Region of Origin Code";
                end;

                "Country/Region of Origin Code" := IntrastatReportMgtIT.GetIntrastatCountryCode(ItemFAOrigCountryCode);

                if "Item No." <> '' then
                    "Company/Representative VAT No." := IntrastatReportMgtIT.GetCompanyRepresentativeVATNo();
            end;
        }
        modify("Entry/Exit Point")
        {
            trigger OnAfterValidate()
            var
                EntryExitPoint: Record "Entry/Exit Point";
            begin
                if EntryExitPoint.Get("Entry/Exit Point") then
                    "Group Code" := EntryExitPoint."Group Code"
                else
                    "Group Code" := '';
                Validate("Indirect Cost");
            end;
        }
        modify("Transaction Specification")
        {
            trigger OnAfterValidate()
            var
                Country: Record "Country/Region";
            begin
                Country.SetRange("EU Country/Region Code", "Transaction Specification");
                if Country.IsEmpty() then
                    FieldError("Transaction Specification");

                if "Transaction Specification" <> '' then
                    TestField("EU 3d-Party Trade", false);
            end;
        }
        modify("Total Weight")
        {
            trigger OnAfterValidate()
            begin
                if "Total Weight" <> 0 then
                    TestField("EU 3d-Party Trade", false);
            end;
        }
        modify("Supplementary Quantity")
        {
            trigger OnAfterValidate()
            begin
                if "Supplementary Quantity" <> 0 then
                    TestField("EU 3d-Party Trade", false);
            end;
        }
        modify("Statistical Value")
        {
            trigger OnAfterValidate()
            begin
                if "Statistical Value" <> 0 then
                    TestField("EU 3d-Party Trade", false);
            end;
        }
        modify("Group Code")
        {
            trigger OnAfterValidate()
            begin
                if "Group Code" <> '' then
                    TestField("EU 3d-Party Trade", false);
            end;
        }
        modify("Transport Method")
        {
            trigger OnAfterValidate()
            begin
                if "Transport Method" <> '' then
                    TestField("EU 3d-Party Trade", false);
            end;
        }
        modify("Country/Region of Origin Code")
        {
            trigger OnAfterValidate()
            begin
                if "Country/Region of Origin Code" <> '' then
                    TestField("EU 3d-Party Trade", false);
            end;
        }
        modify("Area")
        {
            trigger OnAfterValidate()
            begin
                if "Area" <> '' then
                    TestField("EU 3d-Party Trade", false);
            end;
        }
        modify("Transaction Type")
        {
            trigger OnAfterValidate()
            begin
                if "Transaction Type" <> '' then
                    TestField("EU 3d-Party Trade", false);
            end;
        }
    }

    trigger OnAfterInsert()
    var
        IntrastatReportHeader: Record "Intrastat Report Header";
    begin
        IntrastatReportHeader.Get(Rec."Intrastat No.");

        if "Statistics Period" = '' then
            "Statistics Period" := IntrastatReportHeader."Statistics Period"
        else
            if ("Statistics Period" < IntrastatReportHeader."Statistics Period") and IntrastatReportHeader."Corrective Entry" then begin
                "Reference Period" := "Statistics Period";
                "Statistics Period" := IntrastatReportHeader."Statistics Period";
            end;

        if "Entry/Exit Point" <> '' then
            Validate("Entry/Exit Point");

        if ("Corrected Intrastat Report No." <> '') or ("Corrected Document No." <> '') then
            IntrastatReportHeader.CheckEUServAndCorrection(IntrastatReportHeader."No.", false, true);

        Modify();
    end;

    local procedure CheckIndirectCost()
    var
        EntryExitPoint: Record "Entry/Exit Point";
    begin
        if EntryExitPoint.Get("Entry/Exit Point") then;
        if EntryExitPoint."Reduce Statistical Value" then
            "Statistical Value" := Amount - "Indirect Cost"
        else
            "Statistical Value" := Amount + "Indirect Cost";
    end;

    var
        IntrastatReportMgtIT: Codeunit "Intrastat Report Management IT";
}