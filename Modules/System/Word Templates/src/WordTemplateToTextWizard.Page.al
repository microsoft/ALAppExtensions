// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// A wizard to select a Word template that can then be output as text
/// </summary>
page 9999 "Word Template To Text Wizard"
{
    PageType = NavigatePage;
    Caption = 'Apply Word Template';
    SourceTable = "Word Template";
    Permissions = tabledata "Word Template" = rm;
    Extensible = false;

    layout
    {
        area(Content)
        {
            group(WordTemplatesDontExist)
            {
                Visible = not WordTemplatesExist;
                Caption = 'We could not find any Word templates.';
                InstructionalText = 'Before you can continue you must first create at least one Word template.';
            }

            group(SelectTemplate)
            {
                Visible = WordTemplatesExist;

                repeater(Templates)
                {
                    Editable = false;

                    field(Code; Rec.Code)
                    {
                        ApplicationArea = All;
                        Caption = 'Code';
                        ToolTip = 'Specifies the code of the template.';
                        Editable = false;
                    }

                    field(Name; Rec.Name)
                    {
                        ApplicationArea = All;
                        Caption = 'Name';
                        ToolTip = 'Specifies the name of the template.';
                        Editable = false;
                    }
                    field(TableName; Rec."Table Caption")
                    {
                        ApplicationArea = All;
                        Caption = 'Entity';
                        ToolTip = 'Specifies the entity the template is asscociated with.';
                        Editable = false;
                    }
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Finish)
            {
                ApplicationArea = All;
                Image = NextRecord;
                InFooterBar = true;
                ToolTip = ' ';

                trigger OnAction()
                var
                    RecordRef: RecordRef;
                    FieldRef: FieldRef;
                    SystemId: Guid;
                begin

                    if not DataIntialized then begin
                        DictOfRecords.Get(Rec."Table ID", SystemId);
                        RecordRef.Open(Rec."Table ID");
                        FieldRef := RecordRef.Field(RecordRef.SystemIdNo);
                        FieldRef.SetRange(SystemId);
                        DataIntialized := true;
                    end;

                    WordTemplates.Load(Rec.Code);
                    WordTemplates.Merge(RecordRef, false, SaveFormat);
                    FinishedWizard := true;
                    CurrPage.Close();
                end;
            }

            action(New)
            {
                ApplicationArea = All;
                Caption = 'New Template';
                ToolTip = 'Create a new Word template';
                Image = New;
                InFooterBar = true;

                trigger OnAction()
                var
                    WordTemplatesCreationWizard: Page "Word Template Creation Wizard";
                begin
                    if TableId <> 0 then
                        WordTemplatesCreationWizard.SetMultipleTableNo(DictOfRecords.Keys(), TableId);

                    // As this method populates the page, before it is run, 
                    // we commit to make sure that database transactions are done.
                    Commit();
                    WordTemplatesCreationWizard.RunModal();

                    WordTemplatesExist := not Rec.IsEmpty();
                    CurrPage.Update(true);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        WordTemplatesExist := not Rec.IsEmpty();
        FinishedWizard := false;
        SaveFormat := SaveFormat::Html;
    end;

    /// <summary>
    /// Set the output format of the template.
    /// </summary>
    /// <param name="Format">The word template format.</param>
    internal procedure SetFormat(Format: Enum "Word Templates Save Format")
    begin
        SaveFormat := Format;
    end;

    /// <summary>
    /// Set the entities that user can select to create the word template.
    /// </summary>
    /// <param name="Dict">Dictionary of TableId to SystemId entries.</param>
    internal procedure SetData(Dict: Dictionary of [Integer, Guid]; PrimarySource: Integer)
    var
        I: Integer;
        FilterBuilder: TextBuilder;
    begin
        for I := 1 to Dict.Count() do begin
            FilterBuilder.Append(Format(Dict.Keys().Get(I)));
            if I <> Dict.Count() then
                FilterBuilder.Append('|');
        end;
        Rec.SetFilter("Table ID", FilterBuilder.ToText());
        DictOfRecords := Dict;
        DataIntialized := false;
        TableId := PrimarySource;
    end;

    /// <summary>
    /// Get the word template document as text.
    /// </summary>
    /// <returns>Returns the word template as a text.</returns>
    internal procedure GetDocumentAsText(): Text
    var
        InStream: InStream;
        Text: Text;
    begin
        WordTemplates.GetDocument(InStream);
        InStream.ReadText(Text);
        exit(Text);
    end;

    /// <summary>
    /// Returns size of word template document.
    /// </summary>
    /// <returns>The size for the resulting document in bytes.</returns>
    internal procedure GetDocumentSize(): Integer
    begin
        exit(WordTemplates.GetDocumentSize());
    end;

    /// <summary>
    /// Returns if the user completed the dialog to add a word template.
    /// </summary>
    /// <returns>True if completed otherwise false.</returns>
    internal procedure WasDialogCompleted(): Boolean
    begin
        exit(FinishedWizard);
    end;

    var
        WordTemplates: Codeunit "Word Template";
        DictOfRecords: Dictionary of [Integer, Guid];
        DataIntialized: Boolean;
        WordTemplatesExist: Boolean;
        FinishedWizard: Boolean;
        TableId: Integer;
        SaveFormat: Enum "Word Templates Save Format";
}
