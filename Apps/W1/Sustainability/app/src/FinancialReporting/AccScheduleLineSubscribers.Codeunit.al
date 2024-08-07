namespace Microsoft.Sustainability.FinancialReporting;

using Microsoft.Finance.FinancialReports;
using Microsoft.Sustainability.Account;

codeunit 6238 "Acc. Schedule Line Subscribers"
{
    [EventSubscriber(ObjectType::Table, Database::"Acc. Schedule Line", 'OnAfterLookupTotaling', '', false, false)]
    local procedure OnAfterLookupTotaling(var AccScheduleLine: Record "Acc. Schedule Line")
    var
        SustAccList: Page "Sustainability Account List";
    begin
        case AccScheduleLine."Totaling Type" of
            Enum::"Acc. Schedule Line Totaling Type"::"Sust. Accounts":
                begin
                    SustAccList.LookupMode(true);
                    if SustAccList.RunModal() = Action::LookupOK then
                        AccScheduleLine.Validate(Totaling, SustAccList.GetSelectionFilter());
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Acc. Schedule Line", 'OnAfterValidateEvent', 'Totaling', false, false)]
    local procedure OnAfterValidateTotalingEvent(var Rec: Record "Acc. Schedule Line")
    var
        SustAcc: Record "Sustainability Account";
    begin
        case Rec."Totaling Type" of
            Enum::"Acc. Schedule Line Totaling Type"::"Sust. Accounts":
                begin
                    SustAcc.SetFilter("No.", Rec.Totaling);
                    SustAcc.CalcFields("Net Change (CO2)", "Balance at Date (CO2)", "Balance (CO2)", "Net Change (CH4)", "Balance at Date (CH4)", "Balance (CH4)", "Net Change (N2O)", "Balance at Date (N2O)", "Balance (N2O)");
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::AccSchedManagement, 'OnAfterCalcCellValue', '', false, false)]
    local procedure OnAfterCalcCellValue(var sender: Codeunit AccSchedManagement; var AccSchedLine: Record "Acc. Schedule Line"; var ColumnLayout: Record "Column Layout"; var Result: Decimal; var SourceAccScheduleLine: Record "Acc. Schedule Line")
    var
        AccScheLineMgmtHelper: Codeunit "Acc. Sch. Line Mgmt. Helper";
    begin
        case AccSchedLine."Totaling Type" of
            Enum::"Acc. Schedule Line Totaling Type"::"Sust. Accounts":
                begin
                    AccScheLineMgmtHelper.SetAccShedManagement(sender);
                    AccScheLineMgmtHelper.GetCalcCellValueByTotalingType(AccSchedLine, ColumnLayout, Result, SourceAccScheduleLine);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::AccSchedManagement, 'OnDrillDownTotalingTypeElseCase', '', false, false)]
    local procedure OnDrillDownTotalingTypeElseCase(var sender: Codeunit AccSchedManagement; var AccSchedLine: Record "Acc. Schedule Line"; var TempColumnLayout: Record "Column Layout" temporary)
    var
        AccScheLineMgmtHelper: Codeunit "Acc. Sch. Line Mgmt. Helper";
    begin
        case AccSchedLine."Totaling Type" of
            Enum::"Acc. Schedule Line Totaling Type"::"Sust. Accounts":
                begin
                    AccScheLineMgmtHelper.SetAccShedManagement(sender);
                    AccScheLineMgmtHelper.DrillDownOnSustAccount(TempColumnLayout, AccSchedLine);
                end;
        end;
    end;
}