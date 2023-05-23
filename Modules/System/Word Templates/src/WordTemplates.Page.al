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
                    ToolTip = 'Specifies entity associated with the template.';

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
            part("Word Template Related"; "Word Templates Related FactBox")
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
                    WordTemplateRelatedEdit: Page "Word Templates Related Edit";
                begin
                    WordTemplateRelatedEdit.SetWordTemplate(Rec);
                    WordTemplateRelatedEdit.RunModal();
                    CurrPage.Update();
                end;
            }

            action(EditInOneDrive)
            {
                ApplicationArea = All;
                Image = Cloud;
                Caption = 'Edit in OneDrive';
                ToolTip = 'Copy the file to your Business Central folder in OneDrive and open it in a new window so you can edit the file.', Comment = 'OneDrive should not be translated';
                Scope = Repeater;
                Visible = EditOptionVisible;

                trigger OnAction()
                var
                    TempDocumentSharing: Record "Document Sharing" temporary;
                    DocumentSharingCodeunit: Codeunit "Document Sharing";
                    PreviousLength: Integer;
                    InStream: InStream;
                    OutStream: OutStream;
                begin
                    TempDocumentSharing.Name := Rec.Name + '.docx';
                    TempDocumentSharing.Extension := '.docx';

                    TempDocumentSharing."Document Sharing Intent" := Enum::"Document Sharing Intent"::Edit;

                    TempDocumentSharing.Data.CreateOutStream(OutStream);
                    Rec.Template.ExportStream(OutStream);
                    PreviousLength := TempDocumentSharing.Data.Length;

                    TempDocumentSharing.Insert();
                    DocumentSharingCodeunit.Share(TempDocumentSharing);

                    if TempDocumentSharing.Data.Length <> PreviousLength then begin
                        TempDocumentSharing.Data.CreateInStream(InStream);
                        Rec.Template.ImportStream(InStream, '');
                        Rec.Modify();
                    end;
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        DocumentSharing: Codeunit "Document Sharing";
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake('0000FW2', 'Word templates', Enum::"Feature Uptake Status"::Discovered);
        EditOptionVisible := DocumentSharing.ShareEnabled(Enum::"Document Sharing Source"::System);
    end;

    var
        EditOptionVisible: Boolean;
}
