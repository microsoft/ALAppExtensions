namespace Microsoft.Manufacturing.PowerBIReports;

using Microsoft.PowerBIReports;

codeunit 36955 "Manuf. Filter Helper"
{
    Access = Internal;

    procedure GenerateManufacturingReportDateFilter(): Text
    var
        PBISetup: Record "PowerBI Reports Setup";
        FilterRangeLbl: Label '%1..%2', Locked = true;
        RelativeFilterLbl: Label '%1..', Locked = true;
        FilterTxt: Text;
    begin
        Clear(FilterTxt);
        if PBISetup.Get() then
            case PBISetup."Manufacturing Load Date Type" of
                PBISetup."Manufacturing Load Date Type"::"Start/End Date":
                    begin
                        PBISetup.TestField("Manufacturing Start Date");
                        FilterTxt := StrSubstNo(FilterRangeLbl, Format(PBISetup."Manufacturing Start Date"), Format(PBISetup."Manufacturing End Date"));
                        exit(FilterTxt);
                    end;
                PBISetup."Manufacturing Load Date Type"::"Relative Date":
                    begin
                        PBISetup.TestField("Manufacturing Date Formula");
                        FilterTxt := StrSubstNo(RelativeFilterLbl, Format(CalcDate(PBISetup."Manufacturing Date Formula")));
                        exit(FilterTxt);
                    end;
                PBISetup."Manufacturing Load Date Type"::" ":

                    exit('');
            end;

        exit('');
    end;

    procedure GenerateManufacturingReportDateTimeFilter(): Text
    var
        PBISetup: Record "PowerBI Reports Setup";
        FilterRangeLbl: Label '%1..%2', Locked = true;
        RelativeFilterLbl: Label '%1..', Locked = true;
        FilterTxt: Text;
    begin
        Clear(FilterTxt);
        if PBISetup.Get() then
            case PBISetup."Manufacturing Load Date Type" of
                PBISetup."Manufacturing Load Date Type"::"Start/End Date":
                    begin
                        PBISetup.TestField("Manufacturing Start Date");
                        FilterTxt := StrSubstNo(FilterRangeLbl, Format(CreateDateTime(PBISetup."Manufacturing Start Date", 0T)), Format(CreateDateTime(PBISetup."Manufacturing End Date", 0T)));
                        exit(FilterTxt);
                    end;
                PBISetup."Manufacturing Load Date Type"::"Relative Date":
                    begin
                        PBISetup.TestField("Manufacturing Date Formula");
                        FilterTxt := StrSubstNo(RelativeFilterLbl, Format(CreateDateTime(CalcDate(PBISetup."Manufacturing Date Formula"), 0T)));
                        exit(FilterTxt);
                    end;
                PBISetup."Manufacturing Load Date Type"::" ":

                    exit('');
            end;

        exit('');
    end;
}