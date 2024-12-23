namespace Microsoft.Sustainability.Assembly;

using Microsoft.Assembly.Document;
using Microsoft.Sustainability.Setup;
using Microsoft.Inventory.Item;
using Microsoft.Sustainability.Account;

tableextension 6251 "Sustainability Assembly Header" extends "Assembly Header"
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

        field(6217; "Expected Assembly Line Total CO2e"; Decimal)
        {
            AutoFormatType = 11;
            CalcFormula = sum("Assembly Line"."Total CO2e" where("Document Type" = field("Document Type"),
                                                                 "Document No." = field("No.")));
            Caption = 'Expected Assembly Line Total CO2e';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    procedure UpdateSustainabilityEmission(var AssemblyHeader: Record "Assembly Header")
    begin
        AssemblyHeader."Total CO2e" := AssemblyHeader."CO2e per Unit" * AssemblyHeader."Qty. per Unit of Measure" * AssemblyHeader.Quantity;
    end;

    procedure UpdateEmissionPerUnit(var AssemblyHeader: Record "Assembly Header")
    var
        Denominator: Decimal;
    begin
        AssemblyHeader."CO2e Per Unit" := 0;

        if (AssemblyHeader."Qty. per Unit of Measure" = 0) or (AssemblyHeader.Quantity = 0) then
            exit;

        Denominator := AssemblyHeader."Qty. per Unit of Measure" * AssemblyHeader.Quantity;
        if AssemblyHeader."Total CO2e" <> 0 then
            AssemblyHeader."CO2e per Unit" := AssemblyHeader."Total CO2e" / Denominator;
    end;

    local procedure ClearEmissionInformation(var AssemblyHeader: Record "Assembly Header")
    begin
        AssemblyHeader.Validate("CO2e per Unit", 0);
    end;

    local procedure ValidateEmissionPrerequisite(AssemblyHeader: Record "Assembly Header"; CurrentFieldNo: Integer)
    var
        SustAccountCategory: Record "Sustain. Account Category";
    begin
        case CurrentFieldNo of
            AssemblyHeader.FieldNo("CO2e per Unit"),
            AssemblyHeader.FieldNo("Total CO2e"):
                AssemblyHeader.TestField("Sust. Account No.");
            AssemblyHeader.FieldNo("Sust. Account No."),
            AssemblyHeader.FieldNo("Sust. Account Category"),
            AssemblyHeader.FieldNo("Sust. Account Subcategory"),
            AssemblyHeader.FieldNo("Sust. Account Name"):
                begin
                    AssemblyHeader.TestField("No.");

                    if SustAccountCategory.Get(AssemblyHeader."Sust. Account Category") then
                        if SustAccountCategory."Water Intensity" or SustAccountCategory."Waste Intensity" or SustAccountCategory."Discharged Into Water" then
                            Error(NotAllowedToUseSustAccountForWaterOrWasteErr, AssemblyHeader."Sust. Account No.");
                end;
        end;
    end;

    local procedure UpdateCO2eInformation()
    var
        Item: Record Item;
        CalcCO2ePerUnit: Decimal;
    begin
        if not Item.Get(Rec."Item No.") then
            exit;

        if ExistSustAssemblyLine(Rec) then begin
            Rec.CalcFields("Expected Assembly Line Total CO2e");
            CalcCO2ePerUnit := (Rec."Expected Assembly Line Total CO2e") / Rec.Quantity;

            Rec.Validate("CO2e per Unit", CalcCO2ePerUnit);
        end else
            Rec.Validate("CO2e per Unit", Item."CO2e per Unit");
    end;

    local procedure CopyFromSustainabilityAccount(var AssemblyHeader: Record "Assembly Header")
    var
        SustainabilityAccount: Record "Sustainability Account";
    begin
        SustainabilityAccount.Get(AssemblyHeader."Sust. Account No.");
        SustainabilityAccount.CheckAccountReadyForPosting();
        SustainabilityAccount.TestField("Direct Posting", true);

        AssemblyHeader.Validate("Sust. Account Name", SustainabilityAccount.Name);
        AssemblyHeader.Validate("Sust. Account Category", SustainabilityAccount.Category);
        AssemblyHeader.Validate("Sust. Account Subcategory", SustainabilityAccount.Subcategory);
    end;

    local procedure ExistSustAssemblyLine(AssemblyHeader: Record "Assembly Header"): Boolean
    var
        AssemblyLine: Record "Assembly Line";
    begin
        AssemblyLine.SetLoadFields("Document Type", "Document No.", "Sust. Account No.");
        AssemblyLine.SetRange("Document Type", AssemblyHeader."Document Type");
        AssemblyLine.SetRange("Document No.", AssemblyHeader."No.");
        AssemblyLine.SetFilter("Sust. Account No.", '<>%1', '');

        exit(not AssemblyLine.IsEmpty());
    end;

    var
        SustainabilitySetup: Record "Sustainability Setup";
        NotAllowedToUseSustAccountForWaterOrWasteErr: Label 'It is not allowed to use Sustainability Account %1 for water or waste in Assembly document.', Comment = '%1 = Sust. Account No.';
}