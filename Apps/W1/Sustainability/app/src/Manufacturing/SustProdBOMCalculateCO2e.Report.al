namespace Microsoft.Sustainability.Manufacturing;

using Microsoft.Inventory.Item;
using Microsoft.Manufacturing.ProductionBOM;

report 6216 "Sust. Prod. BOM Calculate CO2e"
{
    Caption = 'Calculate CO2e';
    ProcessingOnly = true;
    Permissions = tabledata Item = r,
                  tabledata "Production BOM Header" = r,
                  tabledata "Production BOM Line" = rm;

    dataset
    {
        dataitem("Production BOM Header"; "Production BOM Header")
        {
            RequestFilterFields = "No.";

            trigger OnAfterGetRecord()
            var
                ProductionBOMHeader: Record "Production BOM Header";
                Counter: Integer;
                CommitCounter: Integer;
            begin
                ProductionBOMHeader.CopyFilters("Production BOM Header");
                if ProductionBOMHeader.FindSet() then begin
                    OpenDialog(ProductionBOMHeader, RecordCount);

                    repeat
                        UpdateCO2ePerUnit(ProductionBOMHeader);
                        UpdateDialog(CommitCounter, Counter);

                        CommitRecord(CommitCounter);
                    until ProductionBOMHeader.Next() = 0;

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

    local procedure OpenDialog(var ProductionBOMHeader: Record "Production BOM Header"; var RecCount: Integer)
    begin
        if not GuiAllowed() then
            exit;

        RecCount := ProductionBOMHeader.Count();
        Window.Open(ProcessBarMsg);
    end;

    local procedure CloseDialog()
    begin
        if not GuiAllowed() then
            exit;

        Window.Close();
    end;

    local procedure ShowCompletionMsg(RecCount: Integer; Counter: Integer)
    begin
        if not GuiAllowed() then
            exit;

        Message(StrSubstNo(UpdateCompleteMsg, Counter, RecCount));
    end;

    local procedure UpdateCO2ePerUnit(NewProductionBOMHeader: Record "Production BOM Header")
    var
        Item: Record Item;
        ProductionBOMLine: Record "Production BOM Line";
        VersionManagement: Codeunit VersionManagement;
        ActiveVersionNo: Code[20];
    begin
        ActiveVersionNo := VersionManagement.GetBOMVersion(NewProductionBOMHeader."No.", WorkDate(), false);

        ProductionBOMLine.SetRange("Production BOM No.", NewProductionBOMHeader."No.");
        ProductionBOMLine.SetRange("Version Code", ActiveVersionNo);
        ProductionBOMLine.SetRange(Type, ProductionBOMLine.Type::Item);
        if ProductionBOMLine.FindSet() then
            repeat
                Item.Get(ProductionBOMLine."No.");

                ProductionBOMLine.Validate("CO2e per Unit", Item."CO2e per Unit");
                ProductionBOMLine.Validate("CO2e Last Date Modified", Today());
                if HideValidation then
                    ProductionBOMLine.Modify()
                else
                    ProductionBOMLine.Modify(true);
            until ProductionBOMLine.Next() = 0;
    end;

    var
        Window: Dialog;
        ProcessBarMsg: Label 'Processing: @1@@@@@@@', Comment = '1 - overall progress';
        UpdateCompleteMsg: Label 'CO2e per unit is updated on %1 out of %2 entries in Production BOM.', Comment = '%1 - Records Updated, %2 - Total Record Count';
        RecordCount: Integer;
        HideValidation: Boolean;
}