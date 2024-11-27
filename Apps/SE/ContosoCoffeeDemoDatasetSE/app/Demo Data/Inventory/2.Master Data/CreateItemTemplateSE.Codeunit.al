codeunit 11219 "Create Item Template SE"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateItemTemplate: Codeunit "Create Item Template";
    begin
        UpdateItemTemplate(CreateItemTemplate.Item());
        UpdateItemTemplate(CreateItemTemplate.Service());
    end;

    local procedure UpdateItemTemplate(ItemTempCode: Code[20])
    var
        ItemTempl: Record "Item Templ.";
        CreateVatPostingGroupsSE: Codeunit "Create Vat Posting Groups SE";
    begin
        ItemTempl.Get(ItemTempCode);
        ItemTempl.Validate("VAT Prod. Posting Group", CreateVatPostingGroupsSE.VAT25());
        ItemTempl.Modify(true);
    end;
}