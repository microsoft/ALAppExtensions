codeunit 5012 "Service Declaration Mgt."
{
    Permissions = TableData "Service Declaration Header" = imd,
                  TableData "Service Declaration Line" = imd;

    var
        TransactionTypeCodeNotSpecifiedInLineErr: Label 'A service transaction type code is not specified in the line no. %1 with %2 %3', Comment = '%1 = number of line;%2 = type of the line (item, resource, etc.);%3 = item/resource code';
        FeatureNotEnabledMessageTxt: Label 'The %1 page is part of the new Service Declaration feature, which is not yet enabled in your Business Central. An administrator can enable the feature on the Feature Management page.', Comment = '%1 - page caption';
        ServDeclLbl: Label 'Service Declaration';
        AssistedSetupTxt: Label 'Set up a service declaration';
        AssistedSetupDescriptionTxt: Label 'The Service Declaration it easy to export the servide declaration in the format that the authorities in your country require.';
        AssistedSetupHelpTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2203744', Locked = true;
        CurrentLbl: Label 'CURRENT';

    procedure IsFeatureEnabled() IsEnabled: Boolean
    var
        ServDeclSetup: Record "Service Declaration Setup";
        FeatureMgtFacade: Codeunit "Feature Management Facade";
    begin
        IsEnabled := FeatureMgtFacade.IsEnabled(GetServiceDeclarationFeatureKeyId()) and ServDeclSetup.Get();
        OnAfterCheckFeatureEnabled(IsEnabled);
    end;

    procedure IsServTransTypeEnabled(): Boolean
    var
        ServDeclSetup: Record "Service Declaration Setup";
    begin
        if not IsFeatureEnabled() then
            exit(false);
        if not ServDeclSetup.Get() then
            exit(false);
        exit(ServDeclSetup."Enable Serv. Trans. Types");
    end;

    procedure InsertSetup(var ServDeclSetup: Record "Service Declaration Setup")
    begin
        if InitServDeclSetup(ServDeclSetup) then
            ServDeclSetup.Insert();
        InsertVATReportsConfiguration();
    end;

    procedure InitServDeclSetup(var ServDeclSetup: Record "Service Declaration Setup"): Boolean
    begin
        if ServDeclSetup.Get() then
            exit(false);

        ServDeclSetup.Validate("Declaration No. Series", InsertDefaultDeclNoSeries());
        ServDeclSetup.Validate("Enable Serv. Trans. Types", true);
        ServDeclSetup.Validate("Show Serv. Decl. Overview", true);
        AssignDataExchDefToServDeclSetup(ServDeclSetup);
        OnAfterInitServDeclSetup(ServDeclSetup);
        exit(true);
    end;

    internal procedure InstallServDecl()
    var
        FeatureKey: Record "Feature Key";
        FeatureMgtFacade: Codeunit "Feature Management Facade";
    begin
        if FeatureMgtFacade.IsEnabled(GetServiceDeclarationFeatureKeyId()) then begin
            FeatureKey.Get(GetServiceDeclarationFeatureKeyId());
            FeatureKey.Validate(Enabled, FeatureKey.Enabled::None);
            FeatureKey.Modify(true);
        end;
    end;

    procedure GetVATReportVersion(): Code[10]
    begin
        exit(CurrentLbl);
    end;

    local procedure AssignDataExchDefToServDeclSetup(var ServDeclSetup: Record "Service Declaration Setup")
    var
        DataExchDef: Record "Data Exch. Def";
        TempBlob: Codeunit "Temp Blob";
        XMLOutStream: OutStream;
        XMLInStream: InStream;
        ServDeclDataExchDefCode: Code[20];
        DataExchangeXMLTxt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root>  <DataExchDef Code="SERVDECL-2022" Name="SERVICEDECLARATION" Type="5" ReadingWritingXMLport="1231" ExternalDataHandlingCodeunit="1277" ColumnSeparator="5" CustomColumnSeparator=";" FileType="1" ReadingWritingCodeunit="1276">    <DataExchLineDef LineType="1" Code="DEFAULT" Name="DEFAULT" ColumnCount="5">      <DataExchColumnDef ColumnNo="1" Name="Service Transaction Type" Show="false" DataType="0" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" />      <DataExchColumnDef ColumnNo="2" Name="Country/Region Code" Show="false" DataType="0" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" />      <DataExchColumnDef ColumnNo="3" Name="Currency Code" Show="false" DataType="0" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" />      <DataExchColumnDef ColumnNo="4" Name="Sales Amount" Show="false" DataType="2" DataFormat="&lt;Sign&gt;&lt;Integer&gt;&lt;Decimals&gt;" DataFormattingCulture="en-US" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" />      <DataExchColumnDef ColumnNo="5" Name="Purchase Amount" Show="false" DataType="2" DataFormat="&lt;Sign&gt;&lt;Integer&gt;&lt;Decimals&gt;" DataFormattingCulture="en-US" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" />      <DataExchMapping TableId="5024" Name="" MappingCodeunit="1269">        <DataExchFieldMapping ColumnNo="1" FieldID="5" />        <DataExchFieldMapping ColumnNo="2" FieldID="6" />        <DataExchFieldMapping ColumnNo="3" FieldID="7" />        <DataExchFieldMapping ColumnNo="4" FieldID="10" Optional="true" TransformationRule="ROUNDNEAR1">          <TransformationRules>            <Code>ROUNDNEAR1</Code>            <Description>Rounding decimal nearest to 1</Description>            <TransformationType>14</TransformationType>            <FindValue />            <ReplaceValue />            <StartPosition>0</StartPosition>            <Length>0</Length>            <DataFormat />            <DataFormattingCulture />            <NextTransformationRule />            <TableID>0</TableID>            <SourceFieldID>0</SourceFieldID>            <TargetFieldID>0</TargetFieldID>            <FieldLookupRule>0</FieldLookupRule>            <Precision>1.00</Precision>            <Direction>=</Direction>            <ExportFromDateType>0</ExportFromDateType>          </TransformationRules>        </DataExchFieldMapping>        <DataExchFieldMapping ColumnNo="5" FieldID="11" Optional="true" TransformationRule="ROUNDNEAR1">          <TransformationRules>            <Code>ROUNDNEAR1</Code>            <Description>Rounding decimal nearest to 1</Description>            <TransformationType>14</TransformationType>            <FindValue />            <ReplaceValue />            <StartPosition>0</StartPosition>            <Length>0</Length>            <DataFormat />            <DataFormattingCulture />            <NextTransformationRule />            <TableID>0</TableID>            <SourceFieldID>0</SourceFieldID>            <TargetFieldID>0</TargetFieldID>            <FieldLookupRule>0</FieldLookupRule>            <Precision>1.00</Precision>            <Direction>=</Direction>            <ExportFromDateType>0</ExportFromDateType>          </TransformationRules>        </DataExchFieldMapping>        <DataExchFieldGrouping FieldID="5" />        <DataExchFieldGrouping FieldID="6" />        <DataExchFieldGrouping FieldID="7" />      </DataExchMapping>    </DataExchLineDef>  </DataExchDef></root>';
        HandledDataExchDefCode: Code[20];
    begin
        OnBeforeAssignExchDefToServDeclSetup(HandledDataExchDefCode);
        if HandledDataExchDefCode <> '' then begin
            ServDeclSetup.Validate("Data Exch. Def. Code", HandledDataExchDefCode);
            exit;
        end;
        ServDeclDataExchDefCode := 'SERVDECL-2022';
        if not DataExchDef.Get(ServDeclDataExchDefCode) then begin
            TempBlob.CreateOutStream(XMLOutStream);
            XMLOutStream.WriteText(DataExchangeXMLTxt);
            TempBlob.CreateInStream(XMLInStream);
            Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", XMLInStream);
        end;
        ServDeclSetup.Validate("Data Exch. Def. Code", ServDeclDataExchDefCode);
    end;

    procedure InsertVATReportsConfiguration()
    var
        VATReportsConfiguration: Record "VAT Reports Configuration";
        IsHandled: Boolean;
    begin
        OnBeforeInsertVATReportsConfiguration(IsHandled);
        if IsHandled then
            exit;
        VATReportsConfiguration.Init();
        VATReportsConfiguration.Validate("VAT Report Type", VATReportsConfiguration."VAT Report Type"::"Service Declaration");
        VATReportsConfiguration.Validate("VAT Report Version", GetVATReportVersion());
        VATReportsConfiguration.Validate("Suggest Lines Codeunit ID", Codeunit::"Get Service Declaration Lines");
        VATReportsConfiguration.Validate("Submission Codeunit ID", Codeunit::"Export Service Declaration");
        if VATReportsConfiguration.Insert(true) then;
    end;

    local procedure InsertDefaultDeclNoSeries(): Code[20]
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        NoSeriesCode: Code[20];
    begin
        NoSeriesCode := 'SERVDECL';
        if NoSeries.Get(NoSeriesCode) then
            exit(NoSeriesCode);

        NoSeries.Init();
        NoSeries.Code := NoSeriesCode;
        NoSeries.Description := ServDeclLbl;
        NoSeries.Validate("Default Nos.", true);
        NoSeries.Validate("Manual Nos.", true);
        NoSeries.Insert(true);

        NoSeriesLine.Init();
        NoSeriesLine."Series Code" := NoSeries.Code;
        NoSeriesLine."Line No." := 10000;
        NoSeriesLine.Validate("Starting No.", NoSeriesCode + '00001');
        NoSeriesLine.Insert(true);
        NoSeriesLine.Validate("Allow Gaps in Nos.", true);
        NoSeriesLine.Modify(true);
        exit(NoSeriesCode);
    end;

    procedure ShowNotEnabledMessage(PageCaption: Text)
    begin
        Message(FeatureNotEnabledMessageTxt, PageCaption);
    end;

    local procedure IsSalesDocApplicableForServDecl(SalesHeader: Record "Sales Header"): Boolean
    var
        ServiceDeclarationSetup: Record "Service Declaration Setup";
    begin
        if not IsFeatureEnabled() then
            exit(false);

        ServiceDeclarationSetup.Get();
        case ServiceDeclarationSetup."Sell-To/Bill-To Customer No." of
            ServiceDeclarationSetup."Sell-To/Bill-To Customer No."::"Sell-to/Buy-from No.":
                exit(IsCustomerCountryRegionDiffFromCompanyInfoCountry(SalesHeader."Sell-to Customer No."));
            ServiceDeclarationSetup."Sell-To/Bill-To Customer No."::"Bill-to/Pay-to No.":
                exit(IsCustomerCountryRegionDiffFromCompanyInfoCountry(SalesHeader."Bill-to Customer No."));
        end;
    end;

    local procedure IsServDocApplicableForServDecl(ServHeader: Record "Service Header"): Boolean
    begin
        if not IsFeatureEnabled() then
            exit(false);

        exit(IsCustomerCountryRegionDiffFromCompanyInfoCountry(ServHeader."Customer No."));
    end;

    local procedure IsCustomerCountryRegionDiffFromCompanyInfoCountry(CustNo: Code[20]): Boolean
    var
        CompanyInformation: Record "Company Information";
        Customer: Record Customer;
    begin
        if CustNo = '' then
            exit(false);
        if not Customer.Get(CustNo) then
            exit(false);
        CompanyInformation.Get();
        exit(Customer."Country/Region Code" <> CompanyInformation."Country/Region Code");
    end;

    local procedure IsPurchDocApplicableForServDecl(PurchHeader: Record "Purchase Header"): Boolean
    var
        ServiceDeclarationSetup: Record "Service Declaration Setup";
    begin
        if not IsFeatureEnabled() then
            exit;

        ServiceDeclarationSetup.Get();
        case ServiceDeclarationSetup."Buy-From/Pay-To Vendor No." of
            ServiceDeclarationSetup."Buy-From/Pay-To Vendor No."::"Sell-to/Buy-from No.":
                exit(IsVendorCountryRegionDiffFromCompanyInfoCountry(PurchHeader."Buy-from Vendor No."));
            ServiceDeclarationSetup."Buy-From/Pay-To Vendor No."::"Bill-to/Pay-to No.":
                exit(IsVendorCountryRegionDiffFromCompanyInfoCountry(PurchHeader."Pay-to Vendor No."));
        end;
    end;

    local procedure IsVendorCountryRegionDiffFromCompanyInfoCountry(VendNo: Code[20]): Boolean
    var
        CompanyInformation: Record "Company Information";
        Vendor: Record Vendor;
    begin
        if VendNo = '' then
            exit(false);
        if not Vendor.Get(VendNo) then
            exit(false);
        CompanyInformation.Get();
        exit(Vendor."Country/Region Code" <> CompanyInformation."Country/Region Code");
    end;

    local procedure GetServiceDeclarationFeatureKeyId(): Text[50]
    begin
        exit('ServiceDeclaration');
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterAssistedSetup', '', true, true)]
    local procedure InsertIntoAssistedSetup()
    var
        ServDeclSetup: Record "Service Declaration Setup";
        GuidedExperience: Codeunit "Guided Experience";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
    begin
        GuidedExperience.InsertAssistedSetup(AssistedSetupTxt, CopyStr(AssistedSetupTxt, 1, 50), AssistedSetupDescriptionTxt, 5, ObjectType::Page, Page::"Serv. Decl. Setup Wizard", AssistedSetupGroup::FinancialReporting,
                                            '', VideoCategory::FinancialReporting, AssistedSetupHelpTxt);
        if ServDeclSetup.Get() and IsFeatureEnabled() then
            GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"Serv. Decl. Setup Wizard");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Feature Management Facade", 'OnAfterFeatureEnableConfirmed', '', true, true)]
    local procedure OnAfterFeatureEnableConfirmed(var FeatureKey: Record "Feature Key")
    var
        ServDecletupWizard: Page "Serv. Decl. Setup Wizard";
    begin
        if FeatureKey.ID = GetServiceDeclarationFeatureKeyId() then
            if ServDecletupWizard.RunModal() = Action::OK then
                if not ServDecletupWizard.IsSetupFinished() then
                    Error('');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterCheckSellToCust', '', false, false)]
    local procedure OnAfterCheckSellToCustInSalesHeader(var SalesHeader: Record "Sales Header"; xSalesHeader: Record "Sales Header"; Customer: Record Customer)
    begin
        SalesHeader."Applicable For Serv. Decl." := IsSalesDocApplicableForServDecl(SalesHeader);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterCheckBillToCust', '', false, false)]
    local procedure OnAfterCheckBillToCustInSalesHeader(var SalesHeader: Record "Sales Header"; xSalesHeader: Record "Sales Header"; Customer: Record Customer)
    begin
        SalesHeader."Applicable For Serv. Decl." := IsSalesDocApplicableForServDecl(SalesHeader);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterValidateEvent', 'Customer No.', false, false)]
    local procedure OnAfterValidateCustNoInServHeader(var Rec: Record "Service Header")
    begin
        Rec."Applicable For Serv. Decl." := IsServDocApplicableForServDecl(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterCheckBuyFromVendor', '', false, false)]
    local procedure OnAfterCheckBuyFromVendorInPurchHeader(var PurchaseHeader: Record "Purchase Header"; xPurchaseHeader: Record "Purchase Header"; Vendor: Record Vendor)
    begin
        PurchaseHeader."Applicable For Serv. Decl." := IsPurchDocApplicableForServDecl(PurchaseHeader);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterCheckPayToVendor', '', false, false)]
    local procedure OnAfterCheckPayToVendorInPurchHeader(var PurchaseHeader: Record "Purchase Header"; xPurchaseHeader: Record "Purchase Header"; Vendor: Record Vendor)
    begin
        PurchaseHeader."Applicable For Serv. Decl." := IsPurchDocApplicableForServDecl(PurchaseHeader);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterAssignItemValues', '', false, false)]
    local procedure OnAfterAssignItemValuesInSalesLine(var SalesLine: Record "Sales Line"; Item: Record Item)
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesLine."Applicable For Serv. Decl." := false;
        if not IsFeatureEnabled() then
            exit;
        if Item.Type = Item.Type::Service then begin
            SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
            SalesLine."Service Transaction Type Code" := Item."Service Transaction Type Code";
            SalesLine."Applicable For Serv. Decl." :=
              SalesHeader."Applicable For Serv. Decl." and (not Item."Exclude From Service Decl.");
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Line", 'OnAfterAssignItemValues', '', false, false)]
    local procedure OnAfterAssignItemValuesInServiceLine(var ServiceLine: Record "Service Line"; Item: Record Item)
    var
        ServHeader: Record "Service Header";
    begin
        ServiceLine."Applicable For Serv. Decl." := false;
        if not IsFeatureEnabled() then
            exit;
        if Item.Type = Item.Type::Service then begin
            ServHeader.Get(ServiceLine."Document Type", ServiceLine."Document No.");
            ServiceLine."Service Transaction Type Code" := Item."Service Transaction Type Code";
            ServiceLine."Applicable For Serv. Decl." :=
              ServHeader."Applicable For Serv. Decl." and (not Item."Exclude From Service Decl.");
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterAssignResourceValues', '', false, false)]
    local procedure OnAfterAssignResourceValuesInSalesLine(var SalesLine: Record "Sales Line"; Resource: Record Resource)
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesLine."Applicable For Serv. Decl." := false;
        if not IsFeatureEnabled() then
            exit;
        SalesLine."Service Transaction Type Code" := Resource."Service Transaction Type Code";
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        SalesLine."Applicable For Serv. Decl." :=
          SalesHeader."Applicable For Serv. Decl." and (not Resource."Exclude From Service Decl.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Line", 'OnAfterAssignResourceValues', '', false, false)]
    local procedure OnAfterAssignResourceValuesInServiceLine(var ServiceLine: Record "Service Line"; Resource: Record Resource)
    var
        ServHeader: Record "Service Header";
    begin
        ServiceLine."Applicable For Serv. Decl." := false;
        if not IsFeatureEnabled() then
            exit;
        ServiceLine."Service Transaction Type Code" := Resource."Service Transaction Type Code";
        ServHeader.Get(ServiceLine."Document Type", ServiceLine."Document No.");
        ServiceLine."Applicable For Serv. Decl." :=
          ServHeader."Applicable For Serv. Decl." and (not Resource."Exclude From Service Decl.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterAssignItemChargeValues', '', false, false)]
    local procedure OnAfterAssignItemChargeValuesInSalesLine(var SalesLine: Record "Sales Line"; ItemCharge: Record "Item Charge")
    var
        ServiceDeclarationSetup: Record "Service Declaration Setup";
        SalesHeader: Record "Sales Header";
    begin
        SalesLine."Applicable For Serv. Decl." := false;
        if not IsFeatureEnabled() then
            exit;
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        ServiceDeclarationSetup.Get();
        SalesLine."Applicable For Serv. Decl." :=
          SalesHeader."Applicable For Serv. Decl." and ServiceDeclarationSetup."Report Item Charges" and (not ItemCharge."Exclude From Service Decl.");
        SalesLine."Service Transaction Type Code" := ItemCharge."Service Transaction Type Code";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterAssignItemValues', '', false, false)]
    local procedure OnAfterAssignItemValuesInPurchLine(var PurchLine: Record "Purchase Line"; Item: Record Item)
    var
        PurchHeader: Record "Purchase Header";
    begin
        PurchLine."Applicable For Serv. Decl." := false;
        if not IsFeatureEnabled() then
            exit;
        if Item.Type = Item.Type::Service then begin
            PurchLine."Service Transaction Type Code" := Item."Service Transaction Type Code";
            PurchHeader.Get(PurchLine."Document Type", PurchLine."Document No.");
            PurchLine."Applicable For Serv. Decl." :=
              PurchHeader."Applicable For Serv. Decl." and (not Item."Exclude From Service Decl.");
        end;
    end;


    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterAssignResourceValues', '', false, false)]
    local procedure OnAfterAssignResourceValuesInPurchLine(var PurchaseLine: Record "Purchase Line"; Resource: Record Resource)
    var
        PurchHeader: Record "Purchase Header";
    begin
        PurchaseLine."Applicable For Serv. Decl." := false;
        if not IsFeatureEnabled() then
            exit;
        PurchaseLine."Service Transaction Type Code" := Resource."Service Transaction Type Code";
        PurchHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
        PurchaseLine."Applicable For Serv. Decl." :=
          PurchHeader."Applicable For Serv. Decl." and (not Resource."Exclude From Service Decl.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterAssignItemChargeValues', '', false, false)]
    local procedure OnAfterAssignItemChargeValuesInPurchLine(var PurchLine: Record "Purchase Line"; ItemCharge: Record "Item Charge")
    var
        ServiceDeclarationSetup: Record "Service Declaration Setup";
        PurchHeader: Record "Purchase Header";
    begin
        PurchLine."Applicable For Serv. Decl." := false;
        if not IsFeatureEnabled() then
            exit;
        ServiceDeclarationSetup.Get();
        PurchHeader.Get(PurchLine."Document Type", PurchLine."Document No.");
        PurchLine."Applicable For Serv. Decl." :=
          PurchHeader."Applicable For Serv. Decl." and ServiceDeclarationSetup."Report Item Charges" and (not ItemCharge."Exclude From Service Decl.");
        PurchLine."Service Transaction Type Code" := ItemCharge."Service Transaction Type Code";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterInitItemLedgEntry', '', false, false)]
    local procedure OnAfterInitItemLedgEntry(var NewItemLedgEntry: Record "Item Ledger Entry"; ItemJournalLine: Record "Item Journal Line"; var ItemLedgEntryNo: Integer)
    begin
        if not IsFeatureEnabled() then
            exit;
        NewItemLedgEntry."Service Transaction Type Code" := ItemJournalLine."Service Transaction Type Code";
        NewItemLedgEntry."Applicable For Serv. Decl." := ItemJournalLine."Applicable For Serv. Decl.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnBeforeInsertValueEntry', '', false, false)]
    local procedure OnBeforeInsertValueEntry(var ValueEntry: Record "Value Entry"; ItemJournalLine: Record "Item Journal Line"; var ItemLedgerEntry: Record "Item Ledger Entry"; var ValueEntryNo: Integer; var InventoryPostingToGL: Codeunit "Inventory Posting To G/L"; CalledFromAdjustment: Boolean)
    begin
        if not IsFeatureEnabled() then
            exit;
        ValueEntry."Service Transaction Type Code" := ItemJournalLine."Service Transaction Type Code";
        ValueEntry."Applicable For Serv. Decl." := ItemJournalLine."Applicable For Serv. Decl.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnCodeOnAfterCheck', '', false, false)]
    local procedure OnReleaseSalesDoc(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var LinesWereModified: Boolean)
    var
        ServiceDeclarationSetup: Record "Service Declaration Setup";
        ServDeclSalesLine: Record "Sales Line";
        ErrorMessage: Text;
    begin
        if not IsFeatureEnabled() then
            exit;

        if not SalesHeader."Applicable For Serv. Decl." then
            exit;

        if not IsServTransTypeEnabled() then
            exit;

        ServDeclSalesLine.SetRange("Document Type", SalesHeader."Document Type");
        ServDeclSalesLine.SetRange("Document No.", SalesHeader."No.");
        ServDeclSalesLine.SetRange("Applicable For Serv. Decl.", true);
        ServDeclSalesLine.SetRange("Service Transaction Type Code", '');
        ServiceDeclarationSetup.Get();
        if not ServiceDeclarationSetup."Report Item Charges" then
            ServDeclSalesLine.SetFilter(Type, '<>%1', ServDeclSalesLine.Type::"Charge (Item)");
        if ServDeclSalesLine.FindFirst() then begin
            ErrorMessage :=
              StrSubstNo(
                TransactionTypeCodeNotSpecifiedInLineErr, ServDeclSalesLine."Line No.",
                Format(ServDeclSalesLine.Type), ServDeclSalesLine."No.");
            Error(ErrorMessage);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Service Document", 'OnCodeOnAfterCheck', '', false, false)]
    local procedure OnReleaseServDoc(ServiceHeader: Record "Service Header"; var ServiceLine: Record "Service Line")
    var
        ServDeclServLine: Record "Service Line";
        ErrorMessage: Text;
    begin
        if not IsFeatureEnabled() then
            exit;

        if not ServiceHeader."Applicable For Serv. Decl." then
            exit;

        if not IsServTransTypeEnabled() then
            exit;

        ServDeclServLine.SetRange("Document Type", ServiceHeader."Document Type");
        ServDeclServLine.SetRange("Document No.", ServiceHeader."No.");
        ServDeclServLine.SetRange("Applicable For Serv. Decl.", true);
        ServDeclServLine.SetRange("Service Transaction Type Code", '');
        if ServDeclServLine.FindFirst() then begin
            ErrorMessage :=
              StrSubstNo(
                TransactionTypeCodeNotSpecifiedInLineErr, ServDeclServLine."Line No.",
                Format(ServDeclServLine.Type), ServDeclServLine."No.");
            Error(ErrorMessage);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Purchase Document", 'OnCodeOnAfterCheck', '', false, false)]
    local procedure OnReleasePurchDoc(PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line"; var LinesWereModified: Boolean)
    var
        ServiceDeclarationSetup: Record "Service Declaration Setup";
        ServDeclPurchLine: Record "Purchase Line";
        ErrorMessage: Text;
    begin
        if not IsFeatureEnabled() then
            exit;

        if not PurchaseHeader."Applicable For Serv. Decl." then
            exit;

        if not IsServTransTypeEnabled() then
            exit;

        ServDeclPurchLine.SetRange("Document Type", PurchaseHeader."Document Type");
        ServDeclPurchLine.SetRange("Document No.", PurchaseHeader."No.");
        ServDeclPurchLine.SetRange("Applicable For Serv. Decl.", true);
        ServDeclPurchLine.SetRange("Service Transaction Type Code", '');
        ServiceDeclarationSetup.Get();
        if not ServiceDeclarationSetup."Report Item Charges" then
            ServDeclPurchLine.SetFilter(Type, '<>%1', ServDeclPurchLine.Type::"Charge (Item)");
        if ServDeclPurchLine.FindFirst() then begin
            ErrorMessage :=
              StrSubstNo(
                TransactionTypeCodeNotSpecifiedInLineErr, ServDeclPurchLine."Line No.",
                Format(ServDeclPurchLine.Type), ServDeclPurchLine."No.");
            Error(ErrorMessage);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterCopyItemJnlLineFromSalesLine', '', false, false)]
    local procedure OnAfterCopyItemJnlLineFromSalesLine(var ItemJnlLine: Record "Item Journal Line"; SalesLine: Record "Sales Line")
    begin
        if not IsFeatureEnabled() then
            exit;
        ItemJnlLine."Service Transaction Type Code" := SalesLine."Service Transaction Type Code";
        ItemJnlLine."Applicable For Serv. Decl." := SalesLine."Applicable For Serv. Decl.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnPostItemChargePerOrderOnAfterCopyToItemJnlLine', '', false, false)]
    local procedure OnPostItemChargePerSalesOrderOnAfterCopyToItemJnlLine(var ItemJournalLine: Record "Item Journal Line"; var SalesLine: Record "Sales Line"; GeneralLedgerSetup: Record "General Ledger Setup"; QtyToInvoice: Decimal; var TempItemChargeAssignmentSales: Record "Item Charge Assignment (Sales)" temporary)
    begin
        if not IsFeatureEnabled() then
            exit;
        ItemJournalLine."Service Transaction Type Code" := SalesLine."Service Transaction Type Code";
        ItemJournalLine."Applicable For Serv. Decl." := SalesLine."Applicable For Serv. Decl.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnPostItemChargePerOrderOnAfterCopyToItemJnlLine', '', false, false)]
    local procedure OnPostItemChargePerPurchOrderOnAfterCopyToItemJnlLine(var ItemJournalLine: Record "Item Journal Line"; var PurchaseLine: Record "Purchase Line"; GeneralLedgerSetup: Record "General Ledger Setup"; QtyToInvoice: Decimal; var TempItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)" temporary; PurchLine: Record "Purchase Line")
    begin
        if not IsFeatureEnabled() then
            exit;
        ItemJournalLine."Service Transaction Type Code" := PurchaseLine."Service Transaction Type Code";
        ItemJournalLine."Applicable For Serv. Decl." := PurchaseLine."Applicable For Serv. Decl.";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterCopyItemJnlLineFromServLine', '', false, false)]
    local procedure OnAfterCopyItemJnlLineFromServiceLine(var ItemJnlLine: Record "Item Journal Line"; ServLine: Record "Service Line")
    begin
        if not IsFeatureEnabled() then
            exit;
        ItemJnlLine."Service Transaction Type Code" := ServLine."Service Transaction Type Code";
        ItemJnlLine."Applicable For Serv. Decl." := ServLine."Applicable For Serv. Decl.";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterCopyItemJnlLineFromPurchLine', '', false, false)]
    local procedure OnAfterCopyItemJnlLineFromPurchaseLine(var ItemJnlLine: Record "Item Journal Line"; PurchLine: Record "Purchase Line")
    begin
        if not IsFeatureEnabled() then
            exit;
        ItemJnlLine."Service Transaction Type Code" := PurchLine."Service Transaction Type Code";
        ItemJnlLine."Applicable For Serv. Decl." := PurchLine."Applicable For Serv. Decl.";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Res. Journal Line", 'OnAfterCopyResJnlLineFromSalesLine', '', false, false)]
    local procedure OnAfterCopyResJnlLineFromSalesLine(var SalesLine: Record "Sales Line"; var ResJnlLine: Record "Res. Journal Line")
    begin
        if not IsFeatureEnabled() then
            exit;
        ResJnlLine."Service Transaction Type Code" := SalesLine."Service Transaction Type Code";
        ResJnlLine."Applicable For Serv. Decl." := SalesLine."Applicable For Serv. Decl.";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Res. Journal Line", 'OnAfterCopyResJnlLineFromPurchaseLine', '', false, false)]
    local procedure OnAfterCopyResJnlLineFromPurchaseLine(PurchaseLine: Record "Purchase Line"; var ResJournalLine: Record "Res. Journal Line")
    begin
        if not IsFeatureEnabled() then
            exit;
        ResJournalLine."Service Transaction Type Code" := PurchaseLine."Service Transaction Type Code";
        ResJournalLine."Applicable For Serv. Decl." := PurchaseLine."Applicable For Serv. Decl.";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Res. Ledger Entry", 'OnAfterCopyFromResJnlLine', '', false, false)]
    local procedure OnAfterCopyFromResJnlLine(var ResLedgerEntry: Record "Res. Ledger Entry"; ResJournalLine: Record "Res. Journal Line")
    begin
        if not IsFeatureEnabled() then
            exit;
        ResLedgerEntry."Service Transaction Type Code" := ResJournalLine."Service Transaction Type Code";
        ResLedgerEntry."Applicable For Serv. Decl." := ResJournalLine."Applicable For Serv. Decl.";
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterCheckFeatureEnabled(var IsEnabled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAssignExchDefToServDeclSetup(var HandledDataExchDefCode: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertVATReportsConfiguration(var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitServDeclSetup(var ServDeclSetup: Record "Service Declaration Setup")
    begin

    end;
}
