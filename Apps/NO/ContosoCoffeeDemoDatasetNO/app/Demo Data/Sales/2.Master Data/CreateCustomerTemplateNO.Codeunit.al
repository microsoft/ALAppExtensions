codeunit 10723 "Create Customer Template NO"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Customer Templ.", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertCustomerTemplate(var Rec: Record "Customer Templ.")
    var
        CreateCustomerTemplate: Codeunit "Create Customer Template";
        CreatePostingGroupNO: Codeunit "Create Posting Groups NO";
        CreateCustomerPostingGroup: Codeunit "Create Customer Posting Group";
        CreateVatPostingGroupsNO: Codeunit "Create Vat Posting Groups NO";
    begin
        case Rec.Code of
            CreateCustomerTemplate.CustomerCompany(),
            CreateCustomerTemplate.CustomerPerson():
                ValidateRecordFields(Rec, CreateCustomerPostingGroup.Domestic(), CreatePostingGroupNO.VendDom(), CreateVatPostingGroupsNO.VENDHIGH());
            CreateCustomerTemplate.CustomerEUCompany():
                ValidateRecordFields(Rec, CreateCustomerPostingGroup.Foreign(), CreatePostingGroupNO.VendFor(), CreateVatPostingGroupsNO.VENDHIGH());
        end;
    end;

    local procedure ValidateRecordFields(var CustomerTempl: Record "Customer Templ."; CustomerPostingGroup: Code[20]; GenBusPostinGGroup: Code[20]; VATBusPostinGGroup: Code[20])
    begin
        CustomerTempl.Validate("Customer Posting Group", CustomerPostingGroup);
        CustomerTempl.Validate("Gen. Bus. Posting Group", GenBusPostinGGroup);
        CustomerTempl.Validate("VAT Bus. Posting Group", VATBusPostinGGroup);
    end;
}