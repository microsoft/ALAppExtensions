// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Distribution;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GST.Base;
using Microsoft.Inventory.Location;

table 18208 "Posted GST Distribution Line"
{
    Caption = 'Posted GST Dist. Line';

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
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(17; "From GSTIN No."; Code[20])
        {
            Caption = 'GSTIN No.';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "GST Registration Nos." where("Input Service Distributor" = filter(true));
        }
        field(19; "Rcpt. GST Credit Type"; Enum "GST Credit")
        {
            Caption = 'Rcpt. GST Credit Type';
            DataClassification = CustomerContent;
        }
        field(20; "From Location Code"; Code[10])
        {
            Caption = 'From Location Code';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(21; "To Location Code"; Code[10])
        {
            Caption = 'To Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location where("GST Input Service Distributor" = filter(false));

            trigger OnValidate()
            begin
                ValidateToLocationCode();
            end;
        }
        field(22; "To GSTIN No."; Code[20])
        {
            Caption = 'To GSTIN No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(23; "Distribution Jurisdiction"; Enum "GST Jurisdiction Type")
        {
            Caption = 'Distribution Jurisdiction';
            DataClassification = CustomerContent;
        }
        field(24; "Distribution %"; Decimal)
        {
            Caption = 'Distribution %';
            DataClassification = CustomerContent;
        }
        field(25; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            end;
        }
        field(26; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            DataClassification = CustomerContent;
            Caption = 'Shortcut Dimension 2 Code';
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
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = "Dimension Set Entry";

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
        DistributionMsg: Label '%1,%2', Comment = '%1 =Distribution No., %2= Line No.';

    local procedure ShowDimensions()
    begin
        TestField("Distribution No.");
        TestField("Line No.");
        "Dimension Set ID" :=
          DimMgt.EditDimensionSet("Dimension Set ID", StrSubstNo(DistributionMsg, "Distribution No.", "Line No."));
        DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
    end;

    local procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");
    end;

    local procedure ValidateToLocationCode()
    var
        GSTDistHeader: Record "GST Distribution Header";
        Location: Record Location;
        Location2: Record Location;
    begin
        GSTDistHeader.Get("Distribution No.");
        "From Location Code" := GSTDistHeader."From Location Code";
        "From GSTIN No." := GSTDistHeader."From GSTIN No.";
        "Posting Date" := GSTDistHeader."Posting Date";
        Location.Get("From Location Code");
        if Location2.Get("To Location Code") then
            "To GSTIN No." := Location2."GST Registration No.";
        if Location."State Code" = Location2."State Code" then
            "Distribution Jurisdiction" := "Distribution Jurisdiction"::Intrastate
        else
            "Distribution Jurisdiction" := "Distribution Jurisdiction"::Interstate;
    end;
}
