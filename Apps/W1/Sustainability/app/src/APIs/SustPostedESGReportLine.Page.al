// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.API.V1;

using Microsoft.Sustainability.ESGReporting;

page 6334 "Sust. Posted ESG Report Line"
{
    APIGroup = 'sustainability';
    APIPublisher = 'microsoft';
    APIVersion = 'v1.0';
    EntityCaption = 'Posted ESG Report Line';
    EntitySetCaption = 'Posted ESG Report Lines';
    PageType = API;
    EntityName = 'postedESGReportLine';
    EntitySetName = 'postedESGReportLines';
    ODataKeyFields = SystemId;
    SourceTable = "Sust. Posted ESG Report Line";
    Extensible = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(esgReportingTemplateName; Rec."ESG Reporting Template Name")
                {
                    Caption = 'ESG Reporting Template Name';
                }
                field(esgReportingName; Rec."ESG Reporting Name")
                {
                    Caption = 'ESG Reporting Name';
                }
                field(lineNo; Rec."Line No.")
                {
                    Caption = 'Line No.';
                }
                field(grouping; Rec.Grouping)
                {
                    Caption = 'Grouping';
                }
                field(rowNo; Rec."Row No.")
                {
                    Caption = 'Row No.';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(reportingCode; Rec."Reporting Code")
                {
                    Caption = 'Reporting Code';
                }
                field(conceptLink; Rec."Concept Link")
                {
                    Caption = 'Concept Link';
                }
                field(concept; Rec.Concept)
                {
                    Caption = 'Concept';
                }
                field("fieldType"; Rec."Field Type")
                {
                    Caption = 'Field Type';
                }
                field(tableNo; Rec."Table No.")
                {
                    Caption = 'Table No.';
                }
                field(source; Rec.Source)
                {
                    Caption = 'Source';
                }
                field(fieldNo; Rec."Field No.")
                {
                    Caption = 'Field No.';
                }
                field(fieldCaption; Rec."Field Caption")
                {
                    Caption = 'Value';
                }
                field(valueSettings; Rec."Value Settings")
                {
                    Caption = 'Value Settings';
                }
                field(accountFilter; Rec."Account Filter")
                {
                    Caption = 'Account Filter';
                }
                field(reportingUnit; Rec."Reporting Unit")
                {
                    Caption = 'Reporting Unit';
                }
                field(rowType; Rec."Row Type")
                {
                    Caption = 'Row Type';
                }
                field(rowTotaling; Rec."Row Totaling")
                {
                    Caption = 'Row Totaling';
                }
                field(calculateWith; Rec."Calculate With")
                {
                    Caption = 'Calculate With';
                }
                field(show; Rec.Show)
                {
                    Caption = 'Show';
                }
                field(showWith; Rec."Show With")
                {
                    Caption = 'Show With';
                }
                field(rounding; Rec.Rounding)
                {
                    Caption = 'Rounding';
                }
                field(postedAmount; Rec."Posted Amount")
                {
                    Caption = 'Posted Amount';
                }
            }
        }
    }
}