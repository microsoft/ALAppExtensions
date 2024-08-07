namespace Microsoft.Sustainability.FinancialReporting;

using Microsoft.Finance.Analysis;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Ledger;

codeunit 6236 "Analysis View Entry Subscriber"
{
    [EventSubscriber(ObjectType::Table, Database::"Analysis View Entry", 'OnLookupAccountNo', '', false, false)]
    local procedure OnLookupAccountNo(var AnalysisViewEntry: Record "Analysis View Entry"; var IsHandled: Boolean)
    var
        SustAccount: Record "Sustainability Account";
        SustAccountList: Page "Sustainability Account List";
    begin
        case AnalysisViewEntry."Account Source" of
            AnalysisViewEntry."Account Source"::"Sust. Account":
                begin
                    SustAccountList.LookupMode(true);
                    if SustAccountList.RunModal() = ACTION::LookupOK then begin
                        SustAccountList.GetRecord(SustAccount);
                        AnalysisViewEntry.Validate("Account No.", SustAccount."No.");
                    end;
                    IsHandled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Analysis View Entry", 'OnBeforeDrilldown', '', false, false)]
    local procedure OnBeforeDrilldown(var AnalysisViewEntry: Record "Analysis View Entry"; var IsHandled: Boolean)
    var
        TempSustLedgEntry: Record "Sustainability Ledger Entry" temporary;
        AnalysisViewEntryToSustEntries: Codeunit AnalysisViewEntryToSustEntries;
    begin
        if AnalysisViewEntry."Account Source" <> AnalysisViewEntry."Account Source"::"Sust. Account" then
            exit;

        IsHandled := true;
        TempSustLedgEntry.Reset();
        TempSustLedgEntry.DeleteAll();
        AnalysisViewEntryToSustEntries.GetSustLedgEntries(AnalysisViewEntry, TempSustLedgEntry);
        Page.RunModal(Page::"Sustainability Ledger Entries", TempSustLedgEntry);
    end;
}