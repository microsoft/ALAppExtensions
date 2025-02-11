namespace Microsoft.Sustainability.Transfer;

using Microsoft.Inventory.Transfer;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Setup;

tableextension 6250 "Sust. Transfer Line" extends "Transfer Line"
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
        field(6216; "Posted Shipped Total CO2e"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Posted Shipped Total CO2e';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }

    procedure UpdateSustainabilityEmission(var TransferLine: Record "Transfer Line")
    begin
        TransferLine."Total CO2e" := TransferLine."CO2e per Unit" * TransferLine."Qty. per Unit of Measure" * TransferLine.Quantity;
    end;

    procedure UpdateEmissionPerUnit(var TransferLine: Record "Transfer Line")
    var
        Denominator: Decimal;
    begin
        TransferLine."CO2e Per Unit" := 0;

        if (TransferLine."Qty. per Unit of Measure" = 0) or (TransferLine.Quantity = 0) then
            exit;

        Denominator := TransferLine."Qty. per Unit of Measure" * TransferLine.Quantity;
        if TransferLine."Total CO2e" <> 0 then
            TransferLine."CO2e per Unit" := TransferLine."Total CO2e" / Denominator;
    end;

    local procedure ClearEmissionInformation(var TransferLine: Record "Transfer Line")
    begin
        TransferLine.Validate("CO2e per Unit", 0);
    end;

    local procedure ValidateEmissionPrerequisite(TransferLine: Record "Transfer Line"; CurrentFieldNo: Integer)
    var
        SustAccountCategory: Record "Sustain. Account Category";
    begin
        case CurrentFieldNo of
            TransferLine.FieldNo("CO2e per Unit"),
            TransferLine.FieldNo("Total CO2e"):
                TransferLine.TestField("Sust. Account No.");
            TransferLine.FieldNo("Sust. Account No."),
            TransferLine.FieldNo("Sust. Account Category"),
            TransferLine.FieldNo("Sust. Account Subcategory"),
            TransferLine.FieldNo("Sust. Account Name"):
                begin
                    TransferLine.TestField("Item No.");

                    if SustAccountCategory.Get(TransferLine."Sust. Account Category") then
                        if SustAccountCategory."Water Intensity" or SustAccountCategory."Waste Intensity" or SustAccountCategory."Discharged Into Water" then
                            Error(NotAllowedToUseSustAccountForWaterOrWasteErr, TransferLine."Sust. Account No.");
                end;
        end;
    end;

    local procedure CopyFromSustainabilityAccount(var TransferLine: Record "Transfer Line")
    var
        SustainabilityAccount: Record "Sustainability Account";
    begin
        SustainabilityAccount.Get(TransferLine."Sust. Account No.");
        SustainabilityAccount.CheckAccountReadyForPosting();
        SustainabilityAccount.TestField("Direct Posting", true);

        TransferLine.Validate("Sust. Account Name", SustainabilityAccount.Name);
        TransferLine.Validate("Sust. Account Category", SustainabilityAccount.Category);
        TransferLine.Validate("Sust. Account Subcategory", SustainabilityAccount.Subcategory);
    end;

    var
        SustainabilitySetup: Record "Sustainability Setup";
        NotAllowedToUseSustAccountForWaterOrWasteErr: Label 'It is not allowed to use Sustainability Account %1 for water or waste in Transfer document.', Comment = '%1 = Sust. Account No.';
}