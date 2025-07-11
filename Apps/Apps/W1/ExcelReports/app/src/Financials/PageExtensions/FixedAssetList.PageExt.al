namespace Microsoft.Finance.ExcelReports;
using Microsoft.FixedAssets.FixedAsset;

pageextension 4407 "Fixed Asset List" extends "Fixed Asset List"
{
    actions
    {
        addlast(reporting)
        {
            action("Fixed Asset Analysis - Excel")
            {
                ApplicationArea = All;
                Caption = 'Analysis (Excel)';
                Image = "Report";
                RunObject = report "EXR Fixed Asset Analysis Excel";
                ToolTip = 'View an analysis of your fixed assets with various types of data for both individual assets and groups of fixed assets.';
            }
            action("Fixed Asset Projected - Excel")
            {
                ApplicationArea = All;
                Caption = 'Projected Value (Excel)';
                Image = "Report";
                RunObject = report "EXR Fixed Asset Projected";
                ToolTip = 'View the calculated future depreciation and book value.';
            }
            action("Fixed Asset Details - Excel")
            {
                ApplicationArea = All;
                Caption = 'Details (Excel)';
                Image = View;
                RunObject = report "EXR Fixed Asset Details Excel";
                ToolTip = 'View detailed information about the fixed asset ledger entries that have been posted to a specified depreciation book for each fixed asset.';
            }
        }
        addlast(Category_Report)
        {
            actionref(FAAnalysisExcel_Promoted; "Fixed Asset Analysis - Excel")
            {
            }
            actionref(FAProjectedExcel_Promoted; "Fixed Asset Projected - Excel")
            {
            }
            actionref(FADetailsExcel_Promoted; "Fixed Asset Details - Excel")
            {
            }
        }
    }
}