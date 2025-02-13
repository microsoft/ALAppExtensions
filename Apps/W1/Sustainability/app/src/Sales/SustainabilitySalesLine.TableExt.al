namespace Microsoft.Sustainability.Sales;

using Microsoft.Inventory.Item;
using Microsoft.Projects.Resources.Resource;
using Microsoft.Sustainability.Account;
using Microsoft.Sales.Document;
using Microsoft.Sustainability.Setup;

tableextension 6235 "Sustainability Sales Line" extends "Sales Line"
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
                Rec.TestStatusOpen();
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
        field(6216; "Posted Total CO2e"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Posted Total CO2e';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }

    procedure UpdateSustainabilityEmission(var SalesLine: Record "Sales Line")
    begin
        SalesLine."Total CO2e" := SalesLine."CO2e per Unit" * SalesLine."Qty. per Unit of Measure" * SalesLine.Quantity;
    end;

    procedure UpdateEmissionPerUnit(var SalesLine: Record "Sales Line")
    var
        Denominator: Decimal;
    begin
        SalesLine."CO2e Per Unit" := 0;

        if (SalesLine."Qty. per Unit of Measure" = 0) or (SalesLine.Quantity = 0) then
            exit;

        Denominator := SalesLine."Qty. per Unit of Measure" * SalesLine.Quantity;
        if SalesLine."Total CO2e" <> 0 then
            SalesLine."CO2e per Unit" := SalesLine."Total CO2e" / Denominator;
    end;

    local procedure ClearEmissionInformation(var SalesLine: Record "Sales Line")
    begin
        SalesLine.Validate("CO2e per Unit", 0);
    end;

    local procedure ValidateEmissionPrerequisite(SalesLine: Record "Sales Line"; CurrentFieldNo: Integer)
    var
        SustAccountCategory: Record "Sustain. Account Category";
    begin
        case CurrentFieldNo of
            SalesLine.FieldNo("CO2e per Unit"),
            SalesLine.FieldNo("Total CO2e"):
                begin
                    SalesLine.TestStatusOpen();
                    SalesLine.TestField("Sust. Account No.");
                end;
            SalesLine.FieldNo("Sust. Account No."),
            SalesLine.FieldNo("Sust. Account Category"),
            SalesLine.FieldNo("Sust. Account Subcategory"),
            SalesLine.FieldNo("Sust. Account Name"):
                begin
                    SalesLine.TestField("No.");
                    if not (SalesLine.Type in [SalesLine.Type::Item, SalesLine.Type::"G/L Account", SalesLine.Type::Resource]) then
                        Error(InvalidTypeForSustErr, SalesLine.Type::Item, SalesLine.Type::"G/L Account", SalesLine.Type::Resource);

                    if SustAccountCategory.Get(SalesLine."Sust. Account Category") then
                        if SustAccountCategory."Water Intensity" or SustAccountCategory."Waste Intensity" or SustAccountCategory."Discharged Into Water" then
                            Error(NotAllowedToUseSustAccountForWaterOrWasteErr, SalesLine."Sust. Account No.");
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
        InvalidTypeForSustErr: Label 'Sustainability is only applicable for Type: %1 , %2 and %3.', Comment = '%1 - Sales Line Type Item, %2 - Sales Line Type G/L Account, %3 - Sales Line Type Resource';
        NotAllowedToUseSustAccountForWaterOrWasteErr: Label 'It is not allowed to use Sustainability Account %1 for water or waste in Sales document.', Comment = '%1 = Sust. Account No.';
}