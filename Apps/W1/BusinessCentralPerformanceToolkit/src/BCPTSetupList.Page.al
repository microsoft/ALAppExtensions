// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
page 149000 "BCPT Setup List"
{
    Caption = 'BCPT Suites';
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Import/Export';
    SourceTable = "BCPT Header";
    CardPageId = "BCPT Setup Card";
    Editable = false;
    RefreshOnActivate = true;
    UsageCategory = Lists;
    Extensible = true;
    AdditionalSearchTerms = 'BCPT,Benchmark,Perf,Performance,Toolkit';
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("Code"; Rec."Code")
                {
                    Caption = 'Code';
                    ToolTip = 'Specifies the ID of the BCPT.';
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    Caption = 'Description';
                    ToolTip = 'Specifies the description of the BCPT.';
                    ApplicationArea = All;
                }
                field(Started; Rec."Started at")
                {
                    Caption = 'Started at';
                    ToolTip = 'Specifies when the BCPT was started.';
                    ApplicationArea = All;
                }
                field(DurationMin; Rec."Duration (minutes)")
                {
                    Caption = 'Duration';
                    ToolTip = 'Specifies the duration of the BCPT.';
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    Caption = 'Status';
                    ToolTip = 'Specifies the status of the BCPT.';
                    ApplicationArea = All;
                }

            }
        }
    }
    actions
    {
        area(Processing)
        {
            group("Import/Export")
            {
                action(ImportBCPT)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Import';
                    Image = Import;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = false;
                    PromotedOnly = true;
                    ToolTip = 'Import a file with BCPT Suite details.';

                    trigger OnAction()
                    var
                        BCPTHeader: Record "BCPT Header";
                    begin
                        XMLPORT.Run(XMLPORT::"BCPT Import/Export", false, true, BCPTHeader);
                        CurrPage.Update(false);
                    end;
                }
                action(ExportBCPT)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Export';
                    Image = Export;
                    Enabled = ValidRecord;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = false;
                    PromotedOnly = true;
                    Scope = Repeater;
                    ToolTip = 'Exports a file with BCPT Suite details.';

                    trigger OnAction()
                    var
                        BCPTHeader: Record "BCPT Header";
                    begin
                        CurrPage.SetSelectionFilter(BCPTHeader);
                        XMLPORT.Run(XMLPORT::"BCPT Import/Export", false, false, BCPTHeader);
                        CurrPage.Update(false);
                    end;
                }

            }
        }
    }

    var
        ValidRecord: Boolean;

    trigger OnAfterGetCurrRecord()
    begin
        ValidRecord := Rec.Code <> '';
    end;
}