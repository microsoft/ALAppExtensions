namespace Microsoft.Purchases.PowerBIReports;

using Microsoft.PowerBIReports;

codeunit 36958 "Purchases Filter Helper"
{
    Access = Internal;

    procedure GenerateItemPurchasesReportDateFilter(): Text
    var
        PBISetup: Record "PowerBI Reports Setup";
        FilterRangeLbl: Label '%1..%2', Locked = true;
        RelativeFilterLbl: Label '%1..', Locked = true;
        FilterTxt: Text;
    begin
        Clear(FilterTxt);
        if PBISetup.Get() then
            case PBISetup."Item Purch. Load Date Type" of
                PBISetup."Item Purch. Load Date Type"::"Start/End Date":
                    begin
                        PBISetup.TestField("Item Purch. Start Date");
                        FilterTxt := StrSubstNo(FilterRangeLbl, Format(PBISetup."Item Purch. Start Date"), Format(PBISetup."Item Purch. End Date"));
                        exit(FilterTxt);
                    end;
                PBISetup."Item Purch. Load Date Type"::"Relative Date":
                    begin
                        PBISetup.TestField("Item Purch. Date Formula");
                        FilterTxt := StrSubstNo(RelativeFilterLbl, Format(CalcDate(PBISetup."Item Purch. Date Formula")));
                        exit(FilterTxt);
                    end;
                PBISetup."Item Purch. Load Date Type"::" ":
                    exit('');
            end;

        exit('');
    end;
}