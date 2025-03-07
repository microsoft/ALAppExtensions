namespace Microsoft.Sustainability.PowerBIReports;

using Microsoft.PowerBIReports;

codeunit 37067 "PBI Sustain. Filter Helper"
{
    Access = Internal;
    procedure GenerateSustainabilityReportDateFilter(): Text
    var
        PBISetup: Record "PowerBI Reports Setup";
        FilterRangeLbl: Label '%1..%2', Locked = true;
        RelativeFilterLbl: Label '%1..', Locked = true;
        FilterTxt: Text;
    begin
        if PBISetup.Get() then
            case PBISetup."Sustainability Load Date Type" of
                PBISetup."Sustainability Load Date Type"::"Start/End Date":
                    begin
                        PBISetup.TestField("Sustainability Start Date");
                        FilterTxt := StrSubstNo(FilterRangeLbl, Format(PBISetup."Sustainability Start Date"), Format(PBISetup."Sustainability End Date"));
                        exit(FilterTxt);
                    end;
                PBISetup."Sustainability Load Date Type"::"Relative Date":
                    begin
                        PBISetup.TestField("Sustainability Date Formula");
                        FilterTxt := StrSubstNo(RelativeFilterLbl, Format(CalcDate(PBISetup."Sustainability Date Formula")));
                        exit(FilterTxt);
                    end;
                PBISetup."Sustainability Load Date Type"::" ":
                    exit('');
            end;
        exit('');
    end;
}