#pragma warning disable AA0247
codeunit 5254 "Create Sust. Item"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoSustainability: Codeunit "Contoso Sustainability";
        CreateUnitOfMeasure: Codeunit "Create Unit of Measure";
        SustItemCategory: Codeunit "Create Sust Item Category";
        ContosoUtilities: Codeunit "Contoso Utilities";
        CreatePostingGroup: Codeunit "Create Posting Groups";
        CreateCommonPostingGroup: Codeunit "Create Common Posting Group";
        ContosoItem: Codeunit "Contoso Item";
    begin
        ContosoItem.InsertNonInventoryItem(SustItemCC1000(), SustItemCC1000Lbl, 240, 240, CreatePostingGroup.RetailPostingGroup(), CreateCommonPostingGroup.NonTaxable(), CreateUnitOfMeasure.Piece(), SustItemCategory.ESG(), ContosoUtilities.EmptyPicture());
        ContosoSustainability.UpdateSustainabilityItem(SustItemCC1000(), true, 3000);
    end;

    procedure SustItemCC1000(): Code[20]
    begin
        exit('CC-1000');
    end;

    var
        SustItemCC1000Lbl: Label 'Carbon Credit 3 MTCO2e', MaxLength = 100;
}
