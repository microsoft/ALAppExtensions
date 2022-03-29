// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Presents a list of available Word templates.
/// </summary>
page 9989 "Word Templates"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Word Template";
    PromotedActionCategories = 'New,Process';
    InsertAllowed = false;
    Permissions = tabledata "Word Template" = rmd,
                  tabledata "Word Templates Related Table" = r;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code of the template.';
                }

                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the template.';
                }
                field(Caption; Rec."Table Caption")
                {
                    ApplicationArea = All;
                    Caption = 'Record';
                    ToolTip = 'Specifies entity assosiated with the template.';

                    trigger OnDrillDown()
                    var
                        WordTemplateImpl: Codeunit "Word Template Impl.";
                        TableId: Integer;
                    begin
                        TableID := WordTemplateImpl.SelectTable();

                        if TableId <> 0 then begin
                            Rec."Table ID" := TableId;
                            Rec.CalcFields("Table Caption");
                            CurrPage.Update();
                        end;
                    end;
                }
                field(Language; Rec."Language Name")
                {
                    ApplicationArea = All;
                    Caption = 'Language';
                    ToolTip = 'Specifies the language of the template.';

                    trigger OnDrillDown()
                    var
                        Language: Codeunit Language;
                    begin
                        Language.LookupLanguageCode(Rec."Language Code");
                        CurrPage.Update(true);
                    end;
                }
            }
        }

        area(Factboxes)
        {
            part("Word Template Related"; "Word Templates Related Factbox")
            {
                ApplicationArea = All;
                Caption = 'Related Entities';
                SubPageLink = Code = Field(Code);
                Editable = false;
            }
        }
    }

    actions
    {
        area(Creation)
        {
            action(CreateEmpty)
            {
                ApplicationArea = All;
                Image = New;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = New;
                Caption = 'Create a template';
                ToolTip = 'Create an empty Word template for a specific table.';
                RunObject = page "Word Template Creation Wizard";
            }
        }

        area(Processing)
        {
            action(Download)
            {
                ApplicationArea = All;
                Image = Export;
                Enabled = Rec.Code <> '';
                Caption = 'Download';
                ToolTip = 'Download the selected Word template.';
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    WordTemplates: Codeunit "Word Template Impl.";
                begin
                    WordTemplates.DownloadTemplate(Rec);
                end;
            }

            action(Upload)
            {
                ApplicationArea = All;
                Image = Import;
                Caption = 'Upload';
                ToolTip = 'Upload a new template for the selected entry.';
                Enabled = Rec.Code <> '';
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    WordTemplates: Codeunit "Word Template Impl.";
                begin
                    WordTemplates.Upload(Rec);
                end;
            }

            action(Apply)
            {
                ApplicationArea = All;
                Image = NextRecord;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Enabled = Rec.Code <> '';
                Caption = 'Apply';
                ToolTip = 'Apply Word template.';

                trigger OnAction()
                var
                    WordTemplateSelectionWizard: Page "Word Template Selection Wizard";
                begin
                    WordTemplateSelectionWizard.SetIsUnknownSource();
                    WordTemplateSelectionWizard.SetTemplate(Rec);
                    WordTemplateSelectionWizard.Run();
                end;
            }

            action(RelatedTables)
            {
                ApplicationArea = All;
                Image = EditLines;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Caption = 'Edit related entities';
                ToolTip = 'Edit the related entities for the selected Word template.';

                trigger OnAction()
                var
                    WordTemplateRelatedTable: Record "Word Templates Related Table";
                    WordTemplateRelatedList: Page "Word Templates Related List";
                begin
                    WordTemplateRelatedTable.SetRange(Code, Rec.Code);
                    WordTemplateRelatedList.SetTableView(WordTemplateRelatedTable);
                    WordTemplateRelatedList.SetTableNo(Rec."Table ID");
                    WordTemplateRelatedList.LookupMode(true);
                    WordTemplateRelatedList.RunModal();
                    CurrPage.Update();
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake('0000FW2', 'Word templates', Enum::"Feature Uptake Status"::Discovered);
    end;
}
