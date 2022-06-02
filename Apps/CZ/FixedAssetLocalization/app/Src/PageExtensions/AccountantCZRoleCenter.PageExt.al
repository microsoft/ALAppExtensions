pageextension 31205 "Accountant CZ Role Center CZF" extends "Accountant CZ Role Center CZL"
{
    actions
    {
        addlast("Fixed Asset Reports")
        {
            action("Fixed Asset Card CZF")
            {
                ApplicationArea = FixedAssets;
                Caption = 'Fixed Asset Card';
                Ellipsis = true;
                Image = Report;
                RunObject = Report "Fixed Asset Card CZF";
                ToolTip = 'View, print, or send the fixed asset card report.';
            }
            action("FA Physical Inventory List CZF")
            {
                ApplicationArea = FixedAssets;
                Caption = 'FA Physical Inventory List';
                Ellipsis = true;
                Image = Report;
                RunObject = Report "FA Physical Inventory List CZF";
                ToolTip = 'View, print, or send the fixed asset physical inventory list report.';
            }
            action("Fixed Asset - Book Value 1 CZF")
            {
                ApplicationArea = FixedAssets;
                Caption = 'Fixed Asset - Book Value 1';
                Ellipsis = true;
                Image = Report;
                RunObject = Report "Fixed Asset - Book Value 1 CZF";
                ToolTip = 'View, print, or send the fixed asset book value 1 report.';
            }
            action("Fixed Asset - An. Dep.Book CZF")
            {
                ApplicationArea = FixedAssets;
                Caption = 'Fixed Asset - Depreciation Book Analysis';
                Ellipsis = true;
                Image = Report;
                RunObject = Report "Fixed Asset - An. Dep.Book CZF";
                ToolTip = 'View, print, or send the fixed asset analysis of depreciation book report.';
            }
        }
    }
}
