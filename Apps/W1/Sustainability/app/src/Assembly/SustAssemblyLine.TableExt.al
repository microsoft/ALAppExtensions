namespace Microsoft.Sustainability.Assembly;

using Microsoft.Assembly.Document;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Setup;
using Microsoft.Inventory.Item;

tableextension 6252 "Sust. Assembly Line" extends "Assembly Line"
{
    fields
    {
        field(6210; "Sust. Account No."; Code[20])
        {
            Caption = 'Sustainability Account No.';
            TableRelation = "Sustainability Account" where("Account Type" = const(Posting), Blocked = const(false));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Sust. Account No." <> xRec."Sust. Account No." then
                    ClearEmissionInformation(Rec);

                if Rec."Sust. Account No." = '' then begin
                    Rec.Validate("Sust. Account Category", '');
                    "Sust. Account Name" := '';
                end else begin
                    ValidateEmissionPrerequisite(Rec, Rec.FieldNo("Sust. Account No."));
                    CopyFromSustainabilityAccount(Rec);
                    UpdateCO2eInformation();
                end;
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
        field(6216; "Posted Total CO2e"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Posted Total CO2e';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }

    procedure UpdateSustainabilityEmission(var AssemblyLine: Record "Assembly Line")
    begin
        AssemblyLine."Total CO2e" := AssemblyLine."CO2e per Unit" * AssemblyLine."Qty. per Unit of Measure" * AssemblyLine.Quantity;
    end;

    procedure UpdateEmissionPerUnit(var AssemblyLine: Record "Assembly Line")
    var
        Denominator: Decimal;
    begin
        AssemblyLine."CO2e Per Unit" := 0;

        if (AssemblyLine."Qty. per Unit of Measure" = 0) or (AssemblyLine.Quantity = 0) then
            exit;

        Denominator := AssemblyLine."Qty. per Unit of Measure" * AssemblyLine.Quantity;
        if AssemblyLine."Total CO2e" <> 0 then
            AssemblyLine."CO2e per Unit" := AssemblyLine."Total CO2e" / Denominator;
    end;

    local procedure ClearEmissionInformation(var AssemblyLine: Record "Assembly Line")
    begin
        AssemblyLine.Validate("CO2e per Unit", 0);
    end;

    local procedure ValidateEmissionPrerequisite(AssemblyLine: Record "Assembly Line"; CurrentFieldNo: Integer)
    var
        SustAccountCategory: Record "Sustain. Account Category";
    begin
        case CurrentFieldNo of
            AssemblyLine.FieldNo("CO2e per Unit"),
            AssemblyLine.FieldNo("Total CO2e"):
                AssemblyLine.TestField("Sust. Account No.");
            AssemblyLine.FieldNo("Sust. Account No."),
            AssemblyLine.FieldNo("Sust. Account Category"),
            AssemblyLine.FieldNo("Sust. Account Subcategory"),
            AssemblyLine.FieldNo("Sust. Account Name"):
                begin
                    AssemblyLine.TestField("No.");

                    if SustAccountCategory.Get(AssemblyLine."Sust. Account Category") then
                        if SustAccountCategory."Water Intensity" or SustAccountCategory."Waste Intensity" or SustAccountCategory."Discharged Into Water" then
                            Error(NotAllowedToUseSustAccountForWaterOrWasteErr, AssemblyLine."Sust. Account No.");
                end;
        end;
    end;

    local procedure UpdateCO2eInformation()
    var
        Item: Record Item;
    begin
        if Rec.Type <> Rec.Type::Item then
            exit;

        if not Item.Get(Rec."No.") then
            exit;

        Rec.Validate("CO2e per Unit", Item."CO2e per Unit");
    end;

    local procedure CopyFromSustainabilityAccount(var AssemblyLine: Record "Assembly Line")
    var
        SustainabilityAccount: Record "Sustainability Account";
    begin
        SustainabilityAccount.Get(AssemblyLine."Sust. Account No.");
        SustainabilityAccount.CheckAccountReadyForPosting();
        SustainabilityAccount.TestField("Direct Posting", true);

        AssemblyLine.Validate("Sust. Account Name", SustainabilityAccount.Name);
        AssemblyLine.Validate("Sust. Account Category", SustainabilityAccount.Category);
        AssemblyLine.Validate("Sust. Account Subcategory", SustainabilityAccount.Subcategory);
    end;

    var
        SustainabilitySetup: Record "Sustainability Setup";
        NotAllowedToUseSustAccountForWaterOrWasteErr: Label 'It is not allowed to use Sustainability Account %1 for water or waste in Assembly document.', Comment = '%1 = Sust. Account No.';
}