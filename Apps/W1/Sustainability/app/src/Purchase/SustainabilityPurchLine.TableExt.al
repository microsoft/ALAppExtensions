namespace Microsoft.Sustainability.Purchase;

using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Setup;
using Microsoft.Purchases.Document;
using Microsoft.Inventory.Item;

tableextension 6211 "Sustainability Purch. Line" extends "Purchase Line"
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
                end;

                CreateDimFromDefaultDim(FieldNo(Rec."Sust. Account No."));

                if Rec.Type = Rec.Type::Item then
                    UpdateCarbonCreditInformation();
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
        field(6214; "Emission CO2 Per Unit"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission CO2 Per Unit';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Emission CO2 Per Unit" <> 0 then
                    ValidateEmissionPrerequisite(Rec, Rec.FieldNo("Emission CO2 Per Unit"));

                UpdateSustainabilityEmission(Rec);
            end;
        }
        field(6215; "Emission CH4 Per Unit"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission CH4 Per Unit';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Emission CH4 Per Unit" <> 0 then
                    ValidateEmissionPrerequisite(Rec, Rec.FieldNo("Emission CH4 Per Unit"));

                UpdateSustainabilityEmission(Rec);
            end;
        }
        field(6216; "Emission N2O Per Unit"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission N2O Per Unit';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Emission N2O Per Unit" <> 0 then
                    ValidateEmissionPrerequisite(Rec, Rec.FieldNo("Emission N2O Per Unit"));

                UpdateSustainabilityEmission(Rec);
            end;
        }
        field(6217; "Emission CO2"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission CO2';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Emission CO2" <> 0 then
                    ValidateEmissionPrerequisite(Rec, Rec.FieldNo("Emission CO2"));

                if CurrFieldNo <> Rec.FieldNo("Emission CH4 Per Unit") then
                    UpdateEmissionPerUnit(Rec);
            end;
        }
        field(6218; "Emission CH4"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission CH4';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Emission CH4" <> 0 then
                    ValidateEmissionPrerequisite(Rec, Rec.FieldNo("Emission CH4"));

                UpdateEmissionPerUnit(Rec);
            end;
        }
        field(6219; "Emission N2O"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission N2O';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Emission N2O" <> 0 then
                    ValidateEmissionPrerequisite(Rec, Rec.FieldNo("Emission N2O"));

                UpdateEmissionPerUnit(Rec);
            end;
        }
        field(6220; "Posted Emission CO2"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Posted Emission CO2';
            Editable = false;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Posted Emission CO2" <> 0 then
                    ValidateEmissionPrerequisite(Rec, Rec.FieldNo("Posted Emission CO2"));
            end;
        }
        field(6221; "Posted Emission CH4"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Posted Emission CH4';
            Editable = false;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Posted Emission CH4" <> 0 then
                    ValidateEmissionPrerequisite(Rec, Rec.FieldNo("Posted Emission CH4"));
            end;
        }
        field(6222; "Posted Emission N2O"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Posted Emission N2O';
            Editable = false;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Posted Emission N2O" <> 0 then
                    ValidateEmissionPrerequisite(Rec, Rec.FieldNo("Posted Emission N2O"));
            end;
        }
    }

    procedure UpdateSustainabilityEmission(var PurchLine: Record "Purchase Line")
    begin
        PurchLine."Emission CO2" := PurchLine."Emission CO2 Per Unit" * PurchLine."Qty. per Unit of Measure" * PurchLine."Qty. to Invoice";
        PurchLine."Emission CH4" := PurchLine."Emission CH4 Per Unit" * PurchLine."Qty. per Unit of Measure" * PurchLine."Qty. to Invoice";
        PurchLine."Emission N2O" := PurchLine."Emission N2O Per Unit" * PurchLine."Qty. per Unit of Measure" * PurchLine."Qty. to Invoice";
    end;

    procedure UpdateEmissionPerUnit(var PurchLine: Record "Purchase Line")
    var
        Denominator: Decimal;
    begin
        PurchLine."Emission CO2 Per Unit" := 0;
        PurchLine."Emission CH4 Per Unit" := 0;
        PurchLine."Emission N2O Per Unit" := 0;

        if (PurchLine."Qty. per Unit of Measure" = 0) or (PurchLine."Qty. to Invoice" = 0) then
            exit;

        Denominator := PurchLine."Qty. per Unit of Measure" * PurchLine."Qty. to Invoice";
        if PurchLine."Emission CO2" <> 0 then
            PurchLine."Emission CO2 Per Unit" := PurchLine."Emission CO2" / Denominator;

        if PurchLine."Emission CH4" <> 0 then
            PurchLine."Emission CH4 Per Unit" := PurchLine."Emission CH4" / Denominator;

        if PurchLine."Emission N2O" <> 0 then
            PurchLine."Emission N2O Per Unit" := PurchLine."Emission N2O" / Denominator;
    end;

    local procedure ClearEmissionInformation(var PurchLine: Record "Purchase Line")
    begin
        PurchLine.Validate("Emission CO2 Per Unit", 0);
        PurchLine.Validate("Emission CH4 Per Unit", 0);
        PurchLine.Validate("Emission N2O Per Unit", 0);
    end;

    local procedure ValidateEmissionPrerequisite(PurchaseLine: Record "Purchase Line"; CurrentFieldNo: Integer)
    var
        Item: Record Item;
        SustAccountCategory: Record "Sustain. Account Category";
    begin
        case CurrentFieldNo of
            PurchaseLine.FieldNo("Emission N2O"),
            PurchaseLine.FieldNo("Emission N2O Per Unit"),
            PurchaseLine.FieldNo("Emission CH4"),
            PurchaseLine.FieldNo("Emission CH4 Per Unit"):
                begin
                    PurchaseLine.TestField("Sust. Account No.");

                    if (PurchaseLine.Type = PurchaseLine.Type::Item) and (PurchaseLine."No." <> '') then begin
                        Item.Get(PurchaseLine."No.");
                        if Item."GHG Credit" then
                            Item.TestField("GHG Credit", false);
                    end;
                end;
            PurchaseLine.FieldNo("Emission CO2"),
            PurchaseLine.FieldNo("Emission CO2 Per Unit"):
                PurchaseLine.TestField("Sust. Account No.");
            PurchaseLine.FieldNo("Sust. Account No."),
            PurchaseLine.FieldNo("Sust. Account Category"),
            PurchaseLine.FieldNo("Sust. Account Subcategory"),
            PurchaseLine.FieldNo("Sust. Account Name"):
                begin
                    PurchaseLine.TestField("No.");
                    if not (PurchaseLine.Type in [PurchaseLine.Type::Item, PurchaseLine.Type::"G/L Account"]) then
                        Error(InvalidTypeForSustErr, PurchaseLine.Type::Item, PurchaseLine.Type::"G/L Account");

                    if SustAccountCategory.Get(PurchaseLine."Sust. Account Category") then
                        if SustAccountCategory."Water Intensity" or SustAccountCategory."Waste Intensity" or SustAccountCategory."Discharged Into Water" then
                            Error(NotAllowedToUseSustAccountForWaterOrWasteErr, PurchaseLine."Sust. Account No.");
                end;
        end;
    end;

    local procedure UpdateCarbonCreditInformation()
    var
        Item: Record Item;
    begin
        if not Item.Get(Rec."No.") then
            exit;

        if not Item."GHG Credit" then
            exit;

        Rec.Validate("Emission CO2 Per Unit", Item."Carbon Credit Per UOM");
    end;

    var
        SustainabilitySetup: Record "Sustainability Setup";
        InvalidTypeForSustErr: Label 'Sustainability is only applicable for Type: %1 or %2.', Comment = '%1 - Purchase Line Type Item, %2 - Purchase Line Type G/L Account';
        NotAllowedToUseSustAccountForWaterOrWasteErr: Label 'It is not allowed to use Sustainability Account %1 for water or waste in purchase document.', Comment = '%1 = Sust. Account No.';
}