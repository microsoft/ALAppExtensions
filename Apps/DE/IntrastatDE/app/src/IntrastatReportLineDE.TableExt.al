tableextension 11029 "Intrastat Report Line DE" extends "Intrastat Report Line"
{
    fields
    {
        modify("Item No.")
        {
            trigger OnAfterValidate()
            var
                Item: Record Item;
                FixedAsset: Record "Fixed Asset";
                ItemFAOrigCountryCode: Code[10];
            begin
                if Type = Type::Receipt then begin
                    if ("Source Type" = "Source Type"::"FA Entry") then begin
                        FixedAsset.Get("Item No.");
                        ItemFAOrigCountryCode := FixedAsset."Country/Region of Origin Code";
                    end else begin
                        Item.Get("Item No.");
                        ItemFAOrigCountryCode := Item."Country/Region of Origin Code";
                    end;

                    if ItemFAOrigCountryCode = '' then
                        "Country/Region of Origin Code" := "Country/Region Code"
                    else
                        "Country/Region of Origin Code" := ItemFAOrigCountryCode;
                end;
            end;
        }

        modify("Partner VAT ID")
        {
            trigger OnBeforeValidate()
            begin
                if "Partner VAT ID" <> '' then
                    TestField(Type, Type::Shipment);
            end;
        }
    }
}