// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Agent.SalesOrderAgent;

using System.Environment.Consumption;

page 4585 "SOA Billing Overview"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = "User AI Consumption Data";
    Caption = 'Sales Order Agent - Billing Overview';
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "User AI Consumption Data" = r;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
#pragma warning disable AA0218
                field(ID; Rec.ID)
                {
                }
                field(CopilotStudioFeature; Rec."Copilot Studio Feature")
                {
                    Caption = 'Copilot Studio Feature';
                }
                field(Operation; Rec."Actions")
                {
                    Caption = 'Actions';
                }
                field(Description; DescriptionTxt)
                {
                    Caption = 'Description';
                    ToolTip = 'Specifies the description of the operation';
                    trigger OnDrillDown()
                    begin
                        Message(DescriptionTxt);
                    end;
                }
                field("Agent Task ID"; Rec."Agent Task ID")
                {
                }
                field("Company Name"; Rec."Company Name")
                {
                    Visible = false;
                }
                field(Credits; Rec."Copilot Credits")
                {
                    Visible = false;
                    AutoFormatType = 0;
                }
                field(ConsumptionDateTime; Rec."Consumption DateTime")
                {
                }
            }
        }
    }
#pragma warning restore AA0218

    trigger OnOpenPage()
    var
        CurrentModule: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(CurrentModule);
        Rec.SetRange("App Id", CurrentModule.Id);
    end;

    trigger OnAfterGetRecord()
    var
        DescriptionInStream: InStream;
    begin
        Rec.CalcFields(Description);
        Rec.Description.CreateInStream(DescriptionInStream, TextEncoding::UTF8);
        DescriptionInStream.ReadText(DescriptionTxt);
    end;

    var
        DescriptionTxt: Text;
}

