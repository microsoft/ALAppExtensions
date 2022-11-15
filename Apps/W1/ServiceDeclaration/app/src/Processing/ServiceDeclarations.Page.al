page 5022 "Service Declarations"
{
    CardPageID = "Service Declaration";
    Editable = false;
    PageType = List;
    SourceTable = "Service Declaration Header";
    UsageCategory = Lists;
    ApplicationArea = Basic, Suite;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the service declaration.';
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the starting date of the service declaration.';
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ending date of the service declaration.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        ServiceDeclarationMgt: Codeunit "Service Declaration Mgt.";
    begin
        if not ServiceDeclarationMgt.IsFeatureEnabled() then begin
            ServiceDeclarationMgt.ShowNotEnabledMessage(CurrPage.Caption());
            Error('');
        end;
    end;
}

