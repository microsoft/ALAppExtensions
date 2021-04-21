page 31005 "Stockkeeping Unit Templ. CZL"
{
    Caption = 'Stockkeeping Unit Templates';
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Stockkeeping Unit Template CZL";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Item Category Code"; Rec."Item Category Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the item category of the created stockkeeping unit.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the location code of the created stockkeeping unit.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of the stockkeeping unit template.';
                }
                field("Configuration Template Code"; Rec."Configuration Template Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of the data template that is being used as part of the stockkeeping unit creation process.';
                }
                field("Configuration Template Descr."; Rec."Configuration Template Descr.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of the data template that is being used as part of the stockkeeping unit creation process.';
                }
            }
        }
        area(Factboxes)
        {
            systempart(Links; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action(ConfigurationTemplate)
            {
                Caption = 'Configuration Template';
                ApplicationArea = Basic, Suite;
                Image = Template;
                RunObject = Page "Config. Template Header";
                RunPageLink = Code = field("Configuration Template Code");
                RunPageMode = View;
                ToolTip = 'Open configuration template card.';
            }
        }
    }
}
