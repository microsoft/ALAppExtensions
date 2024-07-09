namespace Microsoft.Finance.ExcelReports;

using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.Setup;
using Microsoft.FixedAssets.Ledger;

report 4411 "EXR Fixed Asset Details Excel"
{
    ApplicationArea = All;
    AdditionalSearchTerms = 'FA Details Excel,FA Details';
    Caption = 'Fixed Asset Details Excel (Preview)';
    DataAccessIntent = ReadOnly;
    DefaultRenderingLayout = FixedAssetDetailsExcel;
    ExcelLayoutMultipleDataSheets = true;
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;
    MaximumDatasetSize = 1000000;

    dataset
    {
        dataitem(FixedAssetData; "Fixed Asset")
        {
            DataItemTableView = sorting("No.");
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "FA Class Code", "FA Subclass Code", "Budgeted Asset", "FA Posting Date Filter";
            column(AssetNumber; "No.") { IncludeCaption = true; }
            column(AssetDescription; Description) { }
            column(FixedAssetClassCode; "FA Class Code") { IncludeCaption = true; }
            column(FixedAssetSubclassCode; "FA Subclass Code") { IncludeCaption = true; }
            column(FixedAssetLocation; "FA Location Code") { IncludeCaption = true; }
            column(BudgetedAsset; "Budgeted Asset") { IncludeCaption = true; }
            column(GlobalDimension1Code; "Global Dimension 1 Code") { IncludeCaption = true; }
            column(GlobalDimension2Code; "Global Dimension 2 Code") { IncludeCaption = true; }
            dataitem(FixedAssetLedgerEntry; "FA Ledger Entry")
            {
                DataItemTableView = sorting("FA No.", "Depreciation Book Code", "FA Posting Date");
                DataItemLink = "FA No." = field("No.");
                column(DocumentType; "Document Type") { IncludeCaption = true; }
                column(DocumentNumber; "Document No.") { IncludeCaption = true; }
                column(Description; Description) { IncludeCaption = true; }
                column(Amount; Amount) { IncludeCaption = true; }
                column(EntryNumber; "Entry No.") { IncludeCaption = true; }
                column(FixedAssetPostingType; "FA Posting Type") { IncludeCaption = true; }
                column(DepreciationDays; "No. of Depreciation Days") { IncludeCaption = true; }
                column(UserID; "User ID") { IncludeCaption = true; }
                column(PostingDate; "Posting Date") { IncludeCaption = true; }
                column(GLEntryNumber; "G/L Entry No.") { IncludeCaption = true; }
                column(FixedAssetPostingCategory; "FA Posting Category") { IncludeCaption = true; }
                column(DepreciationBookCode; "Depreciation Book Code") { IncludeCaption = true; }
                trigger OnPreDataItem()
                begin
                    if DepreciationBookCode <> '' then
                        FixedAssetLedgerEntry.SetRange("Depreciation Book Code", DepreciationBookCode);
                    FixedAssetLedgerEntry.SetFilter("FA Posting Date", FixedAssetData.GetFilter("FA Posting Date Filter"));
                    if not PrintReversedEntries then
                        FixedAssetLedgerEntry.SetRange("Reversed", false);
                end;
            }
            trigger OnAfterGetRecord()
            begin
                if (not IncludeInactive) and FixedAssetData.Inactive then
                    CurrReport.Skip();
            end;
        }
    }
    requestpage
    {
        SaveValues = true;
        AboutTitle = 'Fixed Asset Details Excel';
        AboutText = 'This report shows ledger entries for one or more fixed assets.';
        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(DepreciationBook; DepreciationBookCode)
                    {
                        ApplicationArea = All;
                        Caption = 'Depreciation Book';
                        TableRelation = "Depreciation Book";
                        ToolTip = 'Specifies the code for the depreciation book to be included in the report or batch job.';
                    }
                    field(IncludeReversedEntries; PrintReversedEntries)
                    {
                        ApplicationArea = All;
                        Caption = 'Include Reversed Entries';
                        ToolTip = 'Specifies if you want to include reversed fixed asset entries in the report.';
                    }
                    field(SkipInactive; IncludeInactive)
                    {
                        ApplicationArea = All;
                        Caption = 'Include Inactive Fixed Assets';
                        ToolTip = 'Specifies if you want to include inactive fixed assets in the report.';
                    }
                }
            }
        }

        trigger OnOpenPage()
        var
            FASetup: Record "FA Setup";
        begin
            if not FASetup.Get() then
                exit;
            DepreciationBookCode := FASetup."Default Depr. Book";
        end;

    }
    rendering
    {
        layout(FixedAssetDetailsExcel)
        {
            Type = Excel;
            LayoutFile = './ReportLayouts/Excel/FixedAsset/FixedAssetDetailsExcel.xlsx';
            Caption = 'Fixed Asset Details Excel';
            Summary = 'Built in layout for Fixed Asset Details.';
        }
    }
    labels
    {
        DataRetrieved = 'Data retrieved:';
        FixedAssetDetails = 'Fixed Asset Details', Comment = 'Max length: 31. Excel worksheet name.';
        AssetDescriptionLabel = 'Asset Description';
    }

    var
        DepreciationBookCode: Code[20];
        PrintReversedEntries, IncludeInactive : Boolean;
}