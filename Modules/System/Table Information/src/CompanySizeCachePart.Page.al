// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// The Company Size Cache Part page shows information about company sizes.
/// </summary>
page 8702 "Company Size Cache Part"
{
    Caption = 'Companies';
    PageType = CardPart;
    RefreshOnActivate = true;
    Editable = false;
    SourceTable = "Company Size Cache";
    SourceTableView = sorting("Size (KB)") order(descending);
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Permissions = tabledata "Company Size Cache" = r;

    layout
    {
        area(content)
        {
            repeater(general)
            {
                field(CompanyName; Rec."Company Name")
                {
                    ApplicationArea = All;
                    Tooltip = 'The name of the company.';
                }
                field(SizeKB; Rec."Size (KB)")
                {
                    ApplicationArea = All;
                    ToolTip = 'How much space the company occupies in the database (in kilobytes)';
                }
            }
            group(Total)
            {
                ShowCaption = false;
                field(TotalSize; TotalSizeKB)
                {
                    ApplicationArea = All;
                    Caption = 'Total (KB)';
                    ToolTip = 'How much space all companies occupy in the database (in kilobytes)';
                }
            }
        }
    }

    var
        TotalSizeKB: Integer;

    trigger OnAfterGetCurrRecord()
    var
        TableInformationCacheImpl: Codeunit "Table Information Cache Impl.";
    begin
        TotalSizeKB := TableInformationCacheImpl.CalcCompaniesTotalSize();
    end;
}

