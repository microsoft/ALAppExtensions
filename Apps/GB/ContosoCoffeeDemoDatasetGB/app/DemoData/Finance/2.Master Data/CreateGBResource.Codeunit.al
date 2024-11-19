codeunit 11501 "Create GB Resource"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Resource, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecords(var Rec: Record Resource; RunTrigger: Boolean)
    var
        CreateResource: Codeunit "Create Resource";
    begin
        case Rec."No." of
            CreateResource.Katherine(),
            CreateResource.Lina(),
            CreateResource.Marty(),
            CreateResource.Terry():
                ValidateRecordFields(Rec, AtlantaLbl, USGA31772Lbl, '');
        end;
    end;

    local procedure ValidateRecordFields(var Resource: Record Resource; City: Text[30]; PostCode: Code[20]; County: Code[10])
    begin
        Resource.Validate(City, City);
        Resource.Validate("Post Code", PostCode);
        Resource.Validate(County, County);
    end;

    var
        AtlantaLbl: Label 'Atlanta', MaxLength = 30;
        USGA31772Lbl: Label 'US-GA 31772', MaxLength = 20;
}