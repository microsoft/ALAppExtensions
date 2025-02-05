namespace Microsoft.Sustainability.Manufacturing;

using Microsoft.Inventory.Item;
using Microsoft.Manufacturing.Document;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Setup;

tableextension 6246 "Sust. Prod. Order Component" extends "Prod. Order Component"
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

                CreateDimFromDefaultDim();
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

    procedure UpdateSustainabilityEmission(var ProdOrderComponent: Record "Prod. Order Component")
    begin
        ProdOrderComponent."Total CO2e" := ProdOrderComponent."CO2e per Unit" * ProdOrderComponent."Qty. per Unit of Measure" * ProdOrderComponent."Expected Quantity";
    end;

    procedure UpdateEmissionPerUnit(var ProdOrderComponent: Record "Prod. Order Component")
    var
        Denominator: Decimal;
    begin
        ProdOrderComponent."CO2e Per Unit" := 0;

        if (ProdOrderComponent."Qty. per Unit of Measure" = 0) or (ProdOrderComponent."Expected Quantity" = 0) then
            exit;

        Denominator := ProdOrderComponent."Qty. per Unit of Measure" * ProdOrderComponent."Expected Quantity";
        if ProdOrderComponent."Total CO2e" <> 0 then
            ProdOrderComponent."CO2e per Unit" := ProdOrderComponent."Total CO2e" / Denominator;
    end;

    local procedure ClearEmissionInformation(var ProdOrderComponent: Record "Prod. Order Component")
    begin
        ProdOrderComponent.Validate("CO2e per Unit", 0);
    end;

    local procedure ValidateEmissionPrerequisite(ProdOrderComponent: Record "Prod. Order Component"; CurrentFieldNo: Integer)
    var
        SustAccountCategory: Record "Sustain. Account Category";
    begin
        case CurrentFieldNo of
            ProdOrderComponent.FieldNo("CO2e per Unit"),
            ProdOrderComponent.FieldNo("Total CO2e"):
                ProdOrderComponent.TestField("Sust. Account No.");
            ProdOrderComponent.FieldNo("Sust. Account No."),
            ProdOrderComponent.FieldNo("Sust. Account Category"),
            ProdOrderComponent.FieldNo("Sust. Account Subcategory"),
            ProdOrderComponent.FieldNo("Sust. Account Name"):
                begin
                    ProdOrderComponent.TestField("Item No.");

                    if SustAccountCategory.Get(ProdOrderComponent."Sust. Account Category") then
                        if SustAccountCategory."Water Intensity" or SustAccountCategory."Waste Intensity" or SustAccountCategory."Discharged Into Water" then
                            Error(NotAllowedToUseSustAccountForWaterOrWasteErr, ProdOrderComponent."Sust. Account No.");
                end;
        end;
    end;

    local procedure UpdateCO2eInformation()
    var
        Item: Record Item;
    begin
        if not Item.Get(Rec."Item No.") then
            exit;

        Rec.Validate("CO2e per Unit", Item."CO2e per Unit");
    end;

    local procedure CopyFromSustainabilityAccount(var ProdOrderComponent: Record "Prod. Order Component")
    var
        SustainabilityAccount: Record "Sustainability Account";
    begin
        SustainabilityAccount.Get(ProdOrderComponent."Sust. Account No.");
        SustainabilityAccount.CheckAccountReadyForPosting();
        SustainabilityAccount.TestField("Direct Posting", true);

        ProdOrderComponent.Validate("Sust. Account Name", SustainabilityAccount.Name);
        ProdOrderComponent.Validate("Sust. Account Category", SustainabilityAccount.Category);
        ProdOrderComponent.Validate("Sust. Account Subcategory", SustainabilityAccount.Subcategory);
    end;

    var
        SustainabilitySetup: Record "Sustainability Setup";
        NotAllowedToUseSustAccountForWaterOrWasteErr: Label 'It is not allowed to use Sustainability Account %1 for water or waste in Production document.', Comment = '%1 = Sust. Account No.';
}