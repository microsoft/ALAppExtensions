namespace Microsoft.Sustainability.Certificate;

using Microsoft.Inventory.Item;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Ledger;
using Microsoft.Sustainability.Posting;

report 6215 "Sust. Item Calculate CO2e"
{
    Caption = 'Calculate CO2e';
    ProcessingOnly = true;
    Permissions = tabledata Item = rm;

    dataset
    {
        dataitem(Item; Item)
        {
            RequestFilterFields = "No.";

            trigger OnAfterGetRecord()
            var
                Item1: Record Item;
                Counter: Integer;
                CommitCounter: Integer;
            begin
                Item1.CopyFilters(Item);
                if Item1.FindSet() then begin
                    OpenDialog(Item1, RecordCount);

                    repeat
                        UpdateCO2ePerUnit(Item1);
                        UpdateDialog(CommitCounter, Counter);

                        CommitRecord(CommitCounter);
                    until Item1.Next() = 0;

                    CloseDialog();
                end;

                ShowCompletionMsg(RecordCount, Counter, Item.TableCaption());
                CurrReport.Break();
            end;
        }
    }

    local procedure CommitRecord(var CommitCounter: Integer)
    begin
        if CommitCounter <> 1000 then
            exit;

        Commit();
        CommitCounter := 0;
    end;

    local procedure UpdateDialog(var CommitCounter: Integer; var Counter: Integer)
    begin
        CommitCounter += 1;

        if not GuiAllowed then
            exit;

        Counter += 1;
        Window.Update(1, Round(Counter / RecordCount * 10000, 1));
    end;

    local procedure OpenDialog(var Item: Record Item; var RecCount: Integer)
    begin
        if not GuiAllowed() then
            exit;

        RecCount := Item.Count();
        Window.Open(ProcessBarMsg);
    end;

    local procedure CloseDialog()
    begin
        if not GuiAllowed() then
            exit;

        Window.Close();
    end;

    local procedure ShowCompletionMsg(RecCount: Integer; Counter: Integer; TableCaption: Text)
    begin
        if not GuiAllowed() then
            exit;

        Message(StrSubstNo(UpdateCompleteMsg, Counter, RecCount, TableCaption));
    end;

    local procedure UpdateCO2ePerUnit(var NewItem: Record Item)
    var
        SustCostManagement: Codeunit SustCostManagement;
        CO2eEmission: Decimal;
        CarbonFee: Decimal;
    begin
        if ExistSustainabilityValueEntry(NewItem) then begin
            if not SustCostManagement.CalculateAverageCost(NewItem, CO2eEmission) then
                exit;
        end else
            SustainabilityPostMgt.UpdateCarbonFeeEmissionValues(
                "Emission Scope"::" ",
                WorkDate(),
                '',
                NewItem."Default CO2 Emission",
                NewItem."Default N2O Emission",
                NewItem."Default CH4 Emission",
                CO2eEmission,
                CarbonFee);

        NewItem.Validate("CO2e per Unit", CO2eEmission);
        NewItem.Validate("CO2e Last Date Modified", Today());
        NewItem.Modify(true);
    end;

    local procedure ExistSustainabilityValueEntry(Item: Record Item): Boolean
    var
        SustainabilityValueEntry: Record "Sustainability Value Entry";
    begin
        SustainabilityValueEntry.SetRange("Item No.", Item."No.");
        if not SustainabilityValueEntry.IsEmpty() then
            exit(true);
    end;

    var
        SustainabilityPostMgt: Codeunit "Sustainability Post Mgt";
        Window: Dialog;
        ProcessBarMsg: Label 'Processing: @1@@@@@@@', Comment = '1 - overall progress';
        UpdateCompleteMsg: Label 'CO2e per unit is updated on %1 out of %2 entries in %3.', Comment = '%1 - Records Updated, %2 - Total Record Count , %3 = Table Caption';
        RecordCount: Integer;
}