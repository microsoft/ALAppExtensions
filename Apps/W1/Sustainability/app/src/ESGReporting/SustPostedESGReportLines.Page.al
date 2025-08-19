// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ESGReporting;

using Microsoft.Integration.Dataverse;
using Microsoft.Sustainability.Setup;

page 6298 "Sust. Posted ESG Report Lines"
{
    Caption = 'Posted ESG Report Lines';
    ApplicationArea = Basic, Suite;
    UsageCategory = History;
    Editable = false;
    LinksAllowed = false;
    PageType = List;
    SourceTableView = sorting("Document No.")
                      order(descending);
    SourceTable = "Sust. Posted ESG Report Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Document No. field.';
                }
                field("ESG Reporting Template Name"; Rec."ESG Reporting Template Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the ESG Reporting Template Name field.';
                }
                field("ESG Reporting Name"; Rec."ESG Reporting Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the ESG Reporting Name field.';
                }
                field(Grouping; Rec.Grouping)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Grouping field.';
                }
                field("Row No."; Rec."Row No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a number that identifies the line.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description of the ESG reporting line.';
                }
                field("Reporting Code"; Rec."Reporting Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Reporting Code field.';
                }
                field("Concept Link"; Rec."Concept Link")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the Concept link of the Source field.';
                }
                field("Concept"; Rec."Concept")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the Concept of the Source field.';
                }
                field("Field Type"; Rec."Field Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Field Type field.';
                }
                field("Table No."; Rec."Table No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = Rec."Field Type" = Rec."Field Type"::"Table Field";
                    ToolTip = 'Specifies the value of the Table No. field.';
                }
                field(Source; Rec.Source)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Source field.';
                }

                field("Field No."; Rec."Field No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = Rec."Field Type" = Rec."Field Type"::"Table Field";
                    ToolTip = 'Specifies the value of the Field No. field.';
                }
                field("Field Caption"; Rec."Field Caption")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Value field.';
                }
                field("Value Settings"; Rec."Value Settings")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Value Settings field.';
                }
                field("Account Filter"; Rec."Account Filter")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Account Filter field.';
                }
                field("Reporting Unit"; Rec."Reporting Unit")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Reporting Unit field.';
                }
                field("Row Type"; Rec."Row Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Row Type field.';
                }
                field("Row Totaling"; Rec."Row Totaling")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Row Totaling field.';
                }
                field("Calculate with"; Rec."Calculate With")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Calculate with field.';
                }
                field(Show; Rec.Show)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Show field.';
                }
                field("Show with"; Rec."Show With")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Show with field.';
                }
                field(Rounding; Rec.Rounding)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Rounding field.';
                }
                field("Posted Amount"; Rec."Posted Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Posted Amount field.';
                }
                field("Coupled to Dataverse"; Rec."Coupled to Dataverse")
                {
                    ApplicationArea = All;
                    Visible = SustDataverseIntEnabled;
                }
            }
        }
    }
    actions
    {
        area(navigation)
        {
            group(ActionGroupCRM)
            {
                Caption = 'Dataverse';
                Visible = SustDataverseIntEnabled;
                action(CRMGotoFact)
                {
                    ApplicationArea = Suite;
                    Caption = 'Fact';
                    Image = CoupledItem;
                    ToolTip = 'Open the coupled Dataverse ESG Fact.';

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
                        PostedESGReportingLine: Record "Sust. Posted ESG Report Line";
                        CRMIntegrationManagement: Codeunit "CRM Integration Management";
                        CustomerRecordRef: RecordRef;
                    begin
                        CurrPage.SetSelectionFilter(PostedESGReportingLine);
                        PostedESGReportingLine.Next();

                        if PostedESGReportingLine.Count = 1 then
                            CRMIntegrationManagement.UpdateOneNow(PostedESGReportingLine.RecordId())
                        else begin
                            CustomerRecordRef.GetTable(PostedESGReportingLine);
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
                        ToolTip = 'Create or modify the coupling to a Dataverse ESG Fact.';

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
                        ToolTip = 'Delete the coupling to a Dataverse esg fact.';

                        trigger OnAction()
                        var
                            PostedESGReportingLine: Record "Sust. Posted ESG Report Line";
                            CRMCouplingManagement: Codeunit "CRM Coupling Management";
                            RecRef: RecordRef;
                        begin
                            CurrPage.SetSelectionFilter(PostedESGReportingLine);
                            RecRef.GetTable(PostedESGReportingLine);
                            CRMCouplingManagement.RemoveCoupling(RecRef);
                        end;
                    }
                }
                action(ShowLog)
                {
                    ApplicationArea = Suite;
                    Caption = 'Synchronization Log';
                    Image = Log;
                    ToolTip = 'View integration synchronization jobs for the esg fact table.';

                    trigger OnAction()
                    var
                        CRMIntegrationManagement: Codeunit "CRM Integration Management";
                    begin
                        CRMIntegrationManagement.ShowLog(Rec.RecordId());
                    end;
                }
            }
        }
        area(Promoted)
        {
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

    trigger OnOpenPage()
    var
        SustainabilitySetup: Record "Sustainability Setup";
        CRMIntegrationManagement: Codeunit "CRM Integration Management";
    begin
        CRMIntegrationEnabled := CRMIntegrationManagement.IsCRMIntegrationEnabled();
        CDSIntegrationEnabled := CRMIntegrationManagement.IsCDSIntegrationEnabled();
        if CRMIntegrationEnabled or CDSIntegrationEnabled then
            SustDataverseIntEnabled := SustainabilitySetup.IsDataverseIntegrationEnabled();
    end;

    trigger OnAfterGetCurrRecord()
    var
        CRMCouplingManagement: Codeunit "CRM Coupling Management";
    begin
        if CRMIntegrationEnabled or CDSIntegrationEnabled then
            CRMIsCoupledToRecord := CRMCouplingManagement.IsRecordCoupledToCRM(Rec.RecordId());
    end;

    var
        CRMIntegrationEnabled: Boolean;
        CDSIntegrationEnabled: Boolean;
        CRMIsCoupledToRecord: Boolean;
        SustDataverseIntEnabled: Boolean;
}