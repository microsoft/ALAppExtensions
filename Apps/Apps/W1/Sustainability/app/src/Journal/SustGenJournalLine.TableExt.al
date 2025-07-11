namespace Microsoft.Sustainability.Journal;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Setup;

tableextension 6224 "Sust. Gen. Journal Line" extends "Gen. Journal Line"
{
    fields
    {
        field(6214; "Sust. Account No."; Code[20])
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
                end;

                Rec.CreateDimFromDefaultDim(FieldNo(Rec."Sust. Account No."));
            end;
        }
        field(6215; "Sust. Account Name"; Text[100])
        {
            Caption = 'Sustainability Account Name';
            DataClassification = CustomerContent;
        }
        field(6216; "Sust. Account Category"; Code[20])
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
        field(6217; "Sust. Account Subcategory"; Code[20])
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
        field(6218; "Total Emission CO2"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Total Emission CO2';
            CaptionClass = '102,12,1';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Total Emission CO2" <> 0 then
                    ValidateEmissionPrerequisite(Rec, Rec.FieldNo("Total Emission CO2"));
            end;
        }
        field(6219; "Total Emission CH4"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Total Emission CH4';
            CaptionClass = '102,12,2';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Total Emission CH4" <> 0 then
                    ValidateEmissionPrerequisite(Rec, Rec.FieldNo("Total Emission CH4"));
            end;
        }
        field(6220; "Total Emission N2O"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Total Emission N2O';
            CaptionClass = '102,12,3';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Total Emission N2O" <> 0 then
                    ValidateEmissionPrerequisite(Rec, Rec.FieldNo("Total Emission N2O"));
            end;
        }
        field(6221; "CO2e per Unit"; Decimal)
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
        field(6222; "Total CO2e"; Decimal)
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

    local procedure ClearEmissionInformation(var GenJournalLine: Record "Gen. Journal Line")
    begin
        GenJournalLine.Validate("Total Emission CO2", 0);
        GenJournalLine.Validate("Total Emission CH4", 0);
        GenJournalLine.Validate("Total Emission N2O", 0);
        GenJournalLine.Validate("CO2e per Unit", 0);
    end;

    local procedure ValidateEmissionPrerequisite(GenJournalLine: Record "Gen. Journal Line"; CurrentFieldNo: Integer)
    begin
        case CurrentFieldNo of
            GenJournalLine.FieldNo("Total Emission N2O"),
            GenJournalLine.FieldNo("Total Emission CH4"),
            GenJournalLine.FieldNo("Total Emission CO2"):
                GenJournalLine.TestField("Sust. Account No.");
            GenJournalLine.FieldNo("CO2e per Unit"),
            GenJournalLine.FieldNo("Total CO2e"):
                begin
                    GenJournalLine.TestField("Job No.");
                    GenJournalLine.TestField("Sust. Account No.");
                end;
            GenJournalLine.FieldNo("Sust. Account No."):
                CheckSustGenJournalLine(GenJournalLine);
        end;
    end;

    procedure CheckSustGenJournalLine(GenJournalLine: Record "Gen. Journal Line")
    begin
        if (GenJournalLine."Document Type" in [GenJournalLine."Document Type"::" ", GenJournalLine."Document Type"::Invoice, GenJournalLine."Document Type"::"Credit Memo"]) then
            GenJournalLine.TestField("Sust. Account No.")
        else
            Error(InvalidDocumentTypeErr, GenJournalLine."Journal Template Name", GenJournalLine."Journal Batch Name", GenJournalLine."Line No.");
    end;

    procedure UpdateSustainabilityEmission(var GenJournalLine: Record "Gen. Journal Line")
    begin
        GenJournalLine."Total CO2e" := GenJournalLine."CO2e per Unit" * GenJournalLine."Job Quantity";
    end;

    procedure UpdateEmissionPerUnit(var GenJournalLine: Record "Gen. Journal Line")
    var
        Denominator: Decimal;
    begin
        GenJournalLine."CO2e Per Unit" := 0;

        if (GenJournalLine."Job Quantity" = 0) then
            exit;

        Denominator := GenJournalLine."Job Quantity";
        if GenJournalLine."Total CO2e" <> 0 then
            GenJournalLine."CO2e per Unit" := GenJournalLine."Total CO2e" / Denominator;
    end;

    var
        SustainabilitySetup: Record "Sustainability Setup";
        InvalidDocumentTypeErr: Label 'You can only specify Sustainability Accounts for lines of type blank, invoice and credit memo for Journal Template Name=%1 ,Journal Batch Name=%2 ,Line No.=%3.', Comment = '%1 = Journal Template Name , %2 = Journal Batch Name , %3 = Line No.';
}