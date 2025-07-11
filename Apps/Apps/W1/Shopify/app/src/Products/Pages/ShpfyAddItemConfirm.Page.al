namespace Microsoft.Integration.Shopify;

page 30144 "Shpfy Add Item Confirm"
{
    Caption = 'Add to Shopify shop';
    InstructionalText = 'Add to Shopify shop';
    PageType = StandardDialog;

    layout
    {
        area(Content)
        {
            label(ActiveConfirm)
            {
                ApplicationArea = All;
                CaptionClass = ActiveConfirmTxt;
                MultiLine = true;
                ShowCaption = false;
                Visible = IsActive;
            }
            label(DraftConfirm)
            {
                ApplicationArea = All;
                CaptionClass = DraftConfirmTxt;
                MultiLine = true;
                ShowCaption = false;
                Visible = not IsActive;
            }
        }
    }

    trigger OnOpenPage()
    begin
        ActiveConfirmTxt := StrSubstNo(AddToStoreActiveConfirmLbl, ItemDescription, ShopCode);
        DraftConfirmTxt := StrSubstNo(AddToStoreDraftConfirmLbl, ItemDescription, ShopCode);
    end;

    var
        ItemDescription: Text[100];
        ShopCode: Code[20];
        IsActive: Boolean;
        ActiveConfirmTxt: Text;
        DraftConfirmTxt: Text;

        AddToStoreActiveConfirmLbl: Label 'The item %1 will be added to the %2 store as a new product, and it will be immediately active.', Comment = '%1 - Item description, %2 - Shopify store name';
        AddToStoreDraftConfirmLbl: Label 'The item %1 will be added to the %2 store as a new product, and it will remain in draft until you activate it.', Comment = '%1 - Item description, %2 - Shopify store name';

    internal procedure SetIsActive(Active: Boolean)
    begin
        IsActive := Active;
    end;

    internal procedure SetItemDescription(Description: Text[100])
    begin
        ItemDescription := Description;
    end;

    internal procedure SetShopCode(Code: Code[20])
    begin
        ShopCode := Code;
    end;
}