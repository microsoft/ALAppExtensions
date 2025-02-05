namespace Microsoft.Sustainability.Journal;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Sustainability.Setup;

pageextension 6224 "Sust. General Journal" extends "General Journal"
{
    layout
    {
        addafter("Bal. Account No.")
        {
            field("Sust. Account No."; Rec."Sust. Account No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the value of the Sustainability Account No. field.';
            }
            field("Total Emission CO2"; Rec."Total Emission CO2")
            {
                ApplicationArea = Basic, Suite;
                CaptionClass = GetCaptionClass(Rec.FieldNo("Total Emission CO2"));
                ToolTip = 'Specifies the value of the Total Emission CO2 field.';
            }
            field("Total Emission CH4"; Rec."Total Emission CH4")
            {
                ApplicationArea = Basic, Suite;
                CaptionClass = GetCaptionClass(Rec.FieldNo("Total Emission CH4"));
                ToolTip = 'Specifies the value of the Total Emission CH4 field.';
            }
            field("Total Emission N2O"; Rec."Total Emission N2O")
            {
                ApplicationArea = Basic, Suite;
                CaptionClass = GetCaptionClass(Rec.FieldNo("Total Emission N2O"));
                ToolTip = 'Specifies the value of the Total Emission N2O field.';
            }
        }
    }

    var
        SustainabilitySetup: Record "Sustainability Setup";
        TotalEmissionCaptionTxt: Label '%1 (%2)', Comment = '%1 = Total Emission Field , %2 = Emission Unit of Measure Code';

    local procedure GetCaptionClass(FieldNo: Integer): Text
    begin
        SustainabilitySetup.GetRecordOnce();
        if SustainabilitySetup."Emission Unit of Measure Code" = '' then
            exit;

        case FieldNo of
            Rec.FieldNo("Total Emission CO2"):
                exit(StrSubstNo(TotalEmissionCaptionTxt, Rec.FieldCaption("Total Emission CO2"), SustainabilitySetup."Emission Unit of Measure Code"));
            Rec.FieldNo("Total Emission CH4"):
                exit(StrSubstNo(TotalEmissionCaptionTxt, Rec.FieldCaption("Total Emission CH4"), SustainabilitySetup."Emission Unit of Measure Code"));
            Rec.FieldNo("Total Emission N2O"):
                exit(StrSubstNo(TotalEmissionCaptionTxt, Rec.FieldCaption("Total Emission N2O"), SustainabilitySetup."Emission Unit of Measure Code"));
        end;
    end;

}