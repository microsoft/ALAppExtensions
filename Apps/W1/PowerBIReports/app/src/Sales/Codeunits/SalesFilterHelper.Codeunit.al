namespace Microsoft.Sales.PowerBIReports;

using Microsoft.PowerBIReports;

codeunit 36960 "Sales Filter Helper"
{
    Access = Internal;

    procedure GenerateItemSalesReportDateFilter(): Text
    var
        PBISetup: Record "PowerBI Reports Setup";
        FilterRangeLbl: Label '%1..%2', Locked = true;
        RelativeFilterLbl: Label '%1..', Locked = true;
        FilterTxt: Text;
    begin
        Clear(FilterTxt);
        if PBISetup.Get() then
            case PBISetup."Item Sales Load Date Type" of
                PBISetup."Item Sales Load Date Type"::"Start/End Date":
                    begin
                        PBISetup.TestField("Item Sales Start Date");
                        FilterTxt := StrSubstNo(FilterRangeLbl, Format(PBISetup."Item Sales Start Date"), Format(PBISetup."Item Sales End Date"));
                        exit(FilterTxt);
                    end;
                PBISetup."Item Sales Load Date Type"::"Relative Date":
                    begin
                        PBISetup.TestField("Item Sales Date Formula");
                        FilterTxt := StrSubstNo(RelativeFilterLbl, Format(CalcDate(PBISetup."Item Sales Date Formula")));
                        exit(FilterTxt);
                    end;
                PBISetup."Item Sales Load Date Type"::" ":

                    exit('');
            end;

        exit('');
    end;
}