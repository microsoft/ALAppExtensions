namespace Microsoft.DataMigration.GP;

using Microsoft.DataMigration;

pageextension 41101 "Intelligent Cloud Ext." extends "Intelligent Cloud Management"
{
    layout
    {
        addlast(FactBoxes)
        {
            part("1099 Migration Log"; "GP 1099 Migration Log Factbox")
            {
                Caption = 'GP Vendor 1099 Migration Log';
                ApplicationArea = All;
                Visible = FactBoxesVisible;
            }
        }
    }

    trigger OnOpenPage()
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        HybridGPWizard: Codeunit "Hybrid GP Wizard";
    begin
        if IntelligentCloudSetup.Get() then
            FactBoxesVisible := IntelligentCloudSetup."Product ID" = HybridGPWizard.ProductId();
    end;

    var
        FactBoxesVisible: Boolean;
}