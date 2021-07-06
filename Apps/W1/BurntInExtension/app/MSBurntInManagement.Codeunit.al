codeunit 1090 "MS - Burntin Management"
{
    // // This Codeunit is present only in sharedDb deployments, hence it is used to block functionality that is not supported in such cases.
    // // Keep tests in sync in COD138999.


    trigger OnRun()
    begin
    end;

    var
        ExtensionManagementBlockedTxt: Label 'Interested in trying more apps for Dynamics 365 Business Central? Great! You''ll need to contact a Microsoft partner or Microsoft Support for assistance, though. Your company has used Microsoft Invoicing, which comes with a Dynamics 365 Business Central account in the background. That account allows only those two apps, but we can fix that.\ \To learn more, copy this link to a browser https://go.microsoft.com/fwlink/?linkid=860971';
        CompanyBlockedTxt: Label 'Sorry, your Dynamics 365 Business Central account is locked for new companies. Your company has used Microsoft Invoicing, which is where you got your Dynamics 365 Business Central account, and that account allows only the two companies it came with. Contact a Microsoft partner or Microsoft Support and ask them to unlock it for you.\ \To learn more, copy this link to a browser https://go.microsoft.com/fwlink/?linkid=860971';
        InvToFinTelemetryCategoryTok: Label 'AL InvToFin', Locked = true;
        O365BCTenantOpensExtPageTelemetryMsg: Label 'A O365 Business center tenant tried to open an extension page: Page %1.', Locked = true;
        SharedDbCreateRemoveCompanyMsg: Label 'A shared db tenant tried to create/remove or rename a company.', Locked = true;
        InvoicingCompanyNameTxt: Label 'My Company', Locked = true;

    [EventSubscriber(ObjectType::Page, Page::"Extension Management", 'OnOpenPageEvent', '', true, true)]
    local procedure BlockPageOpen2500ExtensionManagement(var Rec: Record 2000000160)
    begin
        RaiseExtensionErrorAndLogTelemetry(PAGE::"Extension Management");
    end;

    [EventSubscriber(ObjectType::Page, Page::"Extension Details", 'OnOpenPageEvent', '', true, true)]
    local procedure BlockPageOpen2501ExtensionDetails(var Rec: Record 2000000160)
    begin
        RaiseExtensionErrorAndLogTelemetry(PAGE::"Extension Details");
    end;

    [EventSubscriber(ObjectType::Page, Page::"Extension Installation", 'OnOpenPageEvent', '', true, true)]
    local procedure BlockPageOpen2503ExtensionInstallation(var Rec: Record 2000000160)
    begin
        RaiseExtensionErrorAndLogTelemetry(PAGE::"Extension Installation");
    end;

    [EventSubscriber(ObjectType::Page, Page::"Extension Details Part", 'OnOpenPageEvent', '', true, true)]
    local procedure BlockPageOpen2504ExtensionDetailsPart(var Rec: Record 2000000160)
    begin
        RaiseExtensionErrorAndLogTelemetry(PAGE::"Extension Details Part");
    end;

    [EventSubscriber(ObjectType::Page, Page::"Extension Logo Part", 'OnOpenPageEvent', '', true, true)]
    local procedure BlockPageOpen2506ExtensionLogoPart(var Rec: Record 2000000160)
    begin
        RaiseExtensionErrorAndLogTelemetry(PAGE::"Extension Logo Part");
    end;

    [EventSubscriber(ObjectType::Page, Page::"Upload And Deploy Extension", 'OnOpenPageEvent', '', true, true)]
    local procedure BlockPageOpen2507UploadAndDeployExtension(var Rec: Record 2000000160)
    begin
        RaiseExtensionErrorAndLogTelemetry(PAGE::"Upload And Deploy Extension");
    end;

    [EventSubscriber(ObjectType::Page, Page::"Extension Deployment Status", 'OnOpenPageEvent', '', true, true)]
    local procedure BlockPageOpen2508ExtensionDeploymentStatus(var Rec: Record 2000000200)
    begin
        RaiseExtensionErrorAndLogTelemetry(PAGE::"Extension Deployment Status");
    end;

    [EventSubscriber(ObjectType::Page, Page::"Extn Deployment Status Detail", 'OnOpenPageEvent', '', true, true)]
    local procedure BlockPageOpen2509ExtnDeploymentStatusDetail(var Rec: Record 2000000200)
    begin
        RaiseExtensionErrorAndLogTelemetry(PAGE::"Extn Deployment Status Detail");
    end;

    [EventSubscriber(ObjectType::Page, Page::"Marketplace Extn Deployment", 'OnOpenPageEvent', '', true, true)]
    local procedure BlockPageOpen2510MarketplaceExtnDeployment()
    begin
        RaiseExtensionErrorAndLogTelemetry(PAGE::"Marketplace Extn Deployment");
    end;

    [EventSubscriber(ObjectType::Page, Page::"Extension Settings", 'OnOpenPageEvent', '', true, true)]
    local procedure BlockPageOpen2511ExtensionSettings(var Rec: Record 2000000201)
    begin
        RaiseExtensionErrorAndLogTelemetry(PAGE::"Extension Settings");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Company", 'OnBeforeInsertEvent', '', false, false)]
    local procedure BlockCompanyCreation(var Rec: Record "Company"; RunTrigger: Boolean)
    begin
        IF Rec.IsTemporary() THEN
            EXIT;

        RaiseCompanyErrorAndLogTelemetry();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Company", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure BlockCompanyDeletion(var Rec: Record "Company"; RunTrigger: Boolean)
    begin
        IF Rec.IsTemporary() THEN
            EXIT;

        RaiseCompanyErrorAndLogTelemetry();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Company", 'OnBeforeRenameEvent', '', false, false)]
    local procedure BlockCompanyRename(var Rec: Record "Company"; var xRec: Record "Company"; RunTrigger: Boolean)
    begin
        IF Rec.IsTemporary() THEN
            EXIT;

        IF xRec.Name = InvoicingCompanyNameTxt THEN
            RaiseCompanyErrorAndLogTelemetry();
    end;

    local procedure RaiseExtensionErrorAndLogTelemetry(PageID: Integer)
    begin
        Session.LogMessage('00001TR', STRSUBSTNO(O365BCTenantOpensExtPageTelemetryMsg, PageID), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', InvToFinTelemetryCategoryTok);

        ERROR(ExtensionManagementBlockedTxt);
    end;

    local procedure RaiseCompanyErrorAndLogTelemetry()
    var
        EnvironmentInfo: Codeunit "Environment Information";
        ClientTypeManagement: Codeunit "Client Type Management";
    begin
        IF ClientTypeManagement.GetCurrentClientType() IN [CLIENTTYPE::Management, CLIENTTYPE::Background] THEN
            EXIT;

        IF NOT EnvironmentInfo.IsSaaS() THEN
            EXIT;

        Session.LogMessage('00001TQ', SharedDbCreateRemoveCompanyMsg, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', InvToFinTelemetryCategoryTok);

        ERROR(CompanyBlockedTxt);
    end;
}

