namespace Microsoft.Sustainability.Manufacturing;

using Microsoft.Manufacturing.MachineCenter;
using Microsoft.Manufacturing.WorkCenter;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Posting;

report 6214 "Sust. Calculate CO2e"
{
    Caption = 'Calculate CO2e';
    UsageCategory = Tasks;
    ApplicationArea = Basic, Suite;
    ProcessingOnly = true;
    Permissions = tabledata "Work Center" = rm, tabledata "Machine Center" = rm;

    dataset
    {
        dataitem("Work Center"; "Work Center")
        {
            RequestFilterFields = "No.";

            trigger OnPreDataItem()
            begin
                if Type = Type::"Machine Center" then
                    CurrReport.Break();
            end;

            trigger OnAfterGetRecord()
            var
                WorkCenter: Record "Work Center";
                Counter: Integer;
                CommitCounter: Integer;
            begin
                WorkCenter.CopyFilters("Work Center");
                if WorkCenter.FindSet() then begin
                    OpenDialog(WorkCenter, RecordCount);

                    repeat
                        UpdateCO2ePerUnit(WorkCenter);
                        UpdateDialog(CommitCounter, Counter);

                        CommitRecord(CommitCounter);
                    until WorkCenter.Next() = 0;

                    CloseDialog();
                end;

                ShowCompletionMsg(RecordCount, Counter, "Work Center".TableCaption);
                CurrReport.Break();
            end;
        }
        dataitem("Machine Center"; "Machine Center")
        {
            RequestFilterFields = "No.";

            trigger OnPreDataItem()
            begin
                if Type = Type::"Work Center" then
                    CurrReport.Break();
            end;

            trigger OnAfterGetRecord()
            var
                MachineCenter: Record "Machine Center";
                Counter: Integer;
                CommitCounter: Integer;
            begin
                MachineCenter.CopyFilters("Machine Center");
                if MachineCenter.FindSet() then begin
                    OpenDialog(MachineCenter, RecordCount);

                    repeat
                        UpdateCO2ePerUnit(MachineCenter);
                        UpdateDialog(CommitCounter, Counter);

                        CommitRecord(CommitCounter);
                    until MachineCenter.Next() = 0;

                    CloseDialog();
                end;

                ShowCompletionMsg(RecordCount, Counter, "Machine Center".TableCaption());
                CurrReport.Break();
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                field(CapacityType; Type)
                {
                    ApplicationArea = Manufacturing;
                    Visible = not TypeVisible;
                    Caption = 'Type';
                    OptionCaption = 'Work Center,Machine Center,Both';
                    ToolTip = 'Specifies the value of the Type field.';
                }
            }
        }
    }

    procedure Initialize(InitCapacityType: Integer; HideCapacityType: Boolean)
    begin
        Type := InitCapacityType;
        TypeVisible := HideCapacityType;
    end;

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

    local procedure OpenDialog(var WorkCenter: Record "Work Center"; var RecCount: Integer)
    begin
        if not GuiAllowed() then
            exit;

        RecCount := WorkCenter.Count();
        Window.Open(ProcessBarMsg);
    end;

    local procedure OpenDialog(var MachineCenter: Record "Machine Center"; var RecCount: Integer)
    begin
        if not GuiAllowed() then
            exit;

        RecCount := MachineCenter.Count();
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

    local procedure UpdateCO2ePerUnit(var NewWorkCenter: Record "Work Center")
    var
        CO2eEmission: Decimal;
        CarbonFee: Decimal;
    begin
        SustainabilityPostMgt.UpdateCarbonFeeEmissionValues(
            "Emission Scope"::" ",
            WorkDate(),
            '',
            NewWorkCenter."Default CO2 Emission",
            NewWorkCenter."Default N2O Emission",
            NewWorkCenter."Default CH4 Emission",
            CO2eEmission,
            CarbonFee);

        NewWorkCenter.Validate("CO2e per Unit", CO2eEmission);
        NewWorkCenter.Validate("CO2e Last Date Modified", Today());
        NewWorkCenter.Modify(true);
    end;

    local procedure UpdateCO2ePerUnit(var NewMachineCenter: Record "Machine Center")
    var
        CO2eEmission: Decimal;
        CarbonFee: Decimal;
    begin
        SustainabilityPostMgt.UpdateCarbonFeeEmissionValues(
            "Emission Scope"::" ",
            WorkDate(),
            '',
            NewMachineCenter."Default CO2 Emission",
            NewMachineCenter."Default N2O Emission",
            NewMachineCenter."Default CH4 Emission",
            CO2eEmission,
            CarbonFee);

        NewMachineCenter.Validate("CO2e per Unit", CO2eEmission);
        NewMachineCenter.Validate("CO2e Last Date Modified", Today());
        NewMachineCenter.Modify(true);
    end;

    var
        SustainabilityPostMgt: Codeunit "Sustainability Post Mgt";
        Window: Dialog;
        Type: Option "Work Center","Machine Center",Both;
        ProcessBarMsg: Label 'Processing: @1@@@@@@@', Comment = '1 - overall progress';
        UpdateCompleteMsg: Label 'CO2e per unit is updated on %1 out of %2 entries in %3.', Comment = '%1 - Records Updated, %2 - Total Record Count , %3 = Table Caption';
        RecordCount: Integer;
        TypeVisible: Boolean;
}