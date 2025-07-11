// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

page 10063 "IRS 1099 Doc. Line API"
{
    APIPublisher = 'microsoft';
    APIGroup = 'irsForms';
    APIVersion = 'v1.0';
    EntityCaption = 'IRS 1099 Document Line';
    EntitySetCaption = 'IRS 1099 Document Lines';
    PageType = API;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    EntityName = 'irs1099documentline';
    EntitySetName = 'irs1099documentlines';
    ODataKeyFields = SystemId;
    SourceTable = "IRS 1099 Form Doc. Line";
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
                field(lineNo; Rec."Line No.")
                {
                    Caption = 'Line No.';
                }
                field(formBoxNo; Rec."Form Box No.")
                {
                    Caption = 'Form Box No.';
                }
                field(amount; Rec.Amount)
                {
                    Caption = 'Amount';
                }
                field(manuallyChanged; Rec."Manually Changed")
                {
                    Caption = 'Manually Changed';
                }
                field(includeIn1099; Rec."Include In 1099")
                {
                    Caption = 'Include In 1099';
                }
                field(minimumReportableAmount; Rec."Minimum Reportable Amount")
                {
                    Caption = 'Minimum Reportable Amount';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.ReadIsolation := IsolationLevel::ReadCommitted;
    end;
}