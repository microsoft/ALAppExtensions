// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Registration;

using System.Privacy;
using System.Utilities;

page 11755 "Reg. No. Service Config CZL"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Registration No. Validation Service Setup';
    DataCaptionExpression = '';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = Card;
    PopulateAllFields = false;
    ShowFilter = false;
    SourceTable = "Reg. No. Service Config CZL";
    UsageCategory = Administration;
    AdditionalSearchTerms = 'ARES Setup';

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                InstructionalText = 'Information Exchange System is an electronic means of validating identification numbers of economic operators registered in the Czech Republic for national transactions on goods and services.';
                field(ServiceEndpoint; Rec."Service Endpoint")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = ServiceEndpointEditable;
                    ToolTip = 'Specifies the endpoint of the registration number validation service.';
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the service is enabled.';

                    trigger OnValidate()
                    var
                        CustomerConsentMgt: Codeunit "Customer Consent Mgt.";
                    begin
                        if Rec.Enabled = xRec.Enabled then
                            exit;

                        if Rec.Enabled then begin
                            if not CustomerConsentMgt.ConfirmUserConsent() then begin
                                Rec.Enabled := false;
                                exit;
                            end;
                            Rec.TestField("Service Endpoint");
                            Message(TermsAndAgreementMsg);
                        end;
                    end;
                }
                field(ServiceConditionsLbl; ServiceConditionsLbl)
                {
                    Caption = 'Service Conditions';
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ShowCaption = false;
                    ToolTip = 'Specifies a hyperlink to operating conditions of service';

                    trigger OnDrillDown()
                    var
                        RegistrationLogMgtCZL: Codeunit "Registration Log Mgt. CZL";
                    begin
                        HyperLink(RegistrationLogMgtCZL.GetServiceConditionsURL());
                    end;
                }
            }
        }
    }
    actions
    {
        area(creation)
        {
            action(SettoDefault)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Set Default Endpoint';
                Image = Default;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Set the default URL in the Service Endpoint field.';

                trigger OnAction()
                var
                    RegLookupExtDataCZL: Codeunit "Reg. Lookup Ext. Data CZL";
                begin
                    if Rec.Enabled then
                        if ConfirmManagement.GetResponseOrDefault(DisableServiceQst, false) then
                            Rec.Enabled := false
                        else
                            exit;

                    Rec."Service Endpoint" := RegLookupExtDataCZL.GetRegistrationNoValidationWebServiceURL();
                    Rec.Modify(true);
                end;
            }
        }
    }
    trigger OnOpenPage()
    var
        RegistrationLogMgtCZL: Codeunit "Registration Log Mgt. CZL";
    begin
        RegistrationLogMgtCZL.SetupService();
    end;

    trigger OnAfterGetRecord()
    begin
        ServiceEndpointEditable := not Rec.Enabled;
    end;

    var
        ConfirmManagement: Codeunit "Confirm Management";
        DisableServiceQst: Label 'You must turn off the service while you set default values. Should we turn it off for you?';
        TermsAndAgreementMsg: Label 'You are accessing a third-party website and service. Review the disclaimer before you continue.';
        ServiceConditionsLbl: Label 'Service operating conditions';
        ServiceEndpointEditable: Boolean;
}
