codeunit 10525 "Create GB VAT Report Setup"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoVATStatement: Codeunit "Contoso VAT Statement";
    begin
        ContosoVATStatement.InsertVATReportConfiguration(Enum::"VAT Report Configuration"::"VAT Return", GovTalkVersion(), Codeunit::"VAT Report Suggest Lines", Codeunit::"GovTalk VAT Report Validate");
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Reports Configuration", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "VAT Reports Configuration"; RunTrigger: Boolean)
    var
        CreateVATReportSetup: Codeunit "Create VAT Report Setup";
    begin
        if (Rec."VAT Report Type" = Rec."VAT Report Type"::"EC Sales List") and (Rec."VAT Report Version" = CreateVATReportSetup.CurrentVersion()) then
            Rec.Validate("Submission Codeunit ID", Codeunit::"EC Sales List Submit");

        if (Rec."VAT Report Type" = Rec."VAT Report Type"::"VAT Return") and (Rec."VAT Report Version" = GovTalkVersion()) then begin
            Rec.Validate("Content Codeunit ID", Codeunit::"Create VAT Declaration Request");
            Rec.Validate("Submission Codeunit ID", Codeunit::"Submit VAT Declaration Request");
        end;
    end;

    procedure GovTalkVersion(): Code[10]
    begin
        exit(GovTalkVersionTok);
    end;

    var
        GovTalkVersionTok: Label 'GOVTALK', MaxLength = 10;
}