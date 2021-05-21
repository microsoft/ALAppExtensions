codeunit 4056 "Upgrade BaseApp 18x"
{
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

        UpdateBusinessRelation();
        UpgradeIntegrationTableMappingFilterForOpportunities();
        UpgradeIntegrationFieldMappingForOpportunities();
        UpgradeIntegrationFieldMappingForContacts();
        UpgradeAPIs();
        UpgradePostCodeServiceKey();
        UpgradeIntrastatJnlLine(CountryCode);
        UpgradeDimensionSetEntry();
        UpgradeWordTemplateTables();
    end;

    local procedure UpgradeAPIs()
    begin
        UpgradeSalesShipmentLineDocumentId();
        UpgradePurchRcptLineDocumentId();
        UpgradePurchaseOrderEntityBuffer();
    end;

    local procedure UpdateBusinessRelation()
    var
        Contact: Record Contact;
    begin
        Contact.SetRange("Business Relation", '');
        if Contact.FindSet(true, false) then
            repeat
                Contact.UpdateBusinessRelation();
                if Contact.Modify() then;
            until Contact.Next() = 0;
    end;

    internal procedure UpgradeWordTemplateTables()
    var
        WordTemplate: Codeunit "Word Template";
    begin
        WordTemplate.AddTable(Database::Contact);
        WordTemplate.AddTable(Database::Customer);
        WordTemplate.AddTable(Database::Item);
        WordTemplate.AddTable(Database::Vendor);
    end;

    local procedure UpgradeSalesShipmentLineDocumentId()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentLine: Record "Sales Shipment Line";
        EnvironmentInformation: codeunit "Environment Information";
    begin
        if EnvironmentInformation.IsSaaS() then
            if SalesShipmentLine.Count() > GetSafeRecordCountForSaaSUpgrade() then
                exit;

        SalesShipmentHeader.SetLoadFields(SalesShipmentHeader."No.", SalesShipmentHeader.SystemId);
        if SalesShipmentHeader.FindSet() then
            repeat
                SalesShipmentLine.SetRange("Document No.", SalesShipmentHeader."No.");
                SalesShipmentLine.ModifyAll("Document Id", SalesShipmentHeader.SystemId);
            until SalesShipmentHeader.Next() = 0;
    end;

    local procedure LoadForwardLinks()
    var
        NamedForwardLink: Record "Named Forward Link";
    begin
        NamedForwardLink.Load();
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

    local procedure UpgradeIntegrationTableMappingFilterForOpportunities()
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        Opportunity: Record Opportunity;
        CRMSetupDefaults: Codeunit "CRM Setup Defaults";
        OldTableFilter: Text;
        NewTableFilter: Text;
    begin
        IntegrationTableMapping.SetRange(Name, 'OPPORTUNITY');
        IntegrationTableMapping.SetRange("Table ID", Database::Opportunity);
        IntegrationTableMapping.SetRange("Integration Table ID", Database::"CRM Opportunity");
        if IntegrationTableMapping.FindFirst() then begin
            OldTableFilter := IntegrationTableMapping.GetTableFilter();
            if OldTableFilter = '' then begin
                Opportunity.SetFilter(Status, '%1|%2', Opportunity.Status::"Not Started", Opportunity.Status::"In Progress");
                NewTableFilter := CRMSetupDefaults.GetTableFilterFromView(Database::Opportunity, Opportunity.TableCaption(), Opportunity.GetView());
                IntegrationTableMapping.SetTableFilter(NewTableFilter);
                IntegrationTableMapping.Modify();
            end;
        end;
    end;

    local procedure UpgradeIntegrationFieldMappingForOpportunities()
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        TempOpportunity: Record Opportunity temporary;
        TempCRMOpportunity: Record "CRM Opportunity" temporary;
    begin
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
    end;

    local procedure UpgradeIntegrationFieldMappingForContacts()
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        TempContact: Record Contact temporary;
    begin
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
    end;

    local procedure UpgradePurchRcptLineDocumentId()
    var
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        EnvironmentInformation: codeunit "Environment Information";
    begin
        if EnvironmentInformation.IsSaaS() then
            if PurchRcptLine.Count() > GetSafeRecordCountForSaaSUpgrade() then
                exit;

        PurchRcptHeader.SetLoadFields(PurchRcptHeader."No.", PurchRcptHeader.SystemId);
        if PurchRcptHeader.FindSet() then
            repeat
                PurchRcptLine.SetRange("Document No.", PurchRcptHeader."No.");
                PurchRcptLine.ModifyAll("Document Id", PurchRcptHeader.SystemId);
            until PurchRcptHeader.Next() = 0;
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
        IsolatedStorageManagement: Codeunit "Isolated Storage Management";
        IsolatedStorageValue: Text;
    begin
        if not PostCodeServiceConfig.Get() then
            exit;

        if not IsolatedStorageManagement.Get(PostCodeServiceConfig.ServiceKey, DataScope::Company, IsolatedStorageValue) then
            exit;

        if not IsolatedStorageManagement.Delete(PostCodeServiceConfig.ServiceKey, DataScope::Company) then;

        if IsolatedStorageValue = '' then
            IsolatedStorageValue := 'Disabled';

        PostCodeServiceConfig.SaveServiceKey(IsolatedStorageValue);
    end;

    local procedure UpgradeIntrastatJnlLine(CountryCode: Text)
    var
        IntrastatJnlLine: Record "Intrastat Jnl. Line";
    begin
        if CountryCode = ITCountryCodeTxt then
            exit;

        IntrastatJnlLine.SetRange(Type, IntrastatJnlLine.Type::Shipment);
        if IntrastatJnlLine.FindSet() then
            repeat
                IntrastatJnlLine."Country/Region of Origin Code" := IntrastatJnlLine.GetCountryOfOriginCode();
                IntrastatJnlLine."Partner VAT ID" := IntrastatJnlLine.GetPartnerID();
                IntrastatJnlLine.Modify();
            until IntrastatJnlLine.Next() = 0;
    end;

    local procedure UpgradeDimensionSetEntry()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        DimensionSetEntry: Record "Dimension Set Entry";
    begin
        if GeneralLedgerSetup.Get() then begin
            if GeneralLedgerSetup."Shortcut Dimension 3 Code" <> '' then begin
                DimensionSetEntry.SetRange("Dimension Code", GeneralLedgerSetup."Shortcut Dimension 3 Code");
                DimensionSetEntry.ModifyAll("Global Dimension No.", 3);
            end;
            if GeneralLedgerSetup."Shortcut Dimension 4 Code" <> '' then begin
                DimensionSetEntry.SetRange("Dimension Code", GeneralLedgerSetup."Shortcut Dimension 4 Code");
                DimensionSetEntry.ModifyAll("Global Dimension No.", 4);
            end;
            if GeneralLedgerSetup."Shortcut Dimension 5 Code" <> '' then begin
                DimensionSetEntry.SetRange("Dimension Code", GeneralLedgerSetup."Shortcut Dimension 5 Code");
                DimensionSetEntry.ModifyAll("Global Dimension No.", 5);
            end;
            if GeneralLedgerSetup."Shortcut Dimension 6 Code" <> '' then begin
                DimensionSetEntry.SetRange("Dimension Code", GeneralLedgerSetup."Shortcut Dimension 6 Code");
                DimensionSetEntry.ModifyAll("Global Dimension No.", 6);
            end;
            if GeneralLedgerSetup."Shortcut Dimension 7 Code" <> '' then begin
                DimensionSetEntry.SetRange("Dimension Code", GeneralLedgerSetup."Shortcut Dimension 7 Code");
                DimensionSetEntry.ModifyAll("Global Dimension No.", 7);
            end;
            if GeneralLedgerSetup."Shortcut Dimension 8 Code" <> '' then begin
                DimensionSetEntry.SetRange("Dimension Code", GeneralLedgerSetup."Shortcut Dimension 8 Code");
                DimensionSetEntry.ModifyAll("Global Dimension No.", 8);
            end;
        end;
    end;

    local procedure UpgradePurchaseOrderEntityBuffer()
    var
        PurchaseHeader: Record "Purchase Header";
        GraphMgtPurchOrderBuffer: Codeunit "Graph Mgt - Purch Order Buffer";
    begin
        PurchaseHeader.SETRANGE("Document Type", PurchaseHeader."Document Type"::Order);
        IF PurchaseHeader.FindSet() THEN
            repeat
                GraphMgtPurchOrderBuffer.InsertOrModifyFromPurchaseHeader(PurchaseHeader);
            until PurchaseHeader.Next() = 0;
    end;

    local procedure GetSafeRecordCountForSaaSUpgrade(): Integer
    begin
        exit(300000);
    end;
}

