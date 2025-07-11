namespace Microsoft.Sustainability.Manufacturing;

using Microsoft.Manufacturing.MachineCenter;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Setup;

tableextension 6232 "Sust. Machine Center" extends "Machine Center"
{
    fields
    {
        field(6210; "Default Sust. Account"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Sustainability Account" where("Account Type" = const(Posting), Blocked = const(false));
            Caption = 'Default Sust. Account';

            trigger OnValidate()
            var
                SustainabilityAccount: Record "Sustainability Account";
            begin
                if Rec."Default Sust. Account" = '' then
                    ClearDefaultEmissionInformation(Rec)
                else begin
                    SustainabilityAccount.Get(Rec."Default Sust. Account");

                    SustainabilityAccount.CheckAccountReadyForPosting();
                    SustainabilityAccount.TestField("Direct Posting", true);
                end;
            end;
        }
        field(6211; "Default CO2 Emission"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Default CO2 Emission';
            CaptionClass = '102,10,1';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Default CO2 Emission" <> 0 then
                    Rec.TestField("Default Sust. Account");
            end;
        }
        field(6212; "Default CH4 Emission"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Default CH4 Emission';
            CaptionClass = '102,10,2';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Default CH4 Emission" <> 0 then
                    Rec.TestField("Default Sust. Account");
            end;
        }
        field(6213; "Default N2O Emission"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Default N2O Emission';
            CaptionClass = '102,10,3';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Default N2O Emission" <> 0 then
                    Rec.TestField("Default Sust. Account");
            end;
        }
        field(6214; "CO2e per Unit"; Decimal)
        {
            Editable = false;
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'CO2e per Unit';
            MinValue = 0;
            DataClassification = CustomerContent;
        }
        field(6215; "CO2e Last Date Modified"; Date)
        {
            Caption = 'CO2e Last Date Modified';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }

    var
        SustainabilitySetup: Record "Sustainability Setup";

    local procedure ClearDefaultEmissionInformation(var MachineCenter: Record "Machine Center")
    begin
        MachineCenter.Validate("Default N2O Emission", 0);
        MachineCenter.Validate("Default CH4 Emission", 0);
        MachineCenter.Validate("Default CO2 Emission", 0);
    end;
}