namespace Microsoft.Finance.PowerBIReports;

using Microsoft.PowerBIReports;
using Microsoft.Foundation.AuditCodes;

codeunit 36954 "Finance Filter Helper"
{
    Access = Internal;

    procedure GenerateVLEReportDateFilter(): Text
    var
        PBISetup: Record "PowerBI Reports Setup";
        FilterRangeLbl: Label '%1..%2', Locked = true;
        FilterTxt: Text;
    begin
        Clear(FilterTxt);
        if PBISetup.Get() then begin
            if (PBISetup."Vend. Ledger Entry Start Date" = 0D) and (PBISetup."Vend. Ledger Entry End Date" = 0D) then
                exit('');
            FilterTxt := StrSubstNo(FilterRangeLbl, Format(PBISetup."Vend. Ledger Entry Start Date"), Format(PBISetup."Vend. Ledger Entry End Date"));
            exit(FilterTxt);
        end;

        exit('');
    end;

    procedure GenerateCLEReportDateFilter(): Text
    var
        PBISetup: Record "PowerBI Reports Setup";
        FilterRangeLbl: Label '%1..%2', Locked = true;
        FilterTxt: Text;
    begin
        Clear(FilterTxt);
        if PBISetup.Get() then begin
            if (PBISetup."Cust. Ledger Entry Start Date" = 0D) and (PBISetup."Cust. Ledger Entry End Date" = 0D) then
                exit('');
            FilterTxt := StrSubstNo(FilterRangeLbl, Format(PBISetup."Cust. Ledger Entry Start Date"), Format(PBISetup."Cust. Ledger Entry End Date"));
            exit(FilterTxt);
        end;

        exit('');
    end;

    procedure GenerateFinanceReportDateFilter(): Text
    var
        PBISetup: Record "PowerBI Reports Setup";
        FilterRangeLbl: Label '%1..%2', Locked = true;
        FilterTxt: Text;
    begin
        Clear(FilterTxt);
        if PBISetup.Get() then begin
            if (PBISetup."Finance Start Date" = 0D) and (PBISetup."Finance End Date" = 0D) then
                exit('');
            FilterTxt := StrSubstNo(FilterRangeLbl, Format(PBISetup."Finance Start Date"), Format(PBISetup."Finance End Date"));
            exit(FilterTxt);
        end;

        exit('');
    end;

    procedure GenerateFinanceReportSourceCodeFilter(): Code[10]
    var
        SourceCodeSetup: Record "Source Code Setup";
    begin
        SourceCodeSetup.Get();
        SourceCodeSetup.TestField("Close Income Statement");
        exit(SourceCodeSetup."Close Income Statement");
    end;
}