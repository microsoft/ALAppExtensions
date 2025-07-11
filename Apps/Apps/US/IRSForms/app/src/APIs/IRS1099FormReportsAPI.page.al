// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

page 10064 "IRS 1099 Form Reports API"
{
    APIPublisher = 'microsoft';
    APIGroup = 'irsForms';
    APIVersion = 'v1.0';
    EntityCaption = 'IRS 1099 Form Report';
    EntitySetCaption = 'IRS 1099 Form Reports';
    PageType = API;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    EntityName = 'irs1099formreport';
    EntitySetName = 'irs1099formreports';
    ODataKeyFields = SystemId;
    SourceTable = "IRS 1099 Form Report";
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'SystemId';
                }
                field(reportType; Format(Rec."Report Type").Replace(' ', '_'))
                {
                    Caption = 'Report Type';
                }
                field(fileContent; Rec."File Content")
                {
                    Caption = 'File Content';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.ReadIsolation := IsolationLevel::ReadCommitted;
    end;
}