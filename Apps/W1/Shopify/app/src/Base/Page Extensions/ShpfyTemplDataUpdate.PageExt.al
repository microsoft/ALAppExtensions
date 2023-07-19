#if not CLEAN22
pageextension 30105 "Shpfy Templ. Data Update" extends "Schedule Feature Data Update"
{
    ObsoleteReason = 'Feature "Shopify new customer an item templates" will be enabled by default in version 25';
    ObsoleteState = Pending;
    ObsoleteTag = '22.0';

    layout
    {
        addbefore(Review)
        {
            group(ShopifyTemplatesGroup)
            {
                ShowCaption = false;
                Visible = IsShpfyTemplateFeature;
                field(CantUpgradeTemplatesWarning; CantUpgradeTemplatesWarningMsg)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    Visible = not CanUpgradeAllFields;
                }
                part(WarningsPart; "Shpfy Templates Warnings")
                {
                    ApplicationArea = All;
                    Visible = ShowWarnings;
                    Caption = '';
                    Editable = false;
                }
                group(ShpfyDataUpgradeSelection)
                {
                    ShowCaption = false;
                    field(MigrateAnywayChoice; MigrateOption)
                    {
                        Caption = 'Data upgrade';
                        ApplicationArea = All;
                        Visible = not CanUpgradeAllFields;
                        ToolTip = 'What to do with the templates being used in the Shopify Shops';
                        OptionCaption = 'Create templates (skip fields that are not available),Do not create templates. I will update the Shopify shops manually';
                        trigger OnValidate()
                        begin
                            if MigrateOption = MigrateOption::CreateTemplates then
                                Rec."Shpfy Templates Migrate" := true
                            else
                                Rec."Shpfy Templates Migrate" := false
                        end;
                    }
                    field(MigrateChoice; MigrateOption)
                    {
                        Caption = 'Data upgrade';
                        ApplicationArea = All;
                        Visible = CanUpgradeAllFields;
                        ToolTip = 'What to do with the templates being used in the Shopify Shops';
                        OptionCaption = 'Create templates,Do not create any templates. I will update the Shopify shops manually';
                        trigger OnValidate()
                        begin
                            if MigrateOption = MigrateOption::CreateTemplates then
                                Rec."Shpfy Templates Migrate" := true
                            else
                                Rec."Shpfy Templates Migrate" := false;
                        end;
                    }
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        IsShpfyTemplateFeature := FeatureDataUpdateMgt.FeatureKeyMatches(Rec, Enum::"Feature To Update"::ShopifyNewCustomerItemTemplates);
        if not IsShpfyTemplateFeature then
            exit;
        CurrPage.WarningsPart.Page.GetRecord(TempShpfyTemplateWarnings);
        CanUpgradeAllFields := ShpfyTemplates.CanUpgradeAllFields(TempShpfyTemplateWarnings);
        Rec."Shpfy Templates Migrate" := true;
        MigrateOption := MigrateOption::CreateTemplates;
        CurrPage.WarningsPart.Page.SetShpfyTemplateWarnings(TempShpfyTemplateWarnings);
        CurrPage.WarningsPart.Page.Update();
        ShowWarnings := TempShpfyTemplateWarnings.Count <> 0;
        CurrPage.Update();
    end;

    var
        TempShpfyTemplateWarnings: Record "Shpfy Templates Warnings" temporary;
        FeatureDataUpdateMgt: Codeunit "Feature Data Update Mgt.";
        ShpfyTemplates: Codeunit "Shpfy Templates";
        CantUpgradeTemplatesWarningMsg: Label 'There are some fields that we cannot automatically transfer.';
        IsShpfyTemplateFeature: Boolean;
        CanUpgradeAllFields: Boolean;
        ShowWarnings: Boolean;
        MigrateOption: Option CreateTemplates,DontCreateTemplates;
}
#endif