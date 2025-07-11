namespace Microsoft.Sustainability.Certificate;

using Microsoft.Projects.Resources.Resource;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Posting;

report 6217 "Sust. Resource Calculate CO2e"
{
    Caption = 'Calculate CO2e';
    ProcessingOnly = true;
    Permissions = tabledata Resource = rm;

    dataset
    {
        dataitem(Resource; Resource)
        {
            RequestFilterFields = "No.";

            trigger OnAfterGetRecord()
            var
                Resource1: Record Resource;
                Counter: Integer;
                CommitCounter: Integer;
            begin
                Resource1.CopyFilters(Resource);
                if Resource1.FindSet() then begin
                    OpenDialog(Resource1, RecordCount);

                    repeat
                        UpdateCO2ePerUnit(Resource1);
                        UpdateDialog(CommitCounter, Counter);

                        CommitRecord(CommitCounter);
                    until Resource1.Next() = 0;

                    CloseDialog();
                end;

                ShowCompletionMsg(RecordCount, Counter, Resource.TableCaption());
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

    local procedure OpenDialog(var Resource: Record Resource; var RecCount: Integer)
    begin
        if not GuiAllowed() then
            exit;

        RecCount := Resource.Count();
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

    local procedure UpdateCO2ePerUnit(var NewResource: Record Resource)
    var
        CO2eEmission: Decimal;
        CarbonFee: Decimal;
    begin
        SustainabilityPostMgt.UpdateCarbonFeeEmissionValues(
            "Emission Scope"::" ",
            WorkDate(),
            '',
            NewResource."Default CO2 Emission",
            NewResource."Default N2O Emission",
            NewResource."Default CH4 Emission",
            CO2eEmission,
            CarbonFee);

        NewResource.Validate("CO2e per Unit", CO2eEmission);
        NewResource.Validate("CO2e Last Date Modified", Today());
        NewResource.Modify(true);
    end;

    var
        SustainabilityPostMgt: Codeunit "Sustainability Post Mgt";
        Window: Dialog;
        ProcessBarMsg: Label 'Processing: @1@@@@@@@', Comment = '1 - overall progress';
        UpdateCompleteMsg: Label 'CO2e per unit is updated on %1 out of %2 entries in %3.', Comment = '%1 - Records Updated, %2 - Total Record Count , %3 = Table Caption';
        RecordCount: Integer;
}