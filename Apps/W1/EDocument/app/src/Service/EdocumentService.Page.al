﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.eServices.EDocument.IO.Peppol;
using System.Telemetry;

page 6133 "E-Document Service"
{
    ApplicationArea = Basic, Suite;
    PageType = Card;
    Caption = 'E-Document Service';
    SourceTable = "E-Document Service";
    DataCaptionFields = Code;

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

                    trigger OnValidate()
                    begin
                        CurrPage.Update(false);
                    end;
                }
                field("Service Integration"; Rec."Service Integration")
                {
                    ToolTip = 'Specifies integration code for the electronic export setup.';
                }
                field("Use Batch Processing"; Rec."Use Batch Processing")
                {
                    ToolTip = 'Specifies if service uses batch processing for export.';
                }
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
            group(ImportParamenters)
            {
                Caption = 'Imported Parameters';

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
                field("Update Order"; Rec."Update Order")
                {
                    ToolTip = 'Specifies if corresponding purchase order must be updated.';
                }
                field("Create Journal Lines"; Rec."Create Journal Lines")
                {
                    ToolTip = 'Specifies if journal line must be created instead of purchase document.';
                }
                field("General Journal Template Name"; Rec."General Journal Template Name")
                {
                    ToolTip = 'Specifies the General Journal Template Name used for journal line creation.';
                }
                field("General Journal Batch Name"; Rec."General Journal Batch Name")
                {
                    ToolTip = 'Specifies the General Journal Batch Name used for journal line creation.';
                }

                group(Import)
                {
                    ShowCaption = false;
                    field("Auto Import"; Rec."Auto Import")
                    {
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
            }
            part(EDocumentExportFormatMapping; "E-Doc. Mapping Part")
            {
                Caption = 'Export Mapping';
                SubPageLink = Code = field(Code), "For Import" = const(false);
                Visible = not (Rec."Document Format" = Rec."Document Format"::"Data Exchange");
            }
            part(EDocumentImportFormatMapping; "E-Doc. Mapping Part")
            {
                Caption = 'Import Mapping';
                SubPageLink = Code = field(Code), "For Import" = const(true);
                Visible = not (Rec."Document Format" = Rec."Document Format"::"Data Exchange");
            }
            part(EDocumentDataExchDef; "E-Doc. Service Data Exch. Sub")
            {
                ApplicationArea = All;
                Caption = 'Data Exchange Definition';
                SubPageLink = "E-Document Format Code" = field(Code);
                Visible = Rec."Document Format" = Rec."Document Format"::"Data Exchange";
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("SetupServiceIntegration")
            {
                Caption = 'Setup Service Integration';
                ToolTip = 'Setup Service Integration';
                Image = Setup;

                trigger OnAction()
                var
                    EDocumentIntegration: Interface "E-Document Integration";
                    SetupPage, SetupTable : integer;
                begin
                    EDocumentIntegration := Rec."Service Integration";
                    EDocumentIntegration.GetIntegrationSetup(SetupPage, SetupTable);
                    if SetupPage = 0 then
                        Message(ServiceIntegrationSetupMsg)
                    else
                        Page.Run(SetupPage);
                end;
            }
            action(Receive)
            {
                Caption = 'Receive';
                ToolTip = 'Manually Trigger Receive';
                Image = Import;

                trigger OnAction()
                var
                    EDocImport: Codeunit "E-Doc. Import";
                begin
                    EDocImport.ReceiveDocument(Rec);
                end;
            }
        }
        area(Promoted)
        {
            actionref("Promoted Setup service integration"; SetupServiceIntegration) { }
            actionref("Promoted Receive"; Receive) { }
        }
    }

    var
        ServiceIntegrationSetupMsg: Label 'There is no configuration setup for this service integration.';

    trigger OnOpenPage()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        EDocumentHelper: Codeunit "E-Document Processing";
    begin
        FeatureTelemetry.LogUptake('0000KZ6', EDocumentHelper.GetEDocTok(), Enum::"Feature Uptake Status"::Discovered);
        CurrPage.EDocumentExportFormatMapping.Page.SaveAsImport(false);
        CurrPage.EDocumentImportFormatMapping.Page.SaveAsImport(true);
    end;

    trigger OnClosePage()
    var
        EDocumentBackgroundJobs: Codeunit "E-Document Background Jobs";
    begin
        EDocumentBackgroundJobs.HandleRecurrentBatchJob(Rec);
        EDocumentBackgroundJobs.HandleRecurrentImportJob(Rec);
    end;
}
