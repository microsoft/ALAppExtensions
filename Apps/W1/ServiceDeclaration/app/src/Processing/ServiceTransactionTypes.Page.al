page 5011 "Service Transaction Types"
{
    PageType = List;
    SourceTable = "Service Transaction Type";
    UsageCategory = Administration;
    ApplicationArea = Basic, Suite;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of the service transaction type.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of the service transaction type.';
                }
            }
        }
    }

    var
        SetupMode: Boolean;

    trigger OnOpenPage()
    var
        ServiceDeclarationMgt: Codeunit "Service Declaration Mgt.";
    begin
        if SetupMode then
            exit;
        if not ServiceDeclarationMgt.IsFeatureEnabled() then begin
            ServiceDeclarationMgt.ShowNotEnabledMessage(CurrPage.Caption());
            Error('');
        end;
    end;

    procedure SetSetupMode()
    begin
        SetupMode := true;
    end;
}

