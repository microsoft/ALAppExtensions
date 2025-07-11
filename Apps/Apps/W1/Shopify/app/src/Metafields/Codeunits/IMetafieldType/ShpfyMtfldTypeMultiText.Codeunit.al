namespace Microsoft.Integration.Shopify;

codeunit 30352 "Shpfy Mtfld Type Multi Text" implements "Shpfy IMetafield Type"
{
    procedure HasAssistEdit(): Boolean
    begin
        exit(true);
    end;

    procedure IsValidValue(Value: Text): Boolean
    begin
        exit(true);
    end;

    procedure AssistEdit(var Value: Text[2048]): Boolean
    var
        MetafieldAssistEdit: Page "Shpfy Metafield Assist Edit";
    begin
        if MetafieldAssistEdit.OpenForMultiLineText(Value) then begin
            MetafieldAssistEdit.GetMultiLineText(Value);
            exit(true);
        end else
            exit(false);
    end;

    procedure GetExampleValue(): Text
    begin
        exit('Ingredients\Flour\Water\Milk\Eggs');
    end;
}