#if not CLEAN22
page 30138 "Shpfy Templates Warnings"
{
    PageType = ListPart;
    SourceTable = "Shpfy Templates Warnings";
    SourceTableTemporary = true;
    Editable = false;
    Caption = 'Warnings';
    DeleteAllowed = false;
    InsertAllowed = false;
    Extensible = false;
    RefreshOnActivate = true;
    ObsoleteReason = 'Feature "Shopify new customer an item templates" will be enabled by default in version 25. This page is shown in Feature Management.';
    ObsoleteState = Pending;
    ObsoleteTag = '22.0';
    layout
    {
        area(Content)
        {

            repeater(ErrorsRepeater)
            {
                field(Warning; Rec.Warning)
                {
                    ApplicationArea = All;
                    ToolTip = 'Warning on data upgrade';
                }
                field("Template Type"; Rec."Template Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Type of template that cannot be upgraded';
                }
                field("Template Code"; Rec."Template Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Template code using the field';
                }
                field("Field Id"; Rec."Field Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Field id that cannot be found on the template';
                }
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Field name that cannot be found on template';
                }
            }
        }
    }

    internal procedure SetShpfyTemplateWarnings(var TempShpfyTemplateWarnings: Record "Shpfy Templates Warnings" temporary)
    begin
        if TempShpfyTemplateWarnings.FindSet() then
            repeat
                Rec.Copy(TempShpfyTemplateWarnings);
                Rec.Insert();
            until TempShpfyTemplateWarnings.Next() = 0;
    end;
}
#endif