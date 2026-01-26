// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

page 10070 "Error Information IRIS"
{
    PageType = List;
    ApplicationArea = BasicUS;
    Caption = 'Error Information';
    SourceTable = "Error Information IRIS";
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Groupings)
            {
                field(ID; Rec."Line ID")
                {
                }
                field("Unique Transmission ID"; Rec."Unique Transmission ID")
                {
                    Visible = false;
                }
                field("Entity Type"; Rec."Entity Type")
                {
                }
                field("Submission ID"; Rec."Submission ID")
                {
                    Visible = false;
                }
                field("Record ID"; Rec."Record ID")
                {
                    Visible = false;
                }
                field("IRS 1099 Form Doc. ID"; Rec."IRS 1099 Form Doc. ID")
                {
                    trigger OnAssistEdit()
                    var
                        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
                    begin
                        if IRS1099FormDocHeader.Get(Rec."IRS 1099 Form Doc. ID") then
                            Page.RunModal(Page::"IRS 1099 Form Document", IRS1099FormDocHeader)
                        else
                            Error(IRS1099FormDocNotFoundErr, Rec."IRS 1099 Form Doc. ID");
                    end;
                }
                field("Error Code"; Rec."Error Code")
                {
                    Visible = false;
                }
                field("Error Message"; Rec."Error Message")
                {
                    StyleExpr = 'Attention';
                }
                field("Error Value"; Rec."Error Value")
                {
                }
                field("XML Element Path"; Rec."XML Element Path")
                {
                }
            }
        }
    }

    var
        IRS1099FormDocNotFoundErr: Label 'The IRS 1099 Form Document %1 was not found.', Comment = '%1 - IRS 1099 Form Document ID';
}