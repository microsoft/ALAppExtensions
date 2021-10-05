// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

page 2026 "Image Analysis Tags"
{
    PageType = Worksheet;
    SourceTable = "MS - Image Analyzer Tags";
    DeleteAllowed = false;
    InsertAllowed = false;
    Caption = 'Image Analyzer Attributes';
    PromotedActionCategories = 'New,Process,Report,Confidence Score,Blocklist', Comment = 'Blocklist is used to prevent the selected attributes from being suggested in the future.';

    layout
    {
        area(content)
        {
            repeater(TagsTable)
            {
                field(TagName; "Tag Name")
                {
                    ApplicationArea = Basic, Suite;
                    Enabled = false;
                    Editable = false;
                    Style = Strong;

                    trigger OnDrillDown()
                    begin
                        Error('');
                    end;

                }

                field(TagConfidence; "Tag Confidence")
                {
                    ApplicationArea = Basic, Suite;
                    Enabled = false;
                    Editable = false;
                    Style = Attention;
                    StyleExpr = Emphasize;
                }
                field(ActionToPerform; "Action To Perform")
                {
                    ApplicationArea = Basic, Suite;
                }

                field(DetailsText; "Details Text")
                {
                    Editable = false;
                    Enabled = false;
                    ApplicationArea = Basic, Suite;

                    trigger OnDrillDown()
                    var
                        ItemCategory: Record "Item Category";
                        ItemCategoryCard: Page "Item Category Card";
                    begin
                        case "Action To Perform" of
                            "Action To Perform"::Category:
                                begin
                                    ItemCategory.Get("Item Category Code");
                                    ItemCategoryCard.SetRecord(ItemCategory);
                                    ItemCategoryCard.RunModal();
                                    OnAssignCategory();
                                end;

                            "Action To Perform"::Attribute:
                                begin
                                    SelectItemAttribute();
                                    UpdateValueText();
                                    OnAssignAttribute();
                                end;
                        end;
                    end;
                }

                field(AppendToDescription; AppendTagTxt)
                {
                    Caption = 'Add to the Item Description';
                    Editable = false;
                    Enabled = false;
                    ApplicationArea = Basic, Suite;

                    trigger OnDrillDown()
                    begin
                        AppendTagToDescription("Tag Name");
                    end;
                }
            }
            group(ItemDescriptionGroup)
            {
                Caption = 'Item Description';
                Enabled = true;

                field(TheItemDescription; PageItemDescription)
                {
                    ApplicationArea = Basic, Suite;
                    ShowCaption = false;
                    Editable = true;
                    Enabled = true;
                    TableRelation = "MS - Image Analyzer Tags"."Tag Name";

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(FilterAttributesGroup)
            {
                Caption = 'Confidence Score';

                action(RemoveFilterLowConfidence)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'View All Attributes';
                    Enabled = FilterOn;
                    Visible = true;
                    Image = FilterLines;
                    InFooterBar = true;
                    Promoted = true;
                    PromotedIsBig = True;
                    PromotedCategory = Category4;

                    trigger OnAction()
                    begin
                        ToggleConfidenceTagFilter();
                    end;
                }

                action(FilterLowConfidence)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Hide Low Confidence Attributes';
                    Enabled = not FilterOn;
                    Visible = true;

                    Image = AllLines;
                    InFooterBar = true;
                    Promoted = true;
                    PromotedIsBig = True;
                    PromotedCategory = Category4;

                    trigger OnAction()
                    begin
                        ToggleConfidenceTagFilter();
                    end;
                }
            }

            group(BlacklistGroup)
            {
                Caption = 'Blocklist';
                action(ViewBlacklistedTags)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'View Blocked Attributes';
                    Enabled = True;
                    Visible = True;
                    Image = Approvals;
                    Promoted = true;
                    PromotedIsBig = True;
                    PromotedCategory = Category5;

                    trigger OnAction()
                    var
                        ImageAnalysisBlacklistPage: Page "Image Analysis Blacklist";
                    begin
                        ImageAnalysisBlacklistPage.RunModal();
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        Item: Record Item;
    begin
        Reset();
        FindFirst();
        Item.Get("Detected On Item No");
        PageItemDescription := Item.Description;

        SetFilter("Tag Confidence", StrSubstNo('>%1', ConfidencePercent));
        SetCurrentKey("Tag Confidence");
        SetAscending("Tag Confidence", true); //descending does not work
        FilterOn := true;
    end;

    trigger OnAfterGetRecord()
    begin
        Emphasize := "Tag Confidence" < ConfidencePercent;
    end;

    var
        PageItemDescription: Text[100];
        AppendTagTxt: Label 'Add to the item description';
        ConfidencePercent: Decimal;
        [InDataSet]
        Emphasize: Boolean;
        FilterOn: Boolean;

    procedure ToggleConfidenceTagFilter()
    begin
        Rec.Reset();
        SetCurrentKey("Tag Confidence");
        SetAscending("Tag Confidence", false);

        if FilterOn then
            SetFilter("Tag Confidence", '')
        else
            SetFilter("Tag Confidence", StrSubstNo('>%1', ConfidencePercent));

        FilterOn := not FilterOn;
    end;

    procedure AppendTagToDescription(CurrentTagName: Text[250])
    var
    begin
        if StrPos(lowercase(PageItemDescription), lowercase(CurrentTagName)) > 0 then
            exit;

        if PageItemDescription <> '' then
            PageItemDescription := Copystr(StrSubstNo('%1 %2', PageItemDescription, CurrentTagName), 1, MaxStrLen(PageItemDescription))
        else
            PageItemDescription := Copystr(CurrentTagName, 1, MaxStrLen(PageItemDescription));

        CurrPage.Update();
    end;

    procedure GetItemDescription(): Text[100]

    begin
        exit(PageItemDescription);
    end;

    procedure SetConfidencePercent(ConfidencePercentIn: Decimal)
    begin
        ConfidencePercent := ConfidencePercentIn;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAssignCategory()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAssignAttribute()
    begin
    end;
}