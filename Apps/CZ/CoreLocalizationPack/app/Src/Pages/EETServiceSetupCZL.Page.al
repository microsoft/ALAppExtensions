// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance;

using System.Security.Encryption;
using System.Utilities;

#pragma implicitwith disable
page 31142 "EET Service Setup CZL"
{
    ApplicationArea = Basic, Suite;
    Caption = 'EET Service Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = Card;
    ShowFilter = false;
    SourceTable = "EET Service Setup CZL";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Service URL"; Rec."Service URL")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = EditableByNotEnabled;
                    ToolTip = 'Specifies the source address of the service.';
                }
                field("Sales Regime"; Rec."Sales Regime")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = EditableByNotEnabled;
                    ToolTip = 'Specifies the settings for the simplified scheme sales.';
                }
                field("Limit Response Time"; Rec."Limit Response Time")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = EditableByNotEnabled;
                    Importance = Additional;
                    ToolTip = 'Specifies the response time limit, after which goes into offline mode.';
                }
                field("Appointing VAT Reg. No."; Rec."Appointing VAT Reg. No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = EditableByNotEnabled;
                    Importance = Additional;
                    ToolTip = 'Specifies the responsible person who collects revenues.';
                }
                field("Certificate Code"; Rec."Certificate Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = EditableByNotEnabled;
                    ToolTip = 'Specifies the certificate needed to register sales.';
                }
            }
            group(Status)
            {
                Caption = 'Status';
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the service is enabled.';

                    trigger OnValidate()
                    begin
                        UpdateBasedOnEnable();
                        CurrPage.Update();
                    end;
                }
                field(ShowEnableWarning; ShowEnableWarning)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the display of a warning message.';
                    ShowCaption = false;
                    AssistEdit = false;
                    Editable = false;
                    Enabled = not EditableByNotEnabled;

                    trigger OnDrillDown()
                    begin
                        DrilldownCode();
                    end;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("EET Business Premises")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'EET Business Premises';
                Image = ElectronicPayment;
                RunObject = page "EET Business Premises CZL";
                ToolTip = 'Displays a list of your premises.';
            }
            action("Certificate Codes")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Certificate Codes';
                Image = Certificate;
                RunObject = page "Certificate Code List CZL";
                ToolTip = 'Displays a list of available certificates.';
            }
        }
        area(Processing)
        {
            action(SetURLToDefault)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Set URL to Default';
                Enabled = not Rec.Enabled;
                Image = Restore;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Change the Service URL to its default value. You cannot cancel this action to revert back to the current value.';

                trigger OnAction()
                begin
                    Rec.SetURLToDefault(true);
                end;
            }
            action(JobQueueEntry)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Job Queue Entry';
                Enabled = Rec.Enabled;
                Image = JobListSetup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'View or edit the jobs that automatically process the incoming and outgoing electronic documents.';

                trigger OnAction()
                begin
                    Rec.ShowJobQueueEntry();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        UpdateBasedOnEnable();
    end;

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert(true);
        end;
        UpdateBasedOnEnable();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        EnableServiceQst: Label 'The %1 is not enabled. Are you sure you want to exit?', Comment = '%1 = pagecaption (EET Service Setup)';
    begin
        if not Rec.Enabled then
            exit(ConfirmManagement.GetResponse(StrSubstNo(EnableServiceQst, CurrPage.Caption), true))
    end;

    var
        ConfirmManagement: Codeunit "Confirm Management";
        ShowEnableWarning: Text;
        EditableByNotEnabled: Boolean;

    local procedure UpdateBasedOnEnable()
    var
        EnabledWarningTxt: Label 'You must disable the service before you can make changes.';
    begin
        EditableByNotEnabled := not Rec.Enabled;
        ShowEnableWarning := '';
        if CurrPage.Editable and Rec.Enabled then
            ShowEnableWarning := EnabledWarningTxt;
    end;

    local procedure DrilldownCode()
    var
        DisableEnableQst: Label 'Do you want to disable the EET service?';
    begin
        if ConfirmManagement.GetResponse(DisableEnableQst, true) then begin
            Rec.Enabled := false;
            UpdateBasedOnEnable();
            CurrPage.Update();
        end;
    end;
}
