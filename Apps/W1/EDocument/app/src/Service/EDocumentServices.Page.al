// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.eServices.EDocument.IO;
using Microsoft.eServices.EDocument.Processing.Import;
using System.DataAdministration;
using System.Apps.AppSource;
using System.Telemetry;

page 6103 "E-Document Services"
{
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    Caption = 'E-Document Services';
    CardPageID = "E-Document Service";
    PageType = List;
    SourceTable = "E-Document Service";
    AdditionalSearchTerms = 'EServices,Service,edoc,edocument';
    DataCaptionFields = Code;
    Editable = false;
    InsertAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Code; Rec.Code)
                {
                    ToolTip = 'Specifies the code of the electronic export setup.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the electronic export setup.';
                }
                field("Export Format"; Rec."Document Format")
                {
                    ToolTip = 'Specifies the export format of the electronic export setup.';
                }
                field("Service Integration V2"; Rec."Service Integration V2")
                {
                    Caption = 'Service Integration';
                    ToolTip = 'Specifies service integration for the electronic document setup.';
                }
#if not CLEAN26
                field("Service Integration"; Rec."Service Integration")
                {
                    Caption = 'Service Integration (Legacy)';
                    ToolTip = 'Specifies service integration for the electronic document setup.';
                    ObsoleteTag = '26.0';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Moved to field "Service Integration V2" on "E-Document Service" table';
                }
#endif
            }
        }
    }
    actions
    {
        area(Processing)
        {
            group(RetentionPolicy)
            {
                Caption = 'Retention Policy';

                action(LogRetentionPolicy)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'E-Document Log';
                    Tooltip = 'View or edit the retention policy.';
                    Image = Delete;
                    RunObject = Page "Retention Policy Setup Card";
                    RunPageLink = "Table Id" = filter(6124); //Database::"E-Document Log"
                    AccessByPermission = tabledata "Retention Policy Setup" = R;
                    RunPageMode = View;
                    Ellipsis = true;
                }

                action(IntegrationLogRetentionPolicy)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'E-Document Integration Log';
                    Tooltip = 'View or edit the retention policy.';
                    Image = Delete;
                    RunObject = Page "Retention Policy Setup Card";
                    RunPageLink = "Table Id" = filter(6127); //Database::"E-Document Integration Log"
                    AccessByPermission = tabledata "Retention Policy Setup" = R;
                    RunPageMode = View;
                    Ellipsis = true;
                }
                action(MappingLogRetentionPolicy)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'E-Document Mapping Log';
                    Tooltip = 'View or edit the retention policy.';
                    Image = Delete;
                    RunObject = Page "Retention Policy Setup Card";
                    RunPageLink = "Table Id" = filter(6123); //Database::"E-Doc. Mapping Log"
                    AccessByPermission = tabledata "Retention Policy Setup" = R;
                    RunPageMode = View;
                    Ellipsis = true;
                }
                action(StorageLogRetentionPolicy)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'E-Document Data storage';
                    Tooltip = 'View or edit the retention policy.';
                    Image = Delete;
                    RunObject = Page "Retention Policy Setup Card";
                    RunPageLink = "Table Id" = filter(6125); //Database::"E-Doc. Data Storage"
                    AccessByPermission = tabledata "Retention Policy Setup" = R;
                    RunPageMode = View;
                    Ellipsis = true;
                }
            }
            group(DataExchange)
            {
                Caption = 'Data Exchange';

                action(ResetFormats)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Reset Data Exch. Formats';
                    Tooltip = 'Reset E-Document provided Data Exch. Formats';
                    Image = Restore;

                    trigger OnAction()
                    var
                        EDocumentInstall: Codeunit "E-Document Install";
                    begin
                        EDocumentInstall.ImportInvoiceXML();
                        EDocumentInstall.ImportCreditMemoXML();
                        EDocumentInstall.ImportSalesInvoiceXML();
                        EDocumentInstall.ImportSalesCreditMemoXML();
                        EDocumentInstall.ImportServiceInvoiceXML();
                        EDocumentInstall.ImportServiceCreditMemoXML();
                    end;
                }
            }
            action(ConfigureAdditionalFields)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Configure additional fields';
                Tooltip = 'Configure the additional fields to consider when importing an E-Document.';
                Image = AddContacts;
                RunObject = page "EDoc Additional Fields Setup";
            }
        }
        area(Navigation)
        {
            action(OpenAppSourceInstallableServices)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Install E-Document integrations from AppSource';
                Tooltip = 'Open AppSource to install services.';
                Image = Insert;

                trigger OnAction()
                var
                    AppSourceProductList: Page "AppSource Product List";
                    RecordRef: RecordRef;
                    FieldRef, FieldRef2 : FieldRef;
                    Variant: Variant;
                begin
                    RecordRef.Open(2515); // Record "AppSource Product"
                    FieldRef := RecordRef.Field(4);
                    FieldRef.SetRange('microsoftdynsmb');
                    FieldRef2 := RecordRef.Field(2);
                    FieldRef2.SetFilter('E-Document*');

                    Variant := RecordRef;
                    AppSourceProductList.SetTableView(Variant);
                    AppSourceProductList.RunModal();
                end;

            }
        }
    }

    trigger OnOpenPage()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        EDocumentHelper: Codeunit "E-Document Processing";
        EDocumentInstall: Codeunit "E-Document Install";
    begin
        FeatureTelemetry.LogUptake('0000KZ9', EDocumentHelper.GetEDocTok(), Enum::"Feature Uptake Status"::Discovered);
        EDocumentInstall.InsertDataExch();
    end;
}
