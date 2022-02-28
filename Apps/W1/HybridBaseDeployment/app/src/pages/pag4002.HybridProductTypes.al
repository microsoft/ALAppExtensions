page 4002 "Hybrid Product Types"
{
    Caption = 'Cloud Migration Product Types';
    SourceTable = "Hybrid Product Type";
    SourceTableTemporary = true;
    PageType = List;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Products)
            {
                field("Display Name"; "Display Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'The display name of the source product.';
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
    begin
        HybridCloudManagement.OnGetHybridProductType(Rec);
    end;
}