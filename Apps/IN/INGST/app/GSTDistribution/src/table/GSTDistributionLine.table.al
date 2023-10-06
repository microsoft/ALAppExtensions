// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Distribution;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.GST.Base;
using Microsoft.Inventory.Location;

table 18204 "GST Distribution Line"
{
    Caption = 'GST Distribution Line';

    fields
    {
        field(1; "Distribution No."; Code[20])
        {
            Caption = 'Distribution No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(6; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(17; "From GSTIN No."; Code[20])
        {
            Caption = 'GSTIN No.';
            Editable = false;
            TableRelation = "GST Registration Nos." where("Input Service Distributor" = filter(true));
            DataClassification = CustomerContent;
        }
        field(19; "Rcpt. Credit Type"; Enum "GST Credit")
        {
            Caption = 'Rcpt. Credit Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ValidateRcptCreditType();
            end;
        }
        field(20; "From Location Code"; Code[10])
        {
            Caption = 'From Location Code';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(21; "To Location Code"; Code[10])
        {
            Caption = 'To Location Code';
            TableRelation = Location where("GST Input Service Distributor" = filter(false));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ValidateToLocationCode();
            end;
        }
        field(22; "To GSTIN No."; Code[20])
        {
            Caption = 'To GSTIN No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(23; "Distribution Jurisdiction"; Enum "GST Jurisdiction Type")
        {
            Caption = 'Distribution Jurisdiction';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(24; "Distribution %"; Decimal)
        {
            Caption = 'Distribution %';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ValidateDistributionPercent();
            end;
        }
        field(25; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            end;
        }
        field(26; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }
        field(27; "Distribution Amount"; Decimal)
        {
            Caption = 'Distribution Amount';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";
            DataClassification = SystemMetadata;

            trigger OnLookup()
            begin
                ShowDimensions();
            end;
        }
    }

    keys
    {
        key(Key1; "Distribution No.", "Line No.")
        {
            Clustered = true;
        }
    }

    var
        DimMgt: Codeunit DimensionManagement;
        SameToLocationErr: Label 'To Location Code: %1 and Rcpt. Credit Type: %2 already exists for Line No. %3.', Comment = '%1 = To Location Code, %2 = Rcpt. Credit Type, %3 = Line No.';
        DistPercentRangeErr: Label '%1 must be in between 0 and 100.', Comment = '%1 = Field Name';
        DistPercentTotalErr: Label 'Sum of %1 cannot be more than 100.', Comment = '%1 = Field Name';
        ChangeDistPerErr: Label 'You cannot change Distribution % for GST Distribution Reversal.';
        ChangeRcptCreditTypeErr: Label 'You cannot change Rcpt. Credit Type for GST Distribution Reversal.';
        ChangeToLocErr: Label 'You cannot change To Location Code for GST Distribution Reversal.';
        DistributionMsg: Label '%1,%2', Comment = '%1 =Distribution No., %2= Line No.';

    procedure ShowDimensions()
    begin
        TestField("Distribution No.");
        TestField("Line No.");
        "Dimension Set ID" :=
          DimMgt.EditDimensionSet("Dimension Set ID", StrSubstNo(DistributionMsg, "Distribution No.", "Line No."));
        DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");
    end;

    local procedure ValidateRcptCreditType()
    var
        GSTDistributionHeader: Record "GST Distribution Header";
        GSTDistributionLine: Record "GST Distribution Line";
    begin
        GSTDistributionHeader.Get("Distribution No.");
        if GSTDistributionHeader.Reversal and ("Rcpt. Credit Type" <> xRec."Rcpt. Credit Type") then
            Error(ChangeRcptCreditTypeErr);

        TestField("To Location Code");
        GSTDistributionLine.Reset();
        GSTDistributionLine.SetRange("Distribution No.", "Distribution No.");
        GSTDistributionLine.SetRange("To Location Code", "To Location Code");
        GSTDistributionLine.SetRange("Rcpt. Credit Type", "Rcpt. Credit Type");
        GSTDistributionLine.SetFilter("Line No.", '<>%1', "Line No.");
        if GSTDistributionLine.FindFirst() then
            Error(
                SameToLocationErr,
                "To Location Code",
                "Rcpt. Credit Type",
                GSTDistributionLine."Line No.");
    end;

    local procedure ValidateToLocationCode()
    var
        GSTDistHeader: Record "GST Distribution Header";
        Location: Record Location;
        Location2: Record Location;
    begin
        Clear("To GSTIN No.");
        GSTDistHeader.Get("Distribution No.");
        GSTDistHeader.TestField("From Location Code");
        GSTDistHeader.TestField("Posting Date");
        "From Location Code" := GSTDistHeader."From Location Code";
        "From GSTIN No." := GSTDistHeader."From GSTIN No.";
        "Posting Date" := GSTDistHeader."Posting Date";
        "Rcpt. Credit Type" := GSTDistHeader."Dist. Credit Type";
        Location.Get("From Location Code");
        if Location2.Get("To Location Code") then begin
            Location2.TestField("State Code");
            "To GSTIN No." := Location2."GST Registration No.";
            if Location."State Code" = Location2."State Code" then
                "Distribution Jurisdiction" := "Distribution Jurisdiction"::Intrastate
            else
                "Distribution Jurisdiction" := "Distribution Jurisdiction"::Interstate;
        end;

        if GSTDistHeader.Reversal and ("To Location Code" <> xRec."To Location Code") then
            Error(ChangeToLocErr);
    end;

    local procedure ValidateDistributionPercent()
    var
        GSTDistributionHeader: Record "GST Distribution Header";
        GSTDistributionLine: Record "GST Distribution Line";
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        TestField("To Location Code");
        GeneralLedgerSetup.Get();
        GSTDistributionHeader.Get("Distribution No.");
        GSTDistributionLine.SetRange("Distribution No.", "Distribution No.");
        GSTDistributionLine.SetFilter("Line No.", '<>%1', "Line No.");
        GSTDistributionLine.CalcSums("Distribution %");
        if GSTDistributionLine."Distribution %" + "Distribution %" > 100 then
            Error(DistPercentTotalErr, FieldCaption("Distribution %"));

        if ("Distribution %" < 0) or ("Distribution %" > 100) then
            Error(DistPercentRangeErr, FieldCaption("Distribution %"));

        if "Distribution %" <> 0 then
            "Distribution Amount" :=
              Round(
                  GSTDistributionHeader."Total Amout Applied for Dist." * "Distribution %" / 100,
                  GeneralLedgerSetup."Amount Rounding Precision")
        else
            "Distribution Amount" := 0;

        if GSTDistributionHeader.Reversal and ("Distribution %" <> xRec."Distribution %") then
            Error(ChangeDistPerErr);
    end;
}
