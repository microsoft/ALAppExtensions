namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;

tableextension 8095 "Item Templ." extends "Item Templ."
{
    fields
    {
        field(8052; "Subscription Option"; Enum "Item Service Commitment Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Subscription Option';

            trigger OnValidate()
            begin
                Rec.ValidateItemField(FieldNo("Subscription Option"));
                if "Subscription Option" in ["Item Service Commitment Type"::"Sales without Service Commitment", "Item Service Commitment Type"::"Invoicing Item"] then
                    DeleteItemTemplateServiceCommitmentPackages();
            end;
        }
        modify("Allow Invoice Disc.")
        {
            trigger OnAfterValidate()
            begin
                Rec.ValidateItemField(FieldNo("Allow Invoice Disc."));
            end;
        }
    }

    local procedure DeleteItemTemplateServiceCommitmentPackages()
    var
        ItemTemplateServiceCommitmentPackage: Record "Item Templ. Sub. Package";
    begin
        ItemTemplateServiceCommitmentPackage.SetRange("Item Template Code", Rec.Code);
        ItemTemplateServiceCommitmentPackage.DeleteAll(false);
    end;
}