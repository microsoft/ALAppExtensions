codeunit 10724 "Create Vendor Template NO"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Templ.", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertVendorTemplate(var Rec: Record "Vendor Templ.")
    var
        CreateVendorTemplate: Codeunit "Create Vendor Template";
        CreatePostingGroupNO: Codeunit "Create Posting Groups NO";
        CreateVatPostingGroupsNO: Codeunit "Create Vat Posting Groups NO";
    begin
        case Rec.Code of
            CreateVendorTemplate.VendorCompany(),
            CreateVendorTemplate.VendorPerson():
                ValidateRecordFields(Rec, CreatePostingGroupNO.VendDom(), CreateVatPostingGroupsNO.VENDHIGH());
            CreateVendorTemplate.VendorEUCompany():
                ValidateRecordFields(Rec, CreatePostingGroupNO.VendFor(), CreateVatPostingGroupsNO.VENDHIGH());
        end;
    end;

    local procedure ValidateRecordFields(var VendorTempl: Record "Vendor Templ."; GenBusPostinGGroup: Code[20]; VATBusPostinGGroup: Code[20])
    begin
        VendorTempl.Validate("Gen. Bus. Posting Group", GenBusPostinGGroup);
        VendorTempl.Validate("VAT Bus. Posting Group", VATBusPostinGGroup);
    end;
}