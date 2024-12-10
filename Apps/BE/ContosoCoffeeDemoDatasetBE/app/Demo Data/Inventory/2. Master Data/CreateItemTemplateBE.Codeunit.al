codeunit 11377 "Create Item Template BE"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateVatPostingGrp: Codeunit "Create VAT Posting Group BE";
        CreateItemTemplate: Codeunit "Create Item Template";
    begin
        UpdateItemTemplate(CreateItemTemplate.Item(), CreateVatPostingGrp.G3());
        UpdateItemTemplate(CreateItemTemplate.Service(), CreateVatPostingGrp.G3());
    end;

    local procedure UpdateItemTemplate(ItemTemplateCode: Code[20]; VatProdPostingGrp: Code[20])
    var
        ItemTemplate: Record "Item Templ.";
    begin
        ItemTemplate.Get(ItemTemplateCode);
        ItemTemplate.Validate("VAT Prod. Posting Group", VatProdPostingGrp);
        ItemTemplate.Modify(true);
    end;
}