// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ESGReporting;

using Microsoft.Integration.Dataverse;
using Microsoft.Sustainability.Setup;

page 6251 "Sust. ESG Reporting Names"
{
    Caption = 'ESG Reporting Names';
    DataCaptionExpression = DataCaption();
    PageType = List;
    SourceTable = "Sust. ESG Reporting Name";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ESG reporting name.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description of the ESG reporting name.';
                }
                field("Standard"; Rec."Standard")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a Standard of the ESG reporting name.';
                }
                field("Period Name"; Rec."Period Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a period of the ESG reporting name.';
                }
                field("Period Starting Date"; Rec."Period Starting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a period starting date of the ESG reporting name.';
                }
                field("Period Ending Date"; Rec."Period Ending Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a period ending date of the ESG reporting name.';
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a Country/Region Code of the ESG reporting name.';
                }
                field(Posted; Rec.Posted)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a Posted of the ESG reporting name.';
                }
                field("Coupled to Dataverse"; Rec."Coupled to Dataverse")
                {
                    ApplicationArea = All;
                    Visible = SustDataverseIntEnabled;
                }
            }
        }
        area(factboxes)
        {
            systempart(Links; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Edit ESG Reporting")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Edit ESG Reporting';
                Image = SetupList;
                ToolTip = 'View or edit how to calculate your ESG reporting amount for a period.';

                trigger OnAction()
                begin
                    ESGReportingManagement.TemplateSelectionFromBatch(Rec);
                end;
            }
            action("Print")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Print';
                Ellipsis = true;
                Image = Print;
                ToolTip = 'Prepare to print the document. A report request window for the document opens where you can specify what to include on the print-out.';

                trigger OnAction()
                begin
                    ESGReportingManagement.PrintESGReportingName(Rec);
                end;
            }
        }
        area(Navigation)
        {
            group(ActionGroupCRM)
            {
                Caption = 'Dataverse';
                Visible = SustDataverseIntEnabled;
                action(CRMGotoAssessment)
                {
                    ApplicationArea = Suite;
                    Caption = 'Assessment';
                    Image = CoupledItem;
                    ToolTip = 'Open the coupled Dataverse assessment.';

                    trigger OnAction()
                    var
                        CRMIntegrationManagement: Codeunit "CRM Integration Management";
                    begin
                        CRMIntegrationManagement.ShowCRMEntityFromRecordID(Rec.RecordId());
                    end;
                }
                action(CRMSynchronizeNow)
                {
                    AccessByPermission = TableData "CRM Integration Record" = IM;
                    ApplicationArea = Suite;
                    Caption = 'Synchronize';
                    Image = Refresh;
                    ToolTip = 'Send or get updated data to or from Dataverse.';

                    trigger OnAction()
                    var
                        ESGReportingName: Record "Sust. ESG Reporting Name";
                        CRMIntegrationManagement: Codeunit "CRM Integration Management";
                        CustomerRecordRef: RecordRef;
                    begin
                        CurrPage.SetSelectionFilter(ESGReportingName);
                        ESGReportingName.Next();

                        if ESGReportingName.Count = 1 then
                            CRMIntegrationManagement.UpdateOneNow(ESGReportingName.RecordId())
                        else begin
                            CustomerRecordRef.GetTable(ESGReportingName);
                            CRMIntegrationManagement.UpdateMultipleNow(CustomerRecordRef);
                        end
                    end;
                }
                group(Coupling)
                {
                    Caption = 'Coupling', Comment = 'Coupling is a noun';
                    Image = LinkAccount;
                    ToolTip = 'Create, change, or delete a coupling between the Business Central record and a Dataverse record.';
                    action(ManageCRMCoupling)
                    {
                        AccessByPermission = TableData "CRM Integration Record" = IM;
                        ApplicationArea = Suite;
                        Caption = 'Set Up Coupling';
                        Image = LinkAccount;
                        ToolTip = 'Create or modify the coupling to a Dataverse assessment.';

                        trigger OnAction()
                        var
                            CRMIntegrationManagement: Codeunit "CRM Integration Management";
                        begin
                            CRMIntegrationManagement.DefineCoupling(Rec.RecordId());
                        end;
                    }
                    action(DeleteCRMCoupling)
                    {
                        AccessByPermission = TableData "CRM Integration Record" = D;
                        ApplicationArea = Suite;
                        Caption = 'Delete Coupling';
                        Enabled = CRMIsCoupledToRecord;
                        Image = UnLinkAccount;
                        ToolTip = 'Delete the coupling to a Dataverse assessment.';

                        trigger OnAction()
                        var
                            ESGReportingName: Record "Sust. ESG Reporting Name";
                            CRMCouplingManagement: Codeunit "CRM Coupling Management";
                            RecRef: RecordRef;
                        begin
                            CurrPage.SetSelectionFilter(ESGReportingName);
                            RecRef.GetTable(ESGReportingName);
                            CRMCouplingManagement.RemoveCoupling(RecRef);
                        end;
                    }
                }
                action(ShowLog)
                {
                    ApplicationArea = Suite;
                    Caption = 'Synchronization Log';
                    Image = Log;
                    ToolTip = 'View integration synchronization jobs for the reporting name table.';

                    trigger OnAction()
                    var
                        CRMIntegrationManagement: Codeunit "CRM Integration Management";
                    begin
                        CRMIntegrationManagement.ShowLog(Rec.RecordId);
                    end;
                }
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref("Edit ESG Reporting_Promoted"; "Edit ESG Reporting")
                {
                }
                actionref("Print_Promoted"; "Print")
                {
                }
            }
            group(Category_Synchronize)
            {
                Caption = 'Synchronize';
                Visible = SustDataverseIntEnabled;

                group(Category_Coupling)
                {
                    Caption = 'Coupling';
                    ShowAs = SplitButton;

                    actionref(ManageCRMCoupling_Promoted; ManageCRMCoupling)
                    {
                    }
                    actionref(DeleteCRMCoupling_Promoted; DeleteCRMCoupling)
                    {
                    }
                }
                actionref(CRMSynchronizeNow_Promoted; CRMSynchronizeNow)
                {
                }
                actionref(ShowLog_Promoted; ShowLog)
                {
                }
            }
        }
    }

    trigger OnInit()
    begin
        Rec.SetRange("ESG Reporting Template Name");
    end;

    trigger OnOpenPage()
    var
        SustainabilitySetup: Record "Sustainability Setup";
        CRMIntegrationManagement: Codeunit "CRM Integration Management";
    begin
        CRMIntegrationEnabled := CRMIntegrationManagement.IsCRMIntegrationEnabled();
        CDSIntegrationEnabled := CRMIntegrationManagement.IsCDSIntegrationEnabled();
        if CRMIntegrationEnabled or CDSIntegrationEnabled then
            SustDataverseIntEnabled := SustainabilitySetup.IsDataverseIntegrationEnabled();

        ESGReportingManagement.OpenESGReportingBatch(Rec);
    end;

    trigger OnAfterGetCurrRecord()
    var
        CRMCouplingManagement: Codeunit "CRM Coupling Management";
    begin
        if CRMIntegrationEnabled or CDSIntegrationEnabled then
            CRMIsCoupledToRecord := CRMCouplingManagement.IsRecordCoupledToCRM(Rec.RecordId);
    end;

    var
        ESGReportingManagement: Codeunit "Sust. ESG Reporting Management";
        CRMIntegrationEnabled: Boolean;
        CDSIntegrationEnabled: Boolean;
        CRMIsCoupledToRecord: Boolean;
        SustDataverseIntEnabled: Boolean;

    local procedure DataCaption(): Text[250]
    var
        ESGReportingTemplate: Record "Sust. ESG Reporting Template";
    begin
        if not CurrPage.LookupMode then
            if Rec.GetFilter("ESG Reporting Template Name") <> '' then begin
                ESGReportingTemplate.SetFilter(Name, Rec.GetFilter("ESG Reporting Template Name"));
                if ESGReportingTemplate.FindSet() then
                    if ESGReportingTemplate.Next() = 0 then
                        exit(ESGReportingTemplate.Name + ' ' + ESGReportingTemplate.Description);
            end;
    end;
}