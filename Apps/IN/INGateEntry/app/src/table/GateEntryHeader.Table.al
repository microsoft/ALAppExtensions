﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Warehouse.GateEntry;

using Microsoft.Foundation.NoSeries;
using Microsoft.Inventory.Location;
using Microsoft.Finance.TaxBase;
using Microsoft.Inventory.Setup;

table 18603 "Gate Entry Header"
{
    Caption = 'Gate Entry Header';
    DataCaptionFields = "No.";
    LookupPageID = "Gate Entry List";

    fields
    {
        field(1; "Entry Type"; Enum "Gate Entry Type")
        {
            Caption = 'Entry Type';
            DataClassification = CustomerContent;
        }
        field(2; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(3; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(4; "Document Date"; Date)
        {
            Caption = 'Document Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "Posting Date" := "Document Date";
            end;
        }
        field(5; "Document Time"; Time)
        {
            Caption = 'Document Time';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "Posting Time" := "Document Time";
            end;
        }
        field(7; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                PostingNoSeries: Record "Posting No. Series";
                Record: Variant;
            begin
                if Rec."Location Code" <> xRec."Location Code" then begin
                    Record := Rec;
                    PostingNoSeries.GetPostingNoSeriesCode(Record);
                    Rec := Record;
                end;
            end;
        }
        field(8; Description; Text[120])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(9; "Item Description"; Text[120])
        {
            Caption = 'Item Description';
            DataClassification = CustomerContent;
        }
        field(10; "LR/RR No."; Code[20])
        {
            Caption = 'LR/RR No.';
            DataClassification = CustomerContent;
        }
        field(11; "LR/RR Date"; Date)
        {
            Caption = 'LR/RR Date';
            DataClassification = CustomerContent;
        }
        field(12; "Vehicle No."; Code[20])
        {
            Caption = 'Vehicle No.';
            DataClassification = CustomerContent;
        }
        field(13; "Station From/To"; Code[20])
        {
            Caption = 'Station From/To';
            DataClassification = CustomerContent;
        }
        field(15; "Comment Exists"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = Exist("Gate Entry Comment Line" where("Gate Entry Type" = field("Entry Type"), "No." = field("No.")));
            Caption = 'Comment Exists';
        }
        field(16; "Posting No. Series"; Code[20])
        {
            Caption = 'Posting No. Series';
            TableRelation = "No. Series";
            DataClassification = EndUserIdentifiableInformation;
        }
        field(17; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(18; "Posting Time"; Time)
        {
            Caption = 'Posting Time';
            DataClassification = CustomerContent;
        }
        field(19; "Posting No."; Code[20])
        {
            Caption = 'Posting No.';
            DataClassification = CustomerContent;
        }
        field(20; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;

            trigger OnLookup()
            var
                GateEntryHandler: Codeunit "Gate Entry Handler";
            begin
                GateEntryHandler.LookupUserID("User ID");
            end;
        }
    }

    keys
    {
        key(Key1; "Entry Type", "No.")
        {
            Clustered = true;
        }
        key(Key2; "Location Code", "Posting Date", "No.")
        {
        }
    }

    trigger OnInsert()
    var
        NoSeries: Codeunit "No. Series";
#if not CLEAN24
        IsHandled: Boolean;
#endif
    begin
        "Document Date" := WorkDate();
        "Document Time" := Time;
        "Posting Date" := WorkDate();
        "Posting Time" := Time;
        "User ID" := UserId();

        InventorySetup.Get();

        case "Entry Type" of
            "Entry Type"::Inward:
                if "No." = '' then begin
                    InventorySetup.TestField("Inward Gate Entry Nos.");
#if not CLEAN24
                    IsHandled := false;
                    NoSeriesManagement.RaiseObsoleteOnBeforeInitSeries(InventorySetup."Inward Gate Entry Nos.", xRec."No. Series", "Posting Date", "No.", "No. Series", IsHandled);
                    if not IsHandled then begin
#endif
                        "No. Series" := InventorySetup."Inward Gate Entry Nos.";
                        if NoSeries.AreRelated("No. Series", xRec."No. Series") then
                            "No. Series" := xRec."No. Series";
                        "No." := NoSeries.GetNextNo("No. Series", "Posting Date");
#if not CLEAN24
                        NoSeriesManagement.RaiseObsoleteOnAfterInitSeries("No. Series", InventorySetup."Inward Gate Entry Nos.", "Posting Date", "No.");
                    end;
#endif
                end;
            "Entry Type"::Outward:
                if "No." = '' then begin
                    InventorySetup.TestField("Outward Gate Entry Nos.");
#if not CLEAN24
                    IsHandled := false;
                    NoSeriesManagement.RaiseObsoleteOnBeforeInitSeries(InventorySetup."Outward Gate Entry Nos.", xRec."No. Series", "Posting Date", "No.", "No. Series", IsHandled);
                    if not IsHandled then begin
#endif
                        "No. Series" := InventorySetup."Outward Gate Entry Nos.";
                        if NoSeries.AreRelated("No. Series", xRec."No. Series") then
                            "No. Series" := xRec."No. Series";
                        "No." := NoSeries.GetNextNo("No. Series", "Posting Date");
#if not CLEAN24
                        NoSeriesManagement.RaiseObsoleteOnAfterInitSeries("No. Series", InventorySetup."Outward Gate Entry Nos.", "Posting Date", "No.");
                    end;
#endif
                end;
        end;
    end;

    trigger OnDelete()
    var
        GateEntryLine: Record "Gate Entry Line";
        GateEntryCommentLine: Record "Gate Entry Comment Line";
    begin
        GateEntryLine.SetRange("Entry Type", "Entry Type");
        GateEntryLine.SetRange("Gate Entry No.", "No.");
        GateEntryLine.DeleteAll(true);

        GateEntryCommentLine.SetRange("Gate Entry Type", "Entry Type");
        GateEntryCommentLine.SetRange("No.", "No.");
        GateEntryCommentLine.DeleteAll(true);
    end;

    var
        InventorySetup: Record "Inventory Setup";
#if not CLEAN24
        NoSeriesManagement: Codeunit NoSeriesManagement;
#endif

    procedure AssistEdit(OldGateEntryHeader: Record "Gate Entry Header"): Boolean
    var
        NoSeries: Codeunit "No. Series";
    begin
        InventorySetup.Get();
        case "Entry Type" of
            "Entry Type"::Inward:
                begin
                    InventorySetup.TestField("Inward Gate Entry Nos.");
                    if NoSeries.LookupRelatedNoSeries(InventorySetup."Inward Gate Entry Nos.", OldGateEntryHeader."No. Series", "No. Series") then begin
                        "No." := NoSeries.GetNextNo("No. Series");
                        exit(true);
                    end;
                end;
            "Entry Type"::Outward:
                begin
                    InventorySetup.TestField("Outward Gate Entry Nos.");
                    if NoSeries.LookupRelatedNoSeries(InventorySetup."Outward Gate Entry Nos.", OldGateEntryHeader."No. Series", "No. Series") then begin
                        "No." := NoSeries.GetNextNo("No. Series");
                        exit(true);
                    end;
                end;
        end;
    end;
}
