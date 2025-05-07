namespace Microsoft.Sustainability.Manufacturing;

using Microsoft.Manufacturing.MachineCenter;
using Microsoft.Manufacturing.ProductionBOM;
using Microsoft.Manufacturing.Routing;
using Microsoft.Manufacturing.WorkCenter;

report 6218 "Sust. Routing Calculate CO2e"
{
    Caption = 'Calculate CO2e';
    ProcessingOnly = true;
    Permissions = tabledata "Machine Center" = r,
                  tabledata "Work Center" = r,
                  tabledata "Routing Header" = r,
                  tabledata "Routing Line" = rm;

    dataset
    {
        dataitem("Routing Header"; "Routing Header")
        {
            RequestFilterFields = "No.";

            trigger OnAfterGetRecord()
            var
                RoutingHeader: Record "Routing Header";
                Counter: Integer;
                CommitCounter: Integer;
            begin
                RoutingHeader.CopyFilters("Routing Header");
                if RoutingHeader.FindSet() then begin
                    OpenDialog(RoutingHeader, RecordCount);

                    repeat
                        UpdateCO2ePerUnit(RoutingHeader);
                        UpdateDialog(CommitCounter, Counter);

                        CommitRecord(CommitCounter);
                    until RoutingHeader.Next() = 0;

                    CloseDialog();
                end;

                ShowCompletionMsg(RecordCount, Counter);
                CurrReport.Break();
            end;
        }
    }

    procedure SetHideValidation(NewHideValidation: Boolean)
    begin
        HideValidation := NewHideValidation;
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

    local procedure OpenDialog(var RoutingHeader: Record "Routing Header"; var RecordCount: Integer)
    begin
        if not GuiAllowed() then
            exit;

        RecordCount := RoutingHeader.Count();
        Window.Open(ProcessBarMsg);
    end;

    local procedure CloseDialog()
    begin
        if not GuiAllowed() then
            exit;

        Window.Close();
    end;

    local procedure ShowCompletionMsg(RecordCount: Integer; Counter: Integer)
    begin
        if not GuiAllowed() then
            exit;

        Message(StrSubstNo(UpdateCompleteMsg, Counter, RecordCount));
    end;

    local procedure UpdateCO2ePerUnit(NewRoutingHeader: Record "Routing Header")
    var
        RoutingLine: Record "Routing Line";
        VersionManagement: Codeunit VersionManagement;
        ActiveVersionNo: Code[20];
    begin
        ActiveVersionNo := VersionManagement.GetRtngVersion(NewRoutingHeader."No.", WorkDate(), false);

        RoutingLine.SetRange("Routing No.", NewRoutingHeader."No.");
        RoutingLine.SetRange("Version Code", ActiveVersionNo);
        if RoutingLine.FindSet() then
            repeat
                RoutingLine.Validate("CO2e per Unit", GetCO2ePerUnitForRoutingLine(RoutingLine));
                RoutingLine.Validate("CO2e Last Date Modified", Today());
                if HideValidation then
                    RoutingLine.Modify()
                else
                    RoutingLine.Modify(true);
            until RoutingLine.Next() = 0;
    end;

    local procedure GetCO2ePerUnitForRoutingLine(RoutingLine: Record "Routing Line"): Decimal
    var
        WorkCenter: Record "Work Center";
        MachineCenter: Record "Machine Center";
    begin
        case RoutingLine.Type of
            RoutingLine.Type::"Machine Center":
                begin
                    MachineCenter.Get(RoutingLine."No.");
                    exit(MachineCenter."CO2e per Unit");
                end;
            RoutingLine.Type::"Work Center":
                begin
                    WorkCenter.Get(RoutingLine."No.");
                    exit(WorkCenter."CO2e per Unit");
                end;
        end;
    end;

    var
        Window: Dialog;
        ProcessBarMsg: Label 'Processing: @1@@@@@@@', Comment = '1 - overall progress';
        UpdateCompleteMsg: Label 'CO2e per unit is updated on %1 out of %2 entries in Routing.', Comment = '%1 - Records Updated, %2 - Total Record Count';
        RecordCount: Integer;
        HideValidation: Boolean;
}