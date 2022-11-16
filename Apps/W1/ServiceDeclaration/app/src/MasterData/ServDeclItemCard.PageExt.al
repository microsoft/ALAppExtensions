pageextension 5012 "Serv. Decl. Item Card" extends "Item Card"
{
    layout
    {
        addafter(VariantMandatoryDefaultNo)
        {
            field("Service Transaction Type Code"; Rec."Service Transaction Type Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the code for a service transaction type.';
                Editable = IsService;
                Visible = UseServDeclaration;
            }
            field("Exclude From Service Decl."; Rec."Exclude From Service Decl.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether an item must be excluded from the service declaration.';
                Editable = IsService;
                Visible = UseServDeclaration;
            }
        }
    }

    var
        UseServDeclaration: Boolean;

    trigger OnOpenPage()
    var
        ServiceDeclarationMgt: Codeunit "Service Declaration Mgt.";
    begin
        UseServDeclaration := ServiceDeclarationMgt.IsFeatureEnabled();
    end;
}