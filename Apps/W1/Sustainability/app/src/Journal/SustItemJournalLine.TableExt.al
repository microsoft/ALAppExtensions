namespace Microsoft.Sustainability.Journal;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Journal;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Setup;

tableextension 6233 "Sust. Item Journal Line" extends "Item Journal Line"
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

                Rec.CreateDimFromDefaultDim(FieldNo(Rec."Sust. Account No."));
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
            end;
        }
        field(6213; "Sust. Account Subcategory"; Code[20])
        {
            Caption = 'Sustainability Account Subcategory';
            Editable = false;
            TableRelation = "Sustain. Account Subcategory".Code where("Category Code" = field("Sust. Account Category"));
            DataClassification = CustomerContent;
        }
        field(6214; "Emission CO2"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission CO2';
            DataClassification = CustomerContent;
        }
        field(6215; "Emission CH4"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission CH4';
            DataClassification = CustomerContent;
        }
        field(6216; "Emission N2O"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission N2O';
            DataClassification = CustomerContent;
        }
        field(6217; "CO2e per Unit"; Decimal)
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
        field(6218; "Total CO2e"; Decimal)
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

    procedure GetPostingSign(GHGCredit: Boolean): Integer
    var
        Sign: Integer;
    begin
        Sign := 1;

        case Rec."Entry Type" of
            Rec."Entry Type"::Consumption:
                if not GHGCredit then
                    Sign := -1;
            else
                if GHGCredit then
                    Sign := -1;
        end;

        exit(Sign);
    end;

    procedure IsGHGCreditLine(): Boolean
    var
        Item: Record Item;
    begin
        if Rec."Item No." = '' then
            exit(false);

        Item.Get(Rec."Item No.");

        exit(Item."GHG Credit");
    end;

    procedure UpdateSustainabilityEmission(var ItemJournalLine: Record "Item Journal Line")
    begin
        if (ItemJournalLine."Operation No." <> '') and
           (ItemJournalLine."No." <> '') and
           (ItemJournalLine."Unit Cost Calculation" = ItemJournalLine."Unit Cost Calculation"::Time)
        then
            ItemJournalLine."Total CO2e" := ItemJournalLine."CO2e per Unit" * GetTotalTimePerOperation(ItemJournalLine)
        else
            ItemJournalLine."Total CO2e" := ItemJournalLine."CO2e per Unit" * ItemJournalLine."Qty. per Unit of Measure" * ItemJournalLine.Quantity;
    end;

    local procedure GetTotalTimePerOperation(var ItemJournalLine: Record "Item Journal Line"): Decimal
    begin
        exit((ItemJournalLine."Run Time" + ItemJournalLine."Setup Time" + ItemJournalLine."Stop Time") * ItemJournalLine."Qty. per Cap. Unit of Measure");
    end;

    local procedure ClearEmissionInformation(var ItemJournalLine: Record "Item Journal Line")
    begin
        ItemJournalLine.Validate("CO2e per Unit", 0);
    end;

    local procedure UpdateEmissionPerUnit(var ItemJournalLine: Record "Item Journal Line")
    var
        Denominator: Decimal;
    begin
        ItemJournalLine."CO2e Per Unit" := 0;

        if (ItemJournalLine."Operation No." <> '') and
           (ItemJournalLine."No." <> '') and
           (ItemJournalLine."Unit Cost Calculation" = ItemJournalLine."Unit Cost Calculation"::Time)
        then begin
            UpdateEmissionPerUnitForOperation(ItemJournalLine);
            exit;
        end;

        if (ItemJournalLine."Qty. per Unit of Measure" = 0) or (ItemJournalLine.Quantity = 0) then
            exit;

        Denominator := ItemJournalLine."Qty. per Unit of Measure" * ItemJournalLine.Quantity;
        if ItemJournalLine."Total CO2e" <> 0 then
            ItemJournalLine."CO2e per Unit" := ItemJournalLine."Total CO2e" / Denominator;
    end;

    local procedure UpdateEmissionPerUnitForOperation(var ItemJournalLine: Record "Item Journal Line")
    var
        Denominator: Decimal;
    begin
        if (GetTotalTimePerOperation(ItemJournalLine) = 0) then
            exit;

        Denominator := GetTotalTimePerOperation(ItemJournalLine);
        if ItemJournalLine."Total CO2e" <> 0 then
            ItemJournalLine."CO2e per Unit" := ItemJournalLine."Total CO2e" / Denominator;
    end;

    local procedure ValidateEmissionPrerequisite(ItemJournalLine: Record "Item Journal Line"; CurrentFieldNo: Integer)
    begin
        case CurrentFieldNo of
            ItemJournalLine.FieldNo("CO2e per Unit"),
            ItemJournalLine.FieldNo("Total CO2e"):
                ItemJournalLine.TestField("Sust. Account No.");
            ItemJournalLine.FieldNo("Sust. Account No."),
            ItemJournalLine.FieldNo("Sust. Account Category"),
            ItemJournalLine.FieldNo("Sust. Account Subcategory"),
            ItemJournalLine.FieldNo("Sust. Account Name"):
                ItemJournalLine.TestField("Item No.");
        end;
    end;

    local procedure CopyFromSustainabilityAccount(var ItemJournalLine: Record "Item Journal Line")
    var
        SustainabilityAccount: Record "Sustainability Account";
    begin
        SustainabilityAccount.Get(ItemJournalLine."Sust. Account No.");
        SustainabilityAccount.CheckAccountReadyForPosting();
        SustainabilityAccount.TestField("Direct Posting", true);

        ItemJournalLine.Validate("Sust. Account Name", SustainabilityAccount.Name);
        ItemJournalLine.Validate("Sust. Account Category", SustainabilityAccount.Category);
        ItemJournalLine.Validate("Sust. Account Subcategory", SustainabilityAccount.Subcategory);
    end;

    var
        SustainabilitySetup: Record "Sustainability Setup";
}