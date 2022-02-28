#if not CLEAN19
codeunit 4056 "Upgrade BaseApp 18x"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This functionality will be replaced by invoking the actual upgrade from each of the apps';
    ObsoleteTag = '19.0';
    Permissions = tabledata "Sales Shipment Line" = rmid, tabledata "Purch. Rcpt. Line" = rmid, tabledata "Dimension Set Entry" = rmid;

    var
        ITCountryCodeTxt: Label 'IT', Locked = true;

    trigger OnRun()
    begin
        // This code is based on standard app upgrade logic.
    end;

    var
        FailedToUpdatePowerBIImageTxt: Label 'Failed to update PowerBI optin image for client type %1.', Locked = true;
        AttemptingPowerBIUpdateTxt: Label 'Attempting to update PowerBI optin image for client type %1.', Locked = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Management", 'OnUpgradeNonCompanyDataForVersion', '', false, false)]
    local procedure OnUpgradeNonCompanyUpgrade(TargetVersion: Decimal)
    begin
        if TargetVersion <> 18.0 then
            exit;

        UpgradePowerBIOptin();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Company Handler", 'OnUpgradePerCompanyDataForVersion', '', false, false)]
    local procedure OnUpgradePerCompanyDataUpgrade(HybridReplicationSummary: Record "Hybrid Replication Summary"; CountryCode: Text; TargetVersion: Decimal)
    begin
        if TargetVersion <> 18.0 then
            exit;

#if not CLEAN19
        UpdateBusinessRelation();
#endif
        UpgradeIntegrationFieldMappingForOpportunities();
        UpgradeIntegrationFieldMappingForContacts();
        UpgradeAPIs();
        UpgradePostCodeServiceKey();
        UpgradeIntrastatJnlLine(CountryCode);
        UpgradeWordTemplateTables();
    end;

    local procedure UpgradeAPIs()
    begin
        UpgradeSalesShipmentLineDocumentId();
        UpgradePurchRcptLineDocumentId();
        UpgradePurchaseOrderEntityBuffer();
    end;

#if not CLEAN19
    local procedure UpdateBusinessRelation()
    var
        Contact: Record Contact;
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitions: Codeunit "Upgrade Tag Definitions";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetContactBusinessRelationUpgradeTag()) then
            exit;

        Contact.SetRange("Business Relation", '');
        if Contact.FindSet(true, false) then
            repeat
                Contact.UpdateBusinessRelation();
                if Contact.Modify() then;
            until Contact.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetContactBusinessRelationUpgradeTag());
    end;
#endif

    internal procedure UpgradeWordTemplateTables()
    var
        WordTemplate: Codeunit "Word Template";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitions: Codeunit "Upgrade Tag Definitions";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetDefaultWordTemplateAllowedTablesUpgradeTag()) then
            exit;

        WordTemplate.AddTable(Database::Contact);
        WordTemplate.AddTable(Database::Customer);
        WordTemplate.AddTable(Database::Item);
        WordTemplate.AddTable(Database::Vendor);

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetDefaultWordTemplateAllowedTablesUpgradeTag());
    end;

    local procedure UpgradeSalesShipmentLineDocumentId()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentLine: Record "Sales Shipment Line";
        EnvironmentInformation: codeunit "Environment Information";
        UpgradeTagDefinitions: Codeunit "Upgrade Tag Definitions";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetNewSalesShipmentLineUpgradeTag()) then
            exit;

        if EnvironmentInformation.IsSaaS() then
            if SalesShipmentLine.Count() > GetSafeRecordCountForSaaSUpgrade() then
                exit;

        SalesShipmentHeader.SetLoadFields(SalesShipmentHeader."No.", SalesShipmentHeader.SystemId);
        if SalesShipmentHeader.FindSet() then
            repeat
                SalesShipmentLine.SetRange("Document No.", SalesShipmentHeader."No.");
                SalesShipmentLine.ModifyAll("Document Id", SalesShipmentHeader.SystemId);
            until SalesShipmentHeader.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetNewSalesShipmentLineUpgradeTag());
    end;

    local procedure UpgradePowerBIOptin()
    var
        MediaRepository: Record "Media Repository";
        PowerBIReportSpinnerPart: Page "Power BI Report Spinner Part";
        TargetClientType: ClientType;
        ImageName: Text[250];
    begin
        ImageName := PowerBIReportSpinnerPart.GetOptinImageName();

        TargetClientType := ClientType::Phone;
        if not MediaRepository.Get(ImageName, TargetClientType) then
            if not UpdatePowerBIOptinFromExistingImage(TargetClientType) then
                Session.LogMessage('0000EH1', STRSUBSTNO(FailedToUpdatePowerBIImageTxt, TargetClientType), Verbosity::Warning, DataClassification::SystemMetadata,
                TelemetryScope::ExtensionPublisher, 'Category', 'AL SaaS Upgrade');

        TargetClientType := ClientType::Tablet;
        if not MediaRepository.Get(ImageName, TargetClientType) then
            if not UpdatePowerBIOptinFromExistingImage(TargetClientType) then
                Session.LogMessage('0000EH2', STRSUBSTNO(FailedToUpdatePowerBIImageTxt, TargetClientType), Verbosity::Warning, DataClassification::SystemMetadata,
                TelemetryScope::ExtensionPublisher, 'Category', 'AL SaaS Upgrade');
    end;

    local procedure UpdatePowerBIOptinFromExistingImage(targetClientType: ClientType): Boolean
    var
        MediaRepository: Record "Media Repository";
        TargetMediaRepository: Record "Media Repository";
        PowerBIReportSpinnerPart: Page "Power BI Report Spinner Part";
        ImageName: Text[250];
    begin
        Session.LogMessage('0000EH4', STRSUBSTNO(AttemptingPowerBIUpdateTxt, targetClientType), Verbosity::Normal, DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher, 'Category', 'AL SaaS Upgrade');

        // Insert the same image we use on web
        ImageName := PowerBIReportSpinnerPart.GetOptinImageName();
        if not MediaRepository.Get(ImageName, Format(ClientType::Web)) then
            exit(false);

        TargetMediaRepository.TransferFields(MediaRepository);
        TargetMediaRepository."File Name" := ImageName;
        TargetMediaRepository."Display Target" := Format(targetClientType);
        exit(TargetMediaRepository.Insert());
    end;

    local procedure UpgradeIntegrationFieldMappingForOpportunities()
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        TempOpportunity: Record Opportunity temporary;
        TempCRMOpportunity: Record "CRM Opportunity" temporary;
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitions: Codeunit "Upgrade Tag Definitions";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetIntegrationFieldMappingForOpportunitiesUpgradeTag()) then
            exit;

        IntegrationTableMapping.SetRange(Name, 'OPPORTUNITY');
        IntegrationTableMapping.SetRange("Table ID", Database::Opportunity);
        IntegrationTableMapping.SetRange("Integration Table ID", Database::"CRM Opportunity");
        if IntegrationTableMapping.FindFirst() then begin
            IntegrationFieldMapping.SetRange("Integration Table Mapping Name", IntegrationTableMapping.Name);
            IntegrationFieldMapping.SetRange("Field No.", TempOpportunity.FieldNo("Contact Company No."));
            IntegrationFieldMapping.SetRange("Integration Table Field No.", TempCRMOpportunity.FieldNo(ParentAccountId));
            if IntegrationFieldMapping.IsEmpty() then
                IntegrationFieldMapping.CreateRecord(
                    IntegrationTableMapping.Name,
                    TempOpportunity.FieldNo("Contact Company No."),
                    TempCRMOpportunity.FieldNo(ParentAccountId),
                    IntegrationFieldMapping.Direction::ToIntegrationTable,
                    '', true, false);
        end;

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetIntegrationFieldMappingForOpportunitiesUpgradeTag());
    end;

    local procedure UpgradeIntegrationFieldMappingForContacts()
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        TempContact: Record Contact temporary;
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitions: Codeunit "Upgrade Tag Definitions";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetIntegrationFieldMappingForContactsUpgradeTag()) then
            exit;

        IntegrationTableMapping.SetRange(Name, GetContactIntegrationTableMappingName());
        IntegrationTableMapping.SetRange("Table ID", Database::Contact);
        IntegrationTableMapping.SetRange("Integration Table ID", Database::"CRM Contact");
        if IntegrationTableMapping.FindFirst() then begin
            IntegrationFieldMapping.SetRange("Integration Table Mapping Name", IntegrationTableMapping.Name);
            IntegrationFieldMapping.SetRange("Field No.", TempContact.FieldNo(Type));
            IntegrationFieldMapping.SetRange("Integration Table Field No.", 0);
            IntegrationFieldMapping.SetRange(Direction, IntegrationFieldMapping.Direction::FromIntegrationTable);
            IntegrationFieldMapping.SetRange("Transformation Direction", IntegrationFieldMapping."Transformation Direction"::FromIntegrationTable);
            IntegrationFieldMapping.SetFilter("Constant Value", '<>%1', GetContactTypeFieldMappingConstantValue());
            if IntegrationFieldMapping.FindFirst() then begin
                IntegrationFieldMapping."Constant Value" := CopyStr(GetContactTypeFieldMappingConstantValue(), 1, MaxStrLen(IntegrationFieldMapping."Constant Value"));
                IntegrationFieldMapping.Modify();
            end;
        end;

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetIntegrationFieldMappingForContactsUpgradeTag());
    end;

    local procedure UpgradePurchRcptLineDocumentId()
    var
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        EnvironmentInformation: codeunit "Environment Information";
        UpgradeTagDefinitions: Codeunit "Upgrade Tag Definitions";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetNewPurchRcptLineUpgradeTag()) then
            exit;

        if EnvironmentInformation.IsSaaS() then
            if PurchRcptLine.Count() > GetSafeRecordCountForSaaSUpgrade() then
                exit;

        PurchRcptHeader.SetLoadFields(PurchRcptHeader."No.", PurchRcptHeader.SystemId);
        if PurchRcptHeader.FindSet() then
            repeat
                PurchRcptLine.SetRange("Document No.", PurchRcptHeader."No.");
                PurchRcptLine.ModifyAll("Document Id", PurchRcptHeader.SystemId);
            until PurchRcptHeader.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetNewPurchRcptLineUpgradeTag());
    end;

    local procedure GetContactIntegrationTableMappingName(): Text
    begin
        exit('CONTACT');
    end;

    local procedure GetContactTypeFieldMappingConstantValue(): Text
    begin
        exit('Person');
    end;

    local procedure UpgradePostCodeServiceKey()
    var
        PostCodeServiceConfig: Record "Postcode Service Config";
        UpgradeTagDefinitions: Codeunit "Upgrade Tag Definitions";
        UpgradeTag: Codeunit "Upgrade Tag";
        IsolatedStorageManagement: Codeunit "Isolated Storage Management";
        IsolatedStorageValue: Text;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetPostCodeServiceKeyUpgradeTag()) then
            exit;

        if not PostCodeServiceConfig.Get() then
            exit;

        if not IsolatedStorageManagement.Get(PostCodeServiceConfig.ServiceKey, DataScope::Company, IsolatedStorageValue) then
            exit;

        if not IsolatedStorageManagement.Delete(PostCodeServiceConfig.ServiceKey, DataScope::Company) then;

        if IsolatedStorageValue = '' then
            IsolatedStorageValue := 'Disabled';

        PostCodeServiceConfig.SaveServiceKey(IsolatedStorageValue);

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetPostCodeServiceKeyUpgradeTag());
    end;

    local procedure UpgradeIntrastatJnlLine(CountryCode: Text)
    var
        IntrastatJnlLine: Record "Intrastat Jnl. Line";
        UpgradeTagDefinitions: Codeunit "Upgrade Tag Definitions";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if CountryCode = ITCountryCodeTxt then
            exit;

        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetIntrastatJnlLinePartnerIDUpgradeTag()) THEN
            exit;

        IntrastatJnlLine.SetRange(Type, IntrastatJnlLine.Type::Shipment);
        if IntrastatJnlLine.FindSet() then
            repeat
                IntrastatJnlLine."Country/Region of Origin Code" := IntrastatJnlLine.GetCountryOfOriginCode();
                IntrastatJnlLine."Partner VAT ID" := IntrastatJnlLine.GetPartnerID();
                IntrastatJnlLine.Modify();
            until IntrastatJnlLine.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetIntrastatJnlLinePartnerIDUpgradeTag());
    end;

    local procedure UpgradePurchaseOrderEntityBuffer()
    var
        PurchaseHeader: Record "Purchase Header";
        GraphMgtPurchOrderBuffer: Codeunit "Graph Mgt - Purch Order Buffer";
        UpgradeTagDefinitions: Codeunit "Upgrade Tag Definitions";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetNewPurchaseOrderEntityBufferUpgradeTag()) then
            exit;

        PurchaseHeader.SETRANGE("Document Type", PurchaseHeader."Document Type"::Order);
        IF PurchaseHeader.FindSet() THEN
            repeat
                GraphMgtPurchOrderBuffer.InsertOrModifyFromPurchaseHeader(PurchaseHeader);
            until PurchaseHeader.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetNewPurchaseOrderEntityBufferUpgradeTag());
    end;

    local procedure GetSafeRecordCountForSaaSUpgrade(): Integer
    begin
        exit(300000);
    end;
}
#endif