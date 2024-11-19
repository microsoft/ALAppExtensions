codeunit 11188 "Create VAT Template AT"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"VAT Statement Template", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertResource(var Rec: Record "VAT Statement Template"; RunTrigger: Boolean)
    var
        CreateVATStatement: Codeunit "Create VAT Statement";
    begin
        case Rec.Name of
            CreateVATStatement.VATTemplateName():
                ValidateRecordField(Rec, Report::"VAT Statement AT");
        end;
    end;

    local procedure ValidateRecordField(var VatStatementTemplate: Record "VAT Statement Template"; VatReportId: Integer)
    begin
        VatStatementTemplate.Validate("VAT Statement Report ID", VatReportId);
    end;
}