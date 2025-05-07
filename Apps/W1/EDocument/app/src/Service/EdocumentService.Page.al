// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using System.Telemetry;
using Microsoft.eServices.EDocument.IO.Peppol;
using Microsoft.eServices.EDocument.Processing.Import;
page 6133 "E-Document Service"
{
    ApplicationArea = Basic, Suite;
    PageType = Card;
    Caption = 'E-Document Service';
    SourceTable = "E-Document Service";
    DataCaptionFields = Code;
    AdditionalSearchTerms = 'Edoc service,Electronic Document,E-doc,e-doc';

    layout
    {
        area(content)
        {
            group(General)
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
                    ToolTip = 'Specifies integration code for the electronic export setup.';
                }
            }
            group(ImportProcessing)
            {
                Caption = 'Importing';
                group(Import)
                {
                    ShowCaption = false;
                    field("Auto Import"; Rec."Auto Import")
                    {
                        Caption = 'Automatic Import';
                        ToolTip = 'Specifies whether to automatically import documents from the service.';
                    }
                    group(Importsettings)
                    {
                        ShowCaption = false;
                        Visible = Rec."Auto Import";
                        field("Import Start Time"; Rec."Import Start Time")
                        {
                            ToolTip = 'Specifies import jos starting time.';
                        }
                        field("Import Minutes between runs"; Rec."Import Minutes between runs")
                        {
                            ToolTip = 'Specifies the number of minutes between running import job.';
                        }
                    }
                }
                field("Automatic Processing"; Rec."Automatic Import Processing")
                {
                }

                field("Import Process"; Rec."Import Process")
                {
                    ToolTip = 'Specifies the version of the import process to use for incoming e-documents.';
                    Visible = false;
                }
                group(ImportParamenters)
                {
                    Caption = 'Parameters';
                    Visible = Rec."Import Process" = Enum::"E-Document Import Process"::"Version 1.0";

                    field("Validate Receiving Company"; Rec."Validate Receiving Company")
                    {
                        ToolTip = 'Specifies if receiving company information must be validated during the import.';
                    }
                    field("Resolve Unit Of Measure"; Rec."Resolve Unit Of Measure")
                    {
                        ToolTip = 'Specifies if unit of measure shall be resolved during the import.';
                    }
                    field("Lookup Item Reference"; Rec."Lookup Item Reference")
                    {
                        ToolTip = 'Specifies if an item shall be searched by the item reference during the import.';
                    }
                    field("Lookup Item GTIN"; Rec."Lookup Item GTIN")
                    {
                        ToolTip = 'Specifies if an item shall be searched by GTIN during the import.';
                    }
                    field("Lookup Account Mapping"; Rec."Lookup Account Mapping")
                    {
                        ToolTip = 'Specifies if an account shall be searched in the Account Mapping by the incoming text during the import.';
                    }
                    field("Validate Line Discount"; Rec."Validate Line Discount")
                    {
                        ToolTip = 'Specifies if a line discount shall be validated during the import.';
                    }
                    field("Apply Invoice Discount"; Rec."Apply Invoice Discount")
                    {
                        ToolTip = 'Specifies if an invoice discount shall be applied during the import.';
                    }
                    field("Verify Total"; Rec."Verify Totals")
                    {
                        ToolTip = 'Specifies if an invoice total shall be verified during the import.';
                    }
                    field("Create Journal Lines"; Rec."Create Journal Lines")
                    {
                        ToolTip = 'Specifies if journal line must be created instead of purchase document. Only applicable if vendor receives e-document to purchase invoice.';
                    }
                    field("General Journal Template Name"; Rec."General Journal Template Name")
                    {
                        ToolTip = 'Specifies the General Journal Template Name used for journal line creation.';
                    }
                    field("General Journal Batch Name"; Rec."General Journal Batch Name")
                    {
                        ToolTip = 'Specifies the General Journal Batch Name used for journal line creation.';
                    }

                }
            }
            group(ExportProcessing)
            {
                Caption = 'Exporting';

                group(Batch)
                {
                    ShowCaption = false;
                    field("Use Batch Processing"; Rec."Use Batch Processing")
                    {
                        Caption = 'Batch Exporting';
                        ToolTip = 'Specifies if service uses batch processing for export.';
                    }
                    group(BatchSettings)
                    {
                        Caption = 'Batch Settings';
                        Visible = Rec."Use Batch Processing";

                        field("Batch Mode"; Rec."Batch Mode")
                        {
                            ToolTip = 'Specifies the mode of batch processing used for export.';
                        }

                        group(ThresholdSettings)
                        {
                            ShowCaption = false;
                            Visible = Rec."Batch Mode" = Enum::"E-Document Batch Mode"::Threshold;
                            field("Batch Threshold"; Rec."Batch Threshold")
                            {
                                ToolTip = 'Specifies the threshold of batch processing used for export.';
                            }
                        }
                        group(RecurrentSettings)
                        {
                            ShowCaption = false;
                            Visible = Rec."Batch Mode" = Enum::"E-Document Batch Mode"::Recurrent;
                            field("Batch Start Time"; Rec."Batch Start Time")
                            {
                                ToolTip = 'Specifies the start time of batch processing job.';
                            }
                            field("Batch Minutes between runs"; Rec."Batch Minutes between runs")
                            {
                                ToolTip = 'Specifies the number of minutes between batch processing jobs.';
                            }
                        }
                    }
                }
                group(Parameters)
                {
                    Caption = 'Parameters';
                    Visible = Rec."Document Format" = Rec."Document Format"::"PEPPOL BIS 3.0";

                    field("Embed PDF in export"; Rec."Embed PDF in export")
                    {
                    }
                }

            }
            part(EDocumentDataExchDef; "E-Doc. Service Data Exch. Sub")
            {
                ApplicationArea = All;
                Caption = 'Data Exchange Definition';
                SubPageLink = "E-Document Format Code" = field(Code);
                Visible = Rec."Document Format" = Rec."Document Format"::"Data Exchange";
            }
            part(EDocumentExportFormatMapping; "E-Doc. Mapping Part")
            {
                Caption = 'Export Mapping';
                SubPageLink = Code = field(Code), "For Import" = const(false);
                Visible = false;
                Enabled = false;
            }
            part(EDocumentImportFormatMapping; "E-Doc. Mapping Part")
            {
                Caption = 'Import Mapping';
                SubPageLink = Code = field(Code), "For Import" = const(true);
                Visible = false;
                Enabled = false;
            }
            group(ObsoletedFields)
            {
                Caption = 'Obsoleted fields';
                Visible = LegacyIntegrationVisible;

                label(ObsoletedFieldDescription)
                {
                    Caption = 'Obsoleted fields are visible through out the deprecation period. These should not be used in new implementations, and existing implementations should migrate to the new fields before the deprecation period ends.';
                }
#if not CLEAN26
                field("Service Integration"; Rec."Service Integration")
                {
                    Caption = 'Service Integration (Obsoleted)';
                    ToolTip = 'Specifies the integration used for sending and receiving e-documents. Integration is build on legacy implementation that will be deprecated in future releases.';
                    ObsoleteTag = '26.0';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced with field "Service Integration V2"';
                }
#endif
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("SetupServiceIntegration")
            {
                Caption = 'Set up service integration';
                ToolTip = 'Set up service integration';
                Image = Setup;

                trigger OnAction()
                begin
                    RunSetupServiceIntegration();
                end;
            }
            action(SupportedDocTypes)
            {
                Caption = 'Configure documents to export.';
                ToolTip = 'Set up what documents framework will export.';
                Image = Documents;
                RunObject = Page "E-Doc Service Supported Types";
                RunPageLink = "E-Document Service Code" = field(Code);
            }
            action(Receive)
            {
                Caption = 'Receive';
                ToolTip = 'Manually trigger receive';
                Image = Download;

                trigger OnAction()
                begin
                    ReceiveDocs();
                end;
            }
            action(ShowObsoletedFields)
            {
                Caption = 'Show obsoleted fields';
                ToolTip = 'Show obsoleted Fields';
                Image = Setup;

                trigger OnAction()
                begin
                    LegacyIntegrationVisible := true;
                end;
            }
        }
        area(Navigation)
        {
            action(OpenExportMapping)
            {
                Caption = 'Export mapping setup';
                ToolTip = 'Opens export mapping setup';
                Image = Setup;

                trigger OnAction()
                var
                    ExportMapping: Record "E-Doc. Mapping";
                    ExportMappingPart: Page "E-Doc. Mapping Part";
                begin
                    ExportMapping.SetRange(Code, Rec.Code);
                    ExportMapping.SetRange("For Import", false);
                    ExportMappingPart.SetTableView(ExportMapping);
                    ExportMappingPart.RunModal();
                end;
            }
            action(OpenImportMapping)
            {
                Caption = 'Import mapping setup';
                ToolTip = 'Opens import mapping setup';
                Image = Setup;

                trigger OnAction()
                var
                    ImportMapping: Record "E-Doc. Mapping";
                    ImportMappingPart: Page "E-Doc. Mapping Part";
                begin
                    ImportMapping.SetRange(Code, Rec.Code);
                    ImportMapping.SetRange("For Import", true);
                    ImportMappingPart.SetTableView(ImportMapping);
                    ImportMappingPart.RunModal();
                end;
            }
        }
        area(Promoted)
        {
            actionref("Promoted Setup Service Integration"; SetupServiceIntegration) { }
            actionref("Promoted Supported Doc Types"; SupportedDocTypes) { }
            actionref("Promoted Receive"; Receive) { }
        }
    }

    var
        ServiceIntegrationSetupMsg: Label 'There is no configuration setup for this service integration.';
        DocNotCreatedQst: Label 'Failed to create new Purchase %1 from E-Document. Do you want to open E-Document to see reported errors?', Comment = '%1 - Purchase Document Type';
        LegacyIntegrationVisible: Boolean;


    trigger OnOpenPage()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        EDocumentHelper: Codeunit "E-Document Processing";
    begin
        FeatureTelemetry.LogUptake('0000KZ6', EDocumentHelper.GetEDocTok(), Enum::"Feature Uptake Status"::Discovered);
        CurrPage.EDocumentExportFormatMapping.Page.SaveAsImport(false);
        CurrPage.EDocumentImportFormatMapping.Page.SaveAsImport(true);
#if not CLEAN26
        LegacyIntegrationVisible := (Rec."Service Integration" <> Rec."Service Integration"::"No Integration");
#endif
    end;

#if not CLEAN26
    local procedure RunSetupServiceIntegration()
    var
        EDocumentIntegration: Interface "E-Document Integration";
        SetupPage, SetupTable : Integer;
        PageOpened: Boolean;
    begin
        OnBeforeOpenServiceIntegrationSetupPage(Rec, PageOpened);
        if not PageOpened then begin
            EDocumentIntegration := Rec."Service Integration";
            EDocumentIntegration.GetIntegrationSetup(SetupPage, SetupTable);
            if SetupPage <> 0 then begin
                PageOpened := true;
                Page.Run(SetupPage);
            end;
        end;

        if not PageOpened then
            Message(ServiceIntegrationSetupMsg);
    end;
#else
    local procedure RunSetupServiceIntegration()
    var
        PageOpened: Boolean;
    begin
        OnBeforeOpenServiceIntegrationSetupPage(Rec, PageOpened);
        if not PageOpened then
            Message(ServiceIntegrationSetupMsg);
    end;
#endif

    local procedure ReceiveDocs()
    var
        FailedEDocument: Record "E-Document";
        EDocImport: Codeunit "E-Doc. Import";
        Success: Boolean;
    begin
        Success := EDocImport.ReceiveAndProcessAutomatically(Rec);
        if not Success then
            if FailedEDocument.Get(Rec.LastEDocumentLog("E-Document Service Status"::"Imported Document Processing Error")."E-Doc. Entry No") then
                if Confirm(DocNotCreatedQst, true, FailedEDocument."Document Type") then
                    Page.Run(Page::"E-Document", FailedEDocument);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOpenServiceIntegrationSetupPage(EDocumentService: Record "E-Document Service"; var IsServiceIntegrationSetupRun: Boolean)
    begin
    end;

}