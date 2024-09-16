namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;

tableextension 8095 "Item Templ." extends "Item Templ."
{
    fields
    {
        field(8052; "Service Commitment Option"; Enum "Item Service Commitment Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Service Commitment Option';

            trigger OnValidate()
            begin
                Rec.ValidateItemField(FieldNo("Service Commitment Option"));
                if "Service Commitment Option" in ["Item Service Commitment Type"::"Sales without Service Commitment", "Item Service Commitment Type"::"Invoicing Item"] then
                    DeleteItemTemplateServiceCommitmentPackages();
            end;
        }
    }

    local procedure DeleteItemTemplateServiceCommitmentPackages()
    var
        ItemTemplateServiceCommitmentPackage: Record "Item Templ. Serv. Comm. Pack.";
    begin
        ItemTemplateServiceCommitmentPackage.SetRange("Item Template Code", Rec.Code);
        ItemTemplateServiceCommitmentPackage.DeleteAll(false);
    end;
}