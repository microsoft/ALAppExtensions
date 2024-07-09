namespace Microsoft.Integration.Shopify;

/// <summary>
/// Page Shpfy Payment Terms Mapping (ID 30162).
/// </summary>
page 30162 "Shpfy Payment Terms Mapping"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Shpfy Payment Terms";
    Caption = 'Shopify Payment Terms Mapping';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Type; Rec.Type)
                {
                    ToolTip = 'Specifies the value of the Type field.';
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the value of the Name field.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field("Payment Terms Code"; Rec."Payment Terms Code")
                {
                    ToolTip = 'Specifies the value of the Payment Terms Code field.';
                }
                field("Is Primary"; Rec."Is Primary")
                {
                    ToolTip = 'Specifies the value of the Is Primary field.';
                }
            }
        }
    }

    actions
    {
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';
                ShowAs = Standard;

                actionref(PromotedRefresh; Refresh) { }
            }
        }
        area(Processing)
        {
            action(Refresh)
            {
                ApplicationArea = All;
                Caption = 'Refresh';
                Image = Refresh;
                ToolTip = 'Refreshes the list of Shopify Payment Terms.';

                trigger OnAction()
                var
                    ShpfyPaymentTermAPI: Codeunit "Shpfy Payment Terms API";
                begin
                    ShpfyPaymentTermAPI.SetShop(CopyStr(Rec.GetFilter("Shop Code"), 1, 20));
                    ShpfyPaymentTermAPI.PullPaymentTermsCodes();
                end;
            }
        }
    }
}