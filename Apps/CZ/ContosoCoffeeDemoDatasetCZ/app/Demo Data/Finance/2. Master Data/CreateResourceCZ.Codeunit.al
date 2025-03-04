codeunit 31192 "Create Resource CZ"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Resource, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertResource(var Rec: Record Resource)
    var
        CreateResource: Codeunit "Create Resource";
        CreateVatPostingGroupsCZ: Codeunit "Create Vat Posting Groups CZ";
    begin
        case Rec."No." of
            CreateResource.Katherine(),
            CreateResource.Terry(),
            CreateResource.Marty(),
            CreateResource.Lina():
                ValidateRecordFields(Rec, CreateVatPostingGroupsCZ.VAT21S());
        end;
    end;

    local procedure ValidateRecordFields(var Resource: Record Resource; VATProdPostingGroup: Code[20])
    begin
        Resource.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
    end;
}