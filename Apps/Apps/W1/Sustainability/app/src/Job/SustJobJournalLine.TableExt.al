// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Job;

using Microsoft.Inventory.Item;
using Microsoft.Projects.Project.Journal;
using Microsoft.Projects.Resources.Resource;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Setup;

tableextension 6258 "Sust. Job Journal Line" extends "Job Journal Line"
{
    fields
    {
        field(6210; "Sust. Account No."; Code[20])
        {
            Caption = 'Sustainability Account No.';
            TableRelation = "Sustainability Account" where("Account Type" = const(Posting), Blocked = const(false));
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                SustainabilityAccount: Record "Sustainability Account";
            begin
                if Rec."Sust. Account No." <> xRec."Sust. Account No." then
                    ClearEmissionInformation(Rec);

                if Rec."Sust. Account No." = '' then begin
                    Rec.Validate("Sust. Account Category", '');
                    "Sust. Account Name" := '';
                end else begin
                    ValidateEmissionPrerequisite(Rec, Rec.FieldNo("Sust. Account No."));

                    SustainabilityAccount.Get(Rec."Sust. Account No.");
                    SustainabilityAccount.CheckAccountReadyForPosting();
                    SustainabilityAccount.TestField("Direct Posting", true);

                    Rec.Validate("Sust. Account Name", SustainabilityAccount.Name);
                    Rec.Validate("Sust. Account Category", SustainabilityAccount.Category);
                    Rec.Validate("Sust. Account Subcategory", SustainabilityAccount.Subcategory);

                    UpdateCO2eInformation();
                end;

                CreateDimFromDefaultDim(FieldNo(Rec."Sust. Account No."));
            end;
        }
        field(6211; "Sust. Account Name"; Text[100])
        {
            Caption = 'Sustainability Account Name';
            DataClassification = CustomerContent;
        }
        field(6212; "Sust. Account Category"; Code[20])
        {
            Caption = 'Sustainability Account Category';
            Editable = false;
            TableRelation = "Sustain. Account Category";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Sust. Account Category" <> '' then
                    ValidateEmissionPrerequisite(Rec, Rec.FieldNo("Sust. Account Category"))
                else
                    Rec.Validate("Sust. Account Subcategory", '');

                if "Sust. Account Category" <> xRec."Sust. Account Category" then
                    Rec.Validate("Shortcut Dimension 1 Code", '');
            end;
        }
        field(6213; "Sust. Account Subcategory"; Code[20])
        {
            Caption = 'Sustainability Account Subcategory';
            Editable = false;
            TableRelation = "Sustain. Account Subcategory".Code where("Category Code" = field("Sust. Account Category"));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Sust. Account Subcategory" <> '' then
                    ValidateEmissionPrerequisite(Rec, Rec.FieldNo("Sust. Account Subcategory"));
            end;
        }
        field(6214; "CO2e per Unit"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'CO2e per Unit';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."CO2e per Unit" <> 0 then
                    ValidateEmissionPrerequisite(Rec, Rec.FieldNo("CO2e per Unit"));

                UpdateSustainabilityEmission(Rec);
            end;
        }
        field(6215; "Total CO2e"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Total CO2e';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Total CO2e" <> 0 then
                    ValidateEmissionPrerequisite(Rec, Rec.FieldNo("Total CO2e"));

                UpdateEmissionPerUnit(Rec);
            end;
        }
    }

    procedure UpdateSustainabilityEmission(var JobJournalLine: Record "Job Journal Line")
    begin
        JobJournalLine."Total CO2e" := JobJournalLine."CO2e per Unit" * JobJournalLine."Qty. per Unit of Measure" * JobJournalLine.Quantity;
    end;

    procedure UpdateEmissionPerUnit(var JobJournalLine: Record "Job Journal Line")
    var
        Denominator: Decimal;
    begin
        JobJournalLine."CO2e Per Unit" := 0;

        if (JobJournalLine."Qty. per Unit of Measure" = 0) or (JobJournalLine.Quantity = 0) then
            exit;

        Denominator := JobJournalLine."Qty. per Unit of Measure" * JobJournalLine.Quantity;
        if JobJournalLine."Total CO2e" <> 0 then
            JobJournalLine."CO2e per Unit" := JobJournalLine."Total CO2e" / Denominator;
    end;

    procedure GetPostingSign(GHGCredit: Boolean): Integer
    var
        Sign: Integer;
    begin
        Sign := -1;

        if GHGCredit then
            Sign := 1;

        exit(Sign);
    end;

    procedure IsGHGCreditLine(): Boolean
    var
        Item: Record Item;
    begin
        if Rec.Type <> Rec.Type::Item then
            exit(false);

        if Rec."No." = '' then
            exit(false);

        Item.Get(Rec."No.");

        exit(Item."GHG Credit");
    end;

    local procedure ClearEmissionInformation(var JobJournalLine: Record "Job Journal Line")
    begin
        JobJournalLine.Validate("CO2e per Unit", 0);
    end;

    local procedure ValidateEmissionPrerequisite(JobJournalLine: Record "Job Journal Line"; CurrentFieldNo: Integer)
    var
        SustAccountCategory: Record "Sustain. Account Category";
    begin
        case CurrentFieldNo of
            JobJournalLine.FieldNo("CO2e per Unit"),
            JobJournalLine.FieldNo("Total CO2e"):
                JobJournalLine.TestField("Sust. Account No.");
            JobJournalLine.FieldNo("Sust. Account No."),
            JobJournalLine.FieldNo("Sust. Account Category"),
            JobJournalLine.FieldNo("Sust. Account Subcategory"),
            JobJournalLine.FieldNo("Sust. Account Name"):
                begin
                    JobJournalLine.TestField("No.");

                    if SustAccountCategory.Get(JobJournalLine."Sust. Account Category") then
                        if SustAccountCategory."Water Intensity" or SustAccountCategory."Waste Intensity" or SustAccountCategory."Discharged Into Water" then
                            Error(NotAllowedToUseSustAccountForWaterOrWasteErr, JobJournalLine."Sust. Account No.");
                end;
        end;
    end;

    local procedure UpdateCO2eInformation()
    var
        Item: Record Item;
        Resource: Record Resource;
    begin
        case Rec.Type of
            Rec.Type::Item:
                begin
                    Item.Get(Rec."No.");
                    Rec.Validate("CO2e per Unit", Item."CO2e per Unit");
                end;
            Rec.Type::Resource:
                begin
                    Resource.Get(Rec."No.");
                    Rec.Validate("CO2e per Unit", Resource."CO2e per Unit");
                end;
        end;
    end;

    var
        SustainabilitySetup: Record "Sustainability Setup";
        NotAllowedToUseSustAccountForWaterOrWasteErr: Label 'It is not allowed to use Sustainability Account %1 for water or waste in Project document.', Comment = '%1 = Sust. Account No.';
}